/**
* @description       : This test class covers the following Apex classes:
*      ftr_CpqHelper
*      TBD_CLASS2
*      TBD_CLASS3
* @author            : TBD
* @version           : 2 
**/ 
@isTest
public class ftr_CpqHelperTest {
    
    //@TestSetup
    static void makeData(){
        vlocity_cmt__CpqConfigurationSetup__c setting = new vlocity_cmt__CpqConfigurationSetup__c();
        setting.Name = 'DefaultPricingPlan';
        setting.vlocity_cmt__SetupValue__c = 'True';
        insert setting;
        
        Integer numOfQLIforEachQuote = 2;
        Integer numOfQuote = 1;
        List<QuoteLineItem> qlis = ftr_TestDataFactory.getQLI(numOfQLIforEachQuote, numOfQuote);
        insert qlis;
    }
    
    @isTest
    static void getCpqConfigurationSetupValueTest(){
        vlocity_cmt__CpqConfigurationSetup__c cpqSetup = new vlocity_cmt__CpqConfigurationSetup__c();
        cpqSetup.name = 'DefaultPricingPlan';
        cpqSetup.vlocity_cmt__SetupValue__c = 'DEFAULT_PRICING_PLAN';
        insert cpqSetup;
        String setupName = 'DefaultPricingPlan';
        test.startTest();
        String retval = ftr_CpqHelper.getCpqConfigurationSetupValue(setupName);
        test.stopTest();
        System.assertEquals('DEFAULT_PRICING_PLAN', retval);
    }
    
    @isTest
    static void getJSONAttributeValuesTest(){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_JSONAttribute_Access' LIMIT 1];
        String jsonAttribute = sr.body.toString();
        
        Map<String, Object> attrVals =  ftr_CpqHelper.getJSONAttributeValues(jsonAttribute);
        
        System.assertEquals('50 Mbps', (String)attrVals.get('ATTR_BANDWIDTH'));
    }
    
    @isTest
    static void getJSONAttributeValueTest(){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_JSONAttribute_Access' LIMIT 1];
        
        String jsonAttribute = sr.body.toString();
        String attribCode = 'ATTR_BANDWIDTH';
        String attVal = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, attribCode);
        
