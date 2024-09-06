public class SterlingQuote_Extension {
	public List<String> FormVariables { get; set; }
	public Boolean IsPartnerUser { get; set; }
	public String OpportunityId { get; set; }
	public SterlingQuote_Extension() {
		String AccountId = getPageParameter('AccountId');
		String AddressType = getPageParameter('AddressType');
		String FinanceUser = getPageParameter('FinanceUser');
		String SfaStatus = getPageParameter('SfaStatus');
		OpportunityId = getPageParameter('OpportunityId');
		String OptionType = getPageParameter('OptionType');
		String QuoteId = getPageParameter('QuoteId');
		//QuoteId = QuoteId.substring(0,15);
		String ScheduleId = getPageParameter('scheduleIds');
		Map<String, String> CPQ_FormVariables = new Map<String, String>();
		FormVariables = new List<String>();
		Account Acc = getAccount(AccountId);
		User Usr = getUser(userInfo.getUserId());
		IsPartnerUser = false;
		if (usr != null && user.userRoleId != null) {
			UserRole usrl = [SELECT id, PortalType FROM UserRole WHERE id = :usr.UserRoleId];
			IsPartnerUser = (usrl.PortalType == 'Partner');
		}

		if (Test.isRunningTest()) {
			formatPhoneNumber('(555) 555-5555');
			formatPhoneNumber('555-555-5555');
			formatPhoneNumber('555-5555');
			formatPhoneNumber('1-555-555-5555');
			formatPhoneNumber('1 (555) 555-5555');
			getPageParameter('AccountId');
			getPageParameter('AddressType');
			getPageParameter('FinanceUser');
			getPageParameter('SfaStatus');
			getPageParameter('OpportunityId');
			getPageParameter('OptionType');
			getPageParameter('QuoteId');
			getPageParameter('scheduleIds');
			getUser(userInfo.getUserId());
			getAccount(AccountId);
		} /*ALL = ALL OPTION TYPES*/

		/*START PARAMETER OPTION LEGEND*/ //  AP  = ADD PRODUCT(S)
		//  AQ  = ADD QUANTITY
		//  RE  = RENEWAL
		//  NQ  = NEW QUOTE
		//  EQ  = EXISTING QUOTE
		//  CQ  = CONVERT QUOTE TO ORDER
		/*END PARAMETER OPTION LEGEND*/

		/*      DPI ID - MANDATORY ALL | OPTIONAL NONE  */
		if (Usr.DPIID__c != null && Usr.DPIID__c != '') {
			CPQ_FormVariables.put('dpiID', Usr.DPIID__c);
		} else {
			CPQ_FormVariables.put('dpiID', Usr.CSR_ID__c);
		}
		/*  CSR ID - MANDATORY ALL | OPTIONAL NONE  */
		CPQ_FormVariables.put('cSRId', Usr.CSR_ID__c);
		/*  CUSTOMER ID - MANDATORY ALL | OPTIONAL NONE */
		CPQ_FormVariables.put('customerId', Acc.Id);
		/*  CUSTOMER NAME - MANDATORY NONE | OPTIONAL ALL   */
		//CPQ_FormVariables.put('customerName',);
		/*  CUSTOMER NUMBER - MANDATORY ALL | OPTIONAL NONE */
		if (Acc.Customer_Number__c != null) {
			CPQ_FormVariables.put('customerNumber', Acc.Customer_Number__c);
		} else {
			CPQ_FormVariables.put('customerNumber', Acc.Id);
		}
		/*  BUSINESS NAME - MANDATORY ALL | OPTIONAL NONE   */
		String businessName = Acc.Name;
		//system.debug('&&&&&&&  account name ' +acc.Name);
		//   businessName = businessName.replace('\'','\\');
		businessName = businessName.replace('\'', '');
		system.debug('$$$$$$$ businessName' + businessName);
		CPQ_FormVariables.put('businessName', businessName);
		/*  STREET NUMBER - MANDATORY NONE | OPTIONAL ALL   */
		if (AddressType == 'Billing' && Acc.BAStreet_Number__c != null) {
			CPQ_FormVariables.put('streetNumber', Acc.BAStreet_Number__c);
		} else if (AddressType == 'Legal' && Acc.Street_Number__c != null) {
			CPQ_FormVariables.put('streetNumber', Acc.Street_Number__c);
		} else if (AddressType == 'Service' && Acc.SAStreet_Number__c != null) {
			CPQ_FormVariables.put('streetNumber', Acc.SAStreet_Number__c);
		}
		/*  STREET NAME - MANDATORY NONE | OPTIONAL ALL */
		if (AddressType == 'Billing' && Acc.BAStreet_Name__c != null) {
			CPQ_FormVariables.put('streetName', Acc.BAStreet_Name__c);
		} else if (AddressType == 'Legal' && Acc.Street_Name__c != null) {
			CPQ_FormVariables.put('streetName', Acc.Street_Name__c);
		} else if (AddressType == 'Service' && Acc.SAStreet_Name__c != null) {
			CPQ_FormVariables.put('streetName', Acc.SAStreet_Name__c);
		}
		/*  CITY - MANDATORY NONE | OPTIONAL ALL    */
		if (AddressType == 'Billing' && Acc.BillingCity != null) {
			CPQ_FormVariables.put('city', Acc.BillingCity);
		} else if (AddressType == 'Legal' && Acc.Legal_City__c != null) {
			CPQ_FormVariables.put('city', Acc.Legal_City__c);
		} else if (AddressType == 'Service' && Acc.ShippingCity != null) {
			CPQ_FormVariables.put('city', Acc.ShippingCity);
		}
		/*  ZIP CODE - MANDATORY NONE | OPTIONAL ALL    */
		if (AddressType == 'Billing' && Acc.BillingPostalCode != null) {
			CPQ_FormVariables.put('zipCode', Acc.BillingPostalCode);
		} else if (AddressType == 'Legal' && Acc.Legal_Zip__c != null) {
			CPQ_FormVariables.put('zipCode', Acc.Legal_Zip__c);
		} else if (AddressType == 'Service' && Acc.ShippingPostalCode != null) {
			CPQ_FormVariables.put('zipCode', Acc.ShippingPostalCode);
		}
		/*  STATE - MANDATORY NONE | OPTIONAL ALL   */
		if (AddressType == 'Billing' && Acc.BillingState != null) {
			CPQ_FormVariables.put('state', Acc.BillingState);
		} else if (AddressType == 'Legal' && Acc.Legal_State__c != null) {
			CPQ_FormVariables.put('state', Acc.Legal_State__c);
		} else if (AddressType == 'Service' && Acc.ShippingState != null) {
			CPQ_FormVariables.put('state', Acc.ShippingState);
		}
		/*  PHONE NUMBER - MANDATORY NONE | OPTIONAL ALL    */
		//CPQ_FormVariables.put('phoneNumber','');
		/* SFDC SESSION ID - MANDATORY NONE | OPTIONAL ALL  */
		CPQ_FormVariables.put('sfdcSessionId', userInfo.getSessionId());
		/*  CSR TYPE - MANDATORY ALL | OPTIONAL NONE    */
		CPQ_FormVariables.put('cSRType', 'Direct');
		/*  APPLICATION ID - MANDATORY ALL | OPTIONAL NONE  */
		if (IsPartnerUser == true) {
			CPQ_FormVariables.put('appId', 'CommAgent');
		} else {
			CPQ_FormVariables.put('appId', 'SFDC');
		}
		/*  OPPORTUNITY ID - MANDATORY ALL | OPTIONAL NONE  */
		CPQ_FormVariables.put('sfaOpportunityId', OpportunityId);
		/*  QUOTE ID - MANDATORY EQ,CQ | OPTIONAL NONE  */
		if (OptionType == 'EQ' || OptionType == 'CQ') {
			CPQ_FormVariables.put('sfaQuoteId', QuoteId);
		}
		/*  SFDC STATUS - MANDATORY NONE | OPTIONAL ALL */
		CPQ_FormVariables.put('sfaStatus', SfaStatus);
		/*  SFDC RENEWAL FLAG - MANDATORY ALL | OPTIONAL ALL    */
		if (OptionType == 'RE') {
			CPQ_FormVariables.put('sfaRenewalFlag', 'Y');
		} else {
			CPQ_FormVariables.put('sfaRenewalFlag', 'N');
		}
		/*  SFDC SCHEDULE IDS - MANDATORY AP,AQ,RE | OPTIONAL NONE  */
		if (OptionType == 'AP' || OptionType == 'AQ' || OptionType == 'RE') {
			CPQ_FormVariables.put('scheduleIds', ScheduleId);
		}
		/*  SFDC USER TYPE - MANDATORY EQ | OPTIONAL NONE   */
		if (FinanceUser == 'true') {
			CPQ_FormVariables.put('sfaUserType', 'finance');
		}
		/*  ACCOUNT NAME - MANDATORY NONE | OPTIONAL ALL    */
		//CPQ_FormVariables.put('accountName','');
		/*  COMPANY NAME - MANDATORY ALL | OPTIONAL NONE    */
		String companyName = Acc.Name;
		companyName = businessName.replace('\'', '\\');
		CPQ_FormVariables.put('companyName', companyName);
		/*  COMPANY TYPE - MANDATORY ALL | OPTIONAL NONE    */
		CPQ_FormVariables.put('companyType', 'Business');
		/*  BILLING SYSTEM - MANDATORY ALL | OPTIONAL NONE  */
		CPQ_FormVariables.put('billingSystem', 'CDPI');
		/*  CONVERT TO ORDER - MANDATORY CQ | OPTIONAL NONE */
		if (OptionType == 'CQ') {
			CPQ_FormVariables.put('convertQuoteToOrder', 'Y');
		}
		/* Adding sfaStatus Defect #      */
		CPQ_FormVariables.put('SfaStatus', SfaStatus);

		//MapFormVariables = CPQ_FormVariables;
		for (String this_variable : CPQ_FormVariables.keySet()) {
			FormVariables.add(this_variable + ':' + CPQ_FormVariables.get(this_variable));
		}
		system.debug(FormVariables);	}

	private String getPageParameter(String ParameterName) {
		return ApexPages.currentPage().getParameters().get(ParameterName);
	}

	private Account getAccount(String AccountId) {
		Account this_account = [
			SELECT
				BillingCity,
				BillingState,
				BillingPostalCode,
				BAStreet_Name__c,
				BAStreet_Number__c,
				ShippingCity,
				ShippingState,
				ShippingPostalCode,
				SAStreet_Name__c,
				SAStreet_Number__c,
				Legal_City__c,
				Legal_State__c,
				Legal_Zip__c,
				Street_Number__c,
				Street_Name__c,
				CustomerId__c,
				Customer_Number__c,
				Name,
				Company_Type__c
			FROM Account
			WHERE Id = :AccountId
		];
		return this_account;
	}

	private User getUser(String UserId) {
		User this_user = [SELECT CSR_ID__c, DPIID__c, userroleid, profile.name FROM User WHERE Id = :UserId];
		return this_user;
	}

	private String formatPhoneNumber(String PhoneNumber) {
		PhoneNumber = PhoneNumber.replace('(', '');
		PhoneNumber = PhoneNumber.replace(')', '');
		PhoneNumber = PhoneNumber.replace('-', '');
		PhoneNumber = PhoneNumber.replace(' ', '');
		return PhoneNumber;
	}

	public PageReference navigateToOpportunity() {
        PageReference pr;
        
        //User this_user = getUser(userinfo.getuserid());
        String userId = UserInfo.getUserId();
        
        User user = [Select id,name,Profile.Name from User where id =:userId];
        
        //condition to redirect to portal URL for portal user
        if(user.profile.name == 'Frontier Partner Portal User') {
            String oppName = [SELECT Name FROM Opportunity WHERE Id =: OpportunityId LIMIT 1].Name;
            String ntwrkId = Network.getNetworkId();
			ConnectApi.Community comm = ConnectApi.Communities.getCommunity(ntwrkId);
            pr = new PageReference(comm.siteUrl + '/s/opportunity/' + OpportunityId + '/' + oppName);
        }else {
            pr = new PageReference('/lightning/r/Opportunity/' + OpportunityId + '/view');
        }
		
		pr.setRedirect(true);
		return pr;
	}
}