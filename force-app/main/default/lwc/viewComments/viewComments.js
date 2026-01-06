import { LightningElement , wire ,track,api } from 'lwc';
import getcommentObjectList from '@salesforce/apex/viewComments.getcommentObjectList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TwowaycommentsPerPage from '@salesforce/label/c.TwowaycommentsPerPage';
import TwoWayAccessErrorMessage from '@salesforce/label/c.TwoWayAccessErrorMessage';


//changes related to SDT -32717 
const columns = [
    { label: 'Date', fieldName: 'receivedDateUpdated', type: 'date', sortable: true,hideDefaultActions: true,wrapText:true,initialWidth:230,typeAttributes: {day: 'numeric',month: 'numeric',year: 'numeric',hour: '2-digit',minute: '2-digit',hour12:true}},
    { label: 'Created By', fieldName: 'createdBy', type: 'text',hideDefaultActions: true,wrapText:true,initialWidth:230},
    { label: 'External Recipient', fieldName: 'recipientString', type: 'text',hideDefaultActions: true,wrapText:true,initialWidth:230},
    { label: 'Action Required', fieldName: 'isActionRequired', type: 'text',hideDefaultActions: true,wrapText:true,initialWidth:180},
    { label: 'Comment', fieldName: 'message', type: 'text',hideDefaultActions: true,wrapText:true}
];


export default class ViewComments extends LightningElement {

   
    @track tableData = [];
    @track problems = [];
    @track columns = columns;
    @track sortBy;
    @track wiredList = [];
    @track sortDirection = 'asc';
    @track showSpinner = true;
    @track noRecordsToShow = false;
    @api recordId;
    @api recordSize = 2;
    @track location;	
    totalPage = 0;
    recordCount;
    disableEnableNext = false;
    currentPage = 0;
    totalRecords;
    totalRecordsCounter = 0;
    shownPageNumber = 1;
    recordsPerPage = parseInt(TwowaycommentsPerPage);
 
    //add a callback function    
    connectedCallback(){
    this.getcommentObjectListApexCall();
    }

    //logic for sorting the data
    handleSortData(event){
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.tableData));
        let keyValue = a => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.tableData = parseData;
    }

    //for disabling and enabling previous button
    get disablePrevious(){ 
        return this.currentPage<=0;
    }

    //if number of records in the page is lesser than the pagesize
    get disableNext(){ 
        return this.disableEnableNext;
    }

    //for handling previous button
    previousHandler(){ 
        if(this.currentPage>0){
            this.showSpinner = true;
            this.shownPageNumber = this.shownPageNumber-1
            this.currentPage = this.currentPage-1
            this.disableEnableNext = false;
            this.getcommentObjectListApexCall();
        }
    }

    //for handling next 
    nextHandler(event){
        this.showSpinner = true;  
        //if(this.currentPage < this.totalPage){
            this.currentPage = this.currentPage+1
            this.shownPageNumber = this.shownPageNumber+1
            //this.updateRecords() 
                    
            this.getcommentObjectListApexCall();
       // }
    }   
    //function to show error message in the UI
    showErrorMessage(title,message,variant){
        const toastEvent= new ShowToastEvent({
            title  : title,
            message: message,
            variant: variant
          });
        this.dispatchEvent(toastEvent);
    } 
    
    //for calling specifically the apex method 'getcommentObjectList'
    getcommentObjectListApexCall(){
        getcommentObjectList({
            caseId: this.recordId,
            pageIndex:this.currentPage,
            pageSize:this.recordsPerPage
        }).then(result=>{
        if(result.data != undefined || result.data != null) {
                this.totalRecords = [...result.data];
		//SDT-36481
                //console.log('@@@ totalRecords 1'+result.location);
                this.location = result.location;
                this.recordCount = result.count;
        }else {
                this.noRecordsToShow = true;
              }
         if(this.recordCount ===0){
                this.noRecordsToShow = true;
              } 
       this.totalRecordsCounter = this.totalRecordsCounter+this.recordsPerPage;
    
       if(this.totalRecords===undefined || this.totalRecords.length<this.recordsPerPage || this.recordCount===this.totalRecords.length || this.totalRecordsCounter === this.recordCount){
               this.disableEnableNext = true;
       }
               this.problems = result.problem;
               this.recordSize = Number(this.recordSize);
       //this.totalPage = Math.ceil(data.data.length/this.recordSize);
       if(this.problems!==undefined && this.problems.errors.length!==0){
               this.noRecordsToShow = true;
               this.showErrorMessage('Error',this.problems.errors[0].message,'error');
               this.showSpinner = false;
       }else{
               this.updateRecords();
               this.showSpinner = false;
            }
    
        }).catch(error=>{
                console.log('error message by me ' + error);
                this.showSpinner = false;
                this.noRecordsToShow = true;
                this.showErrorMessage('Error',TwoWayAccessErrorMessage,'error');
    
        });
    }

        //for updating the data before putting to datatable
        updateRecords(){ 
			var regex = /(<([^>]+)>)/ig;

            var finaldatatable = [];
            this.totalRecords.forEach(function(commentData){
	     //SDT-36481
                if(!commentData.message.includes('Location')){	    
            var recepientList = [];
            //for avoiding timezone consideration while converting to date format from string
            commentData.receivedDate.replace(/T/g,"");
			commentData.message = commentData.message.replace(regex, "");
			//commentData.message.replace( /(<([^>]+)>)/ig, '');
			
            //for showing yes/no instead of true/false
            commentData.isActionRequired = commentData.isActionRequired ? 'Yes' : 'No';
            commentData.recipients.forEach(function(recepient){
                recepientList.push(recepient.user);               
            });
            var finalRecipientString = recepientList.toString().split(",").join(", ");
            var modifiedCommentData = Object.assign({...commentData}, { recipientString:finalRecipientString,receivedDateUpdated:new Date(commentData.receivedDate)});
            finaldatatable.push(modifiedCommentData);
	    }		
        });
            this.tableData = finaldatatable;
    }

}
