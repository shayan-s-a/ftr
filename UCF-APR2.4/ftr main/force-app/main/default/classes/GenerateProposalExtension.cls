public class GenerateProposalExtension {
	public String oppId { get; set; }
	public List<SterlingQuoteItem__c> strQuotes { get; set; }
	public List<SteringQuoteItemExtension> strQuoteItemsExtensions { get; set; }
	public Account act { get; set; }
	public Contact con { get; set; }
	public User currentUser { get; set; }
	public List<SterlingQuote__c> lSyncedQuote { get; set; }
	public Opportunity opp { get; set; }
	public String currentDate { get; set; }
	public String quoteRepresent { get; set; }
	public String quoteName { get; set; }
	public String quoteNumber { get; set; }
	public String proposalFuture { get; set; }
	public String proposalCompany { get; set; }
	public String qNameStr { get; set; }
	public Boolean lightningRecordtype {get; set;}

	public GenerateProposalExtension() {
		con = null;
		strQuoteItemsExtensions = new List<SteringQuoteItemExtension>();
		strQuotes = new List<SterlingQuoteItem__c>();
		currentDate = (Datetime.now()).format('MMMM dd, yyyy');
		oppId = ApexPages.currentPage().getParameters().get('oppId');
		proposalFuture = ApexPages.currentPage().getParameters().get('proposalFuture');
		proposalCompany = ApexPages.currentPage().getParameters().get('proposalCompany');
		opp = [SELECT Id, AccountId, recordtype.Name FROM Opportunity WHERE id = :oppId];
		lightningRecordtype = false;    
        if (opp.RecordType.Name == 'Opportunity Lightning'|| opp.RecordType.Name == 'Partner Opportunity - New'){
			lightningRecordtype = true;
		}  
		currentUser = [SELECT Id, Phone, Title, MobilePhone, Email, Name FROM User WHERE id = :UserInfo.getUserId()];
		lSyncedQuote = [
			SELECT Id, Name, RecordTypeId, RecordType.Name, Quote_Number__c
			FROM SterlingQuote__c
			WHERE OpportunityId__c = :oppId AND IsSyncing__c = TRUE
		];
		act = [SELECT id, Name FROM Account WHERE id = :opp.AccountId];

		try {
			con = [SELECT AccountId, name FROM Contact WHERE AccountId = :act.id];
		} catch (Exception ex) {
		}

		integer count = 0;
		System.debug('check 2');
		system.debug('m1' + Limits.getQueries());
		system.debug('m2' + lSyncedQuote);
		if (lSyncedQuote != null && lSyncedQuote.size() > 0) {
			for (SterlingQuote__c temp : lSyncedQuote) {
				qNameStr = 'Quote Number: ';
				quoteNumber = temp.Quote_Number__c;
				for (SterlingQuoteItem__c var : [
					SELECT
						Id,
						Name,
						Status__c,
						OverallStatus__c,
						DiscountType__c,
						Products__c,
						StandardMRC__c,
						Quantity__c,
						TermLength__c,
						CPE_NRC_Price__c,
						AdjustedNRC__c,
						StandardNRC__c,
						AdjustedMRC__c,
						Renewal_MRR_Original__c
					FROM SterlingQuoteItem__c
					WHERE SterlingQuote__c = :temp.Id AND (AdjustedNRC__c != 0.00 OR AdjustedMRC__c != 0.00)
				]) {
					system.debug('Selected Sterling Quote Items = ' + var.name);
					if (
						var.DiscountType__c == '' ||
						var.DiscountType__c == null ||
						var.OverallStatus__c != null &&
						var.OverallStatus__c == 'Approved'
					) {
						if (
							!(var.name).contains('Surcharge') &&
							!(var.name).contains('Tax') &&
							!(var.name).contains('Installation') &&
							!(var.name).contains('Credit') &&
							!(var.name).contains('Charge')
						) {
							try {
								PricebookEntry pbEntry = [
									SELECT Id, Product2Id, Product2.Id, Product2.MajorProduct__c, Product2.Name
									FROM PriceBookEntry
									WHERE PriceBook2.isStandard = TRUE AND Product2Id = :var.Products__c
								]; // RB - Defect 1476
								SteringQuoteItemExtension tempSE = new SteringQuoteItemExtension();
								tempSE.ProductId = var.Products__c;
								tempSE.Quantity = var.Quantity__c;
								tempSE.Id = var.Id;
								tempSE.TermLength = var.TermLength__c;
								tempSE.CPE_NRC_Price = var.CPE_NRC_Price__c;
								tempSE.NRC = (var.AdjustedNRC__c == null) ? 0.00 : var.AdjustedNRC__c.setScale(2);

								if (var.CPE_NRC_Price__c != null) {
									tempSE.NRC = var.AdjustedNRC__c + var.CPE_NRC_Price__c; //value getting displayed(NRC)
									tempSE.NRC.setScale(2);
								}

								tempSE.ProductName = pbEntry.Product2.Name;

								if ((tempSE.ProductName).contains('(Challenger)')) {
									tempSE.ProductName = (tempSE.ProductName).replace('(Challenger)', '');
								} else if ((tempSE.ProductName).contains('(Leader)')) {
									tempSE.ProductName = (tempSE.ProductName).replace('(Leader)', '');
								} else if ((tempSE.ProductName).contains('Leader')) {
									tempSE.ProductName = (tempSE.ProductName).replace('- Leader', '');
								} else if ((tempSE.ProductName).contains('Challenger')) {
									tempSE.ProductName = (tempSE.ProductName).replace('- Challenger', '');
								}
                                //tempSE.MRC = var.Quantity__c * (var.AdjustedMRC__c);
                                //SDDD-3415 As per this defect commented 116(removed Quantity)								
								tempSE.MRC = var.AdjustedMRC__c; //value getting displayed(MRC)
								tempSE.MRC = (tempSE.MRC == null) ? 0 : tempSE.MRC.setScale(2);
								strQuoteItemsExtensions.add(tempSE);
							} catch (exception e) {
								system.debug('########' + e);
							}
						}
					}
				}
			}

			System.debug(strQuoteItemsExtensions.size());
			if (lSyncedQuote.size() == 2) {
				for (SterlingQuote__c temp : lSyncedQuote) {
					if (temp.RecordType.Name != 'SFA') {
						quoteName = temp.Name;
					}
				}
			} else if (lSyncedQuote.Size() == 1) {
				for (SterlingQuote__c temp : lSyncedQuote) {
					quoteName = temp.Name;
				}
			}
		}
		quoteRepresent = ' ';
		Map<String, SteringQuoteItemExtension> mapSQIE = new Map<String, SteringQuoteItemExtension>();
		List<SteringQuoteItemExtension> TempStore = new List<SteringQuoteItemExtension>();
		for (SteringQuoteItemExtension SQIE : strQuoteItemsExtensions) {
			SQIE.ProductName = SQIE.ProductName.replace('(Challenger)', '');
			SQIE.ProductName = SQIE.ProductName.replace('(Leader)', '');
			if (
				SQIE.ProductName != 'Inter Lata Change Credit' &&
				SQIE.ProductName != 'Inter Lata Change Charge' &&
				SQIE.ProductName != 'Intra Lata Change Credit' &&
				SQIE.ProductName != 'Intra Lata Change Charge' &&
				SQIE.ProductName != 'Broadband Full Installation  Term Credit' &&
				SQIE.ProductName != 'Broadband Full Installation'
			) {
				TempStore.add(SQIE);
			} else {
				mapSQIE.put(SQIE.ProductName, SQIE);
			}
		}
		if (mapSQIE.containsKey('Inter Lata Change Credit')) {
			mapSQIE.remove('Inter Lata Change Charge');
			mapSQIE.remove('Inter Lata Change Credit');
		}
		if (mapSQIE.containsKey('Intra Lata Change Credit')) {
			mapSQIE.remove('Intra Lata Change Charge');
			mapSQIE.remove('Intra Lata Change Credit');
		}
		if (mapSQIE.containsKey('Broadband Full Installation  Term Credit')) {
			mapSQIE.remove('Broadband Full Installation');
			mapSQIE.remove('Broadband Full Installation  Term Credit');
		}
		strQuoteItemsExtensions.clear();
		strQuoteItemsExtensions.addall(mapSQIE.values());
		strQuoteItemsExtensions.addall(TempStore);
		// add vlocity products
		if (lightningRecordtype == true){
			for (OpportunityLineItem oli : [
				SELECT Id, vlocity_cmt__onetimecharge__c, vlocity_cmt__EffectiveQuantity__c,CPQ_NetNewMRR__c, vlocity_cmt__recurringcharge__c, Term_Months__c, Quantity, Product2.Name, Speed__c, vlocity_cmt__JSONAttribute__c, ftr_isApplyDiscount__c, Product2.ProductCode, ftr_DiscountPrice__c   
				FROM OpportunityLineItem
				WHERE OpportunityId = :oppId AND Opportunity_Sync__c = 'Vlocity' AND (Prod_Code__c NOT IN ('SIP_NETWORK_ACCESS','SIP_RACK_BRACKET','SIP_INSTALL_KIT','SIP_ROUTER_INSTALL_CHARGE','SIP_MANAGED_ROUTER_001'))
				ORDER BY QuoteLineItem__c]) {
                    
				strQuoteItemsExtensions.add(new SteringQuoteItemExtension(oli));
			}
		}
	}

	public class SteringQuoteItemExtension {
		public String Id { get; set; }
		public String ProductId { get; set; }
		public decimal Quantity { get; set; }
		public decimal TermLength { get; set; }
		public decimal CPE_NRC_Price { get; set; }
		public decimal StandardNRC { get; set; }
		public String ProductName { get; set; }
		public Decimal standardMRC { get; set; }
		public Decimal NRC { get; set; }
		public Decimal MRC { get; set; }
        public Decimal Numbeofyears { get; set; }

		public SteringQuoteItemExtension() {
			// do nothing here
		}
		public SteringQuoteItemExtension(OpportunityLineItem oli) {
			Id = oli.Id;
			Quantity = oli.Quantity;
			TermLength = oli.Term_Months__c;
            //Numbeofyears=TermLength/12;
            oli.vlocity_cmt__EffectiveQuantity__c = oli.vlocity_cmt__EffectiveQuantity__c == null ? 1 : oli.vlocity_cmt__EffectiveQuantity__c;
            NRC = oli.vlocity_cmt__onetimecharge__c == null ? 0.00 : oli.vlocity_cmt__onetimecharge__c * oli.vlocity_cmt__EffectiveQuantity__c;
            MRC = oli.vlocity_cmt__recurringcharge__c == null ? 0.00 : oli.CPQ_NetNewMRR__c;

           // MRC = oli.vlocity_cmt__recurringcharge__c == null ? 0.00 : oli.vlocity_cmt__recurringcharge__c * oli.vlocity_cmt__EffectiveQuantity__c;
			            
           // MRC = MRC.setScale(2);
            NRC = NRC.setScale(2);
            Boolean isPartner =isPartnered(oli.vlocity_cmt__JSONAttribute__c);
            String attributeValue = getAttributeValue(oli.vlocity_cmt__JSONAttribute__c);
			ProductName = String.isBlank(oli.Speed__c) ? (oli.Product2.Name + attributeValue) : (oli.Product2.Name + ' ' + oli.Speed__c + attributeValue);
           // if(oli.ftr_isApplyDiscount__c && oli.Product2.ProductCode  == 'ENT_ETH_EIA_0002' ){
            if(oli.ftr_isApplyDiscount__c){
                MRC = oli.ftr_DiscountPrice__c == null ? 0.00 : oli.ftr_DiscountPrice__c;
                if(oli.ftr_isApplyDiscount__c && oli.Product2.ProductCode  == 'ENT_ETH_EIA_0002' ){
                   // system.debug('!!!' + attributeValue);
                //ProductName =  attributeValue == null ? 'DIA Bundle' : 'DIA Bundle'+ attributeValue;
                ProductName =  String.isBlank(oli.Speed__c) ? ('DIA Bundle') : ('DIA Bundle'+ ' ' + oli.Speed__c );
                }
            }
            ProductName = isPartner ? ProductName+' '+'Partnered':ProductName;
			//MRC = MRC.setScale(2);
		}
	}
    
    private static String getAttributeValue(String jsonAttribute){
        String value = '';
        if(jsonAttribute != null && jsonAttribute != '') {
            
            Map<String,Object> jsnMap = (Map<String,Object>) JSON.deserializeUntyped( jsonAttribute );
            System.debug('$$$jsnMap='+jsnMap);
            List<Object> objList = new List<Object>();
            if(jsnMap.containsKey('FTR_ENT_PRI_ATTCAT')){
            objList = (List<Object>) jsnMap.get('FTR_ENT_PRI_ATTCAT');
            }else {
                return '';
            }
            System.debug('$$$objList='+objList);
            for(Object obj: objList) {
                Map<String,Object> attMap = (Map<String,Object>) obj;
                //System.debug('$$$attMap='+attMap);
                //System.debug('$$$attMap='+attMap.get('attributeuniquecode__c'));
                
                if( (String) attMap.get('attributeuniquecode__c') == 'ATTR_CoS' || (String)attMap.get('attributeuniquecode__c') == 'ATTR_IP_BLOCKS' || (String)attMap.get('attributeuniquecode__c') == 'ATTR_MIN_BLOCKS' || (String)attMap.get('attributeuniquecode__c') == 'ATTR_INC_LD_BOT' || (String)attMap.get('attributeuniquecode__c') == 'ATTR_FIREWALL'){
                    Map<String,Object> attributeRunTimeInfoMap = (Map<String,Object>) attMap.get('attributeRunTimeInfo');
                    //System.debug('$$$$###selectItemMap='+attributeRunTimeInfoMap);
                    if(attributeRunTimeInfoMap.containsKey('selectedItem')) {
                        Map<String,Object> selectItemMap = (Map<String,Object>) attributeRunTimeInfoMap.get('selectedItem');
                        System.debug('$$$$###selectItemMap='+selectItemMap);
                        if((String) selectItemMap.get('value') != null && (String) selectItemMap.get('value') != '')
                        value = ' ('+(String) selectItemMap.get('value') + ')';
                    }
                }
            }
        }
		return value;
	}
    /**Added for Partner value**/
    	private static Boolean isPartnered(String jsonAttribute){
        Boolean isPartner=false;
        if(jsonAttribute != null && jsonAttribute != '') {
            
            Map<String,Object> jsnMap = (Map<String,Object>) JSON.deserializeUntyped( jsonAttribute );
            System.debug('$$$jsnMap='+jsnMap);
            List<Object> objList = new List<Object>();
            if(jsnMap.containsKey('FTR_ENT_PRI_ATTCAT')){
            objList = (List<Object>) jsnMap.get('FTR_ENT_PRI_ATTCAT');
            }else {
                return false;
            }
            System.debug('$$$objList='+objList);
            for(Object obj: objList) {
                Map<String,Object> attMap = (Map<String,Object>) obj;
                //System.debug('$$$attMap='+attMap);
                //System.debug('$$$attMap='+attMap.get('attributeuniquecode__c'));
                
                if( (String) attMap.get('attributeuniquecode__c') == 'ATTR_PARTNER'){
                    Map<String,Object> attributeRunTimeInfoMap = (Map<String,Object>) attMap.get('attributeRunTimeInfo');
                    //System.debug('$$$$###selectItemMap='+attributeRunTimeInfoMap);
                    if(attributeRunTimeInfoMap.containsKey('selectedItem')) {
                        Map<String,Object> selectItemMap = (Map<String,Object>) attributeRunTimeInfoMap.get('selectedItem');
                        System.debug('$$$$###selectItemMap='+selectItemMap);
                        if((String) selectItemMap.get('value') != null && (String) selectItemMap.get('value') != ''){
                        	isPartner = true;
                        }
                    }
                }
            }
        }
		return isPartner;
	}
}