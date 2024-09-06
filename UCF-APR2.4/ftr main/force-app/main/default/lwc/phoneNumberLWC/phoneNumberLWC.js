import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import Install_type_Picklist from "@salesforce/schema/ftr_DID_Number_Details__c.Ucf_Install_Type__c";
import Number_Use_Picklist from "@salesforce/schema/ftr_DID_Number_Details__c.Ucf_Number_Use__c";
import queryAccounts from '@salesforce/apex/FetchData.queryAccounts';
import queryAccounts2 from '@salesforce/apex/FetchData.queryAccounts2';
import ftrDIDNumberDetails from '@salesforce/apex/FetchData.ftrDIDNumberDetails';
import updateftrDIDNumberDetails from '@salesforce/apex/FetchData.updateftrDIDNumberDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import loadCSVData from '@salesforce/apex/FetchData.loadCSVData';
import getDIDNumbersData from '@salesforce/apex/FetchData.getDIDNumbersData';
import deleteSelectedDIDNumbers from '@salesforce/apex/FetchData.deleteSelectedDIDNumbers';
import { refreshApex } from '@salesforce/apex';
import checkDID from '@salesforce/apex/FetchData.checkDID';
import isTranslationUser from '@salesforce/apex/PmEnrichmentController.isTranslationUser';
import FtrUcfDIDLocations from '@salesforce/apex/FetchData.FtrUcfDIDLocations';
import getServiceAccountOptions from '@salesforce/apex/FetchData.getServiceAccountOptions';
import updateDidLocationsBulk from '@salesforce/apex/FetchData.updateDidLocationsBulk';
import deleteGroupMembers from '@salesforce/apex/FetchData.deleteGroupMembers';
import updateDidLocationsNXX from '@salesforce/apex/FetchData.updateDidLocationsNXX';
import updateDIDNumbersNXX from '@salesforce/apex/FetchData.updateDIDNumbersNXX';
import getOnloadDataforRbandCombo from '@salesforce/apex/FetchData.getOnloadDataforRbandCombo';
import FtrUcfVoipQualifications from '@salesforce/apex/FetchData.ftrNPANXXPhoneNumberDetails';
import getGroupMembers from '@salesforce/apex/FetchData.getGroupMembers';
import getMLHGMembers from '@salesforce/apex/FetchData.getMLHGMembers';
import deleteMLHGMembers from '@salesforce/apex/FetchData.deleteMLHGMembers';


//import getCurrentOrderStage from  '@salesforce/apex/PmEnrichmentController.getOrderStage';





 





const columns= [
    { label: 'Schedule Name', fieldName: 'Name', type: 'text' ,editable: true},  
    { label: '',  type: "button", typeAttributes: { label: '', name: 'Delete', title: '',  disabled: false,   iconPosition: 'left',  iconName:'utility:delete' }  }
];

const columnsEI = [
    { label: 'Phone Number', fieldName: 'Id', type: 'text' },
    { label: 'Extension', fieldName: 'Name', type: 'text' },
    { label: 'User Name', fieldName: 'BillingCity', type: 'text' },
    { label: 'Email', fieldName: 'Account_Owner_Email__c', type: 'text'},
    { label: 'User Admin', fieldName: 'Account_Channel__c', type: 'text' },
    { label: 'Department', fieldName: 'vlocity_cmt__Status__c', type: 'text' },
    { label: 'Outbound Caller ID', fieldName: 'Agent_Fax_Number__c', type: 'text' },
];
export default class PhoneNumberLWC extends LightningElement {
    @api recordId;
    @api isnetworktranslation;
    showLoader = false;
    accounts;
    accounts2;
    error;
    test;
    value = '';
    @track GetMembers=[] ;
    @track GetMLHGMembers=[] ;

