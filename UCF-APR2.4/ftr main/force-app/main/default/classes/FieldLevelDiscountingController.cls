global without sharing class FieldLevelDiscountingController {
	private Id contextId;
	private Map<String, String> fieldPathMap = new Map<String, String>();
    global Boolean isLogging = false;

	global FieldLevelDiscountingController(String contextId) {
		this.contextId = contextId;
	}

    global FieldLevelDiscountingController(String contextId, Boolean debug) {
		this.contextId = contextId;
        this.isLogging = debug;
	}

	public List<QuoteLineItem> getLineItems() {
		List<String> lineItemFields = new List<String>();
		List<ftr_FieldLevelDiscountingMapping__mdt> fldms = [SELECT Id, Field__c, Path__c FROM ftr_FieldLevelDiscountingMapping__mdt];
		for (ftr_FieldLevelDiscountingMapping__mdt FLDM : fldms) {
			lineItemFields.add(FLDM.Path__c);
			fieldPathMap.put(FLDM.Field__c, FLDM.path__c);
		}
		String query = 'SELECT Id, PricebookEntry.Product2.ProductCode, vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.WC_CLLI__c, vlocity_cmt__OneTimeCharge__c,Floor_Price_One_Time__c,vlocity_cmt__RecurringCharge__c,Floor_Price_Recurring__c,ftr_MRC_Discounted__c, ftr_NRC_Discounted__c';
		for (String field : lineItemFields) {
			query += ', ' + field;
		}

		query += ' FROM QuoteLineItem WHERE QuoteId =:contextId AND Quote.ftr_IsBundle__c = false AND (ftr_MRC_Discounted__c > 0 OR ftr_NRC_Discounted__c >0)';
        if (isLogging) {
            System.debug('string query: ' + query);
        }
		return Database.query(query);
	}

	public Map<String, List<ftr_FieldLevelDiscounting__mdt>> getFieldLevelDiscountingMap() {
		Map<String, List<ftr_FieldLevelDiscounting__mdt>> fldm = new Map<String, List<ftr_FieldLevelDiscounting__mdt>>();
		List<ftr_FieldLevelDiscounting__mdt> mdt = [
			SELECT
				Id,
				Priority__c,
				ProductCode__c,
				FiberTier__c,
				Speed__c,
				Type__c,
				Discount_Max__c,
				Discount_Min__c,
				Term__c,
				Approval_Needed__c,
				Pricing_Group__c
			FROM ftr_FieldLevelDiscounting__mdt
			ORDER BY Priority__c ASC
		];
		for (ftr_FieldLevelDiscounting__mdt record : mdt) {
			String key = record.ProductCode__c;
			if (!fldm.containskey(key)) {
				fldm.put(key, new List<ftr_FieldLevelDiscounting__mdt>());
			}
			fldm.get(key).add(record);
		}
		return fldm;
	}

	//Hemantha
	//
	public void updateApprovalTypeNew(Boolean updateLineItems) {
		update new Quote(Id = this.contextId, ftr_Approval_Type__c = null);

		List<QuoteLineItem> lineItemsToUpdate = new List<QuoteLineItem>();
		List<QuoteLineItem> lineItems = getLineItems();
		List<String> clliList = getClliList(lineItems);
		Map<String, String> clliPGMap = getClliPGMap(clliList);
		String pricingGroup;

        if (isLogging) {
            System.debug('fetched lineitems: ' + JSON.serialize(lineItems));
        }
		if (lineItems.size() > 0) {
			Map<String, List<ftr_FieldLevelDiscounting__mdt>> fldm = getFieldLevelDiscountingMap();
			List<FieldLevelDiscountWrapper> comparedRecords = new List<FieldLevelDiscountWrapper>();
			Boolean goToDealDesk = false;

			for (QuoteLineItem record : lineItems) {
				String key = record.PricebookEntry.Product2.ProductCode;
				Boolean matched = false;

				Double nrcDiscount = record.ftr_NRC_Discounted__c != null ? Double.valueOf(record.ftr_NRC_Discounted__c) : 0;
				Double mrcDiscount = record.ftr_MRC_Discounted__c != null ? Double.valueOf(record.ftr_MRC_Discounted__c) : 0;

				if (isLogging) {
					System.debug('checking: ' + key + ' - ' + record.Id);
				}

				if (fldm.containsKey(key)) {
					
					List<ftr_FieldLevelDiscounting__mdt> fldRecords = fldm.get(key);
					// System.debug('all discounting records: ' + JSON.serialize(fldRecords));
					pricingGroup = clliPGMap.get(record.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.WC_CLLI__c);
                    if (isLogging) {
                        System.debug('pricingGroup: ' + pricingGroup);
                        System.debug('mrc discount: ' + mrcDiscount);
                        System.debug('nrc discount: ' + nrcDiscount);
                    }
					if (fldRecords != null && fldRecords.size() > 0) {
						for (ftr_FieldLevelDiscounting__mdt fld : fldRecords) {
							Boolean chk =   fld.Pricing_Group__c != null 
                                            && fld.Pricing_Group__c.split(',').contains(pricingGroup) 
                                            && (nrcDiscount <= Double.valueOf(fld.Discount_Max__c) && mrcDiscount <= Double.valueOf(fld.Discount_Max__c));
							if (!chk) {
								continue;
							}

							Integer matchCount = 0;
							String[] fields = new List<String>{};
							for (String fpm : fieldPathMap.keySet()) {
								if (fld.get(fpm) != null) {
									fields.add(fpm);
									for (String field : String.valueOf(fld.get(fpm)).split(',')) {
										if (field == String.valueOf(record.get(fieldPathMap.get(fpm)))) {
                                            if (isLogging) {
                                                System.debug(fpm + ': ' + field + ' matched with: ' + fld.get(fpm));
                                            }
											matchCount++;
											break;
										}
									}
								}
							}
							if (fields.size() == matchCount) {
								if (isLogging) {
									System.debug('matched record: ' + JSON.serialize(fld));
								}
								comparedRecords.add(new FieldLevelDiscountWrapper(fld));
								lineItemsToUpdate.add(record);
								matched = true;
								break;
							} else {
								if (isLogging) {
									System.debug('no record match, checking next');
									System.debug('=====');
								}
							}
						} //end of for loop
						if (!matched) {
							goToDealDesk = true;
							break;
						}
					}
				} else {
					if (nrcDiscount > 0 || mrcDiscount > 0) {
						goToDealDesk = true;
						if (isLogging) {
							System.debug('unsupported product is discounted...');
						}
						break;
					}
				}
			}
            
			Quote quote = new Quote(Id = this.contextId);
            if (goToDealDesk || comparedRecords.size() == 0) {
				quote.ftr_Approval_Type__c = 'Deal Desk';
				quote.Approval_Status__c = 'Pending Approval - ICB';
				update quote;
			} else {
				if (updateLineItems) {
					for (quoteLineItem qli : lineItemsToUpdate) {
						qli.Floor_Price_One_Time__c = qli.vlocity_cmt__OneTimeCharge__c;
						qli.Floor_Price_Recurring__c = qli.vlocity_cmt__RecurringCharge__c;
					}
					update lineItemsToUpdate;
				}
				comparedRecords.sort();
                if (isLogging) {
                    System.debug('matched discount records: ' + JSON.serializePretty(comparedRecords));
                }
				quote.ftr_Approval_Type__c = comparedRecords.get(0).record.Approval_Needed__C;
				update quote;
			}
            System.debug('Approval Needed: ' + quote.ftr_Approval_Type__c);
		}
	}

	private static List<String> getClliList(List<QuoteLineItem> lineItems) {
		List<String> clliList = new List<String>();
		String wc_CLLI;
		for (QuoteLineItem line : lineItems) {
			wc_CLLI = line.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.WC_CLLI__c;

			if (wc_CLLI != null) {
				if (!clliList.contains(wc_CLLI)) {
					clliList.add(wc_CLLI);
				}
			}
		}
		return clliList;
	}

	private static Map<String, String> getClliPGMap(List<String> clliList) {
		Map<String, String> clliPGMap = new Map<String, String>();
		List<Wire_Center__c> wcList = [SELECT Id, CLLI__c, Default_Pricing_Group__c FROM Wire_Center__c WHERE CLLI__c = :clliList];
		for (Wire_Center__c wc : wcList) {
			clliPGMap.put(wc.CLLI__c, wc.Default_Pricing_Group__c);
		}
		return clliPGMap;
	}
}
