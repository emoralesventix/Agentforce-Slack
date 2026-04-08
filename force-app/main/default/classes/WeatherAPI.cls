public class WeatherAPI {
      public class WeatherRequest {
        @InvocableVariable(required=true)
        public String location;

        @InvocableVariable(required=true)
        public Integer days;
    }

    public class WeatherResponse {
        @InvocableVariable
        public String rawForecastJson;
    }

    @InvocableMethod(label='Get Weather Forecast' description='Llama a WeatherAPI.com para obtener el pronóstico del tiempo')
    public static List<WeatherResponse> getForecast(List<WeatherRequest> requests) {
        List<WeatherResponse> responses = new List<WeatherResponse>();

        for (WeatherRequest reqItem : requests) {
            WeatherResponse resp = new WeatherResponse();
            resp.rawForecastJson = fetchWeather(reqItem.location, reqItem.days);
            responses.add(resp);
        }

        return responses;
    }

    private static String fetchWeather(String location, Integer days) {
        String endpoint = 'callout:Wether_API/forecast.json'
                        + '?key=db07b47b816d46e483125411251007'
                        + '&q=' + EncodingUtil.urlEncode(location, 'UTF-8')
                        + '&days=' + days;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res;

        try {
            res = http.send(req);
            if (res.getStatusCode() == 200) {
                return res.getBody();
            } else {
                System.debug('WeatherAPI Error: ' + res.getStatusCode() + ' - ' + res.getBody());
                return '{"error":"Status '+res.getStatusCode()+'"}';
            }
        } catch (Exception e) {
            System.debug('Exception calling WeatherAPI: ' + e.getMessage());
            return '{"error":"'+e.getMessage()+'"}';
        }
    }
}