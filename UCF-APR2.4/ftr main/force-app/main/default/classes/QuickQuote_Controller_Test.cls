/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@IsTest(seeAllData = true)
public with sharing class QuickQuote_Controller_Test {
    @IsTest
    private static Void init_Test() {
        Opportunity oppFixture = Test_Fixture_Factory.createTestOpportunity();
        SterlingQuote__c testQuote = Test_Fixture_Factory.createTestQuote(oppFixture.Id, '', 'Pending - Finance');
        QuickQuote_Controller controller = new QuickQuote_Controller();
        controller.init(oppFixture.Id);
    }
    
    @IsTest
    private static void getCurrentOpportunity_Test() {
        Opportunity oppFixture = Test_Fixture_Factory.createTestOpportunity();
        Opportunity testOpp = QuickQuote_Controller.getCurrentOpportunity(oppFixture.Id);
        System.assert(testOpp != null, 'getCurrentOpportunity should not have been null');
    }
}