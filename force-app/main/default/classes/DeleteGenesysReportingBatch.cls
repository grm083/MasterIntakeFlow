/*************************************************************
@Name: DeleteGenesysReportingBatch
@Author: Accenture
@CreateDate: 10/12/2020
@Description: SDT-14682 : Used to delete the Genesys Reporting Records.
*************************************************************/
public class DeleteGenesysReportingBatch implements Database.Batchable<sObject>,Database.Stateful {
    public Integer filteringDate = null;
    public Database.QueryLocator start (Database.BatchableContext bc) {
        if(filteringDate == null){
            filteringDate = 4;
        }
        String query = 'SELECT ID FROM Genesys_Reporting__c WHERE CreatedDate < LAST_N_DAYS:' + filteringDate;
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext bc, List<Genesys_Reporting__c> scope){
        List<Genesys_Reporting__c> deleteGenList = new List<Genesys_Reporting__c>();
        try{
            for(Genesys_Reporting__c gr : scope){
                deleteGenList.add(gr);
            }
            Database.delete(deleteGenList);
        }catch(Exception e){
            System.debug('delete exception -- ' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext batchVariable) {

    } 
}