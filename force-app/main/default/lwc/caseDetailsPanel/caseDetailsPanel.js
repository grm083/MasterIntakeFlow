import { LightningElement, api, wire } from 'lwc';
import getCaseDetails from '@salesforce/apex/CaseDetailsPanelController.getCaseDetails';

export default class CaseDetailsPanel extends LightningElement {
    @api caseId;

    caseDetails;
    error;
    isAssetExpanded = true;  // Asset section expanded by default
    isLocationExpanded = true;  // Location section expanded by default
    isContactExpanded = true;  // Contact section expanded by default

    // Wire the case details from Apex
    @wire(getCaseDetails, { caseId: '$caseId' })
    wiredCaseDetails({ error, data }) {
        if (data) {
            this.caseDetails = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.caseDetails = undefined;
            console.error('Error loading case details:', error);
        }
    }

    // Computed properties for data availability
    get hasAssetData() {
        return this.caseDetails?.hasAsset && this.caseDetails?.caseRecord?.Asset;
    }

    get hasLocationData() {
        return this.caseDetails?.hasLocation && this.caseDetails?.caseRecord?.Location__r;
    }

    get hasContactData() {
        return this.caseDetails?.hasContact && this.caseDetails?.caseRecord?.Contact;
    }

    get asset() {
        return this.caseDetails?.caseRecord?.Asset;
    }

    get location() {
        return this.caseDetails?.caseRecord?.Location__r;
    }

    get client() {
        return this.caseDetails?.caseRecord?.Client__r;
    }

    get serviceDetails() {
        return this.caseDetails?.serviceDetails;
    }

    // Asset field getters
    get assetName() {
        return this.asset?.Name || 'N/A';
    }

    get materialType() {
        return this.asset?.Material_Type__c || 'N/A';
    }

    get sid() {
        return this.asset?.Acorn_SID__c || 'N/A';
    }

    get duration() {
        return this.asset?.Duration__c || 'N/A';
    }

    get occurrenceType() {
        return this.asset?.Occurrence_Type__c || 'N/A';
    }

    get schedule() {
        return this.asset?.Schedule__c || 'N/A';
    }

    get quantity() {
        return this.serviceDetails?.assetQuantity || 'N/A';
    }

    get vendorName() {
        return this.asset?.Supplier__r?.Name || 'N/A';
    }

    get vendorId() {
        return this.asset?.Vendor_ID__c || 'N/A';
    }

    get sensitivityCode() {
        return this.asset?.Sensitivity_Code__c || 'N/A';
    }

    get hasExtraPickup() {
        return this.asset?.Has_Extra_Pickup__c ? 'Yes' : 'No';
    }

    get equipmentOwner() {
        return this.asset?.Equipment_Owner__c || 'N/A';
    }

    get startDate() {
        return this.asset?.Start_Date__c || 'N/A';
    }

    get endDate() {
        return this.asset?.End_Date__c || 'N/A';
    }

    get hasEndDate() {
        return this.asset?.End_Date__c != null;
    }

    get containerPosition() {
        return this.asset?.Container_Position__c || 'N/A';
    }

    get category() {
        return this.asset?.Category__c || 'N/A';
    }

    get vendorAccountNumber() {
        return this.asset?.Vendor_Account_Number__c || 'N/A';
    }

    get masUniqueId() {
        return this.asset?.MAS_Customer_Unique_Id__c || 'N/A';
    }

    get masCompanyAccount() {
        return this.asset?.MAS_Company_Account_Number__c || 'N/A';
    }

    get masLibrary() {
        return this.asset?.MAS_Library__c || 'N/A';
    }

    get projectName() {
        return this.asset?.Project_Code__r?.ProjectCode_Id__c || 'N/A';
    }

    // Pricing getters
    get pickupPrice() {
        return this.formatCurrency(this.serviceDetails?.pickUpPrice);
    }

    get extraPickupPrice() {
        return this.formatCurrency(this.serviceDetails?.extraPickUpPrice);
    }

    get haulPrice() {
        return this.formatCurrency(this.serviceDetails?.haulPrice);
    }

    get disposalPrice() {
        return this.formatCurrency(this.serviceDetails?.disposalPrice);
    }

    get pickupCost() {
        return this.formatCurrency(this.serviceDetails?.pickUpCost);
    }

    get extraPickupCost() {
        return this.formatCurrency(this.serviceDetails?.extraPickUpCost);
    }

    get haulCost() {
        return this.formatCurrency(this.serviceDetails?.haulCost);
    }

    get disposalCost() {
        return this.formatCurrency(this.serviceDetails?.disposalCost);
    }

    // Location field getters
    get clientName() {
        return this.client?.Name || 'N/A';
    }

    get locationCode() {
        return this.location?.Location_Code__c || 'N/A';
    }

    get locationAddress() {
        return this.location?.ShippingStreet || 'N/A';
    }

    get locationPhone() {
        return this.location?.Phone || 'N/A';
    }

    get locationSegment() {
        return this.location?.Primary_Segment__c || 'N/A';
    }

    get locationCity() {
        return this.location?.ShippingCity || '';
    }

    get locationState() {
        return this.location?.ShippingState || '';
    }

    get locationZip() {
        return this.location?.ShippingPostalCode || '';
    }

    get locationCityStateZip() {
        const parts = [this.locationCity, this.locationState, this.locationZip].filter(p => p);
        return parts.length > 0 ? parts.join(', ') : 'N/A';
    }

    get locationCountry() {
        return this.location?.ShippingCountry || 'N/A';
    }

    get localTime() {
        return this.location?.tz__Local_Time_Short__c || 'N/A';
    }

    get customerLocationCode() {
        return this.location?.Customer_Location_Code__c || 'N/A';
    }

    get isPortalCustomer() {
        return this.location?.Is_Portal_Customer__c ? 'Yes' : 'No';
    }

    get portalName() {
        return this.location?.Portal_Name__c || 'N/A';
    }

    // Contact field getters
    get contact() {
        return this.caseDetails?.caseRecord?.Contact;
    }

    get contactName() {
        return this.contact?.Name || 'N/A';
    }

    get contactTitle() {
        return this.caseDetails?.caseRecord?.Contact_Title__c || 'N/A';
    }

    get contactEmail() {
        return this.contact?.Email || 'N/A';
    }

    get contactPhone() {
        const preferredMethod = this.contact?.Preferred_Method__c;
        if (preferredMethod === 'MobilePhone') {
            return this.contact?.MobilePhone || 'N/A';
        } else if (preferredMethod === 'Phone') {
            return this.contact?.Phone || 'N/A';
        }
        return 'N/A';
    }

    get preferredMethod() {
        return this.contact?.Preferred_Method__c || 'N/A';
    }

    get emailValidated() {
        return this.contact?.Email_Validated__c ? 'Yes' : 'No';
    }

    // Section toggle handlers
    handleAssetToggle() {
        this.isAssetExpanded = !this.isAssetExpanded;
    }

    handleLocationToggle() {
        this.isLocationExpanded = !this.isLocationExpanded;
    }

    handleContactToggle() {
        this.isContactExpanded = !this.isContactExpanded;
    }

    // Helper methods
    formatCurrency(value) {
        if (value == null || value === undefined) {
            return 'N/A';
        }
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(value);
    }

    // Icon names for sections
    get assetIcon() {
        return this.isAssetExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get locationIcon() {
        return this.isLocationExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get contactIcon() {
        return this.isContactExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }
}
