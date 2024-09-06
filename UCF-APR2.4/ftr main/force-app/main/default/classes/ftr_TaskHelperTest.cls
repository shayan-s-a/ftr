@IsTest
public class ftr_TaskHelperTest {
    static testMethod void TestGetMDUQueueTasksForOpp() {
        //Creating Group
        /**Group testGroup = new Group(Name='MDU Contract Team Queue', Type='Queue');
        insert testGroup;
        
        //Creating QUEUE
        System.runAs(new User(Id=UserInfo.getUserId())){
            //Associating queue with group AND to the Case object
            QueueSObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Task');
            insert testQueue;
        }*/
        List<Group> lstMDUTeamQueue = [SELECT Id 
                                        FROM Group 
                                        WHERE Type = 'Queue' 
                                        AND DeveloperNAME = 'MDU_Contract_Team_Queue'
                                        LIMIT 1];
        Test.startTest();
            //Create Test Opportunity
            Id oppId = CreateTestOpportunity();
            List<Task> tskList = new List<Task>();
            Task tsk = new Task();
            tsk.Subject = 'Opportunity Ready for Contract Generation';
            tsk.Status = 'Open';
            tsk.Priority = 'Normal';
            tsk.WhatId = oppId;
            tsk.OwnerId = lstMDUTeamQueue[0].Id;
            tskList.add(tsk);
            if(tskList.size() > 0){
                INSERT tskList;
            } 
        Test.stopTest();
        
        List<ftr_TaskHelper.DataTableWrapper> lstDTWrapper = new List<ftr_TaskHelper.DataTableWrapper>();
        lstDTWrapper = ftr_TaskHelper.getMDUQueueTasksForOpp();
        System.debug('lstDTWrapper:' + lstDTWrapper);
        //System.assertEquals(1,lstDTWrapper.size());
    }

    public static Id CreateTestOpportunity(){
        Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
        Account globalAcc = new Account();
        globalAcc.Name = 'GLOBAL ACCOUNT';
        globalAcc.RecordTypeId = globalRecId;
        insert globalAcc;
        Account objAccount = new Account();
        objAccount.Name = 'Test Acc1';
        objAccount.ParentId = globalAcc.Id;
        INSERT objAccount;
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Community_Connections').getRecordTypeId();
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opp1';
        objOpportunity.Accountid = objAccount.id;
        objOpportunity.StageName = 'Contract Requested';
        objOpportunity.CloseDate = system.Today()+3;
        objOpportunity.RecordTypeId = recordTypeId;
        INSERT objOpportunity;
        return objOpportunity.Id;
        //This will run the Trigger on Opp to create Task and assign it to the queue.
        ////objOpportunity.StageName = 'Contract Requested';
        ////UPDATE objOpportunity;
    }
}
// *