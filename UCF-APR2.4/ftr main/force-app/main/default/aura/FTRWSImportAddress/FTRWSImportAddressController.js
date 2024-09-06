({
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
         
        if (event.getSource().get("v.files").length > 0 ) {
            fileName = event.getSource().get("v.files")[0]['name'];
            
            component.set("v.fileName", fileName);       
            
        }
        if(!fileName.endsWith('.csv')){
            component.set("v.showUpload", true);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "warning",
                "message": "Please upload CSV file Only",
            });
            toastEvent.fire();
        }
        else{
            component.set("v.showUpload", false);
        }
        
    },
    doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } 
        else {
            alert('Please Select a Valid File');
        }
    },
    init : function(component, event, helper){
         helper.fetchPermission(component, event, helper);
    },
})