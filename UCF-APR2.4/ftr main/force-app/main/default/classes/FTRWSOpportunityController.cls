public class FTRWSOpportunityController {
    
    @AuraEnabled
    public static List<WrapperOpportunityProduct> getSterlingQuoteItems(String strOpportunityId) {
        System.debug('<=>x1.strOpportunityId :'+strOpportunityId);
        SterlingQuote__c quote = [Select ID,MRC__c,NRC1__c	 from SterlingQuote__c where OpportunityId__c=:strOpportunityId and IsSyncing__c = true];
        String strSterlingQuoteId = quote.Id;
        System.debug('<=>x2.quote :'+quote);
        List<WrapperOpportunityProduct> lstWrapperOppProduct = new List<WrapperOpportunityProduct>();
          Map<Id,FTRWSAddress__c> ftrwsAddressMap = new Map<Id,FTRWSAddress__c>();
        Map<Id,FTRWSCVDRate__c> ftrwsCvdratesMap = new Map<Id,FTRWSCVDRate__c>();
        Set<Id> AddressIds = new Set<Id>(); 
        //     removed at line no 23        Products__r.evcspeed__c,
        list<SterlingQuoteItem__c> lststrquoteitem = [
            SELECT
            Id,
            RecordType.Name,
            Products__r.name,
            Renewal_MRR_Original__c,
            NetNewMRR__c,
              Name,
            PNum__c,
			Products__r.evcspeed__c,
            ST_AddressID__c,
               StandardNRC__c,
            CurrentStatus__c,
            StandardMRC__c,
            AdjustedNRC__c,
            AdjustedMRC__c,
            OverallStatus__c,
            Quantity__c,
            ItemCode__c,
            IsPromoProduct__c,
            Display_Term__c,
            TermLength__c,
            NumInstallments__c,
            DiscountType__c,
            OpportunityLineItemId__c,
            Products__c,
            ApprovalRouting__c,
            NoICB__c,
            Part_Number__c,
            Category__c,
            circuitType__c,
            cvdPriceTier__c,
            cvdratesource__c,
            SterlingQuote__c,MTSO_LATA__c,UMTS_MTSO__c,Need_by_Date__c,UNI_NNI_Speed__c,UNI_NNI_Type__c,
            Display_NRC__c,
            Display_MRC__c, 
            CIAC__C,
            CRT__C,
            Allocated_Total_Capex__c,
            NPV_Net_Present_Value__c,
            Cvdrates_Id__c,	// added extra Field ,
            Fiber_Cost__c,Splicing_Cost__c,Equipment_Cost__c,Guardrail_Cost__c,IRR_Internal_Rate_of_Return__c,HBE_Max_Qos__c,HBE_Max_Speed__c
            FROM SterlingQuoteItem__c
            WHERE SterlingQuote__c = :strSterlingQuoteId
            order by createdDate
        ];
        System.debug('<=>lststrquoteitem :'+lststrquoteitem);
        /*
        for(SterlingQuoteItem__c qii: lststrquoteitem)
        {
            System.debug('<=>CRT__c :'+qii.CRT__c);
            System.debug('<=>CIAC__c :'+qii.CIAC__c);
            System.debug('<=>NPV_Net_Present_Value__c :'+qii.NPV_Net_Present_Value__c);
            System.debug('<=>IRR_Internal_Rate_of_Return__c :'+qii.IRR_Internal_Rate_of_Return__c);
            System.debug('<=>AT_T_MRC__c :'+qii.AT_T_MRC__c);
            System.debug('<=>AT_T_Date__c :'+qii.AT_T_Date__c);            
        }

        */

        list<OpportunityLineItem> lstOppLineItem = [
            SELECT
            id,
            Renewal_MRR__c,
            UnitPrice,
            CPE_Gross_Margin__c,
            CPE_NRC_Price__c,
            NRC_Price__c,
            Product2.name,
            AdjustedMRC__c,
            QuoteId__c,
            Service_Address__c,
            ZAddress__c,
            Speed__c,
            SNE_Code_OTC__c
            FROM OpportunityLineItem
            WHERE Opportunityid = :strOpportunityId
            order by createdDate
        ];
        System.debug('<=>22.lstOppLineItem :'+lstOppLineItem);
        for (SterlingQuoteItem__c SQI : lststrquoteitem) {
            AddressIds.add(SQI.ST_AddressID__c);
            system.debug('@@AddressIds'+AddressIds);
            system.debug('<=>44.SQI : '+SQI);
        }
        // modified the below line added extra field
        for(FTRWSAddress__c add : [select id,
                                   Name,Street__c,Address__c,City__c,G_Latitude__c,G_Longitude__c,Longitude__c,Latitude__c,
                                   State__c,Unit_Number__c,Zip_Code__c,Comments__c, DPI_Qualified__c,DSAT_Qualified__c, 
                                   In_Footprint__c,WireCenter_CLLI__c,Max_Qos__c,
								   DSAT_Max_Speed__c,Copper_Qualification__c,Copper_Tier__c,Fiber_Qualification__c,Fiber_Tier__c,Id__c,
                                   Fiber_Distance__c,Address_Lost_checkbox__c,Address_Lost_checkbox_Address_Lost_reaso__c,CS_LATA__c,
                                   Site_ID__c,Alt_Site_Name__c,Interconnect_Lata__c,Interconnect_CLLI__c,County__c,UMTS_MTSO__c,
                                   MTSO_LATA__c, UNI_NNI_Speed__c,UNI_NNI_Type__c,Need_by_Date__c, CRT__c,	CIAC__c, 
                                   NPV_Net_Present_Value__c, 
                                   IRR_Internal_Rate_of_Return__c, AT_T_MRC__c, AT_T_Date__c , Future_HBE_WC_Speed__c, Planned_HBE_Timeframe__c,
                                   Plan_Id__c, New_Fiber_Build_Footage__c, CO_to_Site_Total_Footage__c, Splicing_Cost__c, 
                                   Servable__c, Review_Reason__c, Review_Status__c, Route_Notes__c, Splice_Count_Splice_Locations__c, SWC_CLLI__c,Guardrail_Cost__c
                                   
                                   from FTRWSAddress__c where id IN: AddressIds ])
        {
            ftrwsAddressMap.put(add.id,add);
        }
        
         for(FTRWSCVDRate__c cvdrates : [select id,Notes__c,ACNA__c,Level_of_service__c from FTRWSCVDRate__c where FTRWSAddress__c IN: AddressIds ]){
            ftrwsCvdratesMap.put(cvdrates.id,cvdrates);
        }
        
        map<id, OpportunityLineItem> mapOppLineItem = new Map<id, OpportunityLineItem>();
        
        for (OpportunityLineItem opp : lstOppLineItem) {
            mapOppLineitem.put(opp.id, opp);
            system.debug('###opp' + opp);
        }
        System.debug('<=> lststrquoteitem.size():'+lststrquoteitem.size());
        System.debug('<=> mapOppLineitem.isEmpty():'+mapOppLineitem.isEmpty());
        if (lststrquoteitem.size() > 0 && !mapOppLineitem.isEmpty()) { 
            System.debug('<=> 21.inside True');
            for (SterlingQuoteItem__c SQI : lststrquoteitem) {
                System.debug('<=> 21.inside LOOP');
                System.debug('<=> 21.SQI.OpportunityLineItemId__c'+SQI.OpportunityLineItemId__c);
                //SHANE FIND ME! OF THE 6 EXAMPLE SQIs, ONLY 2 HAVE OLI Id values
                if (mapOppLineItem.get(SQI.OpportunityLineItemId__c) != null) {
                    OpportunityLineItem OLI = mapOppLineItem.get(SQI.OpportunityLineItemId__c);
                     FTRWSAddress__c address= ftrwsAddressMap.get(SQI.ST_AddressID__c);
                     FTRWSCVDRate__c cvdrates= ftrwsCvdratesMap.get(SQI.Cvdrates_Id__c);
                    System.debug('<=> address :'+address);
                    System.debug('<=> cvdrates :'+cvdrates);
                    Map<Id, List<ZAddress__c>> sterlingQuoteItemIdByZAddressList = null;
                    System.debug('<=>11. SQI :'+SQI);
                    System.debug('<=>22. OLI :'+OLI);
                    System.debug('<=>33. sterlingQuoteItemIdByZAddressList :'+sterlingQuoteItemIdByZAddressList);
                    System.debug('<=>44. address :'+address);
                    System.debug('<=>55. cvdrates :'+cvdrates);
                    WrapperOpportunityProduct tempwrap = new WrapperOpportunityProduct(quote,SQI, OLI, sterlingQuoteItemIdByZAddressList,address,cvdrates);
                    lstWrapperOppProduct.add(tempwrap);
                }
            }
        }

        system.debug('lstWrapperOppProducts:' + lstWrapperOppProduct);
        return lstWrapperoppProduct;
    }
    
    
     @AuraEnabled
    public Static List<String> getSterlingQuoteItemExport(String OppId) {
        List<WrapperOpportunityProduct> lc = new List<WrapperOpportunityProduct>();   
        System.debug('<=>11.OppId :'+OppId);
        lc = getSterlingQuoteItems(OppId);
        List<String> str = new List<String>();       
        for (WrapperOpportunityProduct c : lc){            
            str.add(JSON.serialize(c));
        }
        System.debug('WrapperOpportunityProduct'+str);
        return str;
    }
    
    

    
    @AuraEnabled
    public Static SterlingQuote__c getWSQuickQuote(String strOpportunityId, String commentStr) {
        SterlingQuote__c quote = [Select ID, Status__c from SterlingQuote__c where OpportunityId__c=:strOpportunityId and IsSyncing__c = true];
        String strSterlingQuoteId = quote.Id;
        String quoteStatus = quote.Status__c;    
        if(quote != null && String.isNotBlank(quoteStatus) && (quoteStatus.equalsIgnoreCase('Rejected') || quoteStatus.equalsIgnoreCase('In Review') ||
                            quoteStatus.equalsIgnoreCase('Needs Review')) ) {
            System.debug('Quick quote cannot be generated for a quote with ' + quote.Status__c + ' status');
            return quote;
        }

        try {
            PageReference pdfPage;
            pdfPage = Page.WSCarrierSvcQuickQuote;
            
            boolean isCommentNull = false;

            
            pdfPage.getParameters().put('oid', strOpportunityId);
            if (String.isEmpty(commentStr))
                isCommentNull = true;
            else
                isCommentNull = false;
            pdfPage.getParameters().put('c', commentStr);
            pdfPage.setRedirect(true);
            Blob pdfBlob = pdfPage.getContent();
            System.debug('==========pdfBlob:' + pdfBlob);
            Attachment oAtt = new Attachment(parentId = strOpportunityId, name = 'QuickQuote.pdf', body = pdfBlob);
            insert oAtt;
            initAttachmentSection(strOpportunityId);
            
            
            //String userProfile = [SELECT Name FROM Profile WHERE Id =: userinfo.getProfileId() LIMIT 1].Name;
            
            PageReference pageRef;
            
            pageRef = new PageReference('/apex/Opportunity?Id='+strOpportunityId+'&sfdc.override=1');
            pageRef.setRedirect(true);

        } catch (Exception ex) {
            System.debug('Quick quote generation failed for reason: --' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }

        return quote;
    }

    public static void initAttachmentSection(String strOpportunityId) {
		Integer attPageSize = 5;
		List<AttachmentWrapper> lstAllAttachments = fetchAllAttachments(strOpportunityId);
		Integer attNoOfRecords = lstAllAttachments.size();
		List<AttachmentWrapper> lstAttachments = new List<AttachmentWrapper>();
		Integer attPageNumber = 1;
		integer tmpCount = attNoOfRecords / attPageSize;
		Integer attTotalPages = Math.mod(attNoOfRecords, attPageSize) > 0 ? tmpCount + 1 : tmpCount;
	}
    
    public static List<AttachmentWrapper> fetchAllAttachments(String strOpportunityId) {
		List<Id> idList = new List<Id>();
		List<AttachmentWrapper> notesAndAttachments = new List<AttachmentWrapper>();
		List<Attachment> attachments = [
			SELECT Id, Name, LastModifiedDate, CreatedById, CreatedBy.Name
			FROM Attachment
			WHERE parentId = :strOpportunityId
			ORDER BY LastModifiedDate DESC
		];
		AttachmentWrapper aw;
		if (attachments.size() > 0) {
			for (Attachment att : attachments) {
				aw = new AttachmentWrapper();
				aw.name = att.name;
				aw.typeOf = 'Attachment';
				aw.Id = att.Id + '';
				aw.LastModifiedDate = att.LastModifiedDate;
				aw.createdById = att.CreatedById + '';
				aw.urlRedirection = '/' + att.id;
				aw.createByName = att.CreatedBy.Name;
				notesAndAttachments.add(aw);
			}
		}
		List<Note> notes = [
			SELECT Id, title, LastModifiedDate, CreatedById, CreatedBy.Name
			FROM Note
			WHERE parentId = :strOpportunityId
			ORDER BY LastModifiedDate DESC
		];
		if (notes.size() > 0) {
			for (Note att : notes) {
				aw = new AttachmentWrapper();
				aw.name = att.title;
				aw.typeOf = 'Note';
				aw.Id = att.Id + '';
				aw.LastModifiedDate = att.LastModifiedDate;
				aw.createdById = att.CreatedById + '';
				aw.createByName = att.CreatedBy.Name;
				aw.urlRedirection = '/' + aw.id;
				notesAndAttachments.add(aw);
			}
		}
		return notesAndAttachments;
	}
    
    public class AttachmentWrapper {
		public String name { get; set; }
		public String typeOf { get; set; }
		public String Id { get; set; }
		public dateTime LastModifiedDate { get; set; }
		public String createdById { get; set; }
		public String createByName { get; set; }
		public String urlRedirection { get; set; }
	}
    
    //wrapper class for the products realtedlist
    public with sharing class WrapperOpportunityProduct {
        public @AuraEnabled String url {get; set;}
        public @AuraEnabled String circuitType {get; set;}
        public @AuraEnabled String cvdratesource {get; set;}
        public @AuraEnabled String Status { get; set; }
        public @AuraEnabled String Name { get; set; }
         public @AuraEnabled String EVC_Bandwidth { get; set; }
        public @AuraEnabled String Term_Aggrement { get; set; }
        public @AuraEnabled String Level_of_Service { get; set; }
         public @AuraEnabled String MRC { get; set; }
        public @AuraEnabled String Product_Id { get; set; }
         public @AuraEnabled String Product_Name { get; set; }
        public @AuraEnabled String CVD_Pnum { get; set; }
        public @AuraEnabled Integer Quantity { get; set; }
        public @AuraEnabled String IsPromoProduct { get; set; }
        //public @AuraEnabled Integer EffectiveQuantity { get; set; }
        //public @AuraEnabled Boolean isEasyPass { get; set; }
        public @AuraEnabled String ServiceAddress { get; set; }
        public @AuraEnabled String StateOrProvince { get; set; }
        public @AuraEnabled String Address_Id { get; set; }
         public @AuraEnabled String SQI_Id { get; set; }
        public @AuraEnabled String ZAddress { get; set; }
        public @AuraEnabled Integer TermLength { get; set; }
        public @AuraEnabled String DisplayTerm { get; set; }
        public @AuraEnabled Integer NumInstallments { get; set; }
        public @AuraEnabled Decimal RenewalMRR { get; set; }
        public @AuraEnabled Decimal NetNewMRR { get; set; }
        public @AuraEnabled Decimal AdjustedNRC { get; set; }
        public @AuraEnabled Decimal CPEGrossMargin { get; set; }
        public @AuraEnabled Decimal CPENRC { get; set; }
        public @AuraEnabled Decimal NRC { get; set; }
        public @AuraEnabled string quoteitemid { get; set; }
        public @AuraEnabled Decimal TotalMRC { get; set; }
        public @AuraEnabled Decimal TotalNRC { get; set; }
        public @AuraEnabled Decimal TotalCharge { get; set; }
        public @AuraEnabled String DiscountType { get; set; }
        
        public @AuraEnabled Decimal recurringTotal { get; set; }
        public @AuraEnabled Boolean isOLI { get; set; }
        
        public @AuraEnabled String quoteId { get; set; }
        //Giri 06/24/2014 Added Start
        public @AuraEnabled String OverallStatus { get; set; }
        public @AuraEnabled boolean isSubmitted { get; set; }
        public @AuraEnabled boolean isPending { get; set; }
        public @AuraEnabled boolean isApproved { get; set; }
        public @AuraEnabled String Id { get; set; }
        public @AuraEnabled boolean isDiscountTypeEmpty { get; set; }
        public @AuraEnabled boolean isICB { get; set; }
        public @AuraEnabled boolean isEmptyStatus { get; set; }
        public @AuraEnabled boolean isRecalled { get; set; }
        public @AuraEnabled boolean isstatus { get; set; }
        public @AuraEnabled boolean isshow { get; set; }
        // MMG 2/18/2015 used to control edit capability on product
        public @AuraEnabled boolean isfinance { get; set; }
        public @AuraEnabled String quoteRecordType { get; set; }
        //Giri 06/24/2014 Added End
        public @AuraEnabled String category { get; set; }
        public @AuraEnabled String partNumber { get; set; }
        public @AuraEnabled String Speed { get; set; }
        public @AuraEnabled String SnEMRC { get; set; }
        public @AuraEnabled String SnENRC { get; set; }
        public @AuraEnabled String SnECode { get; set; }
        public @AuraEnabled String noOfBusinessDays { get; set; }
        public @AuraEnabled FTRWSAddress__c ftrwsAddress { get; set; }
        public @AuraEnabled String ftrwsAddressLine { get; set; }
        public @AuraEnabled String ftrwsUnit { get; set; }
        public @AuraEnabled String ftrwsState { get; set; }
         public @AuraEnabled String ftrwsCity { get; set; }
         public @AuraEnabled String ftrwsZipcode { get; set; }
         public @AuraEnabled String ftrwsLat { get; set; }
         public @AuraEnabled String ftrwsLong { get; set; }
        public @AuraEnabled String ftrwsComments { get; set; }
        public @AuraEnabled boolean ftrwsDPIQualified { get; set; }
        public @AuraEnabled boolean ftrwsDSATQualified { get; set; }
        public @AuraEnabled boolean ftrwsInFootprint { get; set; }
        public @AuraEnabled String ftrwsWireCenterCLLI { get; set; }
        public @AuraEnabled String ftrwsMaxQos { get; set; }
        public @AuraEnabled String ftrwsDSATMaxSpeed { get; set; }
        public @AuraEnabled String ftrwsCopperQualification { get; set; }
        public @AuraEnabled String ftrwsCopperTier { get; set; }
        public @AuraEnabled String ftrwsFiberQualification { get; set; }
        public @AuraEnabled String ftrwsFiberTier { get; set; }
        public @AuraEnabled String Cvdratetier {get; set;}
         public @AuraEnabled String ftrwsNotes { get; set; }
       public @AuraEnabled String ftrwsAcna { get; set; }
        public @AuraEnabled String ftrwsLevelofservice { get; set; }
        public @AuraEnabled String ftrwsstreet { get; set; }
        // added extra values
        public @AuraEnabled String DSATID  { get; set; }
        public @AuraEnabled String FiberDistance  { get; set; }
        public @AuraEnabled Boolean AddressLost  { get; set; }
        public @AuraEnabled String AddressLostReason  { get; set; }
        public @AuraEnabled Decimal CSLATA  { get; set; }
        public @AuraEnabled String SiteID  { get; set; }
        public @AuraEnabled String AltSiteName  { get; set; }
        public @AuraEnabled Decimal InterconnectLata  { get; set; }
        public @AuraEnabled String InterconnectCLLI  { get; set; }
        public @AuraEnabled String County  { get; set; }
        public @AuraEnabled Decimal MTSOLATA  { get; set; }
        public @AuraEnabled String UMTSMTSO  { get; set; }
        public @AuraEnabled String UNI_NNISpeed  { get; set; }
        public @AuraEnabled String UNI_NNIType  { get; set; }
        public @AuraEnabled Date NeedbyDate  { get; set; }
        
        
        public @AuraEnabled String NonAdjustedMRC  { get; set; }
        public @AuraEnabled String NonAdjustedNRC  { get; set; }
        
        public @AuraEnabled String CRT  { get; set; }
        public @AuraEnabled Decimal CIAC  { get; set; }
        public @AuraEnabled Decimal IRR  { get; set; }
        public @AuraEnabled String AllocatedTotalCapex  { get; set; }
        public @AuraEnabled Decimal ATTMRC  { get; set; }
        public @AuraEnabled Date ATTDate  { get; set; } 
        public @AuraEnabled Id quoteItem  { get; set; }
        /*Changed by Vyshnavi CML-1793 Start*/
        public @AuraEnabled String FutureHBEWcSpeed  { get; set; }
        public @AuraEnabled String PlannedHBETimeframe  { get; set; }
        /*Changed by Vyshnavi CML-1793 End*/
        public @AuraEnabled Decimal splicingCost  { get; set; }
        public @AuraEnabled Decimal totalOSPCost  { get; set; }
        public @AuraEnabled String planId  { get; set; }
        public @AuraEnabled Decimal newFIberBuildFootage  { get; set; }
        public @AuraEnabled Decimal coToSiteTotalFootage  { get; set; }
        public @AuraEnabled Decimal fiberCost  { get; set; }
        public @AuraEnabled Decimal equipmentCost  { get; set; }
        public @AuraEnabled Decimal transportCost  { get; set; }
        public @AuraEnabled String servable  { get; set; }
        public @AuraEnabled String reviewReason  { get; set; }
        public @AuraEnabled String routeNotes  { get; set; }
        public @AuraEnabled Decimal spliceCount  { get; set; }
        public @AuraEnabled String reviewStatus  { get; set; }
        public @AuraEnabled String swcClli  { get; set; }
        public @AuraEnabled Decimal guardRailCost  { get; set; }
        public @AuraEnabled String HBEMaxQoS  { get; set; }
        public @AuraEnabled String HBEMaxSpeed  { get; set; }
        // newly added on 03-02-2023 by vara
        /*
        public @AuraEnabled String  ftrwsCounty  { get; set; }
        public @AuraEnabled String  ftrwsUNI_NNISpeed  { get; set; }
        public @AuraEnabled String  ftrwsUNI_NNIType  { get; set; }
        public @AuraEnabled String  ftrwsMTSOLATA  { get; set; }
        public @AuraEnabled String  ftrwsUMTSMTSO  { get; set; }
        */
        
        //  upto here
        public WrapperOpportunityProduct() {
            Name = 'test';
        }
        
        public WrapperOpportunityProduct(SterlingQuote__c quote1,
            SterlingQuoteItem__c SQI,
            OpportunityLineItem OLI,
            Map<Id, List<ZAddress__c>> sterlingQuoteItemIdByZAddressList,
             FTRWSAddress__c address,
            FTRWSCVDRate__c cvdrates
        ) {
            //category = (Math.mod((Integer)(Math.random() * 100), 4))+'';//THIS IS A TEMPORARY PLACEHOLDER FOR THE CATEGORY. RANDOMLY ASSIGNS A VALUE OF 0-3 to the section variable.
            quoteItem = SQI.Id;
            category = SQI.Category__c;
            partNumber = SQI.Part_Number__c;
            SnECode = SQI.ItemCode__c;
            isOLI = false;
            status = SQI.CurrentStatus__c;
            circuitType = SQI.circuitType__c;
            cvdratesource = SQI.cvdratesource__c;
            If(cvdrates==null){
                ftrwsNotes='';
            }
            Else{
            ftrwsNotes = cvdrates.Notes__c;
            ftrwsAcna = cvdrates.ACNA__c;
            ftrwsLevelofservice  = cvdrates.Level_of_service__c;
            }
           
            CVD_Pnum = SQI.PNum__c;
            ftrwsAddress = address;
            ftrwsAddressLine = address.Address__c;
            ftrwsUnit = address.Unit_Number__c;
            ftrwsState =address.State__c;
            ftrwsCity = address.City__c;
            ftrwsZipcode = address.Zip_Code__c;
            ftrwsLat = address.Latitude__c;
            ftrwsLong = address.Longitude__c;
            ftrwsComments = address.Comments__c;
            ftrwsDPIQualified = address.DPI_Qualified__c;
            ftrwsDSATQualified = address.DSAT_Qualified__c;
             ftrwsInFootprint = address.In_Footprint__c;
             ftrwsWireCenterCLLI = address.WireCenter_CLLI__c;
             ftrwsMaxQos = address.Max_Qos__c;
             ftrwsDSATMaxSpeed = address.DSAT_Max_Speed__c;
            ftrwsCopperQualification = address.Copper_Qualification__c;
             ftrwsCopperTier = address.Copper_Tier__c;
            ftrwsFiberQualification = address.Fiber_Qualification__c;
             ftrwsFiberTier = address.Fiber_Tier__c;
             Cvdratetier = SQI.cvdPriceTier__c;
                ftrwsstreet = address.Street__c;
           // added extra fields 
           // Mapping FTRWSAddress Values to Quote Products
            DSATID =	address.Id__c;
            FiberDistance=	address.Fiber_Distance__c;
            AddressLost =	address.Address_Lost_checkbox__c;
            AddressLostReason =	address.Address_Lost_checkbox_Address_Lost_reaso__c;
            CSLATA =	address.CS_LATA__c;
            SiteID =	address.Site_ID__c;
            AltSiteName=	address.Alt_Site_Name__c;
            InterconnectLata =	address.Interconnect_Lata__c;
            InterconnectCLLI =	address.Interconnect_CLLI__c;
            County =	address.County__c;
            MTSOLATA =	address.MTSO_LATA__c;
            UMTSMTSO =	address.UMTS_MTSO__c;
            UNI_NNISpeed =	address.UNI_NNI_Speed__c;
            UNI_NNIType =	address.UNI_NNI_Type__c;
            NeedbyDate =	address.Need_by_Date__c; 
            // |Mapping Quote Item Values to Quote Products
            CRT = SQI.CRT__c;
            CIAC = SQI.CIAC__c;
            IRR = SQI.IRR_Internal_Rate_of_Return__c;
            AllocatedTotalCapex = String.valueOf(SQI.Allocated_Total_Capex__c);
            /*Changed by Vyshnavi CML-1793 Start*/
            FutureHBEWcSpeed = address.Future_HBE_WC_Speed__c;
            PlannedHBETimeframe = address.Planned_HBE_Timeframe__c;
            /*Changed by Vyshnavi CML-1793 End*/
            splicingCost = SQI.Splicing_Cost__c;
            Decimal sCost = SQI.Splicing_Cost__c != null ? SQI.Splicing_Cost__c : 0;
            Decimal fCost = SQI.Fiber_Cost__c != null ? SQI.Fiber_Cost__c : 0;
            Decimal gCost = SQI.Guardrail_Cost__c != null ? SQI.Guardrail_Cost__c : 0;
            totalOSPCost = sCost + fCost + gCost;
            planId = address.Plan_Id__c;
            newFIberBuildFootage = address.New_Fiber_Build_Footage__c;
            coToSiteTotalFootage = address.CO_to_Site_Total_Footage__c;
            fiberCost = SQI.Fiber_Cost__c;
            equipmentCost = SQI.Equipment_Cost__c;
            guardRailCost = SQI.Guardrail_Cost__c;
            HBEMaxQoS = SQI.HBE_Max_Qos__c;
            HBEMaxSpeed = SQI.HBE_Max_Speed__c;
            servable = address.Servable__c;
            reviewReason = address.Review_Reason__c;
            reviewStatus = address.Review_Status__c;
            routeNotes = address.Route_Notes__c;
            spliceCount = address.Splice_Count_Splice_Locations__c;
            swcClli = address.SWC_CLLI__c;
            ATTMRC = address.AT_T_MRC__c;
            ATTDate  = address.AT_T_Date__c;  
            // Mapping Quote Values to Quote Products
            NonAdjustedMRC = SQI.StandardMRC__c != null ? String.valueOf(SQI.StandardMRC__c) : '0.00';
			NonAdjustedNRC = SQI.StandardNRC__c != null ? String.valueOf(SQI.StandardNRC__c) : '0.00';                        
            // upto here
              TermLength = Integer.valueof(SQI.TermLength__c);
            Switch on TermLength{
                when 0{
                    Term_Aggrement ='MTM';
                }
                when null{
                    Term_Aggrement ='MTM';
                }
                when else{
                    Integer mtoy = (TermLength)/12;
                   Term_Aggrement = String.valueof(mtoy)+' Years'; 
                }   
            }
            
            if(oli.Speed__c != null && oli.Speed__c != '') {
                Speed = oli.Speed__c;
            }
            
            if(oli.SNE_Code_OTC__c != null && oli.SNE_Code_OTC__c != '') {
                System.debug('************oli.SNE_Code_OTC__c: =======' + oli.SNE_Code_OTC__c);
            }
            
            System.debug('=========1343============OLI.Id:' + OLI.Id);
            System.debug('=========1343============OLI.QuoteId__c:' + OLI.QuoteId__c);
            Quantity = Integer.valueof(SQI.Quantity__c);
            if ((String.Valueof(SQI.IsPromoProduct__c)).ToUppercase() == 'TRUE') {
                IsPromoProduct = 'Yes';
            } else if ((String.Valueof(SQI.IsPromoProduct__c)).ToUppercase() == 'FALSE') {
                IsPromoProduct = 'No';
            }
            //IsPromoProduct= (String.Valueof(SQI.IsPromoProduct__c)).ToUppercase();
            TermLength = Integer.valueof(SQI.TermLength__c);
            DisplayTerm = SQI.Display_Term__c;
            NumInstallments = Integer.valueof(SQI.NumInstallments__c);
            DiscountType = SQI.DiscountType__c;
            
            //  if ((SQI.Renewal_MRR__c != null) && (SQI.Renewal_MRR__c != 0))
            RenewalMRR = (SQI.Renewal_MRR_Original__c == null) ? 0 : SQI.Renewal_MRR_Original__c.setScale(3);
            //  else
            //      RenewalMRR = OLI.Renewal_MRR__c;
            
            // MMG 09/09/2014 Changed to pickup adjusted price instead of list price on items.
            //if ((SQI.NetNewMRR__c != null) && (SQI.NetNewMRR__c != 0))
            NetNewMRR = (SQI.NetNewMRR__c == null) ? 0 : SQI.NetNewMRR__c.setScale(3);
            //else
            //     NetNewMRR = SQI.AdjustedMRC__c;
            
            //IF(NetNewMRR == 0)  NetNewMRR = OLI.UnitPrice;
            
            // MMG end
            CPEGrossMargin = (OLI.CPE_Gross_Margin__c == null) ? 0.00 : OLI.CPE_Gross_Margin__c.setScale(3);
            AdjustedNRC = (SQI.AdjustedNRC__c == null) ? 0.00 : SQI.AdjustedNRC__c.setScale(3);
            CPENRC = (OLI.CPE_NRC_Price__c == null) ? 0.00 : OLI.CPE_NRC_Price__c.setScale(3);
            NRC = (OLI.NRC_Price__c == null) ? 0.00 : OLI.NRC_Price__c.setScale(3);
            TotalNRC = ((OLI.NRC_Price__c == null) ? 0.00 : OLI.NRC_Price__c.setScale(3)) * Quantity;
            Name = OLI.Product2.Name;
             Product_Name = SQI.Name;
            EVC_Bandwidth = SQI.Products__r.evcspeed__c;
            Address_Id = SQI.ST_AddressID__c;
            
            Product_Id = SQI.Products__c;
            SQI_Id = SQI.SterlingQuote__c;
            if(Name.containsIgnoreCase('Platinum') && Name.containsIgnoreCase('EPATH')){
                Level_of_Service='Platinum';
            }
            else if(Name.containsIgnoreCase('Gold') && Name.containsIgnoreCase('EPATH')){
                Level_of_Service='Gold';
            }
            else if(Name.containsIgnoreCase('Silver') && (Name.containsIgnoreCase('EPATH') || Name.containsIgnoreCase('EIA'))){
                Level_of_Service='Silver';
            }
            //Giri 06/24/2014 Added Start
            OverallStatus = SQI.OverallStatus__c;
            quoteitemid = SQI.id;
            url = '/lightning/r/SterlingQuoteItem__c/' + SQI.id + '/view';
            quoteRecordType = SQI.RecordType.Name;
            TotalMRC = (SQI.AdjustedMRC__c == null) ? 0.00 : SQI.AdjustedMRC__c.setScale(3);
            TotalCharge = Quantity * TotalMRC;
            ServiceAddress = OLI.Service_Address__c;
            ZAddress = '';
            
            List<ZAddress__c> zaddrlist = new List<ZAddress__c>();
            if (sterlingQuoteItemIdByZAddressList != null && sterlingQuoteItemIdByZAddressList.size() > 0) {
                zaddrlist = sterlingQuoteItemIdByZAddressList.get(SQI.id);
            }
            //  } else {
            //    zaddrlist = [SELECT SterlingQuoteItem__c,StreetNrFirst__c,StreetName__c,StreetSuffix__c, Locality__c,StateOrProvince__c FROM ZAddress__c where  SterlingQuoteItem__c =: SQI.id];
            //  }
            if (zaddrlist != null && zaddrlist.size() > 0) {
                ZAddress = (zaddrlist[0].StreetNrFirst__c != null) ? zaddrlist[0].StreetNrFirst__c : '';
                ZAddress += (zaddrlist[0].StreetName__c != null) ? zaddrlist[0].StreetName__c : '';
                ZAddress += (zaddrlist[0].StreetSuffix__c != null) ? zaddrlist[0].StreetSuffix__c : '';
                ZAddress += (zaddrlist[0].Locality__c != null) ? zaddrlist[0].Locality__c : '';
                ZAddress += (zaddrlist[0].StateOrProvince__c != null) ? zaddrlist[0].StateOrProvince__c : '';
            }
            
            //isSubmitted = ![ Select Id From ProcessInstance WHERE TargetObjectId =: SQI.Id AND Status = 'Pending' ].isEmpty();
            
            // Changed from using process instance to using overall status to set ispending and isfalse to eliminate too many queries defect # 1402
            if (SQI.Overallstatus__c == 'Pending') {
                isSubmitted = true;
                isPending = false;
            }
            
            isApproved = false;
            isRecalled = false;
            isEmptyStatus = false;
            
            // MMG 2/18/2015 used to control edit capability on product
            isFinance = false;
            if (SQI.Currentstatus__c == 'Pending - Finance') {
                isFinance = true;
            }
            if (SQI.Currentstatus__c == 'Pending - Business Decision Support') {
                isFinance = true;
            }
            if (SQI.OverallStatus__c == 'Approved') {
                isApproved = true;
            } else if (SQI.OverallStatus__c == 'Recalled' || SQI.OverallStatus__c == 'Rejected') {
                isRecalled = true;
            }
            
            if (SQI.OverallStatus__c == '' || SQI.OverallStatus__c == null) {
                isEmptyStatus = true;
            }
            
            Id = SQI.Id;
            isDiscountTypeEmpty = false;
            isICB = false;
            // MGG319 1/4/2019 Changing from ICB to BDT for Testing Purposes to remove Discount Pricing Request Box
            // and allow normal submit for approval button to launch approval process
            System.debug('Discount Type = ' + SQI.Discounttype__c);
            System.debug('Isicb before test = ' + IsIcb);
            System.debug('isDiscountTypeEmpty= ' + isDiscountTypeEmpty);
            System.debug('Record Type Name = ' + quoterecordtype);
            if (SQI.DiscountType__c != null && SQI.DiscountType__c.length() > 0 && SQI.DiscountType__c != 'None') {
                // if ((SQI.DiscountType__c == 'ICB') || (SQI.DiscountType__c == 'CTR') && (quoterecordtype == 'SFA')) {
                //  if ((SQI.DiscountType__c == 'ICB') && (quoterecordtype == 'SFA')) {
                if ((SQI.DiscountType__c == 'BDT') || (SQI.DiscountType__c == 'CTR')) {
                    System.debug('Isicb after test = ' + IsIcb);
                    // MGG319 End Change
                    isICB = true;
                    System.debug('Isicb after test = ' + IsIcb);
                }
                if (SQI.DiscountType__c == 'ICBA') {
                    System.debug('Discount Type = ' + sqi.discounttype__c);
                    isICB = false;
                    isEmptyStatus = false;
                    System.debug('Isicb after test = ' + IsIcb);
                }
                if (SQI.DiscountType__c == 'CTRA') {
                    System.debug('Discount Type = ' + sqi.discounttype__c);
                    isICB = false;
                    isEmptyStatus = false;
                    System.debug('Isicb after test = ' + IsIcb);
                }
                if (SQI.NoICB__c == true) {
                    System.debug('NoIcb = ' + sqi.NoICB__c);
                    isICB = false;
                    System.debug('Isicb after test = ' + IsIcb);
                }
            } else {
                isDiscountTypeEmpty = true;
                System.debug('isDiscountTypeEmpty= ' + isDiscountTypeEmpty);
            }
            //Giri 06/24/2014 Added End
            system.debug('wrapperconstructor nri price' + OLI.NRC_Price__C);
        }

    }
    
}