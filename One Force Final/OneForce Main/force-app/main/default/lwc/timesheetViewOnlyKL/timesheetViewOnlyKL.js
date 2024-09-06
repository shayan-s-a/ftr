import { LightningElement, api, track, wire } from 'lwc';
import getTimesheetToView from '@salesforce/apex/TimesheetController.getTimesheetToView';

export default class TimesheetViewOnlyKL extends LightningElement {
    spinLoader = true;
    @api recordId;
    @api isLineManager;
    @api dateFrom;
    @api dateTo;
    @track timeSheetData = [];

    timesheetWiredResult;
    @wire(getTimesheetToView, { conId: '$recordId', dateFromParam: '$dateFrom', dateToParam: '$dateTo' })
    timesheetDataWire(result) {
        this.timesheetWiredResult = result;
        if (result.data) {
            console.log(':::: timeSheetData:', result.data);
            let finalData = result.data.map(ele => {
                return { ...ele, showOptions: false, approvalScreen: false };
            });
            this.timeSheetData = finalData;
            this.spinLoader = false;
        } else if (result.error) {
            console.error(':::: Error timeSheetData:', result.error);
            this.spinLoader = false;
        }
    }

    handleChange(evt) {
        let { name, value } = evt.target;
        if (name == 'dateFrom') {
            this.spinLoader = true;
            this.dateFrom = value;
        }
        else if (name == 'dateTo') {
            this.spinLoader = true;
            this.dateTo = value;
        }
    }
}