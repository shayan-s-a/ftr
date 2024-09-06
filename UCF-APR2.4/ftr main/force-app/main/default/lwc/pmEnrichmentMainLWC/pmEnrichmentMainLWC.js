import { LightningElement, api } from 'lwc';
import isTranslationUser from '@salesforce/apex/PmEnrichmentController.isNetworkTranslation'; 

export default class PmEnrichmentMainLWC extends LightningElement {
@api recordId;

@api isNetworkTranslation;
loadingcomplete = false;
recordChangeCount = 0;
isChangeTabModalOpen= false;
currentTargetTab = '';
connectedCallback() {
  this.isNetworkTranslationUser();
  
}
isNetworkTranslationUser(){
 
    isTranslationUser({OrderId:this.recordId})
    .then(result => {
       
        if (result) {
            this.isNetworkTranslation =result;
            this.loadingcomplete=true;
            
        }
        
    });
}
selectedTab = 'tab1'; // Default selected tab

    get isTab1Selected() {
        return this.selectedTab === 'tab1';
    }
    get isTab2Selected() {
        return this.selectedTab === 'tab2';
    }
      get isTab3Selected() {
        return this.selectedTab === 'tab3';
    }

  get isTab4Selected() {
        return this.selectedTab === 'tab4';
    }

  get isTab5Selected() {
        return this.selectedTab === 'tab5';
    }

  get isTab6Selected() {
        return this.selectedTab === 'tab6';
    }
    
  get isTab7Selected() {
        return this.selectedTab === 'tab7';
    }
    
  get isTab8Selected() {
        return this.selectedTab === 'tab8';
    }


    get tab1Class() {
        return this.isTab1Selected ? 'slds-button slds-button_neutral slds-is-active' : 'slds-button slds-button_neutral';
    }

    get tab2Class() {
        return this.isTab2Selected ? 'slds-button slds-button_neutral slds-is-active' : 'slds-button slds-button_neutral';
    }
      get tab3Class() {
        return this.isTab3Selected ? 'slds-button slds-button_neutral slds-is-active' : 'slds-button slds-button_neutral';
    }
      get tab4Class() {
        return this.isTab4Selected ? 'slds-button slds-button_neutral slds-is-active' : 'slds-button slds-button_neutral';
    }
      get tab5Class() {
        return this.isTab5Selected ? 'slds-button slds-button_neutral slds-is-active' : 'slds-button slds-button_neutral';
    }
      get tab6Class() {
        return this.isTab6Selected ? 'slds-button slds-button_neutral slds-is-active' : 'slds-button slds-button_neutral';
    }
      get tab7Class() {
        return this.isTab7Selected ? 'slds-button slds-button_neutral slds-is-active' : 'slds-button slds-button_neutral';
    }
      get tab8Class() {
        return this.isTab8Selected ? 'slds-button slds-button_neutral slds-is-active' : 'slds-button slds-button_neutral';
    }

    handleSelectTab(event) {
      this.currentTarget=event.currentTarget.dataset.name
      if (this.recordChangeCount>0) {
        this.isChangeTabModalOpen=true;
      }
      else{
        this.selectedTab = event.currentTarget.dataset.name;
      }
      //this.selectedTab = event.currentTarget.dataset.name;

    }

    handleRecordChange(event){
      console.log('handleRecordChange', event.detail.message);
      this.recordChangeCount=event.detail.message;
    }

    handleConfirm(){
      this.selectedTab = this.currentTarget;
      this.isChangeTabModalOpen=false;
      this.recordChangeCount=0;

    }
    handleCancel(){
      this.isChangeTabModalOpen=false;

    }

}