/*
BLOCK1: LOAD THE COMPONENT.
            1. load css style for multi-line errors show toast.
            2. set the visibility of button/action class variable as per the status.
            3. load the Service_Time_Span__c schema. 
            4. set the service type picklist values.
            5. load the product type picklist values.
            6. load the bunlde related informations.
            7. load the defaults for delivery service quote order.
BLOCK2: RETRIEVE ALL THE EXISTING QUOTE ORDERS ON THE BUNDLE.
            1. set all the existing quote orders with dynamic id's.
            2. overwrite the bundle start and end date on service line start and end date. Also set the service date on Delivery type start date on both the tables(createform & readonly table).
            3. validate all the quote orders service date against the service date validation rules, and highlights the invalids service dates on Quote orders.
BLOCK3: UPDATE THE FIELDS AND RESOLVE ITS DEPENDENCY OVER OTHER SUPPORTING FIELDS(HIDDEN/VISIBLE).
            1. if bundle start date gets changes, repeat BLOCK2 step 3 task.
            2. if bundle end date gets changes, repeat BLOCK2 step 3 task.
            3. if field values on createform get changes, repeat BLOCK2 step 3 task. Check if there is any warning/note needs to be displayed.
BLOCK4: SHOW WARNINGS/NOTIFICATIONS REGARDING CURRENT SERVICE TYPE AND PRODUCT TYPE SELECTIONS.
            1. if any business rule is already there, asks for required information like PO number. Show notification as per the possible combinations.
            2. if delivery order is there, show notification that instructions are mandatory.
BLOCK5: ACTIONS TO PERFORM WHEN CLICK ON BUTTONS.
            1. clicking on ADD button, wil move the createform row to table2 only if the mandatory fields are filled. Also scroller will automatically move to bottom.
            2. clicking on EDIT button, will move the createform row to table2 only if the mandatory fields are filled and then the edited line will move to createform row. Also scroller will automatically move to top.
            3. clicking on DELETE button:
                3.1. if delete button of createform row is clicked
                    3.1.1. if the quote order is new, then remove the field values of whole row.
                    3.1.2. if the quote order is existing, then delete the quote order from database permanently.
                3.2 if delete button of table is clicked, delete the quote order from database permanently.
            4. clicking on UNDO button, will refresh the whole page and reload all the data from database.
BLOCK6: VALIDATIONS RELATED TO SERVICE DATE OF QUOTE ORDERS.
            1. Pickup order should be equal or greater than start date and less than or equal to end date.
            2. Removal order should be greater than or equal to start date and less than or equal to end date.
            3. Delivery order should be equal to start date.
BLOCK7: ACTIONS TO PERFORM WHEN SAVE BUTTON GETS CLICKED.
            1. check if the createform row's mandatory fields are filled.
                1.1. check if QO service date validations are passed.
            2. check if table2 rows have all the correct service dates.
            3. check if the service time is blank, default is to ASAP.
            4. check if there is any non mandatory field is blank, populate null to it.
            5. check if the logged in user is CSR, disable delete button of Delivery QO.
            6. push the createform row to table2.
            7. if all the mandatory fields are filled and QOs have valid service dates, send the data to Database.
            8. if records are successfully created/updated, show success message.
            9. if records are partially successful, show the error messages with total success counts.
            10. post commit, refresh all the class variables, load the bundle data and all the quote orders related to the bundle.
BLOCK8: ACTIONS TO PERFORM WHEN CLOSE/CANCEL BUTTON GETS CLICKED.
            1. closeModal will be called, and it will dispose all the class variables assignment.
*/
import { LightningElement, api, wire, track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import QUOTE_ORDER_OBJECT from '@salesforce/schema/Quote_Order__c';
import SERVICETIME_FIELD from '@salesforce/schema/Quote_Order__c.Service_Time_Span__c';
import getQuoteLineParentProducts from '@salesforce/apex/WorkOrderController.getQuoteLineParentProductsNew';
import quoteLineFeatureProductOptionsNew from '@salesforce/apex/WorkOrderController.quoteLineFeatureProductOptionsNew';
import actionsOnQuoteLineOrders from '@salesforce/apex/WorkOrderController.actionsOnQuoteLineOrders';
import deleteQuoteLineOrders from '@salesforce/apex/WorkOrderController.deleteQuoteLineOrders';
import getQuoteOrdersByQuoteLine from '@salesforce/apex/WorkOrderController.getQuoteOrdersByQuoteLine';
import deliveryOrderError from '@salesforce/label/c.Delivery_Order_Error';
import pickupOrderError from '@salesforce/label/c.Pickup_Order_Error';
import removalOrderError from '@salesforce/label/c.Removal_Order_Error';
import dryrunOrderError from '@salesforce/label/c.Dry_Run_Order_Error';//SDT-42075
import sitesurveyOrderError from '@salesforce/label/c.Site_Survey_Order_Error';//SDT-42075
import productorderOrderError from '@salesforce/label/c.Product_Order_Order_Error';//SDT-42075
import removalOrderError2 from '@salesforce/label/c.Removal_Order_Error2';
import removalOrderWarning from '@salesforce/label/c.Removal_Order_Warning';
import { loadStyle } from 'lightning/platformResourceLoader';
import CSS_FILE from '@salesforce/resourceUrl/multilineToastCSS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import determineSLADate from '@salesforce/apex/QuoteProcurementController.callDetermineSLA';//SDT-29723
import hasAssetAvailabilityAccess from "@salesforce/customPermission/AAV_Asset_Availability_User"; //SDT-29723
import getUpdatedAvailability from "@salesforce/apex/AAV_APIIntegration.getUpdatedAvailability"; //SDT-31585
import getAvailabilityRecord from "@salesforce/apex/AAV_APIIntegration.getAvailabilityRecord"; //SDT-31585
import checkStartDateValidity from '@salesforce/apex/WorkOrderController.checkStartDateValidity'; //SDT-33378


const NEW_SERVICE_CASE_TYPE = 'New Service'; //SDT-29723
const NO_AAV_MSG = 'Availability could not be updated as there was no response from server.'; //SDT 31585
let serviceTypes = ["Container Exchange", "Contaminated Pickup", "Dig Out Service", "Power Wash", "Onsite Relocation", "Equipment Installation"];
export default class quoteOrderComp extends LightningElement {
    userId = USER_ID;
    @api inlineProd;
    @api bShowModal;
    @api isView;
    @api quoteRecordId;
    @api recordId;
    @api servicePicklist;
    //SDT-29723 : assetAvailabilityAccess flag
    get assetAvailabilityAccess(){
        return hasAssetAvailabilityAccess && this.caseRecordType === NEW_SERVICE_CASE_TYPE 
            && !this.isView;
    }
    //SDT-29723 :Asset availability
    slaDate;
    caseRecordType;//SDT-29723
    equipmentSize; //SDT-29723
    @track isEdited=false;
    @track loading=false;
    @track isDo= true;
    @track selectedProductOptions;
    @track selectedProd;
    @track bundleStartDateForm;//SDT-23801, Bundle start date
    @track bundleEndDateForm;//SDT-23801, Bundle end date
    @track vendorCommitDate; //SDT-32136
    @track customerServiceDate; //SDT-32136
    @track productOptions;
    @track serviceTypeOptions;
    @track serviceTimeOptions;
    @track componentList =[];
    @track isShowTable=false;
    @track disableFields=true;
    @track quoteOrderToCreateList=[];
    @track serialno;
    @track idField;
    @track actionType;
    @track quoteLineParentId;
    @track serviceType;
    @track disableDelete;
    @track productType;
    @track serviceTime;
    @track quoteLineId;
    @track serviceDateForm;
    @track contactForm; //SDT-20938, dedicated field for contact info.
    @track phoneForm; //SDT-20938, dedicated field for phone info.
    @track instructionForm;
    @track custRefNumberForm;
    @track occurenceType;
    @track duration;
    @track serviceStartDate;
    @track serviceEndDate;
    @track isDisabled=true;
    @track showNote=false;
    @track note;
    @track bypassworkorderForm= false; //PavanK-Added for SDT-26355 // Changes for SDT-29198
@track lastAvailabilityCallDate; //SDT-31585
    @track availabilityMessage; //SDT 31585

    qoServiceDateValidationMap = new Map(); //SDT-23801, QO id with error flag true/false
    qoServiceDateValidationMessageMap = new Map(); //SDT-23801, QO id with error message
    isCSR=false; //SDT-23246, if logged in user is csr
    isDelete=false;
    isEdit=false;
    isValidationPassed=true;
    showNote=false;
    isDelivery=false; // SDT-20939, true if Delivery QO is eligible for the bundle.
    defaultServiceTime= 'ASAP';
    serviceDate; //static value, SDT-20939 getting start date from delivery service quote line only for delivery QO.
    locPosition; //static value, SDT-20937 getting location position from the parent bundle quote line.
    quoteOrderToSendList=[];
    undefinedValue;
    selQuoteProd; //made uniform always except in closeModel
    defaultQuoteOrderStructure;//includes quotelineid,prodfeatureotions
    prodQuotelineIdMap; //QL Id && comp name map
    prodQuotelineIdMap2; //comp name && QL id map
    servicePOMandatoryMap; //service && customerRef scenario
    serviceTypeProdQuoteLineIdMap;// servicetype and quotelineid map
    quoteOrderMap =new Map(); //QO Id and QO map
    iteratorObj;
    serviceTypePicklistValues;
    indexvar;
    newQuote='newQuote';
    changeQuote='changed';
    deleteQuote='deleted';
    noChange='noChange';
    startDateCheckValidity = true; // SDT-33378
    startDateCheckValidityMessage = ''; //SDT-33378

    /*BLOCK1: STARTS--------------------------*/
    /*----------------------------------------INVOKE POPUP RELATED METHODS STARTS HERE---------------------------------------*/
    @api
    openModal() {    
        //console.log('>>>Open Modal');
        this.bShowModal = true; 
    }
    /*----------------------------------------INVOKE POPUP RELATED METHODS ENDS HERE---------------------------------------*/

    /*-------------------------------------COMPONENT ONLOAD RELATED METHODS STARTS HERE------------------------------------*/

    connectedCallback(){
        //console.log('inline>>');
        loadStyle(this, CSS_FILE)
        .then(() => {});
        this.isEdited=false;
        if(this.isView){
            this.isDisabled= this.isView;
            this.disableFields= this.isView;
            this.isDo= this.isView;
}

        //added as part of SDT 31585
        if(hasAssetAvailabilityAccess && this.inlineProd) {
            getAvailabilityRecord({ quoteLineId: this.inlineProd })
                .then((result) => {
                    if(result && result.AAV_isAPIResult__c) {
                        this.lastAvailabilityCallDate = result.createdDt;
                        this.availabilityMessage = 'Availability updated on : ' + this.lastAvailabilityCallDate;
                    }
                    else {
                        this.availabilityMessage = NO_AAV_MSG;
                    }
            })
            .catch((error) => {
                this.availabilityMessage = NO_AAV_MSG;
                // this.responseFailure(error);
                // this.apiCallout = true;
            });
        }
    }

    //added as part of SDT 31585
    updateAvailability() {
        this.loading=true;
        if(this.assetAvailabilityAccess && this.inlineProd){
            getUpdatedAvailability({quoteLineId : this.inlineProd, vendorCommitDate : this.vendorCommitDate})
            .then(result=>{
                if(result && result.AAV_isAPIResult__c) {
                    this.lastAvailabilityCallDate = result.createdDt;
                    this.availabilityMessage = 'Availability updated on : ' + this.lastAvailabilityCallDate;
                    const childSetters = this.template.querySelectorAll('c-aav-custom-date-picker');
                    childSetters.forEach(childRespData => {
                        childRespData.setResponseData(result);
                    });
                    const childMethods = this.template.querySelectorAll('c-aav-custom-date-picker');
                    childMethods.forEach(childMethod => {
                        childMethod.getAvailabilityResponse(false);
                    });
                    this.loading=false;
                }
                else {
                    this.availabilityMessage = NO_AAV_MSG;
                    this.loading=false;
                }
            })
            .catch(error=>{
                this.availabilityMessage = NO_AAV_MSG;
                this.loading=false;
            });  
        }
    }

    @wire(getObjectInfo, {objectApiName: QUOTE_ORDER_OBJECT})
    objectInfo;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SERVICETIME_FIELD})
    picklistValues1({error, data}) {
        if (data) {
            let picklistOptions = [];
            data.values.forEach(key => {
                //console.log('key.label>>'+key.label);
                //console.log('key.value>>'+key.value);
                picklistOptions.push({
                    label: key.label, 
                    value: key.value
                })
            });
            //console.log('this.serviceTimePicklist>>>'+JSON.stringify(picklistOptions));
            this.serviceTimeOptions = picklistOptions;
            
        } else if (error) {
            this.error = JSON.stringify(error);
        }
    }
    /*----------------------------------------COMPONENT ONLOAD RELATED METHODS ENDS HERE---------------------------------*/

    /*----------------------------------ALL PUBLIC METHODS, CALLED FROM OTHER COMPONENTS STARTS HERE(AFTER LOAD)-----------------------------*/
    
    //SDT-20939, getting service quote lines of the selected product bundle.
    @api
    getChildProducts(){
        this.selQuoteProd = this.inlineProd; 
        this.createServicePicklist(this.selQuoteProd);
        this.isDisabled= false;
        this.disableFields= false;
        this.isDo= false;
        if(this.isView){
            this.isDisabled= true;
            this.disableFields= true;
            this.isDo= true;
        }
    }

    /*----------------------------------ALL PUBLIC METHODS, CALLED FROM OTHER COMPONENTS ENDS HERE(AFTER LOAD)-----------------------------*/

    /*---------------------------------LOAD SERVICE PICKLISTS AND PRODUCT PICKLISTS RELATED METHODS STARTS HERE-----------------------------*/

    //SDT-20939, getting eligible services for the QO creation.
    createServicePicklist(selectedQuoteProd){
        this.loading = true;
        var pickVals= this.servicePicklist;
        var picklistVal= String(pickVals).split(',');
        if (picklistVal) {
            let picklistOptions = [];

            for(var p in picklistVal){
                picklistOptions.push({
                    label: picklistVal[p], 
                    value: picklistVal[p]
                });
            }
            //console.log('this.serviceTypePicklist>>>'+JSON.stringify(picklistOptions));
            this.serviceTypePicklist = picklistOptions;
            var pickListValues=[];
        if(typeof this.serviceTypePicklist !== 'undefined' && this.serviceTypePicklist.length>0){
            for(var dt in this.serviceTypePicklist){
                pickListValues.push(this.serviceTypePicklist[dt].value);
            }
            this.quoteOrderToSendList=[];
            this.quoteOrderToCreateList=[];
        }
        this.serviceTypePicklistValues= pickListValues;
        //console.log('this.serviceTypePicklistValues>>'+this.serviceTypePicklistValues);
        //console.log('this.recordId>>>'+this.recordId);
        this.getquoteLineFeatureProductOptionsJs(selectedQuoteProd, this.serviceTypePicklistValues);
        //this.getQuoteOrdersByQuoteLineJs(selectedQuoteProd);     
        } else if (error) {
            this.error = JSON.stringify(error);
        }
    }

    //SDT-20939, getting product/Components for the selected services.
    getquoteLineFeatureProductOptionsJs(selQuoteProd,serviceTypeOptions){
        var serviceTypeOptionsString= JSON.stringify(serviceTypeOptions);
        //console.log('serviceTypeOptionsString>>>'+serviceTypeOptionsString);
        //console.log('selQuoteProd>>>'+selQuoteProd);
        let recId=''; //SDT-21795
        if(this.quoteRecordId){
            recId= this.quoteRecordId;
        } else if(this.recordId){
            recId= this.recordId;
        }
        //console.log('recId>>>'+recId);
        quoteLineFeatureProductOptionsNew({"quoteId" : recId, "selQuoteProd" : selQuoteProd, "serviceTypeList" : serviceTypeOptionsString}) //quoteLineProd Wrapper
        .then(data =>{
            //console.log('data1>>'+data); 
            data = JSON.parse(data);
            //console.log('data4>>'+data);
            let picklistOptions = [];
            if(data){
                this.prodQuotelineIdMap = new Map(); //quoteLineId and compname map
                this.prodQuotelineIdMap2 = new Map(); //compname and quoteLineId map
                this.servicePOMandatoryMap = new Map(); //service && customerRef flag map
                let serviceTypeList = [];
                data.forEach(key =>{
                    serviceTypeList.push(key.serviceType);
                });
                var serviceTypeSet = new Set(serviceTypeList);
                //console.log('serviceTypeSet>>>'+serviceTypeSet);
                serviceTypeSet.forEach(key =>{
                    picklistOptions.push({
                        label: key, 
                        value: key
                    });
                })
                data.forEach(key => {

                    //console.log('key.serviceType>>>'+key.serviceType); //valid service types comes from metadata filter
                    //console.log('key>>>'+JSON.stringify(key.quoteLineProdOptionsMap));
                    //console.log('key.poFlag>>'+key.poFlag);
                    // SDT-20408: selectedServiceProd is a unique key combination of Service and Product to identify the PO mandatory scenario on micro level
                    var selectedServiceProd= key.serviceType + key.quoteLineProductName;
                    this.servicePOMandatoryMap.set(selectedServiceProd,key.poFlag);
                    for(var k in key.quoteLineProdOptionsMap){
                        //console.log('quoteLineId>>>'+k+'>>>>quoteLineProductName>>>'+key.quoteLineProdOptionsMap[k]);
                        this.prodQuotelineIdMap.set(k,key.quoteLineProdOptionsMap[k]);
                        this.prodQuotelineIdMap2.set(key.quoteLineProdOptionsMap[k],k);
                    }
                    //console.log('key>>>'+key.serviceType+'>>>'+key.occurenceType+'>>>'+key.duration);
                });
                //console.log('picklistOptions 291>>>>'+JSON.stringify(picklistOptions));
                this.serviceTypeOptions = picklistOptions;
                //console.log('picklistOptions 293>>>>'+JSON.stringify(picklistOptions));
                this.defaultQuoteOrderStructure= data;
                //console.log('this.isDelivery>>>'+this.isDelivery);
                this.getParentProduct(selQuoteProd);
            }
        })
    }

    /*---------------------------------LOAD SERVICE PICKLISTS AND PRODUCT PICKLISTS RELATED METHODS ENDS HERE-----------------------------*/

    /*---------------------------------LOAD PARENT BUNDLE RELATED INFORMATIONS RELATED METHODS STARTS HERE--------------------------------*/

    //SDT-20939, get the default possible values from the selected Parent/bundle quote lines. 
    getParentProduct(inlineId){
        getQuoteLineParentProducts({"quoteLineId": inlineId, "userId" : this.userId}) 
        .then(data =>{
            data= JSON.parse(data);
            this.selectedProd = data.selectedProd;
            this.equipmentSize = data.equipmentSize; //SDT-29723 :Asset Availability
            this.caseRecordType = data.caseRecordType; //SDT-29723 :Asset Availability
            //console.log('this.selectedProd>>>'+this.selectedProd);
            this.isDelivery = data.isDelivery;
            this.isCSR = data.isCSR; //SDT-23246, check if loggedin User is CSR.
            this.serviceTime= 'ASAP';
            this.serviceDate= data.startDate;
            this.vendorCommitDate = data.VendorCommitDate; //SDT-32136
            this.customerServiceDate = data.CustomerRequestDate; //SDT-32136
            if(data.bundleStartDate){ //SDT-23801, bundle start date
                this.bundleStartDateForm= data.bundleStartDate;
                if(!this.assetAvailabilityAccess) // SDT-29723:condition added to skip next for asset availabiility
                    setTimeout(() => this.template.querySelector('[data-id="bundleStartDateBlock"]').value = data.bundleStartDate,500);
            }
            if(data.bundleEndDate){ //SDT-23801, bundle end date
                this.bundleEndDateForm= data.bundleEndDate;
                setTimeout(() => this.template.querySelector('[data-id="bundleEndDateBlock"]').value = data.bundleEndDate,500);
            }
            if(typeof data.locPos != 'undefined' && data.locPos !=='' && data.locPos !==null){
                this.locPosition= 'POSITION: '+data.locPos+'; INSTRUCTIONS: ';
                this.instructionForm= 'POSITION: '+data.locPos+'; INSTRUCTIONS: ';
            }
            //console.log('prod name>>'+data);
            //console.log('prod name>>'+data.selectedProd);
            //console.log('this.isDelivery>>>'+this.isDelivery);
            this.determineSLAForAssetAvailability();//SDT-29723
            if(this.isDelivery){
                this.loadDefaultsForDeliveryService();
            } 
            //Get all the existing QO's of the selected bundle from the apex controller.
            this.getQuoteOrdersByQuoteLineJs(inlineId,this.isCSR);  //SDT-23801, reusing the logged in user flag and passing to QO.
            window.setTimeout(()=>this.loading=false,3000);        
        })  
        .catch(error =>{
            console.log(error);
            this.error = error;
        })
    }

    /*---------------------------------LOAD PARENT BUNDLE RELATED INFORMATIONS RELATED METHODS ENDS HERE--------------------------------*/

    /*---------------------------------LOAD SERVICE TYPE-PRODUCT TYPE COMBINATIONS RELATED METHODS STARTS HERE--------------------------------*/

    //Get the Dependent picklist values - servcies & component fields
    getBaseReady(selectedServiceType){
        if(this.defaultQuoteOrderStructure){
            this.serviceTypeProdQuoteLineIdMap= new Map();
            this.defaultQuoteOrderStructure.forEach(key => {
                //console.log('key>>quoteLineProdOptionsMap>'+key.quoteLineProdOptionsMap);
                if(key.serviceType.localeCompare(selectedServiceType) == 0){
                    for(var k in key.quoteLineProdOptionsMap){                        
                        if(this.serviceTypeProdQuoteLineIdMap.has(key.serviceType)){
                            var quoteLineIdList = this.serviceTypeProdQuoteLineIdMap.get(key.serviceType);
                            quoteLineIdList.push(k);
                            this.serviceTypeProdQuoteLineIdMap.set(key.serviceType,quoteLineIdList);//serviceType & quotelineIdList map
                        } else{
                            var quoteLineIdList=[];
                            quoteLineIdList.push(k);
                            this.serviceTypeProdQuoteLineIdMap.set(key.serviceType,quoteLineIdList);
                        }
                    } 
                }
            });
        }
    }

    /*---------------------------------LOAD SERVICE TYPE-PRODUCT TYPE COMBINATIONS RELATED METHODS ENDS HERE--------------------------------*/

    /*---------------------------LOAD DEFAULTS WHEN DELIVERY QUOTE ORDER IS YET TO CREATE OR ALREADY CREATED RELATED METHOD STARTS HERE-----------------------------------------*/

    //SDT-20939, get the default values of the QO fields for Delivery QO.
    loadDefaultsForDeliveryService(){
        //console.log('Inside del>>');
        this.serviceType= 'Delivery';
        this.serviceTypeUpdateInGeneral(this.serviceType);
        this.productType= 'Delivery';
        this.componentNameUpdateInGeneral(this.productType);
        //console.log('Exiting del>>');
        this.serviceDateForm= this.serviceDate;
    }

    //SDT-23246, disable delete button for delivery qo, if CSR has logged in.
    get disableDeleteForm(){
        let isHide = false;
        if(this.serviceType === 'Delivery' && this.isCSR && !this.idField.includes('newlycreatedquoteid')){
            isHide = true;
        }
        return isHide;
    }

    /*---------------------------LOAD DEFAULTS WHEN DELIVERY QUOTE ORDER IS YET TO CREATE OR ALREADY CREATED RELATED METHOD ENDS HERE-----------------------------------------*/
    /*BLOCK1: ENDS--------------------------*/
    
    /*BLOCK2: STARTS--------------------------*/
    /*--------------------------------RETRIEVE ALL THE EXISTING QUOTE ORDERS FROM THE SYSTEM RELATED METHODS STARTS HERE-----------------------------------------------------------------*/
    //Get all the existing QO's of the selected bundle from the apex controller.
    getQuoteOrdersByQuoteLineJs(selQuoteProd,isCSR){ //SDT-23801, reusing the logged in user flag and passing to QO.
        //console.log('selQuoteProd>>>'+selQuoteProd);
        getQuoteOrdersByQuoteLine({"selectedQuoteLine": selQuoteProd,"isCSR": isCSR}) //fetches quote orders-wrapper
        .then(data =>{
            //console.log('data2>>'+data); //quote orders-wrapper
            data = JSON.parse(data);
            //console.log('data3>>'+data);
            if(data){
                var quoteOrderObj = [];
                for(var i=0; i<data.length; i++){
                    //console.log(data[i]);
                    quoteOrderObj.push(data[i]);
                    this.quoteOrderMap.set(data[i].idField,data[i]); //QO Id & QO Map
                }  
                this.isShowTable = true;
                this.quoteOrderToCreateList = quoteOrderObj; 
                if(typeof this.quoteOrderToCreateList != 'undefined' && this.quoteOrderToCreateList.length>0){
                    this.indexvar=0;
                    window.setTimeout(this.getRowId.bind(this), 500);
                }
            } else {
                this.isShowTable = false;
            }
            this.isValidationPassed= true;
        })  
        .catch(error =>{
            console.log(error);
            this.error = error;
        })
    }

    /*--------------------------------RETRIEVE ALL THE EXISTING QUOTE ORDERS FROM THE SYSTEM RELATED METHODS ENDS HERE-----------------------------------------------------------------*/

    /*----------------------------CREATING DYNAMIC ID TO EACH FIELD(ENABLED\DISABLED\READ ONLY) RELATED METHODS STARTS HERE----------------------------------------------*/
    //Generate Dynamic rowId(s) to the saved/unsaved QO(s).
    getRowId(){
        var element= null;
        for(var i=this.indexvar; i <this.quoteOrderToCreateList.length; i++){
            //console.log('readd>i>>>'+i);
            this.createDomSkeleton(element, i);
        }
        window.setTimeout(this.overwriteStartEndDatesOnQO.bind(this),500);
    }
    createDomSkeleton(element, i){
        element = this.template.querySelector('[data-id="snBlock1"]');
        if(element != null){
            element.dataset.id = 'snBlock1'+i;
        }
        element = this.template.querySelector('[data-id="idBlock1"]');
        //console.log('element>>'+element);
        if(element != null){
            //console.log('element.dataset.id>>'+element.dataset.id);
            element.dataset.id = 'idBlock1'+i;
        }
        element = this.template.querySelector('[data-id="actionTypeBlock1"]');
        if(element != null){
            element.dataset.id = 'actionTypeBlock1'+i;
        }
        element = this.template.querySelector('[data-id="parentProductQuoteLineBlock1"]');
        if(element != null){
            element.dataset.id = 'parentProductQuoteLineBlock1'+i;
        }
        element = this.template.querySelector('[data-id="quoteLineBlock1"]');
        if(element != null){
            element.dataset.id = 'quoteLineBlock1'+i;
        }
        element = this.template.querySelector('[data-id="occurenceTypeBlock1"]');
        if(element != null){
            element.dataset.id = 'occurenceTypeBlock1'+i;
        }
        element = this.template.querySelector('[data-id="durationBlock1"]');
        if(element != null){
            element.dataset.id = 'durationBlock1'+i;
        }
        element = this.template.querySelector('[data-id="serviceTypeBlock1"]');
        if(element != null){
            element.dataset.id = 'serviceTypeBlock1'+i;
        }
        element = this.template.querySelector('[data-id="disableDeleteBlock1"]');
        if(element != null){
            element.dataset.id = 'disableDeleteBlock1'+i;
        }
        element = this.template.querySelector('[data-id="productTypeBlock1"]');
        if(element != null){
            element.dataset.id = 'productTypeBlock1'+i;
        }
        element = this.template.querySelector('[data-id="serviceDateBlock1"]');
        if(element != null){
            element.dataset.id = 'serviceDateBlock1'+i;
        }
        element = this.template.querySelector('[data-id="startDateBlock1"]');
        if(element != null){
            element.dataset.id = 'startDateBlock1'+i;
        }
        element = this.template.querySelector('[data-id="endDateBlock1"]');
        if(element != null){
            element.dataset.id = 'endDateBlock1'+i;
        }
        element = this.template.querySelector('[data-id="serviceTimeBlock1"]');
        if(element != null){
            element.dataset.id = 'serviceTimeBlock1'+i;
        }
        element = this.template.querySelector('[data-id="contactBlock1"]');
        if(element != null){
            element.dataset.id = 'contactBlock1'+i;
        }
        element = this.template.querySelector('[data-id="phoneBlock1"]');
        if(element != null){
            element.dataset.id = 'phoneBlock1'+i;
        }
        element = this.template.querySelector('[data-id="instructionBlock1"]');
        if(element != null){
            element.dataset.id = 'instructionBlock1'+i;
        }
        element = this.template.querySelector('[data-id="custRefNumberBlock1"]');
        if(element != null){
            element.dataset.id = 'custRefNumberBlock1'+i;
        }
        //PavanK-Added for SDT-26355
        element = this.template.querySelector('[data-id="bypassworkorderBlock1"]');
        if(element != null){
            element.dataset.id = 'bypassworkorderBlock1'+i;
        }
    }
    /*----------------------------CREATING DYNAMIC ID TO EACH FIELD(ENABLED\DISABLED\READ ONLY) RELATED METHODS ENDS HERE----------------------------------------------*/
    
    /*----------------OVERWRITING START/END DATES ON SERVICE DATE AND IT'S SUPPORTING FIELDS(HIDDEN) OF QO RELATED METHODS STARTS HERE------------------------------------------*/
    //SDT-23801, overwriting the delivery/removal service date as per the current start date and end date respectively.
    overwriteStartEndDatesOnQO(){
        if(typeof this.quoteOrderToCreateList != 'undefined' && this.quoteOrderToCreateList.length>0){
            if(typeof this.serviceDateForm !=='undefined' && this.serviceDateForm !=='' && this.serviceDateForm !== null && typeof this.serviceType !=='undefined' && this.serviceType !=='' && this.serviceType !== null && typeof this.productType !=='undefined' && this.productType !=='' && this.productType !== null){
                let serviceDateStr = 'serviceDateBlock';
                this.serviceDateValidations(this.idField,this.serviceType,this.productType,this.serviceDateForm, this.serviceStartDate, this.serviceEndDate, serviceDateStr);
            }
            //console.log('this.bundleStartDateForm>>>'+this.bundleStartDateForm);
            for(let k=0;k<this.quoteOrderToCreateList.length;k++){
                let serviceDateStr = 'serviceDateBlock1'+k;
                let serviceStartDateStr = 'startDateBlock1'+k;
                let serviceEndDateStr = 'endDateBlock1'+k;
                if(this.quoteOrderToCreateList[k].serviceType === 'Delivery'){
                    this.quoteOrderToCreateList[k].serviceDate= this.bundleStartDateForm;
                    this.quoteOrderToCreateList[k].serviceLineStartDate = this.bundleStartDateForm;
                    this.quoteOrderToCreateList[k].serviceLineEndDate = this.bundleStartDateForm;
                    this.template.querySelector('[data-id='+serviceDateStr+']').value = this.bundleStartDateForm;
                    this.template.querySelector('[data-id='+serviceStartDateStr+']').value = this.bundleStartDateForm;
                    this.template.querySelector('[data-id='+serviceEndDateStr+']').value = this.bundleStartDateForm;
                }else if(typeof this.bundleEndDateForm !== 'undefined' && this.bundleEndDateForm !=='' && this.bundleEndDateForm !== null){
                    if(this.quoteOrderToCreateList[k].serviceType === 'Removal'){
                        this.quoteOrderToCreateList[k].serviceDate= this.bundleEndDateForm;
                        this.template.querySelector('[data-id='+serviceDateStr+']').value = this.bundleEndDateForm;
                    }
                    this.quoteOrderToCreateList[k].serviceLineStartDate = this.bundleStartDateForm;
                    this.quoteOrderToCreateList[k].serviceLineEndDate = this.bundleEndDateForm;
                    this.template.querySelector('[data-id='+serviceStartDateStr+']').value = this.bundleStartDateForm;
                    this.template.querySelector('[data-id='+serviceEndDateStr+']').value = this.bundleEndDateForm;
                }
                this.serviceDateValidations(this.quoteOrderToCreateList[k].idField,this.quoteOrderToCreateList[k].serviceType,this.quoteOrderToCreateList[k].productType,this.quoteOrderToCreateList[k].serviceDate, this.quoteOrderToCreateList[k].serviceLineStartDate, this.quoteOrderToCreateList[k].serviceLineEndDate, serviceDateStr);
            }
        }
    }
    /*------------------OVERWRITING START/END DATES ON SERVICE DATE AND IT'S SUPPORTING FIELDS(HIDDEN) OF QO RELATED METHODS ENDS HERE------------------------------------------*/
    /*BLOCK2: ENDS----------------------------*/

    /*BLOCK3: STARTS--------------------------*/
    /*------------------------------FILL CREATE FORM (ONCHANGE) RELATED METHODS STARTS HERE------------------------------------------------*/
    //SDT-23801, handler: if bundle start date gets change.
    bundleStartDateUpdate(event){
        let bundleStart= event.detail.value;
        //SDT-29723 : method moved out for re-usability purpose
        this.updateStartDate(bundleStart);
    }
    //SDT-29723 : method moved out for re-usability purpose
    updateStartDate(bundleStart){
        if(typeof bundleStart === 'undefined' || bundleStart === null || bundleStart === ''){
            this.showToastMessage('The start date cannot be blank.','error','dismissable');
            bundleStart = this.bundleStartDateForm;
            if(!this.assetAvailabilityAccess) // SDT-29723:condition added to skip next for asset availabiility
                setTimeout(() => this.template.querySelector('[data-id="bundleStartDateBlock"]').value = this.bundleStartDateForm, 500);
            this.bundleStartDateUpdateInGeneral(bundleStart);  
        }else if(typeof this.bundleEndDateForm !== 'undefined' && this.bundleEndDateForm !== null && this.bundleEndDateForm !== '' && this.bundleEndDateForm < bundleStart){
            this.showToastMessage('The end date cannot occur before the start date.','error','dismissable');
            bundleStart = this.bundleStartDateForm;
            if(!this.assetAvailabilityAccess) // SDT-29723:condition added to skip next for asset availabiility
                setTimeout(() => this.template.querySelector('[data-id="bundleStartDateBlock"]').value = this.bundleStartDateForm, 500);
        }else{
            this.bundleStartDateForm = bundleStart;
            this.bundleStartDateUpdateInGeneral(bundleStart);  
        }
    }
    //SDT-23801, to reuse the start date change behavior
    bundleStartDateUpdateInGeneral(bundleStart){
        if(bundleStart && bundleStart !==''){
            this.serviceStartDate = bundleStart;
            if(this.serviceType === 'Delivery'){
                this.serviceDateForm = bundleStart;
                this.serviceEndDate = bundleStart;
            }
            this.defaultQuoteOrderStructure.forEach(key => {
                key.serviceLineStartDate = bundleStart;
                if(key.serviceType === 'Delivery'){
                    key.serviceLineEndDate = bundleStart;
                }
            })
            if(typeof this.serviceDateForm !=='undefined' && this.serviceDateForm !=='' && this.serviceDateForm !== null && typeof this.serviceType !=='undefined' && this.serviceType !=='' && this.serviceType !== null && typeof this.productType !=='undefined' && this.productType !=='' && this.productType !== null){
                var serviceDateStr = 'serviceDateBlock';
                this.serviceDateValidations(this.idField,this.serviceType,this.productType,this.serviceDateForm, this.serviceStartDate, this.serviceEndDate, serviceDateStr);
            }
            if(typeof this.quoteOrderToCreateList !=='undefined' && this.quoteOrderToCreateList.length>0){
                for(var i=0; i <this.quoteOrderToCreateList.length; i++){
                    this.quoteOrderToCreateList[i].serviceLineStartDate = bundleStart;
                    if(this.quoteOrderToCreateList[i].serviceType === 'Delivery'){
                        this.quoteOrderToCreateList[i].serviceDate = bundleStart;
                        this.quoteOrderToCreateList[i].serviceLineEndDate = bundleStart;
                        this.quoteOrderToCreateList[i].actionType= this.changeQuote;
                    }
                    var serviceDateStr = 'serviceDateBlock1' + i;
                    this.serviceDateValidations(this.quoteOrderToCreateList[i].idField,this.quoteOrderToCreateList[i].serviceType, this.quoteOrderToCreateList[i].productType, this.quoteOrderToCreateList[i].serviceDate, this.quoteOrderToCreateList[i].serviceLineStartDate, this.quoteOrderToCreateList[i].serviceLineEndDate, serviceDateStr);
                }
            }
        }
    }
    //SDT-23801, handler: if bundle end date gets change.
    bundleEndDateUpdate(event){
        let bundleEnd= event.detail.value;
        //Changes related to SDT-38985
        if(typeof this.bundleStartDateForm !== 'undefined' && this.bundleStartDateForm !== null && this.bundleStartDateForm !== '' && (this.bundleStartDateForm > bundleEnd || this.vendorCommitDate >bundleEnd)){
            this.showToastMessage('The end date cannot occur before the start date/Vendor Commit Date.','error','dismissable');
            bundleEnd = this.bundleEndDateForm;
            setTimeout(() => this.template.querySelector('[data-id="bundleEndDateBlock"]').value = this.bundleEndDateForm, 500);
        }else{
            this.bundleEndDateForm = bundleEnd;
            this.bundleEndDateUpdateInGeneral(bundleEnd);
        }
    }
    //SDT-23801, to reuse the end date change behavior
    bundleEndDateUpdateInGeneral(bundleEnd){
        //if(bundleEnd && bundleEnd !==''){
            if(typeof bundleEnd !== 'undefined' && bundleEnd !==null && bundleEnd !==''){
                if(this.serviceType === 'Removal'){
                    this.serviceDateForm = bundleEnd;
                }
            }
            if(this.serviceType !== 'Delivery'){
                this.serviceEndDate = bundleEnd;
            }
            this.defaultQuoteOrderStructure.forEach(key => {
                if(key.serviceType !== 'Delivery'){
                    key.serviceLineEndDate = bundleEnd;
                }
            })
            if(typeof this.serviceDateForm !=='undefined' && this.serviceDateForm !=='' && this.serviceDateForm !== null && typeof this.serviceType !=='undefined' && this.serviceType !=='' && this.serviceType !== null && typeof this.productType !=='undefined' && this.productType !=='' && this.productType !== null){
                var serviceDateStr = 'serviceDateBlock';
                this.serviceDateValidations(this.idField,this.serviceType,this.productType,this.serviceDateForm, this.serviceStartDate, this.serviceEndDate, serviceDateStr);
            }
            if(typeof this.quoteOrderToCreateList !=='undefined' && this.quoteOrderToCreateList.length>0){
                for(var i=0; i <this.quoteOrderToCreateList.length; i++){
                    if(this.quoteOrderToCreateList[i].serviceType !== 'Delivery'){
                        if(typeof bundleEnd !== 'undefined' && bundleEnd !==null && bundleEnd !==''){
                            if(this.quoteOrderToCreateList[i].serviceType === 'Removal'){
                                this.quoteOrderToCreateList[i].serviceDate = bundleEnd;
                                this.quoteOrderToCreateList[i].actionType= this.changeQuote;
                            }
                        }
                        this.quoteOrderToCreateList[i].serviceLineEndDate = bundleEnd;
                        let serviceDateStr = 'serviceDateBlock1' + i;
                        this.serviceDateValidations(this.quoteOrderToCreateList[i].idField,this.quoteOrderToCreateList[i].serviceType,this.quoteOrderToCreateList[i].productType, this.quoteOrderToCreateList[i].serviceDate, this.quoteOrderToCreateList[i].serviceLineStartDate, this.quoteOrderToCreateList[i].serviceLineEndDate,serviceDateStr);
                    }
                }
            }
        //}
    }

     //TODO - SDT-32136, handler: if Vendor commit date gets change.
     vendorCommitDateUpdate(event){
          let oldVendorCommitDate = this.vendorCommitDate ;
    let vendorCommit= event.detail.value;
    /*  if(typeof this.bundleStartDateForm !== 'undefined' && this.bundleStartDateForm !== null && this.bundleStartDateForm !== '' && this.bundleStartDateForm > bundleEnd){
        this.showToastMessage('The end date cannot occur before the start date.','error','dismissable');
        bundleEnd = this.bundleEndDateForm;
        setTimeout(() => this.template.querySelector('[data-id="bundleEndDateBlock"]').value = this.bundleEndDateForm, 500);
    }else{ */

    // START SDT-33378
    var showMessage = false;
    var errorMessage = '';
   checkStartDateValidity({quoteId : this.recordId, vendorCommitDate : vendorCommit}).then(response =>{ 

    errorMessage = response['ErrorMessage'];
    let isValid = response['isValid'];
    if(isValid==false){
        showMessage = true;
        this.startDateCheckValidity = false;
        this.startDateCheckValidityMessage = errorMessage;
         
        }else{
            this.startDateCheckValidity = true;
            this.startDateCheckValidityMessage = '';
            this.vendorCommitDate = vendorCommit;
        }
        //this.bundleEndDateUpdateInGeneral(bundleEnd);

    });

    const myTimeout = setTimeout(() => {
        if(showMessage){
            this.vendorCommitDate = oldVendorCommitDate;
        this.showToastMessage(errorMessage,'error','dismissable');
        }
    }, 1000);

    // START SDT-33378
            
        
    }

    //added as part of SDT 31585
    handleVendorCommitDateUpdate(event) {
        if(event.detail.date) {
            let vendorCommit= event.detail.date;
            this.vendorCommitDate = vendorCommit;
        }
    }



    //handle onchange event for service type field.
    serviceTypeUpdate(event){
        var selectedServiceType= event.detail.value;
        this.serviceTypeUpdateInGeneral(selectedServiceType);
    }
    //reuse of service fields behaviors in other onchange events.
    serviceTypeUpdateInGeneral(selectedServiceType){
        this.isEdited=true;
        //console.log('selectedServiceType>>>'+selectedServiceType);
        this.serviceType= selectedServiceType;
        if(this.serviceType === 'Delivery' && this.isCSR){
            this.disableDelete = true;
        }else{
            this.disableDelete = false;
        }
        this.productType= '';
        this.note = '';
        this.showNote= false;
        if(typeof this.idField ==='undefined'){
            this.actionType = this.newQuote;
            //console.log('serviceTypeUpdate>>>this.actionType>>>'+this.actionType);
            var d = new Date();
            var n = d.getTime();
            this.idField= (n+'newlycreatedquoteid').toString();
            //console.log('serviceTypeUpdate>>>this.idField>>>'+this.idField);

        }
        if(this.actionType == this.noChange){
            this.actionType= this.changeQuote;
            //console.log('serviceTypeUpdate>>>this.actionType>>>'+this.actionType);    
        }
        this.quoteLineParentId= this.selQuoteProd;
        //use defaultQuoteOrderStructure with serviceType to get prodFeatureOptions
        //use this onchange event to populate the prodOptions
        this.getBaseReady(this.serviceType);
        this.updateComponentList(this.serviceType);
    }
    
    //update the dependent component list from the selected service type.
    updateComponentList(selectedServiceType){
        //console.log('selectedServiceType>>>'+selectedServiceType);
        if(this.serviceTypeProdQuoteLineIdMap.has(selectedServiceType)) {
            ////console.log('getInside>>>'+this.serviceTypeProdQuoteLineIdMap.get(selectedServiceType));
            var compList = this.serviceTypeProdQuoteLineIdMap.get(selectedServiceType);
            var pickList= [];
            if(compList){
                for(var v=0; v<compList.length; v++){
                    var compName= this.prodQuotelineIdMap.get(compList[v]);
                    ////console.log('compName>>>'+compName);
                    ////console.log('quoteLineId>>>>'+compList[v]);
                    pickList.push({label:compName,value:compName});
                }
            }
            this.componentList= pickList;
        }
    }

    //handle onchange event of component field.
    componentNameUpdate(event){
        this.productType= event.detail.value;
        this.componentNameUpdateInGeneral(this.productType);
    }

    //resue the component onchange behavior in orher onchange behaviors.
    componentNameUpdateInGeneral(prodType){
        this.isEdited=true;
        //console.log('this.productType>>'+prodType);
        this.quoteLineId= this.prodQuotelineIdMap2.get(prodType);
        // SDT-20110: this.servicePOMandatoryMap is used get if PO mandatory -customer ref warning required?
        //SDT-20121 & SDT-20299: check if service type delivery, check instructions warning required?
        this.isShowNotes();
        this.defaultQuoteOrderStructure.forEach(key => {
            //console.log('key>>>'+key.quoteLineProdOptionsMap);
            //console.log('this.quoteLineId>>>'+this.quoteLineId+'>>>key.quoteLineId>>'+key.quoteLineId);
            if(key.quoteLineId == this.quoteLineId){
                //console.log('key>matched>>'+key.serviceType+'>>>'+key.occurenceType+'>>>'+key.duration);
                this.occurenceType= key.occurenceType;
                this.duration= key.duration;
                this.serviceStartDate= key.serviceLineStartDate;
                this.serviceEndDate= key.serviceLineEndDate;
                if(this.serviceType === 'Delivery'){
                    if(typeof this.bundleStartDateForm!== 'undefined' && this.bundleStartDateForm!=='' && this.bundleStartDateForm!== null){
                        this.serviceStartDate= this.bundleStartDateForm;
                        this.serviceEndDate= this.bundleStartDateForm;
                    }
                }else{
                    if(typeof this.bundleStartDateForm!== 'undefined' && this.bundleStartDateForm!=='' && this.bundleStartDateForm!== null){
                        this.serviceStartDate= this.bundleStartDateForm;
                    }
                    if(typeof this.bundleEndDateForm !== 'undefined' && this.bundleEndDateForm !=='' && this.bundleEndDateForm !== null){
                        this.serviceEndDate= this.bundleEndDateForm;
                    }
                }
            }
        });
        this.serviceDateValidations(this.idField,this.serviceType, prodType, this.serviceDateForm, this.serviceStartDate, this.serviceEndDate, 'serviceDateBlock');
        if(this.actionType == this.noChange){
            this.actionType= this.changeQuote;
        }

        if(prodType=='Delivery' && this.isDelivery){
            this.serviceDateForm= this.serviceDate;
            this.serviceDateUpdateInGeneral();
        }
    }

    //handle the onchange event of service date field.
    serviceDateUpdate(event){
        this.serviceDateForm= event.detail.value;
         this.serviceDateUpdateInGeneral();
    }

    //reuse the service date onchange behavior in other onchange events.
    serviceDateUpdateInGeneral(){
        this.isEdited=true;
        this.defaultQuoteOrderStructure.forEach(key => {
            //console.log('key>>>'+key.quoteLineProdOptionsMap);
            //console.log('this.quoteLineId>>>'+this.quoteLineId+'>>>key.quoteLineId>>'+key.quoteLineId);
            if(key.quoteLineId == this.quoteLineId){
                //console.log('key>matched>>'+key.serviceType+'>>>'+key.occurenceType+'>>>'+key.duration);
                this.occurenceType= key.occurenceType;
                this.duration= key.duration;
                this.serviceStartDate= key.serviceLineStartDate;
                this.serviceEndDate= key.serviceLineEndDate;
                if(this.serviceType === 'Delivery'){
                    if(typeof this.bundleStartDateForm!== 'undefined' && this.bundleStartDateForm!=='' && this.bundleStartDateForm!== null){
                        this.serviceStartDate= this.bundleStartDateForm;
                        this.serviceEndDate= this.bundleStartDateForm;
                    }
                }else{
                    if(typeof this.bundleStartDateForm!== 'undefined' && this.bundleStartDateForm!=='' && this.bundleStartDateForm!== null){
                        this.serviceStartDate= this.bundleStartDateForm;
                    }
                    if(typeof this.bundleEndDateForm !== 'undefined' && this.bundleEndDateForm !=='' && this.bundleEndDateForm !== null){
                        this.serviceEndDate= this.bundleEndDateForm;
                    }
                }
            }
        });
        this.serviceDateValidations(this.idField, this.serviceType, this.productType, this.serviceDateForm, this.serviceStartDate, this.serviceEndDate, 'serviceDateBlock');
        if(this.actionType == this.noChange){
            this.actionType= this.changeQuote;
        }
    }

    //handle onchange event of service window field.
    serviceTimeUpdate(event){
        this.isEdited=true;
        this.serviceTime= event.detail.value;
        if(this.actionType == this.noChange){
            this.actionType= this.changeQuote;
        }
    }

    //SDT-20938, handle onchange event of contact field.
    contactUpdate(event){
        this.isEdited=true;
        this.contactForm= event.detail.value;
        if(this.actionType == this.noChange){
            this.actionType= this.changeQuote;
        }
    }

    //SDT-20938, handle onchange event of phone field.
    phoneUpdate(event){
        this.isEdited=true;
        this.phoneForm= event.detail.value;
        //below phone validation is not exposed yet. for future sprints.
        var str= this.phoneForm;
        const regex = /^(1?\(([1-9]\d{2})\)\ ?|1?\-?([0-9]\d{2})(\-?|\.?\ ?))([0-9]\d{2})[-. ]?(\d{4})$/gm;
        let m;
        let isPhoneValid= false;
        //console.log('this.phoneForm>>'+this.phoneForm);
        while ((m = regex.exec(str)) !== null) {
            //console.log('this.phoneForm>>inside>'+str);
            // This is necessary to avoid infinite loops with zero-width matches
            if (m.index === regex.lastIndex) {
                regex.lastIndex++;
            }
            //console.log('check>>>'+JSON.stringify(m));
            // The result can be accessed through the `m`-variable.
            m.forEach((match, groupIndex) => {
                isPhoneValid= true;
                //console.log(`Found match, group ${groupIndex}: ${match}`);
            });
        }
        //console.log('out>>');
        if(this.actionType == this.noChange){
            this.actionType= this.changeQuote;
        }
    }

    //handle onchange event of instruction field.
    instructionUpdate(event){
        this.isEdited=true;
        this.instructionForm= event.detail.value;
        if(this.actionType == this.noChange){
            this.actionType= this.changeQuote;
        }
    }

    //handle onchange event of customer ref field.
    customerRefUpdate(event){
        this.isEdited=true;
        this.custRefNumberForm= event.detail.value;
        if(this.actionType == this.noChange){
            this.actionType= this.changeQuote;
        }
    }

    //PavanK-Added for SDT-26355
    bypassworkorderUpdate(event) {
        this.isEdited=true;
        this.bypassworkorderForm = event.target.checked;
        if(this.actionType == this.noChange){
            this.actionType= this.changeQuote;
        }
    }

    //SDT-20408 
    checkBlankFields(){
        if(typeof this.serviceLineEndDate === 'undefined' || this.serviceLineEndDate === '' || this.serviceLineEndDate === null){
            this.serviceLineEndDate = null;
        }
        if(typeof this.serviceLineStartDate === 'undefined' || this.serviceLineStartDate === '' || this.serviceLineStartDate === null){
            this.serviceLineStartDate = null;
        }
        if(typeof this.instructionForm === 'undefined' || this.instructionForm === '' || this.instructionForm === null){
            this.instructionForm = null;
        }
        if(typeof this.custRefNumberForm === 'undefined' || this.custRefNumberForm === '' || this.custRefNumberForm === null){
            this.custRefNumberForm = null;
        } 
    }
    /*----------------------------------------FILL CREATE FORM (ONCHANGE) RELATED METHODS ENDS HERE------------------------------------------------*/
    /*BLOCK3: ENDS----------------------------*/

    /*BLOCK4: STARTS--------------------------*/
    /*------------------------------------NOTIFICATIONS/WARNINGS/ERRORS/NOTES RELATED METHODS STARTS HERE--------------------------------------*/
    showToastMessage(msg,errorType,errorMode){
        const event = new ShowToastEvent({
            message: msg,
            variant: errorType,
            mode: errorMode        
        });
        this.dispatchEvent(event);
    }

    //SDT-20110,20121,20299 created isShowNotes() to make warning enable or disable as per the scenarios.
    isShowNotes(){
        if(this.servicePOMandatoryMap.has(this.serviceType+this.productType) && this.servicePOMandatoryMap.get(this.serviceType+this.productType)){
            if(this.serviceType==='Delivery'){
                this.note = 'CUSTOMER REF#, INSTRUCTIONS fields are mandatory to fill for \''+ this.serviceType +'\' Service and \''+this.productType+'\' Component.';
            } else{
                this.note = 'CUSTOMER REF# field is mandatory to fill for \''+ this.serviceType +'\' Service and \''+this.productType+'\' Component.'; 
            }
            this.showNote = this.servicePOMandatoryMap.get(this.serviceType+this.productType);
        } else if(this.servicePOMandatoryMap.has(this.serviceType+this.productType)){
            if(this.serviceType==='Delivery'){
                this.note = 'INSTRUCTIONS field is mandatory to fill for \''+ this.serviceType +'\' Service and \''+this.productType+'\' Component.'; 
                this.showNote= true;
            } else{
                this.note ='';
                this.showNote= false
            }    
        }
        //console.log('this.showNote>>this.servicePOMandatoryMap.has(this.serviceType+this.productType)>'+this.servicePOMandatoryMap.has(this.serviceType+this.productType));
        //console.log('this.showNote>>this.servicePOMandatoryMap.get(this.serviceType+this.productType)>'+this.servicePOMandatoryMap.get(this.serviceType+this.productType));
    }
    /*------------------------------------NOTIFICATIONS/WARNINGS/ERRORS/NOTES RELATED METHODS ENDS HERE--------------------------------------*/
    /*BLOCK4: ENDS----------------------------*/

    /*BLOCK5: STARTS--------------------------*/
    /*----------------------------ACTIONS-ADD: CLICKING ON ADD ROW BUTTON RELATED METHODS STARTS HERE-----------------------------------------------------------*/
    addRow(){
        if(typeof this.selQuoteProd !== 'undefined'){
            this.loading= true;
            /*console.log('typeof this.idField>>>'+typeof this.idField+'>>>>'+this.idField);
            console.log('typeof this.actionType>>>'+typeof this.actionType+'>>>>'+this.actionType);
            console.log('typeof this.quoteLineParentId>>>'+typeof this.quoteLineParentId+'>>>>'+this.quoteLineParentId);
            console.log('typeof this.serviceType>>>'+typeof this.serviceType+'>>>>'+this.serviceType);
            console.log('typeof this.productType>>>'+typeof this.productType+'>>>>'+this.productType);
            console.log('typeof this.occurenceType>>>'+typeof this.occurenceType+'>>>>'+this.occurenceType);
            console.log('typeof this.duration>>>'+typeof this.duration+'>>>>'+this.duration);
            console.log('typeof this.quoteLineId>>>'+typeof this.quoteLineId+'>>>>'+this.quoteLineId);
            console.log('typeof this.serviceDateForm>>>'+typeof this.serviceDateForm+'>>>>'+this.serviceDateForm);
            console.log('typeof this.instructionForm>>>>'+typeof this.instructionForm+'>>>>'+this.instructionForm);
            console.log('typeof this.custRefNumberForm>>>>'+typeof this.custRefNumberForm+'>>>>'+this.custRefNumberForm);*/

            // SDT-20110: this.servicePOMandatoryMap is used get if PO mandatory -customer ref required?
            //SDT-20121 & SDT-20299: check if service type delivery, check instructions required?
            if(this.isValidationPassed && typeof this.serviceType !== 'undefined' && typeof this.productType !== 'undefined' && typeof this.quoteLineId !== 'undefined' && typeof this.serviceDateForm !== 'undefined' && this.serviceDateForm !=='' && this.serviceDateForm !==null && (this.servicePOMandatoryMap.has(this.serviceType+this.productType) && ((this.servicePOMandatoryMap.get(this.serviceType+this.productType) && typeof this.custRefNumberForm !== 'undefined' && this.custRefNumberForm !=='' && this.custRefNumberForm !==null) || !this.servicePOMandatoryMap.get(this.serviceType+this.productType))) && (this.serviceType !=='Delivery' || ( typeof this.instructionForm !== 'undefined' && this.instructionForm !=='' && this.instructionForm !==null && this.serviceType === 'Delivery' ))){
                    this.addQuoteOrderToTable2();
                    //console.log('this.serviceStartDate>>>'+this.serviceStartDate);
                    this.isShowTable=true;
                    //this.isDisabled=false;
                    this.showNote= false;
                    this.note= this.undefinedValue;
                    this.makeCreateFormEmpty();  
                    window.setTimeout(()=>this.loading=false,1000); 
                    window.setTimeout(this.scrollToBottom.bind(this),1000); 
            }else{
                window.setTimeout(()=>this.loading=false,1000);
                this.showToastMessage('Please fill all the mandatory fields to create order','error','dismissable');
            }
        }else {
            window.setTimeout(()=>this.loading=false,1000);
            this.showToastMessage('Please select the product first','error','dismissable');
        }
    }
    //push the saved/unsaved QO rows to the queue (for QO view puspose).
    addQuoteOrderToTable2(){
        var rowData = [];   
        if(typeof this.serviceTime == 'undefined' || this.serviceTime === '' || this.serviceTime === null){
            this.serviceTime = this.defaultServiceTime;
        }
        //SDT-20408 check blank fields, replaces with null if found.
        this.checkBlankFields();
        let checkDelivery = false;
        if(this.serviceType === 'Delivery' && this.isCSR){
            checkDelivery = true;
        }
        var row = {"idField":this.idField,"actionType": this.actionType,"quoteLineParentId":this.quoteLineParentId,"occurenceType": this.occurenceType,"duration":this.duration, "serviceType" : this.serviceType, "disableDelete" : checkDelivery,"serviceTime" : this.serviceTime, "contact":this.contactForm,"phone":this.phoneForm, "productType" : this.productType,"quoteLineId" : this.quoteLineId, "serviceDate" : this.serviceDateForm,"serviceLineStartDate": this.serviceStartDate,"serviceLineEndDate":this.serviceEndDate, "instruction" : this.instructionForm,"custRefNumber" : this.custRefNumberForm, "bypassWorkOrder" : this.bypassworkorderForm}; //PavanK- Added Bypass Work Order  for SDT-26355
        rowData.push(row); 
        this.quoteOrderMap.set(this.idField,row);
        this.quoteOrderToCreateList= this.quoteOrderToCreateList.concat(rowData);
        //console.log('this.quoteOrderToCreateList>>>'+this.quoteOrderToCreateList);
        this.indexvar= this.quoteOrderToCreateList.length-1;
        window.setTimeout(this.getRowId.bind(this), 500);
    }
    
    //SDT-23801, scroll to bottom when click on add row button
    scrollToBottom(){
        let knowledgeWidgetElement = this.template.querySelector('.slds-modal__content');
		knowledgeWidgetElement.scrollTop=knowledgeWidgetElement.scrollHeight;
    }
    /*-----------------------------ACTIONS-ADD: CLICKING ON ADD ROW BUTTON RELATED METHODS ENDS HERE-----------------------------------------------------------*/

    /*---------------------------ACTIONS-EDIT: CLICKING ON EDIT ROW BUTTON RELATED METHODS STARTS HERE-------------------------------------------------*/
    //For editing the saved/unsaved row.
    editRow(event){
        let keyIndex = event.target.dataset.editid;
        //console.log('keyIndex>editid>>'+keyIndex);
        this.isEdited= true;
        this.loading=true;
        //this.showNote= false;
        //this.note= this.undefinedValue;
        //this.isDisabled=true;
        let mandatoryField= true;
        if(typeof this.idField!=='undefined' && typeof this.actionType!=='undefined' && typeof this.serviceType !== 'undefined' && typeof this.productType !== 'undefined' && typeof this.quoteLineId !== 'undefined' && typeof this.serviceDateForm !== 'undefined' && this.quoteLineId !== '' && this.serviceDateForm !== '' && this.quoteLineId !== null && this.serviceDateForm !== null && (this.servicePOMandatoryMap.has(this.serviceType+this.productType) && ((this.servicePOMandatoryMap.get(this.serviceType+this.productType) && typeof this.custRefNumberForm !== 'undefined' && this.custRefNumberForm !=='' && this.custRefNumberForm !==null) || !this.servicePOMandatoryMap.get(this.serviceType+this.productType))) && (this.serviceType !=='Delivery' || ( typeof this.instructionForm !== 'undefined' && this.instructionForm !=='' && this.instructionForm !==null && this.serviceType === 'Delivery' ))){
            //console.log('1>>>> idField: '+this.idField+' actionType: '+this.actionType+' quoteLineParentId: '+this.selQuoteProd+' serviceType: '+this.serviceType+' occurenceType: '+this.occurenceType+' duration: '+this.duration+' quoteLineId: '+this.quoteLineId+' serviceDate: '+this.serviceDateForm+' instruction: '+this.instructionForm+' custRefNumber: '+this.custRefNumberForm);
            if(typeof this.serviceTime == 'undefined' || this.serviceTime === '' || this.serviceTime === null){
                this.serviceTime = this.defaultServiceTime;
            }
            let checkDelivery = false;
            if(this.serviceType === 'Delivery' && this.isCSR){
                checkDelivery = true;
            }
            var row= {"idField": this.idField,"actionType":this.actionType,"quoteLineParentId":this.selQuoteProd, "serviceType" : this.serviceType, "disableDelete": checkDelivery, "occurenceType": this.occurenceType,"duration":this.duration, "productType" : this.productType,"quoteLineId" : this.quoteLineId, "serviceDate" : this.serviceDateForm, "serviceTime" : this.serviceTime, "contact":this.contactForm,"phone":this.phoneForm, "serviceLineStartDate": this.serviceStartDate,"serviceLineEndDate":this.serviceEndDate, "instruction" : this.instructionForm,"custRefNumber" : this.custRefNumberForm, "bypassWorkOrder" : this.bypassworkorderForm}; //PavanK- Added Bypass Work Order  for SDT-26355
            this.quoteOrderMap.set(this.idField,row);
            this.quoteOrderToCreateList.push(row);
           
        } else if(typeof this.serviceType !== 'undefined' && (typeof this.productType === 'undefined' || this.productType == '' || this.productType == null || typeof this.serviceDateForm === 'undefined' || this.serviceDateForm ===''|| this.serviceDateForm ===null)){
            //console.log('2>>>>');
            mandatoryField= false;
        } 
        // SDT-20110: this.servicePOMandatoryMap is used get if PO mandatory -customer ref required?
        //SDT-20121 & SDT-20299: check if service type delivery, check instructions required?
        else if((this.servicePOMandatoryMap.has(this.serviceType+this.productType) && (this.servicePOMandatoryMap.get(this.serviceType+this.productType) && ( typeof this.custRefNumberForm == 'undefined' || this.custRefNumberForm == '' || this.custRefNumberForm == null))) || (this.serviceType === 'Delivery' && ( typeof this.instructionForm == 'undefined' || this.instructionForm == '' || this.instructionForm == null))){
            //console.log('3>>>>');
            mandatoryField= false;
            //check if warning related to customer rf# and Instructions are required or not.
            this.isShowNotes();
        }
        if(mandatoryField){
            //console.log('4>>>>');
            this.changeAndGetElements(event,keyIndex);
            if(typeof this.quoteOrderToCreateList !=='undefined' && this.quoteOrderToCreateList.length>=1){
                var quoteId= this.quoteOrderToCreateList[keyIndex].idField;
                if(typeof this.serviceTime == 'undefined' || this.serviceTime === '' || this.serviceTime === null){
                    this.serviceTime = this.defaultServiceTime;
                }
                //SDT-20408 check blank fields, replaces with null if found.
                this.checkBlankFields();
                let checkDelivery = false;
                if(this.serviceType === 'Delivery' && this.isCSR){
                    checkDelivery = true;
                }
    /*06-08-2021*/        this.quoteOrderMap.set(quoteId,{"idField": quoteId,"actionType":this.actionType,"quoteLineParentId":this.selQuoteProd, "serviceType" : this.serviceType, "disableDelete": checkDelivery, "occurenceType": this.occurenceType,"duration":this.duration, "productType" : this.productType,"quoteLineId" : this.quoteLineId, "serviceDate" : this.serviceDateForm, "contact":this.contactForm,"phone":this.phoneForm, "serviceLineStartDate": this.serviceStartDate,"serviceLineEndDate":this.serviceEndDate, "serviceTime" : this.serviceTime, "instruction" : this.instructionForm,"custRefNumber" : this.custRefNumberForm, "bypassWorkOrder" : this.bypassworkorderForm});; //PavanK- Added Bypass Work Order  for SDT-26355
                this.quoteOrderToCreateList.splice(keyIndex,1);
                //SDT-23801, since table2 records are increased/decreased reevaluate the validations and overwrite the service dates.
                window.setTimeout(this.overwriteStartEndDatesOnQO.bind(this),500);
            }
            this.scrollToTop();
            window.setTimeout(()=>this.loading=false,1000);
        } else {
            this.scrollToTop();
            window.setTimeout(()=>this.loading=false,1000);
            this.showToastMessage('Please fill all the mandatory fields to create order.','error','dismissable');
        } 
    }

    //While editing and pushing the QO rows to the queue.
    changeAndGetElements(event,keyIndex){
        var element = null;
        if(typeof this.quoteOrderToCreateList !=='undefined' && this.quoteOrderToCreateList.length>0){
            for(var i=0; i <this.quoteOrderToCreateList.length; i++){
                this.createDomSkeleton(element, i);
            }
            for(var i=0; i <this.quoteOrderToCreateList.length; i++){
                if(i==keyIndex){
                    //console.log('matchedIndex>i>inside>>'+i);
                    var snStr = 'snBlock1' + i;
                    var snElement = this.template.querySelector('[data-id='+ snStr +']');
                    //console.log('snElement>i>'+snStr+'>>'+snElement);
                    var snElementVal;
                    if(snElement != null){
                        snElementVal = snElement.value;
                    }
                    var idFieldStr = 'idBlock1' + i;
                    var idFieldElement = this.template.querySelector('[data-id='+ idFieldStr +']');
                    //console.log('idFieldElement>i>'+idFieldStr+'>>'+idFieldElement);
                    var idFieldElementVal;
                    if(idFieldElement != null){
                        idFieldElementVal = idFieldElement.value;
                        //console.log('idFieldElement>v>'+idFieldStr+'>>'+idFieldElement.value);
                    }
    
                    var actionTypeStr = 'actionTypeBlock1' + i;
                    var actionTypeElement = this.template.querySelector('[data-id='+ actionTypeStr +']');
                    //console.log('actionTypeElement>i>'+actionTypeStr+'>>'+actionTypeElement);
                    var actionTypeElementVal;
                    if(actionTypeElement != null){
                        actionTypeElementVal = actionTypeElement.value;
                        //console.log('actionTypeElement>v>'+actionTypeStr+'>>'+actionTypeElement.value);
                    }
    
                    var parentProductQuoteLineStr = 'parentProductQuoteLineBlock1' + i;
                    var parentProductQuoteLineElement = this.template.querySelector('[data-id='+ parentProductQuoteLineStr +']');
                    //console.log('parentProductQuoteLineElement>i>'+parentProductQuoteLineStr+'>>'+parentProductQuoteLineElement);
                    var parentProductQuoteLineElementVal;
                    if(parentProductQuoteLineElement != null){
                        parentProductQuoteLineElementVal = parentProductQuoteLineElement.value;
                        //console.log('parentProductQuoteLineElement>v>'+parentProductQuoteLineStr+'>>'+parentProductQuoteLineElement.value);
                    }
    
                    var quoteLineStr = 'quoteLineBlock1' + i;
                    var quoteLineElement = this.template.querySelector('[data-id='+ quoteLineStr +']');
                    //console.log('quoteLineElement>i>'+quoteLineStr+'>>'+quoteLineElement);
                    var quoteLineElementVal;
                    if(quoteLineElement != null){
                        quoteLineElementVal = quoteLineElement.value;
                        //console.log('quoteLineElement>v>'+quoteLineStr+'>>'+quoteLineElement.value);
                    }
    
                    var occurenceTypeStr = 'occurenceTypeBlock1' + i;
                    var occurenceTypeElement = this.template.querySelector('[data-id='+ occurenceTypeStr +']');
                    //console.log('occurenceTypeElement>i>'+occurenceTypeStr+'>>'+occurenceTypeElement);
                    var occurenceTypeElementVal;
                    if(occurenceTypeElement != null){
                        occurenceTypeElementVal = occurenceTypeElement.value;
                        //console.log('occurenceTypeElement>v>'+occurenceTypeStr+'>>'+occurenceTypeElement.value);
                    }
    
                    var durationStr = 'durationBlock1' + i;
                    var durationElement = this.template.querySelector('[data-id='+ durationStr +']');
                    //console.log('durationElement>i>'+durationStr+'>>'+durationElement);
                    var durationElementVal;
                    if(durationElement != null){
                        durationElementVal = durationElement.value;
                        //console.log('durationElement>v>'+durationStr+'>>'+durationElement.value);
                    }
    
                    var serviceTypeStr = 'serviceTypeBlock1' + i;
                    var serviceTypeElement = this.template.querySelector('[data-id='+ serviceTypeStr +']');
                    //console.log('serviceTypeElement>i>'+serviceTypeStr+'>>'+serviceTypeElement);
                    var serviceTypeElementVal;
                    if(serviceTypeElement != null){
                        serviceTypeElementVal = serviceTypeElement.value;
                        //console.log('serviceTypeElement>v>'+serviceTypeStr+'>>'+serviceTypeElement.value);
                    }

                    var disableDeleteStr = 'disableDeleteBlock1' + i;
                    var disableDeleteElement = this.template.querySelector('[data-id='+ disableDeleteStr +']');
                    //console.log('disableDeleteElement>i>'+disableDeleteStr+'>>'+disableDeleteElement);
                    var disableDeleteElementVal;
                    if(disableDeleteElement != null){
                        disableDeleteElementVal = disableDeleteElement.value;
                        //console.log('disableDeleteElement>v>'+disableDeleteStr+'>>'+disableDeleteElement.value);
                    }
    
                    var productTypeStr = 'productTypeBlock1' + i;
                    var productTypeElement = this.template.querySelector('[data-id='+ productTypeStr +']');
                    //console.log('productTypeElement>i>'+productTypeStr+'>>'+productTypeElement);
                    var productTypeElementVal;
                    if(productTypeElement != null){
                        productTypeElementVal = productTypeElement.value;
                        //console.log('productTypeElement>v>'+productTypeStr+'>>'+productTypeElement.value);
                    }
    
                    var serviceDateStr = 'serviceDateBlock1' + i;
                    var serviceDateElement = this.template.querySelector('[data-id='+ serviceDateStr +']');
                    //console.log('serviceDateElement>i>'+serviceDateStr+'>>'+serviceDateElement);
                    var serviceDateElementVal;
                    if(serviceDateElement != null){
                        serviceDateElementVal = serviceDateElement.value;
                        //console.log('serviceDateElement>v>'+serviceDateStr+'>>'+serviceDateElement.value);
                    }
                    var startDateStr = 'startDateBlock1' + i;
                    var startDateElement = this.template.querySelector('[data-id='+ startDateStr +']');
                    //console.log('serviceDateElement>i>'+serviceDateStr+'>>'+serviceDateElement);
                    var startDateElementVal;
                    if(startDateElement != null){
                        if(typeof startDateElement.value === 'undefined' ||  startDateElement.value === '' || startDateElement.value === null){
                            startDateElementVal= null
                        } else{
                            startDateElementVal = startDateElement.value;
                        }
                        //console.log('serviceDateElement>v>'+serviceDateStr+'>>'+serviceDateElement.value);
                    } else{
                        startDateElementVal=null;
                    }
                    var endDateStr = 'endDateBlock1' + i;
                    var endDateElement = this.template.querySelector('[data-id='+ endDateStr +']');
                    //console.log('serviceDateElement>i>'+serviceDateStr+'>>'+serviceDateElement);
                    var endDateElementVal;
                    if(endDateElement != null){
                        if(typeof endDateElement.value === 'undefined' ||  endDateElement.value === '' || endDateElement.value === null){
                            endDateElementVal= null
                        } else{
                            endDateElementVal = endDateElement.value;
                        }
                        //console.log('serviceDateElement>v>'+serviceDateStr+'>>'+serviceDateElement.value);
                    } else{
                        endDateElementVal=null;
                    }

                    var serviceTimeStr = 'serviceTimeBlock1' + i;
                    var serviceTimeElement = this.template.querySelector('[data-id='+ serviceTimeStr +']');
                    //console.log('serviceDateElement>i>'+serviceDateStr+'>>'+serviceDateElement);
                    var serviceTimeElementVal;
                    if(serviceTimeElement != null){
                        if(typeof serviceTimeElement.value === 'undefined' ||  serviceTimeElement.value === '' || serviceTimeElement.value === null){
                            serviceTimeElementVal= null
                        } else{
                            serviceTimeElementVal = serviceTimeElement.value;
                        }
                        //console.log('serviceDateElement>v>'+serviceDateStr+'>>'+serviceDateElement.value);
                    } else{
                        serviceTimeElementVal=null;
                    }

                    var contactStr = 'contactBlock1' + i;
                    var contactElement = this.template.querySelector('[data-id='+ contactStr +']');
                    //console.log('contactElement>i>'+contactStr+'>>'+contactElement);
                    var contactElementVal;
                    if(contactElement != null){
                        if(typeof contactElement.value === 'undefined' ||  contactElement.value === '' || contactElement.value === null){
                            contactElementVal= null
                        } else{
                            contactElementVal = contactElement.value;
                        }
                        //console.log('contactElement>v>'+contactStr+'>>'+contactElement.value);
                    } else{
                        contactElementVal=null;
                    }

                    var phoneStr = 'phoneBlock1' + i;
                    var phoneElement = this.template.querySelector('[data-id='+ phoneStr +']');
                    //console.log('phoneElement>i>'+phoneStr+'>>'+phoneElement);
                    var phoneElementVal;
                    if(phoneElement != null){
                        if(typeof phoneElement.value === 'undefined' ||  phoneElement.value === '' || phoneElement.value === null){
                            phoneElementVal= null
                        } else{
                            phoneElementVal = phoneElement.value;
                        }
                        //console.log('phoneElementVal>v>'+phoneStr+'>>'+phoneElement.value);
                    } else{
                        phoneElementVal=null;
                    }
        
                    var instructionBlockStr = 'instructionBlock1' + i;
                    var instructionBlockElement = this.template.querySelector('[data-id='+ instructionBlockStr +']');
                    //console.log('instructionBlockElement>i>'+instructionBlockStr+'>>'+instructionBlockElement);
                    var instructionBlockElementVal;
                    if(instructionBlockElement != null){
                        if(typeof instructionBlockElement.value === 'undefined' ||  instructionBlockElement.value === '' || instructionBlockElement.value === null){
                            instructionBlockElementVal= null
                        } else{
                            instructionBlockElementVal = instructionBlockElement.value;
                        }
                        //console.log('instructionBlockElement>v>'+instructionBlockStr+'>>'+instructionBlockElement.value);
                    } else{
                        instructionBlockElementVal=null;
                    }
                    
                    var custRefNumberBlockStr = 'custRefNumberBlock1' + i;
                    var custRefNumberBlockElement = this.template.querySelector('[data-id='+ custRefNumberBlockStr +']');
                    //console.log('custRefNumberBlockElement>i>'+custRefNumberBlockStr+'>>'+custRefNumberBlockElement);
                    var custRefNumberBlockElementVal;
                    if(custRefNumberBlockElement != null){
                        if(typeof custRefNumberBlockElement.value === 'undefined' ||  custRefNumberBlockElement.value === '' || custRefNumberBlockElement.value === null){
                            custRefNumberBlockElementVal= null
                        } else{
                            custRefNumberBlockElementVal = custRefNumberBlockElement.value;
                        }
                        //console.log('custRefNumberBlockElement>v>'+custRefNumberBlockStr+'>>'+custRefNumberBlockElement.value);
                    } else{
                        custRefNumberBlockElementVal=null;
                    }

                    //PavanK-Added Bypass Work Order SDT-26355
                    var bypassWorkOrderStr = 'bypassworkorderBlock1' + i;
                    var bypassWorkOrderElement = this.template.querySelector('[data-id='+ bypassWorkOrderStr +']');
                    console.log('bypassWorkOrderElement>i>'+bypassWorkOrderStr+'>>'+bypassWorkOrderElement.checked);
                    var bypassWorkOrderElementVal;
                    if(bypassWorkOrderElement.checked)
                        bypassWorkOrderElementVal=true;
                    else
                        bypassWorkOrderElementVal=false;
                    //PavanK-End

                    this.serialno= snElementVal;
                    //console.log('this.serialno>reinstate>>'+this.serialno);
                    this.idField = idFieldElementVal;
                    //console.log('this.idField>reinstate>>'+this.idField);
                    this.actionType= actionTypeElementVal;
                    //console.log('this.actionType>reinstate>>'+this.actionType);
                    this.occurenceType = occurenceTypeElementVal;
                    //console.log('this.occurenceType>reinstate>>'+this.occurenceType);
                    this.duration= durationElementVal;
                    //console.log('this.duration>reinstate>>'+this.duration);
                    this.serviceType = serviceTypeElementVal;
                    //console.log('this.serviceType>reinstate>>'+this.serviceType);
                    this.disableDelete = disableDeleteElementVal;
                    //console.log('this.disableDelete>reinstate>>'+this.disableDelete);
                    this.quoteLineParentId= parentProductQuoteLineElementVal;
                    //console.log('this.quoteLineParentId>reinstate>>'+this.quoteLineParentId);
                    this.getBaseReady(this.serviceType);
                    this.updateComponentList(this.serviceType);
                    this.productType = productTypeElementVal;
                    //console.log('this.productType>reinstate>>'+this.productType);
                    //check if warning related to customer rf# and Instructions are required or not.
                    //SDT-20110: this.servicePOMandatoryMap is used get if PO mandatory -customer ref warning required?
                    //SDT-20121 & SDT-20299: check if service type delivery, check instructions warning required?
                    this.isShowNotes();
                    this.quoteLineId = quoteLineElementVal;
                    //console.log('this.quoteLineId>reinstate>>'+this.quoteLineId);
                    this.serviceDateForm= serviceDateElementVal;
                    //console.log('this.serviceDateForm>reinstate>>'+this.serviceDateForm);
                    this.serviceStartDate= startDateElementVal;
                    //console.log('this.serviceStartDate>reinstate>>'+this.serviceStartDate);
                    this.serviceEndDate= endDateElementVal;
                    //console.log('this.serviceEndDate>reinstate>>'+this.serviceEndDate);
                    //SDT-20939, service date validations are fixed for pickup, delivery and removal: https://wastemanagement.atlassian.net/wiki/spaces/SPFH/pages/1385137700/Work+Order+Design+Pointers
                    this.serviceDateValidations(this.idField,this.serviceType,this.productType,this.serviceDateForm,this.serviceStartDate,this.serviceEndDate,'serviceDateBlock');
                    this.serviceTime = serviceTimeElementVal;
                    //console.log('this.serviceTime>reinstate>>'+this.serviceTime);
                    this.contactForm = contactElementVal;
                     //console.log('this.contactForm>reinstate>>'+this.contactForm);
                    this.phoneForm = phoneElementVal;
                     //console.log('this.phoneForm>reinstate>>'+this.phoneForm);
                    this.instructionForm= instructionBlockElementVal;
                    //console.log('this.instructionForm>reinstate>>'+this.instructionForm);
                    this.custRefNumberForm= custRefNumberBlockElementVal;
                    //console.log('this.custRefNumberForm>reinstate>>'+this.custRefNumberForm);
                    this.bypassworkorderForm = bypassWorkOrderElementVal; //PavanK-Added for SDT-26355
                } 
            }
        }
    }
    //SDT-23801, scroll to top when click on edit row button
    scrollToTop(){
		let knowledgeWidgetElement = this.template.querySelector('.slds-modal__content');
		knowledgeWidgetElement.scrollTop=0;
	}

    /*------------------------------ACTIONS-EDIT: CLICKING ON EDIT ROW BUTTON RELATED METHODS ENDS HERE-------------------------------------------------*/

    /*---------------------------ACTIONS-DELETE: CLICKING ON DELETE ROW BUTTON RELATED METHODS STARTS HERE-------------------------------------------------*/
    //delete row from the QO Queue.
    deleteRow(event){
        if(typeof this.quoteOrderToCreateList !=='undefined' && this.quoteOrderToCreateList.length>=1){
            //console.log('Index>event.target.accesskey>>>'+event.target.accesskey); //Giving undefined
            //console.log('Index>>>>'+event.target.dataset.delid); //using this instead
            var quoteId= this.quoteOrderToCreateList[event.target.dataset.delid].idField;
            if(typeof quoteId !== 'undefined' && quoteId.length<=18){
                this.quoteOrderMap.set(quoteId,{"idField": quoteId,"actionType":this.deleteQuote,"quoteLineParentId":this.selQuoteProd, "serviceType" : this.undefinedValue, "disableDelete": this.undefinedValue, "occurenceType": this.undefinedValue,"duration":this.undefinedValue, "productType" : this.undefinedValue,"quoteLineId" : this.undefinedValue, "serviceDate" : this.undefinedValue, "serviceLineStartDate": this.undefinedValue,"serviceLineEndDate":this.undefinedValue, "serviceTime" : this.undefinedValue, "contact":this.undefinedValue,"phone":this.undefinedValue, "instruction" : this.undefinedValue,"custRefNumber" : this.undefinedValue});
                this.quoteOrderToCreateList.splice(event.target.dataset.delid,1);
                this.deleteQuoteOrder(quoteId);
            }else{
                if(this.quoteOrderMap.has(quoteId)){
                    this.showNote = false;
                    this.note = this.undefinedValue;
                    this.quoteOrderMap.delete(quoteId);
                    this.quoteOrderToCreateList.splice(event.target.dataset.delid,1);
                    if(typeof this.quoteOrderToCreateList != 'undefined' && this.quoteOrderToCreateList.length>0){
                        this.indexvar=0;
                        window.setTimeout(this.getRowId.bind(this), 500);
                    }
                }
            }
        }
        else{
            this.showToastMessage('Bad Results! Row Could not be Deleted.','error','sticky');
        }
    }

    //Delete first row(Fill Form)
    deleteCreateFormRow(){
        if(typeof this.idField !== 'undefined' && this.idField.length<=18){
            this.quoteOrderMap.set(this.idField,{"idField": this.idField,"actionType":this.deleteQuote,"quoteLineParentId":this.selQuoteProd, "serviceType" : this.undefinedValue,"disableDelete": this.undefinedValue, "occurenceType": this.undefinedValue,"duration":this.undefinedValue, "productType" : this.undefinedValue,"quoteLineId" : this.undefinedValue, "serviceDate" : this.undefinedValue, "serviceLineStartDate": this.undefinedValue,"serviceLineEndDate":this.undefinedValue, "serviceTime" : this.undefinedValue , "contact":this.undefinedValue,"phone":this.undefinedValue, "instruction" : this.undefinedValue,"custRefNumber" : this.undefinedValue});
            this.deleteQuoteOrder(this.idField);
            this.makeCreateFormEmpty();
        }else{
            if(typeof this.idField !== 'undefined' && this.quoteOrderMap.has(this.idField)){
                this.quoteOrderMap.delete(this.idField);
            }
            this.showNote = false;
            this.note = this.undefinedValue;
            this.makeCreateFormEmpty();
        } 
        this.isEdited=false; 
    }

    //Delete existing QO permanently.
    deleteQuoteOrder(quoteOrderId){
        //console.log('deleteQuoteOrders>>>'+quoteOrderId);
        this.loading=true;
        //console.log('spinner started');
        deleteQuoteLineOrders({"quoteId" : quoteOrderId})
        .then(data =>{
            //console.log('Data>success>'+data);
            if(data == 'success'){
                this.showToastMessage(data,'success','dismissable');
                //this.isDisabled= false;
                this.refreshLogic();
                this.getquoteLineFeatureProductOptionsJs(this.selQuoteProd, this.serviceTypePicklistValues);
                this.getQuoteOrdersByQuoteLineJs(this.selQuoteProd);
                this.loading=false;
                //console.log('spinner stoped');
            }else{
                this.showToastMessage(data,'error','sticky');
                this.refreshLogic();
                this.getquoteLineFeatureProductOptionsJs(this.selQuoteProd, this.serviceTypePicklistValues);
                this.getQuoteOrdersByQuoteLineJs(this.selQuoteProd);
                this.loading=false;
                //console.log('spinner stoped');
            }
        });
    }

    /*---------------------------ACTIONS-DELETE: CLICKING ON DELETE ROW BUTTON RELATED METHODS ENDS HERE-------------------------------------------------*/

    /*---------------------------ACTIONS-UNDO: CLICKING ON UNDO ROW BUTTON RELATED METHODS STARTS HERE-------------------------------------------------*/
    //Refesh the Queue from the Apex controller.
    undoAllUnsavedChanges(){
        this.loading=true;
        this.refreshLogic();
        this.getquoteLineFeatureProductOptionsJs(this.selQuoteProd, this.serviceTypePicklistValues);
        this.getQuoteOrdersByQuoteLineJs(this.selQuoteProd);
        this.isEdited=false;
        window.setTimeout(()=>this.loading=false,2000);
    }
    /*---------------------------ACTIONS-UNDO: CLICKING ON UNDO ROW BUTTON RELATED METHODS ENDS HERE-------------------------------------------------*/
    /*BLOCK5: ENDS----------------------------*/

    /*BLOCK6: STARTS--------------------------*/
    /*---------------------------VALIDATIONS-SERVICE DATE RELATED METHODS STARTS HERE-----------------------------------------------------*/
    //SDT-23801, dispatch logic of service date validations are changed.
    serviceDateValidations(idField,serviceType,productType,serviceDateForm,serviceStartDate,serviceEndDate,serviceDateBlockStr){
        if(typeof productType !== 'undefined' && typeof serviceStartDate !=='undefined' && serviceStartDate !== null && serviceStartDate !== ''){
            let msg='';
            if(serviceType == 'Delivery'){ 
                if(typeof serviceDateForm !== 'undefined' && serviceDateForm !=='' && serviceDateForm !== null){
                    if(serviceDateForm !== serviceStartDate){
                        msg=deliveryOrderError;
                        this.qoServiceDateValidationMessageMap.set(idField,msg);
                        this.qoServiceDateValidationMap.set(idField,false);
                        this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="red";
                    }else{
                        this.qoServiceDateValidationMap.set(idField,true);
                        this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="black";
                    }
                }
            } else if(serviceType == 'Pickup'){
                if(typeof serviceEndDate == 'undefined' || serviceEndDate === '' || serviceEndDate === null){
                    if(typeof serviceDateForm !== 'undefined' && serviceDateForm !=='' && serviceDateForm !== null){
                        if(serviceDateForm<serviceStartDate){
                            msg=pickupOrderError;
                            this.qoServiceDateValidationMessageMap.set(idField,msg);
                            this.qoServiceDateValidationMap.set(idField,false);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="red";
                        }else{
                            this.qoServiceDateValidationMap.set(idField,true);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="black";
                        }
                    }
                }else{
                    if(typeof serviceDateForm !== 'undefined' && serviceDateForm !=='' && serviceDateForm !== null){
                        if(serviceDateForm < serviceStartDate || serviceDateForm > serviceEndDate){
                            msg=pickupOrderError;
                            this.qoServiceDateValidationMessageMap.set(idField,msg);
                            this.qoServiceDateValidationMap.set(idField,false);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="red";
                        }else{
                            this.qoServiceDateValidationMap.set(idField,true);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="black";
                        }
                    }
                }
            } else if(serviceType == 'Removal'){
                if(typeof serviceEndDate == 'undefined' || serviceEndDate === '' || serviceEndDate === null){
                    if(typeof serviceDateForm !== 'undefined' && serviceDateForm !=='' && serviceDateForm !== null){
                        if(serviceDateForm<serviceStartDate){
                            msg=removalOrderError;
                            this.qoServiceDateValidationMessageMap.set(idField,msg);
                            this.qoServiceDateValidationMap.set(idField,false);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="red";
                        }else if(serviceDateForm==serviceStartDate){ //SDT-21162, show warning message if service date =  start date for Removal
                            this.qoServiceDateValidationMap.set(idField,true);
                            this.note=removalOrderWarning;
                            this.showNote= true;
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="black";
                        }else{
                            this.qoServiceDateValidationMap.set(idField,true);
                            if(this.serviceType !== 'Delivery'){
                                this.note='';
                                this.showNote= false;
                            }
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="black";
                        }
                    }
                }else{
                    if(typeof serviceDateForm !== 'undefined' && serviceDateForm !=='' && serviceDateForm !== null){
                        if(serviceDateForm !== serviceEndDate){
                            msg=removalOrderError2;
                            this.qoServiceDateValidationMessageMap.set(idField,msg);
                            this.qoServiceDateValidationMap.set(idField,false);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="red";
                        }else if(serviceDateForm==serviceStartDate){ //SDT-21162, show warning message if service date =  start date for Removal
                            this.qoServiceDateValidationMap.set(idField,true);
                            this.note=removalOrderWarning;
                            this.showNote= true;
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="black";
                        }else{
                            this.qoServiceDateValidationMap.set(idField,true);
                            if(this.serviceType !== 'Delivery'){
                                this.note='';
                                this.showNote= false;
                            }
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="black";
                        }
                    }
                }
            }

            //SDT- 42075- start, adding for Dry Run, Site Survey and Product Order

            else if(serviceType == 'Dry Run'){
                if(typeof serviceEndDate == 'undefined' || serviceEndDate === '' || serviceEndDate === null){
                    if(typeof serviceDateForm !== 'undefined' && serviceDateForm !=='' && serviceDateForm !== null){
                        if(serviceDateForm<serviceStartDate){
                            msg=dryrunOrderError;
                            this.qoServiceDateValidationMessageMap.set(idField,msg);
                            this.qoServiceDateValidationMap.set(idField,false);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="red";
                        }else{
                            this.qoServiceDateValidationMap.set(idField,true);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="black";
                        }
                    }
                }else{
                    if(typeof serviceDateForm !== 'undefined' && serviceDateForm !=='' && serviceDateForm !== null){
                        if(serviceDateForm < serviceStartDate || serviceDateForm > serviceEndDate){
                            msg=dryrunOrderError;
                            this.qoServiceDateValidationMessageMap.set(idField,msg);
                            this.qoServiceDateValidationMap.set(idField,false);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="red";
                        }else{
                            this.qoServiceDateValidationMap.set(idField,true);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="black";
                        }
                    }
                }
            }
            else if(serviceType == 'Site Survey'){
                if(typeof serviceEndDate == 'undefined' || serviceEndDate === '' || serviceEndDate === null){
                    if(typeof serviceDateForm !== 'undefined' && serviceDateForm !=='' && serviceDateForm !== null){
                        if(serviceDateForm<serviceStartDate){
                            msg=sitesurveyOrderError;
                            this.qoServiceDateValidationMessageMap.set(idField,msg);
                            this.qoServiceDateValidationMap.set(idField,false);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="red";
                        }else{
                            this.qoServiceDateValidationMap.set(idField,true);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="black";
                        }
                    }
                }else{
                    if(typeof serviceDateForm !== 'undefined' && serviceDateForm !=='' && serviceDateForm !== null){
                        if(serviceDateForm < serviceStartDate || serviceDateForm > serviceEndDate){
                            msg=sitesurveyOrderError;
                            this.qoServiceDateValidationMessageMap.set(idField,msg);
                            this.qoServiceDateValidationMap.set(idField,false);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="red";
                        }else{
                            this.qoServiceDateValidationMap.set(idField,true);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="black";
                        }
                    }
                }
            }
            else if(serviceType == 'Product Order'){
                if(typeof serviceEndDate == 'undefined' || serviceEndDate === '' || serviceEndDate === null){
                    if(typeof serviceDateForm !== 'undefined' && serviceDateForm !=='' && serviceDateForm !== null){
                        if(serviceDateForm<serviceStartDate){
                            msg=productorderOrderError;
                            this.qoServiceDateValidationMessageMap.set(idField,msg);
                            this.qoServiceDateValidationMap.set(idField,false);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="red";
                        }else{
                            this.qoServiceDateValidationMap.set(idField,true);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="black";
                        }
                    }
                }else{
                    if(typeof serviceDateForm !== 'undefined' && serviceDateForm !=='' && serviceDateForm !== null){
                        if(serviceDateForm < serviceStartDate || serviceDateForm > serviceEndDate){
                            msg=productorderOrderError;
                            this.qoServiceDateValidationMessageMap.set(idField,msg);
                            this.qoServiceDateValidationMap.set(idField,false);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="red";
                        }else{
                            this.qoServiceDateValidationMap.set(idField,true);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="black";
                        }
                    }
                }
            }
                    
            //SDT- 42075- end, adding for Dry Run, Site Survey and Product Order
            
            else if(serviceTypes.indexOf(serviceType) > -1){
                if(typeof serviceEndDate == 'undefined' || serviceEndDate === '' || serviceEndDate === null){
                    if(typeof serviceDateForm !== 'undefined' && serviceDateForm !=='' && serviceDateForm !== null){
                        if(serviceDateForm<serviceStartDate){
                            msg= serviceType + ' order should be equal or greater than start date and less than or equal to end date';
                            this.qoServiceDateValidationMessageMap.set(idField,msg);
                            this.qoServiceDateValidationMap.set(idField,false);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="red";
                        }else{
                            this.qoServiceDateValidationMap.set(idField,true);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="black";
                        }
                    }
                }else{
                    if(typeof serviceDateForm !== 'undefined' && serviceDateForm !=='' && serviceDateForm !== null){
                        if(serviceDateForm < serviceStartDate || serviceDateForm > serviceEndDate){
                            msg=serviceType + ' order should be equal or greater than start date and less than or equal to end date';
                            this.qoServiceDateValidationMessageMap.set(idField,msg);
                            this.qoServiceDateValidationMap.set(idField,false);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="red";
                        }else{
                            this.qoServiceDateValidationMap.set(idField,true);
                            this.template.querySelector('[data-id='+serviceDateBlockStr+']').style.color="black";
                        }
                    }
                }
            }
        }
    }
    /*---------------------------------------VALIDATIONS-SERVICE DATE RELATED METHODS ENDS HERE-----------------------------------------------------*/
    /*BLOCK6: ENDS----------------------------*/

    /*BLOCK7: STARTS--------------------------*/
    /*---------------------------ACTIONS-SAVE: CLICKING ON SAVE ROW BUTTON RELATED METHODS STARTS HERE-------------------------------------------------*/
    //Save all the QO rows
    //SDT-23801, before save validations rules will be dispatched.
    saveQuoteOrders(){
        //console.log('saveQuoteOrders');
	 // START SDT-33378
         if(!this.startDateCheckValidity){
             this.showToastMessage( this.startDateCheckValidityMessage,'error','dismissable');
        return;
       }
        //END SDT-33378
	    
        this.loading=true;
        let isQoServiceDateValidationPassed = true;
        //console.log('spinner started');
        let mandatoryFieldsFlag= true;
        let dateErrorMessage='';
        // SDT-20110: this.servicePOMandatoryMap is used get if PO mandatory -customer ref required?
        //SDT-20121 & SDT-20299: check if service type delivery, check instructions required?
        if(typeof this.idField!=='undefined' && typeof this.actionType!=='undefined' && typeof this.serviceType !== 'undefined' && typeof this.productType !== 'undefined' && typeof this.quoteLineId !== 'undefined' && typeof this.serviceDateForm !== 'undefined' && this.quoteLineId !== '' && this.serviceDateForm !== '' && this.quoteLineId !== null && this.serviceDateForm !== null && (this.servicePOMandatoryMap.has(this.serviceType+this.productType) && ((this.servicePOMandatoryMap.get(this.serviceType+this.productType) && typeof this.custRefNumberForm !== 'undefined' && this.custRefNumberForm !=='' && this.custRefNumberForm !==null) || !this.servicePOMandatoryMap.get(this.serviceType+this.productType))) && (this.serviceType !=='Delivery' || ( typeof this.instructionForm !== 'undefined' && this.instructionForm !=='' && this.instructionForm !==null && this.serviceType === 'Delivery' ))){
            if(this.qoServiceDateValidationMap.has(this.idField)){
                if(!this.qoServiceDateValidationMap.get(this.idField)){
                    isQoServiceDateValidationPassed =false;
                    mandatoryFieldsFlag =false
                    dateErrorMessage = this.qoServiceDateValidationMessageMap.get(this.idField);
                }else{
                    if(typeof this.quoteOrderToCreateList !== 'undefined' && this.quoteOrderToCreateList.length>0){
                        for(let x=0;x<this.quoteOrderToCreateList.length;x++){
                            if(this.qoServiceDateValidationMap.has(this.quoteOrderToCreateList[x].idField)){
                                if(!this.qoServiceDateValidationMap.get(this.quoteOrderToCreateList[x].idField)){
                                    isQoServiceDateValidationPassed =false;
                                    mandatoryFieldsFlag =false
                                    dateErrorMessage = this.qoServiceDateValidationMessageMap.get(this.quoteOrderToCreateList[x].idField);
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            if(isQoServiceDateValidationPassed){
                if(typeof this.serviceTime === 'undefined' || this.serviceTime === '' || this.serviceTime === null){
                    this.serviceTime = this.defaultServiceTime;
                }
                //SDT-20408 check blank fields, replaces with null if found.
                this.checkBlankFields();
                let checkDelivery = false;
                if(this.serviceType === 'Delivery' && this.isCSR){
                    checkDelivery = true;
                }
                //console.log('this.idField'+this.idField+'>>actionType'+this.actionType+'>>quoteLineParentId'+this.selQuoteProd+'>>serviceType'+this.serviceType+'>>occurenceType'+this.occurenceType+'>>duration'+this.duration+'>>productType'+this.productType+'>>quoteLineId'+this.quoteLineId+'>>serviceDate'+this.serviceDateForm+'>>serviceLineStartDate'+this.serviceStartDate+'>>serviceLineEndDate'+this.serviceEndDate+'>>serviceTime'+this.serviceTime+'>>contact'+this.contactForm+'>>phone'+this.phoneForm+'>>instruction'+this.instruction+'>>custRefNumber'+this.custRefNumberForm);
                var row= {"idField": this.idField,"actionType":this.actionType,"quoteLineParentId":this.selQuoteProd, "serviceType" : this.serviceType, "disableDelete": checkDelivery,"occurenceType": this.occurenceType,"duration":this.duration, "productType" : this.productType,"quoteLineId" : this.quoteLineId, "serviceDate" : this.serviceDateForm, "serviceLineStartDate": this.serviceStartDate,"serviceLineEndDate":this.serviceEndDate, "serviceTime" : this.serviceTime, "contact":this.contactForm,"phone":this.phoneForm, "instruction" : this.instructionForm,"custRefNumber" : this.custRefNumberForm, "bypassWorkOrder" : this.bypassworkorderForm}; //PavanK- Added Bypass Work Order  for SDT-26355
                this.quoteOrderMap.set(this.idField,row);
                this.quoteOrderToCreateList.push(row);
                mandatoryFieldsFlag= true;
            }else{
                this.showToastMessage(dateErrorMessage,'error','dismissable');
            }
            //console.log('this.serviceDateForm>>>'+this.serviceDateForm);
        } else if(typeof this.serviceType !== 'undefined' && (typeof this.productType == 'undefined' || typeof this.serviceDateForm == 'undefined' || this.serviceDateForm ==='' || this.serviceDateForm ===null || (this.servicePOMandatoryMap.has(this.serviceType+this.productType) && (this.servicePOMandatoryMap.get(this.serviceType+this.productType) && ( typeof this.custRefNumberForm == 'undefined' || this.custRefNumberForm == '' || this.custRefNumberForm == null))) || (this.serviceType === 'Delivery' && ( typeof this.instructionForm == 'undefined' || this.instructionForm == '' || this.instructionForm == null)))){
            mandatoryFieldsFlag= false;
            //console.log('this.serviceDateForm>>>'+this.serviceDateForm);
        }
        // SDT-20110: this.servicePOMandatoryMap is used get if PO mandatory -customer ref required?
        //SDT-20121 & SDT-20299: check if service type delivery, check instructions required?
        else if((this.servicePOMandatoryMap.has(this.serviceType+this.productType) && ((this.servicePOMandatoryMap.get(this.serviceType+this.productType) && typeof this.custRefNumberForm !== 'undefined' && this.custRefNumberForm !=='' && this.custRefNumberForm !==null) || !this.servicePOMandatoryMap.get(this.serviceType+this.productType))) && (typeof this.serviceType == 'undefined' || typeof this.productType == 'undefined' || typeof this.serviceDateForm == 'undefined' || this.serviceDateForm ==='' || this.serviceDateForm ===null || (this.serviceType === 'Delivery' && ( typeof this.instructionForm == 'undefined' || this.instructionForm == '' || this.instructionForm == null)))){
            mandatoryFieldsFlag= false;
            //console.log('this.custRefNumberForm>>>'+this.custRefNumberForm);
            //SDT-20121 & SDT-20299: check if service type delivery, check instructions required?
        } else if(this.serviceType === 'Delivery' && ( typeof this.instructionForm == 'undefined' || this.instructionForm == '' || this.instructionForm == null)){
            mandatoryFieldsFlag= false;
            //console.log('this.instructionForm>>>'+this.instructionForm);
        }else {
            if(typeof this.quoteOrderToCreateList !== 'undefined' && this.quoteOrderToCreateList.length>0){
                for(let x=0;x<this.quoteOrderToCreateList.length;x++){
                    if(this.qoServiceDateValidationMap.has(this.quoteOrderToCreateList[x].idField)){
                        if(!this.qoServiceDateValidationMap.get(this.quoteOrderToCreateList[x].idField)){
                            isQoServiceDateValidationPassed =false;
                            mandatoryFieldsFlag =false
                            dateErrorMessage = this.qoServiceDateValidationMessageMap.get(this.quoteOrderToCreateList[x].idField);
                            break;
                        }
                    }
                }
            }
            if(!isQoServiceDateValidationPassed){
                this.showToastMessage(dateErrorMessage,'error','dismissable');
            }
        }

        if(isQoServiceDateValidationPassed){
            if(mandatoryFieldsFlag){
                this.iteratorObj= this.quoteOrderMap.values();
                this.quoteOrderToSendList=[];
                let result = this.iteratorObj.next();
                while (!result.done) {
                    //console.log('result.value>>>'+result.value.actionType);
                    this.quoteOrderToSendList.push(result.value); 
                    result = this.iteratorObj.next();
                }
                //console.log('this.quoteOrderToSendList>>>'+this.quoteOrderToSendList[0].idField);
                if(typeof this.quoteOrderToSendList !== 'undefined' && this.quoteOrderToSendList.length>0){
                    this.isDisabled= true;
                    //console.log('this.quoteOrderToSendList.length>>>'+this.quoteOrderToSendList.length);
                    //console.log('this.quoteOrderToSendList>>'+JSON.stringify(this.quoteOrderToSendList[0]));
                    let recId=''; //SDT-21795
                    if(this.quoteRecordId){
                        recId= this.quoteRecordId;
                    } else if(this.recordId){
                        recId= this.recordId;
                    }
                    if(this.bundleEndDateForm == undefined || this.bundleEndDateForm == null){
                        if(this.quoteOrderToSendList!=undefined && this.quoteOrderToSendList!=null && this.quoteOrderToSendList.length>0){
                            for(let i=0; i<this.quoteOrderToSendList.length; i++){
                                if(this.quoteOrderToSendList[i].serviceType=='Removal' || this.quoteOrderToSendList[i].serviceType=='Haul'){
                                    this.bundleEndDateForm = this.quoteOrderToSendList[i].serviceDate;
                                }
                            }
                        }
                    }
                    //SDT-29723 : assetAvailabilityWrapper added to method
                    let assetAvailabilityFields = this.getAssetAvailabilityFields();
                    actionsOnQuoteLineOrders({"quoteId" : recId,"selQuoteProd" : this.selQuoteProd,"bundleStartDate" : this.bundleStartDateForm,"bundleEndDate": this.bundleEndDateForm,"vendorDate": this.vendorCommitDate, "quoteOrderListStr" : JSON.stringify(this.quoteOrderToSendList)
                                                ,"assetAvailabilityWrapper": assetAvailabilityFields}) // SDT-32136 Vendorcommitdate added as param
                    .then(data =>{
                        if(data == 'success'){
                            //this.isDisabled= false;
                            this.refreshLogic();
                            this.getquoteLineFeatureProductOptionsJs(this.selQuoteProd, this.serviceTypePicklistValues);
                            this.getQuoteOrdersByQuoteLineJs(this.selQuoteProd);
                            window.setTimeout(()=>this.loading=false,3000);
                            this.showToastMessage(data,'success','dismissable');
                        }
                        else{
                            //this.isDisabled=false;
                            this.isValidationPassed= false;
                            this.refreshLogic();
                            this.getquoteLineFeatureProductOptionsJs(this.selQuoteProd, this.serviceTypePicklistValues);
                            this.getQuoteOrdersByQuoteLineJs(this.selQuoteProd);
                            window.setTimeout(()=>this.loading=false,3000);
                            this.showToastMessage(data,'error','dismissable');
                        }
                        this.isDisabled=false;
                    }).catch(error =>{
                        this.isDisabled= false;
                        this.isValidationPassed= false;
                        this.refreshLogic();
                        this.getquoteLineFeatureProductOptionsJs(this.selQuoteProd, this.serviceTypePicklistValues);
                        this.getQuoteOrdersByQuoteLineJs(this.selQuoteProd);
                        window.setTimeout(()=>this.loading=false,3000);
                        this.showToastMessage(error.body.pageErrors[0].statusCode+': '+error.body.pageErrors[0].message,'error','dismissable');
                    });
                }else{
                    this.isDisabled= false;
                    window.setTimeout(()=>this.loading=false,3000);
                    this.showToastMessage('Please fill all the mandatory fields to create order.','error','dismissable');
                }
            }else{
                this.isDisabled= false;
                window.setTimeout(()=>this.loading=false,3000);
                this.showToastMessage('Please fill all the mandatory fields to create order.','error','dismissable');
            }
        }else{
            window.setTimeout(()=>this.loading=false,3000);
        }
    }
    /*--------------------------------ACTIONS-SAVE: CLICKING ON SAVE ROW BUTTON RELATED METHODS ENDS HERE-------------------------------------------------*/
    /*BLOCK7: ENDS----------------------------*/

    /*BLOCK8: STARTS--------------------------*/
    /*------------------------------------DISPOSING CLASS VARIABLES SCOPE RELATED METHODS STARTS HERE--------------------------------------------*/
    
    //clear/default all the form fields
    makeCreateFormEmpty(){
        this.idField= this.undefinedValue;
        this.actionType= this.undefinedValue;
        this.quoteLineParentId= this.undefinedValue;
        this.serviceType = this.undefinedValue;
        this.disableDelete = this.undefinedValue;
        this.componentList = [{label:'',value:''}];
        this.productType = this.undefinedValue;
        this.quoteLineId = this.undefinedValue;
        this.serviceTime = 'ASAP'; //service window defaulted with ASAP
        this.contactForm = this.undefinedValue;
        this.phoneForm = this.undefinedValue;
        this.serviceDateForm= this.undefinedValue;
        this.instructionForm= this.locPosition; //location position pre-populate.
        this.custRefNumberForm= this.undefinedValue;
        this.occurenceType= this.undefinedValue;
        this.duration= this.undefinedValue;
        this.serviceStartDate = this.undefinedValue;
        this.serviceEndDate = this.undefinedValue;
        this.bypassworkorderForm = false; //PavanK-Added for SDT-26355
    }

    //executes after save click, basically clear all the var type variables.
    refreshLogic(){
        //console.log('refresh logic is started.');
        this.quoteOrderToSendList=[];
        this.quoteOrderToCreateList.splice(0,this.quoteOrderToCreateList.length);
        this.isDelete= false;
        this.showNote= false;
        this.note= this.undefinedValue;
        this.isDelivery=false;
        this.qoServiceDateValidationMessageMap = new Map();
        this.qoServiceDateValidationMap.clear();
        this.quoteOrderMap.clear();
        this.prodQuotelineIdMap.clear();
        this.prodQuotelineIdMap2.clear();
        this.servicePOMandatoryMap.clear();
        this.isEdited=false;
        this.makeCreateFormEmpty(); 
        
    }

    //close the popup modal.
    closeModal() {    
        //console.log('>>>Close Modal');
        this.bShowModal = false;
        this.isShowTable=false;
        this.isCSR=false;
        this.isDo= true;
        this.isDisabled= true;
        this.showNote = false;
        this.note= this.undefinedValue;
        this.componentList=[];
        this.selectedProd='';
        this.locPosition='';
        this.serviceDate='';
        this.isDelivery=false;
        this.selectedProductOptions= this.undefinedValue;
        this.defaultQuoteOrderStructure= [];
        this.quoteOrderToSendList=[];
        this.quoteOrderToCreateList=[];
        this.isDelete= false;
        this.quoteOrderMap= new Map();
        this.qoServiceDateValidationMessageMap = new Map();
        this.qoServiceDateValidationMap= new Map();
        this.prodQuotelineIdMap= new Map();
        this.prodQuotelineIdMap2= new Map();
        this.servicePOMandatoryMap= new Map();
        this.serviceTypeProdQuoteLineIdMap= new Map();
        this.isEdited=false;
        this.disableFields= true;
        this.makeCreateFormEmpty();
        //update the list of orders in summary screen on quote detail.
        const value = true;
		const valueChangeEvent = new CustomEvent("valuechange", {
		  detail: { value }
		});
		// Fire the custom event
		this.dispatchEvent(valueChangeEvent);
    }
    /*------------------------------------DISPOSING CLASS VARIABLES SCOPE RELATED METHODS ENDS HERE--------------------------------------------*/
    /*BLOCK8: ENDS--------------------------*/

    //SDT-29723 : Handle start date change from Asset availabilty Date picker
    handleStartDateUpdate(event){
        if(event.detail.date) this.updateStartDate(event.detail.date);
    }
    //SDT-29723 : Method for SLA date assignment
    determineSLAForAssetAvailability(){
        if(this.assetAvailabilityAccess && this.inlineProd){
            determineSLADate({parentQuoteLineId : this.inlineProd})
            .then(result=>{
                this.slaDate = result;
            })
            .catch(error=>{
                this.slaDateError = true;
                console.error('determineSLADate failure ->',error);
            });  
        }         
    }
    //SDT-29723 : Method will return wrapper of Asset Availability Fields
    getAssetAvailabilityFields(){
        let fieldObject = {assetAvailability : this.assetAvailabilityAccess};
        if(this.assetAvailabilityAccess){
            this.getDeliveryAvailability(fieldObject);
        }
        return fieldObject;
    }
    //SDT-29723 : Method will return delivery Availability Value
    getDeliveryAvailability(fieldObject){
        try{
            let aavCustomDatePicker = this.template.querySelector('.aavCustomDatePicker');
            fieldObject.deliveryAvailability = aavCustomDatePicker
                            ? aavCustomDatePicker.getDeliveryDateConditions() :'';
        }
        catch(error) {
            fieldObject.deliveryAvailability = '';
            console.error(error);
        } 
    }
}
