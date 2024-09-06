//v2
public class Quote_Extension {
    public List<Quote_Extension.QuoteItemGroup> QuoteItems {get;set;}
    public Decimal TotalMRC {get;set;}
    public Decimal TotalNRC {get;set;}
    public String strQuoteItemValue{get;set;} //VJ
    public SterlingQuote__c sterlingQuote {get;set;}//VJ
    public Opportunity opp {get;set;}
    public SterlingQuote__c Quote{get;set;}
    public String oppId;
    public String StrQuote{get; set;}
    public boolean syncButton{get;set;}
    public Opportunity objOpp {get;set;}
    public boolean ShowCreateOrderButton {get;set;}
    public boolean ShowLaunchEONButton {get;set;}
    public List<productCompanyInfo> addressinfo {get;set;}
    public String defaultAddress {get;set;}
    public List<SelectOption> dynamicOptions {get;set;}
    public boolean displayAddressGrid {get;set;}    
    public boolean ShowCreateOrderResponsePopUp {get; set;}
    public Boolean ShowEditButton {get;set;}
    
    public Quote_Extension(ApexPages.StandardController SC) {
       
            // MMG 7/18/2014 Added DiscountAmount__c to selection for discount amount to be on Quote Line Items Section of Quote Page
            string strid = ApexPages.currentPage().getParameters().get('id');
            sterlingQuote = [Select id,RecordTypeid, OrderId__c, RecordType.Name,IsSyncing__c,QuoteType__c,CPQQuoteId__c, OpportunityId__c,Is_Sync_Allowed__c,Sync_Allowed_by_Admin__c from SterlingQuote__c where id=: strid];
            //sQuote = (SterlingQuote__c)SC.getRecord();
            // MMG 04/29/2015 Moved code to get Opp info before setting quote to order button
         //   if(sterlingQuote.OrderId__c == null && sterlingQuote.RecordType.Name == 'Sterling' && sterlingQuote.IsSyncing__c == true ) {
          //      ShowCreateOrderButton = true;
           //     ShowLaunchEONButton = false;
           // }
           // if (sterlingQuote.OrderId__c != null && sterlingQuote.OrderId__c.length() > 0) {
           //     ShowCreateOrderButton = false;
            //    ShowLaunchEONButton = true;
           // }
            syncButton  = sterlingQuote.IsSyncing__c;
            OppId       = sterlingQuote.OpportunityId__c;
            objOpp = [SELECT Account.Name,AccountId,Agent_Billing_Verified_Date__c,Agent_LD_Promo_Residuals__c,Agent_Module__c,Agent_Name__c,Agent_Net_New_MRR_ink__c,Agent_Paid_Amount__c,Agent_Payment_Date__c,Agent_Renewal_MRR__c,Agent_Submit_Date__c,Agt_NRC_ink__c,Agt_Term_Residual__c,Approved_Date__c,Audited_By__c,Audit_Finding_Summary__c,Audit_Results__c,CampaignId,Carrier_Region__c,Casual_Usage_Forecast_Qty__c,Casual_Usage_Forecast__c,City_Approval__c,CloseDate,Contract2__c,Contract_MRR__c,Contract_OLD__c,Contract_Sign_Date__c,CPE_GM_Adjustment__c,CPE_Gross_Margin__c,CPE_NRC_Adjustment__c,CPE_NRC__c,CPE_Product_Count__c,CPE_Product__c,CPE_Team_Count__c,CreatedById,CreatedDate,Date_Audited__c,Date_of_Execution__c,Description,Expected_Billed_Date__c,Fiscal,FiscalQuarter,FiscalYear,ForecastCategory,ForecastCategoryName,Forecast_Type__c,FRONTIER_Expected_Revenue__c,Funding_Assistance__c,GM__c,HasOpportunityLineItem,HSI_Lines_Removed__c,Id,IsClosed,IsDeleted,IsWon,LastModifiedById,LastModifiedDate,LD_Promo_Term__c,LeadSource,Local_Area_Market_State__c,Local_Area_Market__c,Mgr_CPE_NRC__c,Mgr_Net_New_MRR__c,Mgr_NRC__c,Mgr_Renewal_MRR__c,Mgr_Signed_Date__c,Mrg_Approved__c,MRR_Amount__c,Name,Net_New_MRR__c,New_Logo__c,NextStep,NRC__c,Opportunity_Amount__c,Opportunity_Type__c,Other_Finding__c,Other_Reason_Lost_Details__c,OwnerId,Potential_Subscribers__c,Pre_Site_Survey_Completed__c,Pricebook2Id,Pricing_Promotion__c,Probability,Product_name__c,Proposal_Agreement_Submitted__c,Quote_ID__c,Reason_Won_Lost__c,RecordTypeId,Redline_email_no__c,Region__c,Renewal_MRR__c,Renewal_Sales_Stage__c,Previous_MRR__c ,Renewal_Type__c,Renewal_Yes__c,Row_Id__c,RPON_Order__c,Secure_Current_Customers__c,Secure_Potential_Subscribers__c,Site_Survey_Completed__c,StageName,Status_of_Anchor_Proposal_City_Agreement__c,Submitted_Date__c,SyncedQuoteId,SystemModstamp,System_the_Order_Entered_In__c,Territory__c,Total_CPE_NRC__c,Total_Monthly_Amount__c,Total_Weighted_Monthly_Amount__c,Ver_no_for_redline__c,Weighted_CPE_NRC__c,Weighted_Net_New_MRR__c,Weighted_NRC__c,Weighted_Renewal_MRR__c,Weighted_Replacement_Revenue__c,Who_Executed_Contract_on_Cust_Behalf__c,Winback_Competitor__c,Wireless_Market_City__c,Wireless_Market_State__c,Wireless_MRR_Forecast__c,Wireless_Opportunity__c,Wireless_Status__c,Wireless_Total_MRR_Forecast__c FROM Opportunity where id =:OppId];
          //  opp = [SELECT Name,accountid FROM Opportunity WHERE id =: oppId];
            
            // MMG 04/29/2015 Moved code to get Opp info before setting quote to order button
            opp = [SELECT Name,accountid, StageName, Mrg_Approved__c FROM Opportunity WHERE id =: oppId];
            // MMG 6/04/2015 set launch eon to be true when opportunity closed/won and manager signed.
          
            if(sterlingQuote.OrderId__c == null && sterlingQuote.RecordType.Name == 'Sterling' && sterlingQuote.IsSyncing__c == true && opp.StageName == 'Closed/Won' && opp.Mrg_Approved__c == 'Closed (Ink)' ) {
        //    if(sterlingQuote.OrderId__c == null && sterlingQuote.RecordType.Name == 'Sterling' && sterlingQuote.IsSyncing__c == true ) {    
                ShowCreateOrderButton = true;
                ShowLaunchEONButton = false;
            }
            if (sterlingQuote.OrderId__c != null && sterlingQuote.OrderId__c.length() > 0) {
                ShowCreateOrderButton = false;
                ShowLaunchEONButton = true;
            }
            
            strQuote = apexpages.currentpage().getparameters().get('id'); 
            system.debug('=====strQuote:' +strQuote);
            //SterlingQuote__c Quote = (SterlingQuote__c)SC.getRecord();
            Quote = (SterlingQuote__c)SC.getRecord(); 
            TotalMRC = 0.00;
            TotalNRC = 0.00;
            // MMG 7/21/2014 Added Unit Price and calculates as StandardMRC + DiscountAmount for display as List price. 
            List<SterlingQuoteItem__c> listQuoteItems = [
                SELECT 
                    Id, Description__c, CPQLineNumber__c, SA_StreetNrFirst__c, SA_StreetDirection__c, SA_StreetName__c, SA_StreetSuffix__c, Locality__c, StateProvince__c, Postcode__c,MajorLine__c, CPE_NRC_Price__c, CPE_Gross_Margin__c, Renewal_MRR_Original__c,
                    MinorLine__c,ItemCode__c, sterlingquote__r.RecordType.Name,Products__r.Name,OverallStatus__c, promoDiscountAmount__c, Quantity__c, TermLength__c, NumInstallments__c, StandardMRC__c, StandardNRC__c, AdjustedMRC__c, AdjustedNRC__c, DiscountAmount__c, PercentageDiscountAmount__c
                FROM SterlingQuoteItem__c  
                WHERE SterlingQuote__c = :Quote.Id ORDER BY MajorLine__c, MinorLine__c];
            
            ShowEditButton = true;
            
            if(listQuoteItems.size()>0){
                for(SterlingQuoteItem__c sqi : listQuoteItems){
                    if(sqi.OverallStatus__c == 'Pending' && sqi.sterlingquote__r.RecordType.Name == 'Sterling'){
                        ShowEditButton = false;
                    }
                }
            }
            
        //Giri Added
        Map<String,PricebookEntry> mapProPRice = new Map<String, PricebookEntry>();            
        List<PricebookEntry> lstPB  = [SELECT Name,Pricebook2Id,Product2Id,ProductCode,UnitPrice,UseStandardPrice FROM PricebookEntry WHERE PriceBook2.isStandard = TRUE];            
        for(PricebookEntry objPB:lstPB){
            mapProPRice.put(objPB.Name,objPB);           
        }
        //Giri End      
            
        Map<String,List<SterlingQuoteItem__c>> mapQuotesByAddress = new Map<String,List<SterlingQuoteItem__c>>();
        QuoteItems = new List<Quote_Extension.QuoteItemGroup>();
        for(SterlingQuoteItem__c this_item : listQuoteItems){
                system.debug('\n' + 'Discount Amount: ' + this_item.DiscountAmount__c + '\n' + 'Discount Percent: ' + this_item.PercentageDiscountAmount__c + '\n' + 'Standard MRC: ' + this_item.standardMRC__c + '\n\n');
        // MMG 07/22/2014  Set Discount amount to 0 if null                     
                                        if(this_item.DiscountAmount__c == null){ this_item.DiscountAmount__c = 0.00; } 
                                        if(this_item.DiscountAmount__c < 0) {this_item.DiscountAmount__c = -(this_item.DiscountAmount__c);} 
                                        //if(this_item.promoDiscountAmount__c < 0) {this_item.promoDiscountAmount__c = -(this_item.promoDiscountAmount__c);}   
                                        if(this_item.promoDiscountAmount__c == null){ this_item.promoDiscountAmount__c = 0.00; } 
                                        if(this_item.DiscountAmount__c == null && this_item.promoDiscountAmount__c == null){ this_item.DiscountAmount__c = 0.00; } 
                                       // if(this_item.DiscountAmount__c == null && this_item.promoDiscountAmount__c != null){ this_item.DiscountAmount__c = this_item.promoDiscountAmount__c; }          
                                        if(
                                                ((this_item.DiscountAmount__c != null && (this_item.DiscountAmount__c != 0 || this_item.DiscountAmount__c != 0.00)) ||
                                                (this_item.promoDiscountAmount__c != null && (this_item.promoDiscountAmount__c != 0 || this_item.promoDiscountAmount__c != 0.00)))&&
                                                (this_item.StandardMRC__c != null && (this_item.StandardMRC__c != 0 || this_item.StandardMRC__c != 0.00))
                                                
                                        ){
                                                system.debug('\nBEFORE: ' + this_item.PercentageDiscountAmount__c);  
                                                system.debug('======' + this_item.DiscountAmount__c )  ;                                                                              
                                                this_item.PercentageDiscountAmount__c = ((this_item.DiscountAmount__c + this_item.promoDiscountAmount__c)/ this_item.StandardMRC__c)* 100;
                                                system.debug('======' + this_item.PercentageDiscountAmount__c )  ;
                                                system.debug('======' + this_item.DiscountAmount__c )  ;
                                                system.debug('======' + this_item.StandardMRC__c )  ;
                                        
                                                system.debug('\nAFTER: ' + this_item.PercentageDiscountAmount__c);                                              
                                        }else {
                                                this_Item.PercentageDiscountAmount__c = 0.00;
                                        }
            //this_item.AdjustedMRC__c = this_item.StandardMRC__c + this_item.DiscountAmount__c; Giri Commented

            if (this_item.Renewal_MRR_Original__c == null)
                this_item.Renewal_MRR_Original__c = 0.00;           
            
            //Giri Added Start
            if(this_item.AdjustedMRC__c == null)
            if(mapProPRice.get(this_item.Products__r.Name) !=null) 
                 this_item.AdjustedMRC__c  = mapProPRice.get(this_item.Products__r.Name).UnitPrice;
                     
            //Giri Added End  
            if(this_item.AdjustedNRC__c == null){  
                this_item.AdjustedNRC__c = this_item.StandardNRC__c;  
            }  
            
            if (this_item.CPE_NRC_Price__c == null)
                 this_item.CPE_NRC_Price__c = 0.00;
                 
            if (this_item.CPE_Gross_Margin__c == null)
                 this_item.CPE_Gross_Margin__c = 0.00;                 
            
                
            String Address = ConcatenateAddress(this_item);
            if(mapQuotesByAddress.get(Address) != null){
                        List<SterlingQuoteItem__c> list_to_update = mapQuotesByAddress.get(Address);
                        list_to_update.add(this_item);
                        mapQuotesByAddress.put(Address,list_to_update);
            }else{
                        List<SterlingQuoteItem__c> list_to_update = new List<SterlingQuoteItem__c>();
                        list_to_update.add(this_item);
                        mapQuotesByAddress.put(Address,list_to_update);
            }     
            // MMG 4/29/2015 Defect 3381  
            // Mohan Talluri 7/31/2015 Defect 7053
            //TotalMRC = TotalMRC + (this_item.AdjustedMRC__c * this_item.quantity__c) + this_item.Renewal_MRR__c;
            TotalMRC = TotalMRC + ((this_item.AdjustedMRC__c) * this_item.quantity__c);
            
            if(this_item.StandardNRC__c != null){
                TotalNRC = TotalNRC + (this_item.AdjustedNRC__c * this_item.quantity__c) + (this_item.CPE_NRC_Price__c * this_item.quantity__c);
            }else{
                TotalNRC = 0.00;
            }
        }
        for(String this_string : mapQuotesByAddress.keyset()){
                    Quote_Extension.QuoteItemGroup this_qig = new Quote_Extension.QuoteItemGroup();
                    this_qig.Address = this_string;
                    this_qig.Items = mapQuotesByAddress.get(this_string);
                    QuoteItems.add(this_qig);           
        }
        
        addressinfo = new List<productcompanyinfo>();
         String strAddress='';
        displayAddressGrid = false;
        dynamicOptions = new List<SelectOption>();
        dynamicOptions.add(new SelectOption('None','None'));
        defaultAddress = 'None';
        //Know the invocation button source i.e Opportunity            
        Account accRec = [SELECT BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,Legal_Street__c,Legal_City__c,Legal_State__c,Legal_Zip__c,Legal_Country1__c,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode FROM ACCOUNT WHERE id =: opp.accountId];
        
            if( accRec != null ){
                if( accRec.Legal_Street__c != null && accRec.Legal_City__c != null && accRec.Legal_State__c != null ){
                    dynamicOptions.add(new SelectOption('Legal Address','Legal Address'));
                    strAddress = accRec.Legal_Street__c + ',' + accRec.Legal_City__c + ',' + accRec.Legal_State__c + ',' 
                                    + accRec.Legal_Country1__c + ',' + accRec.Legal_Zip__c;
                    strAddress = strAddress.replace(',  ,',',');
                    strAddress = strAddress.replace('null','');
                    strAddress= strAddress.replace(',null,',',');
                    strAddress= strAddress.replace(',null','');
                    strAddress= strAddress.replace('null','');
                    productCompanyInfo objAddInfo1 = new productCompanyInfo();
                    objAddInfo1.strColumnOne='Legal Address';
                    objAddInfo1.strColumnTwo=strAddress;
                    System.Debug('Legal Street --'+strAddress);
                    if( strAddress != '' && strAddress != null ){
                        addressinfo.add(objAddInfo1);
                    }
                }
                if( accRec.BillingStreet != null && accRec.BillingCity != null && accRec.BillingState != null ){
                    dynamicOptions.add(new SelectOption('Billing Address','Billing Address'));
                    strAddress = accRec.BillingStreet + ',' + accRec.BillingCity + ',' + accRec.BillingState + ',' 
                                    + accRec.BillingCountry + ',' + accRec.BillingPostalCode;
                    strAddress = strAddress.replace(',  ,',',');
                    strAddress = strAddress.replace('null','');
                    strAddress= strAddress.replace(',null,',',');
                    strAddress= strAddress.replace(',null','');
                    strAddress= strAddress.replace('null','');
                    productCompanyInfo objAddInfo2 = new productCompanyInfo();
                    objAddInfo2.strColumnOne='Billing Address';
                    objAddInfo2.strColumnTwo=strAddress;
                    if( strAddress != '' && strAddress != null ){
                        addressinfo.add(objAddInfo2);
                    }
                }
                if( accRec.ShippingStreet != null && accRec.ShippingCity != null && accRec.ShippingState != null ){
                    dynamicOptions.add(new SelectOption('Service Address','Service Address'));
                    strAddress = accRec.ShippingStreet + ',' + accRec.ShippingCity + ',' + accRec.ShippingState + ',' 
                                    + accRec.ShippingCountry + ',' + accRec.ShippingPostalCode;
                    strAddress = strAddress.replace(',  ,',',');
                    strAddress = strAddress.replace('null','');
                    strAddress= strAddress.replace(',null,',',');
                    strAddress= strAddress.replace(',null','');
                    strAddress= strAddress.replace('null','');
                    productCompanyInfo objAddInfo3 = new productCompanyInfo();
                    objAddInfo3.strColumnOne='Service Address';
                    objAddInfo3.strColumnTwo=strAddress;
                    if( strAddress != '' && strAddress != null ){
                        addressinfo.add(objAddInfo3);
                    }
                }
            }
        
        if( addressinfo.size() >= 1 ){
            displayAddressGrid = true;
        }    
    }
    
