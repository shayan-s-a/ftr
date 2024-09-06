@isTest
private class ftr_SubmitUCFOrder_Test {
    @isTest
    static void testCreateTechnicalProduct() {
        // Test data setup
        // UCF_DID_DPI_Services
        Map<String, String> mapProductNameCode = new Map<String, String>();
        mapProductNameCode.put('UCF Basic', 'UCF_BASIC_LIC');
        mapProductNameCode.put('UCF DID DPI Services', 'UCF_DID_DPI_Services');
        mapProductNameCode.put('UCF Poly Edge 450', 'UCF_POLY_EDGE_E450');
        mapProductNameCode.put('UCF Poly Edge E EM', 'UCF_POLY_EDGE_EEM');
        mapProductNameCode.put('UCF Call Recording Basic', 'UCF_CR_BASIC');
        
        List<Order> liOrders = ftr_TestDataFactory.getOrders(2);
        insert liOrders;
        
        Product2 prod = new Product2(Name = 'UCF Poly Edge 450',
                                    ProductCode = mapProductNameCode.get('UCF Poly Edge 450'),
                                    vlocity_cmt__EffectiveDate__c = System.today(),
                                    IsActive = true);
        insert prod;
        
        List<OrderItem> liOrderItems = ftr_TestDataFactory.getOrderItems(4, mapProductNameCode);
        
        for(OrderItem orderItem :liOrderItems) {
            orderItem.OrderId = liOrders[0].Id;
        }
        
        insert liOrderItems;
        
        List<ftr_DID_Location_Details__c> didLocationDetails = new List<ftr_DID_Location_Details__c>();
        
        for (Integer i = 0; i < liOrders.size(); i++) {
            ftr_DID_Location_Details__c didLocationDetail = new ftr_DID_Location_Details__c();
            didLocationDetail.OrderId__c = liOrders[i].Id;
            
            // Set other fields of didLocationDetail as needed
            // ...
            
            didLocationDetails.add(didLocationDetail);
        }
        
        insert didLocationDetails;
        
        ftr_DID_Number_Details__c newNumberDetail1 = new ftr_DID_Number_Details__c();
        newNumberDetail1.DIDLocationDetailsId__c = didLocationDetails[0].Id;
        newNumberDetail1.Ucf_Number_Use__c = 'Toll Free';
        newNumberDetail1.Ucf_Install_Type__c = 'New DID Range';
        newNumberDetail1.MDN_Checkbox__c = false;
        newNumberDetail1.DID_Number__c = '123' ;
        newNumberDetail1.Ucf_License_Type__c = 'UCF Basic';
        newNumberDetail1.Ucf_Device_Type__c = 'Yealink T31G';
        newNumberDetail1.Ucf_Device_Accessories__c = 'Yealink UH36 Dual Headset';    
        newNumberDetail1.Ucf_Screen_Recording__c='Yes';
        insert newNumberDetail1;
        
        ftr_DID_Number_Details__c newNumberDetail2 = new ftr_DID_Number_Details__c();
        newNumberDetail2.DIDLocationDetailsId__c = didLocationDetails[0].Id;
        newNumberDetail2.Ucf_Number_Use__c = 'Auto Attendant';
        newNumberDetail2.Ucf_Install_Type__c = 'Existing';
        newNumberDetail2.MDN_Checkbox__c = false;
        newNumberDetail2.DID_Number__c = '987' ;
        newNumberDetail2.Ucf_License_Type__c = 'UCF Basic';
        newNumberDetail2.Ucf_Device_Type__c = 'Yealink T31G';
        newNumberDetail2.Ucf_Device_Accessories__c = 'Yealink UH36 Dual Headset';
        newNumberDetail2.Ucf_Screen_Recording__c='Yes';
        insert newNumberDetail2;
        
        ftr_DID_Number_Details__c newNumberDetail3 = new ftr_DID_Number_Details__c();
        newNumberDetail3.DIDLocationDetailsId__c = didLocationDetails[0].Id;
        newNumberDetail3.Ucf_Number_Use__c = 'Auto Attendant';
        newNumberDetail3.Ucf_Install_Type__c = 'New DID Range';
        newNumberDetail3.MDN_Checkbox__c = false;
        newNumberDetail3.DID_Number__c = '123' ;
        newNumberDetail3.Ucf_License_Type__c = 'UCF Basic';
        newNumberDetail3.Ucf_Device_Type__c = 'Yealink T31G';
        newNumberDetail3.Ucf_Device_Accessories__c = 'Yealink UH36 Dual Headset';
        newNumberDetail3.Ucf_Collaboration__c = '';
         newNumberDetail3.Ucf_Webinar__c ='';
         newNumberDetail3.Ucf_Screen_Recording__c='Yes';
          newNumberDetail3.Ucf_Storage__c='1 Year';
        
        
        insert newNumberDetail3;
        
        
        Test.startTest();
        ftr_SubmitUCFOrder obj = new ftr_SubmitUCFOrder();
        obj.createTechnicalProduct(liOrders[0].Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void testUpdateOrderLineItems() {
        
        Map<String, String> mapProductNameCode = new Map<String, String>();
        mapProductNameCode.put('UCF Basic', 'UCF_BASIC_LIC ');
        mapProductNameCode.put('UCF DID DPI Services', 'UCF_DID_DPI_Services');
        mapProductNameCode.put('UCF Poly Edge 450', 'UCF_POLY_EDGE_E450');
        mapProductNameCode.put('UCF DC 711', 'UCF_DC_711');
        mapProductNameCode.put('UCF Poly Edge E EM', 'UCF_POLY_EDGE_EEM');
        
        Product2 prod = new Product2(Name = 'UCF DC 711',
                                    ProductCode = mapProductNameCode.get('UCF DC 711'),
                                    vlocity_cmt__EffectiveDate__c = System.today(),
                                    IsActive = true);
        insert prod;
        List<Order> liOrders = ftr_TestDataFactory.getOrders(2);
        insert liOrders;
        
        List<OrderItem> liOrderItems = ftr_TestDataFactory.getOrderItems(4, mapProductNameCode);
        
        for(OrderItem orderItem :liOrderItems) {
            orderItem.OrderId = liOrders[0].Id;
            orderItem.vlocity_cmt__ServiceAccountId__c = liOrders[0].AccountId; 
        }
        
        insert liOrderItems;
        
        List<ftr_DID_Location_Details__c> didLocationDetails = new List<ftr_DID_Location_Details__c>();
        
        for (Integer i = 0; i < liOrders.size(); i++) {
            ftr_DID_Location_Details__c didLocationDetail = new ftr_DID_Location_Details__c();
            didLocationDetail.OrderId__c = liOrders[i].Id;
            didLocationDetail.ServiceAccountId__c=liOrderItems[0].vlocity_cmt__ServiceAccountId__c;
            didLocationDetails.add(didLocationDetail);
        }
        
        insert didLocationDetails;
        
        ftr_DID_Number_Details__c newNumberDetail1 = new ftr_DID_Number_Details__c();
        newNumberDetail1.DIDLocationDetailsId__c = didLocationDetails[0].Id;
        newNumberDetail1.Ucf_Number_Use__c = 'Toll Free';
        newNumberDetail1.Ucf_Install_Type__c = 'New DID Range';
        newNumberDetail1.MDN_Checkbox__c = true;
        newNumberDetail1.DID_Number__c = '123' ;
        newNumberDetail1.Ucf_License_Type__c = 'UCF Basic';
        newNumberDetail1.Ucf_Device_Type__c = 'Yealink T31G';
        newNumberDetail1.Ucf_Device_Accessories__c = 'Yealink UH36 Dual Headset'; 
        newNumberDetail1.Ucf_Collaboration__c = '';
         newNumberDetail1.Ucf_Webinar__c ='';
         newNumberDetail1.Ucf_Screen_Recording__c='Yes';
          newNumberDetail1.Ucf_Storage__c='1 Year';
        insert newNumberDetail1;
        
        
        Test.startTest();
        ftr_SubmitUCFOrder.updateOrderLineItems(liOrders[0].Id);
        Test.stopTest();
        
    }
}