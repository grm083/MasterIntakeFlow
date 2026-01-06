public with sharing class IntakeProcessAuraHandler {
    
    //The purpose of the Intake Process Aura Handler is to call the actions directly from the Lightning Components that present
    //questions to the users.  It has been broken into classes that are directly invocable by the Lightning Component, and logic
    //components to attempt updates explicitly to the DML classes.
    
    @AuraEnabled
    public static Case getCaseDetails(Id CaseId, Boolean updateFlow) {
        
        Case c = [SELECT Id, Master_Intake_Complete__c
                 FROM Case
                 WHERE Id =: CaseId];
        
        if(updateFlow) {
            c.Master_Intake_Complete__c = updateFlow;
            try {
                update c;
                return c;
            } catch (DmlException e) {
                return c;
            }
        } else {
            return c;
        }
    }
    
    @AuraEnabled
    public static String doCaseUpdates(Id CaseId, Id OutcomeId) {
        
        Intake_Process__c o = new Intake_Process__c();
        Case c = new Case();
        Task t = new Task();
        
        c = [SELECT Id, Case_Type__c, Case_Sub_Type__c, Case_Reason__c,
             Status, Team_Name__c, Team_Queue__c, Case_Sub_Status__c, User_Name__c
             FROM Case
             WHERE Id =: CaseId];
        
        String status = c.Status;
        
        o = [SELECT Id, Update_Case_Record_Type__c, Update_Case_Status__c, Update_Case_Type__c,
             Update_Case_Sub_Type__c, Update_Case_Reason__c, Team_Name__c, Queue_Assigned__c, Case_Status__c,
             Case_Record_Type__c, Case_Type__c, Case_Sub_Type__c, Case_Reason__c, Task_Type__c, Task_Process__c,
             Create_Task__c, Outcome_Statement__c, Assign_To_Current_User__c
             FROM Intake_Process__c
             WHERE Id =: OutcomeId];
        
        if(o.Update_Case_Record_Type__c) {
               c.RecordTypeId = [SELECT Id FROM RecordType WHERE Name =: o.Case_Record_Type__c LIMIT 1].Id;
           }
        
        if(!String.isBlank(o.Queue_Assigned__c)) {
            c.Team_Name__c = o.Team_Name__c;
            c.Team_Queue__c = o.Queue_Assigned__c;
        }
        
        if(o.Assign_to_Current_User__c) {
            c.User_Name__c = UserInfo.getUserId();
        }
        
        if(o.Create_Task__c) {
            t.WhatId = c.Id;
            t.Subject = o.Task_Type__c;
            t.Process__c = 'Master Intake';
            t.Description = o.Outcome_Statement__c;
            t.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Quick Task' LIMIT 1].Id;
            t.OwnerId = UserInfo.getUserId();
        }
        
        try {
            update c;
            if (t.WhatId != null) {
                insert t;
            }
            if (o.Update_Case_Type__c ||
               o.Update_Case_Sub_Type__c ||
                o.Update_Case_Reason__c) {
                    c.Case_Type__c = o.Case_Type__c;
                    c.Case_Sub_Type__c = o.Case_Sub_Type__c;
                    c.Case_Reason__c = o.Case_Reason__c;
                    update c;
                }
            if(o.Update_Case_Status__c) {
                c.Status = o.Case_Status__c;
                status = o.Case_Status__c;
                if(c.Case_Sub_Type__c == 'Service Not Performed' && o.Case_Status__c == 'Open') {
                    c.Case_Sub_Status__c = 'Pending Service Issue Resolution';
                }
                if(c.Case_Sub_Type__c == 'Bale(s)' && o.Case_Status__c == 'Pending') {
                    c.Case_Sub_Status__c = 'Pending Request Approval';
                }
                update c;
            }
            return status;
        } catch (DmlException e) {
            system.debug(e.getMessage());
            return status;
        }
    }
    
    @AuraEnabled
    public static Comment__c createComment(Id CaseId, String Comment) {
        
        Case c = [SELECT Id, CaseNumber, Master_Intake_Complete__c, Case_Comments__c, Tracking_Number__c
                 FROM Case
                 WHERE Id =: CaseId];
        
        User u = [SELECT Id, Acorn_SUser_ID__c
                 FROM User
                 WHERE Id =: UserInfo.getUserId()];
        
        Comment = Comment.replace('Additional Comments', 'Additional Comments/Instructions for Other Teams');
        
        Comment__c comm = new Comment__c();
        comm.Case__c = c.Id;
        comm.Case_Number__c = c.CaseNumber;
        comm.Type__c = 'Case';
        comm.Comment__c = Comment;
        comm.Acorn_SUser_ID__c = u.Acorn_SUser_ID__c;
        comm.Communication_Log_Type_Name__c = 'Internal';
        comm.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Acorn_Ticket_Comment' LIMIT 1].Id;
        if (c.Tracking_Number__c != null) {
            comm.Acorn_Tracking_Number__c = c.Tracking_Number__c;
        }
        
        c.Master_Intake_Complete__c = true;
        c.Case_Comments__c = 'Salesforce Generated Case';
        
        try {
            insert comm;
            update c;
            return comm;
        } catch (DmlException e) {
            system.debug(e.getMessage());
            return comm;
        }
        
    }
    
    @AuraEnabled
    public static Intake_Process__c getFirstQuestion(Id CaseId) {
        
        Intake_Process__c IntakeProcess = new Intake_Process__c();
        
        Case c = [SELECT Id, Client__c, Case_Type__c, Case_Sub_Type__c, Case_Reason__c,
                  Location__c, Asset.Project_Code__c
                  FROM Case
                  WHERE Id =: caseId
                  LIMIT 1];
        
        String CaseReason;
        
        If (c.Case_Reason__c != Null){
            CaseReason = c.Case_Reason__c;
        } else {
            CaseReason = 'Null';
        }
        
        System.Debug('Client Id is: ' + c.Client__c);
        System.Debug('Location Id is: ' + c.Location__c);
        System.Debug('Project Id is: ' + c.Asset.Project_Code__c);
        System.Debug('Case Type is: ' +  c.Case_Type__c);
        System.Debug('Case Sub-Type is: ' +  c.Case_Sub_Type__c);
        System.Debug('Client Reason is: ' + CaseReason);
        
        //Determine which type of questions will be presented to the user
        //Projects have been commented out.  This will be a future feature and the order of query
        //below indicates the "pecking order" that we should approach them with.  
        IntakeProcess = getAccountQs(c.Client__c, c.Case_Type__c, c.Case_Sub_Type__c, CaseReason);
        if (IntakeProcess.Id != Null) {
            system.debug('Client scripting found!');
            return IntakeProcess;
        } else {
            /*if (c.Asset.Project_Code__c != Null) {
                IntakeProcess = getProjectQs(c.Asset.Project_Code__c, c.Case_Type__c, c.Case_Sub_Type__c, CaseReason);
            } To be included in a later release */
            if (IntakeProcess.Id != Null) {
                system.debug('Project scripting found!');
                return IntakeProcess;
            } else {
                IntakeProcess = getLocationQs(c.Location__c, c.Case_Type__c, c.Case_Sub_Type__c, CaseReason);
                if (IntakeProcess.Id != Null) {
                    system.debug('Location scripting found!');
                    return IntakeProcess;    
                } else {
                    IntakeProcess = getRoleQs(c.Case_Type__c, c.Case_Sub_Type__c, CaseReason);
                    if (IntakeProcess.Id != Null) {
                        system.debug('Role scripting found!');
                        return IntakeProcess;
                    } else {
                        IntakeProcess = getGeneralQs(c.Case_Type__c, c.Case_Sub_Type__c, CaseReason);
                        system.debug('General scripting found!');
                        return IntakeProcess;
                        //Not every case type will have a process.  If not this will return a null record and the flow will handle accordingly
                    }
                }
            }
        }
    }
    
    //Gets the next question based on the outcome selected.  Intake Questions are tied to 
    //one or more intake outcomes.  The outcomes determine the picklist values available (see next method)
    //and each outcome should either be tied to a Next Question, or to an Outcome Statement (indicates end of questions)
    @AuraEnabled
    public static Intake_Process__c getNextQuestion(Id QuestionId) {
        
        Intake_Process__c NextQuestion = new Intake_Process__c();
        
        system.debug('QuestionId is: ' + QuestionId);
        
        NextQuestion = [SELECT Id, Customer_Account__c, Case_Type__c, Case_Sub_Type__c,
                        Case_Reason__c, Question__c, Input_Type__c, Customer_Location__c
                        FROM Intake_Process__c
                        WHERE Id =:QuestionId
                        LIMIT 1];        
        
        system.debug(NextQuestion.Question__c);
        
        return NextQuestion;
    }
    
    //Gets the list of acceptable outcomes, used to generate picklist values and
    //determine the next questions or the outcome statements
    @AuraEnabled
    public static List<Intake_Process__c> getOutcomes(Id Question) {
        
        List<Intake_Process__c> Outcomes = [SELECT Id, Outcome__c, Any_Value__c, Update_Service_Date__c, Assign_Case_To__c, Outcome_Statement__c,
                                            Update_Case_Type__c, Update_Case_Sub_Type__c, Update_Case_Reason__c, Update_Case_Status__c, Case_Type__c,
                                            Case_Sub_Type__c, Case_Reason__c, Create_Task__c, Task_Type__c, Task_Process__c,
                                            Next_Question__c, Queue_Assigned__c, Update_Case_Record_Type__c, Case_Record_Type__c, Team_Name__c, Case_Status__c
                                            FROM Intake_Process__c
                                            WHERE RecordType.Name = 'Intake Outcomes' AND Intake_Question__c =: Question];
        
        return Outcomes;
        
    }
    //Logic to Return Account Level Scripting
    public static Intake_Process__c getAccountQs(Id clientId, string CaseType, string SubType, string Reason) {
        
        Intake_Process__c AccountScript = new Intake_Process__c();
        List<Intake_Process__c> AcctProcess = new List<Intake_Process__c>();
        
        try {
            if (Reason != 'Null') {
                AcctProcess = [SELECT Id, Customer_Account__c, Case_Type__c, Case_Sub_Type__c,
                               Case_Reason__c, Question__c, Input_Type__c
                               FROM Intake_Process__c
                               WHERE Customer_Account__c =: clientId AND Presentation_Order__c = 1 AND
                               Case_Type__c =: CaseType AND Case_Sub_Type__c =: SubType AND Case_Reason__c =: Reason
                               AND RecordType.Name = 'Intake Questions'
                               LIMIT 1];
                
                if(AcctProcess.size() > 0) {
                    AccountScript = AcctProcess[0];
                }
                return AccountScript;
            } else {
                AcctProcess = [SELECT Id, Customer_Account__c, Case_Type__c, Case_Sub_Type__c,
                               Case_Reason__c, Question__c, Input_Type__c
                               FROM Intake_Process__c
                               WHERE Customer_Account__c =: clientId AND Presentation_Order__c = 1 AND
                               Case_Type__c =: CaseType AND Case_Sub_Type__c =: SubType AND Case_Reason__c = Null
                               AND RecordType.Name = 'Intake Questions'
                               LIMIT 1];
                
                if(AcctProcess.size() > 0) {
                    AccountScript = AcctProcess[0];
                }
                return AccountScript;
            }
        } catch (DmlException de) {
            return AccountScript;
        }
    }
    
    /*Logic to Return Project level scripting - Written, however won't be enabled as part of first release
    public static Intake_Process__c getProjectQs(Id projectId, string CaseType, string SubType, string Reason) {
        Intake_Process__c ProjectScript = new Intake_Process__c();
        List<Intake_Process__c> ProjProcess = new List<Intake_Process__c>();
        
        try {
            if (Reason != 'Null') {
                ProjProcess = [SELECT Id, Customer_Account__c, Case_Type__c, Case_Sub_Type__c,
                               Case_Reason__c, Question__c, Input_Type__c
                               FROM Intake_Process__c
                               WHERE Customer_Project__c =: projectId AND Presentation_Order__c = 1 AND
                               Case_Type__c =: CaseType AND Case_Sub_Type__c =: SubType AND Case_Reason__c =: Reason
                               AND RecordType.Name = 'Intake Questions'
                               LIMIT 1];
                
                if(ProjProcess.size() > 0) {
                    ProjectScript = ProjProcess[0];
                }
                return ProjectScript;
            } else {
                ProjProcess = [SELECT Id, Customer_Account__c, Case_Type__c, Case_Sub_Type__c,
                               Case_Reason__c, Question__c, Input_Type__c
                               FROM Intake_Process__c
                               WHERE Customer_Project__c =: projectId AND Presentation_Order__c = 1 AND
                               Case_Type__c =: CaseType AND Case_Sub_Type__c =: SubType AND Case_Reason__c = Null
                               AND RecordType.Name = 'Intake Questions'
                               LIMIT 1];
                
                if(ProjProcess.size() > 0) {
                    ProjectScript = ProjProcess[0];
                }
                return ProjectScript;
            }
        } catch (DmlException de) {
            return ProjectScript;
        }
    }*/
    //Logic to Return Location level scripting
    public static Intake_Process__c getLocationQs(Id locationId, string CaseType, string SubType, string Reason) {
        Intake_Process__c LocationScript = new Intake_Process__c();
        List<Intake_Process__c> LocProcess = new List<Intake_Process__c>();
        
        try {
            if (Reason != 'Null') {
                LocProcess = [SELECT Id, Customer_Account__c, Case_Type__c, Case_Sub_Type__c,
                              Case_Reason__c, Question__c, Input_Type__c
                              FROM Intake_Process__c
                              WHERE Customer_Location__c =: locationId AND Presentation_Order__c = 1 AND
                              Case_Type__c =: CaseType AND Case_Sub_Type__c =: SubType AND Case_Reason__c =: Reason
                              AND RecordType.Name = 'Intake Questions'
                              LIMIT 1];
                
                if(LocProcess.size() > 0) {
                    LocationScript = LocProcess[0];
                }
                return LocationScript;
            } else {
                LocProcess = [SELECT Id, Customer_Account__c, Case_Type__c, Case_Sub_Type__c,
                              Case_Reason__c, Question__c, Input_Type__c
                              FROM Intake_Process__c
                              WHERE Customer_Location__c =: locationId AND Presentation_Order__c = 1 AND
                              Case_Type__c =: CaseType AND Case_Sub_Type__c =: SubType AND Case_Reason__c = Null
                              AND RecordType.Name = 'Intake Questions'
                              LIMIT 1];
                
                if(LocProcess.size() > 0) {
                    LocationScript = LocProcess[0];
                }
                return LocationScript;
            }
        } catch (DmlException de) {
            return LocationScript;
        }
    }
    //Logic to Return Role Level scripting
    public static Intake_Process__c getRoleQs(string CaseType, string SubType, string Reason) {
        Intake_Process__c RoleScript = new Intake_Process__c();
        List<Intake_Process__c> RoleProcess = new List<Intake_Process__c>();
        
        String userRoleId = UserInfo.getUserRoleId();
        
        UserRole uRole = [SELECT Id, Name
                          FROM UserRole
                          WHERE Id=:userRoleId];
        
        try {
            if (Reason != 'Null') {
                RoleProcess = [SELECT Id, Customer_Account__c, Case_Type__c, Case_Sub_Type__c,
                               Case_Reason__c, Question__c, Input_Type__c, Customer_Location__c
                               FROM Intake_Process__c
                               WHERE Presentation_Order__c = 1 AND
                               Case_Type__c =: CaseType AND Case_Sub_Type__c =: SubType AND Case_Reason__c =: Reason
                               AND RecordType.Name = 'Intake Questions' AND User_Role__c =:uRole.Name
                               LIMIT 1];
                
                if(RoleProcess.size() > 0) {
                    RoleScript = RoleProcess[0];
                }
                return RoleScript;
            } else {
                RoleProcess = [SELECT Id, Customer_Account__c, Case_Type__c, Case_Sub_Type__c,
                               Case_Reason__c, Question__c, Input_Type__c, Customer_Location__c
                               FROM Intake_Process__c
                               WHERE Presentation_Order__c = 1 AND
                               Case_Type__c =: CaseType AND Case_Sub_Type__c =: SubType AND Case_Reason__c = Null
                               AND RecordType.Name = 'Intake Questions' AND User_Role__c =:uRole.Name
                               LIMIT 1];
                
                if(RoleProcess.size() > 0) {
                    RoleScript = RoleProcess[0];
                }
                return RoleScript;
            }
        } catch (DmlException de) {
            return RoleScript;
        }
    }
    //Logic to return general quesitons
    public static Intake_Process__c getGeneralQs(string CaseType, string SubType, string Reason) {
        Intake_Process__c GenScript = new Intake_Process__c();
        List<Intake_Process__c> GenProcess = new List<Intake_Process__c>();
        
        try {
            if (Reason != 'Null') {
                GenProcess = [SELECT Id, Customer_Account__c, Case_Type__c, Case_Sub_Type__c,
                              Case_Reason__c, Question__c, Input_Type__c, Customer_Location__c
                              FROM Intake_Process__c
                              WHERE Presentation_Order__c = 1 AND
                              Case_Type__c =: CaseType AND Case_Sub_Type__c =: SubType AND Case_Reason__c =: Reason
                              AND RecordType.Name = 'Intake Questions' AND User_Role__c = Null AND Customer_Account__c = Null AND
                              Customer_Location__c = Null
                              LIMIT 1];
                
                if(GenProcess.size() > 0) {
                    GenScript = GenProcess[0];
                }
                return GenScript;
            } else {
                GenProcess = [SELECT Id, Customer_Account__c, Case_Type__c, Case_Sub_Type__c,
                              Case_Reason__c, Question__c, Input_Type__c, Customer_Location__c
                              FROM Intake_Process__c
                              WHERE Presentation_Order__c = 1 AND
                              Case_Type__c =: CaseType AND Case_Sub_Type__c =: SubType AND Case_Reason__c = Null
                              AND RecordType.Name = 'Intake Questions' AND User_Role__c = Null AND Customer_Account__c = Null
                              AND Customer_Location__c = Null
                              LIMIT 1];
                
                if(GenProcess.size() > 0) {
                    GenScript = GenProcess[0];
                } else {
                    GenProcess = [SELECT Id, Customer_Account__c, Case_Type__c, Case_Sub_Type__c,
                              Case_Reason__c, Question__c, Input_Type__c, Customer_Location__c
                              FROM Intake_Process__c
                              WHERE Presentation_Order__c = 1 AND
                              Case_Type__c =: CaseType AND Case_Sub_Type__c =: SubType AND Case_Reason__c = Null
                              AND RecordType.Name = 'Intake Questions' AND User_Role__c = Null AND Customer_Account__c = Null
                              AND Customer_Location__c = Null
                              LIMIT 1];
                }
                return GenScript;
            }
        } catch (DmlException de) {
            return GenScript;
        }
    }
}