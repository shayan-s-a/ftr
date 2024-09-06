({
	doInit : function(component, event, helper) {
		helper.refreshAfterSync(component, event);
        
	},
    handleCheckBoxChange : function(component, event, helper) {
        var isChecked = event.getSource().get("v.checked");
        component.set("v.hideCheckboxColumn",isChecked);
        
        if(isChecked){
            var columnsLength = component.get("v.columns").length;
            var cols = component.get("v.columns");
            cols.splice(columnsLength-1,1);
            component.set("v.columns",cols);
            if(component.get("v.so").length != 0){
                $A.util.removeClass(component.find("btn"), 'slds-hide');
            }
        }else{
            $A.util.addClass(component.find("btn"), 'slds-hide');
            var cols = component.get("v.columns");
            cols.push({label: '', type: 'button', initialWidth: 135, typeAttributes: { label: 'Sync With M6', name: 'Sync_With_M6', title: 'Click to View Details'}});
            component.set("v.columns",cols);
        }
    },
    updateSelectedText: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        console.log('selected rows :: '+JSON.stringify(selectedRows));
        cmp.set("v.so",selectedRows);
        if(cmp.get("v.so").length == 0){
            $A.util.addClass(cmp.find("btn"), 'slds-hide');
        }else{
            $A.util.removeClass(cmp.find("btn"), 'slds-hide');
        }
        //alert();
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        helper.syncSingleSO(cmp,row);
        /*switch (action.name) {
            case 'view_details':
                helper.showRowDetails(row);
                break;
            case 'edit_status':
                helper.editRowStatus(cmp, row, action);
                break;
            default:
                helper.showRowDetails(row);
                break;
        }*/
    },
    syncMultiple : function (cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        var action = cmp.get("c.syncServiceOrders");
        
        var resList = cmp.get("v.so");
        for(var i in resList){
            resList[i].Id = resList[i].Id.replace('/','');
        }
        
        action.setParams({serviceOrders : resList});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
            	helper.refreshAfterSync(cmp, event);
                //alert('state :: '+state);
                   
            }else if(state === 'ERROR'){
                //alert(JSON.parse(response.getError()[0].message).errorMessage);
                var em = JSON.parse(response.getError()[0].message);
                //this.showToast(component,em.errorMessage,'error',em.cause);
                cmp.set("v.showError",true);
                cmp.set("v.ErrorType",em.cause);
                cmp.set("v.ErrorMessage",em.errorMessage);
            }
            cmp.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    }
})