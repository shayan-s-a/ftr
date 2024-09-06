global class ftr_SIPM6CreateCustomerAccountMock implements WebServiceMock {
    global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
         
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {

            ftr_PSRService.createCustomerAccount reqElement = new ftr_PSRService.createCustomerAccount();
            ftr_PSRService.createCustomerAccountResponse respElement = new ftr_PSRService.createCustomerAccountResponse();
            ftr_PSRService.createCustomerAccountResponseType psrRespType = new ftr_PSRService.createCustomerAccountResponseType();
            //System.debug('Test');
            List<ftr_PSRService.StatusMessageType> statusMsgList = new List<ftr_PSRService.StatusMessageType>();
            ftr_PSRService.CreateCustomerAccountResult resultType = new ftr_PSRService.CreateCustomerAccountResult();

            ftr_PSRService.StatusMessageType statusMsg = new ftr_PSRService.StatusMessageType();
            statusMsg.code = '0';
            statusMsg.message = 'Success';
            statusMsg.severity = 'Info';
            statusMsgList.add(statusMsg);

            resultType.custAcctNbr = '3170849';

            psrRespType.statusMessage = statusMsgList;
            psrRespType.createCustomerAccountResult = resultType;

            respElement.createCustomerAccountReturnValue = psrRespType;
            Map<String, ftr_PSRService.createCustomerAccountResponse> response_map_x = new Map<String, ftr_PSRService.createCustomerAccountResponse>();
            
            response.put('response_x', respElement);

        }
}