public class FTRWSCVDController {
    public static final List<String> qosArr = new List<String>{'Silver', 'Gold', 'Platinum'};
    public static final List<String> speedArr = new List<String>{'M', 'G'}; 
    
    @AuraEnabled
    public static String getPNums(String acna) {
        
        String response = FTRWSCVDInterface.getPNUMs(acna);
        if(response != null && response != '') {
            response =  response.substring(response.indexOf('PNum')+7, response.length()-2);
        }
        System.debug('Get pnums final response: ' + response);
        return response;
    }
    
    @AuraEnabled
    public static FTRWSCVDProductResponse getWSProductsAndRates(ID addressId, String pNUM) {
        
        FTRWSCVDRatesRequest request = new FTRWSCVDRatesRequest();
        
        request.addressId = addressId;
        request.pNUM = pNUM;
        
        FTRWSAddress__c address = [Select Street_Number__C, Street_Name__C, City__c, State__c, Unit_Number__c, Service_Control_Number__C, CLLI_Code__C, 
                                   Fiber_Tier__c, DSAT_Max_Speed__c, Copper_Tier__c, WireCenter_CLLI__c, DPI_Qualified__c, DSAT_Validated__c, DSAT_Qualified__c, Max_Qos__c
                                   from FTRWSAddress__c where Id=:addressId];
        
                                   request.address = (String.isNotBlank(address.Street_Number__c) ? address.Street_Number__c + ' ' : '') + address.Street_Name__c;
        
        
        String dsatClliCode = address.WireCenter_CLLI__c;
        
        request.cntrlKey = address.Service_Control_Number__c;
        request.city = address.City__c;
        
        request.swc = address.WireCenter_CLLI__c;
        request.stateCd = address.State__c;
        
        String dsatTier = '';
        String dsatSpeed = '';
        
        if(address.Fiber_Tier__c != null && address.Fiber_Tier__c != '') {
            dsatTier = address.Fiber_Tier__c;    
            dsatSpeed = getFormattedDsatSpeed(address.DSAT_Max_Speed__c);
            System.debug('Choosing fiber tier and speed as the cvd tier and speed');
        } else if(address.Copper_Tier__c != null && address.Copper_Tier__c != '') {
            dsatTier = address.Copper_Tier__c;
            dsatSpeed = dsatSpeed = getFormattedDsatSpeed('50M');
            System.debug('Choosing copper tier and speed as the cvd tier and speed');
        }
        
        System.debug('Filtering cvd products with dsat tier as:' + dsatTier + ' dsat speed as :' + dsatSpeed);
        
        FTRWSCVDRatesResponse response = null;
        
        //adding DPI qualified and DSAT validated check for defect fix - SDDD-1724
        if(address.DSAT_Validated__c == true) {
            response = FTRWSCVDInterface.getCVDRates(request);
        }
        boolean dpiQualified = address.DPI_Qualified__c;
        boolean dsatQualified = address.DSAT_Qualified__c;
        
        return processCVDResponse(response, dsatSpeed, dsatTier, dsatQualified, dpiQualified, address.Max_Qos__c,address.DSAT_Validated__c);
    }
    
    public static String getFormattedDsatSpeed(String dsatSpeed) {
        
        String returnVal = '';
        if(dsatSpeed != null && dsatSpeed != '') {
            String tempStr = '';
            if(dsatSpeed.contains('G')) {
                tempStr = dsatSpeed.substring(0, dsatSpeed.indexOf('G'));
                Integer speedInt = Integer.valueOf(tempStr);
                speedInt = speedInt * 1000;
                returnVal = String.valueOf(speedInt);
            } else if(dsatSpeed.contains('g')) {
                tempStr = dsatSpeed.substring(0, dsatSpeed.indexOf('g'));
                Integer speedInt = Integer.valueOf(tempStr);
                speedInt = speedInt * 1000;
                returnVal = String.valueOf(speedInt);
            } else if(dsatSpeed.contains('M')) {
                returnVal = dsatSpeed.substring(0, dsatSpeed.indexOf('M'));
            } else if(dsatSpeed.contains('m')) {
                returnVal = dsatSpeed.substring(0, dsatSpeed.indexOf('m'));
            }
        }
        
        return returnVal;
    }
    
