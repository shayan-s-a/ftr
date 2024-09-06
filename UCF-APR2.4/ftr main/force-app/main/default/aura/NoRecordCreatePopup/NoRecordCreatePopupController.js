({
	closeModel: function(component, event, helper) {

        var navEvent = $A.get("e.force:navigateToList");

        navEvent.setParams({

            "listViewName": null,

            "scope": "Contract"

        });

        navEvent.fire();

    }
})