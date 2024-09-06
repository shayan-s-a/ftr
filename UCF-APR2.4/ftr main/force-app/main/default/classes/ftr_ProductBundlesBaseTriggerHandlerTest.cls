/**
 * @description       : This test class covers the following Apex classes:
 *      ftr_ProductBundlesBaseTriggerHandler
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
/*********************************************************************************************************************
*@Name        : ftr_ProductBundlesBaseTriggerHandlerTest
*@Author      : Dileep Chinthala <dileep.chinthala@ftr.com>
*@Description : This test class covers ftr_ProductBundlesBaseTriggerHandler 				
* UPDATES
* Version 		Date       		Developer  				Description
*------------------------------------------------------------------------------------------------------------------
*1.0    		08/04/2021     Dileep Chinthala      Initial Creation                                                      

**********************************************************************************************************************/
@isTest
public with sharing class ftr_ProductBundlesBaseTriggerHandlerTest {
    
    @testSetup static void setup() {
        
        map <String, string > prodNamemap = new map <String, string >();
        prodNamemap.put('prod1', 'prod1');
        
        List<Product2>  prdList = ftr_TestDataFactory.getProducts(prodNamemap, 1);
        
        system.debug('!!!'+prdList);
        update prdList;
        Product_Bundles_Base__c testpba = new Product_Bundles_Base__c(Name = 'TestPba',DIA_Bundle__c = prdList[0].Id, Bundle_Type__c = 'DIA + UCF',Managed_Firewall_Bundle__c = prdList[0].Id, UCF_Bundle__c = prdList[0].Id, UCF_Phone__c = prdList[0].Id, Term__c = '36 months', Bundle_Admin_Key__c = '100MB DIA + Exec License + Yealnk T54W 3Yr Promotion');
        
        insert testpba;        
    }
    
    @isTest static void testMethod1() {
        
        Product_Bundles_Base__c pba1 = [SELECT Id FROM Product_Bundles_Base__c WHERE Name='TestPba' LIMIT 1];
        
        pba1.Bundle_Price__c = 100;
        
        update pba1;
        
        Product_Bundles_Base__c pba2 = [SELECT Id FROM Product_Bundles_Base__c WHERE Name='TestPba' LIMIT 1];
        
        delete pba2;
        
    }
    
}