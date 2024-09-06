@isTest
public class XOMAutoTask_SIPCreateDPILeadServiceTest {

    @TestSetup
    static void makeData(){
        Integer numOfOrchItems = 1;
        Map<String,String> prodNameCodeMap = new Map<String,String>{
            'DPI DID LeadOrder Billing RFS' => 'DID_DPI_LEAD_ORDER_RFS_0010'
        };

        List<vlocity_cmt__OrchestrationItem__c> orchItemsList = ftr_TestDataFactory.getOrchestrationItems(numOfOrchItems, prodNameCodeMap);
        ftr_TestDataFactory.getAttributesWithCategory();
        insert orchItemsList;
    }

  
    @isTest static void executeBatchTest() {
        test.startTest();
        //Test.setMock(WebServiceMock.class, new ftr_M6AddServiceItemL1Mock());
        //Test.setMock(WebServiceMock.class, new ftr_M6AddServiceItemL1Mock());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Stage 1 - Order Entry'));

        List<vlocity_cmt__OrchestrationItem__c> items = [SELECT Id, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c FROM vlocity_cmt__OrchestrationItem__c];
       

        XOMAutoTask_SIPCreateDPILeadServiceOrder xom = new XOMAutoTask_SIPCreateDPILeadServiceOrder();

        
        xom.executeBatch(items);
        test.stopTest();
        

    }
}