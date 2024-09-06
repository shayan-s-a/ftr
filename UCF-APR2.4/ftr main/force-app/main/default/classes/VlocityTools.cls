/**
* @author Sean Fife
* @date 2 Nov 2019
* @group Vlocity Component Implementations
* @description Custom functions unavailable to Vlocity Components
* @version 2
*/ 
global class VlocityTools implements vlocity_cmt.VlocityOpenInterface {

    global static Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) 
    {
        if (methodName.equalsIgnoreCase('reformatproducts'))
        {
            ReformatProducts(inputMap, outputMap);
            return true;
        }
        else if (methodName.equalsIgnoreCase('verifyVendors')){
            verifyVendors(inputMap, outputMap);
            return true;
        }else if (methodName.equalsIgnoreCase('reformatproductshbe')){
            ReformatProductsHBE(inputMap, outputMap);
            return true;
        }
        return false;
    }
    
    private static void ReformatProducts(Map<String, Object> inputMap, Map<String, Object> outputMap)
    {
        system.debug(inputMap);

        List<object> objproducts = (List<object>)inputMap.get('Products');
        if(objproducts == null)
        {
            outputMap.put('value', 'None');
            return;
        }
     
        List<string> products = new List<string>();
        for(integer i = 0; i<objproducts.size(); i++)
        {
            products.add(objproducts[i].toString());
        }
        
        
        outputMap.put('value', string.join(products, ','));
    }
    
    private static void verifyVendors(Map<String, Object> inputMap, Map<String, Object> outputMap){
        System.debug('verifyVendors:start::'+ inputMap);
        List<object> objproducts = (List<object>)inputMap.get('EReachProviders');
        if(objproducts == null){
            outputMap.put('value', 'None');
            return;
        }
        Map<String, ftr_EReach_Vendor_Mapping__mdt> vendorMappingList = ftr_EReach_Vendor_Mapping__mdt.getAll();
        List<Map<String,object>> vendordetails = new List<Map<String,object>>();
        List<Map<String,object>> filtervendordetails = new List<Map<String,object>>();
        List<Map<String,object>> bdtmissingvendordetails = new List<Map<String,object>>();
        set<string>vendorkeyMdtSet= new set<string>();
        Map<string,ftr_EReach_Vendor_Mapping__mdt> vendorkeyMapmdt= new Map<string,ftr_EReach_Vendor_Mapping__mdt>();
        for(object obj: objproducts){
            Map<String,object> temp = (Map<String,object>) obj;
            if(!'NoService'.equalsIgnoreCase((String)temp.get('QoS'))){
                Map<String,object> out = new Map<String,object>();
                if(vendorMappingList.containsKey((String)temp.get('ProviderName'))){
                    ftr_EReach_Vendor_Mapping__mdt VendorMapping = vendorMappingList.get((String)temp.get('ProviderName'));
                    out.put('ProviderName',VendorMapping.New_Value__c);
                }else{
                    out.put('ProviderName',temp.get('ProviderName'));
                }
                out.put('Speed',temp.get('Speed'));
                out.put('QoS',temp.get('QoS'));
                out.put('Tier',temp.get('PartnerTier'));
                vendordetails.add(out);
            }
        }
        map<string,EreachPartnerAndTierMapping__mdt> partnerTiermpalist =EreachPartnerAndTierMapping__mdt.getAll();
        for(EreachPartnerAndTierMapping__mdt partnerMdt:partnerTiermpalist.values()){
            string vendormapkey = partnerMdt.Partner__c+'_'+partnerMdt.PartnerTier__c;
            vendorkeyMdtSet.add(vendormapkey);
        }
        for(map<string,Object>partnermap :vendordetails){
            String PartnerTierKey =partnermap.get('ProviderName')+'_'+partnermap.get('Tier');
            if(vendorkeyMdtSet.contains(PartnerTierKey)){
              filtervendordetails.add(partnermap);  
            }
            else{
                bdtmissingvendordetails.add(partnermap);
            }
	     
        }
        vendordetails.clear();
        vendordetails.addAll(filtervendordetails);
        outputMap.put('value', vendordetails);
        outputMap.put('bdtmissVendors', bdtmissingvendordetails);
        system.debug('@@@BDT'+bdtmissingvendordetails);
        
    }
	private static void ReformatProductsHBE(Map<String, Object> inputMap, Map<String, Object> outputMap)
    {
        system.debug(inputMap);
		Map<String,Object> hbeDetails = (Map<String,Object>)inputMap.get('HBEDetails');
        system.debug('hbeDetails Map-->'+hbeDetails);
        List<object> objproducts = (List<object>)hbeDetails.get('Products');
        if(objproducts == null)
        {
            outputMap.put('value', 'None');
            return;
        }
     
        List<string> products = new List<string>();
        for(integer i = 0; i<objproducts.size(); i++)
        {
            products.add(objproducts[i].toString());
        }
        
        
        outputMap.put('value', string.join(products, ','));
    }
   
}