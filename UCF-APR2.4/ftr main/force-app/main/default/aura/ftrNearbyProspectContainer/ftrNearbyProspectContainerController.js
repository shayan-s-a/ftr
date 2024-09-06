({
    scriptsLoaded : function(component, event, helper) {
        console.debug('Script loaded..'); 
    },
	doInit : function(component) {
        component.set('v.error', false);
		var comp = component.find("prospect-table");
		if(comp !=null || comp !=undefined){
            comp.destroy();
		}
		$A.createComponent(
            "c:ftrNearbyProspectTable",
            {
                "aura:id": "prospect-table",
                "recordId": component.get('v.recordId')
            },
            function(newComp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newComp);
					component.set("v.body", body);
                } else if (status === "INCOMPLETE") {
                    console.error("No response from server or client is offline.")
                } else if (status === "ERROR") {
					console.error(errorMessage);
				}
            }
        );
    },
    performAction : function(component, event) {
        if (event.getParam('action') == 'error') {
            component.set('v.errorMsg', event.getParam('errorMsg'));
            component.set('v.error', true);
            var comp = component.find("prospect-table");
            if(comp !=null || comp !=undefined){
                comp.destroy();
            }
        } else if (event.getParam('action') == 'search') {
            var comp = component.find("prospect-table");
            if(comp !=null || comp !=undefined){
                comp.destroy();
            }
            $A.createComponent(
                "c:ftrNearbyProspectTable",
                {
                    "aura:id": "prospect-table",
                    "recordId": component.get('v.recordId'),
                    "distance": event.getParam('distance')
                },
                function(newComp, status, errorMessage){
                    if (status === "SUCCESS") {
                        var body = component.get("v.body");
                        body.push(newComp);
                        component.set("v.body", body);
                    } else if (status === "INCOMPLETE") {
                        console.error("No response from server or client is offline.")
                    } else if (status === "ERROR") {
                        console.error(errorMessage);
                    }
                }
            );
        }
    }
})