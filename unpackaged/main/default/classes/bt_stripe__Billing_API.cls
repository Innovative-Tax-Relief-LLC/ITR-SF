/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Billing_API {
    global Billing_API() {

    }
    global static void commitWork() {

    }
global virtual class APIClass {
    global APIClass() {

    }
}
global virtual class LI extends bt_stripe.Billing_API.APIClass {
    global Decimal additionalDiscountAmount;
    global Decimal additionalDiscountPercentage;
    global String description;
    global Decimal discountAmount;
    global Id eventItemId;
    global Id id;
    global Decimal listPrice;
    global Decimal netAmount;
    global Id priceBookId;
    global Id productId;
    global String productName;
    global Decimal quantity;
    global Decimal subtotalAmount;
    global Decimal totalAmount;
    global Decimal unitPrice;
    global LI() {

    }
}
global virtual class SD extends bt_stripe.Billing_API.APIClass {
    global Decimal additionalDiscountAmount;
    global Decimal additionalDiscountPercentage;
    global Id billToAccountId;
    global String billToCity;
    global Id billToContactId;
    global String billToCountry;
    global String billToPostalCode;
    global String billToState;
    global String billToStreet;
    global String currencyISO;
    global Decimal discountAmount;
    global Id discountCodeId;
    global String discountCodeName;
    global Boolean discountCodeNameExists;
    global String discountCodeResult;
    global Date dueDate;
    global Id eventId;
    global Id id;
    global Boolean isDiscountCodeValid;
    global List<bt_stripe.Billing_API.LI> lineItemList;
    global Decimal netAmount;
    global Set<Id> relatedObjectIdsForDiscountCode;
    global String salesDocumentType;
    global Id shipToAccountId;
    global String shipToCity;
    global Id shipToContactId;
    global String shipToCountry;
    global String shipToPostalCode;
    global String shipToState;
    global String shipToStreet;
    global Decimal subtotalAmount;
    global Decimal totalAmount;
    global SD() {

    }
    global void calculate() {

    }
    global virtual void upsertRecord() {

    }
}
}
