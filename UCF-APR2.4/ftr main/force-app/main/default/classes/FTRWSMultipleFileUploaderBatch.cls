global class FTRWSMultipleFileUploaderBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    // version 3 
    List<Id> adrList = new List<Id>();
    List<Id> AllAdrList = new List<Id>();
    Id oppId;
    global FTRWSMultipleFileUploaderBatch(List<Id> listAdr){
        adrList = listAdr;
    }
    
    global FTRWSMultipleFileUploaderBatch(List<Id> listAdr,List<Id> IUlistAdr,Id opp_Id){
        adrList = listAdr;
        oppId =opp_Id;
        AllAdrList=IUlistAdr;
    }
    
    global DataBase.QueryLocator start(Database.BatchableContext BC){
        return DataBase.getQueryLocator([Select Id__c,id,Street__c,BSAHttpStatusCode__c,Street_Number__c, Street_Name__c, City__c, State__c,Opportunity_ID__c, Zip_Code__c,Comments__c,
                                         G_Latitude__c,G_Longitude__c,Latitude__c,Longitude__c,Unit_Number__c,Error_Message__c, Service_Control_Number__C, CLLI_Code__C, 
                                         Fiber_Tier__c, DSAT_Max_Speed__c, Copper_Tier__c,Request_speed__c,Copper_Distance__c, WireCenter_CLLI__c, DPI_Qualified__c, DSAT_Qualified__c, Max_Qos__c,Address__c
                                         from FTRWSAddress__c where Id=: adrList]);
    }
    
    global void execute(Database.BatchableContext BC,List<FTRWSAddress__c> queryaddress){
        List<FTRWSAddress__c> addressUpd = new List<FTRWSAddress__c>();
        FTRWSDSATAddressResponse dsatResp;
        List<FTRWSDPIAddressResponse> dpirespList;
        Map<id,FTRWSDSATAddressResponse> DSATRespMap = new Map<id,FTRWSDSATAddressResponse>();
        Map<id,List<FTRWSDPIAddressResponse>> DPIRepMap = new  Map<id,List<FTRWSDPIAddressResponse>>();
        List<Map<String, Object>> logOutputList = new List<Map<String, Object>>();//bulk
        List<Map<String, Object>> logInputList = new List<Map<String, Object>>();//bulk
        Boolean DSATException = False;
        Boolean DPIException = False;
        Boolean DSATID = False;
        for(FTRWSAddress__c address : queryaddress){   
            if(address.Comments__c == null)
                address.Comments__c='';
            if(address.Street_Number__c ==null)
                address.Street_Number__c ='';
            address.Street_Name__c = address.Street_Name__c==null?'':address.Street_Name__c;
            address.Street__c = address.Street__c==null?'':address.Street__c;
            
            ftr_addressBeanDSAT addressBean = new ftr_addressBeanDSAT();
            addressBean.Address = address.Street__c;
            addressBean.city=address.City__c;
            addressBean.state=address.State__c;
            addressBean.zipCode=address.Zip_Code__c;            
            addressBean.Latitude = (address.Latitude__c =='' || address.Latitude__c ==null) ? address.G_Latitude__c:address.Latitude__c;
            addressBean.Longitude = (address.Longitude__c=='' || address.Longitude__c==null) ? address.G_Longitude__c:address.Longitude__c;
            
             try{
                if(!Test.isRunningTest()){ 
                    if(address.Id__c!=null && address.Id__c!=''){
                        DSATID=true;
                        dsatResp = FTRWSDSATAddressController.getDSATAddressWithDSATID(address.Id__c);
                    }
                    else if(address.Latitude__c!=null && address.Latitude__c!='' && address.Longitude__c!=null && address.Longitude__c!=''){
                        ftr_addressBeanDSAT addressBean_DSAT_Lat_Lon = new ftr_addressBeanDSAT();
                        addressBean_DSAT_Lat_Lon.Latitude = address.Latitude__c;
                        addressBean_DSAT_Lat_Lon.Longitude = address.Longitude__c;
                        dsatResp = FTRWSDSATAddressController.getDSATAddress(addressBean_DSAT_Lat_Lon);
                    }
                    else{
                        dsatResp = FTRWSDSATAddressController.getDSATAddress(addressBean);
                    }
                    
                    
                }else{
                    Test.setMock(HttpCalloutMock.class, new FTRWSDSATAddressControllerPostMock());
                    dsatResp =  FTRWSDSATAddressController.getDSATAddress(addressBean);                
                }            
            }
            Catch(Exception e){
                System.debug('Exception Occured'+e);
                address.Error_Message__c+='DSAT :: '+e.getMessage()+' Stack Trace String ::'+e.getStackTraceString();
                DSATException=True;
            }
            if(dsatResp != null && DSATException==False){               
                setDSATData(address,dsatResp);                                
                DSATRespMap.put(address.Id,dsatResp);
                // address.Comments__c +='DSAT Validated Successfully;';
            }
            else{
                address.DSAT_Validated__c = True;
                address.DSAT_Qualified__c = false;
                address.Comments__c = DSATID ? address.Comments__c+'Invalid DSAT ID;' : address.Comments__c+'Invalid DSAT Address; ';
            }         
            
            ftr_addressBean addressBeanDPI = new ftr_addressBean();
            addressBeanDPI.addressLine1 = address.Street__c;
            addressBeanDPI.cityName=address.City__c;
            addressBeanDPI.state=address.State__c;
            addressBeanDPI.zipCode=address.Zip_Code__c;
            addressBeanDPI.setIncludeFutureFacilityInformation = true;
            addressBeanDPI.setIncludeDuplicateFacilityInformation= true;
            addressBeanDPI.setRequireUniqueAddress = true;
            System.debug('@@@  adr bean::'+addressBeanDPI);
            try{
                if(!Test.isRunningTest()){               
                    dpirespList = FTRWSDPIAddressController.retreiveMatchingCustomerFacilityBulk(addressBeanDPI,address.Unit_Number__c);
                    //  system.debug('DPI Successs');
                }else{
                    Test.setMock(WebServiceMock.class, new FTRWSDPIAddressValResultMock());
                    dpirespList = FTRWSDPIAddressController.retreiveCustomerFacility(addressBeanDPI); 
                }
                if(dpirespList!=null && dpirespList.size() ==1 && dpirespList[0].status=='SUCCESS'){
                    setDPIData(address, dpirespList[0]);
                    DPIRepMap.put(address.Id,dpirespList);
                }
                addressBean.Longitude = address.Longitude__c;
                addressBean.Latitude = address.Latitude__c;
            }
            // Added Error Condition - To log exception errors
            Catch(Exception e){
                System.debug('Exception Occured'+e);
                address.DPI_Validated__c = True;
                address.DPI_Qualified__c = false;
                address.Error_Message__c='DPI :: '+e.getMessage()+' Stack Trace String ::'+e.getStackTraceString()+'\n';
                address.Comments__c +='Invalid DPI Address; ';
                DPIRepMap.put(address.Id,dpirespList);
                DPIException = True;
            }
            
           
            if(dpirespList!=null && dpirespList.size() ==1 && dpirespList[0].status=='FAILURE' && DPIException==False){
                address.DPI_Validated__c = True;
                address.DPI_Qualified__c = false;
                address.Comments__c +='Invalid DPI Address; ';
                DPIRepMap.put(address.Id,dpirespList);
            }   
            
            if(dsatResp != null && address.DSAT_Qualified__c == false && address.DSAT_Max_Speed__c!=null && address.DSAT_Max_Speed__c!='0MB' && address.DSAT_Max_Speed__c!=''){
                address.Comments__c +='';
            }
            if(dpirespList!=null && dpirespList.size() >1 ){
                address.DPI_Validated__c = True;
                address.DPI_Qualified__c = false;
                address.Comments__c +='Multiple DPI addresses found, please validate the address manually';
                DPIRepMap.put(address.Id,dpirespList);
            }
            
            System.debug('@@@Address to update'+address);
            addressUpd.add(address); 
        }
        
        update addressUpd;
        Integer size = logInputList.size()>=logOutputList.size()?logInputList.size():logOutputList.size();
        for(integer i=0;i<size;i++){
            APILogger log = new APILogger();
            log.createEntry(logInputList[i],logOutputList[i]);
            system.debug('** Im for logger Imput'+logInputList[i]);
            system.debug('** Im for logger Output'+logOutputList[i]);
        }
    }
    
    
    
    
    private static void setDPIData(FTRWSAddress__c address, FTRWSDPIAddressResponse dpiData) {
        
        
        //address.Unit_Number__c = dpiData.unit;
        //Remove Address
        /*
        String streetNo = dpiData.streetNumber;
        address.Street_Number__c = address.Street_Name__c==''?streetNo:address.Street_Number__c;
        address.Street_Name__c = address.Street_Name__c==''? dpiData.streetName:address.Street_Name__c;
        address.City__c = address.City__c==''?dpiData.cityName:address.City__c;
        address.State__c = address.State__c==''?dpiData.state:address.State__c;
        address.Zip_Code__c = address.Zip_Code__c==''?dpiData.zipCode:address.Zip_Code__c;
*/
        //Remove Address
        address.CLLI_Code__c = dpiData.clliCode;
        address.Service_Control_Number__c = dpiData.svcControlNo;
        address.Wire_Center__c = dpiData.wirecenter;
        
        
        if(dpiData.latitude!=null && dpiData.latitude !='')
            address.Latitude__c = dpiData.latitude;
        
        if(dpiData.longitude!=null && dpiData.longitude !='')
            address.Longitude__c = dpiData.longitude;
        
        
        
        // System.debug('address.Latitude__c : '+address.Latitude__c);
        // System.debug('address.Longitude__c : '+address.Longitude__c);
        address.DPI_Validated__c = true;
        address.DPI_Qualified__c = true;
    }
    
    private static void setDSATData(FTRWSAddress__c address, FTRWSDSATAddressResponse dsatData) {
        
        address.Business_Name__c = dsatData.businessName;
        address.Id__c = dsatData.dsatId;
        address.VFO_Record_Id__c = dsatData.vfoRecordId;
        address.M6_Order_Number__c = dsatData.m6OrderNumber;
        address.Created_By__c = dsatData.createdBy;
        address.Creator_Email__c = dsatData.creatorEmail;
        address.Created_By_Id__c = dsatData.createdById;
        address.Opened__c = dsatData.opened;
        address.In_Footprint__c = dsatData.inFootprint;
        address.Market_Id__c = dsatData.market;
        address.Level_Id__c = dsatData.level;
        address.DSAT_Services__c = dsatData.products;
        address.DSAT_Max_Speed__c = dsatData.wireCenterSpeed;
        address.DSAT_Technology__c = 'ETHERNET';
        
        address.WireCenter_CLLI__c = dsatData.wireCenterCLLI;
        address.Site_Name__c = dsatData.siteName;
        address.Max_Qos__c = dsatData.wireCenterQoS;
        address.WireCenter_Speed__c = dsatData.wireCenterSpeed;
        address.Legacy__c = String.isNotBlank(dsatData.wireCenterSpeed) && ftr_CpqHelper.convertToSpeed(dsatData.wireCenterSpeed) > 0?'Yes':'No';
        address.Lit_Building__c = dsatData.litBuilding;
        
        address.Fiber_Distance__c = dsatData.fiberDistance;
        address.Fiber_Qualification__c = dsatData.fiberQualification;
        address.Fiber_Tier__c = dsatData.fiberTier;
        
        address.Copper_Distance__c= dsatData.copperDistance;
        address.Copper_Tier__c = dsatData.copperTier;   
        address.Copper_Qualification__c = dsatData.copperQualification;  
        
        address.Latitude__c = dsatData.latitude;  
        address.Longitude__c = dsatData.longitude; 
        system.debug('dsatData.City => ' + dsatData.City);
        system.debug('dsatData.State => ' + dsatData.State);
        system.debug('dsatData.Address => ' + dsatData.Address);
        system.debug('dsatData.ZipCode => ' + dsatData.ZipCode); 
        /*address.City__c = dsatData.City!=''|| dsatData.City!=null ?dsatData.City:address.City__c;
        address.State__c=dsatData.State!=null || dsatData.State!='' ?dsatData.State:address.State__c;        
        address.Street_Name__c=dsatData.Address!='' || dsatData.Address!=null ?dsatData.Address:address.Street_Name__c;
        address.Zip_Code__c= (dsatData.ZipCode!= null && dsatData.ZipCode.length() > 5) ? dsatData.ZipCode.substring(0,5):dsatData.ZipCode;*/
        address.City__c = String.isNotBlank(dsatData.City) ?dsatData.City:address.City__c;
        address.State__c= String.isNotBlank(dsatData.State)?dsatData.State:address.State__c;        
        address.Street_Name__c=String.isNotBlank(dsatData.Address)?dsatData.Address:address.Street_Name__c;
        address.Zip_Code__c= (dsatData.ZipCode!= null && dsatData.ZipCode.length() > 5) ? dsatData.ZipCode.substring(0,5):dsatData.ZipCode;
        if(dsatData.City!='' && dsatData.State!=null && dsatData.Address!='' && dsatData.ZipCode!='' ){
            address.Address__c=dsatData.Address+' '+dsatData.City+' '+dsatData.State+' '+dsatData.ZipCode;
            address.Zip_Code__c= (dsatData.ZipCode.length() > 5) ? dsatData.ZipCode.substring(0,5):dsatData.ZipCode;
        }
        address.Street__c = address.Street_Name__c;
       
        address.DSAT_Validated__c = true;
        address.DSAT_Qualified__c = true;
        
        // Changes for BSA - Start
        address.link_status__c = dsatData.LinkStatus; 
        address.length_feet__c = dsatData.LengthFeet;
        address.Fiber_Cost__c = dsatData.FiberCost;
        address.Equipment_Cost__c = dsatData.EquipmentCost;
        address.Total_Cost__c = dsatData.TotalCost;
        
        if(address.Total_Cost__c > 0){
            address.Fiber_Tier__c = 'DEAL DESK';
        } else {
            address.Fiber_Tier__c = dsatData.fiberTier!=null?dsatData.fiberTier:'';
        } 
        address.Future_HBE_WC_Speed__c = dsatData.FutureHBEWcSpeed != null ?dsatData.FutureHBEWcSpeed : '-' ;
        address.Planned_HBE_Timeframe__c = dsatData.PlannedHBETimeframe != null ? dsatData.PlannedHBETimeframe : '-';
        /* CML-1958 START*/
        address.SWC_CLLI__c = dsatData.WirecenterClliCode;
        address.Plan_ID__c = dsatData.PlanId;
        address.New_Fiber_Build_Footage__c = dsatData.TotalNewFiberFt;
        address.CO_to_Site_Total_Footage__c = dsatData.CoToSiteFt;
        address.Total_New_Fiber_OSP_Costs__c = dsatData.TotalFiberCost;
        address.Splice_Count_Splice_Locations__c = dsatData.SpliceCount;
        address.Splicing_Cost__c = dsatData.SplicingCost;
        address.NID_SFP_Costs_1G_below__c = dsatData.BbCostLtEt1gb;
        address.NID_SFP_Costs_1G_up_to_10G__c = dsatData.BbCostGt1gbLtEt10gb;
        address.NID_SFP_Costs_10G__c = dsatData.BbCostGt10gb;
        address.TR_Costs_1G_below__c = dsatData.TrCostLtEt1gb;
        address.TR_Costs_1G_up_to_10G__c = dsatData.TrCostGt1gbLtEt10gb;
        address.TR_Costs_10G__c = dsatData.TrCostGt10gb;
        address.Servable__c = dsatData.Servable;
        address.Review_Status__c = dsatData.ReviewStatus;
        address.Review_Reason__c = dsatData.ReviewReason;
        address.Route_Notes__c = dsatData.RouteNotes;
        address.BSAHttpStatusCode__c = dsatData.BSAHttpStatusCode != null && dsatData.BSAHttpStatusCode == 503 ? Label.BSA_DOWN_503_MESSAGE :address.BSAHttpStatusCode__c;
        address.BSAHttpStatusCode__c = dsatData.BSAHttpStatusCode != null && dsatData.BSAHttpStatusCode == 408 ? Label.BSA_DOWN_408_MESSAGE :address.BSAHttpStatusCode__c;
        address.Guardrail_Cost__c = dsatData.GuardRailCost;
        address.HBE_Max_Qos__c = dsatData.HBEMaxQoS;
        address.HBE_Max_Speed__c = dsatData.HBEMaxSpeed;
        address.HBE__c = String.isNotBlank(dsatData.HBEMaxSpeed) && ftr_CpqHelper.convertToSpeed(dsatData.HBEMaxSpeed) > 0 ? 'Yes' : 'No';
        if (address.Total_New_Fiber_OSP_Costs__c != null && address.Total_New_Fiber_OSP_Costs__c > 0 && address.Fiber_Tier__c != null && address.Fiber_Tier__c == 'BDT') {
            address.DSAT_Qualified__c = true;
        }
if(address.Copper_Qualification__c == 'BDT' && address.Fiber_Qualification__c == 'BDT') {
        	address.DSAT_Qualified__c = false;
            if(address.Comments__c  != null && address.Comments__c != '') {
            	address.Comments__c = address.Comments__c  + ' ' + 'Invalid DSAT Address;';    
            } else {
                address.Comments__c = 'Invalid DSAT Address;';    
            }
            
        } else {
        	address.Comments__c = '';    
        }
        /* CML-1958 END*/
    }  
    // Changes for BSA - End
    
    global void finish(Database.BatchableContext BC){
        Database.executeBatch(new FTRWSAddress_CVDRatesBatch(AllAdrList,oppId),10);
        
    }
}