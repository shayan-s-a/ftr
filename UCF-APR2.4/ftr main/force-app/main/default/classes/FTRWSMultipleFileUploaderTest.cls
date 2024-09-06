/**
 * @description       : This test class covers the following Apex classes:
 *      FTRWSMultipleFileUploaderBatch
 *      FTRWSMultipleFileUploader
 *      FTRWSAddress_CVDRatesBatch
 * @author            : Vyshnavi Yalamareddy
 * @version           : 22
**/

@isTest
public class FTRWSMultipleFileUploaderTest {
    
    @testSetup static void methodName() {
        
               Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc;
        
        Account acc = new Account();
        acc.Name='testAccount';
        acc.ParentId = globalAcc.Id;
        insert acc;
        
        Product2 product = new Product2();
        product.Name = 'EPATH 1000M Silver';
        product.evcspeed__c = '1000M';
        product.Family = 'EPATH';
        product.Quantity__c = '1';
        product.mrcusoc__c = 'EPATHUSOC';
        
        insert product;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry priceEntrylist = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = product.Id,UnitPrice = 12000, IsActive = true);
        insert priceEntrylist;
        
        FTRWSAcna__c acna = new FTRWSAcna__c();
        acna.Name='ATX';
        acna.Company__c = acc.id;
        insert acna;
        
        FTRWSPnum__c pnum = new FTRWSPnum__c();
        pnum.Name='EIA001';
        pnum.Wholesale_ACNA__c = acna.id;
        insert pnum;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.Wholesale_ACNA__c=acna.id;
        opp.Wholesale_Pnum__c=pnum.id;
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
        FTRWSAddress__c adr= new FTRWSAddress__c();
        adr.Address__c = '1 BROOKLYN RD' +' '+'FREEVILLE'+' '+'NY'+' '+'13068';
        adr.Name = '1 BROOKLYN RD' +' '+'FREEVILLE'+' '+'NY'+' '+'13068';
        adr.Street__c = '1 BROOKLYN RD';
        adr.Street_Name__c='1 BROOKLYN RD';            
        adr.City__c  = 'FREEVILLE';
        adr.State__c = 'NY';
        adr.Zip_Code__c = '13068';
        adr.Id__c = '1111';
        adr.Opportunity_ID__c = opp.Id;
        insert adr;
        
