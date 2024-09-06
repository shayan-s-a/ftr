/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 4
**/
@isTest
public class WSCatalogItemsTest {
    
    @isTest
    public static void ftradressBeanTest(){
        Test.startTest();
        WSCatalogItems itemBean = new WSCatalogItems();
        itemBean.mrc = '1123';
        itemBean.mrcTotal = 'NYC';
        itemBean.mrcUsoc = 'NY';
        itemBean.name = '1234';
        itemBean.action = 'create';
        itemBean.disableAddToQuote = false;
        
        itemBean.nniMrcUsoc = '1234';
        itemBean.nniNrcUsoc = '1234';
        itemBean.nrc = '1234';
        itemBean.nrcTotal = '1234';
        itemBean.nrcUsoc = '1234';
        
        itemBean.linetotal = '1234';
        itemBean.parentId = '1234';
        itemBean.parentName = '1234';
        itemBean.productName = '1234';
        itemBean.speed = '1234';
        itemBean.uniMrcUsoc = '1234';
        itemBean.uniNrcUsoc = '1234';
        itemBean.term = '3 YR';
        itemBean.pNum = 'EPATH123456';
        List<WSCatalogItems> itemList = new List<WSCatalogItems>();
        itemBean.children = itemList;
        Test.stopTest();
    }
    
}