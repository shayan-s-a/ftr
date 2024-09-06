/**
 * Author: Alishba
 * Date : 01/Nov/2023
 * @description US-, Controller for CustomizationsNotesUcf LWC
 */
public class CustomizationsNotesUcfController {

    /**
     * @description Method to load data for Customization Notes
     * @param recordId the order record Id
     * @return InitResponse
     */
    @AuraEnabled
    public static InitResponse loadData(String recordId) {
        Set<String> product2IdSet = new Set<String>();
     	InitResponse ir = new InitResponse();
        List<Order> orderList = [SELECT Id, Park_Keys__c, How_many_park_keys__c, Group_Page__c, Group_Pickup__c, Direct_Page__c, Speed_Calls__c,
                          DSS_BLF_Enhanced_Monitor_Extensions_Btns__c, Additional_UCF_Information__c, Is_it_shared_or_location_department__c
                          FROM Order 
                          WHERE Id =: recordId LIMIT 1];
        system.debug('recordId '+recordId);
        system.debug('orderList '+orderList);
        if(orderlist.size()>0){
        ir.orderRecord= orderList[0];
        system.debug('orderList '+orderList[0]);
        }
        else{
            Order emptyList= new Order();
            ir.orderRecord=emptyList;
        }

        for(OrderItem ordrItem :[SELECT Id, Product2Id,Product2.vlocity_cmt__SpecificationSubType__c FROM OrderItem WHERE OrderId =: recordId AND Product2Id != null AND Product2.vlocity_cmt__Type__c!='Accessories' AND Product2.vlocity_cmt__SpecificationSubType__c IN ('Yealink Phones','Conference Models','Poly Phones') AND Product2.vlocity_cmt__SubType__c NOT IN ('Power Cord')]){
            product2IdSet.add(ordrItem.Product2Id);
        }
        ir.lineItemsList = [SELECT Id,Name, VendorName__c, AvailableButtonCount__c
                            FROM Product2
                            WHERE  Id IN: product2IdSet];

        ir.NotificationList = [SELECT  Id,Name,	Department_System__c, Department_Name__c,Method__c,Phone_Number__c,	Email_Address__c,Order__c FROM ftr_911_Notifications__c WHERE Order__c =: recordId];
        					
        return ir;
     }
     
    
      //Methods for getting Product Date
	/*@AuraEnabled(cacheable=true)
	public static List<Product2> productData(String orderId) {
    	List<Product2> productlist = [SELECT Id, Name, VendorName__c, AvailableButtonCount__c FROM Product2 where Order__c = :orderId];
   		 return productlist;
		}*/
    
    /**
     * @description Method to update order record
     * @param orderToUpdate the order record to be updated
     */
    @AuraEnabled
    public static void updateOrder(Order orderToUpdate) {
        system.debug('order to update: '+orderToUpdate);
        try{
            update orderToUpdate;
        } catch(Exception ex){
            throw new AuraHandledException('Transaction Failed. Error: '+ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String update911Notifications(List<ftr_911_Notifications__c> updatedRecords) {
        try {
            
            System.debug('records: ' +updatedRecords) ;
            update updatedRecords;
            return 'Success';
        } catch(Exception e) {
            // Log the exception and return an error message
            System.debug('Error updating records: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }
    @AuraEnabled
    public static List<ftr_DID_Number_Details__c> ftrDIDNumberDetailsDepartment(String recordId) {
        List<ftr_DID_Number_Details__c> DIDNumberDetail = [SELECT Id,Ucf_Department__c
                                                           FROM ftr_DID_Number_Details__c 
                                                           WHERE Ucf_Number_Use__c='DID' 
                                                           AND Ucf_Department__c != null
                                                           AND DIDLocationDetailsId__r.OrderId__c  =: recordId
                                                          ];
        return DIDNumberDetail;
    }

    
        @AuraEnabled
    public static String insertNotification(String name, String departmentSystem, String departmentName, String method, Decimal phoneNumber, String emailAddress, Id recordId) {
        try {
            // Create and insert the new notification record
            ftr_911_Notifications__c newNotification = new ftr_911_Notifications__c(
                Name = name,
                Department_System__c = departmentSystem,
                Department_Name__c = departmentName,
                Method__c = method,
                Phone_Number__c = phoneNumber,
                Email_Address__c = emailAddress,
                Order__c = recordId
            );
            insert newNotification;
    
            // Return success message
            return 'Record inserted successfully.';
        } catch (Exception e) {
            // Handle exceptions
            return 'Error: ' + e.getMessage();
        }
    }
    

    
    /**
     * @description Wrapper class to hold response to display
     */
    public Class InitResponse{
        @AuraEnabled public Order orderRecord;
        @AuraEnabled public list<Product2> lineItemsList;
        @AuraEnabled public list<ftr_911_Notifications__c> NotificationList;
    }
}