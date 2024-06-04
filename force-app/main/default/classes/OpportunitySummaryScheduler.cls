/*
*********************************************************
Apex Class Name    : OpportunitySummaryScheduler
Created Date       : May 19, 2024
@description       : This class implements the Schedulable interface to schedule 
                     the execution of the SumAmount batch job.
@author            : Lucas Silva de Oliveira
Modification Log:
Ver   Date         Author         Modification
1.0   05-19-2024   Lucas Silva    Initial Version
*********************************************************
*/
public class OpportunitySummaryScheduler implements Schedulable{
    /*
    *********************************************************
    @Method Name    : execute
    @description    : Executes the scheduled job to run the SumAmount batch job.
    @param          : SchedulableContext ctx - Represents the job context.
    @return         : void
    *********************************************************
    */
    public void execute(SchedulableContext ctx){
        SumAmount batchInstance = new SumAmount();
        // Start the batch job
        Database.executeBatch(batchInstance);
    }
}

//SCRIPTS TO SCHEDULE THE JOB
//// Schedule Daily at 10:00 AM
//System.schedule('Daily Opportunity Summary', '0 0 10 * * ?', new OpportunitySummaryScheduler());

// Schedule Weekly on Friday at 1:00 PM
//System.schedule('Weekly Opportunity Summary', '0 0 13 ? * 6', new OpportunitySummaryScheduler());

// Schedule Monthly on the last Friday at 6:00 PM
//System.schedule('Monthly Opportunity Summary', '0 0 18 ? * 6L', new OpportunitySummaryScheduler());