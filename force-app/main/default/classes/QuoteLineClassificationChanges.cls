/*
            SDT-24736 Classification Changes
            Author: Yeshas Konduru
            Date: Feb 27th 2023                 */
public class QuoteLineClassificationChanges {

    // SDT-42334 -> Start -added this method for comparison screen check in QuoteLineClassificationChanges.cmp and controller
    @AuraEnabled
    public static Boolean getIsHaulAwayValue(Id pQLineId) {
        Boolean isHaul=false;
        id caseId = [select SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c from SBQQ__QuoteLine__c where id=:pQLineId limit 1].SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c;
        isHaul = HaulAwayService.getIsHaulAwayService(caseId);
        system.debug('isHaul--->' + isHaul);
        return isHaul;
    }
    // SDT-42334 -> End

	@AuraEnabled
    public static cChanges getclassificationChanges(string pQLineId){
        cChanges cc = new cChanges();
        String strMaterialCategoryType =Constant_Util.EMPTY_STRING;//Added the field used as per changes SDT-28899
        List<SBQQ__QuoteLine__c> pqLineList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();		//TCS-SDT-33321-24-Nov-2023-Added this line
        List<SBQQ__QuoteLine__c> childqlList = new List<SBQQ__QuoteLine__c>();		//TCS-SDT-33321-24-Nov-2023-Added this line

        //pkulkar-TCS-08-May-23-Added SBQQ__Quantity__c and SBQQ__ProductFamily__c WHERE clause for Child Quote Lines query as per SDT-29623 and moved the Query part to QuoteLineSelector class
        qlList = QuoteLineSelector.getQLsByParentQLIdExcludeWasteCategory(pQLineId);
        //TCS-SDT-33321-24-Nov-2023-Looping the quotelines to seperate parent and child qls.
        if (qlList.size()>0){
            for(SBQQ__QuoteLine__c qL:qlList)
            {
                if(qL.SBQQ__RequiredBy__c == null)	//Parent Quote Line
                {
                    pqLineList.add(qL);
                }
                else
                {
                    childqlList.add(qL);	//Child Quote Lines
                }
            }
        }
        //TCS-SDT-33321-24-Nov-2023-End
        
        if(pqLineList.size()>0){
            SBQQ__QuoteLine__c pqLine = pqLineList[0];
            if(!string.isEmpty(pqLine.Initial_Classification_Changes__c)){
                initialcChange pqLineInitialcChange = new initialcChange();
                pqLineInitialcChange = pqLineInitialcChange.parse(pqLine.Initial_Classification_Changes__c);
                //cc.oldQLineDetails.quantity = pqLineInitialcChange.quantity;	//pkulkar-TCS-08-May-23-Commented as per SDT-29623
                cc.oldQLineDetails.equipmentSize = pqLineInitialcChange.equipmentSize;
                cc.oldQLineDetails.equipmentType = pqLineInitialcChange.equipmentType;
                cc.oldQLineDetails.wasteStream = pqLineInitialcChange.wasteStream;
                cc.oldQLineDetails.companyCategory = pqLineInitialcChange.companyCategory;
                cc.oldQLineDetails.locationPosition = pqLineInitialcChange.locationPosition;
                //Added for changes as per SDT-28900  
                cc.oldQLineDetails.locationPositionName = String.isNotBlank(pqLineInitialcChange.locationPositionName)?pqLineInitialcChange.locationPositionName:'';
                cc.oldQLineDetails.wasteStreamMaterialType = String.isNotBlank(pqLineInitialcChange.wasteStreamMaterialType)?pqLineInitialcChange.wasteStreamMaterialType:'';//Added new wasteStreamMaterialType mapping for SDT-28899
                cc.oldQLineDetails.sCode = pqLineInitialcChange.sCode;
            }
            //cc.newQLineDetails.quantity = string.valueOf(pqLine.SBQQ__Quantity__c);	//pkulkar-TCS-08-May-23-Commented as per SDT-29623
            cc.newQLineDetails.equipmentSize = pqLine.Equipment_Size__c;
            cc.newQLineDetails.equipmentType = pqLine.SBQQ__Product__r.Name;
            cc.newQLineDetails.wasteStream = pqLine.SBQQ__Product__r.Family;
            cc.newQLineDetails.companyCategory = pqLine.CompanyCategoryName__c;
            cc.newQLineDetails.locationPosition = pqLine.Account__r.Name;
            cc.newQLineDetails.locationPositionName = pqLine.LocationPositionName__c;//Added for changes as per SDT-28900 
            cc.newQLineDetails.sCode = pqLine.sCode__c;
            //TCS-SDT-33321-24-Nov-2023-Changed if and for to check for childqlList instead of pqLine.SBQQ__Quote_Lines__r
            if(childqlList.size()>0){ 
                for(SBQQ__QuoteLine__c childqLine :childqlList){
                    serviceLine sLine = new serviceLine();
                    sLine.service = childqLine.SBQQ__Product__r.Name;
                    sLine.schedule = childqLine.Service_Schedule__c;
                    //SDT 41407
                    sLine.monthlyScheduleDetails = QuoteLineServices.generateMonthlyScheduleDetails(childqLine);
                    sLine.cost = string.valueOf(childqLine.SBQQ__UnitCost__c);
                    sLine.price = string.valueOf(childqLine.SBQQ__ListPrice__c);
                    //TCS-SDT-32165-Added following lines
                    sLine.cUnitOfMeasurement =  string.valueOf(childqLine.Cost_Unit_of_Measure__c);
                    sLine.pUnitOfMeasurement = string.valueOf(childqLine.PriceUOM__c); 
                	//TCS-SDT-38111
                	//sLine.cMinimumQuantity = string.valueOf(childqLine.CostMinQuantity__c);
                	//sLine.pMinimumQuantity = string.valueOf(childqLine.PriceMinQuantity__c);
                	sLine.cMinimumQuantity = childqLine.CostMinQuantity__c!=null ? string.valueOf(childqLine.CostMinQuantity__c.setScale(2)) : string.valueOf(childqLine.CostMinQuantity__c);
                	sLine.pMinimumQuantity = childqLine.PriceMinQuantity__c!=null ? string.valueOf(childqLine.PriceMinQuantity__c.setScale(2)) : string.valueOf(childqLine.PriceMinQuantity__c);		
                    sLine.costUpTo1 = string.valueOf(childqLine.CostUpTo1__c);
                    sLine.costUpTo2 = string.valueOf(childqLine.CostUpTo2__c);
                    sLine.costUpTo3 = string.valueOf(childqLine.CostUpTo3__c);
                    sLine.costUpTo4 = string.valueOf(childqLine.CostUpTo4__c);
                    sLine.steppedCost1 = string.valueOf(childqLine.CostPrice1__c);
                    sLine.steppedCost2 = string.valueOf(childqLine.CostPrice2__c);
                    sLine.steppedCost3 = string.valueOf(childqLine.CostPrice3__c);
                    sLine.steppedCost4 = string.valueOf(childqLine.CostPrice4__c);
                    sLine.priceUpTo1 = string.valueOf(childqLine.PriceUpTo1__c);
                    sLine.priceUpTo2 = string.valueOf(childqLine.PriceUpTo2__c);
                    sLine.priceUpTo3 = string.valueOf(childqLine.PriceUpTo3__c);
                    sLine.priceUpTo4 = string.valueOf(childqLine.PriceUpTo4__c);
                    sLine.steppedPrice1 = string.valueOf(childqLine.PricePrice1__c);
                    sLine.steppedPrice2 = string.valueOf(childqLine.PricePrice2__c);
                    sLine.steppedPrice3 = string.valueOf(childqLine.PricePrice3__c);
                    sLine.steppedPrice4 = string.valueOf(childqLine.PricePrice4__c);
                    sLine.pricingMethod = string.valueOf(childqLine.SBQQ__PricingMethod__c);
                    sLine.costModelType = string.valueOf(childqLine.CostModelType__c);
                    //TCS-SDT-32165-End
                    sLine.startDate = string.valueOf(childqLine.SBQQ__StartDate__c);
                    sLine.EndDate = string.valueOf(childqLine.SBQQ__EndDate__c);
                    sLine.Vendor = childqLine.Vendor__r.Name;
                    sLine.productId = (childqLine.SBQQ__Product__c!=null) ? childqLine.SBQQ__Product__c :'';
					sLine.qlId = childqLine.id;//Seema-TCS-22-11-23-Added as per SDT-33136
                    sLine.quantity = String.valueOf(childqLine.SBQQ__Quantity__c);	//pkulkar-TCS-08-May-23-Added as per SDT-29623
                    setSteppedCostAndPrice(sLine);	//TCS-pkulkarn-SDT-40565-12-Sep-2024-Added
                    cc.newQLineDetails.serviceLines.add(sLine);
                    if(!string.isEmpty(childqLine.Initial_Classification_Changes__c)){
                        initialcChange qLineInitialcChange = new initialcChange();
                        qLineInitialcChange = qLineInitialcChange.parse(childqLine.Initial_Classification_Changes__c);
                        serviceLine tempsLine = new serviceLine();
                        tempsLine.service = qLineInitialcChange.service;
                        tempsLine.schedule = qLineInitialcChange.schedule;
                        //SDT 41407
                        tempsLine.monthlyScheduleDetails = qLineInitialcChange.monthlyScheduleDetails;
                        tempsLine.cost = qLineInitialcChange.cost;
                        tempsLine.price = qLineInitialcChange.price;
                        tempsLine.startDate = qLineInitialcChange.startDate;
                        tempsLine.EndDate = qLineInitialcChange.endDate;
                        tempsLine.Vendor = qLineInitialcChange.vendor;
                        tempsLine.productId = qLineInitialcChange.productId;
						tempsLine.qlId = childqLine.id;//Seema-TCS-22-11-23-Added as per SDT-33136
                        tempsLine.quantity = String.valueOf(qLineInitialcChange.quantity);	//pkulkar-TCS-08-May-23-Added as per SDT-29623
                        //TCS-SDT-32165-Added following lines
                        tempsLine.cUnitOfMeasurement = string.valueOf(qLineInitialcChange.cUnitOfMeasurement);
                        tempsLine.pUnitOfMeasurement = string.valueOf(qLineInitialcChange.pUnitOfMeasurement);
                        tempsLine.cMinimumQuantity = string.valueOf(qLineInitialcChange.cMinimumQuantity);
                        tempsLine.pMinimumQuantity = string.valueOf(qLineInitialcChange.pMinimumQuantity);
                        tempsLine.costUpTo1 = string.valueOf(qLineInitialcChange.costUpTo1);
                        tempsLine.costUpTo2 = string.valueOf(qLineInitialcChange.costUpTo2);
                        tempsLine.costUpTo3 = string.valueOf(qLineInitialcChange.costUpTo3);
                        tempsLine.costUpTo4 = string.valueOf(qLineInitialcChange.costUpTo4);
                        tempsLine.steppedCost1 = string.valueOf(qLineInitialcChange.steppedCost1);
                        tempsLine.steppedCost2 = string.valueOf(qLineInitialcChange.steppedCost2);
                        tempsLine.steppedCost3 = string.valueOf(qLineInitialcChange.steppedCost3);
                        tempsLine.steppedCost4 = string.valueOf(qLineInitialcChange.steppedCost4);
                        tempsLine.priceUpTo1 = string.valueOf(qLineInitialcChange.priceUpTo1);
                        tempsLine.priceUpTo2 = string.valueOf(qLineInitialcChange.priceUpTo2);
                        tempsLine.priceUpTo3 = string.valueOf(qLineInitialcChange.priceUpTo3);
                        tempsLine.priceUpTo4 = string.valueOf(qLineInitialcChange.priceUpTo4);
                        tempsLine.steppedPrice1 = string.valueOf(qLineInitialcChange.steppedPrice1);
                        tempsLine.steppedPrice2 = string.valueOf(qLineInitialcChange.steppedPrice2);
                        tempsLine.steppedPrice3 = string.valueOf(qLineInitialcChange.steppedPrice3);
                        tempsLine.steppedPrice4 = string.valueOf(qLineInitialcChange.steppedPrice4);
                        tempsLine.pricingMethod = string.valueOf(qLineInitialcChange.pricingMethod);
                    	tempsLine.costModelType = string.valueOf(qLineInitialcChange.costModelType);
                        //TCS-SDT-32165-End
                        setSteppedCostAndPrice(tempsLine);	//TCS-pkulkarn-SDT-40565-12-Sep-2024-Added
                        cc.oldQLineDetails.serviceLines.add(tempsLine);
                    }
                }
            }
            cc.newQLineDetails.wasteStreamMaterialType = getWasteStreamForParentQuoteLine(pQLineId);//Added the field used as per changes SDT-28899

            //TCS-pkulkarn-SDT-32107-10-Sep-2024-Added
            if(pqLineList.size() > 0 && 
               (pqLineList[0].SBQQ__Quote__r.SBQQ__Status__c != Constant_Util.APPROVED ||
               pqLineList[0].SBQQ__Quote__r.Integration_Status__c != Constant_Util.SUCCESS)
              )
            {
                retrieveAssetsOfMissingQuoteLines(cc, pqLineList[0].AssetId__c, childqlList);
            }
            //TCS-pkulkarn-SDT-32107-10-Sep-2024-End
        }
        return cc;
    }
    public class cChanges{
        @AuraEnabled public cChange oldQLineDetails{set;get;}
        @AuraEnabled public cChange newQLineDetails{set;get;}
        public cChanges(){
            oldQLineDetails = new cChange();
            newQLineDetails = new cChange();
        }
    }
    public class cChange{
        @AuraEnabled public string quantity{set;get;}
        @AuraEnabled public string equipmentSize{set;get;}
        @AuraEnabled public string equipmentType{set;get;}
        @AuraEnabled public string wasteStream{set;get;}
        @AuraEnabled public string wasteStreamMaterialType{set;get;}//Added for the change related to SDT-28899
        @AuraEnabled public string companyCategory{set;get;}
        @AuraEnabled public string locationPosition{set;get;}
		@AuraEnabled public string locationPositionName{set;get;}
        @AuraEnabled public string sCode{set;get;}
        @AuraEnabled public List<serviceLine> serviceLines{set;get;}
        public cChange(){
           serviceLines = new List<serviceLine>();
        }
    }
    public class serviceLine{
        @AuraEnabled public string service{set;get;}
        @AuraEnabled public string schedule{set;get;}
        @AuraEnabled public string cost{set;get;}
        @AuraEnabled public string price{set;get;}
        