    //New method to process cvd rates and products. Not using the dsatTier for filtering at this point
    //No need to use dsatSpeed for filtering the products as per defect: SDDD-1838
    private static FTRWSCVDProductResponse processCVDResponse(FTRWSCVDRatesResponse cvdRatesResponse, String dsatSpeed, String dsatTier, boolean dsatQualified, boolean dpiQualified, String dsatQos,boolean dsatValidated) {
        List<WSCatalogItems> categoryProdList = new List<WSCatalogItems> ();
        FTRWSCVDProductResponse productResponse = new FTRWSCVDProductResponse();
        productResponse.cvdPriceTier = '0';
        
        if(/*dsatQualified != true || */cvdRatesResponse == null) {
            System.debug('Null response from CVD getRates service, no cvd products returned to product catalog, only returning NON CVD products');
            //categoryProdList.addAll(getNonCVDProductCatalogItems()); // commented by siva on 09/22/2021
            productResponse.items = categoryProdList;
            return productResponse;
        }
        
        if(cvdRatesResponse.error != null) {
            productResponse.error = cvdRatesResponse.error;
            System.debug('Error response returned from CVD getRates service, no cvd products returned to product catalog, only returning NON CVD products');
            System.debug('CVD Error' + cvdRatesResponse.error);
            //categoryProdList.addAll(getNonCVDProductCatalogItems()); // commented by siva on 09/22/2021
            productResponse.items = categoryProdList;
            return productResponse;
        }
        
        if(cvdRatesResponse.Address != null) {
            
            if(cvdRatesResponse.Address.lookUpUsed != null && cvdRatesResponse.Address.lookUpUsed != '') {
                productResponse.cvdLookupUsed =  cvdRatesResponse.Address.lookUpUsed;
            }
            
            
            if(cvdRatesResponse.Address.UsocTier != null && cvdRatesResponse.Address.UsocTier != '') {
                productResponse.cvdPriceTier = cvdRatesResponse.Address.UsocTier;
            }
        }
        
        List<FTRWSCVDRate> filteredRateList = cvdRatesResponse.Rate;
        List<FTRWSCVDRate> filteredRateList1 = new List<FTRWSCVDRate>();
        
        if(filteredRateList == null || filteredRateList.size() == 0) {
            System.debug('Null Rates returned for the CVD get Rates' + cvdRatesResponse);
            FTRWSCVDError error = new FTRWSCVDError();
            error.message = 'Null Rates returned from CVD';
            productResponse.error = error;
            return productResponse;            
        }
        
        if(dpiQualified) {
            if(dsatValidated) {
                for(FTRWSCVDRate rate: filteredRateList) {
                    /* Vyshnavi Disabled for SDDD-2873 starts
                    if(rate.circuitType == 'EVC') {
                        if(!evcQOSmatchesDsatQOS(rate, dsatQOS)) {
                            System.debug('Skipping the cvd rate as the cvd qos is:' + getQualityOfService(rate) + ' and DSAT qos:' + dsatQos ); 
                            continue;
                        }                        

                    } 
                   Vyshnavi Disabled for SDDD-2873 ends */
                    
                    /* else {
if(String.isNotBlank(rate.uniSpeed)) {
rate.uniSpeed = getSpeedInGBs(rate.uniSpeed);
}                    

} */         
                    
                    if(rate.vta == '*') {
                        List<FTRWSCVDRate> cloneRateList = cloneRateObjectWithStarTerm(rate);
                        filteredRateList1.addAll(cloneRateList);
                    } 
                    else {
                        filteredRateList1.add(rate);
                    }
                }                
            } 
            else {
                //If an address is DPI only qualified - PNUM should return all the products with all the speeds and QOS as per defect: SDDD-1724
                for(FTRWSCVDRate rate: filteredRateList) {
                    if(rate.vta == '*') {
                        List<FTRWSCVDRate> cloneRateList = cloneRateObjectWithStarTerm(rate);
                        filteredRateList1.addAll(cloneRateList);
                    } else {
                        filteredRateList1.add(rate);
                    }
                }                
            }
        } 
        else {
            //return CVD products even if DSAT only qualified
            if(dsatValidated) {
                for(FTRWSCVDRate rate: filteredRateList) {
                    /* Vyshnavi Disabled for SDDD-2873 starts
                    if(rate.circuitType == 'EVC') {
                        if(!evcQOSmatchesDsatQOS(rate, dsatQOS)) {
                            System.debug('Skipping the cvd rate as the cvd qos is:' + getQualityOfService(rate) + ' and DSAT qos:' + dsatQos ); 
                            continue;
                        }
                    }            
                     Vyshnavi Disabled for SDDD-2873 ends*/
                    if(rate.vta == '*') {
                        List<FTRWSCVDRate> cloneRateList = cloneRateObjectWithStarTerm(rate);
                        filteredRateList1.addAll(cloneRateList);
                    } else {
                        filteredRateList1.add(rate);
                    }
                }        
            }
        }                                                          
        
        WSCatalogItems categoryProd = new WSCatalogItems();
        if(filteredRateList1[0] != null) {
            String categoryname = filteredRateList1[0].product;
            categoryProd.name = categoryname;
            categoryProd.productName = categoryname;
            categoryProd.disableAddToQuote = true;
            categoryProd.children = new List<WSCatalogItems>();
        }
        
        Map<String, List<FTRWSCVDRate>>evcMap = new Map<String, List<FTRWSCVDRate>>();       
        Map<String, FTRWSCVDRate>uniMap = new Map<String, FTRWSCVDRate>();
        Map<String, FTRWSCVDRate>nniMap = new Map<String, FTRWSCVDRate>();
        List<FTRWSCVDRate> uniList = new List<FTRWSCVDRate>();
        List<FTRWSCVDRate> nniList = new List<FTRWSCVDRate>();
        for (Integer i=0; i<filteredRateList1.size(); i++) {
            
            FTRWSCVDRate rateObject = filteredRateList1.get(i);
            String circuitType = rateObject.circuitType;
            String usocTier = rateObject.usocTier;            
            String term = rateObject.vta;
            
            //Christian Lusty confirmed no need to filter based on the usoc tier. CVD to do the filtering on their side
            
            if (circuitType == 'EVC' /*&& isEVCQualified(rateObject.evcSpeed, dsatSpeed)*/) {
                
                if(String.isNotBlank(rateObject.evcSpeed)) {
                    String tempSpeed = rateObject.evcSpeed;
                    rateObject.evcSpeed = getSpeedInGBs(tempSpeed);
                }                
                
                String key =  rateObject.evcSpeed;
                //if(rateObject.spec != null && rateObject.spec != '') {
                String qos = getQualityOfService(rateObject);
                if(qos != null && qos != '') {
                    key = key + ':' + qos;
                }
                //}  
                if(evcMap.containsKey(key)) {
                    List<FTRWSCVDRate> evcRateList = evcMap.get(key);
                    evcRateList.add(rateObject);    
                }  else {
                    List<FTRWSCVDRate> newEvcRateList = new List<FTRWSCVDRate> ();
                    newEvcRateList.add(rateObject);
                    evcMap.put(key, newEvcRateList); 
                }
                
                
            }
            else if(circuitType == 'UNI') {
                
                if(String.isNotBlank(rateObject.uniSpeed)) {
                    String tempSpeed = rateObject.uniSpeed;
                    rateObject.uniSpeed = getSpeedInGBs(tempSpeed);
                }                
                
              //  String key = rateObject.vta + ':' + rateObject.uniSpeed;
              //  uniMap.put(key,rateObject); 
                uniList.add(rateObject);
            }else if(circuitType == 'NNI') {
                
                if(String.isNotBlank(rateObject.uniSpeed)) {
                    String tempSpeed = rateObject.uniSpeed;
                    rateObject.uniSpeed = getSpeedInGBs(tempSpeed);
                }                
                
              //  String key = rateObject.vta + ':' + rateObject.uniSpeed;
                //nniMap.put(key,rateObject);
                nniList.add(rateObject);
            }
        }
        
        List<WSCatalogItems> mainProdList = new List<WSCatalogItems> ();
        
        categoryProd.children = mainProdList;
        categoryProdList.add(categoryProd);
        
        system.debug('EVC Map ####:' + evcMap);
        if(evcMap != null && evcMap.size() > 0) {
            for(String speedKey : evcMap.keySet()) {
                WSCatalogItems mainProduct = buildCVDMainProduct(speedKey, categoryProd.name);
                mainProdList.add(mainProduct);
                Set<String> termProdSet = new Set<String>();
                List<FTRWSCVDRate> termRates = evcMap.get(speedKey);
                for(Integer i=0; i<termRates.size(); i++) {
                    WSCatalogItems termProd = buildCVDTermProduct(termRates.get(i), mainProduct, uniList, nniList,productResponse.cvdPriceTier);
                    if(termProdSet.size()==0){
                    mainProduct.children.add(termProd);
                          termProdSet.add(termProd.name);	
                    }	
                    else if(termProdSet.size()>0 && !termProdSet.contains(termProd.name)){	
                        mainProduct.children.add(termProd);	
                    termProdSet.add(termProd.name);	
                    }
                }
                system.debug('executed mainProduct.children sort');
                mainProduct.children.sort();
            }
            system.debug('executed mainPordLIst sort');
            mainProdList.sort();
        }
        
        //categoryProdList.addAll(getNonCVDProductCatalogItems()); // commented by siva on 09/22/2021
        productResponse.items = categoryProdList;
        
        return productResponse;
    }
    
    
    public static List<FTRWSCVDRate> cloneRateObjectWithStarTerm(FTRWSCVDRate rate) {
        List<FTRWSCVDRate> rateList = new List<FTRWSCVDRate>();
        Integer size = 5;
        if(rate != null && rate.vta == '*') {
            for(Integer i=0; i<size; i++) {
                FTRWSCVDRate copyRate = new FTRWSCVDRate();
                
                
                copyRate.circuitType = rate.circuitType;
                copyRate.evcSpeed = rate.evcSpeed;
                copyRate.locTier = rate.locTier;
                copyRate.los = rate.los;
                copyRate.mrc = rate.mrc;
                copyRate.mrcUsoc = rate.mrcUsoc;
                copyRate.nrc = rate.nrc;
                copyRate.nrcUsoc = rate.nrcUsoc;
                copyRate.pNUM = rate.pNUM;
                copyRate.product = rate.product;
                copyRate.region = rate.region;
                copyRate.spec = rate.spec;
                copyRate.uniSpeed = rate.uniSpeed;
                copyRate.usocTier = rate.usocTier;
                copyRate.usocType = rate.usocType;
                
                if(i == 3) {
                    copyRate.vta = '5';    
                } else if(i == 4) {
                    copyRate.vta = 'MTM';    
                } else {
                    Integer term = i+1;
                    copyRate.vta = '' + term;    
                }
                rateList.add(copyRate);
            }
        }
        return rateList;
    }
    
    
    /*  private static boolean isEVCQualified(String evcSpeed, String dsatSpeed) {
Integer intEvcSpeed = 0;
Integer intDsatSpeed = 0;
if(evcSpeed != null && evcSpeed != '') {
if(evcSpeed.endsWith('M')) {
evcSpeed = evcSpeed.substring(0,evcSpeed.indexOf('M'));
}

intEvcSpeed = Integer.valueOf(evcSpeed);
}

if(dsatSpeed != null && dsatSpeed != '') {
if(dsatSpeed.endsWith('M')) {
dsatSpeed = dsatSpeed.substring(0,dsatSpeed.indexOf('M'));
}

intDsatSpeed = Integer.valueOf(dsatSpeed);
}

if(intEvcSpeed <= intDsatSpeed) {
return true;    
}
return false;

}*/
    
