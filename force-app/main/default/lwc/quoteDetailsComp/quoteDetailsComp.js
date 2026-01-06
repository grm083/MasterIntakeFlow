import { LightningElement, track, api} from 'lwc';


export default class QuoteDetailsComp extends LightningElement {
    @api bundleList;
    @api quoteId;
    @api picklistSchema;
    @api cpqEligible;
    @track activeBundle;
    @track showModal= false;
    @track activeProdId;
    @track isView;
    @track isBundleList;

    @api
    connectedCallback(){
        this.isBundleList= false;
        if(this.bundleList.length>0){
            this.isBundleList= true;
        }
    }

    createViewOrder(event){
        //console.log('QO>>'+event.currentTarget.value);
        const prodId= event.currentTarget.value;
        if(prodId){
            //console.log('this.cpqEligible>>'+this.cpqEligible);
            if(this.cpqEligible){
                this.isView = false;
            }else{
                this.isView = true;
            }
            this.showModal = true;
            this.activeProdId = prodId;
            setTimeout(() => this.template.querySelector('c-quote-order-comp').openModal());
            setTimeout(() => {this.template.querySelector('c-quote-order-comp').getChildProducts()},1000);
        }
    }
}