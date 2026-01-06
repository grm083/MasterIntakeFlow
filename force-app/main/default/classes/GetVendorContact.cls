/**************************************************
* ClassName:GetVendorContact
* **************************************************/
public class GetVendorContact {
        public class caseDetails {
        @InvocableVariable(label='Vendor Id' required=true)
        public string vendorId;
        @InvocableVariable(label='Product Family' required=true)
        public string prodFamily;

        }
    @InvocableMethod(label='Get 2nd Dispatch Vendor Contact' description='Returns the list of Business Hours Delay Resume Time to the flow.')
    public static List<String> getVendorContactList(List<caseDetails>caseDetailsList) {    
		List<String> vendorContactNameList = new List<String>();
        
        List<AccountContactRelation> conListForAccount = new List<AccountContactRelation>();
        if(caseDetailsList[0].prodFamily == Constant_Util.ROLLOFF){
                    conListForAccount = [SELECT Contact.Name
                                 FROM AccountContactRelation 
                                 where AccountId =:caseDetailsList[0].vendorId
                             	 AND Roles includes (:Constant_Util.ROLL_OFF_ESCALATION_DISPATCH_ROLE)
                                 LIMIT 1];
        }
        else if(caseDetailsList[0].prodFamily == Constant_Util.COMMERCIAL){
                                conListForAccount = [SELECT Contact.Name
                                 FROM AccountContactRelation 
                                 where AccountId =:caseDetailsList[0].vendorId
                             	 AND Roles includes (:Constant_Util.COMMERCIAL_ESCALATION_DISPATCH_ROLE)
                                 LIMIT 1];
        }

        if(conListForAccount.size()>0)
        vendorContactNameList.add(conListForAccount[0].Contact.Name);
        return vendorContactNameList; 
    }

}