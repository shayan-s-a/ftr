import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import Department_System_Picklist from "@salesforce/schema/ftr_911_Notifications__c.Department_System__c";
import Method__Picklist from "@salesforce/schema/ftr_911_Notifications__c.Method__c";
import loadComponent from '@salesforce/apex/CustomizationsNotesUcfController.loadData';
import updateOrder from '@salesforce/apex/CustomizationsNotesUcfController.updateOrder';
import update911Notifications from '@salesforce/apex/CustomizationsNotesUcfController.update911Notifications';
import ftrDIDNumberDetailsDepartment from '@salesforce/apex/CustomizationsNotesUcfController.ftrDIDNumberDetailsDepartment';
import insertNotification from '@salesforce/apex/CustomizationsNotesUcfController.insertNotification';


export default class CustomizationsNotesUcf extends LightningElement {

    activeSections = ['buttonProgCap'];
    activeSectionsMessage = '';
    @api recordId;
    Selecteddepartment;
    showLoader = false;
    showGroupPage = false;
    showEmeb = false;
    showSpeedCall = false;
    showParkKeyFields = false;
    @api isnetworktranslation;
    fieldChangeCount=0;
    @track notificationList = [];
    @track result = {};
    @track draftValues = [];    
    //@track isDepartmentNameEditable = false;
    @track method;
    @track departmentSystem;
    departmentnames=[];
    nameAdd;
    @track methodAdd = 'Both';
    emailAdd;
    phoneAdd;
    departmentnameAdd;
    
    @track departmentsystemAdd = 'System' ;
    @track isDepartmentNameAddEditable = false;
    @track isPhoneNumberAddEditable = true;
    @track isEmailAddressAddEditable = true;
    @track isValidationFailed =false;



    @track columns = [
        { label: 'Vendor', fieldName: 'VendorName__c' },
        { label: 'Model', fieldName: 'Name' },
        { label: 'Available Button Count', fieldName: 'AvailableButtonCount__c' },
      ];

    @track shareLocationOptions = [{ label: "Shared", value: "Shared" },
                                   { label: "Location/Department", value: "Location/Department" },];


    
 /*  @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: Department_System_Picklist })
   GetInstallType({error,data}){
       if (data) {
        console.log('department system'+JSON.stringify(data));
        this.departmentSystem =data.values;
        console.log('department system'+JSON.stringify(data.values));
    }
    if (error) {
        console.log('error',error);
    }
   };
   */
  /* @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: Method__Picklist })
   GetNumberUsePicklistValues({error,data}){
       if (data) {
        console.log(' method =='+JSON.stringify(data));
        this.method =data.values;
        console.log('method '+JSON.stringify(data.values));
    }
    if (error) {
        console.log('error',error);
    }
   };       */                        

    connectedCallback(){
        this.loadComponent(this.recordId);
        this.fetchftrDIDNumberDetailsDepartment();
        this.isValidationFailed = false;
        this.departmentSystem = [
            { label: 'Department', value: 'Department' },
            { label: 'System', value: 'System' }
        ];
        this.method = [
            { label: 'Both', value: 'Both' },
            { label: 'Cell', value: 'Cell' },
            { label: 'Email', value: 'Email' }
        ];

        console.log('zainab test',JSON.stringify(this.isnetworktranslation))
        this.isPhoneNumberAddEditable = true;
        this.isEmailAddressAddEditable = true;
    }
      @api
    loadComponent(recordId){
          this.showLoader = true;
          this.showGroupPage = false;
          this.showEmeb = false;
          this.showSpeedCall = false;
          this.showParkKeyFields = false;
          loadComponent({
              'recordId' : recordId
          }).then(result => {
              this.result = result;
              this.notificationList = result.NotificationList;
              this.notificationList = result.NotificationList.map(record => ({
                ...record,
                Department_System__c: record.Department_System__c ? record.Department_System__c : 'System',
                Method__c: record.Method__c ? record.Method__c : 'Both',
                isDepartmentNameEditable: record.Department_System__c === 'Department',
                isPhoneNumberEditable: record.Method__c === 'Both' || record.Method__c === 'Cell',
                isEmailAddressEditable: record.Method__c === 'Both' || record.Method__c === 'Email'


            }));
              this.showLoader = false;
              if(result.orderRecord.Park_Keys__c)
                this.showParkKeyFields = true;
              if(result.orderRecord.Speed_Calls__c)
                this.showSpeedCall = true;
              if(result.orderRecord.Group_Page__c)
                this.showGroupPage = true;
              if(result.orderRecord.DSS_BLF_Enhanced_Monitor_Extensions_Btns__c)
                this.showEmeb = true;
              console.log('result..!', result);
              console.log('zz departmen..!'+ JSON.stringify(this.notificationList));
              console.log('zzz noti list..!' + JSON.stringify(this.notificationList) );
          }).catch(error => {
              this.showToast('Error!', error.body.message, 'error', 'sticky');
              console.log('error..!', error);
          });
    }


