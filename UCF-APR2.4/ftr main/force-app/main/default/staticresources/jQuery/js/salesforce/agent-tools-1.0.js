var j$ = jQuery.noConflict();	
let searchJSFunction;
j$(document).ready(function(){
	j$("#processing_background").hide();
	j$("#processing_content").hide();
	j$("#radio_buttons").buttonset();
	j$("#address_validation").show();
	j$("#address_validation_detail").hide();
	j$("#address_validation_detail2").hide();
	j$("#duedate_calc").hide();
	j$("#provisioning_status").hide();
	
	j$("#address_validation_detail_business").accordion({
		collapsible: true
  });
  j$("#address_validation_detail_residential").accordion({
		collapsible: true
  });
  		
});

function tool_toggle(d){
	if(d=='#address_validation'){
		j$("#address_validation").show();
		j$("#duedate_calc").hide();
		j$("#provisioning_status").hide();
	}
	if(d=='#duedate_calc'){
		j$("#address_validation").hide();
		j$("#duedate_calc").show();
		j$("#provisioning_status").hide();
	}
	if(d=='#provisioning_status'){
		j$("#address_validation").hide();
		j$("#duedate_calc").hide();
		j$("#provisioning_status").show();
	}
}
  
function show_processing_overlay(){
	j$("#processing_background").show();
	j$("#processing_content").show();
}

function hide_processing_overlay(){
	j$("#processing_background").hide();
	j$("#processing_content").hide();
}

function av_submit_click(){
	j$(".av_form_input").each(function(){		
		console.log(j$(this));
		console.log(j$(this).context.id);
  	console.log(j$(this).val());
	});
	show_processing_overlay();
}

function av_search_click(event) {
	console.log(event.target);
	console.log(event.target);
	if (event.target && event.target.dataset && event.target.dataset.address) {
		show_processing_overlay();
		af_processAddressSelected(event.target.dataset.address);
	}
}
function av_search_complete() {
	hide_processing_overlay();
}

function av_predictive_search(event) {
	console.log(event.target.value);
	if (event.target.value && event.target.value.length > 3) {
		clearTimeout(searchJSFunction);
		searchJSFunction = setTimeout(function() {
			af_predictiveSearch(event.target.value);
		}, 200);
	}
	
}

function av_submit_complete(){
	hide_processing_overlay();
}

function ps_submit_click(){
	show_processing_overlay();
}

function ps_submit_complete(){
	hide_processing_overlay();
}

function ddc_submit_click(){
	show_processing_overlay();
}

function ddc_submit_complete(){
	hide_processing_overlay();
}

function av_view_click(){
	j$("#processing_background").show();
	j$("#address_validation_detail").show();
	console.log(j$("#address_validation_detail").is(":visible"));
	if(j$("#address_validation_detail").is(":visible")){
		j$(document.body).click(function(e){
			if(!j$(e.target).closest('#address_validation_detail').length){				
				j$("#processing_background").hide();
				j$("#address_validation_detail").hide();
				j$(document.body).unbind('click');				
			}					
		});
	}		
}