         //TCS-SDT-32165-Added following members
        @AuraEnabled public string cUnitOfMeasurement{set;get;}
        @AuraEnabled public string pUnitOfMeasurement{set;get;}
        @AuraEnabled public string cMinimumQuantity{set;get;}
        @AuraEnabled public string pMinimumQuantity{set;get;}
        @AuraEnabled public string pricingMethod{set;get;}
        @AuraEnabled public string costModelType{set;get;}
        @AuraEnabled public string costUpTo1{set;get;}
        @AuraEnabled public string costUpTo2{set;get;}
        @AuraEnabled public string costUpTo3{set;get;}
        @AuraEnabled public string costUpTo4{set;get;}
        @AuraEnabled public string steppedCost1{set;get;}
        @AuraEnabled public string steppedCost2{set;get;}
        @AuraEnabled public string steppedCost3{set;get;}
        @AuraEnabled public string steppedCost4{set;get;}
        @AuraEnabled public string priceUpTo1{set;get;}
        @AuraEnabled public string priceUpTo2{set;get;}
        @AuraEnabled public string priceUpTo3{set;get;}
        @AuraEnabled public string priceUpTo4{set;get;}
        @AuraEnabled public string steppedPrice1{set;get;}
        @AuraEnabled public string steppedPrice2{set;get;}
        @AuraEnabled public string steppedPrice3{set;get;}
        @AuraEnabled public string steppedPrice4{set;get;}
         //TCS-SDT-32165-End
        @AuraEnabled public string startDate{set;get;}
        @AuraEnabled public string EndDate{set;get;}
        @AuraEnabled public string Vendor{set;get;}
        @AuraEnabled public String productId{set;get;}
        @AuraEnabled public String quantity{set;get;}	//pkulkar-TCS-08-May-23-Added as per SDT-29623
		@AuraEnabled public String qlId{set;get;}	//Seema-TCS-22-11-23-Added as per SDT-33136
        @AuraEnabled public String monthlyScheduleDetails{set;get;}	//SDT-41407
    }
    @AuraEnabled
    public static SBQQ__QuoteLine__c getclassificationChanges1(string pQLineId){
        SBQQ__QuoteLine__c pqLine = new SBQQ__QuoteLine__c();
        List<SBQQ__QuoteLine__c> pqLineList = new List<SBQQ__QuoteLine__c>();
        pqLineList = [SELECT id, SBQQ__Quantity__c, Equipment_Size__c, SBQQ__Product__r.Name, SBQQ__Product__r.Family,
                        //SDT41407
                      Frequency_Interval__c,Schedule_Frequency__c,Day_of_Month__c,Month_Relative_Interval__c,Month_Relative__c,
                      Initial_Classification_Changes__c, CompanyCategoryName__c,Location_Position_Name__r.Name, sCode__c, LocationPositionName__c,
                      AssetId__c, AssetId__r.Quantity__c, AssetId__r.Equipment_Size__c, AssetId__r.Equipment_Type__c, 
                      AssetId__r.CPQ_Product__r.Family, AssetId__r.Category__c, AssetId__r.Location__r.Name, AssetId__r.Sensitivity_Code__c, 
                      (SELECT id, SBQQ__Product__r.Name, Service_Schedule__c, SBQQ__UnitCost__c, SBQQ__ListPrice__c, SBQQ__StartDate__c,
                       SBQQ__EndDate__c, Vendor__r.Name, Initial_Classification_Changes__c FROM SBQQ__Quote_Lines__r)
                      FROM SBQQ__QuoteLine__c 
                      WHERE id=:pQLineId
                     ];//Added LocationPositionName__c for solution related to SDT-28900
        if(pqLineList.size()>0){
			pqLine = pqLineList[0];
        }
        return pqLine;
    }

