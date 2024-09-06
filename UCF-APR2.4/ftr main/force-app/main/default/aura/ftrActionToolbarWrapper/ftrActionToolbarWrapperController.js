({
    refreshToolbar : function(component, event, helper) {
        var changeType = event.getParams().changeType;
        console.log('changeType', changeType);
        console.log('ActionToolbarComponent', component.find('ActionToolbarComponent'));
        if (changeType === "ERROR") { /* handle error; do this first! */ 
        } else if (changeType === "LOADED") { /* handle record load */ 
        } else if (changeType === "REMOVED") { /* handle record removal */ 
        } else if (changeType === "CHANGED") { 
            component.set('v.refreshFlag', !component.get('v.refreshFlag'));
            
        }
    }
})