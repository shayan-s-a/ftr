import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
import queryAccounts from '@salesforce/apex/FetchData.queryAccounts';
import queryAccounts2 from '@salesforce/apex/FetchData.queryAccounts2';
import ftrDIDNumberDetailsEmployeeInfo from '@salesforce/apex/FetchData.ftrDIDNumberDetailsEmployeeInfo';
import loadCSVDataForEmployeeInfo from '@salesforce/apex/FetchData.loadCSVDataForEmployeeInfo';
import updateftrDIDNumberDetailsEmployeeTab from '@salesforce/apex/FetchData.updateftrDIDNumberDetailsEmployeeTab';
import ordetQuoteCounts from '@salesforce/apex/UcfEmpInfoController.ordetQuoteCounts';
import getMDNOptions from '@salesforce/apex/UcfEmpInfoController.getMDNOptions';
import getProductPicklistsAndCountsBySubtype from '@salesforce/apex/UcfEmpInfoController.getProductPicklistsAndCountsBySubtype';
import isTranslationUser from '@salesforce/apex/PmEnrichmentController.isTranslationUser';
import getLisenceAccessoriesPL from '@salesforce/apex/UcfEmpInfoController.getLisenceAccessoriesPL';
import getDeviceTypes from '@salesforce/apex/UcfEmpInfoController.getDeviceTypes';
import getOrderItemsBySubType from '@salesforce/apex/UcfEmpInfoController.getOrderItemsBySubType';
import hasCallRecording from '@salesforce/apex/UcfEmpInfoController.hasCallRecording';
//import getAggregateCountsss from '@salesforce/apex/UcfEmpInfoController.getAggregateCounts';
import getProductTypes from '@salesforce/apex/UcfEmpInfoController.getProductTypes';
//import getCurrentOrderStage from  '@salesforce/apex/PmEnrichmentController.getOrderStage';
import ftrDIDNumberDetails from '@salesforce/apex/FetchData.ftrDIDNumberDetails';

import getQuantitiesForProductType from '@salesforce/apex/UcfEmpInfoController.getQuantitiesForProductType';
import getQuantitiesForVlocitySubType from '@salesforce/apex/UcfEmpInfoController.getQuantitiesForVlocitySubType';
import getQuantitiesForSpecificationSubType from '@salesforce/apex/UcfEmpInfoController.getQuantitiesForSpecificationSubType';
import getQuantitiesForCallRecordingType from '@salesforce/apex/UcfEmpInfoController.getQuantitiesForCallRecordingType';
import getQuantitiesForAudioMining from '@salesforce/apex/UcfEmpInfoController.getQuantitiesForAudioMining';
import getQuantitiesForScreenRecodring from '@salesforce/apex/UcfEmpInfoController.getQuantitiesForScreenRecodring';





import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    refreshApex
} from "@salesforce/apex";

const columns = [{
        label: 'Schedule Name',
        fieldName: 'Name',
        type: 'text',
        editable: true
    },
    {
        label: '',
        type: "button",
        typeAttributes: {
            label: '',
            name: 'Delete',
            title: '',
            disabled: false,
            iconPosition: 'left',
            iconName: 'utility:delete'
        }
    }
];

const columnsEI = [{
        label: 'Phone Number',
        fieldName: 'Id',
        type: 'text'
    },
    {
        label: 'Extension',
        fieldName: 'Name',
        type: 'text'
    },
    {
        label: 'User Name',
        fieldName: 'BillingCity',
        type: 'text'
    },
    {
        label: 'Email',
        fieldName: 'Account_Owner_Email__c',
        type: 'text'
    },
    {
        label: 'User Admin',
        fieldName: 'Account_Channel__c',
        type: 'text'
    },
    {
        label: 'Department',
        fieldName: 'vlocity_cmt__Status__c',
        type: 'text'
    },
    {
        label: 'Outbound Caller ID',
        fieldName: 'Agent_Fax_Number__c',
        type: 'text'
    },
];
export default class EmployeInformationLWC extends LightningElement {
    @api recordId;
    accounts;
    accounts2;
    error;
    ftrDIDNumberDetailsEmployeeInfo;
    value = '';
    
    licenceCount = 0;
    deviceCount = 0;
    
   @track length = 0;
     @track obj = { Ucf_Audio_Mining__c: 'No', Ucf_Screen_Recording__c: 'No' }; 
    @track draftValues = [];
    @track showDualListboxModal = false;
    @track selectedItems = [];
    @track selectedItemsCount = 0;
    @track selectedOption = 'Employee Info';
    @track employeeinfo = 'Employee Info';
    @track deviceinfo = '';
    @track nine11info = '';
    @track licenseinfo = '';
    @track fulltable = '';
    @track storageProducts;
       @track storageProductsCR = [];
    @track audioMiningProducts = [];
    @track screenRecordingProducts = [];
    @track fileName = 'Employee Info';
     @track orderItemCounts;
    Translation='';
    // @track empInfoSelected = '';
    @track accountList = [];
    @track mdnOptions = [];
    @track webinarProducts = [];
    @track collabProducts = [];
    @track deviceTypeOptions = [];
    @track deviceOptions = [];
    @track ataDeviceOptions = [];
    
  collaborationQuantitiesData;
  callRecordingQuantitiesData;
 audioMiningQuantitiesData;
 screenRecordingQuantitiesData;
  storageQuantities;
  webinarQuantitiesData;
  assesQuantitiesData;
  licenseQuantitiesData;
conferenceModelsQuantitiesData
  polyPhonesQuantitiesData
  yealinkQuantitiesData
  ataQuantitiesData
ftrDIDNumberDetails=[];
    
    @track accessoriesOptions = [];
      @track productQuantities = [];
    
    @track licenseOptions = [];
    @track isValidationFailed = false;



@track deviceTypeCount = 0;
@track accessoriesCount = 0;
@track licenseCount = 0;
  @track webinarCount = 0;
@track collabCount = 0;
@track callRecordingCount = 0;
@track isOrderInProgressOrCompleted = false;
 
  
 fieldChangeCount=0;
    

     @track specificationSubTypeQuantities;
    @track accessoriesQuantities;
    @track licenseQuantities;
    @track webinarQuantities;
    @track collaborationQuantities;
    @track callRecordingQuantities;
 
    @track isTranslation;
    @track isReadOnly;
    @track isShowReadOnlyTable;
    @track comboValues;
    dailPlanOptions;
    showCallRecording = false;
    sortColumn;
    sortDir=1;
    sortDirection='asc';
    N11;
    showLoader=false;
    @api isnetworktranslation=false;
    flagOtherCallerId = false;
    sortIcon = 'utility:arrowup';
    @track dualListboxOptions = [{
            label: 'Option 1',
            value: 'Option1'
        },
        {
            label: 'Option 2',
            value: 'Option2'
        },
    ];
    @track wiredRecords;

    @track obj = {
        Ucf_User_Admin__c: 'No' // Default value
    };

    get options() {
        return [{
                label: 'No',
                value: 'No'
            },
            {
                label: 'BGRP',
                value: 'BGRP'
            },
            {
                label: 'Dept',
                value: 'Dept'
            }
        ];
    }

    comboValues = [{
            label: 'Select an option',
            value: ''
        },
        {
            label: 'Yes',
            value: 'Yes'
        },
        {
            label: 'No',
            value: 'No'
        }
    ];
     validStateAbbreviations  = [
        'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 
        'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 
        'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 
        'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 
        'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY'
    ];


    dailPlanOptions = [{
            label: 'Select an option',
            value: ''
        },
        {
            label: 'National and Canada',
            value: 'National and Canada'
        },
        {
            label: 'International',
            value: 'International'
        }
    ];

    dailPlanOptions = [{
            label: 'Select an option',
            value: ''
        },
        {
            label: 'National and Canada',
            value: 'National and Canada'
        },
        {
            label: 'International',
            value: 'International'
        }
    ];
    
    sortEmployeeInfo(event) {

        this.sortColumn = event.currentTarget.dataset.fieldName;
        
        this.sortDirection = this.sortColumn === this.sortColumn && this.sortDirection === 'asc' ? 'desc' : 'asc';
        this.sortData();
    }
    sortData() {
    
        const field = this.sortColumn;
        const reverse = this.sortDirection === 'desc' ? -1 : 1;
        this.ftrDIDNumberDetailsEmployeeInfo = [...this.ftrDIDNumberDetailsEmployeeInfo.sort((a, b) => (a[field] > b[field] ? 1 : -1) * reverse)];
        
        
    }
  

