global with sharing class ftr_CreateContractNoTemplateWrp implements vlocity_cmt.VlocityOpenInterface2 {

    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
         
        if(methodName.equals('createContract')){
            
        String recId = (String)input.get('recordId');
        String contractId = vlocity_cmt.ContractServiceResource.createContractWithoutTemplate(recId);
        
        output.put('ContractId',contractId );
        
        }
        
        return true;
    }
}