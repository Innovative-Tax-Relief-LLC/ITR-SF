/**
 * @description A trigger handler framework.
 * Originally by Kevin O'Hara github.com/kevinohara80/sfdc-trigger-framework
 * Updated and adapted to add other functionalities, as turn off trigger from a custom metadata.
 */
public virtual with sharing class TriggerHandler {
    public TriggerHandler() {
        this.setTriggerContext(null, false);
    }
    
    private TriggerOperationType context;
    private Boolean isTriggerExecutingTest;
    private static Set<String> setOfHandlersToByPass;
    private static Map<String, Trigger_Configuration__mdt> triggerConfigMap;
    
    static {
        setOfHandlersToByPass = new Set<String>();
        triggerConfigMap = new Map<String, Trigger_Configuration__mdt>();
    }
    
    public static void byPass(String triggerHandlerName) {
        TriggerHandler.setOfHandlersToByPass.add(triggerHandlerName);
    }
    
    public static Boolean isByPassed(String triggerHandlerName) {
        return TriggerHandler.setOfHandlersToByPass.contains(triggerHandlerName);
    }
    
    public static void clearAllByPass() {
        TriggerHandler.setOfHandlersToByPass.clear();
    }
    
    public static void clearByPass(String triggerHandlerName) {
        TriggerHandler.setOfHandlersToByPass.remove(triggerHandlerName);
    }
    
    private String getHandlersName() {
        return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
    }
    
    @TestVisible
    private void setTriggerMetadataTest(
        String triggerHandlerName,
        Trigger_Configuration__mdt triggerConfigMtd
    ) {
        if (!TriggerHandler.triggerConfigMap.containsKey(triggerHandlerName)) {
            TriggerHandler.triggerConfigMap.put(triggerHandlerName, triggerConfigMtd);
        }
    }
    
    private Boolean canRun(String triggerHandlerName) {
        if (!Trigger.isExecuting && !this.isTriggerExecutingTest) {
            throw new TriggerHandlerException (
                'Error, Trigger Handler was called outside of trigger execution.'
            );
        }
        
        return !TriggerHandler.isByPassed(triggerHandlerName);
    }
    
    private Trigger_Configuration__mdt getTriggerConfigMtd(String triggerHandlerName) {
        System.debug('This is from getTriggerMtd' + triggerHandlerName);
        if (TriggerHandler.triggerConfigMap.containsKey(triggerHandlerName)) {
            return TriggerHandler.triggerConfigMap.get(triggerHandlerName);
        }
        Trigger_Configuration__mdt triggerConfig = [
            SELECT
            BEFORE_INSERT__c,
            BEFORE_UPDATE__c,
            BEFORE_DELETE__c,
            AFTER_INSERT__c,
            AFTER_UPDATE__c,
            AFTER_DELETE__c,
            AFTER_UNDELETE__c
            FROM Trigger_Configuration__mdt
            WHERE Trigger_Handler_API_Name__c = :triggerHandlerName
            LIMIT 1
        ];
        
        System.debug('This is the trigger config record' + triggerConfig);
        
        if (triggerConfig != null) {
            TriggerHandler.triggerConfigMap.put(triggerHandlerName, triggerConfig);
        } else {
            throw new TriggerHandlerException (
                'No trigger configuration record found for: ' + triggerHandlerName
            );
        }
        return triggerConfig;
    }
    
    @TestVisible
    private void setTriggerContext(TriggerOperationType testContext, Boolean isTest) {
        this.isTriggerExecutingTest = isTest;
        
        if (!Trigger.isExecuting && !this.isTriggerExecutingTest) {
            return;
        }
        
        if (
            (Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
            testContext == TriggerOperationType.BEFORE_INSERT
        ) {
            this.context = TriggerOperationType.BEFORE_INSERT;
        } else if (
            (Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
            testContext == TriggerOperationType.BEFORE_UPDATE
        ) {
            this.context = TriggerOperationType.BEFORE_UPDATE;
        } else if (
            (Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
            testContext == TriggerOperationType.BEFORE_DELETE
        ) {
            this.context = TriggerOperationType.BEFORE_DELETE;
        } else if (
            (Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
            testContext == TriggerOperationType.AFTER_INSERT
        ) {
            this.context = TriggerOperationType.AFTER_INSERT;
        } else if (
            (Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
            testContext == TriggerOperationType.AFTER_UPDATE
        ) {
            this.context = TriggerOperationType.AFTER_UPDATE;
        } else if (
            (Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
            testContext == TriggerOperationType.AFTER_DELETE
        ) {
            this.context = TriggerOperationType.AFTER_DELETE;
        } else if (
            (Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
            testContext == TriggerOperationType.AFTER_UNDELETE
        ) {
            this.context = TriggerOperationType.AFTER_UNDELETE;
        }
    }
    
    public void run() {
        String handlerName = getHandlersName();
        Trigger_Configuration__mdt triggerConfigMtd = getTriggerConfigMtd(handlerName);
        
        if (!canRun(handlerName)) {
            return;
        }
        
        if (this.context == TriggerOperationType.BEFORE_INSERT && triggerConfigMtd.BEFORE_INSERT__c) {
            this.beforeInsert();
        } else if (
            this.context == TriggerOperationType.BEFORE_UPDATE && triggerConfigMtd.BEFORE_UPDATE__c
        ) {
            this.beforeUpdate();
        } else if (
            this.context == TriggerOperationType.BEFORE_DELETE && triggerConfigMtd.BEFORE_DELETE__c
        ) {
            this.beforeDelete();
        } else if (
            this.context == TriggerOperationType.AFTER_INSERT && triggerConfigMtd.AFTER_INSERT__c
        ) {
            this.afterInsert();
        } else if (
            this.context == TriggerOperationType.AFTER_UPDATE && triggerConfigMtd.AFTER_UPDATE__c
        ) {
            this.afterUpdate();
        } else if (
            this.context == TriggerOperationType.AFTER_DELETE && triggerConfigMtd.AFTER_DELETE__c
        ) {
            this.afterDelete();
        } else if (
            this.context == TriggerOperationType.AFTER_UNDELETE && triggerConfigMtd.AFTER_UNDELETE__c
        ) {
            this.afterUndelete();
        }
    }
    
    @TestVisible
    protected virtual void beforeInsert() {
    }
    @TestVisible
    protected virtual void beforeUpdate() {
    }
    @TestVisible
    protected virtual void beforeDelete() {
    }
    @TestVisible
    protected virtual void afterInsert() {
    }
    @TestVisible
    protected virtual void afterUpdate() {
    }
    @TestVisible
    protected virtual void afterDelete() {
    }
    @TestVisible
    protected virtual void afterUndelete() {
    }
    
    public class TriggerHandlerException extends Exception {
        
    }
}