import { LightningElement, api, wire, track } from 'lwc';
import fetchChatTranscript from '@salesforce/apex/GetChatNowTranscriptCtrl.getChatTranscript';
import getTaskDetail from '@salesforce/apex/GetChatNowTranscriptCtrl.fetchTaskDetail'; //SDT-32713
//import downloadPDF from '@salesforce/apex/GetChatNowTranscriptCtrl.getPDFPrint';
//import downloadjs from "@salesforce/resourceUrl/downloadjs";
//import { loadScript } from "lightning/platformResourceLoader";
import {NavigationMixin} from 'lightning/navigation';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import RefNumberField from "@salesforce/schema/Case.Reference_Number__c";
import Interactionfield from "@salesforce/schema/Case.Last_Customer_Interaction_ID__c";

const fields = [RefNumberField, Interactionfield];
export default class ChatNowTranscript extends NavigationMixin(LightningElement)  {

    @api isShowError = false;
    @track isButtonDisabled =true;
    @track selectedOption;
    @api isshowcancelbutton = false;
    @api isShowChat = false;
    @api recordId;
    @api chatTranscriptResult = [];
    @api taskDetailResult = [];
    @api CreatedDate;
    @track showSpinner = false;
    @track value = "";
    @track label = "";
    @api strFile;
    @api pdfString;
    @api errorMessage;
    @track returnedValue; 
    @track interactionVal;
    @track noChatPresent =false;
    @track isComboBoxDisabled = false;
    @track items = []; //this will hold key, value pair
   
    @api disableChatbutton = false;

/*    renderedCallback() {
        loadScript(this, downloadjs).then(() => {});
    }
*/  

    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    case;

    renderedCallback() {
        console.log(this.case.data);
    }

    get refNumber() {
        return getFieldValue(this.case.data, RefNumberField);
    }

    get interactionId() {
        return getFieldValue(this.case.data, Interactionfield);
    }

    connectedCallback(){
    //SDT-32713 :start
    getTaskDetail({
        caseId: this.recordId  
    })
    .then(result => {
        if(result && result.length>0){
           console.log('result ' + JSON.stringify(result));
            //this.taskDetailResult = result;
             this.taskDetailResult = result;
            // Basic For Loop
            for(let i=0; i<this.taskDetailResult.length; i++){
                console.log('createddate :: ' + this.taskDetailResult[i].CreatedDate);
                if(this.taskDetailResult[i].CreatedDate != null && this.taskDetailResult[i].InteractionID != ''){
               
                    this.CreatedDate = this.taskDetailResult[i].CreatedDate;
                   // this.returnedValue = this.CreatedDate;
                    this.items = [...this.items ,{value: this.taskDetailResult[i].InteractionID , label: this.taskDetailResult[i].CreatedDate} ];  
                   
                   
                   
                }else{
                  //  this.noChatPresent = true;
                }
            }
           
           
            
        }else{
            this.noChatPresent = true;
        }
    })
    
    } 
    
    get options() {
      
        return this.items;
    }
    
  
    handleChange(event) {
        this.value = event.detail.value;
        const selectedValue = event.detail.value;
        const selectedOption = this.options.find(option => option.value === selectedValue);
        if(selectedOption){
            const selectedLabel = selectedOption.label;
        }
        if(this.value!= null){
            this.selectedOption =event.detail.value;
            this.isButtonDisabled =!this.selectedOption;
            //this.invalidInteractionId = false;
            this.disableChatbutton = false;
        }
        else{
          // this.invalidInteractionId = true;
           this.disableChatbutton = true;
        }
        // SDT-32713 end
        }
        

    loadChatTranscript(){
        this.showSpinner = true;
        console.log('recordId : ' + this.recordId);
        this.interactionVal = this.value;
        //console.log('refNumber : ' + this.refNumber);
        //console.log('interactionId : ' + this.interactionId);
        fetchChatTranscript({
            caseId: this.recordId  ,
            transactionId: this.value
        })
        .then(result => {
            if(result && result.length>0){
            //    console.log('result ' + result);
                this.chatTranscriptResult = result;
                // Basic For Loop
                for(let i=0; i<this.chatTranscriptResult.length; i++){
                    console.log('error Message :: ' + this.chatTranscriptResult[i].errorMessage);
                    if(this.chatTranscriptResult[i].errorMessage != null ){
                        this.isShowError = true;
                        this.disableChatbutton = true;
                        this.isshowcancelbutton = true;
                        this.isComboBoxDisabled = true;
                        this.errorMessage = this.chatTranscriptResult[i].errorMessage;
                    }else{
                        this.isShowChat = true;
                        this.isComboBoxDisabled = true;
                        this.isShowError = false;
                        this.disableChatbutton = true;
                        this.isshowcancelbutton = true;
                    }
                }
            }else{
                this.isShowChat = false;
            }
        })
        .catch(error => {
            console.error(error);
            console.log('error JSON : ' + error);
        })
        .finally(f => {
            this.showSpinner = false;
        });
    }
    
    handleCloseClick(){
       // this.refreshCounter++;
        this.isshowcancelbutton = false;
        this.isShowChat = false;
        this.disableChatbutton = false;
        this.isComboBoxDisabled = false;
    }
   
       

/*    generatePdf() {
       // console.log('chatTranscriptResult ' + this.chatTranscriptResult);
       // alert('this chatTranscriptResult ' + JSON.stringify(this.chatTranscriptResult));
       // tableObj: JSON.stringify(this.chatTranscriptResult)
        downloadPDF({
            caseId: this.recordId
        }).then(response => {
             console.log('res 0 : ' + response[0]);
             this.strFile = "data:application/pdf;base64,"+response[0];
             window.open(response[1]);
        });
    } */

    generatePdfFiles(event){
       // alert('alert ' + JSON.stringify(this.chatTranscriptResult));
        var url = '/apex/ChatTranscriptDownloadPDF'+'?ref='+this.refNumber+'&resList='+JSON.stringify(this.chatTranscriptResult);
        window.open(url);
    }

}