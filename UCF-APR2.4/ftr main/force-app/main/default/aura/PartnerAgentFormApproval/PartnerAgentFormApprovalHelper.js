({
    submitForm1 : function(component,event) {        
        
        var userprovRec = component.get("v.userProvisioningObj");
        //userprovRec[Company_Name__c] = component.get("v.userProvisioningObj.");
        var masteragent1 = component.get("v.selectedMasterAgent");
        var subagent1 = component.get("v.subAgent");
        var title1 = component.get("v.title1");
        var streetAddress1 = component.get("v.streetAddress");
        var city1 = component.get("v.city");
        var postalCode1 = component.get("v.postalCode");
        var state1 = component.get("v.selectedStateValue");                
        var timezone1 = component.get("v.selectedtimezoneValue");
                console.log('timezone value'+timezone1);
        var action = component.get("c.updateUserProvisioingObj");
 
        
        if(masteragent1 == '-Select One-' || masteragent1 == null || masteragent1 == '' || masteragent1 == undefined ){            
            console.log ("Master Agent is selected - Select One-");                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error!",
                    message: "Please select a value for Master Agent",
                    type: "error",
                    duration : 6000,
               		//	mode : 'dismissible,       	
                });
                toastEvent.fire(); 
                return;
        }
        
        if( state1 == '-Select One-' || state1 == null || state1 == '' || state1 == undefined){            
            console.log ("State is selected - Select One-");                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error!",
                    message: "Please select a State value",
                    type: "error",
                    duration : 6000,
               		//	mode : 'dismissible,       	
                });
                toastEvent.fire(); 
                return;
        }
        
        action.setParams( {
            masterAgent : masteragent1 ,
            subAgent : subagent1 ,
            title : title1 ,
            streetAddress :streetAddress1 ,
            city : city1 ,
            postalCode : postalCode1 ,
            state : state1,
            timezone : timezone1
        });
        //alert('Hi1....')
        console.log('Hi1....');   
        
        action.setCallback(this, function(response){
            //alert('Hi2....');
            console.log('Hi2....');
             console.log(response.getState());
            if(response.getState() === "SUCCESS"){
                
                component.set("v.isAgentFormSubmitted",true);                 
                //alert('Hi3....');
                console.log ("Success");                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success!",
                    message: "Thank you,we will be back to you soon with an email confirming your license has been activated.",
                    type: "success",
                    duration : 6000,
               		//	mode : 'dismissible,       	
                });
                toastEvent.fire();
                //$A.get('e.force:refreshView').fire();
                               
              /*  var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url" : window.location.protocol+'//'+window.location.host+'/FrontierPartnerPortalLightningOne/s/'
                });
                
                var delay = 15000; 
                setTimeout(function(){ 
                    urlEvent.fire();
                }, delay); */
                
            }               
            else if(response.getState() === "ERROR"){                
                //alert('Hi4....');
                console.log('Hi4....');
                var toastEvent =$A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error!",
                    message: "Error in calling server side action",
                    type: "error"
                });
                toastEvent.fire();
                //return; 
            } else {
                cosole.log ("error received");
                //alert('Hi6...');
            }       
            
        });
        $A.enqueueAction(action);
    },
    
    getAgents : function(component,event,helper){
        
        var action= component.get("c.getAgents");
        action.setCallback( this,function(response) {
            //alert('getAgents---');
            if(response.getState() === "SUCCESS"){
                console.log(response.getReturnValue());
                console.log ("Success");    
               if(response.getReturnValue() != '' && response.getReturnValue() != null &&  JSON.stringify(response.getReturnValue()) != '{}'){
                 component.set("v.optionsAgents", response.getReturnValue());                                 
            }  
            }
        });
 		$A.enqueueAction(action);        
    }, 
    
})