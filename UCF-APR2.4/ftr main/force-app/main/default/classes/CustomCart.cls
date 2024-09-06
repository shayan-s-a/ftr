/**
* @author Nicole McGuire
* @date 14 Oct 2019
* @group Vlocity Custom Cart Implementation
* @description Logic needed for roll-up/roll-down logic, pricing logic  
*/  
global with sharing class CustomCart implements vlocity_cmt.VlocityOpenInterface {
    
    // public final static string attributeFieldNameInJSON = 'attributedisplayname__c'; 
    // public final static string attributeuniquecodeInJSON  = 'attributeuniquecode__c';
    // public static Map<String,String> attributeNameDefaultValue;
    // public final static string attributeRunTimeINfoMapNameInJSON = 'attributeRunTimeInfo'; 
    // public final static string picklistDataType = 'Picklist';
    // public final static string dataTypeFieldNameInJSON = 'dataType'; 
    // public final static string runTimeInfoDefaultFieldNameInJSON = 'default'; 
    // public final static string DefaultDisplayTextFieldValueInJSON = 'value';
    // public final static string selectedItemMapNameInJSON = 'selectedItem'; 
    // public final static string selectedItemDisplayTextFieldValueInJSON = 'value'; 
    // public final static string selectedItemDisplayTextFieldNameInJSON = 'displayText'; 
    // public final static string attributeValueFieldNameInJSON = 'value__c';
    // public final static string textDataType = 'Text';
    // public final static string runTimeInfoValueFieldNameInJSON = 'value';
    // public final static string strAccess = 'Access';
    // public static string strAccessId = null;
    // public final static string strEVC = 'EVC';
    // public final static string strEVPL = 'ENT_ETH_EVPL';
    // public final static string strEIA = 'ENT_ETH_EIA';
    // public final static string strID = 'ID';
    // public final static string strTerm  = 'ATTR_CONTRACT_TERM';
    // public final static string strTier  = 'ATTR_TIER';
    // public final static string strBandwidth = 'ATTR_BANDWIDTH';

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, 
                                Map<String, Object> outputMap, Map<String, Object> options) 
    {
        System.debug('customCart-methodName: ' + methodName);
        System.debug('customCart-inputMap: ' + JSON.serialize(inputMap));

        // The code is commentted out and the logic is moved into ftr_CpqAppHandlerHookImpl

        // if( methodName.equalsIgnoreCase('putCartsItems.PreInvoke')) {
        //     putCartsItems_PreInvoke(methodName, inputMap, outputMap, options); 
        //     return true;
        // }
        
        // if( methodName.equalsIgnoreCase('putCartsItems.PostInvoke')) {
        //     putCartsItems_PostInvoke(methodName, inputMap, outputMap,options); 
        //     // Added by Vlocity On 14Jan 2020 to reprice the cart
        //     String contextId = (String) inputMap.get('cartId');
		// 	priceCart(contextId);
            
        //     return true;
        // }
        
        // // Added by Justin Jan 23, 2020
        // if (methodName.equalsIgnoreCase('deleteCartsItems.PreInvoke')) {
        //     System.debug('Enter Into deleteCartsItems.PreInvoke');
        //     vlocity_cmt.JSONAttributeSupport jsonSupport = new vlocity_cmt.JSONAttributeSupport();
        //     Map<String, Object> parentRec = (Map<String, Object>)((List<Object>)(((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)((List<Object>)inputMap.get('items'))[0]).get('parentRecord'))).get('records')))[0];
        //     System.debug('parentRec: ' + JSON.serialize(parentRec));
        //     String parentProductCode = (String)parentRec.get('ProductCode');
        //     if (parentProductCode == 'ENT_ETH_EVPL_0001') { // An EVC is deleted from EVPL (Ethernet Virtual Private Line)
        //         Id quoteId = (Id)inputMap.get('cartId');
        //         Id delQLiId = (Id)inputMap.get('id');
        //         Map<Id, QuoteLineItem> qliMap = new Map<Id, QuoteLineItem>([SELECT Id, Product2.Name, Product2.ProductCode, vlocity_cmt__JSONAttribute__c, vlocity_cmt__Product2Id__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__ServiceAccountId__c FROM QuoteLineItem WHERE QuoteId=:quoteId]);
        //         QuoteLineItem delQLi = qliMap.get(delQLiId);
        //         System.debug('delQLi: ' + JSON.serialize(delQLi));
        //         Id remoteAccessLocationId = delQLi.vlocity_cmt__ServiceAccountId__c;
        //         System.debug('remoteAccessLocationId: ' + remoteAccessLocationId);
        //         for (QuoteLineItem qli : qliMap.values()) {
        //             if (qli.Product2.ProductCode == 'ENT_ETH_ACCESS_0001' && qli.vlocity_cmt__ServiceAccountId__c == remoteAccessLocationId) {
        //                 System.debug('Access to update: ' + JSON.serialize(qli));
        //                 inputMap.put('accessToReprice', qli.Id); 
        //                 // The following code is just for POC, should be moved into the PostInvoke for a whole reprice logic
        //                 System.debug('qli.vlocity_cmt__JSONAttribute__c: ' + qli.vlocity_cmt__JSONAttribute__c);
        //                 Map<String, Object> input = new Map<String, Object> {
        //                     'objectSO' => null,
        //                     'runTimeAttributesJSON' => qli.vlocity_cmt__JSONAttribute__c,
        //                     'originalAttributesJSON' => qli.vlocity_cmt__Product2Id__r.vlocity_cmt__JSONAttribute__c,
        //                     'JSONAttributeActionRequestList' => new List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest> {
        //                         new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_BANDWIDTH', vlocity_cmt.JSONAttributeSupport.ActionType.ASSIGN, 'NA')
        //                     }
        //                 };
        //                 Map<String, Object> output = new Map<String, Object>();
        //                 jsonSupport.invokeMethod('applyAttributeActions', input, output, options);
        //                 // The code below is supposed to run once for POCD
        //                 qli.vlocity_cmt__JSONAttribute__c = (String)output.get('modifiedJSON');
        //                 update qli;
                    
        //             }
        //         }

        //     }
        // }

        // //Added by Vlocity on 8JAN2020 to resolve SOQL 101 error
        // if (methodName.equalsIgnoreCase('cloneQuoteLineItem')) {
        //     cloneQuoteLineItem(methodName, inputMap, outputMap, options);
        //     return true;
        // }        
        

        // // Added by Justin on Jan 24 for default term POC
        // if (methodName.equalsIgnoreCase('postCartsItems.PreInvoke')) {
        //     List<Object> items = (List<Object>)inputMap.get('items');
        //     Map<String, Object> item = (Map<String, Object>)items[0];
        //     cpqAppHandlerCtx.put('parentId', item.get('parentId'));
        // }
        // if (methodName.equalsIgnoreCase('postCartsItems.PostInvoke')) {
        //     String parentId = (String)cpqAppHandlerCtx.get('parentId');

        //     vlocity_cmt.JSONResult jres = (vlocity_cmt.JSONResult)outputMap.get('result');
        //     vlocity_cmt.JSONRecord jrec = jres.records[0];

        //     if (parentId != null) {
        //         // Navigate to the new added xLI
        //         jres = (vlocity_cmt.JSONResult)jrec.nameResult.get('lineItems');
        //         jrec = jres.records[0];
        //     }
        //     Map<String, Object> jfldMap = jrec.fields;
        //     vlocity_cmt.JSONField idFld = (vlocity_cmt.JSONField)jfldMap.get('Id');
        //     vlocity_cmt.JSONField lnFld = (vlocity_cmt.JSONField)jfldMap.get('vlocity_cmt__LineNumber__c');
        //     String ln = (String)lnFld.value;

        //     Id quoteId = (Id)inputMap.get('cartId');

        //     QuoteLineItem[] qLIs = [SELECT Id, vlocity_cmt__LineNumber__c, vlocity_cmt__JSONAttribute__c, vlocity_cmt__Product2Id__r.vlocity_cmt__JSONAttribute__c, Quote.Contract_Term__c FROM QuoteLineItem WHERE QuoteId=:quoteId AND (vlocity_cmt__LineNumber__c=:ln OR vlocity_cmt__LineNumber__c LIKE :(ln+'%'))];
        //     if (qLIs[0].Quote.Contract_Term__c != null) {
        //         vlocity_cmt.JSONAttributeSupport jsonSupport = new vlocity_cmt.JSONAttributeSupport();

        //         for (QuoteLineItem qLI : qLIs) {
        //             Map<String, Object> input = new Map<String, Object> {
        //                 'objectSO' => null,
        //                 'runTimeAttributesJSON' => qLI.vlocity_cmt__JSONAttribute__c,
        //                 'originalAttributesJSON' => qLI.vlocity_cmt__Product2Id__r.vlocity_cmt__JSONAttribute__c,
        //                 'JSONAttributeActionRequestList' => new List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest> {
        //                     new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_CONTRACT_TERM', vlocity_cmt.JSONAttributeSupport.ActionType.ASSIGN, qLI.Quote.Contract_Term__c)
        //                 }
        //             };
        //             Map<String, Object> output = new Map<String, Object>();
        //             Map<String, Object> myoptions = new Map<String, Object>();
        //             jsonSupport.invokeMethod('applyAttributeActions', input, output, myoptions);
        //             // The code below is supposed to run once for POCD
        //             qLI.vlocity_cmt__JSONAttribute__c = (String)output.get('modifiedJSON');
        //         }
        //         update qLIs;

        //         // No need to reprice cart because other attributes are not set yet for new added items
        //     }
        // }
        
        return false;
    }

