//Custom Labels
import PICKLIST_WM_AVAILABILITY from "@salesforce/label/c.AAV_WM_Availability_Picklist_Value";
import PICKLIST_WM_UNAVAILABILITY from "@salesforce/label/c.AAV_WM_Unavailability_Picklist_Value";
import PICKLIST_WM_NOT_DELIVERABLE from "@salesforce/label/c.AAV_WM_Not_Deliverable_Picklist_Value";
import PICKLIST_DELIVERY_BACK_DATED from "@salesforce/label/c.AAV_Delivery_Date_Back_Dated_Picklist_Value";
import PICKLIST_DELIVERY_WITHIN_SLA from "@salesforce/label/c.AAV_Delivery_Date_Within_SLA_Picklist_Value";
import PICKLIST_DELIVERY_BEYOND_SLA from "@salesforce/label/c.AAV_Delivery_Date_Beyond_SLA_Picklist_Value";
import PICKLIST_DELIVERY_BEYOND_LIMITDAY from "@salesforce/label/c.AAV_Delivery_Date_Beyond_Limit_Picklist_Value";
import DELIVERY_DAYS_UPTO from "@salesforce/label/c.AAV_Available_Delivery_Days_Upto";

//SDT-29156 : helper method
export const MONTHS = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];
const getTodayDate = () => {
  return new Date(new Date().setHours(0, 0, 0, 0));
};
const addDaysInDate = (date, days) => {
  return new Date(date).setDate(date.getDate() + Number(days));
};
function stringToDate(date) {
  return new Date([date, "00:00"]);
}
export const WEEK_DAYS = [
  { FullDayName: "Sunday", uiDay: "Sun" },
  { FullDayName: "Monday", uiDay: "Mon" },
  { FullDayName: "Tuesday", uiDay: "Tue" },
  { FullDayName: "Wednesday", uiDay: "Wed" },
  { FullDayName: "Thursday", uiDay: "Thu" },
  { FullDayName: "Friday", uiDay: "Fri" },
  { FullDayName: "Saturday", uiDay: "Sat" }
];
//SDT-29156 : helper method
export function checkDeliveryStatusOne(availableDates, startDate ,isWmServiceAble) {
  if (isWmServiceAble) {
    return availableDates.find((date) => startDate.getTime() === date.getTime())
      ? PICKLIST_WM_AVAILABILITY
      : PICKLIST_WM_UNAVAILABILITY;
  }
  return PICKLIST_WM_NOT_DELIVERABLE;
}
//SDT-29156 : helper method
export function checkDeliveryStatusTwo(startDate, slaDate) {
  let todayDate = getTodayDate();
  if (startDate < todayDate) {
    return PICKLIST_DELIVERY_BACK_DATED;
  }
  let afterNDays = addDaysInDate(todayDate, DELIVERY_DAYS_UPTO);
  if (startDate < slaDate) return PICKLIST_DELIVERY_WITHIN_SLA;
  else if (startDate <= afterNDays) return PICKLIST_DELIVERY_BEYOND_SLA;
  return PICKLIST_DELIVERY_BEYOND_LIMITDAY;
}

export { getTodayDate, addDaysInDate, stringToDate };