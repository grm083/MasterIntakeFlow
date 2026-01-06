/**
 * @author       : Asset Availability Team
 * @description  : Custom Date picker for Delivery availability
 * @History
 * -------
 * VERSION | AUTHOR                | DATE            | DESCRIPTION
 * 1.0     | Satnam Singh          | May 11, 2023    | User Story #SDT-29101
 ***/
import { api, LightningElement, track, wire } from "lwc";
import userLocaleSidKey from "@salesforce/schema/User.LocaleSidKey";
import Id from "@salesforce/user/Id";
import { getRecord } from "lightning/uiRecordApi";
import getAvailabilityRecord from "@salesforce/apex/AAV_APIIntegration.getAvailabilityRecord";
import {
  MONTHS,
  WEEK_DAYS,
  checkDeliveryStatusOne,
  checkDeliveryStatusTwo,
  getTodayDate,
  addDaysInDate,
  stringToDate
} from "./aavCustomDatePickerHelper";

import LABEL_SLAAVAILABLEDATE from "@salesforce/label/c.AAV_Available_SLA_Date_Label";
import LABLE_AVAILABLEDATE from "@salesforce/label/c.AAV_Available_Date_Label";
import PICKLIST_API_ERROR from "@salesforce/label/c.AAV_Availability_API_Error_Picklist_Value";
import DELIVERY_DAYS_UPTO from "@salesforce/label/c.AAV_Available_Delivery_Days_Upto";
//SDT-31583
import API_ERROR_MESSAGE from "@salesforce/label/c.AAV_Availability_API_Error_Out";//Availability could not be confirmed as there is no response from the API';
import NO_CONTAINER_MESSAGE from "@salesforce/label/c.AAV_Available_No_Containers";// 'No WM Container Available';
import NO_CONTAINER_MESSAGE_WITH_CONFIRM from "@salesforce/label/c.AAV_Available_No_Containers_With_Confirm";// 'No WM containers available, please confirm with WM dispatch';
import NO_DELIVERY_INFO_ERROR_MSG from "@salesforce/label/c.AAV_Available_No_Delivery_Message";// 'No WM delivery date information is available for this location';
import NO_SERVICE_MESSAGE_WITH_CONFIRM from "@salesforce/label/c.AAV_Available_No_Service_With_Confirm";// 'No WM service day information is available for this location, please confirm with WM dispatch';
import SELECTED_CONTAINER_NOT_AVAILABLE from "@salesforce/label/c.AAV_Available_Unavailable_Container";// 'No WM Availability for the {equipmentSize} container';
import NON_WM_VENDOR_ERROR_MSG from "@salesforce/label/c.AAV_Available_No_Service_or_Delivery";// 'No WM service day/delivery date information is available for this location';
//SDT-31583
const DEFAULT_DATE_LOCAL = "en-US";
const DATE_YEAR_FORMAT = "numeric";
const DATE_DAY_FORMAT = "numeric";
const DATE_MONTH_FORMAT = "short";

const SLDS_DROPDOWN_BASE_CLASS =
  "slds-form-element slds-dropdown-trigger_click";
const SLD_DROPDOWN_IS_OPEN = "slds-is-open";

export default class AavCustomDatePicker extends LightningElement {
  weekDays = WEEK_DAYS;
  showCalendar = false;
  calendarHover = false;
  slaAvailableDateLabel = LABEL_SLAAVAILABLEDATE;
  availableDateLabel = LABLE_AVAILABLEDATE;
  userLocal = DEFAULT_DATE_LOCAL;
  errorMsgforUI = [];//SDT-31583
  errorMsgforBE = { "service": [], "delivery": [], "common": [] };//SDT-31583
  assetAvailabilityResponseFailure;
  isWmServiceAble;
  calendarViewDate = new Date(new Date().getTime());
  @track dates = [];
  @api equipmentSize;

  //added as part of SDT 31585
  @api pickerLabel;

  //added as part of SDT 31585
  @track response 
  @api setResponseData(responseJson) {
    this.response = responseJson;
  }