    //Code fix for defect: SDDD-1807. Filter cvd products based on the QOS
    private static boolean evcQOSmatchesDsatQOS(FTRWSCVDRate cvdRate, String dsatQOS) {
        boolean matched = false;
        String cvdQOS = getQualityOfService(cvdRate);
        
        if((cvdQOS == null || cvdQOS == '') || (dsatQOS == null || dsatQOS == '')) {
            matched = true;
        }
        if(!String.isBlank(dsatQOS) ) {
            if( dsatQOS.toUpperCase() == 'PLATINUM') {
                matched = true;
            } else if(dsatQOS.toUpperCase() == 'SILVER') {
                if(!String.isBlank(cvdQOS) && cvdQOS.toUpperCase() == dsatQOS.toUpperCase()) {
                    matched = true;
                }            
            } else if(dsatQOS.toUpperCase() == 'GOLD') {
                if(!String.isBlank(cvdQOS) ) {
                    if(cvdQOS.toUpperCase() == 'PLATINUM') {
                        matched = false;
                    } else {
                        matched = true;
                    }                     
                }
                
            }            
        }
        
        
        return matched;
    }
    
    private static WSCatalogItems buildCVDMainProduct(String speedKey, String prodName) {
        String evcSpeed = '';
        String qos = '';
        WSCatalogItems mainProdItem = null;
        if(speedKey != null && speedKey != '') {
            if(speedKey.contains(':')) {
                String [] tokens = speedKey.split(':');
                evcSpeed = tokens[0];
                qos = tokens[1];
            } else {
                evcSpeed = speedkey;
            }
            
            mainProdItem = new WSCatalogItems();
            prodName = prodName + ' ' + evcSpeed;
            if(qos != null && qos != '') {
                
                if(String.isNotBlank(prodName) && prodName.startsWithIgnoreCase('EPATH')) {
                    prodName = prodName + ' ' + qos;    
                }
                
                mainProdItem.qos = qos;
            }
            mainProdItem.name = prodName;
            mainProdItem.productName = prodName;
            mainProdItem.speed = evcSpeed;
            //mainProdItem.speed = getSpeedInGBs(evcSpeed);
            mainProdItem.disableAddToQuote = true;
            mainProdItem.children = new List<WSCatalogItems>();
            
        }
        
        return mainProdItem;
    }
    
