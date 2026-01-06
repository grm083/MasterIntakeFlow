@isTest
public class CaseCustomLookUpControllerTest {
    @isTest static void CaseCustom(){
test.startTest(); //Modified for SDT-33444
        List<Account> accList = new List<Account>();
         Account acc = new Account();
         acc.Name = 'Test';
         acc.AccountNumber = '12345';
         accList.add(acc);
        Database.Insert(accList); //Modified for SDT-33444
         
         String searchKeyWord = 'Test';
         String ObjectName = 'Account';
         String FieldName = 'Name';
    
        CaseCustomLookUpController.fetchLookUpValues(searchKeyWord,ObjectName,FieldName);
          //ccl.fetchLookUpValues(searchKeyWord,ObjectName,FieldName);
          
         Integer count = [select count() from Account];
         System.assertEquals(1,count);
         test.stopTest(); //Modified for SDT-33444
    }
}