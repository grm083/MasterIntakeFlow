import { LightningElement,api,wire,track } from 'lwc';
import getWorkOrderDetails from '@salesforce/apex/AcornWODetailsController.getWorkOrderDetails';
export default class AcornWODetails extends LightningElement {
    @track error;
    @track data ;
    @api recordId;
    @wire(getWorkOrderDetails, { quoteId: '$recordId' })
    wiredOpps({
        error,
        data
    }) {
        if (data) {
            this.data = data;
            console.log(data);
            console.log(JSON.stringify(data, null, '\t'));
        } else if (error) {
            this.error = error;
        }
    }
}