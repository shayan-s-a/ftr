/********************************************************************************************
Name : ECPEntitlementWebService
Created By : Mohan Talluri (mohan.talluri@ftr.com)
Created Date : January 27, 2016
Description :  An Apex REST service to support the following

1. POST/Entitlement - Creates a new Entitlement and insert records in the database.

2. GET/Entitlements - Extracts all entitlements associated to a contactGUID or AccountNumber.

3. DELETE/Entitlements - Deletes entitilements associated to either only a contactGUID or a 
                         specific entitilement associated to a contactGuid and Account

********************************************************************************************/

@RestResource(urlMapping='/Entitlements/*')

global with sharing class ECPEntitlementWebService {
    
    //========================================================================================
    // *** REST POST *** : Require field should not be empty, method to post a new Entitlement
    //========================================================================================  
    @HttpPost
    global static void doPost() {
        //API Working
        List<ECPHandler.Entitlements> EntitlementList = new List<ECPHandler.Entitlements>();
        ECPHandler.Entitlements entitlement = null;
        ECPHandler.Error resBody;
        boolean issueFoundWithInput = false;
        try {
            Map<String, Object> root = (Map<String, Object>) JSON.deserializeuntyped(RestContext.request.requestbody.tostring());
            List<Object> items = (List<Object>)root.get('entitlements');
            for (Object item : items) {
                Map<String, Object> i = (Map<String, Object>)item;
                entitlement = new ECPHandler.Entitlements((String) i.get('contactguid'), (String) i.get('accountnumber'), (String) i.get('accounttype'), (String) i.get('role'), (String) i.get('permissionset'));
                System.debug('contactguid : '+(String) i.get('contactguid'));
                System.debug('accountnumber : '+(String) i.get('accountnumber'));
                System.debug('accounttype : '+(String) i.get('accounttype'));
                System.debug('role : '+(String) i.get('role'));
                System.debug('permissionset : '+i.get('permissionset'));
                EntitlementList.add(entitlement);
            }
        } catch(Exception ex) {
            System.debug(ex);
            issueFoundWithInput = true;
            resBody = new ECPHandler.Error();
            resBody.FaultCode = '1000';
            resBody.FaultDescription = 'Error: Please check in the requestBody to send complete Entitlement Info.  Example: {  \"entitlements\": [ { \"contactguid\" : \"value1\", \"accountnumber\" : \"value2\", \"accounttype\" : \"value3\", \"role\" : \"value4\", \"permissionset\" : \"value5\" } ] } ';
        }
        
        if (!issueFoundWithInput)
            resBody = validateInputParamsForPost(EntitlementList);

        //RestContext.response.addHeader('Content-Type', 'application/json');
        
        if (resBody != null)
        {
            List<ECPHandler.Error> errList = new List<ECPHandler.Error>();
            errList.add(resBody);        
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(resBody));
        }
        else
            RestContext.response.responseBody = Blob.valueOf(ECPHandler.addAccountEntitlements(EntitlementList));
        
        try 
        {   
            Map<String, Object> logOutput = new Map<String, Object>();
            Map<String, Object> logInput = new Map<String, Object>();
            logInput.put('request', JSON.deserializeUntyped(RestContext.request.requestbody.tostring()));
            logInput.put('response', JSON.deserializeUntyped(RestContext.response.responseBody.toString()));
            logInput.put('interface', 'CreateEntitlements');
            logInput.put('system', 'DataWareHouse');
            
            Object ResObject = JSON.deserializeUntyped(RestContext.response.responseBody.toString()); 
            Map<String, Object> ResMap;
            
            if(ResObject InstanceOf List<Object>){
                ResMap = (Map<String,Object>)((List<Object>)ResObject).get(0);
                
            }else if (ResObject InstanceOf Map<String,Object>){
                ResMap = (Map<String,Object>) ResObject;
            }
            if( ResMap.containsKey('FaultCode')){
                logInput.put('status', 'ERROR');
                logInput.put('errorMessage', ResMap.get('FaultDescription'));
                logInput.put('errorCode', ResMap.get('FaultCode'));
            }else{
                logInput.put('status', 'SUCCESS');
            }
            logInput.put('convertToXML', false);
            
            APILogger log = new APILogger();
            log.createEntry(logInput, logOutput);
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            System.debug('Unable to create log');
            System.debug(ex.getMessage());
        } 
    }
    
    //========================================================================================
    // *** REST GET *** : Require field should not be empty, method to get Entitlements either
    //                    by contactGUID or by AccountNumber.
    //========================================================================================  
    @HttpGet
    global static void doGet() {
        String accNum = RestContext.request.params.get('accountnumber');
        String cGUID = RestContext.request.params.get('contactguid');
        
        // validate Input parameters.
        ECPHandler.Error resBody = validateInputParamsForGet(accNum, cGUID);
        
        if (resBody != null)
        {
            //Apex not intelligent enough if written code (new List<ECPHandler.Error>()).add(resBody) directly.
            List<ECPHandler.Error> errList = new List<ECPHandler.Error>();
            errList.add(resBody);        
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(resBody));
        }
        else
        {
            // Now we are good to process the request based out of accountnumber provided.
            if (!(String.isEmpty(accNum)))
                RestContext.response.responseBody = Blob.valueOf(ECPHandler.getAccountEntitlements(accNum));
            else
                RestContext.response.responseBody = Blob.valueOf(ECPHandler.getContactEntitlements(cGUID));
        }
        system.debug('before log');
        try 
        {   
            Map<String, Object> logOutput = new Map<String, Object>();
            Map<String, Object> logInput = new Map<String, Object>();
            logInput.put('request', RestContext.request.params);
            logInput.put('response', JSON.deserializeUntyped(RestContext.response.responseBody.toString()));
            logInput.put('interface', 'GetEntitlements');
            logInput.put('system', 'DataWareHouse');
            
            Object ResObject = JSON.deserializeUntyped(RestContext.response.responseBody.toString()); 
            Map<String, Object> ResMap;
            
            if(ResObject InstanceOf List<Object>){
                ResMap = (Map<String,Object>)((List<Object>)ResObject).get(0);
                
            }else if (ResObject InstanceOf Map<String,Object>){
                ResMap = (Map<String,Object>) ResObject;
            }
            if( ResMap.containsKey('FaultCode')){
                logInput.put('status', 'ERROR');
                logInput.put('errorMessage', ResMap.get('FaultDescription'));
                logInput.put('errorCode', ResMap.get('FaultCode'));
            }else{
                logInput.put('status', 'SUCCESS');
            }
            logInput.put('convertToXML', false);
            
             logInput.put('convertToXML', false);
            
            APILogger log = new APILogger();
            log.createEntry(logInput, logOutput);
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            System.debug('Unable to create log');
            System.debug(ex.getMessage());
        } 
    }

    @HttpDelete
    global static void doDelete() {
        //API working
        String accNum = RestContext.request.params.get('accountnumber');
        String cGUID = RestContext.request.params.get('contactguid');
        
        // validate Input parameters.
        ECPHandler.Error resBody = validateInputParamsForDelete(accNum, cGUID);
        
        if (resBody != null)
        {
            //Apex not intelligent enough if written code (new List<ECPHandler.Error>()).add(resBody) directly.
            List<ECPHandler.Error> errList = new List<ECPHandler.Error>();
            errList.add(resBody);        
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(resBody));
        }
        else
        {
            // Now we are good to process the request based out of accountnumber provided.
            RestContext.response.responseBody = Blob.valueOf(ECPHandler.deleteEntitlement(cGUID, accNum));
        }
        try 
        {   
            Map<String, Object> logOutput = new Map<String, Object>();
            Map<String, Object> logInput = new Map<String, Object>();
            logInput.put('request', RestContext.request.params);
            logInput.put('response', JSON.deserializeUntyped(RestContext.response.responseBody.toString()));
            logInput.put('interface', 'DeleteEntitlements');
            logInput.put('system', 'DataWareHouse');
            logInput.put('convertToXML', false);
            
            Object ResObject = JSON.deserializeUntyped(RestContext.response.responseBody.toString()); 
            Map<String, Object> ResMap;
            
            if(ResObject InstanceOf List<Object>){
                ResMap = (Map<String,Object>)((List<Object>)ResObject).get(0);
                
            }else if (ResObject InstanceOf Map<String,Object>){
                ResMap = (Map<String,Object>) ResObject;
            }
            if( ResMap.containsKey('FaultCode')){
                logInput.put('status', 'ERROR');
                logInput.put('errorMessage', ResMap.get('FaultDescription'));
                logInput.put('errorCode', ResMap.get('FaultCode'));
            }else{
                logInput.put('status', 'SUCCESS');
            }
            logInput.put('convertToXML', false);
            
            APILogger log = new APILogger();
            log.createEntry(logInput, logOutput);
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            System.debug('Unable to create log');
            System.debug(ex.getMessage());
        } 
    }
    
    global static ECPHandler.Error validateInputParamsForPost(List<ECPHandler.Entitlements> elist)
    {
        ECPHandler.Error resBody;

        if (elist.isEmpty())
        {
            resBody = new ECPHandler.Error();
            resBody.FaultCode = '1001';
            resBody.FaultDescription = 'Input Parameter Missing: EntitlementList cant be Empty.';
        }
        else
        {
            
            Set<String> validAccountTypes = new Set<String>{'GAN', 'SMA', 'BTN'};
            Set<String> validRoleTypes = new Set<String>{'Admin', 'Analyst'};
            for (ECPHandler.Entitlements e : elist)
            {
                System.debug('accountnumber exists but accounttype is null : ' +((!(String.isEmpty(e.accountNumber))) && (String.isEmpty(e.accountType))));
                
                //AccountNumber is Optional. However, if there is a value, then AccountType is Mandatory.
                if ( (String.isEmpty(e.contactGUID)) || (String.isEmpty(e.role)) || (String.isEmpty(e.permissionSet)) || ((!(String.isEmpty(e.accountNumber))) && (String.isEmpty(e.accountType))) || (((String.isEmpty(e.accountNumber))) && (!String.isEmpty(e.accountType))))
                {
                    resBody = new ECPHandler.Error();
                    resBody.FaultCode = '1002';
                    resBody.FaultDescription = 'Input Parameter Missing: Every entitlement should have contactGUID, role and permissionSet. Also if accountNumber exist then accountType is mandatory.';
                    break;
                }
                if (!(validAccountTypes.contains(e.accountType)))
                {
                    resBody = new ECPHandler.Error();
                    resBody.FaultCode = '1003';
                    resBody.FaultDescription = 'Input Parameter Error: accounttype [accountType] can only have GAN or SMA or BTN.';
                    break;
                }
                if(!(validRoleTypes.contains(e.role)))
                {
                    resBody = new ECPHandler.Error();
                    resBody.FaultCode = '1004';
                    resBody.FaultDescription = 'Input Parameter Error: role can either be Admin or Analyst.';
                    break;
                }
            }
        }
        
        return resBody;
    }
  
    global static ECPHandler.Error validateInputParamsForGet(String accNum, String cGUID)
    {
          ECPHandler.Error resBody;
          
          if ( (String.isEmpty(accNum)) && (String.isEmpty(cGUID)) ) 
          {
            resBody = new ECPHandler.Error();
            resBody.FaultCode = '1000';
            resBody.FaultDescription = 'Input Parameter Missing: accountnumber [Account Number] Or contactguid [contactGUID] is mandatory to process the request.';
          }
          else  if ( (!(String.isEmpty(accNum))) && (!(String.isEmpty(cGUID))) ) 
          {
            resBody = new ECPHandler.Error();
            resBody.FaultCode = '1001';
            resBody.FaultDescription = 'Input Parameter Error: Only one parameter is expected. Either accountnumber [Account Number] Or contactguid [contactGUID] to process the request.';
          }
          
          return resBody;
    }
    
    global static ECPHandler.Error validateInputParamsForDelete(String accNum, String cGUID)
    {
          ECPHandler.Error resBody;
          
          if ( (!(String.isEmpty(accNum))) && (String.isEmpty(cGUID)) ) {
            resBody = new ECPHandler.Error();
            resBody.FaultCode = '1002';
            resBody.FaultDescription = 'Input Parameter Missing: Though given accountnumber - contactguid [contactGUID] is still a mandatory attribute to process the request.';
          }
          else if (String.isEmpty(cGUID)) 
          {
            resBody = new ECPHandler.Error();
            resBody.FaultCode = '1003';
            resBody.FaultDescription = 'Input Parameter Missing: contactguid [contactGUID] is mandatory to process the request.';
          }
          
          return resBody;
    }    
  
}