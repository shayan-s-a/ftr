public class FieldAssignmentService {
    public static Boolean hasProcessed = false;
    public static Map<String, Schema.SObjectType> schemaMap;

    public Map<String, AutoFieldAssignmentSettings__mdt> settings;
    public AutoFieldAssignmentSettings__mdt currentSetting;
    private Order record;
    private String fieldName;
    private String fieldNameR;
    private String fieldLabel;
    private String fieldAssignmentQueue;
    private Map<String, List<FieldAssignment__c>> assignmentsByProducts;
    private Map<String, List<FieldAssignment__c>> assignmentsByWorkGroup;
    private String assignedUserFrom;
    private String orderRecordTypeName;
    private String[] orderStagesToNotInclude;
    
    public class FieldAssignmentServiceException extends Exception {}
    
    public FieldAssignmentService(Order oldOrder, Order newOrder) {
        try {
            System.debug('FieldAssignmentService START - ' + Limits.getCpuTime());
            
            this.record = newOrder;
            this.orderRecordTypeName = [SELECT Name FROM RecordType WHERE SObjectType = 'Order' AND Id = :newOrder.RecordTypeId].Name;

            getSettings();

            currentSetting = settings.get('Implementor_PM');
            if (currentSetting.IsAutomationEnabled__c 
                && newOrder.get('Implementor_PM__c') == null
                && currentSetting.IncludedProductTypes__c.split(';').contains(newOrder.Product_Type__c) 
                && !currentSetting.ExcludedRecordTypes__c.split(';').contains(orderRecordTypeName)
                && oldOrder.Order_Stage__c == 'New' 
                && newOrder.Order_Stage__c != 'Cancelled') {
                    assign('Implementor_PM__c', false);
            }

            currentSetting = settings.get('Network_Project_Specialist');
            if (currentSetting.IsAutomationEnabled__c 
                && newOrder.get('Network_Project_Specialist__c') == null
                && currentSetting.IncludedProductTypes__c.split(';').contains(newOrder.Product_Type__c) 
                && !currentSetting.ExcludedRecordTypes__c.split(';').contains(orderRecordTypeName)
                && oldOrder.Order_Stage__c == 'New' 
                && newOrder.Order_Stage__c != 'Cancelled') {
                    assign('Network_Project_Specialist__c', false);
            }

            currentSetting = settings.get('Order_Provisioner'); 
            if (currentSetting.IsAutomationEnabled__c 
                && (currentSetting.IncludedProductTypes__c.split(';').contains(newOrder.Product_Type__c) || newOrder.Product_Type__c == null)
                && currentSetting.IncludedRecordTypes__c.split(';').contains(orderRecordTypeName)
                && ((newOrder.Order_Stage__c == 'Customer Network Provisioning')||(newOrder.Order_Stage__c == 'CNP Quality Assurance'))) {
                
                // if no provisioner assigned, assign one and set as owner
                if (newOrder.get('Order_Provisioner__c') == null) {
                    assign('Order_Provisioner__c', false);

                // if provisioner is assigned, set as owner
                } else if (newOrder.OwnerId != newOrder.get('Order_Provisioner__c')) {
                    newOrder.OwnerId = (Id) newOrder.get('Order_Provisioner__c');
                }
            }

            System.debug('FieldAssignmentService END - ' + Limits.getCpuTime());
        } catch (Exception e) {
            System.debug('Exception occured: ' + e.getMessage());
            System.debug(e.getStackTraceString());
            throw e;
        }
    }


    /**
     * @description: grabs the settings to determine if order should be auto-assigned 
     */
    private void getSettings() {
        settings = new Map<String, AutoFieldAssignmentSettings__mdt>();
         
        for (AutoFieldAssignmentSettings__mdt setting : [SELECT Id, DeveloperName, IsAutomationEnabled__c, IncludedRecordTypes__c,QueueName__c, ShouldCreateTask__c, ExcludedOrderStages__c, ExcludedRecordTypes__c, IncludedProductTypes__c FROM AutoFieldAssignmentSettings__mdt]) {
            settings.put(setting.DeveloperName, setting);
        }
    }
    
    
    /**
    * @description will assign a user to the field passed in
    */
    public void assign(String fieldName, Boolean updateRecord) {
        if (record.get(fieldName) != null) return;

        System.debug('Start of Field Assignment for ' + fieldName + ' - ' + Limits.getCpuTime());
        try {
            
            this.fieldName = fieldName;
            this.fieldNameR = fieldName.split('__c')[0] + '__r';
            
            if (schemaMap == null) schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get('Order');
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            this.fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
            
            // query Field Assignment records
            getFieldAssignments();
            
            // run thru logic to assign user 
            Boolean result = assignUserToField();
            try {
                if(record.get(fieldName) != null){
                    User u = [SELECT Id, Name FROM User WHERE Id =:(String)record.get(fieldName)];
                    if (currentSetting.ShouldCreateTask__c) {
                        insert new Task(
                            Description = u.Name + '\n\n' + assignedUserFrom,
                            Subject = fieldLabel + ' Assignment',
                            Priority = 'Normal',
                            WhatId = record.Id,
                            RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SF_Team_Task').getRecordTypeId(),
                            IsReminderSet = true,
                            Status = 'Completed',
                            ActivityDate = Date.today(),
                            OwnerId = (String)record.get(fieldName)
                        );
                    }
                    if (fieldName == 'Order_Provisioner__c') {
                        if (record.Products__c != null) {
                            if (!record.Products__c.contains('EIA') && !record.Products__c.contains('EVPL')) {
                                record.put('OwnerId', u.Id);
                            }
                        } else {
                            record.put('OwnerId', u.Id);
                        }
                    }
                    sendOrderAssignmentEmail((String)record.get(fieldName)); 
                    System.debug('user assigned to ' + fieldName + ': ' + (String)record.get(fieldName));
                } else if (currentSetting.QueueName__c != null) {
                    Group myQ = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName =:currentSetting.QueueName__c LIMIT 1];
                    if (myQ == null) return;
                    insert new Task(
                        Description = 'An Order Provisioner needs to be assigned',
                        Subject = 'Order Provisioner Assignment',
                        Priority = 'High',
                        WhatId = record.Id,
                        OwnerId = myQ.Id,
                        RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SF_Team_Task').getRecordTypeId(),
                        ActivityDate = Date.today(),
                        IsReminderSet = true
                    );
                    sendOrderExceptionEmail(myQ);

                } else {
                    System.debug('no user assigned for ' + fieldName);
                }
            } catch (Exception e) {
                System.debug(e.getMessage());
            } 
            
            if (updateRecord && result) update record;
            
            System.debug('End of Field Assignment for ' + fieldName + ' - ' + Limits.getCpuTime());
            
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            throw ex;
        }
    }
    
    
    /**
    * @description assigns user based on workgroup
    */
    private Boolean assignUserToField() {
        orderStagesToNotInclude = currentSetting.ExcludedOrderStages__c.split(';');
        String productsForCheckingExistingRecords;
        List<FieldAssignment__c> fieldAssignments = new List<FieldAssignment__c>();

        // check if there's an assignment by customer
        if(assignmentsByWorkGroup.get('Customer')!= null){
            for (FieldAssignment__c fa : (List<FieldAssignment__c>) assignmentsByWorkGroup.get('Customer')) {
                if (record.AccountId == fa.AccountId__c) {
                    record.put(fieldName, fa.UserId__c);
                    assignedUserFrom = 'Assigned by Customer';
                    return true;
                }
            }
        }
        
        if (fieldName == 'Order_Provisioner__c') {
            // Order Provisioners match WorkGroup Name by record type name
            fieldAssignments = assignmentsByWorkGroup.get(orderRecordTypeName);

            // if there isnt a group by record type, assign to generic 
            if (fieldAssignments == null) {
                fieldAssignments = assignmentsByWorkGroup.get('Provisioners');
            }

        } else {
            // find field assignments & products for querying previous orders
        
            // special condition for SDWAN - Network Project Specialist
            if (record.Product_Type__c == 'SDWAN' && fieldName == 'Network_Project_Specialist__c') {
                if ( new List<String>{'SDWAN - E-Reach/Off-Net Ethernet', 'SDWAN - New or Upgrade Ethernet'}.contains(record.Product__c)) {
                    if (record.Add_On_Products__c != null && (record.Add_On_Products__c.contains('SIP Trunking') || record.Add_On_Products__c.contains('IP Connect'))) {
                        // use Complex products
                        if (assignmentsByWorkGroup.get('Complex') != null) {
                            fieldAssignments = assignmentsByWorkGroup.get('Complex');
                            productsForCheckingExistingRecords = (String)fieldAssignments[0].getSObject('WorkGroupId__r').get('ProductsForCheckingExistingRecords__c');
                        }
                    } else {
                        // use Non-Complex products
                        if (assignmentsByWorkGroup.get('Non-Complex') != null) {
                            fieldAssignments = assignmentsByWorkGroup.get('Non-Complex');
                            productsForCheckingExistingRecords = (String)fieldAssignments[0].getSObject('WorkGroupId__r').get('ProductsForCheckingExistingRecords__c');
                        }
                    }
                } else {
                    // dont assign anyone
                    return false;
                }
            }

            Boolean hasAddOnProduct = false;
            // get assignments & products for query based on Order's Product
            if (productsForCheckingExistingRecords == null) {
                for (String products : assignmentsByProducts.keySet()) {
                    List<String> prodList = products.split(';');
                    if (record.Add_On_Products__c != null) {
                        for (String addOnProduct : record.Add_On_Products__c.split(';')) {
                            if (prodList.contains(addOnProduct)) {
                                hasAddOnProduct = true;
                            }
                        }
                    }
                    if (prodList.contains(record.Circuit_Product__c) ||  prodList.contains(record.Product_Type__c) || prodList.contains(record.Product__c) || prodList.contains(record.Router_s__c) || hasAddOnProduct) {
                        fieldAssignments = assignmentsByProducts.get(products);
                        productsForCheckingExistingRecords = (String)fieldAssignments[0].getSObject('WorkGroupId__r').get('ProductsForCheckingExistingRecords__c');
                        break;
                    }
                }
            }
        }
        
        String accountId = record.AccountId;
        String quoteId;
        String query;
        List<Order> customerOrders = new List<Order>();
        
        if (fieldName == 'Network_Project_Specialist__c') {
            if (String.isNotBlank(productsForCheckingExistingRecords)) {

                List<String> prodList = productsForCheckingExistingRecords.split(';');
                
                // check if there is a PS assigned to an order created from the same quote (i.e.. UCF + EIA quote should have the same PS for both orders)
                if (record.vlocity_cmt__QuoteId__c != null) {
                    quoteId = record.vlocity_cmt__QuoteId__c;
                    query = 'SELECT Id, ' + fieldName + ' FROM Order WHERE ' + fieldName + ' <> NULL AND ' + fieldNameR + '.isActive = TRUE AND Order_Stage__c NOT IN :orderStagesToNotInclude AND vlocity_cmt__QuoteId__c =:quoteId AND (Circuit_Product__c IN :prodList OR Product_Type__c IN :prodList OR Product__c IN :prodList OR Add_On_Products__c IN :prodList OR Router_s__c IN :prodList) Order By CreatedDate DESC';
                    customerOrders = new List<Order>();
                    customerOrders = (List<Order>)(Database.query(query));
                    if(customerOrders.size() > 0){
                        assignedUserFrom = 'Assigned by related Quote';
                    }
                }

                // check if there are any users assigned to active orders in the last 6mo for this customer
                if (customerOrders.size() == 0) {
                    query = 'SELECT Id, OrderNumber, ' + fieldName + ' FROM Order WHERE AccountId =:accountId AND ' + fieldName + ' <> NULL AND ' + fieldNameR + '.isActive = TRUE AND CreatedDate >= LAST_N_MONTHS:6 AND ' + fieldName+ ' IN (SELECT UserId__c FROM FieldAssignment__c WHERE OutOfOffice__c = false) AND (Circuit_Product__c IN :prodList OR Product_Type__c IN :prodList OR Product__c IN :prodList OR Add_On_Products__c IN :prodList OR Router_s__c IN :prodList) AND Order_Stage__c NOT IN :orderStagesToNotInclude Order By CreatedDate DESC';
                    customerOrders = new List<Order>();
                    customerOrders = (List<Order>)(Database.query(query));
                    if(customerOrders.size() > 0){
                        assignedUserFrom = 'Assigned from order ' + customerOrders[0].OrderNumber;
                    }
                }
            }
        } else if (fieldName == 'Order_Provisioner__c') {
            // check if there are any users assigned to active orders in the last 6mo for this customer
            if (customerOrders.size() == 0) {
                query='SELECT Id, OrderNumber, ' + fieldName + ' FROM Order WHERE AccountId =:accountId AND ' + fieldName + ' <> NULL AND ' + fieldNameR + '.isActive = TRUE AND CreatedDate >= LAST_N_MONTHS:6 AND ' + fieldName + ' IN (SELECT UserId__c FROM FieldAssignment__c WHERE OutOfOffice__c = false) AND Order_Stage__c NOT IN :orderStagesToNotInclude  Order By CreatedDate DESC';
                customerOrders = new List<Order>();
                customerOrders = (List<Order>)(Database.query(query));
                if(customerOrders.size() > 0){
                    assignedUserFrom = 'Assigned from order ' + customerOrders[0].OrderNumber;
                }
            }
        }
        // if an orders meets the criteria, assign user
        if (customerOrders.size() > 0) {
            record.put(fieldName, customerOrders[0].get(fieldName));
            return true;
        } else {
            // assign user with smallest workload 
            Workload assignee;
            if (fieldAssignments != null) {
                if (fieldName == 'Order_Provisioner__c')
                    assignee = getUserByRoundRobin(fieldAssignments);
                else
                    assignee = getUserWithSmallestWorkload(fieldAssignments);
            }

            if(assignee != null){
                assignedUserFrom = 'Assigned from the ' + fieldAssignments[0].getSObject('WorkgroupId__r').get('Name') + ' workgroup. \n\n Workload: ' + assignee.count;
                record.put(fieldName, assignee.userId);
                return true;
            } else{
                return false;
            }
            
        }
        
        //return false;
    }
    
    public class Workload implements Comparable {
        String userId;
        Integer count;
        public Workload(String userId, Integer count) {
            this.userId = userId;
            this.count = count;
        }
        public Integer compareTo(Object other) {
            // for descending order
            return count - ((Workload) other).count;
        }
    }
    
    /**
    * @description returns the user with the lowest workload
    */
    private Workload getUserWithSmallestWorkload(List<FieldAssignment__c> fieldAssignments) {
        Workload assignee;
        Map<String, Integer> userIdMap = new Map<String, Integer>();
        List<Workload> userWorkloadsPrimary = new List<Workload>();
        List<Workload> userWorkloadsSecondary = new List<Workload>();
        Integer multiLocationCount = 5;
        for (FieldAssignment__c fa : fieldAssignments) {
            userIdMap.put(fa.UserId__c, 0);
        }
        Set<String> userIds = userIdMap.keySet();
        
        // get ACTIVE order counts, group by users 
        String query = 'SELECT Id, Multi_Location__c, ' + fieldName + ' FROM Order WHERE ' + fieldName + ' IN :userIds AND Order_Stage__c NOT IN :orderStagesToNotInclude LIMIT 50000';
        Order[] assignedOrders = (Order[]) Database.query(query);
        
        for (Order ord : assignedOrders) {
            String uId = (String)ord.get(fieldName);
            if (userIdMap.containsKey(uId)) {
                Integer count = userIdMap.get(uId);
                if (ord.Multi_Location__c == 'Yes' && fieldName == 'Network_Project_Specialist__c')
                    count += multiLocationCount;
                else
                    count++;
                userIdMap.put(uId, count);
            }
        }
        
        // break into two lists for primary and secondary assignees
        for (FieldAssignment__c fa : fieldAssignments) {
            if (fa.Primary__c) {
                userWorkloadsPrimary.add(new Workload(fa.UserId__c, userIdMap.get(fa.UserId__c)));
            } else {
                userWorkloadsSecondary.add(new Workload(fa.UserId__c, userIdMap.get(fa.UserId__c)));
            }
        }
        
        userWorkloadsPrimary.sort();
        userWorkloadsSecondary.sort();
        
        if (userWorkloadsPrimary.size() > 0 && userWorkloadsSecondary.size() > 0) {
            // check both
            if (userWorkloadsPrimary[0].count > 74) {
                if (userWorkloadsSecondary.size() > 0){
                    if (userWorkloadsSecondary[0].count > 74) {
                        assignee = userWorkloadsPrimary[0];
                    } else {
                        assignee = userWorkloadsSecondary[0];
                    }
                }
            } else {
                assignee = userWorkloadsPrimary[0];
            }  
        } else if (userWorkloadsPrimary.size() > 0) {
            // assign first in primary if secondary list is empty
            assignee = userWorkloadsPrimary[0];
        } else if (userWorkloadsSecondary.size() > 0) {
            // assign first in secondary if primary list is empty
            assignee = userWorkloadsSecondary[0];
        }
               
        return assignee;
    }

    /**
    * @description returns the  next user to be assigned
    */
    private Workload getUserByRoundRobin(List<FieldAssignment__c> fieldAssignments) {
        SObject fieldAssignment;
        SObject[] records = new List<SObject>();
        for (FieldAssignment__c fa : fieldAssignments) {
            if (fa.ProcessedRecord__c == false) {
                fieldAssignment = fa;
                break;
            }
        }  
        if (fieldAssignment != null) {
            // if we find an assignment, flag it as processed
            fieldAssignment.put('ProcessedRecord__c', true);
            Database.updateAsync(fieldAssignment);   

        } else {
            // if we dont find an assignment, grab the first person and reset the flags
            fieldAssignment = fieldAssignments[0];
            fieldAssignments.remove(0);
            for (FieldAssignment__c fa : fieldAssignments) {
                fa.ProcessedRecord__c = false;
            }  
            records.addAll(fieldAssignments);
            Database.updateAsync(records);
            
        }
        
        return new Workload((String)fieldAssignment.get('UserId__c'), null);
    }
    
    /**
    * @description queries all FieldAssignment records and places them into two maps
    */
    private void getFieldAssignments() {
        String query = 'SELECT Id, UserId__c, AccountId__c, Primary__c, WorkGroupId__r.Name, ProcessedRecord__c, WorkGroupId__r.SupportedProducts__c, WorkGroupId__r.ProductsForCheckingExistingRecords__c FROM FieldAssignment__c  WHERE OutOfOffice__c = FALSE AND WorkGroupId__r.Field__c = :fieldName  ';
        if (fieldName != 'Order_Provisioner__c') {
            String state = record.ShippingStateCode;
            query += ' AND (States__c INCLUDES (:state) OR AccountId__c <> NULL) ';
        }
        query += ' ORDER BY WorkGroupId__r.Priority__c ASC, UserId__r.Name ASC ';
        List<FieldAssignment__c> assignments = (List<FieldAssignment__c>) Database.query(query);
        assignmentsByProducts = new Map<String, List<FieldAssignment__c>>();
        assignmentsByWorkGroup = new Map<String, List<FieldAssignment__c>>();
        
        for (FieldAssignment__c fa : assignments) {
            if(fa.WorkGroupId__r.SupportedProducts__c != null){
                // map of assignments by supported products
                if (assignmentsByProducts.containsKey(fa.WorkGroupId__r.SupportedProducts__c)) {
                    assignmentsByProducts.get(fa.WorkGroupId__r.SupportedProducts__c).add(fa);
                } else {
                    assignmentsByProducts.put(fa.WorkGroupId__r.SupportedProducts__c, new List<FieldAssignment__c>{ fa });
                }
            }
            // map of assignments by workgroup
            if (assignmentsByWorkGroup.containsKey(fa.WorkGroupId__r.Name)) {
                assignmentsByWorkGroup.get(fa.WorkGroupId__r.Name).add(fa);
            } else {
                assignmentsByWorkGroup.put(fa.WorkGroupId__r.Name, new List<FieldAssignment__c>{ fa });
            }
        }
    }
    
    public static void sendOrderDetails(Order newOrder, Order oldOrder, String userId) {
        
        User assignee;
        try {
            if(userId != null){
                assignee = [Select Id,Name,Email from User where Id =:userId];
            } 
            Account acc = [SELECT Name FROM Account WHERE Id =:newOrder.AccountId LIMIT 1];
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new List<String> {assignee.Email};
                message.setSenderDisplayName('Salesforce Ordering Notification');
            message.subject = 'SF Order ' + newOrder.OrderNumber + ' - ' + newOrder.Order_Stage__c;
            //message.plaintextbody = 'Salesforce order ' + newOrder.OrderNumber + ' has moved from ' + oldOrder.Order_Stage__c + ' to ' + newOrder.Order_Stage__c + '.\n\n Order link: ' + URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/r/Order/'+ newOrder.Id +'/view  \n\n Thank you.';
            message.plaintextbody = 'Dear ' + assignee.Name + '\n\nSalesforce order ' + newOrder.OrderNumber + ' for ' + acc.Name + ' has progressed to ' + newOrder.Order_Stage__c + '.\n\nLink to order: \n' + URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/r/Order/'+ newOrder.Id +'/view ';
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (!results[0].success) {
                System.debug('Error in sending email: ' + results[0].errors[0].message);
            } else {
                System.debug('Email with order details sent to: ' + assignee.Email);
            }
        } catch (Exception e) {
            System.debug('Exception occured. Email was not sent.');
            System.debug(e.getMessage());
        }
    }
    
    public void sendOrderAssignmentEmail( String userId) {
        
        User assignee;
        try {
            if(userId != null){
                assignee = [Select Id,Name,Email from User where Id =:userId];
            } 
            Account acc = [SELECT Name FROM Account WHERE Id =:record.AccountId LIMIT 1];
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new List<String> {assignee.Email};
            message.setSenderDisplayName('Salesforce Ordering Notification');
            message.subject = 'SF Order ' + record.OrderNumber + ' has been assigned to you';
            //message.plaintextbody = 'Salesforce order ' + newOrder.OrderNumber + ' has moved from ' + oldOrder.Order_Stage__c + ' to ' + newOrder.Order_Stage__c + '.\n\n Order link: ' + URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/r/Order/'+ newOrder.Id +'/view  \n\n Thank you.';
            String orderType = orderRecordTypeName == 'Vlocity OM Order' ? orderRecordTypeName : 'Lightning';
            String serviceType = record.Product_Type__c;
            if (record.Product__c != null)
                serviceType += ', ' + record.Product__c;
            if (record.Circuit_Product__c != null)
                serviceType += ', ' + record.Circuit_Product__c.replaceAll(';', ', ');
            if (record.Add_On_Products__c != null)
                serviceType +=  ', ' + record.Add_On_Products__c.replaceAll(';', ', ');
            
            String body = 'Dear ' + assignee.Name + '\n\n';
            body += 'Salesforce order ' + record.OrderNumber + ' has been assigned to you.\n\n';
            body += 'Account Name: '+acc.Name+'\n';
            body += 'Salesforce Order Type: '+orderType+'\n';
            body+= 'Service Type: '+serviceType+'\n'; 
            body+='Order Record Type: '+orderRecordTypeName+'\n';
            if(record.Related_Order__c != null){
                Order relatedOrder = [SELECT OrderNumber FROM Order WHERE Id =:record.Related_Order__c LIMIT 1];
                body+='Related Order#: ' +relatedOrder.OrderNumber+'\n';
            }else if(record.UCF_Related_Orders__c != null){
                body+='Related Order#: ' +record.UCF_Related_Orders__c+'\n';
            }
            
            // body+= 'Related Order Number: '+relatedOrderNumber+'\n\n'; 
            body+= '\n\nLink to order: \n' + URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/r/Order/'+ record.Id +'/view \n';
            message.plaintextbody = body;
            // message.htmlbody = body;
            // message.plaintextbody = 'Dear ' + assignee.Name + '\n\nSalesforce order ' + record.OrderNumber + ' for ' + acc.Name + ' has been assigned to you.\n\nLink to order: \n' + URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/r/Order/'+ record.Id +'/view ';
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (!results[0].success) {
                System.debug('Error in sending email: ' + results[0].errors[0].message);
            } else {
                System.debug('Email with order details sent to: ' + assignee.Email);
            }
        } catch (Exception e) {
            System.debug('Exception occured. Email was not sent.');
            System.debug(e.getMessage());
        }
    }

    public void sendOrderExceptionEmail(Group g) {
        
        try {
            String[] emails = new String[]{};
            String[] userIds = new String[]{};
          //  Group g = [SELECT Id, Name, DeveloperName FROM Group where Type='Queue' and DeveloperName='CNP_Assignment_Notice'];
            for (GroupMember member : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId=:g.Id]) {
                userIds.add(member.UserOrGroupId);
            }
            for (User u : [SELECT Email FROM User WHERE Id IN :userIds]) {
                emails.add(u.Email);
            }
            Account acc = [SELECT Name FROM Account WHERE Id =:record.AccountId LIMIT 1];
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = emails;

            message.setSenderDisplayName('Salesforce Ordering Notification');
            message.subject = 'Assign an Order Provisioner for the Salesforce Order ' + record.OrderNumber;
            String orderType = orderRecordTypeName == 'Vlocity OM Order' ? orderRecordTypeName : 'Lightning';
            String serviceType = record.Product_Type__c;
            if (record.Product__c != null)
                serviceType += ', ' + record.Product__c;
            if (record.Add_On_Products__c != null)
                serviceType +=  ', ' + record.Add_On_Products__c.replaceAll(';', ', ');
            
            String body = 'An Order Provisioner needs to be assigned for the Salesforce order ' + record.OrderNumber + '\n\n';
            body += 'Account Name: '+acc.Name+'\n';
            body += 'Salesforce Order Type: '+orderType+'\n';
            body+= 'Service Type: '+serviceType+'\n'; 
            body+='Order Record Type: '+orderRecordTypeName+'\n';
            if(record.Related_Order__c != null){
                Order relatedOrder = [SELECT OrderNumber FROM Order WHERE Id =:record.Related_Order__c LIMIT 1];
                body+='Related Order#: ' +relatedOrder.OrderNumber+'\n';
            }else if(record.UCF_Related_Orders__c != null){
                body+='Related Order#: ' +record.UCF_Related_Orders__c+'\n';
            }
            body+= '\n\nLink to order: \n' + URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/r/Order/'+ record.Id +'/view \n';
            message.plaintextbody = body;
            // message.htmlbody = body;
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (!results[0].success) {
                System.debug('Error in sending email: ' + results[0].errors[0].message);
            } else {
                System.debug('Email with order details sent to: '+emails);
            }
        } catch (Exception e) {
            System.debug('Exception occured. Email was not sent.');
            System.debug(e.getMessage());
        }
    }
    
}