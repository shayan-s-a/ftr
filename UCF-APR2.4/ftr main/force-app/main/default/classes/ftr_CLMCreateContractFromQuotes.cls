public class ftr_CLMCreateContractFromQuotes{
    
    public static List<vlocity_cmt__ContractVersion__c> getContractVersion(final String quoteId, final String accountId, final String contractType, final String signingOrder){
        
        if (Test.isRunningTest()){
            Contract_Template_List__c template = new Contract_Template_List__c();
            template.Name = 'CLM_TMPL_00010';
            template.Schedule_Type__c = 'FiberOptic & OneVoice Nationwide (copper)';
            template.Agreement_Type__c = 'Broadband FiberOptic & Voice Bundles - New Service';
            template.Template_Name__c = 'Fiber and OneVoice Schedule';
            insert template;
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
             Account testSAccount = new Account();
             testSAccount.Name = 'Test Service Account';
             testSAccount.RecordTypeId = servRecId;
             testSAccount.BillingStreet = '123 Main Street';
             testSAccount.BillingCity = 'Anywhere';
             testSAccount.BillingState = 'Ohio';
             testSAccount.BillingPostalCode = '44088';
             testSAccount.ShippingStreet = '123 Main Street';
             testSAccount.ShippingCity = 'Anywhere';
             testSAccount.ShippingState = 'Ohio';
             testSAccount.ShippingPostalCode = '44088';
            testSAccount.ParentId = a.Id;
             insert testSAccount;
            
             Opportunity opp = new Opportunity();
             opp.Name = 'RefreshTestOpp';
             opp.AccountId = a.id;
             Date d1=Date.newInstance(2019, 05, 11);
             opp.CloseDate=d1;
             opp.StageName='Investigating';
             opp.CPE_Product__c='No';
             insert opp;
            
             id pricebookId = Test.getStandardPricebookId();
             List<Product2> lstProduct2 = new List<Product2>();
             Product2 product = new Product2();
             product.Name = 'EIA';
             product.ProductCode = 'ENT_ETH_EIA_0001';
             product.IsActive = true;
             lstProduct2.add(product);
    
             Product2 prodEVC = new Product2();
             prodEVC.Name = 'EVC';
             prodEVC.ProductCode = 'ENT_ETH_EVC_0001';
             prodEVC.IsActive = true;
             lstProduct2.add(prodEVC);
            
             Product2 prodAccess = new Product2();
             prodAccess.Name = 'Access';
             prodAccess.ProductCode = 'ENT_ETH_ACCESS_0001';
             prodAccess.IsActive = true;
             lstProduct2.add(prodAccess);
             //*Insert products
             insert lstProduct2;  
            
             PricebookEntry standardPrice = new PricebookEntry(
                 Pricebook2Id = pricebookId, 
                 Product2Id = lstProduct2[0].Id,
                 UnitPrice = 100, IsActive = true);
             insert standardPrice;
            
             Quote oQuote = new Quote();
             oQuote.Name = 'Testing Quote';
             oQuote.OpportunityId = Opp.id;
             oQuote.Pricebook2Id = pricebookId;
             oQuote.Products__c = 'EVPL';
             insert oQuote;
             Id recordTypeId = Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByName().get('Frontier Services Agreement').getRecordTypeId();
            
            Contract ctr = new Contract(Status = 'Draft', AccountId = a.id, Opportunity__c = opp.id, ICB_Flag__c = 'Y', Icb_for_email_for_test__c = true);
            ctr.BillingCity = 'Tampa';
            ctr.BillingCountry = 'United States';
            ctr.BillingState = 'Florida';
            ctr.BillingStreet = '4900 West Kennedy Boulevard';
            ctr.BillingPostalCode = '75068';
            ctr.Status = 'Draft';
            ctr.vlocity_cmt__QuoteId__c = oQuote.Id;
            ctr.ShippingCity = 'Tampa';
            ctr.ShippingCountry = 'United States';
            ctr.ShippingState = 'Florida';
            ctr.ShippingStreet = '321 East Commerce Street';
            ctr.ShippingPostalCode = '75068';
            ctr.RecordTypeId = recordTypeId;
            //insert  ctr; 
            
            
        }
        
        if (contractType == null || String.isBlank(contractType)){
            contractType = 'PS';
        }
        // Check for existing Contract for given QuoteId -> If Contract Status = Draft -> update to Cancelled
        List<Contract> cancelledContractList = new List<Contract>();
        List<Contract> draftContractList = [Select Id, Status, vlocity_cmt__QuoteId__c, vlocity_cmt__QuoteId__r.Id from Contract where  (Status = 'Draft' OR Contract_Status__c = 'Draft') AND (AccountId=:accountId) AND Contract_Record_Type_Formula__c != 'Frontier Services Agreement' AND vlocity_cmt__QuoteId__r.Id=:quoteId AND (Agreement_Type__c ='GenerateUCFSchedule' OR Agreement_Type__c ='schedule' OR Agreement_Type__c ='SDWANSchedule')];
        System.debug('Existing Contracts in Draft Status: ' + draftContractList);
        if (draftContractList != null && draftContractList.size() > 0){
            for(Contract con: draftContractList){
                con.Status = 'Cancelled';
                con.Contract_Status__c = 'Cancelled';
                cancelledContractList.add(con);
            }
        }
        if (cancelledContractList.size() > 0)    update cancelledContractList;
        System.debug('Existing Contracts in Cancelled Status: ' + cancelledContractList);
        ftr_CreateContractFlowController.ContractData contractDataObj = new ftr_CreateContractFlowController.ContractData();
        contractDataObj.quoteId = quoteId;
        contractDataObj.contractType = contractType;
        List<ftr_CreateContractFlowController.ContractData> contractDataList = new List<ftr_CreateContractFlowController.ContractData>();
        contractDataList.add(contractDataObj);
        List<List<Id>> contractIdList;
        if (Test.isRunningTest()){
            Contract contractObj = [Select Id from Contract LIMIT 1];
            List<Id> contractIdListTest = new List<Id>{contractObj.Id};
            contractIdList = new List<List<Id>>{contractIdListTest};
        }else{
            contractIdList = ftr_CreateContractFlowController.createContract(contractDataList);
        }
        
        System.debug('Contract Ids: '+ contractIdList);
        Set<Id> contractIdSet = new Set<Id>();
        
        if (contractIdList != null && contractIdList.size() > 0){
            for(List<Id> idObj: contractIdList){
                List<Id> idTempList = idObj;
                if (idTempList != null && idTempList.size() > 0){
                    for(Id idStr: idTempList){
                        contractIdSet.add(idStr);        
                    }
                }
            }
        }
        System.debug('contractIdSet: '+ contractIdSet);
        if (contractIdSet != null && contractIdSet.size() > 0){
            
            List<Contract> contractList = [Select Id,RecordType.Id,RecordType.Name,Agreement_Type__c,Schedule_Type__c,Products__c,vlocity_cmt__RecurringTotal__c from Contract WHERE Id IN: (contractidSet)];
            List<Contract> contractUpdateList = new List<Contract>();
            List<vlocity_cmt__ContractVersion__c> contractVersionList = new List<vlocity_cmt__ContractVersion__c>();
            if (contractList != null && contractList.size() > 0){
                for(Contract con: contractList){
                    con.Contract_Status__c = 'Draft';
                    con.CLM_Signing_Order__c = signingOrder;
                    Contract FSAContract = ftr_CLMContractCreation.getFSAContract(accountId);
                    if (FSAContract != null)
                        con.FSA__c = FSAContract.Id; 
                    if (con.RecordType.Name == 'Product Schedule' && con.vlocity_cmt__RecurringTotal__c > 0 && con.Products__c.contains('UCF')){
                        con.Agreement_Type__c = 'GenerateUCFSchedule';
                        con.Schedule_Type__c = 'GenerateUCFSchedule';
                        con.Template_Name__c = 'GenerateUCFSchedule';
                    }else if (con.RecordType.Name == 'Product Schedule' && con.vlocity_cmt__RecurringTotal__c > 0 && (con.Products__c.contains('EIA') || con.Products__c.contains('EVPL') || con.Products__c.contains('Private Network'))){
                        con.Agreement_Type__c = 'schedule';
                        con.Schedule_Type__c = 'schedule';
                        con.Template_Name__c = 'schedule';
                    }else if (con.RecordType.Name == 'Product Schedule' && con.vlocity_cmt__RecurringTotal__c > 0 && con.Products__c.contains('SDWAN')){
                        con.Agreement_Type__c = 'SDWANSchedule';
                        con.Schedule_Type__c = 'SDWANSchedule';
                        con.Template_Name__c = 'SDWANSchedule';
                    }
                    contractUpdateList.add(con);
                }
            }
            if (contractUpdateList.size() > 0)    update contractUpdateList;
            List<vlocity_cmt__ContractVersion__c> conVersionList = [Select Id, Name, vlocity_cmt__Type__c, vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.Agreement_Type__c,vlocity_cmt__ContractId__r.Schedule_Type__c, vlocity_cmt__ContractId__r.Id, vlocity_cmt__DocumentTemplateId__c, vlocity_cmt__DocumentTemplateId__r.Id
                                                  FROM  vlocity_cmt__ContractVersion__c where vlocity_cmt__ContractId__r.Id IN: (contractIdSet)];
            for(vlocity_cmt__ContractVersion__c conVerRec: conVersionList){
                //conVerRec.Name = 'Version1';
                conVerRec.vlocity_cmt__Type__c = conVerRec.vlocity_cmt__ContractId__r.Agreement_Type__c;
                System.debug('conVerRec.vlocity_cmt__ContractId__r.Agreement_Type__c: '+ conVerRec.vlocity_cmt__ContractId__r.Agreement_Type__c);
                String templateName = ftr_CLMContractCreation.getTemplateName(conVerRec.vlocity_cmt__ContractId__r.Agreement_Type__c, conVerRec.vlocity_cmt__ContractId__r.Schedule_Type__c);
                conVerRec.vlocity_cmt__DocumentTemplateId__c = ftr_CLMContractCreation.getContractTemplateId(templateName);
                contractVersionList.add(conVerRec);
            }
            if (contractVersionList.size() > 0)    update contractVersionList;
            System.debug('contractVersionList: ' + contractVersionList);
            System.debug('contractVersionList JSON: ' + System.JSON.serialize(contractVersionList));
            return contractVersionList; 
        }
        return null;
    }
}
// *