    private static WSCatalogItems buildCVDTermProduct(FTRWSCVDRate rate, WSCatalogItems mainProduct, List<FTRWSCVDRate> uniList, List<FTRWSCVDRate> nniList,String respUsocTier ) {
        
        String mainProdName = mainProduct.name;
        String qos = mainProduct.qos;
        String term = rate.vta; 
        if(rate.vta != 'MTM') {
            term = term + ' YR';    
        }
        
        WSCatalogItems termProdItem = new WSCatalogItems();
        termProdItem.name = mainProdName + '-'+rate.vta + '-' + rate.usocTier;
        termProdItem.productName = term;
        termProdItem.parentId = mainProdName;
        termProdItem.parentName = mainProdName;
        termProdItem.speed = rate.evcSpeed;
        
        termProdItem.mrcUsoc = rate.mrcUsoc;
        termProdItem.nrcUsoc = rate.nrcUsoc;
        
        termProdItem.disableAddToQuote = true;
        termProdItem.children = new List<WSCatalogItems>();
        
        String mainProductName = termProdItem.parentId;         
        WSCatalogItems evcProd = getCatalogItemFromCircuitProd(rate, mainProductName, term, qos);
        
        termProdItem.children.add(evcProd);
        FTRWSCVDRate uniRate = getUniNniRate(rate.vta, evcProd.speed, uniList,respUsocTier,'UNI');
        System.debug('@@uniRate :: '+ uniRate );
        System.debug('@@ mainProductName :: '+ mainProductName);
        WSCatalogItems uniItem = null;                                               
        if(uniRate != null) {
            uniItem = getCatalogItemFromCircuitProd(uniRate, mainProductName, term, qos);
            termProdItem.children.add(uniItem); 
        }                                               
        FTRWSCVDRate nniRate = getUniNniRate(rate.vta, evcProd.speed, nniList,respUsocTier,'NNI');
        WSCatalogItems nniItem = null;                                               
        if(nniRate != null) {
            nniItem = getCatalogItemFromCircuitProd(nniRate, mainProductName, term, qos);
            termProdItem.children.add(nniItem); 
        } 
        System.debug('@@termProdItem :: '+termProdItem);
        return termProdItem;
    }
    
