import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import LightningConfirm from 'lightning/confirm';
export default class ReportFilter extends LightningElement {
    
    @api dateFrom;
    @api dateTo;
    noOfDays=0;

    // connectedCallback(){
    //     // console.log('FURQAN',this.template.querySelectorAll);
    //     const card = this.template.querySelectorAll('.slds-card'); // Get the card element

    //     let header = card.querySelectorAll('.slds-card'); // Get the header element

    //     card.removeChild(header); // Remove the header element from the card
    // }


    callChildMethod(event){
        let child = this.template.querySelector('c-report-data');
        child.callFromParent(this.dateTo, this.dateFrom, this.noOfDays);
    }
    
    handleChange(evt) {
       
        let { name, value } = evt.target;    
        if (name == 'dateFrom')    
             this.dateFrom = value;  
        else if (name == 'dateTo') 
            this.dateTo = value
       
    }
    handleSearch(event) {
        let firstDate = new Date(this.dateFrom);
        let lastDate = new Date( this.dateTo);
        let diff = lastDate.getTime() - firstDate.getTime();

        let days = diff / (1000 * 60 * 60 * 24);
        console.log(':::: days' + days);
        console.log(firstDate);
        console.log(this.dateFrom);
        // alert (':::: days' + days);
        if(this.dateFrom==undefined || this.dateTo==undefined){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: '"Please select the date range".',
                    variant: 'warning',
                })
            );
        }
        else if (days < 0 ) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Info',
                        message: '"Date To" must be later than "Date From".',
                        variant: 'info',
                    })
                );
            }
       
            else{
                this.noOfDays=days;
                this.callChildMethod(event)
            }

    }

}