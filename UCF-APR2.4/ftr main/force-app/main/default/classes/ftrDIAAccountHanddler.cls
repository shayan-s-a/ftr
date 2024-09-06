global class ftrDIAAccountHanddler implements vlocity_cmt.VlocityOpenInterface{
    
    public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        
        
            if (methodName == 'getAccountsByAddressAndName') {
                output.put('accountInfo',getAccountsByAddressAndName(input));
            }

            if (methodName == 'createAccountManagementCase') {
                output.put('newCase',createAccountManagementCase((Map<String,Object>)input.get('newCase')));
            }

        return false;
    }

    // @TestVisible
    public static List<Map<String,String>> getAccountsByAddressAndName(Map<String,Object> input) {
        System.debug('amev input: ' + input);
        String REGEX = '[\\W\\_]';
        String SERVRECORTYPE = 'Service';
        String MASTRVRECORTYPE = 'Master';

        String companyName = (String)input.get('idAccount');
        String city = (String)input.get('ServiceCity');
        String stateCode = (String)input.get('ServiceState');
        String street = (String)input.get('ServiceStreet');
        String nameQuery;
        String masterNameQuery;
        String masterAccQuery;     
        List<String> lstCompanyName = companyName.split(REGEX);
        List<Map<String,String>> accountInfo = new List<Map<String,String>>();        
      
        // Lookup is EMPTY
        if(lstCompanyName.isEmpty() || companyName.length() == 0){
            List<List<SObject>> relatedServiceAccount = [
                FIND :street IN NAME FIELDS 
                RETURNING Account (Id, name, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStateCode, ShippingStreet, RecordTypeId, 
                Parent.Id, Parent.Name, RecordType.Name 
                WHERE RecordType.Name =: SERVRECORTYPE 
                        AND ShippingCity =:city 
                        AND ShippingStateCode =: stateCode 
                        AND ShippingStreet =: street)
            ];

            Account [] searchServiceAccounts = (Account[])relatedServiceAccount[0];
            System.debug('amev searchServiceAccounts.size(): '+searchServiceAccounts.size());
            if(searchServiceAccounts.size()>0){
                for (Account accServ : searchServiceAccounts) {
                    if (accServ.Parent.Id != null ) {
                        Map<String,String> node = new Map<String, String>{
                            'recordtype'=> accServ.RecordTypeId,
                            'servicezippostalcode'=> accServ.ShippingPostalCode,
                            'servicecity'=> accServ.ShippingCity,
                            'servicestate'=> accServ.ShippingState,
                            'servicestreet'=>  accServ.ShippingStreet,
                            'Id'=> accServ.Parent.Id,
                            'name'=> accServ.Parent.Name
                        };
                        System.debug('amev node lookup empty: '+node);
                        accountInfo.add(node);
                    }          
                }        
            }
        }
        
        // Lookup is NOT empty
        List<String> stUpdtd = new List<String>();
        String searchTerm;
        if (companyName.length() > 1 && lstCompanyName.size() > 0 && !lstCompanyName.isEmpty() ) {
            for(String st: lstCompanyName){
                if (st.length() > 1) {
                    
                    st = st + '*';
                    stUpdtd.add(st);
                } 
            }
            searchTerm = String.join(stUpdtd, ' OR ');
           
            // Get master acc

            List<List<SObject>> searchList = [FIND :searchTerm IN NAME FIELDS RETURNING Account (id, name, RecordType.Name, RecordTypeId, ShippingPostalCode, ShippingCity, ShippingState, ShippingStreet WHERE RecordType.Name =: MASTRVRECORTYPE AND BillingPostalCode !=null AND ShippingStateCode =: stateCode)];
            Account [] searchAccounts = (Account[])searchList[0];
            

            // save Master IDs
            List<id> idAccList = new List<id>();
            for(Account a: searchAccounts){
                idAccList.add(a.Id);
            }

            // Get service acc where parent = master IDs 
            List<Account> serviceAccList = new List<Account>();
            for(Account accountRelated : [SELECT Id, name, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStateCode, ShippingStreet, RecordTypeId, 
            Parent.Id, Parent.Name, RecordType.Name FROM Account WHERE RecordType.Name =:SERVRECORTYPE AND ShippingCity =:city AND ShippingStateCode =: stateCode AND ShippingStreet =: street AND ParentId IN :idAccList]){
                serviceAccList.add(accountRelated);
            }
            
            
            for(Account accServ : serviceAccList){
                Map<String,String> node = new Map<String, String>{
                    'recordtype'=> accServ.RecordTypeId,
                    'servicezippostalcode'=> accServ.ShippingPostalCode,
                    'servicecity'=> accServ.ShippingCity,
                    'servicestate'=> accServ.ShippingState,
                    'servicestreet'=>  accServ.ShippingStreet,
                    'Id'=> accServ.Parent.Id,
                    'name'=> accServ.Parent.Name
                };
                
                accountInfo.add(node);
            }

            for (Account acc : searchAccounts) {
                Map<String,String> node = new Map<String, String>{
                    'recordtype'=> acc.RecordTypeId,
                    'servicezippostalcode'=> acc.ShippingPostalCode,
                    'servicecity'=> acc.ShippingCity,
                    'servicestate'=> acc.ShippingState,
                    'servicestreet'=>  acc.ShippingStreet,
                    'Id'=> acc.Id,
                    'name'=> acc.Name
                };
                
                accountInfo.add(node);
            }
        }
           
        if(accountInfo.isEmpty()) {
            throw new DmlException('No Record Found...');
        }

        return accountInfo;

    }

    // @TestVisible
    public static Boolean createAccountManagementCase(Map<String,Object> input) {
        Id accountManagementRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Management').getRecordTypeId();
        String accId = (String)input.get('newCaseAccountId');
        Account acc = [SELECT Name FROM Account WHERE Id =:accId Limit 1];
        String caseDescription = 'Verify Company Request test-'+ acc.name+'. \n Account Master Record created from Partner Portal.';
        //Fetching the assignment rules on case
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        
        System.debug(input);
        String subject= (String)input.get('newCaseSubject');
        String zipCode= (String)input.get('newCaseZipCode');
        String state= (String)input.get('newCaseState');
        String city= (String)input.get('newCaseCity');
        String street= (String)input.get('newCaseStreet');
        String phone= (String)input.get('newCasePhone');
        String priority= (String)input.get('newCasePriority');
        String relatedTo= (String)input.get('newCaseRelatedTo');
        String businessType= (String)input.get('newCaseBT');
        String status= (String)input.get('newCaseStatus');

        Case caseToInsert = new Case(
            AccountId= accId,
            Description= caseDescription,
            Subject = subject,
            Zip_Code__c = zipCode,
            CAP_State__c = state,
            City__c = city,
            Street_Address__c = street,
            Account_Phone__c = phone,
            Create_Account_Name__c = acc.Name,
            Priority = priority,
            Related_To2__c = relatedTo,
            Business_Type__c = businessType,
            Status = status,
            RecordTypeId = accountManagementRecordType
        );    

        //Setting the DMLOption on Case instance
        caseToInsert.setOptions(dmlOpts);

        System.debug(caseToInsert);

        insert caseToInsert;
    
        return true;
    }
}