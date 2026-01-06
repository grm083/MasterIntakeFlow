import { LightningElement, track, wire, api } from "lwc";
import { registerListener, unregisterAllListeners, fireEvent } from "c/pubsub";
import getRequestNumber from "@salesforce/apex/PricingRequest.getRequestNumber";
import { CurrentPageReference } from "lightning/navigation";

import WM_Franchise from '@salesforce/label/c.WM_Franchise';
import Competitor from '@salesforce/label/c.Competitor';
import Pre_Determined_Pricing from '@salesforce/label/c.Pre_Determined_Pricing';
import Third_Party_Agreement from '@salesforce/label/c.Third_Party_Agreement';
import Minimum_Tons_Recycling from '@salesforce/label/c.Minimum_Tons_Recycling';
import All_Other_Minimum_Tonnage from '@salesforce/label/c.All_Other_Minimum_Tonnage';
import Price_Per_Haul from '@salesforce/label/c.Price_Per_Haul';
import Disposal from '@salesforce/label/c.Disposal';
import Exclude from '@salesforce/label/c.Exclude';
import Percent from '@salesforce/label/c.Percent';
import lblName from '@salesforce/label/c.Name';
import lblCost from '@salesforce/label/c.Cost';
import lblPercent_Base_or_Compounded from '@salesforce/label/c.Percent_Base_or_Compounded';
import lblApplies_to_Disposal from '@salesforce/label/c.Applies_to_Disposal';
import lblApplies_to_Haul from '@salesforce/label/c.Applies_to_Haul';
import lblApplies_to_Rental from '@salesforce/label/c.Applies_to_Rental';
import lblBasis from '@salesforce/label/c.Basis';
import lblUOM from '@salesforce/label/c.UOM';
import lblOrder from '@salesforce/label/c.Order';
import AdministratorMessage from '@salesforce/label/c.AdministratorMessage';
import errorHead from '@salesforce/label/c.Pricing_Error_Head';
import outputMessageDetails from '@salesforce/label/c.Pricing_OutPut_Msg_Details';
import message from '@salesforce/label/c.Pricing_Message';
import market from '@salesforce/label/c.Pricing_Market';
import zoneName from '@salesforce/label/c.Pricing_Zone_Name';
import zoneCompetitorMsg from '@salesforce/label/c.zoneCompetitorMsg';
import zoneDescription from '@salesforce/label/c.Pricing_Zone_desc';
import franchiseLink from '@salesforce/label/c.Pricing_Franchise_Link';
import greenPageLink from '@salesforce/label/c.Pricing_GreenPage_Link';
import notes from '@salesforce/label/c.Pricing_Notes';
import pricingRequestNumber from '@salesforce/label/c.Pricing_Request_No';
import serviceDetails from '@salesforce/label/c.Pricing_Service_Details';
import quoteIdentifier from '@salesforce/label/c.Pricing_Quote_Identifier';
import vendorId from '@salesforce/label/c.Pricing_Vendor_Id';
import vendorCommercial from '@salesforce/label/c.Pricing_VendorId_Commercial';
import sourceCode from '@salesforce/label/c.Pricing_Source_Code';
import vendorName from '@salesforce/label/c.Pricing_VendorName';
import vendorNameCommercial from '@salesforce/label/c.Pricing_VendorName_Commercial';
import quantity from '@salesforce/label/c.Pricing_Quantity';
import rateTypeHaul from '@salesforce/label/c.Pricing_RateType_Haul';

import rateTypePickup from '@salesforce/label/c.Pricing_RateType_Pickup';
import containerCode from '@salesforce/label/c.Pricing_ContainerCode';
import disposition from '@salesforce/label/c.Pricing_Disposition';
import businessUnit from '@salesforce/label/c.Pricing_Business_Unit';
import substitutedContainerCode from '@salesforce/label/c.Pricing_Substituted_ContainerCode';
import disposalFacility from '@salesforce/label/c.Pricing_Disposal_Facility';
import wastStream from '@salesforce/label/c.Pricing_Waste_Stream';
import diversionPercentage from '@salesforce/label/c.Pricing_Diversion_Percentage';
import estTonPerHaul from '@salesforce/label/c.Pricing_EST_Tons_PerHaul';
import frequencyType from '@salesforce/label/c.Pricing_Frequency_Type';
import isScaleAvailable from '@salesforce/label/c.Pricing_IsScale_Available';
import minimuTons from '@salesforce/label/c.Pricing_Minimum_Tons';
import frequencyCount from '@salesforce/label/c.Pricing_Frequency_Count';
import vendorcomments from '@salesforce/label/c.Pricing_Vendor_Comments';
import customerType from '@salesforce/label/c.Pricing_Customer_Type';
import baselineId from '@salesforce/label/c.Pricing_BaselineId';
import marketAreaCode from '@salesforce/label/c.Pricing_Market_AreaCode';
import haulRecId from '@salesforce/label/c.Pricing_Haul_RecId';
import pickupRecId from '@salesforce/label/c.Pricing_Pickup_RecId';
import masLibrary from '@salesforce/label/c.Pricing_MAS_Library';

import disposalRecId from '@salesforce/label/c.Pricing_Disposal_RecId';
import extraPickupRecId from '@salesforce/label/c.Pricing_Extra_Pickup_RecId';
import marketAreaName from '@salesforce/label/c.Pricing_Market_AreaName';
import facilityId from '@salesforce/label/c.Pricing_Facility_Id';
import masUniqId from '@salesforce/label/c.Pricing_MAS_Unique_Id';
import siteId from '@salesforce/label/c.Pricing_Site_Id';
import pricingDetails from '@salesforce/label/c.PricingDetails';
import costSteps from '@salesforce/label/c.Pricing_Cost_Steps';
import UOM from '@salesforce/label/c.Pricing_UOM';
import unitCost from '@salesforce/label/c.Pricing_Unit_Cost';
import priceSteps from '@salesforce/label/c.Pricing_Price_Steps';
import unitPrice from '@salesforce/label/c.Pricing_Unit_Price';
import priceRatePerHaul from '@salesforce/label/c.Pricing_Price';
import pickup from '@salesforce/label/c.Pricing_Pickup';
import disposal from '@salesforce/label/c.Pricing_Disposal';
import extraPickup from '@salesforce/label/c.Pricing_Extra_Pickup';
import systemInformation from '@salesforce/label/c.Pricing_System_Info';
import createBy from '@salesforce/label/c.Pricing_Created_By';
import createdDate from '@salesforce/label/c.Pricing_Created_Date';
import zoneFranchiseMsg from '@salesforce/label/c.zoneFranchiseMsg';
import lblMarket_WM_Franchise from '@salesforce/label/c.Market_WM_Franchise';
import lblMarket_Non_WM_Franchise from '@salesforce/label/c.Market_Non_WM_Franchise';
import lblMarket_WM_Pre_Determined_Pricing from '@salesforce/label/c.Market_WM_Pre_Determined_Pricing';
import lblMarket_WM_Third_Party_Agreement from '@salesforce/label/c.Market_WM_Third_Party_Agreement';


