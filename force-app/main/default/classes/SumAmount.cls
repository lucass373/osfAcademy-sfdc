public class SumAmount implements Database.Batchable<SObject>, Database.Stateful {
    // This map stores the summary of opportunities for each account, categorized by stage.
    //public Map<Id, Map<String, Decimal>> accountSummaryMap = new Map<Id, Map<String, Decimal>>();
    SummaryBatchHandler handler = new SummaryBatchHandler();

    // This method is called at the beginning of the batch job. It returns the query to fetch the data.
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT AccountId, StageName, Amount FROM Opportunity WHERE CloseDate = THIS_MONTH
        ]);
    }    
    // This method is called for each batch of records fetched by the start method.
    public void execute(Database.BatchableContext bc, List<Opportunity> subList) {                
        handler.accountSummaryMap = handler.processOpportunity(subList);    
    }
    
    // This method is called after all batches are processed.
    public void finish(Database.BatchableContext bc) {
        handler.sendSumary(handler.accountSummaryMap);
    }
}
