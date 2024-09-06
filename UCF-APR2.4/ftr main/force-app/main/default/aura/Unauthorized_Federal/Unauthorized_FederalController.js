({
	doInit : function(component, event, helper) {
        
	},
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
           // record is loaded (render other component which needs record data value)
            
            let urlString = window.location.href;
            let spliturlString = urlString.split(".com");
            var navUrl;
            if(component.find("accRecData").get("v.targetFields").Type == 'NWF Account'){
                navUrl = spliturlString[0]+'.com/apex/Account?Id='+component.get("v.recordId");
                component.find("navigationService").navigate({ 
                    type: "standard__webPage", 
                    attributes: { 
                        url: navUrl
                    } 
                });
            }
            
        }
    }
})