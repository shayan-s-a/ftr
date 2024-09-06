({
  callUnSyncQuote: function(component, event, helper) {
    var action = component.get("c.getUnSyncQuoteWithOpportunity");
    action.setParams({
      quoteId: component.get("v.recordId")
    });
    action.setCallback(this, function(response) {
        var state = response.getState();
        console.log("**getUnSyncQuoteWithOpportunity: state**: " + state);
      if (state === "SUCCESS") {
        	var response = response.getReturnValue();
          if(response == "SUCCESS") {
              component.set("v.unSyncSuccess", true);
              //$A.get("e.force:closeQuickAction").fire();
              $A.get('e.force:refreshView').fire();
      
          } else {
              component.set("v.unSyncSuccess", false);
          }
      }
    });
    $A.enqueueAction(action);
  }
});