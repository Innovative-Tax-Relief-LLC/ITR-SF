trigger TransactionTrigger on bt_stripe__Transaction__c (after update, after insert) {
	new TransactionTriggerHandler().run();
}