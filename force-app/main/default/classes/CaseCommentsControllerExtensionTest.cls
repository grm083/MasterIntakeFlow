/* 
* Apex Class : CaseCommentsControllerExtensionTest
* Description : This class is used for CaseCommentsControllerExtension
* Developer : Ruchika
* Date : 31/May/2022
* Edit Comments : SDT-23547
*/
@isTest
private class CaseCommentsControllerExtensionTest {
    public static Comment__c commentInstance {get; set;} 
private static final string CUSTOMER_SERVICE = 'Customer Service';
    
    @testSetup
    public static void dataSetup() {
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
        //Profile p = TestDataFactory.getProfile('System Administrator'); //Commented for SDT-33442
        Profile p = TestDataFactory.getProfile(CUSTOMER_SERVICE);
        User usr = TestDataFactory.createUser(p); //Modified for SDT-33442
        Database.insert(usr);
        system.runAs(usr){
            Account clientAcc = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,'Client')[0];
            Database.insert(clientAcc);
            
            Account locAcc = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, clientAcc.id)[0];
            Database.insert(locAcc);
            
            Contact contct = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, clientAcc, usr)[0];
            Database.insert(contct);
            
            Product2 prdct = TestDataFactory.createProduct('Sample Product Test')[0];
            Database.insert(prdct);
            
            Asset asst = TestDataFactory.createAsset('Test Asset', clientAcc,contct, prdct, usr,locAcc)[0];
            Database.insert(asst);
            
            AccountContactRelation testACR1 = TestDataFactory.returnAccConRel(locAcc.Id, contct, 'Commercial Service/Dispatch');
            Database.insert(testACR1);
            
            Case cse = TestDataFactory.createNewCase()[0];
            cse.Client__c = clientAcc.Id;
            cse.Location__c = locAcc.Id;
            cse.ContactId = contct.Id;
            cse.Case_Type__c = 'Pickup';
            cse.Case_Sub_Type__c = 'Empty and Return';
            cse.Origin = 'Phone';
            cse.Emergency__c = false;
            cse.Tracking_Number__c = 'T-000000';
            Database.insert(cse);
            
List<Opportunity> oppList = new List<Opportunity>(); //Modified for SDT-33442 
            Opportunity opp = new Opportunity(Name = 'Test Opp',Case__c = cse.Id,StageName = 'Proposal',CloseDate = system.today());
            oppList.add(opp); //Modified for SDT-33442 
            insert oppList; //Modified for SDT-33442
            
