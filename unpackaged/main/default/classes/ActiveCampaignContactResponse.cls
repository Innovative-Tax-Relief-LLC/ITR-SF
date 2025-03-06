public with sharing class ActiveCampaignContactResponse {

    public List<ScoreValues> scoreValues;
	public List<Contacts> contacts;
	public Meta meta;

	public class ScoreValues {}

	public class Contacts {
		public String cdate;
		public String email; 
		public String phone;
		public String firstName;
		public String lastName; 
		public String orgid;
		public String orgname; 
		public String segmentio_id;
		public String bounced_hard;
		public String bounced_soft;
		public Object bounced_date;
		public String ip;
		public String ua;
		public String hash;
		public Object socialdata_lastcheck;
		public String email_local;
		public String email_domain;
		public String sentcnt;
		public String rating_tstamp;
		public String gravatar;
		public String deleted;
		public String anonymized;
		public String adate;
		public String udate;
		public String edate;
		public Object deleted_at;
		public String created_utc_timestamp;
		public String updated_utc_timestamp;
		public String created_timestamp;
		public String updated_timestamp;
		public String created_by;
		public String updated_by;
		public String mpp_tracking;
		public String last_click_date;
		public String last_open_date;
		public Object last_mpp_open_date;
		public List<ScoreValues> scoreValues;
		public List<ScoreValues> accountContacts;
		public Links links;
		public String id;
		public Object organization;
	}

	public class Meta {
		public Page_input page_input;
		public String total;
		public Boolean sortable;
	}

	public class Links {
		public String bounceLogs;
		public String contactAutomations;
		public String contactData;
		public String contactGoals;
		public String contactLists;
		public String contactLogs;
		public String contactTags;
		public String contactDeals;
		public String deals;
		public String fieldValues;
		public String geoIps;
		public String notes;
		public String organization;
		public String plusAppend;
		public String trackingLogs;
		public String scoreValues;
		public String accountContacts;
		public String automationEntryCounts;
	}

	public class Page_input {
		public Object segmentid;
		public Integer formid;
		public Integer listid;
		public Integer tagid;
		public Integer limit_Z;// in json: limit
		public Integer offset;
		public Object search;
		public Object sort_Z;// in json: sort
		public Integer seriesid;
		public Integer waitid;
		public Integer status;
		public Integer forceQuery;
		public String cacheid;

		public Page_input(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'limit') {
							limit_Z = parser.getIntegerValue();
						} else if (text == 'sort') {
							sort_Z = parser.readValueAs(Object.class);
						}
					}
				}
			}
		}
	}

    public static ActiveCampaignContactResponse parse(String json) {
		return (ActiveCampaignContactResponse) System.JSON.deserialize(json, ActiveCampaignContactResponse.class);
	}
}