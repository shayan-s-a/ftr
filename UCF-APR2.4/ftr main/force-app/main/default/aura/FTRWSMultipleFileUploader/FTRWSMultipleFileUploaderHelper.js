({
    MAX_FILE_SIZE: 750000, //Max file size 750kb 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadHelper: function(component, event) {
        // start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadInChunk(component, file, fileContents);
        });
        
        objFileReader.readAsText(file);
    },
    
    
    uploadInChunk: function(component, file, fileContents) {
        var action = component.get("c.saveFile");
        console.log('@@oppId'+component.get("v.oppId"));
        console.log('@@fileContents@@'+fileContents);
        console.log('@@fileContents'+JSON.stringify(fileContents));
        action.setParams({
            base64Data: JSON.stringify(fileContents),
            oppId : component.get("v.oppId") ,
        });
        
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                console.log('your File is uploaded successfully');
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "message": "We are running Address validations, It may take some time to process. Please check back after a while"
                    });
                    toastEvent.fire();
                component.set("v.showLoadingSpinner", false);
                console.log('After FIle upload'+response.getReturnValue());                
                component.set('v.data', response.getReturnValue());
                component.set("v.showTable", true);
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    
    validateInDPI: function(component, event, helper) {
        console.log('clicked Validate in DPI button');
         var recordId = component.get("v.addressId");
        var adruploadTable;
        var action = null;
        var street = component.get("v.streetNo") + ' ' + component.get("v.streetName");
        var city = component.get("v.city");
        var state = component.get("v.state");
        var zip = component.get("v.zip");
        console.log('Passing Street::city:state:zip' + street + ':' + city + ':' + state + ':' + zip );
        
        if(recordId != null) {
            console.log('calling getDPIValResultWithAddressId to get the DPI address validation results:' + recordId);
            action = component.get("c.ValidateDPIWithID");
            action.setParams({
                "addressId" : recordId
            })
        }
        else {
            console.log('calling getDPIValidationResults with address params to get the DPI address validation results');
            /*action = component.get("c.getDPIValidationResults");
        	action.setParams({
            	"street": street,
            	"city": city,
            	"state": state,
            	"zip":zip
        	});*/
        }
        component.set("v.Spinner", true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('33333 DPI validation response results:'+response);
            
            
            if (state === "SUCCESS") {
                console.log("DPI validation response results: " + response.getReturnValue());
                var addrList = response.getReturnValue();
                if(addrList != null && addrList.length>1) {
                    component.set("v.dpiData", addrList);
                    var toastEvent = $A.get("e.force:showToast");                    
                    adruploadTable = component.get("v.data"); 
                    for(var i=0;i< adruploadTable.length;i++){
                        if(adruploadTable[i].Id == recordId){
                            adruploadTable[i].Comments__c = 'Multiple addresses found, please navigate to the Individual record to validate';
                        }
                    }
                    
                    component.set("v.data",adruploadTable);
                   component.set("v.Spinner", false);
                    toastEvent.setParams({
                        "type": "warning",
                        "message": "Multiple addresses found, please navigate to the Individual record to validate"
                    });
                    toastEvent.fire();
                }
                else if(addrList != null && addrList.length==1){
                    component.set("v.DPISingleAddress",addrList[0]);
                    component.set("v.isDPIValidated", true);
                    this.saveAddressQualification(component, event, helper, "DPI");
                }
                    else {
                        
                        console.log('Not a valid DPI Address:'+response);
                        component.set("v.DPISingleAddress", null);                        
                        component.set("v.isDPIValidated", false);
                        component.set("v.isDPIValFailed", true);
                        component.set("v.Spinner", false);
                    }
                
            } else {
                console.log('Error occured in DPI validation response results:'+response);
                component.set("v.DPISingleAddress", null);component.set("v.isDPIValidated", false);
                component.set("v.isDPIValFailed", true);
                component.set("v.Spinner", false);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    validateInDSAT: function(component, event, helper) {
        console.log('clicked Validate in DSAT button');
                       
        var recordId = component.get("v.addressId");
        var adruploadTable;
        var action = null;
        var street = component.get("v.streetNo") + ' ' + component.get("v.streetName");
        var city = component.get("v.city");
        var state = component.get("v.state");
        var zip = component.get("v.zip");
        console.log('Passing Street::city:state:zip' + street + ':' + city + ':' + state + ':' + zip );
        component.set("v.Spinner", true);
        if(recordId != null) {
            console.log('calling getDSATValResultWithAddressId to get the DPI address validation results:' + recordId);
            action = component.get("c.ValidateDSATWithID");
            action.setParams({
                "addressId" : recordId
            })
        }
        else {
            console.log('calling getDSATValidationResults with address params to get the DSAT address validation results');
            /*action = component.get("c.getDPIValidationResults");
        	action.setParams({
            	"street": street,
            	"city": city,
            	"state": state,
            	"zip":zip
        	});*/
        }
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('33333 DSAT validation response results:'+response);
            
            
            if (state === "SUCCESS") {
                console.log("DSAT validation response results: " + response.getReturnValue());
                var addr = response.getReturnValue();
                if(addr != null){
                    component.set("v.DSATSingleAddress",addr);
                    component.set("v.isDSATValidated", true);
                    this.saveAddressQualification(component, event, helper, "DSAT");
                }
                    else {
                        
                        console.log('Not a valid DSAT Address:'+response);
                        component.set("v.DSATSingleAddress", null);
                        //component.set("v.backupDPIdata", null);
                        component.set("v.isDSATValidated", false);
                        component.set("v.isDSATValFailed", true);
                        component.set("v.Spinner", false);
                    }
                
            } else {
                console.log('Error occured in DSAT validation response results:'+response);
                component.set("v.DSATSingleAddress", null);
                //component.set("v.backupDPIdata", null);
                component.set("v.isDSATValidated", false);
                component.set("v.isDSATValFailed", true);
                component.set("v.Spinner", false);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    saveAddressQualification: function(component, event, helper, qualType) {        
        
        var adruploadTable;
        var addressId = component.get("v.addressId");
        var actionStr = "";
        var dpiData = null;
        var dsatData = null;
        if(qualType == "DPI") {
            actionStr = "UPDATE_DPI";
            dpiData = component.get("v.DPISingleAddress");
        } else {
            actionStr = "UPDATE_DSAT";
            dsatData = component.get("v.DSATSingleAddress");;
        }
        
        
        console.log('FTRWSAddress record id is while saving dpi data' + addressId);
        var action = component.get("c.saveAddress");
        
        //String streetNo, String streetName, String unitNo, String city, String state, String zipcode, String opportunityId
        action.setParams({
            "addressId": addressId,
            "actionStr" : actionStr,
            "dpiData": dpiData,
            "dsatData" : dsatData
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('**state**');
            console.log(state);
            if (state === "SUCCESS") {
                
                
                var toastEvent = $A.get("e.force:showToast");
                var address = response.getReturnValue();
                if (address != null) {
                    //addressId
                    component.set("v.addressId", address.Id);
                    adruploadTable = component.get("v.data"); 
                    for(var i=0;i< adruploadTable.length;i++){
                        if(adruploadTable[i].Id == address.Id && qualType == "DPI"){
                            adruploadTable[i].DPI_Validated__c = address.DPI_Validated__c;
                            
                        }
                        if(adruploadTable[i].Id == address.Id && qualType == "DSAT"){
                            
                            adruploadTable[i].DSAT_Validated__c = address.DSAT_Validated__c;
                        }
                    }
                    component.set("v.data",adruploadTable);
                    component.set("v.Spinner", false);
                    
                    toastEvent.setParams({
                        "type": "success",
                        "message": qualType + " data has been updated to the Address Sucessfully"
                    });
                    toastEvent.fire();
                    
                } else {
                    component.set("v.Spinner", false);
                    toastEvent.setParams({
                        "type": "error",
                        "message": "Failed to save "+ qualType + "data to the Address"
                    });
                    toastEvent.fire();
                }
                
            } else {
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    
})