//     @future
//     public static void priceCart(String contextId)
//     {   
//         System.debug('Start repriceCart');
//         Vlocity_cmt.CpqAppHandler cpqHandler = new Vlocity_cmt.CpqAppHandler();
//         Map<String, Object> input = new Map<String, Object> {
//             'methodName' => 'priceCart',
//                 'cartId' => contextId
//         };
//         Map<String, Object> output = new Map<String, Object> ();
//         Map<String, Object> myoptions = new Map<String, Object> ();
        
//         cpqHandler.invokeMethod('priceCart', input, output, myoptions);
        
//         System.debug('End repriceCart');
//     }

    
//     //Added by Vlocity on 8JAN2020 to resolve SOQL 101 error
//     private QuoteLineItem cloneQuoteLineItem(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) 
//     {
//         System.debug('cloneQuoteLineItem');
//         System.debug('inputMap: ' + JSON.serialize(input));
        
//         Id itemId = (Id)input.get('itemId');
//         Set<String> fNameSet = QuoteLineItem.SObjectType.getDescribe().fields.getMap().keySet();
//         // Justin - Something is strange for SFDC, can be improved in the future. 
//         fNameSet.remove('lastvieweddate');
//         fNameSet.remove('lastreferenceddate');
        
//         List<String> fNames = new List<String>(fNameSet);
        
        
//         String qry = 'SELECT ' + String.join(fNames, ',') + ' FROM QuoteLineItem WHERE Id=:itemId';
//         QuoteLineItem srcQLi = Database.query(qry);
        
//         QuoteLineItem lastQLI = [SELECT Id, vlocity_cmt__LineNumber__c FROM QuoteLineItem WHERE QuoteId=:srcQLI.QuoteId AND Product2.ProductCode='ENT_ETH_ACCESS_0001' ORDER BY vlocity_cmt__LineNumber__c ASC LIMIT 1 ];
//         System.debug('lastQLI: ' + JSON.serialize(lastQLI));
        
//         String lineNumber = lastQLI.vlocity_cmt__LineNumber__c;
//         if (Test.isRunningTest() && lineNumber == null) {
//             lineNumber = '0001.0001';
//         }
//         String[] nums = lineNumber.split('\\.');    
//         Integer ln2 = Integer.valueOf(nums[1]);
//         ln2 += 1;
//         nums[1] = String.valueOf(ln2).leftPad(4, '0');
//         lineNumber = String.join(nums, '.');
        
//         srcQLi.vlocity_cmt__LineNumber__c = lineNumber;
//         QuoteLineItem tgtQLi = srcQLi.clone(false, false, false, false);
        
