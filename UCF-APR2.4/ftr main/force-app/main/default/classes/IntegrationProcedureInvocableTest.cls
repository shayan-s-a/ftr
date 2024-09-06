@isTest
public class IntegrationProcedureInvocableTest {
    @isTest
    static void testRunIntegrationServiceInvocable() {
        IntegrationProcedureInvocable.IntegrationProcedureInput inputRecord = new IntegrationProcedureInvocable.IntegrationProcedureInput();
        inputRecord.procedureAPIName = 'TestProcedure';
        inputRecord.input = 'TestInput';
        
        List<IntegrationProcedureInvocable.IntegrationProcedureInput> inputList = new List<IntegrationProcedureInvocable.IntegrationProcedureInput>();
        inputList.add(inputRecord);
        
        List<IntegrationProcedureInvocable.IntegrationProcedureOutput> result = IntegrationProcedureInvocable.runIntegrationServiceInvocable(inputList);
        
        System.assertEquals(1, result.size());
        IntegrationProcedureInvocable.IntegrationProcedureOutput outputRecord = result[0];
        System.assertNotEquals(null, outputRecord.output); // Ensure that output is not null
        
    }
    
}