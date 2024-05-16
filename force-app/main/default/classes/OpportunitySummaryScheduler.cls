public class OpportunitySummaryScheduler implements Schedulable{
    public void execute(SchedulableContext ctx){
        SumAmount batchInstance = new SumAmount();
        // Start the batch job
        Database.executeBatch(batchInstance);
    }
}