trigger SandboxRefreshEventDispatcher on SandboxRefreshEvent__e (after insert) {
    
    // only run this if it is a sandbox
    if ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox || Test.isRunningTest()) {
        // trigger is configured to process 1 event at a time
        Integer minute = Datetime.now().addMinutes(15).minute();
        String cronString = '0 ' + minute + ' * * * ?'; // Starting 15m from now, run hourly.  Job will self-cancel once successful.
        ftr_PrepareSandboxSchedulable job = new ftr_PrepareSandboxSchedulable();
        System.schedule('Sandbox Setup', cronString, job);
    }
}