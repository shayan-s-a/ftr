({
    /*showModel: function(component, event, helper) {
        component.set("v.showModal", true);
    },
    hideModel: function(component, event, helper) {
        component.set("v.showModal", false);
    },*/
    
    validateFields: function(component) {
        
        var quoteItemRec = component.get("v.quoteItemRecord");
        var discType = component.get("v.discountType");
        var discValue = component.get("v.discountVal"); 
        var recurringType = component.get("v.recurringType");
        var mcrVal = quoteItemRec.standardMRC__c;
        var nrcVal = quoteItemRec.standardNRC__c;
        var valid = false;
        var errorMsg = "";
        if (
            (discType == null || discType == "") &&
            (discValue == null || discValue == "")
        ) {
            errorMsg = "Please select Discount Type and enter a discount value";
        } else if (discType == null || discType == "") {
            errorMsg = "Please select Discount Type";
        } else if (discValue == null || discValue == "") {
            errorMsg = "Discount Value cannot be null";
        } else if (discValue == "0" || discValue == "0.00") {
            errorMsg = "Discount Value cannot be " + discValue;
        } else {
            valid = true;
        }
        
        if(valid == false) {
            
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "error",
            message: errorMsg
          });
          toastEvent.fire();
        }
        return valid;
    },
    
    getParameters: function(component, event, helper) {
        var quoteItemRec = component.get("v.quoteItemRecord");
        var recurringType = component.get("v.recurringType");
        console.log("Applying adjustment.." + quoteItemRec);
        var discType = component.get("v.discountType");
        var discValue = component.get("v.discountVal");
        var notes = component.get("v.discountNotes");
        
       /* alert(
            "Discount Type entered: " +
            discType +
            " Discount value entered: " +
            discValue
        );*/
        
        var mrcNotes = "";
        var nrcNotes = "";
        if (recurringType == "MRC") {
            mrcNotes = notes;
        } else {
            nrcNotes = notes;
        }
        
        return {
            quoteItem: quoteItemRec,
            recurringType: recurringType,
            discountType: discType,
            discountVal: discValue,
            mrcDiscountNotes: mrcNotes,
            nrcDiscountNotes: nrcNotes
        };
    },
    navigateToQuotePage: function(component, event, helper) {
        var quoteId = component.get("v.quoteId");
        var urlEvent = $A.get("e.force:navigateToURL");
        var urlStr = "/lightning/r/SterlingQuote__c/" + quoteId + "/view";
        urlEvent.setParams({
            url: urlStr
        });
        urlEvent.fire();
    }
});