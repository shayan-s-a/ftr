import { LightningElement, api, track } from 'lwc';

export default class TimesheetRowAS extends LightningElement {
    @api timesheet;
    @api isNesponManager = false;
    @api isLineManager = false;
    //Asir added these variable
    @track disableCheckbox = false;
    @api changeWeeklyRowColspan;

    get readOnly() {
        return this.isLineManager;
    }

    get isManager() {
        return (this.isNesponManager || this.isLineManager);
    }

    get columnClass() {
        let finalClasses = !this.timesheet.isEditable ? 'notEditable ' : ''
        finalClasses += this.timesheet.combineRow ? 'noTopBorder' : '';
        return finalClasses;
    }

    // get summaryRowClass() {
    //     return 'border'
    // }

    get rowColumnsWidth() {
        return this.isManager ? 9 : 8;
    }

    handleRowRefresh(evt) {
        console.log('REFRESH : ');
        if (this.timesheet.inEditMode && !this.readOnly) {
            this.dispatchEvent(new CustomEvent('rowrefresh', { detail: evt.target.dataset }));
        }
    }

    handleRowEdit(evt) {
        console.log('ROW EDIT : ');
        if (!this.timesheet.inEditMode && this.timesheet.isEditable && !this.readOnly) {
            this.dispatchEvent(new CustomEvent('rowedit', { detail: evt.target.dataset }));
        }
    }

    handleRowChange(evt) {
        let { id, emptyrownumber, name } = evt.target.dataset;
        let finalData = { id, emptyrownumber, name, value: evt.target.value };
        console.log('ROW CHANGE : ', finalData);
        if (this.timesheet.inEditMode && !this.readOnly) {
            this.dispatchEvent(new CustomEvent('rowupdate', { detail: finalData }));
        }
    }

    handleAddRow(evt) {
        if (!this.readOnly) {
            this.dispatchEvent(new CustomEvent('rowadd', { detail: evt.target.dataset }));
        }
    }

    handleRowDelete(evt) {
        if (!this.readOnly) {
            this.dispatchEvent(new CustomEvent('rowdelete', { detail: evt.target.dataset }));
        }
    }

    // For Approval
    handleRowChecked(evt) {
        if (!this.readOnly && this.isNesponManager) {
            this.dispatchEvent(new CustomEvent('rowchecked', { detail: evt.target.dataset }));
        }
    }

    handleBlur() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            this.dispatchEvent(new CustomEvent('validrow', { detail: true }));
            console.log('VALID');
        } else {
            this.dispatchEvent(new CustomEvent('invalidrow', { detail: false }));
            console.log('INVALID');
        }
    }
}