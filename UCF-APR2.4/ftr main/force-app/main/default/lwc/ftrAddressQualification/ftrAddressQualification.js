import { track, api, LightningElement } from 'lwc';
import { log } from 'c/ftrUtils';
import tmpl from './ftrAddressQualification.html';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

const columns = [
    { label: 'Street Address', fieldName: 'AddressLine' },
    { label: 'City', fieldName: 'City' },
    { label: 'State', fieldName: 'State' },
    { label: 'Zip', fieldName: 'Zip' },
    { label: 'Environment', fieldName: 'Environment' }
];

export default class FtrAddressQualification extends OmniscriptBaseMixin(LightningElement) {
    @track selectedAddress;
    @track qualification;
    @track error;
    @track loading = false;
    @track qualificationMessage;

    currentlyQualifyingBy = 'Address';

    columns = columns;
    flagFrontierServedAddress = false;
    flagDifferentAddressQualified = false;

    connectedCallback() {
        // if (this.omniJsonData.OrphanServiceAccounts && this.omniJsonData.OrphanServiceAccounts.SelectedServiceAccount) {
        //     this.refreshQualification();
        // }
    }

    renderedCallback() {
        if (this.qualifyBy != this.currentlyQualifyingBy) {
            this.clearQualification();
        }
        this.checkValidity();
    }

    @api
    checkValidity() {
        return this.isQualified;
    }

    render() {
        return tmpl;
    }

    get showQualifyAnotherLocationBtn() {
        return this.qualification && !this.isQualified;
    }

    get isQualified() {
        return this.showQualificationResults 
        && this.qualification.InFootprint 
        && this.qualification.WireCenterCLLI != null 
        && this.qualification.WireCenterQoS != null 
        && this.qualification.WireCenterSpeed != null 
        && parseInt(this.qualification.WireCenterSpeed.replace(/\D/g,'')) > 0 
        && this.qualification.FiberTier != 'BDT' 
        && this.qualification.Products; 
        //&& this.qualification.HBEDetails.HBEMaxSpeed != null  Removed HBE field Validation by Arunkumar Vairam
        //&& this.qualification.HBEDetails.HBEMaxQoS != null 
        //&& this.qualification.HBEDetails.Products != null;
    }

    get showAddressList() {
        return this.addressList && this.qualifyBy == 'Address';
    }

    get showQualificationResults() {
        return this.addressInputsAreValid && this.qualification;
    }

    get latitude() {
        return this.omniJsonData.AddressQualification.Latitude;
    }

    get longitude() {
        return this.omniJsonData.AddressQualification.Longitude;
    }

    get dsatTicket() {
        return this.omniJsonData.AddressQualification.DSATTicket;
    }

    get qualifyBy() {
        if (this.omniJsonData.AddressQualification) {
            return this.omniJsonData.AddressQualification.QualifyBy;
        } else {
            return null;
        }
    }

    get addressIsValid() {
        return this.omniJsonData.AddressQualification
            && this.omniJsonData.AddressQualification["Address-Block"]
            && this.omniJsonData.AddressQualification["Address-Block"].StreetAddress
            && this.omniJsonData.AddressQualification["Address-Block"].City
            && this.omniJsonData.AddressQualification["Address-Block"].State
            && this.omniJsonData.AddressQualification["Address-Block"].Zip;
    }

    get latLongIsValid() {
        return this.omniJsonData.AddressQualification
            && this.longitude && this.longitude;
    }

    get dsatTicketIsValid() {
        return this.omniJsonData.AddressQualification
            && this.omniJsonData.AddressQualification.DSATTicket;
    }

    get addressInputsAreValid() {
        return this.addressIsValid || this.latLongIsValid || this.dsatTicketIsValid;
    }

    get validQualificationResultAddress() {
        return this.qualification 
        && this.qualification.QualifiedAddress 
        && this.qualification.QualifiedAddress.Address 
        && this.qualification.QualifiedAddress.City 
        && this.qualification.QualifiedAddress.State 
        && this.qualification.QualifiedAddress.ZipCode;
    }

