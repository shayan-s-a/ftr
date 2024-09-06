import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getTimesheetForApprovalByEmployeeId from '@salesforce/apex/TimesheetController.getTimesheetForApprovalByEmployeeId';
import approveTimesheets from '@salesforce/apex/TimesheetController.approveTimesheets';
import rejectTimesheets from '@salesforce/apex/TimesheetController.rejectTimesheets';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUserDetails from '@salesforce/apex/TimesheetController.getUserDetails';
import getImageUrl from '@salesforce/apex/TimesheetController.getImageUrl';
import getTimesheetByDateByEmployee from '@salesforce/apex/TimesheetController.getTimesheetByDateByEmployee';
import saveRecordsFromManager from '@salesforce/apex/TimesheetController.saveRecordsFromManager';
import saveRecordsFromManager2 from '@salesforce/apex/TimesheetController.saveRecordsFromManager2';
import deleteRecords from '@salesforce/apex/TimesheetController.deleteRecords';


export default class TimesheetApproval extends LightningElement {
    @api employeeId;
    spinLoader = true;
    @api recordId;
    @api isNesponManager = false;
    @api isDivisionalHead = false;
    @api isHRPractitioner = false;
    @api isLineManager = false;
    @api dateFrom;
    @api dateTo;
    @track timeSheetData = [];
    @api timeOption;
    @track unlockVal = false;
    @track screenType='approval';
    @track initialData = [];
    @track deletedData = []; 

    showWarningModal = false;
    get timeOptions() {
        return [
            { label: 'Current Pay Period', value: 'Current Pay Period' },
            { label: 'Next Pay Period', value: 'Next Pay Period' },
            { label: 'Previous Pay Period', value: 'Previous Pay Period' },
           // { label: 'Range of Dates', value: 'Range of Dates' },
        ];
    }

