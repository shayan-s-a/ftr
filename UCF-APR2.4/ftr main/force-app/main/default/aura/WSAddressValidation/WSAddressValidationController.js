({
    doInit: function(component, event, helper) {
        
         var recordId =  component.get("v.recordId");
        console.log('11111 Opportunity record id is ' + recordId);
    },
    
    handleAddressEvent: function(component, event, helper) {
        
        var addressId = event.getParam("addressId");
        var oppId = event.getParam("oppId");
        console.log('addressId passed from the child event:' + addressId + ' and oppId:' + oppId);
        component.set("v.addressId", addressId);
        //component.set("v.disableNextBTN", false);
    }
})