//Class: PricingResponseProcessorTest
//Purpose: Test class for the PricingResponseProcessor
//Author: Sheikh Sarfaraz
//Date: 04-April-2025

@isTest(seeAllData = false)
public class PricingResponseProcessorTest 
{
    private static final string TRASH = 'Trash';
    private static final string ON_CALL = 'On-Call';
    private static final string ROLLOFF = 'Rolloff';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SERVICES = 'Services';
    private static final string EQUIPMENT = 'Equipment';
    private static final String sAssertionErrorMessage = 'Error in assertion';
    private static Set<String> productCodes = new Set<String>{'FF', 'LF', 'ENV_FEE', 'ENS', 'IF', 'RECV', 'CSC'};
    
    //Pricing Request data
    //private static final String JSON_VALID_ROLLOFF_DATA = '{"data":{"priceQuoteIdentifier":"Q12631","costSource":"WM (SBS|RO|OT|30O|B02433|20220328|045807|9598)","priceSource":"Standard Pricing","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"12603|214136|2620","supplierName":"WMI - A FIORE & SON OF NEWARK|WMI OF NJ, ELIZABETH|WM - NJ-NORTH - 2433","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD005826","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"30O","equipmentName":"30 Yard Open Top","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-40","equipmentSizeName":"40 Yards","overridableEquipmentSizeCode":"YRDS-30","overridableEquipmentSizeName":"30 Yards","zoneCode":"GIS512254","zoneName":"UCROMSW","disposalFacilityType":"S07379_LF","disposalFacilityName":"B02433|S07379_LF|S02938_TS|132A_FMW|MSW_RO","feeComment": null,"isCostOnly": false,"commercial":null,"rollOff":{"pricingMethodDisposalCode":"1.0","pricingMethodDisposalDescription":"Market Based Pricing","pricingMethodHaulingCode":"2.0","pricingMethodHaulingDescription":"Cost Plus","originalHaulCost":null,"haulCost":285,"haulPrice":null,"originalDisposalCost":null,"disposalCost":102.57,"disposalPrice":null,"estimatedVolumePerHaul":3,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":15.52,"landfillMinutes":23,"transferSiteCode":"S02938_TS","equipmentAvailabilityTypeCode":"TEMP","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":15,"equipmentAdditionalLoadingMinutes":null,"haulRecordId":null,"disposalRecordId":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B02433","masLibrary":"132A_FMW","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Greater Mid Atlantic"},"tpMetaData":null,"serviceCharges":[{"code":"FU_RO_TEMP_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"ENV_RO_TEMP_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"MNT_RO_TEMP_OPEN_R","name":"Minimum Tons Recycling","componentTypeCode":"DSP","componentTypeName":"Disposal","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"MNT_RO_TEMP_OPEN_T","name":"All Other Minimum Tonnage","componentTypeCode":"DSP","componentTypeName":"Disposal","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"LF_RO_TEMP_OPEN","name":"Landfill Fee","componentTypeCode":"LF","componentTypeName":"Landfill Fee","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"FF_RO_TEMP_OPEN","name":"Franchise Fee","componentTypeCode":"FF","componentTypeName":"Franchise Fee","actionCode":"AL","actionName":"Allow","cost":10,"costValueType":"Amount","costUOM":"Monthly","price":10,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"D_RO_TEMP_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null}]},"problem":null}';
    //TCS-pkulkarn-SDT-47682-19-May-2025-Changed equipmentCode and equipmentName (following 3 lines) for fixing test class errors
    private static final String JSON_VALID_ROLLOFF_DATA = '{"data":{"priceQuoteIdentifier":"Q12631","costSource":"WM (SBS|RO|OT|30O|B02433|20220328|045807|9598)","priceSource":"Standard Pricing","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"12603|214136|2620","supplierName":"WMI - A FIORE & SON OF NEWARK|WMI OF NJ, ELIZABETH|WM - NJ-NORTH - 2433","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD005826","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"OT","equipmentName":"Open Top","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-40","equipmentSizeName":"40 Yards","overridableEquipmentSizeCode":"YRDS-30","overridableEquipmentSizeName":"30 Yards","zoneCode":"GIS512254","zoneName":"UCROMSW","disposalFacilityType":"S07379_LF","disposalFacilityName":"B02433|S07379_LF|S02938_TS|132A_FMW|MSW_RO","feeComment": null,"isCostOnly": false,"commercial":null,"rollOff":{"pricingMethodDisposalCode":"1.0","pricingMethodDisposalDescription":"Market Based Pricing","pricingMethodHaulingCode":"2.0","pricingMethodHaulingDescription":"Cost Plus","originalHaulCost":null,"haulCost":285,"haulPrice":null,"originalDisposalCost":null,"disposalCost":102.57,"disposalPrice":null,"estimatedVolumePerHaul":3,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":15.52,"landfillMinutes":23,"transferSiteCode":"S02938_TS","equipmentAvailabilityTypeCode":"TEMP","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":15,"equipmentAdditionalLoadingMinutes":null,"haulRecordId":null,"disposalRecordId":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B02433","masLibrary":"132A_FMW","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Greater Mid Atlantic"},"tpMetaData":null,"serviceCharges":[{"code":"FU_RO_TEMP_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"ENV_RO_TEMP_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"MNT_RO_TEMP_OPEN_R","name":"Minimum Tons Recycling","componentTypeCode":"DSP","componentTypeName":"Disposal","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"MNT_RO_TEMP_OPEN_T","name":"All Other Minimum Tonnage","componentTypeCode":"DSP","componentTypeName":"Disposal","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"LF_RO_TEMP_OPEN","name":"Landfill Fee","componentTypeCode":"LF","componentTypeName":"Landfill Fee","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code": "IF_RO_PERM_OPEN","name": "Inactivity Fee (Monthly or Daily Charge for roll off when no Hauls are performed)","componentTypeCode": "IF","componentTypeName": "Inactivity Fee","actionCode": "ADJ","actionName": "Adjust","cost": 10.0000,"costValueType": "Amount","costUOM": null,"price": 10.0000,"priceValueType": "Amount","priceUOM": null,"serviceChargeRecordId": null},{"code": "CSC_RO_PERM_OPEN","name": "Container Service Charge (Rental for Roll Off Accounts)","componentTypeCode": "UNK","componentTypeName": "Unknown","actionCode": "ADJ","actionName": "Adjust","cost": 10.0000,"costValueType": "Amount","costUOM": null,"price": 10.0000,"priceValueType": "Amount","priceUOM": null,"serviceChargeRecordId": null},{"code": "RMO_RO_PERM_OPEN","name": "Recyable Material Offset","componentTypeCode": "UNK","componentTypeName": "Unknown","actionCode": "ADJ","actionName": "Adjust","cost": 33.0000,"costValueType": "Amount","costUOM": null,"price": 33.0000,"priceValueType": "Amount","priceUOM": null,"serviceChargeRecordId": null},{"code": "ENV_RO_PERM_OPEN","name": "Environmental Fee","componentTypeCode": "ENV_FEE","componentTypeName": "Environmental Fee","actionCode": "ADJ","actionName": "Adjust","cost": 45.0000,"costValueType": "Amount","costUOM": null,"price": 45.0000,"priceValueType": "Amount","priceUOM": null,"serviceChargeRecordId": null},{"code":"FF_RO_TEMP_OPEN","name":"Franchise Fee","componentTypeCode":"FF","componentTypeName":"Franchise Fee","actionCode":"EX","actionName":"Exclude","cost":10,"costValueType":"Amount","costUOM":"Monthly","price":10,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"D_RO_TEMP_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null}]},"problem":null}';
    private static final String JSON_VALID_ROLLOFF_DATA_CMP = '{"data":{"priceQuoteIdentifier":"Q12631","costSource":"WM (SBS|RO|OT|30O|B02433|20220328|045807|9598)","priceSource":"Standard Pricing","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"12603|214136|2620","supplierName":"WMI - A FIORE & SON OF NEWARK|WMI OF NJ, ELIZABETH|WM - NJ-NORTH - 2433","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD005826","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"CMP","equipmentName":"Compactor","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-40","equipmentSizeName":"40 Yards","overridableEquipmentSizeCode":"YRDS-30","overridableEquipmentSizeName":"30 Yards","zoneCode":"GIS512254","zoneName":"UCROMSW","disposalFacilityType":"S07379_LF","disposalFacilityName":"B02433|S07379_LF|S02938_TS|132A_FMW|MSW_RO","feeComment": null,"isCostOnly": false,"commercial":null,"rollOff":{"pricingMethodDisposalCode":"1.0","pricingMethodDisposalDescription":"Market Based Pricing","pricingMethodHaulingCode":"2.0","pricingMethodHaulingDescription":"Cost Plus","originalHaulCost":null,"haulCost":285,"haulPrice":null,"originalDisposalCost":null,"disposalCost":102.57,"disposalPrice":null,"estimatedVolumePerHaul":3,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":15.52,"landfillMinutes":23,"transferSiteCode":"S02938_TS","equipmentAvailabilityTypeCode":"TEMP","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":15,"equipmentAdditionalLoadingMinutes":null,"haulRecordId":null,"disposalRecordId":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B02433","masLibrary":"132A_FMW","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Greater Mid Atlantic"},"tpMetaData":null,"serviceCharges":[{"code":"FU_RO_TEMP_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"ENV_RO_TEMP_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"MNT_RO_TEMP_OPEN_R","name":"Minimum Tons Recycling","componentTypeCode":"DSP","componentTypeName":"Disposal","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"MNT_RO_TEMP_OPEN_T","name":"All Other Minimum Tonnage","componentTypeCode":"DSP","componentTypeName":"Disposal","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"LF_RO_TEMP_OPEN","name":"Landfill Fee","componentTypeCode":"LF","componentTypeName":"Landfill Fee","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code": "IF_RO_PERM_OPEN","name": "Inactivity Fee (Monthly or Daily Charge for roll off when no Hauls are performed)","componentTypeCode": "IF","componentTypeName": "Inactivity Fee","actionCode": "ADJ","actionName": "Adjust","cost": 10.0000,"costValueType": "Amount","costUOM": null,"price": 10.0000,"priceValueType": "Amount","priceUOM": null,"serviceChargeRecordId": null},{"code": "CSC_RO_PERM_OPEN","name": "Container Service Charge (Rental for Roll Off Accounts)","componentTypeCode": "UNK","componentTypeName": "Unknown","actionCode": "ADJ","actionName": "Adjust","cost": 10.0000,"costValueType": "Amount","costUOM": null,"price": 10.0000,"priceValueType": "Amount","priceUOM": null,"serviceChargeRecordId": null},{"code": "RMO_RO_PERM_OPEN","name": "Recyable Material Offset","componentTypeCode": "UNK","componentTypeName": "Unknown","actionCode": "ADJ","actionName": "Adjust","cost": 33.0000,"costValueType": "Amount","costUOM": null,"price": 33.0000,"priceValueType": "Amount","priceUOM": null,"serviceChargeRecordId": null},{"code": "ENV_RO_PERM_OPEN","name": "Environmental Fee","componentTypeCode": "ENV_FEE","componentTypeName": "Environmental Fee","actionCode": "ADJ","actionName": "Adjust","cost": 45.0000,"costValueType": "Amount","costUOM": null,"price": 45.0000,"priceValueType": "Amount","priceUOM": null,"serviceChargeRecordId": null},{"code":"FF_RO_TEMP_OPEN","name":"Franchise Fee","componentTypeCode":"FF","componentTypeName":"Franchise Fee","actionCode":"EX","actionName":"Exclude","cost":10,"costValueType":"Amount","costUOM":"Monthly","price":10,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"D_RO_TEMP_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null}]},"problem":null}';
    private static final String JSON_VALID_ROLLOFF_DATA_PriceOnly = '{"data":{"priceQuoteIdentifier":"Q12631","costSource":"WM (SBS|RO|OT|30O|B02433|20220328|045807|9598)","priceSource":"Standard Pricing","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"12603|214136|2620","supplierName":"WMI - A FIORE & SON OF NEWARK|WMI OF NJ, ELIZABETH|WM - NJ-NORTH - 2433","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD005826","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"OT","equipmentName":"Open Top","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-40","equipmentSizeName":"40 Yards","overridableEquipmentSizeCode":"YRDS-30","overridableEquipmentSizeName":"30 Yards","zoneCode":"GIS512254","zoneName":"UCROMSW","disposalFacilityType":"S07379_LF","disposalFacilityName":"B02433|S07379_LF|S02938_TS|132A_FMW|MSW_RO","feeComment": null,"isCostOnly": false,"commercial":null,"rollOff":{"pricingMethodDisposalCode":"1.0","pricingMethodDisposalDescription":"Market Based Pricing","pricingMethodHaulingCode":"2.0","pricingMethodHaulingDescription":"Cost Plus","originalHaulCost":null,"haulCost":285,"haulPrice":null,"originalDisposalCost":null,"disposalCost":102.57,"disposalPrice":null,"estimatedVolumePerHaul":3,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":15.52,"landfillMinutes":23,"transferSiteCode":"S02938_TS","equipmentAvailabilityTypeCode":"TEMP","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":15,"equipmentAdditionalLoadingMinutes":null,"haulRecordId":null,"disposalRecordId":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B02433","masLibrary":"132A_FMW","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Greater Mid Atlantic"},"tpMetaData":null,"serviceCharges":[{"code":"FU_RO_TEMP_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"ENV_RO_TEMP_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"MNT_RO_TEMP_OPEN_R","name":"Minimum Tons Recycling","componentTypeCode":"DSP","componentTypeName":"Disposal","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"MNT_RO_TEMP_OPEN_T","name":"All Other Minimum Tonnage","componentTypeCode":"DSP","componentTypeName":"Disposal","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"LF_RO_TEMP_OPEN","name":"Landfill Fee","componentTypeCode":"LF","componentTypeName":"Landfill Fee","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code": "IF_RO_PERM_OPEN","name": "Inactivity Fee (Monthly or Daily Charge for roll off when no Hauls are performed)","componentTypeCode": "IF","componentTypeName": "Inactivity Fee","actionCode": "ADJ","actionName": "Adjust","cost": 10.0000,"costValueType": "Amount","costUOM": null,"price": 10.0000,"priceValueType": "Amount","priceUOM": null,"serviceChargeRecordId": null},{"code": "CSC_RO_PERM_OPEN","name": "Container Service Charge (Rental for Roll Off Accounts)","componentTypeCode": "UNK","componentTypeName": "Unknown","actionCode": "ADJ","actionName": "Adjust","cost": 10.0000,"costValueType": "Amount","costUOM": null,"price": 10.0000,"priceValueType": "Amount","priceUOM": null,"serviceChargeRecordId": null},{"code": "RMO_RO_PERM_OPEN","name": "Recyable Material Offset","componentTypeCode": "UNK","componentTypeName": "Unknown","actionCode": "ADJ","actionName": "Adjust","cost": 33.0000,"costValueType": "Amount","costUOM": null,"price": 33.0000,"priceValueType": "Amount","priceUOM": null,"serviceChargeRecordId": null},{"code": "ENV_RO_PERM_OPEN","name": "Environmental Fee","componentTypeCode": "ENV_FEE","componentTypeName": "Environmental Fee","actionCode": "EX","actionName": "Exclude","cost": 45.0000,"costValueType": "Amount","costUOM": null,"price": 45.0000,"priceValueType": "Amount","priceUOM": null,"serviceChargeRecordId": null},{"code":"FF_RO_TEMP_OPEN","name":"Franchise Fee","componentTypeCode":"FF","componentTypeName":"Franchise Fee","actionCode":"AL","actionName":"Allow","cost":10,"costValueType":"Amount","costUOM":"Monthly","price":10,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"D_RO_TEMP_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null}]},"problem":null}';
    private static final String JSON_VALID_COMMERCIAL_DATA = '{"data":{"priceQuoteIdentifier":"Q11839","costSource":"WM (SBS|CO|DMP|4FY|B02433|20211019|030423|5192)","contractType":"Open Market","lineOfBusiness":"Commercial","supplierCode":"12603|214136|2620","supplierName":"WMI - A FIORE & SON OF NEWARK|WMI OF NJ, ELIZABETH|WM - NJ-NORTH - 2433","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD005826","wasteStreamCode":"REC","wasteStreamName":"Recycling","equipmentCode":"4FY","equipmentName":"4 Yard FEL Recycling","equipmentUOM":"Monthly","materialCode":"C","materialName":"Cardboard - OCC","equipmentSizeCode":"YRDS-4","equipmentSizeName":"4 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS513947","zoneName":"UCFLRY","disposalFacilityType":"S02938_MRF","disposalFacilityName":"[B02433] [Recycle_SSRY_CO] Julia Street Recycling","feeComment": null,"isCostOnly": false,"commercial":{"pricingMethodCode":"2.0","pricingMethodCodeDescription":"Cost Plus","cost":32.28,"price":37.12,"equipmentLoadingMinutes":null,"equipmentAdditionalLoadingMinutes":null,"estimatedWeightPerYard":30,"equipmentVolume":4,"extraPickupCost":null,"extraPickupPrice":null},"rollOff":null,"wmMetaData":{"businessUnit":"B02433","masLibrary":"152A_ELC","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Greater Mid Atlantic"},"tpMetaData":null,"serviceCharges":[{"code":"FU_C_PERM_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"ENV_C_PERM_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"RCR_C_PERM_OPEN","name":"Regulatory Cost Recovery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"CSC_C_PERM_OPEN","name":"Container Service Charge","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"MR","actionName":"Manual Review","cost":null,"costValueType":null,"costUOM":null,"price":null,"priceValueType":null,"priceUOM":null},{"code":"D_C_PERM_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":100,"costValueType":"Amount","costUOM":null,"price":115,"priceValueType":"Amount","priceUOM":null}]},"problem":null}';
    private static final String JSON_VALID_MV_ROLLOFF_DATA = '{"data":{"priceQuoteIdentifier":"Q210551","lineOfBusiness":"Roll Off","priceTypeCode":"New","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD000444","serviceBaselineId":null,"equipmentCode":"OT","equipmentName":"Open Top","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","materialCode":"T","materialName":"Trash","countryCode":"USA","currencyCode":"USD","equipmentAvailabilityCode":"TEMP","sourceSystem":"SFDC","isCostOnly":false,"suppliers":[{"costSource":"WM (93116a5e-9d9e-4f1d-bb74-bc382f55cd0a)","priceSource":"Exhibit Pricing","supplierCode":"201226|2199|9022","supplierName":"WMI OF CA, OCEANSIDE|WM OF SAN DIEGO ORANGE COUNTY AREA OFFICE|WMI OF CA, EL CAJON","contractType":"Open Market","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentUOM":"Load","zoneCode":"GIS541218","zoneName":"O=332,C=134(T)-SD, City of","zoneDescription":"O=332,C=134(T)-SD, City of","zoneNotes":null,"disposalFacilityType":"S02969_Disposal","disposalFacilityName":"S02969_Disposal_El Sobrante Landfill_CA0132_CA0132_El Sobrante Landfill","commercial":null,"rollOff":{"pricingMethodDisposalDescription":"Cost Plus","pricingMethodHaulingDescription":"Cost Plus","haulCost":239.95,"haulPrice":686.82,"disposalCost":114.28,"disposalPrice":null,"estimatedVolumePerHaul":3,"haulRecordId":68702,"disposalRecordId":68709,"originalHaulCost":239.95,"originalDisposalCost":114.28,"stepDisposals":[{"costUpTo":null,"costRange":null,"priceUpTo":"2.50","priceRange":"0 UpTo 2.50","cost":null,"price":0},{"costUpTo":null,"costRange":null,"priceUpTo":"99.00","priceRange":"2.50 UpTo 99.00","cost":null,"price":85.63}]},"serviceCharges":[{"code":"FU_RO_TEMP_OPEN","name":"Fuel Fee","componentCode":"ENS","componentName":"Energy Surcharge","actionCode":"ADJ","actionName":"Adjust","cost":60,"costValueType":"Amount","costUOM":"Monthly","price":70,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"ENV_RO_TEMP_OPEN","name":"Environmental Fee","componentCode":"ENV_FEE","componentName":"Environmental Fee","actionCode":"ADJ","actionName":"Adjust","cost":50,"costValueType":"Amount","costUOM":"Monthly","price":50,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"FF_RO_TEMP_OPEN","name":"Franchise Fee","componentCode":"FF","componentName":"Franchise Fee","actionCode":"ADJ","actionName":"Adjust","cost":60,"costValueType":"Amount","costUOM":"Monthly","price":60,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"IF_RO_PERM_OPEN","name":"Inactivity Fee","componentCode":"IF","componentName":"Inactivity Fee","actionCode":"EX","actionName":"Exclude","cost":60,"costValueType":"Amount","costUOM":"Monthly","price":60,"priceValueType":"Amount","priceUOM":"Monthly"}],"wmMetaData":{"equipmentCode":"30O","equipmentName":"30 Yard Open Top","masCompany":null,"masLibrary":"ARDTA.175A","maslob":"O","francisePricingLink":"Do Not Change/T/44/55/40/50/36/45/18/P/45/55/35/45/25/35/18/","greenPagesLink":null,"marketAreaCode":"K00175","marketAreaName":"WM of Southern California","facilityId":"CA0140","facilityName":"San Diego Hauling","siteId":"S04971","siteName":"San Diego Hauling","masCustomerUniqueId":null,"requestTrackingId":"PR250723281033","targetTrackingId":"93116a5e-9d9e-4f1d-bb74-bc382f55cd0a"},"tpMetaData":null,"messages":null}]},"problem":null}';
    