    //Processing for setting EVC/UNI/NNI circuit product at the lowest level
    private static WSCatalogItems getCatalogItemFromCircuitProd(FTRWSCVDRate rate, String mainParentId, String term, String qos) {
        WSCatalogItems item = null;
        
        if(rate != null) {
            if(rate.circuitType == 'EVC') {
                item = new WSCatalogItems();
                item.name = mainParentId + '-'+ term +'-' +'EVC' + '-' + rate.usocTier;
                item.productName = 'EVC';
                item.mrcUsoc = rate.mrcUsoc;
                item.nrcUsoc = rate.nrcUsoc;
                //item.mrc = rate.mrc;
                //item.nrc = rate.nrc;
                item.speed = rate.evcSpeed;
                //String qos = getQualityOfService(rate);
                item.qos = qos;
                
            } else if(rate.circuitType == 'UNI' ) {
                item = new WSCatalogItems();
                item.name = mainParentId + '-'+ term +'-' +'UNI' + '-' + rate.usocTier;
                item.productName = 'UNI';// + '-' + rate.uniSpeed;
                item.uniMrcUsoc = rate.mrcUsoc;
                item.uniNrcUsoc = rate.nrcUsoc;
                item.qos = qos;
                //item.mrc = rate.mrc;
                //item.nrc = rate.nrc;
                item.uniSpeed = rate.uniSpeed;
            } else if(rate.circuitType == 'NNI' ) {
                item = new WSCatalogItems();
                item.name = mainParentId + '-'+ term +'-' +'NNI' + '-' + rate.usocTier;
                item.productName = 'NNI';//  + '-' + rate.uniSpeed;
                item.nniMrcUsoc = rate.mrcUsoc;
                item.nniNrcUsoc= rate.nrcUsoc;
                item.qos = qos;
                //item.mrc = rate.mrc;
                //item.nrc = rate.nrc;
                item.nniSpeed = rate.uniSpeed;
            }
        }
        item.parentId = mainParentId;
        item.term = term;
        item.disableAddToQuote = false;
        item.pNum = rate.pNUM;
        
        if(rate.mrc == null || rate.mrc == '') {
            rate.mrc = '0.00';
        }
        item.mrc = rate.mrc;
        
        if(rate.nrc == null || rate.nrc == '') {
            rate.nrc = '0.00';
        }
        item.nrc = rate.nrc;
        //item.speed = getSpeedInGBs(item.speed);
        return item;
    }
    
    private static String getSpeedInGBs(String orignalSpeed) {
        String retSpeed = '';
        String tempSpeed = '';
        System.debug('Orignal speed: ' + orignalSpeed);
        if(String.isNotBlank(orignalSpeed) && orignalSpeed.indexOf('M') > -1) {
            tempSpeed = orignalSpeed.substring(0, orignalSpeed.indexOf('M'));
            Double speedInt = Double.valueOf(tempSpeed);
            if(speedInt >= 1000) {
                speedInt = speedInt/1000;
                retSpeed = speedInt + 'G';
            } else {
                System.debug('returning Orignal speed: ' + orignalSpeed);
                return orignalSpeed;
            }
        }
        
        System.debug('retunring retSpeed: ' + retSpeed);
        return retSpeed;
    }
    
