({
	doInit : function(component, event, helper) {
        window.open("https://portal.connected2fiber.com/#/ftr",'_blank');
		
	},
    
    urlNavigate: function(comp,evt,hlpr){
        var eUrl= $A.get("e.force:navigateToURL"); 
    	eUrl.setParams({   
     	"url": 'https://portal.connected2fiber.com/#/ftr'     
 		});
    	eUrl.fire();        
    }
    
})