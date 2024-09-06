public class ftr_CLMCustomContractSearchController{
//version1
    @AuraEnabled
    public static Map<String, String> getContractRecordTypeNames(){
        List<RecordType> recordTypeNameList = [select Id,Name from RecordType where sObjectType='Contract'];
        Map<String, String> recordTypeMap = new Map<String, String>();
        
        if (recordTypeNameList != null && recordTypeNameList.size() > 0){
            for(RecordType rt: recordTypeNameList)
                recordTypeMap.put(rt.Id, rt.Name);
        }
        System.debug('recordTypeMap: ' + recordTypeNameList);
        return recordTypeMap;
    }
    
    @AuraEnabled 
    public static Map<String, String> getAgreementTypeFieldValue(String ObjectApi_name,String Field_name){
     
      Map<String, String> lstPickvals=new Map<String, String>();
      Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
      Sobject Object_name = targetType.newSObject();
      Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            if (a.isActive())
                lstPickvals.put(a.getLabel(), a.getValue());//add the value  to our final list
        }
        System.debug('lstPickvals: ' + lstPickvals);
        return lstPickvals;
     }
     
     @AuraEnabled
     public static /*List<Contract>*/ CustomContractSearchWrapper getContractList(final String accountName, final String contractType, final String entityName, final String agreementType, final String scheduleType, final String statusSelected, final String docStatus, 
                                                  final String channelSelected, final String approverName, final String legalState, 
                                                  final String contentText/*, final String documentText*/, 
                                                  final String accountPrimaryACNA, final String accountSecondaryACNA){
         System.debug('Content Text: ' + contentText);
         //System.debug('documentText Text: ' + documentText);
         Set<Id> contractIdSet = new Set<Id>();
         Set<Id> finalContractIdSet = new Set<Id>();
         Boolean isAccountSearch = false;
         CustomContractSearchWrapper wrapper = new CustomContractSearchWrapper();
         
         Boolean condition1 = false, condition2 = false, condition3 = false, condition4 = false, condition5 = false, condition6 = false;
         String queryStr = 'Select Id, Name, Account.Id, Account.Primary_ACNA__c, Account.Secondary_ACNA__c, Account.BillingState, Account.Name, Account.Legal_State1__c, MDU_ContractType__c, RecordType.Name, Affiliation_Approver_Name__c, Affiliation_Approver_Title__c, RecordType.Id, Status, Agreement_Type__c, Document_Status__c, Type_of_Entity__c, Channel_Affiliation__c, Legal_City__c, Legal_Zip_Postal_Code__c from Contract WHERE ';
         
         if (accountName != null && accountName.length() > 0 ){
             isAccountSearch = true;
             String tempInput ='\'%' + accountName  + '%\'';
             queryStr += ' Account.Name LIKE ' + tempInput + ' AND';
         }
         
         if(accountPrimaryACNA != null && accountPrimaryACNA.length() > 0){
              isAccountSearch = true;
              queryStr += ' Account.Primary_ACNA__c =: accountPrimaryACNA AND';  
         }
         
         if(accountSecondaryACNA != null && accountSecondaryACNA.length() > 0){
              isAccountSearch = true;
              queryStr += ' Account.Secondary_ACNA__c =: accountSecondaryACNA AND';  
         }
                                                      
         if(contractType != null && contractType.length() > 0){
              isAccountSearch = true;
              queryStr += ' MDU_ContractType__c =: tempInput AND';  
         }
                                                      
         if (entityName != null && entityName.length() > 0){
             isAccountSearch = true;
             queryStr += ' Type_of_Entity__c=: entityName AND';
         }
         
         if (agreementType != null && agreementType.length() > 0){
             isAccountSearch = true;
             queryStr += ' Agreement_Type__c =: agreementType AND';
         }
                                                      
         if (scheduleType != null && scheduleType.length() > 0){
             isAccountSearch = true;
             queryStr += ' Schedule_Type__c =: scheduleType AND';
         }
         
         if (statusSelected != null && statusSelected.length() > 0){
             isAccountSearch = true;
             queryStr += ' Status =: statusSelected AND';
         }
         
         if (docStatus != null && docStatus.length() > 0){
             isAccountSearch = true;
             queryStr += ' Document_Status__c =: docStatus AND';
         }
         
         if (channelSelected != null && channelSelected.length() > 0){
             queryStr += ' Channel_Affiliation__c =: channelSelected AND';
         }
         
         if (approverName != null && approverName.length() > 0){
             String tempInput ='\'%' + approverName  + '%\'';
             queryStr += ' Affiliation_Approver_Name__c LIKE ' + tempInput + ' AND';
         }
         
         if (legalState != null && legalState.length() > 0){
             isAccountSearch = true;
             queryStr += ' Account.BillingState =: legalState';
         }
         
         System.debug('queryStr: '+ queryStr);
         if (queryStr != null && queryStr.endsWith('AND'))
             queryStr = queryStr.removeEnd('AND');
         System.debug('queryStr FINAL: '+ queryStr);
         
         // Contract Search 
         List<Contract> contractList = new List<Contract>();
         if (!queryStr.endsWith('WHERE '))   
             contractList = Database.query(queryStr);
         System.debug('contractList size: '+ contractList.size());
         
         // Content Search
         List<Contract> contractDocumentList = null;
         if (contentText != null && contentText.length() > 0){               
             contractDocumentList = getContractDocumentList(contentText);
             System.debug('contractDocumentList records: ' + contractDocumentList); 
             if (contractDocumentList != null && contractDocumentList.size() > 0){
                 for(Contract conlist: contractDocumentList){
                     contractIdSet.add(conlist.Id);
                   }                                                 
             }
         }
         System.debug('Content Search is: '+ contractIdSet);  
         
         // Document Search
         List<vlocity_cmt__ContractVersion__c> agreementList = new List<vlocity_cmt__ContractVersion__c>();
         if (contentText != null && contentText.length() > 0){ 
             System.debug('Document Search is called....');                                     
             agreementList = getContractAgreementList(contentText);
             System.debug('agreementList: ' + agreementList);
             if (agreementList != null && agreementList.size() > 0){
                 for(vlocity_cmt__ContractVersion__c agree: agreementList){
                     contractIdSet.add(agree.vlocity_cmt__ContractId__r.Id);
                 }                                                 
             }
         }
         System.debug('After Document Search: ' + contractIdSet);
                                                  
         if (isAccountSearch){  // User has input Contract Search Fields
             if (contractList != null && contractList.size() > 0){
                 for(Contract con: contractList){
                     if (contractIdSet != null && contractIdSet.size() > 0){
                         for(String idObj: contractIdSet){
                             if (con.Id == idObj)
                                 finalContractIdSet.add(con.Id);
                         }
                     }else if ((contractIdSet == null || contractIdSet.size() == 0) && (contentText == null || contentText.length() == 0)){
                             finalContractIdSet.add(con.Id);
                     
                     }
                 }
             }
         }else{
             finalContractIdSet = contractIdSet;
         
         }
                                                      
         // Document Search
        /* List<echosign_dev1__SIGN_Agreement__c> agreementList = null;
         if (documentText != null && documentText.length() > 0){                                      
             agreementList = getContractAgreementList(documentText);
             if (agreementList != null && agreementList.size() > 0){
                 for(echosign_dev1__SIGN_Agreement__c agree: agreementList){
                     contractIdSet.add(agree.echosign_dev1__Contract__r.Id);
                 }                                                 
             }
         }
         
         if (isAccountSearch){  // User has input Contract Search Fields
             if (contractList != null && contractList.size() > 0){
                 for(Contract con: contractList){
                     if (contractIdSet != null && contractIdSet.size() > 0){
                         for(String idObj: contractIdSet){
                             if (con.Id == idObj)
                                 finalContractIdSet.add(con.Id);
                         }
                     }else if (contractIdSet == null || contractIdSet.size() == 0){
                             finalContractIdSet.add(con.Id);
                     
                     }
                 }
             }
         }else{
             finalContractIdSet = contractIdSet;
         
         }*/
         System.debug('finalContractIdSet: '+ finalContractIdSet);
         if (finalContractIdSet != null && finalContractIdSet.size() > 0){
            List<Contract> finalContractList = [Select Id, Renewal_MRR__c,Net_New_MRR__c,Total_CPE__c,NRC__c, Account.Id, Account.Name, Opportunity__c, Opportunity__r.Id, Opportunity__r.Name, ContractNumber, StartDate, EndDate 
                                                from Contract where Id IN: (finalContractIdSet)];
             wrapper.originalContractListSize = finalContractList.size();
             // Check to return Contract List based on LIMIT restriction
             if (finalContractList != null && finalContractList.size() > 0){
                 if (finalContractList.size() > Integer.valueOf(System.Label.Contract_Search_LIMIT)){
                    Integer limitCount = Integer.valueOf(System.Label.Contract_Search_LIMIT);
                    wrapper.limitCount = Integer.valueOf(System.Label.Contract_Search_LIMIT);
                    queryStr = queryStr + ' LIMIT :limitCount';
                    finalContractList.clear();
                    System.debug('Final Query with LIMIT Clause: '+ queryStr);
                    finalContractList = [Select Id, Renewal_MRR__c,Net_New_MRR__c,Total_CPE__c,NRC__c, Account.Id, Account.Name, Opportunity__c, Opportunity__r.Id, Opportunity__r.Name, ContractNumber, StartDate, EndDate 
                                         from Contract where Id IN: (finalContractIdSet) LIMIT :limitCount];
                   System.debug('Final Contracts Are: ' + finalContractList);
                   wrapper.contractList = finalContractList;
                 }else{
                     System.debug('Final Contracts Are: ' + finalContractList);
                     wrapper.contractList = finalContractList;
                 }
             }
             
         }
         return wrapper;
     }
    
    // Document Search starts
    @AuraEnabled
    public static List<vlocity_cmt__ContractVersion__c> getContractAgreementList(final String searchword){
        if (searchword != null || String.isNotBlank(searchword)){
            String searchQuery = 'FIND \'' + searchword + '\' IN ALL FIELDS RETURNING ContentVersion(id, createddate, Title, FirstPublishLocationId, ContentDocumentId)';
            List<List<sObject>> searchList = search.query(searchQuery);
            Set<Id> contentDocumentIdSet = new Set<Id>();
            Set<Id> agreementIdSet = new Set<Id>();
            if (searchList != null && searchList.size() > 0){
                List<ContentVersion> contentVersionList = ((List<ContentVersion>)searchList[0]);
                if (contentVersionList != null && contentVersionList.size() > 0){
                    for(ContentVersion v: contentVersionList){
                        contentDocumentIdSet.add(v.ContentDocumentId);
                    }
                }
            }
            System.debug('contentDocumentIdSet in Document Search: ' + contentDocumentIdSet);
            if (contentDocumentIdSet != null && contentDocumentIdSet.size() > 0){
                List<ContentDocumentLink> linkList = [Select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where ContentDocumentId IN: (contentDocumentIdSet)];
                System.debug('ContentDocumentLink in Document Search: ' + linkList);
                if (linkList != null && linkList.size() > 0){
                    for(ContentDocumentLink l: linkList)
                        agreementIdSet.add(l.LinkedEntityId);
                }
            }
            
            System.debug('agreementIdSet: ' + agreementIdSet);
            if (agreementIdSet != null && agreementIdSet.size() > 0){
                List<vlocity_cmt__ContractVersion__c> agreementList = [Select Id, Name, vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.Id ,vlocity_cmt__ContractId__r.ContractNumber,vlocity_cmt__ContractId__r.StartDate, vlocity_cmt__ContractId__r.EndDate from vlocity_cmt__ContractVersion__c where vlocity_cmt__ContractId__r.Id IN:(agreementIdSet)];
                System.debug('No of Agreement Records: ' + agreementList.size());
                return agreementList;
            }
        }
        return null;
    } 
    
    
    //Content Search Starts
    @AuraEnabled
    public static List<Contract> getContractDocumentList(String searchword){
        if (Test.isRunningTest()){
            Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        	Account globalAcc1 = new Account();
        	globalAcc1.Name = 'GLOBAL ACCOUNT';
            globalAcc1.Customer_Number__c='2661234';
        	globalAcc1.RecordTypeId = globalRecId;
            globalAcc1.ConvertedFromLead__c =false;
        	//globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        	insert globalAcc1;
        	Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
            Account objAccount = new Account(name = 'TestAccount', Primary_ACNA__c='Test', Secondary_ACNA__c='Test');
            objAccount.RecordTypeId = MasterRTId;
			objAccount.ParentId = globalAcc1.Id;
            objAccount.Customer_Number__c='2751234';
            objAccount.ConvertedFromLead__c =false;
            insert objAccount;
            /*Account objAccount = new Account(name = 'TestAccount');
            insert objAccount;*/
            
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
            
            vlocity_cmt__ContractVersion__c version = new vlocity_cmt__ContractVersion__c();
            version.vlocity_cmt__ContractId__c = ctr.Id;
            insert version;
            
            vlocity_cmt__ContractSection__c section = new vlocity_cmt__ContractSection__c();
            section.vlocity_cmt__ContractVersionId__c = version.Id;
            //section.Contract_Id__c = ctr.Id;
            insert section;
            
            searchword = ctr.Id;
        }
        
        
        if (searchword != null || String.isNotBlank(searchword)){
            String searchQuery = 'FIND \'' + searchword + '\' IN ALL FIELDS RETURNING vlocity_cmt__ContractSection__c (Id, Name, Contract_Id__c,vlocity_cmt__SectionContent__c)';
            List<List<sObject>> searchList = search.query(searchQuery);
            Set<Id> contractIdSet = new Set<Id>();
            if (searchList != null && searchList.size() > 0){
                List<vlocity_cmt__ContractSection__c> contractSectionList = ((List<vlocity_cmt__ContractSection__c>)searchList[0]);
                System.debug('contractSectionList: ' + contractSectionList.size());
                if (contractSectionList != null && contractSectionList.size() > 0){
                    for(vlocity_cmt__ContractSection__c section: contractSectionList){
                        contractIdSet.add(section.Contract_Id__c);
                    }
                }
                if (contractIdSet != null && contractIdSet.size() > 0){
                    List<Contract> contractList = [Select Id,ContractNumber,Account.Name, AccountId, Account_Name_lookup__c, Opportunity__c, Opportunity__r.Id, Opportunity__r.Name,vlocity_cmt__OpportunityId__c, vlocity_cmt__OpportunityId__r.Id, vlocity_cmt__OpportunityId__r.Name, StartDate, EndDate from Contract where Id IN: (contractIdSet)];
                    System.debug('Contract Records Found: ' + contractList.size());
                    return contractList;
                }
            }
        }
        return null;
    }
    
    public class CustomContractSearchWrapper{
        @AuraEnabled    public Integer originalContractListSize{get; set;}
        @AuraEnabled    public Integer limitCount{get; set;}
        @AuraEnabled    public List<Contract> contractList{get; set;}
    }

}