/*****
* @author Sean Fife
* @date 2 Nov 2019
* @group Vlocity Component Implementations
* @description Test class for Custom functions unavailable to Vlocity Components
* @version : 3
*/ 
@isTest
public class customFunctionForDRTest {

   static String drInput = '{"FTR_ENT_TECH_ATTCAT":[{"value":"TEST_OSCHESTRATION","characteristic":"CorrelationId"},{"value":"1","characteristic":"GroupOrderTransactionCount"}],"FTR_ENT_CUSTOMER_ATTCAT":[{"value":"null","characteristic":"BusinessOwnerName"},{"value":"Business","characteristic":"CustomerType"},{"value":"3","characteristic":"CreditRating"},{"value":"1234567890","characteristic":"BusinessOwnerTelephone"}],"FTR_ENT_CUSTOMERORDER_ATTCAT":[{"value":"Add","characteristic":"Action"},{"value":"null","characteristic":"SNE_Code_TERM"},{"value":"SSINS","characteristic":"SNE_Code_OTC"},{"value":"100SA","characteristic":"SNE_Code_MRC"},{"value":"660.00","characteristic":"RecurringCharge"},{"value":"1.00","characteristic":"Quantity"},{"value":"250.00","characteristic":"OneTimeTotal"},{"value":"NO_INSTALL","characteristic":"InstallationType"},{"value":"BNR22","characteristic":"IP_SNE_Code_OTC"},{"value":"BIP22","characteristic":"IP_SNE_Code_MRC"},{"value":"EVP1Y","characteristic":"EVPL_SNE_Code_TERM"},{"value":"SSINS","characteristic":"EVPL_SNE_Code_OTC"},{"value":"01KSE","characteristic":"EVPL_SNE_Code_MRC"},{"value":"INSTALL","characteristic":"CustomerOrderType"}],"FTR_ENT_CUSTOMERACCOUNT_ATTCAT":[{"value":"65","characteristic":"AccountServiceType"},{"value":"0000000000","characteristic":"WorkingTelephoneNumber"},{"value":"AJ Test Company 1","characteristic":"TradingName"},{"value":"75057","characteristic":"ServLocZipCode"},{"value":"591 Northside Avenue","characteristic":"ServLocStreetAddress"},{"value":"TX","characteristic":"ServLocStateAbbreviation"},{"value":"Lewisville","characteristic":"ServLocCityName"},{"value":"false","characteristic":"IsFederalTaxExempt"},{"value":"1480 North Valley Parkway","characteristic":"InterLocStreetAddress"},{"value":"TX","characteristic":"InterLocStateAbbreviation"},{"value":"75077","characteristic":"InterLocPostalCode"},{"value":"Lewisville","characteristic":"InterLocCityName"},{"value":"M","characteristic":"BillHandlingCode"},{"value":"PARTIAL","characteristic":"BillDetailLevel"}]}';

