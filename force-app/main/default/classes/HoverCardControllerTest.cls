@isTest(seeAllData=false)
public class HoverCardControllerTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/New_York';
            locationlist[0].tz__UTF_Offset__c = -4;
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            conlist[0].Contact_Status__c = 'Active';
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].ProductTypeSelected__c = 'Compactor';
            productlist[0].Family = 'Rolloff';
            Database.insert(productlist);
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            AccountContactRelation AccContactRel = TestDataFactory.returnAccConRel(supplieracclist[0].Id,conlist[0],'Commercial Service/Dispatch;Rolloff Service/Dispatch;Dispatch');
            Database.insert(AccContactRel);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            List<Project_Code__c> pCodeList=TestDataFactory.createProjectCode(acclist.get(0).Id);
            Database.insert(pCodeList);
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Project_Code__c = pCodeList[0].Id;
            assetlist[0].End_Date__c = system.today() - 2;
            Database.insert(assetlist);
           
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].Service_Date__c = system.today();
            
            Database.insert(caselist);
            
            list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
            tasklist[0].RecordTypeId = TestDataFactory.getRecordType(Constant_Util.APPROVALS,Constant_Util.OBJECT_TASK);
            tasklist[0].Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            Database.insert(tasklist);
        }
    }
    
    @isTest static void testTaskRecord() {
        List<Task> taskList = [Select Id,subject,status from Task LIMIT 1];
        HoverCardController.getFields('WorkOrder' , 'HoverCard');
        HoverCardController.TaskWrapper taskWrapper = HoverCardController.getTaskRecord(taskList[0].Id);
        system.assertEquals(taskWrapper.subject, taskList[0].subject);
        system.assertEquals(taskWrapper.status, taskList[0].status);
    }

}