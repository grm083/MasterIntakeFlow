/**
 * @author       : Asset Availability Team
 * @description  : To show Service information from Availability API.
 * @History
 * -------
 * VERSION | AUTHOR                | DATE            | DESCRIPTION
 * 1.0     | Satnam Singh          | Aug 31, 2023    | User Story #SDT-32016
 ***/
import { api, LightningElement, track, wire } from "lwc";
import getOutputFields from "@salesforce/apex/AAV_AvailbilityAppHelper.getAppOutputFields";
import {
  createRowData,
  getResponsePath,
  getColumnValue,
  checkArray,
  assignErrors
} from "c/aavUtilityMethods";

// custom Labels
import SERVICE_ERROR_MSG from "@salesforce/label/c.AAV_No_WM_Service_Days_Message";

const API_SERVICE_WEEK_DAYS = "Service_Days";
const NUMBER_OF_COLUMNS = 2; // Number of Data column for UI.
const CSS_GREYED_WEEK_DAY = "week_day_box-greyed";
const CSS_FOCUSED_WEEK_DAY = "week_day_box-focused";
const SERVICE_AVAILABILITY = "Service Availability";
const WARNING_TEXT_LIST = "warning-text-list";
const WARNING_TEXT_SINGLE = 'warning-text-single';
export default class AavAppOutputServiceSection extends LightningElement {
  weekDays = [
    { day: "S", dayName: "Sunday" },
    { day: "M", dayName: "Monday" },
    { day: "T", dayName: "Tuesday" },
    { day: "W", dayName: "Wednesday" },
    { day: "T", dayName: "Thursday" },
    { day: "F", dayName: "Friday" },
    { day: "S", dayName: "Saturday" }
  ];
  label_ServiceHeader = SERVICE_AVAILABILITY;
  availabilityType;
  serviceWeekDaysError;
  supplier;
  _availabilityData;
  @api
  set availabilityData(value) {
    if (value && value?.apiResponse) {
      this._availabilityData = JSON.parse(value.apiResponse);
      this.availabilityType = SERVICE_AVAILABILITY;
    }
  }
  get availabilityData() {
    return this._availabilityData;
  }
  get cssServiceClassError(){
    return this.serviceWeekDaysError.length === 1 ? WARNING_TEXT_SINGLE : WARNING_TEXT_LIST
  }
  @track displayFieldsRows;
  outputFields;
  @wire(getOutputFields, { availabilityType: "$availabilityType" })
  outputFieldsData({ error, data }) {
    if (data) {
      this.outputFields = data;
      this.updateUIFields();
    } else if (error) {
      console.error(error);
    }
  }
  //Check if Service Information Available or not to display
  checkServiceAvailability() {
    try {
      this.supplier = this.availabilityData?.data?.suppliers[0];
      return checkArray(this.supplier?.serviceDays);
    } catch (error) {
      console.error(error);
    }
    return false;
  }
  /**** iterate over outputFields metadata records and populate UI fields ****/
  updateUIFields() {
    //Filter Static fields from list
    let otherFields = this.outputFields.filter((item) => {
      if (this.staticFields.has(item.QualifiedApiName)) {
        this.staticFields.get(item.QualifiedApiName)(item);
        return false;
      }
      return true;
    });
    //Generate dynamic data fields
    this.displayFieldsRows = createRowData(
      this.availabilityData,
      otherFields,
      NUMBER_OF_COLUMNS
    );
  }
  /**Populate Serviable Week days */
  udpateWeekDays(data) {
    if (this.checkServiceAvailability()) {
      //fetch Data from Response
      let weekdaysTemp = getColumnValue(
        getResponsePath(data),
        this.availabilityData
      )?.map((item) => item.toLowerCase());
      //Update CSS for Available Week days
      this.weekDays.forEach((day) => {
        day.design = weekdaysTemp.includes(day.dayName.toLowerCase())
          ? CSS_FOCUSED_WEEK_DAY
          : CSS_GREYED_WEEK_DAY;
      });
    } else {
      this.serviceWeekDaysError = [SERVICE_ERROR_MSG];
      //this.serviceWeekDaysError = assignErrors(this.supplier.messages, SERVICE_ERROR_MSG);
    }
  }

  errorCallback(error, stack) {
    console.error(`Error: ${error}, Stack : ${stack}`);
  }
  //Exceptional fields on UI
  staticFields = new Map([
    [API_SERVICE_WEEK_DAYS, this.udpateWeekDays.bind(this)]
  ]);
}