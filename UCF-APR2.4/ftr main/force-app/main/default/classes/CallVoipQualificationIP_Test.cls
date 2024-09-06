@isTest
global class CallVoipQualificationIP_Test {
    
    @isTest(SeeAllData=true)
    static public void test_VoipQualificationIP1()
    {
        ftr_VOIP_Qualification__c voip = [SELECT Id, NPA__c, NXX__c FROM ftr_VOIP_Qualification__c LIMIT 1];
        String npa = String.valueOf(voip.NPA__c.format()) ;
        String nxx = String.valueOf(voip.NXX__c.format()) ;
        String name = 'xyz';
        system.debug(npa + ' - ' + nxx);
        
        Test.startTest();
        Map<String,Object> ipResponse = CallVoipQualificationIP.QualifyVoip(npa,nxx, 'xyz');
        Test.stopTest();
        
        System.assertNotEquals(NULL, ipResponse);
    }
}