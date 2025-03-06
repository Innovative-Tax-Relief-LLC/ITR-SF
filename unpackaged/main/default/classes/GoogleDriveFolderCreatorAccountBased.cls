public  class GoogleDriveFolderCreatorAccountBased implements Database.Batchable<SObject>{
  
   public static String secondTradeRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Second Trade').getRecordTypeId();
   public Database.QueryLocator start(Database.BatchableContext bc){
    
      return Database.getQueryLocator([SELECT Id, Name, SSN__pc, Google_Drive_Folder_ID__c, CreatedDate
      FROM Account 
      WHERE Google_Drive_Folder_ID__c = NULL
      AND Id IN (
          SELECT AccountId
          FROM Opportunity 
          WHERE RecordTypeId =:secondTradeRTId
      )]);
   }

   public void execute(Database.BatchableContext bc, List<Account> scope){
    System.debug('DEBUG :: Account List Size '+scope.size());
        String parentFolderId = Label.GoogleDriveParentFolderID;
        System.debug('DEBUG :: Drive Folder Name '+parentFolderId);
        System.enqueueJob(new GoogleDriveFolderCreatorQueueableBulk(scope, parentFolderId));
   }

   public void finish(Database.BatchableContext bc){
      //do nothing
   }

  
}