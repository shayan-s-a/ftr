import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTimesheetByDate from '@salesforce/apex/TimesheetController.getTimesheetByDate';
import saveRecords from '@salesforce/apex/TimesheetController.saveRecords';
import submitRecords from '@salesforce/apex/TimesheetController.submitRecords';
import recallRecords from '@salesforce/apex/TimesheetController.recallRecords';
import { refreshApex } from '@salesforce/apex';
import LightningConfirm from 'lightning/confirm';
import LightningPrompt from 'lightning/prompt';

export default class TimesheetNew extends LightningElement {
   /* spinLoader = true;
    @api userDetails = {};
    get userExist() {
        return this.userDetails ? Object.keys(this.userDetails).length : false;
    }
    timeOption = 'Current Pay Period';
    get timeOptions() {
        return [
            { label: 'Current Pay Period', value: 'Current Pay Period' },
            { label: 'Next Pay Period', value: 'Next Pay Period' },
            { label: 'Previous Pay Period', value: 'Previous Pay Period' },
            { label: 'Range of Dates', value: 'Range of Dates' },
        ];
    }

    @api dateFrom;
    @api dateTo;
    @api recordId;
    @track timeSheetData = [];
    @track updatedSheet = [];
    @track initialData = []; // This is used when we try to refresh so we can get the original data

    timesheetWiredResult;
    @wire(getTimesheetByDate, { conId: '$recordId', dateFromParam: '$dateFrom', dateToParam: '$dateTo', timeOption: '$timeOption' })
    timesheetDataWire(result) {
        this.timesheetWiredResult = result;
        if (result.data) {
            console.log(':::: timeSheetData:', result.data);
            let finalData = result.data.map(ele => {
                return { ...ele, showOptions: true, approvalScreen: false };
            });
            this.timeSheetData = finalData;
            console.log('this.timeSheetData[0].dayDate: ', this.timeSheetData[0].dayDate);
            if (this.dateFrom != this.timeSheetData[0].dayDate) {
                this.dateFrom = this.timeSheetData[0].dayDate;
                console.log('this.dateFrom INSIDE : ');
            }
            // if (this.dateTo != this.timeSheetData[this.timeSheetData.length - 1].dayDate) {
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
            // }
            this.initialData = finalData;
            this.spinLoader = false;
        } else if (result.error) {
            console.error(':::: Error timeSheetData:', result.error);
            this.spinLoader = false;
        }
    }

    handleChange(evt) {
        let { name, value } = evt.target;
        if (name == 'timeOption') {
            this.spinLoader = true;
            this.timeOption = value;
        }
        else if (name == 'dateFrom') {
            this.spinLoader = true;
            this.timeOption = 'Range of Dates';
            this.dateFrom = value;
            console.log('this.dateFrom : ', this.dateFrom);
        }
        else if (name == 'dateTo') {
            this.spinLoader = true;
            this.timeOption = 'Range of Dates';
            this.dateTo = value;
        }
    }

    // handleFind() {
    //     if (this.dateFrom && this.dateTo) {
    //         if (this.dateFrom > this.dateTo) {
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Info',
    //                     message: '"Date From" must be less than "Date To".',
    //                     variant: 'info'
    //                 })
    //             );
    //         }
    //         else {
    //             this.spinLoader = true;
    //             // Call Apex
    //             getTimesheetByDate({ conId: this.recordId, dateFromParam: this.dateFrom, dateToParam: this.dateTo })
    //                 .then(result => {
    //                     console.log(':::: Timesheet Find Data: ', result);
    //                     this.timeSheetData = result;
    //                     this.initialData = result;
    //                     this.spinLoader = false;
    //                 })
    //                 .catch(error => {
    //                     console.log(':::: Timesheet Find Error: ', error);
    //                     this.spinLoader = false;
    //                 });
    //         }
    //     }
    //     else {
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Info',
    //                 message: 'Please select both "Date From" and "Date To".',
    //                 variant: 'info'
    //             })
    //         );
    //     }
    // }

    handleRowEdit(evt) {
        let { daydate, dayname, id, emptyrownumber } = evt.detail;
        console.log('daydate : ', daydate);
        console.log('dayname : ', dayname);
        console.log('id : ', id);
        console.log('emptyrownumber : ', emptyrownumber);
        let newData = [];

        this.timeSheetData.forEach(ele => {
            let newRow = { ...ele };
            // Update Existing Record
            if (id != undefined && id != null
                && id == ele.id) {
                console.log('Inside Match Id : ', ele.id + ' => ' + id);
                newRow.inEditMode = true;
            }
            // Update Row by emptyrownumber
            else if (emptyrownumber != undefined && emptyrownumber != null &&
                ele.emptyRowNumber == emptyrownumber) {
                console.log('Inside Match emptyrownumber : ', ele.emptyRowNumber + ' => ' + emptyrownumber);
                newRow.inEditMode = true;
            }
            newData.push(newRow);
        })
        console.log('newData : ', newData);
        this.timeSheetData = [...newData];
    }

    handleRowRefresh(evt) {
        let { daydate, dayname, id, emptyrownumber } = evt.detail;
        console.log('daydate : ', daydate);
        console.log('dayname : ', dayname);
        console.log('id : ', id);
        console.log('emptyrownumber : ', emptyrownumber);
        let newData = [];

        this.timeSheetData.forEach(ele => {
            let newRow = { ...ele };
            // Update Existing Record
            if (id != undefined && id != null
                && id == ele.id) {
                let initialRow = this.initialData.filter(row => row.id == id)[0];
                newRow = { ...initialRow };
            }
            // Update Row by emptyrownumber
            else if (emptyrownumber != undefined && emptyrownumber != null &&
                ele.emptyRowNumber == emptyrownumber) {
                let initialRow = this.initialData.filter(row => row.emptyRowNumber == emptyrownumber)[0];
                newRow = { ...initialRow };
            }
            newData.push(newRow);
        })
        this.timeSheetData = [...newData];
    }

    handleRowUpdate(evt) {
        let { id, emptyrownumber, name, value } = evt.detail;
        console.log('id : ', id);
        console.log('emptyrownumber : ', emptyrownumber);
        console.log('name : ', name);
        console.log('value : ', value);
        let newData = [];

        this.timeSheetData.forEach(ele => {
            let newRow = { ...ele };
            if (id != undefined && id != null
                && id == ele.id) {
                console.log('id => value : ', value);
                newRow[name] = value;
            }
            else if (emptyrownumber != undefined && emptyrownumber != null &&
                ele.emptyRowNumber == emptyrownumber) {
                console.log('emptyRowNumber => value : ', value);
                newRow[name] = value;
            }
            newData.push(newRow);
        })
        this.timeSheetData = [...newData];
    }

    handleAddRow(evt) {
        let { id, emptyrownumber, dayname, daydate } = evt.detail;
        console.log('id : ', id);
        console.log('emptyrownumber : ', emptyrownumber);
        console.log('dayname : ', dayname);
        console.log('daydate : ', daydate);
        let newData = [];
        this.timeSheetData.forEach(ele => {
            let newRow = { ...ele };
            let rowFound = false;

            // Update Existing Record
            if (id != undefined && id != null
                && id == ele.id) {
                console.log('Inside Match Id : ', ele.id + ' => ' + id);
                rowFound = true;
            }
            // Update Row by emptyrownumber
            else if (emptyrownumber != undefined && emptyrownumber != null &&
                ele.emptyRowNumber == emptyrownumber) {
                console.log('Inside Match emptyrownumber : ', ele.emptyRowNumber + ' => ' + emptyrownumber);
                rowFound = true;
            }
            newData.push(newRow);
            if (rowFound) {
                let additionalRow = { ...ele };
                additionalRow.hours = null;
                additionalRow.totalHours = null;
                additionalRow.project = null;
                additionalRow.projectName = null;
                additionalRow.inEditMode = true; // * AUTOMATICALLY EDITABLE NEW ROW
                additionalRow.emptyRowNumber = Math.random().toString().substring(2, 8);
                additionalRow.id = null;
                additionalRow.payCode = null;
                additionalRow.combineRow = true;
                additionalRow.delible = true;
                additionalRow.showOptions = true;
                newData.push(additionalRow);
            }
        })
        console.log('newData : ', newData.length);
        this.timeSheetData = [...newData];
    }

    handleRowDelete(evt) {
        let { id, emptyrownumber, dayname, daydate } = evt.detail;
        console.log('id : ', id);
        console.log('emptyrownumber : ', emptyrownumber);
        console.log('dayname : ', dayname);
        console.log('daydate : ', daydate);
        let newData = [];

        this.timeSheetData.forEach(ele => {
            let newRow = { ...ele };
            let rowFound = false;
            if (id != undefined && id != null
                && id == ele.id) {
                console.log('id Found: ', ele.id);
                rowFound = true;
                // TODO DELETE FROM SALESFORCE 
            }
            else if (emptyrownumber != undefined && emptyrownumber != null &&
                ele.emptyRowNumber == emptyrownumber) {
                console.log('emptyRowNumber Found: ', ele.emptyRowNumber);
                rowFound = true;
            }
            if (!rowFound) {
                newData.push(newRow);
            }
        })
        this.timeSheetData = [...newData];
        // this.timeSheetData = [...this.initialData];
    }

    // * ENABLE/DISABLE SAVE BUTTON
    get isSheetNotUpdated() {
        return !this.timeSheetData?.filter(ele => ele.inEditMode).length;
    }

    handleSave() {
        let finalList = [];
        let errorList = [];
        this.timeSheetData.forEach(ele => {
            // Only Focus on the rows which are updated.
            if (ele.inEditMode) {
                console.log('INSIDE EDITED ROWS : ', ele);
                if (ele.hours >= 0.5 && ele.hours <= 15) {
                    finalList.push(ele);
                } else {
                    errorList.push(ele);
                }
            }
        })
        if (errorList.length) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in Hours',
                    message: 'Please provide valid hours for all Time Entires',
                    variant: 'error',
                })
            );
        }
        else if (finalList.length) {
            this.spinLoader = true;
            console.log(':::: finalList : ', finalList);
            saveRecords({ timesheetsToSave: finalList, conId: this.recordId })
                .then(result => {
                    console.log('Result', result);
                    if (result == 'OK') {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Timesheet Saved',
                                message: 'Timesheet saved successfully.',
                                variant: 'success'
                            })
                        );
                    }
                    else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Some Issue in Saving',
                                message: 'Timesheet was not saved successfully. If this error keeps coming up then contact your System Administrator.',
                                variant: 'info'
                            })
                        );
                    }
                    refreshApex(this.timesheetWiredResult);
                })
                .catch(error => {
                    console.error('Error:', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error in Saving',
                            message: 'Error in saving timsheet. ' + JSON.stringify(error),
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );
                    this.spinLoader = false;
                });
        }
    }

    // * SHOW/HIDE SUBMIT BUTTON
    get showSubmitButton() {
        return this.timeSheetData?.filter(ele => ele.timsheetSaved).length;
    }

    async handleSubmit() {
        const dateF = new Date(this.dateFrom);
        const dateT = new Date(this.dateTo);
        const result = await LightningConfirm.open({
            message: `All Timesheets which are saved but not submitted between *${dateF.toString().substring(0, 15)} - ${dateT.toString().substring(0, 15)}* will be submitted for Approval.`,
            variant: 'Confirmation',
        });
        if (result) {
            this.spinLoader = true;
            let finalList = [];
            this.timeSheetData.forEach(ele => {
                // Only Focus on the rows which are Saved but not submitted.
                if (ele.timsheetSaved) {
                    finalList.push(ele);
                }
            })
            console.log(':::: finalList: ', finalList);
            // submitRecords({ dateFromParam: this.dateFrom, dateToParam: this.dateTo, conId: this.recordId })
            submitRecords({ timesheets: finalList, conId: this.recordId })
                .then(result => {
                    console.log('Result', result);
                    if (result == 'OK') {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Timesheet Submitted',
                                message: 'Timesheet submitted for approval successfully.',
                                variant: 'success'
                            })
                        );
                    }
                    else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Some Issue in Saving',
                                message: 'Timesheet was not submitted successfully. If this error keeps coming up then contact your System Administrator.',
                                variant: 'info'
                            })
                        );
                    }
                    refreshApex(this.timesheetWiredResult);
                })
                .catch(err => {
                    console.error('Error:', err);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error in Submitting',
                            message: 'Error in submitting timsheet for Approval. ' + JSON.stringify(err),
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );
                    this.spinLoader = false;
                })
        }
    }

    // * SHOW/HIDE RECALL BUTTON
    get showRecallButton() {
        return this.timeSheetData?.filter(ele => ele.submitted).length;
    }

    handleRecall() {
        const dateF = new Date(this.dateFrom);
        const dateT = new Date(this.dateTo);
        LightningPrompt.open({
            label: 'Request to Edit Timesheet', // this is the header text
            message: `Your request to edit "Submitted Timesheets" between *${dateF.toString().substring(0, 15)} - ${dateT.toString().substring(0, 15)}* will be sent to your manager.`,
            defaultValue: 'Reason here...', //this is optional
        }).then((result) => {
            if (result) {
                this.spinLoader = true;
                let finalList = [];
                this.timeSheetData.forEach(ele => {
                    // Only Focus on the rows which are Submitted.
                    if (ele.submitted) {
                        finalList.push(ele);
                    }
                })
                recallRecords({ timesheets: finalList, conId: this.recordId })
                    .then(result => {
                        console.log('Result', result);
                        if (result == 'OK') {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Request Sent to Manager',
                                    message: 'Request To Edit the "Submitted Timesheet" is sent to your manager successfully.',
                                    variant: 'success'
                                })
                            );
                        }
                        else {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Some Issue in Recalling',
                                    message: 'Unable to recall timesheet. If this error keeps coming up then contact your System Administrator.',
                                    variant: 'info'
                                })
                            );
                        }
                        refreshApex(this.timesheetWiredResult);
                    })
                    .catch(err => {
                        console.error('Error:', err);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error in Recalling',
                                message: 'Error in recalling timsheet to edit. ' + JSON.stringify(err),
                                variant: 'error',
                                mode: 'sticky'
                            })
                        );
                        this.spinLoader = false;
                    })
            }
        });
    }*/
}