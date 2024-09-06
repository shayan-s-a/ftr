import { LightningElement, track, wire,api } from 'lwc';
//import queryAccounts from '@salesforce/apex/FetchData.queryAccounts';
import deleteSchedule from '@salesforce/apex/ucf_PMErichment_MLHG_Schedule.deleteSchedule';
import queryschedules from '@salesforce/apex/FetchDataMLHG.queryschedules';
import queryAccounts2 from '@salesforce/apex/FetchData.queryAccounts2';
import getMultiPicklistValues from '@salesforce/apex/FetchData.getMultiPicklistValues';
//import insertSchedule from '@salesforce/apex/FetchData.insertSchedule';
import insertSchedule from '@salesforce/apex/ucf_PMErichment_MLHG_Schedule.insertSchedule';
import insertHolidayName from '@salesforce/apex/ucf_PMErichment_MLHG_Schedule.insertHolidayName';
import ftrDIDNumberDetails from '@salesforce/apex/FetchData.ftrDIDNumberDetails';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import getTtrDIDNumberDetailsMLHGData from '@salesforce/apex/FetchDataMLHG.ftrDIDNumberDetailsMLHG';
import updateRecords from '@salesforce/apex/FetchDataMLHG.updateRecords';
import GetDidNumbers from '@salesforce/apex/FetchDataMLHG.GetDidNumbers';
import validateRingOneAtaTime from '@salesforce/apex/FetchDataMLHG.validateRingOneAtaTime';

import ScheduleforMLHGSetUp from '@salesforce/apex/FetchDataMLHG.ScheduleforMLHGSetUp';
import saveTimePeriodRecords from '@salesforce/apex/FetchDataMLHG.saveTimePeriodRecords';
import addHoliDays from '@salesforce/apex/FetchDataMLHG.addHoliDays';

import updateSchedule from '@salesforce/apex/FetchDataMLHG.updateSchedule';
import updateftrDIDNumberDetailsEmployeeTab from '@salesforce/apex/FetchData.updateftrDIDNumberDetailsEmployeeTab';
import isTranslationUser from '@salesforce/apex/PmEnrichmentController.isTranslationUser';
import getHolidaysBySchedule from '@salesforce/apex/FetchDataMLHG.getHolidaysBySchedule';
import updateHolidays from '@salesforce/apex/FetchDataMLHG.updateHolidays';


import getSavedTimePeriods from '@salesforce/apex/UcfAutoAttendentController.getSavedTimePeriods';
import saveTimePeriodsNew from '@salesforce/apex/UcfAutoAttendentController.saveTimePeriodsNew';
import deleteHolidayById from '@salesforce/apex/UcfAutoAttendentController.deleteHolidayById';
import getCurrentOrderStage from  '@salesforce/apex/PmEnrichmentController.getOrderStage';





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
export default class MultiLineHuntingGroupLWC extends LightningElement {
    @track isHandle = false;
    showLoaderModal = false;
    tempDIDIds = [];
    GetDidNumbers=[];
    isEditModeMLHGSetup = false;
    isRingOne = false;
    rowIndex;
    @track sortOrder = 1;
    RecdTypeId='Multi-Line Hunting Groups';
    response;
    @api recordId;
    delscheduleId;
    scheduleId;
    schedules;
    accounts2;
    error; 
    @track showTable = false;
    //holiday
    @track holidaysGet;
    @track hasPastDateError = false;
    @track newHolidayName = '';
      //holiday //
    @track length2 = 0;
    value = '';
    schedule =[];
    members=[];
    membername = '';
    @track monday = 'Monday';
    @track tuesday = 'Tuesday';
    @track wednesday = 'Wednesday';
    @track thursday = 'Thursday';
    @track friday = 'Friday';
    @track saturday = 'Saturday';
    @track sunday = 'Sunday';
    @track mondayStartTime = '';
    @track mondayEndTime = '';
    @track tuesdayStartTime = '';
    @track tuesdayEndTime = '';
    @track wednesdayStartTime = '';
    @track wednesdayEndTime = '';
    @track thursdayStartTime = '';
    @track thursdayEndTime = '';
    @track fridayStartTime = '';
    @track fridayEndTime = '';
    @track saturdayStartTime = '';
    @track saturdayEndTime = '';
    @track sundayStartTime = '';
    @track sundayEndTime = '';
    @track customTimePeriodName1 = '';
    @track customTimePeriodName2 = '';
    @track customTimePeriod1OFT;
    @track customTimePeriod2OFT;
    @track customTimePeriod1OFD;
    @track customTimePeriod2OFD;
    @track schedulesCustomTime = [];
    @track tempNumber=0;

    selectedAccount = null; 
    ftrDIDNumberDetailsMLHG;
    ftrDIDNumberDetailsMLHG2;
    @track draftValues = [];
    @track showDualListboxModal = false;
    @track selectedItems = [];
    @track selectedItemsCount = 0;
    @track length = 0;
    @track selectedOption = '';
    @track employeeinfo = '';  
    @track deviceinfo = '';
    @track nine11info = '';
    @track licenseinfo = '';
    @track accountList = [];
    @track picklistOptions = [];
    @track selectedValues = [];
    @track scheduleName = '';
   
    @track isEditMode = false;
    @track is247Expanded = false;
    @track isHolidayExpanded = false;
     @track isOpenExpanded = false;
      @track btnAdd1 = true;
      @track btnAdd2 = false;
       @track showCustomSch1 = false;
       @track showCustomSch2 = false;
      @track isClosedExpanded = false;
      @track selectedValueSchedule = '';
        @track selectedTime = '';
        @track  isSch1 = false;
         @track  isSch2 = false;
          @track overflowT24 ='';
          @track overflowD24 ='';
          @track overflowTOpen ='';
          @track overflowDOpen ='';
          @track overflowTClose ='';
          @track overflowDClose ='';
          @track modifiedTimePeriods = []
           @track modifiedTimePeriodsC2 = []
          originalTimePeriods = [];
           originalTimePeriodsC2 = [];
            @track holidays = [];
             @track holidays = [{ name: '', date: '' }];
             @track isTranslation;
             @track isReadOnly;
          MLHGName='';
          RecordIds='';
    @track schId = '';
    @track holidayName = '';
    @track timePeriodData = [];
    @track holidayDate ;
    isModalOpen = false;
    isModalOpenMLHGSetup = false;
    @track sortField = 'DIDNumber__c'; // Default sort field
    @track sortDirection = 'asc'; // Default sort direction
    wiredResult;
    _wiredMarketData;
    N11;
    showLoader = false;
    fieldChangeCount=0;
    @api isnetworktranslation=false;
    @track dualListboxOptions = [
        { label: 'Option 1', value: 'Option1' },
        { label: 'Option 2', value: 'Option2' },
    ];
    @track ftrDIDNumberDetails = [];
    @track timeOptions = this.createTimeOptions();
    @track isOrderInProgressOrCompleted = false;
    createTimeOptions() {
        const times = [
        '0:00','0:15', '0:30', '0:45',
        '1:00', '1:15', '1:30', '1:45',
        '2:00', '2:15', '2:30', '2:45',
        '3:00', '3:15', '3:30', '3:45',
        '4:00', '4:15', '4:30', '4:45',
        '5:00', '5:15', '5:30', '5:45',
        '6:00', '6:15', '6:30', '6:45',
        '7:00', '7:15', '7:30', '7:45',
        '8:00', '8:15', '8:30', '8:45',
        '9:00', '9:15', '9:30', '9:45',
        '10:00', '10:15', '10:30', '10:45',
        '11:00', '11:15', '11:30', '11:45',
        '12:00', '12:15', '12:30', '12:45',
        '13:00', '13:15', '13:30', '13:45',
        '14:00', '14:15', '14:30', '14:45',
        '15:00', '15:15', '15:30', '15:45',
        '16:00', '16:15', '16:30', '16:45',
        '17:00', '17:15', '17:30', '17:45',
        '18:00', '18:15', '18:30', '18:45',
        '19:00', '19:15', '19:30', '19:45',
        '20:00', '20:15', '20:30', '20:45',
        '21:00', '21:15', '21:30', '21:45',
        '22:00', '22:15', '22:30', '22:45',
        '23:00', '23:15', '23:30', '23:45','24:00'
    ];
        return times.map(time => ({ label: time, value: time }));
    }

