public class AccountTriggerHandler {
     
    public static void handleFieldChangesPersonAccount(Map<Id, Account> oldMap, Map<Id, Account> newMap, Boolean isInsert, Boolean isUpdate) {
        List<Account> personAccountData = new List<Account>();

        // Lista de campos a serem verificados
        Set<String> monitoredFields = new Set<String>{
            'Salutation', 'FirstName', 'LastName', 'PersonEmail', 'PersonMobilePhone', 'Returning_Client__pc', 'PersonBirthdate', 
            'Marital_Status__pc', 'Has_a_Spouse__pc', 'Spouse_First_Name__pc', 'Spouse_Last_Name__pc', 'Spouse_Date_of_Birth__pc',
            'Spouse_Email__pc', 'Spouse_Mobile__pc', 'Name', 'PersonLeadSource', 'Total_Tax_Debt__pc'
        };

        for (Account acc : newMap.values()) {            
            Boolean hasChanges = false;
            
            // Verifica se é Conta Pessoal
            if(acc.IsPersonAccount) {
                if (isInsert) {
                    // Verifica se algum campo monitorado tem valor preenchido na inserção
                    for (String field : monitoredFields) {
                        if (acc.get(field) != null) {
                            hasChanges = true;
                            break;
                        }
                    }
                } else if (isUpdate) {
                    // Verifica se algum campo monitorado foi alterado na atualização
                    Account oldAcc = oldMap.get(acc.Id);
                    for (String field : monitoredFields) {
                        if (oldAcc.get(field) != acc.get(field)) {
                            hasChanges = true;
                            break;
                        }
                    }
                }

                if (hasChanges) {
                    personAccountData.add(acc);
                }
            }
        }
        
        if (!personAccountData.isEmpty()) {
            PersonAccountWebhookCallout.sendPersonAccountData(JSON.serialize(personAccountData));
        }
    }
}