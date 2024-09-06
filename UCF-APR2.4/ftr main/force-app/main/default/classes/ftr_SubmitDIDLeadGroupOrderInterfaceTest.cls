
@isTest
public class ftr_SubmitDIDLeadGroupOrderInterfaceTest {
    @TestSetup
    static void makeData(){
        
        Integer numOfOrchItems = 1;
        Map<String,String> prodNameCodeMap = new Map<String,String>{
            'DPI DID LeadOrder Billing RFS' => 'DID_DPI_LEAD_ORDER_RFS_0010'
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
        
        l1.executeItem('','',item);
        Test.stopTest();
    }

    /* @isTest
    static void test2() {
        String url = '';
       	String path = ''; 
        String testJsonInput = '{"SubmitGroupOrderMember":{"submitGroupOrderMemberInput":{"customerAccount":{"location":{"serviceAddress":{"serviceAddressMaterId":{"controlNumber":"620372"},"address":{"zipCode":"75062","streetAddress":"100 East Airport Freeway","cityName":"Irving","plus4":"75062"},"cityAbbreviation":"IRV"}},"billingAccountId":{"telephoneNumber":{"telephoneNumber":"8321510008"}},"taxProfile":{"isFederalTaxExempt":"false"},"accountServiceType":{"code":"65"},"accountPreferences":{"billHandlingCode":"M"},"accountId":{"telephoneNumber":{"telephoneNumber":"8321510008"},"environment":"FT"},"CustomerBill":{"billDetailLevel":"PARTIAL","BillCycle":"null"}},"header":{"securityInfo":{"userId":"lsg522","employeeId":"lsg522"},"requestingApplication":"VlocityOM","correlationId":"10030431.8321510009"},"poOrder":null,"groupOrderTransactionCount":"2","circuitSNE":"CKT","circuitId":"13/CUXP/541477/   /FTNC/   ","customer":{"organization":{"contactInformation":{"internationalAddress":{"stateOrProvince":"TX","postalCode":"75077","country":"United States","cityName":"Lewisville","addressLine1":"1480 North Valley Parkway"}},"organizationName":{"tradingName":"AK Technical Test Company"}},"customerType":"Business","customerCreditProfile":{"creditScore":{"creditRating":"3"},"creditProfileReference":{"businessOwner":{"name":"Tom Cruise"},"business":{"organizationType":"Sole Ownership"},"TechnicalContact":{"Name":"Tom Cruise"},"BillToContact":{"Name":"Tom Cruise"}}}},"customerOrder":{"provisioningDetails":{"commercialCircuitProvisioning":{"OrgLocZipCode":"75062","OrgLocStreetAddress":"100 East Airport Freeway","OrgLocStateAbbreviation":null,"OrgLocCityName":"Irving"}},"customerOrderItem":[{"product":{"lineItemSequenceNumber":"1","id":"MEDAL"},"chargeType":"Permanent","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"SSINS"},"chargeType":"Temporary","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"EIA2Y"},"chargeType":"Permanent","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"BNR23"},"chargeType":"Temporary","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"BIP23"},"chargeType":"Permanent","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"NA"},"chargeType":"Permanent","processingDirection":"Forward","quantity":"1.00","action":"Add"},{"product":{"lineItemSequenceNumber":"1","id":"CKT"},"chargeType":"Permanent","processingDirection":"Forward","quantity":"1.00","action":"Add"},null],"commercialContract":[{"monthlyRecurringChargeRate":{"amount":"880.00"},"quantity":"1","productId":"MEDAL"},{"nonRecurringChargeRate":{"amount":"250.00"},"quantity":"1","productId":"SSINS"},null],"installationType":"NO_INSTALL","dueDate":"2021-04-10","customerOrderType":"INSTALL","Quantity":1,"crisId":"838810"},"scheduleId":"S-5550011781","InternationalBillAddress":"false","ContractId":"8001g0000003dyrAAA"}}}}';

        Map<String, Object> input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
        
        ftr_SubmitDIDLeadGroupOrderInterface service = new ftr_SubmitDIDLeadGroupOrderInterface();
        service.getOrchestrationTaskName();
        service.createDPIRequestType(url, path, input);
        service.processDPIResponseType(url, path, input);
    } */
}