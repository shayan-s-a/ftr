({
    getrecordtype : function(component,event,helper){
        var action = component.get('c.fetchRecordTypeValues');
        action.setParams({
            "objectName":'Order'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                debugger;
                var custs = [];
                var conts = response.getReturnValue();
                for(var key in conts){
                    custs.push({key:conts[key], value:key});
                }
                component.set("v.recordTypeMap", custs);
                component.set("v.selectRecordtype",true);
                console.log(component.get("v.recordTypeMap"));
            }
        });
        $A.enqueueAction(action);
    },
    getOpportunityRecord: function(component){
        var action = component.get('c.getOpportunityData');
        action.setParams({
            "oppId":component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                debugger;
                
                var oppRec = response.getReturnValue();
                
                component.set("v.opportunityRecord", oppRec);
            }
        });
        $A.enqueueAction(action);
    },
    getUCaaSrecordtype : function(component,event,helper){
        var action = component.get('c.fetchUCaaSRecordTypeList');
        action.setParams({
            "objectName":'Order'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                debugger;
                var custUCaaS = [];
                var UCaaS = response.getReturnValue();
                for(var key in UCaaS){
                    custUCaaS.push({key:UCaaS[key], value:key});
                }
                component.set("v.UCaaSrecordTypeMap", custUCaaS);
                component.set("v.selectRecordtype",true);
                console.log(component.get("v.UCaaSrecordTypeMap"));
            }
        });
        $A.enqueueAction(action);
    },
    getVoicerecordtype : function(component,event,helper){
        var action = component.get('c.fetchVoiceRecordTypeList');
        action.setParams({
            "objectName":'Order'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var custUCaaS = [];
                var UCaaS = response.getReturnValue();
                for(var key in UCaaS){
                    custUCaaS.push({key:UCaaS[key], value:key});
                }
                component.set("v.VoicerecordTypeMap", custUCaaS);
                component.set("v.selectRecordtype",true);
            }
        });
        $A.enqueueAction(action);
    },
    getCircuitrecordtype : function(component,event,helper){
        var action = component.get('c.fetchCircuitRecordTypeList');
        action.setParams({
            "objectName":'Order'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var custUCaaS = [];
                var UCaaS = response.getReturnValue();
                for(var key in UCaaS){
                    custUCaaS.push({key:UCaaS[key], value:key});
                }
                component.set("v.CircuitrecordTypeMap", custUCaaS);
                component.set("v.selectRecordtype",true);
            }
        });
        $A.enqueueAction(action);
    },
      getFAWMitelrecordType : function(component,event,helper){
        var action = component.get('c.fetchFAWMitelRecordTypeList');
        action.setParams({
            "objectName":'Order'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var custUCaaS = [];
                var UCaaS = response.getReturnValue();
                for(var key in UCaaS){
                    custUCaaS.push({key:UCaaS[key], value:key});
                }
                component.set("v.FAWMitelrecordTypeMap", custUCaaS);
                component.set("v.selectRecordtype",true);
            }
        });
        $A.enqueueAction(action);
    },
    createOrder: function(component, event, helper){
        
        var recVal =component.get("v.recordId") ;
        var objRec = component.get("v.opportunityRecord");
        console.log('$$$recVal='+recVal);
        var accInfo;      
        var rt=component.find("recordType").get("v.value");
        var rectypeId;
        
        if(rt =='UCaaS_Order'){ 
            var UCaaSrt=component.find("UCaaSrecordType").get("v.value");            
            rectypeId =UCaaSrt;   
        } else if(rt == 'Voice_Orders') {
            var UCaaSrt=component.find("VoicerecordType").get("v.value");            
            rectypeId =UCaaSrt; 
        } else if(rt == 'Circuit_Order_Type') {
            var UCaaSrt=component.find("CircuitrecordType").get("v.value");            
            rectypeId =UCaaSrt; 
        }else if(rt=='FAW_Mitel_Orders'){
            var UCaaSrt=component.find("FAWMitelrecordType").get("v.value");            
            rectypeId =UCaaSrt; 
        }
        else{
            rectypeId = rt;
        }        
        
        if(objRec && objRec.objectName === 'Account'){
            var createRecordEvent = $A.get("e.force:createRecord");
            if(!objRec){
                createRecordEvent.setParams({
                    "entityApiName": "Order",
                    "recordTypeId":rectypeId
                });
            } else{
                createRecordEvent.setParams({
                    "entityApiName": "Order",
                    "recordTypeId":rectypeId, 
                    "defaultFieldValues":{
                        'AccountId':objRec.acc.Id,
                        'BillingStreet':objRec.acc.BillingStreet,
                        'BillingCity':objRec.acc.BillingCity,
                        'BillingStateCode':objRec.acc.BillingStateCode,
                        'BillingCountry':objRec.acc.BillingCountry,
                        'BillingPostalCode':objRec.acc.BillingPostalCode,
                        'ShippingStreet':objRec.acc.ShippingStreet,
                        'ShippingCity':objRec.acc.ShippingCity,
                        'ShippingStateCode':objRec.acc.ShippingStateCode,
                        'ShippingCountry':objRec.acc.ShippingCountry,
                        'ShippingPostalCode':objRec.acc.ShippingPostalCode,
                    }
                });
            }
            createRecordEvent.fire();
        }else  {
            var createRecordEvent = $A.get("e.force:createRecord");
            if(!objRec){
                createRecordEvent.setParams({
                    "entityApiName": "Order",
                    "recordTypeId":rectypeId
                });
            } else{
                createRecordEvent.setParams({
                    "entityApiName": "Order",
                    "recordTypeId":rectypeId, 
                    "defaultFieldValues":{
                        'OpportunityId' : objRec.opportunityId,
                        'AccountId': objRec.acc.Id,
                        'BillingStreet':objRec.acc.BillingStreet,
                        'BillingCity':objRec.acc.BillingCity,
                        'BillingStateCode':objRec.acc.BillingStateCode,
                        'BillingCountry':objRec.acc.BillingCountry,
                        'BillingPostalCode':objRec.acc.BillingPostalCode,
                        'ShippingStreet':objRec.acc.ShippingStreet,
                        'ShippingCity':objRec.acc.ShippingCity,
                        'ShippingStateCode':objRec.acc.ShippingStateCode,
                        'ShippingCountry':objRec.acc.ShippingCountry,
                        'ShippingPostalCode':objRec.acc.ShippingPostalCode,
                    }
                });
            }
            createRecordEvent.fire();
        }
    }    
    
})