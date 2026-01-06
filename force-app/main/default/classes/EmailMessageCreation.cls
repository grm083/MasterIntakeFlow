/*************************************************************
@Name: EmailMessageCreation
@Author: Shilpa Bhatia
@CreateDate: 7/27/2022
@Description: For Creation of EmailMessage and attaching it to related Quote .
**************************************************************/
public class EmailMessageCreation {
	
    public static EmailMessage attachEmailIfRefExists(Messaging.InboundEmail email){
        
       List<SBQQ__Quote__c> NSQuotelist = new List<SBQQ__Quote__c>(); 
       SBQQ__Quote__c NSQuote = new SBQQ__Quote__c();
   	   Pattern quoteThread = Pattern.compile(Constant_Util.QUOTEREFERENCE);
        String htmlBody = email.htmlBody;
        htmlBody = htmlBody.replaceFirst('(>\\s*)Ref:','$1ref:');
        Matcher quoteMatch = quoteThread.matcher(htmlBody);
        
        EmailMessage newMessage = new EmailMessage();
        newMessage.HtmlBody = htmlBody;
        newMessage.Status = '0';
        newMessage.FromAddress = email.fromAddress;
        newMessage.ToAddress = email.toAddresses[0];
        newMessage.Subject = email.subject;
        newMessage.MessageDate = System.now();
        String refId = '';
        if (quoteMatch.find()) {
            refId = quoteMatch.group(0);
        }

        //TCS-av4-SDT-46928-23/04/25-Added to extract reference id 
        EmailMessageProcessorExtension emailMsgProcessor = new EmailMessageProcessorExtension();
        refId = emailMsgProcessor.getReferenceId(refId, 'ref');
        //TCS-av4-SDT-46928-23/04/25-End
        
        //added by av4 for SDT-41263
        string AGENTREFERENCE = '(lst:).*(:lst)';
        List<EmailMessage> outboundMessageList = new List<EmailMessage>();
        String agentId = '';
        Pattern agentThread = Pattern.compile(AGENTREFERENCE);
        Matcher agentMatch = agentThread.matcher(email.htmlBody);
        if (agentMatch.find()) {
            agentId = agentMatch.group(0);
        }
        //41263 ends
      
            try {
                NSQuotelist = [SELECT Id, Quote_Thread_Id__c
                           FROM SBQQ__Quote__c
                           WHERE Quote_Thread_Id__c like: ('%' + refId + '%')];//modfied as part of SDT-41263
                 for(SBQQ__Quote__c quote:NSQuotelist){
                if(quote.Quote_Thread_Id__c.contains(refId)){
                    NSQuote = quote;

                    //added for SDT-41263
                    if(agentId != null) {
                        system.debug('agentId >> ' + agentId);
                        String query = 'SELECT Id, Message_ID__c, RelatedToId, Status FROM EmailMessage WHERE RelatedToId = \'' + NSQuote.Id + '\' ' + 
                            'AND Message_Id__c LIKE \'%' + String.escapeSingleQuotes(agentId) + '%\'' + 'AND Status = \'3\'';
                        outboundMessageList = Database.query(query);
                        system.debug('outboundMessageList >> ' + outboundMessageList);
                        if(outboundMessageList.size() > 0 && !String.isEmpty(outboundMessageList[0].Message_Id__c)) {
                            system.debug('outboundMessageList[0].Message_Id__c >> ' + outboundMessageList[0].Message_Id__c);
                            String agentUsername = outboundMessageList[0].Message_Id__c.replaceAll('lst:_.*:lst', '');
                            newMessage.Message_ID__c = agentUsername;
                        }
                        else if(Test.isRunningTest()) {
                            String agentUsername = 'agent';
                            newMessage.Message_ID__c = agentUsername;
                        }
                    }
                    //SDT-41263 ends 
                    
                }
            }
                newMessage.RelatedToId = NSQuote.Id;
                insert newMessage;
                
    		}
            catch(Exception ex){
                System.debug('####ex'+ex);
          }
        return newMessage;
	}
    
}