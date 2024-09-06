//test
@isTest
public class ftr_DPIBaseBillingSystemInterfaceTest {
    @TestSetup
    static void makeData(){
        Integer numOfOrchItems = 1;

        Map<String,String> prodNameCodeMap = new Map<String,String>{
            'DPI DID LeadOrder Billing RFS' => 'DID_DPI_LEAD_ORDER_RFS_0010',
            'SIP TRUNKING DPI BILLING RESOURCE SPEC' => 'SIP_TRUNKING_DPI_BILLING_RES_SPEC_0010',
            'DPI CIRCUIT BILLING RESOURCE SPEC' => 'DPI_CIRCUIT_BILLING_RES_SPEC_0010',
            'DPI DID MDN Billing RFS' => 'DID_DPI_MDN_RFS_0010',
			'DPI DID Bulk Billing RFS' => 'DPI_Bulk_Billing_RFS'

        };
        List<vlocity_cmt__OrchestrationItem__c> orchItemsList = ftr_TestDataFactory.getOrchestrationItems(numOfOrchItems, prodNameCodeMap);
        System.debug('orchItemsList = ' + orchItemsList);
        insert orchItemsList;
        ftr_TestDataFactory.getAttributesWithCategory();

        // insert response DR
        vlocity_cmt__DRBundle__c  dtb= new vlocity_cmt__DRBundle__c ();
        dtb.Name = 'DRM6LoadAddServiceItemL1Response';
        dtb.vlocity_cmt__DRMapName__c='DRM6LoadAddServiceItemL1Response';
        dtb.vlocity_cmt__InterfaceObject__c='json';
        insert dtb;
 
    }
    
    @isTest
    static void submitDIDLeadGroupTest(){
        System.debug('SubmitDIDLeadGroupOrder getting the orch item');
        
        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c, vlocity_cmt__NumberOfRetries__c FROM vlocity_cmt__OrchestrationItem__c WHERE Name = 'SubmitDIDLeadGroupOrder' LIMIT 1];
        
