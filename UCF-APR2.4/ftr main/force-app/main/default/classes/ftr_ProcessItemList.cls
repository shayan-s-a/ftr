global with sharing class ftr_ProcessItemList implements vlocity_cmt.VlocityOpenInterface {
	global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
		List<Object> locationList = new List<Object>();

		if (methodName == 'getBlockDetails') {
			system.debug('InputMap' + inputMap);

			String pbeId = (String) inputMap.get('PBEId');
			String orderId = (String) inputMap.get('OrderId');

			if (inputMap.get('location') instanceof List<object>) {
				locationList = (List<Object>) inputMap.get('location');
			} else {
				locationList = new List<Object>{ inputMap.get('location') };
			}

			Set<Id> servAccIds = new Set<Id>();
			for (Object loc : locationList) {
				Map<String, Object> locMap = (Map<String, Object>) loc;
				servAccIds.add((String) locMap.get('Access_ServiceAccountId'));
			}

			Set<Id> servAccsWithUNIs = new Set<Id>();
			for (OrderItem uni : [
				SELECT Id, vlocity_cmt__ServiceAccountId__c
				FROM OrderItem
				WHERE OrderId = :orderId AND vlocity_cmt__ServiceAccountId__c = :servAccIds AND Product2.ProductCode = 'ENT_ETH_UNI_0001'
			]) {
				servAccsWithUNIs.add(uni.vlocity_cmt__ServiceAccountId__c);
			}

			List<Object> itemList = new List<Object>();
			for (Object loc : locationList) {
				Map<String, Object> locMap = (Map<String, Object>) loc;
				String servAccId = (String) locMap.get('Access_ServiceAccountId');

				if (servAccsWithUNIs.contains(servAccId))
					continue;

				Map<String, Object> fieldToUpdateMap = new Map<String, Object>{
					'vlocity_cmt__ItemName__c' => 'A-' + (String) locMap.get('LocationName'),
					'vlocity_cmt__ServiceAccountId__c' => servAccId,
					'Quantity' => 1
				};

				Map<String, Object> itemMap = new Map<String, Object>{ 'fieldsToUpdate' => fieldToUpdateMap, 'itemId' => pbeId };

				itemList.add((Object) itemMap);
			}

			outputMap.put('itemList', itemList);
			System.debug('outputMap..' + outputMap);

			return true;
		}
		return true;
	}
}