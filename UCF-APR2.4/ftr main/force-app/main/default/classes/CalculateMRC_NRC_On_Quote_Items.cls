public class CalculateMRC_NRC_On_Quote_Items 
{
    @InvocableMethod(label='MRC_NRC_AVG' description='Calculating Average MRC and NRC')
/*    public static void updateMRCandNRC(List<id> qitemID) 
    {
        SterlingQuoteItem__c qrec = [select Id,Products__c,TermLength__c,SterlingQuote__c from SterlingQuoteItem__c where Id =: qitemID[0] limit 1];
        List<SterlingQuoteItem__c> qlist =[select Id,AdjustedMRC__c,AdjustedNRC__c 
                                           from SterlingQuoteItem__c where SterlingQuote__c =: qrec.SterlingQuote__c ];
	*/
    public static void updateMRCandNRC(List<id> qitemID) 
    {        
        List<SterlingQuoteItem__c> qlist =[select Id,AdjustedMRC__c,AdjustedNRC__c 
                                           from SterlingQuoteItem__c where SterlingQuote__c =: qitemID[0] ];
        SterlingQuote__c Quote1 = [select Id,OpportunityId__c from SterlingQuote__c where Id=:qitemID[0] limit 1];
        Opportunity op = [select Id,Avg_MRC__c,Avg_NRC__c from Opportunity where Id=:Quote1.OpportunityId__c limit 1];

        // Calculating Total MRC and NRC
        decimal Total_MRC=0,Total_NRC=0,Count_Rec=0,AVG_MRC=0,AVG_NRC=0;
        for(SterlingQuoteItem__c qc : qlist)
        {
            if(qc.AdjustedMRC__c != null || qc.AdjustedMRC__c != 0)
            {
                Total_MRC = Total_MRC + qc.AdjustedMRC__c;              
            }
            if(qc.AdjustedNRC__c != null || qc.AdjustedNRC__c != 0)
            {
                Total_NRC = Total_NRC + qc.AdjustedNRC__c;                                
            }            
                Count_Rec = Count_Rec +1;                            
            System.debug('<=> 1.Each Quote Item :'+qc);
        }
        if(Total_MRC>0){AVG_MRC = Total_MRC/Count_Rec;}
        if(Total_NRC>0){AVG_NRC = Total_NRC/Count_Rec;}
        
        System.debug('Total MRC :'+Total_MRC);
        System.debug('count MRC :'+Count_Rec);
        System.debug('Total NRC :'+Total_NRC);          
        System.debug('Count NRC :'+Count_Rec);    
        System.debug('Average MRC :'+AVG_MRC);
        System.debug('Average NRC :'+AVG_NRC); 
        if(AVG_MRC>0)
        {
            op.Avg_MRC__c =AVG_MRC;
        }
        if(AVG_NRC>0)
        {
           op.Avg_NRC__c =AVG_NRC; 
        }        
        update op;
     }
}