@isTest(seeAllData = false)
public class BusinessRuleHelperTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string PRODUCT = '8 yrd';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string CASE_NAME = 'First';
    private static final string NY_TIMEZONE = 'America/New_York';
    private static final string PO_NUMBER = '1243';
    private static final string COMMERCIAL = 'Commercial';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string DISTRICT_MANAGER = 'District Manager';
    private static final string PO_PSI_VALUE = 'PO Number'; //SDT-33363
    private static final string DISPOSAL ='Disposal';
    
    /* set the test data*/
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        usr.bypass_validation__c = true;
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            Database.insert(acclist);
            
            Categorization__c cg = new Categorization__c();
            cg.Client_Account__c = acclist[0].Id;
            cg.Category__c = 'Location Type';
            cg.Name = 'Kroger Type';
            Database.insert(cg);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            locationlist[0].Location_Type__c = cg.Id;
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(RITA,REPLY, acclist.get(0), usr);
            Database.insert(conlist);
            
            list<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = COMMERCIAL;
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            
            list<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME , acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            List<Project_Code__c> pCodeList=TestDataFactory.createProjectCode(acclist.get(0).Id);
            Database.insert(pCodeList);
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Project_Code__c = pCodeList[0].Id; 
            Database.insert(assetlist);
            
            list<Case> caselist = TestDataFactory.createCase( CASE_NAME, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].PurchaseOrder_Number__c =  PO_NUMBER;
            caselist[0].Status = Constant_Util.PENDING;
            caselist[0].Case_Type__c = Constant_Util.PICKUP_CSTYPE;
            
            caselist[0].Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
            //    caselist[0].Case_Reason__c = COMPACTOR;
            try{
                Database.insert(caselist);
            }catch(Exception ex){
                system.debug('Exception while inserting case:::'+ex.getStackTraceString());
            }
            list<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), 
                                                                               locationlist.get(0));
            brlist[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlist[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlist[0].Container__c = Constant_Util.EMPTY_STRING;
            brlist[0].AssetId__c = assetlist[0].Id;
            brlist[0].Multiple_Mandatory_Approvers__c = true;
            brlist[0].RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            Database.insert(brlist);
            
            list<Account_Title__c> titlelst = TestDataFactory.createAccountTitle(acclist.get(0),DISTRICT_MANAGER);
            Database.insert(titlelst,false);
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(brlist[0]);
            serviceApproverlist[0].Title__c = titlelst[0].Id;
            Database.insert(serviceApproverlist,true);
            brlist[0].Active__c = true;
            Database.Update(brlist);
            
            list<Business_Rule__c> brlist1 = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), 
                                                                               locationlist.get(0));
            brlist1[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlist1[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlist1[0].Container__c = Constant_Util.EMPTY_STRING;
            brlist1[0].AssetId__c = assetlist[0].Id;
            brlist1[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brlist1[0].Required_Information__c = PO_PSI_VALUE; 
            Database.insert(brlist1);
        }
    }
    
    @isTest static void ApprovalBusinessRule(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(currentuser){
           	map<Id,Account> accmap = new map<Id,Account>([select id,Brand__c,Division__c,Location_Type__c,Geography__c from Account where Recordtype.name =: Constant_Util.LOCATION limit 1]);
            
            list<case> caselist = [select id, origin, contactid, Case_Type__c,Contact_Title__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,OwnerId,
                                   Service_Date__c,SLA_Service_Date_Time__c from case where status =: Constant_Util.PENDING limit 1];
            system.debug('caselist@@@@'+caselist);
            map<Id,Asset> asmap = new map<Id,Asset>([select Id,Duration__c,Product2.ProductTypeSelected__c,Project_Code__c,Material_Type__c from Asset where id =: caselist[0].assetid LIMIT 1]);
            list<Business_Rule__c> brlst = [select Id,RecordTypeId,Required_Information__c,AccountId__c,Request_Type__c,Container__c,LocationId__c,Service__c,Schedule_Type__c,End_Date__c,Project_Code__c,AssetId__c,Channel__c,Multiple_Mandatory_Approvers__c,Occurrence_Limit__c,Material__c,
                                            Category_Type__c,Group__c,No_Approval_Required__c,Effective_Date__c,Active__c,(Select Id, Fuzzy_Search__c, Account_Team_Member__c,Business_Rule__c,RecordTypeId,Title__c,Account_Department__c,External_Approver_Email__c,External_Approver_Phone_Number__c,Account_Title__c,
                                                                                                                           Approver_Type__c,Email__c,User__c,ServiceApprover__c,SortBy__c,Approver_Contact__c,Title__r.Name,Approver_Contact__r.FirstName,Approver_Contact__r.LastName,Account_Team_Member__r.FirstName,Account_Team_Member__r.LastName,User__r.FirstName,Requester_Only__c,
                                                                                                                           User__r.LastName from Approver_Entities__r Order BY SortBy__c  ASC) from  Business_Rule__c LIMIT 2];
            
            Asset assetlst = [select Id,Duration__c,Product2.ProductTypeSelected__c,Project_Code__c,Material_Type__c from Asset where id =: caselist[0].assetid LIMIT 1];
            
            System.debug('brlst@@@'+brlst);
            map<Id,Business_Rule__c> brmap = new map<Id,Business_Rule__c>();
            brmap.Put(caselist[0].Id,brlst[0]);
            
            list<Service_Approver__c> salst = [Select Id, Business_Rule__c,Title__c,RecordType.DeveloperName,Requester_Only__c from Service_Approver__c where Business_Rule__c =:brlst[0].Id  LIMIT 49999];
            system.debug('salst@@@@'+salst);
            
            Project_Code__c pc = [Select Id from Project_Code__c Limit 1];
            Categorization__c cg = [Select Id from Categorization__c Limit 1];
            
            Test.startTest();
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            BusinessRuleHelper.getapprovallog(brmap,caselist,null);
            
            //Location and Project
            brlst[0].AssetId__c = null;
            brlst[0].Project_Code__c = pc.Id;
            
            brlst[1].AssetId__c = null;
            brlst[1].Project_Code__c = pc.Id;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //location,container,scheduletype
            brlst[0].Project_Code__c = null;
            brlst[0].Schedule_Type__c = 'Temporary';
            brlst[0].Container__c = COMPACTOR;
            
            brlst[1].Project_Code__c = null;
            brlst[1].Schedule_Type__c = 'Temporary';
            brlst[1].Container__c = COMPACTOR;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //Location,scheduleType
            brlst[0].Container__c = null;
            
            brlst[1].Container__c = null;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //Location,Container
            brlst[0].Schedule_Type__c = null;
            brlst[0].Container__c = COMPACTOR;
            
            brlst[1].Schedule_Type__c = null;
            brlst[1].Container__c = COMPACTOR;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //Location
            brlst[0].Container__c = null;
            
            brlst[1].Container__c = null;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //Project
            brlst[0].Active__c = false;
            brlst[0].LocationId__c = null;
            
            brlst[1].Active__c = false;
            brlst[1].LocationId__c = null;
            Database.Update(brlst);
            
            brlst[0].Active__c = true;
            brlst[0].Project_Code__c = pc.Id;
            
            brlst[1].Active__c = true;
            brlst[1].Project_Code__c = pc.Id;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //Group,Container,Schedule Type
            brlst[0].Project_Code__c = null;
            brlst[0].Category_Type__c = 'Location Type';
            brlst[0].Group__c = cg.Id;
            brlst[0].Schedule_Type__c = 'Temporary';
            brlst[0].Container__c = COMPACTOR;
            
            brlst[1].Project_Code__c = null;
            brlst[1].Category_Type__c = 'Location Type';
            brlst[1].Group__c = cg.Id;
            brlst[1].Schedule_Type__c = 'Temporary';
            brlst[1].Container__c = COMPACTOR;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //Group,Schedule Type
            brlst[0].Container__c = null;
            
            brlst[1].Container__c = null;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //Group,Container
            brlst[0].Schedule_Type__c = null;
            brlst[0].Container__c = COMPACTOR;
            
            brlst[1].Schedule_Type__c = null;
            brlst[1].Container__c = COMPACTOR;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //Group
            brlst[0].Container__c = null;
            
            brlst[1].Container__c = null;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //Container,Schedule Type
            brlst[0].Category_Type__c = null;
            brlst[0].Group__c = null;
            brlst[0].Schedule_Type__c = 'Temporary';
            brlst[0].Container__c = COMPACTOR;
            
            brlst[1].Category_Type__c = null;
            brlst[1].Group__c = null;
            brlst[1].Schedule_Type__c = 'Temporary';
            brlst[1].Container__c = COMPACTOR;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //Schedule Type
            brlst[0].Schedule_Type__c = 'Temporary';
            brlst[0].Container__c = null;
            
            brlst[1].Schedule_Type__c = 'Temporary';
            brlst[1].Container__c = null;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //Container
            brlst[0].Schedule_Type__c = null;
            brlst[0].Container__c = COMPACTOR;
            
            brlst[1].Schedule_Type__c = null;
            brlst[1].Container__c = COMPACTOR;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //Account,service
            brlst[0].Container__c = null;
            
            brlst[1].Container__c = null;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            Test.stopTest();
            
            //location,container,scheduletype
            brlst[0].Project_Code__c = null;
            brlst[0].Schedule_Type__c = 'Temporary';
            brlst[0].Container__c = COMPACTOR;
            
            brlst[1].Project_Code__c = null;
            brlst[1].Schedule_Type__c = 'Temporary';
            brlst[1].Container__c = COMPACTOR;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //Location,scheduleType
            brlst[0].Container__c = null;
            
            brlst[1].Container__c = null;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //Location,Container
            brlst[0].Schedule_Type__c = null;
            brlst[0].Container__c = COMPACTOR;
            
            brlst[1].Schedule_Type__c = null;
            brlst[1].Container__c = COMPACTOR;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
            //Location
            brlst[0].Container__c = null;
            
            brlst[1].Container__c = null;
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            
        
         /*   
            //Material,container,scheduletype
            brlst[0].Material__c = 'Trash';
            brlst[0].Schedule_Type__c =  'Temporary';
         //   brlst[0].Container__c = COMPACTOR;
            brlst[0].AssetId__c = assetlst.Id;
           // brlst[0].locationid__c = null;
          //  brlst[0].Category_Type__c = null;
         //   brlst[0].Project_Code__c = pc.Id;
            
            brlst[1].Material__c = 'Trash';
            brlst[1].Schedule_Type__c =  'Temporary';
         //   brlst[1].Container__c = COMPACTOR;
            brlst[1].AssetId__c = assetlst.Id;
         //   brlst[1].locationid__c = null;
         //   brlst[1].Category_Type__c = null;
         //   brlst[1].Project_Code__c = pc.Id;
            
            Database.Update(brlst);
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            */
            /*
//Material,container
brlst[0].Material__c = 'Trash'; 
brlst[0].Container__c = COMPACTOR;
brlst[0].AssetId__c = null;
brlst[0].locationid__c = null;
brlst[0].Category_Type__c = null;

brlst[1].Material__c = 'Trash';
brlst[1].Container__c = COMPACTOR;
brlst[1].AssetId__c = null;
brlst[1].locationid__c = null;
brlst[1].Category_Type__c = null;  
Database.Update(brlst);
BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);


//Material
brlst[0].Material__c = 'Trash';
brlst[0].Container__c = Constant_Util.EMPTY_STRING;
brlst[0].AssetId__c = null;
brlst[0].locationid__c = null;
brlst[0].Category_Type__c = null;

brlst[1].Material__c = 'Trash';
brlst[1].Container__c = Constant_Util.EMPTY_STRING;
brlst[1].AssetId__c = null;
brlst[1].locationid__c = null;
brlst[1].Category_Type__c = null;                               

Database.Update(brlst);
BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
*/
        }
    }
    
    @isTest static void approvalBusiessRuleWithReason(){
        
      user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
       system.runAs(currentuser){
            map<Id,Account> accmap = new map<Id,Account>([select id,Brand__c,Division__c,Location_Type__c,Geography__c from Account where Recordtype.name =: Constant_Util.LOCATION limit 1]);
            
            list<case> caselist = [select id, origin, contactid, Case_Type__c,Contact_Title__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,OwnerId,
                                   Service_Date__c,SLA_Service_Date_Time__c from case where status =: Constant_Util.PENDING limit 1];
            system.debug('caselist@@@@'+caselist);
            map<Id,Asset> asmap = new map<Id,Asset>([select Id,Duration__c,Product2.ProductTypeSelected__c,Project_Code__c,Material_Type__c from Asset where id =: caselist[0].assetid LIMIT 1]);
            list<Business_Rule__c> brlst = [select Id,RecordTypeId,Required_Information__c,AccountId__c,Request_Type__c,Container__c,LocationId__c,Service__c,Schedule_Type__c,End_Date__c,Project_Code__c,AssetId__c,Channel__c,Multiple_Mandatory_Approvers__c,Occurrence_Limit__c,Material__c,
                                            Category_Type__c,Group__c,No_Approval_Required__c,Effective_Date__c,Active__c,(Select Id,Account_Team_Member__c,Business_Rule__c,RecordTypeId,Title__c,Account_Department__c,External_Approver_Email__c,External_Approver_Phone_Number__c,Account_Title__c,
                                                                                                                           Approver_Type__c,Email__c,User__c,ServiceApprover__c,SortBy__c,Approver_Contact__c,Title__r.Name,Approver_Contact__r.FirstName,Approver_Contact__r.LastName,Account_Team_Member__r.FirstName,Account_Team_Member__r.LastName,User__r.FirstName,Requester_Only__c,
                                                                                                                           User__r.LastName from Approver_Entities__r Order BY SortBy__c  ASC) from  Business_Rule__c LIMIT 2];
            
            Asset assetlst = [select Id,Duration__c,Product2.ProductTypeSelected__c,Project_Code__c,Material_Type__c from Asset where id =: caselist[0].assetid LIMIT 1];
            
            System.debug('brlst@@@'+brlst);
            map<Id,Business_Rule__c> brmap = new map<Id,Business_Rule__c>();
            brmap.Put(caselist[0].Id,brlst[0]);
            
            list<Service_Approver__c> salst = [Select Id, Business_Rule__c,Title__c,RecordType.DeveloperName,Requester_Only__c from Service_Approver__c where Business_Rule__c =:brlst[0].Id  LIMIT 49999];
            system.debug('salst@@@@'+salst);
            
            Project_Code__c pc = [Select Id from Project_Code__c Limit 1];
            Categorization__c cg = [Select Id from Categorization__c Limit 1];
            
            Test.startTest();
            
           //Reason
                  caselist[0].Case_Sub_Type__c = Constant_Util.EMPTY_AND_RETURN;
                  caselist[0].Case_Reason__c = 'Contaminated';
                  Database.update(caselist);
                  
          System.debug('######***case'+caselist);
           
                  brlst[0].AssetId__c = null;
                  brlst[0].Active__c = false;
                  brlst[0].LocationId__c = null;
                  Database.update(brlst);

                  
                  brlst[0].Project_Code__c = null;
           		  brlst[0].Request_Type__c = 'Pickup';
           		  brlst[0].Service__c = Constant_Util.EMPTY_AND_RETURN;
                  brlst[0].Case_Reason__c = 'Contaminated';  
                  brlst[0].Active__c = true;
            
                  Database.Update(brlst);

           System.debug('######business'+brlst);
           
                  BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);  
           test.stopTest();
   	 }
	}
    
    @isTest static void approvalBusiessRuleWithSchedule(){
        
      user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
       system.runAs(currentuser){
            map<Id,Account> accmap = new map<Id,Account>([select id,Brand__c,Division__c,Location_Type__c,Geography__c from Account where Recordtype.name =: Constant_Util.LOCATION limit 1]);
            
            list<case> caselist = [select id, origin, contactid, Case_Type__c,Contact_Title__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,OwnerId,
                                   Service_Date__c,SLA_Service_Date_Time__c from case where status =: Constant_Util.PENDING limit 1];
            system.debug('caselist@@@@'+caselist);
          
           list<Business_Rule__c> brlst = [select Id,RecordTypeId,Required_Information__c,AccountId__c,Request_Type__c,Container__c,LocationId__c,Service__c,Schedule_Type__c,End_Date__c,Project_Code__c,AssetId__c,Channel__c,Multiple_Mandatory_Approvers__c,Occurrence_Limit__c,Material__c,
                                            Category_Type__c,Group__c,No_Approval_Required__c,Effective_Date__c,Active__c,(Select Id,Account_Team_Member__c,Business_Rule__c,RecordTypeId,Title__c,Account_Department__c,External_Approver_Email__c,External_Approver_Phone_Number__c,Account_Title__c,
            
                                                                                                                           Approver_Type__c,Email__c,User__c,ServiceApprover__c,SortBy__c,Approver_Contact__c,Title__r.Name,Approver_Contact__r.FirstName,Approver_Contact__r.LastName,Account_Team_Member__r.FirstName,Account_Team_Member__r.LastName,User__r.FirstName,Requester_Only__c,                                                                                                            User__r.LastName from Approver_Entities__r Order BY SortBy__c  ASC) from  Business_Rule__c LIMIT 2];
        
            Product2 p1 = [Select Id, ProductTypeSelected__c from Product2 Limit 1];
            Asset assetlst = [select Id,Duration__c,Product2.ProductTypeSelected__c,Project_Code__c,Material_Type__c from Asset where id =: caselist[0].assetid LIMIT 1];
            
           	assetlst.Duration__c = 'Temporary';
           assetlst.Material_Type__c = 'Trash';
           
           Database.update(assetlst);         
           System.debug('######***case'+assetlst);
           
           map<Id,Asset> asmap = new map<Id,Asset>([select Id,Duration__c,Product2.ProductTypeSelected__c,Project_Code__c,Material_Type__c from Asset where id =: caselist[0].assetid LIMIT 1]);
           map<Id,Business_Rule__c> brmap = new map<Id,Business_Rule__c>();
           
            brmap.Put(caselist[0].Id,brlst[0]);
            
            list<Service_Approver__c> salst = [Select Id, Business_Rule__c,Title__c,RecordType.DeveloperName,Requester_Only__c from Service_Approver__c where Business_Rule__c =:brlst[0].Id  LIMIT 49999];
            system.debug('salst@@@@'+salst);
            
            Project_Code__c pc = [Select Id from Project_Code__c Limit 1];
            Categorization__c cg = [Select Id from Categorization__c Limit 1];
           
            Test.startTest();
           
            //Material,container,scheduletype
           
            brlst[0].Active__c = false;          
            brlst[0].locationid__c = null;
            brlst[0].AssetId__c = null;
           
            brlst[1].Active__c = false;            
            brlst[1].locationid__c = null;
            brlst[1].AssetId__c = null;
            Database.Update(brlst);
            
            brlst[0].Active__c = true;
            brlst[0].Material__c = 'Trash';
            brlst[0].Schedule_Type__c =  'Temporary';
            brlst[0].Container__c = COMPACTOR; 
           
            brlst[1].Active__c = true;
            brlst[1].Material__c = 'Trash';
            brlst[1].Schedule_Type__c =  'Temporary';
            brlst[1].Container__c = COMPACTOR;
           
            Database.Update(brlst);
           
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            Test.stopTest();
   	 }
	}
    
     @isTest static void approvalBusiessRuleWithContainer(){
        
      user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
       system.runAs(currentuser){
            map<Id,Account> accmap = new map<Id,Account>([select id,Brand__c,Division__c,Location_Type__c,Geography__c from Account where Recordtype.name =: Constant_Util.LOCATION limit 1]);
            
            list<case> caselist = [select id, origin, contactid, Case_Type__c,Contact_Title__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,OwnerId,
                                   Service_Date__c,SLA_Service_Date_Time__c from case where status =: Constant_Util.PENDING limit 1];
            system.debug('caselist@@@@'+caselist);
          
           list<Business_Rule__c> brlst = [select Id,RecordTypeId,Required_Information__c,AccountId__c,Request_Type__c,Container__c,LocationId__c,Service__c,Schedule_Type__c,End_Date__c,Project_Code__c,AssetId__c,Channel__c,Multiple_Mandatory_Approvers__c,Occurrence_Limit__c,Material__c,
                                            Category_Type__c,Group__c,No_Approval_Required__c,Effective_Date__c,Active__c,(Select Id,Account_Team_Member__c,Business_Rule__c,RecordTypeId,Title__c,Account_Department__c,External_Approver_Email__c,External_Approver_Phone_Number__c,Account_Title__c,
            
                                                                                                                           Approver_Type__c,Email__c,User__c,ServiceApprover__c,SortBy__c,Approver_Contact__c,Title__r.Name,Approver_Contact__r.FirstName,Approver_Contact__r.LastName,Account_Team_Member__r.FirstName,Account_Team_Member__r.LastName,User__r.FirstName,Requester_Only__c,                                                                                                            User__r.LastName from Approver_Entities__r Order BY SortBy__c  ASC) from  Business_Rule__c LIMIT 2];
        
            Product2 p1 = [Select Id, ProductTypeSelected__c from Product2 Limit 1];
            Asset assetlst = [select Id,Duration__c,Product2.ProductTypeSelected__c,Project_Code__c,Material_Type__c from Asset where id =: caselist[0].assetid LIMIT 1];
            
           //	assetlst.Duration__c = 'Temporary';
           assetlst.Material_Type__c = 'Trash';
           
           Database.update(assetlst);         
           System.debug('######***case'+assetlst);
           
           map<Id,Asset> asmap = new map<Id,Asset>([select Id,Duration__c,Product2.ProductTypeSelected__c,Project_Code__c,Material_Type__c from Asset where id =: caselist[0].assetid LIMIT 1]);
           map<Id,Business_Rule__c> brmap = new map<Id,Business_Rule__c>();
           
            brmap.Put(caselist[0].Id,brlst[0]);
            
            list<Service_Approver__c> salst = [Select Id, Business_Rule__c,Title__c,RecordType.DeveloperName,Requester_Only__c from Service_Approver__c where Business_Rule__c =:brlst[0].Id  LIMIT 49999];
            system.debug('salst@@@@'+salst);
            
            Project_Code__c pc = [Select Id from Project_Code__c Limit 1];
            Categorization__c cg = [Select Id from Categorization__c Limit 1];
           
            Test.startTest();
           
            //Material,container,scheduletype
           
            brlst[0].Active__c = false;          
            brlst[0].locationid__c = null;
            brlst[0].AssetId__c = null;
           
            brlst[1].Active__c = false;            
            brlst[1].locationid__c = null;
            brlst[1].AssetId__c = null;
            Database.Update(brlst);
            
            brlst[0].Active__c = true;
            brlst[0].Material__c = 'Trash';
            brlst[0].Schedule_Type__c =  null;
            brlst[0].Container__c = COMPACTOR; 
           
            brlst[1].Active__c = true;
            brlst[1].Material__c = 'Trash';
            brlst[1].Schedule_Type__c =  null;
            brlst[1].Container__c = COMPACTOR;
           
            Database.Update(brlst);
           
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            Test.stopTest();
   	 }
	}
    
     @isTest static void approvalBusiessRuleWithMaterial(){
        
      user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
       system.runAs(currentuser){
            map<Id,Account> accmap = new map<Id,Account>([select id,Brand__c,Division__c,Location_Type__c,Geography__c from Account where Recordtype.name =: Constant_Util.LOCATION limit 1]);
            
            list<case> caselist = [select id, origin, contactid, Case_Type__c,Contact_Title__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,OwnerId,
                                   Service_Date__c,SLA_Service_Date_Time__c from case where status =: Constant_Util.PENDING limit 1];
            system.debug('caselist@@@@'+caselist);
          
           list<Business_Rule__c> brlst = [select Id,RecordTypeId,Required_Information__c,AccountId__c,Request_Type__c,Container__c,LocationId__c,Service__c,Schedule_Type__c,End_Date__c,Project_Code__c,AssetId__c,Channel__c,Multiple_Mandatory_Approvers__c,Occurrence_Limit__c,Material__c,
                                            Category_Type__c,Group__c,No_Approval_Required__c,Effective_Date__c,Active__c,(Select Id,Account_Team_Member__c,Business_Rule__c,RecordTypeId,Title__c,Account_Department__c,External_Approver_Email__c,External_Approver_Phone_Number__c,Account_Title__c,
            
                                                                                                                           Approver_Type__c,Email__c,User__c,ServiceApprover__c,SortBy__c,Approver_Contact__c,Title__r.Name,Approver_Contact__r.FirstName,Approver_Contact__r.LastName,Account_Team_Member__r.FirstName,Account_Team_Member__r.LastName,User__r.FirstName,Requester_Only__c,                                                                                                            User__r.LastName from Approver_Entities__r Order BY SortBy__c  ASC) from  Business_Rule__c LIMIT 2];
        
            Product2 p1 = [Select Id, ProductTypeSelected__c from Product2 Limit 1];
            Asset assetlst = [select Id,Duration__c,Product2.ProductTypeSelected__c,Project_Code__c,Material_Type__c from Asset where id =: caselist[0].assetid LIMIT 1];
            
           //	assetlst.Duration__c = 'Temporary';
           assetlst.Material_Type__c = 'Trash';
           
           Database.update(assetlst);         
           System.debug('######***case'+assetlst);
           
           map<Id,Asset> asmap = new map<Id,Asset>([select Id,Duration__c,Product2.ProductTypeSelected__c,Project_Code__c,Material_Type__c from Asset where id =: caselist[0].assetid LIMIT 1]);
           map<Id,Business_Rule__c> brmap = new map<Id,Business_Rule__c>();
           
            brmap.Put(caselist[0].Id,brlst[0]);
            
            list<Service_Approver__c> salst = [Select Id, Business_Rule__c,Title__c,RecordType.DeveloperName,Requester_Only__c from Service_Approver__c where Business_Rule__c =:brlst[0].Id  LIMIT 49999];
            system.debug('salst@@@@'+salst);
            
            Project_Code__c pc = [Select Id from Project_Code__c Limit 1];
            Categorization__c cg = [Select Id from Categorization__c Limit 1];
           
            Test.startTest();
           
            //Material,container,scheduletype
           
            brlst[0].Active__c = false;          
            brlst[0].locationid__c = null;
            brlst[0].AssetId__c = null;
           
            brlst[1].Active__c = false;            
            brlst[1].locationid__c = null;
            brlst[1].AssetId__c = null;
            Database.Update(brlst);
            
            brlst[0].Active__c = true;
            brlst[0].Material__c = 'Trash';
            brlst[0].Schedule_Type__c =  null;
            brlst[0].Container__c = null; 
           
            brlst[1].Active__c = true;
            brlst[1].Material__c = 'Trash';
            brlst[1].Schedule_Type__c =  null;
            brlst[1].Container__c = null;
           
            Database.Update(brlst);
           
            BusinessRuleHelper.businessRuleSelection(caselist,new set<Id>{brlst[0].RecordTypeId,brlst[1].RecordTypeId},new set<Id>{caselist[0].Client__c},new set<string>{caselist[0].Case_Type__c},new set<string>{caselist[0].Case_Sub_Type__c},asmap,accmap);
            Test.stopTest();
   	 }
	}
}