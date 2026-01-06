public class AAV_AvailbilityAppHelper{
    /*@methodName- getAvailabilityRecordById
     *@description- Method to get the Availability Record by record Id
     *@param- Id : Availability Id
     *@return- Asset Availability record
     */
    @AuraEnabled(cacheable = true)
    public static AvailabilityOutputWrapper getAvailabilityRecordById(String recordId){
        AvailabilityOutputWrapper wrapper = new AvailabilityOutputWrapper();
        if (recordId != null){
            list<AAV_Asset_Availability__c> availabilityList = [SELECT Id, AAV_Delivery_Date__c, AAV_Location__c, AAV_Location__r.ParentId, AAV_Line_of_Business__c, AAV_Container_Type__c, toLabel(AAV_Container_Type__c)containerTypeLabel, AAV_MaterialCode__c, AAV_Service_Type__c, AAV_APIRequestOutput__c, AAV_isAPIResult__c
                                                                FROM AAV_Asset_Availability__c
                                                                WHERE id = :recordId];
            //Check availability record is exist or not, if exist then return the availability Record.
            if (availabilityList != null && availabilityList.size() > 0){
                wrapper.deliveryDate = availabilityList[0].AAV_Delivery_Date__c;
                wrapper.location = availabilityList[0].AAV_Location__c;
                wrapper.lineOfBusiness = availabilityList[0].AAV_Line_of_Business__c;
                wrapper.containerType = availabilityList[0].AAV_Container_Type__c;
                wrapper.serviceType = availabilityList[0].AAV_Service_Type__c;
                wrapper.materialCode = availabilityList[0].AAV_MaterialCode__c;
                wrapper.apiResponse = availabilityList[0].AAV_APIRequestOutput__c;
                wrapper.apiResult = availabilityList[0].AAV_isAPIResult__c;
                wrapper.accountId = availabilityList[0].AAV_Location__r.ParentId;
                Object containerTypeLabel = availabilityList[0].get('containerTypeLabel'); //SDT-29723 - for Asset Availablity
                wrapper.productName = containerTypeLabel != null ? containerTypeLabel.toString() : ''; //SDT-29723 - for Asset Availablity
            }
            return wrapper;
        } else{
            throw new AuraHandledException('Availability is Empty');
        }
    }

    /**************************************************************
     * Method name : determineSLAForAllContainers
     * Description : 
     * Returns :  Date for input product (QLI wrapper)
     * User Story : SDT-32015
     ****************************************************************/
    @AuraEnabled(cacheable = true)
    public static Date determineSLAForAllContainers(SlaCalculationInputWrapper inputWrapper){
        DateTime SLADate = system.now();
        Map<String, String> checkDuration = new Map<String, String>{ 'TEMP' => 'Temporary', 'PERM' => 'Permanent', 'SEAS' => 'Seasonal' };
        try{
            BusinessHours defaultHours = [SELECT Id FROM BusinessHours WHERE isDefault = true LIMIT 1];
            //Check related Entitlement
            Entitlement relEntitlement = getRelatedEntitleMent(inputWrapper);
            if (relEntitlement == null || relEntitlement.id == null){
                String serviceFilter = 'New Service_' + checkDuration.get(inputWrapper.duration);
                List<Industry_Standard_SLA__mdt> industryStandardMap = [SELECT Id, Service__c, After__c, Before__c
                                                                                FROM Industry_Standard_SLA__mdt
                                                                                WHERE Service__c LIKE:(serviceFilter + '_' + inputWrapper.productFamily)];
                if(industryStandardMap!=null && industryStandardMap.size()!=0)
                    SLADate = QuoteFavoritesController.calculateISSLA(industryStandardMap[0], defaultHours);
            } else{
                SLADate = QuoteFavoritesController.calculateEntitlementSLA(relEntitlement, defaultHours);
            }
        } catch (Exception e){
            System.debug('Error ' + e);
        }
        return SLADate.date();
    }
    //method copied form QuoteFavoritesController.getRelatedEntitleMent() -Input changed
    public static Entitlement getRelatedEntitleMent(SlaCalculationInputWrapper inputWrapper){
        Entitlement e;
        String productName = inputWrapper.productName.contains('Compactor') ? 'Compactor' : inputWrapper.productName;
        List<Entitlement> entList = new List<Entitlement>();
        //Adding Order By Container Condition in the Query for Priority Logic - SDT-24925
        entList = [SELECT Id, Request_Type__c, Service__c, AccountId, Project_Code__c, Container__c, Service_Guarantee_Category__c, Service_Guarantee_Category_Value__c, Call_On__c, Project__c, Location__c, Schedule_Type__c, Before_After__c, Call_Time__c
                   FROM Entitlement
                   WHERE Request_Type__c = :Constant_Util.NEW_SERVICE AND Status__c = :Constant_Util.APPROVED AND (Container__c = :productName OR Container__c = '' OR Container__c = null) AND ((AccountId = :inputWrapper.account AND Location__c = :inputWrapper.location) OR (AccountId = :inputWrapper.account AND Location__c = null)) AND StartDate <= TODAY AND (EndDate = null OR EndDate >= TODAY)
                   ORDER BY Container__c DESC];
        for (Entitlement ent : entList){
            //Projects for Locations - Priority 1
            //Projects for Location's Account - Priority 2
            if (inputWrapper.project != null && ent.Project_Code__c != null){
                if ((inputWrapper.project == ent.Project_Code__c && inputWrapper.location == ent.Location__c) ||
                (inputWrapper.project == ent.Project_Code__c && inputWrapper.account == ent.AccountId)){
                    e = ent;
                    break;
                }
            }
            //Duration and Container Match for Location - - Priority 3
            //Duration Match for Location - - Priority 4
            //Duration and Container Match for Location's Parent Account - - Priority 5
            //Duration Match for Location's Parent Account - Priority 6
            else if ((inputWrapper.duration == ent.Schedule_Type__c && productName == ent.Container__c && inputWrapper.location == ent.Location__c) ||
                (inputWrapper.duration == ent.Schedule_Type__c && inputWrapper.location == ent.Location__c) ||
                (inputWrapper.duration == ent.Schedule_Type__c && productName == ent.Container__c && inputWrapper.account == ent.AccountId) ||
                (inputWrapper.duration == ent.Schedule_Type__c && inputWrapper.account == ent.AccountId))
            {
                e = ent;
                break;
            }
        }
        return e;
    }
    /*@methodName- getAccountAddress
    *@description- Method to query the Account address record 
    *@param- Id :accountId
    *@return- Account Record
    */  
    @AuraEnabled
    public static Account getAccountAddress(Id accountId){
        Account accRecord;
        try{ 
            accRecord = [SELECT Id, Name,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,
                        ShippingPostalCode, ParentId,Parent.Name FROM Account WHERE id = :accountId];
        }catch(Exception ex){
            throw new AuraHandledException('Can not fetch account information');
        }
        return accRecord;
    }

    /**************************************************************
     * Method name : getAssetAvailabilityOutputFields
     * Description :
     * Returns :  Asset Availability Output Field metadata
     * User Story : SDT-32015
     ****************************************************************/
    @AuraEnabled(cacheable = true)
    public static list<AAV_Asset_Availability_Output_Field__mdt> getAppOutputFields(String availabilityType){
        if (String.isNotBlank(availabilityType)){
            list<AAV_Asset_Availability_Output_Field__mdt> aavOutputFields = [SELECT Id, DeveloperName, MasterLabel, 
                                        Language, Label, QualifiedApiName, API_Name__c, 
                                        Visible__c, Sequence__c, Parent_Container__c, Condition__c, Type__c, Data_Type__c
                                        FROM AAV_Asset_Availability_Output_Field__mdt
                                        WHERE Type__c = :availabilityType AND Visible__c = true order by  Sequence__c];
            return aavOutputFields;
        } else{
            throw new AuraHandledException('Availability Type Should not be Empty');
        }
    }

    public class SlaCalculationInputWrapper{
        @AuraEnabled
        public String location{ get; set; }

        @AuraEnabled
        public String account{ get; set; }

        @AuraEnabled
        public String duration{ get; set; }

        @AuraEnabled
        public String productFamily{ get; set; }

        @AuraEnabled
        public String project{ get; set; }

        @AuraEnabled
        public String productName{ get; set; }

        // @AuraEnabled
        // public List<String> equipmentSizes{ get; set; }

    }

    public class AvailabilityOutputWrapper{
        @AuraEnabled
        public Date deliveryDate{ get; set; }

        @AuraEnabled
        public String location{ get; set; }

        @AuraEnabled
        public String accountId{ get; set; }

        @AuraEnabled
        public String serviceType{ get; set; }

        @AuraEnabled
        public String lineOfBusiness{ get; set; }

        @AuraEnabled
        public String containerType{ get; set; }

        @AuraEnabled
        public String productName{ get; set; }

        @AuraEnabled
        public String materialCode{ get; set; }

        @AuraEnabled
        public Boolean apiResult{ get; set; }

        @AuraEnabled
        public String apiResponse{ get; set; }

    }

}