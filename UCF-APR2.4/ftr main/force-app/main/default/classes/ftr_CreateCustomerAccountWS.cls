/**
* 
* @description CreateCustomerAccount webservice called from ftr_CreateCustomerAccountRA remote action class
*/ 

public with sharing class ftr_CreateCustomerAccountWS {
    public class ftr_CreateCustomerAccountWSException extends Exception {}

    ftr_PSRService.PSRServicePort port;
    ftr_PSRService.createCustomerAccountRequestType request;
    private Map<String, Object> inputMap;
    @TestVisible private static IntegrationAPIConfig__mdt apiconfigs;
    @TestVisible private static NamedCredential apigeeCred;
    Boolean respError = false;

    //Constants
    private static final String AIP_CONFIG_SETTINGS = 'M6Authentication';
    private static final String AIPGEE_CRED = 'M6ApigeeCredentials';
    private static final String SHIPPING_STREET = 'ShippingStreet';
    private static final String SERVICE = 'Retail';
    private static final String ACCOUNTID = 'AccountId';
    private static final String ACCOUNT_NAME = 'AccountName';
    private static final String SHIPPING_CITY = 'ShippingCity';
    private static final String SHIPPING_STATE = 'ShippingStateCode';
    private static final String POSTAL_CODE = 'ShippingPostalCode';


    //Error messages //TODO: to be put in Custom Label
    private static final String ERR_NULL_INPUT = 'Null ApiKey/Timeout';
    private static final String ERR_NAMEDCRED_MISSING ='M6ApigeeCredentials Named Credential missing';
    private static final String ERR_INCORRECT_STREETNAME = 'Incorrect Street Name';

    // set static variables
    static {
        // query for the metadata record
        List<IntegrationAPIConfig__mdt> apiConfig = [SELECT ApiKey__c, Timeout__c,Authorization_Header__c  
                                                     FROM IntegrationAPIConfig__mdt 
                                                     WHERE DeveloperName =: AIP_CONFIG_SETTINGS 
                                                     LIMIT 1];
        
        // throw an exception if nothing is found, set the variable otherwise
        if (! Test.isRunningTest() && (apiConfig.isEmpty() || String.isBlank(apiConfig[0].ApiKey__c) || apiConfig[0].Timeout__c == null)) {
            throw new ftr_CreateCustomerAccountWSException(ERR_NULL_INPUT);
        }
        
        apiconfigs = apiConfig[0];
       
        List<NamedCredential> apigeeCreds = [SELECT DeveloperName, Endpoint FROM NamedCredential where DeveloperName =: AIPGEE_CRED];
        // throw an exception if nothing is found, set the variable otherwise
        if (! Test.isRunningTest() && apigeeCreds.isEmpty()) {
            throw new ftr_CreateCustomerAccountWSException(ERR_NAMEDCRED_MISSING);
        }

        apigeeCred = apigeeCreds[0];

    }

    //Creating Port
    private ftr_PSRService.PSRServicePort createPort(){
        this.port = new ftr_PSRService.PSRServicePort();
        this.port.endpoint_x = 'callout:M6ApigeeCredentials';   //apigeeCred.Endpoint; //        
        this.port.timeout_x = Integer.valueOf(apiconfigs.Timeout__c); //timeout;
        Map<String, String> headers = new Map<String, String>{
            'ApiKey' => apiconfigs.ApiKey__c,

            'Authorization' => 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(apiconfigs.Authorization_Header__c))
        };
        this.port.inputHttpHeaders_x = headers;
        return this.port;
    }
    
    private ftr_PSRService.createCustomerAccountRequestType createRequest(){
        String streetName = String.valueOf(inputMap.get(SHIPPING_STREET));
        this.request = new ftr_PSRService.createCustomerAccountRequestType();
        this.request.serviceCategory = SERVICE;
        this.request.custAcctNbr = String.valueOf(inputMap.get(ACCOUNTID)).toUpperCase();//'JOE191002';
        String companyName = String.valueOf(inputMap.get(ACCOUNT_NAME));//'Joes Garage #191002';
        companyName = companyName.escapeXml();
        this.request.companyName = companyName;
        this.request.customerAddress = new ftr_PSRService.addressType();
        this.request.customerAddress.houseNumberPrefix = '';
        this.request.customerAddress.houseNumberSuffix = '';
        this.request.customerAddress.preDirectional = '';
        try {
            this.request.customerAddress.streetName = streetName.substringAfter(' ');//ACCOUNT:ShippingAddress
            this.request.customerAddress.houseNumber = streetName.substring(0,streetName.indexOf(' '));//'191002';
        } catch(Exception e) {
            throw new ftr_CreateCustomerAccountWSException(ERR_INCORRECT_STREETNAME+ ' : ' + e.getMessage());
        }
        this.request.customerAddress.streetSuffix = '';
        this.request.customerAddress.postDirectional = '';
        this.request.customerAddress.suite = '';
        this.request.customerAddress.building = '';
        this.request.customerAddress.floor = '';
        this.request.customerAddress.room = '';
        this.request.customerAddress.community = '';
        this.request.customerAddress.county = '';
        this.request.customerAddress.city = String.valueOf(inputMap.get(SHIPPING_CITY));//'Rochester';
        this.request.customerAddress.state = String.valueOf(inputMap.get(SHIPPING_STATE));//'NY';
        this.request.customerAddress.postalCode = String.valueOf(inputMap.get(POSTAL_CODE));//'14623';
        System.debug(this.request);
        return this.request;
    }

    public String createCustomerAccount(Map<String, Object> inpMap){
        this.inputMap = inpMap;
        String response;
        ftr_PSRService.createCustomerAccountResponseType resp;
        createPort();
        createRequest();
        try {
            resp = this.port.createCustomerAccount(this.request);
            response = processResponse(resp);

            Map<String, Object> logOutput = new Map<String, Object>();
            Map<String, Object> logInput = new Map<String, Object> {
                'request' => this.request,
                'response' => resp,
                'interface' => 'createCustomerAccount',
                'system' => 'M6',
                'relatedTo' => inputMap.get(ACCOUNTID),
                'status' => respError ? 'Error' : 'Success' ,
                'convertToXML' => true
            };
            APILogger log = new APILogger();
            log.createEntry(logInput, logOutput);
        } catch (Exception e) {

            Map<String, Object> logOutput = new Map<String, Object>();
            Map<String, Object> logInput = new Map<String, Object> {
                'request' => this.request,
                'response' => resp,
                'interface' => 'createCustomerAccount',
                'errorCode' => '500',
                'errorMessage' => e.getMessage(),
                'system' => 'M6',
                'relatedTo' => inputMap.get(ACCOUNTID),
                'status' => 'Error',
                'convertToXML' => true
            };
            APILogger log = new APILogger();
            log.createEntry(logInput, logOutput);
            throw e;
        }

        return response;
    }

   private String processResponse(ftr_PSRService.createCustomerAccountResponseType response){
       
       System.debug('status message'+ response.statusMessage);
       response.createCustomerAccountResult = new ftr_PSRService.CreateCustomerAccountResult();
       System.debug('custNumber return '+ response.createCustomerAccountResult.custAcctNbr);
       String respMessage = response.statusMessage.get(0).message;
       String respCode = response.statusMessage.get(0).code;

       if(respCode != '0' && !respMessage.contains('Record Exists')){
           //return response.statusMessage.get(0).message;
           respError = true;
           throw new ftr_CreateCustomerAccountWSException(response.statusMessage.get(0).message);
        } else if(respMessage.contains('Record Exists')) {
            return respMessage.substringAfter('=');
        } else {
            return response.createCustomerAccountResult.custAcctNbr;
        }
       

   }

}