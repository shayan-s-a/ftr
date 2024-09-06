({
	init : function(cmp, event, helper) {
		helper.submitQuoteForApproval(cmp, event, helper);
	},
    
   hideModel: function(cmp, event, helper) {
        //component.set("v.showModal", false);
        $A.get('e.force:refreshView').fire();
         $A.get("e.force:closeQuickAction").fire();
       helper.navigateToQuotePage(cmp, event, helper);
    }    
})