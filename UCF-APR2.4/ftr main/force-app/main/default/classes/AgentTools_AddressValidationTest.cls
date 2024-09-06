@isTest(seeAllData = true)
private class AgentTools_AddressValidationTest {

    static testMethod void myUnitTest() {        
        AgentTools_AddressValidation.LeadObject newLead = new AgentTools_AddressValidation.LeadObject();
        //insert newLead;
        AgentTools_AddressValidation agnTlsAddVal = new AgentTools_AddressValidation(newLead);
        //agnTlsAddVal.singleAddressLookup.Phone = '4569557878';
        agnTlsAddVal.singleAddressLookup.Street = '2120 cannes dr';
        agnTlsAddVal.singleAddressLookup.City = 'Carrollton';
        agnTlsAddVal.singleAddressLookup.StateOrProvince = 'Tx';
        agnTlsAddVal.singleAddressLookup.PostalCode = '75006';
        agnTlsAddVal.singleAddressLookup.Phone = '4569557878';     

        agnTlsAddVal.SelectedRecordId = 2;
        PageReference pageRef = Page.AgentTools;
        Test.setCurrentPage(pageRef);
        //ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(newLead);
        AgentTools_AddressValidation agnTlsAddVal1 = new AgentTools_AddressValidation(newLead);        
            
        WS_ESB_BusinessObjects.CitizensServiceAddress citSerAdd = new WS_ESB_BusinessObjects.CitizensServiceAddress();
        WS_ESB_BusinessObjects.TechnologyType techType = new WS_ESB_BusinessObjects.TechnologyType();
        
        Test.setMock(HttpCalloutMock.class, new AgentTools_GetTechforAdrRespMock());
        Test.setMock(WebServiceMock.class, new ManageAddressGetAddMockTest()); 
        /*agnTlsAddVal.RetrieveAddressRecords();
        Test.setMock(WebServiceMock.class, new ManageAddressGetAddMockTest1()); 
        agnTlsAddVal.RetrieveAddressRecords();
        agnTlsAddVal.SelectedCriteria = 'Address'; //'Telephone';
        Test.setMock(WebServiceMock.class, new ManageAddressGetAddMockTest()); 
        agnTlsAddVal.RetrieveAddressRecords();
        Test.setMock(WebServiceMock.class, new ManageAddressGetAddMockTest1()); 
        agnTlsAddVal.RetrieveAddressRecords();  */      
        
        AgentTools_AddressValidation.ServiceAddress serAdd = new AgentTools_AddressValidation.ServiceAddress();
        serAdd.RecordId = 2;    
        serAdd.Address = citSerAdd;
        serAdd.Business_Technologies = new List<WS_ESB_BusinessObjects.TechnologyType>();
        serAdd.Business_Technologies.add(techType);
        serAdd.Residential_Technologies = new List<WS_ESB_BusinessObjects.TechnologyType>();
        serAdd.Residential_Technologies.add(techType);
        serAdd.UVerseCapable = true;
        agnTlsAddVal.ServiceAddresses.add(serAdd);
        
        AgentTools_AddressValidation.RequestedAddress reqAdd = new AgentTools_AddressValidation.RequestedAddress();
        reqAdd.Street = '2120 cannes dr';
        reqAdd.City = 'Carrollton';
        reqAdd.StateOrProvince = 'TX';
        reqAdd.PostalCode ='75006';
        reqAdd.Phone = '2145554411';
        agnTlsAddVal.multipleAddressLookup = new List<AgentTools_AddressValidation.RequestedAddress>();
        agnTlsAddVal.multipleAddressLookup.add(reqAdd);		       
        
        WS_ESB_ManageAddress.ManageAddressGetAddressRequest manAddGetAddReq2 = agnTlsAddVal.RPSA_Request();        
        
        agnTlsAddVal.singleAddressLookup = new AgentTools_AddressValidation.RequestedAddress();
        agnTlsAddVal.singleAddressLookup = reqAdd;                
        
        AgentTools_AddressValidation.HughesRequest  hugReq = new AgentTools_AddressValidation.HughesRequest();
        hugReq.siteId = 'nice';
        hugReq.customerId = 'nice';
        hugReq.servicePhone = '2145554411';
        hugReq.serviceAddress1 = '123 abc street';
        hugReq.serviceAddress2 = '123 abc street';
        hugReq.city = 'Dallas';
        hugReq.state = 'TX';
        hugReq.zip = '75022';
        hugReq.hsiUpDown = 'UP';
        hugReq.fiberUpDown = 'UP';
        hugReq.fiberVideo = 'UP';
       
        agnTlsAddVal.ShowPopup();
        agnTlsAddVal.HidePopup();
        ServiceAddressWrapper serAd = agnTlsAddVal.getServiceAddressDetail();
        
      /*try{
            integer temp = integer.valueOf('asdf');
        }catch(Exception e){
            agnTlsAddVal.EmailError(e);
        } */
        
        WS_ESB_ManageAddress.ManageAddressGetAddressRequest manAddGetAddReq1 = agnTlsAddVal.RTN_Request();
        //WS_ESB_ManageAddress.ManageAddressGetAddressRequest manAddGetAddReq2 = agnTlsAddVal.RPSA_Request();
        WS_ESB_ManageAddress.ManageAddressGetAddressRequest manAddGetAddReq3 = agnTlsAddVal.RSA_Request();
        
        agnTlsAddVal.ResetFields();
        List<AgentTools_AddressValidation.ServiceAddress> sa = agnTlsAddVal.getAddressRecords();
        List<SelectOption> sOpt = agnTlsAddVal.getStates();
        
        WS_ESB_ManageAddress.ManageAddressGetAddressRequest manAddGetAddRes1 = agnTlsAddVal.RSA_Request();
        //WS_ESB_ManageAddress.ManageAddressGetAddressResponse manAddGetAddRes1 =
        
        Test.startTest();
        
        agnTlsAddVal.SelectedCriteria = 'Address';         
        //agnTlsAddVal.RetrieveAddressRecords();
        //agnTlsAddVal.getNewAddressess();
    
        agnTlsAddVal.SelectedCriteria = 'Telephone';        
        //agnTlsAddVal.RetrieveAddressRecords();
        
        
        Test.stopTest();
        
    }
}