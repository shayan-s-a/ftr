import { LightningElement, api, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import getUserDetails from '@salesforce/apex/TimesheetController.getUserDetails';
export default class Timecard extends LightningElement {

    userId = Id;
    userDetails = {};
    @wire(getUserDetails, { userId: '$userId' })
    getUserDetails({ error, data }) {
        if (data) {   
            console.log('Data', data);
            this.userDetails = data;
        } else if (error) {
            console.error('Error:', error);
            
        }
    }
   
    get isNesponManager() {
        return this.userDetails?.isNesponManager == 'true' ? true : false;
    }

    get isLineManager() {
        return this.userDetails?.isLineManager == 'true' ? true : false;
    }
    // Kauser
   /* get isDivisionalHead() {
        alert ( 'Test:: DH----------------'+Object.keys(this.userDetails).length );
        return this.userDetails?.isDivisionalHead == 'true' ? true : false;
    }*/
    get employeeTimesheetsFound() {
        
        return this.userDetails?.employeeTimesheetsFound == 'true' ? true : false;
    }

    get requestFound() {
        return this.userDetails?.requestFound == 'true' ? true : false;
    }

    get userExist() {
        return this.userDetails ? Object.keys(this.userDetails).length : false;
    }


}