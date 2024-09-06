public with sharing class SIPSummaryController {

	public Boolean showSpinner { get; set; }
	public List<DataWrapper> allData;
	public String recordId { get; set; }
	public String productCode = 'SIP_TRUNKING_0010';
	// public Map<String, Schema.SObjectField> qliLIFieldMap { get; set; }
	// public Map<String, Schema.SObjectField> product2FieldMap { get; set; }
	public class SIPSummaryControllerException extends Exception {
	}

	public SIPSummaryController() {
		this.showSpinner = true;
		this.recordId = ApexPages.currentPage().getParameters().get('id');
	}

	public void setAllData(List<DataWrapper> lst) {
		this.allData = lst;
	}

	public List<DataWrapper> getAllData() {
		try {
			this.allData = new List<DataWrapper>();
			Map<String, List<ftr_UNI_Location_Details__c>> uniDetailsMap = new Map<String, List<ftr_UNI_Location_Details__c>>();
			Map<String, List<ftr_EVC_Location_Details__c>> evcDetailsMap = new Map<String, List<ftr_EVC_Location_Details__c>>();
			Map<String, List<ftr_DID_Location_Details__c>> didDetailsMap = new Map<String, List<ftr_DID_Location_Details__c>>();

			// get service account map
			List<Account> serviceAccounts = [
				SELECT Id, vlocity_cmt__PremisesId__r.Premise_Detail__c
				FROM Account
				WHERE
					ID IN (
						SELECT vlocity_cmt__ServiceAccountId__c
						FROM OrderItem
						WHERE OrderId = :recordId AND vlocity_cmt__Product2Id__r.ProductCode = :productCode
					)
			];

			// UNI Details
			SObject[] uniDetails = Database.query(
				'SELECT Id, OrderItem__r.vlocity_cmt__ServiceAccountId__c FROM ftr_UNI_Location_Details__c WHERE OrderItem__r.OrderId =:recordId Order by Name'
			);
			for (ftr_UNI_Location_Details__c record : (ftr_UNI_Location_Details__c[]) uniDetails) {
				if (uniDetailsMap.containsKey(record.OrderItem__r.vlocity_cmt__ServiceAccountId__c)) {
					uniDetailsMap.get(record.OrderItem__r.vlocity_cmt__ServiceAccountId__c).add(record);
				} else {
					uniDetailsMap.put(record.OrderItem__r.vlocity_cmt__ServiceAccountId__c, new List<ftr_UNI_Location_Details__c>{ record });
				}
			}

			// // DID Details
			// SObject[] didDetails = Database.query(
			// 	'SELECT Id, ServiceAccountId__c FROM ftr_did_Location_Details__c WHERE OrderId__c =:recordId '
			// );
			// for (ftr_did_Location_Details__c record : (ftr_did_Location_Details__c[]) didDetails) {
			// 	if (didDetailsMap.containsKey(record.ServiceAccountId__c)) {
			// 		didDetailsMap.get(record.ServiceAccountId__c).add(record);
			// 	} else {
			// 		didDetailsMap.put(record.ServiceAccountId__c, new List<ftr_did_Location_Details__c>{ record });
			// 	}
			// }

			// EVC Details
			SObject[] evcDetails = Database.query(
				'SELECT Id, OrderItem__r.vlocity_cmt__ServiceAccountId__c FROM ftr_EVC_Location_Details__c WHERE OrderItem__r.OrderId =:recordId  Order by Name '
			);
			for (ftr_EVC_Location_Details__c record : (ftr_EVC_Location_Details__c[]) evcDetails) {
				if (evcDetailsMap.containsKey(record.OrderItem__r.vlocity_cmt__ServiceAccountId__c)) {
					evcDetailsMap.get(record.OrderItem__r.vlocity_cmt__ServiceAccountId__c).add(record);
				} else {
					evcDetailsMap.put(record.OrderItem__r.vlocity_cmt__ServiceAccountId__c, new List<ftr_EVC_Location_Details__c>{ record });
				}
			}

			// Put data into wrapper for display
			for (Account servAcc : serviceAccounts) {
				this.allData.add(new DataWrapper(servAcc, uniDetailsMap.get(servAcc.Id), evcDetailsMap.get(servAcc.Id)));
			}
		} catch (Exception e) {
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
			throw new SIPSummaryControllerException(e.getMessage());
		} finally {
			this.showSpinner = false;
		}

		// this.allData.sort();

		return this.allData;
	}

	public class DataWrapper {
		public String serviceAccount { get; set; }
		public ftr_UNI_Location_Details__c[] uniDetails { get; set; }
		public ftr_EVC_Location_Details__c[] evcDetails { get; set; }

		public DataWrapper(Account servAcc, ftr_UNI_Location_Details__c[] unis, ftr_EVC_Location_Details__c[] evcs) {
			this.uniDetails = unis;
			this.evcDetails = evcs;
			this.serviceAccount = servAcc.vlocity_cmt__PremisesId__r.Premise_Detail__c;
		}
	}

}