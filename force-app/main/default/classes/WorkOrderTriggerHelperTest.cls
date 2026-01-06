@istest
public class WorkOrderTriggerHelperTest {
    @testsetup
    public static void testData(){
        Profile prfl = TestDataFactory.getProfile('System Administrator');
        User admin = TestDataFactory.createUser(prfl);
        Database.insert(admin);
        Account clientAcc = TestDataFactory.createAccount('Client Acc',admin, 'Client')[0];
        Account vendorAcc = TestDataFactory.createAccount('Vendor Acc',admin, 'Vendor')[0];
        Database.insert(new List<Account> {clientAcc, vendorAcc});
        Account locAcc = TestDataFactory.createLocation('Location Acc', admin, clientAcc.Id)[0];
        Database.insert(locAcc);
        Contact con = TestDataFactory.createContact('Test', 'Contact', clientAcc, admin)[0];
        con.Email = 'testfrom@test.com';
        Database.insert(con);
        Product2 prdct = TestDataFactory.createProduct('Test Product')[0];
        Database.insert(prdct);
        Asset asst = TestDataFactory.createAsset('Test Asset',clientAcc , con, prdct, admin, locAcc)[0];
        Database.insert(asst);
        Case pickupCase = TestDataFactory.createNewCasewithType(locAcc, con, locAcc, asst)[0];
        pickupCase.RecordTypeId = TestDataFactory.getRecordType(Constant_Util.Pickup_Case_Rec_Type, 'Case');
        Database.insert(pickupCase);
        list<Task> tasklist = TestDataFactory.createTask(pickupCase.id, admin);
        tasklist[0].RecordTypeId = TestDataFactory.getRecordType('Follow Up',Constant_Util.OBJECT_TASK);
        tasklist[0].Process__c = Constant_Util.CONFIRM_SERVICE_COMPLETION;
        tasklist[0].RecordTypeId = TestDataFactory.getRecordType('Follow Up',Constant_Util.OBJECT_TASK);
        tasklist[0].Process__c = Constant_Util.Obtain_Schedule_Confirmation;
        Database.insert(tasklist);
    }
    