    @wire(getOrderItemsBySubType, {
        orderId: '$recordId'
    })
  wiredOrderItems({ error, data }) {
    if (data) {
        this.collabProducts = this.doProcessProducts(data, 'Collaboration');
        this.webinarProducts = this.doProcessProducts(data, 'Webinar');
        this.storageProducts = this.doProcessProducts(data, 'Call Recording');
    } else if (error) {
        console.error(error);
    }
}

doProcessProducts(data, subtype) {
 const products = data
        .filter(item => item.Product2.vlocity_cmt__SubType__c === subtype)
        .map(item => ({ label: item.Product2.Name, value: item.Product2.Name }));

    // Always add 'None' at the end of the list
    products.push({ label: 'None', value: 'None' });
    return products;
}


     @wire(getQuantitiesForProductType, { orderId: '$recordId', productType: 'License' })
    wiredLicenseQuantities({ error, data }) {
        if (data) {
            this.licenseQuantitiesData = data;
        } else if (error) {
           
        }
    }

    @wire(getQuantitiesForProductType, { orderId: '$recordId', productType: 'Accessories' })
    wiredassesQuantitiesData({ error, data }) {
        if (data) {
            this.assesQuantitiesData = data;
        } else if (error) {
           
        }
    }
    @wire(getQuantitiesForVlocitySubType, { orderId: '$recordId', vlocitySubType: 'Webinar' })
    wiredWebinarQuantities({ error, data }) {
        if (data) {
            this.webinarQuantitiesData = data;
          // alert('test 1 '+JSON.stringify(this.webinarQuantitiesData ));
            
        } else if (error) {
            
        }
    }
     @wire(getQuantitiesForVlocitySubType, { orderId: '$recordId', vlocitySubType: 'Collaboration' })
    wiredCollaborationQuantities({ error, data }) {
        if (data) {
            this.collaborationQuantitiesData = data;
            
         //   alert('test 1 '+JSON.stringify(this.collaborationQuantitiesData ));
        } else if (error) {
            
        }
    }
     @wire(getQuantitiesForVlocitySubType, { orderId: '$recordId', vlocitySubType: 'Call Recording' })
    wiredCollaborationQuantities({ error, data }) {
        if (data) {
            this.storageQuantities = data;
            
           // alert(JSON.stringify(this.collaborationQuantitiesData ));
        } else if (error) {
            
        }
    }

@wire(getQuantitiesForCallRecordingType, { orderId: '$recordId', productName: 'UCF Call Recording Basic' })
wiredCallRecordingQuantities({ error, data }) {
    if (data) {
         //  alert('before '+ JSON.stringify(data));
        this.callRecordingQuantitiesData = this.transformToDesiredFormat(data);
    } else if (error) {
        // Handle error
    }
}


@wire(getQuantitiesForAudioMining, { orderId: '$recordId'})
wiredAudioMiningQuantities({ error, data }) {
    if (data) {
        this.audioMiningQuantitiesData = data;
    } else if (error) {
        // Handle error
    }
}


@wire(getQuantitiesForScreenRecodring, { orderId: '$recordId' })
wiredForScreenRecodringQuantities({ error, data }) {
    if (data) {
        this.screenRecordingQuantitiesData = data;
    } else if (error) {
        // Handle error
    }
}


transformToDesiredFormat(data) {
    // Initialize an empty object to store the transformed data
    const transformedData = {};

    // Iterate over the keys in the data object
    for (let productName of Object.keys(data)) {
        // For the specific product 'UCF Call Recording Basic', set the key as 'Yes'
        if (productName === 'UCF Call Recording Basic') {
            transformedData['Yes'] = data[productName];
        } else {
            // For all other products, use their name as the key
            transformedData[productName] = data[productName];
        }
    }

    return transformedData;
}





        @wire(getQuantitiesForSpecificationSubType, { orderId: '$recordId', subtypes: 'Conference Models' })
    wiredconferenceModelsQuantities({ error, data }) {
        if (data) {
            this.conferenceModelsQuantitiesData = data;
        } else if (error) {
        }
    }

        @wire(getQuantitiesForSpecificationSubType, { orderId: '$recordId', subtypes: 'poly phones' })
    wiredpolyPhonesQuantities({ error, data }) {
        if (data) {
            this.polyPhonesQuantitiesData = data;
        } else if (error) {
        }
    }

          @wire(getQuantitiesForSpecificationSubType, { orderId: '$recordId', subtypes: 'yealink phones' })
    wiredyealinkQuantities({ error, data }) {
        if (data) {
            this.yealinkQuantitiesData = data;
        } else if (error) {
        }
    }

          @wire(getQuantitiesForSpecificationSubType, { orderId: '$recordId', subtypes: 'ATA' })
    wiredataQuantities({ error, data }) {
        if (data) {
            this.ataQuantitiesData = data;
        } else if (error) {
        }
    }


   
    connectedCallback() {
       // alert('here');
    this.showLoader=true;
    //this.loadAggregateCounts();
        this.loadDeviceTypes();
        this.checkCallRecording();
        this.fetchMDNOptions();
        this.fetchProductTypes();
        this.fetchftrDIDNumberDetailsEmployeeInfo();
        //this.ftrDIDNumberDetail();
        
    }
    // getOrderStage()
    // {
    //     getCurrentOrderStage({recordId: this.recordId}).then(result=>{
    //         if(result.length > 0){
    //         if(result == 'In Progress' ||result == 'Complete')
    //         {
    //             this.isOrderInProgressOrCompleted = true;
    //         }
    //         console.log('order stage is = '+ result);
    //         console.log('order stage flag is = '+ this.isOrderInProgressOrCompleted);   
    //         }
    //     }).catch(error=>{
    //         console.log(' Current Order Stage Error', error);
    //         });
    // }
    checkCallRecording() {
        hasCallRecording({ orderId: this.recordId })
            .then(result => {
                if (result) {
                    this.showCallRecording = result;
                }
            })
            .catch(error => {
                this.error = error;
                console.error(error);
            });
    }
/*
      loadAggregateCounts() {
        getAggregateCounts({ orderId: this.recordId })
            .then(result => {
                  this.orderItemCounts = JSON.parse(result);
                  
                  this.deviceTypeCount = this.orderItemCounts.deviceTypeSum;
                  this.accessoriesCount = this.orderItemCounts.accessoriesSum;
                  this.licenseCount = this.orderItemCounts.licenseSum;
                  this.webinarCount = this.orderItemCounts.webinarSum;
                  this.collabCount = this.orderItemCounts.collaborationSum;
                  this.callRecordingCount = this.orderItemCounts.callRecordingSum;

            })
            .catch(error => {
                console.error('Error2s:', error);
            });
    } */
    
