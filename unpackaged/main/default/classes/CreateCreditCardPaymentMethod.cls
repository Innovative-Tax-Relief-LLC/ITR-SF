public with sharing class CreateCreditCardPaymentMethod {
    @InvocableMethod(label='Create Credit Card Payment Method' description='Creates a Payment Method of type Credit Card')
    public static List<Id> createPaymentMethod(List<InputParameters> inputList) {
        List<Id> paymentMethodIds = new List<Id>();
        
        if (!inputList.isEmpty()) {
            InputParameters input = inputList[0];
            List<EncryptedFieldsResult> encryptedFields = getEncryptedFields(input.opportunityId);

            bt_stripe__Payment_Method__c newPaymentMethod = new bt_stripe__Payment_Method__c();
            newPaymentMethod.RecordTypeId = input.paymentMethodRT;
            newPaymentMethod.bt_stripe__Card_Holder_Name__c = input.cardholderName;
            newPaymentMethod.bt_stripe__Card_Expiration_Month__c = input.expiryMonth;
            newPaymentMethod.bt_stripe__Card_Expiration_Year__c = input.expiryYear;
            newPaymentMethod.bt_stripe__Billing_Postal_Code__c = input.postalCode;
            newPaymentMethod.bt_stripe__Account__c = input.accountOpp;
            newPaymentMethod.bt_stripe__Contact__c = input.contactOpp;
            if (test.isRunningTest()){
                newPaymentMethod.bt_stripe__Send_to_Gateway__c = false;
            } else {
                newPaymentMethod.bt_stripe__Send_to_Gateway__c = true;  
            }
            
            if (!encryptedFields.isEmpty()) {
                EncryptedFieldsResult encryptedData = encryptedFields[0];
                newPaymentMethod.bt_stripe__Card_Number__c = encryptedData.creditCardNumber;
                newPaymentMethod.bt_stripe__CVV__c = encryptedData.cvv;
            }

            if (Schema.sObjectType.bt_stripe__Payment_Method__c.isCreateable()) {
                try {
                    insert newPaymentMethod;
                    paymentMethodIds.add(newPaymentMethod.Id);
                } catch (DmlException e) {
                    throw new FlowException('Error creating Credit Card Payment Method: ' + e.getMessage());
                }
            } else {
                throw new FlowException('You do not have the necessary permissions to create a Credit Card Payment Method.');
            }
        }
        return paymentMethodIds;
    }

    public class InputParameters {
        @InvocableVariable(label='Opportunity ID' description='ID of the related Opportunity' required=true)
        public Id opportunityId;

        @InvocableVariable(label='Credit Card Type' description='Type of credit card' required=true)
        public String cardType;

        @InvocableVariable(label='Holders Name' description='Holders Name' required=true)
        public String cardholderName;

        @InvocableVariable(label='Expiration Month' description='Expiration month of the credit card' required=true)
        public String expiryMonth;

        @InvocableVariable(label='Expiration Year' description='Expiration year of the credit card' required=true)
        public String expiryYear;
        
        @InvocableVariable(label='Payment Method Record Type' description='Type of Payment Method Record Type' required=true)
        public String paymentMethodRT;
        
        @InvocableVariable(label='Postal Code' description='Billing postal code' required=true)
        public String postalCode;
        
        @InvocableVariable(label='Account Related Opportunity' description='The Account associated to the Opportunity' required=true)
        public Id accountOpp;
        
        @InvocableVariable(label='Contact Related Opportunity' description='The Contact associated to the Opportunity' required=true)
        public Id contactOpp;
    }
    
    public class EncryptedFieldsResult {
        public String creditCardNumber;
        public String cvv;
    }
    
   	private static List<EncryptedFieldsResult> getEncryptedFields(Id opportunityId) {
        List<EncryptedFieldsResult> results = new List<EncryptedFieldsResult>();
        
        if (opportunityId == null) {
            return results;
        }

        if (!Schema.sObjectType.Opportunity.isAccessible()) {
            return results;
        }
        
        Schema.DescribeFieldResult creditCardNumberField = Opportunity.Credit_Card_Number__c.getDescribe();
        Schema.DescribeFieldResult cvvField = Opportunity.CVV__c.getDescribe();
        
        if (!creditCardNumberField.isAccessible() ||!cvvField.isAccessible()) {
            return results;
        }
        
        List<Opportunity> opportunities = [
            SELECT Id, 
                   Credit_Card_Number__c, 
                   CVV__c
            FROM Opportunity 
            WHERE Id = :opportunityId
        ];
        
        if (!opportunities.isEmpty()) {
            Opportunity opp = opportunities[0];
            EncryptedFieldsResult result = new EncryptedFieldsResult();
            
            result.creditCardNumber = opp.Credit_Card_Number__c;
            result.cvv = opp.CVV__c;
            
            results.add(result);
        }
        
        return results;
    }
}