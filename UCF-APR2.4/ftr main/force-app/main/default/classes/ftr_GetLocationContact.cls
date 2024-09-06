/**
* 
* @description fetch Location and Contacts details for AE omniscript.
*/ 

global with sharing class ftr_GetLocationContact implements vlocity_cmt.VlocityOpenInterface {
    
    public final static String LocationContact_METHOD = 'getLocationContact';
    public final static String Contact_Role = 'Location Contact';

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        System.debug('Enter ftr_GetLocationContact' + methodName);
        try {
            if (methodName == LocationContact_METHOD) {
                return getLocationContact(methodName, inputMap, outputMap);
            }
            return true;
        } catch (Exception ex) {
            System.debug(ex.getLineNumber() + ': ' + ex.getMessage());
            return false;
        } finally {
            System.debug('Exit ftr_GetLocationContact' + methodName);
        }
    }
        
    public Boolean getLocationContact(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap) {
        System.debug('InputMap in getLocationContact..'+ inputMap);
       
        Id OrderId = (Id)inputMap.get('OrderId');
        System.debug('OrderId'+OrderId);
            
       if(inputMap.get('OrderItem') instanceOf List<object>) {

        List<Object> locInfo = (List<Object>)inputMap.get('OrderItem');
        
        List<Id> serviceId = new List<Id>();
        
        for(Object sId : locInfo) {
             Map<String,Object> servID = (Map<String,Object>)sId;
             Id info = (Id)servID.get('ServiceAccountId');
             serviceId.add(info);
        } System.debug('serviceId'+serviceId);

        List<Location_Contact__c> ContactInfo = [SELECT id,service_account__c,order__c,role__c,name FROM Location_Contact__c
                                                  WHERE Order__c =: OrderId 
                                                  AND Role__c =: Contact_Role
                                                  AND Service_Account__c IN: serviceId]; 
        System.debug('ContactInfo'+ContactInfo);
        
        Map<Id,List<Location_Contact__c>> contactMAP  = new  Map<Id,List<Location_Contact__c>>();
        
        if(ContactInfo.size() > 0) {
        
            for(Location_Contact__c cinfo : ContactInfo){
                                                   
                if(!contactMAP.containsKey(cinfo.service_account__c)){
                    List<Location_Contact__c> locCon = new List<Location_Contact__c>();
                    locCon.add(cinfo);
                    contactMAP.put(cinfo.service_account__c,locCon);
                    System.debug('contactMAP in if' + contactMAP);
                } else {
                    contactMAP.get(cinfo.service_account__c).add(cinfo);
                    System.debug('contactMAP in else' + contactMAP);
                }
            }
        }
        System.debug('contactMAP..'+ contactMAP);
                    
        for(Object eachOI : locInfo){
            
            Map<String,Object> singleOI = (Map<String,Object>)eachOI;
            Id serviceAccId = (Id)singleOI.get('ServiceAccountId');
            
            List<Object> contactInfoList = new List<Object>();
            
            if(contactMAP.containsKey(serviceAccId)) {
                for(Location_Contact__c locCont : contactMAP.get(serviceAccId)){
                
                    Map<String,Object> conObj = new Map<String,Object>();
                    Map<String,Object> conIdMap = new Map<String,Object>();
                    conIdMap.put('value',locCont.name);
                    conIdMap.put('name',locCont.id);
                    
                    conObj.put('ContactId', conIdMap);
                    conObj.put('ContactRole', Contact_Role);
                    
                    contactInfoList.add(conObj);
                }
            } else {
                Map<String,Object> conObj = new Map<String,Object>();
                Map<String,Object> conIdMap = new Map<String,Object>();
                    
                conObj.put('ContactId', conIdMap);
                conObj.put('ContactRole', Contact_Role);
                
                contactInfoList.add(conObj);
            }
            
            singleOI.put('ContactInfo',contactInfoList);
            
        }
        
        System.debug('locInfo..'+ locInfo);
        outputMap.put('LocationInfoBlock',locInfo);

    } else {
        Map<String,Object> locInfoMAP = (Map<String,Object>)inputMap.get('OrderItem');
        System.debug('locInfoMAP'+ locInfoMAP);
        //List<Id> serviceId = new List<Id>();
        
        
             Id servicId = (Id)locInfoMAP.get('ServiceAccountId');
            
             System.debug('servicId'+servicId);

        List<Location_Contact__c> ContactInfo = [SELECT id,service_account__c,order__c,role__c,name FROM Location_Contact__c
                                                  WHERE Order__c =: OrderId 
                                                  AND Role__c =: Contact_Role
                                                  AND Service_Account__c =: servicId]; 
        System.debug('ContactInfo'+ContactInfo);
        
        Map<Id,List<Location_Contact__c>> contactMAP  = new  Map<Id,List<Location_Contact__c>>();
        
        if(ContactInfo.size() > 0) {
        
            for(Location_Contact__c cinfo : ContactInfo){
                                                   
                if(!contactMAP.containsKey(cinfo.service_account__c)){
                    List<Location_Contact__c> locCon = new List<Location_Contact__c>();
                    locCon.add(cinfo);
                    contactMAP.put(cinfo.service_account__c,locCon);
                    System.debug('contactMAP in if' + contactMAP);
                } else {
                    contactMAP.get(cinfo.service_account__c).add(cinfo);
                    System.debug('contactMAP in else' + contactMAP);
                }
            }
        }
        System.debug('contactMAP..'+ contactMAP);
            
            List<Object> contactInfoList = new List<Object>();
            
            if(contactMAP.containsKey(servicId)) {
                for(Location_Contact__c locCont : contactMAP.get(servicId)){
                
                    Map<String,Object> conObj = new Map<String,Object>();
                    Map<String,Object> conIdMap = new Map<String,Object>();
                    conIdMap.put('value',locCont.name);
                    conIdMap.put('name',locCont.id);
                    
                    conObj.put('ContactId', conIdMap);
                    conObj.put('ContactRole', Contact_Role);
                    
                    contactInfoList.add(conObj);
                }
            } else {
                Map<String,Object> conObj = new Map<String,Object>();
                Map<String,Object> conIdMap = new Map<String,Object>();
                    
                conObj.put('ContactId', conIdMap);
                conObj.put('ContactRole', Contact_Role);
                
                contactInfoList.add(conObj);
            }
            
            locInfoMAP.put('ContactInfo',contactInfoList);
        
        System.debug('locInfo..'+ locInfoMAP);
        outputMap.put('LocationInfoBlock',locInfoMAP); 

    }

        return true;
    }
    
    
}