//         insert tgtQLi;
//         System.debug('tgtQLi' + tgtQLi.Id);
        
//         return tgtQLi;
//     }

//     //Added by Vlocity on 8JAN2020 to resolve SOQL 101 error
//     public QuoteLineItem createAccess2(string contextId, string strAccessId){
//         Map<String, Object> ipInput = new Map <String, Object> ();
//         ipInput.put('itemId', strAccessId);
//         ipInput.put('cartId', contextId);
//         Map <String, Object> ipOutput = new Map <String, Object> ();
//         Map <String, Object> ipOptions = new Map <String, Object> ();
//         return cloneQuoteLineItem('cloneQuoteLineItem', ipInput, ipOutput, ipOptions);
//     }
      
//  /*   
//     private void addNetworkAcceses(String methodName, Map<String, Object> input, 
//                                          Map<String, Object> output, Map<String, Object> options) 
//     {
//         //This method gets called before putCartsItems
//         Id quoteId = (Id)input.get('cartId');
//         Quote myQuote = [SELECT Id, SelectedLocations__c FROM Quote WHERE Id=:quoteId];
        
//         QuoteLineItem[] qLIs = new List<QuoteLineItem>();
//         PriceBookEntry pbe = [SELECT Id, Name, Product2.vlocity_cmt__JSONAttribute__c  FROM pricebookEntry WHERE Product2.ProductCode='ENT_ETH_ACCESS_0001'];
        
//         List<Object> selLocs = (List<Object>)JSON.deserializeUntyped(myQuote.SelectedLocations__c);
//         Integer idx = 0;
//         for (Object selLoc : selLocs) {
//             Map<String, Object> loc = (Map<String, Object>)selLoc;
//             QuoteLineItem qLI = new QuoteLineItem(
//                 QuoteId = quoteId,
//                 vlocity_cmt__ServiceAccountId__c = (Id)loc.get('Id'),
//                 vlocity_cmt__LineNumber__c = String.valueOf(idx).leftPad(4, '0'),
//                 Quantity = 1,
//                 UnitPrice = 0.0,
//                 vlocity_cmt__JSONAttribute__c = pbe.Product2.vlocity_cmt__JSONAttribute__c,
//                 PriceBookEntryId = pbe.Id
//             );
//             qLIs.add(qLI);
//         }
        
//         Id cartId = '8011U000000LiqBQAS'; // sample cartId
//         Id lineItemId = '8021U000000NjK2QAK'; // Sample LineItemId
//         List<Map<String,Object>> adjustments = new List<Map<String,Object>>();
                
//         vlocity_cmt.CpqAppHandler cpqAppHandlerService = new vlocity_cmt.CpqAppHandler();

//         Map<String,Object> inputMap = new Map<String,Object> {
//             'cartId' => cartId,
//             'methodName' => 'runCartValidation',
//             'price' => true,
//             'validate' => true
//         };
//         Map<String,Object> outputMap = new Map<String,Object>();
//         Map<String,Object> optionsMap = new Map<String,Object>();
        
//         cpqAppHandlerService.invokeMethod('runCartValidation', inputMap, outputMap, optionsMap);
        
//         if (outputMap.get('error') != null){
//             //System.debug(LoggingLevel.FINEST,'adjustment is not getting applied'+ outputMap.get('error'));
//         }       
        
//         insert qLIs;       
//     }
//  */   
//     private void putCartsItems_PreInvoke(String methodName, Map<String, Object> input, 
//                                          Map<String, Object> output, Map<String, Object> options) 
//     {
//         //This method gets called before putCartsItems
//     }
    
//     private void putCartsItems_PostInvoke(String methodName, Map<String, Object> input, 
//                                           Map<String, Object> output, Map<String, Object> options) 
//     {
//         //This method gets called after putCartsItems
//         String contextId = (String) input.get('cartId');
//         system.debug('putCartsItems_PostInvoke:' + JSON.serialize(input));
//         List<QuoteLineItem> lstQLI = [SELECT id, Quote.AccountId, QuoteId,
//                                       vlocity_cmt__ParentItemId__c, vlocity_cmt__ServiceAccountId__c, 
//                                       vlocity_cmt__AssetReferenceId__c, vlocity_cmt__ReliesOnItemId__c, 
//                                       vlocity_cmt__Product2Id__c, vlocity_cmt__Product2Id__r.name, 
//                                       vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__CpqCardinalityMessage__c,
//                                       Speed__c, Term__c, vlocity_cmt__RootItemId__c, vlocity_cmt__RecurringTotal__c,
//                                       Copper_Tier__c, Fiber_Tier__c, Market__c, Level__c,
//                                       WC_Speed__c, WC_QOS__c, Lit__c, DSAT_Ticket__c, vlocity_cmt__LineNumber__c
//                                       FROM QuoteLineItem 
//                                       WHERE QuoteId =: contextId];
//         try {
//             if(!lstQLI.isEmpty()){

//                 System.debug('lstQLI: ' + JSON.serialize(lstQLI));
//                 id iAcct = lstQLI[0].Quote.AccountId;
                
//                 //Get Root Service Addresses 
//                 map<id, QuoteLineItem> mapRootSA = new map<id, QuoteLineItem>();
//                 mapRootSA = getRootServiceAddresses(lstQLI, strEIA);
                
//                 //Get Root for EVPL
//                 map<id, List<QuoteLineItem>> mapEVPL = new map<id, List<QuoteLineItem>>();
//                 mapEVPL = getRootEVPL(lstQLI, strEVC, strEVPL);
                
//                 //Get Access for Service Address
//                 map<id, QuoteLineItem> mapAccess = new map<id, QuoteLineItem>();
//                 mapAccess = getSAByProdName(lstQLI, strAccess);
                
//                 //Get Premise Information
//                 map<id, Account> mapPremise = new map<id, Account>();
//                 mapPremise = getSAsPremise(lstQLI);
                
//                 //Get ValueMap of Parents
//                 Map<id, string> mapParentValues = new Map<id, string>();
//                 mapParentValues = getParentValues(lstQLI);
                
//                 //Get Map of Bandwidth
//                 Map<string, CustomCart_Data__mdt> mapBandwidth = new Map<string, CustomCart_Data__mdt>();
//                 mapBandwidth = getBandwidthData();
                
