/**
 * @description       : This class is covered by covers the following test classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2
 * 
**/
public class Account_Extension{
         
    public Account currentAccount {get;set;}
    public WS_ESB_ManageAccount.Callout accountCallout = new WS_ESB_ManageAccount.Callout();
    public List<Memo__c> lstMemo {get; set;}
    public String strBroadband    {get;set;}
    public String strPackage    {get;set;}
    public String strFsecure    {get;set;}
    public String strLongDistance    {get;set;}
    public String strDish   {get;set;}
    public String strCPE    {get;set;}
    
    public boolean isLibraryNOTCT {get;set;}
    public boolean csaProfile {get;set;}
    public boolean isFederalUser {get;set;}
    public boolean isDisabled {get;set;}
         
    public List<AvailableTechnology__c> techData {get; set;}
    public List<AvailableTechnology__c> lstAvailableTech {get; set;}
    public List<Customer_Poducts__c> lstItem {get; set;}
    public List<Promotion__c> lstPromotions {get; set;}
    public List<Directory_Information__c> lstDirectory {get; set;}
    public List<Tax_Information__c> lstOtherTax {get; set;}
    public List<Customer_Poducts__c> lstCustProduct {get; set;}
    public List<Promotion__c> lstPromo {get; set;}
    public List<Directory_Information__c> lstDirectory1 {get; set;}
    public List<Tax_Information__c> lstTaxInformation {get; set;}
    public List<Memo__c> lstMemo1 {get; set;}
    public List<Contact> bizContact{get; set;}
    //public ErrorHandler errHandle;
    
    public Set<String> setItemCode {get; set;}
    public Set<String> setInterlata {get; set;}
    public Set<String> setIntralata {get; set;}
    
    public boolean displayPopup {get; set;}
    public boolean showVmButton {get; set;}
    public string message {get; set;}
    public boolean isVM_Passcode_Diabled;
    
    public Account_Extension(ApexPages.StandardController controller){
        showVmButton = false;
        isVM_Passcode_Diabled = VMUtility.isVMDisabled();
        closePopup();
        
        if(!Test.isRunningTest()){
            controller.addFields(new String[]{'Type','ManageAccount_Updated__c','Library_Id__c','TNSequenceId__c','Promo_Exp_Date__c','ParentSequenceId__c', 'RecordType.Name', 'Federal__c','ShippingStateCode'});
        }
        currentAccount = (Account)controller.getRecord();
        

        if(currentAccount.RecordType.Name != null){
            if(currentAccount.RecordType.Name == 'DPI'){
                pullSalesIndicator(currentAccount.TNSequenceId__c,currentAccount.Library_Id__c);  //getAccount callout with Parameters PhoneNumber and DataRegion
            }
        }
        User usr = [SELECT profile.name FROM User WHERE id=:UserInfo.getUserId()];
        if(usr.Profile.name.contains('Customer Service Analyst')){
            csaProfile = false;
        }else{
            csaProfile = true;
        }  
    }
        
    public PageReference retrieveAccountDetails(){
        system.debug('tests :: '+currentAccount.Type);
        WS_ESB_ManageAccount.ManageAccountGetAccountResponse getAccountResponse = new WS_ESB_ManageAccount.ManageAccountGetAccountResponse();
        if(/*currentAccount.ShippingStateCode == 'OR' ||
           currentAccount.ShippingStateCode == 'MT' ||
           currentAccount.ShippingStateCode == 'ID' ||
           currentAccount.ShippingStateCode == 'WA'*/ currentAccount.Type == 'NWF Account')
        {
            PageReference unauthorizedRedirect = new PageReference('/apex/Unauthorized_NWFRecords');
            unauthorizedRedirect.setRedirect(true);
            return unauthorizedRedirect;   
          }
        if(currentAccount.RecordType.Name != null){
            if(currentAccount.RecordType.Name == 'DPI'){
                for(GroupMember gm : [SELECT Id, Group.Id, Group.Name, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId()]){
                    if(gm.Group.DeveloperName == 'FederalAccountTeam'){
                        isFederalUser = true;
                    }
                }
                try {
                    if(!Test.isRunningTest()){
                        getAccountResponse = accountCallout.GetAccount(currentAccount.TNSequenceId__c,currentAccount.Library_Id__c);
                        if(getAccountResponse.CustomerAccount != null){
                    if(getAccountResponse.CustomerAccount[0].AccessRestriction != null){
                    if(getAccountResponse.CustomerAccount[0].AccessRestriction.restrictedToGroupId != null){
                        if(getAccountResponse.CustomerAccount[0].AccessRestriction.restrictedToGroupId == 'A-FEDRL-01'){
                            if(isFederalUser == false){
                                PageReference unauthorizedRedirect = new PageReference('/apex/Unauthorized_Federal');
                                unauthorizedRedirect.setRedirect(true);
                                return unauthorizedRedirect;
                            }
                        }
                    }
                    }
                    }
                    }else{
                        getAccountResponse = webserviceUtil.doinvoke();
                    } 
                    currentAccount.ManageAccount_Updated__c = System.now();
                    update currentAccount;
                }catch(Exception e){
                    System.debug('getStackTraceString===='+e.getStackTraceString());
                    System.debug('getMessage===='+e.getMessage());
                }
            }
        }
        return null;
    }
        
    public Boolean getShowLoadingAnimation(){
            Boolean result = true;
            try{
                Account thisAccount = [SELECT ManageAccount_Updated__c FROM Account WHERE Id = :currentAccount.Id];            
                if(thisAccount.ManageAccount_Updated__c != null){
                    if(System.now().getTime() - thisAccount.ManageAccount_Updated__c.getTime() < 300000){
                            result = false;
                    }
              }
            }catch(Exception e) {  }
        return result;
    }
        
