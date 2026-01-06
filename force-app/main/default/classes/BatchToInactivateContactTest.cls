@isTest
public class BatchToInactivateContactTest {
	static testMethod void testMethod1() 
    {
        List<Contact> lstContact= new List<Contact>();
        
        Contact con2 = new Contact();
        con2.lastName ='WM';
        con2.Contact_Status__c = 'Active';
        con2.Phone = '9899999900';
        con2.Last_Activity_Date__c = Null;
        insert con2;
        
        
        for(Integer i=0 ;i <10;i++)
        {
            Contact con = new Contact();
            con.lastName ='WM'+i;
            con.Contact_Status__c = 'Active';
            con.Phone = '9899999999';
            
            con.Last_Activity_Date__c = system.now()+i;
            lstContact.add(con);
        }
        
        insert lstContact;

        Test.startTest();

            BatchToInactivateContact obj = new BatchToInactivateContact();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}