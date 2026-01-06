import { LightningElement, api, track } from 'lwc';
import allWasteCategories from '@salesforce/label/c.WasteCategory_ShowLocalVendorComp';
export default class WasteStreamComp extends LightningElement {

    @api wasteStreamValues;
    @track wasteStreamOptions;
    @track selectedWasteStream;

    @api
    setPicklistValues(){
        //console.log('this.wasteStreamValues>>>'+this.wasteStreamValues);
        if(this.wasteStreamValues){
            //console.log('this.wasteStreamValues>>>'+JSON.stringify(this.wasteStreamValues));
            //console.log('this.wasteStreamValues>>>'+this.wasteStreamValues);
            let wasteStreamValuesSet = new Set(this.wasteStreamValues);
            let picklistOptions=[];
            let count=0;
            wasteStreamValuesSet.forEach(key =>{
                picklistOptions.push({
                    label: key, 
                    value: key
                });
                count++;
            });
            if(count == 1){
                let value = picklistOptions[0].value;
                var element= this.template.querySelector('[data-id="wasteStreamBlock"]');
                element.value= value;
                //this.selectedWasteStream = value;
                const eve= new CustomEvent('selectedwastestreamevent',{detail:{ value }});
                this.dispatchEvent(eve);
                picklistOptions.unshift({
                    label: allWasteCategories, 
                    value: allWasteCategories
                });
                this.wasteStreamOptions= picklistOptions;
            }else{
                picklistOptions.unshift({
                    label: allWasteCategories, 
                    value: allWasteCategories
                });
                this.wasteStreamOptions= picklistOptions;
                let value = allWasteCategories;
                var element= this.template.querySelector('[data-id="wasteStreamBlock"]');
                element.value= value;
                //this.selectedWasteStream = value;
                //console.log('this.selectedWasteStream>>>'+this.selectedWasteStream);
                const eve= new CustomEvent('selectedwastestreamevent',{detail:{ value }});
                this.dispatchEvent(eve);
            }
        }
    }

    wasteStreamHandler(event){
        let value = event.detail.value;
        const eve= new CustomEvent('selectedwastestreamevent',{detail:{ value }});
        this.dispatchEvent(eve);
    }
}