    private static FTRWSCVDRate getUniNniRate(String term,String evcSpeedStr, List<FTRWSCVDRate> uniList,String respUsocTierM, String circuitType){
        FTRWSCVDRate returnRate = null;
        Double lastSpeed = 0.0;
        Double evcSpeed = 0.0;
        Double uniSpeed =0.0;
        Double uniMrc=0.0;
        Double returnUniMrc = returnRate!=null? Double.valueof(returnRate.mrc):0;
        Map<String, FTRWSCVDRate> loopUniMap = new Map<String, FTRWSCVDRate>();
                
        if(evcSpeedStr != null && evcSpeedStr != '') {
            if(evcSpeedStr.indexOf('M') > -1) {
                evcSpeed = Double.valueOf(evcSpeedStr.substring(0, evcSpeedStr.indexOf('M')));    
            } else if(evcSpeedStr.indexOf('G') > -1) {
                evcSpeed = Double.valueOf(evcSpeedStr.substring(0, evcSpeedStr.indexOf('G')));  
                evcSpeed = evcSpeed * 1000;
            }
            
        }

        for (FTRWSCVDRate key: uniList){
            FTRWSCVDRate uniRate = key;
            String uniTerm = uniRate.vta;
            String uniSpeedStr = uniRate.uniSpeed;
            Double respUsocTier = Double.valueOf(respUsocTierM);
            Double uniUsoc = (uniRate.usocTier !=null && uniRate.usocTier!='') ?  Double.valueOf(uniRate.usocTier.trim()):0;
            
            if(uniSpeedStr != null && uniSpeedStr != '') {
                if(uniSpeedStr.indexOf('M') > -1) {
                    uniSpeed = Double.valueOf(uniSpeedStr.substring(0, uniSpeedStr.indexOf('M')));    
                } else if(uniSpeedStr.indexOf('G') > -1) {
                    uniSpeed = Double.valueOf(uniSpeedStr.substring(0, uniSpeedStr.indexOf('G')));
                    uniSpeed = uniSpeed * 1000;
                }                
            }
            uniMrc= Double.valueof(uniRate.mrc);            
                        
            if(uniTerm == term && ((uniUsoc==respUsocTier&&circuitType=='UNI')||circuitType=='NNI')){
                
                if(circuitType=='NNI' && evcSpeed == uniSpeed ){
                    returnRate = uniRate;
                }
                else if(evcSpeed>=5 && evcSpeed<=900 && uniSpeed==1000 && returnUniMrc<uniMrc){
                    
                    returnRate = uniRate;
                    returnUniMrc= Double.valueof(uniRate.mrc);
                }
                else if(evcSpeed>900  && uniSpeed==10000 && returnUniMrc<uniMrc){
                    
                    returnRate = uniRate;
                    returnUniMrc= Double.valueof(uniRate.mrc);
                }
                
            }
            else if(uniTerm == term && evcSpeed <= uniSpeed && circuitType=='NNI'){
                if (lastSpeed == 0) {
                    lastSpeed = uniSpeed;
                    returnRate = uniRate;
                    //break;
                }
                else if(lastSpeed > unispeed){
                    lastSpeed = uniSpeed;
                    returnRate = uniRate;
                    //break;
                }              
            }
            
        }
        
        return returnRate;
    }              
    
    
    private static String getQualityOfService(FTRWSCVDRate cvdRate) {
        
        String qos = '';
        if(cvdRate.spec != null && cvdRate.spec != '') {
            qos = cvdRate.spec;
            qos = qos.capitalize();
            if(qos.startsWith('EPATH')) {
                if(qos.endsWith('G')) {
                    qos = 'Gold';  
                } else if(qos.endsWith('S')) {
                    qos = 'Silver';  
                }  if(qos.endsWith('P') || qos.endsWith('R')) {
                    qos = 'Platinum';  
                } 
            }
            else{
                Wholesale_SPEC_Qos_Converstion__mdt wsSpecQosConv = Wholesale_SPEC_Qos_Converstion__mdt.getInstance(qos);
                qos = wsSpecQosConv!=null ? wsSpecQosConv.Spec_Value__c :'';
            }
            System.debug('cvdRate.spec: qos for EPATH product: ' + cvdRate.spec +':'+ qos);            
        }  
        else if(cvdRate.product == 'EIA' && cvdRate.circuitType == 'EVC') {
            qos = 'Silver';
        } 
        
        //Start code fix: SDDD-2383 - QOS based on LOS for PNUM: EPAV001999SCM792
        if(String.isBlank(qos)) {
            String los = cvdRate.los;
            
            if(String.isNotBlank(los)) {
                System.debug('LOS returned: ' + los);
                if(los.equalsIgnoreCase('EBE')) {
                    qos = 'Silver';
                } else if(los.equalsIgnoreCase('EPD')) {
                    qos = 'Gold';
                } else if(los.equalsIgnoreCase('ERT')) {
                    qos = 'Platinum';
                }
            }
        }
        //End code fix: SDDD-2383 - QOS based on LOS for PNUM: EPAV001999SCM792        
        return qos;
    }
    
    //category for non cvd products
    private static WSCatalogItems buildCategory(String family) {
        
        WSCatalogItems category = new WSCatalogItems();
        category.children = new List<WSCatalogItems>();
        category.disableAddToQuote = true;
        category.name = family;
        category.productName = family;
        
        return category;
    }
    
    //Main product building for non CVD products
    private static WSCatalogItems buildMainProd(Product2 product, String name, Integer terms) {
        
        
        WSCatalogItems mainProd = new WSCatalogItems();
        mainProd.children = new List<WSCatalogItems>();
        mainProd.disableAddToQuote = true;
        mainProd.name = name;
        mainProd.productName = name;
        System.debug('terms for product: ' + name + ' terms size:' + terms);
        if(terms == 1) {
            mainProd.disableAddToQuote = false;
            mainProd.parentId = name;
            mainProd.parentName = name;
            System.debug(product.Family + '-- Product:Id--' + product.Description +':'+ product.Id);
            List<PricebookEntry> pbList =[select Pricebook2Id, Unitprice from PricebookEntry where Product2Id =:product.Id];// '01t55000007TePJAA0']; //
            
            if(pbList != null && pbList.size() >0) {
                if(pbList.get(0) != null && pbList.get(0).UnitPrice !=null) {
                    if(product.Recurring_Type__c == 'T') { 
                        //recurring type T is for Temporary OR NRC products
                        mainProd.nrc = pbList.get(0).UnitPrice.toPlainString();
                        mainProd.nrcTotal = pbList.get(0).UnitPrice.toPlainString();
                        
                        //setting mrc for the NRC products as 0.00
                        mainProd.mrc = '0.00';
                        mainProd.mrcTotal = '0.00';
                    } else {
                        //recurring type P is for permanent OR MRC products
                        mainProd.mrc = pbList.get(0).UnitPrice.toPlainString();
                        mainProd.mrcTotal = pbList.get(0).UnitPrice.toPlainString();
                        
                        //setting nrc for the MRC products as 0.00
                        mainProd.nrc = '0.00';
                        mainProd.nrcTotal = '0.00';
                    }
                }
            }        
            
        }
        
        return mainProd;
    }
    
