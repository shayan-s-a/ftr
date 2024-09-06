/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2
 * 
**/
@IsTest
public class ftr_DocumentAttachmentConverterTest{

    public static testmethod void testConvertAttachmentToContent(){
        User userObj = [Select Id from User where profile.Name = 'Frontier System Administrator' AND IsActive=true LIMIT 1];
        System.runAs(userObj){
            Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        	Account globalAcc1 = new Account();
        	globalAcc1.Name = 'GLOBAL ACCOUNT';
        	globalAcc1.RecordTypeId = globalRecId;
        	//globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        	insert globalAcc1;
        	Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
             Account objAccount = new Account(name = 'TestAccount');
            objAccount.RecordTypeId = MasterRTId;
			objAccount.ParentId = globalAcc1.Id;
             insert objAccount;
        opportunity objopportunity= new opportunity(AccountId=objAccount.Id);
            objopportunity.Name ='testing opp';
            objopportunity.StageName='verbal commit'; 
            objopportunity.CloseDate= date.today();
            objopportunity.Expected_Billed_Date__c = date.today();
            insert objopportunity;
        
        ContentVersion cv = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = blob.valueof('Test Content Data'),
                IsMajorVersion = true
                
            );
            insert cv;
            
            ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
             ContentDocumentLink contentlink=new ContentDocumentLink();
             contentlink.LinkedEntityId=objopportunity.id;  
             //contentlink.ShareType= 'C';               
             contentlink.ContentDocumentId=documents[0].Id;
             contentlink.Visibility = 'AllUsers'; 
             insert contentlink;
             
        System.Test.startTest();
            String attachId = ftr_DocumentAttachmentConverter.convertContentToAttachment(contentlink.Id, objopportunity.Id);
            String contentDocLinkId = ftr_DocumentAttachmentConverter.convertAttachmentToContent(attachId, objAccount.Id);
            attachId = ftr_DocumentAttachmentConverter.convertContentVersionToAttachment(cv.Id, objopportunity.Id);
            attachId = ftr_DocumentAttachmentConverter.convertAttachmentToContentDuplicate(attachId, objopportunity.Id);
            Map<String, Object> input = new Map<String, Object>();
            Map<String, Object> output = new Map<String, Object>(); 
            Map<String, Object> options = new Map<String, Object>();
            input.put('contentVersionId', cv.Id);
            input.put('newParentObjectId', objopportunity.Id);
            ftr_DocumentAttachmentConverter obj = new ftr_DocumentAttachmentConverter();
            obj.invokeMethod('convertContentVersionToAttachment', input, output, options);
            obj.invokeMethod('test1', input, output, options);
        System.Test.stopTest();
        }
    }
}