export default class PricingMultiVendorOutputScreen extends LightningElement {
  @api recordid;
  @api pricingresponserecord;
  createddate;
  createdby;
  requestno;
  quantity;
  frequencycount;
  frequencytype;
  lineofbusiness;
  pricingthresholdlist;
  serviceoccurrencetype;
  assetcall = true;
  @track getPriceRepsonse = [];
  @track allVendors = [];
  @track stepDisposables = [];
  @track regulatoryFeeDetails = [];
  @track displayStepDisposals = [];
  @track serviceCharges = [];
  @track singleVendorServiceCharges = [];
  @track serviceChargesPerVendor = [];
  @track commercialdata = [];
  @track prWrapperReuslt =[];
  @track responseRecord;
  @track response;
  @track isPaginationRequired = true;
  @track isPriceChangeRequest = false;
  @track serviceBaselineId;
  @wire(CurrentPageReference) pageRef;
  CreatedBy;
  CreatedDate;
  vendorSize = 0;
  priceQuoteIdentifier;
  containerCode;
  ratrTypeHauling;
  isRollOff=false;
  masLibrary;
  marketAreaCode;
  marketAreaName;
  masUniqId;
  siteId;
  fecilityId;
  APIErrorMsg;
  isAPIError = false;
  showSpinner = false;
  minimumTons;
  rateTypePickup;
  messageDetails;
  businessUnit;
  pickupRecordId;
  extraPickupRecordId;
  pricingMethodHaulingDescription
  pricingMethodDisposalDescription;
  haulRecordId;
  overridableEquipmentSizeCode;
  diversion;
  scaleAvailability;
  estimatedVolumePerHaul;
  disposalRecordId;
  feeComment;
  zoneRank;
  isMessageValue = false;
  isCostOnly= false;
  showMessage;
  pricingMinThreshold;
  pricingMaxThreshold;
  pricePerHaul;
  disposalCost;
  currencyCode;
  costUOM;
  priceUOM;
  thresholdMsg;
  isThresholdMsg = false;
  apiContractType;
  outputmsg;
  outputMarket;
  zoneName;
  zoneDescription;
  zoneNote;
  francisePricingLink;
  greenPagesLink;
  isfranchisePRLink = false;
  isGreenPagePRLink = false;
  isOutPutMsg = false;
  extraPickupCost;
  extraPickupPrice;
  pickupUnitPrice;
  pickupUnitCost;
  isRegulatoryFee = false;
  isrfdComment = false;
  extraPickupCostSymbol;
  extraPickupPriceSymbol;
  pickupCostSymbol;
  pickupPriceSymbol;
  messages;
  costSource;
  haulCost;
  haulPrice;


  exclude = 'Exclude';
  weelInstalCharge = 'wheels installation charge';
  lockMonthlyCharge = 'locks - monthly charge';
  lockInstallation = 'lock installation charge';
  managementFee = 'management fee';
  relocation = 'relocation';
  inactivityFee = 'inactivity fee';
  containerRemoval = 'container removal';
  trip = 'trip';
  containerServiceCharges = 'container service charge';
  delevery = 'delivery';
  regulatoryCostrecovery = 'regulatory cost recovery';
  environmentalFee = 'environmental fee';
  fuelFee = 'fuel fee';
  commercial = 'Commercial';
  onCall = 'On-Call';
  rollOff = 'Rolloff';
  exibitPricing = 'Exhibit Pricing';
  exibitCostPricing = 'Exhibit Cost Pricing';
  systemGenarated = 'System Generated';
  weelsMonthlyCharges = 'wheels - monthly charge';
  noCostPriceMsg = 'No cost/price information available';
  nozoneErrorCode = "ER60";            
  costOnlyMessage='Please Note: This customer is not eligible for automated pricing. Response is COST ONLY.';


  label = {
    WM_Franchise,
    Competitor,
    Pre_Determined_Pricing,
    Third_Party_Agreement,
    Minimum_Tons_Recycling,
    All_Other_Minimum_Tonnage,
    Price_Per_Haul,
    Disposal,
    Exclude,
    Percent,
    lblName,
    lblCost,
    lblPercent_Base_or_Compounded,
    lblApplies_to_Disposal,
    lblApplies_to_Haul,
    lblApplies_to_Rental,
    lblBasis,
    lblUOM,
    lblOrder,
    AdministratorMessage,
    errorHead,
    outputMessageDetails,
    message,
    market,
    zoneName,
    zoneDescription,
    franchiseLink,
    greenPageLink,
    notes,
    pricingRequestNumber,
    serviceDetails,
    quoteIdentifier,
    vendorId,
    vendorCommercial,
    sourceCode,
    vendorName,
    vendorNameCommercial,
    quantity,
    rateTypeHaul,
    rateTypePickup,
    containerCode,
    disposition,
    businessUnit,
    substitutedContainerCode,
    disposalFacility,
    wastStream,
    diversionPercentage,
    estTonPerHaul,
    frequencyType,
    isScaleAvailable,
    minimuTons,
    frequencyCount,
    vendorcomments,
    customerType,
    baselineId,
    marketAreaCode,
    haulRecId,
    pickupRecId,
    masLibrary,
    disposalRecId,
    extraPickupRecId,
    marketAreaName,
    facilityId,
    masUniqId,
    siteId,
    pricingDetails,
    costSteps,
    UOM,
    unitCost,
    priceSteps,
    unitPrice,
    priceRatePerHaul,
    pickup,
    disposal,
    extraPickup,
    systemInformation,
    createBy,
    createdDate,
    lblMarket_WM_Franchise,
    lblMarket_Non_WM_Franchise,
    lblMarket_WM_Pre_Determined_Pricing,
    lblMarket_WM_Third_Party_Agreement
  };
  connectedCallback() {
    this.showSpinner = true;
    if (this.recordid !== undefined || this.recordid !== null) {
      this.showoutputScreen();
      //'a0JVF000001HnyD2AS'
    }
    else {
      console.log('recordid::: in else' + this.recordid);
    }
    registerListener("showmultivendoroutputscreen", this.showoutputScreen, this);
  }
  disconnectedCallback() {
    // unsubscribe from showmultivendoroutputscreen event
    unregisterAllListeners(this);
  }

