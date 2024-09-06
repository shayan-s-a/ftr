/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public with sharing class ftr_GetLocationContactTest {
    @TestSetup
    static void insertLocationContact(){
      
     List<Order> orderList = new List<Order>();
        orderList = ftr_TestDataFactory.getOrders(1);
        insert orderList;
     
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'contact';
        con.Phone = '1112223333';
        insert con;
        
     Location_Contact__c loccon = new Location_Contact__c();
        
        loccon.service_account__c = orderList[0].AccountId ;
        loccon.order__c = orderList[0].Id;
        loccon.Contact__c = con.Id;
        loccon.name ='test contact';
        loccon.Role__c =  'Location Contact';
        
        insert loccon;
    }
    @isTest  
    static void getLocationContactTestList() {
        
        List<Location_Contact__c> Continfo = [SELECT id,service_account__c,order__c,role__c,name FROM Location_Contact__c];
   
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped('{"OrderItem":[{"AdditionalLocationInfo":{"SpecialRequirements":"no","SiteAccessHours":"5","RoomSuiteNumber":"2","LocationId":"0011h00000iTl2VAAS","Floor":"2","BuildingNumber":"3767","BTN":"9898989898"},"ServiceAccountId":"'+ Continfo[0].service_account__c+'","Access_ServiceAccountId":"0011h00000iTl2VAAS","LocationDetail":"1480 Santa Monica Boulevard, Santa Monica, CA  90404"}]})');
    
        Map<String, Object> inputMap = new Map<String, Object>{
            'OrderItem' => jsonMap.get('OrderItem'),
            'OrderId' => Continfo[0].order__c
        };
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_GetLocationContact loccontact = new ftr_GetLocationContact();
        
        test.startTest();
        Boolean result = loccontact.invokeMethod('getLocationContact', inputMap, outputMap, options);
        test.stopTest();  
    }
    
    @isTest  
    static void getLocationContactTestMap() {
        List<Location_Contact__c> Continfo = [SELECT id,service_account__c,order__c,role__c,name FROM Location_Contact__c]; 
        
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped('{"OrderItem":{"AdditionalLocationInfo":{"SpecialRequirements":"no","SiteAccessHours":"5","RoomSuiteNumber":"2","LocationId":"0011h00000iTl2VAAS","Floor":"2","BuildingNumber":"3767","BTN":"9898989898"},"ServiceAccountId":"'+ Continfo[0].service_account__c+'","Access_ServiceAccountId":"0011h00000iTl2VAAS","LocationDetail":"1480 Santa Monica Boulevard, Santa Monica, CA  90404"}}');
        Map<String, Object> inputMap = new Map<String, Object>{
            'OrderItem' => jsonMap.get('OrderItem'),
            'OrderId' => Continfo[0].order__c
        };
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_GetLocationContact loccontact = new ftr_GetLocationContact();
        
        test.startTest();
        Boolean result = loccontact.invokeMethod('getLocationContact', inputMap, outputMap, options);
        test.stopTest();   
    }
}