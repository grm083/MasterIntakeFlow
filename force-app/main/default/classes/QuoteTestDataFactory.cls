//This class can be used to create all data needed to create and oprate Quote
@isTest
public class QuoteTestDataFactory {
    //create parent Account with given arguments
    public static Account createParentAccountRecord(String name, String accNum, String recordTypeName,User usr){
        Account accRec = new Account();
        accRec.Name = name;
        //accRec.OwnerId = usr.id;
        accRec.AccountNumber = accNum;
        accRec.RecordTypeid = getRecordType(recordTypeName, 'Account');
        return accRec;
    }
    //insert Account
    public static void insertAccount(Account accRec){
        insert accRec;
    }
    //create parent Account with given arguments
    public static Account createLocationAccount(string name,Id ParentaccId,User usr){        
        
        Account acc = new Account(Name = name,AccountNumber = name,Common_Name__c = name ,phone = '9999999999', //OwnerId = usr.id, 
                                  RecordTypeid = getRecordType('Location','Account'), ParentId = ParentaccId, Status__c = 'ACTIVE');
        return acc;
    }
    //create vendor account with parent 
    public static Account createVendorAccountwithParent(String name,Id ParentaccId, User usr){        
        Account acc = new Account(Name = name,AccountNumber = '8',phone = '9999999999', OwnerId = usr.id, 
                                  RecordTypeid = getRecordType('Vendor','Account'), Status__c = 'ACTIVE',ParentId = ParentaccId);
        return acc;
    }
    //create contact with given arguments
    public static Contact createContactRecord(String lastName, String accId,User usr){
        Contact conRec = new Contact();
        conRec.Lastname = lastName;
        //conRec.OwnerId = usr.id;
        conRec.AccountId = accId;
        return conRec;
    }
    //insert Contact
    public static void insertContact(Contact contactRec){
        insert contactRec;
    }

    public static list<Product2> createProducts(string name,string family,String selectedProductType){
        list<Product2> productlist = new list<Product2>();
        Product2 prd = new Product2(Name = name, Family = family, ProductTypeSelected__c = selectedProductType);
        productlist.add(prd);
        return productlist;
    }

    public static Product2 createProductRecord(String name, String familyType, String productCode){
        Product2 myProduct = new Product2();
        myProduct.Name = name;
        myProduct.Family = familyType;
        myProduct.Is_Pricing_Eligible__c = true;
        myProduct.ProductCode = productCode;
        myProduct.Bypass_Acorn_Integration__c = false;
        myProduct.SBQQ__Component__c = true;
        return myProduct;
    }
    //insert Product2
    public static void insertProducts(List<Product2> productList){
        insert productList;
    }
    
    public static Id getRecordType(String RecordTypeName, String SobjectType){
        return Schema.getGlobalDescribe().get(SobjectType).getDescribe().getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId(); 
    }
    
    public static case createCase(String recordType,String type,String subtype,String caseReason, Account acc, Contact con, Account loc){
        Case caseRec = new Case(Priority = 'Medium', Origin = 'Phone', ContactId = con.id,
                            AccountId = acc.id,Client__c = loc.ParentId, Location__c = loc.id, 
                            Case_Type__c = type, Case_Sub_Type__c = subtype,Case_Reason__c =caseReason, 
                            SlaStartDate = system.today(),Recordtypeid = getRecordType(recordType,'Case'));
        return caseRec;
    }
    //insert case
    public static void insertCases(List<Case> caseRecords){
        insert caseRecords;
    }
    
    public static Opportunity createOpportunity(Integer count,String stageName, String oppName,Id caseId,String caseSubType, Id locationId){
        List<Opportunity> oppList= new List<Opportunity>();
      
            Opportunity opp = new Opportunity();
            opp.Name = oppName;
            opp.AccountId = locationId;
            opp.StageName = stageName;
            opp.CloseDate = date.today() + 4;
            opp.Case__c = caseId;
            opp.Duration__c = caseSubType;
        
        return opp;
    }
    //insert Opportunity
    public static void insertOpportunity(Opportunity oppRec){
        insert oppRec;
    }
    public static Business_Rule__c createBusinessRule(Account acc, Account loc,String recordtype){
        list<Business_Rule__c> businessrulelist = new list<Business_Rule__c>();
        Business_Rule__c businessrule = new Business_Rule__c(Accountid__c = acc.id, locationid__c = loc.id, 
                                                             Container__c = 'Equipment', Service__c = 'Temporary', 
                                                             Request_Type__c = 'New Service', Schedule_Type__c = 'Permanent',
                                                             Active__c = true, Effective_Date__c = System.today() - 1,
                                                             Channel_Req__c= 'Test Channel Requirements',Channel__c = 'WM Portal',
                                                             RecordTypeid = getRecordType(recordtype,'Business_Rule__c') );
        
        
        
        return businessrule;
    }
    //insert Business_Rule__c
    public static Business_Rule__c insertBusinessRule(Business_Rule__c businessRuleRec){
        insert businessRuleRec;
        return businessRuleRec;
    }
    public static Service_Approver__c createServiceApprover(Business_Rule__c br,String recordtype){
        //list<Service_Approver__c> serviceApproverlist = new list<Service_Approver__c>();
        Service_Approver__c serviceApprover = new Service_Approver__c(Business_Rule__c = br.id, Location__c =  br.locationid__c , Active__c = true, 
                                                                      Account__c = br.Accountid__c,
                                                                      Recordtypeid = getRecordType(recordtype,'Service_Approver__c'));
        //serviceApproverlist.add(serviceApprover);
        return serviceApprover;
    }
    //insert Service_Approver__c
    public static Service_Approver__c insertserviceApprover(Service_Approver__c serviceApproverRec){
        insert serviceApproverRec;
        return serviceApproverRec;
    }
    
