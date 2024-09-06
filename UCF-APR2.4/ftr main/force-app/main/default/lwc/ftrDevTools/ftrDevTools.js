import { LightningElement } from 'lwc';

export default class FtrDevTools extends LightningElement {

    handleTabClick(e) {
        const allTabs = this.template.querySelectorAll('.slds-vertical-tabs__nav-item');
        const allTabContents = this.template.querySelectorAll('.slds-vertical-tabs__content');
        const tabContent = this.template.querySelector('#'+e.currentTarget.children[0].id.replaceAll('__nav',''));
        allTabs.forEach( (elm, idx) =>{
            elm.classList.remove("slds-is-active")
        })
        allTabContents.forEach( (elm, idx) =>{
            elm.classList.remove("slds-show")
            elm.classList.add("slds-hide")
        })
        e.currentTarget.classList.add('slds-is-active');
        tabContent.classList.add("slds-show")
        tabContent.classList.remove("slds-hide")
    }

    handleTabFocus(e) {
        const allTabs = this.template.querySelectorAll('.slds-vertical-tabs__nav-item');
        allTabs.forEach( (elm, idx) =>{
            console.log(elm);
            elm.classList.remove("slds-has-focus")
        })
        e.currentTarget.classList.add('slds-has-focus')
    }
}