({
	defaultValues : function(cmp) {
		cmp.set('v.chkSunday', false);
        cmp.set('v.chkMonday', false);
        cmp.set('v.chkTuesday', false);
        cmp.set('v.chkWednesday', false);
        cmp.set('v.chkThursday', false);
        cmp.set('v.chkFriday', false);
        cmp.set('v.chkSaturday', false);
        cmp.set('v.numDaysSelected', 0);
	},
    allDays : function(cmp) {
        cmp.set('v.chkSunday', true);
        cmp.set('v.chkMonday', true);
        cmp.set('v.chkTuesday', true);
        cmp.set('v.chkWednesday', true);
        cmp.set('v.chkThursday', true);
        cmp.set('v.chkFriday', true);
        cmp.set('v.chkSaturday', true);
        cmp.set('v.numDaysSelected', 7);
    },
    weekdaysOnly : function(cmp) {
        cmp.set('v.chkSunday', false);
        cmp.set('v.chkMonday', true);
        cmp.set('v.chkTuesday', true);
        cmp.set('v.chkWednesday', true);
        cmp.set('v.chkThursday', true);
        cmp.set('v.chkFriday', true);
        cmp.set('v.chkSaturday', false);
        cmp.set('v.numDaysSelected', 5);
    },
    disableButtons : function(cmp) {
        let DailyButton = component.find("dailyButton");
        let WeeklyButton = component.find("weeklyButton");
        DailyButton.set('v.disabled',true);
        WeeklyButton.set('v.disabled',true);
    }
})