    //term building for non cvd products
    public static WSCatalogItems buildNonCVDTermProd(product2 product) {
        
        System.debug(product.Family + '-- Product:Id--' + product.Description +':'+ product.Id);
        List<PricebookEntry> pbList =[select Pricebook2Id, Unitprice from PricebookEntry where Product2Id =:product.Id];// '01t55000007TePJAA0']; //
        
        WSCatalogItems termProd = null;
        if(product != null && product.Term__c != null && product.Term__c != '') {
            termProd = new WSCatalogItems();
            String term = product.Term__c + ' YR';
            termProd.productName = term;
            termProd.term = term;
            termProd.name = product.Name + '-'+ term;
            termProd.parentId = product.Name;
            
            if(pbList != null && pbList.size() >0) {
                if(pbList.get(0) != null && pbList.get(0).UnitPrice !=null) {
                    /*if(product.Recurring_Type__c == 'T') {
                        //recurring type T is for Temporary OR NRC products
                        termProd.nrc = pbList.get(0).UnitPrice.toPlainString();
                        termProd.nrcTotal = pbList.get(0).UnitPrice.toPlainString();
                        
                        //setting mrc for the NRC products as 0.00
                        termProd.mrc = '0.00';
                        termProd.mrcTotal = '0.00';
                        
                    } else {
                        //recurring type P is for permanent OR MRC products
                        termProd.mrc = pbList.get(0).UnitPrice.toPlainString();
                        termProd.mrcTotal = pbList.get(0).UnitPrice.toPlainString();
                        
                        //setting nrc for the MRC products as 0.00
                        termProd.nrc = '0.00';
                        termProd.nrcTotal = '0.00';
                        
                    }*/
                    if (product.NRC__c) {
                          //recurring type T is for Temporary OR NRC products
                        termProd.nrc = pbList.get(0).UnitPrice.toPlainString();
                        termProd.nrcTotal = pbList.get(0).UnitPrice.toPlainString();
                        
                        //setting mrc for the NRC products as 0.00
                        termProd.mrc = '0.00';
                        termProd.mrcTotal = '0.00';
                       
                        
                    } else {
                         
                        //recurring type P is for permanent OR MRC products
                        termProd.mrc = pbList.get(0).UnitPrice.toPlainString();
                        termProd.mrcTotal = pbList.get(0).UnitPrice.toPlainString();
                        
                        //setting nrc for the MRC products as 0.00
                        termProd.nrc = '0.00';
                        termProd.nrcTotal = '0.00';
                    }
                }
            }
            
            termProd.speed = product.evcspeed__c;
            //Start SDDD-2626 Defect fix - Enable "AddToQuote" button for the dark fiber products
            /* if(product.Family.startsWith('DARK')) {
termProd.disableAddToQuote = true;
} else{
termProd.disableAddToQuote = false;    
}*/
            termProd.disableAddToQuote = false;
            //End SDDD-2626 Defect fix - Enable "AddToQuote" button for the dark fiber products
            
        }
        
        return termProd;
    }
    
    public static List<WSCatalogItems> getNonCVDProductCatalogItems() {
        
        List<WSCatalogItems> nonCVDProducts = new List<WSCatalogItems>();
        Product2 prod2 = new Product2();
        
        String fotsFamily = 'FOTS';
        String edgeFamily = 'EDGE Colo';
        String darkFiber = 'DARKFIBER';
        
        Set<String> nonCVDFamilies = new Set<String>();
        nonCVDFamilies.add(fotsFamily);
        nonCVDFamilies.add(edgeFamily);
        nonCVDFamilies.add(darkFiber);
        List<Product2> productList = [Select Description, Product_ID__c, MRC__c, NRC__c, ProductCode, Recurring_Type__c, Term__c, Name, RecordTypeId, evcspeed__c, Family, IsActive from Product2 where Family IN: nonCVDFamilies];
        //order by Family];
        List<WSCatalogItems> categoryList = new List<WSCatalogItems>();
        
        Set<String> families = new Set<String>();
        Map<String, List<Product2>> mainProductsMap = new Map<String, List<Product2>>();
        Map<String, Set<String>> productFamilyMap = new Map<String, Set<String>>();
        
        
        for(Product2 product : productList) {
            String prodFamily = product.Family;
            String term = product.Term__c;
            String familyKey = prodFamily;
            String prodKey = //familyKey + ':'+ 
                product.Name;
            
            if(productFamilyMap.containsKey(familyKey)) {
                Set<String> prodNames = productFamilyMap.get(familyKey);
                prodNames.add(product.Name);
            } else {
                Set<String> products = new Set<String>();
                products.add(product.Name);
                productFamilyMap.put(familyKey, products);
            }
            
            if(mainProductsMap.containsKey(prodKey)) {
                List<Product2> mainProdsList = mainProductsMap.get(prodKey);
                mainProdsList.add(product);
            } else {
                List<Product2> mainProdList = new List<Product2>();
                mainProdList.add(product);
                mainProductsMap.put(prodKey, mainProdList);
            }
        }
        
        Set<String> familySet = new Set<String>();
        Set<String> prodSet = new Set<String>(); 
        
        System.debug('productFamilyMap' + productFamilyMap);
        System.debug('mainProductsMap' + mainProductsMap);
        
        for(String familyKey: productFamilyMap.keySet()) {
            
            String family = familyKey;
            
            WSCatalogItems categoryitem = null;
            categoryitem = buildCategory(family);
            nonCVDProducts.add(categoryitem);
            
            Set<String> productSet = productFamilyMap.get(familyKey);
            System.debug('product set for familykey:' + familyKey + '::'+ productSet );
            for(String name: productSet) {
                
                if(mainProductsMap.containsKey(name)) {
                    List<Product2> prodList = mainProductsMap.get(name);
                    System.debug('Main product map for product: '+ name + '----' + mainProductsMap.get(name));
                    WSCatalogItems mainprod = buildMainProd(prodList.get(0), name, prodList.size());
                    categoryitem.children.add(mainprod);
                    
                    if(prodList.size() > 1) {
                        for(product2 Prod: prodList) {
                            WSCatalogItems termProd = buildNonCVDTermProd(prod);
                            mainprod.children.add(termProd);
                        }
                        
                    }                    
                }   
            }
        } 
        
        return nonCVDProducts;
    }
    
