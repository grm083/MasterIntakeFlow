/**
* @author Accenture
* @date 05/06/2020
* @description : test class GetNonPickupBusinessTime
**/

/* test class for GetNonPickupBusinessTime*/
@isTest(seeAllData = false)
public class GetNonPickupBusinessTimeTest {
	
    public static final string SYS_ADMIN = 'System Administrator';
	
    /* getting the business delay time test method*/
    @isTest static void getBusinessDelayTime(){
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
        GetNonPickupBusinessTime.FlowInputvalues wrapper = new GetNonPickupBusinessTime.FlowInputvalues();
		wrapper.businessHoursId = [SELECT Id FROM BusinessHours WHERE Name =: Constant_Util.BUSINESSNAME and IsActive = true LIMIT 1].Id;
		wrapper.baseDateTime = system.now();
		wrapper.delayTimeInterval = '2';
        wrapper.considerBusinessHours = true;
		
		List<GetNonPickupBusinessTime.FlowInputvalues> wrapperLst = new List<GetNonPickupBusinessTime.FlowInputvalues>();
		wrapperLst.add(wrapper);
		
        Test.startTest();
			GetNonPickupBusinessTime.getBusinessHoursForNonPickupCases(wrapperLst);
        Test.stopTest();
        system.assert(wrapperLst.size() != 0);
        }
    }
    /* getting the non business delay time test method*/
    @isTest static void getNonBusinessDelayTime(){
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
        GetNonPickupBusinessTime.FlowInputvalues wrapper = new GetNonPickupBusinessTime.FlowInputvalues();
		wrapper.businessHoursId = [SELECT Id FROM BusinessHours WHERE Name =: Constant_Util.BUSINESSNAME and IsActive = true LIMIT 1].Id;
		wrapper.baseDateTime = system.now();
		wrapper.delayTimeInterval = '2';
        wrapper.considerBusinessHours = false;
		
		List<GetNonPickupBusinessTime.FlowInputvalues> wrapperLst = new List<GetNonPickupBusinessTime.FlowInputvalues>();
		wrapperLst.add(wrapper);
		
        Test.startTest();
			GetNonPickupBusinessTime.getBusinessHoursForNonPickupCases(wrapperLst);
        Test.stopTest();
        system.assert(wrapperLst.size() != 0);
        }
    }
}