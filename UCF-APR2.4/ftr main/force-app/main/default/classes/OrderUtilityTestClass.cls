@isTest
public class OrderUtilityTestClass 
{

    @isTest
    static void testReassignNetworkCOE() 
    
    {
        // Create test data: Users, Account, and Orders - version 2
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User testUser1;
        User testUser2;

       
        System.runAs (thisUser)
        {   
            testUser1 = createTestUser('Test', 'User', 'testuserxyz@example.com', 'userNameglitz@test.com', 'communi1');
            testUser2 = createTestUser('Test1', 'User1', 'testuser1xyz@example.com' , 'userNamecurefit@test.com', 'communi2');
          
             Group testGroup = new Group (
            Name = 'Network Cost Management',
            DeveloperName = 'Network_Cost_Management',
            Type = 'Regular',
            // Email = UserInfo.getUserEmail(),
            DoesSendEmailToMembers = true,
            DoesIncludeBosses = true
        );
        insert testGroup;
        
        // * AND the group has members
        List<GroupMember> groupMembers = new List<GroupMember> {
            new GroupMember(
                GroupId = testGroup.Id,
                UserOrGroupId = UserInfo.getUserId()
            )
        };
        insert groupMembers;

        }
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Stage 1 - Order Entry'));
        Test.startTest();
        user user1 = [select id from user where id =: testUser1.Id];
        user user2 = [select id from user where id =: testUser2.Id];
        Account testAccount = createTestAccount();
        Order testOrder1 = createTestOrder(testAccount.Id, user1.Id, thisUser);
        Service_Order__c  so = new Service_Order__c();
        so.Order_Number__c = '123';
        so.Name = '1234567'; 
        so.Order__c = testOrder1.Id;
        so.RecordTypeId = [select id from RecordType where DeveloperName='M6_Service_Order'].Id;
        so.Item_Spec_Id__c = '1101';
        so.Is_Created_By_Velocity__c = true;
        so.Service_Order_Stage__c = 'Stage 1 - Order Entry';
        insert so; 
               
        Order testOrder2 = updateTestOrder(testOrder1.Id, user2.Id);
		Test.stopTest();
    }

    // Helper method to create a test user
    static User createTestUser(String firstName, String lastName, String email, String userName, String nickName ) 
    {
        // Create and insert a test User
        User testUser = new User(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Username = userName,
            Alias = 'TUser',
            CommunityNickname = nickName,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id, // Set the profile appropriately
            UserRoleId = [SELECT Id FROM UserRole LIMIT 1].Id, // Set the UserRole appropriately
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert testUser;
        return testUser;
    }

    // Helper method to create a test account
    static Account createTestAccount() 
    {
        // Create and insert a test Account
        id recordType = schema.sobjectType.Account.getRecordTypeInfosByName().get('Alternate Channel').getRecordTypeId();
        Account testAccount = new Account(
            Name = 'Test Account',
            Type = 'Prospect',
            RecordTypeId = recordType,
            vlocity_cmt__Status__c = 'Active'
        );
        insert testAccount;
        return testAccount;
    }

    // Helper method to create a test order
    static Order createTestOrder(Id accountId, Id testUser ,  user user) 
    {
        // Create and insert a test Order
        order order = new order();
        order.accountId = accountId;
        order.EffectiveDate = system.today();
        order.Status = 'Draft';
        order.Broadband_Queue_Assignment__c = 'Tests';
        order.CPE_DCS__c = testUser;
        order.Hot_Cut__c =  testUser;
        order.VoIP_Translations__c = testUser;
        order.CPE_COE__c =  testUser;
        order.Broadband_COE__c = testUser;
        order.OwnerId = user.Id;
         order.Order_Stage__c = 'IT Review';
        insert order;
        return order;
    }
    static Order updateTestOrder(Id orderId, Id testUser1)
    {
        order order = new order(Id = orderId);
        order.Broadband_Queue_Assignment__c = 'new Tests';
        order.CPE_DCS__c = testUser1;
        order.Hot_Cut__c = testUser1;
        order.VoIP_Translations__c = testUser1;
        order.CPE_COE__c = testUser1;
        order.Broadband_COE__c = testUser1;
       // order.OwnerId = testGroup;
        order.Order_Stage__c = 'Complete';
        update order;
        return order;
    }
      static testmethod void testIncrement() {
        Test.startTest();
       // OrderUtility.justIncrement();
        Test.stopTest();
    }
}