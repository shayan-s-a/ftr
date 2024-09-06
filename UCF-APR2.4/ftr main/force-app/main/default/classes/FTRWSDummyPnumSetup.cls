public class FTRWSDummyPnumSetup {
    
    
    public static void createDummyPnumsForWholsaleACNA() {
        
        
        Wholesale_Dummy_PNUM__mdt PNUMList = [Select PNUMList__c FROM Wholesale_Dummy_PNUM__mdt WHERE developerName = 'DummyPNUMs' limit 1];
        
        list<FTRWSAcna__c> fullAcnaList = [SELECT Id, Name, Company__c from FTRWSAcna__c];	
        List<String> dummyPnumList = new List<String>();
        
        if(PNUMList != null && String.isNotBlank(PNUMList.PNUMList__c)) {
            dummyPnumList = PNUMList.PNUMList__c.split(','); 
        }
        
        if(dummyPnumList == null || dummyPnumList.size() == 0) {
            return;
        }        
        
        List<FTRWSPnum__c> insertPNumList = new List<FTRWSPnum__c>();
        List<String> insertNewPNumList = new List<String>();
        AggregateResult[] aggregateAcnaList;
        List<Id> acnaWithPnumList = new List<Id>();
        
        for(String dummyPnum: dummyPnumList) {
            
            aggregateAcnaList = [Select Wholesale_ACNA__c from FTRWSPnum__c where name=:dummyPnum  GROUP By Wholesale_ACNA__c];
            if(aggregateAcnaList == null || aggregateAcnaList.size() == 0) {                
                insertNewPNumList.add(dummyPnum);
            } else {
                for (AggregateResult acnaWtPnum:aggregateAcnaList ) {
                    String acnaId = (String) acnaWtPnum.get('Wholesale_ACNA__c');
                    acnaWithPnumList.add(acnaId);
                }
                
            }
            
        }
        
        
        for(String dummyPnum: dummyPnumList) {
            for(FTRWSAcna__c acna: fullAcnaList) {
                
                if(insertNewPNumList.contains(dummyPnum)) {
                    
                    FTRWSPnum__c pnumObj = new FTRWSPnum__c();
                    pnumObj.PNum__c = dummyPnum;
                    pnumObj.Name = dummyPnum;
                    pnumObj.Wholesale_ACNA__c = acna.Id;
                    insertPNumList.add(pnumObj);
                    System.debug('Adding new dummy Pnum: ' + dummyPnum + 'for acna: ' + acna.Name);
                } else if(acnaWithPnumList.contains(acna.Id)) {
                    System.debug('ACNA: ' + acna.Name + ' already has the dummyPnum: ' + dummyPnum);
                    continue; 
                } else {
                    
                    FTRWSPnum__c pnumObj = new FTRWSPnum__c();
                    pnumObj.PNum__c = dummyPnum;
                    pnumObj.Name = dummyPnum;
                    pnumObj.Wholesale_ACNA__c = acna.Id;
                    insertPNumList.add(pnumObj);
                    
                }
                
            }            
        }
        
        if(insertPNumList != null && insertPNumList.size() > 0) {
            insert insertPNumList;
        }
        System.debug('acnaWithPnumList: ' + acnaWithPnumList);
    }
}