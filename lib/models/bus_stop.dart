import 'dart:math';

import 'package:lemun/models/vehicle.dart';
import 'package:lemun/models/vehicle_types.dart';

// This class represents a bus stop that can be displayed on the map view
class BusStop implements Vehicle {


  // Constructor to set all the fields of the bus stops - name, latitude, and longitude
  BusStop({required this.name, required this.latitude, required this.longitude});

  final String name;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final VehicleType vehicleType = VehicleType.bus;



  // Gets the distance of a bus stop to a another position (represented by a latitude, longitude)
  double distanceFrom({required double latitude, required double longitude}) {
    double dx = (this.latitude - latitude);
    double dy = (this.longitude - longitude);

    return sqrt(_squared(dx) + _squared(dy));

  }

   // Gets the distance from the bus stop to the parameter position in meter
  double distanceInMeters({required double latitude, required double longitude}){
    return 111139 * distanceFrom(latitude: latitude, longitude: longitude);

  }

  // toString just for debugging
  @override
  String toString() {

    return '$name: ($latitude, $longitude)';

  }
  // Private helper for some distance math
  num _squared(num x) { return x * x; }

}