//                 //Set Values            
//                 Map<Id, QuoteLineItem> mapQLIToBeUpdated = new Map<Id, QuoteLineItem>();
//                 Map<Id, String> mapTier = new Map<Id, String>();
//                 Map<Id, String> mapTerm = new Map<Id, String>();
//                 Map<Id, String> mapBand = new Map<Id, String>();
                
//                 //Loop through QLI to set logic
//                 For (QuoteLineItem oQLI : lstQLI) {
//                     boolean bCheck = false;
//                     //Set Message to blank from Need to Save.
//                     if(oQLI.vlocity_cmt__CpqCardinalityMessage__c == 'Need to Save.' && oQLI.vlocity_cmt__RecurringTotal__c > 0
//                     && iAcct != oQLI.vlocity_cmt__ServiceAccountId__c){
//                         oQLI.vlocity_cmt__CpqCardinalityMessage__c = '';
//                         bCheck = true;
//                     }

//                     if(oQLI.vlocity_cmt__Product2Id__r.name == 'IP')
//                     {
//                         string inputJson = '{"qliId":"' + oQLI.Id + '"}';
//                         //string inputJson = '{"qliId":"{0}"}', new List<object>{oQLI.Id});
//                         vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.processObjectsJSON(inputJson, 'getSelectedIPBlockValue');

//                         if (!result.hasErrors())
//                         {
//                             List<Map<String, Object>> resultList = (List<Map<String, Object>>)result.toJsonList();
//                             if(resultList.size() > 0)
//                             {
//                                 Map<string, object> selectedAttrValue = (Map<string, object>)resultList[0];

//                                 string attribute = string.valueOf(selectedAttrValue.get('IP Blocks'));

//                                 if(oQLI.vlocity_cmt__CpqCardinalityMessage__c == 'Need to Save.' && oQLI.vlocity_cmt__RecurringTotal__c >= 0
//                                     && iAcct != oQLI.vlocity_cmt__ServiceAccountId__c
//                                     && (attribute == 'Static IP /30' || attribute == 'Static IP /29')){
//                                     oQLI.vlocity_cmt__CpqCardinalityMessage__c = '';
//                                     bCheck = true;
//                                 }
//                             }
//                         }
//                     }

//                     //Update Service Address
//                     if(mapRootSA.containsKey(oQLI.vlocity_cmt__RootItemId__c)) {
//                         QuoteLineItem oRoot =  mapRootSA.get(oQLI.vlocity_cmt__RootItemId__c);
//                         if(oQLI.vlocity_cmt__ServiceAccountId__c != oRoot.vlocity_cmt__ServiceAccountId__c){
//                             oQLI.vlocity_cmt__ServiceAccountId__c = oRoot.vlocity_cmt__ServiceAccountId__c;
//                             if(string.isBlank(oQLI.vlocity_cmt__CpqCardinalityMessage__c)){
//                                 // oQLI.vlocity_cmt__CpqCardinalityMessage__c = 'Need to Save.'; 
//                             }
//                             bCheck = true;
//                         }
//                     }
                    
//                     //Roll-up EVPL Bandwidth
//                     if(mapEVPL.containsKey(oQLI.id)){
//                         List<QuoteLineItem> lstRollup = mapEVPL.get(oQLI.id);
//                         string sBandwidth = getCalcBandwidth(lstRollup, mapBandwidth);
//                         if(string.isNotBlank(sBandwidth)){
//                             oQLI.Speed__c = sBandwidth;
//                             bCheck = true;
//                             //UPDATE BANDWIDTH ATTRIBUTE
//                             mapBand.put(oQLI.id, sBandwidth);
//                         }
//                     }

//                     if(oQLI.vlocity_cmt__ServiceAccountId__c != null 
//                     && iAcct != oQLI.vlocity_cmt__ServiceAccountId__c)
//                     {
//                         if(mapPremise.containsKey(oQLI.vlocity_cmt__ServiceAccountId__c)){
//                             Account oPremise = mapPremise.get(oQLI.vlocity_cmt__ServiceAccountId__c);
//                             if(oQLI.DSAT_Ticket__c != oPremise.vlocity_cmt__PremisesId__r.DSAT_Ticket__c){
//                                 oQLI.Copper_Tier__c = oPremise.vlocity_cmt__PremisesId__r.Copper_Tier__c;
//                                 oQLI.Fiber_Tier__c = oPremise.vlocity_cmt__PremisesId__r.Fiber_Tier__c;
//                                 oQLI.Market__c = oPremise.vlocity_cmt__PremisesId__r.Market__c;
//                                 oQLI.Level__c = oPremise.vlocity_cmt__PremisesId__r.Level__c;
//                                 oQLI.WC_Speed__c = oPremise.vlocity_cmt__PremisesId__r.WC_Speed__c;
//                                 oQLI.WC_QOS__c = oPremise.vlocity_cmt__PremisesId__r.WC_QOS__c;
//                                 oQLI.Lit__c = oPremise.vlocity_cmt__PremisesId__r.Lit__c;
//                                 oQLI.DSAT_Ticket__c = oPremise.vlocity_cmt__PremisesId__r.DSAT_Ticket__c;
//                                 bCheck = true;
//                             }
                            
//                             //Set Tier
//                             string strTierLogic = getTierLogic(oQLI, mapBandwidth);
//                             if(string.isNotBlank(strTierLogic)){
//                                 if(strTierLogic == 'BDT' && (oQLI.vlocity_cmt__CpqCardinalityMessage__c == '' || oQLI.vlocity_cmt__CpqCardinalityMessage__c != 'BDT Required')){
//                                     oQLI.vlocity_cmt__CpqCardinalityMessage__c = 'BDT Required.';
//                                     bCheck = true;
//                                 }else if(strTierLogic != 'BDT' && oQLI.vlocity_cmt__CpqCardinalityMessage__c == 'BDT Required.'){
//                                     oQLI.vlocity_cmt__CpqCardinalityMessage__c = '';
//                                     bCheck = true;
//                                 }
//                                 mapTier.put(oQLI.id, strTierLogic);
//                             }
//                         }
//                     }
//                     if(bCheck){
//                         mapQLIToBeUpdated.put(oQLI.Id, oQLI);
//                     }  
                    
