public class PricingRequestFieldsMetadata {
    public Data data;
	public Problem problem;
	//public ServiceCharges ServiceCharges;

    public class ServiceCharges {
		public String code;
		public String name;
		public String componentCode;
		public String componentName;
		public String actionCode;
		public String actionName;
		public Double cost;
		public String costValueType;
		public String costUOM;
		public Double price;
		public String priceValueType;
		public String priceUOM;
	}

    public class Errors {
		public String code;
		public String message;
	}

    public boolean isError() {
		if (this.Problem != null && this.Problem.Errors != null && this.Problem.Errors.size() > 0) {
			return true;
		}else{
		return false;
		}
	}

    public class Problem {
		public String title;
		public Integer status;
		public List<Errors> errors;
	}

    public class commercial {
		public String pricingMethodCode;
		public String pricingMethodCodeDescription;
		public String pricingMethodPickupDescription;
		public Double cost;
		public Double price;
		public Double unitCost;
		public Double unitPrice;
		public Double extraPickupCost;
		public Double extraPickupPrice;
		public Integer pickupRecordId;
		public Integer extraPickupRecordId;
	}

    public class rollOff {
		public String pricingMethodDisposalCode;
		public String pricingMethodDisposalDescription;
		public String pricingMethodHaulingCode;
		public String pricingMethodHaulingDescription;
		public Double haulCost;
		public Double haulPrice;
		public Double disposalCost;
		public Double disposalPrice;
		public Double estimatedVolumePerHaul;
		public String applyInvoiceFeesToDisposalCharges;
		public String applyInvoiceFeesToRentalCharges;
		public String transferSiteCode;
		public String equipmentAvailabilityTypeCode;
		public String materialClassName;
		public Integer haulRecordId;
		public Integer disposalRecordId;
		public List<StepDisposal> stepDisposals;
	}

    public class StepDisposal{
        public Double priceUpTo;
        public string priceRange;
        public Double costUpTo;
        public String costRange;
        public Double cost;
        public Double price;
	}

    public class messages{
        public String code;
		public String description;
    }

    public class wmMetaData {
		public String businessUnit;
		public String masLibrary;
		public String francisePricingLink;
		public String greenPagesLink;
		public String marketAreaCode;
		public String marketAreaName;
		public String facilityId;
		public String facilityName;
		public String siteId;
		public String siteName;
		public String masCustomerUniqueId;
		public String targetTrackingId;
	}

	public class RegulatoryFees{
		public String name;
		public Double cost;
		public Integer percentageBasedOrCompounded;
		public String appliesToDisposal;
		public String appliesToHaul;
		public String appliesToRental;
		public String basis;
		public String uom;
		public Integer order;
		public String comment;
	}

	public class tpMetaData {
		public Integer zoneRank;
		public String feeComment;
		public Double diversion;
		public String scaleAvailability;
		public List<RegulatoryFees> regulatoryFees;
	}

    public class suppliers{
        public String costSource;
        public String priceSource;
        public String supplierCode;
        public String supplierName;
        public String contractType;
        public String wasteStreamCode;
		public String wasteStreamName;
        public String equipmentUOM;
        public String zoneCode;
		public String zoneName;
        public String zoneDescription;
		public String zoneNotes;
        public String disposalFacilityType;
		public String disposalFacilityName;
        // public String feeComment;//need to confirm this variable is required or not?
        public Boolean isCostOnly;//need to confirm this variable is required or not?

        public commercial commercial;
        public rollOff rollOff;
        public List<ServiceCharges> serviceCharges;
        public wmMetaData wmMetaData;
		public tpMetaData tpMetaData;
        public List<messages> messages;
    }

    public class Data{
        public String priceQuoteIdentifier;
        public String lineOfBusiness;
        public String priceTypeCode;//need to confirm this variable is required or not?
        public String customerCode;
        public String customerName;
        public String locationCode;
        public String serviceBaselineId;//need to confirm this variable is required or not?
        public String equipmentCode;
		public String equipmentName;
        public String equipmentSizeCode;
		public String equipmentSizeName;
        public String materialCode;
		public String materialName;
        public String countryCode;
		public String currencyCode;
        public String equipmentAvailabilityCode;//need to confirm this variable is required or not?
        public String overridableEquipmentSizeCode;//need to confirm this variable is required or not?
		public String overridableEquipmentSizeName;//need to confirm this variable is required or not?

        public List<suppliers> suppliers;

    }

    public static PricingRequestFieldsMetadata parse(String json) {
		return (PricingRequestFieldsMetadata) System.JSON.deserialize(json, PricingRequestFieldsMetadata.class);
	}
}
