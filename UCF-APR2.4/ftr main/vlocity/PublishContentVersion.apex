
List<Object> dataSetObjects = (List<Object>) JSON.deserializeUntyped('CURRENT_DATA_PACKS_CONTEXT_DATA');
List<Id> contentVersionIds = new List<Id>();
system.debug('///// Hellow World');
// Get Deployed Content Version from VBT 'CURRENT_DATA_PACKS_CONTEXT_DATA'
for (Object obj : dataSetObjects)
{
	Map<String, Object> objMap = (Map<String, Object>) obj;
    if ( objMap.containsKey('Id') && ((Id)objMap.get('Id')).getSObjectType() == ContentVersion.SObjectType )
    {
        contentVersionIds.add((Id)objMap.get('Id'));
    }
}

if (contentVersionIds.size() > 0)
{
	// Get "Deployed Content Version" ContentWorkspace ID
	ContentWorkspace contentWorkspace =[SELECT Id, Name
								        FROM ContentWorkspace
								        WHERE Name LIKE '%Vlocity Document Template Library%' 
								        LIMIT 1];
	// If ContentWorkspace ID was founded
	if (contentWorkspace != null) {
		// Get deployed ContentVersion to get the needed ContentDocumentId
		List<ContentVersion> contentVersionFull = [SELECT Id, ContentDocumentId 
												   FROM ContentVersion 
												   WHERE Id = :contentVersionIds];
		// List of 	ContentVersion IDs									   	
		List<Id> contentDocumentIds = new List<Id>();
		// Map with the ContentDocumentId that needs to be linked or has been linked 
		Map<Id,ContentVersion> contentDocumentIdsFromContentVersionFull = new Map<Id,ContentVersion>();
		for (ContentVersion cv : contentVersionFull) {
			// Poulate contentDocumentIds and contentDocumentIdsFromContentVersionFull based on contentVersionFull
		    contentDocumentIdsFromContentVersionFull.put(cv.Id,cv);
			contentDocumentIds.add(cv.ContentDocumentId);
		}
		// Get existing ContentDocumentLinks
		List<ContentDocumentLink> existingContentDocumentLinks = [SELECT Id, ContentDocumentId 
																  FROM ContentDocumentLink 
																  WHERE ContentDocumentId IN :contentDocumentIds 
																  	   AND LinkedEntityId = :contentWorkspace.Id];
		// Create Map of existing link based on the ContentDocumentId
		Map<Id, ContentDocumentLink> linkedContentDocumentId = new Map<id, ContentDocumentLink>();
		for (ContentDocumentLink existingContentDocumentLink : existingContentDocumentLinks) {
			linkedContentDocumentId.put(existingContentDocumentLink.ContentDocumentId,existingContentDocumentLink);
		}
		// Create and Insert the ContentDocumentLink based on the linkedContentDocumentId
	    List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
		for(Id exportedContentVersionId: contentVersionIds) {
			Id contentDocumentIdFromCV = contentDocumentIdsFromContentVersionFull.get(exportedContentVersionId).ContentDocumentId;
			// Add only if the Link does not exists
			if(!linkedContentDocumentId.containskey(contentDocumentIdFromCV)) {
		        ContentDocumentLink documentLink = new ContentDocumentLink(ContentDocumentId=contentDocumentIdFromCV, LinkedEntityId=contentWorkspace.Id, ShareType='I', Visibility='AllUsers');
		        contentDocumentLinks.add(documentLink);
	    	}
	    }

		if (contentDocumentLinks.size() > 0) {
			insert contentDocumentLinks; 
		}	    
	    
	}
}
