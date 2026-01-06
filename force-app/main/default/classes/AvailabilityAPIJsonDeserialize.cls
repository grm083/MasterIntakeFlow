public class AvailabilityAPIJsonDeserialize {
	public cls_data data;
	//public cls_problem problem;
	public class cls_data {
		//public String requestedDate;	//2023-09-01
		//public String lineOfBusiness;	//Roll Off
		//public String customerCode;	//HMD
		//public String customerName;	//The Home Depot
		//public String locationCode;	//HMD000100
		//public String materialCode;	//T
		//public String materialName;	//Trash
		//public String countryCode;	//USA
		public cls_suppliers[] suppliers;
		//public cls_messages[] messages;
	}
	public class cls_suppliers {
		public String availabilitySource;	//WM
		//public String supplierCode;	//212852|213044|222658|2451|4670|6138|648|846|9096|9717
		//public String supplierName;	//City of Smyrna GA|WMI OF MO, WASHINGTON|Waste Pro of Atlanta|WMI OF VA, HAMPTON|WMI OF KS, MANHATTAN|WMI OF NC, THE PIEDMONT, WINSTON-SALEM|COMMERCIAL DISPOSAL|Diamond Rentals, INC|WM-Advanced Smyrna Hauling|WMI OF IN, LAFAYETTE
		public String contractType;	//Open Market
		//public String wasteStreamCode;	//MSW
		//public String wasteStreamName;	//Municipal Solid Waste
		//public String zoneCode;	//GIS526480
		//public String zoneName;	//B0073 ZOOGR - EAST COBB FULTON MSW TO PA
		public cls_wmMetaData wmMetaData;
		//public cls_tpMetaData tpMetaData;
		//public cls_deliveryDays[] deliveryDays;
		//public cls_serviceDays[] serviceDays;
		//public cls_deliveries[] deliveries;
		//public cls_outages outages;
		//public cls_messages[] messages;
	}
	public class cls_wmMetaData {
		public String marketAreaCode;	//K00126
		public String marketAreaName;	//WM of South Atlantic
        /*public String facilityId;
        public String facilityName;
        public String siteId;
        public String siteName;*/
	}
    /*class cls_tpMetaData {
	}
	class cls_deliveryDays {
		public String 0;	//M
		public String 1;	//o
		public String 2;	//n
		public String 3;	//d
		public String 4;	//a
		public String 5;	//y
	}
	class cls_serviceDays {
		public String 0;	//M
		public String 1;	//o
		public String 2;	//n
		public String 3;	//d
		public String 4;	//a
		public String 5;	//y
	}
	class cls_deliveries {
		public String equipmentCode;	//OT
		public String equipmentName;	//Open Top
		public String equipmentSizeCode;	//YRDS-10
		public String equipmentSizeName;	//10 Yards
		public cls_dates[] dates;
		public cls_messages[] messages;
		public cls_wmMetaData wmMetaData;
		public cls_tpMetaData tpMetaData;
	}
	class cls_dates {
		public String 0;	//2
		public String 1;	//0
		public String 2;	//2
		public String 3;	//3
		public String 4;	//-
		public String 5;	//0
		public String 6;	//9
		public String 7;	//-
		public String 8;	//0
		public String 9;	//1
	}
	public class cls_messages {
        public String code;
        public String description;
	}
	public class cls_outages {
	}
	public class cls_problem {
	}*/
	public static AvailabilityAPIJsonDeserialize parse(String json){
		return (AvailabilityAPIJsonDeserialize) System.JSON.deserialize(json, AvailabilityAPIJsonDeserialize.class);
	}
}