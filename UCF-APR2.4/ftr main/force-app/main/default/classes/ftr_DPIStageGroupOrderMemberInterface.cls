global without sharing class ftr_DPIStageGroupOrderMemberInterface extends ftr_DPIBaseSystemInterface {
   
    public ftr_DPIStageGroupOrderMemberInterface() {

    }

    global override String getOrchestrationTaskName() {
        System.debug('Task Name returned-->'+TaskName_StageGroupOrderMember);
        return TaskName_StageGroupOrderMember;
    }

/**
     * This method is called from executeItem to create DPI RequestType 
     *
     * @param  url  base URL for the batch
     * @param  path path for the batch
     * @param  input payload to be used to construct 
     * @return DPI RequestType object to be sent
     */
    global override Object createDPIRequestType(String url, String path, Map<String, Object> input) {
       
        System.debug('Stage order request type '+input);
            return (input);
}

    
    
   
}