    loadAggregateCounts() {
       // alert('Hello');
        getAggregateCounts({orderId: this.recordId })
            .then(result => {
                this.productQuantities = result;
                JSON.stringify(this.productQuantities );
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }


 fetchProductTypes() {
     
        getProductTypes({orderId: this.recordId })
            .then(result => {
                this.storageProductsCR = result.storage && result.storage.length > 0 ? [...result.storage, 'UCF Call Recording Basic'] : ['UCF Call Recording Basic'];
                // this.storageProductsCR.push({ label: 'None', value: 'None' });
                this.audioMiningProducts = result.audioMining && result.audioMining.length > 0 ? [...result.audioMining, 'No'] : ['No'];
                this.screenRecordingProducts = result.screenRecording && result.screenRecording.length > 0 ? [...result.screenRecording, 'No'] : ['No'];
            })
            .catch(error => {
                this.error = error;
                console.error('Error:', error);
            });
    }

    get storageProductsOptions() {
        return this.storageProductsCR.map(product => ({ label: product, value: product }));
    }

    get audioMiningOptions() {
        return this.audioMiningProducts.map(product => ({ label: product, value: product }));
    }

    get screenRecordingOptions() {
        return this.screenRecordingProducts.map(product => ({ label: product, value: product }));
    }

/*
    @wire(getDeviceTypes, {
        orderId: '$recordId'
    })
wiredDeviceTypes({ error, data }) {
  
    if (data) {
        this.deviceOptions = data.map(item => {
            return {
                label: item.Product2.Name,
                value: item.Product2Name
            };
        });
    } 
  
  this.deviceOptions.push({ label: 'None', value: 'None' });
  console.log('Device Option: ' + JSON.stringify(this.deviceOptions));


    if (error) {
        console.error(error);
    }
}*/

loadDeviceTypes() {
    getDeviceTypes({ orderId: this.recordId })
        .then(result => {
            // Initialize deviceOptions if it doesn't exist or it's not an array
            if (!Array.isArray(this.deviceOptions)) {
                this.deviceOptions = [];
            }

            // Append new device options to the existing list
            const newOptions = result.map(item => {
                return {
                    label: item.Product2.Name,
                    value: item.Product2.Name
                };
            });

            this.deviceOptions = [...this.deviceOptions, ...newOptions];

            // Optionally, add 'None' option if it's not already in the list
            if (!this.deviceOptions.some(option => option.value === 'None')) {
                this.deviceOptions.push({ label: 'None', value: 'None' });
            }

            const ataFilteredOptions = result.filter(item => item.Product2.vlocity_cmt__SpecificationSubType__c === 'ATA')
                                             .map(item => ({
                                                 label: item.Product2.Name,
                                                 value: item.Product2.Name
                                             }));

            this.ataDeviceOptions = [...this.ataDeviceOptions, ...ataFilteredOptions];

            // Uncomment the alert for debugging, remove or comment out in production
            // alert('Device Options: ' + JSON.stringify(this.deviceOptions));
            // alert('ATA Device Options: ' + JSON.stringify(this.ataDeviceOptions));
        
        })
        .catch(error => {
            console.error(error);
        });
}




    @wire(getLisenceAccessoriesPL, {
        orderId: '$recordId'
    })
    wiredItems({
        error,
        data
    }) {
        this.accessoriesOptions = [{ label: 'None', value: 'None' }];
        this.licenseOptions = [{ label: 'None', value: 'None' }];
        if (data) {
            data.forEach(item => {
                let option = {
                    label: item.Product2.Name,
                    value: item.Product2.Name
                };
                if (item.Product_Type__c === 'Accessories') {
                    this.accessoriesOptions.push(option);
                } else if (item.Product_Type__c === 'License') {
                    this.licenseOptions.push(option);
                }
            });
        } else if (error) {
            console.error(error);
        }
    }
    validateInputForNumber(event) {
        const regex = new RegExp("^[0-9]*$");

        // Get the key pressed by the user
        const key = String.fromCharCode(!event.charCode ? event.which : event.charCode);

        // Prevent input if the key pressed is not a digit
        if (!regex.test(key)) {
            event.preventDefault();
            return false;
        }
    }
    @wire(ordetQuoteCounts, {
        orderId: '$recordId'
    })
    wiredQuoteOrder({
        error,
        data
    }) {
        if (data) {
            // console.log('DATA: ' + JSON.stringify(data));

            // Check if data[0] exists and has a Quote before trying to access RCDeviceCount__c
            if (data[0] && data[0].Quote) {
                this.licenceCount = data[0].Quote.RCLicenseCount__c;
                this.deviceCount = data[0].Quote.RCDeviceCount__c;
                //console.log('licenceCount: ' + this.licenceCount);
                // console.log('DeviceCount: ' + this.RCDeviceCount__c);
            } else {
                //console.error('Either data[0] is undefined or it does not have a Quote relationship');
            }

            this.accounts = data;
        } else if (error) {
            this.error = error;
        }
       
    }
    fetchMDNOptions() {
        getMDNOptions({
                orderId: this.recordId
            })
            .then(data => {
                if (data) {
                    this.mdnOptions = data.map(mdn => ({
                        label: mdn,
                        value: mdn
                    }));
                }
            })
            .catch(error => {
                console.error('Error retrieving MDN options:', error);
            });
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


    fetchftrDIDNumberDetailsEmployeeInfo() {
        ftrDIDNumberDetailsEmployeeInfo({
                recordId: this.recordId
            }) // Replace 'getPremises' with your actual data fetching method
            .then(data => {
                console.log('Data fetched: ', data);
                if (data) {
                    console.log('Data : ' + JSON.stringify(data));
                    this.processftrDIDNumberDetailsEmployeeInfo(data);
                }
            })
            .catch(error => {
                this.error = error;
                // Handle the error here
            });
    }

    processftrDIDNumberDetailsEmployeeInfo(data) {
        const mainMDNOptions = this.mdnOptions;
        // let getwebCount = 0;
        this.ftrDIDNumberDetailsEmployeeInfo = data.map((ftr_DID_Number_Details__c, index) => {
           // let extLength = parseInt(ftr_DID_Number_Details__c.Ucf_Extension_Lenght__c);
            //this.length = extLength;

               let extLength = parseInt(ftr_DID_Number_Details__c.Ucf_Extension_Lenght__c);
            console.log('extLength: '+ extLength);
             if (extLength === null || extLength === undefined || extLength === '') {
                extLength = 0;
            }
            
            let phoneOption = {
                label: ftr_DID_Number_Details__c.DIDNumber__c,
                value: ftr_DID_Number_Details__c.DIDNumber__c
            };
           
             let webinarValue = ftr_DID_Number_Details__c.Ucf_Webinar__c;
        if (!webinarValue || webinarValue === '' || webinarValue === 'undefined') {
            webinarValue = 'None';
        }

           
             let licenseValue = ftr_DID_Number_Details__c.Ucf_License_Type__c;
        if (!licenseValue || licenseValue === '' || licenseValue === 'undefined') {
            licenseValue = 'None';
        }

              let collaborationValue = ftr_DID_Number_Details__c.Ucf_Collaboration__c;
        if (!collaborationValue || collaborationValue === '' || collaborationValue === 'undefined') {
            collaborationValue = 'None';
        }
            
             let dailPlanValue = ftr_DID_Number_Details__c.Ucf_Dial_Plan_Information__c;
           //  alert('dailPlanValue '+ dailPlanValue);
        if (!dailPlanValue || dailPlanValue === '' || dailPlanValue === 'undefined' || dailPlanValue === 'National and Canada') {
            dailPlanValue = 'National and Canada';
        }




              let audioMiningValue = ftr_DID_Number_Details__c.Ucf_Audio_Mining__c;
        if (!audioMiningValue || audioMiningValue === '' || audioMiningValue === 'undefined') {
            audioMiningValue = 'No';
        }

        
              let screenRecordingValue = ftr_DID_Number_Details__c.Ucf_Screen_Recording__c;
        if (!screenRecordingValue || screenRecordingValue === '' || screenRecordingValue === 'undefined') {
            screenRecordingValue = 'No';
        }

              let callRecValue = ftr_DID_Number_Details__c.Ucf_Call_Recording__c;
        if (!callRecValue || callRecValue === '' || callRecValue === 'undefined') {
            callRecValue = 'No';
        }
               let storageValue = ftr_DID_Number_Details__c.Ucf_Storage__c;
        if (!storageValue || storageValue === '' || storageValue === 'undefined') {
            if(callRecValue === 'Yes')
            {
                 storageValue = 'UCF Call Recording Basic';
            }
           
        }
        

              if (ftr_DID_Number_Details__c.Ucf_License_Type__c === "UCF Inbound WebFax DID") {
                if (!this.deviceOptions.some(option => option.value === 'eFAX')) 
                 {
                    this.deviceOptions.push({ label: 'eFAX', value: 'eFAX' });
                      
                 }

                 
                  if (ftr_DID_Number_Details__c.Ucf_Device_Type__c !== "eFAX") {
                      ftr_DID_Number_Details__c.Ucf_Device_Type__c = "eFAX";
                  }
              
        } 
         if (ftr_DID_Number_Details__c.Ucf_License_Type__c === "UCF Executive") {
              if (!this.deviceOptions.some(option => option.value === 'Softphone')) 
                 {
                    this.deviceOptions.push({ label: 'Softphone', value: 'Softphone' });
                 }
                   // alert('ucf exective device type value ' + ftr_DID_Number_Details__c.Ucf_Device_Type__c );
                  if (ftr_DID_Number_Details__c.Ucf_Device_Type__c === "Softphone") {
                      ftr_DID_Number_Details__c.Ucf_Device_Type__c = "Softphone";
                  }
              
           
        }

         if (ftr_DID_Number_Details__c.Ucf_License_Type__c !== "UCF Executive") {
            
            collaborationValue = "None";
             webinarValue = "None";
        }



            let rowMDNOptions = [phoneOption, ...mainMDNOptions];
            rowMDNOptions.push({ label: 'Other', value: 'Other' });
            let ext = ftr_DID_Number_Details__c.DIDNumber__c.slice(-extLength);
            
            let N11;
            if (ext && ext.length >= 3) {
                N11 = ext.slice(-2);
            }
           // let N11 = ext.slice(-2);

            let showAdditionalColumns  = ftr_DID_Number_Details__c.Ucf_Call_Recording__c === 'Yes';
            let showOtherCallerId  = ftr_DID_Number_Details__c.Outbound_Caller_ID__c === 'Other';

            let showCollabWebinar = false;;
            if (ftr_DID_Number_Details__c.Ucf_License_Type__c === "UCF Executive") {
                showCollabWebinar = true;
            }


            let state = ftr_DID_Number_Details__c.Ucf_State__c;
            if (state && state.length > 2) {
            state = state.slice(0, 2);
                }

            return {
                ...ftr_DID_Number_Details__c,
                editMode: true,
                N11: N11 == '11' ? true : false,
                slicedExtension: ext,
                mdnPicklistOptions: rowMDNOptions,
                key: `key-${index}`, // Unique key
                mdnPicklistId: `mdnPicklist-${index}`,
                // Remaining fields
                Ucf_Department__c: ftr_DID_Number_Details__c.Ucf_Department__c || '',
                DIDNumber__c: ftr_DID_Number_Details__c.DIDNumber__c || '',
                Ucf_User_Name__c: ftr_DID_Number_Details__c.Ucf_User_Name__c || '',
                Ucf_Extension__c: ftr_DID_Number_Details__c.Ucf_Extension__c || '',
                Ucf_Email__c: ftr_DID_Number_Details__c.Ucf_Email__c || '',
                Ucf_Company_Name__c: ftr_DID_Number_Details__c.Ucf_Company_Name__c || '',
                Ucf_Address_Number__c: ftr_DID_Number_Details__c.Ucf_Address_Number__c || '',
                Ucf_Street_Name__c: ftr_DID_Number_Details__c.Ucf_Street_Name__c || '',
                Ucf_City__c: ftr_DID_Number_Details__c.Ucf_City__c || '',
                Ucf_State__c: ftr_DID_Number_Details__c.Ucf_State__c || '',
                Ucf_State__c: state || '', // Updated state field
                Ucf_Zip_Code__c: ftr_DID_Number_Details__c.Ucf_Zip_Code__c || '',
                EAS_Pin__c: ftr_DID_Number_Details__c.EAS_Pin__c || '',
                 Ucf_Other_Outbound_Caller_ID__c: ftr_DID_Number_Details__c.Ucf_Other_Outbound_Caller_ID__c || '',
                Ucf_MAC_Address__c:ftr_DID_Number_Details__c.Ucf_MAC_Address__c || '',
                showAdditionalColumns : showAdditionalColumns , // Add this line,
                showCollabWebinar: showCollabWebinar,
                showOtherCallerId : showOtherCallerId,
                Ucf_Audio_Mining__c: audioMiningValue,
                Ucf_Webinar__c : webinarValue, 
                Ucf_Dial_Plan_Information__c : dailPlanValue,
                 Ucf_Collaboration__c : collaborationValue,
                Ucf_Screen_Recording__c: screenRecordingValue,
                Ucf_Call_Recording__c : callRecValue,
                Ucf_Storage__c : storageValue || '',
                Ucf_License_Type__c : licenseValue,
                Ucf_Identifying_Location__c: ftr_DID_Number_Details__c.Ucf_Identifying_Location__c || ''
            };
        });

        this.showLoader=false;
        // Add any additional logic here if needed
    }



    handleMDNChange(event) {
        const selectedMDN = event.target.value;
        const selectId = event.target.name; // This will now have values like 'mdnPicklist-0', 'mdnPicklist-1', etc.
        // Add your logic here to handle the change
    }

    @wire(queryAccounts2)
    wiredAccounts2({
        error,
        data
    }) {
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


 value = 'Employee Info';
    get options3() {
        
        if(this.isTranslation === true || this.isReadOnly === true){
            return [{
                label: 'Employee Info',
                value: 'Employee Info'
            },
            {
                label: 'License Info',
                value: 'License Info'
            },
            {
                label: 'Device Info',
                value: 'Device Info'
            },
            {
                label: '911 Info',
                value: '911 Info'
            },
            {
                label: 'Full Table',
                value: 'Full Table'
            },
            {
                label: 'Translation',
                value: 'Translation'
            },
        ];
        }
        else{
            return [{
                label: 'Employee Info',
                value: 'Employee Info'
            },
            {
                label: 'License Info',
                value: 'License Info'
            },
            {
                label: 'Device Info',
                value: 'Device Info'
            },
            {
                label: '911 Info',
                value: '911 Info'
            },
            {
                label: 'Full Table',
                value: 'Full Table'
            },
        ];
        }
    }

   

    handleComboboxChange(event) {
        this.selectedOption = event.detail.value;
        if (this.selectedOption === 'Translation') {
            //this.Translation=this.selectedOption;
            if(this.isTranslation === true)
            {
                this.Translation = true; 
                this.isShowReadOnlyTable = false;
            }
            else if(this.isReadOnly === true){
                this.Translation = false; 
                this.isShowReadOnlyTable = true;
            }
            this.employeeinfo = false;
            this.fileName = this.Translation;
            this.nine11info = false;
            this.deviceinfo = false;
            this.licenseinfo = false;
            this.fulltable = false;
        }
        else if (this.selectedOption === 'Employee Info') {
            this.employeeinfo = this.selectedOption;
            this.fileName = this.employeeinfo;
            this.nine11info = false;
            this.deviceinfo = false;
            this.licenseinfo = false;
            this.fulltable = false;
            this.Translation=false;
            this.isShowReadOnlyTable = false;
        } else if (this.selectedOption === 'Device Info') {
            this.deviceinfo = this.selectedOption;
            this.fileName = this.deviceinfo;
            this.employeeinfo = false;
            this.nine11info = false;
            this.licenseinfo = false;
            this.fulltable = false;
            this.Translation=false;
            this.isShowReadOnlyTable = false;
        } else if (this.selectedOption === 'License Info') {
            this.licenseinfo = this.selectedOption;
            this.fileName = this.licenseinfo;
            this.deviceinfo = false;
            this.employeeinfo = false;
            this.nine11info = false;
            this.fulltable = false;
            this.Translation=false;
            this.isShowReadOnlyTable = false;
        } else if (this.selectedOption === '911 Info') {
            this.nine11info = this.selectedOption;
            this.fileName = this.nine11info;
            this.deviceinfo = false;
            this.employeeinfo = false;
            this.licenseinfo = false;
            this.fulltable = false;
            this.Translation=false;
            this.isShowReadOnlyTable = false;
        } else if (this.selectedOption === 'Full Table') {
            this.deviceinfo = false;
            this.employeeinfo = false;
            this.nine11info = false;
            this.licenseinfo = false;
            this.fulltable = this.selectedOption;
            this.fileName = this.fulltable;
            this.Translation=false;
            this.isShowReadOnlyTable = false;
        }

    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    openDualListbox(event) {
        // const rowIndex = event.target.getAttribute('data-row-index');
        //const row = this.data[rowIndex];
        const rowIndex = event.target.getAttribute('data-row-index');
        const account = this.accounts2[rowIndex];
        this.selectedAccount = account; // Store the account being edited
        this.showDualListboxModal = true;
        // this.showDualListboxModal = true;
    }
    closeDualListbox() {
        this.showDualListboxModal = false;
    }

    handleChangeDualListboxModal(event) {
        //this.selectedItems = event.detail.value;
        //this.selectedItemsCount = this.selectedItems.length;
        this.selectedAccount.selectedItems = event.detail.value; // Update the selected items for the specific account
        this.selectedAccount.selectedItemsCount = this.selectedAccount.selectedItems.length;

    }
    handleCancel() {
        this.fetchftrDIDNumberDetailsEmployeeInfo();
        this.fieldChangeCount=0;
        this.notifyInputChange(this.fieldChangeCount);
    }

    exportCSV() {
        console.log('OUTPUT this.ftrDIDNumberDetailsEmployeeInfo : ', JSON.stringify(this.ftrDIDNumberDetailsEmployeeInfo));
        let csv = 'Id, Phone Number,';
        if (this.employeeinfo) {
            csv += 'Extension, User Name, Email, User Admin, Department, Outbound Caller ID,Other Outbound Caller IDs\n';
        } else if (this.licenseinfo) {
            csv += 'Extension, User Name, License Type, Dial Plan Information, Collaboration, Webinar, Call Recording, Audio Mining, Screen Recording, Storage\n';
        } else if (this.deviceinfo) {
            csv += 'Extension, User Name, License Type, Device Type, Device Accessories\n';
        } else if (this.nine11info) {
            csv += 'User Name, Company Name, Address Number, Street Name, City, State, Zip Code, Identifying Location\n';
        } else if (this.fulltable) {
            //csv += 'Extension, User Name, Email, User Admin, Department, Outbound Caller ID, License Type, Dial Plan Information, Collaboration, Webinar, Call Recording, Audio Mining, Screen Recording, Storage, Device Type, Device Accessories, Company Name,Address Number, Street Name, City, State, Zip Code, Identifying Location,Department,User Admin,Email,Outbound Caller ID,License Type,Device Type,Device Accessories,Dial Plan Information,Collaboration,Webinar,Call Recording,Audio Mining, Screen Recording, Storage\n';
            csv += 'Extension, User Name, Company Name, Address Number, Street Name, City, State, Zip Code, Identifying Location, Department, User Admin,Email,Outbound Caller ID,Other Outbound Caller IDs,License Type, Device Type, Device Accessories, Dial Plan Information,Collaboration, Webinar, Call Recording,Audio Mining, Screen Recording, Storage\n';

        }
        else if (this.Translation || this.isReadOnly) {
            
            csv += 'Extension, User Name, EAS Pin, MAC Address, Device Type,MAC Accessories\n';

        }
        //alert('export: '+JSON.stringify(this.ftrDIDNumberDetailsEmployeeInfo));
        this.ftrDIDNumberDetailsEmployeeInfo.forEach(ele => {
            if (this.employeeinfo) {
                csv += `${ele.Id},${ele?.DIDNumber__c},${ele?.Ucf_Extension__c},${ele?.Ucf_User_Name__c},${ele?.Ucf_Email__c},${ele?.Ucf_User_Admin__c ?? ''},${ele?.Ucf_Department__c},${ele?.Outbound_Caller_ID__c ?? ''},${ele?.Ucf_Other_Outbound_Caller_ID__c}\n`;
            } else if (this.licenseinfo) {
                csv += `${ele.Id},${ele?.DIDNumber__c},${ele?.Ucf_Extension__c},${ele?.Ucf_User_Name__c},${ele?.Ucf_License_Type__c},${ele?.Ucf_Dial_Plan_Information__c},${ele?.Ucf_Collaboration__c},${ele?.Ucf_Webinar__c},${ele?.Ucf_Call_Recording__c},${ele?.Ucf_Audio_Mining__c},${ele?.Ucf_Screen_Recording__c},${ele?.Ucf_Storage__c}\n`;
            } else if (this.deviceinfo) {

                csv += `${ele.Id},${ele?.DIDNumber__c},${ele?.Ucf_Extension__c},${ele?.Ucf_User_Name__c},${ele?.Ucf_License_Type__c},${ele?.Ucf_Device_Type__c},${ele?.Ucf_Device_Accessories__c}\n`;
            } else if (this.nine11info) {

                csv += `${ele.Id},${ele?.DIDNumber__c},${ele?.Ucf_User_Name__c},${ele?.Ucf_Company_Name__c},${ele?.Ucf_Address_Number__c},${ele?.Ucf_Street_Name__c},${ele?.Ucf_City__c},${ele?.Ucf_State__c},${ele?.Ucf_Zip_Code__c},${ele?.Ucf_Identifying_Location__c}\n`;
            } else if (this.fulltable) {

                  csv += `${ele.Id},${ele?.DIDNumber__c},${ele?.Ucf_Extension__c},${ele?.Ucf_User_Name__c},${ele?.Ucf_Company_Name__c},${ele?.Ucf_Address_Number__c},${ele?.Ucf_Street_Name__c},${ele?.Ucf_City__c},${ele?.Ucf_State__c},${ele.Ucf_Zip_Code__c},${ele?.Ucf_Identifying_Location__c}, ${ele?.Ucf_Department__c},${ele?.Ucf_User_Admin__c},${ele?.Ucf_Email__c},${ele?.Outbound_Caller_ID__c},${ele?.Ucf_Other_Outbound_Caller_ID__c},${ele?.Ucf_License_Type__c},${ele?.Ucf_Device_Type__c},${ele?.Ucf_Device_Accessories__c},${ele?.Ucf_Dial_Plan_Information__c},${ele?.Ucf_Collaboration__c},${ele?.Ucf_Webinar__c},${ele?.Ucf_Call_Recording__c},${ele?.Ucf_Audio_Mining__c},${ele?.Ucf_Screen_Recording__c},${ele?.Ucf_Storage__c}\n`;
                //csv += `${ele.Id},${ele?.DIDNumber__c},${ele?.Ucf_Extension__c}, ${ele?.Ucf_User_Name__c},${ele?.Ucf_Email__c},${ele?.Ucf_User_Admin__c},${ele?.Ucf_Department__c},${ele?.Outbound_Caller_ID__c},${ele?.Ucf_License_Type__c},${ele?.Ucf_Dial_Plan_Information__c},${ele?.Ucf_Collaboration__c},${ele?.Ucf_Webinar__c},${ele?.Ucf_Call_Recording__c},${ele?.Ucf_Audio_Mining__c},${ele?.Ucf_Screen_Recording__c},${ele?.Ucf_Storage__c},${ele?.Ucf_Device_Type__c},${ele?.Ucf_Device_Accessories__c},${ele?.Ucf_Company_Name__c},${ele?.Ucf_Address_Number__c},${ele?.Ucf_Street_Name__c},${ele?.Ucf_City__c},${ele?.Ucf_State__c},${ele.Ucf_Zip_Code__c}, ${ele?.Ucf_Identifying_Location__c}, ${ele?.Ucf_Department__c},${ele?.Ucf_User_Admin__c},${ele?.Ucf_Email__c},${ele?.Outbound_Caller_ID__c},${ele?.Ucf_Device_Type__c},${ele?.Ucf_Device_Accessories__c},${ele?.Ucf_Collaboration__c},${ele?.Ucf_Webinar__c},${ele?.Ucf_Call_Recording__c}\n`;
            } 
            else if (this.Translation || this.isReadOnly) {

                csv += `${ele.Id},${ele?.DIDNumber__c},${ele?.Ucf_Extension__c},${ele?.Ucf_User_Name__c},${ele?.EAS_Pin__c},${ele?.Ucf_MAC_Address__c},${ele?.Ucf_Device_Type__c},${ele?.Ucf_Device_Accessories__c}\n`;
            }
        });

        // Creating a blob object
        let blob = new Blob([csv], {
            type: 'text/plain'
        });
        let link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = this.fileName + '.csv';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    exportTemplate() {
        console.log('OUTPUT : ');
        // const csvHeader = 'Id,Phone Number,Current Carrier,Voip Qualification,DID Numbers\n';
       
        let csv = 'Phone Number,';
        if (this.employeeinfo) {
            csv += 'Extension, User Name, Email, User Admin, Department, Outbound Caller ID,Other Outbound Caller IDs\n';
        } else if (this.licenseinfo) {
            csv += 'Extension, User Name, License Type, Dial Plane Information, Collaboration, Webinar, Call Recording, Audio Mining, Screen Recording, Storage\n';
        } else if (this.deviceinfo) {
            csv += 'Extension, User Name, Device Type, Device Accessories\n';
        } else if (this.nine11info) {
            csv += 'User Name, Company Name, Address Number, Street Name, City, State, Zip Code, Identifying Location\n';
        } else if (this.fulltable) {
            //csv += 'Extension, User Name, Email, User Admin, Department, Outbound Caller ID, License Type, Dial Plan Information, Collaboration, Webinar, Call Recording, Audio Mining, Screen Recording, Storage, Device Type, Device Accessories, Company Name,Address Number, Street Name, City, State, Zip Code, Identifying Location,Department,User Admin,Email,Outbound Caller ID,License Type,Device Type,Device Accessories,Dial Plan Information,Collaboration,Webinar,Call Recording,Audio Mining, Screen Recording, Storage\n';
            csv += 'Extension, User Name, Company Name, Address Number, Street Name, City, State, Zip Code, Identifying Location, Department, User Admin,Email,Outbound Caller ID,License Type, Device Type, Device Accessories, Dial Plan Information,Collaboration, Webinar, Call Recording,Audio Mining, Screen Recording, Storage\n';

        }
        else if (this.Translation || this.isReadOnly) {
            
            csv += 'Extension, User Name, EAS Pin, MAC Address, Device Type,MAC Accessories\n';

        }
        // Creating a blob object
        let blob = new Blob([csv], {
            type: 'text/plain'
        });
        let link = document.createElement('a');

        link.href = URL.createObjectURL(blob);
        link.download = this.fileName + ' Template.csv';
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

    uploadFileHandler(event) {
        const uploadedFiles = event.detail.files;
        console.log('file name is:-' + uploadedFiles[0].name);
        console.log('document id is:-' + uploadedFiles[0].documentId);
        this.contentDocumentId = uploadedFiles[0].documentId;
        let employeeInfoType = this.selectedOption;
        console.log('OUTPUT this.selectedOption : ', this.selectedOption);

        loadCSVDataForEmployeeInfo({
                contentDocumentId: this.contentDocumentId,
                employeeInfoType: employeeInfoType
            })
            .then((result) => {
                this.recordCount = result;
                console.log('OUTPUT : ', result);
                if (this.recordCount == 0) {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Given data is not valid, Recheck your file columns',
                        variant: 'error',
                        mode: 'dismissible'
                    });
                    this.dispatchEvent(event);
                } else {
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: result,
                        variant: 'success',
                        mode: 'dismissible'
                    });
                    this.dispatchEvent(event);
                   this.fetchftrDIDNumberDetailsEmployeeInfo();
                }
            })
            .catch((error) => {
                this.error = error;
              
            })
    }

 showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }
   

    handleInputChange(event) {
        this.fieldChangeCount++;
        this.notifyInputChange(this.fieldChangeCount);
        const recordId = event.target.dataset.recordId;
        const fieldName = event.target.dataset.fieldName;
        const newValue = event.target.value;
        console.log('reocrd id', recordId);
        console.log(fieldName);
        console.log(newValue);
        this.N11=false;

        if (fieldName === 'Ucf_Email__c' && event.target.value !== null) {
            if (event.target.value !== '') {
                // Email validation
                if (!this.isValidEmail(newValue)) {
                     this.isValidationFailed = true;
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
        }

        if (fieldName === 'Ucf_State__c') {
            // Use 'this.validStateAbbreviations' to access the class property
            if (newValue && !this.validStateAbbreviations.includes(newValue.toUpperCase())) {
                 this.isValidationFailed = true;
                // Clear the field and show an error if the state is invalid
                event.target.value = ''; // Clear the input field
                this.showToast('Invalid State', 'Please enter a valid US state abbreviation.', 'error');
                return; // Stop further execution
            }
        }


   if (fieldName === 'Ucf_User_Name__c') {
            // Check for duplicate Ucf_User_Name__c entry
            const isDuplicate = this.ftrDIDNumberDetailsEmployeeInfo.some(detail =>
                detail.Ucf_User_Name__c === newValue && detail.Id !== recordId
            );

            if (isDuplicate) {
                // Alert the user that the webinar value is already selected
                this.isValidationFailed = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Duplicate User Name',
                        message: 'Please enter an unique user name',
                        variant: 'error'
                    })
                );
             
                return;
            }
        }
/*
        if (fieldName === 'Ucf_Extension__c') {
            // Check for duplicate Ucf_Extension__c entry

            if (event.target.value !== '') {

                const isDuplicate = this.ftrDIDNumberDetailsEmployeeInfo.some(detail =>
                    detail.Ucf_Extension__c === newValue && detail.Id !== recordId
                );

                if (isDuplicate) {
                     this.isValidationFailed = true;
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
        } */
        
        console.log('Hereeeeeeee>>>>>>>>1111 : ' + newValue);

         // Create a new copy of ftrDIDNumberDetailsEmployeeInfo for reactivity
    let updatedDetails = this.ftrDIDNumberDetailsEmployeeInfo.map(record => {
        if (record.Id === recordId) {
            let updatedRecord = {...record, [fieldName]: newValue};

            // If the Ucf_Call_Recording__c field is changed, update the showAdditionalColumns flag
            if (fieldName === 'Ucf_Call_Recording__c') {
                if(newValue === 'No')
                {
                    console.log('Call recodring Noo ' + newValue);
                    updatedRecord.showAdditionalColumns = false;
                    updatedRecord.Ucf_Screen_Recording__c = 'No';
                    updatedRecord.Ucf_Audio_Mining__c = 'No';

                }

                 if(newValue === 'Yes')
                {
                     console.log('Call recodring Yess ' + newValue);
                    updatedRecord.showAdditionalColumns = newValue === 'Yes';
                    updatedRecord.Ucf_Screen_Recording__c = 'No';
                     updatedRecord.Ucf_Storage__c = 'UCF Call Recording Basic';
                    updatedRecord.Ucf_Audio_Mining__c = 'No';

                }
               
               
                
            }

            if (fieldName === 'Ucf_License_Type__c'  && newValue === 'UCF Executive') {
                updatedRecord.showCollabWebinar =  true;
            }
                    if (fieldName === 'Ucf_License_Type__c'  && newValue !== 'UCF Executive') {
                    updatedRecord.showCollabWebinar =  false;
                        updatedRecord.Ucf_Collaboration__c = 'None';
                    updatedRecord.Ucf_Webinar__c = 'None'; 
                        updatedRecord.Ucf_Device_Type__c = 'None'; 
                        this.updateDraftValues(recordId, 'Ucf_Device_Type__c', 'None'); // Update draftValues
                }
                if (fieldName === 'Ucf_License_Type__c' && newValue !== 'UCF Inbound WebFax DID') {
                     updatedRecord.Ucf_Device_Type__c = 'None'; 
                        this.updateDraftValues(recordId, 'Ucf_Device_Type__c', 'None'); // Update draftValues
                }
                console.log('deviceeee '+ newValue);
              if (fieldName === 'Ucf_License_Type__c' && newValue === 'UCF Executive') {
                  if (!this.deviceOptions.some(option => option.value === 'Softphone')) 
                 {
                    this.deviceOptions.push({ label: 'Softphone', value: 'Softphone' });
                 }
                updatedRecord.Ucf_Device_Type__c = 'Softphone'; // Set Ucf_Device_Type__c to eFax
                this.updateDraftValues(recordId, 'Ucf_Device_Type__c', 'Softphone'); // Update draftValues
            }

           
             if (fieldName === 'Ucf_License_Type__c' && newValue === 'UCF Inbound WebFax DID') {
                   console.log('deviceeee heree'+ newValue);
                 if (!this.deviceOptions.some(option => option.value === 'eFAX')) 
                 {
                    this.deviceOptions.push({ label: 'eFAX', value: 'eFAX' });
                    
                 }
                  updatedRecord.Ucf_Device_Type__c = 'eFAX';
                  this.updateDraftValues(recordId, 'Ucf_Device_Type__c', 'eFAX'); // Update draftValues

            }
          

            return updatedRecord;
        }
        return record;
    });

    // Update the state with the new array and force re-render
    this.ftrDIDNumberDetailsEmployeeInfo = updatedDetails;
    this.ftrDIDNumberDetailsEmployeeInfo = [...this.ftrDIDNumberDetailsEmployeeInfo];

             // Create a new copy of ftrDIDNumberDetailsEmployeeInfo for reactivity
    let updatedDetailsCallerid = this.ftrDIDNumberDetailsEmployeeInfo.map(record => {
        if (record.Id === recordId) {
            let updatedRecordCallerId = {...record, [fieldName]: newValue};

            // If the Ucf_Call_Recording__c field is changed, update the showAdditionalColumns flag
            if (fieldName === 'Outbound_Caller_ID__c') {
                updatedRecordCallerId.showOtherCallerId = newValue === 'Other';
            }

            return updatedRecordCallerId;
        }
        return record;
    });

    // Update the state with the new array and force re-render
    this.ftrDIDNumberDetailsEmployeeInfo = updatedDetailsCallerid;
    this.ftrDIDNumberDetailsEmployeeInfo = [...this.ftrDIDNumberDetailsEmployeeInfo];


    
    // Update the state with the new array
   // this.ftrDIDNumberDetailsEmployeeInfo = updatedDetails;
            //let updatedDetails = [...this.ftrDIDNumberDetailsEmployeeInfo];
        const index = this.ftrDIDNumberDetailsEmployeeInfo.findIndex(ftrDIDNumberDetail => ftrDIDNumberDetail.Id === recordId);
        console.log('index ' + index);
         // alert('indexe ' + index);
      //  alert('index new value ' + newValue);
        
        if (index !== -1) {
            // Update the field value in the account data
            this.ftrDIDNumberDetailsEmployeeInfo[index][fieldName] = newValue;
            console.log('index new value ' + newValue);
            //alert('index new value ' + newValue);
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
            console.log('this.draftValues ' + JSON.stringify(this.draftValues));
        }
    }
    updateDraftValues(recordId, fieldName, newValue) {
    // Check if the record is already in draftValues and update it
    const draftIndex = this.draftValues.findIndex(draft => draft.Id === recordId);
    if (draftIndex !== -1) {
        this.draftValues[draftIndex][fieldName] = newValue;
    } else {
        // If the record is not in draftValues, add it
        let draftRecord = { Id: recordId };
        draftRecord[fieldName] = newValue;
        this.draftValues.push(draftRecord);
    }
}

    getErrorDetails(error) {
if (error.message) {
        return error.message;
    } else if (error.body && error.body.message) {
        return error.body.message;
    } else if (Array.isArray(error.body)) {
        return error.body.map(e => e.message).join(', ');
    } else {
        // Return a generic message if no specific error details are found
        return 'An unknown error occurred';
    }
    }
    validateRequiredFields() {
        var isValidVal = true;
        var inputFields = this.template.querySelectorAll("[data-name='validate']");
        console.log('inputFields = ' +  inputFields );
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                    inputField.showHelpMessageIfInvalid();
                    isValidVal = false;
            }
        });
         var inputTextFields = this.template.querySelectorAll('input[name="inputvalidate"]');
         inputTextFields.forEach(inputField => {
            if (inputField.value.trim() === '') {
            inputField.style.border = '1px solid red';
            isValidVal = false;        
            }
            else{
                inputField.style.border = '';
            }
        });
        return isValidVal;
      }

