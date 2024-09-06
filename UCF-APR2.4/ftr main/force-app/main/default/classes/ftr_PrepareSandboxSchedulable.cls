/**
 * @description       : Schedulable class for preparing a sandbox
 * @author            : eric.marcondes@ftr.com
**/
public without sharing class ftr_PrepareSandboxSchedulable implements Schedulable {

    public void execute(SchedulableContext schedulableContext) {
        try {
            // ftr_PrepareSandboxService sandboxService = new ftr_PrepareSandboxService();
            ftr_PrepareSandboxService.updateMetadata();
            ftr_PrepareSandboxService.updateDeveloperProfiles();
            ftr_GitlabService.updateClientIdInRepository();
            ftr_PartnerPortalUtilities.createPartnerPortalUser();
            finish();
        } catch (Exception ex) {
            System.debug('An exception occurred while preparing the sandbox: ');
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            finish();
            throw ex;
        }
    }

    private void finish() {
        List<CronTrigger> triggerList = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE 'Sandbox Setup%'
        ];
        for (CronTrigger t : triggerList) {
            System.abortJob(t.Id);
        }
    }
}