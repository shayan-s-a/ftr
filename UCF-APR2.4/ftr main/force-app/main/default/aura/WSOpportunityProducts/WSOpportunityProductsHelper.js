({
  callGenerateOppProducts: function(component, event, helper) {
    var action = component.get("c.getSterlingQuoteItems");
    var comments = "Testing Opportunity products generation";
    action.setParams({
      strOpportunityId: component.get("v.recordId")
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      console.log("**state**" + state);
      if (state === "SUCCESS") {
        var dataList = response.getReturnValue();
        console.log("**WS Opp Products response **" + dataList);
        for (var i = 0; i < dataList.length; i++) {
          var wrapperProd = dataList[i];
          console.log("**WS Opp Product **" + wrapperProd.ServiceAddress);
        }
        helper.setData(component, event, helper, dataList);

        $A.get("e.force:refreshView").fire();
      } else {
        component.set("v.oppProdsFailed", true);
      }
    });
    $A.enqueueAction(action);
  },

  setData: function(component, event, helper, dataList) {
    component.set("v.oppProdsSuccess", true);
    component.set("v.oppProdData", dataList);
    component.set("v.backupOppProddata", dataList);
  },

  callWSQuickQuote: function(component, event, helper) {
    var action = component.get("c.getWSQuickQuote");
    var comments = "Testing WS Quick quote generation";
    action.setParams({
      strOpportunityId: component.get("v.recordId"),
      commentStr: comments
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      console.log("**state**" + state);
      if (state === "SUCCESS") {
        var response = response.getReturnValue();
        console.log("**WS QQ response **" + response);
          //JIRA issue fix: OAM-1390: Do not allow quick quote if WS quote has been rejected during approval flow  
          var quoteStatus = response.Status__c;
        if (quoteStatus != null && (quoteStatus == "Rejected" ||quoteStatus == "In Review" ||
                                   quoteStatus == "Needs Review") ) {
          var errorMsg =
            "Quick Quote generation failed, as Quote status is '" + quoteStatus + "'" ;
          helper.showToastMessage("error", errorMsg);
          $A.get("e.force:refreshView").fire();
        } else {
          var successMsg = "Quick quote generated successfully!";
          helper.showToastMessage("success", successMsg);
          $A.get("e.force:refreshView").fire();
        }
      } else {
        var errorMsg = "Quick quote generation failed!";
        helper.showToastMessage("error", errorMsg);
        $A.get("e.force:refreshView").fire();
      }
    });
    $A.enqueueAction(action);
  },

  navigate: function(Id) {
    var urlEvent = $A.get("e.force:navigateToURL");
    var urlStr = "/lightning/r/SterlingQuoteItem__c/" + Id + "/view";
    urlEvent.setParams({
      url: urlStr
    });
    urlEvent.fire();
  },

  showToastMessage: function(type, msg) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: type,
      message: msg,
      duration: "3000",
      mode: "dismissable"
    });
    toastEvent.fire();
  }
});