({
	doInit : function(component,event,helper) {
		var action = component.get("c.getdocId")
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (state === "SUCCESS") {
                var docId = response.getReturnValue();
                var docURL1 ='/sfc/servlet.shepherd/document/download/'+docId[0]+'?operationContext=S1';
                component.set("v.documentURL1",docURL1);
                var docURL2 ='/sfc/servlet.shepherd/document/download/'+docId[1]+'?operationContext=S1';
                component.set("v.documentURL2",docURL2);
            }
        });        
        $A.enqueueAction(action);
	}
        
    
})