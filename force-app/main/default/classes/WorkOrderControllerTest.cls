@isTest
public class WorkOrderControllerTest{
    @testSetup 
    static void createData() {
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        insert usr;
        List<Account> accList;
        List<Account> locationList;
        List<Contact> conList;
        List<Case> caseList;
        List<Opportunity> oppList;
        List<Product2> prodList= new List<Product2>();
        List<Pricebookentry> pbeList= new List<Pricebookentry>();
        System.runAs(usr){
            //Changes for SDT-39632
            CodeSwitchTestData.CodeSwitchData();
            
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            insert accList;
            locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            insert locationList;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;
            Product2 prodOT = TestDataFactory.createProduct('Open Top','Equipment','OT');
            prodOT.Bypass_Acorn_Integration__c= false;
            Product2 prod = TestDataFactory.createProduct('Delivery','Services','DLV');
            Product2 prod1 = TestDataFactory.createProduct('Pickup','Services','PCK');
            Product2 prod2 =TestDataFactory.createProduct('Removal','Services','REM');
            //Changes related to SDT-38985
            Product2 prodLock = TestDataFactory.createProduct('Keys', 'Surcharges and Fees', 'LCKF');
            Product2 prodPowerSpray = TestDataFactory.createProduct('Power Spray Wash', 'Services', 'PSW');
            //Product2 prod3 = TestDataFactory.createProduct('Extra Pickup','Services','PCK');
            prodList.add(prodOT);
            prodList.add(prod);
            prodList.add(prod1);
            prodList.add(prod2);
            //Changes related to SDT-38985
            prodList.add(prodLock);
            prodList.add(prodPowerSpray);
            //prodList.add(prod3);
            insert prodList;
            Pricebookentry pbeObjOT= new Pricebookentry(Product2Id = prodOT.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            Pricebookentry pbeObj1= new Pricebookentry(Product2Id = prod.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            Pricebookentry pbeObj2= new Pricebookentry(Product2Id = prod1.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            Pricebookentry pbeObj3= new Pricebookentry(Product2Id = prod2.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            //Pricebookentry pbeObj4= new Pricebookentry(Product2Id = prod3.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            pbeList.add(pbeObjOT);
            pbeList.add(pbeObj1);
            pbeList.add(pbeObj2);
            pbeList.add(pbeObj3);
            //pbeList.add(pbeObj4);
            insert pbeList;
        }
        List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> qlList= new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c parentQl= new SBQQ__QuoteLine__c();
        Profile prfl = [SELECT Id FROM Profile WHERE Name = 'Customer Service'];
        User usrObj= TestDataFactory.createUser(prfl); 
        insert usrObj;
        List<PermissionSetLicense> pslList= [SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' AND Status='Active'];
        insert new PermissionSetLicenseAssign(AssigneeId = usrObj.Id, PermissionSetLicenseId= pslList[0].Id);
        List<PermissionSet> psgList= [SELECT Id FROM PermissionSet WHERE Name = 'QuoteOrdersUser'];
        insert new PermissionSetAssignment(AssigneeId = usrObj.Id, PermissionSetId = psgList[0].id);
        System.runAs(usrObj){
          caseList= new List<Case>();
          oppList= new List<Opportunity>();
          caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
          insert caseList;
          oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
          insert oppList;
          quoteList= TestDataFactory.createQuoteRecords(1,oppList,accList[0],conList[0],Date.today(),false,false);
          insert quoteList;
          parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],prodList[0],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
          parentQl.LocationPositionName__c='Test Location';
          parentQl.SBQQ__StartDate__c= Date.today();
          parentQl.Vendor_Commit_Date__c = Date.today();   //SDT-32136
          parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
          insert parentQl;
          //Changes related to SDT-38985
          for(Integer i=0;i<5;i++){
              qlList.add(TestDataFactory.createQuoteLineRecords(quoteList[0],prodList[i+1],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG'));
              qlList[i].SBQQ__StartDate__c= Date.today();
              qlList[i].Vendor_Commit_Date__c= Date.today(); //SDT-32136
              qlList[i].SBQQ__EndDate__c= Date.today().addDays(25);
              qlList[i].SBQQ__RequiredBy__c= parentQl.Id;
          }
          insert qlList;
          Quote_Order__c qo = new Quote_Order__c();
            qo.Quote_Line__c= parentQl.id;
            qo.Service_Quote_Line__c= qlList[2].id;
            qo.Service_Type__c='Pickup';
            qo.Product_Type__c='Haul';
            qo.Service_Date__c= Date.today();
            qo.Instructions__c= 'test1234';
            qo.Onsite_Contact__c = 'test';
            qo.Onsite_Contact_Phone__c = '9999999';
            qo.Cust_Ref_Number__c='test12345';
            qo.Duration__c='PERM';
            qo.Occurrence_Type__c='OC';
            qo.Quantity__c = 20;
            qo.Service_Time_Span__c= 'ASAP';
            insert qo;
            
            //Changes related to SDT-38985
            Quote_Order__c qoLockDelivery = new Quote_Order__c();
            qoLockDelivery.Quote_Line__c= parentQl.id;
            qoLockDelivery.Service_Quote_Line__c= qlList[3].id;
            qoLockDelivery.Service_Type__c='Lock Delivery';
            qoLockDelivery.Product_Type__c='Keys';
            qoLockDelivery.Service_Date__c= Date.today();
            qoLockDelivery.Instructions__c= 'test1234';
            qoLockDelivery.Onsite_Contact__c = 'test';
            qoLockDelivery.Onsite_Contact_Phone__c = '9999999';
            qoLockDelivery.Cust_Ref_Number__c='test12345';
            qoLockDelivery.Duration__c='PERM';
            qoLockDelivery.Occurrence_Type__c='OC';
            qoLockDelivery.Quantity__c = 20;
            qoLockDelivery.Service_Time_Span__c= 'ASAP';
            insert qoLockDelivery;
            
            //Changes related to SDT-38985
            Quote_Order__c qoPowerWash = new Quote_Order__c();
            qoPowerWash.Quote_Line__c= parentQl.id;
            qoPowerWash.Service_Quote_Line__c= qlList[4].id;
            qoPowerWash.Service_Type__c='Power Wash';
            qoPowerWash.Product_Type__c='Power Spray Wash';
            qoPowerWash.Service_Date__c= Date.today();
            qoPowerWash.Instructions__c= 'test1234';
            qoPowerWash.Onsite_Contact__c = 'test';
            qoPowerWash.Onsite_Contact_Phone__c = '9999999';
            qoPowerWash.Cust_Ref_Number__c='test12345';
            qoPowerWash.Duration__c='PERM';
            qoPowerWash.Occurrence_Type__c='OC';
            qoPowerWash.Quantity__c = 20;
            qoPowerWash.Service_Time_Span__c= 'ASAP';
            insert qoPowerWash;
        }
    }
    @isTest 
    static void retrieveAction_Test(){
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c limit 1];
        List<SBQQ__QuoteLine__c> quoteLine= [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c,SBQQ__EndDate__c,IsExtraPickup__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null];
        //Changed related to SDT-38985
        List<Quote_Order__c> qoObjList = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Pickup' OR Service_Type__c='Lock Delivery' OR Service_Type__c=	'Power Wash'];
        String serviceTypeList= '["Pickup","Delivery","Removal"]'; //list size =3
        Test.startTest();
            String str1 = WorkOrderController.getQuoteLineParentProductsNew(String.valueOf(quoteLine[0].SBQQ__RequiredBy__c), userInfo.getUserId());
            WorkOrderController.SelectedProductWrapper spw= (WorkOrderController.SelectedProductWrapper)System.JSON.deserialize(str1,WorkOrderController.SelectedProductWrapper.class);
            String str2 = WorkOrderController.quoteLineFeatureProductOptionsNew(String.valueOf(quote.id), String.valueOf(quoteLine[0].SBQQ__RequiredBy__c), String.valueOf(serviceTypeList));
            List<WorkOrderController.QuoteLineProductOptionsWrapper> qpowList= (List<WorkOrderController.QuoteLineProductOptionsWrapper>)System.JSON.deserialize(str2,List<WorkOrderController.QuoteLineProductOptionsWrapper>.class);
            String str3 = WorkOrderController.getQuoteOrdersByQuoteLine(String.valueOf(quoteLine[0].SBQQ__RequiredBy__c),true);
            List<WorkOrderController.QuoteOrderWrapper> qoList= (List<WorkOrderController.QuoteOrderWrapper>)System.JSON.deserialize(str3,List<WorkOrderController.QuoteOrderWrapper>.class);
        Test.stopTest();
        System.assertEquals('Open Top-YRDS-20-TEMP', spw.selectedProd, 'Selected Prod is not the expected result.');
        System.assertEquals(3,qpowList.size() , 'Quote Lines product options are mismatched.');
        System.assertEquals(qoList.size(),qoObjList.size() , 'All Quote Orders are not retrieved.');
    }
    @isTest
    static void saveAction_newQO_Test(){
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c limit 1];
        //Changes related to SDT-38985
        List<SBQQ__QuoteLine__c> lockDeliveryquoteLine= [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c,SBQQ__EndDate__c,Vendor_Commit_Date__c,IsExtraPickup__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null AND SBQQ__ProductName__c = 'Keys'];
        List<Quote_Order__c> qoObjLisForLockDelivery = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Lock Delivery'];
        delete qoObjLisForLockDelivery;
        
        List<SBQQ__QuoteLine__c> quoteLine= [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c,SBQQ__EndDate__c,Vendor_Commit_Date__c,IsExtraPickup__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null AND SBQQ__ProductName__c='Delivery']; //SDT-32136
        List<Quote_Order__c> qoObjList = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Delivery' limit 1];
        //Changes related to SDT-38985
        String newQOStr= '[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Delivery","occurenceType":"OC","duration":"TEMP","productType":"Delivery","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"'+Date.today()+'","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP","contact":"Test","phone":"7890654321","bypassWorkOrder":true},'+
        '{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Lock Delivery","occurenceType":"OC","duration":"PERM","productType":"Pickup","quoteLineId":"'+lockDeliveryquoteLine[0].Id+'","serviceDate":"'+Date.today()+'","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP","contact":"Test","phone":"7890654321" , "bypassWorkOrder": true}]';
        WorkOrderController.AssetAvailabilityWrapper aavWrap = new WorkOrderController.AssetAvailabilityWrapper();
        aavWrap.assetAvailability = false;
        Test.startTest();
            String str= WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c),quoteLine[0].SBQQ__StartDate__c,quoteLine[0].SBQQ__EndDate__c,quoteLine[0].Vendor_Commit_Date__c, newQOStr,aavWrap); // aavWrap: asset availability //SDT-32136
        Test.stopTest();
        System.assertEquals('success', str, 'QO are not saved successfully.');
    }
    @isTest
    static void saveAction_existingQO_Test(){
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c limit 1];
        //Changes related to SDT-38985
        List<SBQQ__QuoteLine__c> lockDeliveryquoteLine= [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c,SBQQ__EndDate__c,Vendor_Commit_Date__c,IsExtraPickup__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null AND SBQQ__ProductName__c = 'Keys'];
        List<Quote_Order__c> qoObjLisForLockDelivery = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Lock Delivery'];
        List<SBQQ__QuoteLine__c> powerWashquoteLine= [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c,SBQQ__EndDate__c,Vendor_Commit_Date__c,IsExtraPickup__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null AND SBQQ__ProductName__c = 'Power Spray Wash'];
        List<Quote_Order__c> qoObjLisForPowerWash = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Power Wash'];
        List<SBQQ__QuoteLine__c> quoteLine= [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c,SBQQ__EndDate__c,Vendor_Commit_Date__c,IsExtraPickup__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null AND (SBQQ__ProductName__c='Pickup' OR SBQQ__ProductName__c = 'Keys' OR SBQQ__ProductName__c ='Power Spray Wash')];
        List<Quote_Order__c> qoObjList = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Pickup' OR Service_Type__c='Lock Delivery'  OR Service_Type__c='Power Wash'];
        
        //Changes related to SDT-38985
        String existingQOStr= '[{"idField":"'+qoObjList[0].id+'","actionType":"changed","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Pickup","occurenceType":"OC","duration":"PERM","productType":"Pickup","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"'+Date.today()+'","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP","contact":"Test","phone":"7890654321" , "bypassWorkOrder": true},'+
            '{"idField":"'+qoObjLisForLockDelivery[0].id+'","actionType":"changed","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Lock Delivery","occurenceType":"OC","duration":"PERM","productType":"Pickup","quoteLineId":"'+lockDeliveryquoteLine[0].Id+'","serviceDate":"'+Date.today()+'","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP","contact":"Test","phone":"7890654321" , "bypassWorkOrder": true},'+
            '{"idField":"'+qoObjLisForPowerWash[0].id+'","actionType":"changed","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Power Wash","occurenceType":"OC","duration":"PERM","productType":"Power Spray Wash","quoteLineId":"'+powerWashquoteLine[0].Id+'","serviceDate":"'+Date.today()+'","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP","contact":"Test","phone":"7890654321" , "bypassWorkOrder": true}]';
        WorkOrderController.AssetAvailabilityWrapper aavWrap = new WorkOrderController.AssetAvailabilityWrapper();
        aavWrap.assetAvailability = true;
        aavWrap.deliveryAvailability = '2023-09-09';
        Test.startTest();
            String str= WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c),quoteLine[0].SBQQ__StartDate__c,quoteLine[0].SBQQ__EndDate__c,quoteLine[0].Vendor_Commit_Date__c,existingQOStr,aavWrap);// aavWrap: asset availability
        Test.stopTest();
        System.assertEquals('success', str, 'QO are not saved successfully.');
    }
    @isTest
    static void deleteAction_existingQO_Test(){
        List<Quote_Order__c> qoObjList = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Pickup' limit 1];
        Test.startTest();
            String str= WorkOrderController.deleteQuoteLineOrders(String.valueOf(qoObjList[0].id));
        Test.stopTest();
        System.assertEquals('success', str, 'QO are not deleted successfully.');
    }
    @isTest
    static void validateAction_newQO_Mul_DLV_Test(){
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c limit 1];
        List<SBQQ__QuoteLine__c> quoteLine= [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c,SBQQ__EndDate__c,Vendor_Commit_Date__c,IsExtraPickup__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null AND SBQQ__ProductName__c='Delivery'];//SDT-32136
        String newQOStr= '[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Delivery","occurenceType":"OC","duration":"TEMP","productType":"Delivery","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"'+Date.today()+'","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP","contact":"Test","phone":"7890654321" , "bypassWorkOrder":true},{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Delivery","occurenceType":"OC","duration":"TEMP","productType":"Delivery","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"'+Date.today()+'","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP","contact":"Test","phone":"7890654321" , "bypassWorkOrder":false},{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Delivery","occurenceType":"OC","duration":"TEMP","productType":"Delivery","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"'+Date.today()+'","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP","contact":"Test","phone":"7890654321" ,"bypassWorkOrder":true}]';
        WorkOrderController.AssetAvailabilityWrapper aavWrap = new WorkOrderController.AssetAvailabilityWrapper();
        aavWrap.assetAvailability = false;
        Test.startTest();
            String str= WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c),quoteLine[0].SBQQ__StartDate__c,quoteLine[0].SBQQ__EndDate__c,quoteLine[0].Vendor_Commit_Date__c,newQOStr,aavWrap);// aavWrap: asset availability //SDT-32136
        Test.stopTest();
        System.assert(str.contains('Error:'), 'Validation doesnt throw properly.');
    }
    @isTest
    static void validateAction_newQO_Mul_RMV_Test(){
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c limit 1];
        List<SBQQ__QuoteLine__c> quoteLine= [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c,SBQQ__EndDate__c,Vendor_Commit_Date__c,IsExtraPickup__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null AND SBQQ__ProductName__c='Removal']; //SDT-32136
        String newQOStr= '[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Removal","occurenceType":"OC","duration":"TEMP","productType":"Removal","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"'+Date.today()+'","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP","contact":"Test","phone":"7890654321" , "bypassWorkOrder":false},{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Removal","occurenceType":"OC","duration":"TEMP","productType":"Removal","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"'+Date.today()+'","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP","contact":"Test","phone":"7890654321" , "bypassWorkOrder":false},{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Removal","occurenceType":"OC","duration":"TEMP","productType":"Removal","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"'+Date.today()+'","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP","contact":"Test","phone":"7890654321" , "bypassWorkOrder":true}]';
        WorkOrderController.AssetAvailabilityWrapper aavWrap = new WorkOrderController.AssetAvailabilityWrapper();
        aavWrap.assetAvailability = false;
        Test.startTest();
            String str= WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c),quoteLine[0].SBQQ__StartDate__c,quoteLine[0].SBQQ__EndDate__c,quoteLine[0].Vendor_Commit_Date__c, newQOStr,aavWrap);// aavWrap: asset availability //SDT-32136
        Test.stopTest();
        System.assert(str.contains('Error:'), 'Validation doesnt throw properly.');
    }
    @isTest
    static void validateAction_newQO_Mul_PCK_Test(){
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c limit 1];
        List<SBQQ__QuoteLine__c> quoteLine= [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c,SBQQ__EndDate__c,Vendor_Commit_Date__c,IsExtraPickup__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null AND SBQQ__ProductName__c='Pickup'];
        String newQOStr= '[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Pickup","occurenceType":"OC","duration":"TEMP","productType":"Pickup","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"'+Date.today()+'","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP","contact":"Test","phone":"7890654321" , "bypassWorkOrder":false},{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Pickup","occurenceType":"OC","duration":"TEMP","productType":"Pickup","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"'+Date.today()+'","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP","contact":"Test","phone":"7890654321" , "bypassWorkOrder":false},{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Pickup","occurenceType":"OC","duration":"TEMP","productType":"Pickup","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"'+Date.today()+'","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP","contact":"Test","phone":"7890654321", "bypassWorkOrder":true}]';
        WorkOrderController.AssetAvailabilityWrapper aavWrap = new WorkOrderController.AssetAvailabilityWrapper();
        aavWrap.assetAvailability = false;
        Test.startTest();
            String str= WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c),quoteLine[0].SBQQ__StartDate__c,quoteLine[0].SBQQ__EndDate__c,quoteLine[0].Vendor_Commit_Date__c, newQOStr,aavWrap);// aavWrap: asset availability //SDT-32136
        Test.stopTest();   
        System.assert(str.contains('Error:'), 'Validation doesnt throw properly.');
    }
    //Changes related to SDT-38985
    @isTest
    static void saveAction_newQOFail_Test(){
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c limit 1];
        //Changes related to SDT-38985
        List<SBQQ__QuoteLine__c> lockDeliveryquoteLine= [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c,SBQQ__EndDate__c,Vendor_Commit_Date__c,IsExtraPickup__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null AND SBQQ__ProductName__c = 'Keys'];
        List<Quote_Order__c> qoObjLisForLockDelivery = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Lock Delivery'];        
        List<Quote_Order__c> qoObjList = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Delivery' limit 1];
        //Changes related to SDT-38985
        String newQOStr= '[{"actionType":"newQuote","quoteLineParentId":"'+lockDeliveryquoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Lock Delivery","occurenceType":"OC","duration":"PERM","productType":"Pickup","quoteLineId":"'+lockDeliveryquoteLine[0].Id+'","serviceDate":"'+Date.today()+'","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP","contact":"Test","phone":"7890654321" , "bypassWorkOrder": true}]';
        WorkOrderController.AssetAvailabilityWrapper aavWrap = new WorkOrderController.AssetAvailabilityWrapper();
        aavWrap.assetAvailability = false;
        Test.startTest();
            String str= WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(lockDeliveryquoteLine[0].SBQQ__RequiredBy__c),lockDeliveryquoteLine[0].SBQQ__StartDate__c,lockDeliveryquoteLine[0].SBQQ__EndDate__c,lockDeliveryquoteLine[0].Vendor_Commit_Date__c, newQOStr,aavWrap); // aavWrap: asset availability //SDT-32136
        Test.stopTest();
        System.assert(str.contains('Lock Delivery Order already exist'));
    }
    /*public static SBQQ__QuoteLine__c parentQl;
    @testSetup static void createData() {
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(); 
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__Status__c = 'Draft';
        quote.PO_Mandatory__c= 'NS_TEMP;NS_PERM;PCK_ER;PCK_EXPCK;PCK_OC';
        insert quote;
        
        List<Product2> prodList= new List<Product2>();
        Product2 prod = new Product2(Name = 'Delivery', Bypass_Acorn_Integration__c = false);
        Product2 prod1 = new Product2(Name = 'Pickup', Bypass_Acorn_Integration__c = false);
        Product2 prod2 = new Product2(Name = 'Removal', Bypass_Acorn_Integration__c = false);
        Product2 prod3 = new Product2(Name = 'Extra Pickup', Bypass_Acorn_Integration__c = false);
        prodList.add(prod);
        prodList.add(prod1);
        prodList.add(prod2);
        prodList.add(prod3);
        insert prodList;
        
        PricebookEntry pbe = new Pricebookentry(Product2Id = prod.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
        insert pbe;
        
        parentQl = new SBQQ__QuoteLine__c();
        parentQl.SBQQ__Quote__c =  quote.Id;
        parentQl.SBQQ__Product__c = prod.Id;
        parentQl.IsExtraPickup__c = true;
        parentQl.Duration__c = 'PERM';
        parentQl.Occurrence_Type__c= 'OC';
        parentQl.LocationPositionName__c = 'Test';
        List<SBQQ__QuoteLine__c> qlList= new List<SBQQ__QuoteLine__c>();
        qlList.add(parentQl);
        
        
        //insert ql;
        
        system.debug(parentQl);
        SBQQ__QuoteLine__c qlChild = new SBQQ__QuoteLine__c();
        qlChild.SBQQ__Quote__c =  quote.Id;
        qlChild.SBQQ__Product__c = prod.Id;
        qlChild.Duration__c = 'PERM';
        qlChild.IsExtraPickup__c = true;
        qlChild.Occurrence_Type__c= 'OC';
        qlChild.SBQQ__StartDate__c= Date.newInstance(2020, 13, 5);
        qlChild.SBQQ__EndDate__c= Date.newInstance(2020, 30, 5);
        qlList.add(qlChild);
        SBQQ__QuoteLine__c qlChild1 = new SBQQ__QuoteLine__c();
        qlChild1.SBQQ__Quote__c =  quote.Id;
        qlChild1.SBQQ__Product__c = prod1.Id;
        qlChild1.Duration__c = 'PERM';
        qlChild1.IsExtraPickup__c = true;
        qlChild1.Occurrence_Type__c= 'SCH';
        qlChild1.SBQQ__StartDate__c= Date.newInstance(2020, 13, 5);
        qlChild1.SBQQ__EndDate__c= Date.newInstance(2020, 30, 5);
        qlList.add(qlChild1);
        SBQQ__QuoteLine__c qlChild2 = new SBQQ__QuoteLine__c();
        qlChild2.SBQQ__Quote__c =  quote.Id;
        qlChild2.SBQQ__Product__c = prod2.Id;
        qlChild2.Duration__c = 'PERM';
        qlChild2.IsExtraPickup__c = true;
        qlChild2.Occurrence_Type__c= 'SCH';
        qlChild2.SBQQ__StartDate__c= Date.newInstance(2020, 13, 5);
        qlChild2.SBQQ__EndDate__c= Date.newInstance(2020, 30, 5);
        qlList.add(qlChild2);
        SBQQ__QuoteLine__c qlChild3 = new SBQQ__QuoteLine__c();
        qlChild3.SBQQ__Quote__c =  quote.Id;
        qlChild3.SBQQ__Product__c = prod3.Id;
        qlChild3.Duration__c = 'PERM';
        qlChild3.IsExtraPickup__c = true;
        qlChild3.Occurrence_Type__c= 'SCH';
        qlChild3.SBQQ__StartDate__c= Date.newInstance(2020, 13, 5);
        qlChild3.SBQQ__EndDate__c= Date.newInstance(2020, 30, 5);
        qlList.add(qlChild3);
        insert qlList;
        qlChild.SBQQ__RequiredBy__c = parentQl.Id;
        qlChild1.SBQQ__RequiredBy__c = parentQl.Id;
        qlChild2.SBQQ__RequiredBy__c = parentQl.Id;
        qlChild3.SBQQ__RequiredBy__c = parentQl.Id;
        List<SBQQ__QuoteLine__c> qlChildList= new List<SBQQ__QuoteLine__c>();
        qlChildList.add(qlChild);
        qlChildList.add(qlChild1);
        qlChildList.add(qlChild2);
        qlChildList.add(qlChild3);
        Database.update(qlChildList,false);
        
        system.debug(qlChild);
        system.debug(qlList);
        Quote_Order__c qo = new Quote_Order__c();
        qo.Quote_Line__c= parentQl.id;
        qo.Service_Quote_Line__c= qlChild.id;
        qo.Service_Type__c='Delivery';
        qo.Product_Type__c='Delivery';
        qo.Service_Date__c= Date.newInstance(2020, 13, 5);
        qo.Instructions__c= 'test1234';
        qo.Onsite_Contact__c = 'test';
        qo.Onsite_Contact_Phone__c = '9999999';
        qo.Cust_Ref_Number__c='test12345';
        qo.Duration__c='PERM';
        qo.Occurrence_Type__c='OC';
        qo.Quantity__c = 20;
        qo.Service_Time_Span__c= 'ASAP';
        
        insert qo;
        
        system.debug(qo);
        
        Quote_Order__c qo1 = new Quote_Order__c();
        qo1.Quote_Line__c= parentQl.id;
        qo1.Service_Quote_Line__c= qlChild1.id;
        qo1.Service_Type__c='Pickup';
        qo1.Product_Type__c='Pickup';
        qo1.Service_Date__c= Date.newInstance(2020, 13, 5);
        qo1.Instructions__c= 'test1234';
        qo1.Cust_Ref_Number__c='test12345';
        qo1.Duration__c='PERM';
        qo1.Occurrence_Type__c='OC';
        qo1.Onsite_Contact__c = 'test';
        qo1.Onsite_Contact_Phone__c = '9999999';
        qo1.Quantity__c = 20;
        qo1.Service_Time_Span__c= 'ASAP';
        insert qo1;
        
        system.debug(qo1);
        
        Quote_Order__c qo2 = new Quote_Order__c();
        qo2.Quote_Line__c= parentQl.id;
        qo2.Service_Quote_Line__c= qlChild1.id;
        qo2.Service_Type__c='Removal';
        qo2.Product_Type__c='Removal';
        qo2.Service_Date__c= Date.newInstance(2020, 13, 5);
        qo2.Instructions__c= 'test1234';
        qo2.Cust_Ref_Number__c='test12345';
        qo2.Duration__c='PERM';
        qo2.Occurrence_Type__c='OC';
        qo2.Quantity__c = 20;
        qo2.Service_Time_Span__c= 'ASAP';
        qo2.Onsite_Contact__c = 'test';
        qo2.Onsite_Contact_Phone__c = '9999999';
        insert qo2;
        
        system.debug(qo2);
        
        Quote_Order__c qo3 = new Quote_Order__c();
        qo3.Quote_Line__c= parentQl.id;
        qo3.Service_Quote_Line__c= qlChild1.id;
        qo3.Service_Type__c='Extra Pickup';
        qo3.Product_Type__c='Extra Pickup';
        
        qo3.Service_Date__c= Date.newInstance(2020, 13, 5);
        qo3.Instructions__c= 'test1234';
        qo3.Cust_Ref_Number__c='test12345';
        qo3.Duration__c='PERM';
        qo3.Occurrence_Type__c='OC';
        qo3.Quantity__c = 20;
        qo3.Service_Time_Span__c= 'ASAP';
        qo3.Onsite_Contact__c = 'test';
        qo3.Onsite_Contact_Phone__c = '9999999';
        insert qo3;
        
        system.debug(qo3);
        
        List<Quote_Order__c> qoList = new List<Quote_Order__c>();
        qoList.add(qo);
        qoList.add(qo1);
        qoList.add(qo2);
        qoList.add(qo3);
        Database.update(qoList,false);
    } 
    static testMethod void testDoPost(){
        createData();
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c limit 1];
        List<SBQQ__QuoteLine__c> quoteLine= [Select Id,SBQQ__RequiredBy__c,IsExtraPickup__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null];
        List<Quote_Order__c> qoObjList = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Pickup' limit 1];
        
        Test.startTest();
        String serviceTypeList= '["Pickup"]';
        String selectedProd;
        Date startDate;
        String locPos;
        Boolean isDelivery;
        System.debug('>>>>>>>>>'+serviceTypeList);
        if(quoteLine.size()>0){
        String quoteOrderString= '[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Delivery","occurenceType":"OC","duration":"PERM","productType":"Delivery","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"2021-05-13","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"}]';
        String quoteOrderString1= '[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[1].SBQQ__RequiredBy__c+'","serviceType":"Pickup","occurenceType":"OC","duration":"PERM","productType":"Haul","quoteLineId":"'+quoteLine[1].Id+'","serviceDate":"2021-05-13","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"},{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[1].SBQQ__RequiredBy__c+'","serviceType":"Pickup","occurenceType":"OC","duration":"PERM","productType":"Haul","quoteLineId":"'+quoteLine[1].Id+'","serviceDate":"2021-05-13","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"},{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[1].SBQQ__RequiredBy__c+'","serviceType":"Pickup","occurenceType":"OC","duration":"PERM","productType":"Haul","quoteLineId":"'+quoteLine[1].Id+'","serviceDate":"2021-05-11","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"}]';
        String quoteOrderString2= '[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[2].SBQQ__RequiredBy__c+'","serviceType":"Removal","occurenceType":"OC","duration":"PERM","productType":"Haul","quoteLineId":"'+quoteLine[2].Id+'","serviceDate":"2021-05-15","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"},{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[2].SBQQ__RequiredBy__c+'","serviceType":"Removal","occurenceType":"OC","duration":"PERM","productType":"Haul","quoteLineId":"'+quoteLine[2].Id+'","serviceDate":"2021-05-11","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"}]';
        String quoteOrderString3= '[{"idField":"'+qoObjList[0].id+'","actionType":"changed","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Delivery","occurenceType":"OC","duration":"PERM","productType":"Delivery","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"2021-05-13","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"}]';
        String quoteOrderString4='[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[1].SBQQ__RequiredBy__c+'","serviceType":"Pickup","occurenceType":"OC","duration":"PERM","productType":"Haul","quoteLineId":"'+quoteLine[1].Id+'","serviceDate":"2021-05-25","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"}]';
        String quoteOrderString5='[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[2].SBQQ__RequiredBy__c+'","serviceType":"Removal","occurenceType":"OC","duration":"PERM","productType":"Haul","quoteLineId":"'+quoteLine[2].Id+'","serviceDate":"2021-05-11","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"}]';
        
        WorkOrderController.getQuoteLineParentProductsNew(String.valueOf(parentQl.id));
        WorkOrderController.getQuoteOrdersByQuoteLine(String.valueOf(quoteLine[0].SBQQ__RequiredBy__c));
        WorkOrderController.validateQuoteOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c),qoObjList);
        WorkOrderController.quoteLineFeatureProductOptionsNew(String.valueOf(quote.id), String.valueOf(quoteLine[0].SBQQ__RequiredBy__c), String.valueOf(serviceTypeList));
        WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c), quoteOrderString);
        WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[1].SBQQ__RequiredBy__c), quoteOrderString1); //upsert successfully
        WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[2].SBQQ__RequiredBy__c), quoteOrderString2); //upsert successfully
        WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c), quoteOrderString3);
        WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[1].SBQQ__RequiredBy__c), quoteOrderString4); //upsert successfully
        WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[2].SBQQ__RequiredBy__c), quoteOrderString5);
        WorkOrderController.deleteQuoteLineOrders(String.valueOf(qoObjList[0].id)); //deleted Successfully.
        Test.stopTest();
       }
        List<Quote_Order__c> qoList = [SELECT Id, IsDeleted FROM Quote_Order__c Order By CreatedDate ASC ALL ROWS];
        System.assertEquals(qoList.size(), qoList.size());
        System.assertEquals(qoList[0].IsDeleted, false);
    }
    
    static testMethod void testDoPostFirst(){
        createData();
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c limit 1];
        List<SBQQ__QuoteLine__c> quoteLine= [Select Id,SBQQ__RequiredBy__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null];
        
        List<Quote_Order__c> qoObjList = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Delivery' and Product_Type__c='Delivery' limit 1];
        
        Test.startTest();
        String serviceTypeList= '["Delivery"]';
        String selectedProd;
        Date startDate;
        String locPos;
        Boolean isDelivery;
        System.debug('>>>>>>>>>'+serviceTypeList);
        if(quoteLine.size()>0){
        String quoteOrderString= '[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Delivery","occurenceType":"OC","duration":"PERM","productType":"Delivery","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"2021-05-13","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"}]';
        String quoteOrderString1= '[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[1].SBQQ__RequiredBy__c+'","serviceType":"Pickup","occurenceType":"OC","duration":"PERM","productType":"Haul","quoteLineId":"'+quoteLine[1].Id+'","serviceDate":"2021-05-13","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"},{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[1].SBQQ__RequiredBy__c+'","serviceType":"Pickup","occurenceType":"OC","duration":"PERM","productType":"Haul","quoteLineId":"'+quoteLine[1].Id+'","serviceDate":"2021-05-13","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"},{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[1].SBQQ__RequiredBy__c+'","serviceType":"Pickup","occurenceType":"OC","duration":"PERM","productType":"Haul","quoteLineId":"'+quoteLine[1].Id+'","serviceDate":"2021-05-11","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"}]';
        String quoteOrderString2= '[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[2].SBQQ__RequiredBy__c+'","serviceType":"Removal","occurenceType":"OC","duration":"PERM","productType":"Haul","quoteLineId":"'+quoteLine[2].Id+'","serviceDate":"2021-05-15","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"},{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[2].SBQQ__RequiredBy__c+'","serviceType":"Removal","occurenceType":"OC","duration":"PERM","productType":"Haul","quoteLineId":"'+quoteLine[2].Id+'","serviceDate":"2021-05-11","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"}]';
        String quoteOrderString3= '[{"idField":"'+qoObjList[0].id+'","actionType":"changed","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Delivery","occurenceType":"OC","duration":"PERM","productType":"Delivery","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"2021-05-13","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"}]';
        String quoteOrderString4='[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[1].SBQQ__RequiredBy__c+'","serviceType":"Pickup","occurenceType":"OC","duration":"PERM","productType":"Haul","quoteLineId":"'+quoteLine[1].Id+'","serviceDate":"2021-05-25","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"}]';
        String quoteOrderString5='[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[2].SBQQ__RequiredBy__c+'","serviceType":"Removal","occurenceType":"OC","duration":"PERM","productType":"Haul","quoteLineId":"'+quoteLine[2].Id+'","serviceDate":"2021-05-11","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"}]';
        
        WorkOrderController.getQuoteLineParentProductsNew(String.valueOf(parentQl.id));
        WorkOrderController.getQuoteOrdersByQuoteLine(String.valueOf(quoteLine[0].SBQQ__RequiredBy__c));
        WorkOrderController.validateQuoteOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c),qoObjList);
        WorkOrderController.quoteLineFeatureProductOptionsNew(String.valueOf(quote.id), String.valueOf(quoteLine[0].SBQQ__RequiredBy__c), String.valueOf(serviceTypeList));
        WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c), quoteOrderString);
        WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[1].SBQQ__RequiredBy__c), quoteOrderString1); //upsert successfully
        WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[2].SBQQ__RequiredBy__c), quoteOrderString2); //upsert successfully
        WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c), quoteOrderString3);
        WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[1].SBQQ__RequiredBy__c), quoteOrderString4); //upsert successfully
        WorkOrderController.actionsOnQuoteLineOrders(String.valueOf(quote.id),String.valueOf(quoteLine[2].SBQQ__RequiredBy__c), quoteOrderString5);
        WorkOrderController.deleteQuoteLineOrders(String.valueOf(qoObjList[0].id)); //deleted Successfully.
        
        Test.stopTest();
        }
        List<Quote_Order__c> qoList = [SELECT Id, IsDeleted FROM Quote_Order__c Order By CreatedDate ASC ALL ROWS];
        System.assertEquals(qoList.size(), qoList.size());
        //System.assertEquals(qoList[0].IsDeleted, true);
    } 
    
    static testMethod void testDoPostSecond(){
        createData();
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c limit 1];
        List<SBQQ__QuoteLine__c> quoteLine= [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null limit 1];
        if(quoteLine.size()>0){
        quoteLine[0].SBQQ__StartDate__c= null;
        quoteLine[0].IsExtraPickup__c = false;
        quoteLine[0].Duration__c = 'TEMP';
        quoteLine[0].Occurrence_Type__c= 'OC';
        quoteLine[0].LocationPositionName__c = null;
        
        List<Quote_Order__c> qoObjList = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Delivery' and Product_Type__c='Delivery' limit 1];
        qoObjList[0].Onsite_Contact__c = 'test';
        qoObjList[0].Onsite_Contact_Phone__c = '9999999';
        qoObjList[0].Cust_Ref_Number__c ='999';
        Database.update(qoObjList,false);
        
        
        Test.startTest();
        String serviceTypeList= '["Delivery"]';
        String selectedProd;
        Date startDate;
        String locPos;
        Boolean isDelivery;
        System.debug('>>>>>>>>>'+serviceTypeList);
        String quoteOrderString= '[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Delivery","occurenceType":"OC","duration":"PERM","productType":"Delivery","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"2021-05-13","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"}]';
        
        WorkOrderController.validateQuoteOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c),qoObjList);
        
        Test.stopTest();
        }
        List<Quote_Order__c> qoList = [SELECT Id, IsDeleted FROM Quote_Order__c Order By CreatedDate ASC ALL ROWS];
        System.assertEquals(8, qoList.size());
        System.assertEquals(qoList[0].IsDeleted, false);
    } 
    
    static testMethod void testDoPostthird(){
        createData();
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c limit 1];
        List<SBQQ__QuoteLine__c> quoteLine= [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null limit 1];
        if(quoteLine.size()>0){
        quoteLine[0].SBQQ__StartDate__c= null;
        quoteLine[0].IsExtraPickup__c = false;
        quoteLine[0].Duration__c = 'PERM';
        quoteLine[0].Occurrence_Type__c= 'OC';
        quoteLine[0].LocationPositionName__c = null;
        
        List<Quote_Order__c> qoObjList = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Pickup' and Product_Type__c='Pickup' limit 1];
        qoObjList[0].Onsite_Contact__c = 'test';
        qoObjList[0].Onsite_Contact_Phone__c = '9999999';
        qoObjList[0].Cust_Ref_Number__c ='999';
        Database.update(qoObjList,false);
        
        Test.startTest();
        String serviceTypeList= '["Pickup"]';
        String selectedProd;
        Date startDate;
        String locPos;
        Boolean isDelivery;
        System.debug('>>>>>>>>>'+serviceTypeList);
        
        WorkOrderController.validateQuoteOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c),qoObjList);
        
        Test.stopTest();
        }
        List<Quote_Order__c> qoList = [SELECT Id, IsDeleted FROM Quote_Order__c Order By CreatedDate ASC ALL ROWS];
        System.assertEquals(8, qoList.size());
        System.assertEquals(qoList[0].IsDeleted, false);
    } 
    
    static testMethod void testDoPostfourth(){
        createData();
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c limit 1];
        
        List<SBQQ__QuoteLine__c> quoteLine= [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null limit 1];
        if(quoteLine.size()>0){
        quoteLine[0].SBQQ__StartDate__c= null;
        quoteLine[0].IsExtraPickup__c = false;
        quoteLine[0].Duration__c = 'PERM';
        quoteLine[0].Occurrence_Type__c= 'OC';
        quoteLine[0].LocationPositionName__c = null;
       
        
        List<Quote_Order__c> qoObjList = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Pickup' and Product_Type__c='Pickup' limit 1];
        qoObjList[0].Onsite_Contact__c = 'test';
        qoObjList[0].Onsite_Contact_Phone__c = '9999999';
        qoObjList[0].Cust_Ref_Number__c ='999';
        Database.update(qoObjList,false);
        
        Test.startTest();
        String serviceTypeList= '["Pickup"]';
        String selectedProd;
        Date startDate;
        String locPos;
        Boolean isDelivery;
        System.debug('>>>>>>>>>'+serviceTypeList);
        
        WorkOrderController.validateQuoteOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c),qoObjList);
        
        Test.stopTest();
        }
        List<Quote_Order__c> qoList = [SELECT Id, IsDeleted FROM Quote_Order__c Order By CreatedDate ASC ALL ROWS];
        System.assertEquals(8, qoList.size());
        System.assertEquals(qoList[0].IsDeleted, false);
    } 
    
     static testMethod void testDoPostfifth(){
        createData();
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c limit 1];
        
        List<SBQQ__QuoteLine__c> quoteLine= [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null limit 1];
         if(quoteLine.size()>0){
        quoteLine[0].SBQQ__StartDate__c= null;
        quoteLine[0].IsExtraPickup__c = false;
        quoteLine[0].Duration__c = 'TEMP';
        quoteLine[0].Occurrence_Type__c= 'OC';
        quoteLine[0].LocationPositionName__c = null;
      
         
        
        List<Quote_Order__c> qoObjList = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Pickup' and Product_Type__c='Pickup' limit 1];
        qoObjList[0].Onsite_Contact__c = 'test';
        qoObjList[0].Onsite_Contact_Phone__c = '9999999';
        qoObjList[0].Cust_Ref_Number__c ='999';
        Database.update(qoObjList,false);
         
        Test.startTest();
        String serviceTypeList= '["Pickup"]';
        String selectedProd;
        Date startDate;
        String locPos;
        Boolean isDelivery;
        System.debug('>>>>>>>>>'+serviceTypeList);
         
        WorkOrderController.getQuoteLineParentProductsNew(String.valueOf(quoteLine[0].id));
        WorkOrderController.validateQuoteOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c),qoObjList);
        
        Test.stopTest();
        } 
        List<Quote_Order__c> qoList = [SELECT Id, IsDeleted FROM Quote_Order__c Order By CreatedDate ASC ALL ROWS];
        System.assertEquals(8, qoList.size());
        System.assertEquals(qoList[0].IsDeleted, false);
    }
    
    static testMethod void testDoPostSixth(){
        createData();
        SBQQ__Quote__c quote = [Select Id From SBQQ__Quote__c limit 1];
        List<SBQQ__QuoteLine__c> quoteLine= [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c From SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c!= null limit 1];

        List<Quote_Order__c> qoObjList = [Select id,Service_Quote_Line__c,Service_Type__c,Service_Date__c From Quote_Order__c where Service_Type__c='Delivery' and Product_Type__c='Delivery' limit 1];
 
        Test.startTest();
        String serviceTypeList= '["Delivery"]';
        String selectedProd;
        Date startDate;
        String locPos;
        Boolean isDelivery;
        System.debug('>>>>>>>>>'+serviceTypeList);
        if(quoteLine.size()>0){
        String quoteOrderString= '[{"actionType":"newQuote","quoteLineParentId":"'+quoteLine[0].SBQQ__RequiredBy__c+'","serviceType":"Delivery","occurenceType":"OC","duration":"PERM","productType":"Delivery","quoteLineId":"'+quoteLine[0].Id+'","serviceDate":"2021-05-13","instruction":"fsdf","custRefNumber":"csdv","serviceTime":"ASAP"}]';
        
        WorkOrderController.validateQuoteOrders(String.valueOf(quote.id),String.valueOf(quoteLine[0].SBQQ__RequiredBy__c),qoObjList);
        
        Test.stopTest();
        }
        List<Quote_Order__c> qoList = [SELECT Id, IsDeleted FROM Quote_Order__c Order By CreatedDate ASC ALL ROWS];
        System.assertEquals(8, qoList.size());
        System.assertEquals(qoList[0].IsDeleted, false);
    } */
}