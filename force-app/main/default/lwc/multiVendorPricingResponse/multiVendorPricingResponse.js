import { LightningElement, track, wire, api } from 'lwc';
import getPricingMultiVendorDetails from "@salesforce/apex/PricingRequestMultiVendorSTPProcess.getPricingMultiVendorDetails";
import saveMultiVendorPricingRequest from "@salesforce/apex/PricingRequestMultiVendorSTPProcess.saveMultiVendorPricingRequest";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import Vendor_Mismatch from '@salesforce/label/c.WM_Franchise';
export default class MultiVendorPricingResponse extends NavigationMixin(LightningElement) {
    @api recordid;
    @api selectedPrRecId;
    @api pricingResponce;
    @track wrapperPRList;
    @track allVendors = [];
    @track bundleWiseMultiVendorsList = [];
    @track greenPagesList = [];
    selectAlertMessage = false;
    listAssetError = false;
    isCostOnlyMessage = false;
    isVendorMismatchError = false;
    isProcurementErrorMessage = false;
    isProblemErrorMessage = false;
    isShowVendorButton = true;
    isStepCost = false;
    isStepPrice = false;
    checkShowVendor = false;
    costOnlyMessage;
    isGreenPage = false;
    isWrapperList = true;
    isProductDetails = false;
    selectedVenderName;
    pricingRequest;
    isDefaultVendor = false;
    isMultiVendor = false;
    showSpinner = false;
    isShowVendorAlert = false;
    isSaveButton = false;
    isgrpPagination = false;
    isProbelmMsg = false;
    @track quoteLineWrapper;
    @track pricingJsonWrapper;
    isRollOff;
    isFacilityId;
    sourceCode;

    @track selectedVendorMap = new Map();
    @track storedVendorCodeMap = new Map();

    label = {
        Vendor_Mismatch
    };

    connectedCallback() {
        this.showSpinner = true;
        if (this.recordid !== undefined || this.recordid !== null) {
            var productName = '';
            this.invokeMutliVendorResponse(productName);
        }
    }

    // Fetch Prcing Response details which are stored in Quote Line
    // Fetch Prcing Response details with All Vendors.
    invokeMutliVendorResponse(productName) {
        getPricingMultiVendorDetails({ quoteID: this.recordid })
            .then((result) => {
                this.wrapperPRList = result;
                this.quoteLineWrapper = this.wrapperPRList.selectedVendor;
                this.pricingJsonWrapper = this.wrapperPRList.multiVendor;
                console.log("MultiVendor=====> :" + JSON.stringify(this.pricingJsonWrapper));
                console.log("selectedVendor=====> :" + JSON.stringify(this.quoteLineWrapper));
                this.showSpinner = false;
                this.quoteLineWrapper.forEach(element => {
                    if (productName != '') {
                        if (productName == element.ProductName) {
                            element.displayShowVendor = false;
                        } else {
                            element.displayShowVendor = true;
                        }
                    }
                    if (element.ProductDetailsList != null){
                            element.ProductDetailsList.forEach(elt => {
                                this.sourceCode = elt.SourceCode;
                                elt.sequence = 1;
                            this.storedVendorCodeMap.set(element.BundleLink, elt.SourceCode);
                    });
                    }
                   
                });
                this.generateCurrentVendorData(this.quoteLineWrapper);
            })
            .catch((e) => {
                this.showSpinner = false;
                console.log("showMultivendor Error : Catch " + e);
                //this.error = error;
            });

    }

