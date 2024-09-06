({
    doInit : function(component, event, helper) {
        console.log("RecordId in the progress bar component: " + component.get("v.recordId"));
        helper.toggleTwoAndThreeSteps(component);
        component.set("v.progressIndicatorFlag", "step1");
    },

  
    goBackToStepOne : function(component, event, helper) {
        helper.toggleOneAndTwoSteps(component);
        component.set("v.progressIndicatorFlag", "step1");
    },
    goBackToStepTwo : function(component, event, helper) {
        helper.toggleTwoAndThreeSteps(component);
        component.set("v.progressIndicatorFlag", "step2");
    },
    handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    },
    
    handleAddressEvent: function(component, event, helper) {
        
        var addressId = event.getParam("addressId");
        console.log('addressId passed from the child event:' + addressId);
        component.set("v.addressId", addressId);
        //component.set("v.disableNextBTN", false);
        helper.goToValidateInDSATStep(component, event, helper);
    },
    
    handleDPISavedEvent: function(component, event, helper) {
        console.log('Enabling next button to go to the DSAT screen');
        //component.set("v.disableNextDPIBTN", false);
        helper.goToValidateInDPIStep(component, event, helper);
    }
})