/**********************
@Author: Saqib Qamar
@Name: BatchToInactivateContact
@Description:--------------
**************************************************************/
global class BatchToInactivateContact implements Database.Batchable<sObject>,Database.Stateful,schedulable{
    
    private static String query = 'Select Id, Name, Contact_Status__c, Last_Activity_Date__c,  Phone, Location__c from Contact Where Contact_Status__c = \'Active\' AND Phone != Null LIMIT 49999';
    List<Contact> sortedListOfContact = new List<Contact>();
    Integer targetsize = 0;
    public Database.QueryLocator start(Database.BatchableContext batchVariable) {
        return Database.getQueryLocator(query);
    } 
    
    global void execute(SchedulableContext sc){
      Database.executeBatch(new BatchToInactivateContact(),2000);   
    }
    
    public void execute(Database.BatchableContext batchVariable, List<Contact> contList) {
        List<Contact> contactListToUpdate = new List<Contact>();
        Map<Id,Contact> contactMapToRemoveDuplicateIds = new MAP<Id,Contact>();
        try{
            Map<String, List<Contact> > getContactsByPhone = new Map<String,List<Contact>> ();
            
            if(!contList.isEmpty()){
                for(Contact con :  contList){
				//No Date Stamp contacts
                    if(con.Last_Activity_Date__c == Null){
                        con.Contact_Status__c = 'Inactive';
                        contactListToUpdate.add(con);
                    }
					else{
				
                    if(getContactsByPhone.containsKey(con.Phone) && getContactsByPhone.get(con.Phone) != Null) {
                        List<Contact> contactList = getContactsByPhone.get(con.Phone);
                        contactList.add(con);
                        getContactsByPhone.put(con.Phone,contactList); 
                    }   
                    else {
                        getContactsByPhone.put(con.Phone, new List<Contact>{con});
                    }
                    
                    }
                }
                 
                List<Contact> inActiveContactList;
                for(String ph : getContactsByPhone.keySet()){
                    if(getContactsByPhone.get(ph).size() > 3 && getContactsByPhone.get(ph) != Null && !getContactsByPhone.get(ph).isEmpty()){
                         inActiveContactList = findInActiveContacts(getContactsByPhone.get(ph));
                    }  
                }
                
                if(inActiveContactList != Null){
                    for(Contact con : inActiveContactList){
                        con.Contact_Status__c = 'Inactive';
                        contactListToUpdate.add(con); 
                    }
                }
                
                contactMapToRemoveDuplicateIds.putall(contactListToUpdate);
                if(!contactMapToRemoveDuplicateIds.isEmpty()){
                    
                    Database.SaveResult[] svRes = Database.update(contactMapToRemoveDuplicateIds.values(),false); 
                } 
            }
        }
        catch(Exception e) { System.debug('Exception occured during Contact status to Inactive: '+e.getLineNumber()+' '+e.getMessage());}
    } 
       
    public void finish(Database.BatchableContext batchVariable) {} 
    
    public List<Contact> findInActiveContacts(List<Contact> contacts){
        List<Contact> contactListToInactive = new List<Contact>();
        if(contacts != Null && !contacts.isEmpty()){
            List<Contact> sortedList = new List<Contact>();
            sortedList = checkContactBasedOnPhone(contacts);
            if(sortedList.size() > 0){
                //Integer i = 0;
                for(Integer i = sortedList.size()-1; i >= 0; i--){
                    if(i >= 3){
                        contactListToInactive.add(sortedList.get(i)); 
                    } 
                }
            }
        }
        return contactListToInactive;
    }
    public List<Contact> checkContactBasedOnPhone(List<Contact> cons){
        if(cons != Null && !cons.isEmpty()){
            targetsize = cons.size();
            
            while(sortedListOfContact.size() != targetsize){
                  findMinLastActivityContact(cons);
            }
        }
        
        return sortedListOfContact;
    }
    
    public void findMinLastActivityContact(List<Contact> conList1){
        
        if(conList1!= Null && !conList1.isEmpty()){
            Integer mini = 0; 
            Datetime dt = conList1.get(0).Last_Activity_Date__c; 
            
            for(Integer i = 0; i < conList1.size(); i++){
                if(dt < conList1.get(i).Last_Activity_Date__c){ 
                    dt = conList1.get(i).Last_Activity_Date__c;
                    mini = i;
                }
            }             
    
            sortedListOfContact.add(conList1.get(mini));
            conList1.remove(mini);             
            }
        else {
            sortedListOfContact = new List<Contact>();
            targetsize = 0;
            
        }
    }
}