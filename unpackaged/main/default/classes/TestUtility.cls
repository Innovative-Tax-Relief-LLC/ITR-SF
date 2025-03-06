@isTest
public class TestUtility {
    
    public static Account createAccount(String name, string industry){
        return new Account(Name = name, Industry = industry, 
                           Website='http://google.com',
                           Description = 'test description');
    }

    public static User createUser(String username, string communityNickname, string email){
        return new User(Username = username, CommunityNickname = communityNickname, Email = email,
                        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
                        Alias = 'tuser', EmailEncodingKey = 'UTF-8', LastName = 'User', 
                        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
                        TimeZoneSidKey = 'America/Los_Angeles');
    }

    public static Contact createContact(Id accountId, string lastname){
        return new Contact(accountId = accountId, lastname = lastname);
    }

    public static Product2 createProduct2(String pName, String pCode){
        Product2 product = new Product2(
            Name = pName,
            ProductCode = pCode,
            IsActive = true
        );
        return product;
    }

    public static Lead createLead(String companyName, String firstname, String lastName){
        return new Lead(company=companyName, 
                        firstname=firstname, 
                        lastname=lastname, 
                        email=firstname+'.'+lastname+'@'+companyName.deleteWhitespace()+'.com',
                        LeadSource = 'Email',
                        Industry = 'banking');
    }

    public static Opportunity createOpportunity(Id accountId, string name, string stageName, date closedDate){
        return new Opportunity(AccountId = accountId, Name = name, 
                                StageName = stageName, CloseDate = closedDate);
    }

    public static List<Opportunity> createOpportunities(Integer Qty, Id accountId, string name, string stageName, date closedDate){
        List<Opportunity> returnList = new List<Opportunity>();
        for(Integer i = 0; i < Qty; i++){
            returnList.add(createOpportunity(accountId, name, stageName, closedDate));
        }
        return returnList;
    }

}