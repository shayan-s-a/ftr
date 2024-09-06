public class CallVoipQualificationIP {
    
    public static Map<String, Object> QualifyVoip(string npa , string nxx, string integrationProcedure)
    {
        /* Initialize variables */
        String procedureName = 'DSAT_VOIPQualification';
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        
        /* Populating input map for an Integration Procedure. 
        Follow whatever structure your VIP expects */
        //string npa = '281';
        //string nxx = '427';    
        ipInput.put('npa', npa);
        ipInput.put('nxx', nxx);
        /* Call the IP via runIntegrationService, 
        and save the output to ipOutput */
        return ipOutput = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
        
        
    }
   
}