    findAddresses() {
        this.omniValidate();
        if (!this.addressInputsAreValid) {
            // this.error = 'Please fill out all the required fields.';
            return;
        }
        this.clearQualification();
        if (this.qualifyBy != 'Address') {
            this.callDSATQualification();
            return;
        }
        const params = {
            input: {
                Address: this.omniJsonData.AddressQualification["Address-Block"].StreetAddress,
                City: this.omniJsonData.AddressQualification["Address-Block"].City,
                State: this.omniJsonData.AddressQualification["Address-Block"].State,
                Zip: this.omniJsonData.AddressQualification["Address-Block"].Zip
            },
            sClassName: `vlocity_cmt.IntegrationProcedureService`,
            sMethodName: 'DSAT_AddressQualification',
            options: '{}',
        };
        this.loading = true;
        log('AQ API request', params)
        this.omniRemoteCall(params, true).then(response => {
            log('AQ API response', response)
            if (response.result.IPResult.FindAddressesResponse)
                response = response.result.IPResult.FindAddressesResponse;

            // remove user entered address
            if (response.AssociatedAddresses) {
                let addresses = JSON.parse(JSON.stringify(response.AssociatedAddresses)).filter(addr => addr.Source != 1);
                addresses = addresses.sort((a, b) => b.Source - a.Source);

                // only show unique addresses
                let addressMap = {};
                addresses.forEach(record => {
                    let key = `${record.AddressLine}-${record.City}-${record.State}-${record.Zip}`.toLocaleLowerCase();
                    if (!addressMap.hasOwnProperty(key)) {
                        addressMap[key] = record;
                    }
                });
                addresses = Object.values(addressMap);

                // if there are any dpi addresses, have user select one
                if (addresses.filter(addr => addr.Source == 5).length > 0) {
                    for (let i = 0; i < addresses.length; i++) {
                        addresses[i].id = i;
                    }
                    this.addressList = addresses;
                    if (this.addressList.length > 1) {
                        setTimeout(() => {
                            const addressListDiv = this.template.querySelector('[data-id="addressList"]');
                            if (addressListDiv) addressListDiv.scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"});
                        }, 100);
                    } else {
                        this.selectedAddress = addresses[0];
                        this.callDSATQualification();
                    }
                    // log('addressList', this.addressList)
                    this.flagFrontierServedAddress = true;
                    this.loading = false;
                } else {
                    // if there are no dpi addresses, select the first one and qualify it
                    this.flagFrontierServedAddress = false
                    this.selectedAddress = addresses[0];
                    this.callDSATQualification();
                }

            } else {
                if (response.result.IPResults.error) {
                    this.error = response.result.IPResults.error;
                }
                this.loading = false;
            }

        }).catch(error => {
            this.error = error;
            log('AQ API error', error);
            this.loading = false;
        });
    }

