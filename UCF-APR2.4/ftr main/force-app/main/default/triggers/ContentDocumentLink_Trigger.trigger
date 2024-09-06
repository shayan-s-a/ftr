/**
 * @description       :
 * @author            : Monir Zaman
 * @group             :
 * @last modified on  : 02-07-2024
 * @last modified by  : Md Mehedi Hasan
 * Modifications Log
 * Ver   Date         Author        Modification
 * 2.0   16-08-2023   Monir Zaman   Initial Version
 **/
trigger ContentDocumentLink_Trigger on ContentDocumentLink(after insert) {
  if (Trigger.isInsert) {
    if (Trigger.isAfter) {
      List<ContentDocumentLink> listCDL = new List<ContentDocumentLink>();

      for (ContentDocumentLink cdl : Trigger.new) {
        if (
          cdl.LinkedEntityId.getSObjectType().getDescribe().getName() ==
          'FormData__c'
        ) {
          listCDL.add(cdl);
        }
      }

      aps_ContentDocumentLink_Handler.shareFormDataFile(listCDL);
    }
  }
}