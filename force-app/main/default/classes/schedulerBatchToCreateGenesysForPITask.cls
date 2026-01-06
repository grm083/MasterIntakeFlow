global class schedulerBatchToCreateGenesysForPITask implements schedulable{
    global void execute(SchedulableContext sc){
           ID BatchId = Database.executeBatch(new BatchToCreateGenesysForPITasks(), 200);
    }
}