    callDSATQualification() {
        this.error = null;
        this.qualification = null;
        const params = {
            input: this.generateRequest(),
            sClassName: `vlocity_cmt.IntegrationProcedureService`,
            sMethodName: 'Validation_DSAT',
            options: '{}',
        };
        this.loading = true;
        log('DSAT Qual request', params)
        this.omniRemoteCall(params, true).then(response => {
            log('DSAT Qual response', response)
            if (response.error && response.result.error) {
                this.error = response.result.error;
            } else if (response.result && response.result.IPResult) {
                response = response.result.IPResult;
                if (response.DSATAddressValidationSuccessResponse) {
                    if (response.DSATAddressValidationSuccessResponse.Products && response.DSATAddressValidationSuccessResponse.Products instanceof Array)
                        response.DSATAddressValidationSuccessResponse.Products = response.DSATAddressValidationSuccessResponse.Products.join(', ');
                    
                    // make sure the address is returned
                    if (response.DSATAddressValidationSuccessResponse.QualifiedAddress && response.DSATAddressValidationSuccessResponse.QualifiedAddress.Address && response.DSATAddressValidationSuccessResponse.QualifiedAddress.City && response.DSATAddressValidationSuccessResponse.QualifiedAddress.State && response.DSATAddressValidationSuccessResponse.QualifiedAddress.ZipCode) {
                        
                        response.DSATAddressValidationSuccessResponse.qualifiedBy = this.qualifyBy;
                        this.qualification = response.DSATAddressValidationSuccessResponse;
                        this.setQualificationMessage();
                    
                    } else {
                        this.error = 'Not found';
                    }

                } else if (response.result.errors && response.result.errors[0]) {
                    this.error = response.result.errors[0].detail;
                } else if (response.info && response.info.statusCode != 200) {
                    if (response.info.statusCode == 500) {
                        this.error = 'Unable to qualify.  Ensure the input fields are valid.';
                    } else {
                        this.error = response.info.status;
                    }
                } else if (response.result.message) {
                    this.error = response.result.message;
                } else if (response.result.error) {
                    this.error = response.result.error;
                } else if (response.error != 'OK') {
                    this.error = response.error;
                }
            // edge case
            } else if (response.result && response.result.result && response.result.result.body) {
                this.error = response.result.result.body.message;
            }
            this.omniUpdateDataJson(this.qualification, true);
            this.loading = false;
            setTimeout(() => {
                const qualificationDiv = this.template.querySelector('[data-id="qualification"]');
                if (qualificationDiv) qualificationDiv.scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"});
            }, 100);

            this.generateReportQuickQuote();
        }).catch(error => {
            this.error = error;
            log('DSAT Qual error', error);
            this.qualification = null;
            this.loading = false;
        });
    }

    get isBDT() {
        return this.showQualificationResults && this.qualification.FiberTier == 'BDT';
    }

    get isLEGACY() {
        return this.showQualificationResults && this.qualification.HBEDetails.isLegacy != 'No';
    }

    get isHBE() {
        return this.showQualificationResults && this.qualification.HBEDetails.isHBE != 'No';
    }

    setQualificationMessage() {
        if (!this.qualification) return;
        if (!this.qualification.InFootprint) {
            this.qualificationMessage = 'Address is not in Frontier\'s Footprint';
        } else if (this.isQualified) {
            this.qualificationMessage = 'Frontier Qualified Address';
        } else if (!this.qualification.Products) {
            this.qualificationMessage = 'No DIA at Wire Center';
        } else if (!this.isQualified) {
            this.qualificationMessage = 'Email this address and details to partner_support_team@ftr.com for Qualification/Quote Review';
        }
    }

    clearQualification() {
        this.qualification = null;
        this.error = null;
        this.addressList = null;
        this.currentlyQualifyingBy = this.qualifyBy;
        this.omniUpdateDataJson(this.qualification, true);
    }

    handleAddressSelection(event) {
        // const selectedRows = event.detail.selectedRows[0];
        this.selectedAddress = event.detail.selectedRows[0];
        this.callDSATQualification();
    }

    goNext() {
        if (!this.validQualificationResultAddress) {
            this.error = 'Address needs to be valid to proceed.';
        }
        if (this.isQualified && this.validQualificationResultAddress) {
            this.omniNextStep();
        }
    }

    generateRequest() {
        let req = {};
        if (this.qualifyBy == 'Address') {
            req = {
                AQRecordId: 0,
                Address: this.selectedAddress.AddressLine,
                City: this.selectedAddress.City,
                State: this.selectedAddress.State,
                ZipCode: this.selectedAddress.Zip
            };
        } else if (this.qualifyBy == 'Lat/Long') {
            req = {
                AQRecordId: 0,
                Latitude: this.latitude,
                Longitude: this.longitude
            };
        } else if (this.qualifyBy == 'DSAT Ticket #') {
            req = {
                AQRecordId: this.dsatTicket
            };
        }
        return req;
    }

