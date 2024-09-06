import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import PREM_FIELD from '@salesforce/schema/Account.vlocity_cmt__PremisesId__c';
import getPricingAttributes from '@salesforce/apex/PricingFormulaDefinitionController.getConfigurablePricingAttributes';
import testPricingFormula from '@salesforce/apex/PricingFormulaDefinitionController.testPricingFormula';
import clearCache from '@salesforce/apex/PricingFormulaDefinitionController.clearCache';
import getCalculatedFormula from '@salesforce/apex/PricingFormulaDefinitionController.getCalculatedFormula';
import { NavigationMixin } from 'lightning/navigation';
import PRICING_FORMULA_OBJECT from '@salesforce/schema/Pricing_Formula_Definition__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { refreshApex } from '@salesforce/apex';



const columns = [
    { label: 'Pricing Variable', fieldName: 'name', sortable: true },
    { label: 'Value', fieldName: 'value', sortable: true, cellAttributes: { class: { fieldName: 'text_color' } } }
];

export default class PricingFormulaTester extends NavigationMixin(LightningElement) {
    @track currentFormula = '';
    @track formulaValue = '';
    @track products = [];
    @track editMode = false;
    @api serviceAccountId;
    @track formulaObjInfo;

    formulas = [];
    loading = false;
    currentTerm;
    currentProduct;
    columns = columns;
    activeSections = [];
    activeSectionsMessage = '';
    accountFilter = " RecordType.Name = 'Service' ";
    accountFields = "Name";
    accountDisplayFields = 'Name, Parent.Name';

    handleLookup(event) {
        console.log(JSON.stringify(event.detail))
        if (event.detail.data && event.detail.data.record)
            this.serviceAccountId = event.detail.data.record.Id;
        else
            this.serviceAccountId = null;
    }

    @wire(getRecord, { recordId: '$serviceAccountId', fields: [NAME_FIELD, PREM_FIELD] })
    currentServiceAccount;

    // @wire(getPricingAttributes, { productCode: '$currentProduct'})
    attributes;
    attributeVals = {};
    pricingVars;
    prices;
    error;

    get serviceAccountName() {
        return getFieldValue(this.currentServiceAccount.data, NAME_FIELD);
    }

    get terms() {
        return [
            { label: '12 Months', value: '12 Months' },
            { label: '24 Months', value: '24 Months' },
            { label: '36 Months', value: '36 Months' },
            { label: '60 Months', value: '60 Months' },
        ];
    }

