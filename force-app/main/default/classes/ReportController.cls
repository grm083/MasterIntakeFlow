/*
  * @Name          ReportController
  * @Author        WM - Soham Datta
  * @Date          11/22/2024
  * @Description   This class is created to generate report Id
*/
public with sharing class ReportController {
    
   /*@methodName  getReportId
    *@description Method to query the Report 
    *@param       reportName
    *@return      Report:Id
   */  
    @AuraEnabled(cacheable=true)
    public static Id getReportId(String reportName) {
        Report report = [SELECT Id FROM Report WHERE Name = :reportName LIMIT 1];
        return report.Id;
    }
    
}