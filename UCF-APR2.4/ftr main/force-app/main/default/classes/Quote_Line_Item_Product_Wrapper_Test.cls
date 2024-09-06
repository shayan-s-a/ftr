/**
 * @description        : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 4
 **/
@IsTest //(seeAllData=true)
public class Quote_Line_Item_Product_Wrapper_Test {
    private class TestData {
        public Opportunity testOpportunity;
        public SterlingQuote__c testQuote;
        public SterlingQuoteItem__c testQuoteItem;
        public OpportunityLineItem testOpportunityProduct;

        public TestData() {
            Test.startTest();
            //this.testOpportunity = Test_Fixture_Factory.createTestOpportunity(); // Commented
            
            Account acc = new Account(name = 'TestAccount',Customer_Number__c='1234');
            insert acc; 
            System.debug('----acc----'+acc);
            
            //Opportunity testOpportunity= new Opportunity(Name = 'Test 1', StageName = 'Investigating', AccountId = acc.Id , CloseDate = Date.today(), Pricebook2Id = Test.getStandardPricebookId());
            this.testOpportunity= new Opportunity(Name = 'Test 1', StageName = 'Investigating', AccountId = acc.Id , CloseDate = Date.today(), Pricebook2Id = Test.getStandardPricebookId());
            insert testOpportunity;
            System.debug('----opp----'+testOpportunity);
            
            // Product Object
            Product2 p = new Product2();
            p.Name = 'Test Product';
            p.Description = 'test product';
            p.ProductCode = '999';
            insert p;
            System.debug('----Product----'+p);
            
            // PricebookEntry Object
            Id pb = Test.getStandardPricebookId(); // pricebookId
            PricebookEntry pe = new PricebookEntry(Pricebook2Id = pb , Product2Id = p.Id, UnitPrice = 10.50, IsActive = true);
            insert pe;
            System.debug('----pe----'+pe);
            
            // SterlingQuote__c 
            //this.testQuote = Test_Fixture_Factory.createTestQuote(testOpportunity.Id, '', 'Pending - Finance'); 
            Id SterlingQuoRecordTypeId = Schema.SObjectType.SterlingQuote__c.getRecordTypeInfosByName().get('SFA').getRecordTypeId();
           
            this.testQuote = new SterlingQuote__c(Name = 'Test Quote 1', 
                                                        RecordTypeid = SterlingQuoRecordTypeId , 
                                                        OpportunityId__c = testOpportunity.id, 
                                                        IsSyncing__c = true);
            insert testQuote;
            System.debug('----SterlingQuote__c ----'+testQuote);
            
            Test.stopTest();
            system.debug('testOpportunity@@@@@@@');
            //this.testQuote = Test_Fixture_Factory.createTestQuote(testOpportunity.Id, '', 'Pending - Finance');
            
            this.testOpportunityProduct = new OpportunityLineItem (CPE_Gross_Margin__c = 0,CPE_NRC_Price__c = 5.00,
                NRC_Price__c = 12,Product2 = p,Service_Address__c = 'test',CPQ_NetNewMRR__c=5.00,Renewal_MRR__c=5.00,
                Quantity = 1,OpportunityId = testOpportunity.id,TotalPrice = 18.00,PricebookEntryId = pe.Id);
                                         
            
            insert testOpportunityProduct;
            System.debug('----OpportunityLineItem ----'+this.testOpportunityProduct+'----'+testOpportunityProduct);
                        
            // SterlingQuoteItem__c Object
            Id SterlingQuoItemRecordTypeId = Schema.SObjectType.SterlingQuoteItem__c.getRecordTypeInfosByName().get('SFA').getRecordTypeId();
            
            this.testQuoteItem =  new SterlingQuoteItem__c (SterlingQuote__c = testQuote.id, 
                                                    DiscountType__c = '', Name = 'Test1', Quantity__c = 1, 
                                                    Category__c = 'Services',TermLength__c=1,NetNewMRR__c = 10,
                                                    RecordTypeId = SterlingQuoItemRecordTypeId,
                                                    OpportunityLineItemId__c =testOpportunityProduct.id,
                                                    renewal_mrr_original__c=10,AdjustedNRC__c=10,CPE_NRC_Price__c=10);
            
            insert testQuoteItem;
            
            System.debug('----SterlingQuoteItem__c ----'+this.testQuoteItem+'----'+testQuoteItem);
                                   
            
        }
    }

