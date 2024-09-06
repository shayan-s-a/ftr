/**
 * @description       :
 * @author            : 
 * @group             :
 * @last modified on  : 
 * @last modified by  : 
 * Modifications Log
 * Ver   Date         Author        Modification
 **/
public with sharing class Quote_Line_Item_Product_Wrapper {
    public String status { get; set; } 
    public String name { get; set; }
    public Integer quantity { get; set; }
    public String isPromoProduct { get; set; }
    public String serviceAddress { get; set; }
    public String zAddress { get; set; }
    public Integer termLength { get; set; }
    public Integer numInstallments { get; set; }
    public Decimal renewalMRR { get; set; }
    public Decimal netNewMRR { get; set; }
    public Decimal sumRenewNetNewMRR { get; set; }
    public Decimal adjustedNRC { get; set; }
    public Decimal cpeGrossMargin { get; set; }
    public Decimal cpenrc { get; set; }
    public Decimal nrc { get; set; }
    public string quoteitemid { get; set; }
    public Decimal totalMRC { get; set; }
    public Decimal totalNRC { get; set; }
    public Decimal totalCharge { get; set; }
    public String discountType { get; set; }
    public String overallStatus { get; set; }
    public boolean isSubmitted { get; set; }
    public boolean isPending { get; set; }
    public boolean isApproved { get; set; }
    public String id { get; set; }
    public boolean isDiscountTypeEmpty { get; set; }
    public boolean isICB { get; set; }
    public boolean isEmptyStatus { get; set; }
    public boolean isRecalled { get; set; }
    public boolean isstatus { get; set; }
    public boolean isshow { get; set; }
    public boolean isfinance { get; set; }
    public String quoteRecordType { get; set; }
    public String category { get; set; }
    public String partNumber { get; set; }
    public Boolean lightningRecordtype {get; set;}
    public string Block { get; set; }  // SDDD-4452/SDDD-4429 Add Block
    public string OverageRate { get; set; }  // SDDD-4452/SDDD-4429 Add OverageRate
    public string HandOff { get; set; } // SDDD-4452/SDDD-4429 Add HandOff
    public Decimal UnitPrice { get; set; }
    public string Partnered { get; set; } //
    
    public Quote_Line_Item_Product_Wrapper() {
        name = 'test';
    }
    public Quote_Line_Item_Product_Wrapper(
        SterlingQuoteItem__c sqi,
        OpportunityLineItem oli,
        Map<Id, List<ZAddress__c>> sterlingQuoteItemIdByZAddressList
    ) {
        this.init(sqi, oli);
    }
    public Quote_Line_Item_Product_Wrapper(SterlingQuoteItem__c sqi, OpportunityLineItem oli) {
        this.init(sqi, oli);
    }
    // method added to show Vlocity products in QuickQuote PDF
    public Quote_Line_Item_Product_Wrapper(OpportunityLineItem oli) {
        this.Quantity = (Integer) oli.Quantity;
        this.Name = String.isBlank(oli.Speed__c) ? oli.Product2.Name : oli.Product2.Name + ' ' + oli.Speed__c;
        this.ServiceAddress = oli.vlocity_cmt__ServiceAccountId__r.Name;
        this.TermLength = (Integer) oli.Term_Months__c;
        // Start Case 838120 SDDD-4452/SDDD-4429
        if(oli.vlocity_cmt__JSONAttribute__c !=null && oli.vlocity_cmt__JSONAttribute__c !=''){            
            Map<String, Object> myAttrVals = ftr_CpqHelper.getJSONAttributeValues(oli.vlocity_cmt__JSONAttribute__c);
            // Add Block Additional
            if(myAttrVals.containsKey('ATTR_MIN_BLOCKS')){                
                this.Block = String.valueof(myAttrVals.get('ATTR_MIN_BLOCKS'));
            }
            // Add OVERAGE_RATE 
            if(myAttrVals.containsKey('ATTR_OVERAGE_RATE')){ //if((Decimal)myAttrVals.get('ATTR_OVERAGE_RATE')!=null )               
                this.OverageRate= String.valueof(myAttrVals.get('ATTR_OVERAGE_RATE'));
            }
            // Add Block Include
            if(myAttrVals.containsKey('ATTR_INC_LD_BOT')){                
                this.Block = String.valueof(myAttrVals.get('ATTR_INC_LD_BOT'));                
            }
            // Add Hand Off
            if(myAttrVals.containsKey('ATTR_PBX_HAND_OFF')){             
                this.HandOff = String.valueof(myAttrVals.get('ATTR_PBX_HAND_OFF'));
            }
            // Add Partnered Keyword
            if(myAttrVals.containsKey('ATTR_ELIGBL_PARTNRD')){             
                this.Partnered = String.valueof(myAttrVals.get('ATTR_ELIGBL_PARTNRD'));
                system.debug('partner-- '+this.Partnered);
                if( this.Partnered == 'true'){
                   this.Name = this.Name + ' ' + 'Partnered'; 
                }
            }
                                    
        }
        this.UnitPrice = (Decimal) oli.UnitPrice;
        // End SDDD-4452/SDDD-4429 
        this.AdjustedNRC = oli.vlocity_cmt__OneTimeCharge__c;
        this.NetNewMRR = oli.CPQ_NetNewMRR__c;
        this.RenewalMRR = oli.Renewal_MRR__c;
        this.NRC = oli.vlocity_cmt__OneTimeCharge__c;
        this.CPENRC = oli.CPE_NRC_Price__c;
        this.quoteRecordType = 'Vlocity';
        this.sumRenewNetNewMRR = this.NetNewMRR + this.RenewalMRR;
        System.debug('----sumRenewNetNewMRR------'+this.sumRenewNetNewMRR +'-----AdjustedNRC----'+this.AdjustedNRC +'----CPENRC----'+this.CPENRC );
        System.debug('----oli----'+oli);
       // if(oli.ftr_isApplyDiscount__c && oli.Product2.ProductCode  == 'ENT_ETH_EIA_0002' ){
        if(oli.ftr_isApplyDiscount__c ){
            this.sumRenewNetNewMRR = oli.ftr_DiscountPrice__c == null ? 0.00 : oli.ftr_DiscountPrice__c;
            if(oli.ftr_isApplyDiscount__c && oli.Product2.ProductCode  == 'ENT_ETH_EIA_0002' ){
            this.Name = String.isBlank(oli.Speed__c) ? 'DIA Bundle' : 'DIA Bundle ' + oli.Speed__c;
        }
        }
        
    }

    private static Decimal getValueOrZeroIfNull(Decimal d) {
        return d == null ? 0 : d.setScale(2);
    }

    private void init(SterlingQuoteItem__c sqi, OpportunityLineItem oli) {
        id = sqi.Id;
        category = sqi.Category__c;
        partNumber = sqi.Part_Number__c;
        status = sqi.CurrentStatus__c;
        quantity = Integer.valueof(sqi.Quantity__c);
        isPromoProduct = String.Valueof(sqi.IsPromoProduct__c).ToUppercase() == 'TRUE' ? 'Yes' : 'No';
        termLength = Integer.valueof(sqi.TermLength__c);
        numInstallments = Integer.valueof(sqi.NumInstallments__c);
        discountType = sqi.DiscountType__c;
        renewalMRR = getValueOrZeroIfNull(sqi.Renewal_MRR_Original__c);
        netNewMRR = getValueOrZeroIfNull(sqi.NetNewMRR__c);
        cpeGrossMargin = getValueOrZeroIfNull(oli.CPE_Gross_Margin__c);
        adjustedNRC = getValueOrZeroIfNull(sqi.AdjustedNRC__c);
        cpenrc = getValueOrZeroIfNull(oli.CPE_NRC_Price__c);
        nrc = getValueOrZeroIfNull(oli.NRC_Price__c);
        totalNRC = getValueOrZeroIfNull(oli.NRC_Price__c) * Quantity;
        name = oli.Product2.Name;
        overallStatus = sqi.OverallStatus__c;
        quoteitemid = sqi.id;
        quoteRecordType = sqi.RecordType.Name;
        totalMRC = getValueOrZeroIfNull(sqi.AdjustedMRC__c);
        totalCharge = Quantity * TotalMRC;
        serviceAddress = oli.Service_Address__c;
        zAddress = oli.ZAddress__c;   // added as part of SDDD-2207 
        isFinance = sqi.Currentstatus__c == 'Pending - Finance' || sqi.Currentstatus__c == 'Pending - Business Decision Support';
        sumRenewNetNewMRR = NetNewMRR + RenewalMRR;
        if (sqi.Overallstatus__c == 'Pending') {
            isSubmitted = true;
            isPending = false;
        }

        isApproved = false;
        isRecalled = false;
        if (sqi.OverallStatus__c == 'Approved') {
            isApproved = true;
        } else if (sqi.OverallStatus__c == 'Recalled' || sqi.OverallStatus__c == 'Rejected') {
            isRecalled = true;
        }

        isEmptyStatus = sqi.OverallStatus__c == '' || sqi.OverallStatus__c == null;

        isDiscountTypeEmpty = false;
        isICB = false;

        if (String.isNotBlank(sqi.DiscountType__c) && sqi.DiscountType__c != 'None') {
            if ((sqi.DiscountType__c == 'BDT') || (sqi.DiscountType__c == 'CTR')) {
                isICB = true;
            }
            if (sqi.DiscountType__c == 'ICBA') {
                isICB = false;
                isEmptyStatus = false;
            }
            if (sqi.DiscountType__c == 'CTRA') {
                isICB = false;
                isEmptyStatus = false;
            }
            if (sqi.NoICB__c == true) {
                isICB = false;
            }
        } else {
            isDiscountTypeEmpty = true;
        }
    }

    public static Boolean isNotAdditionalChargeProduct(Quote_Line_Item_Product_Wrapper w) {
        return (!w.name.contains('Surcharge') &&
        !w.name.contains('Tax') &&
        !w.name.contains('Installation') &&
        !w.name.contains('Credit') &&
        !w.name.contains('Charge'));
    }

    public static Boolean isNotDiscounted(Quote_Line_Item_Product_Wrapper w) {
        return (w.OverallStatus == 'Approved' || w.DiscountType == '' || w.DiscountType == null || w.DiscountType == 'None');
    }

    public static String removeChallengerAndLeader(String productName) {
        return productName.replace(' - Challenger', '').replace(' - Leader', '').replace('Challenger', '').replace('Leader', '');
    }

    public static Quote_Line_Item_Product_Wrapper getOppProductToAdd(Quote_Line_Item_Product_Wrapper w) {
        if (isNotAdditionalChargeProduct(w) && isNotDiscounted(w)) {
            w.name = removeChallengerAndLeader(w.name);
            return w;
        }
        return null;
    }

    public static Decimal getTotalQuickQuoteValue(List<Quote_Line_Item_Product_Wrapper> oppProducts) {
        Decimal res = 0;
        for (Quote_Line_Item_Product_Wrapper op : oppProducts) {
            res += (op.RenewalMRR + op.NetNewMRR + op.NRC + op.CPENRC);
            System.debug('----res----0---'+res);
            System.debug('----op.RenewalMRR---'+op.RenewalMRR+ '---- op.NetNewMRR---'+ op.NetNewMRR +'---op.NRC----'+op.NRC +'---op.CPENRC---'+op.CPENRC );
        }
        System.debug('----res----1'+res);
        return res;
    }
    
    public static Decimal getOneTimeTotalQuickQuoteValue(List<Quote_Line_Item_Product_Wrapper> oppProducts) {
        Decimal res = 0;
        for (Quote_Line_Item_Product_Wrapper op : oppProducts) {
            res += (op.AdjustedNRC + op.CPENRC );
        }
        System.debug('----res----2'+res);
        return res;
    }
    
    public static Decimal getMonthlyTotalQuickQuoteValue(List<Quote_Line_Item_Product_Wrapper> oppProducts) {
        Decimal res = 0;
        for (Quote_Line_Item_Product_Wrapper op : oppProducts) {
            res += op.sumRenewNetNewMRR;
        }
        System.debug('----res---------3'+res);
        return res;
    }
    
    public static List<Quote_Line_Item_Product_Wrapper> getQuickQuoteWrappers(Id oppId, Id quoteId) {
        return getQuickQuoteWrappers(oppId, new Set<Id>{ quoteId });
    }

    public static List<Quote_Line_Item_Product_Wrapper> getQuickQuoteWrappersWithVlocityProducts(Id oppId, Id quoteId, Id vlocityQuoteId) {
        return getQuickQuoteWrappers(oppId, new Set<Id>{ quoteId, vlocityQuoteId });
    }

    public static List<Quote_Line_Item_Product_Wrapper> getQuickQuoteWrappers(Id oppId, Set<Id> quoteIds) {
        List<Quote_Line_Item_Product_Wrapper> wrapperOppProducts = new List<Quote_Line_Item_Product_Wrapper>();
        List<Quote_Line_Item_Product_Wrapper> quickQuoteWrappers = new List<Quote_Line_Item_Product_Wrapper>();
        List<SterlingQuoteItem__c> quoteItems = SterlingQuoteUtility.getQuoteItemsFromQuotes(quoteIds);
        
        Map<Id, OpportunityLineItem> mapOppLineItems = Opportunity_Line_Item_Utility.getOpportunityLineItemsMapFromOpportunity(oppId);
        if (quoteItems.size() > 0 && !mapOppLineItems.isEmpty()) {
            for (SterlingQuoteItem__c sqi : quoteItems) {
                if (mapOppLineItems.containsKey(sqi.OpportunityLineItemId__c) && mapOppLineItems.get(sqi.OpportunityLineItemId__c) != null) {
                    OpportunityLineItem oli = mapOppLineItems.get(sqi.OpportunityLineItemId__c);
                    wrapperOppProducts.add(new Quote_Line_Item_Product_Wrapper(sqi, oli));
                }
            }
        }
        if (wrapperOppProducts != null) {
            for (Quote_Line_Item_Product_Wrapper w : wrapperOppProducts) {
                w = getOppProductToAdd(w);
                if (w != null) {
                    quickQuoteWrappers.add(w);
                }
            }
        }// SDDD-4452/SDDD-4429 Add Json Fields and ServiceAccount Order by in Query
        List<OpportunityLineItem> vlocityOpportunityLineItems = new List<OpportunityLineItem>(
            [
                SELECT
                    Id,
                    Quantity,                    
                    Term_Months__c,
                    DiscountType__c,
                    Renewal_MRR__c,
                    CPQ_NetNewMRR__c,
                    CPE_Gross_Margin__c,
                    AdjustedMRC__c,
                    CPE_NRC_Price__c,
                    Speed__c,
                    UnitPrice,
                    vlocity_cmt__JSONAttribute__c,
                    vlocity_cmt__OneTimeCharge__c,
                    Product2.Name,
                    vlocity_cmt__RecurringCharge__c,
                    vlocity_cmt__ServiceAccountId__r.Name,
                    opportunity.recordtype.name,
                    ftr_isApplyDiscount__c, 
                    Product2.ProductCode, 
                    ftr_DiscountPrice__c
                FROM OpportunityLineItem
                WHERE OpportunityId = :oppId AND Opportunity_Sync__c = 'Vlocity' order by vlocity_cmt__ServiceAccountId__r.Name
            ]
        );
         if (vlocityOpportunityLineItems.size() > 0 && (vlocityOpportunityLineItems[0].opportunity.recordtype.name == 'Opportunity Lightning' || 
                                                        vlocityOpportunityLineItems[0].opportunity.recordtype.name == 'Partner Opportunity - New')) {
            for (OpportunityLineItem oli : vlocityOpportunityLineItems) {                                                
                quickQuoteWrappers.add(new Quote_Line_Item_Product_Wrapper(oli));
            }
        }
        return quickQuoteWrappers;
    }
}