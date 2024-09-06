/**
 * @description Service class to handle the Quote to Opportunity Sync
 *              Always one way sync from Quote to Opportunity
 * @version 1
 */
global with sharing class ftr_CpqAppHandlerHookImpl implements vlocity_cmt.VlocityOpenInterface {
    public static String debugLimits() {
        return '(Cpu:' + String.valueOf(Limits.getCpuTime()) + ', Query:' + String.valueOf(Limits.getQueries()) + '-' + String.valueOf(Limits.getQueryRows()) + ', DML:' + String.valueOf(Limits.getDMLStatements()) + '-'  + String.valueOf(Limits.getDMLRows()) + ', Heap:' + String.valueOf(Limits.getHeapSize()) + ')';
    }


    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        ftr_CpqService service = new ftr_CpqService();
        ftr_CpqCartCtx.isInCpq = true;
        try {
            ftr_Logger.writeInfo('Enter ftr_CpqAppHandlerHookImpl.' + methodName);
            Boolean invokeResult = true;
            if (methodName.endsWith('PreInvoke') && methodName != 'PricingPlan.PreInvoke' && methodName != 'deleteCartsItems.PreInvoke') {
                 QuoteSyncService.DelaySyncProcess(QuoteSyncService.DelayByVlocityCpqApi);
            } 
            // PreInvokes
            if (methodName == 'getCartsItems.PreInvoke') {
                invokeResult = service.GetCartsItems_PreInvoke(inputMap, outputMap, options);
            } else if (methodName == 'postCartsItems.PreInvoke') {
                invokeResult = service.PostCartsItems_PreInvoke(inputMap, outputMap, options);
            } else if (methodName == 'cloneItems.PreInvoke') {
                invokeResult = service.CloneCartsItems_PreInvoke(inputMap, outputMap, options);
            } else if (methodName == 'putCartsItems.PreInvoke') {
                invokeResult = service.PutCartsItems_PreInvoke(inputMap, outputMap, options);
            } else if (methodName == 'deleteCartsItems.PreInvoke') {
                // When an EVC product or a bundle with EVC is deleted, the Rollup for Access needs to be re-calculated
                // If the EVC to be deleted is part of EVPL, the rollup for EVPL needs to be re-calculated
                invokeResult = service.DeleteCartsItems_PreInvoke(inputMap, outputMap, options);

            }
            // PostInvokes
            else if (methodName == 'getCartsItems.PostInvoke') {
            } else if (methodName == 'postCartsItems.PostInvoke') {
                invokeResult = service.PostCartsItems_PostInvoke(inputMap, outputMap, options);
            } else if (methodName == 'putCartsItems.PostInvoke') {
                invokeResult = service.PutCartsItems_PostInvoke(inputMap, outputMap, options);
            } else if (methodName == 'deleteCartsItems.PostInvoke') {
                invokeResult = service.DeleteCartsItems_PostInvoke(inputMap, outputMap, options);
            }
            // Pricing Plan step
            else if (methodName == 'PricingPlan.PreInvoke') {
                SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
                List<SObject> itemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
                invokeResult = service.PricingPlan_PreInvoke(inputMap, parent, itemList);
            }
            
            if (methodName.endsWith('PostInvoke')) {
                QuoteSyncService.Sync(true);
            }
            System.debug('Perf - ftr_CpqAppHandlerHookImpl.' + methodName + ' ' + debugLimits());
            // System.debug('Perf - CpuTime: ' + String.valueOf(Limits.getCpuTime()));
            // System.debug('Perf - HeapSize: ' + String.valueOf(Limits.getHeapSize()));
            // System.debug('Perf - DMLStatements: ' + String.valueOf(Limits.getDMLStatements()));
            // System.debug('Perf - Queries: ' + String.valueOf(Limits.getQueries()));            
            return invokeResult;
        }
        catch (Exception ex) {
            ftr_Logger.write(ex);
            return false;
        } finally {
            ftr_Logger.writeInfo('Exit ftr_CpqAppHandlerHookImpl.' + methodName);
        }
    }
}