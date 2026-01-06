/**************************************************
* ClassName:GetSFDCServiceFlag
* Author:WM
* CreatedDate:27/06/2023
* **************************************************/
public class GetSFDCServiceFlag {
    
    @InvocableMethod
    public static List<String> getServiceFlag(List<string> inputstr) { 
        String strUsername;
        String flag = 'CS';
        Boolean skip = false;
        //Integer count = 0;
        List<string> inputlst =  new  List<string>();
        List<string> userLst =  new  List<string>();
        //List<Integer> indexNumber = new List<Integer>();
        try{
            for(String uname : inputstr)
            {
                if(uname != '')
                {
                    strUsername = '%'+uname+'%';
                    userLst.add(strUsername);
                }
                /*else
                {
                    indexNumber.add(count); 
                }
                count++;*/
            }
            if(!userLst.isEmpty())
            {
                for(User u : [Select Id,UserName,User_categorization_code__c from User where username like : userLst AND isActive = true])
                {
                    if(u.User_categorization_code__c != null)
                    {
                        if(CSR_User_Data_Setup__mdt.getInstance(u.User_categorization_code__c) != null)
                        {
                            flag = CSR_User_Data_Setup__mdt.getInstance(u.User_categorization_code__c).GR_Service_Flag__c;
                        }
                        else
                        {
                            flag = 'CS'; 
                        }
                    }
                    else
                    {
                        flag = 'CS'; 
                    }
                    if(flag == null || flag == '')
                    {
                        flag = 'CS';
                    }
                    inputlst.add(flag);
                }
                
            }
            /*else
            {
                for(Integer i : indexNumber)
                {
                    inputlst.set(i, '');
                }
            }
            if(!indexNumber.isEmpty())
            {
                for(Integer i : indexNumber)
                {
                    inputlst.set(i, '');
                }
            }*/
            
        }
        Catch(Exception e)
        {
            UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.SERVICE_FLAG_CLASS,LoggingLevel.ERROR);
        }        
        return inputlst;
    }
}