public with sharing class FTRWSDSATAddressController {
    
    class FTRWSDSATAddressControllerException extends Exception {}
    
    public static String getBearer(){ 
        String Bearer;
        DSAT_Configuration__mdt i = DSAT_Configuration__mdt.getInstance('DSAT_Bearer');
        System.debug('ApiKey_Header__c'+i.ApiKey_Header__c);
        System.debug('Endpoint__c'+i.Endpoint__c);
        DSAT_Configuration__mdt dsatConfig =[Select id,Bearer__c,SandBox__c,Production__c from DSAT_Configuration__mdt where DeveloperName=:'DSAT_Bearer'];
        //Sanbox Bearer
        if(i.SandBox__c)
        Bearer = dsatConfig.Bearer__c;
       // Bearer = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJDcmVhdGVkIjoiMjAxOS0xMC0zMFQxNDozMTozMS41NzQ1MDUyLTA0OjAwIiwiTmlja25hbWUiOiIsIFZGTyBBcHBsaWNhdGlvbiIsIkZpcnN0TmFtZSI6IlZGTyBBcHBsaWNhdGlvbiIsIkxhc3ROYW1lIjoiIiwiRW1haWxBZGRyZXNzIjoic3RhZ2VAc2lmdC50ZXN0IiwiTGFuSWQiOiJhcHA6IHZmbyBhcHBsaWNhdGlvbiIsIkdyb3VwSWRzIjpbMTcsMjNdLCJHcm91cE5hbWVzIjpbIkFwcGxpY2F0aW9ucyIsIlZGTyBBcHBsaWNhdGlvbiJdLCJSaWdodHMiOlszM10sIklkIjoyODM3NCwiVG9rZW5JZCI6MjQ2ODJ9.IccF4Ohx7Y67zoK7UO0izvX_Zkcrlpej6wCMR9RdA0U';
         //Production Bearer token
        if(i.Production__c)
        Bearer = dsatConfig.Bearer__c;
       // Bearer = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJDcmVhdGVkIjoiMjAxOS0xMC0zMFQxNDozMTozMS41NzQ1MDUyLTA0OjAwIiwiTmlja25hbWUiOiIsIFZGTyBBcHBsaWNhdGlvbiIsIkZpcnN0TmFtZSI6IlZGTyBBcHBsaWNhdGlvbiIsIkxhc3ROYW1lIjoiIiwiRW1haWxBZGRyZXNzIjoic3RhZ2VAc2lmdC50ZXN0IiwiTGFuSWQiOiJhcHA6IHZmbyBhcHBsaWNhdGlvbiIsIkdyb3VwSWRzIjpbMTcsMjNdLCJHcm91cE5hbWVzIjpbIkFwcGxpY2F0aW9ucyIsIlZGTyBBcHBsaWNhdGlvbiJdLCJSaWdodHMiOlszM10sIklkIjoyODM3NCwiVG9rZW5JZCI6MjQ2ODJ9.IccF4Ohx7Y67zoK7UO0izvX_Zkcrlpej6wCMR9RdA0U';
        
        HttpRequest req = new HttpRequest();
        req.setEndPoint(i.Endpoint__c);
        req.setMethod('GET');
        req.setTimeout(2 * 60 * 1000); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('apikey', i.ApiKey_Header__c);
        req.setHeader('SIFT-Token', Bearer);
        Http httpCls = new Http();
        HttpResponse response = httpCls.send(req);
        if(response.getStatusCode() == 200){            
            String token = response.getBody().replace('"','');              
            return token;
        }
        else{
            System.debug('@failed StatusCode'+response.getStatusCode());
            System.debug('@failed StatusCode'+response.getStatus());
            return null;
        }
        
    }
    
    public static FTRWSDSATAddressResponse getDSATAddress(ftr_addressBeanDSAT quAdr){
        
        DSAT_Configuration__mdt i = DSAT_Configuration__mdt.getInstance('DSAT_Validation');
        HttpRequest req = new HttpRequest();
        req.setEndPoint(i.Endpoint__c);
        req.setMethod('POST');
        req.setTimeout(2 * 60 * 1000); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('apikey', i.ApiKey_Header__c);
        String token = getBearer();
        req.setHeader('SIFT-Token', 'Bearer '+token); 
        //latlong only
        ftr_addressBeanDSAT latlong= new ftr_addressBeanDSAT();
        latlong.Latitude=quAdr.Latitude;
        latlong.Longitude=quAdr.Longitude;
        latlong.Address='';
        latlong.City='';
        latlong.State='';
        latlong.ZipCode='';
        String bodyLatLong= JSON.serialize(latlong);
        //lat long only
        String body= JSON.serialize(quAdr);
       // System.debug('@@@JSON Body'+body);
        req.setBody('{"QualifiedAddress":'+body+'}');
        Http httpCls = new Http();
        HttpResponse response = httpCls.send(req);
         if(response.getStatusCode() == 200){
            FTRWSDSATAddressResponse ftRespDsat= setRespData(response);
            return ftRespDsat;
        }
        else if(response.getStatusCode() == 500){
            req.setBody('{"QualifiedAddress":'+bodyLatLong+'}');
            Http httpClsLatLong = new Http();
            HttpResponse responseLatLong = httpClsLatLong.send(req);
            if(responseLatLong.getStatusCode() == 200){
                FTRWSDSATAddressResponse ftRespDsat= setRespData(responseLatLong);
                return ftRespDsat; 
            }
        else{
            System.debug('@failed StatusCode'+response.getStatusCode());
            System.debug('@failed StatusCode'+response.getStatus());
            return null;
       }
    }       
         else{
            System.debug('@failed StatusCode'+response.getStatusCode());
            System.debug('@failed StatusCode'+response.getStatus());
            return null;
        }
}
    
    //This is to get DSAT response using DSATID
    public static FTRWSDSATAddressResponse getDSATAddressWithDSATID(String DSATID){
        DSAT_Configuration__mdt i = DSAT_Configuration__mdt.getInstance('DSAT_Validation');
            HttpRequest req = new HttpRequest();
        req.setEndPoint(i.Endpoint__c+'/'+DSATID);
        req.setMethod('GET');
        req.setTimeout(2 * 60 * 1000); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('apikey', i.ApiKey_Header__c);
        String token = getBearer();
        req.setHeader('SIFT-Token', 'Bearer '+token); 
        Http httpCls = new Http();
        HttpResponse response = httpCls.send(req);
         if(response.getStatusCode() == 200){
            FTRWSDSATAddressResponse ftRespDsat= setRespData(response);
            return ftRespDsat;
        }
        else{
            return null;
        }
    }
    public Static FTRWSDSATAddressResponse setRespData(HttpResponse response){
        
        system.debug('## Successfully retrieving DSAT_Addressn'); 
        system.debug('response.getBody() ==> ' + response.getBody());
       // System.debug('@@Deserialised_Body'+(FTRWSDSATAddressResponseJson) System.JSON.deserialize(response.getBody(), FTRWSDSATAddressResponseJson.class));
        FTRWSDSATAddressResponseJsonNew respoJsn = (FTRWSDSATAddressResponseJsonNew) System.JSON.deserialize(response.getBody(), FTRWSDSATAddressResponseJsonNew.class);
        FTRWSDSATAddressResponse ftRespDsat = new FTRWSDSATAddressResponse();
        ftRespDsat.dsatId= respoJsn.Id!=null?String.valueOf(respoJsn.Id):'';
        ftRespDsat.products = respoJsn.Products!=null?String.valueOf(respoJsn.Products):'';
        ftRespDsat.market=respoJsn.Market!=null?respoJsn.Market:'';
        ftRespDsat.level=respoJsn.Level!=null?respoJsn.Level:'';
        ftRespDsat.wireCenterQoS=respoJsn.WireCenterQoS!=null?respoJsn.WireCenterQoS:'';
        ftRespDsat.wireCenterCLLI=respoJsn.WireCenterCLLI!=null?respoJsn.WireCenterCLLI:'';
        // ftRespDsat.dastmaxspeed='';
        ftRespDsat.latitude=respoJsn.QualifiedAddress!=null && respoJsn.QualifiedAddress.Latitude!=null?String.valueOf(respoJsn.QualifiedAddress.Latitude):'';
        ftRespDsat.longitude=respoJsn.QualifiedAddress!=null && respoJsn.QualifiedAddress.Longitude!=null?String.valueOf(respoJsn.QualifiedAddress.Longitude):'';
        //ftRespDsat.dsatservice='';
        ftRespDsat.opened=respoJsn.Opened!=null?respoJsn.Opened:'';
        ftRespDsat.createdBy=respoJsn.CreatedBy!=null?respoJsn.CreatedBy:'';
        ftRespDsat.creatorEmail=respoJsn.CreatorEmail!=null?respoJsn.CreatorEmail:'';
        ftRespDsat.createdById=respoJsn.CreatedById!=null?String.valueOf(respoJsn.CreatedById):'';
        ftRespDsat.fiberQualification=respoJsn.FiberQualification!=null?respoJsn.FiberQualification:'';
        ftRespDsat.fiberDistance=respoJsn.FiberDistance!=null?respoJsn.FiberDistance:'';
        ftRespDsat.copperQualification=respoJsn.CopperQualification!=null?respoJsn.CopperQualification:'';
        ftRespDsat.copperDistance=respoJsn.CopperDistance!=null?respoJsn.CopperDistance:'';
        ftRespDsat.copperTier=respoJsn.CopperTier!=null?respoJsn.CopperTier:'';
        ftRespDsat.fiberTier=respoJsn.FiberTier!=null?respoJsn.FiberTier:'';
        ftRespDsat.vfoRecordId=respoJsn.VFORecordId!=null?String.valueOf(respoJsn.VFORecordId):'';
        ftRespDsat.m6OrderNumber=respoJsn.M6OrderNumber!=null?String.valueOf(respoJsn.M6OrderNumber):'';
        //ftRespDsat.dsatcreatedby='';
        ftRespDsat.siteName=respoJsn.SiteName!=null?respoJsn.SiteName:'';
        ftRespDsat.businessName= respoJsn.BusinessName==null ?'':respoJsn.BusinessName;
        //respoJsn.BusinessName==null ?'':respoJsn.BusinessName;
        ftRespDsat.litBuilding= respoJsn.LitBuilding==null ? False:respoJsn.LitBuilding;
        ftRespDsat.inFootprint=respoJsn.InFootprint==null ? False:respoJsn.InFootprint;
        ftRespDsat.wireCenterSpeed=respoJsn.WireCenterSpeed!=null?respoJsn.WireCenterSpeed:'' ;
        String DSATMaxSpeed = respoJsn.WireCenterSpeed!=null?respoJsn.WireCenterSpeed:'';
        
         // Changes for BSA - Start
        ftRespDsat.LinkStatus= respoJsn.LinkStatus!=null?respoJsn.LinkStatus:'';
        //ftRespDsat.LengthFeet= respoJsn.LengthFeet!=null?respoJsn.LengthFeet:'';
        ftRespDsat.FiberCost= respoJsn.FiberCost!=null?respoJsn.FiberCost:0.0;
        ftRespDsat.EquipmentCost= respoJsn.EquipmentCost!=null?respoJsn.EquipmentCost:0.0;
        ftRespDsat.TotalCost= respoJsn.TotalCost!=null?respoJsn.TotalCost:0.0;
        //adding missing
        ftRespDsat.City= respoJsn.QualifiedAddress!=null && respoJsn.QualifiedAddress.City!=null?String.valueOf(respoJsn.QualifiedAddress.City):'';
		ftRespDsat.State= respoJsn.QualifiedAddress!=null && respoJsn.QualifiedAddress.State!=null?String.valueOf(respoJsn.QualifiedAddress.State):'';
        ftRespDsat.ZipCode= respoJsn.QualifiedAddress!=null && respoJsn.QualifiedAddress.ZipCode!=null?String.valueOf(respoJsn.QualifiedAddress.ZipCode):'';
        ftRespDsat.Address = respoJsn.QualifiedAddress!=null && respoJsn.QualifiedAddress.Address!=null?String.valueOf(respoJsn.QualifiedAddress.Address):'';
        // Changes for BSA - End
        
   
        /* Integer DSATMaxSpeedN= Integer.valueof(DSATMaxSpeed.removeEnd('G'));
if(DSATMaxSpeedN>2){
ftRespDsat.HBE_Legacy = 'HBE';// change to hbe  
}
else if(DSATMaxSpeedN<2){
ftRespDsat.HBE_Legacy = 'HBE Eligible';
}
else{
ftRespDsat.HBE_Legacy = 'Legacy';
} */
        
        String hbeEligible = '';
        String hbeSwcClli = '';
        String dsatClli6 = ftRespDsat.wireCenterCLLI!=null && (ftRespDsat.wireCenterCLLI).length()>6 ? ftRespDsat.wireCenterCLLI.substring(0,6):'';
        FTRHBECLLI__mdt HBEClliList = [Select HBECLLI__c FROM FTRHBECLLI__mdt WHERE developerName = 'CLLI'];
        
        if (HBEClliList.HBECLLI__c.split(',').contains(dsatClli6)) {
            hbeEligible = 'HBE';
            hbeSwcClli = respoJsn.wireCenterCLLI!=null?ftRespDsat.wireCenterCLLI:'';
        }
        else if(HBEClliList.HBECLLI__c.contains(dsatClli6)){
            hbeEligible ='HBE Eligible';
            for (String matchingClli : HBEClliList.HBECLLI__c.split(',')){
                if (matchingClli.contains(dsatClli6)){
                    hbeSwcClli = matchingClli;
                    break;
                }
            }
            //hbeSwcClli = ftRespDsat.wireCenterCLLI;
        }
        else{
            hbeEligible = 'Legacy';
        } 
        ftRespDsat.HBE_Legacy = hbeEligible;
        ftRespDsat.Nearby_HBE_SWC_CLLI = hbeSwcClli;
        /* CML-1958 START*/
ftRespDsat.FutureHBEWcSpeed = respoJsn.FutureHBEWcSpeed!=null?String.valueOf(respoJsn.FutureHBEWcSpeed):'';
        ftRespDsat.PlannedHBETimeframe = respoJsn.PlannedHBETimeframe!=null?String.valueOf(respoJsn.PlannedHBETimeframe):'';
        ftRespDsat.WirecenterClliCode = respoJsn.BSADetails!=null && respoJsn.BSADetails.WirecenterClliCode!=null?String.valueOf(respoJsn.BSADetails.WirecenterClliCode):'';
        ftRespDsat.PlanId = respoJsn.BSADetails!=null && respoJsn.BSADetails.PlanId!=null?String.valueOf(respoJsn.BSADetails.PlanId):'';
        ftRespDsat.TotalNewFiberFt = respoJsn.BSADetails!=null && respoJsn.BSADetails.TotalNewFiberFt!=null?respoJsn.BSADetails.TotalNewFiberFt:ftRespDsat.TotalNewFiberFt;
        ftRespDsat.CoToSiteFt = respoJsn.BSADetails!=null && respoJsn.BSADetails.CoToSiteFt!=null?respoJsn.BSADetails.CoToSiteFt:ftRespDsat.CoToSiteFt;
        ftRespDsat.TotalFiberCost = respoJsn.BSADetails!=null && respoJsn.BSADetails.TotalFiberCost!=null?respoJsn.BSADetails.TotalFiberCost:ftRespDsat.TotalFiberCost;
        ftRespDsat.SpliceCount = respoJsn.BSADetails!=null && respoJsn.BSADetails.SpliceCount!=null?respoJsn.BSADetails.SpliceCount:ftRespDsat.SpliceCount;
        ftRespDsat.SplicingCost = respoJsn.BSADetails!=null && respoJsn.BSADetails.SplicingCost!=null?respoJsn.BSADetails.SplicingCost:ftRespDsat.SplicingCost;
        ftRespDsat.BbCostLtEt1gb = respoJsn.BSADetails!=null && respoJsn.BSADetails.BbCostLtEt1gb!=null?respoJsn.BSADetails.BbCostLtEt1gb:ftRespDsat.BbCostLtEt1gb;
        ftRespDsat.BbCostGt1gbLtEt10gb = respoJsn.BSADetails!=null && respoJsn.BSADetails.BbCostGt1gbLtEt10gb!=null?respoJsn.BSADetails.BbCostGt1gbLtEt10gb:ftRespDsat.BbCostGt1gbLtEt10gb;
        ftRespDsat.BbCostGt10gb = respoJsn.BSADetails!=null && respoJsn.BSADetails.BbCostGt10gb!=null?respoJsn.BSADetails.BbCostGt10gb:ftRespDsat.BbCostGt10gb;
        ftRespDsat.TrCostLtEt1gb = respoJsn.BSADetails!=null && respoJsn.BSADetails.TrCostLtEt1gb!=null?respoJsn.BSADetails.TrCostLtEt1gb:ftRespDsat.TrCostLtEt1gb;
        ftRespDsat.TrCostGt10gb = respoJsn.BSADetails!=null && respoJsn.BSADetails.TrCostGt10gb!=null?respoJsn.BSADetails.TrCostGt10gb:ftRespDsat.TrCostGt10gb;
        ftRespDsat.BbCostLtEt1gb = respoJsn.BSADetails!=null && respoJsn.BSADetails.BbCostLtEt1gb!=null?respoJsn.BSADetails.BbCostLtEt1gb:ftRespDsat.BbCostLtEt1gb;
        ftRespDsat.Servable = respoJsn.BSADetails!=null && respoJsn.BSADetails.Servable!=null?String.valueOf(respoJsn.BSADetails.Servable):'';
        ftRespDsat.ReviewStatus = respoJsn.BSADetails!=null && respoJsn.BSADetails.ReviewStatus!=null?String.valueOf(respoJsn.BSADetails.ReviewStatus):'';
        ftRespDsat.ReviewReason = respoJsn.BSADetails!=null && respoJsn.BSADetails.ReviewReason!=null?String.valueOf(respoJsn.BSADetails.ReviewReason):'';
        ftRespDsat.RouteNotes = respoJsn.BSADetails!=null && respoJsn.BSADetails.RouteNotes!=null?String.valueOf(respoJsn.BSADetails.RouteNotes):'';
        ftRespDsat.BSAHttpStatusCode = respoJsn.BSADetails!=null && respoJsn.BSADetails.BSAHttpStatusCode!=null?respoJsn.BSADetails.BSAHttpStatusCode:ftRespDsat.BSAHttpStatusCode;
        ftRespDsat.GuardRailCost = respoJsn.BSADetails!=null && respoJsn.BSADetails.GuardrailCost!=null?respoJsn.BSADetails.GuardrailCost:ftRespDsat.GuardRailCost;
        ftRespDsat.HBEMaxSpeed = respoJsn.HBEDetails!=null && respoJsn.HBEDetails.HBEMaxSpeed!=null?respoJsn.HBEDetails.HBEMaxSpeed:ftRespDsat.HBEMaxSpeed;
        ftRespDsat.HBEMaxQoS = respoJsn.HBEDetails!=null && respoJsn.HBEDetails.HBEMaxQoS!=null?respoJsn.HBEDetails.HBEMaxQoS:ftRespDsat.HBEMaxQoS;
        ftRespDsat.HBEProducts = respoJsn.HBEDetails!=null && (respoJsn.HBEDetails.Products!=null && !respoJsn.HBEDetails.Products.isEmpty())?respoJsn.HBEDetails.Products:new List<String>();
        /* CML-1958 END*/
        
        
        return ftRespDsat;
        
    }
}