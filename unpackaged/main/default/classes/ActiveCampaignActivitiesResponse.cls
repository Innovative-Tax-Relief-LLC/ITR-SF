public with sharing class ActiveCampaignActivitiesResponse {
    
    public List<LinkData> linkData; 
	public List<Logs> logs; 
	public List<ContactLists> contactLists; 
	public List<ContactAutomations> contactAutomations; 
	public List<Activities> activities; 
	public Meta meta; 

	public class LinkData {
		public String linkid; 
		public String isread; 
		public String campaignid; 
		public String messageid; 
		public String tstamp; 
		public String subscriberid; 
		public String email; 
		public String times; 
		public String ip; 
		public String ua; 
		public String uasrc; 
		public String referer; 
		public String created_timestamp; 
		public String updated_timestamp; 
		public String created_by; 
		public String updated_by; 
		public String ip6; 
		public Links links; 
		public String id; 
		public String link; 
		public String contact; 
		public String campaign; 
		public String message; 
	}

	public class Logs {
		public String campaignid; 
		public String messageid; 
		public String sendid; 
		public String subscriberid; 
		public String successful; 
		public String tstamp; 
		public String comment; 
		public String created_timestamp; 
		public String updated_timestamp; 
		public String created_by; 
		public String updated_by; 
		public Links_Z links; 
		public String id; 
		public String contact; 
		public String campaign; 
		public String message; 
	}

	public class Links_Z {
		public String contact; 
		public String campaign; 
		public String message; 
		public String activity; 
	}

	public class ContactLists {
		public String contact; 
		public String list_Z; // in json: list
		public String form; 
		public String seriesid; 
		public String sdate; 
		public String udate; 
		public String status; 
		public String responder; 
		public String sync; 
		public String unsubreason; 
		public String campaign; 
		public String message; 
		public String first_name; 
		public String last_name; 
		public String ip4Sub; 
		public String sourceid; 
		public String autosyncLog; 
		public String ip4_last; 
		public String ip4Unsub; 
		public String created_timestamp; 
		public String updated_timestamp; 
		public String created_by; 
		public String updated_by; 
		public String unsubscribeAutomation; 
		public Links_Y links; 
		public String id; 
		public String automation; 

		public ContactLists(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'list') {
							list_Z = parser.getText();
						}
					}
				}
			}
		}
	}

	public class Links {
		public String link; 
		public String contact; 
		public String campaign; 
		public String message; 
	}

	public class Links_Y {
		public String automation; 
		public String list_Z; // in json: list
		public String contact; 
		public String form; 
		public String autosyncLog; 
		public String campaign; 
		public String unsubscribeAutomation; 
		public String message; 

		public Links_Y(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'list') {
							list_Z = parser.getText();
						}
					}
				}
			}
		}
	}

	public class ContactAutomations {
		public String contact; 
		public String seriesid; 
		public String startid; 
		public String status; 
		public String batchid; 
		public String adddate; 
		public String remdate; 
		public String timespan; 
		public String lastblock; 
		public String lastlogid; 
		public String lastdate; 
		public String in_als; 
		public Integer completedElements; 
		public Integer totalElements; 
		public Integer completed; 
		public Integer completeValue; 
		public Links_X links; 
		public String id; 
		public String automation; 
	}

	public class Links_X {
		public String automation; 
		public String contact; 
		public String contactGoals; 
		public String automationLogs; 
	}

	public class Activities {
		public String tstamp; 
		public String subscriberid; 
		public String reference_type; 
		public String reference_id; 
		public String reference_action; 
		public String jsonData; 
		public String userid; 
		public String permission; 
		public String referenceModelName; 
		public Reference reference; 
		public Links_W links; 
		public String id; 
		public String user; 
	}

	public class Reference {
		public String type; 
		public String id; 
	}

	public class Links_W {
		public String user; 
		public String recipients; 
		public String reference; 
		public String notes; 
	}

	public class Meta {
		public String total; 
	}

	public static ActiveCampaignActivitiesResponse parse(String json){
		return (ActiveCampaignActivitiesResponse) System.JSON.deserialize(json, ActiveCampaignActivitiesResponse.class);
	}
}