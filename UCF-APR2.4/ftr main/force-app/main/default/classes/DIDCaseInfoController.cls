/* SDDD-4706 - TNAC Number Assignment process 
 * Author - Swetha and Vinoth
 * version - 2.0
 * Purpose - This Class is called when Generate case button is clicked on DIDenrichment vlocity page.
   created for Case creation for TNAC Cases.
*/
public class DIDCaseInfoController {
    
    public DIDCaseInfoController() {
        
    }
    
    public String userInput{get;set;}
    public Id recordId {get; set;}
    public String didLocationId { get; set; }
    public ftr_DID_Location_Details__c didLocationDetails;
    public ftr_DID_Location_Details__c didLocationDetailsId;
    public String Case_BTN {get; set;}
    public String Case_NPA {get; set;}
    public String Case_of_numbers {get; set;}
    public String Case_Restriction {get; set;}
    public String Case_Order {get; set;}
    public String Cust_Name {get; set;}
    public String Cust_Srvloc {get; set;}
    public String Case_OrderID {get; set;}
    public String Cust_ID {get; set;}
    public String OpportunityId {get; set;} //opp
    public String Cust_SrvlocID {get; set;}
    public Id loginUserID = UserInfo.getUserId();
    public Id loginUserProfile = UserInfo.getProfileId();
    public String loginUserEmail = UserInfo.getUserEmail();
    public String strMsg{get; set;}
    public Id caseid{get;set;}
      
    // This method is for Pageload, Getting Current DID Location Details
    public void page_load(){
        recordId  = ApexPages.currentPage().getParameters().get('didLocationId');            
        ftr_DID_Location_Details__c didLocDetails = [Select ServiceAccountId__r.vlocity_cmt__PremisesId__c,ServiceAccountId__r.vlocity_cmt__PremisesId__r.Premise_Detail__c,Name,PremisesId__r.Premise_Detail__c,
                                                     BTN__c,TestNumber__c,IncomingCallerID__c,NumberOfCallPaths__c,InternationalDialingOptions__c,
                                                     ConnectLineIDScreening__c,MDN__c,NumberOfDIDs__c,OrderId__c,OrderId__r.OrderNumber,OrderId__r.Id,OrderId__r.Account_Name__c,
                                                     OrderId__r.AccountId,OrderId__r.OpportunityId,NPA__c,NXX__c from ftr_DID_Location_Details__c where Id=:recordId];  
        Case_Order = didLocDetails.OrderId__r.OrderNumber;
        Case_OrderID = didLocDetails.OrderId__r.Id;
        Cust_Name = didLocDetails.OrderId__r.Account_Name__c;
        Cust_ID = didLocDetails.OrderId__r.AccountId;
        Cust_Srvloc = didLocDetails.ServiceAccountId__r.vlocity_cmt__PremisesId__r.Premise_Detail__c;
        Cust_SrvlocID = didLocDetails.ServiceAccountId__r.vlocity_cmt__PremisesId__c;
        OpportunityId = didLocDetails.OrderId__r.OpportunityId;
    }
    
   // This method is created for Case creation for TNAC cases
    public void Save() {        
        Id recorTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(label.TNAC).getRecordTypeId(); 
                
        Group TNACQueueID = [Select Id,Name,Email from Group where type='queue' and DeveloperName = 'TNAC_Case'];
        
        case caseRecCreation = new case();
        caseRecCreation.recordTypeId = recorTypeId;
        caseRecCreation.vlocity_cmt__ServiceAccountId__c = Cust_ID;
        caseRecCreation.vlocity_cmt__PremisesId__c =Cust_SrvlocID;
        caseRecCreation.BTN__c = Case_BTN;
        caseRecCreation.NPA_NXX_Requested__c = Case_NPA;
        caseRecCreation.of_numbers_needed__c = Case_of_numbers;
        caseRecCreation.Restriction_Notes__c = Case_Restriction;
        caseRecCreation.Orderz__c = Case_OrderID;
        caseRecCreation.AccountID = Cust_ID;
        caseRecCreation.Subject = 'TN Reservation - Reserve TNs';
        caseRecCreation.Origin = 'Salesforce';
        caseRecCreation.Opportunity__c= OpportunityId;
        
        caseRecCreation.OwnerId = TNACQueueID.Id; // Adding TNAC Queue
        
        insert caseRecCreation;
        
        strMsg = 'Successfully created case';
        caseid = caseRecCreation.Id;
        
        User us = new User();
        if(caseid != null){            
            us = [select id,Name,Email from User where id =: UserInfo.getUserId()];
              
            CaseCreatesendEmail(caseRecCreation,us.Email);   
            
        }
               
        
    }
        
    //This method is created for Case Creation Notification for TNAC Case
    public static  void CaseCreatesendEmail(Case caseid, string userMail) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        Case caserec = [Select id,Casenumber,OwnerId,Owner.Name,Owner.Email,BTN__c,NPA_NXX_Requested__c,of_numbers_needed__c,Account.Name,AccountId,Restriction_Notes__c,Orderz__c,Orderz__r.name,Orderz__r.OrderNumber,vlocity_cmt__ServiceAccountId__c,vlocity_cmt__ServiceAccountId__r.name,vlocity_cmt__PremisesId__r.Premise_Detail__c from Case where id =: caseid.id];        
                
