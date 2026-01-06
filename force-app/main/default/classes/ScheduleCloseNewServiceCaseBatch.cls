/*
Author: Jatan Sharma
Story: SDT-20337
Description: to execute the CloseNewServiceCaseBatch
*/
global class ScheduleCloseNewServiceCaseBatch implements Schedulable {

    public void execute(SchedulableContext sc) {
        CloseNewServiceCaseBatch closeNewServiceCaseBatch = new CloseNewServiceCaseBatch();
        database.executeBatch(closeNewServiceCaseBatch, 45);
    }
}