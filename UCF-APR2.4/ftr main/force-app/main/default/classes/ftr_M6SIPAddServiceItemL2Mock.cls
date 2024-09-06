@isTest
global class ftr_M6SIPAddServiceItemL2Mock implements WebServiceMock {
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

                ftr_PSRService.addServiceItem reqElement = new ftr_PSRService.addServiceItem();
                ftr_PSRService.addServiceItemResponse respElement = new ftr_PSRService.addServiceItemResponse();
                ftr_PSRService.addServiceItemResponseValueType RespType = new ftr_PSRService.addServiceItemResponseValueType();

                List<ftr_PSRService.StatusMessageType> statusMsgList = new List<ftr_PSRService.StatusMessageType>();
                ftr_PSRService.addServiceItemResultType resultType = new ftr_PSRService.addServiceItemResultType();

                ftr_PSRService.StatusMessageType statusMsg = new ftr_PSRService.StatusMessageType();
                statusMsg.code = '0';
                statusMsg.message = 'Success';
                statusMsg.severity = 'Info';
                statusMsgList.add(statusMsg);

                resultType.serviceItemId = 7558935;
                resultType.documentNumber = 3170849;
                resultType.itemSpecificationId = 1112;
                resultType.itemAlias = 'UNI';
                resultType.itemAlias = 'SIP';
                resultType.parentServiceItemId = 7558936;
                resultType.locationId = 0;
                resultType.addressId = 0;

                RespType.statusMessage = statusMsgList;
                RespType.addServiceItemResult = resultType;

                respElement.addServiceItemReturnValue = RespType;
                // *Map<String, ftr_PSRService.addServiceItemResponse> response_map_x = new Map<String, ftr_PSRService.addServiceItemResponse>();
                
                response.put('response_x', respElement);

    }
}