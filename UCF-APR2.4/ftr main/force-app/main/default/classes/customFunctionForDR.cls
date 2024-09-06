/**
* @author Sean Fife
* @date 2 Nov 2019
* @group Vlocity Component Implementations
* @description Custom functions unavailable to Vlocity Components
*/ 
global class customFunctionForDR implements vlocity_cmt.VlocityOpenInterface2{
    Public Boolean valueInArray;
    Public Map<string, object> productResult;
    public List<object> inversionResult;
    Public String LabelName;
    Public String zipCode;
    public string OpprtunityName ='';
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options)
    {
        if(methodName == 'invertArray')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            if(!arguments.isEmpty()){
                inversionResult = invertArray(arguments);
            }
            output.put('result', inversionResult);
        }
        else if(methodName == 'getBooleanValueFromArray')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            if(!arguments.isEmpty()){
                productResult = getBooleanValueFromArray(arguments);
            }
            output.put('result', productResult);
        }
        else if(methodName == 'getLabelName')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            if(!arguments.isEmpty()){
                labelName = getLabelName(arguments);
            }
            output.put('result', labelName );
        }
        else if(methodName == 'formatZipCode')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            if(!arguments.isEmpty()){
                zipCode = formatZipCode(arguments);
            }
            output.put('result', zipCode );
        }
        else if(methodName == 'replaceString')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            String str;
            if(!arguments.isEmpty()){
                str = replaceString(arguments);
            }
            output.put('result', str );
        }
        else if(methodName == 'getAllPickListValue')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            if(!arguments.isEmpty()){
                List<Object> pickListValueList= getAllPickListValue(arguments);
                //system.debug('pickListValueList----'+ pickListValueList);
                output.put('result', pickListValueList);
            }
        }
        else if (methodName == 'GetJSONAttributeMap') {
            GetJSONAttributeMap(inputs,output,options);
            return true;
        } else if(methodName == 'GetJSONMapKeys'){
            output.put('result', GetJSONMapKeys((List<Object>)inputs.get('arguments')));
            return true;
        } else if (methodName == 'getAttrVal') {
            getAttrVal(inputs,output);
            return true;
        } else if (methodName == 'getNextUNI') {
            getNextUNI(inputs,output);
            return true;
        }else if (methodName == 'getRelatedOrder') {
            getRelatedOrder(inputs,output);
            return true;
        }else if (methodName == 'isQuoteHasUCFEquipment') {
            isQuoteHasUCFEquipment(inputs,output);
            return true;
        }else if (methodName == 'getAccessType') {
            getAccessType(inputs,output);
            return true;
        }
        else if (methodName == 'getCustomerOrderItemBySNE') {
            System.debug('yes, entered method getCustomerOrderItemBySNE');
            getCustomerOrderItemBySNE(inputs,output);
            return true;
        }
        else if (methodName == 'getCommercialContractItemBySNE') {
            System.debug('yes, entered method getCommercialContractItemBySNE');
            getCommercialContractItemBySNE(inputs,output);
            return true;
        }
        else if(methodName == 'setOpportunityName')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            String str;
            if(!arguments.isEmpty()){
                str = setOpportunityName(arguments);
            }
            output.put('result', str );
        }
        else if(methodName == 'getContactPhone'){
            System.debug('yes, entered method getCommercialContractItemBySNE');
            getContactPhone(inputs,output);
            return true;
        }
        else if(methodName == 'getnpanxxval'){
            getnpanxxval(inputs,output);
            return true;
        }
        else if(methodName == 'getenvironval'){
            getenvironval(inputs,output);
            return true;
        }
        return true;
    }
    /* 
* For the given Quoute Id fetches all the associated Orders and concatenates
*/
    Public Boolean getRelatedOrder(Map<String,Object> inputs,Map<String,Object> output)
    {
        String relatedOrders ='';
        List<Object> args = (List<Object>)inputs.get('arguments');
        
        String quoteId = (String)args[0];               
        
        if(quoteId !=null){
            List<String> lstOrder = new List<String>();
            for(Order ord: [SELECT OrderNumber from Order where vlocity_cmt__QuoteId__c =: quoteId
                            AND RecordTypeId NOT IN (SELECT Id FROM RecordType WHERE DeveloperName='UCaaS_New_Order' AND SObjectType='Order') ]){
                                lstOrder.add(ord.OrderNumber);
                            }
            relatedOrders= string.join(lstOrder,';');          
        }
        output.put('result', relatedOrders);
        return true;
    }
    /* 
* For the given Quoute Id checks the QuouteLineItem whether UCF Equipment exists or not ?
*/
    
    Public Boolean isQuoteHasUCFEquipment(Map<String,Object> inputs,Map<String,Object> output)
    {
        List<Object> args = (List<Object>)inputs.get('arguments');
        String quoteId = (String)args[0];         
        output.put('result', ftr_QuoteService.isQuoteHasUCFEquipment(quoteId));
        return true;
    }
    
    Public List<Object> invertArray(List<Object> arguments)
    {
        List<Object> result = new List<Object>();
        //Map<String, Object> result = new Map<String, Object>();
        
        string fieldName = 'ServiceAccountId';
        
        List<object> firstArray = new List<object>();
        List<object> secondArray = new List<object>();
        
        integer i = 0;
        for(;i<arguments.size(); i++)
        {
            if(arguments[i] instanceof String)
            {
                if(arguments[i].toString() == '###')
                {
                    i++;
                    break;
                }
            }
            
            firstArray.add(arguments[i]);
        }
        for(;i<arguments.size(); i++)
        {
            secondArray.add(arguments[i]);
        }
        
        i = 0;
        for(object sa : firstArray)
        {
            Map<string, object> parentItem = (Map<string, object>)sa;
            
            Map<string, object> outputVar = new Map<string, object>();
            
            outputVar.put('Premise_Detail__c', parentItem.get('Premise_Detail__c').toString());
            outputVar.put('Line', new List<object>());
            
            //result.put(string.valueOf(i), new List<object>());
            //result.put(parentItem.get('Premise_Detail__c').toString(), new List<object>());
            for(object line : secondArray)
            {
                Map<string, object> childItem = (Map<string, object>)line;
                
                //system.debug(parentItem.get('Id'));
                //system.debug(childItem.get('vlocity_cmt__ServiceAccountId__c'));
                
                if(parentItem.get('Id').toString() == childItem.get('vlocity_cmt__ServiceAccountId__c').toString())
                {
                    //system.debug('match found');
                    ((List<object>)outputVar.get('Line')).add(childItem);
                }
            }
            result.add(outputVar);
        }
        return result;
    }
    
    Public Map<String, Object> getBooleanValueFromArray(List<Object> arguments)
    {
        Map<String, Object> result = new Map<String, Object>();
        
        //Assumes the product name is of the format
        //  "<Acronym> (<Full Name>)"
        for(integer i = 0; i<arguments.size() - 1; i++)
        {
            Map<String, Object> item = (Map<String, Object>)arguments[i];
            
            string name = item.get('Name').toString();
            
            if(name.contains(' ') == true)
            {
                string acronym = name.split(' ')[0];
                
                result.put('ProductName_is' + acronym, true);
            }
            else
            {
                result.put('ProductName_is' + name, true);               
            }
        }
        
        return result;
    }
    
    Public String getLabelName(List<Object> arguments)
    {
        Map<String, Object> result = new Map<String, Object>();
        String labelName;
        String sobjectname = string.valueOf(arguments[0]); //object api name
        String fieldapiName = string.valueOf(arguments[1]); //Field api name
        String label = string.valueOf(arguments[2]);
        List<Schema.PicklistEntry> ple = Schema.getGlobalDescribe().get(sobjectname).getDescribe().fields.getMap().get(fieldApiName).getDescribe().getPicklistValues();
        //System.debug('Picklist::'+ple);
        for( Schema.PicklistEntry f : ple){
            if(f.getValue() == label ){
                labelName = f.getLabel();
            }
        }
        return labelName ;
    }
    
    Public String formatZipCode(List<Object> arguments)
    {
        String zip = string.valueOf(arguments[0]).replaceAll('[^0-9]', '');
        return (zip.length() > 5) ? zip.substring(0, 5) + '-' + zip.substring(5) : zip ;
    }
    
    Public List<Object> getAllPickListValue(List<Object> arguments)
    {
        Map<String, Object> result = new Map<String, Object>();
        List<Object> pickListValueList= new List<Object>();
        String sobjectname = string.valueOf(arguments[0]); //object api name
        String fieldapiName = string.valueOf(arguments[1]); //Field api name
        List<Schema.PicklistEntry> ple = Schema.getGlobalDescribe().get(sobjectname).getDescribe().fields.getMap().get(fieldApiName).getDescribe().getPicklistValues();
        //System.debug('Picklist::'+ple);
        //List<Object> objList = new List<Object>();
        for( Schema.PicklistEntry f : ple){
            Map<String,Object> mapObj = new Map<String,Object>();
            mapObj.put('ApiName',f.getValue());
            mapObj.put('LabelName',f.getLabel());
            pickListValueList.add(mapObj);
            //system.debug('mapObj--' + mapObj);
        }
        //system.debug('pickListValueList--' + pickListValueList);
        return pickListValueList;
    }
    
    private void GetJSONAttributeMap(Map<String,Object> inputs, Map<String,Object> output, Map<String,Object> options){
        
        List<Object> arguments = (List<Object>)inputs.get('arguments');
        String JSONAttrString = (String) arguments[0];
        if (arguments.size() != 1 ) {
            
            InvalidParameterValueException e = new InvalidParameterValueException('GetJSONAttributeMap', 'The function must be called with at 1 arguments');
            throw e;
        }
        
        if (JSONAttrString != null && JSONAttrString.length() > 0) {
            
            List<Vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest> actionRequestsList = new List<Vlocity_cmt.JSONAttributeSupport.JSONAttributeActionRequest>();
            Map<String, object> inputMap = new Map<String, object>(); 
            Map<String, object> outputMap = new Map<String, object>(); 
            Map<String, object> optionsMap = new Map<String, object>();
            inputMap.put('JSONString', JSONAttrString);
            Vlocity_cmt.JSONAttributeSupport jsonSupport = new Vlocity_cmt.JSONAttributeSupport();
            jsonSupport.invokeMethod('getAttributeValuesFromJSON', inputMap, outputMap, optionsMap); 
            Map<String,Object> attributeCodeToDisplayName = (Map<String,Object>)outputMap.get('attributeCodeToDisplayName');
            Map<String,Object> attributeCodeToValue = (Map<String,Object>)outputMap.get('attributeCodeToValue');
            Map<String,Object> AttriNameToValueMap = new Map<String,Object>();
            for(String attriCode : attributeCodeToDisplayName.keySet()){
                AttriNameToValueMap.put((String)attributeCodeToDisplayName.get(attriCode),attributeCodeToValue.get(attriCode));
            }
            
            output.put('result', AttriNameToValueMap);
            
        }
    }
    
    private List<Object> GetJSONMapKeys(List<Object> arguments) {
        
        List<Object> theList = new List<Object>();
        
        Map<String,Object> JSONMap;
        String newNodeName;
        
        //check 
        if (arguments.size() >= 2) {
            JSONMap = (Map<String,Object>)(arguments.get(0));
            newNodeName  = String.valueOf(arguments.get(1));
        }
        else {
            InvalidParameterValueException e = new InvalidParameterValueException('GetJSONMapKeys', 'The function must be called with at least 2 arguments');
            throw e;
        }
        
        if(null != JSONMap && JSONMap.size()>0){
            for(String key : JSONMap.keySet() ){
                Map<String,Object> newJSONMap = new Map<String,Object>();
                newJSONMap.put(newNodeName,(String)key);
                theList.add(newJSONMap);
            }
        }
        system.debug('theList '+theList);     
        return theList;
    }
    
    private Boolean getAccessType(Map<String,Object> inputs, Map<String,Object> output) {
        Map<String, String[]> qLIServAccMap = new Map<String, String[]>();
        List<Object> args = (List<Object>)inputs.get('arguments');
        String quoteId = (String) args[0];
        args.remove(0);
        
        System.debug(JSON.serialize(args));
        
        for (QuoteLineItem qLI : [SELECT Id, Product2.ProductCode, vlocity_cmt__ServiceAccountId__c FROM QuoteLineItem WHERE QuoteId = :quoteId]) {
            if (qLIServAccMap.containsKey(qLI.vlocity_cmt__ServiceAccountId__c)) {
                qLIServAccMap.get(qLI.vlocity_cmt__ServiceAccountId__c).add(qLI.Product2.ProductCode);
            } else {
                qLIServAccMap.put(qLI.vlocity_cmt__ServiceAccountId__c, new String[]{ qLI.Product2.ProductCode });
            }
        }
        
        for (Object obj : args) {
            Map<String, Object> line = (Map<String, Object>)obj;
            if (qLIServAccMap.get((String)line.get('ServiceLocationId')).contains(ftr_CpqService.ProductCode_PrivateNetwork)) {
                line.put('AccessType', 'Private Network');
            } else if (qLIServAccMap.get((String)line.get('ServiceLocationId')).contains(ftr_CpqService.ProductCode_EIA)) {
                line.put('AccessType', 'EIA');
            } else {
                line.put('AccessType', 'Other');
            }
        }
        System.debug(JSON.serialize(args));
        output.put('result', args);
        return true;  
    }
    
    private Boolean getAttrVal(Map<String,Object> inputs, Map<String,Object> output) {
        List<Object> args = (List<Object>)inputs.get('arguments');
        Map<String, Object> cateAttrs = (Map<String, Object>)args[0];
        String inputName = (String)args[1];
        //inputName = inputName =='Tech_Partner'?'ATTR_TECH_PAERTNER':inputName;
        system.debug('####inPUT'+inputName);
        for (Object attrsObj : cateAttrs.values()) {
            List<Object> attrs = (List<Object>)attrsObj;
            for (Object attrObj : attrs) {
                Map<String, Object> attr = (Map<String, Object>)attrObj;
                String attrName = (String)attr.get('characteristic');
                Object attrVal = attr.get('value');
                system.debug('@@AttrName'+attrName);
                if (attrName == inputName) {
                    system.debug('AttrName'+attrName+'inputname'+inputName);
                    output.put('result', attrVal);
                }
            }
        }
        return true;  
    }
    Public Boolean getNextUNI(Map<String,Object> inputs,Map<String,Object> output)
    {
        List<Object> args = (List<Object>)inputs.get('arguments');
        
        String arg = (String)args[0];
        system.debug('args'+args);
        
        if(args.size()>=1 && arg !=null){
            
            args.sort();  // This function always results in asc order.
            List<Object> finalList = new List<Object>();
            for(Integer i = args.size()-1; i>=0;i--)
            {
                finalList.add(args.get(i));
            }
            String character = (String)finalList[0];
            System.debug('character'+character);
            Integer[] ASCIINumericRepresentation = character.getChars(); 
            String nxtCharacter = String.fromCharArray(new List<Integer> {ASCIINumericRepresentation[0] + 1}); 
            system.debug('next character'+nxtCharacter);
            output.put('result', nxtCharacter);
        } else {
            
            String nextCharacter = 'A';
            output.put('result', nextCharacter);
        }
        return true ;
    }
    
    /* 
* Usage: replaceString(string, stringToReplace, replacement)
*/
    Public String replaceString(List<Object> arguments)
    {
        String str = string.valueOf(arguments[0]),
            stringToReplace = string.valueOf(arguments[1]),
            replacement = string.valueOf(arguments[2]);
        
        return str.replaceAll(stringToReplace, replacement);
    }
    
    /* 
* Usage: setOpportunityName(List<Object> arguments)
* sets the opportunity name for Quick price partner portal
*/
    Public String setOpportunityName(List<Object> arguments)
    {
        System.debug('***arguments is ***'+ arguments.size());
        String accountName = string.valueOf(arguments[0]);
        System.debug('*****arg 0 is ****' + accountName);
        String oppName = null;
        Set<String> speeds = new Set<String>(); 
        Set<String> terms = new Set<String>();
        for (Integer i = 1; i < arguments.size(); i++){
            Map<String,Object> mapObj = (Map<String,Object>)arguments[i];
            for(String key : mapObj.keySet()){
                if(key.equals('Speed_Mbps__c')){
                    String val = String.valueOf(mapObj.get(key)); 
                    speeds.add(val);
                }
                System.debug('***speeds name is ***'+ speeds);
                if(key.equals('Term__c')){
                    String val = (String)mapObj.get(key); 
                    val = val.substring(0, 2);
                    terms.add(val);
                }
                if(key.equals('Description')){
                    String val = (String)mapObj.get(key); 
                    if(val == 'MNS - Managed Dedicated Internet'){
                        if(!OpprtunityName.contains('MNS')){
                            OpprtunityName =OpprtunityName +'_MNS_';  
                            system.debug('-------1'+OpprtunityName);
                        }
                    }
                    if(val == 'DIA (Dedicated Internet Access)'){
                        if(!OpprtunityName.contains('DIA')){ 
                            OpprtunityName = OpprtunityName + '_DIA_';
                            system.debug('-------2'+OpprtunityName);
                        }
                    }
                    
                    if(OpprtunityName.contains('DIA') && OpprtunityName.contains('MNS')){
                        OpprtunityName = '_DIA/MNS_';
                        system.debug('-------3'+OpprtunityName);
                    }
                    
                } 
                System.debug('***terms name is ***'+ terms);
            }
            oppName = 'Opp-'+accountName+OpprtunityName+String.join(new List<String>(speeds), '/')
                +' Mbps_'+String.join(new List<String>(terms), '/') +' Months';
            System.debug('***opp name is ***'+ oppName);
        }
        return oppName;
    }
    
    //Added by Lakshmi
    //
    private Boolean getCustomerOrderItemBySNE(Map<String,Object> inputs, Map<String,Object> output) {
        system.debug('getCustomerOrderItemBySNE ----'+inputs);
        List<Object> args = (List<Object>)inputs.get('arguments');
        List<String> lstProds;
        String SNE_Code_MRC,SNE_Code_OTC,SNE_Code_TERM,EVPL_SNE_Code_MRC, MR_SNE_Code_MRC,MR_RecurringCharge,
            MR_Quantity,EVPL_SNE_Code_OTC, EVPL_SNE_Code_TERM, UNI_SNE_CODE,IP_SNE_Code_MRC,IP_SNE_Code_OTC, IP_Quantity,IP_SNE_Code_TERM,
            DPI_SIP_Code_DID, DPI_SIP_Code_NA, DPI_SIP_Code_MR, DPI_SIP_Code_MRINS, DPI_SIP_Code_RB, 
            DPI_SIP_Code_INSK, DPI_SIP_INSK_OneTimeCharge, DPI_SIP_RM_OneTimeCharge, DPI_SIP_Code_LBOTA, DPI_SIP_Code_ITW, DPI_SIP_Code_TFAB, DIP_SIP_Code_LBOT, DPI_SIP_Code_TFN, DIP_SIP_Code_SIPT , 
            DPI_SIP_NA_RecurringCharge, DPI_SIP_NA_Term, SIP_MR_RecurringCharge, DPI_SIP_MRINS_OneTimeCharge = null;
        String  MSS_SNE_Code_MRC,MSS_RecurringCharge,MSS_Quantity,MSS_SNE_Code_TERM,MSA_SNE_Code_MRC,MSA_RecurringCharge,MSA_Quantity,MSA_SNE_Code_TERM,CELL_SNE_Code_MRC,CELL_RecurringCharge,CELL_Quantity,CELL_SNE_Code_TERM = null;
        String  IND_SNE_Code_MRC,IND_RecurringCharge,IND_Quantity,IND_SNE_Code_TERM,OUT_SNE_Code_MRC,OUT_RecurringCharge,OUT_Quantity,OUT_SNE_Code_TERM,DPI_ELAN_SNE_COS,ATTR_OFFLM_SNE_CODE,ATTR_PARTNER_SNE_CODE = null;
        String chargeType, quantity, circuit,DIP_SIP_Code_DID,DPISIPQuantity;
        String SIP_Code_Quantity = '1.00';
        Map<String, Object> cateAttrs = (Map<String, Object>)args[0];
        List<Object> finalList = new List<Object>();
        
        System.debug('cateAttrs :'+ cateAttrs);
        List<Object> custAccountAttr =  (  List<Object>)cateAttrs.get('FTR_ENT_CUSTOMERACCOUNT_ATTCAT');
        List<Object> custOrderAttr =  (  List<Object>)cateAttrs.get('FTR_ENT_CUSTOMERORDER_ATTCAT');
        for(Object attrsObj : cateAttrs.values()) {
            List<Object> attrs = (List<Object>)attrsObj;
            for (Object attrObj : attrs) {
                System.debug('attrObj: '+attrObj);
                Map<String, Object> attr = (Map<String, Object>)attrObj;
                String attrName = (String)attr.get('characteristic');
                System.debug('Attribute Name: '+attrName);
                Object attrVal = attr.get('value');
                System.debug('attrName.equalsDPI_SIP_Code_TFN'+attrName.equals('DPI_SIP_Code_TFN'));
                if(attrName.equals('SNE_Code_MRC')){
                    System.debug('Attribute value: '+attrVal);
                    /*   if((object)attrVal==null || attrVal.equals('')){
SNE_Code_MRC = '';
}else{*/
                    SNE_Code_MRC = (String)attrVal;
                    //  }
                    
                }
                if(attrName.equals('SNE_Code_OTC')){
                    SNE_Code_OTC =    (String)attrVal;
                }
                if(attrName.equals('SNE_Code_TERM')){
                    SNE_Code_TERM =    (String)attrVal;
                }
                if(attrName.equals('EVPL_SNE_Code_MRC')){
                    EVPL_SNE_Code_MRC = (String)attrVal;
                }
                if(attrName.equals('EVPL_SNE_Code_OTC')){
                    EVPL_SNE_Code_OTC = (String)attrVal;
                }
                if(attrName.equals('EVPL_SNE_Code_TERM')){
                    EVPL_SNE_Code_TERM = (String)attrVal;
                }
                if(attrName.equals('UNI_SNE_CODE')){
                    UNI_SNE_CODE = (String)attrVal;
                }
                if(attrName.equals('IP_SNE_Code_MRC')){
                    IP_SNE_Code_MRC = (String)attrVal;
                }
                if(attrName.equals('IP_SNE_Code_OTC')){
                    IP_SNE_Code_OTC = (String)attrVal;
                }
                if(attrName.equals('IP_SNE_Code_TERM')){
                    IP_SNE_Code_TERM = (String)attrVal;
                    System.debug('IP_SNE_Code_TERM: '+IP_SNE_Code_TERM);
                }
                if(attrName.equals('Quantity')){
                    quantity = (String)attrVal;
                }
                if(attrName.equals('DPIQuantity')) {DPISIPQuantity = (String)attrVal; }
                if(attrName.equals('CKT_SNE_CODE')){ circuit = (String)attrVal; }    
                if(attrName.equals('IP_Quantity')){ IP_Quantity = (String)attrVal; }    
                if(attrName.equals('MR_SNE_Code_MRC')){ MR_SNE_Code_MRC = (String)attrVal; } 
                if(attrName.equals('MR_RecurringCharge')){ MR_RecurringCharge = (String)attrVal; } 
                if(attrName.equals('MR_Quantity')){ MR_Quantity = (String)attrVal; } 
                if(attrName.equals('DPI_MSS_SNE_Code_MRC')){ MSS_SNE_Code_MRC = (String)attrVal; } 
                if(attrName.equals('DPI_MSS_RecurringCharge')){ MSS_RecurringCharge = (String)attrVal; } 
                if(attrName.equals('DPI_MSS_Quantity')){ MSS_Quantity = (String)attrVal;} 
                if(attrName.equals('DPI_MSA_SNE_Code_MRC')){ MSA_SNE_Code_MRC = (String)attrVal; } 
                if(attrName.equals('DPI_MSA_RecurringCharge')){ MSA_RecurringCharge = (String)attrVal; } 
                //SIP CODES
                if(attrName.equals('DPI_SIP_Code_DID')){ DPI_SIP_Code_DID = (String)attrVal;
                                                       }
                if(attrName.equals('DPI_SIP_Code_NA')){ DPI_SIP_Code_NA = (String)attrVal;
                                                      }
                if(attrName.equals('DPI_SIP_Code_MR')){ DPI_SIP_Code_MR = (String)attrVal;
                                                      } 
                if(attrName.equals('DPI_SIP_Code_MRINS')){ DPI_SIP_Code_MRINS = (String)attrVal;
                                                         } 
                if(attrName.equals('DPI_SIP_Code_RB')){ DPI_SIP_Code_RB = (String)attrVal;
                                                      } 
                if(attrName.equals('DPI_SIP_Code_INSK')){ DPI_SIP_Code_INSK = (String)attrVal;
                                                        }  
                if(attrName.equals('DPI_SIP_INSK_OneTimeCharge')){ DPI_SIP_INSK_OneTimeCharge = (String)attrVal;
                                                                 }
                if(attrName.equals('DPI_SIP_RM_OneTimeCharge')){ DPI_SIP_RM_OneTimeCharge = (String)attrVal;
                                                               }
                
                if(attrName.equals('DPI_SIP_NA_Term')){ DPI_SIP_NA_Term = (String)attrVal;
                                                      }
                if(attrName.equals('DIP_SIP_Code_DID')){ DIP_SIP_Code_DID = (String)attrVal;
                                                       }
                
                ///ANNIE
                if(attrName.equals('DPI_SIP_Code_LBOTA')){   /*SIP LD Block of Time - Additional*/  DPI_SIP_Code_LBOTA = (String)attrVal;
                                                         }
                
                if(attrName.equals('DPI_SIP_Code_ITW')){    /*SIP - International Talk to the World*/ DPI_SIP_Code_ITW = (String)attrVal;
                                                       }
                
                if(attrName.equals('DPI_SIP_Code_TFAB')){   /*SIP TF Block of Time - Additional*/ DPI_SIP_Code_TFAB = (String)attrVal;
                                                        }
                if(attrName.equals('DIP_SIP_Code_LBOT')){    /* SIP LD Block of Time - Additional*/ DIP_SIP_Code_LBOT = (String)attrVal;
                                                        }
                
                if(attrName.equals('DPI_SIP_Code_TFN')){    /* SIP Toll Free Number*/ 
                    System.debug(':::: (String)attrVal DPI_SIP_Code_TFN'+(String)attrVal);
                    DPI_SIP_Code_TFN   = (String)attrVal;
                    
                }
                
                if(attrName.equals('DIP_SIP_Code_SIPT')){    /* SIP TRUNKING */ DIP_SIP_Code_SIPT   = (String)attrVal;
                                                        }
                if(attrName.equals('DPI_MSA_Quantity')){ MSA_Quantity = (String)attrVal; } 
                if(attrName.equals('DPI_CELL_SNE_Code_MRC')){ CELL_SNE_Code_MRC = (String)attrVal; } 
                if(attrName.equals('DPI_CELL_RecurringCharge')){ CELL_RecurringCharge = (String)attrVal;} 
                if(attrName.equals('DPI_CELL_Quantity')){CELL_Quantity = (String)attrVal;} 
                if(attrName.equals('DPI_IND_SNE_Code_MRC')){IND_SNE_Code_MRC = (String)attrVal;} 
                if(attrName.equals('DPI_IND_RecurringCharge')){IND_RecurringCharge = (String)attrVal;} 
                if(attrName.equals('DPI_IND_Quantity')){IND_Quantity = (String)attrVal;} 
                if(attrName.equals('DPI_OUT_SNE_Code_MRC')){OUT_SNE_Code_MRC = (String)attrVal;} 
                if(attrName.equals('DPI_OUT_RecurringCharge')){OUT_RecurringCharge = (String)attrVal;} 
                if(attrName.equals('DPI_OUT_Quantity')){OUT_Quantity = (String)attrVal;}
                if(attrName.equals('DPI_ELAN_SNE_COS')){DPI_ELAN_SNE_COS = (String)attrVal;} 
                if(attrName.equals('ATTR_OFFLM_SNE_CODE')){ATTR_OFFLM_SNE_CODE = (String)attrVal;} 
                if(attrName.equals('ATTR_PARTNER_SNE_CODE')){ATTR_PARTNER_SNE_CODE = (String)attrVal;} 
            }
        }
        if(SNE_Code_MRC!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(SNE_Code_MRC, lineItemSeq, quantity, chargeType, direction));
            
        }
        if(SNE_Code_OTC!=null){
            chargeType = 'Temporary';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(SNE_Code_OTC, lineItemSeq, quantity, chargeType, direction));
        }
        if(SNE_Code_TERM!=null){ 
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(SNE_Code_TERM, lineItemSeq, quantity, chargeType, direction));
        }
        if(IP_SNE_Code_OTC!=null){
            chargeType = 'Temporary';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(IP_SNE_Code_OTC, lineItemSeq, quantity, chargeType, direction));    
        }
        if(IP_SNE_Code_MRC!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(IP_SNE_Code_MRC, lineItemSeq, IP_Quantity, chargeType, direction));           
        }
        if(MR_SNE_Code_MRC!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(MR_SNE_Code_MRC, lineItemSeq, MR_Quantity, chargeType, direction));
        }
        if(EVPL_SNE_Code_MRC!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(EVPL_SNE_Code_MRC, lineItemSeq, quantity, chargeType, direction));
        }
        if(EVPL_SNE_Code_OTC!=null){
            chargeType = 'Temporary';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(EVPL_SNE_Code_OTC, lineItemSeq, quantity, chargeType, direction));
        }
        if(EVPL_SNE_Code_TERM!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(EVPL_SNE_Code_TERM, lineItemSeq, quantity, chargeType, direction));
            
        }
        if(IP_SNE_Code_TERM!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(IP_SNE_Code_TERM, lineItemSeq, quantity, chargeType, direction));
            
        }
        if(UNI_SNE_CODE!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(UNI_SNE_CODE, lineItemSeq, quantity, chargeType, direction));
        }
        if(circuit!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(circuit, lineItemSeq, SIP_Code_Quantity, chargeType, direction));
            
        }
        if(MSS_SNE_Code_MRC!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(MSS_SNE_Code_MRC, lineItemSeq, MSS_Quantity, chargeType, direction));
        }
        if(MSA_SNE_Code_MRC!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(MSA_SNE_Code_MRC, lineItemSeq, MSA_Quantity, chargeType, direction));
        }
        if(CELL_SNE_Code_MRC!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(CELL_SNE_Code_MRC, lineItemSeq, CELL_Quantity, chargeType, direction));
        }
        if(IND_SNE_Code_MRC!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(IND_SNE_Code_MRC, lineItemSeq, IND_Quantity, chargeType, direction));
        }
        if(OUT_SNE_Code_MRC!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(OUT_SNE_Code_MRC, lineItemSeq, OUT_Quantity, chargeType, direction));
        }
        if(DPI_SIP_Code_DID!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(DPI_SIP_Code_DID, lineItemSeq, '1', chargeType, direction));
            //  finalList.add(createCustOrderJson(DPI_SIP_Code_DID, lineItemSeq, SIP_Code_Quantity, chargeType, direction));
            
        }
        if(DPI_SIP_Code_NA!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(DPI_SIP_Code_NA, lineItemSeq, SIP_Code_Quantity, chargeType, direction));
            
        }
        if(DPI_SIP_Code_MR!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(DPI_SIP_Code_MR, lineItemSeq, SIP_Code_Quantity, chargeType, direction));
            
        }
        if(DPI_SIP_Code_MRINS!=null){
            chargeType = 'Temporary';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(DPI_SIP_Code_MRINS, lineItemSeq, SIP_Code_Quantity, chargeType, direction));
            
        }
        if(DPI_SIP_Code_RB!=null){
            chargeType = 'Temporary';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(DPI_SIP_Code_RB, lineItemSeq, SIP_Code_Quantity, chargeType, direction));
            
        }
        if(DPI_SIP_Code_INSK!=null){
            chargeType = 'Temporary';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(DPI_SIP_Code_INSK, lineItemSeq, SIP_Code_Quantity, chargeType, direction));
            
        }
        if(DPI_SIP_NA_Term!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(DPI_SIP_NA_Term, lineItemSeq, SIP_Code_Quantity, chargeType, direction));
            
        }
        if(DIP_SIP_Code_DID!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(DIP_SIP_Code_DID, lineItemSeq, SIP_Code_Quantity, chargeType, direction));
        }
        //Annie 
        
        if(DPI_SIP_Code_LBOTA!=null){ //IP - International Talk to the World
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(DPI_SIP_Code_LBOTA, lineItemSeq, SIP_Code_Quantity, chargeType, direction));
        }
        
        if(DPI_SIP_Code_ITW!=null){   //IP - International Talk to the World
            chargeType = 'Temporary';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(DPI_SIP_Code_ITW, lineItemSeq, SIP_Code_Quantity, chargeType, direction));
        }  
        
        if(DPI_SIP_Code_TFAB!=null){ //SIP TF Block of Time - Additional 
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(DPI_SIP_Code_TFAB, lineItemSeq, SIP_Code_Quantity, chargeType, direction));
        }  
        
        if(DIP_SIP_Code_LBOT !=null){ //SIP LD Block of Time - Additional
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(DIP_SIP_Code_LBOT , lineItemSeq, SIP_Code_Quantity, chargeType, direction));
        }  
        
        if(DPI_SIP_Code_TFN  !=null){ // SIP Toll Free Number
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(DPI_SIP_Code_TFN  , lineItemSeq, SIP_Code_Quantity, chargeType, direction));
        }  
        
        if(DIP_SIP_Code_SIPT   !=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(DIP_SIP_Code_SIPT   , lineItemSeq, DPISIPQuantity, chargeType, direction));
            //16052023 finalList.add(createCustOrderJson(DIP_SIP_Code_SIPT   , lineItemSeq, SIP_Code_Quantity, chargeType, direction));
        }
        if(DPI_ELAN_SNE_COS!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(DPI_ELAN_SNE_COS, lineItemSeq, quantity, chargeType, direction));
        }
        if(ATTR_OFFLM_SNE_CODE!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(ATTR_OFFLM_SNE_CODE, lineItemSeq, quantity, chargeType, direction));
        }
        if(ATTR_PARTNER_SNE_CODE!=null){
            chargeType = 'Permanent';
            String direction = 'Forward'; 
            String lineItemSeq = '1';
            finalList.add(createCustOrderJson(ATTR_PARTNER_SNE_CODE, lineItemSeq, quantity, chargeType, direction));
        }
        system.debug('finalList of customerorderitem---'+finalList);
        output.put('result', finalList);
        return true;  
    }
    private Map<String,Object> createCustOrderJson(String snecode, String lineItemSeq, String quantity, String chargeType, String direction) {
        Map<String, Object> mapItem = new Map<String, Object>();
        Map<String, Object> mapProduct = new Map<String, Object>();
        mapProduct.put('id',snecode);
        System.debug('SNE Code :'+ ': '+snecode);
        mapItem.put('action','Add');
        mapProduct.put('lineItemSequenceNumber',lineItemSeq);
        mapItem.put('quantity',quantity);
        mapItem.put('processingDirection',direction);
        mapItem.put('chargeType',chargeType);
        if(mapProduct!=null){
            mapItem.put('product',mapProduct);
        }
        System.debug('mapitem is :'+mapItem);
        return mapItem;
    }
    private Boolean getCommercialContractItemBySNE(Map<String,Object> inputs, Map<String,Object> output) {
        system.debug('getCommercialOrderItemBySNE ----'+inputs);
        List<Object> args = (List<Object>)inputs.get('arguments');
        List<String> lstProds;
        List<Object> finalList = new List<Object>();
        
        String SNE_Code_OTC, SNE_Code_MRC, SNE_Code_TERM, EVPL_SNE_Code_MRC,MR_RecurringCharge,MR_SNE_Code_MRC, 
            MR_Quantity, EVPL_SNE_Code_OTC, EVPL_SNE_Code_TERM, UNI_SNE_CODE,IP_SNE_Code_MRC,IP_SNE_Code_OTC,IP_Quantity, 
            IP_SNE_Code_TERM, IP_monthlyRecCharge, IP_oneTimeCharge, DPI_SIP_Code_DID, 
            DPI_SIP_Code_NA, DPI_SIP_Code_MR, DPI_SIP_Code_MRINS, DPI_SIP_Code_RB, DPI_SIP_Code_INSK, DPI_SIP_INSK_OneTimeCharge, DPI_SIP_RM_OneTimeCharge,
            DPI_SIP_NA_RecurringCharge, DPI_SIP_NA_OneTimeCharge, DPI_SIP_MR_RecurringCharge, 
            DPI_SIP_MRINS_OneTimeCharge,DIP_SIP_Code_DID,DPI_SIP_Code_LBOTA,DPI_SIP_Code_ITW,DPI_SIP_Code_TFAB,DIP_SIP_Code_LBOT,DPI_SIP_Code_TFN,DIP_SIP_Code_SIPT,DID_SNE_Code_MRC,DID_Quantity;
        String monthlyRecCharge, oneTimeCharge, quantity,TECH_SOURCE_PRODUCTCODE;
        String evplMonthlyRecCharge, evplOneTimeCharge, evplQuantity;
        Integer commQuantity, commIPQuantity, commMRQuantity, evplCommQty,DIDLeadQuantity;
        Integer SIP_Code_Quantity = 1;
        String 	MSS_SNE_Code_MRC,MSS_RecurringCharge,MSS_Quantity,MSS_SNE_Code_TERM,MSA_SNE_Code_MRC,MSA_RecurringCharge,MSA_Quantity,MSA_SNE_Code_TERM,CELL_SNE_Code_MRC,CELL_RecurringCharge,CELL_Quantity,CELL_SNE_Code_TERM = null;
        String 	IND_SNE_Code_MRC,IND_RecurringCharge,IND_Quantity,IND_SNE_Code_TERM,OUT_SNE_Code_MRC,OUT_RecurringCharge,OUT_Quantity,OUT_SNE_Code_TERM,DPI_ELAN_SNE_COS = null;
        Integer indQty,outQty,mssQty,msaQty,cellQty;
        // Annie Fields 
        String DPI_SIP_MRC,DPI_SIP_Quantity,SIP_TFN_SNE_Code_MRC,DPI_TFN_Quantity,SIP_LDBT_SNE_MRC,DPI_LBOT_Quantity,SIP_ITW_SNE_Code_MRC,DPI_ITW_Quantity,SIP_LDBOT_SNE_Code_MRC,DPI_LDBOT_Quantity;
        Integer DID_MDN_SIP_Quantity,DID_MDN_TFN_Quantity,DID_MDN_LBOT_Quantity,DID_MDN_ITW_Quantity,DID_MDN_LDBOT_Quantity;
        Map<String, Object> cateAttrs = (Map<String, Object>)args[0];
        List<String> LDBlockOfTimeAdditional = new List<String>{'F1BT1','F1BT2','F1BTV','F1B10','F1B20','F1B4M','F1B57'};
            List<String> TOLLFreeProduct = new List<String>{'T1B42','T1B43','T1T57','T1B48','T1TF0','T1TFB'};
                
                System.debug('cateAttrs :'+ cateAttrs);
        List<Object> custAccountAttr =  (  List<Object>)cateAttrs.get('FTR_ENT_CUSTOMERACCOUNT_ATTCAT');
        List<Object> custOrderAttr =  (  List<Object>)cateAttrs.get('FTR_ENT_CUSTOMERORDER_ATTCAT');
        for(Object attrsObj : cateAttrs.values()) {
            List<Object> attrs = (List<Object>)attrsObj;
            for (Object attrObj : attrs) {
                System.debug('attrObj: '+attrObj);
                Map<String, Object> attr = (Map<String, Object>)attrObj;
                String attrName = (String)attr.get('characteristic');
                System.debug('Attribute Name: '+attrName);
                Object attrVal = attr.get('value');
                if(attrName.equals('SNE_Code_MRC')){
                    System.debug('Attribute value: '+attrVal);
                    SNE_Code_MRC = (String)attrVal;
                }
                if(attrName.equals('SNE_Code_OTC')){
                    SNE_Code_OTC =    (String)attrVal;
                }
                if(attrName.equals('SNE_Code_TERM')){
                    SNE_Code_TERM= (String)attrVal;
                }
                if(attrName.equals('EVPL_SNE_Code_MRC')){
                    EVPL_SNE_Code_MRC = (String)attrVal;
                }
                if(attrName.equals('EVPL_SNE_Code_OTC')){
                    EVPL_SNE_Code_OTC = (String)attrVal;
                }
                if(attrName.equals('EVPL_SNE_Code_TERM')){
                    EVPL_SNE_Code_TERM = (String)attrVal;
                }
                if(attrName.equals('UNI_SNE_CODE')){UNI_SNE_CODE = (String)attrVal;}
                if(attrName.equals('IP_SNE_Code_MRC')){
                    IP_SNE_Code_MRC = (String)attrVal;
                }
                if(attrName.equals('IP_SNE_Code_OTC')){
                    IP_SNE_Code_OTC = (String)attrVal;
                }
                if(attrName.equals('IP_SNE_Code_TERM')){IP_SNE_Code_TERM = (String)attrVal;}
                if(attrName.equals('RecurringCharge')){
                    monthlyRecCharge = (String)attrVal;
                }
                if(attrName.equals('OneTimeTotal')){
                    oneTimeCharge = (String)attrVal;
                }
                if(attrName.equals('EVPL_RecurringCharge')){evplMonthlyRecCharge = (String)attrVal;}
                if(attrName.equals('EVPL_OneTimeTotal')){evplOneTimeCharge = (String)attrVal;}
                if(attrName.equals('IP_RecurringCharge')){IP_monthlyRecCharge = (String)attrVal;}
                if(attrName.equals('IP_OneTimeTotal')){IP_oneTimeCharge = (String)attrVal;} 
                if(attrName.equals('Quantity')){
                    quantity = (String)attrVal;
                    
                    commQuantity = Integer.valueOf(quantity);
                }
                if(attrName.equals('EVPL_Quantity')){
                    evplQuantity = (String)attrVal;
                    
                    evplCommQty = Integer.valueOf(evplQuantity);
                }
                if(attrName.equals('IP_Quantity')){
                    IP_Quantity = (String)attrVal;
                    commIPQuantity = Integer.valueOf(IP_Quantity);
                } 
                if(attrName.equals('MR_SNE_Code_MRC')){MR_SNE_Code_MRC = (String)attrVal;} 
                if(attrName.equals('MR_RecurringCharge')){MR_RecurringCharge = (String)attrVal;} 
                if(attrName.equals('MR_Quantity')){
                    MR_Quantity = (String)attrVal;
                    commMRQuantity = Integer.valueOf(MR_Quantity);
                }
                if(attrName.equals('DPI_MSS_SNE_Code_MRC')){MSS_SNE_Code_MRC = (String)attrVal;} 
                if(attrName.equals('DPI_MSS_RecurringCharge')){MSS_RecurringCharge = (String)attrVal;} 
                if(attrName.equals('DPI_MSS_Quantity')){
                    MSS_Quantity = (String)attrVal;
                    mssQty = Integer.valueOf(MSS_Quantity);
                } 
                if(attrName.equals('DPI_MSA_SNE_Code_MRC')){MSA_SNE_Code_MRC = (String)attrVal;} 
                if(attrName.equals('DPI_MSA_RecurringCharge')){MSA_RecurringCharge = (String)attrVal;} 
                if(attrName.equals('DPI_MSA_Quantity')){
                    MSA_Quantity = (String)attrVal;
                    msaQty = Integer.valueOf(MSA_Quantity);
                } 
                if(attrName.equals('DPI_CELL_SNE_Code_MRC')){CELL_SNE_Code_MRC = (String)attrVal;} 
                if(attrName.equals('DPI_CELL_RecurringCharge')){CELL_RecurringCharge = (String)attrVal;} 
                if(attrName.equals('DPI_CELL_Quantity')){
                    CELL_Quantity = (String)attrVal;
                    cellQty = Integer.valueOf(CELL_Quantity);
                } 
                if(attrName.equals('DPI_IND_SNE_Code_MRC')){IND_SNE_Code_MRC = (String)attrVal;} 
                if(attrName.equals('DPI_IND_RecurringCharge')){IND_RecurringCharge = (String)attrVal;} 
                if(attrName.equals('DPI_IND_Quantity')){
                    IND_Quantity = (String)attrVal;
                    indQty = Integer.valueOf(IND_Quantity);
                } 
                if(attrName.equals('DPI_OUT_SNE_Code_MRC')){OUT_SNE_Code_MRC = (String)attrVal;} 
                if(attrName.equals('DPI_OUT_RecurringCharge')){ OUT_RecurringCharge = (String)attrVal;} 
                if(attrName.equals('DPI_OUT_Quantity')){
                    OUT_Quantity = (String)attrVal;
                    outQty = Integer.valueOf(OUT_Quantity);
                } 
                // SIP Codes
                if(attrName.equals('DPI_SIP_Code_MR')){ DPI_SIP_Code_MR = (String)attrVal;
                                                      }
                if(attrName.equals('DPI_SIP_Code_MRINS')){ DPI_SIP_Code_MRINS = (String)attrVal;
                                                         }
                if(attrName.equals('DPI_SIP_Code_INSK')){ DPI_SIP_Code_INSK = (String)attrVal;
                                                        }
                if(attrName.equals('DPI_SIP_Code_RB')){ DPI_SIP_Code_RB = (String)attrVal;
                                                      }
                if(attrName.equals('DPI_SIP_INSK_OneTimeCharge')){ DPI_SIP_INSK_OneTimeCharge = (String)attrVal;
                                                                 }
                if(attrName.equals('DPI_SIP_RM_OneTimeCharge')){ DPI_SIP_RM_OneTimeCharge = (String)attrVal;
                                                               }
                if(attrName.equals('DPI_SIP_Code_NA')){ DPI_SIP_Code_NA = (String)attrVal;
                                                      }
                if(attrName.equals('DPI_SIP_NA_RecurringCharge')){ DPI_SIP_NA_RecurringCharge = (String)attrVal;
                                                                 }
                if(attrName.equals('DPI_SIP_MR_RecurringCharge')){ DPI_SIP_MR_RecurringCharge = (String)attrVal;
                                                                 }
                if(attrName.equals('DPI_SIP_MRINS_OneTimeCharge')){ DPI_SIP_MRINS_OneTimeCharge = (String)attrVal;
                                                                  }
                if(attrName.equals('DIP_SIP_Code_DID')){ DIP_SIP_Code_DID = (String)attrVal;
                                                       }
                ///Annie
                if(attrName.equals('DPI_SIP_Code_LBOTA')){
                    if(LDBlockOfTimeAdditional.contains((String)attrVal)){
                        DPI_SIP_Code_LBOTA = (String)attrVal;
                        System.debug('MR_SNE_Code_MRC in commercial contract '+ DPI_SIP_Code_LBOTA);
                    }
                    
                }
                
                if(attrName.equals('DPI_SIP_Code_ITW')){
                    
                    DPI_SIP_Code_ITW = (String)attrVal;
                    System.debug('MR_SNE_Code_MRC in commercial contract '+ DPI_SIP_Code_ITW);
                    
                }
                if(attrName.equals('DPI_SIP_Code_TFAB')){
                    if(TOLLFreeProduct.contains((String)attrVal)){
                        DPI_SIP_Code_TFAB = (String)attrVal;
                        System.debug('MR_SNE_Code_MRC in commercial contract '+ DPI_SIP_Code_TFAB);
                    }
                    
                    
                }
                if(attrName.equals('DIP_SIP_Code_LBOT')){
                    if(LDBlockOfTimeAdditional.contains((String)attrVal)){
                        DIP_SIP_Code_LBOT = (String)attrVal;
                        System.debug('MR_SNE_Code_MRC in commercial contract '+ DIP_SIP_Code_LBOT);
                    }
                    
                    
                }
                if(attrName.equals('DPI_SIP_Code_TFN')){
                    DPI_SIP_Code_TFN = (String)attrVal;
                    System.debug('MR_SNE_Code_MRC in commercial contract '+ DPI_SIP_Code_TFN);
                    
                }
                if(attrName.equals('DIP_SIP_Code_SIPT')){
                    DIP_SIP_Code_SIPT = (String)attrVal;
                    System.debug('MR_SNE_Code_MRC in commercial contract '+ DIP_SIP_Code_SIPT);
                    
                }
                
                // For MDN and Lead DID Number
                if(attrName.equals('DID_SNE_Code_MRC')){ DID_SNE_Code_MRC = (String)attrVal;
                                                       }
                if(attrName.equals('DID_Quantity')){
                    DID_Quantity =(String)attrVal;
                    DIDLeadQuantity = Integer.valueOf(DID_Quantity);
                }
                
                // For MDN SIP Trunking
                if(attrName.equals('DPI_SipMrc')){ DPI_SIP_MRC = (String)attrval;
                                                 }
                if(attrName.equals('DPIQuantity')){
                    System.debug(':::: (String)attrVal'+(String)attrVal);
                    DPI_SIP_Quantity =(String)attrVal;
                    System.debug(':::: DPI_SIP_Quantity'+DPI_SIP_Quantity);
                    DID_MDN_SIP_Quantity = Integer.valueOf(DPI_SIP_Quantity);
                    System.debug(':::: DID_MDN_SIP_Quantity'+DID_MDN_SIP_Quantity);
                }
                
                // For MDN Toll Free Number
                if(attrName.equals('SIP_TFN_SNE_Code_MRC')){ SIP_TFN_SNE_Code_MRC = (String)attrVal;
                                                           }
                if(attrName.equals('SIP_TFN_Quantity')){
                    DPI_TFN_Quantity =(String)attrVal;
                    DID_MDN_TFN_Quantity = Integer.valueOf(DPI_TFN_Quantity);
                }
                //For MDN LD- Block Of Time
                if(attrName.equals('SIP_LDBT_SNE_MRC')){ SIP_LDBT_SNE_MRC = (String)attrVal;
                                                       }
                if(attrName.equals('SIP_LDBT_Quantity')){
                    DPI_LBOT_Quantity =(String)attrVal;
                    DID_MDN_LBOT_Quantity = Integer.valueOf(DPI_LBOT_Quantity);
                }
                
                // For MDN International Talk World
                if(attrName.equals('SIP_ITW_SNE_Code_MRC')){ SIP_ITW_SNE_Code_MRC = (String)attrVal;
                                                           }
                if(attrName.equals('SIP_ITW_Quantity')){
                    DPI_ITW_Quantity =(String)attrVal;
                    DID_MDN_ITW_Quantity = Integer.valueOf(DPI_ITW_Quantity);
                }
                // For MDN Additional Block Of Time
                if(attrName.equals('SIP_LDBOT_SNE_Code_MRC')){ SIP_LDBOT_SNE_Code_MRC = (String)attrVal;
                                                             }
                if(attrName.equals('SIP_LDBOT_Quantity')){
                    DPI_LDBOT_Quantity =(String)attrVal;
                    DID_MDN_LDBOT_Quantity = Integer.valueOf(DPI_LDBOT_Quantity);
                }
                if(attrName.equals('DPI_ELAN_SNE_COS')){
                    DPI_ELAN_SNE_COS = (String)attrVal;
                }
                if(attrName.equals('TECH_SOURCE_PRODUCTCODE')){
                    TECH_SOURCE_PRODUCTCODE = (String)attrVal;
                }
                
            }
        }
        if(SNE_Code_MRC!=null){
            finalList.add(createCommercialContractJson(SNE_Code_MRC, null, monthlyRecCharge, commQuantity));
        }
        if(SNE_Code_OTC!=null){
            finalList.add(createCommercialContractJson(SNE_Code_OTC, oneTimeCharge, null, commQuantity));
        }
        if(SNE_Code_TERM!=null && ((DPI_ELAN_SNE_COS != null && TECH_SOURCE_PRODUCTCODE !='ENT_ETH_EVPL_0010')  || TECH_SOURCE_PRODUCTCODE =='ENT_ETH_EIA_0002' || TECH_SOURCE_PRODUCTCODE =='ENT_ETH_EIA_003')){
            finalList.add(createCommercialContractJson(SNE_Code_TERM, null, '0.00', commQuantity));
        }
        if(MR_SNE_Code_MRC!=null){
            finalList.add(createCommercialContractJson(MR_SNE_Code_MRC,  null, MR_RecurringCharge, commMRQuantity));
        }
        
        if(EVPL_SNE_Code_MRC!=null){
            finalList.add(createCommercialContractJson(EVPL_SNE_Code_MRC, null, evplMonthlyRecCharge, evplCommQty));
        }
        if(EVPL_SNE_Code_OTC!=null){
            finalList.add(createCommercialContractJson(EVPL_SNE_Code_OTC, evplOneTimeCharge, null, evplCommQty));
        }
        if(EVPL_SNE_Code_TERM!=null){
            finalList.add(createCommercialContractJson(EVPL_SNE_Code_TERM, null, null, evplCommQty));
        }
        /*  if(IP_SNE_Code_TERM!=null){
finalList.add(createCommercialContractJson(IP_SNE_Code_TERM,  null, null, commQuantity));
}*/
        
        if(MSS_SNE_Code_MRC!=null){
            finalList.add(createCommercialContractJson(MSS_SNE_Code_MRC,  null, MSS_RecurringCharge, mssQty));
        }
        if(MSA_SNE_Code_MRC!=null){
            finalList.add(createCommercialContractJson(MSA_SNE_Code_MRC,  null, MSA_RecurringCharge, msaQty));
        }
        if(CELL_SNE_Code_MRC!=null){
            finalList.add(createCommercialContractJson(CELL_SNE_Code_MRC,  null, CELL_RecurringCharge, cellQty));
        }
        if(DPI_SIP_Code_NA!=null){ finalList.add(createCommercialContractJson(DPI_SIP_Code_NA, null, DPI_SIP_NA_RecurringCharge, SIP_Code_Quantity));
                                 }
        if(DPI_SIP_Code_MRINS!=null){ finalList.add(createCommercialContractJson(DPI_SIP_Code_MRINS, DPI_SIP_MRINS_OneTimeCharge, null, SIP_Code_Quantity));
                                    }
        if(DPI_SIP_Code_INSK!=null){ finalList.add(createCommercialContractJson(DPI_SIP_Code_INSK, DPI_SIP_INSK_OneTimeCharge, null, SIP_Code_Quantity));
                                   }
        if(DPI_SIP_Code_RB!=null){ finalList.add(createCommercialContractJson(DPI_SIP_Code_RB, DPI_SIP_RM_OneTimeCharge, null, SIP_Code_Quantity));
                                 }
        
        if(DPI_SIP_Code_MR!=null){ finalList.add(createCommercialContractJson(DPI_SIP_Code_MR, null, DPI_SIP_MR_RecurringCharge, SIP_Code_Quantity));
                                 }
        
        // For MDN and Lead DID Number
        if(DID_SNE_Code_MRC !=null){ finalList.add(createCommercialContractJson(DIP_SIP_Code_DID, null, DID_SNE_Code_MRC, DIDLeadQuantity));
                                   }
        
        //Annie
        if(DPI_SIP_Code_LBOTA !=null){ finalList.add(createCommercialContractJson(DPI_SIP_Code_LBOTA, null, monthlyRecCharge, commQuantity));
                                     }
        //   if(DPI_SIP_Code_ITW !=null){
        //         finalList.add(createCommercialContractJson(DPI_SIP_Code_ITW, null, monthlyRecCharge, commQuantity));
        //     }
        if(DPI_SIP_Code_TFAB !=null){ finalList.add(createCommercialContractJson(DPI_SIP_Code_TFAB, null, monthlyRecCharge, commQuantity));
                                    }
        //   if(DIP_SIP_Code_LBOT !=null){
        
        //     }
        //   if(DPI_SIP_Code_TFN !=null){
        //         finalList.add(createCommercialContractJson(DPI_SIP_Code_TFN, null, monthlyRecCharge, commQuantity));
        //     }
        //   if(DIP_SIP_Code_SIPT !=null){
        //         finalList.add(createCommercialContractJson(DIP_SIP_Code_SIPT, null, monthlyRecCharge, commQuantity));
        //     }
        
        // For MDN SIP Trunking 
        if(DPI_SIP_MRC !=null){ finalList.add(createCommercialContractJson(DIP_SIP_Code_SIPT, null, DPI_SIP_MRC, DID_MDN_SIP_Quantity));
                               system.debug(DID_MDN_SIP_Quantity +'Quantity001');
                              }
        if(IND_SNE_Code_MRC!=null){
            finalList.add(createCommercialContractJson(IND_SNE_Code_MRC,  null, IND_RecurringCharge, indQty));
        }
        if(OUT_SNE_Code_MRC!=null){
            finalList.add(createCommercialContractJson(OUT_SNE_Code_MRC,  null, OUT_RecurringCharge, outQty));
        }
        // For MDN Toll Free Number
        if(SIP_TFN_SNE_Code_MRC !=null){ finalList.add(createCommercialContractJson(DPI_SIP_Code_TFN, null, SIP_TFN_SNE_Code_MRC, DID_MDN_TFN_Quantity));
                                       }
        // For MDN LD - Block Of Time
        if(SIP_LDBT_SNE_MRC !=null){ finalList.add(createCommercialContractJson(DIP_SIP_Code_LBOT, null, SIP_LDBT_SNE_MRC, DID_MDN_LBOT_Quantity));
                                   }
        // For MDN International Talk World
        if(SIP_ITW_SNE_Code_MRC !=null){ finalList.add(createCommercialContractJson(DPI_SIP_Code_ITW, null, SIP_ITW_SNE_Code_MRC, DID_MDN_ITW_Quantity));
                                       }
        // For MDN Additional Block Of Time
        if(SIP_LDBOT_SNE_Code_MRC !=null){ finalList.add(createCommercialContractJson(DPI_SIP_Code_LBOTA, null, SIP_LDBOT_SNE_Code_MRC, DID_MDN_LDBOT_Quantity));
                                         }
        if(DPI_ELAN_SNE_COS!=null){
            finalList.add(createCommercialContractJson(DPI_ELAN_SNE_COS,  null, '0.00', commQuantity));
        }
        
        system.debug('finalList---'+finalList.size() + finalList);
        output.put('result', finalList);
        return true;  
    }
    private Map<String,Object> createCommercialContractJson(String snecode, String oneTimeCharge, String monthlyRecCharge, Integer commQuantity) {
        Map<String, Object> mapItem = new Map<String, Object>();
        Map<String, Object> mapMRCRate = new Map<String, Object>();
        Map<String, Object> mapNRCRate = new Map<String, Object>();
        System.debug('SNE code inside commQuantity :' +commQuantity);
        String quantity  = String.ValueOf(commQuantity);
        System.debug('SNE code inside createcomcontract :' +snecode);
        mapItem.put('productId',snecode);
        mapItem.put('quantity',quantity);
        if(oneTimeCharge!=null){
            mapNRCRate.put('amount',oneTimeCharge);
            mapItem.put('nonRecurringChargeRate',mapNRCRate);
        }
        if(monthlyRecCharge!=null){
            mapMRCRate.put('amount',monthlyRecCharge);
            mapItem.put('monthlyRecurringChargeRate',mapMRCRate);
        }
        return mapItem;
    }
    private Boolean getContactPhone(Map<String,Object> inputs, Map<String,Object> output) {
        
        System.debug('::: argsINput'+inputs);
        List<Object> args = (List<Object>)inputs.get('arguments');
        String phoneNumber = String.valueOf(args[0]);
        
        if (phoneNumber.startsWith('1') && phoneNumber.length() > 10) {
            phoneNumber = phoneNumber.substring(1);
        }
        
        output.put('result', phoneNumber);
        
        
        return true;  
    }
    
    private Boolean getnpanxxval(Map<String,Object> inputs, Map<String,Object> output) {
        
        System.debug('::: argsINput'+inputs);
        List<Object> args = (List<Object>)inputs.get('arguments');
        String statecode = String.valueOf(args[0]);
        
        string dpienv = [select DPI_Environment__c from State_DPI_environment_mappings__mdt where State_Code__c = :statecode limit 1].DPI_Environment__c;
        list<ftr_PSRExchangeDetail__c> psrex = [select id,FICT_NPA__c,FICT_NXX__c from ftr_PSRExchangeDetail__c where DPI_Env__c = :dpienv limit 1];
        string npanxxvalue = psrex[0].FICT_NPA__c + psrex[0].FICT_NXX__c;
        
        output.put('result', npanxxvalue);
        
        
        return true;  
    }
    
    private Boolean getenvironval(Map<String,Object> inputs, Map<String,Object> output) {
        
        System.debug('::: argsINput'+inputs);
        List<Object> args = (List<Object>)inputs.get('arguments');
        String statecode = String.valueOf(args[0]);
        
        string dpienv = [select DPI_Environment__c from State_DPI_environment_mappings__mdt where State_Code__c = :statecode limit 1].DPI_Environment__c;
        //list<ftr_PSRExchangeDetail__c> psrex = [select id,FICT_NPA__c,FICT_NXX__c from ftr_PSRExchangeDetail__c where DPI_Env__c = :dpienv limit 1];
        //string npanxxvalue = psrex[0].FICT_NPA__c + psrex[0].FICT_NXX__c;
        
        output.put('result', dpienv);
        
        
        return true;  
    }    
}