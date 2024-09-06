trigger LeadTrigger on Lead (before insert, before update) {
    system.debug('inside trigger');
    Date dt = DateTime.now().Date();
    List<String> reasons = new List<String>{'No Answer', 'Hang Up - Quick', 'Busy', 'Answering Machine'};
    List<String> q5 = new List<String>{'DM Unavailable'};
    for(Lead l: Trigger.New) {
        string recordtypename = Schema.SObjectType.Lead.getRecordTypeInfosById().get(l.RecordtypeId).getname();
        if(l.Status == 'Open' && String.valueof(l.OwnerId).startsWithIgnoreCase('005') && recordtypename == 'Alt Channel - OTM' && 
           l.Follow_Up_Appt_Date__c < = dt && (reasons.contains(l.Reason_made_with_targeted_account__c) ||
           q5.contains(l.Q5_Outcome_with_non_DM__c))) {
            	l.Follow_Up_Appt_Date__c = dt.addDays(2);
                l.Number_of_Attempts_on_date__c = (l.Number_of_Attempts_on_date__c == null)? 1 : l.Number_of_Attempts_on_date__c+1;
        }
    }
}