    // created by siva on 09/22/2021
    public static List<WSCatalogItems> getNonCVDProductCatalogItems(String pNum) {
        
        List<WSCatalogItems> nonCVDProducts = new List<WSCatalogItems>();
        Product2 prod2 = new Product2();
        
        String fotsFamily = 'FOTS';
        String edgeFamily = 'EDGE Colo';
        String darkFiber = 'DARKFIBER';
        
        Set<String> nonCVDFamilies = new Set<String>();
        nonCVDFamilies.add(fotsFamily);
        nonCVDFamilies.add(edgeFamily);
        nonCVDFamilies.add(darkFiber);
        
        List<Product2> productList = new List<Product2>();
        
        If ( String.isNotBlank(pNum) && pNum.startsWithIgnoreCase('FOT') ){
            productList = [Select Description, MRC__c, NRC__c, Product_ID__c, ProductCode, Recurring_Type__c, Term__c, Name, RecordTypeId, evcspeed__c, Family, IsActive from Product2 where Family = 'FOTS'];
        }
        else If ( String.isNotBlank(pNum) && pNum.startsWithIgnoreCase('EDG') ){
            productList = [Select Description, MRC__c, NRC__c, Product_ID__c, ProductCode, Recurring_Type__c, Term__c, Name, RecordTypeId, evcspeed__c, Family, IsActive from Product2 where Family = 'EDGE Colo'];
        }
        else If ( String.isNotBlank(pNum) && pNum.startsWithIgnoreCase('DKF') ){
            productList = [Select Description, MRC__c, NRC__c, Product_ID__c, ProductCode, Recurring_Type__c, Term__c, Name, RecordTypeId, evcspeed__c, Family, IsActive from Product2 where Family = 'DARKFIBER'];
        }
        
        //List<Product2> productList = [Select Description, Product_ID__c, ProductCode, Recurring_Type__c, Term__c, Name, RecordTypeId, evcspeed__c, Family, IsActive from Product2 where Family IN: nonCVDFamilies];
        //order by Family];
        List<WSCatalogItems> categoryList = new List<WSCatalogItems>();
        
        Set<String> families = new Set<String>();
        Map<String, List<Product2>> mainProductsMap = new Map<String, List<Product2>>();
        Map<String, Set<String>> productFamilyMap = new Map<String, Set<String>>();
        
        
        for(Product2 product : productList) {
            String prodFamily = product.Family;
            String term = product.Term__c;
            String familyKey = prodFamily;
            String prodKey = //familyKey + ':'+ 
                product.Name;
            
            if(productFamilyMap.containsKey(familyKey)) {
                Set<String> prodNames = productFamilyMap.get(familyKey);
                prodNames.add(product.Name);
            } else {
                Set<String> products = new Set<String>();
                products.add(product.Name);
                productFamilyMap.put(familyKey, products);
            }
            
            if(mainProductsMap.containsKey(prodKey)) {
                List<Product2> mainProdsList = mainProductsMap.get(prodKey);
                mainProdsList.add(product);
            } else {
                List<Product2> mainProdList = new List<Product2>();
                mainProdList.add(product);
                mainProductsMap.put(prodKey, mainProdList);
            }
        }
        
        Set<String> familySet = new Set<String>();
        Set<String> prodSet = new Set<String>(); 
        
        System.debug('productFamilyMap' + productFamilyMap);
        System.debug('mainProductsMap' + mainProductsMap);
        
        for(String familyKey: productFamilyMap.keySet()) {
            
            String family = familyKey;
            
            WSCatalogItems categoryitem = null;
            categoryitem = buildCategory(family);
            nonCVDProducts.add(categoryitem);
            
            Set<String> productSet = productFamilyMap.get(familyKey);
            System.debug('product set for familykey:' + familyKey + '::'+ productSet );
            for(String name: productSet) {
                
                if(mainProductsMap.containsKey(name)) {
                    List<Product2> prodList = mainProductsMap.get(name);
                    System.debug('Main product map for product: '+ name + '----' + mainProductsMap.get(name));
                    WSCatalogItems mainprod = buildMainProd(prodList.get(0), name, prodList.size());
                    categoryitem.children.add(mainprod);
                    
                    if(prodList.size() > 1) {
                        for(product2 Prod: prodList) {
                            WSCatalogItems termProd = buildNonCVDTermProd(prod);
                            mainprod.children.add(termProd);
                        }
                        
                    }                    
                }   
            }
        } 
        return nonCVDProducts;
    }
    // created by siva on 09/22/2021
    
    
    
}