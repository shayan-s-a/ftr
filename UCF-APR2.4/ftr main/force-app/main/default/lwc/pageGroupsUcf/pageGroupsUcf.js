import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import loadComponent from '@salesforce/apex/PageGroupsController.loadData';
import deletePageGroup from '@salesforce/apex/PageGroupsController.deletePageGroup';
import updateRecords from '@salesforce/apex/PageGroupsController.updateRecords';
import GetDidNumbers from '@salesforce/apex/PageGroupsController.GetDidNumbers';
import createPageGroup from '@salesforce/apex/PageGroupsController.createPageGroup';

export default class PageGroupsUcf extends LightningElement {
   @track result = {};
   @track isHandle = false;
   sortDirection = 'asc';
   showLoader = false;
   showLoaderModal = false;
   showContent = false;
   @api recordId;
   groupName = '';
   tempDIDIds = [];
   @track ftrPageGroup;
   @track ftrDIDNumberDetails;
   error;
   @track rowIndex;
   value = '';
   @track members = [];
   @track membername = '';
   @track GetDidNumbers;
   @track tempDIDIds = [];
   @track selectedAccount = null;
   @track showDualListboxModal = false;
   @track selectedItems = [];
   @track selectedItemsCount = 0;
   @track length = 0;
   @track selectedOption = '';
   @track isEditMode = false;
   @track testArray = [];
   isModalOpen = false;
   @track defaultitems = [];
   @api isnetworktranslation=false;
   @track defaultOptions = [];
   fieldChangeCount=0;
   connectedCallback() {
      this.loadComponent(this.recordId, true);
   }

   handleDidNumberIds() {
      this.showLoaderModal = true;
      GetDidNumbers({
            pagegroupId: this.selectedAccount.Id
         })
         .then((result) => {
            this.GetDidNumbers = result;
            console.log('inside GetDidNumbers', this.GetDidNumbers);
            this.tempDIDIds = [];
            this.GetDidNumbers.forEach(didNumber => {
               this.tempDIDIds.push(didNumber.DID_Number_Details__c);
               console.log('temppppp'+this.tempDIDIds);
            })
            console.log('inside tempids', JSON.stringify(this.tempDIDIds));
            this.tempNumber = this.GetDidNumbers.length;
            console.log('tempNumber'+this.tempNumber);
            this.length= this.tempNumber;
            console.log('length2'+this.length2);
            this.showLoaderModal = false;
         })
         .catch((error) => {
            this.showToast('Error!', error, 'error', 'sticky');
            this.GetDidNumbers = undefined;
         });
   }

   @api
   loadComponent(recordId, parm) {
      this.showLoader = true;
      loadComponent({
         'recordId': recordId
      }).then(result => {
         if(parm){
            this.showContent = result ? true : false;
            if(!this.showContent)
               return this.showLoader = false;
         }
         this.result = result;
         // Loop through the records and extract the number from MLHG_Name__c
         this.ftrPageGroup = result.pageGroupsList.map(Page_Group__c => {
            const selectedItemsCount = parseInt((Page_Group__c.Members__c || '').match(/\d+/), 10) || 0;
            return {
               ...Page_Group__c,
               editMode: true,
               selectedItems: [],
               selectedItemsCount: selectedItemsCount, // Extracted number
            };
         });
      

         this.members = result.ftrDIDNumberDetailList.map(option => ({
            label: `${option.Ucf_User_Name__c} - ${option.DIDNumber__c}`,
            value: option.Id
        })).sort((a, b) => {
            // Compare function for sorting by label
            return a.label.localeCompare(b.label);
        });
         
         
        
      
         //this.sortByName();
         
      });
     this.showLoader = false;
   }

   handleDelete(event) {
      this.showLoader = true;
      var recordToDeleteId = event.target.dataset.id;
      console.log('record to be deleted id: ' + recordToDeleteId);
      deletePageGroup({
         'recordId': recordToDeleteId
      }).then(result => {
         this.loadComponent(this.recordId, false);
         this.showLoader = false;
         this.showToast('Success', 'Record Deleted Successfully', 'success');
      }).catch(error => {
         this.showToast('Error!', error, 'error', 'sticky');
         console.log('error..!', error);
      });
   }

