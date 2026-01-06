/**
* @date 25/05/2023
* @description : Test class for GetChatNowTranscriptCtrl
**/

@isTest(seeAllData = false)
global class GetChatNowTranscriptCtrlTest {
    public static final string SYS_ADMIN = 'System Administrator';
       public static final string EMAIL = 'testfrom@test.com';
       public static final string ALTERNATIVE_EMAIL = 'test@test.com';
       public static final string EMAIL_SUBJECT = 'Approved:';
       public static final string NAME = 'test';
       public static final string EMAIL_BODY = 'Test \n Test1 \n test2';
       public static final string REJECTED = 'Rejected:';
       public static final string APPROVALS = 'Approvals';
       public static final string PO_PSI_VALUE = 'PO Number;PSI';
       public static final string DISTRICT_MANAGER = 'District Manager';
    
    @testSetup 
     static void setup() {
     
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);  
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].ProductTypeSelected__c = 'Compactor';
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0]. Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist.get(0).Tracking_Number__c = 'T22263283-15057747';
            caselist.get(0).Last_Customer_Interaction_ID__c = '000G3aJ512DK7BJE';
            Database.insert(caselist);
            
            Task tsk = new Task();
            tsk.WhatID = caselist[0].Id;
            tsk.Interaction_ID__c = '000FAaHSEAC69DBR';
            tsk.Subject = 'Inbound Customer Interaction';
            tsk.Description = 'chat';
            insert tsk;
            
        }
     }
    
    @isTest static void testChatTranscript() {
        Case caseObj = [Select Id,Last_Customer_Interaction_ID__c,origin from Case LIMIT 1];
        Task tskObj = [Select id,CreatedDate,Description,Subject, Interaction_ID__c from task];
        Test.startTest();
        List<GetChatNowTranscriptCtrl.taskWrapper> MethodResults1 = GetChatNowTranscriptCtrl.fetchTaskDetail(caseObj.Id);
    
        Test.setMock(HttpCalloutMock.class, new GetChatNowTranscriptMock());
        List<GetChatNowTranscriptCtrl.ResponseWrapper> MethodResults = GetChatNowTranscriptCtrl.getChatTranscript(caseObj.Id,tskObj.Interaction_Id__c);
        Test.stopTest();
        System.assert(MethodResults != null);
    }
    @isTest static void testChatTranscriptForChatNow() {
        Case caseObj = [Select Id,Last_Customer_Interaction_ID__c,origin from Case LIMIT 1];
        caseObj.origin = 'Chat Now';
        update caseObj;
        Task tskObj = [Select id,CreatedDate,Description,Subject, Interaction_ID__c from task];
        Test.startTest();
        List<GetChatNowTranscriptCtrl.taskWrapper> MethodResults1 = GetChatNowTranscriptCtrl.fetchTaskDetail(caseObj.Id);
    
        Test.setMock(HttpCalloutMock.class, new GetChatNowTranscriptMock());
        List<GetChatNowTranscriptCtrl.ResponseWrapper> MethodResults = GetChatNowTranscriptCtrl.getChatTranscript(caseObj.Id,tskObj.Interaction_Id__c);
        Test.stopTest();
        System.assert(MethodResults != null);
    }
    
    @isTest static void testChatTranscriptIteractionEmpty() {
        Test.startTest();
        Case caseObj = [Select Id,Last_Customer_Interaction_ID__c,origin from Case LIMIT 1];
        Task tskObj = [Select id,CreatedDate,Description,Subject, Interaction_ID__c from task];
        caseObj.Last_Customer_Interaction_ID__c = '';
        update caseObj;
        tskObj.Interaction_ID__c = '';
        update tskObj;
                List<GetChatNowTranscriptCtrl.taskWrapper> MethodResults1 = GetChatNowTranscriptCtrl.fetchTaskDetail(caseObj.Id);

        Test.setMock(HttpCalloutMock.class, new GetChatNowTranscriptMock());
        List<GetChatNowTranscriptCtrl.ResponseWrapper> MethodResults = GetChatNowTranscriptCtrl.getChatTranscript(caseObj.Id,tskObj.Interaction_Id__c);
        Test.stopTest();
        System.assert(MethodResults != null);
    }
    
    @isTest static void testChatTranscriptInValid() {
        Test.startTest();
        Case caseObj = [Select Id,Last_Customer_Interaction_ID__c,origin from Case LIMIT 1];
        Task tskObj = [Select id,CreatedDate,Description,Subject, Interaction_ID__c from task];
                List<GetChatNowTranscriptCtrl.taskWrapper> MethodResults1 = GetChatNowTranscriptCtrl.fetchTaskDetail(caseObj.Id);

        Test.setMock(HttpCalloutMock.class, new GetChatNowTranscriptErrorMock());
        List<GetChatNowTranscriptCtrl.ResponseWrapper> MethodResults = GetChatNowTranscriptCtrl.getChatTranscript(caseObj.Id,tskObj.Interaction_Id__c);
        Test.stopTest();
        System.assert(MethodResults != null);
    }
    
    @isTest static void testChatTranscriptServerIssue() {
        Test.startTest();
        Case caseObj = [Select Id,Last_Customer_Interaction_ID__c,origin from Case LIMIT 1];
                Task tskObj = [Select id,CreatedDate,Description,Subject, Interaction_ID__c from task];
        List<GetChatNowTranscriptCtrl.taskWrapper> MethodResults1 = GetChatNowTranscriptCtrl.fetchTaskDetail(caseObj.Id);

        Test.setMock(HttpCalloutMock.class, new GetChatNowTranscriptServerErrorMock());
        List<GetChatNowTranscriptCtrl.ResponseWrapper> MethodResults = GetChatNowTranscriptCtrl.getChatTranscript(caseObj.Id,tskObj.Interaction_Id__c);
        Test.stopTest();
        System.assert(MethodResults != null);
    }
    
    @isTest static void testChatTranscriptNoRes() {
        Test.startTest();
        Case caseObj = [Select Id,Last_Customer_Interaction_ID__c,origin from Case LIMIT 1];
                Task tskObj = [Select id,CreatedDate,Description,Subject, Interaction_ID__c from task];
        List<GetChatNowTranscriptCtrl.taskWrapper> MethodResults1 = GetChatNowTranscriptCtrl.fetchTaskDetail(caseObj.Id);

        Test.setMock(HttpCalloutMock.class, new GetChatNowTranscriptNoResMock());
        List<GetChatNowTranscriptCtrl.ResponseWrapper> MethodResults = GetChatNowTranscriptCtrl.getChatTranscript(caseObj.Id,tskObj.Interaction_Id__c);
        Test.stopTest();
        System.assert(MethodResults != null);
    }
    
    global class GetChatNowTranscriptNoResMock implements HTTPCalloutMock {
    	global HTTPResponse respond(HTTPRequest request) {
            String json = '{'+
            '  \"data\": null,'+
            '  \"problem\": null'+
            '}';
         	HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }
    
    global class GetChatNowTranscriptErrorMock implements HTTPCalloutMock {
    	global HTTPResponse respond(HTTPRequest request) {
            String json = '{'+
            '  \"data\": null,'+
            '  \"problem\": {'+
            '    \"title\": \"Bad Request\",'+
            '    \"status\": 400,'+
            '    \"errors\": ['+
            '      {'+
            '        \"code\": \"404\",'+
            '        \"message\": \"No data found\"'+
            '      }'+
            '    ]'+
            '  }'+
            '}';
         	HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }
    
    global class GetChatNowTranscriptServerErrorMock implements HTTPCalloutMock {
    	global HTTPResponse respond(HTTPRequest request) {
            String json = '{'+
            '  \"data\": null,'+
            '  \"problem\": {'+
            '    \"title\": \"Internal Server Error\",'+
            '    \"status\": 500,'+
            '    \"errors\": ['+
            '      {'+
            '        \"code\": \"404\",'+
            '        \"message\": \"No data found\"'+
            '      }'+
            '    ]'+
            '  }'+
            '}';
         	HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }
    
    global class GetChatNowTranscriptMock implements HTTPCalloutMock {
    	global HTTPResponse respond(HTTPRequest request) {
         
         String json = '{'+
		''+
		'	\"Data\": {'+
		''+
		'		\"StartAt\": \"5/7/2023 3:20:29 PM\",'+
		''+
		'		\"SessionId\": \"000G3aJ512DKUNVU\",'+
		''+
		'		\"Events\": ['+
		''+
		'			{'+
		''+
		'				\"UserId\": \"020D6457C1BD19A7\",'+
		''+
		'				\"TimeShift\": \"0\",'+
		''+
		'				\"Visibility\": \"ALL\",'+
		''+
		'				\"EventId\": \"1\",'+
		''+
		'				\"NewParty\": {'+
		''+
		'					\"UserInfo\": {'+
		''+
		'						\"PersonId\": \"\",'+
		''+
		'						\"UserNick\": \"Michael Rantala\",'+
		''+
		'						\"UserType\": \"CLIENT\",'+
		''+
		'						\"ProtocolType\": \"FLEX\",'+
		''+
		'						\"TimeZoneOffset\": \"-300\",'+
		''+
		'						\"ClientVersion\": \"106\"'+
		''+
		'					},'+
		''+
		'					\"UserData\": ['+
		''+
		'						{'+
		''+
		'							\"Key\": \"AuthToken\",'+
		''+
		'							\"Value\": \"142dbc760482cbbfab791d84aebae99dfcd54c582785ac9027f7a965a0df979e\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"ChatBotHoldup\",'+
		''+
		'							\"Value\": \"true\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"ChatBotID\",'+
		''+
		'							\"Value\": \"speechstorm-chatbot\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"ChatBotName\",'+
		''+
		'							\"Value\": \"EchoBot\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"FirstName\",'+
		''+
		'							\"Value\": \"Michael\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"GCTI_GMS_NodeGroup\",'+
		''+
		'							\"Value\": \"GMSCluster_Obj_Ext\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"GCTI_GMS_NodeName\",'+
		''+
		'							\"Value\": \"GMSExt_2\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"GCTI_LanguageCode\",'+
		''+
		'							\"Value\": \"en\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"IdentifyCreateContact\",'+
		''+
		'							\"Value\": \"3\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"IsTestCall\",'+
		''+
		'							\"Value\": \"true\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"LastName\",'+
		''+
		'							\"Value\": \"Rantala\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"MediaType\",'+
		''+
		'							\"Value\": \"chat\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"Nickname\",'+
		''+
		'							\"Value\": \"National Accounts\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"SiteID\",'+
		''+
		'							\"Value\": \"13045\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"StopBotOnAgentArrival\",'+
		''+
		'							\"Value\": \"false\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"StopBotOnCustomerLeft\",'+
		''+
		'							\"Value\": \"false\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"TimeZone\",'+
		''+
		'							\"Value\": \"-300\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"To\",'+
		''+
		'							\"Value\": null'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"Visibility\",'+
		''+
		'							\"Value\": \"ALL\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"_genesys_OS\",'+
		''+
		'							\"Value\": \"Windows\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"_genesys_browser\",'+
		''+
		'							\"Value\": \"Chrome\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"_genesys_pageTitle\",'+
		''+
		'							\"Value\": \"SBS Chat Now\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"_genesys_referrer\",'+
		''+
		'							\"Value\": \"https: //chatnow.wmsbs.wm.com/\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"_genesys_source\",'+
		''+
		'							\"Value\": \"web\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"_genesys_url\",'+
		''+
		'							\"Value\": \"https: //chatnow.wmsbs.wm.com/\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"_genesys_widgets\",'+
		''+
		'							\"Value\": \"9.0.017.00\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"_umsChannel\",'+
		''+
		'							\"Value\": \"channel-chatbot\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"emailid\",'+
		''+
		'							\"Value\": null'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"languageselect\",'+
		''+
		'							\"Value\": \"en\"'+
		''+
		'						}'+
		''+
		'					],'+
		''+
		'					\"EventAttributes\": null'+
		''+
		'				},'+
		''+
		'				\"Message\": null,'+
		''+
		'				\"PartyLeft\": null'+
		''+
		'			},'+
		''+
		'			{'+
		''+
		'				\"UserId\": \"020D6457C1C019A9\",'+
		''+
		'				\"TimeShift\": \"3\",'+
		''+
		'				\"Visibility\": \"ALL\",'+
		''+
		'				\"EventId\": \"2\",'+
		''+
		'				\"NewParty\": {'+
		''+
		'					\"UserInfo\": {'+
		''+
		'						\"PersonId\": \"\",'+
		''+
		'						\"UserNick\": \"National Accounts\",'+
		''+
		'						\"UserType\": \"AGENT\",'+
		''+
		'						\"ProtocolType\": \"BASIC\",'+
		''+
		'						\"TimeZoneOffset\": \"-18000000\",'+
		''+
		'						\"ClientVersion\": \"106\"'+
		''+
		'					},'+
		''+
		'					\"UserData\": ['+
		''+
		'						{'+
		''+
		'							\"Key\": \"GCTI_Chat_PartyStyle\",'+
		''+
		'							\"Value\": \"BOT\"'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"GCTI_Chat_SetPartyStyle\",'+
		''+
		'							\"Value\": \"BOT\"'+
		''+
		'						}'+
		''+
		'					],'+
		''+
		'					\"EventAttributes\": ['+
		''+
		'						{'+
		''+
		'							\"Key\": \"GCTI_SYSTEM\",'+
		''+
		'							\"Items\": ['+
		''+
		'								{'+
		''+
		'									\"Key\": \"party-info\",'+
		''+
		'									\"Text\": null,'+
		''+
		'									\"Items\": {'+
		''+
		'										\"Key\": \"style\",'+
		''+
		'										\"Value\": \"BOT\"'+
		''+
		'									}'+
		''+
		'								}'+
		''+
		'							]'+
		''+
		'						},'+
		''+
		'						{'+
		''+
		'							\"Key\": \"chat-bot-startup-info\",'+
		''+
		'							\"Items\": ['+
		''+
		'								{'+
		''+
		'									\"Key\": \"ChatBotHoldup\",'+
		''+
		'									\"Text\": ['+
		''+
		'										\"true\"'+
		''+
		'									],'+
		''+
		'									\"Items\": null'+
		''+
		'								},'+
		''+
		'								{'+
		''+
		'									\"Key\": \"ChatBotID\",'+
		''+
		'									\"Text\": ['+
		''+
		'										\"speechstorm-chatbot\"'+
		''+
		'									],'+
		''+
		'									\"Items\": null'+
		''+
		'								},'+
		''+
		'								{'+
		''+
		'									\"Key\": \"ChatBotName\",'+
		''+
		'									\"Text\": ['+
		''+
		'										\"EchoBot\"'+
		''+
		'									],'+
		''+
		'									\"Items\": null'+
		''+
		'								},'+
		''+
		'								{'+
		''+
		'									\"Key\": \"StopBotOnAgentArrival\",'+
		''+
		'									\"Text\": ['+
		''+
		'										\"false\"'+
		''+
		'									],'+
		''+
		'									\"Items\": null'+
		''+
		'								},'+
		''+
		'								{'+
		''+
		'									\"Key\": \"StopBotOnCustomerLeft\",'+
		''+
		'									\"Text\": ['+
		''+
		'										\"false\"'+
		''+
		'									],'+
		''+
		'									\"Items\": null'+
		''+
		'								},'+
		''+
		'								{'+
		''+
		'									\"Key\": \"cbs\",'+
		''+
		'									\"Text\": ['+
		''+
		'										\"0857AQ346JM8M6PN\"'+
		''+
		'									],'+
		''+
		'									\"Items\": null'+
		''+
		'								},'+
		''+
		'								{'+
		''+
		'									\"Key\": \"launch-mode\",'+
		''+
		'									\"Text\": ['+
		''+
		'										\"STARTED_BY_ESP\"'+
		''+
		'									],'+
		''+
		'									\"Items\": null'+
		''+
		'								}'+
		''+
		'							]'+
		''+
		'						}'+
		''+
		'					]'+
		''+
		'				},'+
		''+
		'				\"Message\": null,'+
		''+
		'				\"PartyLeft\": null'+
		''+
		'			},'+
		''+
		'			{'+
		''+
		'				\"UserId\": \"020D6457C1C019A9\",'+
		''+
		'				\"TimeShift\": \"6\",'+
		''+
		'				\"Visibility\": \"ALL\",'+
		''+
		'				\"EventId\": \"3\",'+
		''+
		'				\"NewParty\": null,'+
		''+
		'				\"Message\": {'+
		''+
		'					\"Text\": {'+
		''+
		'						\"Type\": null,'+
		''+
		'						\"Value\": \"Welcome Michael! This is Andrew, your virtual assistant. How can I help you?\"'+
		''+
		'					},'+
		''+
		'					\"EventAttributes\": {'+
		''+
		'						\"Item\": {'+
		''+
		'							\"Key\": \"structured-content\",'+
		''+
		'							\"Item\": {'+
		''+
		'								\"Key\": \"genesys-chat\",'+
		''+
		'								\"Text\": null,'+
		''+
		'								\"Item\": {'+
		''+
		'									\"Key\": \"content\",'+
		''+
		'									\"Value\": \"{  type : Message,  contentType : quick-replies,  messageType : text,  text : ,  content : [ {    id : 1,    type : quick-reply,    action : message,    text : Schedule a pickup  }, {    id : 2,    type : quick-reply,    action : message,    text : Get the status of a pending service  }, {    id : 3,    type : quick-reply,    action : message,    text : Something else  } ]}\"'+
		''+
		'								}'+
		''+
		'							}'+
		''+
		'						}'+
		''+
		'					}'+
		''+
		'				},'+
		''+
		'				\"PartyLeft\": null'+
		''+
		'			},'+
		''+
		'			{'+
		''+
		'				\"UserId\": \"020D6457C1BD19A7\",'+
		''+
		'				\"TimeShift\": \"28\",'+
		''+
		'				\"Visibility\": \"ALL\",'+
		''+
		'				\"EventId\": \"4\",'+
		''+
		'				\"NewParty\": null,'+
		''+
		'				\"Message\": {'+
		''+
		'					\"Text\": {'+
		''+
		'						\"Type\": \"text\",'+
		''+
		'						\"Value\": \"Something else\"'+
		''+
		'					},'+
		''+
		'					\"EventAttributes\": {'+
		''+
		'						\"Item\": {'+
		''+
		'							\"Key\": \"general-properties\",'+
		''+
		'							\"Item\": {'+
		''+
		'								\"Key\": \"related-event-id\",'+
		''+
		'								\"Text\": ['+
		''+
		'									\"3\"'+
		''+
		'								],'+
		''+
		'								\"Item\": null'+
		''+
		'							}'+
		''+
		'						}'+
		''+
		'					}'+
		''+
		'				},'+
		''+
		'				\"PartyLeft\": null'+
		''+
		'			},'+
		''+
		'			{'+
		''+
		'				\"UserId\": \"020D6457C1C019A9\",'+
		''+
		'				\"TimeShift\": \"29\",'+
		''+
		'				\"Visibility\": \"ALL\",'+
		''+
		'				\"EventId\": \"5\",'+
		''+
		'				\"NewParty\": null,'+
		''+
		'				\"Message\": {'+
		''+
		'					\"Text\": {'+
		''+
		'						\"Type\": null,'+
		''+
		'						\"Value\": \"Please select what best describes your need:\"'+
		''+
		'					},'+
		''+
		'					\"EventAttributes\": {'+
		''+
		'						\"Item\": {'+
		''+
		'							\"Key\": \"structured-content\",'+
		''+
		'							\"Item\": {'+
		''+
		'								\"Key\": \"genesys-chat\",'+
		''+
		'								\"Text\": null,'+
		''+
		'								\"Item\": {'+
		''+
		'									\"Key\": \"content\",'+
		''+
		'									\"Value\": \"{  type : Message,  contentType : quick-replies,  messageType : text,  text : ,  content : [ {    id : 1,    type : quick-reply,    action : message,    text : New service  }, {    id : 2,    type : quick-reply,    action : message,    text : Bulk  }, {    id : 3,    type : quick-reply,    action : message,    text : Haul Away  }, {    id : 4,    type : quick-reply,    action : message,    text : Missed service  }, {    id : 5,    type : quick-reply,    action : message,    text : Service change  }, {    id : 6,    type : quick-reply,    action : message,    text : Relocation  }, {    id : 7,    type : quick-reply,    action : message,    text : Locks  }, {    id : 8,    type : quick-reply,    action : message,    text : Lids  }, {    id : 9,    type : quick-reply,    action : message,    text : Repair  }, {    id : 10,    type : quick-reply,    action : message,    text : General inquiry  }, {    id : 100-spl,    type : quick-reply,    action : message,    text : Main Menu  } ]}\"'+
		''+
		'								}'+
		''+
		'							}'+
		''+
		'						}'+
		''+
		'					}'+
		''+
		'				},'+
		''+
		'				\"PartyLeft\": null'+
		''+
		'			},'+
		''+
		'			{'+
		''+
		'				\"UserId\": \"020D6457C1BD19A7\",'+
		''+
		'				\"TimeShift\": \"44\",'+
		''+
		'				\"Visibility\": \"ALL\",'+
		''+
		'				\"EventId\": \"6\",'+
		''+
		'				\"NewParty\": null,'+
		''+
		'				\"Message\": {'+
		''+
		'					\"Text\": {'+
		''+
		'						\"Type\": \"text\",'+
		''+
		'						\"Value\": \"Repair\"'+
		''+
		'					},'+
		''+
		'					\"EventAttributes\": {'+
		''+
		'						\"Item\": {'+
		''+
		'							\"Key\": \"general-properties\",'+
		''+
		'							\"Item\": {'+
		''+
		'								\"Key\": \"related-event-id\",'+
		''+
		'								\"Text\": ['+
		''+
		'									\"5\"'+
		''+
		'								],'+
		''+
		'								\"Item\": null'+
		''+
		'							}'+
		''+
		'						}'+
		''+
		'					}'+
		''+
		'				},'+
		''+
		'				\"PartyLeft\": null'+
		''+
		'			},'+
		''+
		'			{'+
		''+
		'				\"UserId\": \"020D6457C1C019A9\",'+
		''+
		'				\"TimeShift\": \"44\",'+
		''+
		'				\"Visibility\": \"ALL\",'+
		''+
		'				\"EventId\": \"7\",'+
		''+
		'				\"NewParty\": null,'+
		''+
		'				\"Message\": {'+
		''+
		'					\"Text\": {'+
		''+
		'						\"Type\": null,'+
		''+
		'						\"Value\": \"In order to assist you, I need to know your service location. How would you like to identify your location?\"'+
		''+
		'					},'+
		''+
		'					\"EventAttributes\": {'+
		''+
		'						\"Item\": {'+
		''+
		'							\"Key\": \"structured-content\",'+
		''+
		'							\"Item\": {'+
		''+
		'								\"Key\": \"genesys-chat\",'+
		''+
		'								\"Text\": null,'+
		''+
		'								\"Item\": {'+
		''+
		'									\"Key\": \"content\",'+
		''+
		'									\"Value\": \"{  type : Message,  contentType : quick-replies,  messageType : text,  text : ,  content : [ {    id : 1,    type : quick-reply,    action : message,    text : Phone number  }, {    id : 2,    type : quick-reply,    action : message,    text : Service address  }, {    id : 3,    type : quick-reply,    action : message,    text : Location ID  } ]}\"'+
		''+
		'								}'+
		''+
		'							}'+
		''+
		'						}'+
		''+
		'					}'+
		''+
		'				},'+
		''+
		'				\"PartyLeft\": null'+
		''+
		'			},'+
		''+
		'			{'+
		''+
		'				\"UserId\": \"020D6457C1BD19A7\",'+
		''+
		'				\"TimeShift\": \"64\",'+
		''+
		'				\"Visibility\": \"ALL\",'+
		''+
		'				\"EventId\": \"8\",'+
		''+
		'				\"NewParty\": null,'+
		''+
		'				\"Message\": {'+
		''+
		'					\"Text\": {'+
		''+
		'						\"Type\": \"text\",'+
		''+
		'						\"Value\": \"Location ID\"'+
		''+
		'					},'+
		''+
		'					\"EventAttributes\": {'+
		''+
		'						\"Item\": {'+
		''+
		'							\"Key\": \"general-properties\",'+
		''+
		'							\"Item\": {'+
		''+
		'								\"Key\": \"related-event-id\",'+
		''+
		'								\"Text\": ['+
		''+
		'									\"7\"'+
		''+
		'								],'+
		''+
		'								\"Item\": null'+
		''+
		'							}'+
		''+
		'						}'+
		''+
		'					}'+
		''+
		'				},'+
		''+
		'				\"PartyLeft\": null'+
		''+
		'			},'+
		''+
		'			{'+
		''+
		'				\"UserId\": \"020D6457C1C019A9\",'+
		''+
		'				\"TimeShift\": \"65\",'+
		''+
		'				\"Visibility\": \"ALL\",'+
		''+
		'				\"EventId\": \"9\",'+
		''+
		'				\"NewParty\": null,'+
		''+
		'				\"Message\": {'+
		''+
		'					\"Text\": {'+
		''+
		'						\"Type\": \"text/plain\",'+
		''+
		'						\"Value\": \"Please enter your Location ID.\"'+
		''+
		'					},'+
		''+
		'					\"EventAttributes\": null'+
		''+
		'				},'+
		''+
		'				\"PartyLeft\": null'+
		''+
		'			},'+
		''+
		'			{'+
		''+
		'				\"UserId\": \"020D6457C1BD19A7\",'+
		''+
		'				\"TimeShift\": \"75\",'+
		''+
		'				\"Visibility\": \"ALL\",'+
		''+
		'				\"EventId\": \"13\",'+
		''+
		'				\"NewParty\": null,'+
		''+
		'				\"Message\": {'+
		''+
		'					\"Text\": {'+
		''+
		'						\"Type\": \"text\",'+
		''+
		'						\"Value\": \"MTH002904\"'+
		''+
		'					},'+
		''+
		'					\"EventAttributes\": null'+
		''+
		'				},'+
		''+
		'				\"PartyLeft\": null'+
		''+
		'			},'+
		''+
		'			{'+
		''+
		'				\"UserId\": \"020D6457C1C019A9\",'+
		''+
		'				\"TimeShift\": \"77\",'+
		''+
		'				\"Visibility\": \"ALL\",'+
		''+
		'				\"EventId\": \"14\",'+
		''+
		'				\"NewParty\": null,'+
		''+
		'				\"Message\": {'+
		''+
		'					\"Text\": {'+
		''+
		'						\"Type\": null,'+
		''+
		'						\"Value\": \"Alright, based on the information you provided, I can see you\'re chatting from Marcus Theatres at 5210 S 76TH ST, Greendale, Wisconsin. Is that correct?\"'+
		''+
		'					},'+
		''+
		'					\"EventAttributes\": {'+
		''+
		'						\"Item\": {'+
		''+
		'							\"Key\": \"structured-content\",'+
		''+
		'							\"Item\": {'+
		''+
		'								\"Key\": \"genesys-chat\",'+
		''+
		'								\"Text\": null,'+
		''+
		'								\"Item\": {'+
		''+
		'									\"Key\": \"content\",'+
		''+
		'									\"Value\": \"{  type : Message,  contentType : quick-replies,  messageType : text,  text : ,  content : [ {    id : 1,    type : quick-reply,    action : message,    text : Yes  }, {    id : 2,    type : quick-reply,    action : message,    text : No  } ]}\"'+
		''+
		'								}'+
		''+
		'							}'+
		''+
		'						}'+
		''+
		'					}'+
		''+
		'				},'+
		''+
		'				\"PartyLeft\": null'+
		''+
		'			},'+
		''+
		'			{'+
		''+
		'				\"UserId\": \"020D6457C1BD19A7\",'+
		''+
		'				\"TimeShift\": \"114\",'+
		''+
		'				\"Visibility\": \"ALL\",'+
		''+
		'				\"EventId\": \"15\",'+
		''+
		'				\"NewParty\": null,'+
		''+
		'				\"Message\": {'+
		''+
		'					\"Text\": {'+
		''+
		'						\"Type\": \"text\",'+
		''+
		'						\"Value\": \"Yes\"'+
		''+
		'					},'+
		''+
		'					\"EventAttributes\": {'+
		''+
		'						\"Item\": {'+
		''+
		'							\"Key\": \"general-properties\",'+
		''+
		'							\"Item\": {'+
		''+
		'								\"Key\": \"related-event-id\",'+
		''+
		'								\"Text\": ['+
		''+
		'									\"14\"'+
		''+
		'								],'+
		''+
		'								\"Item\": null'+
		''+
		'							}'+
		''+
		'						}'+
		''+
		'					}'+
		''+
		'				},'+
		''+
		'				\"PartyLeft\": null'+
		''+
		'			},'+
		''+
		'			{'+
		''+
		'				\"UserId\": \"020D6457C1C019A9\",'+
		''+
		'				\"TimeShift\": \"116\",'+
		''+
		'				\"Visibility\": \"ALL\",'+
		''+
		'				\"EventId\": \"16\",'+
		''+
		'				\"NewParty\": null,'+
		''+
		'				\"Message\": {'+
		''+
		'					\"Text\": {'+
		''+
		'						\"Type\": null,'+
		''+
		'						\"Value\": \"Thanks for confirming your service address. I¿m Sorry, our offices are closed. Our regular business hours are Monday - Friday, 7 AM ¿ 8 PM ET, and Saturdays, 7 AM ¿ 3:30 PM ET. Please select from the following options.\"'+
		''+
		'					},'+
		''+
		'					\"EventAttributes\": {'+
		''+
		'						\"Item\": {'+
		''+
		'							\"Key\": \"structured-content\",'+
		''+
		'							\"Item\": {'+
		''+
		'								\"Key\": \"genesys-chat\",'+
		''+
		'								\"Text\": null,'+
		''+
		'								\"Item\": {'+
		''+
		'									\"Key\": \"content\",'+
		''+
		'									\"Value\": \"{  type : Message,  contentType : quick-replies,  messageType : text,  text : ,  content : [ {    id : 1,    type : quick-reply,    action : message,    text : Contact us later  }, {    id : 2,    type : quick-reply,    action : message,    text : Call 866-223-8034 for urgent issues  }, {    id : 3,    type : quick-reply,    action : message,    text : Request a callback  } ]}\"'+
		''+
		'								}'+
		''+
		'							}'+
		''+
		'						}'+
		''+
		'					}'+
		''+
		'				},'+
		''+
		'				\"PartyLeft\": null'+
		''+
		'			},'+
		''+
		'			{'+
		''+
		'				\"UserId\": \"020D6457C1BD19A7\",'+
		''+
		'				\"TimeShift\": \"685\",'+
		''+
		'				\"Visibility\": \"ALL\",'+
		''+
		'				\"EventId\": \"17\",'+
		''+
		'				\"NewParty\": null,'+
		''+
		'				\"Message\": null,'+
		''+
		'				\"PartyLeft\": {'+
		''+
		'					\"AskerId\": \"020D6457C1BD19A7\",'+
		''+
		'					\"Reason\": {'+
		''+
		'						\"Code\": \"3\",'+
		''+
		'						\"Value\": \"left due to disconnect\"'+
		''+
		'					}'+
		''+
		'				}'+
		''+
		'			},'+
		''+
		'			{'+
		''+
		'				\"UserId\": \"020D6457C1C019A9\",'+
		''+
		'				\"TimeShift\": \"685\",'+
		''+
		'				\"Visibility\": \"ALL\",'+
		''+
		'				\"EventId\": \"18\",'+
		''+
		'				\"NewParty\": null,'+
		''+
		'				\"Message\": null,'+
		''+
		'				\"PartyLeft\": {'+
		''+
		'					\"AskerId\": \"020D6457C1C019A9\",'+
		''+
		'					\"Reason\": {'+
		''+
		'						\"Code\": null,'+
		''+
		'						\"Value\": \"left\"'+
		''+
		'					}'+
		''+
		'				}'+
		''+
		'			}'+
		''+
		'		]'+
		''+
		'	},'+
		''+
		'	\"Problem\": null'+
		''+
		'}';
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(json);
        response.setStatusCode(200);
        return response;
    	}
	}

}
