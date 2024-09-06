global without sharing class ftr_SIPM6CreateCustomerAccountInterface extends ftr_SIPM6BaseSystemInterface {
     /**
     * This method is called from executeItem to create M6 CustomerAccount 
     *
     * @param  url  base URL for the batch
     * @param  path path for the batch
     * @param  input payload to be used to construct 
     * @return         M6 RequestType object to be sent
     * @version 1
     */

    ftr_PSRService.createCustomerAccountRequestType request;
    ftr_PSRService.PSRServicePort port;

    public ftr_SIPM6CreateCustomerAccountInterface() {

    }
    global override String getOrchestrationTaskName() {
        system.debug('Task Name returned:' + TaskName_SIPCheckM6Account);
        return TaskName_SIPCheckM6Account; 
        }
    global override Object createM6RequestType(String url, String path, Map < String, Object > input) {
        this.request = new ftr_PSRService.createCustomerAccountRequestType();
        system.Debug('this.input ' + input);
        Map < String, Object > createPSR = (Map < String, Object > ) input.get('createCustomerAccount');
        system.debug('createcustomerAcc '+createPSR);
        Map < String, Object > PSRRequest = (Map < String, Object > ) createPSR.get('createCustomerAccountRequest');
        system.debug('createPSR Object ' +createPSR );
         system.debug('createPSR PSRRequest' +PSRRequest );
        system.debug('createPSR.get(Account_Id__c) ' + PSRRequest.get('custAcctNbr') );
        String StreetName = String.valueOf(PSRRequest.get('StreetName'));
         String Pcode = String.valueOf(PSRRequest.get('PostalCodeV2'));
       // String  houseNumber = String.valueOf(PSRRequest.get('houseNumber')); 
         system.debug('@DKPcode '+Pcode );
       
        
      //  this.request = new ftr_PSRService.createCustomerAccountRequestType();
                this.request.customerAddress = new ftr_PSRService.addressType();
           system.debug('@DK1'+StreetName );
        this.request.customerAddress.houseNumber=StreetName.substring(0,StreetName.indexOf(' '));
         system.debug('@housenmbr'+this.request.customerAddress.houseNumber);
        this.request.customerAddress.StreetName=StreetName.substringAfter(' ');//'191002'; //vlocity_cmt__Premises__c.vlocity_cmt__StreetAddress__c
         system.debug('@street'+this.request.customerAddress.StreetName );
       // this.request.priloc.endUserLocation.address.streetName = prilocStreetName.substringAfter(' ').toUpperCase();  
        this.request.custAcctNbr = String.valueOf(PSRRequest.get('custAcctNbr')).toUpperCase();
        system.debug('@customer'+ this.request.custAcctNbr );
        this.request.companyName = String.valueOf(PSRRequest.get('CompanyName'));
         this.request.customerAddress.city = String.valueOf(PSRRequest.get('city'));
        this.request.customerAddress.state = String.valueOf(PSRRequest.get('State'));
            // system.debug('@state2'+this.request.customerAddress.state );
        this.request.customerAddress.postalCode = String.valueOf(PSRRequest.get('PostalCodeV2'));
          system.debug('@city'+this.request.customerAddress.city );
          system.debug('@state'+this.request.customerAddress.state);
           system.debug('@postalcode'+this.request.customerAddress.postalCode);
          system.debug('@company'+this.request.companyName );
        
        this.request.serviceCategory = String.valueOf(PSRRequest.get('serviceCategory'));
     // this.request.addressType.streetName = String.valueOf(PSRRequest.get('serviceCategory'));
          
		
        system.debug('@Annie'+this.request.custAcctNbr);
        system.debug('@Annie URL'+url);
        return (Object) this.request;
    }

        /**
     * This method is called from executeItem to create process response
     *
     * @param  url  base URL for the batch
     * @param  path path for the batch
     * @param  respType M6 ResponseType to process
     * @return         output object to be processed
     */
    global override Map < String, Object > processM6ResponseType(String url, String path, Object respType) {
        ftr_PSRService.createCustomerAccountResponseType response = (ftr_PSRService.createCustomerAccountResponseType) respType;
        Map < String, Object > RespMap = new Map < String, Object > ();
        system.debug('response: ' + response);

        system.debug('cusCode: ' + response.statusMessage.get(0).code);
        if (response.statusMessage.get(0).code != '0' && (!response.statusMessage.get(0).message.contains('Record Exists'))) {
				system.debug('record already exist');
                //get account from database:
                throw new ftr_M6SystemInterfaceException(response.statusMessage.get(0).message);  
        	}
			else{
				if(response.CreateCustomerAccountResult != null)
                {
					system.debug('#custAcctNbr:' + response.CreateCustomerAccountResult.custAcctNbr);
                	RespMap.put('custAcctNbr: ', String.valueOf(response.CreateCustomerAccountResult.custAcctNbr));
                }

			}
        return RespMap;
        //throw new ftr_M6SystemInterfaceException('Not implemented.');
    }
}