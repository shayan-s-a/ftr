/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2
**/
@isTest 
private class ftr_ProcessItemListTest{
    

    
    @isTest
    static void testBlockDetails(){
        
            Map<String,Object> convertedInput = (Map<String,Object>)JSON.deserializeUntyped('{"location": [{"Access_ServiceAccountId": "0010n000015muCFAAY","ACCESS_Location": "1480 Santa Monica Boulevard, Santa Monica, CA  00000","LocationName": "1480 Santa Monica Boulevard, 00000","Product": null},{"Access_ServiceAccountId": "0010n000015muCKAAY","ACCESS_Location": "1481 Santa Monica Boulevard, Santa Monica, CA  90404","LocationName": "1481 Santa Monica Boulevard,","Product": null},{"Access_ServiceAccountId": "0010n000015muCUAAY","ACCESS_Location": "737 9th Street, Durham, NC  00000","LocationName": "737 9th Street, 00000","Product": null}]}');
            
            system.debug('Location test----'+convertedInput);
        
       

        
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        String methodName = 'getBlockDetails';
        String PBEId = '01u0h000006ECj2AAG';
       
       
        Map<String, Object> inputMap = new Map<String, Object>{
            'PBEId' => PBEId,
                'location' => convertedInput.get('location')};
                
        
        ftr_ProcessItemList prItem = new ftr_ProcessItemList();
        Test.startTest();
        Boolean outparam = prItem.invokeMethod(methodName,inputMap,options,outputMap);
        Test.stopTest();
        system.assertEquals(true,outparam);
        
        
    }
    
    @isTest
    
    static void testMapBlockDetails(){
        
            Map<String,Object> convertedMapInput = (Map<String,Object>)JSON.deserializeUntyped('{"location":{"Access_ServiceAccountId": "0010n000015muCFAAY","ACCESS_Location": "1480 Santa Monica Boulevard, Santa Monica, CA  00000","LocationName": "1480 Santa Monica Boulevard, 00000","Product": null}}');
            
            system.debug('Location test----'+convertedMapInput);
        
       

        
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        String methodName = 'getBlockDetails';
        String PBEId = '01u0h000006ECj2AAG';
       
       
        Map<String, Object> inputMap = new Map<String, Object>{
            'PBEId' => PBEId,
                'location' => convertedMapInput.get('location')};
                
        
        ftr_ProcessItemList prItem = new ftr_ProcessItemList();
        Test.startTest();
        Boolean outparam = prItem.invokeMethod(methodName,inputMap,options,outputMap);
        Test.stopTest();
        system.assertEquals(true,outparam);
        
        
    }
    
    

}