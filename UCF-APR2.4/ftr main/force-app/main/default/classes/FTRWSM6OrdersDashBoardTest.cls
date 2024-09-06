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
public class FTRWSM6OrdersDashBoardTest {
    
    public static testMethod void  Test1(){ 
          Id carrierRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;
        Account acc = new Account();
        acc.Name='testAccount';
        acc.RecordTypeId = carrierRecId;
        insert acc;
        
        FTRWSAcna__c acna = new FTRWSAcna__c();
        acna.Name = 'GIM';
        acna.Company__c = acc.id;
        insert acna;
        
        FTRWSPnum__c pnum = new FTRWSPnum__c();
        pnum.Name ='test1';
        pnum.Wholesale_ACNA__c = acna.id;
        insert pnum;   
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.Wholesale_ACNA__c = acna.Id;
        opp.Wholesale_Pnum__c = pnum.Id; 
        opp.Project_Id__c = 'TEST1111';
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
     
        
        Wholesale_Service_Order__c woins = new Wholesale_Service_Order__c();
        woins.Service_Order__c = '12019892';
        woins.OpportunityId__c=opp.id;
        
        insert woins;
        
        
        
        System.debug('wo'+woins.id);
        
        //Defect OAM-1369 - updated sample request with Priloc fields
        //String reqUri='{"Order":{"OpportunityNumber":"'+opp.Id+'","ACNA":"'+acna.Id+'","CCNA":"'+acc.Id+'","PNUM":"'+pnum.Id+'","ProjectId":"TEST1111","DSATID":"dsat","VTA":"vta","UNIBDW":"unidbw","EVCBDW":"evcbdw","CNO":"cno","QoS":"QoS","Expedite":true,"OrderStage":"101","BDTRequired":true,"MaxServiceFrameSize":"100","ServiceOrderNo": "12019892","PON": "122223","Version": "78","RPON": "17899","ASRRemarks": "asr remarkss","RequestedDueDate": "2021-06-07","ScheduledDueDate": "2021-06-07","ControlKeyNo": "67","UNISpecCode": "unispec code","EVCSpecCode": "EVC spec code","SEI": "SEI","EVCI": "EVCI","InitiatiorName": "Ini Name","InitiatiorNumber":"7879987655","InitiatiorEmail":"ini@email.org","CircuitQuantity":"11","UNINC":"UNIINC","UNINCI":"UNINCI","UNISECNCI":"UNISECNCI","EVCNC":"EBCNC","EVCNCI":"EVCNCI","MUX":"MUX","CFA":"CFA","CCEA":"CCEA","SUPPLEMENTTYPE":"ST","PRILOC_EndUserName":"pname","PRILOC_STREET_NUMBER":"2925", "PRILOC_STREET_NAME":"INTERSTATE PKWY", "PRILOC_CITY":"BRUNSWICK", "PRILOC_STATE":"OH", "PRILOC_ZIP":"44212","PRILOC_ACTL_NNI_CLLI":"pclli","PRILOC_LCON":"plcon","PRILOC_LCON_TN":"7608123445","PRILOC_LCON_Email":"plconemail@gmail.org","SECLOC_EndUserName":"sname","SECLOC_EndUserAddress":"saddress","SECLOC_ACTL_NNI_CLLI":"sclli","SECLOC_LCON":"slcon","SECLOC_LCON_TN":"789765432","SECLOC_LCON_Email":"test@test.org"}}';
        String reqUri='{"Order":{"OpportunityNumber":"'+opp.Id+'","ACNA":"'+acna.Id+'","CCNA":"'+acc.Id+'","PNUM":"'+pnum.Id+'","ProjectId":"TEST1111","DSATID":"dsat","VTA":"vta","UNIBDW":"unidbw","EVCBDW":"evcbdw","CNO":"cno","QoS":"QoS","Expedite":true,"OrderStage":"101","BDTNumber":"1234","BDTRequired":true,"MaxServiceFrameSize":"100","type_of_sr":"ASR","ACTIVITY_IND":"New","ServiceOrderNo": "12019892","PON": "122223","Version": "78","RPON": "17899","ASRRemarks": "asr remarkss","RequestedDueDate": "2021-06-07","ScheduledDueDate": "2021-06-07","FOCDate":"2021-10-07T00:00:00","ControlKeyNo": "Control Key:1234,","UNISpecCode": "unispec code","EVCSpecCode": "EVC spec code","SEI": "SEI","EVCI": "EVCI","InitiatiorName": "Ini Name","InitiatiorNumber":"7879987655","InitiatiorEmail":"ini@email.org","CircuitQuantity":"11","UNINC":"UNIINC","UNINCI":"UNINCI","UNISECNCI":"UNISECNCI","EVCNC":"EBCNC","EVCNCI":"EVCNCI","MUX":"MUX","CFA":"CFA","CCEA":"CCEA","SUPPLEMENTTYPE":"ST","PRILOC_EndUserName":"pname","PRILOC_STREET_NUMBER":"2925", "PRILOC_STREET_NAME":"INTERSTATE PKWY", "PRILOC_CITY":"BRUNSWICK", "PRILOC_STATE":"OH", "PRILOC_ZIP":"44212","PRILOC_ACTL_NNI_CLLI":"pclli","PRILOC_LCON":"plcon","PRILOC_LCON_TN":"7608123445","PRILOC_LCON_Email":"plconemail@gmail.org","SECLOC_EndUserName":"sname","SECLOC_STREET_NUMBER":"2925", "SECLOC_STREET_NAME":"street", "SECLOC_CITY":"BRUNSWICK", "SECLOC_STATE":"OH","SECLOC_ZIP":"44212","SECLOC_ACTL_NNI_CLLI":"sclli","SECLOC_LCON":"slcon","SECLOC_LCON_TN":"789765432","SECLOC_LCON_Email":"test@test.org"}}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/orders/'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueOf(reqUri);
        RestContext.request = req;
        RestContext.response = res;
        
        FTRWSM6OrderWrapper m6orderObj = (FTRWSM6OrderWrapper) JSON.deserialize(req.requestBody.toString(), FTRWSM6OrderWrapper.class);
        System.debug('m6orderObj.order.ProjectId: ' + m6orderObj.order.ProjectId);
        System.debug('m6orderObj.order.PRILOC_CITY: ' + m6orderObj.order.PRILOC_CITY);
        Test.startTest();
        FTRWSM6OrdersDashBoard dashborad = new FTRWSM6OrdersDashBoard();
        FTRWSM6OrdersDashBoard.getLatestOpportunity(m6orderObj);
        FTRWSM6OrdersDashBoard.populateServiceOrder(null, m6orderObj);
        FTRWSM6OrdersDashBoard.populateServiceOrder(woins, m6orderObj);
        FTRWSM6OrdersDashBoard.getPnum(pnum.Name, acna.Id);
        FTRWSM6OrdersDashBoard.upsertOrder();
        
        Test.stopTest();  
    }
    
