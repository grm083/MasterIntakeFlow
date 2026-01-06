/*************************************************************
@Author: Ayushi Sharma
@Date: 26/02/2019
@group:EmailMessage
@Description: Helper Class to Perform operations on EmailMessage

**************************************************************/
public without sharing class EmailMessageHelper {

/*************************************************************
@Description: This method is Invoked from the Process Builder
@param :objectName EmailMessage List<EmailMessage>
@return:void

**************************************************************/ 

    @InvocableMethod(label='Invocable Email Message Method' description='It is invocable method for the EmailMessage')
    public static void emailMessage(List<EmailMessage> lstEmailMessage){
        try{
            parseEmailMessage(lstEmailMessage);
        }
        catch(Exception e){
            
            System.debug('Exception::::'+e.getStackTraceString() +e.getMessage());
        } 
    }
    
/*************************************************************
@Description: This method is used to parse the Email Message.It extracts the Location Code and then updates on the Case.
@param :objectName EmailMessage List<EmailMessage>
@return:void

**************************************************************/

    public static void parseEmailMessage(List<EmailMessage> lstEmailMessage){
        List<Case> lstCase = new List<Case>();
        List<Account> lstLocation = new List<Account>();
        List<Asset> lstAsset = new List<Asset>();
        String strPattern = Constant_Util.EMAIL_MESSAGE_PATTERN;
        String strLocCodePattern = Constant_Util.LOCATION_CODE_PATTERN;
        String result = null;
        Map<Id,String> mapCaseLocCode = new Map<Id,String>(); 
        Map<String,List<Account>> mapLocationCode = new map<String,List<Account>>();
        Map<String,List<Asset>> mapLocAsset = new map<String,List<Asset>>();
        Map<Id,Id> mapCaseEM = new map<Id,Id>();
        List<Case> lstCaseUpdate = new List<Case>();
        List<Account> lstAccount = new List<Account>();
        List<Asset> assetLst = new List<Asset>();      
        for(EmailMessage objEmailMessage : lstEMailMessage)
        {
            result = patternParsing(strPattern, strLocCodePattern, objEmailMessage.Subject,objEmailMessage.TextBody);
            System.debug(' after null check' + result);
            if(result != null){
                System.debug(' after null check' + result);
                mapCaseLocCode.put(objEmailMessage.ParentId,result);
                mapCaseEM.put(objEmailMessage.ParentId,objEmailMessage.Id);
                System.debug(' after maoCaseLocCode' + mapCaseLocCode);
                System.debug(' after mapCaseEM' + mapCaseEM);
            }    
        }
        lstCase = [select Id,Location__c,Client__c,Asset.AccountId  from Case where id=: mapCaseLocCode.keySet() LIMIT 49999];
        lstLocation = [select Id,Name,Location_Code__c,ParentId , Parent.Customer_Code__c, Parent.Primary_Segment__c  from Account where 
                       Location_Code__c =: mapCaseLocCode.values() AND RecordType.DeveloperName =: Constant_Util.LOCATION AND
                       Status__c = 'Active' LIMIT 49999];
        if(lstLocation.size()>0){
            for(Account objAccount: lstLocation){
                if(String.isNotBlank(objAccount.Location_Code__c)){
                    if(!mapLocationCode.containsKey(objAccount.Location_Code__c)) {
                        mapLocationCode.put(objAccount.Location_Code__c, new List<Account>());
                    }
                    mapLocationCode.get(objAccount.Location_Code__c).add(objAccount);
                }
            }  
        }
        lstAsset = [SELECT Id, AccountId, Location__r.Location_Code__c FROM Asset WHERE Location__r.Location_Code__c =: mapLocationCode.keySet() AND 
                    RecordType.DeveloperName =: Constant_Util.SERVICE_HEADER and Is_Active__c = true];
        if(lstAsset.size()>0){
            for(Asset objAsset: lstAsset){
                if(String.isNotBlank(objAsset.Location__r.Location_Code__c)){
                    if(!mapLocAsset.containsKey(objAsset.Location__r.Location_Code__c)) {
                        mapLocAsset.put(objAsset.Location__r.Location_Code__c, new List<Asset>{objAsset});
                    }
                    else {
                        List<Asset> assetList = mapLocAsset.get(objAsset.Location__r.Location_Code__c);
                        assetList.add(objAsset);
                        mapLocAsset.put(objAsset.Location__r.Location_Code__c,assetList);
                    }
                }
            }  
        }
        if(lstCase.size()>0){
            for(Case objCase : lstCase){
                if(mapCaseLocCode.containsKey(objCase.Id)){
                    String locCode = mapCaseLocCode.get(objCase.Id);
                    if(mapLocationCode.containsKey(locCode)){
                        lstAccount = mapLocationCode.get(locCode);
                        
                        if(lstAccount.size()==1){
                            objCase.Location__c = lstAccount[0].Id;
                            objCase.Client__c = lstAccount[0].ParentId;
                            
                            if(mapLocAsset.containsKey(lstAccount[0].Location_Code__c)){
                                assetLst = mapLocAsset.get(lstAccount[0].Location_Code__c);
                            }
                            
                            if(assetLst.size() == 1){
                                objCase.AssetId = assetLst[0].Id;
                            }   
                            else{
                                objCase.AssetId = null;
                            }
                            lstCaseUpdate.add(objcase);
                            
                            ID EMId  = mapCaseEM.get(objCase.Id);
                            
                        }
                    }
                }
            }    
        }   
        
        if(!lstCaseUpdate.isEmpty()){
            Database.update(lstCaseUpdate, true); 
        }
        
        
    }
    
/*************************************************************
@Description: This method is used for the Pattern Parsing
@param : String strPattern,String strLocCodePattern,String Subject,String EmailBody
@return: string

**************************************************************/

    public static string patternParsing(String strPattern,String strLCPattern, String Subject,String EmailBody){
        String result = null;
        String locCoderesult = null;
        String strPattern2 = Constant_Util.EMAIL_MESSAGE_PATTERN2;
        String strLCPattern2  = Constant_Util.LOCATION_CODE_PATTERN2;
        Set<String> setlocCode = new Set<String>();
        String content = Subject + '|' + EmailBody;
        
        // Search Second Pattern
        Matcher patternMatch2 = Pattern.compile(strPattern2).matcher(Content);
        while (patternMatch2.find()) {
            result = patternMatch2.group(); 
        
            //Match Location Code
            String locCode = result.substringAfterLast(' ');
            
            if(locCode != null){
                locCoderesult = locCode;
                setlocCode.add(locCode); 
            }
        }
        if(setlocCode.size()==1){
            return locCoderesult;
        }else{
            return null; 
        }
    }
    
}