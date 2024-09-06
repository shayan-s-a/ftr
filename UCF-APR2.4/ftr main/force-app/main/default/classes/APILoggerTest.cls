/**
 * @description       : This test class covers the following Apex classes:
 *      APILogger.cls                   - publishes the log event
 *      APILoggerEventHandler.trigger   - inserts the log
 *      APILogTrigger.trigger           - calls the handler
 *      APILogTriggerHandler.cls        - calls the task creation service after insert     
 *      TaskCreationService.cls         - creates and assigns tasks using the TaskCreationConfig__mdt 
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class APILoggerTest {
    @TestSetup
    static void makeData(){
        insert ftr_TestDataFactory.getOrders(1);
    }

    @IsTest
    static void methodName(){
        String orderNumber = [SELECT OrderNumber FROM order].OrderNumber;
        Object requestType = '{}';
        Object responseType = '{}';
        String documentNumber = '1';
        String systemName = 'M6';
        String interfaceName = 'test';
        String status = 'Error';
        String endDate = String.valueOf(Date.today());
        String startDate = String.valueOf(Date.today());
        
        Test.startTest();
        Map<String, Object> logOutput = new Map<String, Object>();
        Map<String, Object> logInput = new Map<String, Object> {
            'request' => requestType,
            'response' => responseType,
            'interface' => interfaceName,
            'system' => systemName,
            'status' => status,
            'convertToXML' => false,
            'orderNumber' => orderNumber,
            'documentNumber' => documentNumber
        };
        APILogger log = new APILogger();
        log.invokeMethod('createEntry', logInput, logOutput, logOutput);
        APILogger.getLogs(
            systemName, 
            interfaceName,
            startDate,
            endDate,
            documentNumber,
            status
        );
        APILogger.getPicklistValues();
        Test.stopTest();
        
    }
}