    @testSetup 
    // method for setting up data
    static void createData() {
        User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        
        insert usr;
        
        System.runAs(usr){
            
            list<Account> acclist = new List<Account>();
            List<Opportunity> oppList = new List<Opportunity>();
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            List<Product2> prodList= new List<Product2>();
            
            Account accParentRetail = new Account(Name = 'Parent Account Retail', phone = '1234567890', OwnerId = usr.id, AccountNumber='1234',
                                                  RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, Primary_Segment__c = 'Retail'); 
            insert accParentRetail;
            
            Account accParentBroker = new Account(Name = 'Parent Account Broker', phone = '2345678901', OwnerId = usr.id, AccountNumber='5678',
                                                  RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, Primary_Segment__c = 'Broker'); 
            insert accParentBroker;

            Account accParentRetailMV = new Account(Name = 'Parent Account Retail MV', phone = '1234567890', OwnerId = usr.id, AccountNumber='1234',
                                                  RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, Primary_Segment__c = 'Retail'); 
            insert accParentRetailMV;
            
            Account accParentRetailMVAMPO = new Account(Name = 'Parent Account Retail MV AMPO', phone = '1234567890', OwnerId = usr.id, AccountNumber='1234',
                                                  RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, Primary_Segment__c = 'Retail'); 
            insert accParentRetailMVAMPO;

            Account accRetail = new Account(Name = 'Child Account Retail', phone = '3456789012', OwnerId = usr.id, AccountNumber='12345',
                                            RecordTypeid = TestDataFactory.getRecordType('Location','Account'), IsPricingEligible__c = true, ParentId = accParentRetail.Id, Type ='Location');
            acclist.add(accRetail);
            
            Account accBroker = new Account(Name = 'Child Account Broker', phone = '4567890123', OwnerId = usr.id, AccountNumber='67890',
                                            RecordTypeid = TestDataFactory.getRecordType('Location','Account'), IsPricingEligible__c = true, ParentId = accParentBroker.Id, Type ='Location');
            acclist.add(accBroker);

            Account accRetailMV = new Account(Name = 'Child Account Multi Vendor', phone = '4567890123', OwnerId = usr.id, AccountNumber='67890',
                                            RecordTypeid = TestDataFactory.getRecordType('Location','Account'), IsPricingEligible__c = true, ParentId = accParentRetailMV.Id, Type ='Location');
            acclist.add(accRetailMV);

            Account accRetailMVAMPO = new Account(Name = 'Child Account Multi Vendor AMPO', phone = '4567890123', OwnerId = usr.id, AccountNumber='67890',
                                            RecordTypeid = TestDataFactory.getRecordType('Location','Account'), IsPricingEligible__c = true, ParentId = accParentRetailMVAMPO.Id, Type ='Location');
            acclist.add(accRetailMVAMPO);
            
            Account vendorAcc = new Account(Name = 'WM Vendor Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='4321',
                                            RecordTypeid = TestDataFactory.getRecordType('Vendor','Account'));
            acclist.add(vendorAcc);
            
            Database.insert(acclist);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, accParentRetail.id);
            list<Account> locationlistBroker = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, accParentBroker.id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Chicago';
            locationlist[0].IsPricingEligible__c = true;
            locationlistBroker[0].tz__Timezone_SFDC__c = 'America/Chicago';
            locationlistBroker[0].IsPricingEligible__c = true;
            Database.insert(locationlist);
            Database.insert(locationlistBroker);
            
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, accParentRetail, usr);
            Database.insert(conlist);
            
