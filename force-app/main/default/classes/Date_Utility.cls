public class Date_Utility {
	/* Author	: TCS
	 * Method Name : getDateTimeInGMTForGivenDateTime
     * Description : The method to convert datetime value from any given timezone to GMT for processing Pricing logic in ACORN.
     * JIRA ID : SDT 29615
     */ 
    public static DateTime getDateTimeInGMTForGivenDateTime(DateTime objGivenDT){
        DateTime objDateTimeGMT;
        if(objGivenDT!=null)
        {
            objDateTimeGMT = DateTime.newInstanceGMT(objGivenDT.yearGMT(),objGivenDT.monthGMT(),objGivenDT.dayGMT(),12, 00, 00);
        }
        return objDateTimeGMT;
    }
}