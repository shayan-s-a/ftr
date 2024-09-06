public class AsyncCBTSIntegration implements Queueable,Database.AllowsCallouts {
    private String orderId;

    public AsyncCBTSIntegration(String orderId) {
        this.orderId = orderId;
    }

    public void execute(QueueableContext context) {
        String procedureName = 'FTR_CBTSIntegration';
    Map<String, Object> ipInput = new Map <String, Object> ();
    ipInput.put('order_id', orderId);
    Map <String, Object> ipOutput = new Map <String, Object> ();
    Map <String, Object> ipOptions = new Map <String, Object> ();
    ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
    system.debug('CBTS result'+ipOutput);
    }
}