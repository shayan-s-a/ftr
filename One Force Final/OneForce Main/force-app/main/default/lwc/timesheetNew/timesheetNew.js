import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTimesheetByDate from '@salesforce/apex/TimesheetController.getTimesheetByDate';
import getImageUrl from '@salesforce/apex/TimesheetController.getImageUrl';
import saveRecords from '@salesforce/apex/TimesheetController.saveRecords';
import saveRecords2 from '@salesforce/apex/TimesheetController.saveRecords2';
import submitRecords from '@salesforce/apex/TimesheetController.submitRecords';
import recallRecords from '@salesforce/apex/TimesheetController.recallRecords';
import deleteRecords from '@salesforce/apex/TimesheetController.deleteRecords';
//import recallRecords from '@salesforce/apex/TimesheetControllerSA.recallRecords';
import { refreshApex } from '@salesforce/apex';
import LightningConfirm from 'lightning/confirm';
import Id from '@salesforce/user/Id';

//import LightningPrompt from 'lightning/prompt';

export default class TimesheetNew extends LightningElement {
    spinLoader = true;
    userId = Id;
    @api userDetails = {};
    get userExist() {
        console.log(`Con Id p: ${this.userDetails.Id}`);
        console.log(`User Picture URL p: ${this.userDetails.SmallBannerPhotoUrl}`);
        console.log(`User p: ${this.userId}`);
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
    @track initialData = [];
    @track deletedData = []; // This is used when we try to refresh so we can get the original data

    imageUrl;
    @wire(getImageUrl, { conId: '$userDetails.Id' })
    profilePhotoUrl(result) {
        try {
            if (result.data) {
                console.log(':::: profilePhotoUrl:', result.data);
                let strData = result.data;
                this.imageUrl = strData;
            } else if (result.error) {
                console.error(':::: Error profilePhotoUrl:', result.error);
            }
        }
        catch (err) {
            console.log('error');
            console.log(err.message);
        }
    }



    timesheetWiredResult;
    @wire(getTimesheetByDate, { conId: '$recordId', dateFromParam: '$dateFrom', dateToParam: '$dateTo', timeOption: '$timeOption' })
    timesheetDataWire(result) {
        this.timesheetWiredResult = result;
        this.spinLoader = false;
        if (result.data) {
            console.log(':::: timeSheetData:::', result.data);
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
        } else if (result.error) {
            console.error(':::: Error timeSheetData:', result.error);
        }
    }

    handleChange(evt) {
        let { name, value } = evt.target;
        this.spinLoader = true;
        if (name == 'timeOption') {
            this.timeOption = value;
        }
        else if (name == 'dateFrom') {
            this.timeOption = 'Range of Dates';
            this.dateFrom = value;
            let firstDate = new Date(value);
            let lastDate = new Date(this.dateTo);
            let diff = lastDate.getTime() - firstDate.getTime();
            let days = diff / (1000 * 60 * 60 * 24);
            console.log(':::: days' + days);

            if (days > 62) {
                this.spinLoader = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Info',
                        message: 'Maximum of 62 days timesheet can be fetched.',
                        variant: 'info',
                    })
                );
                return;
            }
            console.log('this.dateFrom : ', this.dateFrom);
            if (days < 0) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Info',
                        message: '"Date From" must be earlier than "Date To".',
                        variant: 'info',

                    })
                );
            }
        }
        else if (name == 'dateTo') {
            this.timeOption = 'Range of Dates';
            this.dateTo = value;
            let firstDate = new Date(this.dateFrom);
            let lastDate = new Date(value);
            let diff = lastDate.getTime() - firstDate.getTime();

            let days = diff / (1000 * 60 * 60 * 24);

            console.log(':::: days' + days);

            if (days > 62) {
                this.spinLoader = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Info',
                        message: 'Maximum of 62 days timesheet can be fetched.',
                        variant: 'info',
                    })
                );
                return;
            }


            if (days < 0) {
                //alert('To date should not be less than from date');
                this.dispatchEvent(

                    new ShowToastEvent({

                        title: 'Info',

                        message: 'Maximum of 62 days timesheet can be fetched.',

                        variant: 'info',

                    })

                );

            }





            if (days < 0) {

                //alert('To date should not be less than from date');

                this.dispatchEvent(

                    new ShowToastEvent({

                        title: 'Info',

                        message: '"Date To" must be later than "Date From".',

                        variant: 'info',




                    })

                );




            }

        }

    }


    handleFind() {
        if (this.dateFrom && this.dateTo) {
            if (this.dateFrom > this.dateTo) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Info',
                        message: '"Date From" must be less than "Date To".',
                        variant: 'info'
                    })
                );
            }
            else {
                this.spinLoader = true;
                // Call Apex
                getTimesheetByDate({ conId: this.recordId, dateFromParam: this.dateFrom, dateToParam: this.dateTo })
                    .then(result => {
                        console.log(':::: Timesheet Find Data: ', result);
                        this.timeSheetData = result;
                        this.initialData = result;
                        this.spinLoader = false;
                    })
                    .catch(error => {
                        console.log(':::: Timesheet Find Error: ', error);
                        this.spinLoader = false;
                    });
            }
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Info',
                    message: 'Please select both "Date From" and "Date To".',
                    variant: 'info'
                })
            );
        }
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
                console.log('empty row: ', emptyrownumber);
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
        // console.log('paycode : ', paycode);
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
        this.timeSheetData = [...newData];
        console.log('newDAta',JSON.stringify(this.timeSheetData));
    }

    // handleAddRow(evt) {
    //     let { id, emptyrownumber, dayname, daydate } = evt.detail;
    //     console.log('id : ', id);
    //     console.log('emptyrownumber : ', emptyrownumber);
    //     console.log('dayname : ', dayname);
    //     console.log('daydate : ', daydate);
    //     let newData = [];
    //     this.timeSheetData.forEach(ele => {
    //         let newRow = { ...ele };
    //         let rowFound = false;

    //         // Update Existing Record
    //         if (id != undefined && id != null
    //             && id == ele.id) {
    //             console.log('Inside Match Id : ', ele.id + ' => ' + id);
    //             rowFound = true;
    //         }
    //         // Update Row by emptyrownumber
    //         else if (emptyrownumber != undefined && emptyrownumber != null &&
    //             ele.emptyRowNumber == emptyrownumber) {
    //             console.log('Inside Match emptyrownumber : ', ele.emptyRowNumber + ' => ' + emptyrownumber);
    //             rowFound = true;
    //         }
    //         newData.push(newRow);
    //         if (rowFound) {
    //             let additionalRow = { ...ele };
    //             additionalRow.hours = null;
    //             additionalRow.totalHours = null;
    //             additionalRow.project = null;
    //             additionalRow.projectName = null;
    //             additionalRow.inEditMode = true; // * AUTOMATICALLY EDITABLE NEW ROW
    //             additionalRow.emptyRowNumber = Math.random().toString().substring(2, 8);
    //             additionalRow.id = null;
    //             additionalRow.payCode = null;
    //             additionalRow.combineRow = true;
    //             additionalRow.delible = true;
    //             additionalRow.overTime = false;
    //             additionalRow.overtimeFrom = null;
    //             additionalRow.overtimeTo = null;
    //             additionalRow.overtimeDescription = null;
    //             additionalRow.overtimeType = null;
    //             additionalRow.totalOvertimeHours = null;
    //             additionalRow.showOptions = true;
    //             newData.push(additionalRow);
    //         }
    //     })
    //     console.log('newData : ', newData.length);
    //     this.timeSheetData = [...newData];
    // }

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
                additionalRow.overTime = false;
                additionalRow.overtimeFrom = null;
                additionalRow.overtimeTo = null;
                additionalRow.overtimeDescription = null;
                additionalRow.overtimeType = null;
                additionalRow.totalOvertimeHours = null;
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
                console.log('*******************not found')
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
                            ele.projectName = index.projectName;
                            ele.inEditMode = true; // * AUTOMATICALLY EDITABLE NEW ROW
                            ele.emptyRowNumber = Math.random().toString().substring(2, 8);
                            ele.id = null;
                            ele.payCode = index.payCode;

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



    handleSave() {
       if(this.showWarningModal || !this.deletedData.length)
       {
        this.showWarningModal = false;
        let finalList = [];
        let errorList = [];
        let otErrorList = [];
        let saveRecordCheck = false;

        this.timeSheetData.forEach(ele => {
            // Only Focus on the rows which are updated.
            if (ele.inEditMode) {
                console.log('INSIDE EDITED ROWS : ', ele);
                if(ele.overTime && ele.hours > 0){
                    saveRecordCheck = true;
                    otErrorList.push(ele);
                }
                else if (ele.hours >= 0 && ele.hours <= 15) {
                    saveRecordCheck = true;
                    finalList.push(ele);
                }
                else {
                    console.log(ele.dayDate);
                    errorList.push(ele);
                }
            }
            // else if(this.isDeleted)
            // {
            //     if(this.deletedDayDate == ele.dayDate && this.deletedDayName == ele.dayName)
            //     {
            //         console.log('Inside deleted date')
            //         finalList.push(ele);
            //     }
            // }
            

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
        else if (finalList.length || this.deletedData.length) {
            

            console.log(':::: finalList : ', finalList.length);
            console.log(':::: deletedData : ', this.deletedData.length);
                

            if(this.deletedData.length)
            {
                deleteRecords({deletedId: this.deletedData}).then(result =>{
                    if (result == 'OK') {
                        this.deletedData = [];
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
                }).catch(error => {
                    console.error('Error:', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error in Deleting',
                            message: 'Error in deleting timsheet. ' + JSON.stringify(error),
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );
                });
            }
            
            

            if(finalList.length)
            {
                this.spinLoader = true;
                saveRecords2({ timesheetsToSave: finalList, conId: this.recordId})
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
                        this.isDeleted = false;
                        // this.deletedData = [];
                        refreshApex(this.timesheetWiredResult);
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
            // else{
            //     //refreshApex(this.timesheetWiredResult);
            //     //this.spinLoader = false;
            // }            

            
        }
       }
       else
        {
            // this.requestMessage = 'Select day/date to submit the request to edit timesheet.';
            // this.requestHeading = 'Timesheet row(s) has been delete. If you click on Proceed, all the entries related to the rows will be deleted. Refresh your page if you want to revert the changes.';
            this.showWarningModal = true;
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



    handleRefreshTimesheet(){
        refreshApex(this.timesheetWiredResult);
    }

    // <----------------- request to edit pop-up------------------>

    showWarningModal = false;
    showrequestModal = false;
    requestMessage = '';

    handlerequestCancel() {
        this.showrequestModal = false;
        this.showWarningModal = false;
    }

    handlerequestSave(evt) {
        //Asir made changes here to check date time issue in unlock request object in salesforce
        const dateF = new Date(this.dateFrom);
        const dateT = new Date(this.dateTo);
        this.showrequestModal = false;
        this.spinLoader = true;
        let finalList = [];
        this.timeSheetData.forEach(ele => {
            // Only Focus on the rows which are Submitted.
            if (ele.submitted && evt.detail.checkedRow.includes(ele.id)) {
                finalList.push(ele);
                console.log('Element: ', ele.Id);
            }
        })

        recallRecords({ timesheets: finalList, conId: this.recordId, reason: evt.detail.reason, dateF, dateT, dateFNew: this.dateFrom, dateTNew: this.dateTo, payPeriod: this.timeOption })
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

        // recallRecords({ timesheets: finalList, conId: this.recordId, reason: evt.detail, dateF, dateT, dateFNew:this.dateFrom, dateTNew:this.dateTo, payPeriod: this.timeOption })
        //     .then(result => {
        //         console.log('Result', result);
        //         if (result == 'OK') {
        //             this.dispatchEvent(
        //                 new ShowToastEvent({
        //                     title: 'Request Sent to Manager',
        //                     message: 'Request To Edit the "Submitted Timesheet" is sent to your manager successfully.',
        //                     variant: 'success'
        //                 })
        //             );
        //         }
        //         else {
        //             this.dispatchEvent(
        //                 new ShowToastEvent({
        //                     title: 'Some Issue in Recalling',
        //                     message: 'Unable to recall timesheet. If this error keeps coming up then contact your System Administrator.',
        //                     variant: 'info'
        //                 })
        //             );
        //         }
        //         refreshApex(this.timesheetWiredResult);
        //     })
        //     .catch(err => {
        //         console.error('Error:', err);
        //         this.dispatchEvent(
        //             new ShowToastEvent({
        //                 title: 'Error in Recalling',
        //                 message: 'Error in recalling timsheet to edit. ' + JSON.stringify(err),
        //                 variant: 'error',
        //                 mode: 'sticky'
        //             })
        //         );
        //         this.spinLoader = false;
        //     })

    }

    handleRecall() {
        const dateF = new Date(this.dateFrom);
        const dateT = new Date(this.dateTo);
        this.requestMessage = 'Select day/date to submit the request to edit timesheet.';
        this.showrequestModal = true;
        this.requestHeading = 'Request To Edit Timesheet';




        // LightningPrompt.open({
        //     label: 'Request to Edit Timesheet', // this is the header text
        //     message: `Your request to edit "Submitted Timesheets" between *${dateF.toString().substring(0, 15)} - ${dateT.toString().substring(0, 15)}* will be sent to your manager.`,
        //     defaultValue: '', //this is optional
        // }).then((result) => {
        //     if (result) {
        //         this.spinLoader = true;
        //         let finalList = [];
        //         this.timeSheetData.forEach(ele => {
        //             // Only Focus on the rows which are Submitted.
        //             if (ele.submitted) {
        //                 finalList.push(ele);
        //             }
        //         })
        //         recallRecords({ timesheets: finalList, conId: this.recordId, reason: result, dateF, dateT, payPeriod: this.timeOption })
        //             .then(result => {
        //                 console.log('Result', result);
        //                 if (result == 'OK') {
        //                     this.dispatchEvent(
        //                         new ShowToastEvent({
        //                             title: 'Request Sent to Manager',
        //                             message: 'Request To Edit the "Submitted Timesheet" is sent to your manager successfully.',
        //                             variant: 'success'
        //                         })
        //                     );
        //                 }
        //                 else {
        //                     this.dispatchEvent(
        //                         new ShowToastEvent({
        //                             title: 'Some Issue in Recalling',
        //                             message: 'Unable to recall timesheet. If this error keeps coming up then contact your System Administrator.',
        //                             variant: 'info'
        //                         })
        //                     );
        //                 }
        //                 refreshApex(this.timesheetWiredResult);
        //             })
        //             .catch(err => {
        //                 console.error('Error:', err);
        //                 this.dispatchEvent(
        //                     new ShowToastEvent({
        //                         title: 'Error in Recalling',
        //                         message: 'Error in recalling timsheet to edit. ' + JSON.stringify(err),
        //                         variant: 'error',
        //                         mode: 'sticky'
        //                     })
        //                 );
        //                 this.spinLoader = false;
        //             })
        //     }
        //     else {

        //         this.dispatchEvent(
        //             new ShowToastEvent({
        //                 title: 'Reason Required',
        //                 message: 'You have to enter reason.',
        //                 variant: 'info'
        //             })
        //         );

        //     }
        // });
    }
}