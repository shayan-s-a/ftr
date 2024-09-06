/********************************************************************************************
Name : ZAddressUtility
Created By : Mohan Talluri (mohan.talluri@ftr.com)
Created Date : June 13, 2016
Description :  Utility to support ZAddress Trigger Handler.
********************************************************************************************/
public with sharing class ZAddressUtility {

    public static void updateSQI(Map<Id, SObject> newItems) {
    
        List<SterlingQuoteItem__c> lstSterlingQuoteItemUpdate = new List<SterlingQuoteItem__c>();
        List<SterlingQuoteItem__c> lstSterLingQuoteItem = new List<SterlingQuoteItem__c>();     
        Map<Id,List<ZAddress__c>> mapSterlingIdByListZAddress = new Map<Id,List<ZAddress__c>>();
        set<Id> setSterlingQuoteItem = new set<Id>();
        Boolean IsInFrontierFootprint;
        
        ZAddress__c ZAdd;    
        
        for(sObject obj : newItems.values()) { 
           ZAdd = (ZAddress__c)obj;
           if(ZAdd.SterlingQuoteItem__c != null)
              setSterlingQuoteItem.add(ZAdd.SterlingQuoteItem__c);
        }
      
      
        lstSterLingQuoteItem  = [Select id,(select IsInFrontierFootprint__c From ZAddresss__r) from SterlingQuoteItem__c where id in :setSterlingQuoteItem];
        
        if(lstSterLingQuoteItem != null && lstSterLingQuoteItem.size() > 0){
            List<ZAddress__c> lstZAddress = new List<ZAddress__c>();
            for(SterlingQuoteItem__c SQI : lstSterLingQuoteItem){
              lstZAddress = new List<ZAddress__c>();
              for(ZAddress__c ZAdd1 : SQI.ZAddresss__r)
                 lstZAddress.add(ZAdd1);
              
              mapSterlingIdByListZAddress.put(SQI.Id,lstZAddress);
            }
        }               
      
        List<ZAddress__c> lstZAdd;
        
        for(sObject obj : newItems.values()){ 
              ZAdd = (ZAddress__c)obj; 
              if(ZAdd.SterlingQuoteItem__c != null){
                lstZAdd= new List<ZAddress__c>();
                lstZAdd = mapSterlingIdByListZAddress.get(ZAdd.SterlingQuoteItem__c);
                if(ZAdd.IsInFrontierFootprint__c== false && lstZAdd != null && lstZAdd.size() >0){
                    for(ZAddress__c ZAd : lstZAdd)
                    {
                      if(ZAd.IsInFrontierFootprint__c == false){
                          IsInFrontierFootprint = false; 
                          break;                    
                      }
                      else{ IsInFrontierFootprint = true;  }
                    }
                 }
                 else { IsInFrontierFootprint = true; }
              }
        }  
        updateItems(lstSterLingQuoteItem, IsInFrontierFootprint);      
    }
    
    private static void updateItems(List<SterlingQuoteItem__c> itemList, boolean IsInFrontierFootprint){
        List<SterlingQuoteItem__c> lstSterlingQuoteItemUpdate = new List<SterlingQuoteItem__c>();
        for(SterlingQuoteItem__c SQI : itemList){
          SQI.IsInFrontierFootprint__c = IsInFrontierFootprint;
          lstSterlingQuoteItemUpdate.add(SQI);
        }
       
      
      if(lstSterlingQuoteItemUpdate.size() > 0)          
          update lstSterlingQuoteItemUpdate;  
    }
    
    
    
    public static void processDelete(List<ZAddress__c> oldItems){
    
       List<SterlingQuoteItem__c> lstSterlingQuoteItemUpdate = new List<SterlingQuoteItem__c>();   
       Map<Id,List<ZAddress__c>> mapSterlingIdByListZAddress = new Map<Id,List<ZAddress__c>>();
       set<Id> setSterlingQuoteItem = new set<Id>();
       Boolean IsInFrontierFootprint;
       ZAddress__c ZAdd;
       List<ZAddress__c> lstZAdd;        
       for(sObject obj : oldItems){ 
           ZAdd = (ZAddress__c)obj;
           if(ZAdd.SterlingQuoteItem__c != null)
              setSterlingQuoteItem.add(ZAdd.SterlingQuoteItem__c);
       }
      
       List<SterlingQuoteItem__c> lstSterLingQuoteItem = new List<SterlingQuoteItem__c>();
       lstSterLingQuoteItem  = [Select id,(select IsInFrontierFootprint__c From ZAddresss__r)
                                 from SterlingQuoteItem__c where id in :setSterlingQuoteItem];      
       List<ZAddress__c> lstZAddress;
                                 
       if(lstSterLingQuoteItem != null && lstSterLingQuoteItem.size() > 0){
          for(SterlingQuoteItem__c SQI : lstSterLingQuoteItem){
              lstZAddress = new List<ZAddress__c>();
              for(ZAddress__c ZAdd2 : SQI.ZAddresss__r)
                 lstZAddress.add(ZAdd2);
              
              mapSterlingIdByListZAddress.put(SQI.Id,lstZAddress);
          }
       }
        
       for(sObject obj : oldItems){ 
        
          ZAdd = (ZAddress__c)obj;
          if(ZAdd.SterlingQuoteItem__c != null){
            lstZAdd= new List<ZAddress__c>();
            lstZAdd = mapSterlingIdByListZAddress.get(ZAdd.SterlingQuoteItem__c);
            if(lstZAdd != null && lstZAdd.size() >0){
                for(ZAddress__c ZAd : lstZAdd)
                {
                  System.Debug('*   ***'+ZAd.IsInFrontierFootprint__c);
                  if(ZAd.IsInFrontierFootprint__c == false){
                      IsInFrontierFootprint = false; 
                      break;                      
                  }
                  else{
                      IsInFrontierFootprint = true;
                      break;
                  }
                }
             }
             else
                  IsInFrontierFootprint = true;             
          }
       }  
       updateItems(lstSterLingQuoteItem, IsInFrontierFootprint); 
    }
    
    Public static void updateOpptyLineItems(Map<Id, SObject> newItems){  
        
        List<SterlingQuoteItem__c> lstSterLingQuoteItems = new List<SterlingQuoteItem__c>();
        List<OpportunityLineItem> lstOpptyLineItems = new List<OpportunityLineItem>();     
        Map<Id,List<ZAddress__c>> mapSterlingIdByListZAddress = new Map<Id,List<ZAddress__c>>();
        Set<Id> setSterlingQuoteItem = new Set<Id>();
        Set<Id> OpptyLineItemSet = new Set<Id>();
        Map<Id,String> zAddresWithQLIMap = new Map<Id,String>();
        ZAddress__c ZAdd; 
        String addressOLI ='';
        
        for(sObject obj : newItems.values()) { 
           ZAdd = (ZAddress__c)obj;
           if(ZAdd.SterlingQuoteItem__c != null)
              setSterlingQuoteItem.add(ZAdd.SterlingQuoteItem__c);
              addressOLI = (ZAdd.StreetNrFirst__c != null) ?  (ZAdd.StreetNrFirst__c) : '';
              addressOLI += ' ';
              addressOLI += (ZAdd.StreetName__c != null) ? (ZAdd.StreetName__c) : '';
              addressOLI += ' ';
              addressOLI += (ZAdd.StreetSuffix__c != null) ? (ZAdd.StreetSuffix__c) : '' ;
              addressOLI += ' ';
              addressOLI += (ZAdd.Locality__c != null) ? (ZAdd.Locality__c) : '';
              addressOLI += ' ';  
              addressOLI += (ZAdd.StateOrProvince__c != null) ? (ZAdd.StateOrProvince__c) : '';
              addressOLI += ' ';  
              addressOLI += (ZAdd.Postcode__c != null) ? (ZAdd.Postcode__c) : '';
              zAddresWithQLIMap.put(ZAdd.SterlingQuoteItem__c, addressOLI);
              System.debug('ZAddress-162====='+addressOLI);
        }
            
        lstSterLingQuoteItems  = [Select id,OpportunityLineItemId__c,(select id,StreetNrFirst__c,StreetName__c,StreetSuffix__c,Locality__c,StateOrProvince__c,Postcode__c, IsInFrontierFootprint__c From ZAddresss__r) from SterlingQuoteItem__c where id IN :setSterlingQuoteItem];
        
        if(lstSterLingQuoteItems != null && lstSterLingQuoteItems.size() > 0){
            //List<ZAddress__c> lstZAddress = new List<ZAddress__c>();
            for(SterlingQuoteItem__c SQI : lstSterLingQuoteItems){              
            	OpptyLineItemSet.add(SQI.OpportunityLineItemId__c);
            }
        }

        for(OpportunityLineItem OLI :[select id,ZAddress__c,QuoteItem__c from OpportunityLineItem where id IN :OpptyLineItemSet]){
        
            if(zAddresWithQLIMap.containsKey(OLI.QuoteItem__c)){
                OLI.ZAddress__c = zAddresWithQLIMap.get(OLI.QuoteItem__c);  
                lstOpptyLineItems.add(OLI);
                System.debug('ZAddress-179====='+OLI.ZAddress__c);
            }            
        } 
        
        if(lstOpptyLineItems.size() > 0){
            upsert lstOpptyLineItems;            
        }    
	}
    
}