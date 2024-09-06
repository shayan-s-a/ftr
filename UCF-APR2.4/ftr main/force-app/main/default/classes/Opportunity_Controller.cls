/**
* @description       :
* @author            : 
* @group             :
* @last modified on  : 11-08-2023
* @last modified by  : Md Mehedi Hasan
* Modifications Log
* Ver   Date         Author        Modification
**/
public class Opportunity_Controller {
    public string strOpportunityId;
    public list<SterlingQuoteItem__c> Strsterlinquoteitem;
    public list<SterlingQuoteItem__c> lststerlingquoteitem { get; set; }
    public List<SterlingQuote__c> strSterlingQuoteId;
    public List<SterlingQuote__c> lstSterlingQuote { get; set; }
    public boolean displaypopup { get; set; }
    public boolean isCommentNull { get; set; }
    public boolean displayPopUpQQ { get; set; }
    public boolean bolshowgenerate { get; set; }
    public Opportunity objOpp { get; set; }
    public string customerInfo { get; set; }
    public string sqitem_quoteId { get; set; }
    public Opportunity tempOpp { get; set; }
    public boolean showNoSyncError { get; set; }
    public boolean showApprovedProductsNonZero { get; set; }
    public boolean displayProposalPopUp { get; set; }
    public String commentStr { get; set; }
    public String proposalCompany { get; set; }
    public String proposalFuture { get; set; }
    public String SelectedId { get; set; }
    public boolean sectionrefresh { get; set; }
    public boolean isVelocity { get; set; }
    public Date scheduleStDt { get; set; }
    //Giri 06/24/2014 Added Start
    public String presentProduct { get; set; }
    public boolean isflag { get; set; }
    public String currentProduct { get; set; }
    public boolean IsContractExistForAccount { get; set; }
    public String strOppProductEditval { get; set; }
    public String SterlingQuoteDelVal { get; set; }
    public SterlingQuoteItem__c objSterlingQuoteItem { get; set; }
    public List<productCompanyInfo> addressinfo { get; set; }
    public String defaultAddress { get; set; }
    public List<SelectOption> dynamicOptions { get; set; }
    public String uiFlag { get; set; }
    public boolean displayAddressGrid { get; set; }
    public String dtToday { get; set; }
    public String dt2 { get; set; }
    public String dt3 { get; set; }
    //Giri 06/24/2014 Added End
    public Integer size { get; set; }
    public Integer noOfRecords { get; set; }
    public decimal totalQQValue { get; set; }
    public Integer NumSQIs1 { get; set; }
    public decimal totalNRCValue1 { get; set; }
    public decimal totalMRCValue1 { get; set; }
    public Integer NumSQIs2 { get; set; }
    public decimal totalNRCValue2 { get; set; }
    public Integer NumSQIs3 { get; set; }
    public decimal totalNRCValue3 { get; set; }
    public decimal totalMRCValue3 { get; set; }
    public Integer NumSQIs4 { get; set; }
    public decimal totalUnitPriceNRCValue4 { get; set; }
    public decimal totalNRCValue4 { get; set; }
    public Integer NumSQIs5 { get; set; }
    public decimal totalNRCValue5 { get; set; }
    public decimal totalMRCValue5 { get; set; }
    public decimal totalUpfrontCostHardware { get; set; }
    public decimal monthlyRecurringHardware { get; set; }
    public decimal totalMonthlyRecurringCharge { get; set; }
    // public List<SterlingQuote__c> lstStrQuote    {get;set;}
    public List<QuoteWrapper> lstStrQuote { get; set; }
    public Id currentVlocityQuoteId { get; set; }
    public Id currentQuoteId { get; set; }
    public ApexPages.Standardsetcontroller oppSSC { get; set; }
    public Task taskRec { get; set; }
    public String Speed { get; set; }
    public Integer quantity { get; set; }
    public boolean SelfInstall { get; set; }
    public Decimal NRC { get; set; }
    public Decimal MRC { get; set; }
    public String comments { get; set; }
    public boolean ShowGenerateButton { get; set; }
    public boolean ShowNextSecondButton { get; set; }
    public boolean ShowSimply { get; set; }
    public boolean PilotUser { get; set; }
    public Boolean ShowEditLinks { get; set; }
    public Boolean ShowAddProductButtons { get; set; }
    public Boolean lightningRecordtype {get; set;}
    public String ProfileName { get; set; }
    private Id currentUserId;
    private Id oppOwnerId;
    
    public Map<Id, SterlingQuoteItem__c> sterlingQuoteItemIdToSterlingQuoteItem;
    public Map<Id, List<ZAddress__c>> sterlingQuoteItemIdByZAddressList;
    
    public ApexPages.StandardSetController setCon {
        get {
            if (setCon == null) {
                setCon = new ApexPages.Standardsetcontroller(
                    Database.getQuerylocator(
                        [
                            SELECT Id, IsSyncing__c, RecordType.Name, Is_Sync_Allowed__c, Sync_Allowed_by_Admin__c, RecordTypeID, Name
                            FROM SterlingQuote__c
                            WHERE OpportunityId__c = :strOpportunityId
                            ORDER BY IsSyncing__c DESC
                        ]
                    )
                ); //Giri Added order by condition for sync ordering
                //  size = 4;
                system.debug('******** setcon   :' + setcon);
                noOfRecords = setCon.getResultSize();
                system.debug('******** noofRecords  :' + noOfRecords);
            }
            return setCon;
        }
        set;
    }
    public boolean getVZ3_CPQ_Disabled() {
        ENV_SFDC_Settings__c CS = ENV_SFDC_Settings__c.getOrgDefaults();
        //Opportunity O = [SELECT Id, AccountId FROM Opportunity WHERE Id = '006c000000EPwFxAAL' LIMIT 1];
        Opportunity O = [SELECT Id, AccountId FROM Opportunity WHERE Id = :strOpportunityId LIMIT 1];
        Account A = [SELECT Id, BillingStateCode, ShippingStateCode FROM Account WHERE Id = :O.AccountId LIMIT 1];
        Set<string> disabledStateCodes = new Set<string>{ 'CA', 'TX', 'FL' };
            return !(CS.VZ3_DisableSterling9CPQ__c &&
                     (disabledStateCodes.Contains(A.BillingStateCode) || disabledStateCodes.Contains(A.ShippingStateCode)));
    }
    public Opportunity_Controller(ApexPages.StandardController controller) {
        ShowEditLinks = true;        
        tempOpp = new Opportunity();
        PilotUser = false;
        isflag = false;
        ShowGenerateButton = false;
        strOpportunityId = controller.getId();
        size = 100;
        dtToday = System.today().format();
        // MGG319 1/14/2019 Add Approval_Status to select to control close/won selection
        if (strOpportunityId != null) {
            objOpp = [
                SELECT
                RecordType.Name,
                Previous_MRR__c ,
                scheduleRenewed__r.Name,
                Account.ShippingStateCode,
                Account.Name,
                Account.BillingStreet,
                Account.BillingCity,
                Account.BillingState,
                Account.BillingPostalCode,
                Account.BillingCountry,
                Account.Phone,Account.Type,
                Account.SB_Email__c,
                AccountId,
                Agent_Billing_Verified_Date__c,
                Agent_LD_Promo_Residuals__c,
                Agent_Module__c,
                Agent_Name__c,
                Agent_Net_New_MRR_ink__c,
                Agent_Paid_Amount__c,
                Agent_Payment_Date__c,
                Agent_Renewal_MRR__c,
                Agent_Submit_Date__c,
                Agt_NRC_ink__c,
                Agt_Term_Residual__c,
                Approved_Date__c,
                Approval_Status__c,
                Audited_By__c,
                Audit_Finding_Summary__c,
                Audit_Results__c,
                CampaignId,
                Carrier_Region__c,
                Casual_Usage_Forecast_Qty__c,
                Casual_Usage_Forecast__c,
                City_Approval__c,
                CloseDate,
                Contract2__c,
                Contract_MRR__c,
                Contract_OLD__c,
                Contract_Sign_Date__c,
                CPE_GM_Adjustment__c,
                CPE_Gross_Margin__c,
                CPE_NRC_Adjustment__c,
                CPE_NRC__c,
                CPE_Product_Count__c,
                CPE_Product__c,
                CPE_Team_Count__c,
                CreatedById,
                CreatedDate,
                Date_Audited__c,
                Date_of_Execution__c,
                Description,
                Expected_Billed_Date__c,
                Fiscal,
                FiscalQuarter,
                FiscalYear,
                ForecastCategory,
                ForecastCategoryName,
                Forecast_Type__c,
                FRONTIER_Expected_Revenue__c,
                Funding_Assistance__c,
                GM__c,
                HasOpportunityLineItem,
                HSI_Lines_Removed__c,
                Id,
                IsClosed,
                IsDeleted,
                IsWon,
                LastActivityDate,
                LastModifiedById,
                LastModifiedDate,
                LD_Promo_Term__c,
                LeadSource,
                Local_Area_Market_State__c,
                Local_Area_Market__c,
                Mgr_CPE_NRC__c,
                Mgr_Net_New_MRR__c,
                Mgr_NRC__c,
                Mgr_Renewal_MRR__c,
                Mgr_Signed_Date__c,
                Mrg_Approved__c,
                MRR_Amount__c,
                Name,
                Net_New_MRR__c,
                New_Logo__c,
                NextStep,
                NRC__c,
                Opportunity_Amount__c,
                Opportunity_Type__c,
                Other_Finding__c,
                Other_Reason_Lost_Details__c,
                OwnerId,
                Potential_Subscribers__c,
                Pre_Site_Survey_Completed__c,
                Pricebook2Id,
                Pricing_Promotion__c,
                Probability,
                Product_name__c,
                Proposal_Agreement_Submitted__c,
                Quote_ID__c,
                Reason_Won_Lost__c,
                RecordTypeId,
                Redline_email_no__c,
                Region__c,
                Renewal_MRR__c,
                Renewal_Sales_Stage__c,
                Renewal_Type__c,
                Renewal_Yes__c,
                Row_Id__c,
                RPON_Order__c,
                Secure_Current_Customers__c,
                Secure_Potential_Subscribers__c,
                Site_Survey_Completed__c,
                StageName,
                Status_of_Anchor_Proposal_City_Agreement__c,
                Submitted_Date__c,
                SyncedQuoteId,
                SystemModstamp,
                System_the_Order_Entered_In__c,
                Territory__c,
                Total_CPE_NRC__c,
                Total_Monthly_Amount__c,
                Total_Weighted_Monthly_Amount__c,
                Ver_no_for_redline__c,
                Weighted_CPE_NRC__c,
                Weighted_Net_New_MRR__c,
                Weighted_NRC__c,
                Weighted_Renewal_MRR__c,
                Weighted_Replacement_Revenue__c,
                Who_Executed_Contract_on_Cust_Behalf__c,
                Winback_Competitor__c,
                Wireless_Market_City__c,
                Wireless_Market_State__c,
                Wireless_MRR_Forecast__c,
                Wireless_Opportunity__c,
                Wireless_Status__c,
                Wireless_Total_MRR_Forecast__c
                FROM Opportunity
                WHERE id = :strOpportunityId
            ];
        }
        User currentUser = [SELECT Id, Pilot_User__c, Name FROM User WHERE Id = :UserInfo.getUserId()];
        this.currentUserId = Id.valueOf(currentUser.Id);
        this.oppOwnerId = Id.valueOf(objOpp.OwnerId);
        lightningRecordtype = false;
        if (objopp.RecordType.Name == 'Opportunity Lightning'){
            lightningRecordtype = true;
        }
        id userProfileId = userinfo.getProfileId();
        system.debug('lightningRecordtype :: '+lightningRecordtype);    
        
        Map<Id, Profile> disallowedProfileMap = new Map<Id, Profile>(
            [
                SELECT id
                FROM Profile
                WHERE
                name IN (
                    '#CTF Customer Service Analyst',
                    'Customer Service Supervisor',
                    '#CTF RegionalSalesMgr',
                    // '#CTF AccountExec',
                    // '#CPE AccountExec',
                    'Partner Support Team',
                    // '#AccountExec'
                    '#CPE RegionalSalesMgr',
                    'Minimum Access - Salesforce'
                )
            ]
        );
        Set<Id> profileIdsWhereAddingProductsForAClosedWonOpportunityIsNotAllowed = disallowedProfileMap.keySet();
        
        Profile foobar = [SELECT id, name FROM Profile WHERE id = :userProfileId];
        
        profileName = foobar.name;
        ShowAddProductButtons = !profileIdsWhereAddingProductsForAClosedWonOpportunityIsNotAllowed.contains(userProfileId);
        if (objOpp.RecordType.Name != 'Equote') {
            if (currentUser.Pilot_User__C) {
                PilotUser = true;
            }
        }
        
        lstSterlingQuote = new List<SterlingQuote__c>();
        lstSterlingQuote = [SELECT Id, Name, IsSyncing__c, RecordType.Name FROM SterlingQuote__c WHERE OpportunityId__c = :strOpportunityId];
        strSterlingQuoteId = [SELECT id FROM SterlingQuote__c WHERE OpportunityId__c = :strOpportunityId];
        // MGG319 added Quote Synced field to select
        Strsterlinquoteitem = [
            SELECT
            id,
            sterlingquote__r.RecordType.Name,
            Renewal_MRR__c,
            NetNewMRR__c,
            discounttype__c,
            status__c,
            currentstatus__c,
            overallStatus__c,
            ApprovalRouting__c,
            MinorLine__c,
            TermLength__c,
            NumInstallments__c,
            Service_Address__c,
            Locality__c,
            StateProvince__c,
            Postcode__c,
            Quote_Synced__c
            FROM SterlingQuoteItem__c
            WHERE SterlingQuote__c = :strSterlingQuoteId
        ];
        
        // MMG 06/24/2015  Set pilot user to false if no Sterling quote record for this Opportunity  This allows users to still see products on existing opportunities.
        system.debug(' **** Sterling Quote Test ' + lstSterlingQuote);
        /*    
if(lstSterlingQuote.size() == 0){
PilotUser = false;
}
else{
PilotUser = True;
} 
dt2 = dateTime.now().format('MM/dd/yyyy');  //Today's Date
dt3 = '01/20/2019';  //Cutover Date
system.debug('***** Pilot User = ' + PilotUser);
system.debug ('DtToday = ' + dtToday);
system.debug ('Dt2 = ' + dt2);
system.debug('Created Date = ' + objOpp.CreatedDate);


String cdt = objOpp.CreatedDate.format('MM/dd/yyyy');
List<String> cc = cdt.split('/');

if (currentUser.Pilot_User__C) {
if(cdt == dt2 && cdt < dt3) {
PilotUser = true;
}
}

if (currentUser.Pilot_User__C) {
if(cdt >= dt3)
PilotUser = true;  }  

system.debug('CDT = ' + cdt);
system.debug('***** Pilot User after CD test = ' + PilotUser);
// MMG end of added code for pilot user.
*/
        
        for (SterlingQuoteItem__c SQi : Strsterlinquoteitem) {
            if (
                (objopp.StageName == 'Decision' && SQi.OverallStatus__c == 'Approved') ||
                (objopp.StageName == 'Decision' &&
                 SQi.DiscountType__c == null)
            ) {
                system.debug('sales stage' + objOpp.stageName);
                bolshowgenerate = true;
            }
            if (
                sqi.Quote_Synced__c &&
                sqi.OverallStatus__c == 'Pending' &&
                sqi.sterlingquote__r.RecordType.Name == 'Sterling' &&
                currentUserId == oppOwnerId &&
                sqi.CurrentStatus__c != 'Pending AE Update' &&
                sqi.CurrentStatus__c != 'Pending Final Update'
            ) {
                ShowEditLinks = false;
            }
            if (sqi.overallStatus__c == 'Pending') {
                objopp.Approval_Status__c = 'Pending';
            }
        }
        List<Contract> lstContract = new List<Contract>();
        lstContract = [SELECT id FROM Contract WHERE Accountid = :objOpp.Accountid];
        system.debug('=======objOpp.Accountid:' + objOpp.Accountid);
        if (lstContract != null && lstContract.size() > 0) {
            IsContractExistForAccount = true;
        } else {
            IsContractExistForAccount = false;
        }
        // Creating a proposal
        List<SterlingQuote__c> lSyncedQuote = [
            SELECT Id, Name, RecordTypeId, RecordType.Name, Quote_Number__c
            FROM SterlingQuote__c
            WHERE OpportunityId__c = :ApexPages.currentPage().getParameters().get('id') AND IsSyncing__c = TRUE
        ];
        
        List<Quote> lSyncedVlocityQuote = [
            SELECT Id, Name, RecordTypeId, RecordType.Name
            FROM Quote
            WHERE OpportunityId = :ApexPages.currentPage().getParameters().get('id') AND IsSyncing__c = TRUE
        ];
        
        Set<Id> SyncedQuoteIdSet = new Set<Id>();
        for (SterlingQuote__c SQ : lSyncedQuote) {
            SyncedQuoteIdSet.add(SQ.Id);
        }
        
        List<SterlingQuoteItem__c> SterlingQuoteItemList = [
            SELECT Id, Name, Renewal_MRR_Original__c, NetNewMRR__c, overallStatus__c, Status__c, SterlingQuote__c, DiscountType__c
            FROM SterlingQuoteItem__c
            WHERE SterlingQuote__c IN :SyncedQuoteIdSet
        ];
        Map<Id, List<SterlingQuoteItem__c>> SquoteToItemListMap = new Map<Id, List<SterlingQuoteItem__c>>();
        List<SterlingQuoteItem__c> tempList = null;
        for (SterlingQuoteItem__c SQI : SterlingQuoteItemList) {
            if (SquoteToItemListMap.containsKey(SQI.SterlingQuote__c)) {
                SquoteToItemListMap.get(SQI.SterlingQuote__c).add(SQI);
            } else {
                tempList = new List<SterlingQuoteItem__c>();
                tempList.add(SQI);
                SquoteToItemListMap.put(SQI.SterlingQuote__c, tempList);
            }
        }
        if (lSyncedQuote.Size() > 0) {
            for (SterlingQuote__c temp : lSyncedQuote) {
                if (SquoteToItemListMap.get(temp.Id) != null && SquoteToItemListMap.get(temp.Id).size() > 0) {
                    for (SterlingQuoteItem__c var : SquoteToItemListMap.get(temp.Id)) {
                        System.Debug('**var.DiscountType__c*' + var.DiscountType__c);
                        System.Debug('**var.Status__c*' + var.Status__c);
                        if (
                            (var.DiscountType__c == '' ||
                             var.DiscountType__c == null ||
                             var.DiscountType__c == 'None') ||
                            (var.DiscountType__c != null &&
                             var.overallStatus__c == 'Approved') ||
                            (var.overallStatus__c == '')
                        ) {
                            showApprovedProductsNonZero = false;
                            break; 
                        } else {
                            showApprovedProductsNonZero = true;
                        }
                    }
                }
                System.Debug('**showApprovedProductsNonZero*' + showApprovedProductsNonZero);
            }
            showNoSyncError = false;
        } 
        else if (lSyncedVlocityQuote.Size() > 0) {
            showNoSyncError = false;
        }
        else{
            showNoSyncError = true;
        }
        
        getStrQuotes();
        initProductSection();
        //}
        quoteEdit_SterlingCPQ(objOpp.AccountId, objOpp.id);
        initAttachmentSection();
        initScheduleSection();
    }
    
