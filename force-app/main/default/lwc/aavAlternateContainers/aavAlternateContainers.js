/**
 * @author       : Asset Availability Team
 * @description  : To show Alternate Conatiner for selected Products.
 * @History
 * -------
 * VERSION | AUTHOR                | DATE            | DESCRIPTION
 * 1.0     | Satnam Singh          | June 2, 2023    | User Story #SDT-29789
 ***/
import { LightningElement, wire } from "lwc";
import { publish, subscribe, MessageContext } from "lightning/messageService";
import AAV_ALTERNATE_CONTAINER_CHANNEL from "@salesforce/messageChannel/ShowAlternateContainers__c";
import getSLADates from "@salesforce/apex/QuoteFavoritesController.determineSLAForAlternateProducts";
import updateAlternateProduct from "@salesforce/apex/QuoteProcurementController.updateAlternateProduct";
import getSizes from "@salesforce/apex/QuoteFavoritesController.getSizes";
import getAvailabilityResponse from "@salesforce/apex/AAV_APIIntegration.getAvailabilityResponse";
import LABEL_RECORD_UPDATED from "@salesforce/label/c.AAV_Record_Updated_Successfully";
import DESC_RECORD_UPDATED from "@salesforce/label/c.AAV_Record_Updated_Description";
import THRESHHOLD_SIZE_VALUE from "@salesforce/label/c.AAV_Alternate_Products_Threshold";
import LABEL_NO_WM_CONTAINER from "@salesforce/label/c.AAV_No_WM_Container_Available";//SDT-31609
import { ShowToastEvent } from "lightning/platformShowToastEvent";
const CSS_LOWER_SECTION = "lower-section";
const CSS_GREEN_COLOR = "lower-section_green";
const CSS_YELLOW_COLOR = "lower-section_yellow";

export default class AavAlternateContainers extends LightningElement {
  @wire(MessageContext) messageContext;
  showContainer;
  containerSizes;
  product;
  allAvailableDeliveries;
  showSpinner;
  showInnerSpinner;
  slaDates;
  activeTabId;
  lbl_noContainerAvailable;//SDT-31609
  //variables for confirmation box
  confirmationDialogue;
  newContainerSize;
  newContainerSizeCode;
  newContainerDate;
  connectedCallback() {
    this.subscribeToMessageChannel();
  }
  subscribeToMessageChannel() {
    subscribe(this.messageContext, AAV_ALTERNATE_CONTAINER_CHANNEL, (message) =>
      this.showHideComponent(message)
    );
  }
  /*Method to show or hide whole component*/
  showHideComponent(message) {
    try {
      if (message && message.currentProduct) {
        this.product = message.currentProduct;
        this.activeTabId = message.activeTabId;
        this.showContainer = message.showAlternateContainers;
      }
      if (
        this.showContainer &&
        this.product.productId &&
        this.product.parentId
      ) {
        this.showSpinner = 1;
        this.lbl_noContainerAvailable = '';//SDT-31609v
        this.getContainerSize();
      }
    } catch (error) {
      this.showErrorMessage(error);
    }
  }
  /*Get SF stored Container Size for a product*/
  getContainerSize() {
    getSizes({ productId: this.product.productId, returnAll: false })
      .then((result) => {
        if (result && Object.keys(result)?.length) {
          this.containerSizes = result;
          this.getAssetAPIResponse();
        } else this.showSpinner = 0;
      })
      .catch((error) => this.showErrorMessage(error));
  }
  /*Call Backend method to get API response stored*/
  getAssetAPIResponse() {
    getAvailabilityResponse({ quoteLineId: this.product.parentId })
      .then((result) => {
        this.showContainer = this.findAvailableContainers(result);
        this.showSpinner = 0;
      })
      .catch((error) => this.showErrorMessage(error));
  }

  /*Find available Containers from API response*/
  findAvailableContainers(response) {
    if (response?.AAV_isAPIResult__c && response?.AAV_APIRequestOutput__c) {
      let availabilityResponse = JSON.parse(response.AAV_APIRequestOutput__c);
      let supplier = availabilityResponse?.data?.suppliers[0];//SDT-31609
      let deliveries = supplier?.deliveries;
      if (deliveries?.length) {
        let conts = this.commonContainers(deliveries);
        let index = this.getCurrentContainerIndex(conts);
        if (conts.length) {
          this.showInnerSpinner = 1;
          this.getSLADates(this.filterContainers(conts, index));
          return true;
        }
      }
      //SDT-31609
      else if(supplier?.serviceDays?.length){
        this.lbl_noContainerAvailable = LABEL_NO_WM_CONTAINER;
        return true;
      }
    }
    return false;
  }
  /*return only Common Container b/w API response and SF result with max Threshold 10 Yards*/
  commonContainers(list) {
    let uiContainerSizes = Object.values(this.containerSizes);
    return list.filter(
      (container) =>
        container?.dates?.length &&
        uiContainerSizes.includes(container.equipmentSizeName) &&
        this.checkThreshold(container.equipmentSizeName)
    );
  }
  checkThreshold(size) {
    try {
      let value = Number(THRESHHOLD_SIZE_VALUE);
      let currentSize = this.product.equipmentSize.split(" ")[0];
      let otherSize = size.split(" ")[0];
      return (
        currentSize &&
        otherSize &&
        currentSize - otherSize >= -value &&
        currentSize - otherSize <= value
      );
    } catch (error) {
      console.error("checkThreshold=>", error);
      return false;
    }
  }
  /*Filter Container - next or previous container: max 2*/
  filterContainers(list, index) {
    index = (index === -1) ? this.updateNewList(list) : index;//SDT-31978 
    return index === 0
      ? list.slice(1, 2)
      : index === list.length - 1
      ? list.slice(index - 1, index)
      : [list[index - 1], list[index + 1]];
  }
  //SDT-31978 
  updateNewList(list){
    let index = list.findIndex(item => parseFloat(item.equipmentSizeName) > parseFloat(this.product.equipmentSize));
    index = (index === -1) ? list.length : index;
    list.splice(index, 0, {});
    return index;
  }

