/* Apex Class : QuoteLineService
 * Description : This class send the quote line items JSON based on the quoteId 
 * Developer : Lovel Panchal (lpanchal@wm.com)
 * Date : 5-Feb-2021
 * Edit Comments :
 * //------------------------------------------------------------------------------
 * 
 * 
 * //------------------------------------------------------------------------------
 */
@RestResource(urlMapping='/ProcessQuoteLine/*')
global with sharing class QuoteLineService {
    @HttpGet
    global static void doGet() {
        String QuoteName = RestContext.request.params.get('QuoteName');
        system.debug(QuoteName);
        //TCS-pkulkarn-2-Sep-2024-SDT-41371-Tech Debt-Added 2nd parameter to below call
        String finalJSON = PricingJSONRequest.generatePricingJSON(QuoteName, true);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(finalJSON);
    }
   
    @HttpPost
    global static void UpdateStatus() {
       RestRequest restRqst = RestContext.request;
       PricingJSONRequest.updateQuoteLinesStatus(restRqst.requestBody.toString());
    }
      
}