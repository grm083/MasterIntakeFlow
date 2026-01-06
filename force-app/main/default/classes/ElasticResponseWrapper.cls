/*************************************************************
@Name: ElasticResponseWrapper
@Author: 
@CreateDate: 5/Sep/2022
@Description: Response Wrapper to get Location Address Info
@UsedBy: SDT-25339
**************************************************************/
public class ElasticResponseWrapper{
	public Integer took;	//4
	public boolean timedout;
	public HitsWrap hits;
	
    public class HitsWrap {
		//public Total total {get;set;} 
		//public Double maxscore {get;set;} 
		public List<Hits> hits {get;set;}
	}
    
	public class Hits {
		public Source source;
	}
	public class Total {
		public Integer value;	//1
		public String relation;	//eq
	}
	public class Source {
		public Integer LocationId;	//351139
		public String LocationCode;	//DLL000434
		public String CompanyLocationCode;	//00434
		public String LocationName;	//DOLLAR TREE
		public String LocationDescription;
		public String PreviousLocationId;
		public String ClientGLAccount;
		public Integer SquareFootage;	//0
		public String Rank;
		public String LocationTypeCode;	//STOR
		public String LocationTypeName;	//Store
		public String LocationStatusCode;	//ACTV
		public String LocationStatusName;	//Active
		public String LocationAddressLine1;	//1291   FOLLY ROAD
		public String LocationAddressLine2;
		public String LocationCityName;	//JAMES ISLAND
		public String LocationStateProvinceAbbreviation;	//SC
		public String LocationCountryName;
		public String LocationCountryCode;	//US
		public String LocationCountryAbbreviation;	//USA
		public String LocationPostalCode;	//29412
		public String LocationExtendedCode;
		public String CompanyCode;	//DLL
		public String CompanyName;	//Dollar Tree
		public String WebsiteURI;
		public String CompanyStatusCode;	//ACTV
		public String CompanyStatusName;	//Active
		public String CompanyTypeCode;	//CLNT
		public String CompanyTypeName;	//Client
		public String AddressCommunicationChannelTypeCode;	//MADR
		public String AddressCommunicationRecipientTypeCode;	//COMP
		public String AddressCommunicationChannelFunctionTypeCode;	//MAIN
		public String AddressCommunicationChannelDescription;
		public String AddressLine1;	//500 VOLVO PKWY
		public String AddressLine2;
		public Double Latitude;	//36.767011
		public Double Longitude;	//-76.243239
		public String CityName;	//CHESAPEAKE
		public String CityAbbreviation;
		public String StateProvinceCode;	//VA
		public String StateProvinceName;	//Virginia
		public String StateProvinceAbbreviation;	//VA
		public String CountyCode;	//51550
		public String CountyName;	//Chesapeake City
		public String CountyAbbreviation;	//51550
		public String CountryName;	//UNITED STATES
		public String CountryCode;	//US
		public String CountryAbbreviation;	//USA
		public String PostalCode;	//23320
		public String PaymentTermName;	//Net 60
		public String PhoneCommunicationChannelTypeCode;	//PHON
		public String PhoneCommunicationRecipientTypeCode;	//COMP
		public String PhoneCommunicationChannelFunctionTypeCode;	//MAIN
		public String CompanyBrandCode;	//Dollar Tree
		public String CompanyBrandName;	//Dollar Tree
		public String ContractorLocationCode;
		public String ContractorInternalLocationCode;
		public String PsiReadingTypeCode;
		public String PsiReadingTypeName;
		public String TenantStoreTypeName;
		public String TenantStoreTypeCode;
		public String TenantOccupancyTypeName;
		public String TenantOccupancyTypeCode;
		public String RegionalManagerName;
		public String ProjectManagerName;
		public String ParentLocationCode;
		public Integer isLocalService;	//0
		public Integer isAcceptLocalBilling;	//0
		public String LocalBillingAddressLine1;
		public String LocalBillingAddressLine2;
		public String LocalBillingCityName;
		public String LocalBillingStateProvinceAbbreviation;
		public String LocalBillingCountyName;
		public String LocalBillingCountryCode;
		public String LocalBillingCountryAbbreviation;
		public String LocalBillingPostalCode;
		public String LocalBillingExtendedCode;
	}
	
