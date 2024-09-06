import { LightningElement,wire  } from 'lwc';
// import getContacts from '@salesforce/apex/DisplayReportController.getContacts';

const table_columns =[
		{label: 'Id' , fieldName: 'id' ,type: 'text'},
		{label: 'LastName' , fieldName: 'LastName' ,type:'text'},
		{label: 'FirstName' , fieldName: 'FirstName' ,type:'text'}
	];
export default class HRISReportCaller extends LightningElement {
			columns=table_columns;
			// @wire(getContacts) contacts;
}