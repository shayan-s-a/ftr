/**
 * @description       : This test class covers the following Apex classes:
 *      ftr_ResourceManagementService
 *      ftr_ConfirmTOEnrichmentDispatcher
 *      ftr_ConfirmTOEnrichmentSubscriber
 * @author            : TBD
 * @version           : 2 
**/
@isTest(seeAllData = false)
private class ftr_ResourceManagementServiceTest {
    @TestSetup
    static void makeData(){
        Map<String,String> prodNameCodeMap = new Map<String,String>{
            'EIA  (Ethernet Internet Access)' => 'ENT_ETH_EIA_0002',
            'EVPL (Ethernet Virtual Private Line)' => 'ENT_ETH_EVPL_0002'

        };
        insert new ftr_PSRExchangeDetail__c(
            Company_Indicator_Code__c=203,
            Company_Indicator_Name__c='FRONTIER13',
            StateCode__c='CA',
            Exchange__c='ALTON',
            Name='ALTON',
            DPI_Env__c='CA',
            NPANXX__c='704764',
            NPA__c='704',
            NXX__c='764',
            FICT_NPA__c='704',
            FICT_NXX__c='82',
            WC_CLLI__c='ALTNNCXARS0'
        );
    
        Order[] oList = ftr_TestDataFactory.getOrders(1);
        insert oList;
        OrderItem[] oiList = ftr_TestDataFactory.getOrderItems(2, prodNameCodeMap);
        oiList[0].OrderId = oList[0].Id;
        oiList[1].OrderId = oList[0].Id;
        List<Account> accList = ftr_TestDataFactory.getServAccountsWithPremise(1);
        oiList[0].vlocity_cmt__ServiceAccountId__c = accList[0].Id;
        oiList[1].vlocity_cmt__ServiceAccountId__c = accList[0].Id;
        oiList[0].vlocity_cmt__AssetReferenceId__c = 'dcb24676-945e-ba06-66b7-d7219d37bbda';
        oiList[1].vlocity_cmt__AssetReferenceId__c = 'dcb24676-945e-ba06-66b7-d7219d37bbdb';
        insert oiList;
    }
	static testMethod void myUnitTest() {
        Order o = [select id from Order limit 1];
        List<OrderItem> oiList = [select id, vlocity_cmt__JSONAttribute__c, 
                                  vlocity_cmt__ServiceAccountId__r.ShippingStreet, 
                                  vlocity_cmt__ServiceAccountId__r.ShippingCity,
                                  vlocity_cmt__ServiceAccountId__r.ShippingState,
                                  vlocity_cmt__ServiceAccountId__r.ShippingPostalCode,
                                  vlocity_cmt__ServiceAccountId__r.ShippingStateCode
                                  from OrderItem where OrderId =:o.Id];
        Map<String, Object> inputMap = new Map<String,Object>();
        Map<String, Object> outputMap = new Map<String,Object>();
        Map<String, Object> optionsMap = new Map<String,Object>();
        inputMap.put('orderId', o.Id);
        Map<String, Object> findAvailTelephoneNumMap = new Map<String,Object>(); 
        findAvailTelephoneNumMap.put('env', 'LF');
        findAvailTelephoneNumMap.put('state', 'CA');
        findAvailTelephoneNumMap.put('maxTnNumbers', '5');
        findAvailTelephoneNumMap.put('itemSequence', '8');
        findAvailTelephoneNumMap.put('isReserveTN', 'TRUE');    
        Test.startTest();
        Test.setMock(WebServiceMock.class, new ftr_WebServiceMockImpl());
        ftr_ResourceManagementService service = new ftr_ResourceManagementService();
        service.invokeMethod('reserveWTNumber', inputMap, outputMap, optionsMap);
    	ftr_ResourceManagementService.findAvailableTelephoneNumberAndReserve(findAvailTelephoneNumMap);
     	Test.stopTest();
    }
}