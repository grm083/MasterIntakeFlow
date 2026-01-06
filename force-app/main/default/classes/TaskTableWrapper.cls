public with sharing class TaskTableWrapper {
    @AuraEnabled 
    public Id TaskId {get;set;}
    @AuraEnabled 
    public String TaskName {get;set;}
    @AuraEnabled 
    public String CaseNumber {get;set;}
    @AuraEnabled 
    public Id CaseId {get;set;}
    @AuraEnabled 
    public Id AssetId {get;set;}
    @AuraEnabled 
    public String AssetName {get;set;}
    @AuraEnabled 
    public Date ServiceDate {get;set;}
    @AuraEnabled 
    public String Process {get;set;} 
    @AuraEnabled 
    public String Outcome {get;set;}
    @AuraEnabled 
    public DateTime DueDateTime {get;set;}
    @AuraEnabled 
    public String CompanyCategory {get;set;}
    @AuraEnabled 
    public String Position {get;set;}
    @AuraEnabled 
    public String ContactEmail {get;set;}
    @AuraEnabled 
    public String ContactNumber {get;set;}
    @AuraEnabled 
    public String ContactTitle {get;set;}
    @AuraEnabled 
    public String ContactMethod {get;set;}
    @AuraEnabled 
    public String AccountName {get;set;} 
    @AuraEnabled 
    public Id AccountId {get;set;}
    @AuraEnabled 
    public String AccountNumber {get;set;}
    @AuraEnabled 
    public String AcornWONumber {get;set;}
    @AuraEnabled 
    public String Status {get;set;}
    @AuraEnabled 
    public String ParentVendor {get;set;}
    @AuraEnabled 
    public Id ParentVendorId {get;set;}
    @AuraEnabled 
    public String LocationAccount {get;set;}
    @AuraEnabled 
    public Id LocationAccountId {get;set;}
    @AuraEnabled 
    public String LocationAddress {get;set;}
    @AuraEnabled 
    public String LocationCity {get;set;}
    @AuraEnabled 
    public String LocationState {get;set;}
    @AuraEnabled 
    public String LocationZipCode {get;set;}
    @AuraEnabled 
    public String MarketArea {get;set;}
    @AuraEnabled 
    public String VendorBU {get;set;}
    @AuraEnabled 
    public Boolean WMVendor {get;set;}
    @AuraEnabled 
    public String Comments {get;set;}
    @AuraEnabled 
    public Id AssignedTo {get;set;}
    @AuraEnabled 
    public String AssignedToName {get;set;}
    @AuraEnabled 
    public String AssetProject {get;set;}
    @AuraEnabled 
    public String AccountType {get;set;}
    @AuraEnabled 
    public Decimal TaskAttempt {get;set;}
    @AuraEnabled 
    public Boolean ShowServiceDateAsEdit {get;set;}
    @AuraEnabled 
    public String AssetEquipmentSize {get;set;}
    @AuraEnabled 
    public String AssetMaterialType {get;set;} 
    @AuraEnabled 
    public String CaseType {get;set;}
    @AuraEnabled 
    public String CaseSubType {get;set;}
    @AuraEnabled 
    public String AssetMASAccountNumber {get;set;}
    @AuraEnabled 
    public String AssetVendorAccountNumber {get;set;}

}