    fetchftrDIDNumberDetailsDepartment() {
        // Make sure to have your orderId and RecordTypeId available
    
        ftrDIDNumberDetailsDepartment({ recordId: this.recordId })
            .then(result => {
                // Process your result here
                this.departmentnames = result.map(option => ({ label: option.Ucf_Department__c, value: option.Ucf_Department__c }));
                console.log('departmentnames :', this.departmentnames);
            })
            .catch(error => {
                // Handle your error here
                console.error('Error from Apex:', error);
                this.error = error;
            });
    }

    validateInputForName(event) {
        // Allow letters (uppercase and lowercase) and numbers
        const regex = /^[A-Za-z0-9 ]*$/;
    
        // Get the key pressed by the user
        const key = event.key;
    
        // Prevent input if the key pressed does not match the regex pattern
        if (!regex.test(key)) {
            event.preventDefault();
            return false;
        }
    }
    
    handleChange(event){
        this.fieldChangeCount++;
        this.notifyInputChange(this.fieldChangeCount);
        if(event.target.name == 'parkKeys'){
            this.result.orderRecord.Park_Keys__c = event.target.checked;
            if(event.target.checked){
                this.showParkKeyFields = true;
            }
              else{
                this.showParkKeyFields = false;
                this.result.orderRecord.How_many_park_keys__c = null;
                this.result.orderRecord.Is_it_shared_or_location_department__c = '';
              }
        } else if(event.target.name == 'howManyParkKeys'){
            this.result.orderRecord.How_many_park_keys__c = event.target.value;
        } else if(event.target.name == 'isItSharedLocation'){
            this.result.orderRecord.Is_it_shared_or_location_department__c = event.target.value;
        } else if(event.target.name == 'groupPage'){
            this.result.orderRecord.Group_Page__c = event.target.checked;
            if(event.target.checked) 
                this.showGroupPage = true;
              else
                this.showGroupPage = false;
        } else if(event.target.name == 'groupPickup'){
            this.result.orderRecord.Group_Pickup__c = event.target.checked;
        } else if(event.target.name == 'emeb'){
            this.result.orderRecord.DSS_BLF_Enhanced_Monitor_Extensions_Btns__c = event.target.checked;
            if(event.target.checked) 
                this.showEmeb = true;
            else
                this.showEmeb = false; 
        } else if(event.target.name == 'directPage'){
            this.result.orderRecord.Direct_Page__c = event.target.checked;
        } else if(event.target.name == 'speedCalls'){
            this.result.orderRecord.Speed_Calls__c = event.target.checked;
            if(event.target.checked) 
                this.showSpeedCall = true;
            else
                this.showSpeedCall = false; 
        } else if(event.target.name == 'additionalInfo'){
            this.result.orderRecord.Additional_UCF_Information__c = event.target.value;
        } 
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }

    handle911Notification(event){
        this.fieldChangeCount++;
        console.log(this.fieldChangeCount);
        this.notifyInputChange(this.fieldChangeCount);
        const recordId = event.target.dataset.recordId;
        const fieldName = event.target.dataset.fieldName;
        const newValue = event.target.value;


        this.notificationList = this.notificationList.map(record => {
            if (record.Id === recordId) {
                const updatedRecord = { ...record, [fieldName]: newValue };

                if (fieldName === 'Department_System__c') {
                    updatedRecord.isDepartmentNameEditable = newValue === 'Department';
                }

                return updatedRecord;
            }
            return record;
        });

        this.notificationList = this.notificationList.map(record => {
            if (record.Id === recordId) {
                record[fieldName] = newValue;
    
                // Update isPhoneNumberEditable based on Method__c value
                if (fieldName === 'Method__c') {
                    record.isPhoneNumberEditable = newValue === 'Both' || newValue === 'Cell';
                }
    
                return record;
            }
            return record;
        });


        this.notificationList = this.notificationList.map(record => {
            if (record.Id === recordId) {
                record[fieldName] = newValue;
    
                // Update isEmailAddressEditable based on Method__c value
                if (fieldName === 'Method__c') {
                    record.isEmailAddressEditable = newValue === 'Both' || newValue === 'Email';
                }
    
                return record;
            }
            return record;
        });
        
        const index = this.notificationList.findIndex(notificationList => notificationList.Id === recordId);
        if (index !== -1) {
            // Update the field value in the account data
            this.notificationList[index][fieldName] = newValue;
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
            console.log('draft values : '+JSON.stringify(this.draftValues));
        }
    }

