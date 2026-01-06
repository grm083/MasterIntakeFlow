/**
 * @author       : Asset Availability Team
 * @description  : To show Delivery information from Availability API.
 * @History
 * -------
 * VERSION | AUTHOR                | DATE            | DESCRIPTION
 * 1.0     | Satnam Singh          | Aug 29, 2023    | User Story #SDT-32015
 ***/
import { LightningElement, api } from "lwc";
import getSLADatesForAllContainers from "@salesforce/apex/AAV_AvailbilityAppHelper.determineSLAForAllContainers";
import { createDeliveryArray, convertStrToDate, checkArray, assignErrors } from "c/aavUtilityMethods";
// Custom Labels
import LABEL_NO_WM_CONTAINER_APP from "@salesforce/label/c.AAV_No_WM_Container_Available_Message";//No WM Containers available at the location"

const LBL_HEADING_DELIVERY = "Delivery Availability";
const WARNING_TEXT_LIST = "warning-text-list";
const WARNING_TEXT_SINGLE = 'warning-text-single';
export default class AavAppOutputDeliverySection extends LightningElement {
  lbl_header = LBL_HEADING_DELIVERY;
  apiResponse;
  _availabilityData;
  @api
  set availabilityData(value) {
    if (value && value?.apiResponse) {
      this.showSpinner = 1;
      this._availabilityData = value;
      this.apiResponse = JSON.parse(value.apiResponse);
      this.updateDeliveries();
    }
  }
  get availabilityData() {
    return this._availabilityData;
  }
  supplier;
  displayedDeliveries;
  deliveryDaysError;
  get cssDeliveryClassError() {
    return this.deliveryDaysError.length === 1 ? WARNING_TEXT_SINGLE : WARNING_TEXT_LIST;
  }
  allDeliveries;
  checkDeliveryAvailability() {
    try {
      this.supplier = this.apiResponse?.data?.suppliers[0];
      return checkArray(this.supplier?.deliveryDays) && checkArray(this.supplier?.deliveries);
    } catch (error) {
      console.error(error);
    }
    return false;
  }
  updateDeliveries() {
    try {
      if (this.checkDeliveryAvailability()) {
        getSLADatesForAllContainers({
          inputWrapper: this.getInputWrapper()
        })
          .then((result) => {
            this.allDeliveries = this.supplier.deliveries.map((x) =>
              createDeliveryArray(x, convertStrToDate(result))
            );
            this.showSpinner = 0;
          })
          .catch((error) => this.showErrorMessage(error));
      }
      else {
        this.showSpinner = 0;
        this.deliveryDaysError = assignErrors(this.supplier.messages, LABEL_NO_WM_CONTAINER_APP);
      }
    } catch (err) {
      this.showErrorMessage(err);
    }
  }
  /*Capture Error Message*/
  showErrorMessage(error) {
    console.error("error->", error);
    this.showSpinner = false;
  }
  getInputWrapper() {
    let res = {};
    if (this.availabilityData)
      res = {
        location: this.availabilityData.location,
        account: this.availabilityData.accountId,
        duration: this.availabilityData.serviceType,
        productFamily: this.availabilityData.lineOfBusiness,
        project: null,
        productName: this.availabilityData.productName
      };
    return res;
  }
  //From Pagination
  handleListUpdated(event) {
    this.displayedDeliveries = event.detail.list;
  }
}