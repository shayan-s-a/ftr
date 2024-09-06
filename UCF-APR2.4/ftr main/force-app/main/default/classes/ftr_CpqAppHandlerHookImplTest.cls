/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public with sharing class ftr_CpqAppHandlerHookImplTest {

    @isTest
    static void getCartsItems_Test(){
        String methodname = 'getCartsItems.PreInvoke';

        Map<String, Object> inputmap = new Map<String, Object>();
        Map<String, Object> outputmap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_CpqAppHandlerHookImpl hookimpl = new ftr_CpqAppHandlerHookImpl();
        test.startTest();
        Boolean result = hookimpl.invokeMethod(methodname,inputmap,outputmap,options);
        test.stopTest();

        System.assertEquals(true,result);
    }

    @isTest
    static void postCartsItems_Test(){
        String methodname = 'postCartsItems.PreInvoke';

        Map<String, Object> inputmap = new Map<String, Object>();
        Map<String, Object> outputmap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_CpqAppHandlerHookImpl hookimpl = new ftr_CpqAppHandlerHookImpl();
        test.startTest();
        Boolean result = hookimpl.invokeMethod(methodname,inputmap,outputmap,options);
        test.stopTest();

        // System.assertEquals(true,result);
    }
    @isTest
    static void cloneItems_Test(){
        String methodname = 'cloneItems.PreInvoke';

        Map<String, Object> inputmap = new Map<String, Object>();
        Map<String, Object> outputmap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_CpqAppHandlerHookImpl hookimpl = new ftr_CpqAppHandlerHookImpl();
        test.startTest();
        Boolean result = hookimpl.invokeMethod(methodname,inputmap,outputmap,options);
        test.stopTest();

        System.assertEquals(true,result);
    }
    @isTest
    static void putCartsItems_Test(){
        String methodname = 'putCartsItems.PreInvoke';

        Map<String, Object> inputmap = new Map<String, Object>();
        Map<String, Object> outputmap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_CpqAppHandlerHookImpl hookimpl = new ftr_CpqAppHandlerHookImpl();
        test.startTest();
        Boolean result = hookimpl.invokeMethod(methodname,inputmap,outputmap,options);
        test.stopTest();
        //System.assertEquals(true,result);
    }
    @isTest
    static void deleteCartsItems_Test(){
        String methodname = 'deleteCartsItems.PreInvoke';

        Map<String, Object> inputmap = new Map<String, Object>();
        Map<String, Object> outputmap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_CpqAppHandlerHookImpl hookimpl = new ftr_CpqAppHandlerHookImpl();
        test.startTest();
        Boolean result = hookimpl.invokeMethod(methodname,inputmap,outputmap,options);
        test.stopTest();

        //System.assertEquals(true,result);
    }
    @isTest
    static void getCartsItemsPostInvoke_Test(){
        String methodname = 'getCartsItems.PostInvoke';

        Map<String, Object> inputmap = new Map<String, Object>();
        Map<String, Object> outputmap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_CpqAppHandlerHookImpl hookimpl = new ftr_CpqAppHandlerHookImpl();
        test.startTest();
        Boolean result = hookimpl.invokeMethod(methodname,inputmap,outputmap,options);
        test.stopTest();

        System.assertEquals(true,result);
    }
    @isTest
    static void postCartsItemsPostInvoke_Test(){
        String methodname = 'postCartsItems.PostInvoke';

        Map<String, Object> inputmap = new Map<String, Object>();
        Map<String, Object> outputmap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_CpqAppHandlerHookImpl hookimpl = new ftr_CpqAppHandlerHookImpl();
        test.startTest();
        Boolean result = hookimpl.invokeMethod(methodname,inputmap,outputmap,options);
        test.stopTest();
        System.assertEquals(true,result);
    }
    @isTest
    static void putCartsItemsPostInvoke_Test(){
        String methodname = 'putCartsItems.PostInvoke';

        Map<String, Object> inputmap = new Map<String, Object>();
        Map<String, Object> outputmap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_CpqAppHandlerHookImpl hookimpl = new ftr_CpqAppHandlerHookImpl();
        test.startTest();
        Boolean result = hookimpl.invokeMethod(methodname,inputmap,outputmap,options);
        test.stopTest();

        System.assertEquals(true,result);
    }
    @isTest
    static void deleteCartsItemsPostInvoke_Test(){
        String methodname = 'deleteCartsItems.PostInvoke';

        Map<String, Object> inputmap = new Map<String, Object>();
        Map<String, Object> outputmap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        ftr_CpqAppHandlerHookImpl hookimpl = new ftr_CpqAppHandlerHookImpl();
        test.startTest();
        Boolean result = hookimpl.invokeMethod(methodname,inputmap,outputmap,options);
        test.stopTest();
        System.assertEquals(true,result);
    }
}