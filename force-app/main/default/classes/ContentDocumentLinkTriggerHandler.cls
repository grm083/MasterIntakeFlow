public class ContentDocumentLinkTriggerHandler {
    public static void onAfterInsert(Map<Id,ContentDocumentLink> newMap){
        Map<Id,ContentDocumentLink> filteredMap = new Map<Id,ContentDocumentLink>();
        Set<Id> docIds = new Set<Id>();
        system.debug('map values'+newMap.values());
        for(ContentDocumentLink docLink : newMap.values()){
            system.debug('if check'+docLink.LinkedEntityId !=null+' 2 '+docLink.LinkedEntityId.getSObjectType().getDescribe().getName());
            if(docLink.LinkedEntityId !=null && docLink.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Case'){
                docIds.add(docLink.Id);
            }
        }
        if(docIds.size() > 0){
            for(ContentDocumentLink doc : [Select id,LinkedEntityId, ContentDocumentId,ContentDocument.title,ContentDocument.CreatedById,ContentDocument.CreatedDate from ContentDocumentLink where id IN: docIds]){
                filteredMap.put(doc.Id,doc);
            }
        }
        if(filteredMap.size() >0){
            CreateCaseHistory.createHistoryRecordOnRecordCreate(filteredMap);
        }

    }
}