    public class productCompanyInfo{
        public String strColumnOne    {get;set;}
        public String strColumnTwo  {get;set;}
    }   
public PageReference LaunchEON() {
    
        return new PageReference('/apex/WCSHomePageURL');
        
    } 
public PageReference reDirectToSFAQuote(){
        String catalogURL = '';
     //   String btnPhone = ApexPages.currentPage().getParameters().get('btnPhone');
     //   String wtn = ApexPages.currentPage().getParameters().get('wtnnumber');
        
        if(defaultAddress == 'Legal Address'){                   defaultAddress = 'Legal';
        }else if(defaultAddress == 'Billing Address'){           defaultAddress = 'Billing' ;
        }else if(defaultAddress == 'Service Address'){           defaultAddress = 'Service' ;
        }
        //catalogURL ='https://c.cs8.visual.force.com/apex/SterlingQuote?OptionType=NQ&addressType='+defaultAddress +'&accountId='+objOpp.AccountId+'&opportunityId='+objOpp.Id;
        catalogURL ='/apex/productoverridepage?OptionType=NQ&addressType='+defaultAddress +'&oppid='+objOpp.Id + '&strId='+ strQuote;
       // https://c.cs8.visual.force.com/apex/productoverridepage?oppid=006L00000057yGW
        //catalogURL ='/apex/AddProductPages?oppid='+objOpp.Id + '&strId='+ strQuote +'&OptionType=NQ&addressType='+defaultAddress;
        
        PageReference ref = new PageReference(catalogURL);  
       
        System.Debug('URL REDIRECT'+catalogURL);
        ref.setRedirect(true);
        return ref;
    } 

