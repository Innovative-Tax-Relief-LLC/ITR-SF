public with sharing class LeadDistributionController {
    
    @AuraEnabled
    public static sObject fetchRecordForDistribution(){
        return LeadDistributionService.fetchRecordForDistribution(UserInfo.getUserId());
    }
        
}