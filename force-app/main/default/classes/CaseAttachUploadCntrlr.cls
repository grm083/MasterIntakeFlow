/*************************************************************
@Name: CaseAttachUploadCntrlr
@Author: Ezra Soleymani
@CreateDate: 22/05/2019
@Description: @AuraEnabled class for CaseAttachUploadComp
@UsedBy: CaseAttachUploadComp
**************************************************************/
public without sharing class CaseAttachUploadCntrlr {

  public static final String METHOD_NAME_INTEGRATE_TO_ACORN = 'CaseAttachUploadCntrlr.integrateDocsToAcorn()';
  public static final String GENERIC_EXCEPTION = 'Generic Exception';

  @AuraEnabled
  public static list<ContentDocument> getPDF(String recordId) 
  {
    System.debug('record id '+recordId);
    Case c = [select Id , Tracking_Number__c from case where id =: recordId];
    String urlInstance = String.valueof(System.URL.getSalesforceBaseURL().gethost());
    string DocList = IntegrationHandlerUtil.getCaseDocList(Constant_Util.Get_Ticket_Documents,c);    
    Results rsltDocList = new Results();
    list<ContentDocument> contentDocList = new list<ContentDocument>();
    list<ContentVersion> contentVerList = new list<ContentVersion>();
    rsltDocList = parse(DocList);
    Set <String> fileNames = new Set<String>();
    if(rsltDocList.Data != null){
      
      for(CaseAttachUploadCntrlr.Data docListData : rsltDocList.Data){
          string Doc = IntegrationHandlerUtil.getCaseDoc(Constant_Util.Download_Ticket_Document,c,String.valueOf(docListData.IssueFileId));    
          ResultsDoc rsltDoc = new ResultsDoc();
          rsltDoc = parseDoc(Doc);

          if(rsltDoc != null && rsltDoc.Data != null)
          {
            string filename = rsltDoc.Data.FileName.SubStringBefore('.');
            filename = filename.SubStringBefore('_');
            filename = filename.trim();
            fileNames.add(filename);
            string filenameExt = filename+'.'+docListData.FileExtention;
            ContentVersion contentVersion_1 = new ContentVersion(
                Title = filename,
                PathOnClient = filenameExt ,
                VersionData = EncodingUtil.base64Decode(rsltDoc.Data.File),
                FirstPublishLocationId	= recordId,
                IsMajorVersion = false, /*so that can be updated later on*/
                Description = docListData.IssueFileTypeName,
                Is_Integrated_To_Acorn__c = True //added as part of SDT 33127
            );
            contentVerList.add(contentVersion_1);
          }
      }

        System.debug('fileNames '+fileNames);
        list<ContentDocument> contentListDelete = [SELECT Id FROM ContentDocument WHERE Title =: fileNames];
        System.debug('contentListDelete '+contentListDelete);
        if(contentListDelete.size()>0)
            delete contentListDelete;
    }
      if(contentVerList.size() > 0){
          set<Id> contVerIDs = new Set<Id>();
          insert contentVerList;
      
          // for(ContentVersion contVerData:contentVerList){
          //     contVerIDs.add(contVerData.Id);
          // }
      }
          set<Id> contDocId = new set<Id>();
          set<Id> relatedIds = new set<Id>();
          relatedIds.add(recordId);
          list<EmailMessage> EmailMessageList = [SELECT Id from EmailMessage where ParentId =: recordId];
          if( EmailMessageList.size() >0){  
            for(EmailMessage EmailMessageData : EmailMessageList)
            {
              relatedIds.add(EmailMessageData.Id);
            }
          }
          list<ContentDocumentLink> contentDocLinkList =  [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: relatedIds ];
          if( contentDocLinkList.size() >0){  
            for(ContentDocumentLink contDocLinkData : contentDocLinkList)
            {
              contDocId.add(contDocLinkData.ContentDocumentId);
            }
          }
          contentDocList = [SELECT Id,Title,FileType,Description FROM ContentDocument WHERE Id In: contDocId];//LatestPublishedVersionId in: contVerIDs];
          System.debug('contentDocList' +  contentDocList);
          if(contentDocList.Size() > 0){
            return contentDocList;
          }
        // Error
      return null;
    } 

    //modified on 23/01/2024 by av4 as part of SDT 33127
    @AuraEnabled
    public static list<ContentDocument> uploadDoc(String ConDocId ,String TicketFileTypeName,String fileName ,String recordId) 
    {
        //System.debug('ConDocId '+ ConDocId);
        System.debug('TicketFileTypeName '+ TicketFileTypeName); 
        RESTHelper.AcornResponse jsonResp;        
        String InterfaceName =Constant_Util.Upload_Ticket_Document;
        List<case> caseList = [select Id,Tracking_Number__c from case where Id =: recordId];
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = Database.query('select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, ' + 
                                      'Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt ' +
                                      'where DeveloperName =:InterfaceName limit 1');

        String Endpoint = urlMDList[0].End_Point__c;
        list<ContentDocument> contentDocList = new list<ContentDocument>();
        ContentVersion cv =[select id,ContentDocumentId,versiondata,FileExtension from Contentversion where ContentDocumentId =:ConDocId ];
        
        //cv.Title = fileName;
        //cv.Description = TicketFileTypeName;
        //cv.File_Type__c = TicketFileTypeName;
        fileName = fileName.SubStringBefore('.');
        Blob FileBody = cv.VersionData;
        String base64data = EncodingUtil.base64Encode(cv.VersionData);
        JSONGenerator gen = JSON.createGenerator(true);
        // Write data to the JSON string.
        gen.writeStartObject();
        gen.writeObjectField('File', base64data);
        gen.writeObjectField('ticketFileTypeName', TicketFileTypeName);
        gen.writeObjectField('FileName', fileName+'.'+cv.FileExtension);
        gen.writeEndObject();
        String genString = gen.getAsString();
        System.debug(genString);

        //added as part of SDT 33127 & 33441
        ContentVersion c = new ContentVersion();
        if(cv != null){
            c.Id = cv.Id;
            c.title = fileName;
            c.Description = TicketFileTypeName;
        }
        
        String Resp =  IntegrationHandlerUtil.uploadCaseDoc(Constant_Util.Upload_Ticket_Document,caseList[0],genString);
        jsonResp = (RESTHelper.AcornResponse) JSON.deserialize(Resp, RESTHelper.AcornResponse.Class);
        
        if(jsonResp != null){
          if(jsonResp.Data != null ){
            if(jsonResp.Data.IsSuccess){
                // Modified for SDT-33441 Start
                if(c != null){
                    //added as part of sdt 33127
                    c.Is_Integrated_To_Acorn__c = true;
                }
                // Modified for SDT-33441 End
                contentDocList = [Select Id,Title,FileType,FileExtension,Description FROM ContentDocument WHERE Id =: ConDocId Limit 1]; // Modified for SDT-33441
                contentDocList[0].title = fileName;
                if(!contentDocList.isEmpty()){
                    update contentDocList;
                }
            }
              
          }
            /*else if(jsonResp.problem != null && jsonResp.problem.errors != null && jsonResp.problem.errors[0].code == '400'
                  && jsonResp.problem.errors[0].message == 'Tracking Number is not valid.'){
                      contentDocList = [Select Id FROM ContentDocument WHERE Id =: ConDocId];
                      if(!contentDocList.isEmpty()){
                          delete contentDocList;
                      }
                	  return null;              
          }*/
        }
        
        //added as part of sdt 33127 & 33441
        if(c != null){
            update c;
        }
         
        //commented
        //delete contentDocList;
        
        //added as part of SDT 33127
        set<Id> contDocIds = new set<Id>();
        list<ContentDocumentLink> contentDocLinkList =  [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
          if( contentDocLinkList.size() >0){  
            for(ContentDocumentLink contDocLinkData : contentDocLinkList)
            {
              contDocIds.add(contDocLinkData.ContentDocumentId);
            }
          }
          List<ContentDocument> contentDocListNew = [SELECT Id,Title,FileType,Description FROM ContentDocument WHERE Id In: contDocIds];
        return contentDocListNew;
        
        //return null;
    }

    @AuraEnabled
    public static List <String> getFileTypePickList() 
    {
        List<String> allOpts = new list < String > ();
        list<Schema.PicklistEntry> values = ContentVersion.File_Type__c.getDescribe().getPickListValues();
        for(Schema.PicklistEntry a: values) 
        {
          allOpts.add(a.getValue());
        }
        allOpts.sort();
        return allOpts;
    }

    /** 
     * @added by av4 as part of SDT 33127
     * @description Method to integrate the docs to acorn once the traking number is generated
    */
    @AuraEnabled
    public static void integrateDocsToAcorn(String caseId) {
        Case cs = [Select Id, Tracking_Number__c FROM Case where Id=: caseId];
        
        //checking if the case has tracking number
        if(cs.Tracking_Number__c != null && !String.isEmpty(cs.Tracking_Number__c)) {
            List<ContentDocumentLink> conDocLinkList = [select Id, ContentDocumentId, ContentDocument.Title from contentdocumentlink where LinkedEntityId =: caseId];
            
            Set<Id> conDocIds = new Set<Id>();
            for(ContentDocumentLink currentLink : conDocLinkList) {
                conDocIds.add(currentLink.ContentDocumentId);
            }
                List<ContentVersion> conVersionList = [select Id, title, FileExtension, CreatedDate, ContentDocumentId, ContentDocument.Title, 
                                                       contentDocument.FileType, VersionData, ContentDocument.Description, Description, IsLatest, Is_Integrated_To_Acorn__c
                                                       from contentversion where ContentDocumentId IN: conDocIds and Is_Integrated_To_Acorn__c =: False
                                                      and IsLatest =: True];
            
            
            RESTHelper.AcornResponse jsonResp;        
            String interfaceName =Constant_Util.Upload_Ticket_Document;
            
            List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
            urlMDList = Database.query('select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, ' + 
                                       'Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt ' +
                                       'where DeveloperName =:interfaceName limit 1');
            
            //to store updated cv records
            list<ContentVersion> updatedCVList = new list<ContentVersion>();
        
        //to store exception records
        List<ExceptionLog__c> exceptionLogList = new List<ExceptionLog__c>();
        for(ContentVersion currentVersion : conVersionList) {
            try {
                Blob FileBody = currentVersion.VersionData;
                String base64data = EncodingUtil.base64Encode(currentVersion.VersionData);
                JSONGenerator gen = JSON.createGenerator(true);
                // Write data to the JSON string.
                gen.writeStartObject();
                gen.writeObjectField('File', base64data);
                gen.writeObjectField('ticketFileTypeName', currentVersion.Description);
                gen.writeObjectField('FileName', currentVersion.Title+'.'+currentVersion.FileExtension);
                gen.writeEndObject();
                String genString = gen.getAsString();                
                
                String resp =  IntegrationHandlerUtil.uploadCaseDoc(interfaceName,cs,genString);
                jsonResp = (RESTHelper.AcornResponse) JSON.deserialize(resp, RESTHelper.AcornResponse.Class);
                
                //updating the contentversion record
                ContentVersion cv = new ContentVersion();
                cv.Id = currentVersion.Id;
                cv.Is_Integrated_To_Acorn__c = true;
                updatedCVList.add(cv);
                
            }
            catch(Exception ex) {
              ExceptionLog__c exLog = TwoWayService.logExceptions(ex.getMessage(), METHOD_NAME_INTEGRATE_TO_ACORN, GENERIC_EXCEPTION);
              exceptionLogList.add(exLog);
            }
            
        }
        if(!updatedCVList.isEmpty()) {
            update updatedCVList;
        }
        if(!exceptionLogList.isEmpty()) {
          insert exceptionLogList;
        }
        }
    }
    
    /** 
     * @added by av4 as part of SDT 33127
     * @description This method determines whether the 'Sync To Acorn' button is visible or not
    */
    @auraEnabled
    public static Boolean showSyncButton(String caseId) {
        Case cs = [Select Id, Tracking_Number__c from Case where Id =: caseId];
        //checking if tracking number is null
        if(cs.Tracking_Number__c == null || String.isBlank(cs.Tracking_Number__c)) {
            return true;
        }
        //checking if there are any attachments that are yet to be integrated
        else {
            List<ContentDocumentLink> conDocLinkList = [select Id, ContentDocumentId from contentdocumentlink where LinkedEntityId =: caseId];
            
            Set<Id> conDocIds = new Set<Id>();
            for(ContentDocumentLink currentLink : conDocLinkList) {
                conDocIds.add(currentLink.ContentDocumentId);
            }
            List<ContentVersion> conVersionList = [select Id, ContentDocumentId, IsLatest, Is_Integrated_To_Acorn__c
                                                   from contentversion where ContentDocumentId IN: conDocIds and Is_Integrated_To_Acorn__c =: false
                                                  and IsLatest =: True];
            if(conVersionList.isEmpty()) {
                return true;
            }
            return false;
        }
    }

    public Data Data;
    public Object Problem;

	  public inherited sharing  class Results {
      public list<Data> Data {get;set;}
      public Problem Problem {get;set;}
      public Integer PageIndex {get;set;}
      public Integer PageSize {get;set;}
      public Integer Count {get;set;}
	}
    public inherited sharing class ResultsDoc {
      public Data Data {get;set;}
      public Problem Problem {get;set;}
	}
    public inherited sharing class Data {
		  public String File;
		  public String FileName;
      public Integer IssueId;
      public Integer IssueFileId;
      public String FileTitle;
      public String FileDescription;
      public String FileExtention;
      public String IssueFileTypeName;
      public String IssueFileStatusName;
      public String UserLogonName;
	  }
    
    public inherited sharing class Errors {
      public String Code;
      public String Message;
    }
    public inherited sharing class Problem {
      public String Title;
      public Integer Status;
      public List<Errors> Errors;
    }
    
    public static Results parse(String json) {
		return (Results) System.JSON.deserialize(json, CaseAttachUploadCntrlr.Results.class);
	  }
    public static ResultsDoc parseDoc(String json) {
		return (ResultsDoc) System.JSON.deserialize(json, CaseAttachUploadCntrlr.ResultsDoc.class);
	  }
}