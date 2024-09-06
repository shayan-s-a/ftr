({
  submitQuoteForApproval: function(cmp, event, helper) {
    var action = cmp.get("c.submitWSQuoteForApproval");
    var quoteid = cmp.get("v.recordId");

    console.log("Quoteid passed for the Approval flow: " + quoteid);

    action.setParams({ quoteId: quoteid });

    action.setCallback(this, function(response) {
      if (response.getState() === "SUCCESS") {
        console.log("Quote Submitted for approval response --" + response.getReturnValue());
        var data = response.getReturnValue();
        if (data == true) {
          var msg = "Quote Submitted for Approval!";
          cmp.set("v.showSuccess", true);
          cmp.set("v.showError", false);
          console.log(response.getReturnValue());
        } else {
            var msg = "Cannot Submit Quote for Approval";
            cmp.set("v.showSuccess", false);
            cmp.set("v.showError", true);
        }
      } else {
        var msg = "Failed to submit Quote for Approval";
        cmp.set("v.showSuccess", false);
        cmp.set("v.showError", true);
      }
    });
    $A.enqueueAction(action);
  },

  showMsg: function(type, msg) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: type,
      message: msg,
      duration: "3000",
      mode: "dismissable"
    });
    toastEvent.fire();
  },

  navigateToQuotePage: function(cmp, event, helper) {
    var quoteId = cmp.get("v.recordId");
    var urlEvent = $A.get("e.force:navigateToURL");
    var urlStr = "/lightning/r/SterlingQuote__c/" + quoteId + "/view";
    urlEvent.setParams({
      url: urlStr
    });
    urlEvent.fire();
  }
});