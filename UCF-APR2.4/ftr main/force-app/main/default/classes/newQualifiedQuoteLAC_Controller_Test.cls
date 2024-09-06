@IsTest 
public class newQualifiedQuoteLAC_Controller_Test {
    @IsTest
    private static Void newQualifiedQuoteLAC_Controller_Test(){
        // Get the RecordType Id of the 'Global' Account RecordType
        Id globalRecId = [
            SELECT  Id,
                    DeveloperName
            FROM    RecordType
            WHERE   SObjectType = 'Account'
            AND     DeveloperName = 'Global'
            LIMIT   1
        ]?.Id;
        // Create a new 'Global' Account with the above RecordType
        Account globalAcc1 = new Account(
            Name = 'GLOBAL ACCOUNT',
            RecordTypeId = globalRecId
        );
        insert globalAcc1;
        // Get the RecordType Id of the 'Master' Account RecordType
        Id masterRTId = [
            SELECT  Id,
                    DeveloperName
            FROM    RecordType
            WHERE   SObjectType = 'Account'
            AND     DeveloperName = 'Master'
            LIMIT   1
        ]?.Id;
        // Create a new 'Master' Account with the above RecordType and the 'Global' Account as its parent
        Account masterAcc = new Account(
            Name = 'Master Account',
            RecordTypeId = masterRTId,
            ParentId = globalAcc1.Id
        );
        insert masterAcc;

        Account acc = new Account(Name = 'Test Account',BillingStreet='23100 Avenue San Luis',BillingCity= 'WoodLandHills',ParentId = globalAcc1.Id,
                    BillingState= 'California',BillingCountry ='United States',BillingPostalCode ='91364',Legal_Street__c ='23100 Avenue San Luis',
                    Legal_City__c='WOODLAND HILLS',Legal_State__c='California',Legal_Zip__c ='91364',Legal_Country1__c='United States',ShippingStreet='23100 Avenue San Luis',
                    ShippingCity='WODLAND',ShippingState='California',ShippingCountry='United States',ShippingPostalCode ='91364');
        insert acc;

        // Get the RecordType Id of the 'Community_Connections' Opportunity RecordType
        Id opRecordTypeId = [
            SELECT  Id,
                    DeveloperName
            FROM    RecordType
            WHERE   SObjectType = 'Opportunity'
            AND     DeveloperName = 'Community_Connections'
            LIMIT   1
        ]?.Id;

        // Create a new Opportunity with the 'Community_Connections' RecordType and add it to the 'old' map
        Opportunity opp = new Opportunity(
            Name = 'TestCTOppty',
            AccountId = acc.Id,
            Opportunity_Type__c = 'New',
            Partner_Sales_Stages__c = 'Decision',
            CloseDate = System.today(),
            ForecastCategoryName = 'Commit',
            Campaign__c = 'No',
            New_Logo__c = 'No',
            StageName = 'Decision',
            Lead_Product_List__c = 'Managed Firewall',
            Description_of_customer_needs__c = 'Test SEER',
            Description__c = 'Test for SEER',
            Service_Address__c = '2111 Cannes, Dallas, TX',
            Service_Zip_code__c = '90605',
            RecordTypeId = opRecordTypeId
        );
        insert opp;

        NewQualifiedQuoteLAC_Controller.quoteEdit_SterlingCPQ(opp.Id);
        NewQualifiedQuoteLAC_Controller.reDirectToSterling(opp.Id,'Billing Address');
        NewQualifiedQuoteLAC_Controller.reDirectToSterling(opp.Id,'Legal Address');
        NewQualifiedQuoteLAC_Controller.reDirectToSterling(opp.Id,'Service Address');
        NewQualifiedQuoteLAC_Controller.reDirectToSterling(opp.Id,'None');
    } 
}