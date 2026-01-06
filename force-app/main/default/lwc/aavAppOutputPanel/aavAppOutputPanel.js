/**
 * @author       : Asset Availability Team
 * @description  : To show Alternate Conatiner for selected Products.
 * @History
 * -------
 * VERSION | AUTHOR                | DATE            | DESCRIPTION
 * 1.0     | Satnam Singh          | Aug 24, 2023    | User Story #SDT-32014
 ***/
import { LightningElement, api, wire, track } from "lwc";
import getAvailabilityRecord from "@salesforce/apex/AAV_AvailbilityAppHelper.getAvailabilityRecordById";

// custom Labels
import CUSTOM_API_ERROR_MSG from "@salesforce/label/c.AAV_Non_WM_Serviceable_Error_Message";//"Not WM Serviceable area, availability information is not accessible for third party vendors"
import API_ERRORED_OUT from "@salesforce/label/c.AAV_API_Failure_Error_Message";//"API did not return any data, please try again later";

const LBL_HEADER = "Asset Availability";
const LBL_HEADER_SERVICE_AVAILABILITY = "Service Availability";
const WARNING_TEXT_LIST = "warning-text-list";
const WARNING_TEXT_SINGLE = 'warning-text-single';

export default class AavAppOutputPanel extends LightningElement {
  showSpinner = true;
  @api recordId;
  // deliveries;
  @track outages;
  errorMessage;
  availabilityData;
  lbl_header = LBL_HEADER;
  lbl_header_service_availability = LBL_HEADER_SERVICE_AVAILABILITY;
  noContainerFlag = false;
  get cssClassError() {
    return this.errorMessage.length === 1 ? WARNING_TEXT_SINGLE : WARNING_TEXT_LIST;
  }
  @wire(getAvailabilityRecord, { recordId: "$recordId" })
  availabilityRecord({ error, data }) {
    let errorMsg;
    if (data) {
      if (data?.apiResult && data?.apiResponse) {
        let availabilityResponse = JSON.parse(data.apiResponse);
        let supplier = availabilityResponse?.data?.suppliers;
        if (this.checkArray(supplier)) {
          supplier = supplier[0];
          if (this.checkNonWM(supplier)) {
            errorMsg = supplier.messages;
          }
          //only positive Scenario -- WM available
          else {
            this.availabilityData = data;
            // this.deliveries = supplier.deliveries;
            this.outages = supplier.outages;
            // this.noContainerFlag = !(
            //   this.deliveryDays?.length && this.deliveries?.length
            // );
          }
        } else if (availabilityResponse?.data?.messages) {
          errorMsg = availabilityResponse.data.messages;
        }
      } else {
        this.errorMessage = [API_ERRORED_OUT];
      }
      if (errorMsg) {
        this.errorMessage = this.errorMessages(errorMsg);
      }
      this.showSpinner = false;
    } else if (error) {
      this.showErrorMessage(error);
    }
  }
  checkArray(arr) {
    return Boolean(Array.isArray(arr) && arr.length);
  }
  checkNonWM(supplier) {
    return !(this.checkArray(supplier.deliveryDays) || this.checkArray(supplier.serviceDays) ||
      this.checkArray(supplier.outages));
  }
  errorMessages(msg) {
    return this.checkArray(msg)
      ? msg.map((x) => x.description)
      : [CUSTOM_API_ERROR_MSG];
  }
  errorCallback(error, stack) {
    this.showErrorMessage(error, stack);
  }
  showErrorMessage(error, stack) {
    console.error(`Error: ${error}, Stack : ${stack}`);
    this.showSpinner = false;
  }
}