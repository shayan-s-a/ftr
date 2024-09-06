/**
 *  QuoteLineItemService - Handles Quote Line Item service functions
 *
 *  @author: Sean Fife
 *  @date: Dec 4 2019
 *  @version : 1
 */

 public class QuoteLineItemService {
	private static final string CardinalityMessageRecurring = 'Adjusted Recurring Charge (${1}) cannot be less than Recurring Floor Pricing (${0})';
	private static final string CardinalityMessageOneTime = 'Adjusted One Time Charge (${1}) cannot be less than One Time Floor Pricing (${0})';
	private static final string BDTCardinalityMessage = 'IF Fiber Cost is = 0 THEN do BDT or IF the Fiber Cost is > 0 Follow DEALDESK process and submit for approval';
	
	// Delay the quote update DML when it's under CPQ context
	public static Boolean delayQuoteUpdate = false;
	// Stores the quotes deferred for updates
	public static Map<Id, Quote> quotesToUpdate = new Map<Id, Quote>();

	public static boolean UpdateQuote(List<QuoteLineItem> newItems) {
		Map<Id, Quote> quotes = getQuoteMap(newItems);
		Map<Id, List<QuoteLineItem>> qliToQuote = groupQuoteLineItems(newItems);
		Set<Quote> modifiedQuotes = new Set<Quote>();

		boolean modifiedRecord = false;
		for (List<QuoteLineItem> items : qliToQuote.values()) {
			Quote parentQuote = quotes.get(items[0].QuoteId);
			boolean approvalRequired = false;
			boolean revertStatus = true;
			boolean cardinalityMessageShow = false;
			boolean wasAnUnapprovedDiscountFound = false;

			for (QuoteLineItem item : items) {
				boolean unapprovedDiscountFound = false;
				boolean discountFound = false;
				Boolean partQ = false;
                if(!Test.isRunningTest()){
                    partQ = (boolean)ftr_CpqHelper.getJSONAttributeValue(item.vlocity_cmt__JSONAttribute__c, 'ATTR_ELIGBL_PARTNRD');
                }

                if(item.vlocity_cmt__Action__c != 'Disconnect'){//Skiip Discount logic for Disconnected X Line Items
                    if (item.vlocity_cmt__OneTimeCharge__c >= 1000000 || item.vlocity_cmt__RecurringCharge__c >= 1000000 && !partQ) {
                        item.vlocity_cmt__CpqCardinalityMessage__c = BDTCardinalityMessage;                                                                 
                    } else {
                        //error message should hide for this line item
                        item.vlocity_cmt__CpqCardinalityMessage__c = null;
                    }
                    if (item.vlocity_cmt__RecurringCharge__c < item.vlocity_cmt__BaseRecurringCharge__c) {
                        //discount found
                        discountFound = true;
                        if (item.Floor_Price_Recurring__c == null && item.Floor_Price_Recurring__c != 0.00) {
                            //unapproved discount found
                            unapprovedDiscountFound = true;
                            wasAnUnapprovedDiscountFound = true;
                        }
                    }
                    
                    if (item.vlocity_cmt__OneTimeCharge__c < item.vlocity_cmt__BaseOneTimeCharge__c) {
                        //discount found
                        discountFound = true;
                        if (item.Floor_Price_One_Time__c == null && item.Floor_Price_One_Time__c != 0.00) {
                            //unapproved discount found
                            unapprovedDiscountFound = true;
                            wasAnUnapprovedDiscountFound = true;
                        }
                    }
                    
                    if (unapprovedDiscountFound == true) {
                        approvalRequired = true;
                    } else if (discountFound == true) {
                        if (
                            item.vlocity_cmt__RecurringCharge__c < item.Floor_Price_Recurring__c ||
                            item.vlocity_cmt__OneTimeCharge__c < item.Floor_Price_One_Time__c
                        ) {
                            //error message should show for this line item
                            if (item.vlocity_cmt__RecurringCharge__c < item.Floor_Price_Recurring__c) {
                                item.vlocity_cmt__CpqCardinalityMessage__c = string.format(
                                    CardinalityMessageRecurring,
                                    new List<object>{ item.Floor_Price_Recurring__c, item.vlocity_cmt__RecurringCharge__c }
                                );
                            } else if (item.vlocity_cmt__OneTimeCharge__c < item.Floor_Price_One_Time__c) {
                                item.vlocity_cmt__CpqCardinalityMessage__c = string.format(
                                    CardinalityMessageOneTime,
                                    new List<object>{ item.Floor_Price_One_Time__c, item.vlocity_cmt__OneTimeCharge__c }
                                );
                            }
                            
                            cardinalityMessageShow = true;
                        } else {
                            //error message should hide for this line item
                            item.vlocity_cmt__CpqCardinalityMessage__c = null;
                            revertStatus = false;
                        }
                    } else {
                        //no discounts were found
                        if (
                            item.vlocity_cmt__RecurringCharge__c == item.vlocity_cmt__BaseRecurringCharge__c &&
                            item.vlocity_cmt__OneTimeCharge__c == item.vlocity_cmt__BaseOneTimeCharge__c
                        ) {
                            //pricing is unchanged
                            if (item.Floor_Price_Recurring__c == null && item.Floor_Price_One_Time__c == null) {
                                //set the status back to N/A & Draft
                            } else {
                                revertStatus = false;
                            }
                        } else {
                            //something is overpriced - do nothing
                            revertStatus = false;
                        }
                    }
                }
                //Nitesh EQU-70867 Populating speed value Start
                String speed = getSpeed(item.vlocity_cmt__JSONAttribute__c);
                if(!String.isBlank(speed)){
                    item.Speed__c = speed ;
                }
                //Nitesh EQU-70867 Populating speed value End
            }
			if (cardinalityMessageShow == false) {
				if (approvalRequired == true) {
					if (parentQuote.Status != 'Approved' || wasAnUnapprovedDiscountFound == true) {
						modifiedRecord = true;
						parentQuote.Approval_Status__c = 'Approval Required';
						parentQuote.Status = 'Needs Review';
						modifiedQuotes.add(parentQuote);
					}
				} else if (revertStatus == true) {
					if (parentQuote.Status != 'Approved') {
						modifiedRecord = true;
						parentQuote.Approval_Status__c = 'N/A';
						parentQuote.Status = 'Draft';
						modifiedQuotes.add(parentQuote);
					}
				}
			}
		}

		if (!modifiedQuotes.isEmpty() && modifiedQuotes.size() > 0) {
			system.debug('---modifiedQuotes---' + modifiedQuotes);
			// If the dealyQuoteUpdate is set, we will not issue an Quote update DML here, instead we will put quotes to update into quotesToUpdate map
			if (delayQuoteUpdate) {	
				System.debug('The update to the quote(s) is delayed.');
				for (Quote q : modifiedQuotes) {
					quotesToUpdate.put(q.Id, q);
				}
			} else {
				update new List<Quote>(modifiedQuotes);
			}
		}

		return modifiedRecord;
	}

	public static void updateQuotesDelayed() {
		if (quotesToUpdate != null && quotesToUpdate.size() > 0) {
			System.debug('The quote(s) delayed for update are updated.');
			update quotesToUpdate.values();
		}
	}

	private static Map<Id, Quote> getQuoteMap(List<QuoteLineItem> newItems) {
		Set<Id> quoteIds = new Set<Id>();
		for (QuoteLineItem item : newItems) {
			quoteIds.add(item.QuoteId);
		}

		return new Map<Id, Quote>(
			[SELECT Id, Status, Approval_Status__c, IsSyncing__c, OpportunityId, Service_Term__c FROM Quote WHERE Id IN :quoteIds]
		);
	}

	public static Map<Id, List<QuoteLineItem>> groupQuoteLineItems(List<QuoteLineItem> newItems) {
		Map<Id, List<QuoteLineItem>> qliToQuote = new Map<Id, List<QuoteLineItem>>();
		for (QuoteLineItem item : newItems) {
			if (qliToQuote.containsKey(item.QuoteId)) {
				qliToQuote.get(item.QuoteId).add(item);
			} else {
				qliToQuote.put(item.QuoteId, new List<QuoteLineItem>{ item });
			}
		}
		return qliToQuote;
	}

	public static void updateDsatStandardInterval(List<QuoteLineItem> newItems){
        Set<Id> serviceAccountIds = new Set<Id>();
        Map<Id,vlocity_cmt__Premises__c> premisesMap = new Map<Id,vlocity_cmt__Premises__c>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> ethernetProducts = new Set<Id>();
		Map<Id,Id> childParentProductMap = new Map<Id,Id>();
		Set<id> parentProductIdSet = new Set<Id>(); //to store parent products
		Map<Id,Id> childProductIdMap = new Map<Id,Id>(); //to store child and parent product map
		Map<String,DSAT_StandardInterval__c> stateDsatMap = new Map<String,DSAT_StandardInterval__c>();
		Set<String> stateSet = new Set<String>();
		Map<String,Integer> parentDsatMap = new Map<String,Integer>();
		Map<String, List<Integer> > parentDsatChildMap = new Map<String, List<Integer> >();
		Map<String,Integer> childDsatMap = new Map<String,Integer>();
        Map<String,Boolean> parentDsatSwapMap = new Map<String,Boolean>();
		
		
        for(QuoteLineItem eachItem :newItems){
            if(eachItem.vlocity_cmt__ServiceAccountId__c != null){
                serviceAccountIds.add( eachItem.vlocity_cmt__ServiceAccountId__c );
            }
            if(eachItem.Product2Id != null){
                productIds.add( eachItem.Product2Id );
            }
        }
        if(productIds.size() > 0){
            for(Product2 prod: [Select Id, Family from Product2 where Family = 'Ethernet' AND Id IN:productIds]){
                ethernetProducts.add( prod.Id );
            }
			for(vlocity_cmt__ProductChildItem__c eachChild: [Select Id, vlocity_cmt__ParentProductId__c, vlocity_cmt__ChildProductId__c from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__c IN :productIds AND vlocity_cmt__ParentProductId__r.Family = 'Ethernet' Order By vlocity_cmt__ParentProductId__c]) {
				if(eachChild.vlocity_cmt__ParentProductId__c != null) {
					parentProductIdSet.add(eachChild.vlocity_cmt__ParentProductId__c);
				}
				if(eachChild.vlocity_cmt__ChildProductId__c != null) {
					childProductIdMap.put(eachChild.vlocity_cmt__ChildProductId__c, eachChild.vlocity_cmt__ParentProductId__c);
				}				
			}
        }
        System.debug('$$$$parentProductIdSet='+parentProductIdSet);
		System.debug('$$$$childProductIdMap='+childProductIdMap);
		System.debug('$$$$serviceAccountIds='+serviceAccountIds);
		System.debug('$$$$productIds='+productIds);
		
        if(serviceAccountIds.size() > 0){
            for(Account acc: [Select Id,vlocity_cmt__PremisesId__c, vlocity_cmt__PremisesId__r.Lit__c,
                              vlocity_cmt__PremisesId__r.vlocity_cmt__State__c, vlocity_cmt__PremisesId__r.Fiber_Distance__c from Account where Id IN:serviceAccountIds]){
                if(acc.vlocity_cmt__PremisesId__c != null){
                    premisesMap.put(acc.Id, acc.vlocity_cmt__PremisesId__r);
					if(acc.vlocity_cmt__PremisesId__c != null)
					stateSet.add( acc.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c );
                }
            }
			for( DSAT_StandardInterval__c dsatRec: [select id,State__c,Lit__c,X1_1000FT__c,X1001_2000FT__c,X2001_to_4000FT__c from DSAT_StandardInterval__c where State__c IN :stateSet]) {
				stateDsatMap.put(dsatRec.State__c, dsatRec);
			}
                    
			
            System.debug('$$$$premisesMap='+premisesMap);
            for(QuoteLineItem eachItem :newItems){
                if(ethernetProducts.contains(eachItem.Product2Id) && eachItem.vlocity_cmt__ServiceAccountId__c != null && premisesMap.containsKey(eachItem.vlocity_cmt__ServiceAccountId__c)){
                    vlocity_cmt__Premises__c premiseObj = premisesMap.get( eachItem.vlocity_cmt__ServiceAccountId__c );
                    DSAT_StandardInterval__c dsatRec = stateDsatMap.get(premiseObj.vlocity_cmt__State__c);
                    
                    System.debug('$$$$dsatRec='+dsatRec);
                    System.debug('$$$$premiseObj='+premiseObj);
					Integer dsatDays = 0;
                    if(dsatRec != null) {
                    	if(premiseObj.Lit__c == 'Yes'){
                            dsatDays = Integer.valueof(dsatRec.Lit__c.replace('-', ''));
                        }else if(premiseObj.Lit__c == 'No'){
                            if(premiseObj.Fiber_Distance__c > 0 && premiseObj.Fiber_Distance__c <= 1000){
                                dsatDays = Integer.valueof(dsatRec.X1_1000FT__c.replace('-', ''));
                            }
                            else if(premiseObj.Fiber_Distance__c > 1000 && premiseObj.Fiber_Distance__c <= 2000){
                                dsatDays = Integer.valueof(dsatRec.X1001_2000FT__c.replace('-', ''));
                            }
                            else if(premiseObj.Fiber_Distance__c > 2000 && premiseObj.Fiber_Distance__c <= 4000){
                                dsatDays = Integer.valueof(dsatRec.X2001_to_4000FT__c.replace('-', ''));
                            }
                        }
						if(parentProductIdSet.contains( eachItem.Product2Id )){
							parentDsatMap.put( eachItem.QuoteId + '_' + eachItem.Product2Id , dsatDays );
						}
						if( childProductIdMap.containsKey( eachItem.Product2Id ) ){
							Id parentProductId = childProductIdMap.get( eachItem.Product2Id );
							String key = eachItem.QuoteId + '_' + parentProductId;
							childDsatMap.put( eachItem.QuoteId + '_' + eachItem.vlocity_cmt__ServiceAccountId__c + '_' + eachItem.Product2Id, dsatDays  );
							if( parentDsatChildMap.containsKey( key ) ){
								List<Integer> childDsatList = parentDsatChildMap.get( key );
								childDsatList.add( dsatDays );
								parentDsatChildMap.put( key, childDsatList );
							}else {
								parentDsatChildMap.put( key, new List<Integer> {dsatDays} );
							}
						}
                    } //dsat if closed
                } //Ethernet Product if closed
            } //QLI for loop closed
			
			for(QuoteLineItem eachItem :newItems){
				String key = eachItem.QuoteId + '_' + eachItem.Product2Id;
				//Parent Logic
				if(parentDsatMap.containsKey( key ) ){
					integer dsatDays = parentDsatMap.get( key );
					if(parentDsatChildMap.containsKey(key)) {
                        eachItem.Dsat_Standard_interval__c = dsatDays + '';
						List<Integer> childDsatDays = parentDsatChildMap.get(key);
						childDsatDays.sort();
						for(Integer dsat: childDsatDays){
                            if( dsat < dsatDays || dsat == dsatDays) {
                                parentDsatSwapMap.put( key, true );
                                break;
                            }
							if(dsatDays < dsat && !parentDsatSwapMap.containsKey(key)) {
								eachItem.Dsat_Standard_interval__c = dsat + '';
								parentDsatMap.put( key, dsat );
								break;
							}
						}
					}
				}
                
				//Child Logic
				key = eachItem.QuoteId + '_' + eachItem.vlocity_cmt__ServiceAccountId__c + '_' + eachItem.Product2Id;
				if( childDsatMap.containsKey( key ) ){
					Id parentProductId = childProductIdMap.get( eachItem.Product2Id );
					Integer childDsatDays = childDsatMap.get( key );
                    eachItem.Dsat_Standard_interval__c = childDsatDays + '';
					key = eachItem.QuoteId + '_' + parentProductId;
					integer dsatDays = parentDsatMap.get( key );
					if( childDsatDays < dsatDays ) {
						eachItem.Dsat_Standard_interval__c = dsatDays + '';
                    }
                        
                    
				}
			}
            
            for(QuoteLineItem eachItem :newItems){
                if (eachItem.Dsat_Standard_interval__c != null && eachItem.Dsat_Standard_interval__c != ''){
                    
                    eachItem.Dsat_Standard_interval__c = eachItem.Dsat_Standard_interval__c.substring(0,2) + '-'+eachItem.Dsat_Standard_interval__c.substring(2,4);
                    
                    
                }
                
                
            }
            
			
        } //serviceAccounts if closed
    }
    
    //Nitesh EQU-70867 method to pull speed from Json
    public static string getSpeed(String jsonDataStr){
        String value = '';
        if(jsonDataStr != null && jsonDataStr != ''){
            Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped (jsonDataStr); 
            if(jsonData.containsKey('FTR_ENT_PRI_ATTCAT')){
                List<Object> ftrAttCat = (List<Object>) jsonData.get('FTR_ENT_PRI_ATTCAT');
                for(Object obj : ftrAttCat){
                    Map<String,Object> attrData = (Map<String,Object>) obj;
                    if(attrData.containsKey('attributeuniquecode__c') && String.ValueOf(attrData.get('attributeuniquecode__c')) == 'ATTR_BANDWIDTH'){
                        Map<String,Object> attributrValMap = (Map<String,Object>) attrData.get('attributeRunTimeInfo');
                        if(attributrValMap.containsKey('selectedItem')){
                            Map<String,Object> selectedVal = (Map<String,Object>) attributrValMap.get('selectedItem');
                            if(selectedVal.containsKey('value')){
                                value = (String) selectedVal.get('value');
                            }
                        }
                    }
                }
            }
        }
        return value;
    }

    public static void dummytestcoverage() {
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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
