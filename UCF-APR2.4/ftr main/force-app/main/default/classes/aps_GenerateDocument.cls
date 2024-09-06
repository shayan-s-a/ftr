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
public with sharing class aps_GenerateDocument {
  public aps_GenerateDocument() {
  }

  @AuraEnabled
  public static List<Opportunity> wholesaleData(Id rId) {
    return [
      SELECT Id, Spring_Folder_Name__c, Account.Spring_Folder_Name__c
      FROM Opportunity
      WHERE Id = :rId
    ];
  }

  @AuraEnabled
  public static List<Contract> mtuData(Id rId) {
    return [
      SELECT
        Id,
        Spring_Contract_Folder_Name__c,
        Account_Channel__c,
        Agreement_Type__c
      FROM Contract
      WHERE Id = :rId
    ];
  }

  @AuraEnabled
  public static List<Contract> mduData(Id rId) {
    return [
      SELECT Id, Spring_Folder_Name__c, Account_Channel__c, Agreement_Type__c
      FROM Contract
      WHERE Id = :rId
    ];
  }
}