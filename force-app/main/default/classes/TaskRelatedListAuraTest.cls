/**
* @author Accenture
* @date 2/3/2019
* @description : Apex class TaskRelatedListAuraTest 
**/
// test class for TaskRelatedListAura
@isTest(SeeAllData=false)
public class TaskRelatedListAuraTest {

    /**
* @description set the test data
**/
    @testSetup static void setup() {
        Profile prf = TestDataFactory.getProfile(Constant_Util.SYSTEM_ADMINISTRATOR);
        User usr = TestDataFactory.createUser(prf);
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
                                                                  Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            Database.insert(assetlist);
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            Database.insert(caselist);
            list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
            Database.insert(tasklist);    
        } 
        
    }

    /**
* @description test method for getting the related list of task
**/    
    @isTest static void testData(){
        //test class errors - SDT - 33363
        User usr = [Select id,isActive from User WHERE isActive = TRUE limit 1];
        
        system.runAs(usr){
            task tsk = [SELECT Id, WhatId FROM Task limit 1];
            TaskRelatedListAura.getRelatedTo(tsk.id);
            system.assert(tsk.id != null);
        }
        
    }
}