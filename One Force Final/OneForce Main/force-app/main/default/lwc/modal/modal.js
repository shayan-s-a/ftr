import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Modal extends LightningElement {
    text;
    @api message;
    @api heading;
    handleChange(evt) {
        this.text = evt.target.value;
    }

    // get disableButton() {
    //     return !this.text;
    // }

    handleSave() {
        if (this.text) {
            this.dispatchEvent(new CustomEvent('save', { detail: this.text }));
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Reason Required',
                    message: 'Please enter reason before saving.',
                    variant: 'info'
                })
            );
        }

    }
    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }
}