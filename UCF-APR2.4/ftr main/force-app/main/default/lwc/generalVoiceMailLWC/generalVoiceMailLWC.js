import { LightningElement, wire, track, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import ftrDIDNumberDetailsGeneralVoicemail from '@salesforce/apex/UcfGvmController.ftrDIDNumberDetailsGeneralVoicemail';
//import updateAccountFields from '@salesforce/apex/UcfGvmController.updateAccountFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getRatingPicklistValues from '@salesforce/apex/PmEnrichmentController.getRatingPicklistValues';
//import updateAccountFieldsList from '@salesforce/apex/PmEnrichmentController.updateAccountFieldsList';
import upsertAccounts from '@salesforce/apex/PmEnrichmentController.upsertAccounts';
import isTranslationUser from '@salesforce/apex/PmEnrichmentController.isTranslationUser';
import loadCSVData from '@salesforce/apex/UcfGvmController.loadCSVDataForGenralVoicemail';
import updateftrDIDNumberDetailsEmployeeTab from '@salesforce/apex/UcfGvmController.updateftrDIDNumberDetailsEmployeeTab';
//import getCurrentOrderStage from  '@salesforce/apex/PmEnrichmentController.getOrderStage';
import ftrDIDNumberDetails from '@salesforce/apex/FetchData.ftrDIDNumberDetails';


export default class GeneralVoiceMailLWC extends LightningElement {
    @api recordId;
    @track length = 0;
    @track accounts;
    @track data = [];
    @track draftValues = [];
    @track isModalOpen = false;
    @track sicDesc = '';
    @track tickerSymbol = '';
    @track ratingPicklistValues = [];
    @track sortField = 'Name'; // Default sort field
    @track sortOrder = 1;
    @track sortDirection = 'asc'; // Default sort direction
    @track refreshTable = false; // Flag to trigger table refresh
    @track ratingPicklistOptions = [];
    @track selectedRating = ''; 
    @track wiredftrDIDNumberResult;
    @track wiredRecords;
    @track isTranslation;
    @track isReadOnly;
    @api isOrderInProgressOrCompleted = false;
    fileContents;
    N11;
    file;
    ftrDIDNumberDetailsGeneralVoicemail = null;
    showLoader = false;
    error;
    @api isnetworktranslation=false;
    fieldChangeCount=0;
    @track isOrderInProgressOrCompleted = false;
    @track ftrDIDNumberDetails = [];

connectedCallback() {
        this.showLoader=true;
        this.fetchftrDIDNumberDetailsGeneralVoicemail();
        
    }
    // getOrderStage()
    // {
    //     getCurrentOrderStage({recordId: this.recordId}).then(result=>{
    //         if(result != undefined && result != null){
    //         if(result == true)
    //         {
    //             this.isOrderInProgressOrCompleted = true;
    //         }   
    //         }
    //     }).catch(error=>{
    //         console.log(' Current Order Stage Error', error);
    //         });
    // }

    fetchftrDIDNumberDetailsGeneralVoicemail() {
        ftrDIDNumberDetailsGeneralVoicemail({ recordId: this.recordId })
            .then(result => {
                console.log('data: ', JSON.stringify(result));
                this.processData(result);
            })
            .catch(error => {
                this.error = error;
            });
            
    }

    processData(data) {
        // Process your data here similarly to your wire service
        this.ftrDIDNumberDetailsGeneralVoicemail = data.map(ftr_DID_Number_Details__c => {
            let extLength = parseInt(ftr_DID_Number_Details__c.Ucf_Extension_Lenght__c);
            this.length = extLength;
            let ext = ftr_DID_Number_Details__c.DIDNumber__c.slice(-extLength);
            let N11 = ext.slice(-2);    
            return {
                ...ftr_DID_Number_Details__c,
                editMode: true,
                slicedExtension: ext,
                N11: N11 === '11',
                Ucf_Extension__c: ftr_DID_Number_Details__c.Ucf_Extension__c,
                Ucf_Email__c: ftr_DID_Number_Details__c.Ucf_Email__c || '',
                Ucf_General_Voice_Mail_Name__c: ftr_DID_Number_Details__c.Ucf_General_Voice_Mail_Name__c || '',
                EAS_Pin__c : ftr_DID_Number_Details__c.EAS_Pin__c || ''
            };
        });
        this.showLoader=false;
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
sortByPhoneNumber() {
    
    
    
    this.sortDirection = this.sortField === 'DIDNumber__c' && this.sortDirection === 'asc' ? 'desc' : 'asc';
    this.sortField = 'DIDNumber__c';
    this.sortData();
    
}
sortByExtension() {
    
    this.sortDirection = this.sortField === 'Ucf_Extension__c' && this.sortDirection === 'asc' ? 'desc' : 'asc';
    this.sortField = 'Ucf_Extension__c';
    this.sortData();
    
}
sortByMLHGName() {
    
    
    this.sortDirection = this.sortField === 'Ucf_General_Voice_Mail_Name__c' && this.sortDirection === 'asc' ? 'desc' : 'asc';
    this.sortField = 'Ucf_General_Voice_Mail_Name__c';
    this.sortData();
    
}
sortByMLHGEmail() {
    
    
    this.sortDirection = this.sortField === 'Ucf_Email__c' && this.sortDirection === 'asc' ? 'desc' : 'asc';
    this.sortField = 'Ucf_Email__c';
    this.sortData();
    
}
sortByEASPin() {
    
   
    this.sortDirection = this.sortField === 'EAS_Pin__c' && this.sortDirection === 'asc' ? 'desc' : 'asc';
    this.sortField = 'EAS_Pin__c';
    this.sortData();
    
}
sortData() {
    
    const field = this.sortField;
    const reverse = this.sortDirection === 'desc' ? -1 : 1;
    this.ftrDIDNumberDetailsGeneralVoicemail = [...this.ftrDIDNumberDetailsGeneralVoicemail.sort((a, b) => (a[field] > b[field] ? 1 : -1) * reverse)];
}

  openModal(event) {
     
    const recordIdToEdit = event.currentTarget.dataset.recordId;
    const accountToEdit = this.accounts.find(account => account.Id === recordIdToEdit);
    // Set the values from the selected record
    this.recordIdToEdit = recordIdToEdit;

    console.log(recordIdToEdit);
    this.sicDesc = accountToEdit.SicDesc;
    this.tickerSymbol = accountToEdit.TickerSymbol;
    this.isModalOpen = true;
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
      //alert('Type '+ this.userType);
     // alert('Ro '+ this.isReadOnly);
    //  alert('Tra '+ this.isTranslation);
    } else if (error) {
        console.error("Error determining user profile:", error);
    }
} 


    closeModal() {
        this.isModalOpen = false;
    }

    handleSicDescriptionChange(event) {
        this.sicDesc = event.target.value;
    }

    handleTickerSymbolChange(event) {
        this.tickerSymbol = event.target.value;
    }


   handleModalSave() {
       
    // Create an object to store the fields to update
     this.draftValues.forEach(draft => {
        if (draft.Ucf_Extension__c) {
            const isDuplicateExtension = this.ftrDIDNumberDetailsGeneralVoicemail.some(detail =>
                detail.Ucf_Extension__c === draft.Ucf_Extension__c && detail.Id !== draft.Id
            );
 
            if (isDuplicateExtension) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Duplicate Extension',
                        message: 'Please enter a unique Extension',
                        variant: 'error'
                    })
                );
                this.isValidationFailed = true;
                return;
            }
        }
    });

    const fieldsToUpdate = {
        recordId: this.recordIdToEdit,
        sicDesc: this.sicDesc,
        tickerSymbol: this.tickerSymbol
    };

       // Call the Apex method to update the record
    updateAccountFields(fieldsToUpdate)
        .then(result => {
            // Close the modal
            this.isModalOpen = false;
           // alert(JSON.stringify('RS: '+ result))

            // Refresh the table or data
           // return refreshApex(this.wiredAccounts)
           
                    // Display a success message
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: result, // This is the success message returned from Apex
                            variant: 'success'
                        })
                    );
              
        })
        .catch(error => {
            // Handle any errors and display an error message
            const errorMessage = error.body && error.body.message ? error.body.message : 'An error occurred';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: errorMessage,
                    variant: 'error'
                })
            );
        });
}
exportCSV() {
    let csv;  // Your CSV headers
      if(this.isTranslation == true ||  this.isReadOnly == true){
        csv = 'Id,Phone Number,Extension,Name,Email,EAS Pin\n';
    } else if(this.isTranslation == false && this.isReadOnly == false){
        csv = 'Id,Phone Number,Extension,Name,Email\n';
    }
     if(this.ftrDIDNumberDetailsGeneralVoicemail.length ==0){
        console.log('ftrDIDNumberDetailsGeneralVoicemail : ',JSON.stringify(this.ftrDIDNumberDetailsGeneralVoicemail));
        return;
    }
    if(this.isTranslation == false && this.isReadOnly == false){
        this.ftrDIDNumberDetailsGeneralVoicemail.forEach(ele => {
        csv += `${ele.Id},${ele.DIDNumber__c},${ele.Ucf_Extension__c},${ele.Ucf_General_Voice_Mail_Name__c},${ele.Ucf_Email__c }\n`; // Assuming these are the correct property names
    });
    }
    else if(this.isTranslation == true || this.isReadOnly == true){
                 this.ftrDIDNumberDetailsGeneralVoicemail.forEach(ele => {
         csv += `${ele.Id},${ele.DIDNumber__c},${ele.Ucf_Extension__c},${ele.Ucf_General_Voice_Mail_Name__c},${ele.Ucf_Email__c },${ele.EAS_Pin__c}\n`; // Assuming these are the correct property names
    });
    }
    
    


    // Creating a blob object
    let blob = new Blob([csv], { type: 'text/plain' });  
    let link = document.createElement('a');
    
    link.href = URL.createObjectURL(blob);
    link.download = 'GVM_Data.csv';
    document.body.appendChild(link);  
    link.click();
    document.body.removeChild(link);
}

