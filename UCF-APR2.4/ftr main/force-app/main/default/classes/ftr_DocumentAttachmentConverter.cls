global class ftr_DocumentAttachmentConverter implements vlocity_cmt.VlocityOpenInterface2 {

/*
** Class Name:
** Created Date: 2021-06-17
** Created By: Govardhan Dara of EagleCreek
** Description:
**
** History:
** 2021-06-17: Class created date
*/
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output,  Map<String, Object> options) 
    {
        Boolean success = false;
            
        System.debug('invokeMethod:methodName -> ' + methodName);
        System.debug('invokeMethod:input-> ' + input);
        
        if (methodName == 'convertContentVersionToAttachment') 
        {
            if (input.containsKey('contentVersionId') && input.containsKey('newParentObjectId')){
                string contVerId = String.valueof(input.get('contentVersionId'));
                string ParObjId = String.valueof(input.get('newParentObjectId'));
                convertContentVersionToAttachment(contVerId, ParObjId);
            }   
            return true;
        } 
        else 
        {
            System.debug('ftr_CLMDocumentAttachmentConverter unknownmethod');
            
        }

        System.debug('invokeMethod:output -> ' + output);
        System.debug('invokeMethod:success -> ' + success);
        return success;
    }
    
    public static String convertAttachmentToContentDuplicate(final String attachmentId, final String newParentObjectId){
    // Used to create duplicate attachment. Not used anywhere.                                              
        //Get attachment
        Attachment attach = [SELECT Id, Name, Body, ownerId, ContentType, ParentId From Attachment where Id=:attachmentId];
                   // Create new Attachment record
                    Attachment att=new Attachment();
                    //att.Body=Blob.valueOf(String.valueOf(version.VersionData));
                    att.Body = attach.Body;
                    att.Name = attach.Name;
                    att.parentId=newParentObjectId;    // stamp to new ParentObjectId
                    insert att;
        return null;                                  
    }
        

    public static String convertAttachmentToContent(final String attachmentId, final String newParentObjectId){
                                                   
        //Get attachment
        Attachment attach = [SELECT Id, Name, Body, ownerId, ContentType, ParentId From Attachment where Id=:attachmentId];
        
        //Insert ContentVersion
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = attach.Name;//File name with extention
        cVersion.Origin = 'C';//C-Content Origin. H-Chatter Origin.
        //cVersion.OwnerId = attach.OwnerId;//Owner of the file
        cVersion.Title = attach.Name;//Name of the file
        cVersion.VersionData = attach.Body;//File content
        cVersion.FirstPublishLocationId = newParentObjectId; // Creates the ContentDocumentLink also
        Insert cVersion;
        
/*
        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        
        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = newParentObjectId;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink;
 */      
        ContentDocumentLink cDocLink = [SELECT Id  FROM ContentDocumentLink WHERE LinkedEntityId =: newParentObjectId Limit 1];
        if (cDocLink != null) {
            return cDocLink.Id;
        } else {
        	return null;                                  
        }
    }
    
    public static String convertContentToAttachment(final String contentDocumentLinkId, final String newParentObjectId){
                                                   
        if (contentDocumentLinkId != null || String.isNotBlank(contentDocumentLinkId)){
            // Get the ContentDocumentLink record based on input param contentDocumentLinkId
            ContentDocumentLink linkObj = [Select Id, ContentDocumentId from ContentDocumentLink where Id=:contentDocumentLinkId];
            if (linkObj != null){
                // Fetch the ContentVersion record matching ContentDocumentId from ContentDocumentLink.ContentDocumentId
                ContentVersion version = [SELECT ContentDocumentId,ContentLocation,ContentSize,ContentUrl,Description,FileExtension,FileType,Id,Title,VersionData,VersionNumber 
                                          FROM ContentVersion where ContentDocumentId=:linkObj.ContentDocumentId];
                if (version != null){
                    // Create new Attachment record
                    Attachment att=new Attachment();
                    //att.Body=Blob.valueOf(String.valueOf(version.VersionData));
                    att.Body = version.VersionData;
                    att.Name = version.Title + '.' + version.FileExtension;
                    att.parentId=newParentObjectId;    // stamp to new ParentObjectId
                    insert att;
                    return att.Id;    // return newly created AttachmentId
                }                      
            }
        }
        return null;             
    }

    public static String convertContentVersionToAttachment(final String contentVersionId, final String newParentObjectId){
                                                   
        if (contentVersionId != null || String.isNotBlank(contentVersionId)){
            // Get the ContentVersion record based on input param ContentVersionId
            ContentVersion version = [SELECT ContentDocumentId,ContentLocation,ContentSize,ContentUrl,Description,FileExtension,FileType,Id,Title,VersionData,VersionNumber 
                                      FROM ContentVersion where Id=:contentVersionId];
            if (version != null){
                // Create new Attachment record
                Attachment att=new Attachment();
                //att.Body=Blob.valueOf(String.valueOf(version.VersionData));
                att.Body = version.VersionData;
                att.Name = version.Title; //+ '.' + version.FileExtension;
                att.parentId=newParentObjectId;    // stamp to new ParentObjectId
                insert att;
                return att.Id;    // return newly created AttachmentId
            }                      
            
        }
        return null;             
    }

    
}