    public PageReference salesIndicators(){
        
        //Defaults all the Indicators to green before implementing any logic
        strBroadband = 'green';
        strPackage = 'green';
        strCPE='green';
        strDish='green';
        strFsecure='green';
        strLongDistance='green';
        Date curDate = System.today();
        Date PromoExpDate = currentAccount.Promo_Exp_Date__c;           //Promo Expiration Date of the latest CustomerPromotion from the getAccount         
        Integer DaysDifference;
        
        for(GroupMember gm : [SELECT Id, Group.Id, Group.Name, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId()]){
            if(gm.Group.DeveloperName == 'FederalAccountTeam'){
                            isFederalUser = true;
            }
          }
        
        if(currentAccount.Federal__c && isFederalUser == false){
            isDisabled = true;
                PageReference unauthorizedRedirect = new PageReference('/apex/Unauthorized_Federal');
                unauthorizedRedirect.setRedirect(true);
                return unauthorizedRedirect;
            }
        
        if(currentAccount.Promo_Exp_Date__c != null) {  
            DaysDifference = curDate.daysBetween(PromoExpDate);         //Difference between the current date and the Promo Exoiration Date
        } else {
            DaysDifference = 100;
        }
        Map<String,List<Service_Equipment__c>> mapSneCodes = new Map<String,List<Service_Equipment__c>>();
        List<Service_Equipment__c> lstServiceSNE = [SELECT Item_Category__c,Item_Code__c,Name FROM Service_Equipment__c WHERE Item_Category__c != null AND Item_Code__c=:setItemCode];
        
        for(Service_Equipment__c sne: lstServiceSNE) {
            if(sne.Item_Category__c == 'Broadband') {
                mapSneCodes.put(sne.Item_Category__c,lstServiceSNE);        //Comparison between set of SNE Codes to static Broadband Item Codes
            } else if(sne.Item_Category__c == 'Package') {
                mapSneCodes.put(sne.Item_Category__c,lstServiceSNE);        //Comparison between set of SNE Codes to static Package Item Codes
            } else if (sne.Item_Category__c == 'CPE') {
                mapSneCodes.put(sne.Item_Category__c,lstServiceSNE);        //Comparison between set of SNE Codes to static CPE Item Codes
            } else if (sne.Item_Category__c == 'Dish') {
                mapSneCodes.put(sne.Item_Category__c,lstServiceSNE);        //Comparison between set of SNE Codes to static Dish Item Codes
            } else if (sne.Item_Category__c == 'Fsecure') {
                mapSneCodes.put(sne.Item_Category__c,lstServiceSNE);        //Comparison between set of SNE Codes to static FSecure Item Codes
            }
        }
        
        system.debug('daysbetween promoExpDate & Current Date: '+DaysDifference);
        if (setItemCode != null) {
        if(setItemCode.size()>0 ) {
            system.debug('ItemCode Size: '+setItemCode.size());
            if(mapSneCodes.size() > 0) {                                                //Checks if the map is not null
                if(mapSneCodes.get('Broadband') != null && DaysDifference < 90) {       //Determines the Indicator color 
                    strBroadband='yellow';                            
                }else{
                    strBroadband='red';                                                 
                }
                if(mapSneCodes.get('Package') != null && DaysDifference < 90) {
                    strPackage='yellow';                            
                }else{
                    strPackage='red';
                }
                if(mapSneCodes.get('CPE') != null) {
                    strCPE='red';                            
                }
                if(mapSneCodes.get('Dish') != null) {
                strDish='red';                            
                }
                if(mapSneCodes.get('Fsecure') != null) {
                    strFsecure='red';                            
                }
            } else {
                strBroadband='red';
            }
        } else {
            strBroadband='red';
        } 
        }  
        if (setIntralata != null){
        if(setIntralata.size()>0 && setInterlata.size()>0){            //check if Interlata & Intralata sets contains value below
            if(setInterlata.contains('0096') || setInterlata.contains('0000') || setInterlata.contains('5342') || setIntralata.contains('0096') || setIntralata.contains('0000') || setIntralata.contains('5342')){
                strLongDistance='red';
            }
        }  
        }
        
        //Information obtained from the getAccount callout is Inserted. Before the Insertion, if there is unwanted data which exists from the previous callout has to be deleted
        // Delete and Insert DML Operations for all the sObjects which are related to Account Object 
            
        try{ 
        
            if(techData != null) {
                List<AvailableTechnology__c> lstAvailableTech = new List<AvailableTechnology__c>([SELECT Account__c FROM AvailableTechnology__c WHERE Account__c=:currentAccount.id]);
                if(lstAvailableTech != null) {  
                    delete lstAvailableTech;    
                }
                insert techData;    
            }    
            if(lstItem != null) {
                List<Customer_Poducts__c> lstCustProduct = new List<Customer_Poducts__c>([SELECT Account__c FROM Customer_Poducts__c WHERE Account__c=:currentAccount.id]);
                if(lstCustProduct != null) {
                    delete lstCustProduct;  
                }
                insert lstItem; 
            }
            if(bizContact != null){
                List<Contact> conList = [SELECT AccountId from Contact WHERE AccountId =: currentAccount.id];
                if(conList != null){
                    delete conList; 
                }
                insert bizContact;  
            }
            if(lstPromotions != null) {
                List<Promotion__c> lstPromo = new List<Promotion__c>([SELECT Account__c FROM Promotion__c WHERE Account__c=:currentAccount.id]);
                if(lstPromo != null) {
                    delete lstPromo;    
                }
                insert lstPromotions;   
            }
            if(lstOtherTax != null) {
                List<Tax_Information__c> lstTaxInformation = new List<Tax_Information__c>([SELECT Account__c FROM Tax_Information__c WHERE Account__c=:currentAccount.id]);
                if(lstTaxInformation != null) {
                    delete lstTaxInformation;  
                }
                insert lstOtherTax; 
            }
            if(lstMemo != null) {
                List<Memo__c> lstMemo1 = new List<Memo__c>([SELECT Account__c FROM Memo__c WHERE Account__c=:currentAccount.id]);
                if(lstMemo1 != null) {
                    delete lstMemo1;   
                }
                insert lstMemo;    
            } 
            if(lstDirectory != null) {
                System.debug('Directory: '+lstDirectory);
                List<Directory_Information__c> lstDirectory1 = new List<Directory_Information__c>([SELECT Account__c FROM Directory_Information__c WHERE Account__c=:currentAccount.id]);
                if(lstDirectory1 != null) {
                    delete lstDirectory1;    
                }
                insert lstDirectory;   
            }
        } catch (exception e) {
               System.debug('getStackTraceString===='+e.getStackTraceString());
               System.debug('getMessage===='+e.getMessage());
        }
        return null;
    }
        
