@isTest
public class ftr_SubmitDIDBulkGroupOrderTest {
    @TestSetup
    static void makeData(){
        
        Integer numOfOrchItems = 1;
        Map<String,String> prodNameCodeMap = new Map<String,String>{
            'DPI DID Bulk Billing RFS' => 'DPI_Bulk_Billing_RFS'
        };
        
        List<vlocity_cmt__OrchestrationItem__c> orchItemsList = ftr_TestDataFactory.getOrchestrationItems(numOfOrchItems, prodNameCodeMap);
        ftr_TestDataFactory.getAttributesWithCategory();
        vlocity_cmt__FulfilmentRequestLine__c Flr = [select id,vlocity_cmt__FulfilmentRequestId__c from vlocity_cmt__FulfilmentRequestLine__c where Id = :orchItemsList[0].vlocity_cmt__FulfilmentRequestLineId__c];
        Flr.vlocity_cmt__JSONAttribute__c = '{"FTR_ENT_TECH_ATTCAT":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"FTR_ENT_TECH_ATTCAT","attributeid__c":"a7b7c000000L2VXAA0","attributeuniquecode__c":"ATTR_IsBillingComplete","attributedisplayname__c":"IsBillingComplete","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":""},"Name":"IsBillingComplete","Code":"ATTR_IsBillingComplete","Filterable":false,"SegmentValue":"","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"FTR_ENT_TECH_ATTCAT","attributeid__c":"a7b7c000000L2WhAAK","attributeuniquecode__c":"GroupMemberOrderId","attributedisplayname__c":"DPI_GroupMemberOrderId","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":""},"Name":"DPI_GroupMemberOrderId","Code":"GroupMemberOrderId","Filterable":false,"SegmentValue":"","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"FTR_ENT_TECH_ATTCAT","attributeid__c":"a7b7c000000L2WnAAK","attributeuniquecode__c":"LeadOrderId","attributedisplayname__c":"DPI_LeadOrderId","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":""},"Name":"DPI_LeadOrderId","Code":"LeadOrderId","Filterable":false,"SegmentValue":"","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"FTR_ENT_TECH_ATTCAT","attributeid__c":"a7b7c000000CyFaAAK","attributeuniquecode__c":"ATTR_DID_LOC","attributedisplayname__c":"DID Location","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"aH67c0000008g4fCAA"},"Name":"DID Location","Code":"ATTR_DID_LOC","Filterable":false,"SegmentValue":"aH67c0000008g4fCAA","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"FTR_ENT_TECH_ATTCAT","attributeid__c":"a7b7c000000V0RHAA0","attributeuniquecode__c":"Service_Bulk_Type","attributedisplayname__c":"DPI_Service Type","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"V7"},"Name":"DPI_Service Type","Code":"Service_Bulk_Type","Filterable":false,"SegmentValue":"V7","$$AttributeDefinitionEnd$$":null}],"FTR_ENT_CUSTOMERACCOUNT_ATTCAT":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"FTR_ENT_CUSTOMERACCOUNT_ATTCAT","attributeid__c":"a7b7c000000L2ReAAK","attributeuniquecode__c":"Environment","attributedisplayname__c":"DPI_Environment","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":""},"Name":"DPI_Environment","Code":"Environment","Filterable":false,"SegmentValue":"","$$AttributeDefinitionEnd$$":null}],"FTR_ENT_CUSTOMER_ATTCAT":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"FTR_ENT_CUSTOMER_ATTCAT","attributeid__c":"a7b7c000000L2SVAA0","attributeuniquecode__c":"CustomerType","attributedisplayname__c":"DPI_CustomerType","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"New"},"Name":"DPI_CustomerType","Code":"CustomerType","Filterable":false,"SegmentValue":"New","$$AttributeDefinitionEnd$$":null}],"FTR_ENT_CUSTOMERORDER_ATTCAT":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"FTR_ENT_CUSTOMERORDER_ATTCAT","attributeid__c":"a7b7c000000L2RvAAK","attributeuniquecode__c":"Action","attributedisplayname__c":"DPI_action","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"COPY"},"Name":"DPI_action","Code":"Action","Filterable":false,"SegmentValue":"COPY","$$AttributeDefinitionEnd$$":null}]}';
        update Flr;
        System.debug('orchItemsList = ' + orchItemsList);
        insert orchItemsList;

        ftr_DID_Location_Details__c didLocation = new ftr_DID_Location_Details__c();
        didLocation.Name = 'Location One';
        insert didLocation;

        List<ftr_DID_Number_Details__c> numbersList = new List<ftr_DID_Number_Details__c>();
       
        ftr_DID_Number_Details__c numberDetail = new ftr_DID_Number_Details__c();
        numberDetail.DIDLocationDetailsId__c = didLocation.Id;
        numberDetail.Name = 'Number Detail';
        numberDetail.DIDNumberInfo__c = 'New DID Range';
        numberDetail.MDN_Checkbox__c = false;                                           
        numberDetail.isDIDLead__c = false; 
        numberDetail.DID_Number__c = '1111111';
        numbersList.add(numberDetail);
        ftr_DID_Number_Details__c numberDetail2 = new ftr_DID_Number_Details__c();
        numberDetail2.DIDLocationDetailsId__c = didLocation.Id;
        numberDetail2.Name = 'Number Detail';
        numberDetail2.DIDNumberInfo__c = 'Port-In';
        numberDetail2.MDN_Checkbox__c = false;                                           
        numberDetail2.isDIDLead__c = false; 
        numberDetail2.DID_Number__c = '2222222';
        numbersList.add(numberDetail2);

        insert numbersList;

    }
/*
    @isTest
     static void submitDIDBulkGroupTest(){
        System.debug('SubmitDIDBulkGroupOrder getting the orch item');

        vlocity_cmt__OrchestrationItem__c item = [SELECT Id,Name, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__RequestItemsVlocityDataRaptorBundleId__c,vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__c, vlocity_cmt__VlocityDataRaptorBundleId__c,vlocity_cmt__ResponseVlocityDataRaptorBundleId__c, vlocity_cmt__NumberOfRetries__c FROM vlocity_cmt__OrchestrationItem__c WHERE Name = 'SubmitDIDLeadGroupOrder' LIMIT 1];
		
        System.Debug('orch item = ' + item);
		System.debug('SubmitDIDBulkGroupOrderTest Line 37');
        Test.setMock(HttpCalloutMock.class, new ftr_SubmitGroupMemberOrderMock());
        ftr_SubmitDIDBulkGroupOrderInterface l1 = new ftr_SubmitDIDBulkGroupOrderInterface();
        System.debug('Starting the test');
        Test.startTest();
        
        l1.executeItem('','',item);
        Test.stopTest();
    }*/

