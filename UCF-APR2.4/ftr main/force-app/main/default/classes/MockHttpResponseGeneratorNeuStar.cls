@isTest
global class MockHttpResponseGeneratorNeuStar implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
       apiPortpsNeustarBizPortpsServicesB.BasicSearchResponse_element response_x = new apiPortpsNeustarBizPortpsServicesB.BasicSearchResponse_element();
       //response_x = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><ns1:BasicSearchResponse xmlns:ns1="https://api-portps.neustar.biz/portps/services/BasicSearchService/"><ResponseCode>3000</ResponseCode><ResponseMessage>Processed</ResponseMessage><TnResponseList><TNResponse><Ownership><PhoneNumber>5702476072</PhoneNumber><Status>Ported - Intra</Status><NpacSpid>0161</NpacSpid><Company>FrontierPA_CTCO:0161 - NSR/1</Company><AltSpid/><LastAltSpid/><NanpaOcn>0161</NanpaOcn><SvType>Wireline</SvType></Ownership><Geography><Region>Mid-Atlantic</Region><State>Pennsylvania</State><Lata>232 - NORTHEAST - PA</Lata><RateCenter>ROME</RateCenter><Latitude>41.78</Latitude><Longitude>-76.44</Longitude></Geography><Routing><Lrn>5702650088</Lrn><ClassDpcSsn>235235001-000</ClassDpcSsn><LidbDpcSsn>238013000-000</LidbDpcSsn><IsvmDpcSsn>235235001-000</IsvmDpcSsn><CnamDpcSsn>238013000-000</CnamDpcSsn><WsmscDpcSsn/></Routing><CodeBlockInfo><NanpaCodeOwnerOcn>0161</NanpaCodeOwnerOcn><NanpaCodeOwnerOcnName>COMMONWEALTH TELEPHONE COMPANY LLC</NanpaCodeOwnerOcnName><PasBlockOwnerOcn>3806</PasBlockOwnerOcn><PasBlockOwnerOcnName>CORE COMMUNICATIONS, INC. - PA</PasBlockOwnerOcnName><PasBlockOwnerStatus>Assigned</PasBlockOwnerStatus><PasBlockOwnerEffectiveDate>03/27/2019 12:00 AM, EDT</PasBlockOwnerEffectiveDate><NpacCodeOwnerSpid>0161</NpacCodeOwnerSpid><NpacCodeOwnerSpidName>FrontierPA_CTCO:0161 - NSR/1</NpacCodeOwnerSpidName><IlecRbocOcn>LERG/DIR Listing Required</IlecRbocOcn><IlecRbocOcnName>LERG/DIR Listing Required</IlecRbocOcnName></CodeBlockInfo><AdditionalFields><BillingId/><EndUserLocation/><EndUserLocationType/></AdditionalFields><IpFields><VoiceUri/><MmsUri/><SmsUri/></IpFields></TNResponse></TnResponseList></ns1:BasicSearchResponse></soapenv:Body></soapenv:Envelope>';
       response_x.ResponseMessage = 'Processed';
	   response.put('response_x', response_x); 
   }
}