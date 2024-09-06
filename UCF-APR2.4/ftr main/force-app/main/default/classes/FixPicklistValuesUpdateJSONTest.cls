/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class FixPicklistValuesUpdateJSONTest {

    @isTest static void testIfJsonUpdated() {

        //String nsp = ApplicationUtilities.getNameSpacePrefix();
        String nsp = '';
        List<ApexClass> classList = [SELECT Name, NameSpacePrefix FROM ApexClass WHERE Name = 'VlocityOpenInterface' LIMIT 1];                
        if(classList.size() > 0) {                  
            nsp = classList[0].NameSpacePrefix + '__';                
        }               

        //Id objectRTId = ObjectTypesService.getRecordTypeId(nsp + 'ObjectClass__c', 'Object');
        //Id objectTypeRTId = ObjectTypesService.getRecordTypeId(nsp + 'ObjectClass__c', 'ObjectType');

        Id objectRTId;
        List<RecordType> rt = [SELECT Id FROM RecordType WHERE IsActive = TRUE AND SobjectType = 'vlocity_cmt__ObjectClass__c' AND DeveloperName = 'Object'];
        if (rt != null && !rt.isEmpty()){
            objectRTId = rt[0].Id;
        }

        Id objectTypeRTId;
        List<RecordType> rtType = [SELECT Id FROM RecordType WHERE IsActive = TRUE AND SobjectType = 'vlocity_cmt__ObjectClass__c' AND DeveloperName = 'ObjectType'];
        if (rtType != null && !rtType.isEmpty()){
            objectTypeRTId = rtType[0].Id;
        }

        
        vlocity_cmt__ObjectClass__c productObjectClass = new vlocity_cmt__ObjectClass__c(Name='ProductObjectClass', vlocity_cmt__ObjectApiName__c='Product2', RecordTypeId=objectRTId);
        insert productObjectClass;

        vlocity_cmt__ObjectClass__c ocObjectClass = new vlocity_cmt__ObjectClass__c(Name='OCObjectClass', vlocity_cmt__ObjectApiName__c='vlocity_cmt__ObjectClass__c', RecordTypeId=objectRTId);
        insert ocObjectClass;

        vlocity_cmt__ObjectClass__c productObjectType = new vlocity_cmt__ObjectClass__c(Name='ProductObjectType', vlocity_cmt__ObjectApiName__c='Product2', RecordTypeId=objectTypeRTId, vlocity_cmt__RootObjectClassId__c=productObjectClass.Id);
        insert productObjectType;

        Product2 prod = new Product2(Name = 'Test Product', vlocity_cmt__ObjectTypeId__c = productObjectType.Id);
        prod.vlocity_cmt__JSONAttribute__c = '{\"CategoryYS\":[{\"$$AttributeDefinitionStart$$\":null,\"vlocity_cmt__objectid__c\":\"01t4P000009AMdTQAW\",\"vlocity_cmt__attributeid__c\":\"a094P00001w6t8vQAA\",\"vlocity_cmt__attributecategoryid__c\":\"a084P000023TcvKQAS\",\"vlocity_cmt__categorycode__c\":\"ATTR1\",\"vlocity_cmt__categoryname__c\":\"ATTR1\",\"vlocity_cmt__attributeuniquecode__c\":\"ATTR1\",\"vlocity_cmt__attributeconfigurable__c\":true,\"vlocity_cmt__attributedisplaysequence__c\":\"1\",\"vlocity_cmt__attributefilterable__c\":true,\"vlocity_cmt__attributecloneable__c\":true,\"vlocity_cmt__isactive__c\":true,\"vlocity_cmt__attributedisplayname__c\":\"ATTR1\",\"vlocity_cmt__displaysequence__c\":\"null\",\"vlocity_cmt__categorydisplaysequence__c\":1,\"vlocity_cmt__customconfiguitemplate__c\":null,\"vlocity_cmt__formatmask__c\":null,\"vlocity_cmt__hasrule__c\":false,\"vlocity_cmt__isconfigurable__c\":true,\"vlocity_cmt__ishidden__c\":false,\"vlocity_cmt__valueinnumber__c\":null,\"vlocity_cmt__objecttype__c\":\"Product2\",\"vlocity_cmt__querycode__c\":null,\"vlocity_cmt__isreadonly__c\":false,\"vlocity_cmt__isnottranslatable__c\":false,\"vlocity_cmt__isquerydriven__c\":false,\"vlocity_cmt__querylabel__c\":null,\"id\":\"a1n4P000004fVP2QAM\",\"vlocity_cmt__isrequired__c\":false,\"vlocity_cmt__rulemessage__c\":null,\"vlocity_cmt__uidisplaytype__c\":\"Dropdown\",\"vlocity_cmt__value__c\":null,\"vlocity_cmt__valuedatatype__c\":\"Picklist\",\"vlocity_cmt__valuedescription__c\":null,\"vlocity_cmt__attributegrouptype__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Picklist\",\"uiDisplayType\":\"Dropdown\",\"values\":[{\"displayText\":\"Dealer\",\"id\":\"fec702a4-68b0-7edb-9643-0997f49aba75\",\"sequence\":1,\"value\":\"Dealer\"}],\"default\":[]},\"$$AttributeDefinitionEnd$$\":null}]}';
        insert prod;

        List<Id> prodIds = new List<Id> { prod.Id };

        vlocity_cmt__Picklist__c p = new vlocity_cmt__Picklist__c(vlocity_cmt__Code__c = 'Channel', vlocity_cmt__DataType__c = 'Text', vlocity_cmt__IsActive__c = true, Name = 'Channel', vlocity_cmt__Description__c = 'Description before changing');
        insert p;

        vlocity_cmt__PicklistValue__c pl1 = new vlocity_cmt__PicklistValue__c(vlocity_cmt__Code__c = 'Dealer', vlocity_cmt__IsActive__c = true, vlocity_cmt__PicklistId__c = p.Id, vlocity_cmt__TextValue__c = 'Dealer', vlocity_cmt__Abbreviation__c = 'Dealer');
        insert pl1; 

        vlocity_cmt__AttributeCategory__c attrCat = new vlocity_cmt__AttributeCategory__c(Name = 'attrCat', vlocity_cmt__Code__c = 'ATTRCAT', vlocity_cmt__DisplaySequence__c = 1);
        insert attrCat;

        vlocity_cmt__Attribute__c attr1 = new vlocity_cmt__Attribute__c(Name = 'ATTR1', vlocity_cmt__Code__c = 'ATTR1', vlocity_cmt__AttributeCategoryId__c = attrCat.Id, vlocity_cmt__PicklistId__c = p.Id); 
        insert attr1;
        
        vlocity_cmt__AttributeAssignment__c attributeAssignment = new vlocity_cmt__AttributeAssignment__c(
                Name='Picklist',  
                vlocity_cmt__IsConfigurable__c = true,  
                vlocity_cmt__IsReadOnly__c = false, 
                vlocity_cmt__ValueDataType__c = 'Picklist', 
                vlocity_cmt__ValidValuesData__c = '[{"id":1,"displayText":"Dealer","value":"Dealer","isEditable":false,"isDefault":false}]', 
                vlocity_cmt__UIDisplayType__c = 'Dropdown',
                vlocity_cmt__ObjectId__c = prod.Id, 
                vlocity_cmt__AttributeId__c = attr1.Id, 
                vlocity_cmt__AttributeCategoryId__c = attrCat.Id,
                vlocity_cmt__PicklistId__c = p.Id);

        insert attributeAssignment;


        vlocity_cmt__ObjectFieldAttribute__c ofa1 = new vlocity_cmt__ObjectFieldAttribute__c(Name='ofa1', vlocity_cmt__AttributeId__c=attr1.Id, vlocity_cmt__SubclassId__c=productObjectType.Id, vlocity_cmt__ObjectClassId__c=productObjectType.Id, vlocity_cmt__ObjectType__c='vlocity_cmt__ObjectClass__c');
        insert ofa1;

        Product2 Product2 = [SELECT Id, vlocity_cmt__JSONAttribute__c from Product2 WHERE Id =: prod.Id];

        pl1.vlocity_cmt__TextValue__c = 'New Dealer';
        update pl1;

        Test.startTest();

        Boolean refreshProdsJSONAttr = true;
        List<Id> productIds = new List<Id>();

        productIds.add(prod.Id);
        Database.executeBatch(new FixPicklistValuesUpdateJSON(productIds, refreshProdsJSONAttr));

        Test.stopTest();

        Product2 newProduct = [SELECT Id, vlocity_cmt__JSONAttribute__c from Product2 WHERE Id =: prod.Id];
        String jsonAttrStr = newProduct.vlocity_cmt__JSONAttribute__c;
        Map<String, Object> jsonAttrMap = (Map<String, Object>)JSON.deserializeUntyped(jsonAttrStr);
        
        List<Object> attrCatList = (List<Object>)jsonAttrMap.get('ATTRCAT');
        Map<String, Object> eachObMap = (Map<String, Object>)JSON.deserializeUntyped((JSON.serialize(attrCatList[0])));
        String attrRunTimeInfo = (String) JSON.serialize(eachObMap.get('attributeRunTimeInfo'));
        
        Map<String, Object> attrRunTimeInfoMap = (Map<String, Object>) JSON.deserializeUntyped(attrRunTimeInfo);
        
        String values = (String) JSON.serialize(attrRunTimeInfoMap.get('values'));
        List<Object> valuesList = (List<Object>) JSON.deserializeUntyped(values);
        
        Map<String, Object> valuesMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(valuesList[0]));
        System.debug(valuesMap.get('value'));
        
        System.assertEquals('New Dealer', valuesMap.get('value'));
    }
}