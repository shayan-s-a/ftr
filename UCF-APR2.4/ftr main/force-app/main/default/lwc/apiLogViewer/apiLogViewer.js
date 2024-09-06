import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";

const escaped_one_to_xml_special_map = {
    "&amp;": "&",
    "&quot;": '"',
    "&lt;": "<",
    "&gt;": ">"
};

export default class ApiLogViewer extends LightningElement {
    @track activeSections = ["Response", "Log Details", "Error Details"];
    @track logDetails;
    @track errorDetails;
    @track hasError = false;
    @track isInitialized = false;
    @track log;
    @api orderId;
    @api
    get record() {
        return this.log;
    }
    set record(value) {
        this.log = value;
        if (this.isInitialized) 
            this.displayLog(value);
    }

    renderedCallback() {
        if (!this.isInitialized) {
            this.isInitialized = true;
            this.displayLog(this.log);
        }
    }

    displayLog(obj) {
        this.log = obj;
        this.hasError = obj.Status__c.toUpperCase() === 'SUCCESS' ? false : true;
        refreshApex(this.log);
        this.formatRequest();
        this.formatResponse();
        console.log(JSON.parse(JSON.stringify(this.log)));
        this.logDetails = [
            {
                label: 'Log',
                value: this.log.Name,
                apiName: 'Name',
                action: {
                    label: 'Open Log',
                    open: function() {
                        this.openRecord(this.log.Id)
                    }
                },
                colCSS: 'slds-col slds-p-right_small'
            },
            {
                label: 'System',
                value: this.log.System__c,
                apiName: 'System__c',
                colCSS: 'slds-col slds-p-right_small'
            },
            {
                label: 'Interface Name',
                value: this.log.Interface__c,
                apiName: 'Interface__c',
                colCSS: 'slds-col slds-p-right_small'
            },
            {
                label: 'Status',
                value: this.log.Status__c,
                apiName: 'Status__c',
                css: this.hasError ? 'slds-text-color_error' : 'slds-text-color_success',
                colCSS: 'slds-col slds-p-right_small'
            },
            {
                label: 'Order Number',
                value: this.log.OrderNumber__c,
                apiName: 'OrderNumber__c',
                colCSS: 'slds-col slds-p-right_small'
            },
            {
                label: 'Document Number',
                value: this.log.DocumentNumber__c,
                apiName: 'DocumentNumber__c',
                colCSS: 'slds-col slds-p-right_small'
            },
            {
                label: 'Orchestration Item',
                value: this.log.OrchestrationItemId__c,
                apiName: 'OrchestrationItemId__c',
                action: {
                    label: 'Open Orchestration Item',
                    open: function() {
                        this.openRecord(this.log.OrchestrationItemId__c)
                    }
                },
                colCSS: 'slds-col slds-p-right_small'
            },
            {
                label: 'Related ' + this.log.relatedToLabel,
                value: this.log.RelatedTo__c,
                apiName: 'RelatedTo__c',
                action: {
                    label: 'Open Related ' + this.log.relatedToLabel,
                    open: function() {
                        this.openRecord(this.log.RelatedTo__c)
                    }
                },
                colCSS: 'slds-col slds-p-right_small'
            }
        ];
        this.errorDetails = [
            {
                label: 'Code',
                value: this.log.ErrorCode__c,
                apiName: 'ErrorCode__c',
                colCSS: 'slds-col slds-size_1-of-12 slds-p-right_small'
            },
            {
                label: 'Message',
                value: this.log.ErrorMessage__c,
                apiName: 'ErrorMessage__c',
                colCSS: 'slds-col slds-p-right_small'
            }
        ];
    }

    formatRequest() {
        if (this.log.ConvertToXML__c) {
            this.template.querySelector(".request").textContent = this.prettyPrintXml(this.createXML(JSON.parse(this.decodeXml(this.log.Request__c))));
        } else {
            this.template.querySelector(".request").innerHTML = JSON.stringify(JSON.parse(this.log.Request__c), undefined, 2);
        }
    }

    formatResponse() {
        if (this.log.ConvertToXML__c) {
            this.template.querySelector(".response").textContent = this.prettyPrintXml(this.createXML(JSON.parse(this.decodeXml(this.log.Response__c))));
        } else {
            this.template.querySelector(".response").innerHTML = JSON.stringify(JSON.parse(this.log.Response__c), undefined, 2);
        }
    }

    copyRequest() {
        this.copyText('.request', 'Request has been copied');
    }

    copyResponse() {
        this.copyText('.response', 'Response has been copied');
    }

    copyText(selector, displayText) {
        const container = this.template.querySelector(selector);
        const range = document.createRange();
        range.selectNode(container);
        const selection = window.getSelection();
        selection.removeAllRanges();
        selection.addRange(range);
        const successful = document.execCommand('copy');
        this.showNotification({
            // title: 'Success',
            title: displayText,
            variant: 'info',
        });
    }

    createXML(obj) {
        var xml = "";
        for (var prop in obj) {
            xml += obj[prop] instanceof Array ? "" : "<" + prop + ">";
            if (obj[prop] instanceof Array) {
                for (var array in obj[prop]) {
                    xml += "<" + prop + ">";
                    xml += this.createXML(new Object(obj[prop][array]));
                    xml += "</" + prop + ">";
                }
            } else if (typeof obj[prop] == "object") {
                xml += this.createXML(new Object(obj[prop]));
            } else {
                xml += obj[prop];
            }
            xml += obj[prop] instanceof Array ? "" : "</" + prop + ">";
        }
        var xml = xml.replace(/<\/?[0-9]{1,}>/g, "");
        return xml;
    }

    decodeXml(string) {
        return string.replace(/(&quot;|&lt;|&gt;|&amp;)/g, function (str, item) {
            return escaped_one_to_xml_special_map[item];
        });
    }

    prettyPrintXml(xml) {
        var formatted = "";
        var reg = /(>)(<)(\/*)/g;
        xml = xml.replace(reg, "$1\r\n$2$3");
        var pad = 0;
        xml.split("\r\n").forEach((node) => {
            if (node.includes("_type_info")) return;
            var indent = 0;
            if (node.match(/.+<\/\w[^>]*>$/)) {
                indent = 0;
            } else if (node.match(/^<\/\w/)) {
                if (pad != 0) {
                    pad -= 1;
                }
            } else if (node.match(/^<\w[^>]*[^\/]>.*$/)) {
                indent = 1;
            } else {
                indent = 0;
            }

            var padding = "";
            for (var i = 0; i < pad; i++) {
                padding += "  ";
            }
            formatted += padding + node + "\r\n";
            pad += indent;
        });

        return formatted;
    }

    openRecord(contextId) {
        if (contextId)
            return window.open( '/' + contextId, '_blank'); 
        else {
            this.showNotification({
                title: 'Error',
                message: 'Undefined',
                variant: 'error',
            });
        }
    }

    openLog() {
        this.openRecord(this.log.Id);
    }

    openOrder() {
        this.openRecord(this.orderId);
    }

    openOrchestrationItem() {
        this.openRecord(this.log.OrchestrationItemId__c);
    }

    showNotification(obj) {
        const evt = new ShowToastEvent(obj);
        this.dispatchEvent(evt);
    }
}