    private String ConcatenateAddress(SterlingQuoteItem__c this_item){
        String Address = '';
        if(this_item.SA_StreetNrFirst__c!= null && this_item.SA_StreetNrFirst__c!= ''){ Address += this_item.SA_StreetNrFirst__c; }
        if(this_item.SA_StreetDirection__c!= null && this_item.SA_StreetDirection__c!= ''){ Address += ' ' + this_item.SA_StreetDirection__c; }
        if(this_item.SA_StreetName__c != null && this_item.SA_StreetName__c != ''){ Address += ' '+ this_item.SA_StreetName__c; }
        if(this_item.SA_StreetSuffix__c!= null && this_item.SA_StreetSuffix__c!= ''){ Address += ' ' + this_item.SA_StreetSuffix__c; }
        if(this_item.Locality__c != null && this_item.Locality__c != ''){ Address += ' '+ this_item.Locality__c; }
        if(this_item.StateProvince__c != null && this_item.StateProvince__c != ''){ Address += ', ' + this_item.StateProvince__c; }
        if(this_item.Postcode__c != null && this_item.Postcode__c != ''){
            String Postcode = '';
            if(this_item.Postcode__c.length() == 9){
                Postcode += this_item.Postcode__c.substring(0,5);
                Postcode += '-';
                Postcode += this_item.Postcode__c.substring(5);
            }else{
                Postcode += this_item.Postcode__c;
            }
            Address += ' ' + Postcode;
        }
        return Address;
    }
    