validateQuantities() {
    // Validate each product type
   // alert('1');
    if (!this.validateProductQuantity('Ucf_Collaboration__c', this.collaborationQuantitiesData)) {
        return false;
    }
     //alert('2');
    if (!this.validateProductQuantity('Ucf_Webinar__c', this.webinarQuantitiesData)) {
        return false;
    }
    if (!this.validateProductQuantity('Ucf_Call_Recording__c', this.callRecordingQuantitiesData)) {
        return false;
    }
    if (!this.validateProductQuantity('Ucf_Storage__c', this.storageQuantities)) {
        return false;
    }

    if (!this.validateProductQuantity('Ucf_Audio_Mining__c', this.audioMiningQuantitiesData)) {
        return false;
    }
    
    if (!this.validateProductQuantity('Ucf_Screen_Recording__c', this.screenRecordingQuantitiesData)) {
        return false;
    }
    
    
    // alert('3');
    if (!this.validateProductQuantity('Ucf_Device_Accessories__c', this.assesQuantitiesData)) {
        return false;
    }
   //  alert('4');
    if (!this.validateProductQuantity('Ucf_License_Type__c', this.licenseQuantitiesData)) {
        return false;
    }
    // alert('5');
    if (!this.validateProductQuantity('Ucf_Device_Type__c', this.conferenceModelsQuantitiesData)) {
        return false;
    }
    if (!this.validateProductQuantity('Ucf_Device_Type__c', this.polyPhonesQuantitiesData)) {
        return false;
    }
    if (!this.validateProductQuantity('Ucf_Device_Type__c', this.yealinkQuantitiesData)) {
        return false;
    }
    if (!this.validateProductQuantity('Ucf_Device_Type__c', this.ataQuantitiesData)) {
        return false;
    }
    // Add additional validations for other product types if needed

    return true; // All validations passed
}

