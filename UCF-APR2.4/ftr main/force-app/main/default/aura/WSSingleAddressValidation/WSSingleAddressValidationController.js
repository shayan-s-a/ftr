({
    doInit: function(component, event, helper) {
        
        component.set("v.col", [
            {label:"Address", fieldName: "addressLine1", type:"text" },
            {label:"Unit", fieldName: "unit", type:"text" },
            {label:"City", fieldName: "cityName", type:"text" },
            {label:"State", fieldName: "state", type:"text" },
            {label:"Zip Code", fieldName: "zipCode", type:"text" },
            {label:"Wire Center", fieldName: "wirecenter", type:"text" },
            {label:"Service Control #", fieldName: "svcControlNo", type:"text" },
            {label:"Clli Code", fieldName: "clliCode", type:"text" }
            
        ]);
        
                var oppId =  component.get("v.oppId");
        console.log('22222 Opportunity record id is ' + oppId);


    },

    getCities: function(component, event, helper) {

        console.log('event.keyCode' + event.keyCode);
        var params = {
            "input": component.get('v.location')
        }

        helper.callServer(component, "c.getSuggestions", function(response) {
            var resp = JSON.parse(response);
            console.log('Json parse---');
            console.log(resp.predictions);
            component.set('v.predictions', resp.predictions);
        }, params);

    },

    getCityDetails: function(component, event, helper) {

        var selectedItem = event.currentTarget;
        var placeid = selectedItem.dataset.placeid;

        var params = {
            "placeId": placeid
        }

        helper.callServer(component, "c.getPlaceDetails", function(response) {
            var placeDetails = JSON.parse(response);
            console.log('Json print');
            console.log(placeDetails);

            component.set('v.location', placeDetails.result.name);
            var streetConcatinate = '';

            for (var i = 0; i < placeDetails.result.address_components.length; i++) {
                console.log('JSON Response****');
                console.log(placeDetails.result.address_components[i].types[0]);

                if (placeDetails.result.address_components[i].types[0] == "street_number") {
                    streetConcatinate += ' ' + placeDetails.result.address_components[i].long_name;
                    console.log('2');
                    console.log(streetConcatinate);
                    component.set("v.streetNo", placeDetails.result.address_components[i].long_name);
                }
                if (placeDetails.result.address_components[i].types[0] == "route") {
                    streetConcatinate += ' ' + placeDetails.result.address_components[i].long_name;
                    console.log('3');
                    console.log(streetConcatinate);
                    component.set("v.streetName", placeDetails.result.address_components[i].long_name);
                }

                if (placeDetails.result.address_components[i].types[0] == "locality") {
                    component.set("v.city", placeDetails.result.address_components[i].long_name);
                }
                if (placeDetails.result.address_components[i].types[0] == "administrative_area_level_1") {
                    component.set("v.state", placeDetails.result.address_components[i].short_name);
                }
                if (placeDetails.result.address_components[i].types[0] == "country") {
                    component.set("v.country", placeDetails.result.address_components[i].long_name);
                }
                if (placeDetails.result.address_components[i].types[0] == "postal_code") {
                    component.set("v.zip", placeDetails.result.address_components[i].long_name);
                }
                
                if(placeDetails.result.geometry.location.lat != null) {
                    component.set("v.gLat", placeDetails.result.geometry.location.lat);
                }
                if(placeDetails.result.geometry.location.lng != null) {
                    component.set("v.gLng", placeDetails.result.geometry.location.lng);
                }
            }
            console.log('*********streetConcatinate***');
            console.log(streetConcatinate);
            console.log('glat: glng: ' + component.get("v.gLat") + ':' + component.get("v.gLng"));
            
            if (streetConcatinate != null) {
                component.set("v.street", streetConcatinate);
            }

            component.set('v.predictions', []);
        }, params);
    },

    saveAddress: function(component, event, helper) {
		helper.saveAddress(component, event, helper); 
    },
    
    validateInDPIClicked: function(component, event, helper) {
    	console.log('clicked Validate in DPI button');
        //validateDpiClicked
        component.set("v.validateDpiClicked", false);
        component.set("v.validateDpiClicked", true);
        var oppId =  component.get("v.oppId");
        console.log('Opportunity record id is ' + oppId);
    },
    
	//for selecting a dpi record from the dpi validation results table
    getSelectedDPIRecord: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++) {
            	console.log("You selected Address Street : " + selectedRows[i].latitude);
            	component.set("v.selectedRow", selectedRows[i]);
        }
    },
    
    //for radio group functionality - not needed anymore
    handleAddrValRadioGroupChange: function(component, event) {
         var changeValue = event.getParam('value');
        console.log('Radio group value for Address validation type: ' + changeValue);
        if(changeValue == 'Single') {
            component.set("v.showSingleAddrValType", true);
        } else {
            component.set("v.showSingleAddrValType", false);
        }
    }
    
    
})