    links = [
        {
            label: 'Pricing Variable Definitions',
            open: function () {
                window.open('/lightning/setup/CustomSettings/page?address=/setup/ui/listCustomSettingsData.apexp?id=aFN', '_blank').focus();
            }
        },
        {
            label: 'Pricing Formula Matrix',
            open: function () {
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Pricing_Formula_Matrix__c',
                        actionName: 'list'
                    },
                    state: {
                        filterName: 'All'
                    },
                });
            }
        },
        {
            label: 'Multiplier',
            open: function () {
                window.open('/lightning/setup/CustomSettings/page?address=/setup/ui/listCustomSettingsData.apexp?id=aFP', '_blank').focus();
            }
        },
        {
            label: 'Loading Rate',
            open: function () {
                window.open('/lightning/setup/CustomSettings/page?address=/setup/ui/listCustomSettingsData.apexp?id=aFO', '_blank').focus();
            }
        },
        {
            label: 'Class Of Service Charge',
            open: function () {
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Pricing_CoS__c',
                        actionName: 'list'
                    },
                    state: {
                        filterName: 'All'
                    },
                });
            }
        },
        {
            label: 'Other Operating Cost',
            open: function () {
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Pricing_Other_Operating_Cost__c',
                        actionName: 'list'
                    },
                    state: {
                        filterName: 'All'
                    },
                });
            }
        },
        {
            label: 'Competitor Group Pricing',
            open: function () {
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Group_Pricing_Matrix__c',
                        actionName: 'list'
                    },
                    state: {
                        filterName: 'All'
                    },
                });
            }
        },
        {
            label: 'Wire Center',
            open: function () {
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Wire_Center__c',
                        actionName: 'list'
                    },
                    state: {
                        filterName: 'All'
                    },
                });
            }
        },
        {
            label: 'Attribute Based SNEs',
            open: function () {
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'ftr_Attribute_Based_SNE__c',
                        actionName: 'list'
                    },
                    state: {
                        filterName: 'All'
                    },
                });
            }
        }
    ];

    handleSectionToggle(event) {
        if (event.detail.openSections.includes(this.currentFormula)) {
            event.detail.openSections = null;
        } else {
            event.detail.openSections = this.currentFormula;
        }
        console.log(JSON.parse(JSON.stringify(event.detail)));
    }

    @wire(getObjectInfo, { objectApiName: PRICING_FORMULA_OBJECT })
    pricingFormulaObjInfo({ data, error }) {
        console.log('getting formulas');
        this.formulas = [];
        if (data) {
            for (let field in data.fields) {
                if (field.startsWith('Formula') && !field.endsWith('b__c')) {
                    this.formulas.push({
                        label: data.fields[field].label,
                        value: field
                    })
                }
            }
        }
    }

    get disableTestButton() {
        return !this.serviceAccountId;
    }

    handleAccountChange(event) {
        this.currentServiceAccount = event.detail.value;
        console.log(this.currentServiceAccount);
        if (this.currentServiceAccount.length === 18 && this.currentServiceAccount.startsWith("001")) {
            console.log('Account Id entered');
            this.serviceAccountId = event.detail.value;
        }
    }

    handleFormulaChange(event) {
        if (event)
            this.currentFormula = event.detail.value;
        console.log(this.currentFormula);
        getCalculatedFormula({ //imperative Apex call
            formula: this.currentFormula
        }).then(data => {
            console.log(data)
            this.formulaValue = data.formulaValue;
            this.products = [];
            this.currentProduct = null;
            this.attributes = null;
            for (let product in data.products) {
                this.products.push({
                    value: product,
                    label: data.products[product]
                })
            }
        }).catch(error => {
            this.showNotification({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            });
        });
    }

    handleTermChange(event) {
        this.currentTerm = event.detail.value;
    }

    handleProductChange(event) {
        this.currentProduct = event.detail.value;
        getPricingAttributes({ //imperative Apex call
            productCode: this.currentProduct
        }).then(data => {
            this.attributes = data;
            let i = 0;
            for (i = 0; i < data.length; i++) {
                this.attributes[i].value = null;
            }
            console.log(this.attributes);
            this.attributeVals = {};
        }).catch(error => {
        });
    }

    handleAttributeChange(event) {
        let name = event.target.dataset.item;
        let value = event.detail.value;
        if (name === 'ATTR_CONTRACT_TERM') {
            this.currentTerm = value;
        }

        this.attributeVals[name] = value;
        console.log(this.attributeVals);
        console.log(Object.keys(this.attributeVals));
        for (const name of Object.keys(this.attributeVals)) {
            console.log(this.attributeVals[name]);
        }
    }

    @api
    testFormula() {
        this.loading = true;
        testPricingFormula({ //imperative Apex call
            serviceAccountId: this.serviceAccountId,
            productCode: this.currentProduct,
            serviceTerm: this.currentTerm,
            pricingAttrVals: this.attributeVals //attrVals
        }).then(data => {
            console.log(data);
            if (data.error) {
                this.showNotification({
                    title: 'Error',
                    message: data.error,
                    variant: 'error',
                });
                this.loading = false;
                return;
            }
            this.pricingVars = data.pricingVars;
            this.prices = {
                MRC: data.record[this.currentFormula],
                NRC: data.record[this.currentFormula.replaceAll('__c', 'b__c')]
            };
            this.loading = false;
        }).catch(error => {
            this.loading = false;
            this.showNotification({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            });
            this.pricingVars = null;
            this.prices = null;
        });
    }

    @api
    clearABPCache() {
        this.loading = true;
        clearCache().then(data => {
            console.log(data);
            this.loading = false;
        }).catch(error => {
            this.loading = false;
            this.showNotification({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            });
        });
    }

    showNotification(obj) {
        const evt = new ShowToastEvent(obj);
        this.dispatchEvent(evt);
    }

    openEditFormula() {
        this.editMode = true;
    }

    closeEditFormula() {
        this.editMode = false;
        this.handleFormulaChange();
    }
}