    public static testMethod void  Test12(){  
         Id carrierRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;
    
        Account acc = new Account();
        acc.Name='testAccount';
         acc.RecordTypeId = carrierRecId;
        insert acc;
        
        FTRWSAcna__c acna = new FTRWSAcna__c();
        acna.Name = 'GIM';
        acna.Company__c = acc.id;
        insert acna;
        
        FTRWSPnum__c pnum = new FTRWSPnum__c();
        pnum.Name ='test1';
        pnum.Wholesale_ACNA__c = acna.id;
        insert pnum;   
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.Wholesale_ACNA__c = acna.Id;
        opp.Wholesale_Pnum__c = pnum.Id; 
        opp.Project_Id__c = 'TEST1111';
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
        Wholesale_Service_Order__c woins = new Wholesale_Service_Order__c();
        woins.Service_Order__c = '12019892';
        woins.OpportunityId__c=opp.id;
        
        insert woins;
        
        
        
        System.debug('wo'+woins.id);
        String reqUri='{"Order":{"OpportunityNumber":"'+opp.Id+'","ACNA":"'+acna.Id+'","CCNA":"'+acc.Id+'","PNUM":"'+pnum.Id+'","ProjectId":"TEST1111","DSATID":"dsat","VTA":"vta","UNIBDW":"unidbw","EVCBDW":"evcbdw","CNO":"cno","QoS":"QoS","Expedite":true,"OrderStage":"101","BDTRequired":true,"MaxServiceFrameSize":"100","ServiceOrderNo": "12019892","PON": "122223","Version": "78","RPON": "17899","ASRRemarks": "asr remarkss","RequestedDueDate": "2021-06-07","ScheduledDueDate": "2021-06-07","ControlKeyNo": "67","UNISpecCode": "unispec code","EVCSpecCode": "EVC spec code","SEI": "SEI","EVCI": "EVCI","InitiatiorName": "Ini Name","InitiatiorNumber":"7879987655","InitiatiorEmail":"ini@email.org","CircuitQuantity":"11","UNINC":"UNIINC","UNINCI":"UNINCI","UNISECNCI":"UNISECNCI","EVCNC":"EBCNC","EVCNCI":"EVCNCI","MUX":"MUX","CFA":"CFA","CCEA":"CCEA","SUPPLEMENTTYPE":"ST","PRILOC_EndUserName":"pname","PRILOC_EndUserAddress":"address","PRILOC_ACTL_NNI_CLLI":"pclli","PRILOC_LCON":"plcon","PRILOC_LCON_TN":"7608123445","PRILOC_LCON_Email":"plconemail@gmail.org","SECLOC_EndUserName":"sname","SECLOC_EndUserAddress":"saddress","SECLOC_ACTL_NNI_CLLI":"sclli","SECLOC_LCON":"slcon","SECLOC_LCON_TN":"789765432","SECLOC_LCON_Email":"test@test.org"}}';
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/orders/'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueOf(reqUri);
        RestContext.request = req;
        RestContext.response = res;
        
        FTRWSM6OrderWrapper m6orderObj = (FTRWSM6OrderWrapper) JSON.deserialize(req.requestBody.toString(), FTRWSM6OrderWrapper.class);
        System.debug('m6orderObj.order.ProjectId: ' + m6orderObj.order.ProjectId);
        Test.startTest();
        FTRWSM6OrdersDashBoard dashborad = new FTRWSM6OrdersDashBoard();
        FTRWSM6OrdersDashBoard.getLatestOpportunity(m6orderObj);
        FTRWSM6OrdersDashBoard.populateServiceOrder(null, m6orderObj);
        FTRWSM6OrdersDashBoard.populateServiceOrder(woins, m6orderObj);
        FTRWSM6OrdersDashBoard.getPnum(pnum.Name, acna.Id);
        FTRWSM6OrdersDashBoard.upsertOrder();
        
        Test.stopTest();  
    }
    
