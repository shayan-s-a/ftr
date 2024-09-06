import { LightningElement,api, wire, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getAccounts from '@salesforce/apex/PmEnrichmentController.getAccounts';
import getPremises from '@salesforce/apex/PmEnrichmentController.getPremises';
import getPremises2 from '@salesforce/apex/PmEnrichmentController.getPremises2';
import getDIDNumberInfo from '@salesforce/apex/PmEnrichmentController.ftrPhoneNumberDetails';
import updateServiceLoacationMoadalFields from '@salesforce/apex/PmEnrichmentController.updateServiceLoacationMoadalFields'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getRatingPicklistValues from '@salesforce/apex/PmEnrichmentController.getRatingPicklistValues';
import updatePremiseFieldsList from '@salesforce/apex/PmEnrichmentController.updatePremiseFieldsList';
import getNpaNxxList from '@salesforce/apex/PmEnrichmentController.getNpaNxxList';
import updateDIDNumbersFieldsList from '@salesforce/apex/PmEnrichmentController.updateDIDNumbersFieldsList';
import isTranslationUser from '@salesforce/apex/PmEnrichmentController.isTranslationUser';
import getEmployeeInfo from '@salesforce/apex/FetchData.ftrDIDNumberDetailsEmployeeInfo';
import ftrDIDNumberDetailsGeneralVoicemail from '@salesforce/apex/UcfGvmController.downloadFtrDIDNumberDetailsGeneralVoicemail';
import getTtrDIDNumberDetailsMLHGData from '@salesforce/apex/FetchDataMLHG.ftrDIDNumberDetailsMLHG';
import queryschedules from '@salesforce/apex/FetchDataMLHG.queryschedules';
import ftrSelectedMembers from '@salesforce/apex/FetchDataMLHG.ftrSelectedMembers';
import downloadHolidaysBySchedule from '@salesforce/apex/FetchDataMLHG.downloadHolidaysBySchedule';
import downloadHolidaysByAASchedule from '@salesforce/apex/UcfAutoAttendentController.downloadHolidaysByAASchedule';
import ftrDIDNumberDetailsAutoAttendantsSetup from '@salesforce/apex/UcfAutoAttendentController.ftrDIDNumberDetailsAutoAttendantsSetup';
import ScheduleforAutoAttendantSetUp from '@salesforce/apex/UcfAutoAttendentController.downloadMenuLines';
import menusforAutoAttendants from '@salesforce/apex/UcfAutoAttendentController.ScheduleforAutoAttendantsSchedules';
import greetingsforAutoAttendantsGreetings from '@salesforce/apex/UcfAutoAttendentController.greetingsforAutoAttendantsGreetings';
import loadComponent from '@salesforce/apex/PageGroupsController.pageGroupData';
import loadComponentCustomizationNotes from '@salesforce/apex/CustomizationsNotesUcfController.loadData';
import Notifications911CustomizationNotes from '@salesforce/apex/CustomizationsNotesUcfController.loadData';
import DownloadPMPageGroupMembers from '@salesforce/apex/PageGroupsController.DownloadPMPageGroupMembers';
import downloadCustomtimeperiodAA from '@salesforce/apex/UcfAutoAttendentController.downloadCustomtimeperiodAA';
import downloadCustomtimeperiodMLHG from '@salesforce/apex/FetchDataMLHG.downloadCustomtimeperiodMLHG';
//import getCurrentOrderStage from  '@salesforce/apex/PmEnrichmentController.getOrderStage';



export default class ServiceLocationLWC extends LightningElement {

@api recordId;
@api uniqueKey = 0;
@api recordTypeId;
@track accounts;
@track downloadLoader=false;
@track accounts2;
@track data = [];
@track draftValues = [];
@track isModalOpen = false;
@track sicDesc = '';
@track constructionDetails = '';
@track shippingAddress = '';
@track shippingStreet = '';
@track shippingCity = '';
@track shippingState = '';
@track shippingZip = '';
@track tickerSymbol = '';
@track ratingPicklistValues = [];
@track sortField = 'Name'; // Default sort field
@track sortDirection = 'asc'; // Default sort direction
@track refreshTable = false; // Flag to trigger table refresh
@track ratingPicklistOptions = [];
@track selectedRating = ''; 
error;
@track mainPhoneNumber = '';
@track locationName = '';
@track xlsHeader = []; // store all the headers of the the tables
@track workSheetNameList = []; // store all the sheets name of the the tables
@track xlsData = []; // store all tables data
@track filename = "PMEnrichment.xlsx"; // Name of the file
@track PremisesData = []; // used only for storing premeses table
@track DIDNumberInfoTable = []; // used only for storing DIDNumberInfo table
@track getEmployeeInfoTable = [];
@track getTtrDIDNumberDetailsMLHGDataTable = [];
@track ftrDIDNumberDetailsGeneralVoicemailTable =[];
@track queryschedulesTable=[];
@track downloadHolidaysByScheduleTable=[];
@track downloadHolidaysByAAScheduleTable=[];
@track ftrDIDNumberDetailsAutoAttendantsSetupTable=[];
@track ScheduleforAutoAttendantSetUpTable =[];
@track menusforAutoAttendantsTable=[];
@track greetingsforAutoAttendantsGreetingsTable=[];
@track loadComponentTable=[];
@track loadComponentCustomizationNotesTable=[];
@track Notifications911CustomizationNotesTable=[];
@track downloadCustomtimeperiodAATable=[];
@track downloadCustomtimeperiodMLHGTable=[];
@track userType ='';
@track isTranslation;
@track isReadOnly;
//@track isOrderInProgressOrCompleted = false;
showWarningMessage = false;
customMusicChanged = false;
@track timeZoneOptions;
constructionOptions;
customMusicOptions;
wiredResult;
_wiredMarketData;
shippingLocationOptions;
BusinessGroupName = '';
EAS_Pin = '';
ShowLoader=false;
fieldChangeCount=0;
@api isnetworktranslation=false;
NpaNxxHeader;

timeZoneOptions = [
    { label: 'Select an option', value: '' },
    { label: 'Eastern', value: 'Eastern' },
    { label: 'Central', value: 'Central' },
    { label: 'Mountain', value: 'Mountain' },
    { label: 'Arizona – Not Navajo Nation', value: 'Arizona – Not Navajo Nation' },
    { label: 'Pacific', value: 'Pacific' }
];

shippingLocationOptions  = [
    { label: 'Different address', value: 'Different address' },
    { label: 'Same as service location', value: 'Same as service location' }
];


constructionOptions = [
    { label: 'Select an option', value: '' },
    { label: 'Yes', value: 'Yes' },
    { label: 'No', value: 'No' }
];

customMusicOptions = [
     { label: 'Select an option', value: '' },
     { label: 'Yes', value: 'Yes'},
     { label: 'No', value: 'No' }
   
];
    // connectedCallback --- Inside connectedCallBack all other methods are available
    async connectedCallback() {
        this.ShowLoader=true;
        console.log('last test 911 notifications');
        await this.getIsAdmin();
        console.log('this.isTranslation',this.isTranslation);
        getPremises2({recordId: this.recordId}).then(result=>{
            if (result) {
                this.BusinessGroupName=result[0].Business_Group_Name__c || '';
                this.EAS_Pin=result[0].EAS_Pin__c || '';
            }
        }).catch(error=>{
            console.log('error getPremises2 Connectedcallback',error);
        })
        await this.fetchServiceLocations();
    }  

async getdownloadCustomTimePeriodMLHG(){
    try {
        let result = await downloadCustomtimeperiodMLHG({OrderId: this.recordId});
        if (result) {
            console.log("MLHG Custom time Period Data", JSON.stringify(result));
            this.MLHGTimeperiodHeader = ["Id" , "Name", "Day","Menu Name","Schedule Name","Start","Stop","Overflow Destination","Overflow Timer","Monday Start Time","Monday End Time","Tuesday Start Time","Tuesday End Time","Wednesday Start Time","Wednesday End Time","Thursday Start Time","Thursday End Time","Friday Start Time","Friday End Time","Saturday Start Time","Saturday End Time","Sunday Start Time","Sunday End Time"];
            let resultNEw=[];
            if (result.length > 0) {
                result.forEach(ele=>{
                    let newObj={};
                    newObj.Id=ele.Id;
                    newObj.Name=ele?.Name ?? '';
                    newObj.Day__c=ele?.Day__c ?? '';
                    newObj.MenuName__c=ele?.MenuName__c ?? '';
                    newObj.ScheduleName=ele?.Schedule__r.UCF_Name__c ?? '';
                    newObj.Start__c = ele?.Start__c ?? '';
                    newObj.Stop__c=ele.Stop__c ?? '';
                    newObj.Overflow_Destination__c=ele?.Overflow_Destination__c ?? '';
                    newObj.Overflow_Timer__c=ele?.Overflow_Timer__c ?? '';
                    newObj.Monday_Start_Time__c=ele?.MondayStart__c ?? '';
                    newObj.Monday_End_Time__c=ele?.MondayStop__c ?? '';
                    newObj.Tuesday_Start_Time__c = ele?.TuesdayStart__c ?? '';
                    newObj.Tuesday_End_Time__c=ele.TuesdayStop__c ?? '';
                    newObj.Wednesday_Start_Time__c=ele?.WednesdayStart__c ?? '';
                    newObj.Wednesday_End_Time__c=ele?.WednesdayStop__c ?? '';
                    newObj.Thursday_Start_Time__c=ele?.ThursdayStart__c ?? '';
                    newObj.Thursday_End_Time__c=ele?.ThursdayStop__c ?? '';
                    newObj.Friday_Start_Time__c = ele?.FridayStart__c ?? '';
                    newObj.Friday_End_Time__c=ele.FridayStop__c ?? '';
                    newObj.Saturday_Start_Time__c=ele?.SaturdayStart__c ?? '';
                    newObj.Saturday_End_Time__c=ele?.SaturdayStop__c ?? '';
                    newObj.Sunday_Start_Time__c=ele?.SundayStart__c ?? '';
                    newObj.Sunday_End_Time__c=ele?.SundayStop__c ?? '';
                    resultNEw.push(newObj);
                    console.log("MLHG Custom time Period Data", JSON.stringify(resultNEw));
                })
                this.xlsFormatter(resultNEw, "MLHG Custom Timeperiod Info",this.MLHGTimeperiodHeader);
            }
        }
    } catch (error) {
        console.error(error);
    }
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
async getdownloadCustomtimeperiodAA(){
    try {
        let result = await downloadCustomtimeperiodAA({OrderId: this.recordId});
        if (result) {
            console.log("Custom time Period Data", JSON.stringify(result));
            this.AATimeperiodHeader = ["Id" , "Name", "Day","Menu Name","Schedule Name","Start","Stop","Overflow Destination","Overflow Timer","Monday Start Time","Monday End Time","Tuesday Start Time","Tuesday End Time","Wednesday Start Time","Wednesday End Time","Thursday Start Time","Thursday End Time","Friday Start Time","Friday End Time","Saturday Start Time","Saturday End Time","Sunday Start Time","Sunday End Time"];
            let resultNEw=[];
            if (result.length > 0) {
                result.forEach(ele=>{
                    let newObj={};
                    newObj.Id=ele.Id;
                    newObj.Name=ele?.Name ?? '';
                    newObj.Day__c=ele?.Day__c ?? '';
                    newObj.MenuName__c=ele?.MenuName__c ?? '';
                    newObj.ScheduleName=ele?.Schedule__r.UCF_Name__c ?? '';
                    newObj.Start__c = ele?.Start__c ?? '';
                    newObj.Stop__c=ele.Stop__c ?? '';
                    newObj.Overflow_Destination__c=ele?.Overflow_Destination__c ?? '';
                    newObj.Overflow_Timer__c=ele?.Overflow_Timer__c ?? '';
                    newObj.Monday_Start_Time__c=ele?.MondayStart__c ?? '';
                    newObj.Monday_End_Time__c=ele?.MondayStop__c ?? '';
                    newObj.Tuesday_Start_Time__c = ele?.TuesdayStart__c ?? '';
                    newObj.Tuesday_End_Time__c=ele.TuesdayStop__c ?? '';
                    newObj.Wednesday_Start_Time__c=ele?.WednesdayStart__c ?? '';
                    newObj.Wednesday_End_Time__c=ele?.WednesdayStop__c ?? '';
                    newObj.Thursday_Start_Time__c=ele?.ThursdayStart__c ?? '';
                    newObj.Thursday_End_Time__c=ele?.ThursdayStop__c ?? '';
                    newObj.Friday_Start_Time__c = ele?.FridayStart__c ?? '';
                    newObj.Friday_End_Time__c=ele.FridayStop__c ?? '';
                    newObj.Saturday_Start_Time__c=ele?.SaturdayStart__c ?? '';
                    newObj.Saturday_End_Time__c=ele?.SaturdayStop__c ?? '';
                    newObj.Sunday_Start_Time__c=ele?.SundayStart__c ?? '';
                    newObj.Sunday_End_Time__c=ele?.SundayStop__c ?? '';
                    resultNEw.push(newObj);
                    console.log("Custom time Period Data", JSON.stringify(resultNEw));
                })
                this.xlsFormatter(resultNEw, "AA Custom Timeperiod Info",this.AATimeperiodHeader);
            }
        }
    } catch (error) {
        console.error(error);
    }
}
async getMLHGSelectedMembersData(){
    try {
        let result = await ftrSelectedMembers({recordId: this.recordId});
        if (result) {
            console.log("ftrSelectedMembers Members Data", JSON.stringify(result));
            this.SelectedMemberHeader = ["Id", "Name", "MLHG Members" ];
            let resultNEw=[];
            if (result.length > 0) {
                result.forEach(ele=>{
                    let newObj={};
                    newObj.Id = ele.Id;
                    newObj.mlgName = ele?.Parent_DID_Number_Detail__r.MLHG_Name__c ?? '';
                    newObj.Name = ele?.Name ?? '';
                    // newObj.DID_Number_Details__c = ele?.DID_Number_Details__c ?? '';
                    // newObj.DID_Number_DetailName = ele?.DID_Number_Details__r?.Name ?? '';
                    resultNEw.push(newObj);
                })
                this.xlsFormatter(resultNEw, "MLHG Members",this.SelectedMemberHeader);
            }
        }
    } catch (error) {
        console.error(error);
    }
}
async getPageGourpMembersDataToDownload(){
    try {
        let result = await DownloadPMPageGroupMembers({OrderId: this.recordId});
        if (result) {
            console.log("Page Gourp memebers Data", JSON.stringify(result));
            this.PageGroupHeader = ["Id" , "Page Group Name","Name" ];
            let resultNEw=[];
            if (result.length > 0) {
                result.forEach(ele=>{
                    let newObj={};
                    newObj.Id = ele.Id;
                    newObj.PagegroupName = ele?.Page_Groups__r.Name ?? '';
                    newObj.UserName__c = ele?.UserName__c ?? '';
                    resultNEw.push(newObj);
                    console.log("Page Gourp memebers Data for sheet", JSON.stringify(resultNEw));
                })
                this.xlsFormatter(resultNEw, "Page Group Members",this.PageGroupHeader);
            }
        }
    } catch (error) {
        console.error(error);
    }
}

    // gerPermisesRecord --- apex method getPremises2
    // getPremisesRecord(){
    //     getPremises2({recordId: this.recordId})
    //     .then(result => {
    //         console.log('OUTPUT this.recordId : ',this.recordId);
    //         console.log('OUTPUT isTranslationUserValue : ',this.isTranslation);
    //         //this.PremisesHeader = Object.keys(result[0]);
    //         this.PremisesHeader = ["Id","LOCATION NAME", "LOCATION ADDRESS", "MAIN PHONE #", "SHIPPING LOCATION", "TIME ZONE", "NEW CONSTRUCTION", "CONTACT NAME", "CONTACT EMAIL", "CONTACT PHONE", "CALLER ID NAME","CUSTOM MUSIC", "SHIPPING ADDRESS",  "CONSTRUCTION DETAILS"];
    //         if(this.isTranslation){
    //             this.PremisesHeader.push('BUSINESS GROUP NAME','EAS PIN');
    //         }
    //         let resultNEw=[];
    //         if(result.length > 0){
    //             result.forEach(ele=>{
    //                 let newObj={};
    //                 newObj.Id = ele.Id;
    //                 newObj.Location_Name__c = ele?.Location_Name__c ?? '';
    //                 newObj.Location_Address__c = ele?.Location_Address__c ?? '';
    //                 newObj.Main_Phone_Number__c = ele?.Main_Phone_Number__c ?? '';
    //                 newObj.Shipping_Location__c = ele?.Shipping_Location__c ?? '';
    //                 newObj.Time_Zone__c = ele?.Time_Zone__c ?? '';
    //                 newObj.New_Construction__c = ele?.New_Construction__c ?? '';
    //                 newObj.Contact_Name__c = ele?.Contact_Name__c ?? '';
    //                 newObj.Contact_Email__c = ele?.Contact_Email__c ?? '';
    //                 newObj.Contact_Phone__c = ele?.Contact_Phone__c ?? '';
    //                 newObj.Caller_ID_Name__c = ele?.Caller_ID_Name__c ?? '';
    //                 newObj.Custom_music__c = ele?.Custom_music__c ?? '';
    //                 newObj.Shipping_Address__c = `${ele?.Shipping_Address__c ?? ''} ${ele?.Street__c??''} ${ele?.City__c??''} ${ele?.State__c??''} ${ele?.Zip__c??''}`;
    //                 // newObj.Shipping_Address__c = ele?.Shipping_Address__c +','+ele?.Street__c+','+ele?.City__c+','+ele?.State__c+','+ele?.Zip__c ?? '';
    //                 // newObj.Street__c = ele?.Street__c ?? '';
    //                 // newObj.City__c = ele?.City__c ?? '';
    //                 // newObj.State__c = ele?.State__c ?? '';
    //                 // newObj.Zip__c = ele?.Zip__c ?? '';
    //                 newObj.Construction_Details__c = ele?.Construction_Details__c ?? '';
    //                 if(this.isTranslation){
    //                     newObj.Business_Group_Name__c=ele?.Business_Group_Name__c?? '';
    //                     newObj.EAS_Pin__c=ele?.EAS_Pin__c ?? '';
    //                 }
    //                 resultNEw.push(newObj);
    //             })
    //             this.PremisesData = [...this.PremisesData, ...resultNEw];
    //             this.xlsFormatter(resultNEw, "Service Location",this.PremisesHeader);
    //             this.BusinessGroupName=result[0].Business_Group_Name__c || '';
    //             this.EAS_Pin=result[0].EAS_Pin__c || '';
    //         }
    //     })
    //     .catch(error => {
    //         console.error(error);
    //     });
    // }

    async getPremisesRecord(){
        try {
            let result = await getPremises2({recordId: this.recordId})
            if (result) {
                console.log('OUTPUT this.recordId : ',this.recordId);
                console.log('OUTPUT isTranslationUserValue : ',this.isTranslation);
                this.PremisesHeader = ["Id","LOCATION NAME", "LOCATION ADDRESS", "MAIN PHONE #", "SHIPPING LOCATION", "TIME ZONE", "NEW CONSTRUCTION", "CONTACT NAME", "CONTACT EMAIL", "CONTACT PHONE", "CALLER ID NAME","CUSTOM MUSIC", "SHIPPING ADDRESS",  "CONSTRUCTION DETAILS"];
                if(this.isTranslation || this.isReadOnly){
                    this.PremisesHeader.push('BUSINESS GROUP NAME','EAS PIN');
                }
                let resultNEw=[];
                if(result.length > 0){
                    result.forEach(ele=>{
                        let newObj={};
                        newObj.Id = ele.Id;
                        newObj.Location_Name__c = ele?.Location_Name__c ?? '';
                        newObj.Location_Address__c = ele?.Location_Address__c ?? '';
                        newObj.Main_Phone_Number__c = ele?.Main_Phone_Number__c ?? '';
                        newObj.Shipping_Location__c = ele?.Shipping_Location__c ?? '';
                        newObj.Time_Zone__c = ele?.Time_Zone__c ?? '';
                        newObj.New_Construction__c = ele?.New_Construction__c ?? '';
                        newObj.Contact_Name__c = ele?.Contact_Name__c ?? '';
                        newObj.Contact_Email__c = ele?.Contact_Email__c ?? '';
                        newObj.Contact_Phone__c = ele?.Contact_Phone__c ?? '';
                        newObj.Caller_ID_Name__c = ele?.Caller_ID_Name__c ?? '';
                        newObj.Custom_music__c = ele?.Custom_music__c ?? '';
                        newObj.Shipping_Address__c = `${ele?.Shipping_Address__c ?? ''} ${ele?.Street__c??''} ${ele?.City__c??''} ${ele?.State__c??''} ${ele?.Zip__c??''}`;
                        newObj.Construction_Details__c = ele?.Construction_Details__c ?? '';
                        if(this.isTranslation || this.isReadOnly){
                            newObj.Business_Group_Name__c=ele?.Business_Group_Name__c?? '';
                            newObj.EAS_Pin__c=ele?.EAS_Pin__c ?? '';
                        }
                        resultNEw.push(newObj);
                    })
                    this.PremisesData = [...this.PremisesData, ...resultNEw];
                    this.xlsFormatter(resultNEw, "Service Location",this.PremisesHeader);
                    this.BusinessGroupName=result[0].Business_Group_Name__c || '';
                    this.EAS_Pin=result[0].EAS_Pin__c || '';
                }
            }
            
        } catch (error) {
            console.error(error);
            
        }
    }

    // getDIDNumberRecord --- apex method getDIDNumberInfo
    // getDIDNumberRecord(){
    //     getDIDNumberInfo({orderId: this.recordId})
    //     .then(result => {
    //     console.log('OUTPUT getDIDNumberInfo :::::osama1 ',JSON.stringify(result));
    //     this.getDIDNumberInfoHeader = ["Id","Phone Number","Voip Qualification", "Current Carrier",'Install Type',"Number Use"," Service Location Name","Customize Extension","Extension Lenght"];
    //     // if(this.isTranslation){
    //     //     this.getDIDNumberInfoHeader.push("Local Routing Number");
    //     // }
    //     // this.getDIDNumberInfoHeader = Object.keys(result[0]);
    //     let resultNEw=[];
    //     if(result.length > 0){
    //         result.forEach(ele=>{
    //             let newObj={};
    //             newObj.Id=ele.Id;
    //             newObj.DID_Number__c=ele?.DID_Number__c ?? '';
    //             newObj.Ucf_Voip_Qualification__c=ele?.Ucf_Voip_Qualification__c ?? '';
    //             newObj.Ucf_Current_Carrier__c=ele?.Ucf_Current_Carrier__c ?? '';
    //             newObj.Ucf_Install_Type__c=ele?.Ucf_Install_Type__c ?? '';
    //             newObj.Ucf_Number_Use__c=ele?.Ucf_Number_Use__c ?? '';
    //             newObj.Name=ele?.DIDLocationDetailsId__r?.Name ?? '';
    //             newObj.Ucf_Customize_Extension__c=ele?.Ucf_Customize_Extension__c ?? '';
    //             newObj.Ucf_Extension_Lenght__c=ele?.Ucf_Extension_Lenght__c ?? '';
    //             // if(this.isTranslation){
    //             // newObj.Local_Routing_Number__c =ele?.Local_Routing_Number__c ?? '';
    //             // }
    //             resultNEw.push(newObj);
    //         })
    //         this.DIDNumberInfoTable = [...this.DIDNumberInfoTable, ...resultNEw];
    //         this.xlsFormatter(resultNEw, "Phone Number Information",this.getDIDNumberInfoHeader);
    //     }
    //     })
    //     .catch(error => {
    //     console.error(error);
    //     });
    // }

    async getDIDNumberRecord(){
        try {
            let result = await  getDIDNumberInfo({orderId: this.recordId});
            if (result) {
                console.log('OUTPUT getDIDNumberInfo :::::osama1 ',JSON.stringify(result));
                this.getDIDNumberInfoHeader = ["Id","Phone Number","Voip Qualification", "Current Carrier",'Install Type',"Number Use"," Service Location Name","Customize Extension","Extension Lenght"];
                // if(this.isTranslation){
                //     this.getDIDNumberInfoHeader.push("Local Routing Number");
                // }
                // this.getDIDNumberInfoHeader = Object.keys(result[0]);
                let resultNEw=[];
                if(result.length > 0){
                    result.forEach(ele=>{
                        let newObj={};
                        newObj.Id=ele.Id;
                        newObj.DID_Number__c=ele?.DID_Number__c ?? '';
                        newObj.Ucf_Voip_Qualification__c=ele?.Ucf_Voip_Qualification__c ?? '';
                        newObj.Ucf_Current_Carrier__c=ele?.Ucf_Current_Carrier__c ?? '';
                        newObj.Ucf_Install_Type__c=ele?.Ucf_Install_Type__c ?? '';
                        newObj.Ucf_Number_Use__c=ele?.Ucf_Number_Use__c ?? '';
                        newObj.Name=ele?.DIDLocationDetailsId__r?.UCFNameValidation__c ?? '';
                        newObj.Ucf_Customize_Extension__c=ele?.Ucf_Customize_Extension__c ?? '';
                        newObj.Ucf_Extension_Lenght__c=ele?.Ucf_Extension_Lenght__c ?? '';
                        // if(this.isTranslation){
                        // newObj.Local_Routing_Number__c =ele?.Local_Routing_Number__c ?? '';
                        // }
                        resultNEw.push(newObj);
                    })
                    this.DIDNumberInfoTable = [...this.DIDNumberInfoTable, ...resultNEw];
                    this.xlsFormatter(resultNEw, "Phone Number Information",this.getDIDNumberInfoHeader);
                }
            }
        } catch (error) {
            console.error(error);     
        }
    }

    // getEmployeeInfoRecord --- apex method getEmployeeInfo
    // getEmployeeInfoRecord(){
    //     getEmployeeInfo({recordId: this.recordId})
    //     .then(result => {
    //         console.log('OUTPUT getEmployeeInfoTable data :::Osama ',JSON.stringify(result));
    //         // this.getEmployeeInfoHeader = Object.keys(result[0]);
    //         this.getEmployeeInfoHeader = ["Id","Phone Number","Extension","User Name","Company Name","Address Number","Street Name","City","State","Zip Code","Identifying Location","Department","User Admin","Email","Outbound Caller ID","Other Outbound Caller ID","License Type","Device Type","Device Accessories","Dial Plan Information","Colaboration","Webinar","Call Recording","Audio Mining","Screen Recording","Storage"];
    //         if(this.isTranslation){
    //             this.getEmployeeInfoHeader.push("EAS Pin","MAC Address");
    //         }
    //         let resultNew=[];
    //         if(result.length > 0){
    //             result.forEach(ele=>{
    //                 let newObj={};
    //                 newObj.Id=ele.Id;
    //                 newObj.DIDNumber__c=ele?.DIDNumber__c ?? '';
    //                 newObj.Ucf_Extension__c=ele?.Ucf_Extension__c ?? '';
    //                 newObj.Ucf_User_Name__c=ele?.Ucf_User_Name__c ?? '';
    //                 // newObj.Ucf_Number_Use__c=ele?.Ucf_Number_Use__c ?? '';
    //                 newObj.Ucf_Company_Name__c=ele?.Ucf_Company_Name__c ?? '';
    //                 newObj.Ucf_Address_Number__c=ele.Ucf_Address_Number__c ?? '';
    //                 newObj.Ucf_Street_Name__c=ele?.Ucf_Street_Name__c ?? '';
    //                 newObj.Ucf_City__c=ele?.Ucf_City__c ?? '';
    //                 newObj.Ucf_State__c=ele?.Ucf_State__c ?? '';
    //                 newObj.Ucf_Zip_Code__c=ele?.Ucf_Zip_Code__c ?? '';
    //                 newObj.Ucf_Identifying_Location__c=ele?.Ucf_Identifying_Location__c ?? '';
    //                 newObj.Ucf_Department__c=ele.Ucf_Department__c ?? '';
    //                 newObj.Ucf_User_Admin__c=ele?.Ucf_User_Admin__c ?? '';
    //                 newObj.Ucf_Email__c=ele?.Ucf_Email__c ?? '';
    //                 newObj.Outbound_Caller_ID__c=ele?.Outbound_Caller_ID__c ?? '';
    //                 newObj.Ucf_Other_Outbound_Caller_ID__c=ele?.Ucf_Other_Outbound_Caller_ID__c ?? '';
    //                 newObj.Ucf_License_Type__c=ele?.Ucf_License_Type__c ?? '';
    //                 newObj.Ucf_Device_Type__c=ele?.Ucf_Device_Type__c ?? '';
    //                 newObj.Ucf_Device_Accessories__c=ele.Ucf_Device_Accessories__c ?? '';
    //                 newObj.Ucf_Dial_Plan_Information__c=ele?.Ucf_Dial_Plan_Information__c ?? '';
    //                 newObj.Ucf_Collaboration__c=ele?.Ucf_Collaboration__c ?? '';
    //                 newObj.Ucf_Webinar__c=ele?.Ucf_Webinar__c ?? '';
    //                 newObj.Ucf_Call_Recording__c=ele.Ucf_Call_Recording__c ?? '';
    //                 newObj.Ucf_Audio_Mining__c=ele?.Ucf_Audio_Mining__c ?? '';
    //                 newObj.Ucf_Screen_Recording__c=ele?.Ucf_Screen_Recording__c ?? '';
    //                 newObj.Ucf_Storage__c=ele?.Ucf_Storage__c ?? '';
    //                 if(this.isTranslation){
    //                     newObj.EAS_Pin__c=ele?.EAS_Pin__c ?? '';
    //                     newObj.Ucf_MAC_Address__c=ele?.Ucf_MAC_Address__c ?? '';
    //                     }
    //                 resultNew.push(newObj);
    //             })
    //             console.log('OUTPUT : resultNew employeeInfo',resultNew);
    //             this.getEmployeeInfoTable = [...this.getEmployeeInfoTable, ...resultNew];
    //             this.xlsFormatter(resultNew, "EmployeeInfo Information",this.getEmployeeInfoHeader);
    //         }
    //     })
    //     .catch(error => { 
    //         console.error(error);
    //     });
    // }
    async getEmployeeInfoRecord(){
        try {
            let result= await getEmployeeInfo({recordId: this.recordId});
            if (result) {
                console.log('OUTPUT getEmployeeInfoTable data :::Osama ',JSON.stringify(result));
                // this.getEmployeeInfoHeader = Object.keys(result[0]);
                this.getEmployeeInfoHeader = ["Id","Phone Number","Extension","User Name","Company Name","Address Number","Street Name","City","State","Zip Code","Identifying Location","Department","User Admin","Email","Outbound Caller ID","Other Outbound Caller ID","License Type","Device Type","Device Accessories","Dial Plan Information","Colaboration","Webinar","Call Recording","Audio Mining","Screen Recording","Storage"];
                if(this.isTranslation || this.isReadOnly){
                    this.getEmployeeInfoHeader.push("EAS Pin","MAC Address");
                }
                let resultNew=[];
                if(result.length > 0){
                    result.forEach(ele=>{
                        let newObj={};
                        newObj.Id=ele.Id;
                        newObj.DIDNumber__c=ele?.DIDNumber__c ?? '';
                        newObj.Ucf_Extension__c=ele?.Ucf_Extension__c ?? '';
                        newObj.Ucf_User_Name__c=ele?.Ucf_User_Name__c ?? '';
                        // newObj.Ucf_Number_Use__c=ele?.Ucf_Number_Use__c ?? '';
                        newObj.Ucf_Company_Name__c=ele?.Ucf_Company_Name__c ?? '';
                        newObj.Ucf_Address_Number__c=ele.Ucf_Address_Number__c ?? '';
                        newObj.Ucf_Street_Name__c=ele?.Ucf_Street_Name__c ?? '';
                        newObj.Ucf_City__c=ele?.Ucf_City__c ?? '';
                        newObj.Ucf_State__c=ele?.Ucf_State__c ?? '';
                        newObj.Ucf_Zip_Code__c=ele?.Ucf_Zip_Code__c ?? '';
                        newObj.Ucf_Identifying_Location__c=ele?.Ucf_Identifying_Location__c ?? '';
                        newObj.Ucf_Department__c=ele.Ucf_Department__c ?? '';
                        newObj.Ucf_User_Admin__c=ele?.Ucf_User_Admin__c ?? '';
                        newObj.Ucf_Email__c=ele?.Ucf_Email__c ?? '';
                        newObj.Outbound_Caller_ID__c=ele?.Outbound_Caller_ID__c ?? '';
                        newObj.Ucf_Other_Outbound_Caller_ID__c=ele?.Ucf_Other_Outbound_Caller_ID__c ?? '';
                        newObj.Ucf_License_Type__c=ele?.Ucf_License_Type__c ?? '';
                        newObj.Ucf_Device_Type__c=ele?.Ucf_Device_Type__c ?? '';
                        newObj.Ucf_Device_Accessories__c=ele.Ucf_Device_Accessories__c ?? '';
                        newObj.Ucf_Dial_Plan_Information__c=ele?.Ucf_Dial_Plan_Information__c ?? '';
                        newObj.Ucf_Collaboration__c=ele?.Ucf_Collaboration__c ?? '';
                        newObj.Ucf_Webinar__c=ele?.Ucf_Webinar__c ?? '';
                        newObj.Ucf_Call_Recording__c=ele.Ucf_Call_Recording__c ?? '';
                        newObj.Ucf_Audio_Mining__c=ele?.Ucf_Audio_Mining__c ?? '';
                        newObj.Ucf_Screen_Recording__c=ele?.Ucf_Screen_Recording__c ?? '';
                        newObj.Ucf_Storage__c=ele?.Ucf_Storage__c ?? '';
                        if(this.isTranslation || this.isReadOnly){
                            newObj.EAS_Pin__c=ele?.EAS_Pin__c ?? '';
                            newObj.Ucf_MAC_Address__c=ele?.Ucf_MAC_Address__c ?? '';
                            }
                        resultNew.push(newObj);
                    })
                    console.log('OUTPUT : resultNew employeeInfo',resultNew);
                    this.getEmployeeInfoTable = [...this.getEmployeeInfoTable, ...resultNew];
                    this.xlsFormatter(resultNew, "EmployeeInfo Information",this.getEmployeeInfoHeader);
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    // getMLHGSetupRecord --- apex method getTtrDIDNumberDetailsMLHGData
    async getMLHGSetupRecord(){
        try {
            let result = await getTtrDIDNumberDetailsMLHGData({recordId: this.recordId});
            if (result) {
                console.log('MLHG Information',JSON.stringify(result));
                //this.getTtrDIDNumberDetailsMLHGDataHeader = Object.keys(result.availableDIDNumberList[0]);
                this.getTtrDIDNumberDetailsMLHGDataHeader = ["Id","Phone Number","Extension", "MLHG Name","Ring Pattern","Schedule","Members"];
                if(this.isTranslation || this.isReadOnly){
                    this.getTtrDIDNumberDetailsMLHGDataHeader.push("EAS Pin");
                }
                // this.getDIDNumberInfoHeader = Object.keys(result[0]);
                let resultNEw=[];
                if(result.ftrDIDNumberDetailList.length > 0){
                        result.ftrDIDNumberDetailList.forEach(ele=>{
                        let newObj={};
                        newObj.Id=ele.Id;
                        newObj.DIDNumber__c=ele?.DIDNumber__c ?? '';
                        newObj.Ucf_Extension__c=ele?.Ucf_Extension__c ?? '';
                        newObj.MLHG_Name__c =ele?.MLHG_Name__c ?? '';
                        newObj.Ring_Pattern__c =ele?.Ring_Pattern__c ?? '';
                        newObj.Schedule__c=ele?.Schedule__r?.UCF_Name__c ?? '';
                        newObj.Member__c=ele?.Member__c ?? '';
                        if(this.isTranslation || this.isReadOnly){
                            newObj.EAS_Pin__c=ele?.EAS_Pin__c ?? '';   
                        }
                        resultNEw.push(newObj);
                    })
                    this.getTtrDIDNumberDetailsMLHGDataTable = [...this.getTtrDIDNumberDetailsMLHGDataTable,...resultNEw];
                    this.xlsFormatter(resultNEw, "MLHG Setup Information",this.getTtrDIDNumberDetailsMLHGDataHeader);
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    // getGeneralVoiceMailRecord --- apex method ftrDIDNumberDetailsGeneralVoicemail
    async getGeneralVoiceMailRecord(){
        try {
            let result = await ftrDIDNumberDetailsGeneralVoicemail({recordId: this.recordId});
            if (result) {
                console.log('OUTPUT ftrDIDNumberDetailsGeneralVoicemail data :::Osama3 ',JSON.stringify(result));
                if (result.length>0) {
                    //this.ftrDIDNumberDetailsGeneralVoicemailHeader = Object.keys(result[0]);
                    this.ftrDIDNumberDetailsGeneralVoicemailHeader = ["Id","Phone Number","Extension","Name","Email"];
                    if(this.isTranslation || this.isReadOnly){
                        this.ftrDIDNumberDetailsGeneralVoicemailHeader.push("EAS Pin");
                    }
                    let resultNEw=[];
                    result.forEach(ele=>{
                        let newObj={};
                        newObj.Id=ele.Id;
                        newObj.DIDNumber__c=ele?.DIDNumber__c ?? '';
                        newObj.Ucf_Extension__c=ele?.Ucf_Extension__c ?? '';
                        newObj.Ucf_General_Voice_Mail_Name__c=ele?.Ucf_General_Voice_Mail_Name__c ?? '';
                        newObj.Ucf_Email__c = ele?.Ucf_Email__c ?? '';
                        if(this.isTranslation || this.isReadOnly){
                            newObj.EAS_Pin__c=ele?.EAS_Pin__c ?? '';   
                        }
                        resultNEw.push(newObj);
                    })
                    this.ftrDIDNumberDetailsGeneralVoicemailTable = [...this.ftrDIDNumberDetailsGeneralVoicemailTable, ...result];
                    this.xlsFormatter(resultNEw, "General Voice Mail Information",this.ftrDIDNumberDetailsGeneralVoicemailHeader);
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    // getMLHGScheduleInfomation --- apex method queryschedules
    async getMLHGScheduleInfomation(){
        try {
            let result = await queryschedules({orderId: this.recordId});
            if (result) {
                console.log('OUTPUT queryschedules data :::Osama5 ',JSON.stringify(result));
                console.log('OUTPUT recordId :::Osama5 ',this.recordId);
                if (result.length>0) {
                    //this.queryschedulesHeader = Object.keys(result[0]);
                    this.getTtrDIDNumberDetailsMLHGDataHeader = ["Id","Schedule Name","Overflow Timer 24/7","Overflow Destination 24/7","Overflow Timer Closed","Overflow Destionation Closed","Overflow Timer Open","Overflow Destination Open","Monday Start Time","Monday End Time","Tuesday Start Time","Tuesday End Time","Wednesday Start Time","Wednesday End Time","Thursday Start Time","Thursday End Time","Friday Start Time","Friday End Time","Saturday Start Time","Saturday End Time","Sunday Start Time","Sunday End Time"];
                    let resultNEw=[];
                    result.forEach(ele=>{
                        let newObj={};
                        newObj.Id=ele.Id;
                        newObj.UCF_Name__c=ele?.UCF_Name__c ?? '';
                        newObj.Overflow_Timer_24_7__c=ele?.Overflow_Timer_24_7__c ?? '';
                        newObj.Overflow_Destination_24_7__c=ele?.Overflow_Destination_24_7__c ?? '';
                        newObj.Overflow_Timer_Closed__c = ele?.Overflow_Timer_Closed__c ?? '';
                        newObj.Overflow_Destination_Closed__c=ele.Overflow_Destination_Closed__c ?? '';
                        newObj.Overflow_Timer_Open__c=ele?.Overflow_Timer_Open__c ?? '';
                        newObj.Overflow_Destination_Open__c=ele?.Overflow_Destination_Open__c ?? '';
                        newObj.Monday_Start_Time__c=ele?.Monday_Start_Time__c ?? '';
                        newObj.Monday_End_Time__c=ele?.Monday_End_Time__c ?? '';
                        newObj.Tuesday_Start_Time__c = ele?.Tuesday_Start_Time__c ?? '';
                        newObj.Tuesday_End_Time__c=ele.Tuesday_End_Time__c ?? '';
                        newObj.Wednesday_Start_Time__c=ele?.Wednesday_Start_Time__c ?? '';
                        newObj.Wednesday_End_Time__c=ele?.Wednesday_End_Time__c ?? '';
                        newObj.Thursday_Start_Time__c=ele?.Thursday_Start_Time__c ?? '';
                        newObj.Thursday_End_Time__c=ele?.Thursday_End_Time__c ?? '';
                        newObj.Friday_Start_Time__c = ele?.Friday_Start_Time__c ?? '';
                        newObj.Friday_End_Time__c=ele.Friday_End_Time__c ?? '';
                        newObj.Saturday_Start_Time__c=ele?.Saturday_Start_Time__c ?? '';
                        newObj.Saturday_End_Time__c=ele?.Saturday_End_Time__c ?? '';
                        newObj.Sunday_Start_Time__c=ele?.Sunday_Start_Time__c ?? '';
                        newObj.Sunday_End_Time__c=ele?.Sunday_End_Time__c ?? '';
                        resultNEw.push(newObj);
                    })
                    this.queryschedulesTable = [...this.queryschedulesTable, ...result];
                    this.xlsFormatter(resultNEw, "MLHG Schedules Information", this.getTtrDIDNumberDetailsMLHGDataHeader);
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    // getMLHGHolidayInformation --- apex method downloadHolidaysBySchedule
    async getMLHGHolidayInformation(){
        try {
            let result = await downloadHolidaysBySchedule({OrderId: this.recordId});
            if (result) {
                console.log('OUTPUT downloadHolidaysBySchedule ',JSON.stringify(result));
                console.log('OUTPUT recordId :::downloadHolidaysBySchedule ',this.recordId);
                this.downloadHolidaysByScheduleHeader =["Id","Schedule Name","Holiday Name","Holiday Date"];
                let resultNEw=[];
                if (result.length>0) {
                    result.forEach(ele=>{
                        let newObj={};
                        newObj.Id=ele.Id;
                        newObj.ScheduleName=ele?.Schedule__r.UCF_Name__c ?? '';
                        newObj.Name=ele?.Name ?? '';
                        newObj.Date__c=ele?.Date__c ?? '';
                        resultNEw.push(newObj);
                    })
                    //this.ftrDIDNumberDetailsAutoAttendantsSetupHeader = Object.keys(result[0]);
                    this.downloadHolidaysByScheduleTable = [...this.downloadHolidaysByScheduleTable, ...result];
                    this.xlsFormatter(resultNEw, "MLHG Holiday Information",this.downloadHolidaysByScheduleHeader);
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    // getAutoAttendantSetupInformation --- apex method ftrDIDNumberDetailsAutoAttendantsSetup
    async getAutoAttendantSetupInformation(){
        try {
            let result = await ftrDIDNumberDetailsAutoAttendantsSetup({orderId: this.recordId});
            if (result) {
                console.log('OUTPUT ftrDIDNumberDetailsAutoAttendants data :::Osama6 ',JSON.stringify(result));
                console.log('OUTPUT recordId :::Osama6 ',this.recordId);
                this.ftrDIDNumberDetailsAutoAttendantsSetupHeader =["Id","Phone Number","Extension","Name","Schedule"];
                if(this.isTranslation || this.isReadOnly){
                    this.ftrDIDNumberDetailsAutoAttendantsSetupHeader.push("EAS Pin");
                }
                let resultNEw=[];
                if (result.length>0) {
                    result.forEach(ele=>{
                    let newObj={};
                    newObj.Id=ele.Id;
                    newObj.DIDNumber__c=ele?.DIDNumber__c ?? '';
                    newObj.Ucf_Extension__c=ele?.Ucf_Extension__c ?? '';
                    newObj.ucf_Auto_Attendent_Name__c =ele?.ucf_Auto_Attendent_Name__c ?? '';
                    newObj.Schedule__c =ele?.Schedule__r?.UCF_Name__c ?? '';
                    if(this.isTranslation || this.isReadOnly){
                        newObj.EAS_Pin__c=ele?.EAS_Pin__c ?? '';   
                    }
                    resultNEw.push(newObj);
                    })
                    //this.ftrDIDNumberDetailsAutoAttendantsSetupHeader = Object.keys(result[0]);
                    this.ftrDIDNumberDetailsAutoAttendantsSetupTable = [...this.ftrDIDNumberDetailsAutoAttendantsSetupTable, ...result];
                    this.xlsFormatter(resultNEw, "AA Setup Information",this.ftrDIDNumberDetailsAutoAttendantsSetupHeader);
                }                
            }
        } catch (error) {
            console.error(error);
        }
    }

    // getAutoAttendantMenuInformation --- apex method ScheduleforAutoAttendantSetUp
    async getAutoAttendantMenuInformation(){
        try {
            let result = await ScheduleforAutoAttendantSetUp({OrderId: this.recordId});
            if (result) {
                console.log('OUTPUT AA schedules data data :::Osama7 ',JSON.stringify(result));
                console.log('OUTPUT recordId :::Osama7 ',this.recordId);
                this.ScheduleforAutoAttendantSetUpHeader=["Id","Name","Number","Options","Destination Info","Greeting","Sub Menu"];
                let resultNEw=[];
                if (result.length>0) {
                    result.forEach(ele=>{
                    let newObj={};
                    newObj.Id=ele.Id;
                    newObj.MenuName=ele.Menu__r.Name;
                    newObj.Number__c=ele?.Number__c ?? '';
                    newObj.Options__c=ele?.Options__c ?? '';
                    newObj.Destination_Info__c =ele?.Destination_Info__c ?? '';
                    newObj.Greeting__c =ele?.Greeting__c ?? '';
                    newObj.Sub_Menu__c  =ele?.Sub_Menu__c ?? '';
                    resultNEw.push(newObj);
                    })
                    // this.ScheduleforAutoAttendantSetUpHeader = Object.keys(result[0]);
                    this.ScheduleforAutoAttendantSetUpTable = [...this.ScheduleforAutoAttendantSetUpTable, ...result];
                    this.xlsFormatter(resultNEw, "AA Menu Information",this.ScheduleforAutoAttendantSetUpHeader);
                }
            }
        } catch (error) {
            console.error(error);
        }

    }

    // getAutoAttendantScheduleInfomation --- apex method menusforAutoAttendants
    async getAutoAttendantScheduleInfomation(){
        try {
            let result = await menusforAutoAttendants({orderId: this.recordId});
            if (result) {
                console.log('OUTPUT ftrDIDNumberDetailsAutoAttendants data :::Osama8 ',JSON.stringify(result));
                //this.menusforAutoAttendantsHeader = Object.keys(result[0]);
                this.AASchedulesHeader = ["Id"," Schedul Name","Monday Start Time","Monday End Time","Tuesday Start Time","Tuesday End Time","Wednesday Start Time","Wednesday End Time","Thursday Start Time","Thursday End Time","Friday Start Time","Friday End Time","Saturday Start Time","Saturday End Time","Sunday Start Time","Sunday End Time","Menu Close","Menu Open","Menu Holiday"];
                let resultNEw=[];
                if(result.length > 0){
                    result.forEach(ele=>{
                    let newObj={};
                    newObj.Id=ele.Id;
                    newObj.UCF_Name__c=ele?.UCF_Name__c ?? '';
                    // newObj.Overflow_Destination_24_7__c=ele?.Overflow_Destination_24_7__c ?? ''; 
                    // newObj.Overflow_Timer_Closed__c = ele?.Overflow_Timer_Closed__c ?? '';
                    // newObj.Overflow_Destination_Closed__c=ele.Overflow_Destination_Closed__c ?? '';
                    // newObj.Overflow_Timer_Open__c=ele?.Overflow_Timer_Open__c ?? '';
                    // newObj.Overflow_Destination_Open__c=ele?.Overflow_Destination_Open__c ?? '';
                    newObj.Monday_Start_Time__c=ele?.Monday_Start_Time__c ?? '';
                    newObj.Monday_End_Time__c=ele?.Monday_End_Time__c ?? '';
                    newObj.Tuesday_Start_Time__c = ele?.Tuesday_Start_Time__c ?? '';
                    newObj.Tuesday_End_Time__c=ele.Tuesday_End_Time__c ?? '';
                    newObj.Wednesday_Start_Time__c=ele?.Wednesday_Start_Time__c ?? '';
                    newObj.Wednesday_End_Time__c=ele?.Wednesday_End_Time__c ?? '';
                    newObj.Thursday_Start_Time__c=ele?.Thursday_Start_Time__c ?? '';
                    newObj.Thursday_End_Time__c=ele?.Thursday_End_Time__c ?? '';
                    newObj.Friday_Start_Time__c = ele?.Friday_Start_Time__c ?? '';
                    newObj.Friday_End_Time__c=ele.Friday_End_Time__c ?? '';
                    newObj.Saturday_Start_Time__c=ele?.Saturday_Start_Time__c ?? '';
                    newObj.Saturday_End_Time__c=ele?.Saturday_End_Time__c ?? '';
                    newObj.Sunday_Start_Time__c=ele?.Sunday_Start_Time__c ?? '';
                    newObj.Sunday_End_Time__c=ele?.Sunday_End_Time__c ?? '';
                    newObj.Ucf_Menu_Close__c=ele?.Ucf_Menu_Close__c ?? '';
                    newObj.Ucf_Menu_Open__c=ele?.Ucf_Menu_Open__c ?? '';
                    newObj.Menu_Holiday__c=ele?.Menu_Holiday__c ?? '';
                    resultNEw.push(newObj);
                    })
                    this.menusforAutoAttendantsTable = [...this.menusforAutoAttendantsTable, ...resultNEw];
                    // console.log('OUTPUT ::::: Osama 8 New Data : ',JSON.stringify(resultNEw));
                    this.xlsFormatter(resultNEw, "AA Schedules Information",this.AASchedulesHeader);
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    // getAutoAttendantGreetingRecords --- apex method greetingsforAutoAttendantsGreetings
    async getAutoAttendantGreetingRecords(){
        try {
            let result = await greetingsforAutoAttendantsGreetings({orderId: this.recordId});
            if (result) {
                console.log('OUTPUT greetingsforAutoAttendantsGreetings data :::Osama9 ',JSON.stringify(result));
                this.greetingsforAutoAttendantsGreetingsHeader=["Id","Name","Greetings"];
                let resultNEw=[];
                if (result.length>0) {
                    result.forEach(ele=>{
                    let newObj={};
                    newObj.Id=ele.Id;
                    newObj.Name=ele?.Name ?? '';
                    newObj.Message_Board__c=ele?.Message_Board__c ?? '';
                    resultNEw.push(newObj);
                    })
                    //this.greetingsforAutoAttendantsGreetingsHeader = Object.keys(result[0]);
                    this.greetingsforAutoAttendantsGreetingsTable = [...this.greetingsforAutoAttendantsGreetingsTable, ...resultNEw];
                    this.xlsFormatter(resultNEw, "AA Greetings Information",this.greetingsforAutoAttendantsGreetingsHeader);
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    // getAutoAttendantHolidayInformation -- apex method downloadHolidaysByAASchedule
    async getAutoAttendantHolidayInformation(){
        try {
            let result = await downloadHolidaysByAASchedule({OrderId: this.recordId});
            if (result) {
                console.log('OUTPUT downloadHolidaysByAASchedule ',JSON.stringify(result));
                this.downloadHolidaysByAAScheduleHeader =["Id","Schedule Name","Holiday Name","Holiday Date"];
                let resultNEw=[];
                if (result.length>0) {
                    result.forEach(ele=>{
                    let newObj={};
                    newObj.Id=ele.Id;
                    newObj.ScheduleName=ele?.Schedule__r.UCF_Name__c ?? '';
                    newObj.Name=ele?.Name ?? '';
                    newObj.Date__c=ele?.Date__c ?? '';
                    resultNEw.push(newObj);
                    })
                    //this.ftrDIDNumberDetailsAutoAttendantsSetupHeader = Object.keys(result[0]);
                    this.downloadHolidaysByAAScheduleTable = [...this.downloadHolidaysByAAScheduleTable, ...result];
                    this.xlsFormatter(resultNEw, "AA Holiday Information",this.downloadHolidaysByAAScheduleHeader);
                }
            }
        } catch (error) {
            console.error(error);
        } 
    }

    // getPageGroupInformation -- apex method loadComponent
    async getPageGroupInformation(){
        try {
            let result = await loadComponent({orderId: this.recordId});
            if (result) {
                console.log('OUTPUT pageGroup data :::Osama10 ',JSON.stringify(result));
                this.loadComponentHeader=["Id","Name","Members"];
                let resultNEw=[];
                if (result.length>0) {
                    result.forEach(ele=>{
                    let newObj={};
                    newObj.Id=ele.Id;
                    newObj.Name=ele?.Name ?? '';
                    newObj.Members__c=ele?.Members__c ?? '';
                    resultNEw.push(newObj);
                    })
                    //this.loadComponentHeader = Object.keys(result[0]);
                    console.log('OUTPUT pageGroup New data :::Osama10',resultNEw);
                    this.loadComponentTable = [...this.loadComponentTable, ...resultNEw];
                    this.xlsFormatter(resultNEw, "Page Group Information",this.loadComponentHeader);
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    // getCustomizationNotesInformation -- apex method loadComponentCustomizationNotes
    async getCustomizationNotesInformation(){
        try {
            let result = await loadComponentCustomizationNotes({recordId: this.recordId});
            if (result) {
                console.log('OUTPUT loadComponentCustomizationNotes data :::Osama11 ',JSON.stringify(result));
                this.loadComponentCustomizationNotesHeader=["Id","Group Page","Park Keys","How many Park Keys","Is it shared or location/department","Group Pickup","DSS/BLF Enhanced Monitor Extensions Buttons","Speed Calls","Direct Page","Additional UCF Information"];
                let NewResult=[];
                if (result.orderRecord != null) {
                    let newObj={};
                    newObj.Id=result.orderRecord.Id;
                    newObj.Group_Page__c=result.orderRecord.Group_Page__c ?? '';
                    newObj.Park_Keys__c=result.orderRecord.Park_Keys__c ?? '';
                    newObj.How_many_park_keys__c=result.orderRecord.How_many_park_keys__c ?? '';
                    newObj.Is_it_shared_or_location_department__c=result.orderRecord.Is_it_shared_or_location_department__c ?? '';
                    newObj.Group_Pickup__c=result.orderRecord.Group_Pickup__c ?? '';
                    newObj.DSS_BLF_Enhanced_Monitor_Extensions_Btns__c=result.orderRecord.DSS_BLF_Enhanced_Monitor_Extensions_Btns__c ?? '';
                    newObj.Speed_Calls__c=result.orderRecord.Speed_Calls__c ?? '';
                    newObj.Direct_Page__c=result.orderRecord.Direct_Page__c ?? '';
                    newObj.Additional_UCF_Information__c=result.orderRecord.Additional_UCF_Information__c ?? '';
                    NewResult.push(newObj);
                    console.log('Customization notes Order Data',NewResult);
                    this.loadComponentCustomizationNotesTable = [...this.loadComponentCustomizationNotesTable, ...NewResult];
                    this.xlsFormatter(NewResult, "Customization Notes Information",this.loadComponentCustomizationNotesHeader);
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    async getNotifications911CustomizationNotes(){
        try {
            let result = await Notifications911CustomizationNotes({recordId: this.recordId});
            if (result) {
                console.log('OUTPUT Notifications911CustomizationNotes data  ',JSON.stringify(result));
                console.log('zainab',JSON.stringify(result.NotificationList));
                this.Notifications911CustomizationNotesHeader=["Id","Name","Department/System","Department Name","Method","Phone Number","Email Address","Order Id"];
                let NewResult=[];
                if (result.NotificationList != null) {
                    result.NotificationList.forEach(ele=>{
                    let newObj={};
                    newObj.Id = ele.Id;
                    newObj.Name=ele.Name ?? '';
                    newObj.Department_System__c=ele.Department_System__c ?? '';
                    newObj.Department_Name__c=ele.Department_Name__c ?? '';
                    newObj.Method__c=ele.Method__c ?? '';
                    newObj.Phone_Number__c=ele.Phone_Number__c ?? '';
                    newObj.Email_Address__c=ele.Email_Address__c ?? '';
                    newObj.Order__c=ele.Order__c ?? '';
                    NewResult.push(newObj);
                })
                    console.log('911 Notifications testing',JSON.stringify(NewResult));
                    this.Notifications911CustomizationNotesTable = [...this.Notifications911CustomizationNotesTable, ...NewResult];
                    this.xlsFormatter(NewResult, "Notifications 911",this.Notifications911CustomizationNotesHeader);
                
                }
            }
        } catch (error) {
            console.error(error);
        }
    }
    
  // formating the data to send as input to  xlsxMain component
  xlsFormatter(data, sheetName, headers=null) {
    let Header=[];
    if(headers==null){
        Header = Object.keys(data[0]);
    }
    else{
        Header = headers;
    }
    //console.log('OUTPUT Header didnumber: ',Header);
    this.xlsHeader.push(Header);
    this.workSheetNameList.push(sheetName);
    this.xlsData.push(data);
  }
   // calling the download function from xlsxMain.js 
   async download() {
    let downloadBtn = this.template.querySelector("c-xlsx-main");
    console.log('inside download button');
    await this.downloadAllPMData();
    this.downloadLoader=false;
    console.log('this.template.querySelector("c-xlsx-main")',this.template.querySelector("c-xlsx-main"));
    downloadBtn.download();
  }

  async downloadAllPMData(){
    this.downloadLoader = true;
    await this.getPremisesRecord();
    await this.getDIDNumberRecord();
    await this.getEmployeeInfoRecord();
    await this.getMLHGScheduleInfomation();
    await this.getMLHGSetupRecord();
    await this.getMLHGHolidayInformation();
    await this.getMLHGSelectedMembersData();
    await this.getdownloadCustomTimePeriodMLHG();
    await this.getAutoAttendantGreetingRecords();
    await this.getAutoAttendantMenuInformation();
    await this.getAutoAttendantScheduleInfomation();
    await this.getAutoAttendantHolidayInformation();
    await this.getAutoAttendantSetupInformation();
    await this.getdownloadCustomtimeperiodAA();
    await this.getGeneralVoiceMailRecord();
    await this.getCustomizationNotesInformation();
    await this.getNotifications911CustomizationNotes();
    await this.getPageGroupInformation();
    await this.getPageGourpMembersDataToDownload();
    //this.getOrderStage();
    if (this.isTranslation || this.isReadOnly) {
        await this.getNpaNxxList();
    }
  }

async fetchServiceLocations() {
        // Prepare the parameters for the Apex call
        const params = {
            orderId: this.recordId,
            sortField: this.sortField,
            sortDirection: this.sortDirection,
            refreshTable: this.refreshTable
        };

          // Make the imperative call to the Apex method
        getPremises(params)
            .then(data => {
                //console.log('SL hit : ', data);
                      if (data) {
                    let hasCustomMusic = false; // Flag to track if any record has custom music set to 'Yes'
                    this.accounts = data.map(serviceLocation => {
                        // Determine if the current record has custom music set to 'Yes'
                        this.EAS_Pin=serviceLocation.EAS_Pin__c || '';
                        this.BusinessGroupName=serviceLocation.Business_Group_Name__c || '';
                          let showCustomMusicOption = serviceLocation.Custom_music__c === 'Yes';
                           if (!showCustomMusicOption || showCustomMusicOption === '' || showCustomMusicOption === 'undefined') {
                                showCustomMusicOption = 'No';
                            }
                            else
                            {
                                showCustomMusicOption = 'Yes';
                            }
                            let customMusicValue = 'No';
                            customMusicValue = serviceLocation.Custom_music__c;
                             //alert('customMusicValue 2 '+ customMusicValue);
                           if (!customMusicValue || customMusicValue === '' || customMusicValue === 'undefined' || customMusicValue === 'No') {
                                customMusicValue = 'No';
                                  //alert('customMusicValue 2 in if '+ customMusicValue);
                            }
                            else
                            {
                                customMusicValue = 'Yes';
                            }
                    
               if (showCustomMusicOption == 'Yes') {
                    hasCustomMusic = true;
                }
                        return {
                            ...serviceLocation,
                            editMode: true,
                            Location_Name__c:serviceLocation.Location_Name__c || '',
                            Caller_ID_Name__c: serviceLocation.Caller_ID_Name__c || '',
                            Contact_Email__c: serviceLocation.Contact_Email__c || '',
                            Contact_Phone__c: serviceLocation.Contact_Phone__c  || '',
                            Contact_Name__c: serviceLocation.Contact_Name__c  || '',
                            Main_Phone_Number__c: serviceLocation.Main_Phone_Number__c  || '',
                             CustomMusic: customMusicValue,
                            showCustomMusicOption: showCustomMusicOption,
                        };
                        
                       
                    });
                     //alert('account oo1 : '+ JSON.stringify(this.accounts));

                    this.accounts2 = data.map(serviceLocation => {
                        // Determine if the current record has custom music set to 'Yes'
                        this.EAS_Pin=serviceLocation.EAS_Pin__c || '';
                        this.BusinessGroupName=serviceLocation.Business_Group_Name__c || '';
                           let customMusicValue = 'No';
                            customMusicValue = serviceLocation.Custom_music__c;
                           if (!customMusicValue || customMusicValue === '' || customMusicValue === 'undefined' || customMusicValue === 'No') {
                                customMusicValue = 'No';
                            }
                            else
                            {
                                customMusicValue = 'Yes';
                            }
                          let showCustomMusicOption = serviceLocation.Custom_music__c === 'Yes';
                if (showCustomMusicOption) {
                    hasCustomMusic = true;
                }
                        return {
                            ...serviceLocation,
                            editMode: true,
                            Location_Name__c:serviceLocation.Location_Name__c || '',
                            Caller_ID_Name__c: serviceLocation.Caller_ID_Name__c || '',
                            Contact_Email__c: serviceLocation.Contact_Email__c || '',
                            Contact_Phone__c: serviceLocation.Contact_Phone__c  || '',
                            Contact_Name__c: serviceLocation.Contact_Name__c  || '',
                             Main_Phone_Number__c: serviceLocation.Main_Phone_Number__c  || '',
                            CustomMusic: customMusicValue,
                            showCustomMusicOption: showCustomMusicOption,
                        };
                       
                    });
                   // alert('account 2: '+ JSON.stringify(this.accounts2));
                      this.showWarningMessage = hasCustomMusic;
                      this.ShowLoader=false;
                }
            })
            .catch(error => {
                this.error = error;
                // Handle the error
            });
            
    }


async getNpaNxxList(){
    try {
        let result = await getNpaNxxList({});
        if (result) {
            console.log('getNpaNxxList ',JSON.parse(JSON.stringify(result)))
            this.NpaNxxHeader = ["Id" , "Name", "NPA","NXX","Local Routing Number"];
            let resultNEw=[];
            if (result.length > 0) {
                console.log('getNpaNxxList ',JSON.parse(JSON.stringify(result)))
                result.forEach(ele=>{
                    let newObj={};
                    newObj.Id=ele.Id;
                    newObj.Name=ele?.Name ?? '';
                    newObj.NPA__c=ele?.NPA__c ?? '';
                    newObj.NXX__c=ele?.NXX__c ?? '';
                    newObj.Local_Routing_Number__c=ele?.Local_Routing_Number__c ?? '';
                    resultNEw.push(newObj);
                })
             this.xlsFormatter(resultNEw, "NPA AND NXX INFO",this.NpaNxxHeader);
            }
        }
    } catch (error) {
        console.log('NpaNxxHeader', error);
    }
}


async getIsAdmin(){
    try {
       // alert('userType');
        let data = await isTranslationUser({ OrderId: this.recordId }); 
        if (data) {
            this.userType = data;
            //alert('userType ' +this.userType);
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
            //alert('userType ' +this.userType);
           //alert('T ' +this.isTranslation);
           //alert('R ' +this.isReadOnly);
            console.log('this.isTranslation',this.isTranslation);
        }            
    } catch (error) {
        console.error("Error determining user profile:", error);
        
    }
}

handleCancel(event)
{
    this.BusinessGroupName = '';
    this.EAS_Pin = '';
    this.fetchServiceLocations();
}
handleInputBusinessGroup(event)
{
    this.BusinessGroupName=event.target.value;
    this.handleInputChange(event);
}
handleInputEASPin(event)
{
    this.EAS_Pin=event.target.value;
    this.handleInputChange(event);
    
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


    handleInputChange(event) {
       //alert('21');
    this.fieldChangeCount++;
    this.notifyInputChange(this.fieldChangeCount);
    const recordId = event.target.dataset.recordId;
    const fieldName = event.target.dataset.fieldName;
    const newValue = event.target.value;

    console.log('value' + newValue);
    
    if (!this.isValidEmail(newValue) && newValue != '' && fieldName=='Contact_Email__c') {
            // Show error toast and exit the function if email is invalid
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Invalid Email',
                    message: 'Please enter a valid email address.',
                    variant: 'error'
                })
            ); 
            return; // Prevent further processing if the email is invalid
        } 

        if(newValue != '' && fieldName=='Main_Phone_Number__c'){
            this.mainPhoneNumber =  newValue;      }
        if(newValue != '' && fieldName=='Location_Name__c'){
            this.locationName =  newValue;      }

    
    const index = this.accounts.findIndex(account => account.Id === recordId);
    if (index !== -1) {
        // Update the field value in the account data
       this.accounts[index][fieldName] = newValue;

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
        //alert('here')
        this.checkForCustomMusicWarning();
       console.log('draft testing zaaa'+ JSON.stringify(this.draftValues));
       //this.uniqueKey++;

    }
        
} //commented by zainab for the time being
/*
handleInputChange(event) {
    this.fieldChangeCount++;
    this.notifyInputChange(this.fieldChangeCount);
    const recordId = event.target.dataset.recordId;
    const fieldName = event.target.dataset.fieldName;
    const newValue = event.target.value;

    // Email validation
    if (fieldName === 'Contact_Email__c' && newValue !== '' && !this.isValidEmail(newValue)) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Invalid Email',
            message: 'Please enter a valid email address.',
            variant: 'error'
        }));
        return; // Exit if the email is invalid
    }

    // Update specific fields
    if (fieldName === 'Main_Phone_Number__c') {
        this.mainPhoneNumber = newValue;
    }
    if (fieldName === 'Location_Name__c') {
        this.locationName = newValue;
    }

    // Update accounts array
    let updatedAccounts = this.accounts.map(account => {
        if (account.Id === recordId) {
            return { ...account, [fieldName]: newValue };
        }
        return account;
    });
    this.accounts = [...updatedAccounts];

    // Update draftValues array
    let updatedDraft = this.draftValues.find(draft => draft.Id === recordId);
    if (updatedDraft) {
        updatedDraft = { ...updatedDraft, [fieldName]: newValue };
        this.draftValues = this.draftValues.map(draft => draft.Id === recordId ? updatedDraft : draft);
    } else {
        this.draftValues = [...this.draftValues, { Id: recordId, [fieldName]: newValue }];
    }

    console.log('Draft Values za:', JSON.stringify(this.draftValues));
}
*/



/*
checkForCustomMusicWarning() {
    // Create a list of account IDs where Custom_music__c is 'Yes'
    const customMusicAccountIds = this.accounts.filter(account => account.Custom_music__c === 'Yes').map(account => account.Id);

    // Initially assume no custom music (flag is false)
    let flag = false;

    // Iterate through draftValues
    this.draftValues.forEach(draft => {
        if (draft.Custom_music__c === 'Yes') {
            // If any draft record has Custom_music__c as 'Yes', set the flag to true
            flag = true;
        } else if (draft.Custom_music__c === 'No' && customMusicAccountIds.includes(draft.Id)) {
            // If a draft record has Custom_music__c as 'No' and it matches an ID in the list, set the flag to false
            flag = false;
        }
    });

    // Set the showWarningMessage based on the flag
    this.showWarningMessage = flag;
} */

checkForCustomMusicWarning() {
    console.log('No');
    // Create a list of account IDs where Custom_music__c is 'Yes' in the original accounts list
    const customMusicAccountIds = this.accounts
        .filter(account => account.Custom_music__c === 'Yes')
        .map(account => account.Id);

    // Initially assume no custom music (flag is false)
    let flag = false;

    if(customMusicAccountIds.length > 0)
    {
        flag = true;
    }

    for (let draft of this.draftValues) {
        if (draft.Custom_music__c === 'Yes') {

            flag = true;
           // break;
        } 
         if (draft.Custom_music__c === 'No' && customMusicAccountIds.filter(id => id === draft.Id)) {
            const otherYesAccounts = customMusicAccountIds.filter(id => id !== draft.Id);
            
            if (!otherYesAccounts.length > 0) {
                flag = false;
                break;
            }
        }
    }

    // Set the showWarningMessage based on the flag
    this.showWarningMessage = flag;
}





showEmailValidationError() {
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Invalid Email',
            message: 'Please enter a valid email address.',
            variant: 'error'
        })
    );
}




isValidEmail(email) {
    //console.log('isValidEmail ' + email);
    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return emailRegex.test(email);
}




    areAllEmailsValid() {
       //console.log('areAllEmailsValid');
    for (let i = 0; i < this.draftValues.length; i++) {
        //console.log('Draft Values ' + JSON.stringify(this.draftValues));
        const email = this.draftValues[i].Contact_Email__c; // assuming 'Email' is the field name
         //console.log('areAllEmailsValid email' + email);

        if (!this.isValidEmail(email)) {
            return false;
        }
    }
    return true;
}



    sortAllFields(event) {
        this.sortField = event.currentTarget.dataset.fieldName;
        this.sortDirection = this.sortField === this.sortField && this.sortDirection === 'asc' ? 'desc' : 'asc';
        this.sortData();
    }
    // Sort data array based on current sorting criteria
    sortData() {
    const field = this.sortField;
    const reverse = this.sortDirection === 'desc' ? -1 : 1;
    this.accounts = [...this.accounts.sort((a, b) => (a[field] > b[field] ? 1 : -1) * reverse)];
}


  openModal(event) {
    const recordIdToEdit = event.currentTarget.dataset.recordId;
    const sLToEdit = this.accounts.find(Service_Location__c => Service_Location__c.Id === recordIdToEdit);
    // Set the values from the selected record
    this.recordIdToEdit = recordIdToEdit;

    console.log(sLToEdit.Shipping_Location__c);
    this.constructionDetails = sLToEdit.Construction_Details__c;
        if(sLToEdit.Shipping_Location__c === 'Different address')
        {
            this.shippingAddress =sLToEdit.Shipping_Address__c != undefined ? sLToEdit.Shipping_Address__c  : null;
            this.shippingStreet = sLToEdit.Street__c != undefined ? sLToEdit.Street__c  : null;
            this.shippingCity = sLToEdit.City__c != undefined ? sLToEdit.City__c  : null;
            this.shippingState = sLToEdit.State__c != undefined ? sLToEdit.State__c  : null;
            this.shippingZip = sLToEdit.Zip__c != undefined ? sLToEdit.Zip__c  : null;
        }
        else{
            
            this.shippingStreet = sLToEdit.Location_Street__c != undefined ? sLToEdit.Location_Street__c  : null;
            this.shippingCity = sLToEdit.Location_City__c != undefined ? sLToEdit.Location_City__c  : null;
            this.shippingState = sLToEdit.Location_State__c != undefined ? sLToEdit.Location_State__c  : null;
            this.shippingZip = sLToEdit.Location_Zip__c != undefined ? sLToEdit.Location_Zip__c  : null;
        }
        

    //alert(this.shippingAddress);
    
    this.isModalOpen = true;
}
    
 

 handleRatingChange(event) {
        const selectedValue = event.target.value;
        // You can add logic to update the selected rating in your data or save it back to Salesforce.
    }



    closeModal() {
        this.isModalOpen = false;
    }

    handleShippingAddressChange(event) {
        this.shippingAddress = event.target.value;
    }

    handleshippingStreetChange(event) {
        this.shippingStreet = event.target.value;
    }
    handleshippingCityChange(event) {
        this.shippingCity = event.target.value;
    }
    handleshippingStateChange(event) {
        this.shippingState = event.target.value;
    }
    handleshippingZipChange(event) {
        this.shippingZip = event.target.value;
    }
    handleConstructionDetailsChange(event) {
        this.constructionDetails = event.target.value;
    }

   handleModalSave() {
    // Create an object to store the fields to update

    const fieldsToUpdate = {
        recordId: this.recordIdToEdit,
        constructionDetails: this.constructionDetails,
        shippingAddress: this.shippingAddress,
        shippingStreet: this.shippingStreet,
        shippingCity: this.shippingCity,
        shippingState: this.shippingState,
        shippingZip: this.shippingZip
    };
       // Call the Apex method to update the record
    updateServiceLoacationMoadalFields(fieldsToUpdate)
        .then(result => {
            // Close the modal
            this.isModalOpen = false;
           // alert(JSON.stringify('RS: '+ result))

            // Refresh the table or data
           // return refreshApex(this.wiredAccounts)
           this.fetchServiceLocations();    
           
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
// Added to check all the required fields on service location tab 
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
  // In your LWC component, add a method to save the edited records
handleSave() {
    if (this.isTranslation) {
        console.log('Easpin', this.EAS_Pin);
    }
  
    let isValidationFailed = false;
    if(!this.validateRequiredFields())
    {
        this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fields Required',
                    message: 'Please fill out all required fields',
                    variant: 'error'
                })
            );
        isValidationFailed = true;
        return;
    }
   //alert(this.mainPhoneNumber);
   
   //alert('records  2 '+ JSON.stringify(this.accounts2));
   const isDuplicate = this.accounts2.some(detail =>
                detail.Main_Phone_Number__c === this.mainPhoneNumber && detail.Id !== this.recordId
            );
            //alert(isDuplicate);
            if (isDuplicate) {
                // Alert the user that the webinar value is already selected
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Duplicate Phone Number',
                        message: 'Please enter an unique Phone Number',
                        variant: 'error'
                    })
                );
                isValidationFailed = true;
                return;
            }


   this.accounts.forEach(detail =>{
                    //console.log('detail.Main_Phone_Number__c' +  detail.Main_Phone_Number__c);
                    if(detail.Main_Phone_Number__c == undefined || detail.Main_Phone_Number__c.length < 10 )
                            {   
                                this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Length Error',
                                    message: 'Phone number should not be less than 10',
                                    variant: 'error'
                                })
                            );
                           isValidationFailed = true;
                            return;
                                
                            }               
        });

   if(this.isTranslation)
   {

       if (this.EAS_Pin !== undefined && this.EAS_Pin !== null) {
    // Check the length of this.EAS_Pin
    if (this.EAS_Pin.length === 0) {
        console.log('EAS_Pin length:', this.EAS_Pin.length); // Output length for debugging
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Eas Pin Error',
                message: 'Eas Pin cannot be null',
                variant: 'error'
            })
        );
        return; 
    }
      /* if(!this.EAS_Pin.length >0)
       {
           this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Eas Pin Error',
                    message: 'Eas Pin can not be null',
                    variant: 'error'
                })
            );
            return; 
       } */
   } 
   }

   if(this.isTranslation)
   {
       //alert('hello', JSON.stringify(this.BusinessGroupName));
       if(!this.BusinessGroupName.length >0)
       {
           this.dispatchEvent(
                new ShowToastEvent({
                    title: 'BusinessGroupName  Error',
                    message: 'BusinessGroupName can not be null',
                    variant: 'error'
                })
            );
            return; 
       }
   }
   
   if(this.isTranslation)
   {
       
       if(this.EAS_Pin.length < 6)
       {
           this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Eas Pin Error',
                    message: 'Eas Pin can not be less than 6',
                    variant: 'error'
                })
            );
            return; 
       }
   }



    // Create an array to store the records that need to be updated
    const recordsToUpdateForUpdate = [];
    // Loop through draftValues to build the array of records to update
    
    const recordsToUpdateDIDNumber = [];
   // alert('Drrrraaaatttt '+ JSON.stringify(this.draftValues));
   if(this.draftValues.length > 0)
   {
    this.draftValues.forEach(draft => {
        
        recordsToUpdateForUpdate.push({
            Id: draft.Id,
            Shipping_Location__c: draft.Shipping_Location__c, // Replace with your field names
            Time_Zone__c: draft.Time_Zone__c, // Replace with your field names
            New_Construction__c: draft.New_Construction__c,
            Contact_Name__c: draft.Contact_Name__c,
            Caller_ID_Name__c: draft.Caller_ID_Name__c,
            Business_Group_Name__c:this.BusinessGroupName,
            EAS_Pin__c:this.EAS_Pin,
            Contact_Email__c:draft.Contact_Email__c,
            Contact_Phone__c:draft.Contact_Phone__c,
            Contact_Name__c:draft.Contact_Name__c,
            Custom_music__c:draft.Custom_music__c,
            Main_Phone_Number__c : draft.Main_Phone_Number__c,
            Location_Name__c:draft.Location_Name__c

        });
        
    });
   }
   else if(this.draftValues.length == 0 && this.BusinessGroupName != null)
   {
    this.accounts.forEach(draft => {
        recordsToUpdateForUpdate.push({
            Id: draft.Id,
            EAS_Pin__c:this.EAS_Pin,
            Business_Group_Name__c:this.BusinessGroupName
        });
    });
   }
    
            
    	//alert( JSON.stringify(recordsToUpdateForUpdate));
    if(this.EAS_Pin != null)
    {
       
        updateDIDNumbersFieldsList({EASPin:this.EAS_Pin,recordId:this.recordId})
    }

    //alert( JSON.stringify('Final: '+ recordsToUpdateForUpdate));
   
    // Call the Apex method to update the records
    if (isValidationFailed==false) {
    updatePremiseFieldsList({recordsToUpdateForUpdate:recordsToUpdateForUpdate,ServiceLocationOldValues:this.accounts,orderId:this.recordId})
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
            this.fetchServiceLocations();
            // Refresh the table data
           // return refreshApex(this.wiredAccounts);
        })
        .catch(error => {
            // Handle error
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error updating records: ' + error.body.message,
                    variant: 'error'
                })
            );
        });
}
}

notifyInputChange(count){
    this.dispatchEvent(new CustomEvent('recordchange', {
        detail: {
            component: 'serviceLocation',
            message: count
        }
    }));
}

}