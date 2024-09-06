@isTest
public class AgentTools_GetTechnologyForAddressTest {
    // version 1 
    /*@testSetup
    static void testSetup() {
        WS_ESB_Settings__c objSetting = new WS_ESB_Settings__c(FBV_Apigee_Token__c = 'MW35cUl3YX0F4V23qd9ZWGuVocmRz10o', EC_ApplicationID__c = 'SFDC', EC_EmployeeID__c = '123456', EC_UserID__c = 'ESB_REG');
        insert objSetting;
    }*/
    public static testMethod void getTechnologyForAddressTest() { 
         Test.setMock(HttpCalloutMock.class, new AgentTools_GetTechforAdrRespMock());
        String evCode ='FT';
        Integer serviceControlNumber=536670;
        Boolean b = AgentTools_GetTechnologyForAddress.getTechnologyForAddress(evCode, serviceControlNumber);
        System.debug('b');
    }
     static testmethod void testIncrement() {
        Test.startTest();
       // AgentTools_GetTechnologyForAddress.dummytestcoverage();
        Test.stopTest(); 
        
 }

}