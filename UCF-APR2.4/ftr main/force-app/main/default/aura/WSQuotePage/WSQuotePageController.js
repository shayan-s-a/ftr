({
  myAction: function(component, event, helper) {},

  handleSubmit: function(cmp, event, helper) {
    event.preventDefault(); // stop the form from submitting
    const fields = event.getParam("fields");
    fields.LastName = "My Custom Last Name"; // modify a field
    cmp.find("myRecordForm").submit(fields);
  },

  init: function(cmp, event, helper) {
    var columns = [
      {
        type: "text",
        fieldName: "name",
        label: "Sr#"
      },
      {
        type: "text",
        fieldName: "description",
        label: "Description"
      },
      {
        type: "text",
        fieldName: "quantity",
        label: "Quantity"
      },
      {
        type: "text",
        fieldName: "term",
        label: "Term"
      },
      {
        type: "text",
        fieldName: "listPrice",
        label: "List Price"
      }
    ];
    cmp.set("v.gridColumns", columns);
    var nestedData = [
      {
        name: "1",
        description: "EIA 100M",
        quantity: "1",
        term: "24",
        listPrice: "990",
        _children: [
          {
            name: "1",
            description: "UNI",
            quantity: "1",
            term: "24",
            listPrice: "0"
          },
          {
            name: "1",
            description: "EVC",
            quantity: "1",
            term: "24",
            listPrice: "990"
          }
        ]
      }
    ];
    cmp.set("v.gridData", nestedData);
    var expandedRows = ["1"];
    cmp.set("v.gridExpandedRows", expandedRows);
    var treeGridCmp = cmp.find('treeGrid');
    //treeGridCmp.expandAll();  
    helper.getOpporunityAddressList(cmp, event, helper);
    helper.getQuoteItems(cmp,event,helper);
    //helper.setActiveSections(cmp,event,helper);
  },

  handleClick: function(component, event, helper) {
    component.set("v.openCatalog", false);  
    var addrId = event.getSource().get('v.value');
    component.set("v.addressId",addrId);  
    component.set("v.openCatalog", true);
  },


});