//                     //UPDATE TERM ATTRIBUTE
//                     if (mapParentValues.containsKey(oQLI.vlocity_cmt__ParentItemId__c)){
//                         string sTerm = mapParentValues.get(oQLI.vlocity_cmt__ParentItemId__c);
//                         if(string.isNotBlank(sTerm)){
//                             mapTerm.put(oQLI.id, sTerm);
//                         }
//                     }
//                 }
                
//                 //Get Access Rollups for Service Addresses 
//                 map<id, List<QuoteLineItem>> mapAccessRollups = new map<id, List<QuoteLineItem>>();
//                 mapAccessRollups = getSAsByProdNames(lstQLI, strEVC, strEVPL);
                
//                 //Review Quote Lines to set Access for EVC
//                 if(!mapAccessRollups.isEmpty()){
//                     For(id iQLI : mapAccessRollups.keySet()){
//                         List<QuoteLineItem> lstEVC = mapAccessRollups.get(iQLI);
//                         QuoteLineItem oQLIAccess = new QuoteLineItem();
//                         QuoteLineItem oQLIUpdate = new QuoteLineItem();
//                         if(mapAccess.containsKey(iQLI)){
//                             oQLIAccess = mapAccess.get(iQLI);
//                         }else if(mapAccess.containsKey(iAcct)){
//                             oQLIAccess = mapAccess.get(iAcct);
//                         }
//                         if(oQLIAccess.id != null){
//                             if(mapQLIToBeUpdated.containsKey(oQLIAccess.Id)){
//                                 oQLIUpdate = mapQLIToBeUpdated.get(oQLIAccess.Id);
//                             }else{
//                                 oQLIUpdate = oQLIAccess;
//                             }
//                             oQLIUpdate.vlocity_cmt__ServiceAccountId__c = lstEVC[0].vlocity_cmt__ServiceAccountId__c;
//                         }else{
//                             //ADD another Access - use clone - update service account
//                             if(string.isNotBlank(strAccessId)){
//                                 //Added by Vlocity on 8JAN2020 for SOQL 101 error resolution
//                             //    oQLIAccess = createAccess(contextId, strAccessId);
//                             //Commented by VL on 14Jan2020 as a new VIP is used to auto add access
//                             //  oQLIAccess = createAccess2(contextId, strAccessId);
//                                 //Set to default Account Id
//                                 oQLIAccess.vlocity_cmt__ServiceAccountId__c = iAcct;
//                                 if(!mapAccess.containsKey(oQLIAccess.vlocity_cmt__ServiceAccountId__c)){
//                                     mapAccess.put(oQLIAccess.vlocity_cmt__ServiceAccountId__c, oQLIAccess);
//                                 }
//                                 oQLIUpdate = oQLIAccess;
//                                 if(string.isBlank(oQLIUpdate.vlocity_cmt__CpqCardinalityMessage__c)){
//                                     // oQLIUpdate.vlocity_cmt__CpqCardinalityMessage__c = 'Need to Save.'; 
//                                 }
//                                 mapQLIToBeUpdated.put(oQLIUpdate.id, oQLIUpdate);
//                             }
//                         }
                        
//                         if(oQLIUpdate.id != null){
//                             //Calculate Speed and set term
//                             string sBandwidth = getCalcBandwidth(lstEVC, mapBandwidth);
//                             if(string.isNotBlank(sBandwidth)){
//                                 oQLIUpdate.vlocity_cmt__ServiceAccountId__c = lstEVC[0].vlocity_cmt__ServiceAccountId__c;
//                                 oQLIUpdate.Speed__c = sBandwidth;
//                                 //UPDATE BANDWIDTH, TERM, and TIER ATTRIBUTE
//                                 mapBand.put(oQLIUpdate.id, sBandwidth); 
//                                 if(string.isNotBlank(lstEVC[0].Term__c)){
//                                     mapTerm.put(oQLIUpdate.id, lstEVC[0].Term__c);
//                                 }
                                
//                                 if(mapPremise.containsKey(oQLIUpdate.vlocity_cmt__ServiceAccountId__c)){
//                                     Account oPremise = mapPremise.get(oQLIUpdate.vlocity_cmt__ServiceAccountId__c);
//                                     if(oQLIUpdate.DSAT_Ticket__c != oPremise.vlocity_cmt__PremisesId__r.DSAT_Ticket__c){
//                                         oQLIUpdate.Copper_Tier__c = oPremise.vlocity_cmt__PremisesId__r.Copper_Tier__c;
//                                         oQLIUpdate.Fiber_Tier__c = oPremise.vlocity_cmt__PremisesId__r.Fiber_Tier__c;
//                                         oQLIUpdate.Market__c = oPremise.vlocity_cmt__PremisesId__r.Market__c;
//                                         oQLIUpdate.Level__c = oPremise.vlocity_cmt__PremisesId__r.Level__c;
//                                         oQLIUpdate.WC_Speed__c = oPremise.vlocity_cmt__PremisesId__r.WC_Speed__c;
//                                         oQLIUpdate.WC_QOS__c = oPremise.vlocity_cmt__PremisesId__r.WC_QOS__c;
//                                         oQLIUpdate.Lit__c = oPremise.vlocity_cmt__PremisesId__r.Lit__c;
//                                         oQLIUpdate.DSAT_Ticket__c = oPremise.vlocity_cmt__PremisesId__r.DSAT_Ticket__c;
//                                         if(string.isBlank(oQLIUpdate.vlocity_cmt__CpqCardinalityMessage__c)){
//                                             // oQLIUpdate.vlocity_cmt__CpqCardinalityMessage__c = 'Need to Save.'; 
//                                         }
//                                     }
//                                 }
                                
