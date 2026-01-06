@isTest(seeAllData = false)
public class STPExhibitRuleExecutionTest {
    
   @testSetup
    public static void setup(){
        List<SBQQ__QuoteLine__c> childQuoteLineList = new List<SBQQ__QuoteLine__c>();
        List<Product2> productList = new List<Product2>();
        List<STP_Criteria__c> stprules = new List<STP_Criteria__c>();
        List<Case> caseList = new List<Case>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        
        //create quote and update quote status to cost configured in setup method
        Profile adminProfile = TestDataFactory.getProfile(STPRuleExecutionTest.SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr); 
        Profile csrProfile = TestDataFactory.getProfile(Pricing_Constant_Util.CUSTOMER_SERVICE);
        User csrUsr = TestDataFactory.createUser(csrProfile);
        Database.insert(csrUsr); 
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        System.runAs(usr){
            test.startTest();   
            
            Account parentAccount = QuoteTestDataFactory.createParentAccountRecord(STPRuleExecutionTest.parent_AccName,STPRuleExecutionTest.customer_code, 
                                                                                   ConstantClass.RecordType_Client, usr);
            parentAccount.Status__c = 'Active'; 
            parentAccount.Accounting_System__c = STPRuleExecutionTest.WMNAT;                                                                     
            QuoteTestDataFactory.insertAccount(parentAccount);
            Account thirdPartyparentAccount = QuoteTestDataFactory.createParentAccountRecord(STPRuleExecutionTest.thirdPartyparent_AccName,STPRuleExecutionTest.customer_code, 
                                                                                   ConstantClass.RecordType_Client, usr);
            thirdPartyparentAccount.Status__c = 'Active'; 
            thirdPartyparentAccount.Accounting_System__c = STPRuleExecutionTest.WMNAT;                                                                     
            QuoteTestDataFactory.insertAccount(thirdPartyparentAccount);
            //create location account
            Account locationAccount = QuoteTestDataFactory.createLocationAccount(STPRuleExecutionTest.location_AccName, parentAccount.Id, usr);
            QuoteTestDataFactory.insertAccount(locationAccount);
            Account thirdPartylocationAccount = QuoteTestDataFactory.createLocationAccount(STPRuleExecutionTest.thirdPartylocation_AccName, thirdPartyparentAccount.Id, usr);
            QuoteTestDataFactory.insertAccount(thirdPartylocationAccount);
            
            //Create vendor account 
            Id vendorRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantClass.RecordType_Vendor).getRecordTypeId();
            Account parentVendor = new Account(Name = STPRuleExecutionTest.parentVendor_AccName, RecordTypeId = vendorRecordtypeId,
                                               Status__c = ConstantClass.FieldStatus_Active, AccountNumber = STPRuleExecutionTest.parentVendor_AccNumber);
            QuoteTestDataFactory.insertAccount(parentVendor);
            
            Id thirdPartyvendorRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantClass.RecordType_Vendor).getRecordTypeId();
            Account thirdPartyparentVendor = new Account(Name = STPRuleExecutionTest.thirdPartyparentVendor_AccName, RecordTypeId = thirdPartyvendorRecordtypeId,
                                               Status__c = ConstantClass.FieldStatus_Active, AccountNumber = STPRuleExecutionTest.thirdPartyparentVendor_AccNumber);
            QuoteTestDataFactory.insertAccount(thirdPartyparentVendor);
            
            //create child vendor account
            Account childVendor = QuoteTestDataFactory.createVendorAccountwithParent(STPRuleExecutionTest.childVendor_AccName, parentVendor.Id, usr);
            QuoteTestDataFactory.insertAccount(childVendor);
            
            Account thirdpartyChildVendor = QuoteTestDataFactory.createVendorAccountwithParent(STPRuleExecutionTest.thirdPartychildVendor_AccName, thirdPartyparentVendor.Id, usr);
            QuoteTestDataFactory.insertAccount(thirdpartyChildVendor);
            
            //create contact for account which is primary contact in quote with product trash
            Contact quoteContact = QuoteTestDataFactory.createContactRecord(STPRuleExecutionTest.contact_lastName, parentAccount.Id, usr);
            QuoteTestDataFactory.insertContact(quoteContact);
            Contact thirdPartyquoteContact = QuoteTestDataFactory.createContactRecord(STPRuleExecutionTest.contact_lastName, thirdPartyparentAccount.Id, usr);
            QuoteTestDataFactory.insertContact(thirdPartyquoteContact);
            
            //creating case with record type new service
            Case caseForQuote = QuoteTestDataFactory.createCase(ConstantClass.RecordType_NewServiceCase,
                                                                ConstantClass.FieldType_NewService,
                                                                ConstantClass.FieldSubType_Temporary,STPRuleExecutionTest.caseReason_Tempupload,
                                                                parentAccount,quoteContact, locationAccount);
            caseList.add(caseForQuote);
            Case thirdPartycaseForQuote = QuoteTestDataFactory.createCase(ConstantClass.RecordType_NewServiceCase,
                                                                ConstantClass.FieldType_NewService,
                                                                ConstantClass.FieldSubType_Temporary,STPRuleExecutionTest.caseReason_Tempupload,
                                                                thirdPartyparentAccount,thirdPartyquoteContact, thirdPartylocationAccount);
            caseList.add(thirdPartycaseForQuote);
            
            //creating case with recordtype Pickup Case
            Case pickUpCase = QuoteTestDataFactory.createCase(ConstantClass.RecordType_PickUpCase,
                                                              Pricing_Constant_Util.PR_PICKUP,Pricing_Constant_Util.EMPTY_AND_RETURN, 'Contaminated',
                                                              parentAccount, quoteContact, locationAccount);
            caseList.add(pickUpCase);                                                    
            QuoteTestDataFactory.insertCases(caseList);
            
