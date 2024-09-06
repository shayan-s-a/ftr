@isTest
private class CopyEVCSpeedtoUNITest {

 
     // @isTest
    //   static void testCopyEVCSpeedtoUNITrans() {
       
    //     Map<String, Object> inputMap = new Map<String, Object>();
    //     Map<String, Object> outputMap = new Map<String, Object>();
    //     Map<String, Object> options = new Map<String, Object>();

    //     Map<String, Object> AccessLocation = new Map<String, Object>();   

    //     List<string> products = new List<string>();
    //     products.add('EIA');
    //     products.add('EVPL');
    //     products.add('ELAN');
    //     products.add('IPVPN');
    //     products.add('Jumbo Frames');
    //     products.add('EPL');
    //     products.add('Connect Cloud');
    //     products.add('EPath');
    //     products.add('EReach');
    //        AccessLocation.put('Products', products);
        
    //     inputMap.put('products', products);        
    //     CopyEVCSpeedtoUNI testClassInstance = new CopyEVCSpeedtoUNI();        
    //     Boolean result = testClassInstance.invokeMethod('CopyEVCSpeedtoUNI', inputMap, outputMap, options);
    //     System.assertEquals(outputMap.get('value').toString(),'EIA,EVPL,ELAN,IPVPN,Jumbo Frames,EPL,Connect Cloud,EPath,EReach' );
    //     System.assertEquals(true, result);           
    //     System.assert(result != null);       
    // }

    //@isTest
    // static void testFetchUNI() {
    //     // Test data setup
    //     Map<String, Object> inputMap = new Map<String, Object>();
    //     Map<String, Object> outputMap = new Map<String, Object>();
    //     Map<String, Object> options = new Map<String, Object>();

               
       
    //     CopyEVCSpeedtoUNI testClassInstance = new CopyEVCSpeedtoUNI();

    //             Boolean result = testClassInstance.invokeMethod('FetchUNI', inputMap, outputMap, options);


