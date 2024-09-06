/********************************************************************************************
Name : ContractUtility
Created By : Mohan Talluri (mohan.talluri@ftr.com)
Created Date : June 10, 2016
Description :  Utility to support Contract Trigger Handler.
********************************************************************************************/

public with sharing class ContractUtility {
    
    public static void setICBFlag(List<Contract> crtList){
        
        Boolean flag = false;
        Opportunity Opp;
        list <OpportunityLineItem> Oli;
        
        for (Contract C : crtList){
            flag = false;
            
            //Assign the Contract name with Agreement Type
            if(C.Agreement_Type__c != null)
            	C.Name = C.Agreement_Type__c;
            
            if ((C.CustomerSignedDate <> null) && (C.CompanySignedDate <> null)) {
                
                Opp = [SELECT id, NRC__c, MRR_Amount__c, name, Contract_MRR__c, Pricebook2Id 
                       FROM Opportunity where id =: C.Opportunity__c];                                                                                    
                Oli = [SELECT UnitPrice, product_price__c, lineItem__c, Contract_MRR__c, Renewal_MRR__c, Total_MRR__c,
                       NRC_Price__c,CPE_NRC_Price__c, OpportunityId, Description FROM OpportunityLineItem where OpportunityId =: Opp.Id];    
                
                for (OpportunityLineItem O : Oli) {
                    if (O.product_price__c  <> O.UnitPrice)              
                        flag = true;              
                }
            }
            
            if (flag)
                C.ICB_Flag__c = 'Y';
         }           
    }   
    
}