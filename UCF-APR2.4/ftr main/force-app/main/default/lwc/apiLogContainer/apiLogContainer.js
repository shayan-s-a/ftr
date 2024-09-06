import { LightningElement, track, wire } from 'lwc';
import getLogs from '@salesforce/apex/APILogger.getLogs';
import getPicklistValues from '@salesforce/apex/APILogger.getPicklistValues';
import FTR_LOGO from '@salesforce/resourceUrl/FrontierComunication';

const today = new Date();
const tomorrow = new Date();
export default class ApiLogContainer extends LightningElement {
    @track error;
    @track allLogs;
    @track disableSearch = false;
    @track logs;
    @track logId;
    @track log;
    @track page = 1;                        // this is initialize for 1st page
    @track startingRecord = 1;              // start record position per page
    @track endingRecord = 0;                // end record position per page
    @track pageSize = 10;                    // default value we are assigning
    @track totalRecordCount = 0;            // total record count received from all retrieved records
    @track totalPage = 0;                   // total number of page is needed to display all records
    @track pagination = false;              // toggles the pagination component
    @track showDetails = false;
    @track systemName = 'All';
    @track interfaceName = 'All';
    @track filterNumber;
    @track status = 'All';
    @track startDate;
    @track endDate;
    @track statusFilters;
    @track systemFilters;
    @track interfaceFilters;
    logoImg = FTR_LOGO;

    renderedCallback() {

    }

    connectedCallback() {
        tomorrow.setDate(tomorrow.getDate() + 1);
        today.setDate(today.getDate() - 6);
        this.startDate = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        this.endDate = tomorrow.getFullYear() + '-' + (tomorrow.getMonth() + 1) + '-' + (tomorrow.getDate());
        this.getLogs();
        this.getPicklistValues();
    }

    getPicklistValues() {
        getPicklistValues()
        .then(result => {
            this.statusFilters = [{value: 'All', label: 'All'}];
            JSON.parse(result.Status__c).forEach(val => {
                this.statusFilters.push(val);
            });
            this.systemFilters = [{value: 'All', label: 'All'}];
            JSON.parse(result.System__c).forEach(val => {
                this.systemFilters.push(val);
            });
            this.interfaceFilters = [{value: 'All', label: 'All'}];
            JSON.parse(result.Interface__c).forEach(val => {
                this.interfaceFilters.push(val);
            });
        })
        .catch(error => {
            console.error(error);
        })
    }

    getLogs() {
        this.disableSearch = true;
        var payLoad = {
            systemName: this.systemName,
            interfaceName: this.interfaceName,
            filterNumber: this.filterNumber,
            status: this.status,
            startDate: this.startDate,
            endDate: this.endDate
        }
        if (payLoad.filterNumber == '' || payLoad.filterNumber == null) payLoad.filterNumber = 'All';
        getLogs(payLoad)
            .then(result => {
                if (result.logs.length == 0) {
                    this.error = 'No logs found for the given filters.';
                } else {
                    this.error = undefined;
                }
                console.log('getLogsResult', result);
                this.allLogs = JSON.parse(JSON.stringify(result.logs));
                this.allLogs.forEach(log => {
                    var localDate = new Date(log.CreatedDate);
                    log.CreatedDateFormatted = localDate.toLocaleString();
                });
                // set values for pagination
                this.startingRecord = 1;
                this.totalRecordCount = this.allLogs.length;
                this.totalPage = Math.ceil(this.totalRecordCount / this.pageSize);
                this.logs = this.allLogs.slice(0, this.pageSize);
                this.endingRecord = this.pageSize;
                this.resetPagination();
                this.showDetails = false;
                this.disableSearch = false;
            })
            .catch(error => {
                console.error(error);
            })
    }

    saveInputValue(e) {
        this[e.target.name] = e.target.value;
    }

    resetFilters() {
        this.startDate = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        this.endDate = tomorrow.getFullYear() + '-' + (tomorrow.getMonth() + 1) + '-' + (tomorrow.getDate());
        this.systemName = 'M6';
        this.template.querySelector("select[name='systemName']").selectedIndex = 0;
        this.interfaceName = 'All';
        this.template.querySelector("select[name='interfaceName']").selectedIndex = 0;
        this.filterNumber = '';
        this.status = 'All';
        this.template.querySelector("select[name='status']").selectedIndex = 0;
    }

    showLogDetails(e) {
        this.allLogs.forEach(log => {
            delete log['rowCSS'];
        });
        this.showDetails = true;
        this.logId = e.target.dataset.id;
        this.logs.forEach(log => {
            if (log.Id == this.logId) {
                this.log = log;
                this.log.rowCSS = 'active-table-row';
                this.log.relatedToLabel = this.getRelatedToLabel();
            }
        });
    }

    getRelatedToLabel() {
        if (this.log.RelatedTo__c == null) 
            return 'To';
        if (this.log.RelatedTo__c.startsWith('001')) {
            return 'Account';
        } else if (this.log.RelatedTo__c.startsWith('801')) {
            return 'Order';
        } else if (this.log.RelatedTo__c.startsWith('0Q0')) {
            return 'Quote';
        } else if (this.log.RelatedTo__c.startsWith('006')) {
            return 'Opportunity';
        } else if (this.log.RelatedTo__c.startsWith('800')) {
            return 'Contract';
        }
    }

    /* This method is used to control the table's pagination */
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    /* This method is used to control the table's pagination */
    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    /* This method is used to control the records displayed in the table */
    displayRecordPerPage(page) {
        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecordCount)
            ? this.totalRecordCount : this.endingRecord;

        this.logs = this.allLogs.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }

    /*  This method is used to control whether or not pagination is needed */
    needsPagination() {
        this.pagination = this.totalRecordCount > this.pageSize ? true : false;
    }

    resetPagination() {
        // set values for pagination
        this.startingRecord = 1;
        this.endingRecord = this.pageSize;
        this.page = 1;
        this.logs = this.allLogs.slice(0, this.pageSize);
        this.needsPagination();
    }
}