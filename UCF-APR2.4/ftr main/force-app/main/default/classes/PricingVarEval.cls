global with sharing class PricingVarEval implements vlocity_cmt.VlocityOpenInterface {
    global class PricingVarEvalException extends Exception {}
    global class PricingVarEvalIgnoreException extends Exception {}

    private static Map<String, Object> ctx;
    static {
        ctx = new Map<String, Object>();
    }
    
    global PricingVarEval() {
    }

    global Boolean invokeMethod(String methodName,
                                Map<String, Object> input,
                                Map<String, Object> output,
                                Map<String, Object> options) {
        try {
            if (methodName == 'Eval') {
                Object val = eval(input);
                output.put('value', val);
                return true;
            } else {
                output.put('error', methodName + ' is not defined.');
                return false;
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex);
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            output.put('error', ex.getMessage());
            return false;
        }                        
    }

    /**
     * 
     */
    private List<Account> getAccounts(List<SObject> itemList) {
        Set<Id> accountIds = new Set<Id>();
        for (SObject item : itemList) {
            if (item.get('vlocity_cmt__ServiceAccountId__c') != null) {
                accountIds.add((String)item.get('vlocity_cmt__ServiceAccountId__c'));
            }
            if (item.get('vlocity_cmt__BillingAccountId__c') != null) {
                accountIds.add((String)item.get('vlocity_cmt__BillingAccountId__c'));
            }
        }
        return [SELECT Id, 
                    ShippingStateCode, 
                    vlocity_cmt__PremisesId__r.Lit__c,
                    vlocity_cmt__PremisesId__r.Market__c,
                    vlocity_cmt__PremisesId__r.Level__c,
                    vlocity_cmt__PremisesId__r.Last_DSAT_Check__c,
                    vlocity_cmt__PremisesId__r.Copper_Tier__c,
                    vlocity_cmt__PremisesId__r.Fiber_Tier__c,
                    vlocity_cmt__PremisesId__r.Copper_Qualification__c,
                    vlocity_cmt__PremisesId__r.Copper_Distance__c,
                    vlocity_cmt__PremisesId__r.Fiber_Distance__c,
                    vlocity_cmt__PremisesId__r.WC_CLLI__c, 
                    vlocity_cmt__PremisesId__r.WC_Speed__c, 
                    vlocity_cmt__PremisesId__r.WC_QOS__c,
                	vlocity_cmt__PremisesId__r.Max_Speed_Available_Mbps__c
                FROM Account 
                WHERE Id = :accountIds];
    }

    public static void resetContext() {
        ctx = new Map<String, Object>();
    }

    /**
     * @description return the account map
     */
    public Map<Id, Account> getAccountMap(List<SObject> itemList) {
        Map<Id, Account> accountMap = (Map<Id, Account>)ctx.get('accountMap');
        if (accountMap == null) {
            accountMap = new Map<Id, Account>(getAccounts(itemList));
            ctx.put('accountMap', accountMap);
        }

        return accountMap;
    }
    /**
     * @description return the CLLI code to WireCenter Map
     */
    public Map<String, Wire_Center__c> getWCMap(List<SObject> itemList) {
        Map<String, Wire_Center__c> wcMap = (Map<String, Wire_Center__c>)ctx.get('wcMap');
        if (wcMap == null) {
            wcMap = new Map<String, Wire_Center__c>();
            Map<Id, Account> accountMap = getAccountMap(itemList);
            Set<String> cllis = new Set<String>();
            for (Account acc : accountMap.values()) {
                if (acc.vlocity_cmt__PremisesId__r.WC_CLLI__c != null)
                    cllis.add(acc.vlocity_cmt__PremisesId__r.WC_CLLI__c);
            }
            Wire_Center__c[] wcList = [SELECT Id, CLLI__c, Cost_Per_Foot__c, Default_Pricing_Group__c FROM Wire_Center__c WHERE CLLI__c IN :cllis];
            for (Wire_Center__c wc : wcList) 
                wcMap.put(wc.CLLI__c, wc);

            ctx.put('wcMap', wcMap);
        }

        return wcMap;

    }

    /**
     * @description return the xLI.Id to speed Map
     */
    public Map<Id, Integer> getItemSpeedMap(List<SObject> itemList) {
        Map<Id, Integer> speedMap = (Map<Id, Integer>)ctx.get('speedMap');
        if (speedMap == null) {
            generateItemAttributeMaps(itemList);
            speedMap = (Map<Id, Integer>)ctx.get('speedMap');
        }

        return speedMap;

    }

    /**
     * @description return the xLI.Id to discount flag Map
     */
    public Map<Id, String> getIsDiscountedMap(List<SObject> itemList) {
        Map<Id, String> isDiscountedMap = (Map<Id, String>)ctx.get('isDiscountedMap');
        if (isDiscountedMap == null) {
            generateItemAttributeMaps(itemList);
            isDiscountedMap = (Map<Id, String>)ctx.get('isDiscountedMap');
        }

        return isDiscountedMap;

    }

    /**
     * @description return the xLI.Id to speed Map
     */
    public Map<Id, String> getItemCoSMap(List<SObject> itemList) {
        Map<Id, String> cosMap = (Map<Id, String>)ctx.get('cosMap');
        if (cosMap == null) {
            generateItemAttributeMaps(itemList);
            cosMap = (Map<Id, String>)ctx.get('cosMap');
        }

        return cosMap;

    }    

    /**
     * 
     */
    void generateItemAttributeMaps(List<SObject> itemList) {
        Map<Id, String> cosMap = new Map<Id, String>();
        Map<Id, Integer> speedMap = new Map<Id, Integer>();
        Map<Id, String> isDiscountedMap = new Map<Id, String>();
    
        for (SObject item : itemList) {
            Map<String, Object> attrVals = (Map<String, Object>)ftr_CpqHelper.getJSONAttributeValues((String)item.get('vlocity_cmt__JSONAttribute__c'));
            //  System.debug('attVals: '+attrVals);
            String bandWidth = (String)attrVals.get('ATTR_BANDWIDTH'); 
            Integer speed = bandWidth == null ? null : ftr_CpqHelper.convertToSpeed(bandWidth);
            speedMap.put(item.Id, speed);

            String cos = (String)attrVals.get('ATTR_CoS'); 
            cosMap.put(item.Id, cos);
            
            String isDiscounted = (String)attrVals.get('ATTR_IS_DISCOUNT'); 
            isDiscountedMap.put(item.Id, isDiscounted);
        }

        ctx.put('cosMap', cosMap);     
        ctx.put('isDiscountedMap', isDiscountedMap);     
        ctx.put('speedMap', speedMap);
    }

    /**
     * @description
     */
    Map<String, List<Pricing_Other_Operating_Cost__c>> getOperatingCostsMap(List<SObject> itemList) {
        Map<String, List<Pricing_Other_Operating_Cost__c>> costsMap = (Map<String, List<Pricing_Other_Operating_Cost__c>>)ctx.get('operatingCostsMap');
        if (costsMap == null) {
            costsMap = new Map<String, List<Pricing_Other_Operating_Cost__c>>();

            Set<String> states = new Set<String>();
            Set<String> pCodes = new Set<String>();
            Map<Id, Account> accountMap = getAccountMap(itemList);
            for (SObject item : itemList) {
                String pCode = item.getSObject('PriceBookEntry') != null ? (String)item.getSObject('PriceBookEntry').getSObject('Product2').get('ProductCode') : (String)item.get('Description');
                pCodes.add(pCode);

                Account serviceAccount = accountMap.get((Id)item.get('vlocity_cmt__ServiceAccountId__c'));
                if (serviceAccount != null) states.add(serviceAccount.ShippingStateCode);
            }

            Pricing_Other_Operating_Cost__c[] operatingCosts = [
                SELECT Product_Code__c, Speed__c, State__c, MRC__c 
                FROM Pricing_Other_Operating_Cost__c
                WHERE Product_Code__c=:pCodes AND State__c=:states
                ORDER BY State__c, Product_Code__c, Speed__c ASC
            ];

            for (Pricing_Other_Operating_Cost__c cost : operatingCosts) {
                String key = getOperatingCostKey(cost.Product_Code__c, cost.State__c);
                List<Pricing_Other_Operating_Cost__c> costs = costsMap.get(key);
                if (costs == null) {
                    costs = new List<Pricing_Other_Operating_Cost__c>();
                    costsMap.put(key, costs);
                } 
                costs.add(cost);
            }

            ctx.put('operatingCostsMap', costsMap);
        }

        return costsMap;
    }

    // /**
    //  * @description return costKey to cost Map. costKey is constructed by product code, state and speed
    //  */
    // Map<String, Decimal> getOperatingCostMap(List<SObject> itemList) {
    //     Map<String, Decimal> costMap = (Map<String, Decimal>)ctx.get('operatingCostMap');
    //     if (costMap == null) {
    //         costMap = new Map<String, Decimal>();
    //         Set<Integer> speeds = new Set<Integer>();
    //         Set<String> states = new Set<String>();
    //         Set<String> pCodes = new Set<String>();

    //         Map<Id, Account> accountMap = getAccountMap(itemList);
    //         Map<Id, Integer> speedMap = getItemSpeedMap(itemList);

    //         for (SObject item : itemList) {
    //             String pCode = (String)item.getSObject('PriceBookEntry').getSObject('Product2').get('ProductCode');
    //             pCodes.add(pCode);

    //             Account serviceAccount = accountMap.get((Id)item.get('vlocity_cmt__ServiceAccountId__c'));
    //             if (serviceAccount != null) states.add(serviceAccount.ShippingStateCode);
                
    //             speeds.add(speedMap.get(item.Id));
    //         }

    //         Pricing_Other_Operating_Cost__c[] operatingCosts = [
    //             SELECT Product_Code__c, Speed__c, State__c, MRC__c 
    //             FROM Pricing_Other_Operating_Cost__c
    //             WHERE Product_Code__c=:pCodes AND Speed__c=:speeds AND State__c=:states
    //         ];

    //         for (Pricing_Other_Operating_Cost__c cost : operatingCosts) {

    //             costMap.put(getOperatingCostKey(cost.Product_Code__c, cost.State__c, (Integer)cost.Speed__c), cost.MRC__c);
    //         }

    //         ctx.put('operatingCostMap', costMap);

    //     }
    //     return costMap;
    // }
    
    String getOperatingCostKey(String productCode, String stateCode) {
        return productCode + '.' + stateCode;
    }

    // String getOperatingCostKey(String productCode, String stateCode, Integer speed) {
    //     // String pCode = (String)item.getSObject('PriceBookEntry').getSObject('Product2').get('ProductCode');
    //     return productCode + '.' + stateCode + '.' + String.valueOf(speed);
    // }

    // /**
    //  * @description return service account Id to pricing group map 
    //  */
    // Map<Id, String> getPricingGroupMap(List<SObject> itemList) {
    //     Map<Id, String> groupMap = (Map<Id, String>)ctx.get('pricingGroupMap');
    //     if (groupMap == null) {
    //         groupMap = new Map<Id, String>();

    //         Map<Id, Account> accountMap = getAccountMap(itemList);
    //         Map<String, Wire_Center__c> wcMap = getWCMap(itemList);
    //         for (SObject item : itemList) {
    //             Account serviceAccount = accountMap.get((Id)item.get('vlocity_cmt__ServiceAccountId__c'));
    //             if (serviceAccount != null && serviceAccount.vlocity_cmt__PremisesId__r != null) {
    //                 if (serviceAccount.vlocity_cmt__PremisesId__r.Pricing_Group__c == null) {
    //                     groupMap.put(serviceAccount.Id, serviceAccount.vlocity_cmt__PremisesId__r.Pricing_Group__c);
    //                 } else {
    //                     Wire_Center__c wc = wcMap.get(serviceAccount.vlocity_cmt__PremisesId__r.WC_CLLI__c);
    //                     if (wc != null) {
    //                         groupMap.put(serviceAccount.Id, wc.Default_Pricing_Group__c);
    //                     }                     
    //                 }
    //             }
    //         }

    //         ctx.put('pricingGroupMap', groupMap);

    //     }

    //     return groupMap;
    // }

    /**
     * 
     */
    Map<String, Pricing_CoS__c> getCoSMap() {
		Cache.OrgPartition orgPart;
		Map<String, Pricing_CoS__c> cosMap;
		orgPart = Cache.Org.getPartition(PricingFormulaService.CACHE_PARTITION_ABP);
		if (orgPart != null) {
			cosMap = (Map<String, Pricing_CoS__c>) orgPart.get(PricingFormulaService.CACHE_KEY_COS); // get cosMap
			if (cosMap != null) {
				// if the cosMap are in cache already, return the map
				return cosMap;
			} else {
                // else query the formulas and put them into cache
                cosMap = new Map<String, Pricing_CoS__c>();
                for (Pricing_CoS__c cos : [SELECT Id, Name, Speed__c, CoS__c, MRC__c FROM Pricing_CoS__c]) {
                    cosMap.put(getCoSKey(cos.Name, (Integer)cos.Speed__c, cos.CoS__c), cos);
                }

				orgPart.put(PricingFormulaService.CACHE_KEY_COS, cosMap);
			}
		}
		return cosMap;        
    }
    /**
     * @description return the key
     */
    String getCoSKey(String productCode, Integer speed, String cos) {
        return (productCode + '-' + cos + '-' + String.valueOf(speed)).toLowerCase();
    }

    /**
     * 
     */
    Map<String, List<Group_Pricing_Matrix__c>> getGroupPricingMap(List<SObject> itemList, SObject parent) {
        Map<String, List<Group_Pricing_Matrix__c>> grpPricingMap = (Map<String, List<Group_Pricing_Matrix__c>>)ctx.get('grpPricingMap');
        if (grpPricingMap == null) {
            grpPricingMap = new Map<String, List<Group_Pricing_Matrix__c>>();

            Integer  term = integer.valueof(String.valueof(parent.get('Service_Term__c')).subString(0, 3).trim()); 
            Set<String> pCodes = new Set<String>();
            
            Map<Id, Account> accountMap = getAccountMap(itemList);
            Map<String, Wire_Center__c> wcMap = getWCMap(itemList);
            Set<String> groupIds = new Set<String>();

            /*
            // removing premises Pricing Group logic. 
            for (Account svs : accountMap.values()) {
                if (svs.vlocity_cmt__PremisesId__r != null) {
                    if (svs.vlocity_cmt__PremisesId__r.Pricing_Group__c == null) {
                    	Wire_Center__c wc = wcMap.get(svs.vlocity_cmt__PremisesId__r.WC_CLLI__c);
                        if (wc != null) {
                            svs.vlocity_cmt__PremisesId__r.Pricing_Group__c = wc.Default_Pricing_Group__c;
                        }
                    }
                    if (svs.vlocity_cmt__PremisesId__r.Pricing_Group__c != null)
                        groupIds.add(svs.vlocity_cmt__PremisesId__r.Pricing_Group__c);
                }
            }
            */
            
            for (Account svs : accountMap.values()) {
                String grp; 
                Wire_Center__c wc = wcMap.get(svs.vlocity_cmt__PremisesId__r.WC_CLLI__c);
                if (svs.vlocity_cmt__PremisesId__r.Fiber_Tier__c == 'Tier 2') {
                    grp = '12'; // Tier 2 group
                }
                if (wc != null && grp == null) {
                    grp = wc.Default_Pricing_Group__c;
                }
                if (grp != null)
                    groupIds.add(grp);
            }
            
            for (SObject item : itemList) {
                String pCode = item.getSObject('PriceBookEntry') != null ? (String)item.getSObject('PriceBookEntry').getSObject('Product2').get('ProductCode') : (String)item.get('Description');
                pCodes.add(pCode);
            }     
            
            Group_Pricing_Matrix__c[] pricingMatrix = [
                SELECT Id, Product_Code__c, Speed__c, Term__c, MRC__c, Group_Id__c 
                FROM Group_Pricing_Matrix__c 
                WHERE Product_Code__c=:pCodes AND Term__c=:term AND Group_Id__c = :groupIds
                ORDER BY Product_Code__c, Term__c, Speed__c ASC
            ];
            
            // System.debug('pricingMatrix: ' + JSON.serialize(pricingMatrix));
            for (Group_Pricing_Matrix__c pricing : pricingMatrix) {
                String key = getGroupPricingKey(pricing.Product_Code__c, (Integer)pricing.Term__c, pricing.Group_Id__c);
                List<Group_Pricing_Matrix__c> pricingList = (List<Group_Pricing_Matrix__c>)grpPricingMap.get(key);
                if (pricingList == null) {
                    pricingList = new List<Group_Pricing_Matrix__c>();
                    grpPricingMap.put(key, pricingList);
                }
                pricingList.add(pricing);
            }

            ctx.put('grpPricingMap', grpPricingMap);
        }

        return grpPricingMap;
    }

    /**
     * 
     */
    String getGroupPricingKey(String productCode, Integer term, String groupId) {
        return (productCode + '-' + String.valueOf(term) + '-' + groupId).toLowerCase();
    }
    

    /**
     * @description this method is used by the getFormulaPrice method
     */
    public Object eval(Map<String, Object> input) {
        String varName = (String)input.get('name'); // Pricing variable to be evaluated
        SObject item = (SObject)input.get('item');  // xLI to be priced
        SObject parent = (SObject)input.get('parent');  // Header object of xLI
        List<SObject> itemList = (List<SObject>)input.get('itemList');  // xLIs in the shopping cart

        //System.debug('evaluating var -- ' + varName);
        if (varName == 'LitBuilding' || 
            varName == 'CopperDistance' ||
            varName == 'FiberDistance' ||
            varName == 'WCMaxSpeed' ||
            varName == 'FiberTier' ||
            varName == 'CopperTier' ||
            varName == 'Market' ||
            varName == 'Level') {
            Map<Id, Account> accountMap = getAccountMap(itemList);
            Account serviceAccount = accountMap.get((Id)item.get('vlocity_cmt__ServiceAccountId__c'));
            if (serviceAccount != null && serviceAccount.vlocity_cmt__PremisesId__c != null) {
                if (varName == 'LitBuilding') {
                    return serviceAccount.vlocity_cmt__PremisesId__r.Lit__c == 'Yes';
                } else if (varName == 'CopperDistance') {
                    return serviceAccount.vlocity_cmt__PremisesId__r.Copper_Distance__c;
                } else if (varName == 'FiberDistance') {
                    return serviceAccount.vlocity_cmt__PremisesId__r.Lit__c == 'Yes' ? 0 : serviceAccount.vlocity_cmt__PremisesId__r.Fiber_Distance__c;
                } else if (varName == 'WCMaxSpeed') {
                    Decimal maxSpeedAvl = serviceAccount.vlocity_cmt__PremisesId__r.Max_Speed_Available_Mbps__c;
                    return maxSpeedAvl.intValue();
                    //return ftr_CpqHelper.convertToSpeed(serviceAccount.vlocity_cmt__PremisesId__r.WC_Speed__c);
                } else if (varName == 'FiberTier') {
                    return serviceAccount.vlocity_cmt__PremisesId__r.Fiber_Tier__c;
                } else if (varName == 'CopperTier') {
                    return serviceAccount.vlocity_cmt__PremisesId__r.Copper_Tier__c;
                } else if (varName == 'Market') {
                    return serviceAccount.vlocity_cmt__PremisesId__r.Market__c;
                } else if (varName == 'Level') {
                    return serviceAccount.vlocity_cmt__PremisesId__r.Level__c;
                } else {
                    return null;
                }
            } else {
                throw new PricingVarEvalException('Cannot evaluate the ' + varname + '.');
            }
        } else if (varName == 'IsDiscounted') {
            Map<Id, String> isDiscountedMap = getIsDiscountedMap(itemList);
            String isDiscounted = (String) isDiscountedMap.get(item.Id);

            return isDiscounted;
        } else if (varName == 'FiberCostPerFoot') {
            Map<Id, Account> accountMap = getAccountMap(itemList);
            Account serviceAccount = accountMap.get((Id)item.get('vlocity_cmt__ServiceAccountId__c'));
            if (serviceAccount != null && serviceAccount.vlocity_cmt__PremisesId__c != null) {
                Map<String, Wire_Center__c> wcMap = getWCMap(itemList);
                Wire_Center__c wc = wcMap.get(serviceAccount.vlocity_cmt__PremisesId__r.WC_CLLI__c);
                if (wc != null && wc.Cost_Per_Foot__c != null)
                    return wc.Cost_Per_Foot__c;
                else
                    return 1000000;
            } else {
                throw new PricingVarEvalIgnoreException('Cannot locate Service Account or Premises record to determine the Fiber cost per foot.');
            }
        } else if (varName == 'ProductCode') {
            return item.getSObject('PriceBookEntry') != null ? (String)item.getSObject('PriceBookEntry').getSObject('Product2').get('ProductCode') : (String)item.get('Description');
        } else if (varName == 'State') {
            Map<Id, Account> accountMap = getAccountMap(itemList);
            Account serviceAccount = accountMap.get((Id)item.get('vlocity_cmt__ServiceAccountId__c'));
            if (serviceAccount != null && serviceAccount.vlocity_cmt__PremisesId__c != null && serviceAccount.ShippingStateCode != null) {
                return serviceAccount.ShippingStateCode;
            } else {
                throw new PricingVarEvalIgnoreException('Cannot find the premises or service account record.');
            }
        } else if (varName == 'LoadingRate') {
            Map<Id, Account> accountMap = getAccountMap(itemList);
            Account serviceAccount = accountMap.get((Id)item.get('vlocity_cmt__ServiceAccountId__c'));
            if (serviceAccount != null && serviceAccount.ShippingStateCode != null) {
                Pricing_Loading_Rate__c loadingRate = Pricing_Loading_Rate__c.getValues(serviceAccount.ShippingStateCode);
                if (loadingRate != null)
                    return loadingRate.Rate__c;
                else 
                    throw new PricingVarEvalException('Loading rate cannot be determined by the ' + serviceAccount.ShippingStateCode + '.');
            } else {
                throw new PricingVarEvalIgnoreException('Cannot locate Service Account or Premises record to determine the LoadingRate.');
            }
        } else if (varName == 'Multiplier') {

            String  serv = String.valueof(parent.get('Service_Term__c'));
            String sub = serv.substring(0,2);
            Pricing_Multiplier__c multiplier = Pricing_Multiplier__c.getValues(sub);
            Decimal multVal = multiplier.Multiplier__c;

            return multVal;
        } else if (varName =='Term') {
            String  serv = String.valueof(parent.get('Service_Term__c'));
            String sub = serv.substring(0,3);
            Integer  intval = integer.valueof(sub.trim()); 

            return intval;
           
        } else if (varName =='Speed') {

            Map<Id, Integer> speedMap = getItemSpeedMap(itemList);
            Integer speed = speedMap.get(item.Id);
            if (speed == null) {
                throw new PricingVarEvalIgnoreException('Bandwidth is not configured.');
            } else {
                return speed;
            }
        } else if (varName == 'OtherOperatingCost') {
            Map<String, List<Pricing_Other_Operating_Cost__c>> costsMap = getOperatingCostsMap(itemList);

            String pCode = item.getSObject('PriceBookEntry') != null ? (String)item.getSObject('PriceBookEntry').getSObject('Product2').get('ProductCode') : (String)item.get('Description');
                
            Map<Id, Account> accountMap = getAccountMap(itemList);
            Account serviceAccount = accountMap.get((Id)item.get('vlocity_cmt__ServiceAccountId__c'));
            String state = serviceAccount == null ? null : serviceAccount.ShippingStateCode;

            Map<Id, Integer> speedMap = getItemSpeedMap(itemList);
            Integer speed = speedMap.get(item.Id);

            String costKey = getOperatingCostKey(pCode, state);
            List<Pricing_Other_Operating_Cost__c> costs = costsMap.get(costKey);
            if (costs == null) {
                return 0;
            } else {
                Pricing_Other_Operating_Cost__c cost = null;
                for (Integer i = 0; i < costs.size(); i++) {
                    if (speed <= costs[i].Speed__c) {
                        // Pickup the cost for the next higher speed cost if the current speed is not defined in the cost table
                        cost = costs[i];
                        break;
                    }
                }

                if (cost != null)
                    return cost.MRC__c;
                else 
                    return 0;
            }
        } else if (varName == 'ClassOfService') {
            Map<String, Pricing_CoS__c> cosMap = getCoSMap();

            String pCode = item.getSObject('PriceBookEntry') != null ? (String)item.getSObject('PriceBookEntry').getSObject('Product2').get('ProductCode') : (String)item.get('Description');
            Map<Id, Integer> itemSpeedMap = getItemSpeedMap(itemList);
            Integer speed = itemSpeedMap.get(item.Id);
            Map<Id, String> itemCoSMap = getItemCoSMap(itemList);

            String cos = itemCosMap.get(item.Id);
            Pricing_CoS__c cosObj = cosMap.get(getCoSKey(pCode, speed, cos));

            if (cosObj != null) {
                return cosObj.MRC__c;
            } else {
                return 0;
            }
        } else if (varName == 'CompetitorGroupPrice') {
            Map<Id, Account> accountMap = getAccountMap(itemList);
            Account serviceAccount = accountMap.get((Id)item.get('vlocity_cmt__ServiceAccountId__c'));
            
            String pCode = item.getSObject('PriceBookEntry') != null ? (String)item.getSObject('PriceBookEntry').getSObject('Product2').get('ProductCode') : (String)item.get('Description');
            Integer  term = integer.valueof(String.valueof(parent.get('Service_Term__c')).subString(0,3).trim());

            Map<Id, Integer> speedMap = (Map<Id, Integer>)getItemSpeedMap(itemList);
            Integer speed = speedMap.get(item.Id);

            
            Map<String, List<Group_Pricing_Matrix__c>> grpPricingMap = (Map<String, List<Group_Pricing_Matrix__c>>)getGroupPricingMap(itemList, parent);    
            Map<String, Wire_Center__c> wcMap = getWCMap(itemList);
            String groupId;
            if (wcMap.get(serviceAccount.vlocity_cmt__PremisesId__r.WC_CLLI__c) != null)
                groupId = wcMap.get(serviceAccount.vlocity_cmt__PremisesId__r.WC_CLLI__c).Default_Pricing_Group__c;
            if (serviceAccount.vlocity_cmt__PremisesId__r.Fiber_Tier__c == 'Tier 2') {
                groupId = '12';
            }
            // system.debug(pCode + ' - ' + term  + ' - ' + groupId);
            List<Group_Pricing_Matrix__c> pricingList = grpPricingMap.get(getGroupPricingKey(pCode, term, groupId));

            if (pricingList != null) {
                Group_Pricing_Matrix__c myGrpPricing = null;
                for (Integer i = 0; i < pricingList.size(); i++) {
                    if (speed <= pricingList[i].Speed__c) {
                        myGrpPricing = pricingList[i];
                        break;
                    }
                } 

                if (myGrpPricing != null) {
                    return myGrpPricing.MRC__c;
                } else {
                    throw new PricingVarEvalException('Competitor Pricing Group cannot be determined.');
                }
            } else {
                return 0;
            }        
        } else {
            throw new PricingVarEvalException('Pricing variable of ' + varName + ' is not supported.');
        }

    }
}