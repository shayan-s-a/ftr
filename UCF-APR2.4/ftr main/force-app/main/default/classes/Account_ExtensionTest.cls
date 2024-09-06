/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 2
**/
@isTest(seeAllData = true)
public class Account_ExtensionTest{
    public static testMethod void testAccount(){
        try {
             
        List<Account> testAccountList = new List<Account>();
        
       Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('DPI').getRecordTypeId();

        Account testAccount = new Account( Name ='7157543333.0',
        								Hierarchy_Level__c = 'MEMBER',
                                        ParentSequenceId__c='7157543333.0', 
                                        TNSequenceId__c = '7157543333.0',
                                        Library_Id__c ='LF',
                                        RecordTypeId = RecordTypeIdAccount
                                        );
            System.debug('RecordTypeIdAccount -- '+RecordTypeIdAccount);
        testAccountList.add(testAccount);                                
        
        if (testAccountList.size() > 0)
          upsert  testAccountList TNSequenceId__c;
          
    List<Account> acc =  [SELECT Id, Type, ManageAccount_Updated__c,  Promo_Exp_Date__c, Federal__c, ShippingStateCode, ParentSequenceId__c, Library_Id__c, RecordType.Name, TNSequenceId__c FROM Account WHERE Id = :testAccount.Id ];
        System.debug('Account size -- '+acc.size());
    AvailableTechnology__c avlTch = new AvailableTechnology__c(Account__c = acc[0].id, Additional_Speed_Info__c='',Available_Speed__c='241241', Customer_Type__c='124124',Default_Modem__c='24124',Market_Offering__c='12412',Max_Dslam_Speed__c='241234',PrePaid_BroadBand_Capable__c=false,Tech_Feature__c='24312',Technology__c='42141',Technology_Group__c='41241',Technology_Item__c='142314');
    //insert avlTch;
    Customer_Poducts__c cusPrd = new Customer_Poducts__c(Account__c = acc[0].id);
    Promotion__c promo = new Promotion__c(Account__c = acc[0].id);
    //Directory_Information__c dirLst = new Directory_Information__c();
    Tax_Information__c txInfo = new Tax_Information__c(Account__c = acc[0].id);
    Memo__c mem = new Memo__c(Account__c = acc[0].id);
    
        
    PageReference testPage = Page.Account_Header;
    Test.setCurrentPage(testPage);
    ApexPages.currentPage().getParameters().get(acc[0].id);//.put('id', acc.id);
    ApexPages.StandardController sc = new ApexPages.StandardController(acc[0]);

    //Test.setMock(WebServiceMock.class, new WS_ESB_ManageAccountMockWebSerTest()); 
    Test.startTest();
    Account_Extension aExt = new Account_Extension(sc);
    
    System.debug(ApexPages.currentPage().getParameters().get('id')+'777777777777777777777777777777777777777777777777777777777');
   
    //---------------------------------------------------------------------------------------------------------------
    
    //initializing aExt
    aExt.strBroadband = 'ads';
    aExt.strPackage = 'ads';
    aExt.strFsecure = 'ads';
    aExt.strLongDistance = 'ads';
    aExt.strDish = 'ads';
    aExt.strCPE = 'ads';
    //---------------------------------------------------------------------------------------------------------------
    
    
    
    aExt.lstAvailableTech = new List<AvailableTechnology__c>();
    aExt.lstAvailableTech.add(avlTch);
    aExt.lstCustProduct = new List<Customer_Poducts__c>();
    aExt.lstCustProduct.add(cusPrd);
    aExt.lstPromo = new List<Promotion__c>();
    aExt.lstPromo.add(promo);
    aExt.lstTaxInformation = new List<Tax_Information__c>();
    aExt.lstTaxInformation.add(txInfo);
    //aExt.lstDirectory = new List<Directory_Information__c>();
    //aExt.lstDirectory.add(dirLst);
    aExt.lstMemo1 = new List<Memo__c>();
    aExt.lstMemo1.add(mem);
    //---------------------------------------------------------------------------------------------------------------
    
    //Test.setMock(WebServiceMock.class, new WS_ESB_ManageAccountGtMemoMockWebSerTest());
    aExt.getMemoCallout('7157543333', 'LF');
    boolean b1 = aExt.getShowLoadingAnimation();
    aExt.retrieveAccountDetails();    
    PageReference pRf = aExt.salesIndicators();
    
    
    boolean vm = aExt.getVmCode();
    
    aExt.resetVoiceMailPasscode();
    aExt.closePopup();
    
    test.stoptest();
            
            } catch (DmlException ex) {}
   }
    
 }