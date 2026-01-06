import { LightningElement, api, track , wire} from 'lwc';
import getComments from "@salesforce/apex/AcornController.getCommentData";
import getMetaData from "@salesforce/apex/AcornController.returnTwoWayCommMetadata";
import CASE_NUMBER_FIELD from "@salesforce/schema/Case.CaseNumber";
import PORTAL_MESSAGES_URL_FIELD from "@salesforce/schema/Case.Portal_Messages_URL__c";
import ORIGIN_FIELD from "@salesforce/schema/Case.Origin";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

const fields = [CASE_NUMBER_FIELD , PORTAL_MESSAGES_URL_FIELD, ORIGIN_FIELD];
export default class CustomCaseComment extends NavigationMixin(LightningElement) {
    @api recordId;
    @track selectedRecord = {};
    visibleComments = [];
    totalComments;
    metaDataLabels = [];
    @track left;
	@track top;
    @track showHoverCard = false;
    @track showSpinner = true;
    @track sortAsc = false;
    @track sortCol = 'Date';
    
    @wire(getRecord, { recordId: '$recordId', fields })
    case;

    get casenumber() {
        return getFieldValue(this.case.data, CASE_NUMBER_FIELD)
    }

    get portalLink(){
        return getFieldValue(this.case.data, PORTAL_MESSAGES_URL_FIELD);
    }

    get caseOrigin(){
        return getFieldValue(this.case.data, ORIGIN_FIELD);
    }

    connectedCallback(){
        this.fetchComments();
        this.fetchMetaData();
        
    }

    showData(event){
        this.left = event.srcElement.getBoundingClientRect().left + window.scrollX;
        this.top = event.srcElement.getBoundingClientRect().top + window.scrollY; 
        this.selectedRecord = this.visibleComments.filter(x=>x.sObjectId == event.currentTarget.dataset.id)[0];
        this.showHoverCard = false;
        setTimeout(() => {
            this.showHoverCard = true;
        }, 1000);
    }
    
    hideData(event){
        var recId = event.currentTarget.dataset.id;
        if(recId != null) {
            if(!recId.startsWith('02s')) {
                this.showHoverCard  = false;
            }    
        }
    }

    closeModal(){
        this.showHoverCard  = false;
    }

    handleComment() {
        this[NavigationMixin.Navigate]({
         type: 'standard__component',
         attributes: {
             componentName: 'c__customCaseCommentAura'
         },
         state: {
             c__caseId: this.recordId
         }
     });
    }

    handleClick(event) {
        var objectId = event.currentTarget.dataset.id;
        let objectType = event.currentTarget.dataset.objectType;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: objectId,
                objectApiName: objectType,
                actionName: 'view'
            }
        });
        
    }

    handlePortalMessage(){
        if(this.metaDataLabels.indexOf(this.caseOrigin) !== -1) {
            this[NavigationMixin.Navigate]({
                type: "standard__component",
                attributes: {
                    componentName: "c__TwoWayCommunication"
                },
                state: {
                    c__caseId: this.recordId,
                    c__caseOrigin: this.caseOrigin
                }
            });
        }
        else {  
            window.open(this.portalLink, '_blank');
        }
    }

    sortColumn(event){
        this.sortAsc = !this.sortAsc;
        if(event.target.name != this.sortCol){
            this.sortAsc = true;
        }
        this.sortCol = event.target.name;
        this.fetchComments();
    }

    fetchComments(){
        this.showSpinner = true;
        getComments({
            caseId : this.recordId,
            size: 1000,
            sortAsc: this.sortAsc,
            sortColumn : this.sortCol
        })
        .then(result => {
            this.totalComments = result;
            this.visibleComments = this.totalComments;
            this.showSpinner = false;
        })
        .catch(error => {
            console.error(error);
            this.showSpinner = false;
        });
    }

    fetchMetaData(){
        getMetaData({
        })
        .then(result => {
            this.metaDataLabels = result;
        })
        .catch(error => {
            console.error(error);
        });
    }


    get isDateSort(){
        return this.sortCol == 'Date';
    }

    get isUserTeamSort(){
        return this.sortCol == 'UserTeam';
    }

    get isEditedBySort(){
        return this.sortCol == 'EditedBy';
    }

    get isActionSort(){
        return this.sortCol == 'Action';
    }

    get isSourceSort(){
        return this.sortCol == 'Source';
    }
}