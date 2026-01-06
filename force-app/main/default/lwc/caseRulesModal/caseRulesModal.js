import { LightningElement, api, track, wire } from 'lwc';
import fetchCaseBR from '@salesforce/apex/CaseRulesModalCtrl.getCaseRules';
import fetchBR from '@salesforce/apex/CaseRulesModalCtrl.getBRData';
import sendEmail from '@salesforce/apex/CaseRulesModalCtrl.sendEmail';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import {getRecord , getFieldValue} from 'lightning/uiRecordApi';
import strUserId from '@salesforce/user/Id';
import customerServiceProfile from '@salesforce/label/c.Customer_Service_Profile';

export default class CaseRulesModal extends NavigationMixin(LightningElement) {
@track brWrapperNoficationList = [];
    @track isShowModal = true;
    @api locationId;
    @api caseType;
    @api caseSubType;
    @api caseReason;
    @api caseIdRec;
    @track brWrapperList = [];
    @api recordId;
    @track brIds = [];
    @track caseIds = [];
    @track isShowBRData = true;
    @track showApprovalrules = false; // BUG FIX SDT-34169
    @track disableButton = false;
    @track disableSendEmailButton = false;
    @track showSpinner = false;
    @api allRuleType = false;
    @track prfName;
    @track helptext ="";
    @api isHaulAwayContainer;//SDT-46918

    userId = strUserId;

    @wire(getRecord, {recordId: strUserId, fields: [PROFILE_NAME_FIELD]}) 
    profileData({error, data}) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.prfName = getFieldValue(data, PROFILE_NAME_FIELD);
            if(this.prfName != customerServiceProfile /*||  this.disableSendEmailButton*/)   {
                this.disableButton = true;
            }   
        }
    }

    @api
    reloadCaseRules() {  
        this.loadCaseBusinessRules();
        this.isShowModal = true;
    }

    @api
    showBusinessRules(locationId, caseType, caseSubType, caseReason, isHaulAwayContainer) {  
        this.locationId = locationId;
        this.caseType = caseType;
        this.caseSubType = caseSubType;
        this.caseReason = caseReason;
        this.isHaulAwayContainer = isHaulAwayContainer;//SDT-46918
        this.fetchBusinessRules();
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
        this.brWrapperNoficationList = [];
        this.brWrapperList = [];
    }

    connectedCallback(){
        console.log('brWrapperList:', JSON.stringify(this.brWrapperList));
        
        if(!this.allRuleType){
            this.loadCaseBusinessRules();
        } else {
            this.fetchBusinessRules();
        } 
    }

    loadCaseBusinessRules(){
        this.showSpinner = true;
        //this.fetchCaseBusinessRules();
        console.log('rec : ' + this.recordId);
        fetchCaseBR({
            recordId: this.recordId 
        })
        .then(result => {
            if(result && result.length>0){
                result.forEach((eachBrRec) => {
                    if(eachBrRec.recordTypeName == 'Business Notification'){
                        this.brWrapperNoficationList.push(eachBrRec);
                    }else{
                        this.brWrapperList.push(eachBrRec);
                    }
                });
              //  this.brWrapperList = result;
                this.isShowBRData = true;
            }else{
                this.isShowBRData = false;
            }
// BUG FIX SDT-34169
            if(this.brWrapperList && this.brWrapperList.length > 0){
                this.showApprovalrules = true ;
            }else{
                this.showApprovalrules = false ;
            }
            // BUG FIX SDT-34169
        })
        .catch(error => {
            console.error(error);
            console.log('error JSON : ' + error);
        })
        .finally(f => {
            this.showSpinner = false;
        });
    }


    fetchBusinessRules(){
        this.showSpinner = true;
        console.log('rec : ' + this.recordId);
        fetchBR({
            locationId: this.locationId,
            caseType: this.caseType,
            caseSubType: this.caseSubType,
            caseReason: this.caseReason,
            caseIdRec: this.recordId
        })
        .then(result => {
            console.log('rec JSON : ' + JSON.stringify(result));
            //  this.brWrapperList = result;
            this.disableButton = true;
            if(result && result.length>0){
let recordCount = 1 ;
                //filter out  Bussiness notification rule from list
                if(this.allRuleType){
                    result.forEach((eachBrRec) => {
                        //modified as part of SDT-46918
                        const isHaulAway = (this.isHaulAwayContainer === true || 
                            (typeof this.isHaulAwayContainer === 'string' && this.isHaulAwayContainer.toLowerCase() === 'true'));
                       
                        if(isHaulAway) {
                            if(eachBrRec.recordTypeName == 'Approval' && eachBrRec.container == 'Haul Away Service'){
                                eachBrRec.brCount = recordCount ;
                                recordCount++
                                this.disableButton = true;
                                this.brWrapperList.push(eachBrRec);
                            }
                        }
                        else {
                            if(eachBrRec.recordTypeName == 'Approval' && eachBrRec.container !== 'Haul Away Service'){
                            eachBrRec.brCount = recordCount ;
                            recordCount++
                            this.disableButton = true;
                            this.brWrapperList.push(eachBrRec);
                        }
                        }
                    });
                }

            }
            if(brWrapperList && brWrapperList >0){
                this.isShowBRData = true;
            }else{
                this.isShowBRData = false;
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

    sendEmail(event){
        this.showSpinner = true;
        console.log('send email');
        this.brIds = event.target.value;
        this.caseIds = this.recordId;
        sendEmail({
            brlst: this.brIds,
            cselst: this.caseIds
        })
        .then(result => {
            if(result){
                this.showToastMessage('Success' , 'Email sent succesfully.' , 'success' , 'dismissable');
            }else{
                this.showToastMessage('Error' , 'No Email available for Service Approvers.' , 'error' , 'dismissable');
            }
        })
        .catch(error => {
           console.log('error==>' + JSON.stringify(error));
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