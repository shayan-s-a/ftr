({
    onLoad: function(component, event) {
        console.log('onLoad call');
        //call apex class method
        var action = component.get('c.fetchUser');
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in ListOfUsers attribute on component.
                component.set('v.ListOfUser', response.getReturnValue());
                // set deafult count and select all checkbox value to false on load 
                component.set("v.selectedCount", 0);
                component.find("box3").set("v.value", false);
            }
        });
        $A.enqueueAction(action);
    },
    sendHelper: function(component, event, Ids,RecId) {
        // call the server side controller method 
        // RecId='00678000003vJcCAAU';	
        console.log('<=>11.RecId :'+RecId);
        var action = component.get("c.sendemail");
        // set the 3 params to sendMailMethod method   
        action.setParams({
            'ids': Ids,
            'RecId1': RecId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse == 1)
                {
                   alert('Email send successfully'); 
                }
                console.log('storeResponse :'+storeResponse);
            }            
        });
        $A.enqueueAction(action);
    },
})