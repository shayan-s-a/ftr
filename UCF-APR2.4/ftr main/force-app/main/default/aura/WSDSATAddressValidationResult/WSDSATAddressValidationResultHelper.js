({
	validateInDSAT : function(component, event, helper) {
        var recordId =  component.get("v.recordId");
        console.log('FTRWSAddress record id is ' + recordId);
        if(recordId == null) {
            recordId = component.get("v.addressId");
        }
        var action = null;
        var street = component.get("v.streetNo") + ' ' + component.get("v.streetName");
        var city = component.get("v.city");
        var state = component.get("v.state");
        var zip = component.get("v.zip");
        var latitudeInp = component.get("v.latitudeInp");
        var longitudeInp = component.get("v.longitudeInp");
        console.log('Passing Street::city:state:zip:latitudeInp:longitudeInp:' + street + ':' + city + ':' + state + ':' + zip+':'+latitudeInp+':'+ longitudeInp);
        
        if(recordId != null) {
            console.log('calling getDSATValResultWithAddressId to get the DSAT address validation results:' + recordId);
            action = component.get("c.getDSATValResultWithAddressId");
            action.setParams({
                "addressId" : recordId
            })
        }
        else {
            console.log('calling getDSATValidationResults with address params to get the DSAT address validation results');
            action = component.get("c.getDSATValidationResults");
        	action.setParams({
            	"street": street,
            	"city": city,
            	"state": state,
            	"zip":zip,
                "latitudeInp":latitudeInp,
                "longitudeInp":longitudeInp
        	});
        }
		//getDSATDummyResponse
	
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('DSAT validation response results:'+response);
            
            if (state === "SUCCESS" && response.getReturnValue() != null) {
                console.log("***Success DSAT validation response results: " + response.getReturnValue());
                var dsatResponse = response.getReturnValue();
                component.set("v.dsatRespData", dsatResponse);
                component.set("v.showDSATResults", true);
                helper.setDSATData(component, event, helper);
                console.log("***Success DSAT inFootprint: " + dsatResponse.inFootprint);
            } else {
                console.log('Error occured in DSAT validation response results:'+response);
                component.set("v.dsatRespData", null);
                component.set("v.showDSATResults", false);
                component.set("v.isDSATValFailed", true);
                helper.goToDPIHelper(component,event,helper);
            }

        });

        $A.enqueueAction(action);
    },
    
    setDSATData : function(component, event, helper) {
        
        var dsatRespData = component.get("v.dsatRespData");
        component.set("v.businessName", dsatRespData.businessName);
        component.set("v.dsatId", dsatRespData.dsatId);
        component.set("v.vfoRecordId", dsatRespData.vfoRecordId);
        component.set("v.m6OrderNumber", dsatRespData.m6OrderNumber);
        component.set("v.createdBy", dsatRespData.createdBy);
        component.set("v.creatorEmail", dsatRespData.creatorEmail);
        component.set("v.createdById", dsatRespData.createdById);
        component.set("v.opened", dsatRespData.opened);
        component.set("v.inFootprint", dsatRespData.inFootprint);
        component.set("v.market", dsatRespData.market);
        component.set("v.products", dsatRespData.products);
        component.set("v.wireCenterCLLI", dsatRespData.wireCenterCLLI);
        component.set("v.siteName", dsatRespData.siteName);
        component.set("v.wireCenterQoS", dsatRespData.wireCenterQoS);
        component.set("v.wireCenterSpeed", dsatRespData.wireCenterSpeed);
        component.set("v.litBuilding", dsatRespData.litBuilding);
        component.set("v.fiberDistance", dsatRespData.fiberDistance);
        component.set("v.copperDistance", dsatRespData.copperDistance);
        
        component.set("v.copperDistance", dsatRespData.copperDistance);
        component.set("v.fiberTier", dsatRespData.fiberTier);
        component.set("v.copperTier", dsatRespData.copperTier);
        component.set("v.latitude", dsatRespData.latitude);
        component.set("v.longitude", dsatRespData.longitude);
        
        component.set("v.fiberQualification", dsatRespData.fiberQualification);
        component.set("v.copperQualification", dsatRespData.copperQualification);
        helper.goToDPIHelper(component,event,helper);
    },
    goToDPIHelper : function(component,event,helper) {
        console.log(
          "Firing DPI saved event, enable the Next button to go to the DSAT screen"
        );
        var appEvent = $A.get("e.c:WSDPISaved"); //component.getEvent("WSDPISaved");
        //appEvent.setParams({"addressId" :  address.Id});
        //appEvent.setParams({"oppId" :  address.Opportunity_ID__c});
        appEvent.fire();
    } ,
    
    saveDSATAddressQualification: function(component, event, helper, row, qualType) {
         
         
        var recordId = component.get("v.addressId");
        console.log('Saving '+ qualType +' data for the Address with addressId ' + recordId);
         if(recordId == null) {
             recordId = component.get("v.recordId");
         }
         
         
         
        var addressId = recordId;
         var actionStr = "UPDATE_DSAT";
         var dpiData = null;
        
         console.log('FTRWSAddress record id is while saving dpi data' + addressId);
        var action = component.get("c.get_UpdateAddress");
         
        //String streetNo, String streetName, String unitNo, String city, String state, String zipcode, String opportunityId
        action.setParams({
			"addressId": addressId,
            "actionStr" : actionStr,
            "dpiData": dpiData,
            "dsatData" : row
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('**state**');
            console.log(state);
            if (state === "SUCCESS") {
                component.set("v.showDSATResults", true);
                
                var toastEvent = $A.get("e.force:showToast");
                var address = response.getReturnValue();
                if (address != null) {
                    //addressId
                    component.set("v.addressId", address.addressId);

                    toastEvent.setParams({
                        "type": "success",
                        "message": qualType + " data has been updated to the Address Sucessfully"
                    });
                    toastEvent.fire();
                } else {
                    toastEvent.setParams({
                        "type": "error",
                        "message": "Failed to save "+ qualType + "data to the Address"
                    });
                    toastEvent.fire();
                }
                
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();

            } else {

            }
        });
        $A.enqueueAction(action);
    }
    

})