        System.assertEquals('50 Mbps', attVal);
    }
    
    @isTest
    static void setJSONAttributeTest(){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_JSONAttribute_Access' LIMIT 1];
        String runtimeJSON = sr.body.toString(); 
        String originalJSON = '{}'; 
        
        String code = 'ATTR_CONTRACT_TERM';
        Object val = '12 Months';
        test.startTest();
        String modifiedJSON = ftr_CpqHelper.setJSONAttribute(runtimeJSON, originalJSON, code, val);
        test.stopTest();
        
        System.assertEquals(val, ftr_CpqHelper.getJSONAttributeValue(modifiedJSON, code));
    }
    
    @isTest
    static void setJSONAttributesTest(){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'ftr_TD_JSONAttribute_Access' LIMIT 1];
        String runtimeJSON = sr.body.toString(); 
        String originalJSON = '{}'; 
        Map<String, Object> attrVals = new Map<String, Object> {
            'ATTR_CONTRACT_TERM' => '12 Months'
                };
                    test.startTest();
        String modifiedJSON = ftr_CpqHelper.setJSONAttributes(runtimeJSON, originalJSON, attrVals);
        test.stopTest();
        System.assertEquals('12 Months', ftr_CpqHelper.getJSONAttributeValue(modifiedJSON, 'ATTR_CONTRACT_TERM'));
    }
    
    @isTest
    static void setQLIsAttributeTest(){
        String attVal = '12 Months';
        List<QuoteLineItem> qLIs = [SELECT Id, vlocity_cmt__JSONAttribute__c FROM QuoteLineItem];
        String attCode = 'ATTR_CONTRACT_TERM';
        test.startTest();
        List<QuoteLineItem> qLIsOutput = ftr_CpqHelper.setQLIsAttribute(attVal, qLIs, attCode);
        test.stopTest();
    }
    
    @isTest
    static void convertToSpeedTest(){
        String bandWidth = '20 Mbps';
        String bandWidth1 = '30 GB';
        String bandWidth2 = '40 G';
        String bandWidth3 = '50 GBPS';
        String bandWidth4 = '60 Mbps';
        String bandWidth5 = '70 M';
        test.startTest();
        Integer speed = ftr_CpqHelper.convertToSpeed(bandWidth);
        // Integer speed1 = ftr_CpqHelper.convertToSpeed(bandWidth1);
        //Integer speed2 = ftr_CpqHelper.convertToSpeed(bandWidth2);
        //Integer speed3 = ftr_CpqHelper.convertToSpeed(bandWidth3);
        // Integer speed4 = ftr_CpqHelper.convertToSpeed(bandWidth4);
        //Integer speed5 = ftr_CpqHelper.convertToSpeed(bandWidth5);
        test.stopTest();
        System.assertEquals(20, speed);
        // System.assertEquals(30, speed1);
        //System.assertEquals(40, speed2);
        //System.assertEquals(50, speed3);
        //System.assertEquals(60, speed4);
        //System.assertEquals(70, speed5);
    }
    
    @isTest
    static void convertToSpeedGbpsTest(){
        String bandWidth = '20 Gbps';
        test.startTest();
        Integer speed = ftr_CpqHelper.convertToSpeed(bandWidth);
        test.stopTest();
        System.debug('speed gbps..'+ speed);
        System.assertEquals(20000, speed);
    }
    
    @isTest
    static void convertToBandWidthTest(){
        Integer speed = 20;
        test.startTest();
        String bandwidth = ftr_CpqHelper.convertToBandWidth(speed);
        test.stopTest();
        System.assertEquals('20 Mbps', bandwidth);
    }
    
    @isTest
    static void testAsyncCheckout(){
        Quote q = ftr_TestDataFactory.getQuotes(1)[0];
        test.startTest();
        ftr_CpqHelper.checkoutAsync(q.Id);
        test.stopTest();
    }
    
    @isTest
    static void testSetOLIsAttribute(){
        List<OrderItem> oLIs = ftr_TestDataFactory.getOrderItems(2, new Map<string,string>{'Test'=>'TestCode'});
        test.startTest();
        ftr_CpqHelper.setOLIsAttribute('test', oLIs, 'TEST');
        test.stopTest();
    }
    @isTest
    static void testSetQLIsAttribute(){
        List<QuoteLineItem> qLIs = ftr_TestDataFactory.getQLI(2, 1);
        test.startTest();
        ftr_CpqHelper.setQLIsAttribute('test', qLIs, 'TEST');
        test.stopTest();
    }
    
    static Map<String, String> prodNameCodeMap = new Map<String, String>{ 
        'M6 UNI PSR CFS' => 'ENT_ETH_UNI_PSR_001' 
            };
                static Map<String, String> prodNameCodeMap1 = new Map<String, String>{ 
                    'M6 DIA PSR CFS' => 'ENT_ETH_UNI_PSR_001' 
                        };
                            
                            @isTest//TestSetup
                            static void testMACDCompareOLIToAsset() {
                                //  Account[] accounts = ftr_TestDataFactory.getAccounts(1);
                                // insert accounts;
                                Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
                                Account globalAcc1 = new Account();
                                globalAcc1.Name = 'GLOBAL ACCOUNT';
                                globalAcc1.RecordTypeId = globalRecId;
                                //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
                                insert globalAcc1;
                                //  Id GlobalRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();
                                Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
                                
                                Account accounts = new Account(Name = 'TestAccount'); 
                                accounts.RecordTypeId = MasterRTId;
                                accounts.ParentId = globalAcc1.Id;
                                insert accounts;
                                Order order = new Order (
                                    Name = 'Test Order',
                                    AccountId = accounts.Id,
                                    Status = 'Draft',
                                    Pricebook2Id = Test.getStandardPricebookId(),
                                    Product__c = 'EIA',
                                    Product_Type__c = 'Ethernet',
                                    Router_s__c = 'No Router',
                                    //Customer_Requested_Date__c = System.today(),
                                    EffectiveDate = System.today(),
                                    BillingStreet = '123 Main Street',
                                    BillingCity = 'Anywhere',
                                    BillingState = 'Texas',
                                    BillingStateCode = 'TX',
                                    BillingPostalCode = '44088',
                                    ShippingStreet = '123 Main Street',
                                    ShippingCity = 'Anywhere',
                                    ShippingState = 'Texas',
                                    ShippingStateCode = 'TX',
                                    ShippingPostalCode = '44088'
                                );
                                insert order;
                                OrderItem[] orderItems = ftr_TestDataFactory.getOrderItems(2, prodNameCodeMap);
                                orderItems[0].OrderId = order.Id;
                                orderItems[1].OrderId = order.Id;
                                
                                insert orderItems;
                                orderItems[0].UNI_Host__c = orderItems[1].Id;
                                update orderItems;
                                Asset asset1= new Asset(
                                    Name = 'Test',
                                    vlocity_cmt__OrderProductId__c = orderItems[0].Id,
                                    Product2Id = orderItems[0].Product2Id, 
                                    vlocity_cmt__PricebookEntryId__c = orderItems[0].PricebookEntryId,
                                    vlocity_cmt__JSONAttribute__c = orderItems[0].vlocity_cmt__JSONAttribute__c, 
                                    Quantity = 1,
                                    Price = 0.00,
                                    AccountId = order.AccountId
                                );
                                
                                insert asset1;
                                
                                orderItems[0].vlocity_cmt__AssetId__c = asset1.Id;
                                OrderItems[0].vlocity_cmt__AssetReferenceId__c = '123456';
                                OrderItems[0].vlocity_cmt__Action__c = 'Change';
                                update OrderItems[0];
                                
                                List<vlocity_cmt__FulfilmentRequestLine__c> frlList = ftr_TestDataFactory.getFulfilmentRequestLines(1, prodNameCodeMap);
                                vlocity_cmt__FulfilmentRequestLine__c frlLine = frlList.get(0);
                                String originalJSON = '{}'; 
                                String runtimeJSON = frlLine.vlocity_cmt__JSONAttribute__c;
                                ftr_CpqHelper.setJSONAttribute(runtimeJSON, originalJSON, 'ATTR_MACD_Order_Action', 'Change');
                                frlLine.vlocity_cmt__JSONAttribute__c = runtimeJSON;
                                frlLine.vlocity_cmt__Action__c = 'Modify';
                                insert frlLine;
                                ftr_CpqHelper.compareOLIAndAssetJSONAttributesForChangeOrder(frlLine);
                                List<vlocity_cmt__FulfilmentRequestLine__c> frlList1 = ftr_TestDataFactory.getFulfilmentRequestLines(1, prodNameCodeMap1);
                                vlocity_cmt__FulfilmentRequestLine__c frlLine1 = frlList1.get(0);
                                String originalJSON1 = '{}'; 
                                String runtimeJSON1 = frlLine.vlocity_cmt__JSONAttribute__c;
                                ftr_CpqHelper.setJSONAttribute(runtimeJSON1, originalJSON1, 'ATTR_MACD_Order_Action', 'Change');
                                frlLine1.vlocity_cmt__JSONAttribute__c = runtimeJSON1;
                                frlLine1.vlocity_cmt__Action__c = 'Modify';
                                insert frlLine1;
                                ftr_CpqHelper.compareOLIAndAssetJSONAttributesForChangeOrder(frlLine1);
                            }
    @istest
    static void loadChangedJSONAttributesForDIATest() {
        Map<String, Object> oliJsonAttributesMap = new Map<String, Object>{'ATTR_BANDWIDTH' => '50 Mbps',
            'ATTR_TOPO' => '123',
            'ATTR_IP_BLOCKS' => '12','ATTR_VLAN_TAG' => '12', 'ATTR_DECOMP_WTN' => '12345678'};
                Map<String, Object> assetJsonAttributesMap = new Map<String, Object>{'ATTR_BANDWIDTH' => '5 Mbps',
                    'ATTR_TOPO' => '1234',
                    'ATTR_IP_BLOCKS' => '12908','ATTR_VLAN_TAG' => '12867', 'ATTR_DECOMP_WTN' => '12345610'};
                        List<Object> temp = new List<Object>{'123'};
                        Map<String, List<Object>> changedAttributesMap = new Map<String, List<Object>>{'CA_ATTRIBUTES' => temp};
                            Map<String, List<Object>> temp1 = ftr_CpqHelper.loadChangedJSONAttributesForDIA(oliJsonAttributesMap,assetJsonAttributesMap,changedAttributesMap);
    }
}