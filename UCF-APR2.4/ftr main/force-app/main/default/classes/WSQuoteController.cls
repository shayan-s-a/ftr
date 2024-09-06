public class WSQuoteController {
    
    public class QuoteWrapper {
        @AuraEnabled
        public Boolean allowEdit;
        @AuraEnabled
        public List<SterlingQuoteItem__c> quoteLineItems;
        public QuoteWrapper() {
            this.allowEdit = false;
            this.quoteLineItems = new List<SterlingQuoteItem__c>();
        } 
    }
    @AuraEnabled
    public static QuoteWrapper getQuoteItemLines(Id quoteId, Id addressId) {
        System.debug('Id:'+ quoteId);
        QuoteWrapper wrapper = new QuoteWrapper();
        wrapper.allowEdit = FeatureManagement.checkPermission('DealDeskCustomPermission');
        wrapper.quoteLineItems =  [SELECT 
                Id, Description__c, CPQLineNumber__c, SA_StreetNrFirst__c, SA_StreetDirection__c, SA_StreetName__c, SA_StreetSuffix__c, 
                Locality__c, StateProvince__c, Postcode__c,MajorLine__c, CPE_NRC_Price__c, CPE_Gross_Margin__c, Renewal_MRR_Original__c,
                MinorLine__c,ItemCode__c, sterlingquote__r.RecordType.Name,Products__r.Name, Products__r.Family, OverallStatus__c, promoDiscountAmount__c, 
                Quantity__c, TermLength__c, Display_Term__c, NumInstallments__c, StandardMRC__c,Display_MRC__c, StandardNRC__c,Display_NRC__c, AdjustedMRC__c, AdjustedNRC__c, 
                DiscountAmount__c, PercentageDiscountAmount__c, ST_AddressID__c, qos__c, cvdratesource__c, cvdPriceTier__c, circuitType__c,
                PNum__c, Max_Qos__c, DSAT_Max_Speed__c, DSAT_Copper_Tier__c, DSAT_Fiber_Tier__c, BDT_Required__c, CRT__c, CIAC__c, Total_Cost__c,Fiber_Cost__c,Equipment_Cost__c,
                NPV_Net_Present_Value__c,
                Allocated_Total_Capex__c,Splicing_Cost__c, Guardrail_Cost__c,IRR_Internal_Rate_of_Return__c,HBE_Max_Speed__c,HBE_Max_Qos__c
                FROM SterlingQuoteItem__c  
                WHERE SterlingQuote__c = :quoteId 
                AND ST_AddressID__c = :addressId
                ORDER BY CreatedDate ASC];
        return wrapper;
    }
    // removed DSAT and DPI validated condition as part of sddd-2931
    /** Wholesale Enhancement Vyshnavi Starts **/
    @AuraEnabled
    public static AddressWrapper getOpportunityAddressList(Id quoteId) {
        AddressWrapper wrapper = new AddressWrapper();
        SterlingQuote__c oppId = [SELECT OpportunityId__c, Show_Additonal_Quote_Information__c FROM SterlingQuote__c where Id =:quoteId LIMIT 1];
        //System.debug('Hemantha1:'+ oppId);        
        List<FTRWSAddress__c> oppAddressList = [select Id, Street_Name__c, Street_Number__c, Unit_Number__c, 
                                                City__c, State__c,Opportunity_ID__c,CLLI_Code__c, Service_Control_Number__c, 
                                                Zip_Code__c, Id__c from FTRWSAddress__c 
                                                where Opportunity_ID__c =:oppId.OpportunityId__c];
        wrapper.oppAddressList = oppAddressList;
        wrapper.hideAddDetails = oppId?.Show_Additonal_Quote_Information__c;
        //System.debug('Hemantha:'+ oppAddressList);
        return wrapper;      
    }
    /** Wholesale Enhancement Vyshnavi Ends **/
    
    public class AddressWrapper {
        @AuraEnabled
        public List<FTRWSAddress__c> oppAddressList;
        @AuraEnabled
        public Boolean hideAddDetails;
        public AddressWrapper () {
            oppAddressList = new List<FTRWSAddress__c>();
            hideAddDetails = false;
        }
    }
    
    @AuraEnabled
    public static Boolean updateQuoteItems(List<SterlingQuoteItem__c> quoteItems) {
        Map<Id, SterlingQuoteItem__c> quoteItemsMap = new Map<Id, SterlingQuoteItem__c>([SELECT Id, CRT__c, SterlingQuote__c, Status__c FROM SterlingQuoteItem__c WHERE Id IN: quoteItems]);
        Map<Id, SterlingQuote__c> quoteMap = new Map<Id, SterlingQuote__c>();
        Boolean boolRefresh = false;
        for (SterlingQuoteItem__c objQI : quoteItems) {
            if (quoteItemsMap.containsKey(objQI.Id) &&  objQI.CRT__c != null && quoteItemsMap.get(objQI.Id).CRT__c != objQI.CRT__c) {
                Id quoteId = quoteItemsMap.get(objQI.Id).SterlingQuote__c;
                quoteMap.put(quoteId, new SterlingQuote__c(Id = quoteId, Status__c = 'Needs Review'));
                boolRefresh = true;
            }
        }
        update quoteItems;
        update quoteMap.values();
        return boolRefresh;
    }
    
    @AuraEnabled
    public static String removeItem(Id itemId) {
        SterlingQuoteItem__c item = [SELECT Id from SterlingQuoteItem__c WHERE Id=:itemId];
        DELETE item;
        return 'SUCCESS';
    }
    
    
    @AuraEnabled
    public static String getUnSyncQuoteWithOpportunity(ID quoteId) {
        System.debug('UnSynching quote with opportunity, Quote id passed is:' + quoteId);
        
        SterlingQuote__c sterlingQuote = [Select id,RecordTypeid, OrderId__c, RecordType.Name,IsSyncing__c,QuoteType__c,CPQQuoteId__c, OpportunityId__c,Is_Sync_Allowed__c,Sync_Allowed_by_Admin__c from SterlingQuote__c where id=: quoteId];
        //Quote_Extension.
        productUnSync(quoteId, sterlingQuote);
        
        return 'SUCCESS';
    }
    
    private static void productUnSync(String strQuote, SterlingQuote__c sterlingQuote)
    {    
        List<SterlingQuoteItem__c> sterlingQuoteItemDelete = new List<SterlingQuoteItem__c>();
        // MMG 9/17/2014 Added new list for clearing OpportunityLineItemID when Unsyncing 
        List<SterlingQuoteItem__c> SQIUpdate               = new List<SterlingQuoteItem__c>();
        list<OpportunityLineItem> lstOppOtemDelete         = new list<OpportunityLineItem>();
        set<Id> setOppId                                   = new set<Id>();   
        set<Id> setSterlingQuoteId                         = new set<Id>();     
        map<Id,Boolean> mapQuotes                          = new map<Id,Boolean>();
        map<Id,Id> mapQuoteItemIdByOppProductId            = new map<Id,Id>();
        Set<Id> qIdSet                                     = new Set<Id>();
        Set<Id> oppIdSetDelete                             = new Set<Id>(); 
        
        sterlingQuoteItemDelete = [Select id,
                                   Products__c,
                                   Quantity__c,
                                   promoDiscountAmount__c,
                                   CPE_NRC_Price__c,
                                   StandardNRC__c,
                                   Renewal_MRR_Original__c,
                                   TermLength__c,
                                   NumInstallments__c,
                                   AdjustedMRC__c,
                                   CPE_Gross_Margin__c,
                                   TotalPrice__c,
                                   DiscountType__c,
                                   DiscountAmount__c,
                                   StandardMRC__c,
                                   OpportunityLineItemId__c,
                                   SterlingQuote__c                                 
                                   From SterlingQuoteItem__c                                  
                                   where SterlingQuote__c=:strQuote
                                  ];    
        
        for(SterlingQuoteItem__c SQI : sterlingQuoteItemDelete){
            //setSterlingQuoteItemId.add(SQI.id); 
            setSterlingQuoteId.add(SQI.SterlingQuote__c);      
        }
        for(SterlingQuote__c QT:[select Id,IsSyncing__c, OpportunityID__c from SterlingQuote__c where id in : setSterlingQuoteId]){
            setOppId.add(QT.OpportunityId__c);
            mapQuotes.put(QT.id,QT.Issyncing__c);            
        }   
        // MMG 10/1/2014 Selecting on Opportunity Line Items for specific quote
        system.debug('===SetSterlingQuoteId = ' + setSterlingQuoteId);
        system.debug('===StrQuote = ' + strQuote);
        system.debug('===setOppid = ' + setOppid);
        for(Opportunity Opp : [Select id,
                               (select id,quoteitem__c, Quoteid__c
                                From OpportunityLineItems
                                where  
                                opportunityid in :setOppId  AND quotelineitem__c=null)
                               From Opportunity WHERE id in :setOppId]
           ) {                                   
               // MMG 10/1/2014 Selecting on Opportunity Line Items for specific quote
               system.debug('===OPP = ' + OPP);
               for(OpportunityLineItem oppLineItem : Opp.OpportunityLineItems)
               {
                   mapQuoteItemIdByOppProductId.put(oppLineItem.quoteitem__c,oppLineItem.id);
               }       
           }   
        System.debug('================sterlingQuoteItemDelete:'+sterlingQuoteItemDelete);
        System.debug('================sterlingQuoteItemDelete:size: '+sterlingQuoteItemDelete.size());
        
        for(SterlingQuoteItem__c QLI: sterlingQuoteItemDelete){
            if(mapQuotes.get(QLI.sterlingquote__c)){ 
                if(mapQuoteItemIdByOppProductId.get(QLI.id) != null){
                    system.debug('==230====lstOppOtemDelete' + lstOppOtemDelete);
                    OpportunityLineItem  OLU = new OpportunityLineItem(id=mapQuoteItemIdByOppProductId.get(QLI.id));
                    // MMG 10/1/2014 Selecting on Opportunity Line Items for specific quote
                    system.debug('===OLU.Quoteid__c = ' + OLU); 
                    //      if(OLU.QuoteId__c == strQuote)
                    lstOppOtemDelete.add(OLU);
                    SQIUpdate.add(new SterlingQuoteItem__c(Id = QLI.Id, OpportunityLineItemId__c= null));
                    system.debug('======231== ' + lstOppOtemDelete);
                    if(OLU !=null)
                        system.debug('====opplineitemID' +OLU);
                    oppIdSetDelete.add(OLU.Id);
                    if(QLI.SterlingQuote__c != null)
                        qIdSet.add(QLI.SterlingQuote__c);
                }
            }
            
            // MMG 9/17/2014 Add to list for clearing OpportunityLineItemID when Unsyncing 
            //SQIUpdate.add(QLI);
        }
        
        System.debug('====lstOppOtemDelete===='+lstOppOtemDelete);
        if(lstOppOtemDelete != null &&  lstOppOtemDelete.size() > 0){
            if(!qIdSet.isEmpty()) { 
                try {
                    //List<OpportunityLineItem> oliList = [Select Id, QuoteId__c from OpportunityLineItem where QuoteId__c IN: qIdSet];
                    // MMG 10/1/2014 Selecting on Opportunity Line Items for specific quote
                    System.debug('setOppId=='+setOppId);
                    System.debug('strQuote=='+strQuote);
                    List<OpportunityLineItem> oliList = [Select Id, OpportunityId, QuoteId__c  from OpportunityLineItem where OpportunityId IN: setOppId and QuoteId__c =:strQuote AND quotelineitem__c=null];
                    //List<OpportunityLineItem> oliList = [Select Id, OpportunityId, QuoteId__c  from OpportunityLineItem where OpportunityId IN: setOppId and QuoteId__c =:strQuote];
                    List<OpportunityLineItem> oliList1 = [Select Id, OpportunityId, QuoteId__c  from OpportunityLineItem where OpportunityId IN: setOppId AND QuoteId__c = null AND quotelineitem__c=null];
                    System.debug('oliList_New'+oliList1.size());
                    System.debug('oliList'+oliList.size());
                    if(!oliList.isEmpty()) {
                        system.debug('====oliList' + oliList);
                        for(OpportunityLineItem oli: oliList) {
                            if(!oppIdSetDelete.contains(oli.Id) && oli.id != null)
                                lstOppOtemDelete.add(oli);  
                            system.debug('=====232=== '+ lstOppOtemDelete);         
                        }
                    }
                    if(!oliList1.isEmpty()) {
                        system.debug('====oliList1' + oliList1);
                        for(OpportunityLineItem oli: oliList1) {
                            if(!oppIdSetDelete.contains(oli.Id) && oli.id != null)
                                lstOppOtemDelete.add(oli);  
                            system.debug('=====232===New == lstOppOtemDelete'+ lstOppOtemDelete);         
                        }
                    } 
                    
                } catch(Exception e) {
                }
            }
            if(!SQIUpdate.isEmpty())
                //delete SQIUpdate;
                update SQIUpdate;
            System.debug('=================SQIUpdate:' + SQIUpdate);
            System.debug('==========SQIUpdate.size'+SQIUpdate.size());
            system.debug('======before delete unsync====oli' + lstOppOtemDelete);
            system.debug('======before delete unsync size====oli' + lstOppOtemDelete.size());
            delete lstOppOtemDelete;
            
            system.debug('===233==lstOppOtemDelete' + lstOppOtemDelete);
            system.debug('===233==lstOppOtemDelete.size' + lstOppOtemDelete.size());
            sterlingQuote.IsSyncing__c = false;
            update sterlingQuote;
            // MMG 9/17/2014 Added Update for clearing OpportunityLineItemID when Unsyncing 
            
        } 
    }
    
    @AuraEnabled
    public static String getSyncQuoteWithOpportunity(ID quoteId) {
        System.debug('**************Synching quote with opportunity, Quote id passed is:' + quoteId);
        
        SterlingQuote__c sterlingQuote = [Select id,RecordTypeid, OrderId__c, RecordType.Name,IsSyncing__c,QuoteType__c,CPQQuoteId__c, OpportunityId__c,Is_Sync_Allowed__c,Sync_Allowed_by_Admin__c from SterlingQuote__c where id=: quoteId];
        //Quote_Extension.
        productSync(quoteId, sterlingQuote);
        return 'SUCCESS';
    }
    
    
    private static void productSync(String strQuote, SterlingQuote__c sterlingQuote){          
        List<OpportunityLineItem> listOppLineItemInsert= new List<OpportunityLineItem>();
        List<SterlingQuoteItem__c> sterlingQuoteItem = new List<SterlingQuoteItem__c>();
        List<SterlingQuote__c>    sterlingquoteUpdate = new List<SterlingQuote__c>();
        List<SterlingQuoteItem__c> lstSterlingQuoteItemUpdate = new List<SterlingQuoteItem__c>();
        set<Id> sqid                                   = new set<Id>();
        
        sterlingQuoteItem = [SELECT
                             id, Name, Products__c, Quantity__c, CPE_NRC_Price__c,NRC_Item_Code__c, StandardNRC__c, Renewal_MRR_Original__c, TermLength__c, NumInstallments__c, Service_Address__c, Postal_Area__c,
                             AdjustedMRC__c, CPE_Gross_Margin__c,promoDiscountAmount__c, TotalPrice__c, DiscountType__c, DiscountAmount__c, StandardMRC__c, AdjustedNRC__c     //Giri 03/03/2014                             
                             FROM SterlingQuoteItem__c WHERE SterlingQuote__c = :strQuote
                             AND (MinorLine__c = 0 OR MinorLine__c = null or StandardMRC__c != 0 or StandardNRC__c != 0 or DiscountAmount__c != 0 or AdjustedMRC__c != 0)
                             //             AND (MinorLine__c = 0 OR MinorLine__c = null)
                            order by createdDate
                            ];  
        // MMG 9/10/2014 End             
        system.debug('Product sync sterlingquoteitem   :'+sterlingQuoteItem);
        map<Id,Id> mapProductByPriceBookId = new map<Id,Id>();
        // MMG 9/10/2014 Picked up all the products that have a price book entry. 
        for(PriceBookEntry pb : [SELECT Id, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE PriceBook2.isStandard = TRUE and Product2.recordType.Name = 'Carrier Service']){
            //         for(PriceBookEntry pb : [SELECT Id, Product2Id, Product2.Id, Product2.MajorProduct__c, Product2.Name FROM PriceBookEntry WHERE PriceBook2.isStandard = TRUE AND Product2.MajorProduct__c = TRUE]){
            // MMG 9/10/2014 End                      
            mapProductByPriceBookId.put(pb.Product2Id,pb.id);
        }     
        if(sterlingQuoteItem != null && sterlingQuoteItem.size() > 0){
            for(SterlingQuoteItem__c SQ : sterlingQuoteItem){         
                system.debug('******** SQ    : '+SQ);
                system.debug('****** sq.Products__c  : ' +SQ.Products__c);
                OpportunityLineItem oppLineIteminsert = new OpportunityLineItem();              
                if(SQ.Quantity__c != null && SQ.Products__c != null && mapProductByPriceBookId.get(SQ.Products__c) != null) {
                    System.debug('found a product match: ' + SQ.Products__c + ' with MRC:' + SQ.StandardMRC__c);
                    oppLineIteminsert.PricebookEntryId = mapProductByPriceBookId.get(SQ.Products__c);             
                    oppLineIteminsert.Quantity         = SQ.Quantity__c; 
                    oppLineIteminsert.CPE_NRC_Price__c = SQ.CPE_NRC_Price__c;     
                    oppLineIteminsert.NRC_Price__c     = SQ.StandardNRC__c; 
                    // MMG 9/24/2014 Populate NRC_Price with AdjustedNRC if exists 
                    if(SQ.AdjustedNRC__c != 0) oppLineIteminsert.NRC_Price__c = SQ.AdjustedNRC__c;     
                    if(SQ.TermLength__c == 0.0 )
                        oppLineIteminsert.Term_Months__c   = SQ.NumInstallments__c;
                    // MMG 9/9/2014 Added ContractMRR2 field to the populate section.  This will be the adjustedMRC if that field is not 0 .  If 0 this value will be unit price.
                    oppLineIteminsert.ContractMRR2__c   = SQ.AdjustedMRC__c;
                    If(oppLineIteminsert.ContractMRR2__c == 0) oppLineIteminsert.ContractMRR2__c= SQ.StandardMRC__c;
                    // MMG 9/9/2014 End changes 
                    
                    oppLineIteminsert.SNE_Code_MRC__c  = ''+SQ.StandardMRC__c;
                    //oppLineIteminsert.  
                    if(SQ.Name != null && SQ.Name != '') {
                        
                        String prodName = SQ.Name;
                        System.debug('Product name for opportunity product:' + prodName);
                        if(prodName.startsWith('EIA') || prodName.startsWith('EPATH')) {
                            String[] prodNameArr = prodName.split(' ');
                            if(prodNameArr.size() > 1) {
                                System.debug('*****Product speed for opportunity product:' + prodNameArr[1]);
                                oppLineIteminsert.Speed__c = prodNameArr[1];   
                            }
                        }
                    }
                    
                    oppLineIteminsert.SNE_Code_OTC__c = SQ.NRC_Item_Code__c;
                    oppLineIteminsert.CPE_Gross_Margin__c  = SQ.CPE_Gross_Margin__c;
                    oppLineIteminsert.Opportunityid    = sterlingQuote.OpportunityId__c;
                    oppLineIteminsert.Opportunity_Sync__c = sterlingQuote.RecordType.Name; 
                    oppLineIteminsert.UnitPrice          = SQ.StandardMRC__c;    
                    oppLineIteminsert.quoteitem__c       = SQ.ID;
                    oppLineIteminsert.Service_Address__c = '';
                    if (!String.isEmpty(SQ.Service_Address__c))
                        oppLineIteminsert.Service_Address__c += SQ.Service_Address__c;
                    if (!String.isEmpty(SQ.Postal_Area__c)) {
                        if ((oppLineIteminsert.Service_Address__c).equals(''))
                            oppLineIteminsert.Service_Address__c += SQ.Postal_Area__c;
                        else    
                            oppLineIteminsert.Service_Address__c += ' '+SQ.Postal_Area__c;
                    }
                    
                    listOppLineItemInsert.add(oppLineIteminsert);
                    system.debug('list of opp item to be inserted'+listOppLineItemInsert);
                    
                } else {
                    System.debug('SQ.Quantity__c: ' + SQ.Quantity__c);
                    System.debug('SQ.Products__c: ' + SQ.Products__c);
                    System.debug('SQ.mapProductByPriceBookId.get(SQ.Products__c): ' + mapProductByPriceBookId.get(SQ.Products__c));
                }
            }      
        }      
        if(listOppLineItemInsert!= null && listOppLineItemInsert.size() >0){       
            System.Debug('***listOppLineItemInsert******'+listOppLineItemInsert);
            insert listOppLineItemInsert;   
            sterlingQuote.IsSyncing__c = true;
            system.debug('sterling quote which is updated  : ' +sterlingquote);
            update sterlingQuote;            
        } 
        if(listOppLineItemInsert !=null && listOppLineItemInsert.size() > 0){  
            set<id> setNewOppLineItemId = new set<id>();     
            for(OpportunityLineItem oppLine :listOppLineItemInsert){
                system.debug('====== oppLine.id : ' +oppLine.id);
                setNewOppLineItemId.add(oppLine.id);        
                if(oppLine.quoteitem__c != null){
                    SterlingQuoteItem__c SQI = new SterlingQuoteItem__c(id=oppLine.quoteitem__c);
                    SQI.OpportunityLineItemId__c = oppLine.id;
                    system.debug('=======OpportunityLineItemId__c' + SQI.OpportunityLineItemId__c);
                    lstSterlingQuoteItemUpdate.add(SQI);
                }
            }  
            System.debug('Mohan ====== New opp LI added which are to be excluded ' + setNewOppLineItemId);
            List<OpportunityLineItem> oppLineItemDelete = new List<OpportunityLineItem>();        
            oppLineItemDelete = [SELECT id FROM OpportunityLineItem WHERE OpportunityId=:sterlingQuote.OpportunityId__c AND id NOT IN :setNewOppLineItemId AND Opportunity_Sync__c =:sterlingQuote.RecordType.Name];
            System.debug('Mohan===oppLineItemDelete' + oppLineItemDelete);
            if(oppLineItemDelete!= null && oppLineItemDelete.size() >0){          
                delete oppLineItemDelete;
            }        
            List<SterlingQuote__c> lststerlingquote = [SELECT id,IsSyncing__c,QuoteType__c,OpportunityId__c FROM SterlingQuote__c WHERE id !=:strQuote AND IsSyncing__c = TRUE AND RecordTypeid = :sterlingQuote.RecordTypeid AND OpportunityId__c  = :sterlingQuote.OpportunityId__c]; 
            
            //if(lststerlingquote != null )
            //sqid = lststerlingquote.id;
            //system.debug('======233====lststerlingquote.id' + lststerlingquote.id);
            
            //List<SterlingQuoteItem__c> lststerlingquotenew = [SELECT SterlingQuote__c,OpportunityLineItemId__c FROM SterlingQuoteItem__c WHERE SterlingQuote__c = squi]; 
            if(lststerlingquote != null && lststerlingquote.size() > 0){
                for(SterlingQuote__c sterqu : lststerlingquote){             
                    sterqu.IsSyncing__c = false;
                    sterlingquoteUpdate.add(sterqu);
                }
                SterlingQuote__c lststerlingquotenew = [SELECT id FROM SterlingQuote__c WHERE id !=:strQuote AND IsSyncing__c = TRUE AND RecordTypeid = :sterlingQuote.RecordTypeid AND OpportunityId__c  = :sterlingQuote.OpportunityId__c]; 
                system.debug('======233====lststerlingquoteNEW' + lststerlingquotenew);
                string sqid1 = lststerlingquoteNEW.id;
                list<SterlingQuoteItem__c> lstsqinew = [select id, opportunityLineItemId__c from SterlingQuoteItem__c where SterlingQuote__c =: sqid1];
                
                system.debug('======234====sqid1 = ' + sqid1);
                for(SterlingQuoteItem__c sterqui : lstsqinew) {
                    system.debug('======235==== sterqui' + sterqui);
                    sterqui.OpportunityLineItemId__c = '';
                    
                    lstSterlingQuoteItemUpdate.add(sterqui);
                    system.debug('======236==== sterlingquoteUpdate' + sterlingquoteUpdate);
                }           
                
            }
            if(sterlingquoteUpdate != null && sterlingquoteUpdate.size() > 0){
                System.Debug('***sterlingquoteUpdate***'+sterlingquoteUpdate);
                update sterlingquoteUpdate;
            }       
            if(lstSterlingQuoteItemUpdate != null &&  lstSterlingQuoteItemUpdate.size() > 0){
                update lstSterlingQuoteItemUpdate;
            }       
        }           
    }
    
    @AuraEnabled
    public static boolean submitWSQuoteForApproval(String quoteId) {
        System.debug('Calling Wholesale Submit Quote for Approval..');
		boolean approvalTriggered = false;       
        SterlingQuote__c quote =[Select Id, status__c from SterlingQuote__c where Id=:quoteId];
        String quoteStatus = quote.Status__c;
        System.debug('Quote status while submitting quote for approval: ' + quoteStatus);
        if(String.isNotBlank(quoteStatus) && !quoteStatus.equalsIgnoreCase('Needs Review')) {
            return approvalTriggered;
        }
            
        Approval.ProcessSubmitRequest req1 = 
        new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(quoteId);
        req1.setSubmitterId(UserInfo.getUserId()); 
        req1.setProcessDefinitionNameOrId('WS_Product_Family_Assignment');
        req1.setSkipEntryCriteria(false);
        Approval.ProcessResult result = Approval.process(req1);
        approvalTriggered = true;
        return approvalTriggered;
    }
    
}