({
	doInit : function(component, event, helper) {
		helper.getEntityTypePicklistValues(component, event, helper);
        helper.getAgreementTypePicklistValues(component, event, helper);
        helper.getStatusPicklistValues(component, event, helper);
        helper.getDocumentStatusPicklistValues(component, event, helper);
        helper.getChannelPicklistValues(component, event, helper);
        helper.getContractTypePicklistValues(component, event, helper);
        helper.getAccountBillingStatePicklistValues(component, event, helper);
        helper.getScheduleTypePicklistValues(component, event, helper);
        component.set("v.entityTypeSelected", "");
        component.set("v.agreementTypeSelected", "");
        component.set("v.statusSelected", "");
        component.set("v.documentStatusSelected", "");
        component.set("v.channelSelected", "");
        component.set("v.contractTypeSelected","");
        component.set("v.accountName", "");
        component.set("v.primaryACNA", "");
        component.set("v.secondaryACNA", "");
        component.set("v.legalStateSelected", "");
        component.set("v.scheduleTypeSelected", "");
	},
    
    handleLegalState: function(component, event, helper){
    	var legalState = event.getSource().get("v.value");
        component.set("v.legalStateSelected", legalState);
    },
    
    handleContractType: function(component, event, helper){
    	var contractType = event.getSource().get("v.value");
        component.set("v.contractTypeSelected", contractType);
    },
    
    handleChangeEntityType: function(component, event, helper){
    	var recordTypeName = event.getSource().get("v.value");
        component.set("v.entityTypeSelected", recordTypeName);
    },
    
    handleAgreementTypeChange : function(component, event, helper){
        var agreementTypeSelected = event.getSource().get("v.value");
        component.set("v.agreementTypeSelected", agreementTypeSelected);
    },
    
    handleStatusChange: function(component, event, helper){
        var statusSelected = event.getSource().get("v.value");
        component.set("v.statusSelected", statusSelected);
    },
    
    handleDocumentStatusChange: function(component, event, helper){
        var documentStatusSelected = event.getSource().get("v.value");
        component.set("v.documentStatusSelected", documentStatusSelected);
    },
    
    handleChannelChange: function(component, event, helper){
    	var channelSelected = event.getSource().get("v.value");
     	component.set("v.channelSelected", channelSelected);
    },
    
    handleScheduleType: function(component, event, helper){
        var scheduleTypeSelected = event.getSource().get("v.value");
        component.set("v.scheduleTypeSelected", scheduleTypeSelected);
    },
    
    searchContracts: function(component, event, helper){
        var queryStr = '';
        var contentText = component.find("textSearch").get("v.value");
        //var documentText = component.find("documentSearch").get("v.value");
        var entityName = component.get("v.entityTypeSelected");
        var agreementTypeSelected = component.get("v.agreementTypeSelected");
        var statusSelected = component.get("v.statusSelected");
        var documentStatusSelected = component.get("v.documentStatusSelected");
        var channelSelected = component.get("v.channelSelected");
        var scheduleType = component.get("v.scheduleTypeSelected");
        //var legalCity = component.find("legalCity").get("v.value");
        //var legalZipCode = component.find("legalZipCode").get("v.value");
        var accountName = component.find("accountName").get("v.value");
        var accountPrimaryACNA = component.find("accountPrimaryACNA").get("v.value");
        var accountSecondaryACNA = component.find("accountSecondaryACNA").get("v.value");
        var contractType = component.find("contractTypePicklist").get("v.value");
        var legalState = component.find("legalStatePicklist").get("v.value");
        var action = component.get("c.getContractList");
        action.setParams({"accountName":accountName,"contractType":contractType,"entityName": entityName, "agreementType": agreementTypeSelected, 
                          "scheduleType":scheduleType, "statusSelected": statusSelected, "docStatus": documentStatusSelected, 
                          "channelSelected": channelSelected, "approverName": null, "legalState": legalState, "contentText": contentText,
                          "accountPrimaryACNA": accountPrimaryACNA, "accountSecondaryACNA":accountSecondaryACNA});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && component.isValid()){
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                component.set("v.searchResult", storeResponse.contractList);
                var initialRecordCount = storeResponse.originalContractListSize;
                var limitCount = storeResponse.limitCount;
                
                if (initialRecordCount != null && limitCount != null && initialRecordCount > limitCount){
                	var message = 'Your search criteria returned ' + initialRecordCount + ' records, but is limited to only ' + limitCount + ' records. \nPlease filter your search parametres';
                    var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
        				"title": "Success!",
                    	"type": "warning",
        				"message": message
    				});
    				toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    clearResult: function(component, event, helper){
    	component.set("v.searchResult", null);  
        component.find("entityTypePicklist").set("v.value", null);
        component.set("v.entityTypeSelected", null);
        
        component.find("agreementTypePicklist").set("v.value", null);
        component.set("v.agreementTypeSelected", null);
        
        component.find("scheduleTypePicklist").set("v.value", null);
        component.set("v.scheduleTypeSelected", null);
        
        component.find("statusPicklist").set("v.value", null);
        component.set("v.statusSelected", null);
        
        component.find("documentStatusPicklist").set("v.value", null);
        component.set("v.documentStatusSelected", null);
        
        component.find("accountName").set("v.value", null);
        component.find("accountPrimaryACNA").set("v.value", null);
        component.find("accountSecondaryACNA").set("v.value", null);
        
        component.find("legalStatePicklist").set("v.value", null);
        component.set("v.legalStateSelected", null);
        
        component.find("textSearch").set("v.value", null);
        //component.find("documentSearch").set("v.value", null);
    },
    
    searchSOSL: function(component, event, helper){
        var soslText = component.find("textSearch").get("v.value");
        var action = component.get("c.getContractDocumentList");
        action.setParams({searchword: soslText});
        action.setCallback(this, function(response){
        	var state = response.getState();
            if (state === "SUCCESS" && component.isValid()){
                var returnValue = response.getReturnValue();
      			component.set("v.contractList", returnValue);          
            }
        });
        $A.enqueueAction(action);
    },
    
    clearSOSLSearch: function(component, event, helper){
        component.find("textSearch").set("v.value", null);
        component.set("v.contractList", null);
    },
    
    documentSOSL: function(component, event, helper){
        var soslText = component.find("documentSearch").get("v.value");
        var action = component.get("c.getContractAgreementList");
        action.setParams({searchword: soslText});
        action.setCallback(this, function(response){
        	var state = response.getState();
            if (state === "SUCCESS" && component.isValid()){
                var returnValue = response.getReturnValue();
      			component.set("v.agreementList", returnValue);          
            }
        });
        $A.enqueueAction(action);        
    },
    
    clearDocumentSearch: function(component, event, helper){
        component.find("documentSearch").set("v.value", null);
        component.set("v.agreementList", null);
    },
    
})