/* eslint-disable no-console */
/* eslint-disable no-alert */
import { LightningElement,api, track, wire } from 'lwc';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import AGREEMENT_FIELD from '@salesforce/schema/Contract.Agreement_Type__c';
import CONTRACTID_FIELD from '@salesforce/schema/Contract.Id';
import COMPANYSIGNED_FIELD from '@salesforce/schema/Contract.CompanySignedId';
import CUSTOMERSIGNED_FIELD from '@salesforce/schema/Contract.CustomerSignedId';
import CONTRACTFOLDER_FIELD from '@salesforce/schema/Contract.Spring_Contract_Folder_Name__c';
import ACCOUNTCHANNEL_FIELD from '@salesforce/schema/Contract.Account_Channel__c';
import RECORDTYPE_FIELD from '@salesforce/schema/Contract.RecordType.Name';
import SPRINGFOLDER_FIELD from '@salesforce/schema/Contract.Spring_Folder_Name__c';
import DOCUMENTSTATUS_FIELD from '@salesforce/schema/Contract.Document_Status__c';
import SCHEDULETYPE_FIELD from '@salesforce/schema/Contract.Schedule_Type__c';
import PPI_FIELD from '@salesforce/schema/Contract.PPI__c';
import getprofilenm from '@salesforce/apex/GetDetails.getProfileName';
const fields = [AGREEMENT_FIELD,DOCUMENTSTATUS_FIELD,CUSTOMERSIGNED_FIELD,COMPANYSIGNED_FIELD,CONTRACTID_FIELD,CONTRACTFOLDER_FIELD,ACCOUNTCHANNEL_FIELD,RECORDTYPE_FIELD,SPRINGFOLDER_FIELD,SCHEDULETYPE_FIELD,PPI_FIELD];
export default class generateDocument extends LightningElement {
    @track disabled = false;
    @track error;
    
    @api recordId;
    @track profilenm;
    @track profilenm;


    @wire(getRecord, { recordId: '$recordId', fields })
    contract;
    get agreement() {
        return getFieldValue(this.contract.data, AGREEMENT_FIELD);
    }
    get custsigned() {
        return getFieldValue(this.contract.data, CUSTOMERSIGNED_FIELD);
    }
    get companysigned() {
        return getFieldValue(this.contract.data, COMPANYSIGNED_FIELD);
    }
    get contrid() {
        return getFieldValue(this.contract.data, CONTRACTID_FIELD);
    }
    get contractfolder() {
        return getFieldValue(this.contract.data, CONTRACTFOLDER_FIELD);
    }
    get accountchannel() {
        return getFieldValue(this.contract.data, ACCOUNTCHANNEL_FIELD);
    }
    get springfolder() {
        return getFieldValue(this.contract.data, SPRINGFOLDER_FIELD);
    }
    get scheduletype() {
        return getFieldValue(this.contract.data, SCHEDULETYPE_FIELD);
    }
    get docstatus() {
        return getFieldValue(this.contract.data, DOCUMENTSTATUS_FIELD);
    }
    get recordtype() {
        return getFieldValue(this.contract.data, RECORDTYPE_FIELD);
    }
    get ppi() {
        return getFieldValue(this.contract.data, PPI_FIELD);
    }

    
    sendForCollectionsScreening() {

        getprofilenm().then(result=>{
            this.profilenm=result;
            this.newmet();

        })
        .catch(error => {
            this.error=error;
        })

    }

   newmet(){
      
    if(this.companysigned === null && (this.profilenm !== '#CTF Small Business User' || this.custsigned === null)){ 
        alert("Please populate Signatatory fields and try again"); 
    }else if(this.ppi === null && ((this.agreement === 'Ethernet/Data Services' && this.scheduletype === 'DIA Schedule_02012021') || (this.agreement === 'Ethernet/Data Services' && this.scheduletype === 'E-LINE') || (this.agreement === 'Ethernet/Data Services' && this.scheduletype === 'Managed Network Services') || (this.agreement === 'Current Broadband Offers' && this.scheduletype === 'Fiber First Offer ENTERPRISE ONLY') || (this.agreement === 'VoIP' && this.scheduletype === 'SIP Trunking') || (this.agreement === 'VoIP' && this.scheduletype === 'UCF - UCaaS')|| (this.agreement === 'VoIP' && this.scheduletype === 'UCF - CCaaS')|| (this.agreement === 'Ethernet/Data Services' && this.scheduletype === 'MNS - EReach')|| (this.agreement === 'VoIP' && this.scheduletype === 'Ring Central')|| (this.agreement === 'VoIP' && this.scheduletype === 'Frontier Calling Cloud Phone')|| (this.agreement === 'Ethernet/Data Services' && this.scheduletype === 'E-LAN')|| (this.agreement === 'Ethernet/Data Services' && this.scheduletype === 'Optical Transport'))){ 
        alert("PPI choice must be selected");  
    }else if(this.docstatus === 'Completed'){ 
         alert("This Contract has been signed. Unable to replace document."); 
        }else if(this.profilenm === '#CTF Small Business User' && this.recordtype ==='Frontier Services Agreement'){ 
            window.open(`https://na11.springcm.com/atlas/doclauncher/eos/CC-${this.agreement}?aid=17662&eos[0].Id=${this.contrid}&eos[0].Id=${this.contrid}&eos[0].System=Salesforce&eos[0].Type=Contract&eos[0].Name=${this.contractfolder}&eos[0].ScmPath=/Salesforce/Accounts/${this.accountchannel}/${this.springfolder}`); 
        }else if(this.profilenm !== '#CTF Small Business User' && this.recordtype ==='Frontier Services Agreement'){ 
            window.open(`https://na11.springcm.com/atlas/doclauncher/eos/${this.agreement}?aid=17662&eos[0].Id=${this.contrid}&eos[0].Id=${this.contrid}&eos[0].System=Salesforce&eos[0].Type=Contract&eos[0].Name=${this.contractfolder}&eos[0].ScmPath=/Salesforce/Accounts/${this.accountchannel}/${this.springfolder}`); 
        }else if(this.profilenm === '#CTF Small Business User'){ 
            window.open(`https://na11.springcm.com/atlas/doclauncher/eos/CC-${this.scheduletype}?aid=17662&eos[0].Id=${this.contrid}&eos[0].System=Salesforce&eos[0].Type=Contract&eos[0].Name=${this.contractfolder}&eos[0].ScmPath=/Salesforce/Accounts/${this.accountchannel}/${this.springfolder}`); 
        }else { 
            window.open(`https://na11.springcm.com/atlas/doclauncher/eos/${this.scheduletype}?aid=17662&eos[0].Id=${this.contrid}&eos[0].System=Salesforce&eos[0].Type=Contract&eos[0].Name=${this.contractfolder}&eos[0].ScmPath=/Salesforce/Accounts/${this.accountchannel}/${this.springfolder}`); 
        }
        }
        }