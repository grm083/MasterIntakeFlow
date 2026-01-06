import { LightningElement, track, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getFieldDetails from "@salesforce/apex/PricingRequest.getFieldDetails";
import { CurrentPageReference } from "lightning/navigation";
import getRequestNumber from "@salesforce/apex/PricingRequest.getRequestNumber";
import getPricingRecord from "@salesforce/apex/PricingRequest.getPricingRecord";
// import insertCaseComment from "@salesforce/apex/PricingRequest.insertCaseComment";
// import updatePriceRequest from "@salesforce/apex/PricingRequest.updatePriceRequest";
// import getCaseDetailsById from '@salesforce/apex/PricingRequest.getCaseDetailsById';
import isPricingMulltiVendorPTSwitchON from '@salesforce/apex/PricingRequestSelector.isPricingMulltiVendorPTSwitchON';
import { registerListener, unregisterAllListeners, fireEvent } from "c/pubsub";

// Import custom labels
import AdministratorMessage from '@salesforce/label/c.AdministratorMessage';
import Exclude from '@salesforce/label/c.Exclude';
import Percent from '@salesforce/label/c.Percent';
import Rolloff from '@salesforce/label/c.Rolloff';
import Pricing_Availability from '@salesforce/label/c.Pricing_Availability';
import Pricing_Fail_Message from '@salesforce/label/c.Pricing_Fail_Message';
import Pricing_Request_Title from '@salesforce/label/c.Pricing_Request_Title';
import Pricing_Success_Message from '@salesforce/label/c.Pricing_Success_Message';
import Record_Update_Title from '@salesforce/label/c.Record_Update_Title';
import Select_Case from '@salesforce/label/c.Select_Case';
import Service_Details from '@salesforce/label/c.Service_Details';
import Pricing_Details from '@salesforce/label/c.Pricing_Details';
import Open_Market from '@salesforce/label/c.Open_Market';
import Non_Serviceable from '@salesforce/label/c.Non_Serviceable';
import Third_Party_Agreement from '@salesforce/label/c.Third_Party_Agreement';
import WM_Franchise from '@salesforce/label/c.WM_Franchise';
import Competitor from '@salesforce/label/c.Competitor';
import Pre_Determined_Pricing from '@salesforce/label/c.Pre_Determined_Pricing';
import zone3PAMsg from '@salesforce/label/c.zone3PAMsg';
import zoneCompetitorMsg from '@salesforce/label/c.zoneCompetitorMsg';
import zoneDeterminedMsg from '@salesforce/label/c.zoneDeterminedMsg';
import zoneFranchiseMsg from '@salesforce/label/c.zoneFranchiseMsg';
import Cost_Compare_Message from '@salesforce/label/c.Cost_Compare_Message';
import Alternate_Container_Message from '@salesforce/label/c.Alternate_Container_Message';
import Read_timed_out from '@salesforce/label/c.Read_timed_out';
import Frequency_Type from '@salesforce/label/c.Frequency_Type';
import Frequency_Count from '@salesforce/label/c.Frequency_Count';
import Quantity from '@salesforce/label/c.Quantity';
import lblDisposal_Facility from '@salesforce/label/c.Disposal_Facility';
import lblDisposition from '@salesforce/label/c.Disposition';
import Diversion_Percentage from '@salesforce/label/c.Diversion_Percentage';
import Price_Per_Haul from '@salesforce/label/c.Price_Per_Haul';
import Disposal from '@salesforce/label/c.Disposal';
import Pickup from '@salesforce/label/c.Pickup';
import Minimum_Tons from '@salesforce/label/c.Minimum_Tons';
import Minimum_Tons_Recycling from '@salesforce/label/c.Minimum_Tons_Recycling';
import All_Other_Minimum_Tonnage from '@salesforce/label/c.All_Other_Minimum_Tonnage';
import lblName from '@salesforce/label/c.Name';
import lblCost from '@salesforce/label/c.Cost';
import lblPercent_Base_or_Compounded from '@salesforce/label/c.Percent_Base_or_Compounded';
import lblApplies_to_Disposal from '@salesforce/label/c.Applies_to_Disposal';
import lblApplies_to_Haul from '@salesforce/label/c.Applies_to_Haul';
import lblApplies_to_Rental from '@salesforce/label/c.Applies_to_Rental';
import lblBasis from '@salesforce/label/c.Basis';
import lblUOM from '@salesforce/label/c.UOM';
import lblOrder from '@salesforce/label/c.Order';
import lblMarket_WM_Franchise from '@salesforce/label/c.Market_WM_Franchise';
import lblMarket_Non_WM_Franchise from '@salesforce/label/c.Market_Non_WM_Franchise';
import lblMarket_WM_Pre_Determined_Pricing from '@salesforce/label/c.Market_WM_Pre_Determined_Pricing';
import lblMarket_WM_Third_Party_Agreement from '@salesforce/label/c.Market_WM_Third_Party_Agreement';

const objectAPiName = "Account";

export default class ReUsableForm extends LightningElement {
  @api buttonLabel = "Create Account"; //Design Attribute property
  @track fieldList;
  @track items;
  @track resultAPI;
  @track serviceDetailData;
  @track mapData = [];

  //@track newServicePRRecordId;
  @api newServicePRRecordId;
  @track showoutput = false;
  @api recordId;
  @track case;
  @track caseNumber;
  @track CreatedBy;
  @track CreatedDate;
  @track RequestNo;
  @track CaseComment;
  @track responseAPI;
  @track outputFieldList;
  @track isAPIError;
  @track APIErrorMsg;
  @track mockresponse = false;
  @track responseData;
  @track responseRecord;
  @track APIResponseStatus;
  @track priceRequestId;
  @track bShowModal = false;
  @track isPriceCaseComment = false;
  @track serviceCommentsHTML;
  @track priceCommentHTML;
  @track regulatoryFeeCommentHTML;
  @track messageCommentHTML;
  @track lineOfBusiness;
  @track frequencyType;
  @track frequencyCount;
  @track quantity;
  @track serviceOccurrenceType;
  @track acornIssueId;
  @track acornTrackingNumber;
  @track isPriceChangeRequest = false;
  @track serviceBaselineId;
  @wire(CurrentPageReference) pageRef;

  pricingReponse;
  isMultiVendor = false;

  //Changes for SDT-26044
  @track pricingThresholdList =[];
  @track pricingMinThreshold;
  @track pricingMaxThreshold;
  @track isMultivendorResponse = false;

  // Expose the labels to use in the JS File.
  label = {
    AdministratorMessage,
    Exclude,
    Non_Serviceable,
    Open_Market,
    Percent,
    Rolloff,
    Pricing_Availability,
    Service_Details,
    Pricing_Details,
    Pricing_Fail_Message,
    Pricing_Request_Title,
    Pricing_Success_Message,
    Record_Update_Title,
    Select_Case,
    Third_Party_Agreement,
    WM_Franchise,
    Competitor,
    Pre_Determined_Pricing,
    zone3PAMsg,
    zoneCompetitorMsg,
    zoneDeterminedMsg,
    zoneFranchiseMsg,
    Cost_Compare_Message,
    Alternate_Container_Message,
    Read_timed_out,
    Frequency_Type,
    Frequency_Count,
    Quantity,
    lblDisposal_Facility,
    lblDisposition,
    Diversion_Percentage,
    Price_Per_Haul,
    Disposal,
    Pickup,
    Minimum_Tons,
    Minimum_Tons_Recycling,
    All_Other_Minimum_Tonnage,
    lblName,
    lblCost,
    lblPercent_Base_or_Compounded,
    lblApplies_to_Disposal,
    lblApplies_to_Haul,
    lblApplies_to_Rental,
    lblBasis,
    lblUOM,
    lblOrder,
    lblMarket_WM_Franchise,
    lblMarket_Non_WM_Franchise,
    lblMarket_WM_Pre_Determined_Pricing,
    lblMarket_WM_Third_Party_Agreement
  };
  connectedCallback() {
    // subscribe to showoutputscreen event
   // console.log("invoked - Output Screen : Start");
   //this.existingOutPutScreen();
   /* var responseData = [];

    if (this.recordId != undefined) {
      var data = [];
      data.push(this.recordId);
      this.showoutputScreen(data);
    }*/
    //registerListener("showoutputscreen", this.showoutputScreen, this);
  }

  disconnectedCallback() {
    // unsubscribe from showoutputscreen event
    unregisterAllListeners(this);
  }
    //adding for fetch the code switch value for multi vendor response
  @wire(isPricingMulltiVendorPTSwitchON)
  isSwitchOn({error,data}) {
      if(data !== undefined) {
          console.log('wire return is  ' + data);
          this.isMultivendorResponse = data;
      }
      else if(error) {
          console.log('error for wire is ' + error);
      }
  }

  @wire(getPricingRecord, { recordId: "$recordId" }) wiredPricingrequestList(result) {
    if (result.data) {
      console.log('is MultiVendor===>'+result.data.Is_Multi_Vendor__c)
      if(this.isMultivendorResponse){
        if(result.data.Is_Multi_Vendor__c == false){
          this.existingOutPutScreen();
        }else{
          this.isMultiVendor = true; 
          console.log('old screen==>'+this.isMultiVendor);
        }
      }else{
        if(result.data.Is_Multi_Vendor__c == false || result.data.Is_Multi_Vendor__c == true){
          this.existingOutPutScreen();
          this.isMultiVendor = false;
          console.log('new screen==>'+this.isMultiVendor);
        }
      }
    }
  }
  
  existingOutPutScreen(){
    var responseData = [];

    if (this.recordId != undefined) {
      var data = [];
      data.push(this.recordId);
      this.showoutputScreen(data);
    }
    registerListener("showoutputscreen", this.showoutputScreen, this);
  }
  showoutputScreen(data) {
    var recordId;
    // this.responseData = data;

    // if (data.length == 2) {
    //   recordId = data[0];
    //   this.responseAPI = data[1];

    //   setTimeout(() => {
    //     this.createOutputScreen(
    //       this.outputFieldList,
    //       this.responseAPI,
    //       recordId
    //     );
    //   },1000);
    // } else {
      recordId = data[0];

      getRequestNumber({ recordId: recordId })
        .then((result) => {
          this.RequestNo = result.priReq.Name;
          this.CreatedDate = result.createdDate;
          this.responseRecord = result.priReq.APIRequestOutput__c;
          console.log('output screen api response==>'+JSON.stringify(this.CreatedDate));
          this.pricingReponse = result.priReq.Name;
          this.priceRequestId = result.priReq.Id;
          this.isPriceCaseComment = result.priReq.PriceCaseComment__c;
          this.lineOfBusiness = result.priReq.Line_of_Business__c;
          this.frequencyType = result.priReq.Frequency_Type__c;
          this.frequencyCount = result.priReq.Frequency_Count__c;
          this.quantity = result.priReq.Quantity__c;
          this.serviceOccurrenceType = result.priReq.Schedule_or_On_Call__c;
          //SDT-27720 - Price change fields add
          this.serviceBaselineId = result.priReq.Service_Baseline_ID__c;
          this.isPriceChangeRequest = result.priReq.IsPriceChangeRequest__c;
          //SDT-38987
          if(result.priReq.Pricing_Type__c != "PT")
            this.CreatedBy = "System Generated";
          else
            this.CreatedBy = result.priReq.CreatedBy.Name;
	    
          //Changes for SDT-26044
          this.pricingThresholdList =result.pricingThresholds;
          if(!this.responseRecord)
          {              
            this.responseRecord = '{"data":null,"problem":{"title":"No Connection","status":400,"errors":[{"code":null,"message":"We are currently facing issue in connecting API system. Please try later."},{"code":null,"message":"We are currently facing issue in connecting API system. Please try later."}]}}';
          }          

          setTimeout(() => {
            if (this.outputFieldList && this.responseRecord) {
              //console.log("showoutputScreen In if block");

              this.createOutputScreen(
                this.outputFieldList,
                this.responseRecord,
                null
              );
            }
            else{
              if(this.lineOfBusiness)
              {
                var inputData = [];
                inputData.push(this.lineOfBusiness);
                inputData.push(this.serviceOccurrenceType);
                inputData.push(this.isPriceChangeRequest);
                inputData.push(this.serviceBaselineId);
                fireEvent(this.pageRef, "setInputParam", inputData);
              }
            }
          },1000);
        })
        .catch((error) => {
          console.log("showoutputScreen : Catch " + error);
          this.error = error;
        });
    // }
    this.showoutput = true;
  }

  @wire(getFieldDetails, { objectAPiName }) wiredFieldList(result) {
    if (result.data) {
      this.outputFieldList = result;
    }
  }

  

  createOutputScreen(outputFieldList, responseAPI, recordId) {
    //console.log("In method createOutputScreen");

    var responseData = "";
    try {
      responseData = JSON.parse(responseAPI);
    } catch(e) {
      this.APIErrorMsg =
      AdministratorMessage +
      "\n" +
      responseAPI;
    }

    if (!responseData.data) {
      this.isAPIError = true;
      var divVisibility = this.template.querySelectorAll("div.clsErrorMessage");
      for (var items = 0; items < divVisibility.length; items++) {
        divVisibility[items].setAttribute("style", "display:block;");
      }

      if(!this.APIErrorMsg){
        var errorCode = responseData.problem.errors[0].code ? responseData.problem.errors[0].code : '';
        if(errorCode == "3PECON" || errorCode == "WMECON"){
          this.isAPIError = false;
          var divInfo = this.template.querySelectorAll("div.clspricingmsgoutput");
          for (var items = 0; items < divInfo.length; items++) {
            divInfo[items].setAttribute("style", "display:block;");
          }
          var newdivComMessage = document.createElement("div");
          var divIdName = "div1";
          newdivComMessage.setAttribute("id", divIdName);
          var comMessageDetailHTML =
          '<table class="slds-table slds-table_header-hidden slds-table_striped slds-p-vertical_x-small slds-max-medium-table--stacked" style="table-layout: fixed;"><tbody>';

          var msgCPR = '<tr class="slds-hint-parent"> <th data-label="" scope="row" style="width:25%;"> <div class="slds-truncate" title=""> ';
          comMessageDetailHTML += msgCPR + ' <p><b>Message</b></p> </div> </th><td data-label=""> <div class="slds-truncate" style="white-space: normal;" title="' + responseData.problem.errors[0].message + '">: ' + responseData.problem.errors[0].message + '</div> </td> </tr>';
          comMessageDetailHTML += " </tbody></table>";

          newdivComMessage.innerHTML = comMessageDetailHTML;
          var messageDetailContainer = this.template.querySelectorAll(
            "div.apimessaged"
          );
          messageDetailContainer[0].appendChild(newdivComMessage);
          this.messageCommentHTML = newdivComMessage.innerHTML;        
        }
        else{
          this.APIErrorMsg = responseData.problem.errors[0].message;

          if (this.APIErrorMsg.includes("System.NullReferenceException")) {
            this.APIErrorMsg =
              AdministratorMessage +
              "\n" +
              this.APIErrorMsg;
          }
        } 
      }
    } else {
      this.isAPIError = false;

    if (this.outputFieldList.data) {
        var resultAPIJson = responseData;
        var lob = this.lineOfBusiness;
        var apiContractType = resultAPIJson.data["contractType"] ? resultAPIJson.data["contractType"].toLowerCase() : "";
          
        //Implement the new message screen
        if (!apiContractType ||
        (  apiContractType != WM_Franchise && apiContractType != Competitor 
        && apiContractType != Pre_Determined_Pricing && apiContractType != Third_Party_Agreement)) {
         // console.log("In method createOutputScreen - In If");

          var divInfo = this.template.querySelectorAll("div.clspricingoutput");
          for (var items = 0; items < divInfo.length; items++) {
            divInfo[items].setAttribute("style", "display:block;");
          }

          var serviceDetailFields = outputFieldList.data.filter(function (
            entry
          ) {
            return entry.ParentContainer__c === Service_Details && (entry.Condition__c === lob || entry.Condition__c === "All");
          });

          var pricingDetailFields = outputFieldList.data.filter(function (
            entry
          ) {
            return entry.ParentContainer__c === Pricing_Details  && (entry.Condition__c === lob || entry.Condition__c === "All");
          });

          // Service Detail Section Start
          var conts = serviceDetailFields;
          var sourceCost;
          var priceType;
          for (var key in conts) {
            var fieldSeq = conts[key]["Sequence__c"];
            var newRow = false;
            if (fieldSeq % 2 != 0) {
              newRow = true;
            }

            if(conts[key]["FieldName__c"] == Minimum_Tons)
            {
              var responseServiceChangesService = resultAPIJson.data["serviceCharges"];
              
              if(responseServiceChangesService){
                var minimumTonsServiceDetail = responseServiceChangesService.filter(function (entry) {
                  return entry.name.toLowerCase() === Minimum_Tons_Recycling;
                });

                var allOtherminimumTonsServiceDetail = responseServiceChangesService.filter(function (entry) {
                  return entry.name.toLowerCase() === All_Other_Minimum_Tonnage;
                });

                this.mapData.push({
                //  value: minimumTonsServiceDetail[0] && minimumTonsServiceDetail[0].price != null ? minimumTonsServiceDetail[0].price :  (allOtherminimumTonsServiceDetail[0] && allOtherminimumTonsServiceDetail[0].price != null ? allOtherminimumTonsServiceDetail[0].price : ''),
                value: (resultAPIJson.data["materialCode"] == 'C' || resultAPIJson.data["materialCode"] == 'SSR') ? minimumTonsServiceDetail[0] && minimumTonsServiceDetail[0].price != null ? minimumTonsServiceDetail[0].price : '' : (allOtherminimumTonsServiceDetail[0] && allOtherminimumTonsServiceDetail[0].price != null ? allOtherminimumTonsServiceDetail[0].price : ''),
                key: conts[key]["FieldName__c"],
                seq: conts[key]["Sequence__c"],
                isNewRow: newRow,
                });
              }
              else{
                this.mapData.push({
                value: '',
                key: conts[key]["FieldName__c"],
                seq: conts[key]["Sequence__c"],
                isNewRow: newRow,
                });
              }
            }
            else if (conts[key]["FieldName__c"] == Frequency_Type || conts[key]["FieldName__c"] == Frequency_Count || conts[key]["FieldName__c"] == Quantity)
            {
              var responseValue = "";
              if(conts[key]["FieldName__c"] == Frequency_Type){
                responseValue = this.frequencyType ? this.frequencyType : '';
              }
              else if(conts[key]["FieldName__c"] == Frequency_Count){
                responseValue = this.frequencyCount ? this.frequencyCount : '';
              }
              else if(conts[key]["FieldName__c"] == Quantity){
                responseValue = this.quantity;
              }
              this.mapData.push({
                value: responseValue,
                key: conts[key]["FieldName__c"],
                seq: conts[key]["Sequence__c"],
                isNewRow: newRow,
              });
            }
            else if(conts[key]["FieldName__c"] == lblDisposal_Facility || conts[key]["FieldName__c"] == lblDisposition)
            {
              var responseValue = "";
              if(conts[key]["FieldName__c"] == lblDisposal_Facility){
                responseValue = resultAPIJson.data["disposalFacilityName"];
              }
              else if(conts[key]["FieldName__c"] == lblDisposition){
                responseValue = resultAPIJson.data["disposalFacilityType"];
              }

              this.mapData.push({
                value: responseValue ? responseValue : "",
                key: conts[key]["FieldName__c"],
                seq: conts[key]["Sequence__c"],
                isNewRow: newRow,
              });
            }
            else if(conts[key]["FieldName__c"] == "Rate Type Pickup")
            {
              var valueRTP = "";
              if(resultAPIJson.data["commercial"]["pricingMethodPickupDescription"])
              {
                valueRTP = resultAPIJson.data["commercial"]["pricingMethodPickupDescription"];
              }
              else if(resultAPIJson.data["commercial"]["pricingMethodCodeDescription"]){
                valueRTP = resultAPIJson.data["commercial"]["pricingMethodCodeDescription"];
              }

              this.mapData.push({
                value: valueRTP,
                key: conts[key]["FieldName__c"],
                seq: conts[key]["Sequence__c"],
                isNewRow: newRow,
              });
            }
            else if(conts[key]["FieldName__c"] == "Baseline ID")
            {
              this.mapData.push({
                value: this.serviceBaselineId ? this.serviceBaselineId : '',
                key: conts[key]["FieldName__c"],
                seq: conts[key]["Sequence__c"],
                isNewRow: newRow,
              });
            }
            else if(conts[key]["APIParentNode__c"]){
                var apiFieldValue = resultAPIJson.data[conts[key]["APIParentNode__c"]] ?
                                    resultAPIJson.data[conts[key]["APIParentNode__c"]][conts[key]["APIFieldName__c"]] : 
                                    resultAPIJson.data[conts[key]["APIFieldName__c"]] ;
                
                if(conts[key]["FieldName__c"] == Diversion_Percentage){
                  apiFieldValue = apiFieldValue ? apiFieldValue + '%' : '';
                } 

                this.mapData.push({
                  value: apiFieldValue
                    ? apiFieldValue
                    : "",
                  key: conts[key]["FieldName__c"],
                  seq: conts[key]["Sequence__c"],
                  isNewRow: newRow,
                });
            }
            else
            {
              this.mapData.push({
                value: resultAPIJson.data[conts[key]["APIFieldName__c"]]
                  ? resultAPIJson.data[conts[key]["APIFieldName__c"]]
                  : "",
                key: conts[key]["FieldName__c"],
                seq: conts[key]["Sequence__c"],
                isNewRow: newRow,
              }); //Here we are creating the array to show on UI.
            }
          }

          if (this.mapData.length > 0) {
            var newdivService = document.createElement("div");
            var divIdName = "div1";
            newdivService.setAttribute("id", divIdName);

            // Add Substituted Container Fields
            var alternateContainerCode = resultAPIJson.data["overridableEquipmentSizeCode"], alternateContainerName = resultAPIJson.data["overridableEquipmentSizeName"];
            var alternateContainerNotification = '';

            if(alternateContainerCode && alternateContainerName)
            {
              alternateContainerNotification = '<div class="slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_warning" role="alert">'
              + Alternate_Container_Message + ' ' + alternateContainerName + '</div>';
            }

            //Changes for SDT-24009 Start done by jatan
            var isCostOnly = resultAPIJson.data["isCostOnly"];
            var CostOnlyNotification = '';
            if(isCostOnly)
            {
              CostOnlyNotification = '<div class="slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_warning" role="alert">' +
              '<h2>' + 'Please Note: This customer is not eligible for automated pricing. Response is COST ONLY.' + '</h2></div>';
            }
            //End

            var serviceDetailHTML =  alternateContainerNotification + CostOnlyNotification +
              '<table class="slds-table slds-table_header-hidden slds-table_striped slds-var-p-vertical_x-small" style="table-layout: fixed;"><tbody>';

            for (var sdFields in this.mapData) {
              if (this.mapData[sdFields].isNewRow) {
                serviceDetailHTML +=
                  '<tr class="slds-hint-parent"> <th data-label="" scope="row"> <div class="slds-truncate" title= ' +
                  this.mapData[sdFields].key +
                  "> <p><b>" +
                  this.mapData[sdFields].key +
                  '</b></p> </div> </th> <td data-label=""> <div class="slds-truncate" title="' +
                  this.mapData[sdFields].value +
                  '">: ' +
                  this.mapData[sdFields].value +
                  "</div> </td>";
              } else {
                serviceDetailHTML +=
                  '<th data-label="" scope="row"> <div class="slds-truncate" title=' +
                  this.mapData[sdFields].key +
                  "> <p><b>" +
                  this.mapData[sdFields].key +
                  '</b></p> </div> </th> <td data-label=""> <div class="slds-truncate" title="' +
                  this.mapData[sdFields].value +
                  '">: ' +
                  this.mapData[sdFields].value +
                  "</div> </td> </tr>";
              }
              if(this.mapData[sdFields].key == "Source Code"){
                sourceCost = this.mapData[sdFields].value ? this.mapData[sdFields].value.substring(0,2) : '';
              }
              if(this.mapData[sdFields].key == "Customer Price Type"){
                priceType = this.mapData[sdFields].value;
              }
            }
            serviceDetailHTML += " </tbody></table>";

            newdivService.innerHTML = serviceDetailHTML;
            var seviceDetailContainer = this.template.querySelectorAll(
              "div.serviced"
            );
            seviceDetailContainer[0].appendChild(newdivService);
            this.serviceCommentsHTML = newdivService.innerHTML;
          }
          // Service Detail Section End

          // Pricing Detail Section Start

          this.mapData = [];
          var conts = pricingDetailFields;
          var increaseCostNotification = "";
          var newdivPrice = document.createElement("div");
          var divIdName = "div1";
          var currSymbol = resultAPIJson.data["currencyCode"] != null ? resultAPIJson.data["currencyCode"] : "USD";
          var source_Cost = resultAPIJson.data["costSource"] != null ? resultAPIJson.data["costSource"].substring(0,2) : "";
          newdivPrice.setAttribute("id", divIdName);
          var pricingFieldCost = "";

          if(lob == Rolloff && (source_Cost && source_Cost == "WM") && (priceType && (priceType != "Exhibit Pricing" && priceType != "Exhibit Cost Pricing"))){ 
            var disposalCost;
            
              //Changes for SDT-26044
              this.pricingThresholdList.forEach(threshold =>{ 
                if(threshold.Label == Price_Per_Haul)
                {
                  this.pricingMinThreshold = threshold.Minimum_Value__c;
                  this.pricingMaxThreshold = threshold.Maximum_Value__c;
                }
              }); 

              for (var key in conts) {
                if(conts[key]["FieldName__c"] == Price_Per_Haul)
                {
                  pricingFieldCost = resultAPIJson.data["rollOff"][conts[key]["APIFieldName__c"].split("|")[0]]? resultAPIJson.data["rollOff"][conts[key]["APIFieldName__c"].split("|")[0]].toFixed(2) : "";
                }

                if(conts[key]["FieldName__c"] == Disposal)
                {
                  disposalCost = resultAPIJson.data["rollOff"][conts[key]["APIFieldName__c"].split("|")[0]]? resultAPIJson.data["rollOff"][conts[key]["APIFieldName__c"].split("|")[0]].toFixed(2) : "";
                }
              }
              //if((pricingFieldCost && pricingFieldCost > 100000) || disposalCost < 0){
              var thresholdMsg='Haul Cost is @Value, please confirm or re-procure if required';
              if(pricingFieldCost && this.pricingMinThreshold!= null && pricingFieldCost < this.pricingMinThreshold){
                increaseCostNotification = '<div class="slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_warning" role="alert">' +
                '<h2>' + thresholdMsg.replace('@Value', '<$'+ this.pricingMinThreshold) + '</h2></div>';
                //'<h2>' + Cost_Compare_Message + '</h2></div>';
              }

              if(pricingFieldCost &&  this.pricingMaxThreshold !=null && pricingFieldCost > this.pricingMaxThreshold){
                increaseCostNotification = '<div class="slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_warning" role="alert">' +
                '<h2>' + thresholdMsg.replace('@Value', '>$'+ this.pricingMaxThreshold) + '</h2></div>';
              }
          }

          var pricingDetailHTML = increaseCostNotification +
            '<table class="slds-table slds-table_header-hidden slds-table_striped"> <tbody><tr class="slds-hint-parent"> ' +
            '<th data-label="" scope="row" style="width:20%"> </th>' + 
            '<td data-label="CostRange" style="width:20%"><div class="slds-truncate2 slds-text-align_right"><b>Cost Steps</b></div></td>' +
            '<td data-label="CostUOM" style="width:10%"><div class="slds-truncate2 slds-text-align_center"><b>UOM</b></div></td>' + 
            '<td data-label="CostSymbol" style="width:5%"><div class="slds-truncate2 slds-text-align_center"></div></td>' + 
            '<td data-label="Cost" style="width:5%"> <div class="slds-truncate2 slds-text-align_right"><b>Unit Cost</b></div> </td>' + 
            '<td data-label="PriceRange" style="width:20%"><div class="slds-truncate2 slds-text-align_right"><b>Price Steps</b></div</td>' + 
            '<td data-label="PriceUOM" style="width:10%"><div class="slds-truncate2 slds-text-align_center"><b>UOM</b></div></td>' + 
            '<td data-label="PriceSymbol" style="width:5%"><div class="slds-truncate2 slds-text-align_right"></div></td>' + 
            '<td data-label="Price" style="width:5%"> <div class="slds-truncate2 slds-text-align_right"><b>Unit Price</b></div> </td> </tr>';
          
          var pricingFieldPrice = "";
          var apiFieldValueCost = "";
          var apiFieldValuePrice = "";
          var costUOM = "";
          var priceUOM = "";
          var costSymbol = "";
          var priceSymbol = "";
          var responseDisposalsStep = "";
          var responseDisposalsStepCost = "";
          var responseDisposalsStepPrice = "";
          var priceRange = "";
          var costRange = "";
          
          if(lob == Rolloff && resultAPIJson.data["rollOff"]!=null){
            responseDisposalsStep = resultAPIJson.data["rollOff"]["stepDisposals"];
            responseDisposalsStepCost = resultAPIJson.data["rollOff"]["disposalCost"];
            responseDisposalsStepPrice = resultAPIJson.data["rollOff"]["disposalPrice"];

            if(responseDisposalsStepCost && responseDisposalsStepPrice)
            {
              responseDisposalsStep = null;
            }
          }
          var stepCount=0;
          for (var key in conts) {

            if(conts[key]["APIFieldName__c"].split('|')[0] != "serviceCharges"){

                if(conts[key]["FieldName__c"] == Disposal && responseDisposalsStep){
                    for(var step in responseDisposalsStep){
                      pricingDetailHTML +=
                      '<tr class="slds-hint-parent"> <th data-label="" scope="row" style="width:20%"> <div class="slds-truncate2" style="white-space: normal;" title="' +
                      "Disposal" +
                      '"> <p><b>' +
                      "Disposal" +
                      '</b></p> </div> </th>';
                      
                      apiFieldValueCost = responseDisposalsStepCost !=null ? responseDisposalsStepCost : responseDisposalsStep[step]["cost"] != null ? responseDisposalsStep[step]["cost"] :null;
                      apiFieldValuePrice = responseDisposalsStepPrice !=null ? responseDisposalsStepPrice : responseDisposalsStep[step]["price"] != null ? responseDisposalsStep[step]["price"]: null;
                      
                      if(stepCount!=0)
                      {
                        if(responseDisposalsStepCost !=null) 
                          apiFieldValueCost =null;
                        if(responseDisposalsStepPrice !=null) 
                          apiFieldValuePrice =null;
                      }
                      costUOM = (resultAPIJson.data["equipmentUOM"] && apiFieldValueCost != null) ? resultAPIJson.data["equipmentUOM"] : "";
                      priceUOM = (resultAPIJson.data["equipmentUOM"] && apiFieldValuePrice != null) ? resultAPIJson.data["equipmentUOM"] : "";
                      pricingFieldCost = apiFieldValueCost != null  ? apiFieldValueCost.toFixed(2) : "";
                      costSymbol = apiFieldValueCost != null  ? currSymbol : "";
                      pricingFieldPrice = apiFieldValuePrice != null  ? apiFieldValuePrice.toFixed(2) : "";
                      priceSymbol = apiFieldValuePrice != null  ? currSymbol : "";
                      if(responseDisposalsStep[step]["range"])
                      {
                        costRange =  responseDisposalsStep[step]["range"];
                        priceRange = responseDisposalsStep[step]["range"];
                      }
                      else
                      {
                        costRange = responseDisposalsStepCost ? "" : responseDisposalsStep[step]["costRange"] ? responseDisposalsStep[step]["costRange"] :"";
                        priceRange = responseDisposalsStepPrice ? "" : responseDisposalsStep[step]["priceRange"] ? responseDisposalsStep[step]["priceRange"] :"" ;
                      }
                      pricingDetailHTML +=
                      '<td data-label="CostRange" style="width:20%"><div class="slds-truncate2 slds-text-align_right">'+
                      costRange +
                      '<td data-label="CostUOM" style="width:10%"> <div class="slds-truncate2 slds-text-align_center">' + 
                      costUOM +
                      '<td data-label="CostSymbol" style="width:5%"> <div class="slds-truncate2 slds-text-align_center">' + 
                      costSymbol +
                      '<td data-label="Cost" style="width:5%"> <div class="slds-truncate2 slds-text-align_right">' +
                      pricingFieldCost +
                      '<td data-label="PriceRange" style="width:20%"><div class="slds-truncate2 slds-text-align_right">'+
                      priceRange +
                      '<td data-label="PriceUOM" style="width:10%"> <div class="slds-truncate2 slds-text-align_right">' +
                      priceUOM +
                      '<td data-label="PriceSymbol" style="width:5%"> <div class="slds-truncate2 slds-text-align_right">' +
                      priceSymbol +
                      '</div> </td> <td data-label="Price" style="width:5%; margin-right:2%;"> <div class="slds-truncate2 slds-text-align_right">' +
                      pricingFieldPrice +
                      "</div> </td>";
                      pricingDetailHTML += " </tr>";
                      stepCount++;
                  }
                }
                else{
                    //Added logic for SDT-26477
                    if(conts[key]["FieldName__c"] == "Extra Pickup" && this.lineOfBusiness == "Commercial" && this.serviceOccurrenceType == "On-Call")
                    {
                      continue;
                    }
                    pricingDetailHTML +=
                    '<tr class="slds-hint-parent"> <th data-label="" scope="row" style="width:20%"> <div class="slds-truncate2" style="white-space: normal;" title="' +
                    conts[key]["FieldName__c"] +
                    '"> <p><b>' +
                    conts[key]["FieldName__c"] +
                    '</b></p> </div> </th>';
                    if (resultAPIJson.data[conts[key]["APIParentNode__c"]] !=null ){
                      apiFieldValueCost = conts[key]["FieldName__c"] != Pickup ? resultAPIJson.data[conts[key]["APIParentNode__c"]][conts[key]["APIFieldName__c"].split("|")[0]] : 
                                        resultAPIJson.data[conts[key]["APIParentNode__c"]][conts[key]["APIFieldName__c"].split("|")[0]] ?
                                        resultAPIJson.data[conts[key]["APIParentNode__c"]][conts[key]["APIFieldName__c"].split("|")[0]] :
                                        resultAPIJson.data[conts[key]["APIParentNode__c"]]["cost"];
                                        
                    apiFieldValuePrice = conts[key]["FieldName__c"] != Pickup ? resultAPIJson.data[conts[key]["APIParentNode__c"]][conts[key]["APIFieldName__c"].split("|")[1]]: 
                                        resultAPIJson.data[conts[key]["APIParentNode__c"]][conts[key]["APIFieldName__c"].split("|")[1]] ?
                                        resultAPIJson.data[conts[key]["APIParentNode__c"]][conts[key]["APIFieldName__c"].split("|")[1]] :
                                        resultAPIJson.data[conts[key]["APIParentNode__c"]]["price"];    
                    }
                                                        

                    // costUOM = conts[key]["FieldName__c"] == Disposal || conts[key]["FieldName__c"] == Pickup ? resultAPIJson.data["equipmentUOM"] ? resultAPIJson.data["equipmentUOM"] : "" : "";
                    // priceUOM = conts[key]["FieldName__c"] == Disposal || conts[key]["FieldName__c"] == Pickup ? resultAPIJson.data["equipmentUOM"] ? resultAPIJson.data["equipmentUOM"] : "" : "";
                    costUOM = "";
                    priceUOM = "";
                    if(conts[key]["FieldName__c"] == Disposal)
                    {
                      if(resultAPIJson.data["equipmentUOM"])
                      {
                        costUOM = resultAPIJson.data["equipmentUOM"];
                        priceUOM = resultAPIJson.data["equipmentUOM"];
                      }
                    }

                    if(conts[key]["FieldName__c"] == Pickup)
                    {
                      if(this.lineOfBusiness == "Commercial" && this.serviceOccurrenceType == "On-Call")
                      {
                        costUOM = "Event";
                        priceUOM = "Event";
                      }
                      else if(resultAPIJson.data["equipmentUOM"])
                      {
                        costUOM = resultAPIJson.data["equipmentUOM"];
                        priceUOM = resultAPIJson.data["equipmentUOM"];
                      }
                    }
                    pricingFieldCost = apiFieldValueCost !=null && apiFieldValueCost !='' ? apiFieldValueCost.toFixed(2) : "";
                    costSymbol = apiFieldValueCost !=null && apiFieldValueCost !=''  ? currSymbol : "";
                    pricingFieldPrice = apiFieldValuePrice !=null && apiFieldValuePrice !='' ? apiFieldValuePrice.toFixed(2) : "";
                    priceSymbol = apiFieldValuePrice !=null && apiFieldValuePrice !=''  ? currSymbol : "";

                    pricingDetailHTML +=
                    '<td data-label="CostRange" style="width:20%"><div class="slds-truncate2 slds-text-align_right"></div> </td>'+
                    '<td data-label="CostUOM" style="width:10%"> <div class="slds-truncate2 slds-text-align_center">' + 
                    costUOM +
                    '<td data-label="CostSymbol" style="width:5%"> <div class="slds-truncate2 slds-text-align_center">' + 
                    costSymbol +
                    '<td data-label="Cost" style="width:5%"> <div class="slds-truncate2 slds-text-align_right">' +
                    pricingFieldCost +
                    '<td data-label="PriceRange" style="width:20%"><div class="slds-truncate2 slds-text-align_right"></div> </td>'+
                    '<td data-label="PriceUOM" style="width:10%"> <div class="slds-truncate2 slds-text-align_right">' + 
                    priceUOM +
                    '<td data-label="PriceSymbol" style="width:5%"> <div class="slds-truncate2 slds-text-align_right">' + 
                    priceSymbol +
                    '</div> </td> <td data-label="Price" style="width:5%; margin-right:2%;"> <div class="slds-truncate2 slds-text-align_right">' +
                    pricingFieldPrice +
                    "</div> </td>";
                    pricingDetailHTML += " </tr>";
                }
            }
            else{
                  var responseServiceChanges = resultAPIJson.data["serviceCharges"];
                  if (responseServiceChanges) {
                  var fieldName = conts[key]["APIFieldName__c"].split('|')[1];
                  var priceDetailExistInResponse = responseServiceChanges.filter(function (entry) {
                    return entry.name.toLowerCase() === fieldName;
                  });


                  var costValueType = "";
                  var priceValueType = "";
                  var actionName = "";
                  if (priceDetailExistInResponse.length > 0 && priceDetailExistInResponse[0].name.toLowerCase() == fieldName) {
                    costValueType = priceDetailExistInResponse[0].costValueType;
                    priceValueType = priceDetailExistInResponse[0].priceValueType;
                    actionName = priceDetailExistInResponse[0].actionName;
                    pricingFieldCost = priceDetailExistInResponse[0].cost;
                    pricingFieldPrice = priceDetailExistInResponse[0].price;
                    costUOM = priceDetailExistInResponse[0].costUOM ? priceDetailExistInResponse[0].costUOM : "";
                    priceUOM = priceDetailExistInResponse[0].priceUOM ? priceDetailExistInResponse[0].priceUOM : "";
                    costSymbol = "";
                    priceSymbol = "";

    
                    if(pricingFieldCost != null){
                      if(costValueType && costValueType.toLowerCase() === Percent.toLowerCase()){
                          pricingFieldCost = pricingFieldCost.toFixed(2) + "%";
                      }
                      else{
                          pricingFieldCost =  pricingFieldCost.toFixed(2);
                          costSymbol = currSymbol;
                      }
                    }
                    else
                    {
                      pricingFieldCost = '';
                    } 
                    // Comment the repeated code, aleady handle on above block.
                    // else if(pricingFieldCost!=null){
                    //   pricingFieldCost = pricingFieldCost.toFixed(2);
                    //   costSymbol = currSymbol;
                    // }

                    if(pricingFieldPrice != null){
                      if(priceValueType && priceValueType.toLowerCase() === Percent.toLowerCase()){
                          pricingFieldPrice = pricingFieldPrice.toFixed(2) + "%";
                      }
                      else{
                          pricingFieldPrice = pricingFieldPrice.toFixed(2);
                          priceSymbol = currSymbol;
                      }
                    }
                    else
                    {
                      pricingFieldPrice = '';
                    }
                    // Comment the repeated code, aleady handle on above block.
                    // else if(pricingFieldPrice!=null){
                    //   pricingFieldPrice = pricingFieldPrice.toFixed(2);
                    //   priceSymbol = currSymbol;
                    // }

                    if(actionName && actionName.toLowerCase() == Exclude){
                      pricingFieldPrice = "Exclude";
                    }

                    if(pricingFieldCost || pricingFieldPrice)
                    {
                      pricingDetailHTML +=
                      '<tr class="slds-hint-parent"> <th data-label="" scope="row" style="width:20%"> <div class="slds-truncate2" style="white-space: normal;" title="' +
                      priceDetailExistInResponse[0].name +
                      '"> <p><b>' +
                      priceDetailExistInResponse[0].name +
                      "</b></p> </div> </th>";

                      if(pricingFieldCost==null){
                        pricingFieldCost = "";
                      }

    
                      pricingDetailHTML +=
					            '<td data-label="CostRange" style="width:20%"><div class="slds-truncate2 slds-text-align_right"></div> </td>'+
                      '<td data-label="CostUOM" style="width:10%"> <div class="slds-truncate2 slds-text-align_center">' + 
                      (pricingFieldPrice == "Exclude" ? "" : costUOM) + 
                      '<td data-label="CostSymbol" style="width:5%"> <div class="slds-truncate2 slds-text-align_center">' + 
                      (pricingFieldPrice == "Exclude" ? "" : costSymbol) + 
                      '<td data-label="Cost" style="width:5%"> <div class="slds-truncate2 slds-text-align_right">' +
                      pricingFieldCost +
					            '<td data-label="PriceRange" style="width:20%"><div class="slds-truncate2 slds-text-align_right"></div> </td>'+
                      '</div> </td> <td data-label="PriceUOM" style="width:10%"> <div class="slds-truncate2 slds-text-align_right">' + 
                      (pricingFieldPrice == "Exclude" ? "" : priceUOM) + 
                      '</div> </td> <td data-label="PriceSymbol" style="width:5%"> <div class="slds-truncate2 slds-text-align_right">' + 
                      (pricingFieldPrice == "Exclude" ? "" : priceSymbol) +
                      '<td data-label="Price" style="width:5%; margin-right:2%;"> <div class="slds-truncate2 slds-text-align_right">' +
                      pricingFieldPrice +
                      "</div> </td>";
    
                      pricingDetailHTML += " </tr>";
                     }
                  }
                }
            }
          }
          

          pricingDetailHTML += " </tbody></table>";

          newdivPrice.innerHTML = pricingDetailHTML;
          var pricingDetailContainer = this.template.querySelectorAll( "div.pricingd");
          pricingDetailContainer[0].appendChild(newdivPrice);
          this.priceCommentHTML = newdivPrice.innerHTML;
          // Pricing Container End

          // Regulatory Fee Container Start
          var responseRegulatoryFee = resultAPIJson.data["tpMetaData"] ? resultAPIJson.data["tpMetaData"]["regulatoryFees"] ? resultAPIJson.data["tpMetaData"]["regulatoryFees"] : "" : "";
          if(responseRegulatoryFee){
            
            responseRegulatoryFee.sort(this.GetSortOrder("order"));

            var divInfo = this.template.querySelectorAll("div.clspricingrfoutput");
            for (var items = 0; items < divInfo.length; items++) {
              divInfo[items].setAttribute("style", "display:block;");
            }            

            var rfName = "", rfUOM = "", rfCost = "", rfPercentageBasedOrCompounded = "", rfAppliesToDisposal = "", rfAppliesToHaul = "", rfAppliesToRental = "", rfBasis = "", rfOrder = "", rfComment = ""; 
            var newdivRegulatory = document.createElement("div");
            var divIdName = "div1";
            newdivRegulatory.setAttribute("id", divIdName);
            //style="table-layout: fixed; broder: grey;" border="1"
            var regulatoryFeeHTML =  alternateContainerNotification + CostOnlyNotification +
              '<table class="slds-table slds-table_header-hidden slds-table_striped slds-var-p-vertical_x-small" style="table-layout: fixed;"><tbody>';
            
            regulatoryFeeHTML +=
              '<tr class="slds-hint-parent"> ' +
              '<th data-label="" scope="row"><div class="slds-truncate" title="'+lblName+'"><p><b>'+lblName+'</b></p></div></th>' +
              '<th data-label="" scope="row"><div class="slds-truncate" title="'+lblCost+'"><p><b>'+lblCost+'</b></p></div></th>' +
              '<th data-label="" scope="row"><div class="slds-truncate slds-cell-wrap" title="'+lblPercent_Base_or_Compounded+'"><p><b>'+lblPercent_Base_or_Compounded+'</b></p></div></th>' +
              '<th data-label="" scope="row"><div class="slds-truncate slds-cell-wrap" title="'+lblApplies_to_Disposal+'"><p><b>'+lblApplies_to_Disposal+'</b></p></div></th>' +
              '<th data-label="" scope="row"><div class="slds-truncate slds-cell-wrap" title="'+lblApplies_to_Haul+'"><p><b>'+lblApplies_to_Haul+'</b></p></div></th>' +
              '<th data-label="" scope="row"><div class="slds-truncate slds-cell-wrap" title="'+lblApplies_to_Rental+'"><p><b>'+lblApplies_to_Rental+'</b></p></div></th>' +
              '<th data-label="" scope="row"><div class="slds-truncate" title="'+lblBasis+'"><p><b>'+lblBasis+'</b></p></div></th>' +
              '<th data-label="" scope="row"><div class="slds-truncate" title="'+lblUOM+'"><p><b>'+lblUOM+'</b></p></div></th>' +
              '<th data-label="" scope="row"><div class="slds-truncate" title="'+lblOrder+'"><p><b>'+lblOrder+'</b></p></div></th></tr>';

            for(var rfFields in responseRegulatoryFee){
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

              regulatoryFeeHTML +=
              '<tr class="slds-hint-parent"> ' +
              '<td data-label=""> <div class="slds-truncate slds-cell-wrap" title="' + rfName + '">' + rfName + '</div></td>'+
              '<td data-label=""> <div class="slds-truncate" title="' + rfCost + '">' + rfCost + '</div></td>'+
              '<td data-label=""> <div class="slds-truncate" title="' + rfPercentageBasedOrCompounded + '">' + rfPercentageBasedOrCompounded + '</div></td>'+
              '<td data-label=""> <div class="slds-truncate" title="' + rfAppliesToDisposal + '">' + rfAppliesToDisposal + '</div></td>'+
              '<td data-label=""> <div class="slds-truncate" title="' + rfAppliesToHaul + '">' + rfAppliesToHaul + '</div></td>'+
              '<td data-label=""> <div class="slds-truncate" title="' + rfAppliesToRental + '">' + rfAppliesToRental + '</div></td>'+
              '<td data-label=""> <div class="slds-truncate" title="' + rfBasis + '">' + rfBasis + '</div></td>'+
              '<td data-label=""> <div class="slds-truncate" title="' + rfUOM + '">' + rfUOM + '</div></td>'+
              '<td data-label=""> <div class="slds-truncate" title="' + rfOrder + '">' + rfOrder + '</div></td>' +
              '</tr>';

              if(rfComment){
                regulatoryFeeHTML +=
                '<tr class="slds-hint-parent"> ' +
                '<td colspan="2" data-label=""> <div class="slds-truncate" title="' + rfName + '"><p><b>' + rfName + " Comments:"  + '</b></p></div></td>'+
                '<td colspan="6" data-label=""> <div class="slds-truncate slds-cell-wrap" title="' + rfComment + '">' + rfComment + '</div></td>'+
                '</tr>';
              }
            }
            regulatoryFeeHTML += " </tbody></table>";

            newdivRegulatory.innerHTML = regulatoryFeeHTML;
            var regulatoryFeeContainer = this.template.querySelectorAll(
              "div.regulatoryfeed"
            );
            regulatoryFeeContainer[0].appendChild(newdivRegulatory);
            this.regulatoryFeeCommentHTML = newdivRegulatory.innerHTML;
          }
          // Regulatory Fee Container End
          this.messageCommentHTML = "";
        }
        else{
              this.serviceCommentsHTML = "";
              this.priceCommentHTML = "";
              this.regulatoryFeeCommentHTML = "";

              var divInfo = this.template.querySelectorAll("div.clspricingmsgoutput");
              for (var items = 0; items < divInfo.length; items++) {
                divInfo[items].setAttribute("style", "display:block;");
              }

              var newdivMessage = document.createElement("div");
              var divIdName = "div1";
              newdivMessage.setAttribute("id", divIdName);
              var messageDetailHTML =
              '<table class="slds-table slds-table_header-hidden slds-table_striped slds-p-vertical_x-small slds-max-medium-table--stacked" style="table-layout: fixed;"><tbody>';

              var msgTR1 = '<tr class="slds-hint-parent"> <th data-label="" scope="row" style="width:25%;"> <div class="slds-truncate" title=""> ';
              if(apiContractType === WM_Franchise){
                messageDetailHTML += msgTR1 + ' <p><b>Message</b></p> </div> </th><td data-label=""> <div class="slds-truncate" style="white-space: normal;" title="' + zoneFranchiseMsg + '">: ' + zoneFranchiseMsg + '</div> </td> </tr>';
                messageDetailHTML += msgTR1 + ' <p><b>Market</b></p> </div> </th><td data-label=""> <div class="slds-truncate" title="'+ lblMarket_WM_Franchise +'">: ' + lblMarket_WM_Franchise + '</div> </td> </tr>';
              }
              else if(apiContractType === Competitor){
                messageDetailHTML += msgTR1 + ' <p><b>Message</b></p> </div> </th> <td data-label=""> <div class="slds-truncate" style="white-space: normal;" title="' + zoneCompetitorMsg + '">: ' + zoneCompetitorMsg + '</div> </td> </tr>';
                messageDetailHTML += msgTR1 + ' <p><b>Market</b></p> </div> </th><td data-label=""> <div class="slds-truncate" title="'+ lblMarket_Non_WM_Franchise +'">: '+ lblMarket_Non_WM_Franchise +'</div> </td> </tr>';
              }
              else if(apiContractType === Pre_Determined_Pricing){
                messageDetailHTML += msgTR1 + ' <p><b>Message</b></p> </div> </th> <td data-label=""> <div class="slds-truncate" style="white-space: normal;" title="' + zoneDeterminedMsg + '">: ' + zoneDeterminedMsg + '</div> </td> </tr>';
                messageDetailHTML += msgTR1 + ' <p><b>Market</b></p> </div> </th><td data-label=""> <div class="slds-truncate" title="'+ lblMarket_WM_Pre_Determined_Pricing +'">: ' + lblMarket_WM_Pre_Determined_Pricing + '</div> </td> </tr>';
              }
              else if(apiContractType === Third_Party_Agreement){
                messageDetailHTML += msgTR1 + ' <p><b>Message</b></p> </div> </th> <td data-label=""> <div class="slds-truncate" style="white-space: normal;" title="' + zone3PAMsg + '">: ' + zone3PAMsg + '</div> </td> </tr>';
                messageDetailHTML += msgTR1 + ' <p><b>Market</b></p> </div> </th><td data-label=""> <div class="slds-truncate" title="'+ lblMarket_WM_Third_Party_Agreement +'">: '+ lblMarket_WM_Third_Party_Agreement +'</div> </td> </tr>';
              }
              //Changes done for SDT-18954 by jatan
              var ZoneName = "", ZoneDescription = "" , zoneNote = "";
              ZoneName = resultAPIJson.data["zoneName"] ? resultAPIJson.data["zoneName"] : "";
              ZoneDescription = resultAPIJson.data["zoneDescription"] ? resultAPIJson.data["zoneDescription"] : "";
              zoneNote = resultAPIJson.data["zoneNotes"] ? resultAPIJson.data["zoneNotes"] : "";
              messageDetailHTML += msgTR1 + ' <p><b>Zone Name</b></p> </div> </th><td data-label=""> <div class="slds-truncate" style="white-space: normal;" title="' + ZoneName + '">: ' + ZoneName + '</div> </td> </tr>';
              messageDetailHTML += msgTR1 + ' <p><b>Zone Description</b></p> </div> </th><td data-label=""> <div class="slds-truncate" title="'+ ZoneDescription +'">: ' + ZoneDescription + '</div> </td> </tr>';
              //END
              var francisePricingLink = "", greenPagesLink = "";
              francisePricingLink = resultAPIJson.data["wmMetaData"] ? resultAPIJson.data["wmMetaData"]["francisePricingLink"] : null;
              greenPagesLink = resultAPIJson.data["wmMetaData"] ? resultAPIJson.data["wmMetaData"]["greenPagesLink"] : null;

              if(francisePricingLink){
                messageDetailHTML += msgTR1 + ' <p><b>Franchise Pricing Link</b></p> </div> </th> <td data-label=""> <div class="slds-truncate" title="">: <a href="' + francisePricingLink + '" target="_blank">' + francisePricingLink + '</a></div> </td> </tr>';
              }
              if(greenPagesLink){
                messageDetailHTML += msgTR1 + ' <p><b>Green Pages Link</b></p> </div> </th> <td data-label=""> <div class="slds-truncate" title="">: <a href="' + greenPagesLink + '" target="_blank">' + greenPagesLink + '</a></div> </td> </tr>';
              }
              //Changes done for SDT-18954 by jatan
              messageDetailHTML += msgTR1 + ' <p><b>Notes</b></p> </div> </th><td data-label=""> <div class="slds-truncate" title="'+ zoneNote +'">: ' + zoneNote + '</div> </td> </tr>';
              //END
              messageDetailHTML += " </tbody></table>";

              newdivMessage.innerHTML = messageDetailHTML;
              var messageDetailContainer = this.template.querySelectorAll(
                "div.apimessaged"
              );
              messageDetailContainer[0].appendChild(newdivMessage);
              this.messageCommentHTML = newdivMessage.innerHTML;
            }
          //console.log("In method createOutputScreen - Last");
      }
    }
    if(this.lineOfBusiness){
      var inputData = [];
      inputData.push(this.lineOfBusiness);
      inputData.push(this.serviceOccurrenceType);
      inputData.push(this.isPriceChangeRequest);
      inputData.push(this.serviceBaselineId);
      fireEvent(this.pageRef, "setInputParam", inputData);
    }
  }

  GetSortOrder(prop) {    
    return function(a, b) {    
        if (a[prop] > b[prop]) {    
            return 1;    
        } else if (a[prop] < b[prop]) {    
            return -1;    
        }    
        return 0;    
    }      
  }    
  
  // handleSubmit(event) {
  //   event.preventDefault(); // stop the form from submitting
  //   //const fields = event.detail.fields;
  //   const inputFields = JSON.stringify(event.detail);
  //   window.scrollTo(0, 0);
  //   //this.loadingSpinner = true;
  //   var data = JSON.parse(inputFields);

  //   // fields.Id = this.priceRequestId;
  //   // this.template.querySelector('lightning-record-edit-form').submit(fields);
  //   if (data.fields.Case__c) {
  //     this.case = data.fields.Case__c;

  //     getCaseDetailsById({ caseId: this.case }).then((result) => {
  //       this.caseNumber = result.CaseNumber;
  //       this.acornIssueId = result.Acorn_Issue_Id__c;
  //       this.acornTrackingNumber = result.Tracking_Number__c;
  //     });
  //     setTimeout(() => {
  //       updatePriceRequest({
  //         priceId: this.priceRequestId,
  //         caseId: this.case,
  //         PriceCaseComment: true,
  //         AcornIssueId: this.acornIssueId,
  //         CaseNumber: this.caseNumber,
  //         TrackingNumber: this.acornTrackingNumber,
  //       }).then((result) => {
  //         if(this.caseNumber){
  //           insertCaseComment({
  //             caseComment: this.CaseComment,
  //             caseId: this.case,
  //             caseNumber: this.caseNumber,
  //           })
  //             .then((result) => {
  //               this.isPriceCaseComment = true;
  //               fireEvent(this.pageRef, "setCaseNo", this.case);
  //               const evt = new ShowToastEvent({
  //                 title: Record_Update_Title,
  //                 message: Pricing_Success_Message,
  //                 variant: "success",
  //                 mode: "dismissable",
  //               });
  //               this.dispatchEvent(evt);
  //             })
  //             .catch((error) => {
  //               const evt = new ShowToastEvent({
  //                 title: Record_Update_Title,
  //                 message: Pricing_Fail_Message,
  //                 variant: "error",
  //                 mode: "dismissable",
  //               });
  //               this.dispatchEvent(evt);
  //             });

  //           this.bShowModal = false;
  //         }
          
  //       });
  //     },1000);
  //   } else {
  //     const evt = new ShowToastEvent({
  //       title: Pricing_Request_Title,
  //       message: Select_Case,
  //       variant: "warning",
  //       mode: "dismissable",
  //     });
  //     this.dispatchEvent(evt);
  //     //this.bShowModal = false;
  //   }
  // }

  // CopyPriceClick(event) {
  //   const recordId = event.target.value;
  //   getRequestNumber({ recordId: recordId })
  //     .then((result) => {
  //       this.case = result.priReq.Case__c;
  //       this.responseRecord = result.priReq.APIRequestOutput__c;
  //       this.isPriceCaseComment = result.priReq.PriceCaseComment__c;
  //       this.priceRequestId = result.priReq.Id; //Create Case Comments for pricing:
  //       if (this.responseRecord) {
  //         this.CaseComment = this.createComment(this.responseRecord);

  //         if (!this.case) {
  //           this.bShowModal = true;
  //           return;
  //         } else {
  //           this.caseNumber = result.priReq.Case__r.CaseNumber;
  //         }

  //         updatePriceRequest({
  //           priceId: this.priceRequestId,
  //           caseId: this.case,
  //           PriceCaseComment: true,
  //         }).then((result) => {
  //           insertCaseComment({
  //             caseComment: this.CaseComment,
  //             caseId: this.case,
  //             caseNumber: this.caseNumber,
  //           })
  //             .then((result) => {
  //               this.isPriceCaseComment = true;
  //               const evt = new ShowToastEvent({
  //                 title: Record_Update_Title,
  //                 message: Pricing_Success_Message,
  //                 variant: "success",
  //                 mode: "dismissable",
  //               });
  //               this.dispatchEvent(evt);

  //               // this[NavigationMixin.Navigate]({
  //               //   type: 'standard__navItemPage',
  //               //   attributes: {
  //               //       apiName: 'Pricing'
  //               //   },
  //               // });
  //             })
  //             .catch((error) => {
  //               const evt = new ShowToastEvent({
  //                 title: Record_Update_Title,
  //                 message: Pricing_Fail_Message,
  //                 variant: "error",
  //                 mode: "dismissable",
  //               });
  //               this.dispatchEvent(evt);
  //             });
  //         });
  //       } else {
  //         const evt = new ShowToastEvent({
  //           title: "Error",
  //           message: Pricing_Availability,
  //           variant: "error",
  //           mode: "dismissable",
  //         });
  //         this.dispatchEvent(evt);
  //       }
  //     })
  //     .catch((error) => {
  //       this.error = error;
  //     });
  // }
  /* javaScipt functions start */

  // openModal() {
  //   // to open modal window set 'bShowModal' tarck value as true
  //   this.bShowModal = true;
  // }

  // closeModal() {
  //   // to close modal window set 'bShowModal' tarck value as false
  //   this.bShowModal = false;
  // }
  // handleCancel(event) {
  //   event.preventDefault();
  //   this.bShowModal = false;
  // }

  /* javaScipt functions end */

  // createComment(commentData) {
  //   var Case_Comment ="";

  //   Case_Comment = '<div class="slds-section slds-is-open slds-theme_default slds-table">'
  //   + '<h3 class="slds-section__title slds-theme_shade">'
  //   + '<div style="width: 100%;">'
  //   + '<span class="slds-truncate slds-p-horizontal_small" title="Section Title"><b>Pricing Request:'
  //   + this.RequestNo
  //   + '</b></span>'
  //   + '</div></h3></div>';
    
  //   if(this.serviceCommentsHTML && this.priceCommentHTML){
  //     Case_Comment += '<div class="slds-section slds-is-open slds-theme_default slds-table slds-p-bottom_x-small">'
  //     + '<h3 class="slds-section__title slds-theme_shade">'
  //     + '<span class="slds-truncate slds-p-horizontal_small" title="Section Title"><b>Service Details</b></span>'
  //     + '</h3>'
  //     + '<div>'
  //     + this.serviceCommentsHTML
  //     + '</div>'
  //     + '</div>';

  //     Case_Comment += '<div class="slds-section slds-is-open slds-theme_default slds-table slds-p-bottom_x-small">'
  //     + '<h3 class="slds-section__title slds-theme_shade">'
  //     + '<span class="slds-truncate slds-p-horizontal_small" title="Section Title"><b>Pricing Details</b></span>'
  //     + '</h3>'
  //     + '<div>'
  //     + this.priceCommentHTML
  //     + '</div>'
  //     + '</div>';

  //     if(this.regulatoryFeeCommentHTML){
  //       Case_Comment += '<div class="slds-section slds-is-open slds-theme_default slds-table slds-p-bottom_x-small">'
  //       + '<h3 class="slds-section__title slds-theme_shade">'
  //       + '<span class="slds-truncate slds-p-horizontal_small" title="Section Title"><b>Regulatory Fee Details</b></span>'
  //       + '</h3>'
  //       + '<div>'
  //       + this.regulatoryFeeCommentHTML
  //       + '</div>'
  //       + '</div>';
  //     }
  //   }
  //   else if(this.messageCommentHTML){
  //     Case_Comment += '<div class="slds-section slds-is-open slds-theme_default slds-table slds-p-bottom_x-small">'
  //     + '<h3 class="slds-section__title slds-theme_shade">'
  //     + '<span class="slds-truncate slds-p-horizontal_small" title="Section Title"><b>Output Message Details</b></span>'
  //     + '</h3>'
  //     + '<div>'
  //     + this.messageCommentHTML
  //     + '</div>'
  //     + '</div>';
  //   }
  //   return Case_Comment;
  // }
}