List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>(); //Modified for SDT-33442 
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quoteList.add(quote); //Modified for SDT-33442 
            insert quoteList; //Modified for SDT-33442  
            List<SBQQ__Quote__c> updatedQuoteList = new List<SBQQ__Quote__c>(); //Modified for SDT-33442 
            quote = [select Id, Name from SBQQ__Quote__c where id = : quote.id];
            quote.SBQQ__Account__c = locAcc.Id;
            quote.SBQQ__Status__c = 'Draft';
            quote.SBQQ__Opportunity2__c = opp.Id;
            quote.SBQQ__StartDate__c = system.today();
            updatedQuoteList.add(quote); //Modified for SDT-33442  
            update updatedQuoteList; //Modified for SDT-33442
            
            EmailMessage email = new EmailMessage();
            email.ParentId = cse.Id;
            email.RelatedToId = cse.Id;
            Database.insert(email);
            
            Comment__c notes = new Comment__c();
            notes.Case__c = cse.Id;
            notes.RecordTypeId = recordTypeId;
            notes.Acorn_Tracking_Number__c= 'T-000000';
            Database.insert(notes);
        }    
    }
    
    public static testmethod void processWithOutQuoteTest(){
        
        Test.startTest();
List<Comment__c> commentList = new List<Comment__c>(); //Modified for SDT-33442 
        Comment__c comment = [Select id,Acorn_Tracking_Number__c,Comment__c from Comment__c LIMIT 1];
        comment.Acorn_Tracking_Number__c = 'Q-0000';
        comment.Comment__c = 'Test';
        commentList.add(comment); //Modified for SDT-33442
        update commentList; //Modified for SDT-33442   
        CaseCommentsControllerExtension commentClass = new CaseCommentsControllerExtension(new ApexPages.StandardController(comment));
        commentClass.save();
        Test.stopTest();
        system.assert(comment != null);
    }
    
    public static testmethod void processWithQuoteTest(){
        
        Test.startTest();   
        Opportunity opp = [Select Id from Opportunity  limit 1];
List<SBQQ__Quote__c> sbqQuoteList = new List<SBQQ__Quote__c>(); //Modified for SDT-33442 
        SBQQ__Quote__c quote = [Select Id,SBQQ__Opportunity2__c,Case_Comments__c,SBQQ__Status__c,Name from SBQQ__Quote__c LIMIT 1];
        quote.SBQQ__Opportunity2__c = opp.Id;    
        quote.Case_Comments__c ='Test'; 
        sbqQuoteList.add(quote); //Modified for SDT-33442 
        update sbqQuoteList; //Modified for SDT-33442 
        List<Comment__c> commentList = new List<Comment__c>(); //Modified for SDT-33442
        Comment__c comment = [Select id,Acorn_Tracking_Number__c,Comment__c from Comment__c LIMIT 1];
        comment.Acorn_Tracking_Number__c = quote.Name ;
        comment.Comment__c = 'Test';
        commentList.add(comment); //Modified for SDT-33442
        update commentList; //Modified for SDT-33442
        CaseCommentsControllerExtension commentClass = new CaseCommentsControllerExtension(new ApexPages.StandardController(comment));
        commentClass.save();
        Test.stopTest();
        system.assert(comment != null);
    }
    
    public static testmethod void processQuoteTestWithTrackingNumber(){
        
        Test.startTest();
        Opportunity opp = [Select Id from Opportunity  limit 1];
List<SBQQ__Quote__c> sbqQuoteList = new List<SBQQ__Quote__c>(); //Modified for SDT-33442 
        SBQQ__Quote__c quote = [Select Id, SBQQ__Status__c,SBQQ__Opportunity2__c,Case_Comments__c from SBQQ__Quote__c LIMIT 1];
        quote.SBQQ__Opportunity2__c = opp.Id;    
        quote.Case_Comments__c ='Test';
        sbqQuoteList.add(quote); //Modified for SDT-33442 
        update sbqQuoteList; //Modified for SDT-33442
        List<Comment__c> commentList = new List<Comment__c>(); //Modified for SDT-33442 
        Comment__c comment = [Select id,Acorn_Tracking_Number__c,Comment__c from Comment__c LIMIT 1];
        comment.Acorn_Tracking_Number__c = 'T-000000';
        comment.Comment__c = 'Test';
        commentList.add(comment); //Modified for SDT-33442 
        update commentList; //Modified for SDT-33442
        CaseCommentsControllerExtension commentClass = new CaseCommentsControllerExtension(new ApexPages.StandardController(comment));
        commentClass.save();
        Test.stopTest();
        system.assert(comment != null);
    }
    
    public static testmethod void processQuoteTestWithoutTrackingNumber(){
        
        Test.startTest();
        Opportunity opp = [Select Id from Opportunity  limit 1];
List<Comment__c> commentList = new List<Comment__c>(); //Modified for SDT-33442
        Comment__c comment = [Select id,Acorn_Tracking_Number__c,Comment__c from Comment__c LIMIT 1];
        comment.Comment__c = 'Test';
    //    comment.Acorn_Tracking_Number__c  ='';
        commentList.add(comment); //Modified for SDT-33442
        update commentList; //Modified for SDT-33442
        List<SBQQ__Quote__c> sbqQuoteList = new List<SBQQ__Quote__c>(); //Modified for SDT-33442 
        SBQQ__Quote__c quote = [Select Id, SBQQ__Status__c,SBQQ__Opportunity2__c,Case_Comments__c from SBQQ__Quote__c LIMIT 1];
        quote.SBQQ__Opportunity2__c = opp.Id;    
        quote.Case_Comments__c ='Test';
        sbqQuoteList.add(quote); //Modified for SDT-33442
        update sbqQuoteList; //Modified for SDT-33442
        CaseCommentsControllerExtension commentClass = new CaseCommentsControllerExtension(new ApexPages.StandardController(comment));
        commentClass.save();
        Test.stopTest();
        system.assert(comment != null);
    }
    
    public static testmethod void processQuoteCaseTestWithoutTrackingNumber(){
        
        Test.startTest();
        Opportunity opp = [Select Id from Opportunity  limit 1];
List<Comment__c> commentList = new List<Comment__c>(); //Modified for SDT-33442
        Comment__c comment = [Select id,Acorn_Tracking_Number__c,Comment__c from Comment__c LIMIT 1];
        comment.Acorn_Tracking_Number__c = 'ABC';
        comment.Comment__c = 'Test';
        commentList.add(comment); //Modified for SDT-33442
        update commentList; //Modified for SDT-33442
        List<SBQQ__Quote__c> sbqQuoteList = new List<SBQQ__Quote__c>(); //Modified for SDT-33442 
        SBQQ__Quote__c quote = [Select Id, SBQQ__Status__c,SBQQ__Opportunity2__c,Case_Comments__c from SBQQ__Quote__c LIMIT 1];
        quote.SBQQ__Opportunity2__c = opp.Id;    
        quote.Case_Comments__c ='Test';
        sbqQuoteList.add(quote); //Modified for SDT-33442
        update sbqQuoteList; //Modified for SDT-33442
        CaseCommentsControllerExtension commentClass = new CaseCommentsControllerExtension(new ApexPages.StandardController(comment));
        commentClass.save();
        Test.stopTest();
        system.assert(comment != null);
    }
}