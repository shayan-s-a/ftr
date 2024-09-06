/********************************************************************************************
Latest Modification By : Mehedi Hasan (mehedi.hasan@ftr.com)
Targeted Deployment Date:  7th September, 2023.
Description : Removed history__c object reference and formatted code.
********************************************************************************************/
public with sharing class AccountOverrideController {
    public Account account{get;set;}
    private string owner;
    public Id id {get;set;}
    private String accId;
    public String Items='';
    public Boolean display {get;set;}
    public boolean displayPopup=true;
    public String searchInput {get; set;}
    private static string REDIRECT='/001/e?retURL';
    public Account acct{get; set;}

    List<Account> accounts {get;set;}
    public String thisMemo {get;set;}
    public String selectedSavedMemo{get;set;}

    public Id CSRId;
    public string CSRType;
    public string companyName;
    public string companyType;
    public String eMsg = '';
    public  boolean bolIsSmallBusinnessUser        {get;set;}
    public Boolean isPartnerRecord {get;set;}



    public AccountOverrideController(ApexPages.StandardController controller) {
        thisMemo = '';
        id = ApexPages.currentPage().getParameters().get('id');
        system.debug('ID:'+id);
        if(!test.isRunningTest()){
            controller.addFields(new List<String>{'RecordTypeId'});}
        this.account=(Account)controller.getRecord();
        system.debug('Account:'+account);
        try{
            RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE Id = :this.account.RecordTypeId AND DeveloperName = 'Partner' LIMIT 1];
            if(this.account.RecordTypeId == rt.Id){ isPartnerRecord = TRUE; }
            system.debug('isPartnerRecord: '+isPartnerRecord);
        }catch(Exception e){}

        owner=userInfo.getName();
        Items = 'Contains';
        check = 'Contains';

        //Get the Current User Profile  name
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;

        //KJ 9/19/2013
        if (usrProfileName.equals('Small Business User Test') || usrProfileName.containsIgnoreCase('SmallBusinessUser'))
        //if (usrProfileName.equals('Small Business User') || usrProfileName.equals('Small Business User Test') || usrProfileName.containsIgnoreCase('SmallBusinessUser'))
        //if(usrProfileName.equals('Small Business User') || usrProfileName.equals('Small Business User Test'))
            bolIsSmallBusinnessUser = true;
        else
            bolIsSmallBusinnessUser =false;
    }

    //This method creates a log entery in sObject Acces_Log when a Patient contact record is viewed in Salesforce --->Mounika

    public String getOwner(){
        return owner;
    }

    public PageReference save1(){
            try{
                  if(id!=null)
                    update account;
                  else {
                  //if(Userinfo.getProfileId()!='00eE000000104CdIAI' && Userinfo.getProfileId()!='00eL0000000HkN2IAK')
                  //00ec0000000HjmGAAS
                  if(Userinfo.getProfileId()!='00eL0000000HkN2IAK')
                            {
                            account.Memo__c = '-';
                            }
                    insert account;
                     }
               }catch(Exception e){
                 system.debug('Error with Insert:' + e);
                 eMsg = '\nUpsert to Account failed: \nAccount record details:' + account + '\n'+ '\nSystem Error Msg:' + e;
                 sendMsg(eMsg);
                 return null;
               }

        PageReference detailPage = new PageReference('/' +account.id);
        detailPage.setRedirect(true);
        return detailPage;
    }

     public PageReference saveAndnew(){

            try{
                  if(id!=null)
                        update account;
                  else
                        insert account;

               }catch(Exception e){
                 eMsg = '\nUpsert to Account failed: \nAccount record details:' + account + '\n'+ '\nSystem Error Msg:' + e;
                 sendMsg(eMsg);
                 return null;
               }

        PageReference detailPage = new PageReference(REDIRECT);
        detailPage.setRedirect(true);
        return detailPage;
    }

    public AccountOverrideController (){
        Items = 'Contains';
        check = 'Contains';
    }

    List<SIC_Code__c> searchobjList;
    List<SIC_Code__c> tempSearchobjList=new List<SIC_Code__c>();
    String check = '';
    public void showPopup(){
        Items = 'Contains';
        displayPopup = true;
    }
    public Boolean getDisplayPopup(){
        return displayPopup;
    }

    public void Search(){
        String st= getCheckValue();
        System.debug('asdf'+st);
        if(st == 'Contains'){
            display=false;
            String queryName = '%' + searchInput  + '%';
            System.debug('asdf'+queryName );
            searchobjList=[Select d.SystemModstamp,d.Description__c, d.Short_Description__c, d.SIC__c, d.Id From SIC_Code__c d where d.Description__c like :queryName+'%' or d.SIC__c like :queryName+'%' ORDER BY d.numeric_sic__c Limit 1000];
            if(searchobjList.size()==0)
                display=true;
            }
        if(st == 'Starts with'){
            display=false;
            String queryName = searchInput + '%';
            searchobjList=[Select d.SystemModstamp, d.Description__c,d.Short_Description__c, d.SIC__c, d.Id From SIC_Code__c d where d.Description__c like :queryName+'%' or d.SIC__c like :queryName+'%' ORDER BY d.numeric_sic__c Limit 1000];
            if(searchobjList.size()==0)
                display=true;
        }

        // To escape the single quotes present in the description field
        for(SIC_Code__c tList : searchobjList){
        //tList.Description__c = String.escapeSingleQuotes(tList.Description__c);
        // To replace special character(single quote)
        if(tList.Description__c.contains('\''))
           tList.Description__c= tList.Description__c.replace('\'','');
        system.debug('desc value:'+ tList.Description__c);
        }

    }

    public List<SIC_Code__c> getobjList(){
        return searchobjList;
    }

    public List<SelectOption> getItems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Contains','Contains'));
        options.add(new SelectOption('Starts with','Starts with'));
        return options;
    }

    public String getCheckValue(){
        return check;
    }

    public void setCheckValue(String check){
        this.check = check;
    }

    public void sendMsg(String err) {
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'Douglas.Hook@ftr.com'};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Apex error');
        mail.setSubject('AccountOverride Page Error from Org : ' + UserInfo.getOrganizationName());
        mail.setPlainTextBody('Error Message: ' + err +
                          '\nUser:'+ UserInfo.getName()+
                          '\nOrg:' + UserInfo.getOrganizationId()+
                          '\nUserName:' + UserInfo.getUserName()+
                          '\nUserId:' + UserInfo.getUserId());

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }


       public Account a {get;set;}

  //This method creates a log entery in sObject Acces_Log when a Patient contact record is viewed in Salesforce
 public pagereference createLog(){
    if (thisMemo =='' || thisMemo == null){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter a memo and click [Add & Proceed] button to View record.'));
        return null;
    }


     PageReference pageRef = new PageReference('/'+account.id+'?nooverride=1');
     return pageRef;

}

  public pagereference createLogDelete(){
    if (thisMemo =='' || thisMemo == null){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter a memo and click [Add & Proceed] button to Delete record.'));
        return null;
    }

     delete account;

     PageReference pageRef = new PageReference('/001/o');
     return pageRef;

  }
  public List<SelectOption> getSavedMemoList(){
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', '--select saved memo--'));
    Set<String> uniqueMemos = new Set<String>();

    for(String s :uniqueMemos)
        options.add(new SelectOption(s,s));

    return  options;
  }

}