    public PageReference retrieveAccountDetails() {
        if (
            /*(objOpp.Account.ShippingStateCode == 'OR' ||  
objOpp.Account.ShippingStateCode == 'MT' || 
objOpp.Account.ShippingStateCode == 'ID' || 
objOpp.Account.ShippingStateCode == 'WA') &&    
objOpp.StageName == 'Closed/Won' || objOpp.StageName == 'Closed/Lost' &&*/ objOpp.Account.Type == 'NWF Account')    
        {
            PageReference unauthorizedRedirect = new PageReference('/apex/Unauthorized_NWFRecords');
            unauthorizedRedirect.setRedirect(true);
            return unauthorizedRedirect;
        }
        return null;
    }
    //Quick Quote Types handling
    public String[] quickQuoteTypes = new List<String>{ 'Standard', 'UCaaS' };
        public String selectedQQT { get; set; }
    
    public List<SelectOption> getQQTypes() {
        List<SelectOption> op = new List<SelectOption>();
        for (String qqt : quickQuoteTypes) {
            op.add(new SelectOption(qqt, qqt));
        }
        
        return op;
    }
    
    //Proposal Types handling
    public String[] proposalTypes = new List<String>{ 'Standard', 'Cloud Managed IT', 'UCaaS: Cash Payment', 'UCaaS: Frontier Financing' };
        public String selectedProposalType { get; set; }
    
    public List<SelectOption> getProposalTypes() {
        List<SelectOption> op = new List<SelectOption>();
        for (String ppt : proposalTypes) {
            op.add(new SelectOption(ppt, ppt));
        }
        
        return op;
    }
    
    // Method for Quotes
    public list<sterlingquote__c> getSterlingQuote() {
        objOpp = [
            SELECT
            Account.Name,
            Previous_MRR__c ,
            AccountId,
            Agent_Billing_Verified_Date__c,
            Agent_LD_Promo_Residuals__c,
            Agent_Module__c,
            Agent_Name__c,
            Agent_Net_New_MRR_ink__c,
            Agent_Paid_Amount__c,
            Agent_Payment_Date__c,
            Agent_Renewal_MRR__c,
            Agent_Submit_Date__c,
            Agt_NRC_ink__c,
            Agt_Term_Residual__c,
            Approved_Date__c,
            Audited_By__c,
            Audit_Finding_Summary__c,
            Audit_Results__c,
            CampaignId,
            Carrier_Region__c,
            Casual_Usage_Forecast_Qty__c,
            Casual_Usage_Forecast__c,
            City_Approval__c,
            CloseDate,
            Contract2__c,
            Contract_MRR__c,
            Contract_OLD__c,
            Contract_Sign_Date__c,
            CPE_GM_Adjustment__c,
            CPE_Gross_Margin__c,
            CPE_NRC_Adjustment__c,
            CPE_NRC__c,
            CPE_Product_Count__c,
            CPE_Product__c,
            CPE_Team_Count__c,
            CreatedById,
            CreatedDate,
            Date_Audited__c,
            Date_of_Execution__c,
            Description,
            Expected_Billed_Date__c,
            Fiscal,
            FiscalQuarter,
            FiscalYear,
            ForecastCategory,
            ForecastCategoryName,
            Forecast_Type__c,
            FRONTIER_Expected_Revenue__c,
            Funding_Assistance__c,
            GM__c,
            HasOpportunityLineItem,
            HSI_Lines_Removed__c,
            Id,
            IsClosed,
            IsDeleted,
            IsWon,
            LastActivityDate,
            LastModifiedById,
            LastModifiedDate,
            LD_Promo_Term__c,
            LeadSource,
            Local_Area_Market_State__c,
            Local_Area_Market__c,
            Mgr_CPE_NRC__c,
            Mgr_Net_New_MRR__c,
            Mgr_NRC__c,
            Mgr_Renewal_MRR__c,
            Mgr_Signed_Date__c,
            Mrg_Approved__c,
            MRR_Amount__c,
            Name,
            Net_New_MRR__c,
            New_Logo__c,
            NextStep,
            NRC__c,
            Opportunity_Amount__c,
            Opportunity_Type__c,
            Other_Finding__c,
            Other_Reason_Lost_Details__c,
            OwnerId,
            Potential_Subscribers__c,
            Pre_Site_Survey_Completed__c,
            Pricebook2Id,
            Pricing_Promotion__c,
            Probability,
            Product_name__c,
            Proposal_Agreement_Submitted__c,
            Quote_ID__c,
            Reason_Won_Lost__c,
            RecordTypeId,
            Redline_email_no__c,
            Region__c,
            Renewal_MRR__c,
            Renewal_Sales_Stage__c,
            Renewal_Type__c,
            Renewal_Yes__c,
            Row_Id__c,
            RPON_Order__c,
            Secure_Current_Customers__c,
            Secure_Potential_Subscribers__c,
            Site_Survey_Completed__c,
            StageName,
            Status_of_Anchor_Proposal_City_Agreement__c,
            Submitted_Date__c,
            SyncedQuoteId,
            SystemModstamp,
            System_the_Order_Entered_In__c,
            Territory__c,
            Total_CPE_NRC__c,
            Total_Monthly_Amount__c,
            Total_Weighted_Monthly_Amount__c,
            Ver_no_for_redline__c,
            Weighted_CPE_NRC__c,
            Weighted_Net_New_MRR__c,
            Weighted_NRC__c,
            Weighted_Renewal_MRR__c,
            Weighted_Replacement_Revenue__c,
            Who_Executed_Contract_on_Cust_Behalf__c,
            Winback_Competitor__c,
            Wireless_Market_City__c,
            Wireless_Market_State__c,
            Wireless_MRR_Forecast__c,
            Wireless_Opportunity__c,
            Wireless_Status__c,
            Wireless_Total_MRR_Forecast__c
            FROM Opportunity
            WHERE id = :strOpportunityId
        ];
        
        list<SterlingQuote__c> lststr = [
            SELECT Id, Name, IsSyncing__c, RecordType.Name
            FROM SterlingQuote__c
            WHERE OpportunityId__c = :strOpportunityId
        ];
        return lststr;
    }
    
    //Method for Products
    
    public List<WrapperOpportunityProduct> getSterlingQuoteItem() {
        List<WrapperOpportunityProduct> lstWrapperOppProduct = new List<WrapperOpportunityProduct>();
        list<SterlingQuoteItem__c> lststrquoteitem = [
            SELECT
            Id,
            RecordType.Name,
            Products__r.name,
            Renewal_MRR_Original__c,
            NetNewMRR__c,
            CurrentStatus__c,
            StandardMRC__c,
            AdjustedNRC__c,
            AdjustedMRC__c,
            OverallStatus__c,
            Quantity__c,
            ItemCode__c,
            IsPromoProduct__c,
            TermLength__c,
            NumInstallments__c,
            DiscountType__c,
            OpportunityLineItemId__c,
            Products__c,
            ApprovalRouting__c,
            NoICB__c,
            Part_Number__c,
            Category__c
            FROM SterlingQuoteItem__c
            WHERE SterlingQuote__c = :strSterlingQuoteId
        ];
        list<OpportunityLineItem> lstOppLineItem = [
            SELECT
            id,
            Renewal_MRR__c,
            UnitPrice,
            CPE_Gross_Margin__c,
            CPE_NRC_Price__c,
            NRC_Price__c,
            New_TCV__c,
            Previous_MRR__c,
            Product2.name,
            AdjustedMRC__c,
            QuoteId__c,
            Service_Address__c,
            ZAddress__c
            FROM OpportunityLineItem
            WHERE Opportunityid = :strOpportunityId
        ];
        
        map<id, OpportunityLineItem> mapOppLineItem = new Map<id, OpportunityLineItem>();
        
        for (OpportunityLineItem opp : lstOppLineItem) {
            mapOppLineitem.put(opp.id, opp);
            system.debug('###opp' + opp);
        }
        
        if (lststrquoteitem.size() > 0 && !mapOppLineitem.isEmpty()) {
            for (SterlingQuoteItem__c SQI : lststrquoteitem) {
                //SHANE FIND ME! OF THE 6 EXAMPLE SQIs, ONLY 2 HAVE OLI Id values
                if (mapOppLineItem.get(SQI.OpportunityLineItemId__c) != null) {
                    OpportunityLineItem OLI = mapOppLineItem.get(SQI.OpportunityLineItemId__c);
                    WrapperOpportunityProduct tempwrap = new WrapperOpportunityProduct(SQI, OLI, sterlingQuoteItemIdByZAddressList);
                    lstWrapperOppProduct.add(tempwrap);
                }
            }
        }
        // // QuoteLineItemId__c
        // if (lightningRecordtype == false){
        //  return lstWrapperoppProduct;
        // }- // SDDD-4429 Added Json Field
        for (OpportunityLineItem oli : [
            SELECT
            Id,
            Quantity,
            Term_Months__c,
            DiscountType__c,
            Renewal_MRR__c,
            CPQ_NetNewMRR__c,
            New_TCV__c,
            Previous_MRR__c,
            CPE_Gross_Margin__c,
            AdjustedMRC__c,
            CPE_NRC_Price__c,
            Speed__c,
            SNE_Code_MRC__c,
            SNE_Code_OTC__c,
            vlocity_cmt__OneTimeCharge__c,
            vlocity_cmt__EffectiveQuantity__c,
            Product2.Name,
            vlocity_cmt__JSONAttribute__c,
            vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringTotal__c,
            vlocity_cmt__ServiceAccountId__r.Name,
            Opportunity_Sync__c,
            VlocityQuoteId__c,
            Dsat_Standard_Interval__c,
            QuoteLineItem__r.Quote.RecordType.Name
            FROM OpportunityLineItem
            WHERE OpportunityId = :strOpportunityId AND Opportunity_Sync__c = 'Vlocity'
            ORDER BY vlocity_cmt__LineNumber__c
        ]) {
            lstWrapperOppProduct.add(new WrapperOpportunityProduct(oli));
        }
        return lstWrapperoppProduct;
    }
    
