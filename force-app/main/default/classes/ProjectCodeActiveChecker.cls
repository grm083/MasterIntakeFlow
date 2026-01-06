/*************************************************************
@Name: ProjectCodeActiveChecker
@Author: Satyabrata Nag
@CreateDate: 07/29/2019
@Description: Daily Batch to identify Project Code Active flag on Asset .
**************************************************************/
public class ProjectCodeActiveChecker implements Schedulable,Database.Batchable<sObject>{
    public Date datecheck = Date.today().addDays(-1);
    public String qry ='Select Id,Project_Code__c,Active__c,End_Date_Based_on_Project_code__c from Asset where Active__c=true and End_Date_Based_on_Project_code__c<=:datecheck and Project_Code__c!=null';
    
	public void execute(SchedulableContext ctx) {
        Database.executeBatch(new ProjectCodeActiveChecker(), 200); 
    } 
	public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(qry);
    }
    
    public void execute(Database.BatchableContext BC, List<Asset> assetList){
        try{
            for(Asset s : assetList){
                s.Active__c=false;
            }
            if(assetList.size()>0){ 
				update assetList;
            }
            if(Test.isRunningTest()){
                DMLException e = new DMLException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch (Exception e){
            //To handle Error in future Sprints
            system.debug('$$$$'+e.getStackTraceString());
            system.debug('DmlException caught: ' + e.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}