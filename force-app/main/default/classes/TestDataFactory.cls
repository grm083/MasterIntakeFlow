/**
* @author Accenture
* @date 1/31/2019
* @description : Apex class TestDataFactory
**/
@isTest
public class TestDataFactory {
    
    // Create Custome Setting Data for Logging_Framework_Control__c
    static {
            /*    Logging_Framework_Control__c logSetting = new Logging_Framework_Control__c(); 
                    logSetting.Name = 'updateServiceDateInsert';
                    logSetting.Active_Inactive__c = true;
                insert logSetting;
                sla_calculation__c slaSetting = new sla_calculation__c(); 
                    slaSetting.Name = 'Pickup';
                    slaSetting.Enabled__c = true;
                insert slaSetting;
			*/
    }
    // Added this method for haul away code switch
    public static Code_Switch__c codeSwitch(String name, Boolean switchStatus){
        
        Code_Switch__c codeSwitchSetting = new Code_Switch__c(
            Name = name, 
            Switch_Off__c = switchStatus 
        );
        insert codeSwitchSetting;
        return codeSwitchSetting;
    }
       
    public static User createUser(Profile P){
        Profile profile = TestDataFactory.getProfile('System Administrator');
        User usr = TestUserFactory.createUserDetails(profile);
        return usr;
    }
    
    /* Test Data creation for "Process_Builder_to_Flow" Custom setting  */
    
    public static void createProcessBuilderTOFlow(){
        Code_Switch__c codeSwitchSetting = new  Code_Switch__c();
       codeSwitchSetting.Name = 'Process_Builder_to_Flow';
       codeSwitchSetting.Switch_Off__c = false;
        Insert codeSwitchSetting;
    }
    
    public static Profile getProfile(String name){
        return [SELECT Id FROM Profile WHERE Name=: name];
    }
    
    public static Id getRecordType(String RecordTypeName, String SobjectType){
        return Schema.getGlobalDescribe().get(SobjectType).getDescribe().getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId(); 
    }
    
    public static List<Account> createAccount(string name, User usr){
        list<Account> acclist = new list<Account>();
        Account acc = new Account(Name = name, phone = '9999999999', OwnerId = usr.id,AccountNumber='1236',
                                  RecordTypeid = getRecordType('Client','Account'));
        Account acc2 = new Account(Name = name, phone = '9999999999', OwnerId = usr.id,AccountNumber='123',
                                  RecordTypeid = getRecordType('Vendor','Account'));
        Account acc3 = new Account(Name = name, phone = '9999999888', OwnerId = usr.id,AccountNumber='124',
                                  RecordTypeid = getRecordType('Vendor','Account'));
        acclist.add(acc);
        acclist.add(acc2);
        acclist.add(acc3);
        return acclist;
    }

    public static Account returnAccount(String name, String accNum, String recordTypeName, User usr){
        Account myAccount = new Account();
        myAccount.Name = name;
        myAccount.phone = '9999999999';
        myAccount.OwnerId = usr.id;
        myAccount.AccountNumber = accNum;
        myAccount.RecordTypeid = getRecordType(recordTypeName,'Account');
      

        return myAccount;
    }

    public static AccountContactRelation returnAccConRel(String accId, Contact con, String roleString){
        AccountContactRelation myACR = new AccountContactRelation();
        myACR.AccountId = accId;
        myACR.ContactId = con.Id;
        myACR.Roles = roleString;
        return myACR;
    }
    
    public static List<Group> createGroup(User usr){
        
        List<Group> groups = new List<Group>();
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
        return groups ;
    }
    
    public static list<Account> createAccount(string name, User usr,String recordtype){
        list<Account> acclist = new list<Account>();
        Account acc = new Account(Name = name, phone = '9999999999', OwnerId = usr.id,
                                  RecordTypeid = getRecordType(recordtype,'Account'));
        acclist.add(acc);
        return acclist;
    }
    
    public static list<Account> createLocation(string name, User usr,Id ParentaccId){        
        list<Account> acclist = new list<Account>();
        Account acc = new Account(Name = name,AccountNumber = name,Common_Name__c = name ,phone = '9999999999', OwnerId = usr.id, 
                                  RecordTypeid = getRecordType('Location','Account'), ParentId = ParentaccId, Status__c = 'ACTIVE');
        acclist.add(acc);
        return acclist;
    }

    public static Account returnLocation(String name, Id parentAccountId, User usr){
        Account myLocation = new Account();
        myLocation.Name = name;
        myLocation.AccountNumber = name;
        myLocation.Common_Name__c = name; 
        myLocation.Phone = '9999999999';
        myLocation.OwnerId = usr.id;
        myLocation.RecordTypeid = getRecordType('Location','Account');
        myLocation.ParentId = parentAccountId;
        myLocation.Status__c = 'ACTIVE';

        return myLocation;
    }
    
    public static list<Account> createAccountwithParent(string name, User usr,Id ParentaccId){        
        list<Account> acclist = new list<Account>();
        Account acc = new Account(Name = name,AccountNumber = name ,phone = '9999999999', OwnerId = usr.id, 
                                  RecordTypeid = getRecordType('Vendor','Account'), ParentId = ParentaccId, Status__c = 'ACTIVE');
        acclist.add(acc);
        return acclist;
    }
    
