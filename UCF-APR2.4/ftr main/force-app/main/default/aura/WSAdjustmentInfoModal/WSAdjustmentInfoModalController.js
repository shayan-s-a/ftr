({
    init: function(cmp, event, helper) {
        cmp.set("v.showModal", true);
    },
    
    showModel: function(component, event, helper) {
        component.set("v.showModal", true);
    },
    
    hideModel: function(component, event, helper) {
        component.set("v.showModal", false);
        $A.get('e.force:refreshView').fire();
    },
})