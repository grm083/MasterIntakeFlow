import { LightningElement, track, api, wire } from "lwc";
import getAlerts from '@salesforce/apex/MarketAreaAlertController.getAlerts';
import getMAASwitch from '@salesforce/apex/MarketAreaAlertController.getMAASwitch';
import getPageSize from '@salesforce/apex/MarketAreaAlertController.getPageSize';
const COLUMNS = [

  {
    label: '',
    fieldName: '',
    fixedWidth: 50,
    wrapText: false,
    cellAttributes: {
      iconName: {
        fieldName: 'icon',
        class: 'slds-icon_x-small'
      }
    }
  },
  {
    label: 'Alert Title',
    fieldName: 'name',
    wrapText: true,
    initialWidth: 110,
    typeAttributes: {
      label: { fieldName: 'name' }
    }
  },
  {
    label: 'View',
    type: 'button-icon',
    iconName: 'utility:preview',
    hideLabel: true,
    fixedWidth: 30,
    typeAttributes: {
      iconName: 'utility:preview',
      title: 'Preview',
      variant: 'bare',
      alternativeText: 'View',
      name: "popUp",
    },
    cellAttributes: { alignment: 'left' }
  },
  { label: 'Alert Type', fieldName: 'type', wrapText: true, initialWidth: 100 },
  { label: 'Line(s) of Business', fieldName: 'lob', wrapText: true, initialWidth: 110 },
  { label: 'Start Date', fieldName: 'startDate', wrapText: true, fixedWidth: 110 },
  { label: 'End Date', fieldName: 'endDate', wrapText: true, fixedWidth: 100 },

]
export default class AlertCard extends LightningElement {

  @api recordId;
  @track isResponse = false;
  columns = COLUMNS;
  @track operationInventoryModal = false;
  @track alertRow = {};
  @track page = 1;
  @track pageSize; // Number of records to be displayed in the page
  @track totalRecords = 0;
  @track totalPages = 0;
  @track paginatedData = []; // To store sliced data
  @track tableData = [];
  @track allAlertsTableData = [];
  @track isPagination = false;
  @track pageIndex = 0;
  noAlertsMsg;
  isLoader = false;
  isMAACodeSwitch;
  isMarketArea;
  isGeoGraphicArea;
  isContainerType;
  isOutageStartDate;
  isReason;
  isWasteStream;
  isStandardPrieview;
  recordsShownAPI;
  storeIndexUI = 1;
  startIndex;
  endIndex;
  isEvenIndex;

  connectedCallback() {
  window.addEventListener('caseUpdated', this.handleCaseUpdate.bind(this));
    if (this.recordId !== undefined || this.recordId !== null) {
      this.fetchPageSize();
    }
  }

  handleCaseUpdate(event) {
    const updatedCaseId = event.detail.caseId;
    if (updatedCaseId === this.recordId) {
      this.isLoader = true;
      this.pageSize='';
        // Refresh the data when the case is updated
        setTimeout(() => {
          this.fetchPageSize();
      }, 600);
    }
}
  //adding for fetch the code switch value for Market Area Alerts.
  @wire(getMAASwitch)
  isSwitchOn({ error, data }) {
    if (data !== undefined) {
      this.isMAACodeSwitch = data;
    }
    else if (error) {
       console.log('error for wire is ' + error);
    }
  }

  //adding for fetch the Page Size value from Market Area Alerts custom settings.
  fetchPageSize(){
    getPageSize({ recordId: this.recordId})
    .then((result) => {
      this.pageSize = result;
      this.pageIndex = 0;
      this.page = 1;
      this.isPagination = false;
      this.loadData();
    })
    .catch((e) => {
      console.log("getPageSize : Catch " + JSON.stringify(e));
    });
  }

