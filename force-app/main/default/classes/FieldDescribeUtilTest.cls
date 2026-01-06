/**
 * @description       : Test Class to cover FieldDescribeUtil
 * @author            : Adil Aleem 
 * @group             : 
 * @last modified on  : 04-07-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class FieldDescribeUtilTest {
    @isTest static void testGetDependentPicklistValues() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User currentuser = [SELECT Id, Bypass_Validation__c 
                            FROM User
                            WHERE ProfileId =: p.Id 
                            AND isActive =: true
                            LIMIT 1];
        
        System.runAs(currentuser){
            
            Test.startTest();
            FieldDescribeUtil.getDependentPicklistValues(Case.Case_Sub_Type__c);
            Test.stopTest();
        }        
    }

}