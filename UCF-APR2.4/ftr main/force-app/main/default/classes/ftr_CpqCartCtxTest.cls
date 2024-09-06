/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public with sharing class ftr_CpqCartCtxTest {
    @isTest
    static void addMessageTest() {
       String messageName = 'Frontier Communication';
       Object val = 'CpqCart';
       Map<String,Object> msg = new Map<String, Object>();
       msg.put(messageName,val);
       Map<String,Object> resultmap = ftr_CpqCartCtx.addMessage(messageName,msg);
       System.assert(resultmap.containsKey(messageName));
       System.assertEquals(val,resultmap.get(messageName));
    }
    @isTest  
    static void peekMessageTest() {
        String Message = 'Exception Found';
        ftr_CpqCartCtx.peekMessage(Message);
       
    }
    @isTest  
    static void getMessageTest() {
        String Message = 'Exception Found';
        ftr_CpqCartCtx.getMessage(Message);
       
    }
}