public with sharing class GooglePlacesController {

     /**
    * @description : Auto suggestion Web Service 
    * @param : input: SearchAddress , types: Results Types , langug : language for getting the      results
    * @return : string
    **/  
    @AuraEnabled
    public static string getSuggestions(String input) {
       String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
            + 'input=' + EncodingUtil.urlEncode(input, 'UTF-8')
            + getGoogleAPIKey();   
      
        String response = getResponse(url); 
        system.debug('Response suggestions***'+response);
        return response;
    }
    
     /**
    * @description : Place Details Web Service 
    * @param : PlaceId: Unique Place Id , langug : language for getting the results
    * @return : string
    **/ 
    @AuraEnabled
    public static string getPlaceDetails(String placeId) {
        String url = 'https://maps.googleapis.com/maps/api/place/details/json?'
            + 'placeid=' + EncodingUtil.urlEncode(placeId, 'UTF-8')
            + getGoogleAPIKey(); 
        String response = getResponse(url);
        system.debug('Response places****'+response);
        return response;
    }
    
    
         /**
    * @description : Place Details Web Service using Lat and Lng
    * @param : lat: latitude, lng: longitude for getting the results
    * @return : string
    **/ 
    @AuraEnabled
    public static string getPlaceDetailsWithLatLong(String lat, String lng) {
        String latLng = lat +','+lng;
        String url = 'https://maps.googleapis.com/maps/api/geocode/json?'
            + 'latlng=' + EncodingUtil.urlEncode(latLng, 'UTF-8')
            + getGoogleAPIKey(); 
        String response = getResponse(url);
        system.debug('Response places with Lat and Longitude****'+response);
        return response;
    }
    
      /**
    * @description : Common Utility method for making call out
    * @param : String
    * @return : string
    **/
    
    public static string getResponse(string strURL){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setEndpoint(strURL);
        req.setTimeout(120000);
        res = h.send(req); 
        String responseBody = res.getBody(); 
        //system.debug('responseBody---'+responseBody);
        return responseBody; 
    }
    
     /**
    * @description : To get the google Api key from custom label
    * @param : 
    * @return : string
    **/
    private static string getGoogleAPIKey(){
        /*Enter your API key here*/
        string key = 'AIzaSyDShWDFIWpdk7iDC7FDoMYMdAqR5jSdhD4';
        string output = '&key=' + key;   
        return output;
    }
    
    //Save address attributies to the FTRWSAddress table and then link to the address record to the
    //opportunity table
  /*  @AuraEnabled
    public static string saveAddress(FTRWSDPIAddressResponse dpiResponse){
      
      Opportunity opp = new Opportunity();
      warpper wrap = new warpper();
      
      return JSON.serialize(wrap);
    } */
    
  /*  @AuraEnabled
    public static boolean getOppStage(String oppId){
      List<Opportunity> opplist = new List<Opportunity>();
      Boolean notstage ; 
      if(oppId != null){
        opplist = [select id , StageName from Opportunity where id=: oppId];
        if(opplist[0].StageName == '06 - Mortgage Booked'){
          notstage = true;
        }else{
          notstage = false;
        }
      }
      return notstage;
    }
    
    public class warpper{
        @AuraEnabled
        public boolean isSuccess{get;set;}
        
        @AuraEnabled
        public String errormessage{get;set;}
    }*/
}