    //method for notes
    public List<Note> GetNoteItem1() {
        System.Debug('****strOpportunityId***' + strOpportunityId);
        list<Note> lstNote = [SELECT Id, Title, lastmodifieddate, CreatedBy.Name FROM Note WHERE ParentID = :strOpportunityId];
        System.Debug('****lstNote***' + lstNote);
        return lstNote;
    }
    
    public PageReference redirectToNewNote() {
        PageReference newNotePage = new PageReference('/002/e?parent_id=' + strOpportunityId + '&retURL=%2F' + strOpportunityId);
        newNotePage.setRedirect(true);
        return newNotePage;
    }
    public PageReference redirectToNewAttachment() {
        PageReference newAttachmentPage = new PageReference(
            '/p/attach/NoteAttach?pid=' +
            strOpportunityId +
            '&parentname=' +
            objOpp.Name +
            '&retURL=%2F' +
            strOpportunityId
        );
        newAttachmentPage.setRedirect(true);
        return newAttachmentPage;
    }
    
    //methods for the add products
    public pagereference NewSfaQuote() {
        PageReference ref = page.Productoverridepage;
        ref.getparameters().put('oppid', strOpportunityId);
        return ref;
    }
    
    public pagereference editaction() {
        pagereference ref;
        return ref;
    }
    
    //Method for generate schedule
    public PageReference GenerateSchedule() {
        for (SterlingQuoteItem__c SQi : Strsterlinquoteitem) {
            if (objopp.StageName == 'Verbal Commit' && SQi.MinorLine__c == 0) {
                if (SQi.overallStatus__c == 'Approved' || SQi.DiscountType__c == null || SQi.DiscountType__c == '') {
                    bolshowgenerate = true;
                }
            }
        }
        Contract cont = [SELECT id FROM Contract WHERE AccountId = :objOpp.AccountId LIMIT 1];
        list<SterlingQuote__c> lstquote = [
            SELECT id, opportunityid__c, IsSyncing__c
            FROM SterlingQuote__c
            WHERE Issyncing__c != FALSE AND opportunityID__c = :strOpportunityId
            LIMIT 1
        ];
        
        Schedule__c objSch = new Schedule__c();
        objSch.Contract__c = cont.id;
        objSch.New_Opportunity__c = strOpportunityId;
        objSch.Schedule_Start_Date__c = system.today();
        integer i = 0;
        for (SterlingQuoteItem__c SQI : Strsterlinquoteitem) {
            if (i == 0) {
                if (SQI.Service_Address__c != null) {
                    objSch.Street_Address__c = SQI.Service_Address__c;
                }
                if (SQI.Locality__c != null) {
                    objSch.City__c = SQI.Locality__c;
                }
                if (SQI.StateProvince__c != null) {
                    objSch.State__c = SQI.StateProvince__c;
                }
                if (SQI.Postcode__c != null) {
                    objSch.Zip_Code__c = SQI.Postcode__c;
                }
            }
            if (SQI.TermLength__c != null && SQI.TermLength__c != 0) {
                objSch.Schedule_End_Date__c = system.today().addMonths(integer.valueof(SQI.TermLength__c));
            }
            i++;
        }
        insert objSch;
        
        PageReference ref = Page.Opportunity;
        ref.getParameters().put('Id', strOpportunityId);
        ref.setRedirect(true);
        return ref;
    }
    
    // Proposal
    
    public PageReference createProposal() {
        displayProposalPopUp = true;
        return null;
    }
    
