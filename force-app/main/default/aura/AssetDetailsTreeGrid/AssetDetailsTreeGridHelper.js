({
    getAssetRecords : function (cmp) {
        var action = cmp.get("c.getAssetRecords");
        action.setParams({
            "locationRecordId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.assetRecordCount",data.length);
                console.log('REPONSE'  + JSON.stringify(data));
                for(var i=0; i<data.length; i++) {
                    data[i].assName = '/'+data[i].Id ;
                    //added by av4 on 11/01/2024
                    if(data[i].Supplier__c != null && data[i].Supplier__c !== '') {
                        data[i].vendorName = data[i].Supplier__r.Name ;
                        data[i].vendorRecordId = '/'+ data[i].Supplier__c ;
                    }
                    data[i]._children = data[i]['ChildAssets'];
                    delete data[i].ChildAssets;
                }
                //   console.log('DAS'  + JSON.stringify(data));
                data.forEach(function(record){
                    var childRecords = record._children ;
                    childRecords.forEach(function(record){
                        record.assName = '/'+record.Id ;
                        //added by av4 on 11/01/2024
                        if(record.Supplier__c != null && record.Supplier__c !== '') {
                            record.vendorName = record.Supplier__r.Name ;
                            record.vendorRecordId = '/'+record.Supplier__c ;
                            //data[i].vendorName = data[i].Supplier__r.Name ;
                        }
                    });
                });
                cmp.set('v.allRecordGridData',data);
                
                cmp.set("v.totalRecords", data.length);
                cmp.set("v.startPage",0);
                var pageSize = cmp.get("v.pageSize");
                cmp.set("v.endPage",pageSize);
                 var PaginationList = [];
               
                for(var i=0; i< pageSize; i++){
                    if(cmp.get("v.allRecordGridData").length> i)
                        PaginationList.push(response.getReturnValue()[i]); 
                   
                }
                  cmp.set('v.gridData',PaginationList);
                  cmp.set("v.showSpinnerOnPageChange",false );
                  cmp.set("v.showDataTable",true );
            }
        });
        $A.enqueueAction(action);
    },
     next : function(cmp, event){
         cmp.set("v.showDataTable",false );
         cmp.set("v.showSpinnerOnPageChange",true );
        var sObjectList = cmp.get("v.allRecordGridData");
        var end = cmp.get("v.endPage");
        var start = cmp.get("v.startPage");
        var pageSize = cmp.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end; i<end+pageSize; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        cmp.set("v.startPage",start);
        cmp.set("v.endPage",end);
        cmp.set('v.gridData', Paginationlist);
          cmp.set("v.showSpinnerOnPageChange",false );
         cmp.set("v.showDataTable",true );
    },
     previous : function(cmp, event){
         cmp.set("v.showSpinnerOnPageChange",true );
                   cmp.set("v.showDataTable",false );
        var sObjectList = cmp.get("v.allRecordGridData");
        var end = cmp.get("v.endPage");
        var start = cmp.get("v.startPage");
        var pageSize = cmp.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        cmp.set("v.startPage",start);
        cmp.set("v.endPage",end);
          cmp.set("v.showSpinnerOnPageChange",false );
        cmp.set('v.gridData', Paginationlist);
        
          cmp.set("v.showDataTable",true );
    }
})