        List<FTRWSCVDRate__c> insList = new List<FTRWSCVDRate__c>();
        FTRWSCVDRate__c c1= new FTRWSCVDRate__c();
        c1.Spec__c='';
        c1.Product__c='EIA';
        c1.CircuitType__c='EVC';
        c1.FTRWSAddress__c=adr.id;
        insList.add(c1);
        FTRWSCVDRate__c c2= new FTRWSCVDRate__c();
        c2.Spec__c='EPATHEG';
        c2.FTRWSAddress__c=adr.id;
        insList.add(c2);
        FTRWSCVDRate__c c3= new FTRWSCVDRate__c();
        c3.Spec__c='EPATHES';
        c3.FTRWSAddress__c=adr.id;
        insList.add(c3);
        FTRWSCVDRate__c c4= new FTRWSCVDRate__c();
        c4.Spec__c='EPATHEP';
        c4.FTRWSAddress__c=adr.id;
        insList.add(c4);
        insert insList;
    }
    public static testmethod void getQualityOfServiceTest(){
        List<FTRWSCVDRate__c> cvdList = [select id,Spec__c,Product__c,CircuitType__c from FTRWSCVDRate__c ];
        for(FTRWSCVDRate__c c:cvdList){
            String s= FTRWSAddress_CVDRatesBatch.getQualityOfService(c);
        }
    }
    
    public static testmethod void saveFileTest(){
        //Test.setMock(HttpCalloutMock.class, new GoogleLatLngTestMock());
 String date32= String.valueOf(Date.newInstance(2020, 11, 30));
        String fileContent='"Street,unit,city,stateOrProvince,postalCode,latitude,longitude,ACNA,PNUM,Product,Configuration,EVC Bandwidth,Level of service,Term Aggrement, DSAT ID,In quote,mrc,nrc,Address_Id,Product_Id,SQI_Id,Notes,UNI_NNI_Speed__c,UNI_NNI_Type__c,CS_LATA__c,Site_ID__c,Alt_Site_Name__c,Interconnect_Lata__c,Interconnect_CLLI__c,County__c,Need_by_Date__c,Site_ID__c\\r\\n1 BEACH POND RD,,GROTON,CT,6340,null,null,ATX,EPAV001GIM300484,EPATH,EVC,1000M,Silver,1X,1234,X,,,,,,,,,,,,,,,,,,'+date32+'\\r\\n1 BEACH POND RD,,GROTON,CT,6340,null,null,ATX,EPAV001GIM300484,EPATH,EVC,1000M,Silver,1Y,1111,,,,,,,,,,,,,,,,,,,,\\r\\n4310 Verde Vista,,GEORGETOWN,TX,78628,null,null,ATX,EPAV001GIM300484,EPATH,EVC,1000M,Silver,1Y,,,,,,,,,,,,,,,,,,,,\\r\\n1 BROOKLYN RD,,FREEVILLE,NY,13068,null,null,ATX,EPAV001GIM300484,EPATH,EVC,1000M,Silver,1Z,1111,,,,,,,,,,,,,,,,,,,\\r\\n"';
        Opportunity o= [select id from Opportunity limit 1];
        //FTRWSAddress__c adr =[Select id,Street__c,City__c,State__c,Zip_Code__c,Unit_Number__c from FTRWSAddress__c Limit 1 ];
        FTRWSAddress__c adr= new FTRWSAddress__c();
        adr.Address__c = '1 BROOKLYN RD' +' '+'FREEVILLE'+' '+'NY'+' '+'13068';
        adr.Name = '1 BROOKLYN RD' +' '+'FREEVILLE'+' '+'NY'+' '+'13068';
        adr.Street__c = '1 BROOKLYN RD';
        adr.Street_Name__c='1 BROOKLYN RD';            
        adr.City__c  = 'FREEVILLE';
        adr.State__c = 'NY';
        adr.Zip_Code__c = '13068';
        adr.Latitude__c = '';
        adr.Longitude__c =  '';
        adr.Unit_Number__c  = '';
        adr.Opportunity_ID__c = o.Id;
        adr.DPI_Validated__c = False;
        adr.DSAT_Validated__c = False;
        adr.Comments__c='';
        adr.Id__c = '1111';
        adr.Need_by_Date__c= Date.newInstance(2020, 11, 30);
        insert adr;
        Test.startTest();
        String compString=adr.Street__c.toLowerCase()+'_'+adr.City__c.toLowerCase()+'_'+adr.State__c.toLowerCase()+'_'+adr.Zip_Code__c.toLowerCase()+'_'+adr.Unit_Number__c.toLowerCase()+'_'+adr.Id__c;
        System.debug('@@compString@@'+compString);
        Test.setMock(HttpCalloutMock.class, new GoogleLatLngTestMock());
        Test.setMock(WebServiceMock.class, new FTRWSDPIAddressValResultMock());
        Test.setMock(HttpCalloutMock.class, new FTRWSDSATAddressControllerPostMock());
        Test.setMock(HttpCalloutMock.class, new FTRWSCVDRatesMockBulk());
        List<FTRWSAddress__c> addList = FTRWSMultipleFileUploader.saveFile(fileContent,o.id);
        Test.stopTest();
    }
    
    public static testmethod void saveFileTest1(){
        //Test.setMock(HttpCalloutMock.class, new GoogleLatLngTestMock());
        String date32= String.valueOf(Date.newInstance(2020, 11, 30));
        String fileContent='"Street,unit,city,stateOrProvince,postalCode,latitude,longitude,ACNA,PNUM,Product,Configuration,EVC Bandwidth,Level of service,Term Aggrement,In quote,mrc,nrc,Address_Id,Product_Id,SQI_Id,Notes,UNI_NNI_Speed__c,UNI_NNI_Type__c,CS_LATA__c,Site_ID__c,Alt_Site_Name__c,Interconnect_Lata__c,Interconnect_CLLI__c,County__c,Need_by_Date__c,Site_ID__c\\r\\n1 BEACH POND RD,,GROTON,CT,6340,null,null,ATX,EPAV001GIM300484,EPATH,EVC,1000M,Silver,1X,1111,X,,,,,,,,,,,,,,,,,,'+date32+'\\r\\n1 BEACH POND RD,,GROTON,CT,6340,null,null,ATX,EPAV001GIM300484,EPATH,EVC,1000M,Silver,1Y,1111,,,,,,,,,,,,,,,,,,,\\r\\n4310 Verde Vista,,GEORGETOWN,TX,78628,null,null,ATX,EPAV001GIM300484,EPATH,EVC,1000M,Silver,1Y,,,,,,,,,,,,,,,,,,,,\\r\\n1 BROOKLYN RD,,FREEVILLE,NY,13068,null,null,ATX,EPAV001GIM300484,EPATH,EVC,1000M,Silver,1Z,,,,,,,,,,,,,,,,,,,,\\r\\n"';
        Opportunity o= [select id from Opportunity limit 1];
        //FTRWSAddress__c adr =[Select id,Street__c,City__c,State__c,Zip_Code__c,Unit_Number__c from FTRWSAddress__c Limit 1 ];
        FTRWSAddress__c adr= new FTRWSAddress__c();
        adr.Address__c = '1 BROOKLYN RD' +' '+'FREEVILLE'+' '+'NY'+' '+'13068';
        adr.Name = '1 BROOKLYN RD' +' '+'FREEVILLE'+' '+'NY'+' '+'13068';
        adr.Street__c = '1 BROOKLYN RD';
        adr.Street_Name__c='1 BROOKLYN RD';            
        adr.City__c  = 'FREEVILLE';
        adr.State__c = 'NY';
        adr.Max_Qos__c  = 'Silver';
        adr.Zip_Code__c = '13068';
        adr.Latitude__c = '';
        adr.Longitude__c =  '';
        adr.Unit_Number__c  = '';
        adr.Opportunity_ID__c = o.Id;
        adr.DPI_Validated__c = False;
        adr.DSAT_Validated__c = False;
        adr.Comments__c='';
        adr.Fiber_Tier__c='';
        adr.Need_by_Date__c= Date.newInstance(2020, 11, 30);
        adr.Id__c = '1111';
        insert adr;
        Test.startTest();
        String compString=adr.Street__c.toLowerCase()+'_'+adr.City__c.toLowerCase()+'_'+adr.State__c.toLowerCase()+'_'+adr.Zip_Code__c.toLowerCase()+'_'+adr.Unit_Number__c.toLowerCase()+'_'+adr.Id__c;
        System.debug('@@compString@@'+compString);
        Test.setMock(WebServiceMock.class, new FTRWSDPIAddressValResultMock());
        Test.setMock(HttpCalloutMock.class, new FTRWSDSATAddressControllerPostMock());
        Test.setMock(HttpCalloutMock.class, new FTRWSCVDRatesMockBulk1Test());
        List<FTRWSAddress__c> addList = FTRWSMultipleFileUploader.saveFile(fileContent,o.id);
        Test.stopTest();
    }
    
    public static testmethod void exportAddressesTest(){        
        Opportunity o= [select id from Opportunity limit 1];
        Test.startTest();
        List<FTRWSAddress__c> addList = FTRWSMultipleFileUploader.exportAddresses(o.id);
        Test.stopTest();
    }
    public static testmethod void getdocIdTest(){        
        Test.startTest();
        List<String> DocId = FTRWSMultipleFileUploader.getdocId();
        Test.stopTest();
    }
}