/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 5 
**/
@isTest
public class ftr_PSRServiceTest {
    
    @isTest
    public static void ftrPsrServiceTest(){
        ftr_PSRService.PSRServicePort psrService = new ftr_PSRService.PSRServicePort();
        Test.startTest();
        Test.setMock(WebServiceMock.class, new ftr_PSRMockServiceImpl());
        psrService.createEndUserLocation(new ftr_PSRService.endUserLocationType());
        psrService.finishOrder(new ftr_PSRService.finishOrderRequestType());
        psrService.createDisconnectPsr(new ftr_PSRService.createDisconnectPsrRequestType());
        psrService.ping();
        psrService.assignProvPlan(new ftr_PSRService.assignProvPlanRequestType());
        psrService.createSuppToUpdateOrderDueDate(new ftr_PSRService.createSuppToUpdateDueDateRequestType());
        psrService.addOrderNotes(new ftr_PSRService.addOrderNotesRequestType());
        psrService.queryCustomerAccount(new ftr_PSRService.queryCustomerAccountRequestType());
        psrService.createSuppToCancelPsr(new ftr_PSRService.createSuppToCancelPsrRequestType());
        psrService.createServiceLocation(new ftr_PSRService.createServiceLocationRequestType());
        psrService.addServiceItem(new ftr_PSRService.addServiceItemRequestType());
        psrService.getOrderStatus(new ftr_PSRService.orderStatusRequestType());
        psrService.assignPreOrderProvPlan(new ftr_PSRService.assignPreOrderProvPlanRequestType());
        psrService.queryServiceLocation(new ftr_PSRService.queryServiceLocationRequestType());
        psrService.createCustomerAccount(new ftr_PSRService.createCustomerAccountRequestType());
        psrService.createShellPsr(new ftr_PSRService.createShellPsrRequestType());
        
        new ftr_PSRService.locationType();
        new ftr_PSRService.contactType();
        new ftr_PSRService.createSuppToUpdateDueDateResultType();
        new ftr_PSRService.queryCustomerAccountResultType();
        new ftr_PSRService.finishOrderResultType();
        new ftr_PSRService.createLocationResultType();
        new ftr_PSRService.orderStatusResultType();
        new ftr_PSRService.assignProvPlanResultType();
        new ftr_PSRService.dbObjBase();
        new ftr_PSRService.addressType();
        new ftr_PSRService.orderStatusType();
        new ftr_PSRService.addOrderNotesResultType();
        new ftr_PSRService.userDataType();
        new ftr_PSRService.StatusMessageType();
        new ftr_PSRService.createSuppToCancelPsrResultType();
        new ftr_PSRService.serviceItemValueType();
        new ftr_PSRService.customAttributeType();
        new ftr_PSRService.batchMember();
        new ftr_PSRService.CreateCustomerAccountResult();
        new ftr_PSRService.networkLocationType();
        new ftr_PSRService.addServiceItemResultType();
        new ftr_PSRService.createServiceLocationResultType();
        new ftr_PSRService.createPsrResultType();
        new ftr_PSRService.queryServiceLocationResultType();
        
        
        Test.stopTest();
        
        
    }
}