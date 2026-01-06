import { LightningElement, track, api, wire } from 'lwc';
import updateRecordToExSystem from '@salesforce/apex/UpdatePortal.updateRecordToExSystem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import TwoWayAccessErrorMessage from '@salesforce/label/c.TwoWayAccessErrorMessage';
import Office_Trax from '@salesforce/label/c.OfficeTrax';
import getServiceRevisionsHistoryRecord from '@salesforce/apex/UpdatePortal.getServiceRevisionsHistoryRecord'
import TwowaycommentsPerPage from '@salesforce/label/c.TwowaycommentsPerPage';
import getExternalStatus from '@salesforce/apex/UpdatePortal.getExternalStatus';
import getOfficetraxServiceStatus from '@salesforce/apex/UpdatePortal.getOfficetraxServiceStatus'; //SDT-40151
import { refreshApex } from "@salesforce/apex";

const columns = [
  { label: 'Date', fieldName: 'updatedcreateDate', type: 'date', sortable: true, hideDefaultActions: true, wrapText: true, initialWidth: 230,
  typeAttributes: {day: '2-digit',month: 'short',year: 'numeric',hour: '2-digit',minute: '2-digit',hour12:true}
  },
  { label: 'Requestor', fieldName: 'createdBy', type: 'text', hideDefaultActions: true, wrapText: true, initialWidth: 230},
   { label: 'Service Date', fieldName: 'updatedServiceDate', type: 'date', hideDefaultActions: true, wrapText: true, initialWidth: 230,
  typeAttributes: {day: '2-digit',month: 'short',year: 'numeric'}
   },
  { label: 'Status', fieldName: 'serviceStatus', type: 'text', hideDefaultActions: true, wrapText: true, initialWidth: 400 },
  { label: 'System message', fieldName: 'userMessage', type: 'text', hideDefaultActions: true, wrapText: true },
  { label: 'Exception message', fieldName: 'exceptionMessage', type: 'text', hideDefaultActions: true, wrapText: true }
];


export default class SendAlert extends NavigationMixin(LightningElement) {
  showSpinner = true;
  @track selectedStatus;
  @api caseOrigin;
  @api recordId;
  currentServiceDate
  dateTimeValue;
  formatter = new Intl.DateTimeFormat('en', {
    year: "numeric" ,
    month: "short",
    day: "2-digit"
    })
  minDateTimeValue = new Date().toISOString().substring(0,10);
  //UI data variables
  getPortalData = []
  getStatus = []
  combooptions = [];
  //History table variables
  tableData = []
  columns = columns;
  noRecordsToShow = true;
  tableRecordCount
  historyRecordPageIndex = '0'
  pageSize
  historyRecordsPerPage = parseInt(TwowaycommentsPerPage)
  disablePrevious = false
  disableNext = false
  currentPageRecord = 0
  RevisionsHistoryRecord
  serviceStatusVisible ;


  connectedCallback() {
    this.showSpinner = true
    if (this.caseOrigin == Office_Trax) {
      this.showEmailContainer = false;
    }
    getExternalStatus({ caseId: this.recordId }).then((result => {
      if (result.problem === undefined) {
        this.getPortalData = result.data
        if(result.data.serviceDate != undefined && result.data.serviceDate != null)
          {
            this.currentServiceDate = result.data.serviceDate.substring(0,10)
          }
        let array = []
        if (this.getPortalData.serviceStatuses != null) {
          this.getPortalData.serviceStatuses.forEach(element => {
            array.push({ label: element.name, value: element.name })
          });
        }
        this.combooptions = array
      }
      else {
        var errorMessage = result.problem.errors[0].message;
        this.showToastMessage('Error!!', errorMessage, 'error')
      }
    })).catch((error => {
      this.showToastMessage('No data available', error.message, 'error')
    }))
  }

  //SDT-41051
   @wire(getOfficetraxServiceStatus)
   wiredService({ error, data }) {
    if (data != undefined) {
      this.serviceStatusVisible = data;
    }
  }

