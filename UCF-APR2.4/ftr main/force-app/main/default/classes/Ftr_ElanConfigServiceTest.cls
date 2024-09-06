@isTest
private class Ftr_ElanConfigServiceTest {

    // Test method for UpdateELANParentID
     @IsTest(SeeAllData=true)

    static void testUpdateELANParentID() {
       
        // Create test data
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        // Populate inputMap, outputMap, and options with appropriate data
        Map<String, Object> elanConfigurationStep = new Map<String, Object>{
            'ELANProductsBlock' => new List<Object>{
                new Map<String, Object>{
                    'ExistingCheckBox' => true,
                    'ELANPrefix' => 'OldPrefix',
                    'ELANSCMD' => 'OldCMD',
                    'ELANSerial' => 'OldSerial',
                    'ELANTelco' => 'OldTelco'
                },
                new Map<String, Object>{
                    'ExistingCheckBox' => false,
                    'ELANPrefix' => 'NewPrefix',
                    'ELANSCMD' => 'NewCMD',
                    'ELANSerial' => 'NewSerial',
                    'ELANTelco' => 'NewTelco'
                }
            }
        };
        inputMap.put('ELANConfigurationStep', elanConfigurationStep);
        options.put('UpdateELANPrefix', 'UpdatedPrefix');
        options.put('UpdateELANSCMD', 'UpdatedCMD');
        options.put('UpdateELANSerial', 'UpdatedSerial');
        options.put('UpdateTelco', 'UpdatedTelco');

        // Call the method
        Ftr_ElanConfigService service = new Ftr_ElanConfigService();
        service.UpdateELANParentID(inputMap, outputMap, options);

        // Assert the results
        //List<Object> updatedElanBlock = (List<Object>)outputMap.get('ELANConfigurationStep').get('ELANProductsBlock');
        //System.assertEquals(2, updatedElanBlock.size());
        //Map<String, Object> updatedElan = (Map<String, Object>)updatedElanBlock[0];
        //System.assertEquals('UpdatedPrefix', updatedElan.get('ELANPrefix'));
        //System.assertEquals('UpdatedCMD', updatedElan.get('ELANSCMD'));
        //System.assertEquals('UpdatedSerial', updatedElan.get('ELANSerial'));
        //System.assertEquals('UpdatedTelco', updatedElan.get('ELANTelco'));
    }

    // Test method for Saveelandata
    @isTest
    static void testSaveelandata() {
        // Create test data
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        // Populate inputMap, outputMap, and options with appropriate data
        Map<String, Object> elanConfigurationStep = new Map<String, Object>{
            'ELANProductsBlock' => new List<Object>{
                new Map<String, Object>{
                    'ExistingCheckBox' => true,
                    'ELANId' => '123',
                    'CircuitIDText' => 'OldCircuitID',
                        'ExistingCheckBox'=>false,
					'ClassOfService'=> 'Gold',
                        'OEMIdHBE'=> 'SLA HUB 1',				
				'ELANNetworkType'=> 'HBE',				
				'ELANNetwork'=> 1,				
				'FinalELANNetwork'=> 1
                },
                new Map<String, Object>{
                    'ExistingCheckBox' => true,
                    'ELANNetwork' => 456                   
                },
                new Map<String, Object>{
                    'ExistingCheckBox' => false,
                    'ELANNetwork' => 45                        
                },
                new Map<String, Object>{
                    'ExistingCheckBox' => true,
                    'ELANNetwork' => 789                  
                }
            }
        };
        inputMap.put('ELANConfigurationStep', elanConfigurationStep);
		//System.debug('inputMap in assert\n'+JSON.serializePretty(inputMap));
        // Call the method
        Ftr_ElanConfigService service = new Ftr_ElanConfigService();
        service.Saveelandata(inputMap, outputMap, options);

        // Assert the results
        /*List<Map<String, Object>> updatedElanList = (List<Map<String, Object>>)inputMap.get('updatedelan');
       //System.assertEquals(3, updatedElanList.size());
       
        Map<String, Object> firstElan = updatedElanList[0];
        System.assertEquals(true, firstElan.get('existing'));
        System.assertEquals('123', firstElan.get('ELANId'));
        System.assertEquals('OldCircuitID', firstElan.get('finalcircuitid'));*/
    }
}