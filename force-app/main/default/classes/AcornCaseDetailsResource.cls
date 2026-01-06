/*
URL GET: /services/apexrest/Case/V1/5000U0000086V4jQAE
Example JSON POST:
{
    "caseId": "5000U0000086V4jQAE"
}
*/

@RestResource(urlMapping='/Case/V1/*')
global with sharing class AcornCaseDetailsResource {

    @HttpGet
    global static Case getCase() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String caseId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
    	return AcornCaseDetailsResource.getCaseInfo(caseId);
    }
    
    @HttpPost
    global static Case getCase(String caseId) {
        return AcornCaseDetailsResource.getCaseInfo(caseId);
    }
    
    global static Case getCaseInfo(String caseId) {
        List <Case> cases = new List <Case>();
        List<Case> caseCheck = [SELECT Id, Case_Sub_Type__c,Case_Type__c,Work_Order__c FROM Case WHERE Id = :caseId];  // Two fields added for sdt-14124
                      
        if(caseCheck[0].Case_Sub_Type__c.equals(Constant_Util.BALES)){
            cases = [select AccountId, CaseNumber, Material_Grade__c, Material_Type__c, Equipment_Type_Code__c, Equipment_Size_Code__c, Service_Occurrence_Type_Code__c, Delivery_Date__c,   
            Origin, Removal_Date__c, SalesMeet_Quantity__c, Quantity_Override__c, Container_For__c, Disposed_Of__c, Team_Queue__c, User_Name__r.Acorn_SUser_Id__c, User_Name__r.Name, CreatedBy.Acorn_SUser_Id__c, Supplier__r.Name,
            Emergency__c, Case_Information__c, Case_Type__c, Case_Sub_Type__c, Case_Reason__c, Location__r.AccountNumber, Quote_Only__c, Reference_Number__c,
            Event_Recurrence_Type_Code__c, Event_Recurrence_Interval__c, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, 
            Contact.Name, Contact.Account_Title__r.Name, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Phone, Is_With_Wheel__c, Is_With_Lock__c, Standard_Portable_Count__c,
            Handicapped_Portable_Count__c, Workers_Per_Shift_Count__c, Hand_Wash_Station_Type__c, Is_Electrical_Workers__c, Bladder_Mount_Location__c,
            Site_Contact__c, Site_Contact_Phone__c, Comments, Case_Comments__c, AssetId, /*Asset.Acorn_SBID__c*/ AssetDetail__r.Acorn_SBID__c, Acorn_SBID__c, SalesMeet_Container_Position__c, 
            Offsite_Address__c, Company_Category__c, IsClosed, Saturday__c, Sunday__c from Case where Id =: caseId];
            cases[0].SalesMeet_Quantity__c = String.valueOf(cases[0].Quantity_Override__c);
            
        }
		 // case  type not equal to pickup and no workorder exists on case.  - fix as part of SDT-14124
        else if(caseCheck[0].Work_Order__c == null &&  caseCheck[0].Case_Type__c != Constant_Util.PICKUP_CSTYPE)
        {
           cases = [select AccountId, CaseNumber, Material_Grade__c, Material_Type__c, Equipment_Type_Code__c, Equipment_Size_Code__c, Service_Occurrence_Type_Code__c, Delivery_Date__c,   
           Origin, Removal_Date__c, SalesMeet_Quantity__c, Container_For__c, Disposed_Of__c, Team_Queue__c, User_Name__r.Acorn_SUser_Id__c, User_Name__r.Name, CreatedBy.Acorn_SUser_Id__c, Supplier__r.Name,
           Emergency__c, Case_Information__c, Case_Type__c, Case_Sub_Type__c, Case_Reason__c, Location__r.AccountNumber, Quote_Only__c, Reference_Number__c,
           Event_Recurrence_Type_Code__c, Event_Recurrence_Interval__c, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, 
           Contact.Name, Contact.Account_Title__r.Name, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Phone, Is_With_Wheel__c, Is_With_Lock__c, Standard_Portable_Count__c,
           Handicapped_Portable_Count__c, Workers_Per_Shift_Count__c, Hand_Wash_Station_Type__c, Is_Electrical_Workers__c, Bladder_Mount_Location__c,
          Site_Contact__c, Site_Contact_Phone__c, Comments, Case_Comments__c, AssetId, /*Asset.Acorn_SBID__c*/AssetDetail__r.Acorn_SBID__c, Acorn_SBID__c, SalesMeet_Container_Position__c, 
          Offsite_Address__c, Company_Category__c, IsClosed,Service_Date__c, Saturday__c, Sunday__c from Case where Id =: caseId];

        }   
		else{
            cases = [select AccountId, CaseNumber, Material_Grade__c, Material_Type__c, Equipment_Type_Code__c, Equipment_Size_Code__c, Service_Occurrence_Type_Code__c, Delivery_Date__c,   
            Origin, Removal_Date__c, SalesMeet_Quantity__c, Container_For__c, Disposed_Of__c, Team_Queue__c, User_Name__r.Acorn_SUser_Id__c, User_Name__r.Name, CreatedBy.Acorn_SUser_Id__c, Supplier__r.Name,
            Emergency__c, Case_Information__c, Case_Type__c, Case_Sub_Type__c, Case_Reason__c, Location__r.AccountNumber, Quote_Only__c, Reference_Number__c,
            Event_Recurrence_Type_Code__c, Event_Recurrence_Interval__c, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, 
            Contact.Name, Contact.Account_Title__r.Name, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Phone, Is_With_Wheel__c, Is_With_Lock__c, Standard_Portable_Count__c,
            Handicapped_Portable_Count__c, Workers_Per_Shift_Count__c, Hand_Wash_Station_Type__c, Is_Electrical_Workers__c, Bladder_Mount_Location__c,
            Site_Contact__c, Site_Contact_Phone__c, Comments, Case_Comments__c, AssetId, /*Asset.Acorn_SBID__c*/ AssetDetail__r.Acorn_SBID__c, Acorn_SBID__c, SalesMeet_Container_Position__c, 
            Offsite_Address__c, Company_Category__c, IsClosed, Saturday__c, Sunday__c from Case where Id =: caseId];
        }
        
        	if (cases.size() <= 0) {return null;}
        	
        	String caseComments = '';
        	String supplierName = cases[0].Supplier__r.Name;
            if (String.isNotEmpty(supplierName)) { 
                caseComments = supplierName + ' : ';
            } 
        	//system.debug(Cases[0].Case_Type__c);
        	if (Cases[0].Case_Type__c != 'New Service') {
                List<Comment__c> comments = [select Id, CreatedDate, Comment__c from Comment__c where Communication_Log_Type_Name__c='Internal' and RecordType.Name='Acorn Ticket Comment' and Case__r.Id =: caseId];
                for (Comment__c c: comments) {
                    caseComments += c.Comment__c + '<br/>';
                }
                //caseComments = RedNoteController.removeHTML(caseComments);
                Cases[0].Case_Comments__c = caseComments;
        	}
        	/*
        	System.debug('Comments: ' + cases[0].Comments);
        	cases[0].Case_Comments__c = '';
        	if (String.isNotEmpty(cases[0].Comments)) {
                if (String.isNotEmpty(cases[0].Supplier__r.Name)) { 
                    cases[0].Case_Comments__c = cases[0].Supplier__r.Name + ' : ';
                } 
            	cases[0].Case_Comments__c += cases[0].Comments; 
            }else{
                cases[0].Case_Comments__c = 'No Comment Information';
            }
			*/
        	
        	RestRequest req = RestContext.request;
        	RestResponse res = RestContext.response;
        
        return cases[0];
                              
    }
 
}