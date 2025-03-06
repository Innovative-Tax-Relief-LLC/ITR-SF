public with sharing class APIConfigurationHelper {
    public static APIConfiguration getConfiguration(String configName) {
        API_Configuration__mdt config = API_Configuration__mdt.getInstance(configName);

        if (Test.isRunningTest()) {
            config = new API_Configuration__mdt(
                        Token__c = 'sampleToken',
                        API_Version__c = '1.0',
                        MasterLabel = 'PitbullTaxAPI'
                    );
        }

        if (config == null) {
            throw new CustomException('API Configuration not found for: ' + configName);
        }
        
        return new APIConfiguration(config.Token__c, config.API_Version__c);
    }
}