    //When user wants to see the default vendor, fetch the vendor details in each bundle from the QL.
    //Generating all vendors details which are stored in Pricing Response.
    generateCurrentVendorData(dataWrapper) {
        this.wrapperPRList = [];
        this.wrapperPRList = JSON.parse(JSON.stringify(dataWrapper));
        console.log('strting wrapper===>' + JSON.stringify(this.wrapperPRList));
        this.isWrapperList = this.wrapperPRList != null ? false : true;
        this.isProductDetails = this.wrapperPRList.length > 0 && this.wrapperPRList[0].ProductDetailsList != null ? false : true;
        this.isVendorMismatchError = this.wrapperPRList.IsVendorMismatchError != null ? true : false;
        
        
        var count = 1;
        
        this.wrapperPRList.forEach(element => {
            console.log('ProcurementErrorMessage==>'+element.ProcurementErrorMessage);
            this.isProcurementErrorMessage = this.sourceCode == 'WM' && (element.ProcurementErrorMessage != null || element.ProcurementErrorMessage != '') ? true : false;
            element.isProbelmMsg = false;
            this.isRollOff = element.LOB == 'Rolloff' ? true : false;
            if (element.Problem != null) {
                for (let i in element.Problem) {
                    element.isProbelmMsg = true;
                    element.problemMessage = element.Problem[i];
                    element.checkShowVendor = element.VendorCount > 1 ? false : true;
                }
            }

            if (element.ProductDetailsList != null) {
                if (element.ProductDetailsList.length > 0) {
                    element.checkShowVendor = element.VendorCount > 1 ? false : true;
                    element.ProductDetailsList.forEach(elt => {
                        elt.isProblemErrorMessage = false;
                        if (elt.ServiceCharges != null) {
                            elt.ServiceCharges.forEach(sc => {
                                if(sc.StepRates != null){
                                    sc.StepRates.forEach(sr => {
                                        this.isStepCost = sr.StepCost != null ? true : false;
                                        this.isStepPrice = sr.StepPrice != null ? true : false;
                                    });
                                }
                            });
                        }

                        if (elt.FacilityId != null) {
                            elt.isFacilityId = elt.FacilityId != null ? true : false;
                        }

                        if (element.Problem != null) {

                            elt.isProblemErrorMessage = element.Problem.ErrorMessage != null ? true : false;
                            elt.vendorErrorMessage = element.Problem.ErrorMessage;
                            this.isSaveButton = true;
                        }
                        if (elt.vendorMessage != null) {
                            elt.isProblemErrorMessage = elt.vendorMessage != null ? true : false;
                            this.isSaveButton = true;

                            //var nozoneErrorCode = elt.vendorMessage.filter(x=>x.code=="ER60");
                            //elt.ErrorCode = nozoneErrorCode[0].code;
                            elt.vendorMessage.forEach(msg => {
                                elt.vendorErrorMessage = msg.description;
                            });
                        } else {
                            elt.isProblemErrorMessage = false;
                            this.isSaveButton = false;
                        }
                        if (elt.CostOnlyMessage != null) {
                            this.isCostOnlyMessage = elt.CostOnlyMessage != null ? true : false;
                            this.costOnlyMessage = elt.CostOnlyMessage != null ? elt.CostOnlyMessage : '';
                        }
                        if (elt.GreenPages != null) {
                            elt.isGreenPage = true;
                        } else {
                            elt.isGreenPage = false;
                        }
                        if(elt.IsPriceSelected == true){
                            
                            this.selectedVendorMap.set(element.BundleLink, elt.VendorCode);
                        }
                        if(elt.sequence == 1){
                            elt.IsPaginated = true;
                        }else{
                            elt.IsPaginated = false;
                        }
                        /*if(elt.sequence == undefined){
                            elt.sequence = count++;
                        }
                        if(elt.sequence == 1){
                            elt.IsPaginated = true;
                            elt.IsPriceSelected = true;
                            this.selectedVendorMap.set(element.BundleLink, elt.VendorCode);
                        }else{
                            elt.IsPaginated = false;
                            elt.IsPriceSelected = false;
                        }*/
                    });
                }
            }
            count = 1;
        });
        this.wrapperPRList = this.wrapperPRList.map(person => ({
             ...person,
            ProductDetailsList: Array.isArray(person.ProductDetailsList) ? person.ProductDetailsList.sort((a, b) => a.sequence - b.sequence)       : []
       }));
        console.log('default vendor details===>' + JSON.stringify(this.wrapperPRList));
        if (this.wrapperPRList) {
            this.listAssetError = false;
        } else {
            this.listAssetError = true;
        }
        this.showSpinner = false;
    }

    // When User change the vendor to another vendor get vendor details and storing in the map(selectedVendorMap).
    handleSelectVendor(event) {
        this.isShowVendorAlert = true;
        this.wrapperPRList.forEach(element => {
            if (element.ProductName == event.target.name) {
                element.ProductDetailsList.forEach(elt => {
                    if (elt.sequence != event.target.value) {
                        elt.IsPriceSelected = false;
                        if (elt.VendorCode === this.selectedVendorMap.get(element.BundleLink) || event.target.checked === false) {
                            this.selectedVendorMap.delete(element.BundleLink, elt.VendorCode);
                        }
                    } else {
                        if (elt.FacilityId != null) {
                            elt.isFacilityId = elt.FacilityId != null ? true : false;
                        }


                        if (elt.vendorMessage != null) {
                            this.isProblemErrorMessage = elt.vendorMessage != null ? true : false;
                            elt.vendorMessage.forEach(msg => {
                                element.vendorErrorMessage = msg.description;
                            });
                        }
                        if (elt.CostOnlyMessage != null) {
                            this.isCostOnlyMessage = elt.CostOnlyMessage != null ? true : false;
                            this.costOnlyMessage = elt.CostOnlyMessage != null ? elt.CostOnlyMessage : '';
                        }
                        if (elt.GreenPages != null) {
                            elt.isGreenPage = true;
                        } else {
                            elt.isGreenPage = false;
                        }
                        elt.IsPriceSelected = true;
                        this.selectedVendorMap.set(element.BundleLink, elt.VendorCode);
                        this.selectedVenderName = elt.Vendor;
                        this.pricingRequest = element.PricingReqId;
                    }
                });
            }
        });

    }

