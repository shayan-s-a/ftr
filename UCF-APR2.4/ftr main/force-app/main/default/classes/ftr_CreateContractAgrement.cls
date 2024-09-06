/*
** Class Name:ftr_CreateContractAgrement
** Created Date: 2021-06-24
** Created By: Vinod kakantala of EagleCreek
** Description:
**
** History:
** 2021-06-17: Class created date
**/
global class ftr_CreateContractAgrement implements vlocity_cmt.VlocityOpenInterface  {
    public Boolean invokeMethod(String methodName, Map<String,Object> input,Map<String,Object> output,Map<String,Object> options){
        if(methodName.equals('Contractagreement')){
            Contractagreement(input,output,options);
        }
     
        
        
        return true;
    }
public Boolean Contractagreement(Map<String,Object> input,Map<String,Object> output,Map<String,Object> options){
    //string aggid = 'a6G5Y000002djLGUAY';
    //string oppid = '0065Y00001WiM5HQAV';
    string aggid = (Id)input.get('AgreementId');
    string oppid = (Id)input.get('OpportunityId');
    string acctid = (Id)input.get('AccountId');
    list<String> REC_TYPES = new List<String>{'Frontier Services Agreement','Community Connections - Agreement','VZ3 Agreement - VEC','VZ3 Agreement - VES', 'Product Schedule'};//all recordtypes
    list<Contract> contractlist  = [SELECT id,vlocity_cmt__ActiveContractVersionId__c,	Opportunity__c  FROM Contract WHERE (Opportunity__c = :oppid or (AccountId= :acctid AND RecordType.Name = 'Frontier Services Agreement'))  AND RecordType.Name IN: REC_TYPES AND (Contract_Status__c = 'Draft')];
 	set<string>contractversionId= new set<string>();
    for(Contract c : Contractlist){
        contractversionId.add(c.vlocity_cmt__ActiveContractVersionId__c);
    }
    list<vlocity_cmt__ContractVersion__c>contversion = [SELECT id, vlocity_cmt__ContractId__c FROM vlocity_cmt__ContractVersion__c where Id IN :contractversionId];
    set<string>versionid= new set<string>();
    map<string,string>versn2contract = new map<string,string>();
    for(vlocity_cmt__ContractVersion__c cv : contversion){
        versionid.add(cv.id);
        versn2contract.put(cv.vlocity_cmt__ContractId__c,cv.Id);
    }
    map<string,string>versn2attachment = new map<string,string>();
    list<Attachment>attachlist=[SELECT Id,Name,ParentId FROM Attachment where ParentId IN :versionid];
    for(Attachment a : attachlist){
        versn2attachment.put(a.ParentId,a.Name);
        ftr_DocumentAttachmentConverter.convertAttachmentToContent(a.Id,aggid);
    }
    //Passing AttachmentId and AgreementId
    //ftr_DocumentAttachmentConverter.convertAttachmentToContent(attachlist[0].Id,aggid);
    
    //// SELECT Agreement__c,Contract__c,Name FROM Agreement_Contracts__c
    list<Agreement_Contracts__c>listac = new list<Agreement_Contracts__c>();
    for(String conid : versn2contract.keyset()){
        Agreement_Contracts__c acon = new Agreement_Contracts__c();
        acon.Contract__c = conid;
        acon.Name = versn2attachment.get(versn2contract.get(conid));
        acon.Agreement__c=aggid;
        listac.add(acon);
        system.debug('Adding listac@@@@@'+listac);
    }
    
    insert listac;
    system.debug('Insertion listac@@@@@'+listac);
    output.put('BooleanValue', true);
    return true;
}
}