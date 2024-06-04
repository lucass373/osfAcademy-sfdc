/*
*********************************************************
Apex Class Name    : SumAmount
Created Date       : May 16, 2024
@description       : This class implements the Database.Batchable and Database.Stateful 
                     interfaces to process and summarize opportunity data in batches.
                     It uses the SummaryBatchHandler class to handle the processing 
                     and summarizing of opportunities.
@author            : Lucas Silva de Oliveira
Modification Log:
Ver   Date         Author         Modification
1.0   05-16-2024   Lucas Silva    Initial Version
1.1   06-03-2024   Lucas Silva    Implemmented the handler class
*********************************************************
*/
public class SumAmount implements Database.Batchable<SObject>, Database.Stateful {

    // Instance of SummaryBatchHandler to handle the processing and summarizing of opportunities.
    SummaryBatchHandler handler = new SummaryBatchHandler();

    /*
    *********************************************************
    @Method Name    : start
    @description    : This method is called at the beginning of the batch job. 
                      It returns the query to fetch the data.
    @param          : Database.BatchableContext bc - The context of the batch job.
    @return         : Database.QueryLocator - The query locator to fetch the opportunity data.
    *********************************************************
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT AccountId, StageName, Amount FROM Opportunity WHERE CloseDate = THIS_MONTH
        ]);
    }    
    
    /*
    *********************************************************
    @Method Name    : execute
    @description    : This method is called after the start method, where the data retrieved by the start
                      method is processed by processOpportunity method.
    @param          : Database.BatchableContext bc - The context of the batch job.
                      List<Opportunity> subList - The list of opportunity records for the current batch.
    @return         : void
    *********************************************************
    */
    public void execute(Database.BatchableContext bc, List<Opportunity> subList) {                
        handler.accountSummaryMap = handler.processOpportunity(subList);    
    }
    
    /*
    *********************************************************
    @Method Name    : finish
    @description    : This method is called after all batches are processed and the summary is sent to the primary contact for each account by the sendSumary method.
    @param          : Database.BatchableContext bc - The context of the batch job.
    @return         : void
    *********************************************************
    */
    public void finish(Database.BatchableContext bc) {
        handler.sendSumary(handler.accountSummaryMap);
    }
}
