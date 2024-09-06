({
    init: function(cmp, event, helper) {
		helper.getDiscountInfo(cmp, event, helper);        
    },
    
    showModel: function(cmp, event, helper) {
        cmp.set("v.showModal", true);
    },
    
    hideModel: function(cmp, event, helper) {
        cmp.set("v.showModal", false);
        helper.navigateToQuotePage(cmp, event, helper);
        //$A.get('e.force:refreshView').fire();
    },
    
    showEditAdjustmentModal: function(cmp, event, helper) {
        cmp.set("v.showModal", false);
        helper.navitageToEditAdjustmentModal(cmp, event, helper);  
    },

    deleteDiscount: function(cmp, event, helper) {
        helper.removeDiscount(cmp, event, helper);
    }    
    
})

/*


public @AuraEnabled Decimal actualAmt{get;set;}
public @AuraEnabled String displayAmt{get;set;}
public @AuraEnabled Decimal adjustedAmt{get;set;}
public @AuraEnabled Decimal discAmt{get;set;} //difference b/w actualAmt and adjustedAmt
public @AuraEnabled String recurringType{get;set;}
public @AuraEnabled String notes{get;set;}
public @AuraEnabled String discAppliedBy{get;set;}


*/