   public PageReference editQuoteItemMethod() {
        PageReference ref = null;
        if(strQuoteItemValue != null){ 
           SterlingQuoteItem__c sterlingQuoteItem = [Select id,RecordType.Name,SterlingQuote__r.OpportunityId__r.accountid,SterlingQuote__r.OpportunityId__c ,SterlingQuote__c From SterlingQuoteItem__c where id=:strQuoteItemValue];
            Sterlingquote__c strquote =[select id , name, OrderId__c, recordtypeId, recordtype.name from sterlingquote__c where id =: sterlingQuoteItem.sterlingquote__c];                                                         
             system.debug('$$$$$'+sterlingQuoteItem.RecordType.Name);
          /*   if(strquote.RecordType.Name == 'SFA'){
                ref= new PageReference('/'+strQuoteItemValue+'/e?retURL=https%3A%2F%2F'+System.URL.getSalesforceBaseURL().getHost()+'%2Fapex%2Fopportunity%3Fid%3D'+sterlingQuoteItem.SterlingQuote__r.OpportunityId__c+'%26sfdc.override%3D1%26core.apexpages.devmode.url%3D1');// Giri Added   
             }
             else if(strquote.RecordType.Name == 'Sterling'){*/
              //  ref= new PageReference('/apex/NewQuote_SterlingCPQ?uiFlag=OPPORTUNITY&accountId=' + sterlingQuoteItem.SterlingQuote__r.OpportunityId__r.accountid+ '&opportunityId='+sterlingQuoteItem.SterlingQuote__r.OpportunityId__c + '&edit=true&quote=' +sterlingQuoteItem.SterlingQuote__c);
                ref= new PageReference('/apex/SterlingQuote?AccountId='+objOpp.AccountId+'&OpportunityId='+sterlingQuoteItem.SterlingQuote__r.OpportunityId__c+'&OptionType=EQ&QuoteId='+strquote.Id);
        
           //  }
             
        }
        return ref;
    }    
    
        
    public List<SterlingQuoteItem__c> getSterlingQuoteItems() {
        List<Id> sIdList = new List<Id>();
        sIdList.add(Quote.Id);
        return [SELECT Id,CurrentStatus__c,DiscountType__c,DiscountAmount__c,Name,Products__r.Name,ST_SKU__c  FROM SterlingQuoteItem__C WHERE SterlingQuote__r.Id IN :sIdList];
    }
     
        public PageReference redirectToNewSfaProduct(){       
        PageReference ref = new PageReference('/apex/AddProductPages?oppId='+oppId+'&strId='+strQuote);       
        System.Debug('****ref ******'+ref);
        return ref;
    }
    
public boolean getRecordType() {
  RecordType record = [SELECT Id, Name FROM RecordType WHERE Name='SFA' AND sObjectType='SterlingQuote__c'];
  if (Quote.RecordTypeId == record.Id) {
    system.debug('*****VJ'+Quote.RecordTypeId);
    return true;
    } else {
      return false;
          } 
      return null;  
  }
    
 
public pagereference editAction(){
        system.debug('SelectedId    : '+strQuote);
        strQuote = ApexPages.currentPage().getParameters().get('Id');
        SterlingQuote__c objSterlingQuote =[select id, OrderId__c, RecordType.name,recordtypeId from SterlingQuote__c where id =: strQuote];
        system.debug('$$$$$$$$$$$$$$ sterling quote    :'+objSterlingQuote);    
        list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'];
        String strUrl;
        system.debug('$$$$$$$$$$$'+objSterlingQuote.RecordTypeId);
            if(objSterlingQuote.RecordType.Name == 'SFA'){
        //    strURL ='/'+objSterlingQuote.Id+'/e?retURL=https%3A%2F%2Fc.cs8.visual.force.com%2Fapex%2FQuote%3Fid%3D%3Fid%3D'+objSterlingQuote.Id+'%26sfdc.override%3D1%26core';  
            strURL ='/'+objSterlingQuote.Id+'/e?retURL=https%3A%2F%2F'+System.URL.getSalesforceBaseURL().getHost()+'%2Fapex%2FQuote%3Fid%3D'+objSterlingQuote.Id+'%26sfdc.override%3D1%26core.apexpages.devmode.url%3D1';  
            }else{  
            
            // MMG 10/21/2015  Only send sfastatus when finance user 
                     User financed = [Select FinanceUser__c FROM User where id =:userInfo.getUserId() limit 1];  
                if(ShowEditButton && financed.financeuser__c){
                    
                    strUrl = '/apex/SterlingQuote?AccountId='+objOpp.AccountId+'&OpportunityId='+OppId+'&OptionType=EQ&QuoteId='+objSterlingQuote.Id +'&FinanceUser='+financed.financeUser__c+'&SfaStatus=icbApproved';
                }else{
                    strUrl = '/apex/SterlingQuote?AccountId='+objOpp.AccountId+'&OpportunityId='+OppId+'&OptionType=EQ&QuoteId='+objSterlingQuote.Id;
                }
                system.debug('Sterling URL = ' + strUrl);
            }
            pagereference pg = new pagereference(strurl);
            return pg;
        }
        
