({
	getEmail : function(component, event, helper) {
        component.set("v.Message",false);
		var action = component.get("c.getEmailList");
        var recordId = component.get("v.recordId");
        action.setParams({
            "recordId" : recordId
        });
         action.setCallback(this,function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            //alert('rsp==='+JSON.stringify(JSON.parse(resp)));
           
            if(state == 'SUCCESS'){
                if(resp != null && resp != '' && resp != undefined){
                    var opts = [];
                    opts = JSON.parse(resp);
						
                    for(var i = 0; i < opts.length; i++)
                    {
                        //Change done for SDT-21278 -- Start
                        if(opts[i].RelatedToId)
                        {
                            if(recordId.substring(0,3) == '500'){
                                opts[i]["MessageId"] = 'CE' + opts[i].Id + opts[i].RelatedToId + recordId;
                            }
                            else{
                                opts[i]["MessageId"] = 'QE' + opts[i].Id + opts[i].RelatedToId + recordId;
                            }
                        }
                        //Change done for SDT-21278 -- Start
                        if(opts[i].HtmlBody){
                            //opts[i].HtmlBody = opts[i].HtmlBody.replace('/\"/g', '\\"');
                            //opts[i].HtmlBody = escape(opts[i].HtmlBody);  
                            opts[i].HtmlBody = opts[i].HtmlBody.replace(/<\/?BASE[^>]*>/g, "");
                            //sdt-40032
                            opts[i].HtmlBody = opts[i].HtmlBody.replace('\n\x3C!--\ndiv', '\n\x3C!--');
                            let pattern = /<!--[\s\S]*?-->/g;
                            opts[i].HtmlBody = opts[i].HtmlBody.replaceAll(pattern, '<!---->');	
                            
                             //sdt-40032
                            
							//Added by Mudit Chaturvedi for SDT-13733 - Start
							var baseStartTagIndex,baseEndTagIndex;
                            if(opts[i].HtmlBody.indexOf("<base") > -1)
                            {
                                var indx = opts[i].HtmlBody.indexOf("<base");
                                baseStartTagIndex = indx;
                                while(opts[i].HtmlBody[indx] != '>')
                                {
                                    baseEndTagIndex = indx + 2;
                                    indx++;
                                }
                                opts[i].HtmlBody = opts[i].HtmlBody.substring(0, baseStartTagIndex ) + opts[i].HtmlBody.substring( baseEndTagIndex, opts[i].HtmlBody.length);
                            }
                            //Added by Mudit Chaturvedi for SDT-13733 - End
                                    var styleTagStartIndex  = opts[i].HtmlBody.indexOf("<style>");
									if(styleTagStartIndex == -1)
                                    {
                                        styleTagStartIndex = opts[i].HtmlBody.indexOf("<style type=\"text/css\">");
                                    }
									if(styleTagStartIndex == -1)
                                    {
                                        styleTagStartIndex = opts[i].HtmlBody.indexOf("<style type=\"\"text/css\"\">");
                                    }
                                    var styleTagEndIndex  = opts[i].HtmlBody.indexOf("</style>");
                                    var SCRIPT_REGEX = /<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi;

                                    if(styleTagStartIndex > -1)
                                    {
                                        var emailStyle = opts[i].HtmlBody.substring(styleTagStartIndex, styleTagEndIndex);

                                        if(emailStyle.indexOf("body") > -1)
                                        {
                                            opts[i].HtmlBody = opts[i].HtmlBody.replace(SCRIPT_REGEX, "");
                                        }
										else
                                        {
                                           	opts[i].HtmlBody = opts[i].HtmlBody.replace("margin:0!important;", "");
                                        	opts[i].HtmlBody = opts[i].HtmlBody.replace("padding:0!important;", "");
                                        	opts[i].HtmlBody = opts[i].HtmlBody.replace("width:100%!important", ""); 
                                        }
                                    }
                            //console.log('html body --- ' + opts[i].HtmlBody);
                        }
                    }
                    
                                    
                	component.set('v.emailMessageList',opts);
                }
                else{
                    component.set("v.Message",true);
                }
                //console.log('email message ==='+JSON.stringify(component.get("v.emailMessageList")));
            }
        });
        $A.enqueueAction(action);
        
        
    },
    
    checkChild : function(component){
        var action = component.get("c.checkChild");
        var recordId = component.get("v.recordId");
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var respvalue = response.getReturnValue();
            console.log('REsponse value --- ' + respvalue);
            if(respvalue!=null && respvalue.ParentId != undefined){
                component.set("v.isChildBool",true);
                component.set("v.parentId",respvalue.ParentId);
                component.set("v.parentCaseNumber",respvalue.CaseNumber);
            }
            
            
        });
        $A.enqueueAction(action);
    },
    getParentEmail : function(component, event, helper) {
        component.set("v.parentMessage",false);
		var action = component.get("c.getEmailList");
        var recordId = component.get("v.parentId");
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            //alert('rsp==='+JSON.stringify(JSON.parse(resp)));
           
            if(state == 'SUCCESS'){
                if(resp != null && resp != '' && resp != undefined){
                    var opts = [];
                    opts = JSON.parse(resp);
                    
                    for(var i = 0; i < opts.length; i++)
                    {
                        //Change done for SDT-21278 -- Start
                        if(opts[i].RelatedToId)
                        {
                            if(recordId.substring(0,3) == '500'){
                                opts[i]["MessageId"] = 'CE' + opts[i].Id + opts[i].RelatedToId + recordId;
                            }
                            else{
                                opts[i]["MessageId"] = 'QE' + opts[i].Id + opts[i].RelatedToId + recordId;
                            }
                        }
                        //Change done for SDT-21278 -- Start
                        if(opts[i].HtmlBody){
                            //opts[i].HtmlBody = opts[i].HtmlBody.replace('/\"/g', '\\"');
                            //opts[i].HtmlBody = escape(opts[i].HtmlBody);  
                            opts[i].HtmlBody = opts[i].HtmlBody.replace(/<\/?BASE[^>]*>/g, "");
							//Added by Mudit Chaturvedi for SDT-13733 - Start
							var baseStartTagIndex,baseEndTagIndex;
                            if(opts[i].HtmlBody.indexOf("<base") > -1)
                            {
                                var indx = opts[i].HtmlBody.indexOf("<base");
                                baseStartTagIndex = indx;
                                while(opts[i].HtmlBody[indx] != '>')
                                {
                                    baseEndTagIndex = indx + 2;
                                    indx++;
                                }
                                opts[i].HtmlBody = opts[i].HtmlBody.substring(0, baseStartTagIndex ) + opts[i].HtmlBody.substring( baseEndTagIndex, opts[i].HtmlBody.length);
                            }
                            //Added by Mudit Chaturvedi for SDT-13733 - End
                                    var styleTagStartIndex  = opts[i].HtmlBody.indexOf("<style>");
                                    var styleTagEndIndex  = opts[i].HtmlBody.indexOf("</style>");
                                    var SCRIPT_REGEX = /<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi;

                                    if(styleTagStartIndex > -1)
                                    {
                                        var emailStyle = opts[i].HtmlBody.substring(styleTagStartIndex, styleTagEndIndex);

                                        if(emailStyle.indexOf("body") > -1)
                                        {
                                            opts[i].HtmlBody = opts[i].HtmlBody.replace(SCRIPT_REGEX, "");
                                        }
                                    }
                            //console.log('html body --- ' + opts[i].HtmlBody);
                        }
                    }
                	component.set('v.parentEmailList',opts);
                }
                else{
                    component.set("v.parentMessage",true);
                }
                //console.log('email message ==='+JSON.stringify(component.get("v.parentEmailList")));
            }
        });
        $A.enqueueAction(action);
    }
    
})