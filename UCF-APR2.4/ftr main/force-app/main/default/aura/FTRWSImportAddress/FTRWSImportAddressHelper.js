({
    MAX_FILE_SIZE: 750000, //Max file size 750kb 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadHelper: function(component, event) {
        // start/show the loading spinner    
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadInChunk(component, file, fileContents);
        });
        
        objFileReader.readAsText(file);
    },
    
    
    uploadInChunk: function(component, file, fileContents) {
        var action = component.get("c.saveFile");
        console.log('@@oppId'+component.get("v.oppId"));
        console.log('@@fileContents@@'+fileContents);
        console.log('@@fileContents'+JSON.stringify(fileContents));
        action.setParams({
            base64Data: JSON.stringify(fileContents)
        });
        
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                const result = response.getReturnValue();
                if (result) {
                    console.log('your File is uploaded successfully');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "message": "Quote Items Updated Successfully"
                    });
                    toastEvent.fire();
                    component.set("v.showLoadingSpinner", false);
                    $A.get("e.force:closeQuickAction").fire();
                    console.log('After FIle upload'+response.getReturnValue()); 
                }  else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "message": "Quote Items Update Failed"
                    });
                    toastEvent.fire();
                }              
                /*component.set('v.data', response.getReturnValue());
                component.set("v.showTable", true);*/
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": "Quote Items Update Failed"
                });
                toastEvent.fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": "Quote Items Update Failed"
                });
                toastEvent.fire();
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    fetchPermission: function(component, file, fileContents) {
        var action = component.get("c.isDealDeskUser");
        
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                const result = response.getReturnValue();
                if (result) {
                    component.set("v.disableUpload", false);
                }      
            } 
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
})