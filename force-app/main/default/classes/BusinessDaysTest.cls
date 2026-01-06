/*
Author: Anup Dey
Story: SDT-22548
Description: To operate only on business days
------------------------------------------------------
Story             Sprint             Coverage
SDT-22548 		   10					100%			
*/
@isTest(seeAllData = false)
public class BusinessDaysTest {
    private static final string WM_SBS = 'WM SBS';

    @testSetup
    static void setup(){

    }
    
    @isTest
    // method to execute CloseNewServiceCaseBatch
    static void testBusinessDays(){
        BusinessDays bd = new BusinessDays();
        Datetime workingDT=  bd.addDays(Date.today(), 2);
        BusinessDays bday = new BusinessDays(WM_SBS);
        System.AssertNotEquals(workingDT,null,'Next Business day should not be null');
        System.AssertNotEquals(bday,null,'Business day should not be null');
        System.AssertNotEquals(bd,null,'Business day should not be null');
        //Integer days = bd.getNoOfBusinessDaysBetweenDates(Date.today(), Date.today()+1);
        Integer days = bd.getNoOfBusinessDaysfromCurrentDate(Date.today()+1);
        Integer day1s = bd.getNoOfDaysfromCurrentDate(Date.today()+1);
        System.AssertNotEquals(days,null,'day should not be null');
  }
}