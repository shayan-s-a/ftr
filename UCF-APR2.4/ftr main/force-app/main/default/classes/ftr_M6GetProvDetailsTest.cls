/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest(seeAllData = false)
public class ftr_M6GetProvDetailsTest {
   
   @isTest
	 static void myUnitTest() {
        //List<IntegrationAPIConfig__mdt> apiConfigs = [SELECT Timeout__c, ApiKey__c,Authorization_Header__c ,Correlationid__c,OssAuthToken__c,UserName__c,Endpoint__c	 FROM IntegrationAPIConfig__mdt WHERE DeveloperName=: 'OSSAPIAuthentication' LIMIT 1];
        //System.debug('apiConfigs--'+apiConfigs);
         String documentNumber = '3181333';
        Map<String,Object> docMap = new Map<String,Object>();
        docMap.put('DOCUMENT_NUMBER',documentNumber); 
 		
        ftr_M6GetProvisioningOrderDetails getProvDetails = new ftr_M6GetProvisioningOrderDetails();
        Test.setMock(HttpCalloutMock.class, new ftr_OssApiCallOutMock());
         Test.startTest();
         try{
               getProvDetails.invoke('getProvisioningOrderDetails', docMap);
         }
         catch(Exception E){
             System.debug('Exception thrown');
         }
        Test.stopTest();
    }
	
}