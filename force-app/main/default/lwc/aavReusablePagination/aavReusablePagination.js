/**
 * @author       : Asset Availability Team
 * @description  : Reusable Pagination UI
 * @History
 * -------
 * VERSION | AUTHOR                | DATE            | DESCRIPTION
 * 1.0     | Satnam Singh          | Sep  1, 2023    | User Story #SDT-32015
 ***/
import { LightningElement, api } from "lwc";

export default class AavReusablePagination extends LightningElement {
  @api itemPerPage = 5;
  _inputList;
  @api
  set inputList(value) {
    if (value?.length) {
      this._inputList = value;
      this.sendUpdatedList();
    }
  }
  get inputList() {
    return this._inputList;
  }
  currentPage = 1;
  get showPagination() {
    return this.inputList?.length > this.itemPerPage;
  }
  get numberList() {
    return Array.from({ length: this.totalPage }, (_, i) => ({
      number: i + 1,
      variant: this.currentPage === i + 1 ? "brand" : "neutral"
    }));
  }
  get totalPage() {
    return this.inputList.length
      ? Math.ceil(this.inputList.length / this.itemPerPage)
      : 0;
  }
  get isFirstPage() {
    return this.currentPage === 1;
  }
  get isLastPage() {
    return this.currentPage === this.totalPage;
  }
  handleSelectPage(event) {
    let pageNumber = event.target.label;
    if (pageNumber !== this.currentPage)
      this.updateCurrenPage(Number(event.target.label));
  }
  previousPage() {
    this.updateCurrenPage(this.currentPage - 1);
  }
  nextPage() {
    this.updateCurrenPage(this.currentPage + 1);
  }
  updateCurrenPage(page) {
    this.currentPage = page;
    this.sendUpdatedList();
  }
  sendUpdatedList() {
    const start = (this.currentPage - 1) * this.itemPerPage;
    const end = start + this.itemPerPage;
    this.dispatchEvent(
      new CustomEvent("listupdated", {
        detail: {
          list: this.inputList.slice(start, end)
        }
      })
    );
  }
  errorCallback(error, stack) {
    console.error(`Error: ${error}, Stack : ${stack}`);
  }
}