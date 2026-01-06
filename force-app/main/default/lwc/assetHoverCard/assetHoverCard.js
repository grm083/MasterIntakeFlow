import { LightningElement,api,wire,track } from 'lwc';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import getServiceDetail from '@salesforce/apex/HoverOverCardsCntrl.getHoverServiceDetails';
const FIELDS = [
                'Case.Id','Case.AssetId','Case.Asset.ProductFamily','Case.Asset.Name','Case.Asset.Material_Type__c',
                'Case.Asset.Acorn_SID__c','Case.Asset.Duration__c','Case.Asset.Occurrence_Type__c','Case.Asset.Vendor_Account_Number__c',
                'Case.Asset.Schedule__c','Case.Asset.Quantity__c','Case.Asset.Supplier__r.Name','Case.Asset.Vendor_ID__c','Case.Asset.Sensitivity_Code__c',
                'Case.Asset.Has_Extra_Pickup__c','Case.Asset.Equipment_Owner__c','Case.Asset.Start_Date__c','Case.Asset.End_Date__c',
                'Case.Asset.Container_Position__c','Case.Asset.Category__c','Case.Asset.MAS_Library__c','Case.Asset.Project_Code__r.ProjectCode_Id__c',
                'Case.Asset.MAS_Customer_Unique_Id__c','Case.Asset.MAS_Company_Account_Number__c'
]; 
export default class AssetHoverCard extends LightningElement {
    @api caseid;
    @track caseDetails;

    @track assetdetails;
    @track pickUpCost = false;
    @track pickUpPrice = false;
    @track extraPickUpPrice = false;
    @track extraPickUpCost = false;
    @track extraPickUpCost = false;
    @track haulCost = false;
    @track haulPrice = false;
    @track disposalCost = false;
    @track disposalPrice = false;
    @wire(getRecord, { recordId: '$caseid', fields: FIELDS })recdata({ error, data }){
        if(data){
            this.caseDetails = {
               Id:  getFieldValue(data, 'Case.Id'),
               Asset : {
                    ProductFamily: getFieldValue(data, 'Case.Asset.ProductFamily'),
                    Name: getFieldValue(data, 'Case.Asset.Name'),
                    Material_Type__c: getFieldValue(data, 'Case.Asset.Material_Type__c'),
                    Acorn_SID__c: getFieldValue(data, 'Case.Asset.Acorn_SID__c'),
                    Duration__c: getFieldValue(data, 'Case.Asset.Duration__c'),
                    Occurrence_Type__c: getFieldValue(data, 'Case.Asset.Occurrence_Type__c'),
                    Schedule__c: getFieldValue(data, 'Case.Asset.Schedule__c'),
                    Quantity__c: getFieldValue(data, 'Case.Asset.Quantity__c'),
                    Supplier__r: {Name: getFieldValue(data, 'Case.Asset.Supplier__r.Name')},
                    Vendor_ID__c: getFieldValue(data, 'Case.Asset.Vendor_ID__c'),
                    Sensitivity_Code__c: getFieldValue(data, 'Case.Asset.Sensitivity_Code__c'),
                    Has_Extra_Pickup__c: getFieldValue(data, 'Case.Asset.Has_Extra_Pickup__c'),
                    Equipment_Owner__c: getFieldValue(data, 'Case.Asset.Equipment_Owner__c'),
                    Start_Date__c: getFieldValue(data, 'Case.Asset.Start_Date__c'),
                    End_Date__c: getFieldValue(data, 'Case.Asset.End_Date__c'),
                    Container_Position__c: getFieldValue(data, 'Case.Asset.Container_Position__c'),
                    Category__c: getFieldValue(data, 'Case.Asset.Category__c'),
                    MAS_Library__c: getFieldValue(data, 'Case.Asset.MAS_Library__c'),
                    Project_Code__r: {ProjectCode_Id__c : getFieldValue(data, 'Case.Asset.Project_Code__r.ProjectCode_Id__c')},
                    Vendor_Account_Number__c: getFieldValue(data, 'Case.Asset.Vendor_Account_Number__c'),
                    MAS_Customer_Unique_Id__c: getFieldValue(data, 'Case.Asset.MAS_Customer_Unique_Id__c'),
                    MAS_Company_Account_Number__c: getFieldValue(data, 'Case.Asset.MAS_Company_Account_Number__c'),
               },
               AssetId: getFieldValue(data, 'Case.AssetId')
            };
        }else if(error){
            console.log('GETError$$$$'+JSON.stringify(error));
        }
    };

    @wire(getServiceDetail,{ caseid: '$caseid'}) caselst({ error, data }) {
        if(data){
            
            this.assetdetails = data;
            if(data.pickUpCost){
                this.pickUpCost = true;
            }
            if(data.pickUpPrice){
                this.pickUpPrice = true;
            }
            if(data.extraPickUpPrice){
                this.extraPickUpPrice = true;
            }
            if(data.extraPickUpCost){
                this.extraPickUpCost = true;
            }
            if(data.haulCost){
                this.haulCost = true;
            }
            if(data.haulPrice){
                this.haulPrice = true;
            }
            if(data.disposalCost){
                this.disposalCost = true;
            }
            if(data.disposalPrice){
                this.disposalPrice = true;
            }
        }else if(error){
            console.log('GETError$$$$'+JSON.stringify(error));
        }
    };
}