global class CustomFieldValidation {
	global class CustomFieldValidationException extends Exception {
	}
	global CustomFieldValidation() {
	}

	private static Map<String, Object> ctx;
	static {
		ctx = new Map<String, Object>();
	}

	global CustomFieldValidation(String contextId, String validateOn) {
		try {
			Map<String, List<Object>> objectToValidationMap = new Map<String, List<Object>>();
			Map<String, Set<String>> objectToFieldMap = new Map<String, Set<String>>();
			for (CustomFieldValidation__mdt cfv : [
				SELECT ApplicableProducts__c, ExcludeProducts__c,Excluded_Product_Type__c, ErrorMessage__c, Operator__c, Field__c, Value__c, Object__c, IsRequired__c
				FROM CustomFieldValidation__mdt
				WHERE ValidateOn__c = :validateOn AND Excluded_Product_Type__c NOT IN ('Ring Central') AND IsEnabled__c = TRUE
				ORDER BY Field__c DESC
			]) {
				// validation map
				 System.debug('::::::: cfv1234'+cfv);
				if (objectToValidationMap.containsKey(cfv.Object__c)) {
					objectToValidationMap.get(cfv.Object__c).add(cfv);
				} else {
					objectToValidationMap.put(cfv.Object__c, new List<CustomFieldValidation__mdt>{ cfv });
				}
				// field map
				if (objectToFieldMap.containsKey(cfv.Object__c)) {
					objectToFieldMap.get(cfv.Object__c).add(cfv.Field__c);
				} else {
					objectToFieldMap.put(cfv.Object__c, new Set<String>{ cfv.Field__c });
				}
			}
			ctx.put('objectToValidationMap', objectToValidationMap);
			ctx.put('objectToFieldMap', objectToFieldMap);
			ctx.put('contextId', contextId);
			ctx.put('validateOn', validateOn);
            System.debug('ctx123455'+ctx); 
			Map<String, List<SObject>> recordsMap = getRecordsMap();
			Boolean isEasyPass = false;
            System.debug('BooleanrecordsMap'+(Boolean)recordsMap.get('Order')[0].get('isEasyPass__c')); 
            System.debug('BooleanrecordsMap'+recordsMap.keySet()); 
            System.debug('recordsMapXSY'+recordsMap); 
			if ((Boolean)recordsMap.get('Order')[0].get('isEasyPass__c')) {
				isEasyPass = true;
			}
			for (String obj : recordsMap.keySet()) {
                System.debug('BooleaObjectvalidationMap'+(List<CustomFieldValidation__mdt>) objectToValidationMap.get(obj)); 
				for (CustomFieldValidation__mdt cfv : (List<CustomFieldValidation__mdt>) objectToValidationMap.get(obj)) {
                    System.debug('cfv456'+cfv);
                     System.debug('isEasyPass666'+isEasyPass);
					if (isEasyPass) {
						if (cfv.Field__c.startsWith('Sales_Engineer')) continue;
					}
					system.debug('validation record: '+Json.serialize(cfv));
					processRecords(recordsMap.get(obj), cfv);
				}
			}
			customHandler();
		} catch (Exception e) {
			addError(new CustomFieldValidation__mdt(ErrorMessage__c =e.getMessage()));
			System.debug('Exception occurred in CustomFieldValidation'+e.getLineNumber());
			System.debug(':::::: Error Message'+e.getMessage());
		}
	}

	/**
	 * returns true if valid, List of errors if invalid
	 */

	global Boolean isValid() {
		return ctx.get('errors') == null ? true : false;
	}

	global String getErrors() {
		Set<String> errors = new Set<String>();
		Map<String, String> fieldErrorMap = new Map<String, String>();
		// seperate errors by field
		for (CustomFieldValidation__mdt cfv : (List<CustomFieldValidation__mdt>) ctx.get('errors')) {
			fieldErrorMap.put(cfv.Field__c, cfv.ErrorMessage__c);
		}

		return String.join(fieldErrorMap.values(), '.  \r\n');
	}

	global void addError(CustomFieldValidation__mdt cfv) {
		List<CustomFieldValidation__mdt> errors = (List<CustomFieldValidation__mdt>) ctx.get('errors');
		if (errors == null) {
			errors = new List<CustomFieldValidation__mdt>{ cfv };
		} else {
			errors.add(cfv);
		}
		ctx.put('errors', errors);
	}

	private Map<String, List<SObject>> getRecordsMap() {
		Id contextId = (Id) ctx.get('contextId');
        System.debug('::::: contextIdAXZ'+contextId);
		Map<String, List<SObject>> records = (Map<String, List<SObject>>) ctx.get('records');
        
		if (records == null) {
           
			Map<String, Set<String>> objectToFieldMap = (Map<String, Set<String>>) ctx.get('objectToFieldMap');
			Map<String, List<Object>> objectToValidationMap = (Map<String, List<Object>>) ctx.get('objectToValidationMap');
			records = new Map<String, List<SObject>>();
            System.debug('::::: recordsAFGHD');
			for (String obj : objectToValidationMap.keySet()) {
				String query = 'SELECT ';
				query += getFields(obj, objectToFieldMap);
				if (obj == 'Order') {
					query += ', isEasyPass__c, Products__c '; 
				}
				query += ' FROM ' + obj;
				query += getFilters(obj, contextId);
				List<SObject> results = Database.query(query);
                System.debug('::::: records:results'+results);
				if (obj == 'Location_Contact__c') {
                   System.debug('::::: records:obj'+Obj);
                    if (results.size() == 0) {
                         System.debug('::::: records:results'+results);
                        addError(new CustomFieldValidation__mdt(Field__c = 'Location_Contact__c', ErrorMessage__c = 'Location contacts are required'));                     
                    }
                }
				records.put(obj, results);
			}

			ctx.put('records', records);
		}
        System.debug('::::: records:1244'+records);
		return records;
	}

	private String getFields(String obj, Map<String, Set<String>> objectToFieldMap) {
		String result;
		List<String> fields = new List<String>(objectToFieldMap.get(obj));
        List<String> queryFields = new List<String>();
        // add any additional fields needed for processing
		if (obj == 'OrderItem') {
			queryFields.add('Product2.ProductCode');
			queryFields.add('vlocity_cmt__JSONAttribute__c');
		}
		for (String field : fields) {
			if (!field.contains('@')) {
				queryFields.add(field);
			}
		}
		result = String.join(queryFields, ', ');
		return result;
	}

	private String getFilters(String obj, Id contextId) {
		String filters = ' WHERE ';

		if (obj == 'Order') {
			filters += ' Id = :contextId';
		} else if (obj == 'OrderItem') {
			filters += ' OrderId = :contextId';
		} else if (obj == 'Location_Contact__c') {
			filters += ' Order__c = :contextId';
		}
		return filters;
	}

	private void processRecords(List<SObject> records, CustomFieldValidation__mdt cfv) {
		for (SObject record : records) {
			System.debug('current record: '+JSON.serialize(record));
			String operator = cfv.Operator__c;
			String[] fields = cfv.Field__c.split('\\.');
            System.debug('current fields: '+fields);
			if (cfv.Object__c == 'OrderItem') {
                 System.debug('cfv.Object__c'+cfv.Object__c);
                System.debug('cfv.Object__c1'+(String) record.get('vlocity_cmt__JSONAttribute__c'));
                System.debug('cfv.Object__c2'+(String) record.getSObject('Product2').get('ProductCode'));
                System.debug('cfv.ApplicableProducts__c'+cfv.ApplicableProducts__c);
                System.debug('cfv.ExcludeProducts__c'+cfv.ExcludeProducts__c);
                
				String jsonAttribute = (String) record.get('vlocity_cmt__JSONAttribute__c');
				String productCode = (String) record.getSObject('Product2').get('ProductCode');
                System.debug('productCode123244'+(String) record.getSObject('Product2').get('ProductCode'));
				if (String.isNotBlank(cfv.ApplicableProducts__c)) {
                    System.debug('In COming 6');
					if (cfv.ApplicableProducts__c.contains(productCode)) {
						// do the magic
						System.debug('In COming');
						getValueAndCheckForErrors(record, cfv, jsonAttribute, fields);
					}
				} else if (String.isNotBlank(cfv.ExcludeProducts__c)) {
                    System.debug('In productCode'+productCode); 
					if (!cfv.ExcludeProducts__c.contains(productCode)) {
						// do the magic
                        if(String.isNotBlank(jsonAttribute)){
                            getValueAndCheckForErrors(record, cfv, jsonAttribute, fields);
                        }
						
					}
				}
			} else {
				// do the magic for other objects
				String fieldValue = getFieldValue(fields, record);
				String compareValue = getValue(cfv, '', record);
				checkForErrors(fieldValue, compareValue, cfv);
			}
		}
        System.debug('::::: PPhta raha hai ke nhe');
	}

	private void getValueAndCheckForErrors(SObject record, CustomFieldValidation__mdt cfv, String jsonAttribute, String[] fields) {
		 
        String fieldValue, compareValue = getValue(cfv, jsonAttribute, record);
		if (cfv.Field__c.startsWith('@')) {
			// attribute
			 
			fieldValue = (String) ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, cfv.Field__c.substringAfter('@'));
             		} else {
			// field
			fieldValue = getFieldValue(fields, record);
		}
		checkForErrors(fieldValue, compareValue, cfv);
	}

	private void checkForErrors(String fieldValue, String compareValue, CustomFieldValidation__mdt cfv) {
        System.Debug('fieldValue = ' + fieldValue); 
		System.Debug('compareValue = ' + compareValue);
		Boolean addErr = false;
		if (cfv.IsRequired__c || (fieldValue != null && !cfv.IsRequired__c && compareValue != null)) {
            if (fieldValue == null && cfv.IsRequired__c){
                addErr = true;
            }
			else if (cfv.Operator__c == '=') {
				if (fieldValue != compareValue) {
					addErr = true;
				}
			} else if (cfv.Operator__c == '!=') {
				if (fieldValue == compareValue) {
					addErr = true;
				}
			} else if (cfv.Operator__c == 'includes') {
				if (!fieldValue.contains(compareValue)) {
					addErr = true;
				}
			} else if (cfv.Operator__c == 'excludes') {
				if (fieldValue.contains(compareValue)) {
					addErr = true;
				}
			} else if (cfv.Operator__c == 'regex') {
				if (!matchesPattern(fieldValue, compareValue)) {
					addErr = true;
				}
			} else if (cfv.Operator__c == '>=') {		// Added for HBE project by avv335 
                Integer fieldValueInt = ftr_CpqHelper.convertToSpeed(fieldValue);
                Integer compareValueInt = ftr_CpqHelper.convertToSpeed(compareValue);
				if (fieldValueInt < compareValueInt) {
                    addErr = true;
                }
            }
		}
		if (addErr)
			addError(cfv);
	}

	private String getValue(CustomFieldValidation__mdt cfv, String jsonAttribute, SObject record) {
		String value;
		if (cfv.Operator__c == 'regex') {
			return cfv.Value__c;
		}
		if (cfv.Value__c == null) {
			value = null;
		} else if (cfv.Value__c.startsWith('@')) {
			// attribute
			value = (String) ftr_CpqHelper.getJSONAttributeValue(jsonAttribute, cfv.Value__c.substringAfter('@'));
		} else if (cfv.Value__c.startsWith('$')) {
			// field
			value = getFieldValue(cfv.Value__c.split('\\.'), record);
		} else {
			// as is
			value = cfv.Value__c;
		}
		return value;
	}

	private String getFieldValue(String[] fields, SObject record) {
        String value;
        Double currencyvalue;
		if (fields.size() == 1) {
			if(String.Valueof(fields[0]) == 'vlocity_cmt__RecurringCharge__c'){
			currencyvalue = (Double) record.get(fields[0].replaceAll('\\$', ''));
                value = String.valueOf(currencyvalue);
			}
			else {
			value = (String) record.get(fields[0].replaceAll('\\$', ''));
			}
		} else if (fields.size() == 2 && record.getSObject(fields[0]) != null) {
			value = (String) record.getSObject(fields[0].replaceAll('\\$', '')).get(fields[1]);
		}
        return value;
    }

	global static Boolean matchPattern(String value, String regex) {
		if (value == null || regex == null)
			return false;
		Pattern pat = Pattern.compile(regex);
		Matcher match = pat.matcher(value);
		return match.matches();
	}

	private Boolean matchesPattern(String value, String regex) {
		return CustomFieldValidation.matchPattern(value, regex);
	}

	/**
	 * @description: custom handler for validations not covered in Custom Metadata
	 */
	private void customHandler() {
		if ((String)ctx.get('validateOn') == 'Submit Order') {
			Order myOrder = ((Order[])((Map<String, Object>)ctx.get('records')).get('Order'))[0];
			if (myOrder.Products__c.contains('SIP')) {
				ftr_DID_Location_Details__c[] locDetail = [SELECT Id FROM ftr_DID_Location_Details__c WHERE OrderId__c=:myOrder.Id];
				if (locDetail.size() == 0) {
					addError(new CustomFieldValidation__mdt(ErrorMessage__c = 'DID Enrichment is incomplete. At least one DID Location is required.'));
				}
			}
		}
	}
}