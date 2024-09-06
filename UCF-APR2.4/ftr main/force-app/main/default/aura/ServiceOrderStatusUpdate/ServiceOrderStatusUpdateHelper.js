({
	updateStatusHelper : function(component){
		var action = component.get("c.updateOrderStage");
        
        var sos = component.find("recordHandler").get("v.targetFields");
        console.log(sos.Name );
        var params = {
            soId : component.get("v.recordId"),
            orderNum : sos.Name,
            isCalledFromQuickAction : true
        };
        action.setParams(params);
        
        action.setCallback(this,function(response){
			var state = response.getState();
            
            if(state === 'SUCCESS'){
                $A.get('e.force:refreshView').fire();
                this.showToast(component,'Service Order Status Updated','success','Success Message');
                $A.get("e.force:closeQuickAction").fire();;
            }else if(state === 'ERROR'){
                //alert(JSON.parse(response.getError()[0].message).errorMessage);
                var em = JSON.parse(response.getError()[0].message);
                //this.showToast(component,em.errorMessage,'error',em.cause);
                component.set("v.showError",true);
                component.set("v.ErrorType",em.cause);
                component.set("v.ErrorMessage",em.errorMessage);
            }
             component.set("v.showSpinner",false);
		});
        $A.enqueueAction(action);
	},
    showToast : function(component,message,type,title){
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    }
})