    public static testMethod void  Test13(){  
        Id carrierRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;
       
        Account acc = new Account();
        acc.Name='testAccount';
         acc.RecordTypeId = carrierRecId;
        insert acc;
        
        FTRWSAcna__c acna = new FTRWSAcna__c();
        acna.Name = 'GIM';
        acna.Company__c = acc.id;
        insert acna;
        
        FTRWSPnum__c pnum = new FTRWSPnum__c();
        pnum.Name ='test1';
        pnum.Wholesale_ACNA__c = acna.id;
        insert pnum;   
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.Wholesale_ACNA__c = acna.Id;
        opp.Wholesale_Pnum__c = pnum.Id; 
        opp.Project_Id__c = 'TEST1111';
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        opp.recordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Carrier_Service').getRecordTypeId();
        
        
        insert opp;
        
        Wholesale_Service_Order__c woins = new Wholesale_Service_Order__c();
        woins.Service_Order__c = '12019892';
        woins.OpportunityId__c=opp.id;
        
        insert woins;
        
        
        
        System.debug('wo'+woins.id);
        String reqUri='{"Order":{"ACNA":"'+acna.Name+'","CCNA":"'+acc.Id+'","PNUM":"'+pnum.Id+'","DSATID":"dsat","VTA":"vta","UNIBDW":"unidbw","EVCBDW":"evcbdw","CNO":"cno","QoS":"QoS","Expedite":true,"OrderStage":"101","BDTRequired":true,"MaxServiceFrameSize":"100","ServiceOrderNo": "12019892","PON": "122223","Version": "78","RPON": "17899","ASRRemarks": "asr remarkss","RequestedDueDate": "2021-06-07","ScheduledDueDate": "2021-06-07","ControlKeyNo": "67","UNISpecCode": "unispec code","EVCSpecCode": "EVC spec code","SEI": "SEI","EVCI": "EVCI","InitiatiorName": "Ini Name","InitiatiorNumber":"7879987655","InitiatiorEmail":"ini@email.org","CircuitQuantity":"11","UNINC":"UNIINC","UNINCI":"UNINCI","UNISECNCI":"UNISECNCI","EVCNC":"EBCNC","EVCNCI":"EVCNCI","MUX":"MUX","CFA":"CFA","CCEA":"CCEA","SUPPLEMENTTYPE":"ST","PRILOC_EndUserName":"pname","PRILOC_EndUserAddress":"address","PRILOC_ACTL_NNI_CLLI":"pclli","PRILOC_LCON":"plcon","PRILOC_LCON_TN":"7608123445","PRILOC_LCON_Email":"plconemail@gmail.org","SECLOC_EndUserName":"sname","SECLOC_EndUserAddress":"saddress","SECLOC_ACTL_NNI_CLLI":"sclli","SECLOC_LCON":"slcon","SECLOC_LCON_TN":"789765432","SECLOC_LCON_Email":"test@test.org", "CircuitId": "[{\\"CircuitId\\":\\"30/KRGN/677452/ /FTNC/ \\",\\"UNINC\\":\\"KRA3\\",\\"UNINCI\\":\\"02LNF.A04\\",\\"UNISECNCI\\":\\"02CXF.1GE\\"}]"}}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/orders/'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueOf(reqUri);
        RestContext.request = req;
        RestContext.response = res;
        
        FTRWSM6OrderWrapper m6orderObj = (FTRWSM6OrderWrapper) JSON.deserialize(req.requestBody.toString(), FTRWSM6OrderWrapper.class);
        System.debug('m6orderObj.order.ProjectId: ' + m6orderObj.order.ProjectId);
        Test.startTest();
        FTRWSM6OrdersDashBoard dashborad = new FTRWSM6OrdersDashBoard();
        FTRWSM6OrdersDashBoard.getLatestOpportunity(m6orderObj);
        FTRWSM6OrdersDashBoard.populateServiceOrder(null, m6orderObj);
        FTRWSM6OrdersDashBoard.populateServiceOrder(woins, m6orderObj);
        FTRWSM6OrdersDashBoard.getPnum(pnum.Name, acna.Id);
        FTRWSM6OrdersDashBoard.upsertOrder();
        
        Test.stopTest();  
    }
    
