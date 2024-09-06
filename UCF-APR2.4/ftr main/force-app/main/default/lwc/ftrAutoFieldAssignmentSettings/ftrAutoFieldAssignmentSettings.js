import { LightningElement, track, wire } from 'lwc';
import tmpl from './ftrAutoFieldAssignmentSettings.html';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ORDER_OBJECT from '@salesforce/schema/Order';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import save from '@salesforce/apex/ftr_FieldAssignmentSettingsController.saveRecord';
import getRecords from '@salesforce/apex/ftr_FieldAssignmentSettingsController.getRecords';
import getPicklistValues from '@salesforce/apex/ftr_FieldAssignmentSettingsController.getPicklistValues';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    { label: 'Label', fieldName: 'MasterLabel' },
    { label: 'Automation Enabled?', fieldName: 'IsAutomationEnabled__c', type:'boolean' },
    { label: 'Excluded Order Stages', fieldName: 'ExcludedOrderStages__c' },
    { label: 'Included Product Types', fieldName: 'IncludedProductTypes__c' },
    { label: 'Excluded Record Type', fieldName: 'ExcludedRecordTypes__c' },
    { label: 'Included Record Types', fieldName: 'IncludedRecordTypes__c' },
    { label: 'Create Task?', fieldName: 'ShouldCreateTask__c', type:'boolean' },
    { label: 'Task Queue', fieldName: 'QueueName__c' },
];
export default class FtrAutoFieldAssignmentSettings extends NavigationMixin(LightningElement) {
    @track records;

    fields;
    error;
    loading;
    @track record;
    @track selectedRecords = [];
    @track editMode;
    columns = columns;
    isIncludedRecordType = false;
    picklistValues;
    queueFilter = " ID IN (SELECT QueueId FROM QueueSobject WHERE SobjectType = 'Task' ) ";
    queueSearchFields = "Name";
    queueDisplayFields = 'DeveloperName, Id';

    @wire(getObjectInfo, { objectApiName: ORDER_OBJECT })
    orderObjectInfo;

    get orderStages() {
        return JSON.parse(this.picklistValues.OrderStages).map(item => ({
            label: item.label,
            value: item.label,
        })).sort((a, b) => (a.label > b.label) ? 1 : -1)
    }
    get productTypes() {
        return JSON.parse(this.picklistValues.Products).map(item => ({
            label: item.label,
            value: item.label,
        })).sort((a, b) => (a.label > b.label) ? 1 : -1)
    }
    get recordTypes() {
        const rtis = this.orderObjectInfo.data.recordTypeInfos;
        return Object.keys(rtis).map(rti => ({
            label: rtis[rti].name,
            value: rtis[rti].name,
        }));
    }

    get includedRecordType() {
        return this.record.IncludedRecordTypes__c ? 'Include' : 'Exclude';
    }

    set includedRecordType(val) {
        if (val == 'Exclude') {
            this.isIncludedRecordType = false;
        } else {
            this.isIncludedRecordType = true;
        }
    }

    get includedRecordTypeOptions() {
        return [
            { label: 'Include', value: 'Include' },
            { label: 'Exclude', value: 'Exclude' },
        ];
    }

    render() {
        return tmpl;
    }

    connectedCallback() {
        this.fetchRecords();
        getPicklistValues().then(data => {
            this.picklistValues = data;
            console.log('getPicklistValues', data)
        }).catch(error => {
            console.error(error, 'error getting picklist values');
        });
    }

    handleFieldChange(event) {
        let field = event.target.dataset.field;

        if (field == 'includedRecordType') {
            this.includedRecordType = event.detail.value;
            return;
        }

        if (event.target.type == 'checkbox') {
            this.record[field] = event.target.checked;
        } else {
            this.record[field] = event.detail.value;
        }
        console.log(JSON.parse(JSON.stringify(this.record)))
    }

    handleLookup(event) {
        let field = event.target.dataset.field;
        console.log(JSON.stringify(event.detail))
        if (event.detail.data && event.detail.data.record)
            this.record[field] = event.detail.data.record.DeveloperName;
        else
            this.record[field] = null;
        console.log(JSON.parse(JSON.stringify(this.record)))
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (!selectedRows[0]) return;
        this.record = JSON.parse(JSON.stringify(selectedRows[0]));
        console.log('this.record', JSON.parse(JSON.stringify(this.record)))
        this.record.ExcludedOrderStages__c = this.record.ExcludedOrderStages__c.split(';')
        this.record.IncludedProductTypes__c = this.record.IncludedProductTypes__c.split(';')
        if (this.record.IncludedRecordTypes__c) {
            this.record.IncludedRecordTypes__c = this.record.IncludedRecordTypes__c.split(';')
            this.includedRecordType = 'Include';
        } else {
            this.record.ExcludedRecordTypes__c = this.record.ExcludedRecordTypes__c.split(';')
            this.includedRecordType = 'Exclude';
        }
        this.openModal();
    }

    openModal() {
        this.editMode = true;
    }

    closeModal() {
        this.editMode = false;
        this.selectedRecords = [];
    }

    fetchRecords() {
        this.loading = true;
        getRecords().then(data => {
            this.loading = false;
            console.log('getRecords', data)
            this.records = data;
        }).catch(error => {
            this.loading = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            console.error(error, 'error getting records');
        });
    }

    newRecord() {
        this.record = {}
        this.openModal();
    }

    handleSave() {
        this.loading = true;
        save({
            record: JSON.stringify(this.record)
        }).then((data) => {
            this.loading = false;
            console.log(JSON.parse(JSON.stringify(data)))
            if (data.error) {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: data.error,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            } else {
                this.closeModal();
                this.fetchRecords();
            }
        }).catch((error) => {
            this.loading = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            console.error(error)
        })
    }
    
    openWorkGroups() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'WorkGroup__c',
                actionName: 'list'
            },
            state: {
                filterName: 'All'
            },
        });
    }
}