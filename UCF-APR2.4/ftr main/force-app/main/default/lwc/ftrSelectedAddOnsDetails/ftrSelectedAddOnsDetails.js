import { LightningElement,track, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
const columns = [
    { label: 'Products', fieldName: 'ChildProductName', type:'text',editable:true, cellAttributes: { style: { fieldName: 'disable' } } },
    { label: 'Quantity', fieldName: 'Quantity'},
    { label: 'Recurring Charge', fieldName: 'MRC', type:'currency', cellAttributes: { alignment: 'left' }}
];
export default class Test extends OmniscriptBaseMixin(LightningElement) {
    data = {};
    @track datatableData = [];
    columns = columns;
    connectedCallback() {
        console.log('Connected Callback.....');
        this.data = Object.assign([],this.omniJsonData);
        if(this.data['LWCProductNode'] instanceof Array){
            this.data['LWCProductNode'].forEach((currentItem,index) => {
                let subElement = [];
                if(currentItem['LWCChildProduct'] instanceof Array){
                    currentItem['LWCChildProduct'].forEach(subEle => {
                        subElement.push({
                            "ChildProductCode":subEle["ChildProductCode"],
                            "NRC":subEle["NRC"],
                            "MRC":(parseFloat(subEle["MRC"]) * parseFloat(subEle["Quantity"])), 
                                        "Quantity":subEle["Quantity"], 
                                        "ChildProductName":subEle["ChildProductName"],
                                        "disable":"pointer-events: none;" });
                    });
                }
                else{
                    subElement.push({
                        "ChildProductCode":currentItem['LWCChildProduct']["ChildProductCode"],
                        "NRC":currentItem['LWCChildProduct']["NRC"],
                        "MRC":(parseFloat(currentItem['LWCChildProduct']["MRC"]) * parseInt(currentItem['LWCChildProduct']["Quantity"])) ,  
                                        "Quantity":currentItem['LWCChildProduct']["Quantity"], 
                                        "ChildProductName":currentItem['LWCChildProduct']["ChildProductName"],
                                        "disable":"pointer-events: none;" });
                    //currentItem = currentItem['LWCChildProduct']["MRC"] // ?
                }
                
                let element = { "MainProductName" : currentItem['MainProductName'], 
                                "LWCChildProduct":subElement,
                                "LoopKey":index
                                };
                this.datatableData.push(element);
            });
        }
        else{
            let subElement = [];
            let index = 0
            if(this.data['LWCProductNode']['LWCChildProduct'] instanceof Array){
                this.data['LWCProductNode']['LWCChildProduct'].forEach(subEle => {
                    subElement.push({
                        "ChildProductCode":subEle["ChildProductCode"],
                            "NRC":subEle["NRC"],
                            "MRC":(parseFloat(subEle["MRC"]) * parseInt(subEle["Quantity"])), 
                                    "Quantity":subEle["Quantity"], 
                                    "ChildProductName":subEle["ChildProductName"],
                                    "disable":"pointer-events: none;" });
                });
            }
            else{
                subElement.push({
                    "ChildProductCode":this.data['LWCProductNode']['LWCChildProduct']["ChildProductCode"],
                            "NRC":this.data['LWCProductNode']['LWCChildProduct']["NRC"],
                            "MRC":(parseFloat(this.data['LWCProductNode']['LWCChildProduct']["MRC"]) * parseInt(this.data['LWCProductNode']['LWCChildProduct']["Quantity"])), 
                "Quantity":this.data['LWCProductNode']['LWCChildProduct']["Quantity"], 
                "ChildProductName":this.data['LWCProductNode']['LWCChildProduct']["ChildProductName"],
                "disable":"pointer-events: none;" });
            }
           
            let element = { "MainProductName" : this.data['LWCProductNode']['MainProductName'], 
                            "LWCChildProduct":subElement,
                            "LoopKey":index
                            };
            this.datatableData.push(element);
        }
        this.omniApplyCallResp({ 'LWCProductNode': this.datatableData});
        console.log(this.datatableData);
        console.log(JSON.stringify(this.datatableData));
    }
    
    
    
}