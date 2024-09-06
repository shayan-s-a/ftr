@isTest
global class ftr_M6CreatePSRMock implements WebServiceMock {
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

                ftr_PSRService.createShellPsr reqElement = new ftr_PSRService.createShellPsr();
                ftr_PSRService.createShellPsrResponse respElement = new ftr_PSRService.createShellPsrResponse();
                ftr_PSRService.createPsrResponseType psrRespType = new ftr_PSRService.createPsrResponseType();

                List<ftr_PSRService.StatusMessageType> statusMsgList = new List<ftr_PSRService.StatusMessageType>();
                ftr_PSRService.createPsrResultType resultType = new ftr_PSRService.createPsrResultType();

                ftr_PSRService.StatusMessageType statusMsg = new ftr_PSRService.StatusMessageType();
                statusMsg.code = '0';
                statusMsg.message = 'Success';
                statusMsg.severity = 'Info';
                statusMsgList.add(statusMsg);

                resultType.documentNumber = 3170849;

                psrRespType.statusMessage = statusMsgList;
                psrRespType.createPsrResult = resultType;

                respElement.createPsrReturnValue = psrRespType;
                Map<String, ftr_PSRService.createShellPsrResponse> response_map_x = new Map<String, ftr_PSRService.createShellPsrResponse>();
                
                response.put('response_x', respElement);

            }
}