	public static SBQQ__Quote__c createQuoteRecords(Opportunity opp,Account accObj,Contact conObj){
        
        List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__Account__c = accObj.Id;
        quote.SBQQ__Status__c = 'Draft';
        quote.Duration__c = 'Temporary';
        quote.SBQQ__StartDate__c= system.today()+5;
        quote.SBQQ__PrimaryContact__c= conObj.Id;
      
        
        return quote;
    }
	//insert SBQQ__Quote__c
    public static void insertQuotes(List<SBQQ__Quote__c> quoteRecords){
        insert quoteRecords;
    }
    public static SBQQ__QuoteLine__c createQuoteLineRecords(SBQQ__Quote__c quoteObj, Product2 prodObj, String durationStr, Decimal quantityDec, String ownershipStr, String equipmentSizeStr, String occurrenceTypeStr, String scheduleFrequencyStr, String frequencyIntervalStr, String pricingMethodStr, Decimal listPriceDec,String priceUOMStr,String costModelTypeStr,Decimal unitCostDec, String costUnitMeasureStr, String scheduleAOverrideStr, String vcrCodeStr){
        //List<SBQQ__QuoteLine__c> quoteLineList= new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qlObj= new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c= quoteObj.Id;
        qlObj.Account__c= quoteObj.SBQQ__Account__c;
        qlObj.SBQQ__StartDate__c= quoteObj.SBQQ__StartDate__c;
        qlObj.SBQQ__Product__c= prodObj.Id;
        qlObj.Duration__c= durationStr;
        qlObj.SBQQ__Quantity__c= quantityDec;
        qlObj.Ownership__c= ownershipStr;
        qlObj.Equipment_Size__c= equipmentSizeStr;
        qlObj.Occurrence_Type__c= occurrenceTypeStr;
        qlObj.MASCompany__c='test mas company';
        qlObj.MASLibrary__c ='ARDTA.180';
        qlObj.SetupComment__c = 'test';
        //qlObj.Schedule_Frequency__c= scheduleFrequencyStr;
        //qlObj.Frequency_Interval__c= frequencyIntervalStr;
        qlObj.SBQQ__PricingMethod__c= pricingMethodStr;
        qlObj.SBQQ__ListPrice__c= listPriceDec;
        qlObj.PriceUOM__c= priceUOMStr;
        qlObj.CostModelType__c= costModelTypeStr;
        qlObj.SBQQ__UnitCost__c= unitCostDec;
        qlObj.Cost_Unit_of_Measure__c= costUnitMeasureStr;
        //qlObj.ScheduleAOverride__c= null;		//TCS-SDT-36171-16-Feb-2024-Commented
        qlObj.ScheduleAOverride__c= 'Do Not Override';	//TCS-SDT-36171-16-Feb-2024-Added a default value
        qlObj.VCRCode__c= null;
        //quoteLineList.add(qlObj);
        return qlObj;
    }
    //insert SBQQ__Quote__c
    public static void insertQuoteLines(List<SBQQ__QuoteLine__c> quoteLineList){
        insert quoteLineList;
    }
    public static void insertQuoteLine(SBQQ__QuoteLine__c quoteLine){
        insert quoteLine;
    }
    
    //create account title
    public static Account_Title__c createAccountTitle(String titleNameStr,Account accObj){
        Account_Title__c accTitle = new Account_Title__c();
        accTitle.Name = titleNameStr;
        accTitle.Account__c = accObj.id;
        accTitle.Status__c = 'Active';
        accTitle.Business_Rule_Title__c = true;
        return accTitle;
    }
    