    //When user wants to see perticular vendor, fetch the vendor details in each bundle.
    handlevendors(event) {
        const anchors = this.template.querySelectorAll('.pagination a');
        anchors.forEach(anchor => anchor.classList.remove('active'));
        event.target.classList.add('active');

        this.wrapperPRList.forEach(element => {
            if (element.ProductName == event.target.dataset.name) {
                element.ProductDetailsList.forEach(elt => {
                    if (elt.sequence == event.target.dataset.value) {
                        elt.IsPaginated = true;
                        this.isProblemErrorMessage = elt.vendorMessage != null ? true : false;
                        this.isCostOnlyMessage = elt.CostOnlyMessage != null ? true : false;
                        this.costOnlyMessage = elt.CostOnlyMessage != null ? elt.CostOnlyMessage : '';
                        if (elt.GreenPages != null) {
                            elt.isGreenPage = true;
                            this.isgrpPagination = true;
                        } else {
                            elt.isGreenPage = false;
                            this.isgrpPagination = false;
                        }
                        if (elt.ServiceCharges != null) {
                            elt.ServiceCharges.forEach(sc => {
                                if(sc.StepRates != null){
                                    sc.StepRates.forEach(sr => {
                                        this.isStepCost = sr.StepCost != null ? true : false;
                                        this.isStepPrice = sr.StepPrice != null ? true : false;
                                    });
                                }
                            });
                        }
                    } else {
                        elt.IsPaginated = false;
                        elt.isGreenPage = false;
                    }
                });
            }
        });
    }

    //When user wants to change vendor details along with cost and price for the Product.
    handleVendorSave(event) {
        this.showSpinner = true;
        const mapEntries = Object.fromEntries(this.selectedVendorMap.entries());
        var productName = event.target.dataset.name;
        const mapjson = JSON.stringify(mapEntries)
        saveMultiVendorPricingRequest({ quoteID: this.recordid, suppliersMap: mapjson })
            .then((result) => {
                //shajiya
  this.dispatchEvent(              
  new ShowToastEvent({
                    title: 'Success',
                    message: 'The pricing has been successfully changed and updated for the product',
                    variant: 'success',
                    mode: 'dismissable'
                })
            );
            //shajiay
                setTimeout(() => {
                    this.invokeMutliVendorResponse(productName);
                    this.showSpinner = false;
                }, 3000);
                this.isShowVendorButton = false;
                this.isDefaultVendor = false;
            })
            .catch(e => {
                console.log('Error updating Quote Line: ' + e);
            });
    }

    //Navigation to record page of the Quote Line Object.
    navigateQLObject(event) {
        var recordId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'SBQQ__QuoteLine__c',
                actionName: 'view'
            }
        });
    }

    //Navigation to record page of the Pricing Request Object.
    navigatePRObject(event) {
        var recordId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Pricing_Request__c',
                actionName: 'view'
            }
        });
    }

    //When user wants to see multi-vendors for the bundle.
   /* showMultiVendors(event) {
        this.isMultiVendor = true;
        this.isDefaultVendor = true;
        this.isgrpPagination = true;
        var count = 2;
        var size = 1;
        this.pricingJsonWrapper.forEach(element => {
            if (event.target.name == element.ProductName) {
                element.displayShowVendor = false;
            } else {
                element.displayShowVendor = true;
            }
            element.ProductDetailsList.forEach(elt => {
                if(elt.SourceCode == this.storedVendorCodeMap.get(element.BundleLink)){
                    if(elt.SourceCode != undefined){
                        elt.sequence = 1;
                        elt.IsPaginated = true;
                        elt.IsPriceSelected = true;
                    }
                }else{
                    elt.sequence = count++;
                    elt.IsPaginated = false;
                    elt.IsPriceSelected = false;
                }
            });
        });
        this.generateCurrentVendorData(this.pricingJsonWrapper);
    }*/
