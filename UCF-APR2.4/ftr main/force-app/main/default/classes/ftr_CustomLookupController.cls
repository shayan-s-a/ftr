public with sharing class ftr_CustomLookupController {
	@AuraEnabled
	public static List<sObject> search(String objectName, String searchFields, String returnFields, String searchTerm, String filter) {
		try {
			// first try to search by id
			Id recordId = Id.valueOf(searchTerm);
			String query = 'SELECT ';
			query += returnFields + ' FROM ' + objectName + ' WHERE Id =:searchTerm';
			return Database.query(query);
		} catch (Exception ex) {
			// do a sosl if not found by id
			String searchKeyword = searchTerm + '*';
			String searchQuery = ' ALL FIELDS ';
			if (searchFields != null) {
				searchQuery = searchFields + ' FIELDS ';
			}

			String returningQuery = objectName + ' ( ';
			if (!returnFields.contains('Id')) {
				returningQuery += ' Id, ';
			}
			returningQuery += returnFields;
			if (filter != null) {
				returningQuery += ' WHERE ' + filter;
			}
			returningQuery += ')';
			String query = 'FIND :searchKeyword IN ' + searchQuery + ' RETURNING ' + returningQuery + ' LIMIT 20';
			System.debug(' query ' + query);
			List<List<sObject>> searchRecords = Search.Query(Query);
			return searchRecords.get(0);
		}
	}
}
