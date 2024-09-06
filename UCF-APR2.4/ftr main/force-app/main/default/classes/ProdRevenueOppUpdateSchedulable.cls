/**
 * ───────────────────────────────────────────────────────────────────────────────────────────────┐
* Schedules the ProdRevenueOppUpdateBatch class.
* ────────────────────────────────────────────────────────────────────────────────────────────────
* @param    not applicable
* @return   not applicable
* ───────────────────────────────────────────────────────────────────────────────────────────────┘
*/
global class ProdRevenueOppUpdateSchedulable implements Schedulable {
    global void execute(SchedulableContext sc){
        //calling the batch apex
        Database.executeBatch(new ProdRevenueOppUpdateBatch(),20);
    }
}