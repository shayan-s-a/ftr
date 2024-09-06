
//version 1.0

trigger FTRWSSterlingQuoteTrigger on SterlingQuote__c (after update) {
    
    try {
        
        
        if( Trigger.isAfter && Trigger.isUpdate) {
            
        System.debug('FTRWSSterlingQuoteTriggerHandler.AfterUpdate');
        
      List<SterlingQuote__c> quotes = Trigger.New;
        SterlingQuote__c quote = null;
        if(quotes != null && quotes.size() > 0) {
        	quote = quotes.get(0);    
        }
        
        if(quote != null && String.isNotBlank(quote.Status__c) && quote.Status__c.equalsIgnoreCase('Approved')) {
            RecordType recordtype = [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'Carrier_Service' AND SobjectType = 'SterlingQuote__c' limit 1];
            if(quote.RecordTypeId == recordtype.Id) {

            System.debug('quote id in FTRWSSterlingQuoteTrigger: ' + quote.Id);
            List<SterlingQuoteItem__c> sqis = [Select OverallStatus__c, Id from SterlingQuoteItem__c where SterlingQuote__c =:quote.Id];
            
            System.debug('quote items in FTRWSSterlingQuoteTrigger: ' + sqis);
            for(SterlingQuoteItem__c sqi : sqis) {
                if(sqi != null && String.isNotBlank(sqi.OverallStatus__c) && sqi.OverallStatus__c.equalsIgnoreCase('Pending')) {
                    sqi.OverallStatus__c = 'Approved';
                }
            }
            
            update sqis;
                
            }

        }
            

        if(quote != null && String.isNotBlank(quote.Status__c) && quote.Status__c.equalsIgnoreCase('Rejected')) {
            RecordType recordtype = [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'Carrier_Service' AND SobjectType = 'SterlingQuote__c' limit 1];
            if(quote.RecordTypeId == recordtype.Id) {

            System.debug('quote id in FTRWSSterlingQuoteTrigger: ' + quote.Id);
            List<SterlingQuoteItem__c> sqis = [Select OverallStatus__c, Id,StandardMRC__c,AdjustedMRC__c, AdjustedNRC__c,StandardNRC__c, UpdatedMRC__c, UpdatedNRC__c  from SterlingQuoteItem__c where SterlingQuote__c =:quote.Id];
            
            System.debug('quote items in FTRWSSterlingQuoteTrigger: ' + sqis);
            for(SterlingQuoteItem__c sqi : sqis) {
                if(sqi != null && sqi.StandardMRC__c != sqi.AdjustedMRC__c) {
                    sqi.AdjustedMRC__c = sqi.StandardMRC__c;
                    sqi.UpdatedMRC__c = sqi.StandardMRC__c;
                }
                if (sqi != null && sqi.StandardNRC__c != sqi.AdjustedNRC__c){
                    sqi.AdjustedNRC__c = sqi.StandardNRC__c;
                    sqi.UpdatedNRC__c = sqi.StandardNRC__c;
                }
            }
            
            update sqis;
                
            }

        }
            
        }
        
    } catch (Exception ex) {
        System.debug('Exception in FTRWSSterlingQuoteTrigger: --'+ ex.getStackTraceString());
    }
}