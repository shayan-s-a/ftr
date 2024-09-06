
List<Object> dataSetObjects = (List<Object>) JSON.deserializeUntyped('CURRENT_DATA_PACKS_CONTEXT_DATA');
List<Id> documentTemplateIDs = new List<Id>();
// Get Deployed Document Templates
for (Object obj : dataSetObjects)
{
	Map<String, Object> objMap = (Map<String, Object>) obj;
    if ( objMap.containsKey('Id') && ((Id)objMap.get('Id')).getSObjectType() == vlocity_namespace__DocumentTemplate__c.SObjectType )
    {
        documentTemplateIDs.add((Id)objMap.get('Id'));
    }
}
// Update Deployed Document with 
if (documentTemplateIDs.size() > 0)
{
    List<vlocity_namespace__DocumentTemplate__c> documentTemplateToUpdate = new List<vlocity_namespace__DocumentTemplate__c>();
	for(Id dtID : documentTemplateIDs) {
        vlocity_namespace__DocumentTemplate__c dtToUpdate = new vlocity_namespace__DocumentTemplate__c(Id = dtID, vlocity_namespace__IsActive__c = true);
        documentTemplateToUpdate.add(dtToUpdate);
    }
    update documentTemplateToUpdate;
}