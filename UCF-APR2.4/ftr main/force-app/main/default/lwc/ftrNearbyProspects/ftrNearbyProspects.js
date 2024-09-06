/**
*
* This is used to control the NearestProspects LWC Component 
* @author  Eric Marcondes
* @since   2020-05-18
*
*/
import { LightningElement, track, api, wire } from 'lwc';
import getProspectRecords from '@salesforce/apex/ftrNearbyProspectController.getNearbyProspects';

const UNITS = 'mi';                         // distance units used in SOQL query
const LIMIT = 100;                           // SOQL query limit

export default class FtrNearbyProspects extends LightningElement {
    @api recordId;                          // context of current page
    @track loading = false;                 // toggles spinner
    @track data = [];                       // data to be display in the table
    @track page = 1;                        // this is initialize for 1st page
    @track items = [];                      // it contains all the records.
    @track allItems = [];
    @track startingRecord = 1;              // start record position per page
    @track endingRecord = 0;                // end record position per page
    @track pageSize = 20;                    // default value we are assigning
    @track totalRecordCount = 0;            // total record count received from all retrieved records
    @track totalPage = 0;                   // total number of page is needed to display all records
    @track pagination = false;              // toggles the pagination component
    @track distance = 5;                    // for SOQL query
    @track isMobile = false;                // toggles card and table view
    @track sortBy;
    @track sortDirection = 'desc';
    @track filterOptions = {};

    /*
    actions: [
                    {label: 'All', checked: true, name: 'All'},
                    {label: 'Calls', checked: false, name: 'Calls'},
                    {label: 'Emails', checked: false, name: 'Emails'}
                ]
    */ 
    @track columns = [];

    /*  This method gets the records to display in the table */
    getNearbyProspects() {
        this.showSpinner();
        console.debug('searching with within this distance: ', this.distance);
        getProspectRecords({ 
            accountId: this.recordId, 
            distance: this.distance, 
            units: UNITS, 
            queryLimit: LIMIT
        })
        .then(data => {
            this.items = [];
            data.forEach(element => {
                var today = new Date();
                var d2 = new Date(today.getFullYear() - 2, today.getMonth() - 6, today.getDate());
                if ( Date.parse(element.ProviderLastChangedDate) <= Date.parse(d2) || element.ProviderLastChangedDate == ' - ') {
                    this.items.push(element);
                }
            });

            // set the URL for the record detail page
            this.items.forEach(function(record){
                record.nameURL = '/'+ record.AccountId;
            });
            this.allItems = JSON.parse(JSON.stringify(this.items));

            // this.filterOptions = {
            //     CompanyName : [{label: 'All', checked: true, name: 'All'}],
            //     Rating : [{label: 'All', checked: true, name: 'All'}],
            //     ProviderLastChangedDate : [{label: 'All', checked: true, name: 'All'}],
            //     CurrentProvider : [{label: 'All', checked: true, name: 'All'}],
            //     PreviousProvider : [{label: 'All', checked: true, name: 'All'}],
            //     BuildingType : [{label: 'All', checked: true, name: 'All'}]
            // };

            // this.items.forEach(record => {
            //     Object.keys(record).forEach(fieldName => {
            //         if (this.filterOptions[fieldName] != undefined) {
            //             this.filterOptions[fieldName].push({
            //                 label: record[fieldName], 
            //                 checked: false, 
            //                 name: record[fieldName]
            //             }); 
            //         }
            //     });
            // });
            // var tempMap = JSON.parse(JSON.stringify(this.filterOptions));
            // Object.keys(tempMap).forEach(fieldName => {
            //     this.filterOptions[fieldName] = this.removeDuplicates(tempMap[fieldName], 'label');
            // });
            
            this.columns = [
                { label: 'Company Name', fieldName: 'nameURL', type: 'url', wrapText: true, sortable: "true", 
                    typeAttributes: { 
                        label: { 
                            fieldName: 'CompanyName' 
                        }, 
                        target: '_blank'
                    }
                },
                // { label: 'Account Owner', fieldName: 'AccountOwner',  wrapText: true, sortable: "true",  },
                { label: 'Lattice Rating (Connectivity)', fieldName: 'Rating',  wrapText: true, sortable: "true",   },
                { label: 'Provider Last Change Date', fieldName: 'ProviderLastChangedDate',  wrapText: true, sortable: "true", },
                { label: 'Current Voice Provider', fieldName: 'CurrentProvider',  wrapText: true, sortable: "true",   },
                { label: 'Previous Voice Provider', fieldName: 'PreviousProvider',  wrapText: true, sortable: "true", },
                { label: 'Building Type', fieldName: 'BuildingType',  wrapText: true, sortable: "true", }
            ];
            
            console.debug('list: ', this.items);
            // set values for pagination
            this.startingRecord = 1;
            this.totalRecordCount = this.items.length;
            this.totalPage = Math.ceil(this.totalRecordCount / this.pageSize);
            this.data = this.items.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;
            this.needsPagination();
            this.hideSpinner();
        })
        .catch(error => {
            this.error = error.body ? error.body.message : error;
            console.error(error);
            this.hideSpinner();
        });
    }
    
