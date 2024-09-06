public class AssetStagingCircuitHandler {
    public static void updateAddressesOnCircuits(List<ftr_Asset_StagingCircuit__c> circuitList) {
        Map<String, List<ftr_Asset_StagingCircuit__c>> wtnToCircuitMap = new Map<String, List<ftr_Asset_StagingCircuit__c>>();
        for (ftr_Asset_StagingCircuit__c circuit : circuitList) {
            if (String.isBlank(circuit.WTN__c)) {
                continue;
            }
            if (wtnToCircuitMap.containsKey(circuit.WTN__c)) {
                List<ftr_Asset_StagingCircuit__c> circList = wtnToCircuitMap.get(circuit.WTN__c);
                circList.add(circuit);
                wtnToCircuitMap.put(circuit.WTN__c, circList);
            } else {
                wtnToCircuitMap.put(circuit.WTN__c, new List<ftr_Asset_StagingCircuit__c>{circuit});
            }
        }
        Map<String, ftr_Asset_StagingCircuit_DPI__c> wtnToDPIMap = new Map<String, ftr_Asset_StagingCircuit_DPI__c>();
        //fetch dpi record for the wtn set
        List<ftr_Asset_StagingCircuit_DPI__c> dpiList = [SELECT Id, Zipcode__c, City__c, WTN__c, Service_Address__c, State__c FROM ftr_Asset_StagingCircuit_DPI__c WHERE WTN__c IN: wtnToCircuitMap.keySet() AND WTN__c != null AND Zipcode__c != null AND Service_Address__c != null AND City__c != null AND State__c != null];
        for (ftr_Asset_StagingCircuit_DPI__c dpi : dpiList) {
            if (!wtnToDPIMap.containsKey(dpi.WTN__c)) {
                wtnToDPIMap.put(dpi.WTN__c, dpi);
            }
        }
        for (String wtn : wtnToDPIMap.keySet()) {
            ftr_Asset_StagingCircuit_DPI__c dpi = wtnToDPIMap.get(wtn);
            if (wtnToCircuitMap.containsKey(wtn)) {
                for (ftr_Asset_StagingCircuit__c circuit : wtnToCircuitMap.get(wtn)) {
                    circuit.Serviceaddress_DPI__c = dpi.Service_Address__c;
                    circuit.City_DPI__c = dpi.City__c;
                    circuit.Zipcode_DPI__c = dpi.Zipcode__c;
                    circuit.State_DPI__c = dpi.State__c;
                    circuit.Service_Address_From_DPI__c = true;
                }
            }
        }
    }
}