    //     System.assertEquals(true, result);
    //    // System.assert(result != null);

       
    // }
    @isTest
    static void GetAttributesForReviewRemote(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        String OrderId='801Ei00000CTfdcIAD';
        inputMap.put('ContextId',OrderId);
        String str = '{"AccessLocation":[{"Product":{"ProductName":"User to Network Interface (UNI) Port - C-3888 Workman Mill Road, 90601"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiRNIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"3888 Workman Mill Road, Whittier, CA  90601","Id":"802Ei000004KsqLIAS","Action":"Add","AccessReferenceId":"7330e2d5-26c2-d090-f324-b4b684e63a62","ACCESS_ReferenceId":"7330e2d5-26c2-d090-f324-b4b684e63a62"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - A-10506 3rd Street North, 33716"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AswPVIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"10506 3rd Street North, St. Petersburg, FL  33716","Id":"802Ei000004L8I9IAK","Action":"Add","AccessReferenceId":"4d7c34e8-5b12-0876-e659-5fce9afa0cac","ACCESS_ReferenceId":"4d7c34e8-5b12-0876-e659-5fce9afa0cac"},{"Product":{"ProductName":"DIA (Dedicated Internet Access)"},"SpeedinMbps":1000,"noofpartners":0,"ServiceAccountId":"001Ei00000AswPVIAZ","ProductCode":"ENT_ETH_EIA_0002","Location":"10506 3rd Street North, St. Petersburg, FL  33716","Id":"802Ei000004L8rXIAS","Action":"Add","AccessReferenceId":"0ff018fd-dea6-4346-de2c-b38424095e62","ACCESS_ReferenceId":"0ff018fd-dea6-4346-de2c-b38424095e62"},{"Product":{"ProductName":"IP"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AswPVIAZ","ProductCode":"ENT_ETH_IP_0002","Location":"10506 3rd Street North, St. Petersburg, FL  33716","Id":"802Ei000004L8rYIAS","Action":"Add","AccessReferenceId":"01d793bb-7bc1-1e80-2500-2fc886364c50","ACCESS_ReferenceId":"01d793bb-7bc1-1e80-2500-2fc886364c50"},{"Product":{"ProductName":"ELAN (Ethernet LAN)"},"SpeedinMbps":40,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiRNIAZ","ProductCode":"ENT_ETH_ELAN_0001","Location":"3888 Workman Mill Road, Whittier, CA  90601","Id":"802Ei000004L8rZIAS","Action":"Add","AccessReferenceId":"78f8284a-380f-3f86-b6de-d7d275eb4eb8","ACCESS_ReferenceId":"78f8284a-380f-3f86-b6de-d7d275eb4eb8"},{"Product":{"ProductName":"ELAN (Ethernet LAN)"},"SpeedinMbps":25000,"noofpartners":0,"ServiceAccountId":"001Ei00000B82SvIAJ","ProductCode":"ENT_ETH_ELAN_0001","Location":"185 South Lake Shore Way, Lake Alfred, FL  33850","Id":"802Ei000004L8raIAC","Action":"Add","AccessReferenceId":"9e9514b8-2a72-7996-4bb2-370f7a901783","ACCESS_ReferenceId":"9e9514b8-2a72-7996-4bb2-370f7a901783"},{"Product":{"ProductName":"ELAN (Ethernet LAN)"},"SpeedinMbps":5000,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiWCIAZ","ProductCode":"ENT_ETH_ELAN_0001","Location":"610 North Morgan Street, Tampa, FL  33602","Id":"802Ei000004L8rbIAC","Action":"Add","AccessReferenceId":"e1e06e44-e038-a89c-daa4-8b2342bf3aa2","ACCESS_ReferenceId":"e1e06e44-e038-a89c-daa4-8b2342bf3aa2"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - B-3888 Workman Mill Road, 90601"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiRNIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"3888 Workman Mill Road, Whittier, CA  90601","Id":"802Ei000004LD9iIAG","Action":"Add","AccessReferenceId":"ec732640-9a3c-6cca-4626-bbb69547dc2a","ACCESS_ReferenceId":"ec732640-9a3c-6cca-4626-bbb69547dc2a"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - A-610 North Morgan Street, 33602"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiWCIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"610 North Morgan Street, Tampa, FL  33602","Id":"802Ei000004LFecIAG","Action":"Add","AccessReferenceId":"270f3b04-9b21-ff08-9009-29a739d89361","ACCESS_ReferenceId":"270f3b04-9b21-ff08-9009-29a739d89361"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - A-3888 Workman Mill Road, 90601"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiRNIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"3888 Workman Mill Road, Whittier, CA  90601","Id":"802Ei000004LGlpIAG","Action":"Add","AccessReferenceId":"759ce497-8abf-da97-eee7-c1c5afae8a45","ACCESS_ReferenceId":"759ce497-8abf-da97-eee7-c1c5afae8a45"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - A-185 South Lake Shore Way, 33850"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000B82SvIAJ","ProductCode":"ENT_ETH_UNI_0001","Location":"185 South Lake Shore Way, Lake Alfred, FL  33850","Id":"802Ei000004LGttIAG","Action":"Add","AccessReferenceId":"40653841-5489-1853-3933-da96b912321a","ACCESS_ReferenceId":"40653841-5489-1853-3933-da96b912321a"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - D-3888 Workman Mill Road, 90601"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiRNIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"3888 Workman Mill Road, Whittier, CA  90601","Id":"802Ei000004LGtuIAG","Action":"Add","AccessReferenceId":"ac940a79-9e3a-7331-5306-da09d574a03e","ACCESS_ReferenceId":"ac940a79-9e3a-7331-5306-da09d574a03e"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - G-3888 Workman Mill Road, 90601"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiRNIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"3888 Workman Mill Road, Whittier, CA  90601","Id":"802Ei000004LKCrIAO","Action":"Add","AccessReferenceId":"145838e1-9e4c-e0c4-16df-34d7e514d6d1","ACCESS_ReferenceId":"145838e1-9e4c-e0c4-16df-34d7e514d6d1"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - B-610 North Morgan Street, 33602"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiWCIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"610 North Morgan Street, Tampa, FL  33602","Id":"802Ei000004LKnpIAG","Action":"Add","AccessReferenceId":"a5b551ab-f836-7041-44b9-f458b772d553","ACCESS_ReferenceId":"a5b551ab-f836-7041-44b9-f458b772d553"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - F-3888 Workman Mill Road, 90601"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiRNIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"3888 Workman Mill Road, Whittier, CA  90601","Id":"802Ei000004LLNLIA4","Action":"Add","AccessReferenceId":"6319c099-4f22-446b-7d78-27cca9810961","ACCESS_ReferenceId":"6319c099-4f22-446b-7d78-27cca9810961"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - E-3888 Workman Mill Road, 90601"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiRNIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"3888 Workman Mill Road, Whittier, CA  90601","Id":"802Ei000004LLtZIAW","Action":"Add","AccessReferenceId":"2fa2873c-e630-125b-6271-4cda458d653a","ACCESS_ReferenceId":"2fa2873c-e630-125b-6271-4cda458d653a"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - I-3888 Workman Mill Road, 90601"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiRNIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"3888 Workman Mill Road, Whittier, CA  90601","Id":"802Ei000004NGRmIAO","Action":"Add","AccessReferenceId":"220aa6c3-8fce-d1d6-826a-90ece05670b8","ACCESS_ReferenceId":"220aa6c3-8fce-d1d6-826a-90ece05670b8"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - H-3888 Workman Mill Road, 90601"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiRNIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"3888 Workman Mill Road, Whittier, CA  90601","Id":"802Ei000004NJR4IAO","Action":"Add","AccessReferenceId":"ce7dabd4-78e9-49bf-9510-ade8d6ef6bc0","ACCESS_ReferenceId":"ce7dabd4-78e9-49bf-9510-ade8d6ef6bc0"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - I-3888 Workman Mill Road, 90601"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiRNIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"3888 Workman Mill Road, Whittier, CA  90601","Id":"802Ei000004NKq9IAG","Action":"Add","AccessReferenceId":"9d07065f-75d7-cc73-bfdf-d6e66733a06b","ACCESS_ReferenceId":"9d07065f-75d7-cc73-bfdf-d6e66733a06b"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - J-3888 Workman Mill Road, 90601"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiRNIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"3888 Workman Mill Road, Whittier, CA  90601","Id":"802Ei000004NSirIAG","Action":"Add","AccessReferenceId":"7d9d3cb6-9bc1-2940-41ee-09372ae0b60a","ACCESS_ReferenceId":"7d9d3cb6-9bc1-2940-41ee-09372ae0b60a"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - K-3888 Workman Mill Road, 90601"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiRNIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"3888 Workman Mill Road, Whittier, CA  90601","Id":"802Ei000004NSm5IAG","Action":"Add","AccessReferenceId":"89886aa3-570f-4ce3-be46-63db1b55c8db","ACCESS_ReferenceId":"89886aa3-570f-4ce3-be46-63db1b55c8db"},{"Product":{"ProductName":"User to Network Interface (UNI) Port - L-3888 Workman Mill Road, 90601"},"SpeedinMbps":0,"noofpartners":0,"ServiceAccountId":"001Ei00000AsiRNIAZ","ProductCode":"ENT_ETH_UNI_0001","Location":"3888 Workman Mill Road, Whittier, CA  90601","Id":"802Ei000004NSu9IAG","Action":"Add","AccessReferenceId":"7468938e-d361-c85f-e058-32a2be00feb2","ACCESS_ReferenceId":"7468938e-d361-c85f-e058-32a2be00feb2"}]}';
        inputMap.put('StaticResourceName',str);
        
        
        Test.startTest();
        CopyEVCSpeedtoUNI ftrelan = new CopyEVCSpeedtoUNI();        
        ftrelan.GetAttributesForReviewRemote(inputMap, outputMap, options);     
        Test.stopTest();
    }
}