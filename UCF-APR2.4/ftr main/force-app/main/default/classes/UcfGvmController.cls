public class UcfGvmController {

    
    @AuraEnabled
    public static List<ftr_DID_Number_Details__c> ftrDIDNumberDetailsGeneralVoicemail(String recordId) {
        System.debug('Gvm: ' + recordId);
        List<ftr_DID_Number_Details__c> DIDNumberDetail = [
            SELECT Id,
        DIDNumber__c,
        EAS_Pin__c,
        Ucf_Extension__c,
        Ucf_General_Voice_Mail_Name__c,
         Ucf_Number_Use__c,
         Ucf_Customize_Extension__c,
         Ucf_Extension_Lenght__c,
         Ucf_Email__c
         FROM 
         ftr_DID_Number_Details__c 
         WHERE 
         Ucf_Number_Use__c='General Voice Mail'
         AND DIDLocationDetailsId__r.OrderId__c  =: recordId];
         
        return DIDNumberDetail;
    }

    @AuraEnabled
    public static List<ftr_DID_Number_Details__c> downloadFtrDIDNumberDetailsGeneralVoicemail(String recordId) {
        System.debug('Gvm: ' + recordId);
        List<ftr_DID_Number_Details__c> DIDNumberDetail = [
            SELECT Id,
            DIDNumber__c,
            EAS_Pin__c,
            Ucf_Extension__c,
            Ucf_General_Voice_Mail_Name__c,
             Ucf_Email__c
             FROM 
             ftr_DID_Number_Details__c 
             WHERE 
             Ucf_Number_Use__c='General Voice Mail'
             AND DIDLocationDetailsId__r.OrderId__c  =: recordId];
         
        return DIDNumberDetail;
    }
      
       @AuraEnabled
    public static string loadCSVDataForGenralVoicemail(Id contentDocumentId){

        ContentVersion contentVersionObj = [ SELECT Id, VersionData FROM 
                                             ContentVersion WHERE 
                                             ContentDocumentId =:contentDocumentId ];
        
         List<ftr_DID_Number_Details__c> dataToUpesert = new List<ftr_DID_Number_Details__c>();
         
         String data= (String) contentVersionObj.VersionData.toString();

         string[] csvFileLines=data.split('\n');

         for(Integer i=1;i<csvFileLines.size();i++){
            
            string[] csvRecordData = csvFileLines[i].split(',');
            
            ftr_DID_Number_Details__c DIDNumber = new ftr_DID_Number_Details__c();
            DIDNumber.Id = csvRecordData[0];
            DIDNumber.DIDNumber__c = csvRecordData[1] ;             
            DIDNumber.Ucf_Extension__c = csvRecordData[2];
            DIDNumber.Ucf_General_Voice_Mail_Name__c = csvRecordData[3];
            DIDNumber.Ucf_Email__c = csvRecordData[4];
            DIDNumber.DID_Number__c = DIDNumber.DIDNumber__c ;

            System.debug('logLevel'+ csvRecordData[0]);
            dataToUpesert.add(DIDNumber);   
        }

        upsert dataToUpesert;

        return string.valueOf(dataToUpesert.size());
    

    }

     @AuraEnabled
    public static String updateftrDIDNumberDetailsEmployeeTab(List<ftr_DID_Number_Details__c> recordsToUpdate) {
        try {
            // Perform updates on the records
            update recordsToUpdate;

            return 'Records updated successfully.';
        } catch (Exception e) {
            return 'Error updating records: ' + e.getMessage();
        }
    }



}