    @IsTest
    static void invertArray(){

         List<object> SA = (List<object>)JSON.deserializeUntyped('[' + 
            '{"Premise_Detail__c": "13517 Little Bear Creek Pl, Woodinville, 980725521","Id": "0011900000lkknBAAQ"}' + ',' + 
            '{"Premise_Detail__c": "1 Main St, Orlando, 32830","Id": "0011900000n3KvmAAE"}' + 
            ']');
        List<object> Line = (List<object>)JSON.deserializeUntyped('[' + 
            '{"vlocity_cmt__ServiceAccountId__c": "0011900000n3KvmAAE","RecurringTotal": "$252.00","OneTimeTotal": "$0.00","LineNumber": "0001.0001","Quantity": 1,"Tier": "Tier 1","SLA": "Platinum","Term": "24 Months","Speed": "100 Mbps","ProductObjectType": "a9719000000AoJ5AAK","ProductCode": "ENT_ETH_EVC_0001","Name": "EVC","ProductFamily": "Ethernet"}' + ',' +
            '{"vlocity_cmt__ServiceAccountId__c": "0011900000n3KvmAAE","RecurringTotal": "$887.00","OneTimeTotal": "$250.00","LineNumber": "0002.0001","Quantity": 1,"Tier": "Tier 1","Term": "24 Months","Speed": "100 Mbps","ProductObjectType": "a9719000000AoJ5AAK","ProductCode": "ENT_ETH_ACCESS_0001","Name": "Access","ProductFamily": "Ethernet"}' + ',' + 
            '{"vlocity_cmt__ServiceAccountId__c": "0011900000lkknBAAQ","RecurringTotal": "$205.00","OneTimeTotal": "$0.00","LineNumber": "0001.0002","Quantity": 1,"Tier": "Tier 1","SLA": "Gold","Term": "24 Months","Speed": "100 Mbps","ProductObjectType": "a9719000000AoJ5AAK","ProductCode": "ENT_ETH_EVC_0001","Name": "EIA (Ethernet Internet Access)","ProductFamily": "Ethernet"}' + ',' + 
            '{"vlocity_cmt__ServiceAccountId__c": "0011900000lkknBAAQ","RecurringTotal": "$887.00","OneTimeTotal": "$250.00","LineNumber": "0002.0003","Quantity": 1,"Tier": "Tier 1","Term": "24 Months","Speed": "100 Mbps","ProductObjectType": "a9719000000AoJ5AAK","ProductCode": "ENT_ETH_ACCESS_0001","Name": "Access","ProductFamily": "Ethernet"}' +
            ']');

        Map<string, object> inputMap = new Map<string, object>();
        Map<string, object> outputMap = new Map<string, object>();
        Map<string, object> options = new Map<string, object>();
     
        List<object> arguments = new List<object>();
        for(object o : SA)
        {
            arguments.add(o);
        }
        arguments.add('###');
        for(object o : Line)
        {
            arguments.add(o);
        }

        inputMap.put('arguments', arguments);

        customFunctionForDR functions = new customFunctionForDR();
        functions.invokeMethod('invertArray', inputMap, outputMap, options);
    }

    @IsTest
    static void getBooleanValueFromArray(){

         List<object> Line = (List<object>)JSON.deserializeUntyped('[' + 
            '{"vlocity_cmt__ServiceAccountId__c": "0011900000n3KvmAAE","RecurringTotal": "$252.00","OneTimeTotal": "$0.00","LineNumber": "0001.0001","Quantity": 1,"Tier": "Tier 1","SLA": "Platinum","Term": "24 Months","Speed": "100 Mbps","ProductObjectType": "a9719000000AoJ5AAK","ProductCode": "ENT_ETH_EVC_0001","Name": "EVC","ProductFamily": "Ethernet"}' + ',' +
            '{"vlocity_cmt__ServiceAccountId__c": "0011900000n3KvmAAE","RecurringTotal": "$887.00","OneTimeTotal": "$250.00","LineNumber": "0002.0001","Quantity": 1,"Tier": "Tier 1","Term": "24 Months","Speed": "100 Mbps","ProductObjectType": "a9719000000AoJ5AAK","ProductCode": "ENT_ETH_ACCESS_0001","Name": "Access","ProductFamily": "Ethernet"}' + ',' + 
            '{"vlocity_cmt__ServiceAccountId__c": "0011900000lkknBAAQ","RecurringTotal": "$205.00","OneTimeTotal": "$0.00","LineNumber": "0001.0002","Quantity": 1,"Tier": "Tier 1","SLA": "Gold","Term": "24 Months","Speed": "100 Mbps","ProductObjectType": "a9719000000AoJ5AAK","ProductCode": "ENT_ETH_EVC_0001","Name": "EIA (Ethernet Internet Access)","ProductFamily": "Ethernet"}' + ',' + 
            '{"vlocity_cmt__ServiceAccountId__c": "0011900000lkknBAAQ","RecurringTotal": "$887.00","OneTimeTotal": "$250.00","LineNumber": "0002.0003","Quantity": 1,"Tier": "Tier 1","Term": "24 Months","Speed": "100 Mbps","ProductObjectType": "a9719000000AoJ5AAK","ProductCode": "ENT_ETH_ACCESS_0001","Name": "Access","ProductFamily": "Ethernet"}' +
            ']');
       
        Map<string, object> inputMap = new Map<string, object>();
        Map<string, object> outputMap = new Map<string, object>();
        Map<string, object> options = new Map<string, object>();
     
        List<object> arguments = new List<object>();
        for(object o : Line)
        {
            arguments.add(o);
        }
        system.debug(arguments);

        inputMap.put('arguments', arguments);

        customFunctionForDR functions = new customFunctionForDR();
        functions.invokeMethod('getBooleanValueFromArray', inputMap, outputMap, options);
    }

