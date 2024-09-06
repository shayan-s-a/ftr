@isTest
private class ELANConfigSERuleServiceTest {

    // Test method for Saveelandata
    @isTest
    static void ELANConfigSERules() {
        // Create test data
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        // Populate inputMap, outputMap, and options with appropriate data
        Map<String, Object> elanConfigurationStep = new Map<String, Object>{
            'ELANProductsBlock' => new List<Object>{
                new Map<String, Object>{
					'ExistingCheckBox'=>false,
					'ClassOfService'=> 'Gold',
				'OEMIdHBE'=> 'SLA HUB 1',				
				'ELANNetworkType'=> 'HBE',				
				'ELANNetwork'=> 1,				
				'FinalELANNetwork'=> 1 },
                new Map<String, Object>{
					'ExistingCheckBox'=>false,
					'ClassOfService'=> 'Silver',
				'OEMIdHBE'=> 'SLA HUB 2',				
				'ELANNetworkType'=> 'HBE',				
				'ELANNetwork'=> 2,				
				'FinalELANNetwork'=> 2},
                new Map<String, Object>{
					'ExistingCheckBox'=>false,
					'ClassOfService'=> 'Gold',
				'OEMIdHBE'=> 'SLA HUB 2',				
				'ELANNetworkType'=> 'HBE',				
				'ELANNetwork'=> 2,				
				'FinalELANNetwork'=> 2 },
				new Map<String, Object>{
					'ExistingCheckBox'=>false,
					'ClassOfService'=> 'Silver',
				'OEMIdHBE'=> 'SLA Remote',				
				'ELANNetworkType'=> 'HBE',				
				'ELANNetwork'=> 3,				
				'FinalELANNetwork'=> 3 },
				new Map<String, Object>{
				'ExistingCheckBox'=>false,
					'ClassOfService'=> 'Gold',
				'OEMIdHBE'=> 'SLA Remote',				
				'ELANNetworkType'=> 'Legacy',				
				'ELANNetwork'=> 3,				
				'FinalELANNetwork'=> 3  }
            }
        };
        inputMap.put('ELANConfigurationStep', elanConfigurationStep);

        // Call the method
        ELANConfigSERuleService service = new ELANConfigSERuleService();
        service.ELANConfigSERules(inputMap, outputMap, options);
		
        
    }
}