    //Method Ddescription : For changes SDT-28899 - below would only run to identify the waste stream child quote line and get the waste stream from the same.
    @AuraEnabled
    public static String getWasteStreamForParentQuoteLine(string pQLineId){
        String strMaterialCategoryType =Constant_Util.EMPTY_STRING;
        String strProductFamilyName = QuoteLineServices.PRODUCTFAMILY_WASTESTREAM;
        List<SBQQ__QuoteLine__c> lstChildQuoteLines = new List<SBQQ__QuoteLine__c>();
        if(String.isNotBlank(pQLineId)){
            lstChildQuoteLines = [SELECT Id,Name,AssetId__r.CPQ_Product__r.Family,SBQQ__Product__r.Name, SBQQ__Product__r.Family,SBQQ__ProductFamily__c,SBQQ__ProductName__c,
                                  SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.SBQQ__RequiredBy__c 
                                  from SBQQ__QuoteLine__c WHERE 
                                  (SBQQ__RequiredBy__c =: pQLineId OR SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =: pQLineId)];
            if(lstChildQuoteLines.size()>0){
                for(SBQQ__QuoteLine__c qLine : lstChildQuoteLines){
                    if(qLine.SBQQ__ProductFamily__c == strProductFamilyName )
                    {
                        strMaterialCategoryType = qLine.SBQQ__ProductName__c;
                    }
                }
            }
        }
        return strMaterialCategoryType;
    }

