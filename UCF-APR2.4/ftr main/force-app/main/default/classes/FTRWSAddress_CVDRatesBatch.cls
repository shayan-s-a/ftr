global class FTRWSAddress_CVDRatesBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
    List<Id> adrList = new List<Id>();
    Id OppId;
    Id quoteId;
    global FTRWSAddress_CVDRatesBatch(List<Id> listAdr,Id Opp_Id){
        adrList = listAdr;
        OppId=Opp_Id;
        SterlingQuote__c quote = new SterlingQuote__c();
        quote.recordtypeid= Label.WsQuoteRecordTypeId; 
        quote.Name ='Quote'+System.now();
        quote.Status__c = 'Needs Review';
        quote.ExpirationDate__c= System.today() +30;
        quote.OpportunityId__c = OppId;
        Insert quote;
        quoteId=quote.id;
    }
    
    global DataBase.QueryLocator start(Database.BatchableContext BC){
        return DataBase.getQueryLocator([Select id,Configuration__c,Product__c,Notes__c,CVD_Progress_Status__c,Product_Id__c,PNum__c,ACNA__c,QuotelineItem_Id__c,EVC_Bandwidth__c,UniSpeed__c,Level_of_service__c,Term_Aggrement__c,FTRWSAddress__c,Include_InQuote__c,CircuitType__c,NRC__C,Mrc__c,Vta__c,usocTier__c,EvcSpeed__c,NrcUsoc__c,MrcUsoc__c,Spec__c,cvdLookupUsed__c,cvdPriceTier__c, WS_Acna__c from FTRWSCVDRate__c where FTRWSAddress__c=: adrList and WS_Acna__c=true and (CVD_Progress_Status__c='uploaded'OR CVD_Progress_Status__c='Include in Quote')]);
    }
    
    global void execute(Database.BatchableContext BC,List<FTRWSCVDRate__c> CVDRates){
        Map<Id,FTRWSAddress__c> addressMap = new Map<Id,FTRWSAddress__c>();
        Map<Id,List<FTRWSCVDRate__c>> cvdRatesMap=new Map<Id,List<FTRWSCVDRate__c>>();
        List<FTRWSCVDRate__c> RateListUpd =new List<FTRWSCVDRate__c>();
        List<FTRWSAddress__c> queryaddress= [Select id,Street__c,Street_Number__c, Street_Name__c, City__c, State__c,Opportunity_ID__c, Zip_Code__c,Comments__c,
                                             G_Latitude__c,G_Longitude__c,Latitude__c,Longitude__c,Unit_Number__c, Service_Control_Number__C, CLLI_Code__C, 
                                             Fiber_Tier__c, DSAT_Max_Speed__c, Copper_Tier__c, WireCenter_CLLI__c, DPI_Qualified__c, DSAT_Qualified__c, Max_Qos__c                                        
                                             from FTRWSAddress__c where Id=: adrList];
        
        for(FTRWSAddress__c address: queryaddress){
            addressMap.put(address.id,address);
        }
        
        System.debug('queryaddress'+queryaddress.size());
        System.debug('CVDRates'+CVDRates.size());
        
        for(FTRWSCVDRate__c cvdRate: CVDRates){
            System.debug('SOQL Limit for every CVD Rate :'+Limits.getQueries());
            FTRWSAddress__c add = addressMap.get(cvdRate.FTRWSAddress__c);           
            cvdRate.Notes__c='';
            if(cvdRate.product__c == 'EIA' && cvdRate.Level_of_service__c != 'Silver'){
             //   cvdRate.Level_of_service__c = 'Silver';
                cvdRate.Notes__c += 'EIA max level of service is silver ; ';
            }
            
            if(add.Max_Qos__c  == 'Silver'  && cvdRate.Level_of_service__c != 'silver'){
              //  cvdRate.Level_of_service__c = 'silver';
                cvdRate.Notes__c += 'Max level of service at location is silver ; ';
            }
            
            if(add.Max_Qos__c  == 'Gold' && cvdRate.Level_of_service__c == 'Platinum'){
               // cvdRate.Level_of_service__c = 'Gold';
                cvdRate.Notes__c += 'Max level of service at location is gold ; ';
            }
            String reomoveChars = '[^0-9]';
            Integer EVC_Bandwidth = Integer.Valueof(cvdRate.EVC_Bandwidth__c.replaceall(reomoveChars,''));
            Integer multiplier=1;
            if(add.DSAT_Max_Speed__c!=null){
                if(add.DSAT_Max_Speed__c.contains('GB')){
                    Multiplier= 1000;
                }
                Integer DSAT_Max_Speed = Integer.Valueof(add.DSAT_Max_Speed__c.replaceall(reomoveChars,''))*Multiplier;
                if(EVC_Bandwidth > DSAT_Max_Speed){
                    cvdRate.Notes__c += 'Requested Speed exceeds existing Max Speed, BDT required ; ';
                }
            }
            
            if(add.DSAT_Qualified__c ==True && (cvdRate.Include_InQuote__c != 'Y' && cvdRate.Include_InQuote__c != 'N')){                
                FTRWSCVDRatesResponse cvdResponse = getWSProductsRates(null,add,cvdRate);
                //FTRWSCVDController.getWSProductsAndRates(add.id, add.PNUM__c);
               // System.debug('SOQL Limit After Process:'+Limits.getQueries());             
               // System.debug('***'+JSON.serialize(cvdResponse));
                // GIT Test
                if(cvdResponse.Rate!=null  && cvdResponse.Rate.size()>0){
                    for(Integer i=0;i<cvdResponse.Rate.size();i++){                        
                        cvdRate.Nrc__c= cvdResponse.Rate[i].nrc!='' ? Decimal.valueOf(cvdResponse.Rate[i].nrc):0.0;
                        cvdRate.Mrc__c = cvdResponse.Rate[i].mrc!='' ? Decimal.valueOf(cvdResponse.Rate[i].mrc):0.0;
                        cvdRate.Vta__c = cvdResponse.Rate[i].vta;
                        cvdRate.CircuitType__c = cvdResponse.Rate[i].circuitType;
                        cvdRate.usocTier__c =cvdResponse.Rate[i].usocTier;
                        cvdRate.EvcSpeed__c = cvdResponse.Rate[i].evcSpeed;                        
                        cvdRate.NrcUsoc__c = cvdResponse.Rate[i].nrcUsoc;
                        cvdRate.MrcUsoc__c = cvdResponse.Rate[i].nrcUsoc;
                        cvdRate.UniSpeed__c = cvdResponse.Rate[i].uniSpeed;                        
                        cvdRate.Spec__c = cvdResponse.Rate[i].spec;
                        cvdRate.Los__c = cvdResponse.Rate[i].los;//replace spec with Los_Response
                        Integer cvdRate_EvcSpeed;
                        if(cvdRate.EVC_Bandwidth__c.contains('M'))
                        cvdRate_EvcSpeed = integer.valueOf(cvdRate.EVC_Bandwidth__c.remove('M'));
                        
                        if(cvdRate.EVC_Bandwidth__c.contains('G'))
                        cvdRate_EvcSpeed = (integer.valueOf(cvdRate.EVC_Bandwidth__c.remove('G')))*1000;
                        
                        Integer cvdResp_EvcSpeed = (cvdResponse.Rate[i].uniSpeed !=null && cvdResponse.Rate[i].uniSpeed !='') ? integer.valueOf(cvdResponse.Rate[i].uniSpeed.remove('M')):0;
                        Integer cvdResp_USocTier = integer.valueOf(cvdResponse.Address.UsocTier);
                        Integer cvdRate_UscoTier = (cvdResponse.Rate[i].usocTier!=null && cvdResponse.Rate[i].usocTier!='') ? integer.valueOf(cvdResponse.Rate[i].usocTier.trim()) : 0;
                        
                        if(cvdRate.Product__c == 'EPATH' && (cvdRate.Configuration__c == 'NNI' || cvdRate.Configuration__c =='UNI' ) && cvdResp_USocTier==cvdRate_UscoTier){
                            if(cvdRate_EvcSpeed>=5 && cvdRate_EvcSpeed<=900 && cvdResp_EvcSpeed==1000){
                               break; 
                            }
                            else if(cvdRate_EvcSpeed>900  && cvdResp_EvcSpeed==10000){
                                break;
                            }
                        }
                    }
                    cvdRate.cvdLookupUsed__c = cvdResponse.Address.lookUpUsed;
                    cvdRate.cvdPriceTier__c = cvdResponse.Address.UsocTier;
                    cvdRate.CVD_Progress_Status__c = 'Ready_to_Quote';
                    RateListUpd.add(cvdRate); 
                } 
                
                else if(cvdResponse.Rate!=null  && cvdResponse.Rate.size() == 0){
                    cvdRate.CVD_Progress_Status__c = 'No Rates returned from CVD';                
                    RateListUpd.add(cvdRate); 
                }
                else if(cvdResponse.error !=null){
                    String error= JSON.serialize(cvdResponse.error);
                    cvdRate.CVD_Progress_Status__c = 'Error';
                    cvdRate.Error_Message__c = error;
                    RateListUpd.add(cvdRate);  
                } 
                /*else{
cvdRate.CVD_Progress_Status__c = 'No Rates returned from CVD';                
RateListUpd.add(cvdRate); 
}*/
                //}
                
                if(cvdRatesMap.containsKey(cvdRate.FTRWSAddress__c)){
                    List<FTRWSCVDRate__c> cvdList = cvdRatesMap.get(cvdRate.FTRWSAddress__c);
                    cvdList.add(cvdRate);
                    cvdRatesMap.put(cvdRate.FTRWSAddress__c,cvdList);
                }
                else{
                    List<FTRWSCVDRate__c> cvdList = new List<FTRWSCVDRate__c>();
                    cvdList.add(cvdRate);
                    cvdRatesMap.put(cvdRate.FTRWSAddress__c,cvdList);
                }
            }
            
            /*
//* This functionality is for Include_InQuote__c = Yes condition <--> Dev: Vyshnavi*
if(add.DSAT_Qualified__c ==True && cvdRate.Include_InQuote__c == 'Y'){
QLIidSet.add(cvdRate.QuotelineItem_Id__c);
if(INIQYAddMap.containsKey(cvdRate.FTRWSAddress__c)){
List<FTRWSCVDRate__c> addRatelist = INIQYAddMap.get(cvdRate.FTRWSAddress__c);
addRatelist.add(cvdRate);
INIQYAddMap.put(cvdRate.FTRWSAddress__c,addRatelist);   
}
else{
List<FTRWSCVDRate__c> newARlist = new List<FTRWSCVDRate__c>();
newARlist.add(cvdRate);
INIQYAddMap.put(cvdRate.FTRWSAddress__c,newARlist);
}               
}*/
        }
        
        update RateListUpd;
        /*
//* This functionality is for Include_InQuote__c = Yes condition <--> Dev: Vyshnavi*
QLIList =[select AdjustedMRC__c,AdjustedNRC__c,BDT_Required__c,BuildingNumber__c,Category__c,CircuitPriceQuoteId__c,
circuitType__c,CurrentStatus__c,cvdPriceTier__c,cvdratesource__c,Description__c,
DiscountAmount__c,DiscountType__c,Display_Term__c,DSAT_AddressID__c,DSAT_Copper_Tier__c,DSAT_Fiber_Tier__c,
DSAT_Max_Speed__c,Final_Approval_Date__c,FloorPrice__c,GrandFatheredItem__c,Id,IsAddressQualified__c,IsContracted__c,
isCTR__c,IsInFrontierFootprint__c,IsNewConstruction__c,IsPromoProduct__c,ItemCode__c,ItemOwner__c,Jeopardy__c,
Link_to_Opportunity__c,Locality__c,Major_Product__c,Max_QOS__c,NetNewMRR__c,NoICB__c,NRC_Item_Code__c,OpportunityId__c,OpportunityLineItemId__c,
Opportunity_Stage__c,Owner_Manager_id__c,Owner_manager__c,PNum__c,Postal_Address__c,Postal_Area__c,Postcode__c,
Pricebook_Entry_Id__c,Products__c,Product_Name_Quote__c,qos__c,Quantity__c,Quote_Name__c,Quote_Synced__c,RecordTypeId,
Related_Opportunity__c,Renewal_MRR_Original__c,Renewal_MRR__c,SA_StreetName__c,SA_StreetNrFirst__c,SA_StreetPostDirection__c,
SA_UnitNumber__c,ServiceType__c,Service_Address__c,Service_Area__c,SetNextApprover__c,SIFT_Required__c,StandardMRC__c,
StandardNRC__c,StateProvince__c,Status_Date__c,Status__c,SterlingQuote__c,ST_AddressID__c,TermLength__c,TotalPrice__c,
Total_Price__c,Zipcode__c from SterlingQuoteItem__c where id IN :QLIidSet];
for(SterlingQuoteItem__c sqi:QLIList){
INIQYQLIMap.put(sqi.id,sqi);
}
for(Id add: INIQYAddMap.keyset()){
List<FTRWSCVDRate__c> rListbyA= INIQYAddMap.get(add);
for(FTRWSCVDRate__c c:rListbyA){
SterlingQuoteItem__c sqiItem= INIQYQLIMap.get(c.QuotelineItem_Id__c).clone(false,false,false,false);
sqiItem.Products__c=c.Product_Id__c;
sqiItem.SterlingQuote__c=quoteId;
sqiItem.ST_AddressID__c = c.FTRWSAddress__c;
INIQYLtoIns.add(sqiItem);
}            
}
insert INIQYLtoIns;
*/
        for(Id addId: cvdRatesMap.keyset()){
            
            List<FTRWSCVDRate__c> rListbyA= cvdRatesMap.get(addId);
            for(FTRWSCVDRate__c c:rListbyA){ 
                if(!(c.CVD_Progress_Status__c.equalsIgnoreCase('No Rates returned from CVD')) && !(c.CVD_Progress_Status__c.equalsIgnoreCase('Error'))){
                    Integer EVC_Bandwidth = integer.valueOf(c.EVC_Bandwidth__c.remove('M'));
                    String Bandwidth_str;
                    if(EVC_Bandwidth>=1000){
                        Bandwidth_str=String.valueof((double)EVC_Bandwidth/1000);
                        Bandwidth_str=Bandwidth_str+'G';
                    }
                    else{
                        Bandwidth_str= c.EVC_Bandwidth__c;
                    }
                    String productName;
                    if(c.CircuitType__c=='EVC' && c.Product__c=='EIA'){
                        productName = c.Product__c+' '+Bandwidth_str;
                    }
                    else if(c.Level_Of_Service__c==null){
                        productName =c.Product__c+' '+Bandwidth_str;
                        
                    }
                    else{
                        productName = c.Product__c+' '+Bandwidth_str+' '+c.Level_Of_Service__c;
                    }
                    system.debug('*@' + productName);
                    //String qos=getQualityOfService(c);
                    
                    String qos = null;
                    if(c.CircuitType__c == 'EVC') {
                        qos = getQualityOfService(c);
                    }
                    try{
                        //   if(cvdRatesMap!=null)
                        WSProductCatalogController.addToQuote(quoteId, addId,productName, c.CircuitType__c ,c.Term_Aggrement__c, String.valueof(c.mrc__c), String.valueof(c.nrc__c), c.mrcUsoc__c, c.nrcUsoc__c, c.cvdLookupUsed__c, qos,c.cvdPriceTier__c,c.PNum__c,c.id);
                    }
                    Catch(Exception e){
                        System.debug('Exception occured at add to Quote'+ e);
                    }
                }
            }
            
        }
    }
    
    public static String getQualityOfService(FTRWSCVDRate__c cvdRate) {
        
        String qos = '';
        
        if(cvdRate.Spec__c != null && cvdRate.Spec__c != '') {
            qos = cvdRate.Spec__c;
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
                qos = wsSpecQosConv.Spec_Value__c;
            }
            System.debug('cvdRate.spec: qos for EPATH product: ' + cvdRate.Spec__c +':'+ qos);            
        }  
        else if(cvdRate.Product__c == 'EIA' && cvdRate.CircuitType__c == 'EVC') {
            qos = 'Silver';
        }  
        /*else if(cvdRate.CircuitType__c == 'UNI' || cvdRate.CircuitType__c == 'NNI') {
qos = null;
}   */
        
        //Start code fix: SDDD-2383 - QOS based on LOS for PNUM: EPAV001999SCM792
        if(String.isBlank(qos)) {
            String los = cvdRate.Los__c; //replace spec with Los_Response
            
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
    
    
    
    public static FTRWSCVDRatesResponse getWSProductsRates(SterlingQuote__c q, FTRWSAddress__c address,FTRWSCVDRate__c cvdRate){    
        List<Wholesale_ACNA__mdt> wsACNAList = [select ACNA__c from Wholesale_ACNA__mdt];
        List<String> wsACNAStringList =new List<String>();
        for(Wholesale_ACNA__mdt m:wsACNAList){
            wsACNAStringList.add(m.ACNA__c);
        }
        FTRWSCVDRatesRequest request = new FTRWSCVDRatesRequest();
        request.addressId=address.id;
        request.address = address.Street__c;
        String dsatClliCode = address.WireCenter_CLLI__c;
        request.cntrlKey = address.Service_Control_Number__c;
        request.city = address.City__c;
        request.swc = address.WireCenter_CLLI__c;
        request.stateCd = address.State__c;
        request.pNUM = cvdRate.PNUM__c==null ||cvdRate.PNUM__c==''? null:cvdRate.PNUM__c;
        request.product = cvdRate.Product__c;
        request.circuitType = cvdRate.Configuration__c;
        request.evcSpeed = cvdRate.EVC_Bandwidth__c.replaceall('\\s','');
        if(wsACNAStringList.contains(cvdRate.ACNA__c)){
            request.spec = null;
            if(cvdRate.Level_of_service__c.equalsIgnoreCase('Silver')) {
                request.los = 'EBE';
            } else if(cvdRate.Level_of_service__c.equalsIgnoreCase('Gold')) {
                request.los = 'EPD';
            } else if(cvdRate.Level_of_service__c.equalsIgnoreCase('Platinum')) {
                request.los = 'ERT';
            }
        }else{
            if(cvdRate.Level_Of_Service__c =='Gold')
                request.spec = cvdRate.Product__c+'EG';
            if(cvdRate.Level_Of_Service__c =='Silver')
                request.spec = cvdRate.Product__c+'ES';
            if(cvdRate.Level_Of_Service__c =='Platinum')
                request.spec = cvdRate.Product__c+'EP';
            if(cvdRate.Product__c == 'EIA')
                request.spec = null; 
        } 
        String reomoveChars = '[^0-9]';
        request.vta = cvdRate.Term_Aggrement__c!='MTM' ? cvdRate.Term_Aggrement__c.replaceall(reomoveChars,'') : 'MTM';
        
        if(cvdRate.Product__c == 'EPATH' && (cvdRate.Configuration__c == 'UNI' || cvdRate.Configuration__c == 'NNI'|| cvdRate.Configuration__c == 'EVC+UNI'|| cvdRate.Configuration__c == 'EVC+NNI')){
            request.spec = null;
            request.evcSpeed = null;
            //request.uniSpeed = cvdRate.EVC_Bandwidth__c;   
        }
        
        String dsatTier = '';
        String dsatSpeed = '';
        
        if(address.Fiber_Tier__c != null && address.Fiber_Tier__c != '') {
            dsatTier = address.Fiber_Tier__c;    
            dsatSpeed = FTRWSCVDController.getFormattedDsatSpeed(address.DSAT_Max_Speed__c);
        } else if(address.Copper_Tier__c != null && address.Copper_Tier__c != '') {
            dsatTier = address.Copper_Tier__c;
            dsatSpeed = dsatSpeed = FTRWSCVDController.getFormattedDsatSpeed('50M');
        }
        
        System.debug('Filtering cvd products with dsat tier as:' + dsatTier + ' dsat speed as :' + dsatSpeed);
        FTRWSCVDRatesResponse response = null;
        
        //adding DPI validated check for defect fix - SDDD-1724
        if(address.DSAT_Qualified__c == true || address.DPI_Qualified__c == true) {
            System.debug('@@@@@request'+JSON.serialize(request));
            if(test.isRunningTest()){
                Test.setMock(HttpCalloutMock.class, new FTRWSCVDRatesMockBulk());
            }
            response = FTRWSCVDInterface.getCVDRates(request);
        }
        boolean dpiQualified = address.DPI_Qualified__c;
        boolean dsatQualified = address.DSAT_Qualified__c;
        return response;
    }
    
    global void finish(Database.BatchableContext BC){
        String userName = UserInfo.getUserId();
        User activeUser = [Select id,Email From User where Id = : userName limit 1];
        String userEmail = activeUser.Email;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Email to User After Address Validation'];
        mail.setTemplateID(emailTemplate.Id); 
        String[] toAddresses = new String[] {userEmail};
            mail.setToAddresses(toAddresses);
        mail.setTargetObjectId(activeUser.id);
        mail.setSaveAsActivity(False);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}