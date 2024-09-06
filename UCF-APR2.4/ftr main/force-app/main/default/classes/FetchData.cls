public class FetchData {
    @AuraEnabled(cacheable=true)
    public static List<Account> queryAccounts() {
        List<Account> accounts = [SELECT Id, Name,BillingCity, Account_Channel__c
         FROM Account order by createddate desc  limit 10 ];
        return accounts;
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> queryAccounts2() {
        List<Account> accounts = [SELECT Id, Name,BillingCity,Account_Owner_Email__c,
         Account_Channel__c,vlocity_cmt__Status__c,Agent_Fax_Number__c,vlocity_cmt__ContactPreferences__c 
        FROM Account WHERE Account_Channel__c != null AND BillingCity!= null ];
        return accounts;
    }
    
    public static String normalizeSpaces(String input) {
    return input.replaceAll('\\s+', ' ').trim();
}

    @AuraEnabled
public static String checkDID(String did, String qualification, String recordId, String Location,String CurrentCarrier,Boolean CustomExt, String ExtLength,String InstallType) {
    try {
        // Debug log for the phone record ID
        String Result='';
        Map<String,object> MapOfNpaResponse;
        String Response='';
        // Extract the first 6 digits from the DID
        String NPA = did.substring(0, 3);
        String NXX = did.substring(3, 6);
        
        Decimal NPADecimal = Decimal.valueOf(NPA);
        Decimal NXXDecimal = Decimal.valueOf(NXX);

        system.debug('100 NPADecimal ' + NPADecimal);
          system.debug('100 NPADecimal ' + NXXDecimal);

        // Query for matching NPANXX records
        
          List<ftr_VOIP_Qualification__c> matchingRecords = [
            SELECT Id,Available_VOIP__c,Rate_Center__c
            FROM ftr_VOIP_Qualification__c 
            WHERE NPA__c =:NPADecimal AND NXX__c =:NXXDecimal
            LIMIT 1
        ];
        
          system.debug('100 matchingRecords ' + matchingRecords);
        
        
        list<ftr_DID_Number_Details__c> existingDidDetails = new list<ftr_DID_Number_Details__c>();


        // Debug logs
        System.debug('Phone Did : ' + did);
        System.debug('Phone qualification : ' + qualification);
        System.debug('Phone NXX ' + NXX + 'Phone NPA' + NPA);
        System.debug('Phone matchingRecords : ' + matchingRecords.size());

        // Query for existing DID details
        // 
        if(matchingRecords.size() > 0)
        {
            existingDidDetails = [
            SELECT Id, Ucf_Voip_Qualification__c 
            FROM ftr_DID_Number_Details__c 
            WHERE DID_Number__c = :did
            LIMIT 1
        ];
            
             System.debug('Phone existingDidDetails : ' + existingDidDetails);
        }
        
        String normalizedLocation = normalizeSpaces(Location);
		
        system.debug('test 0001 Location >>>>> '+ Location);
        List<ftr_DID_Location_Details__c> DIDLocDetailListRaw = [
            SELECT id, Name, OrderId__c, ServiceAccountId__c, ServiceAccountId__r.Name, UCFNameValidation__c 
            FROM ftr_DID_Location_Details__c 
            WHERE OrderId__c = :recordId
        ];
        
        List<ftr_DID_Location_Details__c> DIDLocDetailList = new List<ftr_DID_Location_Details__c>();
        for (ftr_DID_Location_Details__c detail : DIDLocDetailListRaw) {
            if (normalizeSpaces(detail.UCFNameValidation__c) == normalizedLocation) {
                DIDLocDetailList.add(detail);
    }
        }
        
         system.debug('test 0001 DIDLocDetailList >>>>> '+ DIDLocDetailList);
         system.debug('test 0001 DIDLocDetailList count >>>>> '+ DIDLocDetailList.size());
        // Check if the DID number already exists
        if(existingDidDetails.size() > 0) {
             System.debug('Phone Update');
            ftr_DID_Number_Details__c existing = existingDidDetails[0];
            existing.Ucf_Number_Use__c = qualification;
            existing.Ucf_Current_Carrier__c=CurrentCarrier;
            existing.Ucf_Install_type__c=InstallType;
            if(DIDLocDetailList.size() > 0)
            {
              existing.DIDLocationDetailsId__c=DIDLocDetailList[0].id;
            }
            
            
            update existing;
            return 'Record updated because the number already exists.';
        } else if(existingDidDetails.size() == 0 ) {
            
            
            
            // Create a new DID Number Details record
            ftr_DID_Number_Details__c newDetails = new ftr_DID_Number_Details__c(
                DID_Number__c = did,
                name = did,
                DIDNumber__c = did,
                Ucf_Number_Use__c = qualification,
                Ucf_Customize_Extension__c=CustomExt,
                Ucf_Extension_Lenght__c=ExtLength,
                Ucf_Current_Carrier__c=CurrentCarrier,
                Ucf_Install_type__c=InstallType
            );
             if(CustomExt == false){
                String DIDNumber=newDetails.DIDNumber__c;
                if(!String.isBlank(ExtLength)){
                    String ext = DIDNumber.right(Integer.valueOf(ExtLength));
                newDetails.Ucf_Extension__c=ext;
                }   
                
            }
            if (!DIDLocDetailList.isEmpty() ) {
                ftr_DID_Location_Details__c DIDLocDetail = DIDLocDetailList[0];
                system.debug('test 0001 Loc Id '+ DIDLocDetail.id);
                newDetails.DIDLocationDetailsId__c = DIDLocDetail.id;
            }
            if(!matchingRecords.isEmpty() && qualification != 'Toll Free'){
                system.debug('test 0001');
                newDetails.Ucf_Voip_Qualification__c=matchingRecords[0].Available_VOIP__c;
                newDetails.RateCenter__c=matchingRecords[0].Rate_Center__c;
                insert newDetails;
                system.debug('test 0002');
                Result='Successfully inserted the record.';
            }
            else if(matchingRecords.isEmpty() && qualification != 'Toll Free'){
                  system.debug('test 0003');
                Response=VoipQualificationCallout(NPA,NXX);
                MapOfNpaResponse=(Map<String,object>)JSON.deserializeUntyped(Response);
                system.debug('Debug::MapOfNpaResponse'+MapOfNpaResponse.get('success'));
                if(MapOfNpaResponse.get('success') == true){
                    system.debug('Debug::MapOfNpaResponse'+MapOfNpaResponse);
                newDetails.Ucf_Voip_Qualification__c=(String)MapOfNpaResponse.get('AvailableVOIP');
                newDetails.RateCenter__c=(String)MapOfNpaResponse.get('RateCenter');
                insert newDetails;
                ftr_VOIP_Qualification__c NewVoipQualification=new ftr_VOIP_Qualification__c(Available_VOIP__c=(String)MapOfNpaResponse.get('AvailableVOIP'),
                Rate_Center__c=(String)MapOfNpaResponse.get('RateCenter'),
                NPA__c=Integer.valueOf(MapOfNpaResponse.get('NPA')),
                NXX__c=Integer.valueOf(MapOfNpaResponse.get('NXX')),
                E911_Type__c=(String)MapOfNpaResponse.get('E911Type'),
                IsThirdParty__c=(Boolean)MapOfNpaResponse.get('IsThirdParty'),
                State__c=(String)MapOfNpaResponse.get('State'),
                LATA__c=(String)MapOfNpaResponse.get('LATA'),
                OCN__c=(String)MapOfNpaResponse.get('OCN'),
                OCN_Name__c=(String)MapOfNpaResponse.get('OCNName'),
                ServiceAccountId__c=DIDLocDetailList[0].ServiceAccountId__c);
                Insert NewVoipQualification;
                Result='Successfully inserted the record.';
                }
            else{
                 system.debug('test 0004');
                Result='Phone does not qualify for Voip Qualification';
            }
            }
            else{
                 system.debug('test 0005');
                insert newDetails;
                Result='Successfully inserted the record.';
            }
             
            return Result;
        } else {
            throw new AuraHandledException('No matching NPANXX found in ftr_PSRExchangeDetail__c and the DID does not exist.');
        }
    } catch (Exception e) {
        // Catch any exceptions that occur and log them
        System.debug('Exception occurred: ' + e.getMessage());
        throw new AuraHandledException('An error occurred: ' + e.getMessage());
    }
}


    @AuraEnabled
public static void deleteSelectedDIDNumbers(List<Id> selectedIds) {
    List<ftr_DID_Number_Details__c> recordsToDelete = [SELECT Id FROM ftr_DID_Number_Details__c WHERE Id IN :selectedIds];
    delete recordsToDelete;
}
    
     @AuraEnabled
public static void deleteGroupMembers(List<Id> recordIds) {
    List<Group_Member__c> membersToDelete = [SELECT Id FROM Group_Member__c WHERE Id IN :recordIds];
        delete membersToDelete;
    
}


@AuraEnabled
public static void deleteMLHGMembers(List<Id> recordIds) {
    List<MLHG_Member__c> membersToDelete = [SELECT Id FROM MLHG_Member__c WHERE Id IN :recordIds];
        delete membersToDelete;
    
}
    
     @AuraEnabled
    public static List<Map<String, String>> getServiceAccountOptions(String recordId) {
        List<Map<String, String>> options = new List<Map<String, String>>();
        Set<String> accountedNames = new Set<String>();

        for (ftr_DID_Location_Details__c detail : [SELECT Id, UCFNameValidation__c,ServiceAccountId__c,ServiceAccountId__r.Name,Service_Account_Name__c 
                                                    FROM ftr_DID_Location_Details__c 
                                                    WHERE ServiceAccountId__c != NULL 
                                                    AND OrderId__c = :recordId]) {
            if(!accountedNames.contains(detail.ServiceAccountId__c)) {
                Map<String, String> option = new Map<String, String>{
                    'Id' => detail.Id,
                    'Name' => detail.UCFNameValidation__c
                };
                options.add(option);
                accountedNames.add(detail.ServiceAccountId__c);
            }
        }
        return options;
    }

    @AuraEnabled
   public static list<ftr_DID_Number_Details__c> getOnloadDataforRbandCombo(String recordId)
   {
         List<ftr_DID_Number_Details__c> DIDNumberDetailss = [select id,Ucf_Extension_Lenght__c,RateCenter__c,
         Ucf_Customize_Extension__c FROM ftr_DID_Number_Details__c WHERE DIDLocationDetailsId__r.OrderId__c  =: recordId and Ucf_Extension_Lenght__c != null  limit 1];
         return DIDNumberDetailss;
   }

   @AuraEnabled(cacheable=false)
    public static List<ftr_DID_Number_Details__c> ftrDIDNumberDetails(String recordId) {
        List<ftr_DID_Number_Details__c> DIDNumberDetail = [SELECT Id,Name,Service_Account_Name__c,DIDNumber__c,DID_Number__c, Ucf_Voip_Qualification__c ,DIDLocationDetailsId__c,Ucf_Install_type__c,
        RateCenter__c,Ucf_Current_Carrier__c, DIDLocationDetailsId__r.UCFNameValidation__c,Ucf_Number_Use__c,Ucf_Extension__c,Ucf_Extension_Lenght__c,Ucf_Customize_Extension__c 
        FROM ftr_DID_Number_Details__c WHERE DIDLocationDetailsId__r.OrderId__c  =: recordId];
        System.debug('check ' + DIDNumberDetail.size());
        return DIDNumberDetail;
    }
    
@AuraEnabled
    public static List<Group_Member__c> getGroupMembers(String recordId) {
        List<Group_Member__c> getGroupMembers = [SELECT Id, DID_Number_Details__c, Page_Groups__c 
        FROM Group_Member__c WHERE Page_Groups__r.Order__c =: recordId];
        return getGroupMembers;
    }
    
    @AuraEnabled
    public static List<MLHG_Member__c> getMLHGMembers(String recordId) {
        List<MLHG_Member__c> getMLHGMembers = [SELECT Id, DID_Number_Details__c,Parent_DID_Number_Detail__c
        FROM MLHG_Member__c WHERE Parent_DID_Number_Detail__r.DIDLocationDetailsId__r.OrderId__c=: recordId];
        return getMLHGMembers;
    } 

    @AuraEnabled(cacheable=false)
    public static String updateDidLocationsBulk(List<ftr_DID_Number_Details__c> updatedRecords) {
        try {
            update updatedRecords;
            return 'Success';
        } catch(Exception e) {
            // Log the exception and return an error message
            System.debug('Error updating records: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }
    
    @AuraEnabled
    public static List<ftr_DID_Number_Details__c> ftrDIDNumberDetailsGeneralVoicemail(String recordId) {
        List<ftr_DID_Number_Details__c> DIDNumberDetail = [SELECT Id,DIDNumber__c,Ucf_Extension__c,Ucf_General_Voice_Mail_Name__c, Ucf_Number_Use__c,Ucf_Email__c FROM ftr_DID_Number_Details__c WHERE Ucf_Number_Use__c='General Voice Mail' AND DIDLocationDetailsId__r.OrderId__c  =: recordId];
        return DIDNumberDetail;
    }

    @AuraEnabled
    public static List<ftr_DID_Number_Details__c> ftrDIDNumberDetailsMLHG(String recordId) {
        List<ftr_DID_Number_Details__c> DIDNumberDetail = [SELECT Id,DIDNumber__c,Ucf_Extension__c FROM ftr_DID_Number_Details__c WHERE Ucf_Number_Use__c='Multi-Line Hunting Group' AND DIDLocationDetailsId__r.OrderId__c  =: recordId];
        return DIDNumberDetail;
    }

    @AuraEnabled
    public static List<ftr_DID_Number_Details__c> ftrDIDNumberDetailsEmployeeInfo(String recordId) {
        List<ftr_DID_Number_Details__c> DIDNumberDetail = [SELECT Id,DIDNumber__c,Outbound_Caller_ID__c,Ucf_Other_Outbound_Caller_ID__c,
        Ucf_Extension__c,Ucf_Department__c,Ucf_Email__c,Ucf_License_Type__c,
        Ucf_Dial_Plan_Information__c,Ucf_Collaboration__c,
        Ucf_Webinar__c,Ucf_Call_Recording__c,Ucf_Audio_Mining__c,Ucf_User_Name__c,Ucf_User_Admin__c,
        Ucf_Screen_Recording__c,Ucf_Storage__c,Ucf_Customize_Extension__c,Ucf_Extension_Lenght__c,  
        Ucf_Device_Type__c,Ucf_Device_Accessories__c,EAS_Pin__c,
        DIDLocationDetailsId__r.OrderId__r.quote.RCLicenseCount__c,Ucf_MAC_Address__c,  
            Ucf_Company_Name__c,Ucf_Address_Number__c,Ucf_Street_Name__c,   Ucf_City__c,    
            Ucf_State__c,   Ucf_Zip_Code__c,Ucf_Identifying_Location__c 
            FROM ftr_DID_Number_Details__c 
            WHERE Ucf_Number_Use__c='DID'
            AND DIDLocationDetailsId__r.OrderId__c  =: recordId
            ];
        return DIDNumberDetail;
    }
        
        @AuraEnabled(cacheable=true)
    public static List<Schedule__c> ScheduleforMLHGSetUp() {
        List<Schedule__c> Schedule = [SELECT Id,Name FROM Schedule__c ];
        return Schedule;
    }
    @AuraEnabled
    public static List<ftr_DID_Location_Details__c> FtrUcfDIDLocations(String OrderId) {
        Map<String,ftr_DID_Location_Details__c> MapOfDIDLocation=new Map<String,ftr_DID_Location_Details__c>();
        List<ftr_DID_Location_Details__c> DIDLocation = [select Id,UCFNameValidation__c,Service_Account_Name__c,Local_Routing_Number__c,ServiceAccountId__c,ServiceAccountId__r.Name,NPA__c,NXX__c,OrderId__c from ftr_DID_Location_Details__c where OrderId__c=: OrderId];
        for(ftr_DID_Location_Details__c Loc: DIDLocation)
        {
            MapOfDIDLocation.put(Loc.UCFNameValidation__c,Loc);
        }
        DIDLocation.clear();
        system.debug('Debug::DIDLocation'+DIDLocation);
        for(ftr_DID_Location_Details__c L : MapOfDIDLocation.values()){
            DIDLocation.add(L);
        }
        system.debug('Debug::DIDLocation'+DIDLocation);
        return DIDLocation;
    }
    @AuraEnabled
    public static List<ftr_VOIP_Qualification__c> FtrUcfVoipQualification(String OrderId) {
        List<ftr_DID_Location_Details__c> DIDLocation = [select Id,UCFNameValidation__c,Local_Routing_Number__c,ServiceAccountId__c,ServiceAccountId__r.Name,NPA__c,NXX__c,OrderId__c from ftr_DID_Location_Details__c where OrderId__c=: OrderId];
        Set<Id> SetOfServiceAccountId=new Set<Id>();

        for(ftr_DID_Location_Details__c Loc : DIDLocation){
            SetOfServiceAccountId.add(Loc.ServiceAccountId__c);
        }
        List<ftr_VOIP_Qualification__c> VoipQualifications = [select Id,Local_Routing_Number__c,ServiceAccountId__c,ServiceAccountId__r.Name,NPA__c,NXX__c from ftr_VOIP_Qualification__c where ServiceAccountId__c in: SetOfServiceAccountId];
        
        return VoipQualifications;
    }   
    @AuraEnabled
    public static List<ftr_DID_Number_Details__c> ftrNPANXXPhoneNumberDetails(String orderId) {
        system.debug('heree '+ orderId);
        List<ftr_DID_Number_Details__c> DIDNumberDetail=new List<ftr_DID_Number_Details__c>();
        DIDNumberDetail= [SELECT Id,DID_Number__c,Ucf_Voip_Qualification__c,Ucf_Current_Carrier__c,RateCenter__c,Ucf_Install_Type__c,Ucf_Number_Use__c,DIDLocationDetailsId__r.Name,Ucf_Customize_Extension__c,Ucf_Extension_Lenght__c,NPA__c, NXX__c,Local_Routing_Number__c FROM ftr_DID_Number_Details__c where DIDLocationDetailsId__r.OrderId__c=:orderId];
        system.debug('heree '+ DIDNumberDetail);
        Map<String,ftr_DID_Number_Details__c> MapOfDIDNumbers =new Map<String,ftr_DID_Number_Details__c>();
        for(ftr_DID_Number_Details__c DID : DIDNumberDetail)    
        {
            MapOfDIDNumbers.put(DID.DID_Number__c.substring(0, 3)+'-'+DID.DID_Number__c.substring(3, 6),DID);
        }
        DIDNumberDetail.clear();
        DIDNumberDetail=MapOfDIDNumbers.values();
        return DIDNumberDetail;
    }
    /* To change the NPA NXX update in Phone Numbers 
    @AuraEnabled(cacheable=false)
    public static String updateDidLocationsNXX(List<ftr_VOIP_Qualification__c> updatedRecords) {
        try {
            update updatedRecords;
            return 'Success';
        } catch(Exception e) {
            // Log the exception and return an error message
            System.debug('Error updating records: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }
    */
    @AuraEnabled(cacheable=false)
    public static String updateDidLocationsNXX(List<ftr_DID_Number_Details__c> updatedRecords) {
        try {
            update updatedRecords;
            return 'Success';
        } catch(Exception e) {
            // Log the exception and return an error message
            System.debug('Error updating records: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }
    @AuraEnabled(cacheable=false)
    public static String updateDIDNumbersNXX(List<ftr_DID_Number_Details__c> updatedRecords) {
        try {
            update updatedRecords;
            return 'Success';
        } catch(Exception e) {
            // Log the exception and return an error message
            System.debug('Error updating records: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }
    @AuraEnabled
    public static String updateftrDIDNumberDetails(List<String> ids, String extLength, Boolean isCustmizeExt) {
        try {
            List<Group_Member__c> ListOfGroupMemebers =new List<Group_Member__c>([Select id,DID_Number_Details__c from Group_Member__c where DID_Number_Details__c in: ids]);
        
            // Fetch records that need updates based on the provided IDs
        List<ftr_DID_Number_Details__c> lstToUpdateExtension = [SELECT id, DIDNumber__c,ucf_Customize_Extension__c, ucf_Extension_Lenght__c,Service_Account_Name__c,Ucf_Extension__c 
                                                                FROM ftr_DID_Number_Details__c WHERE id IN :ids];
        // Update the fields for each record
        for(ftr_DID_Number_Details__c record : lstToUpdateExtension) {
            record.ucf_Extension_Lenght__c = extLength;
            record.ucf_Customize_Extension__c = isCustmizeExt;
          if(String.isBlank(record.Ucf_Extension__c)){
                system.debug('Debug::');
                String DID=record.DIDNumber__c;
                String ext = DID.right(Integer.valueOf(extLength));
                record.Ucf_Extension__c=ext;
            }

        }
        // Perform the update
        update lstToUpdateExtension;

        return 'Records updated successfully.';
    } catch (Exception e) {
        return 'Error updating records: ' + e.getMessage();
    }
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

    
    
    @AuraEnabled(cacheable=true)
    public static List<String> getMultiPicklistValues3(String objectApiName, String fieldApiName) {
        List<String> multiPicklistValues = new List<String>();
        Schema.DescribeFieldResult fieldDescription;
        Schema.PicklistEntry[] picklistEntries;
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
        if (objectType != null) {
             fieldDescription = objectType.getDescribe().fields.getMap().get(fieldApiName).getDescribe();
            if (fieldDescription.getType() == Schema.DisplayType.String && fieldDescription.isCreateable() && fieldDescription.isUpdateable()) {
                // This field is a picklist or multipicklist
                picklistEntries = fieldDescription.getPicklistValues();
                for (Schema.PicklistEntry entry : picklistEntries) {
                    multiPicklistValues.add(entry.getValue());
                }
                
            }
        }
        system.debug(multiPicklistValues.size());
        System.debug('Object API Name: ' + objectApiName);
        System.debug('Field API Name: ' + fieldApiName);
        System.debug('Field Description: ' + fieldDescription);
        System.debug('Field Type: ' + fieldDescription.getType());
        System.debug('Is Createable: ' + fieldDescription.isCreateable());
        System.debug('Is Updateable: ' + fieldDescription.isUpdateable());
       // System.debug('Picklist Values Count: ' + picklistEntries.size());
        return multiPicklistValues;
    }
    
   
     @AuraEnabled(cacheable=true)
    public static List<String> getMultiPicklistValues( string YourObjectName,string YourFieldName){
                list<string> picklists=new List<string>(); 
        List<Schema.PicklistEntry> PicklistValues  = Schema.getGlobalDescribe().get(YourObjectName).getDescribe().fields.getMap().get(YourFieldName ).getDescribe().getPicklistValues();               
        
        for( Schema.PicklistEntry PicklistValue : PicklistValues){
            picklists.add(string.valueof(PicklistValue.getLabel()));
        }
        System.debug('MultiPicklist Values: ' + picklists);
        return picklists;

    }


 @AuraEnabled
    public static String insertSchedule(String scheduleName) {
        try {
            System.debug('00001');
            Account newAccount = new Account();
            newAccount.Name = scheduleName;
            newAccount.recordtypeid = '012E0000000kJ51IAE';
            insert newAccount;
            return 'Account created successfully';
        } catch (Exception e) {
            return 'Error creating account: ' + e.getMessage();
        }
    }


    
@AuraEnabled
public static String loadCSVData(Id contentDocumentId, String recordId,Boolean CustomExt, String ExtLength) {
    System.debug('csv record id ' + recordId);
    try {
        Map<String,Object> MapOfNpaResponse;
        Map<String,ftr_DID_Location_Details__c> MapOfLocation=new Map<String,ftr_DID_Location_Details__c>();
        Map<String,ftr_DID_Location_Details__c> MapOfServiceAccount=new Map<String,ftr_DID_Location_Details__c>();
        List<String> LstOfFailedDIDNumber=new List<String>();
        String Response='';
        // Retrieve location details
        List<ftr_DID_Location_Details__c> locationDetail = [
            SELECT Id,ServiceAccountId__c,UCFNameValidation__c
            FROM ftr_DID_Location_Details__c 
            WHERE OrderId__c = :recordId
        ];
        String locationId = (!locationDetail.IsEmpty()) ? locationDetail[0].Id : '';
        for(ftr_DID_Location_Details__c DIDLoc : locationDetail)
        {
            MapOfLocation.put(DIDLoc.UCFNameValidation__c,DIDLoc);
            MapOfServiceAccount.put(DIDLoc.id,DIDLoc);
        }
        // Retrieve content version object
        ContentVersion contentVersionObj = [
            SELECT Id, VersionData 
            FROM ContentVersion 
            WHERE ContentDocumentId = :contentDocumentId
            LIMIT 1
        ];
        String data = contentVersionObj.VersionData.toString();
        String[] csvFileLines = data.split('\n');

        // Initialize collections
        Set<Decimal> npaSet = new Set<Decimal>();
        Set<Decimal> nxxSet = new Set<Decimal>();
        Set<String> phoneNumberSet = new Set<String>();

        // Process CSV to collect NPA, NXX, and phone numbers
        for (Integer i = 1; i < csvFileLines.size(); i++) {
            String[] csvRecordData = csvFileLines[i].split(',');
            String phoneNumber = csvRecordData[1];
            phoneNumberSet.add(phoneNumber);
            npaSet.add(Decimal.valueOf(phoneNumber.substring(0, 3)));
            nxxSet.add(Decimal.valueOf(phoneNumber.substring(3, 6)));
        }

        // Query for VOIP Qualification records and DID Number Details
        Map<String, ftr_VOIP_Qualification__c> voipQualificationMap = new Map<String, ftr_VOIP_Qualification__c>();
        for (ftr_VOIP_Qualification__c record : [SELECT Id, NPA__c, NXX__c,Available_VOIP__c,Rate_Center__c FROM ftr_VOIP_Qualification__c WHERE NPA__c IN :npaSet AND NXX__c IN :nxxSet]) {
            String key = record.NPA__c + '_' + record.NXX__c;
            voipQualificationMap.put(key, record);
        }
        Map<String, ftr_DID_Number_Details__c> didNumberDetailMap = new Map<String, ftr_DID_Number_Details__c>();
        for (ftr_DID_Number_Details__c record : [SELECT Id, DIDLocationDetailsId__c,Ucf_Extension__c,DIDNumber__c,Ucf_Voip_Qualification__c,Ucf_Current_Carrier__c,Ucf_Extension_Lenght__c,Ucf_Customize_Extension__c FROM ftr_DID_Number_Details__c WHERE DIDNumber__c IN :phoneNumberSet]) {
            didNumberDetailMap.put(record.DIDNumber__c, record);
        }

        // Process CSV data for upsert
        List<ftr_DID_Number_Details__c> dataToUpsert = new List<ftr_DID_Number_Details__c>();
        String csvId='';
        String phoneNumber='';
        String npaNxxKey='';
        ftr_DID_Number_Details__c didNumber;
        for (Integer i = 1; i < csvFileLines.size(); i++) {
            String[] csvRecordData = csvFileLines[i].split(',');
            phoneNumber = csvRecordData[1];
            npaNxxKey = String.valueOf(Decimal.valueOf(phoneNumber.substring(0, 3))) + '_' + String.valueOf(Decimal.valueOf(phoneNumber.substring(3, 6)));

            didNumber =new ftr_DID_Number_Details__c();
            didNumber = (didNumberDetailMap.containsKey(phoneNumber)) ? didNumberDetailMap.get(phoneNumber) : new ftr_DID_Number_Details__c();
            
            
            didNumber.DIDNumber__c = phoneNumber;
            didNumber.DID_Number__c = phoneNumber;
            didNumber.Ucf_Customize_Extension__c=CustomExt;
            didNumber.Ucf_Extension_Lenght__c=ExtLength;
             if(!String.isBlank(ExtLength)){
                String DINumber=didNumber.DIDNumber__c;
                String ext = DINumber.right(Integer.valueOf(ExtLength));
                didNumber.Ucf_Extension__c=ext;
            }
            if(csvRecordData.size() > 2){
                didNumber.Ucf_Current_Carrier__c = csvRecordData[2];
                }
            if(csvRecordData.size() > 3){
                didNumber.Ucf_Install_Type__c = csvRecordData[3];
                }    
            if(csvRecordData.size() > 5){
            didNumber.Ucf_Number_Use__c = csvRecordData[5];
            }
            if(csvRecordData.size() > 6 && csvRecordData[6] != null && MapOfLocation.containskey(csvRecordData[6])){
                didNumber.DIDLocationDetailsId__c=MapOfLocation.get(csvRecordData[6]).id;
            }
            else{
                didNumber.DIDLocationDetailsId__c =locationId;
            }
            if(didNumber.Ucf_Voip_Qualification__c != null){
                dataToUpsert.add(didNumber);
            }
            else if((didNumber.Ucf_Voip_Qualification__c == null) && voipQualificationMap.containskey(npaNxxKey) && didNumber.Ucf_Number_Use__c != 'Toll Free'){
                     didNumber.Ucf_Voip_Qualification__c = voipQualificationMap.get(npaNxxKey).Available_VOIP__c;
                     didNumber.RateCenter__c = voipQualificationMap.get(npaNxxKey).Rate_Center__c;
                     dataToUpsert.add(didNumber);
                 }
            
            else if((didNumber.Ucf_Voip_Qualification__c == null) && !voipQualificationMap.containskey(npaNxxKey) && didNumber.Ucf_Number_Use__c != 'Toll Free'){
                Response=VoipQualificationCallout(String.valueOf(Decimal.valueOf(phoneNumber.substring(0, 3))),String.valueOf(Decimal.valueOf(phoneNumber.substring(3, 6))));
                MapOfNpaResponse=(Map<String,object>)JSON.deserializeUntyped(Response);
                system.debug('Debug::MapOfNpaResponse'+MapOfNpaResponse);
                if(MapOfNpaResponse.get('success') == true && MapOfNpaResponse.get('NPA') != null){
                    didNumber.Ucf_Voip_Qualification__c=(String)MapOfNpaResponse.get('AvailableVOIP');
                    didNumber.RateCenter__c=(String)MapOfNpaResponse.get('RateCenter');
                    
                    ftr_VOIP_Qualification__c NewVoipQualification=new ftr_VOIP_Qualification__c(Available_VOIP__c=(String)MapOfNpaResponse.get('AvailableVOIP'),
                    Rate_Center__c=(String)MapOfNpaResponse.get('RateCenter'),
                    NPA__c=Integer.valueOf(MapOfNpaResponse.get('NPA')),
                    NXX__c=Integer.valueOf(MapOfNpaResponse.get('NXX')),
                    E911_Type__c=(String)MapOfNpaResponse.get('E911Type'),
                    IsThirdParty__c=(Boolean)MapOfNpaResponse.get('IsThirdParty'),
                    State__c=(String)MapOfNpaResponse.get('State'),
                    LATA__c=(String)MapOfNpaResponse.get('LATA'),
                    OCN__c=(String)MapOfNpaResponse.get('OCN'),
                    OCN_Name__c=(String)MapOfNpaResponse.get('OCNName'),
                    ServiceAccountId__c=MapOfServiceAccount.get(didNumber.DIDLocationDetailsId__c).ServiceAccountId__c
                    );
                    Insert NewVoipQualification;
                    dataToUpsert.add(didNumber);
                    
                }
                else{
                    LstOfFailedDIDNumber.add(phoneNumber);
                }
            }
            else {
                dataToUpsert.add(didNumber);
            }
            
        }

        // Perform the upsert operation
        if(!dataToUpsert.IsEmpty()){
             upsert dataToUpsert;
        }
       String Message='';
        if(!dataToUpsert.IsEmpty() && !LstOfFailedDIDNumber.IsEmpty()){
            Message= String.valueOf(dataToUpsert.size())+' Phone Numbers have been uploaded Successfully. And '+String.valueOf(LstOfFailedDIDNumber)+' Does not qualify for Voip Qualification !';
        }
        else if(!dataToUpsert.IsEmpty() && LstOfFailedDIDNumber.IsEmpty()){
            Message= String.valueOf(dataToUpsert.size())+' Phone Numbers have been uploaded Successfully.';
        }
        else if(dataToUpsert.IsEmpty() && !LstOfFailedDIDNumber.IsEmpty()){
            Message= 'DID numbers Do not qualify for Voip Qualification !';
        }
        return Message;
    } catch (Exception e) {
        return 'csv error: ' + e.getMessage();
    }
}

    

    // created by osama
      @AuraEnabled(cacheable=true)
    public static List<ftr_DID_Number_Details__c> getDIDNumbersData() {
        return [SELECT Id,DIDNumber__c,RateCenter__c, Ucf_Current_Carrier__c, Ucf_Voip_Qualification__c from ftr_DID_Number_Details__c];
    }

    @AuraEnabled
    public static string loadCSVDataForGenralVoicemail(Id contentDocumentId){

        ContentVersion contentVersionObj = [ SELECT Id, VersionData FROM 
                                             ContentVersion WHERE 
                                             ContentDocumentId =:contentDocumentId ];
        
         List<ftr_DID_Number_Details__c> dataToUpesert = new List<ftr_DID_Number_Details__c>();
         
         String data= contentVersionObj.VersionData.toString();

         string[] csvFileLines=data.split('\n');

         for(Integer i=1;i<csvFileLines.size();i++){
            
            string[] csvRecordData = csvFileLines[i].split(',');
            
            ftr_DID_Number_Details__c DIDNumber = new ftr_DID_Number_Details__c();
            DIDNumber.Id = csvRecordData[0];
            DIDNumber.DIDNumber__c = csvRecordData[1] ;             
            DIDNumber.Ucf_Extension__c = csvRecordData[2];
            DIDNumber.Ucf_Company_Name__c = csvRecordData[3];
            DIDNumber.Ucf_Email__c = csvRecordData[4];
            DIDNumber.DID_Number__c = DIDNumber.DIDNumber__c ;

            System.debug('logLevel'+ csvRecordData[0]);
            dataToUpesert.add(DIDNumber);   
        }

        upsert dataToUpesert;

        return string.valueOf(dataToUpesert.size());
    

    }

     @AuraEnabled
    public static string loadCSVDataForEmployeeInfo(Id contentDocumentId,String employeeInfoType){

        ContentVersion contentVersionObj = [ SELECT Id, VersionData FROM 
                                             ContentVersion WHERE 
                                             ContentDocumentId =:contentDocumentId ];
        Boolean isAdded = false;
        List<String> TranslationError=new List<String>();
         List<ftr_DID_Number_Details__c> dataToUpesert = new List<ftr_DID_Number_Details__c>();
         
         String data= contentVersionObj.VersionData.toString();

         string[] csvFileLines=data.split('\n');

         for(Integer i=1;i<csvFileLines.size();i++){
            
            string[] csvRecordData = csvFileLines[i].split(',');
             ftr_DID_Number_Details__c DIDNumber = new ftr_DID_Number_Details__c();
            if(employeeInfoType=='Employee Info' && csvRecordData.size()==9){
            isAdded = true;    
            DIDNumber.Id = csvRecordData[0];
            DIDNumber.DIDNumber__c = csvRecordData[1] ;             
            DIDNumber.Ucf_Extension__c = csvRecordData[2];
            DIDNumber.Ucf_User_Name__c = csvRecordData[3];
            DIDNumber.Ucf_Email__c = csvRecordData[4];
            DIDNumber.Ucf_User_Admin__c =csvRecordData[5]; 
            DIDNumber.Ucf_Department__c = csvRecordData[6];
            DIDNumber.Outbound_Caller_ID__c = csvRecordData[7];
            DIDNumber.Ucf_Other_Outbound_Caller_ID__c  = csvRecordData[8];
            DIDNumber.DID_Number__c = DIDNumber.DIDNumber__c;
            dataToUpesert.add(DIDNumber);  
            }
              else if(employeeInfoType=='Translation' && csvRecordData.size()==8){
                  if(csvRecordData[4].length() <= 6){
                        isAdded = true;    
                        DIDNumber.Id = csvRecordData[0];
                        DIDNumber.DIDNumber__c = csvRecordData[1] ;             
                        DIDNumber.Ucf_Extension__c = csvRecordData[2];
                        DIDNumber.Ucf_User_Name__c = csvRecordData[3];
                        DIDNumber.EAS_Pin__c = Decimal.valueOf(csvRecordData[4]);
                        DIDNumber.Ucf_MAC_Address__c =csvRecordData[5]; 
                        DIDNumber.Ucf_Device_Type__c = csvRecordData[6];
                        DIDNumber.Ucf_Device_Accessories__c = csvRecordData[7];
                        
                        DIDNumber.DID_Number__c = DIDNumber.DIDNumber__c;
                        dataToUpesert.add(DIDNumber);  
                  }
                  else{
                      TranslationError.add(csvRecordData[1]);
                  }
            
            }

            else if(employeeInfoType=='Device Info' && csvRecordData.size()==6){
                isAdded = true;
                 DIDNumber.Id = csvRecordData[0];
            DIDNumber.DIDNumber__c = csvRecordData[1] ;             
            DIDNumber.Ucf_Extension__c = csvRecordData[2];
            DIDNumber.Ucf_User_Name__c = csvRecordData[3];
            DIDNumber.Ucf_Device_Type__c = csvRecordData[4];
            DIDNumber.Ucf_Device_Accessories__c =csvRecordData[5]; 
            DIDNumber.DID_Number__c = DIDNumber.DIDNumber__c;
            dataToUpesert.add(DIDNumber);  
            }
            else if(employeeInfoType=='License Info' && csvRecordData.size()==12){
                isAdded = true;
                DIDNumber.Id = csvRecordData[0];
            DIDNumber.DIDNumber__c = csvRecordData[1] ;             
            DIDNumber.Ucf_Extension__c = csvRecordData[2];
            DIDNumber.Ucf_User_Name__c = csvRecordData[3];
            DIDNumber.Ucf_License_Type__c = csvRecordData[4];
            DIDNumber.Ucf_Dial_Plan_Information__c =csvRecordData[5]; 
            DIDNumber.Ucf_Collaboration__c = csvRecordData[6];
            DIDNumber.Ucf_Webinar__c = csvRecordData[7];
            DIDNumber.Ucf_Call_Recording__c = csvRecordData[8];
            DIDNumber.Ucf_Audio_Mining__c =csvRecordData[9]; 
            DIDNumber.Ucf_Screen_Recording__c = csvRecordData[10];
            DIDNumber.Ucf_Storage__c = csvRecordData[11];
            DIDNumber.DID_Number__c = DIDNumber.DIDNumber__c;
            dataToUpesert.add(DIDNumber);  
            }
            else if(employeeInfoType=='911 Info' && csvRecordData.size()==10){
                isAdded = true; 
                DIDNumber.Id = csvRecordData[0];
            DIDNumber.DIDNumber__c = csvRecordData[1] ;             
            DIDNumber.Ucf_User_Name__c = csvRecordData[2];
            DIDNumber.Ucf_Company_Name__c = csvRecordData[3];
            DIDNumber.Ucf_Address_Number__c = csvRecordData[4];
            DIDNumber.Ucf_Street_Name__c =csvRecordData[5]; 
            DIDNumber.Ucf_City__c = csvRecordData[6];
            DIDNumber.Ucf_State__c = csvRecordData[7];
            DIDNumber.Ucf_Zip_Code__c = csvRecordData[8];
            DIDNumber.Ucf_Identifying_Location__c = csvRecordData[9];
            DIDNumber.DID_Number__c = DIDNumber.DIDNumber__c;
            dataToUpesert.add(DIDNumber);  
            }
            else if(employeeInfoType=='Full Table'&& csvRecordData.size()==26){
                isAdded = true;
                DIDNumber.Id = csvRecordData[0];
            DIDNumber.DIDNumber__c = csvRecordData[1] ;             
            DIDNumber.Ucf_Extension__c = csvRecordData[2];
            DIDNumber.Ucf_User_Name__c = csvRecordData[3];
            DIDNumber.Ucf_Company_Name__c = csvRecordData[4];
            DIDNumber.Ucf_Address_Number__c =csvRecordData[5]; 
            DIDNumber.Ucf_Street_Name__c = csvRecordData[6];
            DIDNumber.Ucf_City__c = csvRecordData[7];
            DIDNumber.Ucf_State__c = csvRecordData[8] ;             
            DIDNumber.Ucf_Zip_Code__c = csvRecordData[9];
            DIDNumber.Ucf_Identifying_Location__c = csvRecordData[10];
            DIDNumber.Ucf_Department__c = csvRecordData[11];
            DIDNumber.Ucf_User_Admin__c =csvRecordData[12]; 
            DIDNumber.Ucf_Email__c = csvRecordData[13];
            DIDNumber.Outbound_Caller_ID__c = csvRecordData[14];
            DIDNumber.Ucf_Other_Outbound_Caller_ID__c = csvRecordData[15];
            DIDNumber.Ucf_License_Type__c = csvRecordData[16];
            DIDNumber.Ucf_Device_Type__c = csvRecordData[17];
            DIDNumber.Ucf_Device_Accessories__c =csvRecordData[18]; 
            DIDNumber.Ucf_Dial_Plan_Information__c = csvRecordData[19];
            DIDNumber.Ucf_Collaboration__c = csvRecordData[20];
            DIDNumber.Ucf_Webinar__c = csvRecordData[21];
            DIDNumber.Ucf_Call_Recording__c = csvRecordData[22];
            DIDNumber.Ucf_Audio_Mining__c = csvRecordData[23];
            DIDNumber.Ucf_Screen_Recording__c = csvRecordData[24];
            DIDNumber.Ucf_Storage__c  = csvRecordData[25];
            DIDNumber.DID_Number__c = DIDNumber.DIDNumber__c;
            dataToUpesert.add(DIDNumber);  
            }

            System.debug('logLevel'+ csvRecordData[0]);
                   
        }
        
        if(!dataToUpesert.IsEmpty() && !TranslationError.isEmpty()){
            upsert dataToUpesert;
            return string.valueOf(dataToUpesert.size()) +' Phone Numbers have been uploaded successfully And '+String.valueOf(TranslationError)+' Contains EAS Pin greater than 6 digits';
        }
        else if(!dataToUpesert.IsEmpty() && TranslationError.isEmpty()){
            upsert dataToUpesert;
            return string.valueOf(dataToUpesert.size()) +' Phone Numbers have been uploaded successfully';
        }
        else if(dataToUpesert.IsEmpty() && !TranslationError.isEmpty()){
            upsert dataToUpesert;
            return String.valueOf(TranslationError)+' Contains EAS Pin greater than 6 digits';
        }
        else{
            return '0';
        }
        
    }
    

@AuraEnabled
    public static String VoipQualificationCallout(String NPA,String NXX){

        String Response=JSON.Serialize(CallVoipQualificationIP.QualifyVoip(NPA,NXX,'DSAT_VOIPQualification'));
        system.debug('Debug::'+Response);
        return Response;

    
    }
}