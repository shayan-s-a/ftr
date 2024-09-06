import { LightningElement, api } from 'lwc';
//Import apex method 

import getGridData from '@salesforce/apex/ReportController.getGridData';

export default class ReportData extends LightningElement {

    // JS Properties 
    pageSizeOptions = [5, 10, 25, 50, 75, 100]; //Page size options
    records = []; //All records available in the data table
    columns = []; //columns information available in the data table
    Gridcolumns = []; //Gridcolumns information available in the data table

    totalRecords = 0; //Total no.of records
    pageSize; //No.of records to be displayed per page
    totalPages; //Total no.of pages
    pageNumber = 1; //Page number    
    recordsToDisplay = []; //Records to be displayed on the page
    // @api dateFrom;
    // @api dateTo;
    // @api noOfDays;
    dateFrom;
    dateTo;
    noOfDays;
    showLoader=false
    CSVButton=true;

    columns = [{
        label: 'CoCode',
        fieldName: 'CoCode',
        type: 'text'
    },
    {
        label: 'BatchId',
        fieldName: 'BatchId',
        type: 'text'
    },
    {
        label: 'FileNumber',
        fieldName: 'FileNumber',
        type: 'text'
    },
    {
        label: 'TaxFrequency',
        fieldName: 'TaxFrequency',
        type: 'number'
    },
    {
        label: 'RegHours',
        fieldName: 'RegHours',
        type: 'decimal'
    },
    {
        label: 'OTHours',
        fieldName: 'OTHours',
        type: 'decimal'
    },
    {
        label: 'Hours3Code',
        fieldName: 'Hours3Code',
        type: 'decimal'

    },
    ];
 


    get bDisableFirst() {
        return this.pageNumber == 1;
    }

    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }

    @api callFromParent(dateTo, dateFrom, noOfDays){
        this.showLoader=true
        this.dateFrom= dateFrom;
        this.dateTo = dateTo;
        this.noOfDays=noOfDays;
        this.init();
    }

    init(){
        // if (this.noOfDays>0) {
        //     console.log('this.noOfDays',this.noOfDays);
        // }
        // getGridData({dtFromParam:'2023-06-06',dtToParam:'2023-07-25',noOfDays:10})
        getGridData({dtFromParam: this.dateFrom ,dtToParam:this.dateTo ,noOfDays:this.noOfDays})
        .then((result) => {
            if (result != null) {
                
                console.log('result',result);
                this.recordsToDisplay=result;
                this.showLoader=false;
                
                this.records = result;
                this.CSVButton=false;
                this.totalRecords = result.length; // update total records count                 
                this.pageSize = this.pageSizeOptions[1]; //set pageSize with default value as first option
                this.paginationHelper(); // call helper menthod to update pagination logic 
                
            }
        })
        .catch((error) => {
            console.log('error while fetch getGridData--> ' + JSON.stringify(error));
            //alert('error while fetch contacts--> ' + JSON.stringify(error));
        });
    }

    // connectedCallback method called when the element is inserted into a document
    connectedCallback() {
        this.init();
        // fetch contact records from apex method 
    }

    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }

    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }

    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }

    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }

    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }


    // JS function to handel pagination logic 
    paginationHelper() {
        this.recordsToDisplay = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }

        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.records[i]);
        }
    }

    
    // this method validates the data and creates the csv file to download
    downloadCSVFile() {   
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        // let rowData = new Set();
        let rowData={};
        const desiredKeyOrder = ['CoCode','BatchId','FileNumber','TaxFrequency','RegHours','OTHours','Hours3Code'];
     
        rowData = desiredKeyOrder;
         
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;
        alert ( 'csvString::'+ csvString);
        // main for loop to get the data based on key value
        for(let i=0; i < this.recordsToDisplay.length; i++){
            let colValue = 0;
 
            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.recordsToDisplay[i][rowKey] === undefined ? '' : this.recordsToDisplay[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                   
                }
            }
            csvString += rowEnd;
           
        }
        alert ( 'csvString::'+ csvString);
        // Creating anchor element to download
        let downloadElement = document.createElement('a');
 
        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        alert (' downloadElement.href ::'+ downloadElement.href )
        // CSV File Name
        downloadElement.download = 'ADPGrid Data.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
    }
}