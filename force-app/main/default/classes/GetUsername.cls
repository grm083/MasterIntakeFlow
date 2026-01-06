/**************************************************
* ClassName:GetBusinessDelayTime
* Author:Ayushi
* CreatedDate:30/4/2019
* **************************************************/
public class GetUsername {
    
    @InvocableMethod
    public static List<String> getName(List<string> inputstr) { 
        String strUsername;
        List<string> inputlst =  new  List<string>();
        for(String objstr : inputstr){
            strUsername =   objstr.substringBefore('@');
            inputlst.add(strUsername);
        }
        
        
       /* List<List<string>> lstString = new List<List<string>>();
        lstString.add(inputlst);
        */
        
        //system.debug('$$$'+lstString);
        return inputlst;
 	}
}