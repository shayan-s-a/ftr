@isTest
private class ftr_DIDOrderSubmissionTest {

    @TestSetup
    static void makeData(){
        map <String, string > prodNamemap = new map <String, string >();
        prodNamemap.put('DID_DPI_MDN_RFS_0010', 'DID_DPI_MDN_RFS_0010');
        List<vlocity_cmt__FulfilmentRequestLine__c> FulfilmentRequestLines = ftr_TestDataFactory.getFulfilmentRequestLines(1,prodNamemap);
        insert FulfilmentRequestLines;
        vlocity_cmt__FulfilmentRequest__c fulfilmentRequest = [Select Id,Name, vlocity_cmt__orchestrationPlanId__c from vlocity_cmt__FulfilmentRequest__c where Id=: FulfilmentRequestLines[0].vlocity_cmt__FulfilmentRequestID__c LIMIT 1];
        vlocity_cmt__OrchestrationPlan__c orchPlanList =  [Select Id, Name, vlocity_cmt__OrderId__c from vlocity_cmt__OrchestrationPlan__c where Id=: fulfilmentRequest.vlocity_cmt__orchestrationPlanId__c LIMIT 1];
        Order order = [SELECT Id, vlocity_cmt__OrchestrationPlanId__c  FROM Order where Id=: orchPlanList.vlocity_cmt__OrderId__c LIMIT 1];
        order.vlocity_cmt__OrchestrationPlanId__c = orchPlanList.Id;
        update order;
        system.debug('ORDER ID: ' + order.Id);

        List<vlocity_cmt__FulfilmentRequestLine__c> fulfilmentRequestLineSQuery =[Select Id,Name,vlocity_cmt__JSONAttribute__c, vlocity_cmt__Product2Id__r.productCode  from vlocity_cmt__FulfilmentRequestLine__c where Id =: FulfilmentRequestLines[0].Id ];
        system.debug('fulfilmentRequestLineS TEST: ' + fulfilmentRequestLineSQuery);

    }

    @isTest  
    static void saveDIDForSubmissionTest() {
        

        ftr_DIDOrderSubmission service = new ftr_DIDOrderSubmission();
        String methodName = 'saveDIDForSubmission';
        String testJsonInput = '{"ContextId":"","timeStamp":"2023-04-05T12:30:06.292Z","userId":"0058a00000KfKrjAAF","userName":"angelica.morales@nespon.com.devsip20","userProfile":"System Administrator","userTimeZone":-240,"userCurrencyCode":"USD","testContextId":"8017c000000SVUhAAO","sfdcIFrameOrigin":"https://ftr--devsip20--vlocity-cmt.sandbox.vf.force.com","sfdcIFrameHost":"web","layout":"newport","isdtp":"p1","id":"a9p7c0000004J4wAAE","vlcPersistentComponent":{},"ServiceLocationDetails":{"Select1":"Dropdown","ServiceLocationTemplate":null},"checkNextStepLoc":true,"DIDLocationName":"","ServiceAccounts":[{"Premises":{"WC_Speed__c":"1000MB","WC_QOS__c":"Platinum","Last_DSAT_Check__c":"2023-03-30","Id":"aAc7c00000009VfCAI","Fiber_Tier__c":"Tier 1","TicketNo":"1669269","Copper_Tier__c":"Tier 1"},"DIDLocations":[{"isSubmitted__c":false,"DueDate__c":"2023-04-15","MDN__c":"6502549711","BTN__c":"6502549711","Id":"aH67c0000008fwNCAQ","Name":"Fort Wayne Street Bridge, DID Location 1","$$hashKey":"object:66"}],"ZipCode":"46528","Street":"Fort Wayne Street Bridge","State":"IN","Name":"Fort Wayne Street Bridge, Goshen, IN  46528","Id":"0017c000011hlM6AAI","Country":"United States","City":"Goshen","Address":"Fort Wayne Street Bridge, Goshen, IN  46528","currentLocationIndex":0,"SameDueDate":false}],"SelectServiceLocation":{"CurrentLocationId":"0017c000011hlM6AAI","CurrentLocationName":"Fort Wayne Street Bridge, Goshen, IN  46528","CountOfLocations":1},"CurrentServiceLocation":{"Premises":{"WC_Speed__c":"1000MB","WC_QOS__c":"Platinum","Last_DSAT_Check__c":"2023-03-30","Id":"aAc7c00000009VfCAI","Fiber_Tier__c":"Tier 1","TicketNo":"1669269","Copper_Tier__c":"Tier 1"},"DIDLocations":[{"isSubmitted__c":false,"DueDate__c":"2023-04-15","MDN__c":"6502549711","BTN__c":"6502549711","Id":"aH67c0000008fwNCAQ","Name":"Fort Wayne Street Bridge, DID Location 1","$$hashKey":"object:66"}],"ZipCode":"46528","Street":"Fort Wayne Street Bridge","State":"IN","Name":"Fort Wayne Street Bridge, Goshen, IN  46528","Id":"0017c000011hlM6AAI","Country":"United States","City":"Goshen","Address":"Fort Wayne Street Bridge, Goshen, IN  46528","currentLocationIndex":0}}';
        Map<String, Object> input = (Map<String,Object>)JSON.deserializeUntyped(testJsonInput);
        Order orderInput = [SELECT Id, vlocity_cmt__OrchestrationPlanId__c FROM Order LIMIT 1];
        system.debug('ORDER ID 2: ' + orderInput.vlocity_cmt__OrchestrationPlanId__c);

        Id OrderId = orderInput.Id;
        system.debug('ORDER ID 3: ' + OrderId);

        input.put('ContextId', OrderId);
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        test.startTest();
        service.invokeMethod(methodName, input, output, options);
        test.stopTest();

    }

}