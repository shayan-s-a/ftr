/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2 
 * 
**/
@isTest
public class GoogleLatLangResponseTest {
    
    @isTest
    public static void testParseGoogleLatLngResponse() {
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc1 = new Account();
        globalAcc1.Name = 'GLOBAL ACCOUNT';
        globalAcc1.RecordTypeId = globalRecId;
        //globalAcc.RecordTypeId = '012E0000000fDc3IAE';
        insert globalAcc1;
       //  Id GlobalRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();
        Id MasterRTId =[SELECT id FROM RecordType WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'].Id;
        GoogleLatLangResponse resp = new GoogleLatLangResponse();
        List<GoogleLatLangResponse.Result> resultList  = new List<GoogleLatLangResponse.Result>();
        resp.results = resultList;
        GoogleLatLangResponse.Result result = new GoogleLatLangResponse.Result();
        resultList.add(result);
        result.address_components = new List<GoogleLatLangResponse.AddressComponent>();
        
        GoogleLatLangResponse.AddressComponent addComp1 = new GoogleLatLangResponse.AddressComponent();
        result.address_components.add(addComp1);
        addComp1.long_name = '277';
        addComp1.short_name = '277';
        String stNum = 'street_number';
        addComp1.types = new String[]{stNum};
            
            GoogleLatLangResponse.AddressComponent addComp2 = new GoogleLatLangResponse.AddressComponent();
        result.address_components.add(addComp2);
        addComp2.long_name = 'Bedford Avenue';
        addComp2.short_name = 'Bedford Ave';
        String route = 'route';
        addComp2.types = new String[]{route};
            
            
            
            GoogleLatLangResponse.AddressComponent addComp3 = new GoogleLatLangResponse.AddressComponent();
        result.address_components.add(addComp3);
        
        addComp3.long_name = 'Williamsburg';
        addComp3.short_name = 'Williamsburg';
        addComp3.types = new String[]{'neighborhood', 'political'};        
            
            GoogleLatLangResponse.AddressComponent addComp4 = new GoogleLatLangResponse.AddressComponent();
        result.address_components.add(addComp4);
        
        addComp4.long_name = 'Brooklyn';
        addComp4.short_name = 'Brooklyn';
        
        addComp4.types = new String[]{'political', 'sublocality', 'sublocality_level_1'};            
            
            
            
            GoogleLatLangResponse.AddressComponent addComp5 = new GoogleLatLangResponse.AddressComponent();
        result.address_components.add(addComp5);
        
        addComp5.long_name = 'New York';
        addComp5.short_name = 'NY';
        
        addComp5.types = new String[]{'administrative_area_level_1', 'political'};
            
            
            GoogleLatLangResponse.AddressComponent addComp6 = new GoogleLatLangResponse.AddressComponent();
        result.address_components.add(addComp6);
        
        addComp6.long_name = '11211';
        addComp6.short_name = '11211';
        
        addComp6.types = new String[]{'postal_code'};
            
            GoogleLatLangResponse.Geometry geometry = new GoogleLatLangResponse.Geometry();
        Double lat = 40.714224;
        Double lng = -73.961452;
        geometry.location = new GoogleLatLangResponse.GLocation(lat, lng);
        result.geometry = geometry;
        
        String respStr = JSON.serialize(resp);
        System.debug('GoogleLatLangResponse string: ' + respStr);
        
        Account acc = new Account();
         acc.RecordTypeId = MasterRTId;
        acc.ParentId = globalAcc1.Id;
        acc.Name='testAccount';
        insert acc;
        
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
        Test.startTest();
        GoogleLatLangResponse.parseAndSaveGoogleAddress(respStr, opp.Id, '40.714224', '-73.961452');
        Test.stopTest();
    }
}