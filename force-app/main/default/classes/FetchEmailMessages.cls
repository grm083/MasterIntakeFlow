public with sharing class FetchEmailMessages {
    @AuraEnabled
	public Static List<EmailMessage> getAllRelatedEmailTasks(Id eMessageId){
        
        EmailMessage em=[select Id,RelatedToId from EmailMessage where id=:eMessageId];
        return [select Id,ParentId,Parent.CaseNumber,Parent.Case_Type__c,Parent.Case_Sub_Type__c,Parent.Location_Code__c,Parent.Case_Sub_Status__c,Parent.Status,toLabel(Status),FromAddress,Subject,MessageDate from EmailMessage where RelatedToId=:em.RelatedToId ORDER BY MessageDate DESC NULLS LAST];
    }
    @AuraEnabled
	public Static List<EmailMessage> getSearchedEmailMessages(Integer limits,Integer offsets,String searchKeyWord,String fromDate,String toDate,String subject){
        
        List<OrgWideEmailAddress> lstEmailAddress = [select Id,Address from OrgWideEmailAddress WHERE DisplayName=: Constant_Util.EMAIL_TO_QUOTE];
        //Adding this below list size check condition since we are getting List Index Out of bound errors while deployment
        if(lstEmailAddress.size() > 0) {
        String emailValue = lstEmailAddress[0].Address;
        }
        String searchKey = '%' + searchKeyWord + '%';
        String query='select Id,ParentId,Parent.CaseNumber,Parent.Case_Type__c,Parent.Case_Sub_Type__c,Parent.Location_Code__c,Parent.Case_Sub_Status__c,Parent.Status,toLabel(Status),FromAddress,Subject,MessageDate from EmailMessage';
		if(!String.isBlank(searchKeyWord))
        {
            query+=' where FromAddress  LIKE '+'\''+searchKey+'\'';
        }
        if(fromDate!=null )
        {
            if(!String.isBlank(searchKeyWord)){
            query+=' and DAY_ONLY(convertTimezone(MessageDate))  >= '+fromDate;
            }
            else{
            query+=' where DAY_ONLY(convertTimezone(MessageDate))  >= '+fromDate;
            }
        }
        if(toDate !=null)
        {
            if(!String.isBlank(searchKeyWord) || fromDate!=null){
            query+=' and DAY_ONLY(convertTimezone(MessageDate))  <= '+toDate;
            }
            else{
            query+=' where DAY_ONLY(convertTimezone(MessageDate))  <= '+toDate;
            }
        }
        if(subject!=null || !String.isBlank(subject))
        {
            String searchSubject = '%' + subject + '%';
            if(!String.isBlank(searchKeyWord) || fromDate!=null || toDate !=null){
            query+=' and Subject LIKE '+'\''+searchSubject+'\'';
            }
            else{
            query+=' WHERE Subject LIKE '+'\''+searchSubject+'\'';
            }
        }
        //added for SDT-20392
        query+= ' AND ((RelatedToId != null And FromAddress =: emailValue) OR FromAddress !=: emailValue )';	
        //added for SDT-20392
		query+=' ORDER BY MessageDate DESC NULLS LAST LIMIT '+limits+' OFFSET '+Integer.valueOf(offsets);
		return Database.query(query);
    }
    @AuraEnabled
	public Static Integer getSearchedEmailMessagesCount(String searchKeyWord,String fromDate,String toDate,String subject){
        String searchKey = '%' + searchKeyWord + '%';
        String query='select count(Id) rowCount from EmailMessage';
		if(!String.isBlank(searchKeyWord))
        {
            query+=' where FromAddress  LIKE '+'\''+searchKey+'\'';
        }
        if(fromDate!=null )
        {
            if(!String.isBlank(searchKeyWord)){
            query+=' and DAY_ONLY(convertTimezone(MessageDate))  >= '+fromDate;
            }
            else{
            query+=' where DAY_ONLY(convertTimezone(MessageDate))  >= '+fromDate;
            }
        }
        if(toDate !=null)
        {
            if(!String.isBlank(searchKeyWord) || fromDate!=null){
            query+=' and DAY_ONLY(convertTimezone(MessageDate))  <= '+toDate;
            }
            else{
            query+=' where DAY_ONLY(convertTimezone(MessageDate))  <= '+toDate;
            }
        }
        if(subject!=null || !String.isBlank(subject))
        {
            String searchSubject = '%' + subject + '%';
            if(!String.isBlank(searchKeyWord) || fromDate!=null || toDate !=null){
            query+=' and Subject LIKE '+'\''+searchSubject+'\'';
            }
            else{
            query+=' where Subject LIKE '+'\''+searchSubject+'\'';
            }
        }
        AggregateResult result;
        result=database.query(query);
        return (Integer)result.get('rowCount');
    }
}