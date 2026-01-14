/**
 * Controller for Case Details Panel LWC
 * Provides Asset and Location details for display in Master Intake Flow side panel
 */
public with sharing class CaseDetailsPanelController {

    /**
     * Get comprehensive case details including Asset and Location information
     * @param caseId The Case record ID
     * @return CaseDetailsWrapper containing all related information
     */
    @AuraEnabled(cacheable=true)
    public static CaseDetailsWrapper getCaseDetails(Id caseId) {
        try {
            // Query Case with Asset and Location relationships
            Case caseRecord = [
                SELECT Id, CaseNumber,
                       // Asset fields
                       AssetId,
                       Asset.Name,
                       Asset.Material_Type__c,
                       Asset.Acorn_SID__c,
                       Asset.Duration__c,
                       Asset.Occurrence_Type__c,
                       Asset.Schedule__c,
                       Asset.Supplier__r.Name,
                       Asset.Supplier__c,
                       Asset.Vendor_ID__c,
                       Asset.Sensitivity_Code__c,
                       Asset.Has_Extra_Pickup__c,
                       Asset.Equipment_Owner__c,
                       Asset.Start_Date__c,
                       Asset.End_Date__c,
                       Asset.Container_Position__c,
                       Asset.Category__c,
                       Asset.Vendor_Account_Number__c,
                       Asset.MAS_Customer_Unique_Id__c,
                       Asset.MAS_Company_Account_Number__c,
                       Asset.MAS_Library__c,
                       Asset.Project_Code__r.ProjectCode_Id__c,
                       Asset.ProductFamily,
                       Asset.Service_Header_Id__c,
                       // Location fields
                       Location__c,
                       Location__r.Name,
                       Location__r.Location_Code__c,
                       Location__r.AccountNumber,
                       Location__r.ShippingStreet,
                       Location__r.ShippingCity,
                       Location__r.ShippingState,
                       Location__r.ShippingPostalCode,
                       Location__r.ShippingCountry,
                       Location__r.Phone,
                       Location__r.Primary_Segment__c,
                       Location__r.tz__Local_Time_Short__c,
                       Location__r.Customer_Location_Code__c,
                       Location__r.Is_Portal_Customer__c,
                       Location__r.Portal_Name__c,
                       // Client fields
                       Client__c,
                       Client__r.Name
                FROM Case
                WHERE Id = :caseId
                LIMIT 1
            ];

            CaseDetailsWrapper wrapper = new CaseDetailsWrapper();
            wrapper.caseRecord = caseRecord;
            wrapper.hasAsset = caseRecord.AssetId != null;
            wrapper.hasLocation = caseRecord.Location__c != null;

            // Get service details if Asset exists
            if (wrapper.hasAsset) {
                wrapper.serviceDetails = getServiceDetails(caseRecord);
            }

            return wrapper;

        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving case details: ' + e.getMessage());
        }
    }

    /**
     * Get service pricing details for the Asset
     * @param caseRecord The Case record with Asset relationship
     * @return ServiceDetailsWrapper containing pricing information
     */
    private static ServiceDetailsWrapper getServiceDetails(Case caseRecord) {
        ServiceDetailsWrapper details = new ServiceDetailsWrapper();

        try {
            // Query service details related to the Asset
            Set<String> serviceTypes = new Set<String>{'Pickup', 'Haul', 'Disposal'};

            List<Asset> serviceAssets = [
                SELECT Id, Service_Type__c, Occurrence_Type__c, Cost__c,
                       Price__c, Has_Extra_Pickup__c, Quantity__c
                FROM Asset
                WHERE Service_Header_Id__c = :caseRecord.AssetId
                  AND Service_Type__c IN :serviceTypes
                  AND Is_Active__c = true
                  AND RecordType.DeveloperName = 'Service_Details'
                LIMIT 49999
            ];

            // Process service details by type
            for (Asset svc : serviceAssets) {
                if (svc.Service_Type__c == 'Pickup') {
                    if (svc.Occurrence_Type__c == 'Scheduled') {
                        details.assetQuantity = svc.Quantity__c;
                        if (svc.Has_Extra_Pickup__c) {
                            details.pickUpCost = svc.Cost__c;
                            details.pickUpPrice = svc.Price__c;
                        }
                    } else if (svc.Occurrence_Type__c == 'On Call') {
                        details.extraPickUpCost = svc.Cost__c;
                        details.extraPickUpPrice = svc.Price__c;
                    }
                } else if (svc.Service_Type__c == 'Haul') {
                    details.haulCost = svc.Cost__c;
                    details.haulPrice = svc.Price__c;
                } else if (svc.Service_Type__c == 'Disposal') {
                    details.disposalCost = svc.Cost__c;
                    details.disposalPrice = svc.Price__c;
                }
            }

        } catch (Exception e) {
            System.debug('Error getting service details: ' + e.getMessage());
        }

        return details;
    }

    /**
     * Wrapper class for Case details response
     */
    public class CaseDetailsWrapper {
        @AuraEnabled public Case caseRecord { get; set; }
        @AuraEnabled public Boolean hasAsset { get; set; }
        @AuraEnabled public Boolean hasLocation { get; set; }
        @AuraEnabled public ServiceDetailsWrapper serviceDetails { get; set; }

        public CaseDetailsWrapper() {
            this.hasAsset = false;
            this.hasLocation = false;
        }
    }

    /**
     * Wrapper class for service pricing details
     */
    public class ServiceDetailsWrapper {
        @AuraEnabled public Decimal assetQuantity { get; set; }
        @AuraEnabled public Decimal pickUpCost { get; set; }
        @AuraEnabled public Decimal pickUpPrice { get; set; }
        @AuraEnabled public Decimal extraPickUpPrice { get; set; }
        @AuraEnabled public Decimal extraPickUpCost { get; set; }
        @AuraEnabled public Decimal haulCost { get; set; }
        @AuraEnabled public Decimal haulPrice { get; set; }
        @AuraEnabled public Decimal disposalCost { get; set; }
        @AuraEnabled public Decimal disposalPrice { get; set; }
    }
}
