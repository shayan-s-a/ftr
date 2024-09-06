public class FTRWSImportAddressController {
    @AuraEnabled 
    public static Boolean saveFile(String base64Data) {
        try {
            System.debug('base64Data'+base64Data);
            String data = JSON.deserializeUntyped(base64Data).toString();
            System.debug('data@@'+data);
            list<String> lstCSVLines = data.split('\n');
            System.debug('@@CSVLineList'+lstCSVLines);
            List<SterlingQuoteItem__c> quoteItemList = new List<SterlingQuoteItem__c>();
            Boolean allowEdit = isDealDeskUser();
            for(Integer i = 1; i < lstCSVLines.size(); i++){
                String csvLine = lstCSVLines[i];
                List<String> csvRowData = new List<String>();
                Integer counter = 0;
                for(String column : csvLine.split(',')){
                    column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',').replaceAll('\"', '');
                    csvRowData.add(column);
                    counter = counter + 1;
                }
                System.debug('@@csvRowData'+csvRowData[39]);
                System.debug('@@csvRowData'+csvRowData[40]);
                System.debug('@@csvRowData'+csvRowData[41]);
                System.debug('@@csvRowData'+csvRowData[42]);
                if (String.isNotBlank(csvRowData[0])) {
                    SterlingQuoteItem__c quoteItem = new SterlingQuoteItem__c();
                    quoteItem.id = csvRowData[0];
                    quoteItem.CRT__c = allowEdit && String.isNotBlank(csvRowData[39]) ? csvRowData[39] : '';
                    if (allowEdit && String.isNotBlank(csvRowData[40])) {
                        quoteItem.Allocated_Total_Capex__c = Decimal.ValueOf(csvRowData[40]);
                    }
                    if (allowEdit && String.isNotBlank(csvRowData[41])) {
                        quoteItem.CIAC__c = Decimal.ValueOf(csvRowData[41]);
                    }
                    if (allowEdit && String.isNotBlank(csvRowData[42])) {
                        quoteItem.IRR_Internal_Rate_of_Return__c = Decimal.ValueOf(csvRowData[42]);
                    }
                    system.debug('quoteItem ==> ' + quoteItem);
                    quoteItemList.add(quoteItem);
                }
            }
            system.debug('quoteItem ==> lkist size ' + quoteItemList.size());
            Database.upsert(quoteItemList, false);
            return true;
        } catch (Exception ex) {
            return false;
        }
    }
    @AuraEnabled
    public static Boolean isDealDeskUser() {
        return FeatureManagement.checkPermission('DealDeskCustomPermission');
    }
}