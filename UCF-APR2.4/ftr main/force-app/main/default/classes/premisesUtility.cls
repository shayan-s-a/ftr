public with sharing class premisesUtility {
    public static void setKey(List<vlocity_cmt__Premises__c> premisesList) {
        for(vlocity_cmt__Premises__c prem:premisesList){
            String retsha256Hash = getAddressHashKey(prem.vlocity_cmt__StreetAddress__c, 
            prem.vlocity_cmt__City__c, prem.vlocity_cmt__State__c, prem.vlocity_cmt__PostalCode__c, 
            prem.vlocity_cmt__Country__c, prem.vlocity_cmt__UnitNumber__c);
            if(retsha256Hash != null){
                prem.Key__c = retsha256Hash;
            }
        }
    }
    public static string getAddressHashKey(string streetAddress, String city, String state, String postalCode, String country, String addressUnit){
        String addressLine = '';
        if(!String.isBlank(streetAddress)){
            addressLine = streetAddress;
        }
        if(!String.isBlank(city)){
            addressLine += ', ' + city;
        }
        if(!String.isBlank(state)){
            addressLine += ', ' + state;
        }
        if(!String.isBlank(postalCode)){
            addressLine += ', ' + postalCode;
        }
        if(!String.isBlank(country)){
            addressLine += ', ' + country;
        }
        
        addressLine = addressLine.toLowerCase();
        String retsha256Hash = convertStringToSha256Hash(addressLine);
        if (!String.isBlank(addressUnit)){
            return retsha256Hash+'-'+addressUnit.toLowerCase();
        }else {
            return retsha256Hash;
        }
    }
    public static vlocity_cmt__Premises__c getPremise(string streetAddress, String city, String state, String postalCode, String country, String addressUnit){
        string key = getAddressHashKey(streetAddress, city, state, postalCode, country, addressUnit);
        if (key!= null){
            List<vlocity_cmt__Premises__c> lstPremises = new List<vlocity_cmt__Premises__c>([select Id, vlocity_cmt__StreetAddress__c, key__c,
            vlocity_cmt__City__c,vlocity_cmt__State__c, vlocity_cmt__PostalCode__c,
            vlocity_cmt__Country__c, vlocity_cmt__UnitNumber__c from vlocity_cmt__Premises__c  where
            Key__c =:key ]);
            if (lstPremises.size()>0){
                return lstPremises[0];
            }else {
                return null;
            }
        }else {
            return null;
        }
    }
    public static String convertStringToSha256Hash(String address){
        String sha256Hash;
        if(!String.isBlank(address)){
            Blob targetBlob = Blob.valueOf(address);
            Blob hash = Crypto.generateDigest('SHA-256', targetBlob);
            sha256Hash = EncodingUtil.base64Encode(hash);
        }
        return sha256Hash;
    }
}