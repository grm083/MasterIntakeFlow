public class ExceptionModifier {
/*
* @Name          ExceptionModifier
* @Author        Rishan
* @Vendor        TCS
* @Date          06/12/2025
* @description   This class will be used to modify the validation error to remove class information from error message.
* @coverage      QuoteValidationHandlerTest.testTruncateException
*/
    
    public static final string FIELD_CUSTOM_VALIDATION_EXCEPTION = 'FIELD_CUSTOM_VALIDATION_EXCEPTION, ';
    
    public static string truncateException(String exceptionString)
    {
        
        exceptionString = (exceptionString !=null && exceptionString.contains(FIELD_CUSTOM_VALIDATION_EXCEPTION)) ?
            exceptionString.substringAfter(FIELD_CUSTOM_VALIDATION_EXCEPTION) : exceptionString;
        
        return exceptionString;
    }
}
