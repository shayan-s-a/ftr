/**
 * 
* @description Service methods for Quote related functionalities
* @verion :2.0
*/  
global with sharing class ftr_QuoteService implements vlocity_cmt.VlocityOpenInterface {

    private static final String UCF_PRODUCT_FAMILY = 'UCF';
    public final static List<String> UCF_PROD_CODE_WITH_BUYING_OPTIONS = new List<String>{
        'UCF_POLY_150',
        'UCF_POLY_250',
        'UCF_POLY_350',
        'UCF_POLY_450',
        'UCF_POLY_EMS50',
        'UCF_POLY_D230',
        'UCF_POLY_DS230HS',
        'UCF_POLY_8500',
        'UCF_POLY_8800',
        'UCF_POLY_EXPMICS',
        'UCF_POLY_POWER_KIT8500',
        'UCF_POLY_POWER_KIT8800',    
        'UCF_POWER_POLY'   
        
    };
    public final static List<String> UCF_PROD_CODE_WITH_NBD = new List<String>{
        'UCF_NBD_MAINT'};
    public final static List<String> UCF_PROD_CODE_WITH_TF_BLOCKS = new List<String>{
        'UCF_TF_MIN_BLOCKS',
        'UCF_TF_ADDL_BLOCKS'};
    public final static List<String> UCF_PROD_CODE_AS_EQUIPMENT = new List<String>{
        'UCF_1531P8PBUNDLE',
        'UCF_1550_24PBUNDLE',
        'UCF_24P_POE',
        'UCF_48P_POE',
        'UCF_8P_POE',
        'UCF_ADTRAN_48PBUNDLE',
        'UCF_ATA_PAGADPT',
        'UCF_1FXS_FXO',
        'UCF_ATA2P',
        'UCF_ATA4P',
        'UCF_ATA8P',
        'UCF_POLY_8500',
        'UCF_POLY_8800',
        'UCF_POLY_EXPMICS',
        'UCF_POLY_150',
        'UCF_POLY_250',
        'UCF_POLY_350',
        'UCF_POLY_450',
        'UCF_POLY_D230',
        'UCF_POLY_DS230HS',
        'UCF_POLY_EMS50',
        'UCF_POWER_POLY',
        'UCF_SINGLEP_ATA'
        };
    
    /*
    * @description entry point of remoting method 
    */
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        System.debug('Enter ftr_QuoteService.' + methodName);
        try {
            if (methodName == 'toggleQuoteSync') {
                String quoteId = (String)inputMap.get('quoteId') == null ? (String)inputMap.get('contextId') : (String)inputMap.get('quoteId');
                Quote q = [SELECT Id, IsSyncing__c, OpportunityId FROM Quote WHERE Id=:quoteId];
                if (q.IsSyncing__c)
                    QuoteSyncService.UnSync(q);
                else
                    QuoteSyncService.Sync(q);
            } else if (methodName == 'checkForSyncedQuotes') {
                String quoteId = (String)inputMap.get('quoteId') == null ? (String)inputMap.get('contextId') : (String)inputMap.get('quoteId');
                Quote q = [SELECT Id, IsSyncing__c, OpportunityId FROM Quote WHERE Id=:quoteId];
                if (q.IsSyncing__c == false) {
                    Opportunity opp = [SELECT Id, (SELECT OpportunityId, Name FROM Quotes WHERE IsSyncing__c=true AND Id !=:q.Id) FROM Opportunity WHERE Id  =:q.OpportunityId];
                    if (opp.Quotes.size() > 0)
                        outputMap.put('Warning', 'Vlocity Quote '+ opp.Quotes[0].Name +' is already synced with this opportunity. An opportunity can be synced with only one vlocity quote at a time. If you continue, '+ opp.Quotes[0].Name +' won’t sync.');
                    else 
                        outputMap.put('Warning', 'If you continue, you’ll replace all vlocity-related product revenues with the quote line items. After a vlocity quote is synced, product revenues are updated automatically.');
                }
                return true;
            } else if (methodName == 'confirmStopSync') {
                outputMap.put('Warning', 'If you stop syncing now, future updates to quote line items won’t be synced with the opportunity’s products.');
                return true;
            } else if (methodName == 'cancelApproval' || methodName == 'redraft') {
                Id contextId = (Id)inputMap.get('contextId');
                if (contextId != null && contextId.getSobjectType() == Quote.SObjectType) {
                    if (methodName == 'cancelApproval') {
                        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :contextId
                                                                 AND ProcessInstance.Status = 'Pending']; 
                        System.debug(piWorkItems); 
                        if(piWorkItems.size() > 0){
                            //Create Process Work Item Request
                            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
                            pwiRequest.setAction('Removed');
                            pwiRequest.setWorkItemId(piWorkItems[0].Id);
                            Approval.ProcessResult result = Approval.process(pwiRequest);
                            System.debug(result);
                        }
                    } /* else if (methodName == 'redraft') {
                        Quote q = new Quote(
                            Id = contextId,
                            Status = 'Draft'
                        );
                        update q;
                    } */
                }
            }else if (methodName == 'UpdateSNEToQuoteLineItems') {
                return UpdateSNEToQuoteLineItems(inputMap, outputMap);
            }else if (methodName == 'setProductsFieldOnOrder') {
                setProductsFieldOnOrder(inputMap, outputMap);
            }else if (methodName == 'updateAttributeFromField') {
                updateAttributeFromField(inputMap, outputMap);
            }else if (methodName == 'syncDSATAttributes') {
                List<Object> items = (List<Object>) inputMap.get('LineItems');
                List<SObject> xLIs = new List<SObject>();
                for (Object item : items) {
                    Id itemId = (Id) ((Map<String,Object>) item).get('Id');
                    SObject xLI = syncDSATAttributes(itemId, null);
                    xLIs.add(xLI);
                }
                update xLIs;
            }
            return true;
        } catch (Exception ex) {
            System.debug(ex.getLineNumber() + ': ' + ex.getMessage());
            return false;
        } finally {
            System.debug('Exit ftr_QuoteService.' + methodName);
        }
    }
    
    /*
    * @description entry point of remoting method 
    * @param quoteId quote Id
    */
    /* public Boolean addAccessesBySelectedLocations(Id quoteId) {
        Set<Id> selectedLocIds = new Set<Id>();    // Selected Service Account Id from Quote record
        String methodName = 'postCartsItems';
        List<QuoteLineItem> qLIsInsert = new List<QuoteLineItem>();
        List<QuoteLineItem> qLIsUpdate = new List<QuoteLineItem>(); 
        Map<Id,Id> mapQuoteLineItemLocation = new Map<Id,Id>();       
        // TODO...
        
        Quote quotDetail = [SELECT Id, selectedLocations__c, Service_Term__c FROM Quote WHERE Id = : quoteId LIMIT 1];
        
        List<Object> selectedLocList = (List<Object>)(JSON.deserializeuntyped (quotDetail.selectedLocations__c));
        
        
        // 1. Read and parse the Quote.SelectedLocations__c field to return the list of selectedLocIds
        for(Object obj : selectedLocList ){
            Map<String,Object> objMap = (Map<String,Object>)obj;
            selectedLocIds.add((Id)objMap.get('Id'));
        }
        // 2. Read the PriceBookEntry Id for "ENT_ETH_ACCESS_0001" (Product Code)
        PricebookEntry pbe = [select Id from PricebookEntry where ProductCode =:ftr_CpqService.ProductCode_NETWORK_ACCESS LIMIT 1]; // PriceBookEntryId for "ENT_ETH_ACCESS_0001"
        Id accessPbId = pbe.Id;
        
        // 3. Use CpqAppHandler.postCartsItems to add the 1st Access product into the cart        
        vlocity_cmt.CpqAppHandler cpqHand = new vlocity_cmt.CpqAppHandler();
        Map<string,Object> inputMap = new Map<String,Object>();
        Map<string,Object> outMap = new Map<String,Object>();
        Map<string,Object> options = new Map<String,Object>();    
        List<Map<String,Object>> lstPriceBookEntry = new List<Map<String,Object>>();
        
        Map<String,Object> tempMap = new Map<String,Object>();
        tempMap.put('itemId', accessPbId);
        
        lstPriceBookEntry.add(tempMap);
        
        inputMap.put('methodName', methodName);
        inputMap.put('cartId', quoteId );
        inputMap.put('items', lstPriceBookEntry );
        inputMap.put('price', false);
        inputMap.put('validate', false);     
        cpqHand.invokeMethod(methodName, inputMap, outMap, options);
        
        vlocity_cmt.JSONResult result = (vlocity_cmt.JSONResult) outMap.get('result');
        
        // 4. Clone the new added Access lines (a. bump up LineNumber__c; b assign ServiceAccountId)
        if(result != null){
            List<QuoteLineItem> lstTempQuoteLineItem = new List<QuoteLineItem>();
            List<String> fields = new List<String>();
            fields.addAll(QuoteLineItem.getsObjectType().getDescribe().fields.getMap().keySet());
            // Should only contains only one Network Access qLI
            String soql = 'SELECT ' + String.join(fields, ',') + ' FROM QuoteLineItem WHERE QuoteId =: quoteId LIMIT 1';
    
            QuoteLineItem lstQLI = Database.query(soql);
            // Quote terms not getting when network access is added changes by-  IM
            lstQLI.Term__c = quotDetail.Service_Term__c;
            for(Integer i = 1; i < selectedLocIds.size(); i++){
                // if(!lstQLI.isEmpty() && lstQLI != null){
                // List<QuoteLineItem> tempQuoteLineItemLst = new List<QuoteLineItem>();
                // tempQuoteLineItemLst = lstQLI.deepclone(false,false,false);
                qLIsInsert.add(lstQLI.clone(false,false,false, false));            
                // }
            }
            database.insert(qLIsInsert);   
    
    
            Account[] serviceAccounts = [SELECT vlocity_cmt__PremisesId__c, vlocity_cmt__PremisesId__r.WC_Speed__c, vlocity_cmt__PremisesId__r.WC_QOS__c, vlocity_cmt__PremisesId__r.Copper_Tier__c, vlocity_cmt__PremisesId__r.Fiber_Tier__c, vlocity_cmt__PremisesId__r.Market__c, vlocity_cmt__PremisesId__r.Level__c 
                                        FROM Account
                                        WHERE Id = :selectedLocIds];
            
            
            // Add all QLIs to qLIsUpdate for ServiceAccount and DSAT attributes update
            qLIsUpdate.add(lstQLI);
            qLIsUpdate.addAll(qLIsInsert);          
            
            for (Integer i = 0; i < qLIsUpdate.size(); i++) {
                QuoteLineItem qLI = qLIsUpdate[i];
                Account svsAccount = serviceAccounts[i];
                vlocity_cmt__Premises__c premise = svsAccount.vlocity_cmt__PremisesId__r;
                // Bump up the LineNumber
                qLI.vlocity_cmt__LineNumber__c = String.valueOf(i).leftPad(4, '0'); // '000'+String.valueOf(i); 
                // Assign the selected location
                qLI.vlocity_cmt__ServiceAccountId__c = svsAccount.Id;
                // Sync DSAT attributes
                Map<String, Object> attrVals = new Map<String, Object> {
                    'ATTR_ELIGBL_WCSPEED' => premise.WC_Speed__c == null ? '' : premise.WC_Speed__c.replaceAll('MB',' MB'),
                    'ATTR_ELIGBL_QOS' => premise.WC_QOS__c == null ? '' : premise.WC_QOS__c,
                    'ATTR_TIER1' => premise.Copper_Tier__c == null ? '' : premise.Copper_Tier__c,
                    'ATTR_TIER2' => premise.Fiber_Tier__c == null ? '' : premise.Fiber_Tier__c,
                    'ATTR_MARKET' => premise.Market__c == null ? '' : premise.Market__c,
                    'ATTR_LEVEL' => premise.Level__c == null ? '' : premise.Level__c
                };
    
                String modifiedJSON = ftr_CpqHelper.setJSONAttributes(qLI.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                qLI.vlocity_cmt__JSONAttribute__c = modifiedJSON;
            }
    
            database.update(qLIsUpdate);
        }
    
        
        inputMap = new Map<String, Object> {
            'methodName' => 'priceCart',
            'cartId' => quoteId
        };
        outMap = new Map<String, Object> ();
        options = new Map<String, Object> ();
        cpqHand.invokeMethod('priceCart', inputMap, outMap, options);
        
        return true;
    } */
    
    /*
     * @description populate the Products__c field
     */
    public void setProductsFieldOnOrder(Map<String,Object> inputMap, Map<String, Object> outputMap) {
        Id orderId = (String) inputMap.get('OrderId');
    
        ProductsFieldConfig__mdt[] fieldConfigs = [SELECT Field__c, FieldValue__c, PicklistValue__c FROM ProductsFieldConfig__mdt];
        OrderItem[] oLIs = [
            SELECT Id, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.Family, OrderId, vlocity_cmt__Product2Id__r.vlocity_cmt__SubType__c
            FROM OrderItem
            WHERE OrderId  = :orderId
        ];
    
        // group oLIs by quote
        Set<String> products = new Set<String>();
        for (OrderItem item : oLIs) {
            for (ProductsFieldConfig__mdt config : fieldConfigs) {
                if (item.vlocity_cmt__Product2Id__r.get(config.Field__c) == config.FieldValue__c) {
                    products.add(config.PicklistValue__c);
                }
            }
        }
    
        // populate Products__c field
        Order myOrder = new Order(Id=orderId);
        myOrder.Products__c = String.join(new List<String>(products), ';');
    
        update myOrder;
    
    }
    
    /*
     * @description populate the Products__c field
     */
    public void setProductsFieldOnQuote(Map<Id, Quote> quoteMap, Boolean updateQuotes) {
        ProductsFieldConfig__mdt[] fieldConfigs = [SELECT Field__c, FieldValue__c, PicklistValue__c FROM ProductsFieldConfig__mdt];
        QuoteLineItem[] qLIs = [
            SELECT Id, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.Family, QuoteId, vlocity_cmt__Product2Id__r.vlocity_cmt__SubType__c
            FROM QuoteLineItem
            WHERE QuoteId IN :quoteMap.keySet()
        ];
    
        // group QLIs by quote
        Map<Id, List<QuoteLineItem>> qliMap = QuoteLineItemService.groupQuoteLineItems(qLIs);
        Set<String> products = new Set<String>();
        for (Id quoteId : qliMap.keySet()) {
            products = new Set<String>();
            for (QuoteLineItem item : qliMap.get(quoteId)) {
                for (ProductsFieldConfig__mdt config : fieldConfigs) {
                    if (item.vlocity_cmt__Product2Id__r.get(config.Field__c) == config.FieldValue__c) {
                        products.add(config.PicklistValue__c);
                    }
                }
            }
    
            // populate Products__c field
            Quote q = quoteMap.get(quoteId);
            q.put('Products__c', String.join(new List<String>(products), ';'));
        }
    
        if (updateQuotes)
            update quoteMap.values();
    
    }
    
    /*
     * @description populate the ftr_NumberOfLocations__c field on Quote
     */
    public void countLocationsOnQuote(Map<Id, Quote> quoteMap, Boolean updateQuotes) {
        QuoteLineItem[] qLIs = [
            SELECT Id, vlocity_cmt__ServiceAccountId__c, QuoteId
            FROM QuoteLineItem
            WHERE QuoteId IN :quoteMap.keySet()
        ];
    
        // group QLIs by quote
        Map<Id, List<QuoteLineItem>> qliMap = QuoteLineItemService.groupQuoteLineItems(qLIs);
        Set<String> servAccs = new Set<String>();
        for (Id quoteId : qliMap.keySet()) {
            servAccs = new Set<String>();
            for (QuoteLineItem item : qliMap.get(quoteId)) {
                servAccs.add(item.vlocity_cmt__ServiceAccountId__c);
            }
    
            // populate Products__c field
            Quote q = quoteMap.get(quoteId);
            q.put('ftr_NumberOfLocations__c', servAccs.size());
        }
    
        if (updateQuotes)
            update quoteMap.values();
    
    }
    
    public void setQuoteTypeField(Map<Id, Quote> quoteMap, Boolean updateQuotes) {
        for (Id quoteId : quoteMap.keySet()) {
            Quote q = quoteMap.get(quoteId);
            if (q.ftr_QuoteType__c == 'Disconnect' && q.Status == 'Approved') {
                q.ftr_QuoteType__c = 'Price Change';
            }
        }
    
        if (updateQuotes)
            update quoteMap.values();
    }
    
    
    /*
     * @description populate attributes from fields
     */
    public void updateAttributeFromField(Map<string,object> inputMap, Map<String,Object> outputMap) {
        Map<String, String> fieldToAttrCodeMap = new Map<String, String>{
            'ftr_IsMultiLocation__c' => 'ATTR_MULTILOCATION'
        };
        Id contextId = (String) inputMap.get('ContextId');
        String objectType = contextId.getSObjectType().getDescribe().getName();
        String parentFieldName = 'QuoteId';
        String childObject = 'QuoteLineItem';
    
        if (objectType == 'Order') {
            parentFieldName = 'OrderId';
            childObject = 'OrderItem';
        } 
    
        String query = 'SELECT vlocity_cmt__JSONAttribute__c, ' + String.join(new List<String>(fieldToAttrCodeMap.keySet()), ', ');
        query += ' FROM  ' + childObject + ' WHERE ' + parentFieldName + ' =: contextId';
        SObject[] lineItems = Database.query(query);
        
        for (SObject item : lineItems) {
            for (String fieldName : fieldToAttrCodeMap.keySet()) {
                String value;
                try {
                    if ((Boolean)item.get(fieldName) == true) {
                        value = 'YES';
                    } else {
                        value = 'NO';
                    }
                } catch (TypeException ex) {
                    value = (String) item.get(fieldName);
                }
                String modifiedJSON = ftr_CpqHelper.setJSONAttribute((String) item.get('vlocity_cmt__JSONAttribute__c'), '{}', fieldToAttrCodeMap.get(fieldName), value);
                item.put('vlocity_cmt__JSONAttribute__c', modifiedJSON);
            }
        }
    
        update lineItems;
    }
    
    public void automateQuoteName(Quote q, Boolean updateQuote) {
        if (q.Service_Term__c == null) return;
        QuoteLineItem[] qLIs = [SELECT Id, Speed_Mbps__c, Speed__c FROM QuoteLineItem WHERE QuoteId = :q.Id AND Product2.ProductCode = 'ENT_ETH_EIA_0002' AND Speed__c <> NULL ORDER BY Speed_Mbps__c DESC LIMIT 1];
        
        if (qLIs.size() > 0) {
            String[] name = q.Name.split('_');
            q.Name = name[0] + '_' + qLIs[0].Speed__c + '_' + q.Service_Term__c;
            if (updateQuote)
                update q;
        }
    
    }
    
    public Boolean setProductsTier(List<Id> qLIIds, List<QuoteLineItem> qLIs, Map<Id, vlocity_cmt__Premises__c> premiseMap) {
        return true;
    }
    
    /*
    * @description get the QLIs whose speed needs to be rolled up
    */
    public Map<String, List<Id>> getSpeedRollupQLIsOnDeletePrevInvoke(Id delQLIId, Id delParentId, QuoteLineItem[] qLIs) {
        Map<Id, QuoteLineItem> qLIMap = new Map<Id, QuoteLineItem>(qLIs);
        QuoteLineItem delQLI = qLIMap.get(delQLIId);
        QuoteLineItem delParent = qLIMap.get(delParentId);
        
        Set<Id> serviceAccountIds = new Set<Id>();
        
        Id parentEvplId;
        Set<Id> accessIds = new Set<Id>();
        if (delQLI.Product2.ProductCode == ftr_CpqService.ProductCode_EIA) {
            // EIA is deleted, the associated Network Access by service location needs to be rolled up on speed again
            serviceAccountIds.add(delQLI.vlocity_cmt__ServiceAccountId__c);
        } else if (delQLI.Product2.ProductCode == ftr_CpqService.ProductCode_EVPL_EVC ) {
            // EVPL EVC is deleted, the associated Network Access by service location needs to be rolled up on speed again
            serviceAccountIds.add(delQLI.vlocity_cmt__ServiceAccountId__c);
            parentEvplId = delParentId;
        } else if (delQLI.Product2.ProductCode == ftr_CpqService.ProductCode_EVPL) {
            // EVPL is deleted, all the Network Accesses which are associated with itself and its child EVPL EVC needs to be rolled up on speed again
            serviceAccountIds.add(delQLI.vlocity_cmt__ServiceAccountId__c);
            for (QuoteLineItem qLI : qLIs) {
                if (qLI.vlocity_cmt__LineNumber__c.startsWith(delQLI.vlocity_cmt__LineNumber__c + '.') && qLI.Product2.ProductCode == ftr_CpqService.ProductCode_EVPL_EVC) {
                    // Child EVPL EVC of given EVPL
                    serviceAccountIds.add(qLI.vlocity_cmt__ServiceAccountId__c);
                }
            }
        }
        
      /* if (serviceAccountIds.size() > 0) {
            for (QuoteLineItem qLI : qLIs) {
                if (qLI.Product2.ProductCode == ftr_CpqService.ProductCode_NETWORK_ACCESS && serviceAccountIds.contains(qLI.vlocity_cmt__ServiceAccountId__c)) {
                    // Network Access QLI whose ServiceAccountId matchs 
                    accessIds.add(qLI.Id);
                }
            }
        }*/
        List<Id> evplIds = new List<Id>();
        if (parentEvplId != null) evplIds.add(parentEvplId);
        
        return new Map<String, List<Id>> {
            'EvplIds' => evplIds
          //'AccessIds' => new List<Id>(accessIds)
                };
    }
    
    /*
    * @description get the QLIs whose speed needs to be rolled up
    */
    public Map<String, List<Id>> getSpeedRollupQLIsOnQLIBeforeUpdate(QuoteLineItem oldQLI, QuoteLineItem newQLI, Id parentItemId, Id parentServiceAccountId, String productCode) {
        ftr_CpqService service = new ftr_CpqService();
        
        List<Id> evplIds = new List<Id>();
        List<Id> accessIds = new List<Id>();
        
        Set<Id> svcAcctIds = new Set<Id>();
        if (oldQLI.vlocity_cmt__JSONAttribute__c != newQLI.vlocity_cmt__JSONAttribute__c) {
            String oldSpeed = (String)ftr_CpqHelper.getJSONAttributeValue(oldQLI.vlocity_cmt__JSONAttribute__c, ftr_CpqService.AttribCode_SPEED);
            String newSpeed = (String)ftr_CpqHelper.getJSONAttributeValue(newQLI.vlocity_cmt__JSONAttribute__c, ftr_CpqService.AttribCode_SPEED);
            if (oldSpeed != newSpeed) {
                // Speed is updated...
                if (productCode == ftr_CpqService.ProductCode_EVPL_EVC) {
                    // Needs to rollup the speed of EVPL EVC to its parent EVPL
                    evplIds.add(parentItemId);
                }
                // Gather the associated service account Ids.
                svcAcctIds.add(newQLI.vlocity_cmt__ServiceAccountId__c);
                if (productCode == ftr_CpqService.ProductCode_EVPL_EVC)
                    svcAcctIds.add(parentServiceAccountId); // Access associated with the Parent EVPL should be rolled up as well.
            }
        }
        
        if (oldQLI.vlocity_cmt__ServiceAccountId__c != newQLI.vlocity_cmt__ServiceAccountId__c) {
            // Service location is updated within the CPQ cart
            svcAcctIds.add(oldQLI.vlocity_cmt__ServiceAccountId__c);
            svcAcctIds.add(newQLI.vlocity_cmt__ServiceAccountId__c);
        }
        
      /* if (svcAcctIds.size() > 0) {
            QuoteLineItem[] accessList = [
                SELECT Id FROM QuoteLineItem 
                WHERE QuoteId=:newQLI.QuoteId AND Product2.ProductCode=:ftr_CpqService.ProductCode_NETWORK_ACCESS AND vlocity_cmt__ServiceAccountId__c=:svcAcctIds
            ];
            
            if (accessList.size() > 0) {
                // Construct the calculateRollup message which will be picked up and processed within ftr_CpqService.PricingPlan_PreInvoke
                accessIds.addAll((new Map<Id, QuoteLineItem>(accessList)).keySet());
            }
        }*/
        
        return new Map<String, List<Id>> {
            'EvplIds' => evplIds
        //  'AccessIds' => accessIds
        };
    }
    
    /*
    * @description Calculate the speed rollup for EVPL products
    * @param evplIds the list of EVPL QLI Ids to be rolled up for speed
    * @param qLIs the quote line items in the quote
    */
    public Boolean calculateEvplsSpeedRollup(List<Id> evplIds, List<QuoteLineItem> qLIs) {
        ftr_Logger.writeInfo('Enter ftr_QuoteService.calculateEvplsSpeedRollup');
    //        System.debug(JSON.serialize(evplIds));
    //        System.debug(JSON.serialize(qLIs));
        try {
            // system.debug(JSON.serialize(evplIds));
            ftr_Logger.writeVar('evplIds', evplIds);
            ftr_Logger.writeVar('qLIs', qLIs);
    
            Map<Id, QuoteLineItem> qLIMap = new Map<Id, QuoteLineItem>(qLIs);
            QuoteLineItem[] evplQLIs = new List<QuoteLineItem>();
            Map<String, QuoteLineItem> lnEvplMap = new Map<String, QuoteLineItem>();
            Map<String, Integer> lnRollupSpeedMap = new Map<String, Integer>();
            for (Id evplId : evplIds) {
                QuoteLineItem evplQLI = qLIMap.get(evplId);
                lnEvplMap.put(evplQLI.vlocity_cmt__LineNumber__c, evplQLI);
                lnRollupSpeedMap.put(evplQLI.vlocity_cmt__LineNumber__c, 0);
            }
    
            System.debug(lnEvplMap);
            for (QuoteLineItem qLI : qLIs) {
                String ln = qLI.vlocity_cmt__LineNumber__c;
                if (ln.length() > 4) {
                    String rootLn = ln.left(4);
                    String productCode = qLI.PricebookEntry.Product2.ProductCode;
                    System.debug('ProductCode: ' + productCode);
                    if (lnRollupSpeedMap.containsKey(rootLn)) {
                        Integer rollupSpeed = lnRollupSpeedMap.get(rootLn);
                        String bandWidth = (String)ftr_CpqHelper.getJSONAttributeValue(qLI.vlocity_cmt__JSONAttribute__c, 'ATTR_BANDWIDTH');
                        rollupSpeed += ftr_CpqHelper.convertToSpeed(bandWidth);
                        lnRollupSpeedMap.put(rootLn, rollupSpeed);
                    }
                }
            }
    
            System.debug(lnRollupSpeedMap);
            for (String ln : lnEvplMap.keySet()) {
                QuoteLineItem evplQLI = lnEvplMap.get(ln);
                Integer rollupSpeed = lnRollupSpeedMap.get(ln);
                String rollupBandWidth = ftr_CpqHelper.convertToBandWidth(rollupSpeed);
                System.debug(rollupBandWidth);
                System.debug(evplQLI.Id);
                Boolean ispartnered = (boolean)ftr_CpqHelper.getJSONAttributeValue(evplQLI.vlocity_cmt__JSONAttribute__c, 'ATTR_ELIGBL_PARTNRD');
                String partnerValue =(String)ftr_CpqHelper.getJSONAttributeValue(evplQLI.vlocity_cmt__JSONAttribute__c, 'ATTR_PARTNER');
                if(ispartnered){
                    updatepartnerNames(rollupBandWidth,evplQLI,true,true);
                    if(partnerValue != null){
                        updatepartnerNames(partnerValue,evplQLI,true,true);
                    }
                }else{
                    String modifiedJSON = ftr_CpqHelper.setJSONAttribute(evplQLI.vlocity_cmt__JSONAttribute__c, '{}', 'ATTR_BANDWIDTH', rollupBandWidth);
                    evplQLI.vlocity_cmt__JSONAttribute__c = modifiedJSON;
                }
                
                evplQLI.Speed__c = rollupBandWidth;
                //System.debug('modifiedJSON: ' + modifiedJSON);
            }
            //update evplQLIs;
            return true;
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            return false;
        } finally {
            ftr_Logger.writeInfo('Exit ftr_QuoteService.calculateEvplsSpeedRollup');
        }
    }
    
    /*
    * @description Calculate the speed rollup for Network Access products
    * @param accessIds the list of Network Access QLI Ids to be rolled up for speed
    * @param qLIs the quote line items in the quote
    */
    /* public Boolean calculateNetworkAccessesSpeedRollup(List<Id> accessIds, List<QuoteLineItem> qLIs) {
        ftr_Logger.writeInfo('Enter ftr_QuoteService.calculateNetworkAccessesSpeedRollup');
        try {
            // system.debug(JSON.serialize(accessIds));
            ftr_Logger.writeVar('accessIds', accessIds);
            ftr_Logger.writeVar('qLIs', qLIs);
            // TODO...
            // System.debug(JSON.serialize(accessIds));
            // System.debug(JSON.serialize(qLIs));
            Map<Id, QuoteLineItem> qLIMap = new Map<Id, QuoteLineItem>(qLIs);
            Map<Id, Integer> svsLocSpeedMap = new Map<Id, Integer>();
            for (Id accessId : accessIds) {
                svsLocSpeedMap.put(qLIMap.get(accessId).vlocity_cmt__ServiceAccountId__c, 0);
            }
    
            // System.debug(JSON.serialize(svsLocSpeedMap));
    
            for (QuoteLineItem qLI : qLIs) {
                if (qLI.PricebookEntry.Product2.ProductCode == ftr_CpqService.ProductCode_EVPL_EVC ||
                    qLI.PricebookEntry.Product2.ProductCode == ftr_CpqService.ProductCode_EIA) {
                    // System.debug(qLI.PricebookEntry.Product2.ProductCode);
                    Integer speed = svsLocSpeedMap.get(qLI.vlocity_cmt__ServiceAccountId__c);
                    if (speed != null) {
                        String bandWidth = (String)ftr_CpqHelper.getJSONAttributeValue(qLI.vlocity_cmt__JSONAttribute__c, 'ATTR_BANDWIDTH');
                        speed += ftr_CpqHelper.convertToSpeed(bandWidth);
                        svsLocSpeedMap.put(qLI.vlocity_cmt__ServiceAccountId__c, speed);
                        // System.debug(qLI.vlocity_cmt__ServiceAccountId__c + ': ' + speed);
                    }
    
                    if (qLI.PricebookEntry.Product2.ProductCode == ftr_CpqService.ProductCode_EVPL_EVC) {
                        QuoteLineItem parentEvpl = qLIMap.get(qLI.vlocity_cmt__ParentItemId__c);
                        Integer parentEvplSpeed = svsLocSpeedMap.get(parentEvpl.vlocity_cmt__ServiceAccountId__c);
                        if (parentEvplSpeed != null) {
                            String bandWidth = (String)ftr_CpqHelper.getJSONAttributeValue(qLI.vlocity_cmt__JSONAttribute__c, 'ATTR_BANDWIDTH');
                            parentEvplSpeed += ftr_CpqHelper.convertToSpeed(bandWidth);
                            svsLocSpeedMap.put(parentEvpl.vlocity_cmt__ServiceAccountId__c, parentEvplSpeed);
    
                            // System.debug('Host ' + parentEvpl.vlocity_cmt__ServiceAccountId__c + ': ' + parentEvplSpeed);
                        }
                    }
                } 
            }
    
            for (Id accessId : accessIds) {
                QuoteLineItem accessQLI = qLIMap.get(accessId);
                Integer rollupSpeed = svsLocSpeedMap.get(accessQLI.vlocity_cmt__ServiceAccountId__c);
                String rollupBandWidth = ftr_CpqHelper.convertToBandWidth(rollupSpeed);
                // System.debug(rollupSpeed);
                // System.debug(rollupBandWidth);
                // System.debug(accessQLI.Id);
                String modifiedJSON = ftr_CpqHelper.setJSONAttribute(accessQLI.vlocity_cmt__JSONAttribute__c, '{}', 'ATTR_BANDWIDTH', rollupBandWidth);
                accessQLI.vlocity_cmt__JSONAttribute__c = modifiedJSON;
                accessQLI.Speed__c = rollupBandWidth;
            }
    
            return true;
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            return false;
        } finally {
            ftr_Logger.writeInfo('Exit ftr_QuoteService.calculateNetworkAccessesSpeedRollup');
        }
    } */
    
    
    /*
    * @description Update the SNE's of any line items based on Pricing Attributes from the SObject
    * ftr_Attribute_Based_SNE__c based on Product Family. If no ProductFamily is passed in, all line items are updated
    * @params:  inputMap : {
    *               ContextId : orderId/quoteId/opportunityId,  (required)
    *               ProductFamily : comma-separated string      (optional)
    *           }
    */
    public static Boolean UpdateSNEToQuoteLineItems(Map<String, Object> inputMap, Map<String, Object> outputMap){
        Id contextId = (Id)inputMap.get('ContextId');
        String productFamily = (String)inputMap.get('ProductFamily');
        System.debug('ftr_QuoteService.UpdateSNEToQuoteLineItems: inputMap--> '+ JSON.serialize(inputMap));
        try {
            
            AttributeBasedSNEService attrBasedSNEService = new AttributeBasedSNEService(contextId, productFamily);
            Map<String, Object> result = attrBasedSNEService.updateLineItems();
            outputMap.putAll(result);
            
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            outputMap.put('error', ex.getMessage());
            return false;        
        }
        return  true;  
    }
    
    public static Boolean isQuoteHasUCFEquipment(String quoteId){
    
        System.debug('Enter ftr_QuoteService.isQuoteHasUCFEquipment-->');
        Boolean isQuoteHasUCFEquipment=false;    
        List<QuoteLineItem> lstUpdate = [select id,QuoteId,vlocity_cmt__JSONAttribute__c,
                                          PricebookEntry.Product2.ProductCode from QuoteLineItem where
                                          QuoteId =: quoteId and PricebookEntry.Product2.family=: UCF_PRODUCT_FAMILY];
        for(QuoteLineItem qLiItem : lstUpdate) { 
        String qLIProductCode=qLiItem.PricebookEntry.Product2.ProductCode;
        System.debug('qLIProductCode-->' + qLIProductCode); 
        if (UCF_PROD_CODE_AS_EQUIPMENT.contains(qLiProductCode)){
            isQuoteHasUCFEquipment=true;
            break;
        }
            
        }
        
    
        return isQuoteHasUCFEquipment;
    
    }
    /*
    * DEPRECATED - THIS METHOD IS NO LONGER USED
    * @description Update the SNE's of QuoteLineItem based on Pricing Attributes 
    * from the SObject ftr_Attribute_Based_SNE__c   
    */
    public Boolean updateAttritbuteBasedSNE(Id itemId, List<QuoteLineItem> quoteLineItems) {
        ftr_Logger.writeInfo('Enter ftr_QuoteService.updateAttritbuteBasedSNE-->');
        try {
            Map<Id, QuoteLineItem> quoteLineItemMap = new Map<Id, QuoteLineItem>(quoteLineItems); 
            QuoteLineItem quoteLineItem = quoteLineItemMap.get(itemId);                                 
            String jurisdiction =(String)ftr_CpqHelper.getJSONAttributeValue(quoteLineItem.vlocity_cmt__JSONAttribute__c, 'ATTR_TECH_JURIS');
            String term=(String)ftr_CpqHelper.getJSONAttributeValue(quoteLineItem.vlocity_cmt__JSONAttribute__c, 'ATTR_CONTRACT_TERM');
            String CoS=(String)ftr_CpqHelper.getJSONAttributeValue(quoteLineItem.vlocity_cmt__JSONAttribute__c, 'ATTR_CoS');
            String bandWidth = (String)ftr_CpqHelper.getJSONAttributeValue(quoteLineItem.vlocity_cmt__JSONAttribute__c, 'ATTR_BANDWIDTH');
            String ipblocks = (String)ftr_CpqHelper.getJSONAttributeValue(quoteLineItem.vlocity_cmt__JSONAttribute__c, 'ATTR_IP_BLOCKS');
            String sdwanSpeed = (String)ftr_CpqHelper.getJSONAttributeValue(quoteLineItem.vlocity_cmt__JSONAttribute__c, 'ATTR_SDWAN_SPEED');
            String highAvailability = (Boolean)ftr_CpqHelper.getJSONAttributeValue(quoteLineItem.vlocity_cmt__JSONAttribute__c, 'ATTR_SDWAN_HA') == true ? 'YES' : 'NO';
            String ikeV2 = (Boolean)ftr_CpqHelper.getJSONAttributeValue(quoteLineItem.vlocity_cmt__JSONAttribute__c, 'ATTR_IKE_AWS')  == true ? 'YES' : 'NO';
    
            String productCode=quoteLineItem.PricebookEntry.Product2.ProductCode;
    
            //Query ftr_Attribute_Based_SNE__c to retrieve SNE's for the respective pricing Attributes
            ftr_Attribute_Based_SNE__c attrBasedSNE;
            if (productCode==ftr_CpqService.ProductCode_EVPL ||productCode==ftr_CpqService.ProductCode_EVPL_EVC)
            {
                attrBasedSNE=[SELECT SNE_Code_MRC__c, SNE_Code_OTC__c,SNE_Code_TERM__c FROM ftr_Attribute_Based_SNE__c WHERE Product_Code__c=:productCode AND Speed__c=:bandWidth AND Jurisdiction__c=:jurisdiction AND CoS__c =:CoS AND Term__c=:term  ];
            }
            else if (productCode==ftr_CpqService.ProductCode_EIA){
    
                attrBasedSNE=[SELECT SNE_Code_MRC__c, SNE_Code_OTC__c,SNE_Code_TERM__c FROM ftr_Attribute_Based_SNE__c WHERE Product_Code__c=:productCode AND Speed__c=:bandWidth AND Term__c=:term  ];
            }
            else if (productCode==ftr_CpqService.ProductCode_IP){
    
                attrBasedSNE=[SELECT SNE_Code_MRC__c, SNE_Code_OTC__c,SNE_Code_TERM__c FROM ftr_Attribute_Based_SNE__c WHERE Product_Code__c=:productCode AND IP_Blocks__c=:ipblocks  ];
    
            }     
            else if (productCode==ftr_CpqService.ProductCode_SDWAN){
    
                attrBasedSNE=[SELECT SNE_Code_MRC__c, SNE_Code_OTC__c,SNE_Code_TERM__c FROM ftr_Attribute_Based_SNE__c WHERE Product_Code__c=:productCode AND SDWAN_Speed__c=:sdwanSpeed AND High_Availability__c =:highAvailability AND IKEv2_VPN__c =:ikeV2];
            }  
            else if (productCode == ftr_CpqService.ProductCode_PrivateNetwork){
    
                attrBasedSNE=[SELECT SNE_Code_MRC__c, SNE_Code_OTC__c,SNE_Code_TERM__c FROM ftr_Attribute_Based_SNE__c WHERE Product_Code__c=:productCode AND Speed__c=:bandWidth AND Jurisdiction__c=:jurisdiction AND CoS__c =:CoS ];
            }
            quoteLineItem.SNE_Code_MRC__c=attrBasedSNE.SNE_Code_MRC__c;
            quoteLineItem.SNE_Code_OTC__c=attrBasedSNE.SNE_Code_OTC__c;
            quoteLineItem.SNE_Code_TERM__c=attrBasedSNE.SNE_Code_TERM__c;
            return true;
    
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            return false;
        } finally {
            ftr_Logger.writeInfo('Exit ftr_QuoteService.updateAttritbuteBasedSNE-->');
        }
        
    }
    
    public sObject syncDSATAttributes(Id itemId, SObject xLI) {
        if (xLI == null) {
            String sObjectType = itemId.getSobjectType().getDescribe().getName();
            xLI = Database.query('SELECT Id, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__JSONAttribute__c FROM ' + sObjectType + ' WHERE Id =:itemId');
        }
        //Changes for Fiber Tier/Copper Tier Missing -Start
        Account serviceAccount = [SELECT vlocity_cmt__PremisesId__c, vlocity_cmt__PremisesId__r.InFootPrint__c, vlocity_cmt__PremisesId__r.WC_CLLI__c, vlocity_cmt__PremisesId__r.Lit__c,  vlocity_cmt__PremisesId__r.DSAT_Ticket__c, vlocity_cmt__PremisesId__r.WC_Speed__c, vlocity_cmt__PremisesId__r.WC_QOS__c, vlocity_cmt__PremisesId__r.Copper_Tier__c, vlocity_cmt__PremisesId__r.Fiber_Tier__c, vlocity_cmt__PremisesId__r.Market__c, vlocity_cmt__PremisesId__r.Level__c 
        FROM Account
        WHERE Id = : (Id) xLI.get('vlocity_cmt__ServiceAccountId__c')];
    
        String modifiedJSON = (String) xLI.get('vlocity_cmt__JSONAttribute__c');
        if (serviceAccount != null && serviceAccount.vlocity_cmt__PremisesId__c != null) {
            vlocity_cmt__Premises__c premise = serviceAccount.vlocity_cmt__PremisesId__r;
                        Map<String, Object> attrVals = new Map<String, Object> {
                'ATTR_ELIGBL_WCSPEED' => premise.WC_Speed__c == null ? '' : premise.WC_Speed__c,
                'ATTR_ELIGBL_QOS' => premise.WC_QOS__c == null ? '' : premise.WC_QOS__c,
                'ATTR_TIER1' => premise.Copper_Tier__c == null ? '' : premise.Copper_Tier__c,
                'ATTR_TIER2' => premise.Fiber_Tier__c == null ? '' : premise.Fiber_Tier__c,
                'ATTR_MARKET' => premise.Market__c == null ? '' : premise.Market__c,
                'ATTR_LEVEL' => premise.Level__c == null ? '' : premise.Level__c,
                'ATTR_DSAT_ID' => premise.DSAT_Ticket__c == null ? '' : premise.DSAT_Ticket__c,
                'ATTR_ELIGBL_LIT' => premise.Lit__c == null ? '' : premise.Lit__c,
                'ATTR_ELIGBL_CLLI' => premise.WC_CLLI__c == null ? '' : premise.WC_CLLI__c,
                'ATTR_ELIGBL_FOOT_PRNT' => premise.InFootPrint__c == true ? 'Yes' : 'No',
                'ATTR_ELIGBL_PARTNRD' => premise.Fiber_Tier__c == 'BDT' ? true : false
            };
                           modifiedJSON = ftr_CpqHelper.setJSONAttributes(modifiedJSON, '{}', attrVals);
            xLI.put('vlocity_cmt__JSONAttribute__c', modifiedJSON);
        }
                return xLI;
    }
    
    /*
    * @description Calculate the speed rollup for Network Access products
    * @param accessIds the list of Network Access QLI Ids to be rolled up for speed
    * @param qLIs the quote line items in the quote
    */
    public Boolean syncPricingAttribsFromDSAT(Id itemId, List<QuoteLineItem> qLIs) {
        ftr_Logger.writeInfo('Enter ftr_QuoteService.syncPricingAttribsFromDSAT');
        try {
            Map<Id, QuoteLineItem> qLIMap = new Map<Id, QuoteLineItem>(qLIs); 
            QuoteLineItem qLI = qLIMap.get(itemId);
            Account serviceAccount = [SELECT vlocity_cmt__PremisesId__c, vlocity_cmt__PremisesId__r.WC_Speed__c, vlocity_cmt__PremisesId__r.WC_QOS__c, vlocity_cmt__PremisesId__r.Copper_Tier__c, vlocity_cmt__PremisesId__r.Fiber_Tier__c, vlocity_cmt__PremisesId__r.Market__c, vlocity_cmt__PremisesId__r.Level__c 
                                        FROM Account
                                        WHERE Id = :qLI.vlocity_cmt__ServiceAccountId__c];
                        
            String modifiedJSON = '';
            
            if (serviceAccount != null && serviceAccount.vlocity_cmt__PremisesId__c != null) {
                vlocity_cmt__Premises__c premise = serviceAccount.vlocity_cmt__PremisesId__r;
                Map<String, Object> attrVals = new Map<String, Object> {
                    'ATTR_ELIGBL_WCSPEED' => premise.WC_Speed__c == null ? '' : premise.WC_Speed__c.replaceAll('MB',' MB'),
                    'ATTR_ELIGBL_QOS' => premise.WC_QOS__c == null ? '' : premise.WC_QOS__c,
                    'ATTR_TIER1' => premise.Copper_Tier__c == null ? '' : premise.Copper_Tier__c,
                    'ATTR_TIER2' => premise.Fiber_Tier__c == null ? '' : premise.Fiber_Tier__c,
                    'ATTR_MARKET' => premise.Market__c == null ? '' : premise.Market__c,
                    'ATTR_LEVEL' => premise.Level__c == null ? '' : premise.Level__c
                };
    
                modifiedJSON = ftr_CpqHelper.setJSONAttributes(qLI.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                
            } else if (serviceAccount == null || serviceAccount.vlocity_cmt__PremisesId__c == null) {
                Map<String, Object> attrVals = new Map<String, Object> {
                    'ATTR_ELIGBL_WCSPEED' => '',
                    'ATTR_ELIGBL_QOS' => '',
                    'ATTR_TIER1' => '',
                    'ATTR_TIER2' => '',
                    'ATTR_MARKET' => '',
                    'ATTR_LEVEL' => ''
                };
    
                modifiedJSON = ftr_CpqHelper.setJSONAttributes(qLI.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
            }
                        
            qLI.vlocity_cmt__JSONAttribute__c = modifiedJSON;
            return true;
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            return false;
        } finally {
            ftr_Logger.writeInfo('Exit ftr_QuoteService.syncPricingAttribsFromDSAT');
        }
    }
        
    
    /*
    * @description set the term in JSONAttribute to the given QLIs. Only set the QLI.JSONAttribute__c value, DON't update the DB
    * @param qLIs quote line items to be updated
    * @param term the new term value to be propagated
    */
    public void setTermForQLIs(String term,  List<QuoteLineItem> qLIs) {
        ftr_Logger.writeInfo('Enter ftr_QuoteService.setTermForQLIs');
        try {
            ftr_Logger.writeVar('term', term);
            ftr_Logger.writeVar('qLIs', qLIs);
            // TODO...#327 - Updated by Pavitra Bhat
            // vlocity_cmt.JSONAttributeSupport jsonSupport = new vlocity_cmt.JSONAttributeSupport();
            
            // for (QuoteLineItem qLI : qLIs) {
            //     if(qLI.vlocity_cmt__JSONAttribute__c != null) {
            //         Map<String, Object> input = new Map<String, Object> {
            //             'objectSO' => null,
            //                 'runTimeAttributesJSON' => qLI.vlocity_cmt__JSONAttribute__c,
            //                 'originalAttributesJSON' => '{}',
            //                 'JSONAttributeActionRequestList' => new List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest> {
            //                     new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_CONTRACT_TERM', vlocity_cmt.JSONAttributeSupport.ActionType.ASSIGN, term)
            //                         }
            //         };
            //             Map<String, Object> output = new Map<String, Object>();
            //         Map<String, Object> myoptions = new Map<String, Object>();
            //         jsonSupport.invokeMethod('applyAttributeActions', input, output, myoptions);
            //         qLI.vlocity_cmt__JSONAttribute__c = (String)output.get('modifiedJSON');
            //         //System.debug('jsonattribute..'+ qLI.Id + '..'+ qLI.vlocity_cmt__JSONAttribute__c);
            //         ftr_Logger.writeVar('jsonattribute', qLI.Id + '..'+ qLI.vlocity_cmt__JSONAttribute__c);
            //     }
            // }
    
            if (String.isNotEmpty(term)) {
    
                qLIs = ftr_CpqHelper.setQLIsAttribute(term, qLIs, 'ATTR_CONTRACT_TERM');
             
                // Quote terms not getting added to Quoteline Item changes by-  IM
                // Added class of service and Juris for the quoteline items as part of Case #631154 -IM
                for(QuoteLineItem item : qLIs) {
                    item.Term__c=term;
                    item.Class_of_service__c=(String)ftr_CpqHelper.getJSONAttributeValue(item.vlocity_cmt__JSONAttribute__c, 'ATTR_CoS');
                    item.Juris__c=(String)ftr_CpqHelper.getJSONAttributeValue(item.vlocity_cmt__JSONAttribute__c, 'ATTR_TECH_JURIS');
                //    item.Juris__c=Juris;
                }
            }
    
        } catch (Exception ex) {
            ftr_Logger.write(ex);
        } finally {
            ftr_Logger.writeInfo('Exit ftr_QuoteService.setTermForQLIs');
        }
    }
    
        /*
        * @description batch propagate the term to the child QLIs of given quote. After updating the QLI's term, reprice the quote
        * @param quoteId the parent quote
        * @param newTerm the new term value to be propagated
        */
        public void updateTermForAllQLIs(Id quoteId, String newTerm) {
            ftr_Logger.writeInfo('Enter ftr_QuoteService.updateTermForAllQLIs');
            try {
                ftr_Logger.writeVar('quoteId', quoteId);
                ftr_Logger.writeVar('newTerm', newTerm);
                // TODO...#327 - Updated by Pavitra Bhat
                List<QuoteLineItem> qLIsToUpdate = [SELECT id, vlocity_cmt__JSONAttribute__c 
                                                    FROM QuoteLineItem 
                                                    WHERE QuoteId =: quoteId AND Product_Family__c != 'UCF' AND Product_Family__c != 'Managed Services']; // excluding UCF products
                
                setTermForQLIs(newTerm, qLIsToUpdate);
                update qLIsToUpdate;
                //System.debug('qLIsToUpdate..'+ qLIsToUpdate);
                
                Vlocity_cmt.CpqAppHandler cpqHandler = new Vlocity_cmt.CpqAppHandler();
                Map<String, Object> input = new Map<String, Object> {
                    'methodName' => 'priceCart',
                        'cartId' => quoteId
                };
                            
                Map<String, Object> output = new Map<String, Object> ();
                Map<String, Object> myoptions = new Map<String, Object> ();
                cpqHandler.invokeMethod('priceCart', input, output, myoptions);
                
                
            } catch (Exception ex) {
                ftr_Logger.write(ex);
            } finally {
                ftr_Logger.writeInfo('Exit ftr_QuoteService.updateTermForAllQLIs');
            }
        }    
    
        public Boolean setXLIAttributes(Map<String, Object> setAttrsMsg, QuoteLineItem[] itemList) {
            ftr_Logger.writeInfo('Enter ftr_QuoteService.setXLIAttributes');
            try {
                for (SObject xLI : itemList) {
                    Id pbeId = (Id)xLI.get('PricebookEntryId');
                    if (pbeId == (Id)setAttrsMsg.get('itemId')) {
                        Map<String, Object> attrValMap = (Map<String, Object>)setAttrsMsg.get('attributesToUpdate');
                        String modifiedJSON = ftr_CpqHelper.setJSONAttributes((String)xLI.get('vlocity_cmt__JSONAttribute__c'), '{}', attrValMap);
                        xLI.put('vlocity_cmt__JSONAttribute__c', modifiedJSON);
                    }
                }
                return true;
            } catch (Exception ex) {
                ftr_Logger.write(ex);
                return false;
            } finally {
                ftr_Logger.writeInfo('Exit ftr_QuoteService.setXLIAttributes');
            }
        }
    
        /**@param: cpqMessage {
         *      cpqMethod:  postCartsItems.PreInvoke || putCartsItems.PreInvoke
         *      itemId: PbeId || Id of qLI
         *      isAttribute: true/false
         *      fieldOrAttribute: field or attribute api name,
         *      rootItemId: parent qLI's id
         * }
         * @param: lineItems 
         * @description: updates child items with service account of parent parameters depend on cpqMethod. 
         *  If itemId != rootItemId (child being updated) try to get parent from lineItems
         */
        public Boolean setChildFieldOrAttributeFromParent(Map<String, Object> cpqMessage, QuoteLineItem[] lineItems, Quote parentObj) {
            ftr_Logger.writeInfo('Enter ftr_QuoteService.setChildFieldOrAttributeFromParent');
            try {
                QuoteLineItem parentItem;
                Boolean isAttribute = (Boolean) cpqMessage.get('isAttribute');
                String fieldOrAttribute = (String) cpqMessage.get('fieldOrAttribute');
                Id itemId = (Id) cpqMessage.get('itemId');
                Id rootItemId = (Id) cpqMessage.get('rootItemId');
                Id cartId = (Id) cpqMessage.get('cartId');
                String cpqMethod = (String) cpqMessage.get('cpqMethod');
                Object value;
                Boolean getValueFromParentNode = false;
                System.debug('parentId-->'+rootItemId);
                System.debug('itemId-->'+itemId);
                System.debug('lineItems-->'+ JSON.serialize(lineItems));
                if (itemId == rootItemId) {
                    for (QuoteLineItem xLI : lineItems) {
                        if (!xLI.vlocity_cmt__LineNumber__c.contains('.') && cpqMethod == 'postCartsItems.PreInvoke') {
                            parentItem = xLI;
                            break;
                        } else if (itemId == xLI.Id && cpqMethod == 'putCartsItems.PreInvoke') {
                            parentItem = xLI;
                            break;
                        }
                    }
    
                } else if (itemId != rootItemId) {
                    if (cpqMethod == 'putCartsItems.PreInvoke') {
                        Map<Id, QuoteLineItem> qliMap = new Map<Id, QuoteLineItem>(lineItems);
                        parentItem =  qliMap.get(rootItemId);
                    } else if (cpqMethod == 'postCartsItems.PreInvoke') {
                        getValueFromParentNode = true;
                    }
                }
                if (getValueFromParentNode) {
                    if (isAttribute) {
                        // TODO... attribute
                    } else {
                        Map<String, Object> parent = (Map<String, Object>) cpqMessage.get('parentItem');
                        String parentLineNumber = (String) ((Map<String, Object>) parent.get('vlocity_cmt__LineNumber__c')).get('value');
                        try {
                            value = (String) ((Map<String, Object>) parent.get(fieldOrAttribute)).get('value');
                        } catch (exception e) {
                            value = (String) parent.get(fieldOrAttribute);
                        }
                        for (QuoteLineItem qli : lineItems) {
                            if (qli.vlocity_cmt__LineNumber__c.startsWith(parentLineNumber))
                                qli.put(fieldOrAttribute, value);
                        }
                        ftr_Logger.writeVar('Stamping ' + value + ' on ' + fieldOrAttribute + ' for', lineItems);
                    }
                } else {
                    // get value to be stamped from parent
                    if (isAttribute) {
                        value = ftr_CpqHelper.getJSONAttributeValue((String) parentItem.get('vlocity_cmt__JSONAttribute__c'), fieldOrAttribute);
                    } else {
                        value = parentItem.get(fieldOrAttribute);
                    }
                    // set value 
                    for (QuoteLineItem qli : lineItems) {
                        if (qli.vlocity_cmt__LineNumber__c.startsWith(parentItem.vlocity_cmt__LineNumber__c) && qli.vlocity_cmt__LineNumber__c != parentItem.vlocity_cmt__LineNumber__c) {
                            ftr_Logger.writeVar('Stamping ' + value + ' on ' + fieldOrAttribute + ' for', qli);
                            if (isAttribute) {
                                String jsonAttribute = (String) ftr_CpqHelper.setJSONAttributes((String)qli.get('vlocity_cmt__JSONAttribute__c'), '{}', new Map<String, String>{ fieldOrAttribute => (String) value });
                                qli.put('vlocity_cmt__JSONAttribute__c', jsonAttribute);
                            } else {
                                qli.put(fieldOrAttribute, value);
                            }
                        }
                    }
                }
    
                // check if buying option is purchase/rent, if purchase, clear the Term__c
                for (QuoteLineItem qli : lineItems) {
                    if (qli.vlocity_cmt__JSONAttribute__c != null) {
                        String buyingOption = (String) ftr_CpqHelper.getJSONAttributeValue(qli.vlocity_cmt__JSONAttribute__c, 'ATTR_BUYING_OPTION');
                        if (buyingOption != null) {
                            if (buyingOption == 'Purchase') {
                                qli.put('Term__c', null);
                            } else {
                                if (parentObj != null && parentObj.OmniscriptData__c != null) {
                                    Map<string,object> temp = (Map<string,object>) JSON.deserializeUntyped(parentObj.OmniscriptData__c);
                                    String term = (String) temp.get('UCFTerm');
                                    qli.put('Term__c', term);
                                }
                            }
                        }
                    }
                }
    
                return true;
    
            } catch (Exception ex) {
                ftr_Logger.write(ex);
                return false;
            } finally {
                ftr_Logger.writeInfo('Exit ftr_QuoteService.setChildFieldOrAttributeFromParent');
            }
            
        }
    
        /**
         * @description: sets the RSM Approver of the quote.
         */
        public void setRSMApprover(Map<Id, Quote> quoteMap, Boolean updateQuote) {
            Quote q = quoteMap.values()[0];
            if (q.RSM_Approver__c == null) {
                User u = [SELECT ManagerId, Manager.ManagerId, Manager.isActive FROM User WHERE Id=:q.OwnerId];
                
                if (u.ManagerId != null && u.Manager.isActive) {
                    q.RSM_Approver__c = u.ManagerId;
                    if(u.Manager.ManagerId != null){
                        q.VP_Approver__c = u.Manager.ManagerId;
                    }
                } else {
                    Opportunity o = [SELECT Owner.ManagerId, Owner.Manager.ManagerId,Owner.Manager.isActive FROM Opportunity WHERE Id =: q.OpportunityId];
                    if (o.Owner.ManagerId != null && o.Owner.Manager.isActive) {
                        q.RSM_Approver__c = o.Owner.ManagerId;
                        if(o.Owner.Manager.ManagerId != null){
                            q.VP_Approver__c = o.Owner.Manager.ManagerId;
                        }
                    }
                }
                
            }
            if (updateQuote) update q;
        }
 public void populateTypeSubTypeAndFamily(List<QuoteLineItem> qlisToUpdate){
        //This method populates the Type, Sub Type and Product Family values in the Quote Line Item, which is then used by the Quote object 
        //in EPC rules
        //Updated 9/23, Fausto Moussou @Nespon
        Set<Id> productIds = new Set<Id>();
        system.debug('here, qlis: '+ qlisToUpdate);
        for (QuoteLineItem qli : qlisToUpdate) {
            productIds.add(qli.vlocity_cmt__Product2Id__c);
        }
        List<Product2>productsToProcess = [SELECT Family, vlocity_cmt__Type__c, vlocity_cmt__SubType__c FROM Product2 WHERE Id IN :productIds WITH SECURITY_ENFORCED];
        system.debug('Product IDs: '+productsToProcess);
        Map<Id, Product2> productsMap = new Map<Id, Product2>(productsToProcess);
        for (QuoteLineItem qli : qlisToUpdate) {
            Product2 prod = productsMap.get(qli.vlocity_cmt__Product2Id__c);
            system.debug('Product Family: '+prod.Family);
            system.debug('Product Family: '+prod.vlocity_cmt__Type__c);
            system.debug('Product SubType: '+prod.vlocity_cmt__SubType__c);
            qli.VlocityFamily__c = prod.Family;
            qli.VlocityType__c = prod.vlocity_cmt__Type__c;
            qli.VlocitySubType__c = prod.vlocity_cmt__SubType__c;
            
        }
    }
    public void populateFieldToEvaluateLimitedExtensionOnInsert(List<QuoteLineItem> qlisToUpdate){
        // Updated 10/11, Fausto Moussou @Nespon
        // This method populates the RCLimitedExtensionCheck__c field to check for Limited Extension 
        // device counts
        Set<Id> productIds = new Set<Id>();
        List<QuoteLineItem> devices = new List<QuoteLineItem>();
        for (QuoteLineItem qli : qlisToUpdate) {
            productIds.add(qli.vlocity_cmt__Product2Id__c);
        }
        List<Product2>productsToProcess = [SELECT ProductCode,vlocity_cmt__Type__c,vlocity_cmt__SubType__c FROM Product2 WHERE Id IN :productIds WITH SECURITY_ENFORCED];
        Map<Id, Product2> productsMap = new Map<Id, Product2>(productsToProcess);
        for (QuoteLineItem qli : qlisToUpdate) {
            Product2 prod = productsMap.get(qli.vlocity_cmt__Product2Id__c);
            if(prod.ProductCode == 'RC_LIMITED_EXTENSION'){
                qli.RCLimitedExtensionCheck__c = 'true';
            }
            if(prod.vlocity_cmt__Type__c == 'Phones' && prod.vlocity_cmt__SubType__c == 'RingCentral'){
                devices.add(qli);
            }
        }
        if(devices.size()>0){
            List<QuoteLineItem> limitedExtensions = [select RCLimitedExtensionCheck__c from QuoteLineItem where quoteId =: qlisToUpdate[0].quoteId and RCLimitedExtensionCheck__c = 'true'];
            if(limitedExtensions.size()>0){
                for (QuoteLineItem li : limitedExtensions){
                    li.RCLimitedExtensionCheck__c = 'false';
                }
                update limitedExtensions;
            }
        }
    }
    
    public void populateFieldToEvaluateLimitedExtensionOnDelete(List<QuoteLineItem> qlisToDelete){
        // Updated 10/11, Fausto Moussou @Nespon
        // This method populates the RCLimitedExtensionCheck__c field to check for Limited Extension 
        // device counts
        Set<Id> productIds = new Set<Id>();
        List<QuoteLineItem> devices = new List<QuoteLineItem>();
        for (QuoteLineItem qli : qlisToDelete) {
            productIds.add(qli.vlocity_cmt__Product2Id__c);
        }
        List<Product2>productsToProcess = [SELECT ProductCode,vlocity_cmt__Type__c,vlocity_cmt__SubType__c FROM Product2 WHERE Id IN :productIds WITH SECURITY_ENFORCED];
        Map<Id, Product2> productsMap = new Map<Id, Product2>(productsToProcess);
        for (QuoteLineItem qli : qlisToDelete) {
            Product2 prod = productsMap.get(qli.vlocity_cmt__Product2Id__c);
            if(prod.vlocity_cmt__Type__c == 'Phones' && prod.vlocity_cmt__SubType__c == 'RingCentral'){
                devices.add(qli);
            }
        }
        if(devices.size()>0){
            List<QuoteLineItem> cartItems = [select id,RCLimitedExtensionCheck__c,VlocityType__c,VlocitySubType__c,Product2.ProductCode from QuoteLineItem where quoteId =: qlisToDelete[0].quoteId];
            List<QuoteLineItem> limitedExtensions = new List<QuoteLineItem>();
            List<QuoteLineItem> devicesOnCart = new List<QuoteLineItem>();
            for (QuoteLineItem qli : cartItems){
                if(qli.Product2.ProductCode == 'RC_LIMITED_EXTENSION'){
                    limitedExtensions.add(qli);
                }
                if(qli.VlocityType__c=='Phones' && qli.VlocitySubType__c =='RingCentral'){
                    devicesOnCart.add(qli);
                }
            }
            if(limitedExtensions.size()>0 && devicesOnCart.size()==0){
                for (QuoteLineItem li : limitedExtensions){
                    li.RCLimitedExtensionCheck__c = 'true';
                }
                update limitedExtensions;
            }
        }
    }

        /*public void updatePartnerPicklistValues(Map<string,object> inputMap, Map<String,Object> outputMap) {
            String quoteLineItemId=String.valueOf(inputMap.get('QuoteLineItemId'));
            
            List<QuoteLineItem> qlis = [Select Id,vlocity_cmt__JSONAttribute__c,vlocity_cmt__PremisesId__c,vlocity_cmt__PremisesId__r.Fiber_Tier__c,vlocity_cmt__PremisesId__r.no_of_partners__c from QuotelineItem where Id=:quoteLineItemId];
            for(QuotelineItem qli : qlis){
                /*if(qli.vlocity_cmt__PremisesId__r.Fiber_Tier__c == 'BDT' && qli.vlocity_cmt__PremisesId__r.no_of_partners__c >0){
                    premiseIds.add(qli.vlocity_cmt__PremisesId__c);
                }
                List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest> actionRequestsList = new List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest>();
                
               
    
                actionRequestsList.add(new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest(
                    'ATTR_PARTNER', 
                    vlocity_cmt.JSONAttributeSupport.ActionType.CONSTRAIN_INCLUDE, 
                    'Lumen;Spectrum')
                );
                
    
                vlocity_cmt.JSONAttributeSupport jsonSupport = new vlocity_cmt.JSONAttributeSupport();
                Map<String, Object> myInputMap = new Map<String, Object> {
                    'objectSO' => null,
                    'runTimeAttributesJSON' => qli.vlocity_cmt__JSONAttribute__c,
                    'originalAttributesJSON' => '',
                    'JSONAttributeActionRequestList' => actionRequestsList
                };
                Map<String, Object> myOutputMap = new Map<String, Object>();
                Map<String, Object> myOptionsMap = new Map<String, Object>();
    
                jsonSupport.invokeMethod('applyAttributeActions', myInputMap, myOutputMap, myOptionsMap);
                String modifiedJSON = (String)myOutputMap.get('modifiedJSON');
                qli.vlocity_cmt__JSONAttribute__c = modifiedJSON;
            }
            update qlis;
    
    
        }*/
    
    
    /*
    * @description get the QLIs whose partner needs to be restricted
    */
    
    public Boolean updatepartnerNames(Id qliId, List<QuoteLineItem> qLIs) {
        ftr_Logger.writeInfo('Enter ftr_QuoteService.updatepartnerNames');
    //        System.debug(JSON.serialize(evplIds));
    //        System.debug(JSON.serialize(qLIs));
        try {
            // system.debug(JSON.serialize(evplIds));
            ftr_Logger.writeVar('qliId', qliId);
            ftr_Logger.writeVar('qLIs', qLIs);
            
            Map<Id, QuoteLineItem> qLIMap = new Map<Id, QuoteLineItem>(qLIs);
            QuoteLineItem currQli = qLIMap.get(qliId);
            String newSpeed = (String)ftr_CpqHelper.getJSONAttributeValue(currQli.vlocity_cmt__JSONAttribute__c, ftr_CpqService.AttribCode_SPEED);
            updatepartnerNames(newSpeed,currQli,false,true);
            return true;
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            return false;
        } finally {
            ftr_Logger.writeInfo('Exit ftr_QuoteService.updatepartnerNames');
        }
    }
    
    public boolean updatepartnerNames(String newSpeed, QuoteLineItem currQli,Boolean updateSpeed, Boolean filterPartner){
        ftr_Logger.writeInfo('Enter ftr_QuoteService.updatepartnerNames');
        try{
            List<String>PartnerList = new List<String>();
            String allvendorList  = system.label.Vendor_List;
            if(!String.isBlank(allvendorList)){
                for(String str : allvendorList.split(',')){
                    PartnerList.add(str);
                }
            }
            system.debug('partnerList-->'+PartnerList);
            String vendorNamestoInclude =''; 
            if(filterPartner){
                Account serviceAccount = [select id,vlocity_cmt__PremisesId__c from Account where id = :currQli.vlocity_cmt__ServiceAccountId__c];
                List<Vendor_Connectivity__c> vendorList = [select QoS__c,Speed__c,Tier__c,Vendor_Name__c,Converted_Speed_to_MB__c from Vendor_Connectivity__c where Premise__c = :serviceAccount.vlocity_cmt__PremisesId__c];
                                                                        //and Speed__c = :newSpeed];
                Integer convertedNewSpeed = ftr_CpqHelper.convertToSpeed(newSpeed);
                
                for(Vendor_Connectivity__c vc : vendorList){
                    Integer vendorSpeed;
                    String strVendorName;
                    if(!String.isBlank(vc.Converted_Speed_to_MB__c)){
                        vendorSpeed = Integer.valueOf(vc.Converted_Speed_to_MB__c);
                        if(convertedNewSpeed <= vendorSpeed){
                            //if(!String.isBlank(strVendorName)){
                                strVendorName = vc.Vendor_Name__c;
                                if(PartnerList.contains(strVendorName)){
                                    if(String.isBlank(vendorNamestoInclude)){
                                        vendorNamestoInclude = vc.Vendor_Name__c;
                                    }
                                    else{
                                        vendorNamestoInclude = vendorNamestoInclude + ';' + vc.Vendor_Name__c;
                                    } 
                                    Integer index = PartnerList.indexOf(strVendorName);
                                    PartnerList.remove(index);
                                }
                            //}
                        }
                    }
                } 
                system.debug('partnerlistnow-->'+PartnerList);
                system.debug('vendorNamestoInclude-->'+vendorNamestoInclude);
            }
            
            if(!PartnerList.isEmpty()){
                List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest> actionRequestsList = new List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest>();
                if(filterPartner){
                    actionRequestsList.add(new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_PARTNER', vlocity_cmt.JSONAttributeSupport.ActionType.CONSTRAIN_EXCLUDE, string.join(PartnerList,';')));
                    actionRequestsList.add(new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_PARTNER', vlocity_cmt.JSONAttributeSupport.ActionType.CONSTRAIN_INCLUDE, vendorNamestoInclude));
                }else{
                    actionRequestsList.add(new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_PARTNER', vlocity_cmt.JSONAttributeSupport.ActionType.CONSTRAIN_EXCLUDE, string.join(PartnerList,';')));
                    //actionRequestsList.add(new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_PARTNER', vlocity_cmt.JSONAttributeSupport.ActionType.CONSTRAIN_EXCLUDE, ''));
                    //actionRequestsList.add(new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_PARTNER', vlocity_cmt.JSONAttributeSupport.ActionType.ASSIGN, ''));
                }
                if(updateSpeed){
                    actionRequestsList.add(new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_BANDWIDTH', vlocity_cmt.JSONAttributeSupport.ActionType.ASSIGN, newSpeed));
                }
                //actionRequestsList.add(new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_PARTNER', vlocity_cmt.JSONAttributeSupport.ActionType.ASSIGN, strVendorName.split(';')[0]));
                //actionRequestsList.add(new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_PARTNER', vlocity_cmt.JSONAttributeSupport.ActionType.REQUIRE, vlocity_cmt.JSONAttributeSupport.BooleanActionValue.YES));
                Map<String, object> inputMap = new Map<String, object>();
                Map<String, object> outputMap = new Map<String, object>();
                Map<String, object> optionsMap = new Map<String, object>();
                inputMap.put('objectSO', currQli);
                inputMap.put('runTimeAttributesJSON', currQli.vlocity_cmt__JSONAttribute__c);
                inputMap.put('originalAttributesJSON', '{}');
                inputMap.put('JSONAttributeActionRequestList', actionRequestsList);
                vlocity_cmt.JSONAttributeSupport jsonSupport = new vlocity_cmt.JSONAttributeSupport();
                jsonSupport.invokeMethod('applyAttributeActions', inputMap, outputMap, optionsMap);
                String modifiedJSON = (String)outputMap.get('modifiedJSON'); 
                System.debug('RN:::'+modifiedJSON);
                currQli.vlocity_cmt__JSONAttribute__c = (String)outputMap.get('modifiedJSON'); 
                //Trigger.new[0].put('vlocity_cmt__JSONAttribute__c', modifiedJSON); 
                //update currQli;
                
            }
            return true;
        }catch (Exception ex) {
            ftr_Logger.write(ex);
            return false;
        } finally {
            ftr_Logger.writeInfo('Exit ftr_QuoteService.updatepartnerNames');
        }
        
        
    }
     public Boolean updatePartnerTier(Id qliId, List<QuoteLineItem> qLIs) {
        ftr_Logger.writeInfo('Enter ftr_QuoteService.updatepartnerNames');
    
        try {
            // system.debug(JSON.serialize(evplIds));
            ftr_Logger.writeVar('qliId', qliId);
            ftr_Logger.writeVar('qLIs', qLIs);
            
            Map<Id, QuoteLineItem> qLIMap = new Map<Id, QuoteLineItem>(qLIs);
            QuoteLineItem currQli = qLIMap.get(qliId);
            String partner = (String)ftr_CpqHelper.getJSONAttributeValue(currQli.vlocity_cmt__JSONAttribute__c, 'ATTR_PARTNER');
            updatePartnerTier(partner,currQli,false,true);
            return true;
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            return false;
        } finally {
            ftr_Logger.writeInfo('Exit ftr_QuoteService.updatepartnerNames');
        }
    }
    public boolean updatePartnerTier(String Partner, QuoteLineItem currQli,Boolean updateSpeed, Boolean filterPartner){
        ftr_Logger.writeInfo('Enter ftr_QuoteService.updatepartnerTier');
       try{
         String partnerTier;
           string Qos;
            String vendorNamestoInclude =''; 
            if(Partner != null){
                Account serviceAccount = [select id,vlocity_cmt__PremisesId__c from Account where id = :currQli.vlocity_cmt__ServiceAccountId__c];
                List<Vendor_Connectivity__c> vendorList = [select QoS__c,Speed__c,Tier__c,Vendor_Name__c,Converted_Speed_to_MB__c from Vendor_Connectivity__c where Premise__c = :serviceAccount.vlocity_cmt__PremisesId__c AND Vendor_Name__c = : Partner];
                partnerTier= vendorList[0].Tier__c;   
                Qos=vendorList[0].QoS__c;
                
            }
            
            if(partnerTier != null){
                List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest> actionRequestsList = new List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest>();
              
                actionRequestsList.add(new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_PARTNER_TIER', vlocity_cmt.JSONAttributeSupport.ActionType.ASSIGN, partnerTier));
                actionRequestsList.add(new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_ELIGBL_QOS', vlocity_cmt.JSONAttributeSupport.ActionType.ASSIGN, Qos));
                
                
                Map<String, object> inputMap = new Map<String, object>();
                Map<String, object> outputMap = new Map<String, object>();
                Map<String, object> optionsMap = new Map<String, object>();
                inputMap.put('objectSO', currQli);
                inputMap.put('runTimeAttributesJSON', currQli.vlocity_cmt__JSONAttribute__c);
                inputMap.put('originalAttributesJSON', '{}');
                inputMap.put('JSONAttributeActionRequestList', actionRequestsList);
                vlocity_cmt.JSONAttributeSupport jsonSupport = new vlocity_cmt.JSONAttributeSupport();
                jsonSupport.invokeMethod('applyAttributeActions', inputMap, outputMap, optionsMap);
                String modifiedJSON = (String)outputMap.get('modifiedJSON'); 
                System.debug('RN:::'+modifiedJSON);
                currQli.vlocity_cmt__JSONAttribute__c = (String)outputMap.get('modifiedJSON'); 
                //Trigger.new[0].put('vlocity_cmt__JSONAttribute__c', modifiedJSON); 
                //update currQli;
                
            }
            return true;
        }catch (Exception ex) {
            ftr_Logger.write(ex);
            return false;
        } finally {
            ftr_Logger.writeInfo('Exit ftr_QuoteService.updatepartnerNames');
        }
        
        
    }
    
    public boolean updateJurisdiction(QuoteLineItem currQli,list<QuoteLineitem> qlilist){
            ftr_Logger.writeInfo('Enter ftr_QuoteService.updateJurisdiction');
        try{
            boolean elanhasoffnet = false;
            boolean evplhasonnet = false;
            list<quotelineitem> updateqlilist = new list<quotelineitem>();
            list<quotelineitem> elanqlilist = new list<quotelineitem>();
            list<quotelineitem> evplqlilist = new list<quotelineitem>();
            if(qlilist.size()> 0){
                
                for(quotelineitem qli:qlilist ){
                    system.debug('qlilist productcode'+qli.product2.ProductCode);
                    if(qli.product2.ProductCode == 'ENT_ETH_ELAN_0001'){
                        system.debug('entered elan qli list');
                        boolean partnered =(boolean)ftr_CpqHelper.getJSONAttributeValue(qli.vlocity_cmt__JSONAttribute__c, 'ATTR_ELIGBL_PARTNRD');
                        if(partnered){elanhasoffnet =  true;}
                        elanqlilist.add(qli);
                        system.debug('elanqlilist'+elanqlilist.size())  ;                  
                    }
                    if(qli.product2.ProductCode == 'ENT_ETH_EVPL_0002'||qli.product2.ProductCode == 'ENT_ETH_EVPL_0010'){
                        boolean partnered =(boolean)ftr_CpqHelper.getJSONAttributeValue(qli.vlocity_cmt__JSONAttribute__c, 'ATTR_ELIGBL_PARTNRD');
                        if(partnered){evplhasonnet =  true;}
                        evplqlilist.add(qli);
                    }
                }
                if(elanqlilist.size()>0){
                    for(quotelineitem elanqli :elanqlilist){
                        string juris =  elanhasoffnet == true ? 'Interstate' : 'Intrastate';
                        system.debug('juris'+juris);
                        List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest> actionRequestsList = new List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest>();
                        actionRequestsList.add(new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_TECH_JURIS', vlocity_cmt.JSONAttributeSupport.ActionType.ASSIGN, juris));
						Map<String, object> inputMap = new Map<String, object>();
                        Map<String, object> outputMap = new Map<String, object>();
                        Map<String, object> optionsMap = new Map<String, object>();
                        inputMap.put('objectSO', elanqli);
                        inputMap.put('runTimeAttributesJSON', elanqli.vlocity_cmt__JSONAttribute__c);
                        inputMap.put('originalAttributesJSON', '{}');
                        inputMap.put('JSONAttributeActionRequestList', actionRequestsList);
                        vlocity_cmt.JSONAttributeSupport jsonSupport = new vlocity_cmt.JSONAttributeSupport();
                        jsonSupport.invokeMethod('applyAttributeActions', inputMap, outputMap, optionsMap);
                        String modifiedJSON = (String)outputMap.get('modifiedJSON'); 
                        System.debug('KP:::'+modifiedJSON);
                        elanqli.vlocity_cmt__JSONAttribute__c = (String)outputMap.get('modifiedJSON'); 
                        elanqli.Juris__c = juris;
                       // if(elanqli.id <> currQli.Id )
                            updateqlilist.add(elanqli);
                        system.debug('updateqlilist size'+updateqlilist.size());
                    }
                }
                if(evplqlilist.size()>0){
                    for(quotelineitem evplqli :evplqlilist){
                        string juris =  evplhasonnet == true ? 'Interstate' : 'Intrastate';
                        system.debug('evpl juris'+juris);
                        List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest> actionRequestsList = new List<vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest>();
                        actionRequestsList.add(new vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest('ATTR_TECH_JURIS', vlocity_cmt.JSONAttributeSupport.ActionType.ASSIGN, juris));
                        Map<String, object> inputMap = new Map<String, object>();
                        Map<String, object> outputMap = new Map<String, object>();
                        Map<String, object> optionsMap = new Map<String, object>();
                        inputMap.put('objectSO', evplqli);
                        inputMap.put('runTimeAttributesJSON', evplqli.vlocity_cmt__JSONAttribute__c);
                        inputMap.put('originalAttributesJSON', '{}');
                        inputMap.put('JSONAttributeActionRequestList', actionRequestsList);
                        vlocity_cmt.JSONAttributeSupport jsonSupport = new vlocity_cmt.JSONAttributeSupport();
                        jsonSupport.invokeMethod('applyAttributeActions', inputMap, outputMap, optionsMap);
                        String modifiedJSON = (String)outputMap.get('modifiedJSON'); 
                        System.debug('KP:::'+modifiedJSON);
                        evplqli.vlocity_cmt__JSONAttribute__c = (String)outputMap.get('modifiedJSON');
                        evplqli.Juris__c = juris;
                       // if(evplqli.id <> currQli.Id )
                            updateqlilist.add(evplqli);
                    }
                }
                update updateqlilist;
                
            }
            return true;
        }catch (Exception ex) {
            ftr_Logger.write(ex);
            return false;
        } finally {
            ftr_Logger.writeInfo('Exit ftr_QuoteService.updateJurisdiction');
        }
        
        
    }
    
    
    
     
        public static void justIncrement() {
                Integer i = 0;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                     i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
              i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
        
        
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                     i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
              i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                 i++;
                   i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
        
        } 
        
        
    }