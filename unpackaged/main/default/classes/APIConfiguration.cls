public with sharing class APIConfiguration {
    public String token;
    public String apiVersion;

    public APIConfiguration(String token, String apiVersion) {
        this.token = token;
        this.apiVersion = apiVersion;
    }
}