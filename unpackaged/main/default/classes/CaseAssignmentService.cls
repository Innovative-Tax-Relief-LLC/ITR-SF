public class CaseAssignmentService {
    
    private static final String OWNER_TYPE_CASE_OWNER = 'Case Owner';
    private static final String OWNER_TYPE_TAX_PRO = 'Tax Pro';
    private static final String STAGE_PREFIX = 'Stage ';
    
    public static void assignOwnersBeforeInsert(List<Case> cases) {
        if (cases == null || cases.isEmpty()) {
            return;
        }
        
        Set<Id> opportunityIds = new Set<Id>();
        for (Case c : cases) {
            if (c.Opportunity__c != null) {
                opportunityIds.add(c.Opportunity__c);
            }
        }
        
        if (opportunityIds.isEmpty()) {
            System.debug('CaseAssignmentService: No Cases with Opportunity');
            return;
        }
        
        Map<Id, List<OpportunityLineItem>> oppToProducts = getOpportunityProducts(opportunityIds);
        
        if (oppToProducts.isEmpty()) {
            System.debug('CaseAssignmentService: No Products found');
            return;
        }
        
        List<Case_User_Pool__c> allPools = getUserPools();
        
        if (allPools.isEmpty()) {
            System.debug('CaseAssignmentService: No active User Pools');
            return;
        }
        
        CaseCounterService.validateAndSyncCounters(allPools);
        
        Map<String, List<Case_User_Pool__c>> poolsByType = organizePools(allPools);
        
        Integer assignedOwners = 0;
        Integer assignedTaxPros = 0;
        
        for (Case c : cases) {
            if (c.Opportunity__c == null || !oppToProducts.containsKey(c.Opportunity__c)) {
                continue;
            }
            
            List<OpportunityLineItem> products = oppToProducts.get(c.Opportunity__c);
            if (products.isEmpty()) {
                continue;
            }
            
            Integer highestCMStage = getHighestStage(products, 'Case_Owner');
            Integer highestTPStage = getHighestStage(products, 'Tax_Pro');
            
            if (highestCMStage == null && highestTPStage == null) {
                continue;
            }
            
            if (highestCMStage != null) {
                List<Case_User_Pool__c> eligibleCMPools = getEligiblePools(
                    poolsByType.get(OWNER_TYPE_CASE_OWNER), 
                    highestCMStage
                );
                
                if (!eligibleCMPools.isEmpty()) {
                    Case_User_Pool__c selectedOwner = selectCaseOwnerNoSync(eligibleCMPools);
                    c.OwnerId = selectedOwner.User__c;
                    assignedOwners++;
                }
            }
            
            if (highestTPStage != null) {
                List<Case_User_Pool__c> eligibleTPPools = getEligiblePools(
                    poolsByType.get(OWNER_TYPE_TAX_PRO), 
                    highestTPStage
                );
                
                if (!eligibleTPPools.isEmpty()) {
                    Case_User_Pool__c selectedTaxPro = selectTaxProNoSync(eligibleTPPools);
                    c.Enrolled_Agent__c = selectedTaxPro.User__c;
                    assignedTaxPros++;
                }
            }
        }
        
        System.debug('CaseAssignmentService: Owners=' + assignedOwners + ', TaxPros=' + assignedTaxPros);
    }
    
    private static Map<Id, List<OpportunityLineItem>> getOpportunityProducts(Set<Id> opportunityIds) {
        List<OpportunityLineItem> products = [
            SELECT Id, OpportunityId, Product2Id, 
                   Product2.Stage_Tax_Pro__c, 
                   Product2.Stage_Case_Owner__c
            FROM OpportunityLineItem 
            WHERE OpportunityId IN :opportunityIds
        ];
        
        Map<Id, List<OpportunityLineItem>> oppToProducts = new Map<Id, List<OpportunityLineItem>>();
        
        for (OpportunityLineItem oli : products) {
            if (!oppToProducts.containsKey(oli.OpportunityId)) {
                oppToProducts.put(oli.OpportunityId, new List<OpportunityLineItem>());
            }
            oppToProducts.get(oli.OpportunityId).add(oli);
        }
        
        return oppToProducts;
    }
    
    private static List<Case_User_Pool__c> getUserPools() {
        return [
            SELECT Id, User__c, User__r.IsActive, Owner_Type__c, 
                   Stage__c, Number_Cases_Open__c
            FROM Case_User_Pool__c
            WHERE Automate__c = true
            AND User__r.IsActive = true
        ];
    }
    
    private static Map<String, List<Case_User_Pool__c>> organizePools(List<Case_User_Pool__c> allPools) {
        Map<String, List<Case_User_Pool__c>> poolsByType = new Map<String, List<Case_User_Pool__c>>{
            OWNER_TYPE_CASE_OWNER => new List<Case_User_Pool__c>(),
            OWNER_TYPE_TAX_PRO => new List<Case_User_Pool__c>()
        };
        
        for (Case_User_Pool__c pool : allPools) {
            if (pool.Owner_Type__c == OWNER_TYPE_CASE_OWNER) {
                poolsByType.get(OWNER_TYPE_CASE_OWNER).add(pool);
            } else if (pool.Owner_Type__c == OWNER_TYPE_TAX_PRO) {
                poolsByType.get(OWNER_TYPE_TAX_PRO).add(pool);
            }
        }
        
        return poolsByType;
    }
    
    private static Integer getHighestStage(List<OpportunityLineItem> products, String stageType) {
        Integer highestStageNum = null;
        
        for (OpportunityLineItem oli : products) {
            String stageValue = null;
            
            if (stageType == 'Case_Owner') {
                stageValue = oli.Product2.Stage_Case_Owner__c;
            } else if (stageType == 'Tax_Pro') {
                stageValue = oli.Product2.Stage_Tax_Pro__c;
            }
            
            if (String.isNotBlank(stageValue)) {
                try {
                    Integer stageNumber = Integer.valueOf(stageValue.replace(STAGE_PREFIX, ''));
                    if (highestStageNum == null || stageNumber > highestStageNum) {
                        highestStageNum = stageNumber;
                    }
                } catch (Exception e) {
                    System.debug('Error parsing stage: ' + stageValue);
                }
            }
        }
        
        return highestStageNum;
    }
    
    private static List<Case_User_Pool__c> getEligiblePools(
        List<Case_User_Pool__c> pools, 
        Integer requiredStage
    ) {
        List<Case_User_Pool__c> eligible = new List<Case_User_Pool__c>();
        
        if (pools == null || pools.isEmpty()) {
            return eligible;
        }
        
        for (Case_User_Pool__c pool : pools) {
            try {
                Integer poolStageNum = Integer.valueOf(pool.Stage__c.replace(STAGE_PREFIX, ''));
                if (poolStageNum <= requiredStage) {
                    eligible.add(pool);
                }
            } catch (Exception e) {
                System.debug('Error parsing pool stage: ' + pool.Stage__c);
            }
        }
        
        return eligible;
    }
    
    private static Case_User_Pool__c selectCaseOwnerNoSync(List<Case_User_Pool__c> pools) {
        pools.sort(new CaseOwnerComparator());
        return pools[0];
    }
    
    private static Case_User_Pool__c selectTaxProNoSync(List<Case_User_Pool__c> pools) {
        Case_User_Pool__c selectedUser = pools[0];
        Decimal minCases = selectedUser.Number_Cases_Open__c != null ? 
                           selectedUser.Number_Cases_Open__c : 0;
        
        for (Case_User_Pool__c pool : pools) {
            Decimal currentCases = pool.Number_Cases_Open__c != null ? 
                                   pool.Number_Cases_Open__c : 0;
            if (currentCases < minCases) {
                minCases = currentCases;
                selectedUser = pool;
            }
        }
        
        return selectedUser;
    }
    
    public class CaseOwnerComparator implements Comparator<Case_User_Pool__c> {
        public Integer compare(Case_User_Pool__c a, Case_User_Pool__c b) {
            Integer stageA = Integer.valueOf(a.Stage__c.replace(STAGE_PREFIX, ''));
            Integer stageB = Integer.valueOf(b.Stage__c.replace(STAGE_PREFIX, ''));
            
            if (stageA != stageB) {
                return stageB - stageA;
            }
            
            Decimal casesA = a.Number_Cases_Open__c != null ? a.Number_Cases_Open__c : 0;
            Decimal casesB = b.Number_Cases_Open__c != null ? b.Number_Cases_Open__c : 0;
            
            if (casesA < casesB) return -1;
            if (casesA > casesB) return 1;
            return 0;
        }
    }
}