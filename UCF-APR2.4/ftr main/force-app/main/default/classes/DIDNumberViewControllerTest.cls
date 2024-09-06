/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class DIDNumberViewControllerTest {
    @TestSetup
    static void makeData(){
        Order[] o = ftr_TestDataFactory.getOrders(1);
        Account[] servAccs = ftr_TestDataFactory.getServAccountsWithPremise(1);
        update servAccs;
        insert o;
        OrderItem[] oi = ftr_TestDataFactory.getOrderItems(1, new Map<String,String>{
            'SIP_TRUNKING_0010' => 'SIP_TRUNKING_0010'
        });
        oi[0].OrderId = o[0].Id;
        oi[0].vlocity_cmt__ServiceAccountId__c = servAccs[0].Id;
        insert oi;
        
        ftr_DID_Location_Details__c did = new ftr_DID_Location_Details__c(
            OrderId__c=o[0].Id,
            BTN__c='1234567890'
        );
        insert did;

        ftr_DID_Number_Details__c num = new ftr_DID_Number_Details__c(
            DID_Number__c='1234567890',
            DIDLocationDetailsId__c=did.Id
        );
        insert num;
    }

    @IsTest
    static void methodName(){
        
        Test.startTest();
        DIDNumberViewController ctrl = new DIDNumberViewController();
        ctrl.didLocationId = [SELECT Id FROM ftr_DID_Location_Details__c LIMIT 1].Id;
        ctrl.getDIDLocationDetails();
        ctrl.getDIDNumbers();
        ctrl.getAllDIDNumbers();
        ctrl.getX911Options();
        ctrl.nextNumber();
        ctrl.previousNumber();
        ctrl.generateCSV();
        ctrl.generateUcfCSV();
        Test.stopTest();
        
    }
}