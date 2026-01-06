/*
Author: Rishiraj Singh
Requirement Id/Story:
FC: Pankaj Kakkar
Module: Asset Management/Work Order
--------------------------------------------------------------------
Description: Controller class, use to get Parent quoteline products, create, validate and Get Quote orders. Class is used by quoteOrderComp LWC.
*/

public with sharing class WorkOrderController {
    
    //get Parent quoteline products- Old Method- Commenting as a part of SDT-20939
    /*@AuraEnabled(cacheable=false)
    public static String getQuoteLineParentProducts(String quoteId){
        try{ 
            Map<String,Id> getQuoteLineIdWithKey = new Map<String,Id>();  
            string wasteStream = 'Waste Stream';
            List<SBQQ__QuoteLine__c> wasteStreamTypeQLList = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Product__r.ProductCode, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c  
                                                 FROM SBQQ__QuoteLine__c 
                                                 WHERE SBQQ__Product__r.Family =: wasteStream 
                                                 AND SBQQ__Quote__c =: quoteId];
            Map<Id,String> qlMaterialCodeMap= new Map<Id,String>();
            for(SBQQ__QuoteLine__c qlObj: wasteStreamTypeQLList){
                qlMaterialCodeMap.put(qlObj.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, qlObj.SBQQ__Product__r.ProductCode);
            }
            String query = 'Select Id, SBQQ__Quote__c, Name, Equipment_Size__c,SBQQ__EffectiveStartDate__c,SBQQ__EndDate__c, Duration__c, Material_Type__c, SBQQ__Product__r.Name From SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteId and Bypass_Acorn_Integration__c = false and SBQQ__ProductOption__r.SBQQ__Feature__r.Name !=:wasteStream and SBQQ__RequiredBy__c = null  Order BY SBQQ__RequiredBy__c';
            for(SBQQ__QuoteLine__c qlObj : Database.query(query)) {
                String productName = (String.isNotBlank(qlObj.SBQQ__Product__r.Name)) ? qlObj.SBQQ__Product__r.Name : '';
                String equipmentSize = (String.isNotBlank(qlObj.Equipment_Size__c)) ? '-' + qlObj.Equipment_Size__c : '';
                String duration = (String.isNotBlank(qlObj.Duration__c)) ? '-' + qlObj.Duration__c : '';
                String materialType='';
                if(qlMaterialCodeMap.containsKey(qlObj.Id)){
                    materialType = (String.isNotBlank(qlMaterialCodeMap.get(qlObj.Id))) ? '-' + qlMaterialCodeMap.get(qlObj.Id) : '';
                }
                //String materialType = (String.isNotBlank(qlObj.Material_Type__c)) ? '-' + qlObj.Material_Type__c : '';
                String key = qlObj.Name+ '_' +productName + equipmentSize + duration + materialType ;
             //   System.debug('Key>>>'+key);
                if(!getQuoteLineIdWithKey.containskey(key)){
                    getQuoteLineIdWithKey.put(key,qlObj.id);
                }
            }     
            return JSON.serialize(getQuoteLineIdWithKey); 
        }
        catch(Exception ex){
            //System.debug('>>>Exception--->'+ex.getMessage() + 'At Line Number--->'+ex.getLineNumber());
        }
        return Null; 
    }*/
    
    // Changes for SDT-31593
    // Private variable
    public static set<string> serviceTypeSet = new set<string>{'Container Exchange', 'Contaminated Pickup', 'Dig Out Service','Power Wash', 'Onsite Relocation', 'Onsite Relocation', 'Equipment Installation', 'Product Order', 'Dry Run', 'Site Survey'};	//TCS-pkulkarn-SDT-32097-Added 'Product Order', 'Dry Run', 'Site Survey'

    /* Dev: Rishiraj Singh 
     * Requirement Id/Story: SDT-20939/SDT-20937 
     * FC: Anmoal/Rajat
     * Module: Asset Management/Work Order
     */
    @AuraEnabled(cacheable=false)
    public static String getQuoteLineParentProductsNew(String quoteLineId, String userId){
        try{ 
            User userObj = [SELECT ID, UserRole.Name FROM User WHERE ID =: userId LIMIT 1];
            //SDT-29723 - Added equipmentSizeLabel,SBQQ__Quote__r.Case_Type__c to SOQL for Asset availability 
                        //SDT-32136 - Added Vendor_Commit_Date__c,Quote_SLA_Date__c to SOQL to bring it in product order screen
            List<SBQQ__QuoteLine__c> qLineList= [SELECT Id, SBQQ__Quote__c, Name,SBQQ__Quote__r.Case_Type__c,toLabel(Equipment_Size__c) equipmentSizeLabel, Equipment_Size__c,SBQQ__EffectiveStartDate__c,SBQQ__StartDate__c, SBQQ__EndDate__c, Duration__c, Material_Type__c, SBQQ__Product__r.Name,SBQQ__Product__r.ProductCode, LocationPositionName__c,Occurrence_Type__c, SBQQ__ProductName__c,Vendor_Commit_Date__c, Quote_SLA_Date__c FROM SBQQ__QuoteLine__c WHERE Id =:quoteLineId OR SBQQ__RequiredBy__c=:quoteLineId ORDER BY SBQQ__RequiredBy__c ASC NULLS FIRST];
            String productName='';
			String equipmentSize='';
			String duration='';
			String key='';
			SBQQ__QuoteLine__c deliveryQLine;
			SelectedProductWrapper spwObj= new SelectedProductWrapper();
			if(!qLineList.isEmpty()){
                //System.debug('Key>>>');
				productName = (String.isNotBlank(qLineList[0].SBQQ__Product__r.Name)) ? qLineList[0].SBQQ__Product__r.Name : '';
				equipmentSize = (String.isNotBlank(qLineList[0].Equipment_Size__c)) ? '-' + qLineList[0].Equipment_Size__c : '';
				duration = (String.isNotBlank(qLineList[0].Duration__c)) ? '-' + qLineList[0].Duration__c : '';
				//String materialType=(String.isNotBlank(qLineObj.SBQQ__Product__r.ProductCode)) ? '-' + qLineObj.SBQQ__Product__r.ProductCode : '';
				key = productName + equipmentSize + duration /*+ materialType */;
				System.debug('Key>>>'+key);
				for(SBQQ__QuoteLine__c qlObj: qLineList){
					if(qlObj.SBQQ__ProductName__c.equalsIgnoreCase('Delivery')){
						deliveryQLine = qlObj;
                        //System.debug('deliveryQLine>>>'+JSON.serialize(deliveryQLine));
						break;
					}
				}
				Boolean isDlvEligible= false;
				Boolean isDlv= false;
                if(deliveryQLine!=Null){
                    List<QOServiceProductCombination__mdt> QOSerProdFilterList= [SELECT Id, Service__c,Primary_Component__c,IsExtraPickup__c,Occurrence_Type__c,Duration__c,Case_Type__c,Case_Sub_Type__c,PO_Mandatory_Scenario__c FROM QOServiceProductCombination__mdt WHERE Service__c='Delivery' AND ServiceProdFilter__c= true];
                    for(QOServiceProductCombination__mdt qoMdtObj: QOSerProdFilterList){
                        if(qoMdtObj.Occurrence_Type__c.equalsIgnoreCase(deliveryQLine.Occurrence_Type__c) && qoMdtObj.Duration__c.equalsIgnoreCase(deliveryQLine.Duration__c)){
                            //System.debug('isDlvEligible>>>');
                            isDlvEligible= true;
                            break;
                        }
                    }
                }
				if(deliveryQLine!=Null && isDlvEligible){
                    //System.debug('Check QO>>>');
					List<Quote_Order__c> qoList=[SELECT Id FROM Quote_Order__c WHERE Service_Quote_Line__c=:deliveryQLine.Id];
					if(qoList.isEmpty()){
						isDlv= true;
					}else{
						isDlv= false;
					}
				}
				spwObj.selectedProd= key;
                if(isDlv){
                    spwObj.startDate= deliveryQLine.SBQQ__StartDate__c;
                }
                spwObj.isDelivery= isDlv;
                spwObj.bundleStartDate= qLineList[0].SBQQ__StartDate__c;
                spwObj.bundleEndDate= qLineList[0].SBQQ__EndDate__c;
                spwObj.isCSR = (userObj.UserRole != null && userObj.UserRole.Name.containsIgnoreCase('Customer Experience'))? true : false;
                spwObj.locPos = (qLineList[0].LocationPositionName__c != null) ? qLineList[0].LocationPositionName__c : ''; 
                Object equipmentSizeLabel = qLineList[0].get('equipmentSizeLabel'); //SDT-29723 - for Asset Availablity
                spwObj.equipmentSize = equipmentSizeLabel!=null ? equipmentSizeLabel.toString() : ''; //SDT-29723 - for Asset Availablity
                spwObj.caseRecordType = qLineList[0].SBQQ__Quote__r.Case_Type__c ;//SDT-29723
spwObj.VendorCommitDate = qLineList[0].Vendor_Commit_Date__c; //SDT-32136
                spwObj.CustomerRequestDate= qLineList[0].Quote_SLA_Date__c; //SDT-32136   
                //System.debug('spwObj>>>'+JSON.serialize(spwObj));
			}
			return JSON.serialize(spwObj);
        }
        catch(Exception ex){
            System.debug('>>>Exception--->'+ex.getMessage() + 'At Line Number--->'+ex.getLineNumber());
        }
        return Null; 
    }

    //get quoteline product options/comp name
    @AuraEnabled(cacheable=false)
    public static String quoteLineFeatureProductOptionsNew(String quoteId, String selQuoteProd, String serviceTypeList){
        try{
        //    System.debug('quoteId>>>'+quoteId);
        //    System.debug('selQuoteProd>>>'+selQuoteProd);
        //    System.debug('serviceTypeList>>>'+serviceTypeList);            
            ServiceTypeWrapper serviceTypeWrapperObj= (ServiceTypeWrapper) JSON.deserialize('{"serviceTypeList" :'+serviceTypeList+'}',ServiceTypeWrapper.class);
            List<string> serviceTypeOptionsList= serviceTypeWrapperObj.serviceTypeList;
        //    System.debug('serviceTypeOptionsList>>>'+serviceTypeOptionsList);
            // Changes for SDT-30118
            List<SBQQ__QuoteLine__c> filteredBundleQuoteLineList = new List<SBQQ__QuoteLine__c>();
            Set<Id> surChargeIds = new Set<Id>();
            List<SBQQ__QuoteLine__c> quoteLineList = [SELECT id,SBQQ__Quote__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Product__r.name,SBQQ__Product__c,Occurrence_Type__c,Duration__c,IsExtraPickup__c, SBQQ__Product__r.Family, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId order by SBQQ__Number__c];
            // Changes for filter bundle Product
            for(SBQQ__QuoteLine__c ql: quoteLineList)
            {
                if(ql.SBQQ__RequiredBy__c == selQuoteProd)
                {
                    filteredBundleQuoteLineList.add(ql);
                    // Checking for Surcharge and Fee and adding in surcharge list
                    if(ql.SBQQ__Product__r.Family == PricingJSONRequest.SURCHARGES_AND_FEES)
                    {
                        surChargeIds.add(ql.Id);
                    }
                }
                // Adding Keys in filtered bundle QuoteLineList
                if(surChargeIds.contains(ql.SBQQ__RequiredBy__c))
                {
                    filteredBundleQuoteLineList.add(ql);
                }
            }
            
            List<QOServiceProductCombination__mdt> QOSerProdFilterList= [SELECT Id, Service__c,Primary_Component__c,IsExtraPickup__c,Occurrence_Type__c,Duration__c,Case_Type__c,Case_Sub_Type__c,PO_Mandatory_Scenario__c FROM QOServiceProductCombination__mdt WHERE Service__c IN: serviceTypeOptionsList AND ServiceProdFilter__c= true];
            SBQQ__Quote__c quoteRecord= [SELECT PO_Mandatory__c FROM SBQQ__Quote__c WHERE Id=: quoteId];
            List<String> poList = new List<String>();
            if(quoteRecord.PO_Mandatory__c!=null){
                poList.addAll(quoteRecord.PO_Mandatory__c.split(';'));
          //      System.debug('poList>>'+poList);
            }
            //List<PO_Mandatory_Mapping__mdt> POMandatoryFilterList= [SELECT Id,Scenario__c,Case_Type__c,Case_Sub_Type__c FROM PO_Mandatory_Mapping__mdt WHERE Active__c=true AND Scenario__c IN: poList];
          //  System.debug('quoteLineList'+quoteLineList);
          //  System.debug('QOSerProdFilterList>>>'+QOSerProdFilterList);
            Map<String,List<QOServiceProductCombination__mdt>> qoFilterMap= new Map<String,List<QOServiceProductCombination__mdt>>();
            for(QOServiceProductCombination__mdt qoSPObj: QOSerProdFilterList){
                
                if(qoFilterMap.containsKey(qoSPObj.Service__c)){
                    List<QOServiceProductCombination__mdt> qoSPList = qoFilterMap.get(qoSPObj.Service__c);
                    qoSPList.add(qoSPObj);
                    qoFilterMap.put(qoSPObj.Service__c,qoSPList);//servicetype and list of metadata map 
                } else {
                    List<QOServiceProductCombination__mdt> qoSPList= new List<QOServiceProductCombination__mdt>();
                    qoSPList.add(qoSPObj);
                    qoFilterMap.put(qoSPObj.Service__c,qoSPList); //servicetype and list of metadata map 
                }
            }
         //   System.debug('qoFilterMap>>>'+qoFilterMap);
            List<QuoteLineProductOptionsWrapper> quoteLinePOWrapperList= new List<QuoteLineProductOptionsWrapper>();
            if(filteredBundleQuoteLineList != null && !filteredBundleQuoteLineList.isEmpty()){
                for(SBQQ__QuoteLine__c qLine : filteredBundleQuoteLineList){ 
                    for(String serviceTypeObj: serviceTypeOptionsList){
                        if(qoFilterMap.containsKey(serviceTypeObj)){
                            for(QOServiceProductCombination__mdt filterObj:qoFilterMap.get(serviceTypeObj)){
                        /*        System.debug('qLine.SBQQ__Product__r.name>>>'+qLine.SBQQ__Product__r.name);
                                System.debug('qLine.Occurrence_Type__c>>>'+qLine.Occurrence_Type__c);
                                System.debug('qLine.Duration__c>>>'+qLine.Duration__c);
                                System.debug('filterObj.Primary_Component__c>>>'+filterObj.Primary_Component__c);
                                System.debug('filterObj.Occurrence_Type__c>>>'+filterObj.Occurrence_Type__c);
                                System.debug('filterObj.Duration__c>>>'+filterObj.Duration__c);
                                System.debug('filterObj.IsExtraPickup__c>>>'+filterObj.IsExtraPickup__c);
                                System.debug('filterObj.PO_Mandatory_Scenario__c>>>'+filterObj.PO_Mandatory_Scenario__c);*/
                                if(filterObj.Primary_Component__c.equalsIgnoreCase(qLine.SBQQ__Product__r.name) && filterObj.Occurrence_Type__c.equalsIgnoreCase(qLine.Occurrence_Type__c) && filterObj.Duration__c.equalsIgnoreCase(qLine.Duration__c)){
                               //     System.debug('inside>>>');
                                    QuoteLineProductOptionsWrapper quoteLinePOObj= new QuoteLineProductOptionsWrapper();
                                    quoteLinePOObj.quoteLineProdOptionsMap= new Map<String,String>();
                                    quoteLinePOObj.quoteLineProdOptionsMap.put(qLine.id,qLine.SBQQ__Product__r.name);
                                    quoteLinePOObj.quoteLineProductName = qLine.SBQQ__Product__r.name;
                                    quoteLinePOObj.quoteLineId = qLine.id;
                                    quoteLinePOObj.occurenceType = qLine.Occurrence_Type__c;
                                    quoteLinePOObj.duration = qLine.Duration__c;
                                    quoteLinePOObj.serviceType = serviceTypeObj;
                                    if(qLine.SBQQ__StartDate__c != null){
                                        quoteLinePOObj.serviceLineStartDate = qLine.SBQQ__StartDate__c;
                                    }
                                    if(qline.SBQQ__EndDate__c != null){
                                        quoteLinePOObj.serviceLineEndDate = qline.SBQQ__EndDate__c;
                                    }
                                    if(!poList.isEmpty() && poList.contains(filterObj.PO_Mandatory_Scenario__c)){
                                        quoteLinePOObj.poFlag= true;
                                    } else{
                                        quoteLinePOObj.poFlag= false;
                                    }
                                    quoteLinePOWrapperList.add(quoteLinePOObj);
                                }
                                /*else if(filterObj.Primary_Component__c.equalsIgnoreCase(qLine.SBQQ__Product__r.name) && filterObj.Occurrence_Type__c.equalsIgnoreCase(qLine.Occurrence_Type__c) && filterObj.Duration__c.equalsIgnoreCase(qLine.Duration__c) && filterObj.IsExtraPickup__c && qLine.IsExtraPickup__c){
                                 //   System.debug('inside>2>>');
                                    QuoteLineProductOptionsWrapper quoteLinePOObj= new QuoteLineProductOptionsWrapper();
                                    quoteLinePOObj.quoteLineProdOptionsMap= new Map<String,String>();
                                    quoteLinePOObj.quoteLineProdOptionsMap.put(qLine.id,qLine.SBQQ__Product__r.name);
                                    quoteLinePOObj.quoteLineProductName = qLine.SBQQ__Product__r.name;
                                    quoteLinePOObj.quoteLineId = qLine.id;
                                    quoteLinePOObj.occurenceType = qLine.Occurrence_Type__c;
                                    quoteLinePOObj.duration = qLine.Duration__c;
                                    quoteLinePOObj.serviceType = serviceTypeObj;
                                    if(qLine.SBQQ__StartDate__c != null){
                                        quoteLinePOObj.serviceLineStartDate = qLine.SBQQ__StartDate__c;
                                    }
                                    if(qline.SBQQ__EndDate__c != null){
                                        quoteLinePOObj.serviceLineEndDate = qline.SBQQ__EndDate__c;
                                    }
                                    if(!poList.isEmpty() && poList.contains(filterObj.PO_Mandatory_Scenario__c)){
                                        quoteLinePOObj.poFlag= true;
                                    } else{
                                        quoteLinePOObj.poFlag= false;
                                    }
                                    quoteLinePOWrapperList.add(quoteLinePOObj);
                                }*/
                            }
                        }
                    }
                }
            }
            return JSON.serialize(quoteLinePOWrapperList);
        }catch(Exception ex){
          //  System.debug('>>>Exception--->'+ex.getMessage() + 'At Line Number--->'+ex.getLineNumber());
        }   
        
        return Null;
    }

    
    //Get Quote orders
    @AuraEnabled(cacheable=false)
    public static String getQuoteOrdersByQuoteLine(String selectedQuoteLine, Boolean isCSR) {
      //  System.debug('>>>selectedQuoteLine'+selectedQuoteLine);
        try{
            List<QuoteOrderWrapper> quoteOrderWrapList = new List<QuoteOrderWrapper>();
            List<Quote_Order__c> quoteOrderList = [SELECT Id, Quote_Line__c, Service_Type__c, Service_Quote_Line__c,Service_Quote_Line__r.SBQQ__StartDate__c,Service_Quote_Line__r.SBQQ__EndDate__c,
                                                  Product_Type__c, Service_Date__c, Service_Time_Span__c,Onsite_Contact__c,Onsite_Contact_Phone__c, Instructions__c, Cust_Ref_Number__c, Occurrence_Type__c, Duration__c, Bypass_Work_Order__c
                                                  FROM Quote_Order__c 
                                                  WHERE Quote_Line__c =: selectedQuoteLine ORDER BY LastModifiedDate DESC];
                                                  
       //     System.debug('>>>quoteOrderList'+quoteOrderList);
            if(quoteOrderList != Null && !quoteOrderList.isEmpty()){
                for(Quote_Order__c qOObj : quoteOrderList){
                    QuoteOrderWrapper quoteOrderWrapObj = new QuoteOrderWrapper();
                    if(qOObj.Quote_Line__c != null){
                        quoteOrderWrapObj.quoteLineParentId = qOObj.Quote_Line__c;
                    }
                    if(qOObj.Id != null){
                        quoteOrderWrapObj.idField = qOObj.Id;
                        quoteOrderWrapObj.actionType= 'noChange';
                    }
                    if(qOObj.Service_Quote_Line__c!=null){
                        quoteOrderWrapObj.quoteLineId = qOObj.Service_Quote_Line__c;
                    }
                    if(qOObj.Service_Type__c != null){
                        quoteOrderWrapObj.serviceType = qOObj.Service_Type__c;
                        quoteOrderWrapObj.disableDelete = (qOObj.Service_Type__c == 'Delivery' && isCSR) ? true : false;
                    }
                    if(qOObj.Product_Type__c != null){
                        quoteOrderWrapObj.productType = qOObj.Product_Type__c;
                    }
                    if(qOObj.Service_Date__c != null){
                        quoteOrderWrapObj.serviceDate = String.valueOf(qOObj.Service_Date__c);
                    }
                    if(qOObj.Service_Time_Span__c != null){
                        quoteOrderWrapObj.serviceTime = qOObj.Service_Time_Span__c;
                    }
                    //SDT-20938, populating the contact fields on UI.
                    if(qOObj.Onsite_Contact__c != null){
                        quoteOrderWrapObj.contact = qOObj.Onsite_Contact__c;
                    }
                    //SDT-20938, populating the Phone fields on UI.
                    if(qOObj.Onsite_Contact_Phone__c != null){
                        quoteOrderWrapObj.phone = qOObj.Onsite_Contact_Phone__c;
                    }
                    //SDT-20938, populating the Instruction fields on UI.
                    if(qOObj.Instructions__c != null){
                        quoteOrderWrapObj.instruction = qOObj.Instructions__c;
                    }
                    if(qOObj.Cust_Ref_Number__c != null){
                        quoteOrderWrapObj.custRefNumber = qOObj.Cust_Ref_Number__c;
                    }
                    if(qOObj.Duration__c != null){
                        quoteOrderWrapObj.duration = qOObj.Duration__c;
                    }
                    if(qOObj.Occurrence_Type__c != null){
                        quoteOrderWrapObj.occurenceType = qOObj.Occurrence_Type__c;
                    }
                    if(qOObj.Service_Quote_Line__r.SBQQ__StartDate__c != null){
                        quoteOrderWrapObj.serviceLineStartDate = qOObj.Service_Quote_Line__r.SBQQ__StartDate__c;
                    }
                    if(qOObj.Service_Quote_Line__r.SBQQ__EndDate__c != null){
                        quoteOrderWrapObj.serviceLineEndDate = qOObj.Service_Quote_Line__r.SBQQ__EndDate__c;
                    }
                    quoteOrderWrapObj.bypassWorkOrder = qOObj.Bypass_Work_Order__c;
                    quoteOrderWrapList.add(quoteOrderWrapObj); 
                }
                return JSON.serialize(quoteOrderWrapList); 
            }                                      
        }
        catch(Exception ex){
          //  System.debug('>>>Exception--->'+ex.getMessage() + 'At Line Number--->'+ex.getLineNumber());
        }
        return Null;
    }

    @AuraEnabled(cacheable=false)
    public static String deleteQuoteLineOrders(String quoteId){

        Quote_Order__c qoToDelete = new Quote_Order__c();
        qoToDelete.id= Id.valueOf(quoteId);
        try{
            delete qoToDelete;
            return 'success';
        }catch(Exception e){
            return 'error';
        }
    }

    // create,update,delete quote orders.
    @AuraEnabled(cacheable=false)
    public static String actionsOnQuoteLineOrders(String quoteId, String selQuoteProd, Date bundleStartDate, Date bundleEndDate,Date vendorDate, String quoteOrderListStr ,AssetAvailabilityWrapper assetAvailabilityWrapper){   //SDT-32136 added vendor commit date  as input param
     //   System.debug('quoteId>>>'+quoteId);
     //   System.debug('selQuoteProd>>>'+selQuoteProd);
     //   System.debug('quoteOrderListStr>>>'+quoteOrderListStr);
        Map<Id, String> qlIdOccurenceTypeMap= new Map<Id, String>();
        Map<Id, String> qlIdDurationMap= new Map<Id, String>();
        // Changes for SDT-30118
        List<SBQQ__QuoteLine__c> removalQuoteLinesToDelete = new List<SBQQ__QuoteLine__c>(); 
        //Changes for SDT-38985 - check if  the parent quoteline is eligible for end date update.
        Boolean updateEndDate = false;
        //SDT-32136 added Vendor_Commit_Date__c in soql query
        //Changes related to SDT-38985 - adding SBQQ__Quote__r.Case_record_Type__c,SBQQ__Quote__r.Case_Sub_Type__c to query
        List<SBQQ__QuoteLine__c> allQuoteLineList = [SELECT id,SBQQ__Quote__c,SBQQ__StartDate__c,SBQQ__EndDate__c,Vendor_Commit_Date__c,SBQQ__Product__r.name,SBQQ__Product__c,Occurrence_Type__c,Duration__c,IsExtraPickup__c,SBQQ__RequiredBy__c,SBQQ__Quote__r.Case_record_Type__c,SBQQ__Quote__r.Case_Sub_Type__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND (Id=:selQuoteProd OR SBQQ__RequiredBy__c=:selQuoteProd OR SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =:selQuoteProd)];
        List<SBQQ__QuoteLine__c> toUpdateQuoteLinesList = new List<SBQQ__QuoteLine__c>();
        //Check if end date is populated in parent QuoteLine
        for(SBQQ__QuoteLine__c qlObj: allQuoteLineList){
            if(qlObj.Id == selQuoteProd && qlObj.SBQQ__EndDate__c !=null &&qlObj.SBQQ__Quote__r.Case_record_Type__c !=null && qlObj.SBQQ__Quote__r.Case_record_Type__c =='New Service Case' &&qlObj.SBQQ__Quote__r.Case_Sub_Type__c  != null && qlObj.SBQQ__Quote__r.Case_Sub_Type__c =='Temporary'){
                updateEndDate = true;
                break;
            }
        }
        for(SBQQ__QuoteLine__c qlObj: allQuoteLineList){
            //Changes related to SDT-38985
            If(bundleEndDate !=null && updateEndDate){
		    //TCS-pkulkarn-SDT-33156-Commented following code block to stop the update of Start Date and End Date (on all quote lines) from Product Order (Work Order) component
                if(qlObj.SBQQ__Product__r.name == 'Removal'){
                qlObj.SBQQ__StartDate__c = bundleEndDate;
                qlObj.SBQQ__EndDate__c = bundleEndDate;
          
                }else if(qlObj.SBQQ__Product__r.name == 'Delivery'){
                qlObj.SBQQ__StartDate__c = bundleStartDate;
                qlObj.SBQQ__EndDate__c = bundleStartDate;
                }
                else{
                    qlObj.SBQQ__StartDate__c = bundleStartDate;
                    qlObj.SBQQ__EndDate__c = bundleEndDate; 
                }
                
            }
            
			//SDT-33156-End
            //SDT-32136
            if(qlObj.SBQQ__RequiredBy__c == null){
                qlObj.Vendor_Commit_Date__c = vendorDate; 
            }
            //SDT-29723 : START :Update Asset Availability field
            if(assetAvailabilityWrapper.assetAvailability==true && qlObj.SBQQ__RequiredBy__c==null){
                qlObj.AAV_Delivery_Availability__c =assetAvailabilityWrapper.deliveryAvailability;
            }
            //SDT-29723 : END        
            toUpdateQuoteLinesList.add(qlObj);
            if(qlObj.SBQQ__RequiredBy__c == selQuoteProd){
                qlIdOccurenceTypeMap.put(qlObj.id,qlObj.Occurrence_Type__c);
                qlIdDurationMap.put(qlObj.id,qlObj.Duration__c);
            }
        }
        List<Quote_Order__c> quoteLineOrderListToUpsert = new List<Quote_Order__c>();
        //List<Quote_Order__c> quoteLineOrderListToDelete = new List<Quote_Order__c>();
        if(quoteOrderListStr != null) {
            QuoteLineWrapper objQuoteLineWrapper = (QuoteLineWrapper)JSON.deserialize('{"quoteOrder" :'+quoteOrderListStr+'}',QuoteLineWrapper.class);
            List<QuoteOrderWrapper> quoteLineOrderList = objQuoteLineWrapper.quoteOrder;
            //SDT-20938, declaring below variables for the new Contact, phone and location position fields.
            String OnsiteContact ='';
            String OnsitePhone ='';
            String Position ='';
          //  System.debug('>>>objQuoteLineWrapper'+objQuoteLineWrapper); 
          //  System.debug('>>>quoteLineOrderList'+quoteLineOrderList);
            List<Id> quoteIdToUpdate = new List<Id>();
            //List<Id> quoteIdToDelete = new List<Id>();
            if(quoteLineOrderList != null && !quoteLineOrderList.isEmpty()) {
                for(QuoteOrderWrapper quoteLineOrderWrapObj : quoteLineOrderList) {
                    //System.debug('quoteLineOrderWrapObj.idField.length()>>>'+quoteLineOrderWrapObj.idField.length());
                    if(quoteLineOrderWrapObj.actionType == 'newQuote' || (quoteLineOrderWrapObj.idField.length()>18 && quoteLineOrderWrapObj.actionType != 'deleted')){
                        Quote_Order__c quoteLineOrderObj = new Quote_Order__c();
                        if(quoteLineOrderWrapObj.quoteLineParentId != null){
                            quoteLineOrderObj.Quote_Line__c = Id.valueOf(quoteLineOrderWrapObj.quoteLineParentId);
                        }
                        if(quoteLineOrderWrapObj.serviceType != null){
                            quoteLineOrderObj.Service_Type__c = quoteLineOrderWrapObj.serviceType;
                        }
                        if(quoteLineOrderWrapObj.productType != null){
                            quoteLineOrderObj.Product_Type__c = quoteLineOrderWrapObj.productType;
                        }
                        if(quoteLineOrderWrapObj.quoteLineId != null){
                            quoteLineOrderObj.Service_Quote_Line__c = quoteLineOrderWrapObj.quoteLineId;
                        }
                        if(quoteLineOrderWrapObj.serviceDate != null) {
                            quoteLineOrderObj.Service_Date__c = Date.valueOf(quoteLineOrderWrapObj.serviceDate);
                        }else{
                            quoteLineOrderObj.Service_Date__c =null;
                        }
                        if(quoteLineOrderWrapObj.serviceTime != null) {
                            quoteLineOrderObj.Service_Time_Span__c = quoteLineOrderWrapObj.serviceTime;
                        }
                        //SDT-20938, populating the contact fields from UI.
                        if(quoteLineOrderWrapObj.contact != null && !String.isBlank(quoteLineOrderWrapObj.contact)) {
                            quoteLineOrderObj.Onsite_Contact__c = quoteLineOrderWrapObj.contact;
                            OnsiteContact = quoteLineOrderObj.Onsite_Contact__c !=null ?  'ONSITE CONTACT : ' +quoteLineOrderObj.Onsite_Contact__c+';' :'';
                        }
                        //SDT-20938, populating the Phone fields from UI.
                        if(quoteLineOrderWrapObj.phone != null && !String.isBlank(quoteLineOrderWrapObj.phone)) {
                            quoteLineOrderObj.Onsite_Contact_Phone__c = quoteLineOrderWrapObj.phone;
                            OnsitePhone =  quoteLineOrderObj.Onsite_Contact_Phone__c !=null? ' CONTACT PHONE : '+ quoteLineOrderObj.Onsite_Contact_Phone__c+';':'';
                        }
                        //SDT-20938, populating the Instruction fields from UI.
                        if(quoteLineOrderWrapObj.instruction != null && !String.isBlank(quoteLineOrderWrapObj.instruction)){
                            quoteLineOrderObj.Instructions__c =quoteLineOrderWrapObj.instruction;
                            Position =  quoteLineOrderWrapObj.instruction!=null ? ' '+  quoteLineOrderWrapObj.instruction: '';
                        }
                        if(quoteLineOrderWrapObj.custRefNumber != null){
                            quoteLineOrderObj.Cust_Ref_Number__c = quoteLineOrderWrapObj.custRefNumber;
                        }
                        if(quoteLineOrderWrapObj.duration != null && !String.isBlank(quoteLineOrderWrapObj.duration)){
                            quoteLineOrderObj.Duration__c = quoteLineOrderWrapObj.duration;
                        }
                        if(quoteLineOrderWrapObj.occurenceType != null && !String.isBlank(quoteLineOrderWrapObj.occurenceType)){
                            quoteLineOrderObj.Occurrence_Type__c = quoteLineOrderWrapObj.occurenceType;
                        }
                        //SDT-20938, population Acorn Instructions with the OnsiteContact + OnsitePhone + Position
                        quoteLineOrderObj.Acorn_Instructions__c = OnsiteContact + OnsitePhone + Position;

                        // Changes for SDT-29198
                        if(quoteLineOrderWrapObj.bypassWorkOrder!=null)
				quoteLineOrderObj.Bypass_Work_Order__c = quoteLineOrderWrapObj.bypassWorkOrder;	

                        quoteLineOrderListToUpsert.add(quoteLineOrderObj);
                    } else if(quoteLineOrderWrapObj.actionType == 'changed'){
                        //System.debug('Id.valueOf(quoteLineOrderWrapObj.idField)>>update>'+Id.valueOf(quoteLineOrderWrapObj.idField));
                        quoteIdToUpdate.add(Id.valueOf(quoteLineOrderWrapObj.idField));
                    } 
                }
                if(quoteIdToUpdate != null && !quoteIdToUpdate.isEmpty()){
                    Map<String, Quote_Order__c> qoMap = new Map<String, Quote_Order__c>();
                    for(Quote_Order__c qo:[SELECT Id, Quote_Line__c, Service_Type__c,Service_Quote_Line__c,Product_Type__c, Service_Date__c,Service_Time_Span__c,Onsite_Contact__c, Onsite_Contact_Phone__c, Instructions__c, Cust_Ref_Number__c FROM Quote_Order__c WHERE Id IN: quoteIdToUpdate]){
                        qoMap.put(qo.Id,qo);
                    }
                    for(QuoteOrderWrapper quoteLineOrderWrapObj : quoteLineOrderList) {
                        if(quoteLineOrderWrapObj.idField != null){
                            if(qoMap.containsKey(quoteLineOrderWrapObj.idField)){
                                Quote_Order__c quoteLineOrderObj = new Quote_Order__c();
                                if(quoteLineOrderWrapObj.idField != null){
                                    quoteLineOrderObj.Id = quoteLineOrderWrapObj.idField;
                                }
                                if(quoteLineOrderWrapObj.quoteLineParentId != null){
                                    quoteLineOrderObj.Quote_Line__c = Id.valueOf(quoteLineOrderWrapObj.quoteLineParentId);
                                }
                                if(quoteLineOrderWrapObj.serviceType != null){
                                    quoteLineOrderObj.Service_Type__c = quoteLineOrderWrapObj.serviceType;
                                }
                                if(quoteLineOrderWrapObj.productType != null){
                                    quoteLineOrderObj.Product_Type__c = quoteLineOrderWrapObj.productType;
                                }
                                if(quoteLineOrderWrapObj.quoteLineId != null){
                                    quoteLineOrderObj.Service_Quote_Line__c = quoteLineOrderWrapObj.quoteLineId;
                                }
                                if(quoteLineOrderWrapObj.serviceDate != null) {
                                    quoteLineOrderObj.Service_Date__c = Date.valueOf(quoteLineOrderWrapObj.serviceDate);
                                }else{
                                    quoteLineOrderObj.Service_Date__c =null;
                                }
                                if(quoteLineOrderWrapObj.serviceTime != null) {
                                    quoteLineOrderObj.Service_Time_Span__c = quoteLineOrderWrapObj.serviceTime;
                                }
                                //SDT-20938, populating the contact fields from UI.
                                if(quoteLineOrderWrapObj.contact != null && !String.isBlank(quoteLineOrderWrapObj.contact)) {
                                    quoteLineOrderObj.Onsite_Contact__c = quoteLineOrderWrapObj.contact;
                                    OnsiteContact = quoteLineOrderObj.Onsite_Contact__c !=null ?  'ONSITE CONTACT : ' +quoteLineOrderObj.Onsite_Contact__c+';' :'';
                                } else{
                                    quoteLineOrderObj.Onsite_Contact__c ='';
                                    OnsiteContact = '';
                                }
                                //SDT-20938, populating the Phone fields from UI.
                                if(quoteLineOrderWrapObj.phone != null && !String.isBlank(quoteLineOrderWrapObj.phone)) {
                                    quoteLineOrderObj.Onsite_Contact_Phone__c = quoteLineOrderWrapObj.phone;
                                    OnsitePhone =  quoteLineOrderObj.Onsite_Contact_Phone__c !=null? ' CONTACT PHONE : '+ quoteLineOrderObj.Onsite_Contact_Phone__c+';':'';
                                }
                                else{
                                    quoteLineOrderObj.Onsite_Contact_Phone__c ='';
                                    OnsitePhone='';
                                }
                                //SDT-20938, populating the Instruction fields from UI.
                                if(quoteLineOrderWrapObj.instruction != null && !String.isBlank(quoteLineOrderWrapObj.instruction)){
                                    quoteLineOrderObj.Instructions__c = quoteLineOrderWrapObj.instruction;
                                    Position = quoteLineOrderWrapObj.instruction!=null ?  ' '+  quoteLineOrderWrapObj.instruction: '';
                                }else{
                                    quoteLineOrderObj.Instructions__c ='';
                                    Position='';
                                }
                                if(quoteLineOrderWrapObj.custRefNumber != null){
                                    quoteLineOrderObj.Cust_Ref_Number__c = quoteLineOrderWrapObj.custRefNumber;
                                }else{
                                    quoteLineOrderObj.Cust_Ref_Number__c ='';
                                }
                                if(quoteLineOrderWrapObj.duration != null){
                                    quoteLineOrderObj.Duration__c = quoteLineOrderWrapObj.duration;
                                }
                                if(quoteLineOrderWrapObj.occurenceType != null){
                                    quoteLineOrderObj.Occurrence_Type__c = quoteLineOrderWrapObj.occurenceType;
                                }
                                //SDT-20938, population Acorn Instructions with the OnsiteContact + OnsitePhone + Position
                                quoteLineOrderObj.Acorn_Instructions__c = OnsiteContact + OnsitePhone + Position;
							
                                // Changes for SDT-29198
                                if(quoteLineOrderWrapObj.bypassWorkOrder != null)
					quoteLineOrderObj.Bypass_Work_Order__c = quoteLineOrderWrapObj.bypassWorkOrder;
								
                                quoteLineOrderListToUpsert.add(quoteLineOrderObj);    
                            }
                        }
                    }
                }
            }
        }
        Boolean isValidUpsert= true;
        String msg='';
        String result='';
        Boolean isValidQL= true;
        List<Quote_Order__c> validQOList= new List<Quote_Order__c>();
        List<Quote_Order__c> invalidQOList= new List<Quote_Order__c>();
        if(quoteLineOrderListToUpsert != null && !quoteLineOrderListToUpsert.isEmpty()){
          //  System.debug('quoteLineOrderListToUpsert>>>'+quoteLineOrderListToUpsert);
            try{
                
                //String msg= validateQuoteOrders(quoteId, selQuoteProd, quoteLineOrderListToUpsert);
                Map<String, List<Quote_Order__c>> allScenarioMap= validateQuoteOrders(quoteId, selQuoteProd, quoteLineOrderListToUpsert);
                for(String str: allScenarioMap.keySet()){
                    if(str.equals('success')){
                        List<Quote_Order__c> qoList= allScenarioMap.get(str);
                        validQOList.addAll(qoList);
                    }else{
                        for(Quote_Order__c qo:allScenarioMap.get(str)){
                            isValidUpsert= false;
                            invalidQOList.add(qo);
                            String dt= String.valueOf(qo.Service_Date__c);
                            result = result + 'Order: ' +'SERVICE TYPE: '+qo.Service_Type__c+' , '+'COMPONENT NAME: '+qo.Product_Type__c+' , '+'SERVICE DATE: '+dt.subString(0,10)+'\n'+'- Error: '+str+'\n';
                        }
                    }
                }

                if(!toUpdateQuoteLinesList.isEmpty()){ //SDT-23801, update all the bundle lines.
                    Database.SaveResult[] srList = Database.update(toUpdateQuoteLinesList, true);
                    for(Database.SaveResult sr : srList){
                        if(!sr.isSuccess()){
                            for(Database.Error err : sr.getErrors()) {
                                isValidQL= false;
                                msg = msg+ 'Failed: The following error has occurred.\n'+err.getStatusCode() + ': ' + err.getMessage()+'\n'+'Quote Lines fields that affected this error: '+err.getFields()+'\n';
													 
										   
                            }
                        }
                    }
                    if(isValidQL && !validQOList.isEmpty()){
                        upsert validQOList;
                        if(validQOList.size()>1){
                            msg= 'Success: '+ validQOList.size() +' are saved successfully.'+'\n';
                        }else{
                            msg= 'Success: '+ validQOList.size() +' is saved successfully.'+'\n';
                        }
                    }
                }
            }
            catch(Exception e){
                isValidUpsert= false;
                return 'error';
            }
        }else if(!toUpdateQuoteLinesList.isEmpty()){ //SDT-23801, update all the bundle lines.
            try{
                Database.SaveResult[] srList = Database.update(toUpdateQuoteLinesList, true);
                for(Database.SaveResult sr : srList){
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()) {
                            isValidQL= false;
                            msg = msg+ 'Failed: The following error has occurred.\n'+err.getStatusCode() + ': ' + err.getMessage()+'\n'+'Quote Lines fields that affected this error: '+err.getFields()+'\n';
												 
									   
                        }
                    }
                }
            }catch(Exception e){
                isValidUpsert= false;

                //SDT-32136 
                string errorMsg = e.getMessage(); 
                if(errorMsg.contains('Vendor_Commit_Date__c')){
                    string pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
                    pureErrorMsg = pureErrorMsg.Substring(0,(pureErrorMsg.length()-4)); 
                    return pureErrorMsg;
                }else{
                return 'error';
            }
        }
}

        if( !isValidQL || !invalidQOList.isEmpty()){
         //   System.debug('invalid>>In>');
            msg = msg + result;
            isValidUpsert= false;
        }

        if(isValidUpsert){
            return 'success';
        } else{
            return msg;
        }

    }

    public static Map<String, List<Quote_Order__c>> validateQuoteOrders(String quoteId, String selectedQuoteLineId,List<Quote_Order__c> quoteOrderList){
        String message = '';
        String wasteStream = 'Waste Stream';
        Map<String, List<Quote_Order__c>> allScenarioMap= new Map<String, List<Quote_Order__c>>();
        Map<Id, List<Quote_Order__c>> prodQuoteLineIdQOMap= new Map<Id, List<Quote_Order__c>>();
        Map<Id,List<Quote_Order__c>> getQuoteLineOrdersByQuoteLine = new Map<Id,List<Quote_Order__c>>(); //quotelineId & quoteOrders
        //List<Quote_Order__c> validQOList= new List<Quote_Order__c>();
        for(Quote_Order__c qo: quoteOrderList){
            if(prodQuoteLineIdQOMap.containsKey(qo.Service_Quote_Line__c)){
                List <Quote_Order__c> qoList= prodQuoteLineIdQOMap.get(qo.Service_Quote_Line__c);
                qoList.add(qo);
            }else{
                prodQuoteLineIdQOMap.put(qo.Service_Quote_Line__c, new List <Quote_Order__c>{qo});
            }
        }
        Map<Id,SBQQ__QuoteLine__c> getQuoteLineById = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, 
                                                      SBQQ__Quote__c, SBQQ__RequiredBy__c,SBQQ__StartDate__c, SBQQ__EndDate__c,
                                                      SBQQ__EffectiveStartDate__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Name, 
                                                      SBQQ__Product__r.Name From SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId
                                                      AND Id IN: prodQuoteLineIdQOMap.keySet() 
                                                      AND Bypass_Acorn_Integration__c = false 
                                                      AND SBQQ__ProductOption__r.SBQQ__Feature__r.Name !=: wasteStream  
                                                      ORDER BY SBQQ__RequiredBy__c]);
        
        Map<Id,Quote_Order__c> getQuoteOrderById = new Map<Id,Quote_Order__c>([SELECT Id,Quote_Line__c,
                                                      Service_Type__c, Product_Type__c, Service_Date__c,Service_Time_Span__c,Onsite_Contact__c,Onsite_Contact_Phone__c,
                                                      Instructions__c, Cust_Ref_Number__c, Duration__c, Occurrence_Type__c, Service_Quote_Line__c 
                                                      FROM Quote_Order__c 
                                                      WHERE Quote_Line__c =: selectedQuoteLineId]);
        //Map<Id, Quote_Order__c> getprodQuoteLineIdQOMap = new Map<Id, Quote_Order__c>();
      //  System.debug('quoteOrderList>>'+quoteOrderList);
      //  System.debug('>>>getQuoteOrderById'+getQuoteOrderById);  
        
        if(!getQuoteOrderById.isEmpty()){
            for(Quote_Order__c quoteOrder :  getQuoteOrderById.values()){
            //    System.debug('>>>quoteOrder'+quoteOrder);
            //    System.debug('>>>getQuoteLineOrdersByQuoteLine.containsKey(quoteOrder.Service_Quote_Line__c)'+getQuoteLineOrdersByQuoteLine.containsKey(quoteOrder.Service_Quote_Line__c));
                if(getQuoteLineOrdersByQuoteLine.containsKey(quoteOrder.Service_Quote_Line__c)){
                    List<Quote_Order__c> qOrderList = getQuoteLineOrdersByQuoteLine.get(quoteOrder.Service_Quote_Line__c);
                //    System.debug('>>>qOrderList'+qOrderList);
                    qOrderList.add(quoteOrder);
                //    System.debug('>>>qOrderList'+qOrderList); 
                    getQuoteLineOrdersByQuoteLine.put(quoteOrder.Service_Quote_Line__c,qOrderList);
                 //   System.debug('>>>getQuoteLineOrdersByQuoteLine'+getQuoteLineOrdersByQuoteLine); 
                }
                else{
                    getQuoteLineOrdersByQuoteLine.put(quoteOrder.Service_Quote_Line__c,new List<Quote_Order__c>{quoteOrder}); 
     //   System.debug('>>>getQuoteLineOrdersByQuoteLine'+getQuoteLineOrdersByQuoteLine); 
                }
            }                                              
        }                                              

     //   System.debug('>>>getQuoteLineById'+getQuoteLineById);

        if(!getQuoteLineById.isEmpty()){
            Boolean isValid; 
            for(Quote_Order__c quoteOrderObj : quoteOrderList){
                isValid = true;
                message='';
             //   System.debug('>>>quoteOrderObj>>>'+quoteOrderObj); 
                if(quoteOrderObj.Service_Type__c == 'Delivery' || quoteOrderObj.Service_Type__c == 'Rental Charge'){
                    if(!getQuoteLineOrdersByQuoteLine.isEmpty() && getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c) != null 
                         && getQuoteLineOrdersByQuoteLine.containsKey(quoteOrderObj.Service_Quote_Line__c)
                         && getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c).size() > 0){
                         for(Quote_Order__c qOrderObj : getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c)){
                       //     System.debug('>>>qOrderObj'+qOrderObj);  
                            if((qOrderObj.Service_Type__c == 'Delivery' && quoteOrderObj.id== null) || (qOrderObj.Service_Type__c == 'Delivery' && quoteOrderObj.id !=null && quoteOrderObj.id != qOrderObj.id) ||
                              (qOrderObj.Service_Type__c == 'Rental Charge' && quoteOrderObj.id== null) || (qOrderObj.Service_Type__c == 'Rental Charge' && quoteOrderObj.id !=null && quoteOrderObj.id != qOrderObj.id)){
                                message = 'Delivery Order already exists.';
                                isValid = false;
                                //return message;
                                
                                if(allScenarioMap.containsKey(message)){
                                    List<Quote_Order__c> qoList= allScenarioMap.get(message);
                                    qoList.add(quoteOrderObj);
                                    allScenarioMap.put(message,qoList);
                                }else{
                                    List<Quote_Order__c> qoList= new List<Quote_Order__c>();
                                    qoList.add(quoteOrderObj);
                                    allScenarioMap.put(message,qoList);
                                }
                            }
                        }   
                    }
                    
                    /*if( isValid && getQuoteLineById.containsKey(quoteOrderObj.Service_Quote_Line__c)){
                        if(getQuoteLineById.get(quoteOrderObj.Service_Quote_Line__c).SBQQ__StartDate__c == null || getQuoteLineById.get(quoteOrderObj.Service_Quote_Line__c).SBQQ__StartDate__c != quoteOrderObj.Service_Date__c){
                            message = 'Delivery Order should be equal to start date.';
                            isValid = false;
                            //return message;
                            if(allScenarioMap.containsKey(message)){
                                List<Quote_Order__c> qoList= allScenarioMap.get(message);
                                qoList.add(quoteOrderObj);
                                allScenarioMap.put(message,qoList);
                            }else{
                                List<Quote_Order__c> qoList= new List<Quote_Order__c>();
                                qoList.add(quoteOrderObj);
                                allScenarioMap.put(message,qoList);
                            }
                        }
                        //getQuoteLineById.get(quoteOrderObj.Service_Quote_Line__c).SBQQ__EndDate__c;
                    }*/
                    
                    if(isValid){
                      //  System.debug('valid>>>>');
                        if(getQuoteLineOrdersByQuoteLine.containsKey(quoteOrderObj.Service_Quote_Line__c)){
                            List<Quote_Order__c> qOrderList = getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c);
                         //   System.debug('>>>qOrderList'+qOrderList);
                            qOrderList.add(quoteOrderObj);
                        //    System.debug('>>>qOrderList'+qOrderList); 
                            getQuoteLineOrdersByQuoteLine.put(quoteOrderObj.Service_Quote_Line__c,qOrderList);
                         //   System.debug('>>>getQuoteLineOrdersByQuoteLine'+getQuoteLineOrdersByQuoteLine); 
                        }
                        else{
                            getQuoteLineOrdersByQuoteLine.put(quoteOrderObj.Service_Quote_Line__c,new List<Quote_Order__c>{quoteOrderObj}); 
                         //   System.debug('>>>getQuoteLineOrdersByQuoteLine'+getQuoteLineOrdersByQuoteLine); 
                        }
                        //validQOList.add(quoteOrderObj);
                        message = 'success'; 
                        if(allScenarioMap.containsKey(message)){
                            List<Quote_Order__c> qoList= allScenarioMap.get(message);
                            qoList.add(quoteOrderObj);
                            allScenarioMap.put(message,qoList);
                        }else{
                            List<Quote_Order__c> qoList= new List<Quote_Order__c>();
                            qoList.add(quoteOrderObj);
                            allScenarioMap.put(message,qoList);
                        }
                    }
                }
                if(quoteOrderObj.Service_Type__c == 'Pickup'){
                    
                    if(!getQuoteLineOrdersByQuoteLine.isEmpty() && getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c) != null 
                         && getQuoteLineOrdersByQuoteLine.containsKey(quoteOrderObj.Service_Quote_Line__c)
                         && getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c).size() > 0){
                         for(Quote_Order__c qOrderObj : getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c)){
                         //   System.debug('qOrderObj>>>'+qOrderObj);
                         //   System.debug('quoteOrderObj.Service_Date__c>>>'+qOrderObj.Service_Date__c);
                             if((qOrderObj.Service_Type__c == 'Pickup' && quoteOrderObj.id== null && qOrderObj.Service_Date__c == quoteOrderObj.Service_Date__c) || (qOrderObj.Service_Type__c == 'Pickup' && quoteOrderObj.id !=null && quoteOrderObj.id != qOrderObj.id && qOrderObj.Service_Date__c == quoteOrderObj.Service_Date__c)){
                                message = 'Pickup Order already exists for the service date.';
                                isValid = false;
                                //return message;
                                if(allScenarioMap.containsKey(message)){
                                    List<Quote_Order__c> qoList= allScenarioMap.get(message);
                                    qoList.add(quoteOrderObj);
                                    allScenarioMap.put(message,qoList);
                                }else{
                                    List<Quote_Order__c> qoList= new List<Quote_Order__c>();
                                    qoList.add(quoteOrderObj);
                                    allScenarioMap.put(message,qoList);
                                }
                             }
                         }   
                    }
                    
                    /*if(isValid && getQuoteLineById.containsKey(quoteOrderObj.Service_Quote_Line__c)){
                        if( getQuoteLineById.get(quoteOrderObj.Service_Quote_Line__c).SBQQ__StartDate__c == null || (quoteOrderObj.Service_Date__c < getQuoteLineById.get(quoteOrderObj.Service_Quote_Line__c).SBQQ__StartDate__c) || (quoteOrderObj.Service_Date__c > getQuoteLineById.get(quoteOrderObj.Service_Quote_Line__c).SBQQ__EndDate__c)){
                            message = 'Pickup Order should be equal and greater than start date and less than and equal to end date.';
                            isValid = false;
                            //return message;
                            if(allScenarioMap.containsKey(message)){
                                List<Quote_Order__c> qoList= allScenarioMap.get(message);
                                qoList.add(quoteOrderObj);
                                allScenarioMap.put(message,qoList);
                            }else{
                                List<Quote_Order__c> qoList= new List<Quote_Order__c>();
                                qoList.add(quoteOrderObj);
                                allScenarioMap.put(message,qoList);
                            }
                        }
                    }*/
                    
                    if(isValid){
                       // System.debug('valid>>>>');
                        if(getQuoteLineOrdersByQuoteLine.containsKey(quoteOrderObj.Service_Quote_Line__c)){
                            List<Quote_Order__c> qOrderList = getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c);
                         //   System.debug('>>>qOrderList'+qOrderList);
                            qOrderList.add(quoteOrderObj);
                         //   System.debug('>>>qOrderList'+qOrderList); 
                            getQuoteLineOrdersByQuoteLine.put(quoteOrderObj.Service_Quote_Line__c,qOrderList);
                         //   System.debug('>>>getQuoteLineOrdersByQuoteLine'+getQuoteLineOrdersByQuoteLine); 
                        }
                        else{
                            getQuoteLineOrdersByQuoteLine.put(quoteOrderObj.Service_Quote_Line__c,new List<Quote_Order__c>{quoteOrderObj}); 
                         //   System.debug('>>>getQuoteLineOrdersByQuoteLine'+getQuoteLineOrdersByQuoteLine); 
                        }
                        message = 'success'; 
                        if(allScenarioMap.containsKey(message)){
                            List<Quote_Order__c> qoList= allScenarioMap.get(message);
                            qoList.add(quoteOrderObj);
                            allScenarioMap.put(message,qoList);
                        }else{
                            List<Quote_Order__c> qoList= new List<Quote_Order__c>();
                            qoList.add(quoteOrderObj);
                            allScenarioMap.put(message,qoList);
                        }
                    }
                }

                // Start ->Abhishek Patel -> 41624
                // Show error message for same type of haul away service quote order 

                if(quoteOrderObj.Service_Type__c == 'Haul Away Service'){
                    
                    if(!getQuoteLineOrdersByQuoteLine.isEmpty() && getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c) != null 
                         && getQuoteLineOrdersByQuoteLine.containsKey(quoteOrderObj.Service_Quote_Line__c)
                         && getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c).size() > 0){
                         for(Quote_Order__c qOrderObj : getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c)){
                         
                             if((qOrderObj.Service_Type__c == 'Haul Away Service' && quoteOrderObj.id== null && qOrderObj.Service_Date__c == quoteOrderObj.Service_Date__c) || (qOrderObj.Service_Type__c == 'Haul Away Service' && quoteOrderObj.id !=null && quoteOrderObj.id != qOrderObj.id && qOrderObj.Service_Date__c == quoteOrderObj.Service_Date__c)){
                                message = 'Haul Away Service Order already exists';
                                isValid = false;
                                //return message;
                                if(allScenarioMap.containsKey(message)){
                                    List<Quote_Order__c> qoList= allScenarioMap.get(message);
                                    qoList.add(quoteOrderObj);
                                    allScenarioMap.put(message,qoList);
                                }else{
                                    List<Quote_Order__c> qoList= new List<Quote_Order__c>();
                                    qoList.add(quoteOrderObj);
                                    allScenarioMap.put(message,qoList);
                                }
                             }
                         }   
                    }
                
                    
                    if(isValid){
                       
                        if(getQuoteLineOrdersByQuoteLine.containsKey(quoteOrderObj.Service_Quote_Line__c)){
                            List<Quote_Order__c> qOrderList = getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c);
                         
                            qOrderList.add(quoteOrderObj);
                          
                            getQuoteLineOrdersByQuoteLine.put(quoteOrderObj.Service_Quote_Line__c,qOrderList);
                        }
                        else{
                            getQuoteLineOrdersByQuoteLine.put(quoteOrderObj.Service_Quote_Line__c,new List<Quote_Order__c>{quoteOrderObj}); 
                        }
                        message = 'success'; 
                        if(allScenarioMap.containsKey(message)){
                            List<Quote_Order__c> qoList= allScenarioMap.get(message);
                            qoList.add(quoteOrderObj);
                            allScenarioMap.put(message,qoList);
                        }else{
                            List<Quote_Order__c> qoList= new List<Quote_Order__c>();
                            qoList.add(quoteOrderObj);
                            allScenarioMap.put(message,qoList);
                        }
                    }
                }

                // End ->Abhishek Patel -> 41624
                
                if(quoteOrderObj.Service_Type__c == 'Removal'){
                 //   System.debug('>>>Removal');
                    
                    if(!getQuoteLineOrdersByQuoteLine.isEmpty() && getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c) != null 
                         && getQuoteLineOrdersByQuoteLine.containsKey(quoteOrderObj.Service_Quote_Line__c)
                         && getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c).size() > 0){
                         for(Quote_Order__c qOrderObj : getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c)){
                        //    System.debug('>>>qOrderObj'+qOrderObj);  
                            if((qOrderObj.Service_Type__c == 'Removal' && quoteOrderObj.id== null) || (qOrderObj.Service_Type__c == 'Removal' && quoteOrderObj.id !=null && quoteOrderObj.id != qOrderObj.id)){
                          //      System.debug('>>>Removal Entry1');
                                message = 'Removal Order already exists.';
                                isValid = false;
                                //return message;
                                if(allScenarioMap.containsKey(message)){
                                    List<Quote_Order__c> qoList= allScenarioMap.get(message);
                                    qoList.add(quoteOrderObj);
                                    allScenarioMap.put(message,qoList);
                                }else{
                                    List<Quote_Order__c> qoList= new List<Quote_Order__c>();
                                    qoList.add(quoteOrderObj);
                                    allScenarioMap.put(message,qoList);
                                }
                            }
                         }   
                    }
                    
                    /*if(isValid && getQuoteLineById.containsKey(quoteOrderObj.Service_Quote_Line__c)){
                        if(getQuoteLineById.get(quoteOrderObj.Service_Quote_Line__c).SBQQ__StartDate__c == null || (quoteOrderObj.Service_Date__c < getQuoteLineById.get(quoteOrderObj.Service_Quote_Line__c).SBQQ__StartDate__c) || (quoteOrderObj.Service_Date__c > getQuoteLineById.get(quoteOrderObj.Service_Quote_Line__c).SBQQ__EndDate__c)){
                            message = 'Removal Order should be greater than or equal to start date and less than and equal to end date.';
                            isValid = false;
                            //return message;
                            if(allScenarioMap.containsKey(message)){
                                List<Quote_Order__c> qoList= allScenarioMap.get(message);
                                qoList.add(quoteOrderObj);
                                allScenarioMap.put(message,qoList);
                            }else{
                                List<Quote_Order__c> qoList= new List<Quote_Order__c>();
                                qoList.add(quoteOrderObj);
                                allScenarioMap.put(message,qoList);
                            }
                        }
                    }*/
                    
                    if(isValid){
                    //    System.debug('valid>>>>');
                        if(getQuoteLineOrdersByQuoteLine.containsKey(quoteOrderObj.Service_Quote_Line__c)){
                            List<Quote_Order__c> qOrderList = getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c);
                        //    System.debug('>>>qOrderList'+qOrderList);
                            qOrderList.add(quoteOrderObj);
                        //    System.debug('>>>qOrderList'+qOrderList); 
                            getQuoteLineOrdersByQuoteLine.put(quoteOrderObj.Service_Quote_Line__c,qOrderList);
                        //    System.debug('>>>getQuoteLineOrdersByQuoteLine'+getQuoteLineOrdersByQuoteLine); 
                        }
                        else{
                            getQuoteLineOrdersByQuoteLine.put(quoteOrderObj.Service_Quote_Line__c,new List<Quote_Order__c>{quoteOrderObj}); 
                            // System.debug('>>>getQuoteLineOrdersByQuoteLine'+getQuoteLineOrdersByQuoteLine); 
                        }
                        message = 'success'; 
                        if(allScenarioMap.containsKey(message)){
                            List<Quote_Order__c> qoList= allScenarioMap.get(message);
                            qoList.add(quoteOrderObj);
                            allScenarioMap.put(message,qoList);
                        }else{
                            List<Quote_Order__c> qoList= new List<Quote_Order__c>();
                            qoList.add(quoteOrderObj);
                            allScenarioMap.put(message,qoList);
                        }
                    }
                }
                // Changes for SDT-30118
                if(quoteOrderObj.Service_Type__c == 'Lock Delivery')
                {
                    if(!getQuoteLineOrdersByQuoteLine.isEmpty() && getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c) != null 
                        && getQuoteLineOrdersByQuoteLine.containsKey(quoteOrderObj.Service_Quote_Line__c)
                        && getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c).size() > 0){
                        for(Quote_Order__c qOrderObj : getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c)){
                        
                            if((qOrderObj.Service_Type__c == 'Lock Delivery' && quoteOrderObj.id== null) || (qOrderObj.Service_Type__c == 'Lock Delivery' && quoteOrderObj.id !=null && quoteOrderObj.id != qOrderObj.id)){
                            
                                message = 'Lock Delivery Order already exists.';
                                isValid = false;
                                //return message;
                                if(allScenarioMap.containsKey(message)){
                                    List<Quote_Order__c> qoList= allScenarioMap.get(message);
                                    qoList.add(quoteOrderObj);
                                    allScenarioMap.put(message,qoList);
                                }else{
                                    List<Quote_Order__c> qoList= new List<Quote_Order__c>();
                                    qoList.add(quoteOrderObj);
                                    allScenarioMap.put(message,qoList);
                                }
                            }
                        }   
                    }
                    
                    if(isValid){
                   
                        if(getQuoteLineOrdersByQuoteLine.containsKey(quoteOrderObj.Service_Quote_Line__c)){
                            List<Quote_Order__c> qOrderList = getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c);
                        
                            qOrderList.add(quoteOrderObj);
                        
                            getQuoteLineOrdersByQuoteLine.put(quoteOrderObj.Service_Quote_Line__c,qOrderList);
                        
                        }
                        else{
                            getQuoteLineOrdersByQuoteLine.put(quoteOrderObj.Service_Quote_Line__c,new List<Quote_Order__c>{quoteOrderObj}); 
                            
                        }
                        message = 'success'; 
                        if(allScenarioMap.containsKey(message)){
                            List<Quote_Order__c> qoList= allScenarioMap.get(message);
                            qoList.add(quoteOrderObj);
                            allScenarioMap.put(message,qoList);
                        }else{
                            List<Quote_Order__c> qoList= new List<Quote_Order__c>();
                            qoList.add(quoteOrderObj);
                            allScenarioMap.put(message,qoList);
                        }
                    }
                }
                // Changes for SDT-31593
                if(serviceTypeSet.contains(quoteOrderObj.Service_Type__c))
                {
                    
                    if(!getQuoteLineOrdersByQuoteLine.isEmpty() && getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c) != null 
                        && getQuoteLineOrdersByQuoteLine.containsKey(quoteOrderObj.Service_Quote_Line__c)
                        && getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c).size() > 0){
                        for(Quote_Order__c qOrderObj : getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c)){
                         
                            if((serviceTypeSet.contains(qOrderObj.Service_Type__c) && quoteOrderObj.id== null) || (serviceTypeSet.contains(qOrderObj.Service_Type__c) && quoteOrderObj.id !=null && quoteOrderObj.id != qOrderObj.id)){
                           
                                message = qOrderObj.Service_Type__c + ' Order already exists.';
                                isValid = false;
                               
                                if(allScenarioMap.containsKey(message)){
                                    List<Quote_Order__c> qoList= allScenarioMap.get(message);
                                    qoList.add(quoteOrderObj);
                                    allScenarioMap.put(message,qoList);
                                }else{
                                    List<Quote_Order__c> qoList= new List<Quote_Order__c>();
                                    qoList.add(quoteOrderObj);
                                    allScenarioMap.put(message,qoList);
                                }
                            }
                        }   
                    }
                    
                    if(isValid){
                    
                        if(getQuoteLineOrdersByQuoteLine.containsKey(quoteOrderObj.Service_Quote_Line__c)){
                            List<Quote_Order__c> qOrderList = getQuoteLineOrdersByQuoteLine.get(quoteOrderObj.Service_Quote_Line__c);
                        
                            qOrderList.add(quoteOrderObj);
                        
                            getQuoteLineOrdersByQuoteLine.put(quoteOrderObj.Service_Quote_Line__c,qOrderList);
                       
                        }
                        else{
                            getQuoteLineOrdersByQuoteLine.put(quoteOrderObj.Service_Quote_Line__c,new List<Quote_Order__c>{quoteOrderObj}); 
                            
                        }
                        message = 'success'; 
                        if(allScenarioMap.containsKey(message)){
                            List<Quote_Order__c> qoList= allScenarioMap.get(message);
                            qoList.add(quoteOrderObj);
                            allScenarioMap.put(message,qoList);
                        }else{
                            List<Quote_Order__c> qoList= new List<Quote_Order__c>();
                            qoList.add(quoteOrderObj);
                            allScenarioMap.put(message,qoList);
                        }
                    }
                }
            }
        }
     /*   System.debug('tell me message>>>'+allScenarioMap.keySet()); 
        System.debug('tell me quote_order__c>>>'+allScenarioMap.values());     */                                         
        return allScenarioMap;  
    }
	
    //SDT-33378
    // TCS
    //Checks the start date at the change of vendor commit date
    @AuraEnabled
    public static Map<object,object> checkStartDateValidity(String quoteId, Date vendorCommitDate){
        SBQQ__Quote__c quote = new SBQQ__Quote__c(Id=quoteId);
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList.add(quote);
        
        Map<object,Object> result = new Map<object,Object>();
        result.put('isValid',true);
        result.put('ErrorMessage','');
        List<SBQQ__QuoteLine__c> qlList = QuoteLineSelector.getQuoteLinesByQuoteIdList(quoteList);
        
        system.debug('qlList.size ' + qlList.size());
        system.debug('quoteId ' + quoteId);
        system.debug('vendorCommitDate ' + vendorCommitDate);
        
        // does it require to run for each line
        StartDateManagement manager = new StartDateManagement();
        for(SBQQ__QuoteLine__c ql  : qlList){
            if(ql.AssetId__r.ParentId!=null){
                ql.SBQQ__StartDate__c  = vendorCommitDate ;
               boolean isValid = manager.validateQuoteLineStartDate(ql);
                if(!isValid){
                    result.put('isValid',false);
                     result.put('ErrorMessage',StartDateManagement.InvalidStartDateErrorMessage);
                    
                }
                
                break;
            }
        }
        
         //result.put('isValid',false);
        //result.put('ErrorMessage',StartDateManagement.InvalidStartDateErrorMessage);
        return result;
        //for()
    }
    

    public class QuoteLineProductOptionsWrapper{
        public String duration;
        public String occurenceType;
        public String serviceType;
        public String quoteLineProductName;
        public String quoteLineId;
        public Map<String,String> quoteLineProdOptionsMap; //quoteLine & Prod Options
        public Boolean poFlag;
        public Date serviceLineStartDate;
        public Date serviceLineEndDate;
    }

    public class QuoteLineFeatureProductOptionsWrapper{
        public List<QuoteLineProductOptionsWrapper> quoteLineProdOptionList;
    }

    public class DeleteQuoteLineWrapper{
        public List<String> quoteOrderidList;
    }
    public class QuoteLineWrapper {
        public List<QuoteOrderWrapper> quoteOrder;
    }

    public class QuoteOrderWrapper{
        public String quoteLineParentId;
        public String idField;
        public String serviceType;
        public String productType;
        public String quoteLineId;
        public String serviceDate;
        public String serviceTime;
        public String contact;
        public String phone;
        public String instruction;
        public String custRefNumber;
        public String actionType;
        public String duration;
        public String occurenceType;
        public Date serviceLineStartDate;
        public Date serviceLineEndDate;
        public Boolean disableDelete;
		public Boolean bypassWorkOrder;															
    }

    public class ServiceTypeWrapper{
        public List<String> serviceTypeList;
    }

    public class SelectedProductWrapper{
        public String selectedProd;
        public Date startDate;
        public Date bundleStartDate;
        public Date bundleEndDate;
        public String locPos;
        public Boolean isDelivery;
        public Boolean isCSR;
        public String equipmentSize ; //SDT-29723 - for Asset Availablity
        public String caseRecordType; //SDT-29723 - for Asset Availablity
        public Date VendorCommitDate;  //SDT-32136 - to bring it in product order screen.
        public Date CustomerRequestDate; //SDT-32136 - to bring it in product order screen.
    }
    //SDT-29723 : Wrapper will contain field related to Asset availability fnc
    public class AssetAvailabilityWrapper{
        @AuraEnabled public String deliveryAvailability {get; set;}
        @AuraEnabled public Boolean assetAvailability {get; set;}
    }
}