        // Following was added by Kartez 10/10/14 for new add quantity button on quote page.
        /*    public pagereference addQuantity(){
            system.debug('SelectedId    : '+strQuote);
            strQuote = ApexPages.currentPage().getParameters().get('Id');
            SterlingQuote__c objSterlingQuote =[select id,RecordType.name,recordtypeId from SterlingQuote__c where id =: strQuote];
            system.debug('$$$$$$$$$$$$$$ sterling quote    :'+objSterlingQuote);    
            list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'];
            String strUrl;
            system.debug('$$$$$$$$$$$'+objSterlingQuote.RecordTypeId);
            if(objSterlingQuote.RecordType.Name == 'SFA'){
        //    strURL ='/'+objSterlingQuote.Id+'/e?retURL=https%3A%2F%2Fc.cs8.visual.force.com%2Fapex%2FQuote%3Fid%3D%3Fid%3D'+objSterlingQuote.Id+'%26sfdc.override%3D1%26core';  
                strURL ='/'+objSterlingQuote.Id+'/e?retURL=https%3A%2F%2F'+System.URL.getSalesforceBaseURL().getHost()+'%2Fapex%2FQuote%3Fid%3D'+objSterlingQuote.Id+'%26sfdc.override%3D1%26core.apexpages.devmode.url%3D1';  
            }else{
                strUrl = '/apex/SterlingQuote?AccountId='+objOpp.AccountId+'&OpportunityId='+OppId+'&OptionType=AQ&QuoteId='+objSterlingQuote.Id;
            }
            pagereference pg = new pagereference(strurl);
            return pg;
        }  */

  public PageReference deleteAction(){  
      String strQt = ApexPages.currentPage().getParameters().get('id');
      Utilities.delLineItem(strQuoteItemValue, strQt);  
      String strUrl = '/apex/Quote?id='+strQt+'&sfdc.override=1';
      pagereference pg = new pagereference(strUrl);
      pg.setRedirect(true);
      return pg;
  }     
        
  public PageReference BackCustom() {
        return new PageReference('/lightning/r/Opportunity/'+oppId + '/view');    // changes made on 7/15
    }    
    

    public class QuoteItemGroup{
        public String Address {get;set;}
        public List<SterlingQuoteItem__c> Items {get;set;}
    }

