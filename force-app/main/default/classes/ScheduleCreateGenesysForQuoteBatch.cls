/*
Author: Shilpa Bhatia
Story: SDT-23088
Description: Scheduling the CreateGenesysForQuoteBatch.
*/
global class ScheduleCreateGenesysForQuoteBatch implements Schedulable {
    private static Integer BATCHSIZE= 50;

    public void execute(SchedulableContext sc) {
        CreateGenesysForQuoteBatch genesysQuoteBatch = new CreateGenesysForQuoteBatch();
        database.executeBatch(genesysQuoteBatch, 50);
    }
}