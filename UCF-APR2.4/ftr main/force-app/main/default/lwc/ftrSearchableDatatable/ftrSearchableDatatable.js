import { LightningElement, api } from 'lwc';
import tmpl from './ftrSearchableDatatable.html';
import { log, convertToSpeed } from 'c/ftrUtils';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
const DELAY = 300;
const pageNumber = 1;
const SHOWDIV = 'visibility:visible';
const HIDEDIV = 'visibility:hidden';
const DEFAULTHEIGHT = '500px';

export default class FtrSearchableDatatable extends OmniscriptBaseMixin(LightningElement) {
    // Input Attributes from Parent Componant
    @api keyField;
    @api showSearchBox = false; //Show/hide search box; valid values are true/false
    @api showPagination; //Show/hide pagination; valid values are true/false
    @api pageSizeOptions; //Page size options; valid values are array of integers
    @api totalRecords; //Total no.of records; valid type is Integer
    @api records; //All records available in the data table; valid type is Array
    @api maxRowSelection;
    @api columns = [];
    @api selectedRows = []; // Ids of records selected in table

    tableHeightStyle = 'height: ' + DEFAULTHEIGHT;
    @api
    get tableHeight() {
        return this.tableHeightStyle;
    }

    set tableHeight(value) {
        this.tableHeightStyle = 'height: ' + value;
    }

    pageSize; //No.of records to be displayed per page
    totalPages; //Total no.of pages
    pageNumber = pageNumber; //Page number
    searchKey; //Search Input
    paginationVisibility = SHOWDIV;
    rowNumberOffset; //Row number
    recordsToDisplay = []; //Records to be displayed on the page
    selectedRowIds = []; // Ids of records selected in table
    allSelectedRowIds = []; // Ids of records selected in table
    filteredRecords = []; //Filtered records available in the data table; valid type is Array
    filtredNum; // Total no.of Filtered records; valid type is Integer
    //SORT
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    changingPages = false;

    render() {
        return tmpl;
    }

    //Called after the component finishes inserting to DOM
    connectedCallback() {
        if (this.pageSizeOptions && this.pageSizeOptions.length > 0)
            this.pageSize = this.pageSizeOptions[0];
        else {
            this.pageSize = this.totalRecords;
            this.showPagination = false;
        }
        this.paginationVisibility = this.showPagination === false ? HIDEDIV : SHOWDIV;
        this.filteredRecords = this.records;
        this.filtredNum = this.totalRecords;
        this.setRecordsOnPage();
    }

    renderedCallback() {
    }

    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.setRecordsOnPage();
    }

    handlePageNumberChange(event) {
        if (event.keyCode === 13) {
            this.pageNumber = event.target.value;
            this.setRecordsOnPage();
        }
    }

    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.setRecordsOnPage();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.setRecordsOnPage();
    }

    @api
    setRecordsOnPage() {
        this.recordsToDisplay = [];
        if (!this.pageSize)
            this.pageSize = this.filtredNum;

        this.totalPages = Math.ceil(this.filtredNum / this.pageSize);

        this.setPaginationControls();
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.filtredNum) break;
            this.recordsToDisplay.push(this.filteredRecords[i]);
        }
    }

    setPaginationControls() {
        // Previous/Next buttons visibility by Total pages
        if (this.totalPages === 1) {
            this.showPrevious = HIDEDIV;
            this.showNext = HIDEDIV;
        } else if (this.totalPages > 1) {
            this.showPrevious = SHOWDIV;
            this.showNext = SHOWDIV;
        }
        // Previous/Next buttons visibility by Page number
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
            this.showPrevious = HIDEDIV;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
            this.showNext = HIDEDIV;
        }
        // Previous/Next buttons visibility by Pagination visibility
        if (this.paginationVisibility === HIDEDIV) {
            this.showPrevious = HIDEDIV;
            this.showNext = HIDEDIV;
        }
    }

    handleKeyChange(event) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        if (searchKey) {
            this.delayTimeout = setTimeout(() => {
                //this.paginationVisibility = HIDEDIV;
                this.setPaginationControls();

                this.searchKey = searchKey;
                this.filteredRecords = this.records.filter(rec => {
                    for (let col of this.columns) {
                        if (col.searchable && JSON.stringify(rec[col.fieldName]).toLowerCase().includes(searchKey.toLowerCase()))
                            return true;
                    }
                    // JSON.stringify(rec).toLowerCase().includes(searchKey.toLowerCase())
                });
                this.filtredNum = this.filteredRecords.length;
                this.setRecordsOnPage();
            }, DELAY);
        } else {
            this.filteredRecords = this.records;
            this.filtredNum = this.totalRecords;
            this.paginationVisibility = SHOWDIV;
            this.setRecordsOnPage();
        }
    }

    handelRowSelection() {
        // const selectedRecords = this.records.filter(record => record.selected)

        this.dispatchEvent(new CustomEvent('rowselection', { detail: this.selectedRowIds }));
    }

    getSelectedRows(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRowIds = [];
        selectedRows.forEach(record => {
            this.selectedRowIds.push(record[this.keyField]);
        })
        // log('getSelectedRows: this.selectedRowIds ', this.selectedRowIds)
        this.handelRowSelection();
    }

    handelSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.filteredRecords];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.filteredRecords = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this.setRecordsOnPage();
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return field == 'Speed__c' ? convertToSpeed(x[field]) : x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
}