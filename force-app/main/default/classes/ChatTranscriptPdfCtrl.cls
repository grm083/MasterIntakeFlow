/**
* @date 25/05/2023
* @description : Get Chat Now Transcript is used for VF Page
**/
public class ChatTranscriptPdfCtrl {
    
    public List<ResponseWrapper> wrapperResList {get; set;}
    
    public ChatTranscriptPdfCtrl() {
        String result = ApexPages.CurrentPage().getparameters().get('resList');
        //system.debug('result :' + result);
        if(String.isNotBlank(result)){
            result = '{"Data":'+result+'}';
            DataWrapper wrap = (DataWrapper) (JSON.deserialize(result, DataWrapper.class));
            wrapperResList = new List<ResponseWrapper>();
            wrapperResList = wrap.Data;
        }
        //system.debug('wrapperResList : ' + wrapperResList);
    }
    public class DataWrapper {
        List<ResponseWrapper> Data {get; set;}
	}
    
    public class ResponseWrapper{
        @AuraEnabled
        public string userId {get; set;}
        @AuraEnabled
        public string messageText {get; set;}
        @AuraEnabled
        public string chatDateTime {get; set;}
        @AuraEnabled
        public string errorMessage {get; set;}
    }

}