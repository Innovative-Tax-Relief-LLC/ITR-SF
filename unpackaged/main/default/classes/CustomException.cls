public with sharing class CustomException extends Exception {
    public CustomException(String internalMessage, String externalMessage) { 
        this(externalMessage); 
    }
}