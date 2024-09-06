({
	 init : function(component, event, helper){
         helper.getData(component, event, helper);
    },
	
    
    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
    }
})