  showoutputScreen() {

    // Fetching prcing request wrapper list
    getRequestNumber({ recordId: this.recordid })
      .then((result) => {
        this.prWrapperReuslt = result;
        this.response = result.priReq.APIRequestOutput__c;
        this.requestno = result.priReq.Name;
        this.createddate = result.createdDate;
        this.lineofbusiness = result.priReq.Line_of_Business__c;
        this.frequencytype = result.priReq.Frequency_Type__c;
        this.frequencycount = result.priReq.Frequency_Count__c;
        this.quantity = result.priReq.Quantity__c;
        this.serviceoccurrencetype = result.priReq.Schedule_or_On_Call__c;
        if (result.priReq.Pricing_Type__c != "PT") {
          this.createdby = this.systemGenarated;
        } else {
          this.createdby = result.priReq.CreatedBy.Name;
        }
        this.pricingthresholdlist = result.pricingThresholds;
        this.isPriceChangeRequest = result.priReq.IsPriceChangeRequest__c;
        this.serviceBaselineId = result.priReq.Service_Baseline_ID__c;
        if (this.lineofbusiness == this.rollOff) {
          this.isRollOff = true;
        } else if (this.lineofbusiness == this.commercial) {
          this.isRollOff = false;
        }
        this.showPriceRequestValues(this.response);
      })
      .catch((error) => {
        console.log("getRequestNumber : Catch " + error);
        this.error = error;
      });
  }

  //Displaying pricing request record data 
  showPriceRequestValues(result) {
    var responseData;
    try {
      responseData = JSON.parse(result);
      this.responseRecord = responseData;
      
      if (responseData.data != null) {
        //49635 sorting
        this.allVendors =[];

        if(responseData.data["isCostOnly"])
          {
                this.isCostOnly= true;
          }
         responseData.data.suppliers.forEach((vendor, index) => {
           vendor.originalIndex = index;
          if(vendor.messages !== null){
            for (let i in vendor.messages) {
              var msg = vendor.messages[i].description;
              var errorCode =vendor.messages[i].code;
              if(msg !== this.noCostPriceMsg ){
                //if(errorCode !== this.nozoneErrorCode){
                  this.allVendors.push(vendor);
                //}
              }
            }
          }else{
            this.allVendors.push(vendor);
          }
          console.log('allvendors==>'+JSON.stringify(this.allVendors));
        });
        //shajiya 49635 sorting vendors
        this.allVendors.sort((a, b) => {
          const vendorA = (a.supplierName || '').trim().toUpperCase();
           const vendorB = (b.supplierName || '').trim().toUpperCase();   
          
   // Check if WM vendor (startsWith 'WM')
          const isWM_A = vendorA.startsWith('WM');
          const isWM_B = vendorB.startsWith('WM');

        const prioritizedErrorMessages = [
           'missing disposal facility',
           'unable get geo location address',
           'no cost/price information available',
           'geo code:error message'
        ];

  // Check if vendor has priority error message
      const hasPriorityError = (vendor) => {
         if (!vendor.messages) return false;
            return vendor.messages.some(msg =>
               prioritizedErrorMessages.includes((msg.description || '').trim().toLowerCase())
 );
  };
   const aHasError = hasPriorityError(a);
      const bHasError = hasPriorityError(b);

         // Priority 1: WM vendors with priority error message first
      if (isWM_A && aHasError && !(isWM_B && bHasError)) return -1;
      if (isWM_B && bHasError && !(isWM_A && aHasError)) return 1;

  // Helper to get rank, assign 0 if missing/null/blank
        const getRank = (vendor) => {
         let rankRaw = vendor.rank;
          if (!rankRaw && vendor.tpMetaData?.zoneRank !== undefined) {
           rankRaw = vendor.tpMetaData.zoneRank;
        }
          if (rankRaw === null || rankRaw === undefined || rankRaw === '') {
           return 0; // prioritize missing rank as 0
        }
          const numRank = Number(rankRaw);
           return isNaN(numRank) ? 0 : numRank;
      };

      const rankA = getRank(a);
      const rankB = getRank(b);

      // Priority 2: sort by rank ascending
        if (rankA !== rankB) return rankA - rankB;
         // Priority 3: WM vendors first if ranks equal
      if (isWM_A && !isWM_B) return -1;
      if (!isWM_A && isWM_B) return 1;

    // Priority 4: Alphabetical sort
  const nameCompare = vendorA.localeCompare(vendorB);
  if (nameCompare !== 0) return nameCompare;

  // Final fallback: preserve API response order
  return a.originalIndex - b.originalIndex;
 
});
  console.log('after sorting:', this.allVendors.map(v => v.supplierName));
        //shajiya 49635 shajiya
       
        this.isAPIError = false;
        this.allVendorSize = this.allVendors.length;

this.currentPage = 1;

this.vendorSize = 0;
 
        //checking vendor size and display pagination buttons
        if (this.allVendors.length > 1) {
          this.isPaginationRequired = true;
        } else {
          this.isPaginationRequired = false;
        }
        if(this.allVendors[this.vendorSize].messages != null){
          this.getMessageDetails(this.vendorSize);
        }
        
        
        
        
        if (this.allVendors[this.vendorSize].wmMetaData != null) {
          this.getWMMetaDataValues(this.vendorSize);
        }
        this.singleVendorServiceCharges = [];
        if (this.allVendors[this.vendorSize].serviceCharges != null) {
          this.getServiceCharges(this.vendorSize);
        }
        if (responseData.data != null) {
          this.getDataNodeValues(this.responseRecord,this.vendorSize);
        }
        if (this.allVendors[this.vendorSize].commercial != null) {
          this.getCommercialData(this.vendorSize);
        }
        
        if (this.allVendors[this.vendorSize].tpMetaData != null) {
          this.getTPMetadata(this.vendorSize);
        }
        this.getOutPutMessage(this.vendorSize);
        if (this.allVendors[this.vendorSize].rollOff != null) {
          this.getVendorRollOffData(this.vendorSize,this.prWrapperReuslt);
          this.getStepDisposals(this.vendorSize, this.responseRecord);
        }
        this.showSpinner = false;
        var inputData = [];
                inputData.push(this.lineofbusiness);
                inputData.push(this.serviceoccurrencetype);
                inputData.push(this.isPriceChangeRequest);
                inputData.push(this.serviceBaselineId);
                fireEvent(this.pageRef, "setInputParam", inputData); 
      }else{
        this.showSpinner = false;
        this.isAPIError = true;
        var errorCode = responseData.problem.errors[0].code ? responseData.problem.errors[0].code : '';
        if (errorCode == "3PECON" || errorCode == "WMECON") {
          this.APIErrorMsg = responseData.problem.errors[0].message;
          if (this.APIErrorMsg.includes("System.NullReferenceException")) {
            this.APIErrorMsg =
              AdministratorMessage +
              "\n" +
              this.responseRecord;
          }
        }else if (errorCode == "ER10"){
          this.APIErrorMsg = responseData.problem.errors[0].message;
          var inputData = [];
                inputData.push(this.lineofbusiness);
                inputData.push(this.serviceoccurrencetype);
                inputData.push(this.isPriceChangeRequest);
                inputData.push(this.serviceBaselineId);
                fireEvent(this.pageRef, "setInputParam", inputData);
        }
      }
    } catch (e) {
      this.APIErrorMsg = AdministratorMessage+
      "\n" +
      this.responseRecord;
      this.isAPIError = true;
      this.showSpinner = false;
    }


  }

