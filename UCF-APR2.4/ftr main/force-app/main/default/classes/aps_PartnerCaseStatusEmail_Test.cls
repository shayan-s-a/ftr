/**
 * @description       :
 * @author            : Monir Zaman
 * @group             :
 * @last modified on  : 26-10-2023
 * @last modified by  : Monir Zaman
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   21-09-2023   Monir Zaman   Initial Version
 **/
@isTest
public with sharing class aps_PartnerCaseStatusEmail_Test {
  @isTest
  public static void tstMethodt() {
    Id globalAccRecordType = [
      SELECT Id, Name, DeveloperName, SobjectType
      FROM RecordType
      WHERE Name = 'Global' AND SobjectType = 'Account'
    ]
    .Id;

    Account accG = new Account(
      Name = 'test Account',
      RecordTypeId = globalAccRecordType
    );
    insert accG;

    Id masterAccRecordType = [
      SELECT Id, Name, DeveloperName, SobjectType
      FROM RecordType
      WHERE Name = 'Master' AND SobjectType = 'Account'
    ]
    .Id;

    Account accM = new Account(
      Name = 'test Account',
      RecordTypeId = masterAccRecordType,
      phone = '1234567890',
      ParentId = accG.Id
    );
    insert accM;

    Id defaultConRecordType = [
      SELECT Id, Name, DeveloperName, SobjectType
      FROM RecordType
      WHERE Name = 'default' AND SobjectType = 'Contact'
    ]
    .Id;

    Contact con = new Contact(
      LastName = 'test',
      AccountId = accM.Id,
      RecordTypeId = defaultConRecordType,
      Email = 'test@test.com'
    );
    insert con;

    FormData__c fd = new FormData__c(
      Name__c = 'test',
      Email__c = 'test@test.com',
      Reply_To_Emails__c = 'test1@test.com',
      Legal_Business_Name__c = 'test'
    );
    insert fd;

    Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName()
      .get('Partner Support Request')
      .getRecordTypeId();

    Case cs = new Case(
      AccountId = accM.Id,
      ContactId = con.Id,
      Status = '01-New',
      Origin = 'Web',
      FormData__c = fd.Id,
      Subject = 'test',
      RecordTypeId = caseRecordType
    );
    insert cs;

    aps_PartnerCaseStatusEmail.allEmailTemplate();
    aps_PartnerCaseStatusEmail.getEmailInfo(cs.Id);

    String toAddress = 'test@gmail.com';
    String ccAddress = 'test@gmail.com';
    String subject = 'test subject';
    String body = 'test body';
    String files = '[{"fileName": "file","fileContent": "fileContents"}]';
    aps_PartnerCaseStatusEmail.sendEmailController(
      toAddress,
      ccAddress,
      subject,
      body,
      files,
      cs.Id
    );
  }
}