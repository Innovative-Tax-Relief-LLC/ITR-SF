public class CaseAssignmentService {
    
    public static void assignOwnersBeforeInsert(List<Case> cases) {
        if (cases == null || cases.isEmpty()) return;
        
        Set<Id> opportunityIds = new Set<Id>();
        for (Case c : cases) {
            if (c.Opportunity__c != null) {
                opportunityIds.add(c.Opportunity__c);
            }
        }
        
        if (opportunityIds.isEmpty()) return;
        
        List<OpportunityLineItem> opportunityProducts = [
            SELECT Id, OpportunityId, Product2Id, Product2.Stage_Tax_Pro__c, Product2.Stage_Case_Owner__c
            FROM OpportunityLineItem 
            WHERE OpportunityId IN :opportunityIds
        ];
        
        if (opportunityProducts.isEmpty()) return;
        
        Set<Id> productIds = new Set<Id>();
        Map<Id, List<OpportunityLineItem>> oppToProducts = new Map<Id, List<OpportunityLineItem>>();
        
        for (OpportunityLineItem oli : opportunityProducts) {
            productIds.add(oli.Product2Id);
            
            if (!oppToProducts.containsKey(oli.OpportunityId)) {
                oppToProducts.put(oli.OpportunityId, new List<OpportunityLineItem>());
            }
            oppToProducts.get(oli.OpportunityId).add(oli);
        }
        
        for (Case c : cases) {
            if (c.Opportunity__c == null || !oppToProducts.containsKey(c.Opportunity__c)) continue;
            
            List<OpportunityLineItem> products = oppToProducts.get(c.Opportunity__c);
            if (products.isEmpty()) continue;
            
            String highestCaseOwnerStage = getHighestStage(products, 'Case_Owner');
            String highestTaxProStage = getHighestStage(products, 'Tax_Pro');
            
            if (String.isBlank(highestCaseOwnerStage) && String.isBlank(highestTaxProStage)) continue;
            
            List<Case_User_Pool__c> allPools = [
                SELECT Id, User__c, Owner_Type__c, Stage__c, Number_Cases_Open__c
                FROM Case_User_Pool__c
                WHERE Automate__c = true
            ];
            
            if (allPools.isEmpty()) continue;
            
            if (String.isNotBlank(highestCaseOwnerStage)) {
                List<Case_User_Pool__c> caseOwnerPools = new List<Case_User_Pool__c>();
                Integer highestOwnerStageNum = Integer.valueOf(highestCaseOwnerStage.replace('Stage ', ''));
                
                for (Case_User_Pool__c pool : allPools) {
                    if (pool.Owner_Type__c == 'Case Owner') {
                        Integer poolStageNum = Integer.valueOf(pool.Stage__c.replace('Stage ', ''));
                        if (poolStageNum <= highestOwnerStageNum) {
                            caseOwnerPools.add(pool);
                        }
                    }
                }
                
                if (!caseOwnerPools.isEmpty()) {
                    Case_User_Pool__c selectedOwner = getUserWithHighestStageAndLowestCases(caseOwnerPools, 'Case_Owner');
                    c.OwnerId = selectedOwner.User__c;
                }
            }
            
            if (String.isNotBlank(highestTaxProStage)) {
                List<Case_User_Pool__c> taxProPools = new List<Case_User_Pool__c>();
                Integer highestTaxProStageNum = Integer.valueOf(highestTaxProStage.replace('Stage ', ''));
                
                for (Case_User_Pool__c pool : allPools) {
                    if (pool.Owner_Type__c == 'Tax Pro') {
                        Integer poolStageNum = Integer.valueOf(pool.Stage__c.replace('Stage ', ''));
                        if (poolStageNum <= highestTaxProStageNum) {
                            taxProPools.add(pool);
                        }
                    }
                }
                
                if (!taxProPools.isEmpty()) {
                    Case_User_Pool__c selectedTaxPro = getUserWithLowestCases(taxProPools);
                    c.Enrolled_Agent__c = selectedTaxPro.User__c;
                }
            }
        }
    }
    
    public static void assignOwners(List<Case> cases) {
        if (cases == null || cases.isEmpty()) return;
        
        Set<Id> opportunityIds = new Set<Id>();
        for (Case c : cases) {
            if (c.Opportunity__c != null) {
                opportunityIds.add(c.Opportunity__c);
            }
        }
        
        if (opportunityIds.isEmpty()) return;
        
        List<OpportunityLineItem> opportunityProducts = [
            SELECT Id, OpportunityId, Product2Id, Product2.Stage_Tax_Pro__c, Product2.Stage_Case_Owner__c
            FROM OpportunityLineItem 
            WHERE OpportunityId IN :opportunityIds
        ];
        
        if (opportunityProducts.isEmpty()) return;
        
        Set<Id> productIds = new Set<Id>();
        Map<Id, List<OpportunityLineItem>> oppToProducts = new Map<Id, List<OpportunityLineItem>>();
        
        for (OpportunityLineItem oli : opportunityProducts) {
            productIds.add(oli.Product2Id);
            
            if (!oppToProducts.containsKey(oli.OpportunityId)) {
                oppToProducts.put(oli.OpportunityId, new List<OpportunityLineItem>());
            }
            oppToProducts.get(oli.OpportunityId).add(oli);
        }
        
        List<Case> casesToUpdate = new List<Case>();
        
        for (Case c : cases) {
            if (c.Opportunity__c == null || !oppToProducts.containsKey(c.Opportunity__c)) continue;
            
            List<OpportunityLineItem> products = oppToProducts.get(c.Opportunity__c);
            if (products.isEmpty()) continue;
            
            String highestCaseOwnerStage = getHighestStage(products, 'Case_Owner');
            String highestTaxProStage = getHighestStage(products, 'Tax_Pro');
            
            if (String.isBlank(highestCaseOwnerStage) && String.isBlank(highestTaxProStage)) continue;
            
            List<Case_User_Pool__c> allPools = [
                SELECT Id, User__c, Owner_Type__c, Stage__c, Number_Cases_Open__c
                FROM Case_User_Pool__c
                WHERE Automate__c = true
            ];
            
            if (allPools.isEmpty()) continue;
            
            if (String.isNotBlank(highestCaseOwnerStage)) {
                List<Case_User_Pool__c> caseOwnerPools = new List<Case_User_Pool__c>();
                Integer highestOwnerStageNum = Integer.valueOf(highestCaseOwnerStage.replace('Stage ', ''));
                
                for (Case_User_Pool__c pool : allPools) {
                    if (pool.Owner_Type__c == 'Case Owner') {
                        Integer poolStageNum = Integer.valueOf(pool.Stage__c.replace('Stage ', ''));
                        if (poolStageNum <= highestOwnerStageNum) {
                            caseOwnerPools.add(pool);
                        }
                    }
                }
                
                if (!caseOwnerPools.isEmpty()) {
                    Case_User_Pool__c selectedOwner = getUserWithHighestStageAndLowestCases(caseOwnerPools, 'Case_Owner');
                    c.OwnerId = selectedOwner.User__c;
                }
            }
            
            if (String.isNotBlank(highestTaxProStage)) {
                List<Case_User_Pool__c> taxProPools = new List<Case_User_Pool__c>();
                Integer highestTaxProStageNum = Integer.valueOf(highestTaxProStage.replace('Stage ', ''));
                
                for (Case_User_Pool__c pool : allPools) {
                    if (pool.Owner_Type__c == 'Tax Pro') {
                        Integer poolStageNum = Integer.valueOf(pool.Stage__c.replace('Stage ', ''));
                        if (poolStageNum <= highestTaxProStageNum) {
                            taxProPools.add(pool);
                        }
                    }
                }
                
                if (!taxProPools.isEmpty()) {
                    Case_User_Pool__c selectedTaxPro = getUserWithLowestCases(taxProPools);
                    c.Enrolled_Agent__c = selectedTaxPro.User__c;
                }
            }
            
            casesToUpdate.add(c);
        }
        
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
            CaseCounterService.updateCountersAfterAssignment(casesToUpdate);
        }
    }
    
    private static String getHighestStage(List<OpportunityLineItem> products, String stageType) {
        Integer highestStageNum = null;
        
        for (OpportunityLineItem oli : products) {
            String stageValue = null;
            
            if (stageType == 'Case_Owner') {
                stageValue = oli.Product2.Stage_Case_Owner__c;
            } else if (stageType == 'Tax_Pro') {
                stageValue = oli.Product2.Stage_Tax_Pro__c;
            }
            
            if (String.isNotBlank(stageValue)) {
                Integer stageNumber = Integer.valueOf(stageValue.replace('Stage ', ''));
                if (highestStageNum == null || stageNumber > highestStageNum) {
                    highestStageNum = stageNumber;
                }
            }
        }
        
        return highestStageNum != null ? 'Stage ' + highestStageNum : null;
    }
    
    // Nuevo método para Case Owners - prioriza stage más alto, luego menos casos
    private static Case_User_Pool__c getUserWithHighestStageAndLowestCases(List<Case_User_Pool__c> userPools, String ownerType) {
        CaseCounterService.validateAndSyncCounters(userPools);
        
        if (ownerType == 'Case_Owner') {
            // Ordenar por stage descendente, luego por casos ascendente
            userPools.sort(new CaseOwnerComparator());
            return userPools[0];
        } else {
            // Para otros tipos, usar lógica original
            return getUserWithLowestCases(userPools);
        }
    }
    
    // Método original para Tax Pros
    private static Case_User_Pool__c getUserWithLowestCases(List<Case_User_Pool__c> userPools) {
        CaseCounterService.validateAndSyncCounters(userPools);
        
        Case_User_Pool__c selectedUser = userPools[0];
        Decimal minCases = selectedUser.Number_Cases_Open__c ?? 0;
        
        for (Case_User_Pool__c pool : userPools) {
            Decimal currentCases = pool.Number_Cases_Open__c ?? 0;
            if (currentCases < minCases) {
                minCases = currentCases;
                selectedUser = pool;
            }
        }
        
        return selectedUser;
    }
    
    // Clase interna para comparar Case Owners
    public class CaseOwnerComparator implements Comparator<Case_User_Pool__c> {
        public Integer compare(Case_User_Pool__c a, Case_User_Pool__c b) {
            Integer stageA = Integer.valueOf(a.Stage__c.replace('Stage ', ''));
            Integer stageB = Integer.valueOf(b.Stage__c.replace('Stage ', ''));
            
            // Primero ordenar por stage (descendente - stage más alto primero)
            if (stageA != stageB) {
                return stageB - stageA;
            }
            
            // Si tienen el mismo stage, ordenar por número de casos (ascendente - menos casos primero)
            Decimal casesA = a.Number_Cases_Open__c ?? 0;
            Decimal casesB = b.Number_Cases_Open__c ?? 0;
            
            if (casesA < casesB) return -1;
            if (casesA > casesB) return 1;
            return 0;
        }
    }
    
    public static void assignCaseOwnersAndTaxPros(List<Case> cases) {
        assignOwners(cases);
    }
}