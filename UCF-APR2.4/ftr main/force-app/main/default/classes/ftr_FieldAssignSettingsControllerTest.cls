@IsTest
public class ftr_FieldAssignSettingsControllerTest {
    
    @IsTest
    static void mainTest(){
        
        Test.startTest();
        ftr_FieldAssignmentSettingsController.getRecords();
        ftr_FieldAssignmentSettingsController.getPicklistValues();
        ftr_FieldAssignmentSettingsController.saveRecord(
            JSON.serialize(new Map<String, Object>{
                'DeveloperName' => 'Test',
                'MasterLabel' => 'Test',
                'IsAutomationEnabled__c' => true,
                'ExcludedOrderStages__c' => new List<String> {
                   'Complete',
                   'New',
                   'Cancelled',
                   'Completed'
                } 
            })
        );
        Test.stopTest();
        
    }
}
