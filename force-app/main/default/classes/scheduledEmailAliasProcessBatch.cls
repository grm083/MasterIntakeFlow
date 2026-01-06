global class scheduledEmailAliasProcessBatch implements Schedulable {
    global void execute(SchedulableContext SC) {       
        EmailAliasProcessBatch batch = New EmailAliasProcessBatch();
            database.executeBatch(batch,200); 
    }
    /*
        To run every 15 mins 
        System.schedule('EmailAliasProcessBatch: at 00 mins', '0 0 * * * ?', new scheduledEmailAliasProcessBatch());
        System.schedule('EmailAliasProcessBatch: at 15 mins', '0 15 * * * ?', new scheduledEmailAliasProcessBatch());
        System.schedule('EmailAliasProcessBatch: at 30 mins', '0 30 * * * ?', new scheduledEmailAliasProcessBatch());
        System.schedule('EmailAliasProcessBatch: at 45 mins', '0 45 * * * ?', new scheduledEmailAliasProcessBatch());
    */
}