import { LightningElement,track,api,wire } from 'lwc';
import fetchSimpleMap from '@salesforce/apex/SendAlert.getMap';
import getRecipientsMsg from '@salesforce/apex/SendAlert.getRecipientsMsg';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import TwowayCommCharslimit from '@salesforce/label/c.TwowayCommCharslimit';
import TwoWayAccessErrorMessage from '@salesforce/label/c.TwoWayAccessErrorMessage';
export default class EmailMessageInput extends LightningElement {

@track Message = null;
@track length;
@track alertMap; 
@track showSpinner = true;
@track combooptions = [];
@track success;
@track selectedValues=[];
@track typedValues=[];
@track allValues=[];
@track selectedValue;
@track typedValue;
@track msg;
@track selectRecipients;
//@track disableEnableSend = true;
@track value;
@api recordId;

checkEnter(event) {
    const validEmailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    const email = event.target.value;
    if(event.keyCode != 13 ) {
      if(validEmailRegex.test(email)) {
        event.target.setCustomValidity("");
      }
      else {
        event.target.setCustomValidity("Enter a valid email.");
      }
    }
    else if(event.keyCode === 13) {
      event.preventDefault();
      if(validEmailRegex.test(email)) {
      event.target.setCustomValidity("");
      this.handleEnter(event);
      }
      else {
        event.target.setCustomValidity("Enter a valid email.");
      }
    }
    event.target.reportValidity();
  }

   //handling entry of a valid recipient from the textbox.
 handleEnter(event) {
    this.typedValue = event.target.value.toLowerCase();
    if(!this.allValues.includes(this.typedValue)) {
     this.typedValues.push(this.typedValue);
     this.allValues.push(this.typedValue);
     var values = this.typedValues;
     // this.modifyOptions();
     this.callEmailtoParentEvent();
   }
   else {
    event.target.setCustomValidity("Email address already selected.");
    event.target.reportValidity();
   }
  }

  handleRemoveForTextBox(event)
  {
    const valueRemoved=event.target.name;
    this.allValues.splice(this.allValues.indexOf(valueRemoved),1);
    this.typedValues.splice(this.typedValues.indexOf(valueRemoved),1);
    const comboboxValue = this.template.querySelector("[data-id='combobox']");;
    if(comboboxValue)
    {
      comboboxValue.value = null;
    }

    this.callEmailtoParentEvent();
  }

  //method for calling event
  callEmailtoParentEvent(){
    var values = this.typedValues;
    var allvalues = this.allValues
    this.dispatchEvent(new CustomEvent("emailtoparent", {
      detail:{typedValue:values,allvalue:allvalues}
    })) ;
  }
}