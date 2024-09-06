public class NeustarApiBatchHandler {
    
    public static void updateAccountNeuStar(List<Account> lstAcc){
        Map<String,Account> mapAccAndPhnNumber = new Map<String,Account>();
        Map<String,List<Neustar_Data__c>> mapNewStarAndPhnNumber = new Map<String,List<Neustar_Data__c>>();
        for(Account acc : lstAcc) mapAccAndPhnNumber.put(String.isNotBlank(acc.Phone) ?acc.Phone.deleteWhitespace().replaceAll('\\p{P}','').replace('-',''):acc.Phone,acc);
                
        List<Neustar_Data__c> lstNeustar_Data = [select id,TN__c, Billing_Account__c,Billing_Account__r.RecordType.Name ,Master_Account__c,Master_Account__r.RecordType.Name ,Service_Account__c,Service_Account__r.RecordType.Name  from Neustar_Data__c where TN__c IN: mapAccAndPhnNumber.keyset() AND TN__c != null];
                
        for(Neustar_Data__c nd : lstNeustar_Data){
            if(mapNewStarAndPhnNumber.containsKey(nd.TN__c)) mapNewStarAndPhnNumber.get(nd.TN__c).add(nd);
            else mapNewStarAndPhnNumber.put(nd.TN__c,new List<Neustar_Data__c>{nd});
        }
        List<Neustar_Data__c> neuStarRecordToInsert = new List<Neustar_Data__c>();
        List<Neustar_Data__c> neuStarRecordToUpdate = new List<Neustar_Data__c>();
        
        for(String phn : mapAccAndPhnNumber.keyset()){
            List<Neustar_Data__c> lstExistingNeuStarRecs = mapNewStarAndPhnNumber.get(phn);
            Account acc = mapAccAndPhnNumber.get(phn);
            
            if(lstExistingNeuStarRecs != null && lstExistingNeuStarRecs.size() > 0){
                Neustar_Data__c ndExisting = lstExistingNeuStarRecs[0];
                /*if(acc.RecordType.DeveloperName == 'Master' && ndExisting.Master_Account__r.RecordType.Name == 'Master' && ndExisting.Service_Account__c == null){
                    ndExisting.Service_Account__c =  mapAccAndPhnNumber.get(phn).Id;
                    ndExisting.Master_Account__c =  mapAccAndPhnNumber.get(phn).ParentId;
                }
                else if(acc.RecordType.DeveloperName == 'Master' && ndExisting.Master_Account__r.RecordType.Name == 'Master' && ndExisting.Billing_Account__c == null){
                    ndExisting.Billing_Account__c =  mapAccAndPhnNumber.get(phn).Id;
                    ndExisting.Master_Account__c =  mapAccAndPhnNumber.get(phn).ParentId;
                }*/
                if(acc.RecordType.DeveloperName == 'Service' && ndExisting.Service_Account__c == null){
                    ndExisting.Service_Account__c =  mapAccAndPhnNumber.get(phn).Id;
                    ndExisting.Master_Account__c =  mapAccAndPhnNumber.get(phn).ParentId;
                }else if(acc.RecordType.DeveloperName == 'Billing' && ndExisting.Billing_Account__c == null){
                    ndExisting.Billing_Account__c =  mapAccAndPhnNumber.get(phn).Id;
                    ndExisting.Master_Account__c =  mapAccAndPhnNumber.get(phn).ParentId;
                }
                neuStarRecordToUpdate.add(ndExisting);
            }else{
                Neustar_Data__c nd = NeustartApiManager.makeApiCall(phn);
                if(nd != null){
                    if(acc.RecordType.DeveloperName == 'Master') nd.Master_Account__c =  mapAccAndPhnNumber.get(phn).Id;
                    else if(acc.RecordType.DeveloperName == 'Service'){
                        nd.Service_Account__c =  mapAccAndPhnNumber.get(phn).Id;
                        nd.Master_Account__c =  mapAccAndPhnNumber.get(phn).ParentId;
                    }
                    else if(acc.RecordType.DeveloperName == 'Billing'){
                        nd.Billing_Account__c =  mapAccAndPhnNumber.get(phn).Id;
                        nd.Master_Account__c =  mapAccAndPhnNumber.get(phn).ParentId;
                    }
                    neuStarRecordToInsert.add(nd);
                }
            }
        }
        insert neuStarRecordToInsert;
        update neuStarRecordToUpdate;
        for(Account acc : lstAcc) acc.Need_To_Sync_With_NeuStar__c = false;
        update lstAcc;
    }
    
    public static void updateOlderNeuStar(List<Neustar_Data__c> lstNS){
        List<Neustar_Data__c> lstNdToUpdate = new List<Neustar_Data__c>();
        for(Neustar_Data__c nd : lstNS){
            Neustar_Data__c ndToUpdate = NeustartApiManager.makeApiCall(nd.TN__c);
            if(ndToUpdate != null){
                Id ndRecId = nd.Id; 
                nd = ndToUpdate;
                nd.Id = ndRecId;
                lstNdToUpdate.add(nd);
            }
        }
        try{
            update lstNdToUpdate;
        }catch(Exception ee){
 			system.debug('Error :: '+ee.getMessage());           
        }
    }
    
}