    public static testMethod void  Test14(){     
        Id carrierRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;
       
        Account acc = new Account();
        acc.Name='testAccount';
        acc.RecordTypeId = carrierRecId;
        insert acc;
        
        FTRWSAcna__c acna = new FTRWSAcna__c();
        acna.Name = 'GIM';
        acna.Company__c = acc.id;
        insert acna;
        
        FTRWSPnum__c pnum = new FTRWSPnum__c();
        pnum.Name ='test1';
        pnum.Wholesale_ACNA__c = acna.id;
        insert pnum;   
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.Wholesale_ACNA__c = acna.Id;
        opp.Wholesale_Pnum__c = pnum.Id; 
        //opp.Project_Id__c = 'TEST1111';
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
        
        FTRWSAddress__c  address = new FTRWSAddress__c();
        address.Street_Number__c = '2925';
        address.Street_Name__c = 'INTERSTATE PKWY';
        address.City__c = 'BRUNSWICK';
        address.State__c = 'OH';
        address.Zip_Code__c = '44212';
        address.Opportunity_ID__c = opp.id;
        
        insert address;        
        
        Wholesale_Service_Order__c woins = new Wholesale_Service_Order__c();
        woins.Service_Order__c = '12019892';
        woins.OpportunityId__c=opp.id;
        
        insert woins;
        
        String nullStr = null;
        
        System.debug('wo'+woins.id);
        
        //Defect OAM-1369 - updated sample request with Priloc fields
        Id oppId = null;
        
        String reqUri='{"Order":{"OpportunityNumber":"'+oppId+'","ACNA":"'+acna.Name+'","CCNA":"'+acc.Id+'","PNUM":"'+pnum.Id+'","DSATID":"dsat","VTA":"vta","UNIBDW":"unidbw","EVCBDW":"evcbdw","CNO":"cno","QoS":"QoS","Expedite":true,"OrderStage":"101","BDTNumber":"1234","BDTRequired":"Y","MaxServiceFrameSize":"100","type_of_sr":"ASR","ACTIVITY_IND":"New","ServiceOrderNo": "12019892","PON": "122223","Version": "78","RPON": "17899","ASRRemarks": "asr remarkss","RequestedDueDate": "2021-06-07","ScheduledDueDate": "2021-06-07","FOCDate":"2021-10-07T00:00:00","ControlKeyNo": "Control Key:1234,","UNISpecCode": "unispec code","EVCSpecCode": "EVC spec code","SEI": "SEI","EVCI": "EVCI","InitiatiorName": "Ini Name","InitiatiorNumber":"7879987655","InitiatiorEmail":"ini@email.org","CircuitQuantity":"11","UNINC":"UNIINC","UNINCI":"UNINCI","UNISECNCI":"UNISECNCI","EVCNC":"EBCNC","EVCNCI":"EVCNCI","MUX":"MUX","CFA":"CFA","CCEA":"CCEA","SUPPLEMENTTYPE":"1","PRILOC_EndUserName":"pname","PRILOC_STREET_NUMBER":"2925", "PRILOC_STREET_NAME":"INTERSTATE PKWY", "PRILOC_CITY":"BRUNSWICK", "PRILOC_STATE":"OH", "PRILOC_ZIP":"44212","PRILOC_ACTL_NNI_CLLI":"pclli","PRILOC_LCON":"plcon","PRILOC_LCON_TN":"7608123445","PRILOC_LCON_Email":"plconemail@gmail.org","SECLOC_EndUserName":"sname","SECLOC_STREET_NUMBER":"2925", "SECLOC_STREET_NAME":"street", "SECLOC_CITY":"BRUNSWICK", "SECLOC_STATE":"OH","SECLOC_ZIP":"44212","SECLOC_ACTL_NNI_CLLI":"sclli","SECLOC_LCON":"slcon","SECLOC_LCON_TN":"789765432","SECLOC_LCON_Email":"test@test.org"}}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/orders/'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueOf(reqUri);
        RestContext.request = req;
        RestContext.response = res;
        
        FTRWSM6OrderWrapper m6orderObj = (FTRWSM6OrderWrapper) JSON.deserialize(req.requestBody.toString(), FTRWSM6OrderWrapper.class);
        System.debug('m6orderObj.order.ProjectId: ' + m6orderObj.order.ProjectId);
        System.debug('m6orderObj.order.PRILOC_CITY: ' + m6orderObj.order.PRILOC_CITY);
        Test.startTest();
        FTRWSM6OrdersDashBoard dashborad = new FTRWSM6OrdersDashBoard();
        FTRWSM6OrdersDashBoard.getLatestOpportunity(m6orderObj);
        FTRWSM6OrdersDashBoard.populateServiceOrder(null, m6orderObj);
        FTRWSM6OrdersDashBoard.populateServiceOrder(woins, m6orderObj);
        FTRWSM6OrdersDashBoard.getPnum(pnum.Name, acna.Id);
        FTRWSM6OrdersDashBoard.upsertOrder();
        
        Test.stopTest();  
    }
    
