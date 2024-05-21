public class WeatherWrapper {
    @AuraEnabled public String city {get;set;}
    @AuraEnabled public String temperature {get;set;}
    @AuraEnabled public String description {get;set;}
    @AuraEnabled public String icon {get;set;}
}