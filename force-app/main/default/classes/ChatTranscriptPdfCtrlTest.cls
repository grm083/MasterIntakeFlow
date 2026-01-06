/**
* @date 25/05/2023
* @description : Test class for ChatTranscriptPdfCtrl
**/

@isTest(seeAllData = false)
public class ChatTranscriptPdfCtrlTest {
    
    static testMethod void testChatTranscriptPdf() {
        
        Test.StartTest();
        PageReference pageRef = Page.ChatTranscriptPdf; 
        pageRef.getParameters().put('resList', '[{"chatDateTime":"05/01/2023 01:42:53 PM","messageText":"Disposition Code: Account Assistance","userId":"chatbot customer"},{"chatDateTime":"05/01/2023 01:42:53 PM","messageText":"Transferred from wm.com chatbot","userId":"chatbot customer"}]');
        Test.setCurrentPage(pageRef);
        
        ChatTranscriptPdfCtrl testClsChat = new ChatTranscriptPdfCtrl();
        ChatTranscriptPdfCtrl.ResponseWrapper resWrap = new ChatTranscriptPdfCtrl.ResponseWrapper();
        resWrap.chatDateTime = '05/01/2023 01:42:53 PM';
        resWrap.messageText = 'Hello WM';
        resWrap.userId = 'National Accounts';
        resWrap.errorMessage = 'Server Issue';
        Test.StopTest();
        
    }
    
}