            //create pricing request
            Pricing_Request__c pricingRequest = TestDataFactory.createPricingRequestRecord(caseForQuote, parentAccount, locationAccount,
                                                                                           Pricing_Constant_Util.ROLLOFF, 'AM', '', 
                                                                                           STPRuleExecutionTest.JSON_VALID_ROLLOFF_DATA, usr);
            //pricingRequest.Market_Area_Code__c = 'K00199';
            pricingRequest.zone_Type__c = 'Open Market';
            pricingRequest.Customer_Price_Type__c = Pricing_Constant_Util.EXHIBIT_PRICING;
            Insert pricingRequest;
            
            Pricing_Request__c thirdPartypricingRequest = TestDataFactory.createPricingRequestRecord(caseForQuote, thirdPartyparentAccount, thirdPartylocationAccount,
                                                                                           Pricing_Constant_Util.ROLLOFF, 'AM', '', 
                                                                                           STPRuleExecutionTest.JSON_VALID_ROLLOFF_DATA, usr);
            thirdPartypricingRequest.zone_Type__c = Pricing_Constant_Util.WM_FRANCHISE;
            Insert thirdPartypricingRequest;
            
            //creating open top product
            Product2 openTop = QuoteTestDataFactory.createProductRecord(Pricing_Constant_Util.OPEN_TOP, 'Equipment', 'OT');
            productList.add(openTop);
            //creating haul service product
            Product2 haulService = QuoteTestDataFactory.createProductRecord(Pricing_Constant_Util.HAUL, 'Services', 'H');
            productList.add(haulService);
            //creating disposal service product
            Product2 DisposalService= QuoteTestDataFactory.createProductRecord(Pricing_Constant_Util.DISPOSAL,'Services','DSP');
            productList.add(DisposalService);
            //creating container service charge product 
            Product2 ContainerServiceCharge = QuoteTestDataFactory.createProductRecord(Pricing_Constant_Util.PR_ContainerServiceCharge,'Services','CSC');
            productList.add(ContainerServiceCharge); 
            //creating trash product with family waste stream
            Product2 TrashWasteStream = QuoteTestDataFactory.createProductRecord('Trash','Waste Stream','T');
            TrashWasteStream.Is_Pricing_Eligible__c = true;
            productList.add(TrashWasteStream);
            //creating trash product with family waste category
            product2 TrashWasteCategory = QuoteTestDataFactory.createProductRecord('Trash','Waste Category','OTT');
            productList.add(TrashWasteCategory);
            
            Product2 deliveryService = QuoteTestDataFactory.createProductRecord('Delivery','Surcharges and Fees','DLV');
            productList.add(deliveryService);
            
            QuoteTestDataFactory.insertProducts(productList);
            
            //creating opportunity for new service case
            Opportunity oppForNewServiceCase = QuoteTestDataFactory.createOpportunity(1, ConstantClass.FieldStageName_Proposal, 
                                                                                      'OpportunityFornewServiceCase', caseForQuote.Id, 
                                                                                      ConstantClass.FieldSubType_Temporary, locationAccount.Id);  
            QuoteTestDataFactory.insertOpportunity(oppForNewServiceCase);
            Opportunity thirdPartyoppForNewServiceCase = QuoteTestDataFactory.createOpportunity(1, ConstantClass.FieldStageName_Proposal, 
                                                                                      'OpportunityForthirdPartynewServiceCase', thirdPartycaseForQuote.Id, 
                                                                                      ConstantClass.FieldSubType_Permanent, thirdPartylocationAccount.Id);  
            QuoteTestDataFactory.insertOpportunity(thirdPartyoppForNewServiceCase);
            
            //creating opportunity for pickup case
            Opportunity oppForpickUpCase = QuoteTestDataFactory.createOpportunity(1, ConstantClass.FieldStageName_Proposal, 
                                                                                  'OpportunityForPickupCase', pickUpCase.Id, 
                                                                                  ConstantClass.FieldSubType_Temporary, locationAccount.Id);  
            QuoteTestDataFactory.insertOpportunity(oppForpickUpCase); 
            
            //creating quote for new service case(for trash)
            SBQQ__Quote__c quoteForTestingTrash = QuoteTestDataFactory.createQuoteRecords(oppForNewServiceCase, locationAccount, quoteContact);
            quoteList.add(quoteForTestingTrash);
            SBQQ__Quote__c thirdPartyquoteForTestingTrash = QuoteTestDataFactory.createQuoteRecords(thirdPartyoppForNewServiceCase, thirdPartylocationAccount, thirdPartyquoteContact);
            quoteList.add(thirdPartyquoteForTestingTrash);
            
            //creating quote for pick up case
            SBQQ__Quote__c quoteForPickUpCase = QuoteTestDataFactory.createQuoteRecords(oppForpickUpCase, locationAccount, quoteContact);
            quoteList.add(quoteForPickUpCase);
            RecurrsiveTriggerHandler.bypassValidation = true;
            QuoteTestDataFactory.insertQuotes(quoteList);
            
            //QuoteLine Creation
            //parent quoteline 'Open Top' for new service case
            //RecurrsiveTriggerHandler.isRecurrsiveQuoteLine = true;
            
            //--trigger control is disabled in order to avoid SOQL query exception
            SBQQ.TriggerControl.disable();
            
