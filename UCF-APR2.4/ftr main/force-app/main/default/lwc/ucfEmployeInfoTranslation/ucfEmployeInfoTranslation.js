import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';


import getEmployeInformationDataForPM from '@salesforce/apex/UcfEmpInfoController.getEmployeInformationDataForPM';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from "@salesforce/apex";
import getMDNOptions from '@salesforce/apex/UcfEmpInfoController.getMDNOptions';
import updateftrDIDNumberDetailsEmployeeTab from '@salesforce/apex/FetchData.updateftrDIDNumberDetailsEmployeeTab';
import loadCSVDataForEmployeeInfo from '@salesforce/apex/FetchData.loadCSVDataForEmployeeInfo';
 


export default class UcfEmployeInfoTranslation extends LightningElement {


    @api recordId;
    @track getEmployeInformationDataForPM;
    @track showData = false;
    @track mdnOptions = [];
    @track sortedBy;
    @track sortedDirection = 'asc';
    @track draftValues = [];
    @track wiredRecords;



    
    displayEmpInfoDetailForPM() {
        this.showData = true;
        this.getEmpData();
    
    }

       @wire(getMDNOptions, { orderId: '$recordId' })
    wiredMDNOptions({ data, error }) {
        if (data) {
            this.mdnOptions = data.map(mdn => ({ label: mdn, value: mdn }));
        } else if (error) {
           // console.error('Error retrieving MDN options:', error);
        }
    }
    processResult(data) {
                const mainMDNOptions = this.mdnOptions;
       this.getEmployeInformationDataForPM = data.map((ftr_DID_Number_Details__c, index) => { 
              let extLength = parseInt(ftr_DID_Number_Details__c.Ucf_Extension_Lenght__c);
               let phoneOption = { label: ftr_DID_Number_Details__c.DIDNumber__c, value: ftr_DID_Number_Details__c.DIDNumber__c };
            let rowMDNOptions = [phoneOption, ...mainMDNOptions];
            let ext = ftr_DID_Number_Details__c.DIDNumber__c.slice(-extLength);
              console.log('hello ext ' + ext);
              if (ext === null || ext === undefined || ext === '') {
                 ext = 0;
                    }
            return {
                ...ftr_DID_Number_Details__c, 
                editMode: true,
                 slicedExtension: ext, 
                mdnPicklistOptions: rowMDNOptions,
                key: `key-${index}`, // Added a template literal to define a unique key
                mdnPicklistId: `mdnPicklist-${index}`,
                Ucf_Department__c: ftr_DID_Number_Details__c.Ucf_Department__c || '',
                DIDNumber__c: ftr_DID_Number_Details__c.DIDNumber__c || '',
                Ucf_User_Name__c: ftr_DID_Number_Details__c.Ucf_User_Name__c || '',
                 Ucf_MAC_Address__c: ftr_DID_Number_Details__c.Ucf_MAC_Address__c || '',
                  Ucf_EAS_Pin__c: ftr_DID_Number_Details__c.Ucf_EAS_Pin__c || '',
                Ucf_Extension__c: ftr_DID_Number_Details__c.Ucf_Customize_Extension__c ? '' : ext,
                Ucf_Email__c: ftr_DID_Number_Details__c.Ucf_Email__c || '', 
                Ucf_Company_Name__c: ftr_DID_Number_Details__c.Ucf_Company_Name__c || '',
                Ucf_Address_Number__c: ftr_DID_Number_Details__c.Ucf_Address_Number__c || '',
                Ucf_Street_Name__c: ftr_DID_Number_Details__c.Ucf_Street_Name__c || '',
                Ucf_City__c: ftr_DID_Number_Details__c.Ucf_City__c || '',
                Ucf_State__c: ftr_DID_Number_Details__c.Ucf_State__c || '',
                Ucf_Zip_Code__c: ftr_DID_Number_Details__c.Ucf_Zip_Code__c || '',
                Ucf_Device_Type__c : ftr_DID_Number_Details__c.Ucf_Device_Type__c || '',
                Ucf_Device_Accessories__c : ftr_DID_Number_Details__c.Ucf_Device_Accessories__c || '',
                Ucf_Identifying_Location__c: ftr_DID_Number_Details__c.Ucf_Identifying_Location__c || ''
            };
        }); 

        
        
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
    getEmpData()
    {
            // Call the Apex method imperatively
     getEmployeInformationDataForPM({ recordId: this.recordId })
            .then(result => {
 
                this.processResult(result);
            })
            .catch(error => {
                this.error = error;
                // Handle error (e.g., show a toast message)
                this.showToast('Error', 'Can not Display Data', 'error');
            }); 
    }

     handleInputChange(event) {
    //alert('heree');
    const recordId = event.target.dataset.recordId;
    const fieldName = event.target.dataset.fieldName;
    const newValue = event.target.value;
    console.log('reocrd id' ,recordId);
    console.log(fieldName);
   
    const index = this.getEmployeInformationDataForPM.findIndex(ftrDIDNumberDetail => ftrDIDNumberDetail.Id === recordId);
    if (index !== -1) {
        // Update the field value in the account data
        this.getEmployeInformationDataForPM[index][fieldName] = newValue;
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
     
     //alert(JSON.stringify(this.draftValues));
        console.log(updatedData);
    }
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

sortByField(fieldName) {
    //alert('cl');
    const sortDirection = this.sortedBy === fieldName && this.sortedDirection === 'asc' ? 'desc' : 'asc';
    this.sortData(fieldName, sortDirection);
}



handleSave() {
    if(this.draftValues == null || this.draftValues == '')
    {
        this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'You can only Save Data once you made some changes in the grid`',
                    variant: 'error'
                })
            );
        return;
    }

