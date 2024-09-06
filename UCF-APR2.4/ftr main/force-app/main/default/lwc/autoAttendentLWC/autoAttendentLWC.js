import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
import queryAccounts from '@salesforce/apex/FetchData.queryAccounts';
import queryAccounts2 from '@salesforce/apex/FetchData.queryAccounts2';
import queryschedules from '@salesforce/apex/UcfAutoAttendentController.ScheduleforAutoAttendantsSchedules';
import queryschedulesForAA from '@salesforce/apex/UcfAutoAttendentController.ScheduleforAutoAttendantsSchedules';
import ftrDIDNumberDetails from '@salesforce/apex/FetchData.ftrDIDNumberDetails';
import greetingsforAutoAttendantsGreetings from '@salesforce/apex/UcfAutoAttendentController.greetingsforAutoAttendantsGreetings';
import menusforAutoAttendants from '@salesforce/apex/UcfAutoAttendentController.menusforAutoAttendants';
import insertMenus from '@salesforce/apex/UcfAutoAttendentController.insertMenus';
import deleteMenus from '@salesforce/apex/UcfAutoAttendentController.deleteMenus';
import insertScheduleRec from '@salesforce/apex/UcfAutoAttendentController.insertSchedule';
import insertGreeting from '@salesforce/apex/UcfAutoAttendentController.insertGreeting';
import greetingforEdit from '@salesforce/apex/UcfAutoAttendentController.greetingforEdit';
import updateGreeting from '@salesforce/apex/UcfAutoAttendentController.updateGreeting';
import deleteSchedule from '@salesforce/apex/UcfAutoAttendentController.deleteSchedule';
import deleteGreeting from '@salesforce/apex/UcfAutoAttendentController.deleteGreeting';
import saveTimePeriods from '@salesforce/apex/UcfAutoAttendentController.saveTimePeriods';
import ScheduleforAutoAttendantSetUp from '@salesforce/apex/UcfAutoAttendentController.ScheduleforAutoAttendantSetUp';
import getMultiPicklistValues from '@salesforce/apex/FetchData.getMultiPicklistValues';
import insertSchedule from '@salesforce/apex/FetchData.insertSchedule';
import isTranslationUser from '@salesforce/apex/PmEnrichmentController.isTranslationUser';
import getSavedTimePeriods from '@salesforce/apex/UcfAutoAttendentController.getSavedTimePeriods';
import saveTimePeriodsNew from '@salesforce/apex/UcfAutoAttendentController.saveTimePeriodsNew';
import deleteHolidayById from '@salesforce/apex/UcfAutoAttendentController.deleteHolidayById';
import insertHolidayName from '@salesforce/apex/ucf_PMErichment_MLHG_Schedule.insertHolidayName';
import updateHolidays from '@salesforce/apex/FetchDataMLHG.updateHolidays';






import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    refreshApex
} from '@salesforce/apex';
import ftrDIDNumberDetailsAutoAttendantsSetup from '@salesforce/apex/UcfAutoAttendentController.ftrDIDNumberDetailsAutoAttendantsSetup';
import updateAaSetupData from '@salesforce/apex/UcfAutoAttendentController.updateAaSetupData';
import ScheduleforAutoAttendantsSetUp from '@salesforce/apex/UcfAutoAttendentController.ScheduleforAutoAttendantsSetUp';
import addHoliDays from '@salesforce/apex/UcfAutoAttendentController.addHoliDays';
import updateSchedule from '@salesforce/apex/UcfAutoAttendentController.updateSchedule';
import getMenuLines from '@salesforce/apex/UcfAutoAttendentController.getMenuLines';
import getTimePeriodData from '@salesforce/apex/UcfAutoAttendentController.getTimePeriodData';
import updateMenuFields from '@salesforce/apex/UcfAutoAttendentController.updateMenuFields';
import saveMenuLines from '@salesforce/apex/UcfAutoAttendentController.saveMenuLines';
import getHolidaysBySchedule from '@salesforce/apex/FetchDataMLHG.getHolidaysBySchedule';




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


export default class AutoAttendentLWC extends LightningElement {

    menus;
    menuList = [];
    greetings;
    greetingsList = [];
    @api isnetworktranslation=false;
    @track greeting = {
        Id: '',
        Name: '',
        Message_Board__c: ''
    };
    @track greetId = '';
    @track greetName = '';
    @track greetMessage = '';
    @track holidaysGet;
    @track hasPastDateError = false;
     @track newHolidayName = '';
    @track showTable = false;
    schedules;
    @track schedulesCustomTime = [];
    scheduleList = [];
    schedule = [];
    @api recordId;
    delMenuId;
    delscheduleId;
    delGreetingId;
    RecdTypeId = 'Auto_Attendants';
    accounts;
    accounts2;
    error;
    value = '';
    selectedAccount = null;
    ftrDIDNumberDetailsAutoAttendants;
    schedule = [];
    @track additionalMessage = '';
    @track menuLines;
    @track showDualListboxModal = false;
    @track selectedItems = [];
    @track selectedItemsCount = 0;
    @track didId;
    @track length = 0;
    @track length2 = 0;
    @track selectedOption = '';
    @track employeeinfo = '';
    @track deviceinfo = '';
    @track nine11info = '';
    @track licenseinfo = '';
    @track accountList = [];
    @track picklistOptions = [];
    @track selectedValues = [];
    // @track scheduleName;\
    @track draftValues =[];
    @track scheduleName = '';
    @track greetingName = '';
    @track newMenuName = '';
    @track isEditMode = false;
    @track is247Expanded = false;
    @track isHolidayExpanded = false;
    @track isOpenExpanded = false;
    @track isClosedExpanded = false;
    @track isRadionYes = false;
    @track isShowCustomTimePeriods = false;
    @track isShowCustomTimePeriodslick = true;
    isModalOpen = false;
     isModalOpenTP = false;
    isMenuModalOpen = false;
    isModalOpenML = false;
    @track monday = 'Monday';
    @track menuId;
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
    @track menu247 = '';
     @track rb27Value = false;
     @track radioValue;
    @track menuOpen = '';
    @track menuClosed = '';
    @track menuHoliday ='';
    @track menuTP1 = '';
    @track menuTP2 = '';
    @track tpCustom1 = '';
    @track greetingML = '';
    @track tpCustom2 = '';
    @track isTabOneActive = true;
    @track isTabTwoActive = false;
    @track isTabThreeActive = false;
    @track originalTableRows = [];
    @track aadraftValues=[];
    @track schedulesForAA;
    @track greetingForML = '';
    @track newHolidayName = '';
    _wiredScheduleData;
    N11;
    showLoader = false;
    @track btnAdd1 = true;
    @track btnAdd2 = false;
    @track showCustomSch1 = false;
    @track showCustomSch2 = false;
    @track isClosedExpanded = false;
    @track selectedValueSchedule = '';
    @track selectedTime = '';
    @track isSch1 = false;
    @track isSch2 = false;
    @track overflowT24 = '';
    @track menuNametoUpdate = '';
    @track overflowD24 = '';
    @track overflowTOpen = '';
    @track overflowDOpen = '';
    @track modifiedTimePeriods = []
    @track modifiedTimePeriodsC2 = []
    originalTimePeriods = [];
    originalTimePeriodsC2 = [];
    @track holidays = [];
    @track holidays = [{
        name: '',
        date: '',
        ucf_Menu__c: ''
    }];
    @track menuOptions = [];
    @track menuOptions2 = [];
    @track menuOptionsForTP = [];

    @track greetingOptions = [];
    @track menuLineOptions = []; // Should be populated with picklist options for Destination_Info__c
    @track radioValue = 'No';
    @track ftrDIDNumberDetails = [];
    @track isTranslation;
    @track isReadOnly;
    @track radioOptions = [{

            label: 'Yes',
            value: 'Yes',
            key: 2
        },
        {
            label: 'No',
            value: 'No',
            key: 1
        }
    ];

    menuLineOptions = [{
            label: 'Transfer Number',
            value: 'Transfer Number'
        },
        {
            label: 'Transfer Voicemail',
            value: 'Transfer Voicemail'
        },
        {
            label: 'Go to Sub Menu',
            value: 'Go to Sub Menu'
        },
        {
            label: 'Announcement Return',
            value: 'Announcement Return'
        },
        {
            label: 'Announcement Hang Up ',
            value: 'Announcement Hang Up'
        },
        {
            label: 'Dial by Extension',
            value: 'Dial by Extension'
        },
        {
            label: 'Dial by Name',
            value: 'Dial by Name'
        },
        {
            label: 'Replay Menu',
            value: 'Replay Menu'
        },
        {
            label: 'Previous Menu',
            value: 'Previous Menu'
        },
        {
            label: 'Nothing',
            value: 'Nothing'
        }
    ];



    @track timeOptions = this.createTimeOptions();

