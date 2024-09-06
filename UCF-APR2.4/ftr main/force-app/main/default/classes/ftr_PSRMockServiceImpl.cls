global class ftr_PSRMockServiceImpl implements WebServiceMock {
    global void doInvoke(  
        Object stub,  
        Object request,  
        Map<string, object> response,  
        String endpoint,  
        String soapAction,  
        String requestName,  
        String responseNS,  
        String responseName,  
        String responseType) {  
            
            /*  *ftr_PSRServices MOCK */
            if(requestName.equalsIgnoreCase('createEndUserLocation')){
                ftr_PSRService.createEndUserLocationResponse respElement = new ftr_PSRService.createEndUserLocationResponse();
                respElement.createLocationReturnValue = new ftr_PSRService.createLocationResponseValueType();
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('finishOrder')){
                ftr_PSRService.finishOrderResponse respElement = new ftr_PSRService.finishOrderResponse();
                respElement.finishOrderReturnValue = new ftr_PSRService.finishOrderResponseValueType();
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('createDisconnectPsr')){
                ftr_PSRService.createDisconnectPsrResponse respElement = new ftr_PSRService.createDisconnectPsrResponse();
                respElement.createPsrReturnValue = new ftr_PSRService.createPsrResponseType();
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('ping')){
                ftr_PSRService.pingResponse respElement = new ftr_PSRService.pingResponse();
                respElement.return_x = 'test';
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('assignProvPlan')){
                ftr_PSRService.assignProvPlanResponse respElement = new ftr_PSRService.assignProvPlanResponse();
                respElement.assignProvPlanReturnValue = new ftr_PSRService.assignProvPlanResponseValueType();
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('createSuppToUpdateOrderDueDate')){
                ftr_PSRService.createSuppToUpdateOrderDueDateResponse respElement = new ftr_PSRService.createSuppToUpdateOrderDueDateResponse();
                respElement.createSuppToUpdateDueDateReturnValue = new ftr_PSRService.createSuppToUpdateDueDateResponseValueType();
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('addOrderNotes')){
                ftr_PSRService.addOrderNotesResponse respElement = new ftr_PSRService.addOrderNotesResponse();
                respElement.addOrderNotesReturnValue = new ftr_PSRService.addOrderNotesResponseValueType();
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('queryCustomerAccount')){
                ftr_PSRService.queryCustomerAccountResponse respElement = new ftr_PSRService.queryCustomerAccountResponse();
                respElement.queryCustomerAccountReturnValue = new ftr_PSRService.queryCustomerAccountResponseValueType();
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('createSuppToCancelPsr')){
                ftr_PSRService.createSuppToCancelPsrResponse respElement = new ftr_PSRService.createSuppToCancelPsrResponse();
                respElement.createSuppToCancelPsrReturnValue = new ftr_PSRService.createSuppToCancelPsrResponseValueType();
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('createServiceLocation')){
                ftr_PSRService.createServiceLocationResponse respElement = new ftr_PSRService.createServiceLocationResponse();
                respElement.createServiceLocationReturnValue = new ftr_PSRService.createServiceLocationResponseValueType();
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('addServiceItem')){
                ftr_PSRService.addServiceItemResponse respElement = new ftr_PSRService.addServiceItemResponse();
                respElement.addServiceItemReturnValue = new ftr_PSRService.addServiceItemResponseValueType();
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('getOrderStatus')){
                ftr_PSRService.getOrderStatusResponse respElement = new ftr_PSRService.getOrderStatusResponse();
                respElement.orderStatusReturnValue = new ftr_PSRService.orderStatusResponseValueType();
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('assignPreOrderProvPlan')){
                ftr_PSRService.assignPreOrderProvPlanResponse respElement = new ftr_PSRService.assignPreOrderProvPlanResponse();
                respElement.assignProvPlanReturnValue = new ftr_PSRService.assignProvPlanResponseValueType();
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('queryServiceLocation')){
                ftr_PSRService.queryServiceLocationResponse respElement = new ftr_PSRService.queryServiceLocationResponse();
                respElement.queryServiceLocationReturnValue = new ftr_PSRService.queryServiceLocationResponseValueType();
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('createCustomerAccount')){
                ftr_PSRService.createCustomerAccountResponse respElement = new ftr_PSRService.createCustomerAccountResponse();
                respElement.createCustomerAccountReturnValue = new ftr_PSRService.createCustomerAccountResponseType();
                response.put('response_x', respElement);
            }
            else if(requestName.equalsIgnoreCase('createShellPsr')){
                ftr_PSRService.createShellPsrResponse respElement = new ftr_PSRService.createShellPsrResponse();
                respElement.createPsrReturnValue = new ftr_PSRService.createPsrResponseType();
                response.put('response_x', respElement);
            }
        }
    
}