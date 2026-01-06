@isTest
public class dynamicCardControllerTest {
    static testMethod void validateGetCaseDetails() {
        Case c = new Case();
        
        insert c;
        
        Case b = dynamicCardController.getCaseDetails(c.Id);
        
        System.assertEquals(c, b);
    }
}