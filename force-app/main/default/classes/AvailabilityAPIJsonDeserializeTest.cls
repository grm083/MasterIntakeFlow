/*
* @Name          AvailabilityAPIJsonDeserializeTest
* @Author        Digdershika Ojha
* @Vendor		 TCS
* @Date          14/09/2023
* @description	 This class will be used as Test class for AvailabilityAPIJsonDeserialize, initially created for story SDT-32003
*/
@isTest (SeeAllData = FALSE)
public class AvailabilityAPIJsonDeserializeTest {
    static String JSON_STRING = '{"data": {"suppliers": [{"availabilitySource": "WM","contractType": "Open Market","wmMetaData": {"marketAreaCode": "K00126","marketAreaName": "WM of South Atlantic"}}]}}';
	/*
     * @MethodName    : testParse
     * @description	  : Test if parse method is able to deseralise the passed json string.
     * @return        : void
     */
    @isTest
    static void testParse(){
        AvailabilityAPIJsonDeserialize parsedValue = AvailabilityAPIJsonDeserialize.parse(JSON_STRING);
        //system.debug('parsedValue :: '+ parsedValue);
        //assert.isNotNull(parsedValue,'parsedValue should not be null');
    }
}