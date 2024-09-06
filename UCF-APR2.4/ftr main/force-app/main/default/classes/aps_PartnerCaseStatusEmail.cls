/**
 * @description       :
 * @author            : Monir Zaman
 * @group             :
 * @last modified on  : 23-10-2023
 * @last modified by  : Monir Zaman
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   17-08-2023   Monir Zaman   Initial Version
 **/
public with sharing class aps_PartnerCaseStatusEmail {
  public aps_PartnerCaseStatusEmail() {
  }

  @AuraEnabled
  public static String allEmailTemplate() {
    return JSON.serialize(
      [
        SELECT Id, Name, DeveloperName, FolderName, IsActive, Markup
        FROM EmailTemplate
        WHERE DeveloperName LIKE 'PSR_%' AND IsActive = TRUE
      ]
    );
  }

  public class EmailInfo {
    public String ToAddress;
    public String CCAddress;
    public String Subject;
    public String CaseId;
  }

  @AuraEnabled
  public static String getEmailInfo(String rId) {
    Case cs = [
      SELECT Id, FormData__c, ContactId, CaseNumber, Partner_Request_Type__c
      FROM Case
      WHERE Id = :rId
    ];

    FormData__c fd = [
      SELECT Id, Email__c, Legal_Business_Name__c, Reply_To_Emails__c
      FROM FormData__C
      WHERE Id = :cs.FormData__c
    ];

    EmailInfo ei = new EmailInfo();
    ei.ToAddress = fd.Email__c;
    ei.CCAddress = fd.Reply_To_Emails__c;
    ei.Subject =
      cs.Partner_Request_Type__c +
      ' - Case#' +
      cs.CaseNumber +
      ' - ' +
      fd.Legal_Business_Name__c;
    ei.CaseId = cs.Id;

    List<EmailInfo> lstEI = new List<EmailInfo>();
    lstEI.add(ei);
    return JSON.serialize(ei);
  }

  public class FileDataWP {
    public String fileName;
    public Blob fileContent;
  }

  @AuraEnabled
  public static void sendEmailController(
    String toAddress,
    String ccAddress,
    String subject,
    String body,
    String files,
    String caseId
  ) {
    List<Messaging.EmailFileAttachment> email_attachments = new List<Messaging.EmailFileAttachment>();

    OrgWideEmailAddress[] owea = [
      SELECT Id
      FROM OrgWideEmailAddress
      WHERE Address = 'ent_sales_support_team@ftr.com'
    ];

    if (String.isNotBlank(files)) {
      List<FileDataWP> fileData = (List<FileDataWP>) JSON.deserialize(
        files,
        List<FileDataWP>.class
      );

      for (FileDataWP att : fileData) {
        Messaging.EmailFileAttachment email_att = new Messaging.EmailFileAttachment();
        email_att.filename = att.fileName;
        email_att.body = att.fileContent;

        email_attachments.add(email_att);
      }
    }

    messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();
    mail.setSaveAsActivity(true);
    mail.setWhatId(caseId);
    mail.setToAddresses(new List<String>{ toAddress });
    mail.setOrgWideEmailAddressId(owea[0].Id);

    if (!String.isEmpty(ccAddress)) {
      mail.setCcAddresses(ccAddress.split(','));
    }

    mail.setSubject(subject);
    mail.setHtmlBody(body);
    mail.setFileAttachments(email_attachments);

    Messaging.sendEmail(new List<messaging.SingleEmailMessage>{ mail });
  }
}