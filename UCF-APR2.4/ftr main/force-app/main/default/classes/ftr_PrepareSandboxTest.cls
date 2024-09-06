/**
 * @description       : This test class covers the following Apex classes:
 *      ftr_PrepareSandbox
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2
**/
@IsTest
public class ftr_PrepareSandboxTest {
	// @testSetup
    // static void setupData() {
    // 	insert new vlocity_cmt__Omniscript__c(Name='Test',vlocity_cmt__IsActive__c=true);
    // 	insert new vlocity_cmt__VlocityAction__c(Name='Test',vlocity_cmt__DisplayLabel__c='Test',vlocity_cmt__IsActive__c=true);
    // }
    
    @IsTest
    static void prepareSandboxTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGitLab());

        Test.testSandboxPostCopyScript(new ftr_PrepareSandbox(), UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
		
        Test.stopTest();
    }
    
}