public with sharing class PricingFormulaDefinitionController {
    public String currentFormulaGroup { get; set; }
    public String formulaGroupLabel { get; set; }
    public String mrcFormulaName { get; set; }
    public String nrcFormulaName { get; set; }
    public String mrcFormula { get; set; }
    public String nrcFormula { get; set; }
   
    public String mrcErrors { get; set; }
    public String nrcErrors { get; set; }
    public String groupErrors { get; set; }
    
    public String pageMode { get; set; }
    public List<PricingVarDef> pricingVars { get; set; }
    public List<SelectOption> pricingFormulas { get; set; }
    
    public Decimal mrcTestValue { get; set; }
    public Decimal nrcTestValue { get; set; }
    
    public class PricingVarDef {
        public String name { get; set; }
        public String fieldName { get; set; }
        public String displayType { get; set; }

        public String textVal { get; set; }
        public Boolean boolVal { get; set; }
        public Decimal numericVal { get; set; }
        
        
        public String picklistRef;
        public List<SelectOption> picklistItems { get; set; }
        

        
        public PricingVarDef(Pricing_Formula_Var__c var) {
            name = var.Name; 
            fieldName = var.Field_API_Name__c;
            if (var.Picklist_Ref__c != null) {
                displayType = 'picklist';
                picklistItems = new List<SelectOption>();
        	} else if (var.Data_Type__c == 'Decimal' || var.Data_Type__c == 'Integer') {
                displayType = 'number';
                numericVal = 0;

            } else if (var.Data_Type__c == 'String') {
                displayType = 'text';
            } else if (var.Data_Type__c == 'Boolean') {
                displayType = 'checkbox';
                boolVal = false;
            }
            
            
        }
    } 
    
    public List<PricingVarDef> retrievePricingVars() {
        PricingVarDef[] vdefs = new List<PricingVarDef>();
        Map<String, PricingVarDef[]> pklVarMap = new Map<String, PricingVarDef[]>();
        for (Pricing_Formula_Var__c pv : Pricing_Formula_Var__c.getAll().values()) {
            PricingVarDef pVar = new PricingVarDef(pv);
            if (pv.Picklist_Ref__c != null && pv.Picklist_Ref__c.startsWith('VPL.')) {
                String pklCode = pv.Picklist_Ref__c.subString(4);
                PricingVarDef[] pvars = pklVarMap.get(pklCode.toLowerCase());
                if (pvars == null) {
                    pvars = new List<PricingVarDef>();
                    pklVarMap.put(pklCode.toLowerCase(), pvars);
                }
                pvars.add(pVar);
            } else if (pv.Picklist_Ref__c == 'State') {
                for (Pricing_Loading_Rate__c rate : Pricing_Loading_Rate__c.getAll().values()) {
                    pVar.picklistItems.add(new SelectOption(rate.Name, rate.Name));
                }
            } else if (pv.PickList_Ref__c == 'ProductCode') {
                pVar.picklistItems.addAll(new SelectOption[] {
                    new SelectOption(ftr_CpqService.ProductCode_EIA, 'EIA'),
                    new SelectOption(ftr_CpqService.ProductCode_EVPL, 'EVPL'),
                    new SelectOption(ftr_CpqService.ProductCode_EVPL_EVC, 'EVPL EVC')
                });
            }
            vdefs.add(pVar);
        }
        vlocity_cmt__PicklistValue__c[] pklValues = [SELECT Id, name, vlocity_cmt__Code__c, vlocity_cmt__Value__c, vlocity_cmt__Sequence__c,vlocity_cmt__PicklistId__r.vlocity_cmt__Code__c 
                                                     FROM vlocity_cmt__PicklistValue__c 
                                                     WHERE vlocity_cmt__PicklistId__r.vlocity_cmt__Code__c = :pklVarMap.keySet()
                                                     ORDER By vlocity_cmt__PicklistId__c, vlocity_cmt__Sequence__c];
        for (vlocity_cmt__PicklistValue__c pklVal : pklValues) {
            PricingVarDef[] pVars = pklVarMap.get(pklVal.vlocity_cmt__PicklistId__r.vlocity_cmt__Code__c.toLowerCase());
            for (PricingVarDef pVar : pVars)
                pVar.picklistItems.add(new SelectOption(pklVal.vlocity_cmt__Value__c, pklVal.name));
        }
        
        
        return vdefs;
    }
    
    public Boolean groupHasError { 
        get {
        	return String.isNotEmpty(groupErrors);
    	}
    }

    public String PricingVarKeyPrefix {
        get {
            return Pricing_Formula_Var__c.SObjectType.getDescribe().getKeyPrefix();
        }
    }    
    
    public String PricingMultiplierKeyPrefix {
        get {
            return Pricing_Multiplier__c.SObjectType.getDescribe().getKeyPrefix();
        }
    }   
    public String PricingLoadingRateKeyPrefix {
        get {
            return Pricing_Loading_Rate__c.SObjectType.getDescribe().getKeyPrefix();
        }
    }   

    public List<SelectOption> retrievePricingFormulas() {
        Map<String, Schema.SObjectField> fmap = Pricing_Formula_Definition__c.SObjectType.getDescribe().fields.getMap();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '------ Please Select ---------'));
        for (String fname : fMap.keySet()) {
            if (fname.startsWith('formula_') && !fname.endsWith('b__c')) {
                SObjectField field = fMap.get(fname);
                String name = fname.substring(0, fname.length() - 3);
                String label = field.getDescribe().getLabel();
            	options.add(new SelectOption(name, label));
            }
        }

        return options;   
    }
    
    /**
     * 
     */
    public PageReference clearABPCache() {
        Cache.OrgPartition orgPart;
        orgPart = Cache.Org.getPartition(PricingFormulaService.CACHE_PARTITION_ABP);

        orgPart.remove(PricingFormulaService.CACHE_KEY_FORMULAS);
        orgPart.remove(PricingFormulaService.CACHE_KEY_MATRIX);
        orgPart.remove(PricingFormulaService.CACHE_KEY_COS);
        return null;
    }

    @AuraEnabled
    public static void clearCache() {
        Cache.OrgPartition orgPart;
        orgPart = Cache.Org.getPartition(PricingFormulaService.CACHE_PARTITION_ABP);

        orgPart.remove(PricingFormulaService.CACHE_KEY_FORMULAS);
        orgPart.remove(PricingFormulaService.CACHE_KEY_MATRIX);
        orgPart.remove(PricingFormulaService.CACHE_KEY_COS);
    }

    public void init() {
        pricingVars = retrievePricingVars();
        pricingFormulas = retrievePricingFormulas();
    }
    
    /**
     * 
     */
    public PageReference selectFormula() {
        pageMode = 'Edit';
        
        mrcErrors = null;
        nrcErrors = null;
        groupErrors = null;
        
        mrcTestValue = nrcTestValue = null;
        
        Map<String, Schema.SObjectField> fmap = Pricing_Formula_Definition__c.SObjectType.getDescribe().fields.getMap();
        if (String.isEmpty(currentFormulaGroup)) {
            formulaGroupLabel = '';
            mrcFormula = '';
            nrcFormula = '';
            mrcFormulaName = nrcFormulaName = '';
        } else {
            String fn = currentFormulaGroup + '__c';
            try {            
                Map<String, String> mappings = PricingFormulaService.getFormulaVarMapping();

                SObjectField mrc = fmap.get(currentFormulaGroup + '__c');
                SObjectField nrc = fmap.get(currentFormulaGroup + 'b__c');
                formulaGroupLabel = mrc.getDescribe().getLabel();
                mrcFormulaName = mrc.getDescribe().getName();
                nrcFormulaName = nrc.getDescribe().getName();
        
                mrcFormula = decodeFormula(mrc.getDescribe().getCalculatedFormula(), mappings);
                nrcFormula = decodeFormula(nrc.getDescribe().getCalculatedFormula(), mappings);
            } catch (Exception ex) {
                groupErrors = 'Pricing Variable Mappings needs to be defined for the given pricing formula group.';
                //groupErrors = ex.getMessage();
            }
        }
        return null;
    }

    @AuraEnabled
    public static Map<String, Object> getCalculatedFormula(String formula){
        Map<String, Object> output = new Map<String, Object>();
        try {
            Map<String, String> mappings = PricingFormulaService.getFormulaVarMapping();
            Map<String, Schema.SObjectField> fmap = Pricing_Formula_Definition__c.SObjectType.getDescribe().fields.getMap();
            PricingFormulaDefinitionController ctrl = new PricingFormulaDefinitionController();
            String formulaValue = ctrl.decodeFormula(fmap.get(formula).getDescribe().getCalculatedFormula(), mappings);
            output.put('formulaValue', formulaValue);

            Map<String, Object> products = new Map<String, Object>();
            for (Pricing_Formula_Matrix__c matrix : [SELECT Product_Code__c FROM Pricing_Formula_Matrix__c WHERE Formula_Name__c =:formula]) {
                products.put(matrix.Product_Code__c, true);
            }
            for (Product2 product : [SELECT Name, ProductCode FROM Product2 WHERE ProductCode IN :products.keySet()]) {
                products.put(product.ProductCode, product.Name);
            }
            output.put('products', products);
            return output;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * 
     */
    public PageReference save() {
        System.debug('Jyue - 1');
        Map<String, String> mappings = PricingFormulaService.getFormulaVarMapping();
        
        String newMrcFormula = encodeFormula(mrcFormula, mappings);
        String newNrcFormula = encodeFormula(nrcFormula, mappings);

        System.debug('Jyue - 2');
        Map<String, Schema.SObjectField> fmap = Pricing_Formula_Definition__c.SObjectType.getDescribe().fields.getMap();
        
        MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
        SObjectField mrc = fmap.get(currentFormulaGroup + '__c');
        SObjectField nrc = fmap.get(currentFormulaGroup + 'b__c');
        
        
        metadataservice .SessionHeader = new MetadataService.SessionHeader_element();
        metadataservice .SessionHeader.sessionId = UserInfo.getSessionId();
        List<MetadataService.CustomField> fields = new List<MetadataService.CustomField> {
            new MetadataService.CustomField(),
            new MetadataService.CustomField()
        };
        fields[0].fullName = 'Pricing_Formula_Definition__c.' + mrc.getDescribe().getName();
        fields[0].label = formulaGroupLabel; // mrc.getDescribe().getLabel(); // mrcFormulaName;
        fields[0].formula = newMrcFormula;
        
        fields[1].fullName = 'Pricing_Formula_Definition__c.' + nrc.getDescribe().getName();
        fields[1].label = mrc.getDescribe().getLabel(); // nrcFormulaName;
        fields[1].formula = newNrcFormula;
        
        // System.debug(fields[0]);
        System.debug(newNrcFormula);
        for (MetadataService.CustomField f : fields) {
            f.type_x = 'Currency';
            f.scale = 2;
            f.precision = 18;
        }
        System.debug('Jyue - 3');

        MetadataService.SaveResult[] srList;


        
        if (Test.isRunningTest()) {
            srList = new List<MetadataService.SaveResult> {
                new MetadataService.SaveResult(),
                new MetadataService.SaveResult()
            };
            srList[0].success = true;
            srList[1].success = true;
        } else {
            srList = metadataservice.updateMetadata(fields);
        }

        System.debug(srList[1]);

        mrcErrors = getSaveErrors(srList[0], mappings);
        nrcErrors = getSaveErrors(srList[1], mappings);
        System.debug('Jyue - 4');
        for (SelectOption f : pricingFormulas) {
            if (f.getValue() == currentFormulaGroup) {
                f.setLabel(formulaGroupLabel);
            }
        }

        
        return null;
    }
    
    
    public PageReference test() {
        pageMode = 'Test';
        //pricingVars = retrievePricingVars();
        return null;
        
    }
    
    public PageReference close() {
        pageMode = 'Edit';
        return null;
        
    }

    public PageReference run() {
        for (PricingVarDef pvar : pricingVars) {
            System.debug(pvar);
        }
        
        Pricing_Formula_Definition__c fDef = new Pricing_Formula_Definition__c();
        for (PricingVarDef pvar : pricingVars) {
            Object value;
            if (pvar.name == 'Speed' || pvar.name == 'WCMaxSpeed') {
                value = ftr_CpqHelper.convertToSpeed(pvar.textVal);
            } else if (pvar.name == 'State' || pvar.name == 'ProductCode') {
                value = pvar.textVal;
            } else if (pvar.name == 'Term') {
                value = pvar.textVal == null ? null : Integer.valueOf(pvar.textVal.subString(0, 2).trim());
            } else if (pvar.displayType == 'checkbox') {
                value = pvar.boolVal;
            } else if (pvar.displayType == 'number') {
                value = pvar.numericVal;
            } else {
                value = pvar.textVal;
            }
            System.debug(pvar.name + ': ' + String.valueOf(value));

            fDef.put(pvar.fieldName, value);

        }
        
        List<FormulaRecalcResult> results = Formula.recalculateFormulas(new List<Pricing_Formula_Definition__c> { fDef });
        mrcTestValue = (Decimal)(fDef.get(currentFormulaGroup + '__c'));
        nrcTestValue = (Decimal)(fDef.get(currentFormulaGroup + 'b__c'));

        
        
        
        //System.debug(JSON.serialize(pricingVars));
        return null;
        
    }    
    /**
     * 
     */    
    String getSaveErrors(MetadataService.SaveResult sr, Map<String, String> mappings) {
        if (sr.success) return null;
        else {
            String message = sr.errors[0].message;
            for (String fName : mappings.keySet()) {
                message = message.replaceAll(fName, '\\$' + mappings.get(fName));
            }
            return message;
        }
    }
    
    /**
     * @description convert VarName to FieldName
     */
    String encodeFormula(String formula, Map<String, String> mappings) {
        for (String fName : mappings.keySet()) {
            formula = formula.replaceAll('(?i)\\$' + mappings.get(fName), fName); // Case insenitive replaceAll
        }
        
        return formula;
    }
    
    /**
     * @description convert VarName to FieldName
     */
    String decodeFormula(String formula, Map<String, String> mappings) {
        for (String fName : mappings.keySet()) {
            formula = formula.replaceAll('(?i)' + fName, '\\$' + mappings.get(fName)); // Case insenitive replaceAll
        }
        
        return formula;        
    }

    /**
     * 
     */
    @AuraEnabled
    public static List<Map<String, Object>> getConfigurablePricingAttributes(String productCode) {
        Product2 p = [SELECT Id, Name, ProductCode, vlocity_cmt__JSONAttribute__c FROM Product2 WHERE ProductCode=:productCode LIMIT 1];
        String jsonAttrib = p.vlocity_cmt__JSONAttribute__c;
        Map<String, Object> cateJsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonAttrib);
        Object[] pricingJsons = (Object[])cateJsonMap.get('FTR_ENT_PRI_ATTCAT');

        List<Map<String, Object>> pricingAttribs = new List<Map<String, Object>>();
        for (Object pricingJson : pricingJsons) {
            Map<String, Object> attr = (Map<String, Object>)pricingJson;
            if (Boolean.valueOf(attr.get('isactive__c')) == true && Boolean.valueOf(attr.get('ishidden__c')) == false /* && Boolean.valueOf(attr.get('isreadonly__c')) == false */) {
                Map<String, Object> pAttr = new Map<String, Object> {
                    'label' => (String)attr.get('attributedisplayname__c'),
                    'key' => productCode + (String)attr.get('attributeuniquecode__c'),
                    'code' => (String)attr.get('attributeuniquecode__c'),
                    'displayOrder' => Integer.valueOf(attr.get('attributedisplaysequence__c')),
                    'datatype' => (String)attr.get('valuedatatype__c'),
                    'value' => attr.get('value__c'),
                    'required' => attr.get('isrequired__c'),
                    'isPicklist' => false,
                    'readonly' => attr.get('isreadonly__c')
                };
                if ((String)pAttr.get('datatype') == 'Picklist') {
                    Object[] plValues = (Object[])((Map<String, Object>)attr.get('attributeRunTimeInfo')).get('values');
                    List<Map<String, Object>> options = new List<Map<String, Object>>();
                    for (Object plValue : plValues) {
                        Map<String, Object> val = (Map<String, Object>)plValue;
                        options.add(new Map<String, Object> {
                            'label' => (String)val.get('displayText'),
                            'value' => val.get('value')
                        });
                    }
                    pAttr.put('options', options);
                    pAttr.put('isPicklist', true);
                }
                pricingAttribs.add(pAttr);
            }
        }

        System.debug(JSON.serialize(pricingAttribs));
        return pricingAttribs;
    }

    /**
     * 
     */
    @AuraEnabled
    public static Map<String, Object> testPricingFormula(String formulaName, Id serviceAccountId, String productCode, String serviceTerm, Map<String, Object> pricingAttrVals) {
        Product2 p = [SELECT Id, Name, ProductCode, vlocity_cmt__JSONAttribute__c FROM Product2 WHERE ProductCode=:productCode LIMIT 1];
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = p.Id,
            Product2 = p
        );

        Account service = [SELECT Id, ParentId, Name, Parent.Name FROM Account WHERE Id=:serviceAccountId];
        // Account company = service.Parent;
        
        // Opportunity testOpp = new Opportunity(
        //     Id = '0060q00000IVmMFAA1',  // Fake Id
        //     AccountId = company.Id
        // );
        Quote testQuote = new Quote(
            Id = '0Q00q000000AZSMCA4',  // Fake Id
            // OpportunityId = testOpp.Id,
            Service_Term__c = serviceTerm
            // ,
            // Opportunity = testOpp
        );
        QuoteLineItem qLI = new QuoteLineItem(
            Id = '0QL0q000000ISkCGAW',  // Fake Id
            QuoteId = testQuote.Id,
            PriceBookEntryId = pbe.Id,
            vlocity_cmt__ServiceAccountId__c = service.Id,
            Quote = testQuote,
            vlocity_cmt__LineNumber__c = '0001',
            vlocity_cmt__ServiceAccountId__r = service,
            PriceBookEntry = pbe,
            vlocity_cmt__JSONAttribute__c = p.vlocity_cmt__JSONAttribute__c
        );

        System.debug('Jyue - test-: ' + JSON.serialize(pricingAttrVals));
        qLI.vlocity_cmt__JSONAttribute__c  = ftr_CpqHelper.setJSONAttributes(p.vlocity_cmt__JSONAttribute__c, '{}', pricingAttrVals);
        System.debug('Jyue - test-: ' + qLI.vlocity_cmt__JSONAttribute__c);
        
        // System.debug(ftr_CpqHelper.getJSONAttributeValue(qLI.vlocity_cmt__JSONAttribute__c, 'ATTR_IP_BLOCKS'));
        PricingFormulaService svs = new PricingFormulaService();
        Map<String, Object> input = new Map<String, Object> {
            'parent' => testQuote,
            'itemList' => new QuoteLineItem[] { qLI }
        };
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object> {
            'isFormulaTesting' => true
        };
        if (String.isNotEmpty(formulaName)) {
            options.put('formulaName', formulaName);
        }

        System.debug('calculatePrice.before');

        // vlocity_cmt.PricingPlanService.putInPricingContext('Parent', testQuote);
        // vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', new QuoteLineItem[] { qLI });

        svs.calculatePrice(input, output, options);
        System.debug('calculatePrice.after');

        Map<String, Object> retMap = new Map<String, Object>();
        if (qLI.get('vlocity_cmt__CpqMessageData__c') != null) {
            retMap.put('error', qLI.get('vlocity_cmt__CpqMessageData__c'));
            return retMap;
        }

        PricingFormulaDefinitionController ctrl = new PricingFormulaDefinitionController();
        Map<String, String> varDefMap = new Map<String, String>();
        for (PricingVarDef def : ctrl.retrievePricingVars()) {
            varDefMap.put(def.fieldName, def.name);
        }

        Map<String, Object> prices = (Map<String, Object>)((Map<String, Object>)output.get('pricingResults')).get(qLI.Id);
        if (prices == null) {
            retMap.put('error', 'No formulas found for the given configuration');
            return retMap;
        }
        Map<String, Object> priceVarMap;
        if (prices.get('pricingVars') != null)
            priceVarMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(prices.get('pricingVars')));
        System.debug('prices:'+JSON.serialize(prices));
        retMap.put('MRC', prices.get('mRC'));
        retMap.put('NRC', prices.get('nRC'));
        retMap.put('record', priceVarMap);
        List<Map<String, Object>> pricingVarVals = new List<Map<String, Object>>();
        retMap.put('pricingVars', pricingVarVals);
        for (String vname : priceVarMap.keySet()) {
            if (varDefMap.containsKey(vname)) {
                pricingVarVals.add(new Map<String, Object> {
                    'name' => varDefMap.get(vname),
                    'value' => priceVarMap.get(vname)
                });
            }
        }

        System.debug(JSON.serialize(retMap));



        return retMap;
                

    }
}