public class ftr_CLMAgreementTriggerHandler{
    
    public static void updateContractStatus(Set<Id> agreementIdSet){
        Set<Id> contractIdList = new Set<Id>();
        List<Contract_AS_Agreement_Recipient__c> recipientList = new List<Contract_AS_Agreement_Recipient__c>();
        List<Contract_Adobe_Sign_Agreement__c> signAgreementListToInsert = new List<Contract_Adobe_Sign_Agreement__c>();
        List<echosign_dev1__SIGN_Agreement__c> agreementList = [Select Id, echosign_dev1__Opportunity__c,echosign_dev1__Opportunity__r.Id, 
                               echosign_dev1__Account__c, echosign_dev1__Account__r.Id, echosign_dev1__Contract__c, echosign_dev1__Contract__r.Id, echosign_dev1__Contract__r.Status, echosign_dev1__Status__c,
            /* Lead Fields  */ echosign_dev1__Recipient_Lead__c,echosign_dev1__Recipient_Lead2__c,echosign_dev1__Recipient_Lead3__c,echosign_dev1__Recipient_Lead4__c,
            /* Contact Fields */ echosign_dev1__Recipient__c,echosign_dev1__Recipient2__c,echosign_dev1__Recipient3__c,echosign_dev1__Recipient4__c,
            /* Emails comma-separared */echosign_dev1__More_Recipients__c,
            /* User Fields */ echosign_dev1__Recipient_User__c,echosign_dev1__Additional_Recipient_1_User__c,echosign_dev1__Additional_Recipient_2_User__c,echosign_dev1__Additional_Recipient_3_User__c
            
        
            from echosign_dev1__SIGN_Agreement__c where Id IN: (agreementIdSet)];
        
        if (agreementList != null && agreementList.size() > 0){
            Boolean isContractFound = false;
            String contractId;
            for(echosign_dev1__SIGN_Agreement__c agreeObj: agreementList){
                // Check if Contract is not null
                if (agreeObj.echosign_dev1__Contract__c != null){
                    contractId = agreeObj.echosign_dev1__Contract__r.Id;
                
                // Check if Contract is null => Opportunity is not null
                }else if (agreeObj.echosign_dev1__Contract__c == null && agreeObj.echosign_dev1__Opportunity__c != null){
                    String opptyId = agreeObj.echosign_dev1__Opportunity__r.Id;
                    List<Contract> contractList = [Select Id, Opportunity__c, Opportunity__r.Id from Contract where Opportunity__r.Id=:opptyId ORDER BY LastModifiedDate DESC LIMIT 1];
                    if (contractList != null)
                        contractId = contractList[0].Id;
                
                // Check if Contract is null => Opportunity => null => Account is not null   
                }else if (agreeObj.echosign_dev1__Contract__c == null && agreeObj.echosign_dev1__Opportunity__c == null && agreeObj.echosign_dev1__Account__c != null){
                    String acctId = agreeObj.echosign_dev1__Account__r.Id;
                    List<Contract> contractList = [Select Id, Account.Id from Contract where Account.Id=:acctId ORDER BY LastModifiedDate DESC LIMIT 1];
                    if (contractList != null)
                        contractId = contractList[0].Id;
                }
                
                if (contractId == null)
                    return;
                else{
                    // Step 1: Update Contract Status = Signed
                    contractIdList.add(contractId);
                    
                    // Step 2: Create new record in Contract Adobe Sign Agreement object
                    Contract_Adobe_Sign_Agreement__c signAgreement = new Contract_Adobe_Sign_Agreement__c();
                    signAgreement.Contract__c = contractId;
                    signAgreement.Agreement__c = agreeObj.Id;
                    signAgreementListToInsert.add(signAgreement);
                    
                    // Step 3: Create new record in Contract AS Agreement Recipient Object
                    Contract_AS_Agreement_Recipient__c recipient;
                    
                    /* Leads Fields Mapping Starts */
                    if (agreeObj.echosign_dev1__Recipient_Lead__c != null){
                        recipient = new Contract_AS_Agreement_Recipient__c();
                        recipient.Recipient_Agreement__c = agreeObj.Id;
                        recipient.Recipient_Contract__c = contractId;
                        recipient.Recipient_Lead__c = agreeObj.echosign_dev1__Recipient_Lead__c;
                        recipientList.add(recipient);
                    }
                    if (agreeObj.echosign_dev1__Recipient_Lead2__c != null){
                        recipient = new Contract_AS_Agreement_Recipient__c();
                        recipient.Recipient_Agreement__c = agreeObj.Id;
                        recipient.Recipient_Contract__c = contractId;
                        recipient.Recipient_Lead__c = agreeObj.echosign_dev1__Recipient_Lead2__c;
                        recipientList.add(recipient);
                    }
                    if (agreeObj.echosign_dev1__Recipient_Lead3__c != null){
                        recipient = new Contract_AS_Agreement_Recipient__c();
                        recipient.Recipient_Agreement__c = agreeObj.Id;
                        recipient.Recipient_Contract__c = contractId;
                        recipient.Recipient_Lead__c = agreeObj.echosign_dev1__Recipient_Lead3__c;
                        recipientList.add(recipient);
                    }
                    if (agreeObj.echosign_dev1__Recipient_Lead4__c != null){
                        recipient = new Contract_AS_Agreement_Recipient__c();
                        recipient.Recipient_Agreement__c = agreeObj.Id;
                        recipient.Recipient_Contract__c = contractId;
                        recipient.Recipient_Lead__c = agreeObj.echosign_dev1__Recipient_Lead4__c;
                        recipientList.add(recipient);
                    }
                    /* Leads Fields Mapping Ends */
                    
                    /* Contact Fields mapping Starts */
                    if (agreeObj.echosign_dev1__Recipient__c != null){
                        recipient = new Contract_AS_Agreement_Recipient__c();
                        recipient.Recipient_Agreement__c = agreeObj.Id;
                        recipient.Recipient_Contract__c = contractId;
                        recipient.Recipient_Contact__c = agreeObj.echosign_dev1__Recipient__c;
                        recipientList.add(recipient);
                    }
                    if (agreeObj.echosign_dev1__Recipient2__c != null){
                        recipient = new Contract_AS_Agreement_Recipient__c();
                        recipient.Recipient_Agreement__c = agreeObj.Id;
                        recipient.Recipient_Contract__c = contractId;
                        recipient.Recipient_Contact__c = agreeObj.echosign_dev1__Recipient2__c;
                        recipientList.add(recipient);
                    }
                    if (agreeObj.echosign_dev1__Recipient3__c != null){
                        recipient = new Contract_AS_Agreement_Recipient__c();
                        recipient.Recipient_Agreement__c = agreeObj.Id;
                        recipient.Recipient_Contract__c = contractId;
                        recipient.Recipient_Contact__c = agreeObj.echosign_dev1__Recipient3__c;
                        recipientList.add(recipient);
                    }
                    if (agreeObj.echosign_dev1__Recipient4__c != null){
                        recipient = new Contract_AS_Agreement_Recipient__c();
                        recipient.Recipient_Agreement__c = agreeObj.Id;
                        recipient.Recipient_Contract__c = contractId;
                        recipient.Recipient_Contact__c = agreeObj.echosign_dev1__Recipient4__c;
                        recipientList.add(recipient);
                    }
                    /* Contact Fields mapping Ends */
                    
                    /* User Fields Mapping Starts */
                    if (agreeObj.echosign_dev1__Recipient_User__c != null){
                        recipient = new Contract_AS_Agreement_Recipient__c();
                        recipient.Recipient_Agreement__c = agreeObj.Id;
                        recipient.Recipient_Contract__c = contractId;
                        recipient.Recipient_User__c = agreeObj.echosign_dev1__Recipient_User__c;
                        recipientList.add(recipient);
                    }
                    if (agreeObj.echosign_dev1__Additional_Recipient_1_User__c != null){
                        recipient = new Contract_AS_Agreement_Recipient__c();
                        recipient.Recipient_Agreement__c = agreeObj.Id;
                        recipient.Recipient_Contract__c = contractId;
                        recipient.Recipient_User__c = agreeObj.echosign_dev1__Additional_Recipient_1_User__c;
                        recipientList.add(recipient);
                    }
                    if (agreeObj.echosign_dev1__Additional_Recipient_2_User__c != null){
                        recipient = new Contract_AS_Agreement_Recipient__c();
                        recipient.Recipient_Agreement__c = agreeObj.Id;
                        recipient.Recipient_Contract__c = contractId;
                        recipient.Recipient_User__c = agreeObj.echosign_dev1__Additional_Recipient_2_User__c;
                        recipientList.add(recipient);
                    }
                    if (agreeObj.echosign_dev1__Additional_Recipient_3_User__c != null){
                        recipient = new Contract_AS_Agreement_Recipient__c();
                        recipient.Recipient_Agreement__c = agreeObj.Id;
                        recipient.Recipient_Contract__c = contractId;
                        recipient.Recipient_User__c = agreeObj.echosign_dev1__Additional_Recipient_3_User__c;
                        recipientList.add(recipient);
                    }
                    /* User Fields Mapping Starts */
                    
                    /* Emails splitting starts */
                    if (agreeObj.echosign_dev1__More_Recipients__c != null || String.isNotBlank(agreeObj.echosign_dev1__More_Recipients__c)){
                        String emailTemp = String.valueOf(agreeObj.echosign_dev1__More_Recipients__c).removeEnd(',');
                        System.debug('emails are: ' + emailTemp);
                        List<String> emailList = emailTemp.split(',');
                        if (emailList != null && emailList.size() > 0){
                            for(String str: emailList){
                                recipient = new Contract_AS_Agreement_Recipient__c();
                                recipient.Recipient_Agreement__c = agreeObj.Id;
                                recipient.Recipient_Contract__c = contractId;
                                recipient.Recipient_Email__c = str;
                                recipientList.add(recipient);
                            }
                        }
                    }
                    
                }
            }
        }
        
        // Step 1: Update Contract Status to Signed
        if (contractIdList != null && contractIdList.size() > 0){
            List<Contract> contractListToUpdate = new List<Contract>();
            List<Contract> contractList = [Select Id, Status from Contract where Id IN: (contractIdList)];
            if (contractList != null && contractList.size() > 0){
                for(Contract con: contractList){
                    con.Status = 'Signed';
                    contractListToUpdate.add(con);
                }
            }
            if (contractListToUpdate.size() > 0)
                update contractListToUpdate;
        }
        
        // Step 2: Create new record in Contract Adobe Sign Agreement object
        if (signAgreementListToInsert.size() > 0)
            insert signAgreementListToInsert;
        
        if (recipientList.size() > 0)
            insert recipientList;
        
    }
}