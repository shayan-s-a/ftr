/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class premisesUtilityTest {
    public static testMethod void singleTest(){
        Test.startTest();
        vlocity_cmt__Premises__c vcp = new vlocity_cmt__Premises__c(Name='Test123',vlocity_cmt__StreetAddress__c='123 harrypotter lane',vlocity_cmt__City__c='Dallas',vlocity_cmt__State__c='Texas',vlocity_cmt__PostalCode__c='75182',vlocity_cmt__Country__c='USA');
        insert vcp;
        Blob targetBlob = Blob.valueOf(vcp.vlocity_cmt__StreetAddress__c.toLowerCase()+ ', ' +vcp.vlocity_cmt__City__c.toLowerCase()+ ', ' +vcp.vlocity_cmt__State__c.toLowerCase()+ ', ' +vcp.vlocity_cmt__PostalCode__c+ ', ' +vcp.vlocity_cmt__Country__c);
        Blob hash = Crypto.generateDigest('SHA-256', targetBlob);
        String sha256Hash = EncodingUtil.base64Encode(hash);
        vlocity_cmt__Premises__c vcp2 = [select Key__c,vlocity_cmt__StreetAddress__c,vlocity_cmt__City__c,vlocity_cmt__State__c,vlocity_cmt__PostalCode__c,vlocity_cmt__Country__c from vlocity_cmt__Premises__c where Id=:vcp.Id];
        //system.assertEquals(sha256Hash, vcp2.Key__c);
        vcp2.vlocity_cmt__StreetAddress__c = '124 harrypotter Blvd';
        update vcp2;
        Blob targetBlob2 = Blob.valueOf(vcp2.vlocity_cmt__StreetAddress__c.toLowerCase()+ ', ' +vcp2.vlocity_cmt__City__c.toLowerCase()+ ', ' +vcp2.vlocity_cmt__State__c.toLowerCase()+ ', ' +vcp2.vlocity_cmt__PostalCode__c+ ', ' +vcp2.vlocity_cmt__Country__c);
        Blob hash2 = Crypto.generateDigest('SHA-256', targetBlob2);
        String sha256Hash2 = EncodingUtil.base64Encode(hash2);
        premisesUtility.getPremise(vcp2.vlocity_cmt__StreetAddress__c, vcp2.vlocity_cmt__City__c, vcp2.vlocity_cmt__State__c, vcp2.vlocity_cmt__PostalCode__c, vcp2.vlocity_cmt__Country__c , '');
        vlocity_cmt__Premises__c vcp3 = [select Key__c,vlocity_cmt__StreetAddress__c,vlocity_cmt__City__c,vlocity_cmt__State__c,vlocity_cmt__PostalCode__c,vlocity_cmt__Country__c from vlocity_cmt__Premises__c where Id=:vcp.Id];
        //system.assertEquals(sha256Hash2, vcp3.Key__c);
        delete vcp3; 
        Test.stopTest();
    }
}