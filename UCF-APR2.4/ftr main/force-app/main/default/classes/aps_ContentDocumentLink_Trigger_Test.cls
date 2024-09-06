/**
 * @description       :
 * @author            : Monir Zaman
 * @group             :
 * @last modified on  : 02-10-2024
 * @last modified by  : Md Mehedi Hasan
 * @last modified on  : 02-10-2024
 * @last modified by  : Md Mehedi Hasan
 * Modifications Log
 * Ver   Date         Author        Modification
 * 3.0   16-09-2023   Monir Zaman   Just updating 2.0 to 3.0 to trigger in pipeline
 **/
@isTest
public with sharing class aps_ContentDocumentLink_Trigger_Test {
  @isTest
  static void contentDocTest() {
    FormData__c fd = new FormData__c(
      Name__c = 'test',
      Company__c = 'test',
      Email__c = 'test@test.com',
      Legal_Business_Name__c = 'test'
    );
    insert fd;

    Case cs = new Case(
      RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get('Ent_Partner_Dir_Sales_Support')
        .getRecordTypeId(),
      Status = '01-New',
      Origin = 'Origin',
      Subject = 'test',
      FormData__c = fd.Id
    );
    insert cs;

    ContentVersion content1 = new ContentVersion();
    content1.Title = 'Header_Picture1';
    content1.PathOnClient = '/' + content1.Title + '.jpg';
    Blob bodyBlob1 = Blob.valueOf('snc');
    content1.VersionData = bodyBlob1;
    content1.origin = 'H';
    insert content1;

    ContentDocumentLink contentlink1 = new ContentDocumentLink();
    contentlink1.LinkedEntityId = fd.id; // linked with contact module
    contentlink1.contentdocumentid = [
      SELECT contentdocumentid
      FROM contentversion
      WHERE id = :content1.id
    ]
    .contentdocumentid;
    contentlink1.ShareType = 'I';
    contentlink1.Visibility = 'AllUsers';
    insert contentlink1;
  }
}