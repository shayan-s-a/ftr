import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ModalSA extends LightningElement {
    text;
    @api message;
    @api heading;
    @api dateFrom;
    @api dateTo;
    @api timeSheetData;
    @api isModal = false;
    @api warningModal;
    isModal = true;
    checkedList = [];
    handleChange(evt) {
        this.text = evt.target.value;
    }

    // get disableButton() {
    //     return !this.text;
    // }

    handleSave() {
        if(this.warningModal)
        {
            this.warningModal = false;
            this.dispatchEvent(new CustomEvent('proceed'));
        }
        else
        {
            if(this.checkedList.length == 0)
            {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Day/Date Not Selected',
                        message: 'Please select a day/date before saving.',
                        variant: 'info'
                    })
                );
            }
            else if (this.text) {
                this.dispatchEvent(new CustomEvent('save', { 
                    detail: {
                        reason:this.text,
                        checkedRow: this.checkedList
                    }}));
            } 
            else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Reason Required',
                        message: 'Please enter reason before saving.',
                        variant: 'info'
                    })
                );
            }
            //console.log(`Date from:::::::: ${this.dateFrom}`);
        }

    }
    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleRowChecked(evt) {
            
        let { daydate, dayname, id, checked} = evt.detail.data;
        console.log('daydate : ', daydate);
        console.log('dayname : ', dayname);
        console.log('id : ', id);
        console.log('checked : ', evt.detail.checkbox);
        let newData = [];

        if(evt.detail.checkbox)
        {
            console.log('INSIDE IF');
            this.timeSheetData.forEach(ele => {
                let newRow = { ...ele };
                // Update Existing Record
                if (id != undefined && id != null
                    && id == ele.id) {
                    console.log('Inside Match Id : ', ele.id + ' => ' + id);
                    newRow.checked = !newRow.checked;
                    this.checkedList.push(ele.id);
                    
                }
                    //newData.push(newRow);
                    //this.checkedList.push(newRow);
            })
            //this.timeSheetData = [...newData];
            // console.log('this.checkedList size: ', this.checkedList.length);
            // console.log('newData size: ', newData.length);
            // console.log('timeSheetData : ', this.timeSheetData);
        }
        else
        {
            console.log('**********UNCHECKED*************');
            this.checkedList = this.checkedList.filter((element) => element != id);
        }
        console.log('this.checkedList size: ', this.checkedList.length);
        
    }

    // handleSelectAll(e) {
    //     this.unlockVal = true;
    //     let finalList = [];
    //     if (e.target.checked) {
    //         this.timeSheetData.forEach(element => {
    //             let singleElement = { ...element };
    //             if (singleElement.id) {
    //                 singleElement.checked = true;
    //             }
    //             finalList.push(singleElement);
    //         });
    //     }
    //     else {
    //         this.timeSheetData.forEach(element => {
    //             let singleElement = { ...element };
    //             if (singleElement.id) {
    //                 singleElement.checked = false;
    //             }
    //             finalList.push(singleElement);
    //         });
    //     }
    //     this.timeSheetData = [...finalList];
    // }
}