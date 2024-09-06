/***
 * @description       : Utility class for the partner portal setup
 * @author            : eric.marcondes@ftr.com
 * 
 **/
public with sharing class ftr_PartnerPortalUtilities {
	private static String sbxName = URL.getSalesforceBaseUrl().toExternalForm().substringAfter('ftr--').substringBefore('.');
	public static String accountName = 'Frontier Partner Portal';
	public static String agentName = 'FRONTIER INTERNAL NO PAY';
	public static String userProfileName = 'Frontier Partner Portal User';
	public static String userRoleName = 'FrontierPartnerPortalPartnerUser';
	public static String permissionSetGroupName = 'AgentPortal_CommunityGroup';

	public ftr_PartnerPortalUtilities() {
	}

	public static void createPartnerPortalUser() {
		String firstName = 'Test';
		String lastName = 'Partner User';
		String email = 'laurie.gilgan@ftr.com';
		String phoneNumber = '5551231234';
		createPartnerPortalUser(firstName, lastName, email, phoneNumber);
	}

	public static void createPartnerPortalUser(String firstName, String lastName, String email, String phoneNumber) {
		Account partnerAccount;
		try {
			partnerAccount = [SELECT Id, IsPartner FROM Account WHERE Name = :accountName LIMIT 1];
			if (!partnerAccount.IsPartner) {
				partnerAccount.IsPartner = true;
				update partnerAccount;
			}
		} catch (Exception e) {
			partnerAccount = new Account(Name = accountName, RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId());
			insert partnerAccount;
			partnerAccount.IsPartner = true;
			update partnerAccount;
		}

		Agent__c agent;
		try {
			agent = [SELECT Id, Name FROM Agent__c WHERE Name = :agentName LIMIT 1];
		} catch (Exception e) {
			agent = new Agent__c(
				Name = agentName,
				Partner_ID__c = '701074',
				Agent_Email__c = 'na@na.com',
				Channel_ID__c = 205,
				Partner_Community_Access__c = true
			);
			insert agent;
		}

		Contact portalContact = new Contact(
			FirstName = firstName,
			Lastname = lastName,
			AccountId = partnerAccount.Id,
			Email = email,
			Phone = phoneNumber,
			Department = agent.Name
		);
		insert (portalContact);

		createPartnerPortalUser(portalContact.Id);
	}

	@Future
	private static void createPartnerPortalUser(String contactId) {
		Id profileId = [SELECT Id, Name FROM Profile WHERE Name = :userProfileName LIMIT 1].Id;
		Id roleId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = :userRoleName LIMIT 1].Id;
		Id permissionsetId = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName = :permissionSetGroupName LIMIT 1].Id;

		Contact portalContact = [SELECT FirstName, LastName, Email, Phone, Department FROM Contact WHERE Id = :contactId];

		String uniqueName = (portalContact.FirstName + '.' + portalContact.LastName).replaceAll(' ', '.');

		User portalUser = new User(
			Username = uniqueName + '@ftr.com.' + sbxName,
			ContactId = contactId,
			ProfileId = profileId,
			UserRoleId = roleId,
			Sub_Agent__c = 'N/A',
			Phone = portalContact.Phone,
			CompanyName = portalContact.Department,
			Alias = portalContact.firstName.left(1) + portalContact.lastName.right(4),
			Email = portalContact.Email,
			EmailEncodingKey = 'UTF-8',
			FirstName = portalContact.FirstName,
			LastName = portalContact.LastName,
			CommunityNickname = uniqueName,
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US'
		);
        try {
            insert (portalUser);
    		insert new PermissionSetAssignment(PermissionSetGroupId = permissionsetId, AssigneeId = portalUser.Id);
        } catch (Exception ex) {
            System.debug('An error occurred: ' + ex.getMessage());
            System.debug(ex.getStackTraceString());
        }
	}
}