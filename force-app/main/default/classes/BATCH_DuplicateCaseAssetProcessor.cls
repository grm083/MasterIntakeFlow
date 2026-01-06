/**
* @Name          BATCH_DuplicateCaseAssetProcessor
* @Author        Accenture
* @Date          28/01/2020
* @Description   BATCH class for the purpose of removing duplicate SBS_Case_Asset__c records
*/
public class BATCH_DuplicateCaseAssetProcessor implements Database.Batchable<sObject>,Database.Stateful {
    
    public List<String> duplicateCSVRowValues = new List<String>();
    public List<String> AllCSVRowValues = new List<String>();
	public final String queryString = 'SELECT Id,Name,Asset_Header__c, AssetId__c, CaseId__c, Asset_Service_Type__c,CreatedDate,CaseId__r.CaseNumber FROM SBS_Case_Asset__c WHERE CreatedDate > 2020-01-24T00:00:00Z AND CreatedDate < 2020-01-28T00:00:00Z order by Name,CreatedDate asc';
    public final String COLUMN_HEADER='CaseNumber, Id, Name, Asset Header, Asset Id, Case Id, Service Type,CreatedDate,Deletion Flag\n';
    public final String DUPLICATE_FOLDER_NAME = 'Duplicate Case Asset';
    public Map<String, List<SBS_Case_Asset__c>> myCAMap = new Map<String, List<SBS_Case_Asset__c>>();
    
    
    
    public Database.QueryLocator start(Database.BatchableContext currentScope){ 
        return Database.getQueryLocator(queryString);
    }
    
    
    public void execute(Database.BatchableContext currentScope, List<SBS_Case_Asset__c> myCAList){
        String rowStr,myCAKey;
        Boolean potentialDeleteFlag;
        List<SBS_Case_Asset__c> myNewCAList;
        try{
            for(SBS_Case_Asset__c myCA : myCAList){
                potentialDeleteFlag = false;
                myCAKey = String.valueOf(myCA.Asset_Header__c) + String.valueOf(myCA.AssetId__c) + String.valueOf(myCA.CaseId__c + String.valueOf(myCA.Asset_Service_Type__c));
                rowStr =  myCA.CaseId__r.CaseNumber + ',' + myCA.Id + ',' + myCA.Name + ',' + myCA.Asset_Header__c + ',' + myCA.AssetId__c + ','+ myCA.CaseId__c + ','+ myCA.Asset_Service_Type__c + ','+myCA.CreatedDate.format('M/d/yyyy h:mm:ss a z');
                if(myCAMap.containsKey(myCAKey)){
                    myCAMap.get(myCAKey).add(myCA);
                    duplicateCSVRowValues.add(rowStr);
                    potentialDeleteFlag = true;
                } 
                else {
                    myNewCAList = new List<SBS_Case_Asset__c>();
                    myNewCAList.add(myCA);
                    myCAMap.put(myCAKey, myNewCAList);
                }
                rowStr+=','+potentialDeleteFlag;
                AllCSVRowValues.add(rowStr);
            }
        }catch (Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), 'DUPLICATE CASE ASSET BATCH CLASS',LoggingLevel.ERROR);
        }
    }
    public void finish(Database.BatchableContext currentScope){
        List<Document> docList=new List<Document>();
        String documentName;
        String CSVFile;
        String csvColumnHeader = COLUMN_HEADER;
        List<Folder> folders = [SELECT Id, Name FROM Folder WHERE Name = :DUPLICATE_FOLDER_NAME];
        try{
            if((duplicateCSVRowValues!=null || !duplicateCSVRowValues.isEmpty()) && !folders.isEmpty()){
                documentName = 'DuplicateCaseAssets-'+ Datetime.now().format('MMM') + Datetime.now().year();
   				CSVFile = csvColumnHeader + String.join(duplicateCSVRowValues,'\n');
                Document doc = new Document(Name = documentName, Body = Blob.valueOf(CSVFile), FolderId = folders[0].Id, Type = 'csv', ContentType='application/vnd.ms-excel');
                docList.add(doc); 
            }
            if((AllCSVRowValues!=null || !AllCSVRowValues.isEmpty()) && !folders.isEmpty()){
                documentName = 'ALLCaseAssets-'+ Datetime.now().format('MMM') + Datetime.now().year();
				CSVFile = csvColumnHeader + String.join(AllCSVRowValues,'\n');
                Document doc = new Document(Name = documentName, Body = Blob.valueOf(CSVFile), FolderId = folders[0].Id, Type = 'csv', ContentType='application/vnd.ms-excel');
                docList.add(doc);
            }
            if(docList!=null || !docList.isEmpty()){
                Database.insert(docList,false);
            }
        }catch (Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), 'DUPLICATE CASE ASSET BATCH CLASS',LoggingLevel.ERROR);
        }
    }
}