    private static Quote_Line_Item_Product_Wrapper getTestQLIPW() {
        TestData td = new TestData();
        return new Quote_Line_Item_Product_Wrapper(td.testQuoteItem, td.testOpportunityProduct);
    }

    @IsTest
    public static void empty_constructor_test() {
        Quote_Line_Item_Product_Wrapper testQLIPW = new Quote_Line_Item_Product_Wrapper();
        system.assert(testQLIPW.name == 'test');
    }
    
    @IsTest
    public static void adding_vlocity_olis_test() {
        TestData td = new TestData();
        System.debug('----td ----'+td );
        ftr_TestDataFactory.getAccounts(1);
        String jsonAttribute='{ "FTR_ENT_ADDL_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000051z8AAA", "attributecategoryid__c": "a7ae0000000Em9wAAC", "categorycode__c": "FTR_ENT_ADDL_ATTCAT", "categoryname__c": "More Information", "attributeuniquecode__c": "ATTR_NOTES", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Comments", "displaysequence__c": "null", "categorydisplaysequence__c": 30, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": false, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008jhBEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Text", "value__c": null, "valuedatatype__c": "Text", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Text", "uiDisplayType": "Text", "value": null }, "$$AttributeDefinitionEnd$$": null } ], "FTR_ENT_DECOMP_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000051z5AAA", "attributecategoryid__c": "a7ae0000000Em9rAAC", "categorycode__c": "FTR_ENT_DECOMP_ATTCAT", "categoryname__c": "Decomposition Attributes", "attributeuniquecode__c": "ATTR_DECOMP_WTN", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "WTN", "displaysequence__c": "null", "categorydisplaysequence__c": 40, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": false, "ishidden__c": true, "valueinnumber__c": 0, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008jhCEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Text", "value__c": "0000000000", "valuedatatype__c": "Text", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Text", "uiDisplayType": "Text", "default": "0000000000", "value": "0000000000" }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000051zfAAA", "attributecategoryid__c": "a7ae0000000Em9rAAC", "categorycode__c": "FTR_ENT_DECOMP_ATTCAT", "categoryname__c": "Decomposition Attributes", "attributeuniquecode__c": "ATTR_M6_Circuit", "attributeconfigurable__c": true, "attributedisplaysequence__c": "60", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "M6 Circuit ID", "displaysequence__c": "null", "categorydisplaysequence__c": 40, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": false, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008jhUEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Text", "value__c": null, "valuedatatype__c": "Text", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Text", "uiDisplayType": "Text", "value": null }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000051zgAAA", "attributecategoryid__c": "a7ae0000000Em9rAAC", "categorycode__c": "FTR_ENT_DECOMP_ATTCAT", "categoryname__c": "Decomposition Attributes", "attributeuniquecode__c": "ATTR_NEG", "attributeconfigurable__c": true, "attributedisplaysequence__c": "1", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Negotiation", "displaysequence__c": "null", "categorydisplaysequence__c": 40, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008jhJEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": "Auto", "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "default": [ { "displayText": "Auto", "id": "d70b531d-3efe-6008-324f-285dcac217f7", "sequence": 10, "value": "Auto" } ], "values": [ { "displayText": "Auto", "id": "d70b531d-3efe-6008-324f-285dcac217f7", "sequence": 10, "value": "Auto" }, { "displayText": "No Negotiate", "id": "9be6c3a7-aebe-8c0e-8bdd-9467314c26c3", "sequence": 20, "value": "No Negotiate" } ], "selectedItem": { "displayText": "Auto", "id": "d70b531d-3efe-6008-324f-285dcac217f7", "sequence": 10, "value": "Auto" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000051zpAAA", "attributecategoryid__c": "a7ae0000000Em9rAAC", "categorycode__c": "FTR_ENT_DECOMP_ATTCAT", "categoryname__c": "Decomposition Attributes", "attributeuniquecode__c": "ATTR_TECH_RATE_CODE", "attributeconfigurable__c": true, "attributedisplaysequence__c": "30", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Rate Code", "displaysequence__c": "null", "categorydisplaysequence__c": 40, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": false, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008k2EEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Text", "value__c": null, "valuedatatype__c": "Text", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Text", "uiDisplayType": "Text", "value": null }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000051ztAAA", "attributecategoryid__c": "a7ae0000000Em9rAAC", "categorycode__c": "FTR_ENT_DECOMP_ATTCAT", "categoryname__c": "Decomposition Attributes", "attributeuniquecode__c": "ATTR_UNI_MODE", "attributeconfigurable__c": true, "attributedisplaysequence__c": "15", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "UNI Mode", "displaysequence__c": "null", "categorydisplaysequence__c": 40, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": false, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008jhPEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Text", "value__c": "Full Duplex", "valuedatatype__c": "Text", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Text", "uiDisplayType": "Text", "default": "Full Duplex", "value": "Full Duplex" }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000051zqAAA", "attributecategoryid__c": "a7ae0000000Em9rAAC", "categorycode__c": "FTR_ENT_DECOMP_ATTCAT", "categoryname__c": "Decomposition Attributes", "attributeuniquecode__c": "ATTR_TECH_SVC_MULTIPLX", "attributeconfigurable__c": true, "attributedisplaysequence__c": "40", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Service Multiplexed", "displaysequence__c": "null", "categorydisplaysequence__c": 40, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": true, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008jhREAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "displayText": "Yes", "id": "d830fdde-6767-bf12-ce2f-faad54710321", "sequence": 10, "value": "Yes" }, { "displayText": "No", "id": "d6f9f1aa-d102-5be3-e907-5aff00b2b92a", "sequence": 20, "value": "No" } ], "default": [ ], "selectedItem": { } }, "$$AttributeDefinitionEnd$$": null } ], "FTR_ENT_ELIG_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000053K0AAI", "attributecategoryid__c": "a7ae0000000Em9xAAC", "categorycode__c": "FTR_ENT_ELIG_ATTCAT", "categoryname__c": "Eligibility Attributes", "attributeuniquecode__c": "ATTR_DSAT_ID", "attributeconfigurable__c": true, "attributedisplaysequence__c": "600", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "DSAT ID", "displaysequence__c": "null", "categorydisplaysequence__c": 50, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": false, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008k2FEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Text", "value__c": null, "valuedatatype__c": "Text", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Text", "uiDisplayType": "Text", "value": null }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000051zAAAQ", "attributecategoryid__c": "a7ae0000000Em9xAAC", "categorycode__c": "FTR_ENT_ELIG_ATTCAT", "categoryname__c": "Eligibility Attributes", "attributeuniquecode__c": "ATTR_ELIGBL_CLLI", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "WC CLLI", "displaysequence__c": "null", "categorydisplaysequence__c": 50, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": false, "ishidden__c": true, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008jhGEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Text", "value__c": null, "valuedatatype__c": "Text", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Text", "uiDisplayType": "Text", "value": null }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000051zDAAQ", "attributecategoryid__c": "a7ae0000000Em9xAAC", "categorycode__c": "FTR_ENT_ELIG_ATTCAT", "categoryname__c": "Eligibility Attributes", "attributeuniquecode__c": "ATTR_ELIGBL_QOS", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "WC QoS", "displaysequence__c": "null", "categorydisplaysequence__c": 50, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": false, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008k2GEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Text", "value__c": null, "valuedatatype__c": "Text", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Text", "uiDisplayType": "Text", "value": null }, "$$AttributeDefinitionEnd$$": null } ], "FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000051zIAAQ", "attributecategoryid__c": "a7ae0000000Em9yAAC", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008l2SEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "displayText": "NA", "id": "b0966bd9-fd8a-64e8-c734-491d83f778f4", "sequence": 1, "value": "NA" }, { "displayText": "5 Mbps", "id": "4aba2306-23a9-9d57-df5e-6845e3943828", "sequence": 5, "value": "5 Mbps" }, { "displayText": "10 Mbps", "id": "1a208fd2-ccf1-e3ad-2f16-3009f90cb522", "sequence": 10, "value": "10 Mbps" }, { "displayText": "20 Mbps", "id": "8b45b7bf-7984-df2e-7378-108ef35bc8a5", "sequence": 20, "value": "20 Mbps" }, { "displayText": "30 Mbps", "id": "8e3195a8-38f9-7b18-d78b-87ef50d43f48", "sequence": 23, "value": "30 Mbps" }, { "displayText": "40 Mbps", "id": "8628d5bb-244e-41e2-db08-85d3cb246e8f", "sequence": 26, "value": "40 Mbps" }, { "displayText": "50 Mbps", "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "sequence": 30, "value": "50 Mbps" }, { "displayText": "100 Mbps", "id": "ed22cdc9-eb1e-cd69-15a9-f5669740afb5", "sequence": 40, "value": "100 Mbps" }, { "displayText": "200 Mbps", "id": "3c2416ab-8c99-5331-c40b-ba36ca84bf72", "sequence": 50, "value": "200 Mbps" }, { "displayText": "300 Mbps", "id": "c096a1f5-cbdc-5e41-1bde-6bf9a4aedee9", "sequence": 60, "value": "300 Mbps" }, { "displayText": "400 Mbps", "id": "fdebc972-b9ec-e456-1d6e-5d03c284ca67", "sequence": 70, "value": "400 Mbps" }, { "displayText": "500 Mbps", "id": "5b421e64-e57e-6aa5-fc1a-55c926e9e3dc", "sequence": 80, "value": "500 Mbps" }, { "displayText": "600 Mbps", "id": "f2af83f9-ab01-4700-0fe5-b02afe290f69", "sequence": 90, "value": "600 Mbps" }, { "displayText": "700 Mbps", "id": "0501fb70-8e20-540d-d4d5-2330d003a939", "sequence": 100, "value": "700 Mbps" }, { "displayText": "800 Mbps", "id": "e049798b-2162-1f86-1bdc-508c3e58a89d", "sequence": 110, "value": "800 Mbps" }, { "displayText": "900 Mbps", "id": "9e713b50-7ac2-2053-0aad-eeb42c9db47f", "sequence": 120, "value": "900 Mbps" }, { "displayText": "1 Gbps", "id": "3aa261dc-29ca-d36d-2a72-5e253b8937f3", "sequence": 130, "value": "1 Gbps" }, { "displayText": "2 Gbps", "id": "092b8106-a0bd-1ba4-8844-b8b5cbc0d9c4", "sequence": 140, "value": "2 Gbps" }, { "displayText": "5 Gbps", "id": "ecd9008f-9dd8-2415-6574-a52930dc128f", "sequence": 170, "value": "5 Gbps" }, { "displayText": "10 Gbps", "id": "e2fd022e-25c7-1ca8-2a6a-d1a9aa9265cf", "sequence": 180, "value": "10 Gbps" } ], "default": [ ], "selectedItem": { "displayText": "50 Mbps", "id": "f7bc4c42-ca8b-bd24-832f-a4a106b8173b", "sequence": 30, "value": "50 Mbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000051zQAAQ", "attributecategoryid__c": "a7ae0000000Em9yAAC", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_ROLLUP_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "25", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Rollup Bandwidth", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": false, "ishidden__c": true, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008jhHEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Text", "value__c": null, "valuedatatype__c": "Text", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Text", "uiDisplayType": "Text", "value": null }, "$$AttributeDefinitionEnd$$": null } ], "FTR_ENT_TECH_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000051zcAAA", "attributecategoryid__c": "a7ae0000000Em9zAAC", "categorycode__c": "FTR_ENT_TECH_ATTCAT", "categoryname__c": "Technical Attributes", "attributeuniquecode__c": "ATTR_FRAME_SIZE", "attributeconfigurable__c": true, "attributedisplaysequence__c": "20", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Frame Size", "displaysequence__c": "null", "categorydisplaysequence__c": 20, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008jhQEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": "<=1600", "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "default": [ { "displayText": "<=1600", "id": "100426e7-141e-e712-d202-03ac94b15f12", "sequence": 10, "value": "<=1600" } ], "values": [ { "displayText": "<=1600", "id": "100426e7-141e-e712-d202-03ac94b15f12", "sequence": 10, "value": "<=1600" }, { "displayText": "<=9000", "id": "684b7c89-9384-fcb6-0e59-355b342cbf52", "sequence": 20, "value": "<=9000" } ], "selectedItem": { "displayText": "<=1600", "id": "100426e7-141e-e712-d202-03ac94b15f12", "sequence": 10, "value": "<=1600" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000051ziAAA", "attributecategoryid__c": "a7ae0000000Em9zAAC", "categorycode__c": "FTR_ENT_TECH_ATTCAT", "categoryname__c": "Technical Attributes", "attributeuniquecode__c": "ATTR_PHY_MEDIUM", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Physical Medium", "displaysequence__c": "null", "categorydisplaysequence__c": 20, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008jhNEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": "Copper RJ45", "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "default": [ { "displayText": "Copper RJ45", "id": "cd3d6291-1b1e-6a97-3139-9973a3219c3b", "sequence": 10, "value": "Copper RJ45" } ], "values": [ { "displayText": "Copper RJ45", "id": "cd3d6291-1b1e-6a97-3139-9973a3219c3b", "sequence": 10, "value": "Copper RJ45" }, { "displayText": "Fiber Single Mode 1310nm", "id": "965bb435-fa30-4a87-946c-998f74350bb7", "sequence": 20, "value": "Fiber Single Mode 1310nm" }, { "displayText": "Fiber Multi Mode 850nm", "id": "f699b668-e0a8-b724-1ace-fa122773c63f", "sequence": 30, "value": "Fiber Multi Mode 850nm" } ], "selectedItem": { "displayText": "Copper RJ45", "id": "cd3d6291-1b1e-6a97-3139-9973a3219c3b", "sequence": 10, "value": "Copper RJ45" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000051zjAAA", "attributecategoryid__c": "a7ae0000000Em9zAAC", "categorycode__c": "FTR_ENT_TECH_ATTCAT", "categoryname__c": "Technical Attributes", "attributeuniquecode__c": "ATTR_PORT_SPEED", "attributeconfigurable__c": true, "attributedisplaysequence__c": "1", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Port Speed", "displaysequence__c": "null", "categorydisplaysequence__c": 20, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008jhLEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Text", "value__c": "1G", "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Text", "default": [ { "displayText": "1G", "id": "4c6c13ba-a992-2f43-ac06-535eb430dc21", "sequence": 10, "value": "1G" } ], "values": [ { "displayText": "1G", "id": "4c6c13ba-a992-2f43-ac06-535eb430dc21", "sequence": 10, "value": "1G" }, { "displayText": "10 GBPS", "id": "52b0dc97-e975-ec49-639e-884009fa8f94", "sequence": 20, "value": "10 GBPS" } ], "selectedItem": { "displayText": "1G", "id": "4c6c13ba-a992-2f43-ac06-535eb430dc21", "sequence": 10, "value": "1G" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000053NrAAI", "attributecategoryid__c": "a7ae0000000Em9zAAC", "categorycode__c": "FTR_ENT_TECH_ATTCAT", "categoryname__c": "Technical Attributes", "attributeuniquecode__c": "ATTR_TECH_JURISDICTION", "attributeconfigurable__c": true, "attributedisplaysequence__c": "40", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Jurisdiction", "displaysequence__c": "null", "categorydisplaysequence__c": 20, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008l2TEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": "Interstate", "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "default": [ { "displayText": "Interstate", "id": "41baec4f-2bd6-e788-da02-00fa0b85253b", "sequence": 10, "value": "Interstate" } ], "values": [ { "displayText": "Interstate", "id": "41baec4f-2bd6-e788-da02-00fa0b85253b", "sequence": 10, "value": "Interstate" }, { "displayText": "Intrastate", "id": "a3aa8c06-69da-5379-9dea-a4c1b1d51d04", "sequence": 20, "value": "Intrastate" } ], "selectedItem": { "displayText": "Interstate", "id": "41baec4f-2bd6-e788-da02-00fa0b85253b", "sequence": 10, "value": "Interstate" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be000000051zvAAA", "attributecategoryid__c": "a7ae0000000Em9zAAC", "categorycode__c": "FTR_ENT_TECH_ATTCAT", "categoryname__c": "Technical Attributes", "attributeuniquecode__c": "ATTR_VLAN_TAG", "attributeconfigurable__c": true, "attributedisplaysequence__c": "40", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "VLAN Tag Config", "displaysequence__c": "null", "categorydisplaysequence__c": 20, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008jhSEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": "Service Multiplexing", "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "default": [ { "displayText": "Service Multiplexing", "id": "5617aa92-ef1f-e9eb-48b0-7d2b53a8afab", "sequence": 10, "value": "Service Multiplexing" } ], "values": [ { "displayText": "Service Multiplexing", "id": "5617aa92-ef1f-e9eb-48b0-7d2b53a8afab", "sequence": 10, "value": "Service Multiplexing" }, { "displayText": "All-to-one Bundling", "id": "ac6ee353-a706-bf12-b0f4-05e771f656c2", "sequence": 20, "value": "All-to-one Bundling" }, { "displayText": "Untagged", "id": "eb86808f-1b45-623b-b7f2-a266b16db51d", "sequence": 30, "value": "Untagged" } ], "selectedItem": { "displayText": "Service Multiplexing", "id": "5617aa92-ef1f-e9eb-48b0-7d2b53a8afab", "sequence": 10, "value": "Service Multiplexing" } }, "$$AttributeDefinitionEnd$$": null },{"$$AttributeDefinitionStart$$":null,"categorycode__c":"FTR_ENT_TECH_ATTCAT","attributeid__c":"a7b0m000000DCWdAAO","attributeuniquecode__c":"ATTR_WaitFor_ComboOrder","attributedisplayname__c":"Wait for Combo Order","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":false},"Name":"Wait for Combo Order","Code":"ATTR_WaitFor_ComboOrder","Filterable":false,"SegmentValue":"false","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"FTR_ENT_TECH_ATTCAT","attributeid__c":"a7b0m000000DCWTAA4","attributeuniquecode__c":"ATTR_ISComboOrder","attributedisplayname__c":"IsComboOrder","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"True","value":"True"},"Name":"IsComboOrder","Code":"ATTR_ISComboOrder","Filterable":false,"SegmentValue":"True","$$AttributeDefinitionEnd$$":null} ], "FTR_ENT_USERDATA_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be0000000536pAAA", "attributecategoryid__c": "a7ae0000000Ems6AAC", "categorycode__c": "FTR_ENT_USERDATA_ATTCAT", "categoryname__c": "UserData Attributes", "attributeuniquecode__c": "ATTR_COMPANY_INDICATOR", "attributeconfigurable__c": true, "attributedisplaysequence__c": "500", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "COMPANY INDICATOR", "displaysequence__c": "null", "categorydisplaysequence__c": 70, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": false, "ishidden__c": true, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008jhWEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Text", "value__c": null, "valuedatatype__c": "Text", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Text", "uiDisplayType": "Text", "value": "204" }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h0000063RFeAAM", "attributeid__c": "a7be0000000536qAAA", "attributecategoryid__c": "a7ae0000000Ems6AAC", "categorycode__c": "FTR_ENT_USERDATA_ATTCAT", "categoryname__c": "UserData Attributes", "attributeuniquecode__c": "ATTR_NPA_NXX", "attributeconfigurable__c": true, "attributedisplaysequence__c": "510", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "NPA NXX", "displaysequence__c": "null", "categorydisplaysequence__c": 70, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": false, "ishidden__c": true, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Ye00000008jhXEAQ", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Text", "value__c": null, "valuedatatype__c": "Text", "valuedescription__c": null, "attributegrouptype__c": null, "attributeRunTimeInfo": { "dataType": "Text", "uiDisplayType": "Text", "value": "928537" }, "$$AttributeDefinitionEnd$$": null } ] }'; 
        td.testOpportunityProduct.vlocity_cmt__JSONAttribute__c =jsonAttribute;
        td.testOpportunityProduct.Opportunity_Sync__c = 'Vlocity';
        td.testOpportunityProduct.vlocity_cmt__ServiceAccountId__c = ftr_TestDataFactory.getAccounts(1)[0].Id;
        td.testOpportunityProduct.Term_Months__c = 60;
        td.testOpportunityProduct.vlocity_cmt__OneTimeCharge__c = 1;
        td.testOpportunityProduct.ftr_isApplyDiscount__c = true;
        td.testOpportunityProduct.Product2.ProductCode  = 'ENT_ETH_EIA_0002';
        td.testOpportunityProduct.ftr_DiscountPrice__c = 100;
        td.testOpportunityProduct.UnitPrice=100;
        //Test.startTest();
        System.debug('----OpportunityLineItem ----'+td.testOpportunityProduct);
        Quote_Line_Item_Product_Wrapper testQLIPW = new Quote_Line_Item_Product_Wrapper(td.testOpportunityProduct);
        //Test.stopTest();
    }

