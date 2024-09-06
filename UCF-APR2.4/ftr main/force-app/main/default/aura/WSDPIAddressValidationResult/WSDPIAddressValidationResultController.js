({
	doInit: function(component, event, helper) {
        
        component.set("v.col", [
            {label:"Address", fieldName: "addressLine1", type:"text" },
            {label:"Unit", fieldName: "unit", type:"text" },
            {label:"City", fieldName: "cityName", type:"text" },
            {label:"State", fieldName: "state", type:"text"},
            {label:"Zip", fieldName: "zipCode", type:"text" },
            {label:"Wire Center", fieldName: "wirecenter", type:"text" },
            {label:"Control No", fieldName: "svcControlNo", type:"text" },
            {label:"Clli Code", fieldName: "clliCode", type:"text" }
            //{label:"DPI Action", type: 'button', 
             //typeAttributes: { label: 'Save', name: 'saveDPIInfo', variant: 'base', disabled:{fieldName: "disableSave"} }}
            
        ]);
        
        var addressId =  component.get("v.addressId");
        if(addressId == null) {
            addressId = component.get("v.recordId");
        }
        console.log('22222 FTRWSAddress record id is ' + addressId);
        
        if(addressId != null) {
            console.log('Calling dpi validation from the FTRWSAddress screen');
            helper.validateInDPI(component, event, helper);
        }
    },
    
    handleAddressEvent: function(component, event, helper) {
        
        var addressId = event.getParam("addressId");
        console.log('addressId passed from the single address to DPI component via application event:' + addressId);
        component.set("v.addressId", addressId);
        
        if(addressId != null) {
            component.set("v.disableValDPITBTN", false);
        } else {
            component.set("v.disableValDPITBTN", true);
        }        
    },
    
    validateInDPIClicked: function(component, event, helper) {
    	console.log('clicked Validate in DPI button');

        component.set("v.validateDpiClicked", false);
        component.set("v.validateDpiClicked", true);

        var oppId =  component.get("v.oppId");
        console.log('Opportunity record id is ' + oppId);
        
        var addressId =  component.get("v.addressId");
        console.log('AddressId in DPI validation screen' + addressId);
        
        helper.validateInDPI(component, event, helper);
    },
    
	//for selecting a dpi record from the dpi validation results table
    getSelectedDPIRecord: function (component, event,  helper) {
        var selectedRows = event.getParam('selectedRows');
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++) {
            	console.log("You selected Address Street : " + selectedRows[i].latitude);
            	component.set("v.selectedRow", selectedRows[i]);
            	component.set("v.disableSaveDPIBTN", false);
        }
        
        var row = component.get("v.selectedRow");
        var qualType = "DPI";
        helper.saveDPIAddressQualification(component, event, helper, row, qualType); 
    },

    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper) {
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    },
    
    handleDPIRowAction : function(component,event,helper) {
        var row = event.getParam('row');
        var action = event.getParam('action');
        var qualType = "DPI";
        if(action.name==='saveDPIInfo') {
            helper.saveAddressQualification(component, event, helper, row, qualType); 
        }
	},
    
   /* saveDPIData: function(component,event,helper) {
        var qualType = "DPI";
        var row = component.get("v.selectedRow");
        helper.saveDPIAddressQualification(component, event, helper, row, qualType); 
    },*/
    
     filterDPIData: function(component, event, helper) {
        console.log('filter DPI data invoked');
        var data = component.get("v.backupDPIdata"),
            term = component.get("v.filter"),
            results = data, regex;
            console.log('term: ' + term);

         try {
            if(term){
                regex = new RegExp(term, "i");
                
                results = data.filter(row=>regex.test(row.addressLine1) || regex.test(row.unit) || 
                                      regex.test(row.city) || regex.test(row.state) ||
                                      regex.test(row.zipCode) || regex.test(row.wirecenter)||
                                      regex.test(row.svcControlNo) || regex.test(row.clliCode));
            }
            else{
                component.set("v.dpiData", data);
            }
        } catch(e) {
            console.log(e);
        }
        component.set("v.dpiData", results);
    },
    closeModal:function() {
        $A.get("e.force:closeQuickAction").fire();
    },

})