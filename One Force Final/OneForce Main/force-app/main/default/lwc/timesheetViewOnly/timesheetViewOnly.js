import { LightningElement, api, track, wire } from 'lwc';
import getTimesheetToViewByEmployeeId from '@salesforce/apex/TimesheetController.getTimesheetToViewByEmployeeId';
import getUserDetails from '@salesforce/apex/TimesheetController.getUserDetails';
import getImageUrl from '@salesforce/apex/TimesheetController.getImageUrl';
import getTimesheetByDateByEmployee from '@salesforce/apex/TimesheetController.getTimesheetByDateByEmployee';



export default class TimesheetViewOnly extends LightningElement {
    spinLoader = true;
    @api employeeId;
    @api recordId;
    // @api isLineManager;
    isLineManager = true;
    @api dateFrom;
    @api dateTo;
    @api timeOption;
    @track timeSheetData = [];

    @track userDetails = {};
    @wire(getUserDetails, { userId: '$employeeId' })
    getUserDetails({ error, data }) {
        if (data) {
            // console.log(':::: userDetails: ', JSON.stringify(data));
            // this.userDetails = data;
            //Asir adding this part to convert date format
            let [year, month, date] = data.HireDate.split("-");
            let formattedHireDate = `${date}/${month}/${year}`;
            this.userDetails = {
                ...data, 
                'formattedHireDate':formattedHireDate
            };
            console.log(':::: Data', JSON.stringify(this.userDetails));
        } else if (error) {
            console.error(':::: Error:', error);
        }
    }
    get timeOptions() {
        return [
            { label: 'Current Pay Period', value: 'Current Pay Period' },
            { label: 'Next Pay Period', value: 'Next Pay Period' },
            { label: 'Previous Pay Period', value: 'Previous Pay Period' },
            { label: 'Range of Dates', value: 'Range of Dates' },
        ];
    }
    imageUrl;
    @wire(getImageUrl, {conId: '$userDetails.Id'})
    profilePhotoUrl(result) {
        try{
            if (result.data) {
                console.log(':::: profilePhotoUrl:', result.data);
                let strData = result.data;
                this.imageUrl = strData;
            } else if (result.error) {
                console.error(':::: Error profilePhotoUrl:', result.error);
            }
        }
        catch(err){
            console.log('error');
            console.log(err.message);
        }
    }

    handleTimesheetClose(e) {
        this.dispatchEvent(new CustomEvent('timesheetclose'));
    }

    renderedCallback() {
        console.log(':::: recordId: ' + this.recordId);
        console.log(':::: employeeId: ' + this.employeeId);
        console.log(':::: dateFrom: ' + this.dateFrom);
        console.log(':::: dateTo: ' + this.dateTo);
    }

    timesheetWiredResult; // Her conId = Manager Id
    // @wire(getTimesheetToViewByEmployeeId, { employeeId: '$employeeId', conId: '$recordId', dateFromParam: '$dateFrom', dateToParam: '$dateTo', timeOption: '$timeOption' })
    // timesheetDataWire(result) {
    //     console.log(':::: RESULT view only' + JSON.stringify(result));
    //     // this.timesheetWiredResult = result;
    //     if (result.data) {
    //         console.log(':::: timeSheetData:', result.data);
    //         let finalData = result.data.map(ele => {
    //             return { ...ele, showOptions: false, approvalScreen: false };
    //         });
    //         this.timeSheetData = finalData;
    //         this.spinLoader = false;
    //     } else if (result.error) {
    //         console.error(':::: Error timeSheetData:', result.error);
    //         this.spinLoader = false;
    //     }
    //     console.log(':::: RESULT' + JSON.stringify(result));
    //     this.spinLoader = false;
    // }
    @wire(getTimesheetByDateByEmployee, { conId: '$employeeId', dateFromParam: '$dateFrom', dateToParam: '$dateTo', timeOption: '$timeOption', status: 'viewonly' })
    timesheetDataWire(result) {
        console.log(':::: RESULT view only' + JSON.stringify(result));
        // this.timesheetWiredResult = result;
        if (result.data) {
            console.log(':::: timeSheetData:', result.data);
            let finalData = result.data.map(ele => {
                return { ...ele, showOptions: false, approvalScreen: false };
            });
            this.timeSheetData = finalData;
            if (this.dateFrom != this.timeSheetData[0].dayDate) {
                this.dateFrom = this.timeSheetData[0].dayDate;
                console.log('this.dateFrom INSIDE : ');
            }
            if (!this.timeSheetData[this.timeSheetData.length - 1]?.weeklySumRow) {
                if (this.dateTo != this.timeSheetData[this.timeSheetData.length - 1]?.dayDate) {
                    console.log('this.dateTo INSIDE: ');
                    this.dateTo = this.timeSheetData[this.timeSheetData.length - 1]?.dayDate;
                }
            } else {
                if (this.dateTo != this.timeSheetData[this.timeSheetData.length - 2]?.dayDate) {
                    console.log('this.dateTo INSIDE WEEKLY: ');
                    this.dateTo = this.timeSheetData[this.timeSheetData.length - 2]?.dayDate;
                }
            }
            this.spinLoader = false;
        } else if (result.error) {
            console.error(':::: Error timeSheetData:', result.error);
            this.spinLoader = false;
        }
        console.log(':::: RESULT' + JSON.stringify(result));
        this.spinLoader = false;
    }



    handleChange(evt) {
        let { name, value } = evt.target;
        if (name == 'timeOption') {
            this.spinLoader = true;
            this.timeOption = value;
        }
        if (name == 'dateFrom') {
            this.spinLoader = true;
            this.dateFrom = value;
        }
        else if (name == 'dateTo') {
            this.spinLoader = true;
            this.dateTo = value;
        }
    }
}