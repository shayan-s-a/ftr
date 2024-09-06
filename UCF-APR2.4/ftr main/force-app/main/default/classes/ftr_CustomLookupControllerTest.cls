/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@IsTest
public class ftr_CustomLookupControllerTest {
	@TestSetup
	static void makeData() {
		insert ftr_TestDataFactory.getAccounts(3);
		insert new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', Phone = '5555551234');
	}

	@IsTest
	static void searchAccounts() {
		Test.startTest();
		String accId = [SELECT Id FROM Account LIMIT 1].Id;
		ftr_CustomLookupController.search('Account', 'Name', 'Name', accId, null);
		ftr_CustomLookupController.search('Contact', 'Name', 'Name,Email,Phone', 'Test', 'LastName = \'Contact\'');
		Test.stopTest();
	}
}
