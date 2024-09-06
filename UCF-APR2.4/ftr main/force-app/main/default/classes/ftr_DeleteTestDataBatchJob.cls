global class ftr_DeleteTestDataBatchJob implements Database.Batchable<SObject>, Database.Stateful  {
    @TestVisible private class DeleteDataException extends Exception {}
    global User jobInitiatedBy;
    global Account company;
    global Boolean deleteAllRecords = false;
    global Exception[] exceptions = new Exception[]{};
    global Boolean reRunBatch = false;

    global ftr_DeleteTestDataBatchJob(String companyName) {
        setup(companyName);
    }
    
    global ftr_DeleteTestDataBatchJob(String companyName, Boolean deleteAllRecords) {
        setup(companyName);
        this.deleteAllRecords = deleteAllRecords;
    }

    private void setup(String companyName) {
        if ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox || Test.isRunningTest()) {

            if (String.isBlank(companyName)) {
                throw new DeleteDataException('A company is required');
            } else {
                this.jobInitiatedBy = [SELECT Id, UserName, Email FROM User WHERE Id =:UserInfo.getUserId()];

                // first try to get by Id
                try {
                    this.company = [SELECT Id, Name, Owner.Name FROM Account WHERE Id =:companyName LIMIT 1];
                } catch (Exception e) {

                    // if its not by Id, find by name
                    try {
                        this.company = [SELECT Id, Name, Owner.Name FROM Account WHERE Name =:companyName LIMIT 1];
                    } catch (Exception ex) {
                        system.debug(ex.getMessage());
                        system.debug(ex.getStackTraceString());
                        throw new DeleteDataException(companyName + ' not found');
                    }
                }
            }
        } else {
            throw new DeleteDataException('This Batch Job cannot be run in production.');
        }
    }

    global List<SObject> start(Database.BatchableContext ctx) {
        List<SObject> allRecords = new List<SObject>();

        // get the opps under that company
        Map<Id, SObject> opps = new Map<Id, SObject>([SELECT Id FROM Opportunity WHERE AccountId =: this.company.Id]);
        if (opps.isEmpty()) return allRecords;

        // get all files from the opps under that company
        Set<Id> contentDocIds = new Set<Id>();
        for (ContentDocumentLink link : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:opps.keySet()]) {
            contentDocIds.add(link.ContentDocumentId);
        }
        allRecords.addAll([SELECT Id FROM ContentDocument WHERE Id IN :contentDocIds]);

        // get all the rest of the data to delete
        if (this.deleteAllRecords) {
            allRecords.addAll([SELECT Id FROM OpportunityLineItem WHERE OpportunityId =:opps.keySet()]);
            allRecords.addAll([SELECT Id FROM ftr_EVC_Location_Details__c WHERE OrderItem__r.Order.OpportunityId =:opps.keySet()]);
            allRecords.addAll([SELECT Id FROM ftr_UNI_Location_Details__c WHERE OrderItem__r.Order.OpportunityId =:opps.keySet()]);
            allRecords.addAll([SELECT Id FROM Order WHERE OpportunityId =:opps.keySet()]);
            allRecords.addAll([SELECT Id FROM Contract WHERE Opportunity__c =:opps.keySet()]);
            allRecords.addAll([SELECT Id FROM Quote WHERE OpportunityId =:opps.keySet()]);
            allRecords.addAll([SELECT Id FROM SterlingQuoteItem__c WHERE OpportunityId__c =:opps.keySet()]);
            allRecords.addAll([SELECT Id FROM SterlingQuote__c WHERE OpportunityId__c =:opps.keySet()]);
            allRecords.addAll(opps.values());
        }

        return allRecords;
    }

    global void execute(Database.BatchableContext ctx, List<SObject> recordsToDelete) {
        try {
            delete recordsToDelete;
        } catch(Exception e){
            this.exceptions.add(e);
        }
    }

    global void finish(Database.BatchableContext ctx) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<String> toAddresses = new List<String> { this.jobInitiatedBy.Email.replace('.invalid', '') };
        mail.setToAddresses(toAddresses);

        if (this.exceptions.isEmpty()) {
            mail.setHtmlBody(
                'Test Data deleted successfully for: ' 
                + this.company.Name + ' <br/><br/>' 
                + 'Job Initiated by: ' + this.jobInitiatedBy.UserName
            );
            mail.setSubject('Success - Delete Test Data Batch Job');

        } else {
            String errors = '';
            for (Exception e : this.exceptions) {
                errors += 'Error Message: ' + e.getMessage() + ' <br/><br/>'
                        + 'Stack Trace: ' + ' <br/>' + e.getStackTraceString() + ' <br/><br/>';
            }
            
            mail.setHtmlBody(
                'Delete Test Data Batch Job failed for: ' + this.company.Name + ' <br/><br/>'
                + 'Job Initiated by: ' + this.jobInitiatedBy.UserName + '<br/><br/>'
                + errors
            );
            mail.setSubject('Error - Delete Test Data Batch Job');
        }
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    @AuraEnabled
    global static List<SObject> deleteTestData(String companyName, Boolean allData) {
        try {
            String jobId = Database.executeBatch(new ftr_DeleteTestDataBatchJob(companyName, allData), 200);
            return ftr_DeleteTestDataBatchJob.getJobStatus(jobId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    global static List<SObject> getJobStatus(String jobId) {
        try {
            return [
                SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                FROM AsyncApexJob  
                WHERE Id =: jobId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}