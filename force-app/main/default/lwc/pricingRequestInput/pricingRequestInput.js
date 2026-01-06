import { LightningElement,track,wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountAddress from '@salesforce/apex/PricingRequest.getAccountAddress';
import getPricingDetail from '@salesforce/apex/PricingRequest.getPricingDetail';
import getPricingMultiVendorDetail from '@salesforce/apex/PricingRequestAPIIntegration.getPricingDetail';
import getNAICSCode from '@salesforce/apex/PricingRequest.getNAICSCode';
import getCaseDetails from '@salesforce/apex/PricingRequest.getCaseDetails';
import validatePicklist from '@salesforce/apex/UTIL_Picklist.validatePicklist';
import validateDependentPicklist from '@salesforce/apex/UTIL_Picklist.validateDependentPicklist';
import checkPricingEligibility from '@salesforce/apex/PricingRequest.checkPricingEligibility';
import getPricingRecord from '@salesforce/apex/PricingRequest.getPricingRecord';
import isPricingMulltiVendorPTSwitchON from '@salesforce/apex/PricingRequestSelector.isPricingMulltiVendorPTSwitchON';

//Changes for Price Change SDT-27720
import getAssteDetails from '@salesforce/apex/PricingChangeRequest.getAssteDetails';
import getPricingChangeDetail from '@salesforce/apex/PricingChangeRequest.getPricingChangeDetail';
//End
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';


// Import custom labels
import Rolloff from '@salesforce/label/c.Rolloff';
import Commercial from '@salesforce/label/c.Commercial';
import Account_Eligibility from '@salesforce/label/c.Account_Eligibility';
import No_Mapping from '@salesforce/label/c.No_Mapping';
import PC_Baseline_FieldChange from '@salesforce/label/c.Error_PC_PT_FieldChange';

//Changes related to SDT- 33633 -Import user profile details
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import ProfileName from '@salesforce/schema/User.Profile.Name';


const DELAY = 350;

const FIELDS = [
    'Account.ShippingStreet',
    'Account.ShippingCity',
    'Account.ShippingState',
    'Account.ShippingStateCode',
    'Account.ShippingCountry',
    'Account.ShippingPostalCode'     
];

export default class PricingRequestInput extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference) pageRef;
    @track requestId;
    @track loadingSpinner = false;
    @track caseId;
    @track accountId;    
    @track  account;     
    @track error;
    @track buttonDisabled = false;
    @track buttonDisabledAndLOB = false;
    @track buttonDisabledCustomerOwned = false;
    @track buttonInfoDisabled = false;
    @track buttonCloneEnable = false;
    @api recordId;
    @track streetadd;
    @track cityadd;
    @track stateadd;
    @track countryadd;
    @track postaladd;
    @track naicsCode;
    @api txtLOB;
    @track lineOfBusinessValue;
    @track customerowned;
    @track quantity;
    @track addressLock = false;
    @track APIResponseStatus;
    @track case;
    @api containertype;
    @api containersize;
    @api materialtype;
    @track servicetype;
    @track frequencytype;
    @track frequencycount;
    @track picklistvalue;
    @track pcklstvalue;
    @track mappingError = false;
    @track Schedule_or_OnCall;
    @track isPricingEligible = false;
    @api isRollOff = false;
    @api isCommercial =false;
    @api isCommercial_SCH =false;
    @api isCaseError = false;
    @api caseErrorMessage = '';
    @track inputData;
    @track cloneRequestData;
    @track originalCaseNumber;
    @track parentPricingRequest;
    @track acornIssueId;
    @track caseNumber;
    @track acornTrackingNumber;
    @track pricingType = 'PT';
    @api projectrequest;
    @track project;
    @track showProject=false;
    @track GetButtonAvailability = true;
    @track isPriceChangeRequest = false;
    @track serviceBaselineId;
    @track pricingToggleChecked = true;

    @track equipmentType; //SDT-30110
    //Variable for SDT-30894
    @track asset_containersize;
    @track asset_quantity;
    @track asset_servicetype;
    @track asset_frequencytype;
    @track asset_frequencycount;
    //Changes related to SDT-33633
    @track isbuttonDisabled = false;
    @track isMultivendorResponse = false;
   
    //End SDT-30894
    // slaOverride = false; //AAC-1 - SDT-28753 SLA Override field
    // deliveryDate; //SDT-28765
    // slaComment; //SDT-28765
    // slaReason; //SDT-28765

    // Expose the labels to use in the JS File.
    label = {
        Rolloff,
        Commercial,
        Account_Eligibility,
        No_Mapping,
        PC_Baseline_FieldChange,
    };
    
//Changes related to SDT-33633 - wire method to fetch user details
@wire(getRecord, { recordId: Id, fields: [ ProfileName] })
userDetails({ error, data }) {
    if (error) {
        //this.error = error;
    } else if (data) {
        if (data.fields.Profile.value != null && data.fields.Profile.value.fields.Name.value ==='Customer Account Team') {
            this.isbuttonDisabled = true;
        }
    }
}

