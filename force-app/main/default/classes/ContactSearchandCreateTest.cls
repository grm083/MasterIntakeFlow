@isTest
public class ContactSearchandCreateTest {
    
    private Static final String STR_Unspecified = 'Unspecified';
    
    @testSetup static void createTestRecords() {
        
        //Customer Account test record insert
        Account cusAcct = new Account();
        RecordType rt2 = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='Client' LIMIT 1];
        Id rtAccount = rt2.Id;
        cusAcct.Name = 'Test Client';
        cusAcct.RecordTypeId = rtAccount;
        insert cusAcct;
        Id cusAcctId = cusAcct.Id;
        
        //Account title record insert
        Account_Title__c act = new Account_Title__c();
        act.Name = 'Test Title';
        act.Account__c = cusAcctId;
        act.Status__c = 'Active';
        insert act;
        Id actId = act.Id;
        String actName = act.Name;
        
        //Contact insert with relationship to Account
        Contact c1 = new Contact();
        c1.FirstName = 'Unspecified';
        c1.LastName = 'Test Client';
        c1.AccountId = cusAcctId;
        c1.Account_Title__c = actId;
        insert c1;
        Id cusAcctContactId = c1.Id;
        
        //Build of supplemental Account Contact Relationship with Customer Account Contact
        /*AccountContactRelation cusAcctACR = new AccountContactRelation();
cusAcctACR.ContactId = cusAcctContactId;
cusAcctACR.AccountId = cusAcctId;
cusAcctACR.Type__c = 'Customer';
cusAcctACR.Account_Title__c = actName;
insert cusAcctACR;*/
        
