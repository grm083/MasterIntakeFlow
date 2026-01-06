public without sharing class ReopenAcornTicket {
    
    @future(callout=true)
    public static void reassignTicket(Set<String> trackNumber){
        for(String trck : trackNumber)
        {
            String result = IntegrationHandlerUtil.getMetadataDetails('Reopen_Ticket',trck,true);
            RESTHelper.AcornResponse jsonResp = (RESTHelper.AcornResponse) JSON.deserialize(result, RESTHelper.AcornResponse.Class);
            System.debug('jsonResp ' + jsonResp);
        }
    }

}