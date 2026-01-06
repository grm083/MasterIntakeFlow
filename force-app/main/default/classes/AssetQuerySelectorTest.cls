//Class: AssetQuerySelectorTest
//Purpose: Test class for the AssetQuerySelector
//Author: TCS
//Date: 4-Nov-2024

@isTest(seeAllData = false)
public class AssetQuerySelectorTest 
{
    @isTest static void testCovertStringArrayToDelimiterSeparatedString()
    {
        String[] testArray = new String[] {'Test1', 'Test2', 'Test3'};
        String[] testArrayBlank = new String[] {};
        String result = '';
        result = AssetQuerySelector.covertStringArrayToDelimiterSeparatedString(testArray, ';');
        system.assertEquals(result, String.join(testArray, ';'), 'Error in assertion');
        result = AssetQuerySelector.covertStringArrayToDelimiterSeparatedString(testArrayBlank, ';');
        system.assertEquals(result, String.join(testArrayBlank, ';'), 'Error in assertion');
    }
    
    @isTest static void testGetMaxStartOrEndDate()
    {
        List<Asset> assetList = new List<Asset>();
        Asset parentAsset = new Asset();
        parentAsset.Name = 'Parent Asset';
        parentAsset.Start_Date__c = Date.today().addDays(1);
        parentAsset.End_Date__c = Date.today().addDays(20);
        INSERT parentAsset;
        
        Asset childAsset1 = new Asset();
        Asset childAsset2 = new Asset();
        
        childAsset1.Name = 'Child Asset 1';
        childAsset1.ParentId = parentAsset.Id;
        childAsset1.Start_Date__c = Date.today().addDays(4);
        childAsset1.End_Date__c = Date.today().addDays(21);
        
        childAsset2.Name = 'Child Asset 2';
        childAsset2.ParentId = parentAsset.Id;
        childAsset2.Start_Date__c = Date.today().addDays(3);
        childAsset2.End_Date__c = Date.today().addDays(22);
            
        assetList.add(childAsset1);
        assetList.add(childAsset2);
        
        INSERT assetList;
            
        AggregateResult[] test = AssetQuerySelector.getMaxStartOrEndDate(parentAsset.Id);

        system.assertEquals(true, test[0].get('start') == Date.today().addDays(4) ? true : false, 'Error in assertion');
        system.assertEquals(true, test[0].get('end') == Date.today().addDays(22) ? true : false, 'Error in assertion');
    }
}