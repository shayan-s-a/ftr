import { track, api, LightningElement } from 'lwc';
import { log } from 'c/ftrUtils';
import tmpl from './ftrCreateQQQuoteQLILoader.html';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { getNamespaceDotNotation } from "vlocity_cmt/omniscriptInternalUtils";
import { OmniscriptActionCommonUtil } from "vlocity_cmt/omniscriptActionUtils";



export default class ftrCreateQQQuoteQLILoader extends OmniscriptBaseMixin(LightningElement) {
    
    IpResponse;
    isSuccess;
    _actionUtil;
    @track loading = true;
    @track currentPercent = 0;
    @track processingQuote = 1;
    @track totalQuotes;
    @track hasRouter = false;
    @track MDIAIndex = 0;
    _ns = getNamespaceDotNotation();
    @api input;
    
    connectedCallback() {
        
        this._actionUtil = new OmniscriptActionCommonUtil();
        this.generateQuoteQlis();
    }
    
    async generateQuoteQlis() {
        
        //this.loading = true;
        var LWCdata = this.omniJsonData;
        var productList = this.omniJsonData.SelectedProducts;
        this.totalQuotes = productList.length;
       
        for (let index = 0; index < productList.length; index++) {
            
            await this.callIPCreateQuoteQLI(LWCdata, productList[index]);
            
            if (this.processingQuote < this.totalQuotes) {
                this.processingQuote ++;                
                this.currentPercent = Math.round((this.processingQuote-1)/this.totalQuotes* 100);
            }else if(this.processingQuote == this.totalQuotes){
                this.currentPercent = Math.round((this.processingQuote)/this.totalQuotes* 100);
            }

        }
        this.loading = false;

        if (!this.loading){
            this.goNext();
        }
    }

    async callIPCreateQuoteQLI(allData, product){
        try {
            //this.hasRouter = allData.ProductAddOn.SelectManagedRouter == 'Yes'? true: false;
            
            //const options = this.hasRouter ?  JSON.stringify({useQueueableApexRemoting: true }) : '{}' ;
            const options =   JSON.stringify({useQueueableApexRemoting: true })  ;
            if(product.PricebookEntry.Product2.ProductCode == 'ENT_ETH_EIA_003'){
                this.addOns = allData.LWCProductNode[this.MDIAIndex];
                this.MDIAIndex++;
            }
            
            const params = {
                input: {
                    OpportunityId: allData.OpportunityId,
                    QuoteCreation: allData.QuoteCreation,
                    ProductAddOn: allData.ProductAddOn,                    
                    ProductIndexToSync: allData.ProductIndexToSync,
                    ServiceAccountId: allData.UpdatedServiceAccountId,
                    product: product,
                    LWCProductNode:this.addOns
                  },
                sClassName: 'vlocity_cmt.IntegrationProcedureService',
                sMethodName: 'CPQ_Create_QQPartnerPortalQuoteQli',
                options: options,
            };
            

            log('hasRouter ', this.hasRouter);
           
            log('Create quote & QLI input data ', params);
            log('Create quote & QLI proccess call ', 'log');
            const response = await this.omniRemoteCall(params, true)
            log('response', response);
            if(product.PricebookEntry.Product2.ProductCode == 'ENT_ETH_EIA_003' && allData.isAddOnSelected == true){
                for(let addOnIndex = 0 ; addOnIndex < this.addOns["LWCChildProduct"].length; addOnIndex++){
                    const addOnsParams = {
                        input: {
                            OpportunityId: allData.OpportunityId,
                            QuoteId: response["result"]["IPResult"]["response"]["QuoteId"],                  
                            ProductIndexToSync: allData.ProductIndexToSync,
                            ServiceAccountId: allData.UpdatedServiceAccountId,
                            product: product,
                            LWCChildProduct:this.addOns["LWCChildProduct"][addOnIndex]
                        },
                        sClassName: 'vlocity_cmt.IntegrationProcedureService',
                        sMethodName: 'QLI_CreateQLIForAddOnsProduct',
                        options: options,
                    };

                    console.log('responce ---'+response["result"]["IPResult"]["response"]["QuoteId"])        
                    log('Create addOnsParams input data ', addOnsParams);
                    log('Create addOnsParams proccess call ', 'log');
                    const responseAddOns = await this.omniRemoteCall(addOnsParams, true);
                    log('responseAddOns ', responseAddOns);
                }
        }


        const paramsUNI = {
            input: {
                OpportunityId: allData.OpportunityId,
                QuoteId: response["result"]["IPResult"]["response"]["QuoteId"], 
                ProductAddOn: allData.ProductAddOn,                    
                ProductIndexToSync: allData.ProductIndexToSync,
                ServiceAccountId: allData.UpdatedServiceAccountId,
                product: product,
                LWCProductNode:this.addOns
              },
            sClassName: 'vlocity_cmt.IntegrationProcedureService',
            sMethodName: 'Quote_AddUNIProduct',
            options: options,
        };
        

        //log('hasRouter ', this.hasRouter);
       
        log('CreateQuote_AddUNIProduct data ', paramsUNI);
        log('Create Quote_AddUNIProduct call ', 'log');
        const responseUNI = await this.omniRemoteCall(paramsUNI, true)
        log('responseUNI  ', responseUNI);
        
        
            
        } catch (error) {
           log('Create quote & QLI IP error', error);
        }
    }

    goNext() {       
        this.omniNextStep();
       
    }

    render() {
        return tmpl;
    }

}