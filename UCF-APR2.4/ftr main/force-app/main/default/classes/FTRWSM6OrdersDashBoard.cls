@RestResource(urlMapping='/orders/*')
global with sharing class FTRWSM6OrdersDashBoard {
    
    static Map<String,FTRWSCircuits__c> cList = new Map<string,FTRWSCircuits__c>(); //SDDD-2041
    
    static RestRequest req;
    static RestResponse res;
    
    //START CODE FIX FOR JIRA DEFECT: SDDD-2443
    static String EXCEPTION_QUEUE_NAME = 'WSMissingACNA';
    //END CODE FIX FOR JIRA DEFECT: SDDD-2443
    
    public FTRWSM6OrdersDashBoard() {   }
    
    class FTRWSM6OrdersDashBoardException extends Exception {}
    
    @HttpPost
    global static void upsertOrder() {
        //Start-- API Logging
        Wholesale_Service_Order__c wholesaleServiceOrder;
        req = RestContext.request;
        res = RestContext.response;
        FTRWSM6OrderWrapper m6orderObj;
        String errorMsg = null;
        String  existingSONumber = null;
        try{
            //check url size/is valid URL/throw an error not valid url
            
            m6orderObj = (FTRWSM6OrderWrapper) JSON.deserialize(req.requestBody.toString(), FTRWSM6OrderWrapper.class);
            existingSONumber = m6orderObj.order.ServiceOrderNo;
            
            System.debug('m6orderObj='+req.requestBody.toString());
            if(String.isNotEmpty(existingSONumber)){
                Wholesale_Service_Order__c sOrder = retrieveExistingOrder(existingSONumber);
                wholesaleServiceOrder= populateServiceOrder(sOrder, m6orderObj);
                upsert wholesaleServiceOrder;           
                
                //SDDD-2041 Begin
                for(FTRWSCircuits__c cl: cList.values()){
                    cl.Wholesale_Service_Order__c = wholesaleServiceOrder.Id;
                }
                
                system.debug('wholesaleServiceOrderIdwholesaleServiceOrderId'+wholesaleServiceOrder.Id);
                for(FTRWSCircuits__c cl2:[select id,Circuit_ID__c,Wholesale_Service_Order__c from FTRWSCircuits__c where Wholesale_Service_Order__c =: wholesaleServiceOrder.Id]){
                    if(cList.containsKey(cl2.Circuit_ID__c)){
                        cList.remove(cl2.Circuit_ID__c);
                    }
                }
                if(!cList.isEmpty()){
                    try {
                        Database.insert(cList.values(),false);
                    } catch(DmlException e) {
                        res.statusCode = 405;
                        res.responseBody = Blob.valueOf('{"error":"Duplicate circuit ID Not Allowed"}');
                    }
                }                    
                //SDDD-2041 End
                
                /* Moved the code to set Opportunity stage code to seperate method for not throwing the error back to M6*/
                setOpportunityStageCode(m6orderObj, wholesaleServiceOrder);
                
            }
            
            //logSuccessMessage(m6orderObj, res, existingSONumber, m6orderObj.order.OpportunityNumber, 'Success');
            
        }catch(Exception ex) {
            System.debug(ex);
            //Need to talk to Hemantha about the error logging. To send proper response back to M6 in case of error
            errorMsg = ex.getMessage() + '--' + ex.getStackTraceString() ;
        } finally {
            if(errorMsg != null) {
                logErrorMessage(m6orderObj, 'NONE', existingSONumber, 'NONE', 'Error', errorMsg);
                setErrorResponse(errorMsg);
            } else {
                String serializedjson = JSON.serialize(wholesaleServiceOrder);                
                res.responseBody = Blob.valueOf(serializedjson);
                res.statusCode = 200;
                res.addHeader('Content-Type', 'application/json');
                logSuccessMessage(m6orderObj, res, existingSONumber, m6orderObj.order.OpportunityNumber, 'Success');
            }
        }
    }
    
    // retrieve the existing service order
    private static Wholesale_Service_Order__c retrieveExistingOrder(String existingSONumber){
        Wholesale_Service_Order__c serviceorder = null;
        try{
            serviceorder = [SELECT Additional_Comments__c,AE_Contact_Number__c,AE_CRIS__c,AE_Name__c,ASR_Remarks__c,BDT_Required__c,
                            BDT__c, Activity_Indicator__c, Order_Type__c, FOC__c, Cancellation__c,CCEA__c,CCNA__c,CFA__c,Circuit_ID__c,Circuit_Quantity__c,ConnectionReceivedId,
                            ConnectionSentId,Control_Key__c,CreatedById,CreatedDate,Customer_Technical_Solution_Sign_Off__c,DSAT_ID__c,
                            EVCI__c,EVC_BDW__c,EVC_NCI__c,EVC_NC__c,EVC_SPEC_Code__c,Expedite__c,Id,Initiatior_Email__c,
                            Initiatior_Name__c,Initiatior_TN__c,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,
                            LastReferencedDate,LastViewedDate,Maximum_Service_Frame_Size__c,MRC__c,MUX__c,Name,NRC__c,OpportunityId__c,
                            Opportunity__c,Order_Record_Type__c,Order_Stage__c,OwnerId,PON__c,PRILOC_ACTL_NNI_CLLI__c,
                            PRILOC_ADDRESS__c,PRILOC_End_User_Name__c,PRILOC_LCON_Email__c,PRILOC_LCON_TN__c,PRILOC_LCON__c,
                            Project_Id__c,Quality_of_Service__c,Requested_Due_Date__c,RPON__c,
                            Scheduled_Due_Date__c,SECLOC_ACTL_NNI_CLLI__c,SECLOC_Address__c,SECLOC_End_User_Name__c,
                            SECLOC_LCON_Email__c,Promotion_Num_PNUM__c, SECLOC_LCON_TN__c,SECLOC_LCON__c,SEI__c,Service_Order__c,Solutions_Engineer__c,
                            Stage_Owner__c,Supplement_Type__c,SystemModstamp,Term_VTA__c,UNI_BDW__c,UNI_NNI_NCI__c,UNI_NNI_NC__c,
                            UNI_NNI_SECNCI__c,UNI_SPEC_Code__c,Version__c,Wholesale_ACNA__c 
                            FROM Wholesale_Service_Order__c where Service_Order__c =:existingSONumber LIMIT 1];
            
        }catch(Exception e){
            e.getStackTraceString();
        }
        system.debug('---existing service order object log ---' + serviceorder);
        return serviceorder;
        
    }
    
    
    // get latest opportunity for the account
    @TestVisible
    private static String getLatestOpportunity(FTRWSM6OrderWrapper m6orderObj){
        Id OppId;
        boolean oppByProjectId = false;
        //match for project Id
        if (String.isNotEmpty(m6orderObj.order.ProjectId)){
            
            try{
                Opportunity existingOpp = [SELECT Id from Opportunity where Project_Id__c =:m6orderObj.order.ProjectId];
                OppId=existingOpp.Id;
                oppByProjectId = true;
                return OppId;
            } catch(Exception e) {
                System.debug('No existing opp found with the given project id: ' + m6orderObj.order.ProjectId + '----' + e.getMessage());
            }
        }
        
        //match for opportunity Id
        if (String.isNotEmpty(m6orderObj.order.OpportunityNumber)){
            try{
                Opportunity existingOpp = [SELECT Id from Opportunity where Id =:m6orderObj.order.OpportunityNumber];
                if (existingOpp != null){
                    return existingOpp.Id;
                }
            }   catch(Exception e){
                System.debug('No match found for opportunity Id:' + m6orderObj.order.OpportunityNumber);
            }    
        }
        
        //match with PRILOC
        if (String.isNotEmpty(m6orderObj.order.acna) && 
            String.isNotEmpty(m6orderObj.order.PRILOC_STREET_NUMBER) && 
            String.isNotEmpty(m6orderObj.order.PRILOC_STREET_NAME) &&
            String.isNotEmpty(m6orderObj.order.PRILOC_CITY) &&
            String.isNotEmpty(m6orderObj.order.PRILOC_STATE)){
                try{
                    FTRWSAddress__c serviceAddress = [SELECT Id,Opportunity_ACNA__c,Opportunity_ID__c,Street_Number__c,Street_Name__c,City__c,State__c,Zip_Code__c 
                                                      FROM FTRWSAddress__c 
                                                      WHERE Opportunity_ACNA__c =:m6orderObj.order.acna AND 
                                                      Street_Number__c =:m6orderObj.order.PRILOC_STREET_NUMBER AND
                                                      Street_Name__c =:m6orderObj.order.PRILOC_STREET_NAME AND
                                                      City__c =:m6orderObj.order.PRILOC_CITY AND
                                                      State__c =:m6orderObj.order.PRILOC_STATE ORDER BY CreatedDate desc LIMIT 1];
                    return serviceAddress.Opportunity_ID__c;    
                }catch(Exception e){
                    System.debug('No mactch found for Opportunity address:' + m6orderObj.order.acna + ' ' + m6orderObj.order.PRILOC_STREET_NUMBER );
                    //throw e;
                }        
            }
        //START CODE FIX FOR JIRA DEFECT: SDDD-2443
        FTRWSAcna__c acnaObj = null;
        try {
            acnaObj = [SELECT Id, Name, Company__c from FTRWSAcna__c WHERE name =:m6orderObj.order.acna LIMIT 1];
        } catch(Exception e) {
            emailErrorDetailsToUsers(e.getMessage(), e.getStackTraceString(), m6orderObj.order.acna, m6orderObj.order.PRILOC_EndUserName, m6orderObj.order.ServiceOrderNo);
            logErrorMessage(m6orderObj, 'NONE', m6orderObj.order.ServiceOrderNo, 'NONE', 'Error', e.getMessage());
        }
        //END CODE FIX FOR JIRA DEFECT: SDDD-2443
        
        Opportunity oop_rectype =  [SELECT RecordTypeId, RecordType.DeveloperName from Opportunity where RecordType.DeveloperName = 'Carrier_Service' LIMIT 1];
        
        Opportunity opp = new Opportunity();
        opp.Name='M6 ' + m6orderObj.order.ServiceOrderNo + ' ' + Datetime.now().format('MM-dd-yyyy');
        opp.AccountId = acnaObj.Company__c;
        opp.StageName='Evaluating.';
        opp.CloseDate = system.today();
        opp.RecordTypeId = oop_rectype.RecordTypeId;
        Id pnumId = getPnum(m6orderObj.order.pnum, acnaObj.Id);
        //start code fix for SDDD-2378
        if(pnumId == null) {
            pnumId = insertInactivePnum(m6orderObj.order.pnum, acnaObj.Id);
        }
        //End code fix for SDDD-2378
        opp.Wholesale_Pnum__c = pnumId;
        opp.Wholesale_ACNA__c = acnaObj.Id;
        
        //Defect fix for JIRA ticket#OAM-1371
        if(String.isNotEmpty(m6orderObj.order.ProjectId) && !oppByProjectId) {
            opp.Project_Id__c = m6orderObj.order.ProjectId;
        }
        insert opp;
        return opp.Id;
        
    }
    
    // populate the service order
    @TestVisible
    private static Wholesale_Service_Order__c populateServiceOrder(
        Wholesale_Service_Order__c wholesaleServiceOrder,FTRWSM6OrderWrapper m6orderObj){
            
            Boolean expedite = false;
            Boolean bdtRequired = false;
            if (m6orderObj.order.Expedite == 'Y'){
                expedite = true;
            }
            
            if (m6orderObj.order.BDTRequired == 'Y'){
                bdtRequired = true;
            }
            
            if(wholesaleServiceOrder == null){
                wholesaleServiceOrder = new Wholesale_Service_Order__c();
                String opportunityid = getLatestOpportunity(m6orderObj);
                wholesaleServiceOrder.OpportunityId__c = opportunityid;
                wholesaleServiceOrder.Service_Order__c = m6orderObj.order.ServiceOrderNo;
            }             
            wholesaleServiceOrder.Wholesale_ACNA__c = getACNA(m6orderObj.order.ACNA);
            wholesaleServiceOrder.Maximum_Service_Frame_Size__c = m6orderObj.order.MaxServiceFrameSize;
            wholesaleServiceOrder.BDT_Required__c = bdtRequired;
            wholesaleServiceOrder.Promotion_Num_PNUM__c = m6orderObj.order.PNUM;
            wholesaleServiceOrder.Project_ID__c = m6orderObj.order.ProjectId;
            wholesaleServiceOrder.DSAT_ID__c = m6orderObj.order.DSATID;
            wholesaleServiceOrder.Expedite__c = expedite;
            wholesaleServiceOrder.Term_VTA__c = m6orderObj.order.VTA;
            wholesaleServiceOrder.UNI_BDW__c= m6orderObj.order.UNIBDW;
            wholesaleServiceOrder.EVC_BDW__c = m6orderObj.order.EVCBDW;
            wholesaleServiceOrder.Order_Stage__c = m6orderObj.order.OrderStage;
            wholesaleServiceOrder.Quality_Of_Service__c = m6orderObj.order.QoS;
            wholesaleServiceOrder.PON__c = m6orderObj.order.PON;
            wholesaleServiceOrder.Version__c = m6orderObj.order.Version;
            wholesaleServiceOrder.RPON__c = m6orderObj.order.RPON;
            wholesaleServiceOrder.ASR_Remarks__c = m6orderObj.order.ASRRemarks;
            wholesaleServiceOrder.CCNA__c = m6orderObj.order.CCNA;
            DateTime rq_dt =  m6orderObj.order.RequestedDueDate;
            DateTime sc_dt = m6orderObj.order.ScheduledDueDate;
            
            if (rq_dt != null){
                wholesaleServiceOrder.Requested_Due_Date__c =  date.newinstance(rq_dt.year(), rq_dt.month(), rq_dt.day() + 1);
            }
            if (sc_dt != null){
                wholesaleServiceOrder.Scheduled_Due_Date__c = date.newinstance(sc_dt.year(), sc_dt.month(), sc_dt.day() + 1);
            }
            
            //FOC Date
            DateTime foc_dt = m6orderObj.order.FOCDate;
            
            if (foc_dt != null){
                wholesaleServiceOrder.FOC__c =  date.newinstance(foc_dt.year(), foc_dt.month(), foc_dt.day() + 1);
            }
            
            //JIRA ticket:OAM-1376 fix for Control key
            //Sample [Control Key:1002285, LSO:330273, SWC:BRWKOHXADS0]
            String inputStr = m6orderObj.order.ControlKeyNo;
            System.debug('Before formatting ControlKey:' + inputStr);
            //STRART JIRA ticket:SDDD-2442 for control key fields with extra characters
            if(String.isNotBlank(inputStr) && (inputStr.indexOf('[') > -1) && (inputStr.indexOf(']') > -1)) {
                inputStr = inputStr.substring(inputStr.indexOf('['), inputStr.indexOf(']')+1);
                System.debug('Formatted ControlKey String:' + inputStr);
            }
            //END JIRA ticket:SDDD-2442 for control key fields with extra characters            
            if(String.isNotBlank(inputStr) && (inputStr.indexOf(':') > -1) && (inputStr.indexOf(',') > -1)) {
                inputStr = inputStr.substring(inputStr.indexOf(':')+1, inputStr.indexOf(','));
                System.debug('ControlKey:' + inputStr);            
                wholesaleServiceOrder.Control_Key__c = inputStr;
            }
            
            wholesaleServiceOrder.UNI_SPEC_Code__c = m6orderObj.order.UNISpecCode;
            wholesaleServiceOrder.EVC_Spec_Code__c = m6orderObj.order.EVCSpecCode;
            wholesaleServiceOrder.SEI__c = m6orderObj.order.SEI;
            wholesaleServiceOrder.EVCI__c = m6orderObj.order.EVCI;
            wholesaleServiceOrder.Initiatior_Name__c = m6orderObj.order.InitiatiorName;
            wholesaleServiceOrder.Initiatior_TN__c = m6orderObj.order.InitiatiorNumber;
            
            if (m6orderObj.order.InitiatiorEmail != null && m6orderObj.order.InitiatiorEmail.contains('@')){
                wholesaleServiceOrder.Initiatior_Email__c = m6orderObj.order.InitiatiorEmail;
            }
            wholesaleServiceOrder.Circuit_Quantity__c = m6orderObj.order.CircuitQuantity;
            
            //SDDD-2041 begin
            String circuits = m6orderObj.order.CircuitId;
            if (circuits != null) {
                List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(circuits);
                for(Object fld : fieldList){    
                    Map<String,Object> data = (Map<String,Object>)fld;                  
                    FTRWSCircuits__c c = new FTRWSCircuits__c();
                    c.Circuit_ID__c  = String.valueof(data.get('CircuitId'));
                    c.UNI_NNI_NC__c  = String.valueof(data.get('UNINC'));
                    c.UNI_NNI_NCI__c = String.valueof(data.get('UNINCI'));
                    c.UNI_NNI_SECNCI__c = String.valueof(data.get('UNISECNCI'));
                    cList.put(String.valueof(data.get('CircuitId')),c);
                }              
            }
            //SDDD-2041 end
            
            wholesaleServiceOrder.UNI_NNI_NC__c = m6orderObj.order.UNINC;
            wholesaleServiceOrder.UNI_NNI_NCI__c = m6orderObj.order.UNINCI;
            wholesaleServiceOrder.UNI_NNI_SECNCI__c = m6orderObj.order.UNISECNCI;
            wholesaleServiceOrder.EVC_NC__c = m6orderObj.order.EVCNC;
            wholesaleServiceOrder.EVC_NCI__c = m6orderObj.order.EVCNCI;
            wholesaleServiceOrder.MUX__c = m6orderObj.order.MUX;
            wholesaleServiceOrder.CFA__c = m6orderObj.order.CFA;
            wholesaleServiceOrder.CCEA__c = m6orderObj.order.CCEA;
            wholesaleServiceOrder.SUPPLEMENT_TYPE__c = m6orderObj.order.SUPPLEMENTTYPE;
            wholesaleServiceOrder.PRILOC_End_User_Name__c = m6orderObj.order.PRILOC_EndUserName;
            //wholesaleServiceOrder.PRILOC_End_User_Address__c = m6orderObj.order.PRILOC_EndUserAddress; //Defect OAM-1369 changes
            wholesaleServiceOrder.PRILOC_ACTL_NNI_CLLI__c = m6orderObj.order.PRILOC_ACTL_NNI_CLLI;
            wholesaleServiceOrder.PRILOC_LCON__c = m6orderObj.order.PRILOC_LCON;
            wholesaleServiceOrder.PRILOC_LCON_TN__c = m6orderObj.order.PRILOC_LCON_TN;
            
            if (m6orderObj.order.PRILOC_LCON_Email != null && m6orderObj.order.PRILOC_LCON_Email.contains('@')){
                wholesaleServiceOrder.PRILOC_LCON_Email__c = m6orderObj.order.PRILOC_LCON_Email;
            }
            wholesaleServiceOrder.SECLOC_End_User_Name__c = m6orderObj.order.SECLOC_EndUserName;
            //wholesaleServiceOrder.SECLOC_End_User_Address__c = m6orderObj.order.SECLOC_EndUserAddress; //Defect OAM-1369 changes
            wholesaleServiceOrder.SECLOC_ACTL_NNI_CLLI__c = m6orderObj.order.SECLOC_ACTL_NNI_CLLI;
            wholesaleServiceOrder.SECLOC_LCON__c = m6orderObj.order.SECLOC_LCON;
            wholesaleServiceOrder.SECLOC_LCON_TN__c = m6orderObj.order.SECLOC_LCON_TN;
            
            if (m6orderObj.order.SECLOC_LCON_Email != null && m6orderObj.order.SECLOC_LCON_Email.contains('@')){
                wholesaleServiceOrder.SECLOC_LCON_Email__c = m6orderObj.order.SECLOC_LCON_Email;
            }
            
            //Start Defect OAM-1369 changes
            //****PRILOC Address fields*************            
            if(String.isNotBlank(m6orderObj.order.PRILOC_STREET_NUMBER)) {
                wholesaleServiceOrder.PRILOC_ST_NUMBER__c = m6orderObj.order.PRILOC_STREET_NUMBER;
            }
            
            if(String.isNotBlank(m6orderObj.order.PRILOC_STREET_NAME)) {
                wholesaleServiceOrder.PRILOC_ST_NAME__c = m6orderObj.order.PRILOC_STREET_NAME;
            }
            
            if(String.isNotBlank(m6orderObj.order.PRILOC_CITY)) {
                wholesaleServiceOrder.PRILOC_CITY__c = m6orderObj.order.PRILOC_CITY;
            }
            if(String.isNotBlank(m6orderObj.order.PRILOC_STATE)) {
                wholesaleServiceOrder.PRILOC_STATE__c = m6orderObj.order.PRILOC_STATE;
            }
            if(String.isNotBlank(m6orderObj.order.PRILOC_ZIP)) {
                wholesaleServiceOrder.PRILOC_ZIP__c = m6orderObj.order.PRILOC_ZIP;
            }
            
            //****SECLOC Address fields*************
            if(String.isNotBlank(m6orderObj.order.SECLOC_STREET_NUMBER)) {
                wholesaleServiceOrder.SECLOC_ST_NUMBER__c = m6orderObj.order.SECLOC_STREET_NUMBER;
            }
            
            if(String.isNotBlank(m6orderObj.order.SECLOC_STREET_NAME)) {
                wholesaleServiceOrder.SECLOC_ST_NAME__c = m6orderObj.order.SECLOC_STREET_NAME;
            }
            
            if(String.isNotBlank(m6orderObj.order.SECLOC_CITY)) {
                wholesaleServiceOrder.SECLOC_CITY__c = m6orderObj.order.SECLOC_CITY;
            }
            if(String.isNotBlank(m6orderObj.order.SECLOC_STATE)) {
                wholesaleServiceOrder.SECLOC_STATE__c = m6orderObj.order.SECLOC_STATE;
            }
            if(String.isNotBlank(m6orderObj.order.SECLOC_ZIP)) {
                wholesaleServiceOrder.SECLOC_ZIP__c = m6orderObj.order.SECLOC_ZIP;
            }            
            
            //BDT Number
            if(String.isNotBlank(m6orderObj.order.BDTNumber)) {
                wholesaleServiceOrder.BDT__c = m6orderObj.order.BDTNumber;    
            }
            
            //order type - ASR
            if(String.isNotBlank(m6orderObj.order.type_of_sr)) {
                wholesaleServiceOrder.Order_Type__c = m6orderObj.order.type_of_sr;       
            }
            
            //activity indicator - New/Change/Disconnect
            if(String.isNotBlank(m6orderObj.order.ACTIVITY_IND)) {
                wholesaleServiceOrder.Activity_Indicator__c = m6orderObj.order.ACTIVITY_IND;       
            }
            
            //UNI bandwidth mapped with in the FTRWSCircuit object, no need to map it in the code here.
            
            //End Defect OAM-1369 changes
            return wholesaleServiceOrder;
        }
    
    private static Id getACNA(String acna) {
        Id acnaId;
        try {
            FTRWSAcna__c  acnaObj  = [SELECT Id, Name, Company__c from FTRWSAcna__c WHERE name =:acna LIMIT 1];
            acnaId = acnaObj.Id;
        } catch(Exception e) {
            System.debug('No existing opp found with the given acna: ' + acna + '----' + e.getMessage());
        }
        return acnaId;
    }
    
    @TestVisible
    private static Id getPnum(String pnum, Id acnaId){
        Id pnumId;
        FTRWSPnum__c pnumObj = null;
        try{
            pnumObj = [SELECT Id, Name from FTRWSPnum__c WHERE Name =:pnum  and Wholesale_ACNA__c =:acnaId LIMIT 1];    
            pnumId = pnumObj.Id;
        }catch(Exception e){}
        return pnumId;
    }
    
    //start code fix for SDDD-2378
    private static Id insertInactivePnum(String pnum, Id acnaId) {
        
        Id pnumId;
        FTRWSPnum__c pnumObj = new FTRWSPnum__c();
        pnumObj.Name = pnum;
        pnumObj.Wholesale_ACNA__c = acnaId;
        try{
            insert pnumObj;
            pnumId = pnumObj.Id;
        }catch(Exception e){}
        return pnumId;
    }
    //End code fix for SDDD-2378
    
    //Sets the stage code on Opportunity to Closed/Won if M6 Order Supplement Type != 1
    //Sets the stage code on Opportunity to Closed/Lost if M6 Order Supplement Type == 1
    private static void setOpportunityStageCode(FTRWSM6OrderWrapper m6orderObj, Wholesale_Service_Order__c wholesaleServiceOrder) {
        
        Id oppId = null;
        String stageCode = null;
        try {
            
            if (String.isNotEmpty(wholesaleServiceOrder.OpportunityId__c)){
                oppId = wholesaleServiceOrder.OpportunityId__c;            
                Opportunity opp = new Opportunity(Id = oppId);
                
                //Fix for JIRA Issue:OAM-1362. Supplement type 1 means its cancel order
                String supplementType = wholesaleServiceOrder.Supplement_Type__c; 
                System.debug('Wholesale service order SupplementType: ' + supplementType);
                
                if(String.isNotEmpty(supplementType) && supplementType == '1') {
                    opp.StageName = 'Closed/Lost';
                    stageCode = opp.StageName;
                    opp.Reason_Lost__c = 'Other';
                    opp.Detail_Lost_Reasons__c = 'Other';
                } else {
                    opp.StageName = 'Closed/Won';
                    stageCode = opp.StageName;
                    opp.Reason_Won__c = 'Product Offering';
                }
                update opp;
            }        
            
            
        } catch(Exception ex) {
            String serviceOrderNo = m6orderObj.order.ServiceOrderNo;
            String errorMsg = ex.getStackTraceString();
            System.debug('Unable to set the Opportunity stage code to ' + stageCode + '----' + ex.getMessage());
            logErrorMessage(m6orderObj, 'NONE', serviceOrderNo, oppId, 'Error', errorMsg);
        }
        
    }
    
    @TestVisible
    private static void logErrorMessage(Object request, Object response, String serviceOrderNo, String oppId, String status, String errorMsg) {
        
        
        Map<String, Object> logOutput = new Map<String, Object>();
        
        System.debug('Logging request and response for Wholesale M6: ' + request);
        String taskName = 'upsertOrder';
        Map<String, Object> logInput = new Map<String, Object> {
            
            'request' => request,
                
                'response' => response,
                
                'interface' => taskName,
                
                'system' => 'Wholesale',
                
                'status' => status,
                
                'convertToXML' => false,
                
                'orderNumber' => serviceOrderNo,
                
                'relatedTo' => oppId,
                
                'documentNumber' => serviceOrderNo,//documentNumber,
                
                'errorMessage' => errorMsg,
                
                'errorCode' => '500'                        
                
                };
                    
                    System.debug('Log message request and response: ' + JSON.serialize(logInput));
        
        APILogger log = new APILogger();
        
        log.createEntry(logInput, logOutput);
    }
    
    
    private static void logSuccessMessage(Object request, Object response, String serviceOrderNo, String oppId, String status) {
        try {
            
            Map<String, Object> logOutput = new Map<String, Object>();
            
            System.debug('Logging request and response for Wholesale M6: ' + request);
            String taskName = 'upsertOrder';
            Map<String, Object> logInput = new Map<String, Object> {
                
                'request' => request,
                    
                    'response' => response,
                    
                    'interface' => taskName,
                    
                    'system' => 'Wholesale',
                    
                    'status' => status,
                    
                    'convertToXML' => false,
                    
                    'orderNumber' => serviceOrderNo,
                    
                    'relatedTo' => oppId,
                    
                    'documentNumber' => serviceOrderNo//documentNumber,
                    
                    };
                        
                        System.debug('Log message request and response: ' + logInput);
            
            APILogger log = new APILogger();
            
            log.createEntry(logInput, logOutput);
            
            
        } catch(Exception ex) {
            System.debug('Unable to create log');
            
            System.debug(ex.getMessage());
        }
        
    }
    
    //START CODE FIX FOR JIRA DEFECT: SDDD-2443
    @TestVisible
    public static void emailErrorDetailsToUsers(String message, String stackTraceString, String acna, String company, String m6OrderNo) {
        
        Group myQ = [SELECT Id, Email FROM Group WHERE Type = 'Queue' AND DeveloperName =: EXCEPTION_QUEUE_NAME LIMIT 1];
        
        String[] emails = new String[]{};
            
        String[] userIds = new String[]{};
            
        String resolutionMsg = 'Please manually create the Company and the ACNA records first and then repost the M6 order.';    
                
        for (GroupMember member : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId=:myQ.Id]) {
            userIds.add(member.UserOrGroupId);
                    
        }
        
        for (User u : [SELECT Email FROM User WHERE Id IN :userIds]) {
            
            emails.add(u.Email);
            
        } 
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(emails);
        
        mail.setSubject('Error - Wholesale ACNA Missing');
        
        mail.setHtmlBody(
            
            'Details for the missing ACNA<br/><br/>'
            
            + '<strong>M6 Service OrderNo:  </strong>' + m6OrderNo + ' <br/><br/>'
            
            + '<strong>ACNA Name:  </strong>' + acna + ' <br/><br/>'
            
            + '<strong>Company Name: </strong>' + company + ' <br/><br/>'
            
            + '<strong>Error Message: </strong>' + message + ' <br/><br/>'
            
            + '<strong>Resolution: </strong>' + resolutionMsg + ' <br/><br/>'
            
            //+ 'Stack Trace: ' + ' <br/>' + stackTraceString
            
        );
        
        if (!Test.isRunningTest()) {
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }
        
    }
    //END CODE FIX FOR JIRA DEFECT: SDDD-2443
    
    
    @TestVisible
    private static void setErrorResponse(String errorMsg) {
        errors err = new errors();
        err.statusCode ='500';
        err.Message = errorMsg;
        List<errors> errors = new List<errors>{err};        
            
            String serializedjson = JSON.serialize(errors);
        if(res != null) {
            
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(serializedjson);
            System.debug('responsejson--'+res);            
            
        }
        
    }
    
    public class response {
        public String id;
        public Boolean success;
        public List<errors> errors;
        
    }
    public class errors{
        public String statusCode;
        public String  Message;
    }    
    
    
}