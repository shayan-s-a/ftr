({
    getData : function(component, event, helper) {
    
        var action = component.get("c.exportAddresses");
        var oppId = component.get("v.recordId");
        
        console.log('@@oppId'+oppId);
        action.setParams({"oppId" : oppId});
        action.setCallback(this, function(response) {
            console.log('Get State :: '+response.getState());
            if(response.getState() === "SUCCESS"){
               var records = response.getReturnValue();
                //console.log('response.getReturnValue ::'+ JSON.stringify(response.getReturnValue()));
                //component.set("v.AddressList",JSON.stringify(response.getReturnValue()));
                var AddressList =response.getReturnValue();
                var newItems=[];
                for (var i=0; i< records.length; i++)
                {
                    var record = records[i];
                    var address;
                    console.log('@@address'+address);
                     var Item = { //Street_Number__c:record.Street_Number__c,
                                 Address__c:record.Address__c,
                                 City__c:record.City__c,
                                 DSAT_Qualified__c:record.DSAT_Qualified__c,
                                 DPI_Qualified__c:record.DPI_Qualified__c,
                                 Street_Name__c:record.Street_Name__c,
                                 Zip_Code__c:record.Zip_Code__c,
                                 State__c:record.State__c,
                                 Name:record.Name,
                                 In_Footprint__c:record.In_Footprint__c,
                                 WireCenter_CLLI__c:record.WireCenter_CLLI__c,
                                 Max_Qos__c:record.Max_Qos__c,
                                 DSAT_Max_Speed__c:record.DSAT_Max_Speed__c,
                                 Comments__c: record.Comments__c,
                         Copper_Qualification__c: record.Copper_Qualification__c,
                         Copper_Tier__c: record.Copper_Tier__c,
                         Fiber_Qualification__c: record.Fiber_Qualification__c,
                         Fiber_Tier__c: record.Fiber_Tier__c,
                         Mrc__c : record.Mrc__c,
                         
                                }
                    //console.log('Item-> ' + JSON.stringify(record));

                    newItems.push(Item);
                    //console.log('newItems-> ' + JSON.stringify(newItems));
                }
                component.set("v.AddressList",AddressList);
                console.log('@AddressList'+JSON.stringify(AddressList));
                this.download(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    
    download : function(component, event, helper) {
        //get the Records list 
        var AddressList = component.get("v.AddressList");
        console.log('@@download Data'+ AddressList);
        // call the helper function which "return" the CSV data as a String   
        var csv = this.convertArrayOfObjectsToCSV(component,AddressList);   
         if (csv == null){
             $A.get("e.force:closeQuickAction").fire();
             return;} 
                // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
	     var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
          hiddenElement.target = '_self'; // 
          hiddenElement.download = 'AddressExport.csv';  // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click(); // using click() js function to download csv file
         
          $A.get("e.force:closeQuickAction").fire();
        } ,
    
	 convertArrayOfObjectsToCSV : function(component,objectRecords){
        
        
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
       
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            console.log('objectRecords :: '+objectRecords);
            return null;
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
 
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        keys = ['Name','Address__c','Street_Name__c','Street_Number__c','City__c','State__c', 'Zip_Code__c','Comments__c','DPI_Qualified__c','DSAT_Qualified__c','In_Footprint__c','WireCenter_CLLI__c','Max_Qos__c','DSAT_Max_Speed__c','Copper_Qualification__c','Copper_Tier__c','Fiber_Qualification__c','Fiber_Tier__c'];
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
                 var Column;
                 if(objectRecords[i][skey] == undefined || objectRecords[i][skey] == "undefined"){
                     Column='';
                 }
                 else{
                     Column = objectRecords[i][skey];
                 }
               csvStringResult += '"'+ Column+'"'; 
               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
       
       // return the CSV formate String 
        return csvStringResult;
         System.debug('csvStringResult :: '+csvStringResult);
        
    }
})