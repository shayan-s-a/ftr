import { LightningElement, track, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getUpdateRequestEmployeeListNewV2 from '@salesforce/apex/TimesheetController.getUpdateRequestEmployeeListNewV2';
import getUserListToShowForView from '@salesforce/apex/TimesheetController.getUserListToShowForView';

import getUserListToShowForApproval from '@salesforce/apex/TimesheetController.getUserListToShowForApproval';

import getDivisonalOffices from '@salesforce/apex/TimesheetController.getDivisonalOffices';
import getUserProjectByUserId from '@salesforce/apex/TimesheetController.getUserProjectByUserId';

import Id from '@salesforce/user/Id';

export default class TimesheetRequestEmployees extends LightningElement {
    @api screenType;

    get isApprovalScreen() {
        return this.screenType == 'Approval' ? true : false;
    }
    get isUnlockScreen() {
        return this.screenType == 'Unlock' ? true : false;
    }
    get isViewScreen() {
        return this.screenType == 'View' ? true : false;
    }

    get showDates() {
        return !this.isApprovalScreen;
    }

    get showFilterButton() {
        return !this.isApprovalScreen;
    }

    approvalStatus;
    @track approvalStatuses = [
        { label: '--None--', value: '' }
    ];

    get timesheetEmpListRes() {
        if (this.isApprovalScreen && this.timesheetForApproval?.length) return this.timesheetForApproval;
        else if (this.isUnlockScreen && this.timesheetForUnlock?.length) return this.timesheetForUnlock;
        else if (this.isViewScreen && this.timesheetForView?.length) return this.timesheetForView;
        else return [];
    }
    @api dateFrom;
    @api dateTo;
    dateToLocaleStr;
    dateFromLocaleStr;
    @api empId;
    @api timeOption = 'Current Pay Period';
    @api recordId;
    @api isNesponManager = false;
    @api isDivisionalHead = false;
    @api isHRPractitioner = false;
    @api isLineManager = false;
    showChildComponent = false;
    sortBy = 'asc';
    // @track spinLoader;
    @track employeeId;
    @track positionId;
    @track divisionalOffice;
    @track showFilteredData = false;
    divisionalOfficesVals;
    dateFromStored = false;
    dateToStored = false;
    prevDateFrom;
    prevDateTo;
    @track timesheetForUnlock = [];
    project;
    @track projects = [];
    dateFromFilter;
    dateToFilter;
    timeOptionFilter;
    @track filteredData = [];
    dateToForRow;
    dateFromForRow;

    connectedCallback(){
        setTimeout(() => {
            if (this.showProjectDropDown==false || this.isApprovalScreen==false) {
                const targetElement = this.template.querySelector('.custommargin');
                if (targetElement) {
                targetElement.classList.add('remove_margin_left');
                }
            }
            if (this.isApprovalScreen==true) {
                const targetElement = this.template.querySelector('.custommargin');
                if (targetElement) {
                targetElement.classList.remove('remove_margin_left');
                }
            }
          }, 0);
    }

    get timeOptions() {
        return [
            { label: 'Current Pay Period', value: 'Current Pay Period' },
            { label: 'Next Pay Period', value: 'Next Pay Period' },
            { label: 'Previous Pay Period', value: 'Previous Pay Period' },
           // { label: 'Range of Dates', value: 'Range of Dates' },
        ];
    }

    get showDivisionalDropDown() {
        // return (this.isNesponManager || this.isHRPractitioner || this.isDivisonalHead) ? true : false;
        return !this.isViewScreen;
    }

    get getterFilteredData() {
        return (this.filteredData.length > 0)
    }

    get showProjectDropDown() {
        return this.isViewScreen;
    }

    userId = Id;
    @wire(getDivisonalOffices, { userId: '$userId', isNesponManager: '$isNesponManager', isDivisionalHead: '$isDivisionalHead', isHRPractitioner: '$isHRPractitioner' })
    divisionalOfficeWireData(result) {
        if (result.data) {
            console.log(':::: divisionalOfficeVals:', result);
            this.divisionalOfficesVals = Object.keys(result.data).map((key) => ({
                label: result.data[key],
                value: key
            }));
            this.spinLoader = false;
        } else if (result.error) {
            console.error(':::: Error divisionalOfficeVals:', result.error);
            this.spinLoader = false;
        }
    }

    @wire(getUserProjectByUserId, { userId: '$userId' })
    projectsWireData({ data, error }) {
        if (data) {
            console.log(':::: GET PROJECT DATA ', data);
            let projData=[{ label: 'None', value: '' }];
            // projData.push({ label: 'None', value: '' })

            for (let index = 0; index < data.length; index++) {
                projData.push(data[index]);
            }
            this.projects = projData;

        } else if (error) {
            console.log(':::: GET PROJECT ERROR ', error);
        }
    }

    // @track timesheetEmpListRes;
    @track timesheetForApproval = [];
    @wire(getUserListToShowForApproval, { conId: '$recordId', isNesponManager: '$isNesponManager', isDivisionalHead: '$isDivisionalHead', isHRPractitioner: '$isHRPractitioner' })
    approvetimesheetEmpDataWire(result) {
        let startDate =  new Date(this.dateFrom);
        let endDate =  new Date(this.dateTo);
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        this.dateFromLocaleStr = startDate.toLocaleDateString('en-US', options);
        this.dateToLocaleStr = endDate.toLocaleDateString('en-US', options);
        if (result.data) {
            console.log(':::: timesheetForApproval:', result.data);
            // this.timesheetEmpListRes = result.data;
            this.timesheetForApproval = result.data;
            this.spinLoader = false;
            this.showFilteredData = false;
            this.employeeId = '';
            this.positionId = '';
            this.divisionalOffice = '';
            let newArr = [{ label: '--None--', value: '' }];
            let newUniqueArr = new Set();
            this.timesheetForApproval.forEach(ele => {
                newUniqueArr.add(ele.approvalStatus);
            })
            newUniqueArr.forEach(ele => newArr.push({ label: ele, value: ele }))
            this.approvalStatuses = [...newArr];
        } else if (result.error) {
            console.error(':::: Error timesheetForApproval:', result.error);
            this.spinLoader = false;
        } else {
            console.log(':::: RESULT: approval ' + result);
        }
    }

    @wire(getUpdateRequestEmployeeListNewV2, { conId: '$recordId', dateFromParam: '$dateFrom', dateToParam: '$dateTo', timeOption: '$timeOption', isNesponManager: '$isNesponManager', isDivisionalHeadUnlock: '$isDivisionalHead', isHRPractitionerUnlock: '$isHRPractitioner' })
    unlocktimesheetEmpData(result) {
        let startDate =  new Date(this.dateFrom);
        let endDate =  new Date(this.dateTo);
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        this.dateFromLocaleStr = startDate.toLocaleDateString('en-US', options);
        this.dateToLocaleStr = endDate.toLocaleDateString('en-US', options);
        if (result.data) {
            console.log(':::: timesheetForUnlock:', result.data);
            //this.timesheetEmpListRes = result.data;
            this.timesheetForUnlock = result.data;
            this.spinLoader = false;
            this.showFilteredData = false;
            this.employeeId = '';
            this.positionId = '';
            this.divisionalOffice = '';

        } else if (result.error) {
            console.error(':::: Error timesheetForUnlock:', result.error);
            this.spinLoader = false;
        } else {
            console.log(':::: timesheetForUnlock ELSE ' + JSON.stringify(result));
        }
    }

    @track timesheetForView = []; // here conId = Project Manager Id
    @wire(getUserListToShowForView, { conId: '$recordId', dateFromParam: '$dateFrom', dateToParam: '$dateTo', timeOption: '$timeOption' })
    viewtimesheetEmpData(result) {
        let startDate =  new Date(this.dateFrom);
        let endDate =  new Date(this.dateTo);
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        this.dateFromLocaleStr = startDate.toLocaleDateString('en-US', options);
        this.dateToLocaleStr = endDate.toLocaleDateString('en-US', options);
        if (result.data) {
            console.log(':::: timesheetForView:', result.data);
            //this.timesheetEmpListRes = result.data;
            this.timesheetForView = result.data;
            this.spinLoader = false;
            this.showFilteredData = false;
            this.employeeId = '';
            this.positionId = '';
            this.divisionalOffice = '';

        } else if (result.error) {
            console.error(':::: Error timesheetForView:', result.error);
            this.spinLoader = false;
        } else {
            console.log(':::: timesheetForView ELSE ' + JSON.stringify(result));
        }
        console.log(':::: timesheetForView END');
    }

    handleSearchChange(e) {
        let { name, value } = e.target;
        if (name == 'employeeId') {
            this.employeeId = value;
            this.positionId = '';
            if (this.divisionalOffice) {
                this.filteredData = this.timesheetEmpListRes.filter(item => {
                    return item.userName.toLowerCase().includes(this.employeeId.toLowerCase()) && item.divisionalOffice.toLowerCase().includes(this.divisionalOffice.toLowerCase())
                });
            }
            else {
                this.filteredData = this.timesheetEmpListRes.filter(item => {
                    return item.userName.toLowerCase().includes(this.employeeId.toLowerCase())
                });
            }
            this.showFilteredData = true;
        }
        else if (name == 'positionId') {
            this.employeeId = '';
            this.positionId = value;
            if (this.divisionalOffice) {
                this.filteredData = this.timesheetEmpListRes.filter(item => {
                    return item.reqPositionId!=undefined && item.reqPositionId.toLowerCase().includes(this.positionId.toLowerCase()) && item.divisionalOffice.toLowerCase().includes(this.divisionalOffice.toLowerCase())
                });
            }
            else {
                this.filteredData = this.timesheetEmpListRes.filter(item => {
                    return item.reqPositionId!=undefined && item.reqPositionId.toLowerCase().includes(this.positionId.toLowerCase())
                });
            }
            this.showFilteredData = true;
        }

        else if (name == 'project') {
            this.employeeId = '';
            this.positionId = '';
            if (value) {
                this.project = value;
                this.filteredData = this.timesheetEmpListRes.filter(item => {
                    return item.projectName.toLowerCase().includes(this.project.toLowerCase());
                });
                this.showFilteredData = true;
            } else {
                this.project = '';
                this.filteredData = [];
                this.showFilteredData = false;
            }
        }

        else if (name == 'divisionalOffice') {
            this.employeeId = '';
            this.positionId = '';
            if (value) {
                console.log('value: ' + value);
                this.divisionalOffice = value;
                this.filteredData = this.timesheetEmpListRes.filter(item => {
                    return item.divisionalOffice.toLowerCase().includes(this.divisionalOffice.toLowerCase());
                });
                this.showFilteredData = true;
            } else {
                console.log('else value: ' + value);
                this.divisionalOffice = '';
                this.filteredData = [];
                this.showFilteredData = false;
            }
        } else if (name == 'approvalStatus') {
            this.employeeId = '';
            this.positionId = '';
            if (value) {
                this.approvalStatus = value;
                this.filteredData = this.timesheetEmpListRes.filter(item => {
                    return item.approvalStatus.toLowerCase().includes(this.approvalStatus.toLowerCase());
                });
                this.showFilteredData = true;
            } else {
                this.approvalStatus = '';
                this.filteredData = [];
                this.showFilteredData = false;
            }
        }
    }

    filterRecs(e) {
        this.dateFrom = this.dateFromFilter ? this.dateFromFilter : this.dateFrom;
        this.dateTo = this.dateToFilter ? this.dateToFilter : this.dateTo;
        this.timeOption = this.timeOptionFilter ? this.timeOptionFilter : this.timeOption;

        console.log('lksajdklasjdklasjklda:::: ',this.dateFrom, this.dateTo, this.timeOption );
    }

    handleChange(e) {
        let { name, value } = e.target;
        console.log('here1');
        if (name == 'timeOption') {
            if (!this.dateFromStored) {
                console.log('here2');
                this.prevDateFrom = this.dateFrom;
                this.dateFromStored = true;
            }
            if (!this.dateToStored) {
                console.log('here3');
                this.prevDateTo = this.dateTo;
                this.dateToStored = true;
            }
            // this.timeOptionFilter = value;
            if (value == 'Current Pay Period') {
                // this.dateFromFilter = this.prevDateFrom ? this.prevDateFrom : this.dateFrom;
                // this.dateToFilter = this.prevDateTo ? this.prevDateTo : this.dateTo;
                this.dateFrom = this.prevDateFrom ? this.prevDateFrom : this.dateFrom;
                this.dateTo = this.prevDateTo ? this.prevDateTo : this.dateTo;
            }
            else if (value == 'Next Pay Period') {
                let startDate =  new Date(this.prevDateTo);
                let endDate =  new Date(this.prevDateTo);
                startDate.setDate(startDate.getDate() + 2);
                endDate.setDate(endDate.getDate() + 15);
           
                let [month, day, year] = startDate.toLocaleDateString().split('/');
                let finalStartDate = new Date(`${year}-${month}-${day}`);
                this.dateFrom = finalStartDate.toISOString().split('T')[0];
                [month, day, year] = endDate.toLocaleDateString().split('/');
                let finalEndDate = new Date(`${year}-${month}-${day}`);
                this.dateTo = finalEndDate.toISOString().split('T')[0];
            }
            else if (value == 'Previous Pay Period') {
                let startDate =  new Date(this.prevDateFrom);
                let endDate =  new Date(this.prevDateFrom);
                startDate.setDate(startDate.getDate() - 13);
                endDate.setDate(endDate.getDate() - 0);
                let [month, day, year] = startDate.toLocaleDateString().split('/');
                let finalStartDate = new Date(`${year}-${month}-${day}`);
                this.dateFrom = finalStartDate.toISOString().split('T')[0];
                [month, day, year] = endDate.toLocaleDateString().split('/');
                let finalEndDate = new Date(`${year}-${month}-${day}`);
                this.dateTo = finalEndDate.toISOString().split('T')[0];
            }
            this.timeOption = value;
            refreshApex(this.timesheetForApproval);
        }
    }

    handleRowClick(e) {
        this.empId = e.currentTarget.dataset.rowId;
        this.dateToForRow = e.currentTarget.dataset.rowDateto;
        this.dateFromForRow = e.currentTarget.dataset.rowDatefrom;
        this.showChildComponent = true;
    }

    handleTimesheetClose(e) {
        this.showChildComponent = false;
    }

    handleSort(e) {
        let table;
        if (!this.showFilteredData) {
            console.log(this.screenType);
            if (this.screenType == 'Approval') {
                table = JSON.parse(JSON.stringify(this.timesheetForApproval));
            }
            else if (this.screenType == 'Unlock') {
                console.log(JSON.stringify(this.timesheetForUnlock));
                table = JSON.parse(JSON.stringify(this.timesheetForUnlock));
            }
            else if (this.screenType == 'View') {
                table = JSON.parse(JSON.stringify(this.timesheetForView));
            }
        }
        else {
            table = JSON.parse(JSON.stringify(this.filteredData));
        }
        if (this.sortBy == 'asc') {
            table.sort((a, b) => { return a[e.currentTarget.dataset.id] > b[e.currentTarget.dataset.id] ? 1 : -1 }
            );
            this.sortBy = 'desc';
        }
        else if (this.sortBy == 'desc') {
            table.sort((a, b) => { return a[e.currentTarget.dataset.id] < b[e.currentTarget.dataset.id] ? 1 : -1 }
            );
            this.sortBy = 'asc';
        }
        if (!this.showFilteredData) {
            if (this.screenType == 'Approval') {
                this.timesheetForApproval = table;
            }
            else if (this.screenType == 'Unlock') {
                this.timesheetForUnlock = table;
            }
            else if (this.screenType == 'View') {
                this.timesheetForView = table;
            }
        }
        else {
            this.filteredData = table;
        }
    }

}