  pageSize = 1; // Number of suppliers per page
  currentPage = 1;

  get totalPages() {

    return Math.ceil(this.allVendorSize / this.pageSize);
  }

  get isFirstPage() {
    return this.currentPage === 1;
  }

  get isLastPage() {
    return this.currentPage === this.totalPages;
  }


  get paginatedSuppliers() {
    var singleVendor = "";
    const startIdx = (this.currentPage - 1) * this.pageSize;
    const endIdx = startIdx + this.pageSize;
    singleVendor = this.allVendors.slice(startIdx, endIdx);

    return singleVendor;
  }

  //Pagination Preview button
  previousPage() {
    this.showSpinner = true;
    if (this.currentPage > 1) {
      this.currentPage--;
      this.vendorSize--;
      if (this.allVendors[this.vendorSize].rollOff != null) {
        this.getVendorRollOffData(this.vendorSize,this.prWrapperReuslt);
        this.getStepDisposals(this.vendorSize, this.responseRecord);
      }
      if (this.allVendors[this.vendorSize].wmMetaData != null) {
        this.getWMMetaDataValues(this.vendorSize);
      }
      this.singleVendorServiceCharges = [];
      this.serviceChargesPerVendor = [];
      if (this.allVendors[this.vendorSize].serviceCharges != null) {
        this.getServiceCharges(this.vendorSize);
      }
      if (this.responseRecord.data != null) {
        this.getDataNodeValues(this.responseRecord,this.vendorSize);
      }
      if (this.allVendors[this.vendorSize].commercial != null) {
        this.getCommercialData(this.vendorSize);
      }
      if (this.allVendors[this.vendorSize].tpMetaData != null) {
        this.getTPMetadata(this.vendorSize);
      }
      this.isMessageValue = false;
      if(this.allVendors[this.vendorSize].messages != null){
        this.getMessageDetails(this.vendorSize);
      }
      this.getOutPutMessage(this.vendorSize);
    }
    this.showSpinner = false;
  }

  //Pagination Next button
  nextPage() {
    this.showSpinner = true;
    if (this.currentPage < this.totalPages) {
      this.currentPage++;
      this.vendorSize++;
      if (this.allVendors[this.vendorSize].rollOff != null) {
        this.getVendorRollOffData(this.vendorSize, this.prWrapperReuslt);
        this.getStepDisposals(this.vendorSize, this.responseRecord);
      }
      if (this.allVendors[this.vendorSize].wmMetaData != null) {
        this.getWMMetaDataValues(this.vendorSize);
      }
      this.singleVendorServiceCharges = [];
      this.serviceChargesPerVendor = [];
      if (this.allVendors[this.vendorSize].serviceCharges != null) {
        this.getServiceCharges(this.vendorSize);
      }
      if (this.responseRecord.data != null) {
        this.getDataNodeValues(this.responseRecord,this.vendorSize);
      }
      if (this.allVendors[this.vendorSize].commercial != null) {
        this.getCommercialData(this.vendorSize);
      }
      if (this.allVendors[this.vendorSize].tpMetaData != null) {
        this.getTPMetadata(this.vendorSize);
      }
      this.isMessageValue = false;
      if(this.allVendors[this.vendorSize].messages != null){
        this.getMessageDetails(this.vendorSize);
      }
      this.getOutPutMessage(this.vendorSize);
    }
    this.showSpinner = false;
  }

