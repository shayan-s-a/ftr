({
	getCities : function(component, event, helper){	
         
        var params = {
          "inputData" : component.get('v.recordId'),
          "searchString": '%'+component.get('v.location')+'%'
        } 
     	component.set('v.searchKey',component.get('v.location'));
        helper.callServer(component,"c.getSuggestions",function(response){
            console.log(response);
            component.set('v.predictions',response);
            //component.set('v.DisplayList',true);
        },params);	
	},
    getCityDetails : function(component, event, helper){		 
 
        var selectedItem = event.currentTarget;
        var placeid = selectedItem.dataset.placeid;
        var retrievedValue = component.get('v.predictions');
        retrievedValue.forEach(function(element){
            console.log(element);
            if(element.Id == placeid){
                component.set('v.location',element.Name);
                component.set('v.targetR',element.Id);
                component.set('v.IsSelectedFromList',true);
            }
        })
        component.set('v.predictions',[]); 
        component.set('v.DisplayList',[]);
    },
    CheckInvalid : function(component, event, helper){
        if(component.get('v.targetR')==null){
            component.set('v.IsSelectedFromList',false);
            //component.set('v.predictions',[]);
            component.set('v.DisplayList',[]);
        }
    
	},
    displayOnFocus: function(component,event,helper){
        console.log(component.get('v.predictions'));
        if(component.get('v.DisplayList').length>0){
            component.set('v.DisplayList',[]);
        }
        else{
            component.set('v.DisplayList',component.get('v.predictions'));
        }
        //component.set('v.DisplayList',component.get('v.predictions'));
	}
})