global class MACDDpiBatch implements Database.Batchable < sObject >{
    private String queryString;
    private Map < String, Set < String >> distinctAttributesByApiName = new Map < String, Set < String >> ();
    Map<String, Set<String>> sneCodeMrc = new Map<String, Set<String>>();
            Map<String, Set<String>> sneCodeOtc = new Map<String, Set<String>>();
            Map<String, Set<String>> sneCodeTerm = new Map<String, Set<String>>();
      public MACDDpiBatch() {
        Map < String, Schema.SObjectField > fieldMap = ftr_Asset_StagingCircuit_DPI__c.sObjectType.getDescribe().fields.getMap();
        for (String field: fieldMap.keySet()) {
            if (field.contains('__c')) {
                distinctAttributesByApiName.put(field, new Set < String > ());
            }
        }
          
        queryString = 'SELECT ' + String.join((Iterable < String > ) fieldMap.keySet(), ',') + ' FROM ftr_Asset_StagingCircuit_DPI__c';
        for ( ftr_Legacy_Product_SNE__c sne : [SELECT Id, Product_Code__c, MRC_SNE__c FROM ftr_Legacy_Product_SNE__c]) {
            system.debug('sne.SNE_Code_MRC__c = > +' + sne.MRC_SNE__c);
            if (String.isNotBlank(sne.MRC_SNE__c)) {
                if (!sneCodeMrc.containsKey(sne.Product_Code__c)) {
                    sneCodeMrc.put(sne.Product_Code__c, new Set<String>{sne.MRC_SNE__c});
                } else {
                    sneCodeMrc.get(sne.Product_Code__c).add(sne.MRC_SNE__c);
                }
            }
        }
        for (ftr_Attribute_Based_SNE__c sne : [SELECT Product_Code__c, SNE_Code_MRC__c, SNE_Code_OTC__c,SNE_Code_Term__c FROM ftr_Attribute_Based_SNE__c LIMIT 50000 ]){
    	system.debug('sne.SNE_Code_MRC__c = > +' + sne.SNE_Code_MRC__c);
            if (String.isNotBlank(sne.SNE_Code_MRC__c)) {
                if (!sneCodeMrc.containsKey(sne.Product_Code__c)) {
                    sneCodeMrc.put(sne.Product_Code__c, new Set<String>{sne.SNE_Code_MRC__c});
                } else {
                    sneCodeMrc.get(sne.Product_Code__c).add(sne.SNE_Code_MRC__c);
                }
            }
            if (String.isNotBlank(sne.SNE_Code_OTC__c)) {
                if (!sneCodeOtc.containsKey(sne.Product_Code__c)) {
                    sneCodeOtc.put(sne.Product_Code__c, new Set<String>{sne.SNE_Code_OTC__c});
                } else {
                    sneCodeOtc.get(sne.Product_Code__c).add(sne.SNE_Code_OTC__c);
                }
            }
            if (String.isNotBlank(sne.SNE_Code_OTC__c)) {
                if (!sneCodeTerm.containsKey(sne.Product_Code__c)) {
                    sneCodeTerm.put(sne.Product_Code__c, new Set<String>{sne.SNE_Code_Term__c});
                } else {
                    sneCodeTerm.get(sne.Product_Code__c).add(sne.SNE_Code_Term__c);
                }
            }
    }
    }
     global DataBase.QueryLocator start(Database.BatchableContext BC) {
         for (String key : sneCodeMrc.keySet()) {
             system.debug(key + ' = > ' + sneCodeMrc.get(key));
         }
        return DataBase.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List < ftr_Asset_StagingCircuit_DPI__c > scope) {
        system.debug('recods fetched  +' + scope);
        Map <String, List<ftr_Asset_StagingCircuit_DPI__c>> wtnToDPIMap = new Map <String, List<ftr_Asset_StagingCircuit_DPI__c>>();
        Map<String, String> termIndicatorsMap = new Map<String, String>{'EIA1Y'=>'12 Months','EIA2Y'=>'24 Months','EIA3Y'=>'36 Months','EIA5Y'=>'60 Months','EVP3Y'=>'36 Months','EVP1Y'=>'12 Months','EVP2Y'=>'24 Months','EVP5Y'=>'60 Months'};
 		system.debug('sneCodeTerm printt '+ sneCodeTerm);
        system.debug('sneCodeOtc printt '+ sneCodeOtc);
        system.debug('sneCodeMrc printt '+ sneCodeMrc);
        if (!scope.isEmpty()) {
            for (ftr_Asset_StagingCircuit_DPI__c dpi : scope) {
                if (wtnToDPIMap.containsKey(dpi.WTN__c)) {
                    List<ftr_Asset_StagingCircuit_DPI__c> dpiList = wtnToDPIMap.get(dpi.WTN__c);
                    dpiList.add(dpi);
                    wtnToDPIMap.put(dpi.WTN__c, dpiList);
                } else {
                    List<ftr_Asset_StagingCircuit_DPI__c> dpiList = new List<ftr_Asset_StagingCircuit_DPI__c>{dpi};
                    wtnToDPIMap.put(dpi.WTN__c, dpiList);
                }
            }
            system.debug('wtnToDPIMap print ' + wtnToDPIMap);
            Map<String, List<Asset>> wtnToAssetMap = new Map<String, List<Asset>>();
            //get assets with wtn
            List<Asset> assetList = [SELECT Id,DPI_WTN__c,ProductCode,vlocity_cmt__JSONAttribute__c,vlocity_cmt__RecurringCharge__c,SNE_Code_MRC__c,SNE_Code_TERM__c,
                                     vlocity_cmt__RecurringTotal__c,EVPL_SNE_Code_MRC__c, EVPL_SNE_Code_OTC__c, EVPL_SNE_Code_TERM__c, IP_SNE_Code_MRC__c, IP_SNE_Code_OTC__c, IP_SNE_Code_TERM__c, MR_SNE_Code_MRC__c FROM Asset WHERE DPI_WTN__c IN: wtnToDPIMap.keySet()];
            for (Asset asset : assetList) {
                if (wtnToAssetMap.containsKey(asset.DPI_WTN__c)) {
                    List<Asset> tempAssetList = wtnToAssetMap.get(asset.DPI_WTN__c);
                    tempAssetList.add(asset);
                    wtnToAssetMap.put(asset.DPI_WTN__c, tempAssetList);
                } else {
                    wtnToAssetMap.put(asset.DPI_WTN__c, new List<Asset>{asset});
                }
                //wtnToAssetMap.put(asset.DPI_WTN__c, asset);
            }
            system.debug('wtnToAssetMapprint ' + wtnToAssetMap);
            Map<Id, Asset> assetUpdateMap = new Map<Id, Asset>();
            Map<String, List<Asset>> wtnToDiaAssetMap = new Map<String, List<Asset>>();
            //List<ftr_Asset_StagingCircuit_DPI__c> dpiCricuitList = new List<ftr_Asset_StagingCircuit_DPI__c>();
            Map<Id, ftr_Asset_StagingCircuit_DPI__c> dpiCircuitUpdateMap = new Map<Id, ftr_Asset_StagingCircuit_DPI__c>();
            for (String wtn : wtnToDPIMap.keySet()) {
                if (!wtnToAssetMap.containsKey(wtn)) {
                    for (ftr_Asset_StagingCircuit_DPI__c circuitRec : wtnToDPIMap.get(wtn)) {
                        ftr_Asset_StagingCircuit_DPI__c circuitRecNew = new ftr_Asset_StagingCircuit_DPI__c(Id = circuitRec.Id, Status__c = 'Completed', Error_Message__c = 'No Asset Found');
                        dpiCircuitUpdateMap.put(circuitRecNew.Id, circuitRecNew);
                    }
                    continue;
                }
                List<Asset> assetListIt = wtnToAssetMap.get(wtn);
                for (Asset asset : assetListIt) {
                    Integer counter = 0;
                Boolean assetUpdate = false;
                system.debug('wtn for asset ' + wtn);
                Double existingItemRate = asset.vlocity_cmt__RecurringCharge__c;
                Double existingTotalCharge = asset.vlocity_cmt__RecurringTotal__c;
                    asset.vlocity_cmt__RecurringCharge__c = 0;
                    asset.vlocity_cmt__RecurringTotal__c = 0;
                    Map<String,Object> attrValueMap = new Map<String,Object>();
                system.debug('asset id ' + asset.Id);
                for (ftr_Asset_StagingCircuit_DPI__c circuitRec : wtnToDPIMap.get(wtn)) {
                    Boolean dpiUsed = false;
                    system.debug('circuitRec.CODE__c print ' + circuitRec.CODE__c);
                    if (termIndicatorsMap.containsKey(circuitRec.CODE__c)) {
                        if (String.isNotBlank((String)termIndicatorsMap.get(circuitRec.CODE__c))) {
                			attrValueMap.put('ATTR_CONTRACT_TERM', (Object)termIndicatorsMap.get(circuitRec.CODE__c));
            			}
                        //attrValueMap.put('ATTR_DECOMP_BTN', circuitRec.BTN__c);
                        system.debug('attrValueMap print ' + attrValueMap);
                        //String updatedJSONAttribute = (String) ftr_CpqHelper.setJSONAttributes(asset.vlocity_cmt__JSONAttribute__c, '{}', attrValueMap);
                        //system.debug('updated json attribute in helper ' + updatedJSONAttribute);
                        //asset.vlocity_cmt__JSONAttribute__c = updatedJSONAttribute;
                            assetUpdate = true;
                        dpiUsed = true;
                            system.debug('assetUpdatecheck ' + assetUpdate);
                            system.debug('added to list');
                            circuitRec.Status__c = 'Completed';
                            asset.SNE_Code_TERM__c = circuitRec.CODE__c;
                        dpiCircuitUpdateMap.put(circuitRec.Id, circuitRec);
                            //dpiCricuitList.add(circuitRec);
                	} /*else if (circuitRec.DESCRIPTION__c.containsIgnoreCase('dia') && circuitRec.ITEMRATE__c > 0) {
                        counter++;
                        if (asset.ProductCode == 'ENT_ETH_EVPL_0002') {
                            continue;
                        }
                        if (asset.vlocity_cmt__RecurringCharge__c == null) {
                            asset.vlocity_cmt__RecurringCharge__c = 0;
                        }
                        if (asset.vlocity_cmt__RecurringTotal__c == null) {
                            asset.vlocity_cmt__RecurringTotal__c = 0;
                        }
                    	asset.vlocity_cmt__RecurringCharge__c += circuitRec.ITEMRATE__c;
                        asset.vlocity_cmt__RecurringTotal__c += circuitRec.ITEMRATE__c;
                        asset.SNE_Code_MRC__c = circuitRec.CODE__c;
                        assetUpdate = true;
                        dpiUsed = true;
                        system.debug('assetUpdatecheck ' + assetUpdate);
                        //circuitRec.Status__c = 'Completed';
                        if (String.isNotBlank((String)circuitRec.CODE__c)) {
                					attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
            					}
                        //asset.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(asset.vlocity_cmt__JSONAttribute__c,'','ATTR_DECOMP_BTN',(Object)circuitRec.BTN__c);
                        //dpiCircuitUpdateMap.put(circuitRec.Id, circuitRec);
                        //dpiCricuitList.add(circuitRec);
                    }else if ((circuitRec.DESCRIPTION__c.containsIgnoreCase('access') || circuitRec.DESCRIPTION__c.containsIgnoreCase('evc')) && circuitRec.ITEMRATE__c > 0) {
                        counter++;
                        if (asset.ProductCode == 'ENT_ETH_EVPL_0002') {
                            continue;
                        }
                        if (asset.vlocity_cmt__RecurringCharge__c == null) {
                            asset.vlocity_cmt__RecurringCharge__c = 0;
                        }
                        if (asset.vlocity_cmt__RecurringTotal__c == null) {
                            asset.vlocity_cmt__RecurringTotal__c = 0;
                        }
                    	asset.vlocity_cmt__RecurringCharge__c += circuitRec.ITEMRATE__c;
                        asset.vlocity_cmt__RecurringTotal__c += circuitRec.ITEMRATE__c;
                        asset.EVPL_SNE_Code_MRC__c = circuitRec.CODE__c;
                        assetUpdate = true;
                        dpiUsed = true;
                        system.debug('assetUpdatecheck ' + assetUpdate);
                        //circuitRec.Status__c = 'Completed';
                        if (String.isNotBlank((String)circuitRec.CODE__c)) {
                					attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
            					}
                       // asset.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(asset.vlocity_cmt__JSONAttribute__c,'','ATTR_DECOMP_BTN',(Object)circuitRec.BTN__c);
                        //dpiCircuitUpdateMap.put(circuitRec.Id, circuitRec);
                        //dpiCricuitList.add(circuitRec);
                    } else {
                        circuitRec.Status__c = 'Not Used';
                        //dpiCricuitList.add(circuitRec);
                        dpiCircuitUpdateMap.put(circuitRec.Id, circuitRec);
                    }*/
                    system.debug('sneCodeMRC.containsKey(asset.ProductCode)==> ' + sneCodeMRC.containsKey(asset.ProductCode));
                  //  system.debug('sneCodeMRC.get(asset.ProductCode).contains(circuitRec.CODE__c) == > ' + sneCodeMRC.get(asset.ProductCode).contains(circuitRec.CODE__c));
                    system.debug('circuitRec.CODE__c ' + circuitRec.CODE__c);
                    if (sneCodeMRC.containsKey(asset.ProductCode)) {
                        if (sneCodeMRC.get(asset.ProductCode).contains(circuitRec.CODE__c)) {
                            counter++;
                            if (asset.ProductCode == 'ENT_ETH_EVPL_0002') {
                                continue;
                            }
                            if (asset.vlocity_cmt__RecurringCharge__c == null) {
                                asset.vlocity_cmt__RecurringCharge__c = 0;
                            }
                            if (asset.vlocity_cmt__RecurringTotal__c == null) {
                                asset.vlocity_cmt__RecurringTotal__c = 0;
                            }
                            asset.vlocity_cmt__RecurringCharge__c += circuitRec.ITEMRATE__c;
                            asset.vlocity_cmt__RecurringTotal__c += circuitRec.ITEMRATE__c;
                            assetUpdate = true;
                            dpiUsed = true;
                            system.debug('assetUpdatecheck ' + assetUpdate);
                            //evpl asset
                            if (asset.ProductCode == 'ENT_ETH_EVPL_0010') {
                                //asset.SNE_Code_MRC__c = circuitRec.CODE__c;
                                asset.EVPL_SNE_Code_MRC__c = circuitRec.CODE__c;
                                if (String.isNotBlank((String)circuitRec.CODE__c)) {
                					attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
            					}
                                assetUpdate = true;
                                dpiUsed = true;
                                system.debug('came into evpl sne code update');
                            } else if (asset.ProductCode == 'ENT_ETH_IP_0002') {
                                asset.IP_SNE_Code_MRC__c = circuitRec.CODE__c;
                                if (String.isNotBlank((String)circuitRec.CODE__c)) {
                					attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
            					}
                                //attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
                                assetUpdate = true;
                                dpiUsed = true;
                                system.debug('came into ip sne code update');
                                //asset.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(asset.vlocity_cmt__JSONAttribute__c,'','ATTR_DECOMP_BTN',(Object)circuitRec.BTN__c);                            
                            } else if (asset.ProductCode == 'ENT_ETH_MR_001') {
                                if (String.isNotBlank((String)circuitRec.CODE__c)) {
                					attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
            					}
                                asset.MR_SNE_Code_MRC__c = circuitRec.CODE__c;
                                /////attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
                                assetUpdate = true;
                                dpiUsed = true;
                                system.debug('came into MR sne code update');
                                //asset.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(asset.vlocity_cmt__JSONAttribute__c,'','ATTR_DECOMP_BTN',(Object)circuitRec.BTN__c);
                            } else if (asset.ProductCode == 'ENT_ETH_EIA_0002') {
                                asset.SNE_Code_MRC__c = circuitRec.CODE__c;
                                if (String.isNotBlank((String)circuitRec.CODE__c)) {
                					attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
            					}
                                ///////attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
                                assetUpdate = true;
                                dpiUsed = true;
                                system.debug('came into MR sne code update');
                                //asset.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(asset.vlocity_cmt__JSONAttribute__c,'','ATTR_DECOMP_BTN',(Object)circuitRec.BTN__c);
                            } else if (asset.ProductCode == 'ENT_ETH_UNI_0001') {
                                if (String.isNotBlank((String)circuitRec.CODE__c)) {
                					attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
            					}
                                ///////attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
                                assetUpdate = true;
                                dpiUsed = true;
                                system.debug('came into UNI sne code update');
                                //asset.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(asset.vlocity_cmt__JSONAttribute__c,'','ATTR_DECOMP_BTN',(Object)circuitRec.BTN__c);
                            }
                        }
                    } /*else if ((circuitRec.DESCRIPTION__c.containsIgnoreCase('dia') && circuitRec.ITEMRATE__c > 0) ||
                              ((circuitRec.DESCRIPTION__c.containsIgnoreCase('access') || circuitRec.DESCRIPTION__c.containsIgnoreCase('evc')) && circuitRec.ITEMRATE__c > 0)) {
                                      counter++;
                            if (asset.ProductCode == 'ENT_ETH_EVPL_0002') {
                                continue;
                            }
                            if (asset.vlocity_cmt__RecurringCharge__c == null) {
                                asset.vlocity_cmt__RecurringCharge__c = 0;
                            }
                            if (asset.vlocity_cmt__RecurringTotal__c == null) {
                                asset.vlocity_cmt__RecurringTotal__c = 0;
                            }
                            asset.vlocity_cmt__RecurringCharge__c += circuitRec.ITEMRATE__c;
                            asset.vlocity_cmt__RecurringTotal__c += circuitRec.ITEMRATE__c;
                            assetUpdate = true;
                            dpiUsed = true;
                        if (String.isNotBlank((String)circuitRec.CODE__c)) {
                					attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
            					}
                       // asset.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(asset.vlocity_cmt__JSONAttribute__c,'','ATTR_DECOMP_BTN',(Object)circuitRec.BTN__c);
                        //dpiCricuitList.add(circuitRec);
                    }*/
                    if (sneCodeTerm.containsKey(asset.ProductCode)) {
                         if (sneCodeTerm.get(asset.ProductCode).contains(circuitRec.CODE__c)) {
                            if (asset.ProductCode == 'ENT_ETH_EVPL_0010') {
                                asset.EVPL_SNE_Code_TERM__c = circuitRec.CODE__c;
                                /////attrValueMap.put('ATTR_DECOMP_TERM_SNE', circuitRec.CODE__c);
                                if (String.isNotBlank((String)circuitRec.CODE__c)) {
                					attrValueMap.put('ATTR_DECOMP_TERM_SNE', circuitRec.CODE__c);
            					}
                                //asset.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(asset.vlocity_cmt__JSONAttribute__c,'','ATTR_DECOMP_BTN',(Object)circuitRec.BTN__c);
                                assetUpdate = true;
                                dpiUsed = true;
                            } else if (asset.ProductCode == 'ENT_ETH_IP_0002') {
                                asset.IP_SNE_Code_TERM__c = circuitRec.CODE__c;
                                ////attrValueMap.put('ATTR_DECOMP_TERM_SNE', circuitRec.CODE__c);
                                if (String.isNotBlank((String)circuitRec.CODE__c)) {
                					attrValueMap.put('ATTR_DECOMP_TERM_SNE', circuitRec.CODE__c);
            					}
                                //asset.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(asset.vlocity_cmt__JSONAttribute__c,'','ATTR_DECOMP_BTN',(Object)circuitRec.BTN__c);
                                assetUpdate = true;
                                dpiUsed = true;
                            } else if (asset.ProductCode == 'ENT_ETH_EIA_0002') {
                                asset.SNE_Code_TERM__c = circuitRec.CODE__c;
                                system.debug('check this ' + circuitRec.CODE__c);
                                //attrValueMap.put('ATTR_DECOMP_TERM_SNE', circuitRec.CODE__c);
                                if (String.isNotBlank((String)circuitRec.CODE__c)) {
                					attrValueMap.put('ATTR_DECOMP_TERM_SNE', circuitRec.CODE__c);
            					}
                                //asset.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(asset.vlocity_cmt__JSONAttribute__c,'','ATTR_DECOMP_BTN',(Object)circuitRec.BTN__c);
                                assetUpdate = true;
                                dpiUsed = true;
                            }else if (asset.ProductCode == 'ENT_ETH_UNI_0001') {
                                system.debug('check this ' + circuitRec.CODE__c);
                                //attrValueMap.put('ATTR_DECOMP_TERM_SNE', circuitRec.CODE__c);
                                if (String.isNotBlank((String)circuitRec.CODE__c)) {
                					attrValueMap.put('ATTR_DECOMP_TERM_SNE', circuitRec.CODE__c);
            					}
                                //asset.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(asset.vlocity_cmt__JSONAttribute__c,'','ATTR_DECOMP_BTN',(Object)circuitRec.BTN__c);
                                assetUpdate = true;
                                dpiUsed = true;
                            }
                        }
                        }
                    if (String.isNotBlank((String)circuitRec.BTN__c)) {
                					attrValueMap.put('ATTR_DECOMP_BTN', circuitRec.BTN__c);
                        assetUpdate = true;
                        dpiUsed = true;
            					}
                        if (String.isNotBlank((String)circuitRec.WTN__c)) {
                					attrValueMap.put('WorkingTelephoneNumber', circuitRec.WTN__c);
                            assetUpdate = true;
                            dpiUsed = true;
            					}
                        if (String.isNotBlank((String)circuitRec.ENV__c)) {
                					attrValueMap.put('ATTR_DECOMP_ENVIRONMENT', circuitRec.ENV__c);
                            assetUpdate = true;
                            dpiUsed = true;
            					}
                     if (String.isNotBlank((String)circuitRec.Control_Number__c)) {
                					attrValueMap.put('ATTR_DECOMP_CONTROLNUMBER', circuitRec.Control_Number__c);
                            assetUpdate = true;
                         dpiUsed = true;
            					}
                      if (String.isNotBlank((String)circuitRec.City_Short_Name__c)) {
                					attrValueMap.put('ATTR_DECOMP_CITYABBREVIATION', circuitRec.City_Short_Name__c);
                            assetUpdate = true;
                          dpiUsed = true;
            					}
                    /*if (String.isNotBlank('CKT')) {
                					attrValueMap.put('ATTR_DECOMP_CKTID', 'CKT');
                            assetUpdate = true;
            					} */
                     if (String.isNotBlank((String)circuitRec.GAN__c)){
                					attrValueMap.put('ATTR_GAN_CODE', circuitRec.GAN__c);
                            assetUpdate = true;
                         dpiUsed = true;
            					}
                     if (String.isNotBlank((String)circuitRec.Summary_TN__c)) {
                					attrValueMap.put('ATTR_MSTR_SUMMARY_TN',circuitRec.Summary_TN__c);
                            assetUpdate = true;
                         dpiUsed = true;
            					}
                    /*if (assetUpdate) {
                        system.debug('son atirbute print before btn ' + asset.vlocity_cmt__JSONAttribute__c);
                        //attrValueMap.put('ATTR_CONTRACT_TERM', (Object)termIndicatorsMap.get(circuitRec.CODE__c));
                        
                        
                        system.debug('attrValueMap print for btn update ' + attrValueMap);
                        String updatedJSONAttribute = (String) ftr_CpqHelper.setJSONAttributes(asset.vlocity_cmt__JSONAttribute__c, '{}', attrValueMap);
                        system.debug('updated json attribute in helper for btn ' + updatedJSONAttribute);
                        asset.vlocity_cmt__JSONAttribute__c = updatedJSONAttribute;
                    }*/
                    if (dpiUsed) {
                        circuitRec.Status__c = 'Completed';
                        dpiCircuitUpdateMap.put(circuitRec.Id, circuitRec);
                    } else {
                        circuitRec.Status__c = 'Not Used';
                        dpiCircuitUpdateMap.put(circuitRec.Id, circuitRec);
                    }
                    if (circuitRec.CODE__c.equalsIgnoreCase('EEVCI')) {
                        if (wtnToDiaAssetMap.containsKey(asset.DPI_WTN__c)) {
                            List<Asset> tempAssetList = wtnToDiaAssetMap.get(asset.DPI_WTN__c);
                            tempAssetList.add(asset);
                            wtnToDiaAssetMap.put(asset.DPI_WTN__c, tempAssetList);
                        } else {
                            wtnToDiaAssetMap.put(asset.DPI_WTN__c, new List<Asset>{asset});
                        }
                    }
                }
                if (counter > 1) {
                    asset.DPI_Sync_Review__c  = 'Multiple Item rate matches : ' + counter;
                    asset.vlocity_cmt__RecurringCharge__c = existingItemRate;
                    asset.vlocity_cmt__RecurringTotal__c = existingTotalCharge;
                    asset.SNE_Code_MRC__c = '';
                } else if (counter == 1) {
                    asset.DPI_Sync_Review__c = '';
                }
                if (assetUpdate) {
                    system.debug('son atirbute print before btn ' + asset.vlocity_cmt__JSONAttribute__c);
                        //attrValueMap.put('ATTR_CONTRACT_TERM', (Object)termIndicatorsMap.get(circuitRec.CODE__c));
                        
                        
                        system.debug('attrValueMap print for btn update ' + attrValueMap);
                        String updatedJSONAttribute = (String) ftr_CpqHelper.setJSONAttributes(asset.vlocity_cmt__JSONAttribute__c, '{}', attrValueMap);
                        system.debug('updated json attribute in helper for btn ' + updatedJSONAttribute);
                        asset.vlocity_cmt__JSONAttribute__c = updatedJSONAttribute;
                    assetUpdateMap.put(asset.Id, asset);
                }
                }
            }
            system.debug('assetUpdateMap print ' + assetUpdateMap);
            //system.debug('dpiCricuitList print ' + dpiCricuitList);
            system.debug('dpiCircuitUpdateMap print ' + dpiCircuitUpdateMap);
            if (!assetUpdateMap.isEmpty()) {
                update assetUpdateMap.values();
            }
            if (!dpiCircuitUpdateMap.isEmpty()) {
                update dpiCircuitUpdateMap.values();
            }
            system.debug('wtnToDiaAssetMap '   + wtnToDiaAssetMap);
            system.debug('wtnToDiaAssetMap size '   + wtnToDiaAssetMap.size());
            Map<Id, Asset> diaAssetUpdateMap = new Map<Id, Asset>();
            //process DIA specific logic
            //map from wn uni to dia wtn map
            Map<String, String> wtnUNIToDIAMap = new Map<String, String>();
            if (!wtnToDiaAssetMap.isEmpty()) {
                for (Asset dia : [SELECT Id,DPI_WTN__c,UNI_HOST__r.DPI_WTN__c FROM Asset WHERE DPI_WTN__c IN: wtnToDiaAssetMap.keySet()]) {
                    if (String.isNotBlank(dia.UNI_HOST__r.DPI_WTN__c)) {
                        wtnUNIToDIAMap.put(dia.UNI_HOST__r.DPI_WTN__c, dia.DPI_WTN__c);
                    }
                }
            }
            system.debug('wtnUNIToDIAMap ' + wtnUNIToDIAMap);
            //map from dia wtn to dpi unit map
            Map<String, List<ftr_Asset_StagingCircuit_DPI__c>> wtnToDPIUNIMap = new Map<String, List<ftr_Asset_StagingCircuit_DPI__c>>();
            for (ftr_Asset_StagingCircuit_DPI__c dpi : [SELECT Id, CODE__c, DESCRIPTION__c, ITEMRATE__c, Status__c, WTN__c, Error_Message__c FROM ftr_Asset_StagingCircuit_DPI__c WHERE WTN__c IN: wtnUNIToDIAMap.keySet()]) {
                if (wtnToDPIUNIMap.containsKey(wtnUNIToDIAMap.get(dpi.WTN__c))) {
                    List<ftr_Asset_StagingCircuit_DPI__c> dpiList = wtnToDPIUNIMap.get(wtnUNIToDIAMap.get(dpi.WTN__c));
                    dpiList.add(dpi);
                    wtnToDPIUNIMap.put(wtnUNIToDIAMap.get(dpi.WTN__c), dpiList);
                } else {
                    List<ftr_Asset_StagingCircuit_DPI__c> dpiList = new List<ftr_Asset_StagingCircuit_DPI__c>{dpi};
                    wtnToDPIUNIMap.put(wtnUNIToDIAMap.get(dpi.WTN__c), dpiList);
                }
            }
            system.debug('wtnToDPIUNIMap keyset ' + wtnToDPIUNIMap.keySet());
            system.debug('wtnToDPIUNIMap values ' + wtnToDPIUNIMap.values());
            for (String wtn : wtnToDPIUNIMap.keySet()) {
                if (!wtnToDiaAssetMap.containsKey(wtn)) {
                    continue;
                }
                List<Asset> assetListIt = wtnToDiaAssetMap.get(wtn);
                for (Asset asset : assetListIt) {
                    Boolean assetUpdate = false;
                    system.debug('wtn for asset ' + wtn);
                    Double existingItemRate = asset.vlocity_cmt__RecurringCharge__c;
                    Double existingTotalCharge = asset.vlocity_cmt__RecurringTotal__c;
                    asset.vlocity_cmt__RecurringCharge__c = 0;
                    asset.vlocity_cmt__RecurringTotal__c = 0;
                    Map<String,Object> attrValueMap = new Map<String,Object>();
                    for (ftr_Asset_StagingCircuit_DPI__c circuitRec : wtnToDPIUNIMap.get(wtn)) {
                        if (sneCodeMRC.containsKey(asset.ProductCode)) {
                            if (sneCodeMRC.get(asset.ProductCode).contains(circuitRec.CODE__c)) {
                                if (asset.ProductCode == 'ENT_ETH_EVPL_0002') {
                                    continue;
                                }
                                if (asset.vlocity_cmt__RecurringCharge__c == null) {
                                    asset.vlocity_cmt__RecurringCharge__c = 0;
                                }
                                if (asset.vlocity_cmt__RecurringTotal__c == null) {
                                    asset.vlocity_cmt__RecurringTotal__c = 0;
                                }
                                asset.vlocity_cmt__RecurringCharge__c += circuitRec.ITEMRATE__c;
                                asset.vlocity_cmt__RecurringTotal__c += circuitRec.ITEMRATE__c;
                                assetUpdate = true;
                                if (asset.ProductCode == 'ENT_ETH_EIA_0002') {
                                    asset.SNE_Code_MRC__c = circuitRec.CODE__c;
                                    if (String.isNotBlank((String)circuitRec.CODE__c)) {
                                        attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
                                    }
                                    ///////attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
                                    assetUpdate = true;
                                    system.debug('came into MR sne code update');
                                    //asset.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(asset.vlocity_cmt__JSONAttribute__c,'','ATTR_DECOMP_BTN',(Object)circuitRec.BTN__c);
                            	} else if (asset.ProductCode == 'ENT_ETH_UNI_0001') {
                                    if (String.isNotBlank((String)circuitRec.CODE__c)) {
                                        attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
                                    }
                                    ///////attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
                                    assetUpdate = true;
                                    system.debug('came into UNI sne code update');
                                //asset.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(asset.vlocity_cmt__JSONAttribute__c,'','ATTR_DECOMP_BTN',(Object)circuitRec.BTN__c);
                            	} else if (asset.ProductCode == 'ENT_ETH_IP_0002') {
                                asset.IP_SNE_Code_MRC__c = circuitRec.CODE__c;
                                if (String.isNotBlank((String)circuitRec.CODE__c)) {
                					attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
            					}
                                //attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
                                assetUpdate = true;
                                system.debug('came into ip sne code update');
                                //asset.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(asset.vlocity_cmt__JSONAttribute__c,'','ATTR_DECOMP_BTN',(Object)circuitRec.BTN__c);                            
                            } else if (asset.ProductCode == 'ENT_ETH_MR_001') {
                                if (String.isNotBlank((String)circuitRec.CODE__c)) {
                					attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
            					}
                                asset.MR_SNE_Code_MRC__c = circuitRec.CODE__c;
                                /////attrValueMap.put('ATTR_DECOMP_MRCSNE', circuitRec.CODE__c);
                                assetUpdate = true;
                                system.debug('came into MR sne code update');
                                //asset.vlocity_cmt__JSONAttribute__c = ftr_CpqHelper.setJSONAttribute(asset.vlocity_cmt__JSONAttribute__c,'','ATTR_DECOMP_BTN',(Object)circuitRec.BTN__c);
                            }
                            }
                        }
                    }
                    if (assetUpdate) {
                        system.debug('son atirbute print before btn ' + asset.vlocity_cmt__JSONAttribute__c);
                        //attrValueMap.put('ATTR_CONTRACT_TERM', (Object)termIndicatorsMap.get(circuitRec.CODE__c));
                        
                        
                        system.debug('attrValueMap print for btn update ' + attrValueMap);
                        String updatedJSONAttribute = (String) ftr_CpqHelper.setJSONAttributes(asset.vlocity_cmt__JSONAttribute__c, '{}', attrValueMap);
                        system.debug('updated json attribute in helper for btn ' + updatedJSONAttribute);
                        asset.vlocity_cmt__JSONAttribute__c = updatedJSONAttribute;
                    	diaAssetUpdateMap.put(asset.Id, asset);
                    }
                }
            }
            system.debug('diaAssetUpdateMap ' + diaAssetUpdateMap.keySet());
            system.debug('diaAssetUpdateMap ' + diaAssetUpdateMap.values());
            if (!diaAssetUpdateMap.isEmpty()) {
                update diaAssetUpdateMap.values();
            }
        }
    }
    global void finish(Database.BatchableContext BC) {}
}