/*************************************************************
@Name: QuoteLineCreationHandler
@Author: TCS (Jatan sharma)
@CreateDate: 18/08/24
@Description: QuoteLineCreation Event for creating quotelines for IVR New service Process.
@UsedBy: SDT-40344 ,SDT-31997
**************************************************************/
public class QuoteLineCreationHandler implements IHandler {
	private static string const_ProductFamily = 'Waste Category';
	private static string const_QuoteStatus = 'Product Configured';

    private static List<case> getData = new List<case>();
	private static Map<String, SBQQ__Quote__c> quoteData = new Map<String, SBQQ__Quote__c>();
	private static Map<String, case> caseData = new Map<String, case>();
	private static Map<string, Product2> productMap = new Map<string, Product2>();
	private static ID quoteId;
	private static Id parentQL;
	//SDT 42654 Haul Away
    private static Boolean isHaulAway;

	/*
	This method is use to create Quote lines and Quote Order.
	In case of exception we are logging the exception and creating a task for agent to work manually
	*/
	public static Map<String, sobject> execute(Map<String, sobject> caseDataMap) {
		try {
			for (Id key : caseDataMap.Keyset()) {
				sobject obj = caseDataMap.get(key);
				if (obj.getSObjectType() == SBQQ__Quote__c.sObjectType) {
					quoteData.put(key, (SBQQ__Quote__c) obj);
					quoteId = key;
				}
				if (obj.getSObjectType() == Case.sObjectType) {
					caseData.put(key, (Case) obj);
				}
			}
			getData = caseData.values();
			//SDT 42654 Haul Away
            isHaulAway = HaulAwayService.getIsHaulAwayService(getData[0]);
			string productCode = getData[0].Equipment_Type_Code__c;
			string Equipment = getData[0].Equipment_Size_Code__c;
			string MaterialCode = getData[0].Material_Type__c;

			List<Product2> products = [
				SELECT id, name, Family, IsActive, ProductCode
				FROM Product2
				WHERE ProductCode IN (:productCode, :MaterialCode) AND IsActive = TRUE
			];

			for (Product2 prod : products) {
				productMap.put(prod.ProductCode, prod);
			}
			Id productId = productMap.get(productCode).Id;
			string Material = productMap.get(MaterialCode).name;
			String productWasteCategoryCode = productCode +MaterialCode;
			SBQQ__ProductOption__c productWasteCategory = [
				SELECT Id, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name
				FROM SBQQ__ProductOption__c
				WHERE
					SBQQ__ConfiguredSKU__r.ProductCode = :productCode
					AND SBQQ__ProductFamily__c = :const_ProductFamily
					AND SBQQ__OptionalSKU__r.ProductCode = :productWasteCategoryCode
					AND SBQQ__OptionalSKU__r.IsActive = TRUE
				LIMIT 1
			];
			SBQQ__ProductOption__c productWasteStream = [
				SELECT Id
				FROM SBQQ__ProductOption__c
				WHERE
					SBQQ__ConfiguredSKU__c = :productWasteCategory.SBQQ__OptionalSKU__c
					AND SBQQ__OptionalSKU__r.Name = :Material
				LIMIT 1
			];

			string result = QuoteProcurementController.createQuoteLines(
				quoteId,
				productId,
				productWasteStream.id,
				Equipment
			);

			system.debug('Result '+ result);

			List<SBQQ__QuoteLine__c> qlList = [
				SELECT id, Vendor_Commit_Date__c, SBQQ__RequiredBy__c,SBQQ__Product__r.Name
				FROM SBQQ__QuoteLine__c
				WHERE sbqq__Quote__r.id = :quoteID
			];
			for (SBQQ__QuoteLine__c ql : qlList) {
				if (ql.SBQQ__RequiredBy__c == null) {
					parentQL = ql.id;
				}
				//Updating below fields as per CE Intake Logic.
				ql.SBQQ__StartDate__c = getData[0].Delivery_Date__c;
				ql.Quote_SLA_Date__c = getData[0].Delivery_Date__c;
				ql.SBQQ__EndDate__c = getData[0].Removal_Date__c;
				ql.CompanyCategoryName__c = getData[0].Company_Category__c;
				ql.CompanyCategoryCode__c = getData[0].CompanyCategoryCode__c;
				ql.Ownership__c = 'VDR'; //Vendor Owned
			}
			update qlList;

			//SDT 42654 Haul Away
            if(!isHaulAway)
            {
			//Availablity call is required for STP process rule execution.
			IVRUtility.createAvailablity(qlList[0].ID);

			//Creating Quote order for delivery
			IVRUtility.createQuoteOrder(quoteId, parentQL, getData[0],qlList);
			}

			//Succesfull Quoteline created, Update status to Procure service to run STP process.
			if (!String.isempty(result)) {
				RecurrsiveTriggerHandler.bypassValidation = false;
				SBQQ__Quote__c quote = new sbqq__Quote__c();
				quote.id = quoteId;
				quote.SBQQ__Status__c = const_QuoteStatus;
				update quote;
			}
		}
		//In case of any exception we will create task and genesys record for assigning case to Agent.
		//Also creating logs for reporting purpose. 
		catch (exception ex) {
			//SDT 42654 Haul Away
            if(!isHaulAway)
            {
            IVRUtility.taskandGenesysRouting(getData,'Unable to create QuoteLines',ex.getMessage());
			IVRUtility.createIVRExceptionLogObj(
				'Execute',
				ex.getMessage()+ex.getStackTraceString(),
				'QuoteLineCreationHandler'
			);
			}
		}
		return caseDataMap;
	}
}