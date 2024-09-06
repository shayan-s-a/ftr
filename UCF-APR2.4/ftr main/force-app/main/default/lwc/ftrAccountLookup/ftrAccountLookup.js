import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import tmpl from './ftrAccountLookup.html';
import { getOmniMergeFields } from 'c/ftrUtils';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';


const DELAY = 300;
export default class ftrAccountLookup extends NavigationMixin(OmniscriptBaseMixin(LightningElement)) {

    @api objName = 'Account';
    @api iconName = 'standard:account';
    @api labelName;
    @api filter;
    @api readOnly = false;
    @api required;
    @api currentRecordId;
    @api placeholder = 'Search';
    @api createRecord;
    @api searchField;
    @api displayFields = 'Name, Owner.Name, AccountNumber';
    @track searchKey;
    @track error;

    searchTerm;
    delayTimeout;

    searchRecords;
    @track selectedRecord;
    objectLabel;
    isLoading = false;
    inputClass = 'slds-input slds-combobox__input';
    field;
    field1;
    field2;
    field3;

    ICON_URL = '/apexpages/slds/latest/assets/icons/{0}-sprite/svg/symbols.svg#{1}';

    render() {
        return tmpl;
    }

    @api 
    get valueName() {
        return this.selectedRecord.FIELD1;
    }
    set valueName(val) {
        if(val) {
            this.selectedRecord = { 
                FIELD1: val
            }
        }
    }
    
    @api 
    get valueId() {
        return this.currentRecordId;
    }
    set valueId(val) {
        if (val) {
            this.currentRecordId = val;
            console.log('valueId', val);
            setTimeout(async () => {
                this.omniUpdateDataJson(val, true);
            }, 100);
        }
    }

    get isValid() {
        return this.isRequired ? (this.selectedRecord ? true : false) : true;
    }

    get isRequired() {
        return this.required && this.required.valueOf().toLowerCase() == 'yes';
    }

    @api
    checkValidity() {
        return this.isValid;
    }

    renderedCallback() {
        super.renderedCallback && super.renderedCallback()
        this.checkValidity();
        this.inputClass = this.showValidation ? 'slds-input slds-combobox__input slds-has-error' : 'slds-input slds-combobox__input';
    }

    connectedCallback() {
        let icons = this.iconName.split(':');
        this.ICON_URL = this.ICON_URL.replace('{0}', icons[0]);
        this.ICON_URL = this.ICON_URL.replace('{1}', icons[1]);

        this.placeholder = this.placeholder.replace(/([A-Z])/g, ' $1').trim()
        this.labelName = this.labelName.replace(/([A-Z])/g, ' $1').trim()

        this.objectLabel = this.objName.replace('__c', '');
        this.objectLabel = this.objectLabel.replaceAll('_', ' ');
        this.objectLabel = this.titleCase(this.objectLabel);

        let fieldList = Array.isArray(this.displayFields) ? this.displayFields : this.displayFields.split(',');
        this.field = fieldList[0]?.trim();
        this.field1 = fieldList[1]?.trim();
        this.field2 = fieldList[2]?.trim();
        this.field3 = fieldList[3]?.trim();
    }

    handleInputChange(event) {
        window.clearTimeout(this.delayTimeout);
        this.searchKey = event.target.value;
        //this.isLoading = true;
        this.delayTimeout = setTimeout(() => {
            if (this.searchKey.length >= 2) {
                const params = {
                    input: {
                        objectName: this.objName,
                        searchFields: this.searchField,
                        returnFields: this.displayFields,
                        searchTerm: this.searchKey,
                        filter: this.filter ? getOmniMergeFields(this.omniJsonData, this.filter).replaceAll('"', '\'') : null
                    },
                    sClassName: 'CustomOmniscriptHelper',
                    sMethodName: 'search',
                    options: '{}',
                };
                this.omniRemoteCall(params, true).then(response => {
                    let stringResult = JSON.stringify(response);
                    let allResult = JSON.parse(stringResult).result.result;
                    allResult.forEach(record => {
                        record.FIELD1 = this.getField(record, this.field);
                        record.FIELD2 = this.getField(record, this.field1);
                        record.FIELD3 = this.getField(record, this.field2);
                        record.FIELD4 = this.getField(record, this.field3);
                    });
                    this.searchRecords = allResult;
                }).catch(error => {
                    this.error = error.message ? error.message : error;
                    console.error('Error:', error);
                });
            } else {
                this.searchRecords = undefined;
            }
        }, DELAY);
        // this.omniValidate();
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
        this.omniUpdateDataJson(recordId, true);
        this.omniValidate();

    }

    createCase() {
        const params = {
            input: {
                objectName: 'Case',
                recordTypeName: 'Account Creation'
            },
            sClassName: 'CustomOmniscriptHelper',
            sMethodName: 'getRecordTypeId',
            options: '{}',
        };
        this.omniRemoteCall(params, true).then(response => {
            let stringResult = JSON.stringify(response);
            let result = JSON.parse(stringResult).result;
            const defaultValues = encodeDefaultFieldValues({
                Create_Account_Name__c: this.searchKey,
                Street_Address__c: this.omniJsonData.AddressQualification.AddressQualificationResult.QualifiedAddress.Address,
                City__c: this.omniJsonData.AddressQualification.AddressQualificationResult.QualifiedAddress.City,
                CAP_State__c: this.omniJsonData.AddressQualification.AddressQualificationResult.QualifiedAddress.State,
                Zip_Code__c: this.omniJsonData.AddressQualification.AddressQualificationResult.QualifiedAddress.ZipCode.substring(0, 5)
            });
    
            console.log(defaultValues)
    
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Case',
                    actionName: 'new'
                },
                state: {
                    defaultFieldValues: defaultValues,
                    recordTypeId: result.recordTypeId
                }
            }).then(url => {
                window.open(url, "_blank");
            });;
        }).catch(error => {
            this.error = error.message ? error.message : error;
            console.error('Error:', error);
        });
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
        this.omniUpdateDataJson(null, true);
        this.omniValidate();
    }

    titleCase(string) {
        var sentence = string.toLowerCase().split(" ");
        for (var i = 0; i < sentence.length; i++) {
            sentence[i] = sentence[i][0].toUpperCase() + sentence[i].slice(1);
        }
        return sentence;
    }
}