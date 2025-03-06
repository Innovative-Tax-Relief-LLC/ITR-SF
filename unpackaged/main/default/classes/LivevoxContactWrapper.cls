public inherited sharing class LivevoxContactWrapper {
    public class LivevoxCreateContactDetails {
        public LivevoxContactDetails createContactDetails {get;set;}
    }

    public class LivevoxUpdateContactDetails {
        public LivevoxContactDetails updateContactDetails {get;set;}
    }
    public class LivevoxContactDetails {
        public LiveboxContactPerson person {get;set;}
        public List<LivevoxContactPhone> phone {get;set;}
        public List<LivevoxCustomFields> customFields {get;set;}
        public String account {get;set;}	//1234556
        public boolean active {get;set;}
        public String address1 {get;set;}	//123 Main St
        public String state {get;set;}
        public String city {get;set;}
    }
    public class LiveboxContactPerson {
        public String firstName {get;set;}	//James
        public String lastName {get;set;}	//22
        public String email {get;set;}	//example@liveox.com
        public String zipCode {get;set;}	//94043
    }
    public class LivevoxContactPhone {
        public String phone {get;set;}	//6503517500
        public Integer ordinal {get;set;}	//1
    }
    public class LivevoxCustomFields {
        public String field {get;set;}	//COL1
        public Object value {get;set;}	//123
    }

    public static LivevoxCreateContactDetails getLiveboxCreateContactDetailsWrapper(Lead lead) {
        System.debug('lead here ' + lead);
        List<LivevoxCustomFields> livevoxContactCustomFields = new List<LivevoxCustomFields>();
        List<LivevoxContactPhone> livevoxContactPhones = new List<LivevoxContactPhone>();
        LivevoxContactDetails contact = new LivevoxContactDetails();
       // contact.account = String.valueOf(lead.Velocify_Id__c);
        contact.address1 = lead.Street == null ? '': lead.Street;
        contact.state = lead.State == null ? '': lead.State;
        contact.city = lead.City == null ? '': lead.City;
        contact.active = true;
        contact.person = new LiveboxContactPerson();
        contact.person.firstName = lead.FirstName;
        contact.person.lastName = lead.LastName;
        contact.person.email = lead.Email  == null ? '': lead.Email;
        contact.person.zipCode = lead.PostalCode == null ? '': lead.PostalCode;
        LivevoxContactPhone leadPhone = new LivevoxContactPhone();
        leadPhone.phone = lead.MobilePhone == null ? '': lead.MobilePhone.replaceAll('[\\(\\)\\-\\s]', '');
        leadPhone.ordinal = 1;
        livevoxContactPhones.add(leadPhone);
        // LivevoxContactPhone mobilePhone = new LivevoxContactPhone();
        // mobilePhone.phone = lead.MobilePhone == null ? lead.Phone.replaceAll('[\\(\\)\\-\\s]', '') : lead.MobilePhone.replaceAll('[\\(\\)\\-\\s]', '');
        // mobilePhone.ordinal = 2;
        // livevoxContactPhones.add(mobilePhone);
        contact.phone = livevoxContactPhones;
        LivevoxCustomFields leadIdCustom = new LivevoxCustomFields();
        leadIdCustom.field = 'COL17';
        leadIdCustom.value = String.valueOf(lead.Id);
        livevoxContactCustomFields.add(leadIdCustom);
        LivevoxCustomFields leadSourceCustom = new LivevoxCustomFields();
        leadSourceCustom.field = 'COL7';
        leadSourceCustom.value = String.valueOf(lead.LeadSource);
        livevoxContactCustomFields.add(leadSourceCustom);
        LivevoxCustomFields leadCreatedDateCustom = new LivevoxCustomFields();
        leadCreatedDateCustom.field = 'COL5';
        leadCreatedDateCustom.value = lead.CreatedDate ==null ? Datetime.now().format('MM/DD/YYYY') : lead.CreatedDate.format('MM/DD/YYYY');
        livevoxContactCustomFields.add(leadCreatedDateCustom);
        LivevoxCustomFields totalTaxDebtCustom = new LivevoxCustomFields();
        totalTaxDebtCustom.field = 'COL11';
        totalTaxDebtCustom.value = lead.Total_Tax_Debt__c == null? 0 : lead.Total_Tax_Debt__c;
        livevoxContactCustomFields.add(totalTaxDebtCustom);
        LivevoxCustomFields leadStatusCustom = new LivevoxCustomFields();
        leadStatusCustom.field = 'COL15';
        leadStatusCustom.value = String.valueOf(lead.Status) == null ? '': String.valueOf(lead.Status);
        livevoxContactCustomFields.add(leadStatusCustom);
        LivevoxCustomFields leadSubStatusCustom = new LivevoxCustomFields();
        leadSubStatusCustom.field = 'COL16';
        leadSubStatusCustom.value = String.valueOf(lead.Sub_Status__c) == null ? '': String.valueOf(lead.Sub_Status__c);
        livevoxContactCustomFields.add(leadSubStatusCustom);
        contact.customFields = livevoxContactCustomFields;
        
        LivevoxCreateContactDetails createContactDetail = new LivevoxCreateContactDetails();
        createContactDetail.createContactDetails = contact;

        return createContactDetail;
    }

    public static LivevoxUpdateContactDetails getLiveboxUpdateDetailsWrapper(Lead lead) {
        System.debug('lead here ' + lead);
        List<LivevoxCustomFields> livevoxContactCustomFields = new List<LivevoxCustomFields>();
        List<LivevoxContactPhone> livevoxContactPhones = new List<LivevoxContactPhone>();
        LivevoxContactDetails contact = new LivevoxContactDetails();
        //contact.account = String.valueOf(lead.Velocify_Id__c);
        contact.address1 = lead.Street == null ? '': lead.Street;
        contact.state = lead.State == null ? '': lead.State;
        contact.city = lead.City == null ? '': lead.City;
        contact.active = true;
        contact.person = new LiveboxContactPerson();
        contact.person.firstName = lead.FirstName;
        contact.person.lastName = lead.LastName;
        contact.person.email = lead.Email  == null ? '': lead.Email;
        contact.person.zipCode = lead.PostalCode == null ? '': lead.PostalCode;
        LivevoxContactPhone leadPhone = new LivevoxContactPhone();
        leadPhone.phone = lead.MobilePhone == null ? '': lead.MobilePhone.replaceAll('[\\(\\)\\-\\s]', '');
        leadPhone.ordinal = 1;
        livevoxContactPhones.add(leadPhone);
        // LivevoxContactPhone mobilePhone = new LivevoxContactPhone();
        // mobilePhone.phone = lead.MobilePhone == null ? lead.Phone.replaceAll('[\\(\\)\\-\\s]', '') : lead.MobilePhone.replaceAll('[\\(\\)\\-\\s]', '');
        // mobilePhone.ordinal = 2;
        // livevoxContactPhones.add(mobilePhone);
        contact.phone = livevoxContactPhones;
        LivevoxCustomFields leadIdCustom = new LivevoxCustomFields();
        leadIdCustom.field = 'COL17';
        leadIdCustom.value = String.valueOf(lead.Id);
        livevoxContactCustomFields.add(leadIdCustom);
        LivevoxCustomFields leadSourceCustom = new LivevoxCustomFields();
        leadSourceCustom.field = 'COL7';
        leadSourceCustom.value = String.valueOf(lead.LeadSource);
        livevoxContactCustomFields.add(leadSourceCustom);
        LivevoxCustomFields leadCreatedDateCustom = new LivevoxCustomFields();
        leadCreatedDateCustom.field = 'COL5';
        leadCreatedDateCustom.value = lead.CreatedDate ==null ? Datetime.now().format('MM/DD/YYYY') : lead.CreatedDate.format('MM/DD/YYYY');
        livevoxContactCustomFields.add(leadCreatedDateCustom);
        LivevoxCustomFields totalTaxDebtCustom = new LivevoxCustomFields();
        totalTaxDebtCustom.field = 'COL11';
        totalTaxDebtCustom.value = lead.Total_Tax_Debt__c;
        livevoxContactCustomFields.add(totalTaxDebtCustom);
        LivevoxCustomFields leadStatusCustom = new LivevoxCustomFields();
        leadStatusCustom.field = 'COL15';
        leadStatusCustom.value = String.valueOf(lead.Status) == null ? '': String.valueOf(lead.Status);
        livevoxContactCustomFields.add(leadStatusCustom);
        LivevoxCustomFields leadSubStatusCustom = new LivevoxCustomFields();
        leadSubStatusCustom.field = 'COL16';
        leadSubStatusCustom.value = String.valueOf(lead.Sub_Status__c) == null ? '': String.valueOf(lead.Sub_Status__c);
        livevoxContactCustomFields.add(leadSubStatusCustom);
        contact.customFields = livevoxContactCustomFields;
        
        LivevoxUpdateContactDetails updateContactDetail = new LivevoxUpdateContactDetails();
        updateContactDetail.updateContactDetails = contact;

        return updateContactDetail;
    }

    public static List<LivevoxCreateContactDetails> getBulkCreateContactsBody(List<Lead> leads) {
        List<LivevoxCreateContactDetails> livevoxCreateContactDetails = new List<LivevoxCreateContactDetails>();
        for(Lead lead : leads) {
            livevoxCreateContactDetails.add(getLiveboxCreateContactDetailsWrapper(lead));
        }
        System.debug('livevoxCreateContactDetails ' + livevoxCreateContactDetails + ' size ' + livevoxCreateContactDetails.size());
        String body = JSON.serialize(livevoxCreateContactDetails);
        System.debug('request body contact ' + body);
        return livevoxCreateContactDetails;
    }

    public static List<LivevoxUpdateContactDetails> getBulkUpdateContactsBody(List<Lead> leads) {
        List<LivevoxUpdateContactDetails> livevoxUpdateContactDetails = new List<LivevoxUpdateContactDetails>();
        for(Lead lead : leads) {
            livevoxUpdateContactDetails.add(getLiveboxUpdateDetailsWrapper(lead));
        }
        System.debug('livevoxUpdateContactDetails ' + livevoxUpdateContactDetails + ' size ' + livevoxUpdateContactDetails.size());
        String body = JSON.serialize(livevoxUpdateContactDetails);
        System.debug('request body contact ' + body);
        return livevoxUpdateContactDetails;
    }

}