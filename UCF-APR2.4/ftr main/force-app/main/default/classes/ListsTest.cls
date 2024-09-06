/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
private class ListsTest {

    @isTest
    static void testCorrectPartions(){
        List<Integer> records = new List<Integer> {
            1, 2, 3, 4, 5
            };
        Test.startTest();
            List<List<Integer>> actual = (List<List<Integer>>) Lists.doPartions(records, 2, List<List<Integer>>.class);
        Test.stopTest();
        System.assertEquals(3, actual.size(), 'Incorrect number of partions');
        Integer tempNumber = 1;
        for(List<Integer> itemsActual :actual){
            for(Integer numb :itemsActual){
                System.assertEquals(tempNumber, numb, 'Order of elements isn\'t saved');
                ++tempNumber;
            }
        }
    }
}