({  
   invoke : function(component, event, helper) {
   // Get the url attribute
   var url = component.get("v.URL");   
   var newTab = component.get("v.newTab") != null && component.get("v.newTab") != false && component.get("v.newTab") != undefined ?'_blank':'';  
   
   var redirect = $A.get("e.force:navigateToURL");
   
   // Pass the record ID to the event
   redirect.setParams({
      "url": url + newTab
   });
        
   // Open the record
   redirect.fire();
}})