import { LightningElement,track,wire,api } from 'lwc';
import { getRecord,getFieldValue,updateRecord  } from 'lightning/uiRecordApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import getDescription from '@salesforce/apex/changeRecordTypeController.getRecordTypeNames';
import RECORD_TYPE from '@salesforce/schema/Case.RecordTypeId';
const FIELDS = [
    'Case.Id',RECORD_TYPE
];
export default class ChangeRTCard extends LightningElement {
    @track recordTypes = [];
    @api objectSchema = CASE_OBJECT;
    rtValues;
    @track showModal = true;
    @api caseid;
    @track selectedItem;
    @track itemDescription;
    recordTypeId;
    caseUpdate = false;
    @wire(getRecord, { recordId: '$caseid', fields: FIELDS })recdata({ error, data }){
        
        if(data){
            this.recordTypeId = getFieldValue(data, RECORD_TYPE);
            getDescription({ recordId: this.caseid})
            .then((result) => {
                this.rtValues = result;
                for(let i = 0; i < result.length; i++) {
                    if(result[i].Name !== 'Master' && result[i].Name !== 'Integration Case') {
                        if(this.recordTypeId && result[i].Id == this.recordTypeId){
                            this.selectedItem = result[i].Name;
                            this.itemDescription = result[i].Description;
                        }
                        this.recordTypes.push({
                                recid : result[i].Id,
                                name : result[i].Name,
                        });
                    }
                }
            })
            .catch((error) => {
                console.log('changeRecordType$$$$'+JSON.stringify(error));
            });
        }else if(error){
            console.log('getRecordType$$$$'+JSON.stringify(error));
        }
    };
    

    handleSelect(event){
        
        this.selectedItem = event.detail.name;
        let description = this.rtValues;
        if(description){
            for(let i = 0; i < description.length; i++) {
                if(description[i].Name == this.selectedItem){
                    this.itemDescription = description[i].Description;
                    this.recordTypeId = description[i].Id;
                }
            }
        }
    }
    handleButtonClick(){
        this.caseUpdate = true;
        let record = {
            fields: {
                Id: this.caseid,
                RecordTypeId : this.recordTypeId,
            },
        };
        updateRecord(record).then(() => {
            this.dispatchEvent(new CustomEvent('caseupdate'));
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error on data save',
                    message: error.message.body,
                    variant: 'error',
                }),
            );
        });
        
    }
    closeModel(){
        this.showModal = false;
        if(!this.caseUpdate)
        this.dispatchEvent(new CustomEvent('popupclose'));
    }
}