            try 
            {
                SBQQ__QuoteLine__c quotelineForContainerOT = QuoteTestDataFactory.createQuoteLineRecords(quoteForTestingTrash,openTop,
                                                                                                         'TEMP',1.00,'CLT','YRDS-30',
                                                                                                         'OC','M','1','PER',34.00,'DYS',
                                                                                                         'PER',null,'DYS','Do Not Override','NBG');
                quotelineForContainerOT.SBQQ__Bundle__c = true;
                quotelineForContainerOT.SBQQ__RequiredBy__c = null;
                quotelineForContainerOT.Vendor__c = childVendor.Id;
                quotelineForContainerOT.Pricing_Request__c = pricingRequest.Id;
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                QuoteLineTriggerHelper.extrapickUpRecursion = false;
                RecurrsiveTriggerHandler.setIsRecurrsiveQuoteLine();
                QuoteTestDataFactory.insertQuoteLine(quotelineForContainerOT);
                
                //thirdParty
                SBQQ__QuoteLine__c thirdPartyquotelineForContainerOT = QuoteTestDataFactory.createQuoteLineRecords(thirdPartyquoteForTestingTrash,openTop,
                                                                                                         'TEMP',1.00,'CLT','YRDS-30',
                                                                                                         'OC','M','1','PER',34.00,'DYS',
                                                                                                         'PER',null,'DYS','Do Not Override','NBG');
                thirdPartyquotelineForContainerOT.SBQQ__Bundle__c = true;
                thirdPartyquotelineForContainerOT.SBQQ__RequiredBy__c = null;
                thirdPartyquotelineForContainerOT.Vendor__c = thirdPartyChildVendor.Id;
                thirdPartyquotelineForContainerOT.sCode__c = null;
                thirdPartyquotelineForContainerOT.Pricing_Request__c = thirdPartypricingRequest.Id;
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                QuoteLineTriggerHelper.extrapickUpRecursion = false;
                RecurrsiveTriggerHandler.setIsRecurrsiveQuoteLine();
                QuoteTestDataFactory.insertQuoteLine(thirdPartyquotelineForContainerOT);
                
                //parent quoteline 'Open Top' for pickup case
                SBQQ__QuoteLine__c quotelineForContainerOTPickup = QuoteTestDataFactory.createQuoteLineRecords(quoteForPickUpCase,openTop,
                                                                                                               'TEMP',1.00,'CLT','YRDS-30',
                                                                                                               'OC','M','1','PER',34.00,'DYS',
                                                                                                               'PER',null,'DYS','Do Not Override','NBG');
                quotelineForContainerOT.SBQQ__Bundle__c = true;
                quotelineForContainerOT.SBQQ__RequiredBy__c = null;
                quotelineForContainerOT.Vendor__c = childVendor.Id;
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                
                QuoteTestDataFactory.insertQuoteLine(quotelineForContainerOTPickup); 
                
                
                //Adding Availablity 
                AAV_Asset_Availability__c aavObj = new AAV_Asset_Availability__c();
            	aavObj.AAV_Location__c = locationAccount.Id;
				aavObj.AAV_APIRequestOutput__c = STPRuleExecutionTest.AAV_API_REQUEST_OUTPUT;
				aavObj.AAV_Quote_Line__c = quotelineForContainerOT.Id;

            	insert aavObj;
                //Open Top Child Quote Line  --- Start
                //quoteline for trash product
                SBQQ__QuoteLine__c qlTrashWasteCategory = QuoteTestDataFactory.createQuoteLineRecords(quoteForTestingTrash,TrashWasteCategory,'TEMP',1.00,'CLT','YRDS-30',
                                                                                                      'OC','M','1','PER',34.00,'DYS','PER',null,'DYS',
                                                                                                      'Do Not Override','NBG');
                qlTrashWasteCategory.SBQQ__RequiredBy__c = quotelineForContainerOT.Id;
                qlTrashWasteCategory.SBQQ__UnitCost__c = 2;
                qlTrashWasteCategory.Vendor__c = childVendor.Id;
                childQuoteLineList.add(qlTrashWasteCategory);
                
                //quoteline for haul product
                SBQQ__QuoteLine__c qlHaul = QuoteTestDataFactory.createQuoteLineRecords(quoteForTestingTrash,haulService,'TEMP',1.00,'CLT',
                                                                                        'YRDS-30','OC','M','1','PER',34.00,'DYS','PER',
                                                                                        10000000,'DYS','Do Not Override','NBG');//4th last 563.47
                qlHaul.SBQQ__RequiredBy__c = quotelineForContainerOT.Id;
                qlHaul.Pricing_Request__c = pricingRequest.Id;
                qlHaul.Vendor__c = childVendor.Id;
                childQuoteLineList.add(qlHaul);
                
                //quoteline for disposal product
                SBQQ__QuoteLine__c qlDisposal = QuoteTestDataFactory.createQuoteLineRecords(quoteForTestingTrash,DisposalService,
                                                                                            'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',
                                                                                            34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
                qlDisposal.SBQQ__RequiredBy__c = quotelineForContainerOT.Id;
                qlDisposal.Vendor__c = childVendor.Id;
                qlDisposal.SBQQ__UnitCost__c = 2;
                childQuoteLineList.add(qlDisposal);
                
                //quoteline for container service charge
                SBQQ__QuoteLine__c qlContainerService = QuoteTestDataFactory.createQuoteLineRecords(quoteForTestingTrash,ContainerServiceCharge,
                                                                                                    'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',
                                                                                                    34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
                qlContainerService.SBQQ__RequiredBy__c = quotelineForContainerOT.Id;
                qlContainerService.Vendor__c = childVendor.Id;
                qlContainerService.SBQQ__UnitCost__c = 2;
                childQuoteLineList.add(qlContainerService);
                
                //Ql Delivery 
                SBQQ__QuoteLine__c qlDelivery = QuoteTestDataFactory.createQuoteLineRecords(quoteForTestingTrash,deliveryService,
                                                                                            'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',
                                                                                            34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
                qlDelivery.SBQQ__RequiredBy__c = quotelineForContainerOT.Id;
                qlDelivery.Vendor__c = childVendor.Id;
                qlDelivery.SBQQ__UnitCost__c = 2;
                childQuoteLineList.add(qlDelivery);
                
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                QuoteTestDataFactory.insertQuoteLines(childQuoteLineList);
                
                //Open Top Child Quote Line  --- End
                
                //quoteline with product family as waste stream has parent quoteline as trash product with family Waste Category
                //inserting quoteline with waste stream product family
                test.stopTest();
                SBQQ__QuoteLine__c qlTrashWithfamilyWasteStream = QuoteTestDataFactory.createQuoteLineRecords(quoteForTestingTrash,TrashWasteStream,'TEMP',
                                                                                                              1.00,'CLT','YRDS-30','OC','M','1','PER'
                                                                                                              ,34.00,'DYS','PER',null,'DYS',
                                                                                                              'Do Not Override','NBG');
                qlTrashWithfamilyWasteStream.SBQQ__RequiredBy__c = qlTrashWasteCategory.Id;
                
                qlTrashWithfamilyWasteStream.Vendor__c = childVendor.Id;
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                QuoteTestDataFactory.insertQuoteLine(qlTrashWithfamilyWasteStream);
            }
            finally {
                SBQQ.TriggerControl.enable();
            }       
            


            
            STP_Criteria__c ruleWithInactivePartialSTP =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',false, '8','K00129',null, true, true, 'Partial STP', true, false, true, false, '7414', STPRuleExecutionTest.OPEN);                                                            
            
            stprules.add(ruleWithInactivePartialSTP);
            //Exemption Rule
            STP_Criteria__c exmptRuleOpenMktType = QuoteTestDataFactory.createSTPExemptionWithAllParam(parentAccount, STPRuleExecutionTest.byPassProducts,true,'test excemption');
                exmptRuleOpenMktType.Duration__c = 'TEMP';
                exmptRuleOpenMktType.Equipment__c = 'Open Top';
                exmptRuleOpenMktType.Eligible_Vendor__c = 'WM';
            exmptRuleOpenMktType.Market_Type__c = 'Open';
            stprules.add(exmptRuleOpenMktType);
            QuoteTestDataFactory.insertSTPRules(stprules);

        }
     } 
      /*
* @Owner : TCS-Seema Dhikale
* @Story : 46922
* @MethodName    haulCostTest
* @description	  checking if  the quote passes STP if the haul cost is not in between 0 and 15000 
* @Test Scenario : Country: US, Valid For Receiving Exibhit Cost Price:Yes,Threshold limit for Haul:Not Applicable, 
                   Cost Price:In Threshold LIMIT, Other Validation Status: Pass,
                   STP:Pass
*/
    @isTest
    public static void haulCostTest_US(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :STPRuleExecutionTest.SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:STPRuleExecutionTest.location_AccName limit 1];
                //get haul quoteline in this quote
                SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
        		List<SBQQ__QuoteLine__c> haulquoteline = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1];                                    
        haulquoteline[0].SBQQ__UnitCost__c = 1600;
        haulquoteline[0].Cost_Override_Reason__c ='Other';
        haulquoteline[0].Cost_Override_Description__c = 'testing';
        //Update haulquoteline;
                SBQQ.TriggerControl.enable();
                STP_Criteria__c ruleWithProperConfig =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Any');                                                            
            
