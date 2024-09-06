/**
* @author Rishu Singla
* @date 15 Oct 2019
* @group Vlocity Refresh DSAT Class
* @description Logic needed for Refresh of DSAT Class
*/  
global without sharing class RefreshDSATClass implements vlocity_cmt.VlocityOpenInterface
{
    public Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result=false;
        try
        {
            if (methodName.equals('getRefreshAPIDetails'))
            {
                
                result = getRefreshAPIDetails(input, outMap, options);   
            }
        }
        catch(Exception e)
        {
            System.debug('RefreshDSATClass: invokeMethod -> exception: '+e);
        }
        
        return result;
    }
    
    private boolean getRefreshAPIDetails(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        try
        {
            Id parentId = (Id)inputMap.get('ParentAccountId');
            Id contextId = (Id)inputMap.get('ContextId');
            Id premisesId = String.isNotBlank((String)inputMap.get('PremisesId')) ? (Id) inputMap.get('PremisesId') : null;
			system.debug('4');
            string stateName = inputMap.get('State').toString();
            StateNameCodeMapping__mdt state = [SELECT Label FROM StateNameCodeMapping__mdt WHERE State_Name__c = :stateName LIMIT 1];
            inputMap.put('State', state.Label);
            inputMap.put('OpportunityId',contextId);
            system.debug('5');
            system.debug(JSON.serialize(inputMap));
            vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
            integProcServ.invokeMethod('Validation_DSAT', inputMap, outMap, options);
            system.debug('6');
            system.debug(JSON.serialize(outMap));
            if(Test.isRunningTest())
            {
            	Map<String, Object> testDsat = new Map<String, Object>();
                testDsat.put('DSATAddressValidationSuccessResponse', new Map<string, object>());
                outMap.put('IPResult', testDsat);
            }

            // give access to service acc
            try {
                Account servAcc = [SELECT Id FROM Account WHERE ParentId = :parentId AND vlocity_cmt__PremisesId__c =:premisesId LIMIT 1];
                if (servAcc != null) {
                    AccountShare shareObj = new AccountShare();
                    shareObj.AccountId = servAcc.Id;
                    shareObj.UserOrGroupId = UserInfo.getUserId();
                    shareObj.AccountAccessLevel = 'edit';
                    shareObj.OpportunityAccessLevel = 'read';
                    shareObj.RowCause = 'Manual';
                    insert shareObj;
                }
            } catch (Exception e) {
                System.debug('Failed creating share record:');
                System.debug(e.getMessage());
            }
            
            Map<String, Object> inputMapToUpdate = (Map<String, Object>)outMap.get('IPResult');
            Map<String, Object> dsat = (Map<String, Object>)inputMapToUpdate.get('DSATAddressValidationSuccessResponse');
            dsat.put('FullStateName', stateName);
            dsat.put('ContextId',contextId);
            dsat.put('PremisesId',premisesId);
            inputMapToUpdate.put('ParentAccountId',parentId);
            inputMapToUpdate.put('ContextId',contextId);
            inputMapToUpdate.put('PremisesId',premisesId);
            system.debug('7');
            system.debug(JSON.serialize(inputMapToUpdate));
            integProcServ.invokeMethod('DSAT_AddLocation', inputMapToUpdate, outMap, options);
			system.debug('8');
            system.debug(JSON.serialize(outMap));
            return true;
        }
        catch(Exception e)
        {
            return false;
        }
    }
}