            //Inserting Account Position (Location_Position) - Retail Account
            Account_Position__c accLocPosition = new Account_Position__c(AccountId__c = accRetail.Id,
                                                                         Container_Position__c = 'Test 2',
                                                                         AlternatePostalCode__c = '1234',
                                                                         AlternateCity__c = 'Test City',
                                                                         AlternateCountry__c = 'USA',
                                                                         AlternateState__c = 'NY',
                                                                         AlternateStreet__c = 'Day Hill Road');
            insert accLocPosition;
            
            //Inserting Account Position (Location_Position) - Retail Account
            Account_Position__c accLocPositionBroker = new Account_Position__c(AccountId__c = accBroker.Id,
                                                                               Container_Position__c = 'Test 2',
                                                                               AlternatePostalCode__c = '1234',
                                                                               AlternateCity__c = 'Test City',
                                                                               AlternateCountry__c = 'USA',
                                                                               AlternateState__c = 'NY',
                                                                               AlternateStreet__c = 'Day Hill Road');
            INSERT accLocPositionBroker;

            //Inserting Account Position (Location_Position) - Retail Account - Multi Vendor
            Account_Position__c accLocPositionMV = new Account_Position__c(AccountId__c = accRetailMV.Id,
                                                                               Container_Position__c = 'Test 21',
                                                                               AlternatePostalCode__c = '12345',
                                                                               AlternateCity__c = 'Test City MV',
                                                                               AlternateCountry__c = 'USA',
                                                                               AlternateState__c = 'NY',
                                                                               AlternateStreet__c = 'Day Hill Road');
            INSERT accLocPositionMV;

            //Inserting Account Position (Location_Position) - Retail Account - Multi Vendor AMPO
            Account_Position__c accLocPositionMVAMPO = new Account_Position__c(AccountId__c = accRetailMVAMPO.Id,
                                                                               Container_Position__c = 'Test 21',
                                                                               AlternatePostalCode__c = '12345',
                                                                               AlternateCity__c = 'Test City MV',
                                                                               AlternateCountry__c = 'USA',
                                                                               AlternateState__c = 'NY',
                                                                               AlternateStreet__c = 'Day Hill Road');
            INSERT accLocPositionMVAMPO;
            
