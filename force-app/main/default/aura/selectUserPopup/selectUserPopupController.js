({
    doInit: function(component, event, helper){
        //component.set('v.isRowSelected', true);  
    },
    
	reassignButtonClick : function(component, event, helper) {
      component.set('v.showHide', component.get('v.isRowSelected'));   
		
	},
    
     closeModel: function(component, event, helper) {
     component.set('v.showHide', false);
   },
    
     assignuser: function(component, event, helper) {
      alert('User Assigned ');
      
   }
})