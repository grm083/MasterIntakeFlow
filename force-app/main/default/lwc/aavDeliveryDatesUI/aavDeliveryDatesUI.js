/**
 * @author       : Asset Availability Team
 * @description  : Reusable Delivery dates section for Availability API nformation.
 * @History
 * -------
 * VERSION | AUTHOR                | DATE            | DESCRIPTION
 * 1.0     | Satnam Singh          | Sep  1, 2023    | User Story #SDT-32015
 ***/
import { LightningElement, api } from "lwc";

export default class AavDeliveryDatesUI extends LightningElement {
  showInnerSpinner = true;
  _deliveries;
  @api
  set deliveries(value) {
    if (value) {
      this._deliveries = value;
      this.showInnerSpinner = false;
    }
  }
  get deliveries() {
    return this._deliveries;
  }
  handleContainerChange(event) {
    this.dispatchEvent(
      new CustomEvent("containerchange", {
        detail: event
      })
    );
  }
}