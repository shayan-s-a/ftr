import { LightningElement,track,api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Addons Name', fieldName: 'ChildProductName', sortable: true, searchable: true },
    { label: 'Quantity', fieldName: 'Quantity', sortable: true, searchable: true, type: 'text', editable:true, cellAttributes: { style: { fieldName: 'disable' } } }
];
export default class FtrProductAddOnMNS extends OmniscriptBaseMixin(LightningElement) {
    
    @api addOnsList;
    @track recordsData;
    selectedProducts;
    @api maxRowSelection;
    @api selectedRecords =[];
    columns = columns;
    rowNumberOffset = 0;
    @track draftValues;
    @track errors;
    @track isAnyAddonSelected = true;
    connectedCallback(){   
        this.selectedRecords = [];
        this.addOnsList = Object.assign([],this.omniJsonData['AddOns']);
        //log('this.addOnsList', this.addOnsList);
        console.log('-----',this.addOnsList);
        console.log('--',JSON.stringify(this.addOnsList));
        this.maxRowSelection = this.addOnsList.length;
        this.addOnsList.forEach(element => {
            console.log('ChildProductName '+element['ChildProductName']);
        });
        console.log(this.addOnsList.length);
        this.recordsData = this.getRowDataFromRecordsData();
        //this.isRefreshInProgress = false;
        this.selectedRecords = this.addOnsList.map((element,index) => { 
                if(element['SelectedAddOns']){return index+1}}).filter(element => element != null)
        if(this.selectedRecords.length > 0){
            this.isAnyAddonSelected = true;
        }
        else{
            this.isAnyAddonSelected = false;
        }
        this.omniApplyCallResp({ 'isAddOnSelected': this.isAnyAddonSelected });
        console.log(JSON.stringify(this.recordsData));
       

    }
    showToast(title, message) {
        const event = new ShowToastEvent({
            title: title,
            message:message,
        });
        this.dispatchEvent(event);
    }

    OnSaveQuantity(event){
        this.errors = {};
        let updatedValues = event.detail.draftValues;
        this.draftValues = [];
        let recordsToBeSelected = [];
        let recordsTOBeRemoved = [];
        console.log(JSON.stringify(updatedValues));
        let listForModification = JSON.parse(JSON.stringify(this.addOnsList));
        let validityResult = this.validateQuantity(listForModification,updatedValues);
        if(validityResult.length == 0){
            for(let i= 1; i<= listForModification.length; i++){
                updatedValues.forEach(row => {
                    if(row['id'] == i){
                        if(listForModification[i-1]['ChildProductName'] == 'MNS - Managed Wi-Fi - Outdoor' || listForModification[i-1]['ChildProductName'] == 'MNS - Managed Wi-Fi - Indoor'){
                            listForModification[i-1]['Quantity'] = parseInt(row['Quantity']);
                            listForModification[i-1]['SelectedAddOns'] = true;
                            if(recordsToBeSelected.indexOf(i) === -1){
                                recordsToBeSelected.push(i);
                            }
                            if(parseInt(row['Quantity']) == 0){
                                recordsToBeSelected = recordsToBeSelected.filter((element) => element != i)
                                listForModification[i-1]['SelectedAddOns'] = false;
                                recordsTOBeRemoved.push(i);
                            }
                        }
                    }
                });
            }
            this.omniApplyCallResp({ 'AddOns': listForModification});
            this.omniApplyCallResp({ 'LWC_Error': {'AddOnErrorMessage': '', 'ValidationResult' : true  } });
            this.errors = '';
            this.addOnsList = listForModification;
            this.recordsData = this.getRowDataFromRecordsData();
            //this.isRefreshInProgress = false;
            let concatenated = this.selectedRecords.concat(recordsToBeSelected);
            this.selectedRecords = concatenated.filter((element, position) => {return concatenated.indexOf(element) == position});
            this.selectedRecords = this.selectedRecords.filter(element => !recordsTOBeRemoved.includes(element));
            if(this.selectedRecords.length > 0){
                this.isAnyAddonSelected = true;
            }
            else{
                this.isAnyAddonSelected = false;
            }
            this.omniApplyCallResp({ 'isAddOnSelected': this.isAnyAddonSelected });
            console.log(this.selectedRecords);
        }
        else{
            let errorMessages = ''
            validityResult.forEach(error => {
                errorMessages += error;
            })
            this.errors = errorMessages;
            this.omniApplyCallResp({ 'LWC_Error': {'AddOnErrorMessage': errorMessages, 'ValidationResult' : false  } });
        }
        
    }
    validateQuantity(listForModification,updatedValues){
        let validSum = 0;
        let securityCount  = 0;
        let validity = [];
        for(let i= 0; i< listForModification.length; i++){
            if(listForModification[i]['ChildProductName'] == 'MNS - Managed Wi-Fi - Outdoor' || listForModification[i]['ChildProductName'] == 'MNS - Managed Wi-Fi - Indoor'){
                validSum +=  parseInt(listForModification[i]['Quantity']);
            }
            updatedValues.forEach(row => {
                if(row['id'] == i+1){
                    if(listForModification[i]['ChildProductName'] == 'MNS - Managed Wi-Fi - Outdoor'){
                        validSum += parseInt(row['Quantity']);
                        validSum -= parseInt(listForModification[i]['Quantity']); // add new value substract old value
                    }
                    if(listForModification[i]['ChildProductName'] == 'MNS - Managed Wi-Fi - Indoor'){
                        validSum += parseInt(row['Quantity']);
                        validSum -= parseInt(listForModification[i]['Quantity']); // add new value substract old value
                    }
                    if(listForModification[i]['ChildProductName'] == 'MNS - Managed Security – Advanced' || listForModification[i]['ChildProductName']  == 'MNS - Managed Security - Standard'){
                        securityCount++;
                    }
                }
            });
        }
        if(validSum > 4){
            validity.push('Total AP quantity must be greater then 0 and can\'t exceed 4.');
        }
        if(securityCount == 2){
            validity.push('MNS - Managed Security - Advanced Excludes MNS - Managed Security - Standard.');
        }
        return validity;
    }

