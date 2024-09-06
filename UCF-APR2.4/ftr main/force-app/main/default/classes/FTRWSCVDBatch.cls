global class FTRWSCVDBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
    /*List<Id> adrList = new List<Id>();
global FTRWSCVDBatch(List<Id> listAdr)
{
adrList = listAdr;
}*/
    
    global DataBase.QueryLocator start(Database.BatchableContext BC)
    {
        return DataBase.getQueryLocator([select ID, ACNA__c, Company__r.name, Name from FTRWSAcna__c]);
    }
    
    global void execute(Database.BatchableContext BC,List<FTRWSAcna__c> acnaList)
    {
        List<String> ExpnumList = new List<String>();
        List<FTRWSPnum__c> UpsertPnumList= new List<FTRWSPnum__c>();
        
        for (FTRWSAcna__c acna: acnaList){
            String response = FTRWSCVDInterface.getPNUMs(acna.ACNA__c);
            if(response != null && response != '') {
                response =  response.substring(response.indexOf('PNum')+7, response.length()-2);
                
                List<String> pnumList = response.split(',');
                
                List<FTRWSPnum__c> existingPnums = [SELECT ID, PNum__c,Active__c from FTRWSPnum__c where Wholesale_ACNA__c =: acna.id];
                
                for(FTRWSPnum__c pnum : existingPnums){
                    ExpnumList.add(pnum.PNum__c);
                    if(pnumList.contains(pnum.PNum__c)){
                        pnum.Active__c = True;                        
                    }
                    else{
                        pnum.Active__c = False;
                    }
                    UpsertPnumList.add(pnum);
                }
                
                for (string p: pnumList){
                    if (!ExpnumList.contains(p)){
                        FTRWSPnum__c pnum = new FTRWSPnum__c();
                        pnum.Name=p;
                        pnum.PNum__c=p;
                        pnum.Wholesale_ACNA__c=acna.id;
                        pnum.Active__c = True;
                        UpsertPnumList.add(pnum);
                    }        
                }
            }
        }
        upsert UpsertPnumList;
    }
    global void finish(Database.BatchableContext BC)
    {
    }
}