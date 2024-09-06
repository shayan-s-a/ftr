/********************************************************************************************
Latest Modification By : Mehedi Hasan (mehedi.hasan@ftr.com)
Targeted Deployment Date:  7th September, 2023.
Description : Removed history__c object reference and formatted code. 
********************************************************************************************/
public with sharing class OpportunityOverride {

public Opportunity o {get;set;}
    List<Opportunity> opps {get;set;}

    public String thisMemo {get;set;}
    public String selectedSavedMemo {get;set;}
    /*constructor*/
    public OpportunityOverride(ApexPages.StandardController stdcontroller){
        o = (Opportunity)stdController.getRecord();
        o = [SELECT ID,AccountID from Opportunity where ID =:o.id ];
    }

  public List<SelectOption> getSavedMemoList(){
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', '--select saved memo--'));
    Set<String> uniqueMemos = new Set<String>();

    //if (myHistoryList.Size()>0)
        //selectedSavedMemo = myHistoryList[0].Memo__c ;

    for(String s :uniqueMemos)
        options.add(new SelectOption(s,s));

    return  options;
  }

}