/**
* @author Accenture
* @date 4/15/2019
* @description : Apex class MyTaskListController 
test class for MyTaskListController
**/
@isTest(seeAllData = false)
public class MyTaskListControllerTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string OTHER ='Other'; 
    private static final string CS_SUPERVISOR = 'Customer Experience Supervisor';
private static final string CUSTOMER_SERVICE = 'Customer Service';//Modified for SDT-33462
    
    private static User usr{get;set;}
    
    /*
* Method to set the Test Data.
* @owner : Ganesh ram s
* @param :
*/
    @testSetup static void setup() {
        /*Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
UserRole role = new UserRole();
role.Name = SYS_ADMIN ;
Database.insert(role);
usr = TestDataFactory.createUser(adminProfile);
usr.UserRoleId = role.id ;
Database.insert(usr); */
        
        /*Profile adminProfile = [SELECT Id FROM Profile WHERE Name=:SYS_ADMIN];
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = adminProfile.Id, Acorn_SUser_ID__c = 999,
                            TimeZoneSidKey='America/Los_Angeles', UserName='SystemAdministrator'+ String.valueof(system.now().millisecond())+'@testorg.com',IsActive = true);*/ //Commented for SDT-33462
        
Profile csrProfile= TestDataFactory.getProfile(CUSTOMER_SERVICE); //Modified for SDT-33462
        Boolean BypassValidation = true; //Modified for SDT-33462
        Boolean GenesysEnabled = false; //Modified for SDT-33462
        User usr = TestDataFactory.getCSRUser(BypassValidation, GenesysEnabled); //Modified for SDT-33462
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
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
            Database.insert(caselist.get(0));
            list<Business_Rule__c> brlst = TestDataFactory.createBusinessRule(Constant_Util.KEYWORD_TEST,acclist.get(0),locationlist.get(0));
            brlst[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            //brlst[0].Required_Information__c = 'PO Number';
            brlst[0].Required_Information__c = Constant_Util.PO_NUMBER; 
            Database.insert(brlst);
            list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
            Database.insert(tasklist);
            String csRep = Constant_Util.CS_REP ;
            UserRole csrRole = [select id, name from UserRole where name = :csRep limit 1];
            
            User CsrUser = TestDataFactory.createUser(csrProfile); //Modified for SDT-33462
            CsrUser.UserRoleId = csrRole.id ;
            Database.insert(CsrUser, false);
            
        }}
    
    /*
* Method to test getTasks function.
* @owner : Ganesh ram s
* @param :
*/
    @isTest static void showOpenTaskTest(){
        
        //User usr = [Select id from User where Profile.Name =:SYS_ADMIN and IsActive = true  limit 1];
        //Querying CSR User.
        User usr = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1]; //Modified for SDT-33462
        List<Task> resultList = new List<Task>([select Id from Task where what.Type = 'Case' and status = 'Open' Limit 1]);
        resultList[0].OwnerId = usr.id ;
        update resultList ;
        
        system.runAs(usr){
            
            test.startTest();
            try{
                
                MyTaskListController.getTasks();
                
            }
            catch (Exception e){
                System.debug('Exception occured:'+e);
            }
            test.stopTest();
            //System.assert(resultList!=null);
        }
    } 
    
    /*
* Method to test getTasks function.
* @owner : Ganesh ram s
* @param :
*/
    @isTest static void showOpenTaskNegativeTest(){
        
        //User usr = [Select id from User where Profile.Name =:SYS_ADMIN and IsActive = true  limit 1];
//Querying CSR User.
        User usr = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1]; //Modified for SDT-33462
        List<Task> resultList = new List<Task>();
        system.runAs(usr){
            
            test.startTest();
            try{
                MyTaskListController.getTasks();
                
            }
            catch (Exception e){
                System.debug('Exception occured:'+e);
            }
            test.stopTest();
            //System.assert(resultList!=null);
        }
    } 
    
    /*
* Method to Test the showTeamTask function.
* @owner : Ganesh ram s
* @param :
*/
    @isTest static void showTeamTaskTest(){
        
        User usr = [Select id from User where Profile.Name =:SYS_ADMIN and IsActive = true  limit 1];
        
        List<Task> resultList = new List<Task>([select Id from Task where what.Type = 'Case' and status = 'Open' Limit 2]);
        
        list<Group> groups = new list<Group>();
        Group grp = new Group();
        grp.name = 'Test Group 1';
        grp.Type = 'Regular';
        Database.insert(grp, false); 
        
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = usr.id ;
        grpMem1.GroupId = grp.Id;
        Database.insert(grpMem1, false);
        
        Group subGrp  = new Group();
        subGrp.name = 'Test Group 2';
        subGrp.Type = 'Regular';
        Database.insert(subGrp, false);
        
        Profile adminProfile2 = TestDataFactory.getProfile('System Administrator');
        User usr2 = TestDataFactory.createUser(adminProfile2);            
        Database.insert(usr2);
        
        GroupMember grpMem3 = new GroupMember();
        grpMem3.UserOrGroupId = usr2.id;
        grpMem3.GroupId = subGrp.Id;
        Database.insert(grpMem3);
        
        GroupMember grpMem2 = new GroupMember();
        grpMem2.UserOrGroupId = subGrp.Id;
        grpMem2.GroupId = grp.Id;
        Database.insert(grpMem2);
        
        groups.add(grp);
        
        
        system.runAs(usr){
            
            //list<Group> grp = TestDataFactory.createGroup(usr);
            resultList[0].OwnerId = usr.id ;
            update resultList ;
            resultList[1].OwnerId = usr2.id ;
            update resultList ;
            //List<Task> resultList = new List<Task>();
            
            test.startTest();
            try{
                
                MyTaskListController.showTeamTasks();
                
            }
            catch (Exception e){
                System.debug('Exception occured:'+e);
            }
            test.stopTest();
            //System.assert(resultList!=null);
        }}
    
    /*
* Method to Test the showTeamTask function.
* @owner : Ganesh ram s
* @param :
*/
    @isTest static void showTeamTaskNegativeTest(){
        //User usr = [Select id from User where Profile.Name =:SYS_ADMIN and IsActive = true  limit 1];
//Querying CSR User.
        User usr = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1]; //Modified for SDT-33462
        List<Task> resultList = new List<Task>();
        
        
        system.runAs(usr){
            
            test.startTest();
            try{
                
                MyTaskListController.showTeamTasks();
                
            }
            catch (Exception e){
                System.debug('Exception occured:'+e);
            }
            test.stopTest();
            //System.assert(resultList!=null);
        }}
     @isTest static void getSFDCTeamAcessTest(){
        //User usr = [Select id,User_categorization_code__c from User where Profile.Name =:SYS_ADMIN and IsActive = true  limit 1];
        //Querying CSR User.
        User usr = [SELECT Id, User_categorization_code__c, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1]; //Modified for SDT-33462
        //List<Task> resultList = new List<Task>();
            system.runAs(usr){
                usr.User_categorization_code__c = 'CSMGR' ;
                Database.update(usr);// Modified for SDT-33462
                Test.startTest();
          List<String> teamAcessList =   MyTaskListController.getSFDCTeamAcess();
                MyTaskListController.getSFDCTeamTask();
                MyTaskListController.getSFDCTeamTaskWithFilter('Customer Service Team');
                Test.stopTest();
                
         
     }
     }
    
    
    //Modified for SDT-33462 Start
    /*
    * Method to Test the getSFDCTeamQuotes function.
    * @owner : Manisha Patil
    * @param :
    */
    @isTest static void TestgetSFDCTeamQuotes(){
        Test.startTest();
        MyTaskListController.getSFDCTeamQuotes();
        Test.stopTest();
    }
    //Modified for SDT-33462 End
    
    //Modified for SDT-33462 Start
    /*
    * Method to Test the getSFDCTeamTaskWithFilterQuote function.
    * @owner : Manisha Patil
    * @param :
    */
    @isTest static void TestgetSFDCTeamTaskWithFilterQuote(){
        Test.startTest();
        String userSelectedTeam = 'Test';
        MyTaskListController.getSFDCTeamTaskWithFilterQuote(userSelectedTeam);
        Test.stopTest();
    }
    //Modified for SDT-33462 End
    
    
    
    //Modified for SDT-33462 Start
    /*
    * Method to Test the getUserTimeZone function.
    * @owner : Manisha Patil
    * @param :
    */
    @isTest static void TestgetUserTimeZone(){
        Test.startTest();
        MyTaskListController.getUserTimeZone();
        Test.stopTest();
    }
    //Modified for SDT-33462 End
}