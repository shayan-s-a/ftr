import { track, api, LightningElement } from 'lwc';
import tmpl from './ftrServiceAccountTable.html';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

const columns = [
    { label: 'Street Address', fieldName: 'StreetAddress' },
    { label: 'City', fieldName: 'City' },
    { label: 'State', fieldName: 'State' },
    { label: 'Zip', fieldName: 'Zip' },
    { label: 'Latitude', fieldName: 'Latitude' },
    { label: 'Longitude', fieldName: 'Longitude' },
    { label: 'WC Max Speed', fieldName: 'WireCenterSpeed' },
    { label: 'DSAT Ticket #', fieldName: 'DSATTicket' },
];

export default class FtrServiceAccountTable extends OmniscriptBaseMixin(LightningElement) {
    columns = columns;
    @track error;
    @track loading = false;
    @api maxRowSelection = '1';
    @api keyField = 'Id';
    @track selectedAddress;

    render() {
        return tmpl;
    }

    get data() {
        return this.omniJsonData.ServiceAccounts;
    }

    renderedCallback() {

    }

    connectedCallback() {
    }

    handleAddressSelection(event) {
        this.selectedAddress = event.detail.selectedRows[0];
        this.omniUpdateDataJson(this.selectedAddress, true);
    }

}