  //Mapping common fields from JSON
  getDataNodeValues(response,vendorSize) {
    try {
      this.priceQuoteIdentifier = response.data.priceQuoteIdentifier;
      this.containerCode = response.data.equipmentCode;
      this.overridableEquipmentSizeCode = response.data.overridableEquipmentSizeCode;
      this.feeComment = response.data.suppliers[vendorSize].tpMetaData!=null? response.data.suppliers[vendorSize].tpMetaData.feeComment : '';
      this.zoneRank = response.data.suppliers[vendorSize].tpMetaData!=null? response.data.suppliers[vendorSize].tpMetaData.zoneRank : '';
      this.currencyCode = response.data.currencyCode != null ? response.data.currencyCode : "USD";
      this.costSource = response.data.suppliers[vendorSize].costSource;
    } catch (e) {
      console.error('getDataNodeValues::' + e);
      this.showSpinner = false;
    }
  }
  //Mapping Roll-Off feilds from JSOn each vendor
  getVendorRollOffData(rolf, wrapperResult) {
    try {
      this.haulCost ='';
      this.haulPrice = '';
      if (this.allVendors[rolf].rollOff != null) {
        this.pricingthresholdlist = wrapperResult.pricingThresholds;
        //this.isRollOff = true;
        if (this.allVendors[rolf].rollOff.haulCost != null) {
          //Changes related to SDT-48526
          this.haulCost = this.allVendors[rolf].rollOff.haulCost ? this.allVendors[rolf].rollOff.haulCost.toFixed(2) : null;
          this.haulPrice = this.allVendors[rolf].rollOff.haulPrice ? this.allVendors[rolf].rollOff.haulPrice.toFixed(2) : null;
        }
        var costSource = this.allVendors[rolf].costSource.split(' ')[0];
        if (wrapperResult.priReq.Line_of_Business__c == this.rollOff && costSource == "WM" 
          && (this.allVendors[rolf].priceSource != this.exibitPricing && this.allVendors[rolf].priceSource != this.exibitCostPricing)) {
          this.pricingthresholdlist.forEach(threshold => {
            if (threshold.Label == Price_Per_Haul) {
              this.pricingMinThreshold = threshold.Minimum_Value__c;
              this.pricingMaxThreshold = threshold.Maximum_Value__c;
            }
          });
          if (this.allVendors[rolf].rollOff.haulCost != null) {
            this.pricePerHaul = this.allVendors[rolf].rollOff.haulCost ? this.allVendors[rolf].rollOff.haulCost.toFixed(2) : "";
          }
          /*if (this.allVendors[rolf].rollOff.disposalCost != null) {
            this.disposalCost = this.allVendors[rolf].rollOff.disposalCost ? this.allVendors[rolf].rollOff.disposalPrice.toFixed(2) : "";
          }*/
          if(this.pricePerHaul < 150){
            this.thresholdMsg = 'Haul Cost is <$150, please confirm or re-procure if required';
            this.isThresholdMsg = true;
          }else if(this.pricePerHaul > 1500){
            this.thresholdMsg = 'Haul Cost is >$1500, please confirm or re-procure if required';
            this.isThresholdMsg = true;
          }else if(this.pricePerHaul > 150 && this.pricePerHaul < 1500){
            this.thresholdMsg = '';
            this.isThresholdMsg = false;
          }
          /*if (this.pricePerHaul && this.pricingMinThreshold != null && this.pricePerHaul < this.pricingMinThreshold) {
            this.thresholdMsg = 'Haul Cost is <$' + this.pricingMinThreshold + ', please confirm or re-procure if required';
            this.isThresholdMsg = true;
          } else if (this.pricePerHaul && this.pricingMaxThreshold != null && this.pricePerHaul > this.pricingMaxThreshold) {
            this.thresholdMsg = 'Haul Cost is >$' + this.pricingMaxThreshold + ', please confirm or re-procure if required';
            this.isThresholdMsg = true;
          }*/
        }else{
          this.isThresholdMsg = false;
        }
        if (this.allVendors[rolf].rollOff.stepDisposals != null) {
          this.stepDisposables = this.allVendors[rolf].rollOff.stepDisposals;
        }
        if (this.allVendors[rolf].rollOff.pricingMethodHaulingDescription) {
          this.ratrTypeHauling = this.allVendors[rolf].rollOff.pricingMethodHaulingDescription;
        }
        this.pricingMethodHaulingDescription = this.allVendors[rolf].rollOff.pricingMethodHaulingDescription;
        this.pricingMethodDisposalDescription = this.allVendors[rolf].rollOff.pricingMethodDisposalDescription;
        this.haulRecordId = this.allVendors[rolf].rollOff.haulRecordId;
        this.estimatedVolumePerHaul = this.allVendors[rolf].rollOff.estimatedVolumePerHaul;
        this.disposalRecordId = this.allVendors[rolf].rollOff.disposalRecordId;


      }
    } catch (e) {
      console.error('getVendorRollOffData::' + e);
      this.showSpinner = false;
    }
  }
  //Mapping WM Metadata feilds from JSON each vendor
  getWMMetaDataValues(wmMeta) {
    try {
      if (this.allVendors[wmMeta].wmMetaData != null) {
        this.diversion = '';
        this.scaleAvailability = '';
        this.regulatoryFeeDetails= [];
        this.masLibrary = this.allVendors[wmMeta].wmMetaData.masLibrary;
        this.marketAreaName = this.allVendors[wmMeta].wmMetaData.marketAreaName;
        this.fecilityId = this.allVendors[wmMeta].wmMetaData.facilityId;
        this.masUniqId = this.allVendors[wmMeta].wmMetaData.masCustomerUniqueId;
        this.siteId = this.allVendors[wmMeta].wmMetaData.siteId;
        this.marketAreaCode = this.allVendors[wmMeta].wmMetaData.marketAreaCode;
        this.businessUnit = this.allVendors[wmMeta].wmMetaData.businessUnit;
      }
    } catch (e) {
      console.error('getWMMetaDataValues::' + e);
      this.showSpinner = false;
    }
  }
  //Mapping TP Metadata feilds from JSON each vendor
  getTPMetadata(tpMeta) {
    this.regulatoryFeeDetails= [];
    try {
      this.masLibrary = '';
      this.marketAreaName ='';
      this.fecilityId = '';
      this.masUniqId = '';
      this.siteId = '';
      this.marketAreaCode = '';
      this.businessUnit ='';
      this.diversion = this.allVendors[tpMeta].tpMetaData.diversion;
      this.scaleAvailability = this.allVendors[tpMeta].tpMetaData.scaleAvailability;
      // Mapping Regulatory Fee fields from JSON each vendor
      var responseRegulatoryFee = this.allVendors[tpMeta].tpMetaData ?
        this.allVendors[tpMeta].tpMetaData.regulatoryFees ?
          this.allVendors[tpMeta].tpMetaData.regulatoryFees : "" : "";
      if (responseRegulatoryFee) {
        this.isRegulatoryFee = true;
        responseRegulatoryFee.sort(this.getSortOrder("order"));
      }
      var rfName = "", rfUOM = "", rfCost = "", rfPercentageBasedOrCompounded = "", rfAppliesToDisposal = "", rfAppliesToHaul = "", rfAppliesToRental = "", rfBasis = "", rfOrder = "", rfComment = "";
      for (var rfFields in responseRegulatoryFee) {
        rfName = responseRegulatoryFee[rfFields]["name"] ? responseRegulatoryFee[rfFields]["name"] : "";
        rfCost = responseRegulatoryFee[rfFields]["cost"] ? responseRegulatoryFee[rfFields]["cost"] : "";
        rfPercentageBasedOrCompounded = responseRegulatoryFee[rfFields]["percentageBasedOrCompounded"] ? responseRegulatoryFee[rfFields]["percentageBasedOrCompounded"] : "";
        rfAppliesToDisposal = responseRegulatoryFee[rfFields]["appliesToDisposal"] ? responseRegulatoryFee[rfFields]["appliesToDisposal"] : "";
        rfAppliesToHaul = responseRegulatoryFee[rfFields]["appliesToHaul"] ? responseRegulatoryFee[rfFields]["appliesToHaul"] : "";
        rfAppliesToRental = responseRegulatoryFee[rfFields]["appliesToRental"] ? responseRegulatoryFee[rfFields]["appliesToRental"] : "";
        rfBasis = responseRegulatoryFee[rfFields]["basis"] ? responseRegulatoryFee[rfFields]["basis"] : "";
        rfUOM = responseRegulatoryFee[rfFields]["uom"] ? responseRegulatoryFee[rfFields]["uom"] : "";
        rfOrder = responseRegulatoryFee[rfFields]["order"] ? responseRegulatoryFee[rfFields]["order"] : "";
        rfComment = responseRegulatoryFee[rfFields]["comment"] ? responseRegulatoryFee[rfFields]["comment"] : "";
        if (rfComment) {
          this.isrfdComment = true;
        }
        this.regulatoryFeeDetails.push({
          rfName: rfName,
          rfUOM: rfUOM,
          rfCost: rfCost,
          rfPercentageBasedOrCompounded: rfPercentageBasedOrCompounded,
          rfAppliesToDisposal: rfAppliesToDisposal,
          rfAppliesToHaul: rfAppliesToHaul,
          rfAppliesToRental: rfAppliesToRental,
          rfBasis: rfBasis,
          rfOrder: rfOrder,
          rfComment: rfComment
        });
      }
    } catch (e) {
      console.error('getTPMetadata::' + e);
      this.showSpinner = false;
    }
    //End Regulatory Fee fields mapping
  }
  //Sorting Regulatory Fee fields
  getSortOrder(prop) {
    return function (a, b) {
      if (a[prop] > b[prop]) {
        return 1;
      } else if (a[prop] < b[prop]) {
        return -1;
      }
      return 0;
    }
  }
  //Mapping Commercial feilds from JSON each vendor
  getCommercialData(vendorSize) {
    try {
      if (this.allVendors[vendorSize].commercial.pickupRecordId != null) {
        this.pickupRecordId = this.allVendors[vendorSize].commercial.pickupRecordId;
      }
      if (this.allVendors[vendorSize].commercial.extraPickupRecordId != null) {
        this.extraPickupRecordId = this.allVendors[vendorSize].commercial.extraPickupRecordId;
      }
      //Changes related to SDT-48526
      if (this.allVendors[vendorSize].commercial.pricingMethodPickupDescription) {
        //this.containerCode = this.allVendors[vendorSize].commercial.pricingMethodPickupDescription;
        this.rateTypePickup = this.allVendors[vendorSize].commercial.pricingMethodPickupDescription;
      }
      else if (this.allVendors[vendorSize].commercial.pricingMethodCodeDescription !== null) {
        this.rateTypePickup = this.allVendors[vendorSize].commercial.pricingMethodCodeDescription;
      }
      //Changes related to SDT-48526
      this.extraPickupCost = this.allVendors[vendorSize].commercial.extraPickupCost ? this.allVendors[vendorSize].commercial.extraPickupCost.toFixed(2) : null;
      this.extraPickupPrice = this.allVendors[vendorSize].commercial.extraPickupPrice ? this.allVendors[vendorSize].commercial.extraPickupPrice.toFixed(2) : null;
      this.pickupUnitPrice = this.allVendors[vendorSize].commercial.pickupUnitPrice ? this.allVendors[vendorSize].commercial.pickupUnitPrice.toFixed(2) :null;
      this.pickupUnitCost = this.allVendors[vendorSize].commercial.pickupUnitCost ? this.allVendors[vendorSize].commercial.pickupUnitCost.toFixed(2) : null;
      if(this.extraPickupCost != null){
        this.extraPickupCostSymbol = this.currencyCode;
      }else{
        this.extraPickupCostSymbol = "";
      }

      if(this.extraPickupPrice != null){
        this.extraPickupPriceSymbol = this.currencyCode;
      }else{
        this.extraPickupPriceSymbol = "";
      }

      if(this.pickupUnitCost != null){
        this.pickupCostSymbol = this.currencyCode;
      }else{
        this.pickupCostSymbol = "";
      }

      if(this.pickupUnitPrice != null){
        this.pickupPriceSymbol = this.currencyCode;
      }else{
        this.pickupPriceSymbol = "";
      }

      if (this.lineOfBusiness == this.commercial && this.serviceOccurrenceType == this.onCall) {
        this.costUOM = "Event";
        this.priceUOM = "Event";
      }
      else if (this.allVendors[vendorSize].equipmentUOM) {
        this.costUOM = this.allVendors[vendorSize].equipmentUOM;
        this.priceUOM = this.allVendors[vendorSize].equipmentUOM;
      }
    } catch (e) {
      console.error('getCommercialData::' + e);
      this.showSpinner = false;
    }
  }
  //Mapping Message details feilds from JSON each vendor
  getMessageDetails(vendorcount) {
    try {
      this.messages = this.allVendors[vendorcount].messages;
      if (this.messages != null) {
        for (let i in this.messages) {
          this.showMessage = this.messages[i].description;
        }
        if (this.showMessage) {
          this.isMessageValue = true;
        } else {
          this.isMessageValue = false;
        }
      }
    } catch (e) {
      console.error('getMessageDetails::' + e);
      this.showSpinner = false;
    }
  }

