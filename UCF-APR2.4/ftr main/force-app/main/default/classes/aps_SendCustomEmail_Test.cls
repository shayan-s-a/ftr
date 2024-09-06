/**
 * @description       :
 * @author            : Monir Zaman
 * @group             :
 * @last modified on  : 26-10-2023
 * @last modified by  : Monir Zaman
 * Modifications Log
 * Ver   Date         Author        Modification
 * 2.0   21-09-2023   Monir Zaman   Initial Version
 **/
@isTest
public with sharing class aps_SendCustomEmail_Test {
  @isTest
  static void sendButtonEmailTest() {
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

    List<aps_SendCustomEmail.Requests> listRequest = new List<aps_SendCustomEmail.Requests>();
    aps_SendCustomEmail.Requests req = new aps_SendCustomEmail.Requests();
    req.objName = 'Case';
    req.rId = cs.Id;
    listRequest.add(req);

    List<aps_SendCustomEmail.Requests> listRequest1 = new List<aps_SendCustomEmail.Requests>();
    aps_SendCustomEmail.Requests req1 = new aps_SendCustomEmail.Requests();
    req1.objName = 'Case';
    req1.rId = cs.Id;

    listRequest1.add(req1);

    aps_SendCustomEmail.execute(listRequest);
    aps_SendCustomEmail.execute(listRequest1);
  }
}