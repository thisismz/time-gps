import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'db_helper.dart';

class SpeedDisplay extends StatefulWidget {
  @override
  _SpeedDisplayState createState() => _SpeedDisplayState();
}

class _SpeedDisplayState extends State<SpeedDisplay> {
  double speed = 0.0;
  double latitude = 0.0;
  double longitude = 0.0;


  late Timer _timer;
  DateTime timeNow = DateTime.now();
  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) async {
      await _getLocationData();
      setState(() {}); // Trigger UI update
      _saveLocationData(); // Save location data to SQLite
    });
  }
  Future<void> _saveLocationData() async {
    await DBHelper.instance.insertLocation(latitude, longitude, speed);
  }

  Future<void> _getLocationData() async {
    try {
      Position position = await _determinePosition();
      setState(() {
        speed = position.speed ?? 0.0;
        latitude = position.latitude;
        longitude = position.longitude;
        timeNow= DateTime.now();
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Latitude: $latitude, Longitude: $longitude',
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(height: 20.0),
        Text(
          'Speed: ${speed.toStringAsFixed(1)}',
          style: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20.0),
        Text(
          'time: ${timeNow}',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