    public void pullSalesIndicator(String PhoneNumber, String Region){
        if(currentAccount.recordtype.name == 'DPI'){
        techData = new List<AvailableTechnology__c>();
        lstPromotions = new List<Promotion__c>();
        lstDirectory = new List<Directory_Information__c>();
        bizContact = new List<Contact>();
        lstOtherTax = new List<Tax_Information__c>();
        lstItem = new List<Customer_Poducts__c>();
        setItemCode = new set<String>();
        setInterlata = new Set<String>();
        setIntralata = new Set<String>();
        boolean once = true;        
                     
        
            
            if(PhoneNumber != null && Region != null) {
                getMemoCallout(PhoneNumber, Region);
            }                
            WS_ESB_ManageAccount.Callout accountCallOut = new WS_ESB_ManageAccount.Callout();
            WS_ESB_ManageAccount.ManageAccountGetAccountResponse accountResponse;
            
            if(!Test.isRunningTest()){
                try{
                   accountResponse = accountCallOut.GetAccount(PhoneNumber, Region);
                }catch(Exception e){}
            }
            else{
                accountResponse = webserviceUtil.doinvoke();
            }     
            
           try {    
            if(accountResponse != null && accountResponse.CustomerAccount != null && accountResponse.CustomerAccount.size()>0){
                if(accountResponse.CustomerAccount[0].AccountReceivableAging != null) {
                    currentAccount.DPI_Aging_00_30__c = accountResponse.CustomerAccount[0].AccountReceivableAging.Receivable1To30DaysPastDueAmount;
                    currentAccount.DPI_Aging_31_60__c = accountResponse.CustomerAccount[0].AccountReceivableAging.Receivable31To60DaysPastDueAmount;
                    currentAccount.DPI_Aging_61_90__c = accountResponse.CustomerAccount[0].AccountReceivableAging.Receivable61To90DaysPastDueAmount;
                    currentAccount.DPI_Aging_90_Plus__c = accountResponse.CustomerAccount[0].AccountReceivableAging.ReceivableOver90DaysPastDueAmount;
               }
               if(accountResponse.CustomerAccount[0].FederalTaxExemptFlag != null) {
                    currentAccount.Federal_Tax_Exempt__c = accountResponse.CustomerAccount[0].FederalTaxExemptFlag;
               }
               if(accountResponse.CustomerAccount[0].CustomerAccountPromotion != null){
                    if(accountResponse.CustomerAccount[0].CustomerAccountPromotion[0].PromotionStatus == 'Active'){                                //ContractStartDate should be populated only if promostatuc is 'Active'
                        currentAccount.Promo_Exp_Date__c = accountResponse.CustomerAccount[0].CustomerAccountPromotion[0].ContractEndDate;
                    } 
               }
               if(accountResponse.CustomerAccount[0].AccessRestriction != null){
                if(accountResponse.CustomerAccount[0].AccessRestriction.restrictedToGroupId != null){
                    if(accountResponse.CustomerAccount[0].AccessRestriction.restrictedToGroupId == 'A-FEDRL-01'){
                        currentAccount.Federal__c = true;
                    }
                }
               }
               for(WS_ESB_BusinessObjects.CustomerAccount getAccountResponse: accountResponse.CustomerAccount){
                    if(getAccountResponse.Customer != null){
                        if(getAccountResponse.Customer.CustomerCreditprofile.BusinessOwner != null){
                            for(WS_ESB_BusinessObjects.IndividualContact iContact : getAccountResponse.Customer.CustomerCreditProfile.BusinessOwner){
                                if(iContact.TelePhoneNumber != null && once){
                                    Contact newContact = new Contact(ContactName__c = iContact.Name,
                                                                    AccountId = currentAccount.id,
                                                                    LastName = iContact.Name,
                                                                    Contact_Type__c = 'Business Owner',
                                                                    Phone = iContact.TelephoneNumber.Number_x);
                                   bizContact.add(newContact);
                                   once = false;
                                }
                            }
                        }
                        if(getAccountResponse.Customer.CustomerCreditprofile.Manager != null){
                            if(getAccountResponse.Customer.CustomerCreditProfile.Manager.TelephoneNumber != null){
                                Contact newContact = new Contact(ContactName__c = getAccountResponse.Customer.CustomerCreditProfile.Manager.Name,
                                                                 AccountId = currentAccount.id,
                                                                 Contact_Type__c = 'Manager',
                                                                 LastName = getAccountResponse.Customer.CustomerCreditProfile.Manager.Name,
                                                                 Phone = getAccountResponse.Customer.CustomerCreditProfile.Manager.TelephoneNumber.Number_x);
                                bizContact.add(newContact);                                 
                            }
                        }
                        if(getAccountResponse.Customer.CustomerCreditprofile.BillingContact != null){
                            if(getAccountResponse.Customer.CustomerCreditprofile.BillingContact.TelephoneNumber != null){
                                Contact newContact = new Contact(ContactName__c = getAccountResponse.Customer.CustomerCreditProfile.BillingContact.Name,
                                                                 AccountId = currentAccount.id,
                                                                 Contact_Type__c = 'Billing Contact',
                                                                 LastName = getAccountResponse.Customer.CustomerCreditProfile.BillingContact.Name,  
                                                                 Phone = getAccountResponse.Customer.CustomerCreditProfile.BillingContact.TelephoneNumber.Number_x);
                                bizContact.add(newContact);  
                            }
                                
                        }
                        if(getAccountResponse.Customer.CustomerCreditProfile.AdditionalBusinessCreditInformation.TechnicalContact != null) {
                            if(getAccountResponse.Customer.CustomerCreditProfile.AdditionalBusinessCreditInformation.TechnicalContact.TelephoneNumber != null){
                                Contact newContact = new Contact(ContactName__c = getAccountResponse.Customer.CustomerCreditProfile.AdditionalBusinessCreditInformation.TechnicalContact.Name,
                                                                 AccountId = currentAccount.id,
                                                                 Contact_Type__c = 'Technical Contact',
                                                                 LastName = getAccountResponse.Customer.CustomerCreditProfile.AdditionalBusinessCreditInformation.TechnicalContact.Name,  
                                                                 Phone = getAccountResponse.Customer.CustomerCreditProfile.AdditionalBusinessCreditInformation.TechnicalContact.TelephoneNumber.Number_x);
                                bizContact.add(newContact);  
                            }
                        }
                            
                        }
                    
                    WS_ESB_BusinessObjects.Price pr = null;
                    if(getAccountResponse.Item != null) {
                        for(WS_ESB_BusinessObjects.Item itemInfo: getAccountResponse.Item){
                            pr = null; 
                            if(itemInfo.ValidFor != null) {
                                Customer_Poducts__c iTem = new Customer_Poducts__c();
                                iTem.Account__c = currentAccount.id;
                                iTem.Code__c =  itemInfo.ItemCode;
                                setItemCode.add(iTem.Code__c);                  //SNE Codes 
                                iTem.CustomeProductName__c = itemInfo.Description;
                                iTem.ChargeType__c =  itemInfo.ChargeType;
                                iTem.Install_Order_Id__c = itemInfo.InstallOrderId;
                                iTem.Generic_Sku__c = itemInfo.ProductCatalogInformation.GenericSku;
                                
                                //added Sunil for voicemail reset
                                if(!isVM_Passcode_Diabled && iTem.Generic_Sku__c != null && !showVmButton){ 
                                    System.debug('iTem.Generic_Sku__c  -- '+iTem.Generic_Sku__c);                   
                                    showVmButton = VMUtility.checkSkuKey(iTem.Generic_Sku__c);
                                }
                                
                                if (itemInfo.Price!=null && !itemInfo.Price.isEmpty())
                                  pr = itemInfo.Price[0];
                                
                                if (pr != null) {
                                    if (pr.Quantity.Amount != null) 
                                         iTem.MonthlyRecurringCharge__c = Decimal.valueOf(pr.Quantity.Amount);
                                    else 
                                         iTem.NonRecurringAmount__c = Decimal.valueOf(pr.Quantity.Amount);
                                }
                                if(itemInfo.ValidFor.StartDateTime != null) {
                                    DateTime DateField = itemInfo.ValidFor.StartDateTime;
                                    iTem.StartDate_Time__c = DateField.format('MM/dd/yyyy hh:mm a');
                                }
                                if(itemInfo.ValidFor.EndDateTime != null) { iTem.EndDate_Time__c = itemInfo.ValidFor.EndDateTime; }
                                lstItem.add(iTem);
                            }
                        }
                    }
                    if(getAccountResponse.Package_x != null) {
                        for(WS_ESB_BusinessObjects.Package_x pack: getAccountResponse.Package_x) {
                            if(pack.PackageItem != null) {
                                pr = null;
                                Customer_Poducts__c iTem = new Customer_Poducts__c();
                                iTem.Account__c = currentAccount.id;
                                iTem.Code__c =  pack.PackageItem.ItemCode;
                                setItemCode.add(iTem.Code__c);
                                iTem.CustomeProductName__c = pack.PackageItem.Description;
                                iTem.ChargeType__c =  pack.PackageItem.ChargeType;
                                iTem.Install_Order_Id__c = pack.PackageItem.InstallOrderId;
                                iTem.Generic_Sku__c = pack.PackageItem.ProductCatalogInformation.GenericSku;
                                
                                //added Sunil for voicemail reset
                                if(!isVM_Passcode_Diabled && iTem.Generic_Sku__c != null && !showVmButton){ 
                                    System.debug('iTem.Generic_Sku__c  -- '+iTem.Generic_Sku__c);                   
                                    showVmButton = VMUtility.checkSkuKey(iTem.Generic_Sku__c);
                                }
                           

                                if (pack.PackageItem.Price!=null && !pack.PackageItem.Price.isEmpty())
                                    pr = pack.PackageItem.Price[0];
                                    
                                if (pr != null) {                            
                                   if(pr.Quantity.Amount != null) 
                                        iTem.MonthlyRecurringCharge__c = Decimal.valueOf(pr.Quantity.Amount);
                                   else 
                                        iTem.NonRecurringAmount__c = Decimal.valueOf(pr.Quantity.Amount); 
                                }
                                DateTime DateField = pack.PackageItem.ValidFor.StartDateTime;
                                iTem.StartDate_Time__c = DateField.format('MM/dd/yyyy hh:mm a');
                                if(pack.PackageItem.ValidFor.EndDateTime != null) { iTem.EndDate_Time__c = pack.PackageItem.ValidFor.EndDateTime; }
                                lstItem.add(iTem);
                                
                            }
                            if(pack.Item != null) {
                                for(WS_ESB_BusinessObjects.Item Itempack: pack.Item) {
                                    pr = null;
                                    Customer_Poducts__c iTem = new Customer_Poducts__c();
                                    iTem.Account__c = currentAccount.id;
                                    iTem.Code__c =  Itempack.ItemCode;
                                    setItemCode.add(iTem.Code__c);
                                    iTem.CustomeProductName__c = Itempack.Description;
                                    iTem.ChargeType__c =  Itempack.ChargeType;
                                    iTem.Install_Order_Id__c = Itempack.InstallOrderId;
                                    iTem.Generic_Sku__c = Itempack.ProductCatalogInformation.GenericSku;
                                    
                                    //added Sunil for voicemail reset
                                    if(!isVM_Passcode_Diabled && iTem.Generic_Sku__c != null && !showVmButton){ 
                                        System.debug('iTem.Generic_Sku__c  -- '+iTem.Generic_Sku__c);                   
                                        showVmButton = VMUtility.checkSkuKey(iTem.Generic_Sku__c);
                                    }

                                    if (Itempack.Price!=null && !Itempack.Price.isEmpty())
                                      pr = Itempack.Price[0];
                                    
                                    if (pr != null) {    
                                        if(pr.Quantity.Amount != null) {     iTem.MonthlyRecurringCharge__c = Decimal.valueOf(pr.Quantity.Amount);    }
                                        else { iTem.NonRecurringAmount__c = Decimal.valueOf(pr.Quantity.Amount); }
                                    }
                                    DateTime DateField = Itempack.ValidFor.StartDateTime;
                                    iTem.StartDate_Time__c = DateField.format('MM/dd/yyyy hh:mm a');
                                    if(Itempack.ValidFor.EndDateTime != null) { iTem.EndDate_Time__c = Itempack.ValidFor.EndDateTime; }
                                    lstItem.add(iTem);
                                    System.debug(JSON.serializepretty(item));
                                }   
                            }
                        }
                    }
                    //if(setItemCode.size() >0 ){
                    //    if(setItemCode.contains('FED')){
                    //        currentAccount.Federal__c = true;
                    //    }
                    //}
                    if(getAccountResponse.CustomerAccountPromotion != null) {
                        for(WS_ESB_BusinessObjects.Promotion promotion: getAccountResponse.CustomerAccountPromotion) {
                            Promotion__c accPromo = new Promotion__c();
                            accPromo.Account__c = currentAccount.id;
                            accPromo.Promotion__c = promotion.Description;
                            accPromo.InDate__c = promotion.ContractStartDate;
                            accPromo.CreditEnd__c = promotion.ContractEndDate;
                            accPromo.Status__c = promotion.PromotionStatus;
                            accPromo.Discount_ItemCode__c = promotion.DiscountedItem.ItemCode;
                            accPromo.Order_ItemCode__c = promotion.OrderReference.OrderedItemCode;
                            if(promotion.AutoRenewStatus == 'AutoRenewNotAvailable') {       accPromo.AutoRenewal__c = 'N/A';   }
                            else if(promotion.AutoRenewStatus == 'AutoRenewAuthorized') {   accPromo.AutoRenewal__c = 'Yes';      }
                            else if(promotion.AutoRenewStatus == 'AutoRenewNotAuthorized') { accPromo.AutoRenewal__c = 'No';  } 
                            Date InDate =  promotion.ContractStartDate;
                            Date curDate = System.today();
                            Date EndDate = promotion.ContractEndDate;
                            Double Fraction = Double.ValueOf((curDate.daysBetween(EndDate))+1)/(Double.ValueOf(InDate.daysbetween(EndDate)+1));
                            //Fraction = Fraction.pow(2);
                            if(promotion.PenaltyAmountProratedFlag == false) { 
                                accPromo.Cancel_Amount__c =  promotion.ConfiguredPenaltyAmount;
                            } else if (promotion.PenaltyAmountProratedFlag == true){
                                accPromo.Cancel_Amount__c = (Fraction*(promotion.ConfiguredPenaltyAmount));
                            }
                            system.debug('Nominator: '+(curDate.daysBetween(EndDate))+'Denominator: '+(InDate.daysbetween(EndDate))+'Fraction: '+Fraction+'Penalty Amount: '+accPromo.Cancel_Amount__c);
                            accPromo.Override__c = promotion.OverrideCode;
                            if(promotion.PromotionStatus == 'Active') {
                                lstPromotions.add(accPromo);
                            }
                        }
                    }
                    if(getAccountResponse.DirectoryListing != null) {
                        for(WS_ESB_BusinessObjects.DirectoryListing dirLst: getAccountResponse.DirectoryListing) {
                            for(WS_ESB_BusinessObjects.DirectoryListingInfo dirLstInfo: dirLst.DirectoryListingInfo) {
                                Directory_Information__c directoryInfo = new Directory_Information__c();
                                directoryInfo.Listing_Code__c = getAccountResponse.DirectoryListingType;
                                directoryInfo.Account__c = currentAccount.id;
                                directoryInfo.Listing_Seq__c = dirLst.ListingSequence; 
                                directoryInfo.Line__c = dirLstInfo.LineNumber;
                                directoryInfo.Mailing_Address__c = dirLstInfo.DirectoryTextLine;
                                for(WS_ESB_BusinessObjects.DirectoryCode dirCode: dirLstInfo.DirectoryCode) {
                                    if(dirCode.CodeNumber == 1) {
                                    directoryInfo.Directory_Code_1__c = dirCode.DirectoryCode;
                                    } 
                                    if (dirCode.CodeNumber == 2) {
                                        directoryInfo.Directory_Code_2__c = dirCode.DirectoryCode;
                                    } 
                                    if (dirCode.CodeNumber == 3) {
                                        directoryInfo.Directory_Code_3__c = dirCode.DirectoryCode;
                                    }
                                }
                                lstDirectory.add(directoryInfo);
                            }
                        }
                    }   
                    if(getAccountResponse.InternetInfo != null) {
                        currentAccount.DPI_ModemVendor__c = getAccountResponse.InternetInfo.ModemOwnership;
                        if(getAccountResponse.InternetInfo.Connections != null){
                                for(WS_ESB_BusinessObjects.ConnectionType connection: getAccountResponse.InternetInfo.Connections.Connection){
                                if(connection.Technologies != null) {
                                     for(WS_ESB_BusinessObjects.TechnologyType techInfo: connection.Technologies.Technology) {
                                       AvailableTechnology__c avaTech = new AvailableTechnology__c();
                                       avaTech.Account__c = currentAccount.id;
                                       avaTech.Technology_Group__c = techInfo.TechnologyGroup;
                                       avaTech.Technology_Item__c = techInfo.TechnologyItem;
                                       avaTech.Technology__c = techInfo.Technology;
                                       avaTech.Tech_Feature__c = techInfo.TechFeature;
                                       avaTech.PrePaid_BroadBand_Capable__c = techInfo.PrePaidBroadBandCapableFlag;
                                       avaTech.Max_Dslam_Speed__c = techInfo.MaxDslamSpeed;
                                       avaTech.Market_Offering__c = techInfo.MarketOffering;
                                       avaTech.Default_Modem__c = techInfo.DefaultModem;
                                       avaTech.Customer_Type__c = techInfo.CustomerType;
                                       avaTech.Available_Speed__c = techInfo.AvailableSpeed;
                                       avaTech.Additional_Speed_Info__c = techInfo.AdditionalSpeedInfo;
                                       if(techInfo.CustomerType == 'Business') {
                                           techData.add(avaTech);
                                       }
                                   }
                               }
                            }
                        }
                    }
                    if(getAccountResponse.ProvisioningData != null) {
                        for(WS_ESB_BusinessObjects.CharacteristicValue proData: getAccountResponse.ProvisioningData) {
                            if(proData.CharacteristicValue != null) {
                                for(WS_ESB_BusinessObjects.CharacteristicValue charvalue: proData.CharacteristicValue) {
                                    if(charvalue.Characteristic == 'UserName') {
                                        currentAccount.DPI_HSIUserName__c = charvalue.Value;
                                    }
                                    if(charvalue.Characteristic == 'SecurityType') {
                                        currentAccount.Security_Type__c = charvalue.Value;
                                    }
                                    if(charvalue.Characteristic == 'HSIProduct') {
                                        currentAccount.Product_Plan__c = charvalue.Value;
                                    }
                                    if(charvalue.Characteristic == 'DomainName') {
                                        currentAccount.Domain__c = charvalue.Value;
                                    }
                                    if(charvalue.Characteristic == 'WanIPAddress') {
                                        currentAccount.WAN_IP_Address__c = charvalue.Value;
                                    }
                                    if(charvalue.Characteristic == 'LanIPAddress') {
                                        currentAccount.LAN_IP_Address__c = charvalue.Value;
                                    }
                                    if(charvalue.Characteristic == 'SecurityAnswer') {
                                        currentAccount.Security_Info__c = charvalue.Value;
                                    }
                                    if(charvalue.Characteristic == 'ContactPhone') {
                                        if(charvalue.Value == '0') {
                                            currentAccount.ISP_Contact_Phone__c = '000/000-0000';
                                        } else {
                                            currentAccount.ISP_Contact_Phone__c = charvalue.Value;
                                        }
                                    }
                                    if(charvalue.Characteristic == 'FilterQuantity') {
                                        currentAccount.Filter_In_Line__c = charvalue.Value;
                                    }
                                    if(charvalue.Characteristic == 'WallMountQuantity') {
                                        currentAccount.Wall_Mount__c = charvalue.Value;
                                    }
                                    if(charvalue.Characteristic == 'DMARCSplittersIndicator') {
                                        currentAccount.Splitters_Y_N__c = charvalue.Value;
                                    }
                                    if(charvalue.Characteristic == 'FullInstallIndicator') {
                                        currentAccount.Full_Install__c = charvalue.Value;
                                    }
                                    if(charvalue.Characteristic == 'NetworkSize') {
                                        currentAccount.Network_Size_V4__c = charvalue.Value;
                                    }
                                }
                            }
                        }
                    }
                    if(getAccountResponse.DisconnectDate != null) {
                        currentAccount.DPI_DisconnectDate__c = getAccountResponse.DisconnectDate;
                    }   
                    if(getAccountResponse.ServiceType != null) {
                        currentAccount.DPI_ServiceType__c = getAccountResponse.ServiceType.Name;                                     //Check for Service type field
                    }
                    if(getAccountResponse.PersonalIdentificationNumber != null) {
                        currentAccount.DPI_PIN__c = getAccountResponse.PersonalIdentificationNumber;        
                    } 
                    if(getAccountResponse.CustomerBill != null){
                        if(String.valueof(getAccountResponse.CustomerBill.LastBillCycle) != null) {
                            currentAccount.DPI_BillCycle__c = String.valueof(getAccountResponse.CustomerBill.LastBillCycle);                             //Populate Bill Cycle
                        }
                        if(getAccountResponse.CustomerBill.PaymentDueDate != null) {
                            currentAccount.DPI_CurrentDueDate__c = getAccountResponse.CustomerBill.PaymentDueDate;                       //Populate Current Due Date
                        }
                    }
                    
                    system.debug('Promo Date: '+currentAccount.Promo_Exp_Date__c); 
                    if(getAccountResponse.interLATA != null) {
                        for(WS_ESB_BusinessObjects.LATA lataInfo: getAccountResponse.interLATA){
                            if(lataInfo.LATAType == 'interlata') {                               //Check the latatype 
                                setInterlata.add(lataInfo.OperatingCompanyNumber);
                            }
                        }
                        if(getAccountResponse.interLATA[0].LATAType == 'interlata') { 
                            currentAccount.CustAccount_Interlata_Carrier__c = getAccountResponse.interLATA[0].OperatingCompanyNumber;
                        }
                    }
                    if(getAccountResponse.intraLATA != null) {
                        for(WS_ESB_BusinessObjects.LATA lataInfo: getAccountResponse.intraLATA) {
                            if(lataInfo.LATAType == 'intralata')
                                setIntralata.add(lataInfo.OperatingCompanyNumber);
                        }
                        if(getAccountResponse.intraLATA[0].LATAType == 'intraLATA') { 
                            currentAccount.CustAccount_Intralata_Carrier__c = getAccountResponse.intraLATA[0].OperatingCompanyNumber;
                        }
                    }
                       
                    if(getAccountResponse.AuthorizedCustomerProxy != null) {
                        system.debug('SSN String: '+String.ValueOf(getAccountResponse.AuthorizedCustomerProxy.Individual.SocialSecurityNrIdentification.SocialSecurityNr));
                        if(String.ValueOf(getAccountResponse.AuthorizedCustomerProxy.Individual.SocialSecurityNrIdentification.SocialSecurityNr) != '00' || String.ValueOf(getAccountResponse.AuthorizedCustomerProxy.Individual.SocialSecurityNrIdentification.SocialSecurityNr) != '0') {
                            system.debug('inside the condition:');
                            Integer sizeOfSSN = getAccountResponse.AuthorizedCustomerProxy.Individual.SocialSecurityNrIdentification.SocialSecurityNr.length();
                            if(getAccountResponse.AuthorizedCustomerProxy.Individual.SocialSecurityNrIdentification.SocialSecurityNr.length() == 9) {
                                currentAccount.DPI_SSN__c = getAccountResponse.AuthorizedCustomerProxy.Individual.SocialSecurityNrIdentification.SocialSecurityNr.subString(sizeOfSSN-4, sizeOfSSN);
                            }
                        }
                    }
                    
                    if(getAccountResponse.GlobalAccountId != null && String.ValueOf(getAccountResponse.GlobalAccountId) != '0') {
                        if(getAccountResponse.GlobalAccountId.AccountNumber != null && getAccountResponse.GlobalAccountId.AccountNumber != '0') { 
                            currentAccount.DPI_GanID__c = getAccountResponse.GlobalAccountId.AccountNumber;
                        }
                    } 
                    String strBilling;
                    if(getAccountResponse.Customer != null) { 
                        if(String.ValueOf(getAccountResponse.Customer.CustomerCreditProfile.AdditionalBusinessCreditInformation.FederalTaxId) != null && String.ValueOf(getAccountResponse.Customer.CustomerCreditProfile.AdditionalBusinessCreditInformation.FederalTaxId) != '0') {
                            String FederalTaxID = String.ValueOf(getAccountResponse.Customer.CustomerCreditProfile.AdditionalBusinessCreditInformation.FederalTaxId);
                            if(FederalTaxID.length() == 9) {
                                currentAccount.DPI_Federal_Tax_ID_No__c = FederalTaxID.substring(0,2)+' - '+FederalTaxID.substring(2,9);
                            } else {
                                currentAccount.DPI_Federal_Tax_ID_No__c = FederalTaxID;
                            }
                        } 
                        if(getAccountResponse.Customer.CustomerCreditProfile.AdditionalBusinessCreditInformation.RefusedSSN != null) {
                            currentAccount.DPI_Customer_Refused_to_Provide_SSN__c = getAccountResponse.Customer.CustomerCreditProfile.AdditionalBusinessCreditInformation.RefusedSSN;
                        }      
                        if(getAccountResponse.Customer.Organization != null && currentAccount.Company_Name__c == null) {
                            currentAccount.Company_Name__c = getAccountResponse.Customer.Organization.OrganizationName.TradingName;
                        } else if(getAccountResponse.Customer.Individual != null && currentAccount.Company_Name__c == null) {
                            if(getAccountResponse.Customer.Individual.IndividualName != null) {
                                currentAccount.Company_Name__c = getAccountResponse.Customer.Individual.IndividualName.FamilyNames+getAccountResponse.Customer.Individual.IndividualName.GivenNames;
                            }
                        }
                        currentAccount.DPI_CustAuthID__c = getAccountResponse.Customer.CustomerCreditProfile.AuthorizationId;
                        if(getAccountResponse.Customer.CustomerCreditProfile.AccountRepresentative != null) {
                            if(getAccountResponse.Customer.CustomerCreditProfile.AccountRepresentative.Name != null) {
                            currentAccount.AccountOwner__c =  getAccountResponse.Customer.CustomerCreditProfile.AccountRepresentative.Name;
                            }
                        }
                        if(getAccountResponse.Customer.CustomerCreditProfile.Password != null) {
                                currentAccount.DPI_AccountPW__c = getAccountResponse.Customer.CustomerCreditProfile.Password;
                        }
                        if(getAccountResponse.Customer.CustomerCreditProfile.RedFlagMessage != null) {
                            currentAccount.DPI_Red_Flag__c = getAccountResponse.Customer.CustomerCreditProfile.RedFlagMessage[0].ReasonCode.Code;
                            if(getAccountResponse.Customer.CustomerCreditProfile.RedFlagMessage[0].DispositionCode != null) {
                                currentAccount.DPI_Disposition__c = getAccountResponse.Customer.CustomerCreditProfile.RedFlagMessage[0].DispositionCode.Code;
                            }
                        }
                        currentAccount.DPI_Credit_Rating__c = getAccountResponse.Customer.CustomerCreditProfile.InternalCreditRating;
                        currentAccount.DPI_Credit_Score__c = getAccountResponse.Customer.CustomerCreditProfile.CreditScore;
                        currentAccount.DPI_Bankruptcy_Flag__c = getAccountResponse.Customer.CustomerCreditProfile.BankruptcyFlag;
                        currentAccount.DPI_TypeofBusiness__c = getAccountResponse.Customer.CustomerCreditProfile.BusinessType;
                        currentAccount.DPI_RentOwnBuy__c = getAccountResponse.Customer.CustomerCreditProfile.HousingStatus;
                        if(getAccountResponse.Customer.CitizensPostalAddress != null) {
                            system.debug('Citizen address: '+getAccountResponse.Customer.CitizensPostalAddress);
                            currentAccount.BillingStateCode = getAccountResponse.Customer.CitizensPostalAddress.StateOrProvince;
                            currentAccount.BillingCity = getAccountResponse.Customer.CitizensPostalAddress.Locality;
                            if(getAccountResponse.Customer.CitizensPostalAddress.Postcode.length()>5) {
                                Integer i = getAccountResponse.Customer.CitizensPostalAddress.Postcode.length();
                                currentAccount.BillingPostalCode = getAccountResponse.Customer.CitizensPostalAddress.Postcode.substring(0,5)+' '+getAccountResponse.Customer.CitizensPostalAddress.Postcode.substring(5,i);
                            } else {
                                currentAccount.BillingPostalCode = getAccountResponse.Customer.CitizensPostalAddress.Postcode;
                            }
                            for(WS_ESB_BusinessObjects.AddressText cust: getAccountResponse.Customer.CitizensPostalAddress.AddressText) {
                                    String Str = cust.AddressText.replaceAll(' ','');        //get rid of spaces in a address string
                                    if(!str.isAlpha()){                                      //If not str is alpha then the condition is true
                                        if(cust.AddressText != null)
                                            if(strBilling == null) {
                                                strBilling = cust.AddressText;
                                            } else {
                                                strBilling += ', '+cust.AddressText;
                                            }
                                    }
                            }
                            currentAccount.BillingStreet = strBilling;
                        }
                    }
                    if(getAccountResponse.ServiceAddress.Locality != null || getAccountResponse.ServiceAddress.StreetName != null){
                        system.debug('Service Address: '+getAccountResponse.ServiceAddress);
                        currentAccount.ShippingStreet = getAccountResponse.ServiceAddress.StreetNrFirst+' '+getAccountResponse.ServiceAddress.StreetDirection+' '+getAccountResponse.ServiceAddress.StreetName+' '+getAccountResponse.ServiceAddress.StreetNameSuffix; 
                        currentAccount.ShippingCity = getAccountResponse.ServiceAddress.Locality;
                        currentAccount.ShippingStateCode = getAccountResponse.ServiceAddress.StateOrProvince;
                        if(getAccountResponse.ServiceAddress.Postcode.length()>5) {
                            Integer i = getAccountResponse.ServiceAddress.Postcode.length();
                            currentAccount.ShippingPostalCode = getAccountResponse.ServiceAddress.Postcode.subString(0,5)+' '+getAccountResponse.ServiceAddress.Postcode.substring(5,i);
                        } else {
                            currentAccount.ShippingPostalCode = getAccountResponse.ServiceAddress.Postcode;
                        }
                    } 
                    if(currentAccount.ShippingStreet == null) {
                        currentAccount.ShippingStreet ='N/A';
                    }
                    if(getAccountResponse.ConnectDate != null) {
                        currentAccount.DPI_ConnectDate__c = getAccountResponse.ConnectDate;
                    }   
                    if(getAccountResponse.FictitiousFlag != null){
                        currentAccount.DPI_FicticiousNumber__c = getAccountResponse.FictitiousFlag;
                    }
                    
                }
            }
                    
          } catch (exception e) {
                   System.debug('getStackTraceString===='+e.getStackTraceString());
                   System.debug('getMessage===='+e.getMessage());
         }
        }   
    }
        