    public static List<Account> createAccountwithoutParent(String name, User usr){        
        List<Account> acclist = new List<Account>();
        Account acc = new Account(Name = name,AccountNumber = name ,phone = '9999999999', OwnerId = usr.id, 
                                  RecordTypeid = getRecordType('Vendor','Account'), Status__c = 'ACTIVE');
        acclist.add(acc);
        return acclist;
    }
    
    public static List<Contact> createContact(String firstName, String lastname, Account acc, User usr){
        List<Contact> conlist = new List<Contact>();
        Contact con = new Contact(FirstName = firstName, LastName = lastname, phone = '9999999999', 
                                  Accountid = acc.id, OwnerId = usr.id, Email='testfrom@test.com');
        conlist.add(con);
        return conlist;
    }

    public static Contact returnContact(String firstName, String lastName, Account acc, User usr){
        Contact myContact = new Contact();
        myContact.FirstName = firstName;
        myContact.LastName = lastName; 
        myContact.Phone = '9999999999'; 
        myContact.Accountid = acc.id;
        myContact.OwnerId = usr.id;
        myContact.Email='testfrom@test.com';

        return myContact;
    }
    
    public static AccountTeamMember createAccountTeamMember(Account acc, Id usrId){
     
        AccountTeamMember con = new AccountTeamMember(UserId = usrId, AccountId = acc.Id );
        
        return con;
    }
    
   public static list<Business_Rule__c> createBusinessRule(string Name, Account acc, Account loc){
        list<Business_Rule__c> businessrulelist = new list<Business_Rule__c>();
        Business_Rule__c businessrule = new Business_Rule__c(Accountid__c = acc.id, locationid__c = loc.id, 
                                                             Container__c = 'Equipment', Service__c = 'Extra Pickup', 
                                                             Request_Type__c = 'Pickup', Schedule_Type__c = 'Temporary',
                                                             Active__c = true,Effective_Date__c = System.today() - 1,
                                                             Channel_Req__c= 'Test Channel Requirements',Channel__c = 'WM Portal',
                                                             RecordTypeid = getRecordType(Constant_Util.BUSINESS_NOTIFICATION,'Business_Rule__c') );
        
        businessrulelist.add(businessrule);
        
        return businessrulelist;
    }
    
    public static list<Approval_Log__c> createApprovallog(Id caseId){
        list<Approval_Log__c> approvalLoglist = new list<Approval_Log__c>();
        Approval_Log__c approvallog = new Approval_Log__c();
        approvallog.CaseId__c = caseId;
        approvalLoglist.add(approvallog);
        return approvalLoglist;
    }
    
    public static list<Service_Approver__c> createServiceApprover(Business_Rule__c br){
        list<Service_Approver__c> serviceApproverlist = new list<Service_Approver__c>();
        Service_Approver__c serviceApprover = new Service_Approver__c(Business_Rule__c = br.id, Location__c =  br.locationid__c , Account__c = br.Accountid__c,
                                                                      Recordtypeid = getRecordType('Title','Service_Approver__c'));
        serviceApproverlist.add(serviceApprover);
        return serviceApproverlist;
    }
	public static list<Service_Approver__c> createEmailServiceApprover(Business_Rule__c br){
        list<Service_Approver__c> serviceApproverlist = new list<Service_Approver__c>();
        Service_Approver__c serviceApprover = new Service_Approver__c(Business_Rule__c = br.id, Location__c =  br.locationid__c , Account__c = br.Accountid__c,
                                                                      Recordtypeid = getRecordType('Email','Service_Approver__c'));
        serviceApproverlist.add(serviceApprover);
        return serviceApproverlist;
    }
    
    public static list<Product2> createProduct(string name){
        list<Product2> productlist = new list<Product2>();
        Product2 prd = new Product2(Name = name, Family = 'Commercial', ProductTypeSelected__c = 'Equipment');
        productlist.add(prd);
        return productlist;
    }

    public static Product2 returnProduct(String name, String familyType, String productType){
        Product2 myProduct = new Product2();
        myProduct.Name = name;
        myProduct.Family = familyType;
        myProduct.ProductTypeSelected__c = productType;
        
        return myProduct;
    }
    
    public static list<Entitlement> createEntitlement(string Name, Account loc){
        list<Entitlement> entitlementlist = new list<Entitlement>();
        Entitlement ent = new Entitlement(Name='Entitlement1', AccountId=loc.ParentId, StartDate=Date.valueof(System.now().addDays(-2)),
                                          EndDate=Date.valueof(System.now().addYears(2)), Status__c = 'Approved', 
                                          Recordtypeid = getRecordType('SLA','Entitlement'), Request_Type__c = 'PickUp', 
                                          service__c = 'Extra Pickup', Call_On__c = 'Sun;Mon;Tue;Wed;Thu;Fri;Sat',Service_Guarantee_Category__c = 'Days',Service_Guarantee_Category_Value__c = '1');
        Entitlement ent1 = new Entitlement(Name='Entitlement2', AccountId=loc.ParentId, Status__c = 'Approved', 
                                          Recordtypeid = getRecordType('SLA','Entitlement'), Request_Type__c = 'PickUp', 
                                          service__c = 'Extra Pickup', Call_On__c = 'Sun;Mon;Tue;Wed;Thu;Fri;Sat',StartDate = Date.valueof(system.now().addDays(-1)),Call_Time__c = '10:00',
                                          Before_After__c = 'Before',location__c = loc.id,container__c = 'Equipment',Schedule_Type__c = 'Temporary',
                                          Service_Guarantee_Category__c = 'Days',Service_Guarantee_Category_Value__c = '1',EndDate = null);
        Entitlement ent2 = new Entitlement(Name='Entitlement2', AccountId=loc.ParentId, Status__c = 'Approved', 
                                          Recordtypeid = getRecordType('SLA','Entitlement'), Request_Type__c = 'PickUp', 
                                          service__c = 'Extra Pickup', Call_On__c = 'Sun;Mon;Tue;Wed;Thu;Fri;Sat',StartDate = Date.valueof(system.now().addDays(-1)),Call_Time__c = '10:00',
                                          Before_After__c = 'After',location__c = loc.id,container__c = 'Equipment',Schedule_Type__c = 'Temporary',
                                          Service_Guarantee_Category__c = 'Days',Service_Guarantee_Category_Value__c = '1',EndDate = null);
        entitlementlist.add(ent);
        entitlementlist.add(ent1);
        entitlementlist.add(ent2);
        return entitlementlist;
    }
    