    @IsTest
    static void getLabelName(){
        
        Map<string, object> inputMap = new Map<string, object>();
        Map<string, object> outputMap = new Map<string, object>();
        Map<string, object> options = new Map<string, object>();
     
        List<object> arguments = new List<object>();
        arguments.add('Account');
        arguments.add('Account_Channel__c');
        arguments.add('Partner');

        inputMap.put('arguments', arguments);

        customFunctionForDR functions = new customFunctionForDR();
        functions.invokeMethod('getLabelName', inputMap, outputMap, options);
    }

    @IsTest
    static void getAllPickListValue(){
        
        Map<string, object> inputMap = new Map<string, object>();
        Map<string, object> outputMap = new Map<string, object>();
        Map<string, object> options = new Map<string, object>();
     
       List<object> arguments = new List<object>();
        arguments.add('Account');
        arguments.add('Account_Channel__c');
        arguments.add('Partner');

        inputMap.put('arguments', arguments);

        customFunctionForDR functions = new customFunctionForDR();
        functions.invokeMethod('getAllPickListValue', inputMap, outputMap, options);
    }

    @IsTest
    static void BadMethod()
    {
        customFunctionForDR functions = new customFunctionForDR();
        functions.invokeMethod('replace', null, null, null);
    }    
 
    @IsTest
    static void GetJSONAttributeMap()
    {
        Map<string, object> inputMap = new Map<string, object>();
        Map<string, object> outputMap = new Map<string, object>();
        Map<string, object> options = new Map<string, object>();
     
        List<object> arguments = new List<object>();
        arguments.add('{"vlocity_cmt__ServiceAccountId__c": "0011900000n3KvmAAE","RecurringTotal": "$252.00","OneTimeTotal": "$0.00","LineNumber": "0001.0001","Quantity": 1,"Tier": "Tier 1","SLA": "Platinum","Term": "24 Months","Speed": "100 Mbps","ProductObjectType": "a9719000000AoJ5AAK","ProductCode": "ENT_ETH_EVC_0001","Name": "EVC","ProductFamily": "Ethernet"}');

        inputMap.put('arguments', arguments);
        
        customFunctionForDR functions = new customFunctionForDR();
        functions.invokeMethod('GetJSONAttributeMap', inputMap, outputMap, options);       
    }

    @IsTest
    static void GetJSONMapKeys()
    {
        Map<string, object> inputMap = new Map<string, object>();
        Map<string, object> outputMap = new Map<string, object>();
        Map<string, object> options = new Map<string, object>();
     
        Map<string, object> param1 = new Map<string, object>();
        param1.put('field1', 'value1');
        param1.put('field2', 'value2');
        param1.put('field3', 'value3');
        
        
        List<object> arguments = new List<object>();
        arguments.add(param1);
        arguments.add('NewName');

        inputMap.put('arguments', arguments);

        customFunctionForDR functions = new customFunctionForDR();
        functions.invokeMethod('GetJSONMapKeys', inputMap, outputMap, options);        
    }

    @IsTest
    static void formatZipCode(){
        
        Map<string, object> inputMap = new Map<string, object>();
        Map<string, object> outputMap = new Map<string, object>();
        Map<string, object> options = new Map<string, object>();
     
        List<object> arguments = new List<object>();
        arguments.add('123456789');
        inputMap.put('arguments', arguments);
        customFunctionForDR functions = new customFunctionForDR();
        functions.invokeMethod('formatZipCode', inputMap, outputMap, options);
        arguments = new List<object>();
        arguments.add('12345');
        functions.invokeMethod('formatZipCode', inputMap, outputMap, options);
    }

