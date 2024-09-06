public without sharing class ApprovalProcessHelper {
    
    public static void autoSubmitAndApprove(String contextId) {
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Auto Submitting for approval.');
        req1.setObjectId(contextId);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
        // Approve the submitted request
        // First, get the ID of the newly created item
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        // Instantiate the new ProcessWorkitemRequest object and populate it
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Auto Approving request.');
        req2.setAction('Approve');
        
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
        
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req2);
    }
    
    public static void submitToDealDesk(Id quoteId){
         List<ProcessInstanceWorkitem> processItems = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: quoteId];
       			for (ProcessInstanceWorkitem item:processItems ){
                	Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        			req.setAction('Reject');       
        			req.setWorkitemId(item.Id);
   					Approval.process(req);
                }
                //update quote
                Quote q = new Quote(Id = quoteId);
                q.ftr_Approval_Type__c = 'Deal Desk';
        		q.Approval_Status__c = 'Pending Approval - Pricing';
                update q;
                //create a new approval
                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                approvalRequest.setObjectId(quoteId);
                //approvalRequest.setProcessDefinitionNameorId('Approval process name');
                Approval.ProcessResult result = Approval.process(approvalRequest);
    }
}