  @api quoteLineId;
  _selectedDate;
  @api
  set selectedDate(value) {
    this._selectedDate = value;
    this.updateCalendarDate(value);
  }
  get selectedDate() {
    return this._selectedDate;
  }
  get startDate() {
    return stringToDate(this.selectedDate);
  }
  _slaDate;
  @api set slaDate(value) {
    if (value) {
      this._slaDate = stringToDate(value);
    }
  }
  get slaDate() {
    return this._slaDate;
  }
  _availableDates = [];
  set availableDates(value) {
    if (value && value.length) {
      this._availableDates = [];
      value.forEach((date) => this._availableDates.push(stringToDate(date)));
    }
    this.refershCalendar();
  }
  get availableDates() {
    return this._availableDates;
  }
  //SDT-31583
  get availableDatesCheck() {
    return Boolean(this.availableDates.length);
  }
  // add year Range from -+(100) years
  get yearsRange() {
    return Array.from(
      { length: 200 },
      (_, i) => this.calendarViewDate.getFullYear() - 100 + i + 1
    );
  }
  get month() {
    return MONTHS[this.calendarViewDate.getMonth()];
  }
  get dropdownClass() {
    return (
      SLDS_DROPDOWN_BASE_CLASS +
      (this.showCalendar ? ` ${SLD_DROPDOWN_IS_OPEN}` : "")
    );
  }
  //format date as per user local for view
  get formattedDate() {
    return this.selectedDate
      ? stringToDate(this.selectedDate).toLocaleDateString(this.userLocal, {
        year: DATE_YEAR_FORMAT,
        month: DATE_MONTH_FORMAT,
        day: DATE_DAY_FORMAT
      })
      : "";
  }
  //Spinner off conditions
  get showSpinner() {
    let complete = this.slaDate && this.selectedDate && this.apiCallout;
    if (complete)
      this.updateParentEvent(
        undefined,
        this.checkDeliveryOverride(this.startDate)
      );
    return !complete;
  }

  apiCallout;
  // /*Call Backend method to get API response stored*/
  // @wire(getAvailabilityRecord, { quoteLineId: "$quoteLineId" })
  // availabilityRecord({ error, data }) {
  //   if (data) {
  //     try {
  //       //SDT-31609 & //SDT-31583
  //       if (data.AAV_isAPIResult__c) {
  //         this.assetAvailabilityResponseFailure = false;
  //         let response = JSON.parse(data.AAV_APIRequestOutput__c);
  //         let supplier = response?.data?.suppliers;
  //         if (Array.isArray(supplier) && supplier[0]) {
  //           supplier = supplier[0];
  //           this.isWmServiceAble = supplier.deliveries?.length || supplier.deliveryDays?.length || supplier.serviceDays?.length;
  //           if (supplier.deliveries?.length && supplier.deliveryDays?.length) {
  //             this.availableDates = supplier.deliveries.find(
  //               (x) => x.equipmentSizeName === this.equipmentSize
  //             )?.dates;
  //             if (!this.availableDates.length){
  //               let msg = SELECTED_CONTAINER_NOT_AVAILABLE.replace('{equipmentSize}',this.equipmentSize)
  //               this.errorMsgforUI = [msg]; 
  //               this.errorMsgforBE.delivery.push(msg);
  //             }
  //           }
  //           else if (Array.isArray(supplier.messages)) { //SDT-31583
  //             let messages = supplier.messages.map(x => x.description);
  //             this.errorMsgforUI = messages?.length ? messages : NO_CONTAINER_MESSAGE;
  //             this.errorMsgforBE.delivery.push('No WM containers available, please confirm with WM dispatch');
  //           }
  //           this.assetAvailabilityResponseFailure = supplier.deliveries?.length && !supplier.deliveryDays?.length;
  //         }
  //         //SDT-31583
  //         else if (Array.isArray(response?.data?.messages)) {
  //           this.errorMsgforUI = response.data.messages.map(x => x.description);
  //           this.errorMsgforBE.common.push(NON_WM_VENDOR_ERROR_MSG);
  //         }
  //       }
  //       else {
  //         this.responseFailure(data.problem ? data.problem : 'API Errored out');
  //       }
  //     } catch (errormsg) {
  //       this.responseFailure(errormsg);
  //     }
  //   }
  //   if (error) {
  //     this.responseFailure(error);
  //   }
  //   this.wiredCallout = true;
  // }
  //new method
  @api //modified as part of SDT 31585
  getAvailabilityResponse(doServerCall) {
    if(doServerCall) {
    getAvailabilityRecord({ quoteLineId: this.quoteLineId })
      .then((result) => {
        try {
this.getAvailabilityData(result);
        }
        catch (error) {
          this.responseFailure(error);
        }
      })
      .catch((error) => {
        this.responseFailure(error);
        this.apiCallout = true;
      });
    }
    else if(!doServerCall) {
      this.getAvailabilityData(this.response);
    }
  }