    @IsTest
    public static void sqi_oli_zaddr_constructor_test() {
        TestData td = new TestData();
        Quote_Line_Item_Product_Wrapper testQLIPW = new Quote_Line_Item_Product_Wrapper(td.testQuoteItem, td.testOpportunityProduct, null);
        Quote_Line_Item_Product_Wrapper testQLIPW2 = new Quote_Line_Item_Product_Wrapper(td.testQuoteItem, td.testOpportunityProduct);
        system.assert(testQLIPW.name == td.testOpportunityProduct.Product2.Name);
        system.assert(testQLIPW2.name == td.testOpportunityProduct.Product2.Name);
    }

    @IsTest
    private static Void isNotAdditionalChargeProduct_Test() {
        Quote_Line_Item_Product_Wrapper testQLIPW = getTestQLIPW();
        Boolean res = Quote_Line_Item_Product_Wrapper.isNotAdditionalChargeProduct(testQLIPW);
        System.assert(res, 'Res should have been true but was ' + res);

        testQLIPW.name = 'Surcharge';
        res = Quote_Line_Item_Product_Wrapper.isNotAdditionalChargeProduct(testQLIPW);
        System.assert(!res, 'Res should have been false because name containing Surcharge indicates an additional charge product, but was ' + res);
    }

    @IsTest
    private static Void isNotDiscounted_Test() {
        Quote_Line_Item_Product_Wrapper qlipw = getTestQLIPW();
        //Test.Starttest();
        Boolean res = Quote_Line_Item_Product_Wrapper.isNotDiscounted(qlipw);
        System.assert(res, 'Default Discount Type is empty, so Res should have been true indicating no discount, but was ' + res);

        qlipw.discountType = 'ICB';
        qlipw.overallStatus = 'Approved';
        res = Quote_Line_Item_Product_Wrapper.isNotDiscounted(qlipw);
        System.assert(res, 'Overall Status is Approved, so Res should have been true indicating no discount, but was ' + res);

        qlipw.overallStatus = '';
        res = Quote_Line_Item_Product_Wrapper.isNotDiscounted(qlipw);
        //Test.Stoptest();
        System.assert(!res, 'Discount Type is ICB, so Res should have been false indicating the product was discounted, but was ' + res);
    }

