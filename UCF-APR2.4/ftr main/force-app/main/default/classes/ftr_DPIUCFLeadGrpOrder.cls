global class ftr_DPIUCFLeadGrpOrder extends ftr_DPIUCFSystemInterface{

    
     Map<String, Object> getCustOrderItemMap = new  Map<String, Object> ();
     private static String correlationId;
     String accTelNumber ='';
     String customerOrderItemStr ='';
     String commercialContractStr = '' ;
     public static String didType =''; 
     List<OrderItem> orderItemCommercialContract = new List<OrderItem>();
     DIDTypeSettings__c DPISettings = DIDTypeSettings__c.getInstance();
    
    
      global override String getOrchestrationTaskName() {
        System.debug('Task Name returned-->'+TaskName_DPIUCFLeadSubmitGroupOrder);
        return TaskName_DPIUCFLeadSubmitGroupOrder;
    }
    
    
    global override Object createDPIRequestType(String url, String path, Map<String, Object> input) {
        
        //Construct the Request Object to Invoke SubmitGroupOrderMember DPI API
        //return this with SubmitGroupOrderMember request
        Map<String, Object> submitGroupOrderRequest = createESBSubmitGroupOrderMapping(url, path, input);
        return (submitGroupOrderRequest);
    }
    
    
     global override Map<String, Object> processDPIResponseType(String url, String path, Object respType) {
        
        Map<String,Object> submitGroupOrderResponseMap = new Map<String,Object>();
        String response = String.valueOf(respType);
        System.debug('Response:' + response);
        if (respType != null && !Test.isRunningTest()){
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
                submitGroupOrderResponseMap.put('correlationId', correlationId);
                submitGroupOrderResponseMap.put('CreateTask', 'Yes');
               
            }
            else{
                System.debug('Operation status false, response is '+response);
                String severity,operationStatusCode,operationStatusDescription, errorcode ;
                //To Do - ExecutionStatusMessage is an array, need to be handled later. 
                String executionStatusParent = response.substring(response.indexOf('<executionStatusMessage>'),response.indexOf('</executionStatusMessage>'));
                severity =  executionStatusParent.substring(executionStatusParent.indexOf('<severity>')+('<severity>').length(),executionStatusParent.indexOf('</severity>'));      
                operationStatusCode = executionStatusParent.substring(executionStatusParent.indexOf('<operationStatusCode>')+('<operationStatusCode>').length(),executionStatusParent.indexOf('</operationStatusCode>'));
                errorCode = severity + ' | '+ operationStatusCode;
                operationStatusDescription =  executionStatusParent.substring(executionStatusParent.indexOf('<operationStatusDescription>')+('<operationStatusDescription>').length(),executionStatusParent.indexOf('</operationStatusDescription>'));
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
                if(executionStatusChild.indexOf('<executionStatusChild>')!=-1){ operationStatusDescription = operationStatusDescription+ executionStatusChild.substring(executionStatusChild.indexOf('<operationStatusDescription>')+('<operationStatusDescription>').length(),executionStatusChild.indexOf('</operationStatusDescription>') ); }
                executionStatusParent = response.substring(response.indexOf('</executionStatusMessage>')+('<executionStatusMessage>').length());
                System.debug('second executionStatusParent :'+executionStatusParent);
                executionStatusChild  = executionStatusParent.substring(executionStatusParent.indexOf('<executionStatusMessage>')+('<executionStatusMessage>').length());
                System.debug('second executionStatusChild :'+executionStatusChild);
                do{
                    if(executionStatusChild.indexOf('<severity>')!=-1) { severity = errorCode +' | ' + executionStatusChild.substring(executionStatusChild.indexOf('<severity>')+('<severity>').length(), executionStatusChild.indexOf('</severity>') ); }
                    System.debug('severity inside 2nd while :'+severity);
                    if(executionStatusChild.indexOf('<operationStatusCode>')!=-1) { operationStatusCode = severity + ' | '+executionStatusChild.substring(executionStatusChild.indexOf('<operationStatusCode>')+('<operationStatusCode>').length(),executionStatusChild.indexOf('</operationStatusCode>') ); }
                    if(executionStatusChild.indexOf('<operationStatusDescription>')!=-1) { operationStatusDescription = operationStatusDescription + ' | ' +executionStatusChild.substring(executionStatusChild.indexOf('<operationStatusDescription>')+('<operationStatusDescription>').length(),executionStatusChild.indexOf('</operationStatusDescription>') ); }
                    executionStatusChild=executionStatusChild.substring(executionStatusChild.indexOf('<executionStatusMessage>')+('<executionStatusMessage>').length() -1);
                } while(executionStatusChild.indexOf('<executionStatusMessage>') != -1);
                submitGroupOrderResponseMap.put('errorCode', errorCode); 
                if(operationStatusDescription.contains('Failure') ||operationStatusDescription.contains('RUN09034')  || operationStatusDescription.contains('clientGroupIdentifier') ) { operationStatusDescription = 'The telephone numbers previously reserved for this order are either used by different account or the correlation id needs to be fixed. Please open a case for IT.'; }        
                submitGroupOrderResponseMap.put('errorMessage', operationStatusDescription); 
                System.debug(' Error Map : '+ submitGroupOrderResponseMap);
            }
        }
        else{
            System.debug('Response is null');
        }
        return submitGroupOrderResponseMap;
        
        
    }
    
    
      public Map<String, Object> createESBSubmitGroupOrderMapping(String url, String path, Map<String, Object> input){ 
        System.debug('Input to CreateDPIRequestType: '+JSON.serialize(input));
        Map<String, String> submitGroupOrderRequestMap =new Map<String, String> ();
        List<Object> customerOrderProductSNE = new List<Object>();
        List<Object> commercialContractProductSNE = new List<Object>();
        Final String SalesChannelCode_TTL = '217';
        String requesttotal,billCycle, streetAddress,streetNumber,streetName,cityName,stateAbbreviation, streetSuffix,zipCode,addressLine1, addressLine3, country, intcityName,stateOrProvince,postalCode,tradingName; 
        String OrgLocCityName,  orgStreetAdd , orgstateAbbr, orgZipCode, origLoc,termLoc, saleschannelType, contractTerm,soldOn, salesChannelPartnerId, crisId, organizationType,businessOwner, technicalContact,billToContact, managerName,techContactNum, billingContactTelephone, businessOwnerTelephone;
        Boolean isInternationalAddress;
        //String salesChannelBlock;
        try{
            
            Map<String, String> submitGroupOrderResponseMap = null;
            Map < String, Object > SubmitGroupOrderMember = (Map < String, Object > ) input.get('SubmitGroupOrderMember');
            System.debug('SubmitGroupOrderMember :'+SubmitGroupOrderMember);
            Map < String, Object > SubmitGroupOrderMemberInput = (Map < String, Object > ) SubmitGroupOrderMember.get('submitGroupOrderMemberInput');
            String scheduleId = (String)SubmitGroupOrderMemberInput.get('scheduleId');
            String contractId = (String)SubmitGroupOrderMemberInput.get('ContractId');
            String orderNumber = (String)SubmitGroupOrderMemberInput.get('OrderNumber');
            String HotCutUserName = (String)SubmitGroupOrderMemberInput.get('HotCutUserName');
            String AEName = (String)SubmitGroupOrderMemberInput.get('AEName');
           

            // Getting List Of OrderItem For SNE Code to make the customerOrder and Commercial Contract

          /*  List<OrderItem> orderItemCommercialContract = [Select Id,SNE_Code_MRC__c,SNE_Code_OTC__c,SNE_Code_TERM__c,Quantity,vlocity_cmt__EffectiveQuantity__c,
                                                           vlocity_cmt__RecurringCharge__c,vlocity_cmt__Product2Id__r.vlocity_cmt__SpecificationSubType__c,
                                                           vlocity_cmt__OneTimeCharge__c,vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__Product2Id__r.vlocity_cmt__SubType__c,
                                                           vlocity_cmt__Product2Id__r.VendorName__c,vlocity_cmt__Product2Id__r.Family,vlocity_cmt__Product2Id__r.vlocity_cmt__Type__c
                                                           from OrderItem where Order.OrderNumber =:orderNumber]; */
            


            if(contractId!=null && contractId.length()>15){ 
                contractId=contractId.substring(0, 14);
            }
            String circuitId = (String)SubmitGroupOrderMemberInput.get('circuitId');
            if(ftr_OrderManagementHelper.validString((String)SubmitGroupOrderMemberInput.get('InternationalBillAddress'))){    
                isInternationalAddress = Boolean.valueOf(SubmitGroupOrderMemberInput.get('InternationalBillAddress'));
            }
           
            
           
            String groupOrderTransactionCount =(String)SubmitGroupOrderMemberInput.get('groupOrderTransactionCount') ;
            Map < String, Object > header =(Map < String, Object > ) SubmitGroupOrderMemberInput.get('header');
            //(String)header.get('correlationId');
            Map < String, Object > customerOrder =(Map < String, Object > ) SubmitGroupOrderMemberInput.get('customerOrder');
            String customerOrderType = (String)customerOrder.get('customerOrderType');
            String installationType = (String)customerOrder.get('installationType');
            System.debug('custOrderItemString ::: 2378'+(List<Object>) customerOrder.get('customerOrderItem'));
            List<Object> custOrderItemString =    (List<Object>) customerOrder.get('customerOrderItem');
            
            Map<String,Object> customerLocation = (Map < String, Object > ) SubmitGroupOrderMemberInput.get('customerLocation');
            String locationContactName = (String)customerLocation.get('Name');
            String locationPhone  = (String)customerLocation.get('Phone');
            if (locationPhone.startsWith('1') && locationPhone.length() > 10) {
                locationPhone = locationPhone.substring(1);
            }
            
            String remark    = (String)customerLocation.get('Remark');
            String locationType    = (String)customerLocation.get('Type');
            // 
            
            // Ring Central Work For Product SNE's 
          /*  if(!orderItemCommercialContract.isEmpty()){

                customerOrderProductSNE = getCustomerOrderItemBySNE(orderItemCommercialContract);
                commercialContractProductSNE = getCommercialContractItemBySNE(orderItemCommercialContract);
                

            } */
            
           

          
         /*   if(!customerOrderProductSNE.isEmpty()){
                getCustOrderItemMap = (Map < String, Object > )getCustomerOrderItemString(customerOrderProductSNE);
                customerOrderItemStr = (String)getCustOrderItemMap.get('CustOrderItemString');
            } */
           // String prodId = (String)getCustOrderItemMap.get('ProdId');
          
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
            String updatedDueDate;
            if(dueDate!=null){
                List<String> dueDateConvert = dueDate.split(' ');
                
                updatedDueDate = dueDateConvert[0]+'T00:00:00';
            }
            
           
            /*if(!commercialContractProductSNE.isEmpty()){
                
                commercialContractStr = getCommercialContractString(commercialContractProductSNE, scheduleId, contractId);
            } */
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
           
            // Lead DID Works
            
            String DIDLocationId = (String)customerAccountJson.get('DIDLocationId');
            String serviceAccountId = (String)customerAccountJson.get('serviceAccountId');
            String ItemId = (String)customerAccountJson.get('ItemId');
           
            
            // Getting the Main Item from where able to create the Commercial OR CustomerOrder
            System.debug('ItemId :::::'+ItemId);
            List<OrderItem> didItem = [Select Id,UCF_DID_Numbers__c,UCF_DID_Order_Items__c,DID_Type__c from OrderItem where Id=:ItemId]; 
            System.debug('didItem :::::'+didItem);
            List<String> phones = new List<String>();
            List<String> OrderItemsId = new List<String>();
            Set<String> fetchOrderItemsId = new Set<String>();
            for(OrderItem ord:didItem){
                 System.debug('UCF_DID_Numbers__c :::::'+ord.UCF_DID_Numbers__c);
                 System.debug('UCF_DID_Order_Items__c :::::'+ord.UCF_DID_Order_Items__c);
                 if(ord.UCF_DID_Numbers__c !=null){
                    phones = ord.UCF_DID_Numbers__c.split(',');
                  }
                    if(ord.UCF_DID_Order_Items__c !=null){
                         OrderItemsId = ord.UCF_DID_Order_Items__c.split(',');
                    }
                 
                  didType = ord.DID_Type__c;
            }

           System.debug('Numbers :::::'+phones);
           System.debug('OrderItemIds ::::::'+OrderItemsId);
            
            if(didType == DPISettings.AutoAttendantNew__c || didType == DPISettings.AutoAttendantPortIn__c){
                
               System.debug('orderNumber ::::::'+orderNumber);
               orderItemCommercialContract = [Select Id,SNE_Code_MRC__c,SNE_Code_OTC__c,SNE_Code_TERM__c,Quantity,vlocity_cmt__EffectiveQuantity__c,
                                                           vlocity_cmt__RecurringCharge__c,vlocity_cmt__Product2Id__r.vlocity_cmt__SpecificationSubType__c,
                                                           vlocity_cmt__OneTimeCharge__c,vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__Product2Id__r.vlocity_cmt__SubType__c,
                                                           vlocity_cmt__Product2Id__r.VendorName__c,vlocity_cmt__Product2Id__r.Family,vlocity_cmt__Product2Id__r.vlocity_cmt__Type__c
                                                           from OrderItem where Order.OrderNumber =: orderNumber And vlocity_cmt__ServiceAccountId__c =: serviceAccountId
                                                           AND vlocity_cmt__Product2Id__r.ProductCode =: DPISettings.UCF_Auto_Attendant_Code__c]; 
                System.debug('orderItemCommercialContract ::::::'+orderItemCommercialContract);
            }else if(didType == DPISettings.Vacant_Spare_Additional_DID_New__c || didType == DPISettings.Vacant_Spare_Additional_DID_PortIn__c){
                
                    orderItemCommercialContract = [Select Id,SNE_Code_MRC__c,SNE_Code_OTC__c,SNE_Code_TERM__c,Quantity,vlocity_cmt__EffectiveQuantity__c,
                                                           vlocity_cmt__RecurringCharge__c,vlocity_cmt__Product2Id__r.vlocity_cmt__SpecificationSubType__c,
                                                           vlocity_cmt__OneTimeCharge__c,vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__Product2Id__r.vlocity_cmt__SubType__c,
                                                           vlocity_cmt__Product2Id__r.VendorName__c,vlocity_cmt__Product2Id__r.Family,vlocity_cmt__Product2Id__r.vlocity_cmt__Type__c
                                                           from OrderItem where Order.OrderNumber =: orderNumber And vlocity_cmt__ServiceAccountId__c =: serviceAccountId
                                                           AND vlocity_cmt__Product2Id__r.ProductCode =: DPISettings.UCF_Additional_DID__c]; 
                System.debug('orderItemCommercialContract ::::::'+orderItemCommercialContract);
            }else if(didType == DPISettings.New_DID_Range__c || didType == DPISettings.Port_In__c){
            
             orderItemCommercialContract = [Select Id,SNE_Code_MRC__c,SNE_Code_OTC__c,SNE_Code_TERM__c,Quantity,vlocity_cmt__EffectiveQuantity__c,
                                                           vlocity_cmt__RecurringCharge__c,vlocity_cmt__Product2Id__r.vlocity_cmt__SpecificationSubType__c,
                                                           vlocity_cmt__OneTimeCharge__c,vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__Product2Id__r.vlocity_cmt__SubType__c,
                                                           vlocity_cmt__Product2Id__r.VendorName__c,vlocity_cmt__Product2Id__r.Family,vlocity_cmt__Product2Id__r.vlocity_cmt__Type__c
                                                           from OrderItem where Id IN: OrderItemsId];
                
            
            }else if((didType == DPISettings.Multi_Line_Hunt_Group_Pilot_PortIn__c || didType == DPISettings.Multi_Line_Hunt_Group_Pilot_New__c) ||  (didType == DPISettings.General_Voice_Mail_New__c || didType == DPISettings.General_Voice_Mail_PortIn__c)){
                   System.debug('didType :::::: IN'+didType);
                   customerOrderProductSNE = getMHLGAndGVSNE(didType);
            }
            
            if(!orderItemCommercialContract.isEmpty()){
               System.debug('OrderItemIds :::::: IN'+orderItemCommercialContract);
                customerOrderProductSNE = getCustomerOrderItemBySNE(orderItemCommercialContract);
                commercialContractProductSNE = getCommercialContractItemBySNE(orderItemCommercialContract);
            }
            
            if(!customerOrderProductSNE.isEmpty()){
                getCustOrderItemMap = (Map < String, Object > )getCustomerOrderItemString(customerOrderProductSNE);
                customerOrderItemStr = (String)getCustOrderItemMap.get('CustOrderItemString');
            }
            
            if(!commercialContractProductSNE.isEmpty()){
                
                commercialContractStr = getCommercialContractString(commercialContractProductSNE, scheduleId, contractId);
            }
            
            Map < String, Object > accountIdJson = (Map < String, Object > )customerAccountJson.get('accountId');
            if(!phones.isEmpty()){
                
                 Map < String, Object >  accTelephoneNumberJson = (Map < String, Object > )accountIdJson.get('telephoneNumber');
                // String accTelNumber = (String)accTelephoneNumberJson.get('telephoneNumber'); // WTN Number
                 accTelNumber = phones[0];
             }
        
            
            
                correlationId =  orderNumber+'.'+accTelNumber;
            
              
            String accEnv = (String)accountIdJson.get('environment');
            Map < String, Object > billingAccountIdJson = (Map < String, Object > )customerAccountJson.get('billingAccountId');
            Map < String, Object >  billingTelephoneJson = (Map < String, Object > )billingAccountIdJson.get('telephoneNumber'); 
            String billTelNumber = (String) billingTelephoneJson.get('telephoneNumber');
           
            Map < String, Object >  accountServiceTypeJson = (Map < String, Object > )customerAccountJson.get('accountServiceType');
            String code = (String)accountServiceTypeJson.get('code');
            Map < String, Object >  accountPreferencesJson =(Map < String, Object > ) customerAccountJson.get('accountPreferences');
            String billHandlingCode = (String)accountPreferencesJson.get('billHandlingCode') ;
            String tollLimitCode = (String)accountPreferencesJson.get('tollLimitCode');
            Map < String, Object >  customerBillJson =(Map < String, Object > ) customerAccountJson.get('CustomerBill');
            String billDetailLevel =(String) customerBillJson.get('billDetailLevel');
            billCycle = (String) customerBillJson.get('BillCycle');
            Map < String, Object >  taxProfileJson = (Map < String, Object > )customerAccountJson.get('taxProfile');
            String isFederalTaxExempt =(String) taxProfileJson.get('isFederalTaxExempt');
            Map < String, Object >  custAccLocationJson = (Map < String, Object > )customerAccountJson.get('location');
            Map < String, Object > serviceAddrJson = (Map < String, Object > )custAccLocationJson.get('serviceAddress');
            System.debug('custAccLocationJson : '+custAccLocationJson);
            Map < String, Object > serviceAddrMasterIdJson = (Map < String, Object > )serviceAddrJson.get('serviceAddressMaterId');
            String cityAbbr =  (String)serviceAddrJson.get('cityAbbreviation') ;    
            String controlNumber, environment,sequenceNumber;
            System.debug('serviceAddrMasterIdJson : '+serviceAddrMasterIdJson);
            if(serviceAddrMasterIdJson!=null){
                controlNumber = (String)serviceAddrMasterIdJson.get('controlNumber') ;
                sequenceNumber =(String) serviceAddrMasterIdJson.get('sequenceNumber');
            }
            Map < String, Object > addressJson = (Map < String, Object > )serviceAddrJson.get('address');
            streetAddress = (String)addressJson.get('streetAddress');
            System.debug('streetAddress : '+streetAddress);
            streetNumber= streetAddress.substringBefore(' ');
            // preDirectional='S';
            streetName= streetAddress.substringAfter(' ');
            if(streetName!=null && streetName.length()>20){
                streetName = streetName.substring(0,19);  
            }
            streetSuffix =(String)addressJson.get('streetSuffix');
            cityName=(String)addressJson.get('cityName');
            stateAbbreviation =(String)addressJson.get('stateAbbreviation');
            zipCode =(String)addressJson.get('zipCode');
            String plus4 = (String)addressJson.get('plus4');
            termLoc = streetAddress+' '+ cityName +' ' +stateAbbreviation;
            termLoc = termLoc.replaceAll('null', '');
            Map < String, Object > customerJson = (Map < String, Object > )SubmitGroupOrderMemberInput.get('customer');
            Map < String, Object > individualJson =(Map < String, Object > ) customerJson.get('individual');
            if(individualJson!=null){
                String socialSecurityNumber =(String) individualJson.get('socialSecurityNumber');
                String dateOfBirth = (String) individualJson.get('dateOfBirth');
            }
            Map < String, Object > organizationJson = (Map < String, Object > )customerJson.get('organization');
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
            Map < String, Object > custCreditProfileJson = (Map < String, Object > )customerJson.get('customerCreditProfile');
            Map < String, Object > custCreditProfileReferenceJson = (Map < String, Object > )custCreditProfileJson.get('creditProfileReference');
            Map < String, Object > landlordJson = (Map < String, Object > )custCreditProfileReferenceJson.get('landlord');
            String landlordName,landLordTelNum;
            if(landlordJson!=null){
                landlordName = (String)landlordJson.get('name');
                landLordTelNum =(String)landlordJson.get('telephoneNumber');
            }
            Map < String, Object > businessJson =(Map < String, Object > ) custCreditProfileReferenceJson.get('business');
           organizationType = (String)businessJson.get('organizationType');
          
            Map < String, Object > businessOwnerJson =(Map < String, Object > ) custCreditProfileReferenceJson.get('businessOwner');
            if(businessOwnerJson!=null){
                businessOwner = (String)businessOwnerJson.get('name');
                businessOwnerTelephone = (String)businessOwnerJson.get('number');
            }
            Map < String, Object > managerJson =(Map < String, Object > ) custCreditProfileReferenceJson.get('manager');
            if(managerJson!=null){
                managerName = (String)managerJson.get('name');
            }
            Map < String, Object > techContactJson =(Map < String, Object > ) custCreditProfileReferenceJson.get('TechnicalContact');
            
            if(techContactJson!=null){
                technicalContact = (String)techContactJson.get('Name');
                techContactNum = (String)techContactJson.get('telephone');
            }
            Map < String, Object > billContactJson =(Map < String, Object > ) custCreditProfileReferenceJson.get('BillToContact');
            Map < String, Object > billingContactJson = (Map < String, Object > ) custCreditProfileReferenceJson.get('BillingContact');
            if(billContactJson!=null){
                billToContact = (String)billContactJson.get('Name');
                System.debug('Billtocontact :'+billToContact);
                billingContactTelephone =  (String)billContactJson.get('telephone');
            }
            
            
            Map < String, Object > creditScoreJson = (Map < String, Object > )custCreditProfileJson.get('creditScore');
            String creditRating ;
            if(creditScoreJson!=null){
                creditRating = (String)creditScoreJson.get('creditRating');
            }
            String customerType = (String)customerJson.get('customerType');
            String memoText = 'SF Order # '+OrderNumber+'/ AE: '+AEName+'/ SC: '+HotCutUserName+'/ Contract Length '+contractTerm;

            System.debug('commercialContractStr is ********'+commercialContractStr);
            String request1 = '<soapenv:Envelope '+'xmlns:'+'soapenv="http://schemas.xmlsoap.org/soap/envelope/" '+'xmlns:cus="http://esb.frontier.com/CustomerOrderManagement" '+'xmlns:'+'shar="'+ 'http://esb.frontier.com/sharedType" '+'xmlns:'+'xsi="xsi">'+
                '<soapenv:Header/>'+
                '<soapenv:Body>'+
                '<cus:SubmitGroupOrderMember>'+
                '<submitGroupOrderMemberInput>'+
                '<header>'+ //correlationId
                '<shar:correlationId>'+correlationId+'</shar:correlationId>'+
                '<shar:requestingApplication>VlocityOM</shar:requestingApplication>'+
                
                '<securityInfo>'+
                '<userId>ftrqacomm</userId>'+
                '<employeeId>825280</employeeId>'+
                '</securityInfo>'+
                '</header>'+
                '<groupOrderTransactionCount>'+'1'+'</groupOrderTransactionCount>'+
                '<customerOrder>'+
                '<customerOrderType>'+installationType+'</customerOrderType>'+
                '<memo>'+ '<templateName>*FREE</templateName>'+
                 '<section>'+'<sectionName>*NONE</sectionName>'+
                '<text>'+memoText+'</text>'+
                  '</section>'+'</memo>';
              
            String dueDateBlock =  '<dueDate>'+updatedDueDate+'</dueDate>'+
                 '<salesChannelPartnerId>'+salesChannelPartnerId+'</salesChannelPartnerId>'+
                '<actionReason>'+'01'+'</actionReason>'+
                '<customerWillAdviseFlag>'+'false'+'</customerWillAdviseFlag>';
            String cridIdBlock =  '<soldBy>'+
                '<id>'+crisId+'</id>'+ 
                '</soldBy>';
            String salesChannelBlock =  '<saleschannelType>'+
                '<code>' + saleschannelType + '</code>'+ 
                '</saleschannelType>';
             
            String afterSalesChannelBlock = '<provisioningDetails>'+
                '<telephoneProvisioning>'+
                '<intraLata>'+
                '<preferredCarrierId>VOIP</preferredCarrierId>'+
                '<acceptsThirdPartyCalls>false</acceptsThirdPartyCalls>'+
                '<acceptsCollectCalls>false</acceptsCollectCalls>'+
                '<sourceCode>X</sourceCode>'+
                '</intraLata>'+
                '<interLata>'+
                '<preferredCarrierId>VOIP</preferredCarrierId>'+
                '<acceptsThirdPartyCalls>false</acceptsThirdPartyCalls>'+
                '<acceptsCollectCalls>false</acceptsCollectCalls>'+
                '<sourceCode>X</sourceCode>'+
                '</interLata>'+
                '</telephoneProvisioning>'+
                '</provisioningDetails>'+
                '<marketingProgram>BUSINESS</marketingProgram>';
            
            String appointment = '<appointment>'+'<businessTimePeriod>'+'<shar:startDate>'+updatedDueDate+'</shar:startDate>'+
                '</businessTimePeriod>'+'<calendarEntry>'+'<status>'+'Open'+'</status>'+'</calendarEntry>'+
                '<contact>'+'<name>'+technicalContact+'</name>'+'<telephoneNumber>'+
                '<telephoneNumber>'+techContactNum+'</telephoneNumber>'+'<type>'+
                 locationType+'</type>'+'</telephoneNumber>'+
                '</contact>'+'<remark>'+remark+'</remark>'+
                '</appointment>';
            
            String contractTermBlock =   '<contract>'+
                '<Term>'+
                '<termInMonths>'+contractTerm+'</termInMonths>'+
                '</Term>'+
                '<offer>'+
                '<soldOn>'+soldOn+'</soldOn>'+
                '</offer>'+
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
                '<tollLimitCode>'+'E'+'</tollLimitCode>'+
                '</accountPreferences>'+
                '<customerBill>'+
                '<cus:billDetailLevel>'+'Partial'+'</cus:billDetailLevel>';
            
            String afterCustomerBillBlock = '</customerBill>'+
                '<taxProfile>'+
                '<isFederalTaxExempt>'+isFederalTaxExempt+'</isFederalTaxExempt>'+
                '</taxProfile>'+
                '<location>'+
                '<serviceAddress>'+
                '<serviceAddressMaterId>'+
                '<controlNumber>'+controlNumber+'</controlNumber>'+
                '<sequenceNumber>1</sequenceNumber>'+
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
                '<directory>'+'<delivery>'+'<directoryLabelQuantity>'+
                '<amount>'+'0'+'</amount>'+
                '</directoryLabelQuantity>'+'</delivery>'+
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
            // String intAddrLine3Block='<addressLine3>'+addressLine3+'</addressLine3>';
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
                '<dunsNumber>'+'0'+'</dunsNumber>'+
                '</business>';
            String busOwnerBlock =  '<businessOwner>'+
                '<name>'+billToContact+'</name>'+
                '<telephoneNumber>'+billingContactTelephone+'</telephoneNumber>'+
                '</businessOwner>';
            // String creditProfileMgrBlock =  '<manager>'+
            // '<name>'+managerName+'</name>'+
            // '</manager>';
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
                '<customerRefusedToProvideSSN>'+'false'+'</customerRefusedToProvideSSN>'+
                '</cus:customerCreditProfile>'+
                '<cus:customerType>Business</cus:customerType>'+
                '</customer>'+
                '</submitGroupOrderMemberInput>'+
                '</cus:SubmitGroupOrderMember>'+
                '</soapenv:Body>'+
                '</soapenv:Envelope>';
            
            requesttotal = request1 + customerOrderItemStr + commercialContractStr;
           
           
            
            if (saleschannelType!=null){
                requesttotal = requesttotal +  salesChannelBlock ; 
            }
          
            requesttotal = requesttotal + afterSalesChannelBlock;
            
            
            requesttotal = requesttotal +    contractTermBlock;
            
            if(appointment !=null){
                requesttotal = requesttotal + appointment;
            }
            
            requesttotal = requesttotal + afterContractBlock;
            
            requesttotal = requesttotal + afterCustomerBillBlock;
             
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
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
        }
        return (submitGroupOrderRequestMap);
    }
    
     public List<Object> getCustomerOrderItemBySNE(List<OrderItem> orderItemCommercialContract) {
        List<Object> finalist = new List<Object>(); 
        String chargeType = 'Permanent';
        String lineItemSeq = '0';
        String direction = 'Forward';
        System.debug('::::: orderItemCommercialContract 123'+orderItemCommercialContract);    
        if (!orderItemCommercialContract.isEmpty()) {
            for (OrderItem ord : orderItemCommercialContract) {
                
               
                if (!String.isBlank(ord.SNE_Code_MRC__c)) {
                        chargeType = 'Temporary';
                    
                      finalist.add(createMapItem(ord.SNE_Code_MRC__c, lineItemSeq, direction, chargeType, ord));
                    }
             
            }
            if(didType == DPISettings.AutoAttendantNew__c  || didType == DPISettings.Vacant_Spare_Additional_DID_New__c || didType == DPISettings.AutoAttendantPortIn__c || 
               didType == DPISettings.Vacant_Spare_Additional_DID_PortIn__c){
                
                finalist.add(createMapItem(DPISettings.DPI_Products_VP911__c, lineItemSeq, direction,'Temporary', null));
                finalist.add(createMapItem(DPISettings.DPI_Products_ILC67__c, lineItemSeq, direction,'Temporary', null));
                
               }else if(didType == DPISettings.Port_In__c || didType == DPISettings.New_DID_Range__c){
                    finalist.add(createMapItem(DPISettings.DPI_Products_VP911__c, lineItemSeq, direction,'Temporary', null));
               }
         }
              System.debug('::::: finalist'+finalist);
            return finalist;
    }
    
    public List<Object> getMHLGAndGVSNE(String didType){
        
        System.debug('::::: finalist'+didType);
         List<Object> finalist = new List<Object>(); 
         String chargeType = 'Permanent';
         String lineItemSeq = '0';
         String direction = 'Forward';
        
          if(didType == DPISettings.General_Voice_Mail_New__c || didType == DPISettings.General_Voice_Mail_PortIn__c){
                
                finalist.add(createMapItem(DPISettings.DPI_Products_VP911__c, lineItemSeq, direction,'Temporary', null));
                finalist.add(createMapItem(DPISettings.DPI_Products_ILC67__c, lineItemSeq, direction,'Temporary', null));
                finalist.add(createMapItem(DPISettings.DPI_Product_General_Voice__c, lineItemSeq, direction,'Temporary', null));
                
            }else if(didType == DPISettings.Multi_Line_Hunt_Group_Pilot_New__c || didType == DPISettings.Multi_Line_Hunt_Group_Pilot_PortIn__c){
                
                finalist.add(createMapItem(DPISettings.DPI_Products_VP911__c, lineItemSeq, direction,'Temporary', null));
                finalist.add(createMapItem(DPISettings.DPI_Products_ILC67__c, lineItemSeq, direction,'Temporary', null));
                finalist.add(createMapItem(DPISettings.Multi_Hunt_Line_Product__c, lineItemSeq, direction,'Temporary', null));
                
            }
        
          System.debug('::::: finalist'+finalist);
          return finalist;
    }
    public List<Object> getCommercialContractItemBySNE(List<OrderItem> orderItemCommercialContract) {
    List<Object> finalist = new List<Object>();
    Integer quantity = 1;
    if (orderItemCommercialContract != null && !orderItemCommercialContract.isEmpty()) { 
        for (OrderItem ord : orderItemCommercialContract) {
            
            if (!String.isBlank(ord.SNE_Code_MRC__c)) {
                
                
                finalist.add(createMapItem(ord.SNE_Code_MRC__c, quantity, ord.vlocity_cmt__RecurringCharge__c, null));      
            }
            
        }
    }
        System.debug(':::: CommmercialFinalList'+finalist);
    return finalist;
}  
    
    private Map<String, Object> createMapItem(String productId, Integer quantity, Decimal recurringChargeAmount, Decimal oneTimeChargeAmount) {
    Map<String, Object> mapItem = new Map<String, Object>();
    Map<String, Object> recurringChargeRate = new Map<String, Object>();
    Map<String, Object> nonRecurringChargeRate = new Map<String, Object>();

    mapItem.put('productId', productId);
    mapItem.put('quantity', String.valueOf(quantity));
    // mapItem.put('quantity', quantity);
    if (recurringChargeAmount != null) {
        recurringChargeRate.put('amount', String.valueOf(recurringChargeAmount));
        mapItem.put('monthlyRecurringChargeRate', recurringChargeRate);
    }

    if (oneTimeChargeAmount != null) {
        nonRecurringChargeRate.put('amount', String.valueOf(oneTimeChargeAmount));
        mapItem.put('nonRecurringChargeRate', nonRecurringChargeRate);
    }

    return mapItem;
}

     public Map<String, Object> getCustomerOrderItemString( List<Object> custOrderItemString ){
        System.debug('custOrderItemString size '+custOrderItemString.size());
        System.debug('custOrderItemString values'+custOrderItemString);
        System.debug('custOrderItemString: '+String.valueOf(custOrderItemString.get(0)));
        Map<String, Object> custOrderStringMap = new  Map < String, Object > ();
        String action, itemQuantity, chargeType, processingDirection, prodId,lineItemSequenceNumber;
        Map < String, Object > product = new Map < String, Object > ();
        Map<String, Object> item = new Map <String, Object > ();
        if(custOrderItemString!=null){
            for (Object orderItem : custOrderItemString) {
                System.debug('OrderItem: '+orderItem);
                if(orderItem!=null){
                    item = (Map<String, Object>) orderItem;
                    // if(item!=null || !item.isEmpty()){
                    System.debug('Item is : '+item);
                    action =(String) item.get('action');
                    itemQuantity = String.valueOf(item.get('quantity'));
                    chargeType = (String)item.get('chargeType');
                    processingDirection = (String)item.get('processingDirection');
                    product =(Map < String, Object > ) item.get('product');
                    //  }   
                    if(product!=null){
                        prodId = (String)product.get('id');
                        if(prodId.equalsIgnoreCase('ADUNI')){
                            custOrderStringMap.put('ProdId', prodId);
                        }
                        System.debug('Prod Id is '+prodId);
                        lineItemSequenceNumber =(String) product.get('lineItemSequenceNumber');
                    }
                    //if(prodId !=null ){
                    if(ftr_OrderManagementHelper.validString(prodId) && !prodId.contains('NA')){
                        if(customerOrderItemStr!=null){
                            customerOrderItemStr =customerOrderItemStr+'<customerOrderItem>'+
                                '<action>'+action+'</action>'+
                                '<quantity>'+itemQuantity+'</quantity>'+
                                '<chargeType>'+chargeType+'</chargeType>'+
                                '<processingDirection>'+processingDirection+'</processingDirection>'+
                                '<product>'+
                                '<id>'+prodId+'</id>'+
                                '<lineItemSequenceNumber>'+'0'+'</lineItemSequenceNumber>'+
                                '</product>'+
                                '</customerOrderItem>';
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
        System.debug('commercialContractString'+commercialContractString);
        
        if(commercialContractString!=null || commercialContractString.isEmpty()){
            System.debug('commercialContractString I am IN:::'+commercialContractString);
            System.debug('commercialContractString I am IN:::1'+schId);
            System.debug('commercialContractString I am IN:::2'+contractId);
            for (Object contract : commercialContractString) {
                System.debug('commercialContractString I am IN:::6');
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
                    System.debug('recAmount: '+recAmount);
                    System.debug('nonRecAmount: '+nonRecAmount);
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
                                    '<contractId>'+contractId+'</contractId>'+
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
  
    private Map<String, Object> createMapItem(String productId, String lineItemSeq, String direction, String chargeType, OrderItem ord) {
    Map<String, Object> mapItem = new Map<String, Object>();
    Map<String, Object> mapProduct = new Map<String, Object>();

    mapProduct.put('id', productId);
    mapItem.put('action', 'Add');
    mapItem.put('lineItemSequenceNumber', '0');
    if(didType == DPISettings.AutoAttendantNew__c || didType == DPISettings.New_DID_Range__c || didType == DPISettings.Multi_Line_Hunt_Group_Pilot_PortIn__c || didType == DPISettings.Port_In__c || didType == DPISettings.General_Voice_Mail_New__c || didType == DPISettings.General_Voice_Mail_PortIn__c || didType == DPISettings.Multi_Line_Hunt_Group_Pilot_New__c || didType == DPISettings.AutoAttendantPortIn__c ||didType == DPISettings.Vacant_Spare_Additional_DID_New__c || didType == DPISettings.Vacant_Spare_Additional_DID_PortIn__c){
         mapItem.put('quantity',1.00);
    }
     else{
        mapItem.put('quantity',ord.Quantity);
    }
    

    mapItem.put('processingDirection', direction);
    mapItem.put('chargeType', chargeType);
    mapItem.put('product', mapProduct);

    return mapItem;
}


}