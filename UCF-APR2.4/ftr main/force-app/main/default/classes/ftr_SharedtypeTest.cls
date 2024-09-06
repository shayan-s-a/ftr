/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class ftr_SharedtypeTest {
    
    @isTest
    public static void sharedTypeTest(){
        Test.startTest();
        ftr_Sharedtype.ResponseHeader respHeader = new ftr_Sharedtype.ResponseHeader();
        ftr_Sharedtype.ExecutionStatusMessage executeMsg = new ftr_Sharedtype.ExecutionStatusMessage();
        ftr_Sharedtype.Address addr = new ftr_Sharedtype.Address();
        ftr_Sharedtype.TimePeriod timePeriod = new ftr_Sharedtype.TimePeriod();
        ftr_Sharedtype.GlobalPosition gp = new ftr_Sharedtype.GlobalPosition();
        ftr_Sharedtype.EnvelopeAddress envelop = new ftr_Sharedtype.EnvelopeAddress();
        ftr_Sharedtype.TelephoneNumberAsId tel = new ftr_Sharedtype.TelephoneNumberAsId();
        ftr_Sharedtype.AccountIdRequest accountIdReq = new ftr_Sharedtype.AccountIdRequest();
        ftr_Sharedtype.RequestHeader reqHeader = new ftr_Sharedtype.RequestHeader();
        ftr_Sharedtype.EmailAccountId emailAccId = new ftr_Sharedtype.EmailAccountId();
        ftr_Sharedtype.ForEsbUseOnly forEsb = new ftr_Sharedtype.ForEsbUseOnly();
        ftr_Sharedtype.QuantityDecimal qd = new ftr_Sharedtype.QuantityDecimal();
        ftr_Sharedtype.GivenAndFamilyName gfn = new ftr_Sharedtype.GivenAndFamilyName();
        ftr_Sharedtype.AddressChoice adc = new ftr_Sharedtype.AddressChoice();
        ftr_Sharedtype.SecurityInfo si = new ftr_Sharedtype.SecurityInfo();
        ftr_Sharedtype.ServiceAddressMasterId ser = new ftr_Sharedtype.ServiceAddressMasterId();
        Test.stopTest();
    }
}