    @track showDualListboxModal = false;
    @track selectedItems = [];
    @track selectedItemsCount = 0;
    @track selectedOption = 'Employee Info';
    @track employeeinfo = '';  
    @track deviceinfo = '';
    @track nine11info = '';
    @track licenseinfo = '';
    @track accountList = [];
    @track draftValues = [];
     @track phoneNumber;
    @track errorMessage;
      @track didNumber;
    @track ucfVoipQualification;
    @track isComboboxDisabled = true;
    @track selectAll = false;
    @track rSucess = false;
    @track fileSucess = false;
     @track selectedPhoneNumbers = [];
     @track ftrDIDNumberDetails = [];
     @track didNumberDetailOnload = [];
     @track custExt;
    extFlag = false;
    @track serviceAccounts = []; // Initialize as an empty array
    draftValuesNXX = [];
     wiredftrDIDNumberResult;   
        @track userType ='';
  @track isTranslation;
  @track isReadOnly;
  @track DIDList=[];
     allRecordIds = [];
      wiredResult;
      CostumizeExtension=false;
      extChangedFlag = false;
      ExtensionLength;
      DIDLocations=[];
      @track VoipQualifications=[];
      LocationOptions = [];  
      SelectedLocationFromAdd='';
    CurrentCarrier='';  
       @track serviceAccounts;
       selectedServiceAccountId;
    @track sortField = 'DIDNumber__c'; // Default sort field
    @track sortDirection = 'asc'; // Default sort direction
    Install_Type;
    Number_Use;
    SelectedInstallType;
    @track dualListboxOptions = [
        { label: 'Option 1', value: 'Option1' },
        { label: 'Option 2', value: 'Option2' },
    ];
    @track wiredRecords;
    SelectedNumberUse;
    fieldChangeCount=0;
    required=false;
    required2=false;
    //@track isOrderInProgressOrCompleted = false;
    // for add number using manual process start

   @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: Install_type_Picklist })
   GetInstallType({error,data}){
       if (data) {
        console.log('Install Type=='+JSON.stringify(data));
        this.Install_Type=data.values;
        console.log('Install Type'+JSON.stringify(data.values));
    }
    if (error) {
        console.log('error',error);
    }
   };
   @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: Number_Use_Picklist })
   GetNumberUsePicklistValues({error,data}){
       if (data) {
        console.log('Number Use=='+JSON.stringify(data));
        this.Number_Use=data.values;
        console.log('Number Use'+JSON.stringify(data.values));
    }
    if (error) {
        console.log('error',error);
    }
   };

     handleDidChange(event) {
        this.didNumber = event.target.value;
    }
     handleCCChange(event) {
        this.CurrentCarrier = event.target.value;
    }
    handleQualificationChange(event) {
        this.ucfVoipQualification = event.target.value;
       
    } 
    handleDIDAddLocationChange(event) {
        //alert(event.target.value);
        this.SelectedLocationFromAdd = event.target.value;
    } 

    getServiceAccountIdByName(name) {
    const account = this.serviceAccounts.find(acc => acc.label === name);
    return account ? account.value : null;
}
        
    handleAdd2() {
        // const orderId = this.recordId;
          //  alert(orderId);
        if(this.didNumber && this.ucfVoipQualification) {
           
            checkDID({ did: this.didNumber, qualification: this.ucfVoipQualification, recordId: orderId})
            .then(result => {
                // Display a success toast with the message returned from the server
                const toast = new ShowToastEvent({
                    title: 'Success',
                    message: 'Sucess!',
                    variant: 'Success'
                });
                this.dispatchEvent(toast);
                this.didNumber = '';
                this.ucfVoipQualification = '';
                this.CurrentCarrier='';
            })
            .catch(error => {
                // Handle the error, like displaying a toast
                const toast = new ShowToastEvent({
                    title: 'Error',
                    message: 'Could not create new DID number. please contact system administrator',
                    variant: 'error'
                });
                this.dispatchEvent(toast);
            });
        } else {
            const toast = new ShowToastEvent({
                title: 'Error',
                message: 'Both DID and Qualification are required!',
                variant: 'error'
            });
            this.dispatchEvent(toast);
        }
    }

  handleSelectAll(event) {
    this.selectAll = event.target.checked;

    this.ftrDIDNumberDetails = this.ftrDIDNumberDetails.map(record => {
        record.isSelected = this.selectAll;
        return record;
    });


    if (this.selectAll) {
        this.selectedPhoneNumbers = this.ftrDIDNumberDetails.map(record => record.Id);
        //alert('hello: '+ this.selectedPhoneNumbers)
    } else {
        this.selectedPhoneNumbers = [];
    }

     // alert('hello 2: '+ this.selectedPhoneNumbers)

    console.log('Selected Phone Numbers:', this.selectedPhoneNumbers);
}

