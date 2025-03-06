@IsTest
private class ActiveCampaignEmailHistoryCtrlTest {
    
    private static String CONTACT_JSON;
    private static String ACTIVITIES_JSON;
    private static String EMAILACTIVITIES_JSON;
    private static String OPENLIST_JSON;
    private static String CLICKLIST_JSON;

    @TestSetup
    static void makeData(){
		Account acc = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Teste',
            LastName = 'PersonAccount',
            BillingStreet = '1234 Test Street',
            BillingCity = 'Clearwater',
            BillingPostalCode = '33756',
            BillingState = 'FL',
            BillingCountry = 'United States',
            ShippingStreet = '1234 Test Street',
            ShippingCity = 'Clearwater',
            ShippingPostalCode = '33756',
            ShippingState = 'FL',
            ShippingCountry = 'United States',
            PersonEmail = 'tests@tests.com'
        );
        insert acc;
    }


    @IsTest
    static void shouldGetEmailsHistories() {

        Account acc = [SELECT Id, PersonEmail FROM Account];
        Web_Service_Setting__mdt settings = Web_Service_Setting__mdt.getInstance('ActiveCampaign');
		setJSON();

        Test.startTest();
			ActiveCampaignCalloutMock contactMock = new ActiveCampaignCalloutMock(200, CONTACT_JSON);
			ActiveCampaignCalloutMock activitiesMock = new ActiveCampaignCalloutMock(200, ACTIVITIES_JSON);
			ActiveCampaignCalloutMock emailActivitiesMock = new ActiveCampaignCalloutMock(200, EMAILACTIVITIES_JSON);
			ActiveCampaignCalloutMock openMock = new ActiveCampaignCalloutMock(200, OPENLIST_JSON);
			ActiveCampaignCalloutMock clickMock = new ActiveCampaignCalloutMock(200, CLICKLIST_JSON);

			ActiveCampaignCalloutMultiMock multiMock = new ActiveCampaignCalloutMultiMock();
			multiMock.addCalloutMock(settings.Endpoint__c + '/api/3/contacts?filters[email]=' +acc.PersonEmail, contactMock);
			multiMock.addCalloutMock(settings.Endpoint__c + '/api/3/activities?contact=23&include=reference.log.campaign', activitiesMock);
			multiMock.addCalloutMock(settings.Endpoint__c + '/api/3/emailActivities?filters[subscriberid]=23', emailActivitiesMock);
			multiMock.addCalloutMock(settings.Endpoint__c + '/admin/api.php?api_action=campaign_report_open_list&campaignid=729&messageid=736&api_output=json', openMock);
			multiMock.addCalloutMock(settings.Endpoint__c + '/admin/api.php?api_action=campaign_report_link_list&campaignid=729&messageid=736&api_output=json', clickMock);

			Test.setMock(HttpCalloutMock.class, multimock);

			ActiveCampaignEmailHistoryCtrl.ResponseMessage response = ActiveCampaignEmailHistoryCtrl.getEmailsHistories(acc.PersonEmail, acc.Id);

			System.assertEquals('Success', response.title);
			System.assertEquals('Success when searching email histories', response.message);
			System.assertEquals('success', response.typeMessage);

			List<Email_History__c> histories = ActiveCampaignEmailHistoryCtrl.getHistories(acc.Id);

			System.assert(histories.size() > 0);
        Test.stopTest();
    }

	@IsTest
    static void shouldGetEmailsHistoriesErrorContacts() {

        Account acc = [SELECT Id, PersonEmail FROM Account];
        Web_Service_Setting__mdt settings = Web_Service_Setting__mdt.getInstance('ActiveCampaign');
		setJSON();

        Test.startTest();
			ActiveCampaignCalloutMock contactMock = new ActiveCampaignCalloutMock(404, CONTACT_JSON);
			ActiveCampaignCalloutMock activitiesMock = new ActiveCampaignCalloutMock(200, ACTIVITIES_JSON);
			ActiveCampaignCalloutMock emailActivitiesMock = new ActiveCampaignCalloutMock(200, EMAILACTIVITIES_JSON);
			ActiveCampaignCalloutMock openMock = new ActiveCampaignCalloutMock(200, OPENLIST_JSON);
			ActiveCampaignCalloutMock clickMock = new ActiveCampaignCalloutMock(200, CLICKLIST_JSON);

			ActiveCampaignCalloutMultiMock multiMock = new ActiveCampaignCalloutMultiMock();
			multiMock.addCalloutMock(settings.Endpoint__c + '/api/3/contacts?filters[email]=' +acc.PersonEmail, contactMock);
			multiMock.addCalloutMock(settings.Endpoint__c + '/api/3/activities?contact=23&include=reference.log.campaign', activitiesMock);
			multiMock.addCalloutMock(settings.Endpoint__c + '/api/3/emailActivities?filters[subscriberid]=23', emailActivitiesMock);
			multiMock.addCalloutMock(settings.Endpoint__c + '/admin/api.php?api_action=campaign_report_open_list&campaignid=729&messageid=736&api_output=json', openMock);
			multiMock.addCalloutMock(settings.Endpoint__c + '/admin/api.php?api_action=campaign_report_link_list&campaignid=729&messageid=736&api_output=json', clickMock);

			Test.setMock(HttpCalloutMock.class, multimock);

			ActiveCampaignEmailHistoryCtrl.ResponseMessage response = ActiveCampaignEmailHistoryCtrl.getEmailsHistories(acc.PersonEmail, acc.Id);

			System.assertEquals('Warning', response.title);
			System.assertEquals('Contact not found', response.message);
			System.assertEquals('warning', response.typeMessage);
        Test.stopTest();
    }

	@IsTest
    static void shouldGetEmailsHistoriesErrorActivities() {

        Account acc = [SELECT Id, PersonEmail FROM Account];
        Web_Service_Setting__mdt settings = Web_Service_Setting__mdt.getInstance('ActiveCampaign');
		setJSON();

        Test.startTest();
			ActiveCampaignCalloutMock contactMock = new ActiveCampaignCalloutMock(200, CONTACT_JSON);
			ActiveCampaignCalloutMock activitiesMock = new ActiveCampaignCalloutMock(400, ACTIVITIES_JSON);
			ActiveCampaignCalloutMock emailActivitiesMock = new ActiveCampaignCalloutMock(400, EMAILACTIVITIES_JSON);
			ActiveCampaignCalloutMock openMock = new ActiveCampaignCalloutMock(200, OPENLIST_JSON);
			ActiveCampaignCalloutMock clickMock = new ActiveCampaignCalloutMock(200, CLICKLIST_JSON);

			ActiveCampaignCalloutMultiMock multiMock = new ActiveCampaignCalloutMultiMock();
			multiMock.addCalloutMock(settings.Endpoint__c + '/api/3/contacts?filters[email]=' +acc.PersonEmail, contactMock);
			multiMock.addCalloutMock(settings.Endpoint__c + '/api/3/activities?contact=23&include=reference.log.campaign', activitiesMock);
			multiMock.addCalloutMock(settings.Endpoint__c + '/api/3/emailActivities?filters[subscriberid]=23', emailActivitiesMock);
			multiMock.addCalloutMock(settings.Endpoint__c + '/admin/api.php?api_action=campaign_report_open_list&campaignid=729&messageid=736&api_output=json', openMock);
			multiMock.addCalloutMock(settings.Endpoint__c + '/admin/api.php?api_action=campaign_report_link_list&campaignid=729&messageid=736&api_output=json', clickMock);

			Test.setMock(HttpCalloutMock.class, multimock);

			ActiveCampaignEmailHistoryCtrl.ResponseMessage response = ActiveCampaignEmailHistoryCtrl.getEmailsHistories(acc.PersonEmail, acc.Id);

			System.assertEquals('Warning', response.title);
			System.assertEquals('Email activity not found', response.message);
			System.assertEquals('warning', response.typeMessage);
        Test.stopTest();
    }

	@isTest
	static void shouldTestResponseClass() {

		String json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		
		ActiveCampaignActivitiesResponse.ContactLists objContactLists = new ActiveCampaignActivitiesResponse.ContactLists(System.JSON.createParser(json));
		System.assert(objContactLists.list_Z == null);

		ActiveCampaignActivitiesResponse.Links_Y objLinks_Y = new ActiveCampaignActivitiesResponse.Links_Y(System.JSON.createParser(json));
		System.assert(objLinks_Y.list_Z == null);

		ActiveCampaignContactResponse.Page_input objPage_input = new ActiveCampaignContactResponse.Page_input(System.JSON.createParser(json));
		System.assert(objPage_input.limit_Z == null);
		System.assert(objPage_input.sort_Z == null);
	}

	
    private static void setJSON() {

        CONTACT_JSON = '{'+
		'    \"scoreValues\": [],'+
		'    \"contacts\": ['+
		'        {'+
		'            \"cdate\": \"2024-06-21T13:00:21-05:00\",'+
		'            \"email\": \"tests@tests.com\",'+
		'            \"phone\": \"\",'+
		'            \"firstName\": \"Lucas\",'+
		'            \"lastName\": \"Santos Test\",'+
		'            \"orgid\": \"0\",'+
		'            \"orgname\": \"\",'+
		'            \"segmentio_id\": \"\",'+
		'            \"bounced_hard\": \"0\",'+
		'            \"bounced_soft\": \"0\",'+
		'            \"bounced_date\": null,'+
		'            \"ip\": \"2981032362\",'+
		'            \"ua\": \"\",'+
		'            \"hash\": \"928c15a9947337b869fef0bea6086e20\",'+
		'            \"socialdata_lastcheck\": null,'+
		'            \"email_local\": \"\",'+
		'            \"email_domain\": \"hotmail.com\",'+
		'            \"sentcnt\": \"4\",'+
		'            \"rating_tstamp\": \"2024-07-02\",'+
		'            \"gravatar\": \"0\",'+
		'            \"deleted\": \"0\",'+
		'            \"anonymized\": \"0\",'+
		'            \"adate\": \"2024-07-31T17:10:14-05:00\",'+
		'            \"udate\": \"2024-06-25T17:05:09-05:00\",'+
		'            \"edate\": \"2024-07-31T17:10:14-05:00\",'+
		'            \"deleted_at\": null,'+
		'            \"created_utc_timestamp\": \"2024-06-21 13:00:21\",'+
		'            \"updated_utc_timestamp\": \"2024-07-31 17:10:14\",'+
		'            \"created_timestamp\": \"2024-06-21 13:00:21\",'+
		'            \"updated_timestamp\": \"2024-07-31 17:10:14\",'+
		'            \"created_by\": \"0\",'+
		'            \"updated_by\": \"0\",'+
		'            \"mpp_tracking\": \"0\",'+
		'            \"last_click_date\": \"2024-07-02 07:47:07\",'+
		'            \"last_open_date\": \"2024-07-02 07:44:47\",'+
		'            \"last_mpp_open_date\": null,'+
		'            \"scoreValues\": [],'+
		'            \"accountContacts\": [],'+
		'            \"links\": {'+
		'                \"bounceLogs\": \"https://elteste.api-us1.com/api/3/contacts/23/bounceLogs\",'+
		'                \"contactAutomations\": \"https://elteste.api-us1.com/api/3/contacts/23/contactAutomations?limit=2500&orders%5Blastdate%5D=DESC\",'+
		'                \"contactData\": \"https://elteste.api-us1.com/api/3/contacts/23/contactData\",'+
		'                \"contactGoals\": \"https://elteste.api-us1.com/api/3/contacts/23/contactGoals\",'+
		'                \"contactLists\": \"https://elteste.api-us1.com/api/3/contacts/23/contactLists\",'+
		'                \"contactLogs\": \"https://elteste.api-us1.com/api/3/contacts/23/contactLogs\",'+
		'                \"contactTags\": \"https://elteste.api-us1.com/api/3/contacts/23/contactTags\",'+
		'                \"contactDeals\": \"https://elteste.api-us1.com/api/3/contacts/23/contactDeals\",'+
		'                \"deals\": \"https://elteste.api-us1.com/api/3/contacts/23/deals\",'+
		'                \"fieldValues\": \"https://elteste.api-us1.com/api/3/contacts/23/fieldValues\",'+
		'                \"geoIps\": \"https://elteste.api-us1.com/api/3/contacts/23/geoIps\",'+
		'                \"notes\": \"https://elteste.api-us1.com/api/3/contacts/23/notes\",'+
		'                \"organization\": \"https://elteste.api-us1.com/api/3/contacts/23/organization\",'+
		'                \"plusAppend\": \"https://elteste.api-us1.com/api/3/contacts/23/plusAppend\",'+
		'                \"trackingLogs\": \"https://elteste.api-us1.com/api/3/contacts/23/trackingLogs\",'+
		'                \"scoreValues\": \"https://elteste.api-us1.com/api/3/contacts/23/scoreValues\",'+
		'                \"accountContacts\": \"https://elteste.api-us1.com/api/3/contacts/23/accountContacts\",'+
		'                \"automationEntryCounts\": \"https://elteste.api-us1.com/api/3/contacts/23/automationEntryCounts\"'+
		'            },'+
		'            \"id\": \"23\",'+
		'            \"organization\": null'+
		'        }'+
		'    ],'+
		'    \"meta\": {'+
		'        \"page_input\": {'+
		'            \"segmentid\": null,'+
		'            \"formid\": 0,'+
		'            \"listid\": 0,'+
		'            \"tagid\": 0,'+
		'            \"limit\": 20,'+
		'            \"offset\": 0,'+
		'            \"search\": null,'+
		'            \"sort\": null,'+
		'            \"seriesid\": 0,'+
		'            \"waitid\": 0,'+
		'            \"status\": -1,'+
		'            \"forceQuery\": 0,'+
		'            \"cacheid\": \"b400a8ceb46f5939cd88a0c2b81ee2b0\"'+
		'        },'+
		'        \"total\": \"1\",'+
		'        \"sortable\": true'+
		'    }'+
		'}';

        ACTIVITIES_JSON = '{'+
		'    \"linkData\": ['+
		'        {'+
		'            \"linkid\": \"3310\",'+
		'            \"isread\": \"1\",'+
		'            \"campaignid\": \"729\",'+
		'            \"messageid\": \"736\",'+
		'            \"tstamp\": \"2024-06-25T17:06:57-05:00\",'+
		'            \"subscriberid\": \"23\",'+
		'            \"email\": \"lucas-santos-oliveira@hotmail.com\",'+
		'            \"times\": \"1\",'+
		'            \"ip\": \"3171186815\",'+
		'            \"ua\": \"\",'+
		'            \"uasrc\": \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36\",'+
		'            \"referer\": \"\",'+
		'            \"created_timestamp\": \"2024-06-25 17:06:57\",'+
		'            \"updated_timestamp\": \"2024-06-25T17:06:57-05:00\",'+
		'            \"created_by\": null,'+
		'            \"updated_by\": null,'+
		'            \"ip6\": \"189.4.120.127\",'+
		'            \"links\": {'+
		'                \"link\": \"https://elteste.api-us1.com/api/3/linkData/38/link\",'+
		'                \"contact\": \"https://elteste.api-us1.com/api/3/linkData/38/contact\",'+
		'                \"campaign\": \"https://elteste.api-us1.com/api/3/linkData/38/campaign\",'+
		'                \"message\": \"https://elteste.api-us1.com/api/3/linkData/38/message\"'+
		'            },'+
		'            \"id\": \"38\",'+
		'            \"link\": \"3310\",'+
		'            \"contact\": \"23\",'+
		'            \"campaign\": \"729\",'+
		'            \"message\": \"736\"'+
		'        }'+
		'    ],'+
		'    \"logs\": ['+
		'        {'+
		'            \"campaignid\": \"729\",'+
		'            \"messageid\": \"736\",'+
		'            \"sendid\": \"27\",'+
		'            \"subscriberid\": \"23\",'+
		'            \"successful\": \"1\",'+
		'            \"tstamp\": \"2024-06-25T17:05:30-05:00\",'+
		'            \"comment\": null,'+
		'            \"created_timestamp\": \"2024-06-25 17:05:30\",'+
		'            \"updated_timestamp\": \"2024-06-25 17:05:30\",'+
		'            \"created_by\": null,'+
		'            \"updated_by\": null,'+
		'            \"links\": {'+
		'                \"contact\": \"https://elteste.api-us1.com/api/3/logs/31/contact\",'+
		'                \"campaign\": \"https://elteste.api-us1.com/api/3/logs/31/campaign\",'+
		'                \"message\": \"https://elteste.api-us1.com/api/3/logs/31/message\",'+
		'                \"activity\": \"https://elteste.api-us1.com/api/3/logs/31/activity\"'+
		'            },'+
		'            \"id\": \"31\",'+
		'            \"contact\": \"23\",'+
		'            \"campaign\": \"729\",'+
		'            \"message\": \"736\"'+
		'        }'+
		'    ],'+
		'    \"contactLists\": ['+
		'        {'+
		'            \"contact\": \"23\",'+
		'            \"list\": \"8\",'+
		'            \"form\": null,'+
		'            \"seriesid\": \"0\",'+
		'            \"sdate\": \"2024-06-25T17:05:09-05:00\",'+
		'            \"udate\": null,'+
		'            \"status\": \"1\",'+
		'            \"responder\": \"1\",'+
		'            \"sync\": \"0\",'+
		'            \"unsubreason\": \"\",'+
		'            \"campaign\": null,'+
		'            \"message\": null,'+
		'            \"first_name\": \"Lucas\",'+
		'            \"last_name\": \"Santos Test\",'+
		'            \"ip4Sub\": \"0\",'+
		'            \"sourceid\": \"3\",'+
		'            \"autosyncLog\": null,'+
		'            \"ip4_last\": \"177\",'+
		'            \"ip4Unsub\": \"0\",'+
		'            \"created_timestamp\": \"2024-06-25 17:05:09\",'+
		'            \"updated_timestamp\": \"2024-07-02 07:37:43\",'+
		'            \"created_by\": null,'+
		'            \"updated_by\": null,'+
		'            \"unsubscribeAutomation\": null,'+
		'            \"links\": {'+
		'                \"automation\": \"https://elteste.api-us1.com/api/3/contactLists/25/automation\",'+
		'                \"list\": \"https://elteste.api-us1.com/api/3/contactLists/25/list\",'+
		'                \"contact\": \"https://elteste.api-us1.com/api/3/contactLists/25/contact\",'+
		'                \"form\": \"https://elteste.api-us1.com/api/3/contactLists/25/form\",'+
		'                \"autosyncLog\": \"https://elteste.api-us1.com/api/3/contactLists/25/autosyncLog\",'+
		'                \"campaign\": \"https://elteste.api-us1.com/api/3/contactLists/25/campaign\",'+
		'                \"unsubscribeAutomation\": \"https://elteste.api-us1.com/api/3/contactLists/25/unsubscribeAutomation\",'+
		'                \"message\": \"https://elteste.api-us1.com/api/3/contactLists/25/message\"'+
		'            },'+
		'            \"id\": \"25\",'+
		'            \"automation\": null'+
		'        }'+
		'    ],'+
		'    \"contactAutomations\": ['+
		'        {'+
		'            \"contact\": \"23\",'+
		'            \"seriesid\": \"214\",'+
		'            \"startid\": \"0\",'+
		'            \"status\": \"2\",'+
		'            \"batchid\": \"completed\",'+
		'            \"adddate\": \"2024-07-02T07:42:17-05:00\",'+
		'            \"remdate\": \"2024-07-02T07:42:18-05:00\",'+
		'            \"timespan\": \"1\",'+
		'            \"lastblock\": \"3062\",'+
		'            \"lastlogid\": \"106\",'+
		'            \"lastdate\": \"2024-07-02T07:42:18-05:00\",'+
		'            \"in_als\": \"3\",'+
		'            \"completedElements\": 0,'+
		'            \"totalElements\": 6,'+
		'            \"completed\": 1,'+
		'            \"completeValue\": 100,'+
		'            \"links\": {'+
		'                \"automation\": \"https://elteste.api-us1.com/api/3/contactAutomations/78/automation\",'+
		'                \"contact\": \"https://elteste.api-us1.com/api/3/contactAutomations/78/contact\",'+
		'                \"contactGoals\": \"https://elteste.api-us1.com/api/3/contactAutomations/78/contactGoals\",'+
		'                \"automationLogs\": \"https://elteste.api-us1.com/api/3/contactAutomations/78/automationLogs\"'+
		'            },'+
		'            \"id\": \"78\",'+
		'            \"automation\": \"214\"'+
		'        }'+
		'    ],'+
		'    \"activities\": ['+
		'        {'+
		'            \"tstamp\": \"2024-06-25T17:06:57-05:00\",'+
		'            \"subscriberid\": \"23\",'+
		'            \"reference_type\": \"LinkData\",'+
		'            \"reference_id\": \"38\",'+
		'            \"reference_action\": \"\",'+
		'            \"jsonData\": null,'+
		'            \"userid\": \"0\",'+
		'            \"permission\": \"\",'+
		'            \"referenceModelName\": \"link-data\",'+
		'            \"reference\": {'+
		'                \"type\": \"link-data\",'+
		'                \"id\": \"38\"'+
		'            },'+
		'            \"links\": {'+
		'                \"user\": \"https://elteste.api-us1.com/api/3/activities/213/user\",'+
		'                \"recipients\": \"https://elteste.api-us1.com/api/3/activities/213/recipients\",'+
		'                \"reference\": \"https://elteste.api-us1.com/api/3/activities/213/reference\",'+
		'                \"notes\": \"https://elteste.api-us1.com/api/3/activities/213/notes\"'+
		'            },'+
		'            \"id\": \"213\",'+
		'            \"user\": null'+
		'        },'+
		'        {'+
		'            \"tstamp\": \"2024-07-02T07:37:43-05:00\",'+
		'            \"subscriberid\": \"23\",'+
		'            \"reference_type\": \"LinkData\",'+
		'            \"reference_id\": \"40\",'+
		'            \"reference_action\": \"\",'+
		'            \"jsonData\": null,'+
		'            \"userid\": \"0\",'+
		'            \"permission\": \"\",'+
		'            \"referenceModelName\": \"link-data\",'+
		'            \"reference\": {'+
		'                \"type\": \"link-data\",'+
		'                \"id\": \"40\"'+
		'            },'+
		'            \"links\": {'+
		'                \"user\": \"https://elteste.api-us1.com/api/3/activities/216/user\",'+
		'                \"recipients\": \"https://elteste.api-us1.com/api/3/activities/216/recipients\",'+
		'                \"reference\": \"https://elteste.api-us1.com/api/3/activities/216/reference\",'+
		'                \"notes\": \"https://elteste.api-us1.com/api/3/activities/216/notes\"'+
		'            },'+
		'            \"id\": \"216\",'+
		'            \"user\": null'+
		'        },'+
		'        {'+
		'            \"tstamp\": \"2024-07-02T07:44:46-05:00\",'+
		'            \"subscriberid\": \"23\",'+
		'            \"reference_type\": \"LinkData\",'+
		'            \"reference_id\": \"42\",'+
		'            \"reference_action\": \"\",'+
		'            \"jsonData\": null,'+
		'            \"userid\": \"0\",'+
		'            \"permission\": \"\",'+
		'            \"referenceModelName\": \"link-data\",'+
		'            \"reference\": {'+
		'                \"type\": \"link-data\",'+
		'                \"id\": \"42\"'+
		'            },'+
		'            \"links\": {'+
		'                \"user\": \"https://elteste.api-us1.com/api/3/activities/220/user\",'+
		'                \"recipients\": \"https://elteste.api-us1.com/api/3/activities/220/recipients\",'+
		'                \"reference\": \"https://elteste.api-us1.com/api/3/activities/220/reference\",'+
		'                \"notes\": \"https://elteste.api-us1.com/api/3/activities/220/notes\"'+
		'            },'+
		'            \"id\": \"220\",'+
		'            \"user\": null'+
		'        },'+
		'        {'+
		'            \"tstamp\": \"2024-07-02T07:47:07-05:00\",'+
		'            \"subscriberid\": \"23\",'+
		'            \"reference_type\": \"LinkData\",'+
		'            \"reference_id\": \"43\",'+
		'            \"reference_action\": \"\",'+
		'            \"jsonData\": null,'+
		'            \"userid\": \"0\",'+
		'            \"permission\": \"\",'+
		'            \"referenceModelName\": \"link-data\",'+
		'            \"reference\": {'+
		'                \"type\": \"link-data\",'+
		'                \"id\": \"43\"'+
		'            },'+
		'            \"links\": {'+
		'                \"user\": \"https://elteste.api-us1.com/api/3/activities/221/user\",'+
		'                \"recipients\": \"https://elteste.api-us1.com/api/3/activities/221/recipients\",'+
		'                \"reference\": \"https://elteste.api-us1.com/api/3/activities/221/reference\",'+
		'                \"notes\": \"https://elteste.api-us1.com/api/3/activities/221/notes\"'+
		'            },'+
		'            \"id\": \"221\",'+
		'            \"user\": null'+
		'        },'+
		'        {'+
		'            \"tstamp\": \"2024-06-25T17:05:30-05:00\",'+
		'            \"subscriberid\": \"23\",'+
		'            \"reference_type\": \"Log\",'+
		'            \"reference_id\": \"31\",'+
		'            \"reference_action\": \"\",'+
		'            \"jsonData\": null,'+
		'            \"userid\": \"0\",'+
		'            \"permission\": \"\",'+
		'            \"referenceModelName\": \"log\",'+
		'            \"reference\": {'+
		'                \"type\": \"log\",'+
		'                \"id\": \"31\"'+
		'            },'+
		'            \"links\": {'+
		'                \"user\": \"https://elteste.api-us1.com/api/3/activities/212/user\",'+
		'                \"recipients\": \"https://elteste.api-us1.com/api/3/activities/212/recipients\",'+
		'                \"reference\": \"https://elteste.api-us1.com/api/3/activities/212/reference\",'+
		'                \"notes\": \"https://elteste.api-us1.com/api/3/activities/212/notes\"'+
		'            },'+
		'            \"id\": \"212\",'+
		'            \"user\": null'+
		'        },'+
		'        {'+
		'            \"tstamp\": \"2024-06-25T17:08:32-05:00\",'+
		'            \"subscriberid\": \"23\",'+
		'            \"reference_type\": \"Log\",'+
		'            \"reference_id\": \"32\",'+
		'            \"reference_action\": \"\",'+
		'            \"jsonData\": null,'+
		'            \"userid\": \"0\",'+
		'            \"permission\": \"\",'+
		'            \"referenceModelName\": \"log\",'+
		'            \"reference\": {'+
		'                \"type\": \"log\",'+
		'                \"id\": \"32\"'+
		'            },'+
		'            \"links\": {'+
		'                \"user\": \"https://elteste.api-us1.com/api/3/activities/214/user\",'+
		'                \"recipients\": \"https://elteste.api-us1.com/api/3/activities/214/recipients\",'+
		'                \"reference\": \"https://elteste.api-us1.com/api/3/activities/214/reference\",'+
		'                \"notes\": \"https://elteste.api-us1.com/api/3/activities/214/notes\"'+
		'            },'+
		'            \"id\": \"214\",'+
		'            \"user\": null'+
		'        },'+
		'        {'+
		'            \"tstamp\": \"2024-07-02T07:20:32-05:00\",'+
		'            \"subscriberid\": \"23\",'+
		'            \"reference_type\": \"Log\",'+
		'            \"reference_id\": \"33\",'+
		'            \"reference_action\": \"\",'+
		'            \"jsonData\": null,'+
		'            \"userid\": \"0\",'+
		'            \"permission\": \"\",'+
		'            \"referenceModelName\": \"log\",'+
		'            \"reference\": {'+
		'                \"type\": \"log\",'+
		'                \"id\": \"33\"'+
		'            },'+
		'            \"links\": {'+
		'                \"user\": \"https://elteste.api-us1.com/api/3/activities/215/user\",'+
		'                \"recipients\": \"https://elteste.api-us1.com/api/3/activities/215/recipients\",'+
		'                \"reference\": \"https://elteste.api-us1.com/api/3/activities/215/reference\",'+
		'                \"notes\": \"https://elteste.api-us1.com/api/3/activities/215/notes\"'+
		'            },'+
		'            \"id\": \"215\",'+
		'            \"user\": null'+
		'        },'+
		'        {'+
		'            \"tstamp\": \"2024-07-02T07:42:34-05:00\",'+
		'            \"subscriberid\": \"23\",'+
		'            \"reference_type\": \"Log\",'+
		'            \"reference_id\": \"34\",'+
		'            \"reference_action\": \"\",'+
		'            \"jsonData\": null,'+
		'            \"userid\": \"0\",'+
		'            \"permission\": \"\",'+
		'            \"referenceModelName\": \"log\",'+
		'            \"reference\": {'+
		'                \"type\": \"log\",'+
		'                \"id\": \"34\"'+
		'            },'+
		'            \"links\": {'+
		'                \"user\": \"https://elteste.api-us1.com/api/3/activities/219/user\",'+
		'                \"recipients\": \"https://elteste.api-us1.com/api/3/activities/219/recipients\",'+
		'                \"reference\": \"https://elteste.api-us1.com/api/3/activities/219/reference\",'+
		'                \"notes\": \"https://elteste.api-us1.com/api/3/activities/219/notes\"'+
		'            },'+
		'            \"id\": \"219\",'+
		'            \"user\": null'+
		'        },'+
		'        {'+
		'            \"tstamp\": \"2024-06-25T17:05:09-05:00\",'+
		'            \"subscriberid\": \"23\",'+
		'            \"reference_type\": \"SubscriberList\",'+
		'            \"reference_id\": \"25\",'+
		'            \"reference_action\": \"subscribe\",'+
		'            \"jsonData\": \"{\\\"sourceid\\\":\\\"3\\\",\\\"sync\\\":\\\"0\\\",\\\"sourceid_autosync\\\":\\\"0\\\",\\\"unsubreason\\\":\\\"\\\"}\",'+
		'            \"userid\": \"0\",'+
		'            \"permission\": \"\",'+
		'            \"referenceModelName\": \"contact-list\",'+
		'            \"reference\": {'+
		'                \"type\": \"contact-list\",'+
		'                \"id\": \"25\"'+
		'            },'+
		'            \"links\": {'+
		'                \"user\": \"https://elteste.api-us1.com/api/3/activities/211/user\",'+
		'                \"recipients\": \"https://elteste.api-us1.com/api/3/activities/211/recipients\",'+
		'                \"reference\": \"https://elteste.api-us1.com/api/3/activities/211/reference\",'+
		'                \"notes\": \"https://elteste.api-us1.com/api/3/activities/211/notes\"'+
		'            },'+
		'            \"id\": \"211\",'+
		'            \"user\": null'+
		'        },'+
		'        {'+
		'            \"tstamp\": \"2024-07-02T07:42:17-05:00\",'+
		'            \"subscriberid\": \"23\",'+
		'            \"reference_type\": \"SubscriberSeries\",'+
		'            \"reference_id\": \"78\",'+
		'            \"reference_action\": \"start\",'+
		'            \"jsonData\": null,'+
		'            \"userid\": \"0\",'+
		'            \"permission\": \"\",'+
		'            \"referenceModelName\": \"contact-automation\",'+
		'            \"reference\": {'+
		'                \"type\": \"contact-automation\",'+
		'                \"id\": \"78\"'+
		'            },'+
		'            \"links\": {'+
		'                \"user\": \"https://elteste.api-us1.com/api/3/activities/217/user\",'+
		'                \"recipients\": \"https://elteste.api-us1.com/api/3/activities/217/recipients\",'+
		'                \"reference\": \"https://elteste.api-us1.com/api/3/activities/217/reference\",'+
		'                \"notes\": \"https://elteste.api-us1.com/api/3/activities/217/notes\"'+
		'            },'+
		'            \"id\": \"217\",'+
		'            \"user\": null'+
		'        },'+
		'        {'+
		'            \"tstamp\": \"2024-07-02T07:42:18-05:00\",'+
		'            \"subscriberid\": \"23\",'+
		'            \"reference_type\": \"SubscriberSeries\",'+
		'            \"reference_id\": \"78\",'+
		'            \"reference_action\": \"complete\",'+
		'            \"jsonData\": null,'+
		'            \"userid\": \"0\",'+
		'            \"permission\": \"\",'+
		'            \"referenceModelName\": \"contact-automation\",'+
		'            \"reference\": {'+
		'                \"type\": \"contact-automation\",'+
		'                \"id\": \"78\"'+
		'            },'+
		'            \"links\": {'+
		'                \"user\": \"https://elteste.api-us1.com/api/3/activities/218/user\",'+
		'                \"recipients\": \"https://elteste.api-us1.com/api/3/activities/218/recipients\",'+
		'                \"reference\": \"https://elteste.api-us1.com/api/3/activities/218/reference\",'+
		'                \"notes\": \"https://elteste.api-us1.com/api/3/activities/218/notes\"'+
		'            },'+
		'            \"id\": \"218\",'+
		'            \"user\": null'+
		'        }'+
		'    ],'+
		'    \"meta\": {'+
		'        \"total\": \"11\"'+
		'    }'+
		'}';

        EMAILACTIVITIES_JSON = '{'+
		'    \"emailActivities\": ['+
		'        {'+
		'            \"subscriberid\": \"23\",'+
		'            \"userid\": \"1\",'+
		'            \"d_id\": \"0\",'+
		'            \"account\": null,'+
		'            \"reltype\": \"Log\",'+
		'            \"relid\": \"31\",'+
		'            \"from_name\": \"El Funileiro\",'+
		'            \"fromAddress\": \"suporte@elfunileiro.com.br\",'+
		'            \"toAddress\": \"lucas-santos-oliveira@hotmail.com\",'+
		'            \"ccAddress\": \"\",'+
		'            \"subject\": \"Test\",'+
		'            \"message\": \"**LOGóTIPO**\\n\\nCrie seu email aqui!\\n\\nEste editor oferece a habilidade de personalizar totalmente o layout e o estilo dos seus emails. Você pode adicionar, remanejar e remover estruturas e seções.\\n\\nhttps://website.com/ \\n\\nCrie do jeito que você quiser\\n\\nAs estruturas ajudam a criar um relatório com múltiplas colunas sem complicações. Você pode adicionar a um email quantas estruturas quiser.\\n\\nAdicionar texto do botão https://website.com/\\n\\nhttps://www.facebook.com \\n\\nhttps://twitter.com \\n\\nhttps://www.linkedin.com \\n\\nhttps://www.youtube.com \\n\\nhttps://www.instagram.com \\n\\nEnviado para: lucas-santos-oliveira@hotmail.com\\n\\nCancelar inscrição https://elteste.activehosted.com/proc.php?nl=currentnl&amp;c=0&amp;m=0&amp;s=928c15a9947337b869fef0bea6086e20&amp;act=unsub\\n\\n\",'+
		'            \"messageHtml\": \"<!DOCTYPE html PUBLIC \\\"-//W3C//DTD XHTML 1.0 Transitional//EN\\\" \\\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\\\">\\n<html xmlns=\\\"http://www.w3.org/1999/xhtml\\\" xmlns:o=\\\"urn:schemas-microsoft-com:office:office\\\" lang=\\\"und\\\"><head><meta http-equiv=\\\"Content-Type\\\" content=\\\"text/html; charset=utf-8\\\"><meta name=\\\"viewport\\\" content=\\\"width=device-width, minimal-ui, initial-scale=1.0, maximum-scale=1.0, user-scalable=0;\\\"><meta http-equiv=\\\"X-UA-Compatible\\\" content=\\\"IE=edge\\\"><meta name=\\\"format-detection\\\" content=\\\"telephone=no, date=no, email=no, address=no\\\"><meta name=\\\"x-apple-disable-message-reformatting\\\"><title></title>\\n<!--[if (mso 16)]><style type=\\\"text/css\\\"> a { text-decoration: none; } </style><![endif]--> \\n<!--[if gte mso 9]><style> sup { font-size: 100% !important; } </style><![endif]--> \\n<!--[if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG></o:AllowPNG><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]--> \\n<!--[if gte mso 9]><style>sup { font-size: 100% !important; }</style><![endif]--> \\n<!--[if !mso]><!-- --><link href=\\\"https://fonts.googleapis.com/css?family=Roboto:400,400i,700,700i\\\" rel=\\\"stylesheet\\\"> \\n<!--<![endif]--><style type=\\\"text/css\\\">#outlook a { padding:0;}.es-button { mso-style-priority:100!important; text-decoration:none!important;}a[x-apple-data-detectors] { color:inherit!important; text-decoration:none!important; font-size:inherit!important; font-family:inherit!important; font-weight:inherit!important; line-height:inherit!important;}.es-desk-hidden { display:none; float:left; overflow:hidden; width:0; max-height:0; line-height:0; mso-hide:all;}\\n@media only screen and (max-width:600px) {p, ul li, ol li, a { line-height:150%!important } h1, h2, h3, h1 a, h2 a, h3 a { line-height:120% } h1 { font-size:30px!important; text-align:center } h2 { font-size:26px!important; text-align:center } h3 { font-size:20px!important; text-align:center } .es-header-body h1 a, .es-content-body h1 a, .es-footer-body h1 a { font-size:30px!important; text-align:left } .es-header-body h2 a, .es-content-body h2 a, .es-footer-body h2 a { font-size:26px!important; text-align:left } .es-header-body h3 a, .es-content-body h3 a, .es-footer-body h3 a { font-size:20px!important; text-align:left } .es-menu td a { font-size:13px!important } .es-header-body p, .es-header-body ul li, .es-header-body ol li, .es-header-body a { font-size:16px!important } .es-content-body p, .es-content-body ul li, .es-content-body ol li, .es-content-body a { font-size:16px!important }\\n .es-footer-body p, .es-footer-body ul li, .es-footer-body ol li, .es-footer-body a { font-size:16px!important } .es-infoblock p, .es-infoblock ul li, .es-infoblock ol li, .es-infoblock a { font-size:12px!important } *[class=\\\"gmail-fix\\\"] { display:none!important } .es-m-txt-c, .es-m-txt-c h1, .es-m-txt-c h2, .es-m-txt-c h3 { text-align:center!important } .es-m-txt-r, .es-m-txt-r h1, .es-m-txt-r h2, .es-m-txt-r h3 { text-align:right!important } .es-m-txt-l, .es-m-txt-l h1, .es-m-txt-l h2, .es-m-txt-l h3 { text-align:left!important } .es-m-txt-r img, .es-m-txt-c img, .es-m-txt-l img { display:inline!important } .es-button-border { display:inline-block!important } a.es-button, button.es-button { font-size:20px!important; display:inline-block!important } .es-adaptive table, .es-left, .es-right { width:100%!important }\\n .ac-footer, .es-content table, .es-header table, .es-footer table, .es-content, .es-footer, .es-header { width:100%!important; max-width:600px!important } .ac-footer td, .ac-footer p, .es-adapt-td { display:block!important; width:100%!important } .adapt-img { width:100%!important; height:auto!important } .es-m-p0 { padding:0px!important } .es-m-p0r { padding-right:0px!important } .es-m-p0l { padding-left:0px!important } .es-m-p0t { padding-top:0px!important } .es-m-p0b { padding-bottom:0!important } .es-m-p20b { padding-bottom:20px!important } .es-mobile-hidden, .es-hidden { display:none!important } tr.es-desk-hidden, td.es-desk-hidden, table.es-desk-hidden { width:auto!important; overflow:visible!important; float:none!important; max-height:inherit!important; line-height:inherit!important } tr.es-desk-hidden { display:table-row!important } table.es-desk-hidden { display:table!important }\\n td.es-desk-menu-hidden { display:table-cell!important } .es-menu td { width:1%!important } table.es-table-not-adapt, .esd-block-html table { width:auto!important } table.es-social { display:inline-block!important } table.es-social td { display:inline-block!important } .es-desk-hidden { display:table-row!important; width:auto!important; overflow:visible!important; max-height:inherit!important } }@media screen and (max-width:384px) {.mail-message-content { width:414px!important } }</style>\\n </head>\\n <body class=\\\"es-wrapper-color\\\" lang=\\\"und\\\" style=\\\"width:100%;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;padding:0;Margin:0;background-color:#FFFFFF\\\"><table class=\\\"es-wrapper\\\" width=\\\"100%\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;padding:0;Margin:0;width:100%;height:100%;background-repeat:repeat;background-position:center top;background-color:#FFFFFF\\\"><tr><td valign=\\\"top\\\" style=\\\"padding:0;Margin:0\\\"><table class=\\\"es-content\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0\\\"><table class=\\\"es-content-body\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><table width=\\\"100%\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td valign=\\\"top\\\" align=\\\"center\\\" style=\\\"padding:0;Margin:0;width:650px\\\"><table width=\\\"100%\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;border-width:2px;border-style:solid;border-color:#333333;background-color:#efefef\\\" bgcolor=\\\"#efefef\\\" role=\\\"presentation\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;padding-top:20px;padding-bottom:20px\\\"><p style=\\\"Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;line-height:42px;color:#333333;font-size:42px\\\"><b>LOGóTIPO</b></p>\\n</td></tr></table></td></tr></table></td></tr></table></td></tr></table>\\n <table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-content\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" bgcolor=\\\"#ffffff\\\" style=\\\"padding:0;Margin:0;background-color:#ffffff\\\"><table bgcolor=\\\"#ffffff\\\" class=\\\"es-content-body\\\" align=\\\"center\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;width:650px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;padding-top:40px\\\"><p style=\\\"Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;line-height:41px;color:#333333;font-size:14px\\\"><strong><span style=\\\"font-size:27px\\\">Crie seu email aqui!</span></strong><br><br><br>Este editor oferece a habilidade de personalizar totalmente o layout e o estilo dos seus emails. Você pode adicionar, remanejar e remover estruturas e seções.</p>\\n</td></tr><tr><td align=\\\"center\\\" height=\\\"70\\\" style=\\\"padding:0;Margin:0\\\"></td></tr></table></td></tr></table></td></tr></table></td></tr></table>\\n <table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-content\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" bgcolor=\\\"#ffffff\\\" style=\\\"padding:0;Margin:0;background-color:#ffffff\\\"><table bgcolor=\\\"#ffffff\\\" class=\\\"es-content-body\\\" align=\\\"center\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0;padding-bottom:20px\\\"> \\n<!--[if mso]><table style=\\\"width:650px\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\"><tr><td style=\\\"width:319px\\\" valign=\\\"top\\\"><![endif]--><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-left\\\" align=\\\"left\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:left\\\"><tr><td class=\\\"es-m-p20b\\\" align=\\\"left\\\" style=\\\"padding:0;Margin:0;width:319px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;font-size:0px\\\"><a target=\\\"_blank\\\" href=\\\"https://website.com/\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img class=\\\"adapt-img\\\" src=\\\"https://content.app-us1.com/cdn-cgi/image/dpr=2,fit=scale-down,format=auto,onerror=redirect,width=650/Xjajn/2022/06/15/51b94360-d619-48a0-ad61-97400e4f753b.png\\\" alt=\\\"Crie do jeito que você quiser\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\" width=\\\"319\\\" title=\\\"Crie do jeito que você quiser\\\" data-cf-ir-is-resized=\\\"true\\\"></a>\\n</td></tr></table></td></tr></table>\\n<!--[if mso]></td><td style=\\\"width:20px\\\"></td><td style=\\\"width:311px\\\" valign=\\\"top\\\"><![endif]--><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-right\\\" align=\\\"right\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:right\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0;width:311px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><p style=\\\"Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;line-height:29px;color:#333333;font-size:14px\\\"><strong><span style=\\\"font-size:19px\\\">Crie do jeito que você quiser</span></strong><br><br>As estruturas ajudam a criar um relatório com múltiplas colunas sem complicações. Você pode adicionar a um email quantas estruturas quiser.</p>\\n</td></tr><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0;padding-top:20px;padding-bottom:20px\\\"><span class=\\\"es-button-border\\\" style=\\\"border-style:solid;border-color:#004cff;background:#004cff;border-width:0px;display:inline-block;border-radius:3px;width:auto\\\"><a href=\\\"https://website.com/\\\" class=\\\"es-button es-button-1643731601421\\\" target=\\\"_blank\\\" style=\\\"mso-style-priority:100 !important;text-decoration:none;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;color:#ffffff;font-size:14px;padding:10px 15px;display:inline-block;background:#004cff;border-radius:3px;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;font-weight:normal;font-style:normal;line-height:17px;width:auto;text-align:center;mso-padding-alt:0;mso-border-alt:10px solid #004cff\\\">Adicionar texto do botão</a></span></td></tr></table></td></tr></table>\\n<!--[if mso]></td></tr></table><![endif]--></td></tr></table></td></tr></table>\\n <table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-content\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" bgcolor=\\\"#ffffff\\\" style=\\\"padding:0;Margin:0;background-color:#ffffff\\\"><table bgcolor=\\\"#ffffff\\\" class=\\\"es-content-body\\\" align=\\\"center\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;width:650px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;padding-top:30px;padding-bottom:30px;font-size:0\\\"><table border=\\\"0\\\" width=\\\"100%\\\" height=\\\"100%\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td style=\\\"padding:0;Margin:0;border-bottom:0px solid #cccccc;background:none;height:1px;width:100%;margin:0px\\\"></td>\\n </tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr></table>\\n <table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-content\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0\\\"><table bgcolor=\\\"#ffffff\\\" class=\\\"es-content-body\\\" align=\\\"center\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;width:650px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;font-size:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-table-not-adapt es-social\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://www.facebook.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Facebook\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/facebook-circle-black.png\\\" alt=\\\"Facebook\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a>\\n</td><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://twitter.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Twitter\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/twitter-circle-black.png\\\" alt=\\\"Twitter\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td>\\n <td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://www.linkedin.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Linkedin\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/linkedin-circle-black.png\\\" alt=\\\"Linkedin\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td>\\n <td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://www.youtube.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Youtube\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/youtube-circle-black.png\\\" alt=\\\"Youtube\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td>\\n <td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0\\\"><a target=\\\"_blank\\\" href=\\\"https://www.instagram.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Instagram\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/instagram-circle-black.png\\\" alt=\\\"Instagram\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td></tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr></table>\\n <table class=\\\"es-footer ac-footer\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%;background-color:transparent;background-repeat:repeat;background-position:center top\\\"><tr><td align=\\\"center\\\" class=\\\"es-footer-body\\\" style=\\\"padding:0;Margin:0;background-color:transparent;padding-top:20px;padding-bottom:20px;background:inherit;font-family:inherit;font-size:12px;color:inherit\\\"><p style=\\\"Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:inherit;line-height:150%;color:inherit;font-size:inherit\\\">Enviado para: lucas-santos-oliveira@hotmail.com<br><br><a style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:inherit;font-size:inherit;font-family:inherit;font-weight:inherit\\\" href=\\\"https://elteste.activehosted.com/proc.php?nl=currentnl&amp;c=cmpgnid&amp;m=currentmesg&amp;s=928c15a9947337b869fef0bea6086e20&amp;act=unsub\\\" target=\\\"_blank\\\">Cancelar inscrição</a><br><br><span class=\\\"perstag_address\\\" style=\\\"color:inherit;font-family:inherit;font-size:inherit\\\"></span></p>\\n</td></tr></table></body></html>\\n\",'+
		'            \"tstamp\": \"2024-06-25T17:05:30-05:00\",'+
		'            \"series_id\": null,'+
		'            \"subscriber_series_id\": null,'+
		'            \"automation_name\": null,'+
		'            \"service_provider\": null,'+
		'            \"links\": {'+
		'                \"contact\": \"https://elteste.api-us1.com/api/3/emailActivities/21/contact\",'+
		'                \"deal\": \"https://elteste.api-us1.com/api/3/emailActivities/21/deal\",'+
		'                \"user\": \"https://elteste.api-us1.com/api/3/emailActivities/21/user\",'+
		'                \"reference\": \"https://elteste.api-us1.com/api/3/emailActivities/21/reference\",'+
		'                \"account\": \"https://elteste.api-us1.com/api/3/emailActivities/21/account\"'+
		'            },'+
		'            \"id\": \"21\",'+
		'            \"contact\": \"23\",'+
		'            \"deal\": null,'+
		'            \"user\": \"1\",'+
		'            \"reference\": {'+
		'                \"type\": \"log\",'+
		'                \"id\": \"31\"'+
		'            }'+
		'        },'+
		'        {'+
		'            \"subscriberid\": \"23\",'+
		'            \"userid\": \"1\",'+
		'            \"d_id\": \"0\",'+
		'            \"account\": null,'+
		'            \"reltype\": \"Log\",'+
		'            \"relid\": \"32\",'+
		'            \"from_name\": \"El Funileiro\",'+
		'            \"fromAddress\": \"suporte@elfunileiro.com.br\",'+
		'            \"toAddress\": \"lucas-santos-oliveira@hotmail.com\",'+
		'            \"ccAddress\": \"\",'+
		'            \"subject\": \"Test\",'+
		'            \"message\": \"**LOGóTIPO**\\n\\nCrie seu email aqui!\\n\\nEste editor oferece a habilidade de personalizar totalmente o layout e o estilo dos seus emails. Você pode adicionar, remanejar e remover estruturas e seções.\\n\\nhttps://website.com/ \\n\\nCrie do jeito que você quiser\\n\\nAs estruturas ajudam a criar um relatório com múltiplas colunas sem complicações. Você pode adicionar a um email quantas estruturas quiser.\\n\\nAdicionar texto do botão https://website.com/\\n\\nhttps://www.facebook.com \\n\\nhttps://twitter.com \\n\\nhttps://www.linkedin.com \\n\\nhttps://www.youtube.com \\n\\nhttps://www.instagram.com \\n\\nEnviado para: lucas-santos-oliveira@hotmail.com\\n\\nCancelar inscrição https://elteste.activehosted.com/proc.php?nl=currentnl&amp;c=0&amp;m=0&amp;s=928c15a9947337b869fef0bea6086e20&amp;act=unsub\\n\\n\",'+
		'            \"messageHtml\": \"<!DOCTYPE html PUBLIC \\\"-//W3C//DTD XHTML 1.0 Transitional//EN\\\" \\\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\\\">\\n<html xmlns=\\\"http://www.w3.org/1999/xhtml\\\" xmlns:o=\\\"urn:schemas-microsoft-com:office:office\\\" lang=\\\"und\\\"><head><meta http-equiv=\\\"Content-Type\\\" content=\\\"text/html; charset=utf-8\\\"><meta name=\\\"viewport\\\" content=\\\"width=device-width, minimal-ui, initial-scale=1.0, maximum-scale=1.0, user-scalable=0;\\\"><meta http-equiv=\\\"X-UA-Compatible\\\" content=\\\"IE=edge\\\"><meta name=\\\"format-detection\\\" content=\\\"telephone=no, date=no, email=no, address=no\\\"><meta name=\\\"x-apple-disable-message-reformatting\\\"><title></title>\\n<!--[if (mso 16)]><style type=\\\"text/css\\\"> a { text-decoration: none; } </style><![endif]--> \\n<!--[if gte mso 9]><style> sup { font-size: 100% !important; } </style><![endif]--> \\n<!--[if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG></o:AllowPNG><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]--> \\n<!--[if gte mso 9]><style>sup { font-size: 100% !important; }</style><![endif]--> \\n<!--[if !mso]><!-- --><link href=\\\"https://fonts.googleapis.com/css?family=Roboto:400,400i,700,700i\\\" rel=\\\"stylesheet\\\"> \\n<!--<![endif]--><style type=\\\"text/css\\\">#outlook a { padding:0;}.es-button { mso-style-priority:100!important; text-decoration:none!important;}a[x-apple-data-detectors] { color:inherit!important; text-decoration:none!important; font-size:inherit!important; font-family:inherit!important; font-weight:inherit!important; line-height:inherit!important;}.es-desk-hidden { display:none; float:left; overflow:hidden; width:0; max-height:0; line-height:0; mso-hide:all;}\\n@media only screen and (max-width:600px) {p, ul li, ol li, a { line-height:150%!important } h1, h2, h3, h1 a, h2 a, h3 a { line-height:120% } h1 { font-size:30px!important; text-align:center } h2 { font-size:26px!important; text-align:center } h3 { font-size:20px!important; text-align:center } .es-header-body h1 a, .es-content-body h1 a, .es-footer-body h1 a { font-size:30px!important; text-align:left } .es-header-body h2 a, .es-content-body h2 a, .es-footer-body h2 a { font-size:26px!important; text-align:left } .es-header-body h3 a, .es-content-body h3 a, .es-footer-body h3 a { font-size:20px!important; text-align:left } .es-menu td a { font-size:13px!important } .es-header-body p, .es-header-body ul li, .es-header-body ol li, .es-header-body a { font-size:16px!important } .es-content-body p, .es-content-body ul li, .es-content-body ol li, .es-content-body a { font-size:16px!important }\\n .es-footer-body p, .es-footer-body ul li, .es-footer-body ol li, .es-footer-body a { font-size:16px!important } .es-infoblock p, .es-infoblock ul li, .es-infoblock ol li, .es-infoblock a { font-size:12px!important } *[class=\\\"gmail-fix\\\"] { display:none!important } .es-m-txt-c, .es-m-txt-c h1, .es-m-txt-c h2, .es-m-txt-c h3 { text-align:center!important } .es-m-txt-r, .es-m-txt-r h1, .es-m-txt-r h2, .es-m-txt-r h3 { text-align:right!important } .es-m-txt-l, .es-m-txt-l h1, .es-m-txt-l h2, .es-m-txt-l h3 { text-align:left!important } .es-m-txt-r img, .es-m-txt-c img, .es-m-txt-l img { display:inline!important } .es-button-border { display:inline-block!important } a.es-button, button.es-button { font-size:20px!important; display:inline-block!important } .es-adaptive table, .es-left, .es-right { width:100%!important }\\n .ac-footer, .es-content table, .es-header table, .es-footer table, .es-content, .es-footer, .es-header { width:100%!important; max-width:600px!important } .ac-footer td, .ac-footer p, .es-adapt-td { display:block!important; width:100%!important } .adapt-img { width:100%!important; height:auto!important } .es-m-p0 { padding:0px!important } .es-m-p0r { padding-right:0px!important } .es-m-p0l { padding-left:0px!important } .es-m-p0t { padding-top:0px!important } .es-m-p0b { padding-bottom:0!important } .es-m-p20b { padding-bottom:20px!important } .es-mobile-hidden, .es-hidden { display:none!important } tr.es-desk-hidden, td.es-desk-hidden, table.es-desk-hidden { width:auto!important; overflow:visible!important; float:none!important; max-height:inherit!important; line-height:inherit!important } tr.es-desk-hidden { display:table-row!important } table.es-desk-hidden { display:table!important }\\n td.es-desk-menu-hidden { display:table-cell!important } .es-menu td { width:1%!important } table.es-table-not-adapt, .esd-block-html table { width:auto!important } table.es-social { display:inline-block!important } table.es-social td { display:inline-block!important } .es-desk-hidden { display:table-row!important; width:auto!important; overflow:visible!important; max-height:inherit!important } }@media screen and (max-width:384px) {.mail-message-content { width:414px!important } }</style>\\n </head>\\n <body class=\\\"es-wrapper-color\\\" lang=\\\"und\\\" style=\\\"width:100%;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;padding:0;Margin:0;background-color:#FFFFFF\\\"><table class=\\\"es-wrapper\\\" width=\\\"100%\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;padding:0;Margin:0;width:100%;height:100%;background-repeat:repeat;background-position:center top;background-color:#FFFFFF\\\"><tr><td valign=\\\"top\\\" style=\\\"padding:0;Margin:0\\\"><table class=\\\"es-content\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0\\\"><table class=\\\"es-content-body\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><table width=\\\"100%\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td valign=\\\"top\\\" align=\\\"center\\\" style=\\\"padding:0;Margin:0;width:650px\\\"><table width=\\\"100%\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;border-width:2px;border-style:solid;border-color:#333333;background-color:#efefef\\\" bgcolor=\\\"#efefef\\\" role=\\\"presentation\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;padding-top:20px;padding-bottom:20px\\\"><p style=\\\"Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;line-height:42px;color:#333333;font-size:42px\\\"><b>LOGóTIPO</b></p>\\n</td></tr></table></td></tr></table></td></tr></table></td></tr></table>\\n <table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-content\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" bgcolor=\\\"#ffffff\\\" style=\\\"padding:0;Margin:0;background-color:#ffffff\\\"><table bgcolor=\\\"#ffffff\\\" class=\\\"es-content-body\\\" align=\\\"center\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;width:650px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;padding-top:40px\\\"><p style=\\\"Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;line-height:41px;color:#333333;font-size:14px\\\"><strong><span style=\\\"font-size:27px\\\">Crie seu email aqui!</span></strong><br><br><br>Este editor oferece a habilidade de personalizar totalmente o layout e o estilo dos seus emails. Você pode adicionar, remanejar e remover estruturas e seções.</p>\\n</td></tr><tr><td align=\\\"center\\\" height=\\\"70\\\" style=\\\"padding:0;Margin:0\\\"></td></tr></table></td></tr></table></td></tr></table></td></tr></table>\\n <table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-content\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" bgcolor=\\\"#ffffff\\\" style=\\\"padding:0;Margin:0;background-color:#ffffff\\\"><table bgcolor=\\\"#ffffff\\\" class=\\\"es-content-body\\\" align=\\\"center\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0;padding-bottom:20px\\\"> \\n<!--[if mso]><table style=\\\"width:650px\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\"><tr><td style=\\\"width:319px\\\" valign=\\\"top\\\"><![endif]--><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-left\\\" align=\\\"left\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:left\\\"><tr><td class=\\\"es-m-p20b\\\" align=\\\"left\\\" style=\\\"padding:0;Margin:0;width:319px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;font-size:0px\\\"><a target=\\\"_blank\\\" href=\\\"https://website.com/\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img class=\\\"adapt-img\\\" src=\\\"https://content.app-us1.com/cdn-cgi/image/dpr=2,fit=scale-down,format=auto,onerror=redirect,width=650/Xjajn/2022/06/15/51b94360-d619-48a0-ad61-97400e4f753b.png\\\" alt=\\\"Crie do jeito que você quiser\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\" width=\\\"319\\\" title=\\\"Crie do jeito que você quiser\\\" data-cf-ir-is-resized=\\\"true\\\"></a>\\n</td></tr></table></td></tr></table>\\n<!--[if mso]></td><td style=\\\"width:20px\\\"></td><td style=\\\"width:311px\\\" valign=\\\"top\\\"><![endif]--><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-right\\\" align=\\\"right\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:right\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0;width:311px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><p style=\\\"Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;line-height:29px;color:#333333;font-size:14px\\\"><strong><span style=\\\"font-size:19px\\\">Crie do jeito que você quiser</span></strong><br><br>As estruturas ajudam a criar um relatório com múltiplas colunas sem complicações. Você pode adicionar a um email quantas estruturas quiser.</p>\\n</td></tr><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0;padding-top:20px;padding-bottom:20px\\\"><span class=\\\"es-button-border\\\" style=\\\"border-style:solid;border-color:#004cff;background:#004cff;border-width:0px;display:inline-block;border-radius:3px;width:auto\\\"><a href=\\\"https://website.com/\\\" class=\\\"es-button es-button-1643731601421\\\" target=\\\"_blank\\\" style=\\\"mso-style-priority:100 !important;text-decoration:none;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;color:#ffffff;font-size:14px;padding:10px 15px;display:inline-block;background:#004cff;border-radius:3px;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;font-weight:normal;font-style:normal;line-height:17px;width:auto;text-align:center;mso-padding-alt:0;mso-border-alt:10px solid #004cff\\\">Adicionar texto do botão</a></span></td></tr></table></td></tr></table>\\n<!--[if mso]></td></tr></table><![endif]--></td></tr></table></td></tr></table>\\n <table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-content\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" bgcolor=\\\"#ffffff\\\" style=\\\"padding:0;Margin:0;background-color:#ffffff\\\"><table bgcolor=\\\"#ffffff\\\" class=\\\"es-content-body\\\" align=\\\"center\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;width:650px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;padding-top:30px;padding-bottom:30px;font-size:0\\\"><table border=\\\"0\\\" width=\\\"100%\\\" height=\\\"100%\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td style=\\\"padding:0;Margin:0;border-bottom:0px solid #cccccc;background:none;height:1px;width:100%;margin:0px\\\"></td>\\n </tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr></table>\\n <table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-content\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0\\\"><table bgcolor=\\\"#ffffff\\\" class=\\\"es-content-body\\\" align=\\\"center\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;width:650px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;font-size:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-table-not-adapt es-social\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://www.facebook.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Facebook\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/facebook-circle-black.png\\\" alt=\\\"Facebook\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a>\\n</td><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://twitter.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Twitter\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/twitter-circle-black.png\\\" alt=\\\"Twitter\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td>\\n <td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://www.linkedin.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Linkedin\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/linkedin-circle-black.png\\\" alt=\\\"Linkedin\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td>\\n <td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://www.youtube.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Youtube\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/youtube-circle-black.png\\\" alt=\\\"Youtube\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td>\\n <td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0\\\"><a target=\\\"_blank\\\" href=\\\"https://www.instagram.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Instagram\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/instagram-circle-black.png\\\" alt=\\\"Instagram\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td></tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr></table>\\n <table class=\\\"es-footer ac-footer\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%;background-color:transparent;background-repeat:repeat;background-position:center top\\\"><tr><td align=\\\"center\\\" class=\\\"es-footer-body\\\" style=\\\"padding:0;Margin:0;background-color:transparent;padding-top:20px;padding-bottom:20px;background:inherit;font-family:inherit;font-size:12px;color:inherit\\\"><p style=\\\"Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:inherit;line-height:150%;color:inherit;font-size:inherit\\\">Enviado para: lucas-santos-oliveira@hotmail.com<br><br><a style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:inherit;font-size:inherit;font-family:inherit;font-weight:inherit\\\" href=\\\"https://elteste.activehosted.com/proc.php?nl=currentnl&amp;c=cmpgnid&amp;m=currentmesg&amp;s=928c15a9947337b869fef0bea6086e20&amp;act=unsub\\\" target=\\\"_blank\\\">Cancelar inscrição</a><br><br><span class=\\\"perstag_address\\\" style=\\\"color:inherit;font-family:inherit;font-size:inherit\\\"></span></p>\\n</td></tr></table></body></html>\\n\",'+
		'            \"tstamp\": \"2024-06-25T17:08:32-05:00\",'+
		'            \"series_id\": null,'+
		'            \"subscriber_series_id\": null,'+
		'            \"automation_name\": null,'+
		'            \"service_provider\": null,'+
		'            \"links\": {'+
		'                \"contact\": \"https://elteste.api-us1.com/api/3/emailActivities/22/contact\",'+
		'                \"deal\": \"https://elteste.api-us1.com/api/3/emailActivities/22/deal\",'+
		'                \"user\": \"https://elteste.api-us1.com/api/3/emailActivities/22/user\",'+
		'                \"reference\": \"https://elteste.api-us1.com/api/3/emailActivities/22/reference\",'+
		'                \"account\": \"https://elteste.api-us1.com/api/3/emailActivities/22/account\"'+
		'            },'+
		'            \"id\": \"22\",'+
		'            \"contact\": \"23\",'+
		'            \"deal\": null,'+
		'            \"user\": \"1\",'+
		'            \"reference\": {'+
		'                \"type\": \"log\",'+
		'                \"id\": \"32\"'+
		'            }'+
		'        },'+
		'        {'+
		'            \"subscriberid\": \"23\",'+
		'            \"userid\": \"1\",'+
		'            \"d_id\": \"0\",'+
		'            \"account\": null,'+
		'            \"reltype\": \"Log\",'+
		'            \"relid\": \"33\",'+
		'            \"from_name\": \"El Funileiro\",'+
		'            \"fromAddress\": \"suporte@elfunileiro.com.br\",'+
		'            \"toAddress\": \"lucas-santos-oliveira@hotmail.com\",'+
		'            \"ccAddress\": \"\",'+
		'            \"subject\": \"Test no open\",'+
		'            \"message\": \"Crie seu email aqui!\\n%FIRST_NAME%\\n\\nEste editor oferece a habilidade de personalizar totalmente o layout e o estilo dos seus emails. Você pode adicionar, remanejar e remover estruturas e seções.\\n\\nhttps://www.facebook.com \\n\\nhttps://twitter.com \\n\\nhttps://www.linkedin.com \\n\\nhttps://www.youtube.com \\n\\nhttps://www.instagram.com \\n\\nEnviado para: lucas-santos-oliveira@hotmail.com\\n\\nCancelar inscrição https://elteste.emlnk.com/proc.php?nl=currentnl&amp;c=0&amp;m=0&amp;s=928c15a9947337b869fef0bea6086e20&amp;act=unsub\\n\\n\",'+
		'            \"messageHtml\": \"<!DOCTYPE html PUBLIC \\\"-//W3C//DTD XHTML 1.0 Transitional//EN\\\" \\\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\\\">\\n<html xmlns=\\\"http://www.w3.org/1999/xhtml\\\" xmlns:o=\\\"urn:schemas-microsoft-com:office:office\\\" lang=\\\"und\\\"><head><meta http-equiv=\\\"Content-Type\\\" content=\\\"text/html; charset=utf-8\\\"><meta name=\\\"viewport\\\" content=\\\"width=device-width, minimal-ui, initial-scale=1.0, maximum-scale=1.0, user-scalable=0;\\\"><meta http-equiv=\\\"X-UA-Compatible\\\" content=\\\"IE=edge\\\"><meta name=\\\"format-detection\\\" content=\\\"telephone=no, date=no, email=no, address=no\\\"><meta name=\\\"x-apple-disable-message-reformatting\\\"><title></title>\\n<!--[if (mso 16)]><style type=\\\"text/css\\\"> a { text-decoration: none; } </style><![endif]--> \\n<!--[if gte mso 9]><style> sup { font-size: 100% !important; } </style><![endif]--> \\n<!--[if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG></o:AllowPNG><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]--> \\n<!--[if gte mso 9]><style>sup { font-size: 100% !important; }</style><![endif]--> \\n<!--[if !mso]><!-- --><link href=\\\"https://fonts.googleapis.com/css?family=Roboto:400,400i,700,700i\\\" rel=\\\"stylesheet\\\"> \\n<!--<![endif]--><style type=\\\"text/css\\\">#outlook a { padding:0;}.es-button { mso-style-priority:100!important; text-decoration:none!important;}a[x-apple-data-detectors] { color:inherit!important; text-decoration:none!important; font-size:inherit!important; font-family:inherit!important; font-weight:inherit!important; line-height:inherit!important;}.es-desk-hidden { display:none; float:left; overflow:hidden; width:0; max-height:0; line-height:0; mso-hide:all;}\\n@media only screen and (max-width:600px) {p, ul li, ol li, a { line-height:150%!important } h1, h2, h3, h1 a, h2 a, h3 a { line-height:120% } h1 { font-size:30px!important; text-align:center } h2 { font-size:26px!important; text-align:center } h3 { font-size:20px!important; text-align:center } .es-header-body h1 a, .es-content-body h1 a, .es-footer-body h1 a { font-size:30px!important; text-align:left } .es-header-body h2 a, .es-content-body h2 a, .es-footer-body h2 a { font-size:26px!important; text-align:left } .es-header-body h3 a, .es-content-body h3 a, .es-footer-body h3 a { font-size:20px!important; text-align:left } .es-menu td a { font-size:13px!important } .es-header-body p, .es-header-body ul li, .es-header-body ol li, .es-header-body a { font-size:16px!important } .es-content-body p, .es-content-body ul li, .es-content-body ol li, .es-content-body a { font-size:16px!important }\\n .es-footer-body p, .es-footer-body ul li, .es-footer-body ol li, .es-footer-body a { font-size:16px!important } .es-infoblock p, .es-infoblock ul li, .es-infoblock ol li, .es-infoblock a { font-size:12px!important } *[class=\\\"gmail-fix\\\"] { display:none!important } .es-m-txt-c, .es-m-txt-c h1, .es-m-txt-c h2, .es-m-txt-c h3 { text-align:center!important } .es-m-txt-r, .es-m-txt-r h1, .es-m-txt-r h2, .es-m-txt-r h3 { text-align:right!important } .es-m-txt-l, .es-m-txt-l h1, .es-m-txt-l h2, .es-m-txt-l h3 { text-align:left!important } .es-m-txt-r img, .es-m-txt-c img, .es-m-txt-l img { display:inline!important } .es-button-border { display:inline-block!important } a.es-button, button.es-button { font-size:20px!important; display:inline-block!important } .es-adaptive table, .es-left, .es-right { width:100%!important }\\n .ac-footer, .es-content table, .es-header table, .es-footer table, .es-content, .es-footer, .es-header { width:100%!important; max-width:600px!important } .ac-footer td, .ac-footer p, .es-adapt-td { display:block!important; width:100%!important } .adapt-img { width:100%!important; height:auto!important } .es-m-p0 { padding:0px!important } .es-m-p0r { padding-right:0px!important } .es-m-p0l { padding-left:0px!important } .es-m-p0t { padding-top:0px!important } .es-m-p0b { padding-bottom:0!important } .es-m-p20b { padding-bottom:20px!important } .es-mobile-hidden, .es-hidden { display:none!important } tr.es-desk-hidden, td.es-desk-hidden, table.es-desk-hidden { width:auto!important; overflow:visible!important; float:none!important; max-height:inherit!important; line-height:inherit!important } tr.es-desk-hidden { display:table-row!important } table.es-desk-hidden { display:table!important }\\n td.es-desk-menu-hidden { display:table-cell!important } .es-menu td { width:1%!important } table.es-table-not-adapt, .esd-block-html table { width:auto!important } table.es-social { display:inline-block!important } table.es-social td { display:inline-block!important } .es-desk-hidden { display:table-row!important; width:auto!important; overflow:visible!important; max-height:inherit!important } }@media screen and (max-width:384px) {.mail-message-content { width:414px!important } }</style>\\n </head>\\n <body class=\\\"es-wrapper-color\\\" lang=\\\"und\\\" style=\\\"width:100%;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;padding:0;Margin:0;background-color:#FFFFFF\\\"><table class=\\\"es-wrapper\\\" width=\\\"100%\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;padding:0;Margin:0;width:100%;height:100%;background-repeat:repeat;background-position:center top;background-color:#FFFFFF\\\"><tr><td valign=\\\"top\\\" style=\\\"padding:0;Margin:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-content\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" bgcolor=\\\"#ffffff\\\" style=\\\"padding:0;Margin:0;background-color:#ffffff\\\"><table bgcolor=\\\"#ffffff\\\" class=\\\"es-content-body\\\" align=\\\"center\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;width:650px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;padding-top:40px\\\"><p style=\\\"Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;line-height:41px;color:#333333;font-size:14px\\\"><strong><span style=\\\"font-size:27px\\\">Crie seu email aqui!</span></strong><br>%FIRST_NAME%<br><br>Este editor oferece a habilidade de personalizar totalmente o layout e o estilo dos seus emails. Você pode adicionar, remanejar e remover estruturas e seções.</p>\\n</td></tr><tr><td align=\\\"center\\\" height=\\\"70\\\" style=\\\"padding:0;Margin:0\\\"></td></tr></table></td></tr></table></td></tr></table></td></tr></table>\\n <table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-content\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" bgcolor=\\\"#ffffff\\\" style=\\\"padding:0;Margin:0;background-color:#ffffff\\\"><table bgcolor=\\\"#ffffff\\\" class=\\\"es-content-body\\\" align=\\\"center\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;width:650px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;padding-top:30px;padding-bottom:30px;font-size:0\\\"><table border=\\\"0\\\" width=\\\"100%\\\" height=\\\"100%\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td style=\\\"padding:0;Margin:0;border-bottom:0px solid #cccccc;background:none;height:1px;width:100%;margin:0px\\\"></td>\\n </tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr></table>\\n <table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-content\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0\\\"><table bgcolor=\\\"#ffffff\\\" class=\\\"es-content-body\\\" align=\\\"center\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;width:650px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;font-size:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-table-not-adapt es-social\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://www.facebook.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Facebook\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/facebook-circle-black.png\\\" alt=\\\"Facebook\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a>\\n</td><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://twitter.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Twitter\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/twitter-circle-black.png\\\" alt=\\\"Twitter\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td>\\n <td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://www.linkedin.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Linkedin\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/linkedin-circle-black.png\\\" alt=\\\"Linkedin\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td>\\n <td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://www.youtube.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Youtube\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/youtube-circle-black.png\\\" alt=\\\"Youtube\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td>\\n <td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0\\\"><a target=\\\"_blank\\\" href=\\\"https://www.instagram.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Instagram\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/instagram-circle-black.png\\\" alt=\\\"Instagram\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td></tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr></table>\\n <table class=\\\"es-footer ac-footer\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%;background-color:transparent;background-repeat:repeat;background-position:center top\\\"><tr><td align=\\\"center\\\" class=\\\"es-footer-body\\\" style=\\\"padding:0;Margin:0;background-color:transparent;padding-top:20px;padding-bottom:20px;background:inherit;font-family:inherit;font-size:12px;color:inherit\\\"><p style=\\\"Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:inherit;line-height:150%;color:inherit;font-size:inherit\\\">Enviado para: lucas-santos-oliveira@hotmail.com<br><br><a style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:inherit;font-size:inherit;font-family:inherit;font-weight:inherit\\\" href=\\\"https://elteste.emlnk.com/proc.php?nl=currentnl&amp;c=cmpgnid&amp;m=currentmesg&amp;s=928c15a9947337b869fef0bea6086e20&amp;act=unsub\\\" target=\\\"_blank\\\">Cancelar inscrição</a><br><br><span class=\\\"perstag_address\\\" style=\\\"color:inherit;font-family:inherit;font-size:inherit\\\"></span></p>\\n</td></tr></table></body></html>\\n\",'+
		'            \"tstamp\": \"2024-07-02T07:20:32-05:00\",'+
		'            \"series_id\": null,'+
		'            \"subscriber_series_id\": null,'+
		'            \"automation_name\": null,'+
		'            \"service_provider\": null,'+
		'            \"links\": {'+
		'                \"contact\": \"https://elteste.api-us1.com/api/3/emailActivities/24/contact\",'+
		'                \"deal\": \"https://elteste.api-us1.com/api/3/emailActivities/24/deal\",'+
		'                \"user\": \"https://elteste.api-us1.com/api/3/emailActivities/24/user\",'+
		'                \"reference\": \"https://elteste.api-us1.com/api/3/emailActivities/24/reference\",'+
		'                \"account\": \"https://elteste.api-us1.com/api/3/emailActivities/24/account\"'+
		'            },'+
		'            \"id\": \"24\",'+
		'            \"contact\": \"23\",'+
		'            \"deal\": null,'+
		'            \"user\": \"1\",'+
		'            \"reference\": {'+
		'                \"type\": \"log\",'+
		'                \"id\": \"33\"'+
		'            }'+
		'        },'+
		'        {'+
		'            \"subscriberid\": \"23\",'+
		'            \"userid\": \"1\",'+
		'            \"d_id\": \"0\",'+
		'            \"account\": null,'+
		'            \"reltype\": \"Log\",'+
		'            \"relid\": \"34\",'+
		'            \"from_name\": \"El Funileiro\",'+
		'            \"fromAddress\": \"suporte@elfunileiro.com.br\",'+
		'            \"toAddress\": \"lucas-santos-oliveira@hotmail.com\",'+
		'            \"ccAddress\": \"\",'+
		'            \"subject\": \"Teste Activities\",'+
		'            \"message\": \"Crie seu email aqui!\\n\\nLucas\\n\\nEste editor oferece a habilidade de personalizar totalmente o layout e o estilo dos seus emails. Você pode adicionar, remanejar e remover estruturas e seções.\\n\\nClick https://www.google.com/ \\n\\nhttps://www.facebook.com \\n\\nhttps://twitter.com \\n\\nhttps://www.linkedin.com \\n\\nhttps://www.youtube.com \\n\\nhttps://www.instagram.com \\n\\nEnviado para: lucas-santos-oliveira@hotmail.com\\n\\nCancelar inscrição https://elteste.activehosted.com/proc.php?nl=currentnl&amp;c=0&amp;m=0&amp;s=928c15a9947337b869fef0bea6086e20&amp;act=unsub\\n\\n\",'+
		'            \"messageHtml\": \"<!DOCTYPE html PUBLIC \\\"-//W3C//DTD XHTML 1.0 Transitional//EN\\\" \\\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\\\">\\n<html xmlns=\\\"http://www.w3.org/1999/xhtml\\\" xmlns:o=\\\"urn:schemas-microsoft-com:office:office\\\" lang=\\\"und\\\"><head><meta http-equiv=\\\"Content-Type\\\" content=\\\"text/html; charset=utf-8\\\"><meta name=\\\"viewport\\\" content=\\\"width=device-width, minimal-ui, initial-scale=1.0, maximum-scale=1.0, user-scalable=0;\\\"><meta http-equiv=\\\"X-UA-Compatible\\\" content=\\\"IE=edge\\\"><meta name=\\\"format-detection\\\" content=\\\"telephone=no, date=no, email=no, address=no\\\"><meta name=\\\"x-apple-disable-message-reformatting\\\"><title></title>\\n<!--[if (mso 16)]><style type=\\\"text/css\\\"> a { text-decoration: none; } </style><![endif]--> \\n<!--[if gte mso 9]><style> sup { font-size: 100% !important; } </style><![endif]--> \\n<!--[if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG></o:AllowPNG><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]--> \\n<!--[if gte mso 9]><style>sup { font-size: 100% !important; }</style><![endif]--> \\n<!--[if !mso]><!-- --><link href=\\\"https://fonts.googleapis.com/css?family=Roboto:400,400i,700,700i\\\" rel=\\\"stylesheet\\\"> \\n<!--<![endif]--><style type=\\\"text/css\\\">#outlook a { padding:0;}.es-button { mso-style-priority:100!important; text-decoration:none!important;}a[x-apple-data-detectors] { color:inherit!important; text-decoration:none!important; font-size:inherit!important; font-family:inherit!important; font-weight:inherit!important; line-height:inherit!important;}.es-desk-hidden { display:none; float:left; overflow:hidden; width:0; max-height:0; line-height:0; mso-hide:all;}\\n@media only screen and (max-width:600px) {p, ul li, ol li, a { line-height:150%!important } h1, h2, h3, h1 a, h2 a, h3 a { line-height:120% } h1 { font-size:30px!important; text-align:center } h2 { font-size:26px!important; text-align:center } h3 { font-size:20px!important; text-align:center } .es-header-body h1 a, .es-content-body h1 a, .es-footer-body h1 a { font-size:30px!important; text-align:left } .es-header-body h2 a, .es-content-body h2 a, .es-footer-body h2 a { font-size:26px!important; text-align:left } .es-header-body h3 a, .es-content-body h3 a, .es-footer-body h3 a { font-size:20px!important; text-align:left } .es-menu td a { font-size:13px!important } .es-header-body p, .es-header-body ul li, .es-header-body ol li, .es-header-body a { font-size:16px!important } .es-content-body p, .es-content-body ul li, .es-content-body ol li, .es-content-body a { font-size:16px!important }\\n .es-footer-body p, .es-footer-body ul li, .es-footer-body ol li, .es-footer-body a { font-size:16px!important } .es-infoblock p, .es-infoblock ul li, .es-infoblock ol li, .es-infoblock a { font-size:12px!important } *[class=\\\"gmail-fix\\\"] { display:none!important } .es-m-txt-c, .es-m-txt-c h1, .es-m-txt-c h2, .es-m-txt-c h3 { text-align:center!important } .es-m-txt-r, .es-m-txt-r h1, .es-m-txt-r h2, .es-m-txt-r h3 { text-align:right!important } .es-m-txt-l, .es-m-txt-l h1, .es-m-txt-l h2, .es-m-txt-l h3 { text-align:left!important } .es-m-txt-r img, .es-m-txt-c img, .es-m-txt-l img { display:inline!important } .es-button-border { display:inline-block!important } a.es-button, button.es-button { font-size:20px!important; display:inline-block!important } .es-adaptive table, .es-left, .es-right { width:100%!important }\\n .ac-footer, .es-content table, .es-header table, .es-footer table, .es-content, .es-footer, .es-header { width:100%!important; max-width:600px!important } .ac-footer td, .ac-footer p, .es-adapt-td { display:block!important; width:100%!important } .adapt-img { width:100%!important; height:auto!important } .es-m-p0 { padding:0px!important } .es-m-p0r { padding-right:0px!important } .es-m-p0l { padding-left:0px!important } .es-m-p0t { padding-top:0px!important } .es-m-p0b { padding-bottom:0!important } .es-m-p20b { padding-bottom:20px!important } .es-mobile-hidden, .es-hidden { display:none!important } tr.es-desk-hidden, td.es-desk-hidden, table.es-desk-hidden { width:auto!important; overflow:visible!important; float:none!important; max-height:inherit!important; line-height:inherit!important } tr.es-desk-hidden { display:table-row!important } table.es-desk-hidden { display:table!important }\\n td.es-desk-menu-hidden { display:table-cell!important } .es-menu td { width:1%!important } table.es-table-not-adapt, .esd-block-html table { width:auto!important } table.es-social { display:inline-block!important } table.es-social td { display:inline-block!important } .es-desk-hidden { display:table-row!important; width:auto!important; overflow:visible!important; max-height:inherit!important } }@media screen and (max-width:384px) {.mail-message-content { width:414px!important } }</style>\\n </head>\\n <body class=\\\"es-wrapper-color\\\" lang=\\\"und\\\" style=\\\"width:100%;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;padding:0;Margin:0;background-color:#FFFFFF\\\"><table class=\\\"es-wrapper\\\" width=\\\"100%\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;padding:0;Margin:0;width:100%;height:100%;background-repeat:repeat;background-position:center top;background-color:#FFFFFF\\\"><tr><td valign=\\\"top\\\" style=\\\"padding:0;Margin:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-content\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" bgcolor=\\\"#ffffff\\\" style=\\\"padding:0;Margin:0;background-color:#ffffff\\\"><table bgcolor=\\\"#ffffff\\\" class=\\\"es-content-body\\\" align=\\\"center\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;width:650px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;padding-top:40px\\\"><p style=\\\"Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;line-height:41px;color:#333333;font-size:14px\\\"><strong><span style=\\\"font-size:27px\\\">Crie seu email aqui!</span></strong><br></p>\\n<p style=\\\"Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;line-height:41px;color:#333333;font-size:14px\\\"><strong><span style=\\\"font-size:27px\\\"></span></strong><br>Lucas<br><br>Este editor oferece a habilidade de personalizar totalmente o layout e o estilo dos seus emails. Você pode adicionar, remanejar e remover estruturas e seções.</p></td></tr><tr><td align=\\\"center\\\" height=\\\"70\\\" style=\\\"padding:0;Margin:0\\\"></td></tr>\\n <tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0\\\"> \\n<!--[if mso]><a href=\\\"https://www.google.com/\\\" target=\\\"_blank\\\" hidden>\\n\\t<v:roundrect xmlns:v=\\\"urn:schemas-microsoft-com:vml\\\" xmlns:w=\\\"urn:schemas-microsoft-com:office:word\\\" esdevVmlButton href=\\\"https://www.google.com/\\\" \\n                style=\\\"height:36px; v-text-anchor:middle; width:79px\\\" arcsize=\\\"8%\\\" stroke=\\\"f\\\"  fillcolor=\\\"#004cff\\\">\\n\\t\\t<w:anchorlock></w:anchorlock>\\n\\t\\t<center style=\'color:#ffffff; font-family:roboto, \\\"helvetica neue\\\", helvetica, arial, sans-serif; font-size:12px; font-weight:400; line-height:12px;  mso-text-raise:1px\'>Click</center>\\n\\t</v:roundrect></a>\\n<![endif]--> \\n<!--[if !mso]><!-- --><span class=\\\"msohide es-button-border\\\" style=\\\"border-style:solid;border-color:#004CFF;background:#004CFF;border-width:0px;display:inline-block;border-radius:3px;width:auto;mso-hide:all\\\"><a href=\\\"https://www.google.com/\\\" class=\\\"es-button\\\" target=\\\"_blank\\\" style=\\\"mso-style-priority:100 !important;text-decoration:none;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;color:#FFFFFF;font-size:14px;padding:10px 15px 10px 15px;display:inline-block;background:#004CFF;border-radius:3px;font-family:roboto, \'helvetica neue\', helvetica, arial, sans-serif;font-weight:normal;font-style:normal;line-height:17px;width:auto;text-align:center;mso-padding-alt:0;mso-border-alt:10px solid #004CFF\\\">Click</a></span> \\n<!--<![endif]--></td>\\n </tr></table></td></tr></table></td></tr></table></td></tr></table>\\n <table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-content\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" bgcolor=\\\"#ffffff\\\" style=\\\"padding:0;Margin:0;background-color:#ffffff\\\"><table bgcolor=\\\"#ffffff\\\" class=\\\"es-content-body\\\" align=\\\"center\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;width:650px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;padding-top:30px;padding-bottom:30px;font-size:0\\\"><table border=\\\"0\\\" width=\\\"100%\\\" height=\\\"100%\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td style=\\\"padding:0;Margin:0;border-bottom:0px solid #cccccc;background:none;height:1px;width:100%;margin:0px\\\"></td>\\n </tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr></table>\\n <table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-content\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0\\\"><table bgcolor=\\\"#ffffff\\\" class=\\\"es-content-body\\\" align=\\\"center\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:650px\\\"><tr><td align=\\\"left\\\" style=\\\"padding:0;Margin:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;width:650px\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" style=\\\"padding:0;Margin:0;font-size:0\\\"><table cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" class=\\\"es-table-not-adapt es-social\\\" role=\\\"presentation\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px\\\"><tr><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://www.facebook.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Facebook\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/facebook-circle-black.png\\\" alt=\\\"Facebook\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a>\\n</td><td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://twitter.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Twitter\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/twitter-circle-black.png\\\" alt=\\\"Twitter\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td>\\n <td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://www.linkedin.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Linkedin\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/linkedin-circle-black.png\\\" alt=\\\"Linkedin\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td>\\n <td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0;padding-right:10px\\\"><a target=\\\"_blank\\\" href=\\\"https://www.youtube.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Youtube\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/youtube-circle-black.png\\\" alt=\\\"Youtube\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td>\\n <td align=\\\"center\\\" valign=\\\"top\\\" style=\\\"padding:0;Margin:0\\\"><a target=\\\"_blank\\\" href=\\\"https://www.instagram.com\\\" style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#0000EE;font-size:14px\\\"><img title=\\\"Instagram\\\" src=\\\"https://stripo.cluster.app-us1.com/static/assets/img/social-icons/circle-black/instagram-circle-black.png\\\" alt=\\\"Instagram\\\" width=\\\"32\\\" style=\\\"display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic\\\"></a></td></tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr></table>\\n <table class=\\\"es-footer ac-footer\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" align=\\\"center\\\" role=\\\"none\\\" style=\\\"mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%;background-color:transparent;background-repeat:repeat;background-position:center top\\\"><tr><td align=\\\"center\\\" class=\\\"es-footer-body\\\" style=\\\"padding:0;Margin:0;background-color:transparent;padding-top:20px;padding-bottom:20px;background:inherit;font-family:inherit;font-size:12px;color:inherit\\\"><p style=\\\"Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:inherit;line-height:150%;color:inherit;font-size:inherit\\\">Enviado para: lucas-santos-oliveira@hotmail.com<br><br><a style=\\\"-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:inherit;font-size:inherit;font-family:inherit;font-weight:inherit\\\" href=\\\"https://elteste.activehosted.com/proc.php?nl=currentnl&amp;c=cmpgnid&amp;m=currentmesg&amp;s=928c15a9947337b869fef0bea6086e20&amp;act=unsub\\\" target=\\\"_blank\\\">Cancelar inscrição</a><br><br><span class=\\\"perstag_address\\\" style=\\\"color:inherit;font-family:inherit;font-size:inherit\\\"></span></p>\\n</td></tr></table></body></html>\\n\",'+
		'            \"tstamp\": \"2024-07-02T07:42:34-05:00\",'+
		'            \"series_id\": null,'+
		'            \"subscriber_series_id\": null,'+
		'            \"automation_name\": null,'+
		'            \"service_provider\": null,'+
		'            \"links\": {'+
		'                \"contact\": \"https://elteste.api-us1.com/api/3/emailActivities/25/contact\",'+
		'                \"deal\": \"https://elteste.api-us1.com/api/3/emailActivities/25/deal\",'+
		'                \"user\": \"https://elteste.api-us1.com/api/3/emailActivities/25/user\",'+
		'                \"reference\": \"https://elteste.api-us1.com/api/3/emailActivities/25/reference\",'+
		'                \"account\": \"https://elteste.api-us1.com/api/3/emailActivities/25/account\"'+
		'            },'+
		'            \"id\": \"25\",'+
		'            \"contact\": \"23\",'+
		'            \"deal\": null,'+
		'            \"user\": \"1\",'+
		'            \"reference\": {'+
		'                \"type\": \"log\",'+
		'                \"id\": \"34\"'+
		'            }'+
		'        }'+
		'    ],'+
		'    \"meta\": {'+
		'        \"total\": \"4\"'+
		'    }'+
		'}';

        OPENLIST_JSON = '{'+
		'    \"0\": {'+
		'        \"subscriberid\": \"23\",'+
		'        \"email\": \"lucas-santos-oliveira@hotmail.com\",'+
		'        \"tstamp\": \"2024-07-02 09:37:43\",'+
		'        \"times\": \"1\",'+
		'        \"tstamp_iso\": \"2024-07-02T07:37:43-05:00\"'+
		'    },'+
		'    \"result_code\": 1,'+
		'    \"result_message\": \"Sucesso:algo retornou\",'+
		'    \"result_output\": \"json\"'+
		'}';

        CLICKLIST_JSON = '{'+
		'    \"0\": {'+
		'        \"id\": \"3321\",'+
		'        \"name\": \"\",'+
		'        \"link\": \"https://www.facebook.com\",'+
		'        \"tracked\": \"1\",'+
		'        \"a_unique\": \"0\",'+
		'        \"a_total\": \"0\",'+
		'        \"info\": []'+
		'    },'+
		'    \"1\": {'+
		'        \"id\": \"3322\",'+
		'        \"name\": \"\",'+
		'        \"link\": \"https://twitter.com\",'+
		'        \"tracked\": \"1\",'+
		'        \"a_unique\": \"0\",'+
		'        \"a_total\": \"0\",'+
		'        \"info\": []'+
		'    },'+
		'    \"2\": {'+
		'        \"id\": \"3323\",'+
		'        \"name\": \"\",'+
		'        \"link\": \"https://www.linkedin.com\",'+
		'        \"tracked\": \"1\",'+
		'        \"a_unique\": \"0\",'+
		'        \"a_total\": \"0\",'+
		'        \"info\": []'+
		'    },'+
		'    \"3\": {'+
		'        \"id\": \"3324\",'+
		'        \"name\": \"\",'+
		'        \"link\": \"https://www.youtube.com\",'+
		'        \"tracked\": \"1\",'+
		'        \"a_unique\": \"0\",'+
		'        \"a_total\": \"0\",'+
		'        \"info\": []'+
		'    },'+
		'    \"4\": {'+
		'        \"id\": \"3325\",'+
		'        \"name\": \"\",'+
		'        \"link\": \"https://www.instagram.com\",'+
		'        \"tracked\": \"1\",'+
		'        \"a_unique\": \"0\",'+
		'        \"a_total\": \"0\",'+
		'        "info": ['+
		'            {'+
		'                "email": "tests@tests.com",'+
		'                "phone": "",'+
		'                "customer_acct_name": "",'+
		'                "subscriberid": "23",'+
		'                "tstamp": "2024-07-02 09:47:07",'+
		'                "times": "1",'+
		'                "tstamp_iso": "2024-07-02T07:47:07-05:00"'+
		'            }'+
		'        ]'+
		'    },'+
		'    \"result_code\": 1,'+
		'    \"result_message\": \"Sucesso:algo retornou\",'+
		'    \"result_output\": \"json\"'+
		'}';
    }
}