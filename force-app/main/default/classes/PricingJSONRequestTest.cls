@isTest
public class PricingJSONRequestTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string ON_CALL = 'On-Call';
    private static final string TRASH = 'Trash';
    private static final string ROLLOFF = 'Rolloff';
    @testSetup static void createData() {
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr); 
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
         System.runAs(usr){
        list<Account> acclist = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> oppList2 = new List<Opportunity>();
        List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quoteList2= new List<SBQQ__Quote__c>();
        List<Product2> prdList = new List<Product2>(); 
        
        Account accParent = new Account(Name = 'Parent Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='5678',
                                        RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true); 
        insert accParent;
        
        Account acc = new Account(Name = Constant_Util.KEYWORD_TEST, phone = '9999999999', OwnerId = usr.id, AccountNumber='1234',
                                  RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, ParentId = accParent.Id, Type ='Location');
        acclist.add(acc);
        
        Account vendorAcc = new Account(Name = 'WM Vendor Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='4321',
                                        RecordTypeid = TestDataFactory.getRecordType('Vendor','Account'));
        acclist.add(vendorAcc);
        
        Database.insert(acclist);
        list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
        locationlist[0].tz__Timezone_SFDC__c = 'America/Chicago';
        locationlist[0].IsPricingEligible__c = true;
        Database.insert(locationlist);
        
        list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
        Database.insert(conlist);
        
        List<Case> caseList = new List<Case>();
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
        caseList.add(newServiceCase);
        //Database.insert(newServiceCase);
             
        Case newModifyCase = TestDataFactory.newModifyExistingCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0),usr,locationlist.get(0)); 
        newModifyCase.Service_Date__c = system.today() + 1;
        newModifyCase.SLA_Service_Date_Time__c = system.today() + 2;
        //newModifyCase.Case_Type__c = 'New Service'; commented for SDT-37527
        newModifyCase.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Modify Existing Service Case'].Id;  
        //newModifyCase.Case_Sub_Type__c = 'Permanent'; commented for SDT-37527
        newModifyCase.Case_Type__c = 'Change Service'; //added for SDT-37527
        newModifyCase.Case_Sub_Type__c = 'Increase'; //added for SDT-37527
       // newModifyCase.Case_Reason__c = 'Existing Location';commented for SDT-37527
       newModifyCase.Case_Reason__c = 'Size'; // added for SDT-37527
        newModifyCase.LOB__c = 'Rolloff';
        newModifyCase.Status = 'Open';
        newModifyCase.Service_Occurrence_Type_Code__c = ON_CALL;
        newModifyCase.Material_Type__c = TRASH;
        caseList.add(newModifyCase);
        Database.insert(caseList);
        
        
        
        oppList.addAll(TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, caseList[0].Location__c));
        //insert oppList;
        System.Debug('@@@~Create Opp : ' + oppList);
             
        oppList.addAll(TestDataFactory.createOpportunity(2,'TestOpportunityTest2',caseList[1].Id,/*newModifyCase.Case_Sub_Type__c*/ 'Permanent', caseList[1].Location__c));
        insert oppList;
        System.Debug('@@@~Create Opp : ' + oppList);
        
        
        
        quoteList.addAll(TestDataFactory.createQuoteRecords(new List<Opportunity>{oppList[0]},acclist[0],conlist[0],Date.today(),false,true));
        quoteList[0].SBQQ__ShippingStreet__c = 'ABC';
        quoteList[0].SBQQ__ShippingCity__c = 'Test1';
        quoteList[0].SBQQ__ShippingCountry__c = 'USA';
        quoteList[0].SBQQ__ShippingState__c = 'NY';
        quoteList[0].SBQQ__ShippingPostalCode__c = '1234';
        quoteList[0].Duration__c = 'Permanent';
        //insert quoteList;
        system.debug('Quote ' +quoteList);
             
        quoteList.addAll(TestDataFactory.createQuoteRecords(new List<Opportunity>{oppList[1]},acclist[0],conlist[0],Date.today(),false,true));
        quoteList[1].SBQQ__ShippingStreet__c = 'ABC';
        quoteList[1].SBQQ__ShippingCity__c = 'Test123';
        quoteList[1].SBQQ__ShippingCountry__c = 'USA';
        quoteList[1].SBQQ__ShippingState__c = 'NY';
        quoteList[1].SBQQ__ShippingPostalCode__c = '1234';
        quoteList[1].Duration__c = 'Permanent';
        insert quoteList;
        system.debug('Quote ' +quoteList);

        Product2 prodOpenTop = TestDataFactory.createProduct('Open Top','ROLLOFF', 'OT');
        prodOpenTop.Is_Pricing_Eligible__c = true;
        prdList.add(prodOpenTop);
        Product2 prodDelivery= TestDataFactory.createProduct('Delivery','Surcharges and Fees','DLV');
        prdList.add(prodDelivery);
        
        Product2 prodWasteCategory= TestDataFactory.createProduct('Cardboard','Waste Category','CARDBOARD');
        prdList.add(prodWasteCategory);
        Database.insert(prdList);
        
        List<Asset> assetlist = TestDataFactory.createAsset('8 yrd Dumpster', acclist.get(0), conlist.get(0), prdList.get(0), usr, locationlist.get(0));
            Database.insert(assetlist);
        
        List<SBQQ__QuoteLine__c> qlHdr = new List<SBQQ__QuoteLine__c>();
        //Bundle 1 - Open Top
        SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
        qlOT.SBQQ__Bundle__c = TRUE;
        qlOT.SBQQ__RequiredBy__c = null;
        qlOT.Vendor__c = vendorAcc.Id;
        qlOT.AssetId__c = assetlist[0].Id;
        qlOT.SBQQ__Number__c = 1;
        //SDT 41134
        qlOT.Vendor_Commit_Date__c = Date.today();
        //qlOT.Location_Position_Name__c = accLocPosition.Id;
        qlHdr.add(qlOT);
        
        insert qlHdr;
        
        List<SBQQ__QuoteLine__c> qlChild = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qlDelivery = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDelivery,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
        qlDelivery.SBQQ__RequiredBy__c = qlOT.Id;
        qlDelivery.SBQQ__Number__c = 5;
        qlDelivery.AssetId__c = assetlist[0].Id;
        //qlDelivery.Vendor__c = vendorAcc.Id;
        qlChild.add(qlDelivery);
        //Open Top Child Quote Line  --- End
        
        SBQQ__QuoteLine__c q2Delivery = TestDataFactory.createQuoteLineRecords(quoteList[0],prodWasteCategory,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
        q2Delivery.SBQQ__RequiredBy__c = qlOT.Id;
        q2Delivery.SBQQ__Number__c = 5;
        q2Delivery.MaterialGrade__c = 'Waxed OCC';
        q2Delivery.AssetId__c = assetlist[0].Id;
        //qlDelivery.Vendor__c = vendorAcc.Id;
        qlChild.add(q2Delivery);
        //Open Top Child Quote Line  --- End
        
        Database.insert(qlChild); 
        
        
        
        List<SBQQ__QuoteLine__c> qlHdr2 = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qlOT2 = TestDataFactory.createQuoteLineRecords(quoteList[1],prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
        qlOT2.SBQQ__Bundle__c = TRUE;
        qlOT2.SBQQ__RequiredBy__c = null;
        qlOT2.AssetId__c = assetlist[0].Id;
        qlOT2.Vendor__c = vendorAcc.Id;
        qlOT2.SBQQ__Number__c = 1;
        //qlOT.Location_Position_Name__c = accLocPosition.Id;
        qlHdr2.add(qlOT2);
        
        insert qlHdr2;
        
        List<SBQQ__QuoteLine__c> q2Child = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c q4Delivery = TestDataFactory.createQuoteLineRecords(quoteList[1],prodDelivery,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
        q4Delivery.SBQQ__RequiredBy__c = qlOT2.Id;
        q4Delivery.SBQQ__Number__c = 5;
        q4Delivery.AssetId__c = assetlist[0].Id;
        q4Delivery.MaterialGrade__c = 'Waxed OCC';
        //qlDelivery.Vendor__c = vendorAcc.Id;
        q2Child.add(q4Delivery);
        
        
        SBQQ__QuoteLine__c q3Delivery = TestDataFactory.createQuoteLineRecords(quoteList[1],prodWasteCategory,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
        q3Delivery.SBQQ__RequiredBy__c = qlOT2.Id;
        q3Delivery.SBQQ__Number__c = 5;
        q3Delivery.AssetId__c = assetlist[0].Id;
        //qlDelivery.Vendor__c = vendorAcc.Id;
        q2Child.add(q3Delivery);
        
        // List<SBQQ__QuoteLine__c> q2Child = new List<SBQQ__QuoteLine__c>();
        
        
        Database.insert(q2Child); 

        Quote_Order__c qo = new Quote_Order__c();
        qo.Quote_Line__c= qlOT.id;
        qo.Service_Quote_Line__c= qlDelivery.id;
        qo.Service_Type__c='Delivery';
        qo.Product_Type__c='Delivery';
        qo.Service_Date__c= Date.newInstance(2020, 13, 5);
        qo.Instructions__c= 'test1234';
        qo.Cust_Ref_Number__c='test12345';
        qo.Duration__c='PERM';
        qo.Occurrence_Type__c='OC';
        qo.Quantity__c = 20;
        insert qo;  
         }
    } 
    static testMethod void testDoPost(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/ProcessQuoteLine?';  
        req.httpMethod = 'POST';
        List<SBQQ__Quote__c> quoteList = [Select Id, Name From SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id, Name From SBQQ__QuoteLine__c];
        //String body = '{"Quote": {"RequestedBy": "Test","QuoteId": "'+quoteList[0].Name+'","Status": "Failure","QuotLines": [{"QuoteLineId": "'+quoteLineList[0].Name+'","Status": "Failue","Errors": [{"ErrorType": "data","ErrorMessage": "Test error"},{"ErrorType": "data","ErrorMessage": "Invalid data"}]},{"QuoteLineId": "QL-002","Status": "Success/Failue","Error": [{"ErrorType": "","ErrorMessage": ""}]}]}}';
        String body = '{"Quote":{ "QuoteId": "'+quoteList[0].Name+'", "RequestedBy": "system.user", "Status": "Failure", "QuoteError":{ "Type": "Validation Error", "Message": "Arvind - Exception Reason code is required"}, "QuoteLines":[{ "SFQuoteLineKey": "'+quoteLineList[0].Name+'", "Errors":[{ "Type": "Validation Error", "Message": "Jatan - Exception Reason code is required"},{ "Type": "Validation Error", "Message": "Exception type is required"},{ "Type": "Validation Error", "Message": "Exception effective date is required"}]}], "Type": "Asset"}}';
        req.requestBody = Blob.valueof(body);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Quotelineservice.updateStatus();
        //system.assert([Select Id From Task where WhatID in : quoteLineList].size() >0);
        Test.stopTest();
    }
    
    // success response test case
    static testMethod void testDoPostSuccessResponseForAsset(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/ProcessQuoteLine?';  
        req.httpMethod = 'POST';
        List<SBQQ__Quote__c> quoteList = [Select Id, Name From SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id, Name From SBQQ__QuoteLine__c];
        String body = '{"Quote": {"RequestedBy": "Test","QuoteId": "'+quoteList[0].Name+'","Status": "Success","QuoteLines":[],"Type": "Asset"}}';
        req.requestBody = Blob.valueof(body);
        
        RestContext.request = req;
        RestContext.response = res;
        
        
        /*RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = '/services/apexrest/ProcessQuoteLine?';  
        req1.httpMethod = 'POST';
        List<SBQQ__Quote__c> quoteList1 = [Select Id, Name From SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quoteLineList1 = [Select Id, Name From SBQQ__QuoteLine__c];
        String body1 = '{"Quote": {"RequestedBy": "Test","QuoteId": "'+quoteList[0].Name+'","Status": "Success","QuoteLines": [],"Type": "WorkOrder"}}';
        req1.requestBody = Blob.valueof(body1);
        
        RestContext.request = req1;
        RestContext.response = res1;*/
        
        Test.startTest();
        Quotelineservice.updateStatus();
        //system.assert([Select Id From Task where WhatID in : quoteLineList].size() >0);
        Test.stopTest();
    }
    static testMethod void testDoPostSuccessResponseForWO(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/ProcessQuoteLine?';  
        req.httpMethod = 'POST';
        List<SBQQ__Quote__c> quoteList = [Select Id, Name From SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id, Name From SBQQ__QuoteLine__c];
        String body = '{"Quote": {"RequestedBy": "Test","QuoteId": "'+quoteList[0].Name+'","Status": "Success","QuoteLines":[],"Type": "Asset"}}';
        req.requestBody = Blob.valueof(body);
        
        RestContext.request = req;
        RestContext.response = res;
        
        
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = '/services/apexrest/ProcessQuoteLine?';  
        req1.httpMethod = 'POST';
        List<SBQQ__Quote__c> quoteList1 = [Select Id, Name From SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quoteLineList1 = [Select Id, Name From SBQQ__QuoteLine__c];
        //String body1 = '{"Quote": {"RequestedBy": "Test","QuoteId": "'+quoteList[0].Name+'","Status": "Success","QuoteLines": [],"Type": "WorkOrder","WorkOrders":[{"PurchaseOrderNumber": "P1234","WorkOrderNumber": "W4321","ServiceDesc": "Haul","TicketNumber": "T1", "ServiceDate": "2021-07-06T00:00:00"}]}}';
    	String body1 = '{"Quote":{"QuoteId":"'+quoteList[0].Name+'","RequestedBy":"system.user","Status":"Success","QuoteError":{"Type":null,"Message":null},"QuoteLines":[],"Type":"WorkOrder","WorkOrders":[{"WorkOrderNumber":"W21897999","PurchaseOrderNumber":"P16930418","TicketNumber":"T32640205","ServiceDesc":"Disposal","ServiceDate":"2022-06-15T00:00:00","ChildTicketNumber":"T32640205-21957989"},{"WorkOrderNumber":"W21897999","PurchaseOrderNumber":"P16930418","TicketNumber":"T32640205","ServiceDesc":"Landfill Fee","ServiceDate":"2022-06-15T00:00:00","ChildTicketNumber":"T32640205-21957989"},{"WorkOrderNumber":"W21898000","PurchaseOrderNumber":"P16930419","TicketNumber":"T32640203","ServiceDesc":"Delivery","ServiceDate":"2022-04-01T00:00:00","ChildTicketNumber":null},{"WorkOrderNumber":"W21897999","PurchaseOrderNumber":"P16930418","TicketNumber":"T32640205","ServiceDesc":"Haul","ServiceDate":"2022-06-15T00:00:00","ChildTicketNumber":"T32640205-21957989"}]}}';


        req1.requestBody = Blob.valueof(body1);
        
        RestContext.request = req1;
        RestContext.response = res1;
        
        Test.startTest();
        Quotelineservice.updateStatus();
        //system.assert([Select Id From Task where WhatID in : quoteLineList].size() >0);
        Test.stopTest();
    }
    	
        @isTest static void testDoPostSuccessResponseForWO1 (){
            //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
            system.runAs(currentuser){
                Test.startTest();
            Integration_Request_URLs__mdt REASSIGN_TICKET =   [select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c,
                                                         Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt 
                                                         where DeveloperName =:Constant_Util.REASSIGN_TICKET ];
        PricingJSONRequest.assignQueuetoAcornTicket('12345','CS Service Confirmation',REASSIGN_TICKET,IntegrationHandlerUtil.getLoggedInUserAcornId());
                Test.stopTest();
            }
    	}
    
     // success response test case
    static testMethod void testDoPostFailureResponse(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/ProcessQuoteLine?';  
        req.httpMethod = 'POST';
        List<SBQQ__Quote__c> quoteList = [Select Id, Name From SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id, Name From SBQQ__QuoteLine__c];
        String body = '{"Quote": {"RequestedBy": "Test","QuoteId": "'+quoteList[0].Name+'","Status": "Failue","QuotLines": [{"QuoteLineId": "'+quoteLineList[0].Name+'","Status": "Failue","Errors": [{"ErrorType": "data","ErrorMessage": "Test error"},{"ErrorType": "data","ErrorMessage": "Invalid data"}]},{"QuoteLineId": "QL-002","Status": "Success/Failue","Error": [{"ErrorType": "","ErrorMessage": ""}]}],"Type": "Asset"}}';
        req.requestBody = Blob.valueof(body);
        
        RestContext.request = req;
        RestContext.response = res;
        
        
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = '/services/apexrest/ProcessQuoteLine?';  
        req1.httpMethod = 'POST';
        List<SBQQ__Quote__c> quoteList1 = [Select Id, Name From SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quoteLineList1 = [Select Id, Name From SBQQ__QuoteLine__c];
        String body1 = '{"Quote": {"RequestedBy": "Test","QuoteId": "'+quoteList[0].Name+'","Status": "Failue","QuotLines": [{"QuoteLineId": "'+quoteLineList[0].Name+'","Status": "Failue","Errors": [{"ErrorType": "data","ErrorMessage": "Test error"},{"ErrorType": "data","ErrorMessage": "Invalid data"}]},{"QuoteLineId": "QL-002","Status": "Success/Failue","Error": [{"ErrorType": "","ErrorMessage": ""}]}],"Type": "WorkOrder"}}';
        req1.requestBody = Blob.valueof(body1);
        
        RestContext.request = req1;
        RestContext.response = res1;
        
        Test.startTest();
        Quotelineservice.updateStatus();
        //system.assert([Select Id From Task where WhatID in : quoteLineList].size() >0);
        Test.stopTest();
    }
    
    static testMethod void testDoPostFailureResponseForQO(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/ProcessQuoteLine?';  
        req.httpMethod = 'POST';
        List<SBQQ__Quote__c> quoteList = [Select Id, Name From SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id, Name From SBQQ__QuoteLine__c];
        
        String body = '{"Quote": {"RequestedBy": "Test","QuoteId": "'+quoteList[0].Name+'","Status": "Failure","QuoteLines": [{"QuoteLineId": "'+quoteLineList[0].Name+'","Status": "Failue","Errors": [{"ErrorType": "data","ErrorMessage": "Test error"},{"ErrorType": "data","ErrorMessage": "Invalid data"}]},{"QuoteLineId": "QL-002","Status": "Success/Failue","Error": [{"ErrorType": "","ErrorMessage": ""}]}],"Type": "Asset"}}';
        req.requestBody = Blob.valueof(body);
        
        RestContext.request = req;
        RestContext.response = res;
        
        
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = '/services/apexrest/ProcessQuoteLine?';  
        req1.httpMethod = 'POST';
        List<SBQQ__Quote__c> quoteList1 = [Select Id, Name From SBQQ__Quote__c];
        //List<SBQQ__QuoteLine__c> quoteLineList1 = [Select Id, Name From SBQQ__QuoteLine__c];
        List<Quote_Order__c> quoteOrderList= [Select Id, Name From Quote_Order__c];
        String body1 = '{"Quote": {"RequestedBy": "Test","QuoteId": "'+quoteList[0].Name+'","Status": "Failure","QuoteLines": [{"SFQuoteLineKey": "'+quoteOrderList[0].Name+'","Errors": [{"ErrorType": "data","ErrorMessage": "Test error"}]}],"Type": "WorkOrder","WorkOrders":[{"PurchaseOrderNumber": "P1234","WorkOrderNumber": "W4321","ServiceDesc": "Haul","TicketNumber": "T1","ServiceDate": "2021-07-06T00:00:00"}]}}';
        req1.requestBody = Blob.valueof(body1);
        
        RestContext.request = req1;
        RestContext.response = res1;
        
        Test.startTest();
        Quotelineservice.updateStatus();
        //system.assert([Select Id From Task where WhatID in : quoteLineList].size() >0);
        Test.stopTest();
    }
    
    static testMethod void testDoGet(){
        List<Material_type_Material_Grade_mapping__mdt> materialMapping = new List<Material_type_Material_Grade_mapping__mdt>();
        materialMapping = [SELECT Material_Type__c,Material_Grade__c,Material_Grade_Code__c  FROM Material_type_Material_Grade_mapping__mdt WHERE Material_Type__c IN ('Cardboard','Trash') and Material_Grade__c IN ('Waxed OCC','International Trash')];
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        List<SBQQ__Quote__c> quoteList = [Select Id, Name From SBQQ__Quote__c];
       
        req.requestURI = '/services/apexrest/ProcessQuoteLine?QuoteName='+quoteList[0].Name;  
        req.httpMethod = 'GET';
        req.addParameter('QuoteName',quoteList[0].Name);// = Blob.valueof('{"QuoteName" : '+quoteList[0].Name+' }');
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        //SDT 41134
        try{
            Quotelineservice.doGet();
        }
        catch (Exception ex){             
        }
        Test.stopTest();
    } 
    static testMethod void testDoGet3(){
            List<Material_type_Material_Grade_mapping__mdt> materialMapping = new List<Material_type_Material_Grade_mapping__mdt>();
            materialMapping = [SELECT Material_Type__c,Material_Grade__c,Material_Grade_Code__c  FROM Material_type_Material_Grade_mapping__mdt WHERE Material_Type__c IN ('Cardboard','Trash') and Material_Grade__c IN ('Waxed OCC','International Trash')];
            
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            List<SBQQ__Quote__c> quoteList = [Select Id, Name From SBQQ__Quote__c where SBQQ__ShippingCity__c = 'Test123'];
             List<SBQQ__QuoteLine__c> qlLine= [Select Id,AssetId__c, Name From SBQQ__QuoteLine__c where SBQQ__Quote__c = :quoteList[0].Id];
            System.debug('qlLine^^^ ' +qlLine);
            for(SBQQ__QuoteLine__c ql :qlLine){
             System.debug('AssetId__c^^^ ' +ql.AssetId__c );
             }
            req.requestURI = '/services/apexrest/ProcessQuoteLine?QuoteName='+quoteList[0].Name;  
            req.httpMethod = 'GET';
            req.addParameter('QuoteName',quoteList[0].Name);// = Blob.valueof('{"QuoteName" : '+quoteList[0].Name+' }');
            RestContext.request = req;
            RestContext.response = res;
            
            Test.startTest();
            //SDT 41134
        try{
            Quotelineservice.doGet();
        }
        catch (Exception ex){             
        }
            Test.stopTest();
        }   
        
     static testMethod void testDoGet1(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        List<SBQQ__Quote__c> quoteList = [Select Id, Name From SBQQ__Quote__c];
        req.requestURI = '/services/apexrest/ProcessQuoteLine?QuoteName='+quoteList[0].Name;  
        req.httpMethod = 'GET';
        req.addParameter('QuoteName',quoteList[0].Name);// = Blob.valueof('{"QuoteName" : '+quoteList[0].Name+' }');
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Quotelineservice.doGet();
        Test.stopTest();
    }  
}
