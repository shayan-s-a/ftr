/********************************************************************************************
Name : AccountUtility
Created By : Mohan Talluri (mohan.talluri@ftr.com)
Created Date : February 11, 2016
Description :  Utility to support Account Trigger Handler.
********************************************************************************************/

public with sharing class AccountUtility { 
    
  private static Account acc = null;
  private static List<Account> splitRecords;
  private static ID accRecordTypeDPIID = null; 
  private static Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account.getRecordTypeInfosById();
  private static Set<String> validAccountLevels = new Set<String>{'SUMMARY', 'BILLING', 'MEMBER'};
  private static Map<Integer, String> acctTypes = new Map<Integer, String>{0 => 'Home Grown EBill', 1 => 'Standard', 2 => 'Premium', 3 => 'EDI'}; 
  public static boolean isRecursiveTrigger = false;
  public static void createHierarchy(List<Account> newItems)
  {
       System.debug('In createHierarchy');

       // Hierarchy generation logic for DPI Load, is in reusuable method which needs to be invoked here directly.  
       System.debug('createHierarchy newItems.size() :: '+newItems.size());
       processAccountHierarchy(newItems);
  }
  
  public static void updateHierarchy(List<SObject> newItems) 
  {
       System.debug('In updateHierarchy');
       
       // Hierarchy generation logic for DPI Load, is in reusuable method which needs to be invoked here directly.
       processAccountHierarchy((List<Account>) newItems);
  }
  
  /*@Future
 public static void deleteSupportTeamMember()
 {
    List<Support_Team_Member__c> stm = [Select Id from Support_Team_Member__c where Account__c = '' ];
    delete stm;
 }*/
    
    public static void delete_SupportTeamMember(Set<Id> deletedAccIds){
        delete [Select Id from Support_Team_Member__c where Account__c IN: deletedAccIds ];
    }
 

  private static void processAccountHierarchy(List<Account> newItems)
  {
       // Hierarchy generation logic is in reusuable method which needs to be invoked here directly.    
       System.debug('processAccountHierarchy newItems.size() :: '+newItems.size());     
       List<Account> processedAccounts = generateHierarchy(newItems);  
       List<Account> finalAccounts = new List<Account>();
       boolean accExist = false;  
       for(Account b : processedAccounts){
            accExist = false;
            System.debug('FINAL VALUES :: '+b.TNSequenceId__c);
            for (Account a : newItems){
                if ((a.TNSequenceId__c).equals(b.TNSequenceId__c))  accExist = true; break;
            }
            if (!accExist)
                finalAccounts.add(b);            
       }
       
       System.debug('Processed Accounts getting Upsert are :: '+processedAccounts.size());
       
       System.debug('Final Accounts getting Upsert are :: '+finalAccounts.size());
       if (finalAccounts.size() > 0)
       {
          
          try {
              // insert first all Summary Accounts.
              upsert extractSplitRecords(finalAccounts, 'SUMMARY') TNSequenceId__c;
              // then all the Billing Accounts.
              upsert extractSplitRecords(finalAccounts, 'BILLING') TNSequenceId__c;
              // then all the Member Accounts.
              upsert extractSplitRecords(finalAccounts, 'MEMBER') TNSequenceId__c;
          } catch (DmlException e) {System.debug(e.getMessage());}
          
       }
  }
  
  private static List<Account> generateHierarchy(List<Account> accounts)
  {
       List<Account> processedAccounts = new List<Account>();  
       List<Account> splitAccountsList = new List<Account>();
       List<Account> duplicateAccounts = new List<Account>();
       
       List<String>  avoidTNList = new List<String>();
       
       string tnValue = null;
       
       if (accRecordTypeDPIID == null)  accRecordTypeDPIID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('DPI').getRecordTypeId();
       if (rtMap == null)   rtMap = Schema.SObjectType.Account.getRecordTypeInfosById();
       
       System.debug('generateHierarchy accounts.size() :: '+accounts.size());
       string rname = '';
        
       for (Account acct : accounts)
       {
          acct.TNSequenceId__c = ObjectUtility.checkForZero(acct.TNSequenceId__c);
          acct.ParentSequenceId__c = ObjectUtility.checkForZero(acct.ParentSequenceId__c);
          acct.SMASequenceID__c = ObjectUtility.checkForZero(acct.SMASequenceID__c);
          acct.DPI_GANID__c = ObjectUtility.checkForZero(acct.DPI_GANID__c);
          
          if (string.isEmpty(acct.isDPILoad__c)) acct.isDPILoad__c = 'FALSE';
          
          System.debug('acct.isDPILoad__c'+ acct.isDPILoad__c);
          System.debug('acct.RecordTypeId'+ acct.RecordTypeId);
          
          if (!(string.isEmpty(acct.RecordTypeId)))
              rname = rtMap.get(acct.RecordTypeId).getName();
          else
              System.debug('acct.RecordTypeId'+ acct.RecordTypeId);
              
          //System.debug('DPI :: '+((rtMap.get(acct.RecordTypeId).getName()).equals('DPI')));
          System.debug('rname :: '+ rname);
          
          if ( (acct.isDPILoad__c == 'TRUE') && (rname.equals('DPI')) )
          {
              // Split and build the hierarchy for the current processing account record.   
              splitAccountsList = processRecordHierarchy(acct);
              
              if (splitAccountsList.size() >   0) 
              {
                  tnValue = (!string.isEmpty(acct.TNSequenceId__c)) ? ObjectUtility.appendZeroOnTN(acct.TNSequenceId__c) : ObjectUtility.appendZeroOnTN(acct.ParentSequenceId__c);
                  if (string.isEmpty(tnValue)) tnValue = ObjectUtility.appendZeroOnTN(acct.smasequenceid__c);
                                                       
                  // Using index to identify the object in the list to update the original flowing account record.                  
                  for (Integer i = 0; i < splitAccountsList.size(); i++) 
                  {
                        System.debug('*****   Equal ::  splitAcctTN: '+splitAccountsList.get(i).TNSequenceId__c+' tnValue : '+tnValue);
                        
                        if ( (splitAccountsList.get(i).TNSequenceId__c) == tnValue ) {
                            
                            System.debug('Actual Record :: Name: '+acct.name+' , TNSequenceId__c: '+acct.TNSequenceId__c+' , ParentSequenceId__c: '+acct.ParentSequenceId__c+' , smasequenceid__c: '+acct.smasequenceid__c+' , DPI_GANID__c: '+acct.DPI_GANID__c+' , Account_Type__c: '+acct.Account_Type__c+' , hierarchy_level__c: '+acct.hierarchy_level__c+' , recordtypeId: '+acct.RecordTypeId+' , ParentId: '+acct.ParentId+' , isdpiload__C: '+acct.isdpiload__C+' , createdDate: '+acct.createdDate+' , createdby.name: '+acct.createdby.name);
                            //System.debug('Actual List Record:: Name: '+splitAccountsList.get(i).name+' , TNSequenceId__c: '+splitAccountsList.get(i).TNSequenceId__c+' , ParentSequenceId__c: '+splitAccountsList.get(i).ParentSequenceId__c+' , smasequenceid__c: '+splitAccountsList.get(i).smasequenceid__c+' , DPI_GANID__c: '+splitAccountsList.get(i).DPI_GANID__c+' , Account_Type__c: '+splitAccountsList.get(i).Account_Type__c+' , hierarchy_level__c: '+splitAccountsList.get(i).hierarchy_level__c+' , recordtype.name: '+splitAccountsList.get(i).RecordTypeId+' , ParentId: '+splitAccountsList.get(i).ParentId+' , isdpiload__C: '+splitAccountsList.get(i).isdpiload__C+' , createdDate: '+splitAccountsList.get(i).createdDate+' , createdby.name: '+splitAccountsList.get(i).createdby.name);
                            
                            acct.TNSequenceId__c = splitAccountsList.get(i).TNSequenceId__c;
                            
                            avoidTNList.add(acct.TNSequenceId__c);
                            
                            acct.ParentSequenceId__c = splitAccountsList.get(i).ParentSequenceId__c;
                            acct.DPI_GANID__c = splitAccountsList.get(i).DPI_GANID__c;
                            acct.Hierarchy_Level__c = splitAccountsList.get(i).Hierarchy_Level__c;
                            acct.RecordTypeId = splitAccountsList.get(i).RecordTypeId;
                            acct.Account_Type__c = setAccountType(acct.Account_Type__c);
                            acct.ShippingStateCode = string.isEmpty(acct.ShippingStateCode) ? '' : (acct.ShippingStateCode).mid(0,5);
                            acct.smasequenceid__c = '';
                            acct.Name = splitAccountsList.get(i).Name;  
                            
                            System.debug('After copying:: Name: '+acct.name+' , TNSequenceId__c: '+acct.TNSequenceId__c+' , ParentSequenceId__c: '+acct.ParentSequenceId__c+' , smasequenceid__c: '+acct.smasequenceid__c+' , DPI_GANID__c: '+acct.DPI_GANID__c+' , Account_Type__c: '+acct.Account_Type__c+' , hierarchy_level__c: '+acct.hierarchy_level__c+' , recordtypeid: '+acct.RecordTypeId+' , ParentId: '+acct.ParentId+' , isdpiload__C: '+acct.isdpiload__C+' , createdDate: '+acct.createdDate+' , createdby.name: '+acct.createdby.name);
                            splitAccountsList.remove(i);
                            
                            break;
                        }
                  }
              }
              
              System.debug('splitAccountsList size :: '+splitAccountsList.size());
              processedAccounts.addall(removeDuplicatesComparingLists(processedAccounts, splitAccountsList));
              
          }
          else
          {
             // if isDPILoad__c not empty and not equals TRUE - then they are orphaned records getting loaded.
             // These are already split into Summary/Billing and Member Account Records.
             
             if ( (rname.equals('DPI')) && (!((acct.Name).contains(' - '))) )
             //if ((acct.RecordTypeId).equals(getRecordTypeID()))
             {
                  acct.Name = ObjectUtility.setAccountName(acct.TNSequenceId__c);
                  acct.TNSequenceId__c = ObjectUtility.appendZeroOnTN(acct.TNSequenceId__c);
                  acct.ParentSequenceId__c = ObjectUtility.appendZeroOnTN(acct.ParentSequenceId__c);
                  acct.isDPILoad__c = 'TRUE';  // This is set to TRUE, to have setParentHierarchy to update the parentid after insert or update.
                  acct.smasequenceid__c = '';
                 //Empty the ParentId field if the BTN/Parent sequence Id is empty
                  if(acct.ParentSequenceId__c == null) acct.ParentId = null;
                    
                  acct.Account_Type__c = setAccountType(acct.Account_Type__c);
                    
                  if ((acct.TNSequenceId__c).equals(acct.ParentSequenceId__c)) {
                    if ((acct.Hierarchy_Level__c).equals('MEMBER')) acct.Hierarchy_Level__c = 'BILLING';
                  }
                  System.debug('Processed Individual Record:: Name: '+acct.name+' , TNSequenceId__c: '+acct.TNSequenceId__c+' , ParentSequenceId__c: '+acct.ParentSequenceId__c+' , DPI_GANID__c: '+acct.DPI_GANID__c+' , Account_Type__c: '+acct.Account_Type__c+' , hierarchy_level__c: '+acct.hierarchy_level__c+' , recordtypeid: '+acct.RecordTypeId+' , ParentId: '+acct.ParentId+' , isdpiload__C: '+acct.isdpiload__C+' , createdDate: '+acct.createdDate+' , createdby.name: '+acct.createdby.name);
             }
          }
          
       }
       System.debug('Identified Duplicates TNList :: '+avoidTNList);
       
       List<Account> avoidDuplicatesList = removeDuplicatesComparingKeys(processedAccounts, avoidTNList);
       return avoidDuplicatesList;      
  }
  
  private static List<Account> processRecordHierarchy(Account accnt)
  {
        splitRecords = new List<Account>();

        System.debug('Processing Account Record :: '+accnt);
        String parent;
        
        boolean isGANNOTNull = (!String.isEmpty(accnt.DPI_GANID__c)) ? true : false;
        boolean isSMANOTNull = (!String.isEmpty(accnt.SMASequenceID__c)) ? true: false;
        boolean isBTNNOTNull = (!String.isEmpty(accnt.ParentSequenceId__c)) ? true : false;
        boolean isWTNNOTNull = (!String.isEmpty(accnt.TNSequenceId__c)) ? true : false;
        boolean isWTNBTNSame = false;
        boolean isWTNBTNSMASame = false;
        
        if ( (isWTNNOTNull) && (isBTNNOTNull))
        {
            isWTNBTNSame = ((accnt.TNSequenceId__c).equals(accnt.ParentSequenceId__c));
            if (isSMANOTNull && isWTNBTNSame) isWTNBTNSMASame = ((accnt.SMASequenceID__c).equals(accnt.ParentSequenceId__c));
        }
        
        // Handle Summary Accounts
        if (isSMANOTNull)
        {
            parent = isGANNOTNull ? accnt.DPI_GANID__c : '';
            splitRecords.add(generateSummaryAccount(accnt.SMASequenceID__c, parent, accnt));
        }
        
        // Handle Billing Accounts
        if (isBTNNOTNull && (!isWTNBTNSMASame))
        {
            if (isWTNBTNSame && isSMANOTNull) splitRecords.add(generateBillingAccount(accnt.ParentSequenceId__c, accnt.SMASequenceID__c, accnt));
            else if (isSMANOTNull) splitRecords.add(generateBillingAccount(accnt.ParentSequenceId__c, accnt.SMASequenceID__c, accnt));
            else if (isGANNOTNull) splitRecords.add(generateBillingAccount(accnt.ParentSequenceId__c, accnt.DPI_GANID__c, accnt));            
        }
        
        // Handle Member Accounts
        if (isWTNNOTNull  && (!isWTNBTNSMASame))
        {
            if ((isBTNNOTNull) && (!isWTNBTNSame))
                splitRecords.add(generateMemberAccount(accnt.TNSequenceId__c, accnt.ParentSequenceId__c, accnt));
            else if (isWTNBTNSame && !isSMANOTNull)
                splitRecords.add(generateBillingAccount(accnt.TNSequenceId__c, accnt.TNSequenceId__c, accnt));  
            else if (!isBTNNOTNull) // if BTN Null
                splitRecords.add(generateBillingAccount(accnt.TNSequenceId__c, accnt.TNSequenceId__c, accnt));
        }
        
        System.debug('Processed Account Record. Split record to :: '+splitRecords.size()  +' Accounts.');
        
        return splitRecords;
  }
  
  private static Account generateSummaryAccount(String tn, String parentTN, Account inputAcc)
  {
        acc = new Account();
        acc.Name = ObjectUtility.setAccountName(tn);
        acc.TNSequenceId__c = ObjectUtility.appendZeroOnTN(tn);
        acc.ParentSequenceId__c = ObjectUtility.appendZeroOnTN(parentTN);
        acc.DPI_GANID__c = parentTN;
        acc.Hierarchy_Level__c = 'SUMMARY';
        acc.Account_Type__c = setAccountType(inputAcc.Account_Type__c);//acc.Account_Type__c = acctTypes.get(2);
        acc.RecordTypeId = getRecordTypeID();
        
        System.debug('Summary record : '+acc.name+' , '+acc.TNSequenceId__c+' , '+acc.ParentSequenceId__c);
        return acc;
  }
  
  private static Account generateBillingAccount(String tn, String parentTN, Account inputAcc)
  {
        acc = new Account();
        acc.Name = ObjectUtility.setAccountName(tn);
        acc.TNSequenceId__c = ObjectUtility.appendZeroOnTN(tn);
        acc.ParentSequenceId__c = ObjectUtility.appendZeroOnTN(parentTN);
        acc.DPI_GANID__c = inputAcc.DPI_GANID__c;
        acc.Hierarchy_Level__c = 'BILLING';
        acc.RecordTypeId = getRecordTypeID();
        acc.Account_Type__c = setAccountType(inputAcc.Account_Type__c);//acc.Account_Type__c = acctTypes.get(2);
        
        if (tn.equals(parentTN)) {
                
            acc.DPIUniversalServiceID__c = inputAcc.DPIUniversalServiceID__c; 
            acc.DPI_DisconnectDate__c = inputAcc.DPI_DisconnectDate__c; 
            acc.Company_Name__c = inputAcc.Company_Name__c; 
            acc.ShippingStreet = inputAcc.ShippingStreet; 
            acc.ShippingCity = inputAcc.ShippingCity;   
            acc.ShippingStateCode = string.isEmpty(inputAcc.ShippingStateCode) ? '' : (inputAcc.ShippingStateCode).mid(0,5); 
            acc.ShippingPostalCode = inputAcc.ShippingPostalCode; 
            acc.DPI_ServiceType__c = inputAcc.DPI_ServiceType__c; 
            acc.DPI_ConnectDate__c = inputAcc.DPI_ConnectDate__c; 
            acc.Library_Id__c = inputAcc.Library_Id__c;
        }

        System.debug('Billing record : '+acc.name+' , '+acc.TNSequenceId__c+' , '+acc.ParentSequenceId__c);
        return acc;
  }

  private static Account generateMemberAccount(String tn, String parentTN, Account inputAcc)
  {
        acc = new Account();
        acc.TNSequenceId__c = ObjectUtility.appendZeroOnTN(tn);
        acc.ParentSequenceId__c = ObjectUtility.appendZeroOnTN(parentTN);
        acc.DPI_GANID__c = inputAcc.DPI_GANID__c;
        acc.Hierarchy_Level__c = 'MEMBER';
        acc.RecordTypeId = getRecordTypeID();
        acc.Account_Type__c = setAccountType(inputAcc.Account_Type__c);
        /*
        if ( (!String.isEmpty(inputAcc.Account_Type__c))  && ((inputAcc.Account_Type__c.trim()).isNumeric()))
            acc.Account_Type__c = acctTypes.get(Integer.valueOf(inputAcc.Account_Type__c.trim()));
        else
            acc.Account_Type__c = acctTypes.get(1);
        */    
        acc.DPIUniversalServiceID__c = inputAcc.DPIUniversalServiceID__c; 
        acc.DPI_DisconnectDate__c = inputAcc.DPI_DisconnectDate__c; 
        acc.Company_Name__c = inputAcc.Company_Name__c; 
        acc.ShippingStreet = inputAcc.ShippingStreet; 
        acc.ShippingCity = inputAcc.ShippingCity;   
        acc.ShippingStateCode = string.isEmpty(inputAcc.ShippingStateCode) ? '' : (inputAcc.ShippingStateCode).mid(0,5); 
        acc.ShippingPostalCode = inputAcc.ShippingPostalCode; 
        acc.DPI_ServiceType__c = inputAcc.DPI_ServiceType__c; 
        acc.DPI_ConnectDate__c = inputAcc.DPI_ConnectDate__c; 
        acc.Library_Id__c = inputAcc.Library_Id__c;
        acc.Name = ObjectUtility.setAccountName(tn);
        
        System.debug('Member record : '+acc.name+' , '+acc.TNSequenceId__c+' , '+acc.ParentSequenceId__c);
        return acc;
  }
  
  private static ID getRecordTypeID()
  {
     if (accRecordTypeDPIID == null) accRecordTypeDPIID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('DPI').getRecordTypeId();
     
     return accRecordTypeDPIID;
  }
  
  private static List<Account> removeDuplicatesComparingLists(List<Account> processedAccounts, List<Account> splitAccountsList)
  {
      List<Account> filterAccounts = new List<Account>();
      boolean recordExists = false;
      for (Account accNew : splitAccountsList)
      {
        recordExists = false;
        
        for (Account accOld : processedAccounts) {
            if (accNew.TNSequenceId__c == accOld.TNSequenceId__c) recordExists = true; break;
        }

        if (!recordExists)
           filterAccounts.add(accNew);
      }
      System.debug('removeDuplicatesComparingLists filterAccounts size :: '+filterAccounts.size());
      return filterAccounts;
  }
  
  private static List<Account> removeDuplicatesComparingKeys(List<Account> processedAccounts, List<String> AccountsList)
  {
    System.debug('In removeDuplicatesComparingKeys :::: '+processedAccounts.size());
    List<Account> filterAccounts = new List<Account>();
    boolean recordExists = false;
 
    for (Account accOld : processedAccounts)
    {
        recordExists = false;
        System.debug('In removeDuplicatesComparingKeys processedAcct TN :::: '+accOld.TNSequenceId__c);
        
        for (string s : AccountsList) {
            if (s.equals(accOld.TNSequenceId__c)){
                recordExists = true;
                break;
            }
        }

        if (!recordExists)
           filterAccounts.add(accOld);          
    }
    
    System.debug('In removeDuplicatesComparingKeys After Processing :::: '+processedAccounts.size());
    
    return filterAccounts;
  }

  public static List<Account> removeDuplicates (List<SObject> newItems)
  {
     List<String> accTNList  = new List<String>();
     List<Account> processedAccounts =  (List<Account>) newItems;
     
     System.debug('removeDuplicates size :: '+newItems.size());
     
     for (Account acnt : processedAccounts)
        accTNList.add(acnt.TNSequenceId__c);
     
     System.debug('removeDuplicates accTNList :: '+accTNList);
     
     List<Account> existingAccounts = [Select ID, TNSequenceId__c from Account where TNSequenceId__c in :accTNList and TNSequenceId__c <> null];
     System.debug('removeDuplicates existingAccounts size :: '+existingAccounts.size());
     
     return removeDuplicatesComparingLists(existingAccounts, processedAccounts);   
  } 
    
  // This method not only extracts sub records but will also generate hierarchy by updating ParentId.
  private static List<Account> extractSplitRecords(List<Account> accts, String level)
  {
     System.debug('Extracting '+level+' Records from Processed List.');
     splitRecords = new List<Account>();
     boolean isLevelSummary = false;
     boolean isParentExist = false;
     List<Account> parentAccounts = new List<Account>();
     List<String> parentAccountTNList = new List<String>();
     
     for (Account b : accts)
        parentAccountTNList .add(b.ParentSequenceId__c);
        
     if (validAccountLevels.contains(level))
     {
         if (level.equals('SUMMARY'))
            isLevelSummary = true;
         else
            parentAccounts = [Select ID, TNSequenceId__c, ParentSequenceId__c from Account where RecordTypeId =: getRecordTypeID() and TNSequenceId__c in :parentAccountTNList and TNSequenceId__c <> null];
             
         for (Account a : accts){
            if ((a.Hierarchy_Level__c).equals(level))
            {
               if ( (!isLevelSummary) && (parentAccounts.size() > 0) )
               {
                  isParentExist = false;
                  for (Account parent : parentAccounts)
                  {
                    if ((a.ParentSequenceId__c).equals(parent.TNSequenceId__c))
                    {
                        isParentExist = true;
                        a.ParentId  = parent.ID;
                        break;
                    }
                  }
                  if (!isParentExist) a.ParentId = null;
               }
               else
                  a.ParentId = null;
               
               a.isDPILoad__c = 'FALSE';
               a.smasequenceid__c = '';       
               splitRecords.add(a);
            } 
         }
     }

     System.debug('No. of Records at level '+level+' getting inserted are :: '+splitRecords.size());
     return splitRecords;
  }

  // This method does set the hierarchy for ONLY dpi loaded records.  
  public static void setParentHierarchy(Map<Id, SObject> newItems)
  {
      System.debug('SetParentHierarchy Invoked :: '); 
      boolean isLevelSummary = false;
      ID parentAccountID = null;
      List<Account> updateAccounts = new List<Account>();

      Account updateAcc;
      Map<string, Account> accountItems = new Map<string, Account>();
      Map<string, ID> parentAccountItems = new Map<string, ID>();
      List<String> TNList = new List<String>(); 
      List<String> accountItemsParentTNList = new List<String>();
      
      // Build all TN's as a list so we can query DB with one sql.
      for(Account ac : (List<Account>) newItems.values())
          TNList.add(ac.TNSequenceId__c);
      
      System.debug('setParentHierarchy TNList size ::: '+TNList.size());
      // Query all and store them in a map for reference when needed.
      for (Account ab : [Select ID, TNSequenceId__c, isDPILoad__c, ParentSequenceId__c, SMASequenceID__c, ParentId from Account where RecordTypeId =: getRecordTypeID() and TNSequenceId__c in :TNList and TNSequenceId__c <> null])
      {
         accountItemsParentTNList.add(ab.ParentSequenceId__c);
         accountItems.put(ab.TNSequenceId__c, ab);
      }
      System.debug('setParentHierarchy account Items to be updated size ::: '+accountItemsParentTNList.size());
      
      // Query for all Parent Records
      for (Account pa : [Select ID, TNSequenceId__c from Account where RecordTypeId =: getRecordTypeID() and TNSequenceId__c in :accountItemsParentTNList and TNSequenceId__c <> null])
         parentAccountItems.put(pa.TNSequenceId__c, pa.ID);
        
      System.debug('setParentHierarchy parent account records size ::: '+parentAccountItems.size());
            
      for (Account a : (List<Account>) newItems.values())
      {
          parentAccountID = null;
          System.debug('SetParentHierarchy Record ::  Name: '+a.name+' , TNSequenceId__c: '+a.TNSequenceId__c+' , ParentSequenceId__c: '+a.ParentSequenceId__c+' , smasequenceid__c: '+a.smasequenceid__c+' , DPI_GANID__c: '+a.DPI_GANID__c+' , Account_Type__c: '+a.Account_Type__c+' , hierarchy_level__c: '+a.hierarchy_level__c+' , recordtype.name: '+a.RecordTypeId+' , ParentId: '+a.ParentId+' , isdpiload__C: '+a.isdpiload__C+' , createdDate: '+a.createdDate+' , createdby.name: '+a.createdby.name);
          if ( (a.isDPILoad__c == 'TRUE') && (validAccountLevels.contains(a.Hierarchy_Level__c)))
          {
             updateAcc = accountItems.get(a.TNSequenceId__c);
              if(updateAcc == null) continue;
             if (a.Hierarchy_Level__c.equalsIgnoreCase('SUMMARY'))
                isLevelSummary = true;
             else
                parentAccountID = parentAccountItems.get(updateAcc.ParentSequenceId__c);
                 
             if ( (!isLevelSummary) && (parentAccountID != null) )
             {
                if (updateAcc != null) {
                    if (updateAcc.TNSequenceId__c != updateAcc.ParentSequenceId__c)
                        updateAcc.ParentId  = parentAccountID;
                    updateAcc.SMASequenceID__c = '';
                    System.debug('SetParentHierarchy updated Account :: '+updateAcc); 
                }
             }
             else
                    updateAcc.ParentId = null;

             updateAcc.isDPILoad__c = 'FALSE';
             updateAccounts.add(updateAcc);
         }
     }
     
     if (updateAccounts.size() > 0)
       update updateAccounts; 
  }
  
  /*public static void deleteDPILoadRecords(Map<Id, SObject> newItems) {
     List<Account> listd = [Select id from account where isDPILoad__c = 'TRUE'];
     delete listd;
  }*/

  /*private static List<Account> extractToBeInserted(Map<string, Account> processedItems, Map<string, Account> existingItems) {
     List<Account> listf = new List<Account>();

     for (Account a : processedItems.values()) {
        if (!existingItems.containskey(a.TNSequenceId__c))
            listf.add(a);     
     }
     
     return listf;
  }*/
  
  private static String setAccountType(String accType){
    
    if ( (!String.isEmpty(accType))  && ((accType.trim()).isNumeric()))
          accType = acctTypes.get(Integer.valueOf(accType.trim()));
    return accType;
    
  }
  
  /*private static List<Account> extractToBeUpdated(Map<string, Account> processedItems, Map<string, Account> existingItems) {
     List<Account> listf = new List<Account>();

     for (Account a : processedItems.values()) {
        if (existingItems.containskey(a.TNSequenceId__c))
            listf.add(a);     
     }
     
     return listf;
  }*/

  // This method inserts record in Alt_Channel_Form__c.  
  public static void insertAltChannelForm(Map<Id, SObject> newItems)
  {
    List<Alt_Channel_Form__c> objList = new List<Alt_Channel_Form__c>();
    Alt_Channel_Form__c acf = null;
    
    if (rtMap == null) rtMap = Schema.SObjectType.Account.getRecordTypeInfosById();
           
    for (Account acct : (List<Account>) newItems.values())
    {
        if (acct.RecordTypeId != null && rtMap.get(acct.RecordTypeId).getName() == 'Alternate Channel') {
                acf = new Alt_Channel_Form__c();
                acf.AccountID__c = acct.ID;
                acf.Account_Name__c = acct.Name;
                acf.Legal_Entity_Name__c = acct.Company_Legal_Name__c;
                acf.DBA_Company_Name__c = acct.DBA_Company_Name__c;
                acf.Street_Address__c =  acct.Legal_Street__c;
                acf.City__c = acct.Legal_City__c;
                acf.State__c = acct.Legal_State1__c;
                acf.Zip_Postal_Code__c = acct.Legal_Zip__c;
                acf.Structure__c = acct.Type_of_Entity__c;
                acf.State_of_LLC__c =  acct.State_of_Formation__c;
                acf.Date_of_Formation__c = acct.Company_Date_of_Formation__c;
                acf.Tax_ID_Number__c = acct.Tax_ID_Number__c;
                acf.DUNS_Number__c = acct.D_U_N_S_Number__c;
                acf.Name_of_Principal__c = acct.Name_of_Principal__c;
                acf.SSN_of_Principal__c = acct.SSN_of_Principal__c;
                acf.Vendor_Profile_Date__c = acct.Vendor_Profile_Date__c;
                acf.Current_Frontier_Customer_Number__c = acct.Current_Frontier_Customer_Number__c;
                acf.Credit_Check_Pass_Fail__c = acct.Credit_Check_Pass_Fail__c;
                acf.Pass_Fail_Comments__c = acct.Pass_Fail_Comments__c;
                acf.Legal_Notice_Email_1__c = acct.Legal_Notice_Email_1__c;
                acf.Legal_Notice_Contact_Name_1__c = acct.Legal_Notice_Contact_Name_1__c;
                acf.Legal_Notice_Contact_Name_2__c = acct.Legal_Notice_Contact_Name_2__c;
                acf.Legal_Notice_Email_2__c = acct.Legal_Notice_Email_2__c;
                acf.Pass_Fail_Comments__c = acct.Pass_Fail_Comments__c;
                //acf.What_else_do_we_need_to_know__c = acct.What_else_do_we_need_to_know__c;
                acf.Legal_Notice_Email_1__c = acct.Legal_Notice_Email_1__c;
                acf.Channel_Affiliation__c = acct.Channel_Affiliation__c;
                //acf.Collections_Review_Pass_Fail__c = acct.Collections_Review_Pass_Fail__c;
                acf.Pass_Fail_Comments__c = acct.Pass_Fail_Comments__c;
                acf.Description_of_agent_work_to_be_done__c = acct.Description_of_agent_work_to_be_done__c;
                //acf.Effective_Date_of_Agreement__c = acct.Effective_Date_of_Agreement__c;
                
                objList.add(acf);
            }
    }
    
    if (!objList.isEmpty())
       insert objList;
  }

  
  // This method updates record in Alt_Channel_Form__c.  
  public static void updateAltChannelForm(Map<Id, SObject> newItems)
  {
    List<Alt_Channel_Form__c> modifyList = new List<Alt_Channel_Form__c>();
    List<Alt_Channel_Form__c> acf;
    boolean isRecordExists = false;
    Id AltChannelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alternate Channel').getRecordTypeId();
    
    if (rtMap == null) rtMap = Schema.SObjectType.Account.getRecordTypeInfosById();
           
    for (Account acct : (List<Account>) newItems.values())
    {
         if (acct.RecordTypeId != null && rtMap.get(AltChannelRecordTypeId) != null){
              acf = new List<Alt_Channel_Form__c>();
              acf = [SELECT Id,AccountID__c, Account_Name__c, Legal_Entity_Name__c, DBA_Company_Name__c, Street_Address__c, City__c, State__c, Zip_Postal_Code__c, Structure__c, State_of_LLC__c, Date_of_Formation__c, Tax_ID_Number__c, DUNS_Number__c, Name_of_Principal__c, SSN_of_Principal__c, Vendor_Profile_Date__c, Current_Frontier_Customer_Number__c,Credit_Check_Pass_Fail__c,Pass_Fail_Comments__c,updated_from_Account__c FROM Alt_Channel_Form__c where AccountID__c =: acct.ID LIMIT 1];
              isRecordExists = false;
                    
              if (!acf.isEmpty()){
                        isRecordExists = true;
                        acf[0].updated_from_Account__c = True;
                        acf[0].AccountID__c = acct.ID;
                        acf[0].Account_Name__c = acct.Name;
                        acf[0].Legal_Entity_Name__c = acct.Company_Legal_Name__c;
                        acf[0].DBA_Company_Name__c = acct.DBA_Company_Name__c;
                        acf[0].Street_Address__c =  acct.Legal_Street__c;
                        acf[0].City__c = acct.Legal_City__c;
                        acf[0].State__c = acct.Legal_State__c;
                        acf[0].Zip_Postal_Code__c = acct.Legal_Zip__c;
                        acf[0].Structure__c = acct.Type_of_Entity__c;
                        acf[0].State_of_LLC__c =  acct.State_of_Formation__c;
                        acf[0].Date_of_Formation__c = acct.Company_Date_of_Formation__c;
                        acf[0].Tax_ID_Number__c = acct.Tax_ID_Number__c;
                        acf[0].DUNS_Number__c = acct.D_U_N_S_Number__c;
                        acf[0].Name_of_Principal__c = acct.Name_of_Principal__c;
                        acf[0].SSN_of_Principal__c = acct.SSN_of_Principal__c;
                        acf[0].Vendor_Profile_Date__c = acct.Vendor_Profile_Date__c;
                        acf[0].Current_Frontier_Customer_Number__c = acct.Current_Frontier_Customer_Number__c;
                        acf[0].Credit_Check_Pass_Fail__c = acct.Credit_Check_Pass_Fail__c;
                        acf[0].Pass_Fail_Comments__c = acct.Pass_Fail_Comments__c;
                        acf[0].Legal_Notice_Email_1__c = acct.Legal_Notice_Email_1__c;
                        acf[0].Legal_Notice_Contact_Name_1__c = acct.Legal_Notice_Contact_Name_1__c;
                        acf[0].Legal_Notice_Contact_Name_2__c = acct.Legal_Notice_Contact_Name_2__c;
                        acf[0].Legal_Notice_Email_2__c = acct.Legal_Notice_Email_2__c;
                        acf[0].Pass_Fail_Comments__c = acct.Pass_Fail_Comments__c;
                        acf[0].What_else_do_we_need_to_know_about__c = acct.What_else_do_we_need_to_know_about__c;
                        acf[0].Legal_Notice_Email_1__c = acct.Legal_Notice_Email_1__c;
                        acf[0].Channel_Affiliation__c = acct.Channel_Affiliation__c;
                        acf[0].Credit_Check_Pass_Fail__c = acct.Credit_Check_Pass_Fail__c;
                        acf[0].Pass_Fail_Comments__c = acct.Pass_Fail_Comments__c;
                        acf[0].Description_of_agent_work_to_be_done__c = acct.Description_of_agent_work_to_be_done__c;
                        //acf[0].Effective_Date_of_Agreement__c = acct.Effective_Date_of_Agreement__c;
                }
                if (isRecordExists)
                   modifyList.add(acf[0]);
           }
    }
    
    if (!modifyList.isEmpty())
       update modifyList;
  }
  
    public static void createTotal360Lead(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Account> total360AccountIdToTotal360Account = new Map<Id, Account>();
        Map<Id, Account> fawUcaasAccountIdToFawUcaasAccount = new Map<Id, Account>();
        
        List<Id> leadCreationAccountIds = new List<Id>();
        for(Account acct : (List<Account>) newItems.values()) {
            Account oldValue = null;
            if(oldItems != null && oldItems.size() > 0) {
                oldValue = (Account) oldItems.get(acct.Id);
            }
            if(acct.Total_360__c == true && ((oldValue != null && oldValue.Total_360__c != True) || oldValue == null)) {
                total360AccountIdToTotal360Account.put(acct.Id, acct);
                leadCreationAccountIds.add(acct.Id);
            }
            if(acct.FAW_UCaaS__c == true && ((oldValue != null && oldValue.FAW_UCaaS__c != True) || oldValue == null)) {
                fawUcaasAccountIdToFawUcaasAccount.put(acct.Id, acct);
                leadCreationAccountIds.add(acct.Id);
            }
        }
        
        Campaign Total360Campaign = null;
        Campaign FawUcaasCampaign = null;
        
        if(leadCreationAccountIds.size() > 0) {
        
            //Total360Campaign = [SELECT id, name FROM Campaign WHERE name = 'Mitel _3000 Upgrade _Q22018' LIMIT 1];
            try {
                Total360Campaign = [SELECT id, name, product_name__c FROM Campaign WHERE product_name__c = 'Total 360' ORDER BY createddate desc LIMIT 1];
                FawUcaasCampaign = [SELECT id, name, product_name__c FROM Campaign WHERE product_name__c = 'FAW UCaaS' ORDER BY createddate desc LIMIT 1];
            } catch(QueryException e) {System.debug('FIND ME AccountUtility Query Expection: '+e.getMessage());}
        
            //Get all the territories for those accounts that haven't been flagged as deleted.
            List<ObjectTerritory2Association> accountTerritories = [SELECT id, IsDeleted, Territory2Id, objectId
                                                                    FROM ObjectTerritory2Association 
                                                                    WHERE IsDeleted = false 
                                                                    AND objectid IN :leadCreationAccountIds];
            
            List<Id> territoryIds = new List<Id>();
            Map<Id, Set<Id>> territoryIdToAccountIds = new Map<Id, Set<Id>>();
            for(ObjectTerritory2Association ot2a : accountTerritories) {
                Set<Id> accountIds = new Set<Id>();
                
                if(territoryIdToAccountIds.get(ot2a.Territory2Id) != null && territoryIdToAccountIds.get(ot2a.Territory2Id).size() > 0) accountIds = territoryIdToAccountIds.get(ot2a.Territory2Id);
                
                accountIds.add(ot2a.objectId);
                territoryIdToAccountIds.put(ot2a.Territory2Id, accountIds);
            }
            
            List<UserTerritory2Association> associatedCTFAccountExecs = [SELECT Id, IsActive, RoleInTerritory2, Territory2Id, UserId 
                                                                        FROM UserTerritory2Association 
                                                                        WHERE roleInTerritory2 = '#CTF AccountExec'
                                                                        AND territory2Id IN :territoryIdToAccountIds.keySet()];
            
            Map<Id, Id> accountIdToCTFAccountExecId = new Map<Id, Id>();
            for(UserTerritory2Association ctfAccExec : associatedCTFAccountExecs) {
                Set<Id> relatedAccountIds = territoryIdToAccountIds.get(ctfAccExec.Territory2Id);
                
                for(Id relatedAccountId : relatedAccountIds) accountIdToCTFAccountExecId.put(relatedAccountId, ctfAccExec.UserId);
            }
            
            List<Lead> leadsToCreate = new List<Lead>();
            for(Account acct : total360AccountIdToTotal360Account.values()) {
                Lead newLead = new Lead();
                newLead.company = acct.Name;
                newLead.status = 'Open';
                newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Default Lead').getRecordTypeId();
                newLead.phone = acct.phone;
                newLead.OwnerId = accountIdToCTFAccountExecId.get(acct.Id);
                newLead.Lead_Stage__c = 'Prospect';
                newLead.lastName = acct.Name;
                newLead.SIC__c = acct.Sic;
                newLead.SIC_Description__c = acct.SicDesc;
                //if(acct.Number_of_Employees__c != null) {
                    //newLead.NumberOfEmployees = acct.Number_of_Employees__c.IntValue();
                    newLead.NumberOfEmployees = acct.NumberOfEmployees;
                    newLead.Number_of_Employees__c = acct.NumberOfEmployees;
                //}
                newLead.LeadSource = '2018 Marketing Campaign';
                newLead.Product_Type__c = 'Total 360';
                if(Total360Campaign != null) {
                    newLead.Campaign__c = Total360Campaign.Id;
                }
                
                if(accountIdToCTFAccountExecId.get(acct.Id) != null) leadsToCreate.add(newLead);
            }
            
            for(Account acct : fawUcaasAccountIdToFawUcaasAccount.values()) {
                Lead newLead = new Lead();
                newLead.company = acct.Name;
                newLead.status = 'Open';
                newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Default Lead').getRecordTypeId();
                newLead.phone = acct.phone;
                newLead.OwnerId = accountIdToCTFAccountExecId.get(acct.Id);
                newLead.Lead_Stage__c = 'Prospect';
                newLead.lastName = acct.Name;
                newLead.SIC__c = acct.Sic;
                newLead.SIC_Description__c = acct.SicDesc;
                //if(acct.Number_of_Employees__c != null) {
                    //newLead.NumberOfEmployees = acct.Number_of_Employees__c.IntValue();
                    newLead.NumberOfEmployees = acct.NumberOfEmployees;
                    newLead.Number_of_Employees__c = acct.NumberOfEmployees;
                //}
                newLead.LeadSource = '2018 Marketing Campaign';
                newLead.Product_Type__c = 'Total 360';//'FAW UCaaS';
                if(FawUcaasCampaign != null) {
                    newLead.Campaign__c = FawUcaasCampaign.Id;
                }
                
                if(accountIdToCTFAccountExecId.get(acct.Id) != null) leadsToCreate.add(newLead);
            }
            
            if(leadsToCreate != null && leadsToCreate.size() > 0) {
                insert leadsToCreate;
                
                List<CampaignMember> campaignMembersToCreate = new List<CampaignMember>();
                for(Lead insertedLead : leadsToCreate) {
                    CampaignMember campMem = new CampaignMember();
                    
                    if(insertedLead.Product_Type__c == 'Total 360') campMem.CampaignId = Total360Campaign!=null?Total360Campaign.Id:null;
                    
                    if(insertedLead.Product_Type__c == 'FAW UCaaS') campMem.CampaignId = FawUcaasCampaign.Id;
                    
                    campMem.LeadId = insertedLead.Id;
                    campMem.Status = 'Sent';
                    
                    campaignMembersToCreate.add(campMem);
                }
                try{
                    if(campaignMembersToCreate != null && campaignMembersToCreate.size() > 0) insert campaignMembersToCreate;
                }catch(exception ee){}
                
            }
        }//end of if(leadCreationAccountIds.size() > 0)
    }//end of createTotal360Lead(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    public static void newServiceAccountOwner(List<SObject> newItems){
        List<Account> lstAccount = (List<Account>) newItems;
        Set<Id> parentAccountIds = new Set<Id>();
        Id serviceRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        Id masterRecordTypeId = [select id from RecordType where RecordType.Name = 'Master' and SobjectType = 'Account'].Id;//Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master').getRecordTypeId();
        
        system.debug('serviceRecordTypeId ::: '+serviceRecordTypeId);
        system.debug('masterRecordTypeId ::: '+masterRecordTypeId);
        for(Account acc : lstAccount){
            if(acc.recordTypeId == serviceRecordTypeId && acc.ParentId != null){
                parentAccountIds.add(acc.ParentId);
            }
        }
        
        if(parentAccountIds.size() == 0) return;
        
        Map<Id,Account> mapAccMaster = new Map<Id,Account>([select id,RecordTypeId,OwnerId, Territory_Name__c, Customer_Number__c from Account where Id IN : parentAccountIds AND RecordTypeId =: masterRecordTypeId]);
        
        for(Account acc : lstAccount){
            if(acc.ParentId != null && mapAccMaster.containsKey(acc.ParentId) && (acc.OwnerId != mapAccMaster.get(acc.ParentId).OwnerId || acc.Territory_Name__c != mapAccMaster.get(acc.ParentId).Territory_Name__c || acc.Customer_Number__c != mapAccMaster.get(acc.ParentId).Customer_Number__c)){
                acc.OwnerId = mapAccMaster.get(acc.ParentId).OwnerId;
                acc.Territory_Name__c = mapAccMaster.get(acc.ParentId).Territory_Name__c;
                acc.Customer_Number__c = mapAccMaster.get(acc.ParentId).Customer_Number__c;
            }
        }
    }
    //If master Account is updated with these 3 fields then accordingly update All child service Accounts . 
    public static void serviceAccountOwnerChange(List<SObject> newItems , Map<Id, SObject> oldItems){
        List<Account> lstAccount = (List<Account>) newItems;
        Map<Id,Account> mapParentAccount = new Map<Id,Account>();
        
        Id serviceRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master').getRecordTypeId();
        //Id masterRecordTypeId = [select id from RecordType where RecordType.Name = 'Master' and SobjectType = 'Account'].Id;//Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master').getRecordTypeId();
        for(Account acc : lstAccount){
            Account oldVersion = (Account) oldItems.get(acc.Id);
            system.debug('acc.recordTypeId11 :: '+acc.recordTypeId);
            system.debug('masterRecordTypeId11 :: '+masterRecordTypeId);
            system.debug('oldVersion.ownerId11 :: '+oldVersion.ownerId);
            system.debug('acc.OwnerId11 :: '+acc.OwnerId);
            
            if(acc.recordTypeId == masterRecordTypeId && (oldVersion.ownerId != acc.OwnerId || oldVersion.Territory_Name__c != acc.Territory_Name__c || oldVersion.Customer_Number__c != acc.Customer_Number__c))
                mapParentAccount.put(acc.Id,acc);
        }
        
        if(mapParentAccount.size() == 0) return;
        
        List<Account> lstQueryServiceAccounts = [select id,ownerId,ParentId,Territory_Name__c,Customer_Number__c from Account where ParentId IN : mapParentAccount.keySet() AND RecordTypeId =:serviceRecordTypeId FOR UPDATE];
        for(Account acc : lstQueryServiceAccounts){
            if(acc.OwnerId != mapParentAccount.get(acc.ParentId).OwnerId || acc.Territory_Name__c != mapParentAccount.get(acc.ParentId).Territory_Name__c || acc.Customer_Number__c != mapParentAccount.get(acc.ParentId).Customer_Number__c){
                acc.OwnerId = mapParentAccount.get(acc.ParentId).OwnerId;
                acc.Territory_Name__c = mapParentAccount.get(acc.ParentId).Territory_Name__c;
                acc.Customer_Number__c = mapParentAccount.get(acc.ParentId).Customer_Number__c;
            }
        }
        AccountUtility.isRecursiveTrigger = true;
        if(lstQueryServiceAccounts.size() > 350 || Test.isRunningTest())  System.enqueueJob(new ServiceAccountOwnerChange(lstQueryServiceAccounts,true));
        else update lstQueryServiceAccounts;
    }
    
    public static void updateServiceAccountValidation(List<SObject> newItems,Map<Id, SObject> oldItems){
        List<Account> lstAccount = (List<Account>) newItems;
        Id serviceRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master').getRecordTypeId();
        //Id masterRecordTypeId = [select id from RecordType where RecordType.Name = 'Master' and SobjectType = 'Account'].Id;
        Set<Id> parentAccountIds = new Set<Id>();
        
        for(Account acc : lstAccount){
            if(acc.recordTypeId == serviceRecordTypeId && acc.ParentId != null) parentAccountIds.add(acc.ParentId);
        }
        
        Map<Id,Account> mapAccMaster = new Map<Id,Account>([select id,RecordTypeId,OwnerId, Territory_Name__c, Customer_Number__c from Account where Id IN : parentAccountIds AND RecordTypeId =: masterRecordTypeId]);
        
        for(Account acc : lstAccount){
            Account oldVersion = mapAccMaster.get(acc.ParentId);//(Account) oldItems.get(acc.Id);
            if(oldVersion != null && acc.ParentId != null && acc.recordTypeId == serviceRecordTypeId && (acc.OwnerId != oldVersion.OwnerId || acc.Territory_Name__c != oldVersion.Territory_Name__c || acc.Customer_Number__c != oldVersion.Customer_Number__c)){
                acc.OwnerId = oldVersion.OwnerId;
                acc.Territory_Name__c = oldVersion.Territory_Name__c;
                acc.Customer_Number__c = oldVersion.Customer_Number__c;
            }
        }
    }
    
    public static void OwnerChange(List<SObject> newItems,Map<Id, SObject> oldItems){

        Id masterRecordTypeId = [SELECT id FROM RecordType WHERE RecordType.Name = 'Master' and SobjectType = 'Account'].Id;
        Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        Id globalRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global').getRecordTypeId();

        List<Account> lstAccount = (List<Account>) newItems;
        if(lstAccount.size() == 1){
            Account acc = lstAccount[0];
            Account oldVersion = (Account) oldItems.get(acc.Id);
            if((acc.RecordTypeId == globalRecordTypeId || acc.RecordTypeId == orgRecordTypeId || acc.RecordTypeId == masterRecordTypeId) && acc.OwnerId != oldVersion.OwnerId){
                Database.executeBatch(new BatchClassOwnerChange(acc.Id,acc.OwnerId), 200);
            }
        }
    }    
}