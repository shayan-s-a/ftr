import { LightningElement, api, wire, track } from 'lwc';
import Id from '@salesforce/user/Id';
import getUserDetails from '@salesforce/apex/TimesheetController.getUserDetails';
export default class TimecardAS extends LightningElement {

    userId = Id;
    @track userDetails = {};
    @wire(getUserDetails, { userId: '$userId' })
    getUserDetails({ error, data }) {
        if (data) {
            // console.log(':::: Data', data);
            //Asir adding this part to convert date format
            let [year, month, date] = data.HireDate.split("-");
            let formattedHireDate = `${date}/${month}/${year}`;
            this.userDetails = {
                ...data, 
                'formattedHireDate':formattedHireDate
            };
            console.log(':::: Data', JSON.stringify(this.userDetails));
        } else if (error) {
            console.error('Error:', error);
        }
    }

    get showApprovalAndUnlockTab() {
        return (this.isNesponManager || this.IsDivisionalHead || this.IsHRPractitioner) ? true : false;
    }
    get isNesponManager() {
        return this.userDetails?.isNesponManager == 'true' ? true : false;
    }

    get IsDivisionalHead() {
        return this.userDetails?.IsDivisionalHead == 'true' ? true : false;
    }

    get IsHRPractitioner() {
        return this.userDetails?.IsHRPractitioner == 'true' ? true : false;
    }

    get isLineManager() {
        return this.userDetails?.isLineManager == 'true' ? true : false;
    }

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