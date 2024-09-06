({  
    
    doInit : function(component, event, helper) {
    },
    
    invoke : function(component, event, helper) {
        var action = component.get("c.getBaseUrl");
        action.setCallback(this,function(response) {
			var dataReturned = response.getReturnValue();
            if(dataReturned[0] == 'Frontier Partner Portal User') {
                window.open( dataReturned[1]+'/s/opportunity/'+component.get("v.recordId"), '_blank');
            }else {
                window.open( dataReturned[1]+'/lightning/r/Contract/'+component.get("v.recordId")+'/view', '_blank');
            }
        });
         $A.enqueueAction(action);
       
    }
})