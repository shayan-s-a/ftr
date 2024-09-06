({
  doInit: function(component, event, helper) {
    helper.callGenerateOppProducts(component, event, helper);
    component.set("v.col", [
      {
        label: "QUOTE RECORD TYPE",
        fieldName: "quoteRecordType",
        type: "text"
      },
      {
        label: "PRODUCT",
        fieldName: "url",
        type: "url",
        typeAttributes: {
          label: {
            fieldName: "Name"
          },
          target: "_blank"
        }
      },
      { label: "CIRCUIT TYPE", fieldName: "circuitType", type: "text" },
      { label: "SPEED", fieldName: "Speed", type: "text" },
      { label: "QTY", fieldName: "Quantity", type: "text" },
      { label: "TERM", fieldName: "DisplayTerm", type: "text" },
      {
        label: "EXISTING MRR",
        fieldName: "RenewalMRR",
        type: "currency",
        typeAttributes: { currencyCode: "USD" }
      },
      {
        label: "NET NEW MRR",
        fieldName: "NetNewMRR",
        type: "currency",
        typeAttributes: { currencyCode: "USD" }
      },
      {
        label: "NRC",
        fieldName: "NRC",
        type: "currency",
        typeAttributes: { currencyCode: "USD" }
      },
      { label: "SERVICE ADDRESS", fieldName: "ServiceAddress", type: "text" },
      { label: "Z-ADDRESS", fieldName: "ZAddress", type: "text" }
      //{ type: 'ACTION', typeAttributes: { rowActions: actions } }
    ]);
  },

  generateQuickQuote: function(component, event, helper) {
    helper.callWSQuickQuote(component, event, helper);
  },

  generateOppProducts: function(component, event, helper) {
    helper.callGenerateOppProducts(component, event, helper);
  },

  // this function automatic call by aura:waiting event
  showSpinner: function(component, event, helper) {
    // make Spinner attribute true for display loading spinner
    component.set("v.Spinner", true);
  },

  // this function automatic call by aura:doneWaiting event
  hideSpinner: function(component, event, helper) {
    // make Spinner attribute to false for hide loading spinner
    component.set("v.Spinner", false);
  }
});