import { LightningElement, api, track } from 'lwc';
import fetchComChannel from '@salesforce/apex/CommunicationChannelViewController.communicationData';
export default class MaintainVendorEscalationCom extends LightningElement {

    @api recordId;
    comFunction = [];
    comType = [];
    mapData = {};
    keys = [];
    displayResult = [];
    finalResult = [];
    comNotes = {};
    isDisplay = true;
    @track showSpinner = false;
    connectedCallback() {
        this.fetchCommData();
    }

    fetchCommData() {
        this.showSpinner = true;
        fetchComChannel({ vendorRecordId: this.recordId })
            .then(result => {
                this.comFunction = result.lstComFunction;
                this.comType = result.lstComType;
                this.mapData = result.comDataMap;
                this.comNotes = result.comDataNotesMap;
                this.keys = Object.keys(result.comDataMap);
                let i =0;
                this.comType.forEach(comT => {
                    let j = 0;
                    var holdArrayVal = [];
                    console.log('result com type : ' + comT);
                    this.comFunction.forEach(comF => {
                        if(comF != "Comm")
                        {
                            if(j==0)
                            {
                                holdArrayVal.push({
                                    value: '<strong>'+comT+'</strong>',
                                    helptext: ""
                                });
                            }
                            if (this.mapData[comF + '-' + comT] != undefined) {
                                holdArrayVal.push({
                                    value: this.mapData[comF + '-' + comT],
                                    helptext: this.comNotes[comF + '-' + comT]
                                });
                            }
                            else {
                                holdArrayVal.push("");
                            }
                            j++;
                        }
                    });
                    i++;
                    this.finalResult.push(holdArrayVal);
                });
                if(this.finalResult.length === 0)
                {
                    this.isDisplay = false;
                }
            })
            .catch(error => {
                console.log('Error Occured', JSON.stringify(error));
                this.error = error;

            })
            .finally(fn => {
                this.showSpinner = false;
            }) ;
    }

}