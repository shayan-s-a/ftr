({
    getRecordtypes:function(component, event, helper){    
        //alert('hi');
        helper.getrecordtype(component, event, helper);
        helper.getUCaaSrecordtype(component, event, helper);
        helper.getVoicerecordtype(component, event, helper);
        helper.getCircuitrecordtype(component, event, helper);
        helper.getFAWMitelrecordType(component, event, helper);
        
        var pageRef = component.get("v.pageReference");
        var state = pageRef.state; // state holds any query params      
        var base64Context = state.inContextOfRef;	
        console.log('base64Context = '+base64Context);
        if (base64Context.startsWith("1\.")) {	
            base64Context = base64Context.substring(2);
            
        }	        
        var addressableContext = JSON.parse(window.atob(base64Context));
        console.log('$$$Id='+ addressableContext.attributes.recordId);
        component.set("v.recordId", addressableContext.attributes.recordId);  
        helper.getOpportunityRecord(component);
    },
    createRec: function(component, event, helper){
        helper.createOrder(component, event, helper);
    },
    cancelDialog : function(component, helper) {      
      	
        var recVal =component.get("v.recordId") ;
        if(recVal == undefined){
            alert('=='+recVal);
            var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({
                "scope": "Order"
            });
            homeEvt.fire();
        }else{
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId"),
                "slideDevName": "related"
            });
            navEvt.fire(); 
        }
        $A.get('e.force:refreshView').fire();
        
    },
    onChangeRecordType: function (component, event, helper) {
        var rt=component.find("recordType").get("v.value");
        component.set("v.UCaaSSelectEnable", (rt == 'UCaaS_Order'));
        component.set("v.CircuitSelectEnable", (rt == 'Circuit_Order_Type'));
        component.set("v.VoiceSelectEnable", (rt == 'Voice_Orders'));
        component.set("v.FAWMitelSelectEnable", (rt == 'FAW_Mitel_Orders'));
        
    }
})