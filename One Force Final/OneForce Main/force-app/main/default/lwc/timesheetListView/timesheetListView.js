import { LightningElement, track, wire, api } from 'lwc';
//import gettimesheetlist from '@salesforce/apex/timesheetlistview.gettimesheetlist';
//import getUpdateRequestEmployeeList from '@salesforce/apex/timesheetlistview.getUpdateRequestEmployeeList';

export default class TimesheetListView extends LightningElement {
    // @api dateFrom;
    // @api dateTo;
    // @api empId;
    // @api timeOption = 'Current Pay Period';
    // @api recordId;
    // @api isNesponManager;
    // @track showApprovedTimesheet = false;



    // timeOption = 'Current Pay Period';
    // get timeOptions() {
    //     return [
    //         { label: 'Current Pay Period', value: 'Current Pay Period' },
    //         { label: 'Next Pay Period', value: 'Next Pay Period' },
    //         { label: 'Previous Pay Period', value: 'Previous Pay Period' },
    //         { label: 'Range of Dates', value: 'Range of Dates' },
    //     ];
    // }

    // get statusOptions() {
    //     return [
    //         { label: 'Approved', value: 'Approved' },
    //         // { label: 'Request to Edit', value: 'Request to Edit' },
    //         // { label: 'Rejected', value: 'Rejected' },
    //         { label: 'Submitted and Pending for Approval', value: 'Submitted and Pending for Approval' }
    //     ];
    // }



    // @track timesheetEmpListRes;
    // @wire(getUpdateRequestEmployeeList, { conId: '$recordId', dateFromParam: '$dateFrom', dateToParam: '$dateTo', timeOption: '$timeOption' })
    // timesheetDataWire(result) {
    //     if (result.data) {
    //         console.log(':::: timesheetEmpListRes:', result.data);
    //         this.timesheetEmpListRes = result.data;
    //         // let finalData = result.data.map(ele => {
    //         //     return { ...ele, showOptions: false, requestScreen: true };
    //         // });
    //         // this.timeSheetData = finalData;
    //         this.spinLoader = false;
    //     } else if (result.error) {
    //         console.error(':::: Error timesheetEmpListRes:', result.error);
    //         this.spinLoader = false;
    //     }
    // }

    // handleChange(e) {
    //     let { name, value } = e.target;
    //     if (name == 'timeOption') {
    //         this.spinLoader = true;
    //         this.timeOption = value;
    //     }
    //     else if (name == 'dateFrom') {
    //         this.spinLoader = true;
    //         this.timeOption = 'Range of Dates';
    //         this.dateFrom = value;
    //         console.log('this.dateFrom : ', this.dateFrom);
    //     }
    //     else if (name == 'dateTo') {
    //         this.spinLoader = true;
    //         this.timeOption = 'Range of Dates';
    //         this.dateTo = value;
    //     }
    // }

    // handleRowClick(e) {
    //     this.empId = e.currentTarget.dataset.rowId;
    //     console.log(':::: empId: ' + this.empId);
    //     this.showApprovedTimesheet = true;
    //     // console.log(e.currentTarget.dataset.rowId);
    // }

    // handleTimesheetClose(e) {
    //     this.showApprovedTimesheet = false;
    // }











}