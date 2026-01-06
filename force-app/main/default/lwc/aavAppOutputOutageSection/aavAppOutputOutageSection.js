/**
 * @author       : Asset Availability Team
 * @description  : Component Will provide UI for Outage Section of Asset availabilty.
 * @History
 * -------
 * VERSION | AUTHOR                | DATE            | DESCRIPTION
 * 1.0     | Nikita Jain          | Feb 21, 2023    | User Story #AAC-31
 * **/
import { LightningElement, track, wire, api } from "lwc";
import getOutputFields from "@salesforce/apex/AAV_AvailbilityAppHelper.getAppOutputFields";

// custom Labels
import NO_OUTAGE_INFORMATION_MESSAGE from "@salesforce/label/c.AAV_No_Outage_Information_Message";

const LBL_HEADER_OUTAGE = "Outages Data";

export default class AavAppOutputOutageSection extends LightningElement {
  lbl_header_outage = LBL_HEADER_OUTAGE;
  errorOutageMessage = NO_OUTAGE_INFORMATION_MESSAGE;
  @track columns = [];
  _outages;
  @api
  set outages(value) {
    if (value) this._outages = value;
  }
  get outages() {
    return this._outages;
  }
  @wire(getOutputFields, { availabilityType: "Outage Data" })
  fetchMetadata({ data, error }) {
    if (data) {
      data.forEach((metadata) => {
        this.columns.push({
          label: metadata.MasterLabel,
          fieldName: metadata.API_Name__c,
          type: metadata.Data_Type__c,
          wrapText: true
        });
      });
    } else if (error) {
      console.error(error);
    }
  }
}