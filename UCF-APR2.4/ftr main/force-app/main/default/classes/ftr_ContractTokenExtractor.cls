global with sharing class ftr_ContractTokenExtractor implements vlocity_cmt.VlocityOpenInterface2 

//Created by Eagle Creek. Modified from Vlocity sample code for Token extraction of CLM Contract data.
//main method getTokenData takes the Contract Id as input. Uses SOQL queries to find all relevent Token data for Vlocity Document Templates related to Contract
//Designed as one-size-fits-all solution to pull data for all contracts covered by this release.


/**
 * VLOCITY, INC. CONFIDENTIAL
 * __________________
 *
 *  2014-[Current Year] Vlocity, Inc.
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Vlocity, Inc. and its suppliers,
 * if any. The intellectual and technical concepts contained
 * herein are proprietary to Vlocity, Inc. and its suppliers and may be
 * covered by U.S. and Foreign Patents, patents in process, and are
 * protected by trade secret or copyright law. Dissemination of this
 * information and reproduction, modification or reverse-engineering
 * of this material, is prohibited unless prior written permission
 * is obtained from Vlocity, Inc.


 * CustomHybridTokenDataExtractor
 * Sample implementation that can be used to create custom extraction of Contract and
 * ContractLineItems using DataRaptor for header information and direct queries for
 * line items.
 */
{   
    /**
     *
     */
    private static final Integer DEFAULT_PAGE_OFFSET = 200;
    
    /**
     * Message used when DataRaptor processing encountered any error
     */
    private static final String ERROR_DR_MESSAGE = 'Error encountered while processing request. Please check log for details.';

    /**
     * Message used when method name supplied is not 'getTokenData'
     */
    private static final String ERROR_UNSUPPORTED = 'Unsupported method. Only method [getTokenData] is supported.';

    /**
     * Specify the DataRaptor Extractor for header data
     */
    private static final String DR_EXTRACT_HEADER = 'CC7 Custom Class Docx Header Extract';

    /**
     * Specify the namespace prefix of deployed package
     */
    private static final String NAMESPACE_PREFIX = 'vlocity_cmt__';
    
    /**
     * 
     */
    private static final String QUERY_DRMAP_ITEM;
    
    /**
     * 
     */
    private static final String COUNT_CONTRACT_LINES;
    
    /**
     * 
     */
    private static final String QUERY_CONTRACT_DETAILS;
    
    /**
     * 
     */
    private static final String QUERY_INITIAL_CONTRACT_LINES;
    
    /**
     * 
     */
    private static final String QUERY_SUCCEEDING_CONTRACT_LINES;  
     
    /**
     * Initialize queries to be used to include namespace prefix
     */
    static
    {
        String queryContractLines = 
            'SELECT count() ' +
            'FROM $nmspc$ContractLineItem__c ' +
            'WHERE $nmspc$ContractId__c=:contractId';
        COUNT_CONTRACT_LINES = queryContractLines.replace('$nmspc$', NAMESPACE_PREFIX);
        
        String queryDrMapItem = 
            'SELECT Id, $nmspc$FilterValue__c ' +
            'FROM $nmspc$DRMapItem__c ' +
            'WHERE $nmspc$FilterOperator__c=\'LIMIT\' AND Name=:extractDR';
        QUERY_DRMAP_ITEM = queryDrMapItem.replace('$nmspc$', NAMESPACE_PREFIX);
        
        String queryInitialContractLines =
            'SELECT Id, Name, $nmspc$Quantity__c, $nmspc$OneTimeTotal__c, $nmspc$RecurringTotal__c ' +
            'FROM $nmspc$ContractLineItem__c ' +
            'WHERE ($nmspc$ContractId__c =: contractId) ' +
            'ORDER BY Id ' +
            'LIMIT :pageOffset';
        QUERY_INITIAL_CONTRACT_LINES = queryInitialContractLines.replace('$nmspc$', NAMESPACE_PREFIX);
        
        String querySucceedingContractLines = 
            'SELECT Id, Name, $nmspc$Quantity__c, $nmspc$OneTimeTotal__c, $nmspc$RecurringTotal__c ' +
            'FROM $nmspc$ContractLineItem__c ' +
            'WHERE ($nmspc$ContractId__c =: contractId AND Id >: lastItemId) ' +
            'ORDER BY Id ' +
            'LIMIT :pageOffset';
        QUERY_SUCCEEDING_CONTRACT_LINES = querySucceedingContractLines.replace('$nmspc$', NAMESPACE_PREFIX);
    }
    
    /**
     * 
     */
    global Object invokeMethod(
        String methodName, 
        Map<String, Object> input,
        Map<String, Object> output, 
        Map<String, Object> options) 
    {
        Boolean success = false;
            
        System.debug('invokeMethod112:methodName -> ' + methodName);
        System.debug('invokeMethod112:input-> ' + input);
		System.debug('methodName1121: ' + methodName);
        if (methodName == 'getTokenData') 
        {
    		System.debug('inside getTokenData 05');
            success = getTokenData(input, output, options);
        } 
        else 
        {
            throw new CustomHybridTokenDataExtractorException(ERROR_UNSUPPORTED);
        }

        System.debug('invokeMethod:output -> ' + output);
        System.debug('invokeMethod:success -> ' + success);
        return true;
    }

	private Boolean getTokenData(
        Map<String, Object> input, 
        Map<String, Object> output, 
        Map<String, Object> options)
    {  
		System.debug('inside getTokenData 10');
        Id contractId = (Id) input.get('contextId');
        Map<String, Object> tokenData = new Map<String, Object>();
        Contract contractObj = [select Id, ContractTerm, CLM_Signing_Order__c, Phone__c, Schedule_Type__c, ScheduleID__c, StartDate, Account.BillingCity,
            Account.BillingPostalCode, Account.BillingState, Account.BillingStreet, Single_Point_of_Contact_SPOC__r.Name, 
            Account.Name, Account.ShippingCity, Account.ShippingPostalCode, Account.ShippingState, Account.ShippingStreet,
            Total_One_Time_Charge__c, vlocity_cmt__RecurringTotal__c, vlocity_cmt__QuoteId__r.QuoteNumber,
            vlocity_cmt__QuoteId__c, vlocity_cmt__QuoteId__r.Schedule_Date__c, FSA_Start_Date__c, Account.Company_Legal_Name__c,
            Account.Legal_City__c, Account.Legal_Zip__c, Account.Legal_State__c, Account.Legal_Street__c, Account.vlocity_cmt__BillingEmailAddress__c, Account.Primary_ACNA__c,
            Account.State_of_Formation__c, Account.Type_of_Entity__c, Account.Account_Owner_Email__c, PNUM__c, CLM_Contract_Term_Years__c, Requested_Install_Date__c, vlocity_cmt__OpportunityId__r.Contracted_Units_Number__c,
            Account.Channel_Affiliations__c, Account.Website, Account.Phone          
            from Contract where ID =:contractId];
        
        List<vlocity_cmt__ContractLineItem__c> ContractLineItems = [select ID, Name, vlocity_cmt__Product2Id__r.Name, vlocity_cmt__Product2Id__r.Description,
            vlocity_cmt__Product2Id__c, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.Quantity__c,SterlingQuoteLineItem__c,
            SterlingQuoteLineItem__r.Service_Address__c,SterlingQuoteLineItem__r.Locality__c, SterlingQuoteLineItem__r.StateProvince__c ,SterlingQuoteLineItem__r.Postcode__c,
            SterlingQuoteLineItem__r.NPA__c, SterlingQuoteLineItem__r.NPA_NXX__c,
            Template_Name__c, vlocity_cmt__OnetimeCharge__c, vlocity_cmt__Quantity__c,vlocity_cmt__RecurringTotal__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__ProductDescription__c
            from vlocity_cmt__ContractLineItem__c  where vlocity_cmt__ContractId__c =:contractId Order By SterlingQuoteLineItem__r.StateProvince__c, SterlingQuoteLineItem__r.Locality__c,SterlingQuoteLineItem__r.Service_Address__c ];

        List<Contract_Document_Token_Data__c> ContractFreeFormData = [select ID, Name,Token_Name__c, Token_Data_Type__c, Token_Value__c from Contract_Document_Token_Data__c where Contract__c =:contractId];
                                                                    
        System.debug('inside getTokenData 15');
        if (contractObj != null){
            String OneTimeTotal = add2Decimals(contractObj.Total_One_Time_Charge__c);
            //String RecurringTotal = add2Decimals(contractObj.vlocity_cmt__RecurringTotal__c);
            //system.Debug('OneTimeTotal: ' + OneTimeTotal );
           
            
            
            tokenData.put('ContractTerm', contractObj.ContractTerm);
            tokenData.put('Phone', contractObj.Phone__c);
            tokenData.put('ScheduleType', contractObj.Schedule_Type__c);
            tokenData.put('ScheduleId', contractObj.ScheduleID__c);
            try {
            	tokenData.put('Effective_Date', Date.valueOf(contractObj.StartDate).format());
            } catch (Exception ex) {
            	tokenData.put('Effective_Date', String.valueof(Date.valueOF(contractObj.StartDate))); 
            }
            tokenData.put('BillingCity', contractObj.Account.BillingCity);
            tokenData.put('BillingPostalCode', contractObj.Account.BillingPostalCode);
            tokenData.put('BillingState', contractObj.Account.BillingState);
            tokenData.put('BillingStreet', contractObj.Account.BillingStreet);
            tokenData.put('SPOC', contractObj.Single_Point_of_Contact_SPOC__r.Name);
            tokenData.put('Subscriber_Name', contractObj.Account.Name);
            tokenData.put('ServiceCity', contractObj.Account.ShippingCity);
            tokenData.put('ServicePostalCode', contractObj.Account.ShippingPostalCode);
            tokenData.put('ServiceState', contractObj.Account.ShippingState);
            tokenData.put('ServiceStreet', contractObj.Account.ShippingStreet);
            tokenData.put('OneTimeTotal', OneTimeTotal);
            //tokenData.put('RecurringTotal', RecurringTotal); //moved to below line item tags
            tokenData.put('Schedule_Date', String.Valueof(Date.valueOF(contractObj.StartDate)));
            tokenData.put('QuoteNumber', contractObj.vlocity_cmt__QuoteId__r.QuoteNumber);
            tokenData.put('QuoteId',contractObj.vlocity_cmt__QuoteId__c);
            
            //Added for Release 2
            tokenData.put('FSA_StartDate',String.valueof(Date.valueOF(contractObj.FSA_Start_Date__c)));
            tokenData.put('Legal_Name',contractObj.Account.Company_Legal_Name__c);
            tokenData.put('LegalCity',contractObj.Account.Legal_City__c);
            tokenData.put('LegalPostalCode',contractObj.Account.Legal_Zip__c);
            tokenData.put('LegalState',contractObj.Account.Legal_State__c);
            tokenData.put('LegalStreet',contractObj.Account.Legal_Street__c);
            tokenData.put('StateCompanyFormed',contractObj.Account.State_of_Formation__c);
            tokenData.put('Entity_Type',contractObj.Account.Type_of_Entity__c);
            tokenData.put('BillingEmail',contractObj.Account.vlocity_cmt__BillingEmailAddress__c);
            tokenData.put('PropertyOwnerEmail',contractObj.Account.Account_Owner_Email__c);
            tokenData.put('ACNA',contractObj.Account.Primary_ACNA__c);
            tokenData.put('PNUM',contractObj.PNUM__c);
            tokenData.put('ContractTermYrs', contractObj.CLM_Contract_Term_Years__c);
            tokenData.put('RequestedInstallDate', String.valueof(Date.valueOF(contractObj.Requested_Install_Date__c)));
            tokenData.put('ContractUnits', contractObj.vlocity_cmt__OpportunityId__r.Contracted_Units_Number__c);
            tokenData.put('Channel', contractObj.Account.Channel_Affiliations__c);
            tokenData.put('Website', contractObj.Account.Website);
            tokenData.put('AccPhone', contractObj.Account.Phone);
            
            DateTime dtTime = DateTime.now();
            tokenData.put('PreSignCreatedDate', dtTime.format('MM/dd/yyyy'));
            
            // signer options
            String signingOrder = contractObj.CLM_Signing_Order__c;
            if (signingOrder == 'Frontier 1st, Customer 2nd') 
            {
	            tokenData.put('Signer2Title','{{Ttl_es_:signer1:title}}');
    	        tokenData.put('Signer2Signature','{{Sig_es_:signer1:signature}}');
        	    tokenData.put('Signer2FullName','{{N_es_:signer1:fullname}}');
            	tokenData.put('Signer2Date','{{Dte_es_:signer1:date}}');

            	tokenData.put('Signer1Title','{{Ttl_es_:signer2:title}}');
            	tokenData.put('Signer1Signature','{{Sig_es_:signer2:signature}}');
            	tokenData.put('Signer1FullName','{{N_es_:signer2:fullname}}');
            	tokenData.put('Signer1Date','{{Dte_es_:signer2:date}}');
                
            } 
            else if (signingOrder == 'Customer Only') 
            {
	            tokenData.put('Signer1Title','{{Ttl_es_:signer1:title}}');
    	        tokenData.put('Signer1Signature','{{Sig_es_:signer1:signature}}');
        	    tokenData.put('Signer1FullName','{{N_es_:signer1:fullname}}');
            	tokenData.put('Signer1Date','{{Dte_es_:signer1:date}}');

                tokenData.put('Signer2Title','');
            	tokenData.put('Signer2Signature','');
            	tokenData.put('Signer2FullName','');
            	tokenData.put('Signer2Date','');
                
            } 
            else if (signingOrder == 'Frontier Only')
            {
	            tokenData.put('Signer2Title','{{Ttl_es_:signer1:title}}');
    	        tokenData.put('Signer2Signature','{{Sig_es_:signer1:signature}}');
        	    tokenData.put('Signer2FullName','{{N_es_:signer1:fullname}}');
            	tokenData.put('Signer2Date','{{Dte_es_:signer1:date}}');

   	            tokenData.put('Signer1Title','');
     	        tokenData.put('Signer1Signature','');
        	    tokenData.put('Signer1FullName','');
            	tokenData.put('Signer1Date','');
            } 
            else // Customer 1st, Frontier 2nd
            {
	            tokenData.put('Signer1Title','{{Ttl_es_:signer1:title}}');
    	        tokenData.put('Signer1Signature','{{Sig_es_:signer1:signature}}');
        	    tokenData.put('Signer1FullName','{{N_es_:signer1:fullname}}');
            	tokenData.put('Signer1Date','{{Dte_es_:signer1:date}}');

            	tokenData.put('Signer2Title','{{Ttl_es_:signer2:title}}');
            	tokenData.put('Signer2Signature','{{Sig_es_:signer2:signature}}');
            	tokenData.put('Signer2FullName','{{N_es_:signer2:fullname}}');
            	tokenData.put('Signer2Date','{{Dte_es_:signer2:date}}');
            }
          	
            if (ContractFreeFormData != null && ContractFreeFormData.size()>0){
                for (Contract_Document_Token_Data__c FFD : ContractFreeFormData){
                    if(FFD.Token_Value__c != null || FFD.Token_Value__c != '') {
                    	if (FFD.Token_Data_Type__c == 'Boolean') {
                            if (FFD.Token_Value__c == 'Yes' || FFD.Token_Value__c == 'true' ||  FFD.Token_Value__c == 'Y' ) {
                           		tokenData.put(FFD.Token_Name__c, true);
                        	} else {
                           		tokenData.put(FFD.Token_Name__c, false);
                        	}
                    	} else {
                       		tokenData.put(FFD.Token_Name__c, FFD.Token_Value__c);
                        }
                    }
                }
             }
            
            
            
            if (ContractLineItems != null && ContractLineItems.size()>0){
                decimal grandTotalMRC = 0.00;
                decimal grandTotalNRC = 0.00;
                List<Object> ServAddresses = new List <Object>();
                set<string> AdressStrSet = new set<String>();
                //create list of service addreses.
                for (vlocity_cmt__ContractLineItem__c CLI : ContractLineItems){
                    if (CLI.SterlingQuoteLineItem__c != null && CLI.SterlingQuoteLineItem__r.Locality__c != null){
                        AdressStrSet.add(CLI.SterlingQuoteLineItem__r.Service_Address__c+CLI.SterlingQuoteLineItem__r.Locality__c+CLI.SterlingQuoteLineItem__r.StateProvince__c+CLI.SterlingQuoteLineItem__r.Postcode__c);
                    } 
                }
                for (String SAaddrStr : AdressStrSet){
                    List<Object> xProducts = new List <Object>();
                    map<String,Object> ServAddressMap = new map<String,Object>();
                    string LIServiceStreet;
                    string LIServiceCity;
                    string LIServiceState;
                    string LIServicePostalCode;
                    decimal saOneTimeTotal = 0.00;
                    decimal saRecurringTotal = 0.00;
                    for (vlocity_cmt__ContractLineItem__c CLI : ContractLineItems){
                        Map<string,object> ContractLI = new Map<string,object>();
                        if (CLI.SterlingQuoteLineItem__c != null && SAaddrStr == CLI.SterlingQuoteLineItem__r.Service_Address__c+CLI.SterlingQuoteLineItem__r.Locality__c+CLI.SterlingQuoteLineItem__r.StateProvince__c+CLI.SterlingQuoteLineItem__r.Postcode__c){
                            LIServiceStreet = CLI.SterlingQuoteLineItem__r.Service_Address__c;
                            if (CLI.SterlingQuoteLineItem__r.Locality__c != null) LIServiceCity =  ', ' + CLI.SterlingQuoteLineItem__r.Locality__c;
                            if (CLI.SterlingQuoteLineItem__r.StateProvince__c != null) LIServiceState =  ', ' + CLI.SterlingQuoteLineItem__r.StateProvince__c;
                            if (CLI.SterlingQuoteLineItem__r.Postcode__c != null) LIServicePostalCode= ', ' + CLI.SterlingQuoteLineItem__r.Postcode__c;
                            if (CLI.SterlingQuoteLineItem__r.NPA__c != null) ContractLI.put('NPA', ', ' + CLI.SterlingQuoteLineItem__r.NPA__c);
                            if (CLI.SterlingQuoteLineItem__r.NPA_NXX__c != null) ContractLI.put('NPANXX', ', ' + CLI.SterlingQuoteLineItem__r.NPA_NXX__c);
                             //add 2 decimal places to currency fields
                            String OneTimeCharge = add2Decimals(CLI.vlocity_cmt__OnetimeCharge__c);
                           	//decimal TotalNRC = CLI.vlocity_cmt__OnetimeCharge__c;
                            saOneTimeTotal += CLI.vlocity_cmt__OnetimeCharge__c;
                           
                            //replaced recurring charge with recurring total JIRA#34929
                            //String RecurringCharge = add2Decimals(CLI.vlocity_cmt__RecurringCharge__c);
                            String RecurringCharge = add2Decimals(CLI.vlocity_cmt__RecurringTotal__c);
                            decimal TotalMRC = CLI.vlocity_cmt__RecurringTotal__c * CLI.vlocity_cmt__Quantity__c;
                            saRecurringTotal += TotalMRC;
                            
                            ContractLI.put('Product2Name', CLI.Name );
                            ContractLI.put('ProductName', CLI.vlocity_cmt__Product2Id__r.Name);
                            ContractLI.put('ProductDescription2', CLI.vlocity_cmt__Product2Id__r.Description );
                            ContractLI.put('Product2Id', CLI.vlocity_cmt__Product2Id__c );
                            ContractLI.put('Product2Code', CLI.vlocity_cmt__Product2Id__r.ProductCode );
                            ContractLI.put('TemplateName', CLI.Template_Name__c );
                            ContractLI.put('OneTimeCharge', OneTimeCharge);
                            //ContractLI.put('TotalNRC',TotalNRC);
                            ContractLI.put('Quantity', CLI.vlocity_cmt__Quantity__c );
                            ContractLI.put('RecurringCharge', RecurringCharge);
                            ContractLI.put('TotalMRC',add2Decimals(TotalMRC));
                            ContractLI.put('ProductDescription', CLI.vlocity_cmt__ProductDescription__c );
                            xProducts.add(ContractLI);
                        }  
                    }
                    grandTotalNRC += saOneTimeTotal;
                    grandTotalMRC += saRecurringTotal;
                    ServAddressMap.put('saOneTimeTotal',add2Decimals(saOneTimeTotal));
                    ServAddressMap.put('saRecurringTotal',add2Decimals(saRecurringTotal));
                    ServAddressMap.put('LIServiceStreet',LIServiceStreet);
                    ServAddressMap.put('LIServiceCity',LIServiceCity);
                    ServAddressMap.put('LIServiceState',LIServiceState);
                    ServAddressMap.put('LIServicePostalCode',LIServicePostalCode);
                    ServAddressMap.put('Product',xProducts);
                    ServAddresses.add(ServAddressMap);
                }
                tokenData.put('LIServiceAddress',ServAddresses);
                //tokenData.put('OneTimeTotal', add2Decimals(grandTotalNRC));
                tokenData.put('RecurringTotal', add2Decimals(grandTotalMRC));
                

                /*
                for (vlocity_cmt__ContractLineItem__c CLI : ContractLineItems){
                    //add 2 decimal places to currency fields
                    String OneTimeCharge = add2Decimals(CLI.vlocity_cmt__OnetimeCharge__c);
                   
                  //replaced recurring charge with recurring total JIRA#34929
                  String RecurringCharge = add2Decimals(CLI.vlocity_cmt__RecurringTotal__c);
                //String RecurringCharge = add2Decimals(CLI.vlocity_cmt__RecurringCharge__c);
                    
                    
                    Map<string,object> ContractLI = new Map<string,object>();
                    ContractLI.put('Product2Name', CLI.Name );
                    ContractLI.put('ProductName', CLI.vlocity_cmt__Product2Id__r.Name);
                    ContractLI.put('ProductDescription2', CLI.vlocity_cmt__Product2Id__r.Description );
                    ContractLI.put('Product2Id', CLI.vlocity_cmt__Product2Id__c );
                    ContractLI.put('Product2Code', CLI.vlocity_cmt__Product2Id__r.ProductCode );
                    ContractLI.put('TemplateName', CLI.Template_Name__c );
                    ContractLI.put('OneTimeCharge', OneTimeCharge);
                    ContractLI.put('Quantity', CLI.vlocity_cmt__Quantity__c );
                    ContractLI.put('RecurringCharge', RecurringCharge);
                    ContractLI.put('ProductDescription', CLI.vlocity_cmt__ProductDescription__c );
                    if (CLI.SterlingQuoteLineItem__c != null){
                        ContractLI.put('LIServiceStreet', CLI.SterlingQuoteLineItem__r.Service_Address__c);
                        if (CLI.SterlingQuoteLineItem__r.Locality__c != null) ContractLI.put('LIServiceCity', ', ' + CLI.SterlingQuoteLineItem__r.Locality__c);
                        if (CLI.SterlingQuoteLineItem__r.StateProvince__c != null) ContractLI.put('LIServiceState', ', ' + CLI.SterlingQuoteLineItem__r.StateProvince__c);
                        if (CLI.SterlingQuoteLineItem__r.Postcode__c != null) ContractLI.put('LIServicePostalCode', ', ' + CLI.SterlingQuoteLineItem__r.Postcode__c);
                        if (CLI.SterlingQuoteLineItem__r.NPA__c != null) ContractLI.put('NPA', ', ' + CLI.SterlingQuoteLineItem__r.NPA__c);
                        if (CLI.SterlingQuoteLineItem__r.NPA_NXX__c != null) ContractLI.put('NPANXX', ', ' + CLI.SterlingQuoteLineItem__r.NPA_NXX__c);
                    }                
                    xProducts.add(ContractLI);
                }
                tokenData.put('Product',xProducts);*/
            }
           
        }
        
        output.put('tokenMap',tokenData);
		System.debug('inside getTokenData 20');
        System.debug('HUNTING:' + tokenData.get('HUNTING'));
        return true;        
    }
    public static string add2Decimals(Decimal deci){
        String strDec = String.valueof(deci);  
        if (strDec != null && strDec.length()>0){
            strDec = String.valueof(deci);
            if (!strDec.contains('.')){
                strDec += '.00';
            }
            else if (strDec.split('\\.')[1].length() == 1){
                strDec += '0';
            }
        }
        
        return strDec;
    }
    /**
     *
     *
    private Boolean getTokenData1(
        Map<String, Object> input, 
        Map<String, Object> output, 
        Map<String, Object> options)
    {        
        Boolean success = false;
        
        Id contractId = (Id) input.get('contextId');
                
        if (!input.containsKey('tokenDataQueryInfo')) 
        {
            success = getContractTokenData(input, output, options);
        } 
        else 
        {
            success = getContractItemsTokenData(input, output, options);
        }
        
        System.debug('getTokenData:success -> ' + success);
        return success;
    }*/
    
    /**
     *
     
    private Boolean getContractTokenData(
        Map<String, Object> input, 
        Map<String, Object> output, 
        Map<String, Object> options)
    { 
        Boolean success = false;
        
        Id contractId = (Id) input.get('contextId');
        
        List<Map<String, Object>> DRinputs = new List<Map<String, Object>>();
        Map<String, Object> DRinput = new Map<String, Object>();
        
        DRinput.put('Id', contractId); 
        DRinputs.add(DRinput);
        
        vlocity_cmt.DRProcessResult drProcessResult = vlocity_cmt.DRGlobal.process(DRInputs, DR_EXTRACT_HEADER);
        System.debug('getContractTokenData:drProcessResult ->' + drProcessResult);
        
        if (!drProcessResult.hasErrors())
        {
            Map<String, Object> paginationInformation = initializePaginationInfo(contractId);
            Integer totalItems = (Integer) paginationInformation.get('totalItems');  
            output.put('hasMoreTokenData', totalItems > 0);
            output.put('tokenMap', drProcessResult.toJson());
            output.put('tokenDataQueryInfo', paginationInformation);

            success = true;
        }
        else 
        {
            throw new CustomHybridTokenDataExtractorException(ERROR_DR_MESSAGE);
        }
        
        System.debug('getContractTokenData:output -> ' + output);
        System.debug('getContractTokenData:success -> ' + success);
        return success;
    }*/
    
    /**
     *
     
    private Boolean getContractItemsTokenData(
        Map<String, Object> input, 
        Map<String, Object> output, 
        Map<String, Object> options)
    { 
        Boolean success = false;
        
        Id contractId = (Id) input.get('contextId');
        
        Map<String, Object> paginationInformation = 
            (Map<String, Object>) Json.deserializeUntyped((String) input.get('tokenDataQueryInfo'));
        
        Id lastItemId = (Id) paginationInformation.get('lastItemId');
        Integer recordNumber = (Integer) paginationInformation.get('recordNumber');
        Integer totalItems = (Integer) paginationInformation.get('totalItems');
        Integer pageOffset = (Integer) paginationInformation.get('pageOffset');
        
        List<vlocity_cmt__ContractLineItem__c> lineItems = getContractLineItems(contractId, lastItemId, pageOffset);
        
        vlocity_cmt__ContractLineItem__c lastItem = lineItems.get(lineItems.size()-1);
        paginationInformation.put('lastItemId', lastItem.Id);
        paginationInformation.put('recordNumber', recordNumber += pageOffset);
        
        output.put('tokenMap', extractContractLineItemDetails(lineItems));
        output.put('tokenDataQueryInfo', paginationInformation);
        output.put('hasMoreTokenData', (totalItems > recordNumber ? true : false));
        
        System.debug('getContractItemsTokenData:output -> ' + output);
        System.debug('getContractItemsTokenData:success -> ' + success);
        return success;
    }*/
    
    /**
   
     
    private List<vlocity_cmt__ContractLineItem__c> getContractLineItems(Id contractId, Id lastItemId, Integer pageOffset)
    {
        List<vlocity_cmt__ContractLineItem__c> lineItems = null;
        if (lastItemId == null)
        {
            lineItems = Database.query(QUERY_INITIAL_CONTRACT_LINES);
        }
        else 
        {
            lineItems = Database.query(QUERY_SUCCEEDING_CONTRACT_LINES);
        }

        System.debug('getContractLineItems() lineItems -> ' + lineItems);           
        return lineItems;
    }*/
    
    /**
     * 
     
    private Map<String, Object> extractContractLineItemDetails(List<vlocity_cmt__ContractLineItem__c> lineItems) 
    {
        List<Map<String, Object>> lineItemDetails = new List<Map<String, Object>>();  
        
        for (vlocity_cmt__ContractLineItem__c lineItem : lineItems)
        {
            
            String quantity = String.valueOf(lineItem.get(NAMESPACE_PREFIX + 'Quantity__c'));
            String oneTimeTotal = String.valueOf(lineItem.get(NAMESPACE_PREFIX + 'OneTimeTotal__c'));
            String recurringTotal = String.valueOf(lineItem.get(NAMESPACE_PREFIX + 'RecurringTotal__c'));
            
            quantity = (null==quantity) ? '' : quantity;
            oneTimeTotal = (null==oneTimeTotal) ? '' : oneTimeTotal;
            recurringTotal = (null==recurringTotal) ? '' : recurringTotal;
            
            Map<String, Object> lineItemDetail = new Map<String, Object>();
            lineItemDetail.put('name', String.valueOf(lineItem.get('Name')));
            lineItemDetail.put('quantity', quantity);
            lineItemDetail.put('oneTimeTotal', oneTimeTotal);
            lineItemDetail.put('recurringTotal', recurringTotal);
            
            lineItemDetails.add(lineItemDetail);
        }
        
        Map<String, Object> tokenData = new Map<String, Object>();
        tokenData.put('line_item', lineItemDetails);
        
        return tokenData;
    }*/
    
    /**
     *
     
    private Boolean updateHasMoreData(Map<String, Object> pageInfo) 
    {
        Integer totalItems = (Integer) pageInfo.get('totalItems');
        Integer recordNumber = (Integer) pageInfo.get('recordNumber');
        
        Boolean hasMoreData = totalItems > recordNumber ? true : false;
        
        System.debug('updateHasMoreData:hasMoreData -> ' + hasMoreData);
        return hasMoreData;
    }*/
    
    /**
     *
     
    private void updatePageOffset(Map<String, Object> pageInfo) 
    {
        Integer pageOffset = (Integer) pageInfo.get('pageOffset');
        Integer recordNumber = (Integer) pageInfo.get('recordNumber');
        
        Integer nextPageOffset = recordNumber + pageOffset;
        
        System.debug('updatePageOffset:nextPageOffset -> ' + nextPageOffset);
        pageInfo.put('recordNumber', nextPageOffset);
    } */
    
    /**
     *
     
    private Map<String, Object> initializePaginationInfo(Id contractId) 
    { 
        Integer totalItems = countContractItems(contractId);
            
        Map<String, Object> paginationInformation = new Map<String, Object>();
        paginationInformation.put('queryHeader', true);
        paginationInformation.put('queryLine', true);
        paginationInformation.put('recordNumber', 0);
        paginationInformation.put('pageOffset', DEFAULT_PAGE_OFFSET);
        paginationInformation.put('totalItems', totalItems);
        
        System.debug('initializePaginationInfo:paginationInformation -> ' + paginationInformation);
        return paginationInformation;
    }*/
    
    /**
     *
     
    private Integer countContractItems(Id contractId) 
    {
        Integer contractItems = Database.countQuery(COUNT_CONTRACT_LINES);
        
        System.debug('countContractItems:contractItems -> ' + contractItems);
        return contractItems;
    }*/

    /**
     *
     */
    class CustomHybridTokenDataExtractorException extends Exception {
        
    }
}