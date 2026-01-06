@isTest
public class FeedCommentTriggerHelperTest {

    @testSetup static void setup(){
        Case c = new Case();
        insert c;
        
        FeedItem fi = new FeedItem();
        fi.type = 'EmailMessageEvent';
        fi.ParentId = c.id;
        insert fi;

    }
    
    @isTest static void runTest(){
        FeedItem fi = [SELECT Id FROM FeedItem WHERE Type = 'EmailMessageEvent' LIMIT 1];
        
        Test.startTest();
        FeedComment fc = new FeedComment();
        fc.FeedItemId = fi.Id;
        try{
            insert fc;
        }
        catch(Exception e){
			System.debug(e.getMessage());
        }
        
    }
}