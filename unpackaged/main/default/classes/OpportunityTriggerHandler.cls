/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* OpportunityTriggerHandler
*
* Purpose: Trigger Handler for OpportunityTrigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Cloudforia
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        2024-10-01
* @modified       
* @systemLayer    Service
* @see            
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.x        <user>
* <Date>      Explanation of the change
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class OpportunityTriggerHandler {
    public static String firstTradeRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('First Trade').getRecordTypeId();
    
    public static void handleAfterUpdate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        List<Opportunity> oppsToProcess = new List<Opportunity>();
        
        for (Opportunity newOpp : newMap.values()) {
            Opportunity oldOpp = oldMap.get(newOpp.Id);
            
            if (newOpp.RecordTypeId == firstTradeRTId && oldOpp.StageName != 'Investigation' && newOpp.StageName == 'Investigation') {
                oppsToProcess.add(newOpp);
            }
        }
        
        if (!oppsToProcess.isEmpty()) {
            processOpportunities(oppsToProcess);
        }
    }

    private static void processOpportunities(List<Opportunity> oppsToProcess) {
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Opportunity opp : oppsToProcess) {
            Account acc = [SELECT Id, Name, SSN__pc, Google_Drive_Folder_ID__c FROM Account WHERE Id = :opp.AccountId LIMIT 1];
            
            if (String.isBlank(acc.Google_Drive_Folder_ID__c)) {
                String parentFolderId = Label.GoogleDriveParentFolderID;
                
                String ssnLastFour = acc.SSN__pc != null && acc.SSN__pc.length() >= 4 ? acc.SSN__pc.substring(acc.SSN__pc.length() - 4) : 'XXXX';
                String newFolderName = acc.Name + ' - ' + ssnLastFour + ' - Tax Investigation';
                System.debug('DEBUG :: Drive Folder Name '+newFolderName);
                
                System.enqueueJob(new GoogleDriveFolderCreatorQueueable(parentFolderId, newFolderName,acc.Id));
            }
            else{
                System.debug('DEBUG :: Account already has a Google Drive Folder created');
            }
        }
    }
}