trigger FeedCommentTrigger on FeedComment (before insert) {
    
    if(Trigger.isBefore&&Trigger.isInsert){
        FeedCommentTriggerHandler.onBeforeInsert(Trigger.new);
    }
}