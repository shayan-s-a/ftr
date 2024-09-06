({
  callServer: function(component, method, callback, params) {
    var action = component.get(method);
    if (params) {
      action.setParams(params);
    }

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        // pass returned value to callback function
        callback.call(this, response.getReturnValue());
      } else if (state === "ERROR") {
        // generic error handler
        var errors = response.getError();
        if (errors) {
          console.log("Errors", errors);
          if (errors[0] && errors[0].message) {
            throw new Error("Error" + errors[0].message);
          }
        } else {
          throw new Error("Unknown Error");
        }
      }
    });

    $A.enqueueAction(action);
  },
    
    getAddressParameters : function(component) {
    	var addressId = component.get("v.addressId");
    	var streetNo = component.get("v.streetNo");
        var streetName = component.get("v.streetName");
        var city = component.get("v.city")
        var state = component.get("v.state");
        var unitNo = component.get("v.unit");
        var zip = component.get("v.zip");
        var oppId = component.get("v.oppId");
    	var gLat = component.get("v.gLat");
    	var gLng = component.get("v.gLng");
        var actionStr = "";
	
        if(addressId != null) {
           return {
                'addressId' : addressId,
                'actionStr': "UPDATE",
                'streetNo': streetNo,
                'streetName': streetName,
                'city': city,
                'state': state,
                'unitNo': unitNo,
                'zipcode' : zip,
                'opportunityId' : oppId,
                'gLat' : gLat,
                'gLng' : gLng
    		};
        } else {
            return {
                'actionStr': "CREATE",
                'streetNo': streetNo,
                'streetName': streetName,
                'city': city,
                'state': state,
                'unitNo': unitNo,
                'zipcode' : zip,
                'opportunityId' : oppId,
                'gLat' : gLat,
                'gLng' : gLng
    		};
        }
        
        console.log('Calling ' + actionStr + 'address with address id:' + addressId);
	},
    
  saveAddress: function (component, event, helper) {

      	var action = component.get("c.get_SaveAddress");
		var gAddress = this.getAddressParameters(component);      	

        //String streetNo, String streetName, String unitNo, String city, String state, String zipcode, String opportunityId
        //
        var gAddrStr = JSON.stringify(gAddress);

        action.setParams({
               "gAddressStr" : gAddrStr
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
					helper.setDPIFlags(component, event, helper, address);
                    toastEvent.setParams({
                        "type": "success",
                        "message": "Address has been SAVED Sucessfully"
                    });
                    toastEvent.fire();
                } else {
                    toastEvent.setParams({
                        "type": "error",
                        "message": "Failed to "+ actionStr +" Address for the Wholesale Carrier"
                    });
                    toastEvent.fire();
                }

            } else {

            }
        });
        $A.enqueueAction(action);
      
  },		    

 setDPIFlags: function(component, event, helper, address) {
     console.log('Setting DPI flags: got address id: ' + address.Id);
     console.log('Setting DPI flags: got DPI_Validated__c: ' + address.DPI_Validated__c);
     component.set("v.addressId", address.Id);
     component.set("v.oppId", address.Opportunity_ID__c);
     
     var appEvent = $A.get("e.c:WSAddressEvent");//component.getEvent("addressEvent");
     appEvent.setParams({"addressId" :  address.Id});
     appEvent.setParams({"oppId" :  address.Opportunity_ID__c});
     appEvent.fire();
	
     console.log('Fired the addressEvent, passing the addressId:' + address.Id + ' and the oppId:' + address.Opportunity_ID__c);
     
     console.log('v.disableDpiBTN is set to:' + component.get("v.disableDpiBTN"));
  },
    
    resetForm: function (component, event, helper) {
        component.set("v.disableDpiBTN", true); 
        component.set("v.disableSaveBTN", false);
        component.set("v.streetNo", null);
        component.set("v.streetName", null);
        component.set("v.city", null);
        component.set("v.state", null);
        component.set("v.zip", null);
        component.set("v.location", null);
        component.set("v.addressId", null);
        
    }  
});