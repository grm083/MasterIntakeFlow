/*
Author: Anup Dey
Story: SDT-22548
Description: to execute the QuotePriorityChangeBatch
*/
global class ScheduleQuotePriorityChangeBatch implements Schedulable {
    private static Integer BATCHSIZE= 45;

    public void execute(SchedulableContext sc) {
        QuotePriorityChangeBatch quotePriorityChangeBatch = new QuotePriorityChangeBatch();
        database.executeBatch(quotePriorityChangeBatch, BATCHSIZE);
    }
}