  //added as part of SDT 31585
  getAvailabilityData(result) {
          if (result.AAV_isAPIResult__c) {
            //modified as part of SDT 31585
      this.response = JSON.parse(result.AAV_APIRequestOutput__c);

      let supplier = this.response?.data?.suppliers;
            if (Array.isArray(supplier) && supplier[0]) {
              supplier = supplier[0];
              this.isWmServiceAble = supplier.deliveries?.length || supplier.deliveryDays?.length || supplier.serviceDays?.length;
              if (this.isWmServiceAble) {
                this.checkWMServicableScneraios(supplier);
              }
              else {
                this.wmNotAvailableScenario(supplier?.messages);
              }
            }
            else {
              this.wmNotAvailableScenario(this.response?.data?.messages);
            }
          }
          else {
            this.responseFailure('API Errored out');
          }
        
        this.updateCalendarDate(this.selectedDate);
        this.apiCallout = true;
      
  }
  //check Delivery and Service Conditions
  checkWMServicableScneraios(supplier) {
    let ServiceDatesNull = !supplier.serviceDays?.length; //SDT-31982
    if (supplier.deliveries?.length && supplier.deliveryDays?.length) {
      this.availableDates = supplier.deliveries.find(
        (x) => x.equipmentSizeName === this.equipmentSize
      )?.dates;
      //If Selected Conatiner not available
      if (!this.availableDates.length) {
        let msg = [SELECTED_CONTAINER_NOT_AVAILABLE.replace('{equipmentSize}', this.equipmentSize)];
        this.errorMsgforBE.delivery = this.errorMsgforUI = msg;
      }
      if (ServiceDatesNull) {
        this.errorMsgforBE.service = [NO_SERVICE_MESSAGE_WITH_CONFIRM];
      }
    }
    else if (supplier.deliveries?.length && !supplier.deliveryDays?.length) {
      let messages = supplier.messages;
      this.errorMsgforUI = (Array.isArray(messages) && messages.length) 
                    ? messages.map(x => x.description) :[NO_DELIVERY_INFO_ERROR_MSG];
      if(ServiceDatesNull) {//SDT-31982 & SDT-32005
        this.errorMsgforBE.common = [API_ERROR_MESSAGE];
      }else{
        this.errorMsgforBE.delivery = [NO_DELIVERY_INFO_ERROR_MSG];
      }      
      this.assetAvailabilityResponseFailure = ServiceDatesNull;//SDT-31982
    }
    else {
      let apiMsg = (Array.isArray(supplier.messages) && supplier.messages.length)
        ? supplier.messages.map(x => x.description) : [NO_CONTAINER_MESSAGE];
      this.errorMsgforUI = apiMsg;
      this.errorMsgforBE.delivery = [NO_CONTAINER_MESSAGE_WITH_CONFIRM];
    }
  }
  //for api Failure
  responseFailure(error) {
    this.assetAvailabilityResponseFailure = true;
    this.errorMsgforUI = [API_ERROR_MESSAGE]; //SDT-31583
    this.errorMsgforBE.common = [API_ERROR_MESSAGE];//SDT-31583
    console.error("getAvailabilityResponse=>", error);
  }
  //for Non WM 
  wmNotAvailableScenario(messages) {
    let apiMsg;
    if ((Array.isArray(messages) && messages.length)) {
      apiMsg = messages.map(x => x.description);
    }
    this.errorMsgforUI = apiMsg ? apiMsg : [NO_DELIVERY_INFO_ERROR_MSG];
    this.errorMsgforBE.common = apiMsg ? apiMsg : [NON_WM_VENDOR_ERROR_MSG];
  }
  //Get User local for date formatting
  @wire(getRecord, { recordId: Id, fields: [userLocaleSidKey] })
  currentUserInfo({ data }) {
    if (data && data.fields.LocaleSidKey.value)
      this.userLocal = data.fields.LocaleSidKey.value.replace("_", "-");
  }
  //SDT-29156 : helper method to identify the picklist value as per Delivery/start date selected
  @api
  getDeliveryDateConditions() {
    if (this.assetAvailabilityResponseFailure) return PICKLIST_API_ERROR;
    return (
      checkDeliveryStatusOne(
        this.availableDates,
        this.startDate,
        this.isWmServiceAble
      ) +
      ", " +
      checkDeliveryStatusTwo(this.startDate, this.slaDate)
    );
  }
  yearSelector() {
    return this.template.querySelector('select[name="yearlist"]');
  }
  handleFocusOut() {
    if (!this.focusOnCalendar) this.showCalendar = false;
  }
  focusOnCalendar;
  handleCalHover = () => (this.focusOnCalendar = 1);
  handleCalHoverOut = () => (this.focusOnCalendar = 0);
  handleShowCalendar() {
    this.showCalendar = true;
    this.refershCalendar();
  }
  handlePreviousMonth() {
    this.changeMonth(this.calendarViewDate.getMonth() - 1);
  }

