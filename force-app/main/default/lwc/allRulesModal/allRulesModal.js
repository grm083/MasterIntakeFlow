import { LightningElement, track, api,wire} from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import LOCATION_FIELD from "@salesforce/schema/Case.Location__c";
import ID_FIELD from "@salesforce/schema/Account.Id";
import QUOTE_LOCATION_FIELD from "@salesforce/schema/SBQQ__Quote__c.SBQQ__Account__c";
import fetchAllBusinessRules from '@salesforce/apex/AllRulesModalController.fetchAllBusinessRules';
import fetchBusinessNotification from '@salesforce/apex/CaseRulesModalCtrl.getBrNotificationRecordsByLocation';
import { refreshApex } from '@salesforce/apex';
const CASE_FIELDS = [ LOCATION_FIELD];
const ACCOUNT_FIELDS = [ ID_FIELD];
const QUOTE_FIELDS = [ QUOTE_LOCATION_FIELD];
export default class AllRulesModal extends LightningElement {

    @track allRules = [];
    @track showSpinner = true;
    @api recordId;
    @track showSpinner = false;
    @track locationId;
@track businessId;
    @track showBusinessRule = false;
@track showBusinessNotification = false;
    @track caseType;
    @track caseSubType;
    @track caseReason;
@track brWrapperList;
    @api objectApiName;
    @track currentObjectApiName;
    @track isHaulAwayContainer = false; //SDT-46918

    @wire(getRecord, { recordId: '$recordId', fields: ['Id'] })
    wiredBaseRecord({ error, data }) {
        if (data) {
            // actual object API name of this recordId
            this.currentObjectApiName = data.apiName;
            console.log('Actual Object API Name:', this.currentObjectApiName);
        }
    }

    @wire(getRecord, { recordId:'$recordId',  fields: '$fields'})
    loadFields({error, data}){
        console.log('loadFields, recordId: ', JSON.stringify(data));
        if(error){
            console.log('error', JSON.parse(JSON.stringify(error)));
        }else if(data){
            const apiName = this.currentObjectApiName || this.objectApiName;
            if(apiName === 'Case') {
                this.locationId =  getFieldValue(data, LOCATION_FIELD);
            } else  if(apiName === 'SBQQ__Quote__c') {
                this.locationId =  getFieldValue(data, QUOTE_LOCATION_FIELD);
            }
             else {
                this.locationId =  getFieldValue(data, ID_FIELD);
            }
            this.fetchAllBusinessRules(this.locationId);
this.loadBusinessNotification(this.locationId);
        }
    }

    get fields() {
         const apiName = this.currentObjectApiName || this.objectApiName;
        if (apiName === "Case") {
            return CASE_FIELDS;
        }else if (apiName === "SBQQ__Quote__c") {
            return QUOTE_FIELDS;
        }
         else {
            return ACCOUNT_FIELDS;
        }
    }

    @api
    reloadAllRules(){
        refreshApex(this.loadFields);
    }

    fetchAllBusinessRules(locationId){
        this.showSpinner = true;
        fetchAllBusinessRules({
            locationId: locationId
        })
        .then(result => {
            this.allRules = result;
            this.showSpinner = false;
        })
        .catch(error => {
            console.error(error);
            this.showSpinner = false;
        });
    }

    //SDT-30949 - fetching business notification data
    loadBusinessNotification(locationId){
        this.showSpinner = true;
        fetchBusinessNotification({
            locationId: locationId 
        })
        .then(result => {
            if(result && result.length>0){


                this.brWrapperList = result.map(result=>({...result,formattedalias: `${result.alias} #${result.brCount}`}));
                this.isShowBRData = true;
            }else{
                this.isShowBRData = false;
            }
        })
        .catch(error => {

        })
        .finally(f => {
            this.showSpinner = false;
        });
    }
    

    openBusinessRule(event){
        this.showBusinessRule = true;
        this.caseType = event.currentTarget.dataset.ct; 
        this.caseSubType = event.currentTarget.dataset.cst; 
        this.caseReason = event.currentTarget.dataset.cr; 
        this.isHaulAwayContainer = event.currentTarget.dataset.ishaulaway;//SDT-46918
        if(this.template.querySelector('c-case-rules-modal')){
            this.template.querySelector('c-case-rules-modal').showBusinessRules(this.locationId, this.caseType, this.caseSubType, this.caseReason, this.isHaulAwayContainer) ;
        }      
    }

    //SDT-30949 -- adding event handler
    openBusinessNotification(event){
        this.showBusinessNotification = true;
        this.businessId = event.currentTarget.dataset.br; 
        if(this.template.querySelector('c-business-notification-cmp')){
            this.template.querySelector('c-business-notification-cmp').showBusinessNotification(this.locationId, this.businessId) ;
        }   


    }
}