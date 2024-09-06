import { LightningElement,api, wire, track } from 'lwc';
import {FlowAttributeChangeEvent,FlowNavigationNextEvent} from 'lightning/flowSupport';
import { loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/xlsx";
import getPremises2 from '@salesforce/apex/PmEnrichmentController.getPremises2';
import getDIDNumberInfo from '@salesforce/apex/PmEnrichmentController.ftrPhoneNumberDetails';
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
import downloadCustomtimeperiodAA from '@salesforce/apex/UcfAutoAttendentController.downloadCustomtimeperiodAA';
import loadComponentCustomizationNotes from '@salesforce/apex/CustomizationsNotesUcfController.loadData';
import Notifications911CustomizationNotes from '@salesforce/apex/CustomizationsNotesUcfController.loadData';
import DownloadPMPageGroupMembers from '@salesforce/apex/PageGroupsController.DownloadPMPageGroupMembers';
import storeContentVersions from '@salesforce/apex/TaskSendEmailAction.storeContentVersions';
import getNpaNxxList from '@salesforce/apex/PmEnrichmentController.getNpaNxxList';
import downloadCustomtimeperiodMLHG from '@salesforce/apex/FetchDataMLHG.downloadCustomtimeperiodMLHG';

export default class SendTaskEmail extends LightningElement {
    @api sendToEmails = '';
    @api recordId;

  xlsHeader = [];
  workSheetNameList=[];
  xlsData = [];
  PremisesData = []; // used only for storing premeses table
  DIDNumberInfoTable = []; // used only for storing DIDNumberInfo table
  getEmployeeInfoTable = [];
  getTtrDIDNumberDetailsMLHGDataTable = [];
  ftrDIDNumberDetailsGeneralVoicemailTable =[];
  queryschedulesTable=[];
  downloadHolidaysByScheduleTable=[];
  downloadHolidaysByAAScheduleTable=[];
  ftrDIDNumberDetailsAutoAttendantsSetupTable=[];
  ScheduleforAutoAttendantSetUpTable =[];
  menusforAutoAttendantsTable=[];
  Notifications911CustomizationNotesTable=[];
  greetingsforAutoAttendantsGreetingsTable=[];
  loadComponentTable=[];
  loadComponentCustomizationNotesTable=[];
    handleInputChange = (event)=>{
         event.preventDefault();
         this.sendToEmails = event.target.value;
    }

    renderedCallback() {
    console.log("renderedCallback xlsx");
    if (this.librariesLoaded) return;
    this.librariesLoaded = true;
    Promise.all([loadScript(this, workbook + "/xlsx/xlsx.full.min.js")])
    .then(() => {
      console.log("success");
    })
    .catch(error => {
      console.log("failure");
    });
  }
  // connectedCallback --- Inside connectedCallBack all other methods are available
    connectedCallback() {
        this.ShowLoader=true;
        //this.fetchServiceLocations();
        this.getPremisesRecord();
        this.getDIDNumberRecord();
        this.getEmployeeInfoRecord();
        this.getMLHGSetupRecord();
        this.getGeneralVoiceMailRecord();
        this.getMLHGScheduleInfomation();
        this.getMLHGHolidayInformation();
        this.getAutoAttendantSetupInformation();
        this.getAutoAttendantMenuInformation();
        this.getAutoAttendantScheduleInfomation();
        this.getAutoAttendantGreetingRecords();
        this.getAutoAttendantHolidayInformation();
        this.getPageGroupInformation();
        this.getCustomizationNotesInformation();
        this.getMLHGSelectedMembersData();
        this.getPageGourpMembersDataToDownload();
        this.getNotifications911CustomizationNotes();
        //this.getOrderStage();
        this.getdownloadCustomtimeperiodAA();
        this.getNpaNxxList();
        this.getdownloadCustomTimePeriodMLHG();
    
    }  

    getNpaNxxList(){
        getNpaNxxList({}).then(result=>{
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

        }).catch(error=>{
            console.log('NpaNxxHeader', error);

        })
    }

getdownloadCustomTimePeriodMLHG(){
    downloadCustomtimeperiodMLHG({OrderId: this.recordId})
    .then(result=>{
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
        this.sendEmailDownload();
    }).catch(error => {
        console.log(' MLHG Custom Timeperiod Info', error);
    })

}

getdownloadCustomtimeperiodAA(){
    downloadCustomtimeperiodAA({OrderId: this.recordId})
    .then(result=>{
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
        
    }).catch(error => {
        console.log(' AA Custom Timeperiod Info', error);
    })
}
getMLHGSelectedMembersData(){
    ftrSelectedMembers({recordId: this.recordId})
    .then(result=>{
        console.log("ftrSelectedMembers Members Data", JSON.stringify(result));
        this.SelectedMemberHeader = ["Id", "Name", "MLHG Members" ];
        let resultNEw=[];
        if (result.length > 0) {
            result.forEach(ele=>{
                let newObj={};
                newObj.Id = ele.Id;
                newObj.mlgName = ele?.Parent_DID_Number_Detail__r.MLHG_Name__c ?? '';
                newObj.Name = ele?.Name ?? '';
                //newObj.DID_Number_Details__c = ele?.DID_Number_Details__c ?? '';
                //newObj.DID_Number_DetailName = ele?.DID_Number_Details__r?.Name ?? '';
                resultNEw.push(newObj);
            })
            this.xlsFormatter(resultNEw, "MLHG Members",this.SelectedMemberHeader);
        }
        
    }).catch(error => {
        console.log(' ftrSelectedMembers error', error);
    })
}
getPageGourpMembersDataToDownload(){
    DownloadPMPageGroupMembers({OrderId: this.recordId})
    .then(result=>{
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
        
        
    }).catch(error => {
        console.log(' Page Gourp memebers error', error);
    })
}

    // gerPermisesRecord --- apex method getPremises2
    getPremisesRecord(){
        getPremises2({recordId: this.recordId})
        .then(result => {
            console.log('OUTPUT this.recordId : ',this.recordId);
                console.log('OUTPUT isTranslationUserValue : ',this.isTranslation);
                this.PremisesHeader = ["Id","LOCATION NAME", "LOCATION ADDRESS", "MAIN PHONE #", "SHIPPING LOCATION", "TIME ZONE", "NEW CONSTRUCTION", "CONTACT NAME", "CONTACT EMAIL", "CONTACT PHONE", "CALLER ID NAME","CUSTOM MUSIC", "SHIPPING ADDRESS",  "CONSTRUCTION DETAILS"];
                //if(this.isTranslation){
                    this.PremisesHeader.push('BUSINESS GROUP NAME','EAS PIN');
                //}
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
                        //if(this.isTranslation){
                            newObj.Business_Group_Name__c=ele?.Business_Group_Name__c?? '';
                            newObj.EAS_Pin__c=ele?.EAS_Pin__c ?? '';
                        //}
                        resultNEw.push(newObj);
                    })
                    this.PremisesData = [...this.PremisesData, ...resultNEw];
                    this.xlsFormatter(resultNEw, "Service Location",this.PremisesHeader);
                    //this.BusinessGroupName=result[0].Business_Group_Name__c || '';
                    //this.EAS_Pin=result[0].EAS_Pin__c || '';
                }
        })
        .catch(error => {
            console.error(error);
        });
    }

    // getDIDNumberRecord --- apex method getDIDNumberInfo
    getDIDNumberRecord(){
        getDIDNumberInfo({orderId: this.recordId})
        .then(result => {
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
        })
        .catch(error => {
        console.error(error);
        });
    }

    // getEmployeeInfoRecord --- apex method getEmployeeInfo
    getEmployeeInfoRecord(){
        getEmployeeInfo({recordId: this.recordId})
        .then(result => {
            console.log('OUTPUT getEmployeeInfoTable data :::Osama ',JSON.stringify(result));
                // this.getEmployeeInfoHeader = Object.keys(result[0]);
                this.getEmployeeInfoHeader = ["Id","Phone Number","Extension","User Name","Company Name","Address Number","Street Name","City","State","Zip Code","Identifying Location","Department","User Admin","Email","Outbound Caller ID","Other Outbound Caller ID","License Type","Device Type","Device Accessories","Dial Plan Information","Colaboration","Webinar","Call Recording","Audio Mining","Screen Recording","Storage"];
                //if(this.isTranslation){
                    this.getEmployeeInfoHeader.push("EAS Pin","MAC Address");
                //}
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
                        //if(this.isTranslation){
                            newObj.EAS_Pin__c=ele?.EAS_Pin__c ?? '';
                            newObj.Ucf_MAC_Address__c=ele?.Ucf_MAC_Address__c ?? '';
                           // }
                        resultNew.push(newObj);
                    })
                    console.log('OUTPUT : resultNew employeeInfo',resultNew);
                    this.getEmployeeInfoTable = [...this.getEmployeeInfoTable, ...resultNew];
                    this.xlsFormatter(resultNew, "EmployeeInfo Information",this.getEmployeeInfoHeader);
                }
        })
        .catch(error => { 
            console.error(error);
        });
    }

    // getMLHGSetupRecord --- apex method getTtrDIDNumberDetailsMLHGData
    getMLHGSetupRecord(){
        getTtrDIDNumberDetailsMLHGData({recordId: this.recordId})
    .then(result => {
        console.log('MLHG Information',JSON.stringify(result));
        //this.getTtrDIDNumberDetailsMLHGDataHeader = Object.keys(result.availableDIDNumberList[0]);
        this.getTtrDIDNumberDetailsMLHGDataHeader = ["Id","Phone Number","Extension", "MLHG Name","Ring Pattern","Schedule","Members"];
        //if(this.isTranslation){
            this.getTtrDIDNumberDetailsMLHGDataHeader.push("EAS Pin");
        //}
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
                //if(this.isTranslation){
                    newObj.EAS_Pin__c=ele?.EAS_Pin__c ?? '';   
                //}
                resultNEw.push(newObj);
            })
            this.getTtrDIDNumberDetailsMLHGDataTable = [...this.getTtrDIDNumberDetailsMLHGDataTable,...resultNEw];
            this.xlsFormatter(resultNEw, "MLHG Setup Information",this.getTtrDIDNumberDetailsMLHGDataHeader);
        }
    })
        .catch(error => { 
            console.error(error);
        }); 
    }

    // getGeneralVoiceMailRecord --- apex method ftrDIDNumberDetailsGeneralVoicemail
    getGeneralVoiceMailRecord(){
        ftrDIDNumberDetailsGeneralVoicemail({recordId: this.recordId})
        .then(result => {
            console.log('OUTPUT ftrDIDNumberDetailsGeneralVoicemail data :::Osama3 ',JSON.stringify(result));
                if (result.length>0) {
                    //this.ftrDIDNumberDetailsGeneralVoicemailHeader = Object.keys(result[0]);
                    this.ftrDIDNumberDetailsGeneralVoicemailHeader = ["Id","Phone Number","Extension","Name","Email"];
                    //if(this.isTranslation){
                        this.ftrDIDNumberDetailsGeneralVoicemailHeader.push("EAS Pin");
                    //}
                    let resultNEw=[];
                    result.forEach(ele=>{
                        let newObj={};
                        newObj.Id=ele.Id;
                        newObj.DIDNumber__c=ele?.DIDNumber__c ?? '';
                        newObj.Ucf_Extension__c=ele?.Ucf_Extension__c ?? '';
                        newObj.Ucf_General_Voice_Mail_Name__c=ele?.Ucf_General_Voice_Mail_Name__c ?? '';
                        newObj.Ucf_Email__c = ele?.Ucf_Email__c ?? '';
                        //if(this.isTranslation){
                            newObj.EAS_Pin__c=ele?.EAS_Pin__c ?? '';   
                        //}
                        resultNEw.push(newObj);
                    })
                    this.ftrDIDNumberDetailsGeneralVoicemailTable = [...this.ftrDIDNumberDetailsGeneralVoicemailTable, ...result];
                    this.xlsFormatter(resultNEw, "General Voice Mail Information",this.ftrDIDNumberDetailsGeneralVoicemailHeader);
                }
    })
    .catch(error => { 
            console.error(error);
    });
    }

    // getMLHGScheduleInfomation --- apex method queryschedules
    getMLHGScheduleInfomation(){
        queryschedules({orderId: this.recordId})
        .then(result => {
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
        })
        .catch(error => { 
            console.error(error);
        });
    }

    // getMLHGHolidayInformation --- apex method downloadHolidaysBySchedule
    getMLHGHolidayInformation(){
        downloadHolidaysBySchedule({OrderId: this.recordId})
        .then(result => {
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
        })
        .catch(error => { 
            console.error(error);
        });
    }

    // getAutoAttendantSetupInformation --- apex method ftrDIDNumberDetailsAutoAttendantsSetup
    getAutoAttendantSetupInformation(){
        ftrDIDNumberDetailsAutoAttendantsSetup({orderId: this.recordId})
        .then(result => {
            console.log('OUTPUT ftrDIDNumberDetailsAutoAttendants data :::Osama6 ',JSON.stringify(result));
                console.log('OUTPUT recordId :::Osama6 ',this.recordId);
                this.ftrDIDNumberDetailsAutoAttendantsSetupHeader =["Id","Phone Number","Extension","Name","Schedule"];
                //if(this.isTranslation){
                    this.ftrDIDNumberDetailsAutoAttendantsSetupHeader.push("EAS Pin");
                //}
                let resultNEw=[];
                if (result.length>0) {
                    result.forEach(ele=>{
                    let newObj={};
                    newObj.Id=ele.Id;
                    newObj.DIDNumber__c=ele?.DIDNumber__c ?? '';
                    newObj.Ucf_Extension__c=ele?.Ucf_Extension__c ?? '';
                    newObj.ucf_Auto_Attendent_Name__c =ele?.ucf_Auto_Attendent_Name__c ?? '';
                    newObj.Schedule__c =ele?.Schedule__r?.UCF_Name__c ?? '';
                    //if(this.isTranslation){
                        newObj.EAS_Pin__c=ele?.EAS_Pin__c ?? '';   
                    //}
                    resultNEw.push(newObj);
                    })
                    //this.ftrDIDNumberDetailsAutoAttendantsSetupHeader = Object.keys(result[0]);
                    this.ftrDIDNumberDetailsAutoAttendantsSetupTable = [...this.ftrDIDNumberDetailsAutoAttendantsSetupTable, ...result];
                    this.xlsFormatter(resultNEw, "AA Setup Information",this.ftrDIDNumberDetailsAutoAttendantsSetupHeader);
                }         
        })
        .catch(error => { 
            console.error(error);
        });
    }

    

    // getAutoAttendantMenuInformation --- apex method ScheduleforAutoAttendantSetUp
    getAutoAttendantMenuInformation(){
        ScheduleforAutoAttendantSetUp({OrderId: this.recordId})
        .then(result => {
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
        })
        .catch(error => { 
            console.error(error);
        });
    }

    // getAutoAttendantScheduleInfomation --- apex method menusforAutoAttendants
    getAutoAttendantScheduleInfomation(){
        menusforAutoAttendants({orderId: this.recordId})
        .then(result => {
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
        })
        .catch(error => { 
            console.error(error);
        });
    }

    // getAutoAttendantGreetingRecords --- apex method greetingsforAutoAttendantsGreetings
    getAutoAttendantGreetingRecords(){
        greetingsforAutoAttendantsGreetings({orderId: this.recordId})
        .then(result => {
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
        })
        .catch(error => { 
            console.error(error);
        });
    }

    // getAutoAttendantHolidayInformation -- apex method downloadHolidaysByAASchedule
    getAutoAttendantHolidayInformation(){
        downloadHolidaysByAASchedule({OrderId: this.recordId})
        .then(result => {
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
        })
        .catch(error => { 
            console.error(error);
        });  
    }

    // getPageGroupInformation -- apex method loadComponent
    getPageGroupInformation(){
        loadComponent({orderId: this.recordId})
        .then(result => {
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
        })
        .catch(error => { 
            console.error(error);
        });
    }

    // getCustomizationNotesInformation -- apex method loadComponentCustomizationNotes
    getCustomizationNotesInformation(){
        loadComponentCustomizationNotes({recordId: this.recordId})
        .then(result => {
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
        })
        .catch(error => { 
            console.error(error);
        });
    }

     getNotifications911CustomizationNotes(){
         Notifications911CustomizationNotes({recordId: this.recordId})
            .then(result => {
                console.log('OUTPUT Notifications911CustomizationNotes data  ',JSON.stringify(result));
                console.log('Notifications911CustomizationNotes',JSON.stringify(result.NotificationList));
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
            })
            .catch(error => { 
                console.error(error);
            });
        
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

  sendEmailDownload() {
    const XLSX = window.XLSX;
    const xlsData = this.xlsData;
    const xlsHeader = this.xlsHeader;
    const ws_name = this.workSheetNameList;

    const createXLSLFormatObj = Array(xlsData.length).fill([]);

    /* Form header list */
    xlsHeader.forEach((item, index) => (createXLSLFormatObj[index] = [item]));

    /* Form data key list */
    xlsData.forEach((item, selectedRowIndex) => {
        const xlsRowKey = Object.keys(item[0]);
        item.forEach((value, index) => {
            const innerRowData = [];
            xlsRowKey.forEach(item => {
                innerRowData.push(value[item]);
            });
            createXLSLFormatObj[selectedRowIndex].push(innerRowData);
        });
    });

    /* Creating new Excel */
    const wb = XLSX.utils.book_new();

    /* Creating new worksheet */
    const ws = Array(createXLSLFormatObj.length).fill([]);
    for (let i = 0; i < ws.length; i++) {
        /* Converting data to excel format and pushing to worksheet */
        const data = XLSX.utils.aoa_to_sheet(createXLSLFormatObj[i]);
        ws[i] = [...ws[i], data];
        /* Add worksheet to Excel */
        XLSX.utils.book_append_sheet(wb, ws[i][0], ws_name[i]);
    }

    /* Write Excel */
    const excelBuffer = XLSX.write(wb, { bookType: 'xlsx', type: 'array' });
    const blob = new Blob([new Uint8Array(excelBuffer)], { type: 'application/octet-stream' });

    /* Read the blob as data URL */
    const reader = new FileReader();
    reader.onloadend = async () => {
        if (reader.error) {
            console.error('Error reading file:', reader.error);
            return;
        }

        const base64String = reader.result.split(',')[1]; // Extracting base64 string

        try {
            /* Initiate the server API call in parallel */
            const apiCallPromise = storeContentVersions({ orderId: this.recordId, b64: base64String });
            /* Other operations can continue here */

            /* Wait for the server API call to complete */
            const res = await apiCallPromise;
            console.log(JSON.stringify(res));
        } catch (error) {
            console.error(JSON.stringify(error));
        }
    };

    /* Read the blob as data URL */
    reader.readAsDataURL(blob);
}
}