import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// This class represents a position provider. It provides
// latitude, longitude, and some status information to its
// consumers.
class PositionProvider extends ChangeNotifier {
  double latitude = 200;
  double longitude = 200;
  bool _isKnown = false; // True if app knows user's position.
  bool _failedToLoad = false; // True if the app fails to determine user's position. May seem similar to _isKnown, but has slightly different uses.
  late final Timer _timer;


  // Constructor for PositionProvider class that initializes
  // a periodic Timer to update user's position every second.
  PositionProvider() {
    _timer = Timer.periodic(const Duration(seconds: 1), _updatePosition);
  }


  // Updates the position (i.e. latitude and longitude fields).
  // Sets _failedToLoad to true if unable to determine position.
  // Parameter:
  // - Timer timer: the periodic Timer initiated in constructor
  void _updatePosition(Timer timer) async {
    try {
      final pos = await _determinePosition();
      updatePosition(pos.latitude, pos.longitude);
    } catch (_) {
      _failedToLoad = true;
      _isKnown = false;
    }
  }


  // Helper method for _updatePosition; does the actual updating.
  // Sets fields and notifies listeners.
  // Parameters:
  // - double latitude: new latitude to update to
  // - double longitude: new longitude to update to
  void updatePosition(double latitude, double longitude) {
    this.latitude = latitude;
    this.longitude = longitude;
    _isKnown = true;
    _failedToLoad = false;
    notifyListeners();
  }


  // Cleaning up after ourselves; disposes the timer.
  @override 
  dispose(){
    _timer.cancel();
    super.dispose();
  }
  

  // Getter for whether there was an error or exception caught 
  // loading the position or accessing location permissions.
  bool get loadFailure {
    return _failedToLoad;
  }


  // Getter for boolean field isKnown; whether the provider knows
  // the user's position or not.
  bool get status {
    return _isKnown;
  }


  /// Code copied from https://pub.dev/packages/geolocator.
  ///
  /// Determine the current position of the device.
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
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
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}