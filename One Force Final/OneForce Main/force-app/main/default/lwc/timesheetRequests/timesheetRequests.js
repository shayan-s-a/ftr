import { LightningElement, api, track, wire } from 'lwc';
import getTimesheetsUpdateRequestsByEmployeeId from '@salesforce/apex/TimesheetController.getTimesheetsUpdateRequestsByEmployeeId';
import unlockTimesheets from '@salesforce/apex/TimesheetController.unlockTimesheets';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getUserDetails from '@salesforce/apex/TimesheetController.getUserDetails';
import getTimesheetByDateByEmployee from '@salesforce/apex/TimesheetController.getTimesheetByDateByEmployee';
import getImageUrl from '@salesforce/apex/TimesheetController.getImageUrl';

export default class TimesheetRequests extends LightningElement {
    @api employeeId;
    spinLoader = true;
    @api recordId;
    @api isNesponManager = false;
    @api isDivisionalHead = false;
    @api isHRPractitioner = false;
    @api dateFrom;
    @api dateTo;
    @track timeSheetData = [];
    @api timeOption;
    @track unlockVal = false;
    @track screenType='unlock';


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

    get selectAllDisabled(){
        let btnDisabled = true;
        this.timeSheetData.forEach(element => {
            let singleElement = { ...element };
            if (singleElement.id && singleElement.recall) {
                btnDisabled = false;
            }
        });
        return btnDisabled;
    }

    //Old code
    // timesheetWiredResult;
    // // @wire(getTimesheetsUpdateRequests, { conId: '$recordId' })
    // @wire(getTimesheetsUpdateRequestsByEmployeeId, { conId: '$employeeId',  dateFromParam: '$dateFrom', dateToParam: '$dateTo' })
    // timesheetDataWire(result) {
    //     this.timesheetWiredResult = result;
    //     if (result.data) {
    //         console.log(':::: timeSheetData:', result.data);
    //         let finalData = result.data.map(ele => {
    //             return { ...ele, showOptions: false, requestScreen: true };
    //         });
    //         this.timeSheetData = finalData;
    //         this.spinLoader = false;
    //     } else if (result.error) {
    //         console.error(':::: Error timeSheetData:', result.error);
    //         this.spinLoader = false;
    //     }
    // }

    //Asir new code for bi weekly view
    status = 'Request to Edit';
    timesheetWiredResult;
    @wire(getTimesheetByDateByEmployee, { conId: '$employeeId', dateFromParam: '$dateFrom', dateToParam: '$dateTo', timeOption: '$timeOption', status: '$status', screen:'$screenType' })
    timesheetDataWire(result) {
        this.timesheetWiredResult = result;
        if (result.data) {
            console.log(':::: timeSheetData:', result.data);
            let finalData = result.data.map(ele => {
                return { ...ele, showOptions: false, requestScreen: true };
            });
            this.timeSheetData = finalData;
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
            this.spinLoader = false;
        } else if (result.error) {
            console.error(':::: Error timeSheetData:', result.error);
            this.spinLoader = false;
        }
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

    handleRefreshTimesheet(){
        refreshApex(this.timesheetWiredResult);
    }

    handleTimesheetClose(e) {
        this.dispatchEvent(new CustomEvent('timesheetclose'));
    }

    handleChange(e) {
        let { name, value } = e.target;
        if (name == 'timeOption') {
            this.spinLoader = true;
            this.timeOption = value;
        }
        else if (name == 'dateFrom') {
            this.spinLoader = true;
            this.timeOption = 'Range of Dates';
            this.dateFrom = value;
        }
        else if (name == 'dateTo') {
            this.spinLoader = true;
            this.timeOption = 'Range of Dates';
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
        console.log('newData : ', JSON.stringify(newData));
        this.timeSheetData = [...newData];
    }

    handleSelectAll(e) {
        this.unlockVal = true;
        let finalList = [];
        if (e.target.checked) {
            this.timeSheetData.forEach(element => {
                let singleElement = { ...element };
                if (singleElement.id && singleElement.recall) {
                    singleElement.checked = true;
                }
                // if(!singleElement.recall){
                //     singleElement.disableCheckbox = true;
                // }
                finalList.push(singleElement);
            });
        }
        else {
            this.timeSheetData.forEach(element => {
                let singleElement = { ...element };
                if (singleElement.id && singleElement.recall) {
                    singleElement.checked = false;
                }
                finalList.push(singleElement);
            });
        }
        this.timeSheetData = [...finalList];
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
        this.unlockVal = false;

       
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