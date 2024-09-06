/**
 * ───────────────────────────────────────────────────────────────────────────────────────────────┐
* @description  This class generetes Bulk Test data in new sandboxes.
                This class is not ment to be called in production
* ────────────────────────────────────────────────────────────────────────────────────────────────
* @param    not applicable
* @return   successfull message on completion via System Debug
* ───────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public with sharing class BulkTestDataCreationBatch implements Database.Batchable<sObject> {
    static List<Account> masterAccList;
    static List<Account> carrierAccList;
    static List<Contact> defaultContactList;
    static List<Campaign> campaignList;
    static List<Opportunity> opportunityList;
    static List<Contract> contractList;

    static List<SObject> recordListToInsert;

    static final String ACCOUNT_RT_GLOBAL = '0128a000000tj2qAAA';
    static final String ACCOUNT_RT_MASTER = '012E0000000fDc3IAE';
    static final String ACCOUNT_RT_CARRIER_SERVICE = '0120h000000MekIAAS';
    static final String CONTACT_RT_DEFAULT = '012E0000000kEDgIAM';
    static final String CONTACT_RT_CARRIER_SERVICE_CONTACT = '0120h000000MekJAAS';
    static final String CONTRACT_RT_COMMUNITY_CONNECTION_AGREEMENT = '0120h000000pAtTAAU';
    static final String CONTRACT_RT_DEFAULT = '012E0000000kEDlIAM';
    static final String LEAD_RT_MDU_LEAD = '0128a0000014mSFAAY';
    static final String LEAD_RT_WHOLESALE_LEAD = '0128a000001No08AAC';
    static final String OPPORTUNITY_RT_COMMUNITY_CONNECTIONS = '012E0000000fK7PIAU';
    static final String OPPORTUNITY_RT_OPPORTUNITY_LIGHTNING = '0120h000000cc54AAA';
    static final String FRONTIER_PROJECT_RT_MDU = '0128a000000th9WAAQ';
    static final String ORDER_RT_VLOCITY_OM_ORDER = '0120h000000YRm0AAG';
    static final String ORDER_RT_UCAAS_NEW_ORDER = '0120h000000CFauAAG';
    static final String CASE_RT_RISK = '0120h000000kwjjAAA';
    static final String CASE_RT_SALESFORCE_ADMIN = '0120h000000CFexAAG';

    // static void disableFlows() {
    //     List<Flow_Settings__mdt> objectMDTList = Flow_Settings__mdt.getAll().values();

    //     for(Flow_Settings__mdt objectMDT: objectMDTList ){
    //         //system.debug(objectMDT.Label);
    //         objectMDT.Value__c = false;
    //     }

    // }

    // static void enableFlows() {
    //     List<Flow_Settings__mdt> objectMDTList = Flow_Settings__mdt.getAll().values();

    //     for(Flow_Settings__mdt objectMDT: objectMDTList ){
    //         //system.debug(objectMDT.Label);
    //         objectMDT.Value__c = true;
    //     }

    // }

    static void disableOpptyTrigger() {
        TriggerSettings__c triggerSettings = TriggerSettings__c.getOrgDefaults();
        if(triggerSettings != null && triggerSettings.OpportunityTriggerDisabled__c == false) {
            // Disable the trigger
            triggerSettings.OpportunityTriggerDisabled__c = true;

            update triggerSettings;
        }
    }

    static void enableOpptyTrigger() {
        TriggerSettings__c triggerSettings = TriggerSettings__c.getOrgDefaults();
        if(triggerSettings != null && triggerSettings.OpportunityTriggerDisabled__c == true) {
            // Enable the trigger
            triggerSettings.OpportunityTriggerDisabled__c = false;

            update triggerSettings;
        }
    }

    public static void generateData(){

        String sandboxName = DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName();
        boolean isSandbox = false;
        if(!String.isEmpty(sandboxName)){
            isSandbox = true;
        }

        if(isSandbox){
            disableOpptyTrigger();
            Account newAccount = new Account(
                Name = 'TestData - Global Company - A',
                RecordTypeId = ACCOUNT_RT_GLOBAL 
            );
            insert newAccount;
            BulkTestDataCreationBatch batch = new BulkTestDataCreationBatch();
            Database.executeBatch(batch);
        } else {
            System.debug('This code is only intended for execution in a sandbox environment. Please ensure you are running this code in a sandbox org.');
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM Account');
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        createAccounts();
        createContacts();
        createContracts ();
        createCampaigns ();
        createLeads ();
        createOpportunity ();
        //createOrders ();
        createProjects ();
        
        createCases ();
    }

    public void finish(Database.BatchableContext bc) {
        enableOpptyTrigger();
        System.debug('Batch Apex job completed successfully.');
    }
    
    static void createAccounts(){
       // Creating Account records of the Record Type of "Global"
       List<Account> allAccountsToInsert = new List<Account>();

       List<Account> globalAccountsToInsert = new List<Account>();

       for(Integer i = 1; i <= 20; i++) {
           Account newAccount = new Account(
               Name = 'TestData - Global Company - ' + i,
               RecordTypeId = ACCOUNT_RT_GLOBAL 
           );
           globalAccountsToInsert.add(newAccount);
       }
       insert globalAccountsToInsert;

       // Creating Account records for the Record Type of 'Master accounts' and 'Carrier Service'
       List<Account> masterAccountsToInsert = new List<Account>();
       List<Account> carrierAccountsToInsert = new List<Account>();

       for(Integer i = 1; i <= 20; i++) {
           Account newAccountMaster = new Account(
               Name = 'TestData - Master Company - ' + i,
               RecordTypeId = ACCOUNT_RT_MASTER,
               ParentId = globalAccountsToInsert[0].Id
               // Add other fields as needed00
           );
           masterAccountsToInsert.add(newAccountMaster);

           Account newAccountCarrier = new Account(
                Name = 'TestData - Carrier Company - ' + i,
                RecordTypeId = ACCOUNT_RT_CARRIER_SERVICE
                // Add other fields as needed
            );
            carrierAccountsToInsert.add(newAccountCarrier);
       }
       masterAccList = masterAccountsToInsert;
       carrierAccList = carrierAccountsToInsert;
       
       allAccountsToInsert.addAll(masterAccountsToInsert);
       allAccountsToInsert.addAll(carrierAccountsToInsert);
       //insert masterAccountsToInsert;
       //insert carrierAccountsToInsert;

       insert allAccountsToInsert;
    }

    static void createContacts(){
        // Creating Contact records for the Record Type of 'Default' and 'Carrier Service Contact'
        List<Contact> allContactsToInsert = new List<Contact>();

        List<Contact> defaultContactsToInsert = new List<Contact>();
        List<Contact> carrierContactsToInsert = new List<Contact>();

        for(Integer i = 1; i <= 20; i++) {
            Contact newContactDefault = new Contact(
                LastName = 'TestData - Default Contact - ' + i,
                Contact_Role__c = 'Legal Notice Person 1',
                RecordTypeId = CONTACT_RT_DEFAULT
                // Add other fields as needed
            );
            defaultContactsToInsert.add(newContactDefault);

            Contact newContactCarrier = new Contact(
                LastName = 'TestData - Carrier Contact - ' + i,
                RecordTypeId = CONTACT_RT_CARRIER_SERVICE_CONTACT
            );
            carrierContactsToInsert.add(newContactCarrier);
        }
        defaultContactList =  defaultContactsToInsert;
        allContactsToInsert.addAll(defaultContactsToInsert);
        allContactsToInsert.addAll(carrierContactsToInsert);
        //insert defaultContactsToInsert;        
        //insert carrierContactsToInsert;
        
        insert allContactsToInsert;
    }

    static void createContracts (){
        // Creating Contract records for the Record Type of 'Community Connections - Agreement' and 'Default'
        List<Contract> allContractsToInsert = new List<Contract>();
        
        List<Contract> commconnaggContractsToInsert = new List<Contract>();
        List<Contract> defaultContractsToInsert = new List<Contract>();

        for(Integer i=1; i<=20; i++) {
            Contract newContractCommunity = new Contract(
                AccountId = masterAccList[i-1].id, //Master
                Agreement_Effective_Date__c = Date.today().addDays(4),
                Agreement_End_Date__c = Date.today().addDays(9),
                Signatory_Person_Name__c = defaultContactList[i-1].id, // Default Contact
                RecordTypeId = CONTRACT_RT_COMMUNITY_CONNECTION_AGREEMENT
            );
            commconnaggContractsToInsert.add(newContractCommunity);

            Contract newContractDefault = new Contract(
                AccountId = masterAccList[i-1].id, //Master Account
                StartDate = Date.today().addDays(2),
                RecordTypeId = CONTRACT_RT_DEFAULT
            );
            defaultContractsToInsert.add(newContractDefault);
        }
        contractList = commconnaggContractsToInsert;
        allContractsToInsert.addAll(commconnaggContractsToInsert);
        allContractsToInsert.addAll(defaultContractsToInsert);
        // insert commconnaggContractsToInsert;
        // insert defaultContractsToInsert;

        insert allContractsToInsert;
    }

    static void createCampaigns (){
        List <Campaign> campaignRecordsToInsert = new List<Campaign>();

        for(Integer i=1; i<=20; i++){
            Campaign newCamp = new Campaign(
                Name = 'TestData - Campaign - ' + i
            );
            campaignRecordsToInsert.add(newCamp);
        }
        campaignList = campaignRecordsToInsert;
        insert campaignRecordsToInsert;
    }

    static void createLeads (){
        List<Lead> allLeadsToInsert = new List<Lead>();

        List<Lead> mduLeadToInsert = new List<Lead>();
        List<Lead> wholeSaleLeadToInsert = new List<Lead>();

        for(Integer i=1; i<=20; i++){
            Lead newLeadMDU = new Lead(
                LastName = 'TestData - MDU Lead ' + i,
                LeadSource = 'Costar_MDU',
                Property_Name__c = 'DevTest03',
                Company = 'DevTestCompany',
                Number_of_Units__c = 23,
                Email = 'devtest@mail.com',
                Phone = '131684',   
                Primary_Campaign__c = campaignList[i-1].id,
                Country = 'United States',
                Street = 'testStreet0',
                City = 'Anza',
                State = 'California',
                PostalCode = '53432',
                RecordTypeId = LEAD_RT_MDU_LEAD
            );
            mduLeadToInsert.add(newLeadMDU);

            Lead newLeadWholesale = new Lead(
                LastName = 'TestData - Wholesale Lead '+ i,
                Company = 'testCompany',
                RecordTypeId = LEAD_RT_WHOLESALE_LEAD
            );
            wholeSaleLeadToInsert.add(newLeadWholesale);
        }
        allLeadsToInsert.addAll(mduLeadToInsert);
        allLeadsToInsert.addAll(wholeSaleLeadToInsert);

        // insert mduLeadToInsert;
        // insert wholeSaleLeadToInsert;

        insert allLeadsToInsert;
    }

    static void createOpportunity (){
        // Creating Opportunity records for the Recort Type of 'Community Connections' 
        List<Opportunity> allOpportunitiesToInsert = new List<Opportunity>();

        List<Opportunity> commconnOpportunitiesToInsert = new List<Opportunity>();

        for(Integer i=1; i<=20; i++) {
            Opportunity newOpportunity = new Opportunity(
                Name = 'TestData - Community Connections Opportunity - ' + i,
                AccountId = masterAccList[i-1].id, // Master Account
                Agreement_Type__c = 'Bulk',
                StageName = 'CRT Submitted',
                ForecastCategoryName = 'Pipeline',
                CloseDate = Date.today().addDays(5),
                RPON_Order__c = '10115794',
                Probability = 10,
                Contracted_Units_Number__c = 10,
                Contract_Term_Months__c = 5,
                Contract_Category__c = 'New',
                Total_MRC__c = 670,
                Product_Type__c = 'Data - Copper',
                Installation_Type__c = 'Brownfield has full/partial FTR service',
                RecordTypeId = OPPORTUNITY_RT_COMMUNITY_CONNECTIONS
            );
            commconnOpportunitiesToInsert.add(newOpportunity);
        }
        opportunityList = commconnOpportunitiesToInsert;
        allOpportunitiesToInsert.addAll(commconnOpportunitiesToInsert);
        //insert commconnOpportunitiesToInsert;
        
        
        // Creating Opportunity records for the Record Type of 'Opportunity Lightning'
        List<Opportunity> opptlgtOpportunitiesToInsert = new List<Opportunity>();

        for(Integer i=1; i<=10; i++) {
            Opportunity newOpportunityOppLgt1 = new Opportunity(
                Name = 'TestData - OpptyLightning Opportunity - ' + i,
                AccountId = masterAccList[i-1].id, // Master Account
                StageName = 'Prospecting',
                ForecastCategoryName = 'Omitted',
                CloseDate = Date.today().addDays(5),
                Lead_Product_List__c = 'Cloud IT',
                Service_Address__c = 'test Address',
                Description__c = 'test description',
                RecordTypeId = OPPORTUNITY_RT_OPPORTUNITY_LIGHTNING
            );
            opptlgtOpportunitiesToInsert.add(newOpportunityOppLgt1);

            Opportunity newOpportunityOppLgt2 = new Opportunity(
                Name = 'TestData - OpptyLightning Opportunity - ' + i+10,
                AccountId = carrierAccList[i-1].id,
                StageName = 'Prospecting',
                ForecastCategoryName = 'Omitted',
                CloseDate = Date.today().addDays(5),
                Lead_Product_List__c = 'Cloud IT',
                Service_Address__c = 'test Address',
                Description__c = 'test description',
                RecordTypeId = OPPORTUNITY_RT_OPPORTUNITY_LIGHTNING
            );
            opptlgtOpportunitiesToInsert.add(newOpportunityOppLgt2);
        }
        allOpportunitiesToInsert.addAll(opptlgtOpportunitiesToInsert);
        //insert opptlgtOpportunitiesToInsert;

        insert allOpportunitiesToInsert;
    }


    static void createProjects (){
        List<Project__c> mduProjectToInsert = new List<Project__c>();

        for(Integer i=1; i<=20; i++){
            Project__c newProject = new Project__c(
                Opportunity__c = opportunityList[i-1].Id, // Community Connections [Opportunity]
                RecordTypeId = FRONTIER_PROJECT_RT_MDU
            );
            mduProjectToInsert.add(newProject);
        }
        insert mduProjectToInsert;       
    }

    // static void createOrders (){
    //     // Creating Order records for the record type of 'Vlocity OM Order'
    //     // List<Order> vlomOrdersToInsert = new List<Order>();
    //     // for(Integer i=1; i<=5; i++){
    //     //     Order newOrder = new Order(
    //     //         EffectiveDate = Date.today().addDays(10),
    //     //         AccountId = masterAccList[i-1].id, //Master
    //     //         Product_Type__c = '2 - Wire Circuit',
    //     //         Status = 'Draft',
    //     //         RecordTypeId = ORDER_RT_VLOCITY_OM_ORDER
    //     //     );
    //     //     vlomOrdersToInsert.add(newOrder);
    //     // }
    //     // insert vlomOrdersToInsert;     
        
    //     // Creating Order records for the record type of 'UCaaS New Order'
        
    //     // List<Order> ucaasnoOrdersToInsert = new List<Order>();
    //     // for(Integer i=1; i<=5; i++){
    //     //     Order newOrder = new Order(
    //     //         EffectiveDate = Date.today().addDays(10),
    //     //         OpportunityId = opportunityList[i-1].Id, //Community Connections [Opportunity]
    //     //         Out_of_Franchise__c = 'Yes',
    //     //         Contract_Schedule__c = contractList[i-1].Id, //Community Connections - Agreement [Contract]
    //     //         AccountId = masterAccList[i-1].id, //Master [Account]
    //     //         Is_there_a_Related_Vlocity_Order__c = 'No',
    //     //         Description = 'testing 12345',
    //     //         Order_Point_of_Contact__c = UserInfo.getUserId(), // User name
    //     //         Technical_Contact_Name__c = 'Test name',
    //     //         Contact_Email__c = 'test@email.com',
    //     //         Technical_Contact_Number__c = '92884',
    //     //         Product__c = 'Frontier AnyWare UCaaS - BYOA	',
    //     //         Status = 'Draft',
    //     //         BillingStreet = '123 Main St',
    //     //         BillingCity = 'Citytown',
    //     //         BillingState = 'California',
    //     //         BillingPostalCode = '12345',
    //     //         BillingCountry = 'United States',
    //     //         ShippingStreet = '123 Main St',
    //     //         ShippingCity = 'Citytown',
    //     //         ShippingState = 'California',
    //     //         ShippingPostalCode = '12345',
    //     //         ShippingCountry = 'United States',
    //     //         RecordTypeId = ORDER_RT_UCAAS_NEW_ORDER
    //     //     );
    //     //     ucaasnoOrdersToInsert.add(newOrder);
    //     // }
    //     // System.debug('Creating Orders');
    //     // insert ucaasnoOrdersToInsert;
        
    // }

    static void createCases (){
        // Creating Case for the record type of "Risk" and "Salesforce Admin"
        List<Case> allCasesToInsert = new List <Case>();

        List <Case> riskCasesToInsert = new List<Case> ();
        List <Case> sfadminCasesToInsert = new List<Case> ();

        for(Integer i=1; i<=20; i++){
            Case newCaseRisk = new Case(
                Product_Risk__c = 'Anyware',
                Risk_Level__c = 'Low',
                Estimated_Date_of_Potential_Loss__c = Date.today().addDays(10),
                Description = 'TestData',
                Subject = 'TestData',
                RecordTypeId = CASE_RT_RISK
            );

            riskCasesToInsert.add(newCaseRisk);

            Case newCaseSFAdmin = new Case(
                Type_of_Request__c = 'Account Planner',
                Desired_Due_Date__c = Date.today().addDays(6),
                How__c = '5-25',
                User_Impacted_Name__c = 'testUser',
                Subject = 'TestData',
                Description = 'TestData',
                RecordTypeId = CASE_RT_SALESFORCE_ADMIN
            );

            sfadminCasesToInsert.add(newCaseSFAdmin);
        }
        allCasesToInsert.addAll(riskCasesToInsert);
        allCasesToInsert.addAll(sfadminCasesToInsert);

        // insert riskCasesToInsert;
        // insert sfadminCasesToInsert;        

        insert allCasesToInsert;
    }
}