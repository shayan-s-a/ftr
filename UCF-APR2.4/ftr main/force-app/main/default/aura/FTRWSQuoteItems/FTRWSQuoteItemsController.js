({
    myAction : function(component, event, helper) {
         
    },
    init: function (cmp, event, helper) {
        
        
        helper.getQuoteItems(cmp, event, helper);
    },
    
    handleRowAction: function (cmp, event, helper) {
        console.log('event action name: ' + event);
        //console.log('event row name:' + event.row.name);
        
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log('row: ' + row);
        switch (action.name) {
            case 'show_details':
                helper.navigate(row.Id);
                break;
            case 'delete':
                helper.removeItem(cmp, row);
                break;
            case 'mrcAction':
                helper.showDiscountPopup(cmp, row, "MRC");
                break;
            case 'nrcAction':
                helper.showDiscountPopup(cmp, row, "NRC");
                break;
                
        }
    },
    
    handleTableSave : function(component, event, helper) {
        const updated = event.getParam('draftValues');
        updated.forEach(elem => {
            if (elem.IRR_Internal_Rate_of_Return__c) {
            	elem.IRR_Internal_Rate_of_Return__c = parseFloat(elem.IRR_Internal_Rate_of_Return__c) * 100;
        	}
        })
        var action = component.get("c.updateQuoteItems");
        action.setParams({ quoteItems: updated });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.draftValues', []);
                const returnValue = response.getReturnValue();
                if (returnValue) {
                    $A.get('e.force:refreshView').fire();
                }
                helper.getQuoteItems(component, event, helper);
                
            } 
        });
        $A.enqueueAction(action);
    } 
    
    
})