	public static ElasticResponseWrapper parse(String json){
		return (ElasticResponseWrapper) System.JSON.deserialize(json, ElasticResponseWrapper.class);
	}
    
    public static String MOCK_ELASTIC_SEARCH_RESPONSE =		'{'+
		'    "took": 4,'+
		'    "timedout": false,'+
		'    "shards": {'+
		'        "total": 5,'+
		'        "successful": 5,'+
		'        "skipped": 0,'+
		'        "failed": 0'+
		'    },'+
		'    "hits": {'+
		'        "total": {'+
		'            "value": 1,'+
		'            "relation": "eq"'+
		'        },'+
		'        "maxscore": 20.134901,'+
		'        "hits": ['+
		'            {'+
		'                "index": "sbslocations",'+
		'                "type": "_doc",'+
		'                "id": "351139",'+
		'                "score": 20.134901,'+
		'                "source": {'+
		'                    "LocationId": 207525,'+
		'                    "LocationCode": "HMD006587",'+
		'                    "CompanyLocationCode": "HMD",'+
		'                    "LocationName": "Home Depot - 6587   Store",'+
		'                    "LocationDescription": null,'+
		'                    "PreviousLocationId": null,'+
		'                    "ClientGLAccount": null,'+
		'                    "SquareFootage": 0,'+
		'                    "Rank": null,'+
		'                    "LocationTypeCode": "STOR",'+
		'                    "LocationTypeName": "Store",'+
		'                    "LocationStatusCode": "ACTV",'+
		'                    "LocationStatusName": "Active",'+
		'                    "LocationAddressLine1": "6708 NE Zac Lentz Pkwy",'+
		'                    "LocationAddressLine2": null,'+
		'                    "LocationCityName": "VICTORIA",'+
		'                    "LocationStateProvinceAbbreviation": "TX",'+
		'                    "LocationCountryName": null,'+
		'                    "LocationCountryCode": "US",'+
		'                    "LocationCountryAbbreviation": "USA",'+
		'                    "LocationPostalCode": "77904",'+
		'                    "LocationExtendedCode": null,'+
		'                    "CompanyCode": "HMD",'+
		'                    "CompanyName": "The Home Depot",'+
		'                    "WebsiteURI": "http://www.homedepot.com/",'+
		'                    "CompanyStatusCode": "ACTV",'+
		'                    "CompanyStatusName": "Active",'+
		'                    "CompanyTypeCode": "CLNT",'+
		'                    "CompanyTypeName": "Client",'+
		'                    "AddressCommunicationChannelTypeCode": "MADR",'+
		'                    "AddressCommunicationRecipientTypeCode": "COMP",'+
		'                    "AddressCommunicationChannelFunctionTypeCode": "MAIN",'+
		'                    "AddressCommunicationChannelDescription": null,'+
		'                    "AddressLine1": "500 VOLVO PKWY",'+
		'                    "AddressLine2": null,'+
		'                    "Latitude": 36.767011,'+
		'                    "Longitude": -76.243239,'+
		'                    "CityName": "CHESAPEAKE",'+
		'                    "CityAbbreviation": null,'+
		'                    "StateProvinceCode": "VA",'+
		'                    "StateProvinceName": "Virginia",'+
		'                    "StateProvinceAbbreviation": "VA",'+
		'                    "CountyCode": "51550",'+
		'                    "CountyName": "Chesapeake City",'+
		'                    "CountyAbbreviation": "51550",'+
		'                    "CountryName": "UNITED STATES",'+
		'                    "CountryCode": "US",'+
		'                    "CountryAbbreviation": "USA",'+
		'                    "PostalCode": "23320",'+
		'                    "PaymentTermName": "Net 60",'+
		'                    "PhoneCommunicationChannelTypeCode": "PHON",'+
		'                    "PhoneCommunicationRecipientTypeCode": "COMP",'+
		'                    "PhoneCommunicationChannelFunctionTypeCode": "MAIN",'+
		'                    "CompanyBrandCode": "Dollar Tree",'+
		'                    "CompanyBrandName": "Dollar Tree",'+
		'                    "ContractorLocationCode": null,'+
		'                    "ContractorInternalLocationCode": null,'+
		'                    "PsiReadingTypeCode": null,'+
		'                    "PsiReadingTypeName": null,'+
		'                    "TenantStoreTypeName": null,'+
		'                    "TenantStoreTypeCode": null,'+
		'                    "TenantOccupancyTypeName": null,'+
		'                    "TenantOccupancyTypeCode": null,'+
		'                    "RegionalManagerName": null,'+
		'                    "ProjectManagerName": null,'+
		'                    "ParentLocationCode": null,'+
		'                    "isLocalService": 0,'+
		'                    "isAcceptLocalBilling": 0,'+
		'                    "LocalBillingAddressLine1": null,'+
		'                    "LocalBillingAddressLine2": null,'+
		'                    "LocalBillingCityName": null,'+
		'                    "LocalBillingStateProvinceAbbreviation": null,'+
		'                    "LocalBillingCountyName": null,'+
		'                    "LocalBillingCountryCode": null,'+
		'                    "LocalBillingCountryAbbreviation": null,'+
		'                    "LocalBillingPostalCode": null,'+
		'                    "LocalBillingExtendedCode": null,'+
		'                    "VendorAccountNumber": ['+
		'                        "06928000730",'+
		'                        "06928000731",'+
		'                        "1464250",'+
		'                        "3-0692-8000731",'+
		'                        "3007797PL",'+
		'                        "3290004PL",'+
		'                        "3932056PL",'+
		'                        "6928000730",'+
		'                        "6928000731"'+
		'                    ],'+
		'                    "VendorNames": ['+
		'                        "Republic -Fennel, Suburban, Charleston 692",'+
		'                        "Republic -Fennel, Suburban, Charleston 692",'+
		'                        "1-800-GOT-JUNK - United States",'+
		'                        "Becker Iron & Metal",'+
		'                        "Becker Iron & Metal",'+
		'                        "WM Fee",'+
		'                        "Junk King Franchise Systems",'+
		'                        "Junk King Franchise Systems",'+
		'                        "CheckSammy Inc.",'+
		'                        "CheckSammy Inc."'+
		'                    ],'+
		'                    "VendorAddresses": ['+
		'                        "141 Fennell Rd.  NORTH CHARLESTON South Carolina 29418",'+
		'                        "18500 N Allied Way  PHOENIX Arizona 85054",'+
		'                        "615 S Dupont Hwy  DOVER Delaware 19901",'+
		'                        "1310 Broadway  VENICE Illinois 62090",'+
		'                        "1310 Broadway  VENICE Illinois 62090",'+
		'                        "415 Day Hill Rd  WINDSOR Connecticut 06095",'+
		'                        "389 OYSTER POINT BLVD STE 6  SOUTH SAN FRANCISCO California 94080",'+
		'                        "389 OYSTER POINT BLVD STE 6  SOUTH SAN FRANCISCO California 94080",'+
		'                        "6965 SPEEDWAY BLVD STE X105  LAS VEGAS Nevada 89115",'+
		'                        "6935 ALIANTE PKWY STE 104-499  NORTH LAS VEGAS Nevada 89084"'+
		'                    ]'+
		'                }'+
		'            }'+
		'        ]'+
		'    }'+
		'}';
        
}