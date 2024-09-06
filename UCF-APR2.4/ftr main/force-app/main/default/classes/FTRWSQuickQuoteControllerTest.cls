/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class FTRWSQuickQuoteControllerTest {
    
    public static Opportunity opp;
    //public static SterlingQuote__c quote;
    
    public static Opportunity testOpportunity;
    public static SterlingQuote__c testQuote;
    public static SterlingQuoteItem__c testQuoteItem;
    public static OpportunityLineItem testOpportunityProduct;
    
    @isTest
    public static void testQuickQuoteController() {
        prepareTestData();
        Test.startTest();
        
        FTRWSQuickQuoteController.getCurrentOpportunity(testOpportunity.id);
        FTRWSQuickQuoteController.getSyncedQuote(testOpportunity.id);
        
        FTRWSQuickQuoteController controller  = new FTRWSQuickQuoteController();
        controller.ftrURL = 'https://wholesale.frontier.com';
        controller.rfqString = FTRWSQuickQuoteController.getRFQString(testQuote.WS_Quote_Number__c);
        controller.quoteCreateDate = System.now().format('yyyy-MM-dd');
        controller.init(testOpportunity.Id);
        
controller.totalQQValue = 1000.00;
    controller.totalOnetimeCharge = 500.00;
    controller.totalMonthlyCharge=500.00;
        Test.stopTest();
    }
    
        private static void prepareTestData() {
        			testOpportunity = Test_Fixture_Factory.createTestOpportunity();
			testQuote = Test_Fixture_Factory.createTestQuote(testOpportunity.Id, '', 'Pending - Finance');
			testQuoteItem = [
				SELECT
					DiscountType__c,
					OverallStatus__c,
					OpportunityLineItemId__c,
					Category__c,
					Part_Number__c,
					CurrentStatus__c,
					Quantity__c,
					IsPromoProduct__c,
					TermLength__c,
					NumInstallments__c,
					Renewal_MRR_Original__c,
					NetNewMRR__c,
					AdjustedNRC__c,
					AdjustedMRC__c
				FROM SterlingQuoteItem__c
				WHERE SterlingQuote__c = :testQuote.Id
				LIMIT 1
			];

			testQuoteItem.Category__c = 'Equipment';
			testQuoteItem.Part_Number__c = '1234';
			testQuoteItem.CurrentStatus__c = 'Pending - Finance';
			testQuoteItem.Quantity__c = 1;
			testQuoteItem.IsPromoProduct__c = true;
			testQuoteItem.TermLength__c = 12;
			testQuoteItem.NumInstallments__c = 5;
			testQuoteItem.Renewal_MRR_Original__c = 0;
			testQuoteItem.NetNewMRR__c = 10.00;
			testQuoteItem.AdjustedNRC__c = 2.00;
			testQuoteItem.OverallStatus__c = 'Pending - Finance';
			testQuoteItem.RecordType = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'SterlingQuoteItem__c' AND name = 'SFA' LIMIT 1];
			testQuoteItem.AdjustedMRC__c = 12.00;
			testQuoteItem.Currentstatus__c = 'Pending - Finance';
			testQuoteItem.Overallstatus__c = 'Pending';
			testQuoteItem.DiscountType__c = 'None';
			update testQuoteItem;

			testOpportunityProduct = [
				SELECT
					CPE_Gross_Margin__c,
					CPE_NRC_Price__c,
					NRC_Price__c,
					Product2.Name,
					Service_Address__c,
					CPQ_NetNewMRR__c,
					Renewal_MRR__c,
					Speed__c,
					Quantity,
					OpportunityId,
					TotalPrice,
                    PricebookEntryId,
                    vlocity_cmt__ServiceAccountId__r.Name
				FROM OpportunityLineItem
				WHERE Id = :testQuoteItem.OpportunityLineItemId__c
			];
		}

     public static void createTestOpportunity(Id PriceBookId) {

        Account acc = new Account();
        acc.Name='testAccount';
        insert acc;
        
        opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Decision';
        opp.AccountId=acc.id;
        opp.CloseDate= System.today();
        opp.ForecastCategoryName='Commit';
        opp.Pricebook2Id = pricebookId;
        insert opp;
        
    }
    
    public static void createQuote() {
         RecordType quoteRecType = [SELECT Id FROM RecordType WHERE Name = 'Carrier Service' AND SobjectType = 'SterlingQuote__c' LIMIT 1];
        
        
       SterlingQuote__c  quote = new SterlingQuote__c(Name = 'Test Quote 1', 
                                                      RecordType = quoteRecType, 
                                                      OpportunityId__c = opp.Id, 
                                                      IsSyncing__c = true);
        
        insert quote;
    }
    
       public static FTRWSQuoteLineItemProdWrapper createWrapperItem(String circuitType, String prodName) {
        
        FTRWSQuoteLineItemProdWrapper wrapper = new FTRWSQuoteLineItemProdWrapper();
     	wrapper.id = 'TestSqId';
        wrapper.quantity = 1;
        
        wrapper.rfqString = System.now().format('yyyyMMddHHmmSS');
        wrapper.serviceType = 'Test';
        
        Integer term = 60;
        
        wrapper.termLength = '5 yr';
        
        wrapper.renewalMRR = 500.00;
        wrapper.netNewMRR = 500.00;
        wrapper.nrc = 100.00;
        wrapper.totalNRC = 100.00;
        wrapper.name = prodName;
        
        wrapper.adjustedNRC = 0.00;
        wrapper.cpenrc = 0.00;
        wrapper.nrc = 100.00;
        wrapper.totalNRC = 100.00;
        
        wrapper.qos = 'Platinum';
        wrapper.circuitType = circuitType;
        wrapper.tier = '1';
        wrapper.pNUM = 'EPATH123456';
        
        if(wrapper.circuitType == 'EVC') {
            wrapper.orderSeq = 1;
        } else if(wrapper.circuitType == 'UNI') {
            wrapper.orderSeq = 2;
        } else if(wrapper.circuitType == 'NNI') {
            wrapper.orderSeq = 3;
        }
        
        wrapper.totalMRC = 400.00;
        wrapper.totalCharge = 400.00;
        wrapper.serviceAddress = '2000 Solar Dr, Oxnard, CA';
        wrapper.zAddress = '';
  
        String prodType = 'EPATH';
        String speed = '2000';
        String qos = 'Platinum';
              
        return wrapper;
    }
}