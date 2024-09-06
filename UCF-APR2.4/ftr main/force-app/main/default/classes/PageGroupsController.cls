/**
 * Author: Alishba
 * Date : 01/Nov/2023
 * @description US-, Controller for PageGroups LWC
 */
public class PageGroupsController {

    /**
     * @description Method to load data for Page Group
     * @param recordId the order record Id
     * @return InitResponse
     */
    @AuraEnabled
    public static InitResponse loadData(String recordId) {
        Map<String, Page_Group__c> pageGroupMap = new Map<String, Page_Group__c>();
        InitResponse ir = new InitResponse();
        //fetch order with group page being checked
        list<Order> orderList = [SELECT Id, Group_Page__c
                                 FROM Order 
                                 WHERE Id =: recordId 
                                 AND Group_Page__c = true LIMIT 1];
        if(orderList.isEmpty()){
            return null;
        }
        
        ir.ftrDIDNumberDetailList = [SELECT Id, DIDNumber__c, Ucf_Extension__c, Ucf_User_Name__c 
                                     FROM ftr_DID_Number_Details__c 
                                     WHERE Ucf_Number_Use__c ='DID' 
                                     AND DIDLocationDetailsId__r.OrderId__c  =: recordId];
        
        ir.pageGroupsList = [SELECT Id, Members__c, Name 
                             FROM Page_Group__c 
                             WHERE Order__c =: recordId ORDER By Name ASC];

        System.debug('ir: '+ir);
        return ir; 
    }
    
    /**
     * @description Method to delete Page Group record and its child records
     * @param recordId the Id of the Page Group record to be deleted
     */
    @AuraEnabled
    public static void deletePageGroup(String recordId) {
        system.debug('group id to delete:'+recordId);
        try{
            delete [SELECT Id 
                    FROM Group_Member__c 
                    WHERE Page_Groups__c =: recordId];
            delete [SELECT Id 
                    FROM Page_Group__c 
                    WHERE Id =: recordId];
        } catch(Exception ex){
            throw new AuraHandledException('Transaction Failed. Error: '+ex.getMessage());
        }
    }
    
    /**
     * @description Method to get Group Member records
     * @param pagegroupId the page group record Id
     * @return List<Group_Member__c>
     */
    @AuraEnabled
    public static List<Group_Member__c> GetDidNumbers(String pagegroupId) {
        return [SELECT Id, DID_Number_Details__c, Page_Groups__c 
                FROM Group_Member__c 
                WHERE Page_Groups__c =: pagegroupId];
    }
    @AuraEnabled
    public static List<Group_Member__c> DownloadPMPageGroupMembers(String OrderId) {
        return [SELECT Id,Name, Page_Groups__r.Order__c,UserName__c,Page_Groups__r.Name
                FROM Group_Member__c 
                WHERE Page_Groups__r.Order__c =: OrderId];
    }
    /**
     * @description Method to perform 3 operations
     * Operation 1: Make updates(Member Count) send from LWC on the Page Group record
     * Operation 2: Insert new members if any
     * Operation 3: Delete records of Group Member if any member is removed
     * @param pageGroupRecordToUpdate
     * @param gmRecordsList
     */
    @AuraEnabled
    public static void updateRecords(Page_Group__c pageGroupRecordToUpdate, List<Group_Member__c> gmRecordsList, Boolean ishandle) {
        system.debug(gmRecordsList);
        try {
            // Operation 1
            update pageGroupRecordToUpdate;

        /*    if (gmRecordsList == null || gmRecordsList.isEmpty()) {
            return; // No members to process, so exit the method early
        }*/
            if(ishandle == true){
            List<Group_Member__c> newGrouMembersToInsert = new List<Group_Member__c>();
            Set<String> existingMembersSet = new Set<String>();
            Set<String> membersInGmRecordsSet = new Set<String>();
            Set<String> removedMembersSet = new Set<String>();
            List<Group_Member__c> groupMembersRecordsToDeleteList = new List<Group_Member__c>();
            
            // Operation 2
            // fetch all exisitng group members of the Group being edited 
            for (Group_Member__c existingRec : [SELECT Id, DID_Number_Details__c, UserName__c, Page_Groups__c 
                                                FROM Group_Member__c 
                                                WHERE Page_Groups__c =: pageGroupRecordToUpdate.Id]) {
                existingMembersSet.add(existingRec.DID_Number_Details__c);
            }
            
            // clean duplicates to avoid inserting same member multiple times
            for (Group_Member__c rmRec : gmRecordsList) {
                membersInGmRecordsSet.add(rmRec.DID_Number_Details__c); // maintaining for Operation 3
                if (!existingMembersSet.contains(rmRec.DID_Number_Details__c)) {
                    newGrouMembersToInsert.add(rmRec);
                }
            }
            
            System.debug('newGrouMembersToInsert: '+newGrouMembersToInsert);
            // Insert records if no duplicates were found
            if(!newGrouMembersToInsert.isEmpty()) insert newGrouMembersToInsert;
            
            //Operation 3
            for (String member : existingMembersSet) {
                if (!membersInGmRecordsSet.contains(member)) {
                    removedMembersSet.add(member);
                }
            }
            
            // fetch all exisitng group members record required to delete
            for (Group_Member__c rec : [SELECT Id FROM Group_Member__c 
                                        WHERE DID_Number_Details__c IN: removedMembersSet 
                                        AND Page_Groups__c =: pageGroupRecordToUpdate.Id]) {
                groupMembersRecordsToDeleteList.add(rec);
            }
            
            // delete records
            if(!groupMembersRecordsToDeleteList.isEmpty()) delete groupMembersRecordsToDeleteList;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Transaction Failed. Error: '+e.getMessage());
        }
    }
    
    /**
     * @description Method to insert Page Group record
     * @param groupName the Name for the page Group
     * @param orderId the Id of the order for which page group to be created
     */
    @AuraEnabled
    public static void createPageGroup(String groupName, String orderId) {
        try {
            insert new Page_Group__c(Name = groupName, Order__c = orderId);
        } catch (Exception e) {
            throw new AuraHandledException('Transaction Failed. Error: '+e.getMessage());
        }
    }
    @AuraEnabled
    public static void getMembers(String groupName, String orderId) {
        try {
            insert new Page_Group__c(Name = groupName, Order__c = orderId);
        } catch (Exception e) {
            throw new AuraHandledException('Transaction Failed. Error: '+e.getMessage());
        }
    }
    
        //Methods for getting Page Group Date
	@AuraEnabled(cacheable=true)
	public static List<Page_Group__c > pageGroupData(String orderId) {
    	List<Page_Group__c> pageGrouplist = [SELECT Id,name,Members__c, Order__c from Page_Group__c where Order__c = :orderId ];
   		 return pageGrouplist;
		}
    
    /**
     * @description Wrapper class to hold response to display
     */
    public Class InitResponse{
        @AuraEnabled public list<ftr_DID_Number_Details__c> ftrDIDNumberDetailList;
        @AuraEnabled public list<Page_Group__c> pageGroupsList;
        @AuraEnabled public list<Page_Group__c> availableMembersList;
    }
}