/*********************************************************************************************************************
*@Name        : ProductBundlesBaseService
*@Author      : Dileep Chinthala <dileep.chinthala@ftr.com>
*@Description : This utility class is called from ftr_ProductBundlesBaseTriggerHandler to perform look-up of 
				certain fields on Product Bundles Admin records to populate the fields based on related field values. 
				
* UPDATES
* Version 		Date       		Developer  				Description
*------------------------------------------------------------------------------------------------------------------
*1.0    		08/04/2021     Dileep Chinthala      Initial Creation                                                      

**********************************************************************************************************************/

public class ProductBundlesBaseService {
    public static void setPricebookitemId( List<Product_Bundles_Base__c> newItems ){
        Set<Id> productIds = new Set<Id>();
        Map<Id,Id> standardProductPriceIdsMap = new Map<Id,Id>();
        for(Product_Bundles_Base__c pbbObj: newItems){
            if(pbbObj.DIA_Bundle__c != null){
                productIds.add( pbbObj.DIA_Bundle__c );
            }
            if(pbbObj.Managed_Firewall_Bundle__c != null){
                productIds.add( pbbObj.Managed_Firewall_Bundle__c );
            }
            if(pbbObj.SIP_Bundle__c != null){
                productIds.add( pbbObj.SIP_Bundle__c );
            }
            if(pbbObj.UCF_Bundle__c != null){
                productIds.add( pbbObj.UCF_Bundle__c );
            }
            if(pbbObj.UCF_Phone__c != null){
                productIds.add( pbbObj.UCF_Phone__c );
            }
        }
        if(productIds.size() > 0){
            for(PriceBookEntry pbe : [Select Id, Product2Id from PriceBookEntry where Product2Id IN :productIds AND PriceBook2.Name = 'Standard Price Book']){
                standardProductPriceIdsMap.put( pbe.Product2Id, pbe.Id );
            }
            for(Product_Bundles_Base__c pbbObj: newItems){
                
                if(pbbObj.DIA_Bundle__c != null){
                    pbbObj.DIA_Bundle_PBE__c = standardProductPriceIdsMap.get( pbbObj.DIA_Bundle__c );
                }
                if(pbbObj.Managed_Firewall_Bundle__c != null){
                    pbbObj.Managed_Firewall_PBE__c = standardProductPriceIdsMap.get( pbbObj.Managed_Firewall_Bundle__c );
                }
                if(pbbObj.SIP_Bundle__c != null){
                    pbbObj.SIP_Bundle_PBE__c = standardProductPriceIdsMap.get( pbbObj.SIP_Bundle__c );
                }
                if(pbbObj.UCF_Bundle__c != null){
                    pbbObj.UCF_Bundle_PBE__c = standardProductPriceIdsMap.get( pbbObj.UCF_Bundle__c );
                }
                if(pbbObj.UCF_Phone__c != null){
                    pbbObj.UCF_Phone_PBE__c = standardProductPriceIdsMap.get( pbbObj.UCF_Phone__c );
                }
            }
        }
    }
}