    getRowDataFromRecordsData(){
        return this.addOnsList.map((element,index) => { 
            if(element['ChildProductName'] == 'MNS - Managed Wi-Fi - Outdoor' || element['ChildProductName'] == 'MNS - Managed Wi-Fi - Indoor'){
                return {'ChildProductName':element['ChildProductName'],id:index+1,'Quantity': element['Quantity'],"disable":"pointer-events: auto;"}
            }
            else{
                return {'ChildProductName':element['ChildProductName'],id:index+1,'Quantity': element['Quantity'],"disable":"pointer-events: none;"}
            }
        });
    }
    
    handleRowSelection(event) {
        if(true){
                let rowsToBeSelected = [];
                event.preventDefault();
                let selectedAddons = event.detail.selectedRows;
                let listForModification = JSON.parse(JSON.stringify(this.addOnsList));
                let validityResult = this.validateQuantity(listForModification,selectedAddons);
                if(validityResult.length != 0){
                    let errorMessages = ''
                        validityResult.forEach(error => {
                            errorMessages += error;
                        })
                        this.omniApplyCallResp({ 'LWC_Error': {'AddOnErrorMessage': errorMessages, 'ValidationResult' : false  } });
                        this.errors = errorMessages;
                }
                else{
                    for(let i= 1; i<= listForModification.length; i++){
                        let isSelected = false;
                        selectedAddons.forEach(addOn => {
                            if(listForModification[i-1]['ChildProductName'] == addOn['ChildProductName']){
                                listForModification[i-1]['SelectedAddOns'] = true;
                                listForModification[i-1]['Quantity'] = addOn['Quantity'] == 0 ? 1 : addOn['Quantity'];
                                isSelected = true;
                            }
                        });
                        
                        if(isSelected){
                            if(this.selectedRecords.indexOf(i) === -1){
                                this.selectedRecords.push(i);
                            }
                            
                        }
                        else{
                            if(this.selectedRecords.indexOf(i) != -1){
                                 this.selectedRecords = this.selectedRecords.filter((element) => element != i)
                            }
                            listForModification[i-1]['SelectedAddOns'] = false;
                            listForModification[i-1]['Quantity']  = 0;
                        }
                    }
                    console.log(event.detail);
                    this.omniApplyCallResp({ 'AddOns': listForModification });
                    this.addOnsList = listForModification;
                    this.omniApplyCallResp({ 'LWC_Error': {'AddOnErrorMessage': '', 'ValidationResult' : true  } });
                    this.errors = '';
                    event.preventDefault();
                    clearTimeout();
                    //setTimeout(() => {this.isRefreshInProgress = false;}, 10);
                    this.recordsData = this.getRowDataFromRecordsData();
                }
                this.recordsData = this.getRowDataFromRecordsData();
                // let concatenated = this.selectedRecords.concat(rowsToBeSelected);
                // this.selectedRecords = concatenated.filter((element, position) => {return concatenated.indexOf(element) == position});
                // console.log('selected records'+this.selectedRecords);
                event.stopPropagation();
                if(this.selectedRecords.length > 0){
                    this.isAnyAddonSelected = true;
                }
                else{
                    this.isAnyAddonSelected = false;
                }
                this.omniApplyCallResp({ 'isAddOnSelected': this.isAnyAddonSelected });
            }
    }
    
    
}