showMultiVendors(event) {
    this.isMultiVendor = true;
    this.isDefaultVendor = true;
    this.isgrpPagination = true;
 
    const prioritizedErrorMessages = [
        'Missing Disposal Facility',
        'No Cost/Price Info available',
        'Unable to geocode address',
        'No WM Zone information available'
    ];
 
    this.pricingJsonWrapper.forEach((element) => {
        if (Array.isArray(element.ProductDetailsList) && element.ProductDetailsList.length > 0) {
            const SortedList = [...element.ProductDetailsList];
 
            // Sort vendors: WM first → Rank → First letter of Vendor
            SortedList.sort((a, b) => {
                const vendorA = (a.Vendor || '').trim().toUpperCase();
                const vendorB = (b.Vendor || '').trim().toUpperCase();
 
                const isWM_A = vendorA.startsWith('WM');
                const isWM_B = vendorB.startsWith('WM');
  // Check if vendor has priority error message
                const hasPriorityError_A = prioritizedErrorMessages.includes((a.vendorErrorMessage || '').trim());
                const hasPriorityError_B = prioritizedErrorMessages.includes((b.vendorErrorMessage || '').trim())
 
                if (isWM_A && !isWM_B) return -1;  
                if (!isWM_A && isWM_B) return 1;
// Prioritize vendors with error messages
                if (hasPriorityError_A && !hasPriorityError_B) return -1;  // A comes first (error message)
                if (!hasPriorityError_A && hasPriorityError_B) return 1;   // B comes first (error message)

                const rankA = Number(a.VendorRank) || 0;
                const rankB = Number(b.VendorRank) || 0;
 
                if (rankA !== rankB) return rankA - rankB;
 
                // Alphabetical by first letter
                const nameCompare = vendorA.localeCompare(vendorB);
                if (nameCompare !== 0) return nameCompare;  // Alphabetically compare vendors
 
                return 0;  // Return 0 if everything is equal
            });
 
            element.ProductDetailsList = SortedList;
 
            let wmCount = 1;
            let nonWmCount = 1;
            
 
            const storedVendorCode = this.storedVendorCodeMap?.get(element.BundleLink);

            SortedList.forEach(elt => {
                const vendorName = (elt.Vendor || '').toUpperCase();
                const isWM = vendorName.startsWith('WM');
                const hasPriorityError = prioritizedErrorMessages.includes((elt.vendorErrorMessage || '').trim());
 
                // Sequence assignment
                if (isWM || hasPriorityError) {
                    elt.sequence = wmCount++;
                    elt.IsPaginated = true;
                } else {
                    elt.sequence = wmCount + nonWmCount - 1;
                    elt.IsPaginated = false;
                    nonWmCount++;
                }
 
               // Preselect vendor if it matches storedVendorCode or SourceCode
                if (storedVendorCode) {
                    elt.IsPriceSelected = (storedVendorCode === elt.SourceCode);
                } else if (this.sourceCode && this.sourceCode === elt.SourceCode) {
                    elt.IsPriceSelected = true;
                } else {
                    elt.IsPriceSelected = false;
                }
 
                console.log(`Vendor: ${elt.Vendor}, Rank: ${elt.Rank}, Sequence: ${elt.sequence}, Preselected: ${elt.IsPriceSelected}`);
            });
        } else {
             console.warn(`No valid ProductDetailsList found in bundle:`, element);
        }
 
        // Show/hide vendor group
        element.displayShowVendor = (event.target.name !== element.ProductName);
    });
 
    // Regenerate vendor data
    this.generateCurrentVendorData(this.pricingJsonWrapper);
    this.isProcurementErrorMessage = false;
}
 
    //When user wants to close without selecting any vendor.
    closeMultiVendors(event) {
        this.isMultiVendor = false;
        this.isDefaultVendor = false;
        this.isgrpPagination = false;
        this.generateCurrentVendorData(this.quoteLineWrapper);
    }
    //Sorting vendors as per sequence.
    sortCurrentVendor(currentVendor) {
       /* this.currentVendor = [...currentVendor].sort((a, b) =>
            a.ProductDetailsList.sequence - b.ProductDetailsList.sequence
         );
         console.log("sorted multi vendors=====> :" + JSON.stringify(this.currentVendor));*/
        }

        handleAccordionActive(event){
            this.isMultiVendor = false;
            this.isDefaultVendor = false;
            this.isgrpPagination = false;
            this.generateCurrentVendorData(this.quoteLineWrapper);
        }
}