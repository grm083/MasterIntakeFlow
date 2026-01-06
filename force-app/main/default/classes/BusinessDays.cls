/*
Author: Anup Dey
Story: SDT-22548
Description: To operate only on business days
*/
public class BusinessDays {
    public List<BusinessHours> bHours;

    public BusinessDays(String businessHoursName){
        //get business hours
        bHours = [SELECT Id, MondayStartTime, TuesdayStartTime, WednesdayStartTime, ThursdayStartTime, FridayStartTime, SaturdayStartTime, SundayStartTime FROM BusinessHours WHERE Name =: businessHoursName];
    }
     
    public BusinessDays(){
        //If no business hours name provided in paramaterized constructor, use deafault hours
        bHours = [SELECT Id, MondayStartTime, TuesdayStartTime, WednesdayStartTime, ThursdayStartTime, FridayStartTime, SaturdayStartTime, SundayStartTime FROM BusinessHours WHERE IsDefault = true];
    }

    //Add number of working days in a date
    public Datetime addDays(Datetime startDate, Integer days)
    {
        BusinessHours bHour = new BusinessHours();
        //checking if business hour is empty and null
        if(!bHours.isEmpty() && bHours !=null)
            bHour = bHours[0];

        //If startdate is not within working days, take next working day
        startDate = BusinessHours.nextStartDate(bHour.Id, startDate);
		
        for (Integer elapsed = 1; elapsed <= days; elapsed++)
        {
            //Add 1 day
            startDate = startDate.addDays(elapsed);
            
            //Check if new date is within working days
            // if (!BusinessHours.isWithin(bHour.Id, startDate))
            // { 
            //     //If new date is not within working days, get new working day
            //     startDate = BusinessHours.nextStartDate(bHour.Id, startDate);
            // }
        }
        return startDate;
    }

    //get the no of business days from given date
    public Integer getNoOfBusinessDaysfromCurrentDate( DateTime endDate){
        BusinessHours bHour = new BusinessHours();
        //checking if business hour is empty and null
        if(!bHours.isEmpty() && bHours !=null)
            bHour = bHours[0];
        datetime startDate = Datetime.now();
        Integer count = 0;
        while(startDate <= endDate){
            if(BusinessHours.isWithin(bHour.Id, startDate)){
                count++;
            }
            startDate = startDate.addDays(1);
        }
        return count;
    }

    //Added for story SDT-25213.
    //Developer: Anup dey / Jatan sharma
    //get the no of business days from given date
    public Integer getNoOfDaysfromCurrentDate(DateTime endDate){
        BusinessHours bHour = new BusinessHours();
        //checking if business hour is empty and null
        if(!bHours.isEmpty() && bHours !=null)
            bHour = bHours[0];
        datetime updatedStartDate = Datetime.now();
        datetime startDate = Datetime.now();
        // Time variable with default value
        Time updateCurrentTime = Time.newInstance(0, 0, 0, 0);
        Integer count = 0;
        while(startDate <= endDate){
            // Get Week Day from start Date
            String weekDay = startDate.format('EEEE');
            if(!String.isEmpty(weekDay))
            {
                switch on weekDay {
                    when 'Monday' {
                        if(bHour.MondayStartTime!=null)
                            updateCurrentTime = bHour.MondayStartTime;
                    }
                    when 'Tuesday' {
                        if(bHour.TuesdayStartTime!=null)
                            updateCurrentTime = bHour.TuesdayStartTime;
                    }
                    when 'Wednesday' {
                        if(bHour.WednesdayStartTime!=null)
                            updateCurrentTime = bHour.WednesdayStartTime;
                    }
                    when 'Thursday' {
                        if(bHour.ThursdayStartTime!=null)
                            updateCurrentTime = bHour.ThursdayStartTime;
                    }
                    when 'Friday' {
                        if(bHour.FridayStartTime!=null)
                            updateCurrentTime = bHour.FridayStartTime;
                    }
                    when 'Saturday' {
                        if(bHour.SaturdayStartTime!=null)
                            updateCurrentTime = bHour.SaturdayStartTime;
                    }
                    when else {
                        if(bHour.SundayStartTime!=null)
                            updateCurrentTime = bHour.SundayStartTime;
                    }
                }
                updatedStartDate = DateTime.newInstance(startDate.Date(),updateCurrentTime);
            }
           
            if(BusinessHours.isWithin(bHour.Id, updatedStartDate)){
               system.debug('Within block'+ updatedStartDate);
                count++;
            }

            startDate = startDate.addDays(1);
        }
        system.debug('Count >'+ count);
        return count;
    }
    
}