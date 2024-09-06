import { LightningElement, api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
// import submitRecordsNew from '@salesforce/apex/TimesheetControllerAS.submitRecordsNew';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TimesheetSubmitModalAS extends LightningModal {
    @api timesheetSubmittedData;
    @api conId;
    @track spinLoader;

    handleOkay() {
        // let submittedDataIds = [];
        // this.timesheetSubmittedData.forEach(element => {
        //     submittedDataIds.push(element);
        // });
        this.spinLoader = true;
        // submitRecordsNew({ timesheets: this.timesheetSubmittedData, conId: this.conId })
        //         .then(result => {
        //             this.close();
        //             this.spinLoader = false;
        //             console.log('Result', result);
        //             if (result == 'OK') {
        //                 this.dispatchEvent(
        //                     new ShowToastEvent({
        //                         title: 'Timesheet Submitted',
        //                         message: 'Timesheet submitted for approval successfully.',
        //                         variant: 'success'
        //                     })
        //                 );
        //             }
        //             else {
        //                 this.dispatchEvent(
        //                     new ShowToastEvent({
        //                         title: 'Some Issue in Saving',
        //                         message: 'Timesheet was not submitted successfully. If this error keeps coming up then contact your System Administrator.',
        //                         variant: 'info'
        //                     })
        //                 );
        //             }
        //         })
        //         .catch(err => {
        //             this.close();
        //             this.spinLoader = false;
        //             console.error('Error:', err);
        //             this.dispatchEvent(
        //                 new ShowToastEvent({
        //                     title: 'Error in Submitting',
        //                     message: 'Error in submitting timsheet for Approval. ' + JSON.stringify(err),
        //                     variant: 'error',
        //                     mode: 'sticky'
        //                 })
        //             );
        //         })

        // console.log('submittedDataIds: '+timesheetSubmittedData);
        // this.close();
    }
}