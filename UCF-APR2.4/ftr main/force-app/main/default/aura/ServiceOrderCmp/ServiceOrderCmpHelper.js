({
	syncSingleSO : function(component,row) {
        console.log('Action :: '+JSON.stringify(row));
        component.set("v.showSpinner",true);
        var action = component.get("c.syncServiceOrder");
        
        row.Id = row.Id.replace('/','');
        action.setParams({serviceOrder : row});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
            	this.refreshAfterSync(component, event);
                //alert('state :: '+state);
            }else if(state === 'ERROR'){
                //alert(JSON.parse(response.getError()[0].message).errorMessage);
                var em = JSON.parse(response.getError()[0].message);
                //this.showToast(component,em.errorMessage,'error',em.cause);
                component.set("v.showError",true);
                component.set("v.ErrorType",em.cause);
                component.set("v.ErrorMessage",em.errorMessage);
            }
            component.set("v.showSpinner",false); 
        });
        $A.enqueueAction(action);
	},
    refreshAfterSync : function(component,event) {
        var action = component.get("c.returnServiceOrders");
        action.setParams({orderId : component.get("v.recordId")});
        action.setCallback(this,function(response){
            
            var state = response.getState();
            if(state == 'SUCCESS'){ 
                var cloumns = [
                    {label: 'Service Order Number', fieldName: 'Id', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank', tooltip: 'Click to visit service order' }},
                    //{label: 'Service Order Number', fieldName: 'Name', type: 'text'},
                    {label: 'Product', fieldName: 'Item_Spec_Id__c', type: 'text'},
                    {label: 'Service Order Stage', fieldName: 'Service_Order_Stage__c', type: 'text'},
                    {label: 'Primary Location', fieldName: 'Priloc_Address__c', type: 'text'},
                    {label: 'Secondry Location', fieldName: 'Secloc_Address__c', type: 'text'},
                    {label: 'Due Date', fieldName: 'M6_dd_task_date__c', type: 'date'}
                ]; 
                if(!component.get("v.hideCheckboxColumn")){
                    cloumns.push({label: '', type: 'button', initialWidth: 135, typeAttributes: { label: 'Sync With M6', name: 'Sync_With_M6', title: 'Click to View Details'}});
                } 
               
                var resList = response.getReturnValue().lstSo;
                var prodMap = response.getReturnValue().pickListValuesMap;
                for(var i in resList){
                    resList[i].Id = '/'+resList[i].Id;
                    resList[i].Item_Spec_Id__c = prodMap[resList[i].Item_Spec_Id__c];
                }
                //alert(JSON.stringify(response.getReturnValue()));
                component.set("v.columns",cloumns);
                component.set("v.serviceOrders",resList);
            }else{
                
            }
        });
        $A.enqueueAction(action);
    }
})