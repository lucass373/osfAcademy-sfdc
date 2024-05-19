public class WeatherWrapper {
    @AuraEnabled public String city {get;set;}
        @AuraEnabled public String temperature {get;set;}
        @AuraEnabled public String pressure {get;set;}
        @AuraEnabled public String humidity {get;set;}
        @AuraEnabled public String feelsLike {get;set;}
        @AuraEnabled public String tempMin {get;set;}
        @AuraEnabled public String tempMax {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public String icon {get;set;}
}