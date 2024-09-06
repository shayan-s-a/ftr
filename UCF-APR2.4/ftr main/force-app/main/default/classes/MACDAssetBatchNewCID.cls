global class MACDAssetBatchNewCID implements Database.Batchable < sObject >,Database.Stateful {
    private String queryString;
    private List<AssetStagingJSONMapping__c> assetJSONMappings;
    //list of macd account names to ignore
    private Set<String> m6AccNameToIgnore = MACDAssetBatchNewCIDHelper.getAccNamesToIgnore();
	global Set<String> diaCircuitNameSet = new Set<String>();
      //store priceListId
    global Id priceListId = MACDAssetBatchNewCIDHelper.getPriceListId();
    Set<String> aliasACSet = new Set<String>{'EVPL - EIA','EVPL - P2P','UNI'};
     //   Set<Id> accIds = new Set<Id>{'001E000001egJUDIA2'};
    //map from assetId to its respective circuit record
    global Map<Id, ftr_Asset_StagingCircuit__c> assetToCircuitMap = new Map<Id, ftr_Asset_StagingCircuit__c>();
   // global String accName = 'LOLLICUP USA, INC.';
    //get UNI circuitName set for updating UNI Assets	
    //global Set<String> uniCircuitNameSet = new Set<String>();	
    //map from uni circuit name to sset of diaIds	
    //global Map<String,Set<Id>> uniCircuitNameToDiaIdSet = new Map<String,Set<Id>>();
    global Map<String, ftr_Asset_StagingCircuit__c> uniCNameToCircuitMap = new Map<String, ftr_Asset_StagingCircuit__c>();
    public MACDAssetBatchNewCID() {
        assetJSONMappings = MACDAssetBatchNewCIDHelper.getAssetStagingMappings();
        
        system.debug('asset json mappings print ' + assetJSONMappings);
        queryString = 'SELECT id,name,bit_rate__c,cust_acct_nbr__c,class_of_service__c,error_message__c,managed_device__c,psr_evc_type__c,psr_sdwan__c,psr_virtual_broadband_service_category__c,pass_number__c,priloccity__c,prilocpostalcode__c,prilocstate__c,prilocstreetaddress__c,speed__c,secloccity__c,seclocpostalcode__c,seclocstate__c,seclocstreetaddress__c,status__c,term__c,wtn__c,ftr_circuit_id__c,ftr_companyindicator__c,ftr_ipaddresstype__c,ftr_ipblocksize__c,ftr_iptopology__c,ftr_item_alias__c,ftr_managedfirewall__c,ftr_npa_nxx__c,ftr_psr_cir__c,ftr_psr_jurisdiction__c,ftr_psr_ratecode__c,ftr_psr_parentserviceitemid__c,ftr_ruid1__c,ftr_ruid2__c,ftr_secnci__c,ftr_serviceitemid__c,ftr_circuitname__c,ftr_documentnumber__c,lan_ip__c,managed_device_type__c,wan_ip__c,Service_Address_From_DPI__c,City_DPI__c,Serviceaddress_DPI__c,State_DPI__c,Zipcode_DPI__c FROM ftr_Asset_StagingCircuit__c where(status__c = \'Pending\' OR ( status__c != \'Complete\' AND Pass_Number__c < 2)) ORDER BY CUST_ACCT_NBR__C, ftr_Item_Alias__c ASC LIMIT 50';  
    }

    global DataBase.QueryLocator start(Database.BatchableContext BC) {
    
        return DataBase.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List < ftr_Asset_StagingCircuit__c > scope) {
        //system.debug('Staging	Circuit records' + scope);
        system.debug('size of list ' + scope.size());
        Set < String > WTNSet = new Set < String > ();
        Set < String > CusNoSet = new Set < String > ();
        Set < Id > CusNoSetId = new Set < Id > ();
        Set<String> M6CustNoSet = new Set<String>();
        List < Account > accList = new List < Account > ();
        Map < String, Set < Id >> CuNoCircuitIdMap = new Map < String, Set < Id >> ();
        Map < String, Set<Id>> M6CustNoToCircMap = new Map < String, Set<Id>> ();
        Map < String, Set < Id >> idAccCircuitIdMap = new Map < String, Set < Id >> ();
        Map < String, Account > WtnACCMap = new Map < String, Account > ();
        Set < Id > wtnAccIds = new Set < Id > ();
        set < String > finalwtn = new set < string > ();
        set < String > Streetadd = new set < string > ();
        Map < Id, Account > cIdAccSerMap = new Map < Id, Account > ();
        //map from circuitid to its master account
        Map < Id, Account > circuitAccMap = new Map < Id, Account > ();
        //map from circuit id to circuit record
        Map < Id, ftr_Asset_StagingCircuit__c > circuitMap = new Map < Id, ftr_Asset_StagingCircuit__c > ();
        //map fromcircuit id to wtn
        Map < Id, String > circuitWtnMap = new Map < Id, String > ();
        //map from customer number to wtn 
        Map < String, String > custNoWtnMap = new Map < String, String > ();
        List < asset > assetList = new List < asset > ();
        List < ftr_Asset_Staging_OCAM__c > ocamList = new List < ftr_Asset_Staging_OCAM__c > ();
        //alias set
        Set < String > aliasSet = new Set < String > ();
        //map from wtn to set of circuit ids
        Map < String, Set < Id >> wtnToCircuitMap = new Map < String, Set < Id >> ();
        //map from wtn to alias map
        Map < String, String > wtnToAliasMap = new Map < String, String > ();
        //map from alias to product map
        Map < String, PriceBookEntry > aliasToPriceBEntryMap = new Map < String, PriceBookEntry > ();
      
        //store jurisdiction mappings
        Map<String, String> jurisCodeMap = new Map<String, String>{'0'=>'Ignore','1'=>'Interstate','2'=>'Intrastate'};
        //map from circuit name to circuit sf id
        Map<String, Id> cNameToCIdMap = new Map<String, Id>();
        //Map from street address to wtn
        Map<String, Set<String>> streetAddrToWtnMap = new Map<String, Set<String>>();
        //set of m6 circuit ids
        Set<String> m6CircuitSet = new Set<String>();
        //Map from m6 circuit Id to asset
        Map<String, Asset> existingAssetMap = new Map<String, Asset>();
        //generic circuit ids
        Set<Id> circuitIds = new Set<Id>();
        List<ftr_Asset_StagingCircuit__c> circuitUpdateList = new List<ftr_Asset_StagingCircuit__c>();
        for (ftr_Asset_StagingCircuit__c asset: scope) {
            asset.PriLocStreetAddress__c = asset.PriLocStreetAddress__c?.toLowerCase();
            if (!aliasACSet.contains(asset.ftr_Item_Alias__c) || m6AccNameToIgnore.contains(asset.CUST_ACCT_NBR__c)) {
                continue;
            }
            if (String.isBlank(asset.PriLocStreetAddress__c)) {
                ftr_Asset_StagingCircuit__c circuitRec = new ftr_Asset_StagingCircuit__c(Id = asset.Id, Status__c = 'Needs Review', Error_Message__c = 'No Address Found', Pass_Number__c = asset.Pass_Number__c + 1 );
            		circuitUpdateList.add(circuitRec);
                	continue;
            }
            asset.ftr_circuitName__c = asset.ftr_circuitName__c.replaceAll('\\s+', '');
                asset.ftr_circuitName__c = asset.ftr_circuitName__c.removeEnd('/');
            if (String.isNotBlank(asset.WTN__c)) {
                WTNSet.add(asset.WTN__c);
                aliasSet.add(asset.ftr_Item_Alias__c);
                Streetadd.add(asset.PriLocStreetAddress__c);
                
                //streetAddrToWtnMap.put(asset.PriLocStreetAddress__c, asset.WTN__c);
                circuitMap.put(asset.Id, asset);
                m6CircuitSet.add(asset.ftr_circuitName__c);
                system.debug('ceheck ' + asset.ftr_Item_Alias__c);
                system.debug('ceheck ' + asset.ftr_Item_Alias__c.equalsIgnoreCase('uni'));
                if (asset.ftr_Item_Alias__c.equalsIgnoreCase('uni')) {
                    //system.debug('put in  uniCNameToCircuitMap');
                    uniCNameToCircuitMap.put(asset.ftr_circuitName__c, asset);
                } else {
                    circuitIds.add(asset.Id);
                    if(String.isNotBlank(asset.ftr_RUID1__c)){
                    asset.ftr_RUID1__c = asset.ftr_RUID1__c.replaceAll('\\s+', '');
                   asset.ftr_RUID1__c = asset.ftr_RUID1__c.removeEnd('/');
                    }  
                    if(String.isNotBlank(asset.ftr_RUID2__c))   {
                  asset.ftr_RUID2__c = asset.ftr_RUID2__c.replaceAll('\\s+', '');
                asset.ftr_RUID2__c = asset.ftr_RUID2__c.removeEnd('/');
                    }
                }
                circuitWtnMap.put(asset.Id, asset.WTN__c);
                cNameToCIdMap.put(asset.ftr_circuitName__c,asset.Id);
                if (wtnToCircuitMap.containsKey(asset.WTN__c)) {
                    Set < Id > tempSet = wtnToCircuitMap.get(asset.WTN__c);
                    tempSet.add(asset.Id);
                    wtnToCircuitMap.put(asset.WTN__c, tempSet);
                } else {
                    Set < Id > tempSet = new Set < Id > {
                        asset.Id
                    };
                    wtnToCircuitMap.put(asset.WTN__c, tempSet);
                }
            }
            if (String.isBlank(asset.WTN__c)) { 
                if (asset.ftr_Item_Alias__c.equalsIgnoreCase('uni')) {
                    system.debug('put in  uniCNameToCircuitMap');
                    uniCNameToCircuitMap.put(asset.ftr_circuitName__c, asset);
                } else {
                    ftr_Asset_StagingCircuit__c circuitRec = new ftr_Asset_StagingCircuit__c(Id = asset.Id, Status__c = 'Needs Review', Error_Message__c = 'No WTN Found', Pass_Number__c = asset.Pass_Number__c + 1);
            		circuitUpdateList.add(circuitRec);
                	continue;
                }	
            }
            if (string.isNotBlank(asset.CUST_ACCT_NBR__c)) {
                aliasSet.add(asset.ftr_Item_Alias__c);
                Streetadd.add(asset.PriLocStreetAddress__c);
                circuitMap.put(asset.Id, asset);
                m6CircuitSet.add(asset.ftr_circuitName__c);
                M6CustNoSet.add(asset.CUST_ACCT_NBR__c);
                cNameToCIdMap.put(asset.ftr_circuitName__c,asset.Id);
                    if (M6CustNoToCircMap.containsKey(asset.CUST_ACCT_NBR__c)) {
                        Set < Id > tempSet = M6CustNoToCircMap.get(asset.CUST_ACCT_NBR__c);
                        tempSet.add(asset.Id);
                        M6CustNoToCircMap.put(asset.CUST_ACCT_NBR__c, tempSet);
                    } else {
                        Set < Id > tempSet = new Set < Id > {
                            asset.Id
                        };
                        M6CustNoToCircMap.put(asset.CUST_ACCT_NBR__c, tempSet);
                    }
                circuitIds.add(asset.Id);
                    if(String.isNotBlank(asset.ftr_RUID1__c)){
                    asset.ftr_RUID1__c = asset.ftr_RUID1__c.replaceAll('\\s+', '');
                   asset.ftr_RUID1__c = asset.ftr_RUID1__c.removeEnd('/');
                    }  
                    if(String.isNotBlank(asset.ftr_RUID2__c))   {
                  asset.ftr_RUID2__c = asset.ftr_RUID2__c.replaceAll('\\s+', '');
                asset.ftr_RUID2__c = asset.ftr_RUID2__c.removeEnd('/');
                    }
            } 
        }
      
        if (!aliasSet.isEmpty()) {
            aliasToPriceBEntryMap = MACDAssetBatchNewCIDHelper.getAliasToProductIdMap(aliasSet);
           // priceListId = MACDAssetBatchNewCIDHelper.getPriceListId();
            //system.debug('check aliasToPriceBEntryMap ' + aliasToPriceBEntryMap);
            //system.debug('check aliasToPriceBEntryMap key values ' + aliasToPriceBEntryMap.keySet());
        }
        system.debug('M6CustNoToCircMap ' + M6CustNoToCircMap);
        system.debug('M6CustNoSet ' + M6CustNoSet); 
        //System.debug('wtnToCircuitMap debug ' + wtnToCircuitMap);
        if (!WTNSet.isEmpty()) {
            //system.debug('Print WTNSet' + WTNSet);
            for (ftr_Asset_Staging_OCAM__c ocam: [SELECT Id, CUST_NO__c, BTN__c FROM ftr_Asset_Staging_OCAM__c WHERE BTN__c IN: wtnToCircuitMap.keySet()]) {
                if (ocam.CUST_NO__c.startsWith('001')) {
                    CusNoSetId.add(ocam.CUST_NO__c);
                    Set < Id > tempCIdSet = wtnToCircuitMap.containsKey(ocam.BTN__c) ? wtnToCircuitMap.get(ocam.BTN__c) : new Set < Id > ();
                    Set < Id > tempCIdSet1 = idAccCircuitIdMap.containsKey(ocam.CUST_NO__c) ? idAccCircuitIdMap.get(ocam.CUST_NO__c) : new Set < Id > ();
                    //tempWtnSet.add(ocam.BTN__c);
                    tempCIdSet1.addAll(tempCIdSet);
                    idAccCircuitIdMap.put(ocam.CUST_NO__c, tempCIdSet1);
                } else {
                    CusNoSet.add(ocam.CUST_NO__c);
                    Set < Id > tempCIdSet = wtnToCircuitMap.containsKey(ocam.BTN__c) ? wtnToCircuitMap.get(ocam.BTN__c) : new Set < Id > ();
                    Set < Id > tempCIdSet1 = CuNoCircuitIdMap.containsKey(ocam.CUST_NO__c) ? CuNoCircuitIdMap.get(ocam.CUST_NO__c) : new Set < Id > ();
                    //System.debug('tempCIdSet debug ' + tempCIdSet);
                    //System.debug('tempCIdSet1 debug ' + tempCIdSet1);
                    //tempWtnSet.add(ocam.BTN__c);
                    tempCIdSet1.addAll(tempCIdSet);
                    //system.debug('tempCIdSet1 after add all ' + tempCIdSet1);
                    //idAccWtnMap.put(ocam.CUST_NO__c, tempCIdSet1.addAll(tempCIdSet));
                    //Set < String > tempWtnSet = CuNoWtnMap.containsKey(ocam.CUST_NO__c) ? CuNoWtnMap.get(ocam.CUST_NO__c) : new Set < String > ();
                    //tempWtnSet.add(ocam.BTN__c);
                    CuNoCircuitIdMap.put(ocam.CUST_NO__c, tempCIdSet1);
                }

            }
            system.debug('Print CusNoSet' + CusNoSet);
           system.debug('Print CusNoSetId' + CusNoSetId);
            // system.debug('Print CuNoCircuitIdMap' + CuNoCircuitIdMap);
            // system.debug('Print idAccCircuitIdMap' + idAccCircuitIdMap);
            Map < String, Account > WtntoAccMap = new Map < String, Account > ();
			
            if (M6CustNoSet != null && M6CustNoSet.size() > 0){
                for (Account acc : [SELECT Id, Customer_Number__c,M6_Customer_Number__c,account_id_caps__c  from Account where (M6_Customer_Number__c IN:M6CustNoSet OR account_id_caps__c  IN: M6CustNoSet) and RecordType.developername = 'Master'
                                order by createddate desc]) {
                        if (M6CustNoSet.contains(acc.M6_Customer_Number__c)) {
                        Set < Id > tempCIdSet = M6CustNoToCircMap.get(acc.M6_Customer_Number__c);
                        for (Id cId: tempCIdSet) {
                            if(!circuitAccMap.containsKey(cId)) {
                                circuitAccMap.put(cId, acc);
                            }
                        }
                        //WtnACCMap.put(CuNoWtnMap.get(acc.Customer_Number__c),acc);
                        //finalwtn.addAll(CuNoWtnMap.get(acc.Customer_Number__c));
                    }
                         if ( M6CustNoSet.contains(acc.account_id_caps__c )) {
                        Set < Id > tempCIdSet = M6CustNoToCircMap.get(acc.account_id_caps__c );
                        for (Id cId: tempCIdSet) {
                            if(!circuitAccMap.containsKey(cId)) {
                                circuitAccMap.put(cId, acc);
                            }
                        }
                    }
                }
            }
            system.debug('CusNoSet ==> ' + CusNoSet);
            if (CusNoSet != null && CusNoSet.size() > 0){
                for (Account acc : [SELECT Id, Customer_Number__c,M6_Customer_Number__c,account_id_caps__c  from Account where (Customer_Number__c IN: CusNoSet) and RecordType.developername = 'Master'
                                order by createddate desc]) {
                        if (CusNoSet.contains(acc.Customer_Number__c)) {
                        Set < Id > tempCIdSet = CuNoCircuitIdMap.get(acc.Customer_Number__c);
                        for (Id cId: tempCIdSet) {
                            if(!circuitAccMap.containsKey(cId)) {
                                circuitAccMap.put(cId, acc);
                            }
                        }
                        //WtnACCMap.put(CuNoWtnMap.get(acc.Customer_Number__c),acc);
                        //finalwtn.addAll(CuNoWtnMap.get(acc.Customer_Number__c));
                    }
                }
            }
            
            if (CusNoSetId != null && CusNoSetId.size() > 0){
                for (Account acc : [SELECT Id, Customer_Number__c,M6_Customer_Number__c,account_id_caps__c  from Account where(Id IN: CusNoSetId) and RecordType.developername = 'Master'
                                order by createddate desc]) {
                        if (CusNoSetId.contains(acc.Id)) {
                        Set < Id > tempCIdSet = idAccCircuitIdMap.get(acc.Id);
                        for (Id cId: tempCIdSet) {
                            if(!circuitAccMap.containsKey(cId)) {
                                circuitAccMap.put(cId, acc);
                            }
                        }
                        //WtnACCMap.put(idAccWtnMap.get(acc.Customer_Number__c),acc);
                        //finalwtn.addAll(idAccWtnMap.get(acc.Customer_Number__c));
                    }
                }
            }

            //  Map<Id,Account> AccountMap = new Map<Id,Account>([SELECT Id from Account where (Customer_Number__c IN: CusNoSet or Id IN: CusNoSetId) and RecordType.developername ='Master']);   
            //for (Account acc: [SELECT Id, Customer_Number__c,M6_Customer_Number__c,X18_Digit_Acct_ID__c from Account where(Customer_Number__c IN: CusNoSet or Id IN: CusNoSetId or M6_Customer_Number__c IN:M6CustNoSet or X18_Digit_Acct_ID__c IN: M6CustNoSet) and RecordType.developername = 'Master'
            //        order by createddate desc
            system.debug('accList print '+ accList);
        }
        // system.debug('Print WtnACCMap' + WtnACCMap);
        // system.debug('circuitAccMap print ' + circuitAccMap);
        MACDAssetBatchNewCIDHelper.updateAccounts(circuitAccMap, circuitMap);
        cIdAccSerMap = MACDAssetBatchNewCIDHelper.getServiceAccId(circuitMap, CuNoCircuitIdMap, idAccCircuitIdMap, wtnAccIds, Streetadd, M6CustNoToCircMap, circuitAccMap);
        system.debug('Print cIdAccSerMap' + cIdAccSerMap);
        for (Id cId : cIdAccSerMap.keySet()) {
            system.debug(cId + '===> ' + cIdAccSerMap.get(cId).Id);
        }
        //map from circuit id to service aacount
        Map < Id, Account > circuitIdToServAccMap = new Map < Id, Account > ();
        // System.debug('final wtn ' + finalwtn);
        // system.debug('wtn to circuot map ' + wtnToCircuitMap);
        Map < Id, Id > circuitIdAddressMap = new Map < Id, Id > ();
        Map < String, Id > sameStreetCircuitIdMap = new Map < String, Id > ();
            Id SerAccId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get('Service').getRecordTypeId();
            for (Id cId: circuitIds) {
                if (circuitAccMap.containsKey(cId)) {
                    // circuitMap.get(cId).Status__c = 'Complete';
                    // system.debug('street address ' + circuitMap.get(cId).PriLocStreetAddress__c);
                    if (!cIdAccSerMap.containsKey(cId)) {
                        if (!sameStreetCircuitIdMap.containsKey(circuitMap.get(cId).PriLocStreetAddress__c)) {
                            Account acc = new Account(RecordTypeId = SerAccId);
                            //acc.Name = 'Service account';
                            acc.Name = circuitMap.get(cId).PriLocStreetAddress__c + ', ' + circuitMap.get(cId).PriLocPostalCode__c;
                            acc.ParentId = circuitAccMap.get(cId).id;
                            acc.ShippingStreet = circuitMap.get(cId).PriLocStreetAddress__c;
                            acc.ShippingCity = circuitMap.get(cId).PriLocCity__c;
                            acc.BillingCity = circuitMap.get(cId).PriLocCity__c;
                            acc.ShippingStateCode = circuitMap.get(cId).PriLocState__c;
                            acc.ShippingPostalCode = circuitMap.get(cId).PriLocPostalCode__c;
                            acc.BillingPostalCode = circuitMap.get(cId).PriLocPostalCode__c;
                            acc.BillingStreet = circuitMap.get(cId).PriLocStreetAddress__c;
                            acc.BillingStateCode = circuitMap.get(cId).PriLocState__c;

                            circuitIdToServAccMap.put(cId, acc);
                            // system.debug('Into Insert' + cIdAccSerMap);
                            sameStreetCircuitIdMap.put(circuitMap.get(cId).PriLocStreetAddress__c, cId);
                        } else if (sameStreetCircuitIdMap.containsKey(circuitMap.get(cId).PriLocStreetAddress__c)) {
                            circuitIdAddressMap.put(cId, sameStreetCircuitIdMap.get(circuitMap.get(cId).PriLocStreetAddress__c));
                        }
					
                    } else {
                        circuitIdToServAccMap.put(cId, cIdAccSerMap.get(cId));
                    }
                    // system.debug('sameStreetCircuitIdMap ' + sameStreetCircuitIdMap);
                    // system.debug('circuitIdAddressMap ' + circuitIdAddressMap);
                }
                else if (!circuitAccMap.containsKey(cId)) {
                    if (String.isNotBlank(circuitMap.get(cId).CUST_ACCT_NBR__c)) {
                        if (circuitMap.get(cId).CUST_ACCT_NBR__c.startsWith('001')) {
                            ftr_Asset_StagingCircuit__c circuitRec = new ftr_Asset_StagingCircuit__c(Id =circuitMap.get(cId).Id, Status__c = 'Needs Review', Error_Message__c = 'No Master Account Found', Pass_Number__c = circuitMap.get(cId).Pass_Number__c + 1 );
                    		circuitUpdateList.add(circuitRec);
                        } else {
                            ftr_Asset_StagingCircuit__c circuitRec = new ftr_Asset_StagingCircuit__c(Id =circuitMap.get(cId).Id, Status__c = 'Needs Review', Error_Message__c = 'No OCAM Data Found', Pass_Number__c = circuitMap.get(cId).Pass_Number__c + 1 );
                    		circuitUpdateList.add(circuitRec);
                        }
                    }
                }

            }

        system.debug('Print cIdAccSerMap' + cIdAccSerMap);
        system.debug('printcircuitIdToServAccMap  ' + circuitIdToServAccMap);
        for (Id cId : circuitIdToServAccMap.keySet()) {
            system.debug(cId + '===> ' + circuitIdToServAccMap.get(cId).ShippingStreet);
        }
        Map<String, List<Asset>> ruid2ToAssetMap = new Map<String, List<Asset>>();
        Set<Account> newAccs = new Set<Account>(circuitIdToServAccMap.values());
        List<Account> serAccList = new List<Account>(newAccs);
        Database.upsert(serAccList, false);
        //get existing asssets
        Map < String, Schema.SObjectField > fieldMap = Asset.sObjectType.getDescribe().fields.getMap();
        Set<String> assetFields = new Set<String>();
        for (String field: fieldMap.keySet()) {
            if (field.contains('__c')) {
                
            }
            assetFields.add(field);
            //distinctAttributesByApiName.put(field, new Set < String > ());
        }
        assetFields.add('Product2.Id');
        assetFields.add('Product2.Name');
        queryString = 'SELECT ' + String.join((Iterable < String > ) assetFields, ',') + ' FROM Asset WHERE M6_CircuitId__c IN: m6CircuitSet';
        //query for existing assets
        for (Asset asset : Database.query(queryString)) {
            if (!existingAssetMap.containsKey(asset.M6_CircuitId__c)) {
                existingAssetMap.put(asset.M6_CircuitId__c, asset);
            }
        }    
        for (Id cId: circuitIds) {
                if (!circuitAccMap.containsKey(cId)) {
                	continue;
            	}
                asset s = new asset(Source__c = Label.Asset_Created_From_MACD_Asset_Batch);
            
                if (circuitIdAddressMap.containsKey(cId)) {
                    Id reqCId = circuitIdAddressMap.get(cId);
                    if (circuitIdToServAccMap.containsKey(reqCId)) {
                        s.vlocity_cmt__ServiceAccountId__c = circuitIdToServAccMap.get(reqCId).Id;
                    } else {
                        continue;
                    }
                } else {
                    if (circuitIdToServAccMap.containsKey(cId)) {
                        s.vlocity_cmt__ServiceAccountId__c = circuitIdToServAccMap.get(cId).Id;
                    } else {
                        continue;
                    }
                }
                s.AccountId = circuitAccMap.get(cId).Id;
                // system.debug('alias print failing ' + circuitMap.get(cId).ftr_Item_Alias__c);
                if (!aliasToPriceBEntryMap.containsKey(circuitMap.get(cId).ftr_Item_Alias__c)) {
                    continue;
                }
                s.Name = aliasToPriceBEntryMap.get(circuitMap.get(cId).ftr_Item_Alias__c).Product2.Name;
                s.vlocity_cmt__LineNumber__c =  circuitMap.get(cId).Name.substringAfter('-');
                if (aliasToPriceBEntryMap.containsKey(circuitMap.get(cId).ftr_Item_Alias__c)) {
                    s.Product2Id =  aliasToPriceBEntryMap.get(circuitMap.get(cId).ftr_Item_Alias__c).Product2.Id;
                    s.vlocity_cmt__PricebookEntryId__c  = aliasToPriceBEntryMap.get(circuitMap.get(cId).ftr_Item_Alias__c).Id;
                }
            //if already exisitng asset
            if (existingAssetMap.containsKey(circuitMap.get(cId).ftr_circuitName__c)) {
                s.vlocity_cmt__JSONAttribute__c = existingAssetMap.get(circuitMap.get(cId).ftr_circuitName__c).vlocity_cmt__JSONAttribute__c;
            } else {
                s.vlocity_cmt__JSONAttribute__c = aliasToPriceBEntryMap.get(circuitMap.get(cId).ftr_Item_Alias__c).Product2.vlocity_cmt__JSONAttribute__c;
            }
                s.vlocity_cmt__JSONAttribute__c = MACDAssetBatchNewCIDHelper.getJSONAttribute(s.vlocity_cmt__JSONAttribute__c, circuitMap.get(cId) , assetJSONMappings);
                s.vlocity_cmt__PriceListId__c = priceListId;
                s.vlocity_cmt__Action__c = 'Add';
                s.vlocity_cmt__EffectiveOneTimeTotal__c = 0;
                s.vlocity_cmt__EffectiveQuantity__c = 1;
                s.Quantity = 1;
                s.vlocity_cmt__EffectiveRecurringTotal__c = 0;
                s.vlocity_cmt__OneTimeCalculatedPrice__c = 0;
                s.vlocity_cmt__OneTimeCharge__c = 0;
                s.vlocity_cmt__OneTimeTotal__c = 0;
                s.vlocity_cmt__ProvisioningStatus__c = 'Active';
                s.Price = 0;
                s.M6_ServiceItemId__c = circuitMap.get(cId).ftr_ServiceItemId__c;
                s.M6_ParentServiceItemId__c = circuitMap.get(cId).ftr_PSR_parentServiceItemId__c;
                s.M6_CircuitId__c = circuitMap.get(cId).ftr_circuitName__c;
                //to store uni ciruict name
                s.RUID_1_Originating_CE_VLAN_ID__c = circuitMap.get(cId).ftr_RUID1__c;
                s.RUID_2_Terminating_CE_VLAN_ID__c = circuitMap.get(cId).ftr_RUID2__c;
                s.DPI_WTN__c = circuitMap.get(cId).WTN__c;
                s.M6_Cust_Acc_Number__c = circuitMap.get(cId).CUST_ACCT_NBR__c;
                s.M6_Document_Number__c = circuitMap.get(cId).ftr_documentNumber__c;
               s.LAN_IP__c = circuitMap.get(cId).LAN_IP__c;
                if (aliasToPriceBEntryMap.get(circuitMap.get(cId).ftr_Item_Alias__c).ProductCode == 'ENT_ETH_EIA_0002') {
                    diaCircuitNameSet.add(s.M6_CircuitId__c);
                }
                assetList.add(s);
            }
        if (!assetList.isempty()) {
            // system.debug('MACD_Asset_Batch' + assetList);
            Schema.SObjectField extField = Asset.fields.M6_CircuitId__c;
            Database.upsertResult[] upsertRes = Database.upsert(assetList, extField, false);
            // system.debug('cNameToCIdMap check ' + cNameToCIdMap);
            MACDAssetBatchNewCIDHelper.AssetResult assetResult = MACDAssetBatchNewCIDHelper.getAssetResult(upsertRes, cNameToCIdMap, assetList, circuitMap);
            assetToCircuitMap.putAll(assetResult.assetToCircuitMap);
            // system.debug('assetToCircuitMap in main batch ' + assetToCircuitMap);
            // system.debug('assetresult in check ' + assetResult);
            ruid2ToAssetMap = assetResult.ruid2ToAssetMap;
            circuitUpdateList.addAll(MACDAssetBatchNewCIDHelper.updateCircuitRecords(assetResult.successCIds, assetResult.failedCIds, circuitMap));
        }
        // system.debug('print ruid2ToAssetMap ' + ruid2ToAssetMap);
        if (!circuitUpdateList.isEmpty()) {
            for (ftr_Asset_StagingCircuit__c circuitRec : circuitUpdateList) {
                if (String.isBlank(circuitMap?.get(circuitRec.Id)?.WTN__c)) {
                    continue;
                }
                if (circuitMap.get(circuitRec.Id).WTN__c.length() != 10) {
                    circuitRec.Notes__c = 'WTN length should be exact 10';
                }
            }
            update circuitUpdateList;
        }
        Set<Id> assetIdToBatch = new Set<Id>();
        List<Asset> updateAssetList = new List<Asset>();
        //update assets
        for (Asset asset : assetList) {
            if (asset.isSet('Id')) {
                //asset.vlocity_cmt__ParentItemId__c = asset.Id;
                asset.vlocity_cmt__ProductHierarchyPath__c = asset.Product2Id;
                asset.vlocity_cmt__ProductHierarchyGroupKeyPath__c = asset.vlocity_cmt__ProductGroupKey__c;
                if (!diaCircuitNameSet.contains(asset.M6_CircuitId__c)) {
                    /*String uniCircuitName = (String)ftr_CpqHelper.getJSONAttributeValue(asset.vlocity_cmt__JSONAttribute__c, 'ATTR_TECH_CE_VLAN_ID');
                	uniCircuitNameSet.add(uniCircuitName);
                    Set<Id> tempCIdSet = uniCircuitNameToDiaIdSet.containsKey(uniCircuitName)?uniCircuitNameToDiaIdSet.get(uniCircuitName):new Set<Id>();
                    tempCIdSet.add(asset.Id);
                    uniCircuitNameToDiaIdSet.put(uniCircuitName, tempCIdSet);*/
                    diaCircuitNameSet.remove(asset.M6_CircuitId__c);
                }
                //diaCircuitNameSet.add(asset.M6_CircuitId__c);
                assetIdToBatch.add(asset.Id);
                updateAssetList.add(asset);
                // system.debug('assetIdToBatch test ' + assetIdToBatch);
            } else {
                diaCircuitNameSet.remove(asset.M6_CircuitId__c);
            }
        }
        // system.debug('updateAssetList ' + updateAssetList);
        if (!updateAssetList.isEmpty()) {
            update updateAssetList;
        } 
        List<Asset> evplZUpdateList = new List<Asset>();
        for (Asset evplA : [SELECT Id, Name, ProductCode, vlocity_cmt__LineNumber__c, Uni_Host__r.M6_CircuitId__c FROM Asset WHERE Uni_Host__r.M6_CircuitId__c IN: ruid2ToAssetMap.keySet() AND ProductCode = 'ENT_ETH_EVPL_0002']) {
            for (Asset evplZ : ruid2ToAssetMap.get(evplA.Uni_Host__r.M6_CircuitId__c)) {
                Asset s = new Asset(Id = evplZ.Id);
            	s.vlocity_cmt__LineNumber__c = evplA.vlocity_cmt__LineNumber__c + '.' + '0001';
                s.Source__c = Label.Asset_Created_From_MACD_Asset_Batch;
                evplZUpdateList.add(s);
            }
        }
        // system.debug('evplZUpdateList print ' + evplZUpdateList);
        if (!evplZUpdateList.isEmpty()) {
            update evplZUpdateList;
        }
        
        
    }

    global void finish(Database.BatchableContext BC) {
        //system.debug('assetToCircuitMap in finish methodf ' + assetToCircuitMap);
        //system.debug('circuit name set in finish methodf ' + diaCircuitNameSet);
        //system.debug('uniCNameToCircuitMap print in finsih method ' + uniCNameToCircuitMap);
        //if (!diaCircuitNameSet.isEmpty()) {
      Database.executeBatch(new MACDAssetDIAIPBatch(diaCircuitNameSet, assetToCircuitMap, uniCNameToCircuitMap), 50);
        //}
    }
}