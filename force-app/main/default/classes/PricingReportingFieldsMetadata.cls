public class PricingReportingFieldsMetadata {
    public Data data;
	public Problem problem;
	public ServiceCharges ServiceCharges;

	public class ServiceCharges {
		public String code;
		public String name;
		public String componentTypeCode;
		public String componentTypeName;
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
		// Changes for Exhibit Pricing Story- SDT-20401
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
		// Changes for Exhibit Pricing Story- SDT-20401
		public Integer haulRecordId;
		public Integer disposalRecordId;
		public List<StepDisposal> stepDisposals;
	}

	// Changes for Exhibit Pricing Story- SDT-20401
	public class StepDisposal
	{
	        public Double priceUpTo;
	        public string priceRange;
	        public Double costUpTo;
	        public String costRange;
	        public Double cost;
	        public Double price;
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

	public class tpMetaData {
		public Double diversion;
		public String scaleAvailability;
	}

	public class Data {
		public String priceQuoteIdentifier;
		public String costSource;
		// Changes for Exhibit Pricing Story- SDT-20401
		public String priceSource;
		public String contractType;
		public String lineOfBusiness;
		public String supplierCode;
		public String supplierName;
		public String customerCode;
		public String customerName;
		public String locationCode;
		public String wasteStreamCode;
		public String wasteStreamName;
		public String equipmentCode;
		public String equipmentName;
		public String equipmentUOM;
		public String materialCode;
		public String materialName;
		public String equipmentSizeCode;
		public String equipmentSizeName;
		public String overridableEquipmentSizeCode;
		public String overridableEquipmentSizeName;
		public String zoneCode;
		public String zoneName;
		public String zoneDescription;
		public String zoneNotes;
		public String disposalFacilityType;
		public String disposalFacilityName;

		public commercial commercial;
		public rollOff rollOff;
		public wmMetaData wmMetaData;
		public tpMetaData tpMetaData;
		
		// public String dispositionType;
		// public String dispositionName;
		
		public List<ServiceCharges> serviceCharges;
		// changes for Story 23393
		public String feeComment;
		// Changes for SDT-24009
		public Boolean isCostOnly;
		// Changes for SDT-25845
		public String countryCode;
		public String currencyCode;
	}

	
	public static PricingReportingFieldsMetadata parse(String json) {
		return (PricingReportingFieldsMetadata) System.JSON.deserialize(json, PricingReportingFieldsMetadata.class);
	}
}