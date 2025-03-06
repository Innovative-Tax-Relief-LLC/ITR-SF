@isTest
private class TriggerHandler_Test {
    private static String triggerMethodFired;
    private static TriggerHandler_Test.TriggerHandlerExtension testHandler;

    static {
        testHandler = new TriggerHandler_Test.TriggerHandlerExtension();
    }

    private class TriggerHandlerExtension extends TriggerHandler {
        public override void beforeInsert() {
            TriggerHandler_Test.triggerMethodFired = 'BEFORE_INSERT';
        }

        public override void beforeUpdate() {
            TriggerHandler_Test.triggerMethodFired = 'BEFORE_UPDATE';
        }

        public override void beforeDelete() {
            TriggerHandler_Test.triggerMethodFired = 'BEFORE_DELETE';
        }

        public override void afterInsert() {
            TriggerHandler_Test.triggerMethodFired = 'AFTER_INSERT';
        }

        public override void afterUpdate() {
            TriggerHandler_Test.triggerMethodFired = 'AFTER_UPDATE';
        }

        public override void afterDelete() {
            TriggerHandler_Test.triggerMethodFired = 'AFTER_DELETE';
        }

        public override void afterUndelete() {
            TriggerHandler_Test.triggerMethodFired = 'AFTER_UNDELETE';
        }
    }

    @isTest
    static void testVirtualBeforeInsert_givenValidConfigAndContext_expectProperTriggerEventToBeFired() {

        testHandler.setTriggerContext(TriggerOperationType.BEFORE_INSERT, true);

        Trigger_Configuration__mdt triggerConfigMtd = new Trigger_Configuration__mdt();
        triggerConfigMtd.Trigger_Handler_API_Name__c = 'TriggerHandlerExtension';
        triggerConfigMtd.BEFORE_INSERT__c = true;

        testHandler.setTriggerMetadataTest('TriggerHandlerExtension', triggerConfigMtd);
        testHandler.run();

        Assert.areEqual('BEFORE_INSERT', triggerMethodFired, 'Events do not match.');
    }

    @isTest
    static void testVirtualBeforeUpdate_givenValidConfigAndContext_expectProperTriggerEventToBeFired() {
        testHandler.setTriggerContext(TriggerOperationType.BEFORE_UPDATE, true);

        Trigger_Configuration__mdt triggerConfigMtd = new Trigger_Configuration__mdt();
        triggerConfigMtd.Trigger_Handler_API_Name__c = 'TriggerHandlerExtension';
        triggerConfigMtd.BEFORE_UPDATE__c = true;

        testHandler.setTriggerMetadataTest('TriggerHandlerExtension', triggerConfigMtd);
        testHandler.run();

        Assert.areEqual('BEFORE_UPDATE', triggerMethodFired, 'Events do not match.');
    }

    @isTest
    static void testVirtualBeforeDelete_givenValidConfigAndContext_expectProperTriggerEventToBeFired() {
        testHandler.setTriggerContext(TriggerOperationType.BEFORE_DELETE, true);

        Trigger_Configuration__mdt triggerConfigMtd = new Trigger_Configuration__mdt();
        triggerConfigMtd.Trigger_Handler_API_Name__c = 'TriggerHandlerExtension';
        triggerConfigMtd.BEFORE_DELETE__c = true;

        testHandler.setTriggerMetadataTest('TriggerHandlerExtension', triggerConfigMtd);
        testHandler.run();

        Assert.areEqual('BEFORE_DELETE', triggerMethodFired, 'Events do not match.');
    }

    @isTest
    static void testVirtualAfterInsert_givenValidConfigAndContext_expectProperTriggerEventToBeFired() {
        testHandler.setTriggerContext(TriggerOperationType.AFTER_INSERT, true);

        Trigger_Configuration__mdt triggerConfigMtd = new Trigger_Configuration__mdt();
        triggerConfigMtd.Trigger_Handler_API_Name__c = 'TriggerHandlerExtension';
        triggerConfigMtd.AFTER_INSERT__c = true;

        testHandler.setTriggerMetadataTest('TriggerHandlerExtension', triggerConfigMtd);
        testHandler.run();

        Assert.areEqual('AFTER_INSERT', triggerMethodFired, 'Events do not match.');
    }

