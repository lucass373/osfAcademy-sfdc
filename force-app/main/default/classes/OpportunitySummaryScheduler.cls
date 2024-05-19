public class OpportunitySummaryScheduler implements Schedulable{
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