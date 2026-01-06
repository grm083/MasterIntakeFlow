@isTest//(seeAllData = true)
public class Test_SupervisorDashboardCls {
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string OTHER ='Other'; 
    private static final string CS_SUPERVISOR = 'Customer Experience Supervisor';
    private static User usr{get;set;}
    
    @isTest static void showOpenTaskTest(){ 
        try{
            Profile adminProfile = [SELECT Id FROM Profile WHERE Name=:SYS_ADMIN];
            User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = adminProfile.Id, Acorn_SUser_ID__c = 999,
                                TimeZoneSidKey='America/Los_Angeles', UserName='SystemAdministrator'+ String.valueof(system.now().millisecond())+'@testorg.com',IsActive = true);
            
            
            system.runAs(usr){
                
                List<Id> caseItemListId = new List<Id>();
                Map<Id,String> ticketItemListId = new Map<Id,String>();
                List<Case> caseList = [Select Id from case where status='Open' limit 1];
                if(caseList != null){
                    caseItemListId.add(caseList.get(0).Id);
                    ticketItemListId.put(caseList.get(0).Id, 'VRM Inquiry');
                }
                
                
                List<Id> taskItemListId = new List<Id>();
                List<Task> taskList = [Select Id from task where status='Open' limit 1];
                if(taskList != null){
                    taskItemListId.add(taskList.get(0).Id);
                }
                
                
                Map<String,String> dashboardFilter = new Map<String,String>();
                dashboardFilter.put('Case.ClientName','The Home Depot');
                dashboardFilter.put('Case.VendorName','City of Ontario Ca');
                dashboardFilter.put('Case.LocationName','RES7085MKT8');
                dashboardFilter.put('Case.ParentVendorName','Wmi');
                dashboardFilter.put('Case.Case_Sub_Type__c','Empty and Return');
                dashboardFilter.put('Case.Case_Type__c','Pickup');
                dashboardFilter.put('Process__c','Confirm Service Completion');
                dashboardFilter.put('TaskOwnerName',usr.name);
                dashboardFilter.put('CaseComment.Workflow_TeamUser__c','VRNS');
                dashboardFilter.put('ClientName','The Home Depot');
                dashboardFilter.put('VendorName','City of Ontario Ca');
                dashboardFilter.put('LocationName','RES7085MKT8');
                dashboardFilter.put('ParentVendorName','Wmi');
                dashboardFilter.put('Case_Sub_Type__c','Empty and Return');
                dashboardFilter.put('Case_Type__c','Pickup');
                
                PageReference pageRef = Page.GetSessionIdVF;
                Test.setCurrentPage(pageRef);
                
                system.debug('::'+caseItemListId);
                Test.startTest();
                SupervisorDashboardCls.getTaskList('Task',dashboardFilter);
                SupervisorDashboardCls.getTaskList('workflow',dashboardFilter);
                SupervisorDashboardCls.getTicketList(dashboardFilter,'allCases');
                SupervisorDashboardCls.getTicketList(dashboardFilter,'UnassignedCases');
                SupervisorDashboardCls.getFewUsers();
                SupervisorDashboardCls.getAllActiveUsers();
                SupervisorDashboardCls.updateTheObjectList(caseItemListId,system.now(),'low','case',usr.Id,'test');
                SupervisorDashboardCls.updateTheObjectList(caseItemListId,system.now(),'low','case',usr.Id,'test');
                SupervisorDashboardCls.updateTheObjectList(caseItemListId,system.now(),'low','case',null,'test');
                SupervisorDashboardCls.updateTheObjectList(taskItemListId,system.now(),'low','task',usr.Id,'test');
                SupervisorDashboardCls.updateTheTicketList(ticketItemListId,system.now(),'Wasteless','PM Evans, K','low','ticket',usr.Id,'test');
                SupervisorDashboardCls.updateTheTicketList(ticketItemListId,system.now(),null,null,'low','ticket',usr.Id,'test');
                SupervisorDashboardCls.updateTheTicketList(ticketItemListId,system.now(),'Wasteless',null,'low','ticket',usr.Id,'test');
                //SupervisorDashboardCls.getCaseList();
                SupervisorDashboardCls.getQueuePicklistvalues();
                SupervisorDashboardCls.updateWorkflowTaskClose(taskItemListId);
               // PersonalQueueTicketAssignmentTaskBatch batchQueue = new PersonalQueueTicketAssignmentTaskBatch();
               // Database.executeBatch(batchQueue);
                Test.stopTest();
            }  
        }catch(Exception ex){
            system.debug('Ex :' + ex.getMessage());
        }
        
    }
    
    @isTest static void testgetCaseList(){
        try{
            Profile adminProfile = [SELECT Id FROM Profile WHERE Name=:SYS_ADMIN];
            User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = adminProfile.Id, Acorn_SUser_ID__c = 999,
                                TimeZoneSidKey='America/Los_Angeles', UserName='SystemAdministrator'+ String.valueof(system.now().millisecond())+'@testorg.com',IsActive = true);
            
            
            system.runAs(usr){
                
                List<Id> caseItemListId = new List<Id>();
                List<Case> caseList = [Select Id from case where status='Open' limit 1];
                if(caseList != null){
                    caseItemListId.add(caseList.get(0).Id);
                }
                
                List<Id> taskItemListId = new List<Id>();
                List<Task> taskList = [Select Id from task where status='Open' limit 1];
                if(taskList != null){
                    taskItemListId.add(taskList.get(0).Id);
                }
                
                PageReference pageRef = Page.GetSessionIdVF;
                Test.setCurrentPage(pageRef);
                
                system.debug('::'+caseItemListId);
                Test.startTest();
                SupervisorDashboardCls.getCaseList();
                Test.stopTest();
            }
        }catch(Exception ex){
            system.debug('Ex :' + ex.getMessage());
        }       
    }
    
}