  handleNextMonth() {
    this.changeMonth(this.calendarViewDate.getMonth() + 1);
  }
  changeMonth(month) {
    this.calendarViewDate.setDate(1);
    this.calendarViewDate.setMonth(month);
    this.refershCalendar();
  }
  handleToday() {
    let today = new Date();
    this.updateSelectedDate(
      this.formatFullDate(
        today.getFullYear(),
        today.getMonth(),
        today.getDate()
      )
    );
  }
  handleYearchange(e) {
    this.refershCalendar(e.target.value);
  }
  handleDateSelect(e) {
    this.updateSelectedDate(e.currentTarget.dataset.date);
  }
  refershCalendar(selectedYear) {
    let year;
    if (selectedYear) {
      year = selectedYear;
      this.calendarViewDate.setFullYear(selectedYear);
    } else {
      year = this.calendarViewDate.getFullYear();
      if (this.yearSelector()) this.yearSelector().value = year;
    }
    let month = this.calendarViewDate.getMonth();
    let firstDay = new Date(year, month, 1);
    let lastDay = new Date(year, month + 1, 0);
    let calStart = firstDay.getDate() - firstDay.getDay();
    let calEnd = lastDay.getDate() + (6 - lastDay.getDay());
    let arrTemp = [];
    this.dates = [];
    for (let date = calStart; date <= calEnd; date++) {
      const calDate = new Date(year, month, date);
      arrTemp.push({
        className:
          month === calDate.getMonth()
            ? this.defineDateClass(calDate)
            : "slds-hidden", //"slds-day_adjacent-month"
        fullDate: this.formatFullDate(year, month, date),
        date: calDate.getDate()
      });
      if (arrTemp.length === 7) {
        this.dates.push(arrTemp);
        arrTemp = [];
      }
    }
  }

  defineDateClass(calDate) {
    return this.isWmServiceAble &&
      this.availableDates.find(
        (date) =>
          calDate.getDate() === date.getDate() &&
          calDate.getMonth() === date.getMonth() &&
          calDate.getFullYear() === date.getFullYear()
      )
      ? calDate >= this.slaDate
        ? " green_box"
        : " yellow_box"
      : "";
  }

  //date format yyyy-MM-dd
  formatFullDate(year, month, date) {
    return `${year}-${("0" + (1 + month)).slice(-2)}-${("0" + date).slice(-2)}`;
  }
  connectedCallback() {
    this.getAvailabilityResponse(true); //SDT 31585
  }
  errorCallback(error, stack) {
    console.error(`Error: ${error}, Stack : ${stack}`);
  }
  //update Selected Date for parent component
  updateSelectedDate(date) {
    this.updateParentEvent(
      date,
      this.checkDeliveryOverride(stringToDate(date))
    );
    this.showCalendar = false;
    this.updateCalendarDate(date);
  }
  updateCalendarDate(date) {
    if (date) {
      this.calendarViewDate = stringToDate(date);
      this.refershCalendar();
    }
  }
  updateParentEvent(date, overrideFlag) {
    this.dispatchEvent(
      new CustomEvent("updateparent", {
        detail: {
          date: date,
          deliveryOverrideFlag: overrideFlag,
          errorMsgforUI: this.errorMsgforUI, //SDT-31583
          errorMsgforBE : JSON.stringify(this.errorMsgforBE)
        }
      })
    );
  }
  //SDT-30864 : check if Delivery Override reason required.
  checkDeliveryOverride(date) {
    return (!this.assetAvailabilityResponseFailure && this.availableDatesCheck &&//SDT-31583
      // this.isWmServiceAble &&
      date >= getTodayDate() &&
      date <= addDaysInDate(getTodayDate(), DELIVERY_DAYS_UPTO) &&
      !this.availableDates.find(
        (avlDate) => avlDate.getTime() === date.getTime()
      )
    );
  }
}