/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@Istest
public class ftr_CLMAgreementTriggerHandlerTest{

    @IsTest
    public static void testUpdateContractStatus1(){
        User userObj = [Select Id from User where profile.Name = 'Frontier System Administrator' AND IsActive=true LIMIT 1];
        System.runAs(userObj){
            Account objAccount = new Account(name = 'TestAccount');
            insert objAccount;
            opportunity objopportunity1= new opportunity(AccountId=objAccount.Id);
            objopportunity1.Name ='testing opp1';
            objopportunity1.StageName='verbal commit'; 
            objopportunity1.CloseDate= date.today();
            objopportunity1.Expected_Billed_Date__c = date.today();
            //insert objopportunity;
            
            opportunity objopportunity2= new opportunity(AccountId=objAccount.Id);
            objopportunity2.Name ='testing opp2';
            objopportunity2.StageName='verbal commit'; 
            objopportunity2.CloseDate= date.today();
            objopportunity2.Expected_Billed_Date__c = date.today();
            
            opportunity objopportunity3= new opportunity(AccountId=objAccount.Id);
            objopportunity3.Name ='testing opp3';
            objopportunity3.StageName='verbal commit'; 
            objopportunity3.CloseDate= date.today();
            objopportunity3.Expected_Billed_Date__c = date.today();
            
            opportunity objopportunity4= new opportunity(AccountId=objAccount.Id);
            objopportunity4.Name ='testing opp4';
            objopportunity4.StageName='verbal commit'; 
            objopportunity4.CloseDate= date.today();
            objopportunity4.Expected_Billed_Date__c = date.today();
            
            List<Opportunity> oppList = new List<Opportunity>{objopportunity1, objopportunity2, objopportunity3, objopportunity4};
            insert oppList;
            
            Contract ctr = new Contract(Status = 'Draft', AccountId = objAccount.id, Opportunity__c = oppList[0].id, ICB_Flag__c = 'Y', Icb_for_email_for_test__c = true);
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
            String selectedStrtSubtitle = 'Ln'; 
            String selectedStrtSubDescription = '';
            String selectedTelNum = '3043258181';
            String selectCriteriaDef = 'Address';
            Lead leadObj = new Lead();
            leadObj.LastName = 'test';
            leadObj.Company = 'test';
            leadObj.City__c = selectedCity;
            leadObj.State__c = stateListDef;
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
            leadObj1.Street_Name__c = selectedStrtName;
            leadObj1.street_Number__c = selectedStrtNumber;
            leadObj1.Zip_Code__c = selectedZipCode;
            leadObj1.Street_Subtitle__c = selectedStrtSubtitle;
            leadObj1.Street_Subtitle_Ln_Ave_etc__c = selectedStrtSubDescription;
            insert leadObj1;
            
            echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
            agreement.echosign_dev1__Opportunity__c = oppList[0].Id;
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
            
            echosign_dev1__SIGN_Agreement__c agreement1 = new echosign_dev1__SIGN_Agreement__c();
            agreement1.echosign_dev1__Opportunity__c = oppList[0].Id;
            agreement1.echosign_dev1__More_Recipients__c = 'test@gmail.com';
            agreement1.echosign_dev1__Recipient_User__c = userObj.Id;
            agreement1.echosign_dev1__Additional_Recipient_1_User__c = userObj.Id;
            agreement1.echosign_dev1__Additional_Recipient_2_User__c = userObj.Id;
            agreement1.echosign_dev1__Additional_Recipient_3_User__c = userObj.Id;
            agreement1.echosign_dev1__Status__c = 'Draft';
            agreement1.echosign_dev1__Recipient_Lead2__c = leadObj.Id;
            //agreement1.echosign_dev1__Contract__c = ctr.Id;
            insert agreement1;
            agreement1.echosign_dev1__Status__c = 'Signed';
            update agreement1;
            
            echosign_dev1__SIGN_Agreement__c agreement2 = new echosign_dev1__SIGN_Agreement__c();
            //agreement1.echosign_dev1__Opportunity__c = oppList[0].Id;
            agreement2.echosign_dev1__More_Recipients__c = 'test@gmail.com';
            agreement2.echosign_dev1__Recipient_User__c = userObj.Id;
            agreement2.echosign_dev1__Additional_Recipient_1_User__c = userObj.Id;
            agreement2.echosign_dev1__Additional_Recipient_2_User__c = userObj.Id;
            agreement2.echosign_dev1__Additional_Recipient_3_User__c = userObj.Id;
            agreement2.echosign_dev1__Status__c = 'Draft';
            agreement2.echosign_dev1__Account__c = objAccount.Id;
            agreement.echosign_dev1__Recipient_Lead__c = leadObj.Id;
            agreement2.echosign_dev1__Recipient_Lead3__c = leadObj.Id;
            agreement2.echosign_dev1__Recipient_Lead4__c = leadObj.Id;
            
            //agreement1.echosign_dev1__Contract__c = ctr.Id;
            insert agreement2;
            agreement2.echosign_dev1__Status__c = 'Signed';
            update agreement2;
            ftr_CLMAgreementTriggerHandler.updateContractStatus(new Set<Id>{agreement1.Id, agreement1.Id, agreement2.Id});
        }
    }
    
