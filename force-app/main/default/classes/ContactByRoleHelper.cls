/**
* @author Accenture
* @date 6/20/2019
* @description : Controller class for ContactByRoleComponent lightning component
**/
Public Without Sharing class ContactByRoleHelper {
    
    public static final string BLANKSTR = '';
    public static final string CASESTARTID = '500';
    public static final string WORK_ORDER_START_ID = '0WO';
    public static final string UNDEFINED = 'undefined';
    public static final string ALL = 'All';
    public static final string SEMICOLON = ';';
    
    /**
    * @author Accenture
    * @date 3/25/2019
    * @description : method to create retrieve the list of contact associated to the vendor account
    **/
    @AuraEnabled
    Public static string retrieveContact(string recId){
        string roleClassString = BLANKSTR;
        String accountId = BLANKSTR;
        try{
            if(recId != null && recId != BLANKSTR && recId != UNDEFINED){
                if(recId.startsWith(CASESTARTID)){
                    List<case> caseList = new List<case>();
                    caseList = [Select Id,AccountId,Supplier__c,Client__c,Location__c from Case where Id=:recId limit 1];
                    if(caseList != null && !caseList.isEmpty()){
                        for(case caseRec : caseList){
                            if(caseRec.Supplier__c != null){
                                accountId = caseRec.Supplier__c;
                            }
                        }
                    }
                } else  if(recId.startsWith(WORK_ORDER_START_ID)){
                    List<WorkOrder> woList = new List<WorkOrder>();
                    woList = [Select Id, Vendor_Account_Id__c from WorkOrder where Id=:recId limit 1];
                    if(!woList.isEmpty() && woList[0].Vendor_Account_Id__c != null){
                        accountId = woList[0].Vendor_Account_Id__c;
                    }
                }
                else{
                    accountId = recId;
                }
                if(accountId != null && accountId != BLANKSTR){
                    set<string> groupSet = new Set<string>{ALL};
                        set<string> roleSet = new Set<string>();
                    
                    List<AccountContactRelation> conListForAccount = new List<AccountContactRelation>();
                    conListForAccount = [SELECT Id, ContactId,Contact.Phone,Contact.MobilePhone,Contact.Email,Contact.Preferred_Method__c,Contact.Name, Roles,
                                                Account_Record_Type__c,Tech_Contact_Created_Date__c, Tech_Contact_Status__c, Relationship_Strength__c 
                                         FROM AccountContactRelation 
                                         where AccountId =: accountId 
                                         LIMIT 50000];
                                         
                    Map<string,List<contactClass>> contactByRoleMap = new Map<string,List<contactClass>>();
                    List<RoleClass> roleClassList = new List<RoleClass>();
                    if(conListForAccount != null && !conListForAccount.isEmpty()){
                        for(AccountContactRelation relation :conListForAccount){
                            string role = relation.Roles;
                            if(role != null && role != BLANKSTR){
                                if(role.contains(SEMICOLON)){
                                    List<String> roleStrList = role.split(SEMICOLON);
                                    if(roleStrList!= null && !roleStrList.isEmpty()){
                                        for(string roleStr : roleStrList ){
                                            contactClass conCls = new contactClass();
                                            conCls.conId = relation.contactId;
                                            conCls.conEmail = relation.Contact.Email;
                                            conCls.conPhone = relation.Contact.phone;
                                            conCls.conName = relation.Contact.Name;
                                            conCls.conMobilePhone = relation.Contact.MobilePhone;
                                            conCls.preferredMethod= relation.Contact.Preferred_Method__c;
                                            conCls.role = roleStr;
                                            if(contactByRoleMap  != null && !contactByRoleMap.isEmpty() && contactByRoleMap.containskey(roleStr)){
                                                contactByRoleMap.get(roleStr).add(conCls);
                                            }
                                            else{
                                                contactByRoleMap.put(roleStr,new List<contactClass>{conCls});
                                            }          
                                        }
                                    }
                                }
                                else{                       
                                    contactClass conCls = new contactClass();
                                    conCls.conId = relation.contactId;
                                    conCls.conEmail = relation.Contact.Email;
                                    conCls.conPhone = relation.Contact.phone;
                                    conCls.conName = relation.Contact.Name;
                                    conCls.conMobilePhone = relation.Contact.MobilePhone;
                                    conCls.preferredMethod = relation.Contact.Preferred_Method__c;
                                    conCls.role = role;
                                    if(contactByRoleMap  != null && !contactByRoleMap.isEmpty() && contactByRoleMap.containskey(role)){
                                        contactByRoleMap.get(role).add(conCls);
                                    }
                                    else{
                                        contactByRoleMap.put(role,new List<contactClass>{conCls});
                                    }        
                                }
                            }
                        }
                        system.debug('contacts per role'+contactByRoleMap);
                        Account vendorAccnt = [select id,Vendor_Group__c,AccountNumber from Account where id =:accountId limit 1];
                        String vendorGroup = BLANKSTR;
                        if(vendorAccnt != null && vendorAccnt.Vendor_Group__c != null){
                            vendorGroup = vendorAccnt.Vendor_Group__c;
                        }
                        Map<string,Integer> roleOrderMap = new Map<string,Integer>();
                        Map<String,List<String>> levelRoleMap = new MAp<String,List<String>>();
                        Map<String,Integer> levelOrderMap = new Map<String,Integer>();
                        if(vendorGroup  != null && vendorGroup != BLANKSTR){ 
                            List<Vendor_Contact_Role_Map__mdt> accountRoleList = new List<Vendor_Contact_Role_Map__mdt>();
                            accountRoleList = [Select Group__c,Role__c, Order__c,Level__c,Level_Order__c from Vendor_Contact_Role_Map__mdt WHERE Group__c =:vendorGroup Order by Order__c ASC LIMIT 5000];
                            if(accountRoleList != null && !accountRoleList.isEmpty()){
                                for(Vendor_Contact_Role_Map__mdt actGroupRole : accountRoleList ){
                                    roleOrderMap.put(actGroupRole.Role__c, Integer.valueOf(actGroupRole.Order__c));
                                    if(levelRoleMap  != null && !levelRoleMap.isEmpty() && levelRoleMap.containskey(actGroupRole.Level__c)){
                                        levelRoleMap.get(actGroupRole.Level__c).add(actGroupRole.Role__c);
                                    }
                                    else{
                                        levelRoleMap.put(actGroupRole.Level__c,new List<String>{actGroupRole.Role__c});
                                    }
                                    //levelRoleMap.put(actGroupRole.Level__c,actGroupRole.Role__c);
                                    if(!levelOrderMap.containsKey(actGroupRole.Level__c)){
                                        levelOrderMap.put(actGroupRole.Level__c,Integer.valueOf(actGroupRole.Level_Order__c));
                                    }
                                    
                                }
                            }
                        }
                        List<LevelClass> finalList = new List<LevelClass>();
                        if(levelRoleMap != null && !levelRoleMap.isEmpty()){
                            for(String level : levelRoleMap.keyset()){
                                if(levelOrderMap != null && !levelOrderMap.isEmpty() && levelOrderMap.containsKey(level)){
                                    LevelClass levelClassval = new LevelClass();
                                    levelClassval.levelName = level;
                                    levelClassval.orderNo = levelOrderMap.get(level);
                                    
                                    for(String levelrole : levelRoleMap.get(level)){
                                        if(contactByRoleMap != null && !contactByRoleMap.isempty() && contactByRoleMap.containskey(levelrole)){
                                            if(roleOrderMap != null && !roleOrderMap.isEmpty() && roleOrderMap.containskey(levelrole)){
                                                RoleClass roleClassVal = new RoleClass();
                                                roleClassVal.role = levelrole;
                                                roleClassVal.orderNo = roleOrderMap.get(levelrole);
                                                roleClassVal.conList = new List<contactClass>();
                                                roleClassVal.conList = contactByRoleMap.get(levelrole);
                                                levelClassval.roles.add(roleClassVal);
                                            }
                                        }
                                    }
                                    if(levelClassval.roles != null && !levelClassval.roles.isempty() && levelClassval.roles.size() > 0){
                                        List<RoleClass> roleClassRcrds= levelClassval.roles;
                                        if(roleClassRcrds!= null && !roleClassRcrds.isEmpty()){  
                                            for(integer listVal=0;listVal<roleClassRcrds.size(); listVal++){
                                                for(Integer loopVal= listVal+1; loopVal<roleClassRcrds.size();loopVal++){
                                                    if( roleClassRcrds[listVal].orderNo > roleClassRcrds[loopVal].orderNo){
                                                        RoleClass roleClassVal = roleClassRcrds[listVal];
                                                        roleClassRcrds[listVal]= roleClassRcrds[loopVal];
                                                        roleClassRcrds[loopVal]= roleClassVal;
                                                    }        
                                                }                    
                                            }
                                        }
                                        finalList.add(levelClassval);
                                    }
                                }
                            }
                        }
                        
                        if(finalList!= null && !finalList.isEmpty()){  
                            for(integer listVal=0;listVal<finalList.size(); listVal++){
                                for(Integer loopVal= listVal+1; loopVal<finalList.size();loopVal++){
                                    if( finalList[listVal].orderNo > finalList[loopVal].orderNo){
                                        LevelClass levelClassVal = finalList[listVal];
                                        finalList[listVal]= finalList[loopVal];
                                        finalList[loopVal]= levelClassVal;
                                    }        
                                }                    
                            }
                            roleClassString = JSON.serialize(finalList);
                            system.debug('finallit'+finalList);
                        }
                    } 
                } 
            }
        }
        catch(Exception ex){
            system.debug('exception'+ex.getStackTraceString());
        }
        return roleClassString ;
    }
    /**
    * @author Accenture
    * @date 6/20/2019
    * @description : RoleClass used to store list of contacts by Role
    **/
    public Without Sharing class RoleClass{
        public string role{get;set;}
        public Integer orderNo{get;set;}
        public List<contactClass> conList{get;set;}
        public RoleClass(){
            conList = new List<contactClass>();
        }
    }
    /**
    * @author Accenture
    * @date 6/20/2019
    * @description : ContactClass used to store the List of contacts for the Role
    **/
    public Without Sharing class ContactClass{
        public string conId{get;set;}
        public string conEmail{get;set;}
        public string conName {get;set;}
        public string conPhone{get;set;}
        public string conMobilePhone{get;set;}
        public string preferredMethod{get;set;}
        public string role{get;set;}
    }
    
    
    public without sharing class LevelClass{
        public string levelName{get;set;}
        public Integer orderNo{get;set;}
        public List<RoleClass> roles = new List<RoleClass>();
    }
	
	@AuraEnabled
    Public static Boolean isCommChannelEnabled(string recId){
        Boolean isComm = False;
        try{
        String accountId = BLANKSTR;
        if(recId.startsWith(CASESTARTID)){
            List<case> caseList = new List<case>();
            caseList = [Select Id,AccountId,Supplier__c,Client__c,Location__c from Case where Id=:recId limit 1];
            if(caseList != null && !caseList.isEmpty()){
                for(case caseRec : caseList){
                    if(caseRec.Supplier__c != null){
                        accountId = caseRec.Supplier__c;
                    }
                }
            }
        } else  if(recId.startsWith(WORK_ORDER_START_ID)){
            List<WorkOrder> woList = new List<WorkOrder>();
            woList = [Select Id, Vendor_Account_Id__c from WorkOrder where Id=:recId limit 1];
            if(!woList.isEmpty() && woList[0].Vendor_Account_Id__c != null){
                accountId = woList[0].Vendor_Account_Id__c;
            }
        }
        else{
            accountId = recId;
        }
        if(accountId != null && accountId != BLANKSTR)
        {
            List<Account> accList = [select id,Category__c from Account where id =: accountId];
            if(!accList.isEmpty())
            {
                if(accList[0].Category__c == '' ||accList[0].Category__c == null)
                {
                    isComm = true;
                }
            }  
        }
        }
        catch(Exception e)
        {
           //
        }
        return isComm;
    }
}