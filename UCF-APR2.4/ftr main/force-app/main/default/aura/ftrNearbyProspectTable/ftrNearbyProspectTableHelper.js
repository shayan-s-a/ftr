({
	reloadComponent : function (component, event, helper) {
        var reloadComponent = component.getEvent("reloadComponent");
        reloadComponent.setParams({
            action : 'search',
            distance : component.get('v.distance')
        });
        reloadComponent.fire();
	}
})