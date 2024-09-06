/* Author - Anil A
   SDDD-4526 (01103949)- NCM Order Assignment Automation process.
   This class is used for NCM order automation i.e, owner assigment,outofoffice, backup assignment and roundrobin logic
*/
public class NCMAutomationOrderHandler{ 

    public static String orderRecordTypeName ;    
    /* This method  is used for Ownerassignment logic */
    public static void ownerAssignmentForNCM(Order newOrder, Order oldOrder){
    
        orderRecordTypeName = Schema.SObjectType.Order.getRecordTypeInfosById().get(newOrder.recordtypeId).getname();
        Map<String, List<FieldAssignment__c>> assignmentsByWorkGroupMap = new Map<String, List<FieldAssignment__c>>();
        List<FieldAssignment__c> lstFieldAssignmentUsers = new List<FieldAssignment__c>();        
        
        Map<Id,Id> customerUserIdMap = new Map<Id,Id>();
        Map<Id,FieldAssignment__c> customerUserFaMap = new Map<Id,FieldAssignment__c>(); // Added
        String  assigneeid =null;
        
        String  backupassigneeid =null;
        Boolean outofoff =false;                
        
        if( newOrder.Order_Provisioner__c!= null ){          
            newOrder.ownerId = newOrder.Order_Provisioner__c;
        } 
        else if( string.valueOf(newOrder.ownerId).startsWith('005')  && newOrder.Order_Provisioner__c == null ) {   
            newOrder.Order_Provisioner__c = newOrder.ownerId;
        } else { 
            for(FieldAssignment__c fa : [SELECT Id,Out_Of_Office_Start_Date__c,Out_Of_Office_End_Date__c ,recordtype.Name,OutOfOffice__c,Backup_Assignment__c,UserId__c, AccountId__c, Primary__c, 
                                            WorkGroupId__r.Name, ProcessedRecord__c, WorkGroupId__r.SupportedProducts__c, 
                                            WorkGroupId__r.ProductsForCheckingExistingRecords__c 
                                            FROM FieldAssignment__c  WHERE WorkGroupId__r.Field__c =:System.Label.Network_Cost_Management and Recordtype.name=:System.Label.NCM ]){
                if(!fa.Primary__c){
                    if (assignmentsByWorkGroupMap.containsKey(fa.WorkGroupId__r.Name)) {
                        assignmentsByWorkGroupMap.get(fa.WorkGroupId__r.Name).add(fa);
                    } else {
                        assignmentsByWorkGroupMap.put(fa.WorkGroupId__r.Name, new List<FieldAssignment__c>{ fa });
                    }
                }
                else {
                        if(fa.UserId__c !=null){                                                
                            customerUserIdMap.put(fa.AccountId__c,fa.UserId__c);
                            customerUserFaMap.put(fa.AccountId__c,fa);
                        }                    
                }                
            }
        
        } 
        //if(customerUserIdMap.containsKey(newOrder.AccountId)){
        if(customerUserFaMap.containsKey(newOrder.AccountId)){
            //assigneeid = customerUserIdMap.get(newOrder.AccountId);
            assigneeid = customerUserFaMap.get(newOrder.AccountId).UserId__c;
            backupassigneeid = customerUserFaMap.get(newOrder.AccountId).Backup_Assignment__c ;
            outofoff = customerUserFaMap.get(newOrder.AccountId).OutOfOffice__c;
            
            if(outofoff){                
                newOrder.ownerId = backupassigneeid ;
                newOrder.Order_Provisioner__c = backupassigneeid ;   
            } else{
                newOrder.ownerId = assigneeid ;
                newOrder.Order_Provisioner__c = assigneeid ;
            }
        } 
        else {
            System.debug('newOrder.ownerId12==='+newOrder.ownerId); 
                //if(orderRecordTypeName == 'Contract Renewal'){
                if(orderRecordTypeName == System.Label.Contract_Renewal){
                    if(assignmentsByWorkGroupMap.containsKey(System.Label.Contract_Renewal_Customer)){
                        //lstFieldAssignmentUsers = assignmentsByWorkGroupMap.get('Contract Renewal Customer');
                        lstFieldAssignmentUsers = assignmentsByWorkGroupMap.get(System.Label.Contract_Renewal_Customer);
                    }
                }
                else if(orderRecordTypeName == System.Label.Disconnect_Order){
                //else if(orderRecordTypeName == 'Disconnect Order'){
                    if(assignmentsByWorkGroupMap.containsKey(System.Label.Disconnect_Customer)){
                        //lstFieldAssignmentUsers = assignmentsByWorkGroupMap.get('Disconnect Customer');
                        lstFieldAssignmentUsers = assignmentsByWorkGroupMap.get(System.Label.Disconnect_Customer);
                    }
                }
                else if(orderRecordTypeName == System.Label.New_Order){
                //else if(orderRecordTypeName == 'New Order'){
                    if(assignmentsByWorkGroupMap.containsKey(System.Label.New_Order_Customer)){
                        //lstFieldAssignmentUsers = assignmentsByWorkGroupMap.get('New Order Customer');
                        lstFieldAssignmentUsers = assignmentsByWorkGroupMap.get(System.Label.New_Order_Customer);
                    }
                }
                else{
                    if(assignmentsByWorkGroupMap.containsKey(System.Label.NCM_Other_Customer)){    
                    //if(assignmentsByWorkGroupMap.containsKey('NCM Other Customer')){
                        //lstFieldAssignmentUsers = assignmentsByWorkGroupMap.get(System.Label.NCM Other Customer');
                        lstFieldAssignmentUsers = assignmentsByWorkGroupMap.get(System.Label.NCM_Other_Customer);
                    }
                    
                }                
                
              if(lstFieldAssignmentUsers.size()>0){               
                   assigneeid = getNCMUserByRoundRobin(lstFieldAssignmentUsers);
                   if(assigneeid !=null){
                            newOrder.ownerId = assigneeid ;
                            newOrder.Order_Provisioner__c = assigneeid ;
                    }
                }         
        }
        User us = new User();
        if(newOrder.ownerId != null && string.valueOf(newOrder.ownerId).startsWith('005') ){
            us = [select id,Name,Email from User where id =: newOrder.ownerId];
            sendEmail(newOrder,us.Email);
        }
        // sendEmail(newOrder,us.Email); 
        System.debug('====newOrder.owner==='+newOrder.ownerId+'====newOrder.owner.Email==='+newOrder.owner.Email+'====newOrder====='+newOrder);                     
    
    }
    /* This method  is used for Roundrobin logic */
     public static string getNCMUserByRoundRobin(List<FieldAssignment__c> fieldAssignments) {    
        //Id NCMRecordtypeId = Schema.SObjectType.FieldAssignment__c.getRecordTypeInfosByName().get('NCM').getRecordTypeId();
        FieldAssignment__c fieldAssignment ; 
        List<FieldAssignment__c> records = new List<FieldAssignment__c>();
        
        for (FieldAssignment__c fa : fieldAssignments) {
            if (!fa.ProcessedRecord__c) {
                fieldAssignment = fa;
                break;
            }
        }         
        if (fieldAssignment != null) {
            // if we find an assignment, flag it as processed
            fieldAssignment.ProcessedRecord__c=true;
            Database.update(fieldAssignment); 
        } else {
            // if we dont find an assignment, grab the first person and reset the flags
            fieldAssignment = fieldAssignments[0];
            fieldAssignments.remove(0);
            for (FieldAssignment__c fa : fieldAssignments) {
                fa.ProcessedRecord__c = false;
            }  
            records.addAll(fieldAssignments);
            Database.update(records);            
        }
        
        string userId ;        
        if(fieldAssignment.OutOfOffice__c && isOutOfOffice(fieldAssignment.UserId__c) && fieldAssignment.Backup_Assignment__c !=null){          
               userId = fieldAssignment.Backup_Assignment__c;        
        }
        else{
            userId = fieldAssignment.UserId__c ;
        }        
        return userId ;
       
    }
    /* This method  is used for OutofOffice logic */
    public static Boolean isOutOfOffice(String OutOfficeUserid){    
        //Date assignmentDate = Date.today(); 
        Datetime assignmentDate = DateTime.now();
        system.debug('System DateTime is ' + DateTime.now()+'======='+ DateTime.now().format() + '===System.now ======'+ System.now() + '===========' +System.now().format());
        Boolean assigndate;
        try{        
            OutOfOffice userOutOffice =[select id,startDate,EndDate from OutOfOffice where userId =:OutOfficeUserid limit 1];
            assigndate = assignmentDate >= userOutOffice.startDate-1 && assignmentDate <=userOutOffice.EndDate;
            return assigndate;
            
        }
        catch(Exception Ex){    return false;    }           
    }
    
    // To Send Email to Order Owner.
    public static  void sendEmail(order ords, string userMail) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        Order ord = [Select id,OrderNumber,OwnerId,Owner.Name,Owner.Email from Order where id =: ords.id];        
        //String[] toAddresses = new String[]{'vinoth.ethiraj@ftr.com'};
        String[] toAddresses = new String[] {userMail};
        //toAddresses.add(ord.Owner.Email);
        mail.setToAddresses(toAddresses);
        
        mail.setSubject('Order transferred to you');    
        String body = '<html><body>Order ' + ord.OrderNumber  + ' has been assigned to you. Please click on the link below to view the record. <br><br>'+ URL.getSalesforceBaseUrl().toExternalForm()+ '/'+ord.id+'</body></html>';
        mail.setHtmlBody(body);   // mail.setHtmlBody(et.body); 
        mails.add(mail);    
        try{
            Messaging.sendEmail(mails);
        }
        catch(Exception e){
            system.debug('-------------exception------'+e.getMessage());
        }
    }
                  
}