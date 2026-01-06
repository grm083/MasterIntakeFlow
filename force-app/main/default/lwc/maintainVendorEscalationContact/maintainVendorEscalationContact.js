import { LightningElement, track, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFIELD from '@salesforce/schema/User.Name';
import fetchCategoryType from '@salesforce/apex/VendorEscalationContactController.fetchCategoryType';
import fetchCategories from '@salesforce/apex/VendorEscalationContactController.fetchCategories';
import fetchCategoryData from '@salesforce/apex/VendorEscalationContactController.fetchCategoryData';
import fetchParentAccount from '@salesforce/apex/VendorEscalationContactController.fetchParentAccount';   
import fetchVendorAccount from '@salesforce/apex/VendorEscalationContactController.fetchVendorAccount';
import fetchVendorContact from '@salesforce/apex/VendorEscalationContactController.fetchVendorContact';
import fetchRolesData from '@salesforce/apex/VendorEscalationContactController.fetchRolesData';
import saveCategoryData from '@salesforce/apex/VendorEscalationContactController.saveCategoryData';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CONTACT_OBJECT from "@salesforce/schema/Contact";
import FIRSTNAME_FIELD from "@salesforce/schema/Contact.FirstName";
import LASTNAME_FIELD from "@salesforce/schema/Contact.LastName";


const contactColumns = [
    { label: '', fieldName: 'Name' , cellAttributes: {class: {fieldName: 'contactFormat'}} }
];
const accountColumns = [
    { label: 'Parent Vendor', fieldName: 'accountName' , cellAttributes: {class: {fieldName: 'accountFormat'}} }
];

export default class MaintainVendorEscalationContact extends NavigationMixin(LightningElement) {
    categories;  
    error;  
    searchKey;
    selectedCategoryId;
    categoryType = '';
    parentAccName;
    optionsAcc = [];
    vendorValues = [];
    @track parentAccId;
    searchAccResults = [];
    contactData = [];
    contactColumns = contactColumns;
    accountColumns = accountColumns;
    optionsRoles = [];
    selectedRoles;
    @track selectedContact;
    contactRoleMap = {};
    isShowModal = false;
    contactObject = CONTACT_OBJECT;
    myFields = [FIRSTNAME_FIELD, LASTNAME_FIELD];
    validatedDate;
    validatedBy;
    @track categoryTypeOptions = [];
    @track showSpinner = false;
    @track typeSelected = false;
    @track showVendorAccounts = false;
    @track categoryWrapper;
    @track preSelectedRows = [];
    @track isNew = true;
    @track contactAccountId;
    @track parentAccountName;
    @track parentVendorId;
    @track maxVendor = 100;
    @track validatedById = Id;


    @wire(getRecord, { recordId: Id, fields: [UserNameFIELD ]}) 
    currentUserInfo({error, data}) {
        if (data) {
            this.validatedBy = data.fields.Name.value;
        } else if (error) {
            this.error = error ;
        }
    }

    connectedCallback() {
        this.fetchCategoryTypeData();
        this.fetchRoles('');
        this.validatedDate = new Date().toLocaleDateString();
    }

    //Fetch Category Type Picklist values
    fetchCategoryTypeData(){
        fetchCategoryType({})    
        .then( result => {             
            const options = [];
            if(result && result.length > 0 ){
                result.forEach(type =>{
                    var label = type.split(',')[0];
                    var value = type.split(',')[1];
                    options.push({
                        label: label,
                        value: value
                    }); 
                });
            }    
            this.categoryTypeOptions = options;
        } )  
        .catch( error => {            
            this.error = error;
        } )
        .finally(fn => {
            this.showSpinner = false;
        }) ;
    }

    //Fetch Existing Category Data
    fetchCategoryData(){
        this.showSpinner = true;
        if (this.selectedCategoryId) {  
            fetchCategoryData( { categoryId: this.selectedCategoryId} )    
            .then( result => {             
                console.log( 'result is fetchParentAcc : ', JSON.stringify( result ) );
                this.showSpinner = true;
                this.categoryWrapper = result;
                this.categoryType = this.categoryWrapper.categoryType;
                this.isNew = false;
                this.validatedBy = this.categoryWrapper.validatedBy;
                this.validatedById = this.categoryWrapper.validatedById;
                this.validatedDate = this.categoryWrapper.validatedDate;
                this.parentAccountName = this.categoryWrapper.parentAccountName;
                this.parentVendorId = this.categoryWrapper.parentVendorId;
                this.parentAccId = this.categoryWrapper.parentAccountId;
                this.contactAccountId = this.parentAccId;
                this.selectedRoles = [];
                this.fetchParentAcc('');   
                this.vendorValues = this.categoryWrapper.vendorAccounts && this.categoryWrapper.vendorAccounts.length > 0 ? this.categoryWrapper.vendorAccounts : [] ;
                if(this.parentAccId == undefined || this.parentAccId == null || this.parentAccId == '') {
                    this.contactAccountId = this.vendorValues[0];
                }
                this.showVendorAccounts = true;
                this.fetchVendorData(''); 
              //   this.defaultValues = this.vendorValues;
                this.typeSelected = true;
                this.showVendorAccounts = true;
                this.contactRoleMap = this.categoryWrapper.contactRoleMap;
                this.fetchVendorContact('');
                this.fetchRoles('');
            } )  
            .catch( error => {            
                console.log( 'Error Occured', JSON.stringify( error ) );
                this.error = error; 
            } )
            .finally(fn => {
                this.showSpinner = false;
            }) ;
        } else  {
            this.parentAccName = undefined;
        }
    }

    // Fetch Parent Vendor Account 
    fetchParentAcc(searchKey){
        //console.log('cate this.categoryType : ' + this.categoryType);
        this.showSpinner = true;
        if(this.isNew){
            if (this.categoryType) {  
                // console.log('category this.categoryType : ' + this.categoryType);
                 fetchParentAccount( { categoryType: this.categoryType, searchStr: searchKey} )    
                 .then( result => {             
                    var nonParentalList = [];
                    if(this.categoryType == 'Vendor'){
                         var noParentVander =
                         {
                             accountId: ' ',
                             accountName: 'Non Parental Vendor',
                             accountVendorId: null,
                             isParent: false
                         };
                         nonParentalList.push(noParentVander);
                     }
                     this.searchAccResults = [...nonParentalList , ...result];
                     console.log( 'result is pV fetchParentAcc : ', JSON.stringify( this.searchAccResults ) );
                 } )  
                 .catch( error => {            
                     console.log( 'Error Occured', JSON.stringify( error ) );
                     this.error = error; 
                 } )
                 .finally(fn => {
                     this.showSpinner = false;
                 }) ;
             } else  {
                 this.parentAccName = undefined;
             }
        }
        else {
            this.searchAccResults = [];
            var selectedAccount = {};
            if(this.parentAccId != undefined && this.parentAccId != null && this.parentAccId !=''){
                selectedAccount = {
                    accountId: this.parentAccId,
                    accountName: this.parentAccountName + ' ' + this.parentVendorId,
                    accountVendorId: null,
                    isParent: true
                };
                this.maxVendor = 100;
                this.preSelectedRows.push(this.parentAccId);  
            }    
            else {
                selectedAccount =
                {
                    accountId: ' ',
                    accountName: 'Non Parental Vendor',
                    accountVendorId: null,
                    isParent: false
                };
                this.maxVendor = 1;
                this.preSelectedRows.push(' ');
            }
            this.searchAccResults.push(selectedAccount);
        }
    }
    
    // Fetch Vendor Account based on the parent Account selected
    fetchVendorData(searchVendorAccStr){  
      //  this.showSpinner = true;
        this.parentAccId = this.parentAccId ? this.parentAccId.trim() : this.parentAccId;
        fetchVendorAccount( { parentVendorId: this.parentAccId, searchStr : searchVendorAccStr, isNew : this.isNew, existingVendors: this.vendorValues, categoryId : this.selectedCategoryId} )      
        .then( result => {             
            console.log( 'vendor result is fetchVendorData : ', JSON.stringify( result ) );
            const items = [];
            var dataFound = false;
            if(result && result.length > 0 ){
                result.forEach(acc =>{
                    console.log('vendor accountName : ' + acc.accountName);
                    if(!this.vendorValues.includes(acc.accountId)){
                        dataFound = true;
                    }
                    items.push({
                        label: acc.accountName,
                        value: acc.accountId
                    }); 
                });
            } 
             if(!dataFound){
                var searchCmp = this.template.querySelector("lightning-input[data-recid=vendoSearch]");
                if(searchCmp){
                    searchCmp.setCustomValidity("Not Found - VID might already be in a Category");
                    searchCmp.reportValidity();
                }  
            } 
            console.log('vendor result : ', items);
            this.optionsAcc = items;
        } )  
        .catch( error => {            
            console.log( 'Vendor Error Occured', JSON.stringify( error ) );
            this.error = error;
        } )
        .finally(fn => {
            this.showSpinner = false;
        }) ;
    }

    //Fetch Vendor Contacts
    fetchVendorContact(searchContactKey){
        this.showSpinner = true;
	var accountList = [];
        accountList.push(this.contactAccountId);
        accountList = [...accountList, ...this.vendorValues];  
        fetchVendorContact( { searchStr: searchContactKey, categoryId : this.selectedCategoryId, accountList : accountList} )    
        .then( result => {   
            var nonHighlightedContacts = [];
            this.contactData = [];
            result.forEach(ele => {
                    if(this.contactRoleMap[ele.Id] ){
                        ele.contactFormat = this.contactRoleMap[ele.Id]   ? 'slds-color__background_gray-7' : '';
                        this.contactData.push(ele);  
                    } else {
                        nonHighlightedContacts.push(ele);
                    }     
            });   
            this.contactData =  [...this.contactData, ...nonHighlightedContacts];           
            console.log('search items : ', JSON.stringify(this.contactData));
        } )  
        .catch( error => {            
            console.log( 'Error Occured', JSON.stringify( error ) );
            this.error = error; 
        } )
        .finally(fn => {
            this.showSpinner = false;
        }) ;
    }

    //Fetch Account Contact Relation Roles
    fetchRoles(searchRolesStr){
        this.showSpinner = true;
        fetchRolesData( { searchStr : searchRolesStr } )    
            .then( result => {             
                const items = [];
                if(result && result.length > 0 ){
                    result.forEach(role =>{
                        items.push({
                            label: role,
                            value: role
                        }); 
                    });
                }    
                this.optionsRoles = items;
            } )  
            .catch( error => {            
                console.log( 'Vendor Error Occured', JSON.stringify( error ) );
                this.error = error;
            } )
            .finally(fn => {
                this.showSpinner = false;
            }) ;
    }

    //Search Existing Category based on the input in the category name 
    handleCategoryNameChange( event ) {
        this.searchKey = event.detail.value;
        console.log( 'searchKey is', this.searchKey );
        if ( this.searchKey ) {  
            fetchCategories( { categoryStr: this.searchKey } )    
            .then( result => {             
                console.log( 'result is fetchCategories : ', JSON.stringify( result ) );
                let tempCategories = [];
                if(result && result.length > 0 ){
                    result.forEach( ( record ) => {
                        let tempRec = Object.assign( {}, record );      
                        tempRec.formattedName = tempRec.Name.replace( new RegExp( this.searchKey, 'i' ),( value ) => `<b>${value}</b>` );                    
                        tempCategories.push( tempRec );                 
                    });
                }
                this.categories = tempCategories;  
    
            } )  
            .catch( error => {            
                console.log( 'Error Occured', JSON.stringify( error ) );
                this.error = error;  
    
            } );  
    
        } else  {
            if(!this.isNew) {  
              this.clearData();
            }
            this.isNew = true;
            this.categories = undefined;  
        }

    }

    //Handle selection of  Existing Category and fetch data based on the that
    handleCategorySelect( event ) {   
        this.clearValidation();
        let strIndex = event.currentTarget.dataset.id;
        let tempRecs =  JSON.parse( JSON.stringify( this.categories ) );
        let selectedRecId = tempRecs[ strIndex ].Id;
        let strCatName = tempRecs[ strIndex ].Name;
        this.selectedCategoryId = selectedRecId;
        this.searchKey = strCatName;
        this.categories = undefined;
        this.fetchCategoryData();
    }

    closeSearch(){
        this.categories = undefined;
    }

    // handle change in Category Type
    handleChangeCategoryType(event) {
        this.showSpinner = true;
        this.categoryType = event.detail.value;
        this.typeSelected = true;
        this.showVendorAccounts = false; 
        this.optionsAcc = [];
        this.vendorValues = [];
        this.contactRoleMap = {};
        this.fetchParentAcc('');
        this.selectedContact = '';
        this.selectedRoles = [];
        console.log('options this.value : ' , this.categoryTypeOptions);
        console.log( 'options is options : ', JSON.stringify( this.categoryTypeOptions ) );
    }

    // Search parent Account from search bar
    searchParentAccount(event){
        var searchAccKey = (event && event.detail) ? event.detail.value : '';
        console.log( 'searchAccKey is', searchAccKey);
        this.fetchParentAcc(searchAccKey);
    }

    // Handle Selection of Vendor Account
    handleChangeVendor(event){
        this.vendorValues = event.detail.value;
        if(this.parentAccId != null && this.parentAccId != '' && this.parentAccId != ' ') {
            this.maxVendor = 100;
        } else {
            this.contactAccountId = (this.vendorValues && this.vendorValues.length > 0) ? this.vendorValues[0] : null;
            this.maxVendor = 1;
        }
        if(this.vendorValues && this.vendorValues.length > 0) {
            this.fetchVendorContact('');
        }
    }

    // Search Vendor account from search bar
    handleSearchVendorAcc(event){
        var searchCmp = this.template.querySelector("lightning-input[data-recid=vendoSearch]");
        if(searchCmp){
            searchCmp.setCustomValidity('');
            searchCmp.reportValidity();
        }       
        var searchVendor = event.detail.value;
        console.log( 'searchVendorStr is', searchVendor);
        if(searchVendor) {  
            this.fetchVendorData(searchVendor); 
        } else {
            this.fetchVendorData(''); 
        }
        
    }

    // Search Contact from search bar
    handleSearchContact(event){
        var searchContactKey = event && event.detail.value ? event.detail.value : '';
        console.log( 'searchContactKey is', searchContactKey);
        console.log('search category this.value : ' + searchContactKey);
        this.fetchVendorContact(searchContactKey);
    }

    
   /* searchParentAccount(event) {
        const input = (event.detail != null && event.detail.value != null) ? event.detail.value.toLowerCase() : '';
        this.fetchParentAcc(input);
    } */
    
    clearSearchResults() {
        this.searchAccResults = null;
    }

    handleContactSelect(event){
        this.selectedContact = (event.detail.selectedRows != null && event.detail.selectedRows.length > 0) ? event.detail.selectedRows[0].Id : '';
       if(this.selectedContact && this.selectedContact != null) {
            this.selectedRoles = this.contactRoleMap[this.selectedContact];
       }
        
    }

    handleParentAccountSelect(event){
        if(this.isNew){
            this.showSpinner = true;
            this.clearValidation();     
            const selectedValue = (event.detail.selectedRows != null && event.detail.selectedRows.length > 0) ? event.detail.selectedRows[0].accountId : '';
            this.parentAccId = selectedValue;
            this.contactAccountId = this.parentAccId;
	    this.vendorValues = [];    
            if(this.parentAccId != ''){
                this.showVendorAccounts = true;
                this.fetchVendorData(''); 
            }
            this.selectedContact = '';
            this.selectedRoles = [];
            if(this.parentAccId != null && this.parentAccId != '' && this.parentAccId != ' ') {
                this.maxVendor = 100;
            } else {
                this.contactAccountId = (this.vendorValues && this.vendorValues.length > 0) ? this.vendorValues[0] : null;
                this.maxVendor = 1;
            }
        }  
    }


    handleChangeRoles(event){
        console.log('value roles :: ', event.detail.value);
        this.selectedRoles = event.detail.value;
        if(this.selectedContact) {
            this.contactRoleMap[this.selectedContact] = this.selectedRoles;
        } else {
            this.showMessage('Error' , 'Please select Contact' , 'error' , 'dismissable');
            this.selectedRoles = [];
        }
        this.contactData.forEach(ele => {
            if(this.contactRoleMap[ele.Id] && this.contactRoleMap[ele.Id].length > 0){
                ele.contactFormat = this.contactRoleMap[ele.Id]   ? 'slds-color__background_gray-7' : '';
            } 
        });   
    }

    handleSearchRoles(event){
        console.log('value roles :: ', event.detail.value);
        var searchRolesStr = event.detail.value;
        this.fetchRoles(searchRolesStr);
    }

    handleShowModalBox(){
        this.isShowModal = true;
    }

    handleHideModalBox() {  
        this.isShowModal = false;
    }

    handleSubmitDetails(event){
        if(this.isFormValid()){
            this.parentAccId = this.parentAccId ? this.parentAccId.trim() : this.parentAccId;
            this.showSpinner = true;
            var objDetails =
            {
                categoryId: this.selectedCategoryId,
                categoryName: this.searchKey,
                categoryType: this.categoryType,
                vendorAccounts: this.vendorValues,
                contactRoleMap : this.contactRoleMap,
                parentAccountId: this.parentAccId
            };
            saveCategoryData({categoryData: JSON.stringify(objDetails)})
            .then(result => {
                console.log('Data:'+ JSON.stringify(result));
                this.hardClear();
                this.showMessage('success' , 'Category record saved successfully' , 'success' , 'dismissable');
                this.connectedCallback();
            }) .catch(error => {
                console.log(error);
                this.error = error;
            })
            .finally(fn => {
                this.showSpinner = false;
            }) ;
        }
        else {
            this.showMessage('Error' , 'Please fill the required fields' , 'error' , 'dismissable');
        }
        
    }

    navigateToNewContact() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new'
            }
        });
    }

    handleSelectAllVendors(){
        if(this.optionsAcc && this.optionsAcc.length > 0 && this.optionsAcc.length <= 100) {
            const allVendors = [];
            for(var i=0; i < this.optionsAcc.length; i++){
                allVendors.push(this.optionsAcc[i].value);
            }
        //    this.vendorValues = allVendors.substring(0, allVendors.length - 1);
            this.vendorValues = allVendors;
            this.showMessage('success' , 'All Vendors have been selected.' , 'success' , 'dismissable');
        }  else {
            this.showMessage('error' , 'You can select upto 100' , 'error' , 'dismissable');
        }  
        if(this.vendorValues && this.vendorValues.length > 0) {
            this.fetchVendorContact('');
        }
    }

    handleContactCreated(){
        this.fetchVendorContact('');
    }

    createContact(event){
        event.preventDefault();
        const fields = event.detail.fields;
        fields.AccountId = this.contactAccountId;
        this.template.querySelector('lightning-record-form').submit(fields);
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

    hideCategoryModel(){
        this.categories = undefined;
    }
    
    get disableSave(){
        return this.contactRoleMap != undefined && this.contactRoleMap != null && JSON.stringify(this.contactRoleMap).length > 4 
               && this.vendorValues && this.vendorValues.length > 0 ? false : true;
    }

    handleClear(){
        this.hardClear();
        this.connectedCallback();
    }
    
    clearData(){
        this.categoryType = '';
        this.parentAccId = '';
        this.preSelectedRows = [];
        this.showVendorAccounts = false; 
        this.optionsAcc = [];
        this.vendorValues = [] ;
        this.typeSelected = false;
        this.searchKey = undefined;
        this.contactRoleMap = {};
        this.searchAccResults = [];
        this.selectedCategoryId = '';
        this.clearValidation();
       
    }

    clearValidation(){
        var searchCmp = this.template.querySelector("lightning-input[data-recid=vendoSearch]");
        if(searchCmp){
            searchCmp.value = '';
            searchCmp.setCustomValidity('');
            searchCmp.reportValidity();
        }       
    }

    hardClear(){
        this.categories = undefined;  
        this.error = '';  
        this.searchKey = '';
        this.selectedCategoryId = '';
        this.categoryType = '';
        this.parentAccName = '';
        this.optionsAcc = [];
        this.vendorValues = [];
        this.parentAccId = '';
        this.searchAccResults = [];
        this.contactData = [];
        this.optionsRoles = [];
        this.selectedRoles = [];
        this.selectedContact = '';
        this.contactRoleMap = {};
        this.isShowModal = false;
        this.showSpinner = false;
        this.typeSelected = false;
        this.showVendorAccounts = false;
        this.categoryWrapper;
        this.preSelectedRows = [];
        this.isNew = true;
        this.contactAccountId;
        this.parentAccountName;
        this.parentVendorId = '';
        this.maxVendor = 100;
        this.clearValidation();     
    }
    
    viewRecord(event) {
        // Navigate to Account record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.value,
                "objectApiName": "User",
                "actionName": "view"
            },
        });
    }

    get disableInput(){
        return !this.isNew;
    }

    get showCategories(){
        return this.categories && this.categories.length > 0 ? true : false;
    }

    get showAccResults(){
        return this.searchAccResults && this.searchAccResults.length > 0 ? true : false;
    }
    
    get showContacts(){
        return this.vendorValues && this.vendorValues.length > 0 ? true : false;
    }

    get showSelectAll(){
        return (this.parentAccId != ' ' && this.parentAccId != '' && this.parentAccId != null &&  this.optionsAcc.length && this.optionsAcc.length > 0) ? true : false;
    }

    get vendorComboMessage(){
        return (this.parentAccId != ' ' && this.parentAccId != '' && this.parentAccId != null) ? "Select Vendor upto 100" : "Select only 1 vendor";
    }

}