     ringPatternOptions = [
        { label: 'Ring all', value: 'Ring all' },
        { label: 'Ring One at a Time', value: 'Ring One at a Time' },
        { label: 'Round Robin', value: 'Round Robin' },
        { label: 'Longest Idle', value: 'Longest Idle' }
    ];

 @track timeOptionsOpen = this.generateTimeOptionsOpen();
 

 @track weekDays = [
        { label: 'Monday', startFieldName: 'monStart', endFieldName: 'monEnd', startTime: '', endTime: '' },
        { label: 'Tuesday', startFieldName: 'tueStart', endFieldName: 'tueEnd', startTime: '', endTime: '' },
         { label: 'Wednesday', startFieldName: 'wedStart', endFieldName: 'wedEnd', startTime: '', endTime: '' },
          { label: 'Thursday', startFieldName: 'thuStart', endFieldName: 'thuEnd', startTime: '', endTime: '' },
           { label: 'Friday', startFieldName: 'friStart', endFieldName: 'friEnd', startTime: '', endTime: '' },
            { label: 'Saturday', startFieldName: 'satStart', endFieldName: 'satEnd', startTime: '', endTime: '' },
             { label: 'Sunday', startFieldName: 'sunStart', endFieldName: 'sunEnd', startTime: '', endTime: '' }
    ];
    
     @track weekDaysC2 = [
        { label: 'Monday', startFieldName: 'monStart', endFieldName: 'monEnd', startTime: '', endTime: '' },
        { label: 'Tuesday', startFieldName: 'tueStart', endFieldName: 'tueEnd', startTime: '', endTime: '' },
         { label: 'Wednesday', startFieldName: 'wedStart', endFieldName: 'wedEnd', startTime: '', endTime: '' },
          { label: 'Thursday', startFieldName: 'thuStart', endFieldName: 'thuEnd', startTime: '', endTime: '' },
           { label: 'Friday', startFieldName: 'friStart', endFieldName: 'friEnd', startTime: '', endTime: '' },
            { label: 'Saturday', startFieldName: 'satStart', endFieldName: 'satEnd', startTime: '', endTime: '' },
             { label: 'Sunday', startFieldName: 'sunStart', endFieldName: 'sunEnd', startTime: '', endTime: '' }
    ];

     columns = [
        { label: 'Date', fieldName: 'Date__c', type: 'date' },
        { label: 'Name', fieldName: 'Name', type: 'text' }
    ];

 @track timeOptionsData = this.generateTimeOptions();
    @track value = '';

    // Options for the select list
   @track timeOptionsDatas = [
        '0:00', '0:15', '0:30', '0:45',
        '1:00', '1:15', '1:30', '1:45',
        '2:00', '2:15', '2:30', '2:45',
        '3:00', '3:15', '3:30', '3:45',
        '4:00', '4:15', '4:30', '4:45',
        '5:00', '5:15', '5:30', '5:45',
        '6:00', '6:15', '6:30', '6:45',
        '7:00', '7:15', '7:30', '7:45',
        '8:00', '8:15', '8:30', '8:45',
        '9:00', '9:15', '9:30', '9:45',
        '10:00', '10:15', '10:30', '10:45',
        '11:00', '11:15', '11:30', '11:45',
        '12:00', '12:15', '12:30', '12:45',
        '13:00', '13:15', '13:30', '13:45',
        '14:00', '14:15', '14:30', '14:45',
        '15:00', '15:15', '15:30', '15:45',
        '16:00', '16:15', '16:30', '16:45',
        '17:00', '17:15', '17:30', '17:45',
        '18:00', '18:15', '18:30', '18:45',
        '19:00', '19:15', '19:30', '19:45',
        '20:00', '20:15', '20:30', '20:45',
        '21:00', '21:15', '21:30', '21:45',
        '22:00', '22:15', '22:30', '22:45',
        '23:00', '23:15', '23:30', '23:45','24:00'
    ];

//    @api recordId;
selectedTab = 'tab1'; // Default selected tab

    get isTab1Selected() {
        return this.selectedTab === 'tab1';
    }
    get isTab2Selected() {
        return this.selectedTab === 'tab2';
    }

    get tab1Class() {
        return this.isTab1Selected ? 'slds-button slds-button_neutral slds-is-active' : 'slds-button slds-button_neutral';
    }

    get tab2Class() {
        return this.isTab2Selected ? 'slds-button slds-button_neutral slds-is-active' : 'slds-button slds-button_neutral';
    }
  

