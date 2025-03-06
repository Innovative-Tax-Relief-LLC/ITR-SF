public class CreateACHPaymentMethod {
    @InvocableMethod(label='Create ACH Payment Method' description='Creates a Payment Method of type ACH')
    public static List<Id> createPaymentMethod(List<InputParameters> inputList) {
        List<Id> paymentMethodIds = new List<Id>();
        
        if (!inputList.isEmpty()) {
            InputParameters input = inputList[0];
            List<EncryptedFieldsResultForAC> encryptedFields = getEncryptedFields(input.opportunityId);

            bt_stripe__Payment_Method__c newPaymentMethod = new bt_stripe__Payment_Method__c();
            newPaymentMethod.RecordTypeId = input.paymentMethodRT;
            newPaymentMethod.bt_stripe__Card_Holder_Name__c = input.cardholderName;
            newPaymentMethod.bt_stripe__Currency_ISO__c  = input.currencyIso;
            newPaymentMethod.bt_stripe__Country_ISO__c  = input.countryIso;
            newPaymentMethod.bt_stripe__Account_Holder_Type__c  = input.accountHolderType;
            newPaymentMethod.bt_stripe__Account__c = input.accountOpp;
            newPaymentMethod.bt_stripe__Contact__c = input.contactOpp;
            newPaymentMethod.bt_stripe__Send_to_Gateway__c = false;
             
            if (!encryptedFields.isEmpty()) {
                EncryptedFieldsResultForAC encryptedData = encryptedFields[0];
                newPaymentMethod.bt_stripe__Account_Number__c  = encryptedData.accountNumber;
                newPaymentMethod.bt_stripe__Routing_Number__c  = encryptedData.routingNumber;
            }

            if (Schema.sObjectType.bt_stripe__Payment_Method__c.isCreateable()) {
                try {
                    insert newPaymentMethod;
                    paymentMethodIds.add(newPaymentMethod.Id);
                } catch (DmlException e) {
                    throw new FlowException('Error creating ACH Payment Method: ' + e.getMessage());
                }
            } else {
                throw new FlowException('You do not have the necessary permissions to create a ACH Payment Method.');
            }
        }
        return paymentMethodIds;
    }

    public class InputParameters {
        @InvocableVariable(label='Opportunity ID' description='ID of the related Opportunity' required=true)
        public Id opportunityId;

        @InvocableVariable(label='Holders Name' description='Holders Name' required=true)
        public String cardholderName;

        @InvocableVariable(label='Account Holder Type' description='The Type of Holder Account' required=true)
        public String accountHolderType;

        @InvocableVariable(label='Currency ISO' description='The ISO Currency' required=true)
        public String currencyIso;
        
        @InvocableVariable(label='Country ISO' description='The ISO Country' required=true)
        public String countryIso;
        
        @InvocableVariable(label='Payment Method Record Type' description='Type of Payment Method Record Type' required=true)
        public String paymentMethodRT;
        
        @InvocableVariable(label='Account Related Opportunity' description='The Account associated to the Opportunity' required=true)
        public Id accountOpp;
        
        @InvocableVariable(label='Contact Related Opportunity' description='The Contact associated to the Opportunity' required=true)
        public Id contactOpp;
    }
    
    public class EncryptedFieldsResultForAC {
        public String accountNumber;
        public String routingNumber;
    }
    
   	private static List<EncryptedFieldsResultForAC> getEncryptedFields(Id opportunityId) {
        List<EncryptedFieldsResultForAC> results = new List<EncryptedFieldsResultForAC>();
        
        if (opportunityId == null) {
            return results;
        }

        if (!Schema.sObjectType.Opportunity.isAccessible()) {
            return results;
        }
        
        Schema.DescribeFieldResult creditCardNumberField = Opportunity.Account_Number__c.getDescribe();
        Schema.DescribeFieldResult cvvField = Opportunity.Routing_Number__c.getDescribe();
        
        if (!creditCardNumberField.isAccessible() ||!cvvField.isAccessible()) {
            return results;
        }
        
        List<Opportunity> opportunities = [
            SELECT Id,
                   Account_Number__c, 
                   Routing_Number__c 
            FROM Opportunity 
            WHERE Id = :opportunityId
        ];
        
        if (!opportunities.isEmpty()) {
            Opportunity opp = opportunities[0];
            EncryptedFieldsResultForAC result = new EncryptedFieldsResultForAC();
            
            result.accountNumber = opp.Account_Number__c;
            result.routingNumber = opp.Routing_Number__c;
            
            results.add(result);
        }
        
        return results;
    }
}