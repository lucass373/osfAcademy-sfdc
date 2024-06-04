public class WeatherService {

    // This method retrieves weather data for a given city
    @AuraEnabled(cacheable=true)
    public static WeatherWrapper getWeather(String city) {
    
        // Retrieve API key from custom metadata
        Weather_API_Config__mdt apiConfig = [SELECT API_Key__c FROM Weather_API_Config__mdt LIMIT 1];
        String apiKey = apiConfig.API_Key__c;

        String billingCity;

        if (city.contains(' ')) {
            billingCity = city.replace(' ', '%20');
        } else {
            billingCity = city;
        }
        

        // Constructing the endpoint URL for the API call
        String endpoint = 'https://api.openweathermap.org/data/2.5/weather?q=' + billingCity + '&appid=' + apiKey + '&units=metric';
        
        // Creating an HTTP object for making requests
        Http http = new Http();
        // Creating an HTTP request object
        HttpRequest request = new HttpRequest();
        // Setting the endpoint URL for the request
        request.setEndpoint(endpoint);
        // Setting the HTTP method as GET
        request.setMethod('GET');
        // Sending the HTTP request and getting the response
        HttpResponse response = http.send(request);
        
        // Creating a WeatherWrapper object to hold the weather data
        WeatherWrapper weatherDet = new WeatherWrapper();

        // If the response status code is 200 (OK), parse the weather data
        if (response.getStatusCode() == 200) {

            // Parsing the JSON response into a Map
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            // Extracting city name from the response
            weatherDet.city = String.valueOf(result.get('name'));

            // Extracting main weather information from the response
            Map<String, Object> mainResult = (Map<String, Object>) result.get('main');
            weatherDet.temperature = String.valueOf(mainResult.get('temp'));

            // Extracting weather description and icon from the response
            List<Object> weatherList = (List<Object>) result.get('weather');
            if (!weatherList.isEmpty()) {
                Map<String, Object> weather = (Map<String, Object>) weatherList[0];
                weatherDet.description = String.valueOf(weather.get('description'));
                weatherDet.icon = String.valueOf(weather.get('icon'));
            }

            // Returning the WeatherWrapper object with weather data
            return weatherDet;
        } else {
            // If response status code is not 200, throw an exception
            throw new AuraHandledException('Error fetching weather data');
        }
    }
}
