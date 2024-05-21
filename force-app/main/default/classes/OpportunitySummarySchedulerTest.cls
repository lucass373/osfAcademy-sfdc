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
        
        // Verify that the scheduled job is of the correct type
        AsyncApexJob scheduledJob = [SELECT Id, JobType FROM AsyncApexJob WHERE Id = :jobId];
        System.assertEquals('ScheduledApex', scheduledJob.JobType, 'Job should be of type ScheduledApex');
        
        // Verify that the scheduled job's name matches
        System.assertEquals('Test Opportunity Summary Scheduler', scheduledJob.ApexClass.Name, 'Job name should match');
    }
}