   showToast(t, m, v) {
      this.dispatchEvent(new ShowToastEvent({
         title: t,
         message: m,
         variant: v,
      }));
   }

   openDualListbox(event) {
      this.isModalOpen = true;
      this.isEditMode = !this.isEditMode;
      this.rowIndex = event.target.getAttribute('data-row-index');
      console.log('rowIndex', this.rowIndex);
      if (this.rowIndex >= 0 && this.rowIndex < this.ftrPageGroup.length) {
         this.selectedAccount = this.ftrPageGroup[this.rowIndex]; // Store the account being edited
         console.log('selectedAccount', JSON.stringify(this.selectedAccount.Id));
      }

      this.handleDidNumberIds();
   }

   closeDualListbox() {
      this.isModalOpen = false;
   }

   saveDualListbox() {
      
      this.showDualListboxModal = false;
      this.selectedAccount.selectedItemsCount = this.length;
      //this.membername = this.length + ' Members';
      this.membername = this.length > 0 ? `${this.length} Members` : 'No Members';

      console.log('membername', this.membername);
      const recordToUpdate = [{
         Id: this.selectedAccount.Id,
         Members__c: this.membername
      }];
      const recordsToinsert = [];

      //this.defaultOptions = this.selectedItems;
      this.selectedItems.forEach(selectedId => {

         recordsToinsert.push({
            DID_Number_Details__c: selectedId,
            Page_Groups__c: this.selectedAccount.Id,
         });
      });

      


      console.log('recordddd', JSON.stringify(this.recordsToinsert));
      let flagDataSave= false;
      this.showLoaderModal = true;
      updateRecords({
         pageGroupRecordToUpdate: recordToUpdate[0],
         gmRecordsList: recordsToinsert,
         ishandle : this.isHandle

      }).then(result => {
         this.loadComponent(this.recordId, false);
         this.showToast('Success', 'Updates Successfully', 'success');
         this.showLoaderModal = false;
         this.isModalOpen = false;
         flagDataSave = true;

      }).catch(error => {
         this.showLoaderModal = false;
         if(flagDataSave===false){
            this.showToast('Error', error.body.message, 'error');}
         

      });
   }

   handleChangeDualListboxModal(event) {
      this.isHandle= true ;
      this.selectedItems = event.detail.value;
      this.length = this.selectedItems.length;
      //const rowIndex = event.target.getAttribute('data-row-index');
      console.log('row', this.rowIndex);
      console.log('length', this.length);
      console.log('selectedItems', this.selectedItems[this.rowIndex]);
      this.testArray.push(this.selectedItems);
      console.log('testarray', this.testArray);
   }

   handleGroupCreate() {
      if (!this.groupName) {
         return this.showToast('Error', 'Group name cannot be empty!', 'error');
      }

      const getGroup = this.groupName.trim().toLowerCase(); 
        if (this.ftrPageGroup.some(group => group.Name.toLowerCase() === getGroup)) {
            this.showToast('Error', 'This Group name already exists.', 'error');
            return;
        }


      this.showLoader = true;
      createPageGroup({
         'groupName': this.groupName,
         'orderId': this.recordId
      }).then(result => {
         this.groupName = '';
         this.loadComponent(this.recordId, false);
         this.showToast('Success', 'Record Created Successfully', 'success');
         this.showLoader = false;
         this.fieldChangeCount=0;
         this.notifyInputChange(this.fieldChangeCount);
      }).catch(error => {
         this.showLoader = false;
         this.showToast('Error', error, 'error');
      });
   }

   handleGroupNameChange(event) {
      this.groupName = event.target.value;
      this.fieldChangeCount++;
      this.notifyInputChange(this.fieldChangeCount);
   }

   sortByName() {
      this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
      const reverse = this.sortDirection === 'desc' ? -1 : 1;
      const field = 'Name';
      this.ftrPageGroup = [...this.ftrPageGroup.sort((a, b) => (a[field] > b[field] ? 1 : -1) * reverse)];
  }
  notifyInputChange(count){
   this.dispatchEvent(new CustomEvent('recordchange', {
       detail: {
           component: 'pageGroupUcf',
           message: count
       }
   }));
}

}