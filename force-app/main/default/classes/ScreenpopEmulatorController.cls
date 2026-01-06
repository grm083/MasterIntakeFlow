public class ScreenpopEmulatorController {
    public static final string EqlTo = '=';
    public static final String BASE_URL = URL.getSalesforceBaseUrl().toExternalForm() 
        + '/apex/Screenpop?' + ScreenpopController.PARAM_MEDIA_TYPE + EqlTo;
    
    public String PageTitle {
        get {
            String env = UserInfo.getUserName();
            env = env == null ? Constant_Util.EMPTY_STRING : env.substringAfterLast('.').trim();
            return Constant_Util.EMPTY_STRING.equals(env) ? 'PRODUCTION' : 'Sandbox: ' + env.toUpperCase();
        }
    }
    
    public Boolean MediaTypeToggle { get; set; }
    public String MediaType { get; set; }    
    public String ReferenceNumber { get; set; }    
    public String GenesysId { get; set; }    
    public String IntentSelected { get; set; }
    public String AccountSelected { get; set; }
    public String LocationSelected { get; set; }
    public String AssetSelected { get; set; }
    public String ContactSelected { get; set; }
    public String ScreenpopUrl { get; set; }
    public String tpFlag { get;set; }
    //Added by Venkat V to include IVR attached data
    public String ivrqueue { get; set; }
    public String ivrlanguage { get; set; }
    public String ivrlob { get; set; }
    public String ivrexitpoint { get; set; }
    public String ivrsseligible { get; set; }
    public String ivrsseligiblestatus { get; set; }
    public String ivrsseligiblepickup { get; set; }
    public String ivrdnis { get; set; }
    public String ivrani { get; set; }
    public string pickDate { get; set;}
    public string ivrr4c { get; set;}
    public string workOrder { get; set;}
    public string quote { get; set;}
    public string isVendor { get; set;}

    //Added as part of SDT-17701
    public String ivrSpokenName {get;set;}
    public String ivrIntentName  {get;set;}
    public String ivrSpokenLoc  {get;set;}
    public String ivrSpokenRefNum  {get;set;}
    //Added as part of SDT-17701
    
    //Added as part of SDT-18313
    public String ivrSpokenIntent {get;set;}
    //Added as part of SDT-18313
    
    public String ivrSubTypeReturn { get; set; } // SDT-23351
    
    public List<SelectOption> LocationList { get; set; }
    public List<SelectOption> assetselectList { get; set; }
    public List<SelectOption> ContactList { get; set; }
    
    public ScreenpopEmulatorController() {
        MediaType = ScreenpopController.MEDIA_TYPE_VOICE;
        IntentSelected = ScreenpopController.INTENT_PICKUP;
        GenesysId = Constant_Util.EMPTY_STRING;
        AccountSelected = Constant_Util.EMPTY_STRING;
        LocationSelected = Constant_Util.EMPTY_STRING;
        ContactSelected = Constant_Util.EMPTY_STRING;
        assetselectList = new List<SelectOption>();
    }
    
    public void updateScreenpopUrl() {
        system.debug('MediaType : ' + MediaType);
        if(MediaType != null && !Constant_Util.EMPTY_STRING.equals(MediaType) && ScreenpopController.MEDIA_TYPE_CHAT.equals(MediaType)){
            ScreenpopUrl = BASE_URL + Constant_Util.EMPTY_STRING;
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_IVRMEDIA + EqlTo + MediaType + Constant_Util.AMPERSAND;
        }else{
            ScreenpopUrl = BASE_URL + MediaType + Constant_Util.AMPERSAND;
        }        
        ScreenpopUrl += (ScreenpopController.MEDIA_TYPE_VOICE.equals(MediaType)) || (ScreenpopController.MEDIA_TYPE_CHAT.equals(MediaType)) ? ScreenpopController.PARAM_CONNECTION_ID : ScreenpopController.PARAM_INTERACTION_ID;
        ScreenpopUrl += EqlTo + getGenesysId();
        
        if(ivrSubTypeReturn != null && !Constant_Util.EMPTY_STRING.equals(ivrSubTypeReturn)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_SUBTYPE_TEMPRETURN + EqlTo + ivrSubTypeReturn;
        }
        if(ReferenceNumber != null && !Constant_Util.EMPTY_STRING.equals(ReferenceNumber)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_REF_NO + EqlTo + ReferenceNumber;
        }else{}
        if(!string.isBlank(workOrder)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_IVRWO + EqlTo + workOrder;
        }
        if(!string.isBlank(quote)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_SFDCRecId + EqlTo + quote;
        }
        if((ScreenpopController.MEDIA_TYPE_VOICE.equals(MediaType)) || (ScreenpopController.MEDIA_TYPE_CHAT.equals(MediaType)) && AccountSelected != null && !Constant_Util.EMPTY_STRING.equals(AccountSelected)) {
            
            if(IntentSelected != null && !Constant_Util.EMPTY_STRING.equals(IntentSelected)){
                ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_INTENT + EqlTo + IntentSelected;
                
                ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_ACCT_ID + EqlTo + AccountSelected;
            }else{}
            if(LocationSelected != null && !Constant_Util.EMPTY_STRING.equals(LocationSelected)){
                ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_LOCATION_ID + EqlTo + LocationSelected;
            }else{}
            if(AssetSelected != null && !Constant_Util.EMPTY_STRING.equals(AssetSelected)){
                ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_ASSET_ID + EqlTo + AssetSelected;
            }else{}
            if(ContactSelected != null && !Constant_Util.EMPTY_STRING.equals(ContactSelected)){
                ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_CONTACT_ID + EqlTo + ContactSelected; 
            }else{}
        }else{}
        
        if(!string.Isblank(ivrr4c)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_IVR4C + EqlTo + ivrr4c;
        }
        if(ivrqueue != null && !Constant_Util.EMPTY_STRING.equals(ivrqueue)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_IVRQueue + EqlTo + ivrqueue;
        }
        if(ivrlanguage != null && !Constant_Util.EMPTY_STRING.equals(ivrlanguage)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_IVRlang + EqlTo + ivrlanguage;
        }
        
        if(ivrlob != null && !Constant_Util.EMPTY_STRING.equals(ivrlob)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_IVRLOB + EqlTo + ivrlob;
        }
        if(ivrexitpoint != null && !Constant_Util.EMPTY_STRING.equals(ivrexitpoint)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_IVREXITpOINT + EqlTo + ivrexitpoint;
        }
        if(ivrsseligible != null && !Constant_Util.EMPTY_STRING.equals(ivrsseligible)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_IVRSELF + EqlTo + ivrsseligible;
        }
        if(ivrsseligiblestatus != null && !Constant_Util.EMPTY_STRING.equals(ivrsseligiblestatus)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_IVRSELF_STATUS + EqlTo + ivrsseligiblestatus;
        }
        if(ivrsseligiblepickup != null && !Constant_Util.EMPTY_STRING.equals(ivrsseligiblepickup)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_IVRSELF_PICKUP + EqlTo + ivrsseligiblepickup;
        }
        if(!string.isblank(isVendor)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_IVRVENDOR + EqlTo + isVendor;
        }
        if(ivrdnis != null && !Constant_Util.EMPTY_STRING.equals(ivrdnis)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_IVRDNIS + EqlTo + ivrdnis;
        }
        if(ivrani != null && !Constant_Util.EMPTY_STRING.equals(ivrani)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_IVRANI + EqlTo + ivrani;
        }
        if(!String.isBlank(pickDate)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_PICKUP_Date + EqlTo + pickDate;
        }

        //Below parameters added as part of SDT-17701
        if(ivrSpokenName != null && !Constant_Util.EMPTY_STRING.equals(ivrSpokenName)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_SPOKEN_NAME + EqlTo + ivrSpokenName;
        }
        if(ivrIntentName != null && !Constant_Util.EMPTY_STRING.equals(ivrIntentName)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_INTENT_NAME + EqlTo + ivrIntentName;
        }
        if(ivrSpokenLoc != null && !Constant_Util.EMPTY_STRING.equals(ivrSpokenLoc)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_SPOKEN_LOC + EqlTo + ivrSpokenLoc;
        }
        if(ivrSpokenRefNum != null && !Constant_Util.EMPTY_STRING.equals(ivrSpokenRefNum)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_SPOKEN_REF + EqlTo + ivrSpokenRefNum;
        }
        // Above parameter added as part of SDT-17701
       //Below parameter added as part of SDT-18313
         if(ivrSpokenIntent != null && !Constant_Util.EMPTY_STRING.equals(ivrSpokenIntent)){
            ScreenpopUrl += Constant_Util.AMPERSAND + ScreenpopController.PARAM_SPOKEN_INTENT + EqlTo + ivrSpokenIntent;
        }
       // Above parameter added as part of SDT-18313
    }
    
    private String getGenesysId() {
        
        if(GenesysId == null || Constant_Util.EMPTY_STRING.equals(GenesysId)) { 
            
            Long randomId = 0;            
            while(randomId == 0)
                randomId = crypto.getRandomLong();
            
            return (randomId < 0 ? randomId * -1 : randomId) + Constant_Util.EMPTY_STRING;
        }else{}
        
        return GenesysId;
    } 
    
    public void toggleOnMediaType() {     
        
        if((ScreenpopController.MEDIA_TYPE_VOICE.equals(MediaType)) || (ScreenpopController.MEDIA_TYPE_CHAT.equals(MediaType))) {
            MediaTypeToggle = false;
        } 
        else { MediaTypeToggle = true;
              IntentSelected = 'other';
              AccountSelected = Constant_Util.EMPTY_STRING;
              loadAccountLists();
             }
        
        updateScreenpopUrl();        
    }
    
    public List<SelectOption> getAccountList() {
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constant_Util.EMPTY_STRING, 'Select Account'));
        
        List<Account> accounts = 
            [select Id, Name from Account where 
             RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId() 
	     and Status__c =: Constant_Util.ACTIVE order by Name limit 999];
        System.debug('>>>>> ScreenpopEmulatorController.getAccountList: accounts count = ' + accounts.size());
        
        for(Account a : accounts)            
            options.add(new SelectOption(a.Id, a.Name));
        
        return options;        
    }
    
    public void loadAccountLists() {
        LocationSelected = Constant_Util.EMPTY_STRING;
        ContactSelected = Constant_Util.EMPTY_STRING;
        loadLocationList();
        loadContactList();
    }
    
	public void loadLocationList() {       
        
        if(LocationList == null){
            LocationList = new List<SelectOption>();
        } else{   
            LocationList.clear();
        }
        if(Constant_Util.EMPTY_STRING.equals(AccountSelected)){
            return;
        }else{}        
        List<Account> accounts = 
            [select Id, Name from Account where ParentId =: AccountSelected 
	    and RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location').getRecordTypeId() 
	    and Status__c =: Constant_Util.ACTIVE order by Name limit 999];
        
        if(accounts.size() > 0) {            
            LocationList.add(new SelectOption(Constant_Util.EMPTY_STRING, 'Select Location'));            
            for(Account a : accounts) {          
                LocationList.add(new SelectOption(a.Id, a.Name));            
            }
        }else{}
        updateScreenpopUrl();        
    }    
    
    private List<Asset> fetchassetlist(){
        system.debug('LocationSelected$$$'+LocationSelected);
        Id recTypeId = Schema.SobjectType.Asset.getRecordTypeInfosByDeveloperName().get('Service_Header').getRecordTypeId();
        return [Select Id, Name from Asset where Location__c = : LocationSelected AND RecordTypeId = :recTypeId AND Is_Active__c = true LIMIT 999];
    }
    public void loadContactList() {              
        
        if(ContactList == null){
            ContactList = new List<SelectOption>();
        }
        else{
            ContactList.clear();
        }
        if(Constant_Util.EMPTY_STRING.equals(AccountSelected)){
            return;        
        }else{}
        List<Contact> contacts = Constant_Util.EMPTY_STRING.equals(LocationSelected)
            ? [select Id, Name from Contact where AccountId =: AccountSelected and Contact_Status__c =: Constant_Util.ACTIVE order by Name limit 999]
            : [select Id, Name from Contact where Contact_Status__c =: Constant_Util.ACTIVE and Id in (select ContactId from AccountContactRelation where AccountId =: LocationSelected) order by Name limit 999];
                
                if(contacts.size() > 0) {            
                    ContactList.add(new SelectOption(Constant_Util.EMPTY_STRING, 'Select Contact'));            
                    for(Contact c : contacts)            
                        ContactList.add(new SelectOption(c.Id, c.Name));
                }else{}            
        if(!assetselectList.isEmpty() && assetselectList.size() == 0){
            assetselectList = new List<SelectOption>();
        }else {
            assetselectList.clear();
        }
        If(!string.isBlank(LocationSelected)){
            List<Asset> astlist = fetchassetlist();
            system.debug('Asset List'+astlist);
            if(!astlist.isEmpty() && astlist.size() > 0) {            
                assetselectList.add(new SelectOption(Constant_Util.EMPTY_STRING, 'Select Container'));            
                for(Asset a : astlist) {          
                    assetselectList.add(new SelectOption(a.Id, a.Name));            
                }
            }else{}
            system.debug('assetselectList'+assetselectList);
        }
        updateScreenpopUrl();        
    }

} // class