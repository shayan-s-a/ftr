public with sharing class ReportController {
  
    @AuraEnabled(cacheable=true)
    public static List<ADPGridWrapper> getGridData(String dtFromParam ,String dtToParam ,Integer noOfDays){
        
        List<String> Pcodes = new List<String> {'Labour Regular', 'Paid Leave'};
        Date dateFrom =  Date.valueOf( dtFromParam);
        Date dateTo   =  Date.valueOf( dtToParam);
        // string dateFrom='2023-07-19';
        // string dateTo='2023-07-20';
        List<ADPGridWrapper> AdpGridLst = new List<ADPGridWrapper>();     
        for(AggregateResult agg: [select Contact__r.Account.Payroll_Company_Code__c PCC, Contact__r.File_Number__c FNumber,Sum(Hours__c) TotHr,Pay_Code__c PCode from TimeSheet__c where (Pay_Code__c ='Labour Regular' or Pay_Code__c ='Paid Leave') AND Day__c >=: dateFrom AND Day__c <=: dateTo group by  Contact__r.File_Number__c,Pay_Code__c,Contact__r.Account.Payroll_Company_Code__c ] ) 
        {       ADPGridWrapper AdpGrid = new ADPGridWrapper();
                AdpGrid.CoCode = (String) agg.get('PCC');
               //BacthID from Company code 
                AdpGrid.BatchId = (AdpGrid.CoCode== '92j') ? '90' : 'Wrksh001';
               
               
                AdpGrid.FileNumber = (String) agg.get('FNumber');
                AdpGrid.TaxFrequency = 0;
                system.debug('FNO:'+agg.get('FNumber')); 
                system.debug('Hr::'+agg.get('TotHr')); 
                Decimal TotalHrs=(Decimal)agg.get('TotHr');
                Decimal weeks =noOfDays / 7;
                Decimal LimitDays =40 * weeks;
                system.debug('TotalHr:'+TotalHrs);
                system.debug('noOfDays:'+noOfDays);
                system.debug('LimitDays:'+LimitDays);
                if(agg.get('PCode')==Pcodes[0] ){

                    if (TotalHrs>LimitDays){
                        AdpGrid.RegHours=LimitDays;
                        AdpGrid.OTHours=TotalHrs-LimitDays;
                        system.debug('More Hrs::::'+AdpGrid.RegHours); 
                    }
                    else
                    {
                        AdpGrid.RegHours = TotalHrs;
                        AdpGrid.OTHours = 0;
                        system.debug('Less Hrs----'+AdpGrid.RegHours);
                    }
                }
                else if (agg.get('PCode')==Pcodes[1] ){
                    AdpGrid.Hours3Code = TotalHrs;
                    System.debug( 'In Paid Leave'+Pcodes[1]+'>>>'+AdpGrid.Hours3Code);
                }
                AdpGridLst.add(AdpGrid);

            }   
           
            return AdpGridLst;
    }
  
   
    public class ADPGridWrapper {
        @AuraEnabled
        public String CoCode {get; set;}
        @AuraEnabled
        public String BatchId {get; set;}
        @AuraEnabled
        public String FileNumber {get; set;}
        @AuraEnabled
        public integer TaxFrequency {get; set;}
        @AuraEnabled
        public Decimal RegHours {get; set;}
        @AuraEnabled
        public Decimal OTHours {get; set;}
        @AuraEnabled
        public Decimal Hours3Code {get; set;}
    
        
        // public ADPGridWrapper() {
        //     Id='Id';
        //     CoCode='code';
        //     BatchId ='Batch Id ';
        //     FileNumber ='432532N';
        //     TaxFrequency =0;
        //     RegHours =0;
        //     OTHours=0;
        //     Hours3Code =0;
        // }
    }
  
    public class ContactItemWrapper {       
             
            public Integer recordStart {get;set;}
            public Integer pageNumber {get;set;}
            public Integer totalRecords {get;set;}
            public Integer recordEnd {get;set;}
            public Integer pageSize {get;set;}       
            public List<String> ADPGrids {get;set;}
    }
        
      
}