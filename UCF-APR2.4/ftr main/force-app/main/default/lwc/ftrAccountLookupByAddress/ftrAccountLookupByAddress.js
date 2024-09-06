import { LightningElement, api, track, wire } from 'lwc';
import tmpl from './ftrAccountLookupByAddress.html';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { OmniscriptActionCommonUtil } from 'vlocity_cmt/omniscriptActionUtils';


const columns = [
    { label: 'Account Name', fieldName: 'name' },
    { label: 'Service Street', fieldName: 'servicestreet' },
    { label: 'Service City', fieldName: 'servicecity' },
    { label: 'Service State', fieldName: 'servicestate' },
    { label: 'Service Code zip', fieldName: 'servicezippostalcode' },
    
];

const DELAY = 300;
export default class ftrAccountLookupByAddress extends NavigationMixin(OmniscriptBaseMixin(LightningElement)) {
    
    columns = columns;
    @api objName = 'Account';
    @api labelName;    
    @api readOnly = false;
    @api required;    
    @api placeholder = 'Search';   
    @track searchKey;
    @track error;
    @track isSelected = false;
    @track selectedRows;
    @track notInList = false;
    @api respCompany;
    @api accountList = [];
    @track selectedAccount;
    @track showAccountList =false;
    inputClass = 'slds-input';     

    isLoading = false;    

    render() {
        return tmpl;
    } 
    
    renderedCallback() {
        super.renderedCallback && super.renderedCallback()    
    }

    connectedCallback() {     
         try {
            this._actionUtilClass = new OmniscriptActionCommonUtil();
           this.handleInputChange('_');
        } catch (error) {
            console.error('Error:', error);
        }
        
    }        

    // handle SearchInput and call integration procedure to retrive account data
    handleInputChange(event) {
        this.selectedAccount = undefined;
        this.isSelected = false;
        this.accountList = undefined;
        this.searchKey = event == '_' || event.target.value =='' ? '_': event.target.value;
        this.isLoading = true;

        let myData = {
            "ftrPartnerAllowedToCreateAccount": false
        }
        this.omniApplyCallResp(myData);

        if(this.searchKey.length > 0){
            this.showAccountList = true;
            const params = {
                input: {
                    "idAccount": this.searchKey,
                    "ServiceCity": this.omniJsonData.AddressQualification.AddressQualificationResult.QualifiedAddress.City,
                    "ServicePostalCode": this.omniJsonData.AddressQualification.AddressQualificationResult.QualifiedAddress.ZipCode,
                    "ServiceState": this.omniJsonData.AddressQualification.AddressQualificationResult.QualifiedAddress.State,
                    "ServiceStreet": this.omniJsonData.AddressQualification.AddressQualificationResult.QualifiedAddress.Address,
                  },
                sClassName: 'vlocity_cmt.IntegrationProcedureService',
                sMethodName: 'CPQ_CompanyLookupIntegracionProcedure',
                options: '{}',
            };
           
            //console.log('params To lookUpAccount', params);
            this._actionUtilClass
            .executeAction(params, null, this, null, null)
            .then(resp => {
                //console.log("resp CompanyLookup", resp);
                this.respCompany = resp.result.IPResult.accountInfo;
                console.log('Accounts Info: ', this.respCompany);
                
                resp = resp;
                
                // set data on datatable
                this.accountList = resp.result.IPResult.accountInfo;
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                window.console.log(error);
            });
        }else{
            this.showAccountList = false;
            this.selectedAccount = undefined;
            this.isSelected = false;
            this.isLoading = false;
        }
        

    }

    //when a record is selected update data
    handleCompanySelection(event) {
        this.selectedAccount = event.detail.selectedRows[0];
        this.selectedRows = event.detail.selectedRows;
        this.omniUpdateDataJson(this.selectedAccount);
        if (this.selectedRows && this.selectedRows.length > 0 && this.isSelected != true) {
            this.isSelected = true;
        }
        
    } 

    createCase(event) {
        if (event) {
            let myData = {
                "ftrPartnerAllowedToCreateAccount": true,
                "NewAccountName": this.searchKey == '_' ? '' : this.searchKey
            }
            this.omniApplyCallResp(myData);
            this.omniNextStep();
        }
    }

    /*
    createCase() {      
        console.log( this.searchKey);
        
        const params = {
            input: {
                objectName: 'Case',
                recordTypeName: 'Account Creation'
            },
            sClassName: 'CustomOmniscriptHelper',
            sMethodName: 'getRecordTypeId',
            options: '{}',
        };
        this.omniRemoteCall(params, true).then(response => {
            let stringResult = JSON.stringify(response);
            let result = JSON.parse(stringResult).result;
            const defaultValues = encodeDefaultFieldValues({
                Create_Account_Name__c: this.searchKey,
                Street_Address__c: this.omniJsonData.AddressQualification.AddressQualificationResult.QualifiedAddress.Address,
                City__c: this.omniJsonData.AddressQualification.AddressQualificationResult.QualifiedAddress.City,
                CAP_State__c: this.omniJsonData.AddressQualification.AddressQualificationResult.QualifiedAddress.State,
                Zip_Code__c: this.omniJsonData.AddressQualification.AddressQualificationResult.QualifiedAddress.ZipCode.substring(0, 5)
            });

            console.log(defaultValues)

            this[NavigationMixin.GenerateUrl]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Case',
                    actionName: 'new'
                },
                state: {
                    defaultFieldValues: defaultValues,
                    recordTypeId: result.recordTypeId
                }
            }).then(url => {
                window.open(url, "_blank");
            });;
        }).catch(error => {
            this.error = error.message ? error.message : error;
            console.error('Error:', error);
        });
    }
    */

    //Next Button
    goNext() {        
        if (this.isSelected) {
            this.omniNextStep();
        }
    }
    //Previous Button
    goBack() {      
        this.omniPrevStep();       
    }

    // Account is not in list checkbox hanndlers

    @track value = [];

    get accountCheck() {
        return [
            { label: 'Don\'t Find Account', value: 'notInList' }
        ];
    }

    handleIsNotOnList(e) {
        console.log("evento ---> "+ e),
        this.value = e.detail.value;
        
        this.value == 'notInList' ? this.notInList = true: this.notInList = false;
    }
}