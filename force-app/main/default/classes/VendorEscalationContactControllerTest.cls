/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-21-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class VendorEscalationContactControllerTest {

    @TestSetup
    static void createData(){
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        Account parentAcc1 = new Account(Name= 'Parent Vendor Account 1' , RecordTypeId = recordTypeId, AccountNumber = '777'  );
        Account parentAcc2 = new Account(Name= 'Parent Vendor Account 2' , RecordTypeId = recordTypeId, AccountNumber = '8'  );
        insert new List<Account>{parentAcc1 , parentAcc2};

        Account childAccount1 = new Account(Name= 'Child Vendor Account 1' , RecordTypeId = recordTypeId , ParentId = parentAcc1.Id);
        Account childAccount2 = new Account(Name= 'Child Vendor Account 2' , RecordTypeId = recordTypeId , ParentId = parentAcc2.Id);
        Account childAccount3 = new Account(Name= 'Child Vendor Account 3' , RecordTypeId = recordTypeId , ParentId = parentAcc1.Id);
        Account nonParentedChildAccount = new Account(Name= 'Child Vendor Account 2' , RecordTypeId = recordTypeId);
        insert new List<Account>{childAccount1 , childAccount2 , childAccount3, nonParentedChildAccount};

        Contact con1 = new Contact(FirstName = 'test contact 1' , LastName = 'test contact 1', AccountId = parentAcc1.Id);
        Contact con2 = new Contact(FirstName = 'test contact 2' , LastName = 'test contact 2', AccountId = parentAcc1.Id);
        Contact con3 = new Contact(FirstName = 'test contact 3' , LastName = 'test contact 3', AccountId = parentAcc2.Id);
        insert new List<Contact>{con1 , con2, con3};

        List<Category__c> testCategories = new List<Category__c>{
            new Category__c(Name = 'Test Category 1', Category_Type__c = 'Vendor' , Parent_Vendor_Account__c = parentAcc1.id),
                new Category__c(Name = 'Test Category 2', Category_Type__c = 'Market Area'  , Parent_Vendor_Account__c = parentAcc2.id)
                };
                    insert testCategories;
                    
        
        AccountContactRelation acr1 = new AccountContactRelation();
        acr1.AccountId = childAccount1.id;
        acr1.ContactId = con1.id;
        acr1.Roles = '1st Dispatch Escalation-Rolloff;2nd Dispatch Escalation-Rolloff';
        acr1.CategoryId__c = testCategories[0].Id;

        AccountContactRelation acr2 = new AccountContactRelation();
        acr2.AccountId = childAccount1.id;
        acr2.ContactId = con2.id;
        acr2.Roles = '1st Dispatch Escalation-Commercial;2nd Dispatch Escalation-Commercial';
        acr2.CategoryId__c = testCategories[0].Id;

        AccountContactRelation acr3 = new AccountContactRelation();
        acr3.AccountId = childAccount2.id;
        acr3.ContactId = con1.id;
        acr3.Roles = '1st Dispatch Escalation-Rolloff;2nd Dispatch Escalation-Rolloff';
        acr3.CategoryId__c = testCategories[1].Id;

        insert new List<AccountContactRelation>{acr1 , acr2, acr3};

        childAccount1.Category__c = testCategories[0].Id;
        childAccount2.Category__c = testCategories[1].Id;
        update new List<Account>{childAccount1 , childAccount2};

    }

    @isTest
    static void testFetchCategories() {
        List<Category__c> fetchedCategories = VendorEscalationContactController.fetchCategories('Test');
        System.assertEquals(2, fetchedCategories.size());
    }

    @isTest
    static void testFetchParentAccount() {
        
        system.assertEquals(1 , VendorEscalationContactController.fetchParentAccount('Vendor','Parent').size());

        system.assertEquals(1 , VendorEscalationContactController.fetchParentAccount('Market Area','Parent').size());

    }

    @isTest
    static void testFetchVendorAccount() {
        List<Account> acc = [Select Id FROM Account WHERE Name = 'Parent Vendor Account 1'];
        List<Category__c> fetchedCategories = VendorEscalationContactController.fetchCategories('Test Category 1');
        system.assertEquals(1 , VendorEscalationContactController.fetchVendorAccount(acc[0].id ,'Child' , true, new List<String>(), null).size());
        system.assertEquals(2 , VendorEscalationContactController.fetchVendorAccount(acc[0].id ,'Child' , false, new List<String>(), fetchedCategories[0].Id).size());
    }

    @isTest
    static void testFetchVendorContact() {
        List<Category__c> cat = [Select Id FROM Category__c WHERE Name = 'Test Category 1'];
        Account parentAcc1 = [Select Id FROM Account WHERE Name= 'Parent Vendor Account 1' ];
        Account parentAcc2 = [Select Id FROM Account WHERE Name= 'Parent Vendor Account 2' ];
        system.assertEquals(2 , VendorEscalationContactController.fetchVendorContact('test contact' , cat[0].id , new List<String>{parentAcc1.id}).size() );
        system.assertEquals(1 , VendorEscalationContactController.fetchVendorContact('test contact' , '' , new List<String>{parentAcc2.id}).size());
        
    }

    @isTest
    static void testFetchCategoryType() {
        system.assert( VendorEscalationContactController.fetchCategoryType().size() > 0);
    }

    @isTest
    static void testFetchRolesData() {
        system.assert( VendorEscalationContactController.fetchRolesData('Dispatch').size() > 0);
    }

    @isTest
    static void testSaveCategoryData() {
        Account parentAcc = [Select Id, Name FROM Account WHERE Name= 'Parent Vendor Account 1'];
        Account childAcc = [Select Id, Name FROM Account WHERE Name= 'Child Vendor Account 1'];
        VendorEscalationContactController.CategoryDataWrapper wrapper = new VendorEscalationContactController.CategoryDataWrapper();
        wrapper.categoryName = 'Test Category from test method';
        wrapper.categoryType = 'Vendor';
        wrapper.parentAccountId = parentAcc.id;
        wrapper.parentAccountName = parentAcc.Name;
        wrapper.vendorAccounts = new List<String> ();
        wrapper.vendorAccounts.add(childAcc.Id);

        List<AccountContactRelation> accContactRelations = [SELECT Id, AccountId, ContactId, Roles FROM AccountContactRelation WHERE AccountId = :childAcc.Id];

        Map<String,List<String>> contactRoleMap = new Map<String,List<String>>();
        for(AccountContactRelation acr : accContactRelations){
            List<String> roleList = acr.Roles != null ?  acr.Roles.split(';') : null;
            roleList.add('Work Order Inquiries');
            contactRoleMap.put(acr.ContactId , roleList);
        }                                                            

        wrapper.contactRoleMap = contactRoleMap;    
        VendorEscalationContactController.saveCategoryData(JSON.serialize(wrapper));
    }

    @isTest
    static void testFetchCategoryData() {
        List<Category__c> cat = [Select Id FROM Category__c WHERE Name = 'Test Category 1'];
        VendorEscalationContactController.fetchCategoryData(cat[0].id);
        
    }
}