    handleTimesheetClose(e) {
        this.dispatchEvent(new CustomEvent('timesheetclose'));
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

    get selectAllDisabled(){
        let btnDisabled = true;
        this.timeSheetData.forEach(element => {
            let singleElement = { ...element };
            if (singleElement.id && singleElement.submitted) {
                btnDisabled = false;
            }
            else if(singleElement.disableCheckbox==false){
                btnDisabled = false;

            }
        });
        return btnDisabled;
    }

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

    // timesheetWiredResult;
    // // @wire(getTimesheetForApproval, { conId: '$recordId', dateFromParam: '$dateFrom', dateToParam: '$dateTo' })
    // @wire(getTimesheetForApprovalByEmployeeId, { employeeId: '$employeeId', dateFromParam: '$dateFrom', dateToParam: '$dateTo' })
    // timesheetDataWire(result) {
    //     this.timesheetWiredResult = result;
    //     if (result.data) {
    //         console.log(':::: timeSheetData:', result.data);
    //         let finalData = result.data.map(ele => {
    //             return { ...ele, showOptions: false, approvalScreen: true };
    //         });
    //         finalData.sort((a, b) => {
    //             let fa = a.userName.toLowerCase();
    //             let fb = b.userName.toLowerCase();

    //             if (fa < fb) {
    //                 return -1;
    //             }
    //             if (fa > fb) {
    //                 return 1;
    //             }
    //             return 0;
    //         });

    //         this.timeSheetData = finalData;
    //         this.spinLoader = false;
    //     } else if (result.error) {
    //         console.error(':::: Error timeSheetData:', result.error);
    //         this.spinLoader = false;
    //     }
    // }

    //Asir added wire method to show bi weekly view on approval screen
    timesheetWiredResult;
    @wire(getTimesheetByDateByEmployee, { conId: '$employeeId', dateFromParam: '$dateFrom', dateToParam: '$dateTo', timeOption: '$timeOption', status: 'Submitted and Pending for Approval', screen: '$screenType' })
    timesheetDataWire(result) {
        console.log(this.employeeId);
        console.log(this.dateFrom);
        console.log(this.dateTo);
        console.log(this.timeOption);
        this.timesheetWiredResult = result;
        if (result.data) {
            console.log(':::: timeSheetDataapproval:', result.data);
            let finalData = result.data.map(ele => {
                return { ...ele, showOptions: true, approvalScreen: true };
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
            this.initialData = finalData;
        } else if (result.error) {
            console.error(':::: Error timeSheetData:', result.error);
            this.spinLoader = false;
        }
    }

    // @wire(getTimesheetByDateByEmployee, {conId: '$employeeId', dateFromParam: '$dateFrom', dateToParam: '$dateTo', timeOption: '$timeOption', status: 'Submitted and Pending for Approval'})
    // wiredApprovalTimesheet({ error, data }) {
        // console.log(this.employeeId);
        // console.log(this.dateFrom);
        // console.log(this.dateTo);
        // console.log(timeOption);
    //     if (data) {
    //         console.log(data);
    //     } else if (error) {
    //         console.error(error);
    //     }
    // }

    handleRefreshTimesheet(){	
        refreshApex(this.timesheetWiredResult);	
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

    // handleChange(evt) {
    //     let { name, value } = evt.target;
    //     if (name == 'dateFrom') {
    //         this.spinLoader = true;
    //         this.dateFrom = value;
    //         if (this.dateTo < this.dateFrom) {
    //             //alert('To date should not be less than from date');
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Info',
    //                     message: '"Date From" must be earlier than "Date To".',
    //                     variant: 'info',

    //                 })
    //             );
    //             this.spinLoader = false;
    //         }
    //     }
    //     else if (name == 'dateTo') {
    //         this.spinLoader = true;
    //         this.dateTo = value;
    //         if (this.dateTo < this.dateFrom) {
    //             //alert('To date should not be less than from date');
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Info',
    //                     message: '"Date To" must be later than "Date From".',
    //                     variant: 'info',

    //                 })
    //             );
    //             this.spinLoader = false;
    //         }
    //     }
        //add validation

        // if (this.dateTo < this.dateFrom) {
        //     //alert('To date should not be less than from date');
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Info',
        //             message: '"Date To" must be greater than "Date From".',
        //             variant: 'info',

        //         })
        //     );
        //     this.spinLoader = false;
        // }
        //add validation

    // }

    // * EVENT FROM CHILD COMPONENT
    handleRowChecked(evt) {
        console.log('::::: ROW CHECKED');
        let { daydate, dayname, id, emptyrownumber } = evt.detail;
        console.log('daydate : ', daydate);
        console.log('dayname : ', dayname);
        console.log('id : ', id);
        console.log('emptyrownumber ',emptyrownumber);
        let newData = [];

        this.timeSheetData.forEach(ele => {
            let newRow = { ...ele };
            // Update Existing Record
            if (id != undefined && id != null
                && id == ele.id) {
                console.log('Inside Match Id : ', ele.id + ' => ' + id);
                newRow.checked = !newRow.checked;
            }
            else if(emptyrownumber != undefined && emptyrownumber != null &&
                ele.emptyRowNumber == emptyrownumber && ele.empty==true){
                newRow.checked = !newRow.checked;
                console.log('Inside Match emptyrownumber : ', ele.emptyrownumber + ' => ' + emptyrownumber);
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
               
                // if (singleElement.id) {
                //     singleElement.checked = true;
                // }
                if (singleElement.disableCheckbox==false) {
                    console.log('::::SingleElement',JSON.stringify(singleElement));
                    singleElement.checked = true;
                }
                finalList.push(singleElement);
            });
        }
        else {
            this.timeSheetData.forEach(element => {
                let singleElement = { ...element };
                // if (singleElement.id) {
                //     singleElement.checked = false;
                // }
                if (singleElement.disableCheckbox==false) {
                    singleElement.checked = false;
                }
                finalList.push(singleElement);
            });
        }
        this.timeSheetData = [...finalList];
    }

       // * SHOW/HIDE SUBMIT BUTTON
       get showSubmitButton() {
        return this.timeSheetData?.filter(ele => ele.inEditMode).length;
    }

    requestMessage = '';
    requestMessage = '';

    handleCancel()
    {
        this.showWarningModal = false;
    }

    handleSave() {
        if(this.showWarningModal || !this.deletedData.length){
            this.showWarningModal = false
            let finalList = [];
        let errorList = [];
        let otErrorList=[];
        this.timeSheetData.forEach(ele => {
            // Only Focus on the rows which are updated.
            // if (ele.inEditMode) {
            //     console.log('INSIDE EDITED ROWS : ', ele);
            //     if (ele.hours >= 0 && ele.hours <= 15) {
            //         finalList.push(ele);
            //     }
            //     else if(ele.hours === undefined){
            //         ele.hours = 0;
            //         finalList.push(ele);
            //     } 
            //     else {
            //         errorList.push(ele);
            //     }
            //     console.log(ele.hours);
            // }
            if (ele.inEditMode) {
                console.log('INSIDE EDITED ROWS : ', ele);
                if(ele.overTime && ele.hours > 0){
                    otErrorList.push(ele);
                }
                else if (ele.hours >= 0 && ele.hours <= 15) {
                    finalList.push(ele);
                }
                else {
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
        else if (otErrorList.length) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in Hours',
                    message: 'Worked Hours should be 0 if you have provided overtime',
                    variant: 'error',
                })
            );
        }
        else if (errorList.length) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error in Hours',
                        message: 'Please provide valid hours for all Time Entires',
                        variant: 'error',
                    })
                );
            }
        else if (finalList.length || this.deletedData.length) {
                
                console.log(':::: finalList : ', JSON.stringify(finalList));
                console.log(':::: this.timeSheetData : ', JSON.stringify(this.timeSheetData));
    
                if(this.deletedData.length)
                {
                    deleteRecords({deletedId: this.deletedData}).then(result =>{
                        if (result == 'OK') {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Records Deleted Permanently',
                                    message: 'Records have been deleted permanently.',
                                    variant: 'success'
                                })
                            );
                        }
                        else
                        {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Issues in deleting records',
                                    message: 'A problem has occured during deletion. Please refresh the page.',
                                    variant: 'error'
                                })
                            );
                        }
                    });
                }

                if(finalList.length)
                {
                    this.spinLoader = true;
                    saveRecordsFromManager2({ timesheetsToSave: finalList, conId: this.employeeId })
                    .then(result => {
                        console.log('Result', result);
                        if (result == 'OK') {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Timesheet Submitted',
                                    message: 'Timesheet submitted successfully.',
                                    variant: 'success'
                                })
                            );
                        }
                        else {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Some Issue in Submitting',
                                    message: 'Timesheet was not saved successfully. If this error keeps coming up then contact your System Administrator.',
                                    variant: 'info'
                                })
                            );
                        }
                        this.isDeleted = false;
                        this.deletedData = [];
                        refreshApex(this.timesheetWiredResult);
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error in Submitting',
                                message: 'Error in submitting timsheet. ' + JSON.stringify(error),
                                variant: 'error',
                                mode: 'sticky'
                            })
                        );
                        this.spinLoader = false;
                    });
                }
                else{
                    //refreshApex(this.timesheetWiredResult);
                    //this.spinLoader = false;
                } 
                
            }
        }
        else
        {
            this.requestMessage = 'ows Overwritten/Deleted.';
            this.requestHeading = 'Existing timesheet row(s) has been overwritten.delete. If you click on Proceed, all the entries related to the rows will be deleted. Refresh your page if you want to revert the changes.';
            this.showWarningModal = true;
        }
    }


    // * ENABLE/DISABLE APPROVE BUTTON
    get noRowSelected() {
        return this.timeSheetData.filter(ele => ele.checked).length > 0 ? false : true;
    }

    handleApprove() {
        this.spinLoader = true;
        let finalList = [];
        this.unlockVal = false;
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


    // reason of rejection modal
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
        this.rejectMessage = `Please enter rejection reason for the user.`;
        this.showRejectModal = true;
        this.rejectHeading = 'Rejection Reason';
        console.log(':::: handleReject');
    }

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
            if ((id != undefined && id != null
                && id == ele.id) && (newRow.submitted==true || newRow.recall==true || newRow.timsheetSaved == true)) {
                console.log('Inside Match Id : ', ele.id + ' => ' + id);
                newRow.inEditMode = true;
                newRow.disableCheckbox=false;
                
                
            }
            // Update Row by emptyrownumber
            else if (emptyrownumber != undefined && emptyrownumber != null &&
                ele.emptyRowNumber == emptyrownumber) {
                console.log('Inside Match emptyrownumber : ', ele.emptyRowNumber + ' => ' + emptyrownumber);
                newRow.inEditMode = true;
                newRow.disableCheckbox=false;
                newRow.contactId = this.employeeId;
                
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
                initialRow.disableCheckbox=true;
                newRow = { ...initialRow };
            }
            newData.push(newRow);
        })
        this.timeSheetData = [...newData];
    }

    handleRowUpdate(evt) {
        let { id, emptyrownumber, name, value, paycode } = evt.detail;
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
                if (name == 'project') {
                    newRow['payCode'] = paycode
                }
            }
            else if (emptyrownumber != undefined && emptyrownumber != null &&
                ele.emptyRowNumber == emptyrownumber) {
                console.log('emptyRowNumber => value : ', value);
                newRow[name] = value;
                if (name == 'project') {
                    newRow['payCode'] = paycode
                }
            }
            newData.push(newRow);
        })
        console.log(JSON.stringify(newData));
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
                additionalRow.overTime = false;
                additionalRow.delible = true;
                additionalRow.showOptions = true;
                additionalRow.disableCheckbox = false;
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

    @track copiedTimesheet = [];
    @track checkPaste = true;
    checkCopy = false;
    
    handleRowCopyOption(evt)
    {
        console.log('Handle copy called in timesheetnew');

        let { id, emptyrownumber, dayname, daydate } = evt.detail;
        console.log('id : ', id);
        console.log('emptyrownumber : ', emptyrownumber);
        console.log('dayname : ', dayname);
        console.log('daydate : ', daydate);
        this.copiedTimesheet = [];

        this.timeSheetData.forEach(index => {
            if(index.dayDate == daydate && index.isEditable == true)
            {
                this.copiedTimesheet.push(index);
                console.log('Copied overtime: ', index.overtimeType);
                this.checkPaste = false;
            }
            
        })

        console.log('Copied timesheet: ', this.copiedTimesheet.length);

        if(this.copiedTimesheet.length){
            this.checkCopy = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Row Copied',
                    message: 'Row has been copied successfully',
                    variant: 'success'
                })
            );
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Unable to save timesheet row',
                    message: 'Please save a timesheet row before copying it',
                    variant: 'info'
                })
            );
        }
    }

    testing = false;
    checkOT = false;
    handleRowPasteOption(evt)
    {
        console.log('Handle paste called in timesheetnew');

        let { id, emptyrownumber, dayname, daydate } = evt.detail;
        console.log('id : ', id);
        console.log('emptyrownumber : ', emptyrownumber);
        console.log('dayname : ', dayname);
        console.log('daydate : ', daydate);
        let newData = [];
        let firstElement = true;
        let checkSameDayDate = false;
        let count = 0;
        let checkCount = true;

        this.copiedTimesheet.forEach(index => {
            if(dayname == index.dayName && daydate == index.dayDate)
            {
                checkSameDayDate = true;
            }
        })

        // if(checkSameDayDate || this.checkCopy)
        if(checkSameDayDate || this.checkCopy)
        {
            this.timeSheetData.forEach(ele => {
                if(ele.dayDate == daydate && ele.dayName == dayname)
                {
                    count++;
                }
            });

            this.timeSheetData.forEach(ele => {
                let newRow = { ...ele };
                let rowFound = false;

                if(ele.dayDate == daydate && ele.dayName == dayname)
                {
                    count--;
                }
    
                // // Update Existing Record
                // if (id != undefined && id != null
                //     && id == ele.id) {
                //     console.log('Inside Match Id : ', ele.id + ' => ' + id);
                //     count--;
                //     rowFound = true;
                // }
                // // Update Row by emptyrownumber
                // else if (emptyrownumber != undefined && emptyrownumber != null &&
                //     ele.emptyRowNumber == emptyrownumber) {
                //     console.log('Inside Match emptyrownumber : ', ele.emptyRowNumber + ' => ' + emptyrownumber);
                //     rowFound = true;
                //     count--;
                // }
                console.log('Coun1t::: ', count);
                newData.push(newRow);
                if(count == 0 && checkCount){
                this.copiedTimesheet.forEach(index =>{
                    //if (rowFound) {
                        console.log('this is called');
                        let additionalRow = { ...index };
                        additionalRow.dayName = dayname;
                        additionalRow.dayDate = daydate;
                        additionalRow.hours = index.hours;
                        additionalRow.totalHours = index.totalHours;
                        additionalRow.project = index.project;
                        additionalRow.projectName = index.projectName;
                        additionalRow.inEditMode = true; // * AUTOMATICALLY EDITABLE NEW ROW
                        additionalRow.emptyRowNumber = Math.random().toString().substring(2, 8);
                        additionalRow.id = null;
                        additionalRow.payCode = index.payCode;
                        additionalRow.combineRow = true;
                        additionalRow.delible = true;
                        additionalRow.timsheetSaved = null;
                        additionalRow.rejected = null;
                        additionalRow.submitted = null;
                        additionalRow.disableCheckbox = false;


                        if(index.overTime)
                            {
                                console.log('index overtime:::: ', index.overTime);
                                additionalRow.overTime = index.overTime;
                                additionalRow.overtimeFrom = index.overtimeFrom;
                                additionalRow.overtimeTo = index.overtimeTo;
                                additionalRow.overtimeDescription = index.overtimeDescription;
                                additionalRow.overtimeType = index.overtimeType;
                                additionalRow.totalOvertimeHours = index.totalOvertimeHours;
                            }

                        additionalRow.showOptions = true;
                        newData.push(additionalRow);
                    
                });
                checkCount = false;
                
            }
            })
            // this.timeSheetData.sort((a,b) =>{
            //     if(a.dayDate == b.dayDate && a.dayName == b.dayName)
            //     {
            //         if(a.hours > b.hours) return -1;
            //         if(a.hours < b.hours) return 1;
            //         return 0;
            //      }
            // });
            console.log('newData : ', newData.length);
            this.timeSheetData = [...newData];
            
        }
        else
        {
            this.timeSheetData.forEach(ele => {
            if(dayname == ele.dayName && daydate == ele.dayDate)
            {
                console.log('Ele hours:::::::: ', ele.hours);
                if(ele.id != null || ele.id !=undefined)
                {
                    this.deletedData.push(ele.id);
                    console.log(`ID::::: ${ele.id}`);
                }

                if(firstElement)
                {
                    // ele.hours = null;
                    // ele.totalHours = null;
                    // ele.project = null;
                    // ele.projectName = null;
                    // ele.inEditMode = false; // * AUTOMATICALLY EDITABLE NEW ROW
                    // ele.emptyRowNumber = Math.random().toString().substring(2, 8);
                    // ele.divisionalOffice = null;
                    // ele.id = null;
                    // ele.status = null;
                    // ele.timsheetSaved = false;
                    // ele.rejected = false;
                    // ele.payCode = null;
                    // ele.overTime = false;
                    // ele.overtimeFrom = null;
                    // ele.overtimeTo = null;
                    // ele.overtimeDescription = null;
                    // ele.overtimeType = null;
                    // ele.totalOvertimeHours = null;
                    // //ele.combineRow = true;
                    // //ele.delible = true;
                    // ele.showOptions = true;

                    firstElement = false;
                    
                }
                else
                {
                    let newRow = {...ele};
                    let rowFound = false;
                    if (ele.id != undefined && ele.id != null) {
                        console.log('***id Found: ', ele.id);
                        rowFound = true;
                        // TODO DELETE FROM SALESFORCE 
                    }
                    else if (ele.emptyRowNumber != undefined && ele.emptyRowNumber != null) {
                        console.log('***emptyRowNumber Found: ', ele.emptyRowNumber);
                        rowFound = true;
                    }
                    if (rowFound) {
                        //newData.push(newRow);
                        this.timeSheetData = this.timeSheetData.filter(function (obj){
                            return obj.id != ele.id || obj.emptyRowNumber != ele.emptyRowNumber
                        });
                    }
                }
                
            }
        });

        console.log('Inside testing');
            this.testing = true;
            firstElement = true;
        
            this.timeSheetData.forEach(ele => {
                let newRow = { ...ele };
                newData.push(newRow);
                if(dayname == ele.dayName && daydate == ele.dayDate)
                {
                    console.log('same daydate dayname')
                    this.copiedTimesheet.forEach(index =>{
                        console.log('Copied index hours: ', index.hours)
                        if(firstElement){
                            console.log('inside copied timesheet 1st index ', index.hours);
                            console.log('element ', ele.hours);
                            // let additionalRow = { ...ele};

                            // additionalRow.dayName = dayname;
                            // additionalRow.dayDate = daydate;
                            // additionalRow.hours = index.hours;
                            // additionalRow.totalHours = null;
                            // additionalRow.project = index.project;
                            // additionalRow.projectName = index.projectName;
                            // additionalRow.inEditMode = true; // * AUTOMATICALLY EDITABLE NEW ROW
                            // additionalRow.emptyRowNumber = Math.random().toString().substring(2, 8);
                            // additionalRow.id = null;
                            // additionalRow.payCode = index.payCode;

                            // // if(index.overTime)
                            // // {
                            // //     console.log('1st element index overtime:::: ', index.overTime);
                            // //     ele.overTime = index.overTime;
                            // //     ele.overtimeFrom = index.overtimeFrom;
                            // //     ele.overtimeTo = index.overtimeTo;
                            // //     ele.overtimeDescription = index.overtimeDescription;
                            // //     ele.overtimeType = index.overtimeType;
                            // //     ele.totalOvertimeHours = index.totalOvertimeHours;

                            // //     this.checkOT = true;
                            // // }
                            // additionalRow.combineRow = false;
                            // additionalRow.delible = false;
                            // additionalRow.showOptions = true;
                            // newData.push(additionalRow);

                            firstElement = false;


                        }
                        else{
                            console.log('Called else if hours: ', index.hours);
                            let additionalRow = { ...index};
                            additionalRow.dayName = dayname;
                            additionalRow.dayDate = daydate;
                            additionalRow.hours = index.hours;
                            additionalRow.timsheetSaved = null;
                            additionalRow.totalHours = null;
                            additionalRow.project = index.project;
                            additionalRow.projectName = index.projectName;
                            additionalRow.inEditMode = true; // * AUTOMATICALLY EDITABLE NEW ROW
                            additionalRow.emptyRowNumber = Math.random().toString().substring(2, 8);
                            additionalRow.id = null;
                            additionalRow.payCode = index.payCode;
                            additionalRow.disableCheckbox = false;

                            if(index.overTime)
                            {
                                console.log('index overtime:::: ', index.overTime);
                                additionalRow.overTime = index.overTime;
                                additionalRow.overtimeFrom = index.overtimeFrom;
                                additionalRow.overtimeTo = index.overtimeTo;
                                additionalRow.overtimeDescription = index.overtimeDescription;
                                additionalRow.overtimeType = index.overtimeType;
                                additionalRow.totalOvertimeHours = index.totalOvertimeHours;
                            }
                            
                            additionalRow.combineRow = true;
                            additionalRow.delible = true;
                            additionalRow.showOptions = true;
                            console.log('Additional row id after paste:::::',index.id);
                            newData.push(additionalRow);
                        }
                    });
                }
            })

            if(newData.length)
            {
                console.log('newData : ', newData.length);
                this.timeSheetData = [...newData];
            }
            

            firstElement = true
            this.timeSheetData.forEach(ele => {
                // let newRow = { ...ele };
                // newData.push(newRow);
                if(dayname == ele.dayName && daydate == ele.dayDate)
                {
                    this.copiedTimesheet.forEach(index =>{
                        //console.log('another first element hours: ', index.hours);
                        if(firstElement){
                            console.log('overtime: ', index.overTime);
                            ele.dayName = dayname;
                            ele.dayDate = daydate;
                            ele.hours = index.hours;
                            ele.totalHours = null;
                            ele.project = index.project;
                            ele.timsheetSaved = null;
                            ele.rejected = null;
                            ele.submitted = null;
                            ele.projectName = index.projectName;
                            ele.inEditMode = true; // * AUTOMATICALLY EDITABLE NEW ROW
                            ele.emptyRowNumber = Math.random().toString().substring(2, 8);
                            ele.id = null;
                            ele.payCode = index.payCode;
                            ele.disableCheckbox = false;

                            if(ele.overTime)
                            {
                                ele.overTime = index.overTime;
                                ele.overtimeFrom = index.overtimeFrom;
                                ele.overtimeTo = index.overtimeTo;
                                ele.overtimeDescription = index.overtimeDescription;
                                ele.overtimeType = index.overtimeType;
                                ele.totalOvertimeHours = index.totalOvertimeHours;
                            }

                            if(index.overTime)
                            {
                                console.log('1st element index overtime:::: ', index.overTime);
                                ele.overTime = index.overTime;
                                ele.overtimeFrom = index.overtimeFrom;
                                ele.overtimeTo = index.overtimeTo;
                                ele.overtimeDescription = index.overtimeDescription;
                                ele.overtimeType = index.overtimeType;
                                ele.totalOvertimeHours = index.totalOvertimeHours;
                            }
                            ele.combineRow = false;
                            ele.delible = false;
                            ele.showOptions = true;

                            firstElement = false;
                        }
                    });
                }
            })
            this.checkCopy = true;
        }
        

        if(this.copiedTimesheet.length){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Row Pasted',
                    message: 'Row has been pasted successfully',
                    variant: 'success'
                })
            );
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Row Not Pasted',
                    message: 'Row unable to be pasted. Try again!',
                    variant: 'error'
                })
            );
        }
        
    }


    isDeleted = false;
    deletedDayDate = '';
    deletedDayName = '';

    handleRowDeleteOption(evt)
    {
        console.log('Handle delete called in timesheetnew');

        let { emptyrownumber, dayname, daydate } = evt.detail;
        //console.log('id : ', id);
        console.log('emptyrownumber : ', emptyrownumber);
        console.log('dayname : ', dayname);
        console.log('daydate : ', daydate);
        let newData = [];
        let firstElement = true;

        //this.spinLoader = true;
        this.timeSheetData.forEach(ele => {
            if(dayname == ele.dayName && daydate == ele.dayDate)
            {
                console.log('Ele hours:::::::: ', ele.hours);
                if(ele.id != null || ele.id !=undefined)
                {
                    this.deletedDayDate = ele.dayDate;
                    this.deletedDayName = ele.dayName;

                    this.deletedData.push(ele.id);
                    console.log(`ID::::: ${ele.id}`);
                }

                if(firstElement)
                {
                    console.log('This is 1st element');
                    console.log('End of 1st element with id => ', ele.id);
                    ele.userName = null
                    ele.hours = null;
                    ele.totalHours = null;
                    ele.project = null;
                    ele.projectName = null;
                    ele.inEditMode = false; // * AUTOMATICALLY EDITABLE NEW ROW
                    ele.emptyRowNumber = Math.random().toString().substring(2, 8);
                    ele.divisionalOffice = null;
                    ele.id = null;
                    ele.status = null;
                    ele.payCode = null;
                    ele.timsheetSaved = false;
                    ele.rejected = false;
                    ele.submitted = false;
                    ele.overTime = false;
                    ele.overtimeFrom = null;
                    ele.overtimeTo = null;
                    ele.overtimeDescription = null;
                    ele.overtimeType = null;
                    ele.totalOvertimeHours = null;
                    //ele.combineRow = true;
                    //ele.delible = true;
                    ele.showOptions = true;

                    firstElement = false;
                    
                }
                else
                {
                    console.log('Other elements');
                    let newRow = {...ele};
                    let rowFound = false;
                    if (ele.id != undefined && ele.id != null) {
                        console.log('***id Found: ', ele.id);
                        rowFound = true;
                        // TODO DELETE FROM SALESFORCE 
                    }
                    else if (ele.emptyRowNumber != undefined && ele.emptyRowNumber != null) {
                        console.log('***emptyRowNumber Found: ', ele.emptyRowNumber);
                        rowFound = true;
                    }
                    if (rowFound) {
                        console.log('*******************row found')
                        newData.push(newRow);
                        this.timeSheetData = this.timeSheetData.filter(function (obj){
                            return obj.id != ele.id || obj.emptyRowNumber != ele.emptyRowNumber
                        });
                    }
                    //this.timeSheetData = [...newData];
                }
            }
        })
        
        if(this.deletedData.length || newData.length || !firstElement){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Row Deleted',
                    message: 'Row has been deleted successfully',
                    variant: 'success'
                })
            );
            if(this.deletedData.length)
            {
                this.isDeleted = true;
            }
            
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Row Not Deleted',
                    message: 'Unable to delete row. Try again!',
                    variant: 'error'
                })
            );
        }
        //this.spinLoader = false;

        
    }
}