validateProductQuantity(fieldName, quantitiesDataObject) {
    let selectedProductCounts = new Map();

    console.log('fieldName: '+ fieldName +' quantitiesDataObject: '+ JSON.stringify(quantitiesDataObject));
    this.ftrDIDNumberDetailsEmployeeInfo.forEach(record => {
        const productName = record[fieldName];
        console.log('productName '+ productName);
        if (productName && productName !== 'None' &&  productName !== 'UCF Call Recording Basic' &&  productName !== 'Softphone' 
        &&  productName !== 'eFAX' && productName && productName !== 'No'  ) {
            selectedProductCounts.set(productName, (selectedProductCounts.get(productName) || 0) + 1);
        }
        console.log('selectedProductCounts '+ selectedProductCounts);
           console.log(' selectedProductCounts: '+ JSON.stringify(selectedProductCounts));
    });

    for (const [productName, selectedCount] of selectedProductCounts) {
        console.log(JSON.stringify(quantitiesDataObject));
         let availableCount;
         let availableQuantity = 0;
        if(quantitiesDataObject != null && quantitiesDataObject !== 'undefined')
        {
              availableQuantity = quantitiesDataObject[productName] || 0;
             availableCount = availableQuantity;
        }
        
       console.log('selectedCount '+ selectedCount);
       console.log('availableQuantity '+ availableCount);
        if (selectedCount > availableCount) {
       let displayProductName = productName === 'Yes' ? 'Call Recording' : productName;
            this.showToast(`Exceeded Quantity for ${displayProductName}`, `The number of ${displayProductName} selected (${selectedCount}) cannot exceed the available quantity (${availableQuantity}).`, 'error');
           this.isValidationFailed = true;
            return false;
        }
    } 

    return true;
}

showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
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
            
            // Perform subsequent actions that depend on the data
            console.log('Data fetched and processed:', this.ftrDIDNumberDetails);
            this.isValidationFailed = false;

            if (!this.validateQuantities()) {
                    console.log('Save process initiated');
                    //  alert('no');
                    // TODO: Insert save logic here
                }
  
   // Check device type and license type constraints
                this.draftValues.forEach(draft => {
                    const deviceType = draft.Ucf_Device_Type__c !== undefined ? draft.Ucf_Device_Type__c 
                                    : this.ftrDIDNumberDetailsEmployeeInfo.find(record => record.Id === draft.Id)?.Ucf_Device_Type__c;
                    
                    const licenseType = draft.Ucf_License_Type__c !== undefined ? draft.Ucf_License_Type__c 
                                    : this.ftrDIDNumberDetailsEmployeeInfo.find(record => record.Id === draft.Id)?.Ucf_License_Type__c;
                    let isDeviceTypeFound;
                    if(deviceType !== null)
                    {
                    // alert(' this.ataDeviceOptions '+ JSON.stringify(this.ataDeviceOptions));
                        isDeviceTypeFound= this.ataDeviceOptions.some(option => option.value === deviceType);
                    }
                    

                    if (isDeviceTypeFound && licenseType !== 'UCF Analog') {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Invalid License Type',
                                message: 'Only ATA devices are allowed to be added to UCF Analog licenses.',
                                variant: 'error'
                            })
                        );
                        this.isValidationFailed = true;
                        return; // Stop the execution to prevent saving the data
                    }
                });

                // If validation failed, exit the function
                if (this.isValidationFailed) {
                    return;
                }

                //
            // Check if 'UCF Analog' license type is selected with a non-ATA device type

            this.draftValues.forEach(draft => {
                const licenseType = draft.Ucf_License_Type__c !== undefined ? draft.Ucf_License_Type__c 
                                : this.ftrDIDNumberDetailsEmployeeInfo.find(record => record.Id === draft.Id)?.Ucf_License_Type__c;
                
                const deviceType = draft.Ucf_Device_Type__c !== undefined ? draft.Ucf_Device_Type__c 
                                : this.ftrDIDNumberDetailsEmployeeInfo.find(record => record.Id === draft.Id)?.Ucf_Device_Type__c;

                let isInvalidDeviceTypeForAnalog = false;
                if (licenseType === 'UCF Analog' && deviceType !== 'None') {
                    isInvalidDeviceTypeForAnalog = !this.ataDeviceOptions.some(option => option.value === deviceType);
                }

                if (isInvalidDeviceTypeForAnalog) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Invalid Device Type',
                            message: 'ATA devices can only be selected for UCF Analog Liceses.',
                            variant: 'error'
                        })
                    );
                    this.isValidationFailed = true;
                    return; // Stop the execution to prevent saving the data
                }
            });

            if (this.isValidationFailed) {
                return; // Exit the function if any record failed validation
            }



                let Duplicate=false;
                let ExtChanged=false;
                let count=0;
                console.log('1718'+JSON.stringify(this.ftrDIDNumberDetails));
                
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
                            
                            this.isValidationFailed = true;
                            return;
                            }
                            if(Duplicate == false)
                            {
                                const isDuplicateExtension = this.ftrDIDNumberDetails.some(detail =>
                                    detail.Ucf_Extension__c === draft.Ucf_Extension__c && detail.Id !== draft.Id && this.checkValueExistsArray(detail.Id,this.draftValues) == false 
                                );
                    
                                if (isDuplicateExtension) {
                                    Duplicate=true;
                                    this.isValidationFailed = true;
                                    console.log('1751');
                                    return;
                                }
                            }
                            }
                        });

                    

                    if(Duplicate == false && ExtChanged == true)
                    {
                        
                        this.ftrDIDNumberDetailsEmployeeInfo.forEach(draft => {
                        
                        const isDuplicateExtension = this.ftrDIDNumberDetails.some(detail =>
                            detail.Ucf_Extension__c === draft.Ucf_Extension__c && detail.Id !== draft.Id && this.checkValueExists(draft.Id) == false && this.checkValueExists(detail.Id) == false
                        );
            
                        if (isDuplicateExtension) {
                            Duplicate=true;
                            this.isValidationFailed = true;
                            console.log('If duplicate out side Employee Info when change in Ext');
                            return;
                        }
                    
                    });
                    }
                
                console.log('Debug::'+Duplicate);
                /***** Checking duplicate Ext with in the order when Ext is not changed manually and user saved*/
                if((Duplicate == false && this.draftValues.length == 0) || (Duplicate == false && this.draftValues.length !== 0 && ExtChanged == false)) 
                {
                    this.ftrDIDNumberDetailsEmployeeInfo.forEach(draft => {
                    
                        const isDuplicateExtension = this.ftrDIDNumberDetails.some(detail =>
                            detail.Ucf_Extension__c === draft.Ucf_Extension__c && detail.Id !== draft.Id
                        );
            
                        if (isDuplicateExtension) {
                            Duplicate=true;
                            this.isValidationFailed = true;
                            console.log('If duplicate out side Employee Info without change'+draft);
                            return;
                        }
                    
                    });
                }
                
                console.log('1732'+Duplicate);
                if(Duplicate == true)
                {
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
                
                this.ftrDIDNumberDetailsEmployeeInfo.forEach(detail =>{
                            
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
                                    this.isValidationFailed = true;
                                        return;
                                            
                                        }
                                }

                        

            
                            if(detail.Ucf_Extension__c !== '' && detail.Ucf_Extension__c !== "undefined")
                            {
                                if(detail.Ucf_Extension__c.slice(-2) === '11' && detail.Ucf_Extension__c.toString().length == 3)
                                {
                                    
                                    this.N11=true;
                                    
                                }
                            }
                            
                            
                        
                            let lengthOfExtension = parseInt(detail.Ucf_Extension_Lenght__c);
                        
                            if(detail.Ucf_Extension__c !== '' && detail.Ucf_Extension__c !== "undefined")
                            {
                                if(detail.Ucf_Extension__c.toString().length < lengthOfExtension)
                                {
                                this.dispatchEvent(
                                                new ShowToastEvent({
                                                    title: 'Length Error',
                                                    message: 'Extension length should not be less than ' + lengthOfExtension,
                                                    variant: 'error'
                                                })
                                            );
                                            this.isValidationFailed = true;
                                            return;
                                    
                                }
                            }
                        
                    });
                    
                    this.draftValues.forEach(draft => {
                        if(draft.Ucf_Other_Outbound_Caller_ID__c)
                        {
                            //alert();
                            if(draft.Ucf_Other_Outbound_Caller_ID__c.toString().length <= 9)
                            {
                                                
                            this.flagOtherCallerId = true;
                            } else {
                                // The length is not 10
                                this.flagOtherCallerId = false;
                            }
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
                            this.isValidationFailed=true;
                            return;
                        }
                    
                        if (this.flagOtherCallerId == true) {
                            // Alert the user that the webinar value is already selected
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Other Outbound Caller ID',
                                    message: 'Other Outbound Caller ID must be 10 digits long!',
                                    variant: 'error'
                                })
                            );
                            this.isValidationFailed=true;
                            return;
                        }

                    // Create an array to store the records that need to be updated
                    const recordsToUpdate = [];

   
   

        // Loop through draftValues to build the array of records to update
                this.draftValues.forEach(draft => {
                        // Check if Ucf_Dial_Plan_Information__c is present, and if it's null or empty
                if (draft.Ucf_Dial_Plan_Information__c === null || draft.Ucf_Dial_Plan_Information__c === '' || typeof draft.Ucf_Dial_Plan_Information__c === 'undefined') {
                    draft.Ucf_Dial_Plan_Information__c = 'National and Canada';
                }
                if (draft.Ucf_Call_Recording__c === 'No') {
                //  alert('CR no');
                draft.Ucf_Storage__c = '';
                }
                //  alert('storage '+ draft.Ucf_Storage__c);
                    // alert('CR '+ draft.Ucf_Call_Recording__c);
                    if ((draft.Ucf_Storage__c === null || draft.Ucf_Storage__c === '' || typeof draft.Ucf_Storage__c === 'undefined') && draft.Ucf_Call_Recording__c === 'Yes') {
                    /// alert('heree');
                    draft.Ucf_Storage__c = 'UCF Call Recording Basic';
                }


            recordsToUpdate.push({
                Id: draft.Id,
                Ucf_Extension__c: draft.Ucf_Extension__c,
                Ucf_User_Name__c: draft.Ucf_User_Name__c,
                Ucf_User_Admin__c: draft.Ucf_User_Admin__c,
                Ucf_Department__c: draft.Ucf_Department__c,
                Ucf_Email__c: draft.Ucf_Email__c,
                Ucf_Company_Name__c: draft.Ucf_Company_Name__c,
                Ucf_Address_Number__c: draft.Ucf_Address_Number__c,
                Ucf_Street_Name__c: draft.Ucf_Street_Name__c,
                Ucf_City__c: draft.Ucf_City__c,
                Ucf_State__c: draft.Ucf_State__c,
                Outbound_Caller_ID__c: draft.Outbound_Caller_ID__c,
                Ucf_Zip_Code__c: draft.Ucf_Zip_Code__c,
                Ucf_Identifying_Location__c: draft.Ucf_Identifying_Location__c,
                Ucf_License_Type__c: draft.Ucf_License_Type__c,
                Ucf_Dial_Plan_Information__c: draft.Ucf_Dial_Plan_Information__c,
                Ucf_Collaboration__c: draft.Ucf_Collaboration__c,
                EAS_Pin__c: draft.EAS_Pin__c,
                Ucf_Webinar__c: draft.Ucf_Webinar__c,
                Ucf_Audio_Mining__c: draft.Ucf_Audio_Mining__c,
                Ucf_Call_Recording__c: draft.Ucf_Call_Recording__c,
                Ucf_Screen_Recording__c: draft.Ucf_Screen_Recording__c,
                Ucf_Storage__c: draft.Ucf_Storage__c,
                Ucf_Customize_Extension__c: draft.Ucf_Customize_Extension__c,
                Ucf_Device_Type__c: draft.Ucf_Device_Type__c,
                Ucf_Device_Accessories__c: draft.Ucf_Device_Accessories__c,
                Ucf_EAS_Pin__c: draft.Ucf_EAS_Pin__c,
                Ucf_MAC_Address__c: draft.Ucf_MAC_Address__c,
                Ucf_Company_Name__c: draft.Ucf_Company_Name__c,
                Ucf_Other_Outbound_Caller_ID__c: draft.Ucf_Other_Outbound_Caller_ID__c
                });
            });
          
          // alert(JSON.stringify(recordsToUpdate));
            if (!this.isValidationFailed && this.draftValues.length > 0) {
            // Call the Apex method to update the records
            updateftrDIDNumberDetailsEmployeeTab({
                    recordsToUpdate
                })
            .then(result => {
                // Handle success
                this.fieldChangeCount=0;
                this.notifyInputChange(this.fieldChangeCount);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Records saved successfully',
                        variant: 'success'
                    })
                );

                // Clear the draftValues array
                this.draftValues = [];
                this.ftrDIDNumberDetails=null;
                console.log('Debug::1972'+this.ftrDIDNumberDetails);
                // Refresh the table data
                // this.fetchMDNOptions();
                this.fetchftrDIDNumberDetailsEmployeeInfo();
                   console.log('get passed 11');
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

    handleRefreshClick() {
        refreshApex(this.wiredRecords).then(() => {
            console.log('OUTPUT : refreshed');
        });
    }
    notifyInputChange(count){
        console.log('count',count);
        this.dispatchEvent(new CustomEvent('recordchange', {
            detail: {
                component: 'serviceLocation',
                message: count
            }
        }));
    }

}