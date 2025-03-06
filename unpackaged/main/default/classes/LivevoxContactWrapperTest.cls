@isTest
private class LivevoxContactWrapperTest {

    @isTest
    static void testGetLiveboxCreateContactDetailsWrapper() {
        Lead testLead = new Lead(
            FirstName = 'James',
            LastName = 'Bond',
            Email = 'james.bond@example.com',
            MobilePhone = '5555555555',
           // Velocify_Id__c = '1234556',
            LeadSource = 'DT Form',
            Total_Tax_Debt__c = 50000,
            Status = 'Working'
        );
      

        LivevoxContactWrapper.LivevoxCreateContactDetails result = 
            LivevoxContactWrapper.getLiveboxCreateContactDetailsWrapper(testLead);


        //Assert.areEqual(testLead.Velocify_Id__c, result.createContactDetails.account, 'Velocify Id should match');
        Assert.areEqual(testLead.Email, result.createContactDetails.person.email, 'Email should match');
        Assert.isTrue(!result.createContactDetails.customFields.isEmpty(), 'Custom fields should not be empty');
    }

    @isTest
    static void testGetLiveboxUpdateContactDetailsWrapper() {

        Lead testLead = new Lead(
            FirstName = 'James',
            LastName = 'Bond',
            Email = 'james.bond@example.com',
            MobilePhone = '5555555555',
            //Velocify_Id__c = '1234556',
            LeadSource = 'DT Form',
            Total_Tax_Debt__c = 50000,
            Status = 'Working'
        );

        LivevoxContactWrapper.LivevoxUpdateContactDetails result = 
            LivevoxContactWrapper.getLiveboxUpdateDetailsWrapper(testLead);

       // Assert.areEqual(testLead.Velocify_Id__c, result.updateContactDetails.account, 'Velocify Id should match');
        Assert.areEqual(testLead.Email, result.updateContactDetails.person.email, 'Email should match');
        Assert.isTrue(!result.updateContactDetails.customFields.isEmpty(), 'Custom fields should not be empty');
    }
}