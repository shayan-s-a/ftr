({
  callSyncQuote: function(component, event, helper) {
    var action = component.get("c.getSyncQuoteWithOpportunity");
    action.setParams({
      quoteId: component.get("v.recordId")
    });
    action.setCallback(this, function(response) {
        var state = response.getState();
        console.log("**state**");
      if (state === "SUCCESS") {
        	var response = response.getReturnValue();
          if(response == "SUCCESS") {
              component.set("v.syncSuccess", true);
              component.set("v.syncFailed", false);
              
                //$A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();

          } else {
              component.set("v.syncFailed", true);
              component.set("v.syncSuccess", false);
          }
      }
    });
    $A.enqueueAction(action);
  }
});