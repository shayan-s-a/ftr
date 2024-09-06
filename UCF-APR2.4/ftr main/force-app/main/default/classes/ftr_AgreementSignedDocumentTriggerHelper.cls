/*
** Class Name:
** Created Date: 2021-06-26
** Created By: Vinod kakantala of EagleCreek
** Description:
**
** History:
** 2021-06-17: Class created date
*/public class ftr_AgreementSignedDocumentTriggerHelper {
    
    public static void CreateContractDocument(list<echosign_dev1__SIGN_Agreement__c>triggernew){
        system.debug('===InsideHelper::=='+triggernew);
        list<Contract>conlist = new list<Contract>();
        list<Agreement_Contracts__c>aconlist = new list<Agreement_Contracts__c>();
      //  list<Contact>aggcontact = new list<Contact>();
       // list<echosign_dev1__SIGN_Agreement__c>aggrementlist = new list<echosign_dev1__SIGN_Agreement__c>();
       // list<echosign_dev1__SIGN_AgreementEvent__c>aggevent = new list<echosign_dev1__SIGN_AgreementEvent__c>();
        list<vlocity_cmt__ContractVersion__c>cclist = new list<vlocity_cmt__ContractVersion__c>();
        map<string,string>doc2version = new map<string,string>();
        set<string>signagreementid = new set<string>();
        for(echosign_dev1__SIGN_Agreement__c sa : triggernew){
            signagreementid.add(sa.id);
        }
        system.debug('=====signagreementid:::'+signagreementid);
        if(signagreementid!=null && signagreementid.size()>0){
            aconlist = [select id,Agreement__c,Name,Contract__c from Agreement_Contracts__c where Agreement__c IN : signagreementid];
            system.debug('==aconlist=='+aconlist);
            if(aconlist!=null && aconlist.size()>0){
                list<ContentDocumentLink>cdl = new list<ContentDocumentLink>();
                cdl= [SELECT ContentDocumentId,ContentDocument.Title,Id,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId IN :signagreementid];
                system.debug('====CDL::::'+cdl);
                if(cdl!=null && cdl.size()>0){
                    for(Agreement_Contracts__c ac : aconlist){
                        for(ContentDocumentLink cd : cdl){
                            string fname= ac.Name+' - signed.pdf';
                            //system.debug('=====fName:'+fname);
                            //system.debug('===Title:::'+cd.ContentDocument.Title);
                            if(ac.Agreement__c == cd.LinkedEntityId && fname== cd.ContentDocument.Title){
                                vlocity_cmt__ContractVersion__c cc = new vlocity_cmt__ContractVersion__c();
                                cc.vlocity_cmt__ContractId__c = ac.Contract__c;
                                cc.vlocity_cmt__DocumentCreationSource__c='Generate';
                                cclist.add(cc);
                                doc2version.put(ac.Contract__c,cd.id);
                            }
                        }
                    }
                }
                system.debug('====cclist:::'+cclist);
                if(cclist!=null && cclist.size()>0){
                    insert cclist;
                    for(vlocity_cmt__ContractVersion__c vcc : cclist){
                        if(vcc.id!=null){
                            string vid = doc2version.get(vcc.vlocity_cmt__ContractId__c);
                            if(vid!=null){
                            	ftr_DocumentAttachmentConverter.convertContentToAttachment(vid,vcc.id);
                                system.debug('==Calling FTR CLASS=====');
                            }
                            
                        }
                    }
                }
                 if(aconlist!=null && aconlist.size()>0){
                    for(Agreement_Contracts__c ac : aconlist){
                  conlist = [Select Id,Contract_Status__c,Document_Status__c,Status from Contract where Id=:ac.Contract__c];                   
                        for(Contract con :conlist){
                             con.Contract_Status__c ='Active';
                        con.Document_Status__c='Signed';
						    con.Status = 'Activated';
                              
                        }
                       update conlist;
                    }
                }
            }
            
        }
    }
    
    public static void UpdateContractStatus(list<echosign_dev1__SIGN_Agreement__c>triggernew){
         list<Agreement_Contracts__c>aconlist = new list<Agreement_Contracts__c>();
        list<Contract>conlist = new list<Contract>();
        set<string>declineagreementid = new set<string>();
        for(echosign_dev1__SIGN_Agreement__c sa : triggernew){
            declineagreementid.add(sa.id);
            if(declineagreementid!=null && declineagreementid.size()>0){
                aconlist =[Select Id, Contract__c from Agreement_Contracts__c where Agreement__c IN : declineagreementid];
                    system.debug('==aconlist=='+aconlist);             
                if(aconlist!=null && aconlist.size()>0){
                    for(Agreement_Contracts__c ac : aconlist){
                   conlist = [Select Id,Contract_Status__c,Document_Status__c from Contract where Id=:ac.Contract__c];
                        for(Contract con :conlist){
                             con.Contract_Status__c ='Declined/Cancelled';
                        con.Document_Status__c='Customer Declined';
                        }
                       update conlist;
                    }
                }
            }
        }
    }
    public static void UpdateContractDocumentStatus(list<echosign_dev1__SIGN_Agreement__c>triggernew){
         list<Agreement_Contracts__c>aconlist = new list<Agreement_Contracts__c>();
        list<Contract>conlist = new list<Contract>();
        set<string>draftagreementid = new set<string>();
        for(echosign_dev1__SIGN_Agreement__c sa : triggernew){
            draftagreementid.add(sa.id);
            if(draftagreementid!=null && draftagreementid.size()>0){
                aconlist =[Select Id, Contract__c from Agreement_Contracts__c where Agreement__c IN : draftagreementid];
                    system.debug('==aconlist=='+aconlist);             
                if(aconlist!=null && aconlist.size()>0){
                    for(Agreement_Contracts__c ac : aconlist){
                   conlist = [Select Id,Contract_Status__c,Document_Status__c from Contract where Id=:ac.Contract__c];
                        for(Contract con :conlist){
                             con.Contract_Status__c ='Draft';
                        con.Document_Status__c='Document Generated';
                        }
                       update conlist;
                    }
                }
            }
        }
    }

	 public static void UpdateContractDocumentofsStatus(list<echosign_dev1__SIGN_Agreement__c>triggernew){
         list<Agreement_Contracts__c>aconlist = new list<Agreement_Contracts__c>();
        list<Contract>conlist = new list<Contract>();
        set<string>agrementofstlist = new set<string>();
        for(echosign_dev1__SIGN_Agreement__c sa : triggernew){
            agrementofstlist.add(sa.id);
            if(agrementofstlist!=null && agrementofstlist.size()>0){
                aconlist =[Select Id, Contract__c from Agreement_Contracts__c where Agreement__c IN : agrementofstlist];
                    system.debug('==aconlist=='+aconlist);             
                if(aconlist!=null && aconlist.size()>0){
                    for(Agreement_Contracts__c ac : aconlist){
                   conlist = [Select Id,Contract_Status__c,Document_Status__c from Contract where Id=:ac.Contract__c];
                        for(Contract con :conlist){
                             con.Contract_Status__c ='Draft';
                        con.Document_Status__c='Document Sent to Customer';
                        }
                       update conlist;
                    }
                }
            }
        }
    }
	
	 public static void UpdateContractDocumentwcaStatus(list<echosign_dev1__SIGN_Agreement__c>triggernew){
         list<Agreement_Contracts__c>aconlist = new list<Agreement_Contracts__c>();
        list<Contract>conlist = new list<Contract>();
        set<string>agrementwcalist = new set<string>();
         set<string> contractIds = new set<string>();
        for(echosign_dev1__SIGN_Agreement__c sa : triggernew){
            agrementwcalist.add(sa.id);   
        }
        if(agrementwcalist!=null && agrementwcalist.size()>0){
             aconlist =[Select Id, Contract__c from Agreement_Contracts__c where Agreement__c IN : agrementwcalist];
             system.debug('==aconlist=='+aconlist);             
             if(aconlist!=null && aconlist.size()>0){
                 for(Agreement_Contracts__c ac : aconlist){
                     contractIds.add(ac.Contract__c);
                 }
                 conlist = [Select Id,Contract_Status__c,Document_Status__c from Contract where Id IN :contractIds];
                 for(Contract con :conlist){
                     con.Contract_Status__c ='	Customer Signed';
                     con.Document_Status__c='Customer Signed / Awaiting Approval';
                 }
                 update conlist;
             }
         }
        /*for(echosign_dev1__SIGN_Agreement__c sa : triggernew){
            draftagreementid.add(sa.id);
            if(draftagreementid!=null && draftagreementid.size()>0){
                aconlist =[Select Id, Contract__c from Agreement_Contracts__c where Agreement__c IN : draftagreementid];
                    system.debug('==aconlist=='+aconlist);             
                if(aconlist!=null && aconlist.size()>0){
                    for(Agreement_Contracts__c ac : aconlist){
                   conlist = [Select Id,Contract_Status__c,Document_Status__c from Contract where Id=:ac.Contract__c];
                        for(Contract con :conlist){
                             con.Contract_Status__c ='Draft';
                        con.Document_Status__c='Customer Signed / Awaiting Approval';
                        }
                       update conlist;
                    }
                }
            }
        }*/
    }


}