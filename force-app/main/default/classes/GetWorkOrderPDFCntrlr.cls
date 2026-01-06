/**
* @author Accenture
* @date 05/08/2019
* @description : Controller class for GetWorkOrderPDF lightning component
**/
public without sharing class GetWorkOrderPDFCntrlr {
    @AuraEnabled
    public static list<ContentDocument> getPDF(String recordId) 
    {
      System.debug('record id '+recordId);
      String urlInstance = String.valueof(System.URL.getSalesforceBaseURL().gethost());
      string Resp = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.DOWNLOAD_WORK_ORDER,recordId);    
      Results rsltData = new Results();
      list<ContentDocument> contentList = new list<ContentDocument>();
      rsltData = parse(Resp);
      if(rsltData.Data != null)
      {
          list<ContentDocument> contentListDelete = [SELECT Id FROM ContentDocument WHERE Title =: rsltData.Data.FileName];
            //System.debug('contentList '+contentListDelete);
            ContentVersion contentVersion_1 = new ContentVersion(
                Title = rsltData.Data.FileName,
                PathOnClient = rsltData.Data.FileName,
                VersionData = EncodingUtil.base64Decode(rsltData.Data.File),
                FirstPublishLocationId	= recordId,
                IsMajorVersion = false /*so that can be updated later on*/
            );

            if(contentVersion_1 != null){
              List<String> contentVersionIds = new List<String>();
              insert contentVersion_1;
              String cv= contentVersion_1.Id; 
              contentVersionIds.add(cv);
              contentList = [SELECT Id,Title,FileType FROM ContentDocument WHERE LatestPublishedVersionId in: contentVersionIds];
            }
          if(contentListDelete.size()>0){
              delete contentListDelete;
          }
            System.debug('contentList '+contentList);
            return contentList;
      }
        // Error
       return null;
      } 
    public Data Data;
    public Object Problem;

	  public class  Results {
      public Data Data {get;set;}
      public Problem Problem {get;set;}
	  }
    public class Data {
		  public String File;
		  public String FileName;
	  }
    
    public class Errors {
      public String Code;
      public String Message;
    }
    public class Problem {
      public String Title;
      public Integer Status;
      public List<Errors> Errors;
    }
    
    public static Results parse(String json) {
		  return (Results) System.JSON.deserialize(json, GetWorkOrderPDFCntrlr.Results.class);
	  }

}