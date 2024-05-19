public class WeatherService {
    @AuraEnabled(cacheable=true)
    public static WeatherWrapper getWeather(String city) {
        String apiKey = 'dff7f9b1a1d3e65f63fe9e6331e80cfc';
        String endpoint = 'https://api.openweathermap.org/data/2.5/weather?q=' + city + '&appid=' + apiKey + '&units=metric';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        WeatherWrapper weatherDet = new WeatherWrapper();

        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            weatherDet.city = String.valueOf(result.get('name'));
            Map<String, Object> mainResult = (Map<String, Object>) result.get('main');

            weatherDet.temperature = String.valueOf(mainResult.get('temp'));
            weatherDet.pressure = String.valueOf(mainResult.get('pressure'));
            weatherDet.humidity = String.valueOf(mainResult.get('humidity'));
            weatherDet.feelsLike = String.valueOf(mainResult.get('feels_like'));
            weatherDet.tempMin = String.valueOf(mainResult.get('temp_min'));
            weatherDet.tempMax = String.valueOf(mainResult.get('temp_max'));

            List<Object> weatherList = (List<Object>) result.get('weather');

            if (!weatherList.isEmpty()) {
                Map<String, Object> weather = (Map<String, Object>) weatherList[0];
                weatherDet.description = String.valueOf(weather.get('description'));
                weatherDet.icon = String.valueOf(weather.get('icon'));
            }

            return weatherDet;
        } else {
            throw new AuraHandledException('Error fetching weather data');
        }
    }
}