handleIndividualCheckboxChange(event) {
    const recordId = event.target.dataset.id; // Assuming you've set data-id={record.Id} in the template for checkboxes
    const isChecked = event.target.checked;

    let updatedSelectedPhoneNumbers = [...this.selectedPhoneNumbers];

    if (isChecked && !updatedSelectedPhoneNumbers.includes(recordId)) {
        updatedSelectedPhoneNumbers.push(recordId);
    } else if (!isChecked) {
        updatedSelectedPhoneNumbers = updatedSelectedPhoneNumbers.filter(id => id !== recordId);
    }

    if (updatedSelectedPhoneNumbers.length === this.ftrDIDNumberDetails.length) {
        this.selectAll = true;
    } else {
        this.selectAll = false;
    }

    this.selectedPhoneNumbers = updatedSelectedPhoneNumbers;
     // alert('hello 3: '+ this.selectedPhoneNumbers)

    console.log('Selected Phone Numbers:', this.selectedPhoneNumbers);
}

@wire(isTranslationUser, { OrderId: '$recordId' })
    wiredgetIsAdmin({ error, data }) {
        console.log('in user '+ data);
        if (data) {
            this.userType = data;
          // alert(this.userType);
          if(this.userType == 'Translation')
          {
              this.isTranslation = true;
              this.isReadOnly = false;
          }
          else if(this.userType == 'Non-Translation')
          {
              this.isTranslation = false;
              this.isReadOnly = true;
          }
          else if(this.userType == 'None')
          {
              this.isTranslation = false;
              this.isReadOnly = false;
          }
         // alert('Type '+ this.userType);
        // alert('Ro '+ this.isReadOnly);
       // alert('Tra '+ this.isTranslation);
        } else if (error) {
            console.error("Error determining user profile:", error);
        }
    } 


handleDeleteRecords() {
    if (this.selectedPhoneNumbers.length === 0) {
        this.showToast('No Selection', 'Please select records to delete.', 'warning');
        return;
    }

    if (confirm('Are you sure you want to delete the selected records?')) {
        deleteSelectedDIDNumbers({ selectedIds: this.selectedPhoneNumbers })
            .then(() => {
                  // Filter out the deleted records
        this.ftrDIDNumberDetails = this.ftrDIDNumberDetails.filter(
            record => !this.selectedPhoneNumbers.includes(record.Id)
        );
                this.showToast('Success', 'Records deleted successfully.', 'success');
                this.selectedPhoneNumbers = []; // Clear selection
                //return refreshApex(this.wiredftrDIDNumberResult);  // Refresh the data
            })
            .then(() => {
                // Any additional processing after data is refreshed (e.g., updating UI)
            })
            .catch(error => {
                this.showToast('Error', 'Error deleting records. ' + error.message, 'error');
            });
    }
    this.FtrVoipQualifications();
}
showToast(title, message, variant) {
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
}
validateInputForNumber(event) {
        // alert('1')
        // Regular expression to allow only digits
        const regex = new RegExp("^[0-9]*$");
    
        // Get the key pressed by the user
        const key = String.fromCharCode(!event.charCode ? event.which : event.charCode);
    
        // Prevent input if the key pressed is not a digit
        if (!regex.test(key)) {
            event.preventDefault();
            return false;
        }
    }


    // checkbox select all work

    //checkbox select all work end
    //osama
  get acceptedFormats() {
        return ['.csv'];
       // return ['.xlsx'];
       }

    @track contentDocumentId;
    @track recordCount;
  

async connectedCallback() {
    //alert('hi');
    this.showLoader=true;
    await this.fetchServiceAccountOptions();
    this.FtrDIDLocations();
    
    this.fetchDidNumberDetails();
    this.ftrDIDNumberDetail();
    this.FtrVoipQualifications();
    this.getGroupMember();
    this.getMLHGMember();
    

    //this.getOrderStage(); 
}




getMLHGMember()
{
    getMLHGMembers({ recordId: this.recordId })
    .then(result => {
        if (result) {
            this.GetMLHGMembers = result.map(member => ({
                id: member.Id,
                didNumberDetails: member.DID_Number_Details__c
            }));
            
          // alert(JSON.stringify(this.GetMLHGMembers));
        }
    })
    .catch(error => {
        // Handle error (if any)
        console.error('Error fetching group members:', error);
    });
}