        System.Debug('orch item = ' + item);
        System.debug('SubmitDIDLeadGroupOrderTest Line 37');
        Test.setMock(HttpCalloutMock.class, new ftr_SubmitGroupMemberOrderMock());
        ftr_SubmitDIDLeadGroupOrderInterface l1 = new ftr_SubmitDIDLeadGroupOrderInterface();
        System.debug('Starting the test');
        Test.startTest();
        l1.startBatch('', '');
        l1.executeItem('','',item);
        l1.endBatch('', '');
        Test.stopTest();
    }
    
    /*@isTest
    static void submitMDNGroupOrderMemberTest(){
        String url = '';
       	String path = ''; 
        String testJsonInput = '{"SubmitGroupOrderMember":{"submitGroupOrderMemberInput":{"header":{"correlationId":"10103610.5855321464","requestingApplication":"VlocityOM","securityInfo":{"userId":"ftrqacomm","employeeId":825280}},"groupOrderTransactionCount":"1","customerOrder":{"customerOrderType":"INSTALL","salesChannelPartnerId":"","customerOrderItem":[{"action":"Add","quantity":1,"chargeType":"Permanent","processingDirection":"Forward","product":{"id":"BTNCH","lineItemSequenceNumber":"1"}},{"action":"Add","quantity":"1","chargeType":"Parmanent","processingDirection":"Forward","product":{"id":"720","lineItemSequenceNumber":"1"}},{"action":"Add","quantity":"1","chargeType":"Temporary","processingDirection":"Forward","product":{"id":"F1BT2","lineItemSequenceNumber":"1"}},{"action":"Add","quantity":"1","chargeType":"Permanent","processingDirection":"Forward","product":{"id":"SIPTE","lineItemSequenceNumber":"1"}}],"scheduleId":"S-5550088682","contractId":"8007b000001Dvq","productId":"SIPTE","quantity":"","commercialContract":[{"scheduleId":"S-5550088682","contractId":"8007b000001Dvq","productId":"BTNCH","quantity":"50","monthlyRecurringChargeRate":{"amount":"0"},"nonRecurringChargeRate":{"amount":"15"}},{"scheduleId":"S-5550088682","contractId":"8007b000001Dvq","productId":"SIPTE","quantity":"","monthlyRecurringChargeRate":{"amount":"19.99"},"nonRecurringChargeRate":{"amount":"15"}},{"scheduleId":"S-5550088682","contractId":"8007b000001Dvq","productId":"F1BT2","quantity":"8","monthlyRecurringChargeRate":{"amount":"0"},"nonRecurringChargeRate":{"amount":"15"}}],"dueDate":"2023-09-09","soldBy":{"id":"404849"},"provisioningDetails":{"commercialCircuitProvisioning":{"orderStageCode":"***"}},"marketingProgram":"BUSINESS","contract":{"term":{"termInMonths":"36"},"offer":{"soldOn":"2023-05-19 00:00:00","standardMarketingPackageId":"1"},"Id":"8007b000001Dvq","type":"CIR","scheduleId":"S-5550088682","marketingPackage":"BUSINESS"}},"customerAccount":{"accountId":{"telephoneNumber":{"telephoneNumber":"5855302140"},"environment":"LR"},"billingAccountId":{"telephoneNumber":{"telephoneNumber":"5855302140"}},"accountServiceType":{"code":""},"accountPreferences":{"billHandlingCode":"M","tollLimitCode":""},"CustomerBill":{"billDetailLevel":"PARTIAL","BillCycle":"3"},"taxProfile":{"isFederalTaxExempt":"false"},"location":{"serviceAddress":{"serviceAddressMaterId":{"controlNumber":"233654","sequenceNumber":"1"},"cityAbbreviation":"","address":{"streetNumber":"120","streetName":"North Plymouth Aven","streetSuffix":"","cityName":"Rochester","stateAbbreviation":"","zipCode":"14608"}}},"directory":{"delivery":{"directoryLabelQuantity":{"amount":"0"}},"directoryListingType":"NR","directoryListingAllowance":0}},"InternationalBillAddress":"true","customer":{"organization":{"organizationName":{"tradingName":"Travels"},"contactInformation":{"internationalAddress":{"addressLine1":"8001 West Jefferson Boulevard","cityName":"Fort Wayne","stateOrProvince":"IN","postalCode":"46804"}}},"customerCreditProfile":{"creditProfileReference":{"businessOwner":{"name":"Some One","telephoneNumber":"1234567890"},"billingContact":{"name":"Some One","telephoneNumber":"1234567890"},"technicalContact":{"name":"Some One","telephoneNumber":"1234567890"}},"creditScore":{"creditRating":"3"}},"customerType":"Business"}}}}';
        String testJsonOutput = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:snv="http://www.webserviceX.NET" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Header/><soapenv:Body><bons2:SubmitGroupOrderMemberResponse xmlns:bons030="http://esb.frontier.com/sharedType" xmlns:bons2="http://esb.frontier.com/CustomerOrderManagement"><submitGroupOrderMemberOutput><response><bons030:correlationId>10087697.8171970273</bons030:correlationId><bons030:requestingApplication>VlocityOM</bons030:requestingApplication><forEsbUseOnly><trackingId>6c3328ac-264a-4432-b895-e16f61f96480</trackingId><correlationId>6c3328ac-264a-4432-b895-e16f61f96480</correlationId></forEsbUseOnly><operationStatus>TRUE</operationStatus><executionStatusMessage><severity>INFO</severity><service>CustomerOrderManagement</service><operation>SubmitGroupOrderMember</operation><operationStatusCode>000-000-0000</operationStatusCode><operationStatusDescription>Success</operationStatusDescription><executionStatusMessage><severity>INFO</severity><service>API_SubmitOrderManager</service><operation>submitGroupOrderMember</operation><operationStatusCode>0</operationStatusCode><operationStatusDescription>L/626436/QPGMR/RUN09192</operationStatusDescription></executionStatusMessage> </response><leadOrderId><orderNumber>082793470</orderNumber><environment>FT</environment></leadOrderId><groupMemberOrderId><orderNumber>082793471</orderNumber><environment>FT</environment></groupMemberOrderId></submitGroupOrderMemberOutput></bons2:SubmitGroupOrderMemberResponse></soapenv:Body></soapenv:Envelope>';
        String convertedJson = '{"transactionCount":null,"CreateTask":"Yes","GroupMemberOrderId":"005871693","LeadOrderId":"005871693"}';
        Map<String, Object> input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
        Object output = (Object)JSON.deserializeUntyped(convertedJson);

        ftr_DPISIPMDNSubmitGroupOrderMembInterf service = new ftr_DPISIPMDNSubmitGroupOrderMembInterf();
        service.getOrchestrationTaskName();
        service.createDPIRequestType( url, path, input);
        service.processDPIResponseType(url, path, testJsonOutput);
    }*/
    @isTest
    static void submitMDNGroupOrderMemberTest(){
        System.debug('SubmitMDNGroupOrderMember getting the orch item'); 
        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c, vlocity_cmt__NumberOfRetries__c FROM vlocity_cmt__OrchestrationItem__c WHERE Name = 'SubmitMDNGroupOrderMember' LIMIT 1]; 
        System.Debug('orch item = ' + item); 
        System.debug('SubmitMDNGroupOrderMember Line 37'); 
        Test.setMock(HttpCalloutMock.class, new ftr_SubmitGroupMemberOrderMock()); 
        ftr_DPISIPMDNSubmitGroupOrderMembInterf l1 = new ftr_DPISIPMDNSubmitGroupOrderMembInterf(); 
        System.debug('Starting the test'); 
        Test.startTest(); 
        l1.startBatch('', ''); 
        l1.executeItem('','',item); 
        l1.endBatch('', '');   
        Test.stopTest(); 
    }
	/*@isTest
    static void submitGroupOrderMemberTest(){
        System.debug('SubmitGroupOrderMember getting the orch item'); 
        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c, vlocity_cmt__NumberOfRetries__c FROM vlocity_cmt__OrchestrationItem__c WHERE Name = 'SubmitGroupOrderMember' LIMIT 1]; 
        System.Debug('orch item = ' + item); 
        System.debug('SubmitGroupOrderMember Line 37'); 
        Test.setMock(HttpCalloutMock.class, new ftr_SubmitGroupMemberOrderMock()); 
        ftr_DPISubmitGroupOrderMemberInterface l1 = new ftr_DPISubmitGroupOrderMemberInterface(); 
        System.debug('Starting the test'); 
        Test.startTest(); 
        l1.startBatch('', ''); 
        l1.executeItem('','',item); 
        l1.endBatch('', '');   
        Test.stopTest(); 
    }*/
    @isTest 
      static void submitDIDBulkGroupOrderTest(){ 
        System.debug('SubmitDIDBulkGroupOrder getting the orch item'); 
        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c, vlocity_cmt__NumberOfRetries__c FROM vlocity_cmt__OrchestrationItem__c WHERE Name = 'SubmitDIDBulkGroupOrder' LIMIT 1]; 
        System.Debug('orch item = ' + item); 
        System.debug('SubmitDIDBulkGroupOrderTest Line 37'); 
        Test.setMock(HttpCalloutMock.class, new ftr_SubmitGroupMemberOrderMock()); 
        ftr_SubmitDIDBulkGroupOrderInterface l1 = new ftr_SubmitDIDBulkGroupOrderInterface(); 
        System.debug('Starting the test'); 
        Test.startTest(); 
        l1.startBatch('', ''); 
        l1.executeItem('','',item); 
        l1.endBatch('', '');   
        Test.stopTest(); 
    } 
     
    //ANNIE
    
    ///
    
    /*@isTest
    static void submitDIDBulkGroupOrderTest(){
        System.debug('SubmitDIDBulkGroupOrder getting the orch item');
        
        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c, vlocity_cmt__NumberOfRetries__c FROM vlocity_cmt__OrchestrationItem__c WHERE Name = 'SubmitDIDBulkGroupOrder' LIMIT 1];
        
        System.Debug('orch item = ' + item);
        System.debug('SubmitDIDBulkGroupOrderTest Line 37');
        Test.setMock(HttpCalloutMock.class, new ftr_SubmitGroupMemberOrderMock());
        ftr_SubmitDIDBulkGroupOrderInterface l1 = new ftr_SubmitDIDBulkGroupOrderInterface();
        System.debug('Starting the test');
        Test.startTest();
        l1.startBatch('', '');
        l1.executeItem('','',item);
        l1.endBatch('', '');  
        Test.stopTest();
    }*/

     static testmethod void testIncrement() {
        Test.startTest();
        ftr_DPIBaseBillingSystemInterface.justIncrement();
        Test.stopTest(); 
 }
}