            //Inserting Case
            Case newServiceCase = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, accParentRetail, conlist.get(0),usr, locationlist.get(0)); 
            newServiceCase.Service_Date__c = system.today() + 1;
            newServiceCase.SLA_Service_Date_Time__c = system.today() + 2;
            newServiceCase.Case_Type__c = 'New Service';
            newServiceCase.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'New Service Case'].Id;  
            newServiceCase.Case_Sub_Type__c = 'Permanent';
            newServiceCase.Case_Reason__c = 'Existing Location';
            newServiceCase.LOB__c = 'Rolloff';
            newServiceCase.Status = 'Open';
            newServiceCase.Service_Occurrence_Type_Code__c = ON_CALL;
            newServiceCase.Material_Type__c = TRASH;
            
            Database.insert(newServiceCase);
            
            //Inserting Case Broker
            Case newServiceCaseBroker = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, accParentBroker, conlist.get(0),usr, locationlist.get(0)); 
            newServiceCaseBroker.Service_Date__c = system.today() + 1;
            newServiceCaseBroker.SLA_Service_Date_Time__c = system.today() + 2;
            newServiceCaseBroker.Case_Type__c = 'New Service';
            newServiceCaseBroker.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'New Service Case'].Id;  
            newServiceCaseBroker.Case_Sub_Type__c = 'Permanent';
            newServiceCaseBroker.Case_Reason__c = 'Existing Location';
            newServiceCaseBroker.LOB__c = 'Rolloff';
            newServiceCaseBroker.Status = 'Open';
            newServiceCaseBroker.Service_Occurrence_Type_Code__c = ON_CALL;
            newServiceCaseBroker.Material_Type__c = TRASH;
            
            Database.insert(newServiceCaseBroker);
            
            //Inserting Case Compactor
            Case newServiceCaseCMP = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, accParentRetail, conlist.get(0),usr, locationlist.get(0)); 
            newServiceCaseCMP.Service_Date__c = system.today() + 1;
            newServiceCaseCMP.SLA_Service_Date_Time__c = system.today() + 2;
            newServiceCaseCMP.Case_Type__c = 'New Service';
            newServiceCaseCMP.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'New Service Case'].Id;  
            newServiceCaseCMP.Case_Sub_Type__c = 'Permanent';
            newServiceCaseCMP.Case_Reason__c = 'Existing Location';
            newServiceCaseCMP.LOB__c = 'Rolloff';
            newServiceCaseCMP.Status = 'Open';
            newServiceCaseCMP.Service_Occurrence_Type_Code__c = ON_CALL;
            newServiceCaseCMP.Material_Type__c = TRASH;
            
            Database.insert(newServiceCaseCMP);

            //Inserting Case for Multi Vendor
            Case newServiceCaseMV = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, accParentRetail, conlist.get(0),usr, locationlist.get(0)); 
            newServiceCaseMV.Service_Date__c = system.today() + 1;
            newServiceCaseMV.SLA_Service_Date_Time__c = system.today() + 2;
            newServiceCaseMV.Case_Type__c = 'New Service';
            newServiceCaseMV.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'New Service Case'].Id;  
            newServiceCaseMV.Case_Sub_Type__c = 'Permanent';
            newServiceCaseMV.Case_Reason__c = 'Existing Location';
            newServiceCaseMV.LOB__c = 'Rolloff';
            newServiceCaseMV.Status = 'Open';
            newServiceCaseMV.Service_Occurrence_Type_Code__c = ON_CALL;
            newServiceCaseMV.Material_Type__c = TRASH;
            
            Database.insert(newServiceCaseMV);

            //Inserting Case for Multi Vendor AMPO
            Case newServiceCaseMVAMPO = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, accParentRetail, conlist.get(0),usr, locationlist.get(0)); 
            newServiceCaseMVAMPO.Service_Date__c = system.today() + 1;
            newServiceCaseMVAMPO.SLA_Service_Date_Time__c = system.today() + 2;
            newServiceCaseMVAMPO.Case_Type__c = 'New Service';
            newServiceCaseMVAMPO.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'New Service Case'].Id;  
            newServiceCaseMVAMPO.Case_Sub_Type__c = 'Permanent';
            newServiceCaseMVAMPO.Case_Reason__c = 'Existing Location';
            newServiceCaseMVAMPO.LOB__c = 'Rolloff';
            newServiceCaseMVAMPO.Status = 'Open';
            newServiceCaseMVAMPO.Service_Occurrence_Type_Code__c = ON_CALL;
            newServiceCaseMVAMPO.Material_Type__c = TRASH;
            
            Database.insert(newServiceCaseMVAMPO);
            
            //Opportunity-Retail
            oppList.addAll(TestDataFactory.createOpportunity(1,'Test Opportunity Retail',newServiceCase.Id,newServiceCase.Case_Sub_Type__c, newServiceCase.Location__c));
            insert oppList;
            CodeSwitchTestData  CodeSwithData = new CodeSwitchTestData();
            quoteList.addAll(TestDataFactory.createQuoteRecords(oppList, accRetail, conlist[0], Date.today(), false, true));
            quoteList[0].SBQQ__ShippingStreet__c = 'ABC';
            quoteList[0].SBQQ__ShippingCity__c = 'Test1';
            quoteList[0].SBQQ__ShippingCountry__c = 'United States';
            quoteList[0].SBQQ__ShippingState__c = 'NY';
            quoteList[0].SBQQ__ShippingPostalCode__c = '1234';
            quoteList[0].Duration__c = 'Permanent';
            quoteList[0].SBQQ__Type__c = 'Quote';
            insert quoteList;
            SBQQ__Quote__c quoteWithRetailParentAccount = quoteList[0];
            
            //Opportunity-Broker
            oppList.clear();
            oppList.addAll(TestDataFactory.createOpportunity(1,'Test Opportunity Broker',newServiceCaseBroker.Id,newServiceCaseBroker.Case_Sub_Type__c, newServiceCaseBroker.Location__c));
            insert oppList;
            
            quoteList.clear();
            quoteList.addAll(TestDataFactory.createQuoteRecords(oppList, accBroker, conlist[0], Date.today(), false, true));
            quoteList[0].SBQQ__ShippingStreet__c = 'ABC';
            quoteList[0].SBQQ__ShippingCity__c = 'Test1';
            quoteList[0].SBQQ__ShippingCountry__c = 'United States';
            quoteList[0].SBQQ__ShippingState__c = 'NY';
            quoteList[0].SBQQ__ShippingPostalCode__c = '1234';
            quoteList[0].Duration__c = 'Permanent';
            quoteList[0].SBQQ__Type__c = 'Quote';
            insert quoteList;
			SBQQ__Quote__c quoteWithBrokerParentAccount = quoteList[0];
            
            //Opportunity-Retail-Compactor
            oppList.clear();
            oppList.addAll(TestDataFactory.createOpportunity(1,'Test Opportunity Retail CMP', newServiceCaseCMP.Id, newServiceCaseCMP.Case_Sub_Type__c, newServiceCaseCMP.Location__c));
            insert oppList;
            
            quoteList.clear();
            quoteList.addAll(TestDataFactory.createQuoteRecords(oppList, accRetail, conlist[0], Date.today(), false, true));
            quoteList[0].SBQQ__ShippingStreet__c = 'ABC';
            quoteList[0].SBQQ__ShippingCity__c = 'Test1';
            quoteList[0].SBQQ__ShippingCountry__c = 'United States';
            quoteList[0].SBQQ__ShippingState__c = 'NY';
            quoteList[0].SBQQ__ShippingPostalCode__c = '1234';
            quoteList[0].Duration__c = 'Permanent';
            quoteList[0].SBQQ__Type__c = 'Quote';
            insert quoteList;
            SBQQ__Quote__c quoteWithRetailParentAccountCMP = quoteList[0];

            //Opportunity-Multi Vendor
            oppList.clear();
            oppList.addAll(TestDataFactory.createOpportunity(1,'Test Opportunity Multi Vendor',newServiceCaseMV.Id,newServiceCaseMV.Case_Sub_Type__c, newServiceCaseMV.Location__c));
            insert oppList;
            
            quoteList.clear();
            quoteList.addAll(TestDataFactory.createQuoteRecords(oppList, accRetailMV, conlist[0], Date.today(), false, true));
            quoteList[0].SBQQ__ShippingStreet__c = 'ABC';
            quoteList[0].SBQQ__ShippingCity__c = 'Test1';
            quoteList[0].SBQQ__ShippingCountry__c = 'United States';
            quoteList[0].SBQQ__ShippingState__c = 'NY';
            quoteList[0].SBQQ__ShippingPostalCode__c = '1234';
            quoteList[0].Duration__c = 'Permanent';
            quoteList[0].SBQQ__Type__c = 'Quote';
            insert quoteList;
			SBQQ__Quote__c quoteWithMultiVendorResponse = quoteList[0];

            //Opportunity-Multi Vendor AMPO
            oppList.clear();
            oppList.addAll(TestDataFactory.createOpportunity(1,'Test Opportunity Multi Vendor AMPO',newServiceCaseMVAMPO.Id,newServiceCaseMVAMPO.Case_Sub_Type__c, newServiceCaseMVAMPO.Location__c));
            insert oppList;
            
            quoteList.clear();
            quoteList.addAll(TestDataFactory.createQuoteRecords(oppList, accRetailMVAMPO, conlist[0], Date.today(), false, true));
            quoteList[0].SBQQ__ShippingStreet__c = 'ABC';
            quoteList[0].SBQQ__ShippingCity__c = 'Test1';
            quoteList[0].SBQQ__ShippingCountry__c = 'United States';
            quoteList[0].SBQQ__ShippingState__c = 'NY';
            quoteList[0].SBQQ__ShippingPostalCode__c = '1234';
            quoteList[0].Duration__c = 'Permanent';
            quoteList[0].SBQQ__Type__c = 'Quote';
            insert quoteList;
			SBQQ__Quote__c quoteWithMultiVendorResponseAMPO = quoteList[0];
            
            //***********************
            Product2 prodOpenTop = TestDataFactory.createProduct('Open Top',ROLLOFF,'OT');
            prodOpenTop.Bypass_Acorn_Integration__c= false;
            prodOpenTop.Is_Pricing_Eligible__c = true;
            
            Product2 prodCompactor = TestDataFactory.createProduct('Compactor',ROLLOFF, 'CMP');
            prodCompactor.Bypass_Acorn_Integration__c= false;
            prodCompactor.Is_Pricing_Eligible__c = true;
            
            Product2 prodDelivery = TestDataFactory.createProduct('Delivery','Services','DLV');
            Product2 prodPickup = TestDataFactory.createProduct('Pickup','Services','PCK');
            Product2 prodRemoval =TestDataFactory.createProduct('Removal','Services','REM');
            Product2 prodTrashWC = TestDataFactory.createProduct('Trash','Waste Category','TW');
            Product2 prodTrashWS = TestDataFactory.createProduct('Trash','Waste Stream','T');
            Product2 prodHaul = TestDataFactory.createProduct('Haul','Rolloff', 'H');
            Product2 prodDisposal = TestDataFactory.createProduct('Disposal','Rolloff', 'DSP');
            
            Product2 prodContainerServiceCharge = TestDataFactory.createProduct('Container Service Charge','Services', 'CSC');
            Product2 prodEnergySurcharge = TestDataFactory.createProduct('Energy Surcharge','Surcharges and Fees', 'ENS');
            Product2 prodEnvFee = TestDataFactory.createProduct('Environmental Fee','Surcharges and Fees', 'ENV_FEE');
            Product2 prodFranchiseFee = TestDataFactory.createProduct('Franchise Fee','Surcharges and Fees', 'FF');
            Product2 prodInactivityFee = TestDataFactory.createProduct('Inactivity Fee','Surcharges and Fees', 'IF');
            Product2 prodLandfillFee = TestDataFactory.createProduct('Landfill Fee','Surcharges and Fees', 'LF');
            Product2 prodRecyclingMaterialFee = TestDataFactory.createProduct('Recycling Material Recovery Fee','RECV', 'RECV');
            
            Product2 prodDumpster = TestDataFactory.createProduct('Dumpster','Commercial', 'DMP');
            prodDumpster.Is_Pricing_Eligible__c = true;
            prodDumpster.Container_Size__c = '2 Yards';
            
            prodList.add(prodOpenTop);
            prodList.add(prodDelivery);
            prodList.add(prodPickup);
            prodList.add(prodRemoval);
            prodList.add(prodDumpster);
            prodList.add(prodTrashWC);
            prodList.add(prodTrashWS);
            prodList.add(prodCompactor);
            prodList.add(prodHaul);
            prodList.add(prodDisposal);
            prodList.add(prodContainerServiceCharge);
            prodList.add(prodEnergySurcharge);
            prodList.add(prodEnvFee);
            prodList.add(prodFranchiseFee);
            prodList.add(prodInactivityFee);
            prodList.add(prodLandfillFee);
            prodList.add(prodRecyclingMaterialFee);
            
            Database.insert(prodList);
            
            //Create Price book and price book entries
            createPriceBookAndBookEntries(prodList);
            
            //Create Code Switch
            Code_Switch__c specMappingCodeSwitch = TestDataFactory.codeSwitch('Spec_Mapping', false);
            Code_Switch__c isPricingMulltiVendorAMSwitchON = TestDataFactory.codeSwitch('Pricing MulltiVendor AM Switch', true);
            
            //Create Pricing Request - Standard - Reail Account
            List<Pricing_Request__c> createPRList = new List<Pricing_Request__c>();
            Pricing_Request__c pReq1 = TestDataFactory.createPricingRequestRecord(newServiceCase, accParentRetail, locationlist[0], ROLLOFF, 'AM', '', JSON_VALID_ROLLOFF_DATA, usr);
            pReq1.Service_City__c = 'Test OT AM';
            createPRList.add(pReq1);
            
            //Create Pricing Request - Standard - Broker Account
            Pricing_Request__c pReq2 = TestDataFactory.createPricingRequestRecord(newServiceCaseBroker, accParentBroker, locationlistBroker[0], ROLLOFF, 'AM', '', JSON_VALID_ROLLOFF_DATA, usr);
            pReq2.Service_City__c = 'Test OT AM Broker';
            createPRList.add(pReq2);
            
            //Create Pricing Request - Price Only
            Pricing_Request__c pReq3 = TestDataFactory.createPricingRequestRecord(newServiceCase, accParentRetail, locationlist[0], ROLLOFF, 'AMPO', '', JSON_VALID_ROLLOFF_DATA_PriceOnly, usr);
            pReq3.Service_City__c = 'Test OT AMPO';
            createPRList.add(pReq3);
            
            //Create Pricing Request - Standard - Retail Account -Compactor
            Pricing_Request__c pReq4 = TestDataFactory.createPricingRequestRecord(newServiceCaseCMP, accParentRetail, locationlist[0], ROLLOFF, 'AM', '', JSON_VALID_ROLLOFF_DATA_CMP, usr);
            pReq4.Service_City__c = 'Test OT AM CMP';
            createPRList.add(pReq4);

            Pricing_Request__c pReq5 = TestDataFactory.createPricingRequestRecord(newServiceCaseMV, accParentRetail, locationlist[0], ROLLOFF, 'AM', '', JSON_VALID_MV_ROLLOFF_DATA, usr);
            pReq5.Service_City__c = 'Test MV OT AM';
            pReq5.Is_Multi_Vendor__c = true;
            createPRList.add(pReq5);

            Pricing_Request__c pReq6 = TestDataFactory.createPricingRequestRecord(newServiceCaseMVAMPO, accParentRetail, locationlist[0], ROLLOFF, 'AMPO', '', JSON_VALID_ROLLOFF_DATA_PriceOnly, usr);
            pReq6.Service_City__c = 'Test MV OT AMPO';
            pReq6.Is_Multi_Vendor__c = true;
            createPRList.add(pReq6);
            
            RecurrsiveTriggerHandler.invokeValidationforPricing = false;
            Database.insert(createPRList);
            
            //***********************
			RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = true;
            List<SBQQ__QuoteLine__c> qlHdr = new List<SBQQ__QuoteLine__c>();
            //Bundle 1 - Open Top - Retail Account
            SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(quoteWithRetailParentAccount, prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOT.SBQQ__Bundle__c = TRUE;
            qlOT.SBQQ__RequiredBy__c = null;
            qlOT.Vendor__c = vendorAcc.Id;
            qlOT.SBQQ__Number__c = 1;
            qlOT.Location_Position_Name__c = accLocPosition.Id;
            qlOT.Pricing_Request__c = createPRList[0].Id;
            qlHdr.add(qlOT);
            
            SBQQ.TriggerControl.disable();
            try 
            {
                insert qlHdr;
            } 
            finally 
            {
                SBQQ.TriggerControl.enable();
            }
            
            //Update Pricing Request with Quote Line Id
            createPRList[0].Quote_Line_Bundle__c = qlHdr[0].Id;
            createPRList[0].Quote__c = quoteWithRetailParentAccount.Id;
            UPDATE createPRList[0];
            
            //Create child quote lines
            List<SBQQ__QuoteLine__c> qlChild = new List<SBQQ__QuoteLine__c>();
            //Open Top Child Quote Line  --- Haul
            SBQQ__QuoteLine__c openTopHaul = TestDataFactory.createQuoteLineRecords(quoteWithRetailParentAccount, prodHaul,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            openTopHaul.SBQQ__RequiredBy__c = qlHdr[0].Id;
            openTopHaul.SBQQ__Number__c = 2;
            qlChild.add(openTopHaul);
            
            //Open Top Child Quote Line  --- Disposal
            SBQQ__QuoteLine__c openTopDisposal = TestDataFactory.createQuoteLineRecords(quoteWithRetailParentAccount, prodDisposal,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            openTopDisposal.SBQQ__RequiredBy__c = qlHdr[0].Id;
            openTopDisposal.SBQQ__Number__c = 2;
            qlChild.add(openTopDisposal);
            
            //Bundle 1 - Open Top - Broker Account
            SBQQ__QuoteLine__c qlOTBroker = TestDataFactory.createQuoteLineRecords(quoteWithBrokerParentAccount, prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOTBroker.SBQQ__Bundle__c = TRUE;
            qlOTBroker.SBQQ__RequiredBy__c = null;
            qlOTBroker.Vendor__c = vendorAcc.Id;
            qlOTBroker.SBQQ__Number__c = 1;
            qlOTBroker.Location_Position_Name__c = accLocPositionBroker.Id;
            qlOTBroker.Pricing_Request__c = createPRList[1].Id;
            
            SBQQ.TriggerControl.disable();
            try 
            {
                insert qlOTBroker;
            } 
            finally 
            {
                SBQQ.TriggerControl.enable();
            }
            
            //Update Pricing Request with Quote Line Id
            createPRList[1].Quote_Line_Bundle__c = qlOTBroker.Id;
            createPRList[1].Quote__c = quoteWithBrokerParentAccount.Id;
            UPDATE createPRList[1];
            
            //Create child quote lines - Broker Account
            List<SBQQ__QuoteLine__c> qlChildBroker = new List<SBQQ__QuoteLine__c>();
            //Open Top Child Quote Line  --- Haul
            SBQQ__QuoteLine__c openTopHaulBroker = TestDataFactory.createQuoteLineRecords(quoteWithBrokerParentAccount, prodHaul,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            openTopHaulBroker.SBQQ__RequiredBy__c = qlOTBroker.Id;
            openTopHaulBroker.SBQQ__Number__c = 2;
            qlChild.add(openTopHaulBroker);
            
            //Open Top Child Quote Line  --- Disposal
            SBQQ__QuoteLine__c openTopDisposalBroker = TestDataFactory.createQuoteLineRecords(quoteWithBrokerParentAccount, prodDisposal,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            openTopDisposalBroker.SBQQ__RequiredBy__c = qlOTBroker.Id;
            openTopDisposalBroker.SBQQ__Number__c = 2;
            qlChild.add(openTopDisposalBroker);
            
            /////////////
            //Bundle 3 - Compactor - Retail Account
            SBQQ__QuoteLine__c qlCMP = TestDataFactory.createQuoteLineRecords(quoteWithRetailParentAccountCMP, prodCompactor,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlCMP.SBQQ__Bundle__c = TRUE;
            qlCMP.SBQQ__RequiredBy__c = null;
            qlCMP.Vendor__c = vendorAcc.Id;
            qlCMP.SBQQ__Number__c = 1;
            qlCMP.Location_Position_Name__c = accLocPosition.Id;
            qlCMP.Pricing_Request__c = createPRList[0].Id;
            
            SBQQ.TriggerControl.disable();
            try 
            {
                insert qlCMP;
            } 
            finally 
            {
                SBQQ.TriggerControl.enable();
            }
            
            //Update Pricing Request with Quote Line Id
            createPRList[3].Quote_Line_Bundle__c = qlCMP.Id;
            createPRList[3].Quote__c = quoteWithRetailParentAccountCMP.Id;
            UPDATE createPRList[3];
            
            //Create child quote lines
            List<SBQQ__QuoteLine__c> qlChildCMP = new List<SBQQ__QuoteLine__c>();
            //Compactor Child Quote Line - Haul
            SBQQ__QuoteLine__c cmpHaul = TestDataFactory.createQuoteLineRecords(quoteWithRetailParentAccountCMP, prodHaul,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            cmpHaul.SBQQ__RequiredBy__c = qlCMP.Id;
            cmpHaul.SBQQ__Number__c = 2;
            qlChild.add(cmpHaul);
            
            //Open Top Child Quote Line  --- Disposal
            SBQQ__QuoteLine__c cmpDisposal = TestDataFactory.createQuoteLineRecords(quoteWithRetailParentAccountCMP, prodDisposal,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            cmpDisposal.SBQQ__RequiredBy__c = qlCMP.Id;
            cmpDisposal.SBQQ__Number__c = 2;
            qlChild.add(cmpDisposal);
            /////////////
            
            //Bundle 4 - Open Top - Retail Account - Multi Vendor
            SBQQ__QuoteLine__c qlOTMV = TestDataFactory.createQuoteLineRecords(quoteWithMultiVendorResponse, prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOTMV.SBQQ__Bundle__c = TRUE;
            qlOTMV.SBQQ__RequiredBy__c = null;
            qlOTMV.Vendor__c = vendorAcc.Id;
            qlOTMV.SBQQ__Number__c = 1;
            //qlOTMV.Location_Position_Name__c = accLocPositionMV.Id;
            qlOTMV.Pricing_Request__c = createPRList[4].Id;
            
            SBQQ.TriggerControl.disable();
            try 
            {
                insert qlOTMV;
            } 
            finally 
            {
                SBQQ.TriggerControl.enable();
            }
            
            //Update Pricing Request with Quote Line Id
            createPRList[4].Quote_Line_Bundle__c = qlOTMV.Id;
            createPRList[4].Quote__c = quoteWithMultiVendorResponse.Id;
            UPDATE createPRList[4];
            
            //Create child quote lines
            List<SBQQ__QuoteLine__c> qlChildMV = new List<SBQQ__QuoteLine__c>();
            //Open Top Child Quote Line  --- Haul
            SBQQ__QuoteLine__c openTopHaulMV = TestDataFactory.createQuoteLineRecords(quoteWithMultiVendorResponse, prodHaul,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            openTopHaulMV.SBQQ__RequiredBy__c = qlOTMV.Id;
            openTopHaulMV.SBQQ__Number__c = 2;
            qlChild.add(openTopHaulMV);
            
            //Open Top Child Quote Line  --- Disposal
            SBQQ__QuoteLine__c openTopDisposalMV = TestDataFactory.createQuoteLineRecords(quoteWithMultiVendorResponse, prodDisposal,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            openTopDisposalMV.SBQQ__RequiredBy__c = qlOTMV.Id;
            openTopDisposalMV.SBQQ__Number__c = 2;
            qlChild.add(openTopDisposalMV);
            
            //Bundle 5 - Open Top - Retail Account - Multi Vendor AMPO
            SBQQ__QuoteLine__c qlOTMVAMPO = TestDataFactory.createQuoteLineRecords(quoteWithMultiVendorResponseAMPO, prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOTMVAMPO.SBQQ__Bundle__c = TRUE;
            qlOTMVAMPO.SBQQ__RequiredBy__c = null;
            qlOTMVAMPO.Vendor__c = vendorAcc.Id;
            qlOTMVAMPO.SBQQ__Number__c = 1;
            //qlOTMV.Location_Position_Name__c = accLocPositionMV.Id;
            qlOTMVAMPO.Pricing_Request__c = createPRList[5].Id;
            
            SBQQ.TriggerControl.disable();
            try 
            {
                insert qlOTMVAMPO;
            } 
            finally 
            {
                SBQQ.TriggerControl.enable();
            }
            
            //Update Pricing Request with Quote Line Id
            createPRList[5].Quote_Line_Bundle__c = qlOTMVAMPO.Id;
            createPRList[5].Quote__c = quoteWithMultiVendorResponseAMPO.Id;
            UPDATE createPRList[5];
            
            //Create child quote lines
            List<SBQQ__QuoteLine__c> qlChildMVAMPO = new List<SBQQ__QuoteLine__c>();
            //Open Top Child Quote Line  --- Haul
            SBQQ__QuoteLine__c openTopHaulMVAMPO = TestDataFactory.createQuoteLineRecords(quoteWithMultiVendorResponseAMPO, prodHaul,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            openTopHaulMVAMPO.SBQQ__RequiredBy__c = qlOTMVAMPO.Id;
            openTopHaulMVAMPO.SBQQ__Number__c = 2;
            qlChild.add(openTopHaulMVAMPO);
            
            //Open Top Child Quote Line  --- Disposal
            SBQQ__QuoteLine__c openTopDisposalMVAMPO = TestDataFactory.createQuoteLineRecords(quoteWithMultiVendorResponseAMPO, prodDisposal,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            openTopDisposalMVAMPO.SBQQ__RequiredBy__c = qlOTMVAMPO.Id;
            openTopDisposalMVAMPO.SBQQ__Number__c = 2;
            qlChild.add(openTopDisposalMVAMPO);

            
            SBQQ.TriggerControl.disable();
            try 
            {
                Database.insert(qlChild);
                // Database.insert(qlChildBroker);
                // Database.insert(qlChildCMP);
                // Database.insert(qlChildMV);
                // Database.insert(qlChildMVAMPO);
            } 
            finally 
            {
                SBQQ.TriggerControl.enable();
            }
        }
    }
    
    //Create Price book and price book entries
    static void createPriceBookAndBookEntries(List<Product2> productsListForPriceBook)
    {
        List<Pricebookentry> pbeList= new List<Pricebookentry>();
        Pricebook2 pbObj = new Pricebook2(Name = 'Standard Price Book');
        
        insert pbObj;
        
        for(Product2 product : productsListForPriceBook)
        {
            Pricebookentry pbeObjOT= new Pricebookentry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            pbeList.add(pbeObjOT);
        }

        if(pbeList.size() > 0)
        {
            INSERT pbeList;
        }
    }
    
    static void createProductOptions(List<Product2> prodList)
    {
        Product2 prodOpenTop = prodList[0];
        Product2 prodDelivery = prodList[1];
        Product2 prodPickup = prodList[2];
        Product2 prodRemoval = prodList[3];
        Product2 prodDumpster = prodList[4];
        Product2 prodTrashWC = prodList[5];
        Product2 prodTrashWS = prodList[6];
        Product2 prodCompactor = prodList[7];
        Product2 prodHaul = prodList[8];
        Product2 prodDisposal = prodList[9];
        Product2 prodContainerServiceCharge = prodList[10];
        Product2 prodEnergySurcharge = prodList[11];
        Product2 prodEnvFee = prodList[12];
        Product2 prodFranchiseFee = prodList[13];
        Product2 prodInactivityFee = prodList[14];
        Product2 prodLandfillFee = prodList[15];
        Product2 prodRecyclingMaterialFee = prodList[16];
        
        List<SBQQ__ProductOption__c> productOptionsList = new List<SBQQ__ProductOption__c>();
        
        //Waste Category - Dumpster
        SBQQ__ProductOption__c wstCategoryPODMP = new SBQQ__ProductOption__c();
        wstCategoryPODMP.SBQQ__ConfiguredSKU__c = prodDumpster.Id;
        wstCategoryPODMP.SBQQ__OptionalSKU__c = prodTrashWC.Id;
        wstCategoryPODMP.SBQQ__Number__c = 350;
        wstCategoryPODMP.SBQQ__Quantity__c = 1;
        wstCategoryPODMP.Occurrence_Type__c = 'SCH';
        wstCategoryPODMP.CostModelType__c = 'PER';
        wstCategoryPODMP.Cost_Unit_of_Measure__c = 'MTH';
        wstCategoryPODMP.PriceUOM__c = 'MTH';
        productOptionsList.add(wstCategoryPODMP);
        
        //Waste Stream - Dumpster
        SBQQ__ProductOption__c wstStreamPODMP = new SBQQ__ProductOption__c();
        wstStreamPODMP.SBQQ__ConfiguredSKU__c = prodTrashWC.Id;
        wstStreamPODMP.SBQQ__OptionalSKU__c = prodTrashWS.Id;
        wstStreamPODMP.SBQQ__Number__c = 350;
        wstStreamPODMP.SBQQ__Quantity__c = 1;
        wstStreamPODMP.Occurrence_Type__c = 'SCH';
        wstStreamPODMP.CostModelType__c = 'PER';
        wstStreamPODMP.Cost_Unit_of_Measure__c = 'MTH';
        wstStreamPODMP.PriceUOM__c = 'MTH';
        productOptionsList.add(wstStreamPODMP);
        
        //Waste Category - Open Top
        SBQQ__ProductOption__c wstCategoryPOOT = new SBQQ__ProductOption__c();
        wstCategoryPOOT.SBQQ__ConfiguredSKU__c = prodOpenTop.Id;
        wstCategoryPOOT.SBQQ__OptionalSKU__c = prodTrashWC.Id;
        wstCategoryPOOT.SBQQ__Number__c = 350;
        wstCategoryPOOT.SBQQ__Quantity__c = 1;
        wstCategoryPOOT.Occurrence_Type__c = 'SCH';
        wstCategoryPOOT.CostModelType__c = 'PER';
        wstCategoryPOOT.Cost_Unit_of_Measure__c = 'MTH';
        wstCategoryPOOT.PriceUOM__c = 'MTH';
        productOptionsList.add(wstCategoryPOOT);
        
        //Waste Stream - Open Top
        SBQQ__ProductOption__c wstStreamPOOT = new SBQQ__ProductOption__c();
        wstStreamPOOT.SBQQ__ConfiguredSKU__c = prodTrashWC.Id;
        wstStreamPOOT.SBQQ__OptionalSKU__c = prodTrashWS.Id;
        wstStreamPOOT.SBQQ__Number__c = 350;
        wstStreamPOOT.SBQQ__Quantity__c = 1;
        wstStreamPOOT.Occurrence_Type__c = 'SCH';
        wstStreamPOOT.CostModelType__c = 'PER';
        wstStreamPOOT.Cost_Unit_of_Measure__c = 'MTH';
        wstStreamPOOT.PriceUOM__c = 'MTH';
        productOptionsList.add(wstStreamPOOT);
        
        //Waste Category - Compactor
        SBQQ__ProductOption__c wstCategoryPOCMP = new SBQQ__ProductOption__c();
        wstCategoryPOCMP.SBQQ__ConfiguredSKU__c = prodCompactor.Id;
        wstCategoryPOCMP.SBQQ__OptionalSKU__c = prodTrashWC.Id;
        wstCategoryPOCMP.SBQQ__Number__c = 350;
        wstCategoryPOCMP.SBQQ__Quantity__c = 1;
        wstCategoryPOCMP.Occurrence_Type__c = 'SCH';
        wstCategoryPOCMP.CostModelType__c = 'PER';
        wstCategoryPOCMP.Cost_Unit_of_Measure__c = 'MTH';
        wstCategoryPOCMP.PriceUOM__c = 'MTH';
        productOptionsList.add(wstCategoryPOCMP);
        
        //Waste Stream - Compactor
        SBQQ__ProductOption__c wstStreamPOCMP = new SBQQ__ProductOption__c();
        wstStreamPOCMP.SBQQ__ConfiguredSKU__c = prodTrashWC.Id;
        wstStreamPOCMP.SBQQ__OptionalSKU__c = prodTrashWS.Id;
        wstStreamPOCMP.SBQQ__Number__c = 350;
        wstStreamPOCMP.SBQQ__Quantity__c = 1;
        wstStreamPOCMP.Occurrence_Type__c = 'SCH';
        wstStreamPOCMP.CostModelType__c = 'PER';
        wstStreamPOCMP.Cost_Unit_of_Measure__c = 'MTH';
        wstStreamPOCMP.PriceUOM__c = 'MTH';
        productOptionsList.add(wstStreamPOCMP);
        
        //Create fees for Open Top
        productOptionsList.add(createFeesProductOption(prodOpenTop, prodContainerServiceCharge));
        productOptionsList.add(createFeesProductOption(prodOpenTop, prodEnergySurcharge));
        productOptionsList.add(createFeesProductOption(prodOpenTop, prodEnvFee));
        productOptionsList.add(createFeesProductOption(prodOpenTop, prodFranchiseFee));
        productOptionsList.add(createFeesProductOption(prodOpenTop, prodInactivityFee));
        productOptionsList.add(createFeesProductOption(prodOpenTop, prodLandfillFee));
        productOptionsList.add(createFeesProductOption(prodOpenTop, prodRecyclingMaterialFee));
        
        //Create fees for Compactor
        productOptionsList.add(createFeesProductOption(prodCompactor, prodContainerServiceCharge));
        productOptionsList.add(createFeesProductOption(prodCompactor, prodEnergySurcharge));
        productOptionsList.add(createFeesProductOption(prodCompactor, prodEnvFee));
        productOptionsList.add(createFeesProductOption(prodCompactor, prodFranchiseFee));
        productOptionsList.add(createFeesProductOption(prodCompactor, prodInactivityFee));
        productOptionsList.add(createFeesProductOption(prodCompactor, prodLandfillFee));
        productOptionsList.add(createFeesProductOption(prodCompactor, prodRecyclingMaterialFee));
        
        //Create fees for Dumpster
        productOptionsList.add(createFeesProductOption(prodDumpster, prodContainerServiceCharge));
        productOptionsList.add(createFeesProductOption(prodDumpster, prodEnergySurcharge));
        productOptionsList.add(createFeesProductOption(prodDumpster, prodEnvFee));
        productOptionsList.add(createFeesProductOption(prodDumpster, prodFranchiseFee));
        productOptionsList.add(createFeesProductOption(prodDumpster, prodInactivityFee));
        productOptionsList.add(createFeesProductOption(prodDumpster, prodLandfillFee));
        productOptionsList.add(createFeesProductOption(prodDumpster, prodRecyclingMaterialFee));
        
        //Create Delivery Product Option for Containers
        productOptionsList.add(createDeliveryProductOption(prodOpenTop, prodDelivery));
        productOptionsList.add(createDeliveryProductOption(prodCompactor, prodDelivery));
        productOptionsList.add(createDeliveryProductOption(prodDumpster, prodDelivery));
        
        insert productOptionsList;
    }
    
    public static SBQQ__ProductOption__c createFeesProductOption(Product2 parentProduct, Product2 childProduct)
    {
        SBQQ__ProductOption__c feesProductOption = new SBQQ__ProductOption__c();
        feesProductOption.SBQQ__ConfiguredSKU__c = parentProduct.Id;
        feesProductOption.SBQQ__OptionalSKU__c = childProduct.Id;
        feesProductOption.SBQQ__Number__c = 350;
        feesProductOption.SBQQ__Quantity__c = 1;
        feesProductOption.Occurrence_Type__c = 'SCH';
        feesProductOption.CostModelType__c = 'PER';
        feesProductOption.Cost_Unit_of_Measure__c = 'MTH';
        feesProductOption.PriceUOM__c = 'MTH';
        feesProductOption.Schedule_Frequency__c = 'M';
        feesProductOption.Frequency_Interval__c = '1';
        return feesProductOption;
    }
    
    public static SBQQ__ProductOption__c createDeliveryProductOption(Product2 parentProduct, Product2 childProduct)
    {    
        SBQQ__ProductOption__c deliveryPO = new SBQQ__ProductOption__c();
        deliveryPO.SBQQ__ConfiguredSKU__c = parentProduct.Id;
        deliveryPO.SBQQ__OptionalSKU__c = childProduct.Id;
        deliveryPO.SBQQ__Number__c = 350;
        deliveryPO.SBQQ__Quantity__c = 1;
        deliveryPO.Occurrence_Type__c = 'OC';
        deliveryPO.CostModelType__c = 'PER';
        deliveryPO.Cost_Unit_of_Measure__c = 'EV';
        deliveryPO.PriceUOM__c = 'EV';
        return deliveryPO;
    }
    
    /*
    @isTest
    static void test()
    {
		List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, SBQQ__Opportunity2__r.Name FROM SBQQ__Quote__c];
        for(SBQQ__Quote__c q : quoteList)
        {
            system.debug('PK Q' + q.SBQQ__Opportunity2__r.Name + ';' + q.Id + ';' + q.Name);
            
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__Product__r.Name, Pricing_Request__c, SBQQ__RequiredBy__c, SBQQ__Quote__r.Name
                                                   FROM SBQQ__QuoteLine__c 
                                                   WHERE SBQQ__Quote__c =: q.Id
                                                  ];
            for(SBQQ__QuoteLine__c ql : quoteLines)
            {
                system.debug('PK Q QL ' + ql.Id + ';' + ql.SBQQ__Product__r.Name + ';' + ql.SBQQ__RequiredBy__c + ql.SBQQ__Quote__r.Name);
            }
        }
    }
    */
    @isTest
    static void testFeesAdditionStandarPricingWMOpenMarketOpenTopUSRetail()
    {
		User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {
            List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Opportunity2__r.Name FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.Name = 'Test Opportunity Retail' LIMIT 1];
            Id quoteId = quoteList[0].Id;
            
            test.startTest();
            system.assertEquals(true, true, 'Bypass SOQL 101');
            PricingRequestSTPProcess.quoteLineProcess(quoteId);
            
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__Product__r.Name, Pricing_Request__c 
                                                   FROM SBQQ__QuoteLine__c 
                                                   WHERE SBQQ__Quote__c =: quoteId
                                                   AND SBQQ__Product__r.ProductCode in ('FF', 'LF', 'ENV_FEE', 'ENS', 'IF', 'RECV', 'CSC')
                                                  ];
            system.assertEquals(1, quoteLines.size(), sAssertionErrorMessage);
            test.stopTest();
        }
    }
    
    @isTest
    static void testFeesAdditionStandarPricingWMOpenMarketCompactorUSRetail()
    {
		User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {
            List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Opportunity2__r.Name FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.Name = 'Test Opportunity Retail CMP' LIMIT 1];
            Id quoteId = quoteList[0].Id;
            
            test.startTest();
            system.assertEquals(true, true, 'Bypass SOQL 101');
            PricingRequestSTPProcess.quoteLineProcess(quoteId);
            
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__Product__r.Name, Pricing_Request__c 
                                                   FROM SBQQ__QuoteLine__c 
                                                   WHERE SBQQ__Quote__c =: quoteId
                                                   AND SBQQ__Product__r.ProductCode in ('FF', 'LF', 'ENV_FEE', 'ENS', 'IF', 'RECV', 'CSC')
                                                  ];
            system.assertEquals(0, quoteLines.size(), sAssertionErrorMessage);
            system.debug('PK Compa' + quoteLines);
            test.stopTest();
        }
    }
    
    @isTest
    static void testFeesAdditionStandarPricingWMOpenMarketOpenTopUSBroker()
    {
        User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {
            List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Opportunity2__r.Name FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.Name = 'Test Opportunity Broker' LIMIT 1];
            Id quoteId = quoteList[0].Id;
            
            test.startTest();
            system.assertEquals(true, true, 'Bypass SOQL 101');
            PricingRequestSTPProcess.quoteLineProcess(quoteId);
            
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__Product__r.Name, Pricing_Request__c 
                                                   FROM SBQQ__QuoteLine__c 
                                                   WHERE SBQQ__Quote__c =: quoteId
                                                   AND SBQQ__Product__r.ProductCode in ('FF', 'LF', 'ENV_FEE', 'ENS', 'IF', 'RECV', 'CSC')
                                                  ];
            system.assertEquals(6, quoteLines.size(), sAssertionErrorMessage);
            test.stopTest();
        }
    }
    
    @isTest
    static void testFeesAdditionPriceOnlyWMOpenMarketOpenTopUS()
    {
        User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {
            List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Opportunity2__r.Name, SBQQ__Account__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.Name = 'Test Opportunity Retail' LIMIT 1];
            Id quoteId = quoteList[0].Id;
            
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name = 'WM Vendor Account' LIMIT 1];
            
            test.startTest();
            system.assertEquals(true, true, 'Bypass SOQL 101');
            PricingRequestSTPProcess.quoteLineProcess(quoteId);
            SBQQ__QuoteLine__c bundleQuoteLine = null;
            
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__Product__r.Name, Pricing_Request__c, SBQQ__Product__r.ProductCode, Pricing_Only_Request__c, SBQQ__RequiredBy__c
                                                   FROM SBQQ__QuoteLine__c 
                                                   WHERE SBQQ__Quote__c =: quoteId
                                                  ];
            Integer serviceChargesQuoteLineCount = 0;
            for(SBQQ__QuoteLine__c quoteLine : quoteLines)
            {
                if(productCodes.contains(quoteLine.SBQQ__Product__r.ProductCode))
                {
                    serviceChargesQuoteLineCount++;
                }
                if(quoteLine.SBQQ__RequiredBy__c == null)
                {
                    bundleQuoteLine = quoteLine;
                }
            }
            system.assertEquals(1, serviceChargesQuoteLineCount, sAssertionErrorMessage);
            
            Pricing_Request__c priceOnlyPR = [SELECT Id, Pricing_Type__c, Quote__c, Quote_Line_Bundle__c FROM Pricing_Request__c WHERE Service_City__c = 'Test OT AMPO' AND Pricing_Type__c = 'AMPO'];
            
            if(bundleQuoteLine != null && priceOnlyPR != null)
            {
                bundleQuoteLine.Pricing_Only_Request__c = priceOnlyPR.Id;
                UPDATE bundleQuoteLine;
                
                priceOnlyPR.Quote__c = quoteId;
                priceOnlyPR.Quote_Line_Bundle__c = bundleQuoteLine.Id;
                UPDATE priceOnlyPR;
                
                //Create Landfill Fee-Manually procured service
                Product2 prodLandfillFee = [SELECT Id FROM Product2 WHERE Name='Landfill Fee'];
                SBQQ__QuoteLine__c openTopLandfillFee = TestDataFactory.createQuoteLineRecords(quoteList[0], prodLandfillFee,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',5,'DYS','Do Not Override','NBG');
                openTopLandfillFee.SBQQ__RequiredBy__c = bundleQuoteLine.Id;
                openTopLandfillFee.SBQQ__Number__c = 15;
                openTopLandfillFee.SBQQ__Quote__c = quoteId;
                openTopLandfillFee.Vendor__c = vendorAcc.Id;
                SBQQ.TriggerControl.disable();
                try 
                {
                    RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = true;
                    Database.insert(openTopLandfillFee);
                } 
                finally 
                {
                    SBQQ.TriggerControl.enable();
                }
                
            }

            List<SBQQ__QuoteLine__c> quoteLinesList = [SELECT Id, SBQQ__Product__r.Name, Pricing_Request__c, SBQQ__Product__r.ProductCode, Pricing_Only_Request__c, SBQQ__RequiredBy__c, Vendor__c
                                                       FROM SBQQ__QuoteLine__c 
                                                       WHERE SBQQ__Quote__c =: quoteId
                                                      ];
            List<SBQQ__QuoteLine__c> quoteLinesListForVendorUpdate = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c quoteLine : quoteLinesList)
            {
                if(String.isBlank(quoteLine.Vendor__c))
                {
                    quoteLine.Vendor__c = vendorAcc.Id;
                    quoteLinesListForVendorUpdate.add(quoteLine);
                }
            }
            
            SBQQ.TriggerControl.disable();
            try 
            {
                RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = true;
                if(quoteLinesListForVendorUpdate.size() > 0)
                {
                    UPDATE quoteLinesListForVendorUpdate;
                }
                
            } 
            finally 
            {
                SBQQ.TriggerControl.enable();
            }

            //Invoke PriceOnly
            PriceOnlyRequestSTPProcess.savePricetoQuoteline(quoteId);
            test.stopTest();
        }
    }
    
    @isTest
    static void testFeesAdditionStandarPricingWMOpenMarketOpenTopCanada()
    {
        User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {
            List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Opportunity2__r.Name FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.Name = 'Test Opportunity Retail' LIMIT 1];
            SBQQ__Quote__c quoteRecord = quoteList[0];
            Id quoteId = quoteList[0].Id;
            
            if(quoteRecord != null)
            {
                quoteRecord.SBQQ__ShippingCountry__c = 'Canada';
                UPDATE quoteRecord;
            }
            
            test.startTest();
            system.assertEquals(true, true, 'Bypass SOQL 101');
            PricingRequestSTPProcess.quoteLineProcess(quoteId);
            
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__Product__r.Name, Pricing_Request__c 
                                                   FROM SBQQ__QuoteLine__c 
                                                   WHERE SBQQ__Quote__c =: quoteId
                                                   AND SBQQ__Product__r.ProductCode in ('FF', 'LF', 'ENV_FEE', 'ENS', 'IF', 'RECV', 'CSC')
                                                  ];
            system.assertEquals(6, quoteLines.size(), sAssertionErrorMessage);
        }
    }

    @isTest
    static void testFeesAdditionStandarPricingWMOpenMarketOpenTopUSRetailMV()
    {
		User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {
            List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Opportunity2__r.Name FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.Name = 'Test Opportunity Multi Vendor' LIMIT 1];
            Id quoteId = quoteList[0].Id;

           
            test.startTest();
            system.assertEquals(true, true, 'Bypass SOQL 101');
            // PricingRequestSTPProcess.quoteLineProcess(quoteId);
            PricingRequestMultiVendorSTPProcess.processMultiVendorPricingRequest(quoteId, true);
            
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__Product__r.Name, Pricing_Request__c 
                                                   FROM SBQQ__QuoteLine__c 
                                                   WHERE SBQQ__Quote__c =: quoteId
                                                   AND SBQQ__Product__r.ProductCode in ('FF', 'LF', 'ENV_FEE', 'ENS', 'IF', 'RECV', 'CSC')
                                                  ];
            system.assertEquals(0, quoteLines.size(), sAssertionErrorMessage);
            test.stopTest();
        }
    }

    @isTest
    static void testFeesAdditionStandarPricingWMOpenMarketOpenTopUSRetailMV_PO()
    {
		User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {
            List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Opportunity2__r.Name FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.Name = 'Test Opportunity Multi Vendor AMPO' LIMIT 1];
            Id quoteId = quoteList[0].Id;

            // List<SBQQ__QuoteLine__c> qlList = [SELECT Id, Pricing_Request__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteList[0].Id and SBQQ__RequiredBy__c = null LIMIT 1];
            List<Pricing_Request__c> prlList = [SELECT Id, Quote__c, Quote_Line_Bundle__c, Pricing_Type__c, APIRequestOutput__c FROM Pricing_Request__c WHERE Quote__c =: quoteId  LIMIT 1];

            test.startTest();
            system.assertEquals(true, true, 'Bypass SOQL 101');

            SBQQ.TriggerControl.disable();
            try 
            {
                Pricing_Request__c pr = new Pricing_Request__c();
                pr.Id = prlList[0].Id;
                pr.Pricing_Type__c = 'AMPO';
                pr.Quote__c = quoteId;
                pr.APIRequestOutput__c  = JSON_VALID_ROLLOFF_DATA_PriceOnly;
                update pr;
            } 
            finally 
            {
                SBQQ.TriggerControl.enable();
            }

            // PricingRequestSTPProcess.quoteLineProcess(quoteId);
            PricingRequestMultiVendorSTPProcess.processMultiVendorPricingRequest(quoteId, true);
            //PriceOnlyRequestSTPProcess.savePricetoQuoteline(quoteId);
            
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__Product__r.Name, Pricing_Request__c 
                                                   FROM SBQQ__QuoteLine__c 
                                                   WHERE SBQQ__Quote__c =: quoteId
                                                   AND SBQQ__Product__r.ProductCode in ('FF', 'LF', 'ENV_FEE', 'ENS', 'IF', 'RECV', 'CSC')
                                                  ];
            system.assertEquals(0, quoteLines.size(), sAssertionErrorMessage);
            test.stopTest();
        }
    }
}
