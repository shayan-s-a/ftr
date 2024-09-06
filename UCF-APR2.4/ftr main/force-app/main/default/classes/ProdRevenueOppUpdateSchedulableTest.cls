/**
 * ───────────────────────────────────────────────────────────────────────────────────────────────┐
* Test method for ProdRevenueOppUpdateSchedulable class
* ────────────────────────────────────────────────────────────────────────────────────────────────
* @param    not applicable 
* @return   not applicable
* ───────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class ProdRevenueOppUpdateSchedulableTest {
    @isTest static void ProdRevenueOppUpdateSchedulableTest() {
        Test.startTest();
        ProdRevenueOppUpdateSchedulable prv = new ProdRevenueOppUpdateSchedulable();
        String scheduleTime = '0 0 2 * * ?';
        System.schedule('Test Schedule Check', scheduleTime, prv);
        Test.stopTest();
        System.assert(true);
    }
}