getGroupMember()
    {
        getGroupMembers({ recordId: this.recordId })
        .then(result => {
            if (result) {
                this.GetMembers = result.map(member => ({
                    id: member.Id,
                    didNumberDetails: member.DID_Number_Details__c
                }));
                
               // alert(JSON.stringify(this.GetMembers));
            }
        })
        .catch(error => {
            // Handle error (if any)
            console.error('Error fetching group members:', error);
        });
    }


getOrderStage()
    {
        getCurrentOrderStage({recordId: this.recordId}).then(result=>{
            if(result != undefined && result != null){
            if(result == true)
            {
                this.isOrderInProgressOrCompleted = true;
            }   
            }
        }).catch(error=>{
            console.log(' Current Order Stage Error', error);
            });
    }

ftrDIDNumberDetail() {
    //alert('testing DID');
    ftrDIDNumberDetails({recordId:this.recordId})
    .then(result => {
        
        if(result)
        {
            
        this.ftrDIDNumberDetails = result.map(record => ({
            ...record,
            isSelected: false,
            LocationPicklistOptions: this.LocationOptions,
            serviceName: record.UCFNameValidation__c,
            comboBoxValue: this.getServiceAccountIdByName(record.DIDLocationDetailsId__r.UCFNameValidation__c),
            SelectedNumberUse: record.Ucf_Number_Use__c !== '' ? record.Ucf_Number_Use__c : 'DID',
            InstallType : record.Ucf_Install_Type__c
        }));
        
        this.allRecordIds = this.ftrDIDNumberDetails.map(record => record.Id);
        console.log('allrecords'+JSON.stringify(this.allRecordIds));
        this.showLoader=false;
        //alert('zainab 3'+ JSON.stringify(this.ftrDIDNumberDetails));
      
    }
    });
} 
/*fetchServiceAccountOptions() {
    //alert('testing Location');
    getServiceAccountOptions({ recordId: this.recordId })
        .then(result => {
            this.serviceAccounts = result.map(account => ({
                label: account['Name'],
                value: account['Id']
            }));
            //alert('Service Accounts Loaded:'+ JSON.stringify(this.serviceAccounts));
        })
        .catch(error => {
            console.error('Error fetching service accounts:', error);
        });
}*/


fetchServiceAccountOptions() {
    return getServiceAccountOptions({ recordId: this.recordId })
        .then(result => {
            this.serviceAccounts = result.map(account => ({
                label: account['Name'],
                value: account['Id']
            }));
            // Optional: return a value or resolve the promise here if needed
        })
        .catch(error => {
            console.error('Error fetching service accounts:', error);
            // Optional: throw the error to be caught by the caller
            throw error;
        });
}


  get notExtFlag() {
        return !this.extFlag;
        
    }


