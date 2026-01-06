/*************************************************************
@Name: CaseTriggerHelper
@Author: DineshKumar S
@CreateDate: 28/08/2019
@Description: Helper Class to Perform operations on based on Business Rule
@UsedBy: CaseTriggerHandler
*************************************************************/
public without sharing class BusinessRuleHelper {
    private static Flow.Interview.Approval_Business_Rule approvalFlow {get;Set;}
	public static Map<Id,List<Service_Approver__c>> bruleSerMap = new Map<Id,List<Service_Approver__c>>();
    /*
    * This method is used to find the Business Rule for the respective case.
    * @owner : Priyadharshini R
    * @param : List<case>,set<Id>,set<Id>,set<String>.set<String>,map<Id,Asset>,map<Id,Account>
    */
    
    Public Static List<BusinessRulewrapper> businessRuleSelection(String caseId, Set<Id> recTypeIdset) {
        
        List<BusinessRulewrapper> prioritizedBusinessRules = new List<BusinessRulewrapper>();
        
        Map<String, List<Business_Rule__c>> prioritizedBusinessRuleMap = new Map<String, List<Business_Rule__c>>();
        prioritizedBusinessRuleMap = BusinessRuleUtility.getPriorityBusinessRule(caseId);
        for(String key : prioritizedBusinessRuleMap.keySet()) {
            for(Business_Rule__c b : prioritizedBusinessRuleMap.get(key)) {
                BusinessRuleWrapper brw = new BusinessRuleWrapper(caseId, b);
                prioritizedBusinessRules.add(brw);
            }
        }
        
        return prioritizedBusinessRules;
        
    }
    
    Public Static List<BusinessRulewrapper> businessRuleSelection(List<case> newcaselist,set<Id> recTypeIdset,Set<Id> accontIdSet,set<string> requestTypeSet, set<string> serviceSet,map<Id,Asset> assetmap,map<Id,Account> locationmap){
        
	List<BusinessRulewrapper> actualBusinessRulewrapper = new List<BusinessRulewrapper>();
        
        for(Case c : newCaseList) {
            List<BusinessRulewrapper> iterableRuleList = new List<BusinessRulewrapper>();
        	iterableRuleList = businessRuleSelection(c.Id, recTypeIdSet);
            actualBusinessRuleWrapper.addAll(iterableRuleList);
        }
	    
	/*
        map<string,List<Business_Rule__c>> businessRulemap = new map<string,List<Business_Rule__c>>();
        string businesskey = null;
        List<BusinessRulewrapper> actualBusinessRulewrapper = new List<BusinessRulewrapper>();
        map<string,List<Business_Rule__c>> identifybrmap = new map<string,List<Business_Rule__c>>();
	      set<Id> brRecTypeId = new set<Id>();
        for(Business_Rule__c br : [Select Id,Required_Information__c,AccountId__c,Container__c,Case_Reason__c,Material__c,LocationId__c,Service__c,Schedule_Type__c,End_Date__c,Project_Code__c,AssetId__c,Channel__c,Multiple_Mandatory_Approvers__c,Occurrence_Limit__c,Category_Type__c,Group__c,No_Approval_Required__c,RecordTypeId,Special_Instructions_Approval__c,(Select Id,Fuzzy_Search__c,Account_Team_Member__c,Business_Rule__c,RecordTypeId,Title__c,Account_Department__c,External_Approver_Email__c,External_Approver_Phone_Number__c,Account_Title__c,Approver_Type__c,Email__c,User__c,ServiceApprover__c,SortBy__c,Approver_Contact__c,Title__r.Name,Approver_Contact__r.FirstName,Approver_Contact__r.LastName,Account_Team_Member__r.FirstName,Account_Team_Member__r.LastName,User__r.FirstName,User__r.LastName,Requester_Only__c from Approver_Entities__r where Active__c = true Order BY SortBy__c,ServiceApprover__c ASC) from Business_Rule__c where AccountId__c In: accontIdSet and Active__c =: true and Effective_Date__c <=: System.Today() and RecordTypeId In: recTypeIdset and Request_Type__c In: requestTypeSet and Service__c In: serviceSet and (End_Date__c >=: System.Today() OR End_Date__c =: null) Limit 49999]){
            businesskey = br.AccountId__c + Constant_Util.STAR + br.Service__c;
            if(businessRulemap.isEmpty() || !businessRulemap.containskey(businesskey)){
                businessRulemap.put(businesskey,new List<Business_Rule__c>());
            }
            If(!businessRulemap.isEmpty() && businessRulemap.containskey(businesskey)){
                businessRulemap.get(businesskey).add(br);
            }
        }
        if(!businessRulemap.isEmpty() && businessRulemap.size() > 0){
            set<String> ruleSet = new set<String>();
            string casekey = null;
            string key = null;
            string bkey = null;
            BusinessRulewrapper brwrapper = null;
            List<Business_Rule__c> brlst = new List<Business_Rule__c>();
	    Id nscRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constant_Util.R_NEW_SERVICE_CASE).getRecordTypeId();
            for(case c : newcaselist){
                casekey = c.Client__c + Constant_Util.STAR + c.Case_Sub_Type__c;
                ruleSet.clear();
                if(businessRulemap.containsKey(casekey)){
                for(Business_Rule__c br : businessRulemap.get(casekey)){
                    //changes related to SDT-9467(Case Reason & Material addition)
                    if(string.isNotblank(br.Case_Reason__c) && string.isNotblank(c.Case_Reason__c) && c.Case_Reason__c.equals(br.Case_Reason__c)){
                        
                        bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.CASEREASON;
                        ruleset.add(Constant_Util.CASEREASON + Constant_Util.UNDERSCORE + br.RecordTypeId);
			brRecTypeId.add(br.RecordTypeId);
                        if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
                            identifybrmap.put(bkey,new List<Business_Rule__c>());
                        }
                        If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
                            identifybrmap.get(bkey).add(br);
                        }
                    }
                    else if(string.isNotblank(br.AssetId__c) && string.isNotblank(c.AssetId) && c.AssetId.equals(br.AssetId__c) && string.isNotblank(c.Location__c) && string.isNotblank(br.LocationId__c) && c.Location__c.equals(br.LocationId__c) &&  string.isBlank(br.Category_Type__c) &&  string.isBlank(br.Material__c)){
                        
                        bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.ASSET;
                        ruleset.add(Constant_Util.ASSET + Constant_Util.UNDERSCORE + br.RecordTypeId);
			brRecTypeId.add(br.RecordTypeId);
                        if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
                            identifybrmap.put(bkey,new List<Business_Rule__c>());
                        }
                        If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
                            identifybrmap.get(bkey).add(br);
                        }
                    }else if(string.isNotblank(br.Project_Code__c) && string.isNotblank(c.AssetId) && assetmap.containskey(c.AssetId) && string.isNotblank(assetmap.get(c.AssetId).Project_Code__c)&& assetmap.get(c.AssetId).Project_Code__c.equals(br.Project_Code__c) && string.isNotblank(c.Location__c) && string.isNotblank(br.LocationId__c) 
                             && c.Location__c.equals(br.LocationId__c) && string.isblank(br.AssetId__c) && string.isblank(br.Category_Type__c) &&  string.isBlank(br.Material__c)){
                                 
                                 bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.PROJECT_LOCATION;
                                 ruleset.add(Constant_Util.PROJECT_LOCATION + Constant_Util.UNDERSCORE + br.RecordTypeId);
				 brRecTypeId.add(br.RecordTypeId);
                                 if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
                                     identifybrmap.put(bkey,new List<Business_Rule__c>());
                                 }
                                 If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
                                     identifybrmap.get(bkey).add(br);
                                 }
					}else if(string.isNotblank(br.Project_Code__c) && string.isNotblank(c.AssetId) && assetmap.containskey(c.AssetId) && string.isNotblank(assetmap.get(c.AssetId).Project_Code__c)&& assetmap.get(c.AssetId).Project_Code__c.equals(br.Project_Code__c) && string.isblank(br.LocationId__c) 
							  && string.isblank(br.AssetId__c) && string.isblank(br.Category_Type__c) &&  string.isBlank(br.Material__c)){
								  
								  bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.FLOW_PROJECT;
								  ruleset.add(Constant_Util.FLOW_PROJECT + Constant_Util.UNDERSCORE + br.RecordTypeId);
								  brRecTypeId.add(br.RecordTypeId);
								  if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
									  identifybrmap.put(bkey,new List<Business_Rule__c>());
								  }
								  If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
									  identifybrmap.get(bkey).add(br);
								  }
					}else if(string.isNotblank(br.Schedule_Type__c) && string.isNotblank(br.Container__c) && string.isNotblank(br.LocationId__c) && string.isNotblank(c.AssetId) && assetmap.containskey(c.AssetId) && string.isNotblank(c.Location__c)
							   && string.isNotblank(assetmap.get(c.AssetId).Duration__c) && string.isNotblank(assetmap.get(c.AssetId).Product2.ProductTypeSelected__c) && assetmap.get(c.AssetId).Duration__c.equals(br.Schedule_Type__c) && assetmap.get(c.AssetId).Product2.ProductTypeSelected__c.equals(br.Container__c) 
							   && c.Location__c.equals(br.LocationId__c) && string.isblank(br.Project_Code__c) && string.isblank(br.AssetId__c) && string.isblank(br.Category_Type__c) &&  string.isBlank(br.Material__c)){
								   
								   bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION;
								   ruleset.add(Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION + Constant_Util.UNDERSCORE + br.RecordTypeId);
								   brRecTypeId.add(br.RecordTypeId);
								   if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
									   identifybrmap.put(bkey,new List<Business_Rule__c>());
								   }
								   If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
									   identifybrmap.get(bkey).add(br);
								   }
					}else if(string.isNotblank(br.Schedule_Type__c) && string.isblank(br.Container__c) && string.isNotblank(br.LocationId__c) && string.isNotblank(c.AssetId) && assetmap.containskey(c.AssetId) && string.isNotblank(c.Location__c)
							&& string.isNotblank(assetmap.get(c.AssetId).Duration__c) && assetmap.get(c.AssetId).Duration__c.equals(br.Schedule_Type__c) && c.Location__c.equals(br.LocationId__c) && string.isblank(br.Project_Code__c) 
							&& string.isblank(br.AssetId__c) && string.isblank(br.Category_Type__c) &&  string.isBlank(br.Material__c)){
								
								bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.SCHEDULETYPE_LOCATION;
								ruleset.add(Constant_Util.SCHEDULETYPE_LOCATION + Constant_Util.UNDERSCORE + br.RecordTypeId);
								brRecTypeId.add(br.RecordTypeId);
								if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
									identifybrmap.put(bkey,new List<Business_Rule__c>());
								}
								If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
									identifybrmap.get(bkey).add(br);
								}
					}else if(string.isblank(br.Schedule_Type__c) && string.isNotblank(br.Container__c) && string.isNotblank(br.LocationId__c) && string.isNotblank(c.AssetId) && assetmap.containskey(c.AssetId) && string.isNotblank(c.Location__c)
							 && string.isNotblank(assetmap.get(c.AssetId).Product2.ProductTypeSelected__c) && assetmap.get(c.AssetId).Product2.ProductTypeSelected__c.equals(br.Container__c) && c.Location__c.equals(br.LocationId__c) 
							 && string.isblank(br.Project_Code__c) && string.isblank(br.AssetId__c) && string.isblank(br.Category_Type__c) &&  string.isBlank(br.Material__c)){
								 
								 bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.CONTAINER_LOCATION;
								 ruleset.add(Constant_Util.CONTAINER_LOCATION + Constant_Util.UNDERSCORE + br.RecordTypeId);
								 brRecTypeId.add(br.RecordTypeId);
								 if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
									 identifybrmap.put(bkey,new List<Business_Rule__c>());
								 }
								 If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
									 identifybrmap.get(bkey).add(br);
								 }
					}else if(string.isblank(br.Schedule_Type__c) && string.isblank(br.Container__c) && string.isNotblank(br.LocationId__c) && (string.isNotblank(c.AssetId) || (string.isblank(c.AssetId) && c.RecordTypeId == nscRecordTypeId	)) && string.isNotblank(c.Location__c) && c.Location__c.equals(br.LocationId__c) 
							  && string.isblank(br.Project_Code__c) && string.isblank(br.AssetId__c) && string.isblank(br.Category_Type__c) &&  string.isBlank(br.Material__c)){
								  
								  bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.LOCATION;
								  ruleset.add(Constant_Util.LOCATION + Constant_Util.UNDERSCORE + br.RecordTypeId);
								  brRecTypeId.add(br.RecordTypeId);
								  if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
									  identifybrmap.put(bkey,new List<Business_Rule__c>());
								  }
								  If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
									  identifybrmap.get(bkey).add(br);
								  }
					}else if(string.isblank(br.Project_Code__c) && string.isblank(br.AssetId__c) && string.isblank(br.LocationId__c) && string.isNotblank(br.Category_Type__c) && !locationmap.isEmpty() && string.isNotblank(c.Location__c) && locationmap.containskey(c.Location__c) 
							   && string.isNotblank(br.Group__c) && (('Brand'.equals(br.Category_Type__c) &&  string.isBlank(br.Material__c) && br.Group__c.equals(locationmap.get(c.Location__c).Brand__c)) || ('Division/Department'.equals(br.Category_Type__c) && br.Group__c.equals(locationmap.get(c.Location__c).Division__c)) 
																	 || ('Geography'.equals(br.Category_Type__c) && br.Group__c.equals(locationmap.get(c.Location__c).Geography__c)) || ('Location Type'.equals(br.Category_Type__c) && br.Group__c.equals(locationmap.get(c.Location__c).Location_Type__c))  )){
																		 
														if(string.isNotblank(br.Schedule_Type__c) && string.isNotblank(br.Container__c) && string.isNotblank(c.AssetId) && assetmap.containskey(c.AssetId) && string.isNotblank(assetmap.get(c.AssetId).Duration__c) && string.isNotblank(assetmap.get(c.AssetId).Product2.ProductTypeSelected__c) 
															&& assetmap.get(c.AssetId).Duration__c.equals(br.Schedule_Type__c) && assetmap.get(c.AssetId).Product2.ProductTypeSelected__c.equals(br.Container__c)){
																
																bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.SCHEDULETYPE_CONTAINER_CATEGORY;
																ruleset.add(Constant_Util.SCHEDULETYPE_CONTAINER_CATEGORY + Constant_Util.UNDERSCORE + br.RecordTypeId);
																brRecTypeId.add(br.RecordTypeId);
																if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
																	identifybrmap.put(bkey,new List<Business_Rule__c>());
																}
																If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
																	identifybrmap.get(bkey).add(br);
																}
														}else if(string.isNotblank(br.Schedule_Type__c) && string.isblank(br.Container__c) && string.isNotblank(c.AssetId) && assetmap.containskey(c.AssetId) && string.isNotblank(assetmap.get(c.AssetId).Duration__c) && assetmap.get(c.AssetId).Duration__c.equals(br.Schedule_Type__c)){
															
															bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.SCHEDULETYPE_CATEGORY;
															ruleset.add(Constant_Util.SCHEDULETYPE_CATEGORY + Constant_Util.UNDERSCORE + br.RecordTypeId);
															brRecTypeId.add(br.RecordTypeId);
															if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
																identifybrmap.put(bkey,new List<Business_Rule__c>());
															}
															If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
																identifybrmap.get(bkey).add(br);
															}
														}else if(string.isNotblank(br.Container__c) && string.isblank(br.Schedule_Type__c) && string.isNotblank(c.AssetId) && assetmap.containskey(c.AssetId) && string.isNotblank(assetmap.get(c.AssetId).Product2.ProductTypeSelected__c) && assetmap.get(c.AssetId).Product2.ProductTypeSelected__c.equals(br.Container__c)){
															
															bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.CONTAINER_CATEGORY;
															ruleset.add(Constant_Util.CONTAINER_CATEGORY + Constant_Util.UNDERSCORE + br.RecordTypeId);
															brRecTypeId.add(br.RecordTypeId);
															if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
																identifybrmap.put(bkey,new List<Business_Rule__c>());
															}
															If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
																identifybrmap.get(bkey).add(br);
															}
														}else if(string.isblank(br.Container__c) && string.isblank(br.Schedule_Type__c)){
															
															bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.CATEGORY;
															ruleset.add(Constant_Util.CATEGORY + Constant_Util.UNDERSCORE + br.RecordTypeId);
															brRecTypeId.add(br.RecordTypeId);
															if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
																identifybrmap.put(bkey,new List<Business_Rule__c>());
															}
															If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
																identifybrmap.get(bkey).add(br);
															}
														}
					} else if(string.isblank(br.AssetId__c) && string.isblank(br.Project_Code__c) && string.isblank(br.LocationId__c) && string.isblank(br.Category_Type__c)){
						 
								//changes related to SDT-9467
								if(string.isNotblank(br.Schedule_Type__c) && string.isNotblank(br.Container__c) && string.isNotblank(br.Material__c) && string.isNotblank(c.AssetId) && assetmap.containskey(c.AssetId) && string.isNotblank(assetmap.get(c.AssetId).Duration__c) && string.isNotblank(assetmap.get(c.AssetId).Product2.ProductTypeSelected__c) 
									&& assetmap.get(c.AssetId).Duration__c.equals(br.Schedule_Type__c) && assetmap.get(c.AssetId).Product2.ProductTypeSelected__c.equals(br.Container__c)
									&& assetmap.get(c.AssetId).Material_Type__c.equals(br.Material__c)){
										
										bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.SCHEDULETYPE_CONTAINER_MATERIAL;
										ruleset.add(Constant_Util.SCHEDULETYPE_CONTAINER_MATERIAL + Constant_Util.UNDERSCORE + br.RecordTypeId);
										brRecTypeId.add(br.RecordTypeId);
										if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
											identifybrmap.put(bkey,new List<Business_Rule__c>());
										}
										If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
											identifybrmap.get(bkey).add(br);
										}
								}else if(string.isblank(br.Schedule_Type__c) && string.isNotblank(br.Container__c) && string.isNotblank(br.Material__c) && string.isNotblank(c.AssetId) && assetmap.containskey(c.AssetId) && string.isNotblank(assetmap.get(c.AssetId).Product2.ProductTypeSelected__c) 
											 && assetmap.get(c.AssetId).Product2.ProductTypeSelected__c.equals(br.Container__c)
											 && assetmap.get(c.AssetId).Material_Type__c.equals(br.Material__c)){
																												 
										bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.CONTAINER_MATERIAL;
										ruleset.add(Constant_Util.CONTAINER_MATERIAL + Constant_Util.UNDERSCORE + br.RecordTypeId);
										brRecTypeId.add(br.RecordTypeId);
										if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
											 identifybrmap.put(bkey,new List<Business_Rule__c>());
										}
										If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
											 identifybrmap.get(bkey).add(br);
										}
								}else if(string.isblank(br.Schedule_Type__c) && string.isblank(br.Container__c) && string.isNotblank(br.Material__c) && string.isNotblank(c.AssetId) && assetmap.containskey(c.AssetId)
											&& assetmap.get(c.AssetId).Material_Type__c.equals(br.Material__c)){
																												 
										bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.MATERIAL;
										ruleset.add(Constant_Util.MATERIAL + Constant_Util.UNDERSCORE + br.RecordTypeId);
										brRecTypeId.add(br.RecordTypeId);
										if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
											 identifybrmap.put(bkey,new List<Business_Rule__c>());
										}
										If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
											 identifybrmap.get(bkey).add(br);
										}
								}
								//End of SDT-9467
								else if(string.isNotblank(br.Schedule_Type__c) && string.isNotblank(br.Container__c) && string.isNotblank(c.AssetId) && assetmap.containskey(c.AssetId) && string.isNotblank(assetmap.get(c.AssetId).Duration__c) && string.isNotblank(assetmap.get(c.AssetId).Product2.ProductTypeSelected__c) 
										 && assetmap.get(c.AssetId).Duration__c.equals(br.Schedule_Type__c) && assetmap.get(c.AssetId).Product2.ProductTypeSelected__c.equals(br.Container__c) && string.isBlank(br.Material__c)){
											 
										bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.SCHEDULETYPE_CONTAINER;
										ruleset.add(Constant_Util.SCHEDULETYPE_CONTAINER + Constant_Util.UNDERSCORE + br.RecordTypeId);
										brRecTypeId.add(br.RecordTypeId);
										if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
											 identifybrmap.put(bkey,new List<Business_Rule__c>());
										}
										If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
											 identifybrmap.get(bkey).add(br);
										}
								}else if(string.isNotblank(br.Schedule_Type__c) && string.isblank(br.Container__c) && string.isNotblank(c.AssetId) && assetmap.containskey(c.AssetId) && string.isNotblank(assetmap.get(c.AssetId).Duration__c) && assetmap.get(c.AssetId).Duration__c.equals(br.Schedule_Type__c) && string.isBlank(br.Material__c)){
									 
										bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.SCHEDULETYPE;
										ruleset.add(Constant_Util.SCHEDULETYPE + Constant_Util.UNDERSCORE + br.RecordTypeId);
										brRecTypeId.add(br.RecordTypeId);
										if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
											 identifybrmap.put(bkey,new List<Business_Rule__c>());
										}
										If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
											 identifybrmap.get(bkey).add(br);
										}
								}else if(string.isNotblank(br.Container__c) && string.isblank(br.Schedule_Type__c) && string.isNotblank(c.AssetId) && assetmap.containskey(c.AssetId) && string.isNotblank(assetmap.get(c.AssetId).Product2.ProductTypeSelected__c) && assetmap.get(c.AssetId).Product2.ProductTypeSelected__c.equals(br.Container__c) && string.isBlank(br.Material__c)){
									 
										bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.CONTAINER;
										ruleset.add(Constant_Util.CONTAINER + Constant_Util.UNDERSCORE + br.RecordTypeId);
										brRecTypeId.add(br.RecordTypeId);
										if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
											 identifybrmap.put(bkey,new List<Business_Rule__c>());
										}
										If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
											 identifybrmap.get(bkey).add(br);
										}
								}else if(string.isblank(br.Container__c) && string.isblank(br.Schedule_Type__c) && string.isBlank(br.Material__c) && string.isBlank(br.Case_Reason__c)){
										system.debug('BRID :::'+br.Id);
                                    	system.debug('BRID :::Account');
										bkey = c.Id + Constant_Util.UNDERSCORE + br.RecordTypeId + Constant_Util.ACCOUNT;
										ruleset.add(Constant_Util.ACCOUNT + Constant_Util.UNDERSCORE + br.RecordTypeId);
										brRecTypeId.add(br.RecordTypeId);
										if(identifybrmap.isEmpty() || !identifybrmap.containskey(bkey)){
											 identifybrmap.put(bkey,new List<Business_Rule__c>());
										}
										If(!identifybrmap.isEmpty() && identifybrmap.containskey(bkey)){
											 identifybrmap.get(bkey).add(br);
										}
								}
					}
				}	
                }
				if(ruleset != null && ruleset.size() > 0){
					system.debug('Account'+ruleset);
					for(Id recType : brRecTypeId){
						
						if(ruleset.contains(Constant_Util.CASEREASON + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.CASEREASON;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}
						else if(ruleset.contains(Constant_Util.ASSET + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.ASSET;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}else if(ruleset.contains(Constant_Util.PROJECT_LOCATION + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.PROJECT_LOCATION;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}else if(ruleset.contains(Constant_Util.FLOW_PROJECT + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.FLOW_PROJECT;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}else if(ruleset.contains(Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}else if(ruleset.contains(Constant_Util.SCHEDULETYPE_LOCATION + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.SCHEDULETYPE_LOCATION;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}else if(ruleset.contains(Constant_Util.CONTAINER_LOCATION + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.CONTAINER_LOCATION;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}else if(ruleset.contains(Constant_Util.LOCATION + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.LOCATION;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}else if(ruleset.contains(Constant_Util.SCHEDULETYPE_CONTAINER_CATEGORY + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.SCHEDULETYPE_CONTAINER_CATEGORY;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}else if(ruleset.contains(Constant_Util.SCHEDULETYPE_CATEGORY + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.SCHEDULETYPE_CATEGORY;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}else if(ruleset.contains(Constant_Util.CONTAINER_CATEGORY + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.CONTAINER_CATEGORY;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}else if(ruleset.contains(Constant_Util.CATEGORY + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.CATEGORY;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}
						else if(ruleset.contains(Constant_Util.SCHEDULETYPE_CONTAINER_MATERIAL + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.SCHEDULETYPE_CONTAINER_MATERIAL;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}
						else if(ruleset.contains(Constant_Util.CONTAINER_MATERIAL + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.CONTAINER_MATERIAL;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}
						else if(ruleset.contains(Constant_Util.MATERIAL + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.MATERIAL;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}
						else if(ruleset.contains(Constant_Util.SCHEDULETYPE_CONTAINER + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.SCHEDULETYPE_CONTAINER;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}else if(ruleset.contains(Constant_Util.SCHEDULETYPE + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.SCHEDULETYPE;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}else if(ruleset.contains(Constant_Util.CONTAINER + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.CONTAINER;
							brlst = identifybrmap.get(key);
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}else if(ruleset.contains(Constant_Util.ACCOUNT + Constant_Util.UNDERSCORE + recType)){
							key = c.Id + Constant_Util.UNDERSCORE + recType + Constant_Util.ACCOUNT;
							brlst = identifybrmap.get(key);
                            system.debug('Account');
							if(brlst != null && brlst.size() > 0){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[0]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							if(brlst != null && brlst.size() > 1){
								brwrapper = new BusinessRulewrapper(c.Id,brlst[1]);
								actualBusinessRulewrapper.add(brwrapper);
							}
							continue;
						}
					}
				}
            }
        }*/
        return actualBusinessRulewrapper;
	// */
    }
    /*
    * This method is used to find the Approval Business Rule for the respective case and get the Approval Logs to be inserted.
    * @owner : DineshKumar S
    * @param : map<Id,Business_Rule__c>,List<case>
    */
    Public Static wrapperResult getapprovallog(map<Id,Business_Rule__c> businessRulemap,List<case> newcaselist,Map<String,Integer> caseWorkOrderCount){
        
        map<Id,List<Approval_Log__c>> approvalLogMap = new map<Id,List<Approval_Log__c>>();
        map<Id,Boolean> autoApprovalmap = new map<Id,Boolean>();
        map<Id,Boolean> ruleMatchedmap = new map<Id,Boolean>();
        map<Id,Boolean> occurenceLimitmap = new map<Id,Boolean>();
        wrapperResult wrapper = null;
        
        if(businessRulemap != null && businessRulemap.size() > 0 && newCaseList != null && newCaseList.Size() > 0){
            map<Id,String> conSamap = new map<Id,String>();
            Business_Rule__c bRule = null;
            List<Approval_Log__c> approvalLst = new List<Approval_Log__c>();
            string conSa = null;
            List<Approval_Log__c> allApprovallog = new List<Approval_Log__c>();
            List<Approval_Log__c> approvalLoglst;
            for(Case ca : newCaseList){
                bRule = businessRulemap.Containskey(ca.Id) && businessRulemap.get(ca.Id) != null ? businessRulemap.get(ca.Id) : null;
                if(bRule != null){
                map<String, Object> flowInputMap = new map<String, Object>();
                flowInputMap.put(Constant_Util.FLOW_CONTACTID , ca.ContactId);
                flowInputMap.put(Constant_Util.FLOW_TITLE , ca.Contact_Title__c);
                flowInputMap.put(Constant_Util.FLOW_OBTAINEDBR , bRule);
                flowInputMap.put(Constant_Util.VARCASEREC , ca);
                flowInputMap.put(Constant_Util.VARWOCOUNT , caseWorkOrderCount != null && string.IsNotBlank(String.Valueof(ca.AssetId)) && string.IsNotBlank(String.Valueof(ca.Location__c)) && string.IsNotBlank(String.Valueof(ca.Case_Sub_type__c)) && caseWorkOrderCount.containsKey(String.Valueof(ca.AssetId)+String.Valueof(ca.Location__c) + string.valueOf(ca.Case_Sub_type__c)) ? caseWorkOrderCount.get(String.Valueof(ca.AssetId)+String.Valueof(ca.Location__c)+ string.valueOf(ca.Case_Sub_type__c)) : 0);
                if(bruleSerMap.containsKey(bRule.Id))
                {
                  flowInputMap.put(Constant_Util.FLOW_SERVICEAPPROVERSLST, bruleSerMap.get(bRule.Id));  
                }
                else
                {
                   flowInputMap.put(Constant_Util.FLOW_SERVICEAPPROVERSLST, (List<Service_Approver__c>) bRule.Approver_Entities__r); 
                }
                approvalFlow = new Flow.Interview.Approval_Business_Rule(flowInputMap);
                approvalFlow.Start();
                approvalLoglst = new List<Approval_Log__c>();
                approvalLoglst = (List<Approval_Log__c>)(approvalFlow.getVariableValue(Constant_Util.FLOW_APPROVALLOGLST));
                autoApprovalmap.put(ca.Id,(Boolean)(approvalFlow.getVariableValue(Constant_Util.FLOW_ISAUTOAPPROVED)));
                ruleMatchedmap.put(ca.Id,(Boolean)(approvalFlow.getVariableValue(Constant_Util.FLOW_RULEMATCHED)));
                occurenceLimitmap.put(ca.Id,(Boolean)(approvalFlow.getVariableValue(Constant_Util.VAROCCURRENCELIMIT)));
                conSa = (String)(approvalFlow.getVariableValue(Constant_Util.FLOW_SERVICE_APPROVERS));
                if(conSa != null){
                    conSamap.put(ca.Id,conSa);
                }
                if(approvalLoglst != null && approvalLoglst.size() > 0){
                    allApprovallog.addAll(approvalLoglst);
                }
            }
            }
            
            if(allApprovallog != null && !allApprovallog.IsEmpty() && allApprovallog.size() > 0){ //Added null check for SDT-6633.
                for(Approval_Log__c al : allApprovallog){
                    //al.Service_Approvers__c = conSamap != null && conSamap.containskey(al.CaseId__c) ? conSamap.get(al.CaseId__c) : null;
                    al.ServiceApprovers__c = conSamap != null && conSamap.containskey(al.CaseId__c) ? conSamap.get(al.CaseId__c) : null;
                    al.Status__c = String.valueof(al.Status__c); //need to convert Picklist Type to String as values are returned from Flow.
                    if(approvalLogmap.isEmpty() || (!approvalLogmap.isEmpty() && !approvalLogmap.containskey(al.CaseId__c))){
                        approvalLogmap.put(al.CaseId__c, new List<Approval_Log__c>());
                    }
                    approvalLogmap.get(al.CaseId__c).add(al);
                }
            }
            
            
            wrapper = new wrapperResult(approvalLogmap,autoApprovalmap,ruleMatchedmap,occurenceLimitmap);
        }
        
        return wrapper;
    }
    /*
    * This class is used to return Approval Log case info respective to the case.
    * @owner : DineshKumar S
    */
    Public class wrapperResult {
        Public map<Id,List<Approval_Log__c>> apprLogMap {get;set;}
        Public map<Id,Boolean> autoApprovemap {get;set;}
        public map<Id,Boolean> rulematchedmap {get;set;}
        public map<Id,Boolean> occurenceLimitmap {get;set;}
        public wrapperResult(map<Id,List<Approval_Log__c>> approvalLogmap,map<Id,Boolean> autoApprovalmap,map<Id,Boolean> brmatchedmap,map<Id,Boolean> occlimitmap){
            this.apprLogMap = approvalLogmap;
            this.autoApprovemap = autoApprovalmap;
            this.rulematchedmap = brmatchedmap;
            this.occurenceLimitmap = occlimitmap;
        }
        
    }
    /*
    * This class is used to return Business Rule respective to the case.
    * @owner : DineshKumar S
    */
    public class BusinessRulewrapper {
        public Id caseId {get;set;}
        public Business_Rule__c bRule {get;set;}
        public BusinessRulewrapper(Id cId, Business_Rule__c br) {
            this.caseId = cId;
            this.bRule = br;
        }
    }
    
}
