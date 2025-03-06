/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Public_Checkout_Button_Controller {
    global Public_Checkout_Button_Controller() {

    }
    @RemoteAction
    global static bt_stripe.Public_Checkout_Button_Controller.CheckoutResult checkoutExistingBankAccount(List<String> params) {
        return null;
    }
    @RemoteAction
    global static bt_stripe.Public_Checkout_Button_Controller.CheckoutResult checkoutExistingCard(List<String> params) {
        return null;
    }
global class CheckoutResult {
    global String message;
    global Id reAttemptId;
    global Boolean success;
    global bt_stripe__Transaction__c tra;
    global CheckoutResult() {

    }
}
}
