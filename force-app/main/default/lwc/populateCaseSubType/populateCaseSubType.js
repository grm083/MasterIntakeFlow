import { LightningElement,track,api,wire } from 'lwc';
import { getRecord,createRecord   } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import USER_ID from '@salesforce/user/Id';
import ACORN_SUSER_ID from '@salesforce/schema/User.Acorn_SUser_ID__c';
import COMMENT_OBJECT from '@salesforce/schema/Comment__c';
import CASE from '@salesforce/schema/Comment__c.Case__c';
import COMMENT from '@salesforce/schema/Comment__c.Comment__c';
import LOG_TYPE from '@salesforce/schema/Comment__c.Communication_Log_Type_Name__c';
import CASE_NUMBER from '@salesforce/schema/Comment__c.Case_Number__c';
import RECORDTYPE from '@salesforce/schema/Comment__c.RecordTypeId';
import TRACKING_NUMBER from '@salesforce/schema/Comment__c.Acorn_Tracking_Number__c';
import WORKFLOW_ACTION from '@salesforce/schema/Comment__c.Workflow_Action__c';
import WORKFLOW_TEAMUSER from '@salesforce/schema/Comment__c.Workflow_TeamUser__c';
import C_ACORN_SUSER from '@salesforce/schema/Comment__c.Acorn_SUser_ID__c';
import TYPE from '@salesforce/schema/Comment__c.Type__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
export default class ModalLwc extends LightningElement {
    @track bShowModal = true;
    @api recid;
    @api productFamily;
    @api equipmentType;
    @api duration;
    @track objectApiName = "Case"; 
    @track caseSubType = false;
    @track reqInfo = false;
    @track serviceDate = false;
    @track closeCase = false;
    @api action;
    @track title;
    @track objUser = {};
    @track validationmessage;
    @api recordTypeId;
    @api caseNumber;
    @api trackingNumber;
    iscaseUpdated = false;
    commentRecordTypeId;
    @wire(getObjectInfo, { objectApiName: COMMENT_OBJECT })objectInfo({data,error}){
        if(data){
            // Returns a map of record type Ids 
            const rtis = data.recordTypeInfos;
            this.commentRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Acorn Ticket Comment');
        }else if(error){
            console.log('Error Get RecordType'+JSON.stringify(error));
        }

    };
    @wire(getRecord, { recordId: USER_ID, fields: [ NAME_FIELD, ACORN_SUSER_ID ]}) wireuser({error,data}) {
        if (error) {
            console.log('$$$$'+JSON.stringify(error));
        } else if (data) {
            let objCurrentData = data.fields;

            this.objUser = {
                Name : objCurrentData.Name.value,
                Acorn_SUser_ID__c : objCurrentData.Acorn_SUser_ID__c.value,
            }
        }
    };
    /*@wire(getCaseSubTypes, {caseId: '$recid', assetId: '$assetid'})subTypeInfo({data,error}){
        if(data){
            this.subTypes = data;
        }else if(error){
            console.log('Error Get RecordType'+JSON.stringify(error));
        }

    };*/
    closeModal() {    
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModal = false;
        if(!this.iscaseUpdated){
            this.dispatchEvent(new CustomEvent('popupclose'));
        }
    }
    handleSubmit(event){

        if(this.action && this.action == 'CaseSubType'){
            const fields = event.detail.fields;
            if(this.productFamily && this.productFamily === 'Rolloff' && !(this.equipmentType === "Open Top" && this.duration === "Temporary") && (fields.Case_Sub_Type__c != 'Empty and Return' && fields.Case_Sub_Type__c != 'Empty and Do NOT Return' && fields.Case_Sub_Type__c != 'Bale(s)')){                
                
                    event.preventDefault();
                    this.validationmessage = "For Product Family RollOff we can only select Empty and Return,Empty And DO NOT Return and Bale(s)";
                
            }else if(this.productFamily && this.productFamily === 'Commercial' && this.equipmentType !== "Hand Pickup"  && (fields.Case_Sub_Type__c != 'Extra Pickup' && fields.Case_Sub_Type__c != 'On Call' && fields.Case_Sub_Type__c != 'Bale(s)')){
                
                    event.preventDefault();       // stop the form from submitting 
                    this.validationmessage = "For Product Family Commercial we can only select Extra Pickup, On-Call and Bale(s)";
                
            } else {
                this.validationmessage = null;
            }
        }
    }   
    handleSuccess(event){
        this.bShowModal = false;
        this.iscaseUpdated = true;
        if(this.action && this.action == 'closeCase'){
            const caseReason = this.template.querySelector('lightning-input-field[data-formfield="closeReason"]').value;
            const fields = {};
            fields[CASE.fieldApiName] = this.recid;
            fields[COMMENT.fieldApiName] = 'Case Close Reason-' + caseReason;
            fields[LOG_TYPE.fieldApiName] = 'Internal';
            fields[CASE_NUMBER.fieldApiName] = this.caseNumber;
            fields[RECORDTYPE.fieldApiName] = this.commentRecordTypeId;
            if(this.trackingNumber){
                fields[TRACKING_NUMBER.fieldApiName] = this.trackingNumber;
            }
            fields[WORKFLOW_ACTION.fieldApiName] = '';
            fields[WORKFLOW_TEAMUSER.fieldApiName] = this.objUser.Name;
            fields[C_ACORN_SUSER.fieldApiName] = this.objUser.Acorn_SUser_ID__c;
            fields[TYPE.fieldApiName] = 'Case';
            const recordInput = { apiName: COMMENT_OBJECT.objectApiName, fields };
            createRecord(recordInput)
            .then((comment) => {
            })
            .catch((error) => {
                console.log('##### '+JSON.stringify(error));
            });
        }        
        this.dispatchEvent(new CustomEvent('caseupdate'));
    }
    connectedCallback(){
        if(this.action && this.action == 'CaseSubType'){
            this.caseSubType = true;
            this.title = 'Fill in Sub-Type';
        }else if(this.action && this.action == 'ReqInfo'){
            this.reqInfo = true;
            this.title = 'Required Actions';
        }if(this.action && this.action == 'serviceDate'){
            this.serviceDate = true;
            this.title = 'Fill in Service Date';
        }if(this.action && this.action == 'closeCase'){
            this.closeCase = true;
            this.title = 'Close Case';
        }
    }
    /* javaScipt functions end */ 
}