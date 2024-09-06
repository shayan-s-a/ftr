({
    helperMethod: function() {},
    getQuoteItems: function(component, event, helper) {
        var action = component.get("c.getQuoteItemLines");
        var quoteId = component.get("v.recordId");
        var addressId = component.get("v.addressId");
        action.setParams({ quoteId: quoteId, addressId: addressId });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                const result = response.getReturnValue();
                console.log('result ==> ', result);
                // Added by Vara - Start
                var rows = result.quoteLineItems;
                component.set('v.allowEdit', result.allowEdit);
                helper.setColumns(component, event, helper);
                
                for(var i = 0; i < rows.length; i++){
                    console.log(rows[i]);
                    var displayMRC=rows[i].Display_MRC__c.split('$')[1];
                    console.log(displayMRC);
                    var displayNRC=rows[i].Display_NRC__c.split('$')[1];
                    console.log(displayNRC);
                    if(Math.abs(rows[i].AdjustedMRC__c-displayMRC)){
                        rows[i].colortext='background slds-text-title_bold';
                    }
                    if(Math.abs(rows[i].AdjustedNRC__c-displayNRC)){
                        rows[i].colortext1='background slds-text-title_bold';
                    }
                    let splicingCost = 0;
                    let guardrailCost = 0;
                    let fiberCost = 0;
                    
                    if (rows[i].Splicing_Cost__c) {
                        splicingCost = rows[i].Splicing_Cost__c;
                    }
                    if (rows[i].Guardrail_Cost__c) {
                        guardrailCost = rows[i].Guardrail_Cost__c;
                    }
                    
                    if (rows[i].Fiber_Cost__c) {
                        fiberCost = rows[i].Fiber_Cost__c;
                    }
                    rows[i].totalOSPCost = fiberCost + splicingCost + guardrailCost;
                    if (rows[i].IRR_Internal_Rate_of_Return__c) {
                        rows[i].IRR_Internal_Rate_of_Return__c = rows[i].IRR_Internal_Rate_of_Return__c / 100;
                    }
                    //Total OSP Cost 
                }                
                component.set("v.data", rows); 
                //Added by Vara- End
            } 
        });
        $A.enqueueAction(action);
    },
    setColumns: function(component, event, helper) {
        let actions = [
            { label: 'Show details', name: 'show_details' },
            { label: 'Delete', name: 'delete' }
        ],
            fetchData = {
                name : 'company.companyName',
                author: 'name.findName',
                published : 'address.state'
            };
        //wrapText: true,
        component.set('v.columns', [
            { label: 'Product Name', fieldName: 'Description__c', type: 'text', wrapText: true, initialWidth: 200},
            { label: 'Circuit Type', fieldName: 'circuitType__c', type: 'text', wrapText: true, initialWidth: 100},
            { label: 'Quantity', fieldName: 'Quantity__c', type: 'text', wrapText: true, initialWidth: 75},
            { label: 'Term', fieldName: 'Display_Term__c', type: 'text', wrapText: true, initialWidth: 75},
            //{ label: 'MRC', fieldName: 'StandardMRC__c', type:'button',  typeAttributes:{value: {fieldName: 'StandardMRC__c'},label: {fieldName: 'StandardMRC__c'},title: {fieldName: 'StandardMRC__c'},variant: 'base',name:'mrcAction', rowActions: actions}, wrapText: true, initialWidth: 100},
            //Added by Vara - Set the cell attribute
            { label: 'MRC', fieldName: 'Display_MRC__c', type:'button',  typeAttributes:{value: {fieldName: 'Display_MRC__c'},label: {fieldName: 'Display_MRC__c'},title: {fieldName: 'Display_MRC__c'},variant: 'base',name:'mrcAction', rowActions: actions},cellAttributes:{class: { fieldName: 'colortext' }}, wrapText: true, initialWidth: 100},            
            { label: 'Adjusted MRC', fieldName: 'AdjustedMRC__c', type: 'currency', wrapText: true, initialWidth: 100},            
            //{ label: 'NRC', fieldName: 'StandardNRC__c', type: 'currency', wrapText: true, initialWidth: 100},
            //Added by Vara - Set the cell attribute
            { label: 'NRC', fieldName: 'Display_NRC__c', type:'button',  typeAttributes:{value: {fieldName: 'Display_NRC__c'},label: {fieldName: 'Display_NRC__c'},title: {fieldName: 'Display_NRC__c'},variant: 'base',name:'nrcAction', rowActions: actions}, cellAttributes:{class: { fieldName: 'colortext1' }}, wrapText: true, initialWidth: 100},
            { label: 'Adjusted NRC', fieldName: 'AdjustedNRC__c', type: 'currency', wrapText: true, initialWidth: 100},
            { label: 'Max QOS', fieldName: 'Max_QOS__c', type: 'text', wrapText: true, initialWidth: 140},
            { label: 'Max Speed', fieldName: 'DSAT_Max_Speed__c', type: 'text', wrapText: true, initialWidth: 75},
            { label: 'HBE Max Speed', fieldName: 'HBE_Max_Speed__c', type: 'text', wrapText: true, initialWidth: 75},
            { label: 'HBE Max QoS', fieldName: 'HBE_Max_Qos__c', type: 'text', wrapText: true, initialWidth: 75},
            { label: 'Copper Tier', fieldName: 'DSAT_Copper_Tier__c', type: 'text', wrapText: true, initialWidth: 75},
            { label: 'Fiber Tier', fieldName: 'DSAT_Fiber_Tier__c', type: 'text', wrapText: true, initialWidth: 75},
            { label: 'BDT Required', fieldName: 'BDT_Required__c', type: 'text', wrapText: true,initialWidth: 75},
            { label: 'CVD Rate Tier', fieldName: 'cvdPriceTier__c', type: 'text', wrapText: true, initialWidth: 75},
            { label: 'CVD Pnum', fieldName: 'PNum__c', type: 'text', wrapText: true, initialWidth: 150},
            { label: 'CVD Source', fieldName: 'cvdratesource__c', type: 'text', wrapText: true, initialWidth: 125},
            /**Wholesale Enhancement Vyshnavi Starts **/
            { label: 'CRT', fieldName: 'CRT__c', type: 'text', wrapText: true, initialWidth: 125, editable: true},
            { label: 'Allocated Total Capex', fieldName: 'Allocated_Total_Capex__c', editable: component.get('v.allowEdit'),type: 'currency',  typeAttributes : {maximumSignificantDigits: '14', maximumFractionDigits: '2'}, wrapText: true, initialWidth: 125},
            { label: 'CIAC', fieldName: 'CIAC__c', type: 'currency', editable: component.get('v.allowEdit'),typeAttributes : {maximumSignificantDigits: '7', maximumFractionDigits: '2'}, initialWidth: 125},
            { label: 'IRR (Internal Rate of Return)', fieldName: 'IRR_Internal_Rate_of_Return__c',editable: component.get('v.allowEdit'), type: 'percent',typeAttributes : {maximumFractionDigits: '1', minimumFractionDigits: '1'}, wrapText: true, initialWidth: 125},
			{ label: 'Fiber Cost', fieldName: 'Fiber_Cost__c',editable: true, type: 'currency',typeAttributes : {maximumSignificantDigits: '7', maximumFractionDigits: '2'}, wrapText: true, initialWidth: 125},
            { label: 'Equipment Cost', fieldName: 'Equipment_Cost__c',editable: true, type: 'currency',typeAttributes : {maximumSignificantDigits: '7', maximumFractionDigits: '2'}, wrapText: true, initialWidth: 125},
            { label: 'Transport Cost', fieldName: 'Total_Cost__c',editable: true, type: 'currency',typeAttributes : {maximumSignificantDigits: '7', maximumFractionDigits: '2'}, wrapText: true, initialWidth: 125},            
            { label: 'Splicing Cost', fieldName: 'Splicing_Cost__c',editable: true, type: 'currency',typeAttributes : {maximumSignificantDigits: '7', maximumFractionDigits: '2'}, wrapText: true, initialWidth: 125},            
            { label: 'Guardrail Cost', fieldName: 'Guardrail_Cost__c',editable: true, type: 'currency',typeAttributes : {maximumSignificantDigits: '14', maximumFractionDigits: '2'}, wrapText: true, initialWidth: 125}, 
			{ label: 'Total OSP Cost', fieldName: 'totalOSPCost',editable: false, type: 'currency',typeAttributes : {maximumSignificantDigits: '14', maximumFractionDigits: '2'}, wrapText: true, initialWidth: 125},             
            /**Wholesale Enhancement Vyshnavi Ends **/
            // added extra
            /*
            {label: 'CRT', fieldName: 'CRT__c', type: 'text'},
            {label: 'CIAC', fieldName: 'CIAC__c', type: 'text'},
            {label: 'NPV (Net Present Value)', fieldName: 'NPV_Net_Present_Value__c', type: 'text'},
            {label: 'IRR (Internal Rate of Return)', fieldName: 'IRR_Internal_Rate_of_Return__c', type: 'text'},
            {label: 'AT&T MRC', fieldName: 'AT_T_MRC__c', type: 'text'},
            {label: 'AT&T Date', fieldName: 'AT_T_Date__c', type: 'text'},
            {label: 'Latency Even Side 2way in ms', fieldName: 'Latency_Even_Side_2way_in_ms__c', type: 'text'},
            {label: 'Latency Odd Side 2way in ms', fieldName: 'Latency_Odd_Side_2way_in_ms__c', type: 'text'},
            {label: 'Direct Lata Summary', fieldName: 'Direct_Lata_Summary__c', type: 'text'},
            {label: 'Direct OSP Total', fieldName: 'Direct_OSP_Total__c', type: 'text'},
            {label: 'Direct BB Total', fieldName: 'Direct_BB_Total__c', type: 'text'},
            {label: 'Direct TR Total', fieldName: 'Direct_TR_Total__c', type: 'text'},
            {label: 'Direct Individual CS Cost', fieldName: 'Direct_Individual_CS_Cost__c', type: 'text'},
            {label: 'Direct Split Lata Summary', fieldName: 'Direct_Split_Lata_Summary__c', type: 'text'},
            {label: 'Collector BDT', fieldName: 'Collector_BDT__c', type: 'text'},
            {label: 'Collector Cost', fieldName: 'Collector_Cost__c', type: 'text'},
            {label: 'Collector Allocation', fieldName: 'Collector_Allocation__c', type: 'text'},
            {label: 'Allocated Total Capex', fieldName: 'Allocated_Total_Capex__c', type: 'text'},
            {label: 'SPOF', fieldName: 'SPOF__c', type: 'text'},
            {label: 'SPOF quantity', fieldName: 'SPOF_quantity__c', type: 'text'},
            {label: 'SRG', fieldName: 'SRG__c', type: 'text'},
            {label: 'estimated build time', fieldName: 'estimated_build_time__c', type: 'text'}, */
            //{label: 'Average MRC', fieldName: 'Average_MRC__c', type: 'text'},
            //{label: 'Average NRC', fieldName: 'Average_NRC__c', type: 'text'},
            
            
            // upto here
            { type: 'action', typeAttributes: {rowActions: actions} }
        ]);
    },
    removeItem: function(cmp, row) {
        var rows = cmp.get("v.data");
        var rowIndex = rows.indexOf(row);
        var itemRecord = rows.splice(rowIndex, 1);
        var action = cmp.get("c.removeItem");
        action.setParams({ itemId: itemRecord[0].Id });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                console.log(response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: "success",
                    message: "Item removed successfully."
                });
                toastEvent.fire();
                console.log(response.getReturnValue());
                cmp.set("v.data", rows);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: "error",
                    message: "Failed to remove Item."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
        //cmp.set("v.data", rows);
    },
    
    navigate: function(Id) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var urlStr = "/lightning/r/SterlingQuoteItem__c/" + Id + "/view";
        urlEvent.setParams({
            url: urlStr
        });
        urlEvent.fire();
    },
    
    showDiscountPopup:function(cmp, row, discType) {
        cmp.set("v.quoteItemRec", row);

        cmp.set("v.recurringType", discType); //mrc or nrc disc type
        cmp.set("v.openAdjustmentModal", true);     
    }
});