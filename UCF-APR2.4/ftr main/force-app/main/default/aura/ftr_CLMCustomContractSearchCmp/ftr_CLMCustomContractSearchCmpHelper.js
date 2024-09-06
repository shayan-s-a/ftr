({
	getEntityTypePicklistValues : function(component, event, helper) {
		var action = component.get("c.getAgreementTypeFieldValue");
        action.setParams({ObjectApi_name: "Contract", Field_name: "Type_of_Entity__c"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && component.isValid()){
                var entityTypeList = response.getReturnValue();
                var fieldMap = [];
                for(var entityTypeObj in entityTypeList){
                    fieldMap.push({key: entityTypeObj, value: entityTypeList[entityTypeObj]});
                }
                component.set("v.entityTypeMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
	},
    
    getAgreementTypePicklistValues : function(component, event, helper) {
  		var action = component.get("c.getAgreementTypeFieldValue");
        action.setParams({ObjectApi_name: "Contract", Field_name: "Agreement_Type__c"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && component.isValid()){
                var agreementTypeList = response.getReturnValue();
                var fieldMap = [];
                for(var agreementTypeObj in agreementTypeList){
                    //fieldMap.push({key: agreementTypeObj, value: agreementTypeList[agreementTypeObj]});
                    fieldMap.push({key: agreementTypeList[agreementTypeObj], value: agreementTypeObj});
                }
                component.set("v.agreementTypeMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    getScheduleTypePicklistValues : function(component, event, helper) {
        var action = component.get("c.getAgreementTypeFieldValue");
        action.setParams({ObjectApi_name: "Contract", Field_name: "Schedule_Type__c"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && component.isValid()){
                var agreementTypeList = response.getReturnValue();
                var fieldMap = [];
                for(var agreementTypeObj in agreementTypeList){
                    //fieldMap.push({key: agreementTypeObj, value: agreementTypeList[agreementTypeObj]});
                    fieldMap.push({key: agreementTypeList[agreementTypeObj], value: agreementTypeObj});
                }
                component.set("v.scheduleMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    getStatusPicklistValues : function(component, event, helper) {
  		var action = component.get("c.getAgreementTypeFieldValue");
        action.setParams({ObjectApi_name: "Contract", Field_name: "Status"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && component.isValid()){
                var statusList = response.getReturnValue();
                var fieldMap = [];
                for(var statusObj in statusList){
                    fieldMap.push({key: statusObj, value: statusList[statusObj]});
                }
                component.set("v.statusMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    getDocumentStatusPicklistValues : function(component, event, helper) {
  		var action = component.get("c.getAgreementTypeFieldValue");
        action.setParams({ObjectApi_name: "Contract", Field_name: "Document_Status__c"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && component.isValid()){
                var statusList = response.getReturnValue();
                var fieldMap = [];
                for(var statusObj in statusList){
                    fieldMap.push({key: statusObj, value: statusList[statusObj]});
                }
                component.set("v.documentStatusMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    getChannelPicklistValues: function(component, event, helper) {
        var action = component.get("c.getAgreementTypeFieldValue");
        action.setParams({ObjectApi_name: "Contract", Field_name: "Channel_Affiliation__c"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && component.isValid()){
                var statusList = response.getReturnValue();
                var fieldMap = [];
                for(var statusObj in statusList){
                    fieldMap.push({key: statusObj, value: statusList[statusObj]});
                }
                component.set("v.channelMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    getContractTypePicklistValues: function(component, event, helper) {
        var action = component.get("c.getAgreementTypeFieldValue");
        action.setParams({ObjectApi_name: "Contract", Field_name: "MDU_ContractType__c"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && component.isValid()){
                var statusList = response.getReturnValue();
                var fieldMap = [];
                for(var statusObj in statusList){
                    fieldMap.push({key: statusObj, value: statusList[statusObj]});
                }
                component.set("v.contractTypeMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    getAccountBillingStatePicklistValues: function(component, event, helper) {
        var action = component.get("c.getAgreementTypeFieldValue");
        action.setParams({ObjectApi_name: "Account", Field_name: "Legal_State1__c"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && component.isValid()){
                var statusList = response.getReturnValue();
                var fieldMap = [];
                for(var statusObj in statusList){
                    fieldMap.push({key: statusObj, value: statusList[statusObj]});
                }
                component.set("v.accountLegalStateMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
    }
})