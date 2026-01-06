({
    noButtonClicked: function(){
        this.showToast('No Button Clicked', 'error', 'Please Select any Schedule to proceed');
    },
    onCall: function(component, event){
        component.set("v.showSpinner", true);
        
        var quoteId = component.get("v.quoteId");
        console.log('quoteId==>'+quoteId);
        
        var action = component.get("c.submitOnCall");
        action.setParams({ 
            qId : quoteId, 
            parentQLineId : component.get("v.parentId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var fResult = response.getReturnValue();
            console.log('state==>'+state);
            if (state === "SUCCESS") {
                console.log("fResult==>"+fResult);
                if(fResult=="SUCCESS"){
                    this.updateScreen(component);
                    this.showToast('Success', 'success', 'Record updated Successfully');
                    component.set("v.showSpinner", false);
                    component.set("v.showSIDModal", false);
                }else{
                    this.showToast('Error', 'error', fResult);
                    component.set("v.showSpinner", false);
                }
            }
            else{
                this.showToast('Error', 'error', fResult);
                    component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    daily: function(component, event){
        const clickedBtn = this.getDailyBtnName(component);
        console.log('clickedBtn==>'+clickedBtn);
        
        if(clickedBtn=='Daily'){
            const freq = this.getFrequency(component);
            console.log('freq==>'+freq);
            if(freq!=''){
                this.updateDailyEveryDay(component, freq);
            }
        }else if(clickedBtn=='Weekly'){
            this.updateDailyEveryWeek(component);
        }
    },
    weekly: function(component, event){
        const everyWeeks = component.get("v.everyWeeks");
        console.log('everyWeeks==>'+everyWeeks);
        
        const selectedWeekDayOption = component.get("v.selectedWeekDayOption");
        console.log('selectedWeekDayOption==>'+selectedWeekDayOption);
        
        //SDT 31262
        //if(this.weeksValidated(everyWeeks) && this.serviceDaysValidated(selectedWeekDayOption)){
            this.updateWeekly(component, everyWeeks, selectedWeekDayOption);
        //}
    },
    monthly: function(component, event){
        console.log('line#61');
        var btnName = component.get("v.monthlyEveryMonthBtnstate")? 'Every Month' : (component.get("v.monthlySpecificMonthBtnstate")? 'Specific Month' : '');
        console.log('btnName==>'+btnName);
        if(this.validateMonthlySelect(btnName)){
            if(btnName=='Every Month'){
                console.log('line#66');
                this.monthlyEveryMonth(component);
            }else{
                //SDT-38285 -start - using new method as functionality changed
                //this.monthlySpecificMonth(component);                
                this.monthlySpecificMonthNew(component);
                //SDT-38285 -End
            }
        }
    },
    yearly: function(component, event){
        const yearlyState = component.get('v.yearlyBtnstate'); 
        const yearlyFrequency = component.get('v.yearlyFrequency'); 
        if(this.yearlyStateValidated(yearlyState) && this.yearlyFrequencyValidated(yearlyFrequency)){
            this.updateYearly(component, yearlyFrequency);
        }
    },
    yearlyStateValidated: function(yearlyState){
        if(yearlyState==false){
            this.showToast('Alert', 'warning', 'Please Click on select button to continue');
            return false;
        }
        return true;
    },
    yearlyFrequencyValidated: function(yearlyFrequency){
        if(yearlyFrequency==0 || yearlyFrequency=='' || yearlyFrequency==null || isNaN(yearlyFrequency)){
            this.showToast('Alert', 'warning', 'Please provide a valid Every__Year(s) to proceed');
        	return false;
        }
        return true;
    },
    monthlySpecificMonth: function(component){
        const dayOfMonth = component.get("v.monthlySpecificdayOfMonth");
        console.log('dayOfMonth==>'+dayOfMonth);
        
        const freq = component.get("v.monthlySpecificMonthFrequency");
        console.log('freq==>'+freq);
        
        //TCS-pkulkarn-SDT-38495-20-May-2024-Removed the validations on JavaScript for the  Frequency Interval field for the Schedule Frequency of Monthly
            this.updateMonthlySpecific(component, dayOfMonth, freq);
    },
    //SDT-38285 - start
    monthlySpecificMonthNew: function(component){
               
        //SDt-38285 - Start
        
        if(this.validateMonthlyRadiosNew()){
            var valueOfRadioSelected ;
            
            var radioServiceDateVar = document.getElementById("radioServiceDate");
        	var radioServiceDayVar = document.getElementById("radioServiceDay");
        	var radioServiceDateCheck = radioServiceDateVar.checked;
        	var radioServiceDayCheck = radioServiceDayVar.checked; 
            if(radioServiceDateCheck){
            	valueOfRadioSelected = radioServiceDateVar.value;
            }else if(radioServiceDayCheck){
                valueOfRadioSelected = radioServiceDayVar.value;
            }
            var dayOfMonthInptVar = document.getElementById("inputFieldDayOfMonth");
			var dayOfMonthFrequencyInptVar = document.getElementById("inputFieldOfDayOfMonthFrequency");
            var onTheFirstInptVar = document.getElementById("inputFieldOfOnTheFirst");
			var onTheDayOfWeekInptVar = document.getElementById("inputFieldOfOnTheDayOfWeek");
			var onTheFrequencyInptVar = document.getElementById("inputFieldOfOnTheFrequency");
            
            var valueOfdayOfMonthInptVar = dayOfMonthInptVar.value;
            var valueOfdayOfMonthFrequencyInptVar = dayOfMonthFrequencyInptVar.value;
            
            var valueOfonTheFirstInptVar = onTheFirstInptVar.value;
            var valueOfonTheDayOfWeekInptVar = onTheDayOfWeekInptVar.value;
            var valueOfonTheFrequencyInptVar = onTheFrequencyInptVar.value;
            this.updateMonthlySpecificIntervalsNew(component, valueOfRadioSelected, valueOfdayOfMonthInptVar, valueOfdayOfMonthFrequencyInptVar, valueOfonTheFirstInptVar, valueOfonTheDayOfWeekInptVar, valueOfonTheFrequencyInptVar);
        }
        
    	//SDT-38285 - end        
    },
    validateMonthlyRadiosNew: function(){
        var radioServiceDateVar = document.getElementById("radioServiceDate");
        var radioServiceDayVar = document.getElementById("radioServiceDay");
        var radioServiceDateCheck = radioServiceDateVar.checked;
        var radioServiceDayCheck = radioServiceDayVar.checked; 
        if(!radioServiceDateCheck && !radioServiceDayCheck){
            const monthlyTypeServiceScheduleErrorMessage = $A.get("$Label.c.MonthlyTypeServiceScheduleErrorMessage");
            this.showToast('Alert', 'warning', monthlyTypeServiceScheduleErrorMessage);
            return false;
        }else if(radioServiceDateCheck){
            var dayOfMonthInptVar = document.getElementById("inputFieldDayOfMonth");
			var dayOfMonthFrequencyInptVar = document.getElementById("inputFieldOfDayOfMonthFrequency");
            var valueOfdayOfMonthInptVar = dayOfMonthInptVar.value;
            var valueOfdayOfMonthFrequencyInptVar = dayOfMonthFrequencyInptVar.value;
            if($A.util.isUndefinedOrNull(valueOfdayOfMonthInptVar) || $A.util.isEmpty(valueOfdayOfMonthInptVar)
              || valueOfdayOfMonthInptVar === 0 || isNaN(valueOfdayOfMonthInptVar)){
                const validDayOfMonthErrorMessage = $A.get("$Label.c.ValidDayOfMonthErrorMessage");
            	this.showToast('Alert', 'warning', validDayOfMonthErrorMessage);
            return false;
        	}
        }else if(radioServiceDayCheck){
            var onTheFirstInptVar = document.getElementById("inputFieldOfOnTheFirst");
			var onTheDayOfWeekInptVar = document.getElementById("inputFieldOfOnTheDayOfWeek");
			var valueOfonTheFirstInptVar = onTheFirstInptVar.value;
            var valueOfonTheDayOfWeekInptVar = onTheDayOfWeekInptVar.value;
            if($A.util.isUndefinedOrNull(valueOfonTheFirstInptVar) || $A.util.isEmpty(valueOfonTheFirstInptVar)
              || $A.util.isUndefinedOrNull(valueOfonTheDayOfWeekInptVar) || $A.util.isEmpty(valueOfonTheDayOfWeekInptVar)){
            	const validMonthlyIntervalErrorMessage = $A.get("$Label.c.ValidMonthlyIntervalErrorMessage");
                this.showToast('Alert', 'warning', validMonthlyIntervalErrorMessage);
            	return false;
        	}
        }
        
        return true;
    },
    //SDT-38285 - End
    updateYearly: function(component, freq){
        component.set("v.showSpinner", true);
        
        var quoteId = component.get("v.quoteId");
        console.log('quoteId==>'+quoteId);
			
        var action = component.get("c.submitYearly");
        action.setParams({ 
            qId : quoteId,
            parentQLineId : component.get("v.parentId"),
            frequency : freq
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state==>'+state);
            if (state === "SUCCESS") {
                var fResult = response.getReturnValue();
                console.log("fResult==>"+fResult);
                if(fResult=="SUCCESS"){
                    this.updateScreen(component);
                    this.showToast('Success', 'success', 'Record updated Successfully');
                    component.set("v.showSpinner", false);
                    component.set("v.showSIDModal", false);
                }else{
                    this.showToast('Error', 'error', fResult);
                    component.set("v.showSpinner", false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    monthlyEveryMonth: function(component){
        const freq = component.get("v.monthlyEveryMonthFrequency");
        //TCS-pkulkarn-SDT-38495-20-May-2024-Commented the validations on JavaScript for the Frequency Interval field for the Schedule Frequency of Monthly and moved to controller class
        this.updateMonthly(component, freq);
    },
    updateMonthly: function(component, freq){
        component.set("v.showSpinner", true);
        
        var quoteId = component.get("v.quoteId");
        console.log('quoteId==>'+quoteId);

        var action = component.get("c.submitMonthly");
        action.setParams({ 
            qId : quoteId,
            parentQLineId : component.get("v.parentId"),
            frequency : freq
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state==>'+state);
            if (state === "SUCCESS") {
                var fResult = response.getReturnValue();
                console.log("fResult==>"+fResult);
                if(fResult=="SUCCESS"){
                    this.updateScreen(component);
                    this.showToast('Success', 'success', 'Record updated Successfully');
                    component.set("v.showSpinner", false);
                    component.set("v.showSIDModal", false);
                }else{
                    this.showToast('Error', 'error', fResult);
                    component.set("v.showSpinner", false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    //SDT-38285 - Start
    updateMonthlySpecificIntervalsNew: function(component, valueOfRadioSelected, valueOfdayOfMonthInptVar, valueOfdayOfMonthFrequencyInptVar, valueOfonTheFirstInptVar, valueOfonTheDayOfWeekInptVar, valueOfonTheFrequencyInptVar){        
        component.set("v.showSpinner", true);
        
        var quoteId = component.get("v.quoteId");
        
        var action = component.get("c.submitMonthlyIntervalSpecificNew");
        action.setParams({ 
            qId : quoteId,
            parentQLineId : component.get("v.parentId"),
            dayOfMonth : valueOfdayOfMonthInptVar,
            dayFrequency : valueOfdayOfMonthFrequencyInptVar,
            monthRelativeInterval : valueOfonTheFirstInptVar,
    		monthRelative : valueOfonTheDayOfWeekInptVar,
            relativeFrequency : valueOfonTheFrequencyInptVar,
            radioSelected : valueOfRadioSelected            
            
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var fResult = response.getReturnValue();
                if(fResult==="SUCCESS"){
                    this.updateScreen(component);
                    this.showToast('Success', 'success', 'Record updated Successfully');
                    component.set("v.showSpinner", false);
                    component.set("v.showSIDModal", false);
                }else{
                    this.showToast('Error', 'error', fResult);
                    component.set("v.showSpinner", false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    //SDT-38285 - End
    updateMonthlySpecific: function(component, dOfMonth, freq){
        console.log('line#185');
        component.set("v.showSpinner", true);
        
        var quoteId = component.get("v.quoteId");
        console.log('quoteId==>'+quoteId);
        
        var action = component.get("c.submitMonthlySpecific");
        action.setParams({ 
            qId : quoteId,
            parentQLineId : component.get("v.parentId"),
            dayOfMonth : dOfMonth,
            frequency : freq
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state==>'+state);
            if (state === "SUCCESS") {
                var fResult = response.getReturnValue();
                console.log("fResult==>"+fResult);
                if(fResult=="SUCCESS"){
                    this.updateScreen(component);
                    this.showToast('Success', 'success', 'Record updated Successfully');
                    component.set("v.showSpinner", false);
                    component.set("v.showSIDModal", false);
                }else{
                    this.showToast('Error', 'error', fResult);
                    component.set("v.showSpinner", false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    validateMonthlySelect: function(btnName){
        console.log('line#205')
        if(btnName ==''){
            this.showToast('Alert', 'warning', 'Please select atleast one activity to proceed');
            return false;
        }
        return true;
    },
     //commenting for SDT 31262
    /*weeksValidated: function(everyWeeks){
        //  Added for SDT-24451 change the taost message and added confition to only enter 1 or 2 value.
        //if(everyWeeks< 1 || everyWeeks>= 3 || everyWeeks=='' || everyWeeks==null || isNaN(everyWeeks) || validity.valid == false){
        if(  everyWeeks==null || everyWeeks=='' || !(/^[1-2]*$/.test(everyWeeks))){
            this.showToast('Alert', 'warning', 'Please provide a valid Every__Weeks to proceed \n Enter 1 for every week \n Enter 2 for every other week');
        	return false;
        }
        return true;
    },*/
    //SDT 31262 moving this validation on apex level
    /*serviceDaysValidated: function(selectedWeekDayOption){
        if(selectedWeekDayOption =='' || selectedWeekDayOption==null){
           this.showToast('Alert', 'warning', 'Please provide a Service Days to proceed'); 
            return false;
        }
        return true;
    },*/
    getDailyBtnName: function(component){
        var btnName = component.get("v.dailyEveryDayBtnstate")? 'Daily' : (component.get("v.dailyEveryWeekBtnstate")? 'Weekly' : '');
        if(btnName ==''){
            this.showToast('Alert', 'warning', 'Please select atleast one activity to proceed');
        }
        return btnName;
    },
    getFrequency: function(component){
        const freq = component.get("v.dailyEveryDayFrequency");
        if(freq == '' || freq==null || isNaN(freq)){
            this.showToast('Alert', 'warning', 'Please provide a valid frquency to proceed');
            return '';
        }
        return freq;
    },
    updateDailyEveryDay: function(component, qlineId, freq){
        component.set("v.showSpinner", true);
        
        var quoteId = component.get("v.quoteId");
        console.log('quoteId==>'+quoteId);
        
        var action = component.get("c.submitDailyEveryDay");
        action.setParams({ 
            qId : quoteId,
            parentQLineId : component.get("v.parentId"),
            frequecny : component.get("v.dailyEveryDayFrequency")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state==>'+state);
            if (state === "SUCCESS") {
                var fResult = response.getReturnValue();
                console.log('fResult==>'+fResult);
                if(fResult=="SUCCESS"){
                    this.updateScreen(component);
                    this.showToast('Success', 'success', 'Record updated Successfully');
                    component.set("v.showSpinner", false);
                    component.set("v.showSIDModal", false);
                }else{
                    this.showToast('Error', 'error', fResult);
                    component.set("v.showSpinner", false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    updateDailyEveryWeek: function(component){
        component.set("v.showSpinner", true);
        
        var quoteId = component.get("v.quoteId");
        console.log('quoteId==>'+quoteId);
        
        var action = component.get("c.submitDailyEveryWeek");
        action.setParams({ 
            qId : quoteId,
            parentQLineId : component.get("v.parentId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state==>'+state);
            if (state === "SUCCESS") {
                var fResult = response.getReturnValue();
                console.log('fResult==>'+fResult);
                if(fResult=="SUCCESS"){
                    this.updateScreen(component);
                    this.showToast('Success', 'success', 'Record updated Successfully');
                    component.set("v.showSpinner", false);
                    component.set("v.showSIDModal", false);
                }else{
                    this.showToast('Error', 'error', fResult);
                    component.set("v.showSpinner", false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    updateWeekly: function(component, everyWeeks, selectedWeekDayOption){
        component.set("v.showSpinner", true);
        
        var quoteId = component.get("v.quoteId");
        console.log('quoteId==>'+quoteId);
        
        var action = component.get("c.submitWeekly");
        action.setParams({ 
            qId : quoteId,
            parentQLineId : component.get("v.parentId"),
            frequency : everyWeeks,
            serviceDays : selectedWeekDayOption
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state==>'+state);
            if (state === "SUCCESS") {
                var fResult = response.getReturnValue();
                console.log('fResult==>'+fResult);
                if(fResult=="SUCCESS"){
                    this.updateScreen(component);
                    this.showToast('Success', 'success', 'Record updated Successfully');
                    component.set("v.showSpinner", false);
                    component.set("v.showSIDModal", false);
                }else{
                    this.showToast('Error', 'error', fResult);
                    component.set("v.showSpinner", false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    dailyBtnStateToggle: function(component){
        component.set("v.dailyEveryDayBtnstate", false);
        component.set("v.dailyEveryWeekBtnstate", false);
    },
    monthlyBtnStateToggle: function(component){
        component.set("v.monthlyEveryMonthBtnstate", false);
        component.set("v.monthlySpecificMonthBtnstate", false);
    },
    changeBtnColors: function(component){
        component.find("oncallBtnId").set("v.variant","Neutral");
        component.find("dailyBtnId").set("v.variant","Neutral");
        component.find("weeklyBtnId").set("v.variant","Neutral");
        component.find("monthlyBtnId").set("v.variant","Neutral");
        component.find("YearlyBtnId").set("v.variant","Neutral");
    },
    showToast : function(title, type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: msg,
            key: 'info_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    updateScreen : function(cmp) {
        var CEScreens = cmp.get('v.showSIDModal');
        if (!CEScreens) {
            var updateState = cmp.getEvent('UpdateSummary');
            updateState.setParams({
                "completeChildComponent": true
            });
            updateState.fire();
        }
    },
    prepopulateSchedular : function(cmp, pQline){
        console.log('prepopulateSchedular pQline==>'+JSON.stringify(pQline));
        if(pQline.Occurrence_Type__c){
            console.log('line#398');
            if(pQline.Occurrence_Type__c =='OC'){
                console.log('line#400');
                var onCallBtn = cmp.find("oncallBtnId");
                onCallBtn.set("v.variant","brand");
                cmp.set("v.clickedBtnName",'On Call');
            }else{
                console.log('line#404');
                if(pQline.Schedule_Frequency__c == 'D'){
                    console.log('line#405');
                    var dailyBtn = cmp.find("dailyBtnId");
                    dailyBtn.set("v.variant","brand");
                    cmp.set("v.clickedBtnName",'Daily');
                    if(pQline.Frequency_Interval__c != null){
                        console.log('line#409');
                        cmp.set("v.dailyEveryDayBtnstate",true);
                        cmp.set("v.dailyEveryDayFrequency",pQline.Frequency_Interval__c);
                    }else{
                        console.log('line#414');
                        cmp.set("v.dailyEveryWeekBtnstate",true);
                    }
                }else if(pQline.Schedule_Frequency__c == 'W'){
                    console.log('line#418');
                    var weeklyBtn = cmp.find("weeklyBtnId");
                    weeklyBtn.set("v.variant","brand");
                    cmp.set("v.clickedBtnName",'Weekly');
                    cmp.set("v.everyWeeks",pQline.Frequency_Interval__c);
                    if(pQline.Service_Days__c){
                        console.log('line#423');
                        cmp.set("v.selectedWeekDayOption",pQline.Service_Days__c);
                        let servDays = [];
                        servDays = pQline.Service_Days__c.split(";");
                        cmp.set("v.selectedOptions",servDays);
                        this.setSelectedRadioOptionValue(cmp,pQline.Service_Days__c);
                    }
                }else if(pQline.Schedule_Frequency__c == 'M'){
                    console.log('line#430');
                    var monthlyBtn = cmp.find("monthlyBtnId");
                    monthlyBtn.set("v.variant","brand");
                    cmp.set("v.clickedBtnName",'Monthly');
                    //SDT-38285 - Start - commenting below code as functionality changed
                    /*if(!pQline.Day_of_Month__c){
                        console.log('line#435');
                        cmp.set("v.monthlyEveryMonthBtnstate",true);
                        cmp.set("v.monthlyEveryMonthFrequency",pQline.Frequency_Interval__c);
                    }else{
                        console.log('line#439');
                        cmp.set("v.monthlySpecificMonthBtnstate",true);
                        cmp.set("v.monthlySpecificMonthFrequency",pQline.Frequency_Interval__c);
                        cmp.set("v.monthlySpecificdayOfMonth",pQline.Day_of_Month__c);
                    }*/
                        if(!pQline.Day_of_Month__c && !pQline.Month_Relative_Interval__c && !pQline.Month_Relative__c
                            && pQline.Frequency_Interval__c){
                              cmp.set("v.monthlyEveryMonthBtnstate",true);
                              cmp.set("v.monthlyEveryMonthFrequency",pQline.Frequency_Interval__c);
                              cmp.set("v.radioServiceDateChecked", false);
                              cmp.set("v.radioServiceDayChecked", false);
                          }else
                          if(pQline.Day_of_Month__c && pQline.Frequency_Interval__c
                                && !pQline.Month_Relative_Interval__c && !pQline.Month_Relative__c){
                              cmp.set("v.monthlyEveryMonthBtnstate",false);
                              cmp.set("v.monthlySpecificMonthBtnstate",true);                        
                              cmp.set("v.monthlySpecificdayOfMonth",pQline.Day_of_Month__c);
                              cmp.set("v.monthlySpecificMonthFrequency",pQline.Frequency_Interval__c);
                              cmp.set("v.radioServiceDateChecked", true);
                              cmp.set("v.radioServiceDayChecked", false);
                        cmp.set("v.dayOfMonthInptDisabled",false);
                        cmp.set("v.dayOfMonthFrequencyInptDisabled",false);
                        cmp.set("v.onTheFirstInptDisabled",true);
                        cmp.set("v.onTheDayOfWeekInptDisabled",true);
                        cmp.set("v.onTheFrequencyInptDisabled",true);
                          }else 
                          if(pQline.Month_Relative_Interval__c && pQline.Month_Relative__c && pQline.Frequency_Interval__c
                            && !pQline.Day_of_Month__c){
                              cmp.set("v.monthlyEveryMonthBtnstate",false);
                              cmp.set("v.monthlySpecificMonthBtnstate",true);
                              cmp.set("v.monthRelativeInterval",pQline.Month_Relative_Interval__c);
                              cmp.set("v.monthRelative",pQline.Month_Relative__c);
                              cmp.set("v.monthlySpecificRelativeMonthFrequency",pQline.Frequency_Interval__c);
                              cmp.set("v.radioServiceDateChecked", false);
                              cmp.set("v.radioServiceDayChecked", true);
                        cmp.set("v.dayOfMonthInptDisabled",true);
                        cmp.set("v.dayOfMonthFrequencyInptDisabled",true);
                        cmp.set("v.onTheFirstInptDisabled",false);
                        cmp.set("v.onTheDayOfWeekInptDisabled",false);
                        cmp.set("v.onTheFrequencyInptDisabled",false);
                          }
                          //SDT-38285 - End
                }else if(pQline.Schedule_Frequency__c == 'Y'){
                    console.log('line#445');
                    var YearlyBtn = cmp.find("YearlyBtnId");
                    YearlyBtn.set("v.variant","brand");
                    cmp.set("v.clickedBtnName",'Yearly');
                    cmp.set('v.yearlyBtnstate', true); 
                    cmp.set('v.yearlyFrequency', pQline.Frequency_Interval__c); 
                }
            }
        }
        else{
        	this.changeBtnColors(cmp);    
            cmp.find("oncallBtnId").set("v.variant","brand");
            cmp.set("v.clickedBtnName", 'On Call');
        }
    },
    setSelectedRadioOptionValue : function(cmp, selectedWeekDayOption){
        if(selectedWeekDayOption == 'M;W;F'){
           cmp.set("v.selectedRadioOptionValue", 'MWF'); 
        }else if(selectedWeekDayOption == 'T;T1'){
            cmp.set("v.selectedRadioOptionValue", 'TR');
        }else if(selectedWeekDayOption == 'M;T;W;T1;F'){
            cmp.set("v.selectedRadioOptionValue", 'Weekdays');
        }
    },

    //SDT-21804 moved the dynamic action logic from component.js to helper.js.
    dynamicActionSelection: function(component, event){
        var currBtn = component.get("v.clickedBtnName");
        switch(currBtn) {
            case '':
                this.noButtonClicked();
                break;
            case 'On Call':
                this.onCall(component, event);
                break;
            case 'Daily':
                this.daily(component, event);
                break;
            case 'Weekly':
                this.weekly(component, event);
                break;
            case 'Monthly':
                this.monthly(component, event);
                break;
            case 'Yearly':
                this.yearly(component, event);
                break;
            default:
                // code block
        }
    },
    updateAdditionalServices : function(cmp){
        var action = cmp.get('c.updateAdditionalServices');        
        action.setParams({
            bundleId: cmp.get("v.parentId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    //SDT-29100
    getServiceOverrideReasons :function(cmp){
        if(cmp.get('v.assetAvailabilityAccess')){
            let getPicklists = cmp.get('c.getServiceOverrideReasons');
            getPicklists.setCallback(this, function(response) {
                cmp.set('v.overrideReasonOptions', response.getReturnValue());
            });
            $A.enqueueAction(getPicklists);
        }
    },
    checkServiceDay : function(component){ 
        var selectedOptionValue = component.get("v.selectedOptions");
        let serviceDaysList= component.get('v.serviceDaysList');   //SDT-29100 
        let assetCheck = component.get("v.assetAvailabilityAccess"); //SDT-29100 
        let serviceStatus = component.get("v.serviceStatus"); 
        let selectedUnavailableDays;
        var fOption = '';
        let flag=false; //SDT-29100 
        for(var i = 0; i < selectedOptionValue.length; i++){          
            if(fOption==''){
                fOption = selectedOptionValue[i];
            }else{
                fOption = fOption+';'+selectedOptionValue[i];
            }
            //SDT-29100 :START
            if (assetCheck && serviceDaysList.includes(selectedOptionValue[i])===false)
            {
                flag=true;
                selectedUnavailableDays = selectedUnavailableDays 
                            ? selectedUnavailableDays + ';' + selectedOptionValue[i] 
                            : selectedOptionValue[i];
            }  
            //END         
        }
        //SDT-29100 :START
        if(assetCheck){
            
            if(serviceStatus != 'WM NOT available to Service in the area' &&
            serviceStatus !='Availability could not be confirmed as there is no response from the API'){//SDT-31583
                component.set('v.showOverrideDetails',(serviceDaysList.length && flag));//SDT-31583
                let tempStatus = flag ? 
                            'Selected Service is NOT as per WM Availability' : 
                            'Selected Service is as per WM Availability';
                component.set('v.serviceStatus',tempStatus);
            } 
            component.set("v.selectedUnavailableDays",selectedUnavailableDays);
        }
        //END
        component.set("v.selectedWeekDayOption",fOption);
    },
    //SDT-31583
    updateAssetErrorMsg :function(cmp,errorList,showAssetAPIButton){
        cmp.set("v.classAssetAPIErrors",errorList.length === 1 ?
                 'warning-text-single' : 'warning-text-list');
        cmp.set("v.msgAssetAPIErrors",errorList);
        cmp.set("v.showAssetAPIError",true);
        cmp.set("v.showAssetAPIButton",showAssetAPIButton);
    },   
    //SDT-31583
    handleAvailabilityResponse: function(component,response){
        let serviceDaysList=[];
        //SDT-31583
        let apiFailedError = ['Availability could not be confirmed as there is no response from the API. '
                            +'Please retry by clicking on the "Get Availability" button'];
        let wmNotAvailableLabel = "WM NOT available to Service in the area";
        let serviceDaysErrorMsg = 'No WM service day information is available for this location';
        //let apiErroredOutMsg = 'Availability API Errored out';
        let apiErroredOutMsg = 'Availability could not be confirmed as there is no response from the API';
        let serviceDays = [];
        const weekdays={
            'MONDAY':{label:'Monday', value:'M'},
            'TUESDAY':{label:'Tuesday', value:'T'},
            'WEDNESDAY':{label:'Wednesday', value:'W'},
            'THURSDAY':{label:'Thursday', value:'T1'},
            'FRIDAY':{label:'Friday', value:'F'},
            'SATURDAY':{label:'Saturday', value:'S'},
            'SUNDAY':{label:'Sunday', value:'S1'},
        }
        let errormsg = "";
        let responseData = response.getReturnValue();
        if(response.getState() === "SUCCESS" && responseData.AAV_isAPIResult__c) {
            try {
                let assetAvailabilityData = JSON.parse(responseData.AAV_APIRequestOutput__c);
                //SDT-31609 :changes added for deliveries check
                let supplier = assetAvailabilityData.data && Array.isArray(assetAvailabilityData.data.suppliers) ?
                                        assetAvailabilityData.data.suppliers[0] : false;
                //SDT-31583
                if(supplier){
                    if(supplier.serviceDays && supplier.serviceDays.length){
                        serviceDays = supplier.serviceDays;
                        serviceDays = serviceDays ? serviceDays.map(ele => ele.toUpperCase()) : [];     
                    }
                    else {
                        let checkDeliveries = Array.isArray(supplier.deliveries) && supplier.deliveries.length;
                        let supplierMessage = Array.isArray(supplier.messages) && supplier.messages.length;
                        let serviceErrorMsg = (!supplier.deliveryDays && !checkDeliveries && supplierMessage) 
                                                ? supplier.messages.map(x=>x.description) : [serviceDaysErrorMsg];   
                        this.updateAssetErrorMsg(component,serviceErrorMsg,false);
                        if(!supplier.deliveryDays){
                            component.set("v.serviceStatus", !checkDeliveries ? wmNotAvailableLabel :apiErroredOutMsg);
                            // component.set("v.assetAvailabilityError",!checkDeliveries && supplierMessage 
                            //             ? supplier.messages.map(x=>x.description).join(', '):apiErroredOutMsg);
                        } 
                    }
                }
                else if(Array.isArray(assetAvailabilityData.data.messages) && assetAvailabilityData.data.messages.length){
                    let responseErrors =assetAvailabilityData.data.messages.map(x=>x.description);
                    this.updateAssetErrorMsg(component,responseErrors,false); 
                    component.set("v.serviceStatus", wmNotAvailableLabel);
                   // component.set("v.assetAvailabilityError",responseErrors.join(', '));
                }
                else if(assetAvailabilityData.problem){
                    errormsg = assetAvailabilityData.problem;
                } 
                else {
                    component.set("v.serviceStatus", wmNotAvailableLabel);
                }
            } catch (error) {
                errormsg = error;
            }
        } else {
            errormsg =  response.getState() === "ERROR" ? response.getError() : apiErroredOutMsg;
        }
        if (errormsg) {
            this.updateAssetErrorMsg(component,apiFailedError,true);//SDT-31583
            component.set("v.serviceStatus", apiErroredOutMsg);
            //component.set("v.assetAvailabilityError",apiErroredOutMsg);
            console.error("getAvailabilityResponse=>", errormsg);
        }
        let styleElement = document.createElement("style");
        for(let days of Object.keys(weekdays)){
            let cssRule;
            if(serviceDays.includes(days)){
                serviceDaysList.push(weekdays[days.toUpperCase()].value);
                cssRule = document.createTextNode("div[data-value='"+weekdays[days.toUpperCase()].value+"'] {background-color :#A4b66e }");  
            }
            else{
                cssRule = document.createTextNode("div[data-value='"+weekdays[days.toUpperCase()].value+"'] {background-color :white }");
            }
            styleElement.appendChild(cssRule);
        }
        document.head.appendChild(styleElement);
        component.set("v.serviceDaysList", serviceDaysList);
        this.checkServiceDay(component);//SDT-31295
    },
    //SDT-38285 - start - fetch Both picklist values
    getMonthRelativePickList : function(cmp){
        var getPicklists = cmp.get('c.getMonthRelatedPickLists');
        getPicklists.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS"){
                	var returnVal = response.getReturnValue();
                    for (var entry in returnVal) { 
                        var pickListVal = [];
                        var valuesOfPickList = returnVal[entry];
                        for(var e in valuesOfPickList){
                            pickListVal.push({value:valuesOfPickList[e], key:e});    
                        }
                        cmp.set('v.'+entry,pickListVal);                        	
                        }                    
                    }                
            });
            $A.enqueueAction(getPicklists);
    },
  /*  getMonthRelativeInterval :function(cmp){        
        var getPicklists = cmp.get('c.getMonthRelativeInterval');
        getPicklists.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                var monthRelativeIntervalList = [];
                var returnVal = response.getReturnValue();
                for (var entry in returnVal) {
                        monthRelativeIntervalList.push({value:returnVal[entry], key:entry});
                        cmp.set('v.monthRelativeIntervalList', monthRelativeIntervalList);
                    }
                }                
        });
        $A.enqueueAction(getPicklists);
    
},
getMonthRelative :function(cmp){        
        var getPicklists = cmp.get('c.getMonthRelative');
        getPicklists.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                var monthRelativeList = [];
                var returnVal = response.getReturnValue();
                for (var entry in returnVal) {
                        monthRelativeList.push({value:returnVal[entry], key:entry});
                        cmp.set('v.monthRelativeList', monthRelativeList);
                    }
                }                
        });
        $A.enqueueAction(getPicklists);        
},*/
setEnabledDisabled : function (cmp,radioServiceDayChecked){
     cmp.set('v.radioServiceDayChecked', radioServiceDayChecked);
    cmp.set('v.radioServiceDateChecked', !radioServiceDayChecked);
        cmp.set("v.dayOfMonthInptDisabled",radioServiceDayChecked);
        cmp.set("v.dayOfMonthFrequencyInptDisabled",radioServiceDayChecked);
        cmp.set("v.onTheFirstInptDisabled",!radioServiceDayChecked);
        cmp.set("v.onTheDayOfWeekInptDisabled",!radioServiceDayChecked);
        cmp.set("v.onTheFrequencyInptDisabled",!radioServiceDayChecked);
}
//SDT-38285 - end
})