global without sharing class ftr_AssociateUNIAssets implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {
	global void executeBatch(List<vlocity_cmt__OrchestrationItem__c> items) {
		ftr_Logger.writeInfo('Enter ftr_AssociateUNIAssets.executeBatch');
		ftr_Logger.writeInfo('items: ' + JSON.serialize(items));
		try {
			Map<Id, vlocity_cmt__OrchestrationItem__c> itemsMap = new Map<Id, vlocity_cmt__OrchestrationItem__c>(items);
			Set<Id> orderIds = new Set<Id>();
			for (vlocity_cmt__OrchestrationItem__c item : [
				SELECT vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c
				FROM vlocity_cmt__OrchestrationItem__c
				WHERE Id = :itemsMap.keySet()
			]) {
				orderIds.add(item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c);
			}
			executeBatch(orderIds);
		} catch (Exception ex) {
			ftr_Logger.write(ex);
			throw ex;
		} finally {
			ftr_Logger.writeInfo('Exit ftr_AssociateUNIAssets.executeBatch');
		}
	}
	//version1
	/**
	 * @description - will associate all assets to their UNIs by order Id. Must be associated to an Order Item
	 * @param Set<Id> orderIds - order Ids to run association
	 **/
	global void executeBatch(Id orderId) {
		Set<Id> orderIds = new Set<Id>{orderId};
        executeBatch(orderIds);
	}

	/**
	 * @description - will associate all assets to their UNIs by order Id. Must be associated to an Order Item
	 * @param Set<Id> orderIds - order Ids to run association
	 **/
	global void executeBatch(Set<Id> orderIds) {
        // create a map of UNI Order Item Ids to Asset record
		Map<Id, Asset> uniOrderItemIdMap = new Map<Id, Asset>();
		for (Asset uni : [
			SELECT Id, vlocity_cmt__OrderProductId__c
			FROM Asset
			WHERE Product2.ProductCode = :ftr_CpqService.ProductCode_UNI AND vlocity_cmt__OrderProductId__r.OrderId = :orderIds
		]) {
			uniOrderItemIdMap.put(uni.vlocity_cmt__OrderProductId__c, uni);
		}

        // get all assets that have their order items UNI_Host__c or UNI_Remote__c fields populated
		Asset[] assets = [
			SELECT Id, UNI_Host__c, UNI_Remote__c, vlocity_cmt__OrderProductId__r.UNI_Host__c, vlocity_cmt__OrderProductId__r.UNI_Remote__c
			FROM Asset
			WHERE
				vlocity_cmt__OrderProductId__r.OrderId = :orderIds
				AND (asset.vlocity_cmt__OrderProductId__r.UNI_Host__c != NULL
				OR asset.vlocity_cmt__OrderProductId__r.UNI_Remote__c != NULL)
		];
		for (Asset asset : assets) {
			if (asset.vlocity_cmt__OrderProductId__r.UNI_Host__c != null && uniOrderItemIdMap.get(asset.vlocity_cmt__OrderProductId__r.UNI_Host__c) != null)
				asset.UNI_Host__c = uniOrderItemIdMap.get(asset.vlocity_cmt__OrderProductId__r.UNI_Host__c).Id;

			if (asset.vlocity_cmt__OrderProductId__r.UNI_Remote__c != null && uniOrderItemIdMap.get(asset.vlocity_cmt__OrderProductId__r.UNI_Remote__c) != null)
				asset.UNI_Remote__c = uniOrderItemIdMap.get(asset.vlocity_cmt__OrderProductId__r.UNI_Remote__c).Id;
		}
		update assets;
	}
}