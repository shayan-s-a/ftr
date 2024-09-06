import { LightningElement, track, wire } from 'lwc';
import getMDUQueueTasksForOpp from '@salesforce/apex/ftr_TaskHelper.getMDUQueueTasksForOpp';

//const DEFAULT_API_NAME = 'Task';
const columns = [
    //{ label: 'Id', fieldName: 'Id', type: 'text'},
    { label: 'Task', fieldName: 'nameUrl', type: 'url', typeAttributes: {label: { fieldName: 'subject' }, target: '_blank'}, sortable: true},
    //{ label: 'Task', fieldName: 'nameUrl', type: 'url', typeAttributes: {label: { fieldName: 'Subject' }, target: '_blank'}, sortable: true},
    { label: 'Opportunity', fieldName: 'oppName', type: 'text'},
    { label: 'Status', fieldName: 'status', type: 'text'},
    { label: 'Created Date', fieldName: 'createdDate', type: 'date'},
    { label: 'Owner', fieldName: 'ownerName', type: 'text'},
];

export default class FtrOppTasksForContractGen extends LightningElement {
    @track loaded = true;
    @track columns = columns;
    @track tskRecords = [];
    @track error;

    @wire(getMDUQueueTasksForOpp)
    wiredTasks({ error, data }) {
        console.log('About to get Records:' + JSON.stringify(data));
        if (data) {
            console.log('Records:' + JSON.stringify(data));
            let nameUrl;
            /*this.tskRecords = data.map(row => {
                console.log('row:' + JSON.stringify(row));
                nameUrl = '/' + row.Id;
                return {...row , nameUrl}
            })*/
            this.tskRecords = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }
}