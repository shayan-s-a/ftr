import { LightningElement, api, wire, track } from 'lwc';
import getImageUrl from '@salesforce/apex/TimesheetController.getImageUrl';

export default class UserDetails extends LightningElement {
    @api userDetails = {}
    @api imageURL;
    //Asir added new property in user details
    @api showMyTimeEntry = false;
    
    // imageUrlRes;
    // @wire(getImageUrl, { conId: '$conId'})
    // imageUrlDataWire(result) {
    //     if (result.data) {
    //         console.log('user image url:: ',result.data);
    //         this.imageUrlRes = result.data;
    //     } else if (result.error) {
    //         console.error(':::: Error timeSheetData:', result.error);
    //     }
    // }
}