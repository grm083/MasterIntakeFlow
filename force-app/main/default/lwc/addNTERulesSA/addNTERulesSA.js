import { LightningElement,api, wire  } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import LightningModal from 'lightning/modal';
import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from 'lightning/refresh';
import saveNTEData from '@salesforce/apex/AddNTERulesCtrl.saveNTERulesData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import REQUEST_TYPE_FIELD from "@salesforce/schema/Business_Rule__c.Request_Type__c";
import ACCOUNT_FIELD from "@salesforce/schema/Business_Rule__c.AccountId__c";
import LOCATION_FIELD from "@salesforce/schema/Business_Rule__c.LocationId__c";

export default class AddNTERulesSA extends LightningElement {
    @api recordId;
    amount = '';
    value = '';
    requestType = '';
    isShowModal = true;
    showSpinner = false;
    accountId = '';
    locationId = '';

    @wire(getRecord, {recordId: '$recordId', fields: [REQUEST_TYPE_FIELD,LOCATION_FIELD,ACCOUNT_FIELD]}) 
    requestTypeData({error, data}) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.requestType = getFieldValue(data, REQUEST_TYPE_FIELD);
            this.locationId = getFieldValue(data, LOCATION_FIELD);
            this.accountId = getFieldValue(data, ACCOUNT_FIELD);
            console.log(' requestType :: '+ this.requestType);
            console.log(' locationId :: '+ this.locationId);
            console.log(' accountId :: '+ this.accountId);
        }
    }

    handleAmountChange(e) {
        this.amount = e.detail.value;
    }

    handleCloseAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSubmitDetails(event){
        if(this.isFormValid()){
            this.showSpinner = true;
            var objDetails =
            {
                businessRuleId: this.recordId,
                serviceType: this.value,
                nteAmount: this.amount,
                accountId: this.accountId,
                locationId : this.locationId
            };
            saveNTEData({nTERulesData: JSON.stringify(objDetails)})
            .then(result => {
                console.log('Data:'+ JSON.stringify(result));
                this.showMessage('success' , 'SR record saved successfully' , 'Success' , 'dismissable');
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(new RefreshEvent());
            }) .catch(error => {
                //SDT-31225 -added toast 
                this.dispatchEvent(
                    new ShowToastEvent({
                        Title : 'Error',
                        message : error.body.message,
                        variant : 'error'
                    })
                );
                console.log(error);
                this.error = error;
            })
            .finally(fn => {
                this.showSpinner = false;
            }) ;
        }
        else {
            this.showMessage('Error' , 'Please fill the required fields' , 'Error' , 'dismissable');
        }
        
    }

    showMessage(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    isFormValid(){ 
        let valid = false;

        valid = [...this.template.querySelectorAll( 'lightning-input, lightning-combobox, lightning-dual-listbox')].reduce(
            (validSoFar, input) => {
                if( !input.checkValidity() ) {
                    input.classList.add('slds-has-error');

                } else {
                    input.classList.remove('slds-has-error');
                }
                input.reportValidity();
                return validSoFar && input.checkValidity();
            },
            true
        );
        return valid;
    }

    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }

    get options() {
            console.log(' V requestType :: '+ this.requestType);
            const serviceOptions = [];
            if (this.requestType == 'Add'){
                serviceOptions.push({ label: 'Container Washout', value: 'Container Washout'});
                serviceOptions.push({ label: 'Delivery', value: 'Delivery'});
                serviceOptions.push({ label: 'Demurrage', value: 'Demurrage'});
                serviceOptions.push({ label: 'Dry Run', value: 'Dry Run'});
                serviceOptions.push({ label: 'Equipment Installation', value: 'Equipment Installation'});
                serviceOptions.push({ label: 'Equipment Repair', value: 'Equipment Repair'});
                serviceOptions.push({ label: 'Equipment Sales', value: 'Equipment Sales'});
                serviceOptions.push({ label: 'Man Hours', value: 'Man Hours'});
                serviceOptions.push({ label: 'Mileage', value: 'Mileage'});
                serviceOptions.push({ label: 'Site Survey', value: 'Site Survey'});
                serviceOptions.push({ label: 'Trip Charge', value: 'Trip Charge'});
            }else if(this.requestType == 'Change Service'){
                serviceOptions.push({ label: 'Swapout', value: 'Swapout'});
            }else if(this.requestType == 'New Service'){
                serviceOptions.push({ label: 'Disposal', value: 'Disposal'});
                serviceOptions.push({ label: 'Hand Pickup', value: 'Hand Pickup'});
                serviceOptions.push({ label: 'Haul', value: 'Haul'});
                serviceOptions.push({ label: 'Pickup', value: 'Pickup'});
            }else if(this.requestType == 'Pickup'){
                serviceOptions.push({ label: 'Bulk', value: 'Bulk'});
                serviceOptions.push({ label: 'Haul Away – No Equipment', value: 'Haul Away – No Equipment'});
            }
            console.log('serviceOptions ' + JSON.stringify(serviceOptions));
        return serviceOptions;
        ;
    }

    handleChange(event) {
        this.value = event.detail.value;
    }
}