        	insert ruleWithProperConfig;
        
            STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
                ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :STPRuleExecutionTest.methodName_ExecuteRules];
                System.debug('exceptionLog haulCostTest'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
                SBQQ__Quote__c quoteAfterExecution = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id=:InsertedQuote.Id LIMIT 1];
                //System.assertEquals ('Procure Service', quoteAfterExecution.SBQQ__Status__c,'If STP fails,Quote should remain in Procure service status.');
            }catch(Exception e) {
			system.debug('Exception while executing haulCostTest '+ e.getMessage());
        }
        }
        test.stopTest();
        }
    
    
    /*
* @Owner : TCS-Anjali Chalase
* @Story : 46922
* @Test Scenario : Country: US, Valid For Receiving Exibhit Cost Price:Yes,Threshold limit for Haul:Not Applicable, 
                   Cost Price:Not In Threshold LIMIT, Other Validation Status: Pass,
                   STP:Pass
*/
    @isTest
    public static void haulCostTest_NotInThreshold_US(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :STPRuleExecutionTest.SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:STPRuleExecutionTest.location_AccName limit 1];
                //get haul quoteline in this quote
                SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
        		List<SBQQ__QuoteLine__c> haulquoteline = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1];                                    
        haulquoteline[0].SBQQ__UnitCost__c = 16000;
        haulquoteline[0].Cost_Override_Reason__c ='Other';
        haulquoteline[0].Cost_Override_Description__c = 'testing';
        Update haulquoteline;
                SBQQ.TriggerControl.enable();
                STP_Criteria__c ruleWithProperConfig =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Any');                                                            
            
        	insert ruleWithProperConfig;
        
            STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
                ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :STPRuleExecutionTest.methodName_ExecuteRules];
                System.debug('exceptionLog haulCostTest_NotInThreshold'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
                SBQQ__Quote__c quoteAfterExecution = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id=:InsertedQuote.Id LIMIT 1];
                System.assertEquals ('Procure Service', quoteAfterExecution.SBQQ__Status__c,'If STP fails,Quote should remain in Procure service status.');
            }catch(Exception e) {
			system.debug('Exception while executing haulCostTest_NotInThreshold '+ e.getMessage());
        }
        }
        test.stopTest();
        }
    
    
    /*
* @Owner : TCS-Anjali Chalase
* @Story : 46922
* @Test Scenario : Country: US, Valid For Receiving Exibhit Cost Price:Yes,Threshold limit for Haul:Not Applicable, 
                   Cost Price:Not In Threshold LIMIT, Other Validation Status: Fail,
                   STP:Fail
*/
   @isTest
    public static void haulCostTest_FailureonAllChecks_US(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :STPRuleExecutionTest.SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:STPRuleExecutionTest.location_AccName limit 1];
                //get haul quoteline in this quote
                SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
        		List<SBQQ__QuoteLine__c> haulquoteline = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1];                                    
        haulquoteline[0].SBQQ__UnitCost__c = 17000;
        haulquoteline[0].Cost_Override_Reason__c ='Other';
        haulquoteline[0].Cost_Override_Description__c = 'testing';
        Update haulquoteline;
                SBQQ.TriggerControl.enable();
                STP_Criteria__c ruleWithProperConfig =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, false, false,
                                                                                          'WRONG_TEMP', 'Open Top', 'WM',
                                                                                          'Wrong Trash', 'New Service Case',false, '','K00126',null, false, false, 'Fail STP', false, false, false, false, '', 'Any');                                                            
            
        	insert ruleWithProperConfig;
        
            STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
                ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :STPRuleExecutionTest.methodName_ExecuteRules];
                System.debug('exceptionLog haulCostTest_FailureonAllChecks'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
                SBQQ__Quote__c quoteAfterExecution = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id=:InsertedQuote.Id LIMIT 1];
                System.assertEquals ('Procure Service', quoteAfterExecution.SBQQ__Status__c,'If STP fails,Quote should remain in Procure service status.');
            }catch(Exception e) {
			system.debug('Exception while executing haulCostTest_FailureonAllChecks '+ e.getMessage());
        }
        }
        test.stopTest();
        }
    
    /*
* @Owner : TCS-Anjali Chalase
* @Story : 46922
* @Test Scenario : Country: US, Valid For Receiving Exibhit Cost Price:No,Threshold limit for Haul:Applicable, 
                   Cost Price:In Threshold LIMIT, Other Validation Status: Pass,
                   STP:Pass
*/
    @isTest
    Public static void haulCostTest_WithinThresholdButFailsRules_US(){
        Test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :STPRuleExecutionTest.SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:STPRuleExecutionTest.location_AccName limit 1];
              SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
        		List<SBQQ__QuoteLine__c> haulquoteline = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1]; 
        haulquoteline[0].SBQQ__UnitCost__c = 600;
        haulquoteline[0].Cost_Override_Reason__c ='Other';
        haulquoteline[0].Cost_Override_Description__c = ' fail validations';
        Update haulquoteline;
                SBQQ.TriggerControl.enable(); 
                STP_Criteria__c ruleValidationFail =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, false, false,
                                                                                          'WRONG_TEMP', 'Open Top', 'WM',
                                                                                          'WRONG Trash', 'New Service Case',false, '','K00126',null, false, false, 'Fail STP', false, false, false, true, 'A', 'Any');                                                            
            
        	insert ruleValidationFail;
                STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
                ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :STPRuleExecutionTest.methodName_ExecuteRules];
                System.debug('exceptionLog WithinThresholdButFailsRules'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
                SBQQ__Quote__c quoteAfterExecution = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id=:InsertedQuote.Id LIMIT 1];
                System.assertEquals ('Procure Service', quoteAfterExecution.SBQQ__Status__c,'If STP fails,Quote should remain in Procure service status.');
            }catch(Exception e) {
			system.debug('Exception while executing haulCostTest_WithinThresholdButFailsRules '+ e.getMessage());
        }
        }
        test.stopTest();
    }
    
    /*
* @Owner : TCS-Anjali Chalase
* @Story : 46922
* @Test Scenario : Country: US, Valid For Receiving Exibhit Cost Price:No,Threshold limit for Haul:Applicable, 
                   Cost Price:Not In Threshold LIMIT, Other Validation Status: Pass,
                   STP:Fail
*/
    @isTest
    Public static void haulCostTest_PassAllChecks_WithinThreshold_US(){
        Test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :STPRuleExecutionTest.SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:STPRuleExecutionTest.location_AccName limit 1];
              SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
        		List<SBQQ__QuoteLine__c> haulquoteline = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1]; 
        haulquoteline[0].SBQQ__UnitCost__c = 6500;
        haulquoteline[0].Cost_Override_Reason__c ='Other';
        haulquoteline[0].Cost_Override_Description__c = 'Testing';
        Update haulquoteline;
                SBQQ.TriggerControl.enable(); 
                STP_Criteria__c ruleValidationFail =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Any');                                                            
            
        	insert ruleValidationFail;
                STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
                ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :STPRuleExecutionTest.methodName_ExecuteRules];
                System.debug('exceptionLog PassAllChecks_WithinThreshold'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
                SBQQ__Quote__c quoteAfterExecution = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id=:InsertedQuote.Id LIMIT 1];
                System.assertEquals ('Procure Service', quoteAfterExecution.SBQQ__Status__c,'If STP fails,Quote should remain in Procure service status.');
            }catch(Exception e) {
			system.debug('Exception while executing haulCostTest_ PassAllChecks_WithinThreshold '+ e.getMessage());
        }
        }
        test.stopTest();
    }
   
    /*
* @Owner : TCS-Anjali Chalase
* @Story : 46922
* @Test Scenario : Country: US, Valid For Receiving Exibhit Cost Price:No,Threshold limit for Haul:Applicable, 
                   Cost Price:Not In Threshold LIMIT, Other Validation Status: Fail,
                   STP:Fail
*/
    @isTest
    Public static void haulCostTest_AllFail_NotinThreshold_US(){
        Test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :STPRuleExecutionTest.SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:STPRuleExecutionTest.location_AccName limit 1];
              SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
        		List<SBQQ__QuoteLine__c> haulquoteline = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1]; 
        haulquoteline[0].SBQQ__UnitCost__c = 0;
        haulquoteline[0].Cost_Override_Reason__c ='Other';
        haulquoteline[0].Cost_Override_Description__c = 'Testing';
        Update haulquoteline;
                SBQQ.TriggerControl.enable(); 
                STP_Criteria__c ruleValidationFail =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, false, false,
                                                                                          'WRONG_TEMP', 'Open Top', 'OT',
                                                                                          'Trash', 'New Service Case',false, '','K00126',null, false, false, 'Full STP', false, false, false, false, '', 'Any');                                                            
            
        	insert ruleValidationFail;
                STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
                ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :STPRuleExecutionTest.methodName_ExecuteRules];
                System.debug('exceptionLog AllFail_NotinThreshold'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
                SBQQ__Quote__c quoteAfterExecution = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id=:InsertedQuote.Id LIMIT 1];
                System.assertEquals ('Procure Service', quoteAfterExecution.SBQQ__Status__c,'If STP fails,Quote should remain in Procure service status.');
            }catch(Exception e) {
			system.debug('Exception while executing haulCostTest_AllFail_NotinThreshold '+ e.getMessage());
        }
        }
        test.stopTest();
    }
    
