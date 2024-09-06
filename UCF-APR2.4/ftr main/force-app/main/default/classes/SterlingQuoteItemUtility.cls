public with sharing class SterlingQuoteItemUtility {

    
    public static void setApproverAndOwner(List<SterlingQuoteItem__c> sqiList){
        setSalesEngineerandApprovalOwner(sqiList);
        setNextApprover(sqiList);
    }
    
    /*
         This trigger sets the sales engineer and the Intm owner at the beginning of the approval process.
         Also sets the original owner when the approval process ends.
    */
    private static void setSalesEngineerandApprovalOwner(List<SterlingQuoteItem__c> sqiList){
        for(SterlingQuoteItem__c objs : sqiList){
            // Set Item owner before approvals so OwnerId can be used for the current approver
            if(objs.ItemOwner__c == null) objs.ItemOwner__c = objs.OwnerId;
            
            // Set Ownerid back to original owner when overall status changes from pending
            if(objs.OverallStatus__c != 'Pending')
                    if(objs.ItemOwner__c != null) objs.OwnerId = objs.ItemOwner__c;
                    
            
            if(objs.PriorStatus__c=='Assigned - Sales Engineer' && objs.CurrentStatus__c=='Pending - Engineering'){
                if(objs.SalesEngineer__c== null) objs.SalesEngineer__c = userinfo.getuserid();
                if(objs.IsInFrontierFootprint__c== false) objs.CurrentStatus__c = 'Pending - INA';
            }
            else
            {
                // wireless test
                if(objs.PriorStatus__c=='Approved - Engineering Wireless' && objs.CurrentStatus__c=='Pending - Engineering Wireless' && objs.SalesEngineer__c== null)
                    objs.SalesEngineer__c= userinfo.getuserid();
                else
                {
                    // If Renewal and Sales Engineer not assigned, Set to Original Owner. 
                    // Renewals INA
                    if(objs.PriorStatus__c=='Approved - Engineering' && objs.CurrentStatus__c=='Pending - INA' && objs.IsInFrontierFootprint__c==false && objs.SalesEngineer__c== null)
                       objs.SalesEngineer__c= objs.ItemOwner__c;
                    // Renewal Standard   
                    else if(objs.PriorStatus__c=='Approved - Finance' && objs.CurrentStatus__c=='Pending - Credit' && objs.IsInFrontierFootprint__c==true && objs.SalesEngineer__c == null)
                        objs.SalesEngineer__c= objs.ItemOwner__c;
                }                
            }
        }
    }
    
    // Set Next Approver - Updated by Mohan
    private static void setNextApprover(List<SterlingQuoteItem__c> sqiList){
    
        String ListVar, QSS, SEM, RFR, INAGROUP, EngWireless, EngWirelessMgr, EngWirelessMgrMgr, Credit, Eng, BDS, Finance, SVP, RVP, SiteVerification, queuesObjectType, qsuffix;
        List<QueueSuffix__c> lstQS;
        id nextapprover, sliid;
        QueueSobject queueId;
        list<QueueSobject> lstqueueid;

        for(SterlingQuoteItem__c objs : sqiList) {
        
           if(objs.SetNextApprover__c == true) { 
           
               queueId = new QueueSobject();
               system.debug('Approval Territory = ' + objs.ApprovalTerritory__c);      
               QueueSuffix__c QS  = new QueueSuffix__c();
               ListVar = objs.ApprovalTerritory__c;
               lstQS = [Select ApprovalQueueSuffix__c from qUEUEsUFFIX__C WHERE Name =: ListVar];
               if(!lstQS.isEmpty()) QS = lstQS[0];
               QSS = QS.ApprovalQueueSuffix__c;
               if (QSS== null) QS.ApprovalQueueSuffix__c = 'CT';
               SEM = 'Sales Engineering Manager ' + objs.ApprovalRegion__c;
               // Add Regional Queues for Ready for Review Originally developed for 1 queue
               RFR = 'Ready For Review ' + objs.ApprovalRegion__c;
               INAGROUP = 'INA Group';
               EngWireless = 'Engineering Wireless';
               EngWirelessMgr = 'Wireless Engineering Management';
               EngWirelessMgrMgr = 'Wireless Engineering Manager';
               Credit = 'Credit';
               Eng = 'Engineering - ' + QS.ApprovalQueueSuffix__c;
               BDS = 'BDS - ' + QS.ApprovalQueueSuffix__c;
               Finance = 'Finance - ' + QS.ApprovalQueueSuffix__c;
               system.debug('Finance Queue Name = ' + Finance);
               SVP = 'SVP - ' + QS.ApprovalQueueSuffix__c;
               RVP = 'RVP - ' + QS.ApprovalQueueSuffix__c;
               SiteVerification = 'Site Verification - ' + QS.ApprovalQueueSuffix__c;
               queuesObjectType = 'SterlingQuoteItem__c';
               qsuffix = null;
               sliid = objs.id;
               
               system.debug('SLIID = ######## ' + sliid);
               system.debug('Current Status = ' + objs.CurrentStatus__c);
               system.debug('SEM Queue ID = ' + SEM);

               // Bypass Sales Engineering Manager straight to Finance for Renewals
               if(objs.CurrentStatus__c=='Pending - Sales Engineering Manager'){
                    if(objs.ApprovalRouting__c == 'Renewal / Special Pricing') 
                       objs.CurrentStatus__c='Pending - Finance';
                    else if(objs.ApprovalRouting__c == 'Renewal / Special Pricing - SMB Only') 
                            objs.CurrentStatus__c='Pending - Finance';
               }
    
               if(objs.CurrentStatus__c=='Pending - Sales Engineering Manager'){
                    lstqueueid = [Select id, queueid from QueueSobject  where Queue.Name =: SEM and SobjectType =:queueSObjectType];
                    if(!lstqueueid.isEmpty()) queueId = lstqueueid[0];
               }
            
               if(objs.CurrentStatus__c=='Pending - Engineering')
                    queueId = [Select id, queueid   from QueueSobject q where q.Queue.Name =: Eng And q.SobjectType =:queueSObjectType];
                 
               if(objs.ApprovalTerritory__c == 'National') {
                  if(objs.CurrentStatus__c=='Pending Ready for Review')
                     objs.CurrentStatus__c='Pending - State VP';
               }     
                   
               if(objs.CurrentStatus__c=='Pending - Engineering'){
                  if(objs.ApprovalRouting__c.contains('Renewal'))
                    queueId = [Select id, queueid   from QueueSobject q where q.Queue.Name =: Finance And q.SobjectType =:queueSObjectType];
               }
        
               if(objs.CurrentStatus__c=='Pending - INA')
                  queueId = [Select id, queueid from QueueSobject q where q.Queue.Name =: INAGROUP and q.SobjectType=:queueSObjectType];
                
               if(objs.CurrentStatus__c=='Pending - Sales Engineering')
                  queueId = [Select id, queueid from QueueSobject q where q.Queue.Name =: EngWireless and q.SobjectType=:queueSObjectType];
                
               if(objs.CurrentStatus__c=='Pending - Engineering Wireless')
                  queueId = [Select id, queueid from QueueSobject q where q.Queue.Name =: Eng and q.SobjectType=:queueSObjectType];
                
               if(objs.CurrentStatus__c=='Pending - Site Verification')
                  queueId = [Select id, queueid from QueueSobject q where q.Queue.Name =: SiteVerification and q.SobjectType=:queueSObjectType];
                
               if(objs.CurrentStatus__c=='Pending - Engineering Wireless Final')
                  queueId = [Select id, queueid from QueueSobject q where q.Queue.Name =: EngWireless  and q.SobjectType=:queueSObjectType];
                
               if(objs.CurrentStatus__c=='Pending - Wireless Management && objs.Total_Price__c :< 25000.01')
                  queueId = [Select id, queueid from QueueSobject q where q.Queue.Name =: EngWirelessMgr  and q.SobjectType=:queueSObjectType];
                
               if(objs.CurrentStatus__c=='Pending - Wireless Management && objs.Total_Price__c :> 25000')
                  queueId = [Select id, queueid from QueueSobject q where q.Queue.Name =: EngWirelessMgrMgr and q.SobjectType=:queueSObjectType];
                
               if(objs.CurrentStatus__c=='Pending - Credit')
                  queueId = [Select id, queueid from QueueSobject q where q.Queue.Name =: Credit and q.SobjectType=:queueSObjectType];
                
               if(objs.CurrentStatus__c=='Pending - Business Decision Support')
                  queueId = [Select id, queueid from QueueSobject q where q.Queue.Name =: BDS and q.SobjectType=:queueSObjectType];
                           
               if(objs.CurrentStatus__c=='Pending - Finance')
                  queueId = [Select id, queueid from QueueSobject q where q.Queue.Name =: Finance and q.SobjectType=:queueSObjectType];
                 
               if(objs.CurrentStatus__c=='Pending Ready for Review'){
                    lstqueueid = [Select id, queueid from QueueSobject  where Queue.Name =: RFR and SobjectType =:queueSObjectType];
                    if(!lstqueueid.isEmpty()) queueId = lstqueueid[0];
               }
                    
               if(objs.CurrentStatus__c=='Pending - State VP')
                  queueId = [Select id, queueid from QueueSobject q where q.Queue.Name =: SVP and q.SobjectType=:queueSObjectType];
                
               if(objs.CurrentStatus__c=='Pending - Regional President')
                  queueId = [Select id, queueid from QueueSobject q where q.Queue.Name =: RVP and q.SobjectType=:queueSObjectType];
               
               if(objs.CurrentStatus__c=='Pending - Post Completion Audit Finance')
                  queueId = [Select id, queueid from QueueSobject q where q.Queue.Name =: Finance and q.SobjectType=:queueSObjectType];

               // finally set the nextApprover 
               if ((queueId != null) && (queueId.QueueId != null)) nextapprover = queueId.QueueId;
               // MGG319 1/7/2019  Set Next Approver to RSM for Pending - RSM step in CAPEX approval Process
               if(objs.CurrentStatus__c=='Pending - RSM Approval')
                nextapprover = objs.Owner_Manager_Id__c;
                    system.debug('Current Status = ' + objs.CurrentStatus__c);
//                    system.debug('Owner = ' + objs.Owner);
                    system.debug('Manager = ' + objs.Owner_Manager__c);
                    system.debug('Next Approver = ' + nextapprover);
               // MGG319 1/14/2019  Set Next Approver to AE for Pending - AE Update step in CAPEX approval Process 
                    objs.OwnerId = objs.ItemOwner__c;  
                  system.debug('Object Owner = ' + objs.ItemOwner__c);
                  if(objs.CurrentStatus__c=='Pending AE Update')
                      
                    nextapprover = objs.Ownerid;
                    system.debug('Current Status = ' + objs.CurrentStatus__c);
                    system.debug('Owner = ' + objs.Owner);
                    system.debug('OwnerId = ' + objs.Ownerid);
                    system.debug('Next Approver = ' + nextapprover);  
        
               if(nextapprover != null)
                  objs.OwnerId = nextApprover;
           }
       }
   }
   
//---

    public static void checkOpportunityCheckboxes(boolean isInsert, boolean isUpdate, List<SterlingQuoteItem__c> newItemsList, List<SterlingQuoteItem__c> oldItemsList) {
        Map<Id, Boolean> sqiIdTohasProductCategoryChanged = new Map<Id, Boolean>();
        Map<Id, String> productIdToProductCategory = new Map<Id, String>();
        Map<Id, Opportunity> opportunityIdToOpportunity = new Map<Id, Opportunity>();
        Set<Opportunity> opportunitiesToUpdate = new Set<Opportunity>();

        Map<Id, Id> sterlingQuoteItemIdToSterlingQuoteId = new Map<Id, Id>();
        Map<Id, Id> sterlingQuoteIdToOpportunityId = new Map<Id, Id>();
        
        List<Id> productIds = new List<Id>();
        if(newItemsList != null) {
            for(SterlingQuoteItem__c sqi : newItemsList) {
                productIds.add(sqi.Products__c);
                sterlingQuoteItemIdToSterlingQuoteId.put(sqi.Id, sqi.SterlingQuote__c);
            }
        }
        if(oldItemsList != null) {
            for(SterlingQuoteItem__c sqi : oldItemsList) {
                productIds.add(sqi.Products__c);
                sterlingQuoteItemIdToSterlingQuoteId.put(sqi.Id, sqi.SterlingQuote__c);
            }
        }
        
        for(Product2 prod : [SELECT id, family FROM Product2 WHERE id IN :productIds]) {
            productIdToProductCategory.put(prod.Id, prod.family);
        }
        
        for(SterlingQuote__c sq : [SELECT id, OpportunityId__c FROM SterlingQuote__c WHERE id IN :sterlingQuoteItemIdToSterlingQuoteId.values()]) {
            sterlingQuoteIdToOpportunityId.put(sq.Id, sq.OpportunityId__c);
        }
        
        for(Opportunity opp : [SELECT id, Cloud_IT__c, Enterprise_WIFI__c, Ethernet__c, FAW_UCaaS__c FROM Opportunity WHERE id IN :sterlingQuoteIdToOpportunityId.values()]) {
            opportunityIdToOpportunity.put(opp.Id, opp);
        }
        
        if(isUpdate) {
            for(SterlingQuoteItem__c newSqi : newItemsList) {
                for(SterlingQuoteItem__c oldSqi : oldItemsList) {
                    if(newSqi.Id == oldSqi.Id && newSqi.Products__c != oldSqi.Products__c) {
                        sqiIdTohasProductCategoryChanged.put(newSqi.Id, true);
                    }
                }
            }
        }
        
        for(SterlingQuoteItem__c sqi : newItemsList) {
            if(isInsert || (isUpdate && sqiIdTohasProductCategoryChanged.size() > 0 && sqiIdTohasProductCategoryChanged.get(sqi.Id))) {
                Id parentSqId = sterlingQuoteItemIdToSterlingQuoteId.get(sqi.Id);
                Id parentOppId = sterlingQuoteIdToOpportunityId.get(parentSqId);
                
                Opportunity opp = opportunityIdToOpportunity.get(parentOppId);
                List<Opportunity> oppList = new List<Opportunity>(opportunitiesToUpdate);
                if(oppList.contains(opp) == true) {
                    opp = oppList.get(oppList.indexOf(opp));
                    opportunitiesToUpdate.remove(Opp);
                }
                
                String prodCat = productIdToProductCategory.get(sqi.Products__c);
                if(prodCat == 'Ethernet') {
                    opp.Ethernet__c = true;
                } else if(prodCat == 'Cloud Managed Solutions') {
                    opp.Cloud_IT__c = true;
                } else if(prodCat == 'Manage Enterprise WiFi') {
                    opp.Enterprise_WIFI__c = true;
                } else if(prodCat == 'Frontier AnyWare') {
                    opp.FAW_UCaaS__c = true;
                }
                
                opportunitiesToUpdate.add(opp);
            }
        }
        
        if(opportunitiesToUpdate.size() > 0) {
            List<Opportunity> oppUpList = new List<Opportunity>(opportunitiesToUpdate);
            update oppUpList;
        }
    }
    
    public static void uncheckOpportunityCheckboxes(boolean isUpdate, boolean isDelete, List<SterlingQuoteItem__c> newItemsList, List<SterlingQuoteItem__c> oldItemsList) {
        //Gather a list of all the Quote Items that might justify unchecking a checkbox
            //Gather all the parent Opportunities for those SQIs
        Map<Id, Boolean> sqiIdTohasProductCategoryChanged = new Map<Id, Boolean>();
        Map<Id, Id> sterlingQuoteItemIdToSterlingQuoteId = new Map<Id, Id>();
        Map<Id, Id> sterlingQuoteIdToOpportunityId = new Map<Id, Id>();
        Map<Id, Opportunity> opportunityIdToOpportunity = new Map<Id, Opportunity>();
        Map<Id, Set<Id>> opportunityIdToSetOfEthernetSQIs = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> opportunityIdToSetOfCloudItSQIs = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> opportunityIdToSetOfEnterpriseWifiSQIs = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> opportunityIdToSetOfFAWUcaasSQIs = new Map<Id, Set<Id>>();
        List<Id> productIds = new List<Id>();
                
        if(isUpdate) {
            for(SterlingQuoteItem__c newSqi : newItemsList) {
                for(SterlingQuoteItem__c oldSqi : oldItemsList) {
                    if(newSqi.Id == oldSqi.Id && newSqi.Products__c != oldSqi.Products__c) {
                        sqiIdTohasProductCategoryChanged.put(newSqi.Id, true);
                    }
                    
                    sterlingQuoteItemIdToSterlingQuoteId.put(newSqi.Id, newSqi.SterlingQuote__c);
                    productIds.add(newSqi.Products__c);
                }
            }
        } else {
            for(SterlingQuoteItem__c oldSqi : oldItemsList) {
                sqiIdTohasProductCategoryChanged.put(oldSqi.Id, true);
                sterlingQuoteItemIdToSterlingQuoteId.put(oldSqi.Id, oldSqi.SterlingQuote__c);
                productIds.add(oldSqi.Products__c);
            }
        }
        
        for(SterlingQuote__c sq : [SELECT id, OpportunityId__c FROM SterlingQuote__c WHERE id IN :sterlingQuoteItemIdToSterlingQuoteId.values()]) {
            sterlingQuoteIdToOpportunityId.put(sq.Id, sq.OpportunityId__c);
        }
        
        for(Opportunity opp : [SELECT id, Cloud_IT__c, Enterprise_WIFI__c, Ethernet__c, FAW_UCaaS__c FROM Opportunity WHERE id IN :sterlingQuoteIdToOpportunityId.values()]) {
            opportunityIdToOpportunity.put(opp.Id, opp);
        }
        
        List<Id> allTheSQIdsRelatedToRelevantParentOpportunities = new List<Id>();
        for(SterlingQuote__c sq : [SELECT id, OpportunityId__c FROM SterlingQuote__c WHERE OpportunityId__c IN :opportunityIdToOpportunity.keySet()]) {
            allTheSQIdsRelatedToRelevantParentOpportunities.add(sq.Id);
        }
        
        Map<Id, SterlingQuoteItem__c> sqiIdToAllTheSQIsRelatedToRelevantParentOpportunities = new Map<Id, SterlingQuoteItem__c>();
        for(SterlingQuoteItem__c sqi : [SELECT id, SterlingQuote__c, Products__c FROM SterlingQuoteItem__c WHERE SterlingQuote__c IN :allTheSQIdsRelatedToRelevantParentOpportunities]) {
            sqiIdToAllTheSQIsRelatedToRelevantParentOpportunities.put(sqi.Id, sqi);
        }
        
        //Assemble a list of the SQIs that justify each checkbox on each relevant Opportunity, excluding those that are being removed
        Map<Id, String> productIdToProductCategory = new Map<Id, String>();
        for(Product2 prod : [SELECT id, family FROM Product2 WHERE id IN :productIds]) {
            productIdToProductCategory.put(prod.Id, prod.family);
        }

        for(SterlingQuoteItem__c sqi : sqiIdToAllTheSQIsRelatedToRelevantParentOpportunities.values()) {
            Id parentSqId = sterlingQuoteItemIdToSterlingQuoteId.get(sqi.Id);
            Id parentOppId = sterlingQuoteIdToOpportunityId.get(parentSqId);
            
            if(sqiIdTohasProductCategoryChanged.get(sqi.Id) != null && sqiIdTohasProductCategoryChanged.get(sqi.Id) == true) {
                String prodCat = productIdToProductCategory.get(sqi.Products__c);
                if(prodCat == 'Ethernet') {
                    Set<Id> categorySqis = new Set<Id>();
                    if(opportunityIdToSetOfEthernetSQIs.get(parentOppId) != null) {
                        categorySqis = opportunityIdToSetOfEthernetSQIs.get(parentOppId);
                    }
                    categorySqis.add(sqi.Id);
                    opportunityIdToSetOfEthernetSQIs.put(parentOppId, categorySqis);
                } else if(prodCat == 'Cloud Managed Solutions') {
                    Set<Id> categorySqis = new Set<Id>();
                    if(opportunityIdToSetOfCloudItSQIs.get(parentOppId) != null) {
                        categorySqis = opportunityIdToSetOfCloudItSQIs.get(parentOppId);
                    }
                    categorySqis.add(sqi.Id);
                    opportunityIdToSetOfCloudItSQIs.put(parentOppId, categorySqis);
                } else if(prodCat == 'Manage Enterprise WiFi') {
                    Set<Id> categorySqis = new Set<Id>();
                    if(opportunityIdToSetOfEnterpriseWifiSQIs.get(parentOppId) != null) {
                        categorySqis = opportunityIdToSetOfEnterpriseWifiSQIs.get(parentOppId);
                    }
                    categorySqis.add(sqi.Id);
                    opportunityIdToSetOfEnterpriseWifiSQIs.put(parentOppId, categorySqis);
                } else  if(prodCat == 'Frontier AnyWare') {
                    Set<Id> categorySqis = new Set<Id>();
                    if(opportunityIdToSetOfFAWUcaasSQIs.get(parentOppId) != null) {
                        categorySqis = opportunityIdToSetOfFAWUcaasSQIs.get(parentOppId);
                    }
                    categorySqis.add(sqi.Id);
                    opportunityIdToSetOfFAWUcaasSQIs.put(parentOppId, categorySqis);
                }
            }
        }
        
        //Reevaluate the justification for each checkbox and uncheck those no longer justified
        Set<Opportunity> opportunitiesToUpdate = new Set<Opportunity>();
        
        for(Opportunity opp : opportunityIdToOpportunity.values()) {
            if(opportunityIdToSetOfEthernetSQIs.get(opp.Id) == null || (opportunityIdToSetOfEthernetSQIs.get(opp.Id) != null && opportunityIdToSetOfEthernetSQIs.get(opp.Id).size() == 0)) {
                opp.Ethernet__c = false;
            }
            if(opportunityIdToSetOfCloudItSQIs.get(opp.Id) == null || (opportunityIdToSetOfCloudItSQIs.get(opp.Id) != null && opportunityIdToSetOfCloudItSQIs.get(opp.Id).size() == 0)) {
                opp.Cloud_IT__c = false;
            }
            if(opportunityIdToSetOfEnterpriseWifiSQIs.get(opp.Id) == null || (opportunityIdToSetOfEnterpriseWifiSQIs.get(opp.Id) != null && opportunityIdToSetOfEnterpriseWifiSQIs.get(opp.Id).size() == 0)) {
                opp.Enterprise_WIFI__c = false;
            }
            if(opportunityIdToSetOfFAWUcaasSQIs.get(opp.Id) == null || (opportunityIdToSetOfFAWUcaasSQIs.get(opp.Id) != null && opportunityIdToSetOfFAWUcaasSQIs.get(opp.Id).size() == 0)) {
                opp.FAW_UCaaS__c = false;
            }
            
            opportunitiesToUpdate.add(opp);
        }
        
        if(opportunitiesToUpdate.size() > 0) {
            List<Opportunity> oppUpList = new List<Opportunity>(opportunitiesToUpdate);
            update oppUpList;
        }
    }

    public static void deleteDuplicateQuoteLineItems(boolean isDelete, List<SterlingQuoteItem__c> itemLists) {
        //The list of Sterling Quote Items we're going to update or delete.
        List<SterlingQuoteItem__c> sterlingQuoteItemsToUpdate = new List<SterlingQuoteItem__c>();
        List<SterlingQuoteItem__c> sterlingQuoteItemsToDelete = new List<SterlingQuoteItem__c>();
        
        //store the combination of a composite id to the incoming SQI for ease of retrieval later.
        Map<String, SterlingQuoteItem__c> sqiCompositeIdToIncomingSQI = new Map<String, SterlingQuoteItem__c>();
        List<Id> incomingSQIIds = new List<Id>();
        List<Id> incomingSQIIdsToDelete = new List<Id>();
        
        //For querying purposes, we need a list of all the components of the composite id.
        List<String> incomingSQINames = new List<String>();
        List<Id> incomingSQIProducts = new List<Id>();
        List<Id> incomingSQIQuotes = new List<Id>();
        
        for(SterlingQuoteItem__c sqi : itemLists) {
        // MGG319 2/8/2019 Added CTRA to block Duplicates when ICBA or CTRA back from Sterling
            if(sqi.DiscountType__c == 'ICBA'|| sqi.DiscountType__c == 'CTRA') {
                //build our composite key
                String compositeId = sqi.name + '_' + sqi.Products__c + '_' + sqi.SterlingQuote__c;
                
                //add this to the map
                sqiCompositeIdToIncomingSQI.put(compositeID, sqi);
                incomingSQIIds.add(sqi.Id);
                
                //build our list of composite values for a subsequent query
                incomingSQINames.add(sqi.name);
                incomingSQIProducts.add(sqi.Products__c);
                incomingSQIQuotes.add(sqi.SterlingQuote__c);
            }
        }
        
        //We're gonna want a mapping of composite keys to existing Sterling Quote Items as well.
        Map<String, SterlingQuoteItem__c> sqiCompositeIdToExistingSQI = new Map<String, SterlingQuoteItem__c>();
        
        //If there are incoming Sterling Quote Items we want to check for existing, related Sterling Quote Items...
        if(sqiCompositeIdToIncomingSQI != null && !sqiCompositeIdToIncomingSQI.isEmpty()) {
        
            //...then query for all related SQIs as defined by having a value from each of the composite value lists.
            List<SterlingQuoteItem__c> relatedSterlingQuoteItems = [SELECT id, name, NetNewMRR__c, DiscountAmount__c, PercentageDiscountAmount__c, AdjustedMRC__c, AdjustedNRC__c, DiscountType__c, StandardMRC__c, StandardNRC__c, Products__c, SterlingQuote__c
                                            FROM SterlingQuoteItem__c 
                                            WHERE name IN :incomingSQINames
                                            AND Products__c IN :incomingSQIProducts
                                            AND SterlingQuote__c IN :incomingSQIQuotes
                                            AND id NOT IN :incomingSQIIds];

            //Loop through the list of related SQIs                                            
            for(SterlingQuoteItem__c rsqi : relatedSterlingQuoteItems) {
                //...and build their composite keys and put 'em in a map. There's a chance of a false-positive sneaking in at this stage since the composite value lists
                //are being compared against broadly instead of as tuples (e.g. IF name = [AA, BB], products = [11, 22], QuoteName = [XX, YY], we want AA/11/XX or BB/22/YY
                //but AA/22/XX will come through since it's a bunch of IN-filters). So we're building this map and we'll later compare it against the other map to be certain.
                String compositeId = rsqi.name + '_' + rsqi.Products__c + '_' + rsqi.SterlingQuote__c;
                sqiCompositeIdToExistingSQI.put(compositeId, rsqi);
            }
        }
        
        //If we found any related SQIs...
        if(sqiCompositeIdToExistingSQI != null && !sqiCompositeIdToExistingSQI.isEmpty()) {
            //...set the existing one's values for updating then delete the recently-inserted ones.
            
            //Loop through the composite keys of the existing SQIs. We need to weed out any false-positives from the query above.
            for(String compositeId : sqiCompositeIdToExistingSQI.keySet()) {
            
                //If there is an incoming SQI with the same composite key, then it's a match and we want to do the stuff.
                if(sqiCompositeIdToIncomingSQI.get(compositeId) != null) {
                    //Grab the SQI record for the related SQI
                    SterlingQuoteItem__c relatedIncomingSQI = sqiCompositeIdToIncomingSQI.get(compositeId);
                    
                    //Add this incoming SQI's composite key to the list we want to delete.
                    sterlingQuoteItemsToDelete.add(relatedIncomingSQI);
                    incomingSQIIdsToDelete.add(relatedIncomingSQI.Id);
                    
                    SterlingQuoteItem__c sqiToUpdate = sqiCompositeIdToExistingSQI.get(compositeId);
                    
                    //Set it's 'money fields' and Discount Type to match the values from the incoming SQI. Then add it to our list to update.
                    sqiToUpdate.AdjustedMRC__c = relatedIncomingSQI.AdjustedMRC__c;
                    sqiToUpdate.AdjustedNRC__c = relatedIncomingSQI.AdjustedNRC__c;
                    sqiToUpdate.DiscountType__c = relatedIncomingSQI.DiscountType__c;
                    sqiToUpdate.StandardMRC__c = relatedIncomingSQI.StandardMRC__c;
                    sqiToUpdate.StandardNRC__c = relatedIncomingSQI.StandardNRC__c;
                    sqiToUpdate.DiscountAmount__c = relatedIncomingSQI.DiscountAmount__c;
                    sqiToUpdate.NetNewMRR__c = relatedIncomingSQI.NetNewMRR__c;
                    sqiToupdate.PercentageDiscountAmount__c = relatedIncomingSQI.PercentageDiscountAmount__c;
                    sterlingQuoteItemsToUpdate.add(sqiToUpdate);
                }
            }
            
            //Update all the existing, related SQIs with their new field values.
            if(sterlingQuoteItemsToUpdate != null && sterlingQuoteItemsToUpdate.size() > 0) {
                update sterlingQuoteItemsToUpdate;
            }
            
            //If we need to delete any incoming SQIs from being inserted...
            if(incomingSQIIdsToDelete != null && incomingSQIIdsToDelete.size() > 0) {
                //...query for them and delete 'em. The query is necessary because doing it directly from the passed-in NEW variable throws an error.
                sterlingQuoteItemsToDelete = [SELECT id FROM SterlingQuoteItem__c WHERE id IN :incomingSQIIdsToDelete]; 
                delete sterlingQuoteItemsToDelete;
            }
        }//end of if(sqiCompositeIdToExistingSQI != null && !sqiCompositeIdToExistingSQI.isEmpty())
    }

    public static void updateQuoteLineItems(boolean isDelete, List<SterlingQuoteItem__c> itemLists){
    
        set<Id> setOppId                = new set<Id>();
        set<Id> setSterlingQuoteId      = new set<Id>();
        set<Id> setSterlingQuoteItemId  = new set<Id>();
        
        list<OpportunityLineItem> lstOppOtem                  = new list<OpportunityLineItem>();
        list<OpportunityLineItem> lstOppOtemUpdate            = new list<OpportunityLineItem>();
        list<OpportunityLineItem> lstOppOtemDelete            = new list<OpportunityLineItem>();
        List<SterlingQuoteItem__c> lstSterlingQuoteItemUpdate = new List<SterlingQuoteItem__c>();
        
        Map<Id,string> mapProfiles              = new map<Id,String>();
        map<Id,Id> mapProducts                  = new map<Id, Id>();
        map<Id,Boolean> mapQuotes               = new map<Id,Boolean>();
        map<Id,Id> mapOpps                      = new map<Id,Id>();
        map<Id,Id> mapoppItems                  = new map<Id,Id>();
        map<Id,Id> mapQuoteItemIdByOppProductId = new map<Id,Id>();
        map<Id,String> mapQuoteItemIdByStatus   = new map<Id,String>();
        map<Id,SterlingQuote__c> mapSterlingQuoteIdBySterlingQuote = new map<Id,SterlingQuote__c>();
        map<Id,List<SterlingQuote__c>> mapOppIdByListSterlingQuoteSFA = new map<Id,List<SterlingQuote__c>>();
        map<Id,List<SterlingQuote__c>> mapOppIdByListSterlingQuoteSterling = new map<Id,List<SterlingQuote__c>>();
        string testclass = '';
        
        SterlingQuote__c SterlingQuoteUpdate = new SterlingQuote__c();  
        
        if(!isDelete){
            for(SterlingQuoteItem__c SQI : itemLists){
           
                setSterlingQuoteItemId.add(SQI.id);
                setSterlingQuoteId.add(SQI.SterlingQuote__c);
                mapProducts.put(SQI.products__c,SQI.products__c);
                testclass = SQI.Description__c;
                //mapQuotes.put(SQI.sterlingquote__c,null);      
            
            }
        }
        if(isDelete){
           for(SterlingQuoteItem__c SQI : itemLists){
                setSterlingQuoteItemId.add(SQI.id);
                setSterlingQuoteId.add(SQI.SterlingQuote__c);
                mapProducts.put(SQI.products__c,SQI.products__c);
               // mapQuotes.put(SQI.sterlingquote__c,null);      
            }
        }     
        
    
        /*list<PricebookEntry> lstPBE     =[select id, product2ID, PriceBook2ID from PricebookEntry where product2id in: mapProducts.Keyset() AND pricebook2.IsStandard = True];
          list<SterlingQuote__c> lstQuote =[select Id,IsSyncing__c, OpportunityID__c from SterlingQuote__c ];//No filter to limit data like on basis of parent sterling quote.

        for(PricebookEntry pbe: lstPBE){
            mapProducts.put(pbe.product2ID,pbe.Id);
        }
        for(SterlingQuote__c QT:lstQuote){
            setOppId.add(QT.OpportunityId__c);
            mapQuotes.put(QT.id,QT.Issyncing__c);
            mapOpps.put(QT.Id,QT.OpportunityId__c);   
        }
        No need to declare 2 list only for using in Loops, we can handle as below*/
        // MMG 8/25/2014 added condition to bypass these steps if running approval test class
        
        if(testclass != 'Running Test Class'){
        
            for(PricebookEntry pbe: [select id, product2ID, PriceBook2ID from PricebookEntry where product2id in: mapProducts.Keyset() AND pricebook2.IsStandard = True]){
                mapProducts.put(pbe.product2ID,pbe.Id);
            }
            
            list<sterlingquote__c> lststerlquote =[select Id,RecordType.Name,IsSyncing__c, OpportunityID__c, OpportunityID__r.Owner.Profile.Name from SterlingQuote__c where id in : setSterlingQuoteId]; // added Vj
            //for(SterlingQuote__c QT:[select Id,RecordType.Name,IsSyncing__c, OpportunityID__c from SterlingQuote__c where id in : setSterlingQuoteId]){
            for(sterlingQuote__c QT: lststerlquote){
                mapProfiles.put(QT.Id, QT.OpportunityID__r.Owner.Profile.Name);       // added for Opportunity Lock 2020-07-27
                setOppId.add(QT.OpportunityId__c);
                mapQuotes.put(QT.id,QT.Issyncing__c);
                mapOpps.put(QT.Id,QT.OpportunityId__c);   
                mapSterlingQuoteIdBySterlingQuote.put(QT.Id , QT); 
            }  
    
            for(Opportunity Opp : [Select id, 
                                      (select id,quoteitem__c
                                          From OpportunityLineItems
                                           where opportunityid in :setOppId)
                                          From Opportunity WHERE id in:setOppId]
                                     ) {            
               System.debug('=====73==' +opp);                      
               for(OpportunityLineItem oppLineItem : Opp.OpportunityLineItems)
                mapQuoteItemIdByOppProductId.put(oppLineItem.quoteitem__c,oppLineItem.id);
            }
           
            for(Opportunity Opp : [Select id,
                                        (Select id,RecordType.Name
                                                from Quotes__r
                                                where RecordType.Name='SFA')
                                          From Opportunity where id in :setOppId]
                                     ) {
              List<SterlingQuote__c> lstSterlingQuote = new List<SterlingQuote__c>();                          
              for(SterlingQuote__c sq : Opp.Quotes__r)
                 lstSterlingQuote.add(sq);
              mapOppIdByListSterlingQuoteSFA.put(Opp.Id,lstSterlingQuote);
            }
    
            System.Debug('******mapOppIdByListSterlingQuoteSFA****'+mapOppIdByListSterlingQuoteSFA);
            for(Opportunity Opp : [Select id,
                                        (Select id,RecordType.Name
                                                from Quotes__r
                                                where RecordType.Name='Sterling')
                                          From Opportunity where id in :setOppId]
                                     ) {
              List<SterlingQuote__c> lstSterlingQuote = new List<SterlingQuote__c>();                          
              for(SterlingQuote__c sq : Opp.Quotes__r)
                  lstSterlingQuote.add(sq);
              mapOppIdByListSterlingQuoteSterling.put(Opp.Id,lstSterlingQuote);
            } 
          
            for(ProcessInstance oProcessInstance: [Select TargetObjectId, Status, CreatedBy.Name, CreatedById
                                                From ProcessInstance
                                                Where TargetObjectId In : setSterlingQuoteItemId order by LastModifiedDate]){
                System.debug('###################### --> oProcessInstance.Status:' + oProcessInstance.Status);
                System.debug('###################### --> oProcessInstance.CreatedBy.Name:' + oProcessInstance.CreatedBy.Name);
                if(oProcessInstance.TargetObjectId != null)
                     mapQuoteItemIdByStatus.put(oProcessInstance.TargetObjectId,oProcessInstance.Status);
            }
            
             //Start of changes to this method added per the CAPEX project of January '19.

            //Declaring some initial variables, mostly here to bulkify subsequent queries.
            List<Id> sterlingQuoteIds = new List<Id>();
            List<Id> opportunityIds = new List<Id>();
            List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
            Map<Id, Boolean> sterlingQuoteIdToHasUnapprovedICBDiscountType = new Map<Id, Boolean>();
            
            //Loop through the updated SQIs and gather a list of their QuoteIds so we can query against it.
            for(SterlingQuoteItem__c SQI : itemLists) {
                sterlingQuoteIds.add(SQI.SterlingQuote__c);
            }

            Map<Id, Boolean> sterlingQuoteIdToPendingStatus = new Map<Id, Boolean>();
            Map<Id, List<Id>> opportunityToRelatedSterlingQuoteIds = new Map<Id, List<Id>>();
            
            if(sterlingQuoteIds != null && sterlingQuoteIds.size() > 0) {
                //Query for the synchronized Quotes associated with the updated SQIs.
                List<SterlingQuote__c> relatedSQs = [SELECT id, OpportunityId__c FROM SterlingQuote__c WHERE IsSyncing__c = true AND id IN :sterlingQuoteIds];

                for(SterlingQuote__c relatedSQ : relatedSQs) {
                    //Initialize some mapped flags
                    sterlingQuoteIdToPendingStatus.put(relatedSQ.Id, false);
                    sterlingQuoteIdToHasUnapprovedICBDiscountType.put(relatedSQ.Id, false);
                
                    //Get the list of Opportunity Ids for subsequent querying
                    List<Id> tempSterlingQuoteIds = new List<Id>();
                    if(opportunityToRelatedSterlingQuoteIds.get(relatedSQ.OpportunityId__c) != null && opportunityToRelatedSterlingQuoteIds.get(relatedSQ.OpportunityId__c).size() > 0) {
                        tempSterlingQuoteIds = opportunityToRelatedSterlingQuoteIds.get(relatedSQ.OpportunityId__c);
                    }
                    
                    tempSterlingQuoteIds.add(relatedSQ.Id);
                    opportunityToRelatedSterlingQuoteIds.put(relatedSQ.OpportunityId__c, tempSterlingQuoteIds);
                
                    opportunityIds.add(relatedSQ.OpportunityId__c);
                }
                
                //Query for all the related, synchronized SQIs associated with these Quotes, not just the SQIs that are being updated.
                List<SterlingQuoteItem__c> relatedSterlingQuoteItems = [SELECT id, SterlingQuote__c, OverallStatus__c, DiscountType__c 
                                                                        FROM SterlingQuoteItem__c 
                                                                        WHERE SterlingQuote__c IN :sterlingQuoteIds 
                                                                        AND Quote_Synced__c = true 
                                                                        AND OpportunityLineItemId__c != null];
                
                //Loop through all of 'em and note if ANY for a given SterlingQuote are of status 'Pending', or are unapproved and have a Discount type of either ICB or CTR.
                for(SterlingQuoteItem__c relatedSQI : relatedSterlingQuoteItems) {
                    if(relatedSQI.OverallStatus__c == 'Pending') {
                        sterlingQuoteIdToPendingStatus.put(relatedSQI.SterlingQuote__c, true);
                    }

                    if((relatedSQI.DiscountType__c == 'ICB' || relatedSQI.DiscountType__c == 'CTR') && relatedSQI.OverallStatus__c != 'Approved') {
                        sterlingQuoteIdToHasUnapprovedICBDiscountType.put(relatedSQI.SterlingQuote__c, true);
                    }
                }
                
                if(opportunityIds != null && opportunityIds.size() > 0) {
                    //Query the related opportunities so we can make updates as appropriate.
                    List<Opportunity> relatedOpps = [SELECT id, Approval_Status__c FROM Opportunity WHERE id IN :opportunityIds];    
                    
                    Boolean anyPendingStatusSterlingQuoteItems = false;
                    Boolean anyUnapprovedICBDiscountTypeSterlingQuoteItems = false;
                    //Loop through the related Opportunities and, for each one, loop through the related Quotes and check the flags.
                    for(Opportunity relatedOpp : relatedOpps) {
                        for(Id sterlingQuoteId : opportunityToRelatedSterlingQuoteIds.get(relatedOpp.Id)) {
                            if(sterlingQuoteIdToPendingStatus.get(sterlingQuoteId) == true) {
                                anyPendingStatusSterlingQuoteItems = true;
                            }
                            if(sterlingQuoteIdToHasUnapprovedICBDiscountType.get(sterlingQuoteId) == true) {
                                anyUnapprovedICBDiscountTypeSterlingQuoteItems = true;
                            }                            
                        }
                        
                        //If there are pending SQIs and unapproved ICB/CRT discounts, set status to 'Approval Not Submitted'
                        if(!anyPendingStatusSterlingQuoteItems && anyUnapprovedICBDiscountTypeSterlingQuoteItems) {
                            relatedOpp.Approval_Status__c = 'Approval Not Submitted';                        
                        } //Otherwise, if there are any pending SQIs, set the status to 'Pending'
                        else if(anyPendingStatusSterlingQuoteItems) {
                           relatedOpp.Approval_Status__c = 'Pending';
                        } //Otherwise, set the status to null
                        else {
                            relatedOpp.Approval_Status__c = NULL;
                        }
                        
                        opportunitiesToUpdate.add(relatedOpp);
                    }
                }
                
                if(opportunitiesToUpdate != null && opportunitiesToUpdate.size() > 0) {
                    update opportunitiesToUpdate;
                }
            }//end of if(sterlingQuoteIds != null && sterlingQuoteIds.size() > 0)

      //Some small changes were made as part of the CAPEX Jan. '19 code because the inserted and then deleted SQIs from the deleteDuplicateQuoteLineItems() method were causing
      //Errors with this code downstream.
      if(!isDelete){
      
        List<SterlingQuote__c> lstSterlingQuote;  

        //Grab the ids of the modified SQIs
        List<Id> qliIds = new List<Id>();
        for(SterlingQuoteItem__c QLI : itemLists){
            qliIds.add(QLI.id);
        }
        
        //Query for those SQIs to make sure none have been deleted.
        List<SterlingQuoteItem__c> tempResults = [SELECT id FROM SterlingQuoteItem__c WHERE id IN :qliIds];
        
        List<SterlingQuoteItem__c> tempResults2 = new List<SterlingQuoteItem__c>();
        
        //Compare each incoming SQI to each queried SQI and grab those which match. They're the ones we can perform DML on without error.
        for(SterlingQuoteItem__c QLI : itemLists) {
            for(SterlingQuoteItem__c tr : tempResults) {
                if(tr.id == QLI.Id) {
                    tempResults2.add(QLI);
                }
            }
        }
        
        //Update the itemLists variable to only contain those SQIs that haven't been deleted.
        itemLists = tempResults2;
        //End of changes to this method added per the CAPEX project of January '19.
        
        for(SterlingQuoteItem__c QLI : itemLists){
    
            lstSterlingQuote = new List<SterlingQuote__c>(); 
            if(QLI.SterlingQuote__c != null){
                SterlingQuoteUpdate = mapSterlingQuoteIdBySterlingQuote.get(QLI.SterlingQuote__c);
            }                             
            if(SterlingQuoteUpdate.RecordType.Name == 'SFA'){
               lstSterlingQuote = mapOppIdByListSterlingQuoteSFA.get(SterlingQuoteUpdate.OpportunityId__c);
            }
            else if(SterlingQuoteUpdate.RecordType.Name == 'Sterling'){
               lstSterlingQuote = mapOppIdByListSterlingQuoteSterling.get(SterlingQuoteUpdate.OpportunityId__c);
            }
            System.Debug('***mapQuotes.get(QLI.sterlingquote__c)**'+mapQuotes.get(QLI.sterlingquote__c));
            System.Debug('*lstSterlingQuote***'+lstSterlingQuote + '**lstSterlingQuote size**'+lstSterlingQuote.size());
            if(mapQuotes.get(QLI.sterlingquote__c) || ( (mapQuotes.get(QLI.sterlingquote__c) == false && lstSterlingQuote.size() == 1) && !Quote_Extension.containsProfileForLock(mapProfiles.get(QLI.sterlingquote__c)) ) ) { 
                if(mapQuoteItemIdByOppProductId.get(QLI.id) != null){
                           OpportunityLineItem  OLI = Utilities.setOpportunityLineItem(mapQuoteItemIdByOppProductId.get(QLI.id), QLI, false, null, null, SterlingQuoteUpdate.RecordType.Name);
                           if (OLI != null)
                               lstOppOtemUpdate.add(OLI);
                           system.debug('***lstOppOtemUpdate Insert*'+lstOppOtemUpdate + '**lstOppOtemUpdate Size*'+lstOppOtemUpdate.size()); 
                }                   
                else {
                    if((mapProducts.get(QLI.products__c)!=null) && (QLI.Products__c!=null || QLI.Products__c !='')){
                      
                      OpportunityLineItem  OLI = Utilities.setOpportunityLineItem(null, QLI, true, mapOpps.get(QLI.SterlingQuote__c), mapProducts.get(QLI.products__c), SterlingQuoteUpdate.RecordType.Name);
                      if (OLI != null)
                        lstOppOtem.add(OLI);
                    }
                    system.debug('***lstOppOtem Insert*'+lstOppOtem + '**lstOppOtem Size*'+lstOppOtem.size());
                }      
            }
        } // end of for loop
        
        system.debug('***lstOppOtem*'+lstOppOtem + '**lstOppOtem Size*'+lstOppOtem.size());
        
        if(lstOppOtem != null && lstOppOtem.size() > 0){
          System.debug('================195========lstOppOtem:'+lstOppOtem);
          insert lstOppOtem;
          SterlingQuoteUpdate.IsSyncing__c = true;
          update SterlingQuoteUpdate;  
        }
        
        system.debug('***lstOppOtemUpdate*'+lstOppOtemUpdate + '**lstOppOtemUpdate Size*'+lstOppOtemUpdate.size());     
        
        if(lstOppOtemUpdate != null && lstOppOtemUpdate.size() > 0){ 
            System.debug('================203========lstOppOtemUpdate:'+lstOppOtemUpdate);           
            update lstOppOtemUpdate;
        }
              
        for(OpportunityLineItem OppItem : lstOppOtem){
         if(OppItem.quoteitem__c != null){
             SterlingQuoteItem__c SQI = new SterlingQuoteItem__c(id=OppItem.quoteitem__c);
             SQI.OpportunityLineItemId__c = OppItem.id;
             /*if(SQI.DiscountAmount__c != null && SQI.StandardMRC__c > 0 ) {
                SQI.PercentageDiscountAmount__c = ((-(SQI.DiscountAmount__c))/SQI.StandardMRC__c);
             } else {
                SQI.PercentageDiscountAmount__c = 0;
             }*/
             lstSterlingQuoteItemUpdate.add(SQI);
             system.debug('=====234 PercentageDiscountAmount__c' +SQI.PercentageDiscountAmount__c);
             system.debug('=====235 SQI.StandardMRC__c' +SQI.StandardMRC__c);
             system.debug('=====233 SQI.DiscountAmount__c' +SQI.DiscountAmount__c);
            }
        }
        
        system.debug('***lstSterlingQuoteItemUpdate*'+lstSterlingQuoteItemUpdate + '**lstSterlingQuoteItemUpdate Size*'+lstSterlingQuoteItemUpdate.size());
        
        if(lstSterlingQuoteItemUpdate != null &&  lstSterlingQuoteItemUpdate.size() > 0){
         update lstSterlingQuoteItemUpdate;
        }
       }
      } //End of test for running test class

      if(isDelete){
             for(SterlingQuoteItem__c QLI : itemLists){
                    if(mapQuotes.get(QLI.sterlingquote__c)){
                        if(mapQuoteItemIdByOppProductId.get(QLI.id) != null){
                           OpportunityLineItem  OLU = new OpportunityLineItem(id=mapQuoteItemIdByOppProductId.get(QLI.id));
                           lstOppOtemDelete.add(OLU);
                        }
                    }
                }
                if(lstOppOtemDelete != null &&  lstOppOtemDelete.size() > 0){
                 delete lstSterlingQuoteItemUpdate;
                }
      }        
   }
    //This method will set is sync alloed field in SterlingQuoteobject false
    public static void setisSyncallowed(List<SterlingQuoteItem__c> itemList){
        //Assume this code is not in batch mode 
        system.debug('==>enter into setisSyncallowed');
        Boolean isSyncAllowed = false;
        Id quoteId =  itemList[0].SterlingQuote__c;
        // List<String> profiles = new List<String>{'#CTF AccountExec','Frontier Sales User'};
        List<String> profiles = new List<String>{'Frontier Sales User'};
        itemList = [SELECT Id,DiscountType__c,Products__r.Is_LegacyVlocityProduct__c, 
                    SterlingQuote__r.OpportunityId__r.Account.Has_MSA__c,SterlingQuote__r.OpportunityId__r.Owner.Profile.Name,
                    SterlingQuote__r.OpportunityId__r.Opportunity_type__c
                    FROM SterlingQuoteItem__c
                    WHERE SterlingQuote__c =:quoteId ];
        if (itemList.size() > 0 && Quote_Extension.containsProfileForLock(itemList[0].SterlingQuote__r.OpportunityId__r.Owner.Profile.Name)) {
            // if (itemList.size() == 0){
            //     isSyncAllowed = true;
            // }else{
                SterlingQuote__c quote = itemList[0].SterlingQuote__r;
                if (quote.OpportunityId__r.Account.Has_MSA__c == true || 
                    quote.OpportunityId__r.Opportunity_type__c == 'Renewal' || 
                    quote.OpportunityId__r.Opportunity_type__c == 'Existing'){
                    isSyncAllowed = true;
                }
                if (isSyncAllowed != true){
                    for (SterlingQuoteItem__c slqi: itemList){
                        if ((slqi.DiscountType__c == 'BDT' || slqi.DiscountType__c == 'ICB' || slqi.Products__r.Is_LegacyVlocityProduct__c == false)){
                               isSyncAllowed = true;
                            break;
                        }
                    }
                }
            // }
        } else {
            isSyncAllowed = true;
        }
        system.debug('==>isSyncAllowed'+isSyncAllowed);
        SterlingQuote__c squpdate = new SterlingQuote__c(Id =quoteId, Is_Sync_Allowed__c = isSyncAllowed);
        update squpdate;
    }
  	/** Wholesale Enhancement Vyshnavi Starts **/
    public static void updateTotalCIACCharge(List<SterlingQuoteItem__c> quoteItems) {
        Set<String> oppIdSet = new Set<String>();
        Set<String> addressIds = new Set<String>();
        Map<Id, Opportunity> oppCIACMap = new Map<Id, Opportunity>();
        for (SterlingQuoteItem__c lineItem :quoteItems ) {
            if (String.isNotBlank(lineItem.OpportunityId__c)) {
                oppIdSet.add(lineitem.OpportunityId__c);
            }
        }
        system.debug('oppIdSet ==> ' + oppIdSet);
        List<SterlingQuoteItem__c> temp =  [SELECT Id, CIAC__c, ST_AddressID__c, OpportunityId__c FROM SterlingQuoteItem__c WHERE CIAC__c != null AND OpportunityId__c IN: oppIdSet];
        system.debug('temp ==> ' + temp);
        for (SterlingQuoteItem__c lineItem :temp ) {
            if (String.isNotBlank(lineItem.OpportunityId__c)) {
                addressIds.add(lineitem.ST_AddressID__c);
            }
        }
        Map<Id, FTRWSAddress__c> addressMap = new Map<Id, FTRWSAddress__c>([SELECT Id, Address_Lost_checkbox__c FROM FTRWSAddress__c WHERE Id IN: addressIds]);
        for (SterlingQuoteItem__c lineItem : temp) {
            Opportunity opp = oppCIACMap.containsKey(lineItem.OpportunityId__c) ? oppCIACMap.get(lineItem.OpportunityId__c) : new Opportunity(Id = lineItem.OpportunityId__c);
			Decimal ciac = opp.Total_CIAC_Charge3__c != null ? opp.Total_CIAC_Charge3__c : 0;
            Decimal totalCIAC = opp.Total_Won_CIAC_Charge1__c != null ? opp.Total_Won_CIAC_Charge1__c : 0;
            system.debug('ciac 1  ==> ' + ciac);
            ciac = ciac + lineItem.CIAC__c;
            Boolean addressLost = addressMap.containsKey(lineItem.ST_AddressID__c) ? addressMap.get(lineItem.ST_AddressID__c).Address_Lost_checkbox__c : false;
            totalCIAC = totalCIAC + (!addressLost ? lineItem.CIAC__c : 0);
            opp.Total_CIAC_Charge3__c = ciac;
            opp.Total_Won_CIAC_Charge1__c = totalCIAC;
            system.debug('ciac 2  ==> ' + ciac);
            system.debug('opp 1  ==> ' + opp);
            oppCIACMap.put(lineItem.OpportunityId__c, opp);
        }
        
        if (!oppCIACMap.isEmpty()) {
            update oppCIACMap.values();
        }
    }
    /**Wholesale Enhancement Vyshnavi Ends **/
}