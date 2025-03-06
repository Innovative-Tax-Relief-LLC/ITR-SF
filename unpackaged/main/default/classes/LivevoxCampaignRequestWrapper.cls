public with sharing class LivevoxCampaignRequestWrapper {
    public List<CampaignRecord> records {get;set;}

	public class CampaignRecord {
		public String phone1 {get;set;}	
		public String account {get;set;}	
		public String firstName {get;set;}	
		public String lastName {get;set;}
       }
       
       public LivevoxCampaignRequestWrapper(Lead lead){
           records = new List<CampaignRecord>();
           CampaignRecord record = new CampaignRecord();
           record.phone1 = lead.MobilePhone.replaceAll('[\\(\\)\\-\\s]', '');
           //record.account = lead.Velocify_Id__c;
           record.firstName = lead.FirstName;
           record.lastName = lead.LastName;
           records.add(record);

       }
}