    public static testmethod void insertWONegativeTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId from Case Where RecordType.Name='Pickup Case' limit 1];
        WorkOrder wrkodr = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        wrkodr.Vendor_Service_Status__c = Constant_Util.CONFIRMED_NEGATIVE;
        test.startTest();
        Database.Insert(wrkodr);
        system.assertEquals(Constant_Util.CONFIRMED_NEGATIVE,wrkodr.Vendor_Service_Status__c);
        test.stopTest();        
    }
    
    public static testmethod void insertWOPositiveTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId from Case Where RecordType.Name='Pickup Case' limit 1];
        pickupCase.Status = 'Closed';
        Database.update(pickupCase);
        WorkOrder wrkodr = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        wrkodr.Vendor_Service_Status__c = Constant_Util.CONFIRMED_POSITIVE;
        test.startTest();
        Database.Insert(wrkodr);
        system.assertEquals(Constant_Util.CONFIRMED_POSITIVE,wrkodr.Vendor_Service_Status__c);
        test.stopTest();
    }
    
    public static testmethod void insertWOCancelledTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];
        pickupCase.Status = 'Open';
        Database.update(pickupCase);
        WorkOrder wrkodr = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        wrkodr.Status = Constant_Util.CANCELLED;
        test.startTest();
        Database.Insert(wrkodr);
        system.assertEquals(Constant_Util.CANCELLED,wrkodr.Status);
        test.stopTest();
    }
    
    public static testmethod void updateServiceDateTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];
        WorkOrder wrkodr = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        wrkodr.Service_Date__c = system.today()+1;
        Database.insert(wrkodr);
        test.startTest();
        wrkodr.Status = Constant_Util.ISSUED;
        wrkodr.Service_Date__c = system.today()+2;
        Database.update(wrkodr);
        system.assertEquals(system.today()+2,wrkodr.Service_Date__c);
        test.stopTest();
    }
    
    public static testmethod void updateRescheduleDateTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];
        WorkOrder wrkodr = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        wrkodr.Rescheduled_Date__c = system.today()+1;
        Database.insert(wrkodr);
        test.startTest();
        wrkodr.Status = Constant_Util.ISSUED;
        wrkodr.Rescheduled_Date__c = system.today()+2;
        Database.update(wrkodr);
        system.assertEquals(system.today()+2,wrkodr.Rescheduled_Date__c);
        test.stopTest();
    }
    public static testmethod void updateWOTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];
        WorkOrder wrkodr = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        wrkodr.Service_Date__c = system.today()+1;
        Database.insert(wrkodr);
        test.startTest();
        wrkodr.Integration_Status__c = Constant_Util.ACCEPT;
        wrkodr.Service_Date__c = system.today()-1;
        Database.update(wrkodr);
        system.assertEquals(Constant_Util.ACCEPT,wrkodr.Integration_Status__c);
        test.stopTest();
    }
    
    public static testmethod void updtCaseStatusTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];
        pickupCase.status = constant_util.OPEN;
        Database.update(pickupCase);
        WorkOrder wrkodr = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        Database.insert(wrkodr);
        test.startTest();
        wrkodr.status = Constant_Util.ACCEPTED;
        wrkodr.Integration_Status__c = Constant_Util.ACCEPT;
        Database.update(wrkodr);
        system.assertEquals(Constant_Util.ACCEPT,wrkodr.Integration_Status__c);
        test.stopTest();
    }
    /**
    * @Authur: WM Team
    * @description test method for Delete and Undelete 
    */
    public static testmethod void deleteWOTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];
        WorkOrder wrkodr = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        Database.insert(wrkodr);
        test.startTest();
        Database.delete(wrkodr);
        test.stopTest();
        Database.undelete(wrkodr);    
    }
    
    //When RescheduleDate of workorder is changed
    public static testmethod void updateWORescheduleTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];
        WorkOrder wrkodr = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        wrkodr.Rescheduled_Date__c = datetime.now();
        Database.insert(wrkodr);
        
        test.startTest();
        wrkodr.Rescheduled_Date__c = datetime.now();
        Database.update(wrkodr);
        test.stopTest();
    }
    //When AcornWorkOrderNumber is changed
    public static testmethod void updateAcornWONumberTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];
        WorkOrder wrkodr = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        wrkodr.Acorn_WorkOrder_Number__c='W15540815';
        wrkodr.Rescheduled_Date__c = datetime.now();
        Database.insert(wrkodr);
        
        test.startTest();
        wrkodr.Acorn_WorkOrder_Number__c='W15539829';
        Database.update(wrkodr);
        system.assertEquals('W15539829',wrkodr.Acorn_WorkOrder_Number__c);
        test.stopTest();
    }
    
    //When Vendor Service Status of workorder is changed
     public static testmethod void updateVendorServiceStatusTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];       
        pickupCase.status=constant_util.OPEN;  
        pickupCase.Case_Sub_Status__c =Constant_UTIL.PENDING_SERVICE_INTEGRATION;  
        Database.update(pickupCase); 
         
        WorkOrder wrkodr = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        wrkodr.Service_Date__c = Date.today();
        Database.insert(wrkodr);
        
        test.startTest();
       // wrkodr.Vendor_Service_Status__c=constant_util.CONFIRMED_NEGATIVE;
        wrkodr.Vendor_Service_Status__c=constant_util.CONFIRMED_POSITIVE;
        wrkodr.Rescheduled_Date__c = datetime.now();
        wrkodr.Service_Date__c = Date.today().addDays(1);
        Database.update(wrkodr);
        system.assertEquals(constant_util.CONFIRMED_POSITIVE,wrkodr.Vendor_Service_Status__c);
        test.stopTest();
    }
    //When Case Sub Status of workorder is changed
    public static testmethod void updateCaseSubStatusTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];       
        pickupCase.Case_Sub_Status__c =Constant_UTIL.PENDING_SERVICE_INTEGRATION; 
        pickupCase.Source_System__c='Acorn';
        pickupCase.status= Constant_UTIL.OPEN;
        Database.update(pickupCase); 
         
        WorkOrder wrkodr = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        wrkodr.Service_Date__c = Date.today();
        Database.insert(wrkodr);
        
        test.startTest();
        wrkodr.Vendor_Service_Status__c=Constant_Util.SCHEDULED;
        wrkodr.status=Constant_UTIL.ISSUED; 
        wrkodr.send_status__c=Constant_UTIL.SCHEDULED;
        wrkodr.Rescheduled_Date__c = datetime.now();
        wrkodr.Service_Date__c = Date.today().addDays(15);
        Database.update(wrkodr);
        system.assertEquals(Constant_UTIL.PENDING_SERVICE_INTEGRATION,pickupCase.Case_Sub_Status__c);
        test.stopTest();
    }
    //When Send Status of workorder is changed when availability is confirmed
    public static testmethod void updateSendStatusTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];       
        pickupCase.Case_Sub_Status__c =Constant_UTIL.PENDING_SERVICE_INTEGRATION; 
        pickupCase.status= constant_util.OPEN;
        pickupCase.Service_Date__c = system.today();
        pickupCase.Availability_Confirmed__c = true;
        Database.update(pickupCase); 
         
        WorkOrder wrkodr = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        Database.insert(wrkodr);
        
        test.startTest();
        wrkodr.status=Constant_UTIL.ISSUED; 
        wrkodr.Send_Status__c=Constant_UTIL.SENT;
        wrkodr.Rescheduled_Date__c = datetime.now();
        system.assertEquals(Constant_UTIL.SENT,wrkodr.Send_Status__c);
        Database.update(wrkodr);
        
        test.stopTest();
    }
    //When Send Status of workorder is changed when availability is not confirmed
    public static testmethod void updateSendStatusAvailabilityTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];       
        pickupCase.Case_Sub_Status__c =Constant_UTIL.PENDING_SERVICE_INTEGRATION; 
        pickupCase.status= constant_util.OPEN;
        pickupCase.Service_Date__c = system.today();
        Database.update(pickupCase); 
         
        WorkOrder wrkodr = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        Database.insert(wrkodr);
        
        test.startTest();
        wrkodr.status=Constant_UTIL.ISSUED; 
        wrkodr.Send_Status__c=Constant_UTIL.SENT;
        wrkodr.Rescheduled_Date__c = datetime.now();
        Database.update(wrkodr);
        system.assertEquals(Constant_UTIL.SENT,wrkodr.Send_Status__c);
        test.stopTest();
    } 
    //When Case Sub Status of workorder is changed
    public static testmethod void updateCaseSubStatusNextTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];       
        pickupCase.status=constant_util.OPEN;  
        pickupCase.Case_Sub_Status__c =Constant_UTIL.PENDING_SERVICE_INTEGRATION;  
        Database.update(pickupCase); 
                
        WorkOrder wrkodr2 = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        Database.insert(wrkodr2);
        test.startTest();
        wrkodr2.Vendor_Service_Status__c=Constant_Util.SCHEDULED;
        wrkodr2.Service_Date__c = Date.today().addDays(-1);
        wrkodr2.status = constant_util.SENT; 
        system.assertEquals(Date.today().addDays(-1),wrkodr2.Service_Date__c); 
        Database.update(wrkodr2); 
        
        test.stopTest();
    }
    //When Service Date of workorder is changed
    public static testmethod void updateServiceDtTest(){
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];       
        pickupCase.status=constant_util.OPEN;  
        pickupCase.Case_Sub_Status__c =Constant_UTIL.PENDING_SERVICE_INTEGRATION;  
        Database.update(pickupCase); 
                
        WorkOrder wrkodr2 = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        wrkodr2.Service_Date__c = Date.today().addDays(4);
        Database.insert(wrkodr2);

        test.startTest();
        wrkodr2.Vendor_Service_Status__c=Constant_Util.SCHEDULED;
        wrkodr2.Service_Date__c = Date.today().addDays(2);
        wrkodr2.status = constant_util.SENT; 
    wrkodr2.Send_Status__c=Constant_UTIL.SENT;
        Database.update(wrkodr2); 
        system.assertEquals(Date.today().addDays(2), wrkodr2.Service_Date__c);
        test.stopTest();
    }
    
    
    //Whenever WorkOrder is getting created/updated it populating Client Name field with Location's Parent Account
    public static testmethod void testWOClient(){
        String clientAccId;
        String locationAccId;
        for(Account acc : [SELECT Id, Name FROM Account WHERE NAME IN ('Location Acc' , 'Client Acc')]){
            if(acc.Name == 'Location Acc'){
                locationAccId = acc.id;
            } else if(acc.Name == 'Client Acc'){
                clientAccId = acc.id;
            }
        }
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];       
        pickupCase.status=constant_util.OPEN;  
        pickupCase.Case_Sub_Status__c =Constant_UTIL.PENDING_SERVICE_INTEGRATION;  
        Database.update(pickupCase); 
                
        WorkOrder wrkodr2 = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        wrkodr2.Service_Date__c = Date.today().addDays(4);
        wrkodr2.Customer_Location__c = locationAccId;
        
        test.startTest();
        Database.insert(wrkodr2);
        Database.update(wrkodr2); 
        
        WorkOrder wo = [select id, Client__c from workorder limit 1];
        system.assertEquals(wo.Client__c  , clientAccId );
        test.stopTest();
    }
    
    public static testmethod void testUpdateDispatchEmail(){
        String vendorAccId;
        String locationAccId;
        for(Account acc : [SELECT Id, Name FROM Account WHERE NAME IN ('Location Acc' , 'Vendor Acc')]){
            if(acc.Name == 'Location Acc'){
                locationAccId = acc.id;
            } else if(acc.Name == 'Vendor Acc'){
                vendorAccId = acc.id;
            }
        }
        Case pickupCase = [Select id,Location__c,AssetId,ContactId,OwnerId,status from Case Where RecordType.Name='Pickup Case' limit 1];       
        pickupCase.status=constant_util.OPEN;  
        pickupCase.Case_Sub_Status__c =Constant_UTIL.PENDING_SERVICE_INTEGRATION;  
        Database.update(pickupCase); 
                        
        test.startTest();
        AccountContactRelation acr = new AccountContactRelation(AccountId = vendorAccId , ContactId = pickupCase.ContactId , Roles = 'Dispatch'); 
        Database.insert(acr);
        
        WorkOrder wrkodr = TestDataFactory.createWorkOrder(new Account(Id=pickupCase.Location__c), new Contact(Id=pickupCase.ContactId), pickupCase, new Asset(Id = pickupCase.AssetId))[0];
        wrkodr.Vendor_Account_Id__c = vendorAccId;
        Database.insert(wrkodr);
        
        WorkOrder wo = [select id, Client__c, Dispatch_Email__c from workorder limit 1];
        system.assertEquals(wo.Dispatch_Email__c , 'testfrom@test.com' );
        test.stopTest();
    }
}