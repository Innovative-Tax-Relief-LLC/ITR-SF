public class CaseCounterService {
    
    public static Map<String, Case_User_Pool__c> getCurrentUserPools() {
        Map<String, Case_User_Pool__c> userPoolMap = new Map<String, Case_User_Pool__c>();
        
        for (Case_User_Pool__c pool : [
            SELECT Id, User__c, Owner_Type__c, Stage__c, Number_Cases_Open__c
            FROM Case_User_Pool__c
            WHERE Automate__c = true
        ]) {
            String key = pool.Owner_Type__c + '_' + pool.Stage__c + '_' + pool.User__c;
            userPoolMap.put(key, pool);
        }
        
        return userPoolMap;
    }
    
    public static void validateAndSyncCounters(List<Case_User_Pool__c> pools) {
        if (pools == null || pools.isEmpty()) return;
        
        Set<Id> userIds = new Set<Id>();
        for (Case_User_Pool__c pool : pools) {
            userIds.add(pool.User__c);
        }
        
        Map<Id, Integer> ownerCaseCounts = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT OwnerId, COUNT(Id) totalCases
            FROM Case 
            WHERE IsClosed = false 
            AND OwnerId IN :userIds
            GROUP BY OwnerId
        ]) {
            ownerCaseCounts.put((Id)ar.get('OwnerId'), (Integer)ar.get('totalCases'));
        }
        
        Map<Id, Integer> enrolledAgentCaseCounts = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT Enrolled_Agent__c, COUNT(Id) totalCases
            FROM Case 
            WHERE IsClosed = false 
            AND Enrolled_Agent__c IN :userIds
            GROUP BY Enrolled_Agent__c
        ]) {
            enrolledAgentCaseCounts.put((Id)ar.get('Enrolled_Agent__c'), (Integer)ar.get('totalCases'));
        }
        
        List<Case_User_Pool__c> poolsToSync = new List<Case_User_Pool__c>();
        
        for (Case_User_Pool__c pool : pools) {
            Integer actualCount = 0;
            
            if (pool.Owner_Type__c == 'Case Owner') {
                actualCount = ownerCaseCounts.get(pool.User__c) ?? 0;
            } else if (pool.Owner_Type__c == 'Tax Pro') {
                actualCount = enrolledAgentCaseCounts.get(pool.User__c) ?? 0;
            }
            
            if (pool.Number_Cases_Open__c != actualCount) {
                pool.Number_Cases_Open__c = actualCount;
                poolsToSync.add(pool);
            }
        }
        
        if (!poolsToSync.isEmpty()) {
            update poolsToSync;
        }
    }
    
    public static void updateCountersAfterAssignment(List<Case> assignedCases) {
        if (assignedCases == null || assignedCases.isEmpty()) return;
        
        Map<Id, Integer> ownerIncrements = new Map<Id, Integer>();
        Map<Id, Integer> enrolledAgentIncrements = new Map<Id, Integer>();
        
        for (Case c : assignedCases) {
            if (c.OwnerId != null) {
                ownerIncrements.put(c.OwnerId, (ownerIncrements.get(c.OwnerId) ?? 0) + 1);
            }
            if (c.Enrolled_Agent__c != null) {
                enrolledAgentIncrements.put(c.Enrolled_Agent__c, (enrolledAgentIncrements.get(c.Enrolled_Agent__c) ?? 0) + 1);
            }
        }
        
        List<Case_User_Pool__c> poolsToUpdate = new List<Case_User_Pool__c>();
        
        if (!ownerIncrements.isEmpty()) {
            for (Case_User_Pool__c pool : [
                SELECT Id, User__c, Number_Cases_Open__c, Stage__c
                FROM Case_User_Pool__c 
                WHERE Owner_Type__c = 'Case Owner' 
                AND User__c IN :ownerIncrements.keySet()
                AND Automate__c = true
            ]) {
                Integer increment = ownerIncrements.get(pool.User__c);
                pool.Number_Cases_Open__c = (pool.Number_Cases_Open__c ?? 0) + increment;
                poolsToUpdate.add(pool);
            }
        }
        
        if (!enrolledAgentIncrements.isEmpty()) {
            for (Case_User_Pool__c pool : [
                SELECT Id, User__c, Number_Cases_Open__c, Stage__c
                FROM Case_User_Pool__c 
                WHERE Owner_Type__c = 'Tax Pro' 
                AND User__c IN :enrolledAgentIncrements.keySet()
                AND Automate__c = true
            ]) {
                Integer increment = enrolledAgentIncrements.get(pool.User__c);
                pool.Number_Cases_Open__c = (pool.Number_Cases_Open__c ?? 0) + increment;
                poolsToUpdate.add(pool);
            }
        }
        
        if (!poolsToUpdate.isEmpty()) {
            update poolsToUpdate;
        }
    }
    
    public static void recalculateAllCounters() {
        List<Case_User_Pool__c> allUserPools = [
            SELECT Id, User__c, Owner_Type__c, Number_Cases_Open__c
            FROM Case_User_Pool__c
            WHERE Automate__c = true
        ];
        
        if (allUserPools.isEmpty()) return;
        
        Set<Id> allUserIds = new Set<Id>();
        for (Case_User_Pool__c pool : allUserPools) {
            allUserIds.add(pool.User__c);
        }
        
        Map<Id, Integer> ownerCaseCounts = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT OwnerId, COUNT(Id) totalCases
            FROM Case 
            WHERE IsClosed = false 
            AND OwnerId IN :allUserIds
            GROUP BY OwnerId
        ]) {
            ownerCaseCounts.put((Id)ar.get('OwnerId'), (Integer)ar.get('totalCases'));
        }
        
        Map<Id, Integer> enrolledAgentCaseCounts = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT Enrolled_Agent__c, COUNT(Id) totalCases
            FROM Case 
            WHERE IsClosed = false 
            AND Enrolled_Agent__c IN :allUserIds
            GROUP BY Enrolled_Agent__c
        ]) {
            enrolledAgentCaseCounts.put((Id)ar.get('Enrolled_Agent__c'), (Integer)ar.get('totalCases'));
        }
        
        List<Case_User_Pool__c> poolsToUpdate = new List<Case_User_Pool__c>();
        
        for (Case_User_Pool__c pool : allUserPools) {
            Integer currentCount = 0;
            
            if (pool.Owner_Type__c == 'Case Owner') {
                currentCount = ownerCaseCounts.get(pool.User__c) ?? 0;
            } else if (pool.Owner_Type__c == 'Tax Pro') {
                currentCount = enrolledAgentCaseCounts.get(pool.User__c) ?? 0;
            }
            
            if (pool.Number_Cases_Open__c != currentCount) {
                pool.Number_Cases_Open__c = currentCount;
                poolsToUpdate.add(pool);
            }
        }
        
        if (!poolsToUpdate.isEmpty()) {
            update poolsToUpdate;
        }
    }
    
    public static void decrementCountersForClosedCases(List<Case> closedCases) {
        if (closedCases == null || closedCases.isEmpty()) return;
        
        Map<Id, Integer> ownerDecrements = new Map<Id, Integer>();
        Map<Id, Integer> enrolledAgentDecrements = new Map<Id, Integer>();
        
        for (Case c : closedCases) {
            if (c.OwnerId != null) {
                ownerDecrements.put(c.OwnerId, (ownerDecrements.get(c.OwnerId) ?? 0) + 1);
            }
            if (c.Enrolled_Agent__c != null) {
                enrolledAgentDecrements.put(c.Enrolled_Agent__c, (enrolledAgentDecrements.get(c.Enrolled_Agent__c) ?? 0) + 1);
            }
        }
        
        List<Case_User_Pool__c> poolsToUpdate = new List<Case_User_Pool__c>();
        
        if (!ownerDecrements.isEmpty()) {
            for (Case_User_Pool__c pool : [
                SELECT Id, User__c, Number_Cases_Open__c
                FROM Case_User_Pool__c 
                WHERE Owner_Type__c = 'Case Owner' 
                AND User__c IN :ownerDecrements.keySet()
                AND Automate__c = true
            ]) {
                Integer decrement = ownerDecrements.get(pool.User__c);
                pool.Number_Cases_Open__c = Math.max(0, (pool.Number_Cases_Open__c ?? 0) - decrement);
                poolsToUpdate.add(pool);
            }
        }
        
        if (!enrolledAgentDecrements.isEmpty()) {
            for (Case_User_Pool__c pool : [
                SELECT Id, User__c, Number_Cases_Open__c
                FROM Case_User_Pool__c 
                WHERE Owner_Type__c = 'Tax Pro' 
                AND User__c IN :enrolledAgentDecrements.keySet()
                AND Automate__c = true
            ]) {
                Integer decrement = enrolledAgentDecrements.get(pool.User__c);
                pool.Number_Cases_Open__c = Math.max(0, (pool.Number_Cases_Open__c ?? 0) - decrement);
                poolsToUpdate.add(pool);
            }
        }
        
        if (!poolsToUpdate.isEmpty()) {
            update poolsToUpdate;
        }
    }
    
    public static void updateCaseCounters() {
        recalculateAllCounters();
    }
    
    public static void incrementCaseCounters(List<Case> cases) {
        updateCountersAfterAssignment(cases);
    }
}