    handleSave(){
        this.showLoader = true;

        


        this.draftValues.forEach(draft => {
            if (draft.Method__c === 'Cell') {
                draft.Email_Address__c = ''; // Clear the email address if method is 'Cell'
            } else if (draft.Method__c === 'Email') {
                draft.Phone_Number__c = ''; // Clear the cell phone field if method is 'Email'
            }

            if (draft.Department_System__c === 'System') {
                draft.Department_Name__c = ''; 
            }
        });

        this.notificationList = this.notificationList.map(notification => {
            const draft = this.draftValues.find(d => d.Id === notification.Id);
            if (draft) {
                if (draft.Method__c === 'Cell') {
                    notification.Email_Address__c = '';
                } else if (draft.Method__c === 'Email') {
                    notification.Phone_Number__c = ''; // Assuming the phone number field is named 'Phone_Number__c'
                }

                if (draft.Department_System__c === 'System') {
                    notification.Department_Name__c = '';
                }
            }
            return notification;
        });
        
        const invalidEmail = this.notificationList.some(record => {
            return record.isEmailAddressEditable && record.Email_Address__c && !this.isValidEmail(record.Email_Address__c);
        });
    
        if (invalidEmail) {
            this.showLoader = false;
            this.showToast('Error', 'One or more email addresses are invalid', 'error');
            return;
        }

        const invalidPhoneNumber = this.notificationList.some(draft => {
            return draft.Phone_Number__c && draft.Phone_Number__c.length < 10;
        });
    
        if (invalidPhoneNumber) {
            this.showLoader = false;
            console.log('zainab');
            this.showToast('Error', 'Phone number must be at least 10 digits long.', 'error');
            return; // Stop the save operation
        }


        for (let draft of this.draftValues) {
            if ((draft.Method__c === 'Both' || draft.Method__c === 'Cell') && !draft.Phone_Number__c) {
                // If method is Both or Cell, phone number must not be empty
                this.showLoader = false;
                this.showToast('Error', 'Phone number is required when method is "Both" or "Cell".', 'error');
                return; // Stop the operation
            }
            
            if ((draft.Method__c === 'Both' || draft.Method__c === 'Email') && !draft.Email_Address__c) {
                // If method is Both or Email, email address must not be empty
                this.showLoader = false;
                this.showToast('Error', 'Email address is required when method is "Both" or "Email".', 'error');
                return; // Stop the operation
            }
    
           
        }
        

        
        updateOrder({
            orderToUpdate : this.result.orderRecord
        }).then((result) => {
            this.showLoader = false;
            this.showToast('Success', 'Record Updated Successfully', 'success');
            this.fieldChangeCount=0;
            this.notifyInputChange(this.fieldChangeCount);
        }).catch((error) => {
            this.showLoader = false;
            this.showToast('Error', ' error: ' + JSON.stringify(error), 'error');
        });
        if (!this.isValidationFailed ){
        update911Notifications({
            updatedRecords : this.draftValues
        }).then((result) => {
            this.isValidationFailed = false;
            this.showLoader = false;
            this.showToast('Success', 'Record Updated Successfully', 'success');
            this.fieldChangeCount=0;
            this.notifyInputChange(this.fieldChangeCount);
            this.loadComponent(this.recordId);
        }).catch((error) => {
            this.showLoader = false;
            this.showToast('Error1', ' error: ' + JSON.stringify(error), 'error');
        });
    }
        
    }

    handleCancel(){
        this.loadComponent(this.recordId);
        this.fieldChangeCount=0;
        this.notifyInputChange(this.fieldChangeCount);
        this.nameAdd="";
        this.emailAdd="";
        this.methodAdd="";
        this.departmentnameAdd="";
        this.departmentsystemAdd="";
        this.phoneAdd="";
    }

    showToast(t, m, v){
        this.dispatchEvent(new ShowToastEvent({
            title: t,
            message: m,
            variant: v,
        }));
    }
   

    handleName(event) {
        this.fieldChangeCount++;
        console.log(this.fieldChangeCount);
        this.notifyInputChange(this.fieldChangeCount);
        this.nameAdd = event.target.value;
    }

    // Handler for Department System combobox
    handleDepartmentSystem(event) {
        this.fieldChangeCount++;
        console.log(this.fieldChangeCount);
        this.notifyInputChange(this.fieldChangeCount);
        this.departmentsystemAdd = event.target.value;
        this.isDepartmentNameAddEditable = this.departmentsystemAdd === 'Department';

    }

