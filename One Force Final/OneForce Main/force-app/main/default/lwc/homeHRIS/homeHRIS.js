import { LightningElement, api, wire, track } from 'lwc';
import Id from '@salesforce/user/Id';
import getUserDetails from '@salesforce/apex/TimesheetController.getUserDetails';
import { NavigationMixin } from 'lightning/navigation';
import backgroundImage from '@salesforce/resourceUrl/HRISBackground';

export default class HomeHRIS extends NavigationMixin(LightningElement) {

    backgroundImageUrl = backgroundImage;
    userId = Id;
    @track userDetails = {};
    @wire(getUserDetails, { userId: '$userId' })
    getUserDetails({ error, data }) {
        if (data) {
            console.log('Data', data);
            this.userDetails = data;
            console.log("Length ::::::  " + Object.keys(this.userDetails).length);
            if (Object.keys(this.userDetails).length >0){
                console.log("Employee is here");
                this.addSubItem(1,'My Timesheet');
                // const newItem = { id: 4, title: 'Sub-item 4' };
                // this.subItems.push(newItem);
                // console.log('this.userDetails.isNesponManager',JSON.stringify(this.userDetails));
            }
            console.log("after 1st IF");
            if (this.userDetails.isLineManager == 'true') {
                console.log("Line manager is here");
                this.addSubItem(2,'Timesheets To View');
                // const newItem2 = { id: 5, title: 'Sub-item 5' };
                // this.subItems.push(newItem2);
                
            } 
            console.log("after 2nd IF");
            if (this.userDetails.isNesponManager == 'true') {
                console.log("Nespon Manager is here");
                this.addSubItem(3,'Employee Timesheet');
                // const newItem3 = { id: 6, title: 'Sub-item 6' };
                // this.subItems.push(newItem3);
            }
        } else if (error) {
            console.error('Error:', error);
        }

    }


    imageLoaded = false;
    container = '';
    // renderedCallback() {
    //     if (!this.imageLoaded) {
    //         if (this.backgroundImageUrl) {
    //             console.log('this.backgroundImageUrl : ', this.backgroundImageUrl);
    //             this.imageLoaded = true;
    //             var css = this.template.querySelector('[data-name="mainDiv"]').style.backgroundImage = 'url(\'' + this.backgroundImageUrl + '\')';
    //             // css.setProperty('--imageLink', this.backgroundImageUrl);
    //             console.log(':::: css ', css);  
                
    //         }
    //     }
    // }

    handleTileClick() {

    }
    handleOnClick(e) {
        console.log('asdasdasd', e.target.getAttribute('data-name'));

        if (e.target.getAttribute('data-name') == 'navigate') {
            this.navigateToCommPage();
        }
        if (e.target.getAttribute('data-name') == 'dropDownRequest') {
            this.toggleItem()
        }

    }

    navigateToCommPage() {
        console.log('inside');
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://nesponsolutions--hris.sandbox.my.site.com/NesponHRIS/s/employee-page'
            }
        });
    }

    @api itemTitle;
    @track itemExpanded = false;
    @track subItems = [];
    addSubItem(id, title) {
        // Create a new sub-item object
        const newSubItem = { id: id, title: title };

        // Push the new sub-item to the array
        this.subItems.push(newSubItem);
    }
    toggleItem() {
        this.itemExpanded = !this.itemExpanded;
    }
    handleItemClick(event) {
        //const itemId = event.target.dataset.itemId;
        // Perform operations based on the clicked item's ID
        console.log('Clicked item ID:', event.target.data);
    }

}