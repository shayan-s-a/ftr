@isTest
public class AssetsUIContollerTest {
    //version1
    @isTest
    static void testGetAssetUIMappingJSON() {
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>(); 
        String methodName = 'getAssetUIMappingJSON';
        AssetsUIContoller assetUIContr = new AssetsUIContoller();
        Boolean bResult = assetUIContr.invokeMethod(methodName, inputMap, outputMap, options);

       // System.assertEquals(true, bResult);
    }
}