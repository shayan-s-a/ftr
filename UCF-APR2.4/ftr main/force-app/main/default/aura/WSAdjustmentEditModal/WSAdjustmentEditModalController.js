({
  init: function(cmp, event, helper) {
    cmp.set("v.showModal", true);
  },

  showModel: function(component, event, helper) {
    component.set("v.showModal", true);
  },

  hideModel: function(component, event, helper) {
    
    //$A.get('e.force:refreshView').fire();
    helper.navigateToQuotePage(component, event, helper);
    component.set("v.showModal", false);  
    component.set("v.showEmailModal", false);       
  },

  hideModel1: function(component, event, helper) {
    
    //$A.get('e.force:refreshView').fire();
    helper.navigateToQuotePage(component, event, helper);
    component.set("v.showModal", false);  
    component.set("v.showEmailModal", false);       
  },    
    
  applyAdjustment: function(component, event, helper) {
    var valid = helper.validateFields(component);
    if (valid) {
      var action = component.get("c.applyDiscount");
      var params = helper.getParameters(component, event, helper);

      action.setParams({ jsonString: JSON.stringify(params) });

      action.setCallback(this, function(response) {
        if (response.getState() === "SUCCESS") {
          console.log(response.getReturnValue());         
            
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "success",
            message: "Applied discount successfully."
          });
          toastEvent.fire();
          console.log(response.getReturnValue());
            //added by Vara
		    component.set("v.showModal", false); 
           component.set("v.showEmailModal", true); 
            //upto here
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "error",
            message: "Failed to apply discount."
          });
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);
    }
  },

  onSelectChange: function(component, event, helper) {
    var discountType = component.find("select").get("v.value");
    component.set("v.discountType", discountType);
  },

  // this function automatic call by aura:waiting event
  showSpinner: function(component, event, helper) {
    // make Spinner attribute true for display loading spinner
    component.set("v.Spinner", true);
  },

  // this function automatic call by aura:doneWaiting event
  hideSpinner: function(component, event, helper) {
    // make Spinner attribute to false for hide loading spinner
    component.set("v.Spinner", false);
  }
});