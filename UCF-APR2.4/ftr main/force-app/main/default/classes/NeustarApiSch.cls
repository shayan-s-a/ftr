global class NeustarApiSch implements Schedulable {
    
    public String callingLocation = '';
    public NeustarApiSch(String callingLocation){
        this.callingLocation = callingLocation;
    }
    
    global void execute(SchedulableContext SC) {
        if(callingLocation == 'NewUpdatedAccount') database.executeBatch(new NeustarApiBatch('NewUpdatedAccount'),1);
        if(callingLocation == 'ExistingND') database.executeBatch(new NeustarApiBatch('ExistingND'),1);
    }
}