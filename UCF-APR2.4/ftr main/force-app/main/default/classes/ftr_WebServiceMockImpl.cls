global class ftr_WebServiceMockImpl implements WebServiceMock {
    
    global void doInvoke(  
        Object stub,  
        Object request,  
        Map<string, object> response,  
        String endpoint,  
        String soapAction,  
        String requestName,  
        String responseNS,  
        String responseName,  
        String responseType) {  
            System.debug('Type :'+requestName);
            System.debug('Type :'+endpoint);
            /**  ftr_Resourcemanagement MOCK */
            if(requestName.equalsIgnoreCase('RetrieveCustomerFacilities')){
                ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_element respElement = new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_element();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                ftr_Resourcemanagement.msg_RetrieveCustomerFacilitiesResponse facResp = new ftr_Resourcemanagement.msg_RetrieveCustomerFacilitiesResponse();
                ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_CustomerFacilities[] customerFacilityList = new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_CustomerFacilities[]{};
                ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_CustomerFacilities customerFacility = new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_CustomerFacilities();
                ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_Location location = new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_Location();
                ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_ServiceAddress serviceAddress = new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_ServiceAddress();
                ftr_Sharedtype.ServiceAddressMasterId serviceAddressMasterId = new ftr_Sharedtype.ServiceAddressMasterId();
                
                serviceAddressMasterId.controlNumber = 247415;
                serviceAddressMasterId.sequenceNumber = 3;
                serviceAddressMasterId.environment = 'CA';

                location.serviceAddress = serviceAddress;

                serviceAddress.serviceAddressMasterId = serviceAddressMasterId;
                serviceAddress.cityAbbreviation = 'NDL';

                customerFacility.location = location;
                customerFacility.wireCenter = '971301';
                customerFacilityList.add(customerFacility);
                
                facResp.header = header;
                facResp.customerFacilities = customerFacilityList;
                respElement.RetrieveCustomerFacilitiesOutput = facResp;
                response.put('response_x', respElement);
            }
            // *ftr_Resourcemanagement.ReserveTelephoneNumberResponse_element
            else if(requestName.equalsIgnoreCase('ReserveTelephoneNumber')){
                ftr_Resourcemanagement.ReserveTelephoneNumberResponse_element respElement = new ftr_Resourcemanagement.ReserveTelephoneNumberResponse_element();
                ftr_Resourcemanagement.msg_ReserveTelephoneNumberResponse reserveTelephoneNumberOutput = new ftr_Resourcemanagement.msg_ReserveTelephoneNumberResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                ftr_Sharedtype.ExecutionStatusMessage executionStatusMessage = new ftr_Sharedtype.ExecutionStatusMessage();
                executionStatusMessage.operationStatusCode = '000-000-0000';
                header.operationStatus = 'TRUE';
                header.executionStatusMessage = executionStatusMessage;
                reserveTelephoneNumberOutput.header = header;
                respElement.reserveTelephoneNumberOutput = reserveTelephoneNumberOutput;
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('findAvailableTelephoneNumbers')){
                ftr_Resourcemanagement.FindAvailableTelephoneNumbersResponse_element respElement = new ftr_Resourcemanagement.FindAvailableTelephoneNumbersResponse_element();
                ftr_Resourcemanagement.msg_FindAvailableTelephoneNumbersResponse findAvailableTelephoneNumbersOutput = new ftr_Resourcemanagement.msg_FindAvailableTelephoneNumbersResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                findAvailableTelephoneNumbersOutput.header = header;
                respElement.findAvailableTelephoneNumbersOutput = findAvailableTelephoneNumbersOutput;
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('RetrieveHuntGroupDetails')){
                ftr_Resourcemanagement.RetrieveHuntGroupDetailsResponse_element respElement = new ftr_Resourcemanagement.RetrieveHuntGroupDetailsResponse_element();
                ftr_Resourcemanagement.msg_RetrieveHuntGroupDetailsResponse retrieveHuntGroupDetailsOutput = new ftr_Resourcemanagement.msg_RetrieveHuntGroupDetailsResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                retrieveHuntGroupDetailsOutput.header = header;
                respElement.retrieveHuntGroupDetailsOutput = retrieveHuntGroupDetailsOutput;
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('RetrieveServiceDesign')){
                ftr_Resourcemanagement.RetrieveServiceDesignResponse_element respElement = new ftr_Resourcemanagement.RetrieveServiceDesignResponse_element();
                ftr_Resourcemanagement.msg_RetrieveServiceDesignResponse retrieveServiceDesignOutput = new ftr_Resourcemanagement.msg_RetrieveServiceDesignResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                retrieveServiceDesignOutput.header = header;
               	respElement.retrieveServiceDesignOutput = retrieveServiceDesignOutput;
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('GeneratePasscode')){
                ftr_Resourcemanagement.GeneratePasscodeResponse_element respElement = new ftr_Resourcemanagement.GeneratePasscodeResponse_element();
                ftr_Resourcemanagement.msg_GeneratePasscodeResponse generatePasscodeOutput = new ftr_Resourcemanagement.msg_GeneratePasscodeResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                generatePasscodeOutput.header = header;
               	respElement.generatePasscodeOutput = generatePasscodeOutput;
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('RetrievePreferredExchange')){
                ftr_Resourcemanagement.RetrievePreferredExchangeResponse_element respElement = new ftr_Resourcemanagement.RetrievePreferredExchangeResponse_element();
                ftr_Resourcemanagement.msg_RetrievePreferredExchangeResponse retrievePreferredExchangeOutput = new ftr_Resourcemanagement.msg_RetrievePreferredExchangeResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                retrievePreferredExchangeOutput.header = header;
               	respElement.retrievePreferredExchangeOutput = retrievePreferredExchangeOutput;
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('RetrieveCustomerFacilitiesSummary')){
                ftr_Resourcemanagement.RetrieveCustomerFacilitiesSummaryResponse_element respElement = new ftr_Resourcemanagement.RetrieveCustomerFacilitiesSummaryResponse_element();
                ftr_Resourcemanagement.msg_RetrieveCustomerFacilitiesSummaryResponse retrieveCustomerFacilitiesSummaryOutput = new ftr_Resourcemanagement.msg_RetrieveCustomerFacilitiesSummaryResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                retrieveCustomerFacilitiesSummaryOutput.header = header;
               	respElement.retrieveCustomerFacilitiesSummaryOutput = retrieveCustomerFacilitiesSummaryOutput;
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('ReleaseTelephoneNumber')){
                ftr_Resourcemanagement.ReleaseTelephoneNumberResponse_element respElement = new ftr_Resourcemanagement.ReleaseTelephoneNumberResponse_element();
                ftr_Resourcemanagement.msg_ReleaseTelephoneNumberResponse releaseTelephoneNumberOutput = new ftr_Resourcemanagement.msg_ReleaseTelephoneNumberResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                releaseTelephoneNumberOutput.header = header;
               	respElement.releaseTelephoneNumberOutput = releaseTelephoneNumberOutput;
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('SynchronizePlantDetails')){
                ftr_Resourcemanagement.SynchronizePlantDetailsResponse_element respElement = new ftr_Resourcemanagement.SynchronizePlantDetailsResponse_element();
                ftr_Resourcemanagement.msg_SynchronizePlantDetailsResponse synchronizePlantDetailsOutput = new ftr_Resourcemanagement.msg_SynchronizePlantDetailsResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                synchronizePlantDetailsOutput.header = header;
               	respElement.synchronizePlantDetailsOutput = synchronizePlantDetailsOutput;
                response.put('response_x', respElement);
            }
             else if(requestName.equalsIgnoreCase('ValidatePasscode')){
                ftr_Resourcemanagement.ValidatePasscodeResponse_element respElement = new ftr_Resourcemanagement.ValidatePasscodeResponse_element();
                ftr_Resourcemanagement.msg_ValidatePasscodeResponse validatePasscodeOutput = new ftr_Resourcemanagement.msg_ValidatePasscodeResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                validatePasscodeOutput.header = header;
               	respElement.validatePasscodeOutput = validatePasscodeOutput;
                response.put('response_x', respElement);
            }
             else if(requestName.equalsIgnoreCase('RetrieveCustomerFacilityHistory')){
                ftr_Resourcemanagement.RetrieveCustomerFacilityHistoryResponse_element respElement = new ftr_Resourcemanagement.RetrieveCustomerFacilityHistoryResponse_element();
                ftr_Resourcemanagement.msg_RetrieveCustomerFacilityHistoryResponse RetrieveCustomerFacilityHistoryOutput = new ftr_Resourcemanagement.msg_RetrieveCustomerFacilityHistoryResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                RetrieveCustomerFacilityHistoryOutput.header = header;
               	respElement.RetrieveCustomerFacilityHistoryOutput = RetrieveCustomerFacilityHistoryOutput;
                response.put('response_x', respElement);
            }
             else if(requestName.equalsIgnoreCase('findCircuit')){
                ftr_Resourcemanagement.findCircuitResponse_element respElement = new ftr_Resourcemanagement.findCircuitResponse_element();
                ftr_Resourcemanagement.msg_FindCircuitResponse findCircuitOutput = new ftr_Resourcemanagement.msg_FindCircuitResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                findCircuitOutput.header = header;
               	respElement.findCircuitOutput = findCircuitOutput;
                response.put('response_x', respElement);
            }
             else if(requestName.equalsIgnoreCase('RetrieveTelephoneNumberHistory')){
                ftr_Resourcemanagement.RetrieveTelephoneNumberHistoryResponse_element respElement = new ftr_Resourcemanagement.RetrieveTelephoneNumberHistoryResponse_element();
                ftr_Resourcemanagement.msg_RetrieveTelephoneNumberHistoryResponse retrieveTelephoneNumberHistoryOutput = new ftr_Resourcemanagement.msg_RetrieveTelephoneNumberHistoryResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                retrieveTelephoneNumberHistoryOutput.header = header;
               	respElement.retrieveTelephoneNumberHistoryOutput = retrieveTelephoneNumberHistoryOutput;
                response.put('response_x', respElement);
            }
             else if(requestName.equalsIgnoreCase('UpdateCustomerVoiceMailDetails')){
                ftr_Resourcemanagement.UpdateCustomerVoiceMailDetailsResponse_element respElement = new ftr_Resourcemanagement.UpdateCustomerVoiceMailDetailsResponse_element();
                ftr_Resourcemanagement.msg_UpdateCustomerVoiceMailDetailsResponse UpdateCustomerVoiceMailDetailsOutput = new ftr_Resourcemanagement.msg_UpdateCustomerVoiceMailDetailsResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                UpdateCustomerVoiceMailDetailsOutput.header = header;
               	respElement.UpdateCustomerVoiceMailDetailsOutput = UpdateCustomerVoiceMailDetailsOutput;
                response.put('response_x', respElement);
            }
             else if(requestName.equalsIgnoreCase('FindEmailAccounts')){
                ftr_Resourcemanagement.FindEmailAccountsResponse_element respElement = new ftr_Resourcemanagement.FindEmailAccountsResponse_element();
                ftr_Resourcemanagement.msg_FindEmailAccountsResponse findEmailAccountsOutput = new ftr_Resourcemanagement.msg_FindEmailAccountsResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                findEmailAccountsOutput.header = header;
               	respElement.findEmailAccountsOutput = findEmailAccountsOutput;
                response.put('response_x', respElement);
            }
             else if(requestName.equalsIgnoreCase('FindLocalLoop')){
                ftr_Resourcemanagement.FindLocalLoopResponse_element respElement = new ftr_Resourcemanagement.FindLocalLoopResponse_element();
                ftr_Resourcemanagement.msg_FindLocalLoopResponse findLocalLoopOutput = new ftr_Resourcemanagement.msg_FindLocalLoopResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                findLocalLoopOutput.header = header;
               	respElement.findLocalLoopOutput = findLocalLoopOutput;
                response.put('response_x', respElement);
            }
             else if(requestName.equalsIgnoreCase('IsFrontierEmailAddressAvailable')){
                ftr_Resourcemanagement.IsFrontierEmailAddressAvailableResponse_element respElement = new ftr_Resourcemanagement.IsFrontierEmailAddressAvailableResponse_element();
                ftr_Resourcemanagement.msg_IsFrontierEmailAddressAvailableResponse isFrontierEmailAddressAvailableOutput = new ftr_Resourcemanagement.msg_IsFrontierEmailAddressAvailableResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                isFrontierEmailAddressAvailableOutput.header = header;
               	respElement.isFrontierEmailAddressAvailableOutput = isFrontierEmailAddressAvailableOutput;
                response.put('response_x', respElement);
            }
             else if(requestName.equalsIgnoreCase('FindAvailableTelephoneNumbers')){
                ftr_Resourcemanagement.FindAvailableTelephoneNumbersResponse_element respElement = new ftr_Resourcemanagement.FindAvailableTelephoneNumbersResponse_element();
                ftr_Resourcemanagement.msg_FindAvailableTelephoneNumbersResponse findAvailableTelephoneNumbersOutput = new ftr_Resourcemanagement.msg_FindAvailableTelephoneNumbersResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                findAvailableTelephoneNumbersOutput.header = header;
               	respElement.findAvailableTelephoneNumbersOutput = findAvailableTelephoneNumbersOutput;
                response.put('response_x', respElement);
            }
             else if(requestName.equalsIgnoreCase('RetrieveEmailAccountDetails')){
                ftr_Resourcemanagement.RetrieveEmailAccountDetailsResponse_element respElement = new ftr_Resourcemanagement.RetrieveEmailAccountDetailsResponse_element();
                ftr_Resourcemanagement.msg_RetrieveEmailAccountDetailsResponse retrieveEmailAccountDetailsOutput = new ftr_Resourcemanagement.msg_RetrieveEmailAccountDetailsResponse();
                ftr_Sharedtype.ResponseHeader header = new ftr_Sharedtype.ResponseHeader();
                header.operationStatus = 'TRUE';
                retrieveEmailAccountDetailsOutput.header = header;
               	respElement.retrieveEmailAccountDetailsOutput = retrieveEmailAccountDetailsOutput;
                response.put('response_x', respElement);
            }
        }  
}