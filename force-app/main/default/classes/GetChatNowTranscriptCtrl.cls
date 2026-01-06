/**
* @date 25/05/2023
* @description : Get Chat Now Transcript
**/

public class GetChatNowTranscriptCtrl {
    
    public List<ResponseWrapper> wrapperResList {get; set;}
    public String currentRecordId {get;set;}
    /*
@AuraEnabled
public static List<String> getPDFPrint(String caseId){
List<String> pageStrings =  new List<String>();
PageReference pdfPage = new PageReference('/apex/chatNowTranscriptVF?id='+caseId);
Blob pdfBlob = pdfPage.getContent();
String downloadURL = EncodingUtil.base64Encode(pdfBlob);
pageStrings.add(downloadURL);
pageStrings.add(pdfPage.getURL());

pdfPage.setRedirect(True);

return pageStrings; 
}

public void chatNowTranscript()
{
currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
wrapperResList = new List<ResponseWrapper>();
wrapperResList = getChatTranscript(currentRecordId);
}*/
    
    @AuraEnabled(cacheable=true)
    public static List<ResponseWrapper> getChatTranscript(String caseId, String transactionId) {
        system.debug('recordId : ' + caseId);
        String taskInteractionId;
        //Case caseObj = [Select Id,Last_Customer_Interaction_ID__c from Case WHERE Id =: caseId];
        
        
            // Success
        // caseInteractionId = '000G3aJ512DK7B6E'; //'000G3aJ512DK7BJE'; //'000G3aJ512DKUNVU'; // '000FTaJ19110598P';//'000FXaJ4JSC9HARQ'; 
        //caseInteractionId = '000G3aJ512DK7BJE';
        //caseInteractionId = '000G3aJ512DKUNVU';
        // For Error
        //  caseInteractionId = '000FTaJ19110598P';
        //String caseInteractionId = caseObj.Last_Customer_Interaction_ID__c;
        if(transactionId != ''){
         taskInteractionId = transactionId;
        System.debug('taskInteractionId^^^ ' +taskInteractionId);
        }
        
        //system.debug('caseInteractionId : ' + caseInteractionId);
        // Query Metadata for Request URL
        List<ResponseWrapper> wrapperList = new List<ResponseWrapper>();
        try{
            if(String.isNotEmpty(taskInteractionId)){    
                Integration_Request_URLs__mdt urlMD = [Select DeveloperName, MasterLabel, Client_Key__c, Client_Token__c, 
                                                       Timeout__c, Content_Type__c, End_Point__c, Method__c FROM Integration_Request_URLs__mdt 
                                                       WHERE DeveloperName = 'Get_Chat_Transcript'];												
                String endpoint = urlMD.End_Point__c;
                //endpoint = 'https://qa.sf.wmsbs.wm.com/salesforceintegration/api/v1.0/Chatnow/Connections/000G3aJ512DK7BJE/Transcript';
                //Replace the {InteractionId} in endpoint with the case Last_Customer_Interaction_ID__c
                endpoint = endpoint.replace('{InteractionId}', taskInteractionId);
                
                //Create New HTTP request based on paramters of metadata record
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                
                //Set request headers
                req.setEndpoint(endpoint);
                req.setMethod('GET');
                req.setHeader('Content-Type', urlMD.Content_Type__c);
                req.setHeader('X-PARTNER-KEY', urlMD.Client_Key__c);
                req.setHeader('X-USERID', '1');
                req.setHeader('Authorization', urlMD.Client_Token__c);
                req.setHeader('Accept-Encoding', 'gzip,compress'); 
                req.setTimeout(urlMD.Timeout__c.intValue());
                
                res = h.send(req);
                // System.HttpResponse[Status=Not Found, StatusCode=404]
                String resStatus = res.getStatus();
                Integer resStatusCode = res.getStatusCode();
                System.debug('resStatus : ' + resStatus + 'resStatusCode : ' + resStatusCode);
                String jsonRes = res.getBody();
                jsonRes = jsonRes.replace('#', '');
                System.debug('jsonRes : ' + jsonRes);
                ChatNowTranscriptResponse obj = ChatNowTranscriptResponse.parse(jsonRes);
                List<String> userIdList = new List<String>();
                
                if(obj.Data!=null){
                    system.debug('StartAt  : ' + obj.Data.StartAt);
                    // system.debug('SessionId  : ' + obj.Data.SessionId);
                    ChatNowTranscriptResponse.Events events = new ChatNowTranscriptResponse.Events();
                    List<ChatNowTranscriptResponse.Events> eventList = new List<ChatNowTranscriptResponse.Events>();
                    Map<String,String> mapUserIdVsName = new Map<String,String>();
                    for(ChatNowTranscriptResponse.Events event : obj.Data.Events){
                        if(event.UserId!=null && event.NewParty!=null && event.NewParty.UserInfo !=null && event.NewParty.UserInfo.UserNick !=null){
                            mapUserIdVsName.put(event.UserId, event.NewParty.UserInfo.UserNick);
                        }
                        if(event.UserId!=null && event.Message !=null && event.Message.Text!=null && event.Message.Text.value !=null){
                            ResponseWrapper wrap = new ResponseWrapper();
                            wrap.chatDateTime = addSecondInDateTime(obj.Data.StartAt, event.TimeShift);
                            wrap.UserId = mapUserIdVsName.get(event.UserId);
                            wrap.messageText = event.Message.Text.value;
                            wrapperList.add(wrap);
                        }
                    }
                }else if(obj.Data ==null && obj.Problem!=null){
                    Integer[] listStatusCodes = new Integer[] { 401, 403, 404, 405, 503 };
                    if(obj.Problem.title == 'Bad Request' && obj.Problem.status == 400){
                        ResponseWrapper wrap = new ResponseWrapper();
                        wrap.errorMessage = 'Please allow up to one hour from the end of the chat to access the transcript.';
                        wrapperList.add(wrap);
                    }else if((obj.Problem.title == 'Internal Server Error' && obj.Problem.status == 500) || listStatusCodes.contains(obj.Problem.status)){
                        ResponseWrapper wrap = new ResponseWrapper();
                        wrap.errorMessage = 'Please try again later.';
                        wrapperList.add(wrap);
                    }else{
                        ResponseWrapper wrap = new ResponseWrapper();
                        wrap.errorMessage = 'Please try again later.';
                        wrapperList.add(wrap);
                    }
                }else {
                    ResponseWrapper wrap = new ResponseWrapper();
                    wrap.errorMessage = 'Please allow up to one hour from the end of the chat to access the transcript.';
                    wrapperList.add(wrap);
                }
            }else{
                ResponseWrapper wrap = new ResponseWrapper();
                wrap.errorMessage = 'Interaction Id is empty.';
                wrapperList.add(wrap);
            }
        }
        catch(Exception ex){
            ResponseWrapper wrap = new ResponseWrapper();
            wrap.errorMessage = 'Please try again later.';
            wrapperList.add(wrap);
            system.debug('ex : ' +ex.getMessage());
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
        //system.debug('wrapperList : ' + wrapperList);
        return wrapperList;
    }
     @AuraEnabled
    public static List<taskWrapper> fetchTaskDetail(String caseId) {
        List<taskWrapper> tsWrapperList = new List<taskWrapper>();
        
        List<Task> taskList = new List<Task>();
        String IntId;
        Datetime CrDate;
        String formattedDateTime;
        ////////////////
        List<Case> CaseList = new List<Case>();
        List<task> finalTaskList = new List<task>();
        if(String.isNotEmpty(caseId)){   
            CaseList = [select id,origin from Case where Id =: caseId];
        }
        
        if(CaseList != null && !CaseList.isEmpty()){
            if(CaseList[0].origin != '' && CaseList[0].origin == 'Chat Now'){
                taskList = [Select id,CreatedDate,Interaction_ID__c,Description__c,Subject from task where whatId =:caseId and Subject IN ('Inbound Customer Interaction','Self-Service','Customer Call Back Request') and (Interaction_ID__c != '' or Description__c != '') order by CreatedDate desc];
                if(taskList != null && !taskList.isEmpty()){
                    for(Task ts: taskList){
            
            if((ts.Subject == 'Inbound Customer Interaction' || ts.Subject == 'Self-Service') && String.isNotBlank(ts.Interaction_Id__c)){
                            
              IntId = ts.Interaction_Id__c;
                            DateTime dt =Datetime.valueOf(ts.CreatedDate);
                            
                          formattedDateTime = dt.format('yyyy-MM-dd hh:mm a');
                            tsWrapperList.add(new taskwrapper(formattedDateTime,IntId));
            }
            else if(ts.Subject == 'Customer Call Back Request' && String.isNotBlank(ts.Description__c)){
              IntId = ts.Description__c;
                            DateTime dt =Datetime.valueOf(ts.CreatedDate);
                          formattedDateTime = dt.format('yyyy-MM-dd hh:mm a');
                            tsWrapperList.add(new taskwrapper(formattedDateTime,IntId));
            }
                       
                     }
                }
            }
            if(CaseList[0].origin != '' && CaseList[0].origin != 'Chat Now'){
                taskList = [Select id,CreatedDate,Interaction_ID__c,Description from task where whatId =:caseId and Subject IN ('Inbound Customer Interaction','Self-Service') and Interaction_ID__c != '' order by CreatedDate desc];
                for(Task ts : taskList){
                    if((ts.Description).containsIgnoreCase('Chat')){
                        finalTaskList.add(ts);
                    }
                   
                    System.debug('finalTaskList^^^^ ' +finalTaskList);
                }
                
                if(finalTaskList != null && !finalTaskList.isEmpty()){
                    for(Task ts: finalTaskList){
                        System.debug('here3^^^^ ' );
                        DateTime dt =Datetime.valueOf(ts.CreatedDate);
                        formattedDateTime = dt.format('yyyy-MM-dd hh:mm a');
                        
                        tsWrapperList.add(new taskwrapper(formattedDateTime,ts.Interaction_Id__c));
                        
                    }
                }
            }
        }
       
        
        System.debug('tsWrapperList^^ ' +tsWrapperList);
        return tsWrapperList;
        
    }
     public class taskWrapper{
        @AuraEnabled public string CreatedDate{get;set;}
        @AuraEnabled public string InteractionID{get;set;}
        
        public taskwrapper( string CreatedDate,string InteractionID){
            this.CreatedDate = CreatedDate;
            this.InteractionID = InteractionID;
        }
    }
    
    public static string addSecondInDateTime(String startDateTime, String seconds){
        String changeDateFormat ='';
        if(String.isNotBlank(startDateTime) && String.isNotBlank(seconds)){
            //String StringTime = '5/7/2023 3:20:29 PM';
            List<String> DateAndTimeList = startDateTime.split(' ');
            List<String> dayList = DateAndTimeList[0].split('/');
            String timeConvert = formatTime(DateAndTimeList[1]+' '+DateAndTimeList[2]);
            List<string> timeList = timeConvert.split(':');
            // System.debug('DateTime is timeList: '+timeList);
            DateTime dtGMT = DateTime.newInstanceGmt(Integer.valueOf(dayList[2]), Integer.valueOf(dayList[0]), Integer.valueOf(dayList[1]), Integer.valueOf(timeList[0]), Integer.valueOf(timeList[1]), Integer.valueOf(timeList[2]));
            // System.debug('DateTime is dtGMT: '+dtGMT);
            
            DateTime newDateTime = dtGMT.addSeconds(Integer.valueOf(seconds));
            // System.debug('newDateTime : '+ newDateTime);
            
            //SDT 31280
            //formatGMT() is changed to format()
            changeDateFormat = newDateTime.format('MM/dd/yyyy hh:mm:ss a');
            // System.debug('>>>>' + changeDateFormat);
            
            if(changeDateFormat.contains(' 12') && changeDateFormat.containsIgnoreCase('AM')){
                changeDateFormat = changeDateFormat.replace(' 12',' 00');    
            }
            // System.debug('>>>> changeDateFormat : ' + changeDateFormat);
        }
        return changeDateFormat;
    }
    
    public static String formatTime(String t) {
        String a = t.split(' ')[1];
        String hours = t.substringBefore(':');
        //system.debug('a : ' + a + 'hr : ' + hours); 
        if (a == 'AM' && hours == '12'){
            t = '00:' + t.substringAfter(':');
        }
        else if (a == 'PM' && hours != '12'){
            t = String.valueOf(Integer.valueOf(hours) + 12) + ':' + t.substringAfter(':');
        }
        //system.debug('return : ' + t.split(' ')[0]+':00');
        return t.split(' ')[0]+':00';
    }
    
    public class ResponseWrapper{
        @AuraEnabled
        public string userId {get; set;}
        @AuraEnabled
        public string messageText {get; set;}
        @AuraEnabled
        public string chatDateTime {get; set;}
        @AuraEnabled
        public string errorMessage {get; set;}
    }
    
}
