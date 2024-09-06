public class FTRWSCalculateOppMRR {

    @InvocableMethod(label='calculateMRR' category='Wholesale')
    public static void calculateMRR(List<Id> oppId){

    try{
        //FTRWSAddress__c addr = [SELECT Opportunity_ID__c FROM FTRWSAddress__c WHERE Id=:addressId[0]];
        SterlingQuote__c quote = [SELECT Id from SterlingQuote__c WHERE OpportunityId__c =: oppId[0] and IsSyncing__c = TRUE LIMIT 1];
        double lostMRR = 0.00;

        List<FTRWSAddress__c> addrList = [SELECT Id FROM FTRWSAddress__c WHERE Opportunity_ID__c =: oppId[0] AND Address_Lost_checkbox__c = TRUE];

        List<Id> addrIdList = new List<Id>();

		for (FTRWSAddress__c a: addrList){
    		addrIdList.add(a.Id);
		}

        if (quote != null && addrList != null){
            List<SterlingQuoteItem__c> quoteItemList = [SELECT Id, NetNewMRR__c, ST_AddressID__c FROM SterlingQuoteItem__c WHERE SterlingQuote__c =:quote.Id];
            for (SterlingQuoteItem__c item: quoteItemList){
                if (addrIdList.contains(item.ST_AddressID__c)){
                    lostMRR = lostMRR +  item.NetNewMRR__c;
                    System.debug('lostMrr:' + lostMRR);
                }
            }
        }

        Opportunity opp = [SELECT Lost_MRR2__c FROM Opportunity WHERE Id =:oppId[0]];
        opp.Lost_MRR2__c = lostMRR;
        if (!Test.isRunningTest()){
            update opp;
        }
        System.debug('opp:'+opp);
    }catch(Exception e){
        System.debug(e);
    }
    }


}