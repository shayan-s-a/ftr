import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import search from '@salesforce/apex/ftr_CustomLookupController.search';
const DELAY = 300;
export default class ftrLookupElement extends LightningElement {

    @api objName = 'Account';
    @api iconName = 'standard:account';
    @api labelName;
    @api filter;
    @api readOnly = false;
    @api currentRecordId;
    @api placeholder = 'Search';
    @api createRecord;
    @api searchField;
    @api displayFields = 'Name, Owner.Name, AccountNumber';

    @api 
    get value() {
        return this.selectedRecord.FIELD1;
    }
    set value(val) {
        // this needs to be further tested
        if (!val) return;
        if (this.selectedRecord) 
            this.selectedRecord.FIELD1 = val;
        else 
            this.selectedRecord = {
                FIELD1: val
            }
    }

    @track error;

    searchTerm;
    delayTimeout;

    searchRecords;
    selectedRecord;
    objectLabel;
    isLoading = false;

    field;
    field1;
    field2;

    ICON_URL = '/apexpages/slds/latest/assets/icons/{0}-sprite/svg/symbols.svg#{1}';

    connectedCallback() {

        let icons = this.iconName.split(':');
        this.ICON_URL = this.ICON_URL.replace('{0}', icons[0]);
        this.ICON_URL = this.ICON_URL.replace('{1}', icons[1]);
        if (this.objName.includes('__c')) {
            let obj = this.objName.substring(0, this.objName.length - 3);
            this.objectLabel = obj.replaceAll('_', ' ');
        } else {
            this.objectLabel = this.objName;
        }
        this.objectLabel = this.titleCase(this.objectLabel);
        let fieldList;
        if (!Array.isArray(this.displayFields)) {
            fieldList = this.displayFields.split(',');
        } else {
            fieldList = this.displayFields;
        }

        if (fieldList.length > 1) {
            this.field = fieldList[0].trim();
            this.field1 = fieldList[1].trim();
        }
        if (fieldList.length > 2) {
            this.field2 = fieldList[2].trim();
        }
        // let combinedFields = [];
        // fieldList.forEach(field => {
        //     if (!this.fields.includes(field.trim())) {
        //         combinedFields.push(field.trim());
        //     }
        // });

        // this.fields = combinedFields.concat( JSON.parse(JSON.stringify(this.fields)) );

    }

    handleInputChange(event) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        //this.isLoading = true;
        this.delayTimeout = setTimeout(() => {
            if (searchKey.length >= 2) {
                search({
                    objectName: this.objName,
                    searchFields: this.searchField,
                    returnFields: this.displayFields,
                    searchTerm: searchKey,
                    filter: this.filter
                })
                    .then(result => {
                        let stringResult = JSON.stringify(result);
                        let allResult = JSON.parse(stringResult);
                        allResult.forEach(record => {
                            record.FIELD1 = this.getField(record, this.field);
                            record.FIELD2 = this.getField(record, this.field1);
                            record.FIELD3 = this.getField(record, this.field2);
                        });
                        this.searchRecords = allResult;

                    })
                    .catch(error => {
                        console.error('Error:', error);
                    })
                    .finally(() => {
                        //this.isLoading = false;
                    });
            } else {
                this.searchRecords = undefined;
            }
        }, DELAY);
    }

    getField(record, field) {
        let value = '';
        if (field) {
            let fields = field.split('.');
            if (record[fields[0]])
                value = record[fields[0]];
            if (fields.length > 1) {
                fields.splice(0, 1);
                fields.forEach(obj => {
                    if (value[obj]) value = value[obj];
                });
            }
        }
        return value;
    }

    handleSelect(event) {

        let recordId = event.currentTarget.dataset.recordId;

        let selectRecord = this.searchRecords.find((item) => {
            return item.Id === recordId;
        });
        this.selectedRecord = selectRecord;

        const selectedEvent = new CustomEvent('lookup', {
            bubbles: true,
            composed: true,
            cancelable: true,
            detail: {
                data: {
                    record: selectRecord,
                    recordId: recordId,
                    currentRecordId: this.currentRecordId
                }
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleClose() {
        this.selectedRecord = undefined;
        this.searchRecords = undefined;
        const selectedEvent = new CustomEvent('lookup', {
            bubbles: true,
            composed: true,
            cancelable: true,
            detail: {
                undefined,
                undefined,
                currentRecordId: this.currentRecordId
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    openRecord() {
        if (this.selectedRecord) {
            window.open('/' + this.selectedRecord.Id, '_blank').focus();
        }
    }

    titleCase(string) {
        var sentence = string.toLowerCase().split(" ");
        for (var i = 0; i < sentence.length; i++) {
            sentence[i] = sentence[i][0].toUpperCase() + sentence[i].slice(1);
        }
        return sentence;
    }
}