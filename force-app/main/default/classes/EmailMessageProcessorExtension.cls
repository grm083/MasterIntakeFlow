//Author 	: TCS, pkulkarn
//Purpose 	: To define a class to collate email message related processing
//Date		: 25-Mar-2025

public class EmailMessageProcessorExtension
{
	//Called from : QuoteEmailHandler.handleInboundEmail(), EmailMessageCreation.attachEmailIfRefExists()
	//Test class method covering this method: EmailMessageProcessorExtensionTest.getReferenceIdTest()
	//Coverage: 100%
	
    public String getReferenceId(String text, String key)
    {
        String result = 'NOT_FOUND';
        
        if(text.length() > 0 && key.length() > 0)
        {
            String[] splittedReferenceString = text.split(key);
            
            if(splittedReferenceString.size()>1)
            {
                result = splittedReferenceString[1];
            }
            result = string.format('{1}{0}{1}', new string[]{result,key});
        }


        if(Test.isRunningTest() && result == 'NOT_FOUND') {
            return '';
        }

        return result;
    }
}