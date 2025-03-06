/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class P360_API_v1 {
    global static List<bt_stripe.P360_API_v1.Customer> customerList;
    global static List<bt_stripe.P360_API_v1.PM> paymentMethodList;
    global static List<bt_stripe.P360_API_v1.Tra> transList;
    global P360_API_v1() {

    }
    global static void commitWork() {

    }
    global static bt_stripe.P360_API_v1.Customer customerFactory() {
        return null;
    }
    global static bt_stripe.P360_API_v1.Customer customerFactory(Id customerId) {
        return null;
    }
    global static bt_stripe.P360_API_v1.Customer customerFactory(Schema.SObjectField parentField, Id parentId, Id paymentGatewayId, String name, String email) {
        return null;
    }
    global static bt_stripe.P360_API_v1.PM paymentMethodFactory() {
        return null;
    }
    global static bt_stripe.P360_API_v1.PM paymentMethodFactory(Id paymentMethodId) {
        return null;
    }
    global static bt_stripe.P360_API_v1.Tra transactionFactory() {
        return null;
    }
    global static bt_stripe.P360_API_v1.Tra transactionFactory(Id transId) {
        return null;
    }
global class Customer {
    global Id accountId;
    global Id contactId;
    global String email;
    global Id leadId;
    global String name;
    global Id paymentGatewayId;
    global String phone;
    global bt_stripe__Stripe_Customer__c record;
    global void registerCustomer() {

    }
    global void updateCustomer() {

    }
}
global class P360_Exception extends Exception {
}
global class PM {
    global String accountId;
    global String accountNumber;
    global String cardExpMonth;
    global String cardExpYear;
    global String cardHolderName;
    global String cardNumber;
    global String city;
    global Id connectedAccountId;
    global String contactId;
    global String country;
    global bt_stripe.P360_API_v1.Customer customer;
    global String cvv;
    global Boolean defaultpm;
    global String email;
    global Boolean enableMoto;
    global String holderType;
    global Boolean isACH;
    global String leadId;
    global Id paymentGatewayId;
    global String postalCode;
    global bt_stripe__Payment_Method__c record;
    global String routingNumber;
    global String state;
    global String status {
        get;
    }
    global String street;
    global String stripeToken;
    global void registerExternalAccount() {

    }
    global void registerPM() {

    }
    global void updatePM() {

    }
}
global class PmtSchd {
    global Boolean autoCapture;
    global Boolean captureFirst;
    global Integer count;
    global String currencyISO;
    global String dayOfMonth;
    global String dayOfWeek;
    global String description;
    global Decimal eachAmount;
    global Date endDate;
    global Integer frequency;
    global Decimal initialAmount;
    global String monthOfYear;
    global String onThe;
    global bt_stripe.P360_API_v1.PM pm;
    global String preset;
    global bt_stripe__Payment_Schedule__c record;
    global String recurrenceMethod;
    global String repeats;
    global Date startDate;
    global Decimal totalAmount;
    global PmtSchd() {

    }
    global void generate() {

    }
    global void saveDraft() {

    }
}
global class Tra {
    global Decimal amount;
    global Boolean authOnly;
    global Boolean autoCapture;
    global String currencyCode;
    global String description {
        get;
        set;
    }
    global Date dueDate;
    global Id paymentGatewayId {
        get;
        set;
    }
    global String paymentStatus {
        get;
    }
    global bt_stripe.P360_API_v1.PM pm {
        get;
        set;
    }
    global bt_stripe__Transaction__c record;
    global String transactionStatus {
        get;
    }
    global void authorize() {

    }
    global void capture() {

    }
    global Boolean findAndUpsertTransactionFromStripe() {
        return null;
    }
    global void refund() {

    }
    global void refund(Decimal refundAmount) {

    }
    global void register() {

    }
    global void setParent(Schema.SObjectField field, Object value) {

    }
    global void updateTransaction() {

    }
}
}
