@isTest
private with sharing class AAV_APIIntegrationTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string EQUIPMENT = 'Equipment';
    private static final string SERVICES = 'Services';
    // private static final string PERMANENT = 'PERM';
    private static final string ON_CALL = 'On-Call';
    private static final string TRASH = 'Trash';

    @testSetup static void setup() {
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        
        User bypassuser = TestDataFactory.createUser(adminProfile);
        bypassuser.Bypass_Validation__c = true;
        insert bypassuser;
        system.runAs(usr)
        { 
            //Changes for SDT-39632
            CodeSwitchTestData.CodeSwitchData();
            
            List<Opportunity> oppList = new List<Opportunity>();
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            List<Product2> prdList = new List<Product2>();    
            list<Account> acclist = new List<Account>();

            Account accParent = new Account(Name = 'Parent Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='5678',
             RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true); 
            insert accParent;

            Account acc = new Account(Name = Constant_Util.KEYWORD_TEST, phone = '9999999999', OwnerId = usr.id, AccountNumber='1234',
                RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, ParentId = accParent.Id, Type ='Location');
            acclist.add(acc);

            Account vendorAcc = new Account(Name = 'Vendor Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='4321',
             RecordTypeid = TestDataFactory.getRecordType('Vendor','Account'));
            acclist.add(vendorAcc);

            Database.insert(acclist);

            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Chicago';
            locationlist[0].IsPricingEligible__c = true;
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);

            //Inserting Account Position (Location_Position)
            Account_Position__c accLocPosition = new Account_Position__c(AccountId__c = acclist[0].Id,
            Container_Position__c = 'Test 2',
            AlternatePostalCode__c = '1234',
            AlternateCity__c = 'Test City',
            AlternateCountry__c = 'USA',
            AlternateState__c = 'NY',
            AlternateStreet__c = 'Day Hill Road');
            insert accLocPosition;

            //Inserting Case

            Case newServiceCase = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0),usr,locationlist.get(0)); 
            newServiceCase.Service_Date__c = system.today() + 1;
            newServiceCase.SLA_Service_Date_Time__c = system.today() + 2;
            newServiceCase.Case_Type__c = 'New Service';
            newServiceCase.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'New Service Case'].Id;  
            newServiceCase.Case_Sub_Type__c = 'Permanent';
            newServiceCase.Case_Reason__c = 'Existing Location';
            newServiceCase.LOB__c = 'Rolloff';
            newServiceCase.Status = 'Open';
            newServiceCase.Service_Occurrence_Type_Code__c = ON_CALL;
            newServiceCase.Material_Type__c = TRASH;
            
            Database.insert(newServiceCase);

            oppList.addAll(TestDataFactory.createOpportunity(1,'TestOpportunityTest',newServiceCase.Id,newServiceCase.Case_Sub_Type__c, newServiceCase.Location__c));
            insert oppList;
            System.Debug('@@@~Create Opp : ' + oppList);
            
            quoteList.addAll(TestDataFactory.createQuoteRecords(oppList,locationlist[0],conlist[0],Date.today(),false,true));
            quoteList[0].SBQQ__ShippingStreet__c = 'ABC';
            quoteList[0].SBQQ__ShippingCity__c = 'Test1';
            quoteList[0].SBQQ__ShippingCountry__c = 'USA';
            quoteList[0].SBQQ__ShippingState__c = 'NY';
            quoteList[0].SBQQ__ShippingPostalCode__c = '1234';
            quoteList[0].Duration__c = 'Permanent';
            insert quoteList;

            Product2 prodOpenTop = TestDataFactory.createProduct('Open Top',EQUIPMENT, 'OT');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prdList.add(prodOpenTop);

            Product2 prodCompactor = TestDataFactory.createProduct('Compactor',EQUIPMENT, 'CMP');
            prodCompactor.Is_Pricing_Eligible__c = true;
            prdList.add(prodCompactor);

            Product2 prodDumpster = TestDataFactory.createProduct('Dumpster',EQUIPMENT, 'DMP');
            prodDumpster.Is_Pricing_Eligible__c = true;
            prdList.add(prodDumpster);

            Product2 prodNull= TestDataFactory.createProduct('Error',EQUIPMENT,'ERR');
            prodNull.Is_Pricing_Eligible__c = true;
            prdList.add(prodNull);

            Product2 prodPickup= TestDataFactory.createProduct('Pickup',SERVICES,'PCK');
            prdList.add(prodPickup);

            Product2 prodExPickup= TestDataFactory.createProduct('Extra Pickup',SERVICES,'PCK');
            prdList.add(prodExPickup);

            Product2 prodHaul= TestDataFactory.createProduct('Haul',SERVICES,'H');
            prdList.add(prodHaul);

            Product2 prodDisposal= TestDataFactory.createProduct('Disposal',SERVICES,'DSP');
            prdList.add(prodDisposal);

            Product2 prodTrash = TestDataFactory.createProduct('Trash','Waste Stream','T');
            prodTrash.Is_Pricing_Eligible__c = true;
            prdList.add(prodTrash);

            Product2 prodCardboard = TestDataFactory.createProduct('Cardboard','Waste Stream','C');
            prodCardboard.Is_Pricing_Eligible__c = true;
            prdList.add(prodCardboard);

            Database.insert(prdList);

            RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
            QuoteLineTriggerHelper.extrapickUpRecursion = false;

            List<SBQQ__QuoteLine__c> qlHdr = new List<SBQQ__QuoteLine__c>();

            //Bundle 1 - Open Top
            SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOT.SBQQ__Bundle__c = TRUE;
            qlOT.SBQQ__RequiredBy__c = null;
            //qlOT.Vendor__c = vendorAcc.Id;
         //   qlOT.Location_Position_Name__c = accLocPosition.Id;
            qlHdr.add(qlOT);

             //Bundle 3 - Vertical Compactor
             SBQQ__QuoteLine__c qlCMPV = TestDataFactory.createQuoteLineRecords(quoteList[0],prodCompactor,'TEMP',1.00,'CLT','YRDS-20','OC',null,null,'PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
             qlCMPV.SBQQ__Bundle__c = TRUE;
             qlCMPV.SBQQ__RequiredBy__c = null;
             //qlCMPV.Vendor__c = vendorAcc.Id;
             qlHdr.add(qlCMPV);

             //Bundle 2 - Dumpster
             SBQQ__QuoteLine__c qlDMP = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDumpster,'PERM',1.00,'CLT','YRDS-4','SCH','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
             qlDMP.SBQQ__Bundle__c = TRUE;
             qlDMP.SBQQ__RequiredBy__c = null;
             //qlDMP.Vendor__c = vendorAcc.Id;
             qlHdr.add(qlDMP);

              //Bundle 5 - Error
            SBQQ__QuoteLine__c qlErr = TestDataFactory.createQuoteLineRecords(quoteList[0],prodNull,'TEMP',1.00,'CLT','YRDS-30','OC',null,null,'PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlErr.SBQQ__Bundle__c = TRUE;
            qlErr.SBQQ__RequiredBy__c = null;
            qlHdr.add(qlErr);
             SBQQ.TriggerControl.disable();
             try 
             {
                 insert qlHdr;
             } 
             finally {
             SBQQ.TriggerControl.enable();
             }

             List<SBQQ__QuoteLine__c> qlChild = new List<SBQQ__QuoteLine__c>();
             //Open Top Child Quote Line  --- Start
            SBQQ__QuoteLine__c qlOTT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodTrash,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOTT.SBQQ__RequiredBy__c = qlOT.Id;
            //qlOTT.Vendor__c = vendorAcc.Id;
            qlChild.add(qlOTT);

            SBQQ__QuoteLine__c qlHaul = TestDataFactory.createQuoteLineRecords(quoteList[0],prodHaul,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlHaul.SBQQ__RequiredBy__c = qlOT.Id;
            //qlHaul.Vendor__c = vendorAcc.Id;
            qlChild.add(qlHaul);

            SBQQ__QuoteLine__c qlDisposal = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDisposal,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDisposal.SBQQ__RequiredBy__c = qlOT.Id;
            //qlDisposal.Vendor__c = vendorAcc.Id;
            qlChild.add(qlDisposal);
            //Open Top Child Quote Line  --- End

            
            //Dumpster Child Quote Line  --- Start
            SBQQ__QuoteLine__c qlDMPC = TestDataFactory.createQuoteLineRecords(quoteList[0],prodCardboard,'PERM',1.00,'CLT','YRDS-4','SCH','W','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDMPC.SBQQ__RequiredBy__c = qlDMP.Id;
            //qlDMPC.Vendor__c = vendorAcc.Id;
            qlChild.add(qlDMPC);

            SBQQ__QuoteLine__c qlPCK = TestDataFactory.createQuoteLineRecords(quoteList[0],prodPickup,'PERM',1.00,'CLT','YRDS-4','SCH','','','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlPCK.SBQQ__RequiredBy__c = qlDMP.Id;
            //qlPCK.Vendor__c = vendorAcc.Id;
            qlChild.add(qlPCK);
            
            SBQQ__QuoteLine__c qlEPCK = TestDataFactory.createQuoteLineRecords(quoteList[0],prodExPickup,'PERM',1.00,'CLT','YRDS-4','SCH','','','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlEPCK.SBQQ__RequiredBy__c = qlDMP.Id;
            //qlEPCK.Vendor__c = vendorAcc.Id;
            qlChild.add(qlEPCK);
            //Dumpster Child Quote Line  --- End

            SBQQ.TriggerControl.disable();
            try 
            {
                Database.insert(qlChild);
            } 
            finally {
            SBQQ.TriggerControl.enable();
            }

        }

    }

    @isTest static void testMethod1() {
        user currentuser = [select id, Bypass_Validation__c,IsActive,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            list<SBQQ__QuoteLine__c> qlist= [select Id, Duration__c from SBQQ__QuoteLine__c where SBQQ__RequiredBy__c=null];
            system.debug('qlist '+qlist);
            if(qlist != null && qlist.size() > 0){   
                          
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new AAV_APIIntegrationMockTest());
                    AAV_APIIntegration.getAvailabilityResponse(qlist[0].Id);
                Test.stopTest(); 
                AAV_APIIntegration.getAvailabilityResponse(qlist[0].Id);
                AAV_APIIntegration.getAvailabilityRecord(qlist[0].Id);
            }            
        }
    }
    @isTest static void testMethod4() {
        user currentuser = [select id, Bypass_Validation__c,IsActive,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            list<SBQQ__QuoteLine__c> qlist= [select Id, Duration__c from SBQQ__QuoteLine__c where SBQQ__RequiredBy__c=null];
            system.debug('qlist '+qlist);
            if(qlist != null && qlist.size() > 0){          
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new AAV_APIIntegrationMockTest());
                ServiceSchedulerCtrl.retryAvailabilityResponse(qlist[0].Id);
                Test.stopTest(); 
                ServiceSchedulerCtrl.retryAvailabilityResponse(qlist[0].Id);
            }            
        }
    }

    @isTest static void testMethod2() {
        user currentuser = [select id, Bypass_Validation__c,IsActive,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            list<SBQQ__QuoteLine__c> qlist= [select Id, Duration__c from SBQQ__QuoteLine__c where SBQQ__RequiredBy__c=null];
            system.debug('qlist '+qlist);
            if(qlist != null && qlist.size() > 1){   
                system.debug('Coming Inside');             
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new AAV_APIIntegrationMockTest());
                    AAV_APIIntegration.getAvailabilityResponse(qlist[1].Id);
                    delete qlist[1]; 
                Test.stopTest();  
            }
            
        }
    }

    @isTest static void testMethod3() {
        user currentuser = [select id, Bypass_Validation__c,IsActive,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            list<SBQQ__QuoteLine__c> qlist= [select Id,SBQQ__Quote__c,SBQQ__Product__c, Duration__c,AAV_Delivery_Availability__c,
                        AAV_Service_Availability__c,AAV_Requested_AdditionalServicesAccessor__c,
                        SBQQ__StartDate__c, AAV_Priority__c //SDT-28610
                        FROM SBQQ__QuoteLine__c where SBQQ__RequiredBy__c=null];
            system.debug('qlist '+qlist);
            if(qlist != null && qlist.size() > 0){   
                qlist[0].AAV_Requested_AdditionalServicesAccessor__c = 'Requested Additional Services & Accessories';
                qlist[0].AAV_Service_Availability__c = 'Selected Service is NOT as per WM Availability';
                qlist[0].AAV_Delivery_Availability__c = 'Selected Delivery is NOT as per WM Availability, selected date is beyond SLA days but within 30 days';
                qlist[0].AAV_Service_Days_Unavailable__c = 'S';
                update qlist[0];
                AAV_AvailabilityUtility.getAvailabilityFlagMap();
                Availability_Flag__mdt availability = AAV_AvailabilityUtility.getAvailabilityFlag(qlist[0]);
                AAV_AvailabilityUtility.availabilityComments(qlist[0].SBQQ__Quote__c); 
                AAV_AvailabilityUtility.getSelectedServices(qlist[0].Id, qlist[0].SBQQ__Product__c);
            }
            
        }
    }

    @isTest static void testgetAvailabilityBellIconMessageMethod() {
        user currentuser = [select id, Bypass_Validation__c,IsActive,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        List<String> lstCustomLabels=new List<String>();
        lstCustomLabels.add('AAV_Alternate_Products_Threshold');
        AAV_AvailabilityUtility.getCustomLabels(lstCustomLabels);
        // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            list<SBQQ__QuoteLine__c> qlist= [select Id,SBQQ__Quote__c,SBQQ__Product__c, Duration__c,AAV_Delivery_Availability__c,
                        AAV_Service_Availability__c,AAV_Requested_AdditionalServicesAccessor__c
                        FROM SBQQ__QuoteLine__c where SBQQ__RequiredBy__c=null];
            system.debug('qlist '+qlist);
            if(qlist != null && qlist.size() > 0){   
                qlist[0].AAV_Requested_AdditionalServicesAccessor__c = 'Requested Additional Services & Accessories';
                qlist[0].AAV_Service_Availability__c = 'Selected Service is NOT as per WM Availability';
                qlist[0].AAV_Delivery_Availability__c = 'Selected Delivery is NOT as per WM Availability, selected date is beyond SLA days but within 30 days';
                qlist[0].AAV_Service_Days_Unavailable__c = 'S';
                qlist[0].Availability_Flag__c='WM Availability NOT Confirmed - Delivery';
                qlist[0].AAV_Asset_Availability_API_Errors__c='	{"service":["No WM service day information is available for this location, please confirm with WM dispatch"],"delivery":[],"common":[]}';
                update qlist[0];
                
                AAV_AvailabilityUtility.getAvailabilityBellIconMessage(qlist[0],'No WM service day information is available for this location, please confirm with WM dispatch');
                  

            }
            
        }
    }

    //SDT 31585
    //this test method covers both the getUpdatedAvailability() and createCommentForAAVChangeHistory() methods that were added as part of SDT 31585
    @isTest static void testgetUpdatedAvailability() {
        user currentuser = [select id, Bypass_Validation__c,IsActive,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(currentuser){
            list<SBQQ__QuoteLine__c> qlist= [select Id, Duration__c from SBQQ__QuoteLine__c where SBQQ__RequiredBy__c=null];
            if(qlist != null && qlist.size() > 0){   
                          
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new AAV_APIIntegrationMockTest());
                    AAV_APIIntegration.getUpdatedAvailability(qlist[0].Id, System.today());
                Test.stopTest(); 
            }
        }
    }
}