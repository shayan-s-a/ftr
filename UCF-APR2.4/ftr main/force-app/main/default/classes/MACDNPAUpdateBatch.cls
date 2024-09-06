global class MACDNPAUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID,NPA_NXX__c,vlocity_cmt__JSONAttribute__c from asset where NPA_NXX__c = null';
        return Database.getQueryLocator(query);

    }
    global void execute(Database.BatchableContext bc, List<asset> asttList){
        List<Asset> assetList = new List<Asset>();
        for(asset ast: asttList){
           String npa = (String)ftr_CpqHelper.getJSONAttributeValue(ast.vlocity_cmt__JSONAttribute__c, 'ATTR_NPA_NXX');
            if (String.isNotBlank(npa)) {
                ast.NPA_NXX__c = npa;  
                assetList.add(ast);
            }
                    
        }
        if (assetList !=null && assetList.size() > 0){
            try{
                update assetList;
            }catch(Exception e){
                System.debug(e);
            }
        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}