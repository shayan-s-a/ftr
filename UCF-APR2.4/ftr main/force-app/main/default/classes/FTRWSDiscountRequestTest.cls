@isTest
public class FTRWSDiscountRequestTest {

          @isTest
    public static void TestFTRWSDiscountRequest() {
        Test.startTest();
        FTRWSDiscountRequest req = new FTRWSDiscountRequest();
        req.discountType = 'AMOUNT';
        req.discountVal = 100.00;
        req.mrcDiscountNotes = 'TEST MRC';
        req.nrcDiscountNotes = 'TEST NRC';
        req.recurringType = 'MRC';
        Test.stopTest();
    }
}