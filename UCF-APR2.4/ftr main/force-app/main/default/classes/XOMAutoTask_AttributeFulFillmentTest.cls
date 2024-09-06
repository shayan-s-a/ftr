/**
 * @description       :  This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1
**/
@isTest
public class XOMAutoTask_AttributeFulFillmentTest {

    @TestSetup
    static void makeData(){
        Integer numOfOrchItems = 1;
        Map<String,String> prodNameCodeMap = new Map<String,String>{
            'SIP Trunking CFS' => 'SIP_TRUNKING_CFS_0010', // Not present
            'M6 UNI SIP PSR RESOURCE SPEC' => 'SIP_TRUNKING_UNI_PSR_RES_SPEC_0010',
            'M6 SIP EVC  PSR RESOURCE SPEC' => 'SIP_EVC_PSR_RES_SPEC_0010'
            /*'DPI DID LeadOrder Billing RFS' => 'DID_DPI_LEAD_ORDER_RFS_0010',
            'DPI DID MDN Billing RFS' => 'DID_DPI_MDN_RFS_0010'*/
        };
       
        List<vlocity_cmt__OrchestrationItem__c> orchItemsList = ftr_TestDataFactory.getOrchestrationItems(numOfOrchItems, prodNameCodeMap);
        insert orchItemsList;
        ftr_TestDataFactory.getAttributesWithCategory();
        
    }

    @isTest
    static void testUpdateAttribute() {
        List<vlocity_cmt__OrchestrationItem__c> liItems = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c FROM vlocity_cmt__OrchestrationItem__c];
        Test.startTest();
        // *Call the method to be tested
        XOMAutoTask_AttributeFulFillment.updateAttribute(liItems);
        Test.stopTest();

        // Verify the expected results
        vlocity_cmt__FulfilmentRequest__c fulfilmentRequest = [SELECT Id, Name FROM vlocity_cmt__FulfilmentRequest__c];
        List<vlocity_cmt__FulfilmentRequestLine__c> fulfilmentRequestLines = [
            SELECT Id, Name, vlocity_cmt__JSONAttribute__c
            FROM vlocity_cmt__FulfilmentRequestLine__c
            WHERE vlocity_cmt__FulfilmentRequestID__c = :fulfilmentRequest.Id
        ];
        System.assertEquals(1, fulfilmentRequestLines.size());

        vlocity_cmt__FulfilmentRequestLine__c frLine = fulfilmentRequestLines[0];
        System.assertEquals('CISCO ISR4321-SEC/K9 P/N:ISR4321-SEC/K9', ftr_CpqHelper.getJSONAttributeValue(frLine.vlocity_cmt__JSONAttribute__c, 'ATTR_MNGD_DEVICE'));
        // System.assertEquals('null', ftr_CpqHelper.getJSONAttributeValue(frLine.vlocity_cmt__JSONAttribute__c, 'MANAGED DEVICE KIT'));
        // System.assertEquals('WALL MOUNT', ftr_CpqHelper.getJSONAttributeValue(frLine.vlocity_cmt__JSONAttribute__c, 'MOUNTING SPECIFICATION'));
    }
    static testmethod void testIncrement() {
        Test.startTest();
        XOMAutoTask_AttributeFulFillment.justIncrement();
        Test.stopTest(); 
 }

}