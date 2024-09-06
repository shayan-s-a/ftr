({  
    
    doInit: function(component, event, helper) { 
        //var value = helper.getParameterByName(component , event, 'inContextOfRef');
        //var context = JSON.parse(window.atob(value));
        //var parentId = context.attributes.recordId;
        var IsProfileValid = component.get("c.isValidProfile");
        IsProfileValid.setCallback(this, function(response) {           
            var state = response.getState();
            if (state == "SUCCESS") {   
                let res = response.getReturnValue();
                console.log(res);
                if(res.isValid && (res.recordTypeId != '' || Object.keys(res.recordTypes).length > 0)){
                    if(res.recordTypeId != '') {
                        var createRecordEvent = $A.get("e.force:createRecord");  
                        createRecordEvent.setParams({  
                            "entityApiName" : "Contract",
                            "recordTypeId": res.recordTypeId
                        });  
                        createRecordEvent.fire(); 
                    } else {
                        let recordTypes = [];
                        let rcs = Object.keys(res.recordTypes);
                        rcs.forEach(o => {
                            recordTypes.push(JSON.parse(JSON.stringify({"value":res.recordTypes[o], "label":o})));
                        });
                        component.set("v.showRecordTypesDropDown", true);
                        component.set("v.recordTypes", recordTypes);
                    }
                }else {
                    component.set("v.showRecordTypesDropDown", false);
                    var evt = $A.get("e.force:navigateToComponent");  
                    evt.setParams({  
                        componentDef : "c:NoRecordCreatePopup",  
                        componentAttributes: {  
                            contactRecordTypeId : null  
                        }
                        
                    });  
                    evt.fire(); 
                    $A.get('e.force:refreshView').fire();
                    console.log("Failed with state: " + state);
                    
                }
            }
        });
        $A.enqueueAction(IsProfileValid);
    },
    handleChange: function (cmp, event) {
        var selectedOptionValue = event.getParam("value");
        cmp.set("v.selectedRecordTypeId", selectedOptionValue);
    },
    handleCreate: function(component, event, helper) { 
        var createRecordEvent = $A.get("e.force:createRecord");  
        createRecordEvent.setParams({  
            "entityApiName" : "Contract",
            "recordTypeId": component.get("v.selectedRecordTypeId")
        });  
        createRecordEvent.fire(); 
    }
    
})