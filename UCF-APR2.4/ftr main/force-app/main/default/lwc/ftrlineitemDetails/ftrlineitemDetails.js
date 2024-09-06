import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PREM_OBJECT from '@salesforce/schema/vlocity_cmt__Premises__c';


export default class ftrlineitemDetails extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track objectName;
    @track fields;
    @track premisesData;
    @track premisesObjInfo;
 
    @wire(getObjectInfo, { objectApiName: PREM_OBJECT })
    getPremInfo({ data, error }) {
        this.premisesObjInfo = data;
        console.log(data);
        this.fields = [
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c',
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c',
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c',
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c',
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.DSAT_Ticket__c',
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.Last_DSAT_Check__c',
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.WC_CLLI__c',
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.WC_QOS__c',
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.WC_Speed__c',
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.Lit__c',
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.Market__c',
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.Level__c',
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.Copper_Tier__c',
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.Fiber_Tier__c',
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.Copper_Distance__c',
            this.objectApiName + '.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PremisesId__r.Fiber_Distance__c',
        ];
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    get( { error, data }) {
        if (error) {
            // TODO
            console.log('Error', error);
        } else if (data) {
            console.log(data);
            this.premisesData = [];
            if (data.fields.vlocity_cmt__ServiceAccountId__r.value.fields.vlocity_cmt__PremisesId__r.value.fields) {
                let fieldSet = data.fields.vlocity_cmt__ServiceAccountId__r.value.fields.vlocity_cmt__PremisesId__r.value.fields;
                this.fields.forEach(field => {
                    let fieldApiName = field.split(".").pop();
                    this.premisesData.push({ apiName: fieldApiName, value: fieldSet[fieldApiName].value, label: this.premisesObjInfo.fields[fieldApiName].label });
                });
            }
        }
    }

}