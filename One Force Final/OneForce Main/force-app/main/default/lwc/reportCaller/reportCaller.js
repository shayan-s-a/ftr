import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import getReportData from '@salesforce/apex/ReportAPIHandler.getReportData';

export default class ReportCaller extends LightningElement {
    connectedCallback() {
        // Load required JS files
        Promise.all([
            loadScript(this, 'https://www.salesforce.com/resourceUrl/SLDS213'),
            loadScript(this, 'https://www.salesforce.com/resourceUrl/ReportAPIHandlerJSFile')
        ]).then(() => {
            // Scripts loaded
        }).catch(error => {
            // Handle error
        });
    }

    callReport() {
        getReportData({ reportId: '00O8I000000TMjqUAG' })
            .then(response => {
                // Process the report data
                console.log(response);
            })
            .catch(error => {
                // Handle error
                console.error(error);
            });
    }
}