    public static List<Asset> createAsset(String name, Account acc, Contact con, Product2 prd, User usr, Account loc){
        List<Asset> assetlist = new List<Asset>();
        asset ast = new asset(Name = name, AccountId = loc.Id, ContactId = con.id, product2id = prd.id, OwnerId = usr.id,
                              Location__c = loc.id, Recordtypeid = getRecordType('Service Header','Asset'), Duration__c = 'Temporary',Acorn_SBID__c = 99,Acorn_SID__c='999');
        assetlist.add(ast);
        return assetlist;
    }

    public static Asset returnServiceHeaderAsset(String name, Account acc, Contact con, 
                                                Product2 prod, User usr, Account loc){
        Asset myAsset = new Asset();
        myAsset.Name = name;
        myAsset.AccountId = loc.Id;
        myAsset.ContactId = con.id; 
        myAsset.product2id = prod.id; 
        myAsset.OwnerId = usr.id;
        myAsset.Location__c = loc.id;
        myAsset.Recordtypeid = getRecordType('Service Header','Asset');
        myAsset.Duration__c = 'Temporary';
        myAsset.Acorn_SBID__c = 99;
        myAsset.Acorn_SID__c='999';

        return myAsset;
    }
    
    public static list<Asset> createChildAsset(String Name){
        list<Asset> assetlist = new list<asset>();
        asset ast1 = new asset(Name = name,Recordtypeid = getRecordType('Service Detail','Asset'), Duration__c = 'Temporary',Quantity__c = 1);
        asset ast2 = new asset(Name = name,Recordtypeid = getRecordType('Service Detail','Asset'), Duration__c = 'Temporary',Quantity__c = 1);
        assetlist.add(ast1);
        assetlist.add(ast2);
        return assetlist;
    }
    
 public static Case newServiceCase(String name, Account acc, Contact con, User usr, Account loc){
        Case myCase = new Case(Site_Contact__c = name, Status ='New', Priority = 'Medium', Origin = 'Phone', ContactId = con.id, 
                            AccountId = acc.id, OwnerId = usr.id, Client__c = loc.ParentId, Location__c = loc.id, 
                            Case_Type__c = 'New Service', Case_Sub_Type__c = 'Temporary',Case_Reason__c = 'Baler Repair', 
                            SlaStartDate = System.today(), Recordtypeid = getRecordType('New Service Case','Case'));
        return myCase;
    }
    
    public static Case newModifyExistingCase(String name, Account acc, Contact con, User usr, Account loc){
        Case myCase = new Case(Site_Contact__c = name, Status ='New', Priority = 'Medium', Origin = 'Phone', ContactId = con.id, 
                            AccountId = acc.id, OwnerId = usr.id, Client__c = loc.ParentId, Location__c = loc.id, 
                            Case_Type__c = 'Modify', Case_Sub_Type__c = 'Temporary',Case_Reason__c = 'Baler Repair', 
                            SlaStartDate = System.today(), Recordtypeid = getRecordType('Modify Existing Service Case','Case'));
        return myCase;
    }
    //   public static Opportunity newOpportunity(String name, Account acc, Contact con, User usr, Account loc){

   public static list<Product2> createCPQProduct(string name){
        list<Product2> productlist = new list<Product2>();
        Product2 prd = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT', IsActive = true);
        productlist.add(prd);
       
       
        return productlist;
    }
    
      public static list<Product2> createCPQProduct1(string name){
        list<Product2> productlist = new list<Product2>();
        Product2 prd = new Product2(Name = 'Compactor', Family = 'Equipment', ProductCode = 'OT', IsActive = true);
        productlist.add(prd);
       
       
        return productlist;
    }
    
