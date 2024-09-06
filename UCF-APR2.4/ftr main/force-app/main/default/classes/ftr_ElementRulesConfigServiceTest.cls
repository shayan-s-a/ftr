/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@IsTest
public class ftr_ElementRulesConfigServiceTest {

    @TestSetup
    static void makeData(){
        
        insert new ftr_SIP_ElementRulesConfig__c(
            CCS__c='5-20',
            HandOff__c='SIP'
        );
    }

    @IsTest
    static void successTest(){
        
        Test.startTest();
        ftr_ElementRulesConfigService service = new ftr_ElementRulesConfigService();
        service.invokeMethod('getCCSDataByHandoff', new Map<String,Object>{
            'ccs' => 10,
            'PBXHandOff' => 'SIP'
        }, new Map<String,Object>(), new Map<String,Object>());
        Test.stopTest();
        
    }
    
    @IsTest
    static void failureTest(){
        
        Test.startTest();
        ftr_ElementRulesConfigService service = new ftr_ElementRulesConfigService();
        service.invokeMethod('getCCSDataByHandoff', new Map<String,Object>{
            'PBXHandOff' => 'SIP'
        }, new Map<String,Object>(), new Map<String,Object>());
        service.invokeMethod('getCCSDataByHandoff', new Map<String,Object>{
            'ccs' => 10
        }, new Map<String,Object>(), new Map<String,Object>());
        Test.stopTest();
        
    }
}