fetchDidNumberDetails() {
        getOnloadDataforRbandCombo({ recordId: this.recordId })
            .then(result => {
                if (result) {
                    console.log(JSON.stringify(result));
                  //  alert(JSON.stringify(result[0].Ucf_Extension_Lenght__c));
                   //  alert(JSON.stringify(result[0].Ucf_Customize_Extension__c));
                    this.custExt = result[0].Ucf_Extension_Lenght__c;
                    this.ExtensionLength =  result[0].Ucf_Extension_Lenght__c;
                    this.extFlag = Boolean(result[0].Ucf_Customize_Extension__c); 
                    this.extChangedFlag =Boolean(result[0].Ucf_Customize_Extension__c);
                    //alert('ex ' +this.custExt);
                    // alert('flag'+ this.extFlag);
                    console.log('phoneee '+ this.ExtensionLength);
                    console.log('phoneee Flag '+ this.extChangedFlag);
                }

                //alert('zainab 2', JSON.stringify(this.custExt));

                
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }



 getServiceAccountIdByName(name) {
    if (Array.isArray(this.serviceAccounts)) {
        const account = this.serviceAccounts.find(acc => acc.label === name);
        return account ? account.value : null;
    }
    return null;
}


FtrDIDLocations(){
    FtrUcfDIDLocations({OrderId:this.recordId})
    .then(result => {
        
        if (result) {
            
            this.LocationOptions=result.map(item => ({
                    
                        label: item.UCFNameValidation__c,
                        value: item.id    
            }));

            this.FtrUcfDIDLocations = result.map(record => ({
                ...record
            }));
        }

        //alert('zainab 1', JSON.stringify(this.LocationOptions));
        
    });
    //alert(JSON.stringify(this.LocationOptions));
}
/*
FtrVoipQualifications(){
    FtrUcfVoipQualifications({OrderId:this.recordId})
    .then(result => {
        
        if (result) {
            
            this.VoipQualifications = result.map(record => ({
                ...record,
                Local_Routing_Number__c : record.Local_Routing_Number__c || ''
            }));
        }
        
    });
}
*/
/*** Changing in NPA and NXX table in Phone Number to get data from Phone Number tab but keeping the above function in case */
FtrVoipQualifications(){
    console.log('OrderID'+this.recordId);
    FtrUcfVoipQualifications({orderId:this.recordId})
    .then(result => {
        if (result) {
            
            this.VoipQualifications = result.map(record => ({
                ...record,
                Local_Routing_Number__c : record.Local_Routing_Number__c || ''
            }));
        }
        
    });
}



    @wire(queryAccounts2)
    wiredAccounts2({ error, data }) {
        if (data) {
          
           // this.accounts2 = data;
           this.accounts2 = data.map(account => ({
            ...account,
            selectedItems: [], 
        }));
        
        } else if (error) {
            this.error = error;
        }
    }
    deleteItem(event) {
       
        console.log('Delete button clicked');
        const abc = event.currentTarget.dataset;
      
        const itemId = event.currentTarget.dataset.itemId;
        const itemIndex = event.currentTarget.dataset.itemIndex;
        
        console.log('Item ID:', itemId);
        console.log('Index:', itemIndex);
        const updatedAccounts = [...this.accounts];

        if (itemIndex !== undefined) {
            updatedAccounts.splice(itemIndex, 1); 
            this.accounts = updatedAccounts; 
        }
        

    }

    get columns() {
        return columns;
    }

    get options1() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    get options2() {
        return [
            { label: '3 digits', value: '3' },
            { label: '4 digits', value: '4' },
            { label: '5 digits', value: '5' },
            { label: '7 digits', value: '7' },
        ];
    }

sortPhoneNumInfo(event) {

    this.sortColumn = event.currentTarget.dataset.fieldName;
    
    this.sortDirection = this.sortColumn === this.sortColumn && this.sortDirection === 'asc' ? 'desc' : 'asc';
    this.sortData();
}
sortData() {

    const field = this.sortColumn;
    const reverse = this.sortDirection === 'desc' ? -1 : 1;
    this.ftrDIDNumberDetails = [...this.ftrDIDNumberDetails.sort((a, b) => (a[field] > b[field] ? 1 : -1) * reverse)];
    
    
}
handleRadioChange(event) {
        this.isComboboxDisabled = event.target.value !== 'true';
       
        if(event.target.value == 'true')
        {
            console.log('in true');
            console.log('radio change ' + event.target.value);
            this.CostumizeExtension=true;
             this.extChangedFlag = true;
             this.extFlag = true;
          
        }
        else if(event.target.value == 'false')
        {
            console.log('radio change '  + event.target.value);
           // this.CostumizeExtension=true;
           this.extChangedFlag = false;
           this.extFlag = false;
          
        }
        
    }
 

    handleChange(event) {
        this.value = event.detail.value;
        this.ExtensionLength=event.detail.value;
        console.log('length: '+this.ExtensionLength );
        this.fieldChangeCount++;
        this.notifyInputChange(this.fieldChangeCount);
        
        
    }

    handleInputChange(event) {
    this.fieldChangeCount++;
    console.log(this.fieldChangeCount);
    this.notifyInputChange(this.fieldChangeCount);
    const recordId = event.target.dataset.recordId;
    const fieldName = event.target.dataset.fieldName;
    const newValue = event.target.value;
    
    const index = this.ftrDIDNumberDetails.findIndex(ftrDIDNumberDetail => ftrDIDNumberDetail.Id === recordId);
    if (index !== -1) {
        // Update the field value in the account data
        this.ftrDIDNumberDetails[index][fieldName] = newValue;
         console.log(newValue);
        // Create an object to store the updated data
        const updatedData = {
            Id: recordId,
            [fieldName]: newValue
        };

        // Check if the record is already in draftValues and update it
        const draftIndex = this.draftValues.findIndex(draft => draft.Id === recordId);
        if (draftIndex !== -1) {
            this.draftValues[draftIndex][fieldName] = newValue;
        } else {
            // If the record is not in draftValues, add it
            this.draftValues.push(updatedData);
        }
        console.log(updatedData);
        //alert(JSON.stringify(this.draftValues));

        this.DIDList = this.draftValues.map(draft => draft.Id);
    
        
        console.log(this.DIDList);
    }
}
handleInputChangeMXX(event) {
    
    const recordId = event.target.dataset.recordId;
    const fieldName = event.target.dataset.fieldName;
    const newValue = event.target.value;
    
    const index = this.VoipQualifications.findIndex(VoipQualifications => VoipQualifications.Id === recordId);
    if (index !== -1) {
        // Update the field value in the account data
        this.VoipQualifications[index][fieldName] = newValue;
         console.log(newValue);
        // Create an object to store the updated data
        const updatedData = {
            Id: recordId,
            [fieldName]: newValue
        };

        // Check if the record is already in draftValues and update it
        const draftIndex = this.draftValuesNXX.findIndex(draft => draft.Id === recordId);
        if (draftIndex !== -1) {
            this.draftValuesNXX[draftIndex][fieldName] = newValue;
        } else {
            // If the record is not in draftValues, add it
            this.draftValuesNXX.push(updatedData);
        }
        
    }
}
handleCancel()
{ 

    this.ftrDIDNumberDetails = [];
    this.didNumber = "";
    this.ucfVoipQualification = "";
    this.SelectedInstallType="";
    this.CurrentCarrier="";
    console.log('check if id is fetching ' + this.template.querySelector('[data-recid="locationOptions"]').value);
    this.template.querySelector('[data-recid="locationOptions"]').value = "";
    //this.fetchServiceAccountOptions();
    this.ftrDIDNumberDetail();
    this.fieldChangeCount=0;
    this.notifyInputChange(this.fieldChangeCount);
}


 handleInstallTypeSelect(event) {
        this.SelectedInstallType = event.target.value;
    }
    handlePhoneChange(event) {
        this.phoneNumber = event.target.value;
    }

 handleAdd() {
    if(this.didNumber && this.CurrentCarrier && this.SelectedInstallType && this.ucfVoipQualification && this.SelectedLocationFromAdd) {
        
        const isDuplicate = this.ftrDIDNumberDetails.some(detail =>
                detail.DIDNumber__c === this.didNumber
            );

            if (isDuplicate) {
                // Alert the user that the webinar value is already selected
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Duplicate DID Number',
                        message: 'Please enter an unique DID Number',
                        variant: 'error'
                    })
                );
                return;
            }

            else if(this.didNumber.length < 10){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Length Error',
                        message: 'Phone Number length can not be less than 10',
                        variant: 'error'
                    })
                );
                return;
            }
        checkDID({ 
            did: this.didNumber, 
            qualification: this.ucfVoipQualification, 
            recordId: this.recordId,
            Location: this.SelectedLocationFromAdd,
            CustomExt:this.CostumizeExtension,
            CurrentCarrier:this.CurrentCarrier,
            ExtLength:this.ExtensionLength,
            InstallType:this.SelectedInstallType
        })
        .then(result => {
            
            // Display a success toast with the message returned from the server
            if(result !== 'Phone does not qualify for Voip Qualification')
            {
                const toast = new ShowToastEvent({
                title: 'Success',
                message: result,
                variant: 'Success'
            });
            this.dispatchEvent(toast);
             this.rSucess = true;
            }
            else if(result === 'Phone does not qualify for Voip Qualification'){
                const toast = new ShowToastEvent({
                title: 'Error',
                message: result,
                variant: 'error'
            });
            this.dispatchEvent(toast);
             this.rSucess = false;
            }
            
            
            // Resetting the fields
            this.FtrDIDLocations();
            this.FtrVoipQualifications();
            this.didNumber = '';
           
            this.ucfVoipQualification = '';
            this.SelectedLocationFromAdd = '';
            this.CurrentCarrier='';
            this.SelectedInstallType='';
            this.LocationOptions=null;
            this.ftrDIDNumberDetail();
            
            
            
        })
        .catch(error => {
            // Handle the error by displaying a toast
        
            let errorMessage = 'Unknown error';
            if( !this.rSucess)
            {
                if (error && error.body && error.body.message) {
                errorMessage = error.body.message;
            }
            const toast = new ShowToastEvent({
                title: 'Error',
                message: errorMessage,
                variant: 'error'
            });
            this.dispatchEvent(toast);
            }
            
        });
    } else {
        const toast = new ShowToastEvent({
            title: 'Error',
            message: 'Please fill all the fields to create a record!',
            variant: 'error'
        });
        this.dispatchEvent(toast);
    }
}

