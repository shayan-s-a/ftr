({
  getDiscountInfo: function(cmp, event, helper) {
    helper.validateDiscountParams(cmp, event, helper);

    var action = cmp.get("c.getQuoteLineItemDiscountInfo");
    var params = helper.getParameters(cmp, event, helper);

    action.setParams({ jsonString: JSON.stringify(params) });

    action.setCallback(this, function(response) {
      if (response.getState() === "SUCCESS") {
        console.log(response.getReturnValue());
        var data = response.getReturnValue();
        cmp.set("v.adjustedAmt", data.adjustedAmt);
        cmp.set("v.actualAmt", data.actualAmt);
        cmp.set("v.discAmt", data.discAmt);
        cmp.set("v.discAppliedBy", data.discAppliedBy);
        cmp.set("v.showDiscountInfo", data.isDiscounted); 
        cmp.set("v.notes", data.notes); 
          // added by vara from here to
         cmp.set("v.PrimaryCompetitor", data.PrimaryCompetitor);
         cmp.set("v.PrimaryCompetitorArea", data.PrimaryCompetitorArea);
         cmp.set("v.PrimaryCompetitorAmt", data.PrimaryCompetitorAmt);
         // added by vara uoto here
        var msg = "Discount info retrieved successfully!";  
        helper.showMsg("success", msg);
        
        console.log(response.getReturnValue());
      } else {
         var msg = "Failed to retrieve discount info."; 
       	 helper.showMsg("error", msg);
      }
    });
    $A.enqueueAction(action);
  },

  getParameters: function(component, event, helper) {
    var quoteItemRec = component.get("v.quoteItemRecord");
    var recurringType = component.get("v.recurringType");
    console.log("Applying adjustment.." + quoteItemRec);
    return {
      quoteItem: quoteItemRec,
      recurringType: recurringType
    };
  },

  validateDiscountParams: function(cmp, event, helper) {
    var quoteItemRec = cmp.get("v.quoteItemRecord");
    var recurringType = cmp.get("v.recurringType");

    if (recurringType == "MRC") {
      var mrcVal = quoteItemRec.Display_MRC__c;
      if (mrcVal != null && mrcVal == "$0.00") {
        var msg = "Cannot apply discount for a $0.00 MRC";
        helper.showMsg("error", msg);
        cmp.set("v.showModal", false);
        helper.navigateToQuotePage(cmp, event, helper);
      } else {
        cmp.set("v.showModal", true);
      }
    } else if (recurringType == "NRC") {
      var nrcVal = quoteItemRec.Display_NRC__c;
      if (nrcVal != null && nrcVal == "$0.00") {
        var msg = "Cannot apply discount for a $0.00 NRC";
        helper.showMsg("error", msg);
        cmp.set("v.showModal", false);
        helper.navigateToQuotePage(cmp, event, helper);
      } else {
        cmp.set("v.showModal", true);
      }
    }
  },

  navitageToEditAdjustmentModal: function(component, event, helper) {
    var navigateEvent = $A.get("e.force:navigateToComponent");
    var quoteId = component.get("v.quoteId");
    var quoteItemRec = component.get("v.quoteItemRecord");
    var recurringType = component.get("v.recurringType");
    navigateEvent.setParams({
      componentDef: "c:WSAdjustmentEditModal",
      //You can pass attribute value from Component1 to Component2
      componentAttributes: {
        quoteId: quoteId,
        quoteItemRecord: quoteItemRec,
        recurringType: recurringType
      }
    });
    navigateEvent.fire();
  },

  navigateToQuotePage: function(component, event, helper) {
    var quoteId = component.get("v.quoteId");
    var urlEvent = $A.get("e.force:navigateToURL");
    var urlStr = "/lightning/r/SterlingQuote__c/" + quoteId + "/view";
    urlEvent.setParams({
      url: urlStr
    });
    urlEvent.fire();
  },

  removeDiscount: function(cmp, event, helper) {
    var action = cmp.get("c.removeDiscount");
    var params = helper.getParameters(cmp, event, helper);

    action.setParams({ jsonString: JSON.stringify(params) });

    action.setCallback(this, function(response) {
      if (response.getState() === "SUCCESS") {
        console.log(response.getReturnValue());
        var data = response.getReturnValue();
        
        var msg = "Discount removed successfully!!";
        helper.showMsg("success", msg);  
        console.log("Removed discount: " + data);
        helper.navigateToQuotePage(cmp, event, helper);  
        cmp.set("v.showModal", false);
        
          
      } else {
        var msg = "Failed to remove discount.";  
        helper.showMsg("error", msg);
        console.log("Removed discount: " + data);  
          
        //cmp.set("v.showModal", false);
        helper.navigateToQuotePage(cmp, event, helper);
          
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
  }
});