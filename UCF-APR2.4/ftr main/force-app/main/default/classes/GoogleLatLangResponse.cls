public class GoogleLatLangResponse {
    
    public List<Result> results{get;set;}
    
    
    public static FTRWSAddress__c parseAndSaveGoogleAddress(String response, String oppId, String inlat, String inlng) {
        FTRWSAddress__c address;
        Boolean matchFound = false;
        System.debug('Input oppId, lat and lng: ' + oppId +':' + inlat +':' + inlng);
        if(!String.isBlank(response)) {
            GoogleLatLangResponse jsonResponse = (GoogleLatLangResponse) System.JSON.deserialize(response, GoogleLatLangResponse.class);
            System.debug('JSON parsed google Address response: '+jsonResponse); 
            if(jsonResponse != null) {
                List<AddressComponent> addrCompList = null;
                List<Result> results = jsonResponse.results;
                
                System.debug('google Address results: '+results + 'size: ' + results.size()); 
                String formattedAddr = '';
                if(results != null && results.size() >0) {
                    Result result = results.get(0);
                    if(result.address_components != null && result.address_components.size() > 0) {
                        addrCompList = result.address_components;
                        formattedAddr = result.formatted_address;
                        address = new FTRWSAddress__c();  
                        address.Address__c = formattedAddr;
						address.Opportunity_ID__c = oppId;
                        for(AddressComponent addrComp : addrCompList) {
                            String[] types = addrComp.types;
                            
                            if(types!=null && types.size() > 0) {
                                if(types[0] == 'street_number') {
                                    address.Street_Number__c = addrComp.long_name;
                                } else if(types[0] == 'route') {
                                    address.Street_Name__c = addrComp.short_name;
                                } else if(types[0] == 'locality' && types[1] == 'political') {
                                    address.City__c = addrComp.long_name;
                                }else if(types[0] == 'administrative_area_level_1' && types[1] == 'political') {
                                    address.State__c = addrComp.short_name;
                                } else if(types[0] == 'postal_code') {
                                    address.Zip_Code__c = addrComp.long_name;
                                }
                                
                            }                        
                            
                        }
                        return address;                        
                    }
                }                
            }
        }
        
        return null;        
    }    
    
    
    /* OLD method implementation: paa512 
     * 
     * public static FTRWSAddress__c parseAndSaveGoogleAddress(String response, String oppId, String inlat, String inlng) {
FTRWSAddress__c address;
Boolean matchFound = false;
System.debug('Input lat and lng: ' + inlat +':' + inlng);
if(!String.isBlank(response)) {
GoogleLatLangResponse jsonResponse = (GoogleLatLangResponse) System.JSON.deserialize(response, GoogleLatLangResponse.class);
System.debug('JSON parsed google Address response: '+jsonResponse); 
if(jsonResponse != null) {
List<AddressComponent> addrCompList = null;
List<Result> results = jsonResponse.results;

System.debug('google Address results: '+results + 'size: ' + results.size()); 
String formattedAddr = '';
for(Result result : results) {
Geometry geometry = result.geometry;

Double glatitude;
Double glongitude;
if(geometry != null && geometry.location != null) {
System.debug('geometry.location: ' + geometry.location); 
GLocation location = geometry.location;
glatitude = location.lat; 
glongitude = location.lng; 
}
Double inputlat = Double.valueOf(inlat);
Double inputlang = Double.valueOf(inlng); 
System.debug('Output inputlat/glatitude and inputlang/glongitude: ' + inputlat+'/'+glatitude +':' + inputlang+'/'+glongitude);   
if(inputlat == glatitude && inputlang == glongitude) {
System.debug('Matched lat and lng:' + glatitude +':'+ glongitude);
addrCompList = result.address_components;
formattedAddr = result.formatted_address;
matchFound = true;
break;
}
}

if(matchFound && addrCompList != null && addrCompList.size() > 0) {
address = new FTRWSAddress__c();  
address.Address__c = formattedAddr;
for(AddressComponent addrComp : addrCompList) {
String[] types = addrComp.types;

if(types!=null && types.size() > 0) {
if(types[0] == 'street_number') {
address.Street_Number__c = addrComp.long_name;
} else if(types[0] == 'route') {
address.Street_Name__c = addrComp.long_name;
} else if(types[0] == 'locality' && types[1] == 'political') {
address.Opportunity_ID__c = oppId;
}else if(types[0] == 'administrative_area_level_1' && types[1] == 'political') {
address.State__c = addrComp.long_name;
} else if(types[0] == 'postal_code') {
address.Zip_Code__c = addrComp.long_name;
}

}
}  

return address;
}
}
}

return null;        
} */   
    
    public class Result{
        public List<AddressComponent> address_components{get;set;}
        public String formatted_address{get;set;}
        public Geometry geometry{get;set;}
    }
    public class AddressComponent {
        public String long_name{get;set;}
        public String short_name{get;set;}
        public String[] types{get;set;}
        
    }
    
    public class Geometry {
        public Bounds bounds{get;set;}
        public GLocation location{get;set;}
        public String short_name{get;set;}
    } 
    
    public class GLocation {
        public final Double lat{get;set;}
        public final Double lng{get;set;}
        public GLocation(Double lat1, Double lng1) {
            this.lat = lat1;
            this.lng = lng1;
        }
    } 
    
    public class Bounds {
        public GLocation northeast{get;set;}
        public GLocation southwest{get;set;}
    }
    
}