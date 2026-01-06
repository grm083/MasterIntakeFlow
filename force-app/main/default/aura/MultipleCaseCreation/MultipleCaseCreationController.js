({
    loadJquery : function(component, event, helper) {
        var SelectedDate = [];
        var arr = [];
        jQuery(document).ready(function(){
            var maxLength = 100;
            $('textarea').keyup(function() {
                var length = $(this).val().length;
                var length = maxLength-length;
                $('#chars').text(length);
            });
			jQuery('#multiple-date-select').multiDatesPicker({
          onSelect: function(datetext) {
            let table = $('#table-data');
            let rowLast = table.data('lastrow');
            let rowNext = rowLast + 1;
            let r = table.find('tr').filter(function() {
              return ($(this).data('date') == datetext);
            }).eq(0);
            // a little redundant checking both here 
            if (!!r.length && arr.includes(datetext)) {
              removeRow(datetext);
              r.remove();
            } else {
              // not found so add it
              let col = $('<td></td>').html(datetext);
              let row = $('<tr></tr>');
              row.data('date', datetext);
              row.attr('id', 'newrow' + rowNext);
              row.append(col).appendTo(table);
              table.data('lastrow', rowNext);
              arr.push(datetext);
            }
              component.set("v.selectedDate",arr);
              //alert(' Select date '+ component.get("v.selectedDate"));
          } 
        });
            
        // set start, first row will be 0 could be in markup
        $('#table-data').data('lastrow', -1);
        });               
    },
    
    createCase : function(component, event, helper) {        
        helper.createMultipleCases(component, event, helper);
    },
    
    fetchListOfRecordTypes : function(component, event, helper) {        
        helper.callRecType(component, event, helper);
    },
    
    closeModal: function(component, event, helper) {
      // set "isOpen" attribute to false for hide/close model box 
      component.set("v.isOpen", false);
   },
 
   openModal: function(component, event, helper) {
      // set "isOpen" attribute to true to show model box
      component.set("v.isOpen", true);
   }
    
})