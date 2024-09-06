@isTest
private class ScheduleServiceOrderStageUpdateTest {
    public static testMethod void testschedule() {
        Test.StartTest();

        ScheduleServiceOrderStageUpdate sh1 = new ScheduleServiceOrderStageUpdate();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Territory Check', sch, sh1);

        Test.stopTest();
    }
}