/*
 * @Author : vara 
 * Version : 1.0
 * Updated Date : 24-11-2022
 * new version : 24-02-2023
 */ 
public class FTRWSMultipleFileUploader { 
    
    @AuraEnabled
    public Static List<String> getdocId(){
        List<String> docList= new List<String>();
        docList.add(System.Label.MultipleAddressDocId);
         docList.add(System.Label.SampleBulkUploadId);
        return docList;
    }
  
    
    @AuraEnabled
    public Static List<FTRWSAddress__c> exportAddresses(ID oppId){
        System.debug('@@oppId'+oppId);
        return [Select Name,Address__c,Street__c,Street_Name__c,Street_Number__c,City__c,State__c,Zip_Code__c,Comments__c,DPI_Qualified__c,DSAT_Qualified__c,In_Footprint__c,WireCenter_CLLI__c,Max_Qos__c,DSAT_Max_Speed__c,Copper_Qualification__c,Copper_Tier__c,Fiber_Qualification__c,Fiber_Tier__c From FTRWSAddress__c where Opportunity_ID__c=: oppId];
    }
    
    @AuraEnabled
    public static List<FTRWSAddress__c> saveFile(String base64Data, ID oppId) {
        List<FTRWSAddress__c> UpldAdrList = new List<FTRWSAddress__c>();
        List<FTRWSCVDRate__c> cvdRateList = new List<FTRWSCVDRate__c>();
        List<FTRWSCVDRate__c> updCvdRateList = new List<FTRWSCVDRate__c>();
        List<Quote_Products__c> qpList = new List<Quote_Products__c>(); // newly added to map Quote_Products__c
        List<id> eAdrRepeat = new List<id>();
        List<id> inserted = new List<id>();
        List<id> allAddIdList = new List<id>();
        Map<Integer,List<FTRWSCVDRate__c>> AddresCvdMap = new Map<Integer,List<FTRWSCVDRate__c>>();
        Integer addrPostion;
        // Modified  by Vara
        //List<FTRWSAddress__c> existingAdrList=[Select id,Address__c,Street__c,Street_Name__c,Street_Number__c,City__c,State__c,Zip_Code__c,Longitude__c,Latitude__c,Unit_Number__c from FTRWSAddress__c  where Opportunity_ID__c=: oppId];
		List<FTRWSAddress__c> existingAdrList=[Select id,Address__c,Street__c,Street_Name__c,Street_Number__c,City__c,State__c,Zip_Code__c,Longitude__c,Latitude__c,Unit_Number__c,ACNA__c,PNUM__c,Product__c,Configuration__c,EVC_Bandwidth__c,Level_Of_Service__c,Term_Agreement__c,Id__c,BDT_Required_checkbox__c,MRC_Discount_Type__c,MRC_Discount__c,Address_Lost_checkbox__c,Address_Lost_checkbox_Address_Lost_reaso__c,UNI_NNI_Speed__c,UNI_NNI_Type__c,CS_LATA__c,Site_ID__c,Alt_Site_Name__c,Interconnect_Lata__c,Interconnect_CLLI__c,County__c,UMTS_MTSO__c,Need_by_Date__c from FTRWSAddress__c  where Opportunity_ID__c=: oppId];        
        Map<String,FTRWSAddress__c> existingAdMap = new Map<String,FTRWSAddress__c>();
        Map<String,FTRWSAddress__c> insertingAdMap = new Map<String,FTRWSAddress__c>();
        Map<String,Integer> AdkeyPositionMap = new Map<String,Integer>();
        
        for(FTRWSAddress__c ad:existingAdrList){
            String unitNumber = ad.Unit_Number__c!=null ? ad.Unit_Number__c:'';
            //Added by Vara
            if(ad!=null && unitNumber != null && ad.Street__c != null && ad.City__c != null && ad.State__c != null && ad.Zip_Code__c != null){
                String adress=ad.Street__c.toLowerCase()+'_'+ad.City__c.toLowerCase()+'_'+ad.State__c.toLowerCase()+'_'+ad.Zip_Code__c.toLowerCase()+'_'+unitNumber.toLowerCase()+'_'+ad.Id__c ;
                existingAdMap.put(adress,ad);
            }
        }
        
        System.debug('base64Data'+base64Data);
        String data = JSON.deserializeUntyped(base64Data).toString();
        System.debug('data@@'+data);
        list<FTRWSAddress__c> lstAdrToInsert = new list<FTRWSAddress__c>();
        list<String> lstCSVLines = data.split('\n');
        System.debug('@@CSVLineList'+lstCSVLines);
        for(Integer i = 1; i < lstCSVLines.size(); i++){
            FTRWSAddress__c adr = new FTRWSAddress__c();
            String csvLine = lstCSVLines[i];
            String prevLine = csvLine;
            Integer startIndex;
            Integer endIndex;            
     
            List<String> csvRowData = new List<String>();
            for(String column : csvLine.split(',')){
                column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                csvRowData.add(column);
                System.debug('@@csvRowData'+csvRowData);
            }
            //only lat long 
            if(csvRowData[0]==''&&csvRowData[2]==''&&csvRowData[3]==''&&csvRowData[4]==''&&csvRowData[5]!=''&&csvRowData[6]!=''){
                String response = GooglePlacesController.getPlaceDetailsWithLatLong(csvRowData[5], csvRowData[6]);
                System.debug('response requried '+response);
                FTRWSAddress__c address = GoogleLatLangResponse.parseAndSaveGoogleAddress(response, oppId,csvRowData[5],csvRowData[6]);
                System.debug('response'+address);
                 adr.Street__c = address.Street_Number__c + ' '+ address.Street_Name__c ;
                adr.Address__c = adr.Street__c+ ' '+ address.City__c+ ' '+ address.State__c+ ' '+ address.Zip_Code__c ;
                adr.Street_Name__c=address.Street_Name__c;
                adr.Street_Number__c = address.Street_Number__c;
                adr.City__c  = address.City__c;
                adr.State__c = address.State__c;
                adr.Zip_Code__c = address.Zip_Code__c; 
            }
            else{
                adr.Address__c = csvRowData[0] +' '+csvRowData[2]+' '+csvRowData[3]+' '+csvRowData[4];
                adr.Street__c = csvRowData[0];
                adr.Street_Name__c=csvRowData[0];            
                adr.City__c  = csvRowData[2];
                adr.State__c = csvRowData[3];
                adr.Zip_Code__c = csvRowData[4];            
            }
            adr.Latitude__c = csvRowData[5];
            adr.Longitude__c =  csvRowData[6];
            adr.Unit_Number__c  = csvRowData[1];
            adr.Opportunity_ID__c = oppId;
            adr.DPI_Validated__c = False;
            adr.DSAT_Validated__c = False;
            adr.Comments__c='';
            // need to add Here Missing Values
            
            adr.ACNA__c = csvRowData[7];
            adr.PNUM__c  = csvRowData[8];
            adr.Product__c  = csvRowData[9];
            adr.Configuration__c = csvRowData[10];
            adr.EVC_Bandwidth__c = csvRowData[11];
            adr.Level_Of_Service__c = csvRowData[12];
            adr.Term_Agreement__c = csvRowData[13];
            adr.Id__c = csvRowData[14];
            adr.BDT_Required_checkbox__c = Boolean.valueOf(csvRowData[15]);
            adr.MRC_Discount_Type__c = csvRowData[16];
            System.debug('17 : '+csvRowData[17]+':');
            adr.MRC_Discount__c = csvRowData[17]!='' ? Decimal.valueOf(csvRowData[17]):0.0 ;
            adr.NRC_Discount_Type__c = csvRowData[18];
            adr.NRC_Discount__c = csvRowData[19]!='' ? Decimal.valueOf(csvRowData[19]):0.0;
            
            adr.Address_Lost_checkbox__c = Boolean.valueOf(csvRowData[20]);
            adr.Address_Lost_checkbox_Address_Lost_reaso__c = csvRowData[21];
            adr.UNI_NNI_Speed__c = csvRowData[22];
            adr.UNI_NNI_Type__c = csvRowData[23];
            adr.CS_LATA__c = csvRowData[24]!='' ? Decimal.valueOf(csvRowData[24]):0.0;
            adr.Site_ID__c = csvRowData[25];
            adr.Alt_Site_Name__c = csvRowData[26];
            adr.Interconnect_Lata__c = csvRowData[27]!='' ? Decimal.valueOf(csvRowData[27]):0.0;
            adr.Interconnect_CLLI__c = csvRowData[28];
            adr.County__c = csvRowData[29];
            System.debug('csvRowData[30] :'+csvRowData[30]);
            adr.UMTS_MTSO__c = csvRowData[31];
            System.debug('csvRowData[31] :'+csvRowData[31]);
            adr.MTSO_LATA__c = csvRowData[30]!='' ?decimal.valueOf(csvRowData[30]):0.0;
            //String dd = csvRowData[32];
            //System.debug('csvRowData[32] Date Value :'+csvRowData[32]);            
			//String text = csvRowData[32];   
            /*
            if(String.isEmpty(text)==true)
            {
                System.debug('22 isEmpty');
            }
            if(String.isBlank(text)==true)
            {
                System.debug('11 isBlank');
            }            
            if(String.isBlank(text)==false)
            {
                System.debug('not blank');
                System.debug('String32 :'+csvRowData[32]);
                String  t = csvRowData[32].substring(6, 10);
                Integer Y,D,M;
                Y = integer.valueof(t);       
                t = csvRowData[32].substring(0, 2);            
                M = integer.valueof(t);
                t = csvRowData[32].substring(3, 5);
                D = integer.valueof(t);
                System.debug('Day:'+D);
                System.debug('month1:'+M);
                System.debug('year1:'+Y);            
                //Date nbd = Date.newInstance(Y, M, D);
                //System.debug('Need By date:'+nbd);
                //adr.Need_by_Date__c = nbd;                     
            }               
            if(String.isNotEmpty(text)==true)
            {
                System.debug('33 String Not Empty');
           
            }            
            */
            String needByDateStr = csvRowData[32].removeEnd('\r');
            if(needByDateStr != null && needByDateStr != ''){
                List<String> needByDateList = needByDateStr.split('/');
                Integer Y,D,M;
                Y = integer.valueof(needByDateList[2]);
                M = integer.valueof(needByDateList[0]);
                D = integer.valueof(needByDateList[1]);
                System.debug('Day:'+D);
                System.debug('month1:'+M);
                System.debug('year1:'+Y);            
                Date nbd = Date.newInstance(Y, M, D);
                adr.Need_by_Date__c = nbd;
            }
            
            adr.Customer_DSAT_ID__c = csvRowData[14];
            adr.Customer_Longitude__c = csvRowData[6];
            adr.Customer_Latitude__c = csvRowData[5];
            
            //adr.Need_by_Date__c = Date.parse(csvRowData[32]);
            // Mapping here 
            /*
            Quote_Products__c qpl = new Quote_Products__c();
            qpl.DSAT_ID__c  = csvRowData[14];            
            qpl.Address_Lost__c = Boolean.valueOf(csvRowData[20]);
            qpl.Address_Lost_Reason__c = csvRowData[21];
            qpl.CS_LATA__c = csvRowData[24];
            qpl.Site_ID__c = csvRowData[25];
            qpl.Alt_Site_Name__c = csvRowData[26];
            qpl.Interconnect_Lata__c = csvRowData[27];
            qpl.Interconnect_CLLI__c = csvRowData[28];
            qpl.County__c = csvRowData[29];
            qpl.MTSO_LATA__c = csvRowData[30];
            qpl.UMTS_MTSO__c = csvRowData[31];
            qpl.UNI_NNI_Speed__c = csvRowData[22];
            qpl.UNI_NNI_Type__c = csvRowData[23];            
            qpl.Opportunity__c = oppId;            
                     
            qpList.add(qpl);  */            
            //
            // add upto here - 7/3
            System.debug('@@@'+adr);
            String compString=validateValue(adr.Street__c)+'_'+validateValue(adr.City__c)+'_'+validateValue(adr.State__c)+'_'+validateValue(adr.Zip_Code__c)+'_'+validateValue(adr.Unit_Number__c)+'_'+adr.Id__c;   
            System.debug('@@compString'+compString);
            system.debug('@@@@compString' + existingAdMap.keyset());
            if(existingAdMap.containsKey(compString)){
                FTRWSAddress__c address=existingAdMap.get(compString);
                adr.Latitude__c = address.Latitude__c;
                adr.Longitude__c = address.Longitude__c;
                adr.id= address.id;
                eAdrRepeat.add(address.id);
                UpldAdrList.add(adr);
                System.debug('Im into 1st if');
                FTRWSCVDRate__c cvdRate = new  FTRWSCVDRate__c(); 
                cvdRate.ACNA__c = csvRowData[7];
                cvdRate.PNum__c =  csvRowData[8];
                cvdRate.Product__c = csvRowData[9];
                cvdRate.Configuration__c = csvRowData[10];
                cvdRate.EVC_Bandwidth__c = csvRowData[11];
                cvdRate.Level_of_service__c = csvRowData[12];
                cvdRate.Term_Aggrement__c =csvRowData[13];
                cvdRate.opportunity__c = oppId;
                cvdRate.QuotelineItem_Id__c = csvRowData[19]==null?'':csvRowData[19];                               
                cvdRate.Include_InQuote__c = csvRowData[14];
                cvdRate.FTRWSAddress__c= address.id;
                cvdRate.Product_Id__c =  csvRowData[18]==null?'':csvRowData[18];
                cvdRate.CVD_Progress_Status__c ='Uploaded';
                updCvdRateList.add(cvdRate);
            }
            else{
                   if(insertingAdMap.containsKey(validateValue(adr.Street__c)+'_'+validateValue(adr.City__c)+'_'+validateValue(adr.State__c)+'_'+validateValue(adr.Zip_Code__c)+'_'+validateValue(adr.Unit_Number__c))){
                   System.debug('Im into else if after address check');
                    FTRWSCVDRate__c cvdRate = new  FTRWSCVDRate__c();
                    Integer p=AdkeyPositionMap.get(compString);
                    cvdRate.FTRWSAddress__c=lstAdrToInsert[p].id;
                    cvdRate.ACNA__c = csvRowData[7];
                    cvdRate.PNum__c = csvRowData[8];
                    cvdRate.Product__c = csvRowData[9];
                    cvdRate.Configuration__c = csvRowData[10];
                    cvdRate.EVC_Bandwidth__c = csvRowData[11];
                    cvdRate.Level_of_service__c = csvRowData[12];
                    cvdRate.Term_Aggrement__c = csvRowData[13];
                    cvdRate.Include_InQuote__c = csvRowData[14];
                    cvdRate.opportunity__c = oppId;
                    cvdRate.CVD_Progress_Status__c ='uploaded';
                    cvdRate.QuotelineItem_Id__c = csvRowData[19];
                    List<FTRWSCVDRate__c> crList = AddresCvdMap.get(p);
                    crList.add(cvdRate);
                    AddresCvdMap.put(p,crList);
                }
                else{
                    insertingAdMap.put(compString,adr);
                    lstAdrToInsert.add(adr);
                    System.debug('Im into else if after address check else'+adr);
                    FTRWSCVDRate__c cvdRate = new  FTRWSCVDRate__c();
                    addrPostion = lstAdrToInsert.size()>0 ? lstAdrToInsert.size()-1:0 ;
                    cvdRate.FTRWSAddress__c=lstAdrToInsert[addrPostion].id;
                    cvdRate.ACNA__c = csvRowData[7];
                    cvdRate.PNum__c = csvRowData[8];
                    cvdRate.Product__c = csvRowData[9];
                    cvdRate.Configuration__c = csvRowData[10];
                    cvdRate.EVC_Bandwidth__c = csvRowData[11];
                    cvdRate.Level_of_service__c = csvRowData[12];
                    cvdRate.Term_Aggrement__c = csvRowData[13];
                    cvdRate.Include_InQuote__c = csvRowData[14];
                    cvdRate.opportunity__c = oppId;
                    cvdRate.CVD_Progress_Status__c ='uploaded';
                    cvdRate.QuotelineItem_Id__c = csvRowData[19];
                    List<FTRWSCVDRate__c> crList = new List<FTRWSCVDRate__c>();
                    crList.add(cvdRate);
                    AddresCvdMap.put(lstAdrToInsert.size()-1,crList);
                    AdkeyPositionMap.put(compString,lstAdrToInsert.size()-1);
                }         
            }
        }
        
        insert lstAdrToInsert;
        insert qpList;
        //update UpldAdrList;
        System.debug('@@@Im after InsertList'+ lstAdrToInsert);
        
        for(Integer i=0;i< lstAdrToInsert.size();i++){
            inserted.add(lstAdrToInsert[i].id);           
        }
        allAddIdList.addAll(inserted);
        allAddIdList.addAll(eAdrRepeat);
        for(Integer q: AddresCvdMap.keyset()){
            System.debug('q ::'+q+' value list Size :: '+AddresCvdMap.get(q).size());
            List<FTRWSCVDRate__c> rList = AddresCvdMap.get(q);
            for(FTRWSCVDRate__c c: rList){
                c.FTRWSAddress__c = lstAdrToInsert[q].id;                
                FTRWSCVDRate__c cvdRate = new FTRWSCVDRate__c();
                cvdRate=c;
                System.debug('cvdRate'+cvdRate);
                cvdRateList.add(cvdRate);
            }            
        }
        //cvdRateList.addAll(updCvdRateList);
        insert updCvdRateList;
        insert cvdRateList;
        //This is for Bulk Upload automation
        if (Test.isRunningTest() && !inserted.isEmpty()) {
            inserted = new List<Id>{inserted[0]};
        }
        Database.executeBatch(new FTRWSMultipleFileUploaderBatch(inserted,allAddIdList,oppId),1);
        lstAdrToInsert.addAll(UpldAdrList);
        return lstAdrToInsert;
    }
     public static String validateValue(String data) {
    	return String.isNotBlank(data) ? data.toLowerCase() : '';
    }
}