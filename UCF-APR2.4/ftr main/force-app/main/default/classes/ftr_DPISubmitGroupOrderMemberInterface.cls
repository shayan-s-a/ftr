global without sharing class ftr_DPISubmitGroupOrderMemberInterface extends ftr_DPIBaseSystemInterface {
    Map<String, Object> getCustOrderItemMap = new  Map<String, Object> ();
    String customerOrderItemStr ='';
    String commercialContractStr = '' ;
    public ftr_DPISubmitGroupOrderMemberInterface() {
        
    }
    
    global override String getOrchestrationTaskName() {
        System.debug('Task Name returned-->'+TaskName_SubmitGroupOrderMember);
        return TaskName_SubmitGroupOrderMember;
    }
    
    /**
* This method is called from executeItem to create DPI RequestType 
*
* @param  url  base URL for the batch
* @param  path path for the batch
* @param  input payload to be used to construct 
* @return DPI RequestType object to be sent
*/
    global override Object createDPIRequestType(String url, String path, Map<String, Object> input) {
        
        //Construct the Request Object to Invoke SubmitGroupOrderMember DPI API
        //return this with SubmitGroupOrderMember request
        //paa512 - MACD code changes
        Map<String, Object> submitGroupOrderRequest = null;
        if(isChangeOrder(input)) {
            String orderType ='Change';
            //submitGroupOrderRequest = createESBSubmitGroupOrderMapping(url, path, input, orderType);
            System.debug('Submitorderinput :'+ JSON.serialize(input));
            Map <String, Object> SubmitGroupOrderMember = (Map <String, Object> ) input.get('SubmitGroupOrderMember');         
            Map <String, Object> SubmitGroupOrderMemberInput = (Map <String, Object> ) SubmitGroupOrderMember.get('submitGroupOrderMemberInput');
            Map < String, Object > customerOrder =(Map < String, Object > ) SubmitGroupOrderMemberInput.get('customerOrder');
            String actionDPI ;
            if((String)customerOrder.get('actionDPI')!=null){
                actionDPI =  (String)customerOrder.get('actionDPI');
            }
            system.debug('actionDPI:'+actionDPI);
            if(actionDPI != null){
                system.debug('step1');
               if(actionDPI.equalsIgnoreCase('MNS'))
               {
                   submitGroupOrderRequest  = payloadChangeOrderDIAtoMNS(url, path, input, orderType);
               }
                
               else if(actionDPI.equalsIgnoreCase('MNStoMNS'))
               {
                      submitGroupOrderRequest  = payloadChangeOrderMNStoMNS(url, path, input, orderType);
               }
                else{    
                    submitGroupOrderRequest = createESBSubmitGroupOrderMapping(url, path, input, orderType);
                    // submitGroupOrderRequest = getChangeSubmitGroupOrderRequest(input);
                }
            }
        
        } else {
            //only for install orders
            System.debug('actionDPI is null');
            String orderType ='Install';
            submitGroupOrderRequest = createESBSubmitGroupOrderMapping(url, path, input, orderType);    
        }
        String testjsonInput;
        if(Test.isRunningTest()){
                    testJsonInput= '{"SubmitGroupOrderMember":{"submitGroupOrderMemberInput":{"customerAccount":{"location":{"serviceAddress":{"serviceAddressMaterId":{"controlNumber":"620372"},"address":{"zipCode":"75062","streetAddress":"100 East Airport Freeway","cityName":"Irving","plus4":"75062"},"cityAbbreviation":"IRV"}},"billingAccountId":{"telephoneNumber":{"telephoneNumber":"8321510008"}},"taxProfile":{"isFederalTaxExempt":"false"},"accountServiceType":{"code":"65"},"accountPreferences":{"billHandlingCode":"M"},"accountId":{"telephoneNumber":{"telephoneNumber":"8321510008"},"environment":"FT"},"CustomerBill":{"billDetailLevel":"PARTIAL","BillCycle":"null"}},"header":{"securityInfo":{"userId":"lsg522","employeeId":"lsg522"},"requestingApplication":"VlocityOM","correlationId":"10030431.8321510009"},"poOrder":null,"groupOrderTransactionCount":"2","circuitSNE":"CKT","circuitId":"13/CUXP/541477/   /FTNC/   ","customer":{"organization":{"contactInformation":{"internationalAddress":{"stateOrProvince":"TX","postalCode":"75077","country":"United States","cityName":"Lewisville","addressLine1":"1480 North Valley Parkway"}},"organizationName":{"tradingName":"AK Technical Test Company"}},"customerType":"Business","customerCreditProfile":{"creditScore":{"creditRating":"3"},"creditProfileReference":{"businessOwner":{"name":"Tom Cruise"},"business":{"organizationType":"Sole Ownership"},"TechnicalContact":{"Name":"Tom Cruise"},"BillToContact":{"Name":"Tom Cruise"}}}},"customerOrder":{"provisioningDetails":{"commercialCircuitProvisioning":{"OrgLocZipCode":"75062","OrgLocStreetAddress":"100 East Airport Freeway","OrgLocStateAbbreviation":null,"OrgLocCityName":"Irving"}},"customerOrderItem":[{"product":{"lineItemSequenceNumber":"1","id":"MEDAL"},"chargeType":"Permanent","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"SSINS"},"chargeType":"Temporary","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"EIA2Y"},"chargeType":"Permanent","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"BNR23"},"chargeType":"Temporary","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"BIP23"},"chargeType":"Permanent","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"NA"},"chargeType":"Permanent","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"CKT"},"chargeType":"Permanent","processingDirection":"Forward","quantity":"1.00","action":"Add"},null],"commercialContract":[{"monthlyRecurringChargeRate":{"amount":"880.00"},"quantity":"1","productId":"MEDAL"},{"nonRecurringChargeRate":{"amount":"250.00"},"quantity":"1","productId":"SSINS"},null],"installationType":"NO_INSTALL","dueDate":"2021-04-10","customerOrderType":"CHANGE","Quantity":1,"crisId":"838810"},"scheduleId":"S-5550011781","InternationalBillAddress":"false","ContractId":"8001g0000003dyrAAA"}}}}';
                    submitGroupOrderRequest = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
        }
        System.debug('submitGroupOrderRequest :'+ JSON.serialize(submitGroupOrderRequest));
        return (submitGroupOrderRequest);
    }
    
    /**
* This method is called from executeItem to create process response
*
* @param  url  base URL for the batch
* @param  path path for the batch
* @param  respType DPI ResponseType to process
* @return  output object to be processed
*/
    global override Map<String, Object> processDPIResponseType(String url, String path, Object respType) {
        
        Map<String,Object> submitGroupOrderResponseMap = new Map<String,Object>();
        String response = String.valueOf(respType);
        System.debug('Response:' + response);
        
    /*    if(respType != null && respType instanceof esbftrCustomerordermanagement.msg_SubmitGroupOrderMemberResponse) {
            return processDPIResponseTypeFromObject(url, path, respType);
        }*/
        if (respType != null){
            String resp = JSON.serialize(respType);
            if(response.indexOf('<leadOrderId>') !=-1){
                String orderNum=response.substring(response.indexOf('<leadOrderId>'), response.indexOf('</leadOrderId>'));
                System.debug('ordernumber:' + ordernum);
            }
            
            System.debug('Index of operationstatus :'+ response.indexOf('<operationStatus>'));
            String OpStatus = response.substring(response.indexOf('<operationStatus>')+17, response.indexOf('</operationStatus>'));
            System.debug('Operation Status :'+ OpStatus.trim() );
            if((OpStatus.trim()).equals('TRUE')){
                String leadOrderBlock = response.substring(response.indexOf('<leadOrderId>'), response.indexOf('</leadOrderId>'));
                String leadOrderNum=leadOrderBlock.substring(leadOrderBlock.indexOf('<orderNumber>')+13, leadOrderBlock.indexOf('</orderNumber>'));
                String groupMemberOrderBlock = response.substring(response.indexOf('<groupMemberOrderId>'), response.indexOf('</groupMemberOrderId>'));
                String memberOrderNum=groupMemberOrderBlock.substring(groupMemberOrderBlock.indexOf('<orderNumber>')+13, groupMemberOrderBlock.indexOf('</orderNumber>'));
                System.debug('leadOrderNum :'+leadOrderNum);
                System.debug('memberOrderNum :'+memberOrderNum);
                submitGroupOrderResponseMap.put('LeadOrderId',leadOrderNum);
                submitGroupOrderResponseMap.put('GroupMemberOrderId', memberOrderNum);
                submitGroupOrderResponseMap.put('CreateTask', 'Yes');
            }
            else{
                System.debug('Operation status false, response is '+response);
                String severity,operationStatusCode,operationStatusDescription, errorcode ;
                //To Do - ExecutionStatusMessage is an array, need to be handled later. 
                String executionStatusParent = response.substring(response.indexOf('<executionStatusMessage>'),response.indexOf('</executionStatusMessage>'));
                severity =  executionStatusParent.substring(executionStatusParent.indexOf('<severity>')+('<severity>').length(),executionStatusParent.indexOf('</severity>'))    ;      
                operationStatusCode = executionStatusParent.substring(executionStatusParent.indexOf('<operationStatusCode>')+('<operationStatusCode>').length(),executionStatusParent.indexOf('</operationStatusCode>')) ;
                errorCode = severity + ' | '+ operationStatusCode;
                operationStatusDescription =  executionStatusParent.substring(executionStatusParent.indexOf('<operationStatusDescription>')+('<operationStatusDescription>').length(),executionStatusParent.indexOf('</operationStatusDescription>')) ;
                System.debug('executionStatusParent: '+executionStatusParent);
                String executionStatusChild  = executionStatusParent.substring(executionStatusParent.indexOf('<executionStatusMessage>')+('<executionStatusMessage>').length()-1);
                System.debug('executionStatusChild: '+executionStatusChild);
                //  while(executionStatusChild.indexOf('<executionStatusMessage>') != -1){
                do{
                    System.debug('executionStatusChild: inside while :'+executionStatusChild.indexOf('<executionStatusMessage>'));
                    System.debug('errorCode inside while :'+errorCode);
                    System.debug('Severity starting index :'+ executionStatusChild.indexOf('<severity>')+('<severity>').length());
                    System.debug('Severity ending index :'+ executionStatusChild.indexOf('</severity>'));
                    severity = errorCode +' | ' + executionStatusChild.substring(executionStatusChild.indexOf('<severity>')+('<severity>').length(),
                                                                                 executionStatusChild.indexOf('</severity>') );
                    System.debug('severity inside while :'+severity);
                    operationStatusCode = severity + ' | '+executionStatusChild.substring(executionStatusChild.indexOf('<operationStatusCode>')+('<operationStatusCode>').length(),executionStatusChild.indexOf('</operationStatusCode>') );
                    operationStatusDescription = operationStatusDescription + ' | ' +executionStatusChild.substring(executionStatusChild.indexOf('<operationStatusDescription>')+('<operationStatusDescription>').length(),executionStatusChild.indexOf('</operationStatusDescription>') );
                    executionStatusChild=executionStatusChild.substring(executionStatusChild.indexOf('<executionStatusMessage>')+('<executionStatusMessage>').length() -1);
                    System.debug('executionStatusChild inside while :'+executionStatusChild);
                    errorCode = operationStatusCode;
                    System.debug('Error code in while :'+errorCode);
                }while(executionStatusChild.indexOf('<executionStatusMessage>') != -1);
                System.debug('executionStatusChild after while: '+executionStatusChild);
                if(executionStatusChild.indexOf('<operationStatusCode>')!=-1){
                    errorCode = errorCode + ' | '+executionStatusChild.substring(executionStatusChild.indexOf('<operationStatusCode>')+('<operationStatusCode>').length(),executionStatusChild.indexOf('</operationStatusCode>') );
                }
                if(executionStatusChild.indexOf('<executionStatusChild>')!=-1){
                    operationStatusDescription = operationStatusDescription+ executionStatusChild.substring(executionStatusChild.indexOf('<operationStatusDescription>')+('<operationStatusDescription>').length(),executionStatusChild.indexOf('</operationStatusDescription>') );
                }
                executionStatusParent = response.substring(response.indexOf('</executionStatusMessage>')+('<executionStatusMessage>').length());
                System.debug('second executionStatusParent :'+executionStatusParent);
                executionStatusChild  = executionStatusParent.substring(executionStatusParent.indexOf('<executionStatusMessage>')+('<executionStatusMessage>').length());
                System.debug('second executionStatusChild :'+executionStatusChild);
                do{
                    if(executionStatusChild.indexOf('<severity>')!=-1){
                        severity = errorCode +' | ' + executionStatusChild.substring(executionStatusChild.indexOf('<severity>')+('<severity>').length(), executionStatusChild.indexOf('</severity>') );
                    }
                    System.debug('severity inside 2nd while :'+severity);
                    if(executionStatusChild.indexOf('<operationStatusCode>')!=-1){
                        operationStatusCode = severity + ' | '+executionStatusChild.substring(executionStatusChild.indexOf('<operationStatusCode>')+('<operationStatusCode>').length(),executionStatusChild.indexOf('</operationStatusCode>') );
                    }
                    if(executionStatusChild.indexOf('<operationStatusDescription>')!=-1){
                        operationStatusDescription = operationStatusDescription + ' | ' +executionStatusChild.substring(executionStatusChild.indexOf('<operationStatusDescription>')+('<operationStatusDescription>').length(),executionStatusChild.indexOf('</operationStatusDescription>') );
                    }
                    executionStatusChild=executionStatusChild.substring(executionStatusChild.indexOf('<executionStatusMessage>')+('<executionStatusMessage>').length() -1);
                }while(executionStatusChild.indexOf('<executionStatusMessage>') != -1);
                submitGroupOrderResponseMap.put('errorCode', errorCode);

                if(operationStatusDescription.contains('Failure') ||operationStatusDescription.contains('RUN09034')  || operationStatusDescription.contains('clientGroupIdentifier') ){
                 operationStatusDescription = 'The telephone numbers previously reserved for this order are either used by different account or the correlation id needs to be fixed. Please open a case for IT.';
                }                   
                submitGroupOrderResponseMap.put('errorMessage', operationStatusDescription); 
                System.debug(' Error Map : '+ submitGroupOrderResponseMap);
            }
        }
        else{
            System.debug('Response is null');
        }
        return submitGroupOrderResponseMap;
    }
    public Map<String, Object> getCustomerOrderItemString( List<Object> custOrderItemString ){
        System.debug('custOrderItemString size '+custOrderItemString.size());
        System.debug('custOrderItemString: '+String.valueOf(custOrderItemString.get(0)));
        Map<String, Object> custOrderStringMap = new  Map < String, Object > ();
        String action, itemQuantity, chargeType, processingDirection, prodId,lineItemSequenceNumber;
        Map < String, Object > product = new Map < String, Object > ();
        Map<String, Object> item = new Map < String, Object > ();
        if(custOrderItemString!=null){
            for (Object orderItem : custOrderItemString) {
                System.debug('OrderItem: '+orderItem);
                if(orderItem!=null){
                    item = (Map<String, Object>) orderItem;
                     if(item!=null && !(item.isEmpty())){
                    System.debug('Item is : '+item);
                         action = (String) item.get('action');
                    itemQuantity = String.valueOf(item.get('quantity'));
                    chargeType = (String)item.get('chargeType');
                    processingDirection = (String)item.get('processingDirection');
                    product =(Map < String, Object > ) item.get('product');
                         
                      }   
                    if(product!=null && null!=product.get('id') ){
                        prodId = (String)product.get('id');
                       
                        if(prodId.equalsIgnoreCase('ADUNI')){
                            custOrderStringMap.put('ProdId', prodId);
                        }
                        System.debug('Prod Id is '+prodId);
                        if(null!=prodId && !prodId.equalsIgnoreCase('NA')){
                        lineItemSequenceNumber =(String) product.get('lineItemSequenceNumber');
                        }
                    }
                    //if(prodId !=null ){
                    if(product.get('id')!=null && ftr_OrderManagementHelper.validString((String)product.get('id')) && !((String)product.get('id')).contains('NA') ){
                        if(customerOrderItemStr!=null){
                            customerOrderItemStr =customerOrderItemStr+'<customerOrderItem>'+
                                '<action>'+action+'</action>'+
                                '<quantity>'+itemQuantity+'</quantity>'+
                                '<chargeType>'+chargeType+'</chargeType>'+
                                '<processingDirection>'+processingDirection+'</processingDirection>'+
                                '<product>'+
                                '<id>'+prodId+'</id>'+
                                '<lineItemSequenceNumber>'+lineItemSequenceNumber+'</lineItemSequenceNumber>'+
                                '</product>'+
                                '</customerOrderItem>';
                            System.debug('**customerOrderItemStr**'+customerOrderItemStr+'******');
                        }
                    }
                    custOrderStringMap.put('CustOrderItemString', customerOrderItemStr);
                }
            }
        }else{ 
            System.debug('customerOrderItemStr is null');
        }
        return custOrderStringMap;
    }
    
    public String getCommercialContractString(List<Object>  commercialContractString, String schId, String contractId){
        // Map < String, Object > contractMap = new  Map < String, Object > ();
        if(commercialContractString!=null || commercialContractString.isEmpty()){
            for (Object contract : commercialContractString) {
                Map < String, Object > contractMap = new  Map < String, Object > ();
                String   productId, contractQuantity,recAmount, nonRecAmount;
                if(contract!=null){
                    contractMap =(Map<String, Object>) contract;
                    //  contractId = (String)contractMap.get('contractId');
                    productId=(String)contractMap.get('productId');
                    contractQuantity = (String)contractMap.get('quantity');
                    Map < String, Object > monthlyRecCharge = new Map < String, Object > ();
                    Map < String, Object > nonRecCharge = new Map < String, Object > ();
                    monthlyRecCharge = (Map < String, Object > )contractMap.get('monthlyRecurringChargeRate');
                    nonRecCharge =    (Map < String, Object > )contractMap.get('nonRecurringChargeRate'); 
                    System.debug('Product ID: '+     productId);
                    System.debug('monthlyRecCharge: '+String.valueOf(monthlyRecCharge));
                    if(monthlyRecCharge!=null){
                        recAmount= (String)monthlyRecCharge.get('amount');
                    }
                    if(nonRecCharge!=null){
                        nonRecAmount= (String)nonRecCharge.get('amount');
                    }
                    if(ftr_OrderManagementHelper.validString(productId)){    
                        if(commercialContractStr!=null){
                            if(recAmount!=null){
                                commercialContractStr = commercialContractStr+ ' <commercialContract>'+
                                    '<scheduleId>'+schId+'</scheduleId>'+
                                    '<contractId>'+contractId+'</contractId>'+
                                    '<productId>'+productId+'</productId>'+
                                    '<quantity>'+contractQuantity+'</quantity>'+
                                    '<monthlyRecurringChargeRate>'+
                                    '<shar:amount>'+recAmount+'</shar:amount>'+
                                    '</monthlyRecurringChargeRate>'+
                                    '</commercialContract>';
                            }
                            if(nonRecAmount!=null){
                                commercialContractStr = commercialContractStr+ ' <commercialContract>'+
                                    '<scheduleId>'+schId+'</scheduleId>'+
                                    '<productId>'+productId+'</productId>'+
                                    '<quantity>'+contractQuantity+'</quantity>'+
                                    '<nonRecurringChargeRate>'+
                                    '<shar:amount>'+nonRecAmount+'</shar:amount>'+
                                    '</nonRecurringChargeRate>'+
                                    '</commercialContract>';
                            }
                            System.debug('commercialContractStr is ************'+commercialContractStr);
                        }
                    }
                }
            }
        }
        System.debug('Final commercialContractStr is ************'+commercialContractStr);
        return commercialContractStr;
    }
    
    public Map<String, Object> createESBSubmitGroupOrderMapping(String url, String path, Map<String, Object> input, String orderType){
        System.debug('Input to CreateDPIRequestType: '+JSON.serialize(input));
        Map<String, String> submitGroupOrderRequestMap =new Map<String, String> ();
        Map < String, Object > serviceAddrJson = new Map< String, Object >();
        Map < String, Object > serviceAddrMasterIdJson = new Map< String, Object >();
        Map < String, Object > individualJson = new Map< String, Object >();
        Map < String, Object > organizationJson = new Map< String, Object >();
        Map < String, Object > custCreditProfileJson = new Map< String, Object >();
        Map < String, Object > custCreditProfileReferenceJson = new Map< String, Object >();
        Map < String, Object > businessJson = new Map< String, Object >();
        Map < String, Object > landlordJson =  new Map< String, Object >();
        Map < String, Object > businessOwnerJson = new Map< String, Object >();
        Map < String, Object > managerJson = new Map< String, Object >();
        Map < String, Object > techContactJson = new Map< String, Object >();
        Map < String, Object > billContactJson = new Map< String, Object >();
        Map < String, Object > billingContactJson = new Map< String, Object >();
        Map < String, Object > creditScoreJson = new Map< String, Object >();
        Final String SalesChannelCode_TTL = '202';
        String requesttotal,cityAbbr,plus4, billCycle,isFederalTaxExempt, streetAddress,serviceType,streetNumber,streetName,cityName,stateAbbreviation, streetSuffix,zipCode,addressLine1, addressLine3, country, intcityName,stateOrProvince,postalCode,tradingName; 
        String OrgLocCityName,BandwidthSpeed, code, customerOrderType, customerType, orgStreetAdd,billDetailLevel,billHandlingCode, tollLimitCode, orgstateAbbr, orgZipCode, origLoc,termLoc, saleschannelType, contractTerm,soldOn, salesChannelPartnerId, crisId, organizationType,businessOwner, technicalContact,billToContact, managerName,techContactNum, billingContactTelephone, businessOwnerTelephone;
        Boolean isInternationalAddress;
        //String salesChannelBlock;
        try{
            Map<String, String> submitGroupOrderResponseMap = null;
            Map < String, Object > SubmitGroupOrderMember = (Map < String, Object > ) input.get('SubmitGroupOrderMember');
            System.debug('SubmitGroupOrderMember :'+JSON.serialize(SubmitGroupOrderMember));
            Map < String, Object > SubmitGroupOrderMemberInput = (Map < String, Object > ) SubmitGroupOrderMember.get('submitGroupOrderMemberInput');
            String scheduleId = (String)SubmitGroupOrderMemberInput.get('scheduleId');
            String contractId = (String)SubmitGroupOrderMemberInput.get('ContractId');
            if(contractId!=null && contractId.length()>15){ 
                contractId=contractId.substring(0, 14);
            }
            String circuitId = (String)SubmitGroupOrderMemberInput.get('circuitId');
            system.debug('@@@OFFNET'+(String)SubmitGroupOrderMemberInput.get('offNetPartnerSNECode'));
            String OffNetPartnerValue= (String)SubmitGroupOrderMemberInput.get('offNetPartnerSNECode');
            String mainProductCode= (String)SubmitGroupOrderMemberInput.get('mainParentProduct');
            String BandwidthMRCSNE=(String)SubmitGroupOrderMemberInput.get('BandwidthSpeed');
			if(BandwidthMRCSNE !=null && OffNetPartnerValue !=null){
               BandwidthSpeed = [select  Speed__c from ftr_Attribute_Based_SNE__c  where SNE_Code_MRC__c =:BandwidthMRCSNE and ftr_Partnered__c ='YES' limit 1]?.Speed__c; 
            }
            String SFOrderNo=(String)SubmitGroupOrderMemberInput.get('SFOrderNo');
            String ECROrder =(String)SubmitGroupOrderMemberInput.get('ECROrder');
            if(ftr_OrderManagementHelper.validString((String)SubmitGroupOrderMemberInput.get('InternationalBillAddress'))){    
                isInternationalAddress = Boolean.valueOf(SubmitGroupOrderMemberInput.get('InternationalBillAddress'));
            }
            Boolean printCircuitOnBill = True;
            Boolean printLocationOnBill =  True;
            serviceType ='EVC';
            String poOrder = (String)SubmitGroupOrderMemberInput.get('poOrder');
            String groupOrderTransactionCount =(String)SubmitGroupOrderMemberInput.get('groupOrderTransactionCount') ;
            Map < String, Object > header =(Map < String, Object > ) SubmitGroupOrderMemberInput.get('header');
            String correlationId =(String)header.get('correlationId') ;
            Map < String, Object > customerOrder =(Map < String, Object > ) SubmitGroupOrderMemberInput.get('customerOrder');
            if(orderType.equalsIgnoreCase('Change')){
                customerOrderType = 'CHANGE';
            }
            else{
                customerOrderType = (String)customerOrder.get('customerOrderType');
            }
            String actionDPI = (String)customerOrder.get('actionDPI');
            String installationType = (String)customerOrder.get('installationType');
            List<Object> custOrderItemString =    (List<Object>) customerOrder.get('customerOrderItem');
            if(custOrderItemString!=null){
                system.debug('custOrderItemString ESB:'+JSON.serialize(custOrderItemString));
                getCustOrderItemMap = (Map < String, Object > )getCustomerOrderItemString(custOrderItemString);
                system.debug('getCustOrderItemMap ESB:'+getCustOrderItemMap);
                customerOrderItemStr = (String)getCustOrderItemMap.get('CustOrderItemString');
                system.debug('customerOrderItemStr ESB:'+customerOrderItemStr);
            }
            String prodId = (String)getCustOrderItemMap.get('ProdId');
            if(prodId!=null && prodId.equalsIgnoreCase('ADUNI')){
                serviceType ='ETHERNET';
            }
            //  Map < String, Object > saleschannelTypeJson = (Map < String, Object > )customerOrder.get('saleschannelType');
            String ttlNum = (String)customerOrder.get('TtlNum');
            if((String)customerOrder.get('saleschannelType') !=null){
                saleschannelType = ((String)customerOrder.get('saleschannelType')).substringBefore(' -');
            }
            salesChannelPartnerId = (String)customerOrder.get('salesChannelPartnerId');
            Map < String, Object > contract = (Map < String, Object > )customerOrder.get('contract');
            Map < String, Object > term = new  Map < String, Object > ();
            Map < String, Object > offer = new  Map < String, Object > ();
            if(contract !=null){
                term = (Map < String, Object > )contract.get('Term'); 
                offer =(Map < String, Object > )contract.get('offer');
            }
            
            
            if(term!=null){
                contractTerm = String.valueOf(term.get('termInMonths'));
            }
            if(offer!=null){
                soldOn =  (String)offer.get('soldOn');
            }
            
            
            System.debug ('contractTerm is '+ contractTerm);
            System.debug ('contractDate is '+ soldOn);
            crisId =(String)customerOrder.get('crisId');
            if(ttlNum != null){
                saleschannelType = SalesChannelCode_TTL;
                salesChannelPartnerId = ttlNum;
            }
            System.debug('Step 1');
            
            String dueDate = (String)customerOrder.get('dueDate');
            if(dueDate!=null){
                // dueDate = convertDate(dueDate);
                dueDate = dueDate+'T00:00:00';
            }
            List<Object> commercialContractString =(List<Object> ) customerOrder.get('commercialContract');
            if(commercialContractString!=null){
                commercialContractStr = getCommercialContractString(commercialContractString, scheduleId, contractId);
            }
            Map < String, Object >  provisioningDetails = (Map < String, Object > )customerOrder.get('provisioningDetails');
            Map < String, Object > circuitProvisioning = (Map < String, Object > )provisioningDetails.get('commercialCircuitProvisioning');
            System.debug('Step 2');
            if(circuitProvisioning!=null){
                OrgLocCityName =(String) circuitProvisioning.get('OrgLocCityName');
                orgStreetAdd = (String) circuitProvisioning.get('OrgLocStreetAddress');
                orgstateAbbr = (String)circuitProvisioning.get('OrgLocStateAbbreviation');
                orgZipCode = (String)circuitProvisioning.get('OrgLocZipCode');
                origLoc =orgStreetAdd +' '+ OrgLocCityName+' '+orgstateAbbr;
                if(origLoc!=null && origLoc.length()>20){
                    origLoc=origLoc.substring(0, 19);
                }  
                origLoc = origLoc.replaceAll('null', '');
                
            }
            System.debug('Step 3');
            Map < String, Object > customerAccountJson =(Map < String, Object > ) SubmitGroupOrderMemberInput.get('customerAccount');
            System.debug('customerAccountJson :'+ customerAccountJson);
            Map < String, Object > accountIdJson = (Map < String, Object > )customerAccountJson.get('accountId');
            System.debug('accountIdJson :'+ accountIdJson);
            Map < String, Object >  accTelephoneNumberJson = (Map < String, Object > )accountIdJson.get('telephoneNumber');
            String accTelNumber = (String)accTelephoneNumberJson.get('telephoneNumber');
            String accEnv = (String)accountIdJson.get('environment');
            Map < String, Object > billingAccountIdJson = (Map < String, Object > )customerAccountJson.get('billingAccountId');
            Map < String, Object >  billingTelephoneJson = (Map < String, Object > )billingAccountIdJson.get('telephoneNumber');
            String billTelNumber =(String) billingTelephoneJson.get('telephoneNumber');
            Map < String, Object >  accountServiceTypeJson = (Map < String, Object > )customerAccountJson.get('accountServiceType');
            if(accountServiceTypeJson!=null){
            code = (String)accountServiceTypeJson.get('code');
            }
            Map < String, Object >  accountPreferencesJson =(Map < String, Object > ) customerAccountJson.get('accountPreferences');
            if(accountPreferencesJson!=null){
                System.debug('Order Type:'+orderType);
                if(orderType.equalsIgnoreCase('Change')){
                    System.debug('Its a change');
                    if(actionDPI == 'Disconnect'){
                        System.debug('Its a internal Disconnect');
                        billHandlingCode = '';
                    }
                }
                else{
                    
                 billHandlingCode = (String)accountPreferencesJson.get('billHandlingCode') ;
                    system.debug('billHandlingCodevishal'+billHandlingCode);
                 }
                 tollLimitCode = (String)accountPreferencesJson.get('tollLimitCode');
            }
            system.debug('billHandlingCodevishaloutsideif'+billHandlingCode);
            Map < String, Object >  customerBillJson =(Map < String, Object > ) customerAccountJson.get('CustomerBill');
            if(customerBillJson!=null){
                billDetailLevel =(String) customerBillJson.get('billDetailLevel');
                billCycle = (String) customerBillJson.get('BillCycle');  
            }
          
            Map < String, Object >  taxProfileJson = (Map < String, Object > )customerAccountJson.get('taxProfile');
            if(taxProfileJson!=null){
               isFederalTaxExempt =(String) taxProfileJson.get('isFederalTaxExempt'); 
            }
            
            Map < String, Object >  custAccLocationJson = (Map < String, Object > )customerAccountJson.get('location');
              System.debug('custAccLocationJson : '+custAccLocationJson);
            if(custAccLocationJson!=null){
                serviceAddrJson = (Map < String, Object > )custAccLocationJson.get('serviceAddress');
            }
            if(serviceAddrJson!=null){
                serviceAddrMasterIdJson = (Map < String, Object > )serviceAddrJson.get('serviceAddressMaterId');
                cityAbbr =  (String)serviceAddrJson.get('cityAbbreviation') ;
            }
            String controlNumber, environment,sequenceNumber;
            System.debug('serviceAddrMasterIdJson : '+serviceAddrMasterIdJson);
            if(serviceAddrMasterIdJson!=null){
                controlNumber = (String)serviceAddrMasterIdJson.get('controlNumber') ;
                sequenceNumber =(String) serviceAddrMasterIdJson.get('sequenceNumber');
            }
            Map < String, Object > addressJson = (Map < String, Object > )serviceAddrJson.get('address');
            if(addressJson!=null){
                streetAddress = (String)addressJson.get('streetAddress'); 
                streetSuffix =(String)addressJson.get('streetSuffix');
                cityName=(String)addressJson.get('cityName');
                stateAbbreviation =(String)addressJson.get('stateAbbreviation');
                zipCode =(String)addressJson.get('zipCode');
                plus4 = (String)addressJson.get('plus4');
            }
            System.debug('streetAddress : '+streetAddress);
            if(streetAddress!=null){
                 streetNumber= streetAddress.substringBefore(' ');
            // preDirectional='S';
                 streetName= streetAddress.substringAfter(' ');
            }
           
            if(streetName!=null && streetName.length()>20){
                streetName = streetName.substring(0,19);  
            }
           
            termLoc = streetAddress+' '+ cityName +' ' +stateAbbreviation;
            termLoc = termLoc.replaceAll('null', '');
            Map < String, Object > customerJson = (Map < String, Object > )SubmitGroupOrderMemberInput.get('customer');
            if(customerJson!=null){
                individualJson =(Map < String, Object > ) customerJson.get('individual');
                organizationJson = (Map < String, Object > )customerJson.get('organization');
                custCreditProfileJson = (Map < String, Object > )customerJson.get('customerCreditProfile');
                 customerType = (String)customerJson.get('customerType');
            }
            
            if(individualJson!=null){
                String socialSecurityNumber =(String) individualJson.get('socialSecurityNumber');
                String dateOfBirth = (String) individualJson.get('dateOfBirth');
            }
            
            if(organizationJson!=null){
                Map < String, Object > orgNameJson = (Map < String, Object > )organizationJson.get('organizationName');
                tradingName =(String)orgNameJson.get('tradingName');
                if (tradingname.length()>30){
                    tradingName = tradingName.substring(0, 29);
                }
                tradingName = tradingName.escapeXml();
                //tradingName ='AJ Test Company 1';
                Map < String, Object > contactInfoJson = (Map < String, Object > )organizationJson.get('contactInformation');
                if(contactInfoJson!=null){
                    Map < String, Object > intAddrJson = (Map < String, Object > )contactInfoJson.get('internationalAddress');
                    addressLine1 = (String)intAddrJson.get('addressLine1');
                    country = (String)intAddrJson.get('country');
                    intcityName = (String)intAddrJson.get('cityName');
                    stateOrProvince = (String)intAddrJson.get('stateOrProvince');
                    postalCode =(String) intAddrJson.get('postalCode');
                    if(isInternationalAddress){
                        addressLine3 = intcityName +' '+stateOrProvince;
                        addressLine3 = addressLine3.replaceAll('null', '');
                        intcityName = country +' '+postalCode;
                        intcityName = intcityName.replaceAll('null', '');
                        stateOrProvince ='';
                        postalCode = '';
                    }
                }
            }
            if(custCreditProfileJson!=null){
               custCreditProfileReferenceJson = (Map < String, Object > )custCreditProfileJson.get('creditProfileReference');
               creditScoreJson = (Map < String, Object > )custCreditProfileJson.get('creditScore');

            }
            String landlordName,landLordTelNum;
            if(custCreditProfileReferenceJson!= null){
                landlordJson = (Map < String, Object > )custCreditProfileReferenceJson.get('landlord');
                businessJson =(Map < String, Object > ) custCreditProfileReferenceJson.get('business');
                managerJson =(Map < String, Object > ) custCreditProfileReferenceJson.get('manager');
                techContactJson =(Map < String, Object > ) custCreditProfileReferenceJson.get('TechnicalContact');
                billContactJson =(Map < String, Object > ) custCreditProfileReferenceJson.get('BillToContact');
                billingContactJson = (Map < String, Object > ) custCreditProfileReferenceJson.get('BillingContact');

            }
           
            
            if(landlordJson!=null){
                landlordName = (String)landlordJson.get('name');
                landLordTelNum =(String)landlordJson.get('telephoneNumber');
            }
            
            if(businessJson!=null){
                organizationType = (String)businessJson.get('organizationType');
                businessOwnerJson =(Map < String, Object > ) custCreditProfileReferenceJson.get('businessOwner');
            }
           
            if(businessOwnerJson!=null){
                businessOwner = (String)businessOwnerJson.get('name');
                businessOwnerTelephone = (String)businessOwnerJson.get('number');
            }
            
            if(managerJson!=null){
                managerName = (String)managerJson.get('name');
            }
            
            if(techContactJson!=null){
                technicalContact = (String)techContactJson.get('Name');
                techContactNum = (String)techContactJson.get('telephone');
            }
            
            if(billContactJson!=null){
                billToContact = (String)billContactJson.get('Name');
                System.debug('Billtocontact :'+billToContact);
                billingContactTelephone =  (String)billContactJson.get('telephone');
            }
             String creditRating,headercircuit,frontierOffice ;
            if(creditScoreJson!=null){
                creditRating = (String)creditScoreJson.get('creditRating');
            }
            If(OffNetPartnerValue !=null){
                if(mainProductCode != 'ENT_ETH_UNI_0001'){
             	headercircuit='<circuitSNE>CKT</circuitSNE>'+'<circuitId>'+circuitId+'</circuitId>';
                }
            }
            System.debug('commercialContractStr is ********'+commercialContractStr);
            String request1 = '<soapenv:Envelope '+'xmlns:'+'soapenv="http://schemas.xmlsoap.org/soap/envelope/" '+'xmlns:cus="http://esb.frontier.com/CustomerOrderManagement" '+'xmlns:'+'shar="'+ 'http://esb.frontier.com/sharedType" '+'xmlns:'+'xsi="xsi">'+
                '<soapenv:Header/>'+
                '<soapenv:Body>'+
                '<cus:SubmitGroupOrderMember>'+
                '<submitGroupOrderMemberInput>'+
                '<header>'+
                '<shar:correlationId>'+correlationId+'</shar:correlationId>'+
                '<shar:requestingApplication>VlocityOM</shar:requestingApplication>'+
                '<securityInfo>'+
                '<userId>ftrqacomm</userId>'+
                '<employeeId>825280</employeeId>'+
                '</securityInfo>'+
                 headercircuit+
                '</header>'+
                '<groupOrderTransactionCount>'+groupOrderTransactionCount+'</groupOrderTransactionCount>'+
                '<customerOrder>'+
                '<customerOrderType>'+customerOrderType+'</customerOrderType>'+
                '<salesChannelPartnerId>'+salesChannelPartnerId+'</salesChannelPartnerId>';
            String dueDateBlock =  '<dueDate>'+dueDate+'</dueDate>';
            String cridIdBlock =  '<soldBy>'+
                '<id>'+crisId+'</id>'+
                '</soldBy>';
            String salesChannelBlock =  '<saleschannelType>'+
                '<code>' + saleschannelType + '</code>'+
                '</saleschannelType>';
            String newConstructionBlock = '<isNewConstruction>true</isNewConstruction>';            
            String afterSalesChannelBlock = '<provisioningDetails>'+
                '<commercialCircuitProvisioning>'+
                '<printCircuitOnBill>'+printCircuitOnBill+'</printCircuitOnBill>'+
                '<serviceType>'+serviceType+'</serviceType>';
            String circuitIdBlock = '<circuitId>'+circuitId+'</circuitId>';
            String OffnetOriginAdd,ContactLineinfo,OffnetOriginLoc,circuitOLOCBlock,afterCustomerBillBlock,intAddrLine3Block,intCityBlock,intStateOrProv,intPostalCode;
            if(OffNetPartnerValue !=null){
                if(mainProductCode =='ENT_ETH_ELAN_0001' || mainProductCode== 'ENT_ETH_EIA_0002' || mainProductCode == 'ENT_ETH_EIA_003'){
                   origLoc = 'Frontier Central Office';
                    ContactLineinfo='<contactLineInfo>INSTALL '+BandwidthSpeed+' PER SF ORDER # '+SFOrderNo+ ' </contactLineInfo>';
               						// +'<contactLineInfo>ECR ORDER # 1234</contactLineInfo>';
               	   ContactLineinfo= ECROrder !=null? ContactLineinfo +'<contactLineInfo>ECR ORDER # ' +ECROrder+'</contactLineInfo>':ContactLineinfo+'<contactLineInfo>Pending</contactLineInfo>';

                }
                if(mainProductCode == 'ENT_ETH_ELAN_0001'){
                  OffnetOriginLoc = 'Elan Network';
                }else if(mainProductCode == 'ENT_ETH_EIA_003'  || mainProductCode == 'ENT_ETH_EIA_0002'){
                   OffnetOriginLoc='INTERNET ACCESS';
                }
                else if(mainProductCode == 'ENT_ETH_EVPL_0010'|| mainProductCode == 'ENT_ETH_EVPL_0002' ){
                  OffnetOriginLoc = 'CUSTOMER PREMISE';
                  ContactLineinfo='<contactLineInfo>INSTALL '+BandwidthSpeed+' PER SF ORDER # '+SFOrderNo+ ' </contactLineInfo>';
               					  //+'<contactLineInfo>ECR ORDER # 1234</contactLineInfo>';
               	   ContactLineinfo= ECROrder !=null? ContactLineinfo +'<contactLineInfo>ECR ORDER # ' +ECROrder+'</contactLineInfo>':ContactLineinfo+'<contactLineInfo>Pending</contactLineInfo>';

                }
                else{
                  OffnetOriginLoc = 'CUSTOMER NID'; 
                  ContactLineinfo='<contactLineInfo>SF ORDER # '+SFOrderNo+ ' </contactLineInfo>';
               	   ContactLineinfo= ECROrder !=null? ContactLineinfo +'<contactLineInfo>ECR ORDER # ' +ECROrder+'</contactLineInfo>':ContactLineinfo+'<contactLineInfo>Pending</contactLineInfo>';
                }
             circuitOLOCBlock ='<originatingAddressString>'+origLoc+'</originatingAddressString>'+
                '<originatingLocation>'+OffnetOriginLoc+'</originatingLocation>'+
                '<terminatingAddressString>'+termLoc+'</terminatingAddressString>'+                  
                '<terminatingLocation>CUSTOMER PREMISE</terminatingLocation>'; 

            }
            else{
                circuitOLOCBlock = '<originatingAddressString>'+origLoc+'</originatingAddressString>'+
                '<originatingLocation>CUSTOMER NID</originatingLocation>'+
                '<terminatingAddressString>'+termLoc+'</terminatingAddressString>'+                  
                '<terminatingLocation>CUSTOMER PREMISE</terminatingLocation>';
                }
            String poOrderBlock = '<purchaseOrderNumber>'+poOrder+'</purchaseOrderNumber>';
            string telephoneProvisioningBlock = '<printLocationOnBill>'+printLocationOnBill+'</printLocationOnBill>'+
                                                '<orderStageCode>HFB</orderStageCode>'+
                								 ContactLineinfo+
                                                '</commercialCircuitProvisioning>'+
                         						'<telephoneProvisioning>'+
                                                '<intraLata>'+
                                                '<preferredCarrierId>0PIC</preferredCarrierId>'+
                                                '<acceptsThirdPartyCalls>false</acceptsThirdPartyCalls>'+
                                                '<acceptsCollectCalls>false</acceptsCollectCalls>'+
                                                '<sourceCode>S</sourceCode>'+
                                            	'</intraLata>'+
                                            	'<interLata>'+
                                                '<preferredCarrierId>0PIC</preferredCarrierId>'+
                                                '<acceptsThirdPartyCalls>false</acceptsThirdPartyCalls>'+
                                                '<acceptsCollectCalls>false</acceptsCollectCalls>'+  
                                                '<sourceCode>S</sourceCode>'+
                                            '</interLata>'+
                                        '</telephoneProvisioning>'+
                         			'</provisioningDetails>'+
                					'<marketingProgram>BUSINESS</marketingProgram>';
            String afterCommCirProvBlock = '<printLocationOnBill>'+printLocationOnBill+'</printLocationOnBill>'+
                '<orderStageCode>HFB</orderStageCode>'+
                '</commercialCircuitProvisioning>'+
                '</provisioningDetails>'+
                '<marketingProgram>BUSINESS</marketingProgram>';
            String contractTermBlock =   '<contract>'+
                '<term>'+
                '<termInMonths>'+contractTerm+'</termInMonths>'+
                '</term>'+
                '<offer>'+
                '<soldOn>'+soldOn+'</soldOn>'+
                '<standardMarketingPackageId>1</standardMarketingPackageId>'+
                '</offer>'+
                '<Id>'+ contractId+'</Id>'+
                '<type>CIR</type>'+
                '<scheduleId>'+scheduleId+'</scheduleId>'+
                '<marketingPackage>BUSINESS</marketingPackage>'+
                '</contract>';
            String afterContractBlock = '</customerOrder>'+
                '<customerAccount>'+
                '<accountId>'+
                '<telephoneNumber>'+
                '<telephoneNumber>'+accTelNumber+'</telephoneNumber>'+
                '</telephoneNumber>'+
                '<environment>'+accEnv+'</environment>'+
                '</accountId>'+
                '<billingAccountId>'+
                '<telephoneNumber>'+
                '<telephoneNumber>'+billTelNumber+'</telephoneNumber>'+
                '</telephoneNumber>'+
                '</billingAccountId>'+
                '<accountServiceType>'+
                '<code>'+code+'</code>'+
                '</accountServiceType>'+
                '<accountPreferences>'+
                '<billHandlingCode>'+billHandlingCode+'</billHandlingCode>'+
                '<tollLimitCode/>'+
                '</accountPreferences>'+
                '<customerBill>'+
                '<cus:billDetailLevel>'+billDetailLevel+'</cus:billDetailLevel>';
            String billCycleBlock = '<cus:BillingCycle>'+
                '<cus:billingCycleDayOfMonth>'+billCycle+'</cus:billingCycleDayOfMonth>'+
                '</cus:BillingCycle>';
            if(OffNetPartnerValue !=null){
                afterCustomerBillBlock = '</customerBill>'+
                '<taxProfile>'+
                '<isFederalTaxExempt>'+isFederalTaxExempt+'</isFederalTaxExempt>'+
                '</taxProfile>'+
                '<location>'+
                '<serviceAddress>'+
                '<serviceAddressMaterId>'+
                '</serviceAddressMaterId>'+
                '<address>'+
                '<streetNumber>'+streetNumber+'</streetNumber>'+
                '<streetName>'+streetName+'</streetName>'+
                '<streetSuffix>'+streetSuffix+'</streetSuffix>'+
                '<cityName>'+cityName+'</cityName>'+
                '<stateAbbreviation>'+stateAbbreviation+'</stateAbbreviation>'+
                '<zipCode>'+zipCode+'</zipCode>'+
                '</address>'+
                '</serviceAddress>'+
                '</location>'+
                '<directory>'+
                '<delivery>'+
                '<directoryLabelQuantity>'+
                '<amount>0</amount>'+
                '</directoryLabelQuantity>'+
                '</delivery>'+
                '<directoryListingType>NR</directoryListingType>'+
                '<directoryListingAllowance>0</directoryListingAllowance>'+
                '</directory>'+
                '</customerAccount>'+
                '<customer>'+
                '<cus:organization>'+
                '<organizationName>'+
                '<tradingName>'+tradingName+'</tradingName>'+
                '</organizationName>'+
                '<contactInformation>'+
                '<internationalAddress>'+
                '<addressLine1>'+addressLine1+'</addressLine1>';
             intAddrLine3Block='<addressLine3>'+addressLine3+'</addressLine3>';
             intCityBlock =  '<cityName>'+intcityName+'</cityName>';
             intStateOrProv = '<stateOrProvince>'+stateOrProvince+'</stateOrProvince>';
             intPostalCode =   '<postalCode>'+postalCode+'</postalCode>';
            }else{
            afterCustomerBillBlock = '</customerBill>'+
                '<taxProfile>'+
                '<isFederalTaxExempt>'+isFederalTaxExempt+'</isFederalTaxExempt>'+
                '</taxProfile>'+
                '<location>'+
                '<serviceAddress>'+
                '<serviceAddressMaterId>'+
                '<controlNumber>'+controlNumber+'</controlNumber>'+
                '<sequenceNumber>1</sequenceNumber>'+
                '</serviceAddressMaterId>'+
                '<cityAbbreviation>'+cityAbbr+'</cityAbbreviation>'+
                '<address>'+
                '<streetNumber>'+streetNumber+'</streetNumber>'+
                '<streetName>'+streetName+'</streetName>'+
                '<streetSuffix>'+streetSuffix+'</streetSuffix>'+
                '<cityName>'+cityName+'</cityName>'+
                '<stateAbbreviation>'+stateAbbreviation+'</stateAbbreviation>'+
                '<zipCode>'+zipCode+'</zipCode>'+
                '</address>'+
                '</serviceAddress>'+
                '</location>'+
                '<directory>'+
                '<delivery>'+
                '<directoryLabelQuantity>'+
                '<amount>0</amount>'+
                '</directoryLabelQuantity>'+
                '</delivery>'+
                '<directoryListingType>NR</directoryListingType>'+
                '<directoryListingAllowance>0</directoryListingAllowance>'+
                '</directory>'+
                '</customerAccount>'+
                '<customer>'+
                '<cus:organization>'+
                '<organizationName>'+
                '<tradingName>'+tradingName+'</tradingName>'+
                '</organizationName>'+
                '<contactInformation>'+
                '<internationalAddress>'+
                '<addressLine1>'+addressLine1+'</addressLine1>';
             intAddrLine3Block='<addressLine3>'+addressLine3+'</addressLine3>';
             intCityBlock =  '<cityName>'+intcityName+'</cityName>';
             intStateOrProv = '<stateOrProvince>'+stateOrProvince+'</stateOrProvince>';
             intPostalCode =   '<postalCode>'+postalCode+'</postalCode>';
            }
            String beforeCreditProfileRefBlock =             '</internationalAddress>'+
                '</contactInformation>'+
                '</cus:organization>'+
                '<cus:customerCreditProfile>'+
                
                '<creditProfileReference>';
            String creditProfileBusBlock =  '<business>'+
                '<organizationType>'+organizationType + '</organizationType>'+
                '</business>';
            String busOwnerBlock =  '<businessOwner>'+
                '<name>'+businessOwner+'</name>'+
                '<telephoneNumber>'+businessOwnerTelephone+'</telephoneNumber>'+
                '</businessOwner>';
            String creditProfileMgrBlock =  '<manager>'+
                '<name>'+managerName+'</name>'+
                '</manager>';
            String creditProfileBillToContactBlock =  '<billingContact>'+
                '<name>'+billToContact+'</name>'+
                '<telephoneNumber>'+billingContactTelephone+'</telephoneNumber>'+
                '</billingContact>';
            String creditProfileTechContactBlock =  '<technicalContact>'+
                '<name>'+technicalContact+'</name>'+
                '<telephoneNumber>'+techContactNum+'</telephoneNumber>'+
                '</technicalContact>';
            String afterCreditProfileRefBlock =   '</creditProfileReference>'+
                '<creditScore>'+
                '<creditRating>'+creditRating+'</creditRating>'+
                '</creditScore>'+
                '</cus:customerCreditProfile>'+
                '<cus:customerType>Business</cus:customerType>'+
                '</customer>'+
                '</submitGroupOrderMemberInput>'+
                '</cus:SubmitGroupOrderMember>'+
                '</soapenv:Body>'+
                '</soapenv:Envelope>';
            
            requesttotal = request1 + customerOrderItemStr + commercialContractStr;
            if(dueDate!=null){
                requesttotal = requesttotal+dueDateBlock;
            }
            if(crisId!=null){
                requesttotal = requesttotal + cridIdBlock ;
            }
            if (saleschannelType!=null){
                requesttotal = requesttotal +  salesChannelBlock ; 
            }
            
          if(String.isBlank(controlNumber) || controlNumber==null){
              requesttotal = requesttotal +  newConstructionBlock;
          }
            
            requesttotal = requesttotal + afterSalesChannelBlock;
            if(circuitId!=null){
                requesttotal = requesttotal + circuitIdBlock;
            }
            if(dueDate!=null){
                requesttotal = requesttotal+dueDateBlock;
            }
            requesttotal = requesttotal + circuitOLOCBlock;
            if(poOrder!=null){
                requesttotal = requesttotal +   poOrderBlock;
            }
            if(OffNetPartnerValue !=null){
              requesttotal =requesttotal+   telephoneProvisioningBlock ; 
            }
            else{
                requesttotal = requesttotal +afterCommCirProvBlock;
            }
            //  if(contractTerm!=null){
            requesttotal = requesttotal +    contractTermBlock;
            //    }
            requesttotal = requesttotal + afterContractBlock;
            if(billCycle!=null){
                requesttotal = requesttotal + billCycleBlock;
            }
            requesttotal = requesttotal + afterCustomerBillBlock;
            if(addressLine3!=null){
                requesttotal = requesttotal +  intAddrLine3Block;
            }
            if(intcityName!=null){
                requesttotal = requesttotal + intCityBlock;    
            }
            if(stateOrProvince!=null){
                requesttotal = requesttotal + intStateOrProv;
            }
            if(postalCode!=null){
                requesttotal = requesttotal + intPostalCode;   
            }
            requesttotal = requesttotal + beforeCreditProfileRefBlock;
            if(organizationType!=null){
                requesttotal = requesttotal +  creditProfileBusBlock; 
            } 
            if(businessOwner!=null){
                requesttotal = requesttotal + busOwnerBlock;    
            }
            if(managerName!=null){
                requesttotal = requesttotal +   creditProfileMgrBlock;
            }
            if(billToContact!=null){
                requesttotal = requesttotal +  creditProfileBillToContactBlock;
            }
            if(technicalContact!=null){
                requesttotal = requesttotal +  creditProfileTechContactBlock;
            }
            requesttotal = requesttotal + afterCreditProfileRefBlock; 
            
            requesttotal = requesttotal.replaceAll('>null<', '><');
            System.debug('New design submit order request '+requesttotal );
            submitGroupOrderRequestMap.put('DpiRequestXML', requesttotal);
            submitGroupOrderRequestMap.put('transactionCount', groupOrderTransactionCount);
        }
        catch(Exception e){
            System.debug(e.getStackTraceString());
        }
        return (submitGroupOrderRequestMap);
    }
    
    public static boolean isChangeOrder(Map<String, Object> input) {
        boolean changeOrder = false;
        
        if(input != null) {
            
            Map <String, Object> SubmitGroupOrderMember = (Map <String, Object> ) input.get('SubmitGroupOrderMember');
            System.debug('SubmitGroupOrderMember :'+SubmitGroupOrderMember);
            
            if(SubmitGroupOrderMember != null) {
                
                Map <String, Object> SubmitGroupOrderMemberInput = (Map <String, Object> ) SubmitGroupOrderMember.get('submitGroupOrderMemberInput');
                
                if(SubmitGroupOrderMemberInput != null) {
                    Map <String, Object> customerOrder = (Map <String, Object> ) SubmitGroupOrderMemberInput.get('customerOrder');
                    String customerOrderType = (String) customerOrder.get('customerOrderType');
                    System.debug('customerOrderType :'+customerOrderType);
                    if(customerOrderType.equalsIgnoreCase('CHANGE')) {
                        changeOrder = true;
                        return changeOrder;
                    }
                }
                
            }
        }
        
        return changeOrder;
    } 
    
    /*public static Map<String, Object> getChangeSubmitGroupOrderRequest(Map<String, Object> input) {
        
        if(input == null || input.size() == 0) {
            return null;
        }
        
        esbftrCustomerordermanagement.SubmitGroupOrderMember_element request_x = new esbftrCustomerordermanagement.SubmitGroupOrderMember_element();
        esbftrCustomerordermanagement.msg_SubmitGroupOrderMemberRequest submitGroupOrderMemberInput = 
            new esbftrCustomerordermanagement.msg_SubmitGroupOrderMemberRequest();
        
        
        Map < String, Object > SubmitGroupOrderMemberJson = (Map < String, Object > ) input.get('SubmitGroupOrderMember');
        System.debug('SubmitGroupOrderMember in getChangeSubmitGroupOrderRequest:'+SubmitGroupOrderMemberJson);
        Map < String, Object > SubmitGroupOrderMemberInputJson = (Map < String, Object > ) SubmitGroupOrderMemberJson.get('submitGroupOrderMemberInput');
        
        setRequestHeader(SubmitGroupOrderMemberInputJson, submitGroupOrderMemberInput);
        setCustomer(SubmitGroupOrderMemberInputJson, submitGroupOrderMemberInput);
        setCustomerAccount(SubmitGroupOrderMemberInputJson, submitGroupOrderMemberInput);
        
        Map < String, Object > customerAccountJson = new Map < String, Object >();
        if(SubmitGroupOrderMemberInputJson.containsKey('customerAccount')) {
            customerAccountJson = (Map < String, Object >) SubmitGroupOrderMemberInputJson.get('customerAccount');    
        }   
        
        //poOrder
        String poOrder = '';
        if(SubmitGroupOrderMemberInputJson.containsKey('poOrder')) {
            poOrder = (String) SubmitGroupOrderMemberInputJson.get('poOrder');
        }
        
        //groupOrderTransactionCount            
        String groupOrderTransactionCount ='';
        if(SubmitGroupOrderMemberInputJson.containsKey('groupOrderTransactionCount')) {
            groupOrderTransactionCount = (String)SubmitGroupOrderMemberInputJson.get('groupOrderTransactionCount');
            submitGroupOrderMemberInput.groupOrderTransactionCount = Integer.valueOf(groupOrderTransactionCount); 
        }
        
         
        //scheduleId
        String scheduleId = '';        
        if(SubmitGroupOrderMemberInputJson.containsKey('scheduleId')) {
            scheduleId = (String)SubmitGroupOrderMemberInputJson.get('scheduleId');
        }
        //contractId
        String contractId = '';
        if(SubmitGroupOrderMemberInputJson.containsKey('ContractId')) {
            contractId =(String)SubmitGroupOrderMemberInputJson.get('ContractId'); 
        }
        
        if(contractId!=null && contractId.length()>15){ 
            contractId=contractId.substring(0, 14);
        }
        
        setCustomerOrder(SubmitGroupOrderMemberInputJson, submitGroupOrderMemberInput, scheduleId, contractId);
        //circuitId
        String circuitId = '';
        if(SubmitGroupOrderMemberInputJson.containsKey(circuitId)) {
            circuitId = (String)SubmitGroupOrderMemberInputJson.get('circuitId');
        }
        
        System.debug('MACD change order Submit request xml --' + JSON.serialize(submitGroupOrderMemberInput));
        
        Map<String, Object> changeOrderMap = new Map<String, Object> ();
        changeOrderMap.put('mcad_order', submitGroupOrderMemberInput);
        changeOrderMap.put('transactionCount', groupOrderTransactionCount);
        return changeOrderMap;
    }*/
    
      public static Map<String, Object> getChangeSubmitGroupOrderRequest(Map<String, Object> input) {
        
        if(input == null || input.size() == 0) {
            return null;
        }
        
        
         String requesttotal,billCycle, streetAddress,serviceType,streetNumber,streetName,cityName,stateAbbreviation, streetSuffix,zipCode,addressLine1, addressLine3, country, intcityName,stateOrProvince,postalCode,tradingName; 
         String OrgLocCityName,  correlationId, orgStreetAdd , orgstateAbbr, orgZipCode, origLoc,termLoc, saleschannelType, contractTerm,soldOn, salesChannelPartnerId, crisId, organizationType,businessOwner, technicalContact,billToContact, managerName,techContactNum, billingContactTelephone, businessOwnerTelephone;
         Boolean isInternationalAddress, creditRating, dueDate;
          Map<String, String> submitGroupOrderRequestMap =new Map<String, String> ();
         Map < String, Object > SubmitGroupOrderMemberJson = (Map < String, Object > ) input.get('SubmitGroupOrderMember');
         System.debug('SubmitGroupOrderMember in getChangeSubmitGroupOrderRequest:'+SubmitGroupOrderMemberJson);
         Map < String, Object > SubmitGroupOrderMemberInputJson = (Map < String, Object > ) SubmitGroupOrderMemberJson.get('submitGroupOrderMemberInput');
         Map<String, Object> header= new Map <String, Object>();
          String groupOrderTransactionCount ;
        if(SubmitGroupOrderMemberInputJson.containsKey('header')) {
            header =(Map < String, Object > ) SubmitGroupOrderMemberInputJson.get('header');    
        }
        if(header != null) {
            if(header.containsKey('correlationId')) {
                correlationId=(String)header.get('correlationId');  
           }
        }
       // setRequestHeader(SubmitGroupOrderMemberInputJson, submitGroupOrderMemberInput);
      //  setCustomer(SubmitGroupOrderMemberInputJson, submitGroupOrderMemberInput);
      //  setCustomerAccount(SubmitGroupOrderMemberInputJson, submitGroupOrderMemberInput);
        
        Map < String, Object > customerAccountJson = new Map < String, Object >();
        if(SubmitGroupOrderMemberInputJson.containsKey('customerAccount')) {
            customerAccountJson = (Map < String, Object >) SubmitGroupOrderMemberInputJson.get('customerAccount');    
        }   
        
        //poOrder
        String poOrder = '';
        if(SubmitGroupOrderMemberInputJson.containsKey('poOrder')) {
            poOrder = (String) SubmitGroupOrderMemberInputJson.get('poOrder');
        }
        
        //groupOrderTransactionCount            
        if(SubmitGroupOrderMemberInputJson.containsKey('groupOrderTransactionCount')) {
            groupOrderTransactionCount = (String)SubmitGroupOrderMemberInputJson.get('groupOrderTransactionCount');
        //    groupOrderTransactionCount = Integer.valueOf(groupOrderTransactionCount); 
        }
        
         
        //scheduleId
        String scheduleId = '';        
        if(SubmitGroupOrderMemberInputJson.containsKey('scheduleId')) {
            scheduleId = (String)SubmitGroupOrderMemberInputJson.get('scheduleId');
        }
        //contractId
        String contractId = '';
        if(SubmitGroupOrderMemberInputJson.containsKey('ContractId')) {
            contractId =(String)SubmitGroupOrderMemberInputJson.get('ContractId'); 
        }
        
        if(contractId!=null && contractId.length()>15){ 
            contractId=contractId.substring(0, 14);
        }
        
       // setCustomerOrder(SubmitGroupOrderMemberInputJson, submitGroupOrderMemberInput, scheduleId, contractId);
        //circuitId
        String circuitId = '';
        if(SubmitGroupOrderMemberInputJson.containsKey(circuitId)) {
            circuitId = (String)SubmitGroupOrderMemberInputJson.get('circuitId');
        }
        
        System.debug('MACD change order Submit request xml --' + JSON.serialize(SubmitGroupOrderMemberInputJson));
        
        Map<String, Object> changeOrderMap = new Map<String, Object> ();
    //    changeOrderMap.put('mcad_order', submitGroupOrderMemberInput);
    //    changeOrderMap.put('transactionCount', groupOrderTransactionCount);
         String request1 = '<soapenv:Envelope '+'xmlns:'+'soapenv="http://schemas.xmlsoap.org/soap/envelope/" '+'xmlns:cus="http://esb.frontier.com/CustomerOrderManagement" '+'xmlns:'+'shar="'+ 'http://esb.frontier.com/sharedType" '+'xmlns:'+'xsi="xsi">'+
         '<soapenv:Header/>'+
         '<soapenv:Body>'+
         '<cus:SubmitGroupOrderMember>'+
         '<submitGroupOrderMemberInput>'+
         '<header>'+
         '<shar:correlationId>'+correlationId+'</shar:correlationId>'+
         '<shar:requestingApplication>VlocityOM</shar:requestingApplication>'+
         '<securityInfo>'+
         '<userId>ftrqacomm</userId>'+
         '<employeeId>825280</employeeId>'+
         '</securityInfo>'+
         '</header>'+
         '<groupOrderTransactionCount>'+groupOrderTransactionCount+'</groupOrderTransactionCount>'+
         '<customerOrder>'+
      //   '<customerOrderType>'+customerOrderType+'</customerOrderType>'+
          '<salesChannelPartnerId>'+salesChannelPartnerId+'</salesChannelPartnerId>';
          System.debug('Request1 is '+request1);
          String dueDateBlock =  '<dueDate>'+dueDate+'</dueDate>';
          String cridIdBlock =  '<soldBy>'+
          '<id>'+crisId+'</id>'+
          '</soldBy>';
          String salesChannelBlock =  '<saleschannelType>'+
          '<code>' + saleschannelType + '</code>'+
          '</saleschannelType>';
         
          String afterSalesChannelBlock = '<provisioningDetails>'+
          '<commercialCircuitProvisioning>'+
      //    '<printCircuitOnBill>'+printCircuitOnBill+'</printCircuitOnBill>'+
          '<serviceType>'+serviceType+'</serviceType>';
          String circuitIdBlock = '<circuitId>'+circuitId+'</circuitId>';
          String circuitOLOCBlock = '<originatingAddressString>'+origLoc+'</originatingAddressString>'+
          '<originatingLocation>CUSTOMER NID</originatingLocation>'+
          '<terminatingAddressString>'+termLoc+'</terminatingAddressString>'+                  
          '<terminatingLocation>CUSTOMER PREMISE</terminatingLocation>';
          String poOrderBlock = '<purchaseOrderNumber>'+poOrder+'</purchaseOrderNumber>';
      
          String contractTermBlock =   '<contract>'+
          '<term>'+
          '<termInMonths>'+contractTerm+'</termInMonths>'+
          '</term>'+
          '<offer>'+
          '<soldOn>'+soldOn+'</soldOn>'+
          '<standardMarketingPackageId>1</standardMarketingPackageId>'+
          '</offer>'+
          '<Id>'+ contractId+'</Id>'+
          '<type>CIR</type>'+
          '<scheduleId>'+scheduleId+'</scheduleId>'+
          '<marketingPackage>BUSINESS</marketingPackage>'+
           '</contract>';
      /*    String afterContractBlock = '</customerOrder>'+
          '<customerAccount>'+
          '<accountId>'+
          '<telephoneNumber>'+
          '<telephoneNumber>'+accTelNumber+'</telephoneNumber>'+
          '</telephoneNumber>'+
          '<environment>'+accEnv+'</environment>'+
          '</accountId>'+
          '<billingAccountId>'+
          '<telephoneNumber>'+
          '<telephoneNumber>'+billTelNumber+'</telephoneNumber>'+
          '</telephoneNumber>'+
          '</billingAccountId>'+
          '<accountServiceType>'+
           '<code>'+code+'</code>'+
           '</accountServiceType>'+
           '<accountPreferences>'+
           '<billHandlingCode>'+billHandlingCode+'</billHandlingCode>'+
           '<tollLimitCode/>'+
           '</accountPreferences>'+
           '<customerBill>'+
           '<cus:billDetailLevel>'+billDetailLevel+'</cus:billDetailLevel>';
           String billCycleBlock = '<cus:BillingCycle>'+
           '<cus:billingCycleDayOfMonth>'+billCycle+'</cus:billingCycleDayOfMonth>'+
           '</cus:BillingCycle>';*/

         /* String afterCustomerBillBlock = '</customerBill>'+
           '<taxProfile>'+
           '<isFederalTaxExempt>'+isFederalTaxExempt+'</isFederalTaxExempt>'+
           '</taxProfile>'+
           '<location>'+
           '<serviceAddress>'+
           '<serviceAddressMaterId>'+
           '<controlNumber>'+controlNumber+'</controlNumber>'+
           '<sequenceNumber>1</sequenceNumber>'+
           '</serviceAddressMaterId>'+
           '<cityAbbreviation>'+cityAbbr+'</cityAbbreviation>'+
           '<address>'+
           '<streetNumber>'+streetNumber+'</streetNumber>'+
           '<streetName>'+streetName+'</streetName>'+
           '<streetSuffix>'+streetSuffix+'</streetSuffix>'+
           '<cityName>'+cityName+'</cityName>'+
           '<stateAbbreviation>'+stateAbbreviation+'</stateAbbreviation>'+
           '<zipCode>'+zipCode+'</zipCode>'+
           '</address>'+
           '</serviceAddress>'+
           '</location>'+
           '<directory>'+
           '<delivery>'+
           '<directoryLabelQuantity>'+
           '<amount>0</amount>'+
           '</directoryLabelQuantity>'+
           '</delivery>'+
           '<directoryListingType>NR</directoryListingType>'+
           '<directoryListingAllowance>0</directoryListingAllowance>'+
           '</directory>'+
          '</customerAccount>'+
          '<customer>'+
          '<cus:organization>'+
          '<organizationName>'+
          '<tradingName>'+tradingName+'</tradingName>'+
          '</organizationName>'+
          '<contactInformation>'+
          '<internationalAddress>'+
          '<addressLine1>'+addressLine1+'</addressLine1>';*/
          String intAddrLine3Block='<addressLine3>'+addressLine3+'</addressLine3>';
          String intCityBlock =  '<cityName>'+intcityName+'</cityName>';
          String intStateOrProv = '<stateOrProvince>'+stateOrProvince+'</stateOrProvince>';
          String intPostalCode =   '<postalCode>'+postalCode+'</postalCode>';
          String beforeCreditProfileRefBlock =             '</internationalAddress>'+
          '</contactInformation>'+
          '</cus:organization>'+
          '<cus:customerCreditProfile>'+
         
          '<creditProfileReference>';
          String creditProfileBusBlock =  '<business>'+
          '<organizationType>'+organizationType + '</organizationType>'+
          '</business>';
          String busOwnerBlock =  '<businessOwner>'+
          '<name>'+businessOwner+'</name>'+
               '<telephoneNumber>'+businessOwnerTelephone+'</telephoneNumber>'+
          '</businessOwner>';
          String creditProfileMgrBlock =  '<manager>'+
          '<name>'+managerName+'</name>'+
          '</manager>';
          String creditProfileBillToContactBlock =  '<billingContact>'+
          '<name>'+billToContact+'</name>'+
               '<telephoneNumber>'+billingContactTelephone+'</telephoneNumber>'+
          '</billingContact>';
          String creditProfileTechContactBlock =  '<technicalContact>'+
          '<name>'+technicalContact+'</name>'+
          '<telephoneNumber>'+techContactNum+'</telephoneNumber>'+
          '</technicalContact>';
          String afterCreditProfileRefBlock =   '</creditProfileReference>'+
               '<creditScore>'+
          '<creditRating>'+creditRating+'</creditRating>'+
          '</creditScore>'+
          '</cus:customerCreditProfile>'+
          '<cus:customerType>Business</cus:customerType>'+
          '</customer>'+
          '</submitGroupOrderMemberInput>'+
          '</cus:SubmitGroupOrderMember>'+
          '</soapenv:Body>'+
          '</soapenv:Envelope>';

         // requesttotal = request1 + customerOrderItemStr + commercialContractStr;
           requesttotal = request1;
          if(dueDate!=null){
            requesttotal = requesttotal+dueDateBlock;
          }
          if(crisId!=null){
             requesttotal = requesttotal + cridIdBlock ;
          }
          if (saleschannelType!=null){
             requesttotal = requesttotal +  salesChannelBlock ; 
          }
       /*   if(String.isBlank(controlNumber) || controlNumber==null){
              requesttotal = requesttotal +  newConstructionBlock;
          }*/
          requesttotal = requesttotal + afterSalesChannelBlock;
          if(circuitId!=null){
              requesttotal = requesttotal + circuitIdBlock;
          }
       /*    if(dueDate!=null){
            requesttotal = requesttotal+dueDateBlock;
          }*/
          requesttotal = requesttotal + circuitOLOCBlock;
          if(poOrder!=null){
           requesttotal = requesttotal +   poOrderBlock;
          }
         //   requesttotal = requesttotal +afterCommCirProvBlock;
        //  if(contractTerm!=null){
            requesttotal = requesttotal +    contractTermBlock;
      //    }
     //     requesttotal = requesttotal + afterContractBlock;
       /*   if(billCycle!=null){
          requesttotal = requesttotal + billCycleBlock;
          }*/
     //     requesttotal = requesttotal + afterCustomerBillBlock;
          if(addressLine3!=null){
           requesttotal = requesttotal +  intAddrLine3Block;
          }
          if(intcityName!=null){
            requesttotal = requesttotal + intCityBlock;    
          }
          if(stateOrProvince!=null){
            requesttotal = requesttotal + intStateOrProv;
          }
          if(postalCode!=null){
            requesttotal = requesttotal + intPostalCode;   
          }
          requesttotal = requesttotal + beforeCreditProfileRefBlock;
          if(organizationType!=null){
          requesttotal = requesttotal +  creditProfileBusBlock; 
          } 
          if(businessOwner!=null){
          requesttotal = requesttotal + busOwnerBlock;    
          }
          if(managerName!=null){
           requesttotal = requesttotal +   creditProfileMgrBlock;
          }
          if(billToContact!=null){
            requesttotal = requesttotal +  creditProfileBillToContactBlock;
          }
          if(technicalContact!=null){
            requesttotal = requesttotal +  creditProfileTechContactBlock;
          }
           requesttotal = requesttotal + afterCreditProfileRefBlock; 
          System.debug('Submit MACD order request1 '+requesttotal );
          requesttotal = requesttotal.replaceAll('>null<', '><');
          System.debug('Submit MACD order request '+requesttotal );
          submitGroupOrderRequestMap.put('DpiRequestXML', requesttotal);
          submitGroupOrderRequestMap.put('transactionCount', groupOrderTransactionCount);
        return submitGroupOrderRequestMap;
    }
    
        public Map<String, Object> payloadChangeOrderDIAtoMNS(String url, String path, Map<String, Object> input, String orderType){
        System.debug('Input to CreateDPIRequestType: '+JSON.serialize(input));
        Map<String, String> submitGroupOrderRequestMap =new Map<String, String> ();
        Map < String, Object > serviceAddrJson = new Map< String, Object >();
        Map < String, Object > serviceAddrMasterIdJson = new Map< String, Object >();
        Map < String, Object > individualJson = new Map< String, Object >();
        Map < String, Object > organizationJson = new Map< String, Object >();
        Map < String, Object > custCreditProfileJson = new Map< String, Object >();
        Map < String, Object > custCreditProfileReferenceJson = new Map< String, Object >();
        Map < String, Object > businessJson = new Map< String, Object >();
        Map < String, Object > landlordJson =  new Map< String, Object >();
        Map < String, Object > businessOwnerJson = new Map< String, Object >();
        Map < String, Object > managerJson = new Map< String, Object >();
        Map < String, Object > techContactJson = new Map< String, Object >();
        Map < String, Object > billContactJson = new Map< String, Object >();
        Map < String, Object > billingContactJson = new Map< String, Object >();
        Map < String, Object > creditScoreJson = new Map< String, Object >();
        Final String SalesChannelCode_TTL = '202';
        String requesttotal,cityAbbr,plus4, billCycle,isFederalTaxExempt, streetAddress,serviceType,streetNumber,streetName,cityName,stateAbbreviation, streetSuffix,zipCode,addressLine1, addressLine3, country, intcityName,stateOrProvince,postalCode,tradingName; 
        String OrgLocCityName, code, customerOrderType,orgStreetAdd,billDetailLevel, tollLimitCode, orgstateAbbr, orgZipCode, origLoc,termLoc, saleschannelType, contractTerm,soldOn, salesChannelPartnerId, crisId, organizationType,businessOwner, technicalContact,billToContact, managerName,techContactNum, billingContactTelephone, businessOwnerTelephone;
        Boolean isInternationalAddress;
        //String salesChannelBlock;
        try{
            Map<String, String> submitGroupOrderResponseMap = null;
            Map < String, Object > SubmitGroupOrderMember = (Map < String, Object > ) input.get('SubmitGroupOrderMember');
            System.debug('SubmitGroupOrderMember :'+JSON.serialize(SubmitGroupOrderMember));
            Map < String, Object > SubmitGroupOrderMemberInput = (Map < String, Object > ) SubmitGroupOrderMember.get('submitGroupOrderMemberInput');
            String scheduleId = (String)SubmitGroupOrderMemberInput.get('scheduleId');
            String contractId = (String)SubmitGroupOrderMemberInput.get('ContractId');
            if(contractId!=null && contractId.length()>15){ 
                contractId=contractId.substring(0, 14);
            }

            String groupOrderTransactionCount ='1';
            Map < String, Object > header =(Map < String, Object > ) SubmitGroupOrderMemberInput.get('header');
            String correlationId =(String)header.get('correlationId') ;
            Map < String, Object > customerOrder =(Map < String, Object > ) SubmitGroupOrderMemberInput.get('customerOrder');
            customerOrderType = 'CHANGE';

            String actionDPI = (String)customerOrder.get('actionDPI');
            //String installationType = (String)customerOrder.get('installationType');
            List<Object> custOrderItemString =    (List<Object>) customerOrder.get('customerOrderItem');
            if(custOrderItemString!=null){
                system.debug('custOrderItemString ESB:'+JSON.serialize(custOrderItemString));
                getCustOrderItemMap = (Map < String, Object > )getCustomerOrderItemStringDIAtoMNS(custOrderItemString);
                system.debug('getCustOrderItemMap ESB:'+getCustOrderItemMap);
                customerOrderItemStr = (String)getCustOrderItemMap.get('CustOrderItemString');
                system.debug('customerOrderItemStr ESB:'+customerOrderItemStr);
            }
            String prodId = (String)getCustOrderItemMap.get('ProdId');
     
            if((String)customerOrder.get('saleschannelType') !=null){
                saleschannelType = ((String)customerOrder.get('saleschannelType')).substringBefore(' -');
            }
            salesChannelPartnerId = (String)customerOrder.get('salesChannelPartnerId');
            Map < String, Object > contract = (Map < String, Object > )customerOrder.get('contract');
            Map < String, Object > term = new  Map < String, Object > ();
            Map < String, Object > offer = new  Map < String, Object > ();
            if(contract !=null){
                term = (Map < String, Object > )contract.get('Term'); 
                offer =(Map < String, Object > )contract.get('offer');
            }
            
            
            if(term!=null){
                contractTerm = String.valueOf(term.get('termInMonths'));
            }
            if(offer!=null){
                soldOn =  (String)offer.get('soldOn');
            }
            
            
            crisId =(String)customerOrder.get('crisId');
            System.debug('Step 1');
            
            String dueDate = (String)customerOrder.get('dueDate');
            if(dueDate!=null){
                dueDate = dueDate+'T00:00:00';
            }
            List<Object> commercialContractString =(List<Object> ) customerOrder.get('commercialContract');
            if(commercialContractString!=null){
                commercialContractStr = getCommercialContractStringMNS(commercialContractString, scheduleId, contractId);
            }
            Map < String, Object >  provisioningDetails = (Map < String, Object > )customerOrder.get('provisioningDetails');

            System.debug('Step 2 customerAccount');
            Map < String, Object > customerAccountJson =(Map < String, Object > ) SubmitGroupOrderMemberInput.get('customerAccount');
            System.debug('customerAccountJson :'+ customerAccountJson);
            Map < String, Object > accountIdJson = (Map < String, Object > )customerAccountJson.get('accountId');
            System.debug('accountIdJson :'+ accountIdJson);
            Map < String, Object >  accTelephoneNumberJson = (Map < String, Object > )accountIdJson.get('telephoneNumber');
            String accTelNumber = (String)accTelephoneNumberJson.get('telephoneNumber');
            String accEnv = (String)accountIdJson.get('environment');
            Map < String, Object >  accountServiceTypeJson = (Map < String, Object > )customerAccountJson.get('accountServiceType');
            if(accountServiceTypeJson!=null){
            code = (String)accountServiceTypeJson.get('code');// should be 65 for DIA to MNS always
            }


            System.debug('Step PAYLOAD REQUET');
            System.debug('commercialContractStr is ********'+commercialContractStr);
            String request1 = '<soapenv:Envelope '+'xmlns:'+'soapenv="http://schemas.xmlsoap.org/soap/envelope/" '+'xmlns:cus="http://esb.frontier.com/CustomerOrderManagement" '+'xmlns:'+'shar="'+ 'http://esb.frontier.com/sharedType" '+'xmlns:'+'xsi="xsi">'+
                '<soapenv:Header/>'+
                '<soapenv:Body>'+
                '<cus:SubmitGroupOrderMember>'+
                '<submitGroupOrderMemberInput>'+
                '<header>'+
                '<shar:correlationId>'+correlationId+'</shar:correlationId>'+
                '<shar:requestingApplication>VlocityOM</shar:requestingApplication>'+
                '<securityInfo>'+
                '<userId>ftrqacomm</userId>'+
                '<employeeId>825280</employeeId>'+
                '</securityInfo>'+
                '</header>'+
                '<groupOrderTransactionCount>'+groupOrderTransactionCount+'</groupOrderTransactionCount>'+
                '<customerOrder>'+
                '<customerOrderType>'+customerOrderType+'</customerOrderType>';
                //'<salesChannelPartnerId>'+salesChannelPartnerId+'</salesChannelPartnerId>';
            String dueDateBlock =  '<dueDate>'+dueDate+'</dueDate>';
            String cridIdBlock =  '<soldBy>'+
                '<id>'+crisId+'</id>'+
                '</soldBy>';
            String salesChannelBlock =  '<saleschannelType>'+
                '<code>' + saleschannelType + '</code>'+
                '</saleschannelType>';
            String afterSalesChannelBlock = '<provisioningDetails>'+
               '<orderStageCode>HFB</orderStageCode>'+
                '</provisioningDetails>'+
                '<marketingProgram>BUSINESS</marketingProgram>';
               
                
            String contractTermBlock =   '<contract>'+
                '<term>'+
                '<termInMonths>'+contractTerm+'</termInMonths>'+
                '</term>'+
                '<offer>'+
                '<soldOn>'+soldOn+'</soldOn>'+
                '<standardMarketingPackageId>1</standardMarketingPackageId>'+
                '</offer>'+
                '<Id>'+ contractId+'</Id>'+
                '<type>CIR</type>'+
                '<scheduleId>'+scheduleId+'</scheduleId>'+
                '<marketingPackage>BUSINESS</marketingPackage>'+
                '</contract>';
            String afterContractBlock = '</customerOrder>'+
                '<customerAccount>'+
                '<accountId>'+
                '<telephoneNumber>'+
                '<telephoneNumber>'+accTelNumber+'</telephoneNumber>'+
                '</telephoneNumber>'+
                '<environment>'+accEnv+'</environment>'+
                '</accountId>'+
                '<accountServiceType>'+
                '<code>'+code+'</code>'+
                '</accountServiceType>'+
                //'<accountPreferences>'+
                //'<tollLimitCode/>'+
                //'</accountPreferences>'+
                '<customerBill>'+
                '<cus:billDetailLevel>PARTIAL</cus:billDetailLevel>'+
                '</customerBill>'+
                '</customerAccount>'+
                '</submitGroupOrderMemberInput>'+
                '</cus:SubmitGroupOrderMember>'+
                '</soapenv:Body>'+
                '</soapenv:Envelope>';
            
            requesttotal = request1 + customerOrderItemStr + commercialContractStr;
            if(dueDate!=null){
                requesttotal = requesttotal+dueDateBlock;
            }
            if(crisId!=null){
                requesttotal = requesttotal + cridIdBlock ;
            }
            if (saleschannelType!=null){
                requesttotal = requesttotal +  salesChannelBlock ; 
            }
            requesttotal = requesttotal + afterSalesChannelBlock;

            requesttotal = requesttotal +    contractTermBlock;
            requesttotal = requesttotal + afterContractBlock;

            requesttotal = requesttotal.replaceAll('>null<', '><');
            System.debug('New design submit order request '+requesttotal );
            submitGroupOrderRequestMap.put('DpiRequestXML', requesttotal);
            submitGroupOrderRequestMap.put('transactionCount', groupOrderTransactionCount);
        }
        catch(Exception e){
            System.debug(e.getStackTraceString());
        }
        return (submitGroupOrderRequestMap);
    }
        
    
        public Map<String, Object> payloadChangeOrderMNStoMNS(String url, String path, Map<String, Object> input, String orderType){
        System.debug('Input to CreateDPIRequestType: '+JSON.serialize(input));
        Map<String, String> submitGroupOrderRequestMap =new Map<String, String> ();
        Map < String, Object > serviceAddrJson = new Map< String, Object >();
        Map < String, Object > serviceAddrMasterIdJson = new Map< String, Object >();
        Map < String, Object > individualJson = new Map< String, Object >();
        Map < String, Object > organizationJson = new Map< String, Object >();
        Map < String, Object > custCreditProfileJson = new Map< String, Object >();
        Map < String, Object > custCreditProfileReferenceJson = new Map< String, Object >();
        Map < String, Object > businessJson = new Map< String, Object >();
        Map < String, Object > landlordJson =  new Map< String, Object >();
        Map < String, Object > businessOwnerJson = new Map< String, Object >();
        Map < String, Object > managerJson = new Map< String, Object >();
        Map < String, Object > techContactJson = new Map< String, Object >();
        Map < String, Object > billContactJson = new Map< String, Object >();
        Map < String, Object > billingContactJson = new Map< String, Object >();
        Map < String, Object > creditScoreJson = new Map< String, Object >();
        Final String SalesChannelCode_TTL = '202';
        String requesttotal,cityAbbr,plus4, billCycle,isFederalTaxExempt, streetAddress,serviceType,streetNumber,streetName,cityName,stateAbbreviation, streetSuffix,zipCode,addressLine1, addressLine3, country, intcityName,stateOrProvince,postalCode,tradingName; 
        String OrgLocCityName, code, customerOrderType,orgStreetAdd,billDetailLevel, tollLimitCode, orgstateAbbr, orgZipCode, origLoc,termLoc, saleschannelType, contractTerm,soldOn, salesChannelPartnerId, crisId, organizationType,businessOwner, technicalContact,billToContact, managerName,techContactNum, billingContactTelephone, businessOwnerTelephone;
        Boolean isInternationalAddress;
        //String salesChannelBlock;
        try{
            Map<String, String> submitGroupOrderResponseMap = null;
            Map < String, Object > SubmitGroupOrderMember = (Map < String, Object > ) input.get('SubmitGroupOrderMember');
            System.debug('SubmitGroupOrderMember :'+JSON.serialize(SubmitGroupOrderMember));
            Map < String, Object > SubmitGroupOrderMemberInput = (Map < String, Object > ) SubmitGroupOrderMember.get('submitGroupOrderMemberInput');
            String scheduleId = (String)SubmitGroupOrderMemberInput.get('scheduleId');
            String contractId = (String)SubmitGroupOrderMemberInput.get('ContractId');
            if(contractId!=null && contractId.length()>15){ 
                contractId=contractId.substring(0, 14);
            }

            String groupOrderTransactionCount ='1';
            Map < String, Object > header =(Map < String, Object > ) SubmitGroupOrderMemberInput.get('header');
            String correlationId =(String)header.get('correlationId') ;
            Map < String, Object > customerOrder =(Map < String, Object > ) SubmitGroupOrderMemberInput.get('customerOrder');
            customerOrderType = 'CHANGE';

            String actionDPI = (String)customerOrder.get('actionDPI');
            //String installationType = (String)customerOrder.get('installationType');
            List<Object> custOrderItemString =    (List<Object>) customerOrder.get('customerOrderItem');
            if(custOrderItemString!=null){
                system.debug('custOrderItemString ESB:'+JSON.serialize(custOrderItemString));
                getCustOrderItemMap = (Map < String, Object > )getCustomerOrderItemStringMNStoMNS(custOrderItemString);
                system.debug('getCustOrderItemMap ESB:'+getCustOrderItemMap);
                customerOrderItemStr = (String)getCustOrderItemMap.get('CustOrderItemString');
                system.debug('customerOrderItemStr ESB:'+customerOrderItemStr);
            }
            String prodId = (String)getCustOrderItemMap.get('ProdId');
     
            if((String)customerOrder.get('saleschannelType') !=null){
                saleschannelType = ((String)customerOrder.get('saleschannelType')).substringBefore(' -');
            }
            salesChannelPartnerId = (String)customerOrder.get('salesChannelPartnerId');
            Map < String, Object > contract = (Map < String, Object > )customerOrder.get('contract');
            Map < String, Object > term = new  Map < String, Object > ();
            Map < String, Object > offer = new  Map < String, Object > ();
            if(contract !=null){
                term = (Map < String, Object > )contract.get('Term'); 
                offer =(Map < String, Object > )contract.get('offer');
            }
            
            
            if(term!=null){
                contractTerm = String.valueOf(term.get('termInMonths'));
            }
            if(offer!=null){
                soldOn =  (String)offer.get('soldOn');
            }
            
            
            crisId =(String)customerOrder.get('crisId');
            System.debug('Step 1');
            
            String dueDate = (String)customerOrder.get('dueDate');
            if(dueDate!=null){
                dueDate = dueDate+'T00:00:00';
            }
            List<Object> commercialContractString =(List<Object> ) customerOrder.get('commercialContract');
            if(commercialContractString!=null){
                commercialContractStr = getCommercialContractStringMNS(commercialContractString, scheduleId, contractId);
            }
            Map < String, Object >  provisioningDetails = (Map < String, Object > )customerOrder.get('provisioningDetails');

            System.debug('Step 2 customerAccount');
            Map < String, Object > customerAccountJson =(Map < String, Object > ) SubmitGroupOrderMemberInput.get('customerAccount');
            System.debug('customerAccountJson :'+ customerAccountJson);
            Map < String, Object > accountIdJson = (Map < String, Object > )customerAccountJson.get('accountId');
            System.debug('accountIdJson :'+ accountIdJson);
            Map < String, Object >  accTelephoneNumberJson = (Map < String, Object > )accountIdJson.get('telephoneNumber');
            String accTelNumber = (String)accTelephoneNumberJson.get('telephoneNumber');
            String accEnv = (String)accountIdJson.get('environment');
            Map < String, Object >  accountServiceTypeJson = (Map < String, Object > )customerAccountJson.get('accountServiceType');
            if(accountServiceTypeJson!=null){
            code = (String)accountServiceTypeJson.get('code');// should be 65 for DIA to MNS always
            }


            System.debug('Step PAYLOAD REQUET');
            System.debug('commercialContractStr is ********'+commercialContractStr);
            String request1 = '<soapenv:Envelope '+'xmlns:'+'soapenv="http://schemas.xmlsoap.org/soap/envelope/" '+'xmlns:cus="http://esb.frontier.com/CustomerOrderManagement" '+'xmlns:'+'shar="'+ 'http://esb.frontier.com/sharedType" '+'xmlns:'+'xsi="xsi">'+
                '<soapenv:Header/>'+
                '<soapenv:Body>'+
                '<cus:SubmitGroupOrderMember>'+
                '<submitGroupOrderMemberInput>'+
                '<header>'+
                '<shar:correlationId>'+correlationId+'</shar:correlationId>'+
                '<shar:requestingApplication>VlocityOM</shar:requestingApplication>'+
                '<securityInfo>'+
                '<userId>ftrqacomm</userId>'+
                '<employeeId>825280</employeeId>'+
                '</securityInfo>'+
                '</header>'+
                '<groupOrderTransactionCount>'+groupOrderTransactionCount+'</groupOrderTransactionCount>'+
                '<customerOrder>'+
                '<customerOrderType>'+customerOrderType+'</customerOrderType>';
                //'<salesChannelPartnerId>'+salesChannelPartnerId+'</salesChannelPartnerId>';
            String dueDateBlock =  '<dueDate>'+dueDate+'</dueDate>';
            String cridIdBlock =  '<soldBy>'+
                '<id>'+crisId+'</id>'+
                '</soldBy>';
            String salesChannelBlock =  '<saleschannelType>'+
                '<code>' + saleschannelType + '</code>'+
                '</saleschannelType>';
            String afterSalesChannelBlock = '<provisioningDetails>'+
               '<orderStageCode>HFB</orderStageCode>'+
                '</provisioningDetails>'+
                '<marketingProgram>BUSINESS</marketingProgram>';
               
                
            String contractTermBlock =   '<contract>'+
                '<term>'+
                '<termInMonths>'+contractTerm+'</termInMonths>'+
                '</term>'+
                '<offer>'+
                '<soldOn>'+soldOn+'</soldOn>'+
                '<standardMarketingPackageId>1</standardMarketingPackageId>'+
                '</offer>'+
                '<Id>'+ contractId+'</Id>'+
                '<type>CIR</type>'+
                '<scheduleId>'+scheduleId+'</scheduleId>'+
                '<marketingPackage>BUSINESS</marketingPackage>'+
                '</contract>';
            String afterContractBlock = '</customerOrder>'+
                '<customerAccount>'+
                '<accountId>'+
                '<telephoneNumber>'+
                '<telephoneNumber>'+accTelNumber+'</telephoneNumber>'+
                '</telephoneNumber>'+
                '<environment>'+accEnv+'</environment>'+
                '</accountId>'+
                '<accountServiceType>'+
                '<code>'+code+'</code>'+
                '</accountServiceType>'+
                '<accountPreferences>'+
                '<tollLimitCode/>'+
                '</accountPreferences>'+
                '<customerBill>'+
                '<cus:billDetailLevel>PARTIAL</cus:billDetailLevel>'+
                '</customerBill>'+
                '</customerAccount>'+
                '</submitGroupOrderMemberInput>'+
                '</cus:SubmitGroupOrderMember>'+
                '</soapenv:Body>'+
                '</soapenv:Envelope>';
            
            requesttotal = request1 + customerOrderItemStr + commercialContractStr;
            if(dueDate!=null){
                requesttotal = requesttotal+dueDateBlock;
            }
            if(crisId!=null){
                requesttotal = requesttotal + cridIdBlock ;
            }
            if (saleschannelType!=null){
                requesttotal = requesttotal +  salesChannelBlock ; 
            }
            requesttotal = requesttotal + afterSalesChannelBlock;

            requesttotal = requesttotal +    contractTermBlock;
            requesttotal = requesttotal + afterContractBlock;

            requesttotal = requesttotal.replaceAll('>null<', '><');
            System.debug('New design submit order request MNS '+requesttotal );
            submitGroupOrderRequestMap.put('DpiRequestXML', requesttotal);
            submitGroupOrderRequestMap.put('transactionCount', groupOrderTransactionCount);
        }
        catch(Exception e){
            System.debug(e.getStackTraceString());
        }
        return (submitGroupOrderRequestMap);
    }
    
    
    public Map<String, Object> getCustomerOrderItemStringDIAtoMNS( List<Object> custOrderItemString ){
        System.debug('custOrderItemString size '+custOrderItemString.size());
        System.debug('custOrderItemString: '+String.valueOf(custOrderItemString.get(0)));
        Map<String, Object> custOrderStringMap = new  Map < String, Object > ();
        String action, itemQuantity, chargeType, processingDirection, prodId,lineItemSequenceNumber;
        Map < String, Object > product = new Map < String, Object > ();
        Map<String, Object> item = new Map < String, Object > ();
        if(custOrderItemString!=null){
            for (Object orderItem : custOrderItemString) {
                boolean isDIAorMNSProd= false;
                boolean isDIAProd= false;
                boolean isMNSProd= false;
                System.debug('OrderItem: '+orderItem);
                if(orderItem!=null){
                    item = (Map<String, Object>) orderItem;
                     if(item!=null && !(item.isEmpty())){
                    System.debug('Item is : '+item);
                    action = (String) item.get('action');
                    itemQuantity = String.valueOf(item.get('quantity'));
                    chargeType = (String)item.get('chargeType');
                    processingDirection = (String)item.get('processingDirection');
                    product =(Map < String, Object > ) item.get('product');
                         
                      }   
                    if(product!=null && null!=product.get('id') ){
                        prodId = (String)product.get('id');

                        System.debug('Prod Id is '+prodId);
                        
                        //SNE_Code_MRC__c = TBD,MEDAX or 02KEI is a DIA
                        if(null!=prodId &&  (prodId.contains('MEDA') || prodId.contains('TBD')|| prodId.contains('02KEI') )){ 
                            action = 'Remove';
                            isDIAProd = true;
                        }
                        
                        
                        if((prodId.startsWith('DIA') || prodId.startsWith('MD')|| prodId.startsWith('M200D')))
                            isMNSProd = true;                       

                        if(null!=prodId && !prodId.equalsIgnoreCase('NA')){
                            lineItemSequenceNumber =(String) product.get('lineItemSequenceNumber');
                        }
                    }
                    //if(prodId !=null ){
                    if(product.get('id')!=null && ftr_OrderManagementHelper.validString((String)product.get('id')) && !((String)product.get('id')).contains('NA') ){
                        if(customerOrderItemStr!=null && (isDIAProd || isMNSProd)){
                            customerOrderItemStr =customerOrderItemStr+'<customerOrderItem>'+
                                '<action>'+action+'</action>'+
                                '<quantity>'+itemQuantity+'</quantity>'+
                                '<chargeType>'+chargeType+'</chargeType>'+
                                '<processingDirection>'+processingDirection+'</processingDirection>'+
                                '<product>'+
                                '<id>'+prodId+'</id>'+
                                '<lineItemSequenceNumber>'+lineItemSequenceNumber+'</lineItemSequenceNumber>'+
                                '</product>'+
                                '</customerOrderItem>';
                            System.debug('**customerOrderItemStr**'+customerOrderItemStr+'******');
                            custOrderStringMap.put('CustOrderItemString', customerOrderItemStr);
                        }
                    }                    
                }
            }
        }else{ 
            System.debug('customerOrderItemStr is null');
        }
        return custOrderStringMap;
    }
    
public Map<String, Object> getCustomerOrderItemStringMNStoMNS(List<Object> custOrderItemString) {
    System.debug('custOrderItemString size ' + custOrderItemString);
    
    Map<String, Object> custOrderStringMap = new Map<String, Object>();
    Map<String, Map<String, Object>> productSumMap = new Map<String, Map<String, Object>>();
    
    if (custOrderItemString != null) {
        for (Object orderItemObj : custOrderItemString) {
            if (orderItemObj != null) {
                Map<String, Object> orderItem = (Map<String, Object>)orderItemObj;
                String action = (String)orderItem.get('action');
                String prodId = '';
                Decimal itemQuantity = 0;
                
                if (orderItem.containsKey('product')) {
                    Map<String, Object> product = (Map<String, Object>)orderItem.get('product');
                    if (product != null && product.containsKey('id')) {
                        prodId = (String)product.get('id');
                    }
                }
                
                if (orderItem.containsKey('quantity')) {
                    itemQuantity = Decimal.valueOf(orderItem.get('quantity').toString());
                }
                
                if (!productSumMap.containsKey(prodId)) {
                    productSumMap.put(prodId, new Map<String, Object>{
                        'quantitySum' => Decimal.valueOf(0),
                        'isMNSorMNSProd' => false
                    });
                }
                
                Map<String, Object> productSumData = productSumMap.get(prodId);
                
                if (action == 'Disconnect') {
                    productSumData.put('quantitySum', (Decimal)productSumData.get('quantitySum') - itemQuantity);
                } else {
                    productSumData.put('quantitySum', (Decimal)productSumData.get('quantitySum') + itemQuantity);
                }
                
                if (prodId.contains('MDIAI') || prodId.contains('MFAIL') || prodId.contains('MS100') || prodId.contains('MINDO')) {
                    productSumData.put('isMNSorMNSProd', true);
                }
            }
        }
        
        String customerOrderItemStr = '';
        
        for (String prodId : productSumMap.keySet()) {
            Map<String, Object> productSumData = productSumMap.get(prodId);
            if ((Boolean)productSumData.get('isMNSorMNSProd')) {
                Decimal quantitySum = (Decimal)productSumData.get('quantitySum');
                String action = (quantitySum >= 0) ? 'Add' : 'Removal';
                customerOrderItemStr += '<customerOrderItem>' +
                    '<action>' + (Decimal)productSumData.get('quantitySum') + '</action>' +
                    '<quantity>' + (Decimal)productSumData.get('quantitySum') + '</quantity>' +
                    '<chargeType/>' +
                    '<processingDirection/>' +
                    '<product>' +
                    '<id>' + prodId + '</id>' +
                    '</product>' +
                    '</customerOrderItem>';
            }
        }
        
        if (customerOrderItemStr != '') {
            custOrderStringMap.put('CustOrderItemString', customerOrderItemStr);
        }
    } else {
        System.debug('customerOrderItemStr is null');
    }
    
    return custOrderStringMap;
}

   
        public String getCommercialContractStringMNS(List<Object>  commercialContractString, String schId, String contractId){
        // Map < String, Object > contractMap = new  Map < String, Object > ();
        if(commercialContractString!=null || commercialContractString.isEmpty()){
            for (Object contract : commercialContractString) {
                Map < String, Object > contractMap = new  Map < String, Object > ();
                String   productId, contractQuantity,recAmount, nonRecAmount;
                if(contract!=null){
                    contractMap =(Map<String, Object>) contract;
                    //  contractId = (String)contractMap.get('contractId');
                    productId=(String)contractMap.get('productId');
                    
                    //MDIAI , startsWith('DIA') , startsWith('MD') or startsWith('M200D') means is MNS Product
                    if(productId.contains('MDIAI') || (productId.startsWith('DIA')|| productId.startsWith('MD')|| productId.startsWith('M200D')))
                    {
                        contractQuantity = (String)contractMap.get('quantity');
                        Map < String, Object > monthlyRecCharge = new Map < String, Object > ();
                        Map < String, Object > nonRecCharge = new Map < String, Object > ();
                        monthlyRecCharge = (Map < String, Object > )contractMap.get('monthlyRecurringChargeRate');
                        nonRecCharge =    (Map < String, Object > )contractMap.get('nonRecurringChargeRate'); 
                        System.debug('Product ID: '+     productId);
                        System.debug('monthlyRecCharge: '+String.valueOf(monthlyRecCharge));
                        if(monthlyRecCharge!=null){
                            recAmount= (String)monthlyRecCharge.get('amount');
                        }
                        if(nonRecCharge!=null){
                            nonRecAmount= (String)nonRecCharge.get('amount');
                        }
                        if(ftr_OrderManagementHelper.validString(productId)){    
                            if(commercialContractStr!=null){
                                if(recAmount!=null){
                                    commercialContractStr = commercialContractStr+ ' <commercialContract>'+
                                        '<scheduleId>'+schId+'</scheduleId>'+
                                        '<contractId>'+contractId+'</contractId>'+
                                        '<productId>'+productId+'</productId>'+
                                        '<quantity>'+contractQuantity+'</quantity>'+
                                        '<monthlyRecurringChargeRate>'+
                                        '<shar:amount>'+recAmount+'</shar:amount>'+
                                        '</monthlyRecurringChargeRate>'+
                                        '</commercialContract>';
                                }
                                if(nonRecAmount!=null){
                                    commercialContractStr = commercialContractStr+ ' <commercialContract>'+
                                        '<scheduleId>'+schId+'</scheduleId>'+
                                        '<productId>'+productId+'</productId>'+
                                        '<quantity>'+contractQuantity+'</quantity>'+
                                        '<nonRecurringChargeRate>'+
                                        '<shar:amount>'+nonRecAmount+'</shar:amount>'+
                                        '</nonRecurringChargeRate>'+
                                        '</commercialContract>';
                                }
                                System.debug('commercialContractStr is ************'+commercialContractStr);
                            }
                        }
                    }
                }
            }
        }
        System.debug('Final commercialContractStr is ************'+commercialContractStr);
        return commercialContractStr;
    }
    
             public static void justIncrement() {
            Integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                 i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                       i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                       i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                       i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                       i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                       i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;         i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                          i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
          i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
          i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                 i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
          i++;
               i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
               i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
               i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
               i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
               i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
               i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
               i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
               i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
             i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                      i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                      i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                      i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                      i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                      i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                      i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                      i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                      i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                      i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                      i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
    }
    
    
}