    public static list<SBQQ__QuoteLine__c> createBundle(Id trashid, Id quoteId, Id productId){
        list<SBQQ__QuoteLine__c> productlist = new list<SBQQ__QuoteLine__c>();
        /*
			quoteBundle.SBQQ__Quote__c = q.Id;
			quoteBundle.SBQQ__Product__c = productlist[0].Id;
			quoteBundle.Equipment_Size__c = 'YRDS-8';
			quoteBundle.SBQQ__Bundle__c = true;
			quoteBundle.Duration__c = 'TEMP';
			quoteBundle.SBQQ__Quantity__c = 1;*/
        	SBQQ__QuoteLine__c prd = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteId, SBQQ__Product__c = productId, Equipment_Size__c = 'YRDS-8', SBQQ__Bundle__c = true, Duration__c = 'TEMP', SBQQ__Quantity__c = 1);
        productlist.add(prd);
        return productlist;
    }
    public static List<Case> createCase(String name, Account acc, Contact con, User usr, Account loc, Asset ast){
        List<Case> caselist = new List<Case>();
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Phone', ContactId = con.id, 
                            AccountId = acc.id, OwnerId = usr.id, Client__c = loc.ParentId, Location__c = loc.id, 
                            assetid = ast.id, Case_Type__c = 'Pickup', Case_Sub_Type__c = 'Extra Pickup', 
                            SlaStartDate = system.today(),Recordtypeid = getRecordType('Pickup Case','Case'));
        Case case1 = new Case(Status ='Pending', Priority = 'Medium', Origin = 'Phone', ContactId = con.id, 
                            AccountId = acc.id, OwnerId = usr.id, Client__c = loc.ParentId, Location__c = loc.id, 
                            assetid = ast.id, Case_Type__c = 'Pickup', Case_Sub_Type__c = 'Extra Pickup', 
                            SlaStartDate = system.today(), Recordtypeid = getRecordType('Pickup Case','Case'));
        Case case2 = new Case(Status ='Open', Priority = 'Medium', Origin = 'Phone', 
                            AccountId = acc.id, OwnerId = usr.id, Client__c = loc.ParentId, Location__c = loc.id, 
                            assetid = ast.id, Case_Type__c = 'Pickup', Case_Sub_Type__c = 'Extra Pickup', 
                            SlaStartDate = system.today(),Recordtypeid = getRecordType('Pickup Case','Case'));
        Case case3 = new Case(Status ='Closed', Priority = 'Medium', Origin = 'Phone', 
                            AccountId = acc.id, OwnerId = usr.id, Client__c = loc.ParentId, Location__c = loc.id, 
                            assetid = ast.id, Case_Type__c = 'Pickup', Case_Sub_Type__c = 'Extra Pickup', 
                            SlaStartDate = system.today(),Recordtypeid = getRecordType('Pickup Case','Case'));
        caselist.add(cas);
        caselist.add(case1);
        caselist.add(case2);
        caselist.add(case3);
        return caselist;
    }

    public static Case returnCase(String name, Account acc, Contact con, User usr, Account loc, Asset ast){
        Case myCase = new Case(Site_Contact__c = name, Status ='New', Priority = 'Medium', Origin = 'Phone', ContactId = con.id, 
                            AccountId = acc.id, OwnerId = usr.id, Client__c = loc.ParentId, Location__c = loc.id, 
                            assetid = ast.id, Case_Type__c = 'Pickup', Case_Sub_Type__c = 'Extra Pickup', 
                            SlaStartDate = System.today(), Recordtypeid = getRecordType('Pickup Case','Case'));
        return myCase;
    }

    public static list<Case> createNewCase(){
        list<Case> newCaselist = new list<Case>();
        Case cas = new Case(Status ='New', Recordtypeid = getRecordType(Constant_Util.PICKUP,'Case'));
        Case case1 = new Case(Status='Open',Recordtypeid = getRecordType(Constant_Util.PICKUP,'Case') );
        newCaselist.add(cas);
        newCaselist.add(case1);
        return newCaselist;
    }
   
    public static list<Case> createNewCasewithAsset(Account acc,Account loc,asset ast){
        list<Case> newCaselist = new list<Case>();
        Case cas = new Case(Status ='New', AccountId = loc.id, Client__c = loc.ParentId, Location__c = loc.id, 
                            assetid = ast.id, Recordtypeid = getRecordType(Constant_Util.SERVICE_REQUEST_CASE,'Case'));
        newCaselist.add(cas);
        return newCaselist;
    }
    
    public static list<Case> createNewCasewithContact(Account acc,Contact con,Account loc,asset ast){
        list<Case> newCaselist = new list<Case>();
        Case cas = new Case(Status ='New', AccountId = loc.id, Client__c = loc.ParentId, Location__c = loc.id,Origin = 'Phone', ContactId = con.id, 
                            assetid = ast.id, Recordtypeid = getRecordType(Constant_Util.SERVICE_REQUEST_CASE,'Case'));
        newCaselist.add(cas);
        return newCaselist;
    }
    
    public static list<Case> createNewCasewithType(Account acc,Contact con,Account loc,asset ast){
        list<Case> newCaselist = new list<Case>();
        Case cas = new Case(Status ='New', AccountId = loc.id, Client__c = loc.ParentId, Location__c = loc.id,Origin = 'Phone', ContactId = con.id, 
                            Case_Type__c = 'Pickup', Case_Sub_Type__c = 'Extra Pickup',assetid = ast.id, Recordtypeid = getRecordType(Constant_Util.SERVICE_REQUEST_CASE,'Case'));
        newCaselist.add(cas);
        return newCaselist;
    }
    
    public static list<Case> createCaseWithoutSLADate(string name, Account acc, Contact con, User usr, Account loc, asset ast){
        list<Case> caselist = new list<Case>();
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Phone', ContactId = con.id, 
                            AccountId = loc.id, OwnerId = usr.id, Client__c = loc.ParentId, Location__c = loc.id, 
                            SLA_Service_Date_Time__c = null,assetid = ast.id, Case_Type__c = 'Pickup', Case_Sub_Type__c = 'Extra Pickup', 
                            Recordtypeid = getRecordType(Constant_Util.SERVICE_REQUEST_CASE,'Case'));
        caselist.add(cas);
        return caselist;
    }
    public static list<task> createTask(Id whatId, User usr){
        List<task> tasklist = new List<task>();
        Task tsk = new Task(OwnerId = usr.id, Subject='test',Status='Open',Priority='Normal',WhatID = whatId,Process__c=Constant_Util.CONFIRM_SERVICE_COMPLETION_LOCATION);
        Task tsk1 = new Task(OwnerId = usr.id, Subject='test',Status='Open',Priority='Normal',WhatID = whatId,Process__c=Constant_Util.CONFIRM_SERVICE_COMPLETION);
        tasklist.add(tsk);
        tasklist.add(tsk1);
        return tasklist;
    }
    
    public static List<WorkOrder> createWorkOrder(Account acc, Contact con, Case caseObj, asset ast){
        List<WorkOrder> workOrderList = new List<WorkOrder>();

        WorkOrder wo = new WorkOrder(AccountId = acc.Id, AssetId = ast.Id, CaseId = caseObj.Id, OwnerId = caseObj.OwnerId, Status = 'New');

        workOrderList.add(wo);
        return workOrderList;
    }

    public static WorkOrder returnWorkOrder(Account acc, Contact con, Case caseObj, asset ast){        
        WorkOrder wo = new WorkOrder(AccountId = acc.Id, AssetId = ast.Id, 
                                    CaseId = caseObj.Id, OwnerId = caseObj.OwnerId, Status = 'New');
        return wo;
    }
    
    public static list<EmailMessage> createEmailMessage(String Subject, String Body, Case caseObj){
        list<EmailMessage> emList = new list<EmailMessage>();
        EmailMessage objEM = new EmailMessage(Subject = Subject, TextBody = Body, ToAddress = 'test@test.com',
                                              FromAddress = 'testfrom@test.com', ParentId = caseObj.Id, Incoming = true);
        emList.add(objEM);
        return emList;
    }
    //create email message with headers
     public static list<EmailMessage> createEmailMessageWithHeader(String Subject, String Body, Case caseObj, String Header){
        list<EmailMessage> emHeaderList = new list<EmailMessage>();
        EmailMessage objEMH1 = new EmailMessage(Subject = Subject, TextBody = Body, ToAddress = 'test@test.com',
                                              FromAddress = 'testfrom@test.com', ParentId = caseObj.Id, Incoming = true,
                                              Headers = Header);
       /* EmailMessage objEMH2 = new EmailMessage(Subject = Subject, TextBody = Body, ToAddress = 'test@test.com',
                                              FromAddress = 'testfrom@test.com', ParentId = caseObj.Id, Incoming = true,
                                              Headers = 'Message-ID: <1234574MB0022227D61A03821A797F3F8F6550@CY4P114MB0022.NAMP114.PROD.OUTLOOK.COM>  In-Reply-To: <1234564MB0022227D61A03821A797F3F8F6550@CY4P114MB0022.NAMP114.PROD.OUTLOOK.COM>');
        
        */ 
        emHeaderList.add(objEMH1);
        //emHeaderList.add(objEMH2); 
        return emHeaderList;
    }
    
    public static list<Messaging.InboundEmail> createinboundemail(string subject,string fromAddress,string plainTextBody){
        List<Messaging.InboundEmail> emaillst = new List<Messaging.InboundEmail>();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = subject;
        email.fromAddress = fromAddress;
        email.plainTextBody = plainTextBody;
        email.htmlBody = plainTextBody;
        email.toAddresses = new List<String>{fromAddress};
        emaillst.add(email);
        return emaillst;
     }
    public static list<Account_Title__c> createAccountTitle(Account acc, String Name){
        list<Account_Title__c> titlelst = new list<Account_Title__c>();
        Account_Title__c title = new Account_Title__c(Name = Name, Status__c = 'Active', Business_Rule_Title__c = true,
                                              Account__c = acc.Id);
        titlelst.add(title);
        return titlelst;
    }
    public static List<Project_Code__c> createProjectCode(Id parentAccId){
        List<Project_Code__c> pCodeList = new List<Project_Code__c>();
        Project_Code__c pCode= new Project_Code__c(Client_Account__c=parentAccId,Name='Test Project Header',Date_Requested__c=System.today(),Container_Type__c = 'Compactor',
                                Effective_Date__c=System.today(),RecordTypeId=getRecordType('Project Code Detail','Project_Code__c'),Duration__c = 'Temporary',Product_Type__c = 'Both');
        pCodeList.add(pCode);
        return pCodeList;
        
    }
    public static list<WorkOrderHistory> WorkOrderHistory(Id WOid) {
        list<WorkOrderHistory> records = new list<WorkOrderHistory>{};
        WorkOrderHistory ah = new WorkOrderHistory(WorkOrderId = WOid,Field = 'Actual_Service_Date__c' );
        WorkOrderHistory ah1 = new WorkOrderHistory(WorkOrderId = WOid,Field = 'Service_Date__c' );
        WorkOrderHistory ah2 = new WorkOrderHistory(WorkOrderId = WOid,Field = 'Fast_Lane_Ticket__c' );
            records.add(ah1);
            records.add(ah2);
            records.add(ah);
        WorkOrderHistory ah4 = new WorkOrderHistory(WorkOrderId = WOid,Field = 'Instructions__c' );
        WorkOrderHistory ah5 = new WorkOrderHistory(WorkOrderId = WOid,Field = 'Manifest_Number__c' );
        WorkOrderHistory ah6 = new WorkOrderHistory(WorkOrderId = WOid,Field = 'MAS_Ticket__c' );
            records.add(ah4);
            records.add(ah5);
            records.add(ah6);
        WorkOrderHistory ah7 = new WorkOrderHistory(WorkOrderId = WOid,Field = 'Pickup_DateTime__c' );
        WorkOrderHistory ah8 = new WorkOrderHistory(WorkOrderId = WOid,Field = 'Profile_Description__c' );
        WorkOrderHistory ah9 = new WorkOrderHistory(WorkOrderId = WOid,Field = 'Profile_Number__c' );
        WorkOrderHistory ah13 = new WorkOrderHistory(WorkOrderId = WOid,Field = 'Profile_Generator__c' );
            records.add(ah7);
            records.add(ah8);
            records.add(ah9);
            records.add(ah13);
        WorkOrderHistory ah10 = new WorkOrderHistory(WorkOrderId = WOid,Field = 'Profile_Purchase_Order__c' );
        WorkOrderHistory ah11 = new WorkOrderHistory(WorkOrderId = WOid,Field = 'Vehicle_Number__c' );
        WorkOrderHistory ah12 = new WorkOrderHistory(WorkOrderId = WOid,Field = 'Return_DateTime__c' );
            records.add(ah10);
            records.add(ah11);
            records.add(ah12);
        return records;
    }
    
    public static list <CaseHistory> CaseHistory(Id caseid){
        list<CaseHistory> records = new list<CaseHistory>();
        CaseHistory ch = new CaseHistory(CaseId = caseid, Field = 'User_Name__c');
        CaseHistory ch1 = new CaseHistory(CaseId = caseid, Field = 'Team_Queue__c');
        CaseHistory ch2 = new CaseHistory(CaseId = caseid, Field = 'Case_Sub_Status__c');
        CaseHistory ch3 = new CaseHistory(CaseId = caseid, Field = 'Status');
        CaseHistory ch4 = new CaseHistory(CaseId = caseid, Field = 'Close_Irrelevant_Case__c');
        CaseHistory ch5 = new CaseHistory(CaseId = caseid, Field = 'Close_Pickup_Case__c');
        CaseHistory ch6 = new CaseHistory(CaseId = caseid, Field = 'Case_Close_Reason__c');
            records.add(ch);
            records.add(ch1);
            records.add(ch2);
            records.add(ch3);
            records.add(ch4);
            records.add(ch5);
            records.add(ch6);
        return records;
    }
    
    public static list <AssetHistory> AssetHistory(Id assetId){
        list<AssetHistory> records = new List <AssetHistory>();
        AssetHistory ah = new AssetHistory(AssetId = assetId, Field = 'Container_Position__c');
        records.add(ah);
        return records;
        
    }

    public static list<WorkOrderLineItem> createWorkOrderLineItem(WorkOrder WO) {
        
        list<WorkOrderLineItem> WorkOrderLineItems = new list<WorkOrderLineItem>();

        WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem();
        WorkOrderLineItem.WorkOrderId = WO.Id ;
        WorkOrderLineItem.Acorn_WOC__c = 1222.0;
        WorkOrderLineItems.add(WorkOrderLineItem);
    
        return WorkOrderLineItems;
    }
