/*************************************************************
@Name: GetChildCase
@Author: Priyadharshini R
@CreateDate: 22/07/2019
@Description: To show all cases based on the Grouping of Approval task
@UsedBy: GetChildCaseDetails
*************************************************************/
public class GetChildCase {

    public Case parentcse {get;set;}
    /*To get all cases based on the Grouping of Approval task*/
    public List<Case> getcases(){
        set<Id> caseidset = new set<Id>();
        set<case> caseGrp1 = new Set<Case>();
        Integer limitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        if(parentcse !=null){
            for(Task t:[select id,WhatId from Task where MultiCaseId__c=:parentcse.Id LIMIT:limitRows]){
                caseidset.add(t.WhatId);
            }
            for(Case c: [select id,Case_Sub_Type__c,Asset.Equipment_Size__c,Asset.Material_Type__c,Asset.Equipment_Type__c,CaseNumber,
                         Contact.Name,Tech_Location_Details__c,Service_Date__c,Reference_Number__c,Description,Contact_Title__c,Location_Customer_Name_Email_Teamp__c
                         from Case where Id IN :caseidset LIMIT:limitRows]){
                             c.Description = (c.Tech_Location_Details__c).stripHtmlTags();
                             caseGrp1.add(c);
            }
        }
        List<Case> caseGrp = new List<Case>();
        caseGrp.addAll(caseGrp1);
        return caseGrp;
    }
    public User getuser(){
     return [SELECT id,FirstName,LastName,Department_Email__c,Department_Phone__c,Department from USER where id=:UserInfo.getUserId()];
    }
}