trigger DIDNumbers on ftr_DID_Number_Details__c (after insert, after update) {

    Set<Id> didLocationIds = new Set<Id>();
    Set<String> didLocationMDN = new Set<String>();
    Map<Id, ftr_DID_Location_Details__c> parentMap = new Map<Id, ftr_DID_Location_Details__c>();

    for (ftr_DID_Number_Details__c newDIDNumber : Trigger.new) {
        didLocationIds.add(newDIDNumber.DIDLocationDetailsId__c);
         //didLocationMDN.add(newDIDNumber.DIDLocationDetailsId__r.MDN__c);
    }
 
    if(!didLocationIds.isEmpty()){

        List<ftr_DID_Location_Details__c> didMDNList = [Select Id,MDN__c from ftr_DID_Location_Details__c where Id IN: didLocationIds];
       
        for(ftr_DID_Location_Details__c didMDN: didMDNList){
            
            didLocationMDN.add(didMDN.MDN__c);
        }
    }
    
    
     
     

    
    List<AggregateResult> results = [SELECT DIDLocationDetailsId__c, DIDNumberInfo__c, COUNT(Id) FROM ftr_DID_Number_Details__c
                                     WHERE DIDLocationDetailsId__c IN :didLocationIds AND DID_Number__c NOT IN: didLocationMDN
                                     GROUP BY DIDLocationDetailsId__c, DIDNumberInfo__c];

    if(!results.isEmpty()){
    for (AggregateResult result : results) {
                                        
        Id parentId = (Id)result.get('DIDLocationDetailsId__c');
        String picklistValue = (String)result.get('DIDNumberInfo__c');
        Integer count = (Integer)result.get('expr0');
                                        
        ftr_DID_Location_Details__c parent = parentMap.get(parentId);
        if (parent == null) {
                parent = new ftr_DID_Location_Details__c(Id = parentId);
                parentMap.put(parentId, parent);
            }
                                        
            if (picklistValue == 'New DID Range') {
                parent.DID_New__c = String.valueOf(count);
                parent.Total_DID_Numbers__c = parent.Total_DID_Numbers__c != null ? parent.Total_DID_Numbers__c + count : count;
            } else if (picklistValue == 'Port-In') {
                    parent.DID_PortIn__c = String.valueOf(count);
                    parent.Total_DID_Numbers__c = parent.Total_DID_Numbers__c != null ? parent.Total_DID_Numbers__c + count : count;
            }else if(picklistValue == 'Existing # (Regrade)'){
                parent.Total_DID_Numbers__c = parent.Total_DID_Numbers__c != null ? parent.Total_DID_Numbers__c + count : count;

            }else if(picklistValue == 'Winback'){
                parent.Total_DID_Numbers__c = parent.Total_DID_Numbers__c != null ? parent.Total_DID_Numbers__c + count : count;

            }
    }
}

        if(parentMap.values().size()>0){
            try{
                List<Database.SaveResult> results = Database.update(parentMap.values(), false);

                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){
                        System.debug('Error in Subscriber: '+ err.getStatusCode() + ' ' + err.getMessage());
                        }
                    }
                }
            }catch(Exception e) {
                System.debug('Exception in Subscriber..'+ e.getMessage());
               
            }
            
        }
    
}