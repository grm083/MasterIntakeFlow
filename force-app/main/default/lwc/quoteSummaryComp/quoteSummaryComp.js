import { LightningElement, track, api } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import getQuoteDetails from '@salesforce/apex/GetQuoteSummary.getQuoteDetails';
import getPicklistSchema from '@salesforce/apex/QuoteProcurementController.getPicklistSchema';

export default class QuoteSummaryComp extends LightningElement {
    @track quoteList;
    @track activeQuote;
    @track pickListSchema;
    @track isQuoteList;
    @api recordId;
    @track isLoading;
    connectedCallback(){
        this.isLoading = true;
        this.activeQuote='';
        this.isQuoteList = false;
        getQuoteDetails({caseId: this.recordId, userId:USER_ID}).
        then(data=>{
            data = JSON.parse(data);
            if(data){
                this.quoteList=[];
                data.forEach(element => {
                    this.isQuoteList = true;
                    const quote={};
                    quote.quoteNumber = element.quoteNumber;
                    quote.quoteStatus = element.quoteStatus;
                    quote.teamAssignment = element.teamAssignment;
                    quote.quoteRecordId = element.quoteRecordId;
                    quote.quoteDescription = element.quoteDescription;
                    quote.cpqEligible = element.cpqEligible;
                    quote.bundleList=[];
                    element.bundleList.forEach(ele =>{
                        quote.bundleList.push(ele);
                    });
                    this.quoteList.push(quote);
                });
            }
            this.getServicePicklists();
        });
    }
    getServicePicklists(){
        getPicklistSchema().then(data=>{
            this.pickListSchema = data;
        });
        this.isLoading = false;
    }
}