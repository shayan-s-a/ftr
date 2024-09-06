public class PmEnrichmentController {
// created by ussama

     @AuraEnabled(Cacheable = true)
    public static List<Account> getAccountList(){
        List<Account> accListObj= [SELECT Id, Name, Phone, Industry, Description, Type, Website FROM Account Where Phone != null limit 20 ];
        return accListObj;
    } 
    

    
@AuraEnabled(cacheable=true)
public static String isTranslationUser(String OrderId) {
    System.debug('in SL ');
    // Retrieve the profileName__c of the current user
   
     Order Ord=[Select id,vlocity_cmt__OrderStatus__c,Order_Stage__c from Order where id=:OrderId];
    User currentUser = [SELECT profileName__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    string profileName = 'None';
    System.debug('SL '+currentUser);
    System.debug('SL Ord '+Ord);

    // Check if the profile name matches the given names
   /* if (currentUser.profileName__c == '#Project Manager - Supervisor Level' || 
        currentUser.profileName__c == '#Project Manager') {
        profileName = 'Non-Translation';
    } else */
    system.debug('SL order status' +Ord.vlocity_cmt__OrderStatus__c);
    system.debug('SL order stage' +Ord.Order_Stage__c);
    system.debug('SL profile ' +currentUser.profileName__c );
     if  (currentUser.profileName__c == '#Solution Engineer Supervisor' 
     && Ord.Order_Stage__c == 'Network Translations') {
        {
             profileName = 'Translation';
        }
       
       
    }
     else if((Ord.vlocity_cmt__OrderStatus__c == 'In Progress' || Ord.vlocity_cmt__OrderStatus__c == 'Complete' ) &&
        ord.Order_Stage__c == 'Hot Cuts'  && Ord.Order_Stage__c != 'Network Translations')
        {
            profileName = 'Non-Translation'; //
        }
    System.debug('SL profileName  '+profileName);
    // Return false if no match is found
    return profileName;
}

@AuraEnabled(Cacheable = true)
public static List<ftr_VOIP_Qualification__c> getNpaNxxList(){
    List<ftr_VOIP_Qualification__c> ftr_VOIP= [SELECT Id, Name,NPA__c, NXX__c, Local_Routing_Number__c
    FROM ftr_VOIP_Qualification__c ];
    return ftr_VOIP;
} 



@AuraEnabled
public static Boolean isNetworkTranslation(String OrderId) {
    System.debug('in SL ');
    // Retrieve the profileName__c of the current user
    User currentUser = [SELECT profileName__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    Order Ord=[Select id,vlocity_cmt__OrderStatus__c,Order_Stage__c from Order where id=:OrderId];
    Boolean profile = false;
    System.debug('SL '+currentUser);
    // Check if the profile name matches the given names
    if (((currentUser.profileName__c == '#Project Manager - Supervisor Level' || 
        currentUser.profileName__c == '#Project Manager') && Ord.Order_Stage__c == 'Network Translations') || currentUser.profileName__c == '#Hot Cut Service Consultants' || currentUser.profileName__c == '#Sales Support Supervisor') {
        profile = true;
    } 
    else if ((Ord.vlocity_cmt__OrderStatus__c == 'In Progress' || Ord.vlocity_cmt__OrderStatus__c == 'Complete') && Ord.Order_Stage__c == 'Hot Cuts' ){
        profile = true;    
    }
    else{
        profile = false;
    }

    // Return false if no match is found
    return profile;
}
@AuraEnabled
    public static boolean getOrderStage(String recordId) {
        System.Debug('orderId = ' + recordId); 
        Order ord = [Select Id , vlocity_cmt__OrderStatus__c,Order_Stage__c  From Order Where Id =: recordId];
        System.debug('ord = ' + ord);
        if(ord.vlocity_cmt__OrderStatus__c  != null)
            if((ord.vlocity_cmt__OrderStatus__c == 'In Progress' || ord.vlocity_cmt__OrderStatus__c == 'Complete') && ord.Order_Stage__c == 'Hot Cuts' ){
                return true;
            }
            return false;
    }
    
@AuraEnabled
public static List<Service_Location__c> getPremises(String orderId) {
     Map<String, String> mapOMainPhoneNumber = new Map<String, String>();
    List<Service_Location__c> existingServiceLocations = [SELECT Id, Location_Name__c, 
                                                          Contact_Email__c,
                                                          Contact_Name__c,
                                                          Contact_Phone__c, 
                                                          Caller_ID_Name__c,
                                                          Shipping_Address__c,Shipping_Location__c,Street__c,City__c,State__c,Zip__c,
                                                          Location_Street__c,Location_City__c,Location_State__c,Location_Zip__c,
                                                          Construction_Details__c,
                                                          New_Construction__c,Custom_music__c,
                                                          Main_Phone_Number__c,
                                                          Location_Address__c,Time_Zone__c,Business_Group_Name__c,EAS_Pin__c,
                                                          Order__c FROM Service_Location__c WHERE Order__c = :orderId];
    
     boolean updateRequired = false;
    for (Service_Location__c loc : existingServiceLocations) {
        if (String.isEmpty(loc.Location_Name__c) || String.isEmpty(loc.Main_Phone_Number__c)) {
             system.debug('SL Empty ' + loc.Location_Name__c);
            updateRequired = true;
            break;
        }
    }
    
      if (updateRequired) {
          
           List<OrderItem> orderItems = [SELECT Id, vlocity_cmt__ServiceAccountId__c,vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__c,
        vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c
                                      FROM OrderItem WHERE OrderId = :orderId];
            system.debug('SL orderItems ' + orderItems);
          
            Map<Id,OrderItem> MapOfOrderItems=new Map<Id,OrderItem>();
        for (OrderItem oi : orderItems) {
            MapOfOrderItems.put(oi.vlocity_cmt__ServiceAccountId__c,oi);
        }
          system.debug('SL Required');
        Map<String, String> mapOfLocations = new Map<String, String>();
         
        List<ftr_DID_Location_Details__c> locationDetails = [SELECT Id, ServiceAccountId__c, UCFNameValidation__c, UCFLocationMainPhoneNumber__c
                                                             FROM ftr_DID_Location_Details__c 
                                                             WHERE OrderId__c =: orderId];
        system.debug('SL locationDetail ' + locationDetails);

        // Create a map of locations
        for (ftr_DID_Location_Details__c detail : locationDetails) {
            mapOfLocations.put(detail.ServiceAccountId__c + '-' + orderId, detail.UCFNameValidation__c);
            mapOMainPhoneNumber.put(detail.ServiceAccountId__c + '-' + orderId, detail.UCFLocationMainPhoneNumber__c);
            
        }

        // Update existing Service Locations with null or empty Location Name
        for (Service_Location__c loc : existingServiceLocations) {
            if (String.isEmpty(loc.Location_Name__c) ||String.isEmpty(loc.Main_Phone_Number__c) ) {
                 if (!MapOfOrderItems.isEmpty()) {
                        for(OrderItem premises: MapOfOrderItems.values())
            {
            
                system.debug('SL updating name in fisrt '+  MapOfLocations.get(premises.vlocity_cmt__ServiceAccountId__c+'-'+orderId));
                loc.Location_Name__c = MapOfLocations.get(premises.vlocity_cmt__ServiceAccountId__c+'-'+orderId);
                loc.Main_Phone_Number__c =  mapOMainPhoneNumber.get(premises.vlocity_cmt__ServiceAccountId__c+'-'+orderId);  
            }
                 }
            }
        }
        update existingServiceLocations;
    }
    
    system.debug('SL existingServiceLocations ' + existingServiceLocations);
    if (existingServiceLocations.size() == 0 && existingServiceLocations != null) {
        Map<string,string> MapOfLocations=new map<String,String>();
        Order orderRecord = [SELECT Id, Technical_Contact_Name__c, Technical_Contact_Email__c,Account_Name__c, 
                             Technical_Contact_Number__c FROM Order WHERE Id = :orderId LIMIT 1];
          system.debug('SL order ' + orderRecord);
        List<OrderItem> orderItems = [SELECT Id, vlocity_cmt__ServiceAccountId__c,vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__c,
        vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
        vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c
                                      FROM OrderItem WHERE OrderId = :orderId];
            system.debug('SL orderItems ' + orderItems);

        List<ftr_DID_Location_Details__c> locationDetail = [
            SELECT Id,ServiceAccountId__c,UCFNameValidation__c,UCFLocationMainPhoneNumber__c
            FROM ftr_DID_Location_Details__c 
            WHERE OrderId__c =:orderId
          ];
           system.debug('SL locationDetail ' + locationDetail);
        for(ftr_DID_Location_Details__c Loc:  locationDetail){
            MapOfLocations.put(Loc.ServiceAccountId__c+'-'+orderId,Loc.UCFNameValidation__c);
            mapOMainPhoneNumber.put(Loc.ServiceAccountId__c + '-' + orderId, Loc.UCFLocationMainPhoneNumber__c);
        }
        
         system.debug('SL MapOfLocations ' + MapOfLocations);
        
        Map<Id,OrderItem> MapOfOrderItems=new Map<Id,OrderItem>();
        for (OrderItem oi : orderItems) {
            MapOfOrderItems.put(oi.vlocity_cmt__ServiceAccountId__c,oi);
        }
        
         system.debug('SL MapOfOrderItems ' + MapOfOrderItems);
        
                                      
        List<Service_Location__c> newServiceLocationList =new list<Service_Location__c>();
        if (!MapOfOrderItems.isEmpty()) {
            
            for(OrderItem premises: MapOfOrderItems.values())
            {
                system.debug('SL premises.vlocity_cmt__ServiceAccountId__c ' + premises.vlocity_cmt__ServiceAccountId__c);
                 system.debug('SL Loc Name.. ' +   MapOfLocations.get(premises.vlocity_cmt__ServiceAccountId__c+'-'+orderId));
              
                Service_Location__c newServiceLocation = new Service_Location__c(      
                Contact_Email__c = (orderRecord.Technical_Contact_Email__c != null) ? orderRecord.Technical_Contact_Email__c : '',
                Contact_Name__c = (orderRecord.Technical_Contact_Name__c != null) ? orderRecord.Technical_Contact_Name__c : '',
                Contact_Phone__c = (orderRecord.Technical_Contact_Number__c != null) ? orderRecord.Technical_Contact_Number__c : '',
                Caller_ID_Name__c = (orderRecord.Account_Name__c != null && orderRecord.Account_Name__c.length() > 15) ? orderRecord.Account_Name__c.substring(0, 15) : orderRecord.Account_Name__c,
               // Caller_ID_Name__c= orderRecord.Account_Name__c.Length() > 15 ? orderRecord.Account_Name__c.substring(0, 15) : orderRecord.Account_Name__c,
                Location_Address__c = premises.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c+', '+
                premises.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c+', '+
                premises.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,
                Location_Name__c = MapOfLocations.get(premises.vlocity_cmt__ServiceAccountId__c+'-'+orderId),
                Main_Phone_Number__c =mapOMainPhoneNumber.get(premises.vlocity_cmt__ServiceAccountId__c+'-'+orderId),
                Shipping_Location__c='Different Address',
                Custom_music__c  = 'No',
                Location_Street__C=premises.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
                Location_City__C=premises.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
                Location_State__C=premises.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,
                Location_Zip__C=premises.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,
                Order__c = orderId);
                newServiceLocationList.add(newServiceLocation);
            }
            
             insert newServiceLocationList;
           existingServiceLocations =newServiceLocationList;
           /*= [SELECT Id, Location_Name__c, 
                                                          Contact_Email__c,
                                                          Contact_Name__c,
                                       Shipping_Location__c, New_Construction__c,Custom_music__c,
                                                          Contact_Phone__c, 
                                                          Construction_Details__c,Caller_ID_Name__c,
                                                          Location_Address__c,Time_Zone__c,Business_Group_Name__c,EAS_Pin__c,
                                                          Order__c FROM Service_Location__c where Order__c =: orderId];
           
           */

        }
    }
    system.debug('PM SL Return '+ existingServiceLocations);
    return existingServiceLocations;
}
   @AuraEnabled(cacheable=true)
public static List<Service_Location__c> getPremises2(string recordId) { 
    
    // Query and return premises based on the premise Ids from the above query
    return [SELECT Id, 
            Location_Name__c, 
            Location_Address__c,
            Main_Phone_Number__c,
            Shipping_Location__c, 
            Time_Zone__c,
            New_Construction__c,
            Contact_Name__c,
            Contact_Email__c,
            Contact_Phone__c, 
            Caller_ID_Name__c,
            Custom_music__c,
            Shipping_Address__c,
            Street__c,
            City__c,
            State__c,
            Zip__c,
            Construction_Details__c,
            Business_Group_Name__c,
            EAS_Pin__c,
            Order__c FROM Service_Location__c WHERE Order__c = :recordId];
}
//osama work for getDIDNumberDeatils

@AuraEnabled(cacheable=true)
    public static List<ftr_DID_Number_Details__c> ftrDIDNumberDetailsEmployeeInfo(String orderId) {
        system.debug('heree '+ orderId);
        List<ftr_DID_Number_Details__c> DIDNumberDetail=new List<ftr_DID_Number_Details__c>();
        DIDNumberDetail= [SELECT Id, DIDLocationDetailsId__r.OrderId__c, DIDNumber__c,Ucf_Extension__c,Ucf_License_Type__c,
        Ucf_Dial_Plan_Information__c,Ucf_Collaboration__c,Ucf_Webinar__c,Ucf_Call_Recording__c,Ucf_Audio_Mining__c,
        Ucf_Screen_Recording__c,Ucf_Storage__c,Ucf_Device_Type__c,Ucf_Device_Accessories__c,
            Ucf_Company_Name__c,Ucf_Address_Number__c,Ucf_Street_Name__c,   Ucf_City__c,EAS_Pin__c,    
            Ucf_State__c,   Ucf_Zip_Code__c,    Ucf_Identifying_Location__c FROM ftr_DID_Number_Details__c where DIDLocationDetailsId__r.OrderId__c=:orderId];
        
    system.debug('heree '+ DIDNumberDetail);
        return DIDNumberDetail;
    }
     //osama work
   @AuraEnabled(cacheable=true)
    public static List<ftr_DID_Number_Details__c> ftrPhoneNumberDetails(String orderId) {
        system.debug('heree '+ orderId);
        List<ftr_DID_Number_Details__c> DIDNumberDetail=new List<ftr_DID_Number_Details__c>();
        DIDNumberDetail= [SELECT Id,DID_Number__c,DIDLocationDetailsId__r.UCFNameValidation__c,Ucf_Voip_Qualification__c,Ucf_Current_Carrier__c,RateCenter__c,Ucf_Install_Type__c,Ucf_Number_Use__c,DIDLocationDetailsId__r.Name,Ucf_Customize_Extension__c,Ucf_Extension_Lenght__c,NPA__c, NXX__c,Local_Routing_Number__c FROM ftr_DID_Number_Details__c where DIDLocationDetailsId__r.OrderId__c=:orderId];
        system.debug('heree '+ DIDNumberDetail);
       
        return DIDNumberDetail;
    }
    
   /*
    @AuraEnabled
    public static String updateAccountFieldsList(List<Account> recordsToUpdate) {
        try {
            // Perform updates on the records
            update recordsToUpdate;
            
            return 'Records updated successfully.';
        } catch (Exception e) {
            return 'Error updating records: ' + e.getMessage();
        }
    }  */

        @AuraEnabled
    public static String updatePremiseFieldsList(List<Service_Location__c> recordsToUpdateForUpdate,List<Service_Location__c> ServiceLocationOldValues,String orderId) {
        System.debug('0001 : here');
         System.debug('0001 : ' + recordsToUpdateForUpdate);
        try {
            

            // Perform updates on the records
            if(!recordsToUpdateForUpdate.isEmpty())
            {
                Set<String> SetOfLocationData=new Set<String>();
                List<Service_Location__c> LstOfOldSerLocValues=new List<Service_Location__c>([select id,Location_Name__c from Service_Location__c where Id IN : ServiceLocationOldValues]);
                for(Service_Location__c Loc : LstOfOldSerLocValues)
                {
                    SetOfLocationData.add(Loc.Location_Name__c);
                    
                }
                List<ftr_DID_Location_Details__c> locationDetail = [
                    SELECT Id,ServiceAccountId__c,UCFNameValidation__c,UCFLocationMainPhoneNumber__c
                    FROM ftr_DID_Location_Details__c 
                    WHERE OrderId__c =:orderId AND UCFNameValidation__c in:SetOfLocationData
                ];
                Map<String,ftr_DID_Location_Details__c> MapofDIDLocations=new Map<String,ftr_DID_Location_Details__c>();
                for(ftr_DID_Location_Details__c DIDLoc : locationDetail)
                {
                    MapofDIDLocations.put(DIDLoc.UCFNameValidation__c,DIDLoc);
                }
                for(Service_Location__c OldValue : LstOfOldSerLocValues)
                {
                    for(Service_Location__c NewValue : recordsToUpdateForUpdate)
                    { 
                        if(OldValue.id == NewValue.id && NewValue.Location_Name__c != null)
                        {
                            MapofDIDLocations.get(OldValue.Location_Name__c).UCFNameValidation__c=NewValue.Location_Name__c;
                        }
                        
                    }
                }
                update MapofDIDLocations.values();
                update recordsToUpdateForUpdate;
            }
            
            return 'Records updated successfully.';
        } catch (Exception e) {
             System.debug('0001 : ' + e.getMessage());
            return 'Error updating records: ' + e.getMessage();
        }
    }
    @AuraEnabled
    public static String updateDIDNumbersFieldsList(String EASPin,String recordId) {
        
         List<ftr_DID_Number_Details__c> DIDNumberDetail=new List<ftr_DID_Number_Details__c>();
        
         List<ftr_DID_Number_Details__c> UpdateDIDNumberDetail=new List<ftr_DID_Number_Details__c>();
        DIDNumberDetail= [SELECT Id, DIDLocationDetailsId__r.OrderId__c, DIDNumber__c,Ucf_Extension__c,Ucf_License_Type__c,
        Ucf_Dial_Plan_Information__c,Ucf_Collaboration__c,Ucf_Webinar__c,Ucf_Call_Recording__c,Ucf_Audio_Mining__c,
        Ucf_Screen_Recording__c,Ucf_Storage__c,Ucf_Device_Type__c,Ucf_Device_Accessories__c,
            Ucf_Company_Name__c,Ucf_Address_Number__c,Ucf_Street_Name__c,   Ucf_City__c,EAS_Pin__c,    
            Ucf_State__c,Ucf_Zip_Code__c,Ucf_Identifying_Location__c FROM ftr_DID_Number_Details__c where DIDLocationDetailsId__r.OrderId__c =: recordId];
       
         for(ftr_DID_Number_Details__c did : DIDNumberDetail)
         {
            // did.EAS_Pin__c=Decimal.valueOf(EASPin);
            did.EAS_Pin__c=(EASPin=='' || EASPin==null)? 0 : Decimal.valueOf(EASPin);
            UpdateDIDNumberDetail.add(did);
         }
        
        try {
            // Perform updates on the records
            if(!UpdateDIDNumberDetail.isEmpty())
            {
                update UpdateDIDNumberDetail;
            }
            
            return 'Records updated successfully.';
        } catch (Exception e) {
             System.debug('0001 : ' + e.getMessage());
            return 'Error updating records: ' + e.getMessage();
        }
    }
        @AuraEnabled
     public static void upsertAccounts(String csvData) {
         System.debug('0001:  '+ csvData);

         
List<String> records = csvData.substring(1, csvData.length()-1).split('},\\{');

List<Account> accounts = new List<Account>();

for(String record : records) {
    record = record.replace('{', '').replace('}', '');
    Map<String, String> fields = new Map<String, String>();
    // Splitting each record into its fields
    for(String field : record.split(',')) {
          // System.debug('000- here: ');
        List<String> keyValue = field.split(':');
        // Removing quotes from both key and value
        String key = keyValue[0].replace('"', '').trim();
        String value = keyValue[1].replace('"', '').trim();
        fields.put(key, value);
    }
    System.debug('0002: '+ fields);
    Account acc = new Account();
    acc.Id = fields.get('PhoneNumber=');
   // acc.Extension__c = fields.get('Extension'); 
    acc.Name = fields.get('Name');
    //acc.Email = fields.get('Email\r').removeEnd('\r');
    accounts.add(acc);
}

//insert accounts
    }

     @AuraEnabled
    public static String updatePremisesFieldsList(List<Service_Location__c> recordsToUpdate) {
        try {
            system.debug('PM Update '+ recordsToUpdate);
            // Perform updates on the records
            update recordsToUpdate;
            system.debug('PM status: Records updated successfully');
            return 'Records updated successfully.';
        } catch (Exception e) {
            system.debug('PM Error '+  e.getMessage());
            return 'Error updating records: ' + e.getMessage();
        }
    }

  


@AuraEnabled
public static String updateServiceLoacationMoadalFields(String recordId, String constructionDetails, String shippingAddress,String shippingStreet,String shippingCity,String shippingState, String shippingZip) {
    try {
        system.debug('Modal: '+ constructionDetails + '  ' +  shippingAddress);
        Service_Location__c premiseToUpdate = new Service_Location__c();
     
            if(shippingAddress != null && shippingAddress != '')
            {
                     premiseToUpdate.Shipping_Address__c = shippingAddress;
            }
            if(shippingStreet != null && shippingStreet != '')
            {
                     premiseToUpdate.Street__c = shippingStreet;
            }
             if(shippingCity != null && shippingCity != '')
            {
                     premiseToUpdate.City__c = shippingCity;
            }
             if(shippingState != null && shippingState != '')
            {
                     premiseToUpdate.State__c = shippingState;
            }
             if(shippingZip != null && shippingZip != '')
            {
                  premiseToUpdate.Zip__c = shippingZip;
            }
             if(constructionDetails != null && constructionDetails != '')
            {
                  premiseToUpdate.Construction_Details__c = constructionDetails;
            }
      
        premiseToUpdate.Id = recordId;

        // Update the record
        update premiseToUpdate;

        // Debug log to verify successful update

        // Return a success message
        return 'Record updated successfully';
    } catch (Exception e) {
        // Debug log to capture exceptions
        return 'QQQQ Error updating records: ' + e.getMessage();
    }
}



    // created by ussama
     @AuraEnabled(cacheable=true)
    public static List<String> getRatingPicklistValues2() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Rating.getDescribe();
        
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValues.add(entry.getValue());
            //picklistValues.add(entry)
        }
        System.debug('test '+ picklistValues);
        
        return picklistValues;
    } 


     @AuraEnabled(cacheable=true)
    public static List<String> getRatingPicklistValues() {
        // Get Rating picklist values
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Rating.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValues.add(entry.getValue());
        }
        return picklistValues;
    }

// created by ussama

      @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id, Name, Industry, BillingAddress,TickerSymbol,SicDesc,Rating,
         (SELECT Id, name, FirstName, LastName, Email, Phone FROM Contacts where accountid != null)
          FROM Account LIMIT 10 ];
    } 


    // created by ussama
      @AuraEnabled(cacheable=true)
    public static List<ftr_DID_Number_Details__c> getDIDNumbersData() {
        return [SELECT Id,DIDNumber__c, Ucf_Current_Carrier__c, Ucf_Voip_Qualification__c from ftr_DID_Number_Details__c];
    }


}