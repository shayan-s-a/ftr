import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getTimesheetForApproval from '@salesforce/apex/TimesheetController.getTimesheetForApproval';
import approveTimesheets from '@salesforce/apex/TimesheetController.approveTimesheets';
import rejectTimesheets from '@salesforce/apex/TimesheetController.rejectTimesheets';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningPrompt from 'lightning/prompt';

export default class TimesheetApprovalKL extends LightningElement {
    spinLoader = true;
    @api recordId;
    @api isNesponManager;
    @api isLineManager;
    @api dateFrom;
    @api dateTo;
    @track timeSheetData = [];

    timesheetWiredResult;
    @wire(getTimesheetForApproval, { conId: '$recordId', dateFromParam: '$dateFrom', dateToParam: '$dateTo' })
    timesheetDataWire(result) {
        this.timesheetWiredResult = result;
        if (result.data) {
            console.log(':::: timeSheetData:', result.data);
            let finalData = result.data.map(ele => {
                return { ...ele, showOptions: false, approvalScreen: true };
            });
            finalData.sort((a, b) => {
                let fa = a.userName.toLowerCase();
                let fb = b.userName.toLowerCase();

                if (fa < fb) {
                    return -1;
                }
                if (fa > fb) {
                    return 1;
                }
                return 0;
            });

            this.timeSheetData = finalData;
            this.spinLoader = false;
        } else if (result.error) {
            console.error(':::: Error timeSheetData:', result.error);
            this.spinLoader = false;
        }
    }

    handleChange(evt) {
        let { name, value } = evt.target;
        if (name == 'dateFrom') {
            this.spinLoader = true;
            this.dateFrom = value;
        }
        else if (name == 'dateTo') {
            this.spinLoader = true;
            this.dateTo = value;
        }
    }

    handleRowChecked(evt) {
        let { daydate, dayname, id } = evt.detail;
        console.log('daydate : ', daydate);
        console.log('dayname : ', dayname);
        console.log('id : ', id);
        let newData = [];

        this.timeSheetData.forEach(ele => {
            let newRow = { ...ele };
            // Update Existing Record
            if (id != undefined && id != null
                && id == ele.id) {
                console.log('Inside Match Id : ', ele.id + ' => ' + id);
                newRow.checked = !newRow.checked;
            }
            newData.push(newRow);
        })
        console.log('newData : ', newData);
        this.timeSheetData = [...newData];
    }

    // * ENABLE/DISABLE APPROVE BUTTON
    get noRowSelected() {
        return this.timeSheetData.filter(ele => ele.checked).length > 0 ? false : true;
    }

    handleApprove() {
        this.spinLoader = true;
        let finalList = [];
        this.timeSheetData.forEach(ele => {
            // Only Focus on the rows which are updated.
            if (ele.checked) {
                console.log('INSIDE CHECKED ROWS : ', ele);
                finalList.push(ele);
            }
        })
        approveTimesheets({ timesheets: finalList, managerId: this.recordId })
            .then(result => {
                if (result == 'OK') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Timesheets Approved',
                            message: 'Timesheet approved successfully.',
                            variant: 'success'
                        })
                    );
                    refreshApex(this.timesheetWiredResult);
                }
                else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Some issue',
                            message: 'Some issue in approving timesheets. If this issue keeps coming up then contact System Administrator.',
                            variant: 'info'
                        })
                    );
                    this.spinLoader = false;
                }

            })
            .catch(err => {
                console.log(':::: Error in Approving: ', err);

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error in Approving',
                        message: 'Error in approving timsheet.',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.spinLoader = false;

            })
    }

    showRejectModal = false;
    rejectMessage = '';

    handleRejectCancel() {
        this.showRejectModal = false;
    }

    handleRejectSave(evt) {
        this.showRejectModal = false;
        this.spinLoader = true;
        let finalList = [];
        this.timeSheetData.forEach(ele => {
            // Only Focus on the rows which are updated.
            if (ele.checked) {
                console.log('INSIDE CHECKED ROWS : ', ele);
                finalList.push(ele);
            }
        })
        rejectTimesheets({ timesheets: finalList, reason: evt.detail, managerId: this.recordId })
            .then(result => {
                if (result == 'OK') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Timesheets Rejected',
                            message: 'Timesheets rejected successfully.',
                            variant: 'success'
                        })
                    );
                    refreshApex(this.timesheetWiredResult);
                }
                else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Some issue',
                            message: 'Some issue in rejecting timesheets. If this issue keeps coming up then contact System Administrator.',
                            variant: 'info'
                        })
                    );
                    this.spinLoader = false;
                }

            })
            .catch(err => {
                console.log(':::: Error in Rejecting: ', err);

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error in Rejecting',
                        message: 'Error in rejecting timsheet.',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.spinLoader = false;

            })

    }

    handleReject() {
        const dateF = new Date(this.dateFrom);
        const dateT = new Date(this.dateTo);
        this.rejectMessage = `Your reason "Submitted " between *${dateF.toString().substring(0, 15)} - ${dateT.toString().substring(0, 15)}* will be sent to your manager.`;
        this.showRejectModal = true;
        console.log('::::');
        //     // Reason Of Rejection

        //     LightningPrompt.open({
        //         label: 'Reason Of Rejection', // this is the header text
        //         message: `Your reason "Submitted " between *${dateF.toString().substring(0, 15)} - ${dateT.toString().substring(0, 15)}* will be sent to your manager.`,
        //         defaultValue: '', //this is optional
        //     }).then((result) => {
        //         if (result) {
        //             console.log('result ', JSON.stringify(result));

        //             this.spinLoader = true;
        //             let finalList = [];
        //             this.timeSheetData.forEach(ele => {
        //                 // Only Focus on the rows which are updated.
        //                 if (ele.checked) {
        //                     console.log('INSIDE CHECKED ROWS : ', ele);
        //                     finalList.push(ele);
        //                 }
        //             })
        //             rejectTimesheets({ timesheets: finalList, reason: result, managerId: this.recordId })
        //                 .then(result => {
        //                     if (result == 'OK') {
        //                         this.dispatchEvent(
        //                             new ShowToastEvent({
        //                                 title: 'Timesheets Rejected',
        //                                 message: 'Timesheets rejected successfully.',
        //                                 variant: 'success'
        //                             })
        //                         );
        //                         refreshApex(this.timesheetWiredResult);
        //                     }
        //                     else {
        //                         this.dispatchEvent(
        //                             new ShowToastEvent({
        //                                 title: 'Some issue',
        //                                 message: 'Some issue in rejecting timesheets. If this issue keeps coming up then contact System Administrator.',
        //                                 variant: 'info'
        //                             })
        //                         );
        //                         this.spinLoader = false;
        //                     }

        //                 })
        //                 .catch(err => {
        //                     console.log(':::: Error in Rejecting: ', err);

        //                     this.dispatchEvent(
        //                         new ShowToastEvent({
        //                             title: 'Error in Rejecting',
        //                             message: 'Error in rejecting timsheet.',
        //                             variant: 'error',
        //                             mode: 'sticky'
        //                         })
        //                     );
        //                     this.spinLoader = false;

        //                 })
        //         }
        //         else if (result == '') {
        //             this.dispatchEvent(
        //                 new ShowToastEvent({
        //                     title: 'Reason Required',
        //                     message: 'You have to enter reason for rejection.',
        //                     variant: 'info'
        //                 })
        //             );
        //         }
        //     });


    }
}