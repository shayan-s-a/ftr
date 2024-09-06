public with sharing class NeustarDataTriggerHandler extends ftr_TriggerHandler {
    public override void beforeInsert() {
        ftr_Logger.writeInfo('NeustarDataTriggerHandler.beforeInsert Start');
        ftr_Logger.writeVar('Trigger.new', Trigger.new);
        Set<string> phoneList = new Set<string>();
        for (sObject obj : Trigger.new) {
            phoneList.add((String) obj.get('TN__c'));
        }
        for (Account a : [SELECT id, phone, recordtype.name from account WHERE phone IN :phoneList AND recordtype.name IN ('Master', 'Service', 'Billing') LIMIT 50000]) {
            String accPhone = a.phone.replaceAll('[^0-9]', '');
            for (sObject obj : Trigger.new) {
                if ((string)obj.get('TN__c') == accPhone) {
                    switch on a.recordtype.name {
                        when 'Master' {
                            obj.put('Master_Account__c', a.id);
                        }
                        when 'Service' {
                            obj.put('Service_Account__c', a.id);
                        }
                        when 'Billing' {
                            obj.put('Billing_Account__c', a.id);
                        }
                        when else {
                            // do nothing   
                        }
                    }   
                }
            }
        }
        ftr_Logger.writeInfo('NeustarDataTriggerHandler.beforeInsert End');
    }
    // public override void afterInsert() {
    //     ftr_Logger.writeInfo('NeustarDataTriggerHandler.afterInsert');
    //     ftr_Logger.writeVar('Trigger.new', Trigger.new);
    // }

    // public override void beforeUpdate() {
    //     ftr_Logger.writeInfo('NeustarDataTriggerHandler.beforeUpdate');
    //     ftr_Logger.writeVar('Trigger.new', Trigger.new);

    // }
    // public override void afterUpdate() {
    //     ftr_Logger.writeInfo('NeustarDataTriggerHandler.afterUpdate');
    //     ftr_Logger.writeVar('Trigger.new', Trigger.new);
    // }

    // public override void beforeDelete() {
    //     ftr_Logger.writeInfo('NeustarDataTriggerHandler.beforeDelete');
    //     ftr_Logger.writeVar('Trigger.old', Trigger.old);
    // }
}