public class ServiceOrderCtrl {
    
    public final static Set<String> productCode = new Set<String>{
        '1101','1102','1103','1180','1181','1220','1221','1242','1260','1284','1300','1380','1440','1460','1480','1481','1500','1501','1541'
    };
	
    @AuraEnabled
    public static data returnServiceOrders(Id orderId){
        return new data([select id,Name,Item_Spec_Id__c,Service_Order_Stage__c,Priloc_Address__c,Secloc_Address__c, Schedule_Due_Date__c,M6_dd_task_date__c  from Service_Order__c where Order__c =:orderId AND Item_Spec_Id__c IN: productCode],getProductValuesIntoMap());
    }
    
    @AuraEnabled
    public static void syncServiceOrder(Service_Order__c serviceOrder){
        syncServiceOrders(new List<Service_Order__c>{serviceOrder});
    }
    
    public static Map<String,String> getProductValuesIntoMap(){
       Map<String,String> pickListValuesMap = new Map<String,String>();
        
		Schema.DescribeFieldResult fieldResult = Service_Order__c.Item_Spec_Id__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesMap.put(pickListVal.getValue(),pickListVal.getLabel());
		}     
		return pickListValuesMap;
    }
    
    public class data{
        @AuraEnabled
        Public List<Service_Order__c> lstSo;
        @AuraEnabled
        public Map<String,String> pickListValuesMap;
        public data(List<Service_Order__c> lstSo,Map<String,String> pickListValuesMap){
            this.lstSo = lstSo;
            this.pickListValuesMap = pickListValuesMap;
        }
    }
    
    @AuraEnabled
    public static void syncServiceOrders(List<Service_Order__c> serviceOrders){
        List<Service_Order__c> lstSo = new List<Service_Order__c>();
        for(Service_Order__c so : serviceOrders){
            Service_Order__c soUodated = ServiceOrderStage_Ctrl.updateOrderStage(so.Id,so.Name,false);
            if(soUodated != null){
                lstSo.add(soUodated);
            }
        }
        try{
            update lstSo;
        }catch(Exception ee){
            throw new ServiceOrderStage_Exception(JSON.serialize(new ServiceOrderStage_Ctrl.ErrorMessage('DML ERROR',ee.getMessage())));
        }
    }
    
    public class ServiceOrderStage_Exception extends Exception {}
}