	//Test error scenario
    public static testMethod void  TestError(){  
         Id carrierRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;
      
        Account acc = new Account();
        acc.Name='testAccount';
        acc.RecordTypeId = carrierRecId;
        insert acc;
        
        FTRWSAcna__c acna = new FTRWSAcna__c();
        acna.Name = 'GIM';
        acna.Company__c = acc.id;
        insert acna;
        
        FTRWSPnum__c pnum = new FTRWSPnum__c();
        pnum.Name ='test1';
        pnum.Wholesale_ACNA__c = acna.id;
        insert pnum;   
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.Wholesale_ACNA__c = acna.Id;
        opp.Wholesale_Pnum__c = pnum.Id; 
        //opp.Project_Id__c = 'TEST1111';
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
        
        FTRWSAddress__c  address = new FTRWSAddress__c();
        address.Street_Number__c = '2925';
        address.Street_Name__c = 'INTERSTATE PKWY';
        address.City__c = 'BRUNSWICK';
        address.State__c = 'OH';
        address.Zip_Code__c = '44212';
        address.Opportunity_ID__c = opp.id;
        
        insert address;        
        
        Wholesale_Service_Order__c woins = new Wholesale_Service_Order__c();
        woins.Service_Order__c = '12019892';
        woins.OpportunityId__c=opp.id;
        
        insert woins;
        
        String nullStr = null;
        
        System.debug('wo'+woins.id);
        
        //Defect OAM-1369 - updated sample request with Priloc fields
        //Id oppId = '00605000005IxtjAAP';
        acna.Name = 'MMM';
       
        
        String reqUri='{"Order":{"OpportunityNumber":"'+opp.Id+'","ACNA":"'+acna.Name+'","CCNA":"'+acc.Name+'","PNUM":"'+pnum.Id+'","DSATID":"dsat","VTA":"vta","UNIBDW":"unidbw","EVCBDW":"evcbdw","CNO":"cno","QoS":"QoS","Expedite":true,"OrderStage":"101","BDTNumber":"1234","BDTRequired":"Y","MaxServiceFrameSize":"100","type_of_sr":"ASR","ACTIVITY_IND":"New","ServiceOrderNo": "12019892","PON": "122223","Version": "78","RPON": "17899","ASRRemarks": "asr remarkss","RequestedDueDate": "2021-06-07","ScheduledDueDate": "2021-06-07","FOCDate":"2021-10-07T00:00:00","ControlKeyNo": "Control Key:1234,","UNISpecCode": "unispec code","EVCSpecCode": "EVC spec code","SEI": "SEI","EVCI": "EVCI","InitiatiorName": "Ini Name","InitiatiorNumber":"7879987655","InitiatiorEmail":"ini@email.org","CircuitQuantity":"11","UNINC":"UNIINC","UNINCI":"UNINCI","UNISECNCI":"UNISECNCI","EVCNC":"EBCNC","EVCNCI":"EVCNCI","MUX":"MUX","CFA":"CFA","CCEA":"CCEA","SUPPLEMENTTYPE":"1","PRILOC_EndUserName":"pname","PRILOC_STREET_NUMBER":"2925", "PRILOC_STREET_NAME":"INTERSTATE PKWY", "PRILOC_CITY":"BRUNSWICK", "PRILOC_STATE":"OH", "PRILOC_ZIP":"44212","PRILOC_ACTL_NNI_CLLI":"pclli","PRILOC_LCON":"plcon","PRILOC_LCON_TN":"7608123445","PRILOC_LCON_Email":"plconemail@gmail.org","SECLOC_EndUserName":"sname","SECLOC_STREET_NUMBER":"2925", "SECLOC_STREET_NAME":"street", "SECLOC_CITY":"BRUNSWICK", "SECLOC_STATE":"OH","SECLOC_ZIP":"44212","SECLOC_ACTL_NNI_CLLI":"sclli","SECLOC_LCON":"slcon","SECLOC_LCON_TN":"789765432","SECLOC_LCON_Email":"test@test.org"}}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/orders/'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueOf(reqUri);
        RestContext.request = req;
        RestContext.response = res;
        
        FTRWSM6OrderWrapper m6orderObj = (FTRWSM6OrderWrapper) JSON.deserialize(req.requestBody.toString(), FTRWSM6OrderWrapper.class);
        System.debug('m6orderObj.order.ProjectId: ' + m6orderObj.order.ProjectId);
        System.debug('m6orderObj.order.PRILOC_CITY: ' + m6orderObj.order.PRILOC_CITY);
        Test.startTest();
        FTRWSM6OrdersDashBoard dashborad = new FTRWSM6OrdersDashBoard();
        FTRWSM6OrdersDashBoard.getLatestOpportunity(m6orderObj);
        FTRWSM6OrdersDashBoard.populateServiceOrder(null, m6orderObj);
        FTRWSM6OrdersDashBoard.populateServiceOrder(woins, m6orderObj);
        FTRWSM6OrdersDashBoard.getPnum(pnum.Name, acna.Id);

        FTRWSM6OrdersDashBoard.logErrorMessage(m6orderObj, m6orderObj, '12245', opp.Id, 'Error', 'ErrorMsg');
        FTRWSM6OrdersDashBoard.setErrorResponse('ErrorMsg');
        FTRWSM6OrdersDashBoard.upsertOrder();
        
        Test.stopTest();  
    }
    
    
	//Test Missing ACNA error scenario
    public static testMethod void  TestMissingACNAError(){   
         Id carrierRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Carrier_Service' LIMIT 1]?.Id;
      
        Account acc = new Account();
        acc.Name='testAccount';
        acc.RecordTypeId = carrierRecId;
        insert acc;
        
        FTRWSAcna__c acna = new FTRWSAcna__c();
        acna.Name = 'GIM';
        acna.Company__c = acc.id;
        insert acna;
        
        FTRWSPnum__c pnum = new FTRWSPnum__c();
        pnum.Name ='test1';
        pnum.Wholesale_ACNA__c = acna.id;
        insert pnum;   
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.Wholesale_ACNA__c = acna.Id;
        opp.Wholesale_Pnum__c = pnum.Id; 
        //opp.Project_Id__c = 'TEST1111';
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        insert opp;
        
        
        FTRWSAddress__c  address = new FTRWSAddress__c();
        address.Street_Number__c = '2925';
        address.Street_Name__c = 'INTERSTATE PKWY';
        address.City__c = 'BRUNSWICK';
        address.State__c = 'OH';
        address.Zip_Code__c = '44212';
        address.Opportunity_ID__c = opp.id;
        
        insert address;        
        
        Wholesale_Service_Order__c woins = new Wholesale_Service_Order__c();
        woins.Service_Order__c = '12019892';
        woins.OpportunityId__c=opp.id;
        
        insert woins;
        
        String nullStr = null;
        
        System.debug('wo'+woins.id);
        
        //Defect OAM-1369 - updated sample request with Priloc fields
        //Id oppId = '00605000005IxtjAAP';
        acna.Name = 'FUW';
       
        
        String reqUri='{"Order":{"OpportunityNumber":"'+opp.Id+'","ACNA":"'+acna.Name+'","CCNA":"'+acc.Name+'","PNUM":"'+pnum.Id+'","DSATID":"dsat","VTA":"vta","UNIBDW":"unidbw","EVCBDW":"evcbdw","CNO":"cno","QoS":"QoS","Expedite":true,"OrderStage":"101","BDTNumber":"1234","BDTRequired":"Y","MaxServiceFrameSize":"100","type_of_sr":"ASR","ACTIVITY_IND":"New","ServiceOrderNo": "12019892","PON": "122223","Version": "78","RPON": "17899","ASRRemarks": "asr remarkss","RequestedDueDate": "2021-06-07","ScheduledDueDate": "2021-06-07","FOCDate":"2021-10-07T00:00:00","ControlKeyNo": "Control Key:1234,","UNISpecCode": "unispec code","EVCSpecCode": "EVC spec code","SEI": "SEI","EVCI": "EVCI","InitiatiorName": "Ini Name","InitiatiorNumber":"7879987655","InitiatiorEmail":"ini@email.org","CircuitQuantity":"11","UNINC":"UNIINC","UNINCI":"UNINCI","UNISECNCI":"UNISECNCI","EVCNC":"EBCNC","EVCNCI":"EVCNCI","MUX":"MUX","CFA":"CFA","CCEA":"CCEA","SUPPLEMENTTYPE":"1","PRILOC_EndUserName":"pname","PRILOC_STREET_NUMBER":"2925", "PRILOC_STREET_NAME":"INTERSTATE PKWY", "PRILOC_CITY":"BRUNSWICK", "PRILOC_STATE":"OH", "PRILOC_ZIP":"44212","PRILOC_ACTL_NNI_CLLI":"pclli","PRILOC_LCON":"plcon","PRILOC_LCON_TN":"7608123445","PRILOC_LCON_Email":"plconemail@gmail.org","SECLOC_EndUserName":"sname","SECLOC_STREET_NUMBER":"2925", "SECLOC_STREET_NAME":"street", "SECLOC_CITY":"BRUNSWICK", "SECLOC_STATE":"OH","SECLOC_ZIP":"44212","SECLOC_ACTL_NNI_CLLI":"sclli","SECLOC_LCON":"slcon","SECLOC_LCON_TN":"789765432","SECLOC_LCON_Email":"test@test.org"}}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/orders/'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueOf(reqUri);
        RestContext.request = req;
        RestContext.response = res;
        
        FTRWSM6OrderWrapper m6orderObj = (FTRWSM6OrderWrapper) JSON.deserialize(req.requestBody.toString(), FTRWSM6OrderWrapper.class);
        System.debug('m6orderObj.order.ProjectId: ' + m6orderObj.order.ProjectId);
        System.debug('m6orderObj.order.PRILOC_CITY: ' + m6orderObj.order.PRILOC_CITY);
        Test.startTest();
        FTRWSM6OrdersDashBoard dashborad = new FTRWSM6OrdersDashBoard();
        FTRWSM6OrdersDashBoard.getLatestOpportunity(m6orderObj);
        FTRWSM6OrdersDashBoard.populateServiceOrder(null, m6orderObj);
        FTRWSM6OrdersDashBoard.populateServiceOrder(woins, m6orderObj);
        FTRWSM6OrdersDashBoard.getPnum(pnum.Name, acna.Id);

        FTRWSM6OrdersDashBoard.logErrorMessage(m6orderObj, m6orderObj, '12245', opp.Id, 'Error', 'ErrorMsg');
        FTRWSM6OrdersDashBoard.setErrorResponse('ErrorMsg');
        FTRWSM6OrdersDashBoard.upsertOrder();
        FTRWSM6OrdersDashBoard.emailErrorDetailsToUsers('List has no rows for assignment to SObject', 'TEST', 'TEST', 'TEST', 'TEST123');
        
        Test.stopTest();  
    }
    
}