@IsTest
public class ftr_GitlabServiceTest {
    
    @IsTest
    static void test(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGitLab());
        ftr_GitlabService.updateClientIdInRepository();
        Test.stopTest();
        
    }
}
