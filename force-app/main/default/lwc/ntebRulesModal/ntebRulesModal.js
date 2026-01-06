import { LightningElement, api, track, wire } from 'lwc';
//import fetchCaseBR from '@salesforce/apex/CaseRulesModalCtrl.getCase';
import fetchBR from '@salesforce/apex/NTEBRRulesModalCtrl.getBRData';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import {getRecord , getFieldValue} from 'lightning/uiRecordApi';
import strUserId from '@salesforce/user/Id';
import customerServiceProfile from '@salesforce/label/c.Customer_Service_Profile';
import { refreshApex } from '@salesforce/apex';

export default class NTEBRulesModal extends NavigationMixin(LightningElement) {
    @track isShowModal = false;
    @api accountId;
    @api locationId;
    @api recordTypeName;
    @api caseType;
    @api caseSubType;
    @api caseReason;

    @api brWrapperList = [];
    @api recordId;
    @track brIds = [];
    @track caseIds = [];
    @track isShowBRData = false;
    @track disableButton = false;
    @track disableSendEmailButton = false;
    @track showSpinner = false;
    @api allRuleType = false;
    @track prfName;
    userId = strUserId;
    requestType = '';
    showSpinner = false;
    /*
    @wire(getRecord, {recordId: '$recordId', fields: [RT_FIELD,LOCATION_FIELD,ACCOUNT_FIELD,
        REQUEST_TYPE_FIELD,SERVICE_FIELD,REASON_FIELD]}) 
    requestTypeData({error, data}) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.recordTypeId = getFieldValue(data, RT_FIELD);
            this.accountId = getFieldValue(data, ACCOUNT_FIELD);
            this.locationId = getFieldValue(data, LOCATION_FIELD);
            this.requestType = getFieldValue(data, REQUEST_TYPE_FIELD);
            this.serviceType = getFieldValue(data, SERVICE_FIELD);
            this.reason = getFieldValue(data, REASON_FIELD);
            console.log(' requestType :: '+ this.requestType);
            console.log(' locationId :: '+ this.locationId);
            console.log(' accountId :: '+ this.accountId);
        }
    }

    @api
    reloadCaseRules() {  
        refreshApex(this.profileData)
        this.loadCaseBusinessRules();
        this.isShowModal = true;
    }*/

    @api
    showBusinessRules(accountId, locationId, recordTypeName, caseType, caseSubType, caseReason) {
        console.log('accountId : ' + accountId + ' locationId: ' + locationId);
        this.accountId = accountId;  
        this.locationId = locationId;
        this.recordTypeName = recordTypeName;
        this.caseType = caseType;
        this.caseSubType = caseSubType;
        this.caseReason = caseReason;
        console.log('aura Type : ' + this.caseType + ' aura SubType: ' + this.caseSubType);
        this.fetchBusinessRules();        
        //this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }

  /*  connectedCallback(){
       console.log('this calling lwc ' + this.isShowModal); 
    }
*/
 
    @api
    fetchBusinessRules(){
        console.log('calling fetch BR');
        this.showSpinner = true;
       // this.isShowModal = true;
       // this.isShowBRData = true;
        console.log('get case record : ' + this.recordId);
        console.log('get case recordTypeName : ' + this.recordTypeName);
        console.log('get case accountId : ' + this.accountId);
        console.log('get case locationId : ' + this.locationId);
        console.log('get case caseType : ' + this.caseType);
        console.log('get case caseSubType : ' + this.caseSubType);
        fetchBR({
            caseRT : this.recordTypeName,
            accountId: this.accountId,
            locationId: this.locationId,
            caseType: this.caseType,
            caseSubType: this.caseSubType,
            caseReason: this.caseReason,
        })
        .then(result => {
            console.log('rec JSON : ' + JSON.stringify(result));
            this.brWrapperList = result;
            this.disableButton = true;
            if(result && result.length>0){
                this.isShowModal = true;
                this.isShowBRData = true;
            }else{
                this.isShowModal = false;
                this.isShowBRData = false;
                console.log('this isShowModal : '+this.isShowModal);
            }
        })
        .catch(error => {
            console.error(error);
            console.log('rec JSON : ' + JSON.stringify(error));
        })
        .finally(f => {
            this.showSpinner = false;
        });

        
    }

    showToastMessage(title , msg , variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: mode
        });

        this.dispatchEvent(evt);
    }

    navigateToRecordPage(event) {
        let brId = event.target.value;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: brId,
                actionName: 'view'
            }
        });
    }

}