    public class initialcChange{
        public String wasteStream;
        public String wasteStreamMaterialType;//Added for the change related to SDT-28899
        public String vendor;
        public String startDate;
        public String service;
        public String sCode;
        public String schedule;
        public String quantity;
        public String price;
        //TCS-SDT-32165-Added following members
        public String cUnitOfMeasurement;
        public String pUnitOfMeasurement;
        public String cMinimumQuantity;
        public String pMinimumQuantity;
        public string pricingMethod;
        public string costModelType;
        public string costUpTo1;
        public string costUpTo2;
        public string costUpTo3;
        public string costUpTo4;
        public string steppedCost1;
        public string steppedCost2;
        public string steppedCost3;
        public string steppedCost4;
        public string priceUpTo1;
        public string priceUpTo2;
        public string priceUpTo3;
        public string priceUpTo4;
        public string steppedPrice1;
        public string steppedPrice2;
        public string steppedPrice3;
        public string steppedPrice4;
        
        //TCS-SDT-32165-Added following members
        public String locationPosition;
        public String locationPositionName; //Added for Changes Required in SDT-28900
        public String equipmentType;
        public String equipmentSize;
        public String endDate;
        public String cost;
        public String companyCategory;
        public String productId;
        //SDT 41407
        public String monthlyScheduleDetails;
        public initialcChange parse(String json){
            return (initialcChange) System.JSON.deserialize(json, initialcChange.class);
        }
    }

