/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class XOMAutoTask_ConfirmPSROrderCompleteTest {
@TestSetup
    static void makeData(){
         Integer numOfOrchItems = 1;

        //test data for UNI
        Map<String,String> prodUNIMap = new Map<String,String>{
                    'M6 UNI PSR CFS' => 'ENT_ETH_EIA_EVC_PSR_001'
        };
             Map<String,String> prodUNIMap2 = new Map<String,String>{
                    'M6 UNI PSR CFS' => 'ENT_ETH_DPI_CIRCUIT_BILLING'
        };
        List<vlocity_cmt__OrchestrationItem__c> orchItemsUNIList = ftr_TestDataFactory.getOrchestrationItems(numOfOrchItems, prodUNIMap);
        insert orchItemsUNIList;
        vlocity_cmt__OrchestrationPlan__c Orp = new vlocity_cmt__OrchestrationPlan__c();
        Orp.vlocity_cmt__State__c = 'Completed';
        insert Orp;
        
         vlocity_cmt__OrchestrationPlanDefinition__c OrPDF = new vlocity_cmt__OrchestrationPlanDefinition__c();
        OrPDF.Name = 'FinalOrderCompletion';
        insert OrPDF;
        
       vlocity_cmt__OrchestrationItemDefinition__c OrdDef = new vlocity_cmt__OrchestrationItemDefinition__c();
        OrdDef.vlocity_cmt__OrchestrationPlanDefinitionId__c = OrPDF.id;
        OrdDef.Name='Wait for BCN Complete';
        insert OrdDef;
         vlocity_cmt__OrchestrationItemDefinition__c OrdDef2 = new vlocity_cmt__OrchestrationItemDefinition__c();
        OrdDef2.vlocity_cmt__OrchestrationPlanDefinitionId__c = OrPDF.id;
        OrdDef2.Name='Wait for M6Orders Completion';
        insert OrdDef2;
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
        /*Map<String, Object> attrVals = new Map<String, Object>{
                'DPI_OrderNumber' => '077756953'
            };
            Flr.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(Flr.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
            Update Flr;*/
        //String jsonAttribute = Flr.vlocity_cmt__JSONAttribute__c;
        //System.debug('ordernoinjson---'+jsonAttribute);
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
System.debug('datacreated--name-'+OItm.vlocity_cmt__OrchestrationItemDefinitionId__r.Name+'productid-'+OItm.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode);
        System.debug('item-'+orchItemsUNIList);
    }
    
      @isTest  
    static void executeTest() {
        
        List<vlocity_cmt__OrchestrationItem__c> items = [SELECT Id, vlocity_cmt__fulfilmentRequestLineId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__JSONAttribute__c 
                                                         FROM vlocity_cmt__OrchestrationItem__c 
                                                         WHERE vlocity_cmt__OrchestrationItemDefinitionId__r.Name =: 'Wait for BCN Complete' ];
	XOMAutoTask_ConfirmPSROrderCompletion obj = new XOMAutoTask_ConfirmPSROrderCompletion();
        Test.startTest();
        obj.executeBatch(items);
        Test.stopTest();
        
    }
}