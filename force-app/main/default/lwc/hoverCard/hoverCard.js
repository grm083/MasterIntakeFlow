import { LightningElement , api, wire, track} from 'lwc';

import fetchFields from '@salesforce/apex/HoverCardController.getFields';
import fetchTaskRecord from '@salesforce/apex/HoverCardController.getTaskRecord';
import fetchEmailMessageRecord from '@salesforce/apex/HoverCardController.getEmailMessageRecord';

export default class HoverCard extends LightningElement {
  //  @api recordId = '0WO6t000000AtEsGAK';
    @api parentId;
    @api objectAPIName;
    @api title; 
    @track fieldSet;
    @track taskData = {};
    @track emailData = {};
    @api fixedUI = false;

    connectedCallback(){
      if(this.objectAPIName == 'Task'){
        fetchTaskRecord({
          taskId : this.objectRecordId
        })
        .then((result) => {
          if (result) {
              this.taskData = result ;
          }
        })
        .catch((error) => {
          let message = error.message || error.body.message;
          console.log("Error:-- " + message);
        });
      }  
      else  if(this.objectAPIName == 'EmailMessage'){
        fetchEmailMessageRecord({
          emailMsgId : this.objectRecordId
        })
        .then((result) => {
          if (result) {
              this.emailData = result ;
          }
        })
        .catch((error) => {
          let message = error.message || error.body.message;
          console.log("Error:-- " + message);
        });
      }  
      else {
          fetchFields({
            objectApiName: this.objectAPIName,
            fieldSetName: 'HoverCard'
          })
          .then((result) => {
            if (result) {
                this.fieldSet = result.fieldData ;
                this.masterField = result.masterField;		
            }
          })
          .catch((error) => {
            let message = error.message || error.body.message;
            console.log("Error:-- " + message);
          });  
        }
    }

    @track objectRecordId;
    @track top = 50;
    @track left = 50;

    @api
    get hoverRecordId(){
        return this.objectRecordId;
    }

    set hoverRecordId(value) {
        this.objectRecordId = value;
    }

    @api
    get topmargin(){
        return this.top;
    }

    set topmargin(value) {
        this.top = value;
    }

    @api
    get leftmargin(){
        return this.left;
    }

    set leftmargin(value) {
        this.left = value;
    }

    get boxClass() { 
      if(this.fixedUI == true){
        return  'position: fixed; background-color:white; top:200px; left:'+ (this.left + 300) + 'px; width: 50%; max-height: 400px;';
       // return  'position: absolute; background-color:white; top:-945px; left:552px; width: 35pc;';
      } else {
        return  'position: absolute; background-color:white; top: 20px; right:'+ (this.left + 100) + 'px; width: 50%; max-height: 400px;';
      }
    }   

    get articleClass(){
      if( this.objectAPIName === 'EmailMessage') {
        return 'margin-top: 35px';
      } else {
        return '';
      }
    }   

    get isTask(){
      return this.objectAPIName === 'Task';
    }

    get isEmailMessage(){
      return this.objectAPIName === 'EmailMessage';
    }

    get objectFieldSet(){
      return (this.objectAPIName != 'Task' && this.objectAPIName != 'EmailMessage');
    }

    handleClose(){
      const closeEvent = new CustomEvent('close', {});
      this.dispatchEvent(closeEvent);
    }
}