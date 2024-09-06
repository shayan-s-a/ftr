({
    doInit : function(component, event, helper) {
        
 	    component.set("v.showModal", true);
        var quoteId = component.get("v.recordId");	
        if (quoteId != null) {
            
            helper.callSyncQuote(component, event, helper);
        }
    },
    showModel: function(component, event, helper) {
        component.set("v.showModal", true);
    }, 
    hideModel: function(component, event, helper) {
        component.set("v.showModal", false);
        $A.get('e.force:refreshView').fire();
         $A.get("e.force:closeQuickAction").fire();
        
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