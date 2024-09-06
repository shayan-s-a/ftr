({
	doInit : function(component, event, helper) {
		
              var toastEvent = $A.get("e.force:showToast");
        	   var quoteId = component.get("v.recordId");	
        if (quoteId != null) {
            helper.callUnSyncQuote(component, event, helper);
     	}
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
    }
})