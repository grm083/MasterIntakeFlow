/**************************************************
 * ClassName:SplitStringToListCntrlr
 * Author:Niranjan 
 * Description: This class was created as part of Release1-Sprint3 to convert String to List
 * CreatedDate:14/3/2019
 * **************************************************/
public Without Sharing class SplitStringToListCntrlr {
    @InvocableMethod
    public static List<List<string>> splitstring(List<string> inputstr) { 
        List<string> inputlst =  new  List<string>();
        List<List<string>> lstString = new List<List<string>>();
        set<string> returnset = new set<String>();
        for(String objStr : inputstr){
            inputlst = objStr.split(Constant_Util.SEMI_COLON);
            lstString.add(inputlst);
        }
        system.debug('####'+lstString);
        return lstString;
 }
 
}