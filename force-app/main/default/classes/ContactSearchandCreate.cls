public with sharing class ContactSearchandCreate {
        
    private Static final String STR_Unspecified = 'Unspecified';
    
    @AuraEnabled //Returns the case record and relevant fields
    public static Case returnCase(Id recordId) {
        //Initialization protocol where the case details are returned to the component
        Case c = [Select Client__c, Location__c, Supplier__c, Status, ContactId, Case_Sub_Type__c, Requested_By_User__c 
                  FROM Case WHERE Id=:recordId];
        
        return c;
    }
    
     @AuraEnabled //Returns the case record and relevant fields
    public static Case returnCaseLastCreated(Id recordId) {
        //Initialization protocol where the case details are returned to the component
        //
        //Select Client__c, Location__c, Status, CreatedDate, ContactId, Requested_By_User__c FROM Case ORDER BY CreatedDate DESC
        Case c = [Select Client__c, Location__c, CreatedDate, ContactId, Requested_By_User__c FROM Case WHERE Id=:recordId ORDER BY CreatedDate DESC];
        
        return c;
    }
    
    @AuraEnabled //Returns all contacts with a relationship to the location
    public static List<allContacts> searchLocCont(Id locId) {
        List<allContacts> locContacts = new List<allContacts>();
        Set<ID> set_ContactID = new Set<ID>();
        List<Contact> qryRes1 = new List<Contact>();
        List<Account> acc = [Select Id , RecordType.name FROM Account where Id = :locId];
        if(acc != null && !acc.isEmpty() && acc[0].RecordType.Name.equals(Constant_Util.CLIENT)){
             qryRes1 = [SELECT id, Name,FirstName,LastName,AccountNameForContact__c, Tech_Contact_Account_Title__c,
                                         Phone, Account.Name,email,Business_Rule_Association__c FROM Contact
                                         WHERE Account.RecordType.Name='Client' AND AccountId = :locId order by Last_Activity_Date__c DESC NULLS LAST LIMIT 500];
           
        } else {
             qryRes1 = [SELECT id, Name,FirstName,LastName,AccountNameForContact__c, Tech_Contact_Account_Title__c,
                                         Phone, Account.Name,email,Business_Rule_Association__c FROM Contact
                                         WHERE Account.RecordType.Name='Client' AND id IN (SELECT ContactID from Case where Location__c=:locId) order by Last_Activity_Date__c DESC NULLS LAST LIMIT 500];           
        }        
        for (Contact con: qryRes1) {        
            if(!(STR_Unspecified.equalsIgnoreCase(con.FirstName) && (con.LastName).equalsIgnoreCase(con.AccountNameForContact__c))){
                locContacts.add(new allContacts(con.id, con.Name, con.Tech_Contact_Account_Title__c, con.Account.Name, con.Phone, con.email, con.Business_Rule_Association__c, Null));
              }
        }             
        system.debug('locContacts------>'+locContacts);
        return locContacts;
    }
    
    @AuraEnabled //Searches for contacts using SOSL
    public static List<allContacts> searchContact(String searchQuery, Id acct) {
        
        List<allContacts> allContacts = new List<allContacts>();
        
        system.debug(searchQuery);
        system.debug(acct);
        
        //SOSL to return a list of lists with the query results
        List<List<sObject>> qryRes = [FIND :searchQuery IN ALL FIELDS
                            RETURNING Contact(Id, Name, FirstName, LastName, Phone,
                                             MobilePhone,Email,Preferred_Method__c,
                                             Contact_Status__c,Account_Title__r.Name, Account.Name
                                             WHERE (AccountId=:acct OR Location__c=:acct))];
        
        //SOSL only returns contacts, so we will grab the first instance of
        //lists from the list of lists
        List<Contact> conList = (Contact[])qryRes[0];
        
        for (Contact con : conList) {
            system.debug(con);
            allContacts.add(new allContacts(con.Id,con.Name,con.Account_Title__r.Name,con.Account.Name,con.Phone,con.Email, Null, Null));
        }
        return allContacts;
    }
    @AuraEnabled //Searches for contacts using SOQL -- SDT-10964
    public static List<allContacts> searchContacts(String firstName, String lastName, String email, String phone, String mobile, Id acct, String caseId) {
        
        List<allContacts> allContacts = new List<allContacts>();
        
        system.debug(firstName);
        system.debug(lastName);
        system.debug(acct);
        
        //SOSL to return a list of lists with the query results
        /*List<List<sObject>> qryRes = [FIND :firstName IN Name FIELDS 
                            RETURNING Contact(Id, Name, FirstName, LastName, Phone,
                                             MobilePhone,Email,Preferred_Method__c,
                                             Contact_Status__c,Account_Title__r.Name, Account.Name
                                             WHERE (AccountId=:acct OR Location__c=:acct OR AccountId=''))];*/
        
        String firstNameText = firstName.trim()+'%';
        String lastNameText = lastName.trim()+'%';
        //(FirstName Like :firstNameText AND LastName Like :lastNameText)
        /*List<Contact> conList = [Select Id, Name, FirstName, LastName, Phone, MobilePhone, Email, Preferred_Method__c
                                      , Contact_Status__c, Account_Title__r.Name, Account.Name 
                                      from contact
                                      Where ((FirstName = :firstNameText AND LastName = :lastNameText)
                                      OR (Email != '' OR Email = :email)
                                      OR (Phone != '' OR Phone = :phone) 
                                      OR (MobilePhone != '' OR MobilePhone = :mobile))
                                      AND (AccountId=:acct OR Location__c=:acct)];*/
        //SOSL only returns contacts, so we will grab the first instance of
        //lists from the list of lists
        //List<Contact> conList = (Contact[])qryRes[0];
        Boolean isInclude = false;
        
        Id loc = [SELECT Id, ContactId, Location__c, Client__c FROM Case WHERE Id =: caseId].Location__c;
       
          String qry = 'SELECT Id, Name, FirstName, LastName,AccountNameForContact__c, Phone, MobilePhone, Email, Preferred_Method__c, Contact_Status__c, Account_Title__r.Name, Account.Name,Business_Rule_Association__c FROM contact WHERE'; 
        
	  if(String.isNotBLANK(acct) && String.isNotBLANK(lastName) && String.isNotBLANK(firstName)){
                qry += ' (((AccountId=:acct AND AccountId != null) OR (Location__c=: loc AND Location__c != null)) AND (LastName Like :lastNameText OR FirstName Like :firstNameText))';
               
                isInclude = true;
            }
            else if(String.isNotBLANK(acct) && String.isNotBLANK(lastName)){
                qry += ' (((AccountId=:acct AND AccountId != null) OR (Location__c=: loc AND Location__c != null)) AND LastName Like :lastNameText)';
                isInclude = true;
            }
            else if(String.isNotBLANK(acct) && String.isNotBLANK(firstName)){
                qry += ' (((AccountId=:acct AND AccountId != null) OR (Location__c=: loc AND Location__c != null)) AND FirstName Like :firstNameText)';
                isInclude = true;
            }
            else if(String.isNotBLANK(acct) && String.isBlank(lastName) && String.isBlank(firstName)){
                qry += ' ((AccountId=:acct AND AccountId != null) OR (Location__c=: loc AND Location__c != null))';
            
            
            if(String.isNotBLANK(email)){
                qry += ' AND Email =: email';  
            }
            if(String.isNotBLANK(phone)){
                qry += ' AND Phone =: phone'; 
            }
            if(String.isNotBLANK(mobile)){
                qry += ' AND MobilePhone =: mobile'; 
            }
            isInclude = false;
        }

            
        if(isInclude == true){
            if(String.isNotBLANK(email)){
                qry += ' OR Email =: email'; 
            }
            if(String.isNotBLANK(phone)){
                qry += ' OR Phone =: phone'; 
            }
            if(String.isNotBLANK(mobile)){
                qry += ' OR MobilePhone =: mobile'; 
            }
        }
        
        System.debug('>>>>qry'+qry);
        
        List<Contact> conList = Database.query(qry);
        
        for(Contact con : conList) {
            if(!(STR_Unspecified.equalsIgnoreCase(con.FirstName) && (con.LastName).equalsIgnoreCase(con.AccountNameForContact__c))){
                allContacts.add(new allContacts(con.Id,con.Name,con.Account_Title__r.Name,con.Account.Name,con.Phone,con.Email, con.Business_Rule_Association__c, Null));
        
            }
            }
        return allContacts;
    }    

    @AuraEnabled
    public static List<allVendors> searchVendors(String searchQuery) {
        List<allVendors> allVendors = new List<allVendors>();
        RecordType accountRT = [SELECT Id, Name FROM RecordType WHERE DeveloperName='Vendor'];
        List<String> badVendors = getInvalidVendors();
        
        List<List<sObject>> qryRes = [FIND :searchQuery in NAME FIELDS
                                     RETURNING Account(Id, Name, Vendor_ID__c
                                                      WHERE RecordTypeId=:accountRT.Id AND
                                                      Vendor_ID__c not in:badVendors)];
        
        List<Account> venList = (Account[])qryRes[0];

        for (Account v : venList) {
            allVendors.add(new allVendors(v.ID, v.Name, v.Vendor_ID__c));
        }
        
        return allVendors;
    }    
    @AuraEnabled //Returns all location vendors based on Asset history
    public static List<allVendors> returnVendors(Id acct) {

        List<allVendors> allVendors = new List<allVendors>();
        List<String> badVendors = getInvalidVendors();
        
        //This query is record type dependent, so we need to obtain
        //our record types for Assets and Accounts by query
        RecordType assetRT = [SELECT Id, Name FROM RecordType WHERE DeveloperName='Service_Header'];
        RecordType accountRT = [SELECT Id, Name FROM RecordType WHERE DeveloperName='Vendor'];
        Id servHeader = assetRT.Id;
        Id vendor = accountRT.Id;
        
        //Return all assets
        List<Asset> assets = [SELECT Id, Supplier__c FROM Asset WHERE RecordTypeId=:servHeader AND Location__c=:acct
                             AND Supplier__c != Null AND Supplier__r.Vendor_ID__c Not In:badVendors];
        
        //Store all supplier Ids in a list for query purposes
        List<String> supplierIds = new List<String>();
        For (Asset a : assets) {
            if (!supplierIds.contains(a.Supplier__c)) {
                supplierIds.add(a.Supplier__c);
            }
        }
        
        //Return all vendors based on the supplier Ids in the assets 
        List<Account> vendors = [SELECT Id, Name, Vendor_ID__c FROM Account WHERE Id IN :supplierIds ORDER BY Name];
        
        for (Account v : vendors) {
            allVendors.add(new allVendors(v.ID, v.Name, v.Vendor_ID__c));
        }
        
        system.debug(allVendors);
        return allVendors;
    }
    
    @AuraEnabled //Saves an existing contact to the case, and validates the relationships
    public static Boolean existingContact(Id caseId, Id contactId, Id accountId, String type) {
			
			 Boolean isInActive = false;
             Contact con = [SELECT FirstName, LastName, Phone,Contact_Status__c, Email, Account_Title__r.Name, Account_Title__r.Status__c, Account_Department__r.Name
                          FROM Contact
                          WHERE Id=:contactId];
			if(con.Account_Title__r.status__c != 'Inactive')
            {
            Id loc = [SELECT Id, ContactId, Location__c, Client__c FROM Case WHERE Id=:caseId].Location__c;
            if(con.Contact_Status__c != 'Active'){
                con.Contact_Status__c = 'Active';
               }   
            if(accountId != null) {
                con.AccountId = accountId ;
            }   
            
            //con.Location__c = loc;
            //system.debug('currentLocation@@@@@@@@@@' +con.Location__c);
                update con;
            
            Case c = [SELECT Id, ContactId, Location__c, Client__c FROM Case WHERE Id=:caseId];
            
            c.ContactId = contactId;
            c.Requested_By_User__c = null;
            
            if (type == 'Customer') {
                if(c.Client__c != null && c.Location__c != null) {
                    custRelationshipCheck(contactId, c.Client__c, c.Location__c, type);
                }         
            } else if (type == 'Vendor') {
                if(accountId != null) {
                    vendRelationshipCheck(contactId, accountId, type);
                }    
            }
     
            update c;
			}
            else
            {
                isInActive = true;
            }
            return isInActive;
			
      }
    //Validates the customer relationships to accounts
    public static void custRelationshipCheck(Id contactId, Id accountId, Id locationId, String type) {
        
        Contact con = [SELECT FirstName, LastName, Phone, Email, Account_Title__r.Name, Account_Department__r.Name
                      FROM Contact
                      WHERE Id=:contactId];
        
        List<AccountContactRelation> AccountRel = [SELECT AccountId, Account_Title__c, Roles, Type__c, ContactId
                                     FROM AccountContactRelation
                                     WHERE ContactId=:contactId AND AccountId=:accountId];
        If (AccountRel.isEmpty()) {
            AccountContactRelation accACR = new AccountContactRelation();
            accACR.AccountId = accountId;
            accACR.Account_Title__c = con.Account_Title__c;
            accACR.Type__c = type;
            accACR.ContactId = contactId;
            
            insert accACR;
            system.debug(accACR.Id);
        }
        
        List<AccountContactRelation> LocationRel = [SELECT AccountId, Account_Title__c, 
                                                    Roles, Type__c, ContactId
                                                    FROM AccountContactRelation
                                                    WHERE ContactId=:contactId AND AccountId=:locationId];
        if (LocationRel.isEmpty()) {
            AccountContactRelation locACR = new AccountContactRelation();
            locACR.AccountId = locationId;
            locACR.Account_Title__c = con.Account_Title__c;
            locACR.Type__c = type;
            locACR.ContactId = contactId;
            
            insert locACR;
            system.debug(locACR.Id);
        }
    }
    //Validates the vendor relationships to accounts
    public static void vendRelationshipCheck(Id contactId, Id accountId, String type) {
        
        Contact con = [SELECT FirstName, LastName, Phone, Email, Account_Title__r.Name, Account_Department__r.Name
                      FROM Contact
                      WHERE Id=:contactId];
        
        List<AccountContactRelation> AccountRel = [SELECT AccountId, Account_Title__c, Roles, Type__c, ContactId
                                     FROM AccountContactRelation
                                     WHERE ContactId=:contactId AND AccountId=:accountId];
        If (AccountRel.isEmpty()) {
            AccountContactRelation accACR = new AccountContactRelation();
            accACR.AccountId = accountId;
            accACR.Account_Title__c = con.Account_Title__c;
            accACR.Type__c = type;
            accACR.ContactId = contactId;
            
            insert accACR;
            system.debug(accACR.Id);
        }
    }
    @AuraEnabled //Pulls the vendor roles from the ACR object
    public static List<dualList> getVendorRoles() {
        List<dualList> venRole = new List<dualList>();
        Schema.DescribeFieldResult fieldResult = AccountContactRelation.Roles.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple ) {
            venRole.Add(new dualList(pickListVal.getLabel(), pickListVal.getValue()));
        }
        system.debug(venRole);
        return venRole;
    }
    @AuraEnabled //Queries and returns the customer account titles
    public static List<dualList> getAccountTitles(Id acct) {
        List<dualList> acctTitles = new List<dualList>();
        
        List<Account_Title__c> act = [SELECT Id, Name, Account__c
                                    FROM Account_Title__c
                                    WHERE Account__c =: acct AND Status__c = 'Active'
                                    ORDER BY Name];
        
        for (Account_Title__c titles : act) {
            acctTitles.add(new dualList(titles.Name, titles.Id));
        }        
        return acctTitles;
    }
    @AuraEnabled //Queries and returns the customer departments
    public static List<dualList> getAccountDepts(Id acct) {
        List<dualList> acctDepts = new List<dualList>();
        
        List<Department__c> acd = [SELECT Id, Name
                                  FROM Department__c
                                  WHERE Account__c =:acct];
        
        for (Department__c d : acd) {
            acctDepts.add(new dualList(d.Name, d.Id));
        }
        return acctDepts;
    }
    @AuraEnabled //Create new account title
    public static Id newTitle(Id acct, String title) {
        
        Account_Title__c act = new Account_Title__c();
        
        act.Account__c = acct;
        act.Name = title;
        act.Status__c = 'Active';
        
        insert act;
        
        Id actId = act.Id;
        
        return actId;
        
    }
    @AuraEnabled //Based on selected vendor Id, returns all known contacts from the ACR
    public static List<allContacts> getVendorContacts(Id vendor) {
        List<allContacts> vendorContacts = new List<allContacts>();
          
        List<AccountContactRelation> qryRes = [SELECT ContactId, Contact.Name, Contact.FirstName,
                                               Contact.LastName, Contact.Phone, Contact.MobilePhone,
                                               Contact.Preferred_Method__c, Contact.Contact_Status__c,
                                               Contact.Account_Title__r.Name, Contact.Account.Name, Contact.Email, 
                                               Type__c, Roles
                                               FROM AccountContactRelation
                                               WHERE AccountId=:vendor
                                               ORDER BY Contact.Name];
        
        for (AccountContactRelation Rcon: qryRes) {
            vendorContacts.add(new allContacts(Rcon.ContactId,Rcon.Contact.Name,Rcon.Roles, Rcon.Contact.Account.Name,Rcon.Contact.Phone,Rcon.Contact.Email, Null, Null));
        }
        
        return vendorContacts;
    }
    
     public static String getAccountTitleNameById(Id accountTitleId){
         if(accountTitleId != Null){
             return [SELECt Id, Name FROM Account_Title__c WHERE Id =: accountTitleId LIMIT 1].Name;
         }
         return Null;
     } 
     @AuraEnabled //Check duplicate contacts are exist or not.
     public static List<allContacts> checkDuplicateContacts(String firstName, 
                                                        String lastName,
                                                        String email,
                                                        String phone, 
                                                        String mobile,
                                                        Id accountId,
                                                        String title,
                                                        String department,
                                                        String preferred,
                                                        String extension,
                                                        String caseId){
               
            List<allContacts> allContactList = new List<allContacts>();                                         	
            List<allContacts> existingContacts = new List<allContacts>();
            
            String accountTitleName = getAccountTitleNameById(Id.valueOf(title)); 
            
            Id tempId = Null; 
            allContacts con = new allContacts(tempId, firstName + ' ' + lastName,accountTitleName,'',phone,email, Null, Null);
            
            allContactList.add(con);
            
            Id loc = [SELECT Id, ContactId, Location__c, Client__c FROM Case WHERE Id =: caseId].Location__c;
            
            List<Contact> conList = [SELECT Id, Name, AccountId, FirstName, LastName, Phone, MobilePhone, Email, Preferred_Method__c,
                                                Contact_Status__c, Account_Title__r.Name, Account.Name, 
                                                Business_Rule_Association__c, Last_Activity_Date__c 
                                                FROM contact
                                              WHERE ((FirstName = :firstName AND LastName = :lastName)
                                              OR (Email != '' AND Email = :email)
                                              OR (Phone != '' AND Phone = :phone) 
                                              OR (MobilePhone != '' AND MobilePhone = :mobile))
                                              AND (AccountId =: accountId OR Location__c =: loc) order by Last_Activity_Date__c DESC NULLS last];
                   
          System.debug('>>>conList'+conList);  	 	
         //allContactList.addAll(conList); 
         for(Contact c : conList) { 
            system.debug(c); 
            allContactList.add(new allContacts(c.Id,c.Name,c.Account_Title__r.Name,c.Account.Name,c.Phone,c.Email,c.Business_Rule_Association__c, Date.valueOf(c.Last_Activity_Date__c))); 
        }
        //List<Contact> existingContacts = searchContacts(firstName, lastName, email, phone, mobile, accountId) {
        System.debug('>>>allContactList'+allContactList); 
        return allContactList;  
    }
    
    @AuraEnabled //Creates a new contact and returns the Id
    public static Id createNewContact(String firstName, 
                                      String lastName,
                                      Id accountId,
                                      Id caseId,
                                      String phone, 
                                      String email, 
                                      String title, 
                                      String department,
                                      String preferred,
                                      String extension) {
       
        
        Id newContact;
        
        system.debug('>>>'+firstName + lastName + accountId + phone + email + title + preferred + department + extension);
         Id loc = [SELECT Id, ContactId, Location__c, Client__c FROM Case WHERE Id=:caseId].Location__c;                                   
        Contact newCon = new Contact();
        
        newCon.FirstName = firstName;
        newCon.LastName = lastName;
        newCon.AccountId = accountId;
        newCon.Phone = phone;
        newCon.Location__c = loc;                                  
        newCon.Email = email;
        newCon.Account_Title__c = title;
        newCon.Business_Rule_Association__c = 'No';
        if (department != '') {
            newCon.Account_Department__c = department;
        }
        newCon.Preferred_Method__c = preferred;
        newCon.Phone_Extension__c = extension;
        
        try {
            insert newCon;                
            newContact = newCon.Id;
            system.debug('>>>'+newCon);
        } catch(DmlException e) {
            system.debug('Exception occurred: ' + e.getMessage()+ 'At Line Number'+e.getLineNumber());
        }
        
        system.debug(newContact);
    
        return newContact;
    }
    @AuraEnabled //Creates a new vendor contact and returns the Id
    public static Id createNewVenContact(String firstName, 
                                      String lastName,
                                      Id accountId,
                                      String phone, 
                                      String email,
                                      String preferred,
                                      String extension) {
        Id newContact;
        
        system.debug(firstName + lastName + accountId + phone + email + preferred + extension);
                                          
        Contact newCon = new Contact();
        
        newCon.FirstName = firstName;
        newCon.LastName = lastName;
        newCon.AccountId = accountId;
        newCon.Phone = phone;
        newCon.Email = email;
        newCon.Preferred_Method__c = preferred;
        newCon.Phone_Extension__c = extension;
        
        try {
            insert newCon;                
            newContact = newCon.Id;
        } catch(DmlException e) {
            system.debug('Exception occurred: ' + e.getMessage());
        }
        
        system.debug(newContact);
        
        return newContact;
    }
    @AuraEnabled //returns users associated to the 
    public static List<allContacts> getAccountTeam(Id accountId) {
        
        List<allContacts> atMembers = new List<allContacts>();
        
        List<AccountTeamMember> atm = [SELECT UserId, User.Name, TeamMemberRole, User.CompanyName,
                                       User.Phone, User.Email
                                       FROM AccountTeamMember
                                       WHERE AccountId =:accountId];
                                        
        For (AccountTeamMember a : atm) {
            atMembers.add(new allContacts(a.UserId, 
                                          a.User.Name, 
                                          a.TeamMemberRole, 
                                          a.User.CompanyName,
                                          a.User.Phone, 
                                          a.User.Email, Null, Null));
        }
        
        system.debug(atMembers);
        
        return atMembers;
    }
    @AuraEnabled 
    public static List<allContacts> getUsers(String query) {
        
        List<allContacts> Users = new List<allContacts>();
        
        system.debug(query);
        query+='*';
        List<List<sObject>> qryRes = [FIND :query IN ALL FIELDS 
                                      RETURNING User(Id, Name, Title, CompanyName, Phone, Email,
                                                    Alias, Acorn_SUser_ID__c)];
        
        List<User> u = (User[])qryRes[0];
        system.debug(u);
        
        For (User UID : u) {
            Users.add(new allContacts(UID.Id,UID.Name,UID.Title,UID.CompanyName,UID.Phone,UID.Email, Null, Null));
        }
        
        return Users;
    }
    public static Id internalContact() {
        List<Contact> conList = [SELECT Id, FirstName, LastName 
                                 FROM Contact
                                 WHERE FirstName='Internal' AND LastName='User']; 
        
        if (conList.size() == 0 ) {
            Contact con = new Contact(
                FirstName='Internal',
                LastName='User'
            );
            insert con;
            return con.Id;
        }
        
        return conList[0].Id;
    }
     @AuraEnabled
    public static void saveUserToCase(Id caseId, Id userId) {
        
        Id contactId = internalContact();
        
        system.debug(caseId);
        system.debug(userId);
        system.debug(contactId);
        
        User userDetail = [Select id, LastName,FirstName, Phone, Email from User WHERE id =: userId];
        List <Contact> userInContact = [Select Id, Internal_User_ID__c, LastName, FirstName, Phone, Email from Contact where Internal_User_ID__c != Null AND Internal_User_ID__c =: userId limit 1];
        //List <Contact> userInContact = [Select Id, Internal_User_ID__c, LastName, FirstName, Phone, Email from Contact where Email =: userDetail.Email AND Internal_User_ID__c =:userId limit 1];
        
        if(userInContact.size() == 0){
                Contact con = new Contact(
                FirstName = userDetail.FirstName,
                LastName = userDetail.LastName,
                Internal_User_ID__c = userId
            );
            insert con;
            contactId = con.Id;
        }
        else {
            contactId = userInContact[0].Id;
        }
        
        Case c = [SELECT Id, Requested_By_User__c, ContactId FROM Case WHERE Id =: caseId];
        
        c.Requested_By_User__c = userId;
        boolean goldCustomerFlag = CaseEntitlement.getCaseEntitlement(caseId);
        if(goldCustomerFlag)
        {
            c.Availability_Checked__c = true;
        }
        c.ContactId = contactId;
        try {
            update c;
        } catch(DmlException e) {
            system.debug('Exception occurred: ' + e.getMessage());
        }
    }
    //Wrapper class and constructor for All Contacts data table
    public inherited sharing class allContacts{
        @AuraEnabled
        public Id ContactId {get;set;}
        @AuraEnabled
        public String Name {get; set;}
        @AuraEnabled
        public String Title {get; set;}
        @AuraEnabled
        public String Company {get; set;}
        @AuraEnabled
        public String Phone {get; set;}
        @AuraEnabled
        public String Email {get; set;}
        @AuraEnabled
        public String BusinessRuleAssociation {get; set;}
        @AuraEnabled
        public Date LastActivityDate {get; set;}
        
        //Constructor
        public allContacts( Id ContactId, String Name, String Title, String Company,
                          String Phone, String Email, String BusinessRuleAssociation, Date LastActivityDate) {
            this.ContactId = ContactId;
            this.Name = Name;
            this.Title = Title;
            this.Company = Company;
            this.Phone = Phone;
            this.Email = Email;
            this.BusinessRuleAssociation = BusinessRuleAssociation; 
            this.LastActivityDate = LastActivityDate;
        }
    }
    //SDT-10964: New Wrapper class and constructor for All Search Contacts data table
    public inherited sharing class allSearchContacts{
        @AuraEnabled
        public Id ContactId {get;set;}
        @AuraEnabled
        public String Name {get; set;}
        @AuraEnabled
        public String Title {get; set;}
        @AuraEnabled
        public String Company {get; set;}
        @AuraEnabled
        public String Phone {get; set;}
        @AuraEnabled
        public String Email {get; set;}
        @AuraEnabled
        public String MobilePhone {get; set;}
        //Constructor
        public allSearchContacts( Id ContactId, String Name, String Title, String Company,
                          String Phone, String Email, String MobilePhone) {
            this.ContactId = ContactId;
            this.Name = Name;
            this.Title = Title;
            this.Company = Company;
            this.Phone = Phone;
            this.Email = Email;
            this.MobilePhone = MobilePhone;
        }
    }    
    public static List<String> getInvalidVendors() {
        
        List<String> badVendors = new List<String>();
        badVendors.add('200092');
        badVendors.add('200095');
        badVendors.add('200108');
        badVendors.add('200110');
        badVendors.add('200230');
        badVendors.add('200319');
        badVendors.add('212660');
        badVendors.add('214092');
        badVendors.add('214250');
        badVendors.add('214276');
        badVendors.add('214376');
        badVendors.add('214519');
        badVendors.add('215066');
        badVendors.add('216145');
        badVendors.add('223623');
        badVendors.add('823');
        badVendors.add('8076');
        badVendors.add('4245');
        badVendors.add('5971');
        
        return badVendors;
        
    }
    
    //Wrapper class and constructor for All Vendors data table
    public inherited sharing class allVendors {    
        @AuraEnabled
        public Id AccountId {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String VID {get;set;}
        
        //Constructor
        public allVendors (Id AccountId, String Name, String VID) {
            this.AccountId = AccountId;
            this.Name = Name;
            this.VID = VID;
        }
    }
    public inherited sharing class dualList {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
        
        public dualList(String label, String value) {
            this.label = label;
            this.value = value; 
        } 
    }
}