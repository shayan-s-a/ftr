({

  navitageToAdjustmentInfoModal: function(component, event, helper) {
        var navigateEvent = $A.get("e.force:navigateToComponent");
        navigateEvent.setParams({
            componentDef: "c:WSAdjustmentInfoModal"
            //You can pass attribute value from Component1 to Component2
            //componentAttributes :{ }
        });
        navigateEvent.fire();
    },
    
  navitageToEditAdjustmentModal: function(component, event, helper) {
        var navigateEvent = $A.get("e.force:navigateToComponent");
        navigateEvent.setParams({
            componentDef: "c:WSAdjustmentInfoModal"
            //You can pass attribute value from Component1 to Component2
            //componentAttributes :{ }
        });
        navigateEvent.fire();
    }    
});