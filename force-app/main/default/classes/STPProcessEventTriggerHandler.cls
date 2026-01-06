/*
   @purpose	:  TriggerHandler for STPProcessEvent
   @Author	:	Toshender Kumar 
 */
public class STPProcessEventTriggerHandler extends TriggerHandler {
    
    //private Map<Id, STPProcessEvent__e> newSTPEventProcessMap;
	//private Map<Id, STPProcessEvent__e> oldSTPEventProcessMap;
    private List<STPProcessEvent__e> triggerNew;
    
    public STPProcessEventTriggerHandler() {
        //this.newSTPEventProcessMap	=	(Map<Id, STPProcessEvent__e>)	Trigger.newMap;
        //this.oldSTPEventProcessMap	=	(Map<Id,  STPProcessEvent__e>)	Trigger.oldMap;
        this.triggerNew				    =	(List<STPProcessEvent__e>)		Trigger.New;		   
    }
    
    // After Insert event for trigger
    public override void afterInsert(){        
        STPProcessTriggerHelper.processSTPProcessEvent(triggerNew);
    }
}