    public PageReference SaveCustom(){
     if(sterlingQuote !=null)
        upsert sterlingQuote ;
        system.debug('*****sterlingQuote'+sterlingQuote);
        strQuote = sterlingQuote.id;
        
        PageReference pg = new PageReference('/apex/sterlingquotepageoverride?id=' + sterlingQuote.id);
        return pg;
    
    }    
   public pageReference productSyncClick()
    {          
      system.debug('&&&&&&&&&&&&'+strQuote);
      productSync(strQuote,sterlingQuote);
    
      PageReference ref = new PageReference('/lightning/r/Opportunity/'+oppId + '/view');
      ref.setRedirect(true);
      return ref;
    }
    public pageReference productUnSyncClick()
    {    
      system.debug('&&&&&&&&&&&&'+strQuote);
      productUnSync(strQuote,sterlingQuote);
      PageReference ref = new PageReference('/lightning/r/Opportunity/'+oppId + '/view');
      ref.setRedirect(true);
      return ref;
    }   
    
  
   //Giridhar ProductSync  
        public static void productSync(String strQuote, SterlingQuote__c sterlingQuote){          
                List<OpportunityLineItem> listOppLineItemInsert= new List<OpportunityLineItem>();
                List<SterlingQuoteItem__c> sterlingQuoteItem = new List<SterlingQuoteItem__c>();
                List<SterlingQuote__c>    sterlingquoteUpdate = new List<SterlingQuote__c>();
                List<SterlingQuoteItem__c> lstSterlingQuoteItemUpdate = new List<SterlingQuoteItem__c>();
                set<Id> sqid                                   = new set<Id>();
                
                sterlingQuoteItem = [SELECT
                                id, Products__c, Quantity__c, CPE_NRC_Price__c, StandardNRC__c, Renewal_MRR_Original__c, TermLength__c, NumInstallments__c, Service_Address__c, Postal_Area__c,
                                AdjustedMRC__c, CPE_Gross_Margin__c,promoDiscountAmount__c, TotalPrice__c, DiscountType__c, DiscountAmount__c, StandardMRC__c, AdjustedNRC__c     //Giri 03/03/2014                             
                        FROM SterlingQuoteItem__c WHERE SterlingQuote__c = :strQuote
                        AND (MinorLine__c = 0 OR MinorLine__c = null or StandardMRC__c != 0 or StandardNRC__c != 0 or DiscountAmount__c != 0 or AdjustedMRC__c != 0)
           //             AND (MinorLine__c = 0 OR MinorLine__c = null)
                ];  
   // MMG 9/10/2014 End             
                system.debug('Product sync sterlingquoteitem   :'+sterlingQuoteItem);
                map<Id,Id> mapProductByPriceBookId = new map<Id,Id>();
  // MMG 9/10/2014 Picked up all the products that have a price book entry. 
                for(PriceBookEntry pb : [SELECT Id, Product2Id, Product2.Id, Product2.MajorProduct__c, Product2.Name FROM PriceBookEntry WHERE PriceBook2.isStandard = TRUE]){
       //         for(PriceBookEntry pb : [SELECT Id, Product2Id, Product2.Id, Product2.MajorProduct__c, Product2.Name FROM PriceBookEntry WHERE PriceBook2.isStandard = TRUE AND Product2.MajorProduct__c = TRUE]){
   // MMG 9/10/2014 End                      
                        mapProductByPriceBookId.put(pb.Product2Id,pb.id);
                }     
                if(sterlingQuoteItem != null && sterlingQuoteItem.size() > 0){
                        for(SterlingQuoteItem__c SQ : sterlingQuoteItem){         
                                  system.debug('******** SQ    : '+SQ);
                                system.debug('****** sq.Products__c  : ' +SQ.Products__c);
                                OpportunityLineItem oppLineIteminsert = new OpportunityLineItem();
                                if(Test.isRunningTest() || (SQ.Quantity__c != null && SQ.Products__c != null && mapProductByPriceBookId.get(SQ.Products__c) != null)){
                                        if(Test.isRunningTest()){
                                            PricebookEntry pricebookEntry =
                                                [SELECT Id,
                                                        Pricebook2Id,
                                                        Product2Id
                                                FROM    PricebookEntry
                                                WHERE   Product2.Id = :SQ.Products__c];
                                                oppLineIteminsert.PricebookEntryId = pricebookEntry.Id;
                                        }else{
                                            oppLineIteminsert.PricebookEntryId = mapProductByPriceBookId.get(SQ.Products__c);
                                        }
                                        oppLineIteminsert.Quantity         = SQ.Quantity__c; 
                                        oppLineIteminsert.CPE_NRC_Price__c = SQ.CPE_NRC_Price__c;     
                                        oppLineIteminsert.NRC_Price__c     = SQ.StandardNRC__c; 
    // MMG 9/24/2014 Populate NRC_Price with AdjustedNRC if exists 
                                        if(SQ.AdjustedNRC__c != 0) oppLineIteminsert.NRC_Price__c = SQ.AdjustedNRC__c;     
                                        if(SQ.TermLength__c == 0.0 )
                                        oppLineIteminsert.Term_Months__c   = SQ.NumInstallments__c;
   // MMG 9/9/2014 Added ContractMRR2 field to the populate section.  This will be the adjustedMRC if that field is not 0 .  If 0 this value will be unit price.
                                       oppLineIteminsert.ContractMRR2__c   = SQ.AdjustedMRC__c;
                                       If(oppLineIteminsert.ContractMRR2__c == 0) oppLineIteminsert.ContractMRR2__c= SQ.StandardMRC__c;
                                                                        // MMG 9/9/2014 End changes 
                                      oppLineIteminsert.CPE_Gross_Margin__c  = SQ.CPE_Gross_Margin__c;
                                        oppLineIteminsert.Opportunityid    = sterlingQuote.OpportunityId__c;
                                        oppLineIteminsert.Opportunity_Sync__c = sterlingQuote.RecordType.Name; 
                                        oppLineIteminsert.UnitPrice          = SQ.StandardMRC__c;    
                                        oppLineIteminsert.quoteitem__c       = SQ.ID;
                                        oppLineIteminsert.Service_Address__c = '';
                                        if (!String.isEmpty(SQ.Service_Address__c))
                                            oppLineIteminsert.Service_Address__c += SQ.Service_Address__c;
                                        if (!String.isEmpty(SQ.Postal_Area__c)) {
                                            if ((oppLineIteminsert.Service_Address__c).equals(''))
                                                oppLineIteminsert.Service_Address__c += SQ.Postal_Area__c;
                                            else    
                                                oppLineIteminsert.Service_Address__c += ' '+SQ.Postal_Area__c;
                                        }
                                        
                                        listOppLineItemInsert.add(oppLineIteminsert);
                                        system.debug('list of opp item to be inserted'+listOppLineItemInsert);
                                        
                                } 
                        }      
                }      
                if(listOppLineItemInsert!= null && listOppLineItemInsert.size() >0){       
                        System.Debug('***listOppLineItemInsert******'+listOppLineItemInsert);
                        insert listOppLineItemInsert;   
                        sterlingQuote.IsSyncing__c = true;
                        system.debug('sterling quote which is updated  : ' +sterlingquote);
                        update sterlingQuote;            
                } 
                if(listOppLineItemInsert !=null && listOppLineItemInsert.size() > 0){  
                        set<id> setNewOppLineItemId = new set<id>();     
                        for(OpportunityLineItem oppLine :listOppLineItemInsert){
                                system.debug('====== oppLine.id : ' +oppLine.id);
                                setNewOppLineItemId.add(oppLine.id);        
                                if(oppLine.quoteitem__c != null){
                                        SterlingQuoteItem__c SQI = new SterlingQuoteItem__c(id=oppLine.quoteitem__c);
                                        SQI.OpportunityLineItemId__c = oppLine.id;
                                        system.debug('=======OpportunityLineItemId__c' + SQI.OpportunityLineItemId__c);
                                        lstSterlingQuoteItemUpdate.add(SQI);
                                }
                        }  
                        System.debug('Mohan ====== New opp LI added which are to be excluded ' + setNewOppLineItemId);
                        List<OpportunityLineItem> oppLineItemDelete = new List<OpportunityLineItem>();        
                        oppLineItemDelete = [SELECT id FROM OpportunityLineItem WHERE OpportunityId=:sterlingQuote.OpportunityId__c AND id NOT IN :setNewOppLineItemId AND Opportunity_Sync__c =:sterlingQuote.RecordType.Name];
                        System.debug('Mohan===oppLineItemDelete' + oppLineItemDelete);
                        if(oppLineItemDelete!= null && oppLineItemDelete.size() >0){          
                                delete oppLineItemDelete;
                        }        
                        List<SterlingQuote__c> lststerlingquote = [SELECT id,IsSyncing__c,QuoteType__c,OpportunityId__c FROM SterlingQuote__c WHERE id !=:strQuote AND IsSyncing__c = TRUE AND RecordTypeid = :sterlingQuote.RecordTypeid AND OpportunityId__c  = :sterlingQuote.OpportunityId__c]; 
                        
                        //if(lststerlingquote != null )
                            //sqid = lststerlingquote.id;
                        //system.debug('======233====lststerlingquote.id' + lststerlingquote.id);
                            
                        //List<SterlingQuoteItem__c> lststerlingquotenew = [SELECT SterlingQuote__c,OpportunityLineItemId__c FROM SterlingQuoteItem__c WHERE SterlingQuote__c = squi]; 
                        if(lststerlingquote != null && lststerlingquote.size() > 0){
                                for(SterlingQuote__c sterqu : lststerlingquote){             
                                        sterqu.IsSyncing__c = false;
                                        sterlingquoteUpdate.add(sterqu);
                                }
                                SterlingQuote__c lststerlingquotenew = [SELECT id FROM SterlingQuote__c WHERE id !=:strQuote AND IsSyncing__c = TRUE AND RecordTypeid = :sterlingQuote.RecordTypeid AND OpportunityId__c  = :sterlingQuote.OpportunityId__c]; 
                         system.debug('======233====lststerlingquoteNEW' + lststerlingquotenew);
                                                string sqid1 = lststerlingquoteNEW.id;
                        list<SterlingQuoteItem__c> lstsqinew = [select id, opportunityLineItemId__c from SterlingQuoteItem__c where SterlingQuote__c =: sqid1];
                        
                        system.debug('======234====sqid1 = ' + sqid1);
                                for(SterlingQuoteItem__c sterqui : lstsqinew) {
                                        system.debug('======235==== sterqui' + sterqui);
                                        sterqui.OpportunityLineItemId__c = '';
                                        
                                        lstSterlingQuoteItemUpdate.add(sterqui);
                                        system.debug('======236==== sterlingquoteUpdate' + sterlingquoteUpdate);
                                }           
                                
                        }
                        if(sterlingquoteUpdate != null && sterlingquoteUpdate.size() > 0){
                                System.Debug('***sterlingquoteUpdate***'+sterlingquoteUpdate);
                                update sterlingquoteUpdate;
                        }       
                        if(lstSterlingQuoteItemUpdate != null &&  lstSterlingQuoteItemUpdate.size() > 0){
                                update lstSterlingQuoteItemUpdate;
                        }       
                }           
        }
    
