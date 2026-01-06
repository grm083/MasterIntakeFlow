/**
* @date 8/21/2019 
* @description : Test Class for customLookUpController 
**/
@isTest
public class customLookUpControllerTest {
    
    private static final string UserName = 'test';
    private static final string User = 'User';
    
    @isTest public static void testCustomLookUp()
    {
        test.startTest();
            
                 customLookUpController.fetchLookUpValues(UserName,User);
           
        test.stopTest();
       
    }
  }