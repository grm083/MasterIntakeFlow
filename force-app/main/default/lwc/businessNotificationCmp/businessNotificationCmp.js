import { LightningElement, api, track, wire } from 'lwc';
import fetchSelectedBR from '@salesforce/apex/CaseRulesModalCtrl.getSelectedBrNotification';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';



export default class BusinessNotificationCmp extends NavigationMixin(LightningElement) {
    @track brWrapperList = [];
    @api recordId;
    @track isShowBRData = true;
    @track showSpinner = false;
    @api allRuleType = false;
    @api locationId
    @api businessId;
    @track isShowModal;

    

    @api
    reloadNotificationRules() {  
       // refreshApex(this.profileData)
        this.loadCaseBusinessRules();
      //  this.isShowModal = true;
    }

    connectedCallback(){
        if(!this.allRuleType){
            this.loadCaseBusinessRules();
        } 
        console.log('the business id is'+this.businessId);
    }

    @api
    showBusinessNotification(locationId,businessId) {  
        this.locationId = locationId;
        this.businessId = businessId;
        this.loadCaseBusinessRules();
        this.isShowModal = true;

    }


    loadCaseBusinessRules(){
        this.showSpinner = true;
        //this.fetchCaseBusinessRules();
        console.log('location id in child >' + this.locationId);
        fetchSelectedBR({
            locationId: this.locationId,
            businessId: this.businessId
 
        })
        .then(result => {
            if(result && result.length>0){
                console.log('the result is '+result);
                console.log('the jsonresult is '+JSON.stringify(result));

                this.brWrapperList = result;
                this.isShowBRData = true;
            }else{
                console.log('the else is');
                this.isShowBRData = false;
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

    hideModalBox() {  
        this.isShowModal = false;
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
       // alert(brId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: brId,
                actionName: 'view'
            }
        });
    }

}