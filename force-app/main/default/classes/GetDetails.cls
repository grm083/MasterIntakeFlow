public  class GetDetails {
    
    public SBQQ__Quote__c objQuote{get;set;}
    public  Set<String> keyValues{get;set;}
    public  Set<String> result {get;set;}
    public List<Integer> lstcount{get;set;}
    public Map<Id,Integer> mapCount{get;set;}
    public Map<String, List<SBQQ__QuoteLine__c>> quoteLineMap{get;set;}
    public Map<Id,SBQQ__QuoteLine__c> mQLI{get;set;}      
    public Map<Id,String> mQLIMaterialCode {get;set;}
    //SDT 33101
    public Map<Id,String> mQLISchedule {get;set;}
    public Map<Id,String> mQLIScheduleAsset {get;set;}// For Asset 
    public Set<Id>priceNames {get;set;}
    public Map<Id,List<priceWrapper>> priceDetailsMap {get;set;}
    public Map<Id,List<priceWrapper>> priceDetailsMapAll {get;set;}
    public Map<Id,configWrapper> configMap{get;set;}
    public Map<Id,List<configWrapper>> childConfigMap {get;set;}
    public Boolean isHaulAway{get;set;}

    public SBQQ__Quote__c getQuoteFields(){ 
        //Changes related to SDT - 19967
        //SDT 33101 adding Quote_Thread_Id__c
       string QId = objQuote.Id;
    //  string QId = 'a9LVF0000004TMn2AM';
        SBQQ__Quote__c sbQRec = [SELECT id,Name,Quote_Thread_Id__c,SBQQ__Opportunity2__r.Case__r.Supplier__r.Name,SBQQ__Account__r.Address__c,SBQQ__Account__r.Parent.Name,SBQQ__Opportunity2__c
        ,SBQQ__Opportunity2__r.Case__r.Material_Type__c,SBQQ__Account__r.Common_Name__c,SBQQ__Opportunity2__r.Case__r.Service_Date__c,SBQQ__Opportunity2__r.Case__c,SBQQ__Opportunity2__r.Case__r.Reference_Number__c
        ,SBQQ__Opportunity2__r.Case__r.Supplier__c,SBQQ__Opportunity2__r.Case__r.Location_Code__c,SBQQ__Opportunity2__r.Case__r.Location__r.Customer_Location_Code__c,SBQQ__Opportunity2__r.Case__r.Location_Name_Email_Temp__c
        ,SBQQ__Opportunity2__r.Case__r.Contact_Name__c,SBQQ__Opportunity2__r.Case__r.Tech_Location_Details__c,SBQQ__Opportunity2__r.Case__r.CaseNumber
        ,SBQQ__Opportunity2__r.Case__r.Equipment_Type_Code__c,SBQQ__Opportunity2__r.Case__r.Case_Type__c,SBQQ__Opportunity2__r.Case__r.Case_Sub_Type__c
        ,SBQQ__Opportunity2__r.Case__r.Case_Reason__c, SBQQ__StartDate__c,Duration__c, SBQQ__Notes__c, SBQQ__Account__c, SBQQ__Account__r.Name, SBQQ__ShippingStreet__c, SBQQ__ShippingState__c
        ,SBQQ__ShippingPostalCode__c, SBQQ__PrimaryContact__r.Name, SBQQ__PrimaryContact__r.Account_Title__r.Name,CurrencyIsoCode, SBQQ__Opportunity2__r.Case__r.Location__r.Name
        FROM SBQQ__Quote__c WHERE id =:QId];            
        if(sbQRec != null){
            return sbQRec;
        }
        else{
            return null;
        }
    }    
    
    public Set<String> getWrapperData(){       
        mapCount = new Map<Id,Integer>();
       integer count= 1;
           string QId = objQuote.Id;
     //   string QId = 'a9LVF0000004TMn2AM';

        quoteLineMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        string wasteStream = 'Waste Stream';
//Changes related to SDT - 19967 - Added additional fields in query
//SDT 33101 new Final_Frequency__c,Service_Days__c
        String query = 'Select Id,AssetId__r.Occurrence_Type__c,Frequency_Interval__c,AssetId__r.Frequency__c,AssetId__r.Occurs__c,AssetId__r.Monday__c,AssetId__r.Tuesday__c,AssetId__r.Wednesday__c,AssetId__r.Thursday__c,AssetId__r.Friday__c,AssetId__r.Saturday__c,AssetId__r.Sunday__c,AssetId__r.ProductFamily,PriceMinQuantity__c,Final_Frequency__c,toLabel(Service_Days__c),toLabel(PriceUOM__c),toLabel(Schedule_Frequency__c),Waste_Stream_Code__c,Service_Schedule__c, Description_of_Waste__c,SBQQ__Quote__c,(Select Id,Service_type__c,Quantity__c,Name from Quote_Orders__r),SBQQ__Quantity__c,Schedule_Type__c, Name, Material_Type__c,toLabel(Equipment_Size__c),toLabel(Occurrence_Type__c),SBQQ__EffectiveStartDate__c,SBQQ__EndDate__c,toLabel(Duration__c),SBQQ__Product__r.Name,SBQQ__Product__r.Family,Material_Type_Code__c,SBQQ__ListPrice__c,PricePrice1__c ,PricePrice2__c,PriceUpTo1__c, sCode__c, Vendor__c,MASCompany__c, Vendor__r.Name,NTE_amount_on_SR__c,Equipment_Style__c,SBQQ__StartDate__C,SBQQ__ProductFamily__c,AssetId__r.MAS_Account_Number__c From SBQQ__QuoteLine__c where SBQQ__Quote__c =: QId and SBQQ__ProductOption__r.SBQQ__Feature__r.Name !=:wasteStream and SBQQ__RequiredBy__c = null  Order BY SBQQ__RequiredBy__c';
        mQLI = new Map<Id,SBQQ__QuoteLine__c>();
        mQLIMaterialCode = new Map<Id,String>();
        //SDT 33101
        mQLISchedule = new Map<Id,String>();
        mQLIScheduleAsset = new Map<Id,String>();
        List<SBQQ__QuoteLine__c> detailRecords = getQuoteDetails(QId);
        
        if(detailRecords.size()>0){
            Case objCase = new Case();
            objCase.Is_Haul_Away_Service__c = detailRecords[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c;
            objCase.Haul_Away_Vendor__c = detailRecords[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c;
            //Pricing in the service charges not to be shown in case of haul away SDT - 45045
        isHaulAway = !HaulAwayService.getIsHaulAwayService(objCase); 
        }
        
        
        for(SBQQ__QuoteLine__c qlObj : Database.query(query)) {           
            mQLI.put(qlObj.Id,qlObj);
            mapCount.put(qlObj.Id,count++);
            for (SBQQ__QuoteLine__c detail: detailRecords) {
                If(detail.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == qlObj.Id || detail.SBQQ__RequiredBy__c == qlObj.Id){
                    if (detail.SBQQ__ProductFamily__c == 'Waste Stream') {
                        mQLIMaterialCode.put(qlObj.Id,detail.SBQQ__ProductName__c);
                    }
                    //SDT 33101
                    mQLISchedule.put(qlObj.Id,getServiceSchedule(qlObj));
                  //  mQLIScheduleAsset.put(qlObj.Id,getServiceScheduleAsset(qlObj.AssetId__c));// For Asset
                }                   
            }
            
        }
        set<Id> sQLID =  mQLI.keySet();
        priceDetailsMap =new Map<Id,List<priceWrapper>>();
        priceDetailsMapAll =new Map<Id,List<priceWrapper>>();
        //Changes related to SDT - 19967 - Added additional fields in query
        query = 'Select Id,SBQQ__PricingMethod__c,PriceUpTo2__c,PriceUpTo1__c,PricePrice1__c,PricePrice2__c,PriceMinQuantity__c,toLabel(PriceUOM__c),toLabel(Equipment_Size__c),Waste_Stream_Code__c, Service_Schedule__c, SBQQ__Quote__c,SBQQ__RequiredBy__r.SBQQ__ProductFamily__c,SBQQ__RequiredBy__r.SBQQ__ProductName__c,SBQQ__ProductName__c,SBQQ__Quantity__c,SBQQ__StartDate__c,Schedule_Type__c,Duration__c,toLabel(Schedule_Frequency__c), Name,(Select Id,Service_type__c from Quote_Orders__r),Material_Type__c,NTE_amount_on_SR__c,SBQQ__ListPrice__c,toLabel(Occurrence_Type__c), SBQQ__RequiredBy__r.Original_Equipment_Size__c,SBQQ__EffectiveStartDate__c,SBQQ__EndDate__c, SBQQ__RequiredBy__r.Duration__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Name,SBQQ__Product__r.Family,Material_Type_Code__c, SBQQ__Product__r.Name, sCode__c, Vendor__c,MASCompany__c, Vendor__r.Name,Equipment_Style__c, AssetId__r.MAS_Account_Number__c  From SBQQ__QuoteLine__c where SBQQ__Quote__c =: QId  and SBQQ__ProductOption__r.SBQQ__Feature__r.Name !=:wasteStream and ( SBQQ__RequiredBy__c in:sQLID OR SBQQ__RequiredBy__c = null)  Order BY SBQQ__RequiredBy__c';
                for(SBQQ__QuoteLine__c qlObj : Database.query(query)) {  
            ////Changes related to SDT - 19967 - method for creating priceWrapper object
            createPriceWrapper(qlObj,priceDetailsMap);
            createPriceWrapperAllProducts(qlObj,priceDetailsMapAll);        
            List<SBQQ__QuoteLine__c> lQuoteLines = new List<SBQQ__QuoteLine__c>();
            string key = qlObj.SBQQ__RequiredBy__c;
            if(quoteLineMap.containsKey(key)){
                lQuoteLines = quoteLineMap.get(key);
            }
            lQuoteLines.add(qlObj);            quoteLineMap.put(key,lQuoteLines);
            
            //lstcount.add(count+1);
            //count++;
            
        }
        keyValues = quoteLineMap.keyset();
        return keyValues;
    }  
    
    public String getDateFormat() {
        return 'MMMM dd yyyy';
    }
    
    //Returns the detail records for waste steam quote line
        //Querying Case id to check haul away SDT - 45045
    public static List<SBQQ__QuoteLine__c> getQuoteDetails(Id quoteIds) {
        
        List<SBQQ__QuoteLine__c> materialCodeQLList = [SELECT Id, SBQQ__Product__r.Name,SBQQ__ProductFamily__c,
                                                       SBQQ__RequiredBy__r.SBQQ__RequiredBy__c,SBQQ__RequiredBy__c,
                                                       SBQQ__ProductName__c, Service_Schedule__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c,
                                                       SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c
                                                       FROM SBQQ__QuoteLine__c 
                                                       WHERE SBQQ__Product__r.Family = 'Waste Stream' 
                                                       AND SBQQ__Quote__c =: quoteIds
                                                      ];
        return materialCodeQLList;
        
    }

    //Returns the Map of quotelines to be shown
    public static void createPriceWrapper(SBQQ__QuoteLine__c qlObj,Map<Id,List<priceWrapper>> priceDetailsMap) {
        if(qlObj.SBQQ__RequiredBy__c!= null && qlObj.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c ==Constant_Util.COMMERCIAL && (qlObj.SBQQ__Product__r.Name ==Constant_Util.ServiceType_Delivery ||qlObj.SBQQ__Product__r.Name ==Constant_Util.PR_PICKUP ||qlObj.SBQQ__Product__r.Name ==Constant_Util.EXTRA_PICKUP)){
            priceWrapper pri = new priceWrapper();
            pri.productName = qlObj.SBQQ__ProductName__c; 
            //SDT 33101
            pri.UOM = qlObj.PriceUOM__c;
            //modified as part of SDT-44641
            if(qlObj.SBQQ__Quantity__c != null && qlObj.SBQQ__ListPrice__c != null) {
                pri.price = (qlObj.SBQQ__ListPrice__c * qlObj.SBQQ__Quantity__c).setScale(2);
            }
            pri.parentProductName = qlObj.SBQQ__RequiredBy__r.SBQQ__ProductName__c;
            if(!priceDetailsMap.containsKey(qlObj.SBQQ__RequiredBy__c)){
                priceDetailsMap.put(qlObj.SBQQ__RequiredBy__c,new List<priceWrapper>{pri}); 
            }
            else{
                priceDetailsMap.get(qlObj.SBQQ__RequiredBy__c).add(pri);
            }
        }
        else if(qlObj.SBQQ__RequiredBy__c!= null && qlObj.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c ==Constant_Util.ROLLOFF && (qlObj.SBQQ__Product__r.Name == Constant_Util.ServiceType_Delivery ||qlObj.SBQQ__Product__r.Name ==Constant_Util.RENTAL ||qlObj.SBQQ__Product__r.Name ==Constant_Util.HAUL ||qlObj.SBQQ__Product__r.Name ==Constant_Util.DISPOSAL)){
            priceWrapper pri = new priceWrapper();
            pri.productName = qlObj.SBQQ__ProductName__c;
            //SDT 33101
            pri.UOM = qlObj.PriceUOM__c; 
            if(qlObj.PriceMinQuantity__c != null && qlObj.SBQQ__ListPrice__c != null)
                        {
                            pri.disposalNewPrice = (qlObj.PriceMinQuantity__c * qlObj.SBQQ__ListPrice__c).setScale(2);
                        }
            if(qlObj.SBQQ__Quantity__c != null && qlObj.SBQQ__ListPrice__c != null)
                   {
                       pri.newListUnitPrice = (qlObj.SBQQ__ListPrice__c * qlObj.SBQQ__Quantity__c).setScale(2);
                   }
            pri.priceMinimumQty = String.valueOf(qlObj.PriceMinQuantity__c);
                        pri.steppedPrice1 = String.valueOf(qlObj.PricePrice1__c);
                        pri.steppedPrice2 = String.valueOf(qlObj.PricePrice2__c);
                        pri.step1UptoTons = String.valueOf(qlObj.PriceUpTo1__c);
                        pri.step2UptoTons = String.valueOf(qlObj.PriceUpTo2__c);
                        pri.pricingMethod = String.valueOf(qlObj.SBQQ__PricingMethod__c);
            //SDT 33101 end
            pri.price = qlObj.SBQQ__ListPrice__c;
            pri.parentProductName = qlObj.SBQQ__RequiredBy__r.SBQQ__ProductName__c;
            if(!priceDetailsMap.containsKey(qlObj.SBQQ__RequiredBy__c)){
                priceDetailsMap.put(qlObj.SBQQ__RequiredBy__c,new List<priceWrapper>{pri}); 
            }
            else{
              //  priceDetailsMap.get(qlObj.SBQQ__RequiredBy__c).add(pri);
              
                
            }
        }
        
    }
    
     //Returns the Map of quotelines to be shown
    public static void createPriceWrapperAllProducts(SBQQ__QuoteLine__c qlObj,Map<Id,List<priceWrapper>> priceDetailsMapAll) {
        if(qlObj.SBQQ__RequiredBy__c!= null && qlObj.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c ==Constant_Util.COMMERCIAL && (qlObj.SBQQ__Product__r.Name ==Constant_Util.ServiceType_Delivery ||qlObj.SBQQ__Product__r.Name ==Constant_Util.PR_PICKUP ||qlObj.SBQQ__Product__r.Name ==Constant_Util.EXTRA_PICKUP)){
            priceWrapper pri = new priceWrapper();
            pri.productName = qlObj.SBQQ__ProductName__c; 
            pri.productFamily = qlObj.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c;
            //SDT 33101
            pri.UOM = qlObj.PriceUOM__c;
            //modified as part of SDT-
            if(qlObj.SBQQ__Quantity__c != null && qlObj.SBQQ__ListPrice__c != null) {
            	pri.price = (qlObj.SBQQ__ListPrice__c * qlObj.SBQQ__Quantity__c).setScale(2);
			}
            pri.parentProductName = qlObj.SBQQ__RequiredBy__r.SBQQ__ProductName__c;
            if(!priceDetailsMapAll.containsKey(qlObj.SBQQ__RequiredBy__c)){
                priceDetailsMapAll.put(qlObj.SBQQ__RequiredBy__c,new List<priceWrapper>{pri}); 
            }
            else{
                priceDetailsMapAll.get(qlObj.SBQQ__RequiredBy__c).add(pri);
            }
        }
        else if(qlObj.SBQQ__RequiredBy__c!= null && qlObj.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c ==Constant_Util.ROLLOFF && (qlObj.SBQQ__Product__r.Name == Constant_Util.ServiceType_Delivery ||qlObj.SBQQ__Product__r.Name ==Constant_Util.RENTAL ||qlObj.SBQQ__Product__r.Name ==Constant_Util.HAUL ||qlObj.SBQQ__Product__r.Name ==Constant_Util.DISPOSAL)){
            priceWrapper pri = new priceWrapper();
            pri.productName = qlObj.SBQQ__ProductName__c;
            pri.productFamily = qlObj.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c;
            //SDT 33101
            pri.UOM = qlObj.PriceUOM__c; 
            if(qlObj.PriceMinQuantity__c != null && qlObj.SBQQ__ListPrice__c != null)
                        {
                            pri.disposalNewPrice = (qlObj.PriceMinQuantity__c * qlObj.SBQQ__ListPrice__c).setScale(2);
                        }
            if(qlObj.SBQQ__Quantity__c != null && qlObj.SBQQ__ListPrice__c != null)
                   {
                       pri.newListUnitPrice = (qlObj.SBQQ__ListPrice__c * qlObj.SBQQ__Quantity__c).setScale(2);
                   }
            pri.priceMinimumQty = String.valueOf(qlObj.PriceMinQuantity__c);
                        pri.steppedPrice1 = String.valueOf(qlObj.PricePrice1__c);
                        pri.steppedPrice2 = String.valueOf(qlObj.PricePrice2__c);
                        pri.step1UptoTons = String.valueOf(qlObj.PriceUpTo1__c);
                        pri.step2UptoTons = String.valueOf(qlObj.PriceUpTo2__c);
                        pri.pricingMethod = String.valueOf(qlObj.SBQQ__PricingMethod__c);
            //SDT 33101 end
            pri.price = qlObj.SBQQ__ListPrice__c;
            pri.parentProductName = qlObj.SBQQ__RequiredBy__r.SBQQ__ProductName__c;
            if(!priceDetailsMapAll.containsKey(qlObj.SBQQ__RequiredBy__c)){
               priceDetailsMapAll.put(qlObj.SBQQ__RequiredBy__c,new List<priceWrapper>{pri}); 
            }
            else{
                 priceDetailsMapAll.get(qlObj.SBQQ__RequiredBy__c).add(pri);
              
                
            }
        }
        else
        {
            priceWrapper pri = new priceWrapper();
            pri.productName = qlObj.SBQQ__ProductName__c; 
            //SDT 33101
            pri.UOM = qlObj.PriceUOM__c;
            //modified as part of SDT-
            if(qlObj.SBQQ__Quantity__c != null && qlObj.SBQQ__ListPrice__c != null) {
            	pri.price = (qlObj.SBQQ__ListPrice__c * qlObj.SBQQ__Quantity__c).setScale(2);
			}
            pri.parentProductName = qlObj.SBQQ__RequiredBy__r.SBQQ__ProductName__c;
            if(!priceDetailsMapAll.containsKey(qlObj.SBQQ__RequiredBy__c)){
                priceDetailsMapAll.put(qlObj.SBQQ__RequiredBy__c,new List<priceWrapper>{pri}); 
            }
            else{
                priceDetailsMapAll.get(qlObj.SBQQ__RequiredBy__c).add(pri);
            }}
        
    }
    
    public Set<String> getMaterialCode(){        
        result= new Set<String>();              
        for(String a : mQLIMaterialCode.keySet()){          
            result.add(a);            
        }      
        return result;
    }
    //SDT 33101
    public Set<String> getServiceSchedule(){        
        result= new Set<String>();              
        for(String a : mQLISchedule.keySet()){          
            result.add(a);            
        }      
        return result;
    }
    /*
    public Set<String> getServiceScheduleAsset(){        
        result= new Set<String>();              
        for(String a : mQLIScheduleAsset.keySet()){          
            result.add(a);            
        }      
        return result;
    }*/
    
    public User getuser()
    {
        return [SELECT id, FirstName, LastName, Email, Phone FROM USER WHERE id=:UserInfo.getUserId()];
    }

   //Method for addChange 
     public Set<String> getConfigData(){
        
      string QId = objQuote.Id;
        quoteLineMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        string wasteStream = 'Waste Stream';
     // string QId = 'a9LVF0000004xRJ2AY';
        
        
        //  String query = 'Select Id,Service_Days__c,Final_Frequency__c,CostMinQuantity__c,SBQQ__UnitCost__c,PricePrice2__c,PricePrice1__c,CostStep01UpTo__c,toLabel(PriceUOM__c),toLabel(Equipment_Size__c),Waste_Stream_Code__c,AssetId__r.Quantity__c,AssetId__r.Equipment_Size__c,AssetId__r.Occurrence_Type__c,AssetId__r.Price__c,Service_Schedule__c,Duration__c, SBQQ__Quote__c,SBQQ__RequiredBy__r.SBQQ__ProductFamily__c,SBQQ__RequiredBy__r.SBQQ__ProductName__c,SBQQ__ProductName__c,SBQQ__Quantity__c,Initial_Classification_Changes__c,toLabel(Schedule_Frequency__c), Name,(Select Id,Service_type__c from Quote_Orders__r),Material_Type__c,NTE_amount_on_SR__c,SBQQ__ListPrice__c,toLabel(Occurrence_Type__c), SBQQ__RequiredBy__r.Original_Equipment_Size__c,SBQQ__EffectiveStartDate__c,SBQQ__EndDate__c, SBQQ__RequiredBy__r.Duration__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Name,SBQQ__Product__r.Family,Material_Type_Code__c, SBQQ__Product__r.Name, sCode__c, Vendor__c, Vendor__r.Name, PriceMinQuantity__c, PriceUpTo1__c, PriceUpTo2__c, SBQQ__PricingMethod__c, AssetId__r.Price_Unit__c  From SBQQ__QuoteLine__c where SBQQ__Quote__c =: QId  and SBQQ__ProductOption__r.SBQQ__Feature__r.Name !=:wasteStream and ( SBQQ__RequiredBy__c in:sQLID OR SBQQ__RequiredBy__c = null)  Order BY SBQQ__RequiredBy__c';
        //SDT 44716 SysHistoryTracking__c
        //SDT 33101 added Service_Schedule__c,Service_Days__c,Final_Frequency__c
        String query = 'Select Id,SysHistoryTracking__c,AssetId__c,Frequency_Interval__c,AssetId__r.Price_Model_Type__c,AssetId__r.SBQQ__ListPrice__c,AssetId__r.Price_Price_1__c,AssetId__r.Price_Price_2__c,AssetId__r.Price_UpTo_1__c,AssetId__r.Price_UpTo_2__c,AssetId__r.SBQQ__PricingMethod__c,' +
            'AssetId__r.ProductFamily,AssetId__r.Price_Minimum_Quantity__c,AssetId__r.Duration__c,AssetId__r.Price_Unit__c,toLabel(Service_Days__c),Final_Frequency__c,CostMinQuantity__c,' +
            'PriceMinQuantity__c,SBQQ__UnitCost__c,PricePrice2__c,PricePrice1__c,CostStep01UpTo__c,toLabel(PriceUOM__c),AssetId__r.Quantity__c,AssetId__r.Equipment_Size__c,AssetId__r.Occurrence_Type__c,' +
            'AssetId__r.Schedule__c,AssetId__r.Price__c,toLabel(Schedule_Frequency__c),Waste_Stream_Code__c,Service_Schedule__c, Description_of_Waste__c,SBQQ__Quote__c,' +
            '(Select Id,Service_type__c,Quantity__c,Name from Quote_Orders__r),SBQQ__Quantity__c,Equipment_Style__c,Schedule_Type__c,SBQQ__StartDate__c, Name, Material_Type__c,SBQQ__ProductFamily__c,toLabel(Equipment_Size__c),toLabel(Occurrence_Type__c),' +
            'SBQQ__EffectiveStartDate__c,SBQQ__EndDate__c,toLabel(Duration__c),SBQQ__Product__r.Name,SBQQ__Product__r.Family,Material_Type_Code__c, sCode__c, Vendor__c, Vendor__r.Name,MASCompany__c,NTE_amount_on_SR__c,' +
            'AssetId__r.Frequency__c,AssetId__r.Occurs__c,AssetId__r.Monday__c,AssetId__r.Tuesday__c,AssetId__r.Wednesday__c,AssetId__r.Thursday__c,AssetId__r.Friday__c,AssetId__r.Saturday__c,AssetId__r.Sunday__c ' +
            'From SBQQ__QuoteLine__c where SBQQ__Quote__c =: QId and SBQQ__ProductOption__r.SBQQ__Feature__r.Name !=:wasteStream and SBQQ__RequiredBy__c = null  Order BY SBQQ__RequiredBy__c';
        
        mQLIMaterialCode = new Map<Id,String>();
        //SDT 33101
        mQLISchedule = new Map<Id,String>();
        List<SBQQ__QuoteLine__c> detailRecords = getQuoteDetails(QId);
        configMap =new Map<Id,configWrapper>();
        mQLI = new Map<Id,SBQQ__QuoteLine__c>();
        
        for(SBQQ__QuoteLine__c qlObj : Database.query(query)) { 
            mQLI.put(qlObj.Id,qlObj);
            //QuoteLineClassificationChanges.initialcChange pqLineInitialcChange = new QuoteLineClassificationChanges.initialcChange();
            //pqLineInitialcChange = pqLineInitialcChange.parse(qlObj.Initial_Classification_Changes__c);
            configWrapper parentConfig = new configWrapper();
            parentConfig.ProductName = qlObj.SBQQ__Product__r.Name; 
            //   parentConfig.oldProductFamily = qlObj.AssetId__r.ProductFamily;//SDT-42568_42538
            parentConfig.ProductFamily = qlObj.SBQQ__ProductFamily__c;//SDT-42568_42538
            parentConfig.oldDuration = qlObj.AssetId__r.Duration__c;
            parentConfig.Duration = qlObj.Duration__c;
            // parentConfig.Duration = qlObj.Duration__c;
            parentConfig.oldQuantity = qlObj.AssetId__r.Quantity__c;
            parentConfig.newQuantity = Integer.valueOf(qlObj.SBQQ__Quantity__c);
            parentConfig.oldEquipmentSize = qlObj.AssetId__r.Equipment_Size__c;
            parentConfig.newEquipmentSize = qlObj.Equipment_Size__c;
            parentConfig.oldOccurenceType = qlObj.AssetId__r.Occurrence_Type__c;
            parentConfig.OccurenceType = qlObj.Occurrence_Type__c;
            parentConfig.oldScheduleFrequency = qlObj.AssetId__r.Schedule__c;//SDT-42568_42538
            parentConfig.newScheduleFrequency = getServiceSchedule(qlObj); //qlObj.Service_Schedule__c;//SDT-42568_42538
            parentConfig.oldPrice = 0;
            parentConfig.newPrice = 0;
            parentConfig.newPriceUOM = qlObj.PriceUOM__c; //SDT-42536_SDT-42538
            parentConfig.oldPriceUOM = qlObj.AssetId__r.Price_Unit__c;

            //SDT 44716
            //code is getting covered by GetDetailsTest.checkAlternateServiceTest()
            SBQQ__QuoteLine__c draftAlternateServiceQL = new SBQQ__QuoteLine__c();
            if(qlObj.SysHistoryTracking__c!='' && qlObj.SysHistoryTracking__c!=null){
                draftAlternateServiceQL = AlternateServiceController.getDraftAlternateServiceDetails(qlObj.SysHistoryTracking__c);
                parentConfig.draftQuantity = Integer.valueOf(draftAlternateServiceQL.SBQQ__Quantity__c);
                parentConfig.draftEquipmentSize = draftAlternateServiceQL.Equipment_Size__c;
                parentConfig.draftProductName = draftAlternateServiceQL.SBQQ__ProductName__c;
                parentConfig.draftOccurenceType = draftAlternateServiceQL.Occurrence_Type__c;
                parentConfig.draftDuration = draftAlternateServiceQL.Duration__c;
                parentConfig.draftScheduleFrequency = getServiceSchedule(draftAlternateServiceQL);
            }
            //SDT 44176
            
            Asset ast = new Asset();
            ast.Occurrence_Type__c = qlObj.AssetId__r.Occurrence_Type__c;
            ast.Frequency__c = qlObj.AssetId__r.Frequency__c;
            ast.Occurs__c = qlObj.AssetId__r.Occurs__c;
            ast.Monday__c = qlObj.AssetId__r.Monday__c;
            ast.Tuesday__c = qlObj.AssetId__r.Tuesday__c;
            ast.Wednesday__c = qlObj.AssetId__r.Wednesday__c;
            ast.Thursday__c  = qlObj.AssetId__r.Thursday__c;
            ast.Friday__c = qlObj.AssetId__r.Friday__c;
            ast.Saturday__c = qlObj.AssetId__r.Saturday__c;
            ast.Sunday__c = qlObj.AssetId__r.Sunday__c;
            parentConfig.oldScheduleFrequency = getServiceScheduleAsset(ast);
            
            configMap.put(qlObj.Id,parentConfig);
            
            for (SBQQ__QuoteLine__c detail: detailRecords) {
                If(detail.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == qlObj.Id || detail.SBQQ__RequiredBy__c == qlObj.Id){
                    if (detail.SBQQ__ProductFamily__c == 'Waste Stream') {
                        mQLIMaterialCode.put(qlObj.Id,detail.SBQQ__ProductName__c);
                    }
                    //SDT 33101
                    mQLISchedule.put(qlObj.Id,getServiceSchedule(qlObj));
                    //   mQLIScheduleAsset.put(qlObj.Id,getServiceScheduleAsset(qlObj));
                }                   
                
            }
            
        }
        integer counter =0;
        
        
        set<Id> sQLID =  mQLI.keySet();
        childConfigMap = new Map<Id,List<configWrapper>>();
        //SDT 33101 added in query,CostMinQuantity__c,SBQQ__UnitCost__c,PricePrice2__c,PricePrice1__c,CostStep01UpTo__c, PriceUpTo1__c, PriceUpTo2__c
        //TCS-pkulkarn-SDT-42459-15-Nov-2024-Added PriceMinQuantity__c, SBQQ__PricingMethod__c
        //TCS-pkulkarn-SDT-42536-15-Nov-2024-Added AssetId__r.Price_Unit__c
        //SDT 44716 SysHistoryTracking__c
        query = 'Select Id,SysHistoryTracking__c,AssetId__c,AssetId__r.Frequency__c,AssetId__r.Occurs__c,AssetId__r.Monday__c,AssetId__r.Tuesday__c,AssetId__r.Wednesday__c,AssetId__r.Thursday__c,AssetId__r.Friday__c,' +
            'AssetId__r.Saturday__c,AssetId__r.Sunday__c,AssetId__r.Price_Model_Type__c,AssetId__r.SBQQ__ListPrice__c,AssetId__r.Price_Price_1__c,AssetId__r.Price_Price_2__c,AssetId__r.Price_UpTo_1__c,AssetId__r.Price_Minimum_Quantity__c,' +
            'AssetId__r.Price_UpTo_2__c,AssetId__r.SBQQ__PricingMethod__c,CostMinQuantity__c,AssetId__r.ProductFamily,AssetId__r.Schedule__c,AssetId__r.Duration__c,SBQQ__UnitCost__c,PricePrice2__c,PricePrice1__c,' +
            'CostStep01UpTo__c,toLabel(PriceUOM__c),toLabel(Equipment_Size__c),SBQQ__ProductFamily__c,Waste_Stream_Code__c,AssetId__r.Quantity__c,AssetId__r.Equipment_Size__c,AssetId__r.Occurrence_Type__c,AssetId__r.Price__c,' +
            'Service_Schedule__c,Duration__c, SBQQ__Quote__c,SBQQ__RequiredBy__r.SBQQ__ProductFamily__c,SBQQ__RequiredBy__r.SBQQ__ProductName__c,SBQQ__ProductName__c,SBQQ__Quantity__c,Schedule_Type__c,SBQQ__StartDate__c,Equipment_Style__c,' +
            'Initial_Classification_Changes__c,toLabel(Schedule_Frequency__c), Name,(Select Id,Service_type__c from Quote_Orders__r),Material_Type__c,NTE_amount_on_SR__c,SBQQ__ListPrice__c,' +
            'toLabel(Occurrence_Type__c), SBQQ__RequiredBy__r.Original_Equipment_Size__c,SBQQ__EffectiveStartDate__c,SBQQ__EndDate__c, SBQQ__RequiredBy__r.Duration__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Name,' +
            'SBQQ__Product__r.Family,Material_Type_Code__c, SBQQ__Product__r.Name, sCode__c, Vendor__c, Vendor__r.Name,MASCompany__c, PriceMinQuantity__c, PriceUpTo1__c, PriceUpTo2__c, SBQQ__PricingMethod__c, AssetId__r.Price_Unit__c  ' +
            'From SBQQ__QuoteLine__c where SBQQ__Quote__c =: QId  and SBQQ__ProductOption__r.SBQQ__Feature__r.Name !=:wasteStream and ( SBQQ__RequiredBy__c in:sQLID OR SBQQ__RequiredBy__c = null)  Order BY SBQQ__RequiredBy__c ';
        List<SBQQ__QuoteLine__c> test = Database.query(query);
        system.debug('size'+test.size());
        system.debug(' *******list '+JSON.serialize(test));
        for(SBQQ__QuoteLine__c qlObj : Database.query(query)) 
        {
            
            if(qlObj.SBQQ__RequiredBy__c!= null && qlObj.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c ==Constant_Util.COMMERCIAL 
               && (qlObj.SBQQ__Product__r.Name ==Constant_Util.ServiceType_Delivery ||qlObj.SBQQ__Product__r.Name ==Constant_Util.PR_PICKUP ||qlObj.SBQQ__Product__r.Name ==Constant_Util.EXTRA_PICKUP)){
                   System.debug('4'+counter);
                   configWrapper childConfig = new configWrapper();
                   //QuoteLineClassificationChanges.initialcChange pqLineInitialcChange = new QuoteLineClassificationChanges.initialcChange();
                   //if(qlObj.Initial_Classification_Changes__c != null){
                   //pqLineInitialcChange = pqLineInitialcChange.parse(qlObj.Initial_Classification_Changes__c);
                   childConfig.oldQuantity = qlObj.AssetId__r.Quantity__c;
                   
                   childConfig.oldEquipmentSize = qlObj.AssetId__r.Equipment_Size__c;
                   childConfig.oldOccurenceType = qlObj.AssetId__r.Occurrence_Type__c;
                   
                   
                   childConfig.newPriceUOM = qlObj.PriceUOM__c; //SDT-42536_SDT-42538
                   childConfig.oldPriceUOM = qlObj.AssetId__r.Price_Unit__c;
                   childConfig.checkAsset = qlObj.AssetId__c;
                   //}
                   //   childConfig.ProductName = qlObj.SBQQ__Product__r.Name;
                   childConfig.productName = qlObj.SBQQ__ProductName__c;//SDT-42536_SDT-42538
                   childConfig.oldProductFamily = qlObj.AssetId__r.ProductFamily;//SDT-42568_42538
                   //    childConfig.newProductFamily = qlObj.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c;//SDT-42568_42538
                   childConfig.ProductFamily = qlObj.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c;//SDT-42536_SDT-42538
                   childConfig.oldDuration = qlObj.AssetId__r.Duration__c;
                   childConfig.Duration = qlObj.Duration__c;
                   //childConfig.oldpriceMinimumQuantity = qlObj.AssetId__r.Price_Minimum_Quantity__c != null ? (qlObj.AssetId__r.Price_Minimum_Quantity__c).setScale(2) : '';
                   childConfig.oldpriceMinimumQuantity = qlObj.AssetId__r.Price_Minimum_Quantity__c;
                   childConfig.newpriceMinimumQuantity = qlObj.PriceMinQuantity__c;
                   
                   childConfig.oldListUnitPrice = (qlObj.AssetId__r.Price__c != null) ? (qlObj.AssetId__r.Price__c).setScale(2) : 0;
                   childConfig.netPrice = childConfig.oldpriceMinimumQuantity != null ? (childConfig.oldpriceMinimumQuantity * childConfig.oldListUnitPrice).setScale(2) : 0;
                   System.debug('***Old price'+childConfig.oldListUnitPrice);
                   //    childConfig. = qlObj.SBQQ__ListPrice__c;//SDT-42536_SDT-42538
                   
                   childConfig.newQuantity = Integer.valueOf(qlObj.SBQQ__Quantity__c);
                   childConfig.newEquipmentSize = qlObj.Equipment_Size__c;
                   childConfig.OccurenceType = qlObj.Occurrence_Type__c;
                   childConfig.oldScheduleFrequency = qlObj.AssetId__r.Schedule__c;//SDT-42568_42538
                   childConfig.newScheduleFrequency = qlObj.Service_Schedule__c;//SDT-42568_42538
                   //  childConfig.newPrice = (qlObj.SBQQ__ListPrice__c * qlObj.SBQQ__Quantity__c).setScale(2);
                   childConfig.oldPrice = (qlObj.AssetId__r.Price__c != null) ? (qlObj.AssetId__r.Price__c).setScale(2) : 0;
                   //  childConfig.newPrice = qlObj.SBQQ__ListPrice__c;//SDT-42536_SDT-42538
                   if(qlObj.SBQQ__Quantity__c != null && qlObj.SBQQ__ListPrice__c != null)//SDT-42536_SDT-42538
                   {
                       childConfig.newListUnitPrice = (qlObj.SBQQ__ListPrice__c * qlObj.SBQQ__Quantity__c).setScale(2);
                   }
                   
                   if(!childConfigMap.containsKey(qlObj.SBQQ__RequiredBy__c)){
                       childConfigMap.put(qlObj.SBQQ__RequiredBy__c,new List<configWrapper>{childConfig}); 
                   }
                   else{
                       childConfigMap.get(qlObj.SBQQ__RequiredBy__c).add(childConfig);
                   }
               }
            else if(qlObj.SBQQ__RequiredBy__c!= null && qlObj.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c == Constant_Util.ROLLOFF && 
                    (qlObj.SBQQ__Product__r.Name == Constant_Util.ServiceType_Delivery ||qlObj.SBQQ__Product__r.Name ==Constant_Util.RENTAL ||qlObj.SBQQ__Product__r.Name ==Constant_Util.HAUL ||qlObj.SBQQ__Product__r.Name ==Constant_Util.DISPOSAL)){
                        
                        System.debug('5'+counter);
                        
                        configWrapper childConfig = new configWrapper();
                        //QuoteLineClassificationChanges.initialcChange pqLineInitialcChange = new QuoteLineClassificationChanges.initialcChange();
                        
                        //if(qlObj.Initial_Classification_Changes__c != null){
                        //pqLineInitialcChange = pqLineInitialcChange.parse(qlObj.Initial_Classification_Changes__c);
                        childConfig.oldQuantity = qlObj.AssetId__r.Quantity__c;
                        childConfig.checkAsset = qlObj.AssetId__c;
                        childConfig.oldEquipmentSize = qlObj.AssetId__r.Equipment_Size__c;
                        childConfig.oldOccurenceType = qlObj.AssetId__r.Occurrence_Type__c;
                        //}
                        childConfig.newPriceUOM = qlObj.PriceUOM__c;//SDT-42536_SDT-42538
                        childConfig.oldPriceUOM = qlObj.AssetId__r.Price_Unit__c;//SDT-42536_SDT-42538
                        
                        
                        childConfig.ProductFamily = qlObj.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c;//SDT-42536_SDT-42538
                        // childConfig.ProductName = qlObj.SBQQ__Product__r.Name;
                        childConfig.productName = qlObj.SBQQ__ProductName__c;//SDT-42536_SDT-42538
                        //  childConfig.Duration = qlObj.Duration__c;
                        childConfig.oldProductFamily = qlObj.AssetId__r.ProductFamily;//SDT-42568_42538
                        //  childConfig.newProductFamily = qlObj.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c;//SDT-42568_42538
                        childConfig.oldDuration = qlObj.AssetId__r.Duration__c;
                        childConfig.Duration = qlObj.Duration__c;
                        childConfig.newQuantity = Integer.valueOf(qlObj.SBQQ__Quantity__c);
                        
                        // childConfig.oldpriceMinimumQuantity = qlObj.AssetId__r.Price_Minimum_Quantity__c;
                        //  childConfig.newpriceMinimumQuantity = qlObj.PriceMinQuantity__c; 
                        
                        childConfig.oldpriceMinimumQuantity = qlObj.AssetId__r.Price_Minimum_Quantity__c;
                        
                        
                        
                        childConfig.newpriceMinimumQuantity = qlObj.PriceMinQuantity__c;
                        
                        
                        
                        childConfig.oldPrice = (qlObj.AssetId__r.Price__c != null) ? (qlObj.AssetId__r.Price__c).setScale(2) : 0;
                        
                        
                        //    childConfig.oldListUnitPrice = qlObj.AssetId__r.Price__c;
                        //    System.debug('***Old price'+childConfig.oldListUnitPrice); 
                        childConfig.oldListUnitPrice = (qlObj.AssetId__r.Price__c != null) ? (qlObj.AssetId__r.Price__c).setScale(2) : 0;
                        childConfig.netPrice = childConfig.oldpriceMinimumQuantity != null ? (childConfig.oldpriceMinimumQuantity * childConfig.oldListUnitPrice).setScale(2) : 0;
                      //  System.debug('childConfig.oldpriceMinimumQuantity=== '+childConfig.oldpriceMinimumQuantity);
                 //  System.debug('childConfig.oldListUnitPrice============ '+childConfig.oldListUnitPrice);
                  // System.debug('childConfig.netPrice======== '+childConfig.netPrice);
                        //childConfig.netPrice = 54;
                        childConfig.newListUnitPrice = qlObj.SBQQ__ListPrice__c;
                        
                        
                        //For Asset New Disposal Price for Email Template Only
                        
                        childConfig.priceMinimumQtytest = (qlObj.AssetId__r.Price_Minimum_Quantity__c != null) ? (qlObj.AssetId__r.Price_Minimum_Quantity__c).setScale(2) : 0;
                        childConfig.listPricetest = (qlObj.AssetId__r.Price__c != null) ? (qlObj.AssetId__r.Price__c).setScale(2) : 0;  
                        
                        if(childConfig.priceMinimumQtytest!= null && childConfig.listPricetest!= null && childConfig.priceMinimumQtytest!= 0 && childConfig.listPricetest!= 0)//SDT-42536_SDT-42538
                        {     
                            childConfig.disposalNewPriceAsset = childConfig.listPricetest / childConfig.priceMinimumQtytest;
                        }
                        else 
                        { 
                            childConfig.disposalNewPriceAsset = childConfig.listPricetest;    
                        }
                        
                        
                        
                        //For Asset Disposal Price
                        
                        childConfig.priceMinimumQtytestAsset = (qlObj.AssetId__r.Price_Minimum_Quantity__c != null) ? (qlObj.AssetId__r.Price_Minimum_Quantity__c).setScale(2) : 0;
                        childConfig.listPricetestAsset = (qlObj.AssetId__r.Price__c != null) ? (qlObj.AssetId__r.Price__c).setScale(2) : 0;  
                        
                        if(childConfig.priceMinimumQtytestAsset !=null && childConfig.listPricetestAsset != null && childConfig.priceMinimumQtytestAsset != 0 && childConfig.listPricetestAsset != 0)//SDT-42536_SDT-42538
                        {
                            childConfig.disposalOldPrice = (childConfig.priceMinimumQtytestAsset * childConfig.listPricetestAsset).setScale(2) ;
                        }
                        else 
                        { 
                            childConfig.disposalOldPrice = childConfig.listPricetestAsset;    
                        }
                        // system.debug('DOP'+childConfig.disposalOldPrice+childConfig.ProductName);
                        
                        //For Quote Line New Disposal Price
                        
                        childConfig.priceMinimumQtytestQuote = (qlObj.PriceMinQuantity__c != null) ? (qlObj.PriceMinQuantity__c).setScale(2) : 0;
                        childConfig.listPricetestQuote = (qlObj.SBQQ__ListPrice__c != null) ? (qlObj.SBQQ__ListPrice__c).setScale(2) : 0;  
                        
                        if(childConfig.priceMinimumQtytestQuote != null && childConfig.listPricetestQuote != null && childConfig.priceMinimumQtytestQuote != 0 && childConfig.listPricetestQuote != 0)//SDT-42536_SDT-42538
                        {
                            childConfig.disposalNewPrice =  (childConfig.priceMinimumQtytestQuote * childConfig.listPricetestQuote).setScale(2);
                        }
                        else 
                        { 
                            childConfig.disposalNewPrice = childConfig.listPricetestQuote;    
                        }
                        
                        childConfig.newEquipmentSize = qlObj.Equipment_Size__c;
                        childConfig.OccurenceType = qlObj.Occurrence_Type__c;
                        childConfig.oldScheduleFrequency = qlObj.AssetId__r.Schedule__c;//SDT-42568_42538
                        childConfig.newScheduleFrequency = qlObj.Service_Schedule__c;//SDT-42568_42538
                        //    childConfig.newPrice = (qlObj.SBQQ__ListPrice__c * qlObj.SBQQ__Quantity__c).setScale(2);
                        
                        //    childConfig.listPrice = qlObj.SBQQ__ListPrice__c;
                        
                        
                        childConfig.oldsteppedPrice1 = String.valueOf(qlObj.AssetId__r.Price_Price_1__c);//SDT-42536_SDT-42538
                        childConfig.oldsteppedPrice2 = String.valueOf(qlObj.AssetId__r.Price_Price_2__c);//SDT-42536_SDT-42538
                        
                        childConfig.oldstep1UptoTons = String.valueOf(qlObj.AssetId__r.Price_UpTo_1__c);//SDT-42536_SDT-42538
                        childConfig.oldstep2UptoTons = String.valueOf(qlObj.AssetId__r.Price_UpTo_2__c);//SDT-42536_SDT-42538
                        childConfig.oldpricingMethod = String.valueOf(qlObj.AssetId__r.Price_Model_Type__c);//SDT-42536_SDT-42538
                        if(childConfig.oldpricingMethod  =='STP' ||childConfig.oldpricingMethod  =='Stepped' )
                        {
                            childConfig.oldcheckSTP = true;
                        }
                        else
                        {
                            childConfig.oldcheckSTP = false;   
                        }
                        
                        if(!childConfigMap.containsKey(qlObj.SBQQ__RequiredBy__c)){
                            childConfigMap.put(qlObj.SBQQ__RequiredBy__c,new List<configWrapper>{childConfig}); 
                        }
                        else{
                            childConfigMap.get(qlObj.SBQQ__RequiredBy__c).add(childConfig);
                        }
                        
                        
                        //TCS-pkulkarn-SDT-42536-18-Nov-2024-Added
                        
                        
                        //TCS-pkulkarn-SDT-42459-18-Nov-2024-Added
                        //       if(qlObj.PriceMinQuantity__c != null && qlObj.SBQQ__ListPrice__c != null)
                        //       {
                        //           childConfig.disposalNewPrice = Decimal.valueOf(String.valueOf(qlObj.PriceMinQuantity__c)) * Decimal.valueOf(String.valueOf(qlObj.SBQQ__ListPrice__c));
                        //       }
                        //TCS-pkulkarn-SDT-42459-18-Nov-2024-Added
                        
                        childConfig.newsteppedPrice1 = String.valueOf(qlObj.PricePrice1__c);
                        childConfig.newsteppedPrice2 = String.valueOf(qlObj.PricePrice2__c);
                        childConfig.newstep1UptoTons = String.valueOf(qlObj.PriceUpTo1__c);
                        childConfig.newstep2UptoTons = String.valueOf(qlObj.PriceUpTo2__c);
                        childConfig.newpricingMethod = String.valueOf(qlObj.SBQQ__PricingMethod__c);
                        if(childConfig.newpricingMethod  =='STP')
                        {
                            childConfig.newcheckSTP = true;
                        }
                        else
                        {
                            childConfig.newcheckSTP = false;   
                        }
                        
                        
                        //TCS-pkulkarn-SDT-42536-18-Nov-2024-End
                    }
            
            System.debug('&&&&&Outside if '+counter);
            
            List<SBQQ__QuoteLine__c> lQuoteLines = new List<SBQQ__QuoteLine__c>();
            string key = qlObj.SBQQ__RequiredBy__c;
            if(quoteLineMap.containsKey(key)){
                lQuoteLines = quoteLineMap.get(key);
            }
            lQuoteLines.add(qlObj);
            quoteLineMap.put(key,lQuoteLines); 
            counter ++;
        }
        
        keyValues = quoteLineMap.keyset();
        
        return keyValues;
    } 
    
    //wrapper class for data shown for price
    public class priceWrapper{
        public String parentProductName{get;set;}
        public String productName{get;set;}
        public String productFamily{get;set;}
        public Decimal price{get;set;}
        //SDT 33101
        public String UOM{get;set;}
        public Decimal disposalNewPrice{get;set;}
        public String priceMinimumQty{get;set;} 	
        public String steppedPrice1{get;set;}       
        public String steppedPrice2{get;set;}       
        public String step1UptoTons{get;set;}      
        public String step2UptoTons{get;set;}       
        public String pricingMethod{get;set;}
        public Decimal newListUnitPrice{get;set;}
    }
    
    //wrapper class for Showing Old and New Configuration of quoteLines
    public class configWrapper{
        //SDT 44716
        public Integer draftQuantity{get;set;}
        public String draftEquipmentSize{get;set;}
        public String draftProductName{get;set;}
        public String draftOccurenceType{get;set;}
        public String draftDuration{get;set;}
        public String draftScheduleFrequency{get;set;}
        //SDT 44716
        public Decimal oldListUnitPrice{get;set;}
        public Decimal newListUnitPrice{get;set;}
        public String ProductName{get;set;}
        Public String oldDuration{get;set;}
        Public String Duration{get;set;}
        public Decimal oldQuantity{get;set;}
        public Integer newQuantity{get;set;}
        public String oldEquipmentSize{get;set;}
        public String newEquipmentSize{get;set;}
        public String oldOccurenceType{get;set;}
        public Decimal oldPrice{get;set;}
        public Decimal newPrice{get;set;}
        public Decimal disposalNewPriceAsset{get;set;}
        public Decimal disposalOldPrice{get;set;} 	//TCS-pkulkarn-SDT-42459-18-Nov-2024-Added
        public Decimal disposalNewPrice{get;set;} 	//TCS-pkulkarn-SDT-42459-18-Nov-2024-Added
        public String newPriceUOM{get;set;} 		//TCS-pkulkarn-SDT-42536-18-Nov-2024-Added
        public String oldPriceUOM{get;set;} 		//TCS-pkulkarn-SDT-42536-18-Nov-2024-Added
        public Decimal priceMinimumQty{get;set;} 	//TCS-pkulkarn-SDT-42536-18-Nov-2024-Added
        public Decimal oldpriceMinimumQuantity{get;set;} 
        public Decimal newpriceMinimumQuantity{get;set;} 
        public Decimal netPrice{get;set;}
        
        public String oldsteppedPrice1{get;set;}       //TCS-pkulkarn-SDT-42536-18-Nov-2024-Added
        public String oldsteppedPrice2{get;set;}       //TCS-pkulkarn-SDT-42536-18-Nov-2024-Added
        public String oldstep1UptoTons{get;set;}       //TCS-pkulkarn-SDT-42536-18-Nov-2024-Added
        public String oldstep2UptoTons{get;set;}       //TCS-pkulkarn-SDT-42536-18-Nov-2024-Added
        public String oldpricingMethod{get;set;}		//TCS-pkulkarn-SDT-42459-18-Nov-2024-Added
        public String newsteppedPrice1{get;set;}       //TCS-pkulkarn-SDT-42536-18-Nov-2024-Added
        public String newsteppedPrice2{get;set;}       //TCS-pkulkarn-SDT-42536-18-Nov-2024-Added
        public String newstep1UptoTons{get;set;}       //TCS-pkulkarn-SDT-42536-18-Nov-2024-Added
        public String newstep2UptoTons{get;set;}       //TCS-pkulkarn-SDT-42536-18-Nov-2024-Added
        public String newpricingMethod{get;set;}		//TCS-pkulkarn-SDT-42459-18-Nov-2024-Added
        
        public String oldScheduleFrequency{get;set;}   //TCS-ruchikak-SDT-42536-22-Nov-2024-Added
        public String OccurenceType{get;set;}      //TCS-ruchikak-SDT-42536-22-Nov-2024-Added
        public String oldProductFamily{get;set;}         //TCS-ruchikak-SDT-42536-22-Nov-2024-Added
        public String ProductFamily{get;set;}        //TCS-ruchikak-SDT-42536-22-Nov-2024-Added
        public Decimal listPrice{get;set;}            //TCS-ruchikak-SDT-42536-22-Nov-2024-Added
        public String newScheduleFrequency{get;set;}  //TCS-ruchikak-SDT-42536-22-Nov-2024-Added
        public String ProductNameParent{get;set;}      //TCS-ruchikak-SDT-42536-22-Nov-2024-Added
        public Decimal priceMinimumQtytest{get;set;} 
        public Decimal listPricetest{get;set;} 
        public Decimal priceMinimumQtytestAsset{get;set;}
        public Decimal listPricetestAsset{get;set;}
        public Decimal priceMinimumQtytestQuote{get;set;}
        public Decimal listPricetestQuote{get;set;}
        public Boolean newcheckSTP{get;set;}
        public Boolean oldcheckSTP{get;set;}
        public String checkAsset{get;set;}
        
       
    }
    //SDT 33101
    
    
    public static String getServiceSchedule(SBQQ__QuoteLine__c ql)
    {
        
        String serviceSchedule = '';
        String daysOfService = '';
        if(ql.Occurrence_Type__c == Constant_Util.ON_CALL)
        {
        
           // serviceSchedule = ql.Occurrence_Type__c;
            serviceSchedule =  ql.Occurrence_Type__c;
        }
        else
        {
            if(ql.Schedule_Frequency__c == 'Weekly')
            {
                
                
                
                integer finalFrequency = 0;
                if(ql.Final_Frequency__c != null)
                {
                    finalFrequency = integer.valueOf(ql.Final_Frequency__c);
                }
                serviceSchedule = finalFrequency + 'x ' + 'E' + ql.Frequency_Interval__c + ' Weekly (' ;
                //TCS-pkulkarn-SDT-45035-6-Feb-2025-Added following block
                List<String> serviceDaysArray = ql.Service_Days__c.split(';');
                for(String s : serviceDaysArray)
                {
                    switch on s
                    {
                        when 'S'
                        {
                            daysOfService = daysOfService + 'Sa';
                        }
                        when 'S1'
                        {
                            daysOfService = daysOfService + 'Su';
                        }
                        when 'M'
                        {
                            daysOfService = daysOfService + 'M';
                        }
                        when 'T'
                        {
                            daysOfService = daysOfService + 'T';
                        }
                        when 'W'
                        {
                            daysOfService = daysOfService + 'W';
                        }
                        when 'T1'
                        {
                            daysOfService = daysOfService + 'R';
                        }
                        when 'F'
                        {
                            daysOfService = daysOfService + 'F';
                        }
                    }
                }
                //TCS-pkulkarn-SDT-45035-6-Feb-2025-End
                serviceSchedule = serviceSchedule + daysOfService + ') ';
            }
            else if(ql.Schedule_Frequency__c == 'Daily' || ql.Schedule_Frequency__c == 'Monthly' || ql.Schedule_Frequency__c == 'Yearly')
            {
                serviceSchedule =  ql.Service_Schedule__c;
            }
            
        }
        return serviceSchedule;
    }
    

     //TCS-pkulkarn-SDT-40565-12-Sep-2024-End
    public static String getServiceScheduleAsset(Asset ast)
    {
        String serviceSchedule = '';
        String daysOfService = '';
        String finalFrequency ='';
        if(ast.Occurrence_Type__c == Constant_Util.ON_CALL)
        {
            serviceSchedule = ast.Occurrence_Type__c;
        }
        else
        {
            //serviceSchedule = 'E' + ast.Occurs__c;
            if(ast.Frequency__c == 'Weekly')
            {
                //serviceSchedule = serviceSchedule + 'W(';
              //  serviceSchedule = ' Weekly (';
               serviceSchedule = 'E'+ ast.Occurs__c + 'Weekly (';
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
                
                serviceSchedule = serviceSchedule + daysOfService + ')';
            }
            //Append final frequency
            if(ast.Frequency__c == 'Daily' || ast.Frequency__c == 'Monthly' || ast.Frequency__c == 'Yearly')
            {
                if(ast.Frequency__c == 'Daily')
                {
                    finalFrequency = 'D';
                }
                else if(ast.Frequency__c == 'Monthly')
                {
                    finalFrequency = 'M';
                }
                 else if(ast.Frequency__c == 'Yearly')
                {
                    finalFrequency = 'Y';
                }
                if(ast.Occurs__c !=null && ast.Occurs__c !='')          
                {
                  serviceSchedule = 'E'+ ast.Occurs__c + serviceSchedule + finalFrequency;  
                }
                else
                {
                  serviceSchedule = 'E'+ serviceSchedule + finalFrequency;    
                }
                
            }
            
            if(ast.Frequency__c == 'Weekly')
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
                    serviceSchedule = String.valueOf(count) + 'x ' + serviceSchedule ;
                }
            }
        }
        return serviceSchedule;
    }
}
