trigger AccountTriggerDNC on Account (after update) {
    for (Account account : Trigger.new) {
        Account oldAccount = Trigger.oldMap.get(account.Id);

        if (account.PersonDoNotCall != oldAccount.PersonDoNotCall) {
            System.debug('AccountTriggerDNC: Change detected for Account ID: ' + account.Id);
            // Call the future method for asynchronous execution
            StatusChangeHandler.sendDoNotCallChangeAsync(
                account.Id, 
               // account.Velocify_Id__pc,
                account.PersonDoNotCall,
                account.Phone,
                account.PersonMobilePhone
            );

        }
    }
}