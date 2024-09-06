/**
 * @description       : This test class covers the following Apex classes:
 *      ftr_OrdersRecordTypePageController
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2
 * 
**/
/*************************************************************************************************
Name        :  ftr_OrdersRecordTypePageControllerTest
Developer   :  RajuM
Description :  Test class for ftr_OrdersRecordTypePageController
**************************************************************************************************/

@istest
public class ftr_OrdersRecordTypePageControllerTest {
    
    static testmethod void OrdersRecordTypePageControllerTest(){
        
        List<Order> ordersList = new List<Order>();
          Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
         
         Id masterRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='Master' LIMIT 1]?.Id;
        
        Account a = new Account();
        a.RecordTypeId=masterRecId; 
        a.name = 'TestAccount';
        a.Phone='2487958700';
        a.ParentId = globalAcc.Id;
        insert a;
        
        Opportunity opp = new Opportunity();
        opp.Name ='TestOppty';
        opp.AccountId=a.id;
        opp.Opportunity_Type__c = 'New';
        opp.Partner_Sales_Stages__c = 'Decision';
        opp.CloseDate= system.today();
        opp.ForecastCategoryName='Commit';
        opp.Campaign__c ='No';
        opp.Lead_Product_List__c = 'Ethernet';
        opp.New_Logo__c ='No';
        opp.RecordTypeId ='012E0000000dgAK';
        opp.StageName='Decision';
        opp.Description__c ='Test for SEER'; 
        opp.Description_of_customer_needs__c = 'Test SEER';
        opp.Service_Address__c = '2120 Cannes Dr,Dallas,TX';
        
        insert opp;    
        
        //List<RecordType> rtList = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SObjectType='Order' AND (NOT DeveloperName LIKE 'UCaaS%') ];//UCaaS New Order
          Id orderRecordTypeId;
          Boolean isRecordTypeAvailable = Schema.sObjectType.Order.getRecordTypeInfosByName().get('Change Order').isAvailable();
          system.debug('isRecordTypeAvailable-->' +isRecordTypeAvailable);
        if(isRecordTypeAvailable == true){
            orderRecordTypeId = Schema.sObjectType.Order.getRecordTypeInfosByName().get('Change Order').getRecordTypeId();
        }else  {
            orderRecordTypeId = Schema.sObjectType.Order.getRecordTypeInfos()[0].getRecordTypeId();
        }
              Order ord = new Order();
        ord.EffectiveDate = system.today();
        ord.Customer_Requested_Date__c = system.today();
        ord.AccountId = a.id;
        ord.OpportunityId = opp.id;
        ord.Product_Type__c = 'EIA';
        ord.Status='Draft';
        ord.Order_Point_of_Contact__c=UserInfo.getUserId();
        ord.RecordTypeId=orderRecordTypeId;
        ord.Circuit__c='Test';
        ord.BillingStreet='1200 TURBINE';
        ord.BillingCity='SANDPOINT';
        ord.BillingState='Idaho';
        ord.BillingPostalCode='83864-7942';
        ord.BillingCountry='United States';
        ord.ShippingCity='SANDPOINT';
        ord.ShippingState='Idaho';
        ord.ShippingStreet='1200 TURBINE';
        ord.ShippingPostalCode='83864-7942';
        ord.ShippingCountry='United States';
        insert ord;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        ftr_OrdersRecordTypePageController testAccPlan = new ftr_OrdersRecordTypePageController(sc);
        
        PageReference pageRef = Page.Order;
        pageRef.getParameters().put('id', String.valueOf(ord.Id));
        Test.setCurrentPage(pageRef); 
        
        testAccPlan.getRecordTypeList();
        testAccPlan.getUCaaSRecordTypeList(); 
        testAccPlan.redirect();
        String order;
        
        ftr_OrdersRecordTypePageController.fetchRecordTypeValues(order);
        ftr_OrdersRecordTypePageController.fetchUCaaSRecordTypeList(order);
        ftr_OrdersRecordTypePageController.fetchCircuitRecordTypeList(order);
        ftr_OrdersRecordTypePageController.fetchVoiceRecordTypeList(order);
        ftr_OrdersRecordTypePageController.getOpportunityData(opp.Id);
        
             
    }

}