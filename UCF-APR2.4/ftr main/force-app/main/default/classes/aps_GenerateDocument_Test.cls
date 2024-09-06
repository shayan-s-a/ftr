/**
 * @description       :
 * @author            : Monir Zaman
 * @group             :
 * @last modified on  : 19-01-2024
 * @last modified by  : Monir Zaman
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   19-01-2024   Monir Zaman   Initial Version
 **/
@isTest
public with sharing class aps_GenerateDocument_Test {
  @isTest
  static void testHandle() {
    Id AccRType = [
      SELECT id
      FROM RecordType
      WHERE RecordType.Name = 'MTU Company' AND SobjectType = 'Account'
    ]
    .Id;

    Account testSAccount = new Account(
      RecordTypeId = AccRType,
      Name = 'Test Service Account',
      BillingStreet = '123 Main Street',
      BillingCity = 'Anywhere',
      BillingState = 'Ohio',
      BillingPostalCode = '44088',
      ShippingStreet = '123 Main Street',
      ShippingCity = 'Anywhere',
      ShippingState = 'Ohio',
      ShippingPostalCode = '44088'
    );
    insert testSAccount;

    Id OppRType = [
      SELECT id
      FROM RecordType
      WHERE
        RecordType.Name = 'MTU Opportunities'
        AND SobjectType = 'Opportunity'
    ]
    .Id;

    Opportunity opp = new Opportunity(
      RecordTypeId = OppRType,
      Name = 'RefreshTestOpp',
      AccountId = testSAccount.Id,
      CloseDate = date.today(),
      StageName = 'Investigating',
      CPE_Product__c = 'No'
    );
    insert opp;

    Id ContrRType = [
      SELECT id
      FROM RecordType
      WHERE RecordType.Name = 'MTU Contract' AND SobjectType = 'Contract'
    ]
    .Id;

    Contract PALCon = new Contract(
      RecordTypeId = ContrRType,
      AccountId = testSAccount.Id,
      Opportunity__c = opp.Id,
      Status = 'Draft',
      StartDate = date.today(),
      ContractTerm = 24,
      Agreement_Type__c = 'PAL'
    );
    insert PALCon;

    Contract MarCon = new Contract(
      RecordTypeId = ContrRType,
      AccountId = testSAccount.Id,
      Opportunity__c = opp.Id,
      Status = 'Draft',
      StartDate = date.today(),
      ContractTerm = 24,
      Agreement_Type__c = 'Marketing'
    );
    insert MarCon;

    aps_GenerateDocument.wholesaleData(opp.Id);

    aps_GenerateDocument.mtuData(PALCon.Id);
    aps_GenerateDocument.mtuData(MarCon.Id);

    aps_GenerateDocument.mduData(PALCon.Id);
  }
}