    // refreshQualification() {
    //     let addressData = {
    //         AddressQualification: {
    //             "Address-Block": this.omniJsonData.OrphanServiceAccounts.SelectedServiceAccount
    //         }
    //     };
    //     this.omniApplyCallResp(addressData);
    //     this.callDSATQualification(this.omniJsonData.OrphanServiceAccounts.SelectedServiceAccount.DSATTicket);
    // }
    refreshPage() {
        this.clearQualification();
        // below line is not working in community portal
        // window.location.search += encodeURI('&prefill={"QualifyBy":"' + this.currentlyQualifyingBy + '"}');
        let addressData = {};
        if (this.qualifyBy == 'Address') {
            addressData = {
                AddressQualification: {
                    "Address-Block": {
                        Address: null,
                        StreetAddress: null,
                        City: null,
                        State: null,
                        Zip: null,
                    }
                }
            }
        } else if (this.qualifyBy == 'Lat/Long') {
            addressData = {
                AddressQualification: {
                    Latitude: null,
                    Longitude: null,
                }
            }
        } else if (this.qualifyBy == 'DSAT Ticket #') {
            addressData = {
                AddressQualification: {
                    DSATTicket: null
                }
            }
        }
        this.flagDifferentAddressQualified = true;
        this.omniApplyCallResp(addressData);
    }


    generateReportQuickQuote() {
        try {
            const params = {
                input: {
                    EventStep : "Qualify Location",
                    OmniScriptId : this.omniJsonData.SessionId,
                    UserName: this.omniJsonData.UserName,
                    UserLogin: this.omniJsonData.UserLogin,
                    MasterAgentId: this.omniJsonData.MasterAgentId,
                    SubAgentName: this.omniJsonData.SubAgent_Name,
                    QualifyBy : this.qualifyBy,
                    DSATTicketNumber : this.qualification.Id,
                    LatLong : this.qualification.QualifiedAddress.Latitude + ', ' + this.qualification.QualifiedAddress.Longitude,
                    StampServiceabilityResults : Date.now(),
                    FrontierServedAddress : this.flagFrontierServedAddress ? 'Yes' : 'No',
                    Qualificationstatus : this.qualificationMessage,
                    DifferentAddressQualified : this.flagDifferentAddressQualified ? 'Yes' : 'No',
                    Address : this.qualification.QualifiedAddress.Address,
                    City : this.qualification.QualifiedAddress.City,
                    State : this.qualification.QualifiedAddress.State,
                    Zip : this.qualification.QualifiedAddress.ZipCode,
                    WireCenter : this.qualification.WireCenterCLLI,
                    WireCenterQoS : this.qualification.WireCenterQoS,
                    FiberTier : this.qualification.FiberTier,
                    WireCenterMaxSpeed : this.qualification.WireCenterSpeed,
                    FiberDistance : this.qualification.FiberDistance,
                    LitOnnetAddress : this.qualification.LitBuilding,
                    HBEMaxSpeed : this.qualification.HBEDetails.HBEMaxSpeed,
                    HBEMaxQoS : this.qualification.HBEDetails.HBEMaxQoS,
                    Products : this.qualification.HBEDetails.Products
                },
                sClassName: 'vlocity_cmt.IntegrationProcedureService',
                sMethodName: 'CPQ_CreateQuickQuoteReport',
                options: '{}',
            };
    
            this.omniApplyCallResp({
                LatLong: this.qualification.QualifiedAddress.Latitude + ', ' + this.qualification.QualifiedAddress.Longitude,
                Qualificationstatus: this.qualificationMessage,
                QualifyBy: this.qualifyBy,
                DSATTicketNumber: this.qualification.Id,
                LitOnnetAddress: this.qualification.LitBuilding,
                FrontierServedAddress: this.flagFrontierServedAddress ? 'Yes' : 'No'
            });
            log('Report Quick Quote send data ', params);
            this.omniRemoteCall(params, true).then(response => {
                log(response);
            }).catch(error => {
                this.error = error;
                log('Report Quick Quote error', error);
            });
            
        } catch (error) {
            this.error = error;
            log('Generate Report Quick Quote error', error);
        }

    }
}