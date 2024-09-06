/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest 
public class UpdatedMRRWrapper_Test 
{
    
    public static testmethod void Test_1(){
        
        string psosimplejson='{"updatedMRRValue":"","recurringCharge":"","recurringTotal":"","quantityValue": ""}';
        
        UpdatedMRRWrapper pw = new UpdatedMRRWrapper();
        
        pw = UpdatedMRRWrapper.parse(psosimplejson);
        
        
    }
}