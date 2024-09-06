/**
* @description webservice callout to finishedOrder interface
*/  
global without sharing class ftr_M6SubmitOrderSystemInterface extends ftr_M6BaseSystemInterface {

    global class ftr_M6finishedOrderException extends Exception {}

    ftr_PSRService.PSRServicePort port;
    ftr_PSRService.finishOrderRequestType request;
    
    global override String getOrchestrationTaskName() {
        System.debug('Task Name returned:'+TaskName_SubmitPSR);
        return TaskName_SubmitPSR;
    }

    /**
     * This method is called from executeItem to create M6 RequestType 
     *
     * @param  url  base URL for the batch
     * @param  path path for the batch
     * @param  input payload to be used to construct 
     * @return M6 RequestType object to be sent
     */
    global override Object createM6RequestType(String url, String path, Map<String, Object> input) {
        this.request = new ftr_PSRService.finishOrderRequestType();
        System.debug('input'+input);
        
        Map<String, Object> desby = new Map<String, Object>();
        List<Object> orderitem = new List<Object>();
        orderitem = (List<Object>)input.get('order_items');
        System.debug('orderitem'+orderitem);
        desby = (Map<String, Object>)orderitem[0];
        System.debug('desby'+desby);
        
        MAP<String, Object> techatt = new MAP<String, Object>();
        techatt = (Map<String, Object>)desby.get('described_by');
        System.debug('techatt'+techatt);
        
        List<Object> attrList = new List<Object>();
        attrList = (List<Object>)techatt.get('FTR_ENT_TECH_ATTCAT');
        System.debug('attrList'+attrList);
        
        for(Object attr : attrList){
        Map<String, Object> attr1 = (Map<String, Object>)attr;
        if((String)attr1.get('characteristic') == 'documentNumber') {
               
        if (String.valueOf(attr1.get('value'))!=null){
            this.request.documentNumber = Long.valueOf(String.valueOf(attr1.get('value')));
            System.debug('documentNumber-->'+ this.request.documentNumber);
        }
        
        //this.request.documentNumber = Long.valueOf(docnum);
        
        }}
        System.debug('finishOrderRequest request generated successfully');
        return (Object)this.request;
    }

    /**
     * This method is called from executeItem to create process response
     *
     * @param  url  base URL for the batch
     * @param  path path for the batch
     * @param  respType M6 ResponseType to process
     * @return         output object to be processed
     */
    global override Map<String, Object> processM6ResponseType(String url, String path, Object respType) {
        ftr_PSRService.finishOrderResponseValueType response = (ftr_PSRService.finishOrderResponseValueType)respType;
        Map<String,Object> respMap = new Map<String,Object>();
        system.debug('response: ' + response);
        system.debug('Code: ' + response.statusMessage.get(0).code);
        if(response.statusMessage.get(0).code != '0'){
            throw new ftr_M6finishedOrderException(response.statusMessage.get(0).message);
        }
        respMap.put('msg',String.valueOf(response.statusMessage.get(0).message));
        system.debug('msg'+respMap);
        return respMap;
        
    }
}