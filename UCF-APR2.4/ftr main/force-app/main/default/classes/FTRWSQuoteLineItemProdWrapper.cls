public with sharing class FTRWSQuoteLineItemProdWrapper implements comparable {
//public with sharing class FTRWSQuoteLineItemProdWrapper {
    public String rfqString { get; set; }
    public String serviceAddress { get; set; } //zAddress
    public String zAddress { get; set; }
    public String name { get; set; }
    public String minorProdName { get; set; }
    public String prodType { get; set; }
    public String serviceType { get; set; }
    public String speed { get; set; }
    public String qos { get; set; }
    public String circuitType { get; set; }
    public String tier { get; set; }
    public String pNUM { get; set; }
    public String termLength { get; set; }
    public Decimal totalMRC { get; set; }
    public Decimal totalNRC { get; set; }
    public Decimal totalCharge { get; set; }
    public Decimal nrc { get; set; }
    public String id { get; set; }
    public Integer quantity { get; set; }  
    public Decimal renewalMRR { get; set; }
    public Decimal netNewMRR { get; set; }
    public Decimal cpenrc { get; set; }
    public Decimal adjustedNRC { get; set; }
    public Integer orderSeq { get; set; }
    
    public List<FTRWSQuoteLineItemProdWrapper> minorProductsList {get;set;}
    
    
    public FTRWSQuoteLineItemProdWrapper() {
        //prodType = 'EIA';
    }
    
    public FTRWSQuoteLineItemProdWrapper(
        SterlingQuoteItem__c sqi,
        OpportunityLineItem oli,
        Map<Id, List<ZAddress__c>> sterlingQuoteItemIdByZAddressList
    ) {
        this.init(sqi, oli);
    }
    public FTRWSQuoteLineItemProdWrapper(SterlingQuoteItem__c sqi, OpportunityLineItem oli) {
        this.init(sqi, oli);
    }
    
    public Integer compareTo(Object obj) {
        FTRWSQuoteLineItemProdWrapper wrapperObject = (FTRWSQuoteLineItemProdWrapper)(obj);
        Integer objOrderSeq = 0;
        Integer orderSequence = 0;    
        
        if(wrapperObject.orderSeq != null)   
        {
            objOrderSeq=wrapperObject.orderSeq;
        }
        
        if(this.orderSeq != null )   
        {
            orderSequence = this.orderSeq;
        }    
        if (orderSequence > objOrderSeq) {
            return 1;
        }
        
        if (orderSequence == objOrderSeq) {
            return 0;
        }
        return -1;
    }
    
    private static Decimal getValueOrZeroIfNull(Decimal d) {
        return d == null ? 0 : d.setScale(2);
    }    
    public static String getTermLengthInYears(Integer term, String displayTerm) {
        if(displayTerm == 'MTM') {
            return displayTerm;
        }
        
        if(term == null) {
            return '';
        }
        String year = 'yr';
        String returnVal = '';
        if (term == 12){
            returnVal = '1';
        }else if (term == 24) {
            returnVal = '2';
        }else if (term == 36) {
            returnVal = '3';
        }else if (term == 48) {
            returnVal = '4';
        }else if (term == 60) {
            returnVal = '5';
        }else if (term == 0) {
            return 'MTM';
        }
        
        if(returnVal != null && returnVal != '') {
        	returnVal = returnVal + year;
            return returnVal;
        }
        
        return '';
    }
    
    private void setProductAttributes(String prodName) {
        
        List<Product2> prodList = [Select id, name, evcspeed__c, Family from Product2 where name =: prodName and isActive = TRUE and recordType.Name = 'Carrier Service'];
        
        if(prodList == null || prodList.size() < 1) {
            return;
        } else {
            Product2 prod = prodList.get(0);
        System.debug('WS Prod attributes: ' + prod);
        if(!String.isBlank(prod.evcspeed__c)) {
        	this.speed = prod.evcspeed__c;    
        }
        if(!String.isBlank(prod.Family)) {
        	this.prodType = prod.Family;    
        }
            
        }
        
    }
    
    private void init(SterlingQuoteItem__c sqi, OpportunityLineItem oli) {
        id = sqi.Id;
        quantity = Integer.valueof(sqi.Quantity__c);
        
        Integer term = Integer.valueof(sqi.TermLength__c);

		String displayTerm = sqi.Display_Term__c;
        
        termLength = getTermLengthInYears(term, displayTerm);    
        
        renewalMRR = getValueOrZeroIfNull(sqi.Renewal_MRR_Original__c);
        netNewMRR = getValueOrZeroIfNull(sqi.NetNewMRR__c);
        nrc = getValueOrZeroIfNull(oli.NRC_Price__c);
        totalNRC = getValueOrZeroIfNull(oli.NRC_Price__c) * Quantity;
        name = oli.Product2.Name;
        
        adjustedNRC = getValueOrZeroIfNull(sqi.AdjustedNRC__c);
        cpenrc = getValueOrZeroIfNull(oli.CPE_NRC_Price__c);
        nrc = getValueOrZeroIfNull(oli.NRC_Price__c);
        totalNRC = getValueOrZeroIfNull(oli.NRC_Price__c) * Quantity;
        
        qos = sqi.qos__c;
        circuitType = sqi.circuitType__c;
        
        
        //quoteitemid = sqi.id;
        //quoteRecordType = sqi.RecordType.Name;
        totalMRC = getValueOrZeroIfNull(sqi.AdjustedMRC__c);
        totalCharge = Quantity * TotalMRC;
        serviceAddress = oli.Service_Address__c ;
        zAddress = '';
        
        String prodName = oli.Product2.Name;
        setProductAttributes(prodName);
        
        tier = sqi.cvdPriceTier__c;
        pNUM = sqi.PNum__c;
        
        if('UNI' == circuitType) {
            minorProdName = prodType + ' ' + 'UNI Port & Access - ' + speed;
            orderSeq = 2;
        } else if('EVC' == circuitType) {
            minorProdName = prodType + ' ' + qos + ' EVC - Tier Rate Structure - ' + speed + ' Tier ' + tier + ' - ' + pNUM;
            orderSeq = 1;
            
        } else if('NNI' == circuitType) {
            minorProdName = prodType + ' ' + 'NNI Port & Access - ' + speed;
            orderSeq = 3;
        }else {
            minorProdName = prodName;
        }         
    }
    
    public static Decimal getTotalQuickQuoteValue(List<FTRWSQuoteLineItemProdWrapper> oppProducts) {
        Decimal res = 0;
        for (FTRWSQuoteLineItemProdWrapper op : oppProducts) {
            res += (op.RenewalMRR + op.NetNewMRR + op.NRC + op.CPENRC);
        }
        return res;
    }
    
    public static Decimal getOneTimeTotalQuickQuoteValue(List<FTRWSQuoteLineItemProdWrapper> oppProducts) {
        Decimal res = 0;
        for (FTRWSQuoteLineItemProdWrapper op : oppProducts) {
            res += (op.AdjustedNRC + op.CPENRC );
        }
        return res;
    }
    
    public static Decimal getMonthlyTotalQuickQuoteValue(List<FTRWSQuoteLineItemProdWrapper> oppProducts) {
        Decimal res = 0;
        for (FTRWSQuoteLineItemProdWrapper op : oppProducts) {
            res += (op.RenewalMRR + op.NetNewMRR );
        }
        return res;
    }
    
    public static List<FTRWSQuoteLineItemProdWrapper> getQuickQuoteWrappers(Id oppId, Id quoteId) {
        return getQuickQuoteWrappers(oppId, new Set<Id>{ quoteId });
    }
    
        //Wholesale specific info retrieved from the SterlingQUoteItem__c object
    public static String getQuoteDate(Id quoteId) {
        SterlingQuote__c quote = [Select Id, CreatedDate from SterlingQuote__c where Id =: quoteId
                                        and IsSyncing__c = true LIMIT 1];
        
        DateTime quoteDate = quote.CreatedDate;
		return quoteDate.format('MM-dd-yyyy');
    }
    
    //Wholesale specific info retrieved from the OpportunityLineItem object
    public static Map<Id, OpportunityLineItem> getOpportunityLineItemsMapFromOpportunity(String oppId) {
        return  new Map<Id, OpportunityLineItem>([SELECT Id, 
                            Renewal_MRR__c, 
                            UnitPrice,
                            Speed__c,                      
                            CPE_Gross_Margin__c, 
                            CPE_NRC_Price__c, 
                            NRC_Price__c, 
                            Product2.name, 
                            AdjustedMRC__c, 
                            QuoteId__c, 
                            Service_Address__c, 
                            ZAddress__c 
                        FROM OpportunityLineItem 
                        WHERE Opportunityid = :oppId
                        order by CreatedDate]);
    }
    
    //Wholesale specific info retrieved from the SterlingQUoteItem__c object
    public static List<SterlingQuoteItem__c> getQuoteItemsFromQuotes(Set<Id> quoteIds) {
        return [SELECT Id,
                RecordType.Name,
                Products__r.name, 
                Renewal_MRR_Original__c, 
                NetNewMRR__c, 
                CurrentStatus__c, 
                StandardMRC__c, 
                AdjustedNRC__c, 
                AdjustedMRC__c, 
                OverallStatus__c, 
                Quantity__c, 
                IsPromoProduct__c, 
                TermLength__c, 
                Display_Term__c,
                NumInstallments__c, 
                DiscountType__c, 
                OpportunityLineItemId__c, 
                Products__c, 
                ApprovalRouting__c, 
                NoICB__c, 
                Part_Number__c, 
                Category__c,
                qos__c,
                circuitType__c,
                PNum__c,
                cvdPriceTier__c,
                StateProvince__c
                
                FROM SterlingQuoteItem__c 
                WHERE SterlingQuote__c IN :quoteIds
                order by CreatedDate];        
    }
    
    
    public static List<FTRWSQuoteLineItemProdWrapper> getQuickQuoteWrappers(Id oppId, Set<Id> quoteIds) {
        List<FTRWSQuoteLineItemProdWrapper> wrapperOppProducts = new List<FTRWSQuoteLineItemProdWrapper>();
        
        List<FTRWSQuoteLineItemProdWrapper> ethernetWrapperOppProducts = new List<FTRWSQuoteLineItemProdWrapper>();
        
        List<SterlingQuoteItem__c> quoteItems = getQuoteItemsFromQuotes(quoteIds);

        Map<Id, OpportunityLineItem> mapOppLineItems = getOpportunityLineItemsMapFromOpportunity(oppId);
        
        if (quoteItems.size() > 0 && !mapOppLineItems.isEmpty()) {
            for (SterlingQuoteItem__c sqi : quoteItems) {
                if (mapOppLineItems.containsKey(sqi.OpportunityLineItemId__c) && mapOppLineItems.get(sqi.OpportunityLineItemId__c) != null) {
                    OpportunityLineItem oli = mapOppLineItems.get(sqi.OpportunityLineItemId__c);
                    FTRWSQuoteLineItemProdWrapper wrapperProd = new FTRWSQuoteLineItemProdWrapper(sqi, oli);
                    System.debug('wrapper prod built: ' + wrapperProd);
                    
                    if(!String.isBlank(wrapperProd.circuitType)) {
                        String circuitType = wrapperProd.circuitType;
                        if(circuitType == 'EVC' || circuitType == 'UNI' || circuitType == 'NNI') {
                            ethernetWrapperOppProducts.add(wrapperProd);
                        }
                    } else {
                    	wrapperOppProducts.add(wrapperProd);    
                    }
                    
                }
            }
        }
        
        List<FTRWSQuoteLineItemProdWrapper> finalOppProdList = new List<FTRWSQuoteLineItemProdWrapper>();
        if(wrapperOppProducts != null && wrapperOppProducts.size() > 0) {
            List<FTRWSQuoteLineItemProdWrapper> nonEthernetProdList = processNonEthernetProducts(wrapperOppProducts);
            finalOppProdList.addAll(nonEthernetProdList);
        }
        
        if(ethernetWrapperOppProducts != null && ethernetWrapperOppProducts.size() > 0) {
            List<FTRWSQuoteLineItemProdWrapper> ethernetProdList = processEthernetProducts(ethernetWrapperOppProducts);
            finalOppProdList.addAll(ethernetProdList);
        }
        
        return finalOppProdList;
    }
    
    private static List<FTRWSQuoteLineItemProdWrapper> processNonEthernetProducts(List<FTRWSQuoteLineItemProdWrapper> wrapperOppProducts) {
        
        List<FTRWSQuoteLineItemProdWrapper> parentProdList = new List<FTRWSQuoteLineItemProdWrapper>();
        
        Map<String, List<FTRWSQuoteLineItemProdWrapper>> qqWrapperMap = 
            new Map<String, List<FTRWSQuoteLineItemProdWrapper>>();
        
       if (wrapperOppProducts != null) {
            for (FTRWSQuoteLineItemProdWrapper w : wrapperOppProducts) {
                w = getOppProductToAdd(w);
                if (w != null) {
                    String key = w.name + '##' + w.serviceAddress + '##'+ w.termLength;
                    System.debug('parent prod key: ' + key);
                    if(qqWrapperMap.containsKey(key)) {
                        List<FTRWSQuoteLineItemProdWrapper>listWrapper = qqWrapperMap.get(key);
                        listWrapper.add(w);
                    } else {
                        List<FTRWSQuoteLineItemProdWrapper>listWrapper = new List<FTRWSQuoteLineItemProdWrapper>();
                        listWrapper.add(w);
                        qqWrapperMap.put(key, listWrapper);
                    }
                }
            }
        }
        
        if(qqWrapperMap != null && qqWrapperMap.size() > 0) {
            for(String key : qqWrapperMap.keySet()) {
                String[] tokens = key.split('##');
                String name = tokens[0];
                String svcAddress = tokens[1];
                String termLength = '';
                if(tokens.size() > 2) {
                    termLength = tokens[2]; 
                }
                
                FTRWSQuoteLineItemProdWrapper parentProd = new FTRWSQuoteLineItemProdWrapper();
                parentProd.serviceAddress = svcAddress;
                parentProd.name = name;
                List<FTRWSQuoteLineItemProdWrapper> minorProductsList = qqWrapperMap.get(key);
                minorProductsList.sort();
                parentProd.minorProductsList = minorProductsList;
                parentProd.prodType = parentProd.minorProductsList.get(0).prodType;
                parentProd.speed = parentProd.minorProductsList.get(0).speed;
                parentProd.termLength = parentProd.minorProductsList.get(0).termLength;
                Decimal parentNetNewMRR = 0.0;
                Decimal parentRenewalMRR = 0.0;
                Decimal parentAdjustedNRC = 0.0;
                Decimal parentCPENRC = 0.0;
                for(FTRWSQuoteLineItemProdWrapper minorProd : parentProd.minorProductsList) {
                    /*if((minorProd.circuitType == 'EVC' || minorProd.circuitType == 'UNI' || minorProd.circuitType == 'NNI' ) ) {
                        if(minorProd.circuitType == 'EVC' ) {
                        	parentProd.qos = minorProd.qos;    
                        }
                        
                        parentProd.serviceType = 'Ethernet';
                    } else {
                         parentProd.serviceType = minorProd.prodType;
                    }*/
                    
                    parentProd.serviceType = minorProd.prodType;
                    parentNetNewMRR = parentNetNewMRR + minorProd.NetNewMRR;
                    parentRenewalMRR = parentRenewalMRR + minorProd.RenewalMRR;
                    parentAdjustedNRC = parentAdjustedNRC +minorProd.AdjustedNRC;
                    parentCPENRC = parentCPENRC + minorProd.CPENRC;
                }
                
                //NetNewMRR+sqitem.RenewalMRR
                //AdjustedNRC+sqitem.CPENRC
                
                parentProd.NetNewMRR = parentNetNewMRR;
                parentProd.RenewalMRR = parentRenewalMRR;
                parentProd.AdjustedNRC = parentAdjustedNRC;
                parentProd.CPENRC = parentCPENRC;                
                
                parentProdList.add(parentProd);
            }
        }
        System.debug('Non-Ethernet ParentProdList:' + parentProdList);
        return parentProdList;
         
    }

    
    public static List<FTRWSQuoteLineItemProdWrapper> processEthernetProducts(List<FTRWSQuoteLineItemProdWrapper> ethernetWrapperProducts) {
        List<FTRWSQuoteLineItemProdWrapper> parentProdList = new List<FTRWSQuoteLineItemProdWrapper>();
        
       Map<String, List<FTRWSQuoteLineItemProdWrapper>> qqWrapperMap = 
            new Map<String, List<FTRWSQuoteLineItemProdWrapper>>();
        
       if (ethernetWrapperProducts != null) {
            for (FTRWSQuoteLineItemProdWrapper w : ethernetWrapperProducts) {
                w = getOppProductToAdd(w);
                if (w != null) {
                    String key = w.name + '##' + w.serviceAddress + '##'+ w.termLength +'##' + w.qos;
                    System.debug('parent prod key: ' + key);
                    if(qqWrapperMap.containsKey(key)) {
                        List<FTRWSQuoteLineItemProdWrapper>listWrapper = qqWrapperMap.get(key);
                        listWrapper.add(w);
                    } else {
                        List<FTRWSQuoteLineItemProdWrapper>listWrapper = new List<FTRWSQuoteLineItemProdWrapper>();
                        listWrapper.add(w);
                        qqWrapperMap.put(key, listWrapper);
                    }
                }
            }
        }  
        
        
        
        //////////////////////////////////////////////////////
        if(qqWrapperMap != null && qqWrapperMap.size() > 0) {
            for(String key : qqWrapperMap.keySet()) {
                String[] tokens = key.split('##');
                String name = tokens[0];
                String svcAddress = tokens[1];
                String termLength = tokens[2];
                String qos = tokens[3];
                FTRWSQuoteLineItemProdWrapper parentProd = new FTRWSQuoteLineItemProdWrapper();
                parentProd.serviceAddress = svcAddress;
                parentProd.name = name;
                List<FTRWSQuoteLineItemProdWrapper> minorProductsList = qqWrapperMap.get(key);
                minorProductsList.sort();
                parentProd.minorProductsList = minorProductsList;
                parentProd.prodType = parentProd.minorProductsList.get(0).prodType;
                parentProd.speed = parentProd.minorProductsList.get(0).speed;
                parentProd.termLength = parentProd.minorProductsList.get(0).termLength;
                
                Decimal parentNetNewMRR = 0.0;
                Decimal parentRenewalMRR = 0.0;
                Decimal parentAdjustedNRC = 0.0;
                Decimal parentCPENRC = 0.0;

                for(FTRWSQuoteLineItemProdWrapper minorProd : parentProd.minorProductsList) {
                    parentProd.serviceType = 'Ethernet';
                    parentProd.qos = qos;
                    parentNetNewMRR = parentNetNewMRR + minorProd.NetNewMRR;
                    parentRenewalMRR = parentRenewalMRR + minorProd.RenewalMRR;
                    parentAdjustedNRC = parentAdjustedNRC +minorProd.AdjustedNRC;
                    parentCPENRC = parentCPENRC + minorProd.CPENRC;
                }
                
                //NetNewMRR+sqitem.RenewalMRR
                //AdjustedNRC+sqitem.CPENRC
                
                parentProd.NetNewMRR = parentNetNewMRR;
                parentProd.RenewalMRR = parentRenewalMRR;
                parentProd.AdjustedNRC = parentAdjustedNRC;
                parentProd.CPENRC = parentCPENRC;                
                
                parentProdList.add(parentProd);
            }
        }
        System.debug('Ethernet ParentProdList:' + parentProdList);
        
        return parentProdList;
    }
    
    public static FTRWSQuoteLineItemProdWrapper getOppProductToAdd(FTRWSQuoteLineItemProdWrapper w) {
        if (isNotAdditionalChargeProduct(w) && isNotDiscounted(w)) {
            w.name = removeChallengerAndLeader(w.name);
            return w;
        }
        return null;
    }
    
    public static Boolean isNotAdditionalChargeProduct(FTRWSQuoteLineItemProdWrapper w) {
        return (!w.name.contains('Surcharge') &&
                !w.name.contains('Tax') &&
                !w.name.contains('Installation') &&
                !w.name.contains('Credit') &&
                !w.name.contains('Charge'));
    }
    
    public static Boolean isNotDiscounted(FTRWSQuoteLineItemProdWrapper w) {
        //return (w.OverallStatus == 'Approved' || w.DiscountType == '' || w.DiscountType == null || w.DiscountType == 'None');
        return true;
    }
    
    public static String removeChallengerAndLeader(String productName) {
        return productName.replace(' - Challenger', '').replace(' - Leader', '').replace('Challenger', '').replace('Leader', '');
    }    
}