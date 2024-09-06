/**
 * @description       :
 * @author            : Monir Zaman
 * @group             :
 * @last modified on  : 28-09-2023
 * @last modified by  : Mnir Zaman
 * @version           : 4
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   13-09-2023   Monir Zaman   Initial Version
 **/
@isTest
public with sharing class aps_VlocityQuoteHandler_Test {
  @isTest
  static void testVlocityQuoteHandle() {
    Id globalRecId = [
      SELECT id, name, developername
      FROM recordtype
      WHERE sobjecttype = 'account' AND developername = 'global'
      LIMIT 1
    ]
    ?.Id;

    Account globalAcc1 = new Account(
      Name = 'GLOBAL ACCOUNT',
      RecordTypeId = globalRecId
    );
    insert globalAcc1;

    Id MasterRTId = [
      SELECT id
      FROM RecordType
      WHERE RecordType.Name = 'Master' AND SobjectType = 'Account'
    ]
    .Id;

    Account testSAccount = new Account(
      RecordTypeId = MasterRTId,
      ParentId = globalAcc1.Id,
      Name = 'Test Service Account',
      BillingStreet = '123 Main Street',
      BillingCity = 'Anywhere',
      BillingState = 'Ohio',
      BillingPostalCode = '44088',
      ShippingStreet = '123 Main Street',
      ShippingCity = 'Anywhere',
      ShippingState = 'Ohio',
      ShippingPostalCode = '44088'
    );
    insert testSAccount;

    Opportunity opp = new Opportunity(
      Name = 'RefreshTestOpp',
      AccountId = testSAccount.Id,
      CloseDate = Date.newInstance(2019, 5, 11),
      StageName = 'Investigating',
      CPE_Product__c = 'No'
    );
    insert opp;

    Id pricebookId = Test.getStandardPricebookId();
    List<Product2> lstProduct2 = new List<Product2>();

    Product2 product = new Product2(
      Name = 'EIA',
      ProductCode = 'ENT_ETH_EIA_0001',
      IsActive = true
    );
    insert product;

    PricebookEntry standardPrice = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = product.Id,
      UnitPrice = 100,
      IsActive = true
    );
    insert standardPrice;

    Quote oQuote = new Quote(
      Name = 'Testing Quote',
      OpportunityId = Opp.Id,
      Pricebook2Id = pricebookId
    );
    insert oQuote;

    QuoteLineItem oQLI = new QuoteLineItem(
      QuoteId = oQuote.Id,
      PricebookEntryId = standardPrice.Id,
      vlocity_cmt__ServiceAccountId__c = testSAccount.Id,
      Quantity = 1,
      UnitPrice = 34.50,
      Term__c = '36 Months',
      vlocity_cmt__Product2Id__c = product.Id,
      Product2Id = product.Id,
      Agreement_Type__c = 'Broadband FiberOptic & Voice Bundles - New Service',
      Schedule_Type__c = 'FiberOptic & OneVoice Nationwide (copper)'
    );
    insert oQLI;

    OpportunityLineItem oli1 = new OpportunityLineItem(
      vlocity_cmt__JSONAttribute__c = '{ "FTR_ENT_PRI_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h000002mZebAAE", "attributeid__c": "a7b0h000000buCRAAY", "attributecategoryid__c": "a7a0h000000blVFAAY", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_BANDWIDTH", "attributeconfigurable__c": true, "attributedisplaysequence__c": "10", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Speed", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Y8a0000019SAiEAM", "isrequired__c": true, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "isnotassetizable__c": false, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "sequence": 23, "value": "30 Mbps", "displayText": "30 Mbps", "id": "14414b0c-98a4-9c39-1a98-ba04a2e7dcd9" }, { "sequence": 50, "value": "200 Mbps", "displayText": "200 Mbps", "id": "250ff27d-186d-262e-6604-ccb548815ce5" }, { "sequence": 40, "value": "100 Mbps", "displayText": "100 Mbps", "id": "4c03d782-90e7-d359-0c4c-b847a4d13547" }, { "sequence": 10, "value": "10 Mbps", "displayText": "10 Mbps", "id": "6af9a9e5-dff5-0f51-223e-f149d256851c" }, { "sequence": 30, "value": "50 Mbps", "displayText": "50 Mbps", "id": "71166878-186e-3b66-49ae-dcd659204939" }, { "sequence": 26, "value": "40 Mbps", "displayText": "40 Mbps", "id": "8178d30d-0ad0-b5af-f206-bc7c6ac80128" }, { "sequence": 100, "value": "10 Gbps", "displayText": "10 Gbps", "id": "8d73c46f-2012-73de-a911-49a814b5dc33" }, { "sequence": 20, "value": "20 Mbps", "displayText": "20 Mbps", "id": "8d9a9bd8-a090-0531-c54b-be76521934dc" }, { "sequence": 5, "value": "5 Mbps", "displayText": "5 Mbps", "id": "a1f88383-489b-617b-796b-db618d5841c6" }, { "sequence": 90, "value": "5 Gbps", "displayText": "5 Gbps", "id": "a76232eb-c1cf-60e7-e95b-7267bd13c5ec" }, { "sequence": 70, "value": "1 Gbps", "displayText": "1 Gbps", "id": "bfd7e3ad-26a4-26d7-3c04-499855b76c53" }, { "sequence": 60, "value": "500 Mbps", "displayText": "500 Mbps", "id": "cbb255c2-9001-4471-a18b-8fadf853c33b" }, { "sequence": 80, "value": "2 Gbps", "displayText": "2 Gbps", "id": "f7fbc8ed-07cd-89e7-e7b3-81703446e4af" } ], "default": [], "selectedItem": { "displayText": "10 Gbps", "id": "8d73c46f-2012-73de-a911-49a814b5dc33", "sequence": 100, "value": "10 Gbps" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h000002mZeaAAE", "attributeid__c": "a7b0h000000buCVAAY", "attributecategoryid__c": "a7a0h000000blVFAAY", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_IP_BLOCKS", "attributeconfigurable__c": true, "attributedisplaysequence__c": "1", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "IP Blocks", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Y8a0000019S2OEAU", "isrequired__c": true, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "isnotassetizable__c": false, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "/22 = 1021 IPs", "sequence": 10, "id": "490d35a9-90db-3601-b96e-b90c7a0731e0", "displayText": "/22 = 1021 IPs" }, { "value": "/23 = 509 IPs", "sequence": 20, "id": "bc7118b2-87ad-1176-9c00-744ea834f65d", "displayText": "/23 = 509 IPs" }, { "value": "/24 = 253 IPs", "sequence": 30, "id": "966a9484-9946-5f49-a32e-83d1a2e3c705", "displayText": "/24 = 253 IPs" }, { "value": "/25 = 125 IPs", "sequence": 40, "id": "a8081c00-7117-7648-6988-c4d198594261", "displayText": "/25 = 125 IPs" }, { "value": "/26 = 61 IPs", "sequence": 50, "id": "830fffb4-db8a-a18e-a4b2-f13c402faa4d", "displayText": "/26 = 61 IPs" }, { "value": "/27 = 29 IPs", "sequence": 60, "id": "705bdef3-ef6c-f170-1401-f575c4ee6fa1", "displayText": "/27 = 29 IPs" }, { "value": "/28 = 13 IPs", "sequence": 70, "id": "62850362-781a-3b21-155f-ed0f9b637cdc", "displayText": "/28 = 13 IPs" }, { "value": "/29 = 5 IPs", "sequence": 80, "id": "7b483b20-bc6d-5720-0cb9-bf67ca83eb98", "displayText": "/29 = 5 IPs" }, { "value": "/30 = 1 IP", "sequence": 90, "id": "b9baf931-9669-e06c-267a-758a30471e36", "displayText": "/30 = 1 IP" } ], "default": [], "selectedItem": { "value": "/25 = 125 IPs", "sequence": 40, "id": "a8081c00-7117-7648-6988-c4d198594261", "displayText": "/25 = 125 IPs" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h000002mZekAAE", "attributeid__c": "a7b0h000000XZGwAAO", "attributecategoryid__c": "a7a0h000000blVFAAY", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_CoS", "attributeconfigurable__c": true, "attributedisplaysequence__c": "30", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Class of Service", "displaysequence__c": "10", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": true, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Y8a0000019S79EAE", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": "Silver", "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "isnotassetizable__c": false, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "default": [ { "displayText": "Silver", "id": "4bd906e9-f059-2a1a-c588-ad08beb5d1e1", "sequence": 10, "value": "Silver" } ], "values": [ { "displayText": "Silver", "id": "4bd906e9-f059-2a1a-c588-ad08beb5d1e1", "sequence": 10, "value": "Silver" }, { "displayText": "Gold", "id": "da9c5b03-49f5-5d55-b41c-b068aa1f2031", "sequence": 20, "value": "Gold" }, { "displayText": "Platinum", "id": "f8d5b838-0867-537e-83a0-a7b710916357", "sequence": 30, "value": "Platinum" } ], "selectedItem": { "displayText": "Silver", "id": "4bd906e9-f059-2a1a-c588-ad08beb5d1e1", "sequence": 10, "value": "Silver" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h000006J2BjAAK", "attributeid__c": "a7b0h0000008UzqAAE", "attributecategoryid__c": "a7a0h000000blVFAAY", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_MIN_BLOCKS", "attributeconfigurable__c": true, "attributedisplaysequence__c": "1", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Minute Blocks", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": true, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Y8a0000019RmmEAE", "isrequired__c": true, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "isnotassetizable__c": false, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "500", "sequence": 10, "id": "8b28bab9-425d-4ff9-6418-f295d607897d", "displayText": "500 Minutes" }, { "value": "1000", "sequence": 20, "id": "b0c22f64-2c8a-f6a5-8824-0a789f41dca3", "displayText": "1000 Minutes" }, { "value": "2500", "sequence": 30, "id": "5015b861-add7-c3d0-22ea-48b9ed62471e", "displayText": "2500 Minutes" }, { "value": "5000", "sequence": 40, "id": "f6833423-cbb8-c11d-14d8-37bb45e737ae", "displayText": "5000 Minutes" }, { "value": "10000", "sequence": 50, "id": "72ca4946-a781-7921-95d6-d9ec04b2b84f", "displayText": "10000 Minutes" }, { "value": "20000", "sequence": 60, "id": "1da430ab-2548-e32c-22f9-bfa7b300492f", "displayText": "20000 Minutes" }, { "value": "40000", "sequence": 70, "id": "14318872-af5b-6d76-a8e7-f7069c1c9801", "displayText": "40000 Minutes" } ], "default": [], "selectedItem": { "value": "5000", "sequence": 40, "id": "f6833423-cbb8-c11d-14d8-37bb45e737ae", "displayText": "5000 Minutes" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h000006J2BjAAK", "attributeid__c": "a7b0h00000007zrAAA", "attributecategoryid__c": "a7a0h000000blVFAAY", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_OVERAGE_RATE", "attributeconfigurable__c": true, "attributedisplaysequence__c": "1", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Overage Rate", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": true, "isconfigurable__c": false, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Y8a0000019RmnEAE", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Text", "value__c": null, "valuedatatype__c": "Text", "valuedescription__c": null, "attributegrouptype__c": null, "isnotassetizable__c": false, "attributeRunTimeInfo": { "dataType": "Text", "uiDisplayType": "Text", "value": "0.037" }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h000006J2DFAA0", "attributeid__c": "a7b0h00000007zsAAA", "attributecategoryid__c": "a7a0h000000blVFAAY", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_PBX_HAND_OFF", "attributeconfigurable__c": true, "attributedisplaysequence__c": "2", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "PBX Hand Off", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Y8a0000019S7lEAE", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "isnotassetizable__c": false, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "SIP", "sequence": 10, "id": "9f5090a3-a162-0815-9990-8a7dc54d0d5d", "displayText": "SIP" }, { "value": "PRI", "sequence": 20, "id": "a45b492f-586f-0870-ccf7-b849f7709701", "displayText": "PRI" }, { "value": "Analog", "sequence": 30, "id": "97335c24-b741-a53b-0303-598a61e2a4bd", "displayText": "Analog" } ], "default": [], "selectedItem": { "value": "SIP", "sequence": 10, "id": "9f5090a3-a162-0815-9990-8a7dc54d0d5d", "displayText": "SIP" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h000006J2BAAA0", "attributeid__c": "a7b0h00000007zpAAA", "attributecategoryid__c": "a7a0h000000blVFAAY", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_INC_LD_BOT", "attributeconfigurable__c": true, "attributedisplaysequence__c": "1", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Included LD Block Of Time", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Y8a0000019RiCEAU", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "isnotassetizable__c": false, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "500", "sequence": 10, "id": "8b28bab9-425d-4ff9-6418-f295d607897d", "displayText": "500 Minutes" }, { "value": "1000", "sequence": 20, "id": "b0c22f64-2c8a-f6a5-8824-0a789f41dca3", "displayText": "1000 Minutes" }, { "value": "2500", "sequence": 30, "id": "5015b861-add7-c3d0-22ea-48b9ed62471e", "displayText": "2500 Minutes" }, { "value": "5000", "sequence": 40, "id": "f6833423-cbb8-c11d-14d8-37bb45e737ae", "displayText": "5000 Minutes" }, { "value": "10000", "sequence": 50, "id": "72ca4946-a781-7921-95d6-d9ec04b2b84f", "displayText": "10000 Minutes" }, { "value": "20000", "sequence": 60, "id": "1da430ab-2548-e32c-22f9-bfa7b300492f", "displayText": "20000 Minutes" }, { "value": "40000", "sequence": 70, "id": "14318872-af5b-6d76-a8e7-f7069c1c9801", "displayText": "40000 Minutes" } ], "default": [], "selectedItem": { "value": "1000", "sequence": 20, "id": "b0c22f64-2c8a-f6a5-8824-0a789f41dca3", "displayText": "1000 Minutes" } }, "$$AttributeDefinitionEnd$$": null }, { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h000006J2C3AAK", "attributeid__c": "a7b0h00000007zmAAA", "attributecategoryid__c": "a7a0h000000blVFAAY", "categorycode__c": "FTR_ENT_PRI_ATTCAT", "categoryname__c": "Pricing Attributes", "attributeuniquecode__c": "ATTR_DID_INC_NUMBER", "attributeconfigurable__c": true, "attributedisplaysequence__c": "1", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "DID Included Number", "displaysequence__c": "null", "categorydisplaysequence__c": 10, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": false, "ishidden__c": true, "valueinnumber__c": null, "objecttype__c": "Product2", "querycode__c": null, "isreadonly__c": true, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Y8a0000019S2bEAE", "isrequired__c": false, "rulemessage__c": null, "uidisplaytype__c": "Text", "value__c": null, "valuedatatype__c": "Text", "valuedescription__c": null, "attributegrouptype__c": null, "isnotassetizable__c": false, "attributeRunTimeInfo": { "dataType": "Text", "uiDisplayType": "Text", "value": "50" }, "$$AttributeDefinitionEnd$$": null } ], "FTR_ENT_TECH_ATTCAT": [ { "$$AttributeDefinitionStart$$": null, "objectid__c": "01t0h000005I8PcAAK", "attributeid__c": "a7b0h0000008YGeAAM", "attributecategoryid__c": "a7a0h000000blVsAAI", "categorycode__c": "FTR_ENT_TECH_ATTCAT", "categoryname__c": "Technical Attributes", "attributeuniquecode__c": "ATTR_FIREWALL", "attributeconfigurable__c": true, "attributedisplaysequence__c": "830", "attributefilterable__c": false, "attributecloneable__c": true, "isactive__c": true, "attributedisplayname__c": "Firewall Model", "displaysequence__c": "20", "categorydisplaysequence__c": 20, "customconfiguitemplate__c": null, "formatmask__c": null, "hasrule__c": false, "isconfigurable__c": true, "ishidden__c": false, "valueinnumber__c": null, "objecttype__c": "vlocity_cmt__ObjectClass__c", "querycode__c": null, "isreadonly__c": false, "isnottranslatable__c": false, "isquerydriven__c": false, "querylabel__c": null, "id": "a7Y8a0000019RhkEAE", "isrequired__c": true, "rulemessage__c": null, "uidisplaytype__c": "Dropdown", "value__c": null, "valuedatatype__c": "Picklist", "valuedescription__c": null, "attributegrouptype__c": null, "isnotassetizable__c": false, "attributeRunTimeInfo": { "dataType": "Picklist", "uiDisplayType": "Dropdown", "values": [ { "value": "60F", "sequence": 10, "id": "1747a631-8515-7c5b-44ca-d64ba45263e7", "displayText": "60F" }, { "value": "100F", "sequence": 20, "id": "d5303899-97f4-f8a7-439c-9e7e5d954e49", "displayText": "100F" }, { "value": "400E", "sequence": 30, "id": "b74a9104-3576-a925-3977-766966919a75", "displayText": "400E" }, { "value": "1000D", "sequence": 40, "id": "a279c570-b8a7-d3c3-9612-441d22fbd61b", "displayText": "1000D" } ], "default": [], "selectedItem": { "value": "400E", "sequence": 30, "id": "b74a9104-3576-a925-3977-766966919a75", "displayText": "400E" } } } ] }',
      OpportunityId = opp.Id,
      Quantity = 1,
      QuoteLineItem__c = oQLI.Id,
      TotalPrice = 10,
      PricebookEntryId = standardPrice.Id,
      Product2Id = product.Id
    );
    insert oli1;

    OpportunityLineItem oli2 = new OpportunityLineItem(
      OpportunityId = opp.Id,
      Quantity = 1,
      QuoteLineItem__c = oQLI.Id,
      TotalPrice = 10,
      PricebookEntryId = standardPrice.Id,
      Product2Id = product.Id,
      UnitPrice = 123.99,
      Id = oli1.Id
    );
    update oli2;
  }
}