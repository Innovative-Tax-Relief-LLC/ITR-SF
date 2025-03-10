/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global virtual class WebhookService implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful, System.Schedulable {
    global WebhookService() {

    }
    global void execute(System.SchedulableContext sc) {

    }
    global void execute(Database.BatchableContext bc, List<SObject> scope) {

    }
    global void finish(Database.BatchableContext bc) {

    }
    global void processEventStripeAsync(bt_stripe__Webhook_Event__c event) {

    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return null;
    }
global class WebhookServiceWithoutSharing extends bt_stripe.WebhookService {
    global WebhookServiceWithoutSharing() {

    }
    global void processEventStripeAsyncWithoutSharing(bt_stripe__Webhook_Event__c event) {

    }
}
}
