/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest(seeAllData = false)
public class ServiceApproverFuzzyMatchTest {
    
    public static testmethod void testCheckFuzzyMatchTrue(){ 
        List<ServiceApproverFuzzyMatch.MethodInputWrapper> inputList = new List<ServiceApproverFuzzyMatch.MethodInputWrapper>();
        ServiceApproverFuzzyMatch.MethodInputWrapper input = new ServiceApproverFuzzyMatch.MethodInputWrapper();
        input.serviceApproverTitle = 'Senior Manager Head';
        input.contactTitle = 'Senior Manager Area Head';
        inputList.add(input);
        system.assertEquals(true , ServiceApproverFuzzyMatch.checkFuzzyMatch(inputList)[0]);
    }

    public static testmethod void testCheckFuzzyMatchFalse(){ 
        List<ServiceApproverFuzzyMatch.MethodInputWrapper> inputList = new List<ServiceApproverFuzzyMatch.MethodInputWrapper>();
        ServiceApproverFuzzyMatch.MethodInputWrapper input = new ServiceApproverFuzzyMatch.MethodInputWrapper();
        input.serviceApproverTitle = 'Regional Supervisor';  
        input.contactTitle = 'Regional Junior Manager';
        inputList.add(input);
        system.assertEquals(false , ServiceApproverFuzzyMatch.checkFuzzyMatch(inputList)[0]);
    }

}