({
   init : function(cmp, event, helper) {
      // Figure out which buttons to display
      var availableActions = cmp.get('v.availableActions');
      for (var i = 0; i < availableActions.length; i++) {
         if (availableActions[i] == "PAUSE") {
            cmp.set("v.canPause", true);
         } else if (availableActions[i] == "BACK") {
            cmp.set("v.canBack", true);
         } else if (availableActions[i] == "NEXT") {
            cmp.set("v.canNext", true);
         } else if (availableActions[i] == "CANCEL") {
            cmp.set("v.canCancel", true);             
         }
      }
   },
        
   onButtonPressed: function(cmp, event, helper) {
      // Figure out which action was called
      var actionClicked = event.getSource().getLocalId();
      // Fire that action
       if(actionClicked == "CANCEL"){
           var dismissActionPanel = $A.get("e.force:closeQuickAction");
           dismissActionPanel.fire();
       }
      var navigate = cmp.get('v.navigateFlow');
      navigate(actionClicked);
   }
})