  loadData() {
    this.tableData = [];
    this.paginatedData =[];
    this.isLoader = true;
    this.totalPages ='';
    this.totalRecords ='';
    this.noAlertsMsg = 'Please wait for the Alerts information to load, then refresh the page.';
    getAlerts({ recordId: this.recordId, pageIndex: this.pageIndex , pageSize : this.pageSize})
      .then((result) => {
        console.log(`MAA API Response latest index: ${JSON.stringify(result)}`);
        const response = result;
        if(response == null || response == undefined ||response.count == 0) {
          this.isResponse = false;
          this.noAlertsMsg = 'No relevent alerts found.';
          this.isLoader = false;
        }else{
        this.tableData = response.Data;
        if (this.tableData == null || this.tableData == undefined) {
          if (response.problem) {
            response.problem.forEach(element => {
              if (element.Status == 500) {
                this.noAlertsMsg = element.errors[1].Message;
              }
            });
          } else {
            this.noAlertsMsg = 'No Active Alerts Found';
          }
          this.isLoader = false;
        } else {
          if (this.tableData.length == 0) {
            this.noAlertsMsg = 'No Active Alerts Found';
          } else {
            this.tableData = this.tableData.map(item => {
              return {
                ...item,
                icon: 'action:new_custom53',
                endDate: item.endDate ? this.getDateFormat(item.endDate) : '',
                startDate: item.startDate ==null && item.outageStartDate != null ? this.getDateFormat(item.outageStartDate) : this.getDateFormat(item.startDate),
                //outageStartDate: item.outageStartDate ? this.getDateFormat(item.outageStartDate) : ''
              };
            });


            if (this.tableData.length > 0) {
              this.totalRecords = response.count;
              this.totalPages = Math.ceil(this.totalRecords / this.pageSize);

              if (this.totalRecords > this.pageSize) {
                this.isPagination = true;
              }
            }

            this.updatePaginatedData();
            this.isResponse = true;
            this.isLoader = false;
            this.page = this.page == 1 ? this.storeIndexUI : this.page;
          }
        }
        this.isLoader = false;
      }
      })
      .catch((e) => {
        console.log("loadData : Catch " + JSON.stringify(e));
        this.isLoader = false;
        this.noAlertsMsg = 'Currently Facing Issues, please refresh the page.';
        this.isResponse = false;

      });
  }
  get _disablePrevious() {
    return this.page === 1 ? true : false;
  }

  get _disableNext() {
    return this.page === this.totalPages ? true : false;
  }

  updatePaginatedData() {
    const startIndex = (this.page - 1) * this.pageSize; // Calculates the start index of paginated data
    const endIndex = startIndex + this.pageSize; // Calculates the end index of paginated data
    //this.paginatedData = this.tableData.slice(startIndex, endIndex);
    console.log('tableData==>'+JSON.stringify(this.tableData));
    this.paginatedData = this.tableData;
    console.log('paginatedData==>'+JSON.stringify(this.paginatedData));
  }

  handlePrevious() {
    if (this.page > 1) {
      this.page--;
      this.pageIndex--;
      this.loadData();
    }
  }

  handleNext() {
    if (this.page < this.totalPages) {
      this.page++;
      this.pageIndex++;
      this.loadData();
    }

  }

  handleRowAction(event) {
    const dataRow = event.detail.row;
    this.alertRow = dataRow;
    this.isMarketArea = this.alertRow.type == 'Inventory' ||
                        this.alertRow.type == 'Operational' ? true : false;
    this.isOutageStartDate = this.alertRow.type == 'Inventory' ||
                             this.alertRow.type == 'Operational' ? true : false;
    this.isGeoGraphicArea = this.alertRow.type == 'Bi-Weekly Re-Route' ||
                            this.alertRow.type == 'Re-Route' ||
                            this.alertRow.type == 'custom' ||
                            this.alertRow.type == 'ticket schedule' ||
                            this.alertRow.type == 'rescheduled' ||
                            this.alertRow.type == 'Early Service' ||
                            this.alertRow.type == 'service delay' ? true : false;
    this.isContainerType = this.alertRow.type == 'Inventory' ? true : false;
    this.isReason = this.alertRow.type == 'Operational' ? true : false;
    this.isWasteStream = this.alertRow.type == 'Bi-Weekly Re-Route' ||
                          this.alertRow.type == 'Re-Route' ||
                          this.alertRow.type == 'custom' ||
                          this.alertRow.type == 'ticket schedule' ||
                          this.alertRow.type == 'rescheduled' ||
                          this.alertRow.type == 'Early Service' ||
                          this.alertRow.type == 'service delay' ? true : false;
    this.isStandardPrieview = this.alertRow.type == 'Bi-Weekly Re-Route' ||
                              this.alertRow.type == 'Re-Route' ||
                              this.alertRow.type == 'custom' ||
                              this.alertRow.type == 'ticket schedule' ||
                              this.alertRow.type == 'rescheduled' ||
                              this.alertRow.type == 'Early Service' ||
                              this.alertRow.type == 'service delay' ? true : false;
    this.operationInventoryModal = true;
    
  }

  closeModal() {
    this.operationInventoryModal = false;
  }

  getDateFormat(date) {
    const dateObj = new Date(date);
    const month = String(dateObj.getMonth() + 1).padStart(2, '0'); // Months are 0-indexed
    const day = String(dateObj.getDate()).padStart(2, '0');
    const year = dateObj.getFullYear();
    const formattedDate = `${month}-${day}-${year}`;
    return formattedDate;
  }
}
