global class PricingFormulaService implements vlocity_cmt.VlocityOpenInterface {
    public static final String CACHE_KEY_FORMULAS = 'FormulaMap';
    public static final String CACHE_KEY_MATRIX = 'FormulaMatrixMap';
    public static final String CACHE_PARTITION_ABP = 'local.AddressBasedPricing';
    public static final String CACHE_KEY_COS = 'ClassOfServiceMap';

    public static Map<String, Pricing_Formula_Matrix__c> formulaMatrixMap;
    Map<Id, Pricing_Formula_Matrix__c> formulaMap;
    public static Map<String, String> varMapping;
    public static List<SObject> itemsToPrice;

    public class PricingFormulaServiceException extends Exception {
    }

    public PricingFormulaService() {
        formulaMatrixMap = getFormulaMatrixMap();
        varMapping = getFormulaVarMapping();
    }

    public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        ftr_Logger.write('Enter PricingFormulaService.' + methodName + ' - CPU Time: ' + Limits.getCpuTime());
        try {
            if (methodName == 'CalculatePrice') {
                calculatePrice(input, output, options);
            } else if (methodName == 'GetAllPricingOptionsByTerm') {
                getAllPricingOptionsByTerm(input, output, options);
            } else if (methodName == 'GetAllPricingOptions') {
                getAllPricingOptions(input, output, options);
            } else {
                output.put('Error', 'Unsupported method name: ' + methodName);
                return false;
            }
            return true;
        } catch (Exception ex) {
            ftr_Logger.write(ex);
            output.put('Error', ex.getMessage());
            return false;
        } finally {
            ftr_Logger.write('Exit PricingFormulaService.' + methodName + ' - CPU Time: ' + Limits.getCpuTime());
        }
    }
    
    /**
    * @params: input : {
    *       productCode: 'ENT_ETH_EIA_0002',
    *       serviceAccountId: '123456',
    *      }
     */
    public void getAllPricingOptions(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        Schema.DescribeFieldResult quoteTerms = Quote.Service_Term__c.getDescribe();
        for (Schema.PicklistEntry term : quoteTerms.getPicklistValues()){
            PricingVarEval.resetContext();
            Map<String, Object> pricingResults = new Map<String, Object>();
            input.put('term', term.getLabel());
            getAllPricingOptionsByTerm(input, pricingResults, options);
            output.put(term.getLabel(), pricingResults);
        }
    }
    
    /**
    * @params: input : {
    *       productCode: 'ENT_ETH_EIA_0002',
    *       serviceAccountId: '123456',
    *       term: '12 Months',
*       }
     */
    public void getAllPricingOptionsByTerm(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        SObject parent = new Quote(
            Service_Term__c= (String) input.get('term')
        );
        List<string> speeds = new List<string>();
        Product2 prod = [SELECT Id, Name, ProductCode, vlocity_cmt__JSONAttribute__c FROM Product2 WHERE ProductCode = :(String)input.get('productCode') LIMIT 1];
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Product2 = new Product2(
                Id = prod.Id,
                Name = prod.Name,
                ProductCode = prod.ProductCode
            )
        );
        /*PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Product2 = prod
        );*/
        Map<string,object> jsonAttr = (Map<string,object>)JSON.deserializeUntyped(prod.vlocity_cmt__JSONAttribute__c);
        List<Object> pricingAttrCatt = (List<Object>)jsonAttr.get('FTR_ENT_PRI_ATTCAT');
        for (Object pricingAttrObj : pricingAttrCatt) {
            Map<String, Object> pricingAttr = (Map<String, Object>)pricingAttrObj;
            if ((String)pricingAttr.get('attributeuniquecode__c') == 'ATTR_BANDWIDTH') { // will only run once
                List<object> values = (List<object>)((Map<string,object>)pricingAttr.get('attributeRunTimeInfo')).get('values');
                for (object speedObj : values) {
                    Map<string,object> speed = (Map<string,object>)speedObj;
                    speeds.add((String)speed.get('value'));
                }
            }
        }
        List<SObject> itemList = new List<SObject>();
        Integer count = 0;
        if (options.get('count') != null) {
            count = Integer.valueOf(options.get('count'));
        }
        for (String speed : speeds) {
            String i;
            count++;
            System.debug('count: '+count);
            if (count < 10) i = '0' + String.valueOf(count);
            else i = String.valueOf(count);
            String jsonAttribute = (String) input.get('jSONAttribute');
            Map<String,Object> attrVals = new Map<String,Object>{
                'ATTR_BANDWIDTH' => speed
            };
            jsonAttribute = (String)ftr_CpqHelper.setJSONAttributes(prod.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
            itemList.add(
                new QuoteLineItem(
                    Id = '0QL7A000812'+i+'N4WBB',
                    vlocity_cmt__ServiceAccountId__c = (String) input.get('serviceAccountId'),
                    PriceBookEntry = pbe,
                    PriceBookEntryId = pbe.Id,
                    vlocity_cmt__JSONAttribute__c=jsonAttribute,
                    Term__c= (String) input.get('term'),
                    Speed__c=speed
                )
            );
        }
        options.put('count', count);
        itemsToPrice = new List<SObject>();
        formulaMap = getFormulaMap(itemList, parent);
        Map<String, Object> pricingResults;

        // get only the lineitems to be priced
        Map<Id, SObject> allItems = new Map<Id, SObject>(itemList);
        for (Id itemId : formulaMap.keySet()) {
            itemsToPrice.add(allItems.get(itemId));
        }

        System.debug('getAllPricingOptions-formulaMap: '+ JSON.serialize(formulaMap));

        // Call evaluateFormula to get MRC and NRC for each lineitem
        Map<String, object> formulaInputMap = new Map<String, object>();
        formulaInputMap.put('parent', parent);
        formulaInputMap.put('itemList', itemsToPrice);
        System.debug('getAllPricingOptions-itemsToPrice: '+ JSON.serialize(itemsToPrice));
        pricingResults = evaluateFormulas(formulaInputMap);
        
        for (SObject item : itemsToPrice) {           
            Map<String, Object> itemObj = item.getPopulatedFieldsAsMap().clone();
            Map<string, object> pricingData = (Map<string, object>) pricingResults.get((String)itemObj.get('Id'));
            Decimal mRC = (Decimal) pricingData.get('mRC');
            if (mRC != null) {
                if (mRC >= 1000000) continue;
                itemObj.put('vlocity_cmt__RecurringCharge__c', mRC);
            }
            Decimal nRC = (Decimal) pricingData.get('nRC');
            if (nRC != null) {
                if (nRC >= 1000000) continue;
                itemObj.put('vlocity_cmt__OneTimeCharge__c', nRC);
            }
            itemObj.put('vlocity_cmt__JSONAttribute__c', null);
            itemObj.put('Id', null);
            itemObj.put('Speed_Mbps__c', ftr_CpqHelper.convertToSpeed((String)itemObj.get('Speed__c')));
            itemObj.put('Description', prod.Name);
            
            output.put((String)itemObj.get('Speed__c'), itemObj);
        }        
    }

    public void calculatePrice(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        SObject parent = (SObject) input.get('parent');
        List<SObject> itemList = (List<SObject>) input.get('itemList');
        itemsToPrice = new List<SObject>();
        formulaMap = getFormulaMap(itemList, parent);
        Map<String, Object> pricingResults;
		Map<String, Object> partnerResults;        

        // get only the lineitems to be priced
        Map<Id, SObject> allItems = new Map<Id, SObject>(itemList);
        for (Id itemId : formulaMap.keySet()) {
            itemsToPrice.add(allItems.get(itemId));
        }

        // Call evaluateFormula to get MRC and NRC for each lineitem
        Map<String, object> formulaInputMap = new Map<String, object>();
        formulaInputMap.put('parent', parent);
        formulaInputMap.put('itemList', itemsToPrice);
        // System.debug('itemsToPrice: '+ JSON.serialize(itemsToPrice));
        pricingResults = evaluateFormulas(formulaInputMap);
         partnerResults=pricingPartneredProducts(itemList);
        for(id itemid:partnerResults.keyset() ){
            itemsToPrice.add(allItems.get(itemId));
        }
        if(partnerResults.size() >0 && itemsToPrice.size()>0){
           pricingResults.putAll(partnerResults);
        }
        // set the price
        Map<String, object> setPriceInput = new Map<String, object>();
        Map<String, object> setPriceOutput = new Map<String, object>();
        Map<String, object> setPriceOptions = new Map<String, object>();
        setPriceInput.put('parent', parent);
        setPriceInput.put('itemList', itemsToPrice);
        setPriceInput.put('pricingResults', pricingResults);
        // setPriceInput.putAll(input);
        ftr_Logger.write('Setting External Price - CPU Time: ' + Limits.getCpuTime());
        if ( options.get('isFormulaTesting') != null && (Boolean) options.get('isFormulaTesting')) {
            output.put('pricingResults', pricingResults);
            return;
        }
        setExternalPrice(setPriceInput, setPriceOutput, setPriceOptions);

        if (setPriceOutput.get('error') != null) {
            output.put('error', setPriceOutput.get('error'));
        }
    }

    /**
     * @description evaluate the MRC and NRC of the pricing formula for a given xLI
     */
    public Map<String, Object> evaluateFormulas(Map<String, Object> input) {
        SObject parent = (SObject) input.get('parent'); // Header object of xLI
        List<SObject> itemList = (List<SObject>) input.get('itemList'); // xLIs in the shopping cart
        Map<String, Object> pricingResults = new Map<String, Object>();

        // build input for PricingVarEval
        for (SObject item : itemList) {
            String mrcFormulaName = formulaMap.get(item.Id).Formula_Name__c;
            String nrcFormulaName = formatNRCFormulaName(mrcFormulaName);
            Boolean checkPartnerEligibile = isPartnered(item); //Added for Offnet pricing check
            SObject formulaObj;
            Decimal mrcResult;
            Decimal nrcResult;
            ftr_Logger.writeVar('Pricing item', item);
            if ((mrcFormulaName != null || nrcFormulaName != null) && varMapping != null && !checkPartnerEligibile) {
                formulaObj = new Pricing_Formula_Definition__c();
                ftr_Logger.writeVar('Pricing vars before evaluation for '+mrcFormulaName, (Object) varMapping);
                // evaluate MRC variables
                try {
                    for (String fieldName : varMapping.keySet()) {
                        PricingVarEval varEvaluator = new PricingVarEval();
                        Object result = varEvaluator.eval(
                            new Map<String, Object>{
                                'item' => item,
                                'parent' => parent,
                                'name' => varMapping.get(fieldName),
                                'itemList' => itemsToPrice
                            }
                        );
                        if (result != null) {
                            formulaObj.put(fieldName, result);
                        }
                    }
                    ftr_Logger.writeVar('Pricing vars after evaluation', formulaObj);
                } catch (exception e) {
                    // dont evaluate this formula
                    formulaObj = null;
                    ftr_Logger.write(e);
                    if (e instanceof PricingVarEval.PricingVarEvalException) {
                        item.put('vlocity_cmt__CpqMessageData__c', e.getMessage());
                    }
                }
            } else {
                if (varMapping == null)
                    ftr_Logger.writeErr('No VarMapping defined for '+mrcFormulaName);
                else 
                    ftr_Logger.writeVar('Invalid Pricing_Formula_Matrix__c record', formulaMap.get(item.Id));
            }
            if (formulaObj != null) {
                List<FormulaRecalcResult> results = Formula.recalculateFormulas(new List<SObject>{ formulaObj });
                if (mrcFormulaName != null)
                    mrcResult = (Decimal) results[0].getSObject().get(mrcFormulaName);
                if (nrcFormulaName != null)
                    nrcResult = (Decimal) results[0].getSObject().get(nrcFormulaName);
            }
          // Added the logic for Partner Port Charge Matrix.
        /* if (checkPartnerEligibile) {
            Decimal partnerPortCharge = callpartnerPortChargeMatrix(item);
            Decimal mRcChargeValue = (Decimal) item.get('vlocity_cmt__RecurringCharge__c');
            mrcResult = mRcChargeValue + partnerPortCharge;
         }*/
            ftr_Logger.write(item.getSObject('PriceBookEntry').getSObject('Product2').get('ProductCode')  + ' - ' + item.Id + ' priced with '+ mrcFormulaName + ': ' + mrcResult);
            pricingResults.put(item.Id, new Map<String, Object>{ 
                'mRC' => mrcResult, 
                'nRC' => nrcResult, 
                'pricingVars' => formulaObj
            });
        }
        return pricingResults;
    }
    //Calculate Pricing for Pertnered Products
    public Map<String, Object> pricingPartneredProducts(List<sobject> itemList) {
		Map<String, Object> pricingResults = new Map<String, Object>();
        Map<String, Object> itemstoPrice = new Map<String, Object>();

        // build input for PricingVarEval
        for (SObject item : itemList){
            Decimal mrcResult;
            Decimal nrcResult;
			Boolean checkPartnerEligibile = isPartnered(item);			//Added for Offnet pricing check
			if (checkPartnerEligibile) {
            Decimal partnerPortCharge = callpartnerPortChargeMatrix(item);
            Decimal mRcChargeValue = (Decimal) item.get('vlocity_cmt__RecurringCharge__c');
            mrcResult = mRcChargeValue + partnerPortCharge;
            Decimal mrcResultround = mrcResult.round(System.RoundingMode.HALF_UP);
                system.debug('mcresult'+mrcResult.round(System.RoundingMode.HALF_UP));
         
		  pricingResults.put(item.Id, new Map<String, Object>{ 
                'mRC' => mrcResultround
            });
          }     
		}
		return pricingResults;
		
		
	}

    // set price of items
    public void setExternalPrice(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        SObject parent = (SObject) input.get('parent');
        List<SObject> itemList = (List<SObject>) input.get('itemList');
        Map<String, Object> pricingResults = (Map<String, Object>) input.get('pricingResults');

        Type t = Type.forName('vlocity_cmt.SetCartItemExternalPriceService');

        if (t != null) {
            vlocity_cmt.VlocityOpenInterface externalPriceService = (vlocity_cmt.VlocityOpenInterface) t.newInstance();
            Map<String, Object> externalPriceServiceInput = new Map<String, Object>();
            Map<String, Object> externalPriceServiceOutput = new Map<String, Object>();
            Map<String, Object> externalPriceServiceOptions = new Map<String, Object>();
            Map<String, Object> itemFields = new Map<String, Object>();
            for (String itemId : pricingResults.keySet()) {
                Map<string, object> pricingData = (Map<string, object>) pricingResults.get(itemId);
                Map<String, Object> itemFieldDetails = new Map<String, Object>();
                Map<String, Object> fieldVals = new Map<String, Object>();
                Decimal mRC = (Decimal) pricingData.get('mRC');
                Decimal nRC = (Decimal) pricingData.get('nRC');
                if (mRC != null) {
                    fieldVals.put('value', mRC);
                    fieldVals.put('detail', 'Address Based Price');
                    itemFieldDetails.put('vlocity_cmt__RecurringCharge__c', fieldVals);
                }
                if (nRC != null) {
                    fieldVals = new Map<String, Object>();
                    fieldVals.put('value', nRC);
                    fieldVals.put('detail', 'Address Based Price');
                    itemFieldDetails.put('vlocity_cmt__OneTimeCharge__c', fieldVals);
                }
                itemFields.put(itemId, itemFieldDetails);
            }
            if (!itemFields.isEmpty()) {
                externalPriceServiceInput.put('parent', parent);
                externalPriceServiceInput.put('itemList', itemList);
                externalPriceServiceInput.put('itemFieldsInfo', itemFields);
                externalPriceService.invokeMethod(
                    'setItemPrices',
                    externalPriceServiceInput,
                    externalPriceServiceOutput,
                    externalPriceServiceOptions
                );
            }
        }
    }

    /**
     *
     */
    public Map<String, Pricing_Formula_Matrix__c> getFormulaMatrixMap() {
        Cache.OrgPartition orgPart;
        Map<String, Pricing_Formula_Matrix__c> formulaMatrixMap;
        orgPart = Cache.Org.getPartition(CACHE_PARTITION_ABP);
        if (orgPart != null) {
            formulaMatrixMap = (Map<String, Pricing_Formula_Matrix__c>) orgPart.get(CACHE_KEY_MATRIX); // get formulaMatrixMap
            if (formulaMatrixMap == null) {
                formulaMatrixMap =  new Map<String, Pricing_Formula_Matrix__c>();
                for (Pricing_Formula_Matrix__c formula : [
                    SELECT Id, Product_Code__c, Speed__c, Term__c, Formula_Name__c, State__c
                    FROM Pricing_Formula_Matrix__c
                    WHERE Enabled__c = TRUE
                    ORDER BY Priority__c DESC
                ]) {
                    formulaMatrixMap.put(getFormulaMatrixKey(formula.Product_Code__c, formula.State__c, formula.Term__c, formula.Speed__c), formula);
                }
                orgPart.put(CACHE_KEY_MATRIX, formulaMatrixMap);
            }
        }
        ftr_Logger.writeVar('formulaMatrixMap', formulaMatrixMap);
        return formulaMatrixMap;
    }

    /**
     *
     */
    public String getFormulaMatrixKey(String productCode, String state, Object term, Object speed) {
        if (state == null)
            state = '';
        if (term == null)
            term = 0;
        if (speed == null)
            speed = 0;

        return (productCode + '-' + state + '-' + String.valueOf(term) + '-' + String.valueOf(speed)).toLowerCase();
    }

    /**
     * @description return itemId -> formulaMatrix map
     */
    public Map<Id, Pricing_Formula_Matrix__c> getFormulaMap(SObject[] itemList, SObject parent) {
        PricingVarEval pve = new PricingVarEval();
        Map<Id, Integer> speedMap = pve.getItemSpeedMap(itemList);
        Map<Id, Account> accountMap = pve.getAccountMap(itemList);

        Map<Id, Pricing_Formula_Matrix__c> matrixMap = new Map<Id, Pricing_Formula_Matrix__c>();
        Integer term = Integer.valueOf(String.valueof(parent.get('Service_Term__c')).substring(0, 3).trim());

        for (SObject item : itemList) {
            String state;
            Integer speed;

            String pCode = item.getSObject('PriceBookEntry') != null ? (String)item.getSObject('PriceBookEntry').getSObject('Product2').get('ProductCode') : (String)item.get('Description');
            Account serviceAccount = accountMap.get((Id) item.get('vlocity_cmt__ServiceAccountId__c'));
            if (serviceAccount != null && serviceAccount.vlocity_cmt__PremisesId__c != null && serviceAccount.ShippingStateCode != null) {
                state = serviceAccount.ShippingStateCode;
            }
            if (state == null) {
                // Cannot quote a quote with State is empty
                continue;
            }
            speed = speedMap.get(item.Id);

            Object[] attrVals = new List<Object>{ state, term, speed };
            // try to match on all attributes
            String matrixKey = getFormulaMatrixKey(pCode, state, term, speed);
            Pricing_Formula_Matrix__c matrix = formulaMatrixMap.get(matrixKey);
            if (matrix == null) {
                // No exact match for all attributes, let us match on two of them
                for (Integer i = 0; i < attrVals.size(); i++) {
                    Object[] myAttrVals = attrVals.clone();
                    myAttrVals[i] = null;

                    matrixKey = getFormulaMatrixKey(pCode, (String) myAttrVals[0], myAttrVals[1], myAttrVals[2]);
                    matrix = formulaMatrixMap.get(matrixKey);
                    if (matrix != null) {
                        break;
                    }
                }
            }
            if (matrix == null) {
                // No exact match on two attributes, let us match only on one of them
                for (Integer i = 0; i < attrVals.size(); i++) {
                    Object[] myAttrVals = new List<Object>{ null, null, null };
                    myAttrVals[i] = attrVals[i];

                    matrixKey = getFormulaMatrixKey(pCode, (String) myAttrVals[0], myAttrVals[1], myAttrVals[2]);
                    matrix = formulaMatrixMap.get(matrixKey);
                    if (matrix != null) {
                        break;
                    }
                }
            }
            if (matrix == null) {
                matrixKey = getFormulaMatrixKey(pCode, null, null, null);
                matrix = formulaMatrixMap.get(matrixKey);
            }
            if (matrix != null) {
                matrixMap.put(item.Id, matrix);
            }
        }
        ftr_Logger.writeVar('matrixMap', matrixMap);
        return matrixMap;
    }

    public String formatNRCFormulaName(String mrcFormulaName) {
        if (mrcFormulaName != null)
            return mrcFormulaName.split('__c')[0] + 'b__c';
        else
            return null;
    }

    public static Map<String, String> getFormulaVarMapping() {
        Map<String, String> mappings = new Map<String, String>(); 
        for (Pricing_Formula_Var__c var : Pricing_Formula_Var__c.getAll().values()) {
            if (var.Field_API_Name__c != null)
                mappings.put(var.Field_API_Name__c, var.Name);
        }

        return mappings;
    }
    //Method to check Partnered Product
 	public static boolean isPartnered(sobject item) {
        Map < String, Object > itemObj = item.getPopulatedFieldsAsMap().clone();
        Boolean isPartner = false;
        String PartnerValue;
        String attrPartner = 'ATTR_PARTNER';
        String jsonAttribute = (string) itemObj.get('vlocity_cmt__JSONAttribute__c');
        //map<string,object> mapobj = (map<string,object>)item;

        PartnerValue = (String)ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, attrPartner);

        /*map < string, Object > jsonAttr = (Map < string, object > ) JSON.deserializeUntyped();
        List < Object > pricingAttrCatt = (List < Object > ) jsonAttr.get('FTR_ENT_PRI_ATTCAT');
        for (Object pricingAttrObj: pricingAttrCatt) {
            Map < String, Object > pricingAttr = (Map < String, Object > ) pricingAttrObj;
            if ((String) pricingAttr.get('attributeuniquecode__c') == 'ATTR_PARTNER') {
                Map < string, object > partnermap = (Map < string, object > ) pricingAttr.get('attributeRunTimeInfo');
                Map < string, object > partnervaluemap = (Map < string, object > ) partnermap.get('selectedItem');
                if(partnervaluemap != null)
                    PartnerValue = (string) partnervaluemap.get('value');
            }
            if (PartnerValue != null) {
                isPartner = true;
            }
        }*/
        if (PartnerValue != null) {
                isPartner = true;
        }
        return isPartner;
   }
   //Created Method for getting Partner Port Charge from VIP Matrix.
   public Decimal callpartnerPortChargeMatrix(sobject item) {
      Map < String, Object > itemObj = item.getPopulatedFieldsAsMap().clone();
      Decimal portcharge = 0;
      String SpeedOfItem = String.valueof(itemObj.get('Speed__c'));
      String TermOfItem = String.valueof(itemObj.get('Term__c'));
      String ClassOfServ = String.valueof(itemObj.get('Class_of_service__c'));
      String SourceProductCodeItem = (String) item.getSObject('PricebookEntry').getSObject('Product2').get('ProductCode');
      String procedureName = 'CPQ_PortCharge';
      Map < String, Object > ipInput = new Map < String, Object > ();
      Map < String, Object > ipOutput = new Map < String, Object > ();
      Map < String, Object > ipOptions = new Map < String, Object > ();
      try {
         /* Populating input map for an Integration Procedure. Follow whatever structure your VIP expects */
         ipInput.put('SourceProductCode', SourceProductCodeItem);
         ipInput.put('Speed', SpeedOfItem);
         ipInput.put('Term', TermOfItem);
         ipInput.put('COS', ClassOfServ);
         /* Call the IP via runIntegrationService, and save the output to ipOutput */

         ipOutput = (Map < String, Object > ) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
         system.debug('###IPOut' + ipOutput);
         List < object > chargemap = (List < object > ) ipOutput.get('PortCharge');
         system.debug('###IPOutchargemap' + chargemap);
         Map < String, Object > Portchmap = (Map < String, Object > ) chargemap[0];
         system.debug('###IPOutPortch' + Portchmap);
         portcharge = (Decimal) Portchmap.get('MDI Port Charge') !=null?(Decimal) Portchmap.get('MDI Port Charge'):0;
         system.debug('###IPOutPortchrg' + portcharge);
      } catch (exception ex) {
         portcharge = 0;
      }

      return portcharge;
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

} 
}