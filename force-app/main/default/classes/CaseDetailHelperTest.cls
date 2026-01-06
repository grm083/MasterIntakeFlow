/**
* @author Accenture
* @date 4/16/2019
* @description : Apex class CaseDetailHelperTest 
**/

// test class for CaseDetailHelper
@isTest(seeAllData = false)
public class CaseDetailHelperTest {
    @testsetup
    static void setup(){
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            //modified by av4 as part of SDT-41134
            Test.startTest();
            list<Account> acclist = TestDataFactory.createAccount('test', usr);
            Database.insert(acclist);
            
            list<Account> acclist1 = TestDataFactory.createAccount('test', usr);
            Database.insert(acclist1);
            
            list<Account> acclist2 = TestDataFactory.createAccount('test', usr,'Client');
            Database.insert(acclist2);
            
            list<Account> locationlist = TestDataFactory.createLocation('Location', usr, acclist.get(0).id);
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact('first', 'last', acclist.get(0), usr);
            Database.insert(conlist);
            
            list<Business_Rule__c> Businessrulelist = TestDataFactory.createBusinessRule('first', acclist.get(0), 
                                                                                         locationlist.get(0));
            Database.insert(Businessrulelist);
            
            /*list<Approval_Log__c> approvalLoglist = TestDataFactory.createApprovallog();
Database.insert(approvalLoglist);*/
            
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(Businessrulelist.get(0));
            Database.insert(serviceApproverlist);
            
            list<product2> productlist = TestDataFactory.createProduct('test');
            Database.insert(productlist);
            
            
            list<Asset> assetlist = TestDataFactory.createAsset('first', acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            Database.insert(assetlist);
            
            list<Case> caselist1 = TestDataFactory.createCase('first', acclist.get(0), conlist.get(0), usr, 
                                                              locationlist.get(0), assetlist.get(0));
            Database.insert(caselist1);
            
            /*list<Case> caselist1 = TestDataFactory.createNewCasewithType(acclist.get(0), conlist.get(0), 
locationlist.get(0), assetlist.get(0));

Database.insert(caselist1);*/
            
            list<Approval_Log__c> approvalLoglist = TestDataFactory.createApprovallog(caselist1.get(0).id);
            Database.insert(approvalLoglist);
            
            list<Entitlement> entitlementlist = TestDataFactory.createEntitlement('test', locationlist.get(0));
            Database.insert(entitlementlist);
            Test.stopTest();
            list<Task> tasklist = TestDataFactory.createTask(caselist1.get(0).id, usr);
            Database.insert(tasklist);
            list<EmailMessage> EmailMessageList = TestDataFactory.createEmailMessage('test', 'testtest', caselist1.get(0));
            Database.insert(EmailMessageList);
            
            List<Account_Title__c> accTitleList = TestDataFactory.createAccountTitle(acclist[0],'test');
            database.insert(accTitleList);
            
            list<Case> caselist2 = TestDataFactory.createCase('first', acclist.get(0), conlist.get(0), usr, 
                                                              locationlist.get(0), assetlist.get(0));
            caselist2[0].Tracking_Number__c = 'T4353453';
            caselist2[0].ParentId = caselist1[0].id;
            Database.insert(caselist2);
            
        }
    }
    @isTest static void CaseDetailTest(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            Test.startTest();
            list<case> caselist = [select id, caseNumber, SLA_Override_Reason__c, Reference_Number__c from Case];
            List<account> accList = [select id,name,RecordTypeid,status__c from account];
            list<contact> conList = [select id,name,accountId from contact];
            list<Account> locationlist = [select id from Account where Name = 'Location' Limit 1];
            caselist.get(0).SLA_Override_Reason__c = 'Repairs';
            //caselist.get(0).Reference_Number__c = '00123456';
            update caselist;
            list<EmailMessage> EmailMessagelist = [select id from EmailMessage];
            
            string strcase = CaseDetailHelper.getCaseNumber(caselist[0].id);
            CaseDetailHelper.closedCloneCase(caselist[0].id);
            string strEmailCase = CaseDetailHelper.getCaseNumberFromEmail(EmailMessagelist[0].id);
            string strEmailMsgrecord = CaseDetailHelper.getEmailListId(EmailMessagelist[0].id);
            string strEmailrecord = CaseDetailHelper.getEmailSubject(EmailMessagelist[0].id);
            list<string> strlist = CaseDetailHelper.fetchRecordTypeValues();
            string strEmailCasercd = CaseDetailHelper.getCaseRecordtyeIdfromCase(caselist[0].id);
            string fieldsrecord = CaseDetailHelper.getFields();
            string emailList = null;
            CaseDetailHelper.cloneCaseDetails(caselist[0].id);
            caseDetailHelper.getRecTypeId(Constant_Util.SERVICE_REQUEST_CASE);
            CaseDetailHelper.createContactTitle(acclist[0].Id,'testLogin');
            CaseDetailHelper.getAccountContactsFromCase(caseList[0].Id,'test');
            CaseDetailHelper.getAccountTitlesForCase(caseList[0].id);
            CaseDetailHelper.getCaseContactId(caselist[0].id);
            caseDetailHelper.setCaseContactId(caseList[0].id,conlist[0].id,locationlist[0].id,true);
            CaseDetailHelper.getContactTitleId(conlist[0].id);
            emailList = CaseDetailHelper.getCopyEmailList(caselist[0].id);
            // Test.stopTest();
            String jsonParams = '{"AccountId":"'+acclist[0].Id+'","FirstName":"first","LastName":"last","Phone":"9999999999","MobilePhone":"","Email":"","Location__c":"'+locationlist[0].id+'"}';
            Contact newContact = (Contact)json.deserialize(jsonParams, Contact.class);
            CaseDetailHelper.checkExisting(caseList[0].id, jsonParams);
            CaseDetailHelper.getEmailList(EmailMessagelist[0].id);
CaseDetailHelper.getEmailList(caselist[0].id);// Modified for SDT-33447
            
            CaseDetailHelper.getAccountContactsFromCase(caseList[0].Id,'first');
            Database.insert(newContact);
            CaseDetailHelper.createContactLocationAssociation(newContact.Id,locationlist[0].id);
            caseDetailHelper.setCaseContactId(caseList[0].id,newContact.Id,locationlist[0].id,false);
            Test.stopTest();
            System.assertNotEquals(emailList, Constant_Util.EMPTY_STRING);            
        }
    }
    
    @isTest static void testCheckChild(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentUser){
            Test.startTest();
            List<Case> caselist = [SELECT Id, ParentId FROM Case WHERE ParentId != null];
            
            CaseDetailHelper.parentWrapper wrapper = CaseDetailHelper.checkChild(caselist[0].id);
            //Id theParentId = CaseDetailHelper.checkChild(caselist[0].id);
            Test.stopTest();
            System.assertEquals(wrapper.ParentId, caselist[0].ParentId);
        }
    }
    @isTest static void testEmailToComments(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentUser){
            list<EmailMessage> EmailMessagelist = [select Id, ParentId, TextBody, HtmlBody, Subject,MessageDate, FromName, FromAddress, ToAddress, CcAddress, BccAddress, toLabel(Status) from EmailMessage Limit 1];
            Test.startTest();
            Case ca = [SELECT Id, caseNumber FROM Case WHERE Id !=: EmailMessagelist[0].Id Limit 1];
            string emails = Json.serialize(EmailMessagelist);
            CaseDetailHelper.emailToComments((String)ca.Id,ca.caseNumber,emails);
            Test.stopTest();
            Comment__c comments = [Select Id,Comment__c from Comment__c where Case__c =: ca.Id Limit 1];
            string comment = Constant_Util.CASE_NUMBER + ca.caseNumber + Constant_Util.New_Line + Constant_Util.FROM_ADDRESS + EmailMessagelist[0].FromAddress + Constant_Util.New_Line + Constant_Util.TO_ADDRESS + EmailMessagelist[0].ToAddress + Constant_Util.New_Line + Constant_Util.CC_ADDRESS + (EmailMessagelist[0].CCAddress == null ? '' : EmailMessagelist[0].CCAddress + Constant_Util.New_Line) + Constant_Util.SUBJECT_EMAIL + EmailMessagelist[0].Subject + Constant_Util.New_Line + Constant_Util.MESSAGE_DATE + EmailMessagelist[0].MessageDate.format() + Constant_Util.New_Line;
            comment = comment + Constant_Util.TEXT_BODY_EMAIL + EmailMessagelist[0].TextBody;
            //System.assertEquals(comment, comments.Comment__c);
        }
    }
    
}