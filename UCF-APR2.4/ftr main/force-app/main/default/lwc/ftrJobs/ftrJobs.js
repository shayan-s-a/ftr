import { LightningElement, track } from 'lwc';
import deleteTestData from '@salesforce/apex/ftr_DeleteTestDataBatchJob.deleteTestData';
import getJobStatus from '@salesforce/apex/ftr_DeleteTestDataBatchJob.getJobStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FtrJobs extends LightningElement {
    @track companyName;
    @track deleteData = 'files';
    @track batchJobTableRecords;

    accountFields = "Name";
    accountDisplayFields = 'Name, RecordType.Name, Id';

    batchJobTableColumns = [
        { label: 'Status', fieldName: 'Status' },
        { label: 'Total Batches', fieldName: 'TotalJobItems' },
        { label: 'Batches Processed', fieldName: 'JobItemsProcessed' },
        { label: 'Failures', fieldName: 'NumberOfErrors' },
    ]
    
    get deleteOptions() {
        return [
            { label: 'All Data', value: 'all' },
            { label: 'Files Only', value: 'files' },
        ];
    }

    handleDeleteDataSelection(event) {
        this.deleteData = event.detail.value;
    }

    handleLookup(event) {
        console.log(JSON.stringify(event.detail))
        if (event.detail.data && event.detail.data.record)
            this.companyName = event.detail.data.record.Id;
        else
            this.companyName = null;
    }

    deleteTestData() {
        this.loading = true;
        deleteTestData({
            companyName: this.companyName,
            allData: this.deleteData == 'all'
        }).then(data => {
            this.loading = false;
            if (data) { 
                this.batchJobTableRecords = data;
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Batch job has been queued',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
            }
            else this.batchJobTableRecords = undefined;
        }).catch(error => {
            this.loading = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            console.error('deleteTestData error', error);
        });
    }

    getJobStatus() {
        this.loading = true;
        getJobStatus({
            jobId: this.batchJobTableRecords[0].Id
        }).then(data => {
            this.loading = false;
            if (data) this.batchJobTableRecords = data;
            else this.batchJobTableRecords = undefined;
        }).catch(error => {
            this.loading = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            console.error('getJobStatus error', error);
        });
    }

    openEmailDeliverability() {
        window.open('/lightning/setup/OrgEmailSettings/home', '_blank').focus();
    }
}