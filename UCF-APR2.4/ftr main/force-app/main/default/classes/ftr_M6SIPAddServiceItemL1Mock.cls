@isTest
global class ftr_M6SIPAddServiceItemL1Mock implements WebServiceMock {
    global void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType){

            ftr_PSRService.addServiceItem request_x = new ftr_PSRService.addServiceItem();
            //*request_x.addServiceItemRequest = addServiceItemRequest;
            
            ftr_PSRService.addServiceItemResponseValueType respValType = new ftr_PSRService.addServiceItemResponseValueType();
            ftr_PSRService.addServiceItemResponse svcItemResp = new ftr_PSRService.addServiceItemResponse();
            ftr_PSRService.addServiceItemResultType resultType = new ftr_PSRService.addServiceItemResultType();
            
            Map<String, ftr_PSRService.addServiceItemResponse> response_map_x = new Map<String, ftr_PSRService.addServiceItemResponse>();
            List<ftr_PSRService.StatusMessageType> statusMsgList = new List<ftr_PSRService.StatusMessageType>();
            ftr_PSRService.StatusMessageType statusMsg = new ftr_PSRService.StatusMessageType();

            statusMsg.code = '0';
            statusMsg.message = 'Success';
            statusMsg.severity = 'Info';
            statusMsgList.add(statusMsg);

            resultType.serviceItemId=234567;

            respValType.statusMessage=statusMsgList;
            respValType.addServiceItemResult=resultType;
            
            svcItemResp.addServiceItemReturnValue=respValType;

            response.put('response_x',svcItemResp);
            }
        }