handleSave() {
    
    const draftValueIds = new Set(this.draftValues.map(draft => draft.Id));
    const groupMemberIdsToDelete = this.GetMembers
        .filter(member => draftValueIds.has(member.didNumberDetails))
        .map(member => member.id);

        if (groupMemberIdsToDelete.length > 0) {
            deleteGroupMembers({ recordIds: groupMemberIdsToDelete })
                .then(result => {
                    console.log('Successfully deleted group members');
                    
                })
                .catch(error => {
                    console.error('Error deleting group members:', error);
                    
                });
        }

        const MLHGMemberIdsToDelete = this.GetMLHGMembers
        .filter(member => draftValueIds.has(member.didNumberDetails))
        .map(member => member.id);

        if (MLHGMemberIdsToDelete.length > 0) {
            deleteMLHGMembers({ recordIds: MLHGMemberIdsToDelete })
                .then(result => {
                    console.log('Successfully deleted MLHG members');
                    
                })
                .catch(error => {
                    console.error('Error deleting MLHG members:', error);
                    
                });
        }

        //alert(JSON.stringify(this.DIDList));


    this.required2=false;

    // Create an array to store the records that need to be updated
    const recordsToUpdate = [];
    // Loop through draftValues to build the array of records to update
    const listPhoneIds = this.allRecordIds;
    
    //Loop through all phone numbers to check if any field is blank
    console.log('Ftr Details'+JSON.stringify(this.ftrDIDNumberDetails));
    this.ftrDIDNumberDetails.forEach(ele => {
        
        if(ele.Ucf_Current_Carrier__c === undefined || ele.Ucf_Install_Type__c === undefined || ele.Ucf_Number_Use__c === undefined || ele.DIDLocationDetailsId__c === undefined)
        {
            this.required=true;
        }
        
    });

    if(this.isTranslation)
   {
    //alert(JSON.stringify(this.VoipQualifications));
    this.VoipQualifications.forEach(ele => {
        
        if(ele.Local_Routing_Number__c === undefined || ele.Local_Routing_Number__c === '')
        {
            this.required2=true;
            //alert(this.required2);
            //alert(JSON.stringify(ele.Local_Routing_Number__c)); 
        }
        
    });
   }

    //alert(this.required);
    if(this.required2 === true)
    {
        //alert(this.required);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please fill all the Local Routing Number before save !', 
                variant: 'error'
            })
        );
    }

    if(this.required === true)
    {
        //alert(this.required);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please fill all the fields before save !', 
                variant: 'error'
            })
        );
    }
   if(this.required2 === false){
    /** Comment by Sami to change the update method instead of voip to DID Numbers update */
    /*
   if (this.draftValuesNXX.length !== 0) {

        updateDidLocationsNXX({ updatedRecords: this.draftValuesNXX })
            .then(result => {
                if (result === 'Success') {
                    // Handle successful update
                    this.fieldChangeCount=0;
                    this.notifyInputChange(this.fieldChangeCount);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Local Routing Number updated successfully',
                            variant: 'success'
                        })
                    );
                    this.FtrVoipQualifications();
                    this.draftValues = []; // Clear draft values after successful update
                } else {
                    // Handle errors returned from Apex
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating records',
                            message: result, // Display the error message from Apex
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error => {
                // Handle any errors that occurred during the LWC-Apex communication
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating records',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
         
        }
        */
        if (this.draftValuesNXX.length !== 0) {

            updateDIDNumbersNXX({ updatedRecords: this.draftValuesNXX })
                .then(result => {
                    if (result === 'Success') {
                        // Handle successful update
                        this.fieldChangeCount=0;
                        this.notifyInputChange(this.fieldChangeCount);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Local Routing Number updated successfully',
                                variant: 'success'
                            })
                        );
                        this.FtrVoipQualifications();
                        this.draftValues = []; // Clear draft values after successful update
                    } else {
                        // Handle errors returned from Apex
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error updating records',
                                message: result, // Display the error message from Apex
                                variant: 'error'
                            })
                        );
                    }
                })
                .catch(error => {
                    // Handle any errors that occurred during the LWC-Apex communication
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating records',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
             
            }
   }
    
     if(this.ExtensionLength == undefined)
    {
       this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select customised extensions length',
                    variant: 'error'
                })
            );
            return;
    }

   

    


    // Call the Apex method to update the records
    updateftrDIDNumberDetails({ ids:listPhoneIds, 
                                extLength:this.ExtensionLength,
                                isCustmizeExt: this.CostumizeExtension  
                                })
        .then(result => {
            // Handle success
            this.fieldChangeCount=0;
            this.notifyInputChange(this.fieldChangeCount);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Extension preferences successfully saved',
                    variant: 'success'
                })
            );

            // Clear the draftValues array
            this.draftValues = [];
            this.FtrVoipQualifications();    
            // Refresh the table data
            return refreshApex(this.wiredftrDIDNumberDetails);
        })
    if (this.draftValues.length !== 0) {
   
    updateDidLocationsBulk({ updatedRecords: this.draftValues })
        .then(result => {
            if (result === 'Success') {
                // Handle successful update
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Records updated successfully',
                        variant: 'success'
                    })
                );
                this.draftValues = []; // Clear draft values after successful update
            } else {
                // Handle errors returned from Apex
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating records',
                        message: result, // Display the error message from Apex
                        variant: 'error'
                    })
                );
            }
        })
        .catch(error => {
            // Handle any errors that occurred during the LWC-Apex communication
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating records',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });

    }
    

        
}

    uploadFileHandler( event ) {
        const uploadedFiles = event.detail.files;
        console.log('file name is:-'+uploadedFiles[0].name);
        console.log('document id is:-'+uploadedFiles[0].documentId);
        this.contentDocumentId=uploadedFiles[0].documentId;
        
        loadCSVData({ contentDocumentId : this.contentDocumentId,  recordId: this.recordId, CustomExt: this.CostumizeExtension, ExtLength: this.ExtensionLength})
        .then((result)=>{
            this.recordCount=result;
            console.log('OUTPUT : ',result);
            const event = new ShowToastEvent({
                title: 'Success',
                message:result,
                    //this.recordCount+' Phone Numbers have been uploaded Successfully.',
                variant:'success',
                mode:'dismissible'
            });
            this.fetchDidNumberDetails();
            this.ftrDIDNumberDetail();
            this.fileSucess = true;
            this.dispatchEvent(event);
            this.handleRefreshClick();
            
            })
        .catch((error)=>{
           this.error = error;
           if(!this.fileSucess)
           {
               const event=new ShowToastEvent({
              title:'Error',
              variant:'error',
              message:'Error while creating Records',
              mode:'dismissible'
           })
           this.dispatchEvent(event);
           }
           
        })
    }

    exportCSV() {
    let csv = 'Id,Phone Number,Current Carrier,Install Type,Voip Qualification,Number Use,Service Location\n';  // Your CSV headers

    this.ftrDIDNumberDetails.forEach(ele => {
        csv += `${ele.Id},${ele.DIDNumber__c},${ele.Ucf_Current_Carrier__c},${ele.Ucf_Install_Type__c},${ele.Ucf_Voip_Qualification__c},${ele.Ucf_Number_Use__c},${ele.DIDLocationDetailsId__r.UCFNameValidation__c}\n`;  // Assuming these are the correct property names
    });

    // Creating a blob object
    let blob = new Blob([csv], { type: 'text/plain' });  
    let link = document.createElement('a');
    
    link.href = URL.createObjectURL(blob);
    link.download = 'Phone Numbers Data.csv';
    document.body.appendChild(link);  
    link.click();
    document.body.removeChild(link);
}
 
exportTemplate() {
    const csvHeader = 'Id,Phone Number,Current Carrier,Install Type,Voip Qualification,Number Use,Service Location\n';

    // Creating a blob object
    let blob = new Blob([csvHeader], { type: 'text/plain' });  
    let link = document.createElement('a');
    
    link.href = URL.createObjectURL(blob);
    link.download = 'Phone Number Template.csv';
    document.body.appendChild(link);  
    link.click();
    document.body.removeChild(link);
}

handleRefreshClick() {
        refreshApex(this.wiredRecords).then(() =>{ 
            console.log('OUTPUT : refreshed');
        });
    }
notifyInputChange(count){
    console.log('count ',count);
    this.dispatchEvent(new CustomEvent('recordchange', {
        detail: {
            component: 'phoneNumber',
            message: count
        }
    }));
}

}