    @IsTest
    static void getAccessType(){
        
        Map<string, object> inputMap = new Map<string, object>();
        Map<string, object> outputMap = new Map<string, object>();
        Map<string, object> options = new Map<string, object>();
     
        List<object> arguments = new List<object>();
        arguments.add('123456789');
        inputMap.put('arguments', arguments);
        customFunctionForDR functions = new customFunctionForDR();
        try {
            functions.invokeMethod('getAccessType', inputMap, outputMap, options);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    @IsTest
    static void replaceStringTest(){
        
        Map<string, object> inputMap = new Map<string, object>();
        Map<string, object> outputMap = new Map<string, object>();
        Map<string, object> options = new Map<string, object>();
     
        List<object> arguments = new List<object>();
        arguments.add('123456789abc');
        arguments.add('abc');
        arguments.add('0');
        inputMap.put('arguments', arguments);
        customFunctionForDR functions = new customFunctionForDR();
        functions.invokeMethod('replaceString', inputMap, outputMap, options);
    }

    @IsTest
    static void setOpportunityNameTest(){
        
        Map<string, object> inputMap = new Map<string, object>();
        Map<string, object> outputMap = new Map<string, object>();
        Map<string, object> options = new Map<string, object>();
     
        List<object> arguments = new List<object>();
        //arguments.add('testaccname');
        
        List<object> Line = (List<object>)JSON.deserializeUntyped('[' + '{"AccountName":"testaccname"}' +','+
                                                                  '{"vlocity_cmt__ServiceAccountId__c": "0011900000n3KvmAAE","RecurringTotal": "$252.00","OneTimeTotal": "$0.00","LineNumber": "0001.0001","Quantity": 1,"Tier": "Tier 1","SLA": "Platinum","Term": "24 Months","Speed": "100 Mbps","Speed_Mbps__c": "100","ProductObjectType": "a9719000000AoJ5AAK","ProductCode": "ENT_ETH_EVC_0001","Name": "EVC","ProductFamily": "Ethernet"}'+  ',' +
                                                                  
                                                                  '{"vlocity_cmt__ServiceAccountId__c": "0011900000n3KvmAAE","RecurringTotal": "$252.00","OneTimeTotal": "$0.00","LineNumber": "0001.0001","Quantity": 1,"Tier": "Tier 1","SLA": "Platinum","Term": "36 Months","Speed": "1000 Mbps","Speed_Mbps__c": "1000","ProductObjectType": "a9719000000AoJ5AAK","ProductCode": "ENT_ETH_EVC_0001","Name": "EVC","ProductFamily": "Ethernet"}'
                                                                  +']');
        
        inputMap.put('arguments', Line);
        customFunctionForDR functions = new customFunctionForDR();
        functions.invokeMethod('setOpportunityName', inputMap, outputMap, options);
    }


    @IsTest
    static void getAttrVal(){
        
        Map<string, object> inputMap = new Map<string, object>();
        Map<string, object> outputMap = new Map<string, object>();
        Map<string, object> options = new Map<string, object>();
     
        List<object> arguments = new List<object>();
        arguments.add(new Map<String, Object>());
        arguments.add('TEST2');
        inputMap.put('arguments', arguments);
        customFunctionForDR functions = new customFunctionForDR();
        functions.invokeMethod('getAttrVal', inputMap, outputMap, options);
    }

    @IsTest
    static void getNextUNI(){
        
        Map<string, object> inputMap = new Map<string, object>();
        Map<string, object> outputMap = new Map<string, object>();
        Map<string, object> options = new Map<string, object>();
     
        List<object> arguments = new List<object>();
        arguments.add('TEST1');
        arguments.add('TEST2');
        inputMap.put('arguments', arguments);
        customFunctionForDR functions = new customFunctionForDR();
        functions.invokeMethod('getNextUNI', inputMap, outputMap, options);
    }

    @isTest
    static void getRelatedOrderTest(){
        Map<string, object> outputMap = new Map<string, object>();
             Map<String, Object> options = new Map<String, Object>();

        List<object> arguments = new List<object>();
        
         List<Order> oList = ftr_TestDataFactory.getOrders(1);
        oList[0].vlocity_cmt__QuoteId__c = oList[0].QuoteId;
        insert oList;
        Quote q = [select id from quote where id=:oList[0].QuoteId];
        System.debug('quote--'+q);
        arguments.add(q.id);
        Map<string,Object> inputMap = new Map<string,Object>{
            'arguments'=> arguments
                };
        customFunctionForDR custom= new customFunctionForDR();
        custom.invokeMethod('getRelatedOrder', inputMap, outputMap, options);
        
    }
     @isTest
    static void isQuoteHasUCFEquipmentTest(){
        Map<string, object> outputMap = new Map<string, object>();
             Map<String, Object> options = new Map<String, Object>();

        List<object> arguments = new List<object>();
        
         List<Order> oList = ftr_TestDataFactory.getOrders(1);
        oList[0].vlocity_cmt__QuoteId__c = oList[0].QuoteId;
        insert oList;
        Quote q = [select id from quote where id=:oList[0].QuoteId];
        System.debug('quote--'+q);
        arguments.add(q.id);
        Map<string,Object> inputMap = new Map<string,Object>{
            'arguments'=> arguments
                };
        customFunctionForDR custom= new customFunctionForDR();
        custom.invokeMethod('isQuoteHasUCFEquipment', inputMap, outputMap, options);
        
    }

     @IsTest
    static void getCustomerOrderItemBySNE()
    {
        Map<string, object> inputMap = new Map<string, object>();
        Map<string, object> outputMap = new Map<string, object>();
        Map<string, object> options = new Map<string, object>();
     
        List<object> arguments = new List<object>();
      //  arguments.add('{"vlocity_cmt__ServiceAccountId__c": "0011900000n3KvmAAE","RecurringTotal": "$252.00","OneTimeTotal": "$0.00","LineNumber": "0001.0001","Quantity": 1,"Tier": "Tier 1","SLA": "Platinum","Term": "24 Months","Speed": "100 Mbps","ProductObjectType": "a9719000000AoJ5AAK","ProductCode": "ENT_ETH_EVC_0001","Name": "EVC","ProductFamily": "Ethernet"}');
  			arguments.add(JSON.deserializeUntyped(drInput));
        inputMap.put('arguments', arguments);
        
        customFunctionForDR functions = new customFunctionForDR();
        functions.invokeMethod('getCustomerOrderItemBySNE', inputMap, outputMap, options);       
    }
      @IsTest
    static void getCommercialContractItemBySNE()
    {
        Map<string, object> inputMap = new Map<string, object>();
        Map<string, object> outputMap = new Map<string, object>();
        Map<string, object> options = new Map<string, object>();
     
        List<object> arguments = new List<object>();
              //  arguments.add('{"vlocity_cmt__ServiceAccountId__c": "0011900000n3KvmAAE","RecurringTotal": "$252.00","OneTimeTotal": "$0.00","LineNumber": "0001.0001","Quantity": 1,"Tier": "Tier 1","SLA": "Platinum","Term": "24 Months","Speed": "100 Mbps","ProductObjectType": "a9719000000AoJ5AAK","ProductCode": "ENT_ETH_EVC_0001","Name": "EVC","ProductFamily": "Ethernet"}');
		//System.debug(Json.serialize(drInput));
        //arguments.add(drInput);
		arguments.add(JSON.deserializeUntyped(drInput));
        inputMap.put('arguments', arguments);
        
        customFunctionForDR functions = new customFunctionForDR();
        functions.invokeMethod('getCommercialContractItemBySNE', inputMap, outputMap, options);       
    }
    
      @IsTest  
    static void getContactPhone()
    {
        Map<string, object> inputMap = new Map<string, object>();
        Map<string, object> outputMap = new Map<string, object>();
        Map<string, object> options = new Map<string, object>();
     
        List<object> arguments = new List<object>();
        arguments.add(new Map<String, Object>());
        arguments.add('197349547532324');
        inputMap.put('arguments', arguments);
        customFunctionForDR functions = new customFunctionForDR();
        functions.invokeMethod('getContactPhone', inputMap, outputMap, options);
    }
}