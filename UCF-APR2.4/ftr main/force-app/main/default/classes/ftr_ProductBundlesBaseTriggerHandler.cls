/*********************************************************************************************************************
*@Name        : ftr_ProductBundlesBaseTriggerHandler
*@Author      : Dileep Chinthala <dileep.chinthala@ftr.com>
*@Description : This utility class is called from ftr_ProductBundlesBaseTrigger to perform look-up of certain fields on Product Bundles Admin records
*              to populate the fields based on related field values. This class is assumed to be called from
*              either before Insert or Before update events of the Product_Bundles_Base__c triggers. 
* UPDATES
* Version 		Date       		Developer  				Description
*------------------------------------------------------------------------------------------------------------------
*1.0    		08/04/2021     Dileep Chinthala      Initial Creation                                                      

**********************************************************************************************************************/

public class ftr_ProductBundlesBaseTriggerHandler extends ftr_TriggerHandler{
	public override void beforeInsert() {
        ftr_Logger.writeInfo('ftr_ProductBundlesBaseTriggerHandler.beforeInsert');
        ProductBundlesBaseService.setPricebookitemId( Trigger.New );
    }
    
    public override void afterInsert() {
        ftr_Logger.writeInfo('ftr_ProductBundlesBaseTriggerHandler.afterInsert');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);
    }
    public override void beforeUpdate() {
        ftr_Logger.writeInfo('ftr_ProductBundlesBaseTriggerHandler.beforeUpdate');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);
        ProductBundlesBaseService.setPricebookitemId( Trigger.New );
    }
    public override void afterUpdate() {
        ftr_Logger.writeInfo('ftr_ProductBundlesBaseTriggerHandler.afterUpdate');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);
    }
    public override void beforeDelete() {
        
    }
    public override void afterDelete() {
        ftr_Logger.writeInfo('ftr_ProductBundlesBaseTriggerHandler.afterDelete');
        ftr_Logger.writeVar('Trigger.old', Trigger.old);
    }
}