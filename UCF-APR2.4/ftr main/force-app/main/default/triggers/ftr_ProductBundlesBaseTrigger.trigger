/*********************************************************************************************************************
*@Name        : ftr_ProductBundlesBaseTrigger
*@Author      : Dileep Chinthala <dileep.chinthala@ftr.com>
*@Description : calls ftr_ProductBundlesBaseTriggerHandler utility class.This class is assumed to be called from
*              either before Insert or Before update events of the Product_Bundles_Base__c triggers. 
* UPDATES
* Version 		Date       		Developer  				Description
*------------------------------------------------------------------------------------------------------------------
*1.0    		08/04/2021     Dileep Chinthala      Initial Creation                                                      

**********************************************************************************************************************/
trigger ftr_ProductBundlesBaseTrigger on Product_Bundles_Base__c (before insert, after insert, before update, after update, before delete, after delete) {
    new ftr_ProductBundlesBaseTriggerHandler().run();
}