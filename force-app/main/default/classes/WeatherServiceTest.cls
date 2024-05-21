@isTest
public class WeatherServiceTest {
    //Class to simulate a http response
    public class WeatherServiceMock implements HttpCalloutMock {
        private String responseBody;
        private Integer statusCode;
    
        // Constructor to set the response body and status code
        public WeatherServiceMock(String responseBody, Integer statusCode) {
            this.responseBody = responseBody;
            this.statusCode = statusCode;
        }

    // Implement the respond method to return the mock response
    public HTTPResponse respond(HTTPRequest req) {
        // Create a new HTTPResponse object
        HttpResponse res = new HttpResponse();
        // Set the status code
        res.setStatusCode(statusCode);
        // Set the response body
        res.setBody(responseBody);
        return res;
    }
}

    
    
    @isTest
    static void testGetWeather_Success() {
        // Mock HTTP callout response
        String mockResponseBody = '{"name":"London","main":{"temp":15},"weather":[{"description":"Cloudy","icon":"04d"}]}';
        System.Test.setMock(HttpCalloutMock.class, new WeatherServiceMock(mockResponseBody, 200));
        
        // Call the method under test
        WeatherWrapper result = WeatherService.getWeather('London');
        
        // Verify the result
        System.assertEquals('London', result.city);
        System.assertEquals('15', result.temperature);
        System.assertEquals('Cloudy', result.description);
        System.assertEquals('04d', result.icon);
    }
    
    @isTest
    static void testGetWeather_Error() {
        // Mock HTTP callout response with error status code
        System.Test.setMock(HttpCalloutMock.class, new WeatherServiceMock('Error fetching weather data', 500));
        
        // Call the method under test
        try {
            WeatherService.getWeather('London');
            // If no exception is thrown, the test fails
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            // Verify the error message
            System.assertEquals('Error fetching weather data', e.getMessage());
        }
    }
}