    //insert  account title
    public static Account_Title__c insertAccountTitle(Account_Title__c accTitle){
        insert accTitle;
        return accTitle;
    }
    
    //create department
    public static Department__c createDepartment(String DepartmentNameStr,Account accobj){
        Department__c dept = new Department__c();
        dept.Account__c = accobj.Id;
        dept.Name = DepartmentNameStr;
        return dept;
    }
    
    //insert department
    public static Department__c insertDepartment(Department__c department){
        insert department;
        return department;
    }
    public static STP_Criteria__c createSTPCriteria(String CustomerStr,Boolean CustomerAllboolean,Boolean CustomerIncluded,String Durationstr,String Equipmentstr,
                                        String Frequencystr,String Materialstr,String ServiceTypestr){
        STP_Criteria__c stpRule = new STP_Criteria__c();
            stpRule.Customer__c = CustomerStr ;
            stpRule.Customer_All__c = CustomerAllboolean; 
            stpRule.Customer_Included__c = CustomerIncluded;
            stpRule.Duration__c = Durationstr;
            stpRule.Equipment__c = Equipmentstr; 
            stpRule.Frequency__c = Frequencystr;
            stpRule.Material__c = Materialstr;
            stpRule.Service_Type__c =ServiceTypestr;
            stpRule.Parent_VID__c = '8';
            stpRule.Active__c = false;
            
            return stpRule;
    }
    public static void  insertSTPRules(List<STP_Criteria__c> stpRules){
       insert stpRules;
    }
    public static SBQQ__Quote__c getQuote(String statusStr,String RecordTypeStr){
        SBQQ__Quote__c insertedQuote = [SELECT id, Priority__c, SBQQ__Status__c, Duration__c, Name,SBQQ__Account__r.ParentId
                         FROM SBQQ__Quote__c WHERE SBQQ__Status__c = :statusStr AND SBQQ__Opportunity2__r.Case__r.RecordType.Name = :RecordTypeStr];
        return insertedQuote;
    }
    public static SBQQ__Quote__c updateQuoteStatus(SBQQ__Quote__c insertedQuote,String statusToUpdateStr){
        insertedQuote.SBQQ__Status__c = statusToUpdateStr;
        update  insertedQuote;
        return insertedQuote;
    }
    public static void assignPermissionSet(Set<String> permissionsetNamesStr,User userRec){
        List<PermissionSetAssignment> permAssignList = new List<PermissionSetAssignment>();
        List<PermissionSet> permissionSetList = [SELECT Id,Label,Name 
                                                 FROM PermissionSet 
                                                 WHERE Name IN:permissionsetNamesStr];

        for(PermissionSet perSet : permissionSetList){
              PermissionSetAssignment aPsa = new PermissionSetAssignment();
              aPsa.AssigneeId = userRec.Id;
              aPsa.PermissionSetId = perSet.Id;
              permAssignList.add(aPsa);
              
           }
           Insert permAssignList; 

    }
        
    public static STP_Criteria__c createSTPCriteriaWithAllParam(String customerStr,Boolean customerAllboolean,
                                                                Boolean customerIncluded,String durationstr,String equipmentstr,
                                                                String frequencystr,String materialstr,String serviceTypestr, Boolean active, String vendor,
                                                               String mas, String customerCanadaStr, Boolean customerCanadaAllboolean, Boolean customerCanadaIncluded,
                                                               String stpType, Boolean wmVendorFlag, Boolean allWMVendorFlag,
                                                               Boolean thirdPartyVendorFlag, Boolean allThirdPartyVendorFlag, String thirdPartyVendor,  String marketType){
        STP_Criteria__c stpRule = new STP_Criteria__c();
            stpRule.Customer__c = customerStr ;
            stpRule.Customer_All__c = customerAllboolean; 
            stpRule.Customer_Included__c = customerIncluded;
            stpRule.Duration__c = durationstr;
            stpRule.Equipment__c = equipmentstr; 
            stpRule.Frequency__c = frequencystr;
            stpRule.Material__c = materialstr;
            stpRule.Service_Type__c =serviceTypestr;
            stpRule.Parent_VID__c = vendor;
            stpRule.Active__c = active;
            stpRule.MAS__c = mas;
            stpRule.Customer_Canada__c = customerCanadaStr ;
            stpRule.Customer_All_Canada__c = customerCanadaAllboolean; 
            stpRule.Customer_Included_Canada__c = customerCanadaIncluded;
            stpRule.recordtypeId = getRecordType('STP Eligibility','STP_Criteria__C');
            stpRule.STP_Type__c = stpType;
            stpRule.WM_Vendor__c = wmVendorFlag;
            stpRule.All_WM_Vendors__c = allWMVendorFlag;
            stpRule.Market_Type__c = marketType;
            stpRule.Child_VID_Check_Include_Uncheck_Exclude__c = thirdPartyVendorFlag;
            stpRule.All_3rd_Party_Vendor__c = allThirdPartyVendorFlag;
            stpRule.Parent_Non_Parent_VID_s__c = thirdPartyVendor;
            return stpRule;
    }

