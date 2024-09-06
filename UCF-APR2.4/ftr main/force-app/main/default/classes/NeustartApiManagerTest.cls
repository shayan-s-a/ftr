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
private class NeustartApiManagerTest {
    @isTest static void testExistingNeuStarWithMasterAccOnly(){
        Test.setMock(WebServiceMock.class, new MockHttpResponseGeneratorNeuStar());
        
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
        
        RecordType rt = [select id from recordtype where developerName = 'Master' AND SobjectType = 'Account'];
        
        Account acc = new Account();
        acc.Phone = '2345678';
        acc.Name = 'test';
        acc.recordTypeId = rt.Id;
        acc.Need_To_Sync_With_NeuStar__c = true;
        acc.ParentId = globalAcc.Id;
        insert acc;
        Test.setMock(WebServiceMock.class, new MockHttpResponseGeneratorNeuStar());
        Neustar_Data__c nd = new Neustar_Data__c();
        nd.TN__c = '2345678';
        nd.Master_Account__c = acc.Id;
        insert nd;
        Test.startTest();
        database.executeBatch(new NeustarApiBatch('NewUpdatedAccount'),1);
        Test.stopTest();
    }
    @isTest static void testExistingNeuStarAPI(){
        Test.setMock(WebServiceMock.class, new MockHttpResponseGeneratorNeuStar());
        Neustar_Data__c nd = new Neustar_Data__c();
        nd.TN__c = '2345678';
        insert nd;
        
        Test.startTest();
            database.executeBatch(new NeustarApiBatch('ExistingND'),1);
        Test.stopTest();
    }
    @isTest static void testNeuStarAPI() {
        Test.setMock(WebServiceMock.class, new MockHttpResponseGeneratorNeuStar());
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
        Account acc = new Account();
            acc.Phone = '12345';
            acc.Name = 'test';
            acc.Need_To_Sync_With_NeuStar__c = true;
        acc.ParentId = globalAcc.Id;
            insert acc;
        Test.startTest();
            database.executeBatch(new NeustarApiBatch('NewUpdatedAccount'),1);
        Test.stopTest();
        
        NeustarApiBatch.removeJobExistingND();
        NeustarApiBatch.removeJobNewUpdatedAccount();
        
        NeustarApiBatch.scheduleJobNewUpdatedAccount();
        NeustarApiBatch.scheduleJobExistingND();
        
        List<Neustar_Data__c> lstNS = [select id,State1__c from Neustar_Data__c where Billing_Account__c =:acc.Id OR Service_Account__c =:acc.Id OR Master_Account__c =:acc.Id limit 1];
      
        system.assertEquals(1,lstNS.size());
        system.assertEquals('Pennsylvania',lstNS[lstNS.size()-1].State1__c);
    }
    