//                                 //Set Tier
//                                 string strTierLogic = getTierLogic(oQLIUpdate, mapBandwidth);
//                                 if(string.isNotBlank(strTierLogic)){
//                                     if(strTierLogic == 'BDT' && (oQLIUpdate.vlocity_cmt__CpqCardinalityMessage__c == '' || oQLIUpdate.vlocity_cmt__CpqCardinalityMessage__c != 'BDT Required')){
//                                         oQLIUpdate.vlocity_cmt__CpqCardinalityMessage__c = 'BDT Required';
//                                     }else if(strTierLogic != 'BDT' && oQLIUpdate.vlocity_cmt__CpqCardinalityMessage__c == 'BDT Required'){
//                                         oQLIUpdate.vlocity_cmt__CpqCardinalityMessage__c = '';
//                                     }
//                                     mapTier.put(oQLIUpdate.id, strTierLogic);
//                                 }
                                
//                                 //update QuoteLine
//                                 mapQLIToBeUpdated.put(oQLIUpdate.id, oQLIUpdate);
//                             }
//                         }
//                     }
//                 }
                
//                 //Update QuoteLine 
//                 if(!mapQLIToBeUpdated.isEmpty()){
//                     try {
//                         update mapQLIToBeUpdated.values();
//                     }catch(exception ex) {
//                         System.debug('Exception occurred while updating the lineitems ' + ex.getMessage());
//                     }
//                 }

//                 //Set Attribute Values
//                 List<Object> lstUpdate = new List<Object>();
//                 system.debug('---lstQLI size---'+lstQLI.size());
//                 For (QuoteLineItem oQLI : lstQLI) {
//                     system.debug('---oQLI---'+oQLI); 
//                     Map<String,Object> attrMap = new Map<String,Object>();
//                     if(mapTier.containsKey(oQLI.Id)){
//                         attrMap.put(strTier, mapTier.get(oQLI.Id));
//                         system.debug('-----strTier---'+strTier);
//                         system.debug('---oQLI Name---'+oQLI.vlocity_cmt__Product2Id__r.name);
//                         system.debug('-----mapTier.get(oQLI.Id)---'+mapTier.get(oQLI.Id));
//                     }
//                     if(mapTerm.containsKey(oQLI.Id)){
//                         attrMap.put(strTerm, mapTerm.get(oQLI.Id));
//                     }
//                     if(mapBand.containsKey(oQLI.Id)){
//                         attrMap.put(strBandwidth, mapBand.get(oQLI.Id));
//                     }
//                     if(!attrMap.isEmpty()){
//                         map<String, Object> drBody = new map<String, Object>{
//                             strID => String.valueOf(oQLI.id),'Attributes' => attrMap};
//                     system.debug('-----drBody---'+drBody);
//                         lstUpdate.add(drBody);
//                     }   
//                 }


//                 system.debug('-----lstUpdate---'+lstUpdate);
//                 //update the values
//                 if(!lstUpdate.isEmpty()){
//                     String dataJson = Json.serialize(lstUpdate);
//                     system.debug('-----dataJson---'+dataJson);
//                     vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.processObjectsJSON(dataJson, 'saveCustomCartAttributes');
//                     system.debug('-----result---'+result);
//                 }
//             }   

//             // Propagate Service Account for new Network Access (ENT_ETH_ACCESS_0002) product POC - Jan 23, 2020
//             Map<String, Object> putRecord = (Map<String, Object>)((List<Object>)((Map<String, Object>)input.get('items')).get('records'))[0];
//             if ((String)putRecord.get('ProductCode') == 'ENT_ETH_ACCESS_0002' || (String)putRecord.get('ProductCode') == 'ENT_ETH_EIA_0001') {
//                 System.debug('update Network Access (New Model)');
//                 List<QuoteLineItem> qLIs = new List<QuoteLineItem>();
//                 String lineNumber = (String)((Map<String, Object>)putRecord.get('vlocity_cmt__LineNumber__c')).get('value');
//                 String serviceAccountId = (String)((Map<String, Object>)putRecord.get('vlocity_cmt__ServiceAccountId__c')).get('value');
//                 System.debug('lineNumber-serviceAccountId: ' + lineNumber + ' - ' + serviceAccountId);
//                 for (QuoteLineItem qLi : lstQLI) {
//                     if (qLi.vlocity_cmt__LineNumber__c.startsWith(lineNumber + '.') && qLi.vlocity_cmt__ServiceAccountId__c != serviceAccountId) {
//                         qLi.vlocity_cmt__ServiceAccountId__c = serviceAccountId;
//                         qLIs.add(qLi);
//                     }
//                 }

//                 if (qLIs.size() > 0) {
//                     System.debug('Propagate Service Account changes to child products');
//                     update qLIs;
//                 }
//             }


//             // Update LocationType of Access (Host vs. Remote) - By Vlocity Jan 18
//             Map<String, Object> item = (Map<String, Object>)((List<Object>)((Map<String, Object>)input.get('items')).get('records'))[0];
//             if ((String)item.get('ProductCode') == 'ENT_ETH_EVPL_0001') {
//                 Id serviceAccountId = (Id)((Map<String, Object>)item.get('vlocity_cmt__ServiceAccountId__c')).get('value');
//                 System.debug('UpdateAccessLocationType - ServiceAccountId__c: ' + serviceAccountId);
//                 if (serviceAccountId != null) {
//                     Map<String, Object> ipInput = new Map<String, Object> {
//                         'ServiceAccountId' => serviceAccountId,
//                         'QuoteId' => contextId
//                     };
//                     Map<String, Object> ipOptions = new Map<String, Object> ();
//                     System.debug('ipInput: ' + JSON.serialize(ipInput));
//                     Map<String, Object> ipOutput = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService('CPQ_UpdateAccess', ipInput, ipOptions);
//                     System.debug('ipOutput: ' + JSON.serialize(ipOutput));
//                 }
//             }
//         } catch (Exception ex) {
//             System.debug(String.valueOf(ex.getLineNumber()) + ex.getMessage());
//         }
//     }
    
