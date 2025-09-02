global with sharing class VelocifyClientPayload {

    public String api_version;
    public String token;
    public ClientData client_data;

    global class ClientData {
        public String flipped_client;
        public Integer is_business;
        public Integer has_income_tax;
        public Integer has_employment_taxes;
        public Integer has_civil_penalty;
        public String first_name;
        public String middle_name;
        public String last_name;
        public String date_of_birth;
        public String state;
        public String city;
        public String street;
        public String zip;
        public String home_phone;
        public String work_phone;
        public String cell_phone;
        public String email;
        public String spouse_first_name;
        public String spouse_middle_initial;
        public String spouse_last_name;
        public String spouse_date_of_birth;
        public String spouse_mobile_phone;
        public String spouse_email;
        public String notes;
        public Integer priority;
        public String client_source_text;
        public Boolean SMS_Opt_Out;
        public String occupation;
        public String occupation_category;
        public String SalesforceObjectId;
        public String profile_id;
        public String opportunity_type;
        public Services services;
        public PaymentsDetails payments_details;
        public List<BillingInfo> billing_info;
        public String SecondStandardPayment;
        public String payment_threshold;
        public String second_trade_received_agreement_date;
        public String tax_type;
        public String solution_type;
        public String first_trader;
        public String second_trader;
        public LenderInfo lender_info;
        public ThirdPartyInfor third_party_info;
        public String marital_status;
        public String social_security_number;
        public String gender;
        public String date_of_marriage_to_current_spouse;
        public String spanish_speaking;
        public String agency;
        public String time_zone;
        public String spouse_gender;
        public String spouse_social_security;
        public String spouse_occupation;
        public String spouse_occupation_category;
        public String client_is_homeowner;
        public String client_owns_more_than_1_real_estate_property;
        public String client_wage_and_income_shows_form_1098;
        public String spouse_is_a_homeowner;
        public String spouse_owns_more_than_1_real_estate_property;
        public String spouse_wage_and_income_shows_form_1098;
    }

    global class Services {
        public ServiceDetails service_details;
    }
    
    global class ServiceDetails {
        public String ExploratoryServiceType;
        public String Service1;
        public String Service2;
        public String ServiceResolutionType1_1;
        public String ServiceResolutionType2_1;
        public String ServiceResolutionType3_1;
        public String ServiceResolutionType4_1;
        public String ServiceResolutionType5_1;
        public String ServiceResolutionType6_1;
        public String YearsToFile1;
        public String YearsToFile2;
        public String YearsToFile3;
        public String YearsToFile4;
        public String GrossResolutionCosts;
        public String NetResolutionCost;
    }

    global class PaymentsDetails {
        public DownPayment down_payment;
        public List<StandardPayment> standard_payments;
    }

    global class DownPayment {
        public String down_payment_1_date;
        public String down_payment_1;
        public String down_payment_2_date;
        public String down_payment_2;
        public String down_payment_3_date;
        public String down_payment_3;
        public String down_payment_4_date;
        public String down_payment_4;
    }

    global class StandardPayment {
        public String date_1;
        public String amount_1;
        public String date_2;
        public String amount_2;
        public String date_3;
        public String amount_3;
        public String date_4;
        public String amount_4;
        public String date_5;
        public String amount_5;
        public String date_6;
        public String amount_6;
        public String date_7;
        public String amount_7;
        public String date_8;
        public String amount_8;
        public String date_9;
        public String amount_9;
        public String date_10;
        public String amount_10;
        public String date_11;
        public String amount_11;
        public String date_12;
        public String amount_12;
    }

    global class BillingInfo {
        public String holder_name;
        public String card_number;
        public String account_number;
        public String routing_number;
        public String type_id;
        public String cvv;
        public String expire_year;
        public String expire_month;
        public String address;
        public String city;
        public String state;
        public String zip;
        public String recurrent_payment;
        public String account_holder_type;
    }

    global class LenderInfo {
        public String financing_lender_used;
        public String offered_client_financing;
        public String agreed_client_financing;
        public String approved_for_financing;
        public String resquest_amount_to_be_financed;
    }

    global class ThirdPartyInfor {
        public String third_party_name;
        public String third_party_phone_number;
        public String third_party_billing_street;
        public String third_party_email;
        public String third_party_relationship;
        public String third_party_city;
        public String third_party_state;
        public String third_party_zip;
    }
}