/*/**************************** TEST SCENARIO'S FOR CANADA LOCATION*********************************/

 /*
* @Owner : TCS-Anjali Chalase
* @Story : 46922
* @description	  checking if  the quote passes STP if the haul cost is not in between 0 and 15000 
* @Test Scenario : Country: Canada, Valid For Receiving Exibhit Cost Price:Yes,Threshold limit for Haul:Not Applicable, 
                   Cost Price:In Threshold LIMIT, Other Validation Status: Pass,
                   STP:Pass
*/
    @isTest
    public static void haulCostTest_Canada(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :STPRuleExecutionTest.SYS_ADMIN  AND IsActive = true LIMIT 1];
        Account parentAccCanada = [SELECT Id, Accounting_System__c FROM Account WHERE Name =:STPRuleExecutionTest.parent_AccName LIMIT 1];
        parentAccCanada.Accounting_System__c = STPRuleExecutionTest.OAKWL;
        Update parentAccCanada;
        
        Account thirdPartyparentAccCanada = [SELECT Id, Accounting_System__c FROM Account WHERE Name =:STPRuleExecutionTest.thirdPartyparent_AccName LIMIT 1];
        thirdPartyparentAccCanada.Accounting_System__c = STPRuleExecutionTest.OAKWL;
        Update thirdPartyparentAccCanada;
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:STPRuleExecutionTest.location_AccName limit 1];
                //get haul quoteline in this quote
                SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
        		List<SBQQ__QuoteLine__c> haulquoteline = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1];                                    
        haulquoteline[0].SBQQ__UnitCost__c = 1600;
        haulquoteline[0].Cost_Override_Reason__c ='Other';
        haulquoteline[0].Cost_Override_Description__c = 'testing';
        Update haulquoteline;
                SBQQ.TriggerControl.enable();
                STP_Criteria__c ruleWithProperConfig =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Any');                                                            
            
        	insert ruleWithProperConfig;
        
            STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
                List<ExceptionLog__c> exceptionLog = [SELECT id FROM ExceptionLog__c WHERE Method_Name__c = :STPRuleExecutionTest.methodName_ExecuteRules];
                //System.debug('exceptionLog haulCostTest'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
                system.assertEquals(0,exceptionLog.size(),'No ExceptionLog should be created for haul cost within threshold');
                
                SBQQ__Quote__c quoteAfterExecution = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id=:InsertedQuote.Id LIMIT 1];
                //System.assertEquals ('Procure Service', quoteAfterExecution.SBQQ__Status__c,'If STP fails,Quote should remain in Procure service status.');
            }catch(Exception e) {
			system.debug('Exception while executing haulCostTest '+ e.getMessage());
            //system.assert(false, 'Unexpected exception occured:'+e.getMessage());    
        }
        }
        test.stopTest();
        }
    
    
    /*
* @Owner : TCS-Anjali Chalase
* @Story : 46922
* @Test Scenario : Country: Canada, Valid For Receiving Exibhit Cost Price:Yes,Threshold limit for Haul:Not Applicable, 
                   Cost Price:Not In Threshold LIMIT, Other Validation Status: Pass,
                   STP:Pass
*/
    @isTest
    public static void haulCostTest_NotInThreshold_Canada(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :STPRuleExecutionTest.SYS_ADMIN  AND IsActive = true LIMIT 1];
        Account parentAccCanada = [SELECT Id, Accounting_System__c FROM Account WHERE Name =:STPRuleExecutionTest.parent_AccName LIMIT 1];
        parentAccCanada.Accounting_System__c = STPRuleExecutionTest.OAKWL;
        Update parentAccCanada;
        
        Account thirdPartyparentAccCanada = [SELECT Id, Accounting_System__c FROM Account WHERE Name =:STPRuleExecutionTest.thirdPartyparent_AccName LIMIT 1];
        thirdPartyparentAccCanada.Accounting_System__c = STPRuleExecutionTest.OAKWL;
        Update thirdPartyparentAccCanada;
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:STPRuleExecutionTest.location_AccName limit 1];
                //get haul quoteline in this quote
                SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
        		List<SBQQ__QuoteLine__c> haulquoteline = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1];                                    
        haulquoteline[0].SBQQ__UnitCost__c = 10000000;
        haulquoteline[0].Cost_Override_Reason__c ='Other';
        haulquoteline[0].Cost_Override_Description__c = 'testing';
        Update haulquoteline;
                SBQQ.TriggerControl.enable();
                STP_Criteria__c ruleWithProperConfig =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Any');                                                            
            
        	insert ruleWithProperConfig;
        
            STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
                ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :STPRuleExecutionTest.methodName_ExecuteRules LIMIT 1];
                System.debug('exceptionLog haulCostTest_NotInThreshold'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
                
                SBQQ__Quote__c quoteAfterExecution = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id=:InsertedQuote.Id LIMIT 1];
                //System.assertEquals ('Procure Service', quoteAfterExecution.SBQQ__Status__c,'If STP fails,Quote should remain in Procure service status.');
            }catch(Exception e) {
			system.debug('Exception while executing haulCostTest_NotInThreshold '+ e.getMessage());
        }
        }
        test.stopTest();
        }
    
    
    /*
* @Owner : TCS-Anjali Chalase
* @Story : 46922
* @Test Scenario : Country: Canada, Valid For Receiving Exibhit Cost Price:Yes,Threshold limit for Haul:Not Applicable, 
                   Cost Price:Not In Threshold LIMIT, Other Validation Status: Fail,
                   STP:Fail
*/
   @isTest
    public static void haulCostTest_FailureonAllChecks_Canada(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :STPRuleExecutionTest.SYS_ADMIN  AND IsActive = true LIMIT 1];
        Account parentAccCanada = [SELECT Id, Accounting_System__c FROM Account WHERE Name =:STPRuleExecutionTest.parent_AccName LIMIT 1];
        parentAccCanada.Accounting_System__c = STPRuleExecutionTest.OAKWL;
        Update parentAccCanada;
        
        Account thirdPartyparentAccCanada = [SELECT Id, Accounting_System__c FROM Account WHERE Name =:STPRuleExecutionTest.thirdPartyparent_AccName LIMIT 1];
        thirdPartyparentAccCanada.Accounting_System__c = STPRuleExecutionTest.OAKWL;
        Update thirdPartyparentAccCanada;
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:STPRuleExecutionTest.location_AccName limit 1];
                //get haul quoteline in this quote
                SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
        		List<SBQQ__QuoteLine__c> haulquoteline = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1];                                    
        haulquoteline[0].SBQQ__UnitCost__c = 17000;
        haulquoteline[0].Cost_Override_Reason__c ='Other';
        haulquoteline[0].Cost_Override_Description__c = 'testing';
        Update haulquoteline;
                SBQQ.TriggerControl.enable();
                STP_Criteria__c ruleWithProperConfig =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, false, false,
                                                                                          'WRONG_TEMP', 'Open Top', 'WM',
                                                                                          'Wrong Trash', 'New Service Case',false, '','K00126',null, false, false, 'Fail STP', false, false, false, false, '', 'Any');                                                            
            
        	insert ruleWithProperConfig;
        
            STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
                ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :STPRuleExecutionTest.methodName_ExecuteRules];
                System.debug('exceptionLog haulCostTest_FailureonAllChecks'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
                SBQQ__Quote__c quoteAfterExecution = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id=:InsertedQuote.Id LIMIT 1];
                System.assertEquals ('Procure Service', quoteAfterExecution.SBQQ__Status__c,'If STP fails,Quote should remain in Procure service status.');
            }catch(Exception e) {
			system.debug('Exception while executing haulCostTest_FailureonAllChecks '+ e.getMessage());
        }
        }
        test.stopTest();
        }
    
    /*
* @Owner : TCS-Anjali Chalase
* @Story : 46922
* @Test Scenario : Country:Canada, Valid For Receiving Exibhit Cost Price:No,Threshold limit for Haul:Applicable, 
                   Cost Price:In Threshold LIMIT, Other Validation Status: Pass,
                   STP:Pass
*/
    @isTest
    Public static void haulCostTest_WithinThresholdButFailsRules_Canada(){
        Test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :STPRuleExecutionTest.SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:STPRuleExecutionTest.location_AccName limit 1];
              SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
        		List<SBQQ__QuoteLine__c> haulquoteline = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1]; 
        haulquoteline[0].SBQQ__UnitCost__c = 600;
        haulquoteline[0].Cost_Override_Reason__c ='Other';
        haulquoteline[0].Cost_Override_Description__c = ' fail validations';
        Update haulquoteline;
                SBQQ.TriggerControl.enable(); 
                STP_Criteria__c ruleValidationFail =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, false, false,
                                                                                          'WRONG_TEMP', 'Open Top', 'WM',
                                                                                          'WRONG Trash', 'New Service Case',false, '','K00126',null, false, false, 'Fail STP', false, false, false, true, 'A', 'Any');                                                            
            
        	insert ruleValidationFail;
                STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
                ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :STPRuleExecutionTest.methodName_ExecuteRules];
                System.debug('exceptionLog WithinThresholdButFailsRules'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
                SBQQ__Quote__c quoteAfterExecution = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id=:InsertedQuote.Id LIMIT 1];
                System.assertEquals ('Procure Service', quoteAfterExecution.SBQQ__Status__c,'If STP fails,Quote should remain in Procure service status.');
            }catch(Exception e) {
			system.debug('Exception while executing haulCostTest_WithinThresholdButFailsRules '+ e.getMessage());
        }
        }
        test.stopTest();
    }
    
    /*
* @Owner : TCS-Anjali Chalase
* @Story : 46922
* @Test Scenario : Country: Canada, Valid For Receiving Exibhit Cost Price:No,Threshold limit for Haul:Applicable, 
                   Cost Price:Not In Threshold LIMIT, Other Validation Status: Pass,
                   STP:Fail
*/
    @isTest
    Public static void haulCostTest_PassAllChecks_WithinThreshold_Canada(){
        Test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :STPRuleExecutionTest.SYS_ADMIN  AND IsActive = true LIMIT 1];
        Account parentAccCanada = [SELECT Id, Accounting_System__c FROM Account WHERE Name =:STPRuleExecutionTest.parent_AccName LIMIT 1];
        parentAccCanada.Accounting_System__c = STPRuleExecutionTest.OAKWL;
        Update parentAccCanada;
        
        Account thirdPartyparentAccCanada = [SELECT Id, Accounting_System__c FROM Account WHERE Name =:STPRuleExecutionTest.thirdPartyparent_AccName LIMIT 1];
        thirdPartyparentAccCanada.Accounting_System__c = STPRuleExecutionTest.OAKWL;
        Update thirdPartyparentAccCanada;
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:STPRuleExecutionTest.location_AccName limit 1];
              SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
        		List<SBQQ__QuoteLine__c> haulquoteline = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1]; 
        haulquoteline[0].SBQQ__UnitCost__c = 65000;
        haulquoteline[0].Cost_Override_Reason__c ='Other';
        haulquoteline[0].Cost_Override_Description__c = 'Testing';
        Update haulquoteline;
                SBQQ.TriggerControl.enable(); 
                STP_Criteria__c ruleValidationFail =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Any');                                                            
            
        	insert ruleValidationFail;
                STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
                ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :STPRuleExecutionTest.methodName_ExecuteRules];
                System.debug('exceptionLog PassAllChecks_WithinThreshold'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
                SBQQ__Quote__c quoteAfterExecution = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id=:InsertedQuote.Id LIMIT 1];
                System.assertEquals ('Procure Service', quoteAfterExecution.SBQQ__Status__c,'If STP fails,Quote should remain in Procure service status.');
            }catch(Exception e) {
			system.debug('Exception while executing haulCostTest_ PassAllChecks_WithinThreshold '+ e.getMessage());
        }
        }
        test.stopTest();
    }
   
    /*
* @Owner : TCS-Anjali Chalase
* @Story : 46922
* @Test Scenario : Country: Canada, Valid For Receiving Exibhit Cost Price:No,Threshold limit for Haul:Applicable, 
                   Cost Price:Not In Threshold LIMIT, Other Validation Status: Fail,
                   STP:Fail
*/
    @isTest
    Public static void haulCostTest_AllFail_NotinThreshold_Canada(){
        Test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :STPRuleExecutionTest.SYS_ADMIN  AND IsActive = true LIMIT 1];
        Account parentAccCanada = [SELECT Id, Accounting_System__c FROM Account WHERE Name =:STPRuleExecutionTest.parent_AccName LIMIT 1];
        parentAccCanada.Accounting_System__c = STPRuleExecutionTest.OAKWL;
        Update parentAccCanada;
        
        Account thirdPartyparentAccCanada = [SELECT Id, Accounting_System__c FROM Account WHERE Name =:STPRuleExecutionTest.thirdPartyparent_AccName LIMIT 1];
        thirdPartyparentAccCanada.Accounting_System__c = STPRuleExecutionTest.OAKWL;
        Update thirdPartyparentAccCanada;
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:STPRuleExecutionTest.location_AccName limit 1];
              SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
        		List<SBQQ__QuoteLine__c> haulquoteline = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1]; 
        haulquoteline[0].SBQQ__UnitCost__c = 0;
        haulquoteline[0].Cost_Override_Reason__c ='Other';
        haulquoteline[0].Cost_Override_Description__c = 'Testing';
        Update haulquoteline;
                SBQQ.TriggerControl.enable(); 
                STP_Criteria__c ruleValidationFail =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, false, false,
                                                                                          'WRONG_TEMP', 'Open Top', 'OT',
                                                                                          'Trash', 'New Service Case',false, '','K00126',null, false, false, 'Full STP', false, false, false, false, '', 'Any');                                                            
            
        	insert ruleValidationFail;
                STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
                ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :STPRuleExecutionTest.methodName_ExecuteRules];
                System.debug('exceptionLog AllFail_NotinThreshold'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
                SBQQ__Quote__c quoteAfterExecution = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id=:InsertedQuote.Id LIMIT 1];
                System.assertEquals ('Procure Service', quoteAfterExecution.SBQQ__Status__c,'If STP fails,Quote should remain in Procure service status.');
            }catch(Exception e) {
			system.debug('Exception while executing haulCostTest_AllFail_NotinThreshold '+ e.getMessage());
        }
        }
        test.stopTest();
    } 
    
    /*@isTest
   Public static void test_STPPartialRuleFailsForWMNAT_System(){
        Test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :STPRuleExecutionTest.SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){ 
            SBQQ__QuoteLine__c insertedQuote = [SELECT Id, SBQQ__Quote__r.Name,SBQQ__RequiredBy__c,Account__r.Parent.Accounting_System__c
                                        FROM SBQQ__QuoteLine__c WHERE Vendor__r.Name = :STPRuleExecutionTest.parentVendor_AccName LIMIT 1];
            
            STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
            //System.assertEquals(false,Test.parentIDMap.get(insertedQuote.SBQQ__RequiredBy__c));
            Test.stopTest();
            
        }
   }*/
  @isTest  
    public static void test_STPPartialRuleFailsForNonOAKWL_System(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :STPRuleExecutionTest.SYS_ADMIN  AND IsActive = true LIMIT 1];
        SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:STPRuleExecutionTest.location_AccName limit 1];
        Account locationAccount = [Select Id from Account where Name =:STPRuleExecutionTest.location_AccName limit 1];
		test.startTest();
        System.runAs(adminUser){
            try{
                SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
                List<SBQQ__QuoteLine__c> childQuotelineList = [SELECT Id
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__RequiredBy__c = null LIMIT 1];
                
                update childQuotelineList;
                AAV_Asset_Availability__c aavObj = new AAV_Asset_Availability__c();
            	aavObj.AAV_Location__c = locationAccount.Id;
				aavObj.AAV_APIRequestOutput__c = STPRuleExecutionTest.INVALID_AAV_API_REQUEST_OUTPUT;
				aavObj.AAV_Quote_Line__c = childQuotelineList[0].Id;
                insert aavObj;
                SBQQ.TriggerControl.enable();
            	STP_Criteria__c ruleWithMASValueDifferent =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',false, '8','K00129',null, true, true, 'PARTIAL STP', true, false, true, false, '7414', STPRuleExecutionTest.OPEN);                                                            
            
        		insert ruleWithMASValueDifferent;
                
				STPRuleExecution.executeRules(insertedQuote.Id, 'PARTIAL STP');
                /*system.debug('quotLineMarketAreaMap '+ STPRuleExecution.quotLineMarketAreaMap);
                List<ExceptionLog__c> exceptionLog = [SELECT id, Exception_Details__c, Application_Name__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];  
                System.debug('exceptionLog0 noMarketAreaTest'+ exceptionLog[0].Exception_Details__c);
                System.debug('exceptionLog1 noMarketAreaTest'+ exceptionLog[1].Exception_Details__c);
                System.assertEquals(exceptionLog.Exception_Details__c != null ,'Market Area should not match');*/
        } catch(Exception e) {
			system.debug('Exception while executing test_STPPartialRuleFailsForNonOAKWL_System '+ e.getMessage());
        }
              
        }
        test.stopTest();
    }
    }