    @IsTest
    private static Void removeChallengerAndLeader_Test() {
        String res = Quote_Line_Item_Product_Wrapper.removeChallengerAndLeader('');
        System.assert(res == '', 'Response should have been empty string but was ' + res);

        res = Quote_Line_Item_Product_Wrapper.removeChallengerAndLeader('Test1');
        System.assert(res == 'Test1', 'Response should have been Test1 but was ' + res);

        res = Quote_Line_Item_Product_Wrapper.removeChallengerAndLeader('Test2 - Challenger');
        System.assert(res == 'Test2', 'Response should have been Test2 but was ' + res);

        res = Quote_Line_Item_Product_Wrapper.removeChallengerAndLeader('Test3 - Leader');
        System.assert(res == 'Test3', 'Response should have been Test3 but was ' + res);

        res = Quote_Line_Item_Product_Wrapper.removeChallengerAndLeader('Challenger');
        System.assert(res == '', 'Response should have been empty string but was ' + res);

        res = Quote_Line_Item_Product_Wrapper.removeChallengerAndLeader('Leader');
        System.assert(res == '', 'Response should have been empty string but was ' + res);
    }

    @IsTest
    private static Void getOppProductToAdd_Test() {
        Quote_Line_Item_Product_Wrapper res = Quote_Line_Item_Product_Wrapper.getOppProductToAdd(getTestQLIPW());
        System.assert(res != null, 'Response was null');
    }

