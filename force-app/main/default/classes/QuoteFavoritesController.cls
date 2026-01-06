public class QuoteFavoritesController {
    
    //Product Methods Start
    //getProducts() returns all products in the catalog that are CPQ eligible
    @AuraEnabled
    public static List<Product2> getProducts() {
        List<Product2> productList = [SELECT Id, Name, ProductCode, Family, Description, Container_Size__c
                                      FROM Product2
                                      WHERE ProductCode != Null AND SBQQ__Component__c = false AND
                                      SBQQ__PricingMethod__c != Null
                                      ORDER BY Name];
        return productList;
    }
    //searchProducts(queryString) returns all products based on a SOSL search of a query string
    @AuraEnabled
    public static List<Product2> searchProducts(String queryString){
        List<List<SObject>> queryResult = new List<List<SObject>>();
        List<Product2> queriedProducts = new List<Product2>();
        queryResult = [FIND :queryString IN ALL FIELDS
                       RETURNING Product2 (Id, Name, ProductCode, Family, Container_Size__c
                                           WHERE ProductCode != Null AND SBQQ__Component__c = false AND
                                           SBQQ__PricingMethod__c != Null)];
        
        queriedProducts = queryResult[0];
        
        return queriedProducts;
    }
    @AuraEnabled
    public static Product2 getPreselectedProduct(string selectedProductName){
        List<Product2> productList = new List<Product2>();
        productList = [SELECT Id, Name, ProductCode, Family 
                       FROM Product2  
                       WHERE ProductCode != Null 
                       AND SBQQ__Component__c = false 
                       AND SBQQ__PricingMethod__c != Null 
                       AND Name =:selectedProductName LIMIT 1];
        if(productList.size()>0){
            return productList[0];
        }
        return null;
    }
    //Product Methods End
    
    //Material Methods Starts
    //getWasteStreams(productId) returns the waste streams registered to the container type
    @AuraEnabled
    public static List<SBQQ__ProductOption__c> getWasteStreams(Id productId) {
        List<SBQQ__ProductOption__c> eligibleStreams = [SELECT Id, Name, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.ProductCode
                                                        FROM SBQQ__ProductOption__c
                                                        WHERE SBQQ__ConfiguredSKU__c =: productId AND SBQQ__ProductFamily__c = 'Waste Category' And SBQQ__OptionalSKU__r.IsActive = true];
        Set<Id> categoryIds = new Set<Id>();
        for (SBQQ__ProductOption__c po : eligibleStreams) {
            categoryIds.add(po.SBQQ__OptionalSKU__c);
        }
        List<SBQQ__ProductOption__c> eligibleMaterials = [SELECT Id, Name, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name, 
                                                          SBQQ__OptionalSKU__r.ProductCode
                                                          FROM SBQQ__ProductOption__c
                                                          WHERE SBQQ__ConfiguredSKU__c IN :categoryIds
                                                          ORDER BY SBQQ__OptionalSKU__r.Name];
        return eligibleMaterials;
    }
    //Material Methods End
    
   
    // Changes by - Toshender Kumar
    // Correction in logic to match the picklist values with shown and hidden values. Earlier the logic was to check the string contains (LIKE logic), 
    // It is now amended to do exact match of equipment size. SDT-21768
    @AuraEnabled
    public static Map<String, String> getSizes(Id productId, Boolean returnAll) {
        Map<String, String> sizeMap = new Map<String, String>();
        List<SBQQ__ConfigurationAttribute__c> containerAtt = [SELECT Id, SBQQ__TargetField__c, SBQQ__Product__c, SBQQ__ShownValues__c, SBQQ__HiddenValues__c
                                                              FROM SBQQ__ConfigurationAttribute__c
                                                              WHERE SBQQ__Product__c =: productId AND SBQQ__TargetField__c = 'Equipment_Size__c'];
        List<Schema.PicklistEntry> sizePicklist = SBQQ__QuoteLine__c.Equipment_Size__c.getDescribe().getPicklistValues();
        if (returnAll){
            for (Schema.PicklistEntry ple: sizePicklist) {
                sizeMap.put(ple.value, ple.label);
            }
            return sizeMap;
        } else if (containerAtt.size() != 1) {
            sizeMap.put('UNK', 'Unknown');
            return sizeMap;
        } else {
            
            // The values in SBQQ__ShownValues__c and SBQQ__HiddenValues__c are stored with newline character separated.
            string SPLIT_KEY = '\n';
  
            String shownValues = containerAtt[0].SBQQ__ShownValues__c;
            List<String> lstShowValues = new List<String>();
            lstShowValues = Split(SPLIT_KEY,shownValues);   // Split by newline character

            system.debug('Shown Values are: ' + shownValues);
            String hiddenValues = containerAtt[0].SBQQ__HiddenValues__c;
            List<String> lsthiddenValues = new List<string>(); 
            lsthiddenValues = Split(SPLIT_KEY,hiddenValues); // Split by newline character
            
            for (Schema.PicklistEntry ple: sizePicklist) {
                if (!lstShowValues.isEmpty() && lstShowValues.contains(ple.value)) {
                    sizeMap.put(ple.value, ple.label);
                } else  if (!lsthiddenValues.isEmpty() && !lsthiddenValues.contains(ple.value)) {
                    sizeMap.put(ple.value, ple.label);
                } else if (lsthiddenValues.isEmpty() && lstShowValues.isEmpty()){
                    sizeMap.put(ple.value, ple.label);
                }
            }
            return sizeMap;
        }
    }

        // Splits the string based on the key provided
        // Changes by - Toshender Kumar
        // SDT-21768 
       private static List<String>  Split(string key, string stringToSplit ){
            
            if(stringToSplit!=null && !string.isEmpty(stringToSplit)){
               return stringToSplit.split(key); 
            }

            return new List<String>();
       }
    
    //Get Favorites given the context of a product
    @AuraEnabled(cacheable=true)
    public static List<FavoriteWrapper> getFavorites(Id productId){
        List<FavoriteWrapper> productFavorites = new List<FavoriteWrapper>();
        
        List<SBQQ__FavoriteProduct__c> productFavoriteDetails = [SELECT Id, SBQQ__Favorite__r.Name, SBQQ__Favorite__c, SBQQ__ConfigurationAttributes__c,
                                                                SBQQ__Product__r.Family, SBQQ__Product__r.Name, SBQQ__Quantity__c
                                                                FROM SBQQ__FavoriteProduct__c
                                                                WHERE SBQQ__Product__c =: productId OR
                                                                SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.SBQQ__Product__c =: productId
                                                                ORDER BY SBQQ__Favorite__c ASC];
        
        if(productFavoriteDetails.size() == 0) {
            return productFavorites;
        }
		/*
 		String favoriteIndex = '';
        FavoriteWrapper favoriteConfig = new FavoriteWrapper();
        for (SBQQ__FavoriteProduct__c fp : productFavoriteDetails) {
            favoriteIndex = (favoriteIndex == '') ? fp.SBQQ__Favorite__c : favoriteIndex;
 		*/
        
        Id favoriteIndex;
        FavoriteWrapper favoriteConfig = new FavoriteWrapper();
        system.debug('productFavoriteDetails--->'+ productFavoriteDetails);
        for (SBQQ__FavoriteProduct__c fp : productFavoriteDetails) {
            system.debug('favoriteIndex--->'+ favoriteIndex);
            system.debug('favoriteIndex2--->'+ favoriteIndex);
            if (favoriteIndex != fp.SBQQ__Favorite__c){
                productFavorites.add(favoriteConfig);
                favoriteConfig = new FavoriteWrapper();
                favoriteIndex = fp.SBQQ__Favorite__c;
                favoriteConfig.favoriteId = fp.SBQQ__Favorite__c;
            }
            if (fp.SBQQ__Product__r.Family == 'Waste Stream') {
                favoriteConfig.materialType = fp.SBQQ__Product__r.Name;
            }
            if (fp.SBQQ__Product__c == productId) {
                favoriteConfig.containerType = fp.SBQQ__Product__r.Name;
                favoriteConfig.quantity = fp.SBQQ__Quantity__c;
                String confAttributes = fp.SBQQ__ConfigurationAttributes__c;
                Map<String, Object> attributes = (Map<String, Object>) JSON.deserializeUntyped(confAttributes);
                favoriteConfig.equipmentSize = (String)attributes.get('Equipment_Size__c');
                favoriteConfig.ownership = (String)attributes.get('Ownership__c');
            }
        }
        productFavorites.add(favoriteConfig);

        return productFavorites;
    }

    //Call to centralized favorites method to write quote lines
    @AuraEnabled
    public static String addQuoteFavorite(Id favoriteId, Id quoteId) {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote = [SELECT Id, SBQQ__Opportunity2__r.Case__c
                FROM SBQQ__Quote__c
                WHERE Id =: quoteId];
        
        //Ref: QuoteProcurementController for documentation
        String returnedId = QuoteProcurementController.addQuoteandQuoteine(favoriteId, quote.SBQQ__Opportunity2__r.Case__c, quoteId, true);

        SBQQ__QuoteLine__c newQL = [SELECT Id, SBQQ__StartDate__c
                                    FROM SBQQ__QuoteLine__c
                                    WHERE SBQQ__ProductOption__c = null
                                    ORDER BY CreatedDate DESC
                                    LIMIT 1];

        //Date SLADateTime = NULL;//determineSLA(newQL.Id);
        //sdt-27107
        //newQL.SBQQ__StartDate__c = SLADateTime;
        //newQL.SBQQ__EndDate__c = SLADateTime;//added by seema
        //sdt-27107 end
        try {
            //update newQL;
            return newQL.Id;
        } catch (exception e) {
            system.debug(e.getMessage());
            return newQL.Id;
        }

    }
    
    @AuraEnabled
    public static String createNonFavoriteLine(Id quoteId, Id productId, Id wasteStream, String equipmentSize) {

        String successMessage;

        successMessage = QuoteProcurementController.createQuoteLines(quoteId, productId, wasteStream, equipmentSize);

        return successMessage;

    }
     /**************************************************************
    * Method name : determineSLAForAlternateProducts
    * Description :  
    * Returns :  Date for input product (QLI wrapper)
    * Developer : Satnam Singh
    * User Story : SDT-29961
    ****************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String,Date> determineSLAForAlternateProducts(Id parentQuoteLineId,List<String> equipmentSizes){
        Map<String,Date> slaDates = new Map<String,Date>();
        Map<String,String> checkDuration= new Map<String,String>
                                        {'TEMP'=>'Temporary','PERM'=>'Permanent','SEAS'=>'Seasonal'};
        try {
            DateTime SLADate;
            List<BusinessHours> locationBusinessHours;
            BusinessHours businessHourId;
			String locTimeZone;

            SBQQ__QuoteLine__c parentLine = [SELECT Id, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Account__c, SBQQ__ProductFamily__c, Duration__c,
                                                SBQQ__Quote__r.SBQQ__Account__r.ParentId, SBQQ__Quote__r.Project__c, SBQQ__ProductName__c, 
                                                Equipment_Size__c, SBQQ__Quote__r.SBQQ__Account__r.tz__Timezone_SFDC__c
                                                FROM SBQQ__QuoteLine__c WHERE Id =: parentQuoteLineId];

            if(parentLine != null) {
                locTimeZone = parentLine.SBQQ__Quote__r.SBQQ__Account__r.tz__Timezone_SFDC__c;
            }
            
            BusinessHours defaultHours = [SELECT Id FROM BusinessHours WHERE isDefault = true LIMIT 1];

            if(!getSLASwitch())
            {
                //Get the Business Hours as per quote account timezone or use default Business Hours
                //For SDT-39637 and SDT-45007
                locationBusinessHours = getBusinessIdByTimeZone(locTimeZone);
                if(locationBusinessHours != null && locationBusinessHours.size() > 0)
                    businessHourId = locationBusinessHours[0];
                else
                    businessHourId = defaultHours;
                //
            }
            else{
                businessHourId = defaultHours;
            }
                        
            //Check related Entitlement
            Entitlement relEntitlement = getRelatedEntitleMent(parentLine.SBQQ__Quote__c, parentLine.Id);
            System.debug('relEntitlement^^'  +relEntitlement);
            if (relEntitlement == null || relEntitlement.id==null) {
                String serviceFilter ='New Service_'+checkDuration.get(parentLine.Duration__c);
                
                List<Industry_Standard_SLA__mdt> industryStandards = [SELECT Id, Service__c, After__c, Before__c
                                                                        FROM Industry_Standard_SLA__mdt
                                                                        WHERE Service__c LIKE :(serviceFilter+'%')];
                Map<String, Industry_Standard_SLA__mdt> industryStandardMap = new Map<String, Industry_Standard_SLA__mdt>();
                for(Industry_Standard_SLA__mdt ind : [SELECT Id, Service__c, After__c, Before__c
                FROM Industry_Standard_SLA__mdt
                WHERE Service__c LIKE :(serviceFilter+'%')]) {
                    industryStandardMap.put(ind.Service__c,ind);
                }
                //If if product is Compactor 
                if(parentLine.SBQQ__ProductName__c.contains('Compactor')){
                    for(String size : equipmentSizes){
                        Integer equipmentSize = Integer.ValueOf(size.replace('YRDS','').replace('-',''));
                        // size less than 10 = Commercial else Roloff
                        String lob = (equipmentSize <= 10) ? Constant_Util.COMMERCIAL : Constant_Util.ROLLOFF;
                        Industry_Standard_SLA__mdt indStand = industryStandardMap.get(serviceFilter+'_'+lob);
                        if(indStand!=null){
                            if(!getSLASwitch()){
                                slaDates.put(size,calculateISSLA_LocTimezone(indStand, businessHourId, parentLine, locTimeZone).date());
                            }
                            else{
                                slaDates.put(size,calculateISSLA(indStand, defaultHours).date());
                            }
                        }
                    }
                }
                else{
                    if(!getSLASwitch()){
                        SLADate = calculateISSLA_LocTimezone(industryStandardMap.get(serviceFilter+'_'+parentLine.SBQQ__ProductFamily__c), businessHourId, parentLine, locTimeZone);
                    }
                    else{
                        SLADate = calculateISSLA(industryStandardMap.get(serviceFilter+'_'+parentLine.SBQQ__ProductFamily__c), defaultHours);
                    }
                }
            } else {
                    if(!getSLASwitch()){
                        SLADate = calculateEntitlementSLA_LocTimezone(relEntitlement, businessHourId, locTimeZone);
                    }
                    else{
                        SLADate = calculateEntitlementSLA(relEntitlement, defaultHours);
                    }
            }
            if(SLADate!=null && slaDates.size()==0){
                for(String size : equipmentSizes){
                    slaDates.put(size,SLADate.date());
                }
            }
        } catch (Exception e) {
            System.debug('Error '+e);
        }
        return slaDates;
    }
    //Determine SLA for the quote line.  This is not invoked from the Lightning ComponentD
    public static DateTime determineSLA(Id parentQuoteLineId) {
        DateTime SLADate = system.now();
        SBQQ__QuoteLine__c parentLine = new SBQQ__QuoteLine__c();
        Entitlement relEntitlement = new Entitlement();
        String duration;
        List<BusinessHours> locationBusinessHours;
        BusinessHours businessHourId;
        BusinessHours defaultHours = [SELECT Id FROM BusinessHours WHERE isDefault = true LIMIT 1];
        String locTimeZone;
        
        List<SBQQ__QuoteLine__c> bundle = [SELECT Id, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Type__c,SBQQ__Quote__r.SBQQ__Account__c, SBQQ__ProductFamily__c, Duration__c,
                                           SBQQ__Quote__r.SBQQ__Account__r.ParentId, SBQQ__Quote__r.Project__c, SBQQ__ProductName__c, Equipment_Size__c,
                                           SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.SLA_Service_DateTime__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Service_Date__c,
                                           SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c, SBQQ__Quote__r.SBQQ__Account__r.tz__Timezone_SFDC__c     
                                           FROM SBQQ__QuoteLine__c
                                           WHERE Id =: parentQuoteLineId];
        
        parentLine = bundle.size() == 1 ? bundle[0] : null;
        
        if (parentLine == null) {
            system.debug('Could not determine parent row.');
            return SLADate;
        }

        locTimeZone = parentLine.SBQQ__Quote__r.SBQQ__Account__r.tz__Timezone_SFDC__c;
        
        
        //SDT-41473 SDT-42045
        Id caseId = bundle[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c; 

        Boolean IsHaulAway =  HaulAwayService.getIsHaulAwayService(caseId);

        if(IsHaulAway){
            return system.now();
        }

        if(!getSLASwitch()){
            //Get the Business Hours as per quote account timezone or use default Business Hours
            //For SDT-39637 and SDT-45007
            locationBusinessHours = getBusinessIdByTimeZone(locTimeZone);
            if(locationBusinessHours != null && locationBusinessHours.size() > 0)
                businessHourId = locationBusinessHours[0];
            else
                businessHourId = defaultHours;
            //
        }
        else{
            businessHourId = defaultHours;
        }

        switch on parentLine.Duration__c {
            when 'TEMP' {
                duration = 'Temporary';
            }
            when 'PERM' {
                duration = 'Permanent';
            }
            when 'SEAS' {
                duration = 'Seasonal';
            }
            when else {
                return system.now();
            }
        }
        relEntitlement = getRelatedEntitleMent(parentLine.SBQQ__Quote__c, parentLine.Id);
        system.debug('jatan test '+ relEntitlement);
        
        if (relEntitlement == null || relEntitlement.id == null) {
            // system.debug('No account entitlements.  Using Industry Standards');
            Industry_Standard_SLA__mdt IndStSLA = new Industry_Standard_SLA__mdt();
            
            List<Industry_Standard_SLA__mdt> industryStandards = [SELECT Id, Service__c, After__c, Before__c
                                                                  FROM Industry_Standard_SLA__mdt
                                                                  WHERE Service__c LIKE 'New Service%'];
            
            // system.debug('Number of industryStandards returned:' + industryStandards.size());
            for(Industry_Standard_SLA__mdt ind : industryStandards) {
                // system.debug('parentLine>>'+ parentLine);
                // Compactor Logic for SDT-24088
                if(parentLine.SBQQ__ProductName__c.contains('Compactor') && !String.isBlank(parentLine.Equipment_Size__c) && parentLine.Equipment_Size__c != null)
                {
                    Double equipmentSize= Double.ValueOf(parentLine.Equipment_Size__c.replace('YRDS','').replace('-',''));
                    // system.debug('equipmentSize>>>'+ equipmentSize);
                    // if product is Compactor and size less than 10 = Commercial
                    if(equipmentSize <= 10 && ind.Service__c.contains(Constant_Util.COMMERCIAL) && ind.Service__c.contains(duration))
                    {
                        IndStSLA = ind;
                        system.debug('inside #4>>'+ IndStSLA);
                    }// if product is Compactor and size greater than 10 yard = Roll Off
                    else if(equipmentSize > 10 && ind.Service__c.contains(Constant_Util.ROLLOFF) && ind.Service__c.contains(duration)){
                        IndStSLA = ind;
                        system.debug('inside #5>>'+ IndStSLA);
                    }
                }
                else if (ind.Service__c.contains(parentLine.SBQQ__ProductFamily__c) && ind.Service__c.contains(duration)) {
                    IndStSLA = ind;
                    system.debug('inside #1>>'+ IndStSLA);
                } else if (ind.Service__c.contains('Service') && ind.Service__c.contains(duration) && IndStSLA == null) {
                    IndStSLA = ind;
                    system.debug('inside #2>>'+ IndStSLA);
                }
                else if (ind.Service__c.contains('Service') && ind.Service__c.contains(duration) && parentLine.SBQQ__ProductFamily__c == 'None') {
                    IndStSLA = ind;
                    system.debug('inside #3>>'+ IndStSLA);
                }
            }
            // system.debug('Industry standard is: ' + IndStSLA.Service__c);
            if(!getSLASwitch()){
                //Changes for SDT-39637
                SLADate = calculateISSLA_LocTimezone(IndStSLA, businessHourId, parentLine, locTimeZone);
                // system.debug('Industry Standard SLA is -->'+SLADate);
            }
            else{
                SLADate = calculateISSLA(IndStSLA, defaultHours);
                system.debug('Industry Standard SLA is -->'+SLADate);
            }
        } 
        else {
            if(!getSLASwitch()){
                //Changes for SDT-45007
                SLADate = calculateEntitlementSLA_LocTimezone(relEntitlement, businessHourId, locTimeZone);
            }
            else{
                SLADate = calculateEntitlementSLA(relEntitlement, defaultHours);
            }
        }
        
        //Iterate through the returned entitlements to match appropriately
         /* adding for SDT-33378 */
        if(parentLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Service_Date__c != null && (parentLine.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment' || parentLine.SBQQ__Quote__r.SBQQ__Type__c == 'Correction' || parentLine.SBQQ__Quote__r.SBQQ__Type__c == 'Exception'))
        {
            Date dateObj = parentLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Service_Date__c;         
            Integer d = dateObj.day();
            Integer mo = dateObj.month();
            Integer yr = dateObj.year();
            SLADate = DateTime.newInstance(yr, mo, d);       
        }
        
        // system.debug('Calculated SLA Date is: ' + SLADate);
        return SLADate;
        
    }

    //Use entitlement to calculate SLA date
    /*public static DateTime calculateEntitlementSLA(Entitlement e, BusinessHours bh, SBQQ__QuoteLine__c parentQL) {
        DateTime additionalDate;
        Date targetDate;
        Time targetTime;
        currentDateTime currDateTime;
        Long milliseconds = 0;
        DateTime productSLA;
        Integer offset;
        //Changes for SDT-45007
        if(parentQL != null)
        {
            // system.debug('calculateEntitlementSLA - When have parent quoteline');
            currDateTime = new currentDateTime(parentQL.SBQQ__Quote__r.SBQQ__Account__r.tz__Timezone_SFDC__c);
            Datetime now = Datetime.now();
            Timezone timeZone = Timezone.getTimeZone(parentQL.SBQQ__Quote__r.SBQQ__Account__r.tz__Timezone_SFDC__c);
            offset = timeZone.getOffset(now);
        }
        else
        {
            // system.debug('calculateEntitlementSLA - When donot have parent quoteline');
            currDateTime = new currentDateTime();
        }        
        integer currentHour = Integer.valueOf(currDateTime.hours.split(':')[0]);
        
        switch on e.Service_Guarantee_Category__c {
            when 'Hours' {
                milliseconds = Integer.valueOf(e.Service_Guarantee_Category_Value__c) * 3600000;
            }
            when 'Days' {
                System.debug('inside ent2^^^^');
                integer serviceGuaranteeCategoryValue = Integer.valueOf(e.Service_Guarantee_Category_Value__c);
                system.debug('serviceGuaranteeCategoryValue in line 347==>'+serviceGuaranteeCategoryValue);
                //For Same Day and Next Day Entitlements SDT-24917, In Before Logic one extra Day shouldn't get added
                if(e.Before_After__c!='' && (Constant_Util.BEFORE).equalsIgnorecase(e.Before_After__c) && currentHour < 9){
                     if(serviceGuaranteeCategoryValue!=0 && serviceGuaranteeCategoryValue==1){
                        // system.debug('In currentHour < 9 - where SG+1');
                        serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue + 1;
                     }
                }
                else if(e.Before_After__c!='' && (Constant_Util.BEFORE).equalsIgnorecase(e.Before_After__c) && currentHour >= 10){
                     if(serviceGuaranteeCategoryValue!=0 && serviceGuaranteeCategoryValue!=1){
                        // system.debug('In currentHour >= 10 - where SG-1');
                        serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue-1;
                    }
                }
                else if(e.Before_After__c!='' && (Constant_Util.BEFORE).equalsIgnorecase(e.Before_After__c) && currentHour < 10){
                     if(serviceGuaranteeCategoryValue!=0 && serviceGuaranteeCategoryValue!=1){
                        serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue;
                        // system.debug('In currentHour < 10 - where SG');
                        // system.debug('serviceGuaranteeCategoryValue for else if Before 10 in before condition==>'+serviceGuaranteeCategoryValue);                        
                    }
                }
                
                //'After' 14:00 Scenarios for Entitlements to get picked up
                else if(e.Before_After__c!='' && (Constant_Util.AFTER).equalsIgnorecase(e.Before_After__c) && (e.Call_Time__c == '14:00' || e.Call_Time__c == '15:00' || e.Call_Time__c == '23:59')){
                        // system.debug('In After 14, 15, 23:59 - SG');
                        serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue;
                }
                 //'After' and before 14:00 Scenarios for Entitlements to get picked up
                else if(e.Before_After__c!='' && (Constant_Util.AFTER).equalsIgnorecase(e.Before_After__c) && e.Call_Time__c == '13:00' || e.Call_Time__c == '12:00' || e.Call_Time__c == '10:00' ){
                    if(serviceGuaranteeCategoryValue!=0 && serviceGuaranteeCategoryValue!=1){
                        // system.debug('In After 13, 12, 10 - SG-1');
                        //serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue-1;
                        // Change for SDT-47963 SGC = SGC
                        serviceGuaranteeCategoryValue = serviceGuaranteeCategoryValue;
                    }
                }
                system.debug('serviceGuaranteeCategoryValue==> '+ serviceGuaranteeCategoryValue);
                milliseconds = serviceGuaranteeCategoryValue * 16 * 3600000;
                /*if(e.Before_After__c!='' && (Constant_Util.BEFORE).equalsIgnorecase(e.Before_After__c)){
                    targetDate = Date.newInstance((SlaStartDate).yearGmt(), (SlaStartDate).monthGmt(), (SlaStartDate).dayGmt());
                    targetTime = Time.newInstance(5, 0, 0, 0);
                    additionalDate = getadditionalDate(targetDate,targetTime,timeZone);
                }else {
                    targetDate = Date.newInstance((SlaStartDate).yearGmt(), (SlaStartDate).monthGmt(), ((SlaStartDate).dayGmt())+1);
                    targetTime = Time.newInstance(5, 0, 0, 0);
                    additionalDate = getadditionalDate(targetDate,targetTime,timeZone);
                }*/
                
                //milliseconds = Integer.valueOf(e.Service_Guarantee_Category_Value__c) * 24 * 3600000;
           /* }
        }*/
        /*if(milliseconds==0){
            productSLA = additionalDate;
        }else{
            productSLA = BusinessHours.add(bh.Id, system.now(), milliseconds);   
        }*/
        // system.debug('Business Hours==> '+ bh.Id);
        // system.debug('currDateTime.local==> '+ currDateTime.local);
        // system.debug('milliseconds==> '+ milliseconds);
       /* if(parentQL != null)
        {
            productSLA = getBusinessHours(bh.Id, currDateTime.local, milliseconds);
            productSLA = productSLA.addSeconds(offset/1000);
        }
        else{
            productSLA = getBusinessHours(bh.Id, currDateTime.local, milliseconds);
        }
        // system.debug('productSLA From QF Controllers calculateEntitlementSLA--> ' + productSLA);
        return productSLA;
        
    }*/

    //Use entitlement to calculate SLA date
    public static DateTime calculateEntitlementSLA(Entitlement e, BusinessHours bh) {
        DateTime additionalDate;
        Date targetDate;
        Time targetTime;
        currentDateTime currDateTime = new currentDateTime();
        integer currentHour = Integer.valueOf(currDateTime.hours.split(':')[0]);
        Long milliseconds = 0;
        DateTime productSLA;
        
        switch on e.Service_Guarantee_Category__c {
            when 'Hours' {
                milliseconds = Integer.valueOf(e.Service_Guarantee_Category_Value__c) * 3600000;
            }
            when 'Days' {
                integer serviceGuaranteeCategoryValue = Integer.valueOf(e.Service_Guarantee_Category_Value__c);
                //For Same Day and Next Day Entitlements SDT-24917, In Before Logic one extra Day shouldn't get added
                if(e.Before_After__c!='' && (Constant_Util.BEFORE).equalsIgnorecase(e.Before_After__c) && currentHour < 9){
                     if(serviceGuaranteeCategoryValue!=0 && serviceGuaranteeCategoryValue==1){
                         serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue + 1;
                     }
                }
                else if(e.Before_After__c!='' && (Constant_Util.BEFORE).equalsIgnorecase(e.Before_After__c) && currentHour >= 10){
                     if(serviceGuaranteeCategoryValue!=0 && serviceGuaranteeCategoryValue!=1){
                        serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue-1;
                    }
                }
                else if(e.Before_After__c!='' && (Constant_Util.BEFORE).equalsIgnorecase(e.Before_After__c) && currentHour < 10){
                     if(serviceGuaranteeCategoryValue!=0 && serviceGuaranteeCategoryValue!=1){
                         serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue;
                         system.debug('serviceGuaranteeCategoryValue for else if Before 10 in before condition==>'+serviceGuaranteeCategoryValue);                        
                    }
                }
                //'After' 14:00 Scenarios for Entitlements to get picked up
                else if(e.Before_After__c!='' && (Constant_Util.AFTER).equalsIgnorecase(e.Before_After__c) && (e.Call_Time__c == '14:00' || e.Call_Time__c == '15:00' || e.Call_Time__c == '23:59')){
                    serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue;
                }
                 //'After' and before 14:00 Scenarios for Entitlements to get picked up
                else if(e.Before_After__c!='' && (Constant_Util.AFTER).equalsIgnorecase(e.Before_After__c) && e.Call_Time__c == '13:00' || e.Call_Time__c == '12:00' || e.Call_Time__c == '10:00' ){
                    if(serviceGuaranteeCategoryValue!=0 && serviceGuaranteeCategoryValue!=1){
                        serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue-1;
                    }
                 }
                milliseconds = serviceGuaranteeCategoryValue * 16 * 3600000;
            }
        }
        productSLA = getBusinessHours(bh.Id, currDateTime.local, milliseconds);   
        system.debug('productSLA From QF Controllers calculateEntitlementSLA-->'+productSLA);
        return productSLA;        
    }

    //Use entitlement to calculate SLA date using location timezone
    public static DateTime calculateEntitlementSLA_LocTimezone(Entitlement e, BusinessHours bh, string locTimeZone) {
        DateTime additionalDate;
        Date targetDate;
        Time targetTime;
        currentDateTime currDateTime;
        Long milliseconds = 0;
        DateTime productSLA;
        Integer offset;
        //Changes for SDT-45007
        if(String.isNotEmpty(locTimeZone))
        {
            // system.debug('calculateEntitlementSLA - When have parent quoteline');
            currDateTime = new currentDateTime(locTimeZone);
            Datetime now = Datetime.now();
            Timezone timeZone = Timezone.getTimeZone(locTimeZone);
            offset = timeZone.getOffset(now);
        }
        else
        {
            // system.debug('calculateEntitlementSLA - When donot have parent quoteline');
            currDateTime = new currentDateTime();
        }        
        integer currentHour = Integer.valueOf(currDateTime.hours.split(':')[0]);
        
        switch on e.Service_Guarantee_Category__c {
            when 'Hours' {
                milliseconds = Integer.valueOf(e.Service_Guarantee_Category_Value__c) * 3600000;
            }
            when 'Days' {
                System.debug('inside ent2^^^^');
                integer serviceGuaranteeCategoryValue = Integer.valueOf(e.Service_Guarantee_Category_Value__c);
                system.debug('serviceGuaranteeCategoryValue in line 347==>'+serviceGuaranteeCategoryValue);
                //For Same Day and Next Day Entitlements SDT-24917, In Before Logic one extra Day shouldn't get added
                /*if(e.Before_After__c!='' && (Constant_Util.BEFORE).equalsIgnorecase(e.Before_After__c) && currentHour < 9){
                     if(serviceGuaranteeCategoryValue!=0 && serviceGuaranteeCategoryValue==1){
                        // system.debug('In currentHour < 9 - where SG+1');
                        serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue + 1;
                     }
                }
                //commented by av4 as part of SDT-39637
                else if(e.Before_After__c!='' && (Constant_Util.BEFORE).equalsIgnorecase(e.Before_After__c) && currentHour >= 10){
                     if(serviceGuaranteeCategoryValue!=0 && serviceGuaranteeCategoryValue!=1){
                        // system.debug('In currentHour >= 10 - where SG-1');
                        serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue-1;
                    }
                }
                else if(e.Before_After__c!='' && (Constant_Util.BEFORE).equalsIgnorecase(e.Before_After__c) && currentHour < 10){
                     if(serviceGuaranteeCategoryValue!=0 && serviceGuaranteeCategoryValue!=1){
                        serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue;
                        // system.debug('In currentHour < 10 - where SG');
                        // system.debug('serviceGuaranteeCategoryValue for else if Before 10 in before condition==>'+serviceGuaranteeCategoryValue);                        
                    }
                }
                
                //'After' 14:00 Scenarios for Entitlements to get picked up
                else if(e.Before_After__c!='' && (Constant_Util.AFTER).equalsIgnorecase(e.Before_After__c) && (e.Call_Time__c == '14:00' || e.Call_Time__c == '15:00' || e.Call_Time__c == '23:59')){
                        // system.debug('In After 14, 15, 23:59 - SG');
                        serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue;
                }
                 //'After' and before 14:00 Scenarios for Entitlements to get picked up
                else if(e.Before_After__c!='' && (Constant_Util.AFTER).equalsIgnorecase(e.Before_After__c) && e.Call_Time__c == '13:00' || e.Call_Time__c == '12:00' || e.Call_Time__c == '10:00' ){
                    if(serviceGuaranteeCategoryValue!=0 && serviceGuaranteeCategoryValue!=1){
                        // system.debug('In After 13, 12, 10 - SG-1');
                        //serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue-1;
                        // Change for SDT-47963 SGC = SGC
                        serviceGuaranteeCategoryValue = serviceGuaranteeCategoryValue;
                    }
                }*/
                //added by av4 as part of testing 39637
                //same day and next day doesnt depend on before and after. we take servicegurantee as 0 and 1 respectively.
                if((serviceGuaranteeCategoryValue == 0 || serviceGuaranteeCategoryValue == 1)) {
                    system.debug('same day and next day scenario');
                }
                //other before scenarios //
                else if(e.Before_After__c!=Constant_Util.EMPTY_STRING && (Constant_Util.BEFORE).equalsIgnorecase(e.Before_After__c)){
                    // system.debug('In currentHour < 9 - where SG+1');
                    serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue - 1;
                }
				//other after scenarios
                else if(e.Before_After__c!=Constant_Util.EMPTY_STRING && (Constant_Util.AFTER).equalsIgnorecase(e.Before_After__c)){
                        serviceGuaranteeCategoryValue=serviceGuaranteeCategoryValue;                       
                }
                
                //morning 12(00:00AM) to 5
                if(currentHour >= 0 && currentHour < 5) {
                    serviceGuaranteeCategoryValue = serviceGuaranteeCategoryValue + 1;
                }

                
                //ends here
                system.debug('serviceGuaranteeCategoryValue==> '+ serviceGuaranteeCategoryValue);
                milliseconds = serviceGuaranteeCategoryValue * 16 * 3600000;
            }
        }
        if(locTimeZone != null)
        {
            //modified by av4 for 39637
            //productSLA = getBusinessHours(bh.Id, currDateTime.local, milliseconds);
            //productSLA = productSLA.addSeconds(offset/1000);
            //milliseconds = milliseconds - difference;
            productSLA = getBusinessHoursInAccountTimeZone(bh.Id, System.now(), milliseconds, locTimeZone);
        }
        else{
            productSLA = getBusinessHours(bh.Id, currDateTime.local, milliseconds);
        }
        // system.debug('productSLA From QF Controllers calculateEntitlementSLA--> ' + productSLA);
        return productSLA;        
    }
    
    //Use industry standard to calculate SLA date
    public static DateTime calculateISSLA(Industry_Standard_SLA__mdt indStand, BusinessHours bh) {
        system.debug('bh==>'+bh);
        DateTime targetSLADate;
        Long milliseconds = 0;
        currentDateTime currDateTime = new currentDateTime();
        integer currentHour = Integer.valueOf(currDateTime.hours.split(':')[0]);
        system.debug('currentHour==>'+currentHour);
        if(currentHour >= 14){ 
            if( indStand.After__c != null){	
                milliseconds = (indStand.After__c.intValue() * 16 * 3600000);
            } 	
            system.debug('if milliseconds==>'+(milliseconds));
            system.debug('if milliseconds 2==>'+(milliseconds+57600000));
            targetSLADate = getBusinessHours(bh.Id, currDateTime.local, milliseconds); 
            System.debug('After Value==>'+targetSLADate);
        }else if(currentHour >= 10 && currentHour < 14){
            if( indStand.Before__c != null){ 
                milliseconds = (indStand.Before__c.intValue() * 16 * 3600000)-57600000;
            }
            system.debug('else milliseconds==>'+(milliseconds-57600000));
            targetSLADate = getBusinessHours(bh.Id, currDateTime.local, milliseconds); 
            System.debug('Before Value==>'+targetSLADate);
        }else{
            if( indStand.Before__c != null){ 
                milliseconds = (indStand.Before__c.intValue() * 16 * 3600000);
            }
            system.debug('else milliseconds==>'+milliseconds);
            targetSLADate = getBusinessHours(bh.Id, currDateTime.local, milliseconds);
            System.debug('Before Value==>'+targetSLADate);
        }
        return targetSLADate;
    }

    //Use industry standard to calculate SLA date using location timezone
    public static DateTime calculateISSLA_LocTimezone(Industry_Standard_SLA__mdt indStand, BusinessHours bh, SBQQ__QuoteLine__c parentQL, String locTimeZone) {
        DateTime targetSLADate;
        Long milliseconds = 0;
        integer daysAdd = 0;
        currentDateTime currDateTime;
        Boolean isQuoteSLA = false;
        Integer offset;
        //Changes for SDT-39637
        if(locTimeZone != null)
        {
            isQuoteSLA = parentQL!=null?true:false;
            currDateTime = new currentDateTime(locTimeZone);
            Datetime now = Datetime.now();
            Timezone timeZone = Timezone.getTimeZone(locTimeZone);
            offset = timeZone.getOffset(now);
             system.debug('Location offset==> '+ offset);
             system.debug('When have parent quoteline ' +currDateTime);
        }
        else
        {
            // system.debug('When donot have parent quoteline');
            currDateTime = new currentDateTime();
            system.debug('No parent quoteline ' +currDateTime);

        }
        integer currentHour = Integer.valueOf(currDateTime.hours.split(':')[0]);
         system.debug('bh==>'+bh);
         system.debug('currentHour==> '+currentHour);
        // system.debug('currDateTime.local==> '+currDateTime.local);
        system.debug('indStand.After__c==> '+indStand.After__c.intValue());
        system.debug('indStand.Before__c==> '+indStand.Before__c.intValue());
        //currentHour = 9;
        if(currentHour >= 12){

             system.debug('When currentHour > 12');
            if(indStand.After__c != null){	
                daysAdd = indStand.After__c.intValue();
                milliseconds = (daysAdd * 16 * 60 * 60 * 1000);
            } 	
            // system.debug('After milliseconds==>'+(milliseconds));
            // modified by av4
            // targetSLADate = getBusinessHours(bh.Id, currDateTime.local, milliseconds);
            targetSLADate = getBusinessHoursInAccountTimeZone(bh.Id, System.now(), milliseconds, locTimeZone);
            //targetSLADate = targetSLADate.addSeconds(offset/1000);
            // System.debug('After Value targetSLADate==> '+targetSLADate);
        }
        //morning 12(00:00AM) to 5 - //added by av4 for SDT-39637
        else if(currentHour >=0 && currentHour < 5) {
            if( indStand.Before__c != null){
                milliseconds = (indStand.Before__c.intValue() * 16 * 60 * 60 * 1000);
                targetSLADate = getBusinessHoursInAccountTimeZone(bh.Id, System.now(), milliseconds, locTimeZone);
            }
        }
       // else if(currentHour >= 10 && currentHour < 12){
        else if(currentHour < 12){
            //modified by av4
            /*if(locTimeZone != null && locTimeZone.contains('Pacific/Honolulu'))
            {
                daysAdd = indStand.Before__c.intValue() - 1;
                milliseconds = (daysAdd * 16 * 60 * 60 * 1000);
                system.debug('currDateTime.local'+currDateTime.local);
                targetSLADate = getBusinessHours(bh.Id, currDateTime.local, milliseconds);
                system.debug('Final HAST Time '+targetSLADate);
            }*/
            if( indStand.Before__c != null){
                //modified by av4 for SDT-39637
                milliseconds = (indStand.Before__c.intValue() * 16 * 60 * 60 * 1000) - 57600000 ; //(57600000 = 16Hrs)
                //milliseconds = (indStand.Before__c.intValue() * 16 * 60 * 60 * 1000);// - 57600000 ;
                // system.debug('Before milliseconds==>'+milliseconds);
                // modified by av4
                // targetSLADate = getBusinessHours(bh.Id, currDateTime.local, milliseconds);
                targetSLADate = getBusinessHoursInAccountTimeZone(bh.Id, System.now(), milliseconds, locTimeZone);
            }
        }
        /*else{
             system.debug('When currentHour < 10');
            if( indStand.Before__c != null){ 
                
                ///This logic is return to handle the Friday SLA calculation scenarion
                //in which weekend date is coming when have Indus. SLA 7 days.
                //To correct that first add 7 days in Business Hours then deducte the hours 
                //As per time zone offset.
                //modified by av4
                /*if(isQuoteSLA && currDateTime.dayOfWeek == 'Fri' && indStand.Before__c.intValue() == 7)
                {
                    milliseconds = (indStand.Before__c.intValue() * 16 * 60 * 60 * 1000);
                    // system.debug('Before milliseconds==>'+milliseconds);
                    targetSLADate = getBusinessHours(bh.Id, currDateTime.local, milliseconds);

                    // system.debug('targetSLADate ==>'+targetSLADate);
                    
                    targetSLADate = targetSLADate.addSeconds(offset/1000);
                    system.debug('Friday Scenario ' +targetSLADate);
                }*/
                //else{
                    //modified by av4
                    //daysAdd = indStand.Before__c.intValue() - 1;
                    //milliseconds = (daysAdd * 16 * 60 * 60 * 1000);
                	/*milliseconds = (indStand.Before__c.intValue() * 16 * 60 * 60 * 1000) - 57600000 ;
                	//milliseconds = (indStand.Before__c.intValue() * 16 * 60 * 60 * 1000);// - 57600000 ;
                    system.debug('currDateTime.local'+currDateTime.local);
                    //modified by av4
                    // targetSLADate = getBusinessHours(bh.Id, currDateTime.local, milliseconds);
                	targetSLADate = getBusinessHoursInAccountTimeZone(bh.Id, System.now(), milliseconds, locTimeZone);
                    system.debug('Timezone '+targetSLADate);
                    //targetSLADate = BusinessHours.add(bh.Id, currDateTime.local, milliseconds);
                    system.debug('local '+targetSLADate);
               // }
            }
            System.debug('Before Value targetSLADate==> '+targetSLADate);            
        }*/
             
        return targetSLADate;
    }
    
    //this switch was created for switching off of new sla functionality(added as part of SDT-39637, SDT-45007, SDT-47970, SDT-47975), without actually
    //rolling back the code changes done.
    public static boolean getSLASwitch(){
        Code_Switch__c codeSwitchSetting = Code_Switch__c.getValues('SLA Logic Switch'); 
        return codeSwitchSetting.Switch_Off__c;
    }
    
    /*******************************************************************************************************
    * @description Utility Method to add business hours using business id 
    * @param businessHoursId of type Id
    * @param startDate of type DateTime
    * @param intervalMilliseconds of type Long
    * @return Datetime
    * @example
    */
    private static DateTime getBusinessHours(Id businessHoursId,DateTime startDate, Long intervalMilliseconds){
        return BusinessHours.addGmt(businessHoursId, startDate, intervalMilliseconds);
    }
    
    //added by av4
    public static DateTime getBusinessHoursInAccountTimeZone(Id businessHoursId,DateTime utcStartDateTime, Long intervalMilliseconds, String accTimeZone){
        // Get the TimeZone object from the provided ID
        TimeZone tz = TimeZone.getTimeZone(accTimeZone);
        
        // Get the offset from GMT for this time zone at the given datetime
        Integer offsetMillis = tz.getOffset(utcStartDateTime);
        
        // Add the offset to the given UTC
        //DateTime convertedStartDateTime = utcDateTime.addSeconds(offsetMillis/1000);
        //System.debug('convertedStartDateTime => ' + convertedStartDateTime + 'desiredTimeZone => ' + desiredTimeZone);
        
        //Adding additional date or hours to based on business hours
        DateTime utcEndDateTime = BusinessHours.add(businessHoursId, utcStartDateTime, intervalMilliseconds);
        
        // Add the offset to the convert to desired timezone
        DateTime convertedEndDateTime = utcEndDateTime.addSeconds(offsetMillis/1000);
        
        return convertedEndDateTime;
    }
    
    
    /*******************************************************************************************************
    * @description Utility Method to get location business hours using location timezone
    * @param timeZone of type String
    * @return Businesshours
    * @example
    */    
    public static List<Businesshours> getBusinessIdByTimeZone(string timeZone)
    {
        timeZone = 'WM SBS - ' + timeZone; //WM SBS - America/Los_Angeles
        List<Businesshours> businessHours = [SELECT Id, Name, TimeZoneSidKey, isActive FROM Businesshours WHERE isActive = True  
                                    AND Name =: timeZone LIMIT 1];
        // system.debug('Fetching local time Picked Businesshours==>' + businessHours);
        return businessHours;
    }
    
    
    public static Entitlement getRelatedEntitleMent(string quoteId, string parentqLineId){
        Entitlement e;
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        SBQQ__QuoteLine__c pqLine = new SBQQ__QuoteLine__c();
        List<Entitlement> entList = new List<Entitlement>();
        List<Entitlement> newList = new List<Entitlement>();
        Map<String,String> statusApiToLabelMap = new Map<String,String>();
        currentDateTime currDateTime;
        quote = [SELECT id, Project__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__c, SBQQ__Account__r.ParentId
                 FROM SBQQ__Quote__c 
                 WHERE id = : quoteId];

        pqLine = [SELECT id, Name, SBQQ__Quote__c, Duration__c, SBQQ__ProductName__c, CreatedDate,
                    SBQQ__Quote__r.SBQQ__Account__r.tz__Timezone_SFDC__c  
                  FROM SBQQ__QuoteLine__c 
                  WHERE Id = : parentqLineId 
                  AND SBQQ__RequiredBy__c=null];
        List<Schema.PicklistEntry> values = SBQQ__QuoteLine__c.Duration__c.getDescribe().getPicklistValues();
		
		For(Schema.PicklistEntry sp : values){
            //Map to hold Picklist API as Key and Picklist Label as Value
            statusApiToLabelMap.put(sp.getValue(), sp.getLabel());
        }
        
        //Adding Order By Container Condition in the Query for Priority Logic - SDT-24925
        //SDT-25065 - Added a extra filter in the Where condition for Location or Parent Account 
        entList = [SELECT Id, Request_Type__c, Service__c, AccountId, Project_Code__c, Container__c,
                Service_Guarantee_Category__c, Service_Guarantee_Category_Value__c, Call_On__c, 
                Project__c, Location__c, Schedule_Type__c, Before_After__c,Call_Time__c 
                FROM Entitlement
                WHERE Request_Type__c =: Constant_Util.NEW_SERVICE 
                AND Status__c =:  Constant_Util.APPROVED
                AND (Container__c =: pqLine.SBQQ__ProductName__c OR Container__c = '' OR Container__c = null ) 
                AND ((AccountId =: quote.SBQQ__Account__r.ParentId AND Location__c =: quote.SBQQ__Account__c) 
                    OR (AccountId =: quote.SBQQ__Account__r.ParentId AND Location__c = null)) 
                AND StartDate <= TODAY AND (EndDate = null OR EndDate >= TODAY) ORDER BY Container__c DESC];
        system.debug('Orignal List '+ entList);
        system.debug('Orignal List size '+ entList.size());
        
        if(!getSLASwitch()){
            for(Entitlement e1 : entList){
                currDateTime = new currentDateTime(pqLine.SBQQ__Quote__r.SBQQ__Account__r.tz__Timezone_SFDC__c);
                //integer currentHour = Integer.valueOf(currDateTime.hours.split(':')[0]);
                //integer callTime = Integer.valueOf(e1.Call_Time__c.split(':')[0]);
                If(e1.Before_After__c != null && (Constant_Util.BEFORE).equalsIgnorecase(e1.Before_After__c)){
                    if(currDateTime.hours <= e1.Call_Time__c)
                    {
                        newList.add(e1);
                    }
                }
                else If(e1.Before_After__c != null && (Constant_Util.AFTER).equalsIgnorecase(e1.Before_After__c)){
                    if(currDateTime.hours >= e1.Call_Time__c)
                    {
                        newList.add(e1);
                    }
                }
            }
        }
        else{
            newList = entList;
        }
        system.debug('Filter List '+ newList);
        system.debug('Orignal List size '+ newList.size());
        if(newList.size()>0){
            for(Entitlement ent: newList){
                //Projects for Locations - Priority 1
                //Adding Null Check for Project Code on Quote and Entitlement as part of SDT-26160
                if(quote.Project__c != null && ent.Project_Code__c != null){
                    if(quote.Project__c == ent.Project_Code__c && 
                        quote.SBQQ__Account__c == ent.Location__c)
                    {
                        system.debug('Priority 1 selected where Project Code and Location matched.');
                        e = ent;
                        break;
                    }
                    //Projects for Location's Parent Account - Priority 2
                    else if(quote.Project__c == ent.Project_Code__c && 
                            quote.SBQQ__Account__r.ParentId == ent.AccountId)
                    {
                        system.debug('Priority 2 selected where Project Code and Account matched.');
                        e = ent;
                        break;
                    }
                }
                //Duration and Container Match for Location - Priority 3
                else if(statusApiToLabelMap.get(pqLine.Duration__c) == ent.Schedule_Type__c && 
                        pqLine.SBQQ__ProductName__c == ent.Container__c && 
                        quote.SBQQ__Account__c  == ent.Location__c)
                {
                    system.debug('Priority 3 selected where ScheduleType, Container and Location matched.');
                    e = ent;
                    break;
                }                
                //Duration Match for Location - - Priority 4
                else if(statusApiToLabelMap.get(pqLine.Duration__c) == ent.Schedule_Type__c && 
                        quote.SBQQ__Account__c == ent.Location__c)
                {
                    system.debug('Priority 4 selected where Duration and Location matched.');
                    e = ent;
                    break;                        
                }
                //Commenting Below logic as a part of SDT-24402 Discussion's to eliminate Priority 5 and 6 Logic
                //Container Match for Location
                /**else if(pqLine.SBQQ__ProductName__c == ent.Container__c && 
                        quote.SBQQ__Account__c == ent.Location__c)
                {
                    e = ent;
                    break;    
                }
                //Entitlement for Location
                else if(quote.SBQQ__Account__c == ent.Location__c){
                    e = ent;
                    break;
                }*/
                //Duration and Container Match for Location's Parent Account -  Priority 5
                else if(statusApiToLabelMap.get(pqLine.Duration__c) == ent.Schedule_Type__c && 
                        pqLine.SBQQ__ProductName__c == ent.Container__c && 
                        quote.SBQQ__Account__r.ParentId == ent.AccountId)
                {
                    system.debug('Priority 5 selected where Duration, Container and Account matched.');
                    e = ent;
                    break;
                }
                //Duration Match for Location's Parent Account - Priority 6
                else if(statusApiToLabelMap.get(pqLine.Duration__c) == ent.Schedule_Type__c && 
                        quote.SBQQ__Account__r.ParentId == ent.AccountId)
                {
                    system.debug('Priority 6 selected where Duration and Account matched.');
                    e = ent;
                    break;
                }
                //Commenting Below logic as a part of SDT-25078 to eliminate Priority 9 Logic
                /*Entitlement for Location's Parent Account
                else if(quote.SBQQ__Account__r.ParentId == ent.AccountId)
                {
                    e = ent;
                    break;
                }*/
            }
        }
        return e;
    }
    
    public class FavoriteWrapper{
        @AuraEnabled public String favoriteId {get; set;}
        @AuraEnabled public String containerType {get; set;}
        @AuraEnabled public String equipmentSize {get; set;}
        @AuraEnabled public String materialType {get; set;}
        @AuraEnabled public Decimal quantity {get; set;}
        @AuraEnabled public String ownership {get; set;}
        @AuraEnabled public Boolean quantityEditable {get; set;}
    }    
   
    public class currentDateTime{
        public string dayOfWeek;
        public string hours;
        public Datetime local;
        public currentDateTime(){
            Datetime now = Datetime.now();
            Integer offset = UserInfo.getTimezone().getOffset(now);
            local = now.addSeconds(offset/1000);
            dayOfWeek = local.formatGmt('EEE');
            hours = local.formatGmt('HH:mm');
            // system.debug('Current dayOfWeek==>'+ dayOfWeek);
            // system.debug('Current Date time hours==>'+hours);
        }

        public currentDateTime(String locationTimeZone){
            Datetime now = Datetime.now();
            Timezone timeZone = Timezone.getTimeZone(locationTimeZone);
            Integer offset = timeZone.getOffset(now);
            local = now.addSeconds(offset/1000);

            dayOfWeek = local.formatGmt('EEE');
            hours = local.formatGmt('HH:mm');
            system.debug('Current dayOfWeek==>'+ dayOfWeek);
            system.debug('Current Date time hours==>'+ hours);
        }
    }
}