    @IsTest
    public static void testUpdateContractStatus2(){
        User userObj = [Select Id from User where profile.Name = 'Frontier System Administrator' AND IsActive=true LIMIT 1];
        System.runAs(userObj){
            Account objAccount = new Account(name = 'TestAccount');
            insert objAccount;
            opportunity objopportunity1= new opportunity(AccountId=objAccount.Id);
            objopportunity1.Name ='testing opp1';
            objopportunity1.StageName='verbal commit'; 
            objopportunity1.CloseDate= date.today();
            objopportunity1.Expected_Billed_Date__c = date.today();
            //insert objopportunity;
            
            opportunity objopportunity2= new opportunity(AccountId=objAccount.Id);
            objopportunity2.Name ='testing opp2';
            objopportunity2.StageName='verbal commit'; 
            objopportunity2.CloseDate= date.today();
            objopportunity2.Expected_Billed_Date__c = date.today();
            
            opportunity objopportunity3= new opportunity(AccountId=objAccount.Id);
            objopportunity3.Name ='testing opp3';
            objopportunity3.StageName='verbal commit'; 
            objopportunity3.CloseDate= date.today();
            objopportunity3.Expected_Billed_Date__c = date.today();
            
            opportunity objopportunity4= new opportunity(AccountId=objAccount.Id);
            objopportunity4.Name ='testing opp4';
            objopportunity4.StageName='verbal commit'; 
            objopportunity4.CloseDate= date.today();
            objopportunity4.Expected_Billed_Date__c = date.today();
            
            List<Opportunity> oppList = new List<Opportunity>{objopportunity1, objopportunity2, objopportunity3, objopportunity4};
            insert oppList;
            
            Contract ctr = new Contract(Status = 'Draft', AccountId = objAccount.id, Opportunity__c = oppList[0].id, ICB_Flag__c = 'Y', Icb_for_email_for_test__c = true);
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
            String selectedStrtSubtitle = 'Ln'; 
            String selectedStrtSubDescription = '';
            String selectedTelNum = '3043258181';
            String selectCriteriaDef = 'Address';
            Lead leadObj = new Lead();
            leadObj.LastName = 'test';
            leadObj.Company = 'test';
            leadObj.City__c = selectedCity;
            leadObj.State__c = stateListDef;
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
            leadObj1.Street_Name__c = selectedStrtName;
            leadObj1.street_Number__c = selectedStrtNumber;
            leadObj1.Zip_Code__c = selectedZipCode;
            leadObj1.Street_Subtitle__c = selectedStrtSubtitle;
            leadObj1.Street_Subtitle_Ln_Ave_etc__c = selectedStrtSubDescription;
            insert leadObj1;
            
            Contact con = new Contact(LastName='TestContact', AccountID = objAccount.id);
            insert con;
            
            echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
            agreement.echosign_dev1__Opportunity__c = oppList[0].Id;
            agreement.echosign_dev1__More_Recipients__c = 'test@gmail.com';
            agreement.echosign_dev1__Recipient_User__c = userObj.Id;
            agreement.echosign_dev1__Additional_Recipient_1_User__c = userObj.Id;
            agreement.echosign_dev1__Additional_Recipient_2_User__c = userObj.Id;
            agreement.echosign_dev1__Additional_Recipient_3_User__c = userObj.Id;
            agreement.echosign_dev1__Status__c = 'Draft';
            agreement.echosign_dev1__Contract__c = ctr.Id;
            agreement.echosign_dev1__Recipient_Lead__c = leadObj.Id;
            agreement.echosign_dev1__Recipient_Lead3__c = leadObj.Id;
            agreement.echosign_dev1__Recipient_Lead2__c = leadObj1.Id;
            agreement.echosign_dev1__Recipient_Lead4__c = leadObj1.Id;
            agreement.echosign_dev1__Recipient__c = con.Id;
            agreement.echosign_dev1__Recipient2__c = con.Id;
            agreement.echosign_dev1__Recipient3__c = con.Id;
            agreement.echosign_dev1__Recipient4__c = con.Id;
            insert agreement;
            
            agreement.echosign_dev1__Status__c = 'Signed';
            update agreement;
            
            ftr_CLMAgreementTriggerHandler.updateContractStatus(new Set<Id>{agreement.Id});
        }
    }
}