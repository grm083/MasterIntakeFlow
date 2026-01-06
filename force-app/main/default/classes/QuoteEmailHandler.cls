global class QuoteEmailHandler implements Messaging.InboundEmailHandler{
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailREsult();
        
        List<SBQQ__Quote__c> NSQuotelist = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c NSQuote = new SBQQ__Quote__c();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        List<Id> quoteListId = new List<Id>();
        Pattern quoteThread = Pattern.compile(Constant_Util.QUOTEREFERENCE);
        Matcher quoteMatch = quoteThread.matcher(email.htmlBody);
        
        String refId = '';
        if (quoteMatch.find()) {
            refId = quoteMatch.group(0);
        }
        
        //TCS-av4-SDT-46928-23/04/25-Added to extract reference id 
        EmailMessageProcessorExtension emailMsgProcessor = new EmailMessageProcessorExtension();
        refId = emailMsgProcessor.getReferenceId(refId, 'ref');
        //TCS-av4-SDT-46928-23/04/25-End

	// get Org wide list
        List<OrgWideEmailAddress> oweaList = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName =: Constant_Util.EMAIL_TO_QUOTE OR DisplayName =: Constant_Util.PS_EMAIL_TO_QUOTE OR DisplayName =: Constant_Util.VRM_EMAIL_TO_QUOTE OR DisplayName =: Constant_Util.CANADA_VRM_EMAIL_TO_QUOTE  ORDER BY DisplayName ASC];
	    
        if (refId != '') {
            //Changes for SDT-26208
            NSQuotelist = [SELECT Id, Quote_Thread_Id__c, SBQQ__ShippingCountry__c
                           FROM SBQQ__Quote__c
                           WHERE Quote_Thread_Id__c like: ('%' + refId + '%')];//modfied as part of SDT-41263
        
            //SDT-24032- Make NSQuote a list, iterate on it and check for Exact Match(Case sensitive).
            for(SBQQ__Quote__c quote:NSQuotelist){
                if(quote.Quote_Thread_Id__c.contains(refId)){
                    NSQuote = quote;
                }
            }
            if(NSQuote!= null){
                EmailMessage newMessage = EmailMessageCreation.attachEmailIfRefExists(email);    
                quoteList.add(NSQuote);
                quoteListId.add(NSQuote.Id);
                setEmailAttachments(newMessage.Id,email);//SDT-23994       
                
                //Changes for SDT-26208
                if(oweaList != null && !oweaList.isEmpty() && oweaList[3] !=null && email.toAddresses[0] != oweaList[3].Address)
                {
                    //Changes related to SDT-37849s
					newMessage.ToAddress = String.join(email.toAddresses, '; ');
                    newMessage.CcAddress = (email.ccAddresses !=null && !email.ccAddresses.isEmpty())? String.join(email.ccAddresses, '; ') : null ;
                    QuoteTriggerHelper.createGenesysForQuote(quoteList,quoteListId,Constant_Util.STATUS_NEW,newMessage);
                }
            }
            else {
                forwardEmail(email, oweaList);
            }
        } else {
            forwardEmail(email, oweaList);
        }
        return result;
    }
    //Forwarding email to Email-to-Case address.
    private void forwardEmail(Messaging.InboundEmail email, List<OrgWideEmailAddress> oweaList){
        
        String emailDate= '';
        String ccAddress= '';
        String emailChain = 'From:{0} \n To:{1} \n CC:{2} \n Sent:{3} \n Subject:{4} \n \n{5}';
        String emailChainHTML = 'From:{0} <br/> To:{1} <br/> CC:{2} <br/>Sent:{3} <br/> Subject:{4}<br/><br/>{5} <br/>';
        //Changes for SDT-26208
       
        List<QuoteGenesysEmailToQuote__mdt>metadata = [Select id from QuoteGenesysEmailToQuote__mdt];
        
        String concat = email.subject;   
        String orgWideAdd;
        String[] toAddresses = new String[] {};
            
            if(email.toAddresses[0] ==  QuoteGenesysEmailToQuote__mdt.getInstance(Constant_Util.EmailToQuote).ToAddress__c){
                //concat = email.subject+'##$$'+email.fromAddress;
                toAddresses.add(QuoteGenesysEmailToQuote__mdt.getInstance(Constant_Util.EmailToQuote).FwdAddress__c);
                orgWideAdd= oweaList[1].Id;
            }    
        else if(email.toAddresses[0] == QuoteGenesysEmailToQuote__mdt.getInstance(Constant_Util.PSEmailToQuote).ToAddress__c){          
            concat = email.subject+'##$$'+email.fromAddress;    
            toAddresses.add(QuoteGenesysEmailToQuote__mdt.getInstance(Constant_Util.PSEmailToQuote).FwdAddress__c);
            orgWideAdd= oweaList[2].Id;
        }   
        else if(email.toAddresses[0] == QuoteGenesysEmailToQuote__mdt.getInstance(Constant_Util.VRMEmailToQuote).ToAddress__c){          
            //concat = email.subject+'##$$'+email.fromAddress;  
            toAddresses.add(QuoteGenesysEmailToQuote__mdt.getInstance(Constant_Util.VRMEmailToQuote).FwdAddress__c);
            orgWideAdd= oweaList[0].Id;
        }//Changes for SDT-26208
        else if(email.toAddresses[0] == QuoteGenesysEmailToQuote__mdt.getInstance(Constant_Util.CANADAVRMEMAILTO_QUOTE).ToAddress__c){          
            //concat = email.subject+'##$$'+email.fromAddress;  
            toAddresses.add(QuoteGenesysEmailToQuote__mdt.getInstance(Constant_Util.CANADAVRMEMAILTO_QUOTE).FwdAddress__c);
            orgWideAdd= oweaList[3].Id;
        }  
        
        System.debug('@@@toAddresses'+toAddresses);
        
        
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        mail.setOrgWideEmailAddressId(orgWideAdd);     
        mail.setToAddresses(toAddresses);      
        mail.setSubject(concat);
        //mail.setInReplyTo(email.fromAddress); 
        if(email.headers!= null){
        Messaging.InboundEmail.header[] dateTimeValue = email.headers;  
        for(Messaging.InboundEmail.header dtValue : dateTimeValue){
            if(!String.isblank(dtValue.Name) && dtValue.Name.equalsIgnoreCase('Date')){
                emailDate = dtValue.Value.replace('+0000','');
            	}
        	}
        }
        if(email.ccAddresses != null){
            ccAddress= String.join(email.ccAddresses,',');
        }
        emailChain = String.format(emailChain,new List<Object>{email.fromAddress,email.toAddresses,ccAddress,emailDate,email.subject,email.plainTextBody} );
        emailChainHTML= String.format(emailChainHTML,new List<Object>{email.fromAddress,email.toAddresses,ccAddress,emailDate,email.subject,email.plainTextBody} );
        mail.setPlainTextBody(emailChain);     
        mail.setHtmlBody(emailChainHTML);         
        
        
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        setFwdEmailAttachments(emailAttachments,email);
        
        mail.setFileAttachments(emailAttachments);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
    /* 
    * SDT-23994
     *Developer : Shilpa Bhatia
     *Description : This method is created to attach attachments in Email with no reference Id in body.    
    */
    public void setFwdEmailAttachments(List<Messaging.EmailFileAttachment>emailAttachments,Messaging.Inboundemail email){
        
         if(email.textAttachments != null)
        {

         // Save attachments, if any
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                
                attachment.filename = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                emailAttachments.add(attachment);
                
            }
        } 
        if(email.binaryAttachments != null)
        {
            
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                
                attachment.filename = bAttachment.fileName;
                attachment.body = bAttachment.body;            
                emailAttachments.add(attachment);               
            }
              
        
    }
    }
    
   /* 
    * SDT-23994
     *Developer : Shilpa Bhatia
     *Description : This method is created to attach attachments in Email having reference Id in body.    
    */
    public void setEmailAttachments(String newMessageId,Messaging.Inboundemail email){
        
        List<Attachment> lstAttach= new List<Attachment>();
        
        if(email.textAttachments != null)
        {
            // Save attachments, if any
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                Attachment attachment = new Attachment();
                
                attachment.Name = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                attachment.ParentId = newMessageId;
                lstAttach.add(attachment);
                
            }
        }
        if(email.binaryAttachments != null)
        {
            try{
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                Attachment attachment = new Attachment();
                
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = newMessageId;
                lstAttach.add(attachment);
               
            }
        
            insert lstAttach;
        }
        catch(Exception ex){
            //Handle Exception
        }
		}
    }
}