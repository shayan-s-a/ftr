/*******************************************************************************************************************
Name        :  ftr_OrdersRecordTypePageController
Developer   :  RajuM FTR
Description :  This controller handles the order record type navigation to respective Page Layouts based on picklist value selection for UCaaS Order
********************************************************************************************************************/

public with sharing class ftr_OrdersRecordTypePageController {    
    
    private ApexPages.StandardController controller;
    public String retURL {get; set;}
    public String saveNewURL {get; set;}
    public String rType {get; set;}
    public String cancelURL {get; set;}
    public String ent {get; set;}
    public String confirmationToken {get; set;}
    public String selectedRT {get;set;}
    public String selectedUCaaSRT {get;set;}
    public Order orderRec;
    
    public ftr_OrdersRecordTypePageController(ApexPages.StandardController controller) {
        
        this.controller = controller;
        
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        rType = ApexPages.currentPage().getParameters().get('RecordType');
        cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
        ent = ApexPages.currentPage().getParameters().get('ent');
        confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
        saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
        
        this.orderRec = (Order)controller.getRecord();
        System.debug('accountID====='+orderRec);
        
    }   
    
    public List<SelectOption> getRecordTypeList(){
        /*String profileName = [Select Id, Name From Profile where Id = :UserInfo.getProfileId()].Name;
        Map<String, String> profilePermissionSets = new Map<String, String>();
        profilePermissionSets.put('#CTF AccountExec', 'Salesforce_Ordering');
        String permissionSetName = profilePermissionSets.get(profileName); 
        Set<Id> userIds = new Set<Id>();
        if(permissionSetName != null){
            List<PermissionSetAssignment> psa = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = :permissionSetName];
        	for(PermissionSetAssignment p: psa) userIds.add(p.AssigneeId);
        }*/
        
        Set<Id> rtSet = new Set<Id>();
        Schema.DescribeSObjectResult R = Order.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RTIF = R.getRecordTypeInfos();
        for (Schema.RecordTypeInfo RTI : RTIF) {
            if (RTI.isAvailable()){
                rtSet.add(RTI.getRecordTypeId());
            }
        }

        
        List<SelectOption> recordTypeval = new List<SelectOption>();
        List<RecordType> rtList = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SObjectType='Order' AND (NOT DeveloperName LIKE 'UCaaS%') ORDER BY DeveloperName ASC ];
        recordTypeval.add(new SelectOption('--None--', '--None--'));
        recordTypeval.add(new SelectOption('UCaaS_Order', 'UCaaS Order'));
        for(RecordType rt : rtList)
        {
            if(rtSet.contains(rt.Id)) recordTypeval.add(new SelectOption(rt.Id, rt.Name));
        }
        return recordTypeval;
    }
    
    public List<SelectOption> getUCaaSRecordTypeList(){
        
        List<SelectOption> recordTypeval = new List<SelectOption>();
        List<RecordType> rtList = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SObjectType='Order' AND (DeveloperName LIKE 'UCaaS%') ];
        recordTypeval.add(new SelectOption('--None--', '--None--'));
        for(RecordType rt : rtList)
        {
            recordTypeval.add(new SelectOption(rt.Id, rt.Name));
        }        
        return recordTypeval;
    }
    
    public PageReference redirect() {
        
        PageReference returnURL;
        
        //String newPagereturnTo = '{!URLFOR($Action.order.Edit, recordId)}';      
        //returnURL = new PageReference(newPagereturnTo); 
        returnURL = new PageReference('/801/e'); 
        
        //returnURL.getParameters().put('retURL', retURL);
        if(selectedUCaaSRT != null && selectedUCaaSRT !='--None--'){
            returnURL.getParameters().put('RecordType', selectedUCaaSRT);
            
        }else{
            returnURL.getParameters().put('RecordType', selectedRT);
            
        }
        
        returnURL.getParameters().put('cancelURL', cancelURL);
        returnURL.getParameters().put('ent', ent);
        returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
        returnURL.getParameters().put('save_new_url', saveNewURL);
        returnURL.getParameters().put('nooverride', '1');
        
        if(orderRec !=null ){
            opportunity opp;
            Account acc;
            if(orderRec.AccountId != null){
                //opp =[select id,Name,AccountId,Account.Name from opportunity where AccountId =:orderRec.AccountId];
                acc =[select id,Name from Account where id =:orderRec.AccountId];
                returnURL.getParameters().put('accid', acc.Name);
                returnURL.getParameters().put('accid_lkid', acc.Id);
                
            }else if(orderRec.OpportunityId != null){
                opp =[select id,Name,AccountId from opportunity where id =:orderRec.OpportunityId];
                returnURL.getParameters().put('opptyid', opp.Name);
                returnURL.getParameters().put('opptyid_lkid', opp.id);
                
            }
            System.debug('====='+opp);        
            
        }
        
                
        returnURL.setRedirect(true);
        return returnURL;
        
    }
    
    @AuraEnabled 
    public static Map<String, String> fetchRecordTypeValues(String objectName){
        Map<String, String> recordtypemap = new Map<String, String>();
        recordtypemap.put('--None--', '--None--');
        recordtypemap.put('UCaaS_Order', 'UCaaS Order');
        recordtypemap.put('Circuit_Order_Type', 'Circuit Order Type ( Non-Ethernet )');
        recordtypemap.put('Voice_Orders','Voice & Broadband Orders ( INC Bundles )');
        recordtypemap.put('FAW_Mitel_Orders', 'FAW Mitel Orders');
        
        Set<Id> rtSet = new Set<Id>();
        Schema.DescribeSObjectResult R = Order.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RTIF = R.getRecordTypeInfos();
        for (Schema.RecordTypeInfo RTI : RTIF) {
            if (RTI.isAvailable()){
                rtSet.add(RTI.getRecordTypeId());
            }
        }
        system.debug(rtSet);
        
        for(RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SObjectType='Order' AND (NOT DeveloperName LIKE 'UCaaS%') AND (NOT DeveloperName LIKE 'Circuit%') AND (NOT DeveloperName LIKE 'FAW%') AND (NOT DeveloperName LIKE 'Voice%') ]){
              if(rtSet.contains(rt.Id)) recordtypemap.put(rt.Id, rt.Name);
        }
         return recordtypemap;
        
    }
    
    @AuraEnabled        
    public static Map<String, String> fetchUCaaSRecordTypeList(String objectName){
        Map<String, String> recordtypemap = new Map<String, String>();
        recordtypemap.put('--None--', '--None--');
        for(RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SObjectType='Order' AND (DeveloperName LIKE 'UCaaS%') ]){
            // if(rt.recTypeName != System.Label.Master && rt.recTypeName.trim() != '')
            recordtypemap.put(rt.Id, rt.Name);
        }     
        return recordtypemap;
        
    }
    @AuraEnabled        
    public static Map<String, String> fetchCircuitRecordTypeList(String objectName){
        Map<String, String> recordtypemap = new Map<String, String>();
        recordtypemap.put('--None--', '--None--');
        for(RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SObjectType='Order' AND (DeveloperName LIKE 'Circuit%') AND (DeveloperName != 'Circuit_Move_of_Voice_Change_Order')]){
            // if(rt.recTypeName != System.Label.Master && rt.recTypeName.trim() != '')
            recordtypemap.put(rt.Id, rt.Name);
        }     
        return recordtypemap;
        
    }
    @AuraEnabled        
    public static Map<String, String> fetchFAWMitelRecordTypeList(String objectName){
        Map<String, String> recordtypemap = new Map<String, String>();
        recordtypemap.put('--None--', '--None--');
        for(RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SObjectType='Order' AND (DeveloperName LIKE 'FAW%') ]){
            // if(rt.recTypeName != System.Label.Master && rt.recTypeName.trim() != '')
            recordtypemap.put(rt.Id, rt.Name);
        }     
        return recordtypemap;
        
    }
    @AuraEnabled        
    public static Map<String, String> fetchVoiceRecordTypeList(String objectName){
        Map<String, String> recordtypemap = new Map<String, String>();
        recordtypemap.put('--None--', '--None--');
        for(RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SObjectType='Order' AND (DeveloperName LIKE 'Voice%') ]){
            // if(rt.recTypeName != System.Label.Master && rt.recTypeName.trim() != '')
            recordtypemap.put(rt.Id, rt.Name);
        }     
        return recordtypemap;
        
    }
    
    @AuraEnabled
    public static AccountWrapper getOpportunityData(String oppId) {
        Id recordID = oppId;
        String sObjName = recordID.getSObjectType().getDescribe().getName();
        AccountWrapper wrapObj = new AccountWrapper();
        wrapObj.acc = new Account();
        wrapObj.objectName = sObjName;
        wrapObj.accountId = '';
        wrapObj.opportunityId = '';
        if(sObjName == 'Opportunity'){
            wrapObj.opportunityId = recordId;
        	for(Opportunity opp: [Select Id, AccountId, Account.Id, Account.BillingStreet, Account.BillingCity, 
                Account.BillingCountry, Account.BillingPostalCode, Account.BillingStateCode,
                Account.ShippingStreet, Account.ShippingCity, Account.ShippingStateCode, 
                Account.ShippingCountry, Account.ShippingPostalCode from Opportunity where Id =:oppId]){
                wrapObj.acc = opp.Account;    
            }
        }
        if(sObjName == 'Account'){
            wrapObj.accountId = recordId;
        	for(Account acc: [Select Id,  Name, BillingStreet, BillingCity, 
                BillingCountry, BillingPostalCode, BillingStateCode,
                ShippingStreet, ShippingCity, ShippingStateCode, 
                ShippingCountry, ShippingPostalCode from Account where Id =:recordID]){
                wrapObj.acc = acc;    
            }
        }
		return wrapObj;
    }
    
    public class AccountWrapper {
        @AuraEnabled public Account acc;
        @AuraEnabled public String opportunityId;
        @AuraEnabled public String accountId;
        @AuraEnabled public String objectName;
    }
    
}