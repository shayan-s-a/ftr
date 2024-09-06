({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
           // {label: 'Street Number', fieldName: 'Street_Number__c', type: 'text',wrapText: true,initialWidth: 140,},
            //{label: 'Street Name', fieldName: 'Street_Name__c', type: 'text',wrapText: true,initialWidth: 140},
             {label: 'Address', fieldName: 'Address__c', type: 'text',wrapText: true,initialWidth: 140},
            {label: 'Unit', fieldName: 'Unit_Number__c', type: 'text',wrapText: true,},
            {label: 'City', fieldName: 'City__c', type: 'text',wrapText: true,},
            {label: 'State/Province', fieldName: 'State__c', type: 'text',wrapText: true,initialWidth: 130},
            {label: 'Postal Code', fieldName: 'Zip_Code__c', type: 'text',wrapText: true,initialWidth: 120},
           /* {label: 'PNUM', fieldName: 'PNUM__c', type: 'text',wrapText: true,},
            {label: 'Product', fieldName: 'Product__c', type: 'text',wrapText: true,},
            {label: 'Configuration', fieldName: 'Configuration__c', type: 'text',wrapText: true,},
            {label: 'EVC Bandwidth', fieldName: 'EVC_Bandwidth__c', type: 'text',wrapText: true,},
            {label: 'Level of service', fieldName: 'Level_Of_Service__c', type: 'text',wrapText: true,},
            {label: 'Term Aggrement', fieldName: 'Term_Agreement__c', type: 'text',wrapText: true,},
       */
       ]);        
            
            },
            doSave: function(component, event, helper) {
            if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
            } 
            else {
            alert('Please Select a Valid File');
            }
            },
            
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
    
    
    viewRecord :function(component, event, helper){
        var actionName = event.getParam('action').name;
        var row = event.getParam( 'row' );
        var recId = row.Id;
        component.set("v.addressId",recId);
        component.set("v.streetNo",row.Street_Number__c);
        component.set("v.streetName",row.Street_Name__c);
        component.set("v.city",row.City__c);
        component.set("v.state",row.State__c);
        component.set("v.zip",row.Zip_Code__c);
        if(actionName == 'DPI')           
            helper.validateInDPI(component, event, helper);
        if(actionName == 'DSAT')
            helper.validateInDSAT(component, event, helper);
    }
})