    //Giridhar Product UnSync 
    public static void productUnSync(String strQuote, SterlingQuote__c sterlingQuote)
    {    
      List<SterlingQuoteItem__c> sterlingQuoteItemDelete = new List<SterlingQuoteItem__c>();
      // MMG 9/17/2014 Added new list for clearing OpportunityLineItemID when Unsyncing 
      List<SterlingQuoteItem__c> SQIUpdate               = new List<SterlingQuoteItem__c>();
      list<OpportunityLineItem> lstOppOtemDelete         = new list<OpportunityLineItem>();
      set<Id> setOppId                                   = new set<Id>();   
      set<Id> setSterlingQuoteId                         = new set<Id>();     
      map<Id,Boolean> mapQuotes                          = new map<Id,Boolean>();
      map<Id,Id> mapQuoteItemIdByOppProductId            = new map<Id,Id>();
      Set<Id> qIdSet                                     = new Set<Id>();
      Set<Id> oppIdSetDelete                             = new Set<Id>(); 
      
      sterlingQuoteItemDelete = [Select id,
                                  Products__c,
                                  Quantity__c,
                                  promoDiscountAmount__c,
                                  CPE_NRC_Price__c,
                                  StandardNRC__c,
                                  Renewal_MRR_Original__c,
                                  TermLength__c,
                                  NumInstallments__c,
                                  AdjustedMRC__c,
                                  CPE_Gross_Margin__c,
                                  TotalPrice__c,
                                  DiscountType__c,
                                  DiscountAmount__c,
                                  StandardMRC__c,
                                  OpportunityLineItemId__c,
                                  SterlingQuote__c                                 
                                  From SterlingQuoteItem__c                                  
                                  where SterlingQuote__c=:strQuote
                          ];    
                         
     for(SterlingQuoteItem__c SQI : sterlingQuoteItemDelete){
        //setSterlingQuoteItemId.add(SQI.id); 
        setSterlingQuoteId.add(SQI.SterlingQuote__c);      
     }
     for(SterlingQuote__c QT:[select Id,IsSyncing__c, OpportunityID__c from SterlingQuote__c where id in : setSterlingQuoteId]){
            setOppId.add(QT.OpportunityId__c);
            mapQuotes.put(QT.id,QT.Issyncing__c);            
     }   
     // MMG 10/1/2014 Selecting on Opportunity Line Items for specific quote
     system.debug('===SetSterlingQuoteId = ' + setSterlingQuoteId);
     system.debug('===StrQuote = ' + strQuote);
      system.debug('===setOppid = ' + setOppid);
     for(Opportunity Opp : [Select id,
                                  (select id,quoteitem__c, Quoteid__c
                                      From OpportunityLineItems
                                       where  
                                       opportunityid in :setOppId  AND quotelineitem__c=null)
                                     From Opportunity WHERE id in :setOppId]
                                 ) {                                   
     // MMG 10/1/2014 Selecting on Opportunity Line Items for specific quote
     system.debug('===OPP = ' + OPP);
          for(OpportunityLineItem oppLineItem : Opp.OpportunityLineItems)
          {
            mapQuoteItemIdByOppProductId.put(oppLineItem.quoteitem__c,oppLineItem.id);
          }       
    }   
    System.debug('================sterlingQuoteItemDelete:'+sterlingQuoteItemDelete);
    System.debug('================sterlingQuoteItemDelete:size: '+sterlingQuoteItemDelete.size());
    
    for(SterlingQuoteItem__c QLI: sterlingQuoteItemDelete){
        if(mapQuotes.get(QLI.sterlingquote__c)){ 
                if(mapQuoteItemIdByOppProductId.get(QLI.id) != null){
                    system.debug('==230====lstOppOtemDelete' + lstOppOtemDelete);
                    OpportunityLineItem  OLU = new OpportunityLineItem(id=mapQuoteItemIdByOppProductId.get(QLI.id));
  // MMG 10/1/2014 Selecting on Opportunity Line Items for specific quote
                    system.debug('===OLU.Quoteid__c = ' + OLU); 
              //      if(OLU.QuoteId__c == strQuote)
                    lstOppOtemDelete.add(OLU);
                    SQIUpdate.add(new SterlingQuoteItem__c(Id = QLI.Id, OpportunityLineItemId__c= null));
                    system.debug('======231== ' + lstOppOtemDelete);
                    if(OLU !=null)
                        system.debug('====opplineitemID' +OLU);
                        oppIdSetDelete.add(OLU.Id);
                    if(QLI.SterlingQuote__c != null)
                        qIdSet.add(QLI.SterlingQuote__c);
                }
         }
         
        // MMG 9/17/2014 Add to list for clearing OpportunityLineItemID when Unsyncing 
                        //SQIUpdate.add(QLI);
    }
   
    System.debug('====lstOppOtemDelete===='+lstOppOtemDelete);
    if(lstOppOtemDelete != null &&  lstOppOtemDelete.size() > 0){
        if(!qIdSet.isEmpty()) { 
            try {
                //List<OpportunityLineItem> oliList = [Select Id, QuoteId__c from OpportunityLineItem where QuoteId__c IN: qIdSet];
                // MMG 10/1/2014 Selecting on Opportunity Line Items for specific quote
                System.debug('setOppId=='+setOppId);
                System.debug('strQuote=='+strQuote);
                List<OpportunityLineItem> oliList = [Select Id, OpportunityId, QuoteId__c  from OpportunityLineItem where OpportunityId IN: setOppId and QuoteId__c =:strQuote AND quotelineitem__c=null];
                //List<OpportunityLineItem> oliList = [Select Id, OpportunityId, QuoteId__c  from OpportunityLineItem where OpportunityId IN: setOppId and QuoteId__c =:strQuote];
                List<OpportunityLineItem> oliList1 = [Select Id, OpportunityId, QuoteId__c  from OpportunityLineItem where OpportunityId IN: setOppId AND QuoteId__c = null AND quotelineitem__c=null];
                System.debug('oliList_New'+oliList1.size());
                System.debug('oliList'+oliList.size());
                if(!oliList.isEmpty()) {
                    system.debug('====oliList' + oliList);
                    for(OpportunityLineItem oli: oliList) {
                        if(!oppIdSetDelete.contains(oli.Id) && oli.id != null)
                            lstOppOtemDelete.add(oli);  
                            system.debug('=====232=== '+ lstOppOtemDelete);         
                    }
                }
                if(!oliList1.isEmpty()) {
                    system.debug('====oliList1' + oliList1);
                    for(OpportunityLineItem oli: oliList1) {
                        if(!oppIdSetDelete.contains(oli.Id) && oli.id != null)
                            lstOppOtemDelete.add(oli);  
                            system.debug('=====232===New == lstOppOtemDelete'+ lstOppOtemDelete);         
                    }
                } 
                
            } catch(Exception e) {
            }
            }
            if(!SQIUpdate.isEmpty())
                //delete SQIUpdate;
                update SQIUpdate;
            System.debug('=================SQIUpdate:' + SQIUpdate);
            System.debug('==========SQIUpdate.size'+SQIUpdate.size());
            system.debug('======before delete unsync====oli' + lstOppOtemDelete);
            system.debug('======before delete unsync size====oli' + lstOppOtemDelete.size());
            delete lstOppOtemDelete;
            
            system.debug('===233==lstOppOtemDelete' + lstOppOtemDelete);
            system.debug('===233==lstOppOtemDelete.size' + lstOppOtemDelete.size());
            sterlingQuote.IsSyncing__c = false;
            update sterlingQuote;
             // MMG 9/17/2014 Added Update for clearing OpportunityLineItemID when Unsyncing 
             
        } 
    }
    public boolean displayPopup {get; set;}     
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    public PageReference deleteCustom(){
        SterlingQuote__c strobj =[select id from SterlingQuote__c where id =: strQuote];
        system.debug('$$$$$$$$$$  deltelink' +strobj);
        list<SterlingQuote__c> lstSterlingQuote  = [SELECT  Id, Name, IsSyncing__c, RecordType.Name  FROM SterlingQuote__c  WHERE OpportunityId__c =: oppid ];
        Map<id,SterlingQuoteItem__c> mapSQLI = new Map<id,SterlingQuoteItem__c>([select id, name from SterlingQuoteItem__c where SterlingQuote__c =: strQuote]);
        List<OpportunityLineItem> lstOpp = [select id,name from OpportunityLineItem where quoteitem__c in: mapSQLI.keyset()];
        lstSterlingQuote  = [SELECT  Id, Name, IsSyncing__c, RecordType.Name  FROM SterlingQuote__c  WHERE OpportunityId__c =: OppId ];
        list<SterlingQuoteItem__c> lstquoteitems =[select id, name from SterlingQuoteItem__c where SterlingQuote__c =: strQuote];
                        /*if(lstOpp.size()>0){
                        delete lstopp;
                        }*/
                       //The agove comented by Vickay and written by Vicky
            if(lstOpp.size()>0) delete lstopp;
            if(lstquoteitems.size()>0){
                delete lstquoteitems;
            }
        delete strobj;
        PageReference pg = new PageReference('/apex/opportunity?id='+oppId);   // change made 7/15
        return pg;   
    } 
    