    createTimeOptions() {
        const times = [
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
        return times.map(time => ({
            label: time,
            value: time
        }));
    }

    @track greetingOptions = [];
    fetchGreetings() {
        getGreetings()
            .then(result => {
                this.greetingOptions = result.map(greeting => {
                    return {
                        label: greeting.Name,
                        value: greeting.Id
                    };
                });
            })
            .catch(error => {
                console.error('Error retrieving greetings:', error);
            });
    }
    fieldChangeCount=0;

selectedTab = 'tab1'; // Default selected tab

    get isTab1Selected() {
        return this.selectedTab === 'tab1';
    }
    get isTab2Selected() {
        return this.selectedTab === 'tab2';
    }
    get isTab3Selected() {
        return this.selectedTab === 'tab3';
    }

    get isTab4Selected() {
        return this.selectedTab === 'tab4';
    }

    get tab1Class() {
        return this.isTab1Selected ? 'slds-button slds-button_neutral slds-is-active' : 'slds-button slds-button_neutral';
    }

    get tab2Class() {
        return this.isTab2Selected ? 'slds-button slds-button_neutral slds-is-active' : 'slds-button slds-button_neutral';
    }
      get tab3Class() {
        return this.isTab3Selected ? 'slds-button slds-button_neutral slds-is-active' : 'slds-button slds-button_neutral';
    }
      get tab4Class() {
        return this.isTab4Selected ? 'slds-button slds-button_neutral slds-is-active' : 'slds-button slds-button_neutral';
    }
  

    handleSelectTab(event) {
        //alert('here');
        this.isModalOpen= false;
        this.isModalOpenTP = false;
        this.selectedTab = event.currentTarget.dataset.name;
        this.loadSchedulesForCC();
        this.loadAutoAttendants();
        this.fetchMenus();
        this.fetchSchedulesForAASetup();
        
    }

    /*
        generateTimeOptions() {
            return Array.from({ length: 96 }, (_, index) => {
                const hour = Math.floor(index / 4).toString().padStart(2, '0');
                const minute = (index % 4) * 15;
                const timeLabel = `${hour}:${minute.toString().padStart(2, '0')}`;
                return { label: timeLabel, value: timeLabel };
            });
        }

    get timeOptions() {
            return this.timeOptionsData.map(time => ({ label: time, value: time }));
        }*/
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
    handleSorting(event){
        this.sortField = event.currentTarget.dataset.fieldName;
        this.sortDirection = this.sortField === this.sortField && this.sortDirection === 'asc' ? 'desc' : 'asc';
        if(this.sortField == 'GreetingName'){
            this.sortField = 'Name';
            this.sortGreetingData()
        }
        if(this.sortField == 'MenuName'){
            console.log(this.sortField)
            this.sortField = 'Name';
            this.sortByMenuName();
        }
        if(this.sortField == 'ScheduleName'){
            console.log(this.sortField)
            this.sortField = 'Name';
            this.sortByScheduleName();

        }
        else{
            this.sortData();
        }
    }
    // sortByPhoneNumber() {
    //     this.sortField = 'DIDNumber__c';
    //     this.sortDirection = this.sortField === 'DIDNumber__c' && this.sortDirection === 'asc' ? 'desc' : 'asc';
    //     this.sortData();
    // }
    // sortByExtension() {
    //     this.sortField = 'Ucf_Extension__c';
    //     this.sortDirection = this.sortField === 'Ucf_Extension__c' && this.sortDirection === 'asc' ? 'desc' : 'asc';
    //     this.sortData();
    // }
    // sortByName() {
    //     this.sortField = 'MLHG_Name__c';
    //     this.sortDirection = this.sortField === 'MLHG_Name__c' && this.sortDirection === 'asc' ? 'desc' : 'asc';
    //     this.sortData();
    // }
    // sortBySchedule() {
    //     this.sortField = 'Schedule__c';
    //     this.sortDirection = this.sortField === 'Schedule__c' && this.sortDirection === 'asc' ? 'desc' : 'asc';
    //     this.sortData();
    // }
    // sortByEASPin() {
    //     this.sortField = 'EAS_Pin__c';
    //     this.sortDirection = this.sortField === 'EAS_Pin__c' && this.sortDirection === 'asc' ? 'desc' : 'asc';
    //     this.sortData();
    // }

    sortDataSm(data, fieldName, sortDirection) {
        // Copy the data to a new array for sorting
        let sortedData = [...data];

        // Determine the sorting order
        let sortOrder = sortDirection === 'asc' ? 1 : -1;

        // Sort the data based on the field name and sort order
        sortedData.sort((a, b) => {
            // Handle null or undefined values to avoid errors during sort
            let valueA = a[fieldName] == null ? '' : a[fieldName].toLowerCase();
            let valueB = b[fieldName] == null ? '' : b[fieldName].toLowerCase();

            // Compare the values and multiply by sortOrder to switch between ascending and descending
            return valueA < valueB ? -1 * sortOrder : (valueA > valueB ? 1 * sortOrder : 0);
        });

        return sortedData;
    }


    sortData() {
        const field = this.sortField;
        const reverse = this.sortDirection === 'desc' ? -1 : 1;
        this.ftrDIDNumberDetailsAutoAttendants = [...this.ftrDIDNumberDetailsAutoAttendants.sort((a, b) => (a[field] > b[field] ? 1 : -1) * reverse)];
    }

    sortGreetingData() {
        const field = this.sortField;
        const reverse = this.sortDirection === 'desc' ? -1 : 1;
        this.greetingsList = [...this.greetingsList.sort((a, b) => (a[field] > b[field] ? 1 : -1) * reverse)];
        this.greetings = this.greetingsList;
    }

    sortByMenuName() {
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        console.log(JSON.stringify(this.menus));

        this.menus = [...this.menus].sort((a, b) => {
            const nameA = a.Name ? a.Name.toLowerCase() : '';
            const nameB = b.Name ? b.Name.toLowerCase() : '';
            return this.sortDirection === 'asc' ? nameA.localeCompare(nameB) : nameB.localeCompare(nameA);
        });
        console.log(JSON.parse(JSON.stringify(this.menus)));

    }

    sortMenuData() {
        const field = this.sortField;
        console.log(JSON.parse(JSON.stringify(this.menuList)));
        const reverse = this.sortDirection === 'desc' ? -1 : 1;
        this.menuList = [...this.menuList.sort((a, b) => (a[field] > b[field] ? 1 : -1) * reverse)];
        this.menus = this.menuList;

    }
    sortByScheduleName() {
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        console.log(JSON.parse(JSON.stringify(this.schedules)));
        this.schedules = [...this.schedules].sort((a, b) => {
            const nameA = a.UCF_Name__c ? a.UCF_Name__c.toLowerCase() : '';
            const nameB = b.UCF_Name__c ? b.UCF_Name__c.toLowerCase() : '';
            return this.sortDirection === 'asc' ? nameA.localeCompare(nameB) : nameB.localeCompare(nameA);
        });
    }

    sortScheduleData() {

        const field = this.sortField;
        console.log(JSON.parse(JSON.stringify(this.scheduleList)));
        const reverse = this.sortDirection === 'desc' ? -1 : 1;
        this.scheduleList = [...this.scheduleList.sort((a, b) => (a[field] > b[field] ? 1 : -1) * reverse)];
        this.schedules = this.scheduleList;

    }
    @wire(queryAccounts)
    wiredAccounts(wireResult) {
        const {
            data,
            error
        } = wireResult;
        this._wiredMarketData = wireResult;
        if (data) {
            this.accounts = data;
            this.wiredResult = data;
        } else if (error) {
            this.error = error;
        }
    }


    loadSchedulesForCC() {
        queryschedules({
                orderId: this.recordId
            })
            .then(result => {
                //alert(JSON.stringify(result));
                // Assuming sortDataSm is a method in your component
                this.schedules = this.sortDataSm(result, 'UCF_Name__c', this.sortDirection);
                // You can handle the result here
            })
            .catch(error => {
                this.error = error;
                // Handle any errors here
            });
    }


    fetchSchedulesForAASetup() {
        queryschedulesForAA({ orderId: this.recordId })
            .then(data => {
                this.schedulesForAA = [{
                        label: 'Select Schedules',
                        value: ''
                    },
                    ...data.map(item => ({
                        label: item.UCF_Name__c, // Replace with your actual field name for label
                        value: item.Id // Replace with your actual field name for value
                    }))
                ];
            })
            .catch(error => {
                this.error = error;
            });
    }



/*
    @wire(queryschedulesForAA, {
        orderId: '$recordId'
    })
    wiredSchForAA(wireResult) {
        this._wiredScheduleData = wireResult;
        const {
            data,
            error
        } = wireResult;
        if (data) {
            alert(JSON.stringify(this.schedulesForAA ));
            // Prepend the "Select" option to the schedulesForAA array
            this.schedulesForAA = [{
                    label: 'Select Schedules',
                    value: ''
                }, // Add your static option
                ...data.map(item => ({
                    label: item.UCF_Name__c, // Replace with your actual field name for label
                    value: item.Id // Replace with your actual field name for value
                }))
            ];
        } else if (error) {
            this.error = error;
        }
    } */


    /*
    @wire(getMenuLines)
    wiredMenuLines({
        error,
        data
    }) {
        if (data) {
            // Create a deep copy of the data to make it mutable
            this.menuLines = JSON.parse(JSON.stringify(data));
            console.log('menu lines: ' + JSON.stringify(this.menuLines));
            alert('menu lines: ' + JSON.stringify(this.menuLines));
        } else if (error) {
            console.error('Error fetching menu lines:', error);
            // Handle error, possibly by showing a toast message to the user
        }
    } */

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
          //alert('Ro '+ this.isReadOnly);
          //alert('Tra '+ this.isTranslation);
        } else if (error) {
            console.error("Error determining user profile:", error);
        }
    } 

    @wire(queryAccounts2)
    wiredAccounts2({
        error,
        data
    }) {
        // alert(data);
        if (data) {
            // this.accounts2 = data;
            this.accounts2 = data.map(account => ({
                ...account,
                selectedItems: [],
                selectedItemsCount: 0,
            }));
            //  this.wiredResult = data;
            console.log('accounts field', this.accounts2);

        } else if (error) {
            this.error = error;
        }
    }




    @wire(getMultiPicklistValues, {
        YourObjectName: 'Account',
        YourFieldName: 'vlocity_cmt__ContactPreferences__c'
    })
    wiredMultiPicklistValues({
        error,
        data
    }) {
        if (data) {
            console.log('data', data);
            this.picklistOptions = data.map(option => ({
                label: option,
                value: option
            }));
            //this.picklistOptions = data;
            console.log('picklistOptions', this.picklistOptions);
        } else if (error) {
            console.error(error);
        }
    }
    deleteGreeting(event) {

        console.log('Delete button clicked');
        const abc = event.currentTarget.dataset;

        const itemId = event.currentTarget.dataset.itemId;
        const itemIndex = event.currentTarget.dataset.itemIndex;

        console.log('Item ID:', itemId);
        console.log('Index:', itemIndex);
        const updatedAccounts = [...this.greetings];

        this.delGreetingId = event.currentTarget.dataset.itemId;
        deleteGreeting({
                greetingId: this.delGreetingId
            })
            .then(result => {
                this.showToast('Deleted', result, 'success');
                console.log('Delete  function');
                return refreshApex(this._wiredMarketData);
            })
            .catch(error => {
                const errorMessage = error.body && error.body.message ? error.body.message : 'An error occurred';
                this.showToast('Error', errorMessage, 'error');
            });
        /* if (itemId && itemIndex !== undefined) {
            this.accounts.splice(itemIndex, 1); 
        }
        if (itemIndex !== -1) {
            this.accounts.splice(itemIndex, 1);
        }*/

        if (itemIndex !== undefined) {
            updatedAccounts.splice(itemIndex, 1);
            this.greetings = updatedAccounts;
        }


    }

    delSchedule(event) {

        console.log('Delete button clicked');
        const abc = event.currentTarget.dataset;

        const itemId = event.currentTarget.dataset.itemId;
        const itemIndex = event.currentTarget.dataset.itemIndex;

        console.log('Item ID:', itemId);
        console.log('Index:', itemIndex);
        // const updatedAccounts = [...this.accounts];
        this.delscheduleId = event.currentTarget.dataset.itemId;
        deleteSchedule({
                scheduleId: this.delscheduleId
            })
            .then(result => {
                this.showToast('Deleted', result, 'success');
                console.log('Delete  function');
                return refreshApex(this._wiredScheduleData);
            })
            .catch(error => {
                const errorMessage = error.body && error.body.message ? error.body.message : 'An error occurred';
                this.showToast('Error', errorMessage, 'error');
            });

        const updatedAccounts = [...this.schedules];
        /* if (itemId && itemIndex !== undefined) {
            this.accounts.splice(itemIndex, 1); 
        }
        if (itemIndex !== -1) {
            this.accounts.splice(itemIndex, 1);
        }*/

        if (itemIndex !== undefined) {
            updatedAccounts.splice(itemIndex, 1);
            this.schedules = updatedAccounts;
        }


    }

   /* loadHolidays() {
        getHolidaysByScheduleId({
                scheduleId: this.schId
            })
            .then(result => {
                this.holidays = result;
            })
            .catch(error => {
                console.error('Error fetching holidays:', error);
            });
    } */
    loadHolidays() {
        getHolidaysBySchedule({ scheduleId: this.schId })
            .then(result => {
                this.holidaysGet = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.holidaysGet = undefined;
            });
    }

     handleHolidayNameChange(event) {
      this.newHolidayName = event.target.value;
       //alert('here '+  this.schedule );
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
   handleHolidayDateChange(event) {
          console.log('here');
         // alert('alert');
        let holidayId = event.target.dataset.id;
        let newDatetocheck = new Date(event.target.value);
        let newDate = event.target.value;
        let today = new Date();
        today.setHours(0, 0, 0, 0);
       // alert('New ' + newDate);
        //alert('today ' + today);

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

        //alert(JSON.stringify(holiday));
         //alert(JSON.stringify( this.holidaysGet));
    }


saveHolidayChanges() {
//alert(JSON.stringify(this.holidaysGet));   
 updateHolidays({ holidays: this.holidaysGet })
        .then(result => {

        })
        .catch(error => {
        });
}

    toggleEditMode(event) {
        //alert('Edit Clicked');
        this.didId = event.currentTarget.dataset.itemId;
        // alert(this.didId);
        const itemId = event.currentTarget.dataset.itemId;
        this.schId = itemId;
        this.isModalOpen = true;
        this.isEditMode = !this.isEditMode;

        if (this.schId) {
            this.loadHolidays();// load holidays
            this.loadSchedules();// load time period
        }

        const schedule = this.schedules.find(schedule => schedule.Id === this.schId);
        //alert(JSON.stringify(schedule));
        if (schedule) {
            // Toggle edit mode and populate the fields for editing
            this.isModalOpen = true;
            this.isEditMode = true;
            this.isRadionYes = schedule.X247_checkbox__c;
            this.radioValue = schedule.X247_checkbox__c? 'Yes' : 'No';
            console.log('check radioVValue on load '+  this.radioValue);
            console.log('check rb value on load '+  this.isRadionYes);
            this.rb27Value = schedule.X247_checkbox__c;
            this.menu247 =  schedule.Ucf_Men_24_7__c;
            this.menuClosed =  schedule.Ucf_Menu_Close__c;
            this.menuHoliday = schedule.Menu_Holiday__c;  
            this.menuOpen =  schedule.Ucf_Menu_Open__c;
            this.overflowT24 = schedule.Overflow_Timer_24_7__c;
            this.overflowD24 = schedule.Overflow_Destination_24_7__c;
            this.overflowTOpen = schedule.Overflow_Timer_Open__c;
            this.overflowDOpen = schedule.Overflow_Destination_Open__c;
            this.overflowTClose = schedule.Overflow_Timer_Closed__c;
            this.overflowDClose = schedule.Overflow_Destination_Closed__c;
            this.holidayName = schedule.Holiday__c;
            this.holidayDate = schedule.Holiday_Date__c;
            this.mondayStartTime = schedule.Monday_Start_Time__c;
            this.mondayEndTime = schedule.Monday_End_Time__c;
            this.tuesdayStartTime = schedule.Tuesday_Start_Time__c;
            this.tuesdayEndTime = schedule.Tuesday_End_Time__c;
            this.wednesdayStartTime = schedule.Wednesday_Start_Time__c;
            this.wednesdayEndTime = schedule.Wednesday_End_Time__c;
            this.thursdayStartTime = schedule.Thursday_Start_Time__c;
            this.thursdayEndTime = schedule.Thursday_End_Time__c;
            this.fridayStartTime = schedule.Friday_Start_Time__c;
            this.fridayEndTime = schedule.Friday_End_Time__c;
            this.saturdayStartTime = schedule.Saturday_Start_Time__c;
            this.saturdayEndTime = schedule.Saturday_End_Time__c;
            this.sundayStartTime = schedule.Sunday_Start_Time__c;
            this.sundayEndTime = schedule.Sunday_End_Time__c;
           

            console.log('menu closed '+  this.menuClosed);
             console.log('menu 247 '+  this.menu247);


        } else {
            // Handle the case where the schedule is not found
            console.error('Schedule not found');
        }
        this.isModalOpen = true;
        this.isEditMode = !this.isEditMode;

        if (this.didId) {
            getTimePeriodData({
                    didId: this.didId
                })
                .then(result => {
                 
                    this.timePeriodLines = result.map(item => ({
                        Id: item.Id,
                        name: item.Name, // Assuming 'Name' is the correct property for Schedule Time Period
                        menuName: item.Menu__r ? item.Menu__r.Name : '', // Navigate the relationship if it exists
                        greeting: item.Menu__r ? item.Menu__r.Greeting__c : '' // Directly use the Greetingc
                    }));
                    console.log(JSON.stringify(this.timePeriodLines)); // Use console.log for debugging
                      this.isModalOpenTP = true;
                })
                .catch(error => {
                    // Handle any errors that occur during the fetch
                    console.error('Error fetching time period data:', error);
                });
        }
    }

    closeModal() {
        this.isModalOpen = false;
    }

    

     closeModalTP() {
        this.isModalOpenTP = false;
    }



    toggleSection(event) {
        const section = event.currentTarget.dataset.id;

        if (section === '24/7') {
            this.is247Expanded = !this.is247Expanded;
        } else if (section === 'Holiday') {
            this.isHolidayExpanded = !this.isHolidayExpanded;
        } else if (section === 'Open') {
            this.isOpenExpanded = !this.isOpenExpanded;
        } else if (section === 'Closed') {
            this.isClosedExpanded = !this.isClosedExpanded;
        }
    }

    addScheduleRow() {
        //alert(this.scheduleName);

        if (!this.scheduleName) {
            console.log(this.schedule);
            this.showToast('Error', 'Schedule name cannot be empty', 'error');
            return;
        }
        
         const getSch = this.scheduleName.trim().toLowerCase(); // Convert input to lower case
    if (this.schedules.some(schd => schd.UCF_Name__c.toLowerCase() === getSch)) {
        this.showToast('Error','This Schedule name already exists.','error');
        return;
    }

        /*
        const getSch = this.scheduleName.trim();
        if (this.schedules.some(schd => schd.UCF_Name__c === getSch)) {
            this.showToast('Error', 'This Schdule name already exists.', 'error');
            return;
        }*/

        insertScheduleRec({
                scheduleName: this.scheduleName,
                orderId: this.recordId,
                RecordTypeId: this.RecdTypeId
            })
            .then(result => {
                this.fieldChangeCount=0;
                this.notifyInputChange(this.fieldChangeCount);
                //console.log("Schedule created"+result);
                if (result === 'Schedule Created Succesfully') {
                    this.showToast('Success', result, 'success');
                    this.loadSchedulesForCC();
                } else {
                    this.showToast('Error', result, 'Error');
                }
                this.scheduleName = '';

                // Refresh the table
                // return refreshApex(this._wiredScheduleData);
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




    get columns() {
        return columns;
    }

    get options1() {
        return [{
                label: 'Yes',
                value: 'Yes'
            },
            {
                label: 'No',
                value: 'No'
            },
        ];
    }

    get options2() {
        return [{
                label: '3 digits',
                value: '3 digits'
            },
            {
                label: '4 digits',
                value: '4 digits'
            },
            {
                label: '5 digits',
                value: '5 digits'
            },
            {
                label: '7 digits',
                value: '7 digits'
            },
        ];
    }
    value = 'Employee Info';
    get options3() {
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
        ];
    }

    handleComboboxChange(event) {
        this.selectedOption = event.detail.value;
        if (this.selectedOption === 'Employee Info') {
            this.employeeinfo = this.selectedOption;
            this.nine11info = false;
            this.deviceinfo = false;
            this.licenseinfo = false;
        } else if (this.selectedOption === 'Device Info') {
            this.deviceinfo = this.selectedOption;
            this.employeeinfo = false;
            this.nine11info = false;
            this.licenseinfo = false;
        } else if (this.selectedOption === 'License Info') {
            this.licenseinfo = this.selectedOption;
            this.deviceinfo = false;
            this.employeeinfo = false;
            this.nine11info = false;
        } else if (this.selectedOption === '911 Info') {
            this.nine11info = this.selectedOption;
            this.deviceinfo = false;
            this.employeeinfo = false;
            this.licenseinfo = false;
        }

    }

  /*  handleChange(event) {
        //this.rb27Value = event.detail.value;
    }*/

    openDualListbox(event) {
        // const rowIndex = event.target.getAttribute('data-row-index');
        //const row = this.data[rowIndex];
        const rowIndex = event.target.getAttribute('data-row-index');
        console.log('rowIndex', this.rowIndex);
        if (rowIndex >= 0 && rowIndex < this.accounts2.length) {
            this.selectedAccount = this.accounts2[rowIndex]; // Store the account being edited
            this.showDualListboxModal = true;
            console.log('selectedAccount', this.selectedAccount);
        }
        this.showDualListboxModal = true;
    }
    closeDualListbox() {
        this.showDualListboxModal = false;
    }
    saveDualListbox() {
        this.showDualListboxModal = false;
        this.selectedAccount.selectedItemsCount = this.length;
    }


    handleCancel() {

        this.isModalOpen = false;
        this.holidays = [];
    }




    handleChangeDualListboxModal(event) {
        this.selectedItems = event.detail.value;
        this.length = this.selectedItems.length;
        console.log('length', this.length);
        const selectedIndex = this.rowIndex;

        /*  this.accounts2 = this.accounts2[selectedIndex].map(account => ({
                ...account,
                selectedItemsCount : this.length
            }));*/

        //this.selectedAccount.selectedItemsCount= this.length;

        console.log('selected items', this.accounts2.selectedItemsCount);
        console.log('accounts2', this.accounts2);

        /*  if (this.selectedAccount) {
                this.selectedAccount.selectedItems = event.detail.value; // Update the selected items for the specific account
                this.selectedAccount.selectedItemsCount = this.selectedAccount.selectedItems.length;
            }*/

    }

    //////////////////////////////////////////////////////////////////////////////
    /////////////////////////Menu/////////////////////////////////////////////////

    /////////////////////////Menu/////////////////////////////////////////////////
    handleMenuNameChange(event) {
        this.fieldChangeCount++;
        this.notifyInputChange(this.fieldChangeCount);
        this.newMenuName = event.target.value;

    }
  fetchMenus() {
        menusforAutoAttendants({ orderId: this.recordId })
            .then(data => {
                this.processMenus(data);
            })
            .catch(error => {
                this.error = error;
            });
    }

    processMenus(data) {
        // alert(JSON.stringify(data)); // Corrected
        let sortedData = this.sortDataSm(data, 'Name', this.sortDirection);
        this.menuOptions = data.map(menu => ({
            label: menu.Name,
            value: menu.Name
        }));
        this.menuOptions2 = data.map(menu => ({
            label: menu.Name,
            value:  menu.Name
        }));
        this.menuOptionsForTp = data.map(menu => ({
            label: menu.Name,
            value: menu.Id
        }));
        this.MenueList = data.map(record => ({
            ...record
        }));
        this.menus = sortedData; // Use the sorted data
        console.log(JSON.stringify(this.menuOptions2));
        // alert(JSON.stringify(this.menus));
    }

    // Include your sortDataSm function here
  /*  sortDataSm(data, fieldName, sortDirection) {
        // Sorting logic goes here
    } */
    addMenuRow() {
        if (!this.newMenuName) {
            this.showToast('Error', 'Menu name cannot be empty', 'error');
            return;
        }

        const trimmedMenuName = this.newMenuName.trim().toLowerCase();
        if (this.menus.some(menu => menu.Name.toLowerCase() === trimmedMenuName)) {
            this.showToast('Error', 'This menu name already exists.', 'error');
            return;
        }


        insertMenus({
                menuName: this.newMenuName,
                orderId: this.recordId
            })
            .then(result => {
                this.fieldChangeCount=0;
            this.notifyInputChange(this.fieldChangeCount);
                //console.log("Schedule created"+result);
                if (result === 'Menu Created Succesfully') {
                    this.showToast('Success', result, 'success');
                } else {
                    this.showToast('success', result, 'success');
                }
                this.newMenuName = '';

                // Refresh the table
                //return refreshApex(this._wiredMarketData);
                this.fetchMenus();
            })
            .catch(error => {
                const errorMessage = error.body && error.body.message ? error.body.message : 'An error occurred';
                this.showToast('Error', errorMessage, 'error');
            });
    }

    delMenu(event) {

        console.log('Delete button clicked');
        const abc = event.currentTarget.dataset;

        const itemId = event.currentTarget.dataset.itemId;
        const itemIndex = event.currentTarget.dataset.itemIndex;

        console.log('Item ID:', itemId);
        console.log('Index:', itemIndex);
        // const updatedAccounts = [...this.accounts];
        this.delMenuId = event.currentTarget.dataset.itemId;
        deleteMenus({
                menuId: this.delMenuId
            })
            .then(result => {
                this.showToast('Deleted', result, 'success');
                console.log('Delete  function');
                return refreshApex(this._wiredMarketData);
            })
            .catch(error => {
                const errorMessage = error.body && error.body.message ? error.body.message : 'An error occurred';
                this.showToast('Error', errorMessage, 'error');
            });

        const updatedAccounts = [...this.menus];
        /* if (itemId && itemIndex !== undefined) {
            this.accounts.splice(itemIndex, 1); 
        }
        if (itemIndex !== -1) {
            this.accounts.splice(itemIndex, 1);
        }*/

        if (itemIndex !== undefined) {
            updatedAccounts.splice(itemIndex, 1);
            this.menus = updatedAccounts;
        }
    }
    toggleEditMenu(event) {
        this.menuId = event.currentTarget.dataset.itemId;
     
        this.isEditMode = !this.isEditMode;

        const menu = this.menus.find(m => m.Id === this.menuId);
        if (menu) {
            this.menuNametoUpdate = menu.Name;
            //alert(this.menuNametoUpdate);
            this.greetingML = menu.Greeting__c;
            let menuNametoUpdate = this.menuNametoUpdate;
            this.menuOptions2 = this.menuOptions2.filter(menuOption => menuOption.value !== menuNametoUpdate);
            // alert('menu op '+ JSON.stringify(this.menuOptions2 ));


            console.log('ML '+ this.greetingML);
        }

        if (this.menuId) {
            //alert('ccc');
           this.fetchMenuLines();  
           this.isModalOpen = true  
            
        }

       // this.menuOptions2 = this.menuOptions2.filter(option => option.value !== this.menuId);
        
        //console.log('menuOptions2'+ JSON.stringify(this.menuOptions2));
       
    }


    fetchMenuLines() {
        // alert('aaaaaa ');
        getMenuLines({
                menuId: this.menuId
            })
            .then(result => {
                

                this.menuLines = result.map(line => {
                    // Determine if the line is for a submenu
                    const isSubMenuEditable = line.Options__c === 'Go to Sub Menu';

                    // Determine if the line is for destination info
                    const isDestinationInfoEditable = line.Options__c === 'Transfer Number';


                    return {
                        ...line,
                        isSubMenuEditable,
                        isDestinationInfoEditable,
                    };
                });
                 //alert('aaa '+ JSON.stringify(this.menuLines));
            })
            .catch(error => {
                console.error('Error fetching menu lines:', error);
            });
    }

    //////////////////////////////////////////////////////////////////////////////
    /////////////////////////Greeting/////////////////////////////////////////////////

    @wire(greetingsforAutoAttendantsGreetings, {
        orderId: '$recordId'
    })
    wiredGreetings(wireResult) {
        const {
            data,
            error
        } = wireResult;
        this._wiredGreetingData = wireResult;
        if (data) {
            this.greetingsList = data.map(record => ({
                ...record
            }));

            this.greetings = data;

            this.greetingOptions = data.map(greetings => ({
                label: greetings.Name,
                value: greetings.Name
            }));
            console.log('this.greetings' + this.greetings);
            this.wiredResult = data;
        } else if (error) {
            this.error = error;
        }
    }

    handleGreetingModalCancel() {

        this.isModalOpen = false;
    }

    handleGreetingModalSave() {
        console.log(this.greet);
        updateGreeting({
                greetingrec: this.greeting
            })
            .then(result => {
                // Handle the result from the Apex method
                if (result === 'Greeting Updated Successfully') {

                    this.isModalOpen = false;

                    this.showToast('Success', result, 'success');
                    this.greeting.Id = '';
                    this.greeting.Name = '';
                    this.greeting.Message_Board__c = '';

                } else {
                    this.showToast('Error', result, 'Error');
                }
                console.log(result);

                return refreshApex(this._wiredGreetingData);
            })
            .catch(error => {
                const errorMessage = error.body && error.body.message ? error.body.message : 'An error occurred';
                this.showToast('Error', errorMessage, 'error');
            });
        // alert('After refreshApex');

        const updatedAccounts = [...this.greetings];
    }


    toggleEditGreetings(event) {

        const itemId = event.currentTarget.dataset.itemId;
        greetingforEdit({
                greetingId: itemId
            })
            .then(result => {

                this.greeting.Id = result.Id;
                this.greeting.Name = result.Name;
                this.greeting.Message_Board__c = result.Message_Board__c;
                this.isModalOpen = true;
                this.isEditMode = !this.isEditMode;
                console.log(this.isModalOpen);
                console.log('this.greeting.Name ' + this.greeting.Name);
                console.log('this.greeting.Message_Board__c ' + this.greeting.Message_Board__c);

            })
            .catch(error => {
                // Handle the error

                const errorMessage = error.body && error.body.message ? error.body.message : 'An error occurred';
                this.showToast('Error', errorMessage, 'error');
            });
    }

    handleGreetingNameChange(event) {
        this.fieldChangeCount++;
        this.notifyInputChange(this.fieldChangeCount);
        this.greetingName = event.target.value;
    }
    editGreetingName(event) {
        this.greeting.Name = event.target.value;
    }
    editGreetingMessage(event) {
        this.greeting.Message_Board__c = event.target.value;
    }
    addGreetingRow() {
        if (!this.greetingName) {
            this.showToast('Error', 'Greeting name cannot be empty', 'error');
            return;
        }


       /* const getGreeting = this.greetingName.trim();
        if (this.greetings.some(greeting => greeting.Name === getGreeting)) {
            this.showToast('Error', 'This greeting name already exists.', 'error');
            return;
        }*/


        const getGreeting = this.greetingName.trim().toLowerCase(); 
        if (this.greetings.some(greeting => greeting.Name.toLowerCase() === getGreeting)) {
            this.showToast('Error', 'This greeting name already exists.', 'error');
            return;
        }

        insertGreeting({
                greetingName: this.greetingName,
                orderId: this.recordId
            })
            .then(result => {
                this.fieldChangeCount=0;
            this.notifyInputChange(this.fieldChangeCount);
                //console.log("Schedule created"+result);
                if (result === 'Greeting Created Succesfully') {
                    this.showToast('Success', result, 'success');
                } else {
                    this.showToast('Error', result, 'Error');
                }
                this.greetingName = '';

                // Refresh the table
                return refreshApex(this._wiredGreetingData);
            })
            .catch(error => {
                const errorMessage = error.body && error.body.message ? error.body.message : 'An error occurred';
                this.showToast('Error', errorMessage, 'error');
            });
    }


    //////////////////////////////////////////////////////////////////////////////
    /////////////////////////AA Setup/////////////////////////////////////////////////

    @wire(ScheduleforAutoAttendantSetUp, {
        orderId: '$recordId'
    })
    wiredScheduleforAutoAttendantSetUp({
        error,
        data
    }) {
        if (data) {
            console.log('Data from Apex:', data);
            this.schedule = data.map(option => ({
                label: option.UCF_Name__c,
                value: option.Id
            }));
            this.scheduleList = data;

            console.log('Mapped Schedule:', this.schedule);
        } else if (error) {
            console.error('Error from Apex:', error);
            this.error = error;
        }
    }

   
    connectedCallback() {
        this.showLoader=true;
        this.loadAutoAttendants();
        this.fetchSchedulesForAASetup();
        this.loadSchedulesForCC();
        this.fetchMenus();
       
    }



    loadAutoAttendants() {
        ftrDIDNumberDetailsAutoAttendantsSetup({
                orderId: this.recordId
            })
            .then(result => {
                this.ftrDIDNumberDetailsAutoAttendants = result.map(ftr_DID_Number_Details__c => {
                    let extLength = parseInt(ftr_DID_Number_Details__c.Ucf_Extension_Lenght__c);
                    console.log('extLength ' + extLength);
                    this.length2 = extLength;
                    let ext = ftr_DID_Number_Details__c.DIDNumber__c.slice(-extLength);
                    let N11 = ext.slice(-2);
                    console.log('ext ' + ext);

                    return {
                        ...ftr_DID_Number_Details__c,
                        editMode: true,
                        N11: N11 == '11' ? true : false,
                        slicedExtension: ext,
                        Ucf_Extension__c: ftr_DID_Number_Details__c.Ucf_Extension__c,
                        EAS_Pin__c: ftr_DID_Number_Details__c.EAS_Pin__c || '',
                        ucf_Auto_Attendent_Name__c: ftr_DID_Number_Details__c.ucf_Auto_Attendent_Name__c || '',
                    };
                });
              if(this.ftrDIDNumberDetailsAutoAttendants.length > 0){
                 this.showTable = true;
                 }

               this.showLoader=false;
            })
            .catch(error => {
                this.error = error;
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

  
    handleInputChange_AA(event) {
        this.fieldChangeCount++;
        this.notifyInputChange(this.fieldChangeCount);
        const recordId = event.target.dataset.recordId;
        const fieldName = event.target.dataset.fieldName;
        const newValue = event.target.value;
        console.log('reocrd id', recordId);
        console.log(fieldName);
        console.log(newValue);
        this.N11=false;

             

        const index = this.ftrDIDNumberDetailsAutoAttendants.findIndex(ftrDIDNumberDetail => ftrDIDNumberDetail.Id === recordId);
        console.log('index : ' + index);
        if (index !== -1) {
            // Update the field value in the account data
            this.ftrDIDNumberDetailsAutoAttendants[index][fieldName] = newValue;
            console.log('New value : ' + newValue);
            // Create an object to store the updated data
            const updatedData = {
                Id: recordId,
                [fieldName]: newValue
            };
            console.log('updatedData : ' + JSON.stringify(updatedData));


            // Check if the record is already in draftValues and update it
            console.log('OUTPUT : ',JSON.stringify(this.aadraftValues));
            const draftIndex = this.aadraftValues.findIndex(draft => draft.Id === recordId);
            if (draftIndex !== -1) {
                this.aadraftValues[draftIndex][fieldName] = newValue;
            } else {
                // If the record is not in draftValues, add it
                this.aadraftValues.push(updatedData);
            }
            console.log('Final updated data ' + JSON.stringify(updatedData));
            console.log('Final updated data ' + JSON.stringify(this.aadraftValues));
            // alert(JSON.stringify(this.draftValues));
        }
        if (fieldName === 'Ucf_Extension__c') {
            // Check for duplicate Ucf_Extension__c entry
            if (event.target.value !== '') {
                const isDuplicate = this.ftrDIDNumberDetailsAutoAttendants.some(detail =>
                    detail.Ucf_Extension__c === newValue && detail.Id !== recordId
                );

               /* if (isDuplicate) {
                    // Alert the user that the webinar value is already selected
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Duplicate Extension',
                            message: 'Please enter an unique Extension',
                            variant: 'error'
                        })
                    );
                    return;
                } */
            }
        }
     /*   if (fieldName === 'ucf_Auto_Attendent_Name__c') {
            // Check for duplicate ucf_Auto_Attendent_Name__c entry
            if (event.target.value !== '') {
                const isDuplicate = this.ftrDIDNumberDetailsAutoAttendants.some(detail =>
                    detail.ucf_Auto_Attendent_Name__c === newValue && detail.Id !== recordId
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
        }*/
    }

    handleAdd1() {
        //alert('Add 1');
        this.isSch1 = true;
        this.btnAdd1 = false;
        this.btnAdd2 = true;
    }

    aaSetuphandleCancel() {
        this.loadAutoAttendants();
        this.fieldChangeCount=0;
        this.notifyInputChange(this.fieldChangeCount);
    }
    checkValueExists(idToCheck) {
      
        return this.aadraftValues.some(obj => obj.Id === idToCheck);
    }
    checkValueExistsArray(idToCheck,ArrayToCheck) {
        console.log('Checking:', idToCheck);

        return ArrayToCheck.some(obj => obj.Id === idToCheck);
    } 
    async aaSetuphandleSave() {
    try {
        this.showLoader = true; // Show loader before making the call
        
        // Call the Apex method and wait for the response
        const result = await ftrDIDNumberDetails({ recordId: this.recordId });
        
        // Update the state with the received data
        if (result) {
            this.ftrDIDNumberDetails = result;    
            let isValidationFailed = false;

            this.ftrDIDNumberDetailsAutoAttendants.forEach(detail =>{
            //alert(detail.EAS_Pin__c.length);
            //console.log('hello test', detail.EAS_Pin__c.toString().length);
            //alert(this.isTranslation); //true
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
    let Duplicate=false;
    let ExtChanged=false;
    
    /***** Checking duplicate Ext with in the order when Ext is changed manually */
    
    console.log('Debug::1779'+JSON.stringify(this.aadraftValues));
    this.aadraftValues.forEach(draft=>{
                         if (draft.Ucf_Extension__c) {
                         ExtChanged=true;
                         const isDuplicateExtension= this.aadraftValues.some(detail =>
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
                                 detail.Ucf_Extension__c === draft.Ucf_Extension__c && detail.Id !== draft.Id && this.checkValueExistsArray(detail.Id,this.aadraftValues) == false 
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
                        this.ftrDIDNumberDetailsAutoAttendants.forEach(draft => {
                        
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
                if((Duplicate == false && this.aadraftValues.length == 0) || (Duplicate == false && this.aadraftValues.length !== 0 && ExtChanged == false)) 
                {
                    this.ftrDIDNumberDetailsAutoAttendants.forEach(draft => {
                    if (draft.Ucf_Extension__c) {
                        const isDuplicateExtension = this.ftrDIDNumberDetails.some(detail =>
                            detail.Ucf_Extension__c === draft.Ucf_Extension__c && detail.Id !== draft.Id
                        );

                        if (isDuplicateExtension) {
                            console.log('Duplicate when no change in Ext or change in other fields with in or out side AA');
                            Duplicate=true;
                            isValidationFailed = true;
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

this.aadraftValues.forEach(draft => {
        if (draft.ucf_Auto_Attendent_Name__c) {
            const isDuplicateExtension = this.ftrDIDNumberDetailsAutoAttendants.some(detail =>
                detail.ucf_Auto_Attendent_Name__c.toLowerCase() === draft.ucf_Auto_Attendent_Name__c.toLowerCase() && detail.Id !== draft.Id
            );
 
            if (isDuplicateExtension) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Duplicate Name',
                        message: 'Please enter a unique Name.',
                        variant: 'error'
                    })
                );
                isValidationFailed = true;
                return;
            }
        }
    });
                console.log('ext a '+parseInt(detail.Ucf_Extension__c).toString().length);
                console.log('ext2 b'+ this.length2);

                 let lengthOfExtension = parseInt(detail.Ucf_Extension_Lenght__c);

                if(detail.Ucf_Extension__c.toString().length < lengthOfExtension)
                {
                   this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Length Error',
                                    message: 'Extension length should not be less than ' + this.length2,
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


        const recordsToUpdate = [];
        // Loop through draftValues to build the array of records to update
        this.aadraftValues.forEach(draft => {
            recordsToUpdate.push({
                Id: draft.Id,
                Ucf_Extension__c: draft.Ucf_Extension__c,
                Schedule__c: draft.Schedule__c,
                EAS_Pin__c: draft.EAS_Pin__c,
                ucf_Auto_Attendent_Name__c: draft.ucf_Auto_Attendent_Name__c,
            });
        });

if (isValidationFailed==false && this.aadraftValues.length !== 0) {
        updateAaSetupData({
                aaSetupData: recordsToUpdate
            })
            .then(result => {
                // Handle success - you can show a toast message or close the modal
                this.fieldChangeCount=0;
                this.notifyInputChange(this.fieldChangeCount);
                this.loadAutoAttendants();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'AA setup updated',
                        variant: 'success',
                    }),
                );
                this.loadAutoAttendants();
                //this.isModalOpen = false; // Close the modal if you have one
            })
            .catch(error => {
                // Handle error - you can show a toast message with the error
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating Menu Lines',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
          }
        }
    }
    catch (error) {
            console.error('Error fetching data:', error);
        } finally {
            this.showLoader = false; // Hide loader after the operation completes (whether success or failure)
        }
}

    handleAdd2() {
        // alert('Add 2');
        this.isSch2 = true;
        this.isSch1 = false;
        this.btnAdd1 = false;
        this.btnAdd2 = false;
    }


    handleInputChangeModal(event) {
        console.log('here');
        if (event.target.name === 'mondayStartTime') {
            this.mondayStartTime = event.target.value;
            console.log('mondayStartTime ' + this.mondayStartTime);
        }
        if (event.target.name === 'mondayEndTime') {
            this.mondayEndTime = event.target.value;
            console.log('mondayStartTime ' + this.mondayEndTime);
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


    }

    handleDelete(event) {
    const holidayId = event.currentTarget.dataset.id;

    // Call Apex method to delete the holiday
    deleteHolidayById({ holidayId: holidayId })
        .then(() => {
            // Remove the holiday from the UI
            this.holidaysGet = this.holidaysGet.filter(holiday => holiday.Id !== holidayId);
        })
        .catch(error => {
            this.error = error;
            console.error("Error deleting holiday:", error);
        });
}



    loadHolidays() {
        getHolidaysBySchedule({
                scheduleId: this.schId
            })
            .then(result => {
                this.holidaysGet = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.holidays = undefined;
            });
    }

    handleTimeChangeCustom1(event) {

        const dayLabel = event.target.dataset.dayLabel;
        const isStartTime = event.target.name.includes('Start');
        const fieldToUpdate = isStartTime ? 'Start__c' : 'Stop__c';
        const timeValue = event.target.value;

        // Check if the dayLabel exists in the originalTimePeriods object, if not, initialize it
        if (!this.originalTimePeriods[dayLabel]) {
            this.originalTimePeriods[dayLabel] = {
                startTime: '',
                endTime: ''
            };
        }

        // Initialize the modified record if it doesn't exist
        if (!this.modifiedTimePeriods[dayLabel]) {
            this.modifiedTimePeriods[dayLabel] = {
                Day__c: dayLabel,
                Schedule__c: this.schId,
                Name: this.tpCustom1,
                Menu__c: this.menuTP1
            };
        }

        // Update the time value
        this.modifiedTimePeriods[dayLabel][fieldToUpdate] = timeValue;

        // Make sure to trigger reactivity in LWC
        this.modifiedTimePeriods = {
            ...this.modifiedTimePeriods
        };
    }


    handleInputChangeTP1(event) {
        this.tpCustom1 = event.target.value;
    }
    handleInputChangeTP2(event) {
        this.tpCustom2 = event.target.value;
    }

    handleTimeChangeCustom2(event) {
        const dayLabel = event.target.dataset.day2OfWeek; // Make sure this matches the dataset attribute
        console.log('dayLabel:' + dayLabel);
        // alert(event.target.name);

        const isStartTime = event.target.name.includes('Start');
        const fieldToUpdate = isStartTime ? 'Start__c' : 'Stop__c';
        const timeValue = event.target.value;

        // Check if the dayLabel exists in the originalTimePeriodsC2 object, if not, initialize it
        if (!this.originalTimePeriodsC2[dayLabel]) {
            this.originalTimePeriodsC2[dayLabel] = {
                startTimeC2: '',
                endTimeC2: ''
            };
        }

        // Initialize the modified record if it doesn't exist
        if (!this.modifiedTimePeriodsC2[dayLabel]) {
            this.modifiedTimePeriodsC2[dayLabel] = {
                Day__c: dayLabel,
                Schedule__c: this.schId,
                Name: this.tpCustom2,
                Menu__c: this.menuTP2
            };
        }

        // Update the time value
        this.modifiedTimePeriodsC2[dayLabel][fieldToUpdate] = timeValue; // Corrected object name

        // Make sure to trigger reactivity in LWC
        this.modifiedTimePeriodsC2 = {
            ...this.modifiedTimePeriodsC2
        };
    }


    addHoliday() {
        // Use a method or property to get the current schedule ID
        // const currentScheduleId = this.getScheduleId(); // Implement this method according to your logic

        // Add a new holiday to the list with the current schedule ID
        this.holidays = [...this.holidays, {
            name: '',
            date: '',
            scheduleId: this.scheduleId
        }];

    }
    /*  handleDateChange(event) {
          const index = event.target.dataset.index; // Use 'dataset.index' instead of 'dataset.id'
          if (this.holidays[index]) {
              this.holidays[index].date = event.target.value;
          } else {
              // Handle the case where the index does not refer to an item in the array
              console.error('Holiday index out of bounds:', index);
          }
      } */

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


    handleNameChange(event) {
        const index = event.target.dataset.index; // Use 'dataset.index' instead of 'dataset.id'
        if (this.holidays[index]) {
            this.holidays[index].name = event.target.value;

        } else {
            // Handle the case where the index does not refer to an item in the array
            console.error('Holiday index out of bounds:', index);
        }
    }

    handleholidayMenuChange(event) {
        const index = event.target.dataset.index; // Use 'dataset.index' instead of 'dataset.id'
        if (this.holidays[index]) {
            this.holidays[index].Ucf_Menu__c = event.target.value;
        } else {
            // Handle the case where the index does not refer to an item in the array
            console.error('Holiday index out of bounds:', index);
        }
    }
    /*

fetchMenuLines() {
        getMenuLines()
            .then(result => {
                this.menuLines = result;
                // ... other logic ...
            })
            .catch(error => {
                // ... handle error ...
            });
    }
    */



    handleMenuChangeForClosed(event) {
        this.menuClosed = event.target.value;
    }
     handleMenuChangeForHoliday(event) {
        this.menuHoliday = event.target.value;
    }
    handleMenuChangeForOpen(event) {
        this.menuOpen = event.target.value;
    }

    handleMenuChangeFor247(event) {
        this.menu247 = event.target.value;
    }
    handleMenuChangeForTP1(event) {
        this.menuTP1 = event.target.value;
        console.log('TP 1' + this.menuTP1);
    }

    handleMenuChangeForTP2(event) {
        this.menuTP2 = event.target.value;
        console.log('TP 2' + this.menuTP2);
    }


    deleteHoliday(event) {
        const index = event.currentTarget.dataset.index; // Use currentTarget to get the button that was clicked
        this.holidays = this.holidays.filter((_, i) => i.toString() !== index);
    }
    handleChange(event) {
        this.radioValue = event.detail.value;
        //alert(this.rb27Value);
        if (this.radioValue === 'Yes') {
            this.isRadionYes = true;
             this.rb27Value = true
        } else {
            this.isRadionYes = false;
             this.rb27Value = false
        }
        // You can handle the radio button value change here
        // For demonstration, let's log the selected value
        console.log('Selected value:', this.radioValue);
    }

       timeStringToMinutes(timeStr) {
    const [hours, minutes] = timeStr.split(':').map(Number);
    return hours * 60 + minutes;
}
    handleModalSave() {


     const invalidTimes = [];


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
 let isInvalidTimeFound = false;
    //alert('here');
    this.schedulesCustomTime.forEach(schedule => {    
        // Check start and stop times for each period
        schedule.timePeriods.forEach(period => {
            const hasStartTime = typeof period.Start === 'string' && period.Start.trim() !== '';
            const hasStopTime = typeof period.Stop === 'string' && period.Stop.trim() !== '';

            if ((hasStartTime && hasStopTime && this.isTimeBefore(period.Stop, period.Start)) ||
                (!hasStartTime && hasStopTime)) {
               // this.showToast('Error', `Invalid time : "${schedule.name}": Stop time must be after Start Time.`, 'error');
                isInvalidTimeFound = true;
            }
        });
    });

    if (isInvalidTimeFound) {
    this.showToast('Error', `Invalid time: Stop time must be after Start Time.`, 'error');
    return;
}
        const schid = this.schId;
        const holidaysToSave = this.holidays
            .filter(holiday => holiday.name)
            .map(holiday => ({
                Name: holiday.name,
                Date__c: holiday.date,
                Ucf_Menu__c: holiday.Ucf_Menu__c,
                Schedule__c: this.schId
            }));

        // Check for duplicate dates
        if (this.checkForDuplicateDates(holidaysToSave)) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Duplicate dates found in holidays.',
                    variant: 'error',
                }),
            );
            return; // Stop execution
        }



        const recordId = this.recordId;


        //  alert('Ucf_Men_24_7__c ' + this.menu247 + ' Ucf_Menu_Open__c ' +  this.menu247+ ' this.menuClosed ' + this.menuClosed+ ' this.schId '+ this.schId);
        const updatedSchedule = {
            Id: this.schId,
            
            X247_checkbox__c: this.rb27Value,
            Ucf_Men_24_7__c: this.menu247,
            Ucf_Menu_Open__c: this.menuOpen,
            Menu_Holiday__c :this.menuHoliday,
            Ucf_Menu_Close__c: this.menuClosed,
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
            Sunday_End_Time__c: this.sundayEndTime,
            Monday__c: this.monday,
            Tuesday__c: this.tuesday,
            Wednesday__c: this.wednesday,
            Thursday__c: this.thursday,
            Friday__c: this.friday,
            Saturday__c: this.saturday,
            Sunday__c: this.sunday,
            UCF_Order__c: recordId

        };



        updateSchedule({
                updatedSchedule: updatedSchedule,
                menuOpen: this.menuOpen,
                menuClosed : this.menuClosed,
                menu247 : this.menu247,
                menuHoliday: this.menuHoliday
            })
            .then(result => {
                this.loadSchedulesForCC();
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
                this.isClosedExpanded = false;
                this.isHolidayExpanded = false;
                this.isOpenExpanded; // Close the modal if you have one
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
        //alert( 'Holidays: '+ JSON.stringify(holidaysToSave));



    }
    /* MEnu Lines work */


    handleTableRowChange(event) {
        const {
            id,
            name,
            value
        } = event.target.dataset;
        const rowIndex = this.tableRows.findIndex(row => row.id === id);

        if (rowIndex !== -1) {
            this.tableRows[rowIndex][name] = value;
        }
        // alert('Table Row Called ' + JSON.stringify(this.tableRows));
        const editedRows = this.detectChanges();
        /// alert('editedRows Called ' + JSON.stringify(editedRows));
    }
    get newRecordTemplate() {
        return {
            Number__c: '',
            Options__c: '',
            Label__c: '',
            Destination_Info__c: '',
            Greeting__c: '',
            Sub_Menu__c: '',
            _editable: false
        };
    }

    handleGreetingChangeMenuLines(event)
    {
        this.greetingForML = event.target.value;
    }

    handleMenuUpdateFromML(event)
    {
         if (event.target.name === 'menuSelectForML') {
            this.greetingML =  event.target.value;
        }

        if (event.target.name === 'menuNametoUpdate') {
            this.menuNametoUpdate =  event.target.value;
        }
    }

    

 handleInputChangeMenuLines(event) {
    console.log('In handle change NeeewWWW');

    try {
        const recordId = event.target.dataset.recordId;
        const fieldName = event.target.dataset.fieldName;
        const newValue = event.target.value;
        let MenuName;

        console.log('Record ID:', recordId);
        console.log('Field Name:', fieldName);
        console.log('New Value:', newValue);
       
        
        this.options2.forEach(opt=>{
            console.log('Opt',opt);
            if(opt.value===newValue){
                MenuName=opt.label;
            }

        });
        console.log('MenuName:', MenuName);
       
       

        console.log('Menu Lines:', JSON.stringify(this.menuLines));

        // Ensure menuLines is an array and has been populated
        if (this.menuLines && Array.isArray(this.menuLines)) {
            this.menuLines = this.menuLines.map(menu => {
                if (menu.Id === recordId) {
                    let updatedMenu = {
                        ...menu,
                        [fieldName]: newValue
                    };

                    if (fieldName === 'Options__c') {
                        updatedMenu.isSubMenuEditable = newValue === 'Go to Sub Menu';
                        //updatedMenu.isDestinationInfoEditable = ['Transfer Number', 'Transfer Voicemail', 'Announcement Return', 'Announcement Hang Up'].includes(newValue);
                        updatedMenu.isDestinationInfoEditable = ['Transfer Number', 'Transfer Voicemail'].includes(newValue);
                        updatedMenu.isGreetingEditable = ['Announcement Return', 'Announcement Hang Up'].includes(newValue);

                        if (['Go to Sub Menu', 'Announcement Return', 'Announcement Hang Up'].includes(newValue)) {
                            this.additionalMessage = 'Additional Menu/Announcement needs to be designed';
                        } else {
                            this.additionalMessage = '';
                        }
                    }

                    return updatedMenu;
                }
                return menu;
            });

            // Update draft values for the changed item
            let updatedData;
            if(fieldName === 'Sub_Menu__c')
            {
                updatedData= {
               
                    Id: recordId,
                    [fieldName]: MenuName
                
                };
            }
            else{
                updatedData= {
               
                    Id: recordId,
                    [fieldName]: newValue
                
                };
            }

            let itemUpdated = false;

            this.draftValues = this.draftValues.map(draft => {
                if (draft.Id === recordId) {
                    itemUpdated = true;
                    return {
                        ...draft,
                        ...updatedData
                    };
                }
                return draft;
            });

            if (!itemUpdated) {
                this.draftValues = [...this.draftValues, updatedData];
            }
        } else {
            console.log('menuLines is not an array or is not ready');
        }
    } catch (error) {
        console.error('Error:', error);
    }

    console.log('End of handleInputChangeMenuLines');
}



    checkForDuplicateDates(holidays) {
        const dates = new Set();
        for (const holiday of holidays) {
            if (dates.has(holiday.Date__c)) {
                // Duplicate date found
                return true;
            }
            if (holiday.Date__c) {
                dates.add(holiday.Date__c);
            }
        }
        return false; // No duplicates
    }


 handleModalSaveMenuLine() {
    // Update the menus array with any changes made to the menu name
    const updatedMenus = this.menus.map(menu => {
        if (menu.Id === this.menuId) {
            return {
                ...menu,
                Name: this.menuNametoUpdate
            };
        }
        return menu;
    });

    this.menus = updatedMenus;

    // Prepare records to be saved, ensuring only updated records are included
    const recordsToSave = this.draftValues.map(draft => {
        return {
            ...draft,
            Id: draft.Id // Include the record ID for updates
        };
    });


    console.log('menu save: '+  JSON.stringify(recordsToSave));

    // Call the saveMenuLines method to save the updated menu lines
    saveMenuLines({
            menuLines: recordsToSave
        })
        .then(result => {
            // Show a toast message on successful save
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Menu Lines updated',
                    variant: 'success',
                }),
            );
            // Fetch updated menu lines to reflect the changes
            this.fetchMenus();
            this.fetchMenuLines();
            // Close the modal window
            this.isModalOpen = false;
        })
        .catch(error => {
            // Show an error toast message if the save operation fails
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating Menu Lines',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });

  

    // Update menu fields with the selected greeting and menu name

    updateMenuFields({
            menuId: this.menuId,
            greetingName: this.greetingML,
            menuName: this.menuNametoUpdate
        })
        .then(result => {
            console.log('Update Menu Fields Result:', result);
        })
        .catch(error => {
            console.error('Error updating menu fields:', error);
        });
}



    /* custom time period to add as many as user can */



    handleScheduMenuChange(event) {
        const scheduleIndex = event.target.dataset.scheduleIndex;
        const selectedMenuId = event.target.value;

        if (scheduleIndex !== undefined) {
            let updatedSchedules = [...this.schedulesCustomTime];
            updatedSchedules[scheduleIndex].menuSelectTp = selectedMenuId;

            this.schedulesCustomTime = updatedSchedules;
            console.log(`Updated menu for schedule at index ${scheduleIndex}: ${selectedMenuId}`);
        } else {
            console.error('Schedule index is undefined in handleScheduMenuChange');
        }
    }



    loadSchedules() {
        getSavedTimePeriods({
                scheduleId: this.schId
            })
            .then(data => {
                console.log('Loaded Schedules Data:', data); // Log the raw data
                // alert(JSON.stringify(data));
                this.schedulesCustomTime = data.map(schedule => ({
                    id: schedule.Id,
                    name: schedule.Name,
                    selectedMenuName: schedule.MenuName__c,
                    selectedMenu: schedule.Menu__c,
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
        const days = [{
                label: 'Monday',
                suffix: 'Monday'
            },
            {
                label: 'Tuesday',
                suffix: 'Tuesday'
            },
            {
                label: 'Wednesday',
                suffix: 'Wednesday'
            },
            {
                label: 'Thursday',
                suffix: 'Thursday'
            },
            {
                label: 'Friday',
                suffix: 'Friday'
            },
            {
                label: 'Saturday',
                suffix: 'Saturday'
            },
            {
                label: 'Sunday',
                suffix: 'Sunday'
            }
        ];
        return days.map(day => ({
            day: day.label,
            Start: schedule[day.suffix + 'Start__c'] || '', // Corrected to use day.suffix
            Stop: schedule[day.suffix + 'Stop__c'] || '', // Corrected to use day.suffix
            changed: false
        }));
    }



    handleTimeChange(event) {
        const scheduleIndex = event.target.dataset.scheduleIndex;
        const periodIndex = event.target.dataset.periodIndex;
        const field = event.target.name === 'StartTime' ? 'Start' : 'Stop';

        let updatedSchedules = JSON.parse(JSON.stringify(this.schedulesCustomTime));
        updatedSchedules[scheduleIndex].timePeriods[periodIndex][field] = event.target.value;
        updatedSchedules[scheduleIndex].timePeriods[periodIndex].changed = true;

        this.schedulesCustomTime = updatedSchedules;
        // alert(JSON.stringify(this.schedulesCustomTime));

    }
    isTimeBefore(time1, time2) {
    const [hours1, minutes1] = time1.split(':').map(Number);
    const [hours2, minutes2] = time2.split(':').map(Number);
    const date1 = new Date(0, 0, 0, hours1, minutes1);
    const date2 = new Date(0, 0, 0, hours2, minutes2);
    return date1 < date2;
}

    handleScheduleNameChange(event) {
        this.fieldChangeCount++;
        this.notifyInputChange(this.fieldChangeCount);
        this.scheduleName = event.target.value;
        //alert('here '+  this.schedule );
    }

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
        const newId = this.schedulesCustomTime.length + 1;
        const newSchedule = {
            name: `Custom ${newId}`,
            Menu__c: `Menu ${newId}`,
            Overflow_Timer__c: 0,
            Overflow_Destination__c: 0,
            timePeriods: this.createDefaultTimePeriods()
        };

        this.schedulesCustomTime = [...this.schedulesCustomTime, newSchedule];
        //alert(JSON.stringify(this.schedulesCustomTime ));
    }

    createDefaultTimePeriods() {
        const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        return days.map(dayLabel => ({
            day: dayLabel,
            Start: '',
            Stop: '',
            changed: false
        }));
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
            saveTimePeriodsNew({
                    timePeriods: scheduleRecords
                })
                .then(() => {
                    // this.showToast('Success', 'Time periods saved successfully', 'success');
                })
                .catch(error => {
                    this.showToast('Error', error.body.message, 'error');
                });
        } else {
            // this.showToast('Info', 'No changes to save', 'info');
        }
    }

fetchMenuLines() {
        getMenuLines({
                menuId: this.menuId
            })
            .then(result => {
 
                this.menuLines = result.map(line => {
                    // Determine if the line is for a submenu
                    const isSubMenuEditable = line.Options__c === 'Go to Sub Menu';
 
                    // Determine if the line is for destination info
                   const isDestinationInfoEditable = ['Transfer Number', 'Transfer Voicemail'].includes(line.Options__c);
 
                   const isGreetingEditable = ['Announcement Return', 'Announcement Hang Up'].includes(line.Options__c);
 
                    return {
                        ...line,
                        isSubMenuEditable,
                        isDestinationInfoEditable,
                        isGreetingEditable,
                    };
                });
 
            })
            .catch(error => {
                console.error('Error fetching menu lines:', error);
            });
    }
 
 
handleInputChangeMenuLines(event) {
    console.log('In handle change NeeewWWW');
 
    try {
        const recordId = event.target.dataset.recordId;
        const fieldName = event.target.dataset.fieldName;
        const newValue = event.target.value;
 
        let MenuName;

        console.log('Record ID:', recordId);
        console.log('Field Name:', fieldName);
        console.log('New Value:', newValue);
       
        
        this.menuOptions2.forEach(opt=>{
            console.log('Opt',opt);
            if(opt.value===newValue){
                MenuName=opt.label;
            }

        });
        console.log('MenuName:', MenuName);

        

 
        if (event.target.name === 'menuSelectForML') {
            this.greetingML = newValue;
        }
 
        if (event.target.name === 'menuNametoUpdate') {
            this.menuNametoUpdate = newValue;
        }
 
        console.log('Menu Lines:', JSON.stringify(this.menuLines));
 
        // Ensure menuLines is an array and has been populated
        if (this.menuLines && Array.isArray(this.menuLines)) {
            this.menuLines = this.menuLines.map(menu => {
                if (menu.Id === recordId) {
                    let updatedMenu = {
                        ...menu,
                        [fieldName]: newValue
                    };
 
                    if (fieldName === 'Options__c') {
                        updatedMenu.isSubMenuEditable = newValue === 'Go to Sub Menu';
                        //updatedMenu.isDestinationInfoEditable = ['Transfer Number', 'Transfer Voicemail', 'Announcement Return','Go to Sub Menu', 'Announcement Hang Up'].includes(newValue);
                        updatedMenu.isDestinationInfoEditable = ['Transfer Number', 'Transfer Voicemail'].includes(newValue);
                        updatedMenu.isGreetingEditable = ['Announcement Return', 'Announcement Hang Up'].includes(newValue);


                        if (['Go to Sub Menu', 'Announcement Return', 'Announcement Hang Up'].includes(newValue)) {
                            this.additionalMessage = 'Additional Menu/Announcement needs to be designed';
                        } else {
                            this.additionalMessage = '';
                        }
                    }
 
                    return updatedMenu;
                }
                return menu;
            });
 
            // Update draft values for the changed item
            let updatedData;
            if(fieldName === 'Sub_Menu__c')
            {
                updatedData= {
               
                    Id: recordId,
                    [fieldName]: MenuName
                
                };
            }
            else{
                updatedData= {
               
                    Id: recordId,
                    [fieldName]: newValue
                
                };
            }
            console.log('updatedData',JSON.stringify(updatedData));
 
            let itemUpdated = false;
 
            this.draftValues = this.draftValues.map(draft => {
                if (draft.Id === recordId) {
                    itemUpdated = true;
                    return {
                        ...draft,
                        ...updatedData
                    };
                }
                return draft;
            });
 
            if (!itemUpdated) {
                this.draftValues = [...this.draftValues, updatedData];
            }
        } else {
            console.log('menuLines is not an array or is not ready');
        }
    } catch (error) {
        console.error('Error:', error);
    }
 
    console.log('End of handleInputChangeMenuLines');
}

notifyInputChange(count){
    this.dispatchEvent(new CustomEvent('recordchange', {
        detail: {
            component: 'autoAttendent',
            message: count
        }
    }));
}

}