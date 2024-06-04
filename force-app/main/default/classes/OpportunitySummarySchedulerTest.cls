/*
*********************************************************
Apex Test Class Name : OpportunitySummarySchedulerTest
Created Date         : May 20, 2024
@description         : This test class verifies the functionality of the 
                       OpportunitySummaryScheduler class by scheduling the 
                       job.
@author              : Lucas Silva de Oliveira
Modification Log:
Ver   Date         Author         Modification
1.0   05-20-2024   Lucas Silva    Initial Version
1.1   05-21-2024   Lucas Silva    Update the testClass only to verify if the job is scheduled
*********************************************************
*/
@isTest
public class OpportunitySummarySchedulerTest {
     /*
    *********************************************************
    @Method Name    : testScheduler
    @description    : Test method to verify the scheduling of the OpportunitySummaryScheduler job.
    @param          : None
    @return         : void
    *********************************************************
    */
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