    async connectedCallback() {
        // check if on mobile device
        if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|ipad|iris|kindle|Android|Silk|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(navigator.userAgent) 
            || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(navigator.userAgent.substr(0,4))) { 
            this.isMobile = true;
        }
        if (this.recordId != null) {
            this.getNearbyProspects();
        }
    }

    removeDuplicates(myArr, prop) {
        return myArr.filter((obj, pos, arr) => {
            return arr.map(mapObj => mapObj[prop]).indexOf(obj[prop]) === pos;
        });
    }

    /* This method is called onblur of an input component to bind its value to the controller */
    bindValue(event) {
        this[event.target.dataset.property] = event.target.value;
    }

    scrollToTop() {
        this.template.querySelector('.topOfPage').scrollTop=0;
    }

    /*  This method toggles the spinner */
    showSpinner() {
        this.loading = true;
    }

    /* This method toggles the spinner */
    hideSpinner() {
        this.loading = false;
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
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);  
        }             
    }

    /* This method is used to control the records displayed in the table */
    displayRecordPerPage(page){
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecordCount) 
                            ? this.totalRecordCount : this.endingRecord; 

        this.data = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
        this.scrollToTop();
    }    

    /*  This method is used to control whether or not pagination is needed */
    needsPagination() {
        this.pagination = this.totalRecordCount > this.pageSize ? true : false;
    }

    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;

        // sort direction
        this.sortDirection = event.detail.sortDirection;

        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.items));
        var excludeFromSort = ['Tier 2', 'Tier 3', ' - '];
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1: -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        
        // resort
        this.items = [];
        var tempList = [];
        parseData.forEach(record => {
            if (!excludeFromSort.includes(record.BuildingType)) {
                this.items.push(record);
            } else {
                tempList.push(record);
            }
        });
        tempList.forEach(record => {
            this.items.push(record);
        });
        // this.items = parseData;
        this.resetPagination();
    }

    resetPagination() {
        // set values for pagination
        this.startingRecord = 1;
        this.endingRecord = this.pageSize;
        this.page = 1;
        this.data = this.items.slice(0,this.pageSize); 
        this.needsPagination();
    }

    // handleHeaderAction(event) {
    //     // gives the selection header action name
    //     var actionName = event.detail.action.name;

    //     if (actionName == 'wrapText' || actionName == 'clipText')
    //         return;

    //     // gives selected column definition
    //     var colDef = event.detail.columnDefinition;
        
    //     // assigning colmuns to new variable
    //     let cols = this.columns;

    //     console.log(JSON.stringify(actionName));
    //     console.log(JSON.stringify(colDef));
    //     console.log(JSON.stringify(cols));
        
    //     if (actionName !== undefined && actionName !== 'All') {
    //         // filtering cases on selected actionname
    //         var key = colDef.fieldName == 'nameURL' ? 'CompanyName' : colDef.fieldName;
    //         this.items = this.allItems.filter(_item => _item[key] === actionName);
    //         this.resetPagination();
    //     } else if (actionName === 'All') {
    //         // returning all cases
    //         this.items = this.allItems;
    //         this.resetPagination();
    //     }
    
    //     /* Following line is responsible for finding which header action selected and return corresponding actions then we will mark selcted as checked/true and remaining will be marked as unchecked/marked */
    //     cols.find(col => col.label === colDef.label).actions.forEach(action => action.checked = action.name === actionName);
    //     this.columns = [...cols];
    // }

}