//adding for fetch the code switch value for multi vendor response
@wire(isPricingMulltiVendorPTSwitchON)
isSwitchOn({error,data}) {
    if(data !== undefined) {
        console.log('wire return is  ' + data);
        this.isMultivendorResponse = data;
    }
    else if(error) {
        console.log('error for wire is ' + error);
    }
}

    connectedCallback() {
        var isCloneRecord, cloneRecordId;
        
        if(localStorage.getItem("isClonedRecord")){
            isCloneRecord = localStorage.getItem("isClonedRecord");
            cloneRecordId = localStorage.getItem("cloneId");
            localStorage.removeItem("isClonedRecord");
            localStorage.removeItem("cloneId");
            this.callClonePricing(cloneRecordId);
        }
        else if(this.recordId != undefined){
            this.addressLock = true;
            //add condition to check the profile of the user
            this.buttonDisabled = true;
            this.buttonDisabledAndLOB = true;
            this.buttonDisabledCustomerOwned = true;
            this.buttonInfoDisabled = true;
            this.buttonCloneEnable = true;
            localStorage.removeItem("isClonedRecord");
            localStorage.removeItem("cloneId");
            
        }

        registerListener("setCaseNo", this.setCaseNo, this);
        registerListener("setInputParam", this.setInputParam, this);
    }

    disconnectedCallback() {
        // unsubscribe from showoutputscreen event
        unregisterAllListeners(this);
    }


    // Changes for Exhibit Pricing Story- SDT-20401
    handleonload(event){

        if(this.template.querySelector('.chkProjectRequest') !=null){

        this.projectrequest = this.template.querySelector('.chkProjectRequest').value;
        if(this.projectrequest!= undefined && this.projectrequest ==true)
        {
            this.showProject = true;
        }
        else{
            this.showProject = false;
        }
        }
    }

    handleSuccess(event) {
        this.recordId = event.detail.id;      
        const recordId = this.recordId;
        var responseData = [];
        this.buttonDisabled = true;
        this.addressLock = true;
        this.buttonDisabledAndLOB = true;
        this.buttonDisabledCustomerOwned = true;
        this.buttonInfoDisabled = true;
        this.buttonCloneEnable = true;

        window.scrollTo(0, 0);

        if(!this.mappingError){
            this.loadingSpinner = true;      
            setTimeout(() => {

                if(!this.isPriceChangeRequest) //Call for New Pricing
                {
                    if(this.isMultivendorResponse)
                    {
                        //API Call Start - New Pricing
                        getPricingMultiVendorDetail({ recordId: recordId, assetCall: false })
                        .then(result => {
                            this.APIResponseStatus = result[0];
                            this.lineOfBusinessValue = result[1];
                            responseData.push(this.recordId);
                            // if(this.APIResponseStatus)
                            //     this.APIResponseStatus = '{"data":null,"problem":{"title":"No Connection","status":400,"errors":[{"code":null,"message":"We are currently facing issue in connecting API system. Please try later."},{"code":null,"message":"We are currently facing issue in connecting API system. Please try later."}]}}';
                            // responseData.push(this.APIResponseStatus);
                            fireEvent(this.pageRef, 'showmultivendoroutputscreen', responseData);
                            
                            this.loadingSpinner = false;
                            
                            this.openPricingRecordPage();
                        })
                        .catch(error => {
                            this.error = error;
                            this.APIResponseStatus = undefined;
                        });
                        //API Call End - New Pricing
                    }
                    else
                    {
                        //API Call Start - New Pricing
                        getPricingDetail({ recordId: recordId, assetCall: false })
                        .then(result => {
                            this.APIResponseStatus = result[0];
                            this.lineOfBusinessValue = result[1];
                            responseData.push(this.recordId);
                            // if(this.APIResponseStatus)
                            //     this.APIResponseStatus = '{"data":null,"problem":{"title":"No Connection","status":400,"errors":[{"code":null,"message":"We are currently facing issue in connecting API system. Please try later."},{"code":null,"message":"We are currently facing issue in connecting API system. Please try later."}]}}';
                            // responseData.push(this.APIResponseStatus);
                            fireEvent(this.pageRef, 'showoutputscreen', responseData);
                            
                            this.loadingSpinner = false;
                            
                            this.openPricingRecordPage();
                        })
                        .catch(error => {
                            this.error = error;
                            this.APIResponseStatus = undefined;
                        });
                        //API Call End - New Pricing
                    }
                }
                else if(this.isPriceChangeRequest) //Call for Change Pricing
                {
                    //API Call Start - Change Pricing
                    getPricingChangeDetail({ recordId: recordId, assetCall: false })
                    .then(result => {
                        this.APIResponseStatus = result[0];
                        this.lineOfBusinessValue = result[1];
                        responseData.push(this.recordId);
                        // if(this.APIResponseStatus)
                        //     this.APIResponseStatus = '{"data":null,"problem":{"title":"No Connection","status":400,"errors":[{"code":null,"message":"We are currently facing issue in connecting API system. Please try later."},{"code":null,"message":"We are currently facing issue in connecting API system. Please try later."}]}}';
                        // responseData.push(this.APIResponseStatus);
                        fireEvent(this.pageRef, 'showoutputscreen', responseData);
                        
                        this.loadingSpinner = false;
                        
                        this.openPricingRecordPage();
                    })
                    .catch(error => {
                        this.error = error;
                        this.APIResponseStatus = undefined;
                    });
                    //API Call End - Change Pricing
                }
                


            
            }, 6000);
        }
    }

    validateInputRequestMapping(inputdata){
        var isValid = true;
        var inputError = "Invalid mapping value for pricing:";
        if(inputdata.fields.Container_Type__c == ""){
            inputError += " Container Type,";
            isValid = false;
        }
        if(inputdata.fields.Container_Size__c == ""){
            inputError += " Container Size,";
            isValid = false;
        }
        if(inputdata.fields.Material_Code__c == ""){
            inputError += " Material Code,";
            isValid = false;
        }
        if(inputdata.fields.Industry_Classification__c == ""){
            inputError += " Industry Classification Code,";
            isValid = false;
        }
        if(inputdata.fields.Line_of_Business__c == Commercial &&
            inputdata.fields.Schedule_or_On_Call__c == 'Scheduled'){
            if(!inputdata.fields.Frequency_Type__c){
                inputError += " Frequency Type,";
                isValid = false;
            }
            if(!inputdata.fields.Frequency_Count__c){
                inputError += " Frequency Count,";
                isValid = false;
            }
        }
        if(inputdata.fields.Container_Type__c == 'TOT')
        {
            if(inputdata.fields.Quantity__c > 5)
            {
                inputError += " Cannot use automated pricing for Qty > 5. Must be priced manually,";
                isValid = false;
            }
            if(inputdata.fields.Material_Code__c == 'C&D')
            {
                inputError += " Material Code Construction/Demolition,";
                isValid = false;
            }
        }
        if(this.isPriceChangeRequest == true && (this.baselineResult == "" || inputdata.fields.Service_Baseline_ID__c == ""))
        {
            inputError = "Please enter the baseline id to create the pricing request,";
            isValid = false;
        }
        if(this.isPriceChangeRequest == true)
        {
            if(this.asset_containersize === inputdata.fields.Container_Size__c && this.asset_quantity === inputdata.fields.Quantity__c && this.asset_servicetype === inputdata.fields.Service_Type__c
                && this.asset_frequencytype === inputdata.fields.Frequency_Type__c && this.asset_frequencycount === inputdata.fields.Frequency_Count__c)
                {
                    inputError = PC_Baseline_FieldChange;
                    isValid = false;
                }
        }
        if(!isValid){
            if (inputError.charAt(inputError.length - 1) == ',') {
                inputError = inputError.substring(0, inputError.length - 1);
                this.error = inputError + '.';
            }
        }
        return isValid;
    }

    handleSubmit(event){
        event.preventDefault();               // stop the form from submitting
        const fields = event.detail.fields;
        const inputFields = JSON.stringify(event.detail);
        var insertdata = JSON.parse(inputFields);
        window.scrollTo(0, 0);

        //if(this.isPricingEligible){    
            if(this.validateInputRequestMapping(insertdata)){
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
            else{
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: this.error,
                    variant: 'error',
                    mode: 'dismissable'
                  });
                  this.dispatchEvent(evt);
            }
        //     this.pricingType = 'PT';
        // }
        // else{
        //     this.pricingType = 'PTCO';
        //     const evt = new ShowToastEvent({
        //         title: 'Error',
        //         message: Account_Eligibility,
        //         variant: 'error',
        //         mode: 'dismissable'
        //       });
        //       this.dispatchEvent(evt);
        // }
    }

    handleError(event) {
        event.preventDefault(); 
        window.scrollTo(0, 0);
    }

    handleLOBChange(event)
    {
        this.lineOfBusinessValue = event.detail.value;

        if(this.lineOfBusinessValue == Rolloff)
        {        
            this.buttonDisabledAndLOB = true;
            this.isRollOff =  true;
            this.isCommercial =  false;
        }
        else if(this.lineOfBusinessValue == Commercial){
            this.isCommercial =  true;
            this.isRollOff =  false;
        }
        else{
            this.isCommercial =  false;
            this.isRollOff =  false;
        }
    }

    //Changes for SDT-26066
    handleSOCChange(event)
    {
        if(event.detail.value == 'On-Call')
        {        
            this.isCommercial_SCH =  false;
        }
        else if(event.detail.value == 'Scheduled')
        {
            this.isCommercial_SCH =  true;
        }
        else{
            this.isCommercial_SCH =  false;
        }
    }    

    // Changes for Exhibit Pricing Story- SDT-20401
    handleProjectRequestChange(event)
    {
        this.projectrequest = event.target.value;
        if(this.projectrequest ==true)
        {
            this.showProject = true;
        }
        else{
            this.showProject = false;
        }
    }

    handleCaseChange(event){
        const caseId = event.detail.value[0];
        
        if(caseId){
            getCaseDetails({ caseId })
                .then(result => {
                    try {
                        this.case = result;
                        // Changes for SDT-23327
                        if(result && this.case.Location__r == undefined){
                            const castevt = new ShowToastEvent({
                                title: 'Error',
                                message: 'Case should be in Open status',
                                variant: 'error',
                                mode: 'dismissable'
                                });
                            this.dispatchEvent(castevt);
                            return;
                        }
                        this.accountId = this.case.Location__r.ParentId;
                        this.isPricingEligible = this.case.Location__r.Parent.IsPricingEligible__c;
                        this.locationId = this.case.Location__c;

                        
                        this.txtLOB = this.case.LOB__c;
                        this.lineOfBusinessValue = this.txtLOB;
                        this.streetadd = this.case.Location__r.ShippingStreet;
                        this.cityadd = this.case.Location__r.ShippingCity;
                        this.stateadd = this.case.Location__r.ShippingState;
                        this.countryadd = this.case.Location__r.ShippingCountry;
                        this.postaladd = this.case.Location__r.ShippingPostalCode;
                        this.quantity = this.case.SalesMeet_Quantity__c;
                        this.acornIssueId = this.case.Acorn_Issue_Id__c;
                        this.caseNumber =  this.case.CaseNumber;
                        this.acornTrackingNumber = this.case.Tracking_Number__c;
                        this.servicetype = this.case.Case_Sub_Type__c == "Permanent" ? "PERM" : "TEMP"; //CHange Label
                        //this.Schedule_or_OnCall = this.case.Service_Occurrence_Type_Code__c == "Scheduled" ? "Scheduled" : "On-Call";
                        //this.Schedule_or_OnCall = this.case.Service_Occurrence_Type_Code__c == "On-Call" || this.case.Service_Occurrence_Type_Code__c == "Scheduled On-Call" ? "On-Call" : "Scheduled";

                        if(!this.isPricingEligible){
                            this.pricingType = 'PTCO';
                            const evt = new ShowToastEvent({
                                title: 'Warning',
                                message: Account_Eligibility,
                                variant: 'warning',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        }
                        else
                        {
                            this.pricingType = 'PT';
                        }
                        
                        
                        var inputError = "Invalid mapping value for pricing:";            
                        
                        getNAICSCode({accountId: this.case.Location__r.ParentId})
                            .then(result =>{
                                if(result)
                                    this.naicsCode = result;
                                else{
                                    inputError += " Industry Classification Code,";
                                    this.mappingError = true;
                                    this.isCaseError = true;
                                    this.buttonInfoDisabled = true;
                                }
                            });
                        validatePicklist({ ObjectApiName: "Pricing_Request__c", FieldApiName : "Container_Type__c", fieldValue: this.case.Equipment_Type_Code__c })
                            .then(result => {
                                this.picklistvalue = result;
                                if(this.picklistvalue.isvalid){
                                    this.containertype = this.picklistvalue.apivalue;

                                    if(this.containertype){
                                        validateDependentPicklist({ ObjectApiName: "Pricing_Request__c", FieldApiName : "Container_Size__c", ControllingfieldValue: this.case.Equipment_Type_Code__c, DependentfieldValue: this.case.Equipment_Size_Code__c })
                                        .then(result => {
                                            this.picklistvalue = result;
                                            if(this.picklistvalue.isvalid){
                                                this.containersize = this.picklistvalue.apivalue;
                                            }
                                            else{
                                                inputError += " Container Size: " + this.case.Equipment_Size_Code__c + ",";
                                                this.containersize = No_Mapping;
                                                this.mappingError = true;
                                                this.isCaseError = true;
                                                this.buttonInfoDisabled = true;
                                            }
                                        });
                                    }
                                    else{
                                        this.containersize = No_Mapping;

                                    }
                                }
                                else{
                                    inputError += " Container Type: " + this.case.Equipment_Type_Code__c + ",";
                                    this.containertype = No_Mapping;
                                    this.containersize = No_Mapping;
                                    this.mappingError = true;
                                    this.isCaseError = true;
                                    this.buttonInfoDisabled = true;
                                }
                            });
                        validatePicklist({ ObjectApiName: "Pricing_Request__c", FieldApiName : "Material_Code__c", fieldValue: this.case.Material_Type__c })
                            .then(result => {
                                this.picklistvalue = result;
                                if(this.picklistvalue.isvalid)
                                    this.materialtype = this.picklistvalue.apivalue;
                                else{
                                    inputError += " Material Code: " + this.case.Material_Type__c + ",";
                                    this.materialtype = No_Mapping;
                                    this.mappingError = true;
                                    this.isCaseError = true;
                                    this.buttonInfoDisabled = true;
                                }
                            });

                        setTimeout(() => {
                            this.loadingSpinner = true;      

                            if(this.lineOfBusinessValue == Commercial){
                                if(this.case.Service_Occurrence_Type_Code__c == "Scheduled"){
                                    this.Schedule_or_OnCall = this.case.Service_Occurrence_Type_Code__c;
                                }
                                else{
                                    this.Schedule_or_OnCall = No_Mapping;
                                    inputError += " Schedule or On-Call: " + this.case.Service_Occurrence_Type_Code__c + ",";
                                    this.mappingError = true;
                                    this.isCaseError = true;
                                }
                            }
                            else{
                                if(this.case.Service_Occurrence_Type_Code__c == "On-Call" || this.case.Service_Occurrence_Type_Code__c == "Scheduled On-Call"){
                                    this.Schedule_or_OnCall = "On-Call";
                                }
                                else{
                                    this.Schedule_or_OnCall = No_Mapping;
                                    inputError += " Schedule or On-Call: " + this.case.Service_Occurrence_Type_Code__c + ",";
                                    this.mappingError = true;
                                    this.isCaseError = true;
                                }
                            }

                            if(this.case.Event_Recurrence_Type_Code__c){
                                this.calculateFrequency(this.case.Event_Recurrence_Type_Code__c, this.case.Event_Recurrence_Interval__c, this.case.Frequency__c);
                                this.isRollOff =  false;
                                this.isCommercial =  true;

                                if(this.frequencytype == No_Mapping){
                                    this.isCaseError = true;
                                    inputError += " Frequency Type/ Frequency Count,";
                                }
                            }
                            else{
                                if(this.lineOfBusinessValue == Commercial){
                                    this.frequencytype = No_Mapping;
                                    this.frequencycount = No_Mapping;
                                    this.isRollOff =  false;
                                    this.isCommercial =  true;
                                    this.isCommercial_SCH =  true;
                                    this.mappingError = true;
                                    this.isCaseError = true;
                                    inputError += " Frequency Type/Frequency Count,";
                                }
                                else{
                                    this.frequencytype = '';
                                    this.frequencycount = '';
                                    this.isRollOff =  true;
                                    this.isCommercial =  false;
                                    this.isCommercial_SCH =  false;
                                }
                            }
                        },3000);    
                        setTimeout(() => {
                            if(this.mappingError){
                                if (inputError.charAt(inputError.length - 1) == ',') {
                                    inputError = inputError.substr(0, inputError.length - 1);
                                    this.error = inputError + '.';
                                    
                                    this.caseErrorMessage = this.error;
                                }
                                setTimeout(() => {
                                    this.template.querySelector('lightning-record-edit-form').submit();
                                    this.buttonCloneEnable = true;
                                    this.loadingSpinner = false;      
                                },1000);
                            }
                            else{
                                this.loadingSpinner = false;      
                            }
                        },4000); 
                        this.buttonDisabled = true;
                        this.addressLock = true;
                        this.buttonDisabledAndLOB = true;
                        this.buttonDisabledCustomerOwned = true;
                        this.buttonInfoDisabled = false;    
                    } catch (error) {
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: error.message,
                            variant: 'error',
                            mode: 'dismissable'
                            });
                        this.dispatchEvent(evt);
                        this.loadingSpinner = false;      
                    }
                })
                .catch(error => {
                    this.error = error;
                    this.account = undefined;                    
                });
                /*
            setTimeout(() => {
                this.template.querySelectorAll('lightning-input-field[data-formfield="address"]').forEach(element => {
                    element.reportValidity();
                });
            }, 1000);
            */
        }else{
           
            this.refreshScreenComponent();
        } 
    }

    refreshScreenComponent()
    {
        this.accountId = '';
        this.locationId = '';
        
        this.quantity = '1';
        this.servicetype = '';
        this.Schedule_or_OnCall = '';
        this.naicsCode = '';
        this.txtLOB = '';
        this.containertype = '';
        this.containersize = '';
        this.materialtype = '';
        this.frequencytype = '';
        this.frequencycount = '';
        this.lineOfBusinessValue = '';
        this.acornIssueId = '';
        this.caseNumber = '';
        this.acornTrackingNumber = '';
        this.project = '';
        this.pricingType = 'PT';
        //Change Price component - Start
        this.serviceBaselineId = '';
        this.baselineResult = '';
        //Change Price component - End
        this.projectrequest=false;        
        this.isPricingEligible = false;
        this.buttonDisabled = false;
        this.addressLock = false;

        //Putting Address value below to addressLock
        this.streetadd = '';
        this.cityadd = '';
        this.stateadd = '';
        this.countryadd = '';
        this.postaladd = '';
        this.buttonDisabledAndLOB = false;
        this.buttonDisabledCustomerOwned = false;
        this.buttonInfoDisabled = false;
        this.mappingError = false;

        //Changes SDT-30894
        this.asset_containersize = '';
        this.asset_quantity = '';
        this.asset_servicetype = '';
        this.asset_frequencytype = '';
        this.asset_frequencycount = '';
        //
    }

    calculateFrequency(eventType,eventInterval,frequency){
        
        var intfrequency = frequency ? parseInt(frequency) : parseInt(1);
        var inteventInterval = parseInt(eventInterval);
        if(eventType == "Monthly"){
            if(inteventInterval == 1 && intfrequency == 1){
                this.frequencytype = 'Monthly';
                this.frequencycount = '1';
            }
            else{
                this.mappingError = true;
                this.frequencytype = No_Mapping;
                this.frequencycount = No_Mapping;
            }
        }
        else{
            if(inteventInterval == 2 && intfrequency == 1){
                this.frequencytype = 'EOW';
                this.frequencycount = '0.5';
            }
            else if(inteventInterval == 1 && (intfrequency == 1 || intfrequency == 2 || intfrequency == 3 || intfrequency == 4 || intfrequency == 5 || intfrequency == 6 || intfrequency == 7)){
                this.frequencytype = 'Weekly';
                setTimeout(() => {
                    this.frequencycount = intfrequency.toString();
            },1000);
            }
            else{
                this.mappingError = true;
                this.frequencytype = No_Mapping;
                this.frequencycount = No_Mapping;
            }
        }
    }
        
    handleIndClas(event){
        const accountId= event.detail.value[0];
        if(accountId){
            getNAICSCode({ accountId })
                .then(result => {
                    this.naicsCode = result;
                })
                .catch(error => {
                    this.error = error;
                    this.account = undefined;
                });
            checkPricingEligibility({accountId: accountId}) 
                .then(result => {
                    this.isPricingEligible = result;
                    if(!this.isPricingEligible){
                        this.pricingType = 'PTCO';
                        const evt = new ShowToastEvent({
                            title: 'Warning',
                            message: Account_Eligibility,
                            variant: 'warning',
                            mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                    }
                    else
                    {
                        this.pricingType = 'PT';
                    }
                })
                .catch(error => {
                    this.error = error;
                    this.account = undefined;
                });
        }else{
            this.naicsCode = '';
            this.project = '';
            this.isPricingEligible = false;
        } 
        
    }

    handleLocationChange(event) {    
        const accountId= event.detail.value[0];
        
        if(accountId)
        {
            getAccountAddress({ accountId })
            .then(result => {
                this.account = result;
                this.accountId = this.account.ParentId; 
                this.streetadd = this.account.ShippingStreet;
                this.cityadd = this.account.ShippingCity;
                this.stateadd = this.account.ShippingState;
                this.countryadd = this.account.ShippingCountry;
                this.postaladd = this.account.ShippingPostalCode;

                //if(this.naicsCode == ''){
                    getNAICSCode({accountId: this.account.ParentId}) 
                    .then(result => {
                        this.naicsCode = result;
                    })
                    .catch(error => {
                        this.error = error;
                    });
                //}
                checkPricingEligibility({accountId: this.account.ParentId}) 
                    .then(result => {
                        this.isPricingEligible = result;
                        if(!this.isPricingEligible){
                            this.pricingType = 'PTCO';
                            const evt = new ShowToastEvent({
                                title: 'Warning',
                                message: Account_Eligibility,
                                variant: 'warning',
                                mode: 'dismissable'
                                });
                                this.dispatchEvent(evt);
                        }
                        else
                        {
                            this.pricingType = 'PT';
                        }
                    })
                    .catch(error => {
                        this.error = error;
                    });                        
                this.error = undefined;
                this.addressLock = true;
                this.project = '';
            })
            .catch(error => {
                this.error = error;
                this.account = undefined;
            });        
            setTimeout(() => {
                this.template.querySelectorAll('lightning-input-field[data-formfield="address"]').forEach(element => {
                    element.reportValidity();
                });
            }, 1000);
        }
        else
        {
            this.accountId = '';
            this.streetadd = '';
            this.cityadd = '';
            this.stateadd = '';
            this.countryadd = '';
            this.postaladd = '';
            this.naicsCode = '';
            this.project = '';
            this.addressLock = false;
            this.isPricingEligible = false;
        }
                
    }

    clonePricingInput(event){
        if(!this.isPricingEligible){
            this.pricingType = 'PTCO';
            const evt = new ShowToastEvent({
                title: 'Warning',
                message: Account_Eligibility,
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            return;
        }
        else{
            this.pricingType = 'PT';
            this.createNewRequest();
            localStorage.setItem("isClonedRecord", true);
            localStorage.setItem("cloneId", this.recordId);
        }
    }

    callClonePricing(Id){
        getPricingRecord({ recordId: Id })
        .then((result) => {
            this.parentPricingRequest = result.Id;
            this.accountId = result.Account__c;
            this.locationId = result.Location__c;
            this.txtLOB = result.Line_of_Business__c;
            this.streetadd = result.Service_Street_Address__c;
            this.cityadd = result.Service_City__c;
            this.stateadd = result.Service_State__c;
            this.countryadd = result.Service_Country__c;
            this.postaladd = result.Service_Postal_Code__c;
            this.naicsCode = result.Industry_Classification__c;
            this.txtLOB = result.Line_of_Business__c;
            this.lineOfBusinessValue = result.Line_of_Business__c;
            this.projectrequest = result.Project_Request__c;
            this.project = result.Project_Code__c;

            setTimeout(() => {
                this.containertype = result.Container_Type__c != No_Mapping? result.Container_Type__c : '';
                this.materialtype = result.Material_Code__c != No_Mapping? result.Material_Code__c : '';
            },500);
            setTimeout(() => {
                this.containersize = result.Container_Size__c != No_Mapping? result.Container_Size__c : '';
            },500);
            this.servicetype = result.Service_Type__c;
            this.customerowned = result.Customer_Owned__c;
            this.quantity = result.Quantity__c;
            this.Schedule_or_OnCall = result.Schedule_or_On_Call__c != No_Mapping? result.Schedule_or_On_Call__c : '';
            
            this.originalCaseNumber = result.Case__r ? result.Case__r.CaseNumber : '';
            this.isPricingEligible = true;            
            if(this.lineOfBusinessValue == Commercial){
                this.isRollOff =  false;
                this.isCommercial =  true;
                this.isCommercial_SCH = this.Schedule_or_OnCall == 'Scheduled' ? true : false;
                this.frequencytype = result.Frequency_Type__c != No_Mapping? result.Frequency_Type__c : '';
                this.frequencycount = result.Frequency_Count__c != No_Mapping? result.Frequency_Count__c : '';
            }
            else{
                this.isRollOff =  true;
                this.isCommercial =  false;
            }
            //SDT-27720 : Start
            this.isPriceChangeRequest = result.IsPriceChangeRequest__c;
            this.serviceBaselineId = result.Service_Baseline_ID__c;
            if(this.isPriceChangeRequest)
            {
                this.pricingToggleChecked = false;
                this.reloadPriceChangePage(this.serviceBaselineId);
            }
            else
            {
                this.pricingToggleChecked = true;
            }
            //SDT-27720 : End
        })
        .catch(error => {
            this.error = error;
        });
    } 

    setCaseNo(data){
        this.caseId = data;
    }

    setInputParam(data){
        if(data[0] == Rolloff){
            this.isRollOff = true;
            this.isCommercial = false;
        }
        else if(data[0] == Commercial){
            this.isRollOff = false;
            this.isCommercial = true;
            this.isCommercial_SCH = data[1] == 'Scheduled' ? true : false;
        }
        else
        {
            this.isRollOff = false;
            this.isCommercial = false;
        }
        this.isPricingEligible = true;
        //SDT-27720, Set PriceChange flag and Baseline
        this.isPriceChangeRequest = data[2]; 
        this.serviceBaselineId = data[3];
        console.log('Price Change Flag: ' + this.isPriceChangeRequest);
        if(this.isPriceChangeRequest)
        {
            this.pricingToggleChecked = false;
            this.reloadPriceChangePage(this.serviceBaselineId);
        }
        else
        {
            this.pricingToggleChecked = true;
        }
    }

    createNewRequest() {    
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Pricing'
            },
        }, true);
    }
    
    recordPageUrl;

    openPricingRecordPage() {    
        
       this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Pricing_Request__c',
                actionName: 'view'
            },
        }, true);        
    }


    //Price Change - SDT-27720
    //Changes by Ali/Jatan : SDT-27720
    @track baselineResult ;
    handleBaselineChange(event){
      this.serviceBaselineId =  event.target.value;
    }
    changeToggle(event){
        this.pricingToggleChecked = !this.pricingToggleChecked;
        if(this.pricingToggleChecked == false) 
        {
            //Condition - for Price Change
            this.isPriceChangeRequest = true;
        }
        else
        {
            this.isPriceChangeRequest = false;
        }
        this.refreshScreenComponent();
        console.log('Toggle pricingChecked '+this.pricingToggleChecked)
    };
    //End

    //changes by jatan
    handleSearchClick(event)
    {
        console.log('Inside handleSearchClick')

        if(this.serviceBaselineId == undefined || this.serviceBaselineId == "")
        {
            const emptyBaseline = new ShowToastEvent({
                title: 'Error',
                message: 'Please enter the baseline Id.',
                variant: 'error',
                mode: 'dismissable'
                });
            this.dispatchEvent(emptyBaseline);
            return;
        }
        let baselineId = this.serviceBaselineId
        console.log('this.serviceBaselineId '+ this.serviceBaselineId)
        this.loadingSpinner = true;             

        getAssteDetails({ baselineId })
        .then(result => {
            console.log('Inside result '+result)
            this.baselineResult = result;
            if(result &&  this.baselineResult.Id == undefined){
               this.baselineResult = false;
               this.loadingSpinner = false;

                const baselineevt = new ShowToastEvent({
                    title: 'Error',
                    message: 'This asset does not meet the standard criteria for a Change Pricing Event. The asset must be a WM Open Market, Commercial, Permanent, Scheduled Service.',
                    variant: 'error',
                    mode: 'dismissable'
                    });
                this.dispatchEvent(baselineevt);
                return;
            }

            this.accountId = this.baselineResult.Account.ParentId;
            this.isPricingEligible = this.baselineResult.Account.Parent.IsPricingEligible__c;
            this.locationId = this.baselineResult.AccountId;

            
            this.txtLOB = this.baselineResult.ProductFamily; //TBD
            this.lineOfBusinessValue = this.txtLOB; //TBD
            this.streetadd = this.baselineResult.Account.ShippingStreet;
            this.cityadd = this.baselineResult.Account.ShippingCity;
            this.stateadd = this.baselineResult.Account.ShippingState;
            this.countryadd = this.baselineResult.Account.ShippingCountry;
            this.postaladd = this.baselineResult.Account.ShippingPostalCode;
            this.quantity = this.baselineResult.Quantity__c;
            this.asset_quantity = this.baselineResult.Quantity__c;
            // this.acornIssueId = this.case.Acorn_Issue_Id__c;
            // this.caseNumber =  this.case.CaseNumber;
            // this.acornTrackingNumber = this.case.Tracking_Number__c;
            this.servicetype = this.baselineResult.Duration__c == "Permanent" ? "PERM" : "SEAS"; //CHange Label
            this.asset_servicetype = this.servicetype;
            this.Schedule_or_OnCall = this.baselineResult.Occurrence_Type__c;

            var scheduletype = this.baselineResult.Schedule__c;
            if(scheduletype.substring(0,1) == 'W')
            {
                this.frequencytype = 'Weekly';
                this.frequencycount = this.baselineResult.Weekly_Frequency__c;
            }
            else if(scheduletype.substring(0,1) == 'E')
            {
                this.frequencytype = 'EOW';
                this.frequencycount = '0.5';
            }
            else if(scheduletype.substring(0,1) == 'M')
            {
                this.frequencytype = 'Monthly';
                this.frequencycount = '1';
            }
            
            this.asset_frequencytype = this.frequencytype;
            this.asset_frequencycount = this.frequencycount;

            if(!this.isPricingEligible){
                this.pricingType = 'PTCO';
                const evt = new ShowToastEvent({
                    title: 'Warning',
                    message: Account_Eligibility,
                    variant: 'warning',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
            else
            {
                this.pricingType = 'PT';
            }


            var inputError = "Invalid mapping value for pricing:";            

            getNAICSCode({accountId: this.baselineResult.Account.ParentId})
                .then(result =>{
                    if(result)
                        this.naicsCode = result;
                    else{
                        inputError += " Industry Classification Code,";
                        this.mappingError = true;
                        this.isCaseError = true;
                        this.buttonInfoDisabled = true;
                    }
                });
            //Change for SDT-30110 Start
            if(this.baselineResult.Equipment_Type__c == 'Dumpster - Front Load' || this.baselineResult.Equipment_Type__c == 'Dumpster - Rear Load')
            {
                this.equipmentType = 'Dumpster';
            }
            else
            {
                this.equipmentType = this.baselineResult.Equipment_Type__c;
            }    
            console.log('equipmentType: ' + this.equipmentType);
            //Change for SDT-30110 End
            validatePicklist({ ObjectApiName: "Pricing_Request__c", FieldApiName : "Container_Type__c", fieldValue: this.equipmentType })
                .then(result => {
                    this.picklistvalue = result;
                    if(this.picklistvalue.isvalid){
                        this.containertype = this.picklistvalue.apivalue;

                        if(this.containertype){
                            validateDependentPicklist({ ObjectApiName: "Pricing_Request__c", FieldApiName : "Container_Size__c", ControllingfieldValue: this.equipmentType, DependentfieldValue: this.baselineResult.Equipment_Size__c })
                            .then(result => {
                                this.picklistvalue = result;
                                if(this.picklistvalue.isvalid){
                                    this.containersize = this.picklistvalue.apivalue;
                                    this.asset_containersize = this.picklistvalue.apivalue;
                                }
                                else{
                                    inputError += " Container Size: " + this.baselineResult.Equipment_Size__c + ",";
                                    this.containersize = No_Mapping;
                                    this.asset_containersize = No_Mapping;
                                    this.mappingError = true;
                                    this.isCaseError = true;
                                    this.buttonInfoDisabled = true;
                                }
                            });
                        }
                        else{
                            this.containersize = No_Mapping;

                        }
                    }
                    else{
                        inputError += " Container Type: " + this.baselineResult.Equipment_Type__c + ",";
                        this.containertype = No_Mapping;
                        this.containersize = No_Mapping;
                        this.mappingError = true;
                        this.isCaseError = true;
                        this.buttonInfoDisabled = true;
                    }
                });
            validatePicklist({ ObjectApiName: "Pricing_Request__c", FieldApiName : "Material_Code__c", fieldValue: this.baselineResult.Material_Type__c })
                .then(result => {
                    this.picklistvalue = result;
                    if(this.picklistvalue.isvalid)
                        this.materialtype = this.picklistvalue.apivalue;
                    else{
                        inputError += " Material Code: " + this.baselineResult.Material_Type__c + ",";
                        this.materialtype = No_Mapping;
                        this.mappingError = true;
                        this.isCaseError = true;
                        this.buttonInfoDisabled = true;
                    }
                });
            this.loadingSpinner = false;
        })
        .catch(error => {
            this.loadingSpinner = false;
            this.error = error;
            console.log('Inside ' +this.error)                 
        });
    }

    reloadPriceChangePage(baselineId)
    {
        this.loadingSpinner = true;
        getAssteDetails({ baselineId })
        .then(result => {
            console.log('Inside reloadPriceChangePage result ' + result);
            this.loadingSpinner = false;
            this.baselineResult = result;
        })
        .catch(error => {
            this.loadingSpinner = false;
            this.error = error;
            console.log('Inside ' +this.error)                 
        });
    }
    //End Price Change
}