public static list<WorkOrderLineItemHistory> WorkOrderLineItemHistory(Id woliId) {
        WorkOrderLineItemHistory h1 = new WorkOrderLineItemHistory(WorkOrderLineItemId = woliId, Field = 'Quantity__c');
        WorkOrderLineItemHistory h2 = new WorkOrderLineItemHistory(WorkOrderLineItemId = woliId, Field = 'Original_Client_Price__c');
        WorkOrderLineItemHistory h3 = new WorkOrderLineItemHistory(WorkOrderLineItemId = woliId, Field = 'New_Client_Price__c');
        WorkOrderLineItemHistory h4 = new WorkOrderLineItemHistory(WorkOrderLineItemId = woliId, Field = 'Reason_Code__c');
        WorkOrderLineItemHistory h5 = new WorkOrderLineItemHistory(WorkOrderLineItemId = woliId, Field = 'Reason_Description__c');
        list<WorkOrderLineItemHistory> historyRecordsLst = new list<WorkOrderLineItemHistory>{h1,h2,h3,h4,h5};
        
        return historyRecordsLst;
    }
	public static list<ExceptionLog__c> createExceptionData()
    {
        List<ExceptionLog__c> escList = new List<ExceptionLog__c>();
        for(Integer i=0;i<= 50;i++)
        {
            ExceptionLog__c exc = new ExceptionLog__c();
            exc.Exception_Type__c = 'System.SObjectException';
            escList.add(exc);
        }
        Database.insert(escList);
        return escList;
    }
    
    public static User createGenesysEnabledUser(Profile P){
        
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, Acorn_SUser_ID__c = 999,
                            TimeZoneSidKey='America/Los_Angeles', UserName='SystemAdministrator'+ String.valueof(system.now().millisecond())+'@testorg.com.wm',IsActive = true,Genesys_Enabled__c = true);
        return usr;
    }

    public static Product2 createProduct(String name, String family, String code){
        Product2 prod = new Product2(Name = name, Family= family, ProductCode= code, IsActive=true, Bypass_Acorn_Integration__c = false);
        return prod;
    }

    public static List<Opportunity> createOpportunity(Integer count, String oppName,Id caseId,String caseSubType, Id locationId){
        List<Opportunity> oppList= new List<Opportunity>();
        for(Integer i=0;i<count;i++){
            Opportunity opp = new Opportunity();
            opp.Name = oppName;
            opp.AccountId = locationId;
            opp.StageName = Constant_Util.PRODUCT_CONFIGURATION;
            opp.CloseDate = date.today() + 4;
            opp.Case__c = caseId;
            opp.Duration__c = caseSubType;
            oppList.add(opp);
        }
        return oppList;
    }

    public static List<SBQQ__Quote__c> createQuoteRecords(Integer count, List<Opportunity> oppList,Account accObj,Contact conObj, Date startDate, Boolean quoteOnlyBol, Boolean projectServicesBol){
        
        List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
        for(Integer i=0;i<count;i++){
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Opportunity2__c = oppList[i].Id;
            quote.SBQQ__Account__c = accObj.Id;
            quote.SBQQ__Status__c = 'Draft';
            quote.PO_Mandatory__c= 'NS_TEMP;NS_PERM;PCK_ER;PCK_EXPCK;PCK_OC';
            quote.Quote_Only__c= quoteOnlyBol;
            quote.Project_Services_Request__c= projectServicesBol;
            quote.SBQQ__StartDate__c= startDate;
            quote.SBQQ__PrimaryContact__c= conObj.Id;
            quoteList.add(quote);
        }
        return quoteList;
    }

    public static List<SBQQ__QuoteLine__c> createQuoteLineRecords(Integer count, SBQQ__Quote__c quoteObj, Product2 prodObj, String durationStr, Decimal quantityDec, String ownershipStr, String equipmentSizeStr, String occurrenceTypeStr, String scheduleFrequencyStr, String frequencyIntervalStr, String pricingMethodStr, Decimal listPriceDec,String priceUOMStr,String costModelTypeStr,Decimal unitCostDec, String costUnitMeasureStr, String scheduleAOverrideStr, String vcrCodeStr){
        List<SBQQ__QuoteLine__c> quoteLineList= new List<SBQQ__QuoteLine__c>();
        for(Integer i=0;i<count;i++){
            SBQQ__QuoteLine__c qlObj= new SBQQ__QuoteLine__c();
            qlObj.SBQQ__Quote__c= quoteObj.Id;
            qlObj.Account__c= quoteObj.SBQQ__Account__c;
            qlObj.SBQQ__StartDate__c= quoteObj.SBQQ__StartDate__c;
            qlObj.SBQQ__Product__c= prodObj.Id;
            qlObj.Duration__c= durationStr;
            qlObj.SBQQ__Quantity__c= quantityDec;
            qlObj.Ownership__c= ownershipStr;
            qlObj.Equipment_Size__c= equipmentSizeStr;
            qlObj.Occurrence_Type__c= occurrenceTypeStr;
            qlObj.Schedule_Frequency__c= scheduleFrequencyStr;
            qlObj.Frequency_Interval__c= frequencyIntervalStr;
            qlObj.SBQQ__PricingMethod__c= pricingMethodStr;
            qlObj.SBQQ__ListPrice__c= listPriceDec;
            qlObj.PriceUOM__c= priceUOMStr;
            qlObj.CostModelType__c= costModelTypeStr;
            qlObj.SBQQ__UnitCost__c= unitCostDec;
            qlObj.Cost_Unit_of_Measure__c= costUnitMeasureStr;
            qlObj.ScheduleAOverride__c= scheduleAOverrideStr;
            qlObj.VCRCode__c= vcrCodeStr;
            quoteLineList.add(qlObj);
        }
        return quoteLineList;
    }

    public static List<SBQQ__Quote__c> createQuoteRecords(List<Opportunity> oppList,Account accObj,Contact conObj, Date startDate, Boolean quoteOnlyBol, Boolean projectServicesBol){
        
        List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Opportunity2__c = oppList[0].Id;
        quote.SBQQ__Account__c = accObj.Id;
        quote.SBQQ__Status__c = 'Draft';
        quote.PO_Mandatory__c= 'NS_TEMP;NS_PERM;PCK_ER;PCK_EXPCK;PCK_OC';
        quote.Quote_Only__c= quoteOnlyBol;
        quote.Project_Services_Request__c= projectServicesBol;
        quote.SBQQ__StartDate__c= startDate;
        quote.SBQQ__PrimaryContact__c= conObj.Id;
        quoteList.add(quote);
        return quoteList;
    }

    public static SBQQ__QuoteLine__c createQuoteLineRecords(SBQQ__Quote__c quoteObj, Product2 prodObj, String durationStr, Decimal quantityDec, String ownershipStr, String equipmentSizeStr, String occurrenceTypeStr, String scheduleFrequencyStr, String frequencyIntervalStr, String pricingMethodStr, Decimal listPriceDec,String priceUOMStr,String costModelTypeStr,Decimal unitCostDec, String costUnitMeasureStr, String scheduleAOverrideStr, String vcrCodeStr){
        //List<SBQQ__QuoteLine__c> quoteLineList= new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qlObj= new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c= quoteObj.Id;
        qlObj.Account__c= quoteObj.SBQQ__Account__c;
        qlObj.SBQQ__StartDate__c= quoteObj.SBQQ__StartDate__c;
        qlObj.SBQQ__Product__c= prodObj.Id;
        qlObj.Duration__c= durationStr;
        qlObj.SBQQ__Quantity__c= quantityDec;
        qlObj.Ownership__c= ownershipStr;
        qlObj.Equipment_Size__c= equipmentSizeStr;
        qlObj.Occurrence_Type__c= occurrenceTypeStr;
        qlObj.Schedule_Frequency__c= scheduleFrequencyStr;
        qlObj.Frequency_Interval__c= frequencyIntervalStr;
        qlObj.SBQQ__PricingMethod__c= pricingMethodStr;
        qlObj.SBQQ__ListPrice__c= listPriceDec;
        qlObj.PriceUOM__c= priceUOMStr;
        qlObj.CostModelType__c= costModelTypeStr;
        qlObj.SBQQ__UnitCost__c= unitCostDec;
        qlObj.Cost_Unit_of_Measure__c= costUnitMeasureStr;
        //qlObj.ScheduleAOverride__c= null;		//TCS-SDT-36171-16-Feb-2024-Commented
        qlObj.ScheduleAOverride__c= 'Do Not Override';	//TCS-SDT-36171-16-Feb-2024-Added a default value
        qlObj.VCRCode__c= null;
        //quoteLineList.add(qlObj);
        return qlObj;
    }

    public static Pricing_Request__c createPricingRequestRecord(Case objCase, Account objAccount, Account objLocation, String lob, String  pricingType, String vendorId, String jsonResponse, User usr)
    {
        Pricing_Request__c pr = new Pricing_Request__c();
        pr.Case__c = objCase.Id;
        pr.Account__c = objAccount.Id;
        pr.Location__c = objLocation.Id;
        pr.Pricing_Type__c = pricingType;
        pr.Service_Country__c = 'United States';
        pr.Service_Postal_Code__c = '48225';
        pr.Service_State__c = 'Michigan';
        pr.Service_City__c = 'Test1';
        pr.Service_Street_Address__c = '20300 KELLY RD';
        if(lob == 'Rolloff')
        {
            pr.Line_of_Business__c = 'Rolloff';
            pr.Container_Type__c = 'OT';
            pr.Container_Size__c = 'YRDS-30';
            pr.Material_Code__c = 'T';
            pr.Service_Type__c = 'TEMP';
            pr.Schedule_or_On_Call__c = 'On-Call';
        }
        else
        {
            pr.Line_of_Business__c = 'Commercial';
            pr.Container_Type__c = 'DMP';
            pr.Container_Size__c = 'YRDS-4';
            pr.Material_Code__c = 'T';
            pr.Service_Type__c = 'PERM';
            pr.Schedule_or_On_Call__c = 'Scheduled';
            pr.Frequency_Type__c ='Weekly';
            pr.Frequency_Count__c = '1';
        }
        if(pricingType == 'AMPO')
        {
            //pr.Vendor_Code__c = vendorId;
            pr.Haul_Cost__c = 30;
            pr.Disposal_Cost__c = 50;
        }
        pr.Quantity__c = 1;
        pr.Industry_Classification__c = '4445';
        pr.Cost_Source__c='WM (SBS|RO|CMP|20C|B02448|20210810|013729|4710)';
        pr.Vendor_Code__c ='10016';
        pr.Vendor_Name__c ='WMI OF MI, LIVONIA';
        pr.APIRequestOutput__c = jsonResponse;
        pr.isAPIResult__c = true;
        pr.CreatedById = usr.Id;

        return pr;
    }

    //Comment:  Method to create entry in VRBatchSetting object
    //Owner: Anup Dey
    //Created on: 10/22/2021
    public static void CreateVRBatchSetting()
    {
        VRBatchSetting__c vrSetting = new VRBatchSetting__c();
        VRSetting.IsBatchExecution__c = false;
        insert VRSetting;
    }
    
    // Create Comment Record
    public static Comment__c createCommentRecord(String caseId,String caseNumber, String Workflow_Action){
        Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
        
        Comment__c note = new Comment__c();
        note.Case__c = caseId;
        note.Comment__c = 'This is a new  - comment';
        note.Communication_Log_Type_Name__c = 'Internal';
        note.Case_Number__c = caseNumber;
        note.recordTypeId = recordTypeId;
        note.Workflow_Action__c = Workflow_Action; 
        note.Workflow_TeamUser__c = System.UserInfo.getName();
        note.Type__c = Constant_Util.OBJECT_CASE;
        note.is_Log__c = true;
        return note;
    }

    /*
    * @vendor			 TCS
    * @story		   	 SDT-29385
    * @author			 Seema Dhikale
    * @description       This method is used to create and return cases of all case types except new service
    * @param             none
    * @return            List of cases of all case types except new service
    */
    public static list<Case> getCasesForAddChange(){
        list<Case> caselist = new list<Case>();
        List<RecordType> caseRecordTypeList=[select id,Name from RecordType where sObjectType='Case' And Name!=:Constant_Util.New_Service_Case];
        List<String> caseRecordTypeNameList=new List<String>();
        for(RecordType recType : caseRecordTypeList)
        {
            caseRecordTypeNameList.add(recType.Name);
            Case c = new Case(Status ='New', Recordtypeid = recType.id);
            caselist.add(c);
        }
		return caselist;
    }

    /*
    * @vendor			 TCS
    * @story		   	 
    * @author			 Manisha Patil
    * @description       This method will be used to setup inital required data to test the methods.
    * @param             none
    * @return            List of User for Customer Service
    */
    public static User getCSRUser(Boolean BypassValidation, Boolean GenesysEnabled){
        User CSRUser = TestUserFactory.getCSRUserDetails(true, false);
        return CSRUser;
    }
}