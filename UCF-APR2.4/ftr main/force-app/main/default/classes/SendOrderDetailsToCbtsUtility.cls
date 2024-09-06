public class SendOrderDetailsToCbtsUtility {
    public static Boolean CBTS_EXECUTED = false;
    public static Map<String, VendorJsonSNE__c> vendorSNEMap = new Map<String, VendorJsonSNE__c>();
    public static Physical_Site__c objPhysSite;
    /* CBTS - Vyshnavi Starts */
    @future(callout=true)
    public static void postToCBTS(Id orderId) {
        try {
            Order objOrder = [SELECT ID, name, OpportunityId, Type, OrderNumber, Description, vlocity_cmt__DefaultServiceAccountId__c,
                              BillingCity, BillingStreet, BillingState, BillingPostalCode, Account.Name, DGF__c, DGF__r.UNI_2_Physical_Medium__c, DGF__r.Topology__c,
                              DGF__r.Site_access_Contact__c, DGF__r.Site_Access_Contact_Email__c, DGF__r.Site_Access_Contact_Phone__c,
                              DGF__r.Customer_Contact_Phone__c, DGF__r.Customer_Contact__c, DGF__r.Customer_Contact_Email__c, DGF__r.Address_Space__c,
                              DGF__r.Physical_Site__r.Service_Address_City__c, DGF__r.Physical_Site__r.Service_Address_Postal_Code__c, DGF__r.Physical_Site__r.Service_Address_State__c, DGF__r.Physical_Site__r.Service_Address_Street__c, 
                              Implementor_PM__c, Implementor_PM__r.Name, Implementor_PM__r.OM_Phone_Number__c, Implementor_PM__r.Email,
                              Network_Project_Specialist__c, Network_Project_Specialist__r.Name, Network_Project_Specialist__r.OM_Phone_Number__c, Network_Project_Specialist__r.Email,
                              Order_Point_of_Contact__c, Order_Point_of_Contact__r.Name, Order_Point_of_Contact__r.OM_Phone_Number__c, Order_Point_of_Contact__r.Email
                              FROM ORDER WHERE OrderNumber != null AND Id =: orderId LIMIT 1];
            objPhysSite = fetchPhysSite(objOrder);
            /*if (objOrder.DGF__c == null || objOrder.DGF__r.Topology__c == null || objPhysSite == null) {
                return;
            }*/
            processPostToCBTS(new List<Order>{objOrder});
        } catch (Exception ex) {
            
        }
    }
    public static void processPostToCBTS(List<Order> orderList) {
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Id> orderToOppMap = new Map<Id, Id>();
        Map<Id, List<OpportunityLineItem>> oppOLIMap = new Map<Id, List<OpportunityLineItem>>();
        
        for (Order objOrder : orderList) {
            oppIds.add(objOrder.OpportunityId);
            orderToOppMap.put(objOrder.Id, objOrder.OpportunityId);
        }
        fetchSNEMap();
        if (!oppIds.isEmpty()) {
            for (OpportunityLineItem objOLI : [SELECT Id, Service_Address__c,  OpportunityId, Product2.Name, Product2.Product_ID__c, Term_Months__c, vlocity_cmt__Action__c, Quantity, Speed__c,
                                               vlocity_cmt__LineNumber__c, SNE_Code_MRC__c, Product_Description__c
                                               FROM OpportunityLineItem WHERE OpportunityId IN: oppIds AND Product_Description__c Like '%MNS%']) {
                                                   if (vendorSNEMap.containsKey(objOLI.Product2.Name.toLowerCase())) {
                                                        if (oppOLIMap.containsKey(objOLI.OpportunityId)) {
                                                            List<OpportunityLineItem> lstOLI = oppOLIMap.get(objOLI.OpportunityId);
                                                            lstOLI.add(objOLI);
                                                            oppOLIMap.put(objOLI.OpportunityId, lstOLI);
                                                        } else {
                                                            oppOLIMap.put(objOLI.OpportunityId, new List<OpportunityLineItem>{objOLI});
                                                        }
                                                	}
                                               }
        }
        if (oppOLIMap.isEmpty()) {
            return;
        }
        
        for (Order objOrder : orderList) {
            OrderCBTSWrapper orderWrapper = new OrderCBTSWrapper();
            List<OpportunityLineItem> lstOLI = oppOLIMap.containsKey(objOrder.OpportunityId) ? oppOLIMap.get(objOrder.OpportunityId) : new List<OpportunityLineItem>();
            fetchOrderWrapper(objOrder, lstOLI);
        }
    }
    public static void fetchOrderWrapper(Order objOrder, List<OpportunityLineItem> lstOLI) {
        OrderCBTSWrapper orderWrapper = new OrderCBTSWrapper();
        orderWrapper.SFOrder = fetchSFOrder(objOrder, lstOLI);
        
        system.debug('orderWrapper==> ' + JSON.serialize(orderWrapper));
        if (orderWrapper != null) {
            postToCBTS(orderWrapper, objOrder);
        }
    }
    public static OrderCBTSWrapper.SFOrder fetchSFOrder(Order objOrder, List<OpportunityLineItem> lstOLI) {
        OrderCBTSWrapper.SFOrder wrapper = new OrderCBTSWrapper.SFOrder();
        wrapper.OrderSpecialRequirements = objOrder.Description;
        wrapper.OrderType = 'New Installation';
        wrapper.SFOrderDetails = fetchSFOrderDetails(objOrder, lstOLI);
        wrapper.SFOrderNumber = objOrder.OrderNumber;
        return wrapper;
    }
    public static OrderCBTSWrapper.SFOrderDetails fetchSFOrderDetails(Order objOrder, List<OpportunityLineItem> lstOLI) {
        OrderCBTSWrapper.SFOrderDetails wrapper = new OrderCBTSWrapper.SFOrderDetails();
        OrderCBTSWrapper.OrderLineItems wrapperOrderLineItems = new OrderCBTSWrapper.OrderLineItems();
        wrapperOrderLineItems.OrderItem = fetchOrderItems(objOrder, lstOLI);
        wrapper.OrderLineItems = wrapperOrderLineItems;
        wrapper.customerAccount = fetchCusAccInfo(objOrder);
        return wrapper;
    }
    public static List<OrderCBTSWrapper.OrderItem> fetchOrderItems(Order objOrder, List<OpportunityLineItem> lstOLI) {
        List<OrderCBTSWrapper.OrderItem> oliWrapper = new List<OrderCBTSWrapper.OrderItem>();
        for (OpportunityLineItem objOLI : lstOLI) {
            OrderCBTSWrapper.OrderItem wrapper = new OrderCBTSWrapper.OrderItem();
            wrapper.LocationContactName = objOrder.DGF__r.Site_access_Contact__c;
            wrapper.LocationContactEmail = objOrder.DGF__r.Site_Access_Contact_Email__c;
            wrapper.LocationContactTN = objOrder.DGF__r.Site_Access_Contact_Phone__c;
            wrapper.LocationSpecialRequirements = objOLI.Service_Address__c;
            wrapper.product = fetchProductDetails(objOLI, objorder);
            wrapper.action = objOLI.vlocity_cmt__Action__c;
            wrapper.termInMonths = objOLI.Term_Months__c != null ? String.valueOf(objOLI.Term_Months__c) + ' ' + 'Months' : '';
            wrapper.quantity = objOLI.Quantity;
            wrapper.addressService = fetchAddressService(objOrder);
            oliWrapper.add(wrapper);
        }
        if (objOrder.DGF__r.Address_Space__c != null && String.isNotBlank(objOrder.DGF__r.Address_Space__c)) {
            oliWrapper.add(fetchCustomProduct(objOrder));
        }
        return oliWrapper;
    }
    public static OrderCBTSWrapper.OrderItem fetchCustomProduct(Order objOrder) {
        OrderCBTSWrapper.OrderItem wrapper = new OrderCBTSWrapper.OrderItem();
        wrapper.LocationContactName = objOrder.DGF__r.Site_access_Contact__c;
        wrapper.LocationContactEmail = objOrder.DGF__r.Site_Access_Contact_Email__c;
        wrapper.LocationContactTN = objOrder.DGF__r.Site_Access_Contact_Phone__c;
        OrderCBTSWrapper.Product prodWrapper = new OrderCBTSWrapper.Product();
        prodWrapper.IPblock = objOrder.DGF__r.Address_Space__c;
        prodWrapper.productTopology = objOrder.DGF__r.Topology__c;
        prodWrapper.productName = 'IP';
        if (prodWrapper.IPblock != null) {
            prodWrapper.productId = vendorSNEMap.containsKey(prodWrapper.IPblock) ? vendorSNEMap.get(prodWrapper.IPblock).SE__c : prodWrapper.productId;
        }
        wrapper.product = prodWrapper;
        wrapper.addressService = fetchAddressService(objOrder);
        return wrapper;
    }
    public static Physical_Site__c fetchPhysSite(Order objOrder) {
        Physical_Site__c objSite;
        try {
            objSite = [SELECT Id, Service_Address_Postal_Code__c, Service_Address_State__c,
                                                Service_Address_City__c, Service_Address_Street__c  FROM Physical_Site__c 
                WHERE DGF__c =: objOrder.DGF__c AND Service_Address_Postal_Code__c != null AND Service_Address_State__c != null 
                AND Service_Address_City__c != NULL AND Service_Address_Street__c != null LIMIT 1];
        } catch (Exception rx) {
            
        }
        return objSite;
    }
    public static OrderCBTSWrapper.addressService fetchAddressService(Order objOrder) {
        OrderCBTSWrapper.addressService objAddressService = new OrderCBTSWrapper.addressService();
        try {
            if (objOrder.DGF__c != null && objPhysSite != null) {
                //Physical_Site__c objPhysSite = [SELECT Id, Service_Address_Postal_Code__c, Service_Address_State__c,
                                               // Service_Address_City__c,Service_Address_Street__c  FROM Physical_Site__c WHERE DGF__c =: objOrder.DGF__c LIMIT 1];
                /*objAddressService.zipCode = objOrder.DGF__r.Physical_Site__r.Service_Address_Postal_Code__c;
                objAddressService.stateCode = objOrder.DGF__r.Physical_Site__r.Service_Address_State__c;
                objAddressService.cityName = objOrder.DGF__r.Physical_Site__r.Service_Address_City__c;
                objAddressService.streetAddress = objOrder.DGF__r.Physical_Site__r.Service_Address_Street__c;*/
                objAddressService.zipCode = objPhysSite.Service_Address_Postal_Code__c;
                objAddressService.stateCode = objPhysSite.Service_Address_State__c;
                objAddressService.cityName = objPhysSite.Service_Address_City__c;
                objAddressService.streetAddress = objPhysSite.Service_Address_Street__c;
            }
        } catch (Exception ex) {
            
        }
        return objAddressService;
    }
    public static OrderCBTSWrapper.Product fetchProductDetails(OpportunityLineItem objOLI, Order objOrder) {
        OrderCBTSWrapper.Product prodWrapper = new OrderCBTSWrapper.Product();
        prodWrapper.productName = objOLI.Product_Description__c;
        if (String.isNotBlank(objOLI.Product2.Name)) {
            String description = objOLI.Product2.Name.toLowerCase();
            prodWrapper.productId = vendorSNEMap.containsKey(description) ? vendorSNEMap.get(description).SE__c : prodWrapper.productId;
            prodWrapper.productBandwidth = vendorSNEMap.containsKey(description) ? vendorSNEMap.get(description).Speed__c : prodWrapper.productBandwidth;
        }
        prodWrapper.lineItemNumber = objOLI.vlocity_cmt__LineNumber__c;
        prodWrapper.productPhysicalMedium = objOrder.DGF__r.UNI_2_Physical_Medium__c;
        //prodWrapper.IPblock = objOrder.DGF__r.Address_Space__c;
        prodWrapper.productTopology = objOrder.DGF__r.Topology__c;
        return prodWrapper;
    }
    public static OrderCBTSWrapper.CustomerAccount fetchCusAccInfo(Order objOrder) {
        OrderCBTSWrapper.CustomerAccount objCustomerAccount = new OrderCBTSWrapper.CustomerAccount();
        objCustomerAccount.MasterCustomer = fetchMasCustInfo(objOrder);
        objCustomerAccount.FTRContactInformation = fetchFTRContactInformation(objOrder);
        return objCustomerAccount;
    }
    public static OrderCBTSWrapper.MasterCustomer fetchMasCustInfo(Order objOrder) {
        OrderCBTSWrapper.MasterCustomer  objMasterCustomer = new OrderCBTSWrapper.MasterCustomer();
        OrderCBTSWrapper.MasterCustomerDetails  objMasterCustomerDetails = new OrderCBTSWrapper.MasterCustomerDetails();
        objMasterCustomerDetails.MasterCustomerAddress = fetchMasterCustomerAddress(objOrder);
        objMasterCustomerDetails.CustomerContactInformation = fetchCustomerContactInformation(objOrder);
        objMasterCustomerDetails.MasterCustomerName = objOrder.Account.Name;
        objMasterCustomer.MasterCustomerDetails = objMasterCustomerDetails;
        return objMasterCustomer;
    }
    public static OrderCBTSWrapper.MasterCustomerAddress fetchMasterCustomerAddress(Order objOrder) {
        OrderCBTSWrapper.MasterCustomerAddress objMasterCustomerAddress = new OrderCBTSWrapper.MasterCustomerAddress();
        OrderCBTSWrapper.AddressService objAddressService = new OrderCBTSWrapper.AddressService();
        objAddressService.cityName = objOrder.BillingCity;
        objAddressService.zipCode = objOrder.BillingPostalCode;
        objAddressService.stateCode = objOrder.BillingState;
        objAddressService.StreetAddress = objOrder.BillingStreet;
        objMasterCustomerAddress.addressLegal = objAddressService;
        return objMasterCustomerAddress;
    }
    public static OrderCBTSWrapper.CustomerContactInformation fetchCustomerContactInformation(Order objOrder) {
        OrderCBTSWrapper.CustomerContactInformation objCustomerContactInformation = new OrderCBTSWrapper.CustomerContactInformation();
        objCustomerContactInformation.OrderContactTN = objOrder.Order_Point_of_Contact__r.OM_Phone_Number__c;	
        objCustomerContactInformation.TechnicalContactTN = objOrder.DGF__r.Customer_Contact_Phone__c;
        objCustomerContactInformation.TechnicalContactEmail = objOrder.DGF__r.Customer_Contact_Email__c;
        objCustomerContactInformation.TechnicalContactName = objOrder.DGF__r.Customer_Contact__c;
        objCustomerContactInformation.OrderContactEmail = objOrder.Order_Point_of_Contact__r.Email;
        objCustomerContactInformation.OrderContactName = objOrder.Order_Point_of_Contact__r.Name;
        return objCustomerContactInformation;
    }
    public static OrderCBTSWrapper.FTRContactInformation fetchFTRContactInformation(Order objOrder) {
        OrderCBTSWrapper.FTRContactInformation objFTRContactInformation = new OrderCBTSWrapper.FTRContactInformation();
        objFTRContactInformation.FTRProjectManagerTN = objOrder.Implementor_PM__r.OM_Phone_Number__c;
        objFTRContactInformation.FTRProjectManagerName = objOrder.Implementor_PM__r.Name;
        objFTRContactInformation.FTRImplementationSpecialistTN = objOrder.Network_Project_Specialist__r.OM_Phone_Number__c;
        objFTRContactInformation.FTRImplementationSpecialistEmail = objOrder.Network_Project_Specialist__r.Email;
        objFTRContactInformation.FTRProjectManagerEmail = objOrder.Implementor_PM__r.Email;
        objFTRContactInformation.FTRImplementationSpecialistName = objOrder.Network_Project_Specialist__r.Name;
        return objFTRContactInformation;
    }
    
    public static void postToCBTS(OrderCBTSWrapper orderWrapper, Order objOrder) {
        system.debug('postToCBTS ==> ' );
        HttpRequest req = new HttpRequest();
        //req.setEndpoint('https://ky93livxf5.execute-api.us-east-2.amazonaws.com/createorder/testorder');
        req.setEndpoint(getCBTSEndpoint());
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        //req.setHeader('x-api-key', 'idC1O5mJDY2m3sPiGFDSt6dfaUJjG8hC3085aSv3');
        req.setHeader('x-api-key', getCBTSAPIKey());
        req.setBody(JSON.serialize(orderWrapper));
        Http httpCls = new Http();
        HttpResponse response = httpCls.send(req);
        system.debug('response ==> ' + response.getStatusCode());
        system.debug('response ==> ' + response.getBody());
        createAPILog(req, response, objOrder);
        if (response.getStatusCode() == 200) {
            OrderCBTSResponse cbtsResponse = (OrderCBTSResponse)JSON.deserialize(response.getBody(), OrderCBTSResponse.class);
            createVendorServiceOrder(cbtsResponse, objOrder);
        }
    }
    public static void createAPILog(HttpRequest objReq, HTTPResponse objResponse, Order objOrder) {
        try {
            String status = objResponse.getStatusCode() == 200 ? 'Success' : 'Error';
            API_Log__c apiLog = new API_Log__c(
                    Request__c = objReq.getBody(),
                    Response__c = objResponse.getBody(),
                    Interface__c = 'CBTSCreateOrder',
                    System__c = 'CBTS',
                    Status__c = status,
                    RelatedTo__c = objOrder.Id,
                    OrderNumber__c = objorder.OrderNumber);
        	insert apiLog;
        } catch (Exception ex) {
            
        }
    }
    public static void createVendorServiceOrder(OrderCBTSResponse cbtsResponse, Order objOrder) {
        try {
            if (cbtsResponse != null && cbtsResponse.SFOrderFA != null && cbtsResponse.SFOrderFA.SFOrderFADetails != null && 
                (cbtsResponse.SFOrderFA.SFOrderFADetails.FAStatusCode != null || cbtsResponse.SFOrderFA.SFOrderFADetails.FAStatusCode == '200' || cbtsResponse.SFOrderFA.SFOrderFADetails.FAStatusCode == '409')) {
                Service_Order__c vendorOrder = new Service_Order__c(RecordTypeId = Schema.SObjectType.Service_Order__c.getRecordTypeInfosByDeveloperName().get('Vendor_Order').getRecordTypeId());
            	vendorOrder.Order__c = objOrder.Id;
                vendorOrder.Vendor_Name__c = cbtsResponse.SFOrderFA.VendorName;
                vendorOrder.Vendor_Order_Type__c = cbtsResponse.SFOrderFA.OrderType;
                vendorOrder.Order_Status_Date__c = cbtsResponse.SFOrderFA.SFOrderFADetails.FAStatusDate != null ? fetchDate(cbtsResponse.SFOrderFA.SFOrderFADetails.FAStatusDate) : null;
                //vendorOrder.Order_Status_Date__c = cbtsResponse.SFOrderFA.SFOrderFADetails.FAStatusDate != null ? Date.parse(cbtsResponse.SFOrderFA.SFOrderFADetails.FAStatusDate.replaceAll('/', '-')) : null;
                //vendorOrder.Order_Status_Date__c = Date.today();
                vendorOrder.Vendor_Order_Status__c = cbtsResponse.SFOrderFA.SFOrderFADetails.FAStatus;
                vendorOrder.Description__c = cbtsResponse.SFOrderFA.SFOrderFADetails.FAStatus;
                system.debug('vendorOrder ==> ' + vendorOrder);
                insert vendorOrder;
                system.debug('vendorOrder ==> ' + vendorOrder);
            } 
        } catch (Exception ex) {
            
        }
    }
    public static Date fetchDate(String objDate) {
        List<String> dateArr = objDate != null  ? objDate.split('/') : new List<String>();
        return Date.newInstance(Integer.valueOf(dateArr[0]), Integer.valueOf(dateArr[1]), Integer.valueOf(dateArr[2]));
    }
    public static void fetchSNEMap() {
        for (VendorJsonSNE__c objSNE : [SELECT Id, Long_Description__c, Speed__c, SE__c FROM VendorJsonSNE__c WHERE Long_Description__c != null]) {
            vendorSNEMap.put(objSNE.Long_Description__c.toLowerCase(), objSNE);
        }
    }
    private static String getCBTSAPIKey() {
        String apiKey = '';
        WS_ESB_Settings__c esbSettings = WS_ESB_Settings__c.getInstance();
        apiKey = esbSettings.CBTS_API_Key__c;
        return apiKey; //uncomment this before deployment
    }
    private static String getCBTSEndPoint() {
        String endpoint = '';
        WS_ESB_Settings__c esbSettings = WS_ESB_Settings__c.getInstance();
        endpoint = esbSettings.CBTS_Order_Endpoint__c;
        return endpoint; //uncomment this before deployment
    }
    /* CBTS - Vyshnavi Ends */
}