exportTemplate() {
    let csvHeader = 'Id,Phone Number,Extension,Name,Email\n';
    if(this.isTranslation == true || this.isReadOnly == true){
        csvHeader = 'Id,Phone Number,Extension,Name,Email,EAS Pin\n';
    } else{
        csvHeader = 'Id,Phone Number,Extension,Name,Email\n';
    }
    // Creating a blob object
    let blob = new Blob([csvHeader], { type: 'text/plain' });  
    let link = document.createElement('a');
    
    link.href = URL.createObjectURL(blob);
    link.download = 'General Voicemail Template.csv';
    document.body.appendChild(link);  
    link.click();
    document.body.removeChild(link);
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
 uploadFileHandler( event ) {
        const uploadedFiles = event.detail.files;
        console.log('file name is:-'+uploadedFiles[0].name);
        console.log('document id is:-'+uploadedFiles[0].documentId);
        this.contentDocumentId=uploadedFiles[0].documentId;
        
        loadCSVData({ contentDocumentId : this.contentDocumentId })
        .then((result)=>{
            this.recordCount=result;
            console.log('OUTPUT : ',result);
            const event = new ShowToastEvent({
                title: 'Success',
                message:
                    this.recordCount+' General Voice Mail have been Updated Successfully.',
                variant:'success',
                mode:'dismissible'
            });
            this.dispatchEvent(event);
            this.fetchftrDIDNumberDetailsGeneralVoicemail();
            })
        .catch((error)=>{
           this.error = error;
           const event=new ShowToastEvent({
              title:'Error',
              variant:'error',
              message:'Error while creating Records',
              mode:'dismissible'
           })
           this.dispatchEvent(event);
        })
    }


    handleInputChange(event) {
    this.fieldChangeCount++;
    this.notifyInputChange(this.fieldChangeCount);
    const recordId = event.target.dataset.recordId;
    const fieldName = event.target.dataset.fieldName;
    const newValue = event.target.value;
    console.log('reocrd id' ,recordId);
    console.log(fieldName);
    console.log(newValue);
    this.N11=false;
    if (fieldName === 'Ucf_Email__c') {
        // Email validation
        if (!this.isValidEmail(newValue)) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Invalid Email',
                    message: 'Please enter a valid email address.',
                    variant: 'error'
                })
            );
            return; // Prevent further processing if the email is invalid
        }
    }

    const index = this.ftrDIDNumberDetailsGeneralVoicemail.findIndex(ftrDIDNumberDetailsGeneralVoicemail => ftrDIDNumberDetailsGeneralVoicemail.Id === recordId);
    
    if (index !== -1) {
        
        this.ftrDIDNumberDetailsGeneralVoicemail[index][fieldName] = newValue;
        
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
        
    }
    if (fieldName === 'Ucf_Extension__c') {
        // Check for duplicate Ucf_Extension__c entry
        if(event.target.value !== '')
        {
        const isDuplicate = this.ftrDIDNumberDetailsGeneralVoicemail.some(detail => 
            detail.Ucf_Extension__c === newValue && detail.Id !== recordId
        );

          if (isDuplicate) {
            // Alert the user that the webinar value is already selected
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Duplicate Extension',
                message: 'Please enter an unique Extension',
                variant: 'error'
            })
        );
        return;
        }
    }
    if (fieldName === 'Ucf_General_Voice_Mail_Name__c') {
        // Check for duplicate Ucf_General_Voice_Mail_Name__c entry
        if(event.target.value !== '')
        {
           // alert(JSON.stringify(this.ftrDIDNumberDetailsGeneralVoicemail));
        const isDuplicate = this.ftrDIDNumberDetailsGeneralVoicemail.some(detail => 
            detail.Ucf_General_Voice_Mail_Name__c === newValue && detail.Id !== recordId
        );

          if (isDuplicate) {
            // Alert the user that the webinar value is already selected
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Duplicate Name',
                message: 'Please enter an unique Name',
                variant: 'error'
            })
        );
        return;
        }
    }
    
}
}
 
    }

