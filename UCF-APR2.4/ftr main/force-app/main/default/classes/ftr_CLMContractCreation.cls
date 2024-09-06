global with sharing class ftr_CLMContractCreation implements vlocity_cmt.VlocityOpenInterface2 
{    
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output,  Map<String, Object> options) 
    {
        Boolean success = false;
            
        System.debug('invokeMethod:methodName -> ' + methodName);
        System.debug('invokeMethod:input-> ' + input);
        
        if (methodName == 'checkProductsForTemplates') 
        {
            Boolean FSAPresent = checkFSAAvailable(String.Valueof(input.get('AccountId')));
            Output.put('FSAPresent',FSAPresent);
            checkProductsForTemplatesFromQuoteIds(input, output, options);
            return true;
        } 
        else if (methodName == 'createContracts') 
        {
            createContractsFromQuoteIds(input, output, options);
            return true;
        }
        /*else if (methodName == 'checkFSAAvailable') 
        {
            Boolean FSAPresent = checkFSAAvailable(String.Valueof(input.get('AccountId')));
            Output.put('FSAPresent',FSAPresent);
            return true;
        }*/ 
        
        
        else 
        {
            System.debug('ftr_CLMContractCreation unknownmethod');
            
        }

        System.debug('invokeMethod:output -> ' + output);
        System.debug('invokeMethod:success -> ' + success);
        return success;
    }
    
   public static void checkProductsForTemplatesFromQuoteIds(Map<String, Object> input, Map<String, Object> output,  Map<String, Object> options){
       List<Object> QuoteIdList;
       try{
           QuoteIdList = (List<Object>) input.get('Quotes'); //will succeed if multiple Quotes exist
       }
       catch(Exception e){
           try{
               QuoteIdList = new List<Object>();
               QuoteIdList.Add((Map<String,Object>) input.get('Quotes'));  //will succeed if one quote exists
           }
           catch(exception e2){
               output.put('NoQuoteFlg',true); //if no quote exists set flag
           }
       }
       //Map<String,Object> xQuote;
       //If (QuoteIdList != null &&QuoteIdList.size()>0){
           //xQuote = (Map<String,Object>) QuoteIdList[0];
       //}
       
       String UpdateAgreeScheduleProduct = '';
       String TemplateNotFoundProduct = '';
       String TemplateFoundProduct = '';
       Boolean ProceedFlag = true;
       if (QuoteIdList != null && QuoteIdList.size() > 0){
           for(Object obj: QuoteIdList){
               Map<String, Object> quoteIdMap = (Map<String, Object>)obj;
               String quoteId = String.valueOf(quoteIdMap.get('Id'));
               Map<String, Object> inputMap = new Map<String, Object>();
               inputMap.put('quoteId', quoteId);
               Map<String, Object> resultMap = ftr_CLMContractCreation.checkProductsForTemplates(inputMap, output, options);
               if (resultMap != null && resultMap.size() > 0){
                   String UpdateAgreeScheduleProductTemp = (String)resultMap.get('UpdateAgreeSchedule');
                   if (UpdateAgreeScheduleProductTemp != null && String.isNotBlank(UpdateAgreeScheduleProductTemp))
                       UpdateAgreeScheduleProduct += UpdateAgreeScheduleProductTemp + ',';
                   
                   Map<String, Object> TemplateNotFoundTemp = (Map<String, Object>)resultMap.get('TemplateNotFound');
                   if (TemplateNotFoundTemp != null){
                       String ProductTemp = (String)TemplateNotFoundTemp.get('Product');
                       if (ProductTemp != null && String.isNotBlank(ProductTemp))
                          TemplateNotFoundProduct +=  ProductTemp + ',';
                   }
                   
                   Map<String, Object> TemplateFoundTemp = (Map<String, Object>)resultMap.get('TemplateFound');
                   if (TemplateFoundTemp != null){
                       String ProductTemp = (String)TemplateFoundTemp.get('Product');
                       if (ProductTemp != null && String.isNotBlank(ProductTemp))
                          TemplateFoundProduct +=  ProductTemp + ',';
                  }
                  
                  Boolean ProceedFlagTemp = (Boolean)resultMap.get('ProceedFlag');
                  if (ProceedFlagTemp != null){
                      if (ProceedFlagTemp == false)  ProceedFlag = false;  
                  }   
               }
           }
       }
       else { 
           ProceedFlag = false; //if no quotes
       }
       
       // Form the final output map based on the calculations
       if (UpdateAgreeScheduleProduct != null && UpdateAgreeScheduleProduct.endsWith(','))
           UpdateAgreeScheduleProduct = UpdateAgreeScheduleProduct.removeEnd(',');
       
       if (TemplateNotFoundProduct != null && TemplateNotFoundProduct.endsWith(','))
           TemplateNotFoundProduct = TemplateNotFoundProduct.removeEnd(',');
           
       if (TemplateFoundProduct != null && TemplateFoundProduct.endsWith(','))
           TemplateFoundProduct = TemplateFoundProduct.removeEnd(',');
       
       //sets Proceed flag to false if Agreement/Schedule type not found or Template not in Rule Engine.
       if (UpdateAgreeScheduleProduct !=null && UpdateAgreeScheduleProduct.length()>0)
           ProceedFlag = false;
       if (TemplateNotFoundProduct !=null && TemplateNotFoundProduct.length()>0)
           ProceedFlag = false;
       
           
       Map<String, Object> finalResultMap = new Map<String, Object>();
       finalResultMap.put('UpdateAgreeSchedule', UpdateAgreeScheduleProduct);
       
       Map<String, Object> TemplateNotFoundFinalMap = new Map<String, Object>();
       TemplateNotFoundFinalMap.put('Product', TemplateNotFoundProduct);
       TemplateNotFoundFinalMap.put('Message', 'Template not found in the rule engine. Contact CLM System Administrator');
       finalResultMap.put('TemplateNotFound', TemplateNotFoundFinalMap);
       
       Map<String, Object> TemplateFoundFinalMap = new Map<String, Object>();
       TemplateFoundFinalMap.put('Product', TemplateFoundProduct);
       TemplateFoundFinalMap.put('Message', 'Template Found');
       finalResultMap.put('TemplateFound', TemplateFoundFinalMap);
       
       output.put('TemplateResult', finalResultMap);
       output.put('ProceedFlag', ProceedFlag);
       System.debug('Final JSON Response for checkProductsForTemplatesFromQuoteIds: ' + System.JSON.serialize(output));
   }
    
   public static void createContractsFromQuoteIds(Map<String, Object> input, Map<String, Object> output,  Map<String, Object> options){
       try {
        output.put('step0', 'start');
        // Check if FSA Contract exists, if not first create a FSA Contract
        Boolean isFSAContractexists = checkFSAAvailable(String.Valueof(input.get('AccountId')));
        System.debug('isFSAContractexists for Quote sObject: '+ isFSAContractexists);
        String accountId = (String)input.get('AccountId');
        String FSATemplateType = (String)input.get('FSATemplateType');
        Integer contractTerm = Integer.valueOf(input.get('ContractTerm'));
        String signingOrder = (String)input.get('SigningOrder');
        String FSASigningOrder = signingOrder;   //'Customer 1st, Frontier 2nd';
        Date contractStartDate = Date.valueOf((String)input.get('ContractStartDate'));
        Boolean WholeSaleTeamFlag = Boolean.valueOf(input.get('WholeSaleTeamFlag'));
        String pNumText = (String)input.get('PNUMText');
        String templateNameWholesale = (String)input.get('TemplateName');
        String opportunityId = (String)input.get('opportunityId');
        Boolean MDUTemplatesflag = Boolean.valueOf(input.get('MDUTemplatesflag'));
        Boolean isContractIdFlag = Boolean.valueOf(input.get('isContractId'));
        String MDUTemplates = (String)input.get('MDUTemplates');
        String ChildContractTemplate = (String)input.get('ChildContractTemplate');
        String WholesaleFSATemplate = (String)input.get('WholesaleFSATemplate');
        String FTRAppAOptions = (String)input.get('FTRAppAOptions');
        String ABSTemplates = (String)input.get('ABSTemplates');
        Boolean CallCenterProfileFlag = Boolean.valueOf(input.get('CallCenterProfileFlag'));
        vlocity_cmt__ContractVersion__c conVerRec = null;
        vlocity_cmt__ContractVersion__c conVerRecWholeSale = null;
        List<vlocity_cmt__ContractVersion__c> contractVersionList = new List<vlocity_cmt__ContractVersion__c>();
        List<vlocity_cmt__ContractVersion__c> contractVersionFinalList = new List<vlocity_cmt__ContractVersion__c>();
        
         // Check for existing Contract for given AccountId/OpportunityId -> If Contract Status = Draft -> update to Cancelled
        List<Contract> cancelledContractList = new List<Contract>();
                List<Contract> draftContractList;
                        if (templateNameWholesale != null || FTRAppAOptions != null || ABSTemplates != null || MDUTemplates != null) {
                        draftContractList = [Select Id,AccountId,Opportunity__c,Agreement_Type__c,Opportunity__r.AccountId, Opportunity__r.Id, Status, vlocity_cmt__QuoteId__c, vlocity_cmt__QuoteId__r.Id, Quote_Sterling__c, Quote_Sterling__r.Id,Contract_Record_Type_Formula__c from Contract where (Status = 'Draft' OR Contract_Status__c = 'Draft') AND (AccountId=:accountId OR Opportunity__r.Id=:opportunityId) AND Contract_Record_Type_Formula__c != 'Frontier Services Agreement' AND (Agreement_Type__c =:templateNameWholesale OR Agreement_Type__c =:FTRAppAOptions OR Agreement_Type__c =:ABSTemplates OR Agreement_Type__c =:MDUTemplates)];
                        } else {
                        draftContractList = [Select Id,AccountId,Opportunity__c,Agreement_Type__c,Opportunity__r.AccountId, Opportunity__r.Id, Status, vlocity_cmt__QuoteId__c, vlocity_cmt__QuoteId__r.Id, Quote_Sterling__c, Quote_Sterling__r.Id,Contract_Record_Type_Formula__c from Contract where (Status = 'Draft' OR Contract_Status__c = 'Draft') AND (AccountId=:accountId OR Opportunity__r.Id=:opportunityId) AND Contract_Record_Type_Formula__c != 'Frontier Services Agreement'];
                        }
                System.debug('Existing Sterling Contracts in Draft Status: ' + draftContractList);
        if (draftContractList != null && draftContractList.size() > 0){
            for(Contract con: draftContractList){
                con.Status = 'Cancelled';
                con.Contract_Status__c = 'Cancelled';
                cancelledContractList.add(con);
            }
        }
        if (cancelledContractList.size() > 0)    update cancelledContractList;
        
        // Check if either of WholeSaleTeamFlag, MDUTemplatesflag or ABSTemplates or isContractIdFlag is true
        if ((ABSTemplates != null && String.isNotBlank(ABSTemplates)) || (WholeSaleTeamFlag != null && WholeSaleTeamFlag) || (MDUTemplatesflag != null && MDUTemplatesflag) || (isContractIdFlag != null && isContractIdFlag )){
            if (ABSTemplates != null && String.isNotBlank(ABSTemplates)){
                output.put('step0.5', 'step0.5 inside ABS');
                // Check FSAContract exists for ABSTemplates
                Account FSAAccount = [Select Id,Federal__c,Name,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingCountryCode,ShippingStateCode,ShippingPostalCode, BillingStreet, BillingCity, BillingState, BillingStateCode, BillingPostalCode,BillingCountryCode, BillingCountry
                                     FROM Account where Id=:accountId LIMIT 1]; 
                if (!isFSAContractexists){
                    Contract contractNew = new Contract();
                    contractNew.StartDate = System.Today();
                    contractNew.ContractTerm = 60;
                    contractNew.CLM_Signing_Order__c = FSASigningOrder; 

                    contractNew.AccountId = FSAAccount.Id;
                    contractNew.Status = 'Draft';
                    contractNew.Contract_Status__c = 'Draft';
                    if (FSATemplateType != null && FSATemplateType == '1 Page'){
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
/*                    
                    if (ABSTemplates != null && ABSTemplates == '1 Page'){
                        contractNew.Agreement_Type__c = 'FSA_Standard';
                        contractNew.Schedule_Type__c = 'FSA_Standard';
                    }else if (ABSTemplates != null && ABSTemplates == '4 Page'){
                        contractNew.Agreement_Type__c = 'FSA_Extended';
                        contractNew.Schedule_Type__c = 'FSA_Extended';
                    }
*/
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
        output.put('step1', 'step1');
               
               Contract contractNew = new Contract();
               contractNew.AccountId = accountId;
               Contract FSAContract = getFSAContract(accountId);
               if (FSAContract != null)
                   contractNew.FSA__c = FSAContract.Id;
               contractNew.Name = (FSAAccount != null && FSAAccount.Federal__c ? (FSAAccount.Name + FSAAccount.ShippingStreet) : null);
               if (Test.isRunningTest()){
                   contractNew.StartDate = System.Today().addDays(+2);
               }else{
                   contractNew.StartDate = contractStartDate;
               }
               contractNew.Status = 'Draft';
               contractNew.Contract_Status__c = 'Draft';
               contractNew.OwnerExpirationNotice = '15';
               contractNew.Document_Status__c = 'Document Generated';
               contractNew.Agreement_Type__c = ABSTemplates;
               contractNew.Schedule_Type__c = ABSTemplates;
               contractNew.Template_Name__c = getTemplateName(ABSTemplates, ABSTemplates);
               contractNew.vlocity_cmt__QuoteId__c = null;
               contractNew.Quote_Sterling__c = null;
               contractNew.ContractTerm = contractTerm;
               contractNew.CLM_Signing_Order__c = signingOrder;
               contractNew.Verified_Contract_End_Date__c = System.Today().addMonths(contractTerm);
               //contractNew.Opportunity__c = opp.Id;
               //contractNew.vlocity_cmt__OpportunityId__c = opp.Id;
               contractNew.Opportunity__c = opportunityId;
               contractNew.vlocity_cmt__OpportunityId__c = opportunityId;
               
               contractNew.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Product Schedule').getRecordTypeId();
                
                contractNew.BillingStreet = (FSAAccount.Id != null ? FSAAccount.BillingStreet : null);
                contractNew.BillingCity =   (FSAAccount.Id != null ? FSAAccount.BillingCity : null);
                contractNew.BillingState = (FSAAccount.Id != null ? FSAAccount.BillingState : null);
                contractNew.BillingStateCode = (FSAAccount.Id != null ? FSAAccount.BillingStateCode : null);
                contractNew.BillingPostalCode = (FSAAccount.Id != null ? FSAAccount.BillingPostalCode : null);
                contractNew.BillingCountry = (FSAAccount.Id != null ? FSAAccount.BillingCountry : null);
                contractNew.BillingCountryCode = (FSAAccount.Id != null ? FSAAccount.BillingCountryCode : null);
                contractNew.ShippingStreet = (FSAAccount.Id != null ? FSAAccount.ShippingStreet : null);
                contractNew.ShippingCity =   (FSAAccount.Id != null ? FSAAccount.ShippingCity : null);
                contractNew.ShippingState = (FSAAccount.Id != null ? FSAAccount.ShippingState : null);
                contractNew.ShippingStateCode = (FSAAccount.Id != null ? FSAAccount.ShippingStateCode : null);
                contractNew.ShippingPostalCode = (FSAAccount.Id != null ? FSAAccount.ShippingPostalCode : null);
                contractNew.ShippingCountry = (FSAAccount.Id != null ? FSAAccount.ShippingCountry : null);
                contractNew.ShippingCountryCode = (FSAAccount.Id != null ? FSAAccount.ShippingCountryCode : null);
        output.put('step2', 'step2');
                
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
               System.debug('Newly Inserted Contracts for WholeSaleTeamFlag is: ' + contractNew);
               if(Test.isRunningTest()){
                   vlocity_cmt__ContractVersion__c cv = new vlocity_cmt__ContractVersion__c();
                   cv.vlocity_cmt__ContractId__c=contractNew.id;
                   insert cv;
               }
               
               List<vlocity_cmt__ContractVersion__c> conVersionListWholeSale = [Select Id, Name, vlocity_cmt__Type__c, vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.Agreement_Type__c,vlocity_cmt__ContractId__r.Schedule_Type__c, vlocity_cmt__ContractId__r.Id, vlocity_cmt__DocumentTemplateId__c, vlocity_cmt__DocumentTemplateId__r.Id
                                                                                FROM  vlocity_cmt__ContractVersion__c where vlocity_cmt__ContractId__r.Id=:contractNew.Id];
               
               if (conVersionListWholeSale != null && conVersionListWholeSale.size() > 0){
                   List<vlocity_cmt__ContractVersion__c> contractVersionWholeSaleList = new List<vlocity_cmt__ContractVersion__c>();
                   for(vlocity_cmt__ContractVersion__c conVerRecWhole: conVersionListWholeSale){
                        //conVerRec.Name = 'Version1';
                        conVerRecWhole.vlocity_cmt__Type__c = conVerRecWhole.vlocity_cmt__ContractId__r.Agreement_Type__c;
                        String templateName = getTemplateName(conVerRecWhole.vlocity_cmt__ContractId__r.Agreement_Type__c, conVerRecWhole.vlocity_cmt__ContractId__r.Schedule_Type__c);
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
            output.put('step3', 'step3');
        
            // If WholesaleFSATemplate is not blank
            }else if (WholeSaleTeamFlag && (WholesaleFSATemplate != null || String.isNotBlank(WholesaleFSATemplate))){
                if (!isFSAContractexists){
                    Account FSAAccount = [Select Id, Name,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingCountryCode,ShippingStateCode,ShippingPostalCode, BillingStreet, BillingCity, BillingState, BillingStateCode, BillingPostalCode,BillingCountryCode, BillingCountry
                                         FROM Account where Id=:accountId LIMIT 1]; 
                    Contract contractNew = new Contract();
                    contractNew.StartDate = System.Today();
                    contractNew.ContractTerm = 60;
                    contractNew.CLM_Signing_Order__c = FSASigningOrder;
                    contractNew.AccountId = FSAAccount.Id;
                    if (WholesaleFSATemplate != null && WholesaleFSATemplate == 'Frontier FSA'){
                        contractNew.Agreement_Type__c = 'Frontier FSA';
                        contractNew.Schedule_Type__c = 'Frontier FSA';
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
            
                }
            }
            output.put('step1', 'before WholeSaleTeamFlag'); 
            // WholeSaleFlag = true but it will not check for FSA
            if (WholeSaleTeamFlag){
                List<Opportunity> oppList = [Select Id, Account.Primary_ACNA__c,Account.Federal__c, Account.Id, Account.BillingStreet, Account.BillingCity, Account.BillingState,Account.BillingStateCode, Account.BillingPostalCode, Account.BillingCountry,Account.BillingCountryCode,
                              Account.ShippingStreet, Account.ShippingCity, Account.ShippingState,Account.ShippingStateCode, Account.ShippingPostalCode, Account.ShippingCountry, Account.ShippingCountryCode
                              FROM Opportunity where Id=:opportunityId LIMIT 1];
                
                if (oppList != null && oppList.size() > 0){
                   Opportunity opp = oppList[0];
                   Contract contractNew = new Contract();
                   contractNew.AccountId = opp.AccountId;
                   Contract FSAContract = getFSAContract(opp.AccountId);
                   if (FSAContract != null)
                       contractNew.FSA__c = FSAContract.Id;
                   
                   contractNew.Name = (opp != null && opp.Account.Federal__c ? (opp.Account.Name + opp.Account.ShippingStreet) : null);
                   if (Test.isRunningTest()){
                       contractNew.StartDate = System.Today().addDays(+2);
                   }else{
                       contractNew.StartDate = contractStartDate;
                   }
                  
                   contractNew.Status = 'Draft';
                   contractNew.Contract_Status__c = 'Draft';
                   contractNew.OwnerExpirationNotice = '15';
                   contractNew.Document_Status__c = 'Document Generated';
                   if (templateNameWholesale != null && templateNameWholesale == 'FTR AppA'){
                       contractNew.Agreement_Type__c = FTRAppAOptions;
                       contractNew.Schedule_Type__c = FTRAppAOptions;
                       contractNew.CLM_Wholesale_FTR_AppA__c = FTRAppAOptions; 
                       contractNew.Template_Name__c = getTemplateName(FTRAppAOptions, FTRAppAOptions);
                   }else if (templateNameWholesale != null && templateNameWholesale != 'FTR AppA'){
                       contractNew.Agreement_Type__c = templateNameWholesale;
                       contractNew.Schedule_Type__c = templateNameWholesale;
                       contractNew.Template_Name__c = getTemplateName(templateNameWholesale, templateNameWholesale);
                   }
                   contractNew.vlocity_cmt__QuoteId__c = null;
                   contractNew.Quote_Sterling__c = null;
                   contractNew.ContractTerm = contractTerm;
                   contractNew.CLM_Signing_Order__c = signingOrder;
                   contractNew.Verified_Contract_End_Date__c = System.Today().addMonths(contractTerm);
                   contractNew.Opportunity__c = opp.Id;
                   contractNew.vlocity_cmt__OpportunityId__c = opp.Id;
                   contractNew.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Product Schedule').getRecordTypeId();
                    
                    contractNew.BillingStreet = (opp.Account.Id != null ? opp.Account.BillingStreet : null);
                    contractNew.BillingCity =   (opp.Account.Id != null ? opp.Account.BillingCity : null);
                    contractNew.BillingState = (opp.Account.Id != null ? opp.Account.BillingState : null);
                    contractNew.BillingStateCode = (opp.Account.Id != null ? opp.Account.BillingStateCode : null);
                    contractNew.BillingPostalCode = (opp.Account.Id != null ? opp.Account.BillingPostalCode : null);
                    contractNew.BillingCountry = (opp.Account.Id != null ? opp.Account.BillingCountry : null);
                    contractNew.BillingCountryCode = (opp.Account.Id != null ? opp.Account.BillingCountryCode : null);
                    contractNew.ShippingStreet = (opp.Account.Id != null ? opp.Account.ShippingStreet : null);
                    contractNew.ShippingCity =   (opp.Account.Id != null ? opp.Account.ShippingCity : null);
                    contractNew.ShippingState = (opp.Account.Id != null ? opp.Account.ShippingState : null);
                    contractNew.ShippingStateCode = (opp.Account.Id != null ? opp.Account.ShippingStateCode : null);
                    contractNew.ShippingPostalCode = (opp.Account.Id != null ? opp.Account.ShippingPostalCode : null);
                    contractNew.ShippingCountry = (opp.Account.Id != null ? opp.Account.ShippingCountry : null);
                    contractNew.ShippingCountryCode = (opp.Account.Id != null ? opp.Account.ShippingCountryCode : null);
                    
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
                   // Update PNUM Field on Contract
                   List<CLM_Environment_Settings__c> clmEnvSettingsList = [Select Id, Name, SubType__c,Type__c,Value__c FROM CLM_Environment_Settings__c WHERE Type__c='Wholesale' AND SubType__c =:templateNameWholesale LIMIT 1];
                   if (clmEnvSettingsList != null && clmEnvSettingsList.size() > 0){
                       String contractNumStr = [Select Id, ContractNumber from Contract where Id=:contractNew.Id LIMIT 1].ContractNumber;
                       String punumTextStr = clmEnvSettingsList[0].Value__c + 'V001' + opp.Account.Primary_ACNA__c + contractNumStr;
                       contractNew.PNUM__c = punumTextStr; 
                       update contractNew;
                   }
                   System.debug('Newly Inserted Contracts for WholeSaleTeamFlag is: ' + contractNew);
                   if(Test.isRunningTest()){
                       vlocity_cmt__ContractVersion__c cv = new vlocity_cmt__ContractVersion__c();
                       cv.vlocity_cmt__ContractId__c=contractNew.id;
                       insert cv;
                   }
        output.put('step4', 'step4');
                   
                   List<vlocity_cmt__ContractVersion__c> conVersionListWholeSale = [Select Id, Name, vlocity_cmt__Type__c, vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.Agreement_Type__c,vlocity_cmt__ContractId__r.Schedule_Type__c, vlocity_cmt__ContractId__r.Id, vlocity_cmt__DocumentTemplateId__c, vlocity_cmt__DocumentTemplateId__r.Id
                                                                                    FROM  vlocity_cmt__ContractVersion__c where vlocity_cmt__ContractId__r.Id=:contractNew.Id];
                   
                   if (conVersionListWholeSale != null && conVersionListWholeSale.size() > 0){
                       List<vlocity_cmt__ContractVersion__c> contractVersionWholeSaleList = new List<vlocity_cmt__ContractVersion__c>();
                       for(vlocity_cmt__ContractVersion__c conVerRecWhole: conVersionListWholeSale){
                            //conVerRec.Name = 'Version1';
                            conVerRecWhole.vlocity_cmt__Type__c = conVerRecWhole.vlocity_cmt__ContractId__r.Agreement_Type__c;
                            String templateName = getTemplateName(conVerRecWhole.vlocity_cmt__ContractId__r.Agreement_Type__c, conVerRecWhole.vlocity_cmt__ContractId__r.Schedule_Type__c);
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
              }
        output.put('step5', 'step5');
                
            }else if (MDUTemplatesflag){

        output.put('step6', 'step6');

                List<Opportunity> oppList = [Select Id,Account.Federal__c, Account.Id, Account.BillingStreet, Account.BillingCity, Account.BillingState,Account.BillingStateCode, Account.BillingPostalCode, Account.BillingCountry,Account.BillingCountryCode,
                              Account.ShippingStreet, Account.ShippingCity, Account.ShippingState,Account.ShippingStateCode, Account.ShippingPostalCode, Account.ShippingCountry, Account.ShippingCountryCode
                              FROM Opportunity where Id=:opportunityId LIMIT 1];
                
                // Check FSAContract exists for MDUTemplateFlag
                /*if (!isFSAContractexists){
                    Account FSAAccount = [Select Id, Name,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingCountryCode,ShippingStateCode,ShippingPostalCode, BillingStreet, BillingCity, BillingState, BillingStateCode, BillingPostalCode,BillingCountryCode, BillingCountry
                                         FROM Account where Id=:accountId LIMIT 1]; 
                    Contract contractNew = new Contract();
                    contractNew.StartDate = System.Today();
                    contractNew.ContractTerm = 60;
                    contractNew.AccountId = FSAAccount.Id;
                    if (FSATemplateType != null && FSATemplateType == '1 Page'){
                        contractNew.Agreement_Type__c = 'FSA_Standard';
                        contractNew.Schedule_Type__c = 'FSA_Standard';
                    }else if (FSATemplateType != null && FSATemplateType == '4 Page'){
                        contractNew.Agreement_Type__c = 'FSA_Extended';
                        contractNew.Schedule_Type__c = 'FSA_Extended';
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
                output.put('step1', 'FSA Contract Creation ends');  */

                if (oppList != null && oppList.size() > 0){
                   Opportunity opp = oppList[0];
                   Contract contractNew = new Contract();
                   contractNew.AccountId = opp.AccountId;
                   Contract FSAContract = getFSAContract(opp.AccountId);
                   if (FSAContract != null)
                       contractNew.FSA__c = FSAContract.Id;
                   contractNew.Name = (opp != null && opp.Account.Federal__c ? (opp.Account.Name + opp.Account.ShippingStreet) : null);
                   if (Test.isRunningTest()){
                       contractNew.StartDate = System.Today().addDays(+2);
                   }else{
                       contractNew.StartDate = contractStartDate;
                   }
                output.put('step2', 'opp'); 
                    
                   try {
                   contractNew.Status = 'Draft';
                   contractNew.Contract_Status__c = 'Draft';
                   contractNew.OwnerExpirationNotice = '15';
                   contractNew.Document_Status__c = 'Document Generated';
                   contractNew.Agreement_Type__c = MDUTemplates;
                   contractNew.Schedule_Type__c = MDUTemplates;
                   contractNew.Template_Name__c = getTemplateName(MDUTemplates, MDUTemplates);
                   contractNew.vlocity_cmt__QuoteId__c = null;
                   contractNew.Quote_Sterling__c = null;
                   contractNew.ContractTerm = contractTerm;
                   contractNew.CLM_Signing_Order__c = signingOrder;
                   contractNew.Verified_Contract_End_Date__c = System.Today().addMonths(contractTerm);
                   contractNew.Opportunity__c = opp.Id;
                   contractNew.vlocity_cmt__OpportunityId__c = opp.Id;
                   contractNew.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Product Schedule').getRecordTypeId();
                    
                    contractNew.BillingStreet = (opp.Account.Id != null ? opp.Account.BillingStreet : null);
                    contractNew.BillingCity =   (opp.Account.Id != null ? opp.Account.BillingCity : null);
                    contractNew.BillingState = (opp.Account.Id != null ? opp.Account.BillingState : null);
                    contractNew.BillingStateCode = (opp.Account.Id != null ? opp.Account.BillingStateCode : null);
                    contractNew.BillingPostalCode = (opp.Account.Id != null ? opp.Account.BillingPostalCode : null);
                    contractNew.BillingCountry = (opp.Account.Id != null ? opp.Account.BillingCountry : null);
                    contractNew.BillingCountryCode = (opp.Account.Id != null ? opp.Account.BillingCountryCode : null);
                    contractNew.ShippingStreet = (opp.Account.Id != null ? opp.Account.ShippingStreet : null);
                    contractNew.ShippingCity =   (opp.Account.Id != null ? opp.Account.ShippingCity : null);
                    contractNew.ShippingState = (opp.Account.Id != null ? opp.Account.ShippingState : null);
                    contractNew.ShippingStateCode = (opp.Account.Id != null ? opp.Account.ShippingStateCode : null);
                    contractNew.ShippingPostalCode = (opp.Account.Id != null ? opp.Account.ShippingPostalCode : null);
                    contractNew.ShippingCountry = (opp.Account.Id != null ? opp.Account.ShippingCountry : null);
                    contractNew.ShippingCountryCode = (opp.Account.Id != null ? opp.Account.ShippingCountryCode : null);
                    
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
                } Catch (Exception mduException) {
                   output.put('mduException', String.valueOf(mduException)); 
                }
                   //contractNew.PNUM__c = pnumText + '-' + contractNew.Id; // Update PNUM Field on Contract
                   //update contractNew;
                   System.debug('Newly Inserted Contracts for MDU is: ' + contractNew);
                   if(Test.isRunningTest()){
                       vlocity_cmt__ContractVersion__c cv = new vlocity_cmt__ContractVersion__c();
                       cv.vlocity_cmt__ContractId__c=contractNew.id;
                       insert cv;
                   }
                   
                   List<vlocity_cmt__ContractVersion__c> conVersionListWholeSale = [Select Id, Name, vlocity_cmt__Type__c, vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.Agreement_Type__c,vlocity_cmt__ContractId__r.Schedule_Type__c, vlocity_cmt__ContractId__r.Id, vlocity_cmt__DocumentTemplateId__c, vlocity_cmt__DocumentTemplateId__r.Id
                                                                                    FROM  vlocity_cmt__ContractVersion__c where vlocity_cmt__ContractId__r.Id=:contractNew.Id];
                   
                   if (conVersionListWholeSale != null && conVersionListWholeSale.size() > 0){
                       List<vlocity_cmt__ContractVersion__c> contractVersionWholeSaleList = new List<vlocity_cmt__ContractVersion__c>();
                       for(vlocity_cmt__ContractVersion__c conVerRecWhole: conVersionListWholeSale){
                            //conVerRec.Name = 'Version1';
                            conVerRecWhole.vlocity_cmt__Type__c = conVerRecWhole.vlocity_cmt__ContractId__r.Agreement_Type__c;
                            String templateName = getTemplateName(conVerRecWhole.vlocity_cmt__ContractId__r.Agreement_Type__c, conVerRecWhole.vlocity_cmt__ContractId__r.Schedule_Type__c);
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
              }
                
            }else if (isContractIdFlag){
                // Clone the existing Contract which matches with opportunityId
                List<Contract> contractList= [Select Id, AccountId, Name, StartDate, Status, Contract_Status__c, OwnerExpirationNotice, Document_Status__c,Agreement_Type__c,Schedule_Type__c,Template_Name__c,vlocity_cmt__QuoteId__c,Quote_Sterling__c,ContractTerm, CLM_Signing_Order__c, Verified_Contract_End_Date__c,Opportunity__c,vlocity_cmt__OpportunityId__c,RecordTypeId,
                                              BillingStreet,BillingCity,BillingState,BillingStateCode,BillingPostalCode,BillingCountry,BillingCountryCode,ShippingStreet,ShippingCity,ShippingState,ShippingStateCode,ShippingPostalCode,ShippingCountry,ShippingCountryCode,
                                              PNUM__c from Contract where Id=:opportunityId LIMIT 1];
                if (contractList != null && contractList.size() > 0){
                    Contract contractNew = contractList[0].clone();
                    contractNew.Agreement_Type__c = ChildContractTemplate;
                    contractNew.Schedule_Type__c = ChildContractTemplate;
                    contractNew.Template_Name__c = getTemplateName(ChildContractTemplate, ChildContractTemplate);
                    contractNew.vlocity_cmt__QuoteId__c = null;
                    contractNew.Quote_Sterling__c = null; 
                    insert contractNew;
                    contractNew.PNUM__c = pnumText + '-' + contractNew.Id; // Update PNUM Field on Contract
                    update contractNew;
                    System.debug('Newly Inserted Contracts for WholeSaleTeamFlag is: ' + contractNew);
                    if(Test.isRunningTest()){
                       vlocity_cmt__ContractVersion__c cv = new vlocity_cmt__ContractVersion__c();
                       cv.vlocity_cmt__ContractId__c=contractNew.id;
                       insert cv;
                   }
                   List<vlocity_cmt__ContractVersion__c> conVersionListWholeSale = [Select Id, Name, vlocity_cmt__Type__c, vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.Agreement_Type__c,vlocity_cmt__ContractId__r.Schedule_Type__c, vlocity_cmt__ContractId__r.Id, vlocity_cmt__DocumentTemplateId__c, vlocity_cmt__DocumentTemplateId__r.Id
                                                                                    FROM  vlocity_cmt__ContractVersion__c where vlocity_cmt__ContractId__r.Id=:contractNew.Id];
                   
                   if (conVersionListWholeSale != null && conVersionListWholeSale.size() > 0){
                       List<vlocity_cmt__ContractVersion__c> contractVersionWholeSaleList = new List<vlocity_cmt__ContractVersion__c>();
                       for(vlocity_cmt__ContractVersion__c conVerRecWhole: conVersionListWholeSale){
                            //conVerRec.Name = 'Version1';
                            conVerRecWhole.vlocity_cmt__Type__c = conVerRecWhole.vlocity_cmt__ContractId__r.Agreement_Type__c;
                            String templateName = getTemplateName(conVerRecWhole.vlocity_cmt__ContractId__r.Agreement_Type__c, conVerRecWhole.vlocity_cmt__ContractId__r.Schedule_Type__c);
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
                    
                }
            }
            
        }else if ((WholeSaleTeamFlag == null || WholeSaleTeamFlag == false) && (ABSTemplates == null || String.isBlank(ABSTemplates)) && (MDUTemplatesflag == null || MDUTemplatesflag == false) && (isContractIdFlag  == null || isContractIdFlag == false)){
            // Go for FSA Contract part
            if (!isFSAContractexists){
                Account FSAAccount = [Select Id, Name,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingCountryCode,ShippingStateCode,ShippingPostalCode, BillingStreet, BillingCity, BillingState, BillingStateCode, BillingPostalCode,BillingCountryCode, BillingCountry
                                 FROM Account where Id=:accountId LIMIT 1]; 
                Contract contractNew = new Contract();
                contractNew.StartDate = System.Today();
                contractNew.ContractTerm = 60;
                contractNew.CLM_Signing_Order__c = FSASigningOrder;
                contractNew.AccountId = FSAAccount.Id;
                contractNew.Status = 'Draft';
                contractNew.Contract_Status__c = 'Draft'; 
                if (FSATemplateType != null && FSATemplateType == '1 Page'){
                    contractNew.Agreement_Type__c = 'FSA_Standard';
                    contractNew.Schedule_Type__c = 'FSA_Standard';
                }else if (FSATemplateType != null && FSATemplateType == '4 Page'){
                    contractNew.Agreement_Type__c = 'FSA_Extended';
                    contractNew.Schedule_Type__c = 'FSA_Extended';
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
           }// FSA Contract creation ends
           
           //List<Object> QuoteIdList = (List<Object>)input.get('Quotes');
           List<Object> QuoteIdList;
           try{
               QuoteIdList = (List<Object>) input.get('Quotes'); //will succeed if multiple quotes exist
           }
           catch(Exception e){
               try{
                   QuoteIdList = new List<Object>();
                   QuoteIdList.Add((Map<String,Object>) input.get('Quotes'));  //will succeed if one quote exists
               }
               catch(exception e2){
                   output.put('NoQuoteFlg',true); //if no quote exists set flag
               }
           }
           
           if (QuoteIdList != null && QuoteIdList.size() > 0){
               for(Object obj: QuoteIdList){
                   Map<String, Object> quoteIdMap = (Map<String, Object>)obj;
                   String quoteId = String.valueOf(quoteIdMap.get('Id'));
                   Map<String, Object> inputMap = new Map<String, Object>();
                   inputMap.put('quoteId', quoteId);
                   inputMap.put('ContractTerm', contractTerm);
                   inputMap.put('SigningOrder', signingOrder);
                   inputMap.put('ContractStartDate', contractStartDate);
                   inputMap.put('AccountId', AccountId);
                   inputMap.put('WholeSaleTeamFlag',WholeSaleTeamFlag);
                   inputMap.put('PNUMText', pNumText);
                   inputMap.put('TemplateName',templateNameWholesale);
                   contractVersionList = ftr_CLMContractCreation.createContracts(inputMap, output, options);
                   if (contractVersionList != null && contractVersionList.size() > 0)
                       contractVersionFinalList.addAll(contractVersionList);
                   //System.debug('Contracts Created for QuoteId: ' + quoteId + ' is: '+ contractVersionList.size());
               }
           }
           
        }
        
       System.debug('Total# Contracts Founds for all Quotes: ' + contractVersionFinalList.size());
       if (contractVersionFinalList != null && contractVersionFinalList.size() > 0){
           Set<Id> contractVersionIdSet = new Set<Id>();
           for(vlocity_cmt__ContractVersion__c version: contractVersionFinalList){
               contractVersionIdSet.add(version.Id);
           }
           List<vlocity_cmt__ContractVersion__c> contractVersionOutputList = [Select Id, vlocity_cmt__ContractId__c, vlocity_cmt__ContractId__r.Id, vlocity_cmt__DocumentTemplateId__c, vlocity_cmt__DocumentTemplateId__r.Id, vlocity_cmt__DocumentTemplateId__r.Name
                                                                                 FROM vlocity_cmt__ContractVersion__c where Id IN: (contractVersionIdSet)];
           Map<String, Object> resultMap = new Map<String, Object>();
           for(Integer i = 0; i<contractVersionOutputList .size(); i++){
               vlocity_cmt__ContractVersion__c version = contractVersionOutputList.get(i);
               output.put('ContractId' + String.valueOf(i + 1), version.vlocity_cmt__ContractId__c);
               output.put('ContractVersionId' + String.valueOf(i + 1), version.Id);
               Map<String, String> templateIdMap = new Map<String, String>();
               templateIdMap.put('Id', version.vlocity_cmt__DocumentTemplateId__c);
               output.put('TemplateId' + String.valueOf(i + 1), templateIdMap);
               output.put('TemplateName' + String.valueOf(i + 1), version.vlocity_cmt__DocumentTemplateId__r.Name);
           }
       }
       System.debug('Final JSON output response: ' + System.JSON.serialize(output));
       } catch (Exception ex) {
           output.put('ExceptionFinal', 'The template Cannot be found in the rule engine. Please contact your system administrator for assistance' + String.valueOf(ex));
       }
   }
    
   public static Map<String, Object> checkProductsForTemplates(Map<String, Object> input, Map<String, Object> output,  Map<String, Object> options){ 
       try{     
        String quoteId = (String) input.get('quoteId');
        //String quoteId = String.Valueof(xQuote.get('Id'));
        if (quoteId != null || String.isNotBlank(quoteId)){
            // Query the Custom Metdata - Contract Templates List
            List<Contract_Template_List__c> templateList = [Select Id, Name,Template_Name__c,Agreement_Type__c,Schedule_Type__c FROM Contract_Template_List__c];
            String sObjectName = getSObjectType(quoteId);
            String updateAgreeSchedule;
            if (sObjectName != null && sObjectName.equals('Quote')){
                List<QuoteLineItem> qliList= [Select Id, Quote.Id, Quote.QuoteNumber, Product2.Id, Product2.Name, Product2.ProductCode, Product2.Agreement_Type__c, Product2.Schedule_Type__c,
                                      Agreement_Type__c,Schedule_Type__c,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__RecurringCharge__c
                                      from QuoteLineItem where Quote.Id =:quoteId]; // fetch all QLI for given QuoteId
        
                Boolean isTemplateFound;
                List<TemplateResponseWrapper> templateWrapperList = new List<TemplateResponseWrapper>();
                List<AgreementScheduleWrapper> agreementWrapperList = new List<AgreementScheduleWrapper>();
                Set<String> productNameSet = new Set<String>();
                Boolean ProceedFlag = false;
                ResponseWrapper responseWrapper = new ResponseWrapper();
        
                if (qliList != null && qliList.size() > 0){
                    for(QuoteLineItem qliObj: qliList){
                        isTemplateFound = false;
                
                        String agreementType = null;
                        String scheduleType = null;
                
                        // Check if Product2.AgreementType is blank, if yes fetch from Agreement_Type__c
                        if (qliObj.Agreement_Type__c != null || String.isNotBlank(qliObj.Agreement_Type__c))
                            agreementType = qliObj.Agreement_Type__c;
                        else if(qliObj.Product2.Id != null && qliObj.Product2.Agreement_Type__c != null)
                            agreementType = qliObj.Product2.Agreement_Type__c;
                        
                        // Check if Product2.Schedule_Type__c is blank, if yes fetch from Schedule_Type__c
                        if (qliObj.Schedule_Type__c != null || String.isNotBlank(qliObj.Schedule_Type__c))
                            scheduleType = qliObj.Schedule_Type__c;
                        else if (qliObj.Product2.Id != null && qliObj.Product2.Schedule_Type__c != null)
                            scheduleType = qliObj.Product2.Schedule_Type__c;
                             
                        // If Product2 AgreementType and ScheduleType both are Do Not Add
                        if (/*qliObj.Product2.Id != null &&*/ agreementType != null && agreementType == 'Do Not Add' &&
                            scheduleType != null && scheduleType == 'Do Not Add'){
                            AgreementScheduleWrapper wrapperObj = new AgreementScheduleWrapper();
                            wrapperObj.productName = qliObj.Product2.Name;
                            wrapperObj.message = 'Will not be added to Contract Document';
                            agreementWrapperList.add(wrapperObj);
                            productNameSet.add(qliObj.Product2.Name);
                            
                        // If Product2 AgreementType and ScheduleType both are Manual    
                        }else if (/*qliObj.Product2.Id != null &&*/ agreementType != null && agreementType == 'Manual' &&
                                  scheduleType != null && scheduleType == 'Manual'){
                                  
                           AgreementScheduleWrapper wrapperObj = new AgreementScheduleWrapper();
                           wrapperObj.productName = qliObj.Product2.Name;
                           wrapperObj.message =  'Enter the Agreement / Schedule Type in Quote Line Item'; 
                           agreementWrapperList.add(wrapperObj);
                           productNameSet.add(qliObj.Product2.Name);
                           
                        // If Product2 AgreementType or ScheduleType are blank/empty
                        }else if (/*qliObj.Product2.Id != null &&*/ 
                                 (agreementType == null || String.isBlank(agreementType)) ||
                                 (scheduleType == null  || String.isBlank(scheduleType))){
                                 
                           AgreementScheduleWrapper wrapperObj = new AgreementScheduleWrapper();
                           wrapperObj.productName = qliObj.Product2.Name;
                           updateAgreeSchedule = (updateAgreeSchedule == null) ? qliObj.Product2.Name : ',' + qliObj.Product2.Name;
                           wrapperObj.message =  'Enter the Agreement / Schedule Type in Quote Line Item'; 
                           agreementWrapperList.add(wrapperObj); 
                           productNameSet.add(qliObj.Product2.Name);         
                        
                        // If AgreementType and ScheduleType both are not-null but both arent Manual/Do Not Add
                        }
                        /*
                        else if (//qliObj.Product2.Id != null &&
                                 (agreementType != null || String.isNotBlank(agreementType) && (agreementType != 'Manual' || agreementType != 'Do Not Add')) &&
                                 (scheduleType != null  || String.isNotBlank(scheduleType) && (scheduleType != 'Manual' || scheduleType != 'Do Not Add'))){
                                 
                           AgreementScheduleWrapper wrapperObj = new AgreementScheduleWrapper();
                           wrapperObj.productName = qliObj.Product2.Name;
                           wrapperObj.message =  'Enter the Agreement / Schedule Type in Quote Line Item'; 
                           agreementWrapperList.add(wrapperObj); 
                           productNameSet.add(qliObj.Product2.Name); 
                        }*/
                        
                        if (templateList != null && templateList.size() > 0){
                            for(Contract_Template_List__c template: templateList){
                                // If Agreement Type and ScheduleType of Product2 matches with the template record
                                if (qliObj.Product2.Id != null && 
                                    template.Agreement_Type__c != null && template.Agreement_Type__c == agreementType && 
                                    template.Schedule_Type__c != null && template.Schedule_Type__c == scheduleType){
                                
                                    TemplateResponseWrapper wrapperObj = new TemplateResponseWrapper();
                                    wrapperObj.productName = qliObj.Product2.Name;
                                    wrapperObj.templateName = template.Template_Name__c;
                                    wrapperObj.message = 'Template Found';
                                    isTemplateFound = true;
                                    templateWrapperList.add(wrapperObj);
                                    break;
                                }
                            }
                        }
                
                        // If Template Not found for that QLI
                        if (!isTemplateFound && agreementType != 'Do Not Add'){
                            TemplateResponseWrapper wrapperObj = new TemplateResponseWrapper();
                            wrapperObj.productName = qliObj.Product2.Name;
                            wrapperObj.templateName = null;
                            wrapperObj.message = 'Template not found in the rule engine. Contact CLM System Administrator';
                            templateWrapperList.add(wrapperObj);
                        }
                    }
            
                    // Final Check - If TemplateMsg has all values as ‘Will not be added to Contract Document‘ or <Template Name> (ie. Found templates for all products)
                    Boolean isTemplateMatched = true;
                    for(TemplateResponseWrapper template: templateWrapperList){
                        if (template.templateName == null){
                            isTemplateMatched = false;
                            break;
                        }
                    }
                    Boolean isAgreementAdded = false;
                    for(AgreementScheduleWrapper agree: agreementWrapperList){
                        if (agree.message == 'Will not be added to Contract Document')
                            isAgreementAdded = true;
                        else
                            isAgreementAdded = false;
                    }
            
                    responseWrapper.agreementMessageWrapper = agreementWrapperList;
                    responseWrapper.templateMessageWrapper = templateWrapperList; 
                    if (isTemplateFound || isAgreementAdded)
                        responseWrapper.ProceedFlag = true;
                
                }
                map<String,Object> resultMap = new map<String,Object>();
                list<Object> templates = new list<Object>();
                list<Object> agreements = new list<Object>();
                for (TemplateResponseWrapper tmpl : responseWrapper.templateMessageWrapper){
                    map<String,Object> tmplMap = new map<String,Object>();
                    tmplMap.put('Product', tmpl.productName);
                    tmplMap.put('Template', tmpl.templateName);
                    tmplMap.put('Message', tmpl.message);
                    templates.add(tmplMap);
                }
                for(AgreementScheduleWrapper agmt : responseWrapper.agreementMessageWrapper){
                    map<String,Object> agmtMap = new map<String,Object>();
                    agmtMap.put('Product', agmt.productName);
                    agmtMap.put('Message', agmt.message);
                    agreements.add(agmtMap);
                }
                
                String productNamesWithoutTemplate = '';
                String productNamesWithTemplate = '';
                String productsWillNotBeAdded = '';
                String productsInQLI = '';
                
                // Put all Products under same Agreement
                if (agreements != null && agreements.size() > 0){
                    for(Object agreement: agreements){
                        if (agreement != null){
                            Map<String, Object> tmplMap = (Map<String, Object>)agreement;
                            String message = (String)tmplMap.get('Message');
                            String productName = (String)tmplMap.get('Product');
                            if (message != null && message.equals('Will not be added to Contract Document'))
                                productsWillNotBeAdded += productName + ',';
                            else if (message != null && message.equals('Enter the Agreement / Schedule Type in Quote Line Item'))
                                productsInQLI += productName + ',';
                        }
                    }
                }
                Map<String, Object> agreementFinalMap;
                List<Object> agreementFinalList = new List<Object>();
                if (productsWillNotBeAdded != null && productsWillNotBeAdded.length() > 0){
                    productsWillNotBeAdded = productsWillNotBeAdded.removeEnd(',');
                    agreementFinalMap = new Map<String, Object>();
                    agreementFinalMap.put('Message','Will not be added to Contract Document');
                    agreementFinalMap.put('Product', productsWillNotBeAdded);
                    agreementFinalList.add(agreementFinalMap);
                }
                if (productsInQLI != null && productsInQLI.length() > 0){
                    productsInQLI = productsInQLI.removeEnd(',');
                    agreementFinalMap = new Map<String, Object>();
                    agreementFinalMap.put('Message','Enter the Agreement / Schedule Type in Quote Line Item');
                    agreementFinalMap.put('Product', productsInQLI);
                    agreementFinalList.add(agreementFinalMap);
                }
                
                // Put all Products under same Template Message
                productNamesWithoutTemplate = '';
                productNamesWithTemplate = '';
                if (templates != null && templates.size() > 0){
                    for(Object template: templates){
                        if (template != null){
                            Map<String, Object> tmplMap = (Map<String, Object>)template;
                            String message = (String)tmplMap.get('Message');
                            String productName = (String)tmplMap.get('Product');
                            if (message != null && message.equals('Template not found in the rule engine. Contact CLM System Administrator'))
                                productNamesWithoutTemplate += productName + ',';
                            else if (message != null && message.equals('Template Found'))
                                productNamesWithTemplate += productName + ',';         
                        }
                    }
                }
                Map<String, Object> templateFinalMap;
                List<Object> templateFinalList = new List<Object>();
                if (productNamesWithoutTemplate != null && productNamesWithoutTemplate.length() > 0){
                    productNamesWithoutTemplate = productNamesWithoutTemplate.removeEnd(',');
                    templateFinalMap = new Map<String, Object>();
                    templateFinalMap.put('Message','Template not found in the rule engine. Contact CLM System Administrator');
                    templateFinalMap.put('Product', productNamesWithoutTemplate);
                    templateFinalList.add(templateFinalMap);
                }
                if (productNamesWithTemplate != null && productNamesWithTemplate.length() > 0){
                    productNamesWithTemplate = productNamesWithTemplate.removeEnd(',');
                    if (productsWillNotBeAdded != null && productsWillNotBeAdded.length()>0){
                        productNamesWithTemplate += ',' + productsWillNotBeAdded;
                    }
                    templateFinalMap = new Map<String, Object>();
                    templateFinalMap.put('Message','Template Found');
                    templateFinalMap.put('Product', productNamesWithTemplate);
                    resultMap.put('TemplateFound',templateFinalMap); 
                    templateFinalList.add(templateFinalMap);
                }
                
                // Final computations performed Starts
                Set<String> productsInQLISet = new Set<String>(); 
                if (productsInQLI != null || String.isNotBlank(productsInQLI)){
                    List<String> strTempList = productsInQLI.split(',');
                    if (strTempList != null && strTempList.size() > 0){
                        for(String str: strTempList)
                            productsInQLISet.add(str);
                        
                    }
                }
                
                String finalProductsWithoutTemplates = '';
                if (productNamesWithoutTemplate != null || String.isNotBlank(productNamesWithoutTemplate)){
                    List<String> strTempList = productNamesWithoutTemplate.split(',');
                    
                    if (strTempList != null && strTempList.size() > 0){
                        for(String str: strTempList){
                            if (productsInQLISet.contains(str))
                                continue;
                             else
                                 finalProductsWithoutTemplates += str;
                        }
                    }    
                }
                
                templateFinalMap = new Map<String, Object>();
                templateFinalMap.put('Message','Template not found in the rule engine. Contact CLM System Administrator');
                templateFinalMap.put('Product', finalProductsWithoutTemplates);
                
                resultMap.put('TemplateNotFound', templateFinalMap);
                //resultMap.put('UpdateAgreeSchedule', productsInQLI);
                resultMap.put('UpdateAgreeSchedule', null); //CT Edit
                resultMap.put('ProceedFlag', responseWrapper.ProceedFlag); 
                //output.put('ProceedFlag', responseWrapper.ProceedFlag);
                //output.put('TemplateResult', resultMap);
                System.debug('TemplateResult Wrapper is: ' + System.JSON.serialize(resultMap));
                return resultMap;
                // Final computations performed Ends
                
            }else if(sObjectName != null && sObjectName.equals('SterlingQuote__c')){
                List<SterlingQuoteItem__c> qliList= [Select Id, SterlingQuote__r.Id, Products__r.Id, Products__r.Name, Products__r.ProductCode, Products__r.Agreement_Type__c, Products__r.Schedule_Type__c,
                                      Agreement_Type__c,Schedule_Type__c
                                      from SterlingQuoteItem__c where SterlingQuote__r.Id =:quoteId]; // fetch all QLI for given QuoteId
                //Output.put('SterlingCheck', 'Entered SterlingCode');
                //System.debug('EnteredSterlingCode');
                Boolean isTemplateFound;
                List<TemplateResponseWrapper> templateWrapperList = new List<TemplateResponseWrapper>();
                List<AgreementScheduleWrapper> agreementWrapperList = new List<AgreementScheduleWrapper>();
                Set<String> productNameSet = new Set<String>();
                Boolean ProceedFlag = false;
                ResponseWrapper responseWrapper = new ResponseWrapper();
                
                if (qliList != null && qliList.size() > 0){
                    for(SterlingQuoteItem__c qliObj: qliList){
                        isTemplateFound = false;
                
                        String agreementType = null;
                        String scheduleType = null;
                
                        // Check if Product2.AgreementType is blank, if yes fetch from Agreement_Type__c
                        if (qliObj.Agreement_Type__c != null || String.isNotBlank(qliObj.Agreement_Type__c))
                            agreementType = qliObj.Agreement_Type__c;
                        else if(qliObj.Products__r.Id != null && qliObj.Products__r.Agreement_Type__c != null)
                            agreementType = qliObj.Products__r.Agreement_Type__c;
                        
                        // Check if Product2.Schedule_Type__c is blank, if yes fetch from Schedule_Type__c
                        if (qliObj.Schedule_Type__c != null || String.isNotBlank(qliObj.Schedule_Type__c))
                            scheduleType = qliObj.Schedule_Type__c;
                        else if (qliObj.Products__r.Id != null && qliObj.Products__r.Schedule_Type__c != null)
                            scheduleType = qliObj.Products__r.Schedule_Type__c;
                             
                        // If Product2 AgreementType and ScheduleType both are Do Not Add
                        if (/*qliObj.Product2.Id != null &&*/ agreementType != null && agreementType == 'Do Not Add' &&
                            scheduleType != null && scheduleType == 'Do Not Add'){
                            AgreementScheduleWrapper wrapperObj = new AgreementScheduleWrapper();
                            wrapperObj.productName = qliObj.Products__r.Name;
                            wrapperObj.message = 'Will not be added to Contract Document';
                            agreementWrapperList.add(wrapperObj);
                            productNameSet.add(qliObj.Products__r.Name);
                            
                        // If Product2 AgreementType and ScheduleType both are Manual    
                        }else if (/*qliObj.Product2.Id != null &&*/ agreementType != null && agreementType == 'Manual' &&
                                  scheduleType != null && scheduleType == 'Manual'){
                                  
                           AgreementScheduleWrapper wrapperObj = new AgreementScheduleWrapper();
                           wrapperObj.productName = qliObj.Products__r.Name;
                           wrapperObj.message =  'Enter the Agreement / Schedule Type in Quote Line Item'; 
                           agreementWrapperList.add(wrapperObj);
                           productNameSet.add(qliObj.Products__r.Name);
                           
                        // If Product2 AgreementType and ScheduleType both are blank/empty
                        }else if (/*qliObj.Product2.Id != null &&*/ 
                                 (agreementType == null || String.isBlank(agreementType)) ||
                                 (scheduleType == null  || String.isBlank(scheduleType))){
                                 
                           AgreementScheduleWrapper wrapperObj = new AgreementScheduleWrapper();
                           wrapperObj.productName = qliObj.Products__r.Name;
                           updateAgreeSchedule = (updateAgreeSchedule == null) ? qliObj.Products__r.Name : ',' + qliObj.Products__r.Name;
                           wrapperObj.message =  'Enter the Agreement / Schedule Type in Quote Line Item'; 
                           agreementWrapperList.add(wrapperObj); 
                           productNameSet.add(qliObj.Products__r.Name);         
                        
                        }
                        /*// If AgreementType and ScheduleType both are not-null but both arent Manual/Do Not Add
                        else if (//qliObj.Product2.Id != null && 
                                 (agreementType != null || String.isNotBlank(agreementType) && (agreementType != 'Manual' || agreementType != 'Do Not Add')) &&
                                 (scheduleType != null  || String.isNotBlank(scheduleType) && (scheduleType != 'Manual' || scheduleType != 'Do Not Add'))){
                                 
                           AgreementScheduleWrapper wrapperObj = new AgreementScheduleWrapper();
                           wrapperObj.productName = qliObj.Products__r.Name;
                           wrapperObj.message =  'Enter the Agreement / Schedule Type in Quote Line Item'; 
                           agreementWrapperList.add(wrapperObj); 
                           productNameSet.add(qliObj.Products__r.Name); 
                        }*/
                        
                        if (templateList != null && templateList.size() > 0){
                            for(Contract_Template_List__c template: templateList){
                                // If Agreement Type and ScheduleType of Product2 matches with the template record
                                if (qliObj.Products__r.Id != null && 
                                    template.Agreement_Type__c != null && template.Agreement_Type__c == agreementType && 
                                    template.Schedule_Type__c != null && template.Schedule_Type__c == scheduleType){
                                
                                    TemplateResponseWrapper wrapperObj = new TemplateResponseWrapper();
                                    wrapperObj.productName = qliObj.Products__r.Name;
                                    wrapperObj.templateName = template.Template_Name__c;
                                    wrapperObj.message = 'Template Found';
                                    isTemplateFound = true;
                                    templateWrapperList.add(wrapperObj);
                                    break;
                                }
                            }
                        }
                
                        // If Template Not found for that QLI
                        if (!isTemplateFound && AgreementType != 'Do Not Add'){
                            TemplateResponseWrapper wrapperObj = new TemplateResponseWrapper();
                            wrapperObj.productName = qliObj.Products__r.Name;
                            wrapperObj.templateName = null;
                            wrapperObj.message = 'Template not found in the rule engine. Contact CLM System Administrator';
                            templateWrapperList.add(wrapperObj);
                        }
                    }
            
                    // Final Check - If TemplateMsg has all values as ‘Will not be added to Contract Document‘ or <Template Name> (ie. Found templates for all products)
                    Boolean isTemplateMatched = true;
                    for(TemplateResponseWrapper template: templateWrapperList){
                        if (template.templateName == null){
                            isTemplateMatched = false;
                            break;
                        }
                    }
                    Boolean isAgreementAdded = false;
                    for(AgreementScheduleWrapper agree: agreementWrapperList){
                        if (agree.message == 'Will not be added to Contract Document')
                            isAgreementAdded = true;
                        else
                            isAgreementAdded = false;
                    }
            
                    responseWrapper.agreementMessageWrapper = agreementWrapperList;
                    responseWrapper.templateMessageWrapper = templateWrapperList; 
                    if (isTemplateFound || isAgreementAdded)
                        responseWrapper.ProceedFlag = true;
                
                }
                map<String,Object> resultMap = new map<String,Object>();
                list<Object> templates = new list<Object>();
                list<Object> agreements = new list<Object>();
                for (TemplateResponseWrapper tmpl : responseWrapper.templateMessageWrapper){
                    map<String,Object> tmplMap = new map<String,Object>();
                    tmplMap.put('Product', tmpl.productName);
                    tmplMap.put('Template', tmpl.templateName);
                    tmplMap.put('Message', tmpl.message);
                    templates.add(tmplMap);
                }
                for(AgreementScheduleWrapper agmt : responseWrapper.agreementMessageWrapper){
                    map<String,Object> agmtMap = new map<String,Object>();
                    agmtMap.put('Product', agmt.productName);
                    agmtMap.put('Message', agmt.message);
                    agreements.add(agmtMap);
                }
                
                String productNamesWithoutTemplate = '';
                String productNamesWithTemplate = '';
                String productsWillNotBeAdded = '';
                String productsInQLI = '';
                
                // Put all Products under same Agreement
                if (agreements != null && agreements.size() > 0){
                    for(Object agreement: agreements){
                        if (agreement != null){
                            Map<String, Object> tmplMap = (Map<String, Object>)agreement;
                            String message = (String)tmplMap.get('Message');
                            String productName = (String)tmplMap.get('Product');
                            if (message != null && message.equals('Will not be added to Contract Document'))
                                productsWillNotBeAdded += productName + ',';
                            else if (message != null && message.equals('Enter the Agreement / Schedule Type in Quote Line Item'))
                                productsInQLI += productName + ',';
                        }
                    }
                }
                Map<String, Object> agreementFinalMap;
                List<Object> agreementFinalList = new List<Object>();
                if (productsWillNotBeAdded != null && productsWillNotBeAdded.length() > 0){
                    productsWillNotBeAdded = productsWillNotBeAdded.removeEnd(',');
                    agreementFinalMap = new Map<String, Object>();
                    agreementFinalMap.put('Message','Will not be added to Contract Document');
                    agreementFinalMap.put('Product', productsWillNotBeAdded);
                    agreementFinalList.add(agreementFinalMap);
                }
                if (productsInQLI != null && productsInQLI.length() > 0){
                    productsInQLI = productsInQLI.removeEnd(',');
                    agreementFinalMap = new Map<String, Object>();
                    agreementFinalMap.put('Message','Enter the Agreement / Schedule Type in Quote Line Item');
                    agreementFinalMap.put('Product', productsInQLI);
                    agreementFinalList.add(agreementFinalMap);
                }

                // Put all Products under same Template Message
                productNamesWithoutTemplate = '';
                productNamesWithTemplate = '';
                if (templates != null && templates.size() > 0){
                    for(Object template: templates){
                        if (template != null){
                            Map<String, Object> tmplMap = (Map<String, Object>)template;
                            System.debug('tmplMap is: ' + tmplMap);
                            String message = (String)tmplMap.get('Message');
                            String productName = (String)tmplMap.get('Product');
                            if (message != null && message.equals('Template not found in the rule engine. Contact CLM System Administrator'))
                                productNamesWithoutTemplate += productName + ',';
                            else if (message != null && message.equals('Template Found'))
                                productNamesWithTemplate += productName + ',';         
                        }
                    }
                }
                Map<String, Object> templateFinalMap;
                List<Object> templateFinalList = new List<Object>();
                if (productNamesWithoutTemplate != null && productNamesWithoutTemplate.length() > 0){
                    productNamesWithoutTemplate = productNamesWithoutTemplate.removeEnd(',');
                    templateFinalMap = new Map<String, Object>();
                    templateFinalMap.put('Message','Template not found in the rule engine. Contact CLM System Administrator');
                    templateFinalMap.put('Product', productNamesWithoutTemplate);
                    templateFinalList.add(templateFinalMap);
                }
                if (productNamesWithTemplate != null && productNamesWithTemplate.length() > 0){
                    productNamesWithTemplate = productNamesWithTemplate.removeEnd(',');
                    if (productsWillNotBeAdded != null && productsWillNotBeAdded.length()>0){
                        productNamesWithTemplate += ',' + productsWillNotBeAdded;
                    }
                    templateFinalMap = new Map<String, Object>();
                    templateFinalMap.put('Message','Template Found');
                    templateFinalMap.put('Product', productNamesWithTemplate);
                    resultMap.put('TemplateFound',templateFinalMap);
                    templateFinalList.add(templateFinalMap);
                }
                
                // Final computations performed Starts
                Set<String> productsInQLISet = new Set<String>(); 
                if (productsInQLI != null || String.isNotBlank(productsInQLI)){
                    List<String> strTempList = productsInQLI.split(',');
                    if (strTempList != null && strTempList.size() > 0){
                        for(String str: strTempList)
                            productsInQLISet.add(str);
                        
                    }
                }
                
                String finalProductsWithoutTemplates = '';
                if (productNamesWithoutTemplate != null || String.isNotBlank(productNamesWithoutTemplate)){
                    List<String> strTempList = productNamesWithoutTemplate.split(',');
                    
                    if (strTempList != null && strTempList.size() > 0){
                        for(String str: strTempList){
                            if (productsInQLISet.contains(str))
                                continue;
                             else
                                 finalProductsWithoutTemplates += str;
                        }
                    }    
                }
                
                templateFinalMap = new Map<String, Object>();
                templateFinalMap.put('Message','Template not found in the rule engine. Contact CLM System Administrator');
                templateFinalMap.put('Product', finalProductsWithoutTemplates);
                
                resultMap.put('TemplateNotFound', templateFinalMap);
                resultMap.put('UpdateAgreeSchedule', productsInQLI);
                resultMap.put('ProceedFlag', responseWrapper.ProceedFlag); 
                //output.put('ProceedFlag', responseWrapper.ProceedFlag);
                //output.put('TemplateResult', resultMap);
                System.debug('TemplateResult Wrapper is: ' + System.JSON.serialize(resultMap));
                return resultMap;
                // Final computations performed Ends
                
            }
        }
      }catch(Exception ex){
          output.put('ExceptionMessage', ex.getMessage());
          output.put('LineNumber', ex.getLineNumber());
          output.put('StackTraceString', ex.getStackTraceString());
          output.put('TypeName', ex.getTypeName());
      }
      return null;
   }
    
    
    public static /*void*/ List<vlocity_cmt__ContractVersion__c> createContracts(Map<String, Object> input, Map<String, Object> output,  Map<String, Object> options){
      try{
        String accountId = (String)input.get('AccountId');
        String quoteId = (String) input.get('quoteId');
        Integer contractTerm = Integer.valueOf(input.get('ContractTerm'));
        String signingOrder = (String) input.get('SigningOrder');
        Date contractStartDate = Date.valueOf(input.get('ContractStartDate'));
        Set<String> templateNameSet = new Set<String>();
        List<QuoteLineItem> matchedQLIList = new List<QuoteLineItem>();
        List<SterlingQuoteItem__c> matchedSterlingQLIList = new List<SterlingQuoteItem__c>();
        
        String agreementType = null;
        String scheduleType = null;
        Integer serviceTerm = null;
        String opptyId = null;
        // For every unique Contract Template found, create new Contract records
        List<Contract> contractListToInsert = new List<Contract>();
        
        if (quoteId != null || String.isNotBlank(quoteId)){
            CreateContactResponseWrapper responseWrapper = new CreateContactResponseWrapper();
            // Query the Custom Settings - Contract Templates List
            List<Contract_Template_List__c> templateList = [Select Id, Name,Template_Name__c,Agreement_Type__c,Schedule_Type__c FROM Contract_Template_List__c];
            
            String sObjectName = getSObjectType(quoteId);
            // sObjectName = 'SterlingQuote__c'
            if (sObjectName != null && sObjectName.equals('Quote')){
                List<vlocity_cmt__ContractVersion__c> contractVersionList = ftr_CLMCreateContractFromQuotes.getContractVersion(quoteId, accountId, null,signingOrder);
                
                /* Quote quoteObj = [Select Id, Service_Term__c,Opportunity.Id, Account.Federal__c, Account.Id, Account.Name,Account.BillingAddress, Account.ShippingAddress, QuoteNumber, 
                                 Account.BillingStreet, Account.BillingCity, Account.BillingStateCode, Account.BillingState, Account.BillingPostalCode, Account.BillingCountryCode, Account.BillingCountry,
                                 Account.ShippingStreet, Account.ShippingCity,Account.ShippingStateCode, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountryCode, Account.ShippingCountry
                                 from Quote where Id=:quoteId LIMIT 1];
                if (quoteObj != null){
                    accountId = quoteObj.Account.Id;
                    opptyId = quoteObj.Opportunity.Id;
                    if (quoteObj.Service_Term__c != null || String.isNotBlank(quoteObj.Service_Term__c)){
                        List<String> serviceTermTemp = quoteObj.Service_Term__c.split(' ');
                        if (serviceTermTemp != null && serviceTermTemp.size() > 0){
                            String tempStr = serviceTermTemp[0];
                            serviceTerm = Integer.valueOf(tempStr);
                        }
                    }
                
                }
                List<QuoteLineItem> qliList= [Select Id,Quantity, Quote.Service_Term__c, Quote.Account.Id, Quote.Account.Name, Quote.Id, Quote.QuoteNumber, Product2.Id, Product2.Name, Product2.ProductCode, Product2.Agreement_Type__c, Product2.Schedule_Type__c,
                                          Agreement_Type__c,Schedule_Type__c,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__RecurringCharge__c
                                          from QuoteLineItem where Quote.Id =:quoteId]; // fetch all QLI for given QuoteId
               
                Map<String, String> templateAgreementScheduleTypeMap = new Map<String, String>();
                if (qliList != null && qliList.size() > 0){
                    for(QuoteLineItem qliObj: qliList){
                    
                        // Check if Product2.AgreementType is blank, if yes fetch from Agreement_Type__c
                        if (qliObj.Agreement_Type__c != null || String.isNotBlank(qliObj.Agreement_Type__c))
                            agreementType = qliObj.Agreement_Type__c;
                        else if (qliObj.Product2.Id != null && qliObj.Product2.Agreement_Type__c != null)
                            agreementType = qliObj.Product2.Agreement_Type__c; 
                    
                        // Check if Product2.Schedule_Type__c is blank, if yes fetch from Schedule_Type__c
                        if (qliObj.Schedule_Type__c != null || String.isNotBlank(qliObj.Schedule_Type__c))
                            scheduleType = qliObj.Schedule_Type__c;
                        else if (qliObj.Product2.Id != null && qliObj.Product2.Schedule_Type__c != null)
                            scheduleType = qliObj.Product2.Schedule_Type__c;
                        
                        // If Product2 AgreementType and ScheduleType both are not Do Not Add
                        if (agreementType != null && agreementType != 'Do Not Add' && scheduleType != null && scheduleType != 'Do Not Add'){
                            if (templateList != null && templateList.size() > 0){
                                for(Contract_Template_List__c template: templateList){
                                    if (qliObj.Product2.Id != null && 
                                        template.Agreement_Type__c != null && template.Agreement_Type__c == agreementType && 
                                        template.Schedule_Type__c != null && template.Schedule_Type__c == scheduleType){
                                        
                                        templateAgreementScheduleTypeMap.put(template.Template_Name__c, agreementType + ',' +  scheduleType);                       
                                        templateNameSet.add(template.Template_Name__c);
                                        matchedQLIList.add(qliObj);        
                                    }
                                }
                            } 
                        }
                    }
                }
            
                System.debug('Unique Templates Found: '+ templateNameSet);
                System.debug('Matched QuoteLineItems are: '+ matchedQLIList);
                System.debug('templateAgreementScheduleTypeMap for Quote sObject: ' + templateAgreementScheduleTypeMap);
                
                for(String templateObj: templateAgreementScheduleTypeMap.keySet()){
                    Contract contractNew = new Contract();
                    contractNew.AccountId = accountId;
                    contractNew.Name = (quoteObj != null && quoteObj.Account.Federal__c ? (quote.Account.Name + quoteObj.Account.ShippingStreet) : null);
                    contractNew.StartDate = contractStartDate;
                    contractNew.Status = 'Draft';
                    //contractNew.OwnerExpirationNotice = '15 Days';
                    contractNew.OwnerExpirationNotice = '15';
                    contractNew.Document_Status__c = 'Document Generated';
                    contractNew.Template_Name__c = templateObj;
                    String mapValue = templateAgreementScheduleTypeMap.get(templateObj);
                    if (mapValue != null){
                        List<String> tempList = mapValue.split(',');
                        contractNew.Agreement_Type__c = ((tempList != null && tempList.size() > 0 && tempList[0] != null) ? tempList[0] : null);
                        contractNew.Schedule_Type__c = ((tempList != null && tempList.size() > 0 && tempList[1] != null) ? tempList[1] : null);
                    }
                    contractNew.vlocity_cmt__QuoteId__c = quoteId;
                    contractNew.Quote_Sterling__c = null;
                    contractNew.ContractTerm = contractTerm;
                    contractNew.Verified_Contract_End_Date__c = System.Today().addMonths(contractTerm);
                    contractNew.Opportunity__c = opptyId;
                    contractNew.vlocity_cmt__OpportunityId__c = opptyId;
                    contractNew.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Product Schedule').getRecordTypeId();
                    
                    contractNew.BillingStreet = (quoteObj != null ? quoteObj.Account.BillingStreet : null);
                    contractNew.BillingCity =   (quoteObj != null ? quoteObj.Account.BillingCity : null);
                    contractNew.BillingState = (quoteObj != null ? quoteObj.Account.BillingState : null);
                    contractNew.BillingStateCode = (quoteObj != null ? quoteObj.Account.BillingStateCode : null);
                    contractNew.BillingPostalCode = (quoteObj != null ? quoteObj.Account.BillingPostalCode : null);
                    contractNew.BillingCountry = (quoteObj != null ? quoteObj.Account.BillingCountry : null);
                    contractNew.BillingCountryCode = (quoteObj != null ? quoteObj.Account.BillingCountryCode : null);
                    contractNew.ShippingStreet = (quoteObj != null ? quoteObj.Account.ShippingStreet : null);
                    contractNew.ShippingCity =   (quoteObj != null ? quoteObj.Account.ShippingCity : null);
                    contractNew.ShippingState = (quoteObj != null ? quoteObj.Account.ShippingState : null);
                    contractNew.ShippingStateCode = (quoteObj != null ? quoteObj.Account.ShippingStateCode : null);
                    contractNew.ShippingPostalCode = (quoteObj != null ? quoteObj.Account.ShippingPostalCode : null);
                    contractNew.ShippingCountry = (quoteObj != null ? quoteObj.Account.ShippingCountry : null);
                    contractNew.ShippingCountryCode = (quoteObj != null ? quoteObj.Account.ShippingCountryCode : null);
                    
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
                    
                    contractListToInsert.add(contractNew);
                }
                if (contractListToInsert.size() > 0)    insert contractListToInsert;
                System.debug('Newly Inserted Contracts for Quote sObject: ' + contractListToInsert);
                
                // Creating the ContractVersions for newly inserted Contracts
                Map<String, String> contractTemplateMap = new Map<String, String>();
                List<vlocity_cmt__ContractVersion__c> contractVersionList = new List<vlocity_cmt__ContractVersion__c>();
                if (contractListToInsert != null && contractListToInsert.size() > 0){
                    for(Contract con: contractListToInsert){
                        contractTemplateMap.put(con.Id, con.Agreement_Type__c + ';' + con.Schedule_Type__c);
                    
                        vlocity_cmt__ContractVersion__c conVerRec = new vlocity_cmt__ContractVersion__c();
                        conVerRec.Name = 'Version1';
                        conVerRec.vlocity_cmt__Type__c = con.Agreement_Type__c;
                        conVerRec.vlocity_cmt__ContractId__c = con.Id;
                        String templateName;
                        if (Test.isRunningTest()){
                            templateName = 'Fiber and OneVoice Schedule';
                        }else{
                            templateName = getTemplateName(con.Agreement_Type__c, con.Schedule_Type__c);
                            //if (templateName == 'FSA_Standard') templateName = 'FSA_Standard_Word';
                        }
                        conVerRec.vlocity_cmt__DocumentTemplateId__c = getContractTemplateId(templateName);   
                        contractVersionList.add(conVerRec);
                    }
                }
                System.debug('contractTemplateMap: ' + contractTemplateMap);
                
                if (contractVersionList.size() > 0)    insert contractVersionList;
                System.debug('contractVersionList for Quote: '+ contractVersionList);
                
                if (contractVersionList != null && contractVersionList.size() > 0){
                    for(vlocity_cmt__ContractVersion__c conVersion: contractVersionList){
                        generateContract(conVersion.Id);
                    }
                }
                
                // For each Contracts created stamp the ContractLineItem
                List<vlocity_cmt__ContractLineItem__c> cliToInsert = new List<vlocity_cmt__ContractLineItem__c>();
                for(Contract con: contractListToInsert){
                    if (matchedQLIList != null && matchedQLIList.size() > 0){
                        for(QuoteLineItem qli: matchedQLIList){
                            //set Agreement/Schedule types equal to Line Item value if not null. If null, sets equal to Product's Agreement/Schedule
                            string qliAgreementType = (qli.Agreement_Type__c != null) ? qli.Agreement_Type__c : qli.Product2.Agreement_Type__c;
                            string qliScheduleType = (qli.Schedule_Type__c != null) ? qli.Schedule_Type__c : qli.Product2.Schedule_Type__c;
                            
                            //if(con.Template_Name__c == getTemplateName(qliAgreementType, qliScheduleType)){
                            if(con.Agreement_Type__c == qliAgreementType && con.Schedule_Type__c == qliScheduleType){
                                vlocity_cmt__ContractLineItem__c cliTemp = new vlocity_cmt__ContractLineItem__c();
                                cliTemp.vlocity_cmt__ContractId__c = con.Id;
                                cliTemp.vlocity_cmt__QuoteLineItem__c = qli.Id;
                                cliTemp.vlocity_cmt__Product2Id__c = qli.Product2.Id;
                                cliTemp.vlocity_cmt__Quantity__c = qli.Quantity;
                                cliTemp.vlocity_cmt__OneTimeCharge__c = qli.vlocity_cmt__OneTimeCharge__c;
                                cliTemp.vlocity_cmt__OneTimeTotal__c = qli.Quantity * qli.vlocity_cmt__OneTimeCharge__c;
                                cliTemp.vlocity_cmt__RecurringCharge__c = qli.vlocity_cmt__RecurringCharge__c;
                                cliTemp.vlocity_cmt__RecurringTotal__c  = qli.Quantity * qli.vlocity_cmt__RecurringCharge__c; //CT Added
                                cliTemp.vlocity_cmt__EffectiveStartDate__c  = contractStartDate.addDays(1);
                                cliToInsert.add(cliTemp);
                            }
                            
                        }
                    }
                }
                
                if (cliToInsert.size() > 0)    insert cliToInsert;
                System.debug('Newly inserted ContractLineItem for Quote sObject: ' + cliToInsert);
                
                /* Set<Id> newContractIdSet = new Set<Id>();
                responseWrapper.NewContracts = contractListToInsert;
                if (contractListToInsert != null && contractListToInsert.size() > 0){
                    for(Contract con: contractListToInsert)
                        newContractIdSet.add(con.Id);
                }
                List<Contract> templateContractList = [Select Id, Template_Name__c from Contract where Id IN: (newContractIdSet)];
                Map<String, String> tempContractTemplateMap = new Map<String, String>();
                for(Contract c:templateContractList)
                    tempContractTemplateMap.put(c.Id, c.Template_Name__c); 
                
                responseWrapper.contractTemplateMap = tempContractTemplateMap;
                System.debug('JSON Response Wrapper in Create Contracts (Quote) : ' + System.JSON.serialize(responseWrapper)); */
                
                return contractVersionList;
                
            }// sObjectName = 'SterlingQuote__c'
            else if (sObjectName != null && sObjectName.equals('SterlingQuote__c')){
                
                SterlingQuote__c quoteObj = [Select Id,OpportunityId__c, OpportunityId__r.Id, OpportunityId__r.Name, Account_Name__r.Federal__c, Account_Name__c, Account_Name__r.Id, Account_Name__r.Name, CPQQuoteId__c ,
                                             Account_Name__r.BillingStreet, Account_Name__r.BillingCity, Account_Name__r.BillingState,Account_Name__r.BillingStateCode, Account_Name__r.BillingPostalCode, Account_Name__r.BillingCountry,Account_Name__r.BillingCountryCode,
                                             Account_Name__r.ShippingStreet, Account_Name__r.ShippingCity, Account_Name__r.ShippingState,Account_Name__r.ShippingStateCode, Account_Name__r.ShippingPostalCode, Account_Name__r.ShippingCountry, Account_Name__r.ShippingCountryCode
                                             from SterlingQuote__c where IsSyncing__c = true AND Id=:quoteId LIMIT 1];
                if (quoteObj != null){
                    accountId = quoteObj.Account_Name__c;
                    opptyId = quoteObj.OpportunityId__r.Id;
                    output.put('TestOpptyId', opptyId);
                    // Check for existing Contract for given QuoteId -> If Contract Status = Draft -> update to Cancelled
                    List<Contract> cancelledContractList = new List<Contract>();
                    List<Contract> draftContractList = [Select Id, Status, vlocity_cmt__QuoteId__c, vlocity_cmt__QuoteId__r.Id, Quote_Sterling__c, Quote_Sterling__r.Id from Contract where (Status = 'Draft' OR Contract_Status__c = 'Draft') AND Quote_Sterling__r.Id=:quoteId];
                    System.debug('Existing Sterling Contracts in Draft Status: ' + draftContractList);
                    if (draftContractList != null && draftContractList.size() > 0){
                        for(Contract con: draftContractList){
                            con.Status = 'Cancelled';
                            con.Contract_Status__c = 'Cancelled';
                            cancelledContractList.add(con);
                        }
                    }
                    if (cancelledContractList.size() > 0)    update cancelledContractList;
                    System.debug('Updated Sterling Contracts in Cancelled Status: ' + cancelledContractList);
                }
                
                List<SterlingQuoteItem__c> qliList = [Select Id, Agreement_Type__c, Schedule_Type__c, Quantity__c, SterlingQuote__r.Account_Name__r.Id, SterlingQuote__r.Account_Name__r.Name, SterlingQuote__r.Id,
                     Products__r.Id, Products__r.Name, Products__r.ProductCode, Products__r.Agreement_Type__c, Products__r.Schedule_Type__c, AdjustedMRC__c, AdjustedNRC__c
                     from SterlingQuoteItem__c where SterlingQuote__r.Id =:quoteId];
                
                Map<String, String> templateAgreementScheduleTypeMap = new Map<String, String>();
                if (qliList != null && qliList.size() > 0){
                    for(SterlingQuoteItem__c qliObj: qliList){
                        // Check if Product2.AgreementType is blank, if yes fetch from Agreement_Type__c
                        if (qliObj.Agreement_Type__c != null || String.isNotBlank(qliObj.Agreement_Type__c))
                            agreementType = qliObj.Agreement_Type__c;
                        else if (qliObj.Products__r.Id != null && qliObj.Products__r.Agreement_Type__c != null)
                            agreementType = qliObj.Products__r.Agreement_Type__c;
                            
                        // Check if Product2.Schedule_Type__c is blank, if yes fetch from Schedule_Type__c
                        if (qliObj.Schedule_Type__c != null || String.isNotBlank(qliObj.Schedule_Type__c))
                            scheduleType = qliObj.Schedule_Type__c;
                        else if (qliObj.Products__r.Id != null && qliObj.Products__r.Schedule_Type__c != null)
                            scheduleType = qliObj.Products__r.Schedule_Type__c;
                            
                        // If Product2 AgreementType and ScheduleType both are not Do Not Add
                        if (/*qliObj.Product2.Id != null &&*/ agreementType != null && agreementType != 'Do Not Add' && scheduleType != null && scheduleType != 'Do Not Add'){
                            if (templateList != null && templateList.size() > 0){
                                for(Contract_Template_List__c template: templateList){
                                    if (qliObj.Products__r.Id != null && 
                                        template.Agreement_Type__c != null && template.Agreement_Type__c == agreementType && 
                                        template.Schedule_Type__c != null && template.Schedule_Type__c == scheduleType){
                                        
                                        templateAgreementScheduleTypeMap.put(template.Template_Name__c, agreementType + ',' + scheduleType);
                                        templateNameSet.add(template.Template_Name__c);
                                        matchedSterlingQLIList.add(qliObj);        
                                    }
                                }
                            } 
                        }    
                    }
                }
                System.debug('templateAgreementScheduleTypeMap in SterlingQuote sObject is: '+ templateAgreementScheduleTypeMap);
                System.debug('Unique Templates Found: '+ templateNameSet);
                System.debug('Matched QuoteLineItems are: '+ matchedSterlingQLIList);
                
                for(String templateObj: templateAgreementScheduleTypeMap.keySet()){
                    Contract contractNew = new Contract();
                    contractNew.AccountId = accountId;
                    contractNew.Name = (quoteObj != null && quoteObj.Account_Name__r.Federal__c ? (quote.Account_Name__r.Name + quoteObj.Account_Name__r.ShippingStreet) : null);
                    contractNew.StartDate = contractStartDate;
                    contractNew.Status = 'Draft';
                    contractNew.Contract_Status__c = 'Draft';
                    //contractNew.OwnerExpirationNotice = '15 Days';
                    contractNew.OwnerExpirationNotice = '15';
                    contractNew.Document_Status__c = 'Document Generated';
                    Contract FSAContract = ftr_CLMContractCreation.getFSAContract(accountId);
                     if (FSAContract != null)
                        contractNew.FSA__c = FSAContract.Id; 
                    
                    contractNew.Template_Name__c = templateObj;
                    String mapValue = templateAgreementScheduleTypeMap.get(templateObj);
                    if (mapValue != null){
                        List<String> tempList = mapValue.split(',');
                        contractNew.Agreement_Type__c = ((tempList != null && tempList.size() > 0 && tempList[0] != null) ? tempList[0] : null);
                        contractNew.Schedule_Type__c = ((tempList != null && tempList.size() > 0 && tempList[1] != null) ? tempList[1] : null);
                    }
                    
                    contractNew.vlocity_cmt__QuoteId__c = null;
                    contractNew.Quote_Sterling__c = quoteId;
                    contractNew.Opportunity__c = opptyId;
                    contractNew.vlocity_cmt__OpportunityId__c = opptyId;
                    contractNew.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Product Schedule').getRecordTypeId();
                    contractNew.Contract_Status__c = 'Draft';
                    contractNew.ContractTerm = contractTerm; 
                    contractNew.CLM_Signing_Order__c = signingOrder; 
                    contractNew.Verified_Contract_End_Date__c = System.Today().addMonths(contractTerm); 
                    
                    contractNew.BillingStreet = (quoteObj != null ? quoteObj.Account_Name__r.BillingStreet : null);
                    contractNew.BillingCity =   (quoteObj != null ? quoteObj.Account_Name__r.BillingCity : null);
                    contractNew.BillingState = (quoteObj != null ? quoteObj.Account_Name__r.BillingState : null);
                    contractNew.BillingStateCode = (quoteObj != null ? quoteObj.Account_Name__r.BillingStateCode : null);
                    contractNew.BillingPostalCode = (quoteObj != null ? quoteObj.Account_Name__r.BillingPostalCode : null);
                    contractNew.BillingCountry = (quoteObj != null ? quoteObj.Account_Name__r.BillingCountry : null);
                    contractNew.BillingCountryCode = (quoteObj != null ? quoteObj.Account_Name__r.BillingCountryCode : null);
                    contractNew.ShippingStreet = (quoteObj != null ? quoteObj.Account_Name__r.ShippingStreet : null);
                    contractNew.ShippingCity =   (quoteObj != null ? quoteObj.Account_Name__r.ShippingCity : null);
                    contractNew.ShippingState = (quoteObj != null ? quoteObj.Account_Name__r.ShippingState : null);
                    contractNew.ShippingStateCode = (quoteObj != null ? quoteObj.Account_Name__r.ShippingStateCode : null);
                    contractNew.ShippingPostalCode = (quoteObj != null ? quoteObj.Account_Name__r.ShippingPostalCode : null);
                    contractNew.ShippingCountry = (quoteObj != null ? quoteObj.Account_Name__r.ShippingCountry : null);
                    contractNew.ShippingCountryCode = (quoteObj != null ? quoteObj.Account_Name__r.ShippingCountryCode : null);
                    
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
                    contractListToInsert.add(contractNew);
                }
                
                if (contractListToInsert.size() > 0)    insert contractListToInsert;
                System.debug('contractListToInsert for SterlingQuote is: '+ contractListToInsert);
                Set<Id> contractIdSet = new Set<Id>();
                if (contractListToInsert != null && contractListToInsert.size() > 0){
                    for(Contract con: contractListToInsert){
                        contractIdSet.add(con.Id);
                    }
                }
                List<vlocity_cmt__ContractVersion__c> conVersionList = [Select Id, Name, vlocity_cmt__Type__c, vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.Agreement_Type__c,vlocity_cmt__ContractId__r.Schedule_Type__c, vlocity_cmt__ContractId__r.Id, vlocity_cmt__DocumentTemplateId__c, vlocity_cmt__DocumentTemplateId__r.Id
                                                                        FROM  vlocity_cmt__ContractVersion__c where vlocity_cmt__ContractId__r.Id IN: (contractIdSet)];
                List<vlocity_cmt__ContractVersion__c> contractVersionList = new List<vlocity_cmt__ContractVersion__c>();
                for(vlocity_cmt__ContractVersion__c conVerRec: conVersionList){
                    //conVerRec.Name = 'Version1';
                    conVerRec.vlocity_cmt__Type__c = conVerRec.vlocity_cmt__ContractId__r.Agreement_Type__c;
                    String templateName = getTemplateName(conVerRec.vlocity_cmt__ContractId__r.Agreement_Type__c, conVerRec.vlocity_cmt__ContractId__r.Schedule_Type__c);
                    System.debug('TemplateName in SterlingQuote is: '+ templateName);
                    conVerRec.vlocity_cmt__DocumentTemplateId__c = ftr_CLMContractCreation.getContractTemplateId(templateName);
                    contractVersionList.add(conVerRec);
                }
                if (contractVersionList.size() > 0)    update contractVersionList;
                 
                // Creating the ContractVersions for newly inserted Contracts
                /* Map<String, String> contractTemplateMap = new Map<String, String>();
                List<vlocity_cmt__ContractVersion__c> contractVersionList = new List<vlocity_cmt__ContractVersion__c>();
                if (contractListToInsert != null && contractListToInsert.size() > 0){
                    for(Contract con: contractListToInsert){
                        contractTemplateMap.put(con.Id, con.Agreement_Type__c + ';' + con.Schedule_Type__c);
                    
                        vlocity_cmt__ContractVersion__c conVerRec = new vlocity_cmt__ContractVersion__c();
                        conVerRec.Name = 'Version1';
                        conVerRec.vlocity_cmt__Type__c = con.Agreement_Type__c;
                        conVerRec.vlocity_cmt__ContractId__c = con.Id;
                        String templateName;
                        if (Test.isRunningTest()){
                            templateName = 'Fiber and OneVoice Schedule';
                        }else{
                            templateName = getTemplateName(con.Agreement_Type__c, con.Schedule_Type__c);
                            //if (templateName == 'FSA_Standard') templateName = 'FSA_Standard_Word';
                        }
                        
                        conVerRec.vlocity_cmt__DocumentTemplateId__c = getContractTemplateId(templateName);   
                        contractVersionList.add(conVerRec);
                    }
                }*/
                
                //System.debug('contractTemplateMap: ' + contractTemplateMap);
                //if (contractVersionList.size() > 0)    insert contractVersionList;
                System.debug('contractVersionList for SterlingQuote: '+ contractVersionList);
                
                if (contractVersionList != null && contractVersionList.size() > 0){
                    for(vlocity_cmt__ContractVersion__c conVersion: contractVersionList){
                        generateContract(conVersion.Id);
                    }
                }
                
                // For each Contracts created stamp the ContractLineItem
                List<vlocity_cmt__ContractLineItem__c> cliToInsert = new List<vlocity_cmt__ContractLineItem__c>();
                for(Contract con: contractListToInsert){
                    if (matchedSterlingQLIList != null && matchedSterlingQLIList.size() > 0){
                        for(SterlingQuoteItem__c qli: matchedSterlingQLIList){
                            //set Agreement/Schedule types equal to Line Item value if not null. If null, sets equal to Product's Agreement/Schedule
                            string qliAgreementType = (qli.Agreement_Type__c != null) ? qli.Agreement_Type__c : qli.Products__r.Agreement_Type__c;
                            string qliScheduleType = (qli.Schedule_Type__c != null) ? qli.Schedule_Type__c : qli.Products__r.Schedule_Type__c;
                            
                            //if(con.Template_Name__c == getTemplateName(qliAgreementType, qliScheduleType)){
                            if(con.Agreement_Type__c == qliAgreementType && con.Schedule_Type__c == qliScheduleType){
                                vlocity_cmt__ContractLineItem__c cliTemp = new vlocity_cmt__ContractLineItem__c();
                                cliTemp.vlocity_cmt__ContractId__c = con.Id;
                                cliTemp.SterlingQuoteLineItem__c = qli.Id;
                                cliTemp.vlocity_cmt__Product2Id__c = qli.Products__r.Id;
                                cliTemp.vlocity_cmt__Quantity__c = qli.Quantity__c;
                                cliTemp.vlocity_cmt__OneTimeCharge__c = qli.AdjustedNRC__c;
                                cliTemp.vlocity_cmt__OneTimeTotal__c  = qli.Quantity__c * qli.AdjustedNRC__c;
                                cliTemp.vlocity_cmt__RecurringCharge__c = qli.AdjustedMRC__c;
                                cliTemp.vlocity_cmt__RecurringTotal__c  = qli.Quantity__c * qli.AdjustedMRC__c; //CT Added
                                cliTemp.vlocity_cmt__EffectiveStartDate__c  = contractStartDate.addDays(1);
                                cliToInsert.add(cliTemp);
                            }
                        }
                    }
                }
                if (cliToInsert.size() > 0)    insert cliToInsert;
                System.debug('ContractLineItem for SterlingQuote is: '+ cliToInsert);
                
                /* output.put('NewContracts', contractListToInsert);
                Set<Id> newContractIdSet = new Set<Id>();
                responseWrapper.NewContracts = contractListToInsert;
                if (contractListToInsert != null && contractListToInsert.size() > 0){
                    for(Contract con: contractListToInsert)
                        newContractIdSet.add(con.Id);
                }
                List<Contract> templateContractList = [Select Id, Template_Name__c from Contract where Id IN: (newContractIdSet)];
                Map<String, String> tempContractTemplateMap = new Map<String, String>();
                for(Contract c:templateContractList)
                    tempContractTemplateMap.put(c.Id, c.Template_Name__c); 
                
                responseWrapper.contractTemplateMap = tempContractTemplateMap;
                System.debug('JSON Response Wrapper in Create Contracts (Quote) : ' + System.JSON.serialize(responseWrapper)); */   
                return contractVersionList;
            }
        }
        
      }catch(Exception ex){
          output.put('ExceptionMessage', ex.getMessage());
          output.put('LineNumber', ex.getLineNumber());
          output.put('StackTraceString', ex.getStackTraceString());
          output.put('TypeName', ex.getTypeName());
      }
      return null;
    }
    
    public static String getTemplateName(final String agreementType, final String scheduleType){
        if (agreementType != null && scheduleType != null){
            List<Contract_Template_List__c> templateObj = [Select Id, Name,Template_Name__c,Agreement_Type__c,Schedule_Type__c FROM Contract_Template_List__c where Agreement_Type__c=:agreementType AND Schedule_Type__c=:scheduleType LIMIT 1];
            if (templateObj != null && templateObj.size() > 0)   {
                System.debug('ftr_CLMContractCreation.getTemplateName.Template Name: ' + templateObj[0].Template_Name__c);
                return templateObj[0].Template_Name__c;
             }else
                 return 'No Such Template Found in Rule Engine. Please contact your system administrator for assistance';
        }
        return null;
    }
    
    public static String getContractTemplateId(final String templateName){
        if (templateName != null && String.isNotBlank(templateName)){
            return [select Id from vlocity_cmt__DocumentTemplate__c where vlocity_cmt__IsActive__c = true AND Name=:templateName LIMIT 1].Id;
        }
        return null;
    }
    
    public static void generateContract(final String contractVersionId){
        // Code goes here.....
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
    
    
    public static String getSObjectType(final Id recordId){
        String sobjectType = recordId.getSObjectType().getDescribe().getName();
        return sobjectType;
    }
    
    public class ResponseWrapper{
        public List<AgreementScheduleWrapper> agreementMessageWrapper;
        public List<TemplateResponseWrapper> templateMessageWrapper;
        public Boolean ProceedFlag{get; set;}
    }
    
    public class CreateContactResponseWrapper{
        public List<Contract> NewContracts{get; set;}
        public Map<String, String> contractTemplateMap = new Map<String, String>();
    }
    
    public class AgreementScheduleWrapper{
        public String productName{get; set;}
        public String message{get; set;}
    }
    
    public class TemplateResponseWrapper{
        public String productName{get; set;}
        public String templateName{get; set;}
        public String message{get; set;}
    }
}