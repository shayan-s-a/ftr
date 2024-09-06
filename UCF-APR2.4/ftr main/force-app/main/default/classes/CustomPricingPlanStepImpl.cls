global with sharing class CustomPricingPlanStepImpl implements vlocity_cmt.VlocityOpenInterface {

    private static String nsp = 'vlocity_cmt__';

    global Boolean invokeMethod (String methodName,
                                 Map<String, Object> input,
                                 Map<String, Object> output,
                                 Map<String, Object> options)
    {
        try {
            system.debug('Enter CustomPricingPlanStepImpl.' + methodName);
            if (methodName == 'GetMatrixPrice')
            {
                getMatrixPrice(input, output, options);
            } else if (methodName =='GetFormulaPrice') {
                getFormulaPrice(input,output,options);
            }
            system.debug('Exit CustomPricingPlanStepImpl...' + methodName);
            return true;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex);
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            output.put('Error', ex.getMessage());
            return false;
        }
    }
    private void getFormulaPrice(Map<String, Object> input,
                                Map<String, Object> output,
                                Map<String, Object> options) 
    {
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        List<SObject> itemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');

        //If Asset or if there are no items, then return
        if(parent == null || itemList == null || itemList.isEmpty()) return;

        String sourceTargetABP = (String)input.get('SourceTargetABP');
        String strDelta = PricingPlanHelper.getCpqConfigurationSetupValue('DeltaPrice');

        //CMT-3332 : If Delta Price is TRUE and if source target attribute based pricing is being done, then load all the line items
        if(strDelta == 'True' && sourceTargetABP == 'True') {
            itemList = getAllLineItems(parent, parent.getSObjectType(), itemList[0].getSObjectType());
            vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList',itemList);
        }

        // If this is the first getMatrixPrice step, clear the external price flag
        Boolean clearExternalPriceFlag = (Boolean)vlocity_cmt.PricingPlanService.getFromPricingContext('ClearExternalPriceFlag');

        if (clearExternalPriceFlag == null) {
            clearExternalPriceFlag = true;
            // Do not clear the external price flag for subsequent calls to getMatrixPrice
            vlocity_cmt.PricingPlanService.putInPricingContext('ClearExternalPriceFlag', false);
        }
        
        PricingFormulaService pricingService = new PricingFormulaService();
        Map<String, object> priceHelperInput = new Map<String, object>();
        Map<String, object> priceHelperOutput = new Map<String, object>();
        Map<String, object> priceHelperOptions = new Map<String, object>();
        priceHelperInput.put('parent', parent);
        priceHelperInput.put('itemList', itemList);
        priceHelperInput.put('ClearExternalPriceFlag', clearExternalPriceFlag);
        priceHelperInput.putAll(input);

        pricingService.invokeMethod('CalculatePrice', priceHelperInput, priceHelperOutput, priceHelperOptions);

        if (priceHelperOutput.get('Error') != null) {
            output.put('Error', priceHelperOutput.get('Error'));
        }
    }

    private void getMatrixPrice(Map<String, Object> input,
                                Map<String, Object> output,
                                Map<String, Object> options)
    {
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        List<SObject> itemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        //If Asset or if there are no items, then return
        if(parent == null || itemList == null || itemList.isEmpty()) return;

        String sourceTargetABP = (String)input.get('SourceTargetABP');
        String strDelta = PricingPlanHelper.getCpqConfigurationSetupValue('DeltaPrice');

        //CMT-3332 : If Delta Price is TRUE and if source target attribute based pricing is being done, then load all the line items
        if(strDelta == 'True' && sourceTargetABP == 'True')
        {
            itemList = getAllLineItems(parent, parent.getSObjectType(), itemList[0].getSObjectType());
            vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList',itemList);
        }
        // If this is the first getMatrixPrice step, clear the external price flag
        Boolean clearExternalPriceFlag = (Boolean)vlocity_cmt.PricingPlanService.getFromPricingContext('ClearExternalPriceFlag');
        // System.debug('ClearExternalPriceFlag: ' + clearExternalPriceFlag);
        if (clearExternalPriceFlag == null)
        {
            clearExternalPriceFlag = true;
            // Do not clear the external price flag for subsequent calls to getMatrixPrice
            vlocity_cmt.PricingPlanService.putInPricingContext('ClearExternalPriceFlag', false);
        }

        Map<String, object> priceHelperInput = new Map<String, object>();
        Map<String, object> priceHelperOutput = new Map<String, object>();
        Map<String, object> priceHelperOptions = new Map<String, object>();
        priceHelperInput.put('Parent', parent);
        priceHelperInput.put('ItemList', itemList);
        priceHelperInput.put('ClearExternalPriceFlag', clearExternalPriceFlag);
        priceHelperInput.putAll(input);

        // create the matrix input rows from the itemList
        PricingPlanHelper priceHelper = new PricingPlanHelper();
                
        priceHelper.invokeMethod('GetCalculationProcedurePrice', priceHelperInput, priceHelperOutput, priceHelperOptions);
        
        if (priceHelperOutput.get('error') != null)
        {
            output.put('error', priceHelperOutput.get('error'));
        }
    }

    //Querying all the dat
    private List<SObject> getAllLineItems(SObject parent, SobjectType parentObjectTypeForPage, SObjectType lineItemTypeForPage)
    {
        Id parentId = (Id)parent.get('Id');
        String query = 'Select Id, '+nsp+'LineNumber__c, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.ProductCode, PriceBookEntry.Product2.Id,' +
                'PriceBookEntry.Product2.'+nsp+'Type__c, PriceBookEntryId, PriceBookEntry.Pricebook2Id, ListPrice, UnitPrice, Quantity,' +
                'PriceBookEntry.Product2.'+nsp+'JSONAttribute__c,'+nsp+'jsonattribute__c,'+nsp+'OneTimeCharge__c, ' +
                nsp+'JSONNode__c, '+nsp+'PricingLogData__c, '+nsp+'Query__c, ' +nsp+'Filter__c, '+nsp+'OneTimeCalculatedPrice__c,' +
                nsp+'OneTimeManualDiscount__c, '+nsp+'OneTimeTotal__c, '+nsp+'ProductHierarchyPath__c, '+nsp+'RecurringCharge__c,' +
                nsp+'RecurringCalculatedPrice__c, '+nsp+'RecurringManualDiscount__c, '+nsp+'RecurringDiscountPrice__c, '+nsp+'RecurringTotal__c,' +
                nsp+'RootItemId__c, '+nsp+'ParentItemId__c, '+nsp+'CpqMessageData__c, '+nsp+'CurrencyPaymentMode__c,' +
                nsp+'CpqCardinalityMessage__c, '+nsp+'ProvisioningStatus__c, '+nsp+'ServiceAccountId__r.Name, '+nsp+'ServiceAccountId__r.Id,' +
                nsp+'BillingAccountId__r.Name, '+nsp+'BillingAccountId__r.Id' +
                ' FROM ' + lineItemTypeForPage + ' WHERE ' + parentObjectTypeForPage + 'Id = \'' + parentId + '\'';
        return Database.query(query);
    }
}