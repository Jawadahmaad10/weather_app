import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  double temp = 0;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   getCurrentWeather();
  // }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = " London";
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&APPID=$openWeatherAPIKey'));
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        //throw data['message'];
        throw 'An unexpected error occurred';
      }
      return data;

      //print(data['list'][0]['main']['temp']);
      // setState(() {
      //  temp = data['list'][0]['main']['temp'];
      // });
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  weather = getCurrentWeather();
                });
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          //final currentTemp = data['list'][0]['main']['temp'];
          final currentTemp = currentWeatherData['main']['temp']; // both same
          //final currentSky = data['list'][0]['weather'][0]['main'];
          final currentSky = currentWeatherData[0]['weather'][0]['main'];
          // final currentPressure = data['list'][0]['main']['pressure'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                " $currentTemp K",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                currentSky,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                const Text(
                  "Hourly Forecast",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 5; i++)
                //         HourlyForecastitem(
                //           time: data['list'][i+1]['dt'].toString(),
                //           icon: data['list'][i+1]['weather'][i+1]['main'] == 'Clouds' ||  data['list'][i+1]['weather'][i+1]['main'] == 'Rain' ?  Icons.cloud : Icons.sunny,
                //           temperature: data['list'][i+1]['main']['temp'].toString(),
                //         ),
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final hourlyForecast = data['list'][index + 1];
                        final hourlySky =
                            data['list'][index + 1]['weather'][0]['main'];
                        final hourlyTemp =
                            hourlyForecast['main']['temp'].toString();
                        final time =
                            DateTime.parse(hourlyForecast['dt_txt'].toString());
                        return HourlyForecastitem(
                          //3:00 6:00
                          time: DateFormat.Hm()
                              .format(time), //hour and minute 3:00
                          temperature: hourlyTemp,
                          icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                              ? Icons.cloud
                              : Icons.sunny,
                        );
                      }),
                ),
                SizedBox(
                  height: 20,
                ),
                //additional information °
                const Text(
                  "Additional Forecast",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: currentHumidity.toString(),
                    ),
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      label: 'Wind Speed',
                      value: currentWindSpeed.toString(),
                    ),
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      label: currentPressure.toString(),
                      value: '1000',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