    handleSelectTab(event) {
        
        this.selectedTab = event.currentTarget.dataset.name;
        this.fetchSchedules();
        this.fetchScheduleForMLHGSetUp();
        this.getTtrDIDNumberDetailsMLHGData();
        
    }

    
    generateTimeOptions() {
        return Array.from({ length: 96 }, (_, index) => {
            const hour = Math.floor(index / 4).toString().padStart(2, '0');
            const minute = (index % 4) * 15;
            const timeLabel = `${hour}:${minute.toString().padStart(2, '0')}`;
            return { label: timeLabel, value: timeLabel };
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
       generateTimeOptionsOpen() {
        return Array.from({ length: 96 }, (_, index) => {
            const hour = Math.floor(index / 4).toString().padStart(2, '0');
            const minute = (index % 4) * 15;
            const timeLabel = `${hour}:${minute.toString().padStart(2, '0')}`;
            return { label: timeLabel, value: timeLabel };
        });
    }
    
    connectedCallback() {
        this.showLoader=true;
        this.fetchSchedules();
        
        this.getTtrDIDNumberDetailsMLHGData();
        this.getOrderStage();
        
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

    fetchScheduleForMLHGSetUp() {
    // Make sure to have your orderId and RecordTypeId available
    const orderId = this.recordId;
    const RecordTypeId = this.RecdTypeId;

    ScheduleforMLHGSetUp({ orderId: orderId, RecordTypeId: RecordTypeId })
        .then(result => {
            // Process your result here
            this.schedule = result.map(option => ({ label: option.UCF_Name__c, value: option.Id }));
            console.log('Mapped Schedule:', this.schedule);
        })
        .catch(error => {
            // Handle your error here
            console.error('Error from Apex:', error);
            this.error = error;
        });
}

    @wire(getMultiPicklistValues, { YourObjectName: 'Account', YourFieldName: 'vlocity_cmt__ContactPreferences__c' })
    wiredMultiPicklistValues({ error, data }) {
        if (data) {
            console.log('data', data);
           this.picklistOptions = data.map(option => ({ label: option, value: option }));
           //this.picklistOptions = data;
            console.log('picklistOptions', this.picklistOptions);
        } else if (error) {
            console.error(error);
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
    deleteItem(event) {
       
        //console.log('Delete button clicked');
        //const abc = event.currentTarget.dataset;
      
        //const itemId = event.currentTarget.dataset.itemId;
        const itemIndex = event.currentTarget.dataset.itemIndex;
        
        //console.log('Item ID:', itemId);
        //console.log('Index:', itemIndex);
        this.delscheduleId=event.currentTarget.dataset.itemId;
        deleteSchedule({ scheduleId: this.delscheduleId})
            .then(result => {
                this.showToast('Deleted', result, 'success');
                console.log('Delete  function');
              return refreshApex(this._wiredMarketData);
            })
            .catch(error => {
                const errorMessage = error.body && error.body.message ? error.body.message : 'An error occurred';
                this.showToast('Error', errorMessage, 'error');
            });
        
        const updatedAccounts = [...this.schedules];
       
        if (itemIndex !== undefined) {
            updatedAccounts.splice(itemIndex, 1); 
            this.schedules = updatedAccounts; 
        }
        

    }


    
    toggleEditMode(event) {
        this.schId = event.currentTarget.dataset.itemId;
        
        if(this.schId)
        {
            this.loadHolidays();
            this.loadSchedules();
        }
        
         const schedule = this.schedules.find(schedule => schedule.Id === this.schId);
         //alert(JSON.stringify(schedule));
        if (schedule) {
            // Toggle edit mode and populate the fields for editing
            this.isModalOpen = true;
            this.isEditMode = true;
            this.overflowT24 = schedule.Overflow_Timer_24_7__c;
            this.overflowD24 = schedule.Overflow_Destination_24_7__c;
            this.overflowTOpen = schedule.Overflow_Timer_Open__c;
            this.overflowDOpen = schedule.Overflow_Destination_Open__c;
            this.overflowTClose = schedule.Overflow_Timer_Closed__c;
            this.overflowDClose = schedule.Overflow_Destination_Closed__c;
            this.holidayName = schedule.Holiday__c;
            this.holidayDate = schedule.Holiday_Date__c;
            this.mondayStartTime = schedule.Monday_Start_Time__c;
            this.mondayEndTime =schedule.Monday_End_Time__c;
            this.tuesdayStartTime =schedule.Tuesday_Start_Time__c;
            this.tuesdayEndTime =schedule.Tuesday_End_Time__c;
            this.wednesdayStartTime =schedule.Wednesday_Start_Time__c;
            this.wednesdayEndTime = schedule.Wednesday_End_Time__c;
            this.thursdayStartTime = schedule.Thursday_Start_Time__c;
            this.thursdayEndTime =schedule.Thursday_End_Time__c;
            this.fridayStartTime = schedule.Friday_Start_Time__c;
            this.fridayEndTime = schedule.Friday_End_Time__c;
            this.saturdayStartTime = schedule.Saturday_Start_Time__c;
            this.saturdayEndTime = schedule.Saturday_End_Time__c;
            this.sundayStartTime =schedule.Sunday_Start_Time__c ;
            this.sundayEndTime = schedule.Sunday_End_Time__c;


        } else {
            // Handle the case where the schedule is not found
            console.error('Schedule not found');
        }
        this.isModalOpen = true;
        this.isEditMode = !this.isEditMode;
      
    }
    
    toggleSection(event) {
        const section = event.currentTarget.dataset.id;

        if (section === '24/7') {
            this.is247Expanded = !this.is247Expanded;
        } else if (section === 'Holiday') {
            this.isHolidayExpanded = !this.isHolidayExpanded;
        }
         else if (section === 'Open') {
            this.isOpenExpanded = !this.isOpenExpanded;
        }
         else if (section === 'Closed') {
            this.isClosedExpanded = !this.isClosedExpanded;
        }
    }

    handleTimeChangeCustom(event)
    {
            const dayOfWeek = event.target.dataset.day;
    const field = event.target.name;
    const value = event.target.value;

    let period = this.timePeriodData.find(period => period.Day__c === dayOfWeek);

    if (!period) {
        period = {
            Day__c: dayOfWeek,
            Overflow_Destination__c: '', // Set default or fetch from UI
            Overflow_Timer__c: '', // Set default or fetch from UI
            Schedule__c: '', // Set default or fetch from UI
            Start__c: '',
            Stop__c: ''
        };
        this.timePeriodData.push(period);
    }

    // Update the period object with the new value
    period[field] = value;
    }

  addScheduleRow() {
        console.log(this.RecdTypeId);
        if (!this.scheduleName) {
            this.showToast('Error', 'Schedule name cannot be empty', 'error');
            return;
        }
          const getSch = this.scheduleName.trim().toLowerCase(); // Convert input to lower case
    if (this.schedules.some(schd => schd.UCF_Name__c.toLowerCase() === getSch)) {
        this.showToast('Error','This Schedule name already exists.','error');
        return;
    }
       
        console.log(this.RecdTypeId);
        insertSchedule({ scheduleName: this.scheduleName, orderId: this.recordId,RecordTypeId : this.RecdTypeId })
            .then(result => {
                //console.log("Schedule created"+result);
                if(result==='Schedule Created Succesfully'){
                    this.showToast('Success', result, 'success');
                      this.fetchSchedules();

                }
                else{
                    this.showToast('Error', result, 'Error'); 
                }
                 this.scheduleName = '';

                // Refresh the table
              return refreshApex(this._wiredMarketData);
            })
            .catch(error => {
                const errorMessage = error.body && error.body.message ? error.body.message : 'An error occurred';
                this.showToast('Error', errorMessage, 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }



     handleScheduleNameChange(event) {
        console.log('handleScheduleNameChange',);
        const recordId = event.target.dataset.recordId;
        this.scheduleName = event.target.value;
        const fieldName = event.target.dataset.fieldName;
        const newValue = event.target.value;
        if (fieldName === 'Ucf_Name__c') {
            this.fieldChangeCount++;
            console.log('this.fieldChangeCount ',this.fieldChangeCount);
            this.notifyInputChange(this.fieldChangeCount);
            // Check for duplicate MLHG_Name__c entry
            if(event.target.value !== '')
            {
            const isDuplicate = this.ftrDIDNumberDetailsMLHG.some(detail => 
                detail.Ucf_Name__c === newValue && detail.Id !== recordId
            );
        
              if (isDuplicate) {
                // Alert the user that the webinar value is already selected
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Duplicate Name',
                    message: 'Please enter an unique name',
                    variant: 'error'
                })
            );
            return;
            }
        }
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
            { label: '3 digits', value: '3 digits' },
            { label: '4 digits', value: '4 digits' },
            { label: '5 digits', value: '5 digits' },
            { label: '7 digits', value: '7 digits' },
        ];
    }
    value = 'Employee Info';
    get options3() {
        return [
            { label: 'Employee Info', value: 'Employee Info' },
            { label: 'License Info', value: 'License Info' },
            { label: 'Device Info', value: 'Device Info' },
            { label: '911 Info', value: '911 Info' },
        ];
    }

    handleComboboxChange(event) {
        this.selectedOption = event.detail.value;
        if (this.selectedOption === 'Employee Info') {
            this.employeeinfo = this.selectedOption;
            this.nine11info= false;
            this.deviceinfo = false;
            this.licenseinfo = false;
        }
        else if (this.selectedOption === 'Device Info') {
            this.deviceinfo = this.selectedOption;
            this.employeeinfo = false;
            this.nine11info= false;
            this.licenseinfo = false;
        }
        else if (this.selectedOption === 'License Info') {
            this.licenseinfo = this.selectedOption;
            this.deviceinfo = false;
            this.employeeinfo = false;
            this.nine11info= false;
        }
        else if (this.selectedOption === '911 Info') {
            this.nine11info = this.selectedOption;
            this.deviceinfo = false;
            this.employeeinfo = false;
            this.licenseinfo= false;
        }

    }

    handleChange(event) {
        this.value = event.detail.value;
    }

     handleSelectChange(event) {
        this.selectedValueSchedule = event.target.value;
         console.log('selectedValueSchedule', this.selectedValueSchedule);
 
    }

    
handleInputChangeModal(event)
{
     if (event.target.name === 'mondayStartTime') {
            this.mondayStartTime = event.target.value;
        }
         if (event.target.name === 'mondayEndTime' ) {
            this.mondayEndTime = event.target.value;
        }
         if (event.target.name === 'tuesdayStartTime') {
            this.tuesdayStartTime = event.target.value;
        }
         if (event.target.name === 'tuesdayEndTime') {
            this.tuesdayEndTime = event.target.value;
        }
         if (event.target.name === 'wednesdayStartTime') {
            this.wednesdayStartTime = event.target.value;
        }
          if (event.target.name === 'wednesdayEndTime') {
            this.wednesdayEndTime = event.target.value;
        }
          if (event.target.name === 'thursdayStartTime') {
            this.thursdayStartTime = event.target.value;
        }
          if (event.target.name === 'thursdayEndTime') {
            this.thursdayEndTime = event.target.value;
        }
          if (event.target.name === 'fridayStartTime') {
            this.fridayStartTime = event.target.value;
        }
          if (event.target.name === 'fridayEndTime') {
            this.fridayEndTime = event.target.value;
        }
          if (event.target.name === 'saturdayStartTime') {
            this.saturdayStartTime = event.target.value;
        }
          if (event.target.name === 'saturdayEndTime') {
            this.saturdayEndTime = event.target.value;
        }
           if (event.target.name === 'sundayStartTime') {
            this.sundayStartTime = event.target.value;
        }
           if (event.target.name === 'sundayEndTime') {
            this.sundayEndTime = event.target.value;
        }
     if (event.target.name === 'OFT') {
            this.overflowT24 = event.target.value;
            //  alert(this.overflowT24)
        }
         if (event.target.name === 'OFD') {
            this.overflowD24 = event.target.value;
           // alert(this.overflowD24)
        }
        if (event.target.name === 'openOFT') {
            this.overflowTOpen = event.target.value;
           // alert(this.overflowD24)
        }
        if (event.target.name === 'openOFD') {
            this.overflowDOpen = event.target.value;
           // alert(this.overflowD24)
        }
        if (event.target.name === 'ClosedOFT') {
            this.overflowTClose = event.target.value;
           // alert(this.overflowD24)
        }
        if (event.target.name === 'ClosedOFD') {
            this.overflowDClose = event.target.value;
           // alert(this.overflowD24)
        }
        if (event.target.name === 'tpName1') {
            this.customTimePeriodName1 = event.target.value;
           // alert(this.overflowD24)
        }
        if (event.target.name === 'tpName2') {
            this.customTimePeriodName2 = event.target.value;
           // alert(this.overflowD24)
        }
        if (event.target.name === 'Custom1OFD') {
           // alert('custom OFD '+ event.target.value);
            this.customTimePeriod1OFD = event.target.value;
           //alert(this.customTimePeriod1OFD)
        }
        if (event.target.name === 'Custom2OFD') {
            this.customTimePeriod2OFD = event.target.value;
           // alert(this.overflowD24)
        }
           if (event.target.name === 'Custom1OFT') {
            this.customTimePeriod1OFT = event.target.value;
            // alert(this.customTimePeriod1OFT)
        }
        if (event.target.name === 'Custom2OFT') {
            this.customTimePeriod2OFT = event.target.value;
           // alert(this.overflowD24)
        }
        if (event.target.name === 'holidayName') {
            this.holidayName = event.target.value;
           // alert(this.overflowD24)
        }
        if (event.target.name === 'holidayDate') {
            this.holidayDate = event.target.value;
           // alert(this.overflowD24)
        }

}



    
handleInputChange(event) {
    this.fieldChangeCount++;
    this.notifyInputChange(this.fieldChangeCount);
    const recordId = event.target.dataset.recordId;
    const fieldName = event.target.dataset.fieldName;
    const newValue = event.target.value;
    this.N11=false;
    this.MLHGName='';
    this.RecordIds=event.target.dataset.recordId;
    console.log('reocrd id' ,recordId);
    console.log(fieldName);
    console.log(newValue);
    
       
    const index = this.ftrDIDNumberDetailsMLHG.findIndex(ftrDIDNumberDetail => ftrDIDNumberDetail.Id === recordId);
    if (index !== -1) {
        // Update the field value in the account data
        this.ftrDIDNumberDetailsMLHG[index][fieldName] = newValue;
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
        console.log(JSON.stringify(this.draftValues));
    }
    if (fieldName === 'Ucf_Extension__c') {
        // Check for duplicate Ucf_Extension__c entry
        if(event.target.value !== '')
        {
        const isDuplicate = this.ftrDIDNumberDetailsMLHG.some(detail => 
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
}
if (fieldName === 'MLHG_Name__c') {
    // Check for duplicate MLHG_Name__c entry
    this.MLHGName=newValue;
    if(event.target.value !== '')
    {
    const isDuplicate = this.ftrDIDNumberDetailsMLHG.some(detail => 
        detail.MLHG_Name__c === newValue && detail.Id !== recordId
    );

      if (isDuplicate) {
       
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Duplicate Name',
            message: 'Please enter an unique name',
            variant: 'error'
        })
    );
    return;
    }
}
}
}
// Handle column sorting MLHG Schedule
handleSorting(event){
    this.sortColumn = event.currentTarget.dataset.fieldName;
    this.sortDirection = this.sortColumn === this.sortColumn && this.sortDirection === 'asc' ? 'desc' : 'asc';
    if(this.sortColumn=='UCF_Name__c'){
        this.sortScheduleData();
    }
    else{
        this.sortData();
    }

}

sortData() {
    const field = this.sortField;
    const reverse = this.sortDirection === 'desc' ? -1 : 1;
    this.ftrDIDNumberDetailsMLHG = [...this.ftrDIDNumberDetailsMLHG.sort((a, b) => (a[field] > b[field] ? 1 : -1) * reverse)];
}
sortScheduleData() {    
    const field = this.sortColumn;
    const reverse = this.sortDirection === 'desc' ? -1 : 1;
    this.schedules = [...this.schedules.sort((a, b) => (a[field] > b[field] ? 1 : -1) * reverse)];
}
validateInputForNumber(event) {
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

     addHolidayRow() {
        if (!this.newHolidayName) {
            this.showToast('Error', 'Holiday name cannot be empty', 'error');
            return;
        }
        const getHoliday = this.newHolidayName.trim();
        if (this.holidaysGet.some(hol => hol.Name === getHoliday)) {
           this.showToast('Error','This Holiday already exists.','error');
           return;
       }
        insertHolidayName({ holidayName: this.newHolidayName, scheduleId: this.schId})
            .then(result => {
                //console.log("Schedule created"+result);
                if(result==='Holiday added succesfully'){
                    this.showToast('Success', result, 'success');
                    this.newHolidayName = '';
                      this.loadHolidays();

                }
                else{
                    this.showToast('Error', result, 'Error'); 
                }
                 this.scheduleName = '';
                this.loadHolidays();
            })
            .catch(error => {
                const errorMessage = error.body && error.body.message ? error.body.message : 'An error occurred';
                this.showToast('Error', errorMessage, 'error');
            });
    }

 loadHolidays() {
        getHolidaysBySchedule({ scheduleId: this.schId })
            .then(result => {
                this.holidaysGet = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.holidays = undefined;
            });
    }

      handleHolidayDateChange(event) {
        let holidayId = event.target.dataset.id;
        let newDatetocheck = new Date(event.target.value);
        let newDate = event.target.value;
        let today = new Date();
        today.setHours(0, 0, 0, 0);
          if(newDatetocheck < today) {
            this.hasPastDateError = true;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Past dates are not allowed',
                variant: 'error'
            }));
            let holiday = this.holidaysGet.find(h => h.Id === holidayId);
             if (holiday) {
                holiday.Date__c = '';
            }
        } else {
            this.hasPastDateError = false;
           let holiday = this.holidaysGet.find(h => h.Id === holidayId);
            if (holiday) {
                holiday.Date__c = newDate;
            }
        }
    }

closeModal()
    {
        this.isModalOpen = false;
        this.is247Expanded = false;
        this.showCustomSch1 = false;
        this.showCustomSch2 = false;
        this.isHolidayExpanded = false;
        this.isOpenExpanded = false;
    }

    timeStringToMinutes(timeStr) {
    const [hours, minutes] = timeStr.split(':').map(Number);
    return hours * 60 + minutes;
}
handleModalSave()
{
   let invalidTimes = [];

// Validate Monday
if (this.mondayStartTime && this.mondayEndTime && this.timeStringToMinutes(this.mondayStartTime) >= this.timeStringToMinutes(this.mondayEndTime)) {
        invalidTimes.push('Monday');
    }
// Validate Tuesday
if (this.tuesdayStartTime && this.tuesdayEndTime && this.timeStringToMinutes(this.tuesdayStartTime) >= this.timeStringToMinutes(this.tuesdayEndTime)) {
        invalidTimes.push('Tuesday');
    }

    // Validate Wednesday
    if (this.wednesdayStartTime && this.wednesdayEndTime && this.timeStringToMinutes(this.wednesdayStartTime) >= this.timeStringToMinutes(this.wednesdayEndTime)) {
        invalidTimes.push('Wednesday');
    }

// Validate Thursday
 if (this.thursdayStartTime && this.thursdayEndTime && this.timeStringToMinutes(this.thursdayStartTime) >= this.timeStringToMinutes(this.thursdayEndTime)) {
        invalidTimes.push('Thursday');
    }

// Validate Friday

if (this.fridayStartTime && this.fridayEndTime && this.timeStringToMinutes(this.fridayStartTime) >= this.timeStringToMinutes(this.fridayEndTime)) {
        invalidTimes.push('Friday');
    }

// Validate Saturday

if (this.saturdayStartTime && this.saturdayEndTime && this.timeStringToMinutes(this.saturdayStartTime) >= this.timeStringToMinutes(this.saturdayEndTime)) {
        invalidTimes.push('Saturday');
    }
// Validate Sunday
if (this.sundayStartTime && this.sundayEndTime && this.timeStringToMinutes(this.sundayStartTime) >= this.timeStringToMinutes(this.sundayEndTime)) {
        invalidTimes.push('Sunday');
    }

if (invalidTimes.length > 0) {
    // Display a single generic error message
    this.showToast('Error', `Stop time must be after Start Time.`, 'error');
    return; // Halt the save operation
}

    
     if (parseInt(this.overflowT24) < 0 || parseInt(this.overflowT24) > 60) {
        this.showToast('Error', 'Overflow Timer 24/7 must be a number between 0 and 60.', 'error');
        return;
    }

    if (parseInt(this.overflowTOpen) < 0 || parseInt(this.overflowTOpen) > 60) {
        this.showToast('Error', 'Overflow Timer Open must be a number between 0 and 60.', 'error');
        return;
    }

    if (parseInt(this.overflowTClose) < 0 || parseInt(this.overflowTClose) > 60) {
        this.showToast('Error', 'Overflow Timer closed must be a number between 0 and 60.', 'error');
        return;
    } 
      //  alert('hiiiiiii: ' +JSON.stringify(this.schedulesCustomTime));
  let isInvalidTimeFound = false;

    this.schedulesCustomTime.forEach(schedule => {
        // Check Overflow Timer for the entire schedule
        if (schedule.Overflow_Timer__c) {
            let overflowTimerValue = parseInt(schedule.Overflow_Timer__c, 10);
            if (isNaN(overflowTimerValue) || overflowTimerValue > 60) {
                this.showToast('Error', `Invalid Overflow timer in schedule "${schedule.name}": Overflow Timer must be between 0 and 60.`, 'error');
                isInvalidTimeFound = true;
            }
        }

        // Check start and stop times for each period
        schedule.timePeriods.forEach(period => {
            const hasStartTime = typeof period.Start === 'string' && period.Start.trim() !== '';
            const hasStopTime = typeof period.Stop === 'string' && period.Stop.trim() !== '';

            if ((hasStartTime && hasStopTime && this.isTimeBefore(period.Stop, period.Start)) ||
                (!hasStartTime && hasStopTime)) {
               // this.showToast('Error', `Invalid time : "${schedule.name}": Stop time cannot be before start time.`, 'error');
                isInvalidTimeFound = true;
            }
        });
    });

   if (isInvalidTimeFound) {
    this.showToast('Error', `Invalid time: Stop time must be after Start Time.`, 'error');
    return;
}

    const schid = this.schId;
    //alert(schid);
     const holidaysToSave = this.holidays.map(holiday => ({
        Name: holiday.name,
        Date__c: holiday.date,
        Schedule__c: schid // Replace with the actual API name of your field
    }));




        const recordId = this.recordId;


  const updatedSchedule = {
        Id: this.schId,
        Overflow_Timer_24_7__c: this.overflowT24,
        Overflow_Destination_24_7__c: this.overflowD24,
        Overflow_Timer_Closed__c: this.overflowTClose,
        Overflow_Destination_Closed__c: this.overflowDClose,
        Overflow_Timer_Open__c:this.overflowTOpen,
        Overflow_Destination_Open__c:this.overflowDOpen,
        Monday_Start_Time__c: this.mondayStartTime,
        Monday_End_Time__c: this.mondayEndTime,
        Tuesday_Start_Time__c: this.tuesdayStartTime,
        Tuesday_End_Time__c: this.tuesdayEndTime,
        Wednesday_Start_Time__c: this.wednesdayStartTime,
        Wednesday_End_Time__c: this.wednesdayEndTime,
        Thursday_Start_Time__c: this.thursdayStartTime,
        Thursday_End_Time__c: this.thursdayEndTime,
        Friday_Start_Time__c: this.fridayStartTime,
        Friday_End_Time__c: this.fridayEndTime,
        Saturday_Start_Time__c: this.saturdayStartTime,
        Saturday_End_Time__c: this.saturdayEndTime,
        Sunday_Start_Time__c: this.sundayStartTime,
        Sunday_End_Time__c: this.sundayEndTime

    };

        updateSchedule({ updatedSchedule: updatedSchedule })
            .then(result => {
                // Handle success - you can show a toast message or close the modal
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Schedule updated',
                        variant: 'success',
                    }),
                );
                this.isModalOpen = false;
                this.is247Expanded = false;
                this.showCustomSch1 = false;
                this.showCustomSch2 = false;
                this.isHolidayExpanded = false;
                this.isOpenExpanded = false; // Close the modal if you have one
                this.isClosedExpanded = false;
                this.fetchSchedules();
            })
            .catch(error => {
                // Handle error - you can show a toast message with the error
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating schedule',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
      
                this.handleSaveTime();
                this.saveHolidayChanges();
                this.isModalOpen = false;
                this.is247Expanded = false;
                this.showCustomSch1 = false;
                this.showCustomSch2 = false;
                this.isHolidayExpanded = false;
                this.isOpenExpanded = false; 
                this.fetchSchedules();
                this.holidays = [];      

}

saveHolidayChanges() {
 updateHolidays({ holidays: this.holidaysGet })
        .then(result => {
            //this.showToast('Success', 'Holidays updated successfully', 'success');
            // Optionally, reload the holidays to reflect the saved data
            this.loadHolidays();
        })
        .catch(error => {
            // ... existing code ...
        });
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
checkValueExists(idToCheck) {
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
                    
                    if(!this.validateRequiredFields())
                    {
                        this.dispatchEvent(
                                                new ShowToastEvent({
                                                    title: 'Schdule Required',
                                                    message: 'Please select the Schdule ',
                                                    variant: 'error'
                                                })
                                            );
                                        isValidationFailed = true;
                                return;
                    }


                    

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
                        this.ftrDIDNumberDetailsMLHG.forEach(draft => {
                    
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

                console.log('1229'+Duplicate);
                /***** Checking duplicate Ext with in the order when Ext is not changed manually and user saved*/
                console.log('Contain Ext'+ExtChanged);

                if((Duplicate == false && this.draftValues.length == 0) || (Duplicate == false && this.draftValues.length !== 0 && ExtChanged == false)) 
                {

                    this.ftrDIDNumberDetailsMLHG.forEach(draft => {
                    if (draft.Ucf_Extension__c) {
                        const isDuplicateExtension = this.ftrDIDNumberDetails.some(detail =>
                            detail.Ucf_Extension__c === draft.Ucf_Extension__c && detail.Id !== draft.Id
                        );

                        if (isDuplicateExtension) {
                            Duplicate=true;
                            isValidationFailed = true;
                            console.log('Duplicate when no change in Ext or change in other fields with in or out side MLHG');
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

                    if(this.MLHGName !== ''){
                        const isDuplicate = this.ftrDIDNumberDetailsMLHG2.some(detail => 
                        detail.MLHG_Name__c.toLowerCase() === this.MLHGName.toLowerCase() && detail.Id !== this.RecordIds
                    );
                    if (isDuplicate) {
                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Duplicate Name',
                            message: 'Please enter an unique name',
                            variant: 'error'
                        })
                    );
                    isValidationFailed = true;
                    return;
                    }

                    }
                    this.ftrDIDNumberDetailsMLHG.forEach(detail =>{
                                
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
                                console.log('ext a '+parseInt(detail.Ucf_Extension__c).toString().length);
                                console.log('ext b'+this.length);

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
                            
                    /*if(this.draftValues == null || this.draftValues == '')
                    {
                        this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'You can only Save Data once you made some changes in the grid`',
                                    variant: 'error'
                                })
                            );
                        return;
                        
                    }*/
                    // Create an array to store the records that need to be updated
                    const recordsToUpdate = [];
                    // Loop through draftValues to build the array of records to update
                    this.draftValues.forEach(draft => {
                        recordsToUpdate.push({
                            Id: draft.Id,
                            Ucf_Extension__c: draft.Ucf_Extension__c, 
                            Ring_Pattern__c: draft.Ring_Pattern__c, 
                            Schedule__c:draft.Schedule__c,
                            MLHG_Name__c:draft.MLHG_Name__c,
                            EAS_Pin__c:draft.EAS_Pin__c

                        });
                    });
                //alert(JSON.stringify(recordsToUpdate));
                    // Call the Apex method to update the records
                    if (isValidationFailed==false && this.draftValues.length !== 0) {
                    updateftrDIDNumberDetailsEmployeeTab({ recordsToUpdate })
                        .then(result => {
                            this.fieldChangeCount=0;
                            this.notifyInputChange(this.fieldChangeCount);
                            // Handle success
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Records saved successfully',
                                    variant: 'success'
                                })
                            );

                            // Clear the draftValues array
                            this.draftValues = [];
                            this.getTtrDIDNumberDetailsMLHGData(this.recordId);
                            // Refresh the table data
                            return refreshApex(this.wiredftrDIDNumberDetailsMLHG);
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
   
handleTimeChangeCustom1(event) {
   
    const dayLabel = event.target.dataset.dayLabel;
    const isStartTime = event.target.name.includes('Start');
    const fieldToUpdate = isStartTime ? 'Start__c' : 'Stop__c';
    const timeValue = event.target.value;

    // Check if the dayLabel exists in the originalTimePeriods object, if not, initialize it
    if (!this.originalTimePeriods[dayLabel]) {
        this.originalTimePeriods[dayLabel] = { startTime: '', endTime: '' };
    }
       // alert('1 '+this.customTimePeriod1OFD);
       // alert('2 '+this.customTimePeriod1OFT);
    // Initialize the modified record if it doesn't exist
    if (!this.modifiedTimePeriods[dayLabel]) {
        this.modifiedTimePeriods[dayLabel] = {
            Day__c: dayLabel,
            Schedule__c: this.schId,
            Name: this.customTimePeriodName1,
            Overflow_Timer__c: this.customTimePeriod1OFT,
            Overflow_Destination__c : this.customTimePeriod1OFD
        };
    }

    // Update the time value
    this.modifiedTimePeriods[dayLabel][fieldToUpdate] = timeValue;
    
    // Make sure to trigger reactivity in LWC
    this.modifiedTimePeriods = { ...this.modifiedTimePeriods };
  //  alert(JSON.stringify(this.modifiedTimePeriods));
}
handleTimeChangeCustom2(event) {
    const dayLabel = event.target.dataset.day2OfWeek; // Make sure this matches the dataset attribute
    console.log('dayLabel:' + dayLabel);
    //alert(event.target.name);

    const isStartTime = event.target.name.includes('Start');
    const fieldToUpdate = isStartTime ? 'Start__c' : 'Stop__c';
    const timeValue = event.target.value;

    // Check if the dayLabel exists in the originalTimePeriodsC2 object, if not, initialize it
    if (!this.originalTimePeriodsC2[dayLabel]) {
        this.originalTimePeriodsC2[dayLabel] = { startTimeC2: '', endTimeC2: '' };
    }


    // Initialize the modified record if it doesn't exist
    if (!this.modifiedTimePeriodsC2[dayLabel]) {
        this.modifiedTimePeriodsC2[dayLabel] = {
            Day__c: dayLabel,
            Schedule__c: this.scheduleId,
            Name: this.customTimePeriodName2,
            Overflow_Timer__c: this.customTimePeriod2OFT,
            Overflow_Destination__c : this.customTimePeriod2OFD
        };
    }

    // Update the time value
    this.modifiedTimePeriodsC2[dayLabel][fieldToUpdate] = timeValue; // Corrected object name
    
    // Make sure to trigger reactivity in LWC
    this.modifiedTimePeriodsC2 = { ...this.modifiedTimePeriodsC2 };
}
  
addHoliday() {
    // Use a method or property to get the current schedule ID
   // const currentScheduleId = this.getScheduleId(); // Implement this method according to your logic
    
    // Add a new holiday to the list with the current schedule ID
    this.holidays = [...this.holidays, { name: '', date: '', scheduleId: this.scheduleId }];

}

handleDateChange(event) {
    const index = event.target.dataset.index;
    const selectedDate = new Date(event.target.value);
    const currentDate = new Date();
    currentDate.setHours(0, 0, 0, 0); // Reset time to the start of the day for comparison

    if (selectedDate < currentDate) {
        // Show an error message if the date is in the past
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Invalid Date',
                message: 'You cannot add holidays in the past.',
                variant: 'error'
            })
        );
    } else if (this.holidays[index]) {
        this.holidays[index].date = event.target.value;
    } else {
        // Handle the case where the index does not refer to an item in the array
        console.error('Holiday index out of bounds:', index);
    }
}


handleNameChange(event) {
    const index = event.target.dataset.index; // Use 'dataset.index' instead of 'dataset.id'
    if (this.holidays[index]) {
        this.holidays[index].name = event.target.value;
    } else {
        // Handle the case where the index does not refer to an item in the array
        console.error('Holiday index out of bounds:', index);
    }
}

deleteHoliday(event) {
    const index = event.currentTarget.dataset.index; // Use currentTarget to get the button that was clicked
    this.holidays = this.holidays.filter((_, i) => i.toString() !== index);
}

//Edit Modal Work


    handleDidNumberIds() {
      this.showLoaderModal = true;
      GetDidNumbers({
            'didNumberId': this.selectedAccount.Id
         })
         .then((result) => {
            this.GetDidNumbers = result;
            console.log('inside GetDidNumbers', this.GetDidNumbers);
            this.tempDIDIds = [];
            this.GetDidNumbers.forEach(didNumber => {
               this.tempDIDIds.push(didNumber.DID_Number_Details__c);
               console.log('temppppp'+this.tempDIDIds);
            })
            this.tempNumber = this.GetDidNumbers.length;
            console.log('tempNumber'+this.tempNumber);
            this.length2= this.tempNumber;
            console.log('length2'+this.length2);
            this.showLoaderModal = false;
            validateRingOneAtaTime({
                'didNumberId': this.selectedAccount.Id
             })
             .then((result) => {
                this.isRingOne = result;
             })
             .catch((error) => {
                console.log(error.body.message);
             });
         })
         .catch((error) => {
            this.showToast('Error!', error.body.message, 'error', 'sticky');
            this.GetDidNumbers = undefined;
         });

         


   }

   fetchSchedules() {
    queryschedules({ orderId: this.recordId, sortField: this.sortField, sortDirection: this.sortDirection, RecordTypeId: this.RecdTypeId })
        .then(result => {
            this.schedules = result.map(UCF_Name__c => ({ ...UCF_Name__c, editMode: true }));
            this.wiredResult = result;
            //console.log('fetchSchedules',JSON.parse(JSON.stringify(result)));
            // Any other logic you need after fetching data
        })
        .catch(error => {
            this.error = error;
            // Handle the error
        });
}

    
   @api
   getTtrDIDNumberDetailsMLHGData(recordId) {
    getTtrDIDNumberDetailsMLHGData({
         'recordId': this.recordId
      }).then(result => {
         // Loop through the records and extract the number from MLHG_Name__c
         this.ftrDIDNumberDetailsMLHG = result.ftrDIDNumberDetailList.map(ftr_DID_Number_Details__c => {
            const selectedItemsCount = parseInt((ftr_DID_Number_Details__c.Member__c || '').match(/\d+/), 10) || 0;
            let extLength = parseInt(ftr_DID_Number_Details__c.Ucf_Extension_Lenght__c);
            this.length = extLength;
            let ext = ftr_DID_Number_Details__c.DIDNumber__c.slice(-extLength);
            let N11 = ext.slice(-2);
            return {
                ...ftr_DID_Number_Details__c,
                editMode: true,
                slicedExtension: ext, 
                N11:N11 == '11' ? true : false,
                Ucf_Extension__c: ftr_DID_Number_Details__c.Ucf_Extension__c,
                MLHG_Name__c: ftr_DID_Number_Details__c.MLHG_Name__c || '',
                EAS_Pin__c: ftr_DID_Number_Details__c.EAS_Pin__c || '',
                selectedItems: [],
                selectedItemsCount: selectedItemsCount, // Extracted number
            };
        });
     if(this.ftrDIDNumberDetailsMLHG.length > 0){
        this.showTable = true;
     }

        this.ftrDIDNumberDetailsMLHG2 = result.ftrDIDNumberDetailList.map(ftr_DID_Number_Details__c => {
            const selectedItemsCount = parseInt((ftr_DID_Number_Details__c.Member__c || '').match(/\d+/), 10) || 0;
            let extLength = parseInt(ftr_DID_Number_Details__c.Ucf_Extension_Lenght__c);
            this.length = extLength;
            let ext = ftr_DID_Number_Details__c.DIDNumber__c.slice(-extLength);
            let N11 = ext.slice(-2);
            return {
                ...ftr_DID_Number_Details__c,
                editMode: true,
                slicedExtension: ext, 
                N11:N11 == '11' ? true : false,
                Ucf_Extension__c: ftr_DID_Number_Details__c.Ucf_Extension__c,
                MLHG_Name__c: ftr_DID_Number_Details__c.MLHG_Name__c || '',
                EAS_Pin__c: ftr_DID_Number_Details__c.EAS_Pin__c || '',
                selectedItems: [],
                selectedItemsCount: selectedItemsCount, // Extracted number
            };
        });
        
       
            this.members = result.availableDIDNumberList.map(option => ({
                        label: `${option.Ucf_User_Name__c} - ${option.DIDNumber__c}`,
                        value: option.Id
                    })).sort((a, b) => {
                        return a.label.localeCompare(b.label);
                    });
                    console.log('helooooooooo', this.members);
        this.showLoader=false;
      }).catch(error => {
         this.showToast('Error!', error.body.message, 'error', 'sticky');
         console.log('error..!', error);
      });
   }

   
  loadSchedules() {
    getSavedTimePeriods({ scheduleId: this.schId })
        .then(data => {
            console.log('Loaded Schedules Data:', data); // Log the raw data
           // alert(JSON.stringify(data));
            this.schedulesCustomTime = data.map(schedule => ({
                id: schedule.Id,
                name: schedule.Name,
                Overflow_Timer__c: schedule.Overflow_Timer__c,
                Overflow_Destination__c: schedule.Overflow_Destination__c,
                timePeriods: this.mapTimePeriods(schedule)
            }));
            console.log('Mapped Schedules:', this.schedulesCustomTime); // Log the mapped data
           // alert(JSON.stringify(this.schedulesCustomTime));
        })
        .catch(error => {
           // this.showToast('Error', error.body.message, 'error');
            console.error('Error loading schedules:', error); // Log any errors
        });
}

mapTimePeriods(schedule) {
     const days = [
        { label: 'Monday', suffix: 'Monday' },
        { label: 'Tuesday', suffix: 'Tuesday' },
        { label: 'Wednesday', suffix: 'Wednesday' },
        { label: 'Thursday', suffix: 'Thursday' },
        { label: 'Friday', suffix: 'Friday' },
        { label: 'Saturday', suffix: 'Saturday' },
        { label: 'Sunday', suffix: 'Sunday' }
    ];
    return days.map(day => ({
        day: day.label,
        Start: schedule[day.suffix + 'Start__c'] || '', // Corrected to use day.suffix
        Stop: schedule[day.suffix + 'Stop__c'] || '', // Corrected to use day.suffix
        changed: false
    }));
}



handleTimeChange(event) {
   // alert('test....');
    const scheduleIndex = event.target.dataset.scheduleIndex;
    const periodIndex = event.target.dataset.periodIndex;
    const field = event.target.name === 'StartTime' ? 'Start' : 'Stop';

    let updatedSchedules = JSON.parse(JSON.stringify(this.schedulesCustomTime));
    updatedSchedules[scheduleIndex].timePeriods[periodIndex][field] = event.target.value;
    updatedSchedules[scheduleIndex].timePeriods[periodIndex].changed = true;

    // Perform validation if both start and stop times are set
    const startTime = updatedSchedules[scheduleIndex].timePeriods[periodIndex].Start;
    const stopTime = updatedSchedules[scheduleIndex].timePeriods[periodIndex].Stop;

   /* if (startTime && stopTime && this.isTimeBefore(stopTime, startTime)) {
        this.showToast('Error', 'Stop time cannot be before start time', 'error');
        updatedSchedules[scheduleIndex].timePeriods[periodIndex].Stop = '';
        updatedSchedules[scheduleIndex].timePeriods[periodIndex].changed = false;
    } */

    this.schedulesCustomTime = updatedSchedules;
}

isTimeBefore(time1, time2) {
    const [hours1, minutes1] = time1.split(':').map(Number);
    const [hours2, minutes2] = time2.split(':').map(Number);
    const date1 = new Date(0, 0, 0, hours1, minutes1);
    const date2 = new Date(0, 0, 0, hours2, minutes2);
    return date1 < date2;
}


//  handleScheduleNameChange(event) {
    
//       this.scheduleName = event.target.value;
//        //alert('here '+  this.schedule );
//  }

  handleHolidayNameChange(event) {
      this.newHolidayName = event.target.value;
       //alert('here '+  this.schedule );
 }

  handleDateChange(event) {
        let holidayId = event.target.dataset.id;
        let newDate = event.target.value;
        let holiday = this.holidays.find(h => h.Id === holidayId);
        if (holiday) {
            holiday.Date__c = newDate;
        }
    }
//   handleScheduleNameChange(event) {
    
//       this.scheduleName = event.target.value;
//       // alert('here '+  this.schedule );
//  }

    handleScheduleNameChangeForTp(event) {
        const scheduleIndex = event.target.dataset.scheduleIndex;
        const newScheduleName = event.target.value;
        this.schedulesCustomTime[scheduleIndex].name = newScheduleName;
    }

    handleOverflowTimeChange(event) {
        const scheduleIndex = event.target.dataset.scheduleIndex;
        const newOFT = event.target.value;
        this.schedulesCustomTime[scheduleIndex].Overflow_Timer__c = newOFT;
    }

    handleOverDestinationChange(event) {
        const scheduleIndex = event.target.dataset.scheduleIndex;
        const newOFD = event.target.value;
        this.schedulesCustomTime[scheduleIndex].Overflow_Destination__c = newOFD;
    }

    
handleAddSchedule() {
     if (this.schedulesCustomTime.length >= 2) {
            // Show toast message and do not add new schedule
            this.showToast('Info', 'Cannot add more than 2 schedules', 'info');
            return;
        }
    const newId = this.schedulesCustomTime.length + 1;
    const newSchedule = {
        name: `Custom ${newId}`,
        Menu__c:  `Menu ${newId}`,
        Overflow_Timer__c: 0,
        Overflow_Destination__c: '',
        timePeriods: this.createDefaultTimePeriods()
    };
  
    this.schedulesCustomTime = [...this.schedulesCustomTime, newSchedule];
      //alert(JSON.stringify(this.schedulesCustomTime ));
}

createDefaultTimePeriods() {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days.map(dayLabel => ({ day: dayLabel, Start: '', Stop: '', changed: false }));
}




handleSaveTime() {
    let scheduleRecords = this.schedulesCustomTime.map(schedule => {
        let record = {
            Id: schedule.id ? schedule.id : null,
            sobjectType: 'Time_Period__c',
            Name: schedule.name,
             Menu__c: schedule.menuSelectTp,
             Schedule__c: this.schId,
            Overflow_Timer__c: schedule.Overflow_Timer__c,
            Overflow_Destination__c: schedule.Overflow_Destination__c,
        };

        schedule.timePeriods.forEach(period => {
            let dayPrefix = period.day; // Convert 'Monday' to 'Mon', etc.
            dayPrefix = dayPrefix.charAt(0).toUpperCase() + dayPrefix.slice(1); // Capitalize the first letter

            const startField = `${dayPrefix}Start__c`;
            const endField = `${dayPrefix}Stop__c`;
            record[startField] = period.Start;
            record[endField] = period.Stop;
        });

        return record;
    });
    if (scheduleRecords.length > 0) {
        saveTimePeriodsNew({ timePeriods: scheduleRecords })
            .then(() => {
                this.fieldChangeCount=0;
                this.notifyInputChange(this.fieldChangeCount);
               // this.showToast('Success', 'Time periods saved successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    } else {
       // this.showToast('Info', 'No changes to save', 'info');
    }
}
notifyInputChange(count){
    this.dispatchEvent(new CustomEvent('recordchange', {
        detail: {
            component: 'multiLineHauntingGroup',
            message: count
        }
    }));
}

handleCancel(event){
    this.fieldChangeCount=0;
    this.notifyInputChange(this.fieldChangeCount);
}


saveDualListbox() {
   // alert('hello');
    this.showDualListboxModal = false;
    this.selectedAccount.selectedItemsCount = this.length2;
    this.membername = this.length2 + ' Members';
    console.log('membername', this.membername);
    console.log('length2', this.length2);
    const recordToUpdate = [{
       Id: this.selectedAccount.Id,
       Member__c: this.membername
    }];
    //console.log(JSON.stringify(recordToUpdate));
    //console.log('zainab save dual box'+JSON.stringify(this.draftValues));

    const recordsToinsert = [];
    this.selectedItems.forEach(selectedId => {
     const member = this.members.find(m => m.value === selectedId);
    
       // Assuming member is found and has a label property
       
       recordsToinsert.push({
          Name: member.label,
          DID_Number_Details__c: selectedId,
          Parent_DID_Number_Detail__c: this.selectedAccount.Id,
       });
       
    });


 /*   const recordsToinsert = this.selectedItems.length > 0 ? [] : this.tempDIDIds.map(didId => {
        return {
             // You need to provide a logic to get the name based on DID ID
            DID_Number_Details__c: didId,
            Parent_DID_Number_Detail__c: this.selectedAccount.Id,
        };
    });

    // If new selections are made, populate recordsToinsert with them
    if (this.selectedItems.length > 0) {
        this.selectedItems.forEach(selectedId => {
            const member = this.members.find(m => m.value === selectedId);
            recordsToinsert.push({
                Name: member.label,
                DID_Number_Details__c: selectedId,
                Parent_DID_Number_Detail__c: this.selectedAccount.Id,
            });
        });
    }
*/
    console.log('zainab',JSON.stringify(recordsToinsert));
  //  if (recordsToinsert.length > 0) {
    this.showLoaderModal = true;
    updateRecords({
       didRecordToUpdate: recordToUpdate[0],
       gmRecordsList: recordsToinsert,
       ishandle : this.isHandle
    }).then(result => {
       this.getTtrDIDNumberDetailsMLHGData(this.recordId);
       console.log('dataaaaaaaaaaaaaa', JSON.stringify(this.ftrDIDNumberDetailsMLHG));
       this.showToast('Success', 'Updates Successfull', 'success');
       this.showLoaderModal = false;
       this.isModalOpenMLHGSetup = false;
    }).catch(error => {
       this.showLoaderModal = false;
       this.showToast('Error', error.body.message, 'error');
    });
   // }
     /*   else {
        // this.showLoaderModal = false;
        this.isModalOpenMLHGSetup = false;
        // Handle the case when recordsToinsert is empty
        console.log('No records to insert or update');
        // You can add additional logic here, like showing a message to the user
        }*/
    //this.length2 = 0;
    
 }

 handleChangeDualListboxModal(event) {
    this.isHandle= true ;
    this.selectedItems = event.detail.value;
    this.length2 = this.selectedItems.length;
    //const rowIndex = event.target.getAttribute('data-row-index');
    console.log('row', this.rowIndex);
    console.log('isHandle', this.isHandle);
    console.log('length2', this.length2);
    console.log('selectedItems', this.selectedItems[this.rowIndex]);
 }

 openDualListbox(event) {
    console.log('zainab open dual box'+JSON.stringify(this.draftValues));

    this.isModalOpenMLHGSetup = true;
    this.isEditModeMLHGSetup = !this.isEditModeMLHGSetup;
    this.rowIndex = event.target.getAttribute('data-row-index');
    console.log('rowIndex', this.rowIndex);
    if (this.rowIndex >= 0 && this.rowIndex < this.ftrDIDNumberDetailsMLHG.length) {
       this.selectedAccount = this.ftrDIDNumberDetailsMLHG[this.rowIndex]; // Store the account being edited
       console.log('selectedAccount', JSON.stringify(this.selectedAccount));
    }
    this.handleDidNumberIds();
    //console.log('testing', this.tempDIDIds.length);

 }

 closeDualListbox() {
    this.isModalOpenMLHGSetup = false;
 }

}