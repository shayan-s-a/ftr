/**
 * @description       : This test class covers the following Apex classes:
 *      ftr_PrepareSandboxService
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2
**/
@IsTest
public class ftr_PrepareSandboxServiceTest {
    
    @IsTest
    static void updateMetadataTest(){
        
        Test.startTest();
        ftr_PrepareSandboxService.updateMetadata();
        Test.stopTest();
        
    }

    @IsTest
    static void updateDeveloperProfilesTest(){
        
        Test.startTest();
        ftr_PrepareSandboxService.updateDeveloperProfiles();
        Test.stopTest();
        
    }
}