    @isTest static void testCoveredWrapper() {
        apiPortpsNeustarBizPortpsServicesB.CodeBlockInfo ap = new apiPortpsNeustarBizPortpsServicesB.CodeBlockInfo();
        List<Object> lst = ap.NanpaCodeOwnerOcn_type_info;
        List<Object> lst1 =ap.NanpaCodeOwnerOcnName_type_info;
        List<Object> lst2 =ap.PasBlockOwnerOcn_type_info;
        List<Object> lst3 =ap.PasBlockOwnerOcnName_type_info;
        List<Object> lst4 =ap.PasBlockOwnerStatus_type_info;
        List<Object> lst5 =ap.PasBlockOwnerEffectiveDate_type_info;
        List<Object> lst6 =ap.NpacCodeOwnerSpidName_type_info;
        List<Object> lst7 =ap.IlecRbocOcn_type_info;
        List<Object> lst8 =ap.IlecRbocOcnName_type_info;
        List<Object> lst9 =ap.apex_schema_type_info;
        
        
        apiPortpsNeustarBizPortpsServicesB.Geography Geography = new apiPortpsNeustarBizPortpsServicesB.Geography();
        List<Object> Geography1 = Geography.Region_type_info;
         Geography1 =Geography.State_type_info;
         Geography1 =Geography.Lata_type_info;
         Geography1 =Geography.RateCenter_type_info;
         Geography1 =Geography.Latitude_type_info;
         Geography1 =Geography.Longitude_type_info;
         Geography1 =Geography.apex_schema_type_info;
        Geography1 =Geography.field_order_type_info;
        
        apiPortpsNeustarBizPortpsServicesB.Ownership Ownership = new apiPortpsNeustarBizPortpsServicesB.Ownership();
        //List<Object> Geography1 = Geography.Region_type_info;
        Geography1 =Ownership.PhoneNumber_type_info;
        Geography1 =Ownership.Status_type_info;
        Geography1 =Ownership.NpacSpid_type_info;
        Geography1 =Ownership.Company_type_info;
        Geography1 =Ownership.AltSpid_type_info;
        Geography1 =Ownership.LastAltSpid_type_info;
        Geography1 =Ownership.NanpaOcn_type_info;
        Geography1 =Ownership.SvType_type_info;
        Geography1 =Ownership.apex_schema_type_info;
        Geography1 =Ownership.field_order_type_info;
        
        apiPortpsNeustarBizPortpsServicesB.BasicSearchResponse_element BasicSearchResponse_element = new apiPortpsNeustarBizPortpsServicesB.BasicSearchResponse_element();
        Geography1 =BasicSearchResponse_element.ResponseCode_type_info;
        Geography1 =BasicSearchResponse_element.ResponseMessage_type_info;
        Geography1 =BasicSearchResponse_element.TnResponseList_type_info; 
        Geography1 =BasicSearchResponse_element.apex_schema_type_info;
        Geography1 =BasicSearchResponse_element.field_order_type_info;
        
        apiPortpsNeustarBizPortpsServicesB.PortingInfoType PortingInfoType = new apiPortpsNeustarBizPortpsServicesB.PortingInfoType();
        Geography1 =PortingInfoType.Date_x_type_info;
        Geography1 =PortingInfoType.Event_type_info;
        Geography1 =PortingInfoType.Status_type_info;
        Geography1 =PortingInfoType.NpacSpid_type_info;
        Geography1 =PortingInfoType.NpacSpidCompanyName_type_info;
        Geography1 =PortingInfoType.AltSpid_type_info;
        Geography1 =PortingInfoType.AltSpidCompanyName_type_info;
        Geography1 =PortingInfoType.LastAltSpid_type_info;
        
        Geography1 =PortingInfoType.LastAltSpidCompanyName_type_info;
        Geography1 =PortingInfoType.NanpaOcn_type_info;
        Geography1 =PortingInfoType.NanpaOcnCompanyName_type_info;
        Geography1 =PortingInfoType.LRN_type_info;
        Geography1 =PortingInfoType.SvType_type_info;
        Geography1 =PortingInfoType.ClassDpcSsn_type_info;
        Geography1 =PortingInfoType.LidbDpcSsn_type_info;
        Geography1 =PortingInfoType.IsvmDpcSsn_type_info;
        Geography1 =PortingInfoType.CnamDpcSsn_type_info;
        Geography1 =PortingInfoType.WsmscDpcSsn_type_info;
        Geography1 =PortingInfoType.BillingId_type_info;
        
        Geography1 =PortingInfoType.EndUserLocation_type_info;
        Geography1 =PortingInfoType.EndUserLocationType_type_info;
        Geography1 =PortingInfoType.VoiceUri_type_info;
        Geography1 =PortingInfoType.MmsUri_type_info;
        Geography1 =PortingInfoType.SmsUri_type_info;
        Geography1 =PortingInfoType.apex_schema_type_info;
        Geography1 =PortingInfoType.field_order_type_info;
        
        
        apiPortpsNeustarBizPortpsServicesB.TNResponseListType TNResponseListType = new apiPortpsNeustarBizPortpsServicesB.TNResponseListType();
        Geography1 =TNResponseListType.TNResponse_type_info;
        Geography1 =TNResponseListType.apex_schema_type_info;
        Geography1 =TNResponseListType.field_order_type_info;
    } 
    @isTest static void testNeustarApiSch() {
        String sch = '0 0 18 * * ? *';
        Test.startTest();
            List<CronTrigger> lstCronTrigger = [SELECT Id, CronJobDetail.Name FROM CronTrigger where CronJobDetail.Name = 'NeustarApiBatch Job:ExistingND'];
            system.debug('lstCronTrigger :: '+lstCronTrigger.size());	
        if(lstCronTrigger.size() == 0)	String jobID = system.schedule('NeustarApiBatch Job:ExistingND', sch, new NeustarApiSch('ExistingND'));
        else String jobID1 = system.schedule('NeustarApiBatch Job:ExistingND11', sch, new NeustarApiSch('ExistingND'));
        Test.stopTest();
    }
 
}