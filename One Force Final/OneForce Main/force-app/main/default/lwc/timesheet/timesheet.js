import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUserDetails from '@salesforce/apex/TimesheetController.getUserDetails';
// import getUserProjects from '@salesforce/apex/TimesheetController.getUserProjects';
import getTimesheetByDate from '@salesforce/apex/TimesheetController.getTimesheetByDate';
import saveRecords from '@salesforce/apex/TimesheetController.saveRecords';
import { refreshApex } from '@salesforce/apex';

export default class Timesheet extends LightningElement {
    spinLoader = true;
    @api recordId;
    nameInitials = 'KS';
    taxId = '11223344';
    positionId = '77223355';
    fullName = 'Khan, Sherbaz';
    role = '001 - Salesforce Developer';
    rigionalOffice = 'Digital Process - C2C T&A Only';
    timeOption = 'Custom';
    get timeOptions() {
        return [
            // { label: 'Next Pay Period', value: 'Next Pay Period' },
            { label: 'Custom', value: 'Custom' }
        ];
    }
    dateFrom;
    dateTo;
    @track timeSheetData = [];
    @track updatedSheet = [];
    @track initialData = []; // This is used when we try to refresh so we can get the original data

    /*
    @track projects = [];
    @track timeSheetDate = [{ Id: 1, checked: true, day: 'Monday' }, { Id: 2, checked: true, day: 'Tuesday' }, { Id: 3, checked: true, day: 'Wednesday' }, { Id: 4, checked: false, day: 'Thursday' }, { Id: 5, checked: false, day: 'Firday' }];
    
    @wire(getUserProjects, { conId: '$recordId' })
    wiredData({ error, data }) {
        if (data) {
            data.forEach(element => {
                console.log(':::: OUTPUT : ', element.label + ' ' + element.value);
                this.projects.push({ label: element.label, value: element.value });
            });
            this.timeSheetDate = this.timeSheetDate.map(time => {
                return { ...time, projects: this.projects };
            })
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Projects',
                    message: 'Error in getting projects for this user.',
                    variant: 'error'
                })
            );
        }
    }
    */

    timesheetWiredResult;
    @wire(getTimesheetByDate, { conId: '$recordId', dateFromParam: '$dateFrom', dateToParam: '$dateTo' })
    timesheetDataWire(result) {
        this.timesheetWiredResult = result;
        if (result.data) {
            console.log(':::: timeSheetData:', result.data);
            this.timeSheetData = result.data;
            this.initialData = result.data;
            this.spinLoader = false;
        } else if (result.error) {
            console.error(':::: Error timeSheetData:', result.error);
            this.spinLoader = false;
        }
    }

    @wire(getUserDetails, { conId: '$recordId' })
    userData({ error, data }) {
        if (data) {
            console.log(':::: User Details:', data);
            this.dateFrom = data.dateFrom;
            this.dateTo = data.dateTo;
            this.fullName = data.LastName + ', ' + data.FirstName;
            this.nameInitials = data.FirstName.charAt(0) + data.LastName.charAt(0);
            // this.spinLoader = false;
        } else if (error) {
            console.error(':::: Error:', error);
            // this.spinLoader = false;
        }
    }

    handleChange(evt) {
        let { name, value } = evt.target;
        if (name == 'timeOption') {
            this.timeOption = value;
        }
        else if (name == 'dateFrom') {
            this.dateFrom = value;
        }
        else if (name == 'dateTo') {
            this.dateTo = value;
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

    get isSheetNotUpdated() {
        if (this.timeSheetData?.filter(ele => ele.inEditMode).length) {
            return false;
        }
        return true;
    }

    handleRowEdit(evt) {
        let { daydate, dayname, id, emptyrownumber } = evt.target.dataset;
        console.log('daydate : ', daydate);
        console.log('dayname : ', dayname);
        console.log('id : ', id);
        console.log('emptyrownumber : ', emptyrownumber);

        // Check if the row is already in Edit Mode then Don't do Anything, otherwise make editable
        if (this.timeSheetData.filter(ele => {
            if ((id != undefined && id != null
                && id == ele.id && ele.inEditMode) ||
                emptyrownumber != undefined && emptyrownumber != null &&
                ele.emptyRowNumber == emptyrownumber && ele.inEditMode) {
                return true;
            }
        }).length) {
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

    }

    handleRowRefresh(evt) {
        let { daydate, dayname, id, emptyrownumber } = evt.target.dataset;
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
        let { id, emptyrownumber, name } = evt.target.dataset;
        console.log('id : ', id);
        console.log('emptyrownumber : ', emptyrownumber);
        console.log('name : ', name);
        console.log('evt.target.value : ', evt.target.value);
        let newData = [];

        this.timeSheetData.forEach(ele => {
            let newRow = { ...ele };
            if (id != undefined && id != null
                && id == ele.id) {
                console.log('id => evt.target.value : ', evt.target.value);
                newRow[name] = evt.target.value;
            }
            else if (emptyrownumber != undefined && emptyrownumber != null &&
                ele.emptyRowNumber == emptyrownumber) {
                console.log('emptyRowNumber => evt.target.value : ', evt.target.value);
                newRow[name] = evt.target.value;
            }
            newData.push(newRow);
        })
        this.timeSheetData = [...newData];
    }

    handleSave() {
        this.spinLoader = true;
        let finalList = [];
        this.timeSheetData.forEach(ele => {
            // Only Focus on the rows which are updated.
            if (ele.inEditMode) {
                // Update Record
                //if (ele.id) {
                //finalList.push(ele);
                //}
                // Create Record
                //else if (ele.emptyRowNumber == 0 || ele.emptyRowNumber) {
                //    finalList.push(ele);
                //}
                finalList.push(ele);
            }
        })
        // this.initialData = [];
        // this.timeSheetData = [];
        // this.updatedSheet = [];
        console.log('OUTPUT : ', this.timeSheetData);
        saveRecords({ timesheetsToSave: finalList, conId: this.recordId })
            .then(result => {
                console.log('Result', result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Records Saved',
                        message: 'Timesheet Saved Successfully.',
                        variant: 'success'
                    })
                );
                refreshApex(this.timesheetWiredResult);


            })
            .catch(error => {
                console.error('Error:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error in Saving',
                        message: 'Error in saving timsheet. ' + JSON.stringify(error),
                        variant: 'error'
                    })
                );
                this.spinLoader = false;
            });
    }
}