    //TCS-pkulkarn-SDT-32107-10-Sep-2024-Added
    public static void retrieveAssetsOfMissingQuoteLines(cChanges QuoteLineAssetDifferences, Id RootAssetId, List<SBQQ__QuoteLine__c> childQuoteLines)
    {
        Set<Id> childQuoteLineAssetIds = new Set<Id>();

        if(String.valueOf(RootAssetId) != null && String.valueOf(RootAssetId) != '')
        {
            //Get the Child Quote Lines' Asset Ids
            for(SBQQ__QuoteLine__c quoteLine : childQuoteLines)
            {
                childQuoteLineAssetIds.add(quoteLine.AssetId__c);
            }

            //Query Active Assets (having null end date) which are missing Quote Lines
            List<Asset> assetsTobeDisplayed = new List<Asset>();
            assetsTobeDisplayed = [SELECT Id, CPQ_Product__r.Name, SBQQ__OriginalUnitCost__c, SBQQ__RegularPrice__c, Cost_Unit__c, Price_Unit__c, Cost_Minimum_Quantity__c, Price_Minimum_Quantity__c, 
                                   Cost_UpTo_1__c, Cost_UpTo_2__c, Cost_UpTo_3__c, Cost_UpTo_4__c, Cost_Price_1__c, Cost_Price_2__c, Cost_Price_3__c, Cost_Price_4__c, 
                                   Price_UpTo_1__c, Price_UpTo_2__c, Price_UpTo_3__c, Price_UpTo_4__c, Price_Price_1__c, Price_Price_2__c, Price_Price_3__c, Price_Price_4__c,
                                   Price_Model_Type__c, Cost_Model_Type__c, Start_Date__c, End_Date__c, Supplier__r.Name, Quantity__c, RootAssetId,
                                   Occurrence_Type__c, Occurs__c, Frequency__c, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c,
                                   Of_Month__c, Month_Relative__c, Month_Relative_Interval__c
                                   FROM Asset
                                   WHERE Id != :RootAssetId AND
                                   RootAssetId =: RootAssetId AND
                                   End_Date__c = null
                                   ORDER BY CPQ_Product__r.Name];
            
            for(Asset ast : assetsTobeDisplayed)
            {
                if(childQuoteLineAssetIds.contains(ast.Id) == false)
                {
                    serviceLine sLine = new serviceLine();
                    createLine(sLine, ast);
                    QuoteLineAssetDifferences.oldQLineDetails.serviceLines.add(sLine);
                }
            }
        }
    }
    //TCS-pkulkarn-SDT-32107-10-Sep-2024-End
    
