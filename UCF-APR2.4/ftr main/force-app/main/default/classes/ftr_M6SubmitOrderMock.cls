@isTest
global class ftr_M6SubmitOrderMock implements WebServiceMock {
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

                ftr_PSRService.finishOrder reqElement = new ftr_PSRService.finishOrder();
                ftr_PSRService.finishOrderResponse respElement = new ftr_PSRService.finishOrderResponse();
                ftr_PSRService.finishOrderResponseValueType RespType = new ftr_PSRService.finishOrderResponseValueType();

                List<ftr_PSRService.StatusMessageType> statusMsgList = new List<ftr_PSRService.StatusMessageType>();
                ftr_PSRService.finishOrderResultType resultType = new ftr_PSRService.finishOrderResultType();

                ftr_PSRService.StatusMessageType statusMsg = new ftr_PSRService.StatusMessageType();
                statusMsg.code = '0';
                statusMsg.message = 'Success';
                statusMsg.severity = 'Info';
                statusMsgList.add(statusMsg);

                resultType.documentNumber = 3170849;
                resultType.message = 'success';

                RespType.statusMessage = statusMsgList;
                RespType.finishOrderResult = resultType;

                respElement.finishOrderReturnValue = RespType;
                // *Map<String, ftr_PSRService.finishOrderResponse> response_map_x = new Map<String, ftr_PSRService.finishOrderResponse>();
                
                response.put('response_x', respElement);

    }
}