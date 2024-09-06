@isTest
public class FTRWSImportAddressControllerTest {
    @TestSetup
    static void makeData() {
        User usr = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamamaAdmin.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Alternate Channel' limit 1].Id,
            isActive=true
        );
        insert usr;
        System.runAs(usr) {
            Id globalRecId = [select id,name,developername from recordtype where sobjecttype='account' and developername='global' LIMIT 1]?.Id;
            Account globalAcc = new Account();
            globalAcc.Name = 'GLOBAL ACCOUNT';
            globalAcc.RecordTypeId = globalRecId;
            insert globalAcc;
            Account objAcc = new Account();
            objAcc.Name ='testing Name';
            objAcc.Legal_Street__c='test';
            objAcc.Legal_City__c='test';
            objAcc.Legal_State__c='test';
            objAcc.ShippingStreet='test';
            objAcc.ShippingCity='NY';
            objAcc.ShippingState='New York';
            objAcc.BillingStreet='test';
            objAcc.BillingCity='NY';
            objAcc.BillingState='New York';
            objAcc.ParentId = globalAcc.Id;
            insert objAcc;
            
            Opportunity objOpp = new Opportunity();
            objOpp.Name ='Testing Name';
            objOpp.AccountId= objAcc.Id;
            objOpp.CloseDate = date.today();
            objOpp.StageName ='Verbal Commit';
            objOpp.Expected_Billed_Date__c = date.today();
            objOpp.Bypass_Validation__c = true;
            insert objOpp;
            
            list<RecordType> recordtypeid = [SELECT BusinessProcessId,DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = 'SFA' AND SobjectType = 'SterlingQuote__c'];        
            
            SterlingQuote__c objquote = new SterlingQuote__c();
            objquote.Name='Testing Name';
            objquote.ExpirationDate__c=date.today();
            objquote.OpportunityId__c=objOpp.id;
            objquote.Account_Name__c= objAcc.Id;
            objquote.IsSyncing__c=false;
            objquote.RecordTypeId = recordtypeid[0].Id; 
            //objquote.MinorLine__c = 0; 
            insert objquote; 
            
            SterlingQuoteItem__c objst = new SterlingQuoteItem__c();
            objst.name='test';
            objst.Description__c='Running Test Class';
            objst.SterlingQuote__c = objquote.id;
            objst.IsInFrontierFootprint__c=false;
            objst.OverallStatus__c ='pending';
            objst.DiscountType__c ='ICB';
            objst.ApprovalTerritory__c ='Indiana';
            objst.ApprovalRouting__c='Customer Build';
            objst.ApprovalRegion__c='IN';
            objst.StandardMRC__c= 10.00;
            objst.StandardNRC__c=10.00;
            objst.AdjustedMRC__c=10.00;
            objst.AdjustedNRC__c=10.00;
            objst.Quantity__c=10;
            objst.OwnerId= userinfo.getUserId(); 
            objst.ItemOwner__c =userinfo.getUserId();
            objst.ApprovalPriority__c='Normal';
            objst.Locality__c='Indiana'; 
            objst.StateProvince__c='IN' ;
            objst.NXX__c='10';
            objst.SetNextApprover__c= true;
            objst.OverallStatus__c='';
            objst.SIFT_Required__c=true;
            objst.SIFT_InquiryId__c='1234';
            objst.NetNewMRR__c=10.00;
            
            insert objst;
            
        }
    }
    public static testmethod void saveFileTest(){
        Test.startTest();
        SterlingQuoteItem__c objQuote = [SELECT Id FROM SterlingQuoteItem__c LIMIT 1];
        String date32= String.valueOf(Date.newInstance(2020, 11, 30));
        String fileContent = '"QuoteItemId,Street,unit,city,StateOrProvince,postalCode,Latitude,Longitude,ACNA,PNUM,Product,Configuration,EVC_Bandwidth,Level_of_Service,Term_Aggrement,Comments,DPI_Qualified,DSAT_Qualified,In_Footprint,WireCenter_CLLI,Max_Qos,DSAT_Max_Speed,Copper_Qualification,Copper_Tier,Fiber_Qualification,Fiber_Tier,MRC,NRC,Notes,CVD_rate_Source,CVD_rate_Tier,DSAT_ID,FiberDistance,AddressLost,AddressLostReason,NonAdjustedMRC,NonAdjustedNRC,CRT,CIAC,NPV,IRR,AT_TMRC,AT_TDate,UNI_NNISpeed,UNI_NNIType,CSLATA,SiteID,AltSiteName,InterconnectLata,InterconnectCLLI,County,MTSOLATA,UMTSMTSO,NeedbyDate\\r\\n{quoteId},7060 Mountaineer Hwy,,Avondale,WV,,37.416977,-81.788972,,EIAV001GIM300484,EIA 200M,EVC,200M,,3 Years,,TRUE,TRUE,TRUE,BRDSWVBK,Platinum,1000MB,BDT,BDT,Qualified (max WC speed),2,810,0,,CLLICd,3,1720677,2693,FALSE,,$900 ,$0.00 ,1,2,3,4,,,,,0,,,0,,,0,,\\r\\n"';
        fileContent = fileContent.replace('{quoteId}', objQuote.Id);
        FTRWSImportAddressController.saveFile(fileContent);
        Test.stopTest();
    }
}