    @IsTest
    private static Void getQuickQuoteWrappers_Test() {
        TestData td = new TestData();
        //Test.startTest();
        system.debug('td@@@@@@@'+td);
        system.debug('td Opp Id @@@@@@@'+td.testOpportunity.Id);
        system.debug('td Quote id @@@@@@@'+td.testQuote.Id);
        List<Quote_Line_Item_Product_Wrapper> res = Quote_Line_Item_Product_Wrapper.getQuickQuoteWrappers(td.testOpportunity.Id, td.testQuote.Id);
        System.assert(res != null && res.size() > 0, 'Response came back empty');
        //Test.stopTest();
    }

    @IsTest
    private static Void getTotalQuickQuoteValue_test() {
        Decimal res = Quote_Line_Item_Product_Wrapper.getTotalQuickQuoteValue(new List<Quote_Line_Item_Product_Wrapper>{ getTestQLIPW() });
        System.assert(res > 0, 'getTotalQuickQuoteValue should have returned a positive value but returned 0.');
    }
    
    @IsTest
    private static Void getOneTimeTotalQuickQuoteValue_test() {
        Decimal res = Quote_Line_Item_Product_Wrapper.getOneTimeTotalQuickQuoteValue(new List<Quote_Line_Item_Product_Wrapper>{ getTestQLIPW() });
        
    }
    
    @IsTest
    private static Void getMonthlyTotalQuickQuoteValue_test() {
        Decimal res = Quote_Line_Item_Product_Wrapper.getMonthlyTotalQuickQuoteValue(new List<Quote_Line_Item_Product_Wrapper>{ getTestQLIPW() });
        
    }

    
}