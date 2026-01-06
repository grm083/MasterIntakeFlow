/**************************************************
* ClassName:GetToAddress
* Author:Ayushi
* CreatedDate:12/8/2019
* **************************************************/
public class GetToAddress {
    @InvocableMethod
    //Method to get user name from input parameter
    public static List<List<string>> getName(List<EMailMessage> lstEmailMessage) { 
        String strUsername;
        List<string> toaddress =  new  List<string>();
        List<string> toAddrLst =  new  List<string>();
        List<List<string>> outputLst =  new  List<List<string>>();
        List<List<string>> tempLst =  new  List<List<string>>();
        set<string> owdEmailset = new set<string>();
        Map<String,String> mapToAddress = new Map<String,String>();
        map<Id,list<String>> toaddressmap = new map<Id,list<String>>();
        map<Id,list<String>> ccaddressmap = new map<Id,list<String>>();
        for(EmailMessage objEM : lstEmailMessage){
            if(objEM.ToAddress != null) {
                toaddressmap.put(objEM.Id, (objEM.ToAddress).split(Constant_Util.SEMI_COLON));
            }
            if(objEM.CCAddress != null) {
                ccaddressmap.put(objEM.Id, (objEM.CCAddress).split(Constant_Util.SEMI_COLON));
            }   
        }
        
        for(OrgWideEmailAddress owd : [SELECT Id,Address,CreatedDate from OrgWideEmailAddress order by CreatedDate]){
            owdEmailset.add(owd.Address);
        }
        for(EmailMessage email : lstEmailMessage){
            strUsername = Constant_Util.EMPTY_STRING;
            toaddress = new List<string>();
	    toAddrLst = new List<String>();
            if(!toaddressmap.isEmpty() && toaddressmap.size() > 0){
                for(string taddress : toaddressmap.get(email.Id)){
                    if(!owdEmailset.isEmpty() && owdEmailset.contains(taddress.trim()) && String.isBlank(strUsername)){
                        strUsername =  taddress.trim();
                        toAddrLst.add(strUsername);
                        outputLst.add(toAddrLst);
                        break;
                    } else if(toaddress.isEmpty() && toaddress.size() == 0 && String.isBlank(strUsername)){
                        toaddress.add(taddress.trim());
                        tempLst.add(toaddress);
                    }
                }
            }
            if(!ccaddressmap.isEmpty() && ccaddressmap.size() > 0 && String.isBlank(strUsername)){
                for(string caddress : ccaddressmap.get(email.Id)){
                    if(!owdEmailset.isEmpty() && owdEmailset.contains(caddress.trim()) && String.isBlank(strUsername)){
                        strUsername =  caddress.trim();
                        toAddrLst.add(strUsername);
                        outputLst.add(toAddrLst);
                        break;
                    }
                }
            }
        }        
        // If not found in both
        if((outputLst.isEmpty() && outputLst.size() == 0) && (!tempLst.isEmpty() && tempLst.size() > 0)){
            outputLst = tempLst;
        }
        return outputLst;
    }
}