  //Onchange event of service Date field
  serviceDateChangeEvent(event) {
    this.dateTimeValue = event.target.value
  }
  //Onchange event of status field
  statusChangeEvent(event) {
    this.selectedStatus = event.target.value
  }

  handleButtonClick(event) {
    if (this.dateTimeValue == null && this.selectedStatus == null) {
      return this.showToastMessage('Review error', 'No Changes to update!', 'error')
    }
    else if(this.dateTimeValue < this.minDateTimeValue)
    {
      return this.showToastMessage('Review error', `Value must be ${this.formatter.format(new Date())} or later.`, 'error')
    }
    this.showSpinner = true;
    updateRecordToExSystem({ serviceDate: this.dateTimeValue, serviceStatus: this.selectedStatus, caseId: this.recordId }).then(result => {
      if (result.problem === undefined || result.problem === null) {
        this.showToastMessage('Success', 'Successfully created', 'success');
        this.reloadRevisionsHistoryRecord()
      }
      else {
        var errorMessage = result.problem.errors[0].message;
        this.showToastMessage('error', errorMessage, 'error');
      }
    }).catch(error => {
      this.showToastMessage('error', TwoWayAccessErrorMessage, 'error');
    })
  }

  reloadRevisionsHistoryRecord() {
    this.handleReset()
    refreshApex(this.RevisionsHistoryRecord)
  }

  showToastMessage(title, message, variant) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(toastEvent);
    this.showSpinner = false;
  }

  @wire(getServiceRevisionsHistoryRecord, { caseId: '$recordId', pageIndex: '$historyRecordPageIndex', pageSize: '$historyRecordsPerPage' })
  ServiceRevisionsHistoryRecord(result) {
    this.RevisionsHistoryRecord = result

    this.showSpinner = true
    const { data, error } = result
    if (data != undefined && data.data != null && data.data != undefined) {
      this.tableData = data.data.map(row => ({
        ...row,
        updatedcreateDate:new Date(row.createDate),
        updatedServiceDate:new Date(row.serviceDate)
      }));
      this.noRecordsToShow = false
      this.tableRecordCount = data.count
      this.historyRecordPageIndex = data.pageIndex
      this.pageSize = data.pageSize
      if (this.tableRecordCount == 0) {
        this.noRecordsToShow = true
        this.tableData = []
        this.disableNext = true
        this.disablePrevious = true
      }
      else {
        this.calculateCurrentPageCount(this.tableRecordCount)
      }
      this.showSpinner = false
    }
    else if (error) {
      this.showSpinner = false
      console.log('error msg ' + JSON.stringify(error.message))

    }
    else {
      this.showSpinner = false
    }
  }

  nextHandler() {
    this.historyRecordPageIndex += 1
  }
  previousHandler() {
    this.historyRecordPageIndex -= 1
  }

  get shownPageNumber() {
    return `${this.currentPageRecord} out of ${this.tableRecordCount}`
  }
  calculateCurrentPageCount(tableRecordCount) {
    this.disableNext = false
    this.disablePrevious = false
    let currentPageIndex = this.historyRecordPageIndex
    currentPageIndex++
    if(tableRecordCount == this.historyRecordsPerPage ||
      tableRecordCount < this.historyRecordsPerPage
    ){
      this.currentPageRecord = tableRecordCount
    }
    else{
      this.currentPageRecord = currentPageIndex * this.historyRecordsPerPage
    }
    if (this.currentPageRecord >= tableRecordCount) {
      this.currentPageRecord = tableRecordCount
      this.disableNext = true
      this.disablePrevious = false
    }
    if(this.currentPageRecord == this.historyRecordsPerPage){
      this.disablePrevious = true
    }
  }

  handleReset() {
    [...this.template
      .querySelectorAll('lightning-input, lightning-combobox')]
      .forEach((input) => { input.value = ''; });

    this.selectedStatus = null
    this.dateTimeValue = null
  }

}