    //TCS-pkulkarn-SDT-32107-10-Sep-2024-Added
    public static void createLine(serviceLine sLine, Asset ast)
    {
        sLine.service = ast.CPQ_Product__r.Name;
        sLine.schedule = getServiceSchedule(ast);
        
        //Handle Mondthly schedule
        SBQQ__QuoteLine__c tempQuoteLine = new SBQQ__QuoteLine__c();
        tempQuoteLine.Schedule_Frequency__c = ast.Frequency__c == 'Daily'? 'D' : ast.Frequency__c == 'Weekly'? 'W' : ast.Frequency__c == 'Monthly'? 'M' : ast.Frequency__c == 'Yearly'? 'Y' : null;
        tempQuoteLine.Day_of_Month__c = ast.Of_Month__c != null ? integer.valueof(ast.Of_Month__c) : null;
        tempQuoteLine.SBQQ__StartDate__c = ast.Start_Date__c;
        tempQuoteLine.Frequency_Interval__c = ast.Occurs__c;
        tempQuoteLine.Month_Relative_Interval__c = ast.Month_Relative_Interval__c;
        tempQuoteLine.Month_Relative__c = ast.Month_Relative__c;
        sLine.monthlyScheduleDetails = QuoteLineServices.generateMonthlyScheduleDetails(tempQuoteLine);
        
        sLine.cost = string.valueOf(ast.SBQQ__OriginalUnitCost__c);
        sLine.price = string.valueOf(ast.SBQQ__RegularPrice__c);
        sLine.cUnitOfMeasurement =  string.valueOf(ast.Cost_Unit__c);
        sLine.pUnitOfMeasurement = string.valueOf(ast.Price_Unit__c); 
        sLine.cMinimumQuantity = ast.Cost_Minimum_Quantity__c != null ? string.valueOf(ast.Cost_Minimum_Quantity__c.setScale(2)) : string.valueOf(ast.Cost_Minimum_Quantity__c);
        sLine.pMinimumQuantity = ast.Price_Minimum_Quantity__c!=null ? string.valueOf(ast.Price_Minimum_Quantity__c.setScale(2)) : string.valueOf(ast.Price_Minimum_Quantity__c);		
        sLine.costUpTo1 = string.valueOf(ast.Cost_UpTo_1__c);
        sLine.costUpTo2 = string.valueOf(ast.Cost_UpTo_2__c);
        sLine.costUpTo3 = string.valueOf(ast.Cost_UpTo_3__c);
        sLine.costUpTo4 = string.valueOf(ast.Cost_UpTo_4__c);
        sLine.steppedCost1 = string.valueOf(ast.Cost_Price_1__c);
        sLine.steppedCost2 = string.valueOf(ast.Cost_Price_2__c);
        sLine.steppedCost3 = string.valueOf(ast.Cost_Price_3__c);
        sLine.steppedCost4 = string.valueOf(ast.Cost_Price_4__c);
        sLine.priceUpTo1 = string.valueOf(ast.Price_UpTo_1__c);
        sLine.priceUpTo2 = string.valueOf(ast.Price_UpTo_2__c);
        sLine.priceUpTo3 = string.valueOf(ast.Price_UpTo_3__c);
        sLine.priceUpTo4 = string.valueOf(ast.Price_UpTo_4__c);
        sLine.steppedPrice1 = string.valueOf(ast.Price_Price_1__c);
        sLine.steppedPrice2 = string.valueOf(ast.Price_Price_2__c);
        sLine.steppedPrice3 = string.valueOf(ast.Price_Price_3__c);
        sLine.steppedPrice4 = string.valueOf(ast.Price_Price_4__c);
        sLine.pricingMethod = UTIL_Picklist.getPickListLabelByAPIValue('SBQQ__QuoteLine__c', 'SBQQ__PricingMethod__c', ast.Price_Model_Type__c);
        sLine.costModelType = string.valueOf(ast.Cost_Model_Type__c);
        sLine.startDate = string.valueOf(ast.Start_Date__c);
        sLine.EndDate = string.valueOf(ast.End_Date__c);
        sLine.Vendor = ast.Supplier__r.Name;
        sLine.qlId = ast.Id;
        sLine.quantity = String.valueOf(ast.Quantity__c);
        setSteppedCostAndPrice(sLine);	//TCS-pkulkarn-SDT-40565-12-Sep-2024-Added
    }
    //TCS-pkulkarn-SDT-32107-10-Sep-2024-End
    
