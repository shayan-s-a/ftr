public class TaskSendEmailAction {
    
    @InvocableMethod(label='Send DPI Order Email' category='Vlocity CLM')
    public static List<EmailReturnData> sendEmailExpectedUser(List<EmailSendData> emailData){
        
        List<EmailReturnData> results = new List<EmailReturnData>();
        EmailReturnData emailReturn = new EmailReturnData();
        
        //get task recordType Ids for D1 and DC	
        Id dC711RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('DC_711_Order').getRecordTypeId();
        Id dI711RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('D1_711_Order').getRecordTypeId();
        
        //get task Id
        Task t = [Select Id,Priority,WhatId,Owner.Name,Description,Status,Subject,RecordTypeId from Task where Id =:emailData[0].taskId];
        String serviceLocationName = emailData[0].serviceLocationName;
        System.debug('serviceLocationName ::'+serviceLocationName);
        
        //When Task is DI 711 
        if(t.RecordTypeId == dI711RecordTypeId && t.WhatId !=null)
        {
            Order o =[Select Id ,OrderNumber,Customer_Requested_Date__c,Account_Name__c,Sales_Order_Point_of_Contact__c,Network_Project_Specialist__r.Name from Order where Id=:t.WhatId];
            List<Location_Contact__c> locContact = [Select Id,Contact_Email__c,Contact_Phone__c,Name from Location_Contact__c where Order__c=:t.WhatId];
            List<ftr_DID_Location_Details__c> didLocations = [Select Id ,Email_List__c,ServiceAccountId__r.Name from ftr_DID_Location_Details__c where OrderId__c =:t.WhatId];
            List<OrderItem> orderItemUCF = [Select Id,SNE_Code_MRC__c,vlocity_cmt__ServiceAccountId__r.Name,
                                            vlocity_cmt__ServiceAccountId__r.BTN__c, SNE_Code_OTC__c, 
                                            Quantity, vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c,
                                            vlocity_cmt__Product2Id__r.Name 
                                            from OrderItem where OrderId=:t.WhatId 
                                            AND vlocity_cmt__ServiceAccountId__r.Name =:serviceLocationName
                                            AND vlocity_cmt__Product2Id__r.Name !='UCF DID DPI Services'
                                            AND vlocity_cmt__Product2Id__r.Name !='UCF DC 711'];
            List<Messaging.SingleEmailMessage> allMail = new List<Messaging.SingleEmailMessage>();
            List<OrgWideEmailAddress> Org = [SELECT id FROM OrgWideEmailAddress WHERE DisplayName = 'Frontier Communication' limit 1];
            system.debug(' :: Org '+Org);  
            
            //Due Date Work
            Date originalDate = Date.today();
            Datetime dt = (DateTime)originalDate;
            Date newDate;
            String BTN='';
            String ProductName;
            String dayOfWeek = dt.format('EEEE');
            if(dayOfWeek == 'Friday'){
                newDate = originalDate.addDays(3);
            }else{
                
                newDate = originalDate.addDays(2);
                
            }
            
            String dueDate = String.ValueOf(newDate);
            List<ftr_DID_Location_Details__c> addEmails = new List<ftr_DID_Location_Details__c>();
            List<String> emailList = emailData[0].EmailTo.split(',');
            
            for (ftr_DID_Location_Details__c emails : didLocations) {
                if (serviceLocationName == emails.ServiceAccountId__r.Name) {
                    // Join the emailList into a single comma-separated string
                    emails.Email_List__c = String.join(emailList, ',');
                    addEmails.add(emails);
                }
            }
            
            if (!addEmails.isEmpty()) {
                update addEmails;
            }
            System.Debug('addEmails:'+ addEmails);
            
            String orderItemTable = '<table border="1px"><tr><th style="text-align: left;">Product Name</th><th>Quantity</th><th>Recurring Charge</th><th>OneTime Charge</th></tr>';
            for(OrderItem ord:orderItemUCF){
                
                if(ord.vlocity_cmt__ServiceAccountId__r.BTN__c !=null && ord.vlocity_cmt__ServiceAccountId__r.BTN__c !='') {
                    BTN = ord.vlocity_cmt__ServiceAccountId__r.BTN__c;
                }
                orderItemTable += '<tr><td>' + ord.vlocity_cmt__Product2Id__r.Name + '</td><td>'+ord.Quantity+'</td><td>'+ord.vlocity_cmt__RecurringCharge__c+'</td><td>'+ord.vlocity_cmt__OneTimeCharge__c+'</td></tr>';
                
            }
            orderItemTable += '</table>';
            // Location Contact Work
            
            String locationContactTable = '<table border="1px"><tr><th>Name</th><th>Email</th><th>Phone</th></tr>';
            for(Location_Contact__c conLoc: locContact){
                locationContactTable += '<tr><td>' + conLoc.Name + '</td><td>'+conLoc.Contact_Email__c+'</td><td>'+conLoc.Contact_Phone__c+'</td></tr>';
                
            }
            locationContactTable += '</table>';
            //Email Template Work
            EmailTemplate emailTemp = [Select Id,HtmlValue,Subject From EmailTemplate Where Name = 'DI 711 Order Detail' Limit 1];
            system.debug(' :: emailTemp '+emailTemp); 
            String Subject = 'Site Survey -'+'UCF '+o.OrderNumber+' - '+serviceLocationName;
            string defaultEmailContent = '';
            defaultEmailContent = emailTemp.HtmlValue;
            defaultEmailContent = defaultEmailContent.replace('{!PMName}', o.Network_Project_Specialist__r != null ? o.Network_Project_Specialist__r.Name : '');
            defaultEmailContent = defaultEmailContent.replace('{!OrderNumber}', o.OrderNumber != null ? o.OrderNumber : '');
            defaultEmailContent = defaultEmailContent.replace('{!BillingTelephoneNumber}', BTN != null ? BTN : '');
            defaultEmailContent = defaultEmailContent.replace('{!Duedate}', dueDate != null ? dueDate : '');
            defaultEmailContent = defaultEmailContent.replace('{!ServiceAddress}', serviceLocationName != null ? serviceLocationName : '');
            defaultEmailContent = defaultEmailContent.replace('{!LocationContact}', locationContactTable != null ? locationContactTable : '');
            defaultEmailContent = defaultEmailContent.replace('{!OrderItem}', orderItemTable != null ? orderItemTable : '');
            
            //List<String> emailList = emailData[0].EmailTo.split(',');
            for (Integer i = 0; i < emailList.size(); i++) {
                emailList[i] = emailList[i].trim();
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // List<string> sendTo = new List<string>();
            //sendTo.add(emailList);
            mail.setToAddresses(emailList);
            // system.debug(' :: sendTo' + sendTo);
            mail.setOrgWideEmailAddressId(Org[0].Id);
            mail.setHtmlBody(defaultEmailContent);
            mail.setSubject(Subject);
            mail.setWhatId(t.WhatId);
            mail.saveAsActivity = true;
            //mail.setEntityAttachments(emailData[0].fileIds);
            allMail.add(mail);     
            
            if(!allMail.isEmpty()) 
            {
                system.debug(' :: allMail' + allMail);
                t.Status ='Completed';
                update t;
                Messaging.sendEmail(allMail,false); 
            }	
            
        }
        
        else if(t.RecordTypeId == dC711RecordTypeId && t.WhatId !=null)//When Task is DC 711 
        {
            
            Order o =[Select Id ,BillingCity,vlocity_cmt__OneTimeTotal__c,Managers_Name__c,BillingState, 
                      OrderNumber,Customer_Requested_Date__c,Account_Name__c,Sales_Order_Point_of_Contact__c,
                      CreatedDate, Account.BTN__c,ftrImplementationSpecialistName__c, Hot_Cut__r.Name 
                      from Order where Id=:t.WhatId];
            List<ftr_DID_Location_Details__c> didLocations = [Select Id ,ServiceAccountId__r.Name,Service_Account_Name__c,DueDate__c,Email_List__c, Location_Due_Date__c from ftr_DID_Location_Details__c where OrderId__c =:t.WhatId];
            List<System_Order_Info__c> wtnNumber = [select Id, Service_Address__r.Name, WTN__c from System_Order_Info__c where Order__c=:t.WhatId];
            List<OrderItem> orderItemUCF = [Select Id,Product_Name__c,vlocity_cmt__ServiceAccountId__r.Name,vlocity_cmt__ServiceAccountId__r.BTN__c, 
                                            SNE_Code_OTC__c, Quantity, vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c 
                                            from OrderItem where OrderId=:t.WhatId AND vlocity_cmt__ServiceAccountId__r.Name =:serviceLocationName
                                            AND ( Product_Type__c = 'Phones' OR Product_Type__c = 'Accessories' OR Product_Type__c = 'Installation')];
            List<Account> serviceAccount = [Select Id, Name, ShippingCity, ShippingState from Account];
            List<Service_Order__c> serviceOrders = [select Id,Name,Order__c,RecordType.Name  from Service_Order__c  where Order__c =:t.WhatId];
            List<Messaging.SingleEmailMessage> allMail = new List<Messaging.SingleEmailMessage>();
            List<OrgWideEmailAddress> Org = [SELECT id FROM OrgWideEmailAddress WHERE DisplayName = 'Frontier Communication' limit 1];
            system.debug(' :: Org '+Org);
            //List<OrderItem> installationChargesOI =[SELECT vlocity_cmt__OneTimeCharge__c FROM OrderItem WHERE OrderId = :t.WhatId AND SNE_Code_OTC__c = 'AWLBR' AND vlocity_cmt__ServiceAccountId__r.Name =:serviceLocationName Limit 1];
            //oneTimeTotal
            //String oneTimeTotal = String.valueOf(installationChargesOI.vlocity_cmt__OneTimeCharge__c);
            // Initialize a default value
            //String oneTimeTotal = '0';
            
            // Check if any records were retrieved
            //if (!installationChargesOI.isEmpty()) {
                //OrderItem firstRecord = installationChargesOI[0];
                // Check if vlocity_cmt__OneTimeCharge__c is not null before converting to String
                //if (firstRecord.vlocity_cmt__OneTimeCharge__c != null) {
                    //oneTimeTotal = String.valueOf(firstRecord.vlocity_cmt__OneTimeCharge__c);
                //}
            //}
            List<OrderItem> installationChargesOI = [SELECT Quantity, vlocity_cmt__OneTimeCharge__c FROM OrderItem WHERE OrderId = :t.WhatId AND SNE_Code_OTC__c = 'AWLBR' AND vlocity_cmt__ServiceAccountId__r.Name = :serviceLocationName LIMIT 1];
            
            // Initialize a default value
            Decimal oneTimeTotal = 0;
            
            // Check if any records were retrieved
            if (!installationChargesOI.isEmpty()) {
                OrderItem firstRecord = installationChargesOI[0];
                
                // Check if vlocity_cmt__OneTimeCharge__c is not null before performing multiplication
                if (firstRecord.vlocity_cmt__OneTimeCharge__c != null) {
                    // Multiply the one-time charge with the quantity
                    oneTimeTotal = firstRecord.vlocity_cmt__OneTimeCharge__c * firstRecord.Quantity;
                }
            }
            
            // Set scale to 2 decimal places
            oneTimeTotal = oneTimeTotal.setScale(2, System.RoundingMode.HALF_UP);
            
            // Convert the result to String
            String oneTimeTotalAsString = String.valueOf(oneTimeTotal);
            
            Date dueDate = null;
            String emailAddresses = '';
            
            for (ftr_DID_Location_Details__c did : didLocations) {
                system.debug('serviceLocationName ::' + serviceLocationName);
                if (serviceLocationName == did.Service_Account_Name__c) {
                    system.debug('did ::'+ did);
                    dueDate = did.DueDate__c;
                    emailAddresses = did.Email_List__c;
                    
                } 
            }
            
            //WTN number
            String wtnNum = '';
            for(System_Order_Info__c wtnn:wtnNumber){
                if(serviceLocationName == wtnn.Service_Address__r.Name){
                    wtnNum = wtnn.WTN__c;
                }
                //else{
                    //wtnNum = '';
                //}
            }
            
            //serviceLocationCityState
            String serviceLocationCityState = '';
            for(Account serAcc:serviceAccount){
                if(serviceLocationName == serAcc.Name){
                    serviceLocationCityState = serAcc.ShippingCity + ', ' + serAcc.ShippingState;
                    system.debug('serviceLocationName ::' + serviceLocationName);
                }
                //else{
                    //serviceLocationCityState = '';
                //}
            }
            
            //Service Order Number
            String dpiServiceOrder = '';
            String infiniumServiceOrder = '';
            List<String> infiniumReqOrderNumbers = new List<String>();
            for(Service_Order__c sOrder:serviceOrders){
                if(sOrder.RecordType.Name == 'DPI Service Order'){
                    dpiServiceOrder = sOrder.Name;
                }
                else if(sOrder.RecordType.Name == 'Infinium REQ'){
                    infiniumServiceOrder = sOrder.Name;
                    infiniumReqOrderNumbers.add(infiniumServiceOrder);
                }
                else{
                    dpiServiceOrder = '';
                    infiniumServiceOrder = '';
                }
            }
            // Convert the list of Infinium REQ order numbers to a comma-separated string
            String infiniumReqNumbersString = String.join(infiniumReqOrderNumbers, ',');
            
            String BTN='';
            String hotCutUser = (o.Hot_Cut__r != null) ? o.Hot_Cut__r.Name : '';
            String implementationSpecialistUser = (o.ftrImplementationSpecialistName__c != null) ? o.ftrImplementationSpecialistName__c : '';
            
            
            // Convert the Date to a String using the format() method
            String formattedDueDate = (dueDate != null) ? String.valueOf(dueDate.month()) + '/' + String.valueOf(dueDate.day()) + '/' + String.valueOf(dueDate.year()) : '';
            // Phones and Assesories Work
            String orderItemTable = '<table border="1px"><tr><th style="text-align: left;">Product Name</th><th>Quantity</th><th>Recurring Charge</th><th>OneTime Charge</th></tr>';
            for(OrderItem ord:orderItemUCF){
                
                if(ord.vlocity_cmt__ServiceAccountId__r.BTN__c !=null && ord.vlocity_cmt__ServiceAccountId__r.BTN__c !='') {
                    BTN = ord.vlocity_cmt__ServiceAccountId__r.BTN__c;
                }
                orderItemTable += '<tr><td>' + ord.Product_Name__c + '</td><td>'+ord.Quantity+'</td><td>'+ord.vlocity_cmt__RecurringCharge__c+'</td><td>'+ord.vlocity_cmt__OneTimeCharge__c+'</td></tr>';
                
            }
            orderItemTable += '</table>';
            
            //Email Template Work
            EmailTemplate emailTemp = [Select Id,HtmlValue,Subject From EmailTemplate Where Name = 'DC 711 Order Detail' Limit 1];
            
            String Subject =  'WIP UCF - '+o.Account_Name__c+' - '+o.OrderNumber;
            string defaultEmailContent = '';
            defaultEmailContent = emailTemp.HtmlValue;
            defaultEmailContent = defaultEmailContent.replace('{!ImplementationSpecialist}', o.ftrImplementationSpecialistName__c != null ? o.ftrImplementationSpecialistName__c : '');
            defaultEmailContent = defaultEmailContent.replace('{!HotCut}', hotCutUser != null ? hotCutUser : '');
            defaultEmailContent = defaultEmailContent.replace('{!DPINumber}', wtnNum != null ? wtnNum : '');
            defaultEmailContent = defaultEmailContent.replace('{!BTNNumber}', BTN != null ? BTN : '');
            defaultEmailContent = defaultEmailContent.replace('{!OrderAccount}', o.Account_Name__c != null ? o.Account_Name__c : '');
            defaultEmailContent = defaultEmailContent.replace('{!OrderNumber}', o.OrderNumber != null ? o.OrderNumber : '');
            defaultEmailContent = defaultEmailContent.replace('{!OneTimeTotal}', oneTimeTotalAsString != null ? oneTimeTotalAsString : '');
            defaultEmailContent = defaultEmailContent.replace('{!Duedate}', formattedDueDate != null ? formattedDueDate : '');
            defaultEmailContent = defaultEmailContent.replace('{!ServiceAdderess}', serviceLocationCityState != null ? serviceLocationCityState : '');
            defaultEmailContent = defaultEmailContent.replace('{Order.Sales_Order_Point_of_Contact__c}', o.Sales_Order_Point_of_Contact__c != null ? o.Sales_Order_Point_of_Contact__c : '');
            defaultEmailContent = defaultEmailContent.replace('{!OrderCreatedDate}', o.CreatedDate != null ? o.CreatedDate.formatGMT('MM/dd/YYYY') : '');
            defaultEmailContent = defaultEmailContent.replace('{!OrderItem}', orderItemTable != null ? orderItemTable : '');
            defaultEmailContent = defaultEmailContent.replace('{!EmailList}', emailAddresses != null ? emailAddresses : '');
            defaultEmailContent = defaultEmailContent.replace('{!ManagerName}', o.Managers_Name__c != null ? o.Managers_Name__c : '');
            defaultEmailContent = defaultEmailContent.replace('{!DPIOrderNumber}', dpiServiceOrder != null ? dpiServiceOrder : '');
            defaultEmailContent = defaultEmailContent.replace('{!InfiniumOrderNumber}', infiniumReqNumbersString != null ? infiniumReqNumbersString : '');
            System.Debug('emailData' + emailData);
            System.Debug('defaultEmailContent' + defaultEmailContent);
            List<String> emailList = emailData[0].EmailTo.split(',');
            for (Integer i = 0; i < emailList.size(); i++) {
                emailList[i] = emailList[i].trim();
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(emailList);
            mail.setOrgWideEmailAddressId(Org[0].Id);
            mail.setHtmlBody(defaultEmailContent);
            mail.setSubject(Subject);
            mail.setWhatId(t.WhatId);
            mail.saveAsActivity = true;
            mail.setEntityAttachments(emailData[0].fileIds);
            allMail.add(mail);     
            
            if(!allMail.isEmpty()) 
            {
                system.debug(' :: allMail' + allMail);
                t.Status ='Completed';
                update t;
                //Messaging.sendEmail(allMail,false); 
            }
            try {
                Messaging.sendEmail(allMail, false);
            } catch (Exception e) {
                System.debug('Error sending email: ' + e.getMessage());
            }
            
            
        }
        
        emailReturn.success = true;
        results.add(emailReturn);
        return results;
    }
    
    
    @AuraEnabled
    public static List<Id> storeContentVersions(Id orderId, String b64) {
        
        // Check if PMEnrichment file already exists for the orderId
        if (!pmEnrichmentFileExists(orderId)) {
            // Check if Order's stage is 'Hot Cut'
            if (orderStageIsInProgress(orderId)) {
                System.debug('orderId: ' + orderId);
                ContentVersion cv = new ContentVersion();
                cv.title = 'PMEnrichment';
                cv.PathOnClient = 'PMEnrichment.xlsx';
                Blob content = EncodingUtil.base64Decode(b64);
                cv.VersionData = content;
                cv.ContentLocation = 'S';
                insert cv;
                
                Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = orderId;
                cdl.ContentDocumentId = conDocId;
                cdl.ShareType = 'I';
                insert cdl;
                
                List<Id> contentVersionIds = new List<Id>();
                contentVersionIds.add(cv.Id);
                return contentVersionIds;
            } else {
                // Order's stage is not 'Hot Cut', handle accordingly (e.g., log, throw exception, etc.)
                System.debug('Order stage is not Hot Cut for orderId: ' + orderId);
                // You might want to handle this case based on your specific requirements
                return new List<Id>();
            }
        } else {
            // PMEnrichment file already exists, handle accordingly (e.g., log, throw exception, etc.)
            System.debug('PMEnrichment file already exists for orderId: ' + orderId);
            // You might want to handle this case based on your specific requirements
            return new List<Id>();
        }
    }

    
    // Helper method to check if PMEnrichment file already exists for the given orderId
    private static Boolean pmEnrichmentFileExists(Id orderId) {
        Integer existingFiles = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :orderId AND ContentDocument.LatestPublishedVersion.Title = 'PMEnrichment'];
        return existingFiles > 0;
    }
    
    // Helper method to check if Order's stage is 'Hot Cut'
    private static Boolean orderStageIsInProgress(Id orderId) {
        Order orderRecord = [SELECT Order_Stage__c FROM Order WHERE Id =:orderId LIMIT 1];
        return orderRecord.Order_Stage__c == 'In Progress';
    }



    
    public class EmailSendData{
        
        @InvocableVariable(required=true)
        public string EmailTo;
        
        @InvocableVariable(required=true)
        public string taskId;
        
        @InvocableVariable(required=true)
        public string serviceLocationName;
        
        @InvocableVariable(label='File Ids *ContentVersionId, AttchmentId or DocumentId')
        public String[] fileIds;
    }
    
    public class EmailReturnData{
        
        @InvocableVariable(required=true)
        public Boolean success;
        
        
    }
    
}