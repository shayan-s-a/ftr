({
	
    init : function(component,event,helper){
        //alert('init-');
		helper.getAgents(component,event); 
        var timezoneValues = [ {value:'America/Chicago',label:'Central Daylight Time'},
                               {value:'America/New_York',label:'Eastern Daylight Time'},
                   			   {value:'America/Denver',label:'Mountain Daylight Time'},
                               {value:'America/Phoenix',label:'Mountain Standard Time - Phoenix'},
                               {value:'America/Los_Angeles',label:'Pacific Daylight Time'},
                               {value:'GMT',label:'GMT'} ];
        
        component.set("v.timezone",timezoneValues );
        
        var stateValues = [{value : 'Alaska' ,label: 'Alaska' },  { value : 'Arizona' ,label: 'Arizona' },
                           { value : 'Arkansas' ,label: 'Arkansas' }, { value : 'California' ,label: 'California' },
                           { value : 'Colorado' ,label: 'Colorado' }, { value : 'Connecticut' ,label: 'Connecticut' },
                           { value : 'Delaware' ,label: 'Delaware' }, { value : 'Florida' ,label: 'Florida' },
                           { value : 'Georgia' ,label: 'Georgia' },  { value : 'Hawaii' ,label: 'Hawaii' },
                           { value : 'Idaho' ,label: 'Idaho' }, { value : 'Illinois' ,label: 'Illinois' },
                           { value : 'Indiana' ,label: 'Indiana' }, { value : 'Iowa' ,label: 'Iowa' },
                           { value : 'Kansas' ,label: 'Kansas' }, { value : 'Kentucky' ,label: 'Kentucky' },
                           { value : 'Louisiana' ,label: 'Louisiana' }, { value : 'Maine' ,label: 'Maine' },
                           { value : 'Maryland' ,label: 'Maryland' }, { value : 'Massachusetts' ,label: 'Massachusetts' },
                           { value : 'Michigan' ,label: 'Michigan' }, { value : 'Minnesota' ,label: 'Minnesota' },
                           { value : 'Mississippi' ,label: 'Mississippi' }, { value : 'Missouri' ,label: 'Missouri' },
                           { value : 'Montana' ,label: 'Montana' }, { value : 'Nebraska' ,label: 'Nebraska' },
                           { value : 'Nevada' ,label: 'Nevada' }, { value : 'New Hampshire' ,label: 'New Hampshire' },
                           { value : 'New Jersey' ,label: 'New Jersey' },  { value : 'New Mexico' ,label: 'New Mexico' },
                           { value : 'New York' ,label: 'New York' },{ value : 'North Carolina' ,label: 'North Carolina' },
                           { value : 'North Dakota' ,label: 'North Dakota' }, { value : 'Ohio' ,label: 'Ohio' },
                           { value : 'Oklahoma' ,label: 'Oklahoma' }, { value : 'Oregon' ,label: 'Oregon' },
                           { value : 'Pennsylvania' ,label: 'Pennsylvania' }, { value : 'Rhode Island' ,label: 'Rhode Island' },
                           { value : 'South Carolina' ,label: 'South Carolina' }, { value : 'South Dakota' ,label: 'South Dakota' },
                           { value : 'Tennessee' ,label: 'Tennessee' }, { value : 'Texas' ,label: 'Texas' },{ value : 'Utah' ,label: 'Utah' },
                           { value : 'Vermont' ,label: 'Vermont' }, { value : 'Virginia' ,label: 'Virginia' },
                           { value : 'Washington' ,label: 'Washington' }, { value : 'West Virginia' ,label: 'West Virginia' },
                           { value : 'Wisconsin' ,label: 'Wisconsin' }, { value : 'Wyoming' ,label: 'Wyoming' } ];
       component.set("v.states",stateValues );
        
    },
    
    submitForm : function(component, event, helper) {        
		helper.submitForm1(component,event); 
    },

	    
})