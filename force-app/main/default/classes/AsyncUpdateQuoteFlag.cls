public class AsyncUpdateQuoteFlag implements Queueable {
    
    public  List<Id> insertedGenesysIdList;
    public String action;
    
    public AsyncUpdateQuoteFlag(List<Id> insertedGenesysIdList,String action){
        this.insertedGenesysIdList = insertedGenesysIdList ;  
        this.action = action;
    }
    public void execute(QueueableContext context) {
        List<Id> upQuoteList = new List<Id>();
        Map<id,String> quoteServiceFlag = new Map<id,String>();
        
        for(Genesys_Routing__c gen : [Select Id,SFDCServiceFlag__c,SFDCObjRecordID__c from Genesys_Routing__c Where Id In:insertedGenesysIdList])
        {
            upQuoteList.add(gen.SFDCObjRecordID__c);
            quoteServiceFlag.put(gen.SFDCObjRecordID__c,gen.SFDCServiceFlag__c);
        }
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : [Select Id,Genesys_Record_Created__c from SBQQ__Quote__c Where Id In:upQuoteList])
        {
            if(action == Constant_Util.STATUS_NEW)
            {
                quote.Genesys_Record_Created__c = true;
                quote.GR_Service_Flag__c = quoteServiceFlag.get(quote.id);//SDT- 23339 Update GR Service Flag of Quote
                quote.Is_Genesys_Required__c = false ;//SDT-23088 Update this field to false so that it cannot be picked by Batch(which is creating Genesys Record).
            }  
            else 
            {
                quote.Genesys_Record_Created__c = false;
                quote.GR_Service_Flag__c = quoteServiceFlag.get(quote.id);//SDT- 23339 Update GR Service Flag of Quote
            }       
            quoteList.add(quote);
        }       
        
         update quoteList;
    }         
}