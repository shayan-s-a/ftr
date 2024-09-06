/*********************************************************************************************************************
    *@Name        : OpportunityQuickQuoteController
    *@Author      : Dileep Chinthala <dileep.chinthala@ftr.com>
    *@Description : This utility class is called from QuickQuote Omniscript remote action generate QuickQuote.pdf with all quotes 
    				under an opportunity
    
    * UPDATES
    * Version 		Date       		Developer  				Description
    *------------------------------------------------------------------------------------------------------------------
    *1.0    		11/16/2021     Dileep Chinthala      Initial Creation                                                      
    
**********************************************************************************************************************/
    global class OpportunityQuickQuoteController implements vlocity_cmt.VlocityOpenInterface{
        global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
            String oppId = (String)inputMap.get('recordId');
            Boolean summQ = (Boolean)inputMap.get('summaryQuote');
            String commentStr =  '';
            String dt = Datetime.now().format('yyyy-MM-dd');
            List<Id> syncQ = new List<Id>(QuoteServiceController.getSyncedQuoteIdFromOpportunity(oppId).keySet());
            system.debug('!!!!' +syncQ);
            try {
                PageReference pdfPage;
                pdfPage = Page.CreateQuickQuote; 
                
                pdfPage.getParameters().put('oid', oppId);			
                pdfPage.getParameters().put('c', commentStr);
                If(summQ == true){
                pdfPage.getParameters().put('allQuotes', 'TRUE');
                } else{
                pdfPage.getParameters().put('allQuotes', 'FALSE');
                }
                
                
                pdfPage.setRedirect(true);
                Blob pdfBlob;
                if(!Test.isRunningTest())
                    pdfBlob = pdfPage.getContent();
                else {
                    pdfBlob = Blob.valueOf('Test pdf data');
                }
                System.debug('==========pdfBlob:' + pdfBlob);
                
                Opportunity objopp = [Select Id, RecordType.Name, ftr_NumberOfQuickQuotes__c, Name from Opportunity where Id=:oppId];
                Quote objquo = [Select Id, Name from Quote where OpportunityId =: objopp.Id AND IsSyncing__c = true];
                Integer count = [Select count() from Quote where OpportunityId =:oppId AND ftr_QuoteCreationStatus__c = 'Completed'];
                
                if(objopp.ftr_NumberOfQuickQuotes__c != count){
                    return false;
                }
                Boolean lightningRecordtype = false;
                if (objopp.RecordType.Name == 'Opportunity Lightning'){
                    lightningRecordtype = true;
                }
                if (true || lightningRecordtype || objopp.RecordType.Name == 'Partner Opportunity - New') {
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
                    conVer.PathOnClient = 'QuickQuote.pdf'; // The files name, extension is very important here which will help the file in preview.
                    //conVer.Title = 'QuickQuote.pdf'; // Display name of the files
                     If(summQ == true){
                         if(objopp.Name.contains('_DIA/MNS_')){
                          	conVer.Title = 'Summ-Q_DIA/MNS_'+dt+'.pdf';
                         }else{
                             If(objopp.Name.contains('_MNS_')){
                                 conVer.Title = 'Summ-Q_MNS_'+dt+'.pdf';
                             }else{
                                  conVer.Title = 'Summ-Q_DIA_'+dt+'.pdf';
                             }
                         }         
                     } else{
                         //conVer.Title = objquo.vlocity_cmt__EffectiveRecurringTotal__c+'-Q_DIA_'+dt+'.pdf';
                         //String NotesLowQuoteName='';
                         
                             If(objquo.Name.contains('MNS')){
                                 conVer.Title = 'LowMRC-Q_MNS_'+dt+'.pdf';
                             }else{
                                  conVer.Title = 'LowMRC-Q_DIA_'+dt+'.pdf';
                             }
                         
                     }
                    conVer.VersionData = pdfBlob; // converting your binary string to Blog
                    insert conVer;    //Insert ContentVersion
                    
                    // First get the Content Document Id from ContentVersion Object
                    Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                    //create ContentDocumentLink  record 
                    ContentDocumentLink conDocLink = new ContentDocumentLink();
                    conDocLink.LinkedEntityId = oppId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
                    conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
                    conDocLink.shareType = 'V';
                    insert conDocLink;
                } else {
                    Attachment oAtt = new Attachment(parentId = oppId, name = 'QuickQuote.pdf', body = pdfBlob);
                    insert oAtt;
                } 
                
                
                String userProfile = [SELECT Name
                                      FROM Profile
                                      WHERE Id =: userinfo.getProfileId()
                                      LIMIT 1].Name;
                
                
                return true;
            } catch (Exception ex) {
                System.debug('$$$Exception='+ex.getMessage());
            }
            return false;
        }
        
        
    }