    public PageReference CreateOrder() {
        String SterlingQuoteId = ApexPages.currentPage().getParameters().get('Id');
        SterlingQuote__c CreateOrderSterlingQuote = [Select id,RecordTypeid, SterlingQuoteId__c,SterlingQuoteKey__c, OrderId__c, RecordType.Name,IsSyncing__c,QuoteType__c,CPQQuoteId__c, OpportunityId__c from SterlingQuote__c where Id=: SterlingQuoteId];
        WS_ESB_CreateOrder.customBeanPort CreateOrderCallout = new WS_ESB_CreateOrder.customBeanPort();
        WS_ESB_CreateOrder.OrderOutputComplexType CreateOrderResponse = null;
        User CurrenUser = [SELECT CSR_ID__C  FROM User WHERE Id =: UserInfo.getUserId()];
        try {
            if(CreateOrderSterlingQuote.SterlingQuoteId__c != null && CreateOrderSterlingQuote.SterlingQuoteKey__c != null) {
                System.debug('===  CreateOrderSterlingQuote.SterlingQuoteId__c :::::::'+CreateOrderSterlingQuote.SterlingQuoteId__c);
                
                CreateOrderResponse = CreateOrderCallout.CreateOrder(CreateOrderSterlingQuote.SterlingQuoteId__c, CreateOrderSterlingQuote.SterlingQuoteKey__c, 'admin');
                if (CreateOrderResponse != null) {
                    if(CreateOrderResponse.OrderNo != null) {
                        system.debug('ORDER NO RECD ::: '+CreateOrderResponse.OrderNo);
                        CreateOrderSterlingQuote.OrderId__c = CreateOrderResponse.OrderNo;
                        update CreateOrderSterlingQuote;
                      //  ShowCreateOrderResponsePopUp = true;
                        sterlingQuote = [Select id,RecordTypeid, SterlingQuoteId__c,SterlingQuoteKey__c, OrderId__c, RecordType.Name,IsSyncing__c,QuoteType__c,CPQQuoteId__c, OpportunityId__c from SterlingQuote__c where Id=: SterlingQuoteId];
                    }
                }
            }
        } catch(Exception e) {
            system.debug(e.getStackTraceString());
        }
        //PageReference PageRef = new PageReference('/apex/WCSHomePageURL');
        //return PageRef;
        return null;
    }
    public void ClosePopUpCreateOrder() {       
        ShowCreateOrderResponsePopUp = false;
    }

    public static Boolean containsProfileForLock(String profileName) {
        // List<String> profiles = new List<String>{'#CTF AccountExec','Frontier Sales User'};
        List<String> profiles = new List<String>{'Frontier Sales User'};
        if (profiles.contains(profileName)) {
            system.debug('###profile');
            return true;
        } else {
            system.debug('###no profile');
            return false;
        }
    }
    
    public static void autoSyncProducts(Map<Id, SObject> items) {
        system.debug('Enter Auto Sync Products');
        //Set<String> quoteIds = new Set<String>();
        // if quote.isSyncing__c = true, dont do anything
        // if quote.isSyncing__c = false, check if sync is allowed by admin flag or sync allowed flag 
        // if there is only 1 quote of a record type, sync
        // else, do nothing
        Id quoteId = (Id)items.values()[0].get('SterlingQuote__c');
        SterlingQuote__c sQuote = [SELECT id,owner.profile.name, OpportunityId__c,RecordType.Name,IsSyncing__c,OrderId__c,Is_Sync_Allowed__c,Sync_Allowed_By_Admin__c  from SterlingQuote__c where id = :quoteId];
        List<SterlingQuote__c> otherQuotes = [Select id From SterlingQuote__c where OpportunityId__c =:sQuote.OpportunityId__c AND RecordType.Name=:sQuote.RecordType.Name AND ID !=:quoteId AND IsSyncing__c = true];
        system.debug('sQuote'+sQuote);
        system.debug('otherQuotes'+otherQuotes);
        // check if the quote is originally syncing, and if either flag is true
        if (sQuote.IsSyncing__c == false && (sQuote.Is_Sync_Allowed__c || sQuote.Sync_Allowed_by_Admin__c) && otherQuotes.size() < 1 && containsProfileForLock(sQuote.owner.profile.name)) {
        //if (sQuote.IsSyncing__c == false && otherQuotes.size() < 1) {
            productSync(quoteId, sQuote);
        }        
        system.debug('Exit Auto Sync Products');
        
    }
}