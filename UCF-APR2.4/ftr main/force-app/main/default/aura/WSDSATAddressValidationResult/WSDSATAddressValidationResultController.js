({
	doInit: function(component, event, helper) {
        
        //helper.validateInDSAT(component, event, helper);
       console.log('Calling validate in DSAT from the FTRWSAddress screen');
        
        var addressId =  component.get("v.addressId");
        if(addressId == null) {
            addressId = component.get("v.recordId");
        }
        console.log('22222 FTRWSAddress record id is ' + addressId);
        
        if(addressId != null) {	
            console.log('Calling dpi validation from the FTRWSAddress screen');
            helper.validateInDSAT(component, event, helper);
        }
    },
    
    validateInDSAT: function(component, event, helper) {
    
        console.log('Calling validate in DSAT from the Opportunity screen');
        helper.validateInDSAT(component, event, helper);
	},
    
    handleAddressEvent: function(component, event, helper) {
        
        var addressId = event.getParam("addressId");
        console.log('addressId passed from the single address to DSAT component via application event:' + addressId);
        component.set("v.addressId", addressId);
        
        if(addressId != null) {
            component.set("v.disableValDSATBTN", false);
        } else {
            component.set("v.disableValDSATBTN", true);
        }  
    },
    
    saveDSATData: function(component,event,helper) {
        var qualType = "DSAT";
        var row = component.get("v.dsatRespData");
        helper.saveDSATAddressQualification(component, event, helper, row, qualType); 
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
    
    closeModal:function() {
        $A.get("e.force:closeQuickAction").fire();
    },
    goToDPI : function(component,event,helper) {
        console.log(
          "Firing DPI saved event, enable the Next button to go to the DSAT screen"
        );
        var appEvent = $A.get("e.c:WSDPISaved"); //component.getEvent("WSDPISaved");
        appEvent.fire();
    }   

})