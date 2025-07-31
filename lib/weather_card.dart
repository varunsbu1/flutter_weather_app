import 'package:flutter/material.dart';
import 'package:weatherapp/weather_app.dart';

class WeatherCard extends StatelessWidget {
  final double temp;
  final String currentsky;
  final bool isSmallScreen;
  const WeatherCard(
      {super.key,
      required this.temp,
      required this.currentsky,
      required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8.0 : 16.0, vertical: 8.0),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                '$temp K',
                style: TextStyle(
                  fontSize: isSmallScreen ? 24 : 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                currentsky == 'Clouds' || currentsky == 'Rain'
                    ? Icons.cloud
                    : Icons.sunny,
                size: isSmallScreen ? 48 : 64,
              ),
              const SizedBox(height: 16),
              Text(
                currentsky,
                style: TextStyle(fontSize: isSmallScreen ? 18 : 25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
