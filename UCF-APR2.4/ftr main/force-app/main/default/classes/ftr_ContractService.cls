/**
 *  ContractService(fsa,product schedule).
 * 
 *  @author: Karthikeya koganti
 *  @date: July 20 2020
 */

public class ftr_ContractService {
    
    
    //public static final String FSA_REC_TYPE = 'Frontier Services Agreement';
    public static final List<String> REC_TYPES = new List<String>{'Frontier Services Agreement','Community Connections - Agreement',
        'VZ3 Agreement - VEC','VZ3 Agreement - VES'};
    public class ContractData{
        
        @InvocableVariable
        public Id fsaContractRecordTypeId;
        
        @InvocableVariable
        public Id psContractRecordTypeId;
        
        @InvocableVariable
        public Boolean fsaExists;
        
    }
    
    public static Boolean fsaExists;
    
    @InvocableMethod(label='Check If FSA Exists' category='Vlocity CLM')
    public static List<ContractData> checkIfFSAExisting(List<Id> quoteIds){
        
        Quote quote = [SELECT Id,Name,AccountId FROM Quote WHERE Id =: quoteIds[0]];
        if(fsaExists == null)
        	fsaExists = ![SELECT Id,Name FROM Contract WHERE AccountId =: quote.AccountId AND RecordType.Name IN: REC_TYPES].isEmpty();
        
        List<ContractData> contractData = new List<ContractData>();
        ContractData cd = new ContractData();
       
        cd.fsaExists = fsaExists;
        
        //cd.psContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get(PRODUCT_SCHEDULE_REC_TYPE).getRecordTypeId();
        //cd.fsaContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get(FSA_REC_TYPE).getRecordTypeId();
        
        contractData.add(cd);
        return contractData;
        
        
       // return null;
    }
}