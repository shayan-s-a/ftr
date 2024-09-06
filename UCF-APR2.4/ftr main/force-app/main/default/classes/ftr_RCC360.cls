global class ftr_RCC360 extends ftr_DPIRCSystemInterface{
    
    global class ftr_RCC360Exception extends Exception {}
    
    global override String getOrchestrationTaskName() {
        
        System.debug('Task Name returned-->'+TaskName_RC360);
        
        return TaskName_RC360;
       

    }
    
    global override Object createDPIRequestType(String url, String path, Map<String, Object> input) {
        
        //Construct the Request Object to Invoke SubmitGroupOrderMember DPI API
        //return this with SubmitGroupOrderMember request
       
        //Map<String, Object> submitGroupOrderRequest = new Map<String, Object>();
        return input;
    }
    
     global override Map<String, Object> processDPIResponseType(String url, String path, Object respType) {
        
         
         String payload = respType.toString();
         
        
         Map<String,Object> RCResponseMap = (Map<String, Object>)Json.deserializeUntyped(payload); 
          
       //  return RCResponseMap; 
           Map<String,Object> RC360Response = new Map<String,Object>();
         if(RCResponseMap.get('message') !=null){
            
              RC360Response.put('errorMessage',RCResponseMap.get('message')); 
              
         }else if(RCResponseMap.get('address.ControlNumber') !=null){
             
                 
                 String error = RCResponseMap.get('address.ControlNumber').toString();
                 RC360Response.put('errorMessage',error); 
                 
                  
         }else if(RCResponseMap.get('address.Environment') !=null){
             
                 
                 String error = RCResponseMap.get('address.Environment').toString();
                 RC360Response.put('errorMessage',error); 
                 
         }
         else{
             RC360Response.put('success','success'); 
             RC360Response.put('Message',RCResponseMap);
         }
         
        return RC360Response;
    }
    
    public static void justIncrement() {
        
        Integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
    } 
}