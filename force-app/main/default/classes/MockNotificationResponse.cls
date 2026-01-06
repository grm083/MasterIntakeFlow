/**
* @author Devendra Patel
* @date 09/04/2020
* @description : Mock response for NotificationTrackingController class
**/
public class MockNotificationResponse {
         public static String NOTIFICATION_MOCK_RESPONSE = '{ '
                +'"pageIndex": 1,'
                +'"pageSize": 10,'
                +'"count": 1,'
                +'"data": [{'
                        +'"communicationType": "Email",'
                        +'"notificationDateTime": "2020-08-26T13:37:44.527",'
                        +'"notificationStatus": "Not Delivered",'
                        +'"notificationMessage": "Negative HOC",'
                        +'"contactName": "NISHCHAL AGARWAL",'
                        +'"emailAddress": "testwm41@gmail.com",'
                        +'"externalReference": "ND48",'
                        +'"imageUrl": null,'
                        +'"locationCode": "HMD005938",'
                        +'"locationId": 12285868,'
                        +'"phoneNumber": null,'
                        +'"serviceBaselineId": null,'
                        +'"subjectContent": null,'
                        +'"accountId": "0017A00000UmhqBQAR",'
                        +'"assetId": "02i7A000005FwqDQAS",'
                        +'"contactId": "0037A00000WuSVyQAN" }],'+
                    	'"Problem": {'+
            				'"Title": "Internal Server Error",'+
            				'"Status": 500,'+
            				'"Errors": ['+
            					   		'{'+
            							'"Code": "500",'+
            							'"Message": "The API has encountered something unexpected that didnt allow it to complete the request. We apologize."'+
            							'}'+
            						']'+
            					'}'+
            	'}';
}