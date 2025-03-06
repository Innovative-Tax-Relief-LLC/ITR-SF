public with sharing class ActiveCampaignEmailActivitiesResponse {

	public List<EmailActivities> emailActivities;
	public Meta meta;

	public class EmailActivities {
		public String subscriberid;
		public String userid;
		public String d_id;
		public Object account;
		public String reltype;
		public String relid;
		public String from_name;
		public String fromAddress;
		public String toAddress;
		public String ccAddress;
		public String subject;
		public String message;
		public String messageHtml;
		public String tstamp;
		public Object series_id;
		public Object subscriber_series_id;
		public Object automation_name;
		public Object service_provider;
		public Links links;
		public String id;
		public String contact;
		public Object deal;
		public String user;
		public Reference reference;
	}

	public class Reference {
		public String type;
		public String id;
	}

	public class Links {
		public String contact;
		public String deal;
		public String user;
		public String reference;
		public String account;
	}

    public class Meta {
		public String total;
	}
	
	public static ActiveCampaignEmailActivitiesResponse parse(String json) {
		return (ActiveCampaignEmailActivitiesResponse) System.JSON.deserialize(json, ActiveCampaignEmailActivitiesResponse.class);
	}
}