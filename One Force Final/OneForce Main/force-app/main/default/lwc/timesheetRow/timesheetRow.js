import { LightningElement, api, track } from 'lwc';
import TimesheetOvertimeModal from 'c/timesheetOvertimeModal';
export default class TimesheetRow extends LightningElement {
    @api timesheet;
    @api isNesponManager = false;
    @api isDivisionalHead = false;
    @api isHRPractitioner = false;
    @api isLineManager = false;
    @api screenApproval=false;

    get noHours(){
        return this.timesheet.hours == 0 ? true : false;
    }
    //Asir added property to handle timesheet view
    @api changeWeeklyRowColspan = false;

    @api pasteDisabled;
    @api checkOT;

    get readOnly() {
        return this.isLineManager && !this.showCheckbox;
    }

    get showOtBtn(){
        return (this.isLineManager || this.timesheet.approved || this.timesheet.rejected || this.timesheet.recall) ? false : true;
    }

    get isManager() {
        return (this.isNesponManager || this.isLineManager || this.isHRPractitioner);
    }

    get showCheckbox() {
        return (this.isNesponManager || this.isDivisionalHead || this.isHRPractitioner);
    }

    get columnClass() {

        let finalClasses = !this.timesheet.isEditable ? 'notEditable ' : ''
        finalClasses += this.timesheet.combineRow ? 'noTopBorder' : '';
        finalClasses += " columnClasscss";
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
    async handleOvertimeModal(e){
        // let { daydate, dayname, id, emptyrownumber } = e.target.dataset;
        console.log(this.timesheet.approved);
        console.log(this.timesheet.rejected);
        console.log(this.showOtBtn);
        const result = await TimesheetOvertimeModal.open({
            size: 'medium',
            description: 'Overtime Modal',
            content: '',
            evtDataset: e.target.dataset,
        });
        if(result == 'OK'){
            this.dispatchEvent(new CustomEvent('refreshtimesheet'));
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
        let finalData={}
        console.log('name of the field',name);
        // paycode='';
        if (name=='project') {
            console.log('ma chala');
            console.log(evt.target.options.find(opt => opt.value === evt.target.value).paycode);
            let paycode = evt.target.options.find(opt => opt.value === evt.target.value).paycode;
            console.log('mjy paycode mil gaya yayyyyyyyy :D',paycode);
            finalData = { id, emptyrownumber, name, value: evt.target.value, paycode:paycode };

        }
        else{
            finalData = { id, emptyrownumber, name, value: evt.target.value };
        }
        console.log('ROW CHANGE : ', JSON.stringify(finalData));
        // console.log('paycode',paycode);
        if (this.timesheet.inEditMode && !this.readOnly) {
            this.dispatchEvent(new CustomEvent('rowupdate', { detail: finalData }));
        }
    }

    handleAddRow(evt) {
        if (!this.readOnly) {
            this.dispatchEvent(new CustomEvent('rowadd', { detail: evt.target.dataset }));
            
            console.log("*****************AFTER EVENT CALLHandle Add Row");
        }
    }

    handleRowDelete(evt) {
        if (!this.readOnly) {
            this.dispatchEvent(new CustomEvent('rowdelete', { detail: evt.target.dataset }));
        }
    }

    // For Approval
    handleRowChecked(evt) {
        console.log('::::: ROW => CHECKED' + JSON.stringify(evt.target.dataset));
        if (!this.readOnly && this.showCheckbox) {
            console.log(':::: INSIDE');
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

    handleOptions(evt)
    {
        console.log('***********Handle Options ', evt.target.value);
        if (!this.readOnly)
        {
            if(evt.target.value == 'CopyRow' )
            {
                console.log('******************Dataset: ', evt.target.dataset);
                this.dispatchEvent(new CustomEvent('rowcopyoption',{detail: evt.target.dataset}));
                // if(this.timesheet.isEditable== true)
                // {
                //     console.log('Paste ENabled')
                //     //this.pasteDisabled = false;
                // }
                
            }
            else if(evt.target.value == 'PasteRow')
            {
                console.log('******************Dataset: ', evt.target.dataset);
                this.dispatchEvent(new CustomEvent('rowpasteoption',{detail: evt.target.dataset}));
            }
            else if(evt.target.value == 'DeleteRow')
            {
                console.log('******************Dataset: ', evt.target.dataset);
                this.dispatchEvent(new CustomEvent('rowdeleteoption',{detail: evt.target.dataset}));

            }
        }
    }
}