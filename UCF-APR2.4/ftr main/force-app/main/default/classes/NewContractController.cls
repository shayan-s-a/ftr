public class NewContractController {
@AuraEnabled
    public static Map<String, Object> isValidProfile(){
        boolean isValid = false;
        String label = system.Label.AltNewContract;
        List<String> profileNames = label.split(',');
		String profileName= getProfileName(UserInfo.getProfileId());

		Set<String> profileNamesSet= new Set<String>();
		profileNamesSet.addAll(profileNames);
		     
        if(String.isNotBlank(label) && profileNamesSet.contains(profileName)){
            isValid = true;
        }
        
        Map<String, Object> profileAssignments = (Map<String, Object>)JSON.deserializeUntyped(system.Label.AltNewContractAutoRedirect);
        String recordTypesAssigned = String.valueOf(profileAssignments.get(profileName));
        String recordTypeId = '';
        Map<String, String> recordTypes = new Map<String, String>();
        if(recordTypesAssigned != null) {
            List<String> recordTypesPerProfile = recordTypesAssigned.split(',');
            if(recordTypesPerProfile.size() == 1) recordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get(recordTypesPerProfile.get(0).trim()).getRecordTypeId();
            if(recordTypesPerProfile.size() > 1) {
                for(String recType: recordTypesPerProfile) {
                    recordTypes.put(recType, Schema.SObjectType.Contract.getRecordTypeInfosByName().get(recType.trim()).getRecordTypeId());
                }
            }
        }
        if(String.isNotBlank(label) && profileNamesSet.contains('')){
            isValid = true;
        }
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('isValid', isValid);
        result.put('recordTypeId', recordTypeId);
        result.put('recordTypes', recordTypes);
        
        return result;
    }
    public static String getProfileName(String profileId)
    {
          return [SELECT Name, Id FROM Profile where Id=: profileId][0].Name;
    }
}