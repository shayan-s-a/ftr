({
	scriptsLoaded: function (component, event, helper) {
		console.debug('Script loaded..');
	},

	doInit: function (component, event, helper) {
		//call apex class method
		var action = component.get('c.getNearbyProspects');
		action.setParams({
			accountId: component.get('v.recordId'),
			distance: component.get('v.distance'),
			units: 'mi',
			queryLimit: 100
		});
		action.setCallback(this, function (response) {
			//store state of response
			var state = response.getState();
			if (state === "SUCCESS") {
				//set response value
				component.set('v.records', response.getReturnValue());

				// when response successfully return from server then apply jQuery dataTable after x milisecond
				setTimeout(function () {
					var $jq = jQuery.noConflict();
					try {
						// dropdown filters
						var table = $jq('#tableId').DataTable({
							/* 
							// column header visibility 
							// dom: 'Bfrtip',
							// colReorder: true,
							// buttons: [
							// 	'colvis'
							// ], */
							// scrollX: true
							responsive: true,
                            initComplete: function () {
								this.api().columns().every(function () {
									var column = this;
									if (column.header().outerText != 'Company Name') {
										var select = $jq('<select class="slds-input filter"><option value=""></option></select>')
										.appendTo($jq(column.footer()).empty())
										.on('change', function () {
											var val = $jq.fn.dataTable.util.escapeRegex(
												$jq(this).val()
											);

											column
												.search(val ? '^' + val + '$' : '', true, false)
												.draw();
										});

									column.data().unique().sort().each(function (d, j) {
										select.append('<option value="' + d + '">' + d + '</option>')
									});
									} else {
										$jq(column.footer()).empty();
									}
								});
							}
						});
						// add lightning class to search filter field with some bottom margin..  
						$jq('div.dataTables_filter input').addClass('slds-input');
						$jq('div.dataTables_filter input').css("marginBottom", "1rem");
						$jq('select[name="tableId_length"]').addClass('slds-input');
						var distanceLabel = $jq('<label/>')
                        .attr({
							for : 'distanceInput'
						})
						.text('Distance from company (miles)');
						var distanceInput = $jq('<input/>')
                        .attr({
							type : 'Number',
							id: 'distanceInput',
							value : component.get('v.distance')
                        })
                        .addClass('slds-input')
						.css('marginRight', '1rem')
						.css("marginBottom", "1rem")
						.css('height', 'fit-content')
						.on('blur', function(e){
							component.set('v.distance', e.target.value);
						});
						var distanceBtn = $jq('<button/>')
                        .text('Search')
                        .attr('title', "Search Nearby Prospects")
						.addClass('slds-button slds-button_brand')
						.css("marginBottom", "1rem")
						.click(function () { 
                            $jq('#tableId-container').addClass('slds-hidden');
							helper.reloadComponent(component, event, helper);
						});
						$jq('#tableId_filter').empty()
						.append(distanceLabel)
						.append(distanceInput)
						.append(distanceBtn);
						// $('.paginate_button').addClass('slds-button slds-button_neutral');
						component.set('v.loading', false);
						$jq('#tableId_filter').css('display','flex');
						$jq('#tableId_filter').css('align-items','baseline');
						$jq('#tableId').removeClass('slds-hidden');
					} catch (exception) {
						console.error(exception);
						var reloadComponent = component.getEvent("reloadComponent");
						reloadComponent.setParams({
							errorMsg : 'An exception has occured. Click below to refresh the view.',
							action : 'error'
						});
						reloadComponent.fire();
					} finally {
						$jq('#tableId-container').removeClass('slds-hidden');
						component.set('v.loading', false);
					}
				}, 0);
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.error(errors[0]);
						var reloadComponent = component.getEvent("reloadComponent");
						reloadComponent.setParams({
							errorMsg : errors[0].message,
							action : 'error'
						});
						reloadComponent.fire();
					}
				} else {
					console.error("Unknown error");
				}
			}
		});
		$A.enqueueAction(action);
	},
})