  /*index of Current product in the available container list*/
  getCurrentContainerIndex(list) {
    return list.findIndex(
      (ele) => ele.equipmentSizeName === this.product.equipmentSize
    );
  }
  /* Fetch Entitled Date to calculate and show SLA dates*/
  getSLADates(containers) {
    let sizes = containers.map((cont) => cont.equipmentSizeCode);
    if (sizes.length) {
      getSLADates({
        parentQuoteLineId: this.product.parentId,
        equipmentSizes: sizes
      })
        .then((result) => {
          this.slaDates = result;
          this.allAvailableDeliveries = containers.map((cont) =>
            this.createUIArray(cont)
          );
          this.showInnerSpinner = 0;
        })
        .catch((error) => this.showErrorMessage(error));
    } else {
      this.showContainer = this.showInnerSpinner = 0;
    }
  }
  /*return Array for UI rendering*/
  createUIArray(container) {
    let slaDate = this.slaDates[container.equipmentSizeCode];
    slaDate = this.convertStrToDate(slaDate);
    return {
      equipmentName:
        container.equipmentSizeName + " " + container.equipmentName,
      equipmentSizeCode: container.equipmentSizeCode,
      dates: this.updateDateFormat(container.dates, slaDate)
    };
  }
  /*return formatted date and Day name */
  updateDateFormat(dates, slaDate) {
    let dayNameStd = new Intl.DateTimeFormat("en-US", { weekday: "long" });
    let returnArray = [];
    dates.forEach((date) => {
      let avlDate = this.convertStrToDate(date);
      let formattedDate = this.formatDate(avlDate, "MM-dd-yyyy");
      returnArray.push({
        date: formattedDate,
        dayName: dayNameStd.format(avlDate),
        cssClass:
          CSS_LOWER_SECTION +
          " " +
          (avlDate >= slaDate ? CSS_GREEN_COLOR : CSS_YELLOW_COLOR)
      });
    });
    return returnArray;
  }
  /*Capture Error Message*/
  showErrorMessage(error) {
    console.error("error->", error);
    this.showInnerSpinner = this.showSpinner = false;
  }
  //confirmation Box Method
  handleDialogueClick(event) {
    let confirmation = event.currentTarget.value;
    this.confirmationDialogue = false;
    this.showSpinner = true;
    if (confirmation === "Yes") {
      this.updateNewSize();
    }
  }
  handleContainerChange(event) {
    this.newContainerSizeCode = event.currentTarget.dataset.size;
    this.newContainerSize = this.containerSizes[this.newContainerSizeCode];
    this.newContainerDate = event.currentTarget.dataset.date;
    this.confirmationDialogue = true;
  }
  errorCallback(error, stack) {
    console.error(`Error: ${error}, Stack : ${stack}`);
    this.showErrorMessage(error);
  }
  convertStrToDate(str) {
    return str ? new Date([str, "00:00"]) : "";
  }
  updatedProduct() {
    return {
      activeTabId: this.activeTabId,
      newSLADate: this.slaDates[this.newContainerSizeCode],
      newEquipmentSize: this.newContainerSize,
      oldEquipmentSize: this.product.equipmentSize,
      parentId: this.product.parentId,
      newContainerDate: this.formatDate(
        this.convertStrToDate(this.newContainerDate),
        "yyyy-MM-dd"
      )
    };
  }
  //Accept date format month -MM, date-dd, year -yyyy
  formatDate(date, formats) {
    let returnDate;
    if (formats && date) {
      returnDate = formats
        .replace("dd", ("0" + date.getDate()).slice(-2))
        .replace("MM", ("0" + (1 + date.getMonth())).slice(-2))
        .replace("yyyy", date.getFullYear().toString());
    }
    return returnDate;
  }
  //udpate new Equipement size in backend
  updateNewSize() {
    updateAlternateProduct({
      productWrapper: {
        parentId: this.product.parentId,
        equipmentSize: this.newContainerSizeCode
      }
    })
      .then((result) => {
        if (result) {
          this.showToast();
        }
        publish(this.messageContext, AAV_ALTERNATE_CONTAINER_CHANNEL, {
          updatedProduct: this.updatedProduct()
        });
        this.showSpinner = false;
      })
      .catch((error) => {
        this.showErrorMessage(error);
      });
  }
  showToast() {
    let description = DESC_RECORD_UPDATED
      ? DESC_RECORD_UPDATED.replace("{name}", this.product.quoteLineName)
      : "";
    this.dispatchEvent(
      new ShowToastEvent({
        variant: "success",
        title: LABEL_RECORD_UPDATED,
        message: description
      })
    );
  }
}