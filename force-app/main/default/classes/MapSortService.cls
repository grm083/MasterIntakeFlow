/* Apex Class : PricingJSONRequest
* Description : This class is used for sorting a map of Map<String, Map<String, Integer>> structure in ascending order based on the integer value.
* Developer : av4 TCS
* Date : 17/06/2025
*/
public class MapSortService {
    
     /*@methodName : getPricingDetails
    *@description : This method sorts the input map in ascending order based on the integer value of the inner map.
    *@param Id : Map<String, Map<String, Integer>> originalMap
    *@return: Map<String, Map<String, Integer>>
    */
    Public Static Map<String, Map<String, Integer>> nestedMapSorter(Map<String, Map<String, Integer>> originalMap) {
        //Convert map entries to a list of key-value pairs
        List<MapEntry> entryList = new List<MapEntry>();
        
        for (String outerKey : originalMap.keySet()) {
            Map<String, Integer> innerMap = originalMap.get(outerKey);
            // Assumes only one key-value pair in inner map. //CHECK WITH ALI
            Integer value = innerMap.values()[0];
            String innerKey = new List<String>(innerMap.keySet())[0];
            entryList.add(new MapEntry(outerKey, innerMap, value, innerKey));
        }
        
        //Sort the list by integer value (ascending)
        entryList.sort();
        
        //Rebuild sorted map - need to check if apex maintains this order, else convert it to list. //CHECK WITH ALI
        Map<String, Map<String, Integer>> sortedMap = new Map<String, Map<String, Integer>>();
        for (MapEntry entry : entryList) {
            sortedMap.put(entry.outerKey, entry.innerMap);
        }
        
        
        
        return sortedMap;
    }
   /*@methodName : getPricingDetails
    *@description : wrapper to facilitate sorting of the input map
    
    */
    public class MapEntry implements Comparable {
        public String outerKey;
        public String innerKey;
        public Map<String, Integer> innerMap;
        public Integer sortValue;
        
        /*@methodName : getPricingDetails
    *@description : MapEntry
    *@param : Id  String outerKey, Map<String, Integer> innerMap, Integer sortValue, String innerKey
    *
    */
        public MapEntry(String outerKey, Map<String, Integer> innerMap, Integer sortValue, String innerKey) {
            this.outerKey = outerKey;
            this.innerMap = innerMap;
            this.sortValue = sortValue;
            this.innerKey = innerKey;
        }
        /*@methodName : getPricingDetails
    *@description : MapEntry
    *@param- Id : Object obj
    *@return : Integer
    */
        public Integer compareTo(Object obj) {
            MapEntry that = (MapEntry) obj;
            if (this.sortValue < that.sortValue){ return -1;}
            if (this.sortValue > that.sortValue) {return 1;}
            // Tie-breaker: sort by innerKey alphabetically
        	return this.innerKey.toLowerCase().compareTo(that.innerKey.toLowerCase());
        }
    }
    
}
