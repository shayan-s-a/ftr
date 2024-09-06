({
	updateStatus : function(component, event, helper) {
        
        component.set("v.showSpinner",true);
        var myFunction = function(){
            helper.updateStatusHelper(component,event);
        }
        setTimeout(myFunction, 500);
	},
    handleRecordUpdated : function(component, event, helper) {
        
        var eventParams = event.getParams();
        
        if(eventParams.changeType === "CHANGED") {
            // get the fields that changed for this record
            var changedFields = eventParams.changedFields;
            
        } else if(eventParams.changeType === "LOADED") {
            // record is loaded in the cache
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted and removed from the cache
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving or deleting the record
        }
        
    },
    handleClick : function(component, event, helper) {
        // Order_Number__c
        var sos = component.find("recordHandler").get("v.targetFields");
        alert(sos.Service_Order_Status__c);
    }
})