import { LightningElement,track,wire,api } from 'lwc';
import getRecordTypes from '@salesforce/apex/changeRecordTypeController.getRecordTypeNamesFromObject';
import caseRecordType from '@salesforce/label/c.CaseRecordType';
import caseSubTypeError from '@salesforce/label/c.CaseSubTypeError';

// import { getRecord } from 'lightning/uiRecordApi';
// import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
// import NAME_FIELD from '@salesforce/schema/User.Name';
// import Update_Asset_Active_User__c from '@salesforce/schema/User.Update_Asset_Active_User__c';

//Changes for SDT-24993
import checkassetCPQProduct from '@salesforce/apex/changeRecordTypeController.checkassetCPQProduct';
import isAssetUserAccess from '@salesforce/apex/changeRecordTypeController.isAssetUserAccess';

export default class ChangeRecordTypeCard extends LightningElement {
    @track recordTypes = [];
    rtValues;
    @track selectedItem;
    @track itemDescription;
    recordTypeId;
    @track recordTypeName;
    caseUpdate = false;
    @api recordId;
    orderedRecordType = caseRecordType;
    @api action;
    @api caseListView;
	@api errorCombination = false;
    @track errorMsg = caseSubTypeError;

    // @track error ;
    // @track name;
    // @wire(getRecord, {
    //     recordId: USER_ID,
    //     fields: [NAME_FIELD,Update_Asset_Active_User__c]
    // }) wireuser({
    //     error,
    //     data
    // }) {
    //     if (error) {
    //        this.error = error ; 
    //        alert(this.error)
    //     } else if (data) {
    //         this.name = data.fields.Name.value;
    //         this.Update_Asset_Active_User__c = data.fields.Update_Asset_Active_User__c.value;
    //     }
    // }

    connectedCallback(){
      this.fetchRecordTypes();
      this.hasCPQProduct();
      console.log('this.recordId '+this.recordId)
      if(this.recordId!=null && this.recordId !=undefined && this.recordId.startsWith('500'))
      this.hasAssetUserAccess();
    }

    hasAssetUserAccess(){
        isAssetUserAccess()
        .then((result)=> {
            this.Update_Asset_Active_User__c = result;
        })
        .catch((error) => {
            console.log('changeRecordType$$$$'+JSON.stringify(error));
        });
    }
    //Changes for SDT-24993
    hasCPQProduct(){
        checkassetCPQProduct({assetId:this.recordId})
        .then((result)=> {
            this.Update_Asset_Active_User__c = result;
        })
        .catch((error) => {
            console.log('changeRecordType$$$$'+JSON.stringify(error));
        });
    }
    fetchRecordTypes(){
        getRecordTypes({ objName: 'Case'})
        .then((result) => {
            let properOrder = this.orderedRecordType.split('|');
            this.rtValues = result;
            for (let j = 0; j < properOrder.length; j++) {
                for(let i = 0; i < this.rtValues.length; i++) {
                    if(this.rtValues[i].Name == properOrder[j]) {
                        this.recordTypes.push({
                                recid : this.rtValues[i].Id,
                                name : this.rtValues[i].Name,
                        });
                    } else if(i == this.rtValues.length){
                        this.recordTypes.push({
                            recid : this.rtValues[i].Id,
                            name : this.rtValues[i].Name,
                        });
                    }
                }
            }    
        })
        .catch((error) => {
            console.log('changeRecordType$$$$'+JSON.stringify(error));
        });
    }
    handleSelect(event){
        
        this.selectedItem = event.detail.name;
        let description = this.rtValues;
        if(description){
            for(let i = 0; i < description.length; i++) {
                if(description[i].Name == this.selectedItem){
                    this.itemDescription = description[i].Description;
                    this.recordTypeId = description[i].Id;
                    this.recordTypeName = description[i].Name;
                    this.reset();
                }
            }
        }
    }
   
    handleSubmit(event){
        event.preventDefault();       
        let fields = event.detail.fields;
        console.log(JSON.stringify(fields));
        this.dispatchEvent(new CustomEvent('next', { detail: {
            caseData: fields,
            recordTypeId: this.recordTypeId,
            recordTypeName: this.recordTypeName
        } }));
     }

     handleCancel(){
        this.dispatchEvent(new CustomEvent('cancel'));
     }
     get recordTypeSelected(){
        return this.recordTypeId ? true : false;
     }

     reset() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
     }

     handleButtonClick(event){
        if(event && event.target.name){
            this.recordTypeName = event.target.name;
            this.handleSubmit(event);
        }
     }


     
}