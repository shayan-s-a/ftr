global class ftr_SIPM6CreateEndUserLocMock  implements WebServiceMock {
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

            ftr_PSRService.createServiceLocation reqElement = new ftr_PSRService.createServiceLocation();
            ftr_PSRService.createServiceLocationResponse respElement = new ftr_PSRService.createServiceLocationResponse();
            ftr_PSRService.createServiceLocationResponseValueType psrRespType = new ftr_PSRService.createServiceLocationResponseValueType();

            List<ftr_PSRService.StatusMessageType> statusMsgList = new List<ftr_PSRService.StatusMessageType>();
            ftr_PSRService.createServiceLocationResultType resultType = new ftr_PSRService.createServiceLocationResultType();
            //System.debug('Test');
            ftr_PSRService.StatusMessageType statusMsg = new ftr_PSRService.StatusMessageType();
            statusMsg.code = '0';
            statusMsg.message = 'Success';
            statusMsg.severity = 'Info';
            statusMsgList.add(statusMsg);

            resultType.documentNumber = 3170849;

            psrRespType.statusMessage = statusMsgList;
            psrRespType.createServiceLocationResult = resultType;

            respElement.createServiceLocationReturnValue = psrRespType;
            Map<String, ftr_PSRService.createServiceLocationResponse> response_map_x = new Map<String, ftr_PSRService.createServiceLocationResponse>();
            
            response.put('response_x', respElement);

        }
}