handleCancel()
{
    this.fetchftrDIDNumberDetailsGeneralVoicemail();
    this.fieldChangeCount=0;
    this.notifyInputChange(this.fieldChangeCount);
}
checkValueExists(idToCheck) {
        console.log('Checking:', idToCheck);
        return this.draftValues.some(obj => obj.Id === idToCheck);
    }
checkValueExistsArray(idToCheck,ArrayToCheck) {
        console.log('Checking:', idToCheck);

        return ArrayToCheck.some(obj => obj.Id === idToCheck);
    }     
async handleSave() {
    try {
        this.showLoader = true; // Show loader before making the call
        
        // Call the Apex method and wait for the response
        const result = await ftrDIDNumberDetails({ recordId: this.recordId });
        
        // Update the state with the received data
        if (result) {
            this.ftrDIDNumberDetails = result;
            
            let isValidationFailed = false;

    
                let Duplicate=false;
                let ExtChanged=false;
                /***** Checking duplicate Ext with in the order when Ext is changed manually */
                this.draftValues.forEach(draft=>{
                            if (draft.Ucf_Extension__c) {
                            ExtChanged=true;
                            const isDuplicateExtension= this.draftValues.some(detail =>
                                detail.Ucf_Extension__c === draft.Ucf_Extension__c && detail.Id !== draft.Id
                            );
                            if(isDuplicateExtension) {
                            console.log('1733');
                            Duplicate=true;
                            
                            isValidationFailed = true;
                            return;
                            }
                            if(Duplicate == false)
                            {
                                const isDuplicateExtension = this.ftrDIDNumberDetails.some(detail =>
                                    detail.Ucf_Extension__c === draft.Ucf_Extension__c && detail.Id !== draft.Id && this.checkValueExistsArray(detail.Id,this.draftValues) == false 
                                );
                    
                                if (isDuplicateExtension) {
                                    Duplicate=true;
                                    isValidationFailed = true;
                                    console.log('1751');
                                    return;
                                }
                            }
                            }
                        });
                
                if(Duplicate == false && ExtChanged == true)
                    {
                        this.ftrDIDNumberDetailsGeneralVoicemail.forEach(draft => {
                    
                        const isDuplicateExtension = this.ftrDIDNumberDetails.some(detail =>
                            detail.Ucf_Extension__c === draft.Ucf_Extension__c && draft.Id !== detail.Id && this.checkValueExists(draft.Id) == false && this.checkValueExists(detail.Id) == false
                        );
            
                        if (isDuplicateExtension) {
                            Duplicate=true;
                            isValidationFailed = true;
                            console.log('If duplicate out side Employee Info when change in Ext');
                            return;
                        }
                    
                    });
                    }

                /***** Checking duplicate Ext with in the order when Ext is not changed manually and user saved*/
                if((Duplicate == false && this.draftValues.length == 0) || (Duplicate == false && this.draftValues.length !== 0 && ExtChanged == false)) 
                {
                    this.ftrDIDNumberDetailsGeneralVoicemail.forEach(draft => {
                    if (draft.Ucf_Extension__c) {
                        const isDuplicateExtension = this.ftrDIDNumberDetails.some(detail =>
                            detail.Ucf_Extension__c === draft.Ucf_Extension__c && detail.Id !== draft.Id
                        );

                        if (isDuplicateExtension) {
                            Duplicate=true;
                            isValidationFailed = true;
                            console.log('Duplicate when no change in Ext or change in other fields with in or out side GVM');
                            return;
                        }
                    }
                    });
                }
            
                if(Duplicate == true)
                {
                    this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Duplicate Extension',
                                    message: 'Please enter a unique Extension',
                                    variant: 'error'
                                })
                            );
                    return;        
                }

            this.draftValues.forEach(draft => {
                if (draft.Ucf_General_Voice_Mail_Name__c) {
                    const isDuplicateName = this.ftrDIDNumberDetailsGeneralVoicemail.some(detail =>
                        detail.Ucf_General_Voice_Mail_Name__c.toLowerCase() === draft.Ucf_General_Voice_Mail_Name__c.toLowerCase() 
                        && detail.Id !== draft.Id
                    );
                    if (isDuplicateName) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Duplicate Name',
                                message: 'Please enter a unique name',
                                variant: 'error'
                            })
                        );
                        isValidationFailed = true;
                        return;
                    }
                }
            });
            /*
                if(this.draftValues == null || this.draftValues == '')
                {
                    this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'You can only Save Data once you made some changes in the grid',
                                variant: 'error'
                            })
                        );
                    return;
                }
                */
                this.ftrDIDNumberDetailsGeneralVoicemail.forEach(detail =>{
                            if(this.isTranslation == true){
                                if(detail.EAS_Pin__c.length < 6)
                                        {   
                                            this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: 'Length Error',
                                                message: 'EAS Pin should not be less than 6',
                                                variant: 'error'
                                            })
                                        );
                                    isValidationFailed = true;
                                        return;
                                            
                                        }
                                }



                            let lengthOfExtension = parseInt(detail.Ucf_Extension_Lenght__c);
                        
                            
                            if(detail.Ucf_Extension__c.toString().length < lengthOfExtension)
                            {
                            this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: 'Length Error',
                                                message: 'Extension length should not be less than ' + this.length,
                                                variant: 'error'
                                            })
                                        );
                                        isValidationFailed = true;
                                        return;
                                
                            }


                            if(detail.Ucf_Extension__c.slice(-2) === '11' && detail.Ucf_Extension__c.toString().length == 3)
                            {
                                
                                this.N11=true;
                                
                            }
                        
                    });
                    
                        if (this.N11 == true) {
                            // Alert the user that the webinar value is already selected
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'N11 Extension',
                                    message: 'Extension should not contain N11 Value!',
                                    variant: 'error'
                                })
                            );
                            
                            return;
                        }
                    
                // Create an array to store the records that need to be updated
                const recordsToUpdate = [];
                // Loop through draftValues to build the array of records to update
                this.draftValues.forEach(draft => {
                    if ((draft.hasOwnProperty('Ucf_Extension__c') && (draft.Ucf_Extension__c=='' || draft.Ucf_Extension__c==null)) ||  (draft.hasOwnProperty('Ucf_General_Voice_Mail_Name__c') && (draft.Ucf_General_Voice_Mail_Name__c=='' || draft.Ucf_General_Voice_Mail_Name__c==null))) {
                        isValidationFailed = true;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'The extension or name field should not be empty; please enter a valid value',
                                variant: 'error'
                            })
                            
                        );
                        
                        return;
                    }
                    recordsToUpdate.push({
                        Id: draft.Id,
                        Ucf_Extension__c: draft.Ucf_Extension__c, 
                        Ucf_General_Voice_Mail_Name__c: draft.Ucf_General_Voice_Mail_Name__c, 
                        Ucf_Email__c: draft.Ucf_Email__c,
                        EAS_Pin__c: draft.EAS_Pin__c
                        
                    });
                });

                console.log('694'+recordsToUpdate);
                console.log('695'+this.draftValues);
                // Call the Apex method to update the records
                if (isValidationFailed==false && this.draftValues.length !== 0) {
                updateftrDIDNumberDetailsEmployeeTab({ recordsToUpdate })
                    .then(result => {
                        console.log('result' + result);
                        this.fieldChangeCount=0;
                        this.notifyInputChange(this.fieldChangeCount);
                        // Handle Error
                    /* if(result.includes('Error updating records'))
                        {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                title: 'Error',
                                message: 'Duplicate value found for the Name, Please enter unique name for each record (Name).',
                                variant: 'error'
                            })
                            );
                        } */
                    // else{
                            // Handle success
                            this.dispatchEvent(
                                new ShowToastEvent({
                                title: 'Success',
                                message: 'Records saved successfully',
                                variant: 'success'
                            })
                            );
                    //  }
                        // Clear the draftValues array
                        this.draftValues = [];

                        // Refresh the table data
                        return refreshApex(this.wiredftrDIDNumberDetailsGeneralVoicemail);
                    })
                    .catch(error => {
                        // Handle error
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Error updating records: ',
                                variant: 'error'
                            })
                        );
                    });
                }
        }
                } catch (error) {
            console.error('Error fetching data:', error);
        } finally {
            this.showLoader = false; // Hide loader after the operation completes (whether success or failure)
        }
}

isValidEmail(email) {
    // Regular expression for email validation
    const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return emailPattern.test(email);
}
notifyInputChange(count){
    this.dispatchEvent(new CustomEvent('recordchange', {
        detail: {
            component: 'generalVoiceMail',
            message: count
        }
    }));
}


}