    // Create an array to store the records that need to be updated
    const recordsToUpdate = [];
    // Loop through draftValues to build the array of records to update
    this.draftValues.forEach(draft => {
        recordsToUpdate.push({
            Id: draft.Id,
            Ucf_Extension__c: draft.Ucf_Extension__c, 
            Ucf_User_Name__c: draft.Ucf_User_Name__c, 
            Ucf_MAC_Address__c : draft.Ucf_MAC_Address__c,
            Ucf_Device_Accessories__c: draft.Ucf_Device_Accessories__c,
            Ucf_Device_Type__c: draft.Ucf_Device_Type__c
        });
    });
//alert(JSON.stringify(recordsToUpdate));
    // Call the Apex method to update the records
    updateftrDIDNumberDetailsEmployeeTab({ recordsToUpdate })
        .then(result => {
            // Handle success
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records saved successfully',
                    variant: 'success'
                })
            );
            this.getEmpData();

            // Clear the draftValues array
            this.draftValues = [];

            // Refresh the table data
            //return refreshApex(this.getEmployeInformationDataForPM);
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


handleSort(event) {
    const fieldName = event.currentTarget.dataset.field;
    this.sortByField(fieldName);
}

sortData(fieldName, sortDirection) {
    // Simple comparison function for strings
    const compareStrings = (a, b) => {
        if (a === null || a === undefined) {
            return sortDirection === 'asc' ? 1 : -1;
        } else if (b === null || b === undefined) {
            return sortDirection === 'asc' ? -1 : 1;
        } else if (a.toLowerCase() > b.toLowerCase()) {
            return sortDirection === 'asc' ? 1 : -1;
        } else if (a.toLowerCase() < b.toLowerCase()) {
            return sortDirection === 'asc' ? -1 : 1;
        } else {
            return 0;
        }
    };

    // Sorting logic
    const sorted = [...this.getEmployeInformationDataForPM].sort((a, b) => {
        return compareStrings(a[fieldName], b[fieldName]);
    });

    this.getEmployeInformationDataForPM = sorted;
    this.sortedBy = fieldName;
    this.sortedDirection = sortDirection;
}
  exportCSV() {
        let csv = 'Id, DIDNumber__c,Ucf_Extension__c,Ucf_User_Name__c,Ucf_EAS_Pin__c,Ucf_MAC_Address__c,Ucf_Device_Accessories__c,Ucf_Device_Type__c\n';
        this.getEmployeInformationDataForPM.forEach(ele => {
                csv += `${ele.Id},${ele?.DIDNumber__c},${ele?.Ucf_Extension__c},${ele?.Ucf_User_Name__c},${ele?.Ucf_EAS_Pin__c},${ele?.Ucf_MAC_Address__c},${ele?.Ucf_Device_Accessories__c},${ele?.Ucf_Device_Type__c}\n`;
            
            
        });

        // Creating a blob object
        let blob = new Blob([csv], { type: 'text/plain' });  
        let link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download =  'EmployeInformation-Translation'+'.csv';
        document.body.appendChild(link);  
        link.click();
        document.body.removeChild(link);
    }

exportTemplate() {
    console.log('OUTPUT : ');
    // const csvHeader = 'Id,Phone Number,Current Carrier,Voip Qualification,DID Numbers\n';
          let csv = 'Id, DIDNumber__c,Ucf_Extension__c,Ucf_User_Name__c,Ucf_EAS_Pin__c,Ucf_MAC_Address__c,Ucf_Device_Accessories__c,Ucf_Device_Type__c\n';

        
    // Creating a blob object
    let blob = new Blob([csv], { type: 'text/plain' });  
    let link = document.createElement('a');
    
    link.href = URL.createObjectURL(blob);
    link.download =  'EmployeInformation-Translation'+' Template.csv';
    document.body.appendChild(link);  
    link.click();
    document.body.removeChild(link);
    const toast = new ShowToastEvent({
                    title: 'Success',
                    message: 'Template Downloaded Successfully.',
                    variant: 'success'
                });
    this.dispatchEvent(toast);
}

 uploadFileHandler( event ) {
        const uploadedFiles = event.detail.files;
        console.log('file name is:-'+uploadedFiles[0].name);
        console.log('document id is:-'+uploadedFiles[0].documentId);
        this.contentDocumentId=uploadedFiles[0].documentId;
        let employeeInfoType = this.selectedOption;
        console.log('OUTPUT this.selectedOption : ',this.selectedOption);
        
        loadCSVDataForEmployeeInfo({ contentDocumentId : this.contentDocumentId, employeeInfoType : 'EmpInfoTrnaslation' })
        .then((result)=>{
            this.recordCount=result;
           this.getEmpData();
            console.log('OUTPUT : ',result);
            if(this.recordCount == 0){
                
                const event = new ShowToastEvent({
                title: 'Error',
                message: 'Given data is not valid, Recheck your file columns',
                variant:'error',
                mode:'dismissible'
            });
            this.dispatchEvent(event);
            }
            else{
                const event = new ShowToastEvent({
                    title: 'Success',
                    message:
                        this.recordCount+' Phone Numbers have been uploaded Successfully.',
                    variant:'success',
                    mode:'dismissible'
                });
                this.getEmpData();
                this.dispatchEvent(event);
                 
            }
            })
        .catch((error)=>{
           this.error = error;
          /* const event=new ShowToastEvent({
              title:'Error',
              variant:'error',
              message:'Error while creating Records',
              mode:'dismissible'
           })
           this.dispatchEvent(event);*/
        })
    }

handleCancel()
{
    this.getEmpData();
}



}