//     public static map<id, QuoteLineItem> getRootServiceAddresses(List<QuoteLineItem> lstQLI, string strProdCode){ 
//         map<id, QuoteLineItem> mapResult = new map<id, QuoteLineItem>();
//         if(!lstQLI.isEmpty()){
//             For (QuoteLineItem oQLI : lstQLI) {
//                 if(oQLI.vlocity_cmt__ServiceAccountId__c != null && oQLI.vlocity_cmt__RootItemId__c != null
//                    && oQLI.vlocity_cmt__ParentItemId__c == null
//                    && oQLI.vlocity_cmt__Product2Id__r.ProductCode.startsWithIgnoreCase(strProdCode)
//                    && oQLI.Quote.AccountId != oQLI.vlocity_cmt__ServiceAccountId__c) 
//                 {
//                     if(!mapResult.containsKey(oQLI.vlocity_cmt__RootItemId__c)){
//                         mapResult.put(oQLI.vlocity_cmt__RootItemId__c, oQLI);
//                     }
//                 }
//             }
//         }
//         return mapResult;
//     }
    
//     public static Map<id, List<QuoteLineItem>> getRootEVPL(List<QuoteLineItem> lstQLI, string strProdName, string strProdCode){
//         Map<id, List<QuoteLineItem>> mapResult = new Map<id, List<QuoteLineItem>>();

//         try {
//             if(!lstQLI.isEmpty()){
//                 For (QuoteLineItem oEVPL : lstQLI) {
//                     if(oEVPL.vlocity_cmt__Product2Id__r.ProductCode.startsWithIgnoreCase(strProdCode)){
//                         For (QuoteLineItem oQLI : lstQLI) {
//                             if(oQLI.vlocity_cmt__Product2Id__r.name == strProdName && 
//                             oEVPL.vlocity_cmt__RootItemId__c == oQLI.vlocity_cmt__RootItemId__c){
//                                 if(mapResult.containsKey(oEVPL.Id)){
//                                     List<QuoteLineItem> mList = mapResult.get(oEVPL.Id);
//                                     // system.debug('--getrootevpl--'+ oQLI.Description);
//                                     mList.add(oQLI);
//                                     mapResult.put(oEVPL.Id, mList);
//                                 }else{
//                                     mapResult.put(oEVPL.Id, new List<QuoteLineItem> {oQLI});
//                                 }
//                             }
//                         }
//                     }
//                 }
//             }
//         } catch (Exception ex) {
//             System.debug(ex.getMessage());
//         }
        
//         return mapResult;
//     }
    
//     public static Map<id, QuoteLineItem> getSAByProdName(List<QuoteLineItem> lstQLI, string strProdName){
//         Map<id, QuoteLineItem> mapResult = new Map<id, QuoteLineItem>();
//         if(!lstQLI.isEmpty()){
//             For (QuoteLineItem oQLI : lstQLI) {
//                 if(oQLI.vlocity_cmt__Product2Id__r.name == strProdName){
//                     if(!mapResult.containsKey(oQLI.vlocity_cmt__ServiceAccountId__c)){
//                         mapResult.put(oQLI.vlocity_cmt__ServiceAccountId__c, oQLI);
//                     }
//                     if(strAccessId == null){
//                         strAccessId = oQLI.id;
//                     }
//                 }
//             }
//         }
//         return mapResult;
//     }
    
//     public static Map<id, List<QuoteLineItem>> getSAsByProdNames(List<QuoteLineItem> lstQLI, string strProdName, string strProdCode){
//         Map<id, List<QuoteLineItem>> mapResult = new Map<id, List<QuoteLineItem>>();
//         if(!lstQLI.isEmpty()){
//             For (QuoteLineItem oQLI : lstQLI) {
//                 if(oQLI.vlocity_cmt__Product2Id__r.name == strProdName || 
//                    oQLI.vlocity_cmt__Product2Id__r.ProductCode.startsWithIgnoreCase(strProdCode)){
//                        if(mapResult.containsKey(oQLI.vlocity_cmt__ServiceAccountId__c)){
//                            List<QuoteLineItem> mList = mapResult.get(oQLI.vlocity_cmt__ServiceAccountId__c);
//                            mList.add(oQLI);
//                            mapResult.put(oQLI.vlocity_cmt__ServiceAccountId__c, mList);
//                        }else{
//                            mapResult.put(oQLI.vlocity_cmt__ServiceAccountId__c, new List<QuoteLineItem> {oQLI});
//                        }
//                    }
//             }
//         }
//         return mapResult;
//     }
    
//     public static Map<Id, Account> getSAsPremise(List<QuoteLineItem> lstQLI){
//         Map<id, Account> mapResult = new Map<id, Account>();
//         Set<Id> idsPremise = new Set<Id>();
        
//         if(!lstQLI.isEmpty()){
//             For (QuoteLineItem oQLI : lstQLI) {
//                 idsPremise.add(oQLI.vlocity_cmt__ServiceAccountId__c);
//             }
//         }
//         if(!idsPremise.isEmpty()){
//             List<Account> lstAcct = [Select id,  vlocity_cmt__PremisesId__r.Copper_Tier__c, 
//                                      vlocity_cmt__PremisesId__r.Fiber_Tier__c, 
//                                      vlocity_cmt__PremisesId__r.Market__c,
//                                      vlocity_cmt__PremisesId__r.Level__c,
//                                      vlocity_cmt__PremisesId__r.WC_Speed__c,
//                                      vlocity_cmt__PremisesId__r.WC_QOS__c,
//                                      vlocity_cmt__PremisesId__r.Lit__c,
//                                      vlocity_cmt__PremisesId__r.DSAT_Ticket__c
//                                      FROM Account 
//                                      WHERE id =: idsPremise];
//             if(!lstAcct.isEmpty()){
//                 mapResult.putAll(lstAcct);
//             }
//         }
//         return mapResult;
//     }
    
//     public static Map<Id, String> getParentValues(List<QuoteLineItem> lstQLI){            
//         Map<Id, String> mapResult = new Map<Id, String>();
//         if(!lstQLI.isEmpty()){
//             For (QuoteLineItem oQLI : lstQLI) {
//                 if(oQLI.vlocity_cmt__ParentItemId__c == null){
//                     mapResult.put(oQLI.Id, oQLI.Term__c);
//                 }
//             }
//         }
//         return mapResult;
//     }
    
