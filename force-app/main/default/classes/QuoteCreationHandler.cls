/*************************************************************
@Name: QuoteCreationHandler
@Author: TCS (Jatan sharma)
@CreateDate: 19/08/24
@Description: QuoteCreationHandler Event for creating quote for IVR New service Process.
@UsedBy: SDT-40344 ,SDT-31997
**************************************************************/
public class QuoteCreationHandler implements IHandler{
    
    public static Map<string,sobject> execute(Map<string,sobject> caseDataMap) {
        Map<string,sobject>  returnMap = caseDataMap;
        List<Case> caseList  =new List<Case>();
        string quoteId;
        string failureMessage;
      try{
        // Code for getting data from PE
        caseList  = caseDataMap.values();
        //Currently skiping this section we will take care of this in future solution.
        //Defaulting current value to true as for current configuration this will always be true.
        //GetCaseInformation.Wrapper wrapperClass = GetCaseInformation.getCaseMessages(caseList[0].Id);
        //boolean addQuote = wrapperClass.addQuoteVisibility;
        boolean addQuote = true;
        if(addQuote)
        {
          quoteId = GetCaseInformation.createOppQuote(caseList[0].Id);
        }
        system.debug('quoteId '+ quoteId);
        if(String.isBlank(quoteId) || addQuote == false)
        {
          failureMessage = addQuote == false ?' Quote visiblity validation. ' : ' No Quote ID available. ';
        }
        if(string.isNotBlank(quoteId))
        {
          SBQQ__Quote__c quote= new SBQQ__Quote__c();
          quote.id = quoteID;
          returnMap.put(quoteID,quote );
          system.debug('QuoteHandler Return '+returnMap);
        }

        if(string.isNotBlank(failureMessage)){
          System.debug('failureMessage '+failureMessage);
          IVRUtility.taskandGenesysRouting(caseList,'Unable to create Quote',failureMessage);
          IVRUtility.createIVRExceptionLogObj('Execute',failureMessage,'QuoteCreationHandler');
          return null;
        }
      }
      catch(exception ex){
        system.debug('QuoteHandler Exception '+ex.getMessage());
        IVRUtility.taskandGenesysRouting(caseList,'Unable to create Quote',ex.getMessage());
        IVRUtility.createIVRExceptionLogObj('Execute',ex.getMessage(),'QuoteCreationHandler');
        return null;
      }
       
        return returnMap;  
    }
    
}