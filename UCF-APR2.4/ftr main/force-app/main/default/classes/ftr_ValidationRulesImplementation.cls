global class ftr_ValidationRulesImplementation implements vlocity_cmt.GlobalInterfaces.ProductValidationInterface, vlocity_cmt.UOWSupportedInterface{
    
    global static void validateLineItems(List<vlocity_cmt.ItemWrapper> itemsList) {
        //System.debug('*****************************Testing*********************'+itemsList);
        vlocity_cmt.GlobalInterfaces.ProductValidationInterface pvi = new vlocity_cmt.ValidationRulesImplementation();
        if(!Test.isRunningTest()){
        pvi.validateLineItems(itemsList);
        }
        Id wifiIndoor = [select id from product2 where productcode = 'ENT_ETH_WIFI_01'][0].Id;
        Id wifiOutdoor = [select id from product2 where productcode = 'ENT_ETH_WIFI_02'][0].Id;
        System.debug('***********wifiIndoor***'+wifiIndoor);
        System.debug('***********wifiOutdoor***'+wifiOutdoor);
        Integer totalWifiQty = 0;
        String rootId = '';
        Map<String,Integer> rootWifi = new Map<String,Integer>();
        for (vlocity_cmt.ItemWrapper item : itemsList) {
            //System.debug('***********3333***'+item.itemSObject.get('vlocity_cmt__Product2Id__c'));
            if((item.itemSObject.get('vlocity_cmt__Product2Id__c') == wifiIndoor && item.itemSObject.get('vlocity_cmt__Action__c') != 'Disconnect') || (item.itemSObject.get('vlocity_cmt__Product2Id__c') == wifiOutdoor && item.itemSObject.get('vlocity_cmt__Action__c') != 'Disconnect')){
                rootId = String.valueOf(item.itemSObject.get('vlocity_cmt__RootItemId__c'));
                /*System.debug('***********5555***'+item);
                System.debug('***********9999***'+item.itemSObject.get('vlocity_cmt__Product2Id__c'));
                System.debug('***********7777***'+item.itemSObject.get('Quantity'));*/
                System.debug('********999*******'+rootWifi.get(rootId));
                totalWifiQty = rootWifi.get(rootId)!=null?Integer.valueOf(rootWifi.get(rootId)):0;
                totalWifiQty = totalWifiQty + Integer.valueOf(item.itemSObject.get('Quantity'));
                rootWifi.put(rootId,totalWifiQty);
                if(totalWifiQty < 1 || totalWifiQty > 4)
                    item.errors.add('Minimum 1 & Maximum 4 as a combination of both Indoor & Outdoor AP qty.');
                System.debug('***********1111***'+rootWifi);    
            }
        }
    }
}

