var j$ = jQuery.noConflict();

j$(document).ready(function(){
	j$('#processing_background').hide();
	j$('#processing_content').hide();
	j$('.numeric').numeric();	
});

function show_processing_overlay(){
	j$('#processing_background').show();
	j$('#processing_content').show();
}

function hide_processing_overlay(){
	j$('#processing_background').hide();
	j$('#processing_content').hide();
}

function up_submit_click(){
	show_processing_overlay();
}

function up_submit_complete(){
	hide_processing_overlay();
}