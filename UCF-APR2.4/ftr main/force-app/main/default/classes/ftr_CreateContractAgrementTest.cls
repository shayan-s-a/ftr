/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 3 
 * 
**/
@istest
public class ftr_CreateContractAgrementTest {
   static testMethod void AgreementMethod() {
       User userObj = [Select Id from User where profile.Name = 'Frontier System Administrator' AND IsActive=true LIMIT 1];
        System.runAs(userObj){            
             RecordType FSARecordType = [Select Id,name,DeveloperName,sobjecttype From RecordType where sobjecttype = 'Contract' AND DeveloperName='Frontier_Services_Agreement' LIMIT 1];
            Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
         
              Id masterRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Master' LIMIT 1]?.Id;
        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = masterRecId;
        a.ParentId = globalAcc.Id;
        insert a;
           Id servRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Service' LIMIT 1]?.Id;
         
        Account ac = new Account();
        ac.Name = 'test Acc';
        ac.RecordTypeId = servRecId;
        ac.Legal_Street__c='test';
        ac.Legal_City__c='test';
        ac.Legal_State__c='test';
        ac.ShippingStreet='test';
        ac.ShippingCity='NY';
        ac.ShippingState='New York';
        ac.BillingStreet='test';
        ac.BillingCity='NY';
        ac.BillingState='New York';
        ac.ParentId = a.Id;
            insert ac;
        Opportunity op  = new Opportunity();
            op.AccountId=a.Id;
        op.Name= 'test';
        op.StageName = 'Prospecting';
        op.CloseDate = Date.newInstance(2016, 12, 9);
            op.Expected_Billed_Date__c = date.today();
        insert op;
        echosign_dev1__SIGN_Agreement__c saggrement = new echosign_dev1__SIGN_Agreement__c();
        saggrement.echosign_dev1__Opportunity__c=op.id;
        saggrement.Name=op.Name;
        saggrement.echosign_dev1__SignatureType__c='e-Signature';
        saggrement.echosign_dev1__SignatureOrder__c='Recipient signs, then I sign';
        saggrement.echosign_dev1__Status__c='Signed';
        saggrement.echosign_dev1__Message__c='  Please review and sign this document.';
        saggrement.echosign_dev1__Enable_Hosted_Signing__c  = true;
        saggrement.echosign_dev1__Authoring__c=true;
        //listagrement.add(saggrement);
        
        //if(listagrement!=null && listagrement.size()>0){
        insert saggrement; 
        //}
          echosign_dev1__SIGN_Agreement__c saggrementdec = new echosign_dev1__SIGN_Agreement__c();
        saggrementdec.echosign_dev1__Opportunity__c=op.id;
        saggrementdec.Name=op.Name;
        saggrementdec.echosign_dev1__SignatureType__c='e-Signature';
        saggrementdec.echosign_dev1__SignatureOrder__c='Recipient signs, then I sign';
        saggrementdec.echosign_dev1__Status__c='Cancelled / Declined';
        saggrementdec.echosign_dev1__Message__c='   Please review and sign this document.';
        saggrementdec.echosign_dev1__Enable_Hosted_Signing__c   = true;
        saggrementdec.echosign_dev1__Authoring__c=true;
        //listagrement.add(saggrement);
          //if(listagrement!=null && listagrement.size()>0){
        insert saggrementdec; 
            
             Contract ca = new Contract();
        ca.Name = 'test';
        ca.BillingStreet='test';
        ca.BillingCity='NY';
        ca.BillingState='New York';  
            ca.BillingPostalCode = '45678';
           ca.BillingCountry='United States';
             ca.ShippingStreet='test';
        ca.ShippingCity='NY';
        ca.ShippingState='New York';  
            ca.ShippingPostalCode = '45678';
           ca.ShippingCountry='United States';
        ca.AccountId = a.Id;
        ca.Status = 'Draft';
        ca.StartDate =  Date.newInstance(2016, 12, 9);
        ca.ContractTerm = 12;
            ca.Contract_Status__c ='Draft';
            ca.Document_Status__c  ='Document Generated';
        ca.vlocity_cmt__OpportunityId__c = op.id;
            ca.Opportunity__c = op.id;
            ca.RecordTypeId = FSARecordType.Id;
           // c.vlocity_cmt__QuoteId__c = oQuote.Id;
        insert ca;
        Agreement_Contracts__c aggcona = new Agreement_Contracts__c();
        aggcona.Contract__c = ca.id;
        aggcona.Name = 'test';
        aggcona.Agreement__c = saggrementdec.id;
        insert aggcona;
           
        
             echosign_dev1__SIGN_Agreement__c updateaggrementstatus = [SELECT Id, echosign_dev1__Status__c FROM echosign_dev1__SIGN_Agreement__c WHERE Id=:saggrementdec.Id];
           updateaggrementstatus.echosign_dev1__Status__c = 'Draft';
            update updateaggrementstatus;
            echosign_dev1__SIGN_Agreement__c updateaggrementofsstatus = [SELECT Id, echosign_dev1__Status__c FROM echosign_dev1__SIGN_Agreement__c WHERE Id=:saggrementdec.Id];
           updateaggrementofsstatus.echosign_dev1__Status__c = 'Out for Signature';
            update updateaggrementofsstatus;
            echosign_dev1__SIGN_Agreement__c updateaggrementwfcstatus = [SELECT Id, echosign_dev1__Status__c FROM echosign_dev1__SIGN_Agreement__c WHERE Id=:saggrementdec.Id];
           updateaggrementwfcstatus.echosign_dev1__Status__c = 'Waiting for Counter-Approval';
            update updateaggrementwfcstatus;
            echosign_dev1__SIGN_Agreement__c updateaggrementwfcstatussign = [SELECT Id, echosign_dev1__Status__c FROM echosign_dev1__SIGN_Agreement__c WHERE Id=:saggrementdec.Id];
           updateaggrementwfcstatussign.echosign_dev1__Status__c = 'Signed';
            update updateaggrementwfcstatussign;
      
             Quote oQuote = new Quote();
         oQuote.Name = 'Testing Quote';
         oQuote.OpportunityId = Op.id;
         insert oQuote;
         
        
        
        Contract c = new Contract();
        c.Name = 'test';
        c.BillingStreet='test';
        c.BillingCity='NY';
        c.BillingState='New York';  
            c.BillingPostalCode = '45678';
           c.BillingCountry='United States';
             c.ShippingStreet='test';
        c.ShippingCity='NY';
        c.ShippingState='New York';  
            c.ShippingPostalCode = '45678';
           c.ShippingCountry='United States';
        c.AccountId = a.Id;
       // c.Status = 'In Approval Process';
        c.StartDate =  Date.newInstance(2016, 12, 9);
        c.ContractTerm = 12;
            c.Contract_Status__c ='Draft';
            c.Document_Status__c  ='Document Generated';
        c.vlocity_cmt__OpportunityId__c = op.id;
            c.Opportunity__c = op.id;
            c.RecordTypeId = FSARecordType.Id;
         //   c.vlocity_cmt__QuoteId__c = oQuote.Id;
        insert c;
        system.debug('====saggrement:'+saggrement);
        
        ContentVersion content=new ContentVersion(); 
        content.Title='test - signed.pdf'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=saggrement.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
            
        insert contentlink;
        
        
        
        
        Agreement_Contracts__c aggcon = new Agreement_Contracts__c();
        aggcon.Contract__c = c.id;
        aggcon.Name = 'test';
        aggcon.Agreement__c = saggrement.id;
        insert aggcon;
        
        Update saggrement;
        vlocity_cmt__ContractVersion__c cv = new vlocity_cmt__ContractVersion__c();
        cv.vlocity_cmt__ContractId__c=c.id;
        insert cv;
            
            Update c;
            contract updatecontractcv = [SELECT Id, vlocity_cmt__ActiveContractVersionId__c FROM Contract WHERE Id=:c.Id];
           updatecontractcv.vlocity_cmt__ActiveContractVersionId__c = cv.Id;
            update updatecontractcv;
            
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob2=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob2;
        attach.parentId=cv.id;
        insert attach;
             Opportunity opp  = new Opportunity();
            opp.AccountId=a.Id;
        opp.Name= 'test';
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.newInstance(2016, 12, 9);
            opp.Expected_Billed_Date__c = date.today();
        insert opp;
        echosign_dev1__SIGN_Agreement__c saggrementdraft = new echosign_dev1__SIGN_Agreement__c();
        saggrementdraft.echosign_dev1__Opportunity__c=opp.id;
        saggrementdraft.Name=op.Name;
        saggrementdraft.echosign_dev1__SignatureType__c='e-Signature';
        saggrementdraft.echosign_dev1__SignatureOrder__c='Recipient signs, then I sign';
        saggrementdraft.echosign_dev1__Status__c='Draft';
        saggrementdraft.echosign_dev1__Message__c='Please review and sign this document.';
        saggrementdraft.echosign_dev1__Enable_Hosted_Signing__c = true;
        saggrementdraft.echosign_dev1__Authoring__c=true;
        //listagrement.add(saggrement);
        
        //if(listagrement!=null && listagrement.size()>0){
        insert saggrementdraft; 
        
        ftr_CreateContractAgrement cca = new ftr_CreateContractAgrement();
        map<string,object>inp = new map<string,object>();
        inp.put('AgreementId',saggrement.id);
        inp.put('OpportunityId',op.id);
        map<string,object>oup = new map<string,object>();
        map<string,object>opt = new map<string,object>();
        cca.invokeMethod('Contractagreement',inp,oup,opt);
        
        
         }
   
        
        
        
        
        
        
        
        
        
        
        
        
    }
}