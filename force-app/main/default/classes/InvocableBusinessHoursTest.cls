@isTest(seeAllData = false)
public class InvocableBusinessHoursTest {
	public static testmethod void calculateFollowupTime(){
        List<DateTime> followUpTimes = new List<DateTime>();
        List<InvocableBusinessHours.QuoteFollowUpParameters> listQuoteFollowupParam= new List<InvocableBusinessHours.QuoteFollowUpParameters>();
        InvocableBusinessHours.QuoteFollowUpParameters objQuoteFollowUp1= new InvocableBusinessHours.QuoteFollowUpParameters();
        objQuoteFollowUp1.delayMinutes= 60;
        objQuoteFollowUp1.quoteStartDate= date.Today();
        objQuoteFollowUp1.quoteStatus= Constant_Util.QUOTE_DRAFT;
        listQuoteFollowupParam.add(objQuoteFollowUp1);
        InvocableBusinessHours.QuoteFollowUpParameters objQuoteFollowUp2= new InvocableBusinessHours.QuoteFollowUpParameters();
        objQuoteFollowUp2.delayMinutes= 60;
        objQuoteFollowUp2.quoteStartDate= date.Today()+16;
        objQuoteFollowUp2.quoteStatus= Constant_Util.QUOTE_PRODUCT_CONFIGURED;
        listQuoteFollowupParam.add(objQuoteFollowUp2);
        InvocableBusinessHours.QuoteFollowUpParameters objQuoteFollowUp3= new InvocableBusinessHours.QuoteFollowUpParameters();
        objQuoteFollowUp3.delayMinutes= 60;
        objQuoteFollowUp3.quoteStartDate= date.Today()+47;
        objQuoteFollowUp3.quoteStatus= Constant_Util.QUOTE_PRODUCT_CONFIGURED;
        listQuoteFollowupParam.add(objQuoteFollowUp3);
        Test.startTest();
        followUpTimes= InvocableBusinessHours.calculateBusinessTime(listQuoteFollowupParam);
        Test.stopTest();
    }
}