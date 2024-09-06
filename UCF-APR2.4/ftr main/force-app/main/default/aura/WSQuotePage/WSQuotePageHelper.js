({
  helperMethod: function() {},

  getOpporunityAddressList: function(component, event, helper) {
    var action = component.get("c.getOpportunityAddressList");
    action.setParams({ quoteId: component.get("v.recordId") });
    action.setCallback(this, function(response) {
      if (response.getState() === "SUCCESS") {
          const result = response.getReturnValue();
        component.set("v.oppaddrlist", result.oppAddressList);
          if (!$A.util.isUndefinedOrNull(result.hideAddDetails)) {
              component.set("v.hideAddDetails", result.hideAddDetails);
          }
        console.log(response.getReturnValue());
        var addressList = result.oppAddressList;
        var array = new Array();
        for (var i = 0; i < addressList.length; i++) {
          array.push(addressList[i].Id);
        }
        component.set("v.activeSections", array);
      }
    });
    $A.enqueueAction(action);
  },

  getQuoteItems: function(component, event, helper) {
    var action = component.get("c.getQuoteItemLines");
    action.setParams({ quoteId: component.get("v.recordId") });
    action.setCallback(this, function(response) {
      if (response.getState() === "SUCCESS") {
        component.set("v.quoteitems", response.getReturnValue());
        console.log(response.getReturnValue());
      }
    });
    $A.enqueueAction(action);
  },

  setActiveSections: function(component, event, helper) {
    var addressId = component.get("v.addressId");
    component.set("v.activeSections", [addressId]);
  }
});