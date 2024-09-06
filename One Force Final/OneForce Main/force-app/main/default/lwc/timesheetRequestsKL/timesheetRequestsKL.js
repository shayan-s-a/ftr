import { LightningElement, api, track, wire } from 'lwc';
import getTimesheetsUpdateRequests from '@salesforce/apex/TimesheetController.getTimesheetsUpdateRequests';
import unlockTimesheets from '@salesforce/apex/TimesheetController.unlockTimesheets';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class timesheetRequestsKL extends LightningElement {
    spinLoader = true;
    @api recordId;
    @api isNesponManager;
    @api dateFrom;
    @api dateTo;
    @track timeSheetData = [];

    timesheetWiredResult;
    @wire(getTimesheetsUpdateRequests, { conId: '$recordId' })
    timesheetDataWire(result) {
        this.timesheetWiredResult = result;
        if (result.data) {
            console.log(':::: timeSheetData:', result.data);
            let finalData = result.data.map(ele => {
                return { ...ele, showOptions: false, requestScreen: true };
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

    // * ENABLE/DISABLE APPROVE BUTTON
    get noRowSelected() {
        return this.timeSheetData.filter(ele => ele.checked).length > 0 ? false : true;
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

    handleUnlock() {
        this.spinLoader = true;
        let finalList = [];
        this.timeSheetData.forEach(ele => {
            // Only Focus on the rows which are updated.
            if (ele.checked) {
                console.log('INSIDE CHECKED ROWS : ', ele);
                finalList.push(ele);
            }
        });

        unlockTimesheets({ timesheets: finalList, managerId: this.recordId })
            .then(result => {
                console.log('result : ', result);
                if (result == 'OK') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Timesheets Unlock',
                            message: 'Timesheets unlock successfully.',
                            variant: 'success'
                        })
                    );
                    refreshApex(this.timesheetWiredResult);
                }
                else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Some issue',
                            message: 'Some issue in unlocking timesheets. If this issue keeps coming up then contact System Administrator.',
                            variant: 'info'
                        })
                    );
                    this.spinLoader = false;
                }

            })
            .catch(err => {
                console.log(':::: Error in unlocking: ', err);

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error in Unlocking',
                        message: 'Error in unlocking timsheet.',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.spinLoader = false;

            })
    }
}