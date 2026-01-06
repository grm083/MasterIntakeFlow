/**
 * @author       : Asset Availability Team
 * @description  : Input section for Availability Standalone APP.
 * @History
 * -------
 * VERSION | AUTHOR                | DATE            | DESCRIPTION
 * 1.0     | Satnam Singh          | Aug 21, 2023    | User Story #SDT-32012
 ***/
import { LightningElement, api } from "lwc";
import getAccountAddress from "@salesforce/apex/AAV_AvailbilityAppHelper.getAccountAddress";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import makeApiCallout from "@salesforce/apex/AAV_APIIntegration.makeApiCallout";
import getAvailabilityRecordById from "@salesforce/apex/AAV_AvailbilityAppHelper.getAvailabilityRecordById";
import { NavigationMixin } from "lightning/navigation";

// custom Labels
import RECORD_SAVE_FAILURE_MSG from "@salesforce/label/c.AAV_Available_Record_Save_Failure";//'Failed to save or call Availability API';

const LOCATION_FIELD_API_NAME = "AAV_Location__c";
const LOCATION_NAME_FIELD_API = "AAV_Location_Name__c";
const ASSET_AVAILABILITY_API_NAME = "AAV_Asset_Availability__c";
const ASSET_AVAILABILITY_APP_NAME = "Asset_Availability";

const AVAILABILITY_FIELDS_LIST = ['location','lineOfBusiness','containerType','deliveryDate'
                                    ,'materialCode','serviceType'];
export default class AavAppInputPanel extends NavigationMixin(LightningElement) {
    @api recordId;
    newRecordId;
    showSpinner = true;
    locationData = {};
    accountName;
    runOnce;
    clonedRecordRef;
    get diabledInput() {
        return this.recordId;
    }
    handleLocationChange(event) {
        let accountId = event.detail.value[0];
        if (accountId) {
            this.getAccountAddress(accountId);
        } else {
            this.locationData = {};
            this.accountName ='';
        }
    }
    getAccountAddress(Id) {
        getAccountAddress({ accountId: Id })
            .then((result) => {
                this.locationData = result;
                this.accountName = result?.Parent?.Name;
            })
            .catch((error) => (this.error = error));
    }

    handleonload(event) {
        if (this.recordId && !this.runOnce) {
            this.runOnce = 1;
            let record = event.detail.records;
            let fields = record[this.recordId].fields;
            let locationId = fields[LOCATION_FIELD_API_NAME]?.value;
            if (locationId) {
                this.getAccountAddress(locationId);
            }
        }
        //SDT-32013
        else if(this.clonedRecordRef){
            AVAILABILITY_FIELDS_LIST.forEach(ele=>{
                this.template.querySelector(`[data-name="${ele}"]`).value = this.clonedRecordRef[ele];
            });
            this.getAccountAddress(this.clonedRecordRef.location);
            this.clonedRecordRef = null;
        }
        this.showSpinner = false;
    }
    handleSubmit(event) {
        event.preventDefault();
        this.showSpinner = true;
        let fields = event.detail.fields;
        fields[LOCATION_NAME_FIELD_API] = this.locationData.Name;
        this.availabilityCallout(fields);
    }
    availabilityCallout(fields) {
        makeApiCallout({ availability: fields, availabilityId: "" })
            .then((result) => {
                fields = result;
                this.template
                    .querySelector("lightning-record-edit-form")
                    .submit(fields);
            })
            .catch((error) => {
                this.showError(error);
            });
    }
    handleSuccess(event) {
        this.showSpinner = false;
        this.newRecordId = event.detail.id;
        this[NavigationMixin.Navigate](
            {
                type: "standard__recordPage",
                attributes: {
                    recordId: this.newRecordId,
                    objectApiName: ASSET_AVAILABILITY_API_NAME,
                    actionName: "view"
                }
            },
            true
        );
    }
    handleError() {
        this.showError();
    }
    showError(error) {
        this.showSpinner = false;
        console.error(error);
        this.dispatchEvent(
            new ShowToastEvent({
                title: RECORD_SAVE_FAILURE_MSG,
                variant: "error"
            })
        );
    }
    connectedCallback() {
        //SDT-32013
        let clonedRecordId = localStorage.getItem("aavClonedRecordId");
        if (clonedRecordId) {
            this.getAvailabilityRecordById(clonedRecordId);
        }
        localStorage.removeItem("aavClonedRecordId");
    }
    //SDT-32013
    getAvailabilityRecordById(clonedRecordId) {
        getAvailabilityRecordById({ recordId: clonedRecordId }).then(result => {
            this.clonedRecordRef = result;
        }).catch(error => {
            console.error(error);
        })
    }
    //SDT-32013
    handleCloneClick() {
        localStorage.setItem("aavClonedRecordId", this.recordId);
        this.navigateToNewAppPage();
    }
    navigateToNewAppPage() {
        this[NavigationMixin.Navigate](
            {
                type: "standard__navItemPage",
                attributes: {
                    apiName: ASSET_AVAILABILITY_APP_NAME
                }
            },
            true
        );
    }
}