    @isTest
    static void test2() {
        String url = '';
       	String path = ''; 
        ftr_DID_Location_Details__c[] locDetail = [SELECT Id FROM ftr_DID_Location_Details__c Limit 1];


        Map<String, Object> input = new Map<String,Object>();
        input.put('DIDLocation', locDetail[0].Id);
        input.put('DIDNumberType', 'New'); 
        input.put('OrderNumber', '000000');
        input.put('LeadOrderId', '00000');
        input.put('Action', '00000');
        input.put('Environment', '00000');
        input.put('serviceType', '00000');
        Map<String, Object> telephoneNumberUsage = new Map<String,Object>();
        telephoneNumberUsage.put('Service', '00000');
        input.put('telephoneNumberUsage', telephoneNumberUsage);
        Map<String, Object> input2 = new Map<String,Object>();
        input2.put('DIDLocation', locDetail[0].Id);
        input2.put('DIDNumberType', 'PortIn'); 
        input2.put('OrderNumber', '000000');
        input2.put('LeadOrderId', '00000');
        input2.put('Action', '00000');
        input2.put('Environment', '00000');
        input2.put('serviceType', '00000');
        input2.put('telephoneNumberUsage', telephoneNumberUsage);
        
        ftr_SubmitDIDBulkGroupOrderInterface service = new ftr_SubmitDIDBulkGroupOrderInterface();

        service.getOrchestrationTaskName();
        service.createDPIRequestType(url, path, input);
        service.createDPIRequestType(url, path, input2);

        //service.processDPIResponseType(url, path, input);
    } 
}