/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 3 
 * 
**/
@IsTest
public class ftr_CLMContractSearchControllerTest{

    @IsTest
    public static void testGetContractRecordTypeNames(){
        ftr_CLMCustomContractSearchController.getContractRecordTypeNames();
        ftr_CLMCustomContractSearchController.getAgreementTypeFieldValue('Contract', 'Status');
        
        User userObj = [Select Id from User where profile.Name = 'Frontier System Administrator' AND IsActive=true LIMIT 1];
        System.runAs(userObj){
            Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        	Account globalAcc1 = new Account();
        	globalAcc1.Name = 'GLOBAL ACCOUNT';
            globalAcc1.Customer_Number__c='231234';
        	globalAcc1.RecordTypeId = globalRecId;
            globalAcc1.ConvertedFromLead__c =false;
        	//globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        	insert globalAcc1;
        	Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
            Account objAccount = new Account(name = 'TestAccount', Primary_ACNA__c='Test', Secondary_ACNA__c='Test');
            objAccount.RecordTypeId = MasterRTId;
			objAccount.ParentId = globalAcc1.Id;
            objAccount.Customer_Number__c='311234';
            objAccount.ConvertedFromLead__c =false;
            insert objAccount;
            
            opportunity objopportunity= new opportunity(AccountId=objAccount.Id);
            objopportunity.Name ='testing opp';
            objopportunity.StageName='verbal commit'; 
            objopportunity.CloseDate= date.today();
            objopportunity.Expected_Billed_Date__c = date.today();
            insert objopportunity;
            
            Contract ctr = new Contract(Status = 'Draft', AccountId = objAccount.id, Opportunity__c = objopportunity.Id, ICB_Flag__c = 'Y', Icb_for_email_for_test__c = true);
            ctr.MDU_ContractType__c = 'Renewal';
            ctr.Type_of_Entity__c = 'Corporation';
            ctr.Agreement_Type__c = 'Ethernet/Data Services';
            ctr.Status = 'Draft';
            ctr.Document_Status__c = 'Document Generated';
            ctr.Channel_Affiliation__c = 'ISP';
            ctr.Affiliation_Approver_Name__c = 'Test';
            
            ctr.BillingCity = 'Tampa';
            ctr.BillingCountry = 'United States';
            ctr.BillingState = 'Florida';
            ctr.BillingStreet = '4900 West Kennedy Boulevard';
            ctr.BillingPostalCode = '75068';
            
            ctr.ShippingCity = 'Tampa';
            ctr.ShippingCountry = 'United States';
            ctr.ShippingState = 'Florida';
            ctr.ShippingStreet = '321 East Commerce Street';
            ctr.ShippingPostalCode = '75068';
            insert  ctr; 
            
            String selectedStrtName = 'Prairie Rose'; 
            String selectedZipCode = '51008';
            String selectedStrtNumber = '335';
            String selectedCity = 'Brunsville';
            String stateListDef = 'IA';
            String state = 'Iowa';
            String selectedStrtSubtitle = 'Ln'; 
            String selectedStrtSubDescription = '';
            String selectedTelNum = '3043258181';
            String selectCriteriaDef = 'Address';
            Lead leadObj = new Lead();
            leadObj.LastName = 'test';
            leadObj.Company = 'test';
            leadObj.City__c = selectedCity;
            leadObj.State__c = stateListDef;
             leadObj.State=state;
            leadObj.street = selectedStrtName;
            leadObj.City=selectedCity;
            leadObj.PostalCode=selectedZipCode;
            leadObj.Street_Name__c = selectedStrtName;
            leadObj.street_Number__c = selectedStrtNumber;
            leadObj.Zip_Code__c = selectedZipCode;
            leadObj.Street_Subtitle__c = selectedStrtSubtitle;
            leadObj.Street_Subtitle_Ln_Ave_etc__c = selectedStrtSubDescription;
            insert leadObj;
            
            Lead leadObj1 = new Lead();
            leadObj1.LastName = 'test';
            leadObj1.Company = 'test';
            leadObj1.City__c = selectedCity;
           leadObj1.State__c = stateListDef;
            leadObj1.State=state;
            leadObj1.street = selectedStrtName;
            leadObj1.City=selectedCity;
            leadObj1.PostalCode=selectedZipCode;
            leadObj1.Street_Name__c = selectedStrtName;
            leadObj1.street_Number__c = selectedStrtNumber;
            leadObj1.Zip_Code__c = selectedZipCode;
            leadObj1.Street_Subtitle__c = selectedStrtSubtitle;
            leadObj1.Street_Subtitle_Ln_Ave_etc__c = selectedStrtSubDescription;
            insert leadObj1;
            
            echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
            agreement.echosign_dev1__Opportunity__c = objopportunity.Id;
            agreement.echosign_dev1__More_Recipients__c = 'test@gmail.com';
            agreement.echosign_dev1__Recipient_User__c = userObj.Id;
            agreement.echosign_dev1__Additional_Recipient_1_User__c = userObj.Id;
            agreement.echosign_dev1__Additional_Recipient_2_User__c = userObj.Id;
            agreement.echosign_dev1__Additional_Recipient_3_User__c = userObj.Id;
            agreement.echosign_dev1__Status__c = 'Draft';
            agreement.echosign_dev1__Contract__c = ctr.Id;
            agreement.echosign_dev1__Recipient_Lead__c = leadObj.Id;
            agreement.echosign_dev1__Recipient_Lead4__c = leadObj1.Id;
            insert agreement;
            
            vlocity_cmt__ContractVersion__c version = new vlocity_cmt__ContractVersion__c();
            version.vlocity_cmt__ContractId__c = ctr.Id;
            insert version;
            
            vlocity_cmt__ContractSection__c section = new vlocity_cmt__ContractSection__c();
            section.vlocity_cmt__ContractVersionId__c = version.Id;
            insert section;
            
            ContentVersion cv = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = blob.valueof('Test Content Data'),
                IsMajorVersion = true
                
            );
            insert cv;
            
            ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
             ContentDocumentLink contentlink=new ContentDocumentLink();
             contentlink.LinkedEntityId=agreement.Id;  
             //contentlink.ShareType= 'C';               
             contentlink.ContentDocumentId=documents[0].Id;
             contentlink.Visibility = 'AllUsers'; 
             insert contentlink;
             ftr_CLMCustomContractSearchController.CustomContractSearchWrapper obj = new ftr_CLMCustomContractSearchController.CustomContractSearchWrapper();
             obj.originalContractListSize = 10;
             obj.limitCount = 50;
             obj.contractList = null;//null
             System.Test.startTest();
                 ftr_CLMCustomContractSearchController.getContractAgreementList(String.valueOf(Blob.valueOf('Test')));
                 Id [] fixedSearchResults= new Id[1];
                   fixedSearchResults[0] = '001x0000003G89h';
                   Test.setFixedSearchResults(fixedSearchResults);
                   List<List<SObject>> searchList = [FIND 'Test' IN ALL FIELDS RETURNING ContentVersion(id, createddate, Title, FirstPublishLocationId, ContentDocumentId WHERE Title = 'Test' LIMIT 1)];
                   ftr_CLMCustomContractSearchController.getContractRecordTypeNames(); 
                   ftr_CLMCustomContractSearchController.getAgreementTypeFieldValue('Contract','MDU_ContractType__c');                        
                   ftr_CLMCustomContractSearchController.getContractList('TestAccount','Renewal','Corporation','Ethernet/Data Services',null,'Draft','Document Generated','ISP','Test',null,'Renewal','Test','Test');
             System.Test.stopTest();
        }
    }
}