        //Location Account test record insert
        Account locAcct = new Account();
        RecordType rt1 = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='Location' LIMIT 1];
        Id rtLocation = rt1.Id;
        locAcct.Name = 'TST000123';
        locAcct.RecordTypeId = rtLocation;
        locAcct.ParentId = cusAcctId;
        insert locAcct;
        Id locAcctId = locAcct.Id;
        
        //Contact insert with relationship to location and account
        Contact c2 = new Contact();
        c2.FirstName = 'Test';
        c2.LastName = 'Location';
        c2.AccountId = cusAcctId;
        c2.Account_Title__c = actId;
        insert c2;
        Id locAcctContactId = c2.Id;
        
        //Build of supplemental Account Contact Relationship with Customer and Location Account
        AccountContactRelation locAccACR1 = new AccountContactRelation();
        AccountContactRelation locAccACR2 = new AccountContactRelation();
        /*Customer relationship
locAccACR1.ContactId = locAcctContactId;
locAccACR1.AccountId = cusAcctId;
locAccACR1.Type__c = 'Customer';
locAccACR1.Account_Title__c = actName;
insert locAccACR1;
//Location relationship
locAccACR2.ContactId = locAcctContactId;
locAccACR2.AccountId = locAcctId;
locAccACR2.Type__c = 'Customer';
locAccACR2.Account_Title__c = actName;
insert locAccACR2;*/
        
        //Supplier account insert
        Account supAcct = new Account();
        RecordType rt3 = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='Vendor' LIMIT 1];
        Id rtSupplier = rt3.Id;
        supAcct.Name = 'Test Vendor';
        supAcct.RecordTypeId = rtSupplier;
        insert supAcct;
        Id supAcctId = supAcct.Id;
        
        //Contact insert with relationship to Supplier
        Contact c3 = new Contact();
        c3.FirstName = 'Test';
        c3.LastName = 'Supplier';
        c3.AccountId = supAcctId;
        insert c3;
        Id supAcctContactId = c3.Id;
        
        //Build of supplemental ACR with Supplier Account Contact
        /*AccountContactRelation supAccACR = new AccountContactRelation();
supAccACR.ContactId = supAcctContactId;
supAccACR.AccountId = supAcctId;
supAccACR.Type__c = 'Vendor';
insert supAccACR;*/
        
        //Asset insert tied to location and supplier
        Asset a = new Asset();
        RecordType rt4 = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='Service_Header' LIMIT 1];
        Id rtServHeader = rt4.Id;
        a.Name = 'Test Asset';
        a.AccountId = locAcctId;
        a.Supplier__c = supAcctId;
        insert a;
        Id assetId = a.Id;
        
        //Case insert tied to most of the variables listed above
        Case c = New Case();
        c.Client__c = cusAcctId;
        c.Location__c = locAcctId;
        c.Origin = 'Phone';
        c.AssetId = assetId;
        c.Status = 'New';
        insert c;
       
       
        
    }
    @isTest static void testReturnCase() {
        Case c = [Select Client__c, Location__c, Status, Id FROM Case LIMIT 1];
        Id caseId = c.Id;
        
        Case returnCase = ContactSearchandCreate.returnCase(caseId);
        Case returnCaseLastCreated = ContactSearchandCreate.returnCaseLastCreated(caseId);
        
        System.assertEquals(c, returnCase);
    }
     @isTest static void testSearchLocCont() {
        List<ContactSearchandCreate.allContacts> allLocContacts = new List<ContactSearchandCreate.allContacts>();
        List<ContactSearchandCreate.allContacts> allVenContacts = new List<ContactSearchandCreate.allContacts>();
        
        Case c = [SELECT Client__c, Location__c, Status, Id FROM Case LIMIT 1];
        Id locId = c.Location__c;
        
        allLocContacts = ContactSearchandCreate.searchLocCont(locId);
        allVenContacts = ContactSearchandCreate.getVendorContacts(locId);
        
        System.assert(allLocContacts != Null);
        System.assert(allVenContacts.size() == 0);
    }
    @isTest static void testSearchLocContWithUnspec() {
        List<ContactSearchandCreate.allContacts> allLocContacts = new List<ContactSearchandCreate.allContacts>();        
        Case c = [SELECT Client__c, Location__c, Status, Id FROM Case LIMIT 1];
        List<Contact> cont = [SELECT  Id FROM Contact WHERE FirstName =:STR_Unspecified];
        c.ContactId = cont[0].id;
        Database.update(c);
        Id locId = c.Location__c;
        allLocContacts = ContactSearchandCreate.searchLocCont(locId);
        System.assert(allLocContacts.size() == 0);
    }
      @isTest static void testSearchLocContWithoutUnspec() {
        List<ContactSearchandCreate.allContacts> allLocContacts = new List<ContactSearchandCreate.allContacts>();
        Case c = [SELECT Client__c, Location__c, Status, Id FROM Case LIMIT 1];
        List<Contact> cont = [SELECT  Id FROM Contact WHERE FirstName !=:STR_Unspecified];
        c.ContactId = cont[0].id;
        Database.update(c);
        Id locId = c.Location__c;
        allLocContacts = ContactSearchandCreate.searchLocCont(locId);
        System.assert(allLocContacts.size() != 0);
    }
    @isTest static void testSearchContact() {
        
        List<ContactSearchandCreate.allContacts> allContacts = new List<ContactSearchandCreate.allContacts>();
        String searchQuery = 'Test';
        RecordType cusRT = [SELECT Id FROM RecordType WHERE DeveloperName='Client'];
        List<Contact> cons = [SELECT Name, Id, AccountId FROM Contact WHERE FirstName='Test'];
        system.debug(cons);
        Id cusRTID = cusRT.Id;
        system.debug(searchQuery);
        system.debug(cusRTID);
        Account a = [SELECT Id, Name FROM Account WHERE RecordTypeId=:cusRTID LIMIT 1];
        system.debug(a.Id + a.Name);
        allContacts = ContactSearchandCreate.searchContact(searchQuery, a.Id);
        system.debug(allContacts);
        
        for (ContactSearchandCreate.allContacts ac: allContacts) {
            system.debug(ac.ContactId + ac.Name);
        }
        
        System.assert(allContacts != Null);
        System.assertEquals(allContacts.size(), 0);
    }
    @isTest static void testSearchContacts_AllValue() {
        
        List<ContactSearchandCreate.allContacts> allContacts = new List<ContactSearchandCreate.allContacts>();
        String firstName = 'F1';
        String lastName = 'L1';
        String email = 'e1@wm.com';
        String phone = '4444444444';
        String mobile = '3333333331';
        RecordType cusRT = [SELECT Id FROM RecordType WHERE DeveloperName='Client'];
        List<Contact> cons = [SELECT Name, Id, AccountId FROM Contact WHERE FirstName='F1'];
        system.debug(cons);
        Id cusRTID = cusRT.Id;
        system.debug(firstName);
        system.debug(cusRTID);
        Account a = [SELECT Id, Name FROM Account WHERE RecordTypeId=:cusRTID LIMIT 1];
        Case cs = [SELECT Id FROM Case LIMIT 1];
        system.debug(a.Id + a.Name);
        allContacts = ContactSearchandCreate.searchContacts(firstName, lastName, email, phone, mobile, a.Id,cs.id);
        system.debug(allContacts);
        
        for (ContactSearchandCreate.allContacts ac: allContacts) {
            system.debug(ac.ContactId + ac.Name);
        }
        
        System.assert(allContacts != Null);
        System.assertEquals(allContacts.size(), 0);
    }
    @isTest static void testSearchContacts_WithNoName() {
        
        List<ContactSearchandCreate.allContacts> allContacts = new List<ContactSearchandCreate.allContacts>();
        String firstName = '';
        String lastName = '';
        String email = 'e1@wm.com';
        String phone = '4444444444';
        String mobile = '3333333331';
        RecordType cusRT = [SELECT Id FROM RecordType WHERE DeveloperName='Client'];
        List<Contact> cons = [SELECT Name, Id, AccountId FROM Contact WHERE FirstName='F1'];
        system.debug(cons);
        Id cusRTID = cusRT.Id;
        system.debug(firstName);
        system.debug(cusRTID);
        Account a = [SELECT Id, Name FROM Account WHERE RecordTypeId=:cusRTID LIMIT 1];
        system.debug(a.Id + a.Name);
        Case cs = [SELECT Id FROM Case LIMIT 1];
        allContacts = ContactSearchandCreate.searchContacts(firstName, lastName, email, phone, mobile, a.Id,cs.id);
        system.debug(allContacts);
        
        for (ContactSearchandCreate.allContacts ac: allContacts) {
            system.debug(ac.ContactId + ac.Name);
        }
        
        System.assert(allContacts != Null);
        System.assertEquals(allContacts.size(), 0);
    }
    @isTest static void testSearchContacts_WithNoEmail() {
        
        List<ContactSearchandCreate.allContacts> allContacts = new List<ContactSearchandCreate.allContacts>();
        String firstName = 'F1';
        String lastName = 'L1';
        String email = '';
        String phone = '4444444444';
        String mobile = '3333333331';
        RecordType cusRT = [SELECT Id FROM RecordType WHERE DeveloperName='Client'];
        List<Contact> cons = [SELECT Name, Id, AccountId FROM Contact WHERE FirstName='F1'];
        system.debug(cons);
        Id cusRTID = cusRT.Id;
        system.debug(firstName);
        system.debug(cusRTID);
        Account a = [SELECT Id, Name FROM Account WHERE RecordTypeId=:cusRTID LIMIT 1];
        system.debug(a.Id + a.Name);
        Case cs = [SELECT Id FROM Case LIMIT 1];
        allContacts = ContactSearchandCreate.searchContacts(firstName, lastName, email, phone, mobile, a.Id,cs.id);
        system.debug(allContacts);
        
        for (ContactSearchandCreate.allContacts ac: allContacts) {
            system.debug(ac.ContactId + ac.Name);
        }
        
        System.assert(allContacts != Null);
        System.assertEquals(allContacts.size(), 0);
    }
    @isTest static void testSearchContacts_WithNoPhone() {
        
        List<ContactSearchandCreate.allContacts> allContacts = new List<ContactSearchandCreate.allContacts>();
        String firstName = 'F1';
        String lastName = 'L1';
        String email = 'e1@wm.com';
        String phone = '';
        String mobile = '3333333331';
        RecordType cusRT = [SELECT Id FROM RecordType WHERE DeveloperName='Client'];
        List<Contact> cons = [SELECT Name, Id, AccountId FROM Contact WHERE FirstName='F1'];
        system.debug(cons);
        Id cusRTID = cusRT.Id;
        system.debug(firstName);
        system.debug(cusRTID);
        Account a = [SELECT Id, Name FROM Account WHERE RecordTypeId=:cusRTID LIMIT 1];
        system.debug(a.Id + a.Name);
        Case cs = [SELECT Id FROM Case LIMIT 1];
        allContacts = ContactSearchandCreate.searchContacts(firstName, lastName, email, phone, mobile, a.Id,cs.id);
        system.debug(allContacts);
        
        for (ContactSearchandCreate.allContacts ac: allContacts) {
            system.debug(ac.ContactId + ac.Name);
        }
        
        System.assert(allContacts != Null);
        System.assertEquals(allContacts.size(), 0);
    }
    @isTest static void testSearchContacts_WithNoFNMobile() {
        
        List<ContactSearchandCreate.allContacts> allContacts = new List<ContactSearchandCreate.allContacts>();
        String firstName = '';
        String lastName = 'L1';
        String email = 'e1@wm.com';
        String phone = '4444444444';
        String mobile = '';
        RecordType cusRT = [SELECT Id FROM RecordType WHERE DeveloperName='Client'];
        List<Contact> cons = [SELECT Name, Id, AccountId FROM Contact WHERE FirstName='F1'];
        system.debug(cons);
        Id cusRTID = cusRT.Id;
        system.debug(firstName);
        system.debug(cusRTID);
        Account a = [SELECT Id, Name FROM Account WHERE RecordTypeId=:cusRTID LIMIT 1];
        system.debug(a.Id + a.Name);
        Case cs = [SELECT Id FROM Case LIMIT 1];
        allContacts = ContactSearchandCreate.searchContacts(firstName, lastName, email, phone, mobile, a.Id,cs.id);
        system.debug(allContacts);
        
        for (ContactSearchandCreate.allContacts ac: allContacts) {
            system.debug(ac.ContactId + ac.Name);
        }
        
        System.assert(allContacts != Null);
        System.assertEquals(allContacts.size(), 0);
    }    
    @isTest static void testSearchVendors() {
        
        List<ContactSearchandCreate.allVendors> allVendors = new List<ContactSearchandCreate.allVendors>();
        String searchQuery = 'Test';
        
        allVendors = ContactSearchandCreate.searchVendors(searchQuery);
        
    }
    @isTest static void testReturnVendors() {
        List<ContactSearchandCreate.allVendors> allVendors = new List<ContactSearchandCreate.allVendors>();
        
        RecordType locRT = [SELECT Id FROM RecordType WHERE DeveloperName='Location'];
        Account loc = [SELECT Id, Name FROM Account WHERE RecordTypeId=:locRT.Id LIMIT 1];
        
        allVendors = ContactSearchandCreate.returnVendors(loc.Id);
        
        allVendors.add(new ContactSearchandCreate.allVendors(loc.Id,
                                                             'Test Vendor',
                                                             '123456'));
        
        System.assert(allVendors != Null);
        System.assertEquals(allvendors.size(), 1);
    }
    @isTest static void testAllContactsWrapper() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        ContactSearchandCreate.allContacts allContacts = new ContactSearchandCreate.allContacts(
            con.Id, 'Test Wrapper', 'Test Title', 'Test Company', '1234567890', 'test@test.test',null,system.today());
        
        system.assertEquals(allContacts.ContactId, con.Id);
        system.assertEquals(allContacts.Name, 'Test Wrapper');
        system.assertEquals(allContacts.Title, 'Test Title');
        system.assertEquals(allContacts.Company, 'Test Company');
        system.assertEquals(allContacts.Phone, '1234567890');
        system.assertEquals(allContacts.Email, 'test@test.test');
    }  
    @isTest static void testAllVendorsWrapper() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        ContactSearchandCreate.allVendors allVendors = new ContactSearchandCreate.allVendors(
            acc.Id, 'Test Class', '123456789');
        
        system.assertEquals(allVendors.AccountId, acc.Id);
        system.assertEquals(allVendors.Name, 'Test Class');
        system.assertEquals(allVendors.VID, '123456789');
    }
    @isTest static void testDualList() {
        ContactSearchandCreate.dualList DL = new ContactSearchandCreate.dualList('label', 'name');
        
        system.assertEquals(DL.label, 'label');
        system.assertEquals(DL.value, 'name');
    }
    @isTest static void testExistingContact() {
        RecordType supplierRec = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='Vendor' LIMIT 1];
        Case c = [SELECT Id, ContactId, Requested_By_User__c, AccountId, Client__c, Location__c
                  FROM Case
                  LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        Account supA = [Select Id, RecordtypeId FROM Account WHERE RecordTypeId = :supplierRec.id];
        Contact supCon = [SELECT Id, AccountId FROM Contact WHERE AccountId = :supA.Id];
        Integer ACROldCount;
        Integer ACRNewCount;
        
        List<String> types = new List<String>();
        types.add('Customer');
        types.add('Vendor');
        
        for (String t : types) {
            if (t == 'Customer') {
                List<AccountContactRelation> ACROld = [SELECT Id FROM AccountContactRelation
                                                       WHERE ContactId=:con.Id AND AccountId=:a.Id];
                ACROldCount = ACROld.Size();
                ContactSearchandCreate.existingContact(c.Id, con.Id, a.Id, t);
                c = [SELECT Id, ContactId, Requested_By_User__c, AccountId, Client__c, Location__c
                     FROM Case
                     LIMIT 1];
                system.assertEquals(c.ContactId, con.Id);
                system.assert(c.Requested_By_User__c == Null);
                List<AccountContactRelation> ACR = [SELECT Id FROM AccountContactRelation
                                                    WHERE ContactId=:con.Id AND AccountId=:a.Id];
                ACRNewCount = ACR.Size();
                If (ACROld.isEmpty()) {
                    system.assertEquals(ACR.Size(), 1);
                } else {
                    system.assertEquals(ACROldCount, ACRNewCount);
                }
                system.assert(ACR.size() == 1);
            } else if (t == 'Vendor') {
                ContactSearchandCreate.existingContact(c.Id, supcon.Id, supa.Id, t);
                c = [SELECT Id, ContactId, Requested_By_User__c, AccountId, Client__c, Location__c
                     FROM Case
                     LIMIT 1];
                system.assertEquals(c.ContactId, supcon.Id);
                system.assert(c.Requested_By_User__c == Null);
                List<AccountContactRelation> ACR = [SELECT Id FROM AccountContactRelation
                                                    WHERE ContactId=:con.Id AND AccountId=:a.Id];
                system.assert(ACR.size() == 1);
            }
        }
    }
    @isTest static void testGetVendorRoles() {
        List<ContactSearchandCreate.dualList> venRoles = new List<ContactSearchandCreate.dualList>();
        
        venRoles = ContactSearchandCreate.getVendorRoles();
        
        system.assert(venRoles.size() != 0);
    }
    @isTest static void testGetAccountTitlesandDepts() {
        RecordType rtAcct = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='Client'];
        Account act = [SELECT Id, Name FROM Account WHERE RecordTypeId=:rtAcct.Id LIMIT 1];
        
        List<ContactSearchandCreate.dualList> acctTitles = new List<ContactSearchandCreate.dualList>();
        List<ContactSearchandCreate.dualList> acctDepts = new List<ContactSearchandCreate.dualList>();
        
        acctTitles = ContactSearchandCreate.getAccountTitles(act.Id);
        acctDepts = ContactSearchandCreate.getAccountDepts(act.Id);
        
        System.assertEquals(acctTitles.size(), 1);
        system.assertEquals(acctDepts.size(), 0);
        
        Id methodACTId = ContactSearchandCreate.newTitle(act.Id, 'New Test Title');
        
        system.assert(methodACTId != Null);
    }
    @isTest static void testNewContact() {
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Account_Title__c act = [SELECT Id FROM Account_Title__c LIMIT 1];
         Case c = [Select Client__c, Location__c, Status, Id FROM Case LIMIT 1];
        Id caseId = c.Id;
        
        Id conId = ContactSearchandCreate.createNewContact('Test', 'Test', acct.Id,caseId, '1234567890', 'test@test.test', act.id, '', 'phone','123');
        Id venconId = ContactSearchandCreate.createNewVenContact('Test', 'Test', acct.Id, '1234567890', 'test@test.test', 'phone','123');
        
        system.assert(conId != Null);
        system.assert(venconId != Null);
    }
    @isTest static void testGetAccountTeam() {
        User u = [SELECT Id, Name, CompanyName, Phone, Email FROM User WHERE Name='George Martin' LIMIT 1];
        Account a = [Select Id FROM Account LIMIT 1];
        
        String search = u.Email;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.UserId = u.Id;
        atm.TeamMemberRole = 'Program Manager';
        atm.AccountId = a.Id;
        insert atm;
        
        List<ContactSearchandCreate.allContacts> atmMembers = new List<ContactSearchandCreate.allContacts>();
        
        atmMembers = ContactSearchandCreate.getAccountTeam(a.Id);
        
        system.assertEquals(atmMembers[0].ContactId, u.Id);
        system.assertEquals(atmMembers[0].Name, u.Name);
        system.assertEquals(atmMembers[0].Title, 'Program Manager');
        system.assertEquals(atmMembers[0].Company, u.CompanyName);
        system.assertEquals(atmMembers[0].Phone, u.Phone);
        system.assertEquals(atmMembers[0].Email, u.Email);
        
        List<ContactSearchandCreate.allContacts> searchUsers = new List<ContactSearchandCreate.allContacts>();
        
        searchUsers = ContactSearchandCreate.getUsers(search);
        system.debug(searchUsers);
        
        system.assert(searchUsers != Null);
    }
    @isTest static void testInternalUser() {
        Id internalConId;
        Id methodId;
        
        List<Contact> conList = [SELECT Id, FirstName, LastName
                                 FROM Contact
                                 WHERE FirstName='Internal' AND LastName='User'];
        
        if (conList.size() > 0) {
            internalConId = conList[0].Id;
            methodId = ContactSearchandCreate.internalContact();
            system.assertEquals(methodId, internalConId);
        } else {
            methodId = ContactSearchandCreate.internalContact();
            system.assert(methodId != Null);
        }
        
        Case c = [SELECT Id, ContactId, Requested_By_User__c
                  FROM Case
                  LIMIT 1];
        
        User u = [SELECT Id FROM User LIMIT 1];
        
        ContactSearchandCreate.saveUserToCase(c.Id, u.Id);
        
        c = [SELECT ContactId, Requested_By_User__c FROM Case WHERE Id=:c.Id];
        
        System.assertNotEquals(c.ContactId, methodId);
        System.assertEquals(c.Requested_By_User__c, u.Id);
        
    }
    
    @isTest static void testVendorContactInsert(){
        RecordType supplierRec = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='Vendor' LIMIT 1];
        Account acc = [SELECT Id, RecordTypeId FROM Account Where RecordTypeId  = :supplierRec.id LIMIT 1];
        
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
    }
    @isTest static void testAllSearchContactsWrapper() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        ContactSearchandCreate.allSearchContacts allContacts = new ContactSearchandCreate.allSearchContacts(
            con.Id, 'Test Wrapper', 'Test Title', 'Test Company', '1234567890', 'test@test.test','1234567891');
        
        system.assertEquals(allContacts.ContactId, con.Id);
        system.assertEquals(allContacts.Name, 'Test Wrapper');
        system.assertEquals(allContacts.Title, 'Test Title');
        system.assertEquals(allContacts.Company, 'Test Company');
        system.assertEquals(allContacts.Phone, '1234567890');
        system.assertEquals(allContacts.Email, 'test@test.test');
    }
    
    @isTest static void testDuplicateContacts() {
        
        List<ContactSearchandCreate.allContacts> allContacts = new List<ContactSearchandCreate.allContacts>();
        String firstName = 'F1';
        String lastName = 'L1';
        String email = 'e1@wm.com';
        String phone = '4444444444';
        String mobile = '3333333331';
        RecordType cusRT = [SELECT Id FROM RecordType WHERE DeveloperName='Client'];
        List<Contact> cons = [SELECT Name, Id, AccountId FROM Contact WHERE FirstName='F1'];
        Id cusRTID = cusRT.Id;
        Account a = [SELECT Id, Name FROM Account WHERE RecordTypeId=:cusRTID LIMIT 1];
        Case cs = [SELECT Id FROM Case LIMIT 1];
        Account_Title__c acctTitle = [SELECT Id FROM Account_Title__c LIMIT 1];
        allContacts = ContactSearchandCreate.checkDuplicateContacts(firstName, lastName, email, phone, mobile, a.Id,acctTitle.id,'Test Department','Test Preferred','Test extension',cs.id);
        System.assert(allContacts != Null);
    }
    
     
}