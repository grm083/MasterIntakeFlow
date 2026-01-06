@isTest(seeAllData =false)
public class PricingRequestFieldsMetadataTest {
    
    //SDT-48584

    @isTest
    static void PricingRequestFieldsMetadataWrapperTest(){
        string jsonData = '{' +
            '"data": {' +
                '"priceQuoteIdentifier": "PQ12345",' +
                '"lineOfBusiness": "Commercial",' +
                '"priceTypeCode": "PTC001",' +
                '"customerCode": "CUST001",' +
                '"customerName": "John Doe Inc.",' +
                '"locationCode": "LOC001",' +
                '"serviceBaselineId": "SB001",' +
                '"equipmentCode": "EQ001",' +
                '"equipmentName": "Dumpster",' +
                '"equipmentSizeCode": "SZ001",' +
                '"equipmentSizeName": "10 Yard",' +
                '"materialCode": "MAT001",' +
                '"materialName": "Construction Debris",' +
                '"countryCode": "US",' +
                '"currencyCode": "USD",' +
                '"equipmentAvailabilityCode": "AVAIL001",' +
                '"overridableEquipmentSizeCode": "OVRSZ001",' +
                '"overridableEquipmentSizeName": "Override 10 Yard",' +
                '"suppliers": [{' +
                    '"costSource": "Manual",' +
                    '"priceSource": "System",' +
                    '"supplierCode": "SUP001",' +
                    '"supplierName": "Waste Supplier",' +
                    '"contractType": "Standard",' +
                    '"wasteStreamCode": "WS001",' +
                    '"wasteStreamName": "Construction Waste",' +
                    '"equipmentUOM": "EA",' +
                    '"zoneCode": "Z001",' +
                    '"zoneName": "Zone 1",' +
                    '"zoneDescription": "Primary zone",' +
                    '"zoneNotes": "High demand area",' +
                    '"disposalFacilityType": "Landfill",' +
                    '"disposalFacilityName": "Central Landfill",' +
                    '"isCostOnly": false,' +
                    '"commercial": {' +
                        '"pricingMethodCode": "PMC001",' +
                        '"pricingMethodCodeDescription": "Standard Pricing",' +
                        '"pricingMethodPickupDescription": "Per Pickup",' +
                        '"cost": 100.0,' +
                        '"price": 150.0,' +
                        '"unitCost": 10.0,' +
                        '"unitPrice": 15.0,' +
                        '"extraPickupCost": 20.0,' +
                        '"extraPickupPrice": 25.0,' +
                        '"pickupRecordId": 101,' +
                        '"extraPickupRecordId": 102' +
                    '},' +
                    '"rollOff": {' +
                        '"pricingMethodDisposalCode": "PMD001",' +
                        '"pricingMethodDisposalDescription": "Disposal Rate",' +
                        '"pricingMethodHaulingCode": "PMH001",' +
                        '"pricingMethodHaulingDescription": "Haul Rate",' +
                        '"haulCost": 200.0,' +
                        '"haulPrice": 250.0,' +
                        '"disposalCost": 80.0,' +
                        '"disposalPrice": 120.0,' +
                        '"estimatedVolumePerHaul": 3.5,' +
                        '"applyInvoiceFeesToDisposalCharges": "Yes",' +
                        '"applyInvoiceFeesToRentalCharges": "No",' +
                        '"transferSiteCode": "TSC001",' +
                        '"equipmentAvailabilityTypeCode": "EATC001",' +
                        '"materialClassName": "Debris",' +
                        '"haulRecordId": 201,' +
                        '"disposalRecordId": 202,' +
                        '"stepDisposals": [{' +
                            '"priceUpTo": 100.0,' +
                            '"priceRange": "0-100",' +
                            '"costUpTo": 80.0,' +
                            '"costRange": "0-80",' +
                            '"cost": 75.0,' +
                            '"price": 95.0' +
                        '}]' +
                    '},' +
                    '"serviceCharges": [{' +
                        '"code": "SC001",' +
                        '"name": "Pickup Charge",' +
                        '"componentCode": "CMP001",' +
                        '"componentName": "Pickup",' +
                        '"actionCode": "ACT001",' +
                        '"actionName": "Pickup",' +
                        '"cost": 50.0,' +
                        '"costValueType": "Fixed",' +
                        '"costUOM": "EA",' +
                        '"price": 75.0,' +
                        '"priceValueType": "Fixed",' +
                        '"priceUOM": "EA"' +
                    '}],' +
                    '"wmMetaData": {' +
                        '"businessUnit": "BU001",' +
                        '"masLibrary": "MAS001",' +
'"francisePricingLink": "http://example.com/franchise",' +
'"greenPagesLink": "http://example.com/green",' +
                        '"marketAreaCode": "MAC001",' +
                        '"marketAreaName": "West Coast",' +
                        '"facilityId": "FAC001",' +
                        '"facilityName": "Main Facility",' +
                        '"siteId": "SITE001",' +
                        '"siteName": "Main Site",' +
                        '"masCustomerUniqueId": "MAS-CUST-001",' +
                        '"targetTrackingId": "TRACK001"' +
                    '},' +
                    '"tpMetaData": {' +
                        '"zoneRank": 1,' +
                        '"feeComment": "Regulatory fees apply",' +
                        '"diversion": 0.75,' +
                        '"scaleAvailability": "Available",' +
                        '"regulatoryFees": [{' +
                            '"name": "Environmental Fee",' +
                            '"cost": 10.0,' +
                            '"percentageBasedOrCompounded": 1,' +
                            '"appliesToDisposal": "Yes",' +
                            '"appliesToHaul": "No",' +
                            '"appliesToRental": "Yes",' +
                            '"basis": "Per Ton",' +
                            '"uom": "TON",' +
                            '"order": 1,' +
                            '"comment": "Mandatory fee"' +
                        '}]' +
                    '},' +
                    '"messages": [{' +
                        '"code": "MSG001",' +
                        '"description": "Supplier data validated"' +
                    '}]' +
                '}]' +
            '},' +
            '"problem": {' +
                '"title": "Validation Error",' +
                '"status": 400,' +
                '"errors": [{' +
                    '"code": "ERR001",' +
                    '"message": "Invalid price code"' +
                '}]' +
            '}' +
        '}';
        
        PricingRequestFieldsMetadata wrapper =  PricingRequestFieldsMetadata.parse(jsonData);
        
        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.data);
        System.assertEquals('PQ12345', wrapper.data.priceQuoteIdentifier);
        
        
        PricingRequestFieldsMetadata.suppliers sup = wrapper.data.suppliers[0];
        System.assertEquals('Waste Supplier', sup.supplierName);
        
        
        System.assertEquals('PMC001', sup.commercial.pricingMethodCode);
        System.assertEquals(150.0, sup.commercial.price);
        
        
        System.assertEquals('PMD001', sup.rollOff.pricingMethodDisposalCode);
        System.assertEquals(120.0, sup.rollOff.disposalPrice);
        System.assertEquals(1, sup.rollOff.stepDisposals.size());
        System.assertEquals('0-100', sup.rollOff.stepDisposals[0].priceRange);
        
        
        System.assertEquals('SC001', sup.serviceCharges[0].code);
        System.assertEquals(75.0, sup.serviceCharges[0].price);
        
        
        System.assertEquals(1, sup.tpMetaData.regulatoryFees.size());
        System.assertEquals('Environmental Fee', sup.tpMetaData.regulatoryFees[0].name);
        
        
        System.assertEquals('MSG001', sup.messages[0].code);
        
        
        System.assertEquals('BU001', sup.wmMetaData.businessUnit);
        
        
        System.assertEquals('Validation Error', wrapper.problem.title);
        System.assert(wrapper.isError(), 'isError should be true');
        System.assertEquals('Invalid price code', wrapper.problem.errors[0].message);
        
         }    

}