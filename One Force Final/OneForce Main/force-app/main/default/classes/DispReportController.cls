public with Sharing class DispReportController {
    @AuraEnabled(cacheable= true)
    public static List<Contact> getContacts(){
        return [SELECT Id, LastName, FirstName FROM Contact limit 20 ];
    }
     @AuraEnabled(cacheable= true)
    public static string displayChart(){
        Report rep =[SELECT Id, DeveloperName FROM Report where DeveloperName ='New_Contacts_Accounts_Report_gEW'];
        return JSON.serialize(Reports.ReportManager.runReport(rep.Id),true) ;
        
    }
    public static string displayConReport(){
        Report rep =[SELECT Id, DeveloperName FROM Report where DeveloperName ='New_Contacts_Accounts_Report_Lwm'];
        return JSON.serialize(Reports.ReportManager.runReport(rep.Id),true) ;
        
    }
    
    

}