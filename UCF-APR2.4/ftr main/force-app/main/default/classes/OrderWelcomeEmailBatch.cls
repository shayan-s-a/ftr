global class OrderWelcomeEmailBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Retrieve the RecordType Id for "UCaaS New Order"
    Id ucaasRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('UCaaS New Order').getRecordTypeId();
        
        // Query to get orders with specific criteria
        return Database.getQueryLocator([
            SELECT Id, Account_Name__c, OrderNumber, Technical_Contact_Email__c,
                   Hot_Cut__r.Email,
                   Network_Project_Specialist__r.FirstName,
                   Network_Project_Specialist__r.LastName,
                   Network_Project_Specialist__r.Email,
                   Network_Project_Specialist__r.Phone
            FROM Order 
            WHERE Order_Stage__c IN ('In progress', 'Complete')
            AND RecordTypeId = :ucaasRecordTypeId
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Order> scope) {
        // Iterate through each order
        for (Order ord : scope) {
            // Debug log for Order Id
            System.debug('Processing Order: ' + ord.Id);
            
            // Fetch related information from the order
            String recordId = ord.Id;
            String sfCompanyName = ord.Account_Name__c;
            String orderNumber = ord.OrderNumber;
            String technicalContactEmail = ord.Technical_Contact_Email__c;
            String hotCutEmail = ord.Hot_Cut__r.Email;
            String implementationSpecialistFirstName = ord.Network_Project_Specialist__r.FirstName;
            String implementationSpecialistLastName = ord.Network_Project_Specialist__r.LastName;
            String implementationSpecialistEmail = ord.Network_Project_Specialist__r.Email;
            String implementationSpecialistPhoneNumber = ord.Network_Project_Specialist__r.Phone;

            // Debug log for fetched data
            System.debug('Fetched Data: ' + 'Company Name: ' + sfCompanyName + ', Order Number: ' + orderNumber);
            
            // Query to fetch earliest service location with hot cut due date within 3 days prior
            List<ftr_DID_Location_Details__c> serviceLocations = [SELECT Id, DueDate__c 
                                                                   FROM ftr_DID_Location_Details__c 
                                                                   WHERE OrderId__c = :recordId
                                                                   AND DueDate__c >= :Date.today().addDays(3)
                                                                   AND DueDate__c <= :Date.today().addDays(3)
                                                                   ORDER BY DueDate__c ASC LIMIT 1];

            // Check if there is a service location found
            if (!serviceLocations.isEmpty()) {
                // Fetch number details for the service locations
                List<ftr_DID_Number_Details__c> numberDetails = [SELECT Id, Ucf_Extension__c, Ucf_User_Name__c,
                                                                             DIDLocationDetailsId__r.Service_Account_Name__c,
                                                                             Ucf_User_Admin__c, Ucf_Email__c,
                                                                             DID_Number__c, EAS_Pin__c,
                                                                             DIDLocationDetailsId__r.Name,
                                                                             Ucf_Number_Use__c
                                                                             FROM ftr_DID_Number_Details__c 
                                                                             WHERE DIDLocationDetailsId__r.OrderId__c = :recordId
                                                                             AND Ucf_Number_Use__c = 'DID'];
                
                // Debug log for service locations
                System.debug('Service Locations: ' + serviceLocations);
                
                // Check if numberDetails and serviceLocations are not empty before proceeding
                if (!numberDetails.isEmpty()) {
                    // Retrieve the email template
                    EmailTemplate emailTemp = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'Order_Welcome_email' LIMIT 1];
                    
                    // Debug log for email template
                    System.debug('Email Template: ' + emailTemp);
                    
                    //Your logic for creating and sending emails goes here
                    String defaultEmailContent = emailTemp.HtmlValue;
                    
                    // Replace placeholders with values, adding null checks
                    defaultEmailContent = defaultEmailContent.replace('{!OrderItem}', generateNumberDetailsTable(numberDetails));
                    defaultEmailContent = defaultEmailContent.replace('{!ImplementationSpecialistFirstName}', implementationSpecialistFirstName != null ? implementationSpecialistFirstName : '');
                    defaultEmailContent = defaultEmailContent.replace('{!ImplementationSpecialistLastName}', implementationSpecialistLastName != null ? implementationSpecialistLastName : '');
                    defaultEmailContent = defaultEmailContent.replace('{!ImplementationSpecialistEmail}', implementationSpecialistEmail != null ? implementationSpecialistEmail : '');
                    defaultEmailContent = defaultEmailContent.replace('{!ImplementationSpecialistPhoneNumber}', implementationSpecialistPhoneNumber != null ? implementationSpecialistPhoneNumber : '');

                    // Debug log for email content
                    System.debug('Email Content: ' + defaultEmailContent);
                    
                    // Check if the hot cut email and implementation specialist email are not null before adding them to the CC list
                    List<String> ccAddresses = new List<String>();
                    if (hotCutEmail != null) {
                        ccAddresses.add(hotCutEmail);
                    }
                    if (implementationSpecialistEmail != null) {
                        ccAddresses.add(implementationSpecialistEmail);
                    }
                    
                    
                    List<OrgWideEmailAddress> orgAddresses = [SELECT id FROM OrgWideEmailAddress WHERE DisplayName = 'Frontier Communication' limit 1];
                    // Create email message
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] sendingTo = new String[]{technicalContactEmail};
                    mail.setToAddresses(sendingTo);
                    mail.setOrgWideEmailAddressId(orgAddresses[0].Id);
                    mail.setSubject('Welcome Letter - ' + sfCompanyName + ' - ' + orderNumber);
                    mail.setHtmlBody(defaultEmailContent);
                    // Set up CC addresses
                    mail.setCcAddresses(ccAddresses); // Set CC addresses
                    mail.setWhatId(recordId);
                    mail.saveAsActivity = true;
                    
                    // Debug log for file attachments
                    System.debug('File Attachments: ' + generateFileAttachments(recordId));
                    
                    // Attach file attachments
                    mail.setFileAttachments(generateFileAttachments(recordId));
                    
                    // Send email
                    System.debug('Sending email...');
                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
                }
            }
            else {
                // No service location found for the order, log a message
                System.debug('No service location found for the order: ' + ord.Id);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Any post-batch execution logic can be added here
    }
    global void execute(SchedulableContext sc) {
        // Schedule the batch to run
        OrderWelcomeEmailBatch batch = new OrderWelcomeEmailBatch();
        Database.executeBatch(batch, 5); 
    }
    
    // Method to generate HTML table for number details
    private String generateNumberDetailsTable(List<ftr_DID_Number_Details__c> numberDetails) {
        String numberDetailsTable = '<table border="1"><tr><th>Extension</th><th>Name/Label</th><th>Address</th><th>Business User Admin</th><th>Email</th><th>Telephone Number</th><th>EAS Pin</th></tr>';
        for (ftr_DID_Number_Details__c employeeInfo : numberDetails) {
            numberDetailsTable += '<tr>';
            numberDetailsTable += '<td>' + (employeeInfo.Ucf_Extension__c != null ? employeeInfo.Ucf_Extension__c : '-') + '</td>';
            numberDetailsTable += '<td>' + (employeeInfo.Ucf_User_Name__c != null ? employeeInfo.Ucf_User_Name__c : '-') + '</td>';   
            numberDetailsTable += '<td>' + (employeeInfo.DIDLocationDetailsId__r.Service_Account_Name__c != null ? employeeInfo.DIDLocationDetailsId__r.Service_Account_Name__c : '-') + '</td>';
            numberDetailsTable += '<td>' + (employeeInfo.Ucf_User_Admin__c != null ? employeeInfo.Ucf_User_Admin__c : '-') + '</td>';
            numberDetailsTable += '<td>' + (employeeInfo.Ucf_Email__c != null ? employeeInfo.Ucf_Email__c : '-') + '</td>';
            numberDetailsTable += '<td>' + (employeeInfo.DID_Number__c != null ? employeeInfo.DID_Number__c : '-') + '</td>';
            numberDetailsTable += '<td>' + (employeeInfo.EAS_Pin__c != null ? String.valueOf(employeeInfo.EAS_Pin__c) : '-') + '</td>';
            numberDetailsTable += '</tr>';
        }
        numberDetailsTable += '</table>';
        return numberDetailsTable;
    }
    
    // Method to generate file attachments from UCF 911 library folder
    private List<Messaging.EmailFileAttachment> generateFileAttachments(String orderId) {
        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
        
        String ucf911 = System.label.welcomeEmailFolder;
        // Query for ContentDocumentLinks related to the UCF 911 library folder
        List<ContentDocumentLink> documentLinks = [
            SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.CreatedDate
            FROM ContentDocumentLink
            WHERE LinkedEntity.Name =:ucf911];
        
        // Loop through each ContentDocumentLink
        for (ContentDocumentLink documentLink : documentLinks) {
            // Query for ContentVersion records related to the ContentDocument
            List<ContentVersion> contentVersions = [
                SELECT Id, VersionData, Title, FileType
                FROM ContentVersion
                WHERE ContentDocumentId = :documentLink.ContentDocumentId
                ORDER BY CreatedDate DESC
            ];
            
            // Loop through each ContentVersion
            for (ContentVersion contentVersion : contentVersions) {
                // Create EmailFileAttachment for each ContentVersion
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                
                // Extract file extension from ContentVersion or ContentDocument
                String fileExtension = contentVersion.FileType != null ? contentVersion.FileType.toLowerCase() : '';
                if (String.isBlank(fileExtension)) {
                    fileExtension = documentLink.ContentDocument.FileExtension != null ? documentLink.ContentDocument.FileExtension.toLowerCase() : '';
                }
                
                // Set file name and body for EmailFileAttachment
                efa.setFileName(contentVersion.Title + '.' + fileExtension);
                efa.setBody(contentVersion.VersionData);
                
                // Add EmailFileAttachment to the list
                fileAttachments.add(efa);
            }
        }
        
        return fileAttachments;
    }


}