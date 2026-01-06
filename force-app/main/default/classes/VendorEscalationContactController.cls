/**
 * @description       : 
 * @author            : Adil ALeem
 * @group             : 
 * @last modified on  : 09-29-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public without sharing class VendorEscalationContactController {

    public static final List<String> WM_VENDOR_IDs = new List<String>{'8' , '5889'};

    @AuraEnabled
    public static List<Category__c> fetchCategories(String categoryStr){
        String categoryName = '%' + categoryStr.trim() + '%';
        String qry = 'SELECT Id, Name, Category_Type__c, Validated_By__c, Validated_Date__c, Parent_Vendor_Account__c FROM Category__c WHERE Name like :categoryName'; 
        List<Category__c> categoryList = Database.query(qry);
        return categoryList;
    } 

    @AuraEnabled
    public static List<AccountWrapper> fetchParentAccount(String categoryType, String searchStr){
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        searchStr = '%' + searchStr + '%';
        List<Account> parentAccList = new List<Account>();
        if(categoryType == 'Vendor') {
            parentAccList = [SELECT Id, Name, Vendor_Id__c,
                            (Select Id FROM ChildAccounts WHERE Status__c = 'Active' LIMIT 1)
                            FROM Account 
                            WHERE Status__c = 'Active' AND ParentId = null AND Vendor_Id__c NOT IN :WM_VENDOR_IDs AND RecordTypeId = :recordTypeId 
                            AND (Name LIKE :searchStr OR Vendor_Id__c LIKE :searchStr) Order BY Vendor_Id__c LIMIT 1000];
        }
        else if(categoryType == 'Market Area') {
            parentAccList = [SELECT Id, Name, Vendor_Id__c,
                            (Select Id FROM ChildAccounts WHERE Status__c = 'Active' LIMIT 1)
                            FROM Account 
                            WHERE Status__c = 'Active' AND ParentId = null AND Vendor_Id__c IN :WM_VENDOR_IDs AND RecordTypeId = :recordTypeId 
                            AND (Name LIKE :searchStr OR Vendor_Id__c LIKE :searchStr) Order BY Vendor_Id__c LIMIT 1000];
        }

        List<AccountWrapper> wrapperList = new List<AccountWrapper>();
        
        for(Account acc: parentAccList){
            if(acc.ChildAccounts != null && !acc.ChildAccounts.isEmpty()) {
                AccountWrapper aw = new AccountWrapper();
                aw.accountId = acc.Id;
                aw.accountName = acc.Name + ' ' + acc.Vendor_Id__c;
                aw.accountVendorId = acc.Vendor_Id__c;
                aw.isParent = true;
                wrapperList.add(aw);
            }
        }
        return wrapperList;
    }

    @AuraEnabled
    public static List<AccountWrapper>  fetchVendorAccount(String parentVendorId, String searchStr, Boolean isNew, List<String> existingVendors, String categoryId){
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        searchStr = '%' + searchStr + '%';
        List<Account> vendorAccList = new List<Account>();
        List<Account> existingVendorList = new List<Account>();
        if(existingVendors != null && !existingVendors.isEmpty()){
            existingVendorList = [SELECT Id, Name, Vendor_Id__c
                                FROM Account 
                                WHERE Id IN :existingVendors LIMIT 500];
        } 
        vendorAccList = [SELECT Id, Name, Vendor_Id__c,
                        (Select Id FROM ChildAccounts LIMIT 1)
                        FROM Account 
                        WHERE Status__c = 'Active' AND ParentId = :parentVendorId AND RecordTypeId = :recordTypeId AND (Category__c = null OR Category__c = :categoryId)
                        AND (Name LIKE :searchStr OR Vendor_Id__c LIKE :searchStr) LIMIT 500];

        vendorAccList.addAll(existingVendorList); 
        List<AccountWrapper> wrapperList = new List<AccountWrapper>();
        Set<String> accountSet = new Set<String>();
        for(Account acc: vendorAccList){
            if((acc.ChildAccounts == null || acc.ChildAccounts.isEmpty()) && !accountSet.contains(acc.Id)) {
                AccountWrapper aw = new AccountWrapper();
                aw.accountId = acc.Id;
                aw.accountName = acc.Name + ' ' + acc.Vendor_Id__c;
                aw.accountVendorId = acc.Vendor_Id__c;
                aw.isParent = false;
                accountSet.add(acc.Id);
                wrapperList.add(aw);
            }    
        }

        return wrapperList;
    }

    @AuraEnabled
    public static List<Contact> fetchVendorContact(String searchStr, String categoryId, List<String> accountList){
        List<Contact> contactList = new List<Contact>();
        List<Contact> existingContactList = new List<Contact>();
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        searchStr = '%' + searchStr + '%';
        if(categoryId != null && categoryId != '') {
            Set<String> contactIdSet = new Set<String>();
            for(AccountContactRelation acr : [SELECT Id, ContactId FROM AccountContactRelation WHERE CategoryId__c = :categoryId]){
                contactIdSet.add(acr.ContactId);
            }   
            existingContactList = [SELECT Id, FirstName, LastName, Name FROM Contact 
                                        WHERE Account.RecordtypeId = :recordTypeId 
                                        AND Account_Record_Type__c = 'Vendor' AND (FirstName LIKE :searchStr OR LastName LIKE :searchStr OR Name LIKE :searchStr) 
                                        AND ID IN :contactIdSet
                                        ORDER BY CreatedDate Desc LIMIT 100];

            contactList = [SELECT Id, FirstName, LastName, Name FROM Contact 
                                    WHERE Account.RecordtypeId = :recordTypeId 
                                    AND Account_Record_Type__c = 'Vendor' AND (FirstName LIKE :searchStr OR LastName LIKE :searchStr OR Name LIKE :searchStr) 
                                    AND ID NOT IN :contactIdSet
                                    AND AccountId IN :accountList
                                    ORDER BY CreatedDate Desc LIMIT 100];
            
            contactList.addAll(existingContactList);                  
        }
        else {
            contactList = [SELECT Id, FirstName, LastName, Name FROM Contact 
                                    WHERE Account.RecordtypeId = :recordTypeId 
                                    AND Account_Record_Type__c = 'Vendor' AND (FirstName LIKE :searchStr OR LastName LIKE :searchStr OR Name LIKE :searchStr) 
                                    AND AccountId IN :accountList
                                    ORDER BY CreatedDate Desc LIMIT 100];
        }
        
        return contactList;
    }

    @AuraEnabled
    public static List<String> fetchCategoryType(){
        return UTIL_Picklist.getPickListValuesIntoList('Category__c', 'Category_Type__c');
    }

    @AuraEnabled
    public static List<String> fetchRolesData(String searchStr){
        List<String> pickListValuesList= new List<String>();
        String roleStr = '%' + searchStr.trim() + '%';
        List<Vendor_Contact_Role_Map__mdt> accountRoleList = [Select Id, Role__c from Vendor_Contact_Role_Map__mdt WHERE Role__c LIKE :roleStr Order by Order__c ASC LIMIT 500];
        for(Vendor_Contact_Role_Map__mdt roleData : accountRoleList){
            pickListValuesList.add(roleData.Role__c);
        }
        return pickListValuesList;
    }


    @AuraEnabled
    public static void saveCategoryData(String categoryData){
        Constant_UTIL.skipWOTrigger = true;
        Object_Save_Mode__c woCustomSetting = Object_Save_Mode__c.getInstance();
        woCustomSetting.Full_Logic_Disabled__c = true;
        upsert woCustomSetting;
        Map<String,  String> eACRMap = new Map<String,  String>();
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        List<Account> accToUpdate = new List<Account>();
        List<AccountContactRelation> acrToDelete = new List<AccountContactRelation> ();
        List<AccountContactRelation> acrToDeleteFinal = new List<AccountContactRelation> ();
        
        CategoryDataWrapper wrapper = (CategoryDataWrapper) JSON.deserialize(categoryData ,  CategoryDataWrapper.class);
        Category__c cat = new Category__c();
        cat.Name = wrapper.categoryName;
        cat.Category_Type__c = wrapper.categoryType;
        if(wrapper.parentAccountId == '' || wrapper.parentAccountId == ' ') {
            wrapper.parentAccountId = null;
        }
        if(wrapper.categoryId == '' || wrapper.categoryId == ' ') {
            wrapper.categoryId = null;
        }
        cat.Parent_Vendor_Account__c = wrapper.parentAccountId ;
        cat.Validated_By__c = UserInfo.getUserId();
        cat.Validated_Date__c = System.today();
        cat.Id = wrapper.categoryId;
        upsert cat;

        
        List<AccountContactRelation> existingAccountContactRelation = [SELECT Id, AccountId, ContactId 
                                                                      FROM AccountContactRelation
                                                                      WHERE AccountId IN :wrapper.vendorAccounts
                                                                      AND ContactId IN :wrapper.contactRoleMap.keySet()];

        for(AccountContactRelation eACR : existingAccountContactRelation) {
            eACRMap.put(eACR.AccountId + '~' + eACR.ContactId , eACR.id); 
        }   
        
        for(String vendorId : wrapper.vendorAccounts) {
            Account acc = new Account(Id = vendorId , Category__c = cat.Id);
            accToUpdate.add(acc);

            for(String key : wrapper.contactRoleMap.keySet()){
                AccountContactRelation acr = new AccountContactRelation();
                String roles = (wrapper.contactRoleMap.get(key) != null && !wrapper.contactRoleMap.get(key).isEmpty()) ? String.join(wrapper.contactRoleMap.get(key) , ';') : '';
                if(roles != ''){
                    String accConKey = vendorId + '~' + key;
                    acr.AccountId = vendorId;
                    acr.ContactId = key;
                    acr.Roles = roles;
                    acr.CategoryId__c = cat.Id;
                    acr.Id = eACRMap.containsKey(accConKey) ? eACRMap.get(accConKey) : null;  
                    acrList.add(acr);
                }
            }
        }

        List<String> contactListToDeleteACR = new List<String>();
        for(String key : wrapper.contactRoleMap.keySet()){
            Boolean isEmptyRoles = (wrapper.contactRoleMap.containsKey(key) && wrapper.contactRoleMap.get(key).isEmpty()) ? true : false;
            if(isEmptyRoles){
                contactListToDeleteACR.add(key);
            }
        }
       

        Set<String> accListToClearCategory = new Set<String>();
        if(wrapper.categoryId != null && wrapper.categoryId != '') {
            acrToDelete = [Select Id, AccountId, Contact.AccountId, Roles, CategoryId__c FROM AccountContactRelation WHERE CategoryId__c = :cat.Id AND AccountId NOT IN :accToUpdate];
            for(AccountContactRelation acr : acrToDelete){
                accListToClearCategory.add(acr.accountId);
            }    
        }

        for(AccountContactRelation acr : [Select Id, AccountId, Contact.AccountId, Roles, CategoryId__c FROM AccountContactRelation WHERE ContactId != null AND ContactId IN :contactListToDeleteACR AND CategoryId__c = :cat.id AND ID NOT IN :acrToDelete]){
            acrToDelete.add(acr);
        }

        for(AccountContactRelation acr : acrToDelete){
            if(acr.AccountId == acr.Contact.AccountId){
                acr.Roles = null;
                acr.CategoryId__c = null;
                acrList.add(acr);
            } else {
                acrToDeleteFinal.add(acr);
            }
        }

        for(Account a : [Select Id, Category__c FROM Account WHERE Id IN :accListToClearCategory]){
            if(a.Category__c == cat.id) {
                accToUpdate.add(new Account(Id = a.Id, Category__c = null));
            }  
        }

        if(!acrList.isEmpty()) {
            upsert acrList;
        } 

        if(!accToUpdate.isEmpty()) {
            update accToUpdate; 
        }

        if(!acrToDeleteFinal.isEmpty()){
            delete acrToDeleteFinal;
        }
        Constant_UTIL.skipWOTrigger = false;
        woCustomSetting.Full_Logic_Disabled__c = false;
        upsert woCustomSetting;
    }


    @AuraEnabled
    public static CategoryDataWrapper fetchCategoryData(String categoryId){
        List<Category__c> categoryList = [Select Id, Name, Category_Type__c, Validated_Date__c, Validated_By__c, Parent_Vendor_Account__c FROM Category__c WHERE Id = :categoryId ];
        CategoryDataWrapper wrapper = new CategoryDataWrapper();
        if(categoryList != null & !categoryList.isEmpty()){      
            Category__c category = categoryList[0]; 
            wrapper.categoryName = category.Name;
            wrapper.categoryType = category.Category_Type__c;
            wrapper.validatedDate = category.Validated_Date__c;
            List<User> usr = [Select Id, Name FROM User WHERE Id = :category.Validated_By__c];
            if(usr != null && !usr.isEmpty()){
                wrapper.validatedBy = usr[0].Name;
                wrapper.validatedById = usr[0].id;
            } 
            wrapper.parentAccountId = category.Parent_Vendor_Account__c;

            List<Account> parentAcc = [Select Id, Name, Vendor_Id__c FROM Account WHERE Id = :wrapper.parentAccountId ];
            if(parentAcc != null && !parentAcc.isEmpty()){
                wrapper.parentAccountName = parentAcc[0].Name;
                wrapper.parentVendorId = parentAcc[0].Vendor_Id__c;
            }
            List<Account> vendorAccounts = [Select Id , Name FROM Account WHERE Category__c = :categoryId AND Status__c = 'Active'];
            wrapper.vendorAccounts = new List<String>();
            for(Account acc : vendorAccounts){
                wrapper.vendorAccounts.add(acc.Id);
            }      
        
            List<AccountContactRelation> accContactRelations = [SELECT Id, AccountId, ContactId, Roles
                                                                        FROM AccountContactRelation
                                                                        WHERE CategoryId__c = :categoryId];
            
            Map<String,List<String>> contactRoleMap = new Map<String,List<String>>();
            for(AccountContactRelation acr : accContactRelations){
                List<String> roleList = acr.Roles != null ?  acr.Roles.split(';') : null;
                contactRoleMap.put(acr.ContactId , roleList);
            }                                                            

            wrapper.contactRoleMap = contactRoleMap;    
        }
        return wrapper;

    }

    public class AccountWrapper{
        @AuraEnabled
        public String accountId {set; get;}
        @AuraEnabled
        public String accountName {set; get;}
        @AuraEnabled
        public String accountVendorId {set; get;}
        @AuraEnabled
        public Boolean isParent {set; get;}
    }

    public class CategoryWrapper{
        @AuraEnabled
        public String categoryId {set; get;}
        @AuraEnabled
        public String categoryName {set; get;}
    }

    public class CategoryDataWrapper{
        @AuraEnabled
        public String categoryId {set; get;}
        @AuraEnabled
        public String categoryName {set; get;}
        @AuraEnabled
        public String categoryType {set; get;}
        @AuraEnabled
        public List<String> vendorAccounts {set; get;}
        @AuraEnabled
        public Date validatedDate {set; get;}
        @AuraEnabled
        public String validatedBy {set; get;}
        @AuraEnabled
        public String validatedById {set; get;}
        @AuraEnabled
        public String parentAccountId {set; get;}
        @AuraEnabled
        public String parentAccountName {set; get;}
        @AuraEnabled
        public String parentVendorId {set; get;}
        @AuraEnabled
        public Map<String,List<String>> contactRoleMap { get; set; }
    }

}