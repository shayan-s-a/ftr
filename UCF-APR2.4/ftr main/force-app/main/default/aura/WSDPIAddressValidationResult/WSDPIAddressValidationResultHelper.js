({
  Old_validateInDPI: function(component, event, helper) {
    console.log("clicked Validate in DPI button");

    helper.resetDPIFlags(component, event, helper);
    var recordId = component.get("v.recordId");
    console.log("FTRWSAddress record id is " + recordId);
    if (recordId == null) {
      recordId = component.get("v.addressId");
    }
    var action = null;
    var street =
      component.get("v.streetNo") + " " + component.get("v.streetName");
    var city = component.get("v.city");
    var state = component.get("v.state");
    var zip = component.get("v.zip");
    console.log(
      "Passing Street::city:state:zip" +
        street +
        ":" +
        city +
        ":" +
        state +
        ":" +
        zip
    );

    if (recordId != null) {
      console.log(
        "calling getDPIValResultWithAddressId to get the DPI address validation results:" +
          recordId
      );
      action = component.get("c.getDPIValResultWithAddressId");
      action.setParams({
        addressId: recordId
      });
    } else {
      console.log(
        "calling getDPIValidationResults with address params to get the DPI address validation results"
      );
      action = component.get("c.getDPIValidationResults");
      action.setParams({
        street: street,
        city: city,
        state: state,
        zip: zip
      });
    }

    action.setCallback(this, function(response) {
      var state = response.getState();
      console.log("33333 DPI validation response results:" + response);
	
   
      if (state === "SUCCESS") {
        console.log(
          "DPI validation response results: " + response.getReturnValue()
        );
        var addrList = response.getReturnValue();
        if (addrList != null && addrList.length > 0) {
          if (addrList.length == 1) {
            var addrValResult = addrList[0];
            if (addrValResult.status == "FAILURE") {
              console.log("Not a valid DPI Address:" + response);
              component.set("v.dpiData", null);
              component.set("v.backupDPIdata", null);
              component.set("v.isDPIValidated", false);
              component.set("v.isDPIValFailed", true);
            } else {
              component.set("v.dpiData", addrList);
              component.set("v.backupDPIdata", addrList);
              component.set("v.isDPIValidated", true);
              component.set("v.isDPIValFailed", false);  
            }
          } else {
            component.set("v.dpiData", addrList);
            component.set("v.backupDPIdata", addrList);
            component.set("v.isDPIValidated", true);
            component.set("v.isDPIValFailed", false);
          }
        } else {
          console.log("FAILURE OCCURRED: Not a valid DPI Address:" + response);
          component.set("v.dpiData", null);
          component.set("v.backupDPIdata", null);
          component.set("v.isDPIValidated", false);
          component.set("v.isDPIValFailed", true);
        }
      } else {
        console.log(
          "Error occured in DPI validation response results:" + response
        );
        component.set("v.dpiData", null);
        component.set("v.backupDPIdata", null);
        component.set("v.isDPIValidated", false);
        component.set("v.isDPIValFailed", true);
      }
    
    });

    $A.enqueueAction(action);
  },

  saveDPIAddressQualification: function(
    component,
    event,
    helper,
    row,
    qualType
  ) {
    var recordId = component.get("v.recordId");
    if (recordId == null) {
      recordId = component.get("v.addressId");
    }

    console.log(
      "Saving " + qualType + " data for the Address with addressId " + recordId
    );

    var addressId = recordId;
    var actionStr = "";
    var dpiData = null;
    var dsatData = null;
    if (qualType == "DPI") {
      actionStr = "UPDATE_DPI_SERVICE";
      dpiData = row;
    } else {
      actionStr = "UPDATE_DSAT";
      dsatData = row;
    }

    console.log("FTRWSAddress record id is while saving dpi data" + addressId);
    var action = component.get("c.get_UpdateAddress");

    //String streetNo, String streetName, String unitNo, String city, String state, String zipcode, String opportunityId
    action.setParams({
      addressId: addressId,
      actionStr: actionStr,
      dpiData: dpiData,
      dsatData: dsatData
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      console.log("**state**");
      console.log(state);
      if (state === "SUCCESS") {
        //helper.fireWSDPISavedEvent(component, event, helper);
        component.set("v.isDPIValidated", false);
		    component.set("v.dpiAddressUpdated", true);
        var toastEvent = $A.get("e.force:showToast");
        var address = response.getReturnValue();
        if (address != null) {
          //addressId
          component.set("v.addressId", address.Id);
          component.set("v.dpiAddressUpdatedRec", address);
          if (qualType == "DPI") {
            component.set("v.disableSaveDPIBTN", true);
          }
          toastEvent.setParams({
            type: "success",
            message:
              qualType + " data has been updated to the Address Sucessfully"
          });
          toastEvent.fire();
        } else {
          toastEvent.setParams({
            type: "error",
            message: "Failed to save " + qualType + "data to the Address"
          });
          toastEvent.fire();
        }
      } else {
      }
    });
    $A.enqueueAction(action);
  },

  resetDPIFlags: function(component, event, helper) {
    component.set("v.dpiData", null);
    component.set("v.isDPIValidated", false);
  },

  resetFormData: function(component, event, helper) {
    helper.resetDPIFlags(component, event, helper);
  },

  fireWSDPISavedEvent: function(component, event, helper) {
    //WSDPISaved
    console.log(
      "Firing DPI saved event, enable the Next button to go to the DSAT screen"
    );
    var appEvent = $A.get("e.c:WSDPISaved"); //component.getEvent("WSDPISaved");
    //appEvent.setParams({"addressId" :  address.Id});
    //appEvent.setParams({"oppId" :  address.Opportunity_ID__c});
    appEvent.fire();
  },

  //**********Common validation for both dsat and DPI with the new design
  validateInDPI: function(component, event, helper) {
      
    component.set("v.Spinner", true);   
    console.log("clicked Validate in DPI button");

    helper.resetDPIFlags(component, event, helper);
    var recordId = component.get("v.recordId");
    console.log("FTRWSAddress record id is " + recordId);
    if (recordId == null) {
      recordId = component.get("v.addressId");
    }
    var action = null;
    var street =
      component.get("v.streetNo") + " " + component.get("v.streetName");
    var city = component.get("v.city");
    var state = component.get("v.state");
    var zip = component.get("v.zip");
    console.log(
      "Passing Street::city:state:zip" +
        street +
        ":" +
        city +
        ":" +
        state +
        ":" +
        zip
    );

    if (recordId != null) {
      console.log(
        "calling getAddressValidationResults to get the DPI and DSAT address validation results:" +
          recordId
      );
      action = component.get("c.getAddressValidationResults");
      action.setParams({
        addressId: recordId
      });
    } else {
      console.log(
        "calling getAddressValidationResults with address params to get the DPI and DSAT address validation results"
      );
      action = component.get("c.getAddressValidationResults");
      action.setParams({
        street: street,
        city: city,
        state: state,
        zip: zip
      });
    }

    action.setCallback(this, function(response) {
      var state = response.getState();
      console.log("DPI and DSAT validation response results:" + response);

      if (state === "SUCCESS") {
        console.log("DPI and DSAT validation response results: " + response.getReturnValue()
        );

        var resp = response.getReturnValue();
        var dpiSuccess = resp.dpiSuccess;
        var dsatSuccess = resp.dsatSuccess;
        var multipleDPIResults = resp.multipleDPIResults;

        var addrList = resp.dpiResponseList;

        if (dpiSuccess == true) {
          if (multipleDPIResults == true) {
            helper.setMultipleDPIResultsFlags(component, event, helper, addrList);
          } else {
              helper.setSingleDPIDSATResultsFlags(component, event, helper, addrList);
          }
        } else {
            console.log("FAILURE OCCURRED: Not a valid DPI Address:" + response);
            helper.setDPIErrorResultsFlags(component, event, helper);
        }
      } else {
          console.log("FAILURE OCCURRED: Not a valid DPI Address:" + response);
          helper.setDPIErrorResultsFlags(component, event, helper);
      }
      
    component.set("v.Spinner", false);     
    });

    $A.get('e.force:refreshView').fire();
    $A.enqueueAction(action);
  },

  setMultipleDPIResultsFlags: function(component, event, helper, addrList) {
    component.set("v.dpiData", addrList);
    component.set("v.backupDPIdata", addrList);
    component.set("v.isDPIValidated", true);
    component.set("v.isDPIValFailed", false);  
    component.set("v.showMultipleDPIResults", true);
  },
    
    setSingleDPIDSATResultsFlags: function(component, event, helper, addrList) {
    component.set("v.dpiData", addrList);
    component.set("v.backupDPIdata", addrList);
    component.set("v.isDPIValidated", true);
    component.set("v.isDPIValFailed", false);    
    component.set("v.showMultipleDPIResults", true);
     var addressId = component.get("v.recordId");   
        if(addressId != null && addressId != '') {
            console.log('Its a single address val result from FTRWSAddress recrod screen' + addressId);
            component.set("v.showMultipleDPIResults", true);
        }
    //helper.fireWSDPISavedEvent(component, event, helper);    
  },
  
    setDPIErrorResultsFlags: function(component, event, helper) {
          component.set("v.dpiData", null);
          component.set("v.backupDPIdata", null);
          component.set("v.isDPIValidated", false);
          component.set("v.isDPIValFailed", true);
    }
});