public class GetDataForCustomLookup {
	@AuraEnabled
    public static List<contact> getSuggestions(String inputData,String searchString){
        List<Contact> contactList = [select Id,Name from Contact where AccountId=:inputData];
        return contactList;
    }
}