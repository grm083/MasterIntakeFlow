public class FeedCommentTriggerHelper {

    public static void preventInsert(List<FeedComment> comments){
        for(FeedComment fc : comments){
            fc.addError('Please add comments through the "Comments" action bar below or through the "Comments" tab.');
        }
			
    }
}