  //Mapping Step Disposals feilds each vendor only for Roll-Off PR
  getStepDisposals(vendorCount, response) {
    try {
      this.displayStepDisposals = [];
      var pricingFieldPrice = "";
      var apiFieldValueCost = "";
      var apiFieldValuePrice = "";
      var costUOM = "";
      var priceUOM = "";
      var costSymbol = "";
      var priceSymbol = "";
      var responseDisposalsStep = "";
      var responseDisposalsCost = "";
      var responseDisposalsPrice = "";
      var priceRange = "";
      var costRange = "";
      var pricingFieldCost = "";
      var currencyCode = response.data.currencyCode != null ? response.data.currencyCode : "USD";
      //Changes related to SDT-48526
      responseDisposalsCost = this.allVendors[vendorCount].rollOff.disposalCost ? this.allVendors[vendorCount].rollOff.disposalCost.toFixed(2) : null;
      responseDisposalsPrice = this.allVendors[vendorCount].rollOff.disposalPrice ? this.allVendors[vendorCount].rollOff.disposalPrice.toFixed(2) : null;
      responseDisposalsStep = this.allVendors[vendorCount].rollOff.stepDisposals;
      if (responseDisposalsStep) {
        var stepCount = 0;
        for (var step in responseDisposalsStep) {
          //Both Disposal Cost and Price is StepRate
          if(responseDisposalsCost == null && responseDisposalsPrice == null){
            if(responseDisposalsStep[step].costRange != null){
              costRange = responseDisposalsStep[step].costRange;
            }else{
              costRange = '';
            }
            if (responseDisposalsStep[step].priceRange != null) {
              priceRange = responseDisposalsStep[step].priceRange;
            }else{
              priceRange ='';
            }
            if (responseDisposalsStep[step].cost != null) {
              pricingFieldCost = responseDisposalsStep[step].cost;
            }else{
              pricingFieldCost='';
            }
            if (responseDisposalsStep[step].price != null) {
              pricingFieldPrice = responseDisposalsStep[step].price;
            }else{
              pricingFieldPrice='';
            }
          }// Disposal Cost is StepRate and Price is FlatRate
          else if(responseDisposalsCost == null && responseDisposalsPrice != null){
            if(responseDisposalsStep[step].costRange != null){
              costRange = responseDisposalsStep[step].costRange;
            }else{
              costRange = '';
            }
            if (responseDisposalsStep[step].priceRange != null) {
              priceRange = responseDisposalsStep[step].priceRange;
            }else{
              priceRange ='';
            }
            if (responseDisposalsStep[step].cost != null) {
              pricingFieldCost = responseDisposalsStep[step].cost;
            }else{
              pricingFieldCost='';
            }
            if(responseDisposalsPrice && pricingFieldPrice == ''){
              pricingFieldPrice=responseDisposalsPrice;
            }else{
              pricingFieldPrice= responseDisposalsStep[step].price;
            }
          }//Disposal Cost is FlatRate and Price is StepRate
          else if(responseDisposalsCost != null && responseDisposalsPrice == null){
            if(responseDisposalsStep[step].costRange != null){
              costRange = responseDisposalsStep[step].costRange;
            }else{
              costRange = '';
            }
            if (responseDisposalsStep[step].priceRange != null) {
              priceRange = responseDisposalsStep[step].priceRange;
            }else{
              priceRange ='';
            }
            if(responseDisposalsCost && pricingFieldCost == ''){
              pricingFieldCost=responseDisposalsCost;
            }else{
              pricingFieldCost= responseDisposalsStep[step].cost;
            }
            if (responseDisposalsStep[step].price != null) {
              pricingFieldPrice = responseDisposalsStep[step].price;
            }else{
              pricingFieldPrice='';
            }
          }//Both Disposal Cost and Price is FlatRate
          else if(responseDisposalsCost != null && responseDisposalsPrice != null){
              costRange = '';
              priceRange ='';
              pricingFieldCost=responseDisposalsCost;
              apiFieldValuePrice=responseDisposalsPrice;
          }
          if(pricingFieldCost == '' || pricingFieldCost == null){
            costSymbol = '';
            costUOM = '';
          }else{
            costSymbol = apiFieldValueCost != null ? currencyCode : "";
            costUOM = (this.allVendors[vendorCount].equipmentUOM && apiFieldValueCost != null) ? this.allVendors[vendorCount].equipmentUOM : "";
          }

          if(pricingFieldPrice == '' || pricingFieldPrice == null){
            priceSymbol = '';  
            priceUOM = '';
          }else{
            priceSymbol = apiFieldValuePrice != null ? currencyCode : "";
            priceUOM = (this.allVendors[vendorCount].equipmentUOM && apiFieldValuePrice != null) ? this.allVendors[vendorCount].equipmentUOM : "";
          }
          this.displayStepDisposals.push({
            costRange: costRange,
            costUOM: costUOM,
            costSymbol: costSymbol,
            pricingFieldCost: pricingFieldCost,
            priceRange: priceRange,
            priceUOM: priceUOM,
            priceSymbol: priceSymbol,
            pricingFieldPrice: pricingFieldPrice,
          });
        }
      }else{
          let disposalCost = this.allVendors[vendorCount].rollOff.disposalCost != null ? this.allVendors[vendorCount].rollOff.disposalCost.toFixed(2) : null;
          let disposalPrice = this.allVendors[vendorCount].rollOff.disposalPrice != null ? this.allVendors[vendorCount].rollOff.disposalPrice.toFixed(2) : null;
          costRange = '';
          priceRange ='';
          pricingFieldCost=disposalCost;
          apiFieldValuePrice=disposalPrice;
          if(pricingFieldCost == '' || pricingFieldCost == null){
            costSymbol = '';
            costUOM = '';
          }else{
            costSymbol = apiFieldValueCost != null ? currencyCode : "";
            costUOM = (this.allVendors[vendorCount].equipmentUOM && apiFieldValueCost != null) ? this.allVendors[vendorCount].equipmentUOM : "";
          }

          if(apiFieldValuePrice == '' || apiFieldValuePrice == null){
            priceSymbol = '';  
            priceUOM = '';
          }else{
            priceSymbol = apiFieldValuePrice != null ? currencyCode : "";
            priceUOM = (this.allVendors[vendorCount].equipmentUOM && apiFieldValuePrice != null) ? this.allVendors[vendorCount].equipmentUOM : "";
          }
          this.displayStepDisposals.push({
            costRange: costRange,
            costUOM: costUOM,
            costSymbol: costSymbol,
            pricingFieldCost: pricingFieldCost,
            priceRange: priceRange,
            priceUOM: priceUOM,
            priceSymbol: priceSymbol,
            pricingFieldPrice: apiFieldValuePrice,
          });
      }
    } catch (e) {
      console.error('getStepDisposals::' + e);
      this.showSpinner = false;
    }
  }
  //Mapping OutPut Message Datils from JSON each Vendor
  getOutPutMessage(vendorcount) {
    try {
      this.isOutPutMsg = false;
      this.apiContractType = this.allVendors[vendorcount].contractType ? this.allVendors[vendorcount].contractType.toLowerCase() : "";
      if (this.apiContractType ||
         (this.apiContractType == WM_Franchise && 
          this.apiContractType == Competitor && 
          this.apiContractType == Pre_Determined_Pricing && 
          this.apiContractType == Third_Party_Agreement)) 
          {
        if (this.apiContractType === WM_Franchise) {
          this.isOutPutMsg = true;
          this.outputmsg = zoneFranchiseMsg;
          this.outputMarket = lblMarket_WM_Franchise;
          
        } else if (this.apiContractType === Competitor) {
          this.isOutPutMsg = true;
          this.outputmsg = zoneCompetitorMsg;
          this.outputMarket = lblMarket_Non_WM_Franchise;
        } else if (this.apiContractType === Pre_Determined_Pricing) {
          this.outputmsg = zoneDeterminedMsg;
          this.outputMarket = lblMarket_WM_Pre_Determined_Pricing;
          this.isOutPutMsg = true;
        } else if (this.apiContractType === Third_Party_Agreement) {
          this.outputmsg = zone3PAMsg;
          this.outputMarket = lblMarket_WM_Third_Party_Agreement;
          this.isOutPutMsg = true;
        }
        this.zoneName = this.allVendors[vendorcount].zoneName ? this.allVendors[vendorcount].zoneName : "";
        this.zoneDescription = this.allVendors[vendorcount].zoneDescription ? this.allVendors[vendorcount].zoneDescription : "";
        this.zoneNote = this.allVendors[vendorcount].zoneNotes ? this.allVendors[vendorcount].zoneNotes : "";
        this.francisePricingLink = this.allVendors[vendorcount].wmMetaData ? this.allVendors[vendorcount].wmMetaData.francisePricingLink : null;
        if (this.francisePricingLink) {
          this.isfranchisePRLink = true;
        }
        this.greenPagesLink = this.allVendors[vendorcount].wmMetaData ? this.allVendors[vendorcount].wmMetaData.greenPagesLink : null;
        if (this.greenPagesLink) {
          this.isGreenPagePRLink = true;
        }
      }
    } catch (e) {
      console.error('getOutPutMessage::' + e);
      this.showSpinner = false;
    }
  }
  //Fetching service charges from JSON each vendor
  getServiceCharges(vendorSize) {
    try {
      this.serviceCharges = this.allVendors[vendorSize].serviceCharges;
      if (this.serviceCharges != null) {
        var minimumTonsServiceDetail = this.serviceCharges.filter(function (entry) {
          return entry.name.toLowerCase() === Minimum_Tons_Recycling;
        });

        var allOtherminimumTonsServiceDetail = this.serviceCharges.filter(function (entry) {
          return entry.name.toLowerCase() === All_Other_Minimum_Tonnage;
        });
        this.minimumTons = (this.responseRecord.data["materialCode"] == 'C' || this.responseRecord.data["materialCode"] == 'SSR') ? minimumTonsServiceDetail[0] && minimumTonsServiceDetail[0].price != null ? minimumTonsServiceDetail[0].price : '' : (allOtherminimumTonsServiceDetail[0] && allOtherminimumTonsServiceDetail[0].price != null ? allOtherminimumTonsServiceDetail[0].price : '');
        var curyCode = this.responseRecord.data.currencyCode != null ? this.responseRecord.data.currencyCode : "USD";
        for (let i in this.serviceCharges) {
          
          if(this.lineofbusiness == this.commercial){
            if (this.serviceCharges[i].name.toLowerCase() === this.weelInstalCharge) {
              this.singleVendorServiceCharges.push(this.serviceCharges[i]);
            }
            if (this.serviceCharges[i].name.toLowerCase() === this.weelsMonthlyCharges) {
              this.singleVendorServiceCharges.push(this.serviceCharges[i]);
            }
            if (this.serviceCharges[i].name.toLowerCase() === this.lockInstallation) {
              this.singleVendorServiceCharges.push(this.serviceCharges[i]);
            }
            if (this.serviceCharges[i].name.toLowerCase() === this.lockMonthlyCharge) {
              this.singleVendorServiceCharges.push(this.serviceCharges[i]);
            }
          }
          if (this.serviceCharges[i].name.toLowerCase() === this.fuelFee) {
            this.singleVendorServiceCharges.push(this.serviceCharges[i]);
          }
          if (this.serviceCharges[i].name.toLowerCase() === this.environmentalFee) {
            this.singleVendorServiceCharges.push(this.serviceCharges[i]);
          }
          if (this.serviceCharges[i].name.toLowerCase() === this.regulatoryCostrecovery) {
            this.singleVendorServiceCharges.push(this.serviceCharges[i]);
          }
          if (this.serviceCharges[i].name.toLowerCase() === this.delevery) {
            this.singleVendorServiceCharges.push(this.serviceCharges[i]);
          }
          if (this.serviceCharges[i].name.toLowerCase().includes(this.containerServiceCharges)) {
            this.singleVendorServiceCharges.push(this.serviceCharges[i]);
          }
          if (this.serviceCharges[i].name.toLowerCase() === this.trip) {
            this.singleVendorServiceCharges.push(this.serviceCharges[i]);
          }
          if (this.serviceCharges[i].name.toLowerCase() === this.containerRemoval) {
            this.singleVendorServiceCharges.push(this.serviceCharges[i]);
          }
          if (this.serviceCharges[i].name.toLowerCase().includes(this.inactivityFee)) {
            this.singleVendorServiceCharges.push(this.serviceCharges[i]);
          }
          if (this.serviceCharges[i].name.toLowerCase() === this.relocation) {
            this.singleVendorServiceCharges.push(this.serviceCharges[i]);
          }
          if (this.serviceCharges[i].name.toLowerCase() === this.managementFee) {
            this.singleVendorServiceCharges.push(this.serviceCharges[i]);
          }
          if (this.serviceCharges[i].cost != null) {
            if (this.serviceCharges[i].costValueType && this.serviceCharges[i].costValueType.toLowerCase() === Percent.toLowerCase()) {
              this.serviceCharges[i].cost = Math.round(this.serviceCharges[i].cost * 100) / 100 + "%";
            } else {
              //Changes related to SDT-48526
              this.serviceCharges[i].cost = (Math.round(this.serviceCharges[i].cost * 100) / 100).toFixed(2);
            }
          } else {
            this.serviceCharges[i].cost = '';
          }
          if (this.serviceCharges[i].price != null) {
            if (this.serviceCharges[i].priceValueType && this.serviceCharges[i].priceValueType.toLowerCase() === Percent.toLowerCase()) {
              this.serviceCharges[i].price = Math.round(this.serviceCharges[i].price * 100) / 100 + "%";
            } else {
              this.serviceCharges[i].price =  (Math.round(this.serviceCharges[i].price * 100) / 100).toFixed(2);
            }
          } else {
            this.serviceCharges[i].price = '';
          }
          if (this.serviceCharges[i].actionName == 'Exclude') {
            this.serviceCharges[i].price = this.exclude;
          } else if (
            this.serviceCharges[i].actionName == "Allow" ||
            this.serviceCharges[i].actionName == "Adjust" ||
            this.serviceCharges[i].actionName == "Manual Review"
          ) {
            this.serviceCharges[i].price = this.serviceCharges[i].price;
          }else{
            this.serviceCharges[i].price = '';
          }

          if(this.serviceCharges[i].price === this.exclude){
            this.serviceCharges[i].priceUOM = '';
            this.serviceCharges[i].priceSymbol = '';
            this.serviceCharges[i].costUOM = '';
            this.serviceCharges[i].costSymbol = '';           
          }else{
            if(this.serviceCharges[i].price !== null){
              this.serviceCharges[i].priceUOM = this.serviceCharges[i].priceUOM;
              this.serviceCharges[i].priceSymbol = curyCode;
            }
            if (this.serviceCharges[i].cost !== null){
              this.serviceCharges[i].costUOM = this.serviceCharges[i].costUOM;
              this.serviceCharges[i].costSymbol = curyCode;
            }
          }

          //Adding sequence field as per order
          this.singleVendorServiceCharges.forEach(item => {
            if (item.name.toLowerCase() === this.fuelFee) {
              item.sequence = 1;
            }
            if (item.name.toLowerCase() === this.environmentalFee) {
              item.sequence = 2;
            }
            if (item.name.toLowerCase() === this.regulatoryCostrecovery) {
              item.sequence = 3;
            }
            if (item.name.toLowerCase() === this.delevery) {
              item.sequence = 4;
            }
            if (item.name.toLowerCase().includes(this.containerServiceCharges)) {
              item.sequence = 5;
            }
            if (item.name.toLowerCase() === this.trip) {
              item.sequence = 6;
            }
            if (item.name.toLowerCase() === this.containerRemoval) {
              item.sequence = 7;
            }
            if (item.name.toLowerCase().includes(this.inactivityFee)) {
              item.sequence = 8;
            }
            if (item.name.toLowerCase() === this.relocation) {
              item.sequence = 9;
            }
            if (item.name.toLowerCase() === this.managementFee) {
              item.sequence = 10;
            }
            if(this.lineofbusiness == this.commercial){
              if (item.name.toLowerCase() === this.lockInstallation) {
                item.sequence = 11;
              }
              if (item.name.toLowerCase() === this.lockMonthlyCharge) {
                item.sequence = 12;
              }
              if (item.name.toLowerCase() === this.weelInstalCharge) {
                item.sequence = 13;
              }
              if (item.name.toLowerCase() === this.weelsMonthlyCharges) {
                item.sequence = 14;
              }
            }

          });
        }
        this.sortVendorServiceCharges(this.singleVendorServiceCharges);
      }
      //this.minimumTons = '';
    } catch (e) {
      console.error('Service Charges::' + e);
      this.showSpinner = false;
    }
  }
  //Sorting service charges as per sequence.
  sortVendorServiceCharges(serviceCharges) {
    serviceCharges.sort((a, b) => {
      return a.sequence - b.sequence;
    })
    this.serviceChargesPerVendor = serviceCharges;
  }

}
