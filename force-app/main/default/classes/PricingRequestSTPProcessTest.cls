@isTest(seeAllData=false)
global class PricingRequestSTPProcessTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string TRASH = 'Trash';
    private static final string ON_CALL = 'On-Call';
    private static final string ROLLOFF = 'Rolloff';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SERVICES = 'Services';
    private static final string EQUIPMENT = 'Equipment';
    private static final string FieldApiName = 'Material_Code__c';
    //private static final String JSON_VALID_ROLLOFF_DATA = '{"data":{"priceQuoteIdentifier":"Q11837","costSource":"WM (SBS|RO|OT|30O|B02860|20211019|025300|5810)","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"10016","supplierName":"WMI OF MI, LIVONIA","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD002718","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"30O","equipmentName":"30 Yard Open Top","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS543320","zoneName":"Detroit Central - RO MSW - To Woodland 1","disposalFacilityType":"S04264_LF","disposalFacilityName":"B02860|S04264_LF|129A_WDL|MSW_RO","commercial":null,"rollOff":{"pricingMethodDisposalCode":"1.0","pricingMethodDisposalDescription":"Market Based Pricing","pricingMethodHaulingCode":"1.0","pricingMethodHaulingDescription":"Market Based Pricing","haulCost":410.59,"haulPrice":null,"disposalCost":30.42,"disposalPrice":null,"estimatedVolumePerHaul":4,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":126.68,"landfillMinutes":25,"transferSiteCode":"NA","equipmentAvailabilityTypeCode":"TEMP","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":20,"equipmentAdditionalLoadingMinutes":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B02860","masLibrary":"129A_WDL","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Michigan Ohio Indiana"},"tpMetaData":null,"serviceCharges":[{"code":"FU_RO_TEMP_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"ENV_RO_TEMP_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"RCR_RO_TEMP_OPEN","name":"Regulatory Cost Recovery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"CSC_RO_TEMP_OPEN","name":"Container Service Charge","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"D_RO_TEMP_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"}]},"problem":null}';
    private static final String JSON_VALID_ROLLOFF_DATA = '{"data":{"priceQuoteIdentifier":"Q12631","costSource":"WM (SBS|RO|OT|30O|B02433|20220328|045807|9598)","priceSource":"Standard Pricing","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"12603|214136|2620","supplierName":"WMI - A FIORE & SON OF NEWARK|WMI OF NJ, ELIZABETH|WM - NJ-NORTH - 2433","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD005826","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"30O","equipmentName":"30 Yard Open Top","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-40","equipmentSizeName":"40 Yards","overridableEquipmentSizeCode":"YRDS-30","overridableEquipmentSizeName":"30 Yards","zoneCode":"GIS512254","zoneName":"UCROMSW","disposalFacilityType":"S07379_LF","disposalFacilityName":"B02433|S07379_LF|S02938_TS|132A_FMW|MSW_RO","feeComment": null,"isCostOnly": false,"commercial":null,"rollOff":{"pricingMethodDisposalCode":"1.0","pricingMethodDisposalDescription":"Market Based Pricing","pricingMethodHaulingCode":"2.0","pricingMethodHaulingDescription":"Cost Plus","originalHaulCost":null,"haulCost":285,"haulPrice":null,"originalDisposalCost":null,"disposalCost":102.57,"disposalPrice":null,"estimatedVolumePerHaul":3,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":15.52,"landfillMinutes":23,"transferSiteCode":"S02938_TS","equipmentAvailabilityTypeCode":"TEMP","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":15,"equipmentAdditionalLoadingMinutes":null,"haulRecordId":null,"disposalRecordId":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B02433","masLibrary":"132A_FMW","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Greater Mid Atlantic"},"tpMetaData":null,"serviceCharges":[{"code":"FU_RO_TEMP_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"ENV_RO_TEMP_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"MNT_RO_TEMP_OPEN_R","name":"Minimum Tons Recycling","componentTypeCode":"DSP","componentTypeName":"Disposal","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"MNT_RO_TEMP_OPEN_T","name":"All Other Minimum Tonnage","componentTypeCode":"DSP","componentTypeName":"Disposal","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"LF_RO_TEMP_OPEN","name":"Landfill Fee","componentTypeCode":"LF","componentTypeName":"Landfill Fee","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"FF_RO_TEMP_OPEN","name":"Franchise Fee","componentTypeCode":"FF","componentTypeName":"Franchise Fee","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"D_RO_TEMP_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null}]},"problem":null}';
    private static final String JSON_VALID_ROLLOFF_DATA_REC = '{"data":{"priceQuoteIdentifier":"Q12631","costSource":"WM (SBS|RO|OT|30O|B02433|20220328|045807|9598)","priceSource":"Standard Pricing","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"12603|214136|2620","supplierName":"WMI - A FIORE & SON OF NEWARK|WMI OF NJ, ELIZABETH|WM - NJ-NORTH - 2433","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD005826","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"30O","equipmentName":"30 Yard Open Top","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-40","equipmentSizeName":"40 Yards","overridableEquipmentSizeCode":"YRDS-30","overridableEquipmentSizeName":"30 Yards","zoneCode":"GIS512254","zoneName":"UCROMSW","disposalFacilityType":"S07379_LF","disposalFacilityName":"B02433|S07379_LF|S02938_TS|132A_FMW|MSW_RO","feeComment": "Rebate is $25 per ton","isCostOnly": false,"commercial":null,"rollOff":{"pricingMethodDisposalCode":"1.0","pricingMethodDisposalDescription":"Market Based Pricing","pricingMethodHaulingCode":"2.0","pricingMethodHaulingDescription":"Cost Plus","originalHaulCost":null,"haulCost":285,"haulPrice":null,"originalDisposalCost":null,"disposalCost":102.57,"disposalPrice":null,"estimatedVolumePerHaul":3,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":15.52,"landfillMinutes":23,"transferSiteCode":"S02938_TS","equipmentAvailabilityTypeCode":"TEMP","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":15,"equipmentAdditionalLoadingMinutes":null,"haulRecordId":null,"disposalRecordId":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B02433","masLibrary":"132A_FMW","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Greater Mid Atlantic"},"tpMetaData":null,"serviceCharges":[{"code":"FU_RO_TEMP_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"ENV_RO_TEMP_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"MNT_RO_TEMP_OPEN_R","name":"Minimum Tons Recycling","componentTypeCode":"DSP","componentTypeName":"Disposal","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"MNT_RO_TEMP_OPEN_T","name":"All Other Minimum Tonnage","componentTypeCode":"DSP","componentTypeName":"Disposal","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"LF_RO_TEMP_OPEN","name":"Landfill Fee","componentTypeCode":"LF","componentTypeName":"Landfill Fee","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"FF_RO_TEMP_OPEN","name":"Franchise Fee","componentTypeCode":"FF","componentTypeName":"Franchise Fee","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null},{"code":"D_RO_TEMP_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly","serviceChargeRecordId":null}]},"problem":null}';
    private static final String JSON_VALID_COMMERCIAL_DATA = '{"data":{"priceQuoteIdentifier":"Q11839","costSource":"WM (SBS|CO|DMP|4FY|B02433|20211019|030423|5192)","contractType":"Open Market","lineOfBusiness":"Commercial","supplierCode":"12603|214136|2620","supplierName":"WMI - A FIORE & SON OF NEWARK|WMI OF NJ, ELIZABETH|WM - NJ-NORTH - 2433","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD005826","wasteStreamCode":"REC","wasteStreamName":"Recycling","equipmentCode":"4FY","equipmentName":"4 Yard FEL Recycling","equipmentUOM":"Monthly","materialCode":"C","materialName":"Cardboard - OCC","equipmentSizeCode":"YRDS-4","equipmentSizeName":"4 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS513947","zoneName":"UCFLRY","disposalFacilityType":"S02938_MRF","disposalFacilityName":"[B02433] [Recycle_SSRY_CO] Julia Street Recycling","feeComment": null,"isCostOnly": false,"commercial":{"pricingMethodCode":"2.0","pricingMethodCodeDescription":"Cost Plus","cost":32.28,"price":37.12,"equipmentLoadingMinutes":null,"equipmentAdditionalLoadingMinutes":null,"estimatedWeightPerYard":30,"equipmentVolume":4,"extraPickupCost":null,"extraPickupPrice":null},"rollOff":null,"wmMetaData":{"businessUnit":"B02433","masLibrary":"152A_ELC","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Greater Mid Atlantic"},"tpMetaData":null,"serviceCharges":[{"code":"FU_C_PERM_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"ENV_C_PERM_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"RCR_C_PERM_OPEN","name":"Regulatory Cost Recovery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"CSC_C_PERM_OPEN","name":"Container Service Charge","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"MR","actionName":"Manual Review","cost":null,"costValueType":null,"costUOM":null,"price":null,"priceValueType":null,"priceUOM":null},{"code":"D_C_PERM_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":100,"costValueType":"Amount","costUOM":null,"price":115,"priceValueType":"Amount","priceUOM":null}]},"problem":null}';
    private static final String JSON_INVALID_DATA = '{"data":null,"problem":{"title":"Bad Request","status":400,"errors":[{"code":null,"message":"No cost price information available."}]}}';
    private static final String JSON_INVALID_DATA_PROS = '{"data":null,"problem":{"title":"Bad Request","status":400,"errors":[{"code":"NAC","message":"WM PROS cannot derive zone coordinates for this location. Please review the location address, correct & resubmit or process this request manually."}]}}';
    private static final String JSON_ROLLOFF_COMPACTOR_DATA = '{"data":{"priceQuoteIdentifier":"Q11840","costSource":"WM (SBS|RO|CMP|25C|B02433|20211019|030955|1913)","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"12603|214136|2620","supplierName":"WMI - A FIORE & SON OF NEWARK|WMI OF NJ, ELIZABETH|WM - NJ-NORTH - 2433","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD005826","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"25C","equipmentName":"25 Yard Compactor","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-25","equipmentSizeName":"25 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS512254","zoneName":"UCROMSW","disposalFacilityType":"S07379_LF","disposalFacilityName":"B02433|S07379_LF|S02938_TS|132A_FMW|MSW_RO","feeComment": null,"isCostOnly": false,"commercial":null,"rollOff":{"pricingMethodDisposalCode":"1.0","pricingMethodDisposalDescription":"Market Based Pricing","pricingMethodHaulingCode":"2.0","pricingMethodHaulingDescription":"Cost Plus","haulCost":285,"haulPrice":327.75,"disposalCost":109.71,"disposalPrice":126.17,"estimatedVolumePerHaul":6,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":15.52,"landfillMinutes":23,"transferSiteCode":"S02938_TS","equipmentAvailabilityTypeCode":"PERM","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":20,"equipmentAdditionalLoadingMinutes":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B02433","masLibrary":"132A_FMW","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Greater Mid Atlantic"},"tpMetaData":null,"serviceCharges":[{"code":"FU_RO_PERM_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"ENV_RO_PERM_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"RCR_RO_PERM_OPEN","name":"Regulatory Cost Recovery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"CSC_RO_PERM_OPEN","name":"Container Service Charge","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"AL","actionName":"Allow","cost":192.04,"costValueType":"Amount","costUOM":null,"price":192.04,"priceValueType":"Amount","priceUOM":null},{"code":"D_RO_PERM_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":100,"costValueType":"Amount","costUOM":null,"price":115,"priceValueType":"Amount","priceUOM":null}]},"problem":null}';
    private static final String JSON_WM_FRANCHISE= '{"data":{"priceQuoteIdentifier":"Q113998","costSource":"WM ()","contractType":"wm franchise","lineOfBusiness":"Roll Off","supplierCode":null,"supplierName":null,"customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD001048","wasteStreamCode":"MSW","wasteStreamName":"Municipal Solid Waste","equipmentCode":"OT","equipmentName":"Open Top","equipmentUOM":null,"materialCode":"T","materialName":"","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS544488","zoneName":"LA, City of - Non WM Franchise - Athens","disposalFacilityType":null,"disposalFacilityName":null,"feeComment": null,"isCostOnly": false,"commercial":null,"rollOff":null,"wmMetaData":{"businessUnit":null,"masLibrary":null,"francisePricingLink":"http://greenpagesadmin.wm.com/eAgent/iq/Ellington/request.do?create=kb:Southern California&view()=r[case013b74a0-a9fc-11de-e73d-000000000000]","greenPagesLink":""},"tpMetaData":null,"serviceCharges":null},"problem":null}';
    private static final String JSON_COMPITITOR= '{"data":{"priceQuoteIdentifier":"Q113998","costSource":"WM ()","contractType":"competitor","lineOfBusiness":"Roll Off","supplierCode":null,"supplierName":null,"customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD001048","wasteStreamCode":"MSW","wasteStreamName":"Municipal Solid Waste","equipmentCode":"OT","equipmentName":"Open Top","equipmentUOM":null,"materialCode":"T","materialName":"","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS544488","zoneName":"LA, City of - Non WM Franchise - Athens","disposalFacilityType":null,"disposalFacilityName":null,"feeComment": null,"isCostOnly": false,"commercial":null,"rollOff":null,"wmMetaData":{"businessUnit":null,"masLibrary":null,"francisePricingLink":"http://greenpagesadmin.wm.com/eAgent/iq/Ellington/request.do?create=kb:Southern California&view()=r[case013b74a0-a9fc-11de-e73d-000000000000]","greenPagesLink":""},"tpMetaData":null,"serviceCharges":null},"problem":null}';
    private static final String JSON_PDPRICING= '{"data":{"priceQuoteIdentifier":"Q113998","costSource":"WM ()","contractType":"pre-determined pricing","lineOfBusiness":"Roll Off","supplierCode":null,"supplierName":null,"customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD001048","wasteStreamCode":"MSW","wasteStreamName":"Municipal Solid Waste","equipmentCode":"OT","equipmentName":"Open Top","equipmentUOM":null,"materialCode":"T","materialName":"","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS544488","zoneName":"LA, City of - Non WM Franchise - Athens","disposalFacilityType":null,"disposalFacilityName":null,"feeComment": null,"isCostOnly": false,"commercial":null,"rollOff":null,"wmMetaData":{"businessUnit":null,"masLibrary":null,"francisePricingLink":"http://greenpagesadmin.wm.com/eAgent/iq/Ellington/request.do?create=kb:Southern California&view()=r[case013b74a0-a9fc-11de-e73d-000000000000]","greenPagesLink":""},"tpMetaData":null,"serviceCharges":null},"problem":null}';
    private static final String JSON_TPAGREEMENT= '{"data":{"priceQuoteIdentifier":"Q113998","costSource":"WM ()","contractType":"third -party agreement","lineOfBusiness":"Roll Off","supplierCode":null,"supplierName":null,"customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD001048","wasteStreamCode":"MSW","wasteStreamName":"Municipal Solid Waste","equipmentCode":"OT","equipmentName":"Open Top","equipmentUOM":null,"materialCode":"T","materialName":"","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS544488","zoneName":"LA, City of - Non WM Franchise - Athens","disposalFacilityType":null,"disposalFacilityName":null,"feeComment": null,"isCostOnly": false,"commercial":null,"rollOff":null,"wmMetaData":{"businessUnit":null,"masLibrary":null,"francisePricingLink":"http://greenpagesadmin.wm.com/eAgent/iq/Ellington/request.do?create=kb:Southern California&view()=r[case013b74a0-a9fc-11de-e73d-000000000000]","greenPagesLink":""},"tpMetaData":null,"serviceCharges":null},"problem":null}';
    private static final String JSON_SUBSTITUTE_SIZE= '{"data":{"priceQuoteIdentifier":"Q11843","costSource":"WM (SBS|RO|OT|30O|B00073|20211019|032658|1469)","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"200119|213220","supplierName":"WASTE MANAGEMENT OF ATLANTA NORTH|WMI OF GA - ATLANTA HAULING","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD000100","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"30O","equipmentName":"30 Yard Open Top","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-35","equipmentSizeName":"35 Yards","overridableEquipmentSizeCode":"YRDS-30","overridableEquipmentSizeName":"30 Yards","zoneCode":"GIS526480","zoneName":"B0073 ZOOGR - EAST COBB FULTON MSW TO PA","disposalFacilityType":"S03261_LF","disposalFacilityName":"B00073|S03261_LF|S03275_TS|126A_PLT|MSW_RO","feeComment": null,"isCostOnly": false,"commercial":null,"rollOff":{"pricingMethodDisposalCode":"4.0","pricingMethodDisposalDescription":"Adjusted MBP","pricingMethodHaulingCode":"1.0","pricingMethodHaulingDescription":"Market Based Pricing","haulCost":207.01,"haulPrice":null,"disposalCost":45.05,"disposalPrice":null,"estimatedVolumePerHaul":3,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":18.68,"landfillMinutes":13,"transferSiteCode":"S03275_TS","equipmentAvailabilityTypeCode":"TEMP","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":10,"equipmentAdditionalLoadingMinutes":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B00073","masLibrary":"126A_PLT","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of South Atlantic"},"tpMetaData":null,"serviceCharges":[{"code":"CSC_RO_TEMP_OPEN","name":"Container Service Charge","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"D_RO_TEMP_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"}]},"problem":null}';
    private static final String JSON_STEPPED = '{"data":{"priceQuoteIdentifier":"Q12632","costSource":"3PS (41552)","priceSource":"Standard Pricing","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"213264","supplierName":"Action Carting Environmental Svcs","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD006177","wasteStreamCode":"Trash","wasteStreamName":"Trash","equipmentCode":"OT","equipmentName":"Open Top","equipmentUOM":"Tons","materialCode":"T","materialName":"Trash","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"182","zoneName":"RO Trash OT Z1","disposalFacilityType":"Transfer Station","disposalFacilityName":"Transfer Station","commercial":null,"rollOff":{"pricingMethodDisposalCode":"41552","pricingMethodDisposalDescription":"Procured","pricingMethodHaulingCode":"41552","pricingMethodHaulingDescription":"Procured","originalHaulCost":null,"haulCost":225,"haulPrice":261,"originalDisposalCost":null,"disposalCost":null,"disposalPrice":null,"estimatedVolumePerHaul":null,"applyInvoiceFeesToDisposalCharges":null,"applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":null,"landfillMinutes":null,"transferSiteCode":null,"equipmentAvailabilityTypeCode":"PERM","materialClassName":"Trash","equipmentLoadingMinutes":null,"equipmentAdditionalLoadingMinutes":null,"haulRecordId":null,"disposalRecordId":null,"stepDisposals":[{"priceUpTo":"2.00","priceRange":"0 UpTo 2.00","costUpTo":"2.00","costRange":"0 UpTo 2.00","cost":225,"price":261},{"priceUpTo":"4.00","priceRange":"2.00 UpTo 4.00","costUpTo":"4.00","costRange":"2.00 UpTo 4.00","cost":281.25,"price":326.25},{"priceUpTo":"6.00","priceRange":"4.00 UpTo 6.00","costUpTo":"6.00","costRange":"4.00 UpTo 6.00","cost":337.5,"price":391.5},{"priceUpTo":"99.00","priceRange":"6.00 UpTo 99.00","costUpTo":"99.00","costRange":"6.00 UpTo 99.00","cost":450,"price":522}]},"wmMetaData":null,"tpMetaData":{"diversion":0,"scaleAvailability":"No","regulatoryFees":null},"serviceCharges":[{"code":"FU_RO_PERM_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"EX","actionName":"Exclude","cost":null,"costValueType":null,"costUOM":null,"price":null,"priceValueType":null,"priceUOM":null,"serviceChargeRecordId":null},{"code":"ENV_RO_PERM_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":null,"costValueType":null,"costUOM":null,"price":null,"priceValueType":null,"priceUOM":null,"serviceChargeRecordId":null},{"code":"MNT_RO_PERM_OPEN_R","name":"Minimum Tons Recycling","componentTypeCode":"DSP","componentTypeName":"Disposal","actionCode":"EX","actionName":"Exclude","cost":null,"costValueType":null,"costUOM":null,"price":null,"priceValueType":null,"priceUOM":null,"serviceChargeRecordId":null},{"code":"MNT_RO_PERM_OPEN_T","name":"All Other Minimum Tonnage","componentTypeCode":"DSP","componentTypeName":"Disposal","actionCode":"EX","actionName":"Exclude","cost":null,"costValueType":null,"costUOM":null,"price":null,"priceValueType":null,"priceUOM":null,"serviceChargeRecordId":null},{"code":"LF_RO_PERM_OPEN","name":"Landfill Fee","componentTypeCode":"LF","componentTypeName":"Landfill Fee","actionCode":"AL","actionName":"Allow","cost":null,"costValueType":null,"costUOM":null,"price":null,"priceValueType":null,"priceUOM":null,"serviceChargeRecordId":null},{"code":"FF_RO_PERM_OPEN","name":"Franchise Fee","componentTypeCode":"FF","componentTypeName":"Franchise Fee","actionCode":"AL","actionName":"Allow","cost":null,"costValueType":null,"costUOM":null,"price":null,"priceValueType":null,"priceUOM":null,"serviceChargeRecordId":null},{"code":"IF_RO_PERM_OPEN","name":"Inactivity Fee (Monthly or Daily Charge for roll off when no Hauls are performed)","componentTypeCode":"IF","componentTypeName":"Inactivity Fee","actionCode":"EX","actionName":"Exclude","cost":50,"costValueType":"Amount","costUOM":"Month","price":null,"priceValueType":null,"priceUOM":null,"serviceChargeRecordId":null},{"code":"SSF_RO_PERM_OPEN","name":"Snapshot Fee","componentTypeCode":"SSF","componentTypeName":"Snapshot Fee","actionCode":"MR","actionName":"Manual Review","cost":null,"costValueType":null,"costUOM":null,"price":null,"priceValueType":null,"priceUOM":null,"serviceChargeRecordId":null},{"code":"GT_RO_PERM_OPEN","name":"Generator Tax","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"AL","actionName":"Allow","cost":null,"costValueType":null,"costUOM":null,"price":null,"priceValueType":null,"priceUOM":null,"serviceChargeRecordId":null},{"code":"RMO_RO_PERM_OPEN","name":"Recyable Material Offset","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":null,"costValueType":null,"costUOM":null,"price":null,"priceValueType":null,"priceUOM":null,"serviceChargeRecordId":null},{"code":"RCR_RO_PERM_OPEN","name":"Regulatory Cost Recovery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":null,"costValueType":null,"costUOM":null,"price":null,"priceValueType":null,"priceUOM":null,"serviceChargeRecordId":null},{"code":"REM_RO_PERM_OPEN","name":"Container Removal","componentTypeCode":"REM","componentTypeName":"Removal","actionCode":"ADJ","actionName":"Adjust","cost":70,"costValueType":"Amount","costUOM":"Event","price":80.5,"priceValueType":"Amount","priceUOM":null,"serviceChargeRecordId":null},{"code":"D_RO_PERM_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":70,"costValueType":"Amount","costUOM":"Event","price":80.5,"priceValueType":"Amount","priceUOM":null,"serviceChargeRecordId":null}]},"problem":null}';

    @testSetup static void setup(){
        test.startTest();
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        
        User bypassuser = TestDataFactory.createUser(adminProfile);
        bypassuser.FirstName = 'testuser#9999';
        bypassuser.Bypass_Validation__c = true;
        bypassuser.Genesys_Enabled__c = false;
        insert bypassuser;

        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();

        System.runAs(usr){
            List<Opportunity> oppList = new List<Opportunity>();
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            List<Product2> prdList = new List<Product2>();    
            list<Account> acclist = new List<Account>();

            Account accParent = new Account(Name = 'Parent Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='5678',
             RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true); 
            insert accParent;

            Account acc = new Account(Name = Constant_Util.KEYWORD_TEST, phone = '9999999999', OwnerId = usr.id, AccountNumber='1234',
                RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, ParentId = accParent.Id, Type ='Location');
            acclist.add(acc);

            Account vendorAcc = new Account(Name = 'WM Vendor Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='4321',
             RecordTypeid = TestDataFactory.getRecordType('Vendor','Account'));
            acclist.add(vendorAcc);

            Database.insert(acclist);

            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Chicago';
            locationlist[0].IsPricingEligible__c = true;
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);

            //Inserting Account Position (Location_Position)
            Account_Position__c accLocPosition = new Account_Position__c(AccountId__c = acclist[0].Id,
            Container_Position__c = 'Test 2',
            AlternatePostalCode__c = '1234',
            AlternateCity__c = 'Test City',
            AlternateCountry__c = 'USA',
            AlternateState__c = 'NY',
            AlternateStreet__c = 'Day Hill Road');
            insert accLocPosition;

            //Inserting Case
            Case newServiceCase = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0),usr,locationlist.get(0)); 
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

            oppList.addAll(TestDataFactory.createOpportunity(1,'TestOpportunityTest',newServiceCase.Id,newServiceCase.Case_Sub_Type__c, newServiceCase.Location__c));
            insert oppList;
            System.Debug('@@@~Create Opp : ' + oppList);
            
            quoteList.addAll(TestDataFactory.createQuoteRecords(oppList,acclist[0],conlist[0],Date.today(),false,true));
            quoteList[0].SBQQ__ShippingStreet__c = 'ABC';
            quoteList[0].SBQQ__ShippingCity__c = 'Test1';
            quoteList[0].SBQQ__ShippingCountry__c = 'USA';
            quoteList[0].SBQQ__ShippingState__c = 'NY';
            quoteList[0].SBQQ__ShippingPostalCode__c = '1234';
            quoteList[0].Duration__c = 'Permanent';
            insert quoteList;

            Product2 prodOpenTop = TestDataFactory.createProduct('Open Top',ROLLOFF, 'OT');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prdList.add(prodOpenTop);

            Product2 prodCompactor = TestDataFactory.createProduct('Compactor',EQUIPMENT, 'CMP');
            prodCompactor.Is_Pricing_Eligible__c = true;
            prdList.add(prodCompactor);

            Product2 prodDumpster = TestDataFactory.createProduct('Dumpster',COMMERCIAL, 'DMP');
            prodDumpster.Is_Pricing_Eligible__c = true;
            prdList.add(prodDumpster);

            Product2 prodNull= TestDataFactory.createProduct('Error',EQUIPMENT,'ERR');
            prodNull.Is_Pricing_Eligible__c = true;
            prdList.add(prodNull);

            Product2 prodPickup= TestDataFactory.createProduct('Pickup',SERVICES,'PCK');
            prdList.add(prodPickup);

            Product2 prodExPickup= TestDataFactory.createProduct('Extra Pickup',SERVICES,'PCK');
            prdList.add(prodExPickup);

            Product2 prodHaul= TestDataFactory.createProduct('Haul',SERVICES,'H');
            prdList.add(prodHaul);

            Product2 prodDisposal= TestDataFactory.createProduct('Disposal',SERVICES,'DSP');
            prdList.add(prodDisposal);

            Product2 prodDelivery= TestDataFactory.createProduct('Delivery','Surcharges and Fees','DLV');
            prdList.add(prodDelivery);
            
            Product2 prodLandfill= TestDataFactory.createProduct('Landfill Fee','Surcharges and Fees','LF');
            prdList.add(prodLandfill);

            Product2 prodRecycling= TestDataFactory.createProduct('Recycling','RollOff','REC');
            prdList.add(prodRecycling);

            Product2 prodTrash = TestDataFactory.createProduct('Trash','Waste Stream','T');
            prodTrash.Is_Pricing_Eligible__c = true;
            prdList.add(prodTrash);

            Product2 prodCardboard = TestDataFactory.createProduct('Cardboard','Waste Stream','C');
            prodCardboard.Is_Pricing_Eligible__c = true;
            prdList.add(prodCardboard);

            Database.insert(prdList);

            //RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;

            List<SBQQ__QuoteLine__c> qlHdr = new List<SBQQ__QuoteLine__c>();
            //Bundle 1 - Open Top
            SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOT.SBQQ__Bundle__c = TRUE;
            qlOT.SBQQ__RequiredBy__c = null;
            qlOT.Vendor__c = vendorAcc.Id;
            qlOT.SBQQ__Number__c = 1;
            qlOT.Location_Position_Name__c = accLocPosition.Id;
            qlHdr.add(qlOT);

            SBQQ.TriggerControl.disable();
            try 
            {
                insert qlHdr;
            } 
            finally {
            SBQQ.TriggerControl.enable();
            }

            List<SBQQ__QuoteLine__c> qlChild = new List<SBQQ__QuoteLine__c>();

            //Open Top Child Quote Line  --- Start
            SBQQ__QuoteLine__c qlOTT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodTrash,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOTT.SBQQ__RequiredBy__c = qlOT.Id;
            qlOTT.SBQQ__Number__c = 2;
            //qlOTT.Vendor__c = vendorAcc.Id;
            qlChild.add(qlOTT);

            SBQQ__QuoteLine__c qlHaul = TestDataFactory.createQuoteLineRecords(quoteList[0],prodHaul,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlHaul.SBQQ__RequiredBy__c = qlOT.Id;
            qlHaul.SBQQ__Number__c = 3;
            //qlHaul.Vendor__c = vendorAcc.Id;
            //Changes related to SDT-48584
            qlHaul.Pricing_API_Method__c = 'Modeled';
            qlChild.add(qlHaul);

            SBQQ__QuoteLine__c qlDisposal = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDisposal,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDisposal.SBQQ__RequiredBy__c = qlOT.Id;
            qlDisposal.SBQQ__Number__c = 4;
            //qlDisposal.Vendor__c = vendorAcc.Id;
            qlChild.add(qlDisposal);

            SBQQ__QuoteLine__c qlDelivery = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDelivery,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDelivery.SBQQ__RequiredBy__c = qlOT.Id;
            qlDelivery.SBQQ__Number__c = 5;
            //qlDelivery.Vendor__c = vendorAcc.Id;
            qlChild.add(qlDelivery);
            //Changes related to SDT-48584
            SBQQ__QuoteLine__c qlRecycling = TestDataFactory.createQuoteLineRecords(quoteList[0],prodRecycling,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlRecycling.SBQQ__RequiredBy__c = qlOT.Id;
            qlRecycling.SBQQ__Number__c = 6;
            //qlDelivery.Vendor__c = vendorAcc.Id;
            qlChild.add(qlRecycling);
            //Open Top Child Quote Line  --- End

            //Database.insert(qlChild);      
            SBQQ.TriggerControl.disable();
            try 
            {
                Database.insert(qlChild);
            } 
            finally {
            SBQQ.TriggerControl.enable();
            }
            //System.debug('New Quote Line ' + qlChild);     

            List<Pricing_Request__c> createPRList = new List<Pricing_Request__c>();

            //Open Top Valid Data - Asset Management
            Pricing_Request__c pReq1 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AM', '', JSON_VALID_ROLLOFF_DATA, usr);
            pReq1.Service_City__c = 'Test OT AM';
            pReq1.Cost_Source__c = 'WM US';//SDT46922
            createPRList.add(pReq1);

            RecurrsiveTriggerHandler.invokeValidationforPricing = false;
            Database.insert(createPRList);

        }
        test.stoptest();
    }
    @isTest public static void testprocessPricingRequest() 
    {
    	User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>();
            quoteLine = [Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quote.id];
            Pricing_Request__c pReq = [Select Id,Quote__c from Pricing_Request__c limit 1];
            
            Test.startTest();
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = quoteLine[0].id;
            pReq.Vendor_Code__c = venId.Id;
            pReq.Zone_Type__c = 'Open Market';
            update pReq;
            
            List<PricingRequestSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestSTPProcess.QuotePricingWrapper>();
            wrapperList = PricingRequestSTPProcess.processPricingRequest(quote.Id , True);
            
            system.assert(wrapperList != null);
            Test.stopTest();
        }
    }
    
    @isTest public static void testsaveProcuredStatus() 
    {
    	User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                                                                                      	Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                                                                                      	SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                                                                                      	SBQQ__RequiredBy__c
																						FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id];
            
            Test.startTest();
            PricingRequestSTPProcess.saveProcuredStatus(quote.Id);
            SBQQ__Quote__c updatedQuote = [Select Id, QuoteProcuredStatus__c from SBQQ__Quote__c Where Id =:quote.Id];
            system.assert(updatedQuote.QuoteProcuredStatus__c != null);
            Test.stopTest();
        }
    }
    @isTest public static void testSteppedPrice() 
    {
    	User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c quoteLine = [Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quote.id and SBQQ__RequiredBy__c = null and SBQQ__ProductCode__c = 'OT'  limit 1];
            Pricing_Request__c pReq = [Select Id,Quote__c from Pricing_Request__c limit 1];
            
            Test.startTest();
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = quoteLine.id;
            pReq.APIRequestOutput__c = JSON_STEPPED;
            pReq.Zone_Type__c = 'Open Market';
            update pReq;
            
            List<PricingRequestSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestSTPProcess.QuotePricingWrapper>();
            wrapperList = PricingRequestSTPProcess.processPricingRequest(quote.Id , True);
            
            system.assert(wrapperList != null);
            Test.stopTest();
        }
    }
    @isTest public static void testCloseMarketWMF() 
    {
        Test.startTest();
    	User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c quoteLine = [Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quote.id and SBQQ__RequiredBy__c = null and SBQQ__ProductCode__c = 'OT'  limit 1];
            Pricing_Request__c pReq = [Select Id,Quote__c from Pricing_Request__c limit 1];
            
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = quoteLine.id;
            pReq.APIRequestOutput__c = JSON_WM_FRANCHISE;
            pReq.Zone_Type__c = 'wm franchise';
            update pReq;
            
            List<PricingRequestSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestSTPProcess.QuotePricingWrapper>();
            wrapperList = PricingRequestSTPProcess.processPricingRequest(quote.Id , false);
            
            system.assert(wrapperList != null);
            
        }
        Test.stopTest();
    }
    @isTest public static void testCloseMarketCompitetor() 
    {
        Test.startTest();
    	User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c quoteLine = [Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quote.id and SBQQ__RequiredBy__c = null and SBQQ__ProductCode__c = 'OT'  limit 1];
            //Changes related to SDT-48584
            Pricing_Request__c pReq = [Select Id,Quote__c,Case__c from Pricing_Request__c limit 1];
            
            
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = quoteLine.id;
            pReq.APIRequestOutput__c = JSON_COMPITITOR;
            pReq.Zone_Type__c = 'competitor';
            update pReq;
            
            List<PricingRequestSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestSTPProcess.QuotePricingWrapper>();
            wrapperList = PricingRequestSTPProcess.processPricingRequest(quote.Id , false);
            
            system.assert(wrapperList != null);

            //addition to increase coverage - getQuoteStatusByCase()
            try {
                PricingRequestSTPProcess.getQuoteStatusByCase(pReq.Case__c);
            }
            catch(exception ex) {
                system.debug(ex.getMessage());
            }
            
        }
        Test.stopTest();
    }
    @isTest public static void testCloseMarketPDP() 
    {
    	User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c quoteLine = [Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quote.id and SBQQ__RequiredBy__c = null and SBQQ__ProductCode__c = 'OT'  limit 1];
            Pricing_Request__c pReq = [Select Id,Quote__c from Pricing_Request__c limit 1];
            
            Test.startTest();
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = quoteLine.id;
            pReq.APIRequestOutput__c = JSON_PDPRICING;
            pReq.Zone_Type__c = 'pre-determined pricing';
            update pReq;
            
            List<PricingRequestSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestSTPProcess.QuotePricingWrapper>();
            wrapperList = PricingRequestSTPProcess.processPricingRequest(quote.Id , false);
            
            system.assert(wrapperList != null);
            Test.stopTest();
        }
    }
    @isTest public static void testCloseMarketTPA() 
    {
    	User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c quoteLine = [Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quote.id and SBQQ__RequiredBy__c = null and SBQQ__ProductCode__c = 'OT'  limit 1];
            Pricing_Request__c pReq = [Select Id,Quote__c from Pricing_Request__c limit 1];
            
            Test.startTest();
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = quoteLine.id;
            pReq.APIRequestOutput__c = JSON_TPAGREEMENT;
            pReq.Zone_Type__c = 'third -party agreement';
            update pReq;
            
            List<PricingRequestSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestSTPProcess.QuotePricingWrapper>();
            wrapperList = PricingRequestSTPProcess.processPricingRequest(quote.Id , false);
            
            system.assert(wrapperList != null);
            Test.stopTest();
        }
    }
    @isTest public static void testError() 
    {
    	User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c quoteLine = [Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quote.id and SBQQ__RequiredBy__c = null and SBQQ__ProductCode__c = 'OT'  limit 1];
            Pricing_Request__c pReq = [Select Id,Quote__c from Pricing_Request__c limit 1];
            
            Test.startTest();
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = quoteLine.id;
            pReq.APIRequestOutput__c = JSON_INVALID_DATA_PROS;
            pReq.isAPIResult__c = false;
            //pReq.Zone_Type__c = 'wm franchise';
            update pReq;
            
            List<PricingRequestSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestSTPProcess.QuotePricingWrapper>();
            wrapperList = PricingRequestSTPProcess.processPricingRequest(quote.Id , True);
            
            system.assert(wrapperList != null);
            Test.stopTest();
        }
    }
    @isTest public static void testprocessPricingRequestfalse() 
    {
    	User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>();
            quoteLine = [Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quote.id];
            Pricing_Request__c pReq = [Select Id,Quote__c from Pricing_Request__c limit 1];
            
            Test.startTest();
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = quoteLine[0].id;
            pReq.Vendor_Code__c = venId.Id;
            pReq.Zone_Type__c = 'Open Market';
            update pReq;
            
            List<PricingRequestSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestSTPProcess.QuotePricingWrapper>();
            wrapperList = PricingRequestSTPProcess.processPricingRequest(quote.Id , false);
            
            system.assert(wrapperList != null);
            Test.stopTest();
        }
    }
    @isTest public static void testgetQuoteProductDetail() 
    {
    	User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>();
            quoteLine = [Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quote.id];
            Pricing_Request__c pReq = [Select Id,Quote__c from Pricing_Request__c limit 1];
            
            Test.startTest();
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = quoteLine[0].id;
            pReq.Vendor_Code__c = venId.Id;
            pReq.Zone_Type__c = 'Open Market';
            update pReq;
            
            Map<Id, Boolean> bundleStatusMap = new Map<Id, Boolean>();
            bundleStatusMap = PricingRequestSTPProcess.getQuoteProductDetail(quote.Id);
            
            system.assert(bundleStatusMap != null);
            Test.stopTest();
        }
    }
    @isTest public static void testquoteLineProcessRecycling() 
    {
    	User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>();
            quoteLine = [Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quote.id];
            Pricing_Request__c pReq = [Select Id,Quote__c from Pricing_Request__c limit 1];
            
            
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = quoteLine[0].id;
            pReq.Vendor_Code__c = venId.Id;
            pReq.Zone_Type__c = 'Open Market';
            pReq.APIRequestOutput__c  = JSON_VALID_ROLLOFF_DATA_REC;
            update pReq;
            
            Test.startTest();
            
            List<PricingRequestSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestSTPProcess.QuotePricingWrapper>();
            wrapperList = PricingRequestSTPProcess.processPricingRequest(quote.Id , True);
            
            system.assert(wrapperList != null);
            Test.stopTest();
        }
    }
    
    //test
    @isTest public static void getPriceAssetErrorMessageIfAnyTest() {
        test.StartTest();
        Opportunity opp = [Select Id FROM Opportunity limit 1];
        Product2 prodOpenTop = [Select Id, Name FROM Product2 WHERE Name =: 'Open Top' LIMIT 1];
        SBQQ__Quote__c newQuote = [Select Id, SBQQ__Account__c, SBQQ__StartDate__c FROM SBQQ__Quote__c limit 1];
        //creating quote line
        //Bundle 1 - Open Top
        SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(newQuote,prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
        qlOT.SBQQ__Bundle__c = TRUE;
        qlOT.SBQQ__RequiredBy__c = null;
        //qlOT.Vendor__c = vendorAcc.Id;
        qlOT.SBQQ__Number__c = 1;
		qlOT.ProcurementErrorMessage__c = 'test error message';
        qlOT.BundleProcuredStatus__c = 'NO';
        qlOT.Pricing_Error__c = 'OtherPricingError';//for assertion fix S11
        insert qlOT;
        
        list<PricingRequestSTPProcess.PricingError> priceErrorWrapperlist = PricingRequestSTPProcess.getPriceAssetErrorMessageIfAny(newQuote.Id);
        test.stopTest();
        System.assert(priceErrorWrapperlist.size() > 0);
    }
    
    @isTest public static void getBypassPriceReviewTest() {
        test.startTest();
        Boolean byPass = PricingRequestSTPProcess.getBypassPriceReview('WM Franchise', 'WM', null);
        //System.assertEquals(byPass,true);
        test.stopTest();
    }
    //SDT 46922
    @isTest public static void testExhibitHaulCost() 
    {
        Test.startTest();
    	User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,Cost_Source__c,Quote__c from Pricing_Request__c limit 1];
            
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                                                                                      	Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                                                                                      	SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                                                                                      	SBQQ__RequiredBy__c,Pricing_Request__r.Cost_Source__c
																						FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id];
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.SBQQ__UnitCost__c = 12000000;
                ql.Pricing_Request__c = pReq.id;
                //ql.Pricing_Request__r.Cost_Source__c = 'WM US';
            }
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.APIRequestOutput__c = JSON_VALID_ROLLOFF_DATA;
            pReq.Customer_Price_Type__c = Pricing_Constant_Util.EXHIBIT_PRICING;
            
            update pReq;
            
            update list_QLI;
            PricingRequestSTPProcess.saveProcuredStatus(quote.Id);
            SBQQ__Quote__c updatedQuote = [Select Id, QuoteProcuredStatus__c from SBQQ__Quote__c Where Id =:quote.Id];
            system.assert(updatedQuote.QuoteProcuredStatus__c != null);
            Test.stopTest();
    }
    }
}