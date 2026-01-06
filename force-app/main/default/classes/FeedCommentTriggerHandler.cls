public class FeedCommentTriggerHandler {

    public static void onBeforeInsert(List<FeedComment> comments){
        try{
        	FeedCommentTriggerHelper.preventInsert(comments);
        }
        catch(Exception e){
            System.debug('Exception:::::::' + e.getStackTraceString());
        }
    }
}