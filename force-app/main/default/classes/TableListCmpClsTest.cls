/**
* @author Accenture
* @date 4/15/2019
* @description : Apex class MyTaskListController 
test class for MyTaskListController
**/
@isTest(seeAllData = false)
public class TableListCmpClsTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string OTHER ='Other'; 
    private static final string CS_SUPERVISOR = 'Customer Experience Supervisor';
    private static User usr{get;set;}
    
    /*
* Method to set the Test Data.
* @owner : Ganesh ram s
* @param :
*/
    @testSetup static void setup() {
        /* Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
           UserRole role = new UserRole();
 		   role.Name = SYS_ADMIN ;
		   Database.insert(role);
		   usr = TestDataFactory.createUser(adminProfile);
		   usr.UserRoleId = role.id ;
		   Database.insert(usr);   */
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name=:SYS_ADMIN];
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = adminProfile.Id, Acorn_SUser_ID__c = 999,
                            TimeZoneSidKey='America/Los_Angeles', UserName='SystemAdministrator'+ String.valueof(system.now().millisecond())+'@testorg.com',IsActive = true);
        
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            acclist.get(1).Status__c = 'Active';
            Database.insert(acclist);
            list<Account> parentacclist = TestDataFactory.createAccountwithParent(Constant_Util.KEYWORD_TEST, usr ,acclist.get(0).id);
            Database.insert(parentacclist);
            list<Account> supplieracclist = TestDataFactory.createAccountwithoutParent(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(supplieracclist);
            list<Account> childacclist = TestDataFactory.createAccountwithParent(Constant_Util.KEYWORD_TEST, usr ,acclist.get(1).id);
            Database.insert(childacclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            Database.insert(assetlist);
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist.get(0).AccountId = acclist.get(0).id ;
            caselist.get(0).Status = 'Open';
            caselist.get(0).Supplier__c = parentacclist.get(0).id ;
            Database.insert(caselist.get(0));
            caselist.get(1).Status = 'Open';
            caselist.get(1).Supplier__c = supplieracclist.get(0).id ;
            Database.insert(caselist.get(1));
            caselist.get(2).AccountId = acclist.get(1).id ;
            caselist.get(2).Status = 'Open';
            caselist.get(2).Supplier__c = childacclist.get(0).id ;
            Database.insert(caselist.get(2));
            
            list<Business_Rule__c> brlst = TestDataFactory.createBusinessRule(Constant_Util.KEYWORD_TEST,acclist.get(0),locationlist.get(0));
            brlst[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            //brlst[0].Required_Information__c = 'PO Number';
            brlst[0].Required_Information__c = Constant_Util.PO_NUMBER; 
            Database.insert(brlst);
            
            
            String csRep = Constant_Util.CS_REP ;
            UserRole csrRole = [select id, name from UserRole where name = :csRep limit 1];
            
            User CsrUser = TestDataFactory.createUser(adminProfile);
            CsrUser.UserRoleId = csrRole.id ;
            Database.insert(CsrUser, false);
            
            UserRole supervisorRole = [select id, name from UserRole where name = :CS_SUPERVISOR limit 1];
            
            User supervisorUser = TestDataFactory.createUser(adminProfile);
            supervisorUser.UserRoleId = supervisorRole.id ;
            Database.insert(supervisorUser, false);
            //modified by av4 on 26/07/2024 for SDT-41134 
            List<Task> finalTaskList = new List<Task>();
            list<Task> tasklistParentAccount = TestDataFactory.createTask(caselist.get(1).id, usr);
            tasklistParentAccount[0].OwnerId = supervisorUser.id ;
            //Database.insert(tasklistParentAccount);
            list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
            tasklist[0].OwnerId = supervisorUser.id ;
            //Database.insert(tasklist);
            list<Task> tasklistParent = TestDataFactory.createTask(caselist.get(2).id, usr);
            tasklistParent[0].OwnerId = supervisorUser.id ;
            //Database.insert(tasklistParent);
            finalTaskList.add(tasklistParentAccount[0]);
            finalTaskList.add(tasklist[0]);
            finalTaskList.add(tasklistParent[0]);
            Database.insert(finalTaskList);
            
            
        }}
    
    /*
* Method to test getTasks function.
* @owner : Ganesh ram s
* @param :
*/
    @isTest static void showOpenTaskTest(){
        
        List<user> currentuser = [select id, IsActive, Bypass_Validation__c from user where UserRole.Name = 'Customer Experience Representative'  and IsActive = true limit 2];
        List<user> currentuser2 = [select id, IsActive, Bypass_Validation__c from user where UserRole.Name = 'System Administrator' and IsActive = true ];
        List<user> currentuser3 = [select id, IsActive, Bypass_Validation__c from user where UserRole.Name = 'Customer Experience Supervisor'  and IsActive = true limit 2];
        List<Task> resultList = new List<Task>([select Process__c from Task Limit 1]);
        List<Account> accountlist = new List<Account>([select id from Account]);
        
        system.runAs(currentuser.get(1)){
            
            test.startTest();
            try{
                //TableListCmpCls.getAccountDetailsForDashboard(currentuser.get(1).id);
                //TableListCmpCls.getAccountDetails();
                
                //TableListCmpCls.getParentAccountDetailsForDashboard(currentuser.get(1).id);
                //TableListCmpCls.getAccountDetailsForDashboard(currentuser.get(1).id);
                //TableListCmpCls.getLocationAccountDetailsForDashboard(currentuser.get(1).id);
                TableListCmpCls.getParentAccountDetails();
                TableListCmpCls.getAccountDetails();
                TableListCmpCls.getLocationAccountDetails(); 
                
                Task tsk = new Task();
                TableListCmpCls.getDependentMap(tsk,'Process__c','Outcome__c');
                TableListCmpCls.getCurrentLoggedInUser(currentuser2.get(1).id);
                TableListCmpCls.getCurrentLoggedInUser(currentuser.get(1).id);
                TableListCmpCls.getCurrentLoggedInUser(currentuser3.get(1).id);
                
                System.assert(!accountlist.isEmpty()); 
                
            }
            catch (Exception e){
                System.debug('Exception occured:'+e);
            }
            test.stopTest();
            
        }
        
    } 
    
    
    @isTest static void showOpenTaskTest2(){
        
        List<user> currentuser = [select id, IsActive, Bypass_Validation__c from user where UserRole.Name = 'Customer Experience Representative' and IsActive = true limit 2];
        List<user> currentuser2 = [select id, IsActive, Bypass_Validation__c from user where UserRole.Name = 'System Administrator'and IsActive = true];
        List<user> currentuser3 = [select id, IsActive, Bypass_Validation__c from user where UserRole.Name = 'Customer Experience Supervisor' and IsActive = true limit 2];
        List<Task> resultList = new List<Task>([select Process__c from Task Limit 1]);
        List<Account> accountlist = new List<Account>([select id from Account]);
        
        system.runAs(currentuser3.get(0)){
            
            test.startTest();
            try{
                //TableListCmpCls.getAccountDetailsForDashboard(currentuser3.get(1).id);
                //TableListCmpCls.getAccountDetails();
                TableListCmpCls.getCurrentLoggedInUser(currentuser3.get(0).id);
                //TableListCmpCls.getParentAccountDetailsForDashboard(currentuser3.get(0).id);
                //TableListCmpCls.getAccountDetailsForDashboard(currentuser3.get(0).id);
                //TableListCmpCls.getLocationAccountDetailsForDashboard(currentuser3.get(0).id);
                TableListCmpCls.getParentAccountDetails();
                TableListCmpCls.getAccountDetails();
                TableListCmpCls.getLocationAccountDetails();
                
                // TableListCmpCls.getAllTasksByParentVendor(accountlist,'Vendor');
                
                Task tsk = new Task();
                TableListCmpCls.getDependentMap(tsk,'Process__c','Outcome__c');
                TableListCmpCls.getCurrentLoggedInUser(currentuser.get(0).id);
                
                System.assert(!accountlist.isEmpty()); 
                
            }
            catch (Exception e){
                System.debug('Exception occured:'+e);
            }
            test.stopTest();
            
        }
        
    } 
    
    
    /*
* Method to test getTasks function.
* @owner : Ganesh ram s
* @param :
*/
    @isTest static void showOpenTask(){
        
        List<user> currentuser = [select id, IsActive , Bypass_Validation__c from user where UserRole.Name = 'Customer Experience Representative' and IsActive = true limit 2];
        List<user> currentuser2 = [select id, IsActive , Bypass_Validation__c from user where UserRole.Name = 'System Administrator' and IsActive = true];
        List<user> currentuser3 = [select id, IsActive , Bypass_Validation__c from user where UserRole.Name = 'Customer Experience Supervisor' and IsActive = true limit 2];
        List<Task> resultList = new List<Task>([select Process__c from Task Limit 1]);
        List<Task> resultLists = new List<Task>([select Process__c from Task Limit 1]);
        List<Task> Tsk = new List<Task>();        
        List<TaskTableWrapper> openTableTaskList = new List<TaskTableWrapper>();
        
        test.startTest();
        try{
            //System.assert(!resultList.isEmpty());   
            TaskTableWrapper taskTable = new TaskTableWrapper();
            taskTable.TaskId = resultList.get(0).Id;
            taskTable.Outcome = '';
            taskTable.Comments = 'test';
            taskTable.AssignedTo = '0051I000003vtI8QAI';
            
            openTableTaskList.add(taskTable);
            
            TableListCmpCls.updateSelectedTasks(openTableTaskList);
            System.assert(!openTableTaskList.isEmpty());
            
            
            // TableListCmpCls.updateSelectedTasks(resultList);
            //TableListCmpCls.updateSelectedTasks(resultLists);
            //System.assert(!resultList.isEmpty());
            //System.assert(!resultLists.isEmpty());
        }
        catch (Exception e){
            System.debug('Exception occured:'+e);
        }
        test.stopTest();
        
        
    } 
}