        string serviceLoc = caserec.vlocity_cmt__PremisesId__r.Premise_Detail__c;
        
        String[] toAddresses = new String[] {userMail};
        mail.setToAddresses(toAddresses);
        
        OrgWideEmailAddress[] owea = [select id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'Frontier Sales Support'];
        mail.setOrgWideEmailAddressId(owea.get(0).Id);
        
        //mail.setReplyTo('noreply@ftr.com');
        mail.setSubject('Case# '+caserec.Casenumber+' - TN Reservation - Reserve TNs');
                
        String body = '<html><body>Case created with the following details for TN Reservation.<br><br>' 
        +'<br><b> Case Number : </b> ' +caserec.Casenumber+ 
        '<br><b> BTN : </b> '+caserec.BTN__c  + 
        '<br><b> NPA/NXX : </b> ' +caserec.NPA_NXX_Requested__c+ 
        '<br><b> # of numbers needed : </b> ' +caserec.of_numbers_needed__c+ 
        '<br><b> Restriction Notes : </b> ' +caserec.Restriction_Notes__c+ 
        '<br><b> Salesforce order for SIP orders : </b> ' +caserec.Orderz__r.OrderNumber+ 
        '<br><b> Customer Name : </b> ' +caserec.vlocity_cmt__ServiceAccountId__r.Name+ 
        '<br> <b>Service Location : </b> ' +caserec.vlocity_cmt__PremisesId__r.Premise_Detail__c+ '<br><br>' +
        
        '</body></html>';        
                
        mail.setHtmlBody(body);   // mail.setHtmlBody(et.body); 
        mails.add(mail);    
        try{
            Messaging.sendEmail(mails);
        }
        catch(Exception e){
            system.debug('-------------exception------'+e.getMessage());
        }
    }
    
    
    // This method is used for Case Close Notification for TNAC Case, calling in Flow
    @InvocableMethod(label='Send Case Close Email')     
    public static  void CaseClosesendEmail(list<string> caselst ) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //user us = [select id,Name,Email from User where id =: UserInfo.getUserId()];
        Case caserec = [Select id,Casenumber,OwnerId,Owner.Name,Owner.Email,createdbyid ,Orderz__r.id,BTN__c,Number_Details__c,NPA_NXX_Requested__c,of_numbers_needed__c,Account.Name,AccountId,Restriction_Notes__c,Orderz__c,Orderz__r.name,Orderz__r.OrderNumber,vlocity_cmt__ServiceAccountId__c,vlocity_cmt__ServiceAccountId__r.name,vlocity_cmt__PremisesId__r.Premise_Detail__c from Case where id =: caselst];        
        user us = [select id,Name,Email from User where id =: caserec.createdbyid ];
                
        string serviceLoc = caserec.vlocity_cmt__PremisesId__r.Premise_Detail__c;
        OrgWideEmailAddress[] owea = [select id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'Frontier Sales Support'];
        mail.setOrgWideEmailAddressId(owea.get(0).Id);
        
        //mail.setReplyTo('noreply@ftr.com');
        String ServLoct= String.valueOf(caserec.vlocity_cmt__PremisesId__r.Premise_Detail__c);

        String[] toAddresses = new String[] {us.Email};
        mail.setToAddresses(toAddresses);
        
        mail.setSubject('Case# '+caserec.Casenumber+' - TN Reservation - Reserve TNs - Case Completed');
                
        String body = '<html><body>Case closed with the following details.<br><br>' 
        +'<br> <b>Case Number :</b>  ' +caserec.Casenumber+ 
        '<br> <b>BTN :</b>  '+caserec.BTN__c  + 
        '<br> <b>NPA/NXX :</b>  ' +caserec.NPA_NXX_Requested__c+ 
        '<br> <b># of numbers needed :</b>  ' +caserec.of_numbers_needed__c+ 
        '<br> <b>Restriction Notes :</b>  ' +caserec.Restriction_Notes__c+
        '<br> <b>Salesforce order for SIP orders :</b>' + '<a href='+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ caserec.Orderz__r.id+' >'+caserec.Orderz__r.OrderNumber + '</a>'+         
        '<br> <b>Customer Name :</b>  ' +caserec.vlocity_cmt__ServiceAccountId__r.Name+ 
        '<br> <b>Service Location :</b>  ' +caserec.vlocity_cmt__PremisesId__r.Premise_Detail__c+ 
        '<br> <b>Reserved Number Details :</b>  ' +caserec.Number_Details__c+ '<br><br>' +
               
        '</body></html>';        
                
        mail.setHtmlBody(body);   
        mails.add(mail);    
        try{
            Messaging.sendEmail(mails);
        }
        catch(Exception e){
            system.debug('-------------exception------'+e.getMessage());
        }
    }
    
        
}