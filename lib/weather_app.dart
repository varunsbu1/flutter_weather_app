import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/additionalinfo.dart';
import 'package:weatherapp/hourly_forecast_item.dart';
import 'package:weatherapp/secret.dart';
import 'package:weatherapp/weather_card.dart';

class WeatherScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const WeatherScreen(
      {super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String cityName = 'London';
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'City not found';
      }

      return data;
    } catch (e) {
      throw 'An error occurred';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: widget.toggleTheme,
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;

          return Column(
            children: [
              // Search Field
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8.0 : 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Enter City Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            cityName = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          cityName = _controller.text;
                        });
                      },
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: getCurrentWeather(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator.adaptive());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }

                    final data = snapshot.data!;
                    final currentWeather = data['list'][0];
                    final currentTemp = currentWeather['main']['temp'];
                    final currentSky = currentWeather['weather'][0]['main'];
                    final currentPressure = currentWeather['main']['pressure'];
                    final currentHumidity = currentWeather['main']['humidity'];
                    final currentSpeed = currentWeather['wind']['speed'];

                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main Weather Card
                            SizedBox(
                              width: double.infinity,
                              child: WeatherCard(
                                  temp: currentTemp,
                                  currentsky: currentSky,
                                  isSmallScreen: isSmallScreen),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Weather Forecast',
                              style: TextStyle(
                                  fontSize: isSmallScreen ? 20 : 25,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            // Hourly Forecast
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                itemCount: 5,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  final forecast = data['list'][index + 1];
                                  final unixTimestamp = forecast['dt'];
                                  final dateTime =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          unixTimestamp * 1000);
                                  final formattedTime = DateFormat('h:mma')
                                      .format(dateTime); // Format like 07:00AM
                                  return WeatherCard(
                                      temp: currentTemp,
                                      currentsky: currentSky,
                                      isSmallScreen: isSmallScreen);
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Additional Information',
                              style: TextStyle(
                                  fontSize: isSmallScreen ? 20 : 25,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                AdditonalInfoItem(
                                  icon: Icons.water_drop,
                                  label: 'Humidity',
                                  value: currentHumidity.toString(),
                                ),
                                AdditonalInfoItem(
                                  icon: Icons.air,
                                  label: 'Wind Speed',
                                  value: currentSpeed.toString(),
                                ),
                                AdditonalInfoItem(
                                  icon: Icons.beach_access,
                                  label: 'Pressure',
                                  value: currentPressure.toString(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
