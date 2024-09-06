/* Class that returns the shipping addresses for the RC shipping information page*/

global class PicklistPopulation implements vlocity_cmt.VlocityOpenInterface {
    public static Boolean invokeMethod(String methodName, Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options) {
        System.debug('input = ' + input);
		System.debug('outMap = ' + outMap);
        System.debug('options = ' + options);
        if (methodName.equals('PopulatePicklist')) {
            PopulatePicklist(input, outMap, options);
        } else if(methodName.equals('allocatedUpdate')){
            allocatedUpdate(input, outMap, options);
        }
		 else if(methodName.equals('updateAllocatedonDeviceInsert')){
            updateAllocatedonDeviceInsert(input, outMap, options);
        }
		else if(methodName.equals('updateAllocatedonShippingdelete')){
			System.Debug('delete fired');
            updateAllocatedonShippingdelete(input, outMap, options);
        }
        else if(methodName.equals('dualOrderItemForUCFOrder')){
			System.debug('delete fired');
            dualOrderItemForUCFOrder(input, outMap, options);
        }
        else if(methodName.equals('UpdateDualChildOrder')){
			System.debug('delete fired');
            UpdateDualChildOrder(input, outMap, options);
        }
        else if(methodName.equals('createTask')){
			System.debug('createTask fired');
            createTask(input, outMap, options);
        }
        else if(methodName.equals('validateForUCFDC711')){
			System.debug('createTask fired');
            validateForUCFDC711(input, outMap, options);
        }
        return true;
    }
    // Get All Relationship Types for Account when the Omniscript is compiled.
    public static void PopulatePicklist(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options) {
        List < Map < String, String >> UIoptions = new List < Map < String, String >> ();
        for (vlocity_cmt__Premises__c rel: [SELECT Premise_Detail__c, Id, CreatedDate FROM vlocity_cmt__Premises__c ORDER BY CreatedDate DESC]) {
            Map < String, String > tempMap = new Map < String, String > ();
            tempMap.put('name', rel.Id);

            // Language Independent
            tempMap.put('value', rel.Premise_Detail__c);
            // Displayed in Picklist
            UIoptions.add(tempMap);
        }
		System.debug('UIoptions = ' + UIoptions);
        outMap.put('options', UIoptions);
    }
    
    public static void allocatedUpdate(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options){
        
        System.debug(':::: OrderProductId'+(String)input.get('OrderProductId'));
        String OrderProductId = (String)input.get('OrderProductId');
        Decimal totalAmount = 0;
        List<Shipping_Device__c> records = [Select Ship_Count__c , Order_Product__c,Allocated__c,Total_Allocated__c from Shipping_Device__c where Order_Product__c=:OrderProductId];
        System.debug(':::: records'+records);
        List<Shipping_Device__c> updateRecords = new List<Shipping_Device__c>();
        if(!records.isEmpty()){
            
            for(Shipping_Device__c dev: records){
                
                if(dev.Ship_Count__c !=null){
                    //totalAmount += dev.Ship_Count__c;
                    totalAmount = dev.Ship_Count__c;
                }
                
            }
            System.debug(':::: totalAmount'+totalAmount);
            
            for(Shipping_Device__c updateDev: records){
                
                 updateDev.Allocated__c = totalAmount;
                 updateRecords.add(updateDev);
            }
        }
        if(!updateRecords.isEmpty()){
            System.debug(':::: updateRecords'+updateRecords);
            update updateRecords;
        }
    }
public static void updateAllocatedonDeviceInsert(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options){
        
        System.debug(':::: ShippingInfoId'+(String)input.get('ShippingInfoId'));
        String ShippingInfoId = (String)input.get('ShippingInfoId');
        Decimal totalAmount = 0;
        List<Shipping_Device__c> records = [Select Id , Order_Product__c from Shipping_Device__c where Shipping_Information__c =:ShippingInfoId];
        System.debug(':::: records'+records);
        List<Shipping_Device__c> deviceToUpd = new List<Shipping_Device__c>();
        if(!records.isEmpty()){
            
            for(Shipping_Device__c device: records){
                Shipping_Device__c numOfAllocation  = [Select Allocated__c from Shipping_Device__c Where Order_Product__c =: device.Order_Product__c Limit 1];
                if(numOfAllocation!= null){
                    device.Allocated__c = numOfAllocation.Allocated__c;
					deviceToUpd.add(device);
                }
            }
        }
        if(!deviceToUpd.isEmpty()){
            System.debug(':::: Updated device count for devices '+deviceToUpd);
            update deviceToUpd;
        }
    }
public static void updateAllocatedonShippingdelete(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options){
        
        System.debug(':::: ShippingInfoId'+(String)input.get('ShippingInfoId'));
        String ShippingInfoId = (String)input.get('ShippingInfoId');
        Decimal totalAmount = 0;
        List<Shipping_Device__c> records = [Select Id , Order_Product__c,Remaining__c,Allocated__c,Ship_Count__c from Shipping_Device__c where Shipping_Information__c =:ShippingInfoId];
        System.debug(':::: records to delete'+records);
        List<Shipping_Device__c> deviceToUpd = new List<Shipping_Device__c>();
		Map<Id,Shipping_Device__c> mapdevices = new Map<Id,Shipping_Device__c>();
    	List<Id> lstOrderProductIds  = new List<Id>();
        if(!records.isEmpty()){
            for(Shipping_Device__c device: records){
               	mapdevices.put(device.Order_Product__c,device);
                }
            }
			Set<Id> prodIds = mapdevices.keySet();		
        	// Perform the SOQL query using the IN operator with the Set of IDs
        	List<Shipping_Device__c> recsToUpd = [SELECT  Id ,Allocated__c, Order_Product__c,Remaining__c from Shipping_Device__c where Order_Product__c IN :prodIds];
    		System.Debug('recsToUpd with count after delete = ' + recsToUpd);
			if(!recsToUpd.isEmpty()){
				for(Shipping_Device__c shipdevice: recsToUpd){
					if(mapdevices.get(shipdevice.Order_Product__c).Ship_Count__c != null && mapdevices.get(shipdevice.Order_Product__c).Ship_Count__c != 0 ){
                        shipdevice.Allocated__c = shipdevice.Allocated__c - mapdevices.get(shipdevice.Order_Product__c).Ship_Count__c;
                        deviceToUpd.add(shipdevice);
                    }
    	        }
                System.Debug('deviceToUpd list = '+ deviceToUpd);
            }
			boolean flag = deviceToUpd.isEmpty();
			System.Debug('flag = ' + flag);
            if(!deviceToUpd.isEmpty()){
                System.debug(':::: Updated device count for devices '+ deviceToUpd);
                update deviceToUpd;
            }
    }
    
    public static void dualOrderItemForUCFOrder(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options){
        
        System.debug(':::: ucfOldOrderId'+(String)input.get('ucfOldOrderId'));
        System.debug(':::: ucfNewOrderId'+(String)input.get('ucfNewOrderId'));
        String ucfOldOrderId = (String)input.get('ucfOldOrderId');
        String ucfNewOrderId = (String)input.get('ucfNewOrderId');
        
        if(ucfOldOrderId !=null){
             List<OrderItem> ucfLineItems = new List<OrderItem>();
             Map<Id, List<OrderItem>> parentOrderLineItemsMap = new Map<Id, List<OrderItem>>();
             List<OrderItem> ucfNewOrderItems = new List<OrderItem>();
             List<OrderItem> ucfInsertNewOrderItems = new List<OrderItem>();
            
             for (OrderItem item : [SELECT Id, Product_Type__c, OrderId,BaseOneTimeCharge__c,BaseRecurringCharge__c,Description,
                          ftr_PromoCode__c,ftr_PSR_HBE_Eligible__c,PriceBookEntryId,Product2Id,Quantity,SNE_Code_MRC__c,
                          SNE_Code_OTC__c, SNE_Code_TERM__c,Speed__c,UnitPrice,vlocity_cmt__Action__c,vlocity_cmt__AssetId__c,vlocity_cmt__BillingAccountId__c,
                          vlocity_cmt__CpqMessageData__c,vlocity_cmt__EffectiveOneTimeTotal__c,vlocity_cmt__EffectiveQuantity__c,
                          vlocity_cmt__EffectiveRecurringTotal__c,vlocity_cmt__ItemName__c,vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c,
                          vlocity_cmt__OneTimeCalculatedPrice__c,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__PremisesId__c,
                          vlocity_cmt__PricingLogData__c,vlocity_cmt__Product2Id__c,
                          vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringTotal__c,vlocity_cmt__SequenceNumber__c,
                          vlocity_cmt__SerialNumber__c,vlocity_cmt__ServiceAccountId__c
                           FROM OrderItem WHERE OrderId =:ucfOldOrderId]) {
            if (item.Product_Type__c == 'None') {
            
                   ucfNewOrderItems.add(item);
             
            }
           }
           if(!ucfNewOrderItems.isEmpty()){

     System.debug(':::::::: ucfNewOrderItems'+ucfNewOrderItems.size());
       
       for(OrderItem newItem: ucfNewOrderItems){

            OrderItem abc = new OrderItem();
            abc.OrderId   = ucfNewOrderId;
            abc.SNE_Code_OTC__c = newItem.SNE_Code_OTC__c;
            abc.BaseOneTimeCharge__c = newItem.BaseOneTimeCharge__c;
            abc.BaseRecurringCharge__c = newItem.BaseRecurringCharge__c;
            abc.Description = newItem.Description;
            abc.ftr_PromoCode__c = newItem.ftr_PromoCode__c;
            abc.ftr_PSR_HBE_Eligible__c = newItem.ftr_PSR_HBE_Eligible__c;
            abc.PriceBookEntryId = newItem.PriceBookEntryId;
            abc.Product2Id = newItem.Product2Id;
            abc.SNE_Code_MRC__c = newItem.SNE_Code_MRC__c;
            abc.SNE_Code_TERM__c = newItem.SNE_Code_TERM__c;
            abc.Speed__c = newItem.Speed__c;
            abc.Quantity = newItem.Quantity;
            abc.UnitPrice = newItem.UnitPrice;
            abc.vlocity_cmt__Action__c = newItem.vlocity_cmt__Action__c;
            abc.vlocity_cmt__AssetId__c = newItem.vlocity_cmt__AssetId__c;
            abc.vlocity_cmt__BillingAccountId__c = newItem.vlocity_cmt__BillingAccountId__c;
            abc.vlocity_cmt__CpqMessageData__c = newItem.vlocity_cmt__CpqMessageData__c;
            abc.vlocity_cmt__EffectiveOneTimeTotal__c = newItem.vlocity_cmt__EffectiveOneTimeTotal__c;
            abc.vlocity_cmt__EffectiveQuantity__c = newItem.vlocity_cmt__EffectiveQuantity__c;
            abc.vlocity_cmt__EffectiveRecurringTotal__c = newItem.vlocity_cmt__EffectiveRecurringTotal__c;
            abc.vlocity_cmt__ItemName__c = newItem.vlocity_cmt__ItemName__c;
            abc.vlocity_cmt__JSONAttribute__c = newItem.vlocity_cmt__JSONAttribute__c;
            abc.vlocity_cmt__OneTimeCalculatedPrice__c = newItem.vlocity_cmt__OneTimeCalculatedPrice__c;
            abc.vlocity_cmt__OneTimeCharge__c = newItem.vlocity_cmt__OneTimeCharge__c;
            abc.vlocity_cmt__OneTimeTotal__c = newItem.vlocity_cmt__OneTimeTotal__c;
            abc.vlocity_cmt__PremisesId__c = newItem.vlocity_cmt__PremisesId__c;
            abc.vlocity_cmt__LineNumber__c = newItem.vlocity_cmt__LineNumber__c;
            abc.vlocity_cmt__PricingLogData__c = newItem.vlocity_cmt__PricingLogData__c;
            abc.vlocity_cmt__Product2Id__c = newItem.vlocity_cmt__Product2Id__c;
            abc.vlocity_cmt__RecurringCharge__c = newItem.vlocity_cmt__RecurringCharge__c;
            abc.vlocity_cmt__RecurringTotal__c = newItem.vlocity_cmt__RecurringTotal__c;
            abc.vlocity_cmt__SequenceNumber__c = newItem.vlocity_cmt__SequenceNumber__c;
            abc.vlocity_cmt__SerialNumber__c = newItem.vlocity_cmt__SerialNumber__c;
            abc.vlocity_cmt__ServiceAccountId__c = newItem.vlocity_cmt__ServiceAccountId__c;

          ucfInsertNewOrderItems.add(abc);

       }
      
      if(!ucfInsertNewOrderItems.isEmpty()){

         insert ucfInsertNewOrderItems;
         delete ucfNewOrderItems;
      }
   } 
        }
        
    }
    
    public static void UpdateDualChildOrder(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options){
        
        System.debug(':::: ucfOldOrderId'+(String)input.get('parentOrderId'));
        String parentOrderId = (String)input.get('parentOrderId');
        String childRecordId;
        List<Order> childOrderRecordUpdate = new List<Order>();
        Map<String,Id> contractIdMap = new Map<String,Id>();
        List<Location_Contact__c> insertForDualOrder = new List<Location_Contact__c>();
        Order parentOrderRecord = [Select Id,Technical_Contact__c,vlocity_cmt__QuoteId__c, vlocity_cmt__BillingName__c,BillToContactId,Order_Contact__c,Customer_Requested_Date__c, TTL__c,Partner_ID__c, Federal_Tax_ID__c,Federal_Account__c,Selling_Representative_Name__c,Selling_Representative_Email__c,Sales_Contact_Number__c,Contract_Schedule__c  from Order where Id=:parentOrderId];
        List<Contract> contractList =[Select Id,Agreement_Type__c,Schedule_Type__c from Contract where vlocity_cmt__QuoteId__c=:parentOrderRecord.vlocity_cmt__QuoteId__c];
        List<Location_Contact__c> locContact = [Select Id,Service_Account__c,Order__c,Role__c,Contact__c from Location_Contact__c where Order__c =:parentOrderId];
        List<Order> childOrderRecord = [Select Id,Technical_Contact__c, BillToContactId,
                                        vlocity_cmt__BillingName__c,Order_Contact__c,ContractId,
                                        Customer_Requested_Date__c, TTL__c,Partner_ID__c,
                                        Federal_Tax_ID__c,Federal_Account__c,Selling_Representative_Name__c,Products__c,
                                        Selling_Representative_Email__c,Sales_Contact_Number__c,Contract_Schedule__c 
                                        from Order where Parent_Order__c=:parentOrderId];
        System.debug('contractList'+contractList.size());
        for(Contract cont: contractList){
            
            if(cont.Schedule_Type__c =='DIA'){
                contractIdMap.put('DIA',cont.Id);
            }else if(cont.Schedule_Type__c =='UCF - UCaaS'){
                contractIdMap.put('UCFUCaaS',cont.Id);
            }else if(cont.Schedule_Type__c == 'Managed Network Services'){
                contractIdMap.put('ManagedNetworkServices',cont.Id);
            }else if(cont.Schedule_Type__c =='ELINE – EVPL – EPL'){
                contractIdMap.put('EVPL',cont.Id);
             }
        }
        
        if(!childOrderRecord.isEmpty()){
            childRecordId = childOrderRecord[0].Id;
            System.debug('contractIdMap 12'+contractIdMap);
        for(Order childRecordProcess: childOrderRecord){
            System.debug('childRecordProcess Products__c'+childRecordProcess.Products__c);
            childRecordProcess.Technical_Contact__c = parentOrderRecord.Technical_Contact__c;
            childRecordProcess.vlocity_cmt__BillingName__c = parentOrderRecord.vlocity_cmt__BillingName__c;
            childRecordProcess.Order_Contact__c = parentOrderRecord.Order_Contact__c;
            childRecordProcess.Customer_Requested_Date__c = parentOrderRecord.Customer_Requested_Date__c;
            childRecordProcess.TTL__c = parentOrderRecord.TTL__c;
            childRecordProcess.Partner_ID__c = parentOrderRecord.Partner_ID__c;
            childRecordProcess.Federal_Tax_ID__c = parentOrderRecord.Federal_Tax_ID__c;
            childRecordProcess.Federal_Account__c = parentOrderRecord.Federal_Account__c;
            childRecordProcess.Sales_Contact_Number__c = parentOrderRecord.Sales_Contact_Number__c;
            childRecordProcess.Selling_Representative_Email__c = parentOrderRecord.Selling_Representative_Email__c;
            childRecordProcess.Selling_Representative_Name__c = parentOrderRecord.Selling_Representative_Name__c;
            ChildRecordProcess.BillToContactId = parentOrderRecord.BillToContactId;
            /*if(ChildRecordProcess.Products__c.contains('EIA') || ChildRecordProcess.Products__c.contains('EVPL') || ChildRecordProcess.Products__c.contains('MNS')){
                ChildRecordProcess.ContractId = contractIdMap.get('DIA');
            }
            else if(ChildRecordProcess.Products__c.contains('MNS')){
                System.debug('ManagedNetworkServices '+contractIdMap.get('ManagedNetworkServices'));
                ChildRecordProcess.ContractId = contractIdMap.get('ManagedNetworkServices');
            }
            else if(ChildRecordProcess.Products__c.contains('EVPL')){
               ChildRecordProcess.ContractId = contractIdMap.get('EVPL');
            }  */
            
            if(!String.isBlank(childRecordProcess.Products__c)){
                
                  System.debug('childRecordProcess 122'+childRecordProcess.Products__c);
                if(childRecordProcess.Products__c.contains('MNS') && !ChildRecordProcess.Products__c.contains('EIA') && !ChildRecordProcess.Products__c.contains('EVPL')){
                    System.debug('childRecordProcess 123');
                    ChildRecordProcess.ContractId = contractIdMap.get('ManagedNetworkServices');
                }
                else if(childRecordProcess.Products__c.contains('EIA')){
                    
                    ChildRecordProcess.ContractId = contractIdMap.get('DIA');
                }
                else if(ChildRecordProcess.Products__c.contains('EVPL') && !ChildRecordProcess.Products__c.contains('EIA') && !ChildRecordProcess.Products__c.contains('MNS')){
                    
                      ChildRecordProcess.ContractId = contractIdMap.get('EVPL');
                    
                }else if(childRecordProcess.Products__c.contains('MNS') && ChildRecordProcess.Products__c.contains('EIA') && ChildRecordProcess.Products__c.contains('EVPL')){
                     
                    ChildRecordProcess.ContractId = contractIdMap.get('DIA'); 
                }
            }
            
            childOrderRecordUpdate.add(childRecordProcess);
        }
        System.debug('contractIdMap'+contractIdMap);
        if(!childOrderRecordUpdate.isEmpty()){
            parentOrderRecord.ContractId = contractIdMap.get('UCFUCaaS');
            update childOrderRecordUpdate;
            update parentOrderRecord;
        }
         if(!locContact.isEmpty()){
                
            List<Location_Contact__c> locContactChild = [Select Id,Service_Account__c,Order__c,Role__c,Contact__c from Location_Contact__c where Order__c =:childRecordId];
             
             if(!locContactChild.isEmpty()){
                delete locContactChild;
             }
             
             for(Location_Contact__c dualLocCon: locContact){
                 
                
                     Location_Contact__c dualOrderSingleLoc = new Location_Contact__c();
                     dualOrderSingleLoc.Service_Account__c = dualLocCon.Service_Account__c;
                     dualOrderSingleLoc.Order__c = childRecordId;
                     dualOrderSingleLoc.Role__c = dualLocCon.Role__c;
                     dualOrderSingleLoc.Contact__c = dualLocCon.Contact__c;
                     insertForDualOrder.add(dualOrderSingleLoc);
                
                
             }
             
             if(!insertForDualOrder.isEmpty()){
                 insert insertForDualOrder;
             }
         }
     }
    }
    
     public static void createTask(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options){
        System.Debug('Create Task from Picklist Population Executed');
        String ordRecordId = (String)input.get('ordRecordId');
        List<String> phoneNumberListNumberUse = new List<String>();
        List<String> phoneNumberListInstallType = new List<String>();
        List<String> lsthotCutDates = new List<String>();
        String phoneNumbersNumberUse;
        String phoneNumbersInstallType;
        for (ftr_DID_Number_Details__c result1 : [SELECT DIDNumber__c,DID_Number__c,DIDLocationDetailsId__r.OrderId__c,Ucf_Number_Use__c FROM ftr_DID_Number_Details__c WHERE Ucf_Number_Use__c = 'Contact Center as a Service' AND DIDLocationDetailsId__r.OrderId__c = : ordRecordId]) {
            if (result1.DIDNumber__c != null) {
                 phoneNumberListNumberUse.add(result1.DID_Number__c);
             }
            
        }
         
         for (ftr_DID_Number_Details__c result2 : [SELECT DIDNumber__c,DID_Number__c,DIDLocationDetailsId__r.OrderId__c,Ucf_Install_Type__c FROM ftr_DID_Number_Details__c WHERE Ucf_Install_Type__c IN ('Winback', 'Existing # (Regrade)') AND DIDLocationDetailsId__r.OrderId__c = :ordRecordId]) {
            if (result2.DIDNumber__c != null) {
                 phoneNumberListInstallType.add(result2.DID_Number__c);
             }
            
        }
         system.debug('numberuse'+ phoneNumberListNumberUse);
         system.debug('installtype'+ phoneNumberListInstallType);
         for (ftr_DID_Location_Details__c  hotcutdates : [Select DueDate__c   From ftr_DID_Location_Details__c Where OrderId__c = :ordRecordId]) {
            if (hotcutdates.DueDate__c  != null) {
                datetime StartDate= Date.Valueof(hotcutdates.get('DueDate__c'));  
                String strStartDate = StartDate.formatGMT('MM/dd/YYYY');
                lsthotCutDates.add(strStartDate);
             }
            
        }
         if(!phoneNumberListNumberUse.isEmpty()){
         	 phoneNumbersNumberUse = String.join(phoneNumberListNumberUse, ', ');
         }
         if(!phoneNumberListInstallType.isEmpty()){
          	 phoneNumbersInstallType = String.join(phoneNumberListInstallType, ', ');
         }
         
         system.debug('numberuse'+ phoneNumberListNumberUse);
         system.debug('installtype'+ phoneNumberListInstallType);
        Group grp = [Select Id from Group where Type = 'Queue' AND DeveloperName  ='Network_COE_UCaas'];
         
        if(!String.isBlank(phoneNumbersNumberUse)){              		
            Task task = new Task();
            task.Subject = 'Create Manual Task(s) for Contact as a Service numbers';
            task.Description = 'BPO need to create manual order on DPI system for the following phone numbers : '+phoneNumbersNumberUse+ ' Possible due dates: ' +lsthotCutDates ;
            task.OwnerId = grp.Id;
            task.Priority = 'High';
            task.WhatId = ordRecordId;
            task.Status ='In Progress';
            task.ActivityDate = Date.Today() + 2;
            insert task;
            
        }
        
         
         if(!String.isBlank(phoneNumbersInstallType)){              		
            Task task = new Task();
            task.Subject = 'Create Manual Task(s) for Winback or Regrade Intall Types';
            task.Description = 'BPO need to create manual order on DPI system for the following install type(s) : '+phoneNumbersInstallType + ' Possible due dates: ' +lsthotCutDates ;
            task.OwnerId = grp.Id;
            task.Priority = 'High';
            task.WhatId = ordRecordId;
            task.Status ='In Progress';
            task.ActivityDate = Date.Today() + 2;
            insert task;
            
        }
        
    }

    
    
    public static void resetPlanOfLeadAfterMDN(List<Order> newOrderList, Map<Id, Order> oldOrderList){
        
        
        List<Order> ordersToReassign = new List<Order>();
        List<Id> orderAccountIdList = new List<Id>();
        List<Id> orderIdList = new List<Id>();
        
        //loop through all the incoming orders and store the ones relevant to this method
        for(Order newOrder : newOrderList) {
            Order oldOrder = (Order) oldOrderList.get(newOrder.Id);
            
            if(oldOrder.MDN_Orders_Created__c == false || newOrder.MDN_Orders_Created__c == true) {
                  updateFRL(newOrder);
            }
        }
    }
    
    public static void updateFRL(Order newOrder){
        
        DIDTypeSettings__c DPISettings = DIDTypeSettings__c.getInstance();
        Map<Id,vlocity_cmt__FulfilmentRequestLine__c> frlsToUpdateMap = new Map<Id,vlocity_cmt__FulfilmentRequestLine__c>();
        
        Set<Id> frlIds = new Set<Id>();
        List<vlocity_cmt__OrchestrationItem__c> oiList = [Select Id,vlocity_cmt__FulfilmentRequestLineId__c from vlocity_cmt__OrchestrationItem__c where vlocity_cmt__OrchestrationPlanId__c =:newOrder.vlocity_cmt__OrchestrationPlanId__c AND Name =:DPISettings.LeadPlanItemName__c];
        
        if(!oiList.isEmpty()){
            for(vlocity_cmt__OrchestrationItem__c oi:oiList){
                
                frlIds.add(oi.vlocity_cmt__FulfilmentRequestLineId__c);
            }   
        }
        
        if(!frlIds.isEmpty()){
            
             List<vlocity_cmt__FulfilmentRequestLine__c> frls = [SELECT Id, vlocity_cmt__JSONAttribute__c, vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__OrderId__r.OrderNumber, vlocity_cmt__Product2Id__r.Name
                                                                FROM vlocity_cmt__FulfilmentRequestLine__c
                                                                WHERE Id=:frlIds];
            if(!frls.isEmpty()){
                
                Map<String, Object> attrVals = new Map<String, Object>{
                  'ATTR_WaitSemaphore' => 'True'   
               };
                
                
                for(vlocity_cmt__FulfilmentRequestLine__c frl:frls){
                    
                     frl.vlocity_cmt__JSONAttribute__c = (String)ftr_CpqHelper.setJSONAttributes(frl.vlocity_cmt__JSONAttribute__c, '{}', attrVals);
                     frlsToUpdateMap.put(frl.Id,frl);
                }
            }
        }
        if(frlsToUpdateMap.values().size()>0){
            try{
                List<Database.SaveResult> results = Database.update(frlsToUpdateMap.values(), false);
                
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){
                            System.debug('XOMAutoTask_InitiateBulkOrder: Error while updating Attr_WaitBulk: '+ err.getStatusCode() + ' ' + err.getMessage());
                        }
                      
                    }
                }
            } catch(Exception e) {
                System.debug('Exception in ftr_OrderManagementService..'+ e.getMessage());
               
            }
    }
    }
    
    public static void validateForUCFDC711(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options){
        
        System.debug('input'+input);
        
         String OrderId = (String)input.get('OrderId');
         String serviceAccountId = (String)input.get('serviceAccountId');
        // String didLocId = (String)input.get('didLocId');
        
      //  System.debug('didLocId'+didLocId);
        System.debug('serviceAccountId'+serviceAccountId);
        if(serviceAccountId.startsWith('(') && serviceAccountId.endsWith(')')){
        
        List<String> serviceAccountIdList = serviceAccountId.substring(1, serviceAccountId.length() - 1).split(',');
       // List<String> didLocIdList = didLocId.substring(1, didLocId.length() - 1).split(',');
        Set<String> serviceAccountIdSet = new Set<String>();
       // Set<String> didLocSet = new Set<String>();
        
        // Add each ID to the set
        for (String id : serviceAccountIdList) {
            serviceAccountIdSet.add(id);
        }
        
       // for (String id : didLocIdList) {
       //     didLocSet.add(id);
       // }
        
        System.debug('serviceAccountIdSet'+serviceAccountIdSet);
      //  System.debug('didLocSet'+didLocSet);
        System.debug('OrderId'+OrderId);
        
        
         List<OrderItem> oiList = [Select Id from OrderItem where vlocity_cmt__ServiceAccountId__c IN: serviceAccountIdSet  AND OrderId=:OrderId And vlocity_cmt__Product2Id__r.ProductCode ='UCF_DC_711'];
         System.debug('oiList'+oiList); 
        if(!oiList.isEmpty()){
            
            outMap.put('result','Success');
             
         }else{
             
              outMap.put('result','Failed');
         }
        
        
        System.debug('serviceAccountId'+serviceAccountId);
        }else{
            
            List<OrderItem> oiList = [Select Id from OrderItem where vlocity_cmt__ServiceAccountId__c =: serviceAccountId  AND OrderId=:OrderId And vlocity_cmt__Product2Id__r.ProductCode ='UCF_DC_711'];
         System.debug('oiList'+oiList); 
        if(!oiList.isEmpty()){
            
            outMap.put('result','Success');
             
         }else{
             
              outMap.put('result','Failed');
         }
        
        
        System.debug('serviceAccountId'+serviceAccountId);
        }
    }
}