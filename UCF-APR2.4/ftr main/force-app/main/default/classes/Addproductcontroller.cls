public class Addproductcontroller {      
                                                                                                                                       
    public String strSearchProduct {get;set;}
    public String strOpportunityID {get;set;}   
    public boolean bolShowRecords  {get;set;}    
    public boolean fromSfaQuote {get;set;}
    public boolean boldisplay;
    public boolean bolVal=false;                                
    public boolean displayPopup {get; set;} 
    public SterlingQuote__c objSteQuote    {get;set;}   
    public Boolean lightningRecordtype {get; set;}   
    //public static final String PRODUCT_RT_SFA_DEVNAME = 'SFA';

    //public List<clsSelectedProducts> lstClsSelectedProducts {get;set;}
    public List<clsSelectedProducts> lstClsSelectedProductsToDB {get;set;} 
    // MGG319 1/2/2019 Set VAriable for Etherrnet test   
     public String ICBProducts {get;set;}
     public Boolean NoICB {get;set;}
                                    
    public void closePopup() {             
        displayPopup = false;    
    }   
                                                                                                                                                  
    public Addproductcontroller(ApexPages.StandardController controller) {       
        strOpportunityID = ApexPages.currentPage().getParameters().get('oppId');
        //lstAllProducts = getAllOrSelectedProducts();                                                        
        objSteQuote = new SterlingQuote__c();
        objSteQuote.ExpirationDate__c = Date.today().addMonths(1);
        if(ApexPages.currentPage().getParameters().get('strId') != null && ApexPages.currentPage().getParameters().get('strId').length() > 0) {
            fromSfaQuote = true;
        } else {
            fromSfaQuote = false;
        }   
        Opportunity objOpp;
        if (strOpportunityId != null) {
			objOpp = [ 
				SELECT
					RecordType.Name FROM Opportunity
                    WHERE id = :strOpportunityId limit 1
            ];
        }
        lightningRecordtype = false;    
        if (!Test.isrunningtest()){
            if (objopp.RecordType.Name == 'Opportunity Lightning'){
                lightningRecordtype = true;
            }
        }                 
        initProductSection();
    } 

  //pagination start 
  public list<clsSelectedProducts> lstAllProducts {get;set;}
  public list<clsSelectedProducts> lstProducts {get;set;}
  public Integer prdNoOfRecords{get; set;}
  public Integer prdPageSize{get;set;}
  public Integer prdPageNumber{get;set;}
  public Integer prdTotalPages {get;set;}
  
  public void initProductSection(){
   prdPageSize = 50;
   lstAllProducts = getAllOrSelectedProducts();
   prdNoOfRecords = lstAllProducts.size();
   lstProducts = new List<clsSelectedProducts>();
   prdPageNumber = 1;
   integer tmpCount = prdNoOfRecords / prdPageSize;
   prdTotalPages = Math.mod(prdNoOfRecords,prdPageSize) > 0 ? tmpCount + 1 : tmpCount;
  }
  
  public  List<clsSelectedProducts> getProducts() {
  
   system.debug('********** list products   : '+lstproducts);
   lstProducts.clear();
   
   Integer start = (prdPageNumber-1)*prdPageSize;
   Integer stop = (prdPageNumber*prdPageSize);
   
   Integer nEnd = lstAllProducts.size();
   
   if(stop > prdNoOfRecords){ stop = prdNoOfRecords;
   }
   
   system.debug('************ start:'+ start);
   system.debug('************ stop:'+ stop);
   system.debug('************ prdNoOfRecords:'+ prdNoOfRecords);
   
   while(start < stop && start < nEnd){
    lstProducts.add(lstAllProducts[start]);
    start ++;
   }
 
   return lstProducts;
  }
  
                                
  public void prdFirst(){
   prdPageNumber = 1;
  }
 
  public void prdLast(){
   prdPageNumber = prdTotalPages;
  }
 
  public void prdPrevious(){
   prdPageNumber --;
  }
 
  public void prdNext(){
   prdPageNumber ++;
  }
 
  public Boolean prdHasNext{
   get {    return prdPageNumber < prdTotalPages;
   }
  }                    
  public Boolean prdHasPrevious{
   get {    return prdPageNumber > 1;
   }
  }
  //Pagination End
    
   
    public void fetchOnlySearchProducts(){
        if(strSearchProduct==null||strSearchProduct==''){            
            initProductSection();
            //lstAllProducts = getAllOrSelectedProducts();        
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'No Search Criteria Entered')); 
        }
        else{
               initProductSection();
            //lstAllProducts = getAllOrSelectedProducts();        
        }   
    }
    
    
    public void getOnlySelectedProducts(){       
        lstClsSelectedProductsToDB = new List<clsSelectedProducts>();      
        for(clsSelectedProducts objSelProTemp: lstAllProducts){           
            if(objSelProTemp.bolIsSelected==true){               
                lstClsSelectedProductsToDB.add(objSelProTemp);
            }
        }
        bolShowRecords=true;   
    }
         
    public pageReference cancelProducts(){          
        /*  PageReference objPG=new PageReference('/apex/opportunity?id='+strOpportunityID+'&sfdc.override=1');
          return objPG;    */
          system.debug('==>strOpportunityID'+strOpportunityID);
          system.debug('==>lightningRecordtype'+lightningRecordtype);
        
        User this_user = [SELECT CSR_ID__c, DPIID__c, userroleid, profile.name FROM User WHERE Id = :userinfo.getuserid()];
        
        PageReference retURL;
        if (lightningRecordtype == true){
            retURL = new PageReference('/lightning/r/Opportunity/' + strOpportunityID + '/view');
        }else if(this_user.profile.name == 'Frontier Partner Portal User') {
            String oppName = [SELECT Name 
                              FROM Opportunity 
                              WHERE Id =: strOpportunityID LIMIT 1].Name;
            String ntwrkId = Network.getNetworkId();
			ConnectApi.Community comm = ConnectApi.Communities.getCommunity(ntwrkId);
            retURL = new PageReference(comm.siteUrl + '/s/opportunity/' + strOpportunityID + '/' + oppName);
        }else {
            retURL = new PageReference('/apex/opportunity?id='+strOpportunityID+'&sfdc.override=1');
        }
        system.debug('==>returl'+retURL);
        retURL.setRedirect(true);
        return retURL;
          
    }  
   
    public PageReference saveProducts(){       
        bolVal=false; 
        String strAddtype = ApexPages.currentPage().getParameters().get('addressType');
        Opportunity opIDTemp = [select id, name, Accountid from Opportunity where id=:ApexPages.currentPage().getParameters().get('oppid')];
        
        //Get the address details
        Account accRec = [SELECT BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,Legal_Street__c,Legal_City__c,Legal_State__c,Legal_Zip__c,Legal_Country1__c,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode FROM ACCOUNT WHERE id =: opIDTemp.accountId];
        
        for(clsSelectedProducts objProd2: lstClsSelectedProductsToDB){
      //      if (objProd2.NoIcb != true) {
      //          objProd2.DiscountType = 'BDT';
      //      }        
            system.debug('OBJPROD2 = ' + objProd2);
            system.debug('Discount Type  = ' + objProd2.DiscountType);
            system.debug('Family  = ' + objProd2.strProductCategory);
            // MGG319 1/27/2019 Populate ICBProducts for testing to set Discount type if null coming in.
            ICBProducts = objProd2.strProductCategory;
            NoICB = objProd2.NoICB;
            // MGG319 4/3/2019 BDT not populating on SFA quote for Ethernet Products.  Populate above for value from product catalog
            system.debug(' 150 Obj2 NoICB = ' + objProd2.NoICB);
            system.debug(' 151 NoICB = ' + NoICB);

            // MMG 07/09/2015 Correct issue with CPE products overriding Net new MRR to Standard Unit Price.  
            If (objprod2.strProductCategory == 'CPE') objProd2.strUnitPrice1 = '0.0';
            // MMG 07/09/2015 End
            if(objProd2.strQuantity==null || objProd2.strQuantity==''){
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please Enter Quanitity');
                apexpages.addmessage(msg);
                bolVal=true;            
            }
            if(objProd2.strTerm==null || objProd2.strTerm==''){
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please Enter Term');
                apexpages.addmessage(msg);
                bolVal=true;             
            }
            if(objProd2.strRenewalMRC==null || objProd2.strRenewalMRC==''){
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please Enter Net New MRR');
                apexpages.addmessage(msg);
                bolVal=true;             
            }
            
            if(objProd2.strUnitPrice==null || objProd2.strUnitPrice==''){
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please Enter Renewal MRR');
                apexpages.addmessage(msg);
                bolVal=true;            
            }
            if(objProd2.strNRC==null || objProd2.strNRC==''){
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please Enter NRC');
                apexpages.addmessage(msg);
                bolVal=true;            
            }
            
            if(objProd2.strCPENRC==null || objProd2.strCPENRC==''){
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please Enter CPE NRC');
                apexpages.addmessage(msg);
                bolVal=true;            
            }            
            if(objProd2.strCPEGross==null || objProd2.strCPEGross==''){
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please Enter CPE Gross Margin%');
                apexpages.addmessage(msg);
                bolVal=true;            
            }    
        } 
        if(bolVal==true){              
            return null;
        }
        
        if(fromSfaQuote) {            
            displayPopup = false;
            system.debug( '+++++++ Address Type from Popup = ' + strAddtype);
            List<SterlingQuoteItem__c> lstSteQuoteLineItem = sterlingQuoteItemList();            
            /* List<SterlingQuoteItem__c> lstSteQuoteLineItem = new List<SterlingQuoteItem__c>();
for(clsSelectedProducts objProd2: lstClsSelectedProductsToDB){
SterlingQuoteItem__c objLineItem    = new SterlingQuoteItem__c();
objLineItem.Products__c             = objProd2.ProductID;
objLineItem.name                    = objProd2.strProductName;
objLineItem.SterlingQuote__c        = ApexPages.currentPage().getParameters().get('strId');
if(objProd2.objSQI.DiscountType__c != null){
objLineItem.DiscountType__c     = objProd2.objSQI.DiscountType__c;                    
}
objlineitem.Quantity__c             = Decimal.valueOf(objProd2.strQuantity);            
objLineItem.TotalPrice__c           = Decimal.valueOf(objProd2.strQuantity)*Decimal.valueOf(objProd2.strRenewalMRC);
objlineitem.StandardNRC__c          = Decimal.valueOf(objProd2.strNRC);
objlineitem.TermLength__c           = Decimal.valueOf(objProd2.strTerm);
if(false) {
objlineitem.CPE_NRC_Price__c    = 0.0;
objlineitem.CPE_Gross_Margin__c = 0.0;
boldisplay                      =false;
} else {
objlineitem.CPE_NRC_Price__c    = Decimal.valueOf(objProd2.strCPENRC);
objlineitem.CPE_Gross_Margin__c = Decimal.valueOf(objProd2.strCPEGross);
}            
objlineitem.AdjustedMRC__c        = Decimal.valueOf(objProd2.strRenewalMRC);                   
objlineitem.StandardMRC__c        = Decimal.valueOf(objProd2.strUnitPrice1); 

if(strAddtype=='Legal'){
objlineitem.PA_AddressLine1__c  = accRec.Legal_Street__c;
objlineitem.Locality__c         = accRec.Legal_City__c;
//   objlineitem.StateProvince__c    = strStateCode(accRec.ShippingState);
objlineitem.StateProvince__c    = accRec.ShippingState;
system.debug('******** state ' +objlineitem.StateProvince__c);
objlineitem.Zipcode__c          = accRec.Legal_Zip__c;
}
if(strAddtype=='Billing'){
objlineitem.SA_StreetName__c    =  accRec.BillingStreet;
objlineitem.Locality__c         =  accRec.BillingCity;
//    objlineitem.StateProvince__c    =  strStateCode(accRec.BillingState);
objlineitem.StateProvince__c    =  accRec.BillingState;
objlineitem.Zipcode__c          =  accRec.BillingPostalCode;
system.debug('******** Billing state ' +objlineitem.StateProvince__c);

}
if(strAddtype=='Service'){
objlineitem.SA_StreetName__c    =  accRec.ShippingStreet;
objlineitem.Locality__c         =  accRec.ShippingCity;
//    objlineitem.StateProvince__c    =  strStateCode(accRec.ShippingState);
objlineitem.StateProvince__c    = accRec.ShippingState;
objlineitem.Zipcode__c          =  accRec.ShippingPostalCode;
system.debug('******** Service state ' +objlineitem.StateProvince__c);

}
lstSteQuoteLineItem.add(objLineItem);
} */
            if(lstSteQuoteLineItem != null && lstSteQuoteLineItem.size() > 0){
                system.debug('******** Insert Line Item ' +lststequotelineitem);
                insert lstSteQuoteLineItem;
            }
            return new PageReference('/apex/quote?id='+ApexPages.currentPage().getParameters().get('strId')+'&sfdc.override=1');
        } else {
            displayPopup = true;
            return null;
        }   
    }
    

    public PageReference saveQuoteAndItem(){      
            Opportunity opIDTemp = [select id, name, Accountid from Opportunity where id=:ApexPages.currentPage().getParameters().get('oppid')];
            Id OppId = opIDTemp.Id;
            if(lstClsSelectedProductsToDB != null && lstClsSelectedProductsToDB.size()>0){                             
                objSteQuote.OpportunityId__c = strOpportunityID;   
                objSteQuote.Account_Name__c = opIDTemp.Accountid;           
                RecordType lstRT       = [select id, name FROM RecordType WHERE SOBJECTTYPE = 'SterlingQuote__c' AND DeveloperName = 'SFA'];
                objSteQuote.RecordTypeID=lstRT.id;
            if(objSteQuote != null){            
                insert objSteQuote;  
            }
            
            String strAddtype = ApexPages.currentPage().getParameters().get('addressType');
            //Opportunity opIDTemp = [select id, name, Accountid from Opportunity where id=:ApexPages.currentPage().getParameters().get('oppid')];
           
           //Get the address details
           Account accRec = [SELECT BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,Legal_Street__c,Legal_City__c,Legal_State__c,Legal_Zip__c,Legal_Country1__c,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode FROM ACCOUNT WHERE id =: opIDTemp.accountId];
 List<SterlingQuoteItem__c> lstSteQuoteLineItem = sterlingQuoteItemList();  
          /*  List<SterlingQuoteItem__c> lstSteQuoteLineItem = new List<SterlingQuoteItem__c>();
            for(clsSelectedProducts objProd2: lstClsSelectedProductsToDB){
                SterlingQuoteItem__c objLineItem    = new SterlingQuoteItem__c();
                objLineItem.Products__c             = objProd2.ProductID;
                objLineItem.name                    = objProd2.strProductName;
                objLineItem.SterlingQuote__c        = objSteQuote.id;
                objLineItem.DiscountType__c         = objProd2.objSQI.DiscountType__c;    
                  if(objProd2.strQuantity==null || objProd2.strQuantity==''){
                    objlineitem.Quantity__c= Decimal.valueOf(0);
                }else{
                    objlineitem.Quantity__c= Decimal.valueOf(objProd2.strQuantity);}
               // objlineitem.Quantity__c             = Decimal.valueOf(objProd2.strQuantity);
                 //   if(objProd2.strUnitPrice==null || objProd2.strUnitPrice==''){
                    if(objProd2.strRenewalMRC==null || objProd2.strRenewalMRC==''){
                    objProd2.strRenewalMRC='0.0';
                }else{
                    objlineitem.AdjustedMRC__c=Decimal.valueOf(objProd2.strRenewalMRC);}  
             //   objlineitem.AdjustedMRC__c          = Decimal.valueOf(objProd2.strUnitPrice);  
              //  if(objProd2.strRenewalMRC==null || objProd2.strRenewalMRC==''){
               if(objProd2.strUnitPrice1==null || objProd2.strUnitPrice1==''){ 
                    objProd2.strUnitPrice1='0.0';
                }else{
                //   objlineitem.StandardMRC__c=Decimal.valueOf(objProd2.strRenewalMRC); }   
                    objlineitem.StandardMRC__c=Decimal.valueOf(objProd2.strUnitPrice1); }   
                             
             //   objlineitem.StandardMRC__c          = Decimal.valueOf(objProd2.strRenewalMRC); 
                if(objProd2.strNRC==null || objProd2.strNRC==''){
                    objProd2.strNRC='0.00';
                }else{  
                  objlineitem.StandardNRC__c= Decimal.valueOf(objProd2.strNRC);}
                if(objProd2.strTerm==null || objProd2.strTerm==''){objProd2.strTerm='0.00';
                                                                  }else{ 
                    objlineitem.TermLength__c= Decimal.valueOf(objProd2.strTerm);}
             //   objlineitem.StandardNRC__c          = Decimal.valueOf(objProd2.strNRC);
             //   objlineitem.TermLength__c           = Decimal.valueOf(objProd2.strTerm);
               
                
                
                if(false) {
                    objlineitem.CPE_NRC_Price__c    = 0.0;
                    objlineitem.CPE_Gross_Margin__c = 0.0;
             //   } else {
             //       objlineitem.CPE_NRC_Price__c    = Decimal.valueOf(objProd2.strCPENRC);
             //       objlineitem.CPE_Gross_Margin__c = Decimal.valueOf(objProd2.strCPEGross);
             //   }      
                  }else if(objProd2.strCPENRC==null || objProd2.strCPENRC=='' || objProd2.strCPEGross==null || objProd2.strCPEGross ==''){
                    objProd2.strCPEGross='0.00';
                    objProd2.strCPENRC='0.00';
                }else{
                    objlineitem.CPE_NRC_Price__c= Decimal.valueOf(objProd2.strCPENRC);
                    objlineitem.CPE_Gross_Margin__c= Decimal.valueOf(objProd2.strCPEGross);
                } 
                
                
             //   objlineitem.TotalPrice__c           = Decimal.valueOf(objProd2.strQuantity)*Decimal.valueOf(objProd2.strRenewalMRC);
                
                 if((objProd2.strQuantity==null || objProd2.strQuantity=='') || (objProd2.strRenewalMRC==null || objProd2.strRenewalMRC=='') ){
                    objProd2.strRenewalMRC='0.00';
                    objProd2.strQuantity ='0.00';
                }else{
                    objlineitem.TotalPrice__c=Decimal.valueOf(objProd2.strQuantity)*Decimal.valueOf(objProd2.strRenewalMRC);}
                
                
                 if(strAddtype=='Legal'){
                      objlineitem.PA_AddressLine1__c  = accRec.Legal_Street__c;
                      objlineitem.Locality__c         = accRec.Legal_City__c;
                    //  objlineitem.StateProvince__c    = strStateCode(accRec.ShippingState);
                      objlineitem.StateProvince__c    = accRec.ShippingState;
                      system.debug('******** state ' +objlineitem.StateProvince__c);
                      objlineitem.Zipcode__c          = accRec.Legal_Zip__c;
               }
                  if(strAddtype=='Billing'){
                      objlineitem.SA_StreetName__c    =  accRec.BillingStreet;
                      objlineitem.Locality__c         =  accRec.BillingCity;
                  //    objlineitem.StateProvince__c    =  strStateCode(accRec.BillingState);
                      objlineitem.StateProvince__c    =  accRec.BillingState;
                      objlineitem.Zipcode__c          =  accRec.BillingPostalCode;

                  }
                  if(strAddtype=='Service'){
                      objlineitem.SA_StreetName__c    =  accRec.ShippingStreet;
                      objlineitem.Locality__c         =  accRec.ShippingCity;
                     // objlineitem.StateProvince__c    =  strStateCode(accRec.ShippingState);
                      objlineitem.StateProvince__c    = accRec.ShippingState;
                      objlineitem.Zipcode__c          =  accRec.ShippingPostalCode;
                      
                                      }
                
                lstSteQuoteLineItem.add(objLineItem);
            }*/
            if(lstSteQuoteLineItem != null && lstSteQuoteLineItem.size() > 0){
            system.debug('******* insert item' +lstSteQuoteLineItem);
               insert lstSteQuoteLineItem;                
            }                  
        }            
        //PageReference objPG=new PageReference('/apex/quote?id=' + objSteQuote.id + '&sfdc.override=1');
       /* PageReference objPG=new PageReference('/apex/opportunity?id=' + ApexPages.currentPage().getParameters().get('oppid'));
        objPG.setRedirect(true);  
        return objPG;*/
        PageReference retURL; 
        system.debug('==>opIDTemp.Id'+opIDTemp.Id);
        if (lightningRecordtype == true){
            retURL= new PageReference('/lightning/r/Opportunity/' + opIDTemp.Id + '/view');
        }else {
            retURL= new PageReference('/apex/opportunity?id=' + ApexPages.currentPage().getParameters().get('OppId'));
        }
        system.debug('==>returl'+retURL);
        retURL.setRedirect(true);
        return retURL; 
    }
    
    public String strStateCode(String strState){
               if(strState=='Alaska')         return 'AK';           
               if(strState=='Arkansas')       return 'AR';
               if(strState=='Colorado')       return 'CO';
               if(strState=='Connecticut')    return 'CT';
               if(strState=='Delaware')       return 'DE';
               if(strState=='Hawaii')         return 'HI';
               if(strState=='Idaho')          return 'ID';
               if(strState=='Kansas')         return 'KS';
               if(strState=='Kentucky')       return 'KY';
               if(strState=='Louisiana')      return 'LA';
               if(strState=='Maine')          return 'ME';
               if(strState=='Maryland')       return 'MD';
               if(strState=='Massachusetts')  return 'MA';
               if(strState=='Missouri')       return 'MO';
               if(strState=='New Hampshire')  return 'NH';
               if(strState=='New Jersey')     return 'NJ';
               if(strState=='North Dakota')   return 'ND';   
               if(strState=='Oklahoma')       return 'OK'; 
               if(strState=='Rhode Island')   return 'RI'; 
               if(strState=='South Dakota')   return 'SD';
               if(strState=='Texas')          return 'TX';
               if(strState=='Vermont')        return 'VT';  
               if(strState=='Virginia')       return 'VA'; 
               if(strState=='Wyoming')        return 'WY'; 
               if(strState=='Alabama')        return 'AL';
               if(strState=='California')     return 'CA';
               if(strState=='Arizona')        return 'AZ';
               if(strState=='Florida')        return 'FL';
               if(strState=='Georgia')        return 'GA';
               if(strState=='Illinois')       return 'IL';
               if(strState=='Indiana')        return 'IN';
               if(strState=='Iowa')           return 'IA';
               if(strState=='Michigan')       return 'MI';
               if(strState=='Minnesota')      return 'MN';
               if(strState=='Mississippi')    return 'MS';
               if(strState=='Montana')        return 'MT'; 
               if(strState=='Nebraska')       return 'NE'; 
               if(strState=='Nevada')         return 'NV'; 
               if(strState=='New Mexico')     return 'NM';    
               if(strState=='New York')       return 'NY';  
               if(strState=='North Carolina') return 'NC';     
               if(strState=='Ohio')           return 'OH';
               if(strState=='Oregon')         return 'OR'; 
               if(strState=='Pennsylvania')   return 'PA'; 
               if(strState=='South Carolina') return 'SC';              
               if(strState=='Tennessee')      return 'TN';
               if(strState=='Utah')           return 'UT';   
               if(strState=='Washington')     return 'WA';  
               if(strState=='West Virginia')  return 'WV';  
               if(strState=='Wisconsin')      return 'WI'; 
              return null;
             }

    public List<clsSelectedProducts> getAllOrSelectedProducts(){        
        List<Product2> lstObjProduct2 = new List<Product2>();
        List<clsSelectedProducts> lstObjClsSelectedProducts = new List<clsSelectedProducts>(); 
        String s = '%' + strSearchProduct + '%'; 
               
        boolean isListEmpty = true;
        List<Opportunity> opIDTemp = new List<Opportunity>();
        
        opIDTemp = [select id, name, Pricebook2.ID from Opportunity where id=:strOpportunityID];
        system.debug('OpIDTEMP: '+OpIDTemp);
        String prBookID = null;
        if (opIDTemp.size()>0){
          if(opIDTemp[0].Pricebook2.ID != null){  
           prBookID = opIDTemp[0].Pricebook2.ID;
          }else{
           List<Pricebook2> pb2 = [select id, isstandard from pricebook2 where IsStandard = TRUE limit 49500];
            if (pb2.size() >0) {
              prBookID = pb2[0].id;
            }
          }
        }   
        List<PricebookEntry> lstPBE  = new List<PricebookEntry>();
        try{
            system.debug('PRICEBOOK ID: '+prBookID);
             lstPBE  = [SELECT ID,Name,Pricebook2Id,Product2Id,ProductCode,UnitPrice,UseStandardPrice FROM PricebookEntry WHERE Pricebook2Id = :prBookID AND isactive = true limit 49500];
             system.debug('PRICE BOOK ENTRY SIZE: '+lstPBE.size());
        }catch(Exception e){
          // Only possiblity is to have NULL POINTER EXCEPTION.. So we extract based out of standard price book
          ////List<Pricebook2> pb2 = [select id, isstandard from pricebook2 where IsStandard = TRUE];
          ////if (pb2.size() >0) {
          ////    prBookID = pb2[0].id;
          ////}
          lstPBE  = [SELECT ID,Name,Pricebook2Id,Product2Id,ProductCode,UnitPrice,UseStandardPrice FROM PricebookEntry WHERE ID = :prBookID AND isactive = true];
          system.debug('pricebookid: '+prBookID);
          system.debug('pricebookentrylistsize: '+lstPBE.size());
        }
             
        Set<id> pbeID = new Set<Id>();
        if (lstPBE !=null) {
            for(PricebookEntry objPBE:lstPBE){
                    pbeID.add(objPBE.Product2Id);
            }
        }
        
        if (pbeID.size()>0)
            isListEmpty = false;
        
        if(strSearchProduct!=null && strSearchProduct!=''){
            if (!isListEmpty)
            // MGG319 Added NoICb__c to selection to bypass default ICB discount type when left blank
                lstObjProduct2 = [SELECT CreatedById,CreatedDate,RecordType.Name,Description,Family,Grandfathered_Product__c,Id,IsActive,IsDeleted,Item_Code__c,Item_Rate__c,Item_Type__c,LastModifiedById,LastModifiedDate,Name,ProductCode,SiebelRowID__c,SKU__c,SystemModstamp,NoICB__c FROM Product2  WHERE Name LIKE :s and SKU__c='' and IsActive = TRUE and RecordType.Name = 'SFA' and ID in :pbeID Order By Name ASC limit 49500];
        }else{
            if (!isListEmpty)
                lstObjProduct2 = [SELECT CreatedById,CreatedDate,RecordType.Name,Description,Family,Grandfathered_Product__c,Id,IsActive,IsDeleted,Item_Code__c,Item_Rate__c,Item_Type__c,LastModifiedById,LastModifiedDate,Name,ProductCode,SiebelRowID__c,SKU__c,SystemModstamp,NoICB__c FROM Product2 WHERE IsActive= True and SKU__c='' and IsActive = TRUE and RecordType.Name = 'SFA' and ID in :pbeID Order By Name ASC limit 49500];
        }        
              
        if(lstObjProduct2 != null && lstObjProduct2.size()>0){           
            Set<Id> setProductId = new Set<Id>();
            for(Product2 objP:lstObjProduct2){
                setProductId.add(objp.id);
            }            
            Map<String,PricebookEntry> mapProPRice = new Map<String, PricebookEntry>();            
            List<PricebookEntry> lstPB  = [SELECT Name,Pricebook2Id,Product2Id,ProductCode,UnitPrice,UseStandardPrice FROM PricebookEntry where Product2Id in :setProductId AND Pricebook2Id = :prBookID AND isactive = true limit 49500 ];            
            if(lstPB.isEmpty()) return null;
            for(PricebookEntry objPB:lstPB){
                mapProPRice.put(objPB.Name,objPB);           
            }            
            for(Product2 objProduct2Temp: lstObjProduct2){
                clsSelectedProducts objSelProd     = new clsSelectedProducts();                 
                objSelProd.ProductID               = objProduct2Temp.id;
                objSelProd.strProductName          = objProduct2Temp.name;
                objSelProd.strGrandfatheredProduct = objProduct2Temp.Grandfathered_Product__c;
                objSelProd.strProductCategory      = objProduct2Temp.Family;
                objSelProd.strProductCode          = objProduct2Temp.ProductCode;
                objSelProd.productFamily           = objProduct2Temp.Family;
                objSelProd.strIsActive             = objProduct2Temp.IsActive;
                objSelPRod.strUnitPrice            ='0.00';          
                objSelProd.strProductDesc          = objProduct2Temp.Description;
                objSelProd.NoIcb                   = objProduct2Temp.NoICB__c;
                objSelProd.RecordTypeName          = objProduct2Temp.RecordType.Name;
                // MGG319 1/02/2019 Set value for ICBProducts Variable to Value from Family
       //       ICBProducts = objProduct2Temp.Family;
              System.debug('Product Name = ' + objProduct2Temp.name);
              System.debug('Product Family = ' + objProduct2Temp.Family);
              
              // MGG319 1/24/2019 Populate Variable
              NOICB = objProduct2Temp.NoIcb__c;
              system.debug(' 522 NoICB = ' + NoICB);

                if(objProduct2Temp.Name=='Aid To Construction' ||objProduct2Temp.Name=='Expedite Fee'||objProduct2Temp.Name=='Cancellation Fee'||objProduct2Temp.Name=='Design/Installation'){
                    objSelPRod.strNRC              = String.valueof(mapProPRice.get(objProduct2Temp.Name).UnitPrice);
                    objSelPRod.strNRC1             = String.valueof(mapProPRice.get(objProduct2Temp.Name).UnitPrice);
                }else{                
                      if(mapProPRice.get(objProduct2Temp.Name)!=null){
                            objSelPRod.strRenewalMRC   = String.valueof(mapProPRice.get(objProduct2Temp.Name).UnitPrice);    
                            objSelPRod.strUnitPrice1   = String.valueof(mapProPRice.get(objProduct2Temp.Name).UnitPrice);   
                       }  
                }                       
                objSelProd.bolIsSelected=false;
                if(objProduct2Temp.Family != 'CPE') {
                    objSelProd.strCPENRC = '0.0';
                    objSelProd.strCPEGross = '0.0';
                    objSelProd.enabled = true;
                } else {
                    objSelProd.strCPENRC = objSelPRod.strRenewalMRC;
                    objSelPRod.strRenewalMRC = '0.0';
                    objSelProd.enabled = false;
                }
                lstObjClsSelectedProducts.add(objSelProd); 
            }
        }
        return lstObjClsSelectedProducts;
    }    
   
    public class clsSelectedProducts{
        public String strProductName        {get;set;}
        public id ProductID                 {get;set;}
        public Boolean strIsActive          {get;set;}
        public String strProductDesc        {get;set;}
        public String strProductCategory    {get;set;}
        public String strGrandfatheredProduct{get;set;}
        public String strProductCode        {get;set;}
        public String strQuantity           {get;set;}
        public String strTerm               {get;set;}
        public String strRenewalMRC         {get;set;}
        public String strMRC                {get;set;}
        public String strCPENRC             {get;set;}
        public String strNRC                {get;set;}
        public String strNRC1               {get;set;}
        public String strCPEGross           {get;set;}
        public String strUnitPrice          {get;set;}
        public String strUnitPrice1          {get;set;}
        public String productFamily         {get;set;}
        public boolean enabled              {get;set;}       
        public string RecordTypeID          {get;set;}
        public string RecordTypeName         {get;set;}
        public SterlingQuoteItem__c objSQI  {get;set;}
        public boolean bolIsSelected        {get;set;}
        public boolean noIcb                            { get; set; }
        public string DiscountType                      { get; set; }
        public clsSelectedProducts(){
            objSQI = new SterlingQuoteItem__c();
        }        
        
    }
 public boolean displayAddressGrid {get;set;}
 // 9/3/2014       
public List<SterlingQuoteItem__c> sterlingQuoteItemList(){
    
            Opportunity opIDTemp = [select id, name, Accountid from Opportunity where id=:ApexPages.currentPage().getParameters().get('oppid')];
        String strAddtype = ApexPages.currentPage().getParameters().get('addressType');
        Account accRec = [SELECT BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,Legal_Street__c,Legal_City__c,Legal_State__c,Legal_Zip__c,Legal_Country1__c,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode FROM ACCOUNT WHERE id =: opIDTemp.accountId];
        List<SterlingQuoteItem__c> lstSteQuoteLineItem = new List<SterlingQuoteItem__c>();
        for(clsSelectedProducts objProd2: lstClsSelectedProductsToDB){
            SterlingQuoteItem__c objLineItem    = new SterlingQuoteItem__c();
            objLineItem.Products__c             = objProd2.ProductID;
            objLineItem.name                    = objProd2.strProductName;
            if(fromSfaQuote){
            objLineItem.SterlingQuote__c        = ApexPages.currentPage().getParameters().get('strId');
            }else{
            objLineItem.SterlingQuote__c        = objSteQuote.Id; }
            if(objProd2.objSQI.DiscountType__c != null){
                objLineItem.DiscountType__c     = objProd2.objSQI.DiscountType__c;                    
            }
             // MGG319 01/02/2019 Add default of ICB to Approval Process for Ethernet products.
             system.debug('Discount Type = ' + objLineItem.DiscountType__c);
              system.debug('ICBProducts = ' + ICBProducts);
              system.debug('NoICB = ' + NoICB);
             if(objLineItem.DiscountType__c == null){
              If(ICBProducts == 'ETHERNET'){
                  If(NoICB == false){
                     objLineItem.DiscountType__c = 'BDT';
                    }
                 }
              }
            objlineitem.Quantity__c             = Decimal.valueOf(objProd2.strQuantity);   
                     
            if (objProd2.strNRC1 == null)
                objlineitem.StandardNRC__c = 0;
            else
                objlineitem.StandardNRC__c          = Decimal.valueOf(objProd2.strNRC1);
            
            objlineitem.TermLength__c           = Decimal.valueOf(objProd2.strTerm);
            
            if(false) {
                objlineitem.CPE_NRC_Price__c    = 0.0;
                objlineitem.CPE_Gross_Margin__c = 0.0;
                boldisplay                      =false;
            } else {
                objlineitem.CPE_NRC_Price__c    = Decimal.valueOf(objProd2.strCPENRC);
                objlineitem.CPE_Gross_Margin__c = Decimal.valueOf(objProd2.strCPEGross);
            }            
               
               objlineitem.NetNewMRR__c    = Decimal.valueOf(objProd2.strRenewalMRC);
               
               objlineitem.AdjustedNRC__c        = Decimal.valueOf(objProd2.strNRC);        
               
               objlineitem.StandardMRC__c        = Decimal.valueOf(objProd2.strUnitPrice1); 
               objlineitem.renewal_mrr_original__c        = Decimal.valueOf(objProd2.strUnitPrice);
               
               objlineitem.AdjustedMRC__c        =  objlineitem.renewal_mrr_original__c + objlineitem.NetNewMRR__c;
               objlineitem.NetNewMRR__c    =   objlineitem.NetNewMRR__c * objlineitem.Quantity__c;
               
               objLineItem.TotalPrice__c         = (((objlineitem.Quantity__c * objlineitem.TermLength__c * (objlineitem.AdjustedMRC__c))) + objlineitem.AdjustedNRC__c + objlineitem.CPE_NRC_Price__c);


            system.debug('+++++ Service type at 529 = ' + straddtype);  
            if(strAddtype=='Legal'){
                 objlineitem.PA_AddressLine1__c  = accRec.Legal_Street__c;
                 objlineitem.Locality__c         = accRec.Legal_City__c;
             //    objlineitem.StateProvince__c    = strStateCode(accRec.ShippingState);
                 objlineitem.StateProvince__c    = accRec.ShippingState;
                 system.debug('******** state ' +objlineitem.StateProvince__c);
                 objlineitem.Zipcode__c          = accRec.Legal_Zip__c;
           }
              if(strAddtype=='Billing'){
                 objlineitem.SA_StreetName__c    =  accRec.BillingStreet;
                 objlineitem.Locality__c         =  accRec.BillingCity;
               //  objlineitem.StateProvince__c    =  strStateCode(accRec.BillingState);
                 objlineitem.StateProvince__c    =  accRec.BillingState;
                 objlineitem.Zipcode__c          =  accRec.BillingPostalCode;

              }
              if(strAddtype=='Service'){
                 objlineitem.SA_StreetName__c    =  accRec.ShippingStreet;
                 objlineitem.Locality__c         =  accRec.ShippingCity;
                // objlineitem.StateProvince__c    =  strStateCode(accRec.ShippingState);
                 objlineitem.StateProvince__c    = accRec.ShippingState;
                 objlineitem.Zipcode__c          =  accRec.ShippingPostalCode;
                  
              }
            lstSteQuoteLineItem.add(objLineItem);
        }
        return lstSteQuoteLineItem;
     }      
  // 9/3/2014     
    
}