    public void getMemoCallout(String PhoneNumber, String LibraryId) {
        System.debug('MemoCallout');
        lstMemo = new List<Memo__c>();
        WS_ESB_ManageAccount.Callout memoCallOut = new WS_ESB_ManageAccount.Callout();
        WS_ESB_ManageAccount.ManageAccountGetMemoResponse memoResponse;
        
       
        System.debug(currentAccount);
        if(!Test.isRunningTest()){
           try{
            System.debug('MemoCallout2');            
            memoResponse = memoCallOut.GetMemo(PhoneNumber, LibraryId);//currentAccount.TNSequenceId__c.substring(0,10),currentAccount.Library_Id__c); 
            }Catch(Exception e){}
            System.debug('MemoCallout3');
        }
        else{
            memoResponse = webserviceUtil.doinvokeMemo();
        }
        
         try {
           
            if(memoResponse != null && memoResponse.AccountMemo != null) {
                for(WS_ESB_BusinessObjects.AccountMemo accMemo: memoResponse.AccountMemo) {
                    Memo__c memo = new Memo__c();
                    Date dateCreated;
                    memo.Account__c = currentAccount.id;
                    if(accMemo.CreateDateTime != null) {
                        memo.Created_Date_Time__c = accMemo.CreateDateTime;
                        dateCreated = accMemo.CreateDateTime.date();
                    } else {
                        dateCreated = System.today();
                    }
                    memo.User_ID__c = accMemo.UserID;
                    memo.Type__c = accMemo.MemoTemplateName;
                    for(WS_ESB_BusinessObjects.MemoSection memoSection: accMemo.MemoSection) {
                            memo.MemoText__c = memoSection.memoText; 
                       }
                    memo.Memo_Key__c = accMemo.HashKey; 
                    memo.Sequence_Number__c = accMemo.SequenceNumber;
                    if((dateCreated.daysBetween(System.today())) < 730 ) {
                        lstMemo.add(memo);
                    }
                }
            }
        } catch (exception e) {
                   System.debug('getStackTraceString===='+e.getStackTraceString());
                   System.debug('getMessage===='+e.getMessage());                   
       }
    }
    
    
    // voicemail set up
    //---------------------------------------------------------------------------------------------------------------------------------------
        
         public void resetVoiceMailPasscode(){   
             displayPopup = true;
             message = VMUtility.resetVoiceMailPasscode(currentAccount.TNSequenceID__c.mid(0, 10));                            
        }
        
        public boolean getVmCode(){            
            System.debug('Sunil 1111-----------------------'+showVmButton);
            if(VMUtility.isVMDisabled() == true)
                return false;
            else
                return showVmButton; 
        }
        public void closePopup() {        
            displayPopup = false;    
        } 
             
    //---------------------------------------------------------------------------------------------------------------------------------------
    
    
}