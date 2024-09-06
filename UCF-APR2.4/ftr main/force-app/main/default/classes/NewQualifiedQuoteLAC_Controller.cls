public class NewQualifiedQuoteLAC_Controller {
    
    @AuraEnabled                                                      
    public static List<productCompanyInfo> quoteEdit_SterlingCPQ(String opportunityId){
        
        List<productCompanyInfo> addressinfo = new List<productCompanyInfo>();
        List<string> addresses = new List<string>();
        Opportunity opp = [SELECT AccountId FROM Opportunity where id =:opportunityId];
        
        String acctid = opp.AccountId;
        String strAddress='';   
        addresses.add('None');
        
        Account accRec = [SELECT BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,Legal_Street__c,Legal_City__c,Legal_State__c,Legal_Zip__c,Legal_Country1__c,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode FROM ACCOUNT WHERE id =: acctid];
        
        if( accRec != null ){
            if( accRec.Legal_Street__c != null && accRec.Legal_City__c != null && accRec.Legal_State__c != null ){
                if(accRec.Legal_Street__c != null){
                    strAddress = accRec.Legal_Street__c;
                }
                if(accRec.Legal_City__c != null){
                    strAddress = strAddress + ', ' + accRec.Legal_City__c;
                }
                if(accRec.Legal_State__c != null){
                    strAddress = strAddress +  ', ' + accRec.Legal_State__c;
                }
                if(accRec.Legal_Country1__c != null){
                    strAddress = strAddress +  ', ' + accRec.Legal_Country1__c;
                }
                if(accRec.Legal_Zip__c != null){
                    strAddress = strAddress +  ', ' + accRec.Legal_Zip__c;
                }
                productCompanyInfo objAddInfo1 = new productCompanyInfo();
                objAddInfo1.strColumnOne='Legal Address';
                objAddInfo1.strColumnTwo=strAddress;
                System.Debug('Legal Street --'+strAddress);
                if( strAddress != '' && strAddress != null ){
                    addressinfo.add(objAddInfo1);
                }
            }
            if( accRec.BillingStreet != null && accRec.BillingCity != null && accRec.BillingState != null ){ 
                addresses.add('Billing Address');
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
                addresses.add('Service Address');
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
        system.debug('addressinfo'+addressinfo);
        return addressinfo;
    }
    
    @AuraEnabled
    public static string reDirectToSterling(String opportunityId, string selectedAddress){
        String catalogURL = '';
        Opportunity objOpp = [SELECT Account.Name,AccountId,Agent_Billing_Verified_Date__c,Agent_LD_Promo_Residuals__c, Previous_MRR__c ,Agent_Module__c,Agent_Name__c,Agent_Net_New_MRR_ink__c,Agent_Paid_Amount__c,Agent_Payment_Date__c,Agent_Renewal_MRR__c,Agent_Submit_Date__c,Agt_NRC_ink__c,Agt_Term_Residual__c,Approved_Date__c,Audited_By__c,Audit_Finding_Summary__c,Audit_Results__c,CampaignId,Carrier_Region__c,Casual_Usage_Forecast_Qty__c,Casual_Usage_Forecast__c,City_Approval__c,CloseDate,Contract2__c,Contract_MRR__c,Contract_OLD__c,Contract_Sign_Date__c,CPE_GM_Adjustment__c,CPE_Gross_Margin__c,CPE_NRC_Adjustment__c,CPE_NRC__c,CPE_Product_Count__c,CPE_Product__c,CPE_Team_Count__c,CreatedById,CreatedDate,Date_Audited__c,Date_of_Execution__c,Description,Expected_Billed_Date__c,Fiscal,FiscalQuarter,FiscalYear,ForecastCategory,ForecastCategoryName,Forecast_Type__c,FRONTIER_Expected_Revenue__c,Funding_Assistance__c,GM__c,HasOpportunityLineItem,HSI_Lines_Removed__c,Id,IsClosed,IsDeleted,IsWon,LastActivityDate,LastModifiedById,LastModifiedDate,LD_Promo_Term__c,LeadSource,Local_Area_Market_State__c,Local_Area_Market__c,Mgr_CPE_NRC__c,Mgr_Net_New_MRR__c,Mgr_NRC__c,Mgr_Renewal_MRR__c,Mgr_Signed_Date__c,Mrg_Approved__c,MRR_Amount__c,Name,Net_New_MRR__c,New_Logo__c,NextStep,NRC__c,Opportunity_Amount__c,Opportunity_Type__c,Other_Finding__c,Other_Reason_Lost_Details__c,OwnerId,Potential_Subscribers__c,Pre_Site_Survey_Completed__c,Pricebook2Id,Pricing_Promotion__c,Probability,Product_name__c,Proposal_Agreement_Submitted__c,Quote_ID__c,Reason_Won_Lost__c,RecordTypeId,Redline_email_no__c,Region__c,Renewal_MRR__c,Renewal_Sales_Stage__c,Renewal_Type__c,Renewal_Yes__c,Row_Id__c,RPON_Order__c,Secure_Current_Customers__c,Secure_Potential_Subscribers__c,Site_Survey_Completed__c,StageName,Status_of_Anchor_Proposal_City_Agreement__c,Submitted_Date__c,SyncedQuoteId,SystemModstamp,System_the_Order_Entered_In__c,Territory__c,Total_CPE_NRC__c,Total_Monthly_Amount__c,Total_Weighted_Monthly_Amount__c,Ver_no_for_redline__c,Weighted_CPE_NRC__c,Weighted_Net_New_MRR__c,Weighted_NRC__c,Weighted_Renewal_MRR__c,Weighted_Replacement_Revenue__c,Who_Executed_Contract_on_Cust_Behalf__c,Winback_Competitor__c,Wireless_Market_City__c,Wireless_Market_State__c,Wireless_MRR_Forecast__c,Wireless_Opportunity__c,Wireless_Status__c,Wireless_Total_MRR_Forecast__c FROM Opportunity where id =:opportunityId];
        
        system.debug('addressinfo'+selectedAddress);
        system.debug('objopp.Opportunity_Type__c'+objopp.Opportunity_Type__c);
        if(selectedAddress == 'Legal Address'){           
            selectedAddress = 'Legal';
        }else if(selectedAddress == 'Billing Address'){           
            selectedAddress = 'Billing' ;
        }else if(selectedAddress == 'Service Address'){           
            selectedAddress = 'Service' ;
        }
        
        if(objopp.Opportunity_Type__c == 'New' || objopp.Opportunity_Type__c == 'Existing' || objopp.Opportunity_Type__c == 'winback'){
            catalogURL ='/apex/SterlingQuote?OptionType=NQ&addressType='+selectedAddress +'&accountId='+objOpp.AccountId+'&opportunityId='+objOpp.Id;
        }else if(objopp.Opportunity_Type__c == 'Renewal'){
            catalogURL ='/apex/SterlingQuote?OptionType=RE&addressType='+selectedAddress +'&accountId='+objOpp.AccountId+'&opportunityId='+objOpp.Id+'&scheduleIds='+objopp.scheduleRenewed__r.Name;
        }
        PageReference ref = new PageReference(catalogURL);  
        System.Debug('URL REDIRECT'+ref.getUrl());
        return ref.getUrl();
    } 
    
    public class productCompanyInfo{
        @AuraEnabled public String strColumnOne {get;set;}
        @AuraEnabled public String strColumnTwo {get;set;}
    }   
}