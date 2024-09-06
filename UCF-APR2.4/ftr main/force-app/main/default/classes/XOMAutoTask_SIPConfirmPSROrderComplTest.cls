@isTest
public class XOMAutoTask_SIPConfirmPSROrderComplTest {
    @TestSetup
    static void makeData() {
        Integer numOfOrchItems = 1;
        
        // *test data for UNI
        Map<String,String> prodUNIMap = new Map<String,String>{
            'SIP TRUNKING DPI BILLING RESOURCE SPEC' => 'SIP_TRUNKING_DPI_BILLING_RES_SPEC_0010',
            'DPI CIRCUIT BILLING RESOURCE SPEC' => 'DPI_CIRCUIT_BILLING_RES_SPEC_0010'
        };
        Map<String,String> prodUNIMap2 = new Map<String,String> {
            'DPI CIRCUIT BILLING RESOURCE SPEC' => 'DPI_CIRCUIT_BILLING_RES_SPEC_0010'
        };

        List<vlocity_cmt__OrchestrationItem__c> orchItemsUNIList = ftr_TestDataFactory.getOrchestrationItems(numOfOrchItems, prodUNIMap);
        insert orchItemsUNIList;
        
        vlocity_cmt__OrchestrationPlan__c Orp = new vlocity_cmt__OrchestrationPlan__c();
        Orp.vlocity_cmt__State__c = 'Completed';
        insert Orp;
        
        vlocity_cmt__OrchestrationPlanDefinition__c OrPDF = new vlocity_cmt__OrchestrationPlanDefinition__c();
        OrPDF.Name = 'SIP DPI Generic Billing Plan';
        insert OrPDF;   
       
        vlocity_cmt__OrchestrationItemDefinition__c OrdDef = new vlocity_cmt__OrchestrationItemDefinition__c();
        OrdDef.vlocity_cmt__OrchestrationPlanDefinitionId__c = OrPDF.id;
        OrdDef.Name='Wait for BCN Complete';
        insert OrdDef;
        
        vlocity_cmt__OrchestrationItemDefinition__c OrdDef1 = new vlocity_cmt__OrchestrationItemDefinition__c();
        OrdDef1.vlocity_cmt__OrchestrationPlanDefinitionId__c = OrPDF.id;
        OrdDef1.Name='Wait for M6Orders Completion';
        insert OrdDef1;

        vlocity_cmt__OrchestrationItemDefinition__c OrdDef2 = new vlocity_cmt__OrchestrationItemDefinition__c();
        OrdDef2.vlocity_cmt__OrchestrationPlanDefinitionId__c = OrPDF.id;
        OrdDef2.Name='SIP Wait for M6Orders Completion';
        insert OrdDef2;

        vlocity_cmt__OrchestrationItemDefinition__c OrdDef3 = new vlocity_cmt__OrchestrationItemDefinition__c();
        OrdDef3.vlocity_cmt__OrchestrationPlanDefinitionId__c = OrPDF.id;
        OrdDef3.Name='SIP Wait for BCN Complete';
        insert OrdDef3;

        vlocity_cmt__OrchestrationItemDefinition__c OrdDef4 = new vlocity_cmt__OrchestrationItemDefinition__c();
        OrdDef4.vlocity_cmt__OrchestrationPlanDefinitionId__c = OrPDF.id;
        OrdDef4.Name='SIP Wait for BCN Ready';
        insert OrdDef4;
        
        
        List<Product2> prodList = ftr_TestDataFactory.getTechnicalProducts(prodUNIMap, 1);
        insert prodList;
        
        List<Product2> prodList2 = ftr_TestDataFactory.getTechnicalProducts(prodUNIMap2, 1);
        insert prodList2;
        //Fullfillment Request Line
        vlocity_cmt__FulfilmentRequestLine__c Flr = new vlocity_cmt__FulfilmentRequestLine__c();
        Flr.vlocity_cmt__Product2Id__c = prodList[0].Id;
        Flr.vlocity_cmt__JSONAttribute__c = '{"CorrelationId":"1453","ATTR_M6_IsOrderCompleted":"true","DPI_OrderNumber":"077756953","FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "attributeRunTimeInfo": { "values": [ { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } ], "selectedItem": { "value": "36 Months" } }, "$$AttributeDefinitionEnd$$": null }]}';  
        insert Flr;
        
        vlocity_cmt__FulfilmentRequestLine__c Flr2 = new vlocity_cmt__FulfilmentRequestLine__c();
        Flr2.vlocity_cmt__Product2Id__c = prodList2[0].Id;
        Flr2.vlocity_cmt__JSONAttribute__c = '{"CorrelationId":"1453","ATTR_M6_IsOrderCompleted":"true","DPI_OrderNumber":"077756953","FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "attributeRunTimeInfo": { "values": [ { "value": "5 Mbps", "sequence": 5, "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "displayText": "5 Mbps" } ], "default": [ ], "selectedItem": { "value": "20 Mbps", "sequence": 20, "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "displayText": "20 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "12 Months", "sequence": 10, "id": "acf430f3-5767-4418-ae26-7ec4b80dbc8d", "displayText": "12 Months" }, { "value": "36 Months", "sequence": 30, "id": "3ce165f6-d467-6a31-f2bf-edbbcad82725", "displayText": "36 Months" } ], "selectedItem": { "value": "36 Months" } }, "$$AttributeDefinitionEnd$$": null }]}';  
        insert Flr2;
        
        System.debug('jsonattri--'+Flr.vlocity_cmt__JSONAttribute__c);
        vlocity_cmt__OrchestrationItem__c OItm = new vlocity_cmt__OrchestrationItem__c();
        OItm.vlocity_cmt__State__c = 'Completed';
        OItm.vlocity_cmt__FulfilmentRequestLineId__c = Flr.id;
        OItm.vlocity_cmt__OrchestrationItemDefinitionId__c = OrdDef.id;
        OItm.vlocity_cmt__OrchestrationPlanId__c = Orp.id;
        insert OItm;
        
        vlocity_cmt__OrchestrationItem__c OItm2 = new vlocity_cmt__OrchestrationItem__c();
        OItm2.vlocity_cmt__State__c = 'Running';
        OItm2.vlocity_cmt__FulfilmentRequestLineId__c = Flr2.id;
        OItm2.vlocity_cmt__OrchestrationItemDefinitionId__c = OrdDef2.id;
        OItm2.vlocity_cmt__OrchestrationPlanId__c = Orp.id;
        insert OItm2;
        
        vlocity_cmt__OrchestrationItem__c OItm3 = new vlocity_cmt__OrchestrationItem__c();
        OItm3.vlocity_cmt__State__c = 'Running';
        OItm3.vlocity_cmt__FulfilmentRequestLineId__c = Flr2.id;
        OItm3.vlocity_cmt__OrchestrationItemDefinitionId__c = OrdDef3.id;
        OItm3.vlocity_cmt__OrchestrationPlanId__c = Orp.id;
        insert OItm3;
        System.debug('datacreated--name-'+OItm.vlocity_cmt__OrchestrationItemDefinitionId__r.Name+'productid-'+OItm.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode);
        System.debug('item-'+orchItemsUNIList);
    }
    
    @isTest  
    static void executeTest() {
        List<vlocity_cmt__OrchestrationItem__c> items = [SELECT Id, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c 
        FROM vlocity_cmt__OrchestrationItem__c WHERE vlocity_cmt__OrchestrationItemDefinitionId__r.Name =: 'SIP Wait for BCN Complete' ];
        XOMAutoTask_SIPConfirmPSROrderCompletion obj = new XOMAutoTask_SIPConfirmPSROrderCompletion();
        Test.startTest();
        obj.executeBatch(items);
        Test.stopTest();
    }
}