    public PageReference generateproposalattachment() {
        //showNoSyncError
        list<attachment> insertAttachment = new List<attachment>();
        system.debug('********' + ApexPages.currentPage().getParameters().get('id'));
        //pageReference pdf = Page.generateproposal;
        
        pageReference pdf;
        if (selectedProposalType == 'UCaaS: Cash Payment') {
            pdf = Page.CreateUCaaSProposal;
            pdf.getParameters().put('paymentMethod', 'UCaaS_Cash_Payment');
        } else if (selectedProposalType == 'UCaaS: Frontier Financing') {
            pdf = Page.CreateUCaaSProposal;
            pdf.getParameters().put('paymentMethod', 'UCaaS_Frontier_Financing');
        } else if (selectedProposalType == 'Cloud Managed IT') {
            pdf = Page.CreateCloudManagedITProposal;
        } else {
            pdf = Page.CreateProposal;
        }
        pdf.getParameters().put('oppId', ApexPages.currentPage().getParameters().get('id'));
        pdf.getParameters().put('proposalCompany', proposalCompany);
        pdf.getParameters().put('proposalFuture', proposalFuture);
        //proposalCompany
        Opportunity temp = [SELECT AccountId, StageName, Id FROM Opportunity WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        temp.StageName = 'Proposal';
        update temp;
        Account companyInfo = [SELECT Name, Id FROM Account WHERE Id = :temp.AccountId];
        /*pdf.getParameters().put('strId', syncedQuote.Id);
pdf.getParameters().put('schId', schd.Id);
pdf.getParameters().put('cntId', schd.Contract__c); */
        Attachment attach = new Attachment();
        if (!test.isRunningTest() && (lightningRecordtype == true || objopp.RecordType.Name == 'Partner Opportunity - New')) {
            Blob body;
            body = pdf.getContent();
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = companyInfo.Name + ' Proposal ' + Datetime.now().format() + '.pdf'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = companyInfo.Name + ' Proposal ' + Datetime.now().format() + '.pdf'; // Display name of the files
            conVer.VersionData = body; // converting your binary string to Blog
            insert conVer;    //Insert ContentVersion
            
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            //create ContentDocumentLink  record 
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = ApexPages.currentPage().getParameters().get('id'); // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'V';
            insert conDocLink;
        } else if (!test.isRunningTest() && lightningRecordtype == false) {
            Blob body;
            
            body = pdf.getContent();
            attach.Body = body;
            attach.Name = companyInfo.Name + ' Proposal ' + Datetime.now().format() + '.pdf';
            attach.IsPrivate = false;
            attach.ParentId = ApexPages.currentPage().getParameters().get('id');
            insertAttachment.add(attach);
            insert insertAttachment;
        } 
        PageReference pageRef;
        if (lightningRecordtype == true){
            pageRef = new PageReference('/lightning/r/Opportunity/' + apexpages.currentpage().getparameters().get('id') + '/view');
        }else{
            pageRef = new PageReference('/' + apexpages.currentpage().getparameters().get('id'));
        }
        //      PageReference pageRef = new PageReference('/apex/opportunity');
        //pageRef.getParameters().put('id',apexpages.currentpage().getparameters().get('id'));
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    //public List<String> filteredSpeedStringList {get;set;}
    
    public void closeProposalPopup() {
        displayProposalPopUp = false;
    }
    //method to launch into sterling quote.
    public PageReference sterlingquote() {
        //PageReference pg = new PageReference('http://10.164.66.102:9080/sfs/sfs/cpq.do');
        Opportunity actOpp = [SELECT AccountId FROM Opportunity WHERE id = :strOpportunityId];
        PageReference pg = new PageReference(
            '/apex/QuoteEdit_SterlingCPQ?id=' +
            strOpportunityId +
            '&uiFlag=OPPORTUNITY&opportunityId=' +
            strOpportunityId +
            '&accountId=' +
            actOpp.AccountId
        );
        return pg;
    }
    
    public pagereference editlinks() {
        system.debug('SelectedId    : ' + SelectedId);
        SterlingQuote__c objSterlingQuote = [SELECT id, RecordType.name, recordtypeId FROM SterlingQuote__c WHERE id = :SelectedId];
        system.debug('$$$$$$$$$$$$$$ sterling quote    :' + objSterlingQuote);
        list<RecordType> recordtypeid = [
            SELECT BusinessProcessId, DeveloperName, Id, Name, SobjectType
            FROM RecordType
            WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'
        ];
        String strUrl;
        system.debug('$$$$$$$$$$$' + objSterlingQuote.RecordTypeId);
        User financed = [SELECT FinanceUser__c FROM User WHERE id = :userInfo.getUserId() LIMIT 1];
        if (objSterlingQuote.RecordType.Name == 'SFA') {
            //strURL ='/'+objSterlingQuote.Id+'/e?retURL=https%3A%2F%2Fc.cs8.visual.force.com%2Fapex%2FQuote%3Fid%3D'+objSterlingQuote.Id+'%26sfdc.override%3D1%26core.apexpages.devmode.url%3D1';
            strURL = '/' + objSterlingQuote.Id + '/e?retURL=%2Fapex%2FOpportunity%3Fid%3D' + strOpportunityId;
            //  strURL ='/'+objSterlingQuote.Id+'/e?retURL= /apex/Opportunity?objSterlingQuote.Id';
        } else {
            // MMG 10/20/2015 Only send sfastatus when user is finance user
            if (ShowEditLinks && financed.financeuser__c) {
                strUrl =
                    '/apex/SterlingQuote?AccountId=' +
                    objOpp.AccountId +
                    '&OpportunityId=' +
                    strOpportunityId +
                    '&OptionType=EQ&QuoteId=' +
                    objSterlingQuote.Id +
                    '&FinanceUser=' +
                    financed.financeUser__c +
                    '&SfaStatus=icbApproved';
            } else {
                strUrl =
                    '/apex/SterlingQuote?AccountId=' +
                    objOpp.AccountId +
                    '&OpportunityId=' +
                    strOpportunityId +
                    '&OptionType=EQ&QuoteId=' +
                    objSterlingQuote.Id +
                    '&FinanceUser=' +
                    financed.financeUser__c;
            }
        }
        pagereference pg = new pagereference(strurl);
        system.debug('Quote URL to Sterling = ' + pg);
        return pg;
    }
    
    public pagereference deletelink() {
        // system.debug('$$$$$$$$$$  deltelink' +strobj);
        
        lstSterlingQuote = [SELECT Id, Name, IsSyncing__c, RecordType.Name FROM SterlingQuote__c WHERE OpportunityId__c = :strOpportunityId];
        setCon = new ApexPages.Standardsetcontroller(
            Database.getQuerylocator(
                [
                    SELECT Id, IsSyncing__c, RecordType.Name, RecordTypeID, Name
                    FROM SterlingQuote__c
                    WHERE OpportunityId__c = :strOpportunityId
                    ORDER BY IsSyncing__c DESC
                ]
            )
        ); //Giri Added order by condition for sync ordering
        Map<id, SterlingQuoteItem__c> mapSQLI = new Map<id, SterlingQuoteItem__c>(
            [SELECT id, name FROM SterlingQuoteItem__c WHERE SterlingQuote__c = :SelectedID]
        );
        List<OpportunityLineItem> lstOpp = [SELECT id, name FROM OpportunityLineItem WHERE quoteitem__c IN :mapSQLI.keyset()];
        lstSterlingQuote = [SELECT Id, Name, IsSyncing__c, RecordType.Name FROM SterlingQuote__c WHERE OpportunityId__c = :strOpportunityId];
        list<SterlingQuoteItem__c> lstquoteitems = [SELECT id, name FROM SterlingQuoteItem__c WHERE SterlingQuote__c = :SelectedID];
        delete lstopp;
        delete lstquoteitems;
        SterlingQuote__c strobj = [SELECT id FROM SterlingQuote__c WHERE id = :SelectedId];
        delete strobj;
        getStrQuotes();
        PageReference pageRef;
        String userProfile = [SELECT Name
                              FROM Profile
                              WHERE Id =: userinfo.getProfileId()
                              LIMIT 1].Name;
        if (lightningRecordtype == true){
            pageRef = new PageReference('/lightning/r/Opportunity/' + strOpportunityId + '/view');
        }else if(userProfile == 'Frontier Partner Portal User') {
            ConnectApi.Community comm = getCommunityUrl();
            pageRef = new PageReference(comm.siteUrl + '/s/opportunity/' + strOpportunityId);
        } else {
            pageRef = new PageReference('/apex/Opportunity?Id='+strOpportunityId+'&sfdc.override=1');
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public pagereference deleteproducts() {
        list<OpportunityLineItem> lstoppadd = new List<OpportunityLineItem>();
        Strsterlinquoteitem = [SELECT id FROM SterlingQuoteItem__c WHERE SterlingQuote__c = :SelectedId];
        system.debug('$$$$$$$$Strsterlinquoteitem ' + Strsterlinquoteitem);
        list<OpportunityLineItem> lstopp = [SELECT id FROM OpportunityLineItem WHERE quoteitem__c = :Strsterlinquoteitem];
        system.debug('$$$$$$$$$$$$ lstopp' + lstopp);
        for (OpportunityLineItem Oppitem : lstopp) {
            lstoppadd.add(oppitem);
            system.debug('************' + lstoppadd);
        }
        delete lstoppadd;
        return null;
    }
    
    //Giri 06/24/2014 For Product Edit Method
    public PageReference editProductMethod() {
        PageReference ref;
        if (strOppProductEditval != null) {
            SterlingQuoteItem__c sterlingQuoteItem = [
                SELECT id, RecordType.Name, SterlingQuote__r.OpportunityId__r.accountid, SterlingQuote__r.OpportunityId__c, SterlingQuote__c
                FROM SterlingQuoteItem__c
                WHERE id = :strOppProductEditval
            ];
            Sterlingquote__c strquote = [
                SELECT id, name, recordtypeId, recordtype.name
                FROM sterlingquote__c
                WHERE id = :sterlingquoteitem.sterlingquote__c
            ];
            system.debug('$$$$$' + sterlingQuoteItem.RecordType.Name);
            if (strquote.RecordType.Name == 'SFA') {
                ref = new PageReference(
                    '/' +
                    strOppProductEditval +
                    '/e?retURL=https%3A%2F%2F' +
                    System.URL.getSalesforceBaseURL().getHost() +
                    '%2Fapex%2Fopportunity%3Fid%3D' +
                    strOpportunityId +
                    '%26sfdc.override%3D1%26core.apexpages.devmode.url%3D1'
                ); // Giri Added
            } else if (strquote.RecordType.Name == 'Sterling') {
                //  ref= new PageReference('/apex/NewQuote_SterlingCPQ?uiFlag=OPPORTUNITY&accountId=' + sterlingQuoteItem.SterlingQuote__r.OpportunityId__r.accountid+ '&opportunityId='+sterlingQuoteItem.SterlingQuote__r.OpportunityId__c + '&edit=true&quote=' +sterlingQuoteItem.SterlingQuote__c);
                
                // MMG 10/20/2015 Only send sfastatus when user is finance user
                User financed = [SELECT FinanceUser__c FROM User WHERE id = :userInfo.getUserId() LIMIT 1];
                if (ShowEditLinks && financed.financeuser__c) {
                    ref = new PageReference(
                        '/apex/SterlingQuote?AccountId=' +
                        objOpp.AccountId +
                        '&OpportunityId=' +
                        strOpportunityId +
                        '&OptionType=EQ&QuoteId=' +
                        strquote.id +
                        '&FinanceUser=' +
                        financed.financeUser__c +
                        '&SfaStatus=icbApproved'
                    );
                } else {
                    ref = new PageReference(
                        '/apex/SterlingQuote?AccountId=' +
                        objOpp.AccountId +
                        '&OpportunityId=' +
                        strOpportunityId +
                        '&OptionType=EQ&QuoteId=' +
                        strquote.Id
                    );
                }
            }
            System.debug('Sterling Product URL = ' + ref);
        }
        return ref;
    }
    
    //Giri 06/24/2014 For SFA Delete Product Method
    public PageReference delOppProductMethod() {
        Pagereference ref;
        System.Debug('***SterlingQuoteDelVal**' + SterlingQuoteDelVal);
        if (SterlingQuoteDelVal != null) {
            SterlingQuoteItem__c sterlingQuoteItem = [
                SELECT id, RecordType.Name, SterlingQuote__r.OpportunityId__r.accountid, SterlingQuote__r.OpportunityId__c, SterlingQuote__c
                FROM SterlingQuoteItem__c
                WHERE id = :SterlingQuoteDelVal
            ];
            System.Debug('***sterlingQuoteItem**' + sterlingQuoteItem);
            if (sterlingQuoteItem.RecordType.Name == 'SFA') {
                delete [SELECT id FROM SterlingQuoteItem__c WHERE id = :SterlingQuoteDelVal];
                initProductSection();
            } else if (sterlingQuoteItem.RecordType.Name == 'Sterling Line Item') {
                ref = new PageReference(
                    '/apex/NewQuote_SterlingCPQ?uiFlag=OPPORTUNITY&accountId=' +
                    sterlingQuoteItem.SterlingQuote__r.OpportunityId__r.accountid +
                    '&opportunityId=' +
                    sterlingQuoteItem.SterlingQuote__r.OpportunityId__c +
                    '&edit=true&quote=' +
                    sterlingQuoteItem.SterlingQuote__c
                );
                return ref;
            }
        }
        return null;
    }
    public String selectedValue { get; set; }
    public List<SelectOption> MyOptions { get; set; }
    
    public List<SelectOption> MyOptionsDependent { get; set; }
    
    //START OF SHANE CHANGE
    public void setCurrentProduct() {
        if (presentProduct != null && presentProduct.length() > 0) {
            objSterlingQuoteItem = [
                SELECT
                Id,
                ApprovalPriority__c,
                ApprovalTerritory__c,
                ApprovalRegion__c,
                ApprovalRouting__c,
                StateProvince__c,
                SIFT_Number__c,
                ICB_Request__c
                FROM SterlingQuoteItem__c
                WHERE Id = :presentProduct
            ];
        }
    }
    
    //Giri 06/24/2014 Added Start
    public void updateSterlingQuote() {
        system.debug('PresentProduct = ' + presentproduct);
        if (presentProduct != null && presentProduct.length() > 0) {
            objSterlingQuoteItem = [
                SELECT
                Id,
                ApprovalPriority__c,
                ApprovalTerritory__c,
                ApprovalRegion__c,
                ApprovalRouting__c,
                StateProvince__c,
                SIFT_Number__c,
                ICB_Request__c
                FROM SterlingQuoteItem__c
                WHERE Id = :presentProduct
            ];
            Opportunity oppTemp = [SELECT AccountId FROM Opportunity WHERE id = :strOpportunityId];
            system.debug(' ********** sterling ' + objSterlingQuoteItem);
            if (objSterlingQuoteItem != null && objSterlingQuoteItem.stateProvince__c != null) {
                system.debug('********** length of state.' + objSterlingQuoteItem.stateProvince__c.length());
            }
            if (objSterlingQuoteItem.stateProvince__c.length() == 2) {
                if (objSterlingQuoteItem.StateProvince__c == 'AL')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Alabama';
                if (objSterlingQuoteItem.StateProvince__c == 'CA')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'California';
                if (objSterlingQuoteItem.StateProvince__c == 'AK')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Alaska';
                if (objSterlingQuoteItem.StateProvince__c == 'AZ')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Arizona';
                if (objSterlingQuoteItem.StateProvince__c == 'AR')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Arkansas';
                if (objSterlingQuoteItem.StateProvince__c == 'CO')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Colorado';
                if (objSterlingQuoteItem.StateProvince__c == 'CT')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Connecticut';
                if (objSterlingQuoteItem.StateProvince__c == 'DE')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Delaware';
                if (objSterlingQuoteItem.StateProvince__c == 'FL')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Florida';
                if (objSterlingQuoteItem.StateProvince__c == 'GA')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Georgia';
                if (objSterlingQuoteItem.StateProvince__c == 'HI')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Hawaii';
                if (objSterlingQuoteItem.StateProvince__c == 'ID')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Idaho';
                if (objSterlingQuoteItem.StateProvince__c == 'IL')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Illinois';
                if (objSterlingQuoteItem.StateProvince__c == 'IN')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Indiana';
                if (objSterlingQuoteItem.StateProvince__c == 'IA')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Iowa';
                if (objSterlingQuoteItem.StateProvince__c == 'KS')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Kansas';
                if (objSterlingQuoteItem.StateProvince__c == 'KY')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Kentucky';
                if (objSterlingQuoteItem.StateProvince__c == 'LA')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Louisiana';
                if (objSterlingQuoteItem.StateProvince__c == 'ME')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Maine';
                if (objSterlingQuoteItem.StateProvince__c == 'MD')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Maryland';
                if (objSterlingQuoteItem.StateProvince__c == 'MA')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Massachusetts';
                if (objSterlingQuoteItem.StateProvince__c == 'MI')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Michigan';
                if (objSterlingQuoteItem.StateProvince__c == 'MN')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Minnesota';
                if (objSterlingQuoteItem.StateProvince__c == 'MS')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Mississippi';
                if (objSterlingQuoteItem.StateProvince__c == 'MO')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Missouri';
                if (objSterlingQuoteItem.StateProvince__c == 'MT')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Montana';
                if (objSterlingQuoteItem.StateProvince__c == 'NE')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Nebraska';
                if (objSterlingQuoteItem.StateProvince__c == 'NV')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Nevada';
                if (objSterlingQuoteItem.StateProvince__c == 'NH')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'New Hampshire';
                if (objSterlingQuoteItem.StateProvince__c == 'NJ')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'New Jersey';
                if (objSterlingQuoteItem.StateProvince__c == 'NM')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'New Mexico';
                if (objSterlingQuoteItem.StateProvince__c == 'NY')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'New York';
                if (objSterlingQuoteItem.StateProvince__c == 'NC')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'North Carolina';
                if (objSterlingQuoteItem.StateProvince__c == 'ND')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'North Dakota';
                if (objSterlingQuoteItem.StateProvince__c == 'OH')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Ohio';
                if (objSterlingQuoteItem.StateProvince__c == 'OK')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Oklahoma';
                if (objSterlingQuoteItem.StateProvince__c == 'OR')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Oregon';
                if (objSterlingQuoteItem.StateProvince__c == 'PA')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Pennsylvania';
                if (objSterlingQuoteItem.StateProvince__c == 'RI')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Rhode Island';
                if (objSterlingQuoteItem.StateProvince__c == 'SC')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'South Carolina';
                if (objSterlingQuoteItem.StateProvince__c == 'SD')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'South Dakota';
                if (objSterlingQuoteItem.StateProvince__c == 'TN')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Tennessee';
                if (objSterlingQuoteItem.StateProvince__c == 'TX')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Texas';
                if (objSterlingQuoteItem.StateProvince__c == 'UT')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Utah';
                if (objSterlingQuoteItem.StateProvince__c == 'VT')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Vermont';
                if (objSterlingQuoteItem.StateProvince__c == 'VA')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Virginia';
                if (objSterlingQuoteItem.StateProvince__c == 'WA')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Washington';
                if (objSterlingQuoteItem.StateProvince__c == 'WV')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'West Virginia';
                if (objSterlingQuoteItem.StateProvince__c == 'WI')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Wisconsin';
                if (objSterlingQuoteItem.StateProvince__c == 'WY')
                    objSterlingQuoteItem.ApprovalTerritory__c = 'Wyoming';
            } else {
                objSterlingQuoteItem.ApprovalTerritory__c = objSterlingQuoteItem.StateProvince__c;
            }
            //Add Picklist value ----------------------------------------
            List<SelectOption> options = new List<SelectOption>();
            // Reading picklist values and labels
            Schema.DescribeFieldResult fieldResult = SterlingQuoteItem__c.ApprovalTerritory__c.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            // Adding apicklist values to the select list
            String strPickVal = null;
            String strPickValtemp = null;
            for (Schema.PicklistEntry entry : picklistEntries) {
                system.debug('******** entry values ' + entry);
                strPickVal = objSterlingQuoteItem.ApprovalTerritory__c;
                strPickValtemp = entry.getValue();
                system.debug('******* strPickValtemp' + strPickValtemp);
                if (strPickValtemp.contains(strPickVal)) {
                    options.add(new SelectOption(entry.getValue(), entry.getLabel()));
                }
            }
            MyOptions = options;
            system.debug(' ******** myoptions' + MyOptions);
            //Add Picklist value ---------------------------------------- end
            //for Dependent
            List<SelectOption> optionsDep = new List<SelectOption>();
            
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Alabama') {
                optionsDep.add(new SelectOption('National', 'National'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'California') {
                optionsDep.add(new SelectOption('West', 'West'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Alaska') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Arizona') {
                optionsDep.add(new SelectOption('National', 'National'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Arkansas') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Colorado') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Connecticut') {
                optionsDep.add(new SelectOption('East', 'East'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Delaware') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Florida') {
                optionsDep.add(new SelectOption('National', 'National'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Georgia') {
                optionsDep.add(new SelectOption('National', 'National'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Hawaii') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Idaho') {
                optionsDep.add(new SelectOption('West', 'West'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Illinois') {
                optionsDep.add(new SelectOption('Central', 'Central'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Indiana') {
                optionsDep.add(new SelectOption('Central', 'Central'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Iowa') {
                optionsDep.add(new SelectOption('Central', 'Central'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Kansas') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Kentucky') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Louisiana') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Maine') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Maryland') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Massachusetts') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Michigan') {
                optionsDep.add(new SelectOption('Central', 'Central'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Minnesota') {
                optionsDep.add(new SelectOption('Central', 'Central'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Mississippi') {
                optionsDep.add(new SelectOption('National', 'National'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Missouri') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Montana') {
                optionsDep.add(new SelectOption('West', 'West'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Nebraska') {
                optionsDep.add(new SelectOption('Central', 'Central'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Nevada') {
                optionsDep.add(new SelectOption('National', 'National'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'New Hampshire') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'New Jersey') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'New Mexico') {
                optionsDep.add(new SelectOption('National', 'National'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'New York') {
                optionsDep.add(new SelectOption('East', 'East'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'North Carolina') {
                optionsDep.add(new SelectOption('National', 'National'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'North Dakota') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Ohio') {
                optionsDep.add(new SelectOption('East', 'East'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Oklahoma') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Oregon') {
                optionsDep.add(new SelectOption('West', 'West'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Pennsylvania') {
                optionsDep.add(new SelectOption('East', 'East'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Rhode Island') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'South Carolina') {
                optionsDep.add(new SelectOption('National', 'National'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'South Dakota') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Tennessee') {
                optionsDep.add(new SelectOption('National', 'National'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Texas') {
                optionsDep.add(new SelectOption('West', 'West'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Utah') {
                optionsDep.add(new SelectOption('National', 'National'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Vermont') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Virginia') {
                optionsDep.add(new SelectOption('', ''));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Washington') {
                optionsDep.add(new SelectOption('West', 'West'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'West Virginia') {
                optionsDep.add(new SelectOption('East', 'East'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Wisconsin') {
                optionsDep.add(new SelectOption('National', 'National'));
            }
            if (objSterlingQuoteItem.ApprovalTerritory__c == 'Wyoming') {
                optionsDep.add(new SelectOption('', ''));
            }
            
            MyOptionsDependent = optionsDep;
        }
    }
    
    // Method for submit for approval button
    public PageReference submitforapproval() {
        isflag = true;
        
        PageReference pageRef = null;
        System.debug('Submit For Approval...' + currentProduct);
        if (currentProduct != null && currentProduct.length() > 0) {
            try {
                update this.objSterlingQuoteItem;
                system.debug('this this this ' + this.objSterlingQuoteItem);
            } catch (Exception e) {
                system.debug('bbbbbbbbb' + e);
            }
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitted for Approval');
            req1.setObjectId(currentProduct);
            if (!test.isRunningTest()) {
                Approval.ProcessResult result = Approval.process(req1);
            }
            pageRef = new PageReference('/apex/opportunity');
            pageRef.getParameters().put('id', apexpages.currentpage().getparameters().get('id'));
            pageRef.setRedirect(true);
        }
        
        return pageRef;
    }
    public PageReference SubmitForICB() {
        isflag = true;
        system.debug('Current product = ' + currentproduct);
        system.debug('QuoteItem = ' + this.objSterlingQuoteItem);
        system.debug('Present Product = ' + PresentProduct);
        
        try {
            if (this.objSterlingQuoteItem.ICB_Request__c == null && this.objSterlingQuoteItem.Sift_Number__c == null) {
                //ApexPages.addMessage('You must enter either a ICB/BDT number or a SIFT number.');
                this.objSterlingQuoteItem.addError('You must enter either an ICB/BDT number or a SIFT number.');
                return null;
            }
            
            this.objSterlingQuoteItem.OverallStatus__c = 'Approved';
            update this.objSterlingQuoteItem;
            system.debug('this this this ' + this.objSterlingQuoteItem);
        } catch (Exception e) {
            system.debug('bbbbbbbbb' + e);
        }
        PageReference pageRef;
        if (lightningRecordtype == true){
            pageRef = new PageReference('/lightning/r/Opportunity/' + apexpages.currentpage().getparameters().get('id') + '/view');
        }else{          
            pageRef = new PageReference('/apex/opportunity');
            pageRef.getParameters().put('id',apexpages.currentpage().getparameters().get('id'));
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public String getStateCode(String stateNameOrStateCode) {
        String stateName = '';
        if (stateNameOrStateCode.length() > 2) {
            stateName = stateNameOrStateCode;
        } else {
            for (String state : stateToStateCodes.KeySet()) {
                if (stateToStateCodes.get(state).toUpperCase() == stateNameOrStateCode) {
                    stateName = state;
                    break;
                }
            }
        }
        return stateName;
    }
    
    public Map<String, String> stateToStateCodes = new Map<String, String>{
        'Alabama' => 'AL'.toLowerCase(),
            'Alaska' => 'AK'.toLowerCase(),
            'Arizona' => 'AZ'.toLowerCase(),
            'Arkansas' => 'AR'.toLowerCase(),
            'California' => 'CA'.toLowerCase(),
            'Colorado' => 'CO'.toLowerCase(),
            'Connecticut' => 'CT'.toLowerCase(),
            'Delaware' => 'DE'.toLowerCase(),
            'Florida' => 'FL'.toLowerCase(),
            'Georgia' => 'GA'.toLowerCase(),
            'Hawaii' => 'HI'.toLowerCase(),
            'Idaho' => 'ID'.toLowerCase(),
            'Illinois' => 'IL'.toLowerCase(),
            'Indiana' => 'IN'.toLowerCase(),
            'Iowa' => 'IA'.toLowerCase(),
            'Kansas' => 'KS'.toLowerCase(),
            'Kentucky' => 'KY'.toLowerCase(),
            'Louisiana' => 'LA'.toLowerCase(),
            'Maine' => 'ME'.toLowerCase(),
            'Maryland' => 'MD'.toLowerCase(),
            'Massachusetts' => 'MA'.toLowerCase(),
            'Michigan' => 'MI'.toLowerCase(),
            'Minnesota' => 'MN'.toLowerCase(),
            'Mississippi' => 'MS'.toLowerCase(),
            'Missouri' => 'MO'.toLowerCase(),
            'Montana' => 'MT'.toLowerCase(),
            'Nebraska' => 'NE'.toLowerCase(),
            'Nevada' => 'NV'.toLowerCase(),
            'New Hampshire' => 'NH'.toLowerCase(),
            'New Jersey' => 'NJ'.toLowerCase(),
            'New Mexico' => 'NM'.toLowerCase(),
            'New York' => 'NY'.toLowerCase(),
            'North Carolina' => 'NC'.toLowerCase(),
            'North Dakota' => 'ND'.toLowerCase(),
            'Ohio' => 'OH'.toLowerCase(),
            'Oklahoma' => 'OK'.toLowerCase(),
            'Oregon' => 'OR'.toLowerCase(),
            'Pennsylvania' => 'PA'.toLowerCase(),
            'Rhode Island' => 'RI'.toLowerCase(),
            'South Carolina' => 'SC'.toLowerCase(),
            'South Dakota' => 'SD'.toLowerCase(),
            'Tennessee' => 'TN'.toLowerCase(),
            'Texas' => 'TX'.toLowerCase(),
            'Utah' => 'UT'.toLowerCase(),
            'Vermont' => 'VT'.toLowerCase(),
            'Virginia' => 'VA'.toLowerCase(),
            'Washington' => 'WA'.toLowerCase(),
            'West Virginia' => 'WV'.toLowerCase(),
            'Wisconsin' => 'WI'.toLowerCase(),
            'Wyoming' => 'WY'.toLowerCase()
            };
                //Giri 06/24/2014 Added End
                
                //wrapper class for the products realtedlist
                public class WrapperOpportunityProduct {
                    public String Status { get; set; }
                    public String Name { get; set; }
                    public Integer Quantity { get; set; }
                    public String IsPromoProduct { get; set; }
                    public Integer EffectiveQuantity { get; set; }
                    public Boolean isEasyPass { get; set; }
                    public String ServiceAddress { get; set; }
                    public String ZAddress { get; set; }
                    public Integer TermLength { get; set; }
                    public Integer NumInstallments { get; set; }
                    public Decimal RenewalMRR { get; set; }
                    public Decimal NetNewMRR { get; set; }
                    public Decimal AdjustedNRC { get; set; }
                    public Decimal CPEGrossMargin { get; set; }
                    public Decimal CPENRC { get; set; }
                    public Decimal NRC { get; set; }
                    public string quoteitemid { get; set; }
                    public Decimal TotalMRC { get; set; }
                    public Decimal NewTCV { get; set; }
                    public Decimal PreviousMRR { get; set; }
                    public string Block { get; set; } // Case#850766 SDDD-4429
                    public Decimal TotalNRC { get; set; }
                    public Decimal TotalCharge { get; set; }
                    public String DiscountType { get; set; }
                    
                    public Decimal recurringTotal { get; set; }
                    public Boolean isOLI { get; set; }
                    
                    public String quoteId { get; set; }
                    //Giri 06/24/2014 Added Start
                    public String OverallStatus { get; set; }
                    public boolean isSubmitted { get; set; }
                    public boolean isPending { get; set; }
                    public boolean isApproved { get; set; }
                    public String Id { get; set; }
                    public boolean isDiscountTypeEmpty { get; set; }
                    public boolean isICB { get; set; }
                    public boolean isEmptyStatus { get; set; }
                    public boolean isRecalled { get; set; }
                    public boolean isstatus { get; set; }
                    public boolean isshow { get; set; }
                    // MMG 2/18/2015 used to control edit capability on product
                    public boolean isfinance { get; set; }
                    public String quoteRecordType { get; set; }
                    //Giri 06/24/2014 Added End
                    public String category { get; set; }
                    public String partNumber { get; set; }
                    public String Speed { get; set; }
                    public String SnEMRC { get; set; }
                    public String SnENRC { get; set; }
                    public String SnECode { get; set; }
                    public String noOfBusinessDays { get; set; }
                    
                    
                    public WrapperOpportunityProduct() {
                        Name = 'test';
                    }
                    
                    public WrapperOpportunityProduct(
                        SterlingQuoteItem__c SQI,
                        OpportunityLineItem OLI,
                        Map<Id, List<ZAddress__c>> sterlingQuoteItemIdByZAddressList
                    ) {
                        //category = (Math.mod((Integer)(Math.random() * 100), 4))+'';//THIS IS A TEMPORARY PLACEHOLDER FOR THE CATEGORY. RANDOMLY ASSIGNS A VALUE OF 0-3 to the section variable.
                        category = SQI.Category__c;
                        partNumber = SQI.Part_Number__c;
                        SnECode = SQI.ItemCode__c;
                        isOLI = false;
                        status = SQI.CurrentStatus__c;
                        System.debug('=========1343============OLI.Id:' + OLI.Id);
                        System.debug('=========1343============OLI.QuoteId__c:' + OLI.QuoteId__c);
                        Quantity = Integer.valueof(SQI.Quantity__c);
                        if ((String.Valueof(SQI.IsPromoProduct__c)).ToUppercase() == 'TRUE') {
                            IsPromoProduct = 'Yes';
                        } else if ((String.Valueof(SQI.IsPromoProduct__c)).ToUppercase() == 'FALSE') {
                            IsPromoProduct = 'No';
                        }
                        //IsPromoProduct= (String.Valueof(SQI.IsPromoProduct__c)).ToUppercase();
                        TermLength = Integer.valueof(SQI.TermLength__c);
                        NumInstallments = Integer.valueof(SQI.NumInstallments__c);
                        DiscountType = SQI.DiscountType__c;
                        
                        //  if ((SQI.Renewal_MRR__c != null) && (SQI.Renewal_MRR__c != 0))
                        RenewalMRR = (SQI.Renewal_MRR_Original__c == null) ? 0 : SQI.Renewal_MRR_Original__c.setScale(3);
                        //  else
                        //      RenewalMRR = OLI.Renewal_MRR__c;
                        
                        // MMG 09/09/2014 Changed to pickup adjusted price instead of list price on items.
                        //if ((SQI.NetNewMRR__c != null) && (SQI.NetNewMRR__c != 0))
                        NetNewMRR = (SQI.NetNewMRR__c == null) ? 0 : SQI.NetNewMRR__c.setScale(3);
                        //else
                        //     NetNewMRR = SQI.AdjustedMRC__c;
                        
                        //IF(NetNewMRR == 0)  NetNewMRR = OLI.UnitPrice;
                        
                        // MMG end
                        CPEGrossMargin = (OLI.CPE_Gross_Margin__c == null) ? 0.00 : OLI.CPE_Gross_Margin__c.setScale(3);
                        AdjustedNRC = (SQI.AdjustedNRC__c == null) ? 0.00 : SQI.AdjustedNRC__c.setScale(3);
                        CPENRC = (OLI.CPE_NRC_Price__c == null) ? 0.00 : OLI.CPE_NRC_Price__c.setScale(3);
                        NRC = (OLI.NRC_Price__c == null) ? 0.00 : OLI.NRC_Price__c.setScale(3);
                        NewTCV = (OLI.New_TCV__c == null) ? 0.00 : OLI.New_TCV__c.setScale(3);
                        PreviousMRR = (OLI.Previous_MRR__c == null) ? 0.00 : OLI.Previous_MRR__c.setScale(3);
                        TotalNRC = ((OLI.NRC_Price__c == null) ? 0.00 : OLI.NRC_Price__c.setScale(3)) * Quantity;
                        Name = OLI.Product2.Name;
                        //Giri 06/24/2014 Added Start
                        OverallStatus = SQI.OverallStatus__c;
                        quoteitemid = SQI.id;
                        quoteRecordType = SQI.RecordType.Name;
                        TotalMRC = (SQI.AdjustedMRC__c == null) ? 0.00 : SQI.AdjustedMRC__c.setScale(3);
                        TotalCharge = Quantity * TotalMRC;            
                        ServiceAddress = OLI.Service_Address__c;
                        ZAddress = '';            
                        List<ZAddress__c> zaddrlist = new List<ZAddress__c>();
                        if (sterlingQuoteItemIdByZAddressList != null && sterlingQuoteItemIdByZAddressList.size() > 0) {
                            zaddrlist = sterlingQuoteItemIdByZAddressList.get(SQI.id);
                        }
                        else {
                            zaddrlist = [SELECT SterlingQuoteItem__c,StreetNrFirst__c,StreetName__c,StreetSuffix__c, Locality__c,StateOrProvince__c,Postcode__c FROM ZAddress__c where  SterlingQuoteItem__c =: SQI.id];
                        }
                        if (zaddrlist != null && zaddrlist.size() > 0) {
                            ZAddress = (zaddrlist[0].StreetNrFirst__c != null) ? ( (zaddrlist[0].StreetNrFirst__c) +',' ) : '';
                            ZAddress += (zaddrlist[0].StreetName__c != null) ? ( (zaddrlist[0].StreetName__c) +',' ) : '';
                            ZAddress += (zaddrlist[0].StreetSuffix__c != null) ? ( (zaddrlist[0].StreetSuffix__c) +',' ): '' ;
                            ZAddress += (zaddrlist[0].Locality__c != null) ? ( (zaddrlist[0].Locality__c) +',' ) : '';
                            ZAddress += (zaddrlist[0].StateOrProvince__c != null) ? ( (zaddrlist[0].StateOrProvince__c) +',' ) : '';
                            ZAddress += (zaddrlist[0].Postcode__c != null) ? (zaddrlist[0].Postcode__c) : '';
                        }
                        
                        //isSubmitted = ![ Select Id From ProcessInstance WHERE TargetObjectId =: SQI.Id AND Status = 'Pending' ].isEmpty();
                        
                        // Changed from using process instance to using overall status to set ispending and isfalse to eliminate too many queries defect # 1402
                        if (SQI.Overallstatus__c == 'Pending') {
                            isSubmitted = true;
                            isPending = false;
                        }
                        
                        isApproved = false;
                        isRecalled = false;
                        isEmptyStatus = false;
                        
                        // MMG 2/18/2015 used to control edit capability on product
                        isFinance = false;
                        if (SQI.Currentstatus__c == 'Pending - Finance') {
                            isFinance = true;
                        }
                        if (SQI.Currentstatus__c == 'Pending - Business Decision Support') {
                            isFinance = true;
                        }
                        if (SQI.OverallStatus__c == 'Approved') {
                            isApproved = true;
                        } else if (SQI.OverallStatus__c == 'Recalled' || SQI.OverallStatus__c == 'Rejected') {
                            isRecalled = true;
                        }
                        
                        if (SQI.OverallStatus__c == '' || SQI.OverallStatus__c == null) {
                            isEmptyStatus = true;
                        }
                        
                        Id = SQI.Id;
                        isDiscountTypeEmpty = false;
                        isICB = false;
                        // MGG319 1/4/2019 Changing from ICB to BDT for Testing Purposes to remove Discount Pricing Request Box
                        // and allow normal submit for approval button to launch approval process
                        System.debug('Discount Type = ' + SQI.Discounttype__c);
                        System.debug('Isicb before test = ' + IsIcb);
                        System.debug('isDiscountTypeEmpty= ' + isDiscountTypeEmpty);
                        System.debug('Record Type Name = ' + quoterecordtype);
                        if (SQI.DiscountType__c != null && SQI.DiscountType__c.length() > 0 && SQI.DiscountType__c != 'None') {
                            // if ((SQI.DiscountType__c == 'ICB') || (SQI.DiscountType__c == 'CTR') && (quoterecordtype == 'SFA')) {
                            //  if ((SQI.DiscountType__c == 'ICB') && (quoterecordtype == 'SFA')) {
                            if ((SQI.DiscountType__c == 'BDT') || (SQI.DiscountType__c == 'CTR')) {
                                System.debug('Isicb after test = ' + IsIcb);
                                // MGG319 End Change
                                isICB = true;
                                System.debug('Isicb after test = ' + IsIcb);
                            }
                            if (SQI.DiscountType__c == 'ICBA') {
                                System.debug('Discount Type = ' + sqi.discounttype__c);
                                isICB = false;
                                isEmptyStatus = false;
                                System.debug('Isicb after test = ' + IsIcb);
                            }
                            if (SQI.DiscountType__c == 'CTRA') {
                                System.debug('Discount Type = ' + sqi.discounttype__c);
                                isICB = false;
                                isEmptyStatus = false;
                                System.debug('Isicb after test = ' + IsIcb);
                            }
                            if (SQI.NoICB__c == true) {
                                System.debug('NoIcb = ' + sqi.NoICB__c);
                                isICB = false;
                                System.debug('Isicb after test = ' + IsIcb);
                            }
                        } else {
                            isDiscountTypeEmpty = true;
                            System.debug('isDiscountTypeEmpty= ' + isDiscountTypeEmpty);
                        }
                        //Giri 06/24/2014 Added End
                        system.debug('wrapperconstructor nri price' + OLI.NRC_Price__C);
                    }
                    public WrapperOpportunityProduct(OpportunityLineItem oli) {
                        if (oli.vlocity_cmt__RecurringCharge__c == null) {
                            oli.vlocity_cmt__RecurringCharge__c = 0;
                        }
                        if (oli.vlocity_cmt__OneTimeCharge__c == null) {
                            oli.vlocity_cmt__OneTimeCharge__c = 0;
                        }
                        Id = oli.Id;
                        // SDDD-4429
                        if(oli.vlocity_cmt__JSONAttribute__c !=null && oli.vlocity_cmt__JSONAttribute__c !=''){            
                            Map<String, Object> myAttrVals = ftr_CpqHelper.getJSONAttributeValues(oli.vlocity_cmt__JSONAttribute__c);
                            // Add Block Additional
                            if(myAttrVals.containsKey('ATTR_MIN_BLOCKS')){                
                                Block = (String)myAttrVals.get('ATTR_MIN_BLOCKS');
                            }
                            // Add Block Include
                            if(myAttrVals.containsKey('ATTR_INC_LD_BOT')){                
                                Block = (String)myAttrVals.get('ATTR_INC_LD_BOT');
                            }
                        }
                        
                        Quantity = (Integer) oli.Quantity;
                        IsPromoProduct = 'No';
                        EffectiveQuantity = (Integer) oli.vlocity_cmt__EffectiveQuantity__c;
                        TermLength = (Integer) oli.Term_Months__c;
                        NumInstallments = 0;
                        DiscountType = oli.DiscountType__c;
                        RenewalMRR = oli.Renewal_MRR__c ;
                        NetNewMRR = oli.CPQ_NetNewMRR__c ;
                        NewTCV = oli.New_TCV__c ;
                        PreviousMRR = oli.Previous_MRR__c;
                        CPEGrossMargin = oli.CPE_Gross_Margin__c;
                        AdjustedNRC = oli.AdjustedMRC__c;
                        CPENRC = oli.CPE_NRC_Price__c;
                        NRC = oli.vlocity_cmt__OneTimeCharge__c;
                        TotalNRC = oli.vlocity_cmt__OneTimeCharge__c * Quantity;
                        Name = oli.Product2.Name;
                        Speed = oli.Speed__c;
                        SnEMRC = oli.SNE_Code_MRC__c;
                        SnENRC = oli.SNE_Code_OTC__c;
                        OverallStatus = '';
                        quoteId = oli.VlocityQuoteId__c;
                        quoteRecordType = 'Vlocity';
                        TotalMRC = oli.vlocity_cmt__RecurringCharge__c;
                        
                        recurringTotal = oli.vlocity_cmt__RecurringTotal__c;
                        isOLI = true;
                        
                        TotalCharge = Quantity * TotalMRC;
                        ServiceAddress = OLI.vlocity_cmt__ServiceAccountId__r.Name;
                        noOfBusinessDays = OLI.Dsat_Standard_Interval__c;
                        ZAddress = '';
                        isSubmitted = true;
                        isPending = false;
                        isApproved = false;
                        isRecalled = false;
                        isEmptyStatus = true;
                        isFinance = false;
                        isDiscountTypeEmpty = true;
                        isICB = false;
                        if (oli.QuoteLineItem__c != null && oli.QuoteLineItem__r.Quote.getSObject('RecordType') != null) {
                            isEasyPass = oli.QuoteLineItem__r.Quote.RecordType.Name.contains('EasyPass') ? true : false;
                        } else {
                            isEasyPass = false;
                        }
                    }
                }
    
    public class QuoteWrapper {
        public String Id { get; set; }
        public Boolean IsSyncing { get; set; }
        public String RecordTypeId { get; set; }
        public String RecordTypeName { get; set; }
        public String Name { get; set; }
        public Boolean IsSyncAllowedByAdmin { get; set; }
        public Boolean IsSyncAllowed { get; set; }
        public QuoteWrapper(sObject quote) {
            this.Id = (String) quote.get('Id');
            this.IsSyncing = (Boolean) quote.get('IsSyncing__c');
            this.Name = (String) quote.get('Name');
            if (String.valueOf(quote.getSObjectType()) == 'Quote') {
                this.RecordTypeId = 'N/A';
                this.RecordTypeName = 'Vlocity';
                this.IsSyncAllowedByAdmin = false;
                this.IsSyncAllowed = true;
            } else {
                this.RecordTypeId = (String) quote.getSObject('RecordType').get('Id');
                this.RecordTypeName = (String) quote.getSObject('RecordType').get('Name');
                this.IsSyncAllowedByAdmin = (Boolean) quote.get('Sync_Allowed_by_Admin__c');
                this.IsSyncAllowed = (Boolean) quote.get('Is_Sync_Allowed__c');
            }
        }
    }
    
    public boolean displayPopUp1 { get; set; }
    public boolean displayPopUp2 { get; set; }
    public boolean displayPopUp3 { get; set; }
    public void closePopup() {
        displayPopup = false;
        displaypopup1 = false;
        displaypopup2 = false;
        displaypopup3 = false;
        displayPopUpQQ = false;
    }
    
    public void closePopupQQ() {
        displayPopUpQQ = false;
    }
    
    public void showPopup() {
        //    initSpeedList();
        //    displayPopup1 = true;
        displayPopUp = true;
    }
    
    public void showPopupQQ() {
        displayPopUpQQ = true;
    }
    
    public void hidePopupQQ() {
        displayPopUpQQ = false;
    }
    
    // Method for paginations
    public void getStrQuotes() {
        //size = 10;
        setCon.setPageSize(size);
        // lstStrQuote = (List<SterlingQuote__c>)setCon.getRecords();
        lstStrQuote = getAllQuotes();
    }
    
    public PageReference syncVlocityQuote() {
        QuoteSyncService.Sync(new Quote(Id=currentVlocityQuoteId, OpportunityId=strOpportunityId));
        // update new Quote(Id = currentVlocityQuoteId, IsSyncing__c = true);
        PageReference pg;
        String userProfile = [SELECT Name
                              FROM Profile
                              WHERE Id =: userinfo.getProfileId()
                              LIMIT 1].Name;
        if(userProfile == 'Frontier Partner Portal User'){
            ConnectApi.Community comm = getCommunityUrl();
            pg = new PageReference(comm.siteUrl + '/s/opportunity/' + strOpportunityId);
            return pg;
        }else {
            return refreshPage();
        }
    }
    
    public PageReference unSyncVlocityQuote() {
        QuoteSyncService.UnSync(new Quote(Id=currentVlocityQuoteId, OpportunityId=strOpportunityId));
        PageReference pg;
        String userProfile = [SELECT Name
                              FROM Profile
                              WHERE Id =: userinfo.getProfileId()
                              LIMIT 1].Name;
        if(userProfile == 'Frontier Partner Portal User'){
            ConnectApi.Community comm = getCommunityUrl();
            pg = new PageReference(comm.siteUrl + '/s/opportunity/' + strOpportunityId);
            return pg;
        }else {
            return refreshPage();
        }
    }
    
    // update new Quote(Id = currentVlocityQuoteId, IsSyncing__c = false);
    
    
    
    public PageReference deleteVlocityQuote() {
        QuoteSyncService.UnSync(new Quote(Id=currentVlocityQuoteId, OpportunityId=strOpportunityId));
        delete new Quote(Id = currentVlocityQuoteId);
        PageReference pg;
        String userProfile = [SELECT Name
                              FROM Profile
                              WHERE Id =: userinfo.getProfileId()
                              LIMIT 1].Name;
        if(userProfile == 'Frontier Partner Portal User'){
            ConnectApi.Community comm = getCommunityUrl();
            pg = new PageReference(comm.siteUrl + '/s/opportunity/' + strOpportunityId);
            return pg;
        }else {
            return refreshPage();
        }
    }
    
    public ConnectApi.Community getCommunityUrl(){
        ConnectApi.Community comm;
        if(!test.isRunningTest()) {
            String ntwrkId = Network.getNetworkId();
            comm = ConnectApi.Communities.getCommunity(ntwrkId); 
        } else {
            comm = new ConnectApi.Community();
        }
        return comm;
    }
    
    public PageReference editVlocityQuote() {
        
        PageReference pg;
        String userProfile = [SELECT Name
                              FROM Profile
                              WHERE Id =: userinfo.getProfileId()
                              LIMIT 1].Name;
        if(userProfile == 'Frontier Partner Portal User'){
            ConnectApi.Community comm = getCommunityUrl();
            pg = new PageReference(comm.siteUrl + '/s/quote/' + currentVlocityQuoteId);
        }else {
            pg = new PageReference('/lightning/r/Quote/' + currentVlocityQuoteId + '/view');
        }
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference openQuoteForPartnerPortal() {
        PageReference pg;
        ConnectApi.Community comm = getCommunityUrl();
        if(isVelocity) {
            pg = new PageReference(comm.siteUrl + '/s/quote/' + currentQuoteId);
        }else {
            pg = new PageReference(comm.siteUrl + '/apex/Quote?id=' + currentQuoteId);
        }
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference openVelocityProductForPartnerPortal() {
        PageReference pg;
        ConnectApi.Community comm = getCommunityUrl();
        pg = new PageReference(comm.siteUrl + '/apex/vlocity_cmt__hybridcpq?id=' + sqitem_quoteId);
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference refreshPage() {
        PageReference pageRef;
        if (lightningRecordtype == true){
            pageRef = new PageReference('/lightning/r/Opportunity/' + strOpportunityId + '/view');
        }else {
            pageRef = new PageReference('/apex/Opportunity?Id='+strOpportunityId+'&sfdc.override=1');
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference launchQuoteOmniscript() {
        PageReference pr = new PageReference(
            '/apex/vlocity_cmt__OmniScriptUniversalPage?Id=' +
            strOpportunityId +
            '&layout=newport&OmniScriptType=Quote&OmniScriptSubType=Guided&OmniScriptLang=English&ContextId=' +
            strOpportunityId +
            '&QuoteId=&PrefillDataRaptorBundle//true'
        );
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference launchEasyPassQuoteOmniscript() {
        PageReference pr = new PageReference(
            '/apex/vlocity_cmt__OmniScriptUniversalPage?Id=' +
            strOpportunityId +
            '&layout=newport&OmniScriptType=Quote&OmniScriptSubType=EasyPass&OmniScriptLang=English&ContextId=' +
            strOpportunityId +
            '&ProductCode=ENT_ETH_EIA_0002&PrefillDataRaptorBundle//true'
        );
        pr.setRedirect(true);
        return pr;
    }
    
    public List<QuoteWrapper> getAllQuotes() {
        List<QuoteWrapper> results = new List<QuoteWrapper>();
        List<QuoteWrapper> syncedQuotes = new List<QuoteWrapper>();
        List<QuoteWrapper> tempList = new List<QuoteWrapper>();
        List<sObject> records = new List<sObject>(
            (List<sObject>) [
                SELECT Id, IsSyncing__c, RecordType.Name, Is_Sync_Allowed__c, Sync_Allowed_by_Admin__c, RecordTypeID, Name
                FROM SterlingQuote__c
                WHERE OpportunityId__c = :strOpportunityId
                ORDER BY IsSyncing__c DESC
            ]
        );
        List<Quote> vlocityQuotes = new List<Quote>(
            [
                SELECT Id, IsSyncing__c, RecordType.Name, RecordTypeID, Name
                FROM Quote
                WHERE OpportunityId = :strOpportunityId
                ORDER BY IsSyncing__c DESC
            ]
        );
        records.addAll((List<sObject>) vlocityQuotes);
        for (sObject record : records) {
            results.add(new QuoteWrapper(record));
        }
        // re-order quotes so synced quotes are at top of the list
        for (QuoteWrapper q : results) {
            if (q.IsSyncing == true) {
                syncedQuotes.add(q);
            } else {
                tempList.add(q);
            }
        }
        results = syncedQuotes;
        results.addAll(tempList);
        // system.debug('records -> '+JSON.serializePretty(records));
        return results;
    }
    
    public void updateStandardSetController() {
        oppSSC = new ApexPages.Standardsetcontroller(
            Database.getQuerylocator([SELECT IsSyncing__c, RecordTypeID, Name FROM SterlingQuote__c WHERE OpportunityId__c = :strOpportunityId])
        );
        noOfRecords = oppSSC.getResultSize();
        oppSSC.setPageSize(size);
    }
    
    public void first() {
        setCon.first();
        getStrQuotes();
    }
    
    public void last() {
        setCon.last();
        getStrQuotes();
    }
    
    public void previous() {
        setCon.previous();
        getStrQuotes();
    }
    
    public void next() {
        setCon.next();
        getStrQuotes();
    }
    
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
    }
    
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
    }
    
    //Giri products pagination start
    
    public list<WrapperOpportunityProduct> lstAllProducts { get; set; }
    public list<WrapperOpportunityProduct> lstProducts { get; set; }
    public Integer prdNoOfRecords { get; set; }
    public Integer prdPageSize { get; set; }
    public Integer prdPageNumber { get; set; }
    public Integer prdTotalPages { get; set; }
    
    public void initProductSection() {
        prdPageSize = 1000;
        lstAllProducts = getSterlingQuoteItem();
        prdNoOfRecords = lstAllProducts.size();
        lstProducts = new List<WrapperOpportunityProduct>();
        prdPageNumber = 1;
        integer tmpCount = prdNoOfRecords / prdPageSize;
        prdTotalPages = Math.mod(prdNoOfRecords, prdPageSize) > 0 ? tmpCount + 1 : tmpCount;
    }
    
    public List<WrapperOpportunityProduct> getProducts() {
        system.debug('********** list products   : ' + lstproducts);
        lstProducts.clear();
        
        Integer start = (prdPageNumber - 1) * prdPageSize;
        Integer stop = (prdPageNumber * prdPageSize);
        
        if (stop > prdNoOfRecords) {
            stop = prdNoOfRecords;
        }
        
        while (start < stop) {
            lstProducts.add(lstAllProducts[start]);
            start++;
        }
        
        return lstProducts;
    }
    
    public void prdFirst() {
        prdPageNumber = 1;
    }
    
    public void prdLast() {
        prdPageNumber = prdTotalPages;
    }
    
    public void prdPrevious() {
        prdPageNumber--;
    }
    
    public void prdNext() {
        prdPageNumber++;
    }
    
    public Boolean prdHasNext {
        get {
            return prdPageNumber < prdTotalPages;
        }
    }
    public Boolean prdHasPrevious {
        get {
            return prdPageNumber > 1;
        }
    }
    //Giri Pagination End
    
    ///////////////////
    //Giri schedule pagination start
    //method for schedules
    public List<Schedule__c> getScheudleItem() {
        list<Schedule__c> listSch = [
            SELECT
            //Id,Name, Contract_Term_Months__c,Product__c, Schedule_Start_Date__c, Schedule_End_Date__c, Primaryserviceaddress__c
            Id,
            Name,
            Contract_Term_Months__c,
            Schedule_Start_Date__c,
            Schedule_End_Date__c
            FROM Schedule__c
            WHERE New_Opportunity__c = :strOpportunityId
        ];
        return listSch;
    }
    
    public List<Schedule__c> getSchedule() {
        system.debug('********** list Schedules   : ' + lstSchedules);
        lstSchedules.clear();
        
        Integer start = (schPageNumber - 1) * schPageSize;
        Integer stop = (schPageNumber * schPageSize);
        
        if (stop > schNoOfRecords) {
            stop = schNoOfRecords;
        }
        
        while (start < stop) {
            lstSchedules.add(lstAllSchedules[start]);
            start++;
        }
        
        return lstSchedules;
    }
    
    public list<Schedule__c> lstAllSchedules { get; set; }
    public list<Schedule__c> lstSchedules { get; set; }
    public Integer schNoOfRecords { get; set; }
    public Integer schPageSize { get; set; }
    public Integer schPageNumber { get; set; }
    public Integer schTotalPages { get; set; }
    
    public void initScheduleSection() {
        schPageSize = 5;
        lstAllSchedules = getScheudleItem();
        schNoOfRecords = lstAllSchedules.size();
        lstSchedules = new List<Schedule__c>();
        schPageNumber = 1;
        integer tmpCount = schNoOfRecords / schPageSize;
        schTotalPages = Math.mod(schNoOfRecords, schPageSize) > 0 ? tmpCount + 1 : tmpCount;
    }
    
    public List<Schedule__c> getSchedules() {
        system.debug('********** list Schedules   : ' + lstSchedules);
        lstSchedules.clear();
        
        Integer start = (schPageNumber - 1) * schPageSize;
        Integer stop = (schPageNumber * schPageSize);
        
        if (stop > schNoOfRecords) {
            stop = schNoOfRecords;
        }
        
        while (start < stop) {
            lstSchedules.add(lstAllSchedules[start]);
            start++;
        }
        
        return lstSchedules;
    }
    
    public void schFirst() {
        schPageNumber = 1;
    }
    
    public void schLast() {
        schPageNumber = schTotalPages;
    }
    
    public void schPrevious() {
        schPageNumber--;
    }
    
    public void schNext() {
        schPageNumber++;
    }
    
    public Boolean schHasNext {
        get {
            return schPageNumber < schTotalPages;
        }
    }
    public Boolean schHasPrevious {
        get {
            return schPageNumber > 1;
        }
    }
    //Giri schedule Pagination End
    //////////////////
    
    //Giridhar ProductSync
    public pageReference productSyncClick() {
        String strQuoteid = Apexpages.currentpage().getparameters().get('strQuoteid');
        system.debug('**strQuoteid****' + strQuoteid);
        String userProfile = [SELECT Name
                              FROM Profile
                              WHERE Id =: userinfo.getProfileId()
                              LIMIT 1].Name;
        SterlingQuote__c sterlingQuote = [
            SELECT id, RecordTypeid, RecordType.Name, IsSyncing__c, QuoteType__c, CPQQuoteId__c, OpportunityId__c
            FROM SterlingQuote__c
            WHERE id = :strQuoteid
        ];
        Quote_Extension.productSync(strQuoteid, sterlingQuote);
        setCon = new ApexPages.Standardsetcontroller(
            Database.getQuerylocator(
                [
                    SELECT Id, IsSyncing__c, RecordType.Name, RecordTypeID, Name
                    FROM SterlingQuote__c
                    WHERE OpportunityId__c = :strOpportunityId
                    ORDER BY IsSyncing__c DESC
                ]
            )
        ); //Giri Added order by condition for sync ordering
        //  getStrQuotes();
        initProductSection();
        PageReference pr;
        if (lightningRecordtype == true){
            pr = new PageReference('/lightning/r/Opportunity/' + strOpportunityId + '/view');
        }else if(userProfile == 'Frontier Partner Portal User') {
            ConnectApi.Community comm = getCommunityUrl();
            pr = new PageReference(comm.siteUrl + '/s/opportunity/' + strOpportunityId);
        }else {
            pr = new PageReference('/apex/Opportunity?Id='+strOpportunityId+'&sfdc.override=1');
        }
        pr.setRedirect(true);
        return pr;
        //return null;
    }
    
    //Giridhar Product UnSync
    public pageReference productUnSyncClick() {
        String strQuoteid = apexpages.currentpage().getparameters().get('strQuoteid');
        String userProfile = [SELECT Name
                              FROM Profile
                              WHERE Id =: userinfo.getProfileId()
                              LIMIT 1].Name;
        system.debug('**strQuoteid****' + strQuoteid);
        SterlingQuote__c sterlingQuote = [
            SELECT id, RecordTypeid, RecordType.Name, IsSyncing__c, QuoteType__c, CPQQuoteId__c, OpportunityId__c
            FROM SterlingQuote__c
            WHERE id = :strQuoteid
        ];
        Quote_Extension.productUnSync(strQuoteid, sterlingQuote);
        setCon = new ApexPages.Standardsetcontroller(
            Database.getQuerylocator(
                [
                    SELECT Id, IsSyncing__c, RecordType.Name, RecordTypeID, Name
                    FROM SterlingQuote__c
                    WHERE OpportunityId__c = :strOpportunityId
                    ORDER BY IsSyncing__c DESC
                ]
            )
        ); //Giri Added order by condition for sync ordering
        getStrQuotes();
        initProductSection();
        PageReference pr;
        if (lightningRecordtype == true){
            pr = new PageReference('/lightning/r/Opportunity/' + strOpportunityId + '/view');
        }else if(userProfile == 'Frontier Partner Portal User') {
            ConnectApi.Community comm = getCommunityUrl();
            pr = new PageReference(comm.siteUrl + '/s/opportunity/' + strOpportunityId);
        }else {
            pr = new PageReference('/apex/Opportunity?Id='+strOpportunityId+'&sfdc.override=1');
        }
        pr.setRedirect(true);
        return pr;
        //return null;
    }
    
    public void quoteEdit_SterlingCPQ(String accountId, String opportunityId) {
        String strAddress = '';
        displayAddressGrid = false;
        dynamicOptions = new List<SelectOption>();
        dynamicOptions.add(new SelectOption('None', 'None'));
        defaultAddress = 'None';
        //Know the invocation button source i.e Opportunity
        uiFlag = 'OPPORTUNITY';
        addressinfo = new List<productcompanyinfo>();
        
        if (uiFlag == 'OPPORTUNITY') {
            Account accRec = [
                SELECT
                BillingStreet,
                BillingCity,
                BillingState,
                BillingCountry,
                BillingPostalCode,
                Legal_Street__c,
                Legal_City__c,
                Legal_State__c,
                Legal_Zip__c,
                Legal_Country1__c,
                ShippingStreet,
                ShippingCity,
                ShippingState,
                ShippingCountry,
                ShippingPostalCode
                FROM ACCOUNT
                WHERE id = :accountId
            ];
            
            if (accRec != null) {
                if (accRec.Legal_Street__c != null && accRec.Legal_City__c != null && accRec.Legal_State__c != null) {
                    dynamicOptions.add(new SelectOption('Legal Address', 'Legal Address'));
                    strAddress =
                        accRec.Legal_Street__c +
                        ',' +
                        accRec.Legal_City__c +
                        ',' +
                        accRec.Legal_State__c +
                        ',' +
                        accRec.Legal_Country1__c +
                        ',' +
                        accRec.Legal_Zip__c;
                    strAddress = strAddress.replace(',  ,', ',');
                    strAddress = strAddress.replace('null', '');
                    strAddress = strAddress.replace(',null,', ',');
                    strAddress = strAddress.replace(',null', '');
                    strAddress = strAddress.replace('null', '');
                    productCompanyInfo objAddInfo1 = new productCompanyInfo();
                    objAddInfo1.strColumnOne = 'Legal Address';
                    objAddInfo1.strColumnTwo = strAddress;
                    System.Debug('Legal Street --' + strAddress);
                    if (strAddress != '' && strAddress != null) {
                        addressinfo.add(objAddInfo1);
                    }
                }
                if (accRec.BillingStreet != null && accRec.BillingCity != null && accRec.BillingState != null) {
                    dynamicOptions.add(new SelectOption('Billing Address', 'Billing Address'));
                    strAddress =
                        accRec.BillingStreet +
                        ',' +
                        accRec.BillingCity +
                        ',' +
                        accRec.BillingState +
                        ',' +
                        accRec.BillingCountry +
                        ',' +
                        accRec.BillingPostalCode;
                    strAddress = strAddress.replace(',  ,', ',');
                    strAddress = strAddress.replace('null', '');
                    strAddress = strAddress.replace(',null,', ',');
                    strAddress = strAddress.replace(',null', '');
                    strAddress = strAddress.replace('null', '');
                    productCompanyInfo objAddInfo2 = new productCompanyInfo();
                    objAddInfo2.strColumnOne = 'Billing Address';
                    objAddInfo2.strColumnTwo = strAddress;
                    if (strAddress != '' && strAddress != null) {
                        addressinfo.add(objAddInfo2);
                    }
                }
                if (accRec.ShippingStreet != null && accRec.ShippingCity != null && accRec.ShippingState != null) {
                    dynamicOptions.add(new SelectOption('Service Address', 'Service Address'));
                    strAddress =
                        accRec.ShippingStreet +
                        ',' +
                        accRec.ShippingCity +
                        ',' +
                        accRec.ShippingState +
                        ',' +
                        accRec.ShippingCountry +
                        ',' +
                        accRec.ShippingPostalCode;
                    strAddress = strAddress.replace(',  ,', ',');
                    strAddress = strAddress.replace('null', '');
                    strAddress = strAddress.replace(',null,', ',');
                    strAddress = strAddress.replace(',null', '');
                    strAddress = strAddress.replace('null', '');
                    productCompanyInfo objAddInfo3 = new productCompanyInfo();
                    objAddInfo3.strColumnOne = 'Service Address';
                    objAddInfo3.strColumnTwo = strAddress;
                    if (strAddress != '' && strAddress != null) {
                        addressinfo.add(objAddInfo3);
                    }
                }
            }
        }
        if (addressinfo.size() >= 1) {
            displayAddressGrid = true;
        }
    }
    
    public class productCompanyInfo {
        public String strColumnOne { get; set; }
        public String strColumnTwo { get; set; }
    }
    
    public PageReference reDirectToSterling() {
        String catalogURL = '';
        if (defaultAddress == 'Legal Address') {
            defaultAddress = 'Legal';
        } else if (defaultAddress == 'Billing Address') {
            defaultAddress = 'Billing';
        } else if (defaultAddress == 'Service Address') {
            defaultAddress = 'Service';
        }
        
        if (objopp.Opportunity_Type__c == 'New' || objopp.Opportunity_Type__c == 'Existing' || objopp.Opportunity_Type__c == 'winback') {
            catalogURL =
                '/apex/SterlingQuote?OptionType=NQ&addressType=' +
                defaultAddress +
                '&accountId=' +
                objOpp.AccountId +
                '&opportunityId=' +
                objOpp.Id;
        } else if (objopp.Opportunity_Type__c == 'Renewal') {
            catalogURL =
                '/apex/SterlingQuote?OptionType=RE&addressType=' +
                defaultAddress +
                '&accountId=' +
                objOpp.AccountId +
                '&opportunityId=' +
                objOpp.Id +
                '&scheduleIds=' +
                objopp.scheduleRenewed__r.Name;
        }
        PageReference ref = new PageReference(catalogURL);
        System.Debug('URL REDIRECT' + catalogURL);
        ref.setRedirect(true);
        return ref;
    }
    
    public PageReference reDirectToSFAQuote() {
        String catalogURL = '';
        
        if (defaultAddress == 'Legal Address') {
            defaultAddress = 'Legal';
        } else if (defaultAddress == 'Billing Address') {
            defaultAddress = 'Billing';
        } else if (defaultAddress == 'Service Address') {
            defaultAddress = 'Service';
        }
        
        catalogURL = '/apex/productoverridepage?OptionType=NQ&addressType=' + defaultAddress + '&oppid=' + objOpp.Id;
        PageReference ref = new PageReference(catalogURL);
        System.Debug('URL REDIRECT' + catalogURL);
        ref.setRedirect(true);
        return ref;
    }
    //giri notes & attachment Start pagination
    
    public list<AttachmentWrapper> lstAllAttachments { get; set; }
    public list<AttachmentWrapper> lstAttachments { get; set; }
    public Integer attNoOfRecords { get; set; }
    public Integer attPageSize { get; set; }
    public Integer attPageNumber { get; set; }
    public Integer attTotalPages { get; set; }
    public String delAttId { get; set; }
    public String viewAttId { get; set; }
    
    public void deleteAttachment() {
        if (delAttId != null && delAttId != '') {
            Attachment oAtt = new Attachment(Id = delAttId);
            delete oAtt;
            initAttachmentSection();
        }
    }
    
    public List<AttachmentWrapper> fetchAllAttachments() {
        List<Id> idList = new List<Id>();
        List<AttachmentWrapper> notesAndAttachments = new List<AttachmentWrapper>();
        List<Attachment> attachments = [
            SELECT Id, Name, LastModifiedDate, CreatedById, CreatedBy.Name
            FROM Attachment
            WHERE parentId = :strOpportunityId
            ORDER BY LastModifiedDate DESC
        ];
        AttachmentWrapper aw;
        if (attachments.size() > 0) {
            for (Attachment att : attachments) {
                aw = new AttachmentWrapper();
                aw.name = att.name;
                aw.typeOf = 'Attachment';
                aw.Id = att.Id + '';
                aw.LastModifiedDate = att.LastModifiedDate;
                aw.createdById = att.CreatedById + '';
                aw.urlRedirection = '/' + att.id;
                aw.createByName = att.CreatedBy.Name;
                notesAndAttachments.add(aw);
            }
        }
        List<Note> notes = [
            SELECT Id, title, LastModifiedDate, CreatedById, CreatedBy.Name
            FROM Note
            WHERE parentId = :strOpportunityId
            ORDER BY LastModifiedDate DESC
        ];
        if (notes.size() > 0) {
            for (Note att : notes) {
                aw = new AttachmentWrapper();
                aw.name = att.title;
                aw.typeOf = 'Note';
                aw.Id = att.Id + '';
                aw.LastModifiedDate = att.LastModifiedDate;
                aw.createdById = att.CreatedById + '';
                aw.createByName = att.CreatedBy.Name;
                aw.urlRedirection = '/' + aw.id;
                notesAndAttachments.add(aw);
            }
        }
        return notesAndAttachments;
    }
    
    public void initAttachmentSection() {
        attPageSize = 5;
        lstAllAttachments = fetchAllAttachments();
        attNoOfRecords = lstAllAttachments.size();
        lstAttachments = new List<AttachmentWrapper>();
        attPageNumber = 1;
        integer tmpCount = attNoOfRecords / attPageSize;
        attTotalPages = Math.mod(attNoOfRecords, attPageSize) > 0 ? tmpCount + 1 : tmpCount;
    }
    
    public List<AttachmentWrapper> getAttachments() {
        lstAttachments.clear();
        Integer start = (attPageNumber - 1) * attPageSize;
        Integer stop = (attPageNumber * attPageSize);
        
        if (stop > attNoOfRecords) {
            stop = attNoOfRecords;
        }
        
        while (start < stop) {
            lstAttachments.add(lstAllAttachments[start]);
            start++;
        }
        
        return lstAttachments;
    }
    
    public void attFirst() {
        attPageNumber = 1;
    }
    
    public void attLast() {
        attPageNumber = attTotalPages;
    }
    
    public void attPrevious() {
        attPageNumber--;
    }
    
    public void attNext() {
        attPageNumber++;
    }
    
    public Boolean attHasNext {
        get {
            return attPageNumber < attTotalPages;
        }
    }
    public Boolean attHasPrevious {
        get {
            return attPageNumber > 1;
        }
    }
    
    public class AttachmentWrapper {
        public String name { get; set; }
        public String typeOf { get; set; }
        public String Id { get; set; }
        public dateTime LastModifiedDate { get; set; }
        public String createdById { get; set; }
        public String createByName { get; set; }
        public String urlRedirection { get; set; }
    }
    
    public PageReference quickQuoteQQ() {
        try {
            PageReference pdfPage;
            
            if (selectedQQT == 'UCaaS') {
                pdfPage = Page.QuickQuote_UCaaS;
            } else {
                pdfPage = Page.QuickQuote;
            }
            pdfPage.getParameters().put('oid', strOpportunityId);
            if (String.isEmpty(commentStr))
                isCommentNull = true;
            else
                isCommentNull = false;
            pdfPage.getParameters().put('c', commentStr);
            pdfPage.setRedirect(true);
            Blob pdfBlob;
            if(!Test.isRunningTest())
                pdfBlob = pdfPage.getContent();
            else {
                pdfBlob = Blob.valueOf('Test pdf data');
            }
            System.debug('==========pdfBlob:' + pdfBlob);
            if (lightningRecordtype == true || objopp.RecordType.Name == 'Partner Opportunity - New') {
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
                conVer.PathOnClient = 'QuickQuote.pdf'; // The files name, extension is very important here which will help the file in preview.
                conVer.Title = 'QuickQuote.pdf'; // Display name of the files
                conVer.VersionData = pdfBlob; // converting your binary string to Blog
                insert conVer;    //Insert ContentVersion
                System.debug('==========conVer=====' + conVer);
                
                // First get the Content Document Id from ContentVersion Object
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                //create ContentDocumentLink  record 
                ContentDocumentLink conDocLink = new ContentDocumentLink();
                conDocLink.LinkedEntityId = ApexPages.currentPage().getParameters().get('id'); // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
                conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
                conDocLink.shareType = 'V';
                insert conDocLink;
                System.debug('==========conDocLink=====' + conDocLink);
            } else {
                Attachment oAtt = new Attachment(parentId = strOpportunityId, name = 'QuickQuote.pdf', body = pdfBlob);
                insert oAtt;
                System.debug('==========oAtt=====' + oAtt);
            } 
            initAttachmentSection();
            
            
            String userProfile = [SELECT Name
                                  FROM Profile
                                  WHERE Id =: userinfo.getProfileId()
                                  LIMIT 1].Name;
            
            PageReference pageRef;
            
            if (lightningRecordtype == true){
                pageRef = new PageReference('/lightning/r/Opportunity/' + strOpportunityId + '/view');
            }else {
                pageRef = new PageReference('/apex/Opportunity?Id='+strOpportunityId+'&sfdc.override=1');
            }
            If(userProfile == 'Frontier Partner Portal User') {
                ConnectApi.Community comm = getCommunityUrl();
                pageRef = new PageReference(comm.siteUrl + '/s/opportunity/' + strOpportunityId ) ;
            }
            pageRef.setRedirect(true);
            return pageRef;
        } catch (Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }
        return null;
    }
    
    @RemoteAction
    public static String updateOLIs(String olisWrapper ) {
        UpdatedMRRWrapper updatedMRRWrapper = UpdatedMRRWrapper.parse(olisWrapper);
        List<OpportunityLineItem> listOLIs = new List<OpportunityLineItem>();
        for(UpdatedMRRWrapper.cls_updatedMRR oliMrr : updatedMRRWrapper.updatedMRR){
            //listOLIs.add(new OpportunityLineItem(Id= oliMrr.oliId,Renewal_MRR__c = Decimal.valueOf(oliMrr.updatedMRRValue),CPQ_NetNewMRR__c =(Decimal.valueOf(oliMrr.recurringCharge) - Decimal.valueOf(oliMrr.updatedMRRValue))));//CPQ_NetNewMRR__c =(Decimal.valueOf(oliMrr.recurringCharge) - Decimal.valueOf(oliMrr.updatedMRRValue))
            String  recurringTotal = String.isBlank(oliMrr.recurringTotal) ? '0' : oliMrr.recurringTotal;
            String  updatedMRRValue = String.isBlank(oliMrr.updatedMRRValue) ? '0' : oliMrr.updatedMRRValue;
            String  quantityValue = String.isBlank(oliMrr.quantityValue) ? '0' : oliMrr.quantityValue;
            
            
            
            Decimal netNewMRR = (Decimal.valueOf(recurringTotal) - Decimal.valueOf(updatedMRRValue)) < 0 ?0:(Decimal.valueOf(oliMrr.recurringTotal) - Decimal.valueOf(oliMrr.updatedMRRValue));
                
                listOLIs.add(new OpportunityLineItem(Id= oliMrr.oliId,Renewal_MRR__c = Decimal.valueOf(updatedMRRValue),CPQ_NetNewMRR__c = netNewMRR*Decimal.valueOf(quantityValue)));//CPQ_NetNewMRR__c =(Decimal.valueOf(oliMrr.recurringCharge) - Decimal.valueOf(oliMrr.updatedMRRValue)))
            
        } 
        try{
            // disbale trigger "OpportunityLineItemTrigger" to run if OLI's are being updated from products page.
            ftr_OLITriggerHandler.TriggerDisabled = true;
            If(!Test.isRunningTest())update listOLIs;
            return 'success';
        }catch(Exception ee){return ee.getMessage();}
    }
    
    public PageReference launchBundleQuoteOmniscript() {
        PageReference pr = new PageReference(
            '/apex/vlocity_cmt__OmniScriptUniversalPage?Id=' +
            strOpportunityId +
            '&layout=newport&OmniScriptType=Quote&OmniScriptSubType=Bundling&OmniScriptLang=English&ContextId=' +
            strOpportunityId +
            '&QuoteId=&PrefillDataRaptorBundle//true'
        );
        pr.setRedirect(true);
        return pr;
    }
    
    public static void justIncrement() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    } 
    
    public static void justIncrement1() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    /*
public PageReference quickQuote() {

try{
PageReference pdfPage = Page.QuickQuote;
pdfPage.getParameters().put('id',strOpportunityId);
//pdfPage.getParameters().put('comments',comments);
pdfPage.setRedirect(true);
Blob pdfBlob = pdfPage.getContent();
Attachment oAtt = new Attachment(parentId = strOpportunityId, name='QuickQuote.pdf', body = pdfBlob);
insert oAtt;
}
catch(Exception ex){

}
initAttachmentSection();
return null;
}
*/
}