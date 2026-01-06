public class CaseCommentsControllerExtension {
public Comment__c comment {get; set;}
public CaseCommentsControllerExtension (ApexPages.StandardController controller) {
comment = (Comment__c) controller.getRecord();
}
/***
* Acorn_SUser_ID__c - Take it from User Object
* Acorn_Tracking_Number__c = Comes from Input
* Case_Number__c = Look up in the Case object based on Acorn_Tracking_Number__c
* Case__c = Look up in the Case object based on Acorn_Tracking_Number__c
* Comment__c = Comes from Input
* Communication_Log_Type_Name__c = Always "Internal"
* Type__c = always "Case"
**/

 Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
    
    public void save(){
        
        if(comment.Acorn_Tracking_Number__c != null){    
            String process = checkforQuoteOrCase(comment.Acorn_Tracking_Number__c );
            switch on process{
                when 'quote'{
                    processQuote();
                } 
                when 'case'{
                    processCase();
                } 
                when else {                
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Quote Number should contain Q- and Tracking Number should start with T')); 
                }
            }
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please Provide Quote Number or Tracking Number'));            
        }
    }
    
    public void processQuote()
    { 
        List<SBQQ__Quote__c> quoteRecords = new List<SBQQ__Quote__c>();
        User currUser = [SELECT Acorn_SUser_ID__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
        for(SBQQ__Quote__c qa :[Select id,SBQQ__Opportunity2__r.Case__r.CaseNumber, SBQQ__Opportunity2__r.Case__r.id from SBQQ__Quote__c  where Name=: comment.Acorn_Tracking_Number__c  LIMIT 2 ])
        {
            quoteRecords.add(qa);
        }
        
        if((quoteRecords.IsEmpty() && quoteRecords.size() == 0)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'No Quotes found for "'+comment.Acorn_Tracking_Number__c +'". Please enter valid Quote Number!')); 
        } else if (quoteRecords.size() > 1){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Multiple Quotes found, please enter valid Quote Number!')); 
        } else{
            Comment__c newComment  =  new Comment__c();
            for(SBQQ__Quote__c quoRec : quoteRecords){
                newComment.Comment__c = comment.comment__c;
                newComment.Acorn_SUser_ID__c = currUser.Acorn_SUser_ID__c;
                newComment.Case_Number__c = quoRec.SBQQ__Opportunity2__r.Case__r.CaseNumber;
                newComment.Case__c = quoRec.SBQQ__Opportunity2__r.Case__r.id;
                newComment.Communication_Log_Type_Name__c = 'Internal';
                newComment.Type__c = 'Case';
                newComment.RecordTypeId =  recordTypeId;
            }
            Database.SaveResult svRst = database.insert(newComment,true);
            if(svRst.isSuccess()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Cost data saved for Quote "'+comment.Acorn_Tracking_Number__c +'"" successfully!')); 
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Error saving cost data for Quote. Please try again.')); 
            }
        }   
    }
    
    public void processCase()
    {
        List<Case> caseRecords = new List<Case>();
        User currUser = [SELECT Acorn_SUser_ID__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
        for(Case ca : [select id, CaseNumber,Tracking_Number__c, OwnerId from Case where Tracking_Number__c = : comment.Acorn_Tracking_Number__c  LIMIT 5]){
            caseRecords.add(ca);
        } 
        if((caseRecords.IsEmpty() && caseRecords.size() == 0)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'No Acorn Tickets found for "'+comment.Acorn_Tracking_Number__c +'". Please enter valid Acorn Tracking Number!')); 
        } else if (caseRecords.size() > 1){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Multiple Acorn Tickets found, please enter valid Acorn Tracking Number!')); 
        } else{
            Comment__c newComment  =  new Comment__c();
            for(Case caseRec : caseRecords){
                newComment.Comment__c = comment.comment__c;
                newComment.Acorn_SUser_ID__c = currUser.Acorn_SUser_ID__c;
                newComment.Case_Number__c = caseRec.CaseNumber;
                newComment.Case__c = caseRec.id;
                newComment.Communication_Log_Type_Name__c = 'Internal';
                newComment.Type__c = 'Case';
                newComment.is_Log__c = true;
                // newComment.RecordTypeId =  recordTypeId;
				newComment.Acorn_Tracking_Number__c = caseRec.Tracking_Number__c ;
            }
            Database.SaveResult svRst = database.insert(newComment,true);
            if(svRst.isSuccess()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Cost data saved to Acorn ticket "'+comment.Acorn_Tracking_Number__c +'"" successfully!')); 
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Error saving cost data to Acorn ticket. Please try again.')); 
            }
        }   
    }
    
    public string checkforQuoteOrCase(String inputValue)
    { 
        if(inputValue.startsWith('Q-'))
        {   
            return 'quote';  
        } 
        else if (inputValue.startsWith('T'))
        {
            return 'case';
        }
        return 'other';
    }

}