/**
 * @description       :
 * @author            : Monir Zaman
 * @group             :
 * @last modified on  : 21-08-2023
 * @last modified by  : Monir Zaman
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   16-08-2023   Monir Zaman   Initial Version
 **/
public with sharing class aps_ContentDocumentLink_Handler {
  public static void shareFormDataFile(List<ContentDocumentLink> listCDL) {
    Set<Id> setFDId = new Set<Id>();
    for (ContentDocumentLink cdl : listCDL) {
      setFDId.add(cdl.LinkedEntityId);
    }

    Map<Id, Id> mapFDvsC = new Map<Id, Id>();
    for (Case cs : [
      SELECT Id, FormData__c
      FROM Case
      WHERE FormData__c IN :setFDId
    ]) {
      mapFDvsC.put(cs.FormData__c, cs.Id);
    }

    List<ContentDocumentLink> lstNewCDL = new List<ContentDocumentLink>();
    for (ContentDocumentLink cdl : listCDL) {
      ContentDocumentLink newCDL = new ContentDocumentLink(
        LinkedEntityId = mapFDvsC.get(cdl.LinkedEntityId),
        ContentDocumentId = cdl.ContentDocumentId,
        Visibility = 'AllUsers',
        ShareType = 'V'
      );

      lstNewCDL.add(newCDL);
      insert lstNewCDL;
    }
  }
}