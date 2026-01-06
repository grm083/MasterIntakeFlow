/*
  * @Name          ReportControllerTest
  * @Author        WM - Soham Datta
  * @Date          11/22/2024
  * @Description   This is the test class for ReportController
*/
@IsTest(SeeAllData=true)
private class ReportControllerTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string REPORT_NAME = 'All Business Rules by Customer';
    
   /*@methodName  testGetReportId
    *@description Method to test getReportId()
   	*/ 
    @isTest
    private static void testGetReportId(){
        
        User currentuser = [Select Id, Name, Profile.Name From User Where Profile.Name =: SYS_ADMIN AND IsActive = true Limit 1];
        
        System.runAs(currentuser){
            
            Test.startTest();
            Id reportId = ReportController.getReportId(REPORT_NAME);
            System.assert(reportId!=null);
            Test.stopTest();
            
        }
        
    }

}