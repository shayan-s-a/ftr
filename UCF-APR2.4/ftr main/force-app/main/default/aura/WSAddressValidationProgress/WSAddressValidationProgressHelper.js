({
  toggleOneAndTwoSteps: function(component) {
    var stepOne = component.find("stepOne");
    $A.util.toggleClass(stepOne, "slds-hide");
    var stepTwo = component.find("stepTwo");
    $A.util.toggleClass(stepTwo, "slds-hide");
  },
  toggleTwoAndThreeSteps: function(component) {
    var stepTwo = component.find("stepTwo");
    $A.util.toggleClass(stepTwo, "slds-hide");
    var stepThree = component.find("stepThree");
    $A.util.toggleClass(stepThree, "slds-hide");
  },
  goToValidateInDPIStep: function(component, event, helper) {
    helper.toggleTwoAndThreeSteps(component);
    component.set("v.progressIndicatorFlag", "step3");

    var dpiComp = component.find("dpiComponent"); //dpiComponent

    var addressId = component.get("v.addressId");
    console.log(
      "Passing addressId from dpiComp validateInDPI call" + addressId
    );
    dpiComp.validateInDPI();
  },
  goToValidateInDSATStep : function(component, event, helper) {
        helper.toggleOneAndTwoSteps(component);
        component.set("v.progressIndicatorFlag", "step2");
        
        var addressId = component.get("v.addressId");
        console.log('Passing addressId from dsatComp validateInDSAT call' + addressId);

        //validateInDSAT
        var dsatComp = component.find("dsatComponent");//dpiComponent
        dsatComp.validateInDSAT();
    },  
});