/**
 * @description       : SandboxPostCopy class for preparing a sandbox
 * @author            : eric.marcondes@ftr.com
**/
global class ftr_PrepareSandbox implements SandboxPostCopy {

    global void runApexClass(SandboxContext context) {

        EventBus.publish(new SandboxRefreshEvent__e());
    }

}