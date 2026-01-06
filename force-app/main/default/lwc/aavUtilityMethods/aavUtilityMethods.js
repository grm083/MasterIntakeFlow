/**
 * @author       : Asset Availability Team
 * @description  : Util methods for re-usabiltiy.
 * @History
 * -------
 * VERSION | AUTHOR                | DATE            | DESCRIPTION
 * 1.0     | Satnam Singh          |                 | User Story
 * **/
const CSS_LOWER_SECTION = "lower-section";
const CSS_GREEN_COLOR = "lower-section_green";
const CSS_YELLOW_COLOR = "lower-section_yellow";
const DATE_LOCAL = "en-US";
const DATE_FORMAT = "MM-dd-yyyy";

const getFromArray = (res, node) => {
  let returnVal = null;
  let newNode = node.substring(0, node.indexOf("["));
  let regex = /\[(\d+)\]/;
  let arrayIndex = parseInt(node.match(regex)[1], 10);
  if (res[newNode] && Array.isArray(res[newNode])) {
    returnVal = res[newNode][arrayIndex];
  }
  return returnVal;
};
const getColumnValue = (childNodes, data) => {
  let tempValue = data;
  childNodes.split(".").forEach((node) => {
    if (node.includes("[")) {
      tempValue = getFromArray(tempValue, node);
    } else tempValue = tempValue[node];
  });
  return tempValue;
};

const getResponsePath = (data) => {
  return data.API_Name__c;
};
/** Method is using field API Names specific to AAV_Asset_Availability_Output_Field__mdt metadata**/
const getColumnsData = (response, arr, index, size) => {
  let columns = [];
  for (let j = 0; j < size; j++) {
    let item = arr[index + j];
    if (item) {
      let col = {
        label: item.Label,
        value: getColumnValue(getResponsePath(item), response)
      };
      columns.push(col);
    }
  }
  return columns;
};

const createRowData = (responseData, outputFields, columnCount) => {
  let rowData;
  for (let i = 0; i < outputFields?.length; ) {
    if (i === 0) rowData = [];
    rowData.push({
      columns: getColumnsData(responseData, outputFields, i, columnCount),
      index: i
    });
    i = i + columnCount;
  }
  return rowData;
};
const convertStrToDate = (str) => {
  return str ? new Date([str, "00:00"]) : "";
};
//Accept date format month -MM, date-dd, year -yyyy
const formatDate = (date, format = DATE_FORMAT) => {
  let returnDate;
  if (format && date) {
    returnDate = format
      .replace("dd", ("0" + date.getDate()).slice(-2))
      .replace("MM", ("0" + (1 + date.getMonth())).slice(-2))
      .replace("yyyy", date.getFullYear().toString());
  }
  return returnDate;
};
/*return formatted date and Day name   specific to Delivery UI */
const updateDateFormat = (dates, slaDate) => {
  let dayNameStd = new Intl.DateTimeFormat(DATE_LOCAL, { weekday: "long" });
  let returnArray = [];
  dates.forEach((date) => {
    let avlDate = convertStrToDate(date);
    let formattedDate = formatDate(avlDate, DATE_FORMAT);
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
};
/*return Array for Delivery UI rendering*/
const createDeliveryArray = (container, slaDate) => {
  return {
    equipmentName: container.equipmentSizeName + " " + container.equipmentName,
    equipmentSizeCode: container.equipmentSizeCode,
    dates: updateDateFormat(container.dates, slaDate)
  };
};
/**** Get Day Names ****/
function getDayName(date = new Date(), locale = DATE_LOCAL) {
  return date.toLocaleDateString(locale, { weekday: "long" });
}
function getDateMilliSeconds(date) {
  return date ? new Date([date, "00:00"]).getTime() : 0;
}
const checkArray = (arr) => {
  return Boolean(Array.isArray(arr) && arr.length);
};
const assignErrors = (msg, customMsg) => {
  return checkArray(msg) ? msg.map((x) => x.description) : [customMsg];
};
export {
  createRowData,
  getResponsePath,
  getColumnValue,
  convertStrToDate,
  formatDate,
  createDeliveryArray,
  getDayName,
  getDateMilliSeconds,
  checkArray,
  assignErrors
};