  /*  public static void createQuotelinesForContainer(SBQQ__Quote__c quoteObj, List<Product2> prodList,Account Vendor){
        List<SBQQ__QuoteLine__c> childQuotelineList = new List<SBQQ__QuoteLine__c>();
        //first product in list will be container
        //second will be haul service product
        //third will be waste category
        List<SBQQ__QuoteLine__c> quoteLineList= new List<SBQQ__QuoteLine__c>();
        //created  container
        SBQQ__QuoteLine__c quotelineForContainer = QuoteTestDataFactory.createQuoteLineRecords(quoteObj,prodList[0],'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',563.47,'DYS','Do Not Override','NBG');    
        quotelineForContainer.Vendor__c = Vendor.Id;
        QuoteTestDataFactory.insertQuoteLine(quotelineForContainer);

        //haul service
        SBQQ__QuoteLine__c qlHaul = QuoteTestDataFactory.createQuoteLineRecords(quoteObj,prodList[1],'TEMP',1.00,'CLT',
                                                                                    'YRDS-30','OC','M','1','PER',34.00,'DYS','PER',
                                                                                    563.47,'DYS','Do Not Override','NBG');
            qlHaul.SBQQ__RequiredBy__c = quotelineForContainer.Id;
            qlHaul.Vendor__c = Vendor.Id;
            childQuotelineList.add(qlHaul);
            
        //waste category product    
        SBQQ__QuoteLine__c qlproductWasteCategory = QuoteTestDataFactory.createQuoteLineRecords(quoteObj,prodList[2],'TEMP',1.00,'CLT','YRDS-30',
                                                                                   'OC','M','1','PER',34.00,'DYS','PER',null,'DYS',
                                                                                   'Do Not Override','NBG');
            qlproductWasteCategory.SBQQ__RequiredBy__c = quotelineForContainer.Id;
            qlproductWasteCategory.SBQQ__UnitCost__c = 2;
            qlproductWasteCategory.Vendor__c = Vendor.Id;
            childQuotelineList.add(qlproductWasteCategory);
            RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine = true;
            QuoteTestDataFactory.insertQuoteLines(childQuotelineList);

            //insert product with family waste stream
            SBQQ__QuoteLine__c qlWithfamilyWasteStream = QuoteTestDataFactory.createQuoteLineRecords(quoteObj,prodList[3],'TEMP',
                                                                                                          1.00,'CLT','YRDS-30','OC','M','1','PER'
                                                                                                          ,34.00,'DYS','PER',null,'DYS',
                                                                                                          'Do Not Override','NBG');
            qlWithfamilyWasteStream.SBQQ__RequiredBy__c = qlproductWasteCategory.Id;
            qlWithfamilyWasteStream.Vendor__c = Vendor.Id;
            RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine = true;
            QuoteTestDataFactory.insertQuoteLine(qlWithfamilyWasteStream);
            
    }*/
    
     public static list<Messaging.InboundEmail> createinboundemail(string subject,string fromAddress,string plainTextBody){
        List<Messaging.InboundEmail> emaillst = new List<Messaging.InboundEmail>();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = subject;
        email.fromAddress = fromAddress;
        email.plainTextBody = plainTextBody;
        email.htmlBody = plainTextBody;
        email.toAddresses = new List<String>{fromAddress};
        emaillst.add(email);
        return emaillst;
     }
     
     public static STP_Criteria__c createSTPExemptionWithAllParam( Account acc, String byPassProducts,
      Boolean active, String name){
        STP_Criteria__c stpRule = new STP_Criteria__c();
            stpRule.recordTypeId = getRecordType('Client Pricing Exemption', 'STP_Criteria__c') ;
            stpRule.Zero_Cost_Price_Allowed__c = byPassProducts;
            stpRule.Active__c = active;
            stpRule.Parent_Account__c = acc.Id;
            stpRule.Name = name;
            return stpRule;
    }
	
    public static Code_Switch__c createCodeSwitch(String Name,Boolean switchOff)
    {
        Code_Switch__c codeSwitch = new Code_Switch__c();
        codeSwitch.Name = Name;
        codeSwitch.Switch_Off__c =switchOff;
        return codeSwitch;
    }
}