    //TCS-pkulkarn-SDT-32107-10-Sep-2024-Added
    public static String getServiceSchedule(Asset ast)
    {
        String serviceSchedule = '';
        String daysOfService = '';
        if(ast.Occurrence_Type__c == Constant_Util.ON_CALL)
        {
            serviceSchedule = ast.Occurrence_Type__c;
        }
        else
        {
            serviceSchedule = 'E' + ast.Occurs__c;
            if(ast.Frequency__c == 'Weekly')
            {
                serviceSchedule = serviceSchedule + 'W(';
                if(ast.Monday__c)
                {
                    daysOfService = daysOfService + 'M';
                }
                if(ast.Tuesday__c)
                {
                    daysOfService = daysOfService + 'T';
                }
                if(ast.Wednesday__c)
                {
                    daysOfService = daysOfService + 'W';
                }
                if(ast.Thursday__c)
                {
                    daysOfService = daysOfService + 'R';
                }
                if(ast.Friday__c)
                {
                    daysOfService = daysOfService + 'F';
                }
                if(ast.Saturday__c)
                {
                    daysOfService = daysOfService + 'Sa';
                }
                if(ast.Sunday__c)
                {
                    daysOfService = daysOfService + 'Su';
                }

                serviceSchedule = serviceSchedule + daysOfService + ') - ';
                //Append final frequency
                if(ast.Frequency__c == 'Daily' || ast.Frequency__c == 'Monthly' || ast.Frequency__c == 'Yearly')
                {
                    serviceSchedule = serviceSchedule + ast.Occurs__c;
                }
                else if(ast.Frequency__c == 'Weekly')
                {
                    Integer count = 0;
                    if(ast.Monday__c)
                    {
                        count = count + 1;
                    }
                    if(ast.Tuesday__c)
                    {
                        count = count + 1;
                    }
                    if(ast.Wednesday__c)
                    {
                        count = count + 1;
                    }
                    if(ast.Thursday__c)
                    {
                        count = count + 1;
                    }
                    if(ast.Friday__c)
                    {
                        count = count + 1;
                    }
                    if(ast.Saturday__c)
                    {
                        count = count + 1;
                    }
                    if(ast.Sunday__c)
                    {
                        count = count + 1;
                    }
                    if(count > 0)
                    {
                        serviceSchedule = serviceSchedule + String.valueOf(count) + 'x';
                    }
                }
            }
        }
        return serviceSchedule;
    }
    //TCS-pkulkarn-SDT-32107-10-Sep-2024-End
        
    //TCS-pkulkarn-SDT-40565-12-Sep-2024-Start	-- Q-08309
    public static void setSteppedCostAndPrice(serviceLine sLine)
    {
        String sStepped = 'Stepped';
        String sSTP = 'STP';	//Asset's Price Model Type stores the value as STP for Stepped pricing (updated from Acorn) 
        
        if((String.valueOf(sLine.pricingMethod) == sStepped || String.valueOf(sLine.pricingMethod) == sSTP))
        {
            sLine.price = sLine.steppedPrice1;
        }
        if((String.valueOf(sLine.costModelType) == sStepped || String.valueOf(sLine.costModelType) == sSTP))
        {
            sLine.cost = sLine.steppedCost1;
        }
    }
    //TCS-pkulkarn-SDT-40565-12-Sep-2024-End
}