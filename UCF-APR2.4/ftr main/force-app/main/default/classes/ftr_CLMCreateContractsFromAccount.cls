global with sharing class ftr_CLMCreateContractsFromAccount implements vlocity_cmt.VlocityOpenInterface2 {

    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output,  Map<String, Object> options) {
        Boolean success = true;
        if (methodName == 'checkFSAContracts'){
            Boolean FSAPresent = checkFSAAvailable(String.Valueof(input.get('AccountId')));
            //success = FSAPresent; FSAExistsFlag
            output.put('FSAPresent', FSAPresent);
        
        }else if (methodName == 'createContracts'){
          try{
                List<vlocity_cmt__ContractVersion__c> contractVersionList = new List<vlocity_cmt__ContractVersion__c>();
              output.put('step10', 'step10');
                contractVersionList = ftr_CLMCreateContractsFromAccount.createContracts(input, output, options);
              output.put('step20', 'step20');
                if (contractVersionList != null && contractVersionList.size() > 0){
                    for(Integer i = 0; i<contractVersionList.size(); i++){
                       vlocity_cmt__ContractVersion__c version = contractVersionList.get(i);
                       output.put('ContractId' + String.valueOf(i + 1), version.vlocity_cmt__ContractId__c);
                       output.put('ContractVersionId' + String.valueOf(i + 1), version.Id);
                       Map<String, String> templateIdMap = new Map<String, String>();
                       templateIdMap.put('Id', version.vlocity_cmt__DocumentTemplateId__c);
                       output.put('TemplateId' + String.valueOf(i + 1), templateIdMap);
                       output.put('test1',  '--' + version.vlocity_cmt__ContractId__r.agreement_type__c + '--');
                       //output.put('TemplateName' + String.valueOf(i + 1), version.vlocity_cmt__DocumentTemplateId__r.Name);    
                       output.put('TemplateName' + String.valueOf(i + 1), version.vlocity_cmt__ContractId__r.agreement_type__c);    
                    }
                }
            }catch(Exception ex){
                output.put('ExceptionFinal', 'The template Cannot be found in the rule engine. Please contact your system administrator for assistance' + String.valueOf(ex));
            }
        }else {
            System.debug('ftr_CLMContractCreation unknownmethod');
            
        }
        System.debug('Final JSON output response: ' + System.JSON.serialize(output));
        return success;
    }
    
    public static List<vlocity_cmt__ContractVersion__c> createContracts(Map<String, Object> input, Map<String, Object> output,  Map<String, Object> options){
        vlocity_cmt__ContractVersion__c conVerRec = null;
        vlocity_cmt__ContractVersion__c conVerRecWholeSale = null;
        List<vlocity_cmt__ContractVersion__c> contractVersionFinalList = new List<vlocity_cmt__ContractVersion__c>();
        Boolean FSAExistsFlag = Boolean.valueOf(input.get('FSAExistsFlag'));
        String FSATemplateType = (String)input.get('FSATemplateType');
        Integer contractTerm = Integer.valueOf(input.get('ContractTerm'));
        String signingOrder = (String)input.get('SigningOrder');
        //String FSASigningOrder = 'Customer 1st, Frontier 2nd';
        String FSASigningOrder = (String)input.get('SigningOrder');
        Date contractStartDate = Date.valueOf((String)input.get('ContractStartDate'));
        String accountId = (String)input.get('AccountId');
        String AccountTemplate = (String)input.get('AccountTemplate');
        String FTRAppAOptions = (String)input.get('FTRAppAOptions');
        //String pNumText = (String)input.get('PNUMText');
        Boolean CallCenterProfileFlag = Boolean.valueOf(input.get('CallCenterProfileFlag'));
        output.put('CallCenterProfileFlag', CallCenterProfileFlag);
        
         // Check for existing Contract for given AccountId/OpportunityId -> If Contract Status = Draft -> update to Cancelled
        List<Contract> cancelledContractList = new List<Contract>();
        List<Contract> draftContractList = [Select Id,AccountId,Opportunity__c,Opportunity__r.AccountId, Opportunity__r.Id, Status, vlocity_cmt__QuoteId__c, vlocity_cmt__QuoteId__r.Id, Quote_Sterling__c, Quote_Sterling__r.Id,Contract_Record_Type_Formula__c from Contract where (Status = 'Draft' OR Contract_Status__c = 'Draft') AND (AccountId=:accountId) AND Contract_Record_Type_Formula__c != 'Frontier Services Agreement'AND (Agreement_Type__c =:AccountTemplate OR Agreement_Type__c =:FTRAppAOptions)];
        System.debug('Existing Sterling Contracts in Draft Status: ' + draftContractList);
        if (draftContractList != null && draftContractList.size() > 0){
            for(Contract con: draftContractList){
                con.Status = 'Cancelled';
                con.Contract_Status__c = 'Cancelled';
                cancelledContractList.add(con);
            }
        }
        
        if (cancelledContractList.size() > 0)    update cancelledContractList;
            
        if (!FSAExistsFlag){
            Account FSAAccount = [Select Id, Name,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingCountryCode,ShippingStateCode,ShippingPostalCode, BillingStreet, BillingCity, BillingState, BillingStateCode, BillingPostalCode,BillingCountryCode, BillingCountry
                                 FROM Account where Id=:accountId LIMIT 1]; 
                          output.put('step15', 'step15');

            Contract contractNew = new Contract();
            contractNew.StartDate = System.Today();
            contractNew.ContractTerm = 60;
            contractNew.CLM_Signing_Order__c = FSASigningOrder;
            contractNew.AccountId = FSAAccount.Id;
            if (FSATemplateType != null && FSATemplateType == '5 Page'){
                contractNew.Agreement_Type__c = 'Frontier FSA';
                contractNew.Schedule_Type__c = 'Frontier FSA';
            } else if (FSATemplateType != null && FSATemplateType == '1 Page'){
                if (CallCenterProfileFlag) {
                    contractNew.Agreement_Type__c = 'FSA Standard Call Center';
                    contractNew.Schedule_Type__c = 'FSA Standard Call Center';
                } else {
                    contractNew.Agreement_Type__c = 'FSA_Standard'; 
                    contractNew.Schedule_Type__c = 'FSA_Standard';
                }
            } else if (FSATemplateType != null && FSATemplateType == '4 Page'){
                if (CallCenterProfileFlag) {
                    contractNew.Agreement_Type__c = 'FSA Extended Call Center';
                    contractNew.Schedule_Type__c = 'FSA Extended Call Center';
                } else {
                    contractNew.Agreement_Type__c = 'FSA_Extended';
                    contractNew.Schedule_Type__c = 'FSA_Extended';
                }
            }
            contractNew.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Frontier Services Agreement').getRecordTypeId();

            contractNew.BillingStreet = FSAAccount.BillingStreet;
            contractNew.BillingCity =   FSAAccount.BillingCity;
            contractNew.BillingState =  FSAAccount.BillingState;
            contractNew.BillingStateCode = FSAAccount.BillingStateCode;
            contractNew.BillingPostalCode = FSAAccount.BillingPostalCode;
            contractNew.BillingCountry = FSAAccount.BillingCountry;
            contractNew.BillingCountryCode = FSAAccount.BillingCountryCode;
            contractNew.ShippingStreet = FSAAccount.ShippingStreet;
            contractNew.ShippingCity =   FSAAccount.ShippingCity;
            contractNew.ShippingState = FSAAccount.ShippingState;
            contractNew.ShippingStateCode = FSAAccount.ShippingStateCode;
            contractNew.ShippingPostalCode = FSAAccount.ShippingPostalCode;
            contractNew.ShippingCountry = FSAAccount.ShippingCountry;
            contractNew.ShippingCountryCode = FSAAccount.ShippingCountryCode;
                      output.put('step30', 'step30');

            if (Test.isRunningTest()){
                contractNew.BillingStreet = '123 Main Street';
                contractNew.BillingCity = 'New Milford';
                contractNew.BillingState = 'Connecticut';
                contractNew.BillingStateCode = 'CT';
                contractNew.BillingPostalCode = '44088';
                contractNew.BillingCountry = 'United States';
                contractNew.BillingCountryCode = 'US';
                contractNew.ShippingStreet = '123 Main Street';
                contractNew.ShippingCity = 'New Milford';
                contractNew.ShippingState = 'Connecticut';
                contractNew.ShippingStateCode = 'CT';
                contractNew.ShippingPostalCode = '44088';
                contractNew.ShippingCountry = 'United States';
                contractNew.ShippingCountryCode = 'US';    
            }
            insert contractNew; // create new FSA Contract
    
            if(Test.isRunningTest()){
                vlocity_cmt__ContractVersion__c cv = new vlocity_cmt__ContractVersion__c();
                cv.vlocity_cmt__ContractId__c=contractNew.id;
                insert cv;
            }
            if (contractNew != null){
                List<vlocity_cmt__ContractVersion__c> conVersionList = [Select Id, Name, vlocity_cmt__Type__c, vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.Agreement_Type__c,vlocity_cmt__ContractId__r.Schedule_Type__c, vlocity_cmt__ContractId__r.Id, vlocity_cmt__DocumentTemplateId__c, vlocity_cmt__DocumentTemplateId__r.Id
                                                               FROM  vlocity_cmt__ContractVersion__c where vlocity_cmt__ContractId__r.Id=:contractNew.Id];
                if (conVersionList != null && conVersionList.size() > 0){
                    List<vlocity_cmt__ContractVersion__c> contractVersionList1 = new List<vlocity_cmt__ContractVersion__c>();
                    for(vlocity_cmt__ContractVersion__c conVerRec1: conVersionList){
                        conVerRec1.vlocity_cmt__Type__c = conVerRec1.vlocity_cmt__ContractId__r.Agreement_Type__c;
                        conVerRec1.vlocity_cmt__DocumentTemplateId__c = ftr_CLMContractCreation.getContractTemplateId(conVerRec1.vlocity_cmt__ContractId__r.Agreement_Type__c);
                        contractVersionList1.add(conVerRec1);
                    }
                    if (contractVersionList1.size() > 0){
                        update contractVersionList1;
                        conVerRec = contractVersionList1[0];
                        contractVersionFinalList.add(conVerRec);
                    }
                }
            }

        }// FSA Contract Creation ends
       
       
              output.put('step40', 'step40');
       Account acctObj = [Select Id,Federal__c, Name,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingCountryCode,ShippingStateCode,ShippingPostalCode, BillingStreet, BillingCity, BillingState, BillingStateCode, BillingPostalCode,BillingCountryCode, BillingCountry
                         FROM Account where Id=:accountId LIMIT 1]; 
       Contract contractNew = new Contract();
       contractNew.AccountId = acctObj.Id;
       Contract FSAContract = getFSAContract(accountId);
       if (FSAContract != null)
           contractNew.FSA__c = FSAContract.Id;
       contractNew.Name = (acctObj != null && acctObj.Federal__c ? (acctObj.Name + acctObj.ShippingStreet) : null);
       if (Test.isRunningTest()){
           contractNew.StartDate = System.Today().addDays(+2);
       }else{
           contractNew.StartDate = contractStartDate;
       }
       contractNew.Status = 'Draft';
       contractNew.Contract_Status__c = 'Draft';
       contractNew.OwnerExpirationNotice = '15';
       contractNew.Document_Status__c = 'Document Generated';
                     output.put('step50', 'step50');

        if (AccountTemplate != null && AccountTemplate == 'FTR AppA'){
           contractNew.Agreement_Type__c = FTRAppAOptions;
           contractNew.Schedule_Type__c = FTRAppAOptions;
           contractNew.Template_Name__c = ftr_CLMContractCreation.getTemplateName(FTRAppAOptions, FTRAppAOptions);
       }else if (AccountTemplate != null && AccountTemplate != 'FTR AppA'){
           contractNew.Agreement_Type__c = AccountTemplate;
           contractNew.Schedule_Type__c = AccountTemplate;
           contractNew.Template_Name__c = ftr_CLMContractCreation.getTemplateName(AccountTemplate, AccountTemplate);
       }
       
       contractNew.vlocity_cmt__QuoteId__c = null;
       contractNew.Quote_Sterling__c = null;
       contractNew.ContractTerm = contractTerm;
       contractNew.CLM_Signing_Order__c = signingOrder;
       contractNew.Verified_Contract_End_Date__c = System.Today().addMonths(contractTerm);
       //contractNew.Opportunity__c = opp.Id;
       //contractNew.vlocity_cmt__OpportunityId__c = opp.Id;
       contractNew.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Product Schedule').getRecordTypeId();
                      output.put('step60', 'step60');

        contractNew.BillingStreet = (acctObj.Id != null ? acctObj.BillingStreet : null);
        contractNew.BillingCity =   (acctObj.Id != null ? acctObj.BillingCity : null);
        contractNew.BillingState = (acctObj.Id != null ? acctObj.BillingState : null);
        contractNew.BillingStateCode = (acctObj.Id != null ? acctObj.BillingStateCode : null);
        contractNew.BillingPostalCode = (acctObj.Id != null ? acctObj.BillingPostalCode : null);
        contractNew.BillingCountry = (acctObj.Id != null ? acctObj.BillingCountry : null);
        contractNew.BillingCountryCode = (acctObj.Id != null ? acctObj.BillingCountryCode : null);
        contractNew.ShippingStreet = (acctObj.Id != null ? acctObj.ShippingStreet : null);
        contractNew.ShippingCity =   (acctObj.Id != null ? acctObj.ShippingCity : null);
        contractNew.ShippingState = (acctObj.Id != null ? acctObj.ShippingState : null);
        contractNew.ShippingStateCode = (acctObj.Id != null ? acctObj.ShippingStateCode : null);
        contractNew.ShippingPostalCode = (acctObj.Id != null ? acctObj.ShippingPostalCode : null);
        contractNew.ShippingCountry = (acctObj.Id != null ? acctObj.ShippingCountry : null);
        contractNew.ShippingCountryCode = (acctObj.Id != null ? acctObj.ShippingCountryCode : null);
        
        if (Test.isRunningTest()){
            contractNew.BillingStreet = '123 Main Street';
            contractNew.BillingCity = 'New Milford';
            contractNew.BillingState = 'Connecticut';
            contractNew.BillingStateCode = 'CT';
            contractNew.BillingPostalCode = '44088';
            contractNew.BillingCountry = 'United States';
            contractNew.BillingCountryCode = 'US';
            contractNew.ShippingStreet = '123 Main Street';
            contractNew.ShippingCity = 'New Milford';
            contractNew.ShippingState = 'Connecticut';
            contractNew.ShippingStateCode = 'CT';
            contractNew.ShippingPostalCode = '44088';
            contractNew.ShippingCountry = 'United States';
            contractNew.ShippingCountryCode = 'US';    
       }
       if (contractNew != null)    insert contractNew;
       //contractNew.PNUM__c = pnumText + '-' + contractNew.Id; // Update PNUM Field on Contract
       //update contractNew;
       contractNew.CLM_Signing_Order__c = signingOrder; // Update signing order Field on Contract
       update contractNew;
       System.debug('Newly Inserted Contracts for WholeSaleTeamFlag is: ' + contractNew);
       if(Test.isRunningTest()){
           vlocity_cmt__ContractVersion__c cv = new vlocity_cmt__ContractVersion__c();
           cv.vlocity_cmt__ContractId__c=contractNew.id;
           insert cv;
       }
                     output.put('step70', 'step70');

       List<vlocity_cmt__ContractVersion__c> conVersionListWholeSale = [Select Id, Name, vlocity_cmt__Type__c, vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.Agreement_Type__c,vlocity_cmt__ContractId__r.Schedule_Type__c, vlocity_cmt__ContractId__r.Id, vlocity_cmt__DocumentTemplateId__c, vlocity_cmt__DocumentTemplateId__r.Id
                                                                        FROM  vlocity_cmt__ContractVersion__c where vlocity_cmt__ContractId__r.Id=:contractNew.Id];
       
       if (conVersionListWholeSale != null && conVersionListWholeSale.size() > 0){
           List<vlocity_cmt__ContractVersion__c> contractVersionWholeSaleList = new List<vlocity_cmt__ContractVersion__c>();
           for(vlocity_cmt__ContractVersion__c conVerRecWhole: conVersionListWholeSale){
                //conVerRec.Name = 'Version1';
                conVerRecWhole.vlocity_cmt__Type__c = conVerRecWhole.vlocity_cmt__ContractId__r.Agreement_Type__c;
                String templateName = ftr_CLMContractCreation.getTemplateName(conVerRecWhole.vlocity_cmt__ContractId__r.Agreement_Type__c, conVerRecWhole.vlocity_cmt__ContractId__r.Schedule_Type__c);
                System.debug('TemplateName in WholeSaleTeamFlag is: '+ templateName);
                conVerRecWhole.vlocity_cmt__DocumentTemplateId__c = ftr_CLMContractCreation.getContractTemplateId(templateName);
                contractVersionWholeSaleList.add(conVerRecWhole);
            }
            if (contractVersionWholeSaleList.size() > 0){
                update contractVersionWholeSaleList;
                conVerRecWholeSale = contractVersionWholeSaleList[0];
                contractVersionFinalList.add(conVerRecWholeSale);
            }
       }
                      output.put('step80', 'step80');

       return contractVersionFinalList; 
    }
    
    public static Boolean checkFSAAvailable(final String accountId){
        List<String> REC_TYPES = new List<String>{'Frontier Services Agreement','Community Connections - Agreement','VZ3 Agreement - VEC','VZ3 Agreement - VES'};
        Boolean isFSAExists = false;
        List<Contract> FSAContractList = [SELECT Id,Name FROM Contract WHERE AccountId =:accountId  AND RecordType.Name IN: REC_TYPES];
        if (FSAContractList != null && FSAContractList.size() > 0)
            isFSAExists = true;
            
        return isFSAExists;
    }
    
    public static Contract getFSAContract(final String accountId){
        List<String> REC_TYPES = new List<String>{'Frontier Services Agreement','Community Connections - Agreement','VZ3 Agreement - VEC','VZ3 Agreement - VES'};
        Boolean isFSAExists = false;
        List<Contract> FSAContractList = [SELECT Id,Name FROM Contract WHERE AccountId =:accountId  AND RecordType.Name IN: REC_TYPES];
        if (FSAContractList != null && FSAContractList.size() > 0)
            return FSAContractList[0];
            
        return null;
    }
}