    // Handler for Department Name combobox
    handleDepartmentName(event) {
        this.fieldChangeCount++;
        console.log(this.fieldChangeCount);
        this.notifyInputChange(this.fieldChangeCount);
        this.departmentnameAdd = event.target.value;
    }

    // Handler for Method combobox
    handleMethod(event) {
        this.fieldChangeCount++;
        console.log(this.fieldChangeCount);
        this.notifyInputChange(this.fieldChangeCount);
        this.methodAdd = event.target.value;
        this.isPhoneNumberAddEditable = this.methodAdd === 'Both' || this.methodAdd === 'Cell';
        this.isEmailAddressAddEditable = this.methodAdd === 'Both' || this.methodAdd === 'Email';
    }

    // Handler for Phone Number input field
    handlePhone(event) {
        this.fieldChangeCount++;
        console.log(this.fieldChangeCount);
        this.notifyInputChange(this.fieldChangeCount);
        this.phoneAdd = event.target.value;
    }

    // Handler for Email Address input field
    handleEmail(event) {
        this.fieldChangeCount++;
        console.log(this.fieldChangeCount);
        this.notifyInputChange(this.fieldChangeCount);
        this.emailAdd = event.target.value;
    }


    handleAdd(){
        if(this.nameAdd){

            const isDuplicate = this.notificationList.some(detail =>
                detail.Name.toLowerCase() === this.nameAdd.toLowerCase()

            );
            if (isDuplicate) {
                // Alert the user that the webinar value is already selected
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Duplicate Name',
                        message: 'Please enter a Name',
                        variant: 'error'
                    })
                );
                return;
            }

            if ((this.methodAdd === 'Both' || this.methodAdd === 'Cell') && (!this.phoneAdd || this.phoneAdd.length < 10)) {
                // Show error toast for invalid phone number
                this.showToast('Error', 'Phone number must be at least 10 digits long.', 'error');
                return; // Stop the save operation
            }

            if (this.emailAdd && !this.isValidEmail(this.emailAdd)) {
                // Show error toast for invalid email
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'The provided email address is not valid.',
                        variant: 'error',
                    })
                );
                return; // Stop the save operation
            }

            if ((this.methodAdd === 'Both' || this.methodAdd === 'Email') && !this.emailAdd) {
                // If method is Both or Email, email address must not be empty
                this.showToast('Error', 'Email address is required when method is "Both" or "Email".', 'error');
                return; // Stop the operation
            }
/*
            if (this.phoneAdd && this.phoneAdd.length < 10) {
                this.showToast('Error', 'Phone number must be at least 10 digits long.', 'error');
                //this.isValidationFailed=true;

                return;
            }*/

            let phoneNumberToSend = this.phoneAdd ? this.phoneAdd : null;
            
            if (!this.isValidationFailed ){
            insertNotification({
                name: this.nameAdd,
                departmentSystem: this.departmentsystemAdd,
                departmentName: this.departmentnameAdd,
                method: this.methodAdd,
                phoneNumber: phoneNumberToSend,
                emailAddress: this.emailAdd,
                recordId: this.recordId
            })
            .then(result => {
                // Display success toast
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: result,
                        variant: 'success',
                    })
                );

                const newNotification = {
                    // ... construct your new notification object with the fields you expect
                    isPhoneNumberEditable: this.methodAdd === 'Both' || this.methodAdd === 'Cell',
                    isEmailAddressEditable: this.methodAdd === 'Both' || this.methodAdd === 'Email'
                };
                this.notificationList = [...this.notificationList, newNotification];
                this.isValidationFailed = false;
                this.fieldChangeCount=0;
                this.notifyInputChange(this.fieldChangeCount);
                this.loadComponent(this.recordId);
                this.nameAdd = '';
                this.departmentsystemAdd = 'System';
                this.departmentnameAdd = '';
                this.methodAdd = 'Both';
                this.phoneAdd = '';
                this.emailAdd = '';
                this.isPhoneNumberAddEditable = true;
                this.isEmailAddressAddEditable = true;
                this.isDepartmentNameAddEditable = false;
                
            })
            .catch(error => {
                // Display error toast
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });

        }

        }
        else {
            const toast = new ShowToastEvent({
                title: 'Error',
                message: 'Please fill Name field to create a record!',
                variant: 'error'
            });
            this.dispatchEvent(toast);
        }
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

    isValidEmail(email) {
        // Regular expression for email validation
        const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        return emailPattern.test(email);
    }

    notifyInputChange(count){
        this.dispatchEvent(new CustomEvent('recordchange', {
            detail: {
                component: 'customizationsNotesUcf',
                message: count
            }
        }));
    }
    

}