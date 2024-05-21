@isTest
public class OpportunitySummarySchedulerTest {
    @isTest
    static void testScheduler() {
        // Schedule the job
        System.Test.startTest();
        String jobId = System.schedule('Test Opportunity Summary Scheduler', '0 0 10 * * ?', new OpportunitySummaryScheduler());
        System.Test.stopTest();
        
        // Verify that the job is scheduled
        System.assertNotEquals(null, jobId, 'Job should be scheduled');
     
    }
}