global class scheduledDeleteGenReportingBatch implements Schedulable {
    global void execute(SchedulableContext SC) {       
        DeleteGenesysReportingBatch batch = New DeleteGenesysReportingBatch();
            database.executeBatch(batch); 
    }

    //System.schedule('DeleteGenesysReportingBatch', '0 0 22 * * ? *', new scheduledDeleteGenReportingBatch());
}