/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class ftrNearbyProspectControllerTest {
    
    @TestSetup
    static void makeData(){
        Id serviceRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        Id billingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();

        List<account> accList = ftr_TestDataFactory.getAccounts(4);
        accList[0].Type = 'Prospect';
        accList[0].ShippingLatitude = 10;
        accList[0].ShippingLongitude = 10;
        accList[0].Phone = '0987654321';
        accList[1].Type = 'Prospect';
        accList[1].ShippingLatitude = 10;
        accList[1].ShippingLongitude = 10;
        accList[1].Phone = '1234567890';
        accList[2].recordtypeId = serviceRecordTypeId;
        accList[2].Phone = '1111111111';
        accList[3].Phone = '2222222222';
        accList[3].recordtypeId = billingRecordTypeId;
        insert accList;
		Date today = Date.today();
        insert new List<Neustar_Data__c>{
            new Neustar_Data__c(
                TN__c = '1234567890',
                Port_Date__c = Date.newInstance(today.year()-3, today.month(), today.day())
            ),
            new Neustar_Data__c(
                TN__c = '1111111111',
                Port_Date__c = Date.newInstance(today.year()-3, today.month(), today.day())
            ),
            new Neustar_Data__c(
                TN__c = '2222222222',
                Port_Date__c = Date.newInstance(today.year()-3, today.month(), today.day())
            )
        };
    }

    @isTest
    static void testGettingNearbyProspects() {
        Test.startTest();
        for (account a : [SELECT Id FROM Account WHERE Name LIKE 'TestAccount0' LIMIT 1]) {
            ftrNearbyProspectController.getNearbyProspects(a.Id, '5', 'mi', '5');
        }
        Test.stopTest();
    }
}