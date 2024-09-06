@isTest
public with sharing class QueryELANLinesTest {
    @isTest
    static void QueryELANLinesTestSEfalse() {
                
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        //String OrderId=(String)elanOrder.Id;
        String OrderId='801Ei00000CTfdcIAD';
        inputMap.put('ContextId',OrderId);
        String str='{"ELANProductsBlock":[{"PremiseNetworkType":"HBE","HbeEditable":true,"HBEManuallyUpdated":false,"HBEId":true,"ExistingCheckBox":false,"ELANSpeedText":"10 Gbps","ELANId":"802Ei000004PAI1IAO","ELANAddressText":"185 South Lake Shore Way, Lake Alfred, FL  33850","ClassOfService":"Silver"},{"PremiseNetworkType":"Legacy","HbeEditable":false,"HBEManuallyUpdated":false,"HBEId":false,"ExistingCheckBox":false,"ELANSpeedText":"1 Gbps","ELANId":"802Ei000004PAI2IAO","ELANAddressText":"4901 West Grace Street, Tampa, FL  33607","ClassOfService":"Silver"},{"PremiseNetworkType":"HBE","HbeEditable":true,"HBEManuallyUpdated":false,"HBEId":true,"ExistingCheckBox":false,"ELANSpeedText":"5 Gbps","ELANId":"802Ei000004PAI3IAO","ELANAddressText":"2240 62nd Avenue South, St. Petersburg, FL  33712","ClassOfService":"Silver"}]}';
       
        
        inputMap.put('StaticResourceName',str);
        
        
        Test.startTest();
        QueryELANLines ftrelan = new QueryELANLines();        
        ftrelan.QueryELANLines(inputMap, outputMap, options);     
        Test.stopTest();
    }
	
    @isTest
    static void QueryELANLinesTestSEtrue() {        
        
		Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        //String OrderId=(String)elanOrder.Id;
        String OrderId='801Ei00000CTfdcIAD';
        inputMap.put('ContextId',OrderId);
        String str='{"ELANProductsBlock":[{"PremiseNetworkType":"Both","OEMIdLegacy":"SLA HUB 1","OEMIdHBE":"SLA HUB 1","HbeEditable":true,"HBEManuallyUpdated":false,"HBEId":true,"ExistingCheckBox":false,"ELANSpeedText":"200 Mbps","ELANNetwork":1,"ELANId":"802Ei000004P1zpIAC","ELANAddressText":"3888 Workman Mill Road, Whittier, CA  90601","ClassOfService":"Silver"},{"PremiseNetworkType":"HBE","OEMIdLegacy":"SLA HUB 2","OEMIdHBE":"SLA HUB 2","HbeEditable":true,"HBEManuallyUpdated":false,"HBEId":true,"ExistingCheckBox":false,"ELANSpeedText":"10 Gbps","ELANNetwork":1,"ELANId":"802Ei000004P1zqIAC","ELANAddressText":"185 South Lake Shore Way, Lake Alfred, FL  33850","ClassOfService":"Silver"},{"Prepopulateforsplit":"11/AAAA/123456/21","PremiseNetworkType":"Both","OEMIdLegacy":"SLA Remote","OEMIdHBE":"SLA Remote","HbeEditable":true,"HBEManuallyUpdated":false,"HBEId":true,"ExistingCheckBox":true,"ELANSpeedText":"30 Mbps","ELANId":"802Ei000004P1zrIAC","ELANAddressText":"610 North Morgan Street, Tampa, FL  33602","ClassOfService":"Silver","CircuitIDText":"11/AAAA/123456/21"}]}';   
 
        inputMap.put('StaticResourceName',str);
		
        Test.startTest();
        QueryELANLines ftrelan = new QueryELANLines();        
        ftrelan.QueryELANLines(inputMap, outputMap, options);     
        Test.stopTest();
    }
    

    @isTest
    static void testBothNetworkTypeWithSpeedGreaterThan500AndSilverCOS() {
        
        Boolean result = QueryELANLines.IsElanHbeBySpeedCos('600 Mbps', 'Silver', 'Both');
        System.assertEquals(true, result, 'Both Network Type with speed greater than 500 and Silver COS should return true');
    }

    @isTest
    static void testBothNetworkTypeWithSpeedLessThan500AndNonSilverCOS() {
        
        Boolean result = QueryELANLines.IsElanHbeBySpeedCos('400 Mbps', 'Gold', 'Both');
        System.assertEquals(true, result, 'Both Network Type with speed less than 500 and non-Silver COS should return true');
    }

    @isTest
    static void testHBEType() {
        
        Boolean result = QueryELANLines.IsElanHbeBySpeedCos('800 Mbps', 'Platinum', 'HBE');
        System.assertEquals(true, result, 'HBE Network Type should return true');
    }

    @isTest
    static void testLegacyType() {
        
        Boolean result = QueryELANLines.IsElanHbeBySpeedCos('300 Mbps', 'Silver', 'Legacy');
        System.assertEquals(false, result, 'Legacy Network Type should return false');
    }



    
}