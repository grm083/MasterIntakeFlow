import { LightningElement,track,api,wire } from 'lwc';
import fetchSimpleMap from '@salesforce/apex/SendAlert.getMap';
import getRecipientsMsg from '@salesforce/apex/SendAlert.getRecipientsMsg';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import TwowayCommCharslimit from '@salesforce/label/c.TwowayCommCharslimit';
import TwoWayAccessErrorMessage from '@salesforce/label/c.TwoWayAccessErrorMessage';
import Service_Channel from '@salesforce/label/c.Service_Channel';
import Office_Trax from '@salesforce/label/c.OfficeTrax';


export default class SendAlert extends NavigationMixin(LightningElement) {

@track Message = null;
@track length;
@track alertMap; 
@track showSpinner = true;
@track combooptions = [];
@track success;
@track selectedValues=[];
@track selectedTexts=[];
@track typedValues=[];
@track allValues=[];
@track allTextValues=[];
@track selectedValue;
@track selectedText;
@track typedValue;
@track msg;
@track selectRecipients;
@track showEmailContainer = true;
//@track disableEnableSend = true;
@track value;
@api caseOrigin;
@api recordId;


 connectedCallback() {  
    if(this.caseOrigin == Office_Trax) 
    {
      this.showEmailContainer = false;
    }
    fetchSimpleMap({caseId:this.recordId}).then((result) => {
      console.log('recipientlist'+result);
      this.showSpinner = false;
      var recipientObj=[];
      if(result.problem === undefined) {
        var jsonDataList = result.data;
        for (var i=0; i<jsonDataList.length; i++) {
          var username = jsonDataList[i].userName;
          
          if(this.caseOrigin == Service_Channel)
          {
            var emailValue = jsonDataList[i].email;
            if(username == null || username == '') {
              username = emailValue;
            }
            recipientObj.push({
              label: username,
              value: emailValue
            })
          }
          else if (this.caseOrigin == Office_Trax)
          {
            var refNumber = jsonDataList[i].referenceNumber;
            recipientObj.push({
              label: username,
              value: refNumber
            })
          }          
        }
        this.combooptions = recipientObj;
        //this.showToastMessage('Success!', "Successfully returned recipient list.", 'success');
      }
      else {
        var errorMessage = result.problem.errors[0].message;
        console.log("This is error message" + errorMessage);
        this.showToastMessage('error', errorMessage, 'error');
    }}).catch((error) => {
        this.showToastMessage('error',TwoWayAccessErrorMessage , 'error');
        this.showSpinner = false;
        console.log("Error occurred" + error.body.message);
    });        
  }
   
  @track optionsMaster=[];
   

  get MAX_CHARACTERS() {
      return parseInt(TwowayCommCharslimit);
  }

   getMessage(event){
   
        this.Message = event.target.value;
        
        const inputField = event.target;
     
        let input = inputField.value;
        if(input.length>this.MAX_CHARACTERS){
                input = input.substr(0,this.MAX_CHARACTERS)
        }
        inputField.value = input;
                    
        if (input.length == this.MAX_CHARACTERS) {
            inputField.setCustomValidity(`* Input Text cannot exceed ${this.MAX_CHARACTERS} characters.`);
						
						//inputField.style.background="#803ADD";
						
        } 
        else {
            inputField.setCustomValidity('');
        }

        inputField.reportValidity();
    }
    
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
   
   //handling select of a recipient from the picklist
   handleSelect(event) {
    this.selectedValue = event.target.value.toLowerCase();
    this.selectedText = event.target.options.find(opt => opt.value === event.detail.value).label;
    if(!this.allValues.includes(this.selectedValue)) {
      this.selectedValues.push(this.selectedValue);
      // this.selectedTexts.push(this.selectedText);
      this.allValues.push(this.selectedValue);
      this.allTextValues.push(this.selectedText);
      event.target.setCustomValidity("");
    }
    else {
      if(this.caseOrigin == Office_Trax)
      {
        event.target.setCustomValidity("This recipient is already selected.");
      }
      else if(this.caseOrigin == Service_Channel)
      {
        event.target.setCustomValidity("Email address already selected.");
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
     // this.modifyOptions();
   }
   else {
    event.target.setCustomValidity("Email address already selected.");
    event.target.reportValidity();
   }
  }

  handleRemoveForPicklist(event)
  {
    const valueRemoved=event.target.name;
    this.allValues.splice(this.allValues.indexOf(valueRemoved),1);
    this.selectedValues.splice(this.selectedValues.indexOf(valueRemoved),1);
    this.allTextValues.splice(this.allTextValues.indexOf(valueRemoved),1);
    const comboboxValue = this.template.querySelector("[data-id='combobox']");;
    comboboxValue.value = null;
  }

  handleRemoveForTextBox(event)
  {
    const valueRemoved=event.target.name;
    this.allValues.splice(this.allValues.indexOf(valueRemoved),1);
    this.typedValues.splice(this.typedValues.indexOf(valueRemoved),1);
    const comboboxValue = this.template.querySelector("[data-id='combobox']");;
    comboboxValue.value = null;
  }

  handleClick(event){
    event.preventDefault();       
    this.dispatchEvent(new CustomEvent('cancel'));
 }

  handleButtonClick(){
    this.showSpinner = true;

    console.log("clicked")
    if((this.Message === '' || this.Message === null) || this.allValues.length === 0) {
      this.showToastMessage( 'Error', 'Please select atleast one recipient and enter some message!' , 'error');
    }
    else {
    getRecipientsMsg({values:this.allValues, textValues:this.allTextValues, message:this.Message, caseId:this.recordId})
    .then(result =>{ 
      if(result.problem === undefined) {
        console.log("in success");
        this.showToastMessage('Success', 'Successfully created' , 'success');
        this.handleReset();
      }
      else {
        var errorMessage = result.problem.errors[0].message;
        console.log("This is the error message" + errorMessage);
        this.showToastMessage('error', errorMessage, 'error');
      }
         
        })
    .catch(error =>{
      this.showToastMessage('error',TwoWayAccessErrorMessage , 'error');
    });
    }

    

  }

  handleReset() {
    [...this.template
        .querySelectorAll('lightning-input, lightning-textarea, lightning-pill, lightning-combobox')]
        .forEach((input) => { input.value = '';});

    this.selectedValues = [];
    this.allValues = [];
    this.allTextValues = [];
    const comboboxValue = this.template.querySelector("[data-id='combobox']");
    comboboxValue.value = null;
  }
  showToastMessage(title,message,variant){
    const toastEvent= new ShowToastEvent({
      title  : title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(toastEvent);
    this.showSpinner = false;
  }
  
       
}