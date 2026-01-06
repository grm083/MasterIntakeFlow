import { LightningElement, wire, api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { publish,subscribe,unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import LMS from "@salesforce/messageChannel/LMS__c";
import SERVICEDATE from "@salesforce/messageChannel/SetServiceDate__c";
import getCaseList from '@salesforce/apex/AssetHeadersForCaseController.showMutipleAssetCasesInfo';
import getCaseSummary from '@salesforce/apex/AssetHeadersForCaseController.fetchCaseSummary';
import hoverDelay from '@salesforce/label/c.HoverDelay';
import sleepDelay from '@salesforce/label/c.SleepDelay';
import { getRecord, getFieldValue  } from 'lightning/uiRecordApi';
import REFERENCE_NUMBER from '@salesforce/schema/Case.Reference_Number__c';
import PARENTID from '@salesforce/schema/Case.ParentId';
const FIELDS = [ REFERENCE_NUMBER,PARENTID,'Case.Id' ];


export default class MultiAssetCaseCard extends NavigationMixin(LightningElement) {
    // Flexipage provides recordId
    @api recordId;
    @track assetcss = 'position: fixed;width: 46rem;height: 25.5rem;padding-top: 20px;padding-left: 20px;padding-right: 20px;padding-bottom: 20px; top : 70px; left:60px;';
    @track cwrappers;
    @track openCaseFormModel = false;
    @track popUpCaseId;
    @track prdfamily;
    @track equipmenttype;
    @track duration;
    @track assethover = false;
    @track openRecordType = false;
    @track showAssetValidation = false;
    @track opentasks;
    @track actionCaseId;
    @track action;
    @track showOpenTask;
    @track assetValidation;
    @track recordTypeId;
    @track caseNumber;
    @track trackingNumer;
    @track caseSummary;
    @track openCaseSummary;
    caseSummaryId = null;
    istaskOpened = false;
    assethovercard = false;
    top =50;
    left=50;
    timer = null;
    referenceNumber;
    parentId;
    iteration = 1;
    subscription = null;
    invokeAura = true;
    ispublished = false;
    serviceDateSub = null;
    // Expose the labels to use in the template.
    label = {
        hoverDelay,
        sleepDelay,
    };
    @wire(MessageContext)context;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })recdata({ error, data }){
        if(data){
            this.caseDetails = data;
            this.referenceNumber = getFieldValue(this.caseDetails, REFERENCE_NUMBER);
            this.parentId = getFieldValue(this.caseDetails, PARENTID);
        }else if(error){
            console.log('GETError$$$$'+JSON.stringify(error));
        }
    };
    @wire(getCaseList, { caseNo: '$referenceNumber', recId: '$recordId',parentId: '$parentId',iteration : '$iteration' })caselist({ error, data }){
        if(data){
            console.log('CaseDetails$$$$'+JSON.stringify(data));
            this.cwrappers = data.MultiAssetCases;
            if((data.shownSummarybtn || (!data.shownSummarybtn && this.ispublished)) && this.invokeAura){
                    // fire contactSelected event
                    const message = {
                        caseId: this.recordId,
                        enable: data.shownSummarybtn
                    }
                    publish(this.context, LMS, message);
                    this.ispublished = true;
                    if (this.subscription) {
                        return;
                    }
                    this.subscription = subscribe(
                        this.context,
                        LMS, (message) => {
                            this.handleMessage(message);
                        },
                        {scope: APPLICATION_SCOPE});
            }
        }else if(error){
            console.log('GETError$$$$'+JSON.stringify(error));
        }
    };
    navigateTo(event) {
        let navigationId;
        const object = event.target.dataset.object;
        if(object == "Task"){
            this.istaskOpened = true;
        }
        if(event.target.dataset.object == 'Asset'){
            navigationId = event.target.dataset.assetid;
        }else {
            navigationId = event.target.dataset.id;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: navigationId,
                objectApiName: event.target.dataset.object,
                actionName: 'view'
            }
        });
    }
    openCaseRecordType(event){
        this.openRecordType = true;
        this.actionCaseId =  event.target.dataset.id;
    }
    openModelCaseType(event) {
        this.openCaseFormModel = true;
        this.popUpCaseId = event.target.dataset.id;
        this.action = 'CaseSubType';        
        this.recordTypeId = event.target.dataset.recordTypeId;
        this.prdfamily = event.target.dataset.prdfamily;
        this.equipmenttype = event.target.dataset.equipmenttype;
        this.duration = event.target.dataset.duration;
    }
    OpenReqInfo(event){
        this.openCaseFormModel = true;
        this.popUpCaseId = event.target.dataset.id;
        this.action = 'ReqInfo';
        this.recordTypeId = event.target.dataset.recordTypeId;
    }
    openServiceDateForm(event){
        //this.openCaseFormModel = true;
        this.popUpCaseId = event.target.dataset.id;
        this.action = 'serviceDate';
        this.recordTypeId = event.target.dataset.recordTypeId;
        // fire contactSelected event
        const message = {
            caseId: event.target.dataset.id,
            parentId: this.recordId,
            isCapacityEligible: event.target.dataset.isCapacityEligible,
        }
        publish(this.context, SERVICEDATE, message);
        if (this.serviceDateSub) {
            return;
        }
        this.serviceDateSub = subscribe(
            this.context,
            SERVICEDATE, (message) => {
                this.handleServiceDateMessage(message);
            },
            {scope: APPLICATION_SCOPE});
    }
    openCloseForm(event){
        this.openCaseFormModel = true;
        this.popUpCaseId = event.target.dataset.id;
        this.caseNumber = event.target.dataset.caseNumber;
        this.trackingNumer = event.target.dataset.trackingNumber;
        this.action = 'closeCase';       
    }
    closePopUp(){
        this.openCaseFormModel = false;
        this.openRecordType = false;
    }
    statusout(){
        this.assetValidation = '';
        this.showAssetValidation = false;
    }
    statusenter(event){
        this.assetValidation = event.target.dataset.assetValidation;
        this.showAssetValidation = true;
        this.top = event.clientY - this.assetValidation.length;
        this.left = event.clientX;
        this.assetcss = 'position: fixed;width: 30rem;height: min 2rem;padding-top: 20px;padding-left: 20px;padding-right: 20px;padding-bottom: 20px; top : '+this.top+'px; left: '+ this.left +'px;';
    }
    reqInfoOut(){
        this.assetValidation = '';
        this.showAssetValidation = false;
    }
    reqInfoEnter(event){
        this.assetValidation = event.target.dataset.reqInfo;
        this.showAssetValidation = true;
        this.top = event.clientY - this.assetValidation.length;
        this.left = event.clientX;
        this.assetcss = 'position: fixed;width: 30rem;height: min 2rem;padding-top: 20px;padding-left: 20px;padding-right: 20px;padding-bottom: 20px; top : '+this.top+'px; left: '+ this.left +'px;';
    }
    assetenter(event){
        let assetId = event.target.dataset.id;
        this.top = screen.height - event.screenY;
        this.left = Math.abs(event.clientX - 750);

        this.timer = setTimeout(() => {
            this.assethover = true;
            this.assethovercard = true;
            this.actionCaseId = assetId;          
            this.assetcss = 'position: fixed;width: 46rem;padding-top: 20px;padding-left: 20px;padding-right: 20px;padding-bottom: 20px; top : '+this.top+'px; left: '+ this.left +'px;';    
        }, this.label.hoverDelay);
    }
    assetout(){
        clearTimeout(this.timer);
        this.sleep(this.label.SleepDelay).then(() => {
            if(this.assethovercard){
                this.assethover = false;
                this.assethovercard = false;
            }
        });
    }
    sleep(delay){
        return new Promise(resolve => setTimeout(resolve, delay));
    }
    assetMouseHover(){
        this.assethovercard = false;
    }
    assetMouseHoverOut(){
        this.assethovercard = false;
        this.assethover = false;
    }
    caseUpdateEvent(event){
        this.openCaseFormModel = false;
        this.openRecordType = false;
        this.invokeAura = true;
        this.iteration = this.iteration + 1;            
    }
    handleMessage(message) {
        const receivedId = message.caseId;
        if(receivedId == this.recordId){
            console.log('Iteration'+this.iteration);
            this.invokeAura = false;
            this.iteration = this.iteration + 1;
        }
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    handleServiceDateMessage(message) {
        console.log('Invoked from AURA');
        const receivedId = message.caseId;
        if(receivedId == this.recordId){
            this.invokeAura = true;
            this.iteration = this.iteration + 1;
        }
        unsubscribe(this.serviceDateSub);
        this.serviceDateSub = null;
    }
    get showassethover(){
        
        if(this.assethover && this.actionCaseId){
            return true;
        }
        return false;
    }
    handleMenuSelect(event){
        // retrieve the selected item's value
        const selectedItemValue = event.detail.value;
        this.opentasks = JSON.parse(selectedItemValue);
        this.showOpenTask = true;
    }
    closeModel(){
        if(this.istaskOpened){
            this.iteration = this.iteration + 1;
        }
        this.showOpenTask = false;
        this.openCaseSummary = false;
    }
    handleRefresh(){
        this.iteration = this.iteration + 1;
    }
    showCaseSummary(event){
        this.openCaseSummary = true;
        console.log('$$$$$'+event.target.dataset.id);
        this.caseSummaryId = event.target.dataset.id;
        getCaseSummary({recId: this.caseSummaryId})
        .then((result) => {
            this.caseSummary = result;
        })
        .catch((error) => {
            console.log('GETError$$$$'+JSON.stringify(error));
        });
    }
}