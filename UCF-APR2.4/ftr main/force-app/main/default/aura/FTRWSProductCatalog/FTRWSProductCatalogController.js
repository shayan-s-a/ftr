({
  myAction: function(component, event, helper) {},

  init: function(cmp, event, helper) {
    var columns = [
      {
        type: "text",
        fieldName: "productName",
        label: "Product Name/Term",
        initialWidth: 200
      },
      {
        type: "currency",
        fieldName: "mrc",
        label: "MRC",
        typeAttributes: { currencyCode: "USD" }
      },
      {
        type: "currency",
        fieldName: "nrc",
        label: "NRC",
        typeAttributes: { currencyCode: "USD" }
      },
      {
        type: "currency",
        fieldName: "linetotal",
        label: "Line Total",
        typeAttributes: { currencyCode: "USD" }
      },

      {
        type: "button",
        fieldName: "action",
        label: "Action",
        typeAttributes: {
          label: "Add to Quote",
          disabled: { fieldName: "disableAddToQuote" }
        },
        initialWidth: 150
      }
    ];

    cmp.set("v.gridColumns", columns);
    //var expandedRows = ["123556,123555"];
    //cmp.set("v.gridExpandedRows", expandedRows);
    helper.openmodal(cmp, event, helper);
    helper.getProductList(cmp, event, helper);
  },

  getState: function(cmp, event, helper) {
    cmp.set("v.currentExpandedRows", "true");
    var treeGridCmp = cmp.find("treeGrid");
    cmp.set(
      "v.currentExpandedRows",
      treeGridCmp.getCurrentExpandedRows().toString()
    );
  },

  closeModal2: function(cmp, event, helper) {
    //cmp.set('',false);
  },

  closeModal: function(component, event, helper) {
    var cmpTarget = component.find("Modalbox");
    var cmpBack = component.find("Modalbackdrop");
    $A.util.removeClass(cmpBack, "slds-backdrop--open");
    $A.util.removeClass(cmpTarget, "slds-fade-in-open");
    helper.navigate(component,event,helper);
  },

  

  onrowaction: function(component, event, helper) {
    var row = event.getParam("row");
    console.log(row.qos);
    console.log(row.mrcUsoc);
    helper.addtoquote(component, row);
  },
 
});