    @isTest
    static void testVirtualAfterUpdate_givenValidConfigAndContext_expectProperTriggerEventToBeFired() {
        testHandler.setTriggerContext(TriggerOperationType.AFTER_UPDATE, true);

        Trigger_Configuration__mdt triggerConfigMtd = new Trigger_Configuration__mdt();
        triggerConfigMtd.Trigger_Handler_API_Name__c = 'TriggerHandlerExtension';
        triggerConfigMtd.AFTER_UPDATE__c = true;

        testHandler.setTriggerMetadataTest('TriggerHandlerExtension', triggerConfigMtd);
        testHandler.run();

        Assert.areEqual('AFTER_UPDATE', triggerMethodFired, 'Events do not match.');
    }

    @isTest
    static void testVirtualAfterDelete_givenValidConfigAndContext_expectProperTriggerEventToBeFired() {
        testHandler.setTriggerContext(TriggerOperationType.AFTER_DELETE, true);

        Trigger_Configuration__mdt triggerConfigMtd = new Trigger_Configuration__mdt();
        triggerConfigMtd.Trigger_Handler_API_Name__c = 'TriggerHandlerExtension';
        triggerConfigMtd.AFTER_DELETE__c = true;

        testHandler.setTriggerMetadataTest('TriggerHandlerExtension', triggerConfigMtd);
        testHandler.run();

        Assert.areEqual('AFTER_DELETE', triggerMethodFired, 'Events do not match.');
    }

    @isTest
    static void testVirtualAfterUndelete_givenValidConfigAndContext_expectProperTriggerEventToBeFired() {
        testHandler.setTriggerContext(TriggerOperationType.AFTER_UNDELETE, true);

        Trigger_Configuration__mdt triggerConfigMtd = new Trigger_Configuration__mdt();
        triggerConfigMtd.Trigger_Handler_API_Name__c = 'TriggerHandlerExtension';
        triggerConfigMtd.AFTER_UNDELETE__c = true;

        testHandler.setTriggerMetadataTest('TriggerHandlerExtension', triggerConfigMtd);
        testHandler.run();

        Assert.areEqual('AFTER_UNDELETE', triggerMethodFired, 'Events do not match.');
    }

    @isTest
    static void testVirtualCanRun_givenScenarioOfNoTestExecution_expectExceptionToBeThrown() {
        String errorMsg;
        try {
            testHandler.setTriggerContext(TriggerOperationType.BEFORE_UPDATE, false);

            Trigger_Configuration__mdt triggerConfigMtd = new Trigger_Configuration__mdt();
            triggerConfigMtd.Trigger_Handler_API_Name__c = 'TriggerHandlerExtension';
            triggerConfigMtd.BEFORE_UPDATE__c = true;

            testHandler.setTriggerMetadataTest('TriggerHandlerExtension', triggerConfigMtd);
            testHandler.run();
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }

        Assert.areEqual(errorMsg, 'Error, Trigger Handler was called outside of trigger execution.', 'No exceptions have occured.');
    }

    @isTest
    static void testVirtualByPass_givenClassNameToByPass_expectNoEventsToBeRan() {
        TriggerHandlerExtension.byPass('TriggerHandlerExtension');

        testHandler.setTriggerContext(TriggerOperationType.BEFORE_UPDATE, true);

        Trigger_Configuration__mdt triggerConfigMtd = new Trigger_Configuration__mdt();
        triggerConfigMtd.Trigger_Handler_API_Name__c = 'TriggerHandlerExtension';
        triggerConfigMtd.BEFORE_UPDATE__c = true;

        testHandler.setTriggerMetadataTest('TriggerHandlerExtension', triggerConfigMtd);
        testHandler.run();

        TriggerHandlerExtension.clearByPass('TriggerHandlerExtension');
        TriggerHandlerExtension.clearAllByPass();

        Assert.areEqual(null, triggerMethodFired, 'No events should have run.');
    }

    @isTest
    static void testVirtualMethods_givenCorrectlyInstantiatedParentClass_expectMethodsToBeCalled() {
        TriggerHandler testTriggerHandler = new Triggerhandler();
        testTriggerHandler.beforeInsert();
        testTriggerHandler.beforeUpdate();
        testTriggerHandler.beforeDelete();
        testTriggerHandler.afterInsert();
        testTriggerHandler.afterUpdate();
        testTriggerHandler.afterDelete();
        testTriggerHandler.afterUndelete();
    }
}