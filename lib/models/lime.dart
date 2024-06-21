import 'package:lemun/models/vehicle.dart';
import 'package:lemun/models/vehicle_types.dart';

// This class represents a Lime vehicle (i.e. bike or scooter).
class Lime implements Vehicle {
  String id;
  @override
  double latitude;
  @override
  double longitude;
  bool isReserved;
  bool isDisabled;
  @override
  VehicleType vehicleType;

  /// Constructor used by json factory construtor
  Lime({required this.id, required this.latitude, required this.longitude,
        required this.isReserved, required this.isDisabled, required this.vehicleType});

  /// Initializes a Lime from a json
  /// paramaters:
  ///  - data: the json to turn into a Lime object
  factory Lime.fromJson(Map<String, dynamic> data) {
    final id = data['bike_id'];
    final latitude = data['lat'];
    final longitude = data['lon'];
    final isReserved = switch(data['is_reserved']) {
      0 => false,
      _ => true
    };
    final isDisabled = switch(data['is_disabled']) {
      0 => false,
      _ => true
    };
    final vehicleType = switch(data['vehicle_type']) {
      'scooter' => VehicleType.scooter,
      'bike' => VehicleType.bike,
      _ => VehicleType.none
    };
    return Lime(id: id, latitude: latitude, longitude: longitude,
                isReserved: isReserved, isDisabled: isDisabled, vehicleType: vehicleType);
  }
}