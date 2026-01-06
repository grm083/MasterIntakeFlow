/*************************************************************
@Name: SendErrorNotificationOnJobFailure
@Author: Ganesh ram S
@CreateDate: 07/02/2019
**************************************************************/
public without sharing class SendErrorNotificationOnJobFailure {

    private Static final String TEST_EMAIL = 'Test@wm.com';
    private Static final String ATTACHMENT = 'Batch Errors.csv';
    private static final String FILEHEADERS = 'Id, Name, Error \n';
    private static final String BODYMESSAGE1 = 'Your batch job has finished with errors. ';
    private static final String BODYMESSAGE2 = 'Please find the error list attached.';
    private static final String SUBJECTMESSAGE = ' - Apex Batch Error List';
    
/**@MethodName sendMail 
 * Method to send email notification on Apex Batch failure
 **/
    public static void sendMail(Map<Id, String> errorMap ,Map<Id, SObject> idToSObjectMap,AsyncApexJob jobStatus){
    
        String jobName = jobStatus.ApexClass.Name ;
        String errorInfo = FILEHEADERS ;
         String body = BODYMESSAGE1 + BODYMESSAGE2 ;
            // Creating the CSV file
            
            String subject = jobName + SUBJECTMESSAGE;
            String emailRecipients = System.Label.Job_Error_Notification_Email ;
            String emailRecipientsInCC = System.Label.JobErrorNotification_CC ;
            for(Id id  : errorMap.keySet()){
                string err = errorMap.get(id);
                User acct = (User) idToSObjectMap.get(id);
                string recordString = '"'+id+'","'+acct.Name+'","'+err+'"\n';
                errorInfo = errorInfo +recordString;
            } 
 
            // Define the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
 
            // Create the email attachment    
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(ATTACHMENT);
            efa.setBody(Blob.valueOf(errorInfo));
 
            // Sets the paramaters of the email
            email.setSubject( subject );
            email.setToAddresses( new String[] {emailRecipients} );
            email.setCcAddresses(new String[] {emailRecipientsInCC});
            if(Test.isRunningTest())
            {
                email.setToAddresses( new String[] {TEST_EMAIL} );
            }
            email.setPlainTextBody( body );
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
 
            // Sends the email
            Messaging.SendEmailResult [] sendEmail = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
            }
    
    }