//     public static Map<string, CustomCart_Data__mdt> getBandwidthData(){
//         Map<string, CustomCart_Data__mdt> mapResult = new Map<string, CustomCart_Data__mdt>();
//         List<CustomCart_Data__mdt> lstCustomCart = [SELECT MasterLabel, Bandwidth_Number__c,
//                                                     Copper_Enabled__c, Fiber_Enabled__c 
//                                                     FROM CustomCart_Data__mdt
//                                                     ORDER BY Bandwidth_Number__c];
//         If (!lstCustomCart.isEmpty()){
//             For(CustomCart_Data__mdt ccd : lstCustomCart){
//                 mapResult.put(ccd.MasterLabel, ccd);
//             }
//         }
        
//         return mapResult;     
//     }
    
//     /*
//     public static string getTierLogic(QuoteLineItem oQLI, Map<string, CustomCart_Data__mdt> mapBandwidth){
//         string sTier = '';
//         if(oQLI != null){
//             if(string.isNotBlank(oQLI.Fiber_Tier__c )){
//                 if(oQLI.Fiber_Tier__c == oQLI.Copper_Tier__c){
//                     sTier = oQLI.Fiber_Tier__c;
//                 }else if (string.isNotBlank(oQLI.Speed__c) && mapBandwidth.containsKey(oQLI.Speed__c)){
//                     customCart_Data__mdt ccData = mapBandwidth.get(oQLI.Speed__c);
//                     if(ccData.Copper_Enabled__c){
//                         sTier = oQLI.Copper_Tier__c;
//                     }else{
//                         sTier = oQLI.Fiber_Tier__c;
//                     }
//                 }else if(oQLI.Fiber_Tier__c != 'BDT'){
//                     sTier = oQLI.Fiber_Tier__c;
//                 }else if(oQLI.Copper_Tier__c != 'BDT'){
//                     sTier = oQLI.Copper_Tier__c;
//                 }else{
//                     sTier = oQLI.Copper_Tier__c;
//                 }
//             }
//         }
//         return sTier;        
//     }
//     */
    
    
//     public static string getTierLogic(QuoteLineItem oQLI, Map<string, CustomCart_Data__mdt> mapBandwidth){
//         string sTier = 'Error';
//         if(oQLI != null){         
           
//             if(string.isNotBlank(oQLI.Fiber_Tier__c )){
//                 if(oQLI.Fiber_Tier__c == oQLI.Copper_Tier__c){
//                     sTier = oQLI.Fiber_Tier__c;
//                 }else if(oQLI.Copper_Tier__c =='Tier 1' && oQLI.Fiber_Tier__c =='Tier 2' && oQLI.Speed__c !=null){
//                     if(Integer.valueOf(oQLI.Speed__c.substring(0,oQLI.Speed__c.indexOf('Mbps')-1)) < 50  ){
//                         sTier = oQLI.Copper_Tier__c;
//                     }else{
//                         sTier = oQLI.Fiber_Tier__c;
//                     }
//                 }else if(oQLI.Copper_Tier__c =='Tier 1' && oQLI.Fiber_Tier__c =='BDT'  && oQLI.Speed__c !=null){
//                     if(Integer.valueOf(oQLI.Speed__c.substring(0,oQLI.Speed__c.indexOf('Mbps')-1)) < 50  ){
//                         sTier = oQLI.Copper_Tier__c;
//                     }else{
//                         sTier = 'BDT';
//                     }
//                 }else if(oQLI.Copper_Tier__c =='Tier 2' && oQLI.Fiber_Tier__c =='Tier 1'){
//                     sTier = oQLI.Fiber_Tier__c;
//                 }else if(oQLI.Copper_Tier__c =='Tier 2' && oQLI.Fiber_Tier__c =='BDT'  && oQLI.Speed__c !=null){
//                     if(Integer.valueOf(oQLI.Speed__c.substring(0,oQLI.Speed__c.indexOf('Mbps')-1)) < 50  ){
//                         sTier = oQLI.Copper_Tier__c;
//                     }else{
//                         sTier = 'BDT';
//                     }
//                 }else if(oQLI.Copper_Tier__c =='BDT' && (oQLI.Fiber_Tier__c =='Tier 1' || oQLI.Fiber_Tier__c =='Tier 2')){
//                     sTier = oQLI.Fiber_Tier__c;
//                 }else if((oQLI.Copper_Tier__c =='BDT' ||oQLI.Copper_Tier__c =='Tier 3') && oQLI.Fiber_Tier__c =='BDT'){
//                     sTier = 'BDT';
//                 }
              
//             } 
//         }
//         // system.debug('----sTier---' +sTier + '---Quote Description---' + oQLI.Description);
//         return sTier;        
//     }
    
    
// /* Commented by Vlocity 2020-01-09  
//     public QuoteLineItem createAccess (string contextId, string strAccessId){
//         QuoteLineItem newAccess = new QuoteLineItem();
//         if(string.isNotBlank(contextId) && string.isNotBlank(strAccessId)){
//             String procedureName = 'CPQ_CloneItem';
//             Map<String, Object> ipInput = new Map <String, Object> ();
//             ipInput.put('cartId', contextId);
//             ipInput.put('itemToClone', strAccessId);
//             Map <String, Object> ipOutput = new Map <String, Object> ();
//             Map <String, Object> ipOptions = new Map <String, Object> ();
//             ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
//             newAccess.id = string.valueOf(ipOutput.get('NewRecordId'));
//         }
//         return newAccess;
//     }
// */    
//     public string getCalcBandwidth(List<QuoteLineItem> lstEVC, Map<string, CustomCart_Data__mdt> mapBandwidth)  {
//         integer iBandwidthNumber = 0;
//         string strCalcBandwidth = '';
//         For (QuoteLineItem evc : lstEVC){
//             if (mapBandwidth.containsKey(evc.Speed__c)){
//                 customCart_Data__mdt ccData = mapBandwidth.get(evc.Speed__c);
//                 iBandwidthNumber += integer.valueof(ccData.Bandwidth_Number__c);
//             }
//         } 
//         if(iBandwidthNumber > 0){
//             For (customCart_Data__mdt ccd : mapBandwidth.values()){
//                 if(iBandwidthNumber <= ccd.Bandwidth_Number__c){
//                     strCalcBandwidth = ccd.MasterLabel;
//                     Break;
//                 }
//             }
//         }
//         return strCalcBandwidth;
//     }

}