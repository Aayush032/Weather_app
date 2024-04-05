import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String,dynamic>> weather;
  Future<Map<String, dynamic>> getWeatherDetails() async {
    try {
      String cityName = "Kathmandu";
      final res = await http.get(
        Uri.parse(
            "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey"),
      );

      final data = jsonDecode(res.body);
      if (data["cod"] != "200") {
        throw "An unexpected error occured";
      }
      return data;

      // temp = data["list"][0]["main"]["temp"] - 273.15;
      // temp = double.parse(temp.toStringAsFixed(2));
    } catch (e) {
      throw e.toString();
    }
  }
  @override
  void initState() {
    super.initState();
    weather = getWeatherDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Weather App",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    weather = getWeatherDetails();
                  });
                },
                icon: const Icon(
                  Icons.refresh,
                  size: 30,
                ),
              ),
            )
          ],
        ),
        body: FutureBuilder(
          future: weather,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            final data = snapshot.data!;
            final currentWeatherData = data["list"][0];
            final currentTemp = currentWeatherData["main"]["temp"] - 273.15;
            final currentTempInCel = int.parse(currentTemp.toStringAsFixed(0));

            final currentPressure = currentWeatherData["main"]["pressure"];
            final currentHumidity = currentWeatherData["main"]["humidity"];
            final currentWind = currentWeatherData["wind"]["speed"];

            final currentSky = currentWeatherData["weather"][0]["main"];
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kathmandu",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    //Weather details
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10,
                            sigmaY: 10,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  " $currentTempInCel°C",
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Icon(
                                  currentSky == "Clouds" || currentSky == "Rain"
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 56,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  currentSky,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //Weather Forecast
                  const Text(
                    "Weather Forecast",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index){
                      final hourlyForecast = data["list"][index+1]; 
                      //final forecastTime = hourlyForecast["dt"];
                    
                      final forecastTemp = hourlyForecast["main"]["temp"] - 273.15;
                    
                      final forecastSky = hourlyForecast["weather"][0]["main"];
                      final time = DateTime.parse(hourlyForecast["dt_txt"]);
                        return HourlyForecastItem(
                          time: DateFormat.j().format(time),
                           icon: forecastSky == "Clouds" || forecastSky == "Rain" ? Icons.cloud : Icons.sunny,
                            value: forecastTemp.toStringAsFixed(0),);
                      }),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //Additional information
                  const Text(
                    "Additional Information",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Additionalnfo(
                        icon: Icons.water_drop,
                        label: "Humidity",
                        value: currentHumidity.toString(),
                      ),
                      Additionalnfo(
                        icon: Icons.air,
                        label: "Wind Speed",
                        value: currentWind.toString(),
                      ),
                      Additionalnfo(
                        icon: Icons.beach_access,
                        label: "Pressure",
                        value: currentPressure.toString(),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ));
  }
}
