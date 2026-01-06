({
    //Handler for the every day stateful button
    handleEDClick : function(cmp, event, helper) {
        helper.defaultValues(cmp);
        var EDbuttonstate = cmp.get('v.EDbuttonstate');
        var EWDbuttonstate = cmp.get('v.EWDbuttonstate');
        if (EWDbuttonstate===true && EDbuttonstate===false) {
        	cmp.set('v.EDbuttonstate', !EDbuttonstate);
            cmp.set('v.EWDbuttonstate', !EWDbuttonstate);
        } else {
            cmp.set('v.EDbuttonstate', !EDbuttonstate);
        }
    },
    //Handler for the every weekday stateful button
    handleEWDClick : function(cmp, event, helper) {
        helper.defaultValues(cmp);
        var EDbuttonstate = cmp.get('v.EDbuttonstate');
        var EWDbuttonstate = cmp.get('v.EWDbuttonstate');
        if (EDbuttonstate===true && EWDbuttonstate===false) {
        	cmp.set('v.EDbuttonstate', !EDbuttonstate);
            cmp.set('v.EWDbuttonstate', !EWDbuttonstate);
        } else {
            cmp.set('v.EWDbuttonstate', !EWDbuttonstate);
        }
    },
    //Commit Daily Selections
    handleDSubmit : function (cmp, event, helper) {
        var EDbuttonstate = cmp.get('v.EDbuttonstate');
        var EWDbuttonstate = cmp.get('v.EWDbuttonstate');
        var dailyFreq = cmp.get('v.DailyFreq');
        if (EDbuttonstate===false && EWDbuttonstate===false) {
            alert("Please make at least one selection before pressing submit");
        } else if (EDbuttonstate===true) {
            if (dailyFreq===1) {
                cmp.set('v.occurrenceCode', 'Daily');
                cmp.set('v.frequency', dailyFreq);
                helper.allDays(cmp);
                cmp.set('v.FrequencyNote', 'This container will be serviced every day');
                cmp.set('v.frequencyGroup', 'Daily');
                cmp.set('v.servicePerFreq', parseFloat(1/dailyFreq).toFixed(2));
                cmp.set('v.fullyConfigured', true);
                alert("Daily service configured!");
            } else {
                cmp.set('v.occurrenceCode', 'Daily');
                cmp.set('v.frequency', dailyFreq);
                cmp.set('v.FrequencyNote', 'This container will be serviced once every ' + dailyFreq + ' days.');
                cmp.set('v.frequencyGroup', 'Daily');
                cmp.set('v.servicePerFreq', parseFloat(1/dailyFreq).toFixed(2));
                cmp.set('v.fullyConfigured', true);
                alert("Daily service configured!");
            }
        } else if (EWDbuttonstate===true) {
            cmp.set('v.occurrenceCode', 'Weekly');
            cmp.set('v.frequency', 1);
            helper.weekdaysOnly(cmp);
            cmp.set('v.FrequencyNote', 'This container will be serviced every week day');
            cmp.set('v.frequencyGroup', 'Weekly');
            cmp.set('v.servicePerFreq', "5");
            cmp.set('v.fullyConfigured', true);
            alert("Daily service configured!");
        }
    },
    handleWClick : function (cmp, event, helper) {
        var Wbuttonstate = cmp.get('v.Wbuttonstate');
        helper.defaultValues(cmp);
        cmp.set('v.Wbuttonstate', !Wbuttonstate);
    },
    handleSuClick : function (cmp, event, helper) {
        var SUbuttonstate = cmp.get('v.chkSunday');
        if (SUbuttonstate===false){
            var daysSelected = cmp.get('v.numDaysSelected')+1;
        }
        else {
            var daysSelected = cmp.get('v.numDaysSelected')-1;
        }
        cmp.set('v.chkSunday', !SUbuttonstate);
        cmp.set('v.numDaysSelected', daysSelected);
    },
    handleMoClick : function (cmp, event, helper) {
        var MObuttonstate = cmp.get('v.chkMonday');
        if (MObuttonstate===false){
            var daysSelected = cmp.get('v.numDaysSelected')+1;
        }
        else {
            var daysSelected = cmp.get('v.numDaysSelected')-1;
        }
        cmp.set('v.chkMonday', !MObuttonstate);
        cmp.set('v.numDaysSelected', daysSelected);
    },
    handleTuClick : function (cmp, event, helper) {
        var TUbuttonstate = cmp.get('v.chkTuesday');
        if (TUbuttonstate===false){
            var daysSelected = cmp.get('v.numDaysSelected')+1;
        }
        else {
            var daysSelected = cmp.get('v.numDaysSelected')-1;
        }
        cmp.set('v.chkTuesday', !TUbuttonstate);
        cmp.set('v.numDaysSelected', daysSelected);
    },
    handleWEClick : function (cmp, event, helper) {
        var WEbuttonstate = cmp.get('v.chkWednesday');
        if (WEbuttonstate===false){
            var daysSelected = cmp.get('v.numDaysSelected')+1;
        }
        else {
            var daysSelected = cmp.get('v.numDaysSelected')-1;
        }
        cmp.set('v.chkWednesday', !WEbuttonstate);
        cmp.set('v.numDaysSelected', daysSelected);
    },
    handleTHClick : function (cmp, event, helper) {
        var THbuttonstate = cmp.get('v.chkThursday');
        if (THbuttonstate===false){
            var daysSelected = cmp.get('v.numDaysSelected')+1;
        }
        else {
            var daysSelected = cmp.get('v.numDaysSelected')-1;
        }
        cmp.set('v.chkThursday', !THbuttonstate);
        cmp.set('v.numDaysSelected', daysSelected);
    },
    handleFRClick : function (cmp, event, helper) {
        var FRbuttonstate = cmp.get('v.chkFriday');
        if (FRbuttonstate===false){
            var daysSelected = cmp.get('v.numDaysSelected')+1;
        }
        else {
            var daysSelected = cmp.get('v.numDaysSelected')-1;
        }
        cmp.set('v.chkFriday', !FRbuttonstate);
        cmp.set('v.numDaysSelected', daysSelected);
    },
    handleSAClick : function (cmp, event, helper) {
        var SAbuttonstate = cmp.get('v.chkSaturday');
        if (SAbuttonstate===false){
            var daysSelected = cmp.get('v.numDaysSelected')+1;
        }
        else {
            var daysSelected = cmp.get('v.numDaysSelected')-1;
        }
        cmp.set('v.chkSaturday', !SAbuttonstate);
        cmp.set('v.numDaysSelected', daysSelected);
    },
    handleSUClick : function (cmp, event, helper) {
        var SUbuttonstate = cmp.get('v.chkSunday');
        if (SUbuttonstate===false){
            var daysSelected = cmp.get('v.numDaysSelected')+1;
        }
        else {
            var daysSelected = cmp.get('v.numDaysSelected')-1;
        }
        cmp.set('v.chkSunday', !SUbuttonstate);
        cmp.set('v.numDaysSelected', daysSelected);
    },
    handleWSubmit : function (cmp, event, helper) {
        var Wbuttonstate = cmp.get('v.Wbuttonstate');
        var weekNums = cmp.get('v.WeekNums');
        var weekFreq = cmp.get('v.WeeklyFreq');
        var daysSelected = cmp.get('v.numDaysSelected');
        if (Wbuttonstate ===false) {
            alert("Please select the weekly button to confirm");
        } else if (daysSelected != weekFreq) {
            alert("You have selected a weekly frequency of " + weekFreq + " but have only selected " +
                 daysSelected + " days.  Please review your selections.")
        } else if (weekNums>1 && weekFreq>1) {
            alert("When the number of weeks between services is greater than 1, the frequency should be set to 1");
        } else if (Wbuttonstate ===true) {
            cmp.set('v.occurrenceCode', 'Weekly');
            cmp.set('v.frequency', weekNums)
            cmp.set('v.FrequencyNote', 'This container will be serviced ' + weekFreq + ' time(s) every ' + weekNums + ' week(s)');
            cmp.set('v.frequencyGroup', 'Weekly');
            cmp.set('v.servicePerFreq', parseFloat(weekFreq/weekNums).toFixed(2));
            cmp.set('v.fullyConfigured', true);
            alert("Weekly service configured!");
        }
    },
    handleEMClick : function (cmp, event, helper) {
        var EMbuttonstate = cmp.get('v.EMbuttonstate');
        var SMDbuttonstate = cmp.get('v.SMDbuttonstate');
        var SWMbuttonstate = cmp.get('v.SWMbuttonstate');
        if (SMDbuttonstate === true && EMbuttonstate === false) {
        	cmp.set('v.SMDbuttonstate', false);
        }
        if (SWMbuttonstate === true && EMbuttonstate === false) {
        	cmp.set('v.SWMbuttonstate', false);
        }
        cmp.set('v.EMbuttonstate', !EMbuttonstate);
    },
    handleSMDClick : function (cmp, event, helper) {
        var EMbuttonstate = cmp.get('v.EMbuttonstate');
        var SMDbuttonstate = cmp.get('v.SMDbuttonstate');
        var SWMbuttonstate = cmp.get('v.SWMbuttonstate');
        if (SWMbuttonstate === true && SMDbuttonstate === false) {
        	cmp.set('v.SWMbuttonstate', false);
        }
        if (EMbuttonstate === true && SMDbuttonstate === false) {
        	cmp.set('v.EMbuttonstate', false);
        }
        cmp.set('v.SMDbuttonstate', !SMDbuttonstate);
    },
    handleSWMClick : function (cmp, event, helper) {
        var EMbuttonstate = cmp.get('v.EMbuttonstate');
        var SMDbuttonstate = cmp.get('v.SMDbuttonstate');
        var SWMbuttonstate = cmp.get('v.SWMbuttonstate');
        if (SMDbuttonstate === true && SWMbuttonstate === false) {
        	cmp.set('v.SMDbuttonstate', false);
        }
        if (EMbuttonstate === true && SWMbuttonstate === false) {
        	cmp.set('v.EMbuttonstate', false);
        }
        cmp.set('v.SWMbuttonstate', !SWMbuttonstate);
    },
    handleMSubmit : function (cmp, event, helper) {
        var SWMbuttonstate = cmp.get('v.SWMbuttonstate');
		var SMDbuttonstate = cmp.get('v.SMDbuttonstate');
		var EMbuttonstate = cmp.get('v.EMbuttonstate');
		var monthlyFreq = cmp.get('v.MonthlyFreq');
		if (EMbuttonstate===true) {
			cmp.set('v.occurrenceCode', 'Monthly');
			cmp.set('v.frequency', monthlyFreq);
			cmp.set('v.FrequencyNote', 'Service will be provided every ' + monthlyFreq + ' month(s)');
			cmp.set('v.frequencyGroup', 'Monthly');
			cmp.set('v.servicePerFreq', parseFloat(1/monthlyFreq).toFixed(2));
			cmp.set('v.fullyConfigured', true);
			alert("Monthly service configured!");
		} else if (SMDbuttonstate===true) {
			var specificSelectedDayNum = cmp.get('v.SpecificDayMonthFreq');
			cmp.set('v.occurrenceCode', 'Monthly');
			cmp.set('v.frequency', monthlyFreq);
			cmp.set('v.FrequencyNote', 'Service will be provided on the ' + specificSelectedDayNum + ' day of every ' + monthlyFreq + ' month(s)');
			cmp.set('v.frequencyGroup', 'Monthly');
			cmp.set('v.servicePerFreq', parseFloat(1/monthlyFreq).toFixed(2));
			cmp.set('v.fullyConfigured', true);
			alert("Monthly service configured!");
		} else if (SWMbuttonstate===true) {
			var cmpMonthNumber = cmp.find('OnTheMonthNumber');
			var cmpMonthType = cmp.find('OnTheMonthType');
			var monthNumber = cmpMonthNumber.get('v.value');
			var monthType = cmpMonthType.get('v.value');
			cmp.set('v.occurrenceCode', 'Monthly');
			cmp.set('v.frequency', monthlyFreq);
			cmp.set('v.FrequencyNote', 'Service will be provided on the ' + monthNumber + ' ' + monthType + ' of every ' + monthlyFreq + ' month(s)');
			cmp.set('v.frequencyGroup', 'Monthly');
			cmp.set('v.servicePerFreq', parseFloat(1/monthlyFreq).toFixed(2));
			cmp.set('v.fullyConfigured', true);
			alert("Monthly service configured!");
		}
    },
    handleEYClick : function (cmp, event, helper) {
        var EYbuttonstate  = cmp.get('v.EYbuttonstate');
        var SMDYbuttonstate  = cmp.get('v.SMDYbuttonstate');
        var SRMYbuttonstate  = cmp.get('v.SRMYbuttonstate');
        if (SMDYbuttonstate === true && EYbuttonstate === false) {
        	cmp.set('v.SMDYbuttonstate', false);
        }
        if (SRMYbuttonstate === true && EYbuttonstate === false) {
        	cmp.set('v.SRMYbuttonstate', false);
        }
        cmp.set('v.EYbuttonstate', !EYbuttonstate);
    },
    handleSMDYClick : function (cmp, event, helper) {
        var EYbuttonstate  = cmp.get('v.EYbuttonstate');
        var SMDYbuttonstate  = cmp.get('v.SMDYbuttonstate');
        var SRMYbuttonstate  = cmp.get('v.SRMYbuttonstate');
        if (EYbuttonstate === true && SMDYbuttonstate === false) {
        	cmp.set('v.EYbuttonstate', false);
        }
        if (SRMYbuttonstate === true && SMDYbuttonstate === false) {
        	cmp.set('v.SRMYbuttonstate', false);
        }
        cmp.set('v.SMDYbuttonstate', !SMDYbuttonstate);
    },
    handleSRMYClick : function (cmp, event, helper) {
        var EYbuttonstate  = cmp.get('v.EYbuttonstate');
        var SMDYbuttonstate  = cmp.get('v.SMDYbuttonstate');
        var SRMYbuttonstate  = cmp.get('v.SRMYbuttonstate');
        if (EYbuttonstate === true && SRMYbuttonstate === false) {
        	cmp.set('v.EYbuttonstate', false);
        }
        if (SMDYbuttonstate === true && SRMYbuttonstate === false) {
        	cmp.set('v.SMDYbuttonstate', false);
        }
        cmp.set('v.SRMYbuttonstate', !SRMYbuttonstate);
    },
    handleYSubmit : function (cmp, event, helper) {
		var EYbuttonstate = cmp.get('v.EYbuttonstate');
		var SMDYbuttonstate = cmp.get('v.SMDYbuttonstate');
		var SRMYbuttonstate = cmp.get('v.SRMYbuttonstate');
		var yearlyFreq = cmp.get('v.YearlyFreq');
		if (EYbuttonstate===true) {
			cmp.set('v.occurrenceCode', 'Yearly');
			cmp.set('v.frequency', yearlyFreq);
			cmp.set('v.FrequencyNote', 'Service will be provided every ' + yearlyFreq + ' year(s)');
			cmp.set('v.frequencyGroup', 'Yearly');
			cmp.set('v.servicePerFreq', 1);
			cmp.set('v.fullyConfigured', true);
			alert("Yearly service configured!");
		} else if (SMDYbuttonstate===true) {
			//var cmpYearSpecificMonth = cmp.find('YearSpecificMonth');
			//var YearSpecificMonth = cmpYearSpecificMonth.get('v.value');
			var YearlyDayNum = cmp.get('YearlyDayNum');
			cmp.set('v.occurrenceCode', 'Yearly');
			cmp.set('v.frequency', 1);
			//cmp.set('v.FrequencyNote', 'Service will be provided yearly on the ' + YearSpecificMonth + ' ' + YearlyDayNum );
			cmp.set('v.frequencyGroup', 'Yearly');
			cmp.set('v.servicePerFreq', 1);
			cmp.set('v.fullyConfigured', true);
			alert("Yearly service configured!");
		} else if (SRMYbuttonstate===true) {
			var cmpYearSpecificTypeofDay = cmp.find('YearSpecificTypeofDay');
			var cmpYearSpecificDay = cmp.find('YearSpecificDay');
			//var cmpYearSpecificMonth = cmp.find('YearSpecificMonth');
			var YearSpecificTypeofDay = cmpYearSpecificTypeofDay.get('v.value');
			var YearSpecificDay = cmpYearSpecificDay.get('v.value');
			//var YearSpecificMonth = cmpYearSpecificMonth.get('v.value');
			cmp.set('v.occurrenceCode', 'Yearly');
			cmp.set('v.frequency', 1);
			cmp.set('v.FrequencyNote', 'Service will be provided yearly on the ' + YearSpecificTypeofDay + ' ' + YearSpecificDay + ' of ' );
			cmp.set('v.frequencyGroup', 'Yearly');
			cmp.set('v.servicePerFreq', 1);
			cmp.set('v.fullyConfigured', true);
			alert("Yearly service configured!");
		}
	},
    handleWeekdaysClick : function(cmp, event, helper) {
        var chkWeekdays = cmp.get('v.chkWeekdays');
        cmp.set('v.chkMWF', false);
        cmp.set('v.chkTR', false);
        if (chkWeekdays === false) {
            helper.defaultValues(cmp) ;
            cmp.set('v.WeeklyFreq', 5);
            cmp.set('v.chkMonday', true);
            cmp.set('v.chkTuesday', true);
            cmp.set('v.chkWednesday', true);
            cmp.set('v.chkThursday', true);
            cmp.set('v.chkFriday',true);
            cmp.set('v.numDaysSelected', 5);
            cmp.set('v.chkWeekdays', !chkWeekdays);
        } else {
            helper.defaultValues(cmp);
            cmp.set('v.chkWeekdays', !chkWeekdays);
        }
    },
        handleTRClick : function(cmp, event, helper) {
        var chkTR = cmp.get('v.chkTR');
        cmp.set('v.chkWeekdays', false);
        cmp.set('v.chkMWF', false);
        if (chkTR === false) {
            helper.defaultValues(cmp) ;
            cmp.set('v.WeeklyFreq', 2);
            cmp.set('v.chkTuesday', true);
            cmp.set('v.chkThursday', true);
            cmp.set('v.numDaysSelected', 2);
            cmp.set('v.chkTR', !chkTR);
        } else {
            helper.defaultValues(cmp);
            cmp.set('v.chkTR', !chkTR);
        }
    },
    handleMWFClick : function(cmp, event, helper) {
        var chkMWF = cmp.get('v.chkMWF');
        cmp.set('v.chkWeekdays', false);
        cmp.set('v.chkTR', false);
        if (chkMWF === false) {
            helper.defaultValues(cmp) ;
            cmp.set('v.WeeklyFreq', 3);
            cmp.set('v.chkMonday', true);
            cmp.set('v.chkWednesday', true);
            cmp.set('v.chkFriday',true);
            cmp.set('v.numDaysSelected', 3);
            cmp.set('v.chkMWF', !chkMWF);
        } else {
            helper.defaultValues(cmp);
            cmp.set('v.chkMWF', !chkMWF);
        }
    },
})