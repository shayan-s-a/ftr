({
  helperMethod: function() {},
  openmodal: function(component, event, helper) {
    var cmpTarget = component.find("Modalbox");
    var cmpBack = component.find("Modalbackdrop");
    $A.util.addClass(cmpTarget, "slds-fade-in-open");
    $A.util.addClass(cmpBack, "slds-backdrop--open");
  },

  getProductList: function(component, event, helper) {
    var action = component.get("c.getProductList");
    var addrId = component.get("v.addressId");
    var quoteId = component.get("v.quoteId");
    component.set("v.isLoaded", false);
    component.set("v.cvdError", null);
    component.set("v.showGrid", true);
    action.setParams({ addressId: addrId, quoteId: quoteId });
    action.setCallback(this, function(response) {
      console.log(response.getState());
      console.log(response.getReturnValue());
      component.set("v.isLoaded", true);
      if (response.getState() === "SUCCESS") {
        var jsonData = response.getReturnValue();
        if (jsonData.items != null && jsonData.items.length > 0) {
          component.set("v.cvdsource", jsonData.cvdLookupUsed);
          component.set("v.cvdPriceTier", jsonData.cvdPriceTier);
          console.log(jsonData.cvdLookupUsed);
          var str = JSON.stringify(jsonData.items).replace(
            /children/g,
            "_children"
          );
          //console.log('After Replacing TMP= '+str);
          //Convert back string to JSON object
          var jsonObject = JSON.parse(str);
          component.set("v.gridData", jsonObject);
        } else {
          component.set("v.cvdError", jsonData.error.message);
          component.set("v.showGrid", false);
        }
      }
    });
    $A.enqueueAction(action);
  },

  addtoquote: function(component, row) {
    var action = component.get("c.addToQuote");
    var addrId = component.get("v.addressId");
    var quoteId = component.get("v.quoteId");
    var cvdLookupUsed = component.get("v.cvdsource");
    var cvdPriceTier = component.get("v.cvdPriceTier");
    var successMsg = "Product " + row.parentId + " added to Quote successfully.";  
    action.setParams({
      quoteId: quoteId,
      addressId: addrId,
      productName: row.parentId,
      circuitType : row.productName,  
      term: row.term,
      mrc: row.mrc,
      nrc: row.nrc,
      mrcUsoc: row.mrcUsoc,
      nrcUsoc: row.nrcUsoc,
      cvdSource: cvdLookupUsed,
      qos: row.qos,
      cvdPriceTier: cvdPriceTier,
      cvdPNum: row.pNum,
        cvdratesid: null
    });
    action.setCallback(this, function(response) {
      console.log(response.getState());
      console.log(response.getReturnValue());
      if (response.getState() === "SUCCESS") {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          mode: 'dismissable',  
          type: 'success',
          message: successMsg,//'Product added to Quote successfully.',
          duration: '3000'          
        });
        toastEvent.fire();
        console.log(response.getReturnValue());
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "error",
          message: "Failed to add product to Quote.",
          duration: "3000",
          mode: "dismissable"
        });
        toastEvent.fire();
      }
      //this.collapseAll(component);  
    });
    $A.enqueueAction(action);
  },
    
  collapseAll: function(component) {
   var treeGrid = component.find("treeGrid");
   treeGrid.collapseAll();
  },  

  navigate: function(component, event, helper) {
    var quoteId = component.get("v.quoteId");
    var urlEvent = $A.get("e.force:navigateToURL");
    var urlStr = "/lightning/r/SterlingQuote__c/" + quoteId + "/view";
    urlEvent.setParams({
      url: urlStr
    });
    urlEvent.fire();
  }
});