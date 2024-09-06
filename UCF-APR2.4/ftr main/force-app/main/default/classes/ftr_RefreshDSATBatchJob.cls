global class ftr_RefreshDSATBatchJob implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	global Integer recordsProcessed = 0;

	global List<Account> start(Database.BatchableContext bc) {
		// get the service accounts associated to those premises
		return [
			SELECT Name, ShippingPostalCode, ShippingState, ShippingCity, ShippingStreet, ParentId, vlocity_cmt__PremisesId__c
			FROM Account
			WHERE RecordType.Name = 'Service' AND vlocity_cmt__PremisesId__c != NULL AND vlocity_cmt__PremisesId__r.vlocity_cmt__floor__c != 'Updated'
			LIMIT 10000
		];
	}

	global void execute(Database.BatchableContext bc, List<Account> accList) {
		List<Id> parents = new List<Id>();
		for (account a : accList) {
			parents.add(a.parentId);
		}

		List<Opportunity> opps = [SELECT id, accountid FROM Opportunity WHERE AccountId IN :parents];

		for (Account acc : accList) {
			recordsProcessed++;
			// build input
			Map<string, object> input = new Map<string, object>{
				'AQRecordId' => 0,
				'OpportunityId' => '',
				'Address' => acc.ShippingStreet,
				'City' => acc.ShippingCity,
				'State' => acc.ShippingState,
				'ZipCode' => acc.ShippingPostalCode,
				'BusinessName' => acc.Name,
				'ParentAccountId' => acc.ParentId,
				'ContextId' => getOppty(opps, acc.parentId),
				'PremisesId' => acc.vlocity_cmt__PremisesId__c
			};
			Map<string, object> output = new Map<string, object>();
			Map<string, object> options = new Map<string, object>();
			RefreshDSATClass obj = new RefreshDSATClass();

			// make callout
			obj.invokeMethod('getRefreshAPIDetails', input, output, options);

			// check if it was successful
			Map<String, object> tempMap = (Map<string, object>) output.get('IPResult');
			if (tempMap.get('ServiceAccounts') != null && tempMap.get('ServiceAccounts') != '') {
				update new vlocity_cmt__Premises__c(Id = acc.vlocity_cmt__PremisesId__c, vlocity_cmt__Floor__c = 'Updated');
			} else {
				update new vlocity_cmt__Premises__c(Id = acc.vlocity_cmt__PremisesId__c, vlocity_cmt__Floor__c = 'Did not update');
			}
		}
	}

	global void finish(Database.BatchableContext bc) {
		System.debug(recordsProcessed + ' records updated!');

		try {
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.toAddresses = Label.vlocity_batch_job_distro.split(';');
			message.setSenderDisplayName('Salesforce Batch Job Results');
			message.subject = 'DSAT Refresh Batch Job';
			message.plaintextbody = 'DSAT Refresh batch job successfully processed ' + recordsProcessed + ' record(s).';
			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

			if (results[0].success) {
				System.debug('The email was sent successfully.');
			} else {
				System.debug('The email failed to send: ' + results[0].errors[0].message);
			}
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
	}

	private Id getOppty(List<Opportunity> opps, Id accId) {
		Id optyId;
		for (Opportunity o : opps) {
			if (o.accountId == accId) {
				optyId = o.Id;
				break;
			}
		}
		return optyId;
	}
}