global class WS_SFA_ManageAgreement {
    
    //TODO
    // 1. Are NPA__c,NXX__c mapped to the BTN?
    
    global class Response {
        webservice WS_SFA_ManageAgreement.ProductSchedule[] Schedule;
        public Response(){
            Schedule = new List<WS_SFA_ManageAgreement.ProductSchedule>();
        }
    }
    global static String nrcOrMrc;
        
    global class ProductDetail {
        webservice Decimal mRC;
        webservice Decimal nRC; 
        webservice String seCode;
        webservice String sku;
        webservice String quantity;
        webservice Integer primeLineNo;
        webservice Integer subLineNo;
        webservice String orderLineKey;
        webservice String bundleParentLineKey;
        public ProductDetail(SterlingQuoteItem__c SQI, Product2 this_product){
            mRC = (SQI.AdjustedMRC__c == null) ? 0 : SQI.AdjustedMRC__c.setScale(2);
            nRC = SQI.AdjustedNRC__c;
            if(SQI.ItemCode__c != null && SQI.ItemCode__c != '' && SQI.ItemCode__c != '0000'){
                seCode = SQI.ItemCode__c;
            }else{
                seCode = this_product.ProductCode;
            }
            sku = SQI.ST_SKU__c;
            quantity = string.valueof(SQI.Quantity__c);
            orderLineKey = SQI.ST_LineKey__c;
            bundleParentLineKey = SQI.ST_ParentLineKey__c;
            primeLineNo = integer.valueof(SQI.MajorLine__c);
            subLineNo = integer.valueof(SQI.MinorLine__c);
        }
        public ProductDetail(VlocityOrderItem SQI, Product2 this_product){
            mRC = (SQI.AdjustedMRC== null) ? 0 : SQI.AdjustedMRC.setScale(2);
            //mRC = mRC == 0? null : mRC;
            
            nRC = SQI.AdjustedNRC;
            //nRC = nRC == 0?null : nRC;
            
            if(SQI.ItemCode != null && SQI.ItemCode != '' && SQI.ItemCode != '0000'){
                seCode = SQI.ItemCode;
            }else{
                seCode = this_product.ProductCode;
            }
            sku = SQI.ST_SKU;
            quantity = string.valueof(SQI.Quantity);
            orderLineKey = SQI.ST_LineKey;
            bundleParentLineKey = SQI.ST_ParentLineKey;
            primeLineNo = integer.valueof(SQI.MajorLine);
            subLineNo = integer.valueof(SQI.MinorLine);
        }        
        public ProductDetail(OpportunityLineItem OLI, Product2 this_product){
            mRC = (OLI.Total_MRR__c/OLI.Quantity) + OLI.Renewal_MRR__c;
            nRC = OLI.NRC_Price__c;
            seCode = OLI.Prod_Code__c;
            quantity = string.valueof(OLI.Quantity);
        }
    }
    
    global class ProductSchedule {
        webservice Date startDate;
        webservice Date endDate;
        webservice String scheduleId;
        webservice String scheduleName;
        webservice WS_SFA_ManageAgreement.CitizensServiceAddress[] Address;
        public ProductSchedule(boolean isSchedule, Schedule__c Schedule, Contract contract, List<SterlingQuoteItem__c> list_products, Map<Id, Product2> productsMap){
            if (isSchedule)
            {
                startDate = Schedule.Schedule_Start_Date__c;
                endDate = Schedule.Schedule_End_Date__c;
                scheduleId = Schedule.Id;
                scheduleName = Schedule.Name;
            }
            else
            {
                startDate = contract.StartDate;
                endDate = contract.EndDate;
                scheduleId = contract.Id;
                scheduleName = contract.ScheduleID__c;
            }
            Address = new List<WS_SFA_ManageAgreement.CitizensServiceAddress>();
            Set<WS_SFA_ManageAgreement.CitizensServiceAddress> SetAddresses = new Set<WS_SFA_ManageAgreement.CitizensServiceAddress>();
            Map<String,WS_SFA_ManageAgreement.CitizensServiceAddress> MapAddresses = new Map<String,WS_SFA_ManageAgreement.CitizensServiceAddress>();
            for(SterlingQuoteItem__c SQI : list_products){
                MapAddresses.put(json.serializepretty(new CitizensServiceAddress(SQI)),new CitizensServiceAddress(SQI));
            }
            
            for(WS_SFA_ManageAgreement.CitizensServiceAddress CSA : MapAddresses.values()){
                List<ProductDetail> List_CSA_ProductDetail = new List<ProductDetail>();
                for(SterlingQuoteItem__c SQI : list_products){
                    if(json.serializepretty(CSA) == json.serializepretty(new CitizensServiceAddress(SQI))){ 
                        //ProductDetail pd = new ProductDetail(SQI, productsMap.get(SQI.Products__c));
                        List_CSA_ProductDetail.add(new ProductDetail(SQI, productsMap.get(SQI.Products__c)));
                    }                   
                }
                Address.add(new WS_SFA_ManageAgreement.CitizensServiceAddress(CSA,List_CSA_ProductDetail));
            }
        }
        
        public ProductSchedule(boolean isSchedule, Schedule__c Schedule, VlocityContract contract, List<VlocityOrderItem> list_products, Map<Id, Product2> productsMap){
            if (isSchedule)
            {
                startDate = Schedule.Schedule_Start_Date__c;
                endDate = Schedule.Schedule_End_Date__c;
                scheduleId = Schedule.Id;
                scheduleName = Schedule.Name;
            }
            else
            {
				startDate = contract.StartDate==null?null:date.newinstance(contract.StartDate.year(), contract.StartDate.month(), contract.StartDate.day());
				endDate = contract.EndDate==null?null:date.newinstance(contract.EndDate.year(), contract.EndDate.month(), contract.EndDate.day());
                scheduleId = contract.Id;
                scheduleName = contract.Name;
            }
            Address = new List<WS_SFA_ManageAgreement.CitizensServiceAddress>();
            Set<WS_SFA_ManageAgreement.CitizensServiceAddress> SetAddresses = new Set<WS_SFA_ManageAgreement.CitizensServiceAddress>();
            Map<String,WS_SFA_ManageAgreement.CitizensServiceAddress> MapAddresses = new Map<String,WS_SFA_ManageAgreement.CitizensServiceAddress>();
            for(VlocityOrderItem SQI : list_products){
                MapAddresses.put(json.serializepretty(new CitizensServiceAddress(SQI)),new CitizensServiceAddress(SQI));
            }
            
            for(WS_SFA_ManageAgreement.CitizensServiceAddress CSA : MapAddresses.values()){
                List<ProductDetail> List_CSA_ProductDetail = new List<ProductDetail>();
                for(VlocityOrderItem SQI : list_products){
                    if(json.serializepretty(CSA) == json.serializepretty(new CitizensServiceAddress(SQI))){ 
                        ProductDetail pdActual = new ProductDetail(SQI, productsMap.get(SQI.Products));
                        if(pdActual.nRC != null && pdActual.mRC != null){
                            	ProductDetail pdActual1 = new ProductDetail(SQI, productsMap.get(SQI.Products));
                            	pdActual1.nRC = null;
                                pdActual1.seCode = SQI.ItemCode;
                            
                            	ProductDetail pdActual2 = new ProductDetail(SQI, productsMap.get(SQI.Products));
                            	pdActual2.mRC = null;
                                pdActual2.seCode = SQI.ItemCode1;
                            	List_CSA_ProductDetail.add(pdActual1);List_CSA_ProductDetail.add(pdActual2);
                            
                        }else if(pdActual.nRC != null && (pdActual.mRC == null || pdActual.mRC == 0)){
                            ProductDetail pdActual1 = new ProductDetail(SQI, productsMap.get(SQI.Products));
                            pdActual1.mRC = null;
                            pdActual1.seCode = SQI.ItemCode1;
                            List_CSA_ProductDetail.add(pdActual1);
                        }else if(pdActual.mRC != null && (pdActual.nRC == null || pdActual.nRC == 0)){
                            ProductDetail pdActual1 = new ProductDetail(SQI, productsMap.get(SQI.Products));
                            pdActual1.nRC = null;
                            pdActual1.seCode = SQI.ItemCode;
                            List_CSA_ProductDetail.add(pdActual1);
                        }
                    }                   
                }
                Address.add(new WS_SFA_ManageAgreement.CitizensServiceAddress(CSA,List_CSA_ProductDetail));
            }
        }
        
        public ProductSchedule(boolean isSchedule, Schedule__c Schedule, Contract contract, List<OpportunityLineItem> listOppItems, Map<Id, Product2> productsMap){
            if (isSchedule)
            {
                startDate = Schedule.Schedule_Start_Date__c;
                endDate = Schedule.Schedule_End_Date__c;
                scheduleId = Schedule.Id;
                scheduleName = Schedule.Name;
            }
            else
            {
                startDate = contract.StartDate;
                endDate = contract.EndDate;
                scheduleId = contract.Id;
                scheduleName = contract.ScheduleID__c;
            }
            Address = new List<WS_SFA_ManageAgreement.CitizensServiceAddress>();
            List<ProductDetail> List_CSA_ProductDetail = new List<ProductDetail>();
            for(OpportunityLineItem OLI : listOppItems){                     
                List_CSA_ProductDetail.add(new ProductDetail(OLI, productsMap.get(OLI.PriceBookEntry.Product2Id)));
            }
            Address.add(new WS_SFA_ManageAgreement.CitizensServiceAddress(Schedule,List_CSA_ProductDetail));
        }
        
        public ProductSchedule(boolean isSchedule, Schedule__c Schedule, VlocityContract contract, List<OpportunityLineItem> listOppItems, Map<Id, Product2> productsMap){
            if (isSchedule)
            {
                startDate = Schedule.Schedule_Start_Date__c;
                endDate = Schedule.Schedule_End_Date__c;
                scheduleId = Schedule.Id;
                scheduleName = Schedule.Name;
            }
            else
            {
                startDate = date.newinstance(contract.StartDate.year(), contract.StartDate.month(), contract.StartDate.day());
                endDate = date.newinstance(contract.EndDate.year(), contract.EndDate.month(), contract.EndDate.day());
                scheduleId = contract.Id;
                scheduleName = contract.Name;
            }
            Address = new List<WS_SFA_ManageAgreement.CitizensServiceAddress>();
            List<ProductDetail> List_CSA_ProductDetail = new List<ProductDetail>();
            for(OpportunityLineItem OLI : listOppItems){                     
                List_CSA_ProductDetail.add(new ProductDetail(OLI, productsMap.get(OLI.PriceBookEntry.Product2Id)));
            }
            Address.add(new WS_SFA_ManageAgreement.CitizensServiceAddress(Schedule,List_CSA_ProductDetail));
        }        
    }
    
    global class ProductContract {      
        webservice Date startDate;
        webservice Date endDate;
        webservice Integer termLength;
        webservice String contractId;
        webservice String contractName;
        public ProductContract(){}
    }
    
    global class CitizensServiceAddress {
        webservice String AddressId;
        webservice String StreetNrFirst;
        webservice String StreetName;
        webservice String StreetSubDescription;
        webservice String StreetNameSuffix;
        webservice String StreetSuffix;
        webservice String StreetDirection;
        webservice String Subdivision;
        webservice String Locality;
        webservice String StateOrProvince;
        webservice String Postcode;
        webservice String BuildingName;
        webservice String BuildingNumber;
        webservice String BuildingSubNumber;
        webservice WS_SFA_ManageAgreement.AddressUnit[] Unit;
        webservice String WireCenter;
        webservice WS_SFA_ManageAgreement.Exchange Exchange;
        webservice Integer ServiceSequenceNumber;
        webservice Integer ServiceControlNumber;
        webservice WS_SFA_ManageAgreement.ProductDetail[] Product;
        public CitizensServiceAddress(){
        }
        public CitizensServiceAddress(CitizensServiceAddress CSA, List<ProductDetail> list_products){
            AddressId = CSA.AddressId;
            StreetNrFirst = CSA.StreetNrFirst;
            StreetName = CSA.StreetName;
            StreetSubDescription = CSA.StreetSubDescription;
            StreetNameSuffix = CSA.StreetNameSuffix;
            StreetSuffix = CSA.StreetSuffix;
            StreetDirection = CSA.StreetDirection;
            Subdivision = CSA.Subdivision;
            Locality = CSA.Locality;
            StateOrProvince = CSA.StateOrProvince;
            Postcode = CSA.Postcode;
            BuildingName = CSA.BuildingName;
            BuildingNumber = '';
            BuildingSubNumber = '';         
            Unit = new List<WS_SFA_ManageAgreement.AddressUnit>();
            Unit.add(new WS_SFA_ManageAgreement.AddressUnit(CSA.Unit[0].Designator,CSA.Unit[0].Number_x));            
            WireCenter = CSA.WireCenter;
            Exchange = new WS_SFA_ManageAgreement.Exchange(CSA.Exchange.NPA,CSA.Exchange.NXX);
            ServiceSequenceNumber = integer.valueof(CSA.ServiceSequenceNumber);
            ServiceControlNumber = integer.valueof(CSA.ServiceControlNumber);
            Product = new List<WS_SFA_ManageAgreement.ProductDetail>();
            Product.addAll(list_products);
        }
        public CitizensServiceAddress(SterlingQuoteItem__c SQI){
            AddressId = SQI.ST_AddressID__c;
            StreetNrFirst = SQI.SA_StreetNrFirst__c;
            StreetName = SQI.SA_StreetName__c;
            StreetSubDescription = SQI.SA_StreetSubDescription__c;
            StreetNameSuffix = SQI.SA_StreetSuffix__c;
            StreetSuffix = SQI.SA_StreetSuffix__c;
            StreetDirection = SQI.SA_StreetDirection__c;
            Subdivision = SQI.SA_SubDivision__c;
            Locality = SQI.Locality__c;
            StateOrProvince = SQI.StateProvince__c;
            Postcode = SQI.Postcode__c;
            BuildingName = SQI.SA_BuildingName__c;
            BuildingNumber = '';
            BuildingSubNumber = '';         
            Unit = new List<WS_SFA_ManageAgreement.AddressUnit>();
            Unit.add(new WS_SFA_ManageAgreement.AddressUnit(SQI.SA_unitDesignator__c,SQI.SA_UnitNumber__c));            
            WireCenter = SQI.SA_WireCenter__c;
            Exchange = new WS_SFA_ManageAgreement.Exchange(SQI.NPA__c,SQI.NXX__c);
            if(SQI.ServiceSequenceNumber__c != null){ServiceSequenceNumber = integer.valueof(SQI.ServiceSequenceNumber__c);}
            if(SQI.ServiceControlNumber__c != null){ServiceControlNumber = integer.valueof(SQI.ServiceControlNumber__c);}
        }
        public CitizensServiceAddress(VlocityOrderItem SQI){
            AddressId = SQI.ST_AddressID;
            StreetNrFirst = SQI.SA_StreetNrFirst;
            StreetName = SQI.SA_StreetName;
            StreetSubDescription = SQI.SA_StreetSubDescription;
            StreetNameSuffix = SQI.SA_StreetSuffix;
            StreetSuffix = SQI.SA_StreetSuffix;
            StreetDirection = SQI.SA_StreetDirection;
            Subdivision = SQI.SA_SubDivision;
            Locality = SQI.Locality;
            StateOrProvince = SQI.StateProvince;
            Postcode = SQI.Postcode;
            BuildingName = SQI.SA_BuildingName;
            BuildingNumber = '';
            BuildingSubNumber = '';         
            Unit = new List<WS_SFA_ManageAgreement.AddressUnit>();
            Unit.add(new WS_SFA_ManageAgreement.AddressUnit(SQI.SA_unitDesignator,SQI.SA_UnitNumber));            
            WireCenter = SQI.SA_WireCenter;
            Exchange = new WS_SFA_ManageAgreement.Exchange(SQI.NPA,SQI.NXX);
            if(SQI.ServiceSequenceNumber != null){ServiceSequenceNumber = integer.valueof(SQI.ServiceSequenceNumber);}
            if(SQI.ServiceControlNumber != null){ServiceControlNumber = integer.valueof(SQI.ServiceControlNumber);}
        }        
        public CitizensServiceAddress(Schedule__c Schedule, List<ProductDetail> list_products){
            if (Schedule != null) {
                if(Schedule.Street_Address__c != null){
                    String[] StreetArray = Schedule.Street_Address__c.split(' ',2);
                    try{
                        StreetNrFirst = StreetArray[0];
                    }catch(Exception e){}
                    try{
                        StreetName = StreetArray[1];
                    }catch(Exception e){}
                }
                if(Schedule.City__c != null){ Locality = Schedule.City__c; }
                if(Schedule.State__c != null){ StateOrProvince = Schedule.State__c; }
                if(Schedule.Zip_Code__c != null){ Postcode = Schedule.Zip_Code__c; }
            }
            Unit = new List<WS_SFA_ManageAgreement.AddressUnit>();
            Product = new List<WS_SFA_ManageAgreement.ProductDetail>();
            Product.addAll(list_products);
        }        
    }
    
    global class AddressUnit{
        webservice Integer SequenceNumber;
        webservice String Designator;
        webservice String Number_x;
        public AddressUnit(String UnitDesignator, String UnitNumber){
            SequenceNumber = 0;
            Designator = UnitDesignator;
            Number_x = UnitNumber;
        }
    }
    
    global class Exchange{
        webservice String NPA;
        webservice String NXX;
        public Exchange(String strNPA,String strNXX){
            NPA = strNPA;
            NXX = strNXX;
        }
    }
    
    global class VlocityOrderItem {
        public VlocityOrderItem(OrderItem oi) {
            Name = oi.Order.Name; //Name
            Products = oi.vlocity_cmt__Product2Id__c;
            AdjustedMRC = oi.vlocity_cmt__RecurringCharge__c;
            AdjustedNRC = oi.vlocity_cmt__OneTimeCharge__c;
            
            //system.debug('!@#$!#@$%@#$%#@$%@#$%@#$%@#$%');
            //system.debug(oi.vlocity_cmt__LineNumber__c);
            if(oi.vlocity_cmt__LineNumber__c.contains('.'))
            {
                string[] lineNums = oi.vlocity_cmt__LineNumber__c.split('\\.');
	            //system.debug(lineNums);
	            MajorLine = lineNums[0];//oi.vlocity_cmt__LineNumber__c;
    	        MinorLine = lineNums[1];//oi.vlocity_cmt__LineItemNumString__c;
            }
            else
            {
	            MajorLine = oi.vlocity_cmt__LineNumber__c;
    	        MinorLine = '0';
            }
            Quantity = oi.Quantity;
            
            if( oi.Order.Account.BTN_Number__c != null )
            {
                String phoneNumber = oi.Order.Account.BTN_Number__c;
                String phoneDigits = phoneNumber.replaceAll('[^0-9]', '');
                if (phoneDigits.length() < 11 && phoneDigits.length() > 5) {
                    NPA = phoneDigits.substring(0,3);
                    NXX = phoneDigits.substring(3,6);
                } else if (phoneDigits.length() == 11) {
                    NPA = phoneDigits.substring(1,4);
                    NXX = phoneDigits.substring(4,7);
                }
            }
            
            ItemCode = oi.SNE_Code_MRC__c;//ItemCode__c;
            ItemCode1 = oi.SNE_Code_OTC__c;//
            SA_StreetName = oi.vlocity_cmt__ServiceAccountId__r.ShippingStreet;
            Locality = oi.vlocity_cmt__ServiceAccountId__r.ShippingCity;
            StateProvince = oi.vlocity_cmt__ServiceAccountId__r.ShippingState;
            Postcode = oi.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode;
        }
        
        public Decimal AdjustedMRC;
        public Decimal AdjustedNRC;
        public string BuildingNumber;
        public string Locality;
        public string MajorLine;
        public string MinorLine;
        public string Name;
        public string NPA;
        public string NXX;
        public string ItemCode; //
        public string ItemCode1; //
        public string Postcode;
        public Decimal Quantity;
        public string SA_BuildingName;
        public string SA_StreetDirection;
        public string SA_StreetName;
        public string SA_StreetNrFirst;
        public string SA_StreetSubDescription;
        public string SA_StreetSuffix;
        public string SA_SubDivision;
        public string SA_unitDesignator;
        public string SA_UnitNumber;
        public string SA_WireCenter;
        
        public string ServiceControlNumber;
        public string ServiceSequenceNumber;
        public string StateProvince;
        public string ST_AddressID;
        public string ST_LineKey;
        public string ST_ParentLineKey;
        public string ST_SKU;
        public string Products;
    }
    
    global class VlocityContract {
        public VlocityContract()
        {
        }
        
        public Id Id;
        public string Name;
        public DateTime StartDate;
        public DateTime EndDate;
    }
    
    webservice static WS_SFA_ManageAgreement.Response getProductsById(String[] ScheduleName) {
        return getProducts(ScheduleName[0],null);
    }
    webservice static WS_SFA_ManageAgreement.Response getProductsByAddress(String ScheduleName, WS_SFA_ManageAgreement.CitizensServiceAddress CitizensServiceAddress){
        return getProducts(ScheduleName,CitizensServiceAddress);
    }
    
    public static WS_SFA_ManageAgreement.Response getProducts(String schedule_Name,WS_SFA_ManageAgreement.CitizensServiceAddress CitizensServiceAddress) {
         Boolean isByAddress = CitizensServiceAddress!=null?True:False;
         WS_SFA_ManageAgreement.Response ServiceResponse = new Response();
         Boolean hasProducts = false;
         /* for Sterling Quotes || START*/
         boolean isSchedule = false;
         ID oppty;
         //String schedule_Name = scheduleName != null && scheduleName.size() > 0?scheduleName[0]:null;
         List<Contract> CurrentContract = getContract(schedule_Name);
         List<Schedule__c> CurrentSchedule = new List<Schedule__c>();
         //System.debug('CurrentContract:: '+ JSON.Serialize(CurrentContract));
         if(CurrentContract.size() > 0){
             oppty = CurrentContract[0].Opportunity__c;
         }else{
             CurrentSchedule = getSchedule(schedule_Name);
             if(CurrentSchedule.size() > 0){
                 isSchedule = true;
                 oppty = CurrentSchedule[0].New_Opportunity__c;
             }
         }
         Set<Id> productsIdList = new Set<Id>();
         Map<Id, Product2> productsMap = new Map<Id, Product2>();
         system.debug('schedule_Name ::'+schedule_Name);
         system.debug('OppId ::'+oppty);
         if(oppty != null && (CurrentContract.size() > 0 || CurrentSchedule.size() > 0)){ 
             List<SterlingQuoteItem__c> SterlingQuoteItems = getSterlingQuoteItems(oppty); 
             system.debug('test :: '+SterlingQuoteItems.size()); 
                 system.debug('isByAddress :: '+isByAddress);
             if(isByAddress){
                 List<SterlingQuoteItem__c> SterlingQuoteItemsByAddress = new List<SterlingQuoteItem__c>();
                 CitizensServiceAddress CSA = null;
                 if(SterlingQuoteItems != null && SterlingQuoteItems.size() > 0) {
                     for(SterlingQuoteItem__c SQI : SterlingQuoteItems) {
                         CSA = new WS_SFA_ManageAgreement.CitizensServiceAddress(SQI);
                         if(CSA.Locality == CitizensServiceAddress.Locality && 
                            CSA.Postcode.left(5) == CitizensServiceAddress.Postcode && 
                            CSA.StateOrProvince == CitizensServiceAddress.StateOrProvince &&
                            CSA.StreetName == CitizensServiceAddress.StreetName &&
                            CSA.StreetNameSuffix == CitizensServiceAddress.StreetNameSuffix && 
                            CSA.StreetNrFirst == CitizensServiceAddress.StreetNrFirst &&
                            CSA.StreetSubDescription == CitizensServiceAddress.StreetSubDescription) {
                                SterlingQuoteItemsByAddress.add(SQI);
                            }
                     }
                     SterlingQuoteItems = SterlingQuoteItemsByAddress;
                 }
             }
             if((SterlingQuoteItems != null) && (SterlingQuoteItems.size() > 0)){
                 for(SterlingQuoteItem__c SQI : SterlingQuoteItems) productsIdList.add(SQI.Products__c);
                 productsMap = new Map<Id, Product2>([SELECT Id, ProductCode FROM Product2 WHERE Id IN :productsIdList]);
                 ServiceResponse.Schedule.add(new ProductSchedule(isSchedule,CurrentSchedule.size() > 0?CurrentSchedule[0]:new Schedule__c(),CurrentContract.size() > 0?CurrentContract[0]:new Contract(),SterlingQuoteItems, productsMap));
                 hasProducts = True;
             }
         }
         system.debug('productsMap Ster :: '+productsMap.keyset());
        /* for Sterling Quotes || END*/
         
         /* for Velocty Quotes || START*/
        //  List<Quote> currentQuote = getVlocityQuote(schedule_Name);
        //  if(currentQuote.size() == 0){
        //      // for example ScheduleName is S-1112 .
        //      currentQuote = [select id, Schedule_Number__c,Name  from quote where OpportunityId =:oppty AND IsSyncing__c  = true limit 1];//Schedule_Number__c LIKE '%S-555%'
        //  }
         
         VlocityContract currentContractVlo = new VlocityContract();
        //  if(currentQuote.size() > 0){
             List<Order> currentOrder = getVlocityOrder(schedule_Name);
             //system.debug('test :: '+currentOrder.size()+' :: '+currentOrder[0].orderNumber);
             if(currentOrder.size() > 0){
                 oppty = oppty==null?currentOrder[0].OpportunityId:oppty;
                 isSchedule = false;
                 currentSchedule = null;//should always be null for Vlocity orders
                 if(CurrentContract.size() > 0){
                     currentContractVlo.Id = CurrentContract[0].Id;
                     currentContractVlo.Name = CurrentContract[0].ScheduleID__c;
                     currentContractVlo.StartDate = CurrentContract[0].StartDate;//vlocity_cmt__RequestedStartDate__c;
                     currentContractVlo.EndDate = CurrentContract[0].EndDate;//vlocity_cmt__RequestedCompletionDate__c;
                 }
                 
                 List<VlocityOrderItem> vlocityOrderItems = new List<VlocityOrderItem>();
                 
                 List<OrderItem>  OrderItm = getOrderItems(currentOrder);
                 for(OrderItem oi : OrderItm) vlocityOrderItems.add(new VlocityOrderItem(oi));
                 
                 productsIdList = new Set<Id>();
                 if(isByAddress){
                     List<VlocityOrderItem> listVlocityOrderItems = new List<VlocityOrderItem>();
                     CitizensServiceAddress CSA = null;
                     if(vlocityOrderItems.size() > 0) {
                         for(VlocityOrderItem SQI : vlocityOrderItems) {
                             CSA = new WS_SFA_ManageAgreement.CitizensServiceAddress(SQI);
                             if(CSA.Locality == CitizensServiceAddress.Locality && 
                                CSA.Postcode.left(5) == CitizensServiceAddress.Postcode && 
                                CSA.StateOrProvince == CitizensServiceAddress.StateOrProvince &&
                                CSA.StreetName == CitizensServiceAddress.StreetName &&
                                CSA.StreetNameSuffix == CitizensServiceAddress.StreetNameSuffix && 
                                CSA.StreetNrFirst == CitizensServiceAddress.StreetNrFirst &&
                                CSA.StreetSubDescription == CitizensServiceAddress.StreetSubDescription) {
                                    listVlocityOrderItems.add(SQI);
                                }
                         }
                         vlocityOrderItems = listVlocityOrderItems;
                     }
                 }
                 if (vlocityOrderItems.size() > 0){
                     for(VlocityOrderItem voi : vlocityOrderItems) productsIdList.add(voi.Products);
                     productsMap = new Map<Id, Product2>([SELECT Id, ProductCode FROM Product2 WHERE Id IN :productsIdList]);
                     ServiceResponse.Schedule.add(new ProductSchedule(isSchedule,null,currentContractVlo,vlocityOrderItems, productsMap));
                     hasProducts = true;
                 }else if(!hasProducts){
                     hasProducts = false;
                 }
             }
        //  }
         system.debug('productsMap vel:: '+productsMap.keyset());
         /* for Vlocity Quotes || END*/
         if(!hasProducts){
             productsIdList = new Set<Id>();
             List<OpportunityLineItem> oppLineItems = getOppLineItems(oppty);
             for(OpportunityLineItem oli : oppLineItems){ productsIdList.add(oli.PricebookEntry.Product2Id); }
             productsMap = new Map<Id,Product2>([SELECT Id, ProductCode FROM Product2 WHERE Id IN :productsIdList]);
             
             if(CurrentSchedule != null && CurrentSchedule.size() > 0){
                 Contract cont = CurrentContract!=null && CurrentContract.size() > 0 ? CurrentContract[0]: new Contract();
                 ServiceResponse.Schedule.add(new ProductSchedule(isSchedule,CurrentSchedule[0],cont,oppLineItems,productsMap));
             }else if(currentContractVlo.Id != null){
                 ServiceResponse.Schedule.add(new ProductSchedule(isSchedule,null,currentContractVlo,oppLineItems,productsMap));
             }
             //ServiceResponse.Schedule.add(new ProductSchedule(isSchedule,CurrentSchedule[0],CurrentContract[0],oppLineItems,productsMap));
         }
         return ServiceResponse;
    }
    
    static List<SterlingQuoteItem__c> getSterlingQuoteItems(ID oppty){
        return [SELECT AdjustedMRC__c,AdjustedNRC__c,BuildingNumber__c,Locality__c,MajorLine__c,Renewal_MRR_Original__c,MinorLine__c,Name,NPA__c,NXX__c,ItemCode__c,
                PA_AddressLine1__c,PA_AddressLine2__c,PA_AddressLine3__c,Postcode__c,Quantity__c,RequestedDueDateNew__c,SA_BuildingName__c,
                SA_StreetDirection__c,SA_StreetName__c,SA_StreetNrFirst__c,SA_StreetPostDirection__c,SA_StreetSubDescription__c,
                SA_StreetSuffix__c,SA_SubDivision__c,SA_unitDesignator__c,SA_UnitNumber__c,SA_WireCenter__c,ServiceControlNumber__c,
                ServiceSequenceNumber__c,StateProvince__c,ST_AddressID__c,ST_LineKey__c,ST_ParentLineKey__c,ST_SKU__c,TermLength__c, Products__c, Products__r.ProductCode
                FROM SterlingQuoteItem__c 
                WHERE
                SterlingQuote__r.OpportunityId__c = :oppty AND SterlingQuote__r.IsSyncing__c  = true ORDER BY MinorLine__c];
    }
    
    static List<Contract> getContract(String schedule_Name){
        return [SELECT Id, Name, StartDate, EndDate, Opportunity__c, ScheduleID__c FROM Contract where ScheduleID__c = :schedule_Name and recordtypeid = '012E0000000kJ6HIAU'];
    }
    
    static List<Schedule__c> getSchedule(String schedule_Name){
        return [SELECT Id, Name, State__c, City__c, Street_Address__c, Zip_Code__c, Schedule_Start_Date__c, Schedule_End_Date__c, New_Opportunity__c FROM Schedule__c WHERE Name = :schedule_Name];
    }
    
    static List<Quote> getVlocityQuote(String schedule_Name){
        
        return [SELECT Id,Name, OpportunityId, Schedule_Number__c FROM Quote WHERE Schedule_Number__c = :schedule_Name  LIMIT 1];
    }
    static List<Order> getVlocityOrder(String scheduleId){
        return [SELECT Id, Name,AccountId,orderNumber, CreatedDate, Customer_Requested_Date__c, vlocity_cmt__RequestedStartDate__c, vlocity_cmt__RequestedCompletionDate__c,OpportunityId, Vlocity_Schedule_ID__c FROM Order WHERE Vlocity_Schedule_ID__c = :scheduleId AND Order_Stage__c <> 'Cancelled' order by createdDate DESC];
    }
    static List<OrderItem> getOrderItems(Order[] orders){
        Map<Id, Order> orderMap = new Map<Id, Order>(orders);
        return [SELECT Id, 
                    Order.Name,
                    vlocity_cmt__Product2Id__c,
                    vlocity_cmt__RecurringTotal__c,
                    vlocity_cmt__OneTimeTotal__c,
                    vlocity_cmt__OneTimeCharge__c,
                    vlocity_cmt__RecurringCharge__c,
                    vlocity_cmt__LineNumber__c,
                    vlocity_cmt__SequenceNumber__c,
                    vlocity_cmt__LineItemNumString__c,
                    Quantity,
                    SNE_Code_MRC__c,
                    SNE_Code_OTC__c,
                    vlocity_cmt__ServiceAccountId__r.ShippingStreet,
                    vlocity_cmt__ServiceAccountId__r.ShippingCity,
                    vlocity_cmt__ServiceAccountId__r.ShippingState,
                    vlocity_cmt__ServiceAccountId__r.ShippingPostalCode,
                    Order.Account.BTN_Number__c
                    FROM OrderItem
                    WHERE
                    DPI_Enabled__c = false AND
                    OrderId IN :orderMap.keySet() ORDER BY vlocity_cmt__SequenceNumber__c];
    }
    static List<OpportunityLineItem> getOppLineItems(Id oppty){
        return [
            SELECT
            Id, lineItem__c, Quantity, PricebookEntry.Product2Id, Contract_MRR__c, Renewal_MRR__c,Prod_Code__c, Total_MRR__c,NRC_Price__c,CPE_NRC_Price__c, OpportunityId, Description
            FROM OpportunityLineItem
            WHERE OpportunityId = :oppty];
    }
    
}