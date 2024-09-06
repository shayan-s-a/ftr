/**
 * @description       :
 * @author            : Monir Zaman
 * @group             :
 * @last modified on  : 25-01-2024
 * @last modified by  : Monir Zaman
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   26-06-2023   Monir Zaman   Initial Version
 **/
public with sharing class aps_SendCustomEmail {
  public class Requests {
    @InvocableVariable(label='Object Name' required=true)
    public String objName;

    @InvocableVariable(label='Record Id' required=true)
    public String rId;
  }

  @InvocableMethod(label='Send Custom Email')
  public static void execute(List<Requests> listRequests) {
    if (listRequests[0].objName == 'Case') {
      EmailTemplate et = [
        SELECT Id, Markup
        FROM EmailTemplate
        WHERE DeveloperName = 'PSR_Case_Status_Email'
      ];

      OrgWideEmailAddress[] owea = [
        SELECT Id
        FROM OrgWideEmailAddress
        WHERE Address = 'ent_sales_support_team@ftr.com'
      ];

      Case cs = [
        SELECT Id, FormData__c, ContactId, Subject
        FROM Case
        WHERE Id = :listRequests[0].rId
      ];

      FormData__c fd = [
        SELECT Id, Email__c, Reply_To_Emails__c, User__c, Type__c
        FROM FormData__C
        WHERE Id = :cs.FormData__c
      ];

      List<String> listToAddress = new List<String>();
      List<String> listCCAddress = new List<String>();

      if (fd.Email__c != null) {
        listToAddress.add(fd.Email__c);
      }
      if (fd.Reply_To_Emails__c != null) {
        listCCAddress = fd.Reply_To_Emails__c.split(',');
      }

      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setTemplateId(et.Id);

      if (fd.Type__c.contains('Direct')) {
        mail.setTargetObjectId(fd.User__c);
        mail.setSaveAsActivity(false);
      } else {
        mail.setTargetObjectId(cs.ContactId);
        mail.setSaveAsActivity(true);
      }

      mail.setWhatId(listRequests[0].rId);
      mail.setToAddresses(listToAddress);
      mail.setOrgWideEmailAddressId(owea[0].Id);

      if (listCCAddress.size() > 0) {
        mail.setCcAddresses(listCCAddress);
      }

      Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
        mail
      };

      Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
      if (results[0].success) {
        System.debug('The email was sent successfully.');
      } else {
        System.debug(
          'The email failed to send: ' + results[0].errors[0].message
        );
      }
    }

    if (listRequests[0].objName == 'Contract') {
    }
  }
}