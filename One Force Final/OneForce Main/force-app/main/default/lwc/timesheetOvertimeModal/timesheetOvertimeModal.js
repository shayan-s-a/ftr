import { LightningElement, api, track, wire } from 'lwc';
import updateOvertimeTimesheet from '@salesforce/apex/TimesheetController.updateOvertimeTimesheet';
import removeOvertimeTimesheet from '@salesforce/apex/TimesheetController.removeOvertimeTimesheet';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TimesheetOvertimeModal extends LightningModal {
    @api evtDataset;
    typeOfOvertime;
    overtimeStartTime;
    overtimeEndTime;
    overtimeDescription;
    disableTimeTo = true;
    startTimeChanged = false;
    endTimeChanged = false;

    get disableSaveBtn() {
        if (this.overtimeStartTime !== undefined && this.overtimeEndTime !== undefined && this.typeOfOvertime !== undefined && this.overtimeDescription !== undefined) {
            return false;
        }
        return true;
    }

    formatTime(overtime) {
        let apexTime = overtime; // The time value returned from Apex

        // Convert milliseconds to hours, minutes, and seconds
        let hours = Math.floor(apexTime / (1000 * 60 * 60));
        let minutes = Math.floor((apexTime % (1000 * 60 * 60)) / (1000 * 60));
        let seconds = Math.floor((apexTime % (1000 * 60)) / 1000);

        // Format the time
        let formattedTime = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;

        console.log(formattedTime); // Output: "01:00:00"
        return formattedTime;
    }

    get getOvertimeStartTime() {
        console.log(this.evtDataset.overtimefrom);
        if (this.evtDataset.overtimefrom !== undefined) {
            if (this.startTimeChanged) {
                return this.overtimeStartTime;
            }
            this.overtimeStartTime = this.formatTime(this.evtDataset.overtimefrom);
            return this.overtimeStartTime;
        }
        return null;
    }

    get getOvertimeEndTime() {
        console.log(this.evtDataset.overtimeto);
        if (this.evtDataset.overtimeto !== undefined) {
            if (this.endTimeChanged) {
                return this.overtimeEndTime;
            }
            this.overtimeEndTime = this.formatTime(this.evtDataset.overtimeto);;
            return this.overtimeEndTime;
        }
        return null;
    }

    renderedCallback() {
        try {
            this.typeOfOvertime = this.template.querySelector('lightning-combobox').value;
            this.overtimeDescription = this.template.querySelector('lightning-textarea').value;
        } catch (error) {
            console.log('error');
            console.log(error);
        }
    }

    get typeOfOvertimes() {
        return [
            { label: 'Active', value: 'Active' },
            { label: 'Passive', value: 'Passive' },
            { label: 'Working Holiday', value: 'Working Holiday' },
        ];
    }

    get isEdit() {
        return this.evtDataset.iseditmodal ? true : false;
    }

    handleChange(e) {
        let { name, value } = e.target;
        if (name == 'typeOfOvertime') {
            console.log(value);
            console.log(this.evtDataset.id);
            this.typeOfOvertime = value;
        }
        else if (name == 'overtimeStartTime') {
            console.log(value);
            let timeVal = value.split('.')[0];
            this.overtimeStartTime = timeVal;
            this.startTimeChanged = true;
        }
        else if (name == 'overtimeEndTime') {
            console.log(value);
            let timeVal = value.split('.')[0];
            this.overtimeEndTime = timeVal;
            this.endTimeChanged = true;
        }
        else if (name == 'overtimeDescription') {
            console.log(value);
            this.overtimeDescription = value;
        }
        if (this.overtimeStartTime !== undefined && this.overtimeEndTime !== undefined) {
            this.disableSaveBtn = false;
        }

    }

    handleRemove(e) {
        removeOvertimeTimesheet({ timesheetId: this.evtDataset.id })
            .then(result => {
                console.log('Result', result);
                if (result == 'OK') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Overtime Removed',
                            message: 'Overtime removed successfully.',
                            variant: 'success'
                        })
                    );
                    this.close('OK');
                }
                else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Problem while removing overtime',
                            message: 'Overtime was not removed successfully. If this error keeps coming up then contact your System Administrator.',
                            variant: 'info'
                        })
                    );
                    this.close('NOT OK');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error in Removing',
                        message: 'Error in removing timsheet. ' + JSON.stringify(error),
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.close('NOT OK');
            });
    }

    convertToSeconds(time) {
        var timeParts = time.split(":");
        var hours = parseInt(timeParts[0], 10);
        var minutes = parseInt(timeParts[1], 10);
        var seconds = parseInt(timeParts[2], 10);
        return hours * 3600 + minutes * 60 + seconds;
    }

    handleOkay(e) {
        if (!this.overtimeStartTime || !this.overtimeEndTime || !this.overtimeDescription) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill in all required fields.',
                    variant: 'error'
                })
            );
            return; // Stop execution if required fields are missing
        }


        let startSeconds = this.convertToSeconds(this.overtimeStartTime);
        let endSeconds = this.convertToSeconds(this.overtimeEndTime);
        if (startSeconds > endSeconds) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Enter Valid Time',
                    message: 'Start Time should be less than End Time.',
                    variant: 'info'
                })
            );
        }
        else {
            updateOvertimeTimesheet({ timesheetId: this.evtDataset.id, typeOfOvertime: this.typeOfOvertime, overtimeStartTime: this.overtimeStartTime, overtimeEndTime: this.overtimeEndTime, overtimeDescription: this.overtimeDescription })
                .then(result => {
                    console.log('Result', result);
                    if (result == 'OK') {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Overtime Saved',
                                message: 'Overtime saved successfully.',
                                variant: 'success'
                            })
                        );
                        this.close('OK');
                    }
                    else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Problem while saving overtime',
                                message: 'Overtime was not saved successfully. If this error keeps coming up then contact your System Administrator.',
                                variant: 'info'
                            })
                        );
                        this.close('NOT OK');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error in Saving',
                            message: 'Error in saving overtime. ' + JSON.stringify(error),
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );
                    this.close('NOT OK');
                });
        }
    }
}