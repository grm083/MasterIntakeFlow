({
    afterRender : function(cmp, helper){
        this.superAfterRender();
        var isScroll = false;
        var isSticky = false;
        var scrollHeight
        var clientHeight
        var stickySectionAura = cmp.find("stickySection");
        var content = cmp.find("content");
        var sticky;
        var hasSubtabs;
        var topHeader = document.getElementById("myHeader");
        var sandboxHeader = false;
        if(topHeader && topHeader.getBoundingClientRect()){
            console.log('-header position---' + topHeader.getBoundingClientRect().y);    
            if(topHeader.getBoundingClientRect().y > 115){
                sandboxHeader = true;
            }
            if(sandboxHeader){
                $A.util.removeClass(stickySectionAura, 'forceHighlightsPanel');
                $A.util.addClass(stickySectionAura, 'forceHighlightsPanelSandBox');
            }
        }    
        window.onscroll = function() {
            var header = document.getElementById("myHeader");
            if(header){
                if(header.getBoundingClientRect()){
                    console.log('-header position--inside-' + header.getBoundingClientRect().y);
                }
                sticky = header.offsetTop;
                console.log('----sticky--' + sticky);
                hasSubtabs = false;
                isSticky =$A.util.hasClass(stickySectionAura, 'stickySection');
                var workspaceAPI = cmp.find("workspace");
                console.log('===' + JSON.stringify(workspaceAPI));
                if(workspaceAPI){
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        console.log('==response=' + JSON.stringify(response));
                      /*  if(response.isSubtab || response.subtabs[0]){
                            hasSubtabs =true;
                        }
                        if(hasSubtabs) {
                            $A.util.removeClass(stickySectionAura, 'forceHighlightsPanel');
                            $A.util.addClass(stickySectionAura, 'forceHighlightsPanelSubTab');
                        } */
                      /*  if(parseInt(window.pageYOffset) > 75 && !isSticky){
                            $A.util.addClass(stickySectionAura, 'stickySection');
                            $A.util.addClass(content, 'aftercontent');
                            if(hasSubtabs){
                                $A.util.addClass(stickySectionAura, 'subtabPostion');
                            }
                            else{
                                $A.util.addClass(stickySectionAura, 'tabPostion');
                            }
                        }
                        else if(parseInt(window.pageYOffset) < 75 && isSticky){
                            $A.util.removeClass(stickySectionAura, 'stickySection');
                            $A.util.removeClass(content, 'aftercontent');
                            if($A.util.hasClass(stickySectionAura, 'subtabPostion')){
                                $A.util.removeClass(stickySectionAura, 'subtabPostion');
                            }
                            else{
                                $A.util.removeClass(stickySectionAura, 'tabPostion');
                            }
                        } */
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                    
                }
            } 
        };
    }
    
})