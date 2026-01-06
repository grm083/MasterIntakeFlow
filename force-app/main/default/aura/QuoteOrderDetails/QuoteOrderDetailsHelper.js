({
    assembleQuoteLine : function(cmp) {
        
    },
    prepopulateQLine : function(cmp, cQLine, serviceStartTime, serviceEndTime){
         
        console.log('currQ==>'+JSON.stringify(currQ));
        cmp.set("v.specialDisposal",false);
        
        if(cQLine.Certificate_of_Destruction__c == true){
            cmp.set("v.certificateValue",'Destruction');
            cmp.set("v.specialDisposal",true);
        }else if(cQLine.Certificate_of_Disposal__c == true){
            cmp.set("v.certificateValue",'Disposal');
            cmp.set("v.specialDisposal",true);
        }else{
            cmp.set("v.certificateValue",'None');
        }
        if(cQLine.Profile_Number__c){
            cmp.set("v.specialDisposal",true);
            cmp.set("v.profileNumber", cQLine.Profile_Number__c);
        }
        if(cQLine.Landfill_Tickets__c){
            cmp.set("v.specialDisposal",true);
            cmp.set('v.landfillTickets', cQLine.Landfill_Tickets__c);
        }
        
        if(cQLine.Special_Disposal_Description__c){
            cmp.set('v.serviceDescription', cQLine.Special_Disposal_Description__c);
        }
        cmp.set("v.serviceRestriction",false);
        if(serviceStartTime){
            cmp.set("v.serviceRestriction",true);
            console.log('serviceStartTime==>'+JSON.stringify(serviceStartTime));
            serviceStartTime = serviceStartTime.substring(0, serviceStartTime.length - 1);
            console.log('serviceStartTime==>'+JSON.stringify(serviceStartTime));
            cmp.set('v.startTime',this.timeConvert(serviceStartTime));
        }
        if(serviceEndTime){
            cmp.set("v.serviceRestriction",true);
            console.log('serviceEndTime==>'+JSON.stringify(serviceEndTime));
            serviceEndTime = serviceEndTime.substring(0, serviceEndTime.length - 1);
            console.log('serviceEndTime==>'+JSON.stringify(serviceEndTime));
            cmp.set('v.endTime',this.timeConvert(serviceEndTime));
        }
        if(cQLine.Gate_Code__c){
            cmp.set("v.serviceRestriction",true);
            cmp.set('v.gateCode',cQLine.Gate_Code__c);
        }
        if(cQLine.Restriction_Details__c){
            cmp.set("v.serviceRestriction",true);
            cmp.set('v.serviceInstructions',cQLine.Restriction_Details__c);
        }
        if(cQLine.Location_Position_Name__c){
            cmp.set("v.offsiteAddress",true);
        }
        var currQ = cmp.get('v.currentQuote');
        cmp.set('v.projectServices',currQ.Project_Services_Request__c);
        if(cmp.get('v.projectServices') == true && currQ.Project__c!= null){
            cmp.set('v.selectedProject', currQ.Project__c);
        	cmp.find('searchProjects').set('v.value',currQ.Project__r.Name);
            this.getActiveProjects(cmp);
        }
    },
    getActiveProjects : function(cmp){
        var queryProducts = cmp.find('searchProjects').get('v.value');
        if(queryProducts.length > 3) {
            var searchProducts = cmp.get('c.getActiveProjects');
            searchProducts.setParams({
                quoteId: cmp.get('v.recordId'),
                searchString: queryProducts
            });
            searchProducts.setCallback(this, function(response) {
                if (response.getState() === 'SUCCESS') {
                    cmp.set('v.activeProjects', response.getReturnValue());
                }
            });
            $A.enqueueAction(searchProducts);
        }  
    },
    convertToTime : function(s){
        var ms = s % 1000;
        s = (s - ms) / 1000;
        var secs = s % 60;
        s = (s - secs) / 60;
        var mins = s % 60;
        var hrs = (s - mins) / 60;
        
        
        let finalhr =  hrs + ':' + mins;
        console.log('finalhr==>'+finalhr);
        return finalhr;
    },
    timeConvert : function(newtime){
        if(newtime!=='' && newtime !== null)
        {
            var time = newtime.split('.', 1)[0];
            // Check correct time format and split into components
            time = time.toString ().match (/^([01]\d|2[0-3])(:)([0-5]\d)(:[0-5]\d)?$/) || [time];

            if (time.length > 1) { // If time format correct
                time = time.slice (1);  // Remove full string match value
                time[5] = +time[0] < 12 ? 'AM' : 'PM'; // Set AM/PM
                time[0] = +time[0] % 12 || 12; // Adjust hours
                time[3] =' ';
            }
            return time.join ('');
        }
        return '';
    
    },
    //SDT-41473 - 41542
    addDaysToDate: function(startDate,days){
        var dateObj = new Date(startDate);
        console.log('date1 '+dateObj);
       
        dateObj.setDate(dateObj.getDate()+ days);
        console.log('date2 '+dateObj);

        var year = dateObj.getFullYear();
        console.log('date3 '+year);
        var month = (dateObj.getMonth()+1).toString().padStart(2,'0');
        console.log('date4 '+month);
        var day = dateObj.getDate().toString().padStart(2,'0');
        console.log('date4 '+day);

        return `${year}-${month}-${day}`;
    }, 
	
    // method to create Acorn and Service Instructions
     createInstructions: function(instructionMap, quoteOrder,  EMPTY_STRING, CONTACT, PHONE) {
        var serviceInstructions = '';
        var serviceAcornInstructions='';
        for (var i = 0; i < instructionMap.length; i++) {
            //alert(instructionMap[i].key]);  
            //alert(instructionMap[i].value);
            if (instructionMap[i].key !== EMPTY_STRING && instructionMap[i].value !== EMPTY_STRING) {
                serviceAcornInstructions += instructionMap[i].value;

                if (instructionMap[i].key !== CONTACT && instructionMap[i].key !== PHONE) {
                    serviceInstructions += instructionMap[i].value;
                }
            }
        }
        quoteOrder.instructions = serviceInstructions;
        quoteOrder.acornInstructions = serviceAcornInstructions;
    },
    //SDT-41473 Added @param  VENDORSERVICEID
     prepareInstructionMap: function(qo, CONTACT, PHONE, cmp, EMPTY_STRING, GATE_CODE, START_TIME, CERTIFICATE_VALUE, PLACEMENT_INSTRUCTIONS, SERVICE_DESCRIPTION, SERVICE_INSTRUCTIONS,VENDORSERVICEID,CHARGEABILITY,Service_Start_Time__c, Service_End_Time__c) {
        let instructionMap = [];
     
        if (qo.onsiteContact !== null) {
            instructionMap.push({ key: CONTACT, value: 'ONSITE CONTACT: ' + qo.onsiteContact + ', ' });
        }
    
        if (qo.onsitePhone !== null) {
            instructionMap.push({ key: PHONE, value: 'PHONE: ' + qo.onsitePhone + '\n ' });
        }
    
        if (cmp.get('v.gateCode') !== EMPTY_STRING) {
            instructionMap.push({ key: GATE_CODE, value: 'GATE CODE: ' + cmp.get('v.gateCode') + '\n ' });
        }
    
        if (cmp.get('v.startTime') !== EMPTY_STRING) {
            instructionMap.push({ key: START_TIME, value: 'Service must be provided between ' + this.timeConvert(Service_Start_Time__c) + ' and ' + this.timeConvert(Service_End_Time__c) + '\n ' });
        }
    
        if (cmp.get('v.certificateValue') !== 'None') {
            instructionMap.push({ key: CERTIFICATE_VALUE, value: 'Certificate of ' + cmp.get('v.certificateValue') + ' must be provided after each haul' + '\n ' });
        }
    
        if (cmp.get('v.placementInstructions') !== EMPTY_STRING) {
            instructionMap.push({ key: PLACEMENT_INSTRUCTIONS, value: cmp.get('v.placementInstructions') + '\n ' });
        }
        if ((cmp.get('v.vendorServiceId') !== EMPTY_STRING) && (cmp.get('v.vendorServiceId'))) {
            instructionMap.push({ key: VENDORSERVICEID, value: 'Vendor Service Id: ' + cmp.get('v.vendorServiceId') + '\n ' });
        } 
    
        if (cmp.get('v.serviceDescription') !== EMPTY_STRING) {
            instructionMap.push({ key: SERVICE_DESCRIPTION, value: cmp.get('v.serviceDescription') + '\n ' });
        }
    
        if (cmp.get('v.serviceInstructions') !== EMPTY_STRING) {
            instructionMap.push({ key: SERVICE_INSTRUCTIONS, value: cmp.get('v.serviceInstructions') + '\n ' });
        }
        return instructionMap;
    },
    //SDT-30864 : Asset Availability
    getDeliveryOverrideReasons :function(cmp){
        if(cmp.get('v.assetAvailabilityAccess')){
            let getPicklists = cmp.get('c.getDeliveryOverrideReasons');
            getPicklists.setCallback(this, function(response) {
                cmp.set('v.deliveryOverrideReasons', response.getReturnValue());
            });
            $A.enqueueAction(getPicklists);
        }
    }
})