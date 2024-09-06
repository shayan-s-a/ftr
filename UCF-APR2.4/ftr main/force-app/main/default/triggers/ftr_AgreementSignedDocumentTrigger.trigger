/*
** Class Name:
** Created Date: 2021-06-26
** Created By: Vinod kakantala of EagleCreek
** Description:
** Version: 1
** History:
** 2021-06-17: Class created date
*/
trigger ftr_AgreementSignedDocumentTrigger on echosign_dev1__SIGN_Agreement__c (after update) {
    list<echosign_dev1__SIGN_Agreement__c>agrementlist = new list<echosign_dev1__SIGN_Agreement__c>();
    list<echosign_dev1__SIGN_Agreement__c>agrementdeclinelist = new list<echosign_dev1__SIGN_Agreement__c>();
    list<echosign_dev1__SIGN_Agreement__c>agrementdraftlist = new list<echosign_dev1__SIGN_Agreement__c>();
     list<echosign_dev1__SIGN_Agreement__c>agrementofstlist = new list<echosign_dev1__SIGN_Agreement__c>();
     list<echosign_dev1__SIGN_Agreement__c>agrementwcalist = new list<echosign_dev1__SIGN_Agreement__c>();
    
    for(echosign_dev1__SIGN_Agreement__c sa: trigger.New){
        if(sa.echosign_dev1__Status__c=='Signed'){
           agrementlist.add(sa); 
        }if(sa.echosign_dev1__Status__c=='Cancelled / Declined'){
                agrementdeclinelist.add(sa); 
            }if(sa.echosign_dev1__Status__c=='Draft'){
                agrementdraftlist.add(sa);
            }if(sa.echosign_dev1__Status__c=='Out for Signature'){
                agrementofstlist.add(sa);
            }if(sa.echosign_dev1__Status__c=='Waiting for Counter-Approval'){
                agrementwcalist.add(sa);
            }
        
    }
    if(agrementlist!=null && agrementlist.size()>0){
        //Call Helper Class
        ftr_AgreementSignedDocumentTriggerHelper.CreateContractDocument(agrementlist);
    }if(agrementdeclinelist!=null && agrementdeclinelist.size()>0){
        ftr_AgreementSignedDocumentTriggerHelper.UpdateContractStatus(agrementdeclinelist);
    }if(agrementdraftlist!=null && agrementdraftlist.size()>0){
        ftr_AgreementSignedDocumentTriggerHelper.UpdateContractDocumentStatus(agrementdraftlist);
    }
    if(agrementofstlist!=null && agrementofstlist.size()>0){
        ftr_AgreementSignedDocumentTriggerHelper.UpdateContractDocumentofsStatus(agrementofstlist);